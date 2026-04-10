local M = {}

function M.get_provider()
  return vim.g.pilot_provider or 'openai'
end

function M.get_api_key()
  local env_name = vim.g.pilot_api_key_env
  if env_name and env_name ~= '' then
    return vim.env[env_name]
  end
  return vim.g.pilot_api_key
end

function M.get_model()
  return vim.g.pilot_model or 'gpt-5.4'
end

function M.create_adapter()
  local provider = M.get_provider()

  if provider == 'minimax' then
    return require('pilot.adapters.minimax').new()
  end

  return require('pilot.adapters.openai').new()
end

return M
