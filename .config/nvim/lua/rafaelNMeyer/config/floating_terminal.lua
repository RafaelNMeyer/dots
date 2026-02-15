local width = vim.o.columns
local height = vim.o.lines

local status = {
  NOT_INITIALIZED = 0,
  CLOSED = 1,
  FLOATING = 2,
  BOTTOM = 3,
}
local state = {
  window = {
    floating = {
      relative = 'editor',
      row = math.floor(height / 4),
      col = math.floor(width / 4),
      height = math.floor(height / 2),
      width = math.floor(width / 2),
      border = 'rounded'
    },
    bottom = {}
  },
  window_id = -1,
  status = status.NOT_INITIALIZED,
  buf = nil
}

local function open_floating_win()
  state.window_id = vim.api.nvim_open_win(state.buf, true, state.window.floating)
end

local function open_bottom_win()
  vim.cmd('botright split')
  vim.cmd('resize 15')
  state.window_id = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_config(state.window_id, state.window.bottom)
  vim.api.nvim_win_set_buf(state.window_id, state.buf)
  vim.opt.laststatus = 0
  vim.opt.showmode = false
  vim.opt.ruler = false
  vim.opt.showcmd = false
end

local function save_last_win_config()
  local config = vim.api.nvim_win_get_config(state.window_id)
  if config.relative == '' then
    state.window.bottom = config
  else
    state.window.floating = config
  end
end

local function close_window()
  if state.window_id ~= -1 and vim.api.nvim_win_is_valid(state.window_id) then
    save_last_win_config()
    vim.api.nvim_win_close(state.window_id, false)
    state.window_id = -1
  end
end

local function create_buf()
  if state.buf == nil then
    state.buf = vim.api.nvim_create_buf(true, true)
  end
end

local function create_term()
  if state.status == status.NOT_INITIALIZED then
    vim.cmd.terminal()
  end
end

local function toggle_terminal(arg)
  create_buf()
  close_window()
  local stat
  if arg ~= state.status then
    if arg == status.FLOATING then
      open_floating_win()
      stat = status.FLOATING
    end
    if arg == status.BOTTOM then
      open_bottom_win()
      stat = status.BOTTOM
    end
  end
  create_term()
  state.status = stat
end

vim.keymap.set('n', '<C-k>', function() toggle_terminal(status.FLOATING) end, {})
vim.keymap.set('n', '<C-j>', function() toggle_terminal(status.BOTTOM) end, {})
vim.api.nvim_set_keymap('t', '<Esc><Esc>', '<C-\\><C-N>', {})
