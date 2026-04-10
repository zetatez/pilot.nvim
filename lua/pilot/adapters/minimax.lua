local Base = require('pilot.adapter')

local M = setmetatable({}, { __index = Base })
M.__index = M

function M.new(config)
  return setmetatable({}, M)
end

function M.get_endpoint(self)
  if self.endpoint or vim.g.pilot_endpoint then
    return self.endpoint or vim.g.pilot_endpoint
  end
  local model = self:get_model()
  return 'https://api.minimax.chat/v1/text/chatcompletion_v2?Model=' .. model
end

function M.request(self, prompt, callback)
  local endpoint = self:get_endpoint()
  local api_key = self:get_api_key()

  local body = {
    messages = prompt.messages,
    max_tokens = 2000,
    temperature = 0.1,
    model = self:get_model(),
    reasoning_level = 0,
    repetition_penalty = 1.2,
  }

  local cmd = {
    'curl', '-s', '-X', 'POST', endpoint,
    '-H', 'Content-Type: application/json',
    '-H', 'Authorization: Bearer ' .. api_key,
    '--max-time', '30',
    '--connect-timeout', '5',
    '-d', vim.fn.json_encode(body)
  }

  vim.fn.jobstart(cmd, {
    on_stdout = function(_, data)
      if not data or not data[1] then
        callback(nil, 'empty response')
        return
      end
      local ok, j = pcall(vim.json.decode, data[1])
      if not ok or type(j) ~= 'table' then
        callback(nil, 'parse error')
        return
      end
      local res = vim.deepcopy(j)
      local content = ''
      if res.choices and type(res.choices) == 'table' and res.choices[1] then
        local msg = res.choices[1].message
        if msg and type(msg) == 'table' and type(msg.content) == 'string' then
          content = msg.content
        end
      elseif type(res.text) == 'string' then
        content = res.text
      end
      callback({ content = content })
    end,
    on_stderr = function(_, data)
      if data and data[1] and data[1]:match('error') then
        callback(nil, table.concat(data, ''))
      end
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        callback(nil, 'exit code: ' .. code)
      end
    end,
  })
end

return M
