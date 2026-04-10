local M = {}

M.ns_id = vim.api.nvim_create_namespace('pilot')
M.cache = {}

function M.setup()
  vim.g.loaded_pilot = 1

  vim.api.nvim_set_hl(0, 'PilotSuggestion', {
    default = true,
    fg = '#808080',
    ctermfg = 244,
  })

  vim.api.nvim_create_autocmd('InsertEnter', {
    pattern = '*',
    callback = function()
      if vim.g.pilot_enabled ~= 0 and vim.fn.pumvisible() == 0 then
        M.trigger(true)
      end
    end,
  })

  vim.api.nvim_create_autocmd('TextChangedI', {
    pattern = '*',
    callback = function()
      M.has_completion = false
      if vim.g.pilot_enabled ~= 0 and vim.fn.pumvisible() == 0 then
        M.trigger(true)
      end
    end,
  })

  vim.api.nvim_create_autocmd('InsertLeave', {
    pattern = '*',
    callback = function()
      M.clear()
      M.has_completion = false
      if M.timer then vim.fn.timer_stop(M.timer) end
    end,
  })

  vim.keymap.set('i', '<C-l>', function()
    if M.accept() then return '<C-l>' end
  end, { expr = true })

  vim.keymap.set('i', '<C-h>', function()
    M.clear()
    return '<C-h>'
  end, { expr = true })

  vim.api.nvim_create_user_command('Pilot', function(opts)
    local cmd = opts.fargs[1]
    if cmd == 'enable' then
      vim.g.pilot_enabled = 1
    elseif cmd == 'disable' then
      vim.g.pilot_enabled = 0
      M.clear()
    end
  end, { nargs = 1, complete = function() return { 'enable', 'disable' } end })
end

function M.trigger(immediate)
  if M.timer then vim.fn.timer_stop(M.timer) end
  if immediate then
    M.request()
  else
    M.timer = vim.fn.timer_start(100, function()
      M.request()
    end)
  end
end

function M.request()
  local bufnr = vim.api.nvim_get_current_buf()
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  row = row - 1

  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  local start_row = math.max(0, row - 16)
  local end_row = math.min(total_lines, row + 16)

  local above = {}
  for i = start_row, row - 1 do
    above[#above + 1] = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
  end

  local current_line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ''
  local current_line_before = current_line:sub(1, col)
  local current_line_after = current_line:sub(col + 1)

  local below = {}
  for i = row + 1, end_row - 1 do
    below[#below + 1] = vim.api.nvim_buf_get_lines(bufnr, i, i + 1, false)[1]
  end

  local prefix = table.concat(above, '\n')
  if #above > 0 then
    prefix = prefix .. '\n' .. current_line_before .. '[|]' .. current_line_after
  else
    prefix = current_line_before .. '[|]' .. current_line_after
  end
  if #below > 0 then
    prefix = prefix .. '\n' .. table.concat(below, '\n')
  end

  local cache_key = bufnr .. ':' .. row .. ':' .. col .. ':' .. prefix
  if M.cache[cache_key] then
    M.show(M.cache[cache_key], bufnr, row, col)
    return
  end

  local filetype = vim.bo.filetype
  local prompt = {
    messages = {
      { role = 'system', content = 'You are an expert ' .. filetype .. ' programmer. The user shows code where [|] marks the cursor position. Predict what the user will type next on this line. Output ONLY the exact text to insert after [|], no explanation, no commentary, no quotes.' },
      { role = 'user', content = prefix },
    },
  }

  local adapter = require('pilot.adapters').create_adapter()
  local request_row, request_col = row, col

  adapter:request(prompt, function(res, err)
    if err or not res or not res.content then return end
    if M.has_completion then return end
    local current_row, current_col = unpack(vim.api.nvim_win_get_cursor(0))
    current_row = current_row - 1
    if current_row ~= request_row or current_col ~= request_col then return end
    if res.content ~= '' then
      M.cache[cache_key] = res.content
    end
    M.has_completion = true
    M.show(res.content, bufnr, row, col)
  end)
end

function M.show(text, bufnr, row, col)
  M.clear()
  if not vim.api.nvim_buf_is_valid(bufnr) then return end

  local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1]
  col = math.min(col, line and #line or 0)

  local first_line = (text:match('^[^\n]+') or text):gsub('\r', '')
  if first_line == '' then return end

  local id = vim.api.nvim_buf_set_extmark(bufnr, M.ns_id, row, col, {
    virt_text = { { first_line, 'PilotSuggestion' } },
    virt_text_pos = 'overlay',
  })

  M.extmark = { id = id, bufnr = bufnr, row = row, col = col, text = first_line }
end

function M.clear()
  if M.extmark and vim.api.nvim_buf_is_valid(M.extmark.bufnr) then
    pcall(vim.api.nvim_buf_del_extmark, M.extmark.bufnr, M.ns_id, M.extmark.id)
  end
  M.extmark = nil
end

function M.accept()
  if not M.extmark then return true end
  local text = M.extmark.text
  M.clear()
  vim.schedule(function()
    vim.api.nvim_put(vim.split(text, '\n', true), '', true, true)
  end)
  return false
end

M.setup()

return M
