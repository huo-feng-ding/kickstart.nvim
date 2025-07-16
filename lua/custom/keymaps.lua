vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- 操作符映射
vim.keymap.set('o', "'", '`', { noremap = true })
vim.keymap.set('o', '`', "'", { noremap = true })
vim.keymap.set('n', "'", '`', { noremap = true })
vim.keymap.set('n', '`', "'", { noremap = true })

-- 后退取消搜索高亮
vim.api.nvim_set_keymap('n', '<BS>', [[v:hlsearch ? ":nohlsearch\<CR>" : "\<CR>"]], { expr = true, noremap = true })

-- SecureCRT 连接的时候发送的 backspace 是 ctrl-h
vim.keymap.set('n', '<C-H>', [[v:hlsearch ? ":nohlsearch\<CR>" : "\<CR>"]], { expr = true, noremap = true })

-- 复制粘贴操作
vim.keymap.set('v', '<C-X>', '"+x', { noremap = true })
vim.keymap.set('v', '<S-Del>', '"+x', { noremap = true })
vim.keymap.set('v', '<C-C>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-Insert>', '"+y', { noremap = true })
vim.keymap.set('n', '<C-V>', '"+gP', { noremap = true })
vim.keymap.set('v', '<C-V>', '"+gP', { noremap = true })
vim.keymap.set('i', '<C-V>', '<C-R>+', { noremap = true })
vim.keymap.set('', '<S-Insert>', '"+gP', { noremap = true })

-- Ctrl+s 进行保存操作
-- vim.keymap.set('n', '<C-s>', ':w<CR>', { noremap = true })
-- vim.keymap.set('v', '<C-s>', '<Esc>:w<CR>', { noremap = true })
-- vim.keymap.set('i', '<C-s>', '<Esc>:w<CR>a', { noremap = true })
-- 使用下边的方法在保存的过程中不会闪的一下出现弹窗
vim.keymap.set({ 'n', 'i', 'v' }, '<C-s>', function()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == '' or bufname:match '^term://' then
    -- 空缓冲区或终端缓冲区
    local cwd = vim.fn.getcwd()
    -- 判断路径是否以分隔符结尾
    local is_ends_with_sep = cwd:match '[\\/]$' ~= nil
    if not is_ends_with_sep then
      local sep = vim.fs.get_separator()
      cwd = cwd .. sep
    end
    local filename = vim.fn.input('Save to: ', cwd, 'file')
    if filename ~= '' then
      vim.cmd('write ' .. filename)
    end
  else
    vim.cmd 'w'
  end
end, { desc = 'Save file' })

-- 终端兼容：将 Ctrl-s 转义序列绑定到保存
if vim.fn.has 'terminal' == 1 then
  vim.keymap.set('t', '<C-s>', [[<C-\><C-n>:w<CR>]], { noremap = true })
end

-- 使用 leader 键进行复制粘贴
vim.keymap.set('v', '<leader>y', '"+y', { noremap = true })
vim.keymap.set('v', '<leader>yy', '"+Y', { noremap = true })
vim.keymap.set('v', '<leader>p', '"+p', { noremap = true })
vim.keymap.set('v', '<leader>P', '"+P', { noremap = true })
vim.keymap.set('n', '<leader>y', '"+y', { noremap = true })
vim.keymap.set('n', '<leader>yy', '"+Y', { noremap = true })
vim.keymap.set('n', '<leader>p', '"+p', { noremap = true })
vim.keymap.set('n', '<leader>P', '"+P', { noremap = true })

-- 复制文件名、路径等到系统剪贴板
vim.keymap.set('n', '<leader>fn', ':let @+ = expand("%:t") | echo "cb> " . @+<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>fp', ':let @+ = expand("%:p") | echo "cb> " . @+<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>dp', ':let @+ = expand("%:p:h") | echo "cb> " . @+<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>dn', ':let @+ = expand("%:p:h:t") | echo "cb> " . @+<CR>', { noremap = true })

-- 修改粘贴行为
vim.keymap.set('x', 'p', 'p:let @"=@0<CR>', { silent = true })

-- 插入模式下 jk 退出插入模式
vim.keymap.set('i', 'jk', '<Esc>', { noremap = true })

-- 不要通过删除 x 键输入默认寄存器
vim.keymap.set('n', 'x', '"_x', { noremap = true })
vim.keymap.set('v', 'x', '"_x', { noremap = true })
vim.keymap.set('n', 'X', '"_X', { noremap = true })
vim.keymap.set('v', 'X', '"_X', { noremap = true })
vim.keymap.set('n', 's', '"_s', { noremap = true })
vim.keymap.set('v', 's', '"_s', { noremap = true })
vim.keymap.set('n', 'S', '"_S', { noremap = true })
vim.keymap.set('v', 'S', '"_S', { noremap = true })
vim.keymap.set('n', 'C', '"_C', { noremap = true })
vim.keymap.set('v', 'C', '"_C', { noremap = true })

-- 插入模式下 Ctrl-Z 撤销，Ctrl-Y 恢复
vim.keymap.set('i', '<C-z>', '<C-O>u', { noremap = true })
vim.keymap.set('i', '<C-y>', '<C-O><C-r>', { noremap = true })

-- 修改 Y 命令为复制到最后一行
vim.keymap.set('n', 'Y', 'y$', { noremap = true })

-- Tab 键转成 %
vim.keymap.set('n', '<Tab>', '%', { noremap = true })
vim.keymap.set('v', '<Tab>', '%', { noremap = true })
vim.keymap.set('n', '>', '>>', { noremap = true })
vim.keymap.set('v', '>', '>gv', { noremap = true })
vim.keymap.set('n', '<', '<<', { noremap = true })
vim.keymap.set('v', '<', '<gv', { noremap = true })

-- 回车直接加上一行
vim.keymap.set('n', '<CR>', 'o<Esc>', { noremap = true })
vim.keymap.set('n', '<C-CR>', 'O<Esc>', { noremap = true })
vim.keymap.set('i', '<C-CR>', '<C-O>O', { noremap = true })
vim.keymap.set('n', '<NL>', 'O<Esc>', { noremap = true })
vim.keymap.set('i', '<NL>', '<C-O>O', { noremap = true })

-- 新建标签快捷键
vim.keymap.set('', '<C-t>', ':tabnew<CR>', { noremap = true })

-- 关闭标签页快捷键
vim.keymap.set('', '<C-w>', ':close<CR>', { noremap = true })

-- 从寄存器或系统剪切板里查找
vim.keymap.set('n', '<Leader>nn', '/<C-R>"<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>n<space>', '/<C-R>+<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>NN', '?<C-R>"<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>N<space>', '?<C-R>+<CR>', { noremap = true })

vim.keymap.set('c', '<C-v>', '<C-R>+', { noremap = true })

-- vim-ReplaceWithRegister插件的gr命令和lsp插件有冲突; 2025-07-11在init.lua的lsp配置中已经将下边这两个快捷键注释掉了，所以下边的也不用去删除了。这里先保持注释以便日后知道有这么个问题。 In Neovim, there's an overlap with LSP-related commands, and if you want to use the plugin's gr{motion} with inner/outer text objects, you need to remove (and optionally remap) the gra and gri commands:
vim.keymap.del('n', 'gra')
vim.keymap.del('n', 'gri')
