require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local CTS_Apply = 0
local CTS_OpenForm = 1
local CTS_QuerySelf = 2
local CTS_QueryRank = 3
local CTS_QueryPlayer = 4
local STC_OpenForm = 0
local STC_QuerySelf = 1
local STC_QueryRank = 2
local STC_QueryPlayer = 3
local MT_Day = 1
local MT_Week = 2
local m_AllowNum = 4
local m_Max = 199
local grop_box_old
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
