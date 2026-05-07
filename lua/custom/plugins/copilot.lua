-- copilot.lua - GitHub Copilot AI 代码补全
-- 快捷键：
--   Tab          接受建议
--   <M-l>        接受单词
--   <M-j>        接受行
--   <M-]>        下一条建议
--   <M-[>        上一条建议
--   <C-]>        关闭建议

vim.pack.add { 'https://github.com/zbirenbaum/copilot.lua' }

-- 1. 定义配置参数
local opts = {
    suggestion = {
        enabled = true,
        auto_trigger = true,
        keymap = {
            accept = false, -- 禁用默认，由下方自定义 Tab 处理
            accept_word = "<M-l>",  -- alt + l 接受单词
            accept_line = "<M-j>",
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
        },
    },
    panel = {
        enabled = true,
    },
}

-- 2. 执行初始化
-- 注意：原生模式下建议放在 InsertEnter 自动命令中以保持性能，
-- 也可以直接 require('copilot').setup(opts)
vim.api.nvim_create_autocmd("InsertEnter", {
    callback = function()
        require("copilot").setup(opts)
        
        -- 设置代码提示的文字颜色 (通常只需设置一次)
        vim.api.nvim_set_hl(0, "CopilotSuggestion", {
          fg = '#458588', -- 这里填入你选定的颜色
          ctermfg = 8, -- 兼容 256 色终端
          italic = true, -- 开启斜体，能更明显地将其与正式代码区分开
        })
    end,
    once = true, -- 只在第一次进入插入模式时执行
})

-- 3. 自定义 Tab 逻辑
-- 映射建议直接定义，逻辑内部会判断 copilot 是否已加载
vim.keymap.set("i", "<Tab>", function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and suggestion.is_visible() then
        suggestion.accept()
    else
        -- 如果没有提示，则输出正常的 Tab 字符
        -- feedkeys 的参数解释：t 表示按键名解析，n 表示不再次触发映射
        local br = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
        vim.api.nvim_feedkeys(br, "n", false)
    end
end, { desc = "Copilot Tab Accept" })

