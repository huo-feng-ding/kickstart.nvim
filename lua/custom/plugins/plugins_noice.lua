-- noice.nvim - 命令行/消息 UI 美化
-- 配置参考: https://www.lazyvim.org/plugins/ui#noicenvim
-- 快捷键：
--   <S-Enter>     重定向命令行
--   <Leader>snl   显示最后一条消息
--   <Leader>snh   显示消息历史
--   <Leader>sna   显示所有消息
--   <Leader>snd   关闭所有消息
--   <Leader>snt   选择消息
--   <C-f>         向前滚动
--   <C-b>         向后滚动

return {
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
}
