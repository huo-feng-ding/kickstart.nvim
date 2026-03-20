-- tabby.nvim - 标签页美化
-- 快捷键：
--   <A-t>      新建标签页
--   <A-w>      智能关闭标签页
--   <A-1~9>    切换到第 1~9 个标签页
--   <A-0>      切换到上一个标签页

return {
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
}
