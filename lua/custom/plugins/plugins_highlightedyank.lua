-- vim-highlightedyank - 复制时高亮显示

return {
  'machakann/vim-highlightedyank',
  config = function()
    vim.g.highlightedyank_highlight_duration = 600
    vim.api.nvim_command 'highlight HighlightedyankRegion cterm=reverse gui=reverse'
  end,
}
