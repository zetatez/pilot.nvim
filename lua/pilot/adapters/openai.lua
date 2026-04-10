local Base = require('pilot.adapter')

local M = setmetatable({}, { __index = Base })
M.__index = M

function M.new(config)
  return setmetatable({}, M)
end

function M.get_endpoint(self)
  return self.endpoint or vim.g.pilot_endpoint or 'https://api.openai.com/v1/chat/completions'
end

return M
