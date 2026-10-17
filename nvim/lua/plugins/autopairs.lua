local defer = require("config.defer")

return function()
  -- was: event = "InsertEnter"
  defer.on("InsertEnter", function()
    require("nvim-autopairs").setup({})
  end)
end
