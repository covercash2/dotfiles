
-- modify the rust-analyzer enabled features
local function enable_features(features)
  -- RustAnalyzer config { cargo = { features = "all" } }
  vim.cmd.RustAnalyzer {
    'config',
    {
      cargo = {
        features = features
      }
    }
  }
end

vim.keymap.set(
  "n", "<leader>lf",
  function() enable_features("all") end,
  { desc = "Enable all features" }
)
