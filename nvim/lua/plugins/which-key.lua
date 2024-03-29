-- NOTE: Plugins can also be configured to run lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = "VimEnter"
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end
return { -- Useful plugin to show you pending keybinds.
  "folke/which-key.nvim",
  event = "VimEnter", -- Sets the loading event to "VimEnter"
  config = function()
    -- Document existing key chains
    require("which-key").register {
      ["<leader>a"] = { name = "[A]lt file", _ = "which_key_ignore" },
      ["<leader>b"] = { name = "[B]rowse", _ = "which_key_ignore" },
      ["<leader>c"] = { name = "[C]ode", _ = "which_key_ignore" },
      ["<leader>d"] = { name = "[D]ocument", _ = "which_key_ignore" },
      ["<leader>f"] = { name = "[F]ile", _ = "which_key_ignore" },
      ["<leader>g"] = { name = "[G]it", _ = "which_key_ignore" },
      ["<leader>s"] = { name = "[S]earch", _ = "which_key_ignore" },
      ["<leader>t"] = { name = "Run [T]est", _ = "which_key_ignore" },
      ["<leader>w"] = { name = "[W]orkspace", _ = "which_key_ignore" },
    }
  end,
}
