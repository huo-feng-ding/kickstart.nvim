-- vim-easymotion - 快速跳转插件
-- 快捷键：
--   <Leader><Leader>  easymotion 前缀
--   <Leader>J         跳转到行尾（向下）
--   <Leader>K         跳转到行尾（向上）

vim.pack.add { 'https://github.com/easymotion/vim-easymotion' }

-- ── 1. 全局配置 (Vimscript 变量) ───────────────────────────────────
-- 建议在 setup 逻辑之前设置，确保插件加载时能读取到
vim.g.EasyMotion_keys = "hklyuiopnmqwertzxcvbasdgjf"
vim.g.EasyMotion_use_upper = 1
vim.g.EasyMotion_smartcase = 1
vim.g.EasyMotion_use_smartsign_us = 1

-- 如果你需要取消注释的高亮配置，可以直接写在这里
-- vim.cmd([[
--   hi link EasyMotionTarget ErrorMsg
--   hi link EasyMotionShade  Comment
--   hi link EasyMotionTarget2First MatchParen
--   hi link EasyMotionTarget2Second MatchParen
-- ]])

-- ── 2. 解决跳转时 Diagnostic 提示闪烁的逻辑 ────────────────────────
local function check_easymotion()
    local timer = vim.loop.new_timer()
    timer:start(
        500,
        0,
        vim.schedule_wrap(function()
            -- 检查 EasyMotion 是否还在运行
            if vim.fn["EasyMotion#is_active"]() == 0 then
                vim.diagnostic.enable()
                vim.g.waiting_for_easy_motion = false
            else
                check_easymotion() -- 递归检查
            end
        end)
    )
end

-- 开始搜索时禁用诊断
vim.api.nvim_create_autocmd("User", {
    pattern = "EasyMotionPromptBegin",
    callback = function()
        vim.diagnostic.enable(false)
    end,
})

-- 搜索结束时启动定时检查并恢复诊断
vim.api.nvim_create_autocmd("User", {
    pattern = "EasyMotionPromptEnd",
    callback = function()
        if vim.g.waiting_for_easy_motion then
            return
        end
        vim.g.waiting_for_easy_motion = true
        check_easymotion()
    end,
})

-- ── 3. 快捷键映射 ──────────────────────────────────────────────────
local map = vim.keymap.set

-- 对应原来的 keys 列表
map({ "n", "v" }, "<Leader>", "<Plug>(easymotion-prefix)", { desc = "EasyMotion Prefix" })
map({ "n", "v" }, "<Leader>J", "<Plug>(easymotion-eol-j)", { desc = "EasyMotion EOL Down" })
map({ "n", "v" }, "<Leader>K", "<Plug>(easymotion-eol-k)", { desc = "EasyMotion EOL Up" })

