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
    'romgrk/barbar.nvim',
    dependencies = {
      'lewis6991/gitsigns.nvim', -- OPTIONAL: for git status
      'nvim-tree/nvim-web-devicons', -- OPTIONAL: for file icons
    },
    init = function()
      vim.g.barbar_auto_setup = false

      local map = vim.api.nvim_set_keymap
      local opts = { noremap = true, silent = true }

      -- Move to previous/next
      map('n', '<A-,>', '<Cmd>BufferPrevious<CR>', opts)
      map('n', '<A-.>', '<Cmd>BufferNext<CR>', opts)

      -- Re-order to previous/next
      map('n', '<A-<>', '<Cmd>BufferMovePrevious<CR>', opts)
      map('n', '<A->>', '<Cmd>BufferMoveNext<CR>', opts)

      -- Goto buffer in position...
      map('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
      map('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
      map('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
      map('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
      map('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
      map('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
      map('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
      map('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
      map('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
      map('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)

      -- Pin/unpin buffer
      map('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)

      -- Goto pinned/unpinned buffer
      --                 :BufferGotoPinned
      --                 :BufferGotoUnpinned

      -- Close buffer
      map('n', '<A-w>', '<Cmd>BufferClose<CR>', opts)

      -- Wipeout buffer
      --                 :BufferWipeout

      -- Close commands
      --                 :BufferCloseAllButCurrent
      --                 :BufferCloseAllButPinned
      --                 :BufferCloseAllButCurrentOrPinned
      --                 :BufferCloseBuffersLeft
      --                 :BufferCloseBuffersRight

      -- Magic buffer-picking mode
      map('n', '<C-p>', '<Cmd>BufferPick<CR>', opts)
      map('n', '<C-s-p>', '<Cmd>BufferPickDelete<CR>', opts)

      -- Sort automatically by...
      map('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
      map('n', '<Space>bn', '<Cmd>BufferOrderByName<CR>', opts)
      map('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
      map('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
      map('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

      -- Other:
      -- :BarbarEnable - enables barbar (enabled by default)
      -- :BarbarDisable - very bad command, should never be used

      map('n', '<A-t>', '<Cmd>tabnew<CR>', opts)

      -- 多标签页的情况下，修改了一个标签页下的内容按ZZ保存并退出需要按两次，这里做处理只需要按一次
      vim.api.nvim_create_autocmd('WinClosed', {
        callback = function(tbl)
          if vim.api.nvim_buf_is_valid(tbl.buf) then
            vim.api.nvim_buf_delete(tbl.buf, {})
          end
        end,
        group = vim.api.nvim_create_augroup('barbar_close_buf', {}),
      })
    end,
    opts = {
      -- lazy.nvim will automatically call setup for you. put your options here, anything missing will use the default:
      -- animation = true,
      -- insert_at_start = true,
      -- …etc.
      -- Enable/disable current/total tabpages indicator (top right corner)
      tabpages = true,

      -- Enables/disable clickable tabs
      --  - left-click: go to buffer
      --  - middle-click: delete buffer
      clickable = true,
      -- Enable highlighting visible buffers
      highlight_visible = true,
      icons = {
        -- Configure the base icons on the bufferline.
        -- Valid options to display the buffer index and -number are `true`, 'superscript' and 'subscript'
        buffer_index = true,
        buffer_number = false,
      },
    },
    version = '^1.0.0', -- optional: only update when a new 1.x version is released
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
