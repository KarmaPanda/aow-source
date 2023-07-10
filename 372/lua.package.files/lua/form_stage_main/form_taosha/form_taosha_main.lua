require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_taosha\\taosha_util")
local FORM_TAOSHA_MAIN = "form_stage_main\\form_taosha\\form_taosha_main"
local CLIENT_CUSTOMMSG_LUAN_DOU = 786
local ST_FUNCTION_TAOSHA = 890
local TaoShaClientMsg_Apply = 101
local TaoShaClientMsg_QuitBaoMing = 102
local TaoShaClientMsg_RequestData = 103
local TaoShaClientMsg_RequesBaoMingInfo = 105
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAOSHA) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("sys_school_convert_01")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  if is_in_taosha_scene() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local info = util_text("37287")
      SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
    end
    return
  end
  local form = nx_value(FORM_TAOSHA_MAIN)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
  else
    util_show_form(FORM_TAOSHA_MAIN, true)
  end
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  request_open_form()
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
    game_timer:Register(5000, -1, nx_current(), "update_left_time", self, -1, -1)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_entre_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_Apply), nx_int(1))
end
function on_btn_person_baoming_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_Apply), nx_int(1))
end
function on_btn_team_baoming_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_Apply), nx_int(2))
end
function on_btn_over_baoming_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_QuitBaoMing))
end
function request_open_form()
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_RequestData))
end
function request_baoming_info()
  nx_execute("custom_sender", "custom_taosha", nx_int(TaoShaClientMsg_RequesBaoMingInfo))
end
function rec_main_form_data(...)
  local form = nx_value(FORM_TAOSHA_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(2) then
    return
  end
  local text = nx_string(arg[1]) .. nx_string("/") .. nx_string(arg[2])
  form.lbl_7.Text = nx_widestr(text)
end
function rec_bao_ming_info(...)
  local form = nx_value(FORM_TAOSHA_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(#arg) < nx_int(4) then
    return
  end
  local text = nx_widestr("")
  if nx_int(arg[1]) == nx_int(0) then
    text = util_text("ui_thbm_001")
  elseif nx_int(arg[1]) == nx_int(1) then
    text = util_text("ui_thbm_002")
  elseif nx_int(arg[1]) == nx_int(2) then
    text = util_text("ui_thbm_003")
  end
  form.lbl_state.Text = text
  form.lbl_num.Text = nx_widestr(arg[2])
  form.lbl_rank.Text = nx_widestr(arg[3])
  form.lbl_open.Text = nx_widestr(arg[4])
end
function close_form()
  local form = nx_value(FORM_TAOSHA_MAIN)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  request_baoming_info()
end
function rec_player_pickup_item_num(...)
  local flag = is_in_taosha_scene()
  if not flag then
    form_main.mltbox_taosha.Visible = false
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  local desktop_width = form_main.Width
  local mltbox_width = form_main.mltbox_taosha.Width
  form_main.mltbox_taosha.AbsLeft = (desktop_width - mltbox_width) / 2
  local count = #arg
  if count < 6 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_th_item_001")
  for i = 1, count do
    gui.TextManager:Format_AddParam(nx_int(arg[i]))
  end
  form_main.mltbox_taosha.HtmlText = gui.TextManager:Format_GetText()
  form_main.mltbox_taosha.Visible = true
end
function hide_player_pickup_num()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  local mltbox = form_main.mltbox_taosha
  if not nx_is_valid(mltbox) then
    return
  end
  mltbox.HtmlText = nx_widestr("")
  mltbox.Visible = false
end
function hide_ctrl_entry_taosha(flag)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  if nx_is_valid(form_main.groupbox_4) then
    form_main.groupbox_4.Visible = not flag
  end
  if nx_is_valid(form_main.groupbox_ad) then
    form_main.groupbox_ad.Visible = not flag
  end
  if nx_is_valid(form_main.groupbox_dbomall) then
    form_main.groupbox_dbomall.Visible = not flag
  end
  if nx_is_valid(form_main.btn_func_guide) then
    form_main.btn_func_guide.Visible = not flag
  end
  if nx_is_valid(form_main.btn_open_yy) then
    form_main.btn_open_yy.Visible = not flag
  end
  if nx_is_valid(form_main.groupbox_openweb) then
    form_main.groupbox_openweb.Visible = not flag
  end
  if nx_is_valid(form_main.groupbox_show_update) then
    form_main.groupbox_show_update.Visible = not flag
  end
end
function hide_handle()
  local flag = nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene")
  local apex_flag = nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene")
  if not flag and not apex_flag then
    return
  end
  hide_ctrl_entry_taosha(true)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_notice_shortcut", false)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_task\\form_task_trace", false)
  local form_main_map = nx_value("form_stage_main\\form_main\\form_main_map")
  if nx_is_valid(form_main_map) then
    form_main_map.Visible = false
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form_map) then
    local gbox_pos = form_map.groupbox_player_pos
    if nx_is_valid(gbox_pos) then
      gbox_pos.Visible = false
    end
  end
end
