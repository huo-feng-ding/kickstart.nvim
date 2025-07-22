-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
  },
  lazy = false,
  keys = {
    -- { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
    -- { '\\', ':Neotree position=current dir=%:p:h:h reveal_file=%:p<CR>', desc = 'NeoTree reveal', silent = true },
    {
      '\\',
      function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname == '' or bufname:match '^term://' then
          -- 空缓冲区或终端缓冲区
          if vim.fn.has 'win32' == 1 then
            vim.cmd 'Neotree position=current dir=d:/'
          else
            vim.cmd 'Neotree position=current dir=/opt'
          end
        else
          vim.cmd 'Neotree position=current dir=%:p:h:h reveal_file=%:p'
        end
      end,
      desc = 'NeoTree reveal',
      silent = true,
    },
  },
  opts = {
    window = {
      position = 'float',
    },
    default_component_configs = {
      last_modified = {
        enabled = true,
        width = 20, -- width of the column
        required_width = 88, -- min width of window required to show this column
        format = '%Y-%m-%d %H:%M:%S', -- format string for timestamp (see `:h os.date()`)
        -- or use a function that takes in the date in seconds and returns a string to display
        --format = require("neo-tree.utils").relative_date, -- enable relative timestamps
      },
    },
    filesystem = {
      filtered_items = {
        -- 是否隐藏以.开头的文件
        hide_dotfiles = false,
        -- 是否隐藏文件
        hide_hidden = false,
        -- 是否隐藏gitignore文件
        hide_gitignored = false,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['<A-x>'] = 'clear_filter',
          -- 重写o快捷键，新标签页打开当前文件
          ['o'] = 'open_tabnew',
          ['l'] = 'open_tabnew',
          ['<CR>'] = 'open_tabnew',
          ['h'] = 'navigate_up',
          --重写t快捷键，t进行排序
          ['t'] = {
            'show_help',
            nowait = false,
            config = { title = 'Order by', prefix_key = 'o' },
          },
        },
        fuzzy_finder_mappings = {
          ['<CR>'] = 'close_keep_filter',
        },
      },
    },
    event_handlers = {
      {
        -- 相关代码参考于 https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#events
        event = 'file_open_requested',
        handler = function()
          -- auto close
          -- vim.cmd("Neotree close")
          -- OR
          require('neo-tree.command').execute { action = 'close' }
        end,
      },
    },
    commands = {
      open_and_close = function(state)
        -- 相关代码参考于 https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes#open-and-clear-search
        local node = state.tree:get_node()
        if node and node.type == 'file' then
          local file_path = node:get_id()
          -- reuse built-in commands to open and clear filter
          local cmds = require 'neo-tree.sources.filesystem.commands'
          cmds.open_tabnew(state)
          vim.cmd 'Neotree close'
          -- reveal the selected file without focusing the tree
          -- require('neo-tree.sources.filesystem').navigate(state, state.path, file_path)
        end
      end,
    },
  },
}
