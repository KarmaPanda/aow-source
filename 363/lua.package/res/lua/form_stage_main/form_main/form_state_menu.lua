require("util_functions")
require("control_set")
function main_form_init(self)
end
function on_main_form_open(self)
  init_zl_auto_set(self)
  init_text_set(self)
  init_cbtn_filterask(self)
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_main\\form_state_menu", nil)
end
function on_zc_click(self)
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) and controlwatch.State ~= 0 then
    controlwatch.State = 0
  end
  local form = self.Parent.Parent
  form:Close()
end
function on_zl_click(self)
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) and controlwatch.State ~= 1 then
    controlwatch.State = 1
  end
  local form = self.Parent.Parent
  form:Close()
end
function on_wr_click(self)
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) and controlwatch.State ~= 2 then
    controlwatch.State = 2
  end
  local form = self.Parent.Parent
  form:Close()
end
function on_btn_jj_click(btn)
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) and controlwatch.State ~= 3 then
    controlwatch.State = 3
  end
  local form = btn.ParentForm
  form:Close()
end
function on_cbtn_auto_watch_checked_changed(cbtn)
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    return
  end
  controlwatch.AutoNA = cbtn.Checked
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "watch_autona", nx_int(controlwatch.AutoNA and 1 or 0))
  nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "watch_autona", controlwatch.AutoNA and "1" or "0")
  local form = cbtn.ParentForm
  form.btn_zl.Enabled = not cbtn.Checked
end
function on_cbtn_filter_ask_checked_changed(cbtn)
  local game_config_info = nx_value("game_config_info")
  util_set_property_key(game_config_info, "filter_playerask", nx_int(cbtn.Checked and 1 or 0))
  nx_execute("game_config", "save_game_config_item", "systeminfo.ini", "Config", "filter_playerask", cbtn.Checked and "1" or "0")
end
function on_ipt_zl_enter(ipt)
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    return false
  end
  controlwatch.NAMessage = nx_widestr(ipt.Text)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("GCW_NA_MESSAGE", controlwatch.NAMessage)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, -1, 0)
  end
end
function on_ipt_wr_enter(ipt)
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    return false
  end
  controlwatch.DontDisturbMessage = nx_widestr(ipt.Text)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("GCW_DONTDISTURB_MESSAGE", controlwatch.DontDisturbMessage)
  local form_logic = nx_value("form_main_sysinfo")
  if nx_is_valid(form_logic) then
    form_logic:AddSystemInfo(info, -1, 0)
  end
end
function init_zl_auto_set(form)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    local key = util_get_property_key(game_config_info, "watch_autona", 0)
    form.cbtn_auto_watch.Checked = nx_string(key) == nx_string("1")
  end
end
function init_cbtn_filterask(form)
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    local key = util_get_property_key(game_config_info, "filter_playerask", 0)
    form.cbtn_filter_ask.Checked = nx_string(key) == nx_string("1")
  end
end
function init_text_set(self)
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) then
    self.ipt_zl.Text = controlwatch.NAMessage
    self.ipt_wr.Text = controlwatch.DontDisturbMessage
  end
end
local state_image_list = {
  [0] = {
    NormalImage = "gui\\mainform\\role\\btn_free_out.png",
    FocusImage = "gui\\mainform\\role\\btn_free_on.png",
    PushImage = "gui\\mainform\\role\\btn_free_down.png"
  },
  [1] = {
    NormalImage = "gui\\mainform\\role\\btn_leave_out.png",
    FocusImage = "gui\\mainform\\role\\btn_leave_on.png",
    PushImage = "gui\\mainform\\role\\btn_leave_down.png"
  },
  [2] = {
    NormalImage = "gui\\mainform\\role\\btn_busy_out.png",
    FocusImage = "gui\\mainform\\role\\btn_busy_on.png",
    PushImage = "gui\\mainform\\role\\btn_busy_down.png"
  },
  [3] = {
    NormalImage = "gui\\mainform\\role\\btn_jujuemsr_down.png",
    FocusImage = "gui\\mainform\\role\\btn_jujuemsr_on.png",
    PushImage = "gui\\mainform\\role\\btn_jujuemsr_out.png"
  }
}
function refresh_btn_image(btn, state)
  if not nx_is_valid(btn) then
    return
  end
  local image_list = state_image_list[nx_number(state)]
  for prop, value in pairs(image_list) do
    nx_set_property(btn, prop, value)
  end
end
function refresh_btn_state_menu_image()
  local state = 0
  local controlwatch = nx_value("ControlWatch")
  if nx_is_valid(controlwatch) then
    state = controlwatch.State
  end
  local form = util_get_form("form_stage_main\\form_chat_system\\form_chat_panel", true)
  if nx_is_valid(form) then
    local btn = form.btn_state
    refresh_btn_image(btn, state)
  end
end
