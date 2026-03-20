-- CodeCompanion.nvim - AI 编程助手
-- 文档: https://codecompanion.olimorris.dev
-- 使用 GitHub Copilot 作为 AI 后端（复用已有的 copilot.lua 认证）
--
-- 快捷键速查：
--   <leader>ai  打开/关闭聊天窗口 (toggle)
--   <leader>aa  打开动作菜单（内置提示词库）
--   <leader>ac  新建聊天
--   <leader>as  把选中代码加入聊天（visual 模式）
--   <leader>ae  内联编辑（inline，在当前光标位置直接修改代码）
--
-- 聊天窗口内快捷键（内置）：
--   <CR> 或 <C-s>   发送消息
--   q               取消当前请求
--   gx              清空聊天记录
--   ga              切换 adapter/模型

return {
  {
    'olimorris/codecompanion.nvim',
    version = '*', -- 使用最新版本
    -- 懒加载：使用命令或快捷键时才加载
    cmd = {
      'CodeCompanion',
      'CodeCompanionChat',
      'CodeCompanionActions',
    },
    keys = {
      { '<leader>ai', mode = { 'n', 'v' }, desc = 'AI: Toggle Chat' },
      { '<leader>aa', mode = { 'n', 'v' }, desc = 'AI: Actions' },
      { '<leader>ac', mode = { 'n' }, desc = 'AI: New Chat' },
      { '<leader>as', mode = { 'v' }, desc = 'AI: Add to Chat' },
      { '<leader>ae', mode = { 'n', 'v' }, desc = 'AI: Inline Edit' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-treesitter/nvim-treesitter',
      -- render-markdown：聊天窗口内渲染 Markdown（可选但强烈推荐）
      {
        'MeanderingProgrammer/render-markdown.nvim',
        ft = { 'markdown', 'codecompanion' },
        opts = {},
      },
    },
    config = function()
      require('codecompanion').setup {
        -- ── Adapter 配置 ──────────────────────────────────────────────────
        -- 使用 GitHub Copilot，不需要额外的 API Key（复用 copilot.lua 的认证）
        adapters = {
          http = {
            copilot = function()
              return require('codecompanion.adapters').extend('copilot', {
                schema = {
                  model = {
                    -- 可选模型（在聊天窗口内按 ga 切换）：
                    --   gpt-4o, gpt-4.1, claude-sonnet-4-5, gemini-2.0-flash-001
                    -- default = 'gpt-4o',
                  },
                },
              })
            end,
            zhipuai = function()
              local api_key2 = os.getenv 'ZHIPU_API_KEY'
              return require('codecompanion.adapters').extend('openai', {
                url = 'https://open.bigmodel.cn/api/paas/v4/chat/completions',
                -- env = { api_key = 'a7225fffe5f54c079e2d51d792d7dcc6.WDJKjddsL6xIeTB6' },
                env = { api_key = api_key2 },
                -- env = { api_key = 'env:ZHIPU_API_KEY' },
                -- env = { api_key = 'vim.env.ZHIPU_API_KEY' },
                -- 覆盖参数
                schema = {
                  model = {
                    default = 'glm-4.7-flash', -- 智谱最新的旗舰模型
                    -- choices = { 'glm-4', 'glm-4-flash', 'glm-3-turbo' },
                  },
                  temperature = {
                    default = 0.7,
                  },
                },
              })
            end,
          },
          acp = {
            -- 使用 Gemini_cli
            gemini_cli = function()
              return require('codecompanion.adapters').extend('gemini_cli', {
                defaults = {
                  auth_method = 'oauth-personal', -- "oauth-personal"|"gemini-api-key"|"vertex-ai"
                },
                -- 增加这一段来强制检查命令路径, 试了 gemini 和 gemini-cli 都可以没影响; 可能有时候打开gemini时比较慢，会报 response timeout
                -- cmd = 'gemini-cli',
                cmd = 'gemini',
                -- env = {
                --   GEMINI_API_KEY = 'cmd:op read op://personal/Gemini_API/credential --no-newline',
                -- },
                -- 添加超时时间
                env = {
                  GEMINI_TIMEOUT = 120000, -- 120秒超时
                },
              })
            end,
          },
        },

        -- ── 策略：指定各场景使用哪个 adapter ────────────────────────────
        strategies = {
          chat = {
            -- adapter = 'copilot',
            adapter = 'zhipuai',
            mode = 'edit',

            -- 聊天窗口的键位映射（窗口内生效）
            keymaps = {
              send = {
                modes = { n = '<CR>', i = '<C-s>' },
              },
              close = {
                modes = { n = 'Q' },
              },
              stop = {
                modes = { n = 'q' },
              },
              clear = {
                modes = { n = 'gx' },
              },
              change_adapter = {
                modes = { n = 'ga' },
              },
            },
          },
          inline = {
            -- adapter = 'copilot',
            adapter = 'zhipuai',
          },
          agent = {
            -- adapter = 'copilot',
            adapter = 'zhipuai',
          },
        },

        -- ── 全局选项 ────────────────────────────────────────────────────
        opts = {
          -- AI 默认用中文回答
          language = 'Chinese',
          -- 日志级别（调试时可改为 'DEBUG'）
          log_level = 'ERROR',
          -- 在状态栏显示进度（需要 mini.statusline 或 lualine）
          send_code = true,
        },

        -- ── 界面外观 ────────────────────────────────────────────────────
        display = {
          chat = {
            -- 聊天窗口显示在右侧
            window = {
              layout = 'vertical', -- 'vertical' | 'horizontal' | 'float' | 'buffer'
              width = 0.35, -- 占屏幕宽度的 35%
            },
            -- 显示代码引用（把文件/代码加入上下文时显示）
            show_references = true,
            -- 显示标题
            show_header_separator = false,
          },
          action_palette = {
            -- 动作菜单使用 telescope（已安装）
            provider = 'telescope',
          },
          inline = {
            -- 内联差异的显示方式：'vertical' | 'horizontal' | 'buffer'
            diff = {
              enabled = true,
              layout = 'vertical',
            },
          },
        },
      }

      -- ── 快捷键映射 ──────────────────────────────────────────────────────
      local map = vim.keymap.set

      -- 打开/关闭聊天窗口
      map({ 'n', 'v' }, '<leader>ai', '<cmd>CodeCompanionChat Toggle<CR>', { desc = 'AI: Toggle Chat' })

      -- 打开动作菜单（提示词库、快速操作）
      map({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<CR>', { desc = 'AI: Actions' })

      -- 新建一个聊天
      map('n', '<leader>ac', '<cmd>CodeCompanionChat<CR>', { desc = 'AI: New Chat' })

      -- 把选中内容添加到聊天窗口（Visual 模式）
      map('v', '<leader>as', '<cmd>CodeCompanionChat Add<CR>', { desc = 'AI: Add to Chat' })

      -- 内联编辑：直接在光标位置让 AI 修改代码
      map({ 'n', 'v' }, '<leader>ae', '<cmd>CodeCompanion<CR>', { desc = 'AI: Inline Edit' })

      -- ── fidget.nvim 状态提示（已安装 fidget，自动生效）────────────────
      local ok_fidget, fidget = pcall(require, 'fidget')
      if ok_fidget then
        local spinner_handle = nil
        vim.api.nvim_create_autocmd('User', {
          pattern = 'CodeCompanionRequest*',
          group = vim.api.nvim_create_augroup('codecompanion_fidget', { clear = true }),
          callback = function(event)
            if event.match == 'CodeCompanionRequestStarted' then
              spinner_handle = fidget.notify('AI thinking...', vim.log.levels.INFO, {
                annote = 'CodeCompanion',
                ttl = 60,
              })
            elseif event.match == 'CodeCompanionRequestFinished' then
              if spinner_handle then
                fidget.notify(nil, nil, { handle = spinner_handle })
                spinner_handle = nil
              end
            end
          end,
        })
      end
    end,
  },
}
