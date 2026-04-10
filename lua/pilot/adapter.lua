local M = {}

M.__index = M

function M.new(config)
  return setmetatable(config or {}, M)
end

function M.get_api_key(self)
  return self.api_key or require('pilot.adapters').get_api_key()
end

function M.get_endpoint(self)
  return self.endpoint or require('pilot.adapters').get_endpoint()
end

function M.get_model(self)
  return self.model or require('pilot.adapters').get_model()
end

function M.request(self, prompt, callback)
  local endpoint = self:get_endpoint()
  local api_key = self:get_api_key()

  local body = {
    model = self:get_model(),
    messages = prompt.messages,
    max_tokens = 1000,
    temperature = 0.5,
  }

  local headers = { ['Content-Type'] = 'application/json' }
  if api_key then
    headers['Authorization'] = 'Bearer ' .. api_key
  end

  local cmd = {
    'curl', '-s', '-X', 'POST', endpoint,
    '-H', 'Content-Type: application/json',
    '-H', 'Authorization: Bearer ' .. api_key,
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
      if res.choices and res.choices[1] then
        content = res.choices[1].message and res.choices[1].message.content or ''
      end
      callback({ content = content })
    end,
    on_stderr = function(_, data)
      callback(nil, table.concat(data, '\n'))
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        callback(nil, code)
      end
    end,
  })
end

return M
