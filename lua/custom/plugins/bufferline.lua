-- -- bufferline.nvim - 标签页美化 (最佳方案)
-- -- 快捷键：
-- --   <A-t>      新建标签页
-- --   <A-w>      智能关闭标签页
-- --   <A-1~9>    切换到第 1~9 个标签页
-- --   <A-h/l>    左右平移滚动视图 (解决溢出显示不全的问题)

vim.pack.add { 'https://github.com/nvim-tree/nvim-web-devicons' }
vim.pack.add { 'https://github.com/akinsho/bufferline.nvim' }

-- ── 1. 智能关闭命令 (SmartTabClose) ─────────────────────────────
vim.api.nvim_create_user_command('SmartTabClose', function()
  -- local current_tab = vim.fn.tabpagenr() -- 当前标签页序号
  -- local total_tabs = vim.fn.tabpagenr '$' -- 总标签页数
  -- local function close()
  --    if total_tabs == 1 then
  --      vim.cmd 'q' -- 仅剩一个标签页时退出
  --    else
  --      vim.cmd 'tabclose' -- 否则关闭当前标签页
  --    end
  -- end

  local bufnr = vim.api.nvim_get_current_buf()
  local buf_modified = vim.api.nvim_get_option_value('modified', { buf = bufnr })

  if buf_modified then
    -- 弹窗提示用户选择
    local choice = vim.fn.confirm('文件未保存，是否保存？', '&Save\n&Discard\n&Cancel', 2)
    if choice == 1 then -- Save
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname == '' or bufname:match '^term://' then
        -- 空缓冲区或终端缓冲区
        local cwd = vim.fn.getcwd()
        -- 判断路径是否以分隔符结尾
        local is_ends_with_sep = cwd:match '[\\/]$' ~= nil
        if not is_ends_with_sep then cwd = cwd .. vim.fs.get_separator() end
        local filename = vim.fn.input('Save to: ', cwd, 'file')
        if filename ~= '' then vim.cmd('wq ' .. filename) end
      else
        vim.cmd 'wq'
      end
    elseif choice == 2 then -- Discard
      vim.cmd 'q!'
    end -- Cancel
  else
    vim.cmd 'q!'
  end
end, { desc = '智能关闭标签页,仅剩一个时退出，否则关闭当前页' })

-- ── 2. 快捷键映射 ────────────────────────────────────────────────
local map = vim.keymap.set
map({ 'n', 'i' }, '<A-t>', '<Cmd>tabnew<CR>')
map({ 'n', 'i' }, '<A-w>', '<Cmd>SmartTabClose<CR>')

-- 解决溢出显示不全的核心：左右滚动视图
map('n', '<A-h>', '<Cmd>BufferLineCyclePrev<CR>')
map('n', '<A-l>', '<Cmd>BufferLineCycleNext<CR>')

-- 快速切换 (1-9)
for i = 1, 9 do
  map({ 'n', 'i' }, '<A-' .. i .. '>', function() require('bufferline').go_to(i, true) end)
end

-- 修复后的 Telescope 跳转逻辑 (使用底层 picker)
map('n', '<A-p>', function()
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    -- 尝试使用多种可能的内置名称，增加容错性
    local picker = builtin.tabpages or builtin.tabs
    if picker then
      picker()
    else
      -- 如果内置选择器都找不到，手动列出所有 tabpage
      require('telescope.pickers')
        .new({}, {
          prompt_title = 'Tabpages',
          finder = require('telescope.finders').new_table {
            results = vim.api.nvim_list_tabpages(),
            entry_maker = function(entry)
              local bufnr = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(entry))
              local name = vim.api.nvim_buf_get_name(bufnr)
              return {
                value = entry,
                display = string.format('%d: %s', entry, vim.fn.fnamemodify(name, ':t')),
                ordinal = name,
              }
            end,
          },
          sorter = require('telescope.config').values.generic_sorter {},
          attach_mappings = function(prompt_bufnr, _)
            require('telescope.actions').select_default:replace(function()
              local selection = require('telescope.actions.state').get_selected_entry()
              require('telescope.actions').close(prompt_bufnr)
              vim.api.nvim_set_current_tabpage(selection.value)
            end)
            return true
          end,
        })
        :find()
    end
  end
end, { desc = '搜索并切换标签页' })

-- ── 3. Bufferline UI 配置, :h bufferline-configuration 查看更多配置 ───────────────────────────────────────
-- 真彩色（必须开启！）
vim.opt.termguicolors = true

-- 定义你想统一的激活背景色
local active_bg = '#3b82f6'
local active_fg = '#ffffff'
local diag_colors = {
    error = '#ff0000',
    warn  = '#ffa500',
    info  = '#ffffff',
    hint  = '#ffffff',
}

require('bufferline').setup {
  options = {
    mode = 'tabs', -- 必须设置为 tabs 模式
    -- "slant" 右倾斜坡 | "slope" 斜角 / 三角形 | "thick" 粗线 | "thin" 细线
    separator_style = 'slant',
    numbers = 'ordinal',
    indicator = {
      style = 'none', -- 当前激活标签的指示器样式
    },

    -- Bufferline 最大的优势：原生支持横向滚动 (Scrollable)
    -- 当标签页总数超过屏幕宽度时，它会自动隐藏边缘标签，
    -- 你可以用快捷键 A-h/l 或者鼠标滚轮左右滑动。

    diagnostics = 'nvim_lsp', -- 集成 LSP 状态（Java 开发利器）
    -- show_buffer_close_icons = true,
    -- show_close_icon = false,
    max_name_length = 20,

    -- 针对 Windows 11 / Neovide 的视觉平滑度优化
    themable = true,
    enforce_regular_tabs = false,
  },
  highlights = {
    -- 1. 填满背景：未激活的标签页背景（建议与状态栏或背景色一致）
    fill = {
      bg = '#1e222a', -- 整体背景色
    },

    -- 2. 核心：当前激活标签的高亮设置
    buffer_selected = {
      fg = active_fg, -- 纯白文字
      bg = active_bg, -- 亮蓝色背景（你可以根据喜好改为 #ff0000 红色）
      bold = true,
      italic = false,
    },

    -- 3. 处理斜角颜色：让斜角与激活背景色融为一体
    separator_selected = {
      fg = '#1e222a', -- 外部背景
      bg = active_bg, -- 内部背景（必须与 buffer_selected 的 bg 一致）
    },

    -- 4. 辅助部分：序号和图标也需要背景同步
    numbers_selected = {
      fg = active_fg,
      bg = active_bg,
      bold = true,
    },
    icon_selected = {
      bg = active_bg,
    },
    modified_selected = {
      fg = '#ffcc00', -- 修改过的文件显示明亮的黄色点
      bg = active_bg,
    },
    close_button_selected = {
      fg = active_fg,
      bg = active_bg,
    },

    -- 5. 未激活标签的调优（降低对比度，突出重点）
    buffer_visible = {
      fg = '#abb2bf',
      bg = '#1e222a',
    },
    separator = {
      fg = '#1e222a',
      bg = '#1e222a',
    },

    -- 核心修复：处理文件名重复时的后缀颜色
    duplicate_selected = {
      fg = active_fg, -- 后缀文字颜色（设为白色）
      bg = active_bg, -- 背景颜色（必须与 buffer_selected 的 bg 一致）
      italic = true, -- 建议设为斜体，方便区分文件名和后缀
      bold = true,
    },

    -- 可选：处理未激活标签页的重复后缀颜色
    duplicate = {
      fg = '#808080', -- 灰色
      bg = '#1e222a', -- 与非激活背景一致
      italic = true,
    },

    -- 可选：处理当前可见但未选中的标签页后缀（如果你分屏了）
    duplicate_visible = {
      fg = '#abb2bf',
      bg = '#1e222a',
      italic = true,
    },

    -- 1. 处理有错误时的选中标签背景
    error_selected = {
      fg = diag_colors.error,-- 错误图标/文字设为红色
      bg = active_bg, -- 背景必须与激活背景一致
      bold = true,
      italic = true,
    },
    error_diagnostic_selected = {
      fg = diag_colors.error,
      bg = active_bg,
    },

    -- 2. 处理有警告时的选中标签背景
    warning_selected = {
      fg = diag_colors.warn,-- 警告图标/文字设为橙色
      bg = active_bg, -- 背景保持一致
    },
    warning_diagnostic_selected = {
      fg = diag_colors.warn,
      bg = active_bg,
    },

    -- 3. 处理提示和信息（可选）
    info_selected = {
      fg = diag_colors.info,
      bg = active_bg,
    },
    info_diagnostic_selected = {
      fg = diag_colors.info,
      bg = active_bg,
    },
    hint_selected = {
      fg = diag_colors.hint,
      bg = active_bg,
    },
    hint_diagnostic_selected = {
      fg = diag_colors.hint,
      bg = active_bg,
    },
  },
}
