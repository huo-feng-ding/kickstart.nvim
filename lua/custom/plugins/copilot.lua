
-- =====================================================================
-- zbirenbaum/copilot.lua 的 vim.pack 懒加载配置
-- =====================================================================

-- 创建一个专门的自动命令组，防止重复注册
local copilot_group = vim.api.nvim_create_augroup("LazyLoadCopilot", { clear = true })

-- 定义一个核心激活函数，确保只加载一次
local copilot_loaded = false
local function load_copilot()
  if copilot_loaded then return end
  
  -- 1. 使用原生 packadd 加载 opt 目录下的插件
  -- pcall(vim.cmd, "packadd copilot.lua")
  vim.pack.add { 'https://github.com/zbirenbaum/copilot.lua' }
  
  -- 2. 执行原 Packer 中的 config 函数（进行 setup 初始化）
  -- 记得根据上文所述，如果你配合 blink.cmp 使用，需要禁用默认的 suggestion
  require("copilot").setup({
    -- 禁用默认的 suggestion 和 panel，使用 blink.cmp 来显示建议
    suggestion = { enabled = false },
    panel = { enabled = false },
  })
  
  copilot_loaded = true
end

-- 映射 Packer 中的 event = "InsertEnter"
vim.api.nvim_create_autocmd("InsertEnter", {
  group = copilot_group,
  callback = function()
    load_copilot()
  end,
})

-- 映射 Packer 中的 cmd = "Copilot"
-- 在插件未加载前，先创建一个同名的用户命令，用户输入该命令时触发加载
vim.api.nvim_create_user_command("Copilot", function(opts)
  -- 激活插件
  load_copilot()
  -- 激活后，原插件的 :Copilot 命令会覆盖此处的临时命令
  -- 重新执行用户刚才输入的指令（带上参数，如 :Copilot auth 等）
  vim.cmd("Copilot " .. opts.args)
end, { nargs = "*" })

