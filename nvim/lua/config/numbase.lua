-- Number base inspector, for bitfield work.
--
--   ?  (normal) inspect the number under the cursor
--   ?  (visual) evaluate the selection as a C bit expression
--
-- Understands 42, 0x2A, 0b101010, 0o52, and (in C buffers) C octal like 052.
-- Visual mode handles << >> | & ^ ~ + - * / % and parentheses, so you can select
-- `(1 << 3) | (1 << 7)` and get the value.

local M = {}

-- Doubles hold integers exactly up to 2^53. Past that the display would start
-- lying, so it gets flagged instead.
local MAX_EXACT = 2 ^ 53
local U32 = 4294967295

---------------------------------------------------------------------- bit ops
-- LuaJIT's `bit` library is 32-bit only, which is too narrow for u64 masks,
-- so these work arithmetically instead.

local function binop(a, b, f)
  local result, place = 0, 1
  while a > 0 or b > 0 do
    if f(a % 2, b % 2) == 1 then
      result = result + place
    end
    a, b, place = math.floor(a / 2), math.floor(b / 2), place * 2
  end
  return result
end

local band = function(a, b) return binop(a, b, function(x, y) return (x == 1 and y == 1) and 1 or 0 end) end
local bor = function(a, b) return binop(a, b, function(x, y) return (x == 1 or y == 1) and 1 or 0 end) end
local bxor = function(a, b) return binop(a, b, function(x, y) return (x ~= y) and 1 or 0 end) end

-- Complemented within 32 bits, matching C's `int`/`unsigned` for mask idioms
-- such as `0xFF & ~0x0F`.
local function bnot(a)
  return U32 - (a % (U32 + 1))
end

----------------------------------------------------------------- number input

--- Parse a single numeric literal. `c_octal` enables C's leading-zero form.
function M.parse(tok, c_octal)
  local t = tok:gsub("[uUlL]+$", "") -- tolerate C suffixes: 1UL, 0xFFu
  if t:match("^0[xX]%x+$") then
    return tonumber(t:sub(3), 16), "hex"
  elseif t:match("^0[bB][01]+$") then
    return tonumber(t:sub(3), 2), "binary"
  elseif t:match("^0[oO][0-7]+$") then
    return tonumber(t:sub(3), 8), "octal"
  elseif c_octal and t:match("^0[0-7]+$") then
    return tonumber(t:sub(2), 8), "C octal"
  elseif t:match("^%d+$") then
    return tonumber(t, 10), "decimal"
  end
  return nil
end

--- Find the numeric literal spanning the cursor.
local function number_at_cursor()
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2] + 1
  -- Most specific first, so 0x2A is not read as a bare 0.
  for _, pat in ipairs({ "0[xX]%x+", "0[bB][01]+", "0[oO][0-7]+", "%d+" }) do
    local init = 1
    while true do
      local s, e = line:find(pat, init)
      if not s then
        break
      end
      if col >= s and col <= e then
        return line:sub(s, e)
      end
      init = e + 1
    end
  end
end

------------------------------------------------------------------- formatting

local function width_of(v)
  for _, w in ipairs({ 8, 16, 32, 64 }) do
    if v < 2 ^ w then
      return w
    end
  end
  return 64
end

local function to_bin(v, width)
  local digits = {}
  for i = width - 1, 0, -1 do
    digits[#digits + 1] = (math.floor(v / 2 ^ i) % 2 == 1) and "1" or "0"
  end
  -- group in nibbles for readability
  local out, s = {}, table.concat(digits)
  for i = 1, #s, 4 do
    out[#out + 1] = s:sub(i, i + 3)
  end
  return table.concat(out, " ")
end

local function bits_set(v, width)
  local set = {}
  for i = 0, width - 1 do
    if math.floor(v / 2 ^ i) % 2 == 1 then
      set[#set + 1] = tostring(i)
    end
  end
  return set
end

local function render(v, how, expr)
  local lines = {}
  if v >= MAX_EXACT then
    lines[#lines + 1] = "! above 2^53 - value may be imprecise"
  end
  local width = width_of(v)
  if expr then
    lines[#lines + 1] = "expr  " .. expr
  end
  lines[#lines + 1] = string.format("dec   %s", string.format("%.0f", v))
  lines[#lines + 1] = string.format("hex   0x%0" .. (width / 4) .. "X", v)
  lines[#lines + 1] = string.format("oct   0%o", v)
  lines[#lines + 1] = string.format("bin   %s", to_bin(v, width))
  local set = bits_set(v, width)
  lines[#lines + 1] = string.format("bits  %s", #set > 0 and table.concat(set, " ") or "(none)")
  lines[#lines + 1] = string.format("width %d-bit%s", width, how and ("  (read as " .. how .. ")") or "")
  return lines
end

local function float(lines)
  vim.lsp.util.open_floating_preview(lines, "", {
    border = "rounded",
    focusable = false,
    close_events = { "CursorMoved", "CursorMovedI", "BufHidden", "InsertCharPre" },
  })
end

------------------------------------------------------------------ expressions

-- Recursive descent over: or -> xor -> and -> shift -> unary -> primary
local function evaluate(src, c_octal)
  local pos = 1
  local function skip() pos = select(2, src:find("^%s*", pos)) + 1 end
  local function peek(lit)
    skip()
    return src:sub(pos, pos + #lit - 1) == lit
  end
  local function take(lit)
    if peek(lit) then
      pos = pos + #lit
      return true
    end
  end

  local parse_or
  local function primary()
    skip()
    if take("(") then
      local v = parse_or()
      if not take(")") then
        error("expected )")
      end
      return v
    end
    local tok = src:match("^0[xX]%x+", pos) or src:match("^0[bB][01]+", pos)
        or src:match("^0[oO][0-7]+", pos) or src:match("^%d+", pos)
    if not tok then
      error("unexpected input at " .. pos)
    end
    pos = pos + #tok
    -- consume C integer suffixes
    local suffix = src:match("^[uUlL]+", pos)
    if suffix then pos = pos + #suffix end
    local v = M.parse(tok, c_octal)
    if not v then
      error("bad number: " .. tok)
    end
    return v
  end

  local function unary()
    skip()
    if take("~") then return bnot(unary()) end
    if take("-") then return -unary() end
    if take("+") then return unary() end
    return primary()
  end

  -- C precedence: * / % bind tighter than + -, which bind tighter than << >>.
  -- So `1 << 5 - 1` is `1 << 4`, and `(1 << 5) - 1` is the N-bit mask idiom.
  local function muldiv()
    local v = unary()
    while true do
      if take("*") then
        v = v * unary()
      elseif take("/") then
        v = math.floor(v / unary())
      elseif take("%") then
        v = v % unary()
      else
        return v
      end
    end
  end

  local function additive()
    local v = muldiv()
    while true do
      skip()
      -- don't swallow the '-' of a following unary minus in `1 - -2`
      if peek("+") then
        take("+")
        v = v + muldiv()
      elseif peek("-") then
        take("-")
        v = v - muldiv()
      else
        return v
      end
    end
  end

  local function shift()
    local v = additive()
    while true do
      if take("<<") then
        v = v * 2 ^ additive()
      elseif take(">>") then
        v = math.floor(v / 2 ^ additive())
      else
        return v
      end
    end
  end

  local function band_lvl()
    local v = shift()
    -- single & only; && is not valid here
    while peek("&") and src:sub(pos + 1, pos + 1) ~= "&" do
      take("&")
      v = band(v, shift())
    end
    return v
  end

  local function bxor_lvl()
    local v = band_lvl()
    while take("^") do
      v = bxor(v, band_lvl())
    end
    return v
  end

  parse_or = function()
    local v = bxor_lvl()
    while peek("|") and src:sub(pos + 1, pos + 1) ~= "|" do
      take("|")
      v = bor(v, bxor_lvl())
    end
    return v
  end

  local value = parse_or()
  skip()
  if pos <= #src then
    error("trailing input: " .. src:sub(pos))
  end
  return value
end

M.evaluate = evaluate

------------------------------------------------------------------- entrypoints

local function c_buffer()
  local ft = vim.bo.filetype
  return ft == "c" or ft == "cpp" or ft == "h"
end

function M.inspect()
  local tok = number_at_cursor()
  if not tok then
    vim.notify("no number under cursor", vim.log.levels.WARN)
    return
  end
  local v, how = M.parse(tok, c_buffer())
  if not v then
    vim.notify("could not parse: " .. tok, vim.log.levels.WARN)
    return
  end
  float(render(v, how))
end

function M.inspect_selection()
  local a = vim.fn.getpos("v")
  local b = vim.fn.getpos(".")
  local lines = vim.fn.getregion(a, b, { type = vim.fn.mode() })
  local src = table.concat(lines, " ")
  local ok, v = pcall(evaluate, src, c_buffer())
  if not ok then
    vim.notify("cannot evaluate: " .. tostring(v), vim.log.levels.WARN)
    return
  end
  float(render(v, nil, vim.trim(src)))
end

vim.keymap.set("n", "?", M.inspect, { desc = "Number: dec/hex/bin under cursor" })
vim.keymap.set("x", "?", M.inspect_selection, { desc = "Number: evaluate bit expression" })

return M
