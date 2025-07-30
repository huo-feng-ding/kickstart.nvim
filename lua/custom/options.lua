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
vim.opt.timeoutlen = 500
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
--" 设置标签页的缩进
vim.opt.tabstop = 2
--" 不在缓冲区列表中显示未列出缓冲区
vim.opt.buflisted = false
--" 切换到已经打开的缓冲区
vim.opt.switchbuf = 'useopen'
-- 启用系统剪贴板（支持跨应用复制粘贴）
-- vim.opt.clipboard = 'unnamedplus'

-- 重新定义 当前行和选中的行 的样式
vim.api.nvim_command 'highlight Visual guifg=White guibg=#0e5e97 gui=none'
vim.api.nvim_command 'highlight CursorLine cterm=NONE ctermbg=black ctermfg=green guibg=#064470 guifg=NONE'

-- gvim 字体设置
vim.opt.guifont = 'Cascadia_Code_PL:h12:cANSI:qDRAFT'

-- 打开文件时恢复上一次光标所在位置
-- vim.api.nvim_create_autocmd("BufReadPost", {
--   pattern = "*",
--   command = [[if line("'\"") > 1 && line("'\"") <= line("$") | execute "normal! g`\"" | endif]],
-- })
vim.api.nvim_create_autocmd('BufReadPost', {
  callback = function()
    local line = vim.fn.line '\'"'
    if line > 1 and line <= vim.fn.line '$' then
      vim.cmd.normal 'g\'"'
    end
  end,
})

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
