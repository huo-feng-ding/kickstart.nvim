-- vim-ReplaceWithRegister - 使用寄存器内容替换
-- 快捷键：
--   <Leader>gr  使用寄存器内容替换

vim.pack.add { 'https://github.com/inkarkat/vim-ReplaceWithRegister' }

-- ── 快捷键映射 ──────────────────────────────────────────────────────

-- 映射 <Leader>gr 到系统剪贴板寄存器 (+) 并触发插件功能
-- 这里使用 vim.keymap.set 是更现代的做法
-- remap = true 是必须的，因为我们需要触发插件定义的 <Plug> 映射
vim.keymap.set('n', '<Leader>gr', '"+gr', { 
    remap = true, 
    silent = true, 
    desc = "Replace with system register" 
})

-- 如果你依然偏好使用原生的 nvim_set_keymap：
-- vim.api.nvim_set_keymap('n', '<Leader>gr', '"+gr', { noremap = false, silent = true })

