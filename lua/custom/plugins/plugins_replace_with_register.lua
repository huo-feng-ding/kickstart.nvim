-- vim-ReplaceWithRegister - 使用寄存器内容替换
-- 快捷键：
--   <Leader>gr  使用寄存器内容替换

return {
  'inkarkat/vim-ReplaceWithRegister',
  config = function() vim.api.nvim_set_keymap('n', '<Leader>gr', '"+gr', { noremap = false, silent = true }) end,
}
