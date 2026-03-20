-- copilot.lua - GitHub Copilot AI 代码补全
-- 快捷键：
--   Tab          接受建议
--   <M-l>        接受单词
--   <M-j>        接受行
--   <M-]>        下一条建议
--   <M-[>        上一条建议
--   <C-]>        关闭建议

return {
  'zbirenbaum/copilot.lua',
  cmd = 'Copilot',
  event = 'InsertEnter',
  opts = {
    suggestion = {
      auto_trigger = true,
      keymap = {
        accept = false, -- 将接受快捷键改为 Tab
        accept_word = '<M-l>', -- alt + l 接受单词
        accept_line = '<M-j>',
        next = '<M-]>',
        prev = '<M-[>',
        dismiss = '<C-]>',
      },
    },
    panel = {
      enabled = true,
    },
  },
  config = function(_, opts)
    require('copilot').setup(opts)

    -- 自定义 Tab 逻辑
    vim.keymap.set('i', '<Tab>', function()
      local suggestion = require 'copilot.suggestion'
      if suggestion.is_visible() then
        suggestion.accept()
      else
        -- 如果没有提示，则输出正常的 Tab 字符
        -- feedkeys 的参数解释：t 表示按键名解析，n 表示不再次触发映射
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Tab>', true, false, true), 'n', false)
      end
    end, { desc = 'Copilot Tab Accept' })

    -- 设置代码提示的文字颜色
    vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
      fg = '#458588', -- 这里填入你选定的颜色
      ctermfg = 8, -- 兼容 256 色终端
      italic = true, -- 开启斜体，能更明显地将其与正式代码区分开
    })
  end,
}
