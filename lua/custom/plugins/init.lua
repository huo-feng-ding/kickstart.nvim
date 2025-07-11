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
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons', -- 可选，用于图标支持
    },
    config = function()
      -- 配置 nvim-tree
      require('nvim-tree').setup {
        -- 自定义配置选项
        sort_by = 'case_sensitive',
        view = {
          width = 30,
          side = 'left',
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          dotfiles = true,
        },
        update_focused_file = {
          enable = true,
          update_root = true,
          update_cwd = true,
        },
      }

      -- 键映射
      vim.keymap.set('n', '<leader>E', ':NvimTreeToggle %:p:h<CR>', { noremap = true, silent = true })
      vim.keymap.set('n', '<leader>o', ':NvimTreeFindFileToggle<CR>', { noremap = true, silent = true })
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
          timeout = 10000, -- 弹出窗口自动关闭时间
          win_options = {
            winblend = 0, -- 弹出窗口的透明度0表示不透明
          },
          close = {
            keys = { 'q', '<Esc>' },
          },
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
              { find = '%d+L, %d+B' },
              { find = '; after #%d+' },
              { find = '; before #%d+' },
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
