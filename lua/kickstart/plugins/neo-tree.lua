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
    { '\\', ':Neotree position=current dir=%:p:h:h reveal_file=%:p<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
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
          -- 重写o快捷键，新标签页打开当前文件
          ['o'] = 'open_tabnew',
          --重写t快捷键，t进行排序
          ['t'] = {
            'show_help',
            nowait = false,
            config = { title = 'Order by', prefix_key = 'o' },
          },
        },
      },
    },
  },
}
