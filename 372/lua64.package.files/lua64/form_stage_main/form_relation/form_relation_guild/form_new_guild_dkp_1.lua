require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_dkp")
local FORM_DKP = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_dkp"
local SUB_CUSTOMMSG_DKP_CHANGE = 82
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local form_dkp = nx_value(FORM_DKP)
  if not nx_is_valid(form_dkp) then
    return 0
  end
  if not nx_find_custom(form_dkp, "select_name") then
    return 0
  end
  if nx_widestr(form_dkp.select_name) == nx_widestr("") then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    local gui = nx_value("gui")
    if nx_is_valid(SystemCenterInfo) and nx_is_valid(gui) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    end
    self:Close()
    return 0
  end
  self.lbl_name.Text = nx_widestr(form_dkp.select_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    return 0
  end
  if nx_int(form.ipt_2.Text) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19656", nx_widestr(form.lbl_name.Text), nx_int(form.ipt_2.Text)) then
    return 0
  end
  local form_dkp = nx_value(FORM_DKP)
  if not nx_is_valid(form_dkp) then
    return
  end
  local from = (nx_int(form_dkp.pageno) - 1) * 10
  local to = form_dkp.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CHANGE), nx_widestr(form.lbl_name.Text), nx_int(form.ipt_2.Text), form.ipt_1.Text, nx_int(from), nx_int(to))
  form:Close()
end
function on_btn_reduce_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local lengh = nx_ws_length(form.lbl_name.Text)
  if nx_int(lengh) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19658"), 2)
    return 0
  end
  local reduce_value = nx_int(0) - nx_int(form.ipt_2.Text)
  if nx_int(reduce_value) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19673", nx_widestr(form.lbl_name.Text), nx_int(form.ipt_2.Text)) then
    return 0
  end
  local form_dkp = nx_value(FORM_DKP)
  if not nx_is_valid(form_dkp) then
    return
  end
  local from = (nx_int(form_dkp.pageno) - 1) * 10
  local to = form_dkp.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_CHANGE), nx_widestr(form.lbl_name.Text), nx_int(reduce_value), form.ipt_1.Text, nx_int(from), nx_int(to))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
