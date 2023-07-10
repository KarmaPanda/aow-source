require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_dkp")
local FORM_DKP = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_dkp"
local SUB_CUSTOMMSG_DKP_SELF_DEFINE = 92
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
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
function on_btn_team_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(form.ipt_1.Text) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19690") then
    return 0
  end
  local form_dkp = nx_value(FORM_DKP)
  if not nx_is_valid(form_dkp) then
    return
  end
  local from = (nx_int(form_dkp.pageno) - 1) * 10
  local to = form_dkp.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_SELF_DEFINE), nx_int(form.ipt_1.Text), form.ipt_2.Text, nx_int(from), nx_int(to))
end
function on_btn_team_reduce_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local reduce_value = nx_int(0) - nx_int(form.ipt_1.Text)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(reduce_value) == nx_int(0) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("19693"), 2)
    return
  end
  if not show_confirm_info("19689") then
    return 0
  end
  local form_dkp = nx_value(FORM_DKP)
  if not nx_is_valid(form_dkp) then
    return
  end
  local from = (nx_int(form_dkp.pageno) - 1) * 10
  local to = form_dkp.pageno * 10
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_DKP_SELF_DEFINE), nx_int(reduce_value), form.ipt_2.Text, nx_int(from), nx_int(to))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
