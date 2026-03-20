-- vim-easymotion - 快速跳转插件
-- 快捷键：
--   <Leader><Leader>  easymotion 前缀
--   <Leader>J         跳转到行尾（向下）
--   <Leader>K         跳转到行尾（向上）

return {
  'easymotion/vim-easymotion',
  config = function()
    vim.cmd [[
      let g:EasyMotion_keys = "hklyuiopnmqwertzxcvbasdgjf"
      let g:EasyMotion_use_upper = 1
      let g:EasyMotion_smartcase = 1
      let g:EasyMotion_use_smartsign_us = 1
    ]]
    -- 如果需要将下边配置复制到上边
    -- hi EasyMotionTarget ctermbg=yellow ctermfg=black
    -- hi EasyMotionShade ctermbg=yellow ctermfg=black
    -- hi EasyMotionTarget2First ctermbg=yellow ctermfg=black
    -- hi EasyMotionTarget2Second ctermbg=yellow ctermfg=black
    -- hi link EasyMotionTarget ErrorMsg
    -- hi link EasyMotionShade  Comment
    -- hi link EasyMotionTarget2First MatchParen
    -- hi link EasyMotionTarget2Second MatchParen
    -- hi link EasyMotionMoveHL Search
    -- hi link EasyMotionIncSearch Search
    --
    -- easymotion插件在退出跳转时会出现diagnosing提示，改了easymotion配置后，没有出现相关问题，暂时注释此处的代码
    vim.api.nvim_create_autocmd('User', {
      pattern = { 'EasyMotionPromptBegin' },
      callback = function()
        vim.diagnostic.enable(false)
        --vim.diagnostic.disable()
      end,
    })
    local function check_easymotion()
      local timer = vim.loop.new_timer()
      timer:start(
        500,
        0,
        vim.schedule_wrap(function()
          -- vim.notify("check_easymotion")
          if vim.fn['EasyMotion#is_active']() == 0 then
            vim.diagnostic.enable()
            vim.g.waiting_for_easy_motion = false
          else
            check_easymotion()
          end
        end)
      )
    end
    vim.api.nvim_create_autocmd('User', {
      pattern = 'EasyMotionPromptEnd',
      callback = function()
        if vim.g.waiting_for_easy_motion then return end
        vim.g.waiting_for_easy_motion = true
        check_easymotion()
      end,
    })
  end,
  keys = {
    {
      '<Leader>',
      '<Plug>(easymotion-prefix)',
      mode = { 'n', 'v' },
    },
    {
      '<Leader>J',
      '<Plug>(easymotion-eol-j)',
      mode = { 'n', 'v' },
    },
    {
      '<Leader>K',
      '<Plug>(easymotion-eol-k)',
      mode = { 'n', 'v' },
    },
  },
}
