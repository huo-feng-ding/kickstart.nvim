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

return {
  'mikavilpas/yazi.nvim',
  version = '*', -- use the latest stable version
  event = 'VeryLazy',
  dependencies = {
    { 'nvim-lua/plenary.nvim', lazy = true },
  },
  keys = {
    -- 👇 in this section, choose your own keymappings!
    {
      '|',
      mode = { 'n', 'v' },
      '<cmd>Yazi<cr>',
      desc = 'Open yazi at the current file',
    },
    {
      -- Open in the current working directory
      '<leader>cw',
      '<cmd>Yazi cwd<cr>',
      desc = "Open the file manager in nvim's working directory",
    },
    {
      '<c-up>',
      '<cmd>Yazi toggle<cr>',
      desc = 'Resume the last yazi session',
    },
  },
  ---@type YaziConfig | {}
  -- opts = {
  --   -- if you want to open yazi instead of netrw, see below for more info
  --   open_for_directories = false,
  --   keymaps = {
  --     open_file_in_tab = 'o',
  --   },
  --   set_keymappings_function = function(yazi_buffer_id, config, context)
  --     -- 重写退出快捷键，因为yazi退出时会projects.yazi插件会将标签页写入文件
  --     vim.keymap.set({ 't' }, 'q', function()
  --       context.api:emit_to_yazi { 'quit' }
  --     end, { buffer = yazi_buffer_id })
  --     -- vim.keymap.set({ 't' }, 'e', function()
  --     --   local path = vim.fn.expand '%'
  --     --   -- local words = {}
  --     --   -- for word in string.gmatch(path, '%S+') do
  --     --   --   table.insert(words, word)
  --     --   -- end
  --     --   -- local quote_content = words[2]:match '^"(.*)"$'
  --     --   -- context.api:emit_to_yazi { 'cd', getParentDir(quote_content) }
  --
  --     --   local file = io.open('d:\\output.txt', 'w')
  --     --   file:write(path)
  --     --   file:write 'a'
  --     --   -- file:write(quote_content)
  --     --   -- file:write 'b'
  --     --   -- file:write(words[2])
  --     --   -- file:write 'c'
  --     --   -- for k, v in pairs(config) do
  --     --   --   -- file:write(k, ' ', type(v), ' ') -- 输出变量名和类型（避免打印过大的值）
  --     --   --   if type(v) == 'string' then
  --     --   --     file:write(v)
  --     --   --   end
  --     --   --   -- file:write '\n'
  --     --   -- end
  --     --   file:close()
  --     -- end, { buffer = yazi_buffer_id })
  --     -- vim.keymap.set({ 't' }, 'e', function()
  --     --   local current_file = vim.api.nvim_buf_get_name(0)
  --     --   if current_file == '' then
  --     --     current_file = nil -- 无文件（如 :enew）
  --     --   else
  --     --     current_file = vim.fn.fnamemodify(current_file, ':p') -- 确保绝对路径
  --     --   end
  --     --   context.api:emit_to_yazi { 'cd', "d:" }
  --     --   -- context.api:emit_to_yazi { 'cd', current_file }
  --     --   -- context.api:emit_to_yazi { "find", "--smart" }
  --     -- end, { buffer = yazi_buffer_id })
  --   end,
  --     -- hooks = {
  --     --   yazi_opened = function(preselected_path, yazi_buffer_id, config)
  --     --     -- you can optionally modify the config for this specific yazi
  --     --     -- invocation if you want to customize the behaviour
  --     --     local file = io.open('d:\\output.txt', 'a')
  --     --     file:write 'opend'
  --     --     file:close()
  --     --   end,
  --     --   on_yazi_ready = function(buffer, config, process_api)
  --     --     -- https://yazi-rs.github.io/docs/configuration/keymap/#manager.find
  --     --     local file = io.open('d:\\output.txt', 'a')
  --     --     file:write 'ready3'
  --     --     file:close()
  --     --     -- process_api:emit_to_yazi { 'cd d:', 'd:' }
  --     --   end,
  --     -- },
  -- },
  opts = function()
    local openedPath = '/'
    return {
      -- if you want to open yazi instead of netrw, see below for more info
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
          context.api:emit_to_yazi { 'cd', openedPath }
        end, { buffer = yazi_buffer_id })
      end,
      -- log_level = vim.log.levels.DEBUG,
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

          -- 获取当前文件的父级目录
          local function getParentDir(filepath)
            -- 统一替换路径分隔符为 '/'
            filepath = filepath:gsub('\\', '/')
            -- 去除末尾的 '/'（如果有）
            filepath = filepath:gsub('/+$', '')
            -- 提取父目录
            local parent = filepath:match '^(.*)/[^/]+$'
            return parent or '.' -- 若没有父目录，返回当前目录 "."
          end

          openedPath = getParentDir(preselected_path)
        end,
      },
    }
  end,
  -- 👇 if you use `open_for_directories=true`, this is recommended
  init = function()
    -- mark netrw as loaded so it's not loaded at all.
    --
    -- More details: https://github.com/mikavilpas/yazi.nvim/issues/802
    vim.g.loaded_netrwPlugin = 1
  end,
}
