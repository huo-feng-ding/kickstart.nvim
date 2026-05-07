-- 自定义插件配置入口
-- lazy.nvim 会自动加载此目录下所有 plugins_*.lua 文件
-- 每个插件独立管理，方便维护
--
-- 插件列表：
--   plugins_easymotion.lua        - 快速跳转
--   plugins_replace_with_register.lua - 寄存器替换
--   plugins_highlightedyank.lua   - 复制高亮
--   plugins_tabby.lua             - 标签页美化
--   plugins_yazi.lua              - 文件管理器
--   plugins_noice.lua             - 命令行美化
--   plugins_copilot.lua           - AI 代码补全
--   plugins_codecompanion.lua     - AI 编程助手

-- Iterate over all Lua files in the plugins directory and load them
local plugins_dir = vim.fs.joinpath(vim.fn.stdpath 'config', 'lua', 'custom', 'plugins')
for file_name, type in vim.fs.dir(plugins_dir) do
  if type == 'file' and file_name:match '%.lua$' and file_name ~= 'init.lua' then
    local module = file_name:gsub('%.lua$', '')
    require('custom.plugins.' .. module)
  end
end
