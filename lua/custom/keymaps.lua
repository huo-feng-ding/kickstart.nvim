vim.g.mapleader = ' '
vim.g.maplocalleader = '\\'

-- 操作符映射
vim.keymap.set('o', "'", '`', { noremap = true })
vim.keymap.set('o', '`', "'", { noremap = true })
vim.keymap.set('n', "'", '`', { noremap = true })
vim.keymap.set('n', '`', "'", { noremap = true })

-- 后退取消搜索高亮
vim.api.nvim_set_keymap('n', '<BS>', [[v:hlsearch ? "<Cmd>nohlsearch\<CR>" : "\<CR>"]], { expr = true, noremap = true })

-- SecureCRT 连接的时候发送的 backspace 是 ctrl-h
vim.keymap.set('n', '<C-H>', [[v:hlsearch ? ":nohlsearch\<CR>" : "\<CR>"]], { expr = true, noremap = true })

-- 全选操作 普通模式和插入模式下均生效
-- 定义函数：全选复制并保持光标位置
local function async_select_all_and_copy()
  local cursor_pos = vim.fn.getpos '.'
  vim.schedule(function()
    vim.cmd 'normal! ggVG"+y'
    vim.fn.setpos('.', cursor_pos)
  end)
end
-- 映射 Ctrl+A 到函数
vim.keymap.set({ 'n', 'i' }, '<C-a>', async_select_all_and_copy, { desc = '全选并复制到剪贴板（保持光标）' })

-- 复制粘贴操作
vim.keymap.set('v', '<C-X>', '"+x', { noremap = true })
vim.keymap.set('v', '<S-Del>', '"+x', { noremap = true })
vim.keymap.set('v', '<C-C>', '"+y', { noremap = true })
vim.keymap.set('v', '<C-Insert>', '"+y', { noremap = true })
vim.keymap.set('n', '<C-Insert>', '<Nop>', { noremap = true })
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
    if filename ~= '' then vim.cmd('write ' .. filename) end
  else
    vim.cmd 'w'
  end
end, { desc = 'Save file' })

-- 终端兼容：将 Ctrl-s 转义序列绑定到保存
if vim.fn.has 'terminal' == 1 then vim.keymap.set('t', '<C-s>', [[<C-\><C-n>:w<CR>]], { noremap = true }) end

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
-- <leader>fn: 复制当前文件名（不含路径）到剪贴板
--   示例：/path/to/file.txt -> file.txt
vim.keymap.set('n', '<leader>fn', ':let @+ = expand("%:t") | echo "cb> " . @+<CR>', { noremap = true })

-- <leader>fp: 复制当前文件的完整绝对路径到剪贴板
--   示例：/path/to/file.txt -> /path/to/file.txt
vim.keymap.set('n', '<Leader>fp', ':let @+ = expand("%:p") | echo "cb> " . @+<CR>', { noremap = true })

-- <leader>dp: 复制当前文件所在目录的完整路径到剪贴板
--   示例：/path/to/file.txt -> /path/to
vim.keymap.set('n', '<Leader>dp', ':let @+ = expand("%:p:h") | echo "cb> " . @+<CR>', { noremap = true })

-- <leader>dd: 复制当前文件所在目录的名称到剪贴板（dir name Yield）
--   示例：/path/to/file.txt -> to
vim.keymap.set('n', '<Leader>dd', ':let @+ = expand("%:p:h:t") | echo "cb> " . @+<CR>', { noremap = true })

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

-- -- 插入模式下粘贴
-- vim.keymap.set('i', '<S-Insert>', '<C-R>+')
-- -- 普通模式下粘贴
-- vim.keymap.set('n', '<S-Insert>', '"+P')
-- -- 命令行模式下粘贴
-- vim.keymap.set('c', '<S-Insert>', '<C-R>+')
-- -- 可视模式下替换粘贴
-- vim.keymap.set('v', '<S-Insert>', '"+P')

-- 从寄存器或系统剪切板里查找
vim.keymap.set('n', '<Leader>nn', '/<C-R>"<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>n<space>', '/<C-R>+<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>NN', '?<C-R>"<CR>', { noremap = true })
vim.keymap.set('n', '<Leader>N<space>', '?<C-R>+<CR>', { noremap = true })

vim.keymap.set('c', '<C-v>', '<C-R>+', { noremap = true })

-- 向下滚动 1/3 屏幕 (对应 Ctrl-e)
vim.keymap.set('n', '<Leader>d', function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) / 3)
  vim.cmd('normal! ' .. lines .. '\x05') -- \x05 是 Ctrl-e 的转义码
end, { silent = true, desc = 'Scroll down 1/3 screen' })

-- 向上滚动 1/3 屏幕 (对应 Ctrl-y)
vim.keymap.set('n', '<Leader>u', function()
  local lines = math.floor(vim.api.nvim_win_get_height(0) / 3)
  vim.cmd('normal! ' .. lines .. '\x19') -- \x19 是 Ctrl-y 的转义码
end, { silent = true, desc = 'Scroll up 1/3 screen' })

-- n当前标签页下，分割一个空白窗口，做差异对比; n 表示 Normal 模式，<C-d> 代表 Ctrl+d
-- 映射为 <leader>dn (d 代表 diff, n 代表 new)
vim.keymap.set('n', '<leader>dn', ':vnew | windo diffthis<CR>', { desc = 'Diff with empty buffer' })
-- 直接对比当前文件和指定文件的差异,我们将 silent 设为 false。这是因为你需要看到命令行弹出的 :vert diffsplit 提示，才能知道接下来要输入路径
-- 映射为 <leader>df (d 代表 diff, f 代表 file)
-- 末尾不加 <CR>，方便您直接输入文件名
vim.keymap.set('n', '<leader>df', ':vert diffsplit ', { desc = 'Diff with file' })

-- 拆分窗口切换
vim.api.nvim_set_keymap('n', '<A-h>', '<C-w>h', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-j>', '<C-w>j', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-k>', '<C-w>k', { noremap = true })
vim.api.nvim_set_keymap('n', '<A-l>', '<C-w>l', { noremap = true })

-- 映射 Ctrl+Backspace 删除前一个单词
vim.api.nvim_set_keymap('i', '<A-BS>', '<C-w>', { noremap = true })

-- vim-ReplaceWithRegister插件的gr命令和lsp插件有冲突; 2025-07-11在init.lua的lsp配置中已经将下边这两个快捷键注释掉了，所以下边的也不用去删除了。这里先保持注释以便日后知道有这么个问题。 In Neovim, there's an overlap with LSP-related commands, and if you want to use the plugin's gr{motion} with inner/outer text objects, you need to remove (and optionally remap) the gra and gri commands:
if vim.fn.maparg('gra', 'n') ~= '' then vim.keymap.del('n', 'gra') end
if vim.fn.maparg('gri', 'n') ~= '' then vim.keymap.del('n', 'gri') end
if vim.fn.maparg('grt', 'n') ~= '' then vim.keymap.del('n', 'grt') end

-- 普通模式下：注释/取消注释当前行
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true, desc = 'Toggle line comment' })
vim.keymap.set('n', '<C-/>', 'gcc', { remap = true, desc = 'Toggle line comment' })

-- 插入模式下：注释当前行并保持在插入模式
-- 这里先回到普通模式执行 gcc，再返回插入模式,光标处在行尾
-- vim.keymap.set('i', '<C-_>', '<Esc>gccA', { remap = true, desc = 'Toggle line comment' })
-- vim.keymap.set('i', '<C-/>', '<Esc>gccA', { remap = true, desc = 'Toggle line comment' })

-- 插入模式下注释当前行：先切换成普通模式，进行注释操作，，再切换回插入模式，并且保持光标位置不变
local function toggle_comment_insert_mode()
  local win = vim.api.nvim_get_current_win()
  local cursor = vim.api.nvim_win_get_cursor(win)
  local old_line_len = #vim.api.nvim_get_current_line()

  -- 1. 退出插入模式
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)

  -- 2. 调度执行注释
  vim.schedule(function()
    vim.cmd 'normal gcc'

    -- 3. 再次调度：计算偏移并恢复
    vim.schedule(function()
      if vim.api.nvim_win_is_valid(win) then
        local new_line_len = #vim.api.nvim_get_current_line()
        -- 计算长度差：新长度 - 旧长度
        -- 如果是注释，偏移量为正；如果是取消注释，偏移量为负
        local diff = new_line_len - old_line_len

        -- 更新光标列位置，确保不小于 0
        local new_col = math.max(0, cursor[2] + diff)

        vim.api.nvim_win_set_cursor(win, { cursor[1], new_col })
        vim.cmd 'startinsert'
      end
    end)
  end)
end
-- 插入模式下注释当前行
vim.keymap.set('i', '<C-/>', toggle_comment_insert_mode, { desc = 'Toggle comment with offset' })
vim.keymap.set('i', '<C-_>', toggle_comment_insert_mode, { desc = 'Toggle comment with offset' })

-- 可选：可视模式下（按行注释选择的部分）
vim.keymap.set('v', '<C-_>', 'gc', { remap = true, desc = 'Toggle comment for selection' })
vim.keymap.set('v', '<C-/>', 'gc', { remap = true, desc = 'Toggle comment for selection' })

-- 解决在 WSL (Windows Subsystem for Linux) 环境下，Neovim 与 Windows 系统剪贴板无法互通的问题
local function setup_clipboard()
  if vim.fn.executable 'win32yank.exe' == 1 then
    -- 您的现有配置
    vim.g.clipboard = {
      name = 'win32yank-wsl',
      copy = {
        ['+'] = 'win32yank.exe -i --crlf',
        ['*'] = 'win32yank.exe -i --crlf',
      },
      paste = {
        ['+'] = 'win32yank.exe -o --lf',
        ['*'] = 'win32yank.exe -o --lf',
      },
      cache_enabled = true, -- 启用缓存提升性能
    }
  elseif vim.fn.executable 'clip.exe' == 1 then
    vim.g.clipboard = {
      name = 'windows-clip',
      copy = {
        ['+'] = 'iconv -f UTF-8 -t UTF-16LE | clip.exe',
        ['*'] = 'iconv -f UTF-8 -t UTF-16LE | clip.exe',
      },
      paste = {
        ['+'] = 'powershell.exe Get-Clipboard',
        ['*'] = 'powershell.exe Get-Clipboard',
      },
      cache_enabled = true, -- 启用缓存提升性能
    }
  end
end
setup_clipboard()

-- 实现 Ctrl + 鼠标左键 点击打开链接
vim.keymap.set('n', '<C-LeftMouse>', function()
  -- 获取鼠标点击的窗口和行列位置
  local mouse_pos = vim.fn.getmousepos()

  -- 检查点击是否在有效的普通窗口内（排除侧边栏、浮动窗等）
  if mouse_pos.winid == 0 or vim.api.nvim_win_get_config(mouse_pos.winid).relative ~= '' then return end

  -- 1. 切换到点击的窗口
  vim.api.nvim_set_current_win(mouse_pos.winid)
  -- 2. 将光标移动到点击的行和列
  vim.api.nvim_win_set_cursor(mouse_pos.winid, { mouse_pos.line, mouse_pos.column - 1 })

  -- 3. 执行打开链接的命令
  vim.cmd 'normal gx'
end, { desc = 'Move cursor and open URL under mouse' })
