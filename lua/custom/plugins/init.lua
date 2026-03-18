return {
  {
    'easymotion/vim-easymotion',
    config = function()
      vim.cmd [[
        let g:EasyMotion_keys = "hklyuiopnmqwertzxcvbasdgjf"
        let g:EasyMotion_use_upper = 1
        let g:EasyMotion_smartcase = 1
        let g:EasyMotion_use_smartsign_us = 1
      ]]
      -- 如果需要将下边配置复制到上边
      -- hi EasyMotionTarget ctermbg=yellow ctermfg=black
      -- hi EasyMotionShade ctermbg=yellow ctermfg=black
      -- hi EasyMotionTarget2First ctermbg=yellow ctermfg=black
      -- hi EasyMotionTarget2Second ctermbg=yellow ctermfg=black
      -- hi link EasyMotionTarget ErrorMsg
      -- hi link EasyMotionShade  Comment
      -- hi link EasyMotionTarget2First MatchParen
      -- hi link EasyMotionTarget2Second MatchParen
      -- hi link EasyMotionMoveHL Search
      -- hi link EasyMotionIncSearch Search
      --
      -- easymotion插件在退出跳转时会出现diagnosing提示，改了easymotion配置后，没有出现相关问题，暂时注释此处的代码
      vim.api.nvim_create_autocmd('User', {
        pattern = { 'EasyMotionPromptBegin' },
        callback = function()
          vim.diagnostic.enable(false)
          --vim.diagnostic.disable()
        end,
      })
      local function check_easymotion()
        local timer = vim.loop.new_timer()
        timer:start(
          500,
          0,
          vim.schedule_wrap(function()
            -- vim.notify("check_easymotion")
            if vim.fn['EasyMotion#is_active']() == 0 then
              vim.diagnostic.enable()
              vim.g.waiting_for_easy_motion = false
            else
              check_easymotion()
            end
          end)
        )
      end
      vim.api.nvim_create_autocmd('User', {
        pattern = 'EasyMotionPromptEnd',
        callback = function()
          if vim.g.waiting_for_easy_motion then return end
          vim.g.waiting_for_easy_motion = true
          check_easymotion()
        end,
      })
    end,
    keys = {
      {
        '<Leader>',
        '<Plug>(easymotion-prefix)',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>J',
        '<Plug>(easymotion-eol-j)',
        mode = { 'n', 'v' },
      },
      {
        '<Leader>K',
        '<Plug>(easymotion-eol-k)',
        mode = { 'n', 'v' },
      },
    },
  },
  {
    'inkarkat/vim-ReplaceWithRegister',
    config = function() vim.api.nvim_set_keymap('n', '<Leader>gr', '"+gr', { noremap = false, silent = true }) end,
  },
  {
    'machakann/vim-highlightedyank',
    config = function()
      vim.g.highlightedyank_highlight_duration = 600
      vim.api.nvim_command 'highlight HighlightedyankRegion cterm=reverse gui=reverse'
    end,
  },
  {
    'nanozuki/tabby.nvim',
    config = function()
      -- always display tabline
      --vim.o.showtabline = 2
      -- Save and restore in session
      --vim.opt.sessionoptions = 'curdir,folds,globals,help,tabpages,terminal,winsize'

      vim.api.nvim_create_user_command('SmartTabClose', function()
        -- local current_tab = vim.fn.tabpagenr() -- 当前标签页序号
        -- local total_tabs = vim.fn.tabpagenr '$' -- 总标签页数
        -- local function close()
        --   if total_tabs == 1 then
        --     vim.cmd 'q' -- 仅剩一个标签页时退出
        --   else
        --     vim.cmd 'tabclose' -- 否则关闭当前标签页
        --   end
        -- end

        local bufnr = vim.api.nvim_get_current_buf() -- 当前缓冲区 ID
        local buf_modified = vim.api.nvim_get_option_value('modified', { buf = bufnr }) -- 检查当前缓冲区是否修改
        if buf_modified then
          -- 弹窗提示用户选择
          local choice = vim.fn.confirm('文件未保存，是否保存？', '&Save\n&Discard\n&Cancel', 2)
          if choice == 1 then -- 用户选择 Save
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
              if filename ~= '' then vim.cmd('wq ' .. filename) end
            else
              vim.cmd 'wq'
            end
          elseif choice == 2 then -- 用户选择 Discard
            vim.cmd 'q!'
          end -- 选择 Cancel 则不操作

          -- vim.ui.select({ 'Save & Quit', 'Quit Without Save', 'Cancel' }, { prompt = '文件未保存，是否保存更改？' }, function(choice)
          --   if choice == 'Save & Quit' then
          --     vim.cmd 'wq' -- 保存并退出
          --   elseif choice == 'Quit Without Save' then
          --     vim.cmd 'q!' -- 强制退出不保存
          --   end
          --   -- 选择 Cancel 则不操作
          -- end)
        else
          vim.cmd 'q!'
        end
      end, { desc = '智能关闭标签页：仅剩一个时退出，否则关闭当前页' })

      vim.keymap.set({ 'n', 'i' }, '<A-t>', '<Cmd>tabnew<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-w>', '<Cmd>SmartTabClose<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-1>', '<Cmd>normal! 1gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-2>', '<Cmd>normal! 2gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-3>', '<Cmd>normal! 3gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-4>', '<Cmd>normal! 4gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-5>', '<Cmd>normal! 5gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-6>', '<Cmd>normal! 6gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-7>', '<Cmd>normal! 7gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-8>', '<Cmd>normal! 8gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-9>', '<Cmd>normal! 9gt<CR>', { noremap = true })
      vim.keymap.set({ 'n', 'i' }, '<A-0>', '<Cmd>normal! g<Tab><CR>', { noremap = true })

      require('tabby').setup {
        line = function(line)
          local theme = {
            fill = 'TabLineFill',
            -- Also you can do this: fill = { fg='#f2e9de', bg='#907aa9', style='italic' }
            head = 'TabLine',
            current_tab = 'TabLineSel',
            tab = 'TabLine',
            win = 'TabLine',
            tail = 'TabLine',
          }

          local function buf_modified(buf)
            if vim.bo[buf].modified then
              return '●'
            else
              return ''
            end
          end

          local function tab_modified(tab, tabId, hl)
            local wins = require('tabby.module.api').get_tab_wins(tabId)
            for _, x in pairs(wins) do
              if vim.bo[vim.api.nvim_win_get_buf(x)].modified then
                return {
                  line.sep('', hl, theme.fill),
                  '%' .. tab.number() .. 'T', -- 启用鼠标点击区域
                  -- tab.is_current() and ' ' or '󰆣 ',
                  '●',
                  --tab.number(),
                  tab.in_jump_mode() and tab.jump_key() or tab.number(),
                  tab.name(),
                  tab.close_btn '',
                  line.sep('', hl, theme.fill),
                  hl = hl,
                  margin = ' ',
                }
              end
            end
            return {
              line.sep('', hl, theme.fill),
              '%' .. tab.number() .. 'T', -- 启用鼠标点击区域
              --tab.is_current() and '' or '󰆣',
              --tab.number(),
              tab.in_jump_mode() and tab.jump_key() or tab.number(),
              tab.name(),
              tab.close_btn '',
              line.sep('', hl, theme.fill),
              hl = hl,
              margin = ' ',
            }
          end

          return {
            {
              { '  ', hl = theme.head },
              line.sep('', theme.head, theme.fill),
            },
            line.tabs().foreach(function(tab)
              local hl = tab.is_current() and theme.current_tab or theme.tab
              return {
                tab_modified(tab, tab.id, hl),
              }
            end),
            -- 最右侧不让显示当前标签激活的文件名
            -- line.spacer(),
            -- line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
            --   return {
            --     line.sep('', theme.win, theme.fill),
            --     --win.is_current() and '' or '',
            --     buf_modified(win.buf().id),
            --     win.buf_name(),
            --     line.sep('', theme.win, theme.fill),
            --     hl = theme.win,
            --     margin = ' ',
            --   }
            -- end),
            -- {
            --   line.sep('', theme.tail, theme.fill),
            --   { '  ', hl = theme.tail },
            -- },
            hl = theme.fill,
          }
        end,
        option = {
          buf_name = {
            mode = 'unique', -- or 'unique', 'relative', 'tail', 'shorten'
          },
        },
      }
    end,
  },
  -- 这个插件存在的唯一问题就是由于使用了projects.yazi插件，打开yazi的时候进入的不是当前文件目录，而加载的projects.yazi里的目录
  -- 目前重写了退出的快捷键，但是在新建标签页的时候，退出快捷键不起作用，还不知道是什么原因
  {
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

    --     --   local file = io.open('d:\\output.txt', 'w')
    --     --   file:write(path)
    --     --   file:write 'a'
    --     --   -- file:write(quote_content)
    --     --   -- file:write 'b'
    --     --   -- file:write(words[2])
    --     --   -- file:write 'c'
    --     --   -- for k, v in pairs(config) do
    --     --   --   file:write(k, ' ', type(v), ' ') -- 输出变量名和类型（避免打印过大的值）
    --     --   --   if type(v) == 'string' then
    --     --   --     file:write(v)
    --     --   --   end
    --     --   --   file:write '\n'
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
  },
  {
    -- 配置参考 https://www.lazyvim.org/plugins/ui#noicenvim
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      views = {
        -- 定义reg命令展示的视图.下边的routes路由去查找展示的命令结果来指定当前这个视图
        -- registers = {
        --   backend = 'split',
        --   -- 弹出窗口自动关闭时间
        --   timeout = 10000,
        --   win_options = {
        --     -- 弹出窗口的透明度0表示不透明
        --     winblend = 0,
        --   },
        --   enter = true, -- 自动将光标跳转到分栏中，方便翻页和搜索
        --   close = {
        --     keys = { 'q', '<Esc>' },
        --   },
        -- },
        -- split = {
        --   enter = true, -- 自动将光标跳转到分栏中，方便翻页和搜索
        -- },
        mini = {
          -- 弹出窗口自动关闭时间
          timeout = 5000,
        },
        split = {
          enter = true, -- 执行完命令后光标自动跳进 split 窗口，方便翻页和退出
          size = 20, -- 设置高度为 20 行（默认通常较小）
        },
      },
      lsp = {
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true,
        },
      },
      routes = {
        -- 捕获绝大多数命令的输出
        {
          filter = {
            event = 'msg_show',
            -- 排除掉没有内容的空消息
            -- 并且确保它不是 mini 类型的小提示
            any = {
              -- { kind = '' }, -- 绝大多数 :命令 的输出 kind 为空字符串
              -- { kind = 'echo' }, -- 使用 :echo 输出的内容
              -- { kind = 'echomsg' }, -- 使用 :echomsg 输出的内容
              { kind = 'list_cmd' }, -- 使用 :list_cmd 输出的内容
              { find = 'mark line  col file/text' }, -- 匹配 :marks 输出的表头
            },
          },
          view = 'split', -- 统一使用分栏视图
          -- opts = {
          --   enter = true, -- 执行完命令后光标自动跳进 split 窗口，方便翻页和退出
          --   size = 20, -- 设置高度为 20 行（默认通常较小）
          -- },
        },
        -- {
        --   filter = {
        --     event = 'msg_show',
        -- any = {
        --   -- 保存操作时的提示
        --   { find = '%d+L, %d+B' },
        --   -- 撤销修改时的提示
        --   { find = '; before #%d+' },
        --   -- 恢复操作时的提示
        --   { find = '; after #%d+' },
        --   -- 复制文件时的提示
        --   { find = 'lines yanked into' },
        --   { find = 'fewer lines' },
        --   { find = 'more lines' },
        --   { find = 'lines yanked' },
        --   -- easymotion
        --   { find = 'Target key' },
        --   { find = 'EasyMotion' },
        -- },
        --   },
        --   view = 'mini',
        -- },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
      },
    },
    -- stylua: ignore
    keys = {
      { "<leader>sn", "", desc = "+noice"},
      { "<S-Enter>", function() require("noice").redirect(vim.fn.getcmdline()) end, mode = "c", desc = "Redirect Cmdline" },
      { "<leader>snl", function() require("noice").cmd("last") end, desc = "Noice Last Message" },
      { "<leader>snh", function() require("noice").cmd("history") end, desc = "Noice History" },
      { "<leader>sna", function() require("noice").cmd("all") end, desc = "Noice All" },
      { "<leader>snd", function() require("noice").cmd("dismiss") end, desc = "Dismiss All" },
      { "<leader>snt", function() require("noice").cmd("pick") end, desc = "Noice Picker (Telescope/FzfLua)" },
      { "<c-f>", function() if not require("noice.lsp").scroll(4) then return "<c-f>" end end, silent = true, expr = true, desc = "Scroll Forward", mode = {"i", "n", "s"} },
      { "<c-b>", function() if not require("noice.lsp").scroll(-4) then return "<c-b>" end end, silent = true, expr = true, desc = "Scroll Backward", mode = {"i", "n", "s"}},
    },
    config = function(_, opts)
      -- HACK: noice shows messages from before it was enabled,
      -- but this is not ideal when Lazy is installing plugins,
      -- so clear the messages in this case.
      if vim.o.filetype == 'lazy' then vim.cmd [[messages clear]] end
      require('noice').setup(opts)
    end,
  },
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = false, -- 将接受快捷键改为 Tab
          accept_word = '<M-l>', -- alt + l 接受单词
          accept_line = '<M-j>',
          next = '<M-]>',
          prev = '<M-[>',
          dismiss = '<C-]>',
        },
      },
      panel = {
        enabled = true,
      },
    },
    config = function(_, opts)
      require('copilot').setup(opts)

      -- 自定义 Tab 逻辑
      vim.keymap.set('i', '<Tab>', function()
        local suggestion = require 'copilot.suggestion'
        if suggestion.is_visible() then
          suggestion.accept()
        else
          -- 如果没有提示，则输出正常的 Tab 字符
          -- feedkeys 的参数解释：t 表示按键名解析，n 表示不再次触发映射
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
        end
      end, { desc = 'Copilot Tab Accept' })

      -- 设置代码提示的文字颜色
      vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
        fg = '#458588', -- 这里填入你选定的颜色
        ctermfg = 8, -- 兼容 256 色终端
        italic = true, -- 开启斜体，能更明显地将其与正式代码区分开
      })
    end,
  },
  -- {
  --   -- neovide 对ime输入法支持(2026.03.18 试用后支持不好，暂时注释掉)
  --   'sevenc-nanashi/neov-ime.nvim',
  -- },
}
