require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\url_define")
local CLIENT_SUB_GETINFO = 1
local CLIENT_SUB_BUY = 2
local SERVER_SUB_GETINFO = 1
local SERVER_SUB_BUY_SUCCESS = 2
local SERVER_SUB_BUY_FAILED = 3
function main_form_init(self)
  self.Fixed = false
  self.prize = 500
end
function on_main_form_open(form)
  set_form_pos(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("HoldFaculty", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("CapitalType0", "int", form, nx_current(), "prop_callback_refresh")
  end
  refresh_form(form)
  nx_execute("custom_sender", "custom_hold_faculty", CLIENT_SUB_GETINFO, 0)
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local hold_faculty = player:QueryProp("HoldFaculty")
  form.lbl_hold_faculty.Text = nx_widestr(hold_faculty)
  local jinzi = player:QueryProp("CapitalType0")
  form.lbl_all_money.Text = nx_widestr(jinzi)
  local max_cost = hold_faculty / form.prize
  form.tbar_select.Maximum = max_cost
  form.lbl_buy_faculty.Text = nx_widestr(form.tbar_select.Value * form.prize)
  form.lbl_buy_jinzi.Text = nx_widestr(form.tbar_select.Value)
  form.btn_buy.Enabled = false
  if nx_int(form.tbar_select.Value) > nx_int(0) and nx_int(form.tbar_select.Value) <= nx_int(jinzi) and nx_int(form.tbar_select.Value * form.prize) <= nx_int(hold_faculty) then
    form.btn_buy.Enabled = true
  end
end
function prop_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  refresh_form(form)
  return 1
end
function on_btn_colse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local buy_count = form.tbar_select.Value
  if nx_int(buy_count) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_hold_faculty", CLIENT_SUB_BUY, buy_count)
  form:Close()
end
function on_track_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_form(form)
  return 1
end
function on_btn_online_charge_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_msg(sub_cmd, arg1)
  if sub_cmd == nil or arg1 == nil then
    return false
  end
  local form = util_get_form("form_stage_main\\form_wuxue\\form_holdfaculty_buy", true, false)
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(sub_cmd) == nx_int(SERVER_SUB_GETINFO) then
    form.prize = arg1
    refresh_form(form)
  end
end
