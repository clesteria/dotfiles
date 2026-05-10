-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- 編集時のマークアップ隠蔽設定解除(markdownのコードブロック等)
vim.opt.conceallevel = 0

-- yank とクリップボードの同期を無効化(LazyVimでは標準で有効)
vim.opt.clipboard = ""
