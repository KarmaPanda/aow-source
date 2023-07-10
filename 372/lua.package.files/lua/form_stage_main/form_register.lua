require("util_functions")
require("util_gui")
local CLIENT_SUBMSG_JOIN_REGISTER = 1
local CLIENT_SUBMSG_LEAVE_REGISTER = 2
local REGISTER_TYPE_XJZLYBS = 0
local REGISTER_TYPE_YHGTXCL = 1
local REGISTER_TITLE = 1
local REGISTER_INFO = 2
local register_data = {
  [REGISTER_TYPE_XJZLYBS] = {
    [REGISTER_TITLE] = "ui_xjzhd_002",
    [REGISTER_INFO] = "ui_xjzhd_003"
  },
  [REGISTER_TYPE_YHGTXCL] = {
    [REGISTER_TITLE] = "ui_yhgtxcl_001",
    [REGISTER_INFO] = "ui_yhgtxcl_002"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.reg_type = -1
  form.reg_id = 0
  form.reg_time = 0
  form.heartbeat_count = 1000
  return 1
end
function on_main_form_open(form)
  form.lbl_time.Text = nx_widestr(form.reg_time / 1000)
  local title = nx_string(register_data[form.reg_type][REGISTER_TITLE])
  local info = nx_string(register_data[form.reg_type][REGISTER_INFO])
  form.lbl_title.Text = util_text(title)
  form.mltbox_info.HtmlText = util_text(info)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_register", CLIENT_SUBMSG_JOIN_REGISTER, form.reg_type, form.reg_id)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_server_msg(...)
  local reg_type = nx_int(arg[1])
  local reg_id = nx_int(arg[2])
  local reg_time = nx_int(arg[3])
  local form = util_get_form("form_stage_main\\form_register", true, false, reg_type)
  if not nx_is_valid(form) then
    return
  end
  form.reg_type = reg_type
  form.reg_id = reg_id
  form.reg_time = reg_time
  form:Show()
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, reg_time, nx_current(), "on_update_time", form, -1, -1)
end
function on_update_time(form)
  if form.heartbeat_count < form.reg_time then
    local leaving_time = nx_string((form.reg_time - form.heartbeat_count) / 1000)
    form.lbl_time.Text = nx_widestr(leaving_time)
    form.heartbeat_count = form.heartbeat_count + 1000
  else
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
    form:Close()
  end
end
