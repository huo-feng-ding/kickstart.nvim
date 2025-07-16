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
          if vim.g.waiting_for_easy_motion then
            return
          end
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
    config = function()
      vim.api.nvim_set_keymap('n', '<Leader>gr', '"+gr', { noremap = false, silent = true })
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
              if filename ~= '' then
                vim.cmd('wq ' .. filename)
              end
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

      vim.api.nvim_set_keymap('n', '<A-t>', ':$tabnew<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-w>', ':SmartTabClose<CR>', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-1>', '1gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-2>', '2gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-3>', '3gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-4>', '4gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-5>', '5gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-6>', '6gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-7>', '7gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-8>', '8gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-9>', '9gt', { noremap = true })
      vim.api.nvim_set_keymap('n', '<A-0>', 'g<Tab>', { noremap = true })

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
            line.spacer(),
            line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
              return {
                line.sep('', theme.win, theme.fill),
                --win.is_current() and '' or '',
                buf_modified(win.buf().id),
                win.buf_name(),
                line.sep('', theme.win, theme.fill),
                hl = theme.win,
                margin = ' ',
              }
            end),
            {
              line.sep('', theme.tail, theme.fill),
              { '  ', hl = theme.tail },
            },
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
  {
    'machakann/vim-highlightedyank',
    config = function()
      vim.g.highlightedyank_highlight_duration = 600
      vim.api.nvim_command 'highlight HighlightedyankRegion cterm=reverse gui=reverse'
    end,
  },
  {
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      views = {
        -- 定义reg命令展示的视图.下边的routes路由去查找展示的命令结果来指定当前这个视图
        registers = {
          backend = 'split',
          -- 弹出窗口自动关闭时间
          timeout = 10000,
          win_options = {
            -- 弹出窗口的透明度0表示不透明
            winblend = 0,
          },
          close = {
            keys = { 'q', '<Esc>' },
          },
        },
        mini = {
          -- 弹出窗口自动关闭时间
          timeout = 5000,
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
        {
          filter = {
            event = 'msg_show',
            any = {
              -- 保存操作时的提示
              { find = '%d+L, %d+B' },
              -- 撤销修改时的提示
              { find = '; before #%d+' },
              -- 恢复操作时的提示
              { find = '; after #%d+' },
            },
          },
          view = 'mini',
        },
        {
          filter = {
            event = 'msg_show',
            any = {
              { find = 'Type Name Content' },
            },
          },
          view = 'registers',
        },
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
      if vim.o.filetype == 'lazy' then
        vim.cmd [[messages clear]]
      end
      require('noice').setup(opts)
    end,
  },
}
