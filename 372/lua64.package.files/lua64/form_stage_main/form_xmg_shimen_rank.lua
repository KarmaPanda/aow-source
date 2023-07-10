require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_xmg_shimen_rank"
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  clear_grid(form)
  form.grid_info:SetColTitle(0, nx_widestr(util_text("ui_xmg_shimen_rank")))
  form.grid_info:SetColTitle(1, nx_widestr(util_text("ui_xmg_shimen_name")))
  form.grid_info:SetColTitle(2, nx_widestr(util_text("ui_xmg_shimen_kill_count")))
  nx_execute("custom_sender", "custom_send_xmg_shimen", 1)
  return
end
function close_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  btn.ParentForm:Close()
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_info
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function refresh_rank(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  clear_grid(form)
  local count = table.getn(arg)
  local InfoSize = 2
  if count < InfoSize or math.mod(count, InfoSize) ~= 0 then
    return
  end
  for i = 0, count / InfoSize - 1 do
    local row = form.grid_info:InsertRow(-1)
    form.grid_info:SetGridText(row, 0, nx_widestr(i + 1))
    form.grid_info:SetGridText(row, 1, nx_widestr(arg[i * InfoSize + 1]))
    form.grid_info:SetGridText(row, 2, nx_widestr(arg[i * InfoSize + 2]))
  end
end
