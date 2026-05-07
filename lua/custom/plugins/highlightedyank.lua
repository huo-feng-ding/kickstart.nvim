-- vim-highlightedyank - 复制时高亮显示

vim.pack.add { 'https://github.com/machakann/vim-highlightedyank' }

-- 1. 设置高亮持续时间（单位：毫秒）
-- 设为 600ms，比默认稍长，方便确认复制范围
vim.g.highlightedyank_highlight_duration = 600

-- 2. 设置高亮样式
-- 这里使用了 reverse（反显），使拉取块在不同主题下都有很好的对比度
vim.api.nvim_command('highlight HighlightedyankRegion cterm=reverse gui=reverse')

