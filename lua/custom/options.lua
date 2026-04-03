-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true
-- 空格/tab符号不显示占位符,显示的话页面上看着太乱了
vim.opt.list = false

-- 启用语法高亮
vim.opt.syntax = 'on'
-- 设置制表符的宽度为2个空格
vim.opt.tabstop = 2
-- 设置自动缩进的宽度为2个空格
vim.opt.shiftwidth = 2
-- 将制表符转换为空格
vim.opt.expandtab = true
-- 启用行号和相对行号
vim.opt.number = true
vim.opt.relativenumber = true
-- 设置 scrolloff
vim.opt.scrolloff = 3
-- 启用增量搜索
vim.opt.incsearch = true
-- 启用显示模式
vim.opt.showmode = true
-- 设置超时时间
vim.opt.timeout = true
vim.opt.timeoutlen = 1500
-- 忽略大小写
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.smoothscroll = false
-- 禁用环绕搜索
vim.opt.wrapscan = true
-- 启用当前行高亮
vim.opt.cursorline = true
-- 显示匹配括号
vim.opt.showmatch = true
-- 不兼容模式
vim.opt.compatible = false
-- 启用鼠标支持
vim.opt.mouse = 'a'
-- 插入模式下 Shift+光标键可以进行选择文字
vim.opt.keymodel = 'startsel'
-- 设定默认解码
vim.opt.fileencoding = 'utf-8'
vim.opt.fileencodings = { 'utf-8', 'gb18030', 'gbk', 'gb2312', 'cp936', 'usc-bom', 'euc-jp' }
-- Windows 下 gvim 的 backspace 不起作用配置
vim.opt.backspace = { 'indent', 'eol', 'start' }
-- 总是显示标签页
vim.opt.showtabline = 2
--" 不在缓冲区列表中显示未列出缓冲区
-- vim.opt.buflisted = false  -- 值为 false 这通常不是期望的行为，可能会让您在多文件切换时感到困惑，因为您无法轻松地通过缓冲区列表跳转到已经打开过的文件。

--" 切换到已经打开的缓冲区
vim.opt.switchbuf = 'useopen'
-- 启用系统剪贴板（支持跨应用复制粘贴）
-- vim.opt.clipboard = 'unnamedplus'
-- tab diffs 命令垂直分割窗口显示
vim.opt.diffopt:append 'vertical'

-- 开启标题显示
vim.opt.title = true
-- 自定义标题格式，加上 [NVIM] 前缀方便 AHK 识别
vim.opt.titlestring = '[NVIM] %t'
-- (可选) 退出时确保标题被清理（虽然 Terminal 通常会自动处理）
vim.api.nvim_create_autocmd('VimLeave', {
  callback = function() vim.opt.titlestring = '' end,
})

-- Set the C compiler to gcc for Windows
if vim.fn.has 'win32' == 1 then vim.env.CC = 'gcc' end

-- 重新定义 当前行和选中的行 的样式
vim.api.nvim_command 'highlight Visual guifg=White guibg=#0e5e97 gui=none'
vim.api.nvim_command 'highlight CursorLine cterm=NONE ctermbg=black ctermfg=green guibg=#064470 guifg=NONE'

-- gvim 字体设置
vim.opt.guifont = 'Cascadia Code PL:h12:cANSI:qDRAFT'

-- 打开文件时恢复上一次光标所在位置
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
})
-- 下边的配置虽然是等价的，但是在neovide中使用powershell profile 中的n函数打开第二个标签页文件时没有恢复上次光标所在位置
-- vim.api.nvim_create_autocmd('BufReadPost', {
--   pattern = '*',
--   callback = function()
--     local line = vim.fn.line '\'"'
--     if line > 1 and line <= vim.fn.line '$' then vim.cmd.normal 'g\'"' end
--   end,
-- })

-- 禁止在新行中自动添加注释符号
vim.api.nvim_create_autocmd('FileType', {
  pattern = '*',
  callback = function() vim.opt_local.formatoptions:remove { 'r', 'o' } end,
})

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

if vim.g.neovide then
  -- 以下代码实现在 Neovide 中根据输入模式自动切换输入法状态（IME）
  vim.g.neovide_input_ime = true

  local function set_ime(args)
    if args.event:match 'Enter$' then
      vim.g.neovide_input_ime = true
    else
      vim.g.neovide_input_ime = false
    end
  end

  local ime_input = vim.api.nvim_create_augroup('ime_input', { clear = true })

  vim.api.nvim_create_autocmd({ 'InsertEnter', 'InsertLeave' }, {
    group = ime_input,
    pattern = '*',
    callback = set_ime,
  })

  vim.api.nvim_create_autocmd({ 'CmdlineEnter', 'CmdlineLeave' }, {
    group = ime_input,
    -- pattern = '[/\\?]',
    pattern = { '/', '?' },
    callback = set_ime,
  })

  -- 1. 修复插入模式下的粘贴
  -- <C-R>+ 表示从系统剪贴板 (+) 寄存器插入内容
  vim.keymap.set('i', '<S-Insert>', '<C-R>+', { noremap = true, silent = true })

  -- 2. 修复命令行模式下的粘贴 (解决你之前配置的 / 和 ? 搜索时的粘贴)
  -- 在命令行中 <C-R>+ 同样有效, 在命令行粘贴文字后命令行没有变化，输入一个字符才会将粘贴的内容显示出来，这个<C-L>(快捷键的作用是 Redraw（重绘))映射可以让粘贴后立即显示
  -- vim.keymap.set('c', '<S-Insert>', '<C-R>+<C-L>', { noremap = true, silent = true })
  -- 避免在命令行模式中使用 silent = true 的复杂映射
  vim.keymap.set('c', '<S-Insert>', '<C-R>+', { noremap = true })

  -- 3. [可选] 针对 Neovide 的特殊优化
  -- 有时输入法会上屏带括号的 <S-Insert>，如果上面的不起效，可以尝试这个：
  -- vim.keymap.set('i', '<S-Insert>', '<Esc>"+pi', { noremap = true })

  -- 设为空字符串可关闭所有光标粒子特效 torpedo railgun pixiedust 等
  -- 1. 核心模式：电磁炮/导轨炮模式
  vim.g.neovide_cursor_vfx_mode = 'pixiedust'
  -- 2. 粒子密度：默认是 7.0，拉到 20.0 - 50.0 会有明显的“大雨”感
  vim.g.neovide_cursor_vfx_particle_density = 50.0
  -- 3. 粒子透明度：0.9 让粒子非常清晰亮眼
  vim.g.neovide_cursor_vfx_opacity = 200
  -- 4. 粒子生命周期：1.5 秒，让爆炸后的余辉停留更久，形成拖尾
  vim.g.neovide_cursor_vfx_particle_lifetime = 0.5
  -- 5. 粒子速度：提高速度让喷射感更强
  vim.g.neovide_cursor_vfx_particle_speed = 30.0
  vim.g.neovide_cursor_vfx_particle_phase = 2.0 -- 快速闪烁
  vim.g.neovide_cursor_vfx_particle_curl = 1.5 -- 粒子会打旋，视觉更丰富
  -- 6. 额外推荐：配合丝滑的光标移动（可选）
  vim.g.neovide_cursor_animation_length = 0.13 -- 光标移动动画时长
  vim.g.neovide_cursor_trail_size = 0.8 -- 光标拖尾大小
end

-- 修改标签页的显示
-- _TABLINE = {}
--
-- _TABLINE.generate_tabline = function()
--   local s = ''
--   for i = 1, vim.fn.tabpagenr '$' do
--     local buflist = vim.fn.tabpagebuflist(i)
--     local winnr = vim.fn.tabpagewinnr(i)
--     local title = vim.fn.fnamemodify(vim.fn.bufname(buflist[winnr]), ':t')
--     title = title ~= '' and title or '[No Name]'
--     -- 支持鼠标点击切换：%T 标记 + 序号
--     s = s .. '%' .. i .. 'T' -- 启用鼠标点击区域
--     s = s .. (i == vim.fn.tabpagenr() and '%#TabLineSel#' or '%#TabLine#')
--     s = s .. i .. ': ' .. title .. ' ' -- 格式：序号 + 标题
--   end
--   return s .. '%#TabLineFill#%T' -- 填充剩余空间并关闭鼠标区域
-- end
-- vim.o.tabline = '%!v:lua._TABLINE.generate_tabline()'

-- nvim-qt 配置加载有两部分，一部分是 D:\ProgramData\scoop\apps\neovim-qt\current\share\nvim-qt\runtime 下的插件和配置文件，另一部分是 ginit.vim 中的 UI 配置。
-- 1. 定义探测函数
-- local function setup_nvim_qt()
--   -- 探测 Scoop 默认的 current 软连接路径（不含版本号，升级不影响）
--   local scoop_apps = vim.fn.expand '$USERPROFILE' .. [[\AppData\Local\scoop\apps\neovim-qt\current\share\nvim-qt\runtime]]
--   -- 兼容全局安装路径 (D:\ProgramData\...)
--   local global_scoop = [[D:\ProgramData\scoop\apps\neovim-qt\current\share\nvim-qt\runtime]]
--
--   local target_path = ''
--   if vim.fn.isdirectory(scoop_apps) == 1 then
--     target_path = scoop_apps
--   elseif vim.fn.isdirectory(global_scoop) == 1 then
--     target_path = global_scoop
--   end
--
--   -- 2. 只有当路径存在，且当前确实是由 nvim-qt 启动时才执行
--   -- 注意：nvim-qt 启动时 v:progname 通常是 nvim-qt 或通过特定参数识别
--   if target_path ~= '' and (vim.fn.has 'gui_running' == 1 or vim.env.NVIM_QT_RUNTIME_PATH) then
--     vim.opt.rtp:append(target_path)
--     -- 尝试静默加载 shim 插件
--     pcall(vim.cmd, 'source ' .. target_path .. '/plugin/nvim_gui_shim.vim')
--
--     -- 直接在这里写 nvim-qt 的 UI 配置，不再需要 ginit.vim
--     vim.schedule(function()
--       if vim.fn.exists ':GuiFont' ~= 0 then
--         vim.cmd 'GuiAdaptiveColor 1'
--         vim.cmd 'GuiAdaptiveFont 1'
--         vim.cmd 'GuiAdaptiveStyle Fusion'
--         vim.cmd 'GuiRenderLigatures 1'
--         vim.cmd 'GuiScrollBar 1'
--         vim.cmd 'GuiTabline 0'
--       end
--     end)
--   end
-- end
-- setup_nvim_qt()
