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

vim.pack.add { 'https://github.com/folke/noice.nvim' }

-- ── 1. 定义配置参数 (对应原 opts) ──────────────────────────────────
local opts = {
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
            enter = true,
            size = 20,
        },
    },
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    routes = {
      -- 捕获绝大多数命令的输出
        {
            filter = {
                event = "msg_show",
          -- 👇 新增：排除掉包含 "more lines" 的消息,这里的功能和上边配的规则效果一样
          -- 注意：因为 not 是 Lua 的关键字，作为 key 时建议加上引号和中括号
                ["not"] = {
      -- Neovim 内部有一个参数叫做 report。它的作用是设定一个阈值：当一行命令影响的行数超过这个阈值时，Neovim 就会在状态栏显示提示信息。
      -- 默认值： 通常是 2。
      -- 逻辑： * 如果你粘贴了 2 行 或更少，Neovim 觉得这只是小操作，保持安静。
      -- 如果你粘贴了 3 行 或更多，超过了默认的阈值，它就会跳出提示：3 more lines。
                    any = {
                        { find = "%d+ more lines" },
                        { find = "%d+ fewer lines" },
                        { find = "%d+ lines yanked" },
                        { find = "%d+ lines >ed %d+ time" },
                    },
                },
          -- 排除掉没有内容的空消息
          -- 并且确保它不是 mini 类型的小提示
                any = {
                    { kind = "list_cmd" },
                    { find = "mark line  col file/text" },
                },
            },
            view = "split",
        },
    },
    presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
    },
}

-- ── 2. 执行初始化 (对应原 config) ──────────────────────────────────
-- 如果当前是在 lazy 界面（虽然你改用了原生，但如果是手动触发加载可保留此逻辑）
if vim.o.filetype == "lazy" then
    vim.cmd([[messages clear]])
end

require("noice").setup(opts)

-- ── 3. 快捷键映射 (对应原 keys) ──────────────────────────────────
local map = vim.keymap.set

-- 命令行重定向
map("c", "<S-Enter>", function()
    require("noice").redirect(vim.fn.getcmdline())
end, { desc = "Redirect Cmdline" })

-- 信息查询与管理
map("n", "<leader>snl", function() require("noice").cmd("last") end, { desc = "Noice Last Message" })
map("n", "<leader>snh", function() require("noice").cmd("history") end, { desc = "Noice History" })
map("n", "<leader>sna", function() require("noice").cmd("all") end, { desc = "Noice All" })
map("n", "<leader>snd", function() require("noice").cmd("dismiss") end, { desc = "Dismiss All" })
map("n", "<leader>snt", function() require("noice").cmd("pick") end, { desc = "Noice Picker" })

-- 悬浮窗滚动 (LSP/Noice)
local scroll_func = function(delta)
    return function()
        if not require("noice.lsp").scroll(delta) then
            return delta > 0 and "<c-f>" or "<c-b>"
        end
    end
end

map({ "i", "n", "s" }, "<c-f>", scroll_func(4), { silent = true, expr = true, desc = "Scroll Forward" })
map({ "i", "n", "s" }, "<c-b>", scroll_func(-4), { silent = true, expr = true, desc = "Scroll Backward" })

