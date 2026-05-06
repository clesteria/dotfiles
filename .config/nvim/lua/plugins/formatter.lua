return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    -- ここにフォーマッターの対応表を書く
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    opts.formatters_by_ft.lua = { "stylua" }
    opts.formatters_by_ft.json = { "prettier" }
    opts.formatters_by_ft.yaml = { "prettier" }
  end,
}
