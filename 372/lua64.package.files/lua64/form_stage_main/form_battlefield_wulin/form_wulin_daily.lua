require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_DAILY = "form_stage_main\\form_battlefield_wulin\\form_wulin_daily"
local WuDaoTeamOperateType_ChangeLeader = 1
local WuDaoTeamOperateType_Quit = 2
local WuDaoTeamOperateType_RankUp = 3
local WuDaoTeamOperateType_Lose = 4
local WuDaoTeamOperateType_Win = 5
local WuDaoTeamOperateType_Join = 6
local WuDaoTeamOperateType_Create = 7
local wudao_operate_type = "wudao_event_sys_"
function close_form()
  local form = nx_value(FORM_WULIN_DAILY)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_event_form()
  if not is_in_wudao_prepare_scene() then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindProp("WuDaoWarTeamName") then
    return
  end
  local strTeamName = player:QueryProp("WuDaoWarTeamName")
  if nx_widestr(strTeamName) == nx_widestr("") then
    return
  end
  local form_event = nx_value(FORM_WULIN_DAILY)
  if nx_is_valid(form_event) and not form_event.Visible then
    form_event.Visible = true
  else
    util_show_form(FORM_WULIN_DAILY, true)
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
  custom_wudao_team_event()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function custom_wudao_team_event()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_REQUEST_BATTLE_TEAM_EVENT))
end
function rec_wudao_team_event_info(...)
  local form = nx_value(FORM_WULIN_DAILY)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.mltbox_1:Clear()
  for i = 1, #arg do
    local event_info = arg[i]
    local event_info_list = util_split_wstring(event_info, ",")
    if nx_int(#event_info_list) == nx_int(4) then
      local event_time = event_info_list[1]
      local event_type = event_info_list[2]
      local event_object_one = event_info_list[3]
      local event_object_two = event_info_list[4]
      local text_id = wudao_operate_type .. nx_string(event_type)
      local text = gui.TextManager:GetFormatText(text_id, nx_string(event_time), nx_widestr(event_object_one), nx_widestr(event_object_two))
      form.mltbox_1:AddHtmlText(text, -1)
    end
  end
  form.mltbox_1.ReadOnly = true
  form.mltbox_1.SelectBarColor = "0,0,0,0"
  form.mltbox_1.MouseInBarColor = "0,0,0,0"
end
