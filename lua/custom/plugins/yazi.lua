-- yazi.nvim - 终端文件管理器
-- 快捷键：
--   |           打开 yazi（当前文件）
--   <Leader>cw  打开 yazi（工作目录）
--   <C-Up>      恢复上次 yazi 会话
--   <C-e>       在 yazi 中跳转到当前文件目录
--
-- 注意：
-- 这个插件存在的唯一问题就是由于使用了projects.yazi插件，打开yazi的时候进入的不是当前文件目录，而加载的projects.yazi里的目录
-- 目前重写了退出的快捷键，但是在新建标签页的时候，退出快捷键不起作用，还不知道是什么原因

vim.pack.add { 
  'https://github.com/mikavilpas/yazi.nvim',
  'https://github.com/nvim-lua/plenary.nvim',
 }

-- ── 1. Init 逻辑 (对应原 init) ──────────────────────────────────
-- 禁用 netrw，推荐在 setup 之前设置
vim.g.loaded_netrwPlugin = 1

-- ── 2. 快捷键映射 (对应原 keys) ──────────────────────────────────
local map = vim.keymap.set

-- 当前文件位置打开 Yazi
map({ 'n', 'v' }, '|', '<cmd>Yazi<cr>', { desc = 'Open yazi at the current file' })
-- 当前工作目录打开 Yazi
map('n', '<leader>cw', '<cmd>Yazi cwd<cr>', { desc = "Open yazi in nvim's cwd" })
-- 恢复上次会话
map('n', '<c-up>', '<cmd>Yazi toggle<cr>', { desc = 'Resume the last yazi session' })

-- ── 3. 配置与初始化 (对应原 opts) ────────────────────────────────
local openedPath = '/'

-- 辅助函数：获取父目录
local function get_parent_dir(filepath)
    if not filepath then return '.' end
            -- 统一替换路径分隔符为 '/'
    filepath = filepath:gsub('\\', '/')
            -- 去除末尾的 '/'（如果有）
    filepath = filepath:gsub('/+$', '')
    local parent = filepath:match('^(.*)/[^/]+$')
     -- 若没有父目录，返回当前目录 "."
    return parent or '.'
end

require('yazi').setup({
    open_for_directories = false,
    keymaps = {
        show_help = '?',
        open_file_in_vertical_split = '<a-v>',
        open_file_in_horizontal_split = '<a-x>',
        open_file_in_tab = '<a-o>',
        grep_in_directory = '<a-s>',
        replace_in_directory = '<a-g>',
        cycle_open_buffers = '<tab>',
        copy_relative_path_to_selected_files = '<a-y>',
        send_to_quickfix_list = '<a-q>',
        change_working_directory = '<a-\\>',
        open_and_pick_window = '<c-o>',
    },
    set_keymappings_function = function(yazi_buffer_id, config, context)
              -- 重写退出快捷键，因为yazi退出时会projects.yazi插件会将标签页写入文件;
        -- 2026.01.27 在yazi下使用z快速查询导航时按q键没有输出q字符，因为这里重写了q键的功能，所以换成Ctrl+q，避免冲突，暂时先不起用这个功能
        -- vim.keymap.set({ 't' }, '<C-q>', function()
        --   context.api:emit_to_yazi { 'quit' }
        -- end, { buffer = yazi_buffer_id })

        -- 加载当前打开的文件目录, 使用e快捷键的话在z查询导航时输不出e字符，所以改成Ctrl+e

        vim.keymap.set({ 't' }, '<C-e>', function()
          -- local path = vim.fn.expand '%' -- 因为yazi窗口已经打开了，这里取到的是yazi里的内容，不是nvim的当前标签页的路径
            context.api:emit_to_yazi({ 'cd', openedPath })
        end, { buffer = yazi_buffer_id })
    end,
    hooks = {
        -- This function is called when yazi is ready to process events.
        -- 如果其它窗口已经打开yazi，在nvim中打开yazi，这个函数目前没有被调用到
        -- on_yazi_ready = function(buffer, config, process_api)
        --   local file = io.open('d:\\output.txt', 'a')
        --   file:write 'ready2'
        --   file:close()
        --   process_api:emit_to_yazi { 'cd', openedPath }
        -- end,
        yazi_opened = function(preselected_path, yazi_buffer_id, config)
          -- https://yazi-rs.github.io/docs/configuration/keymap/#manager.find
            openedPath = get_parent_dir(preselected_path)
        end,
    },
}) 

