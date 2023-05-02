require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
require("define\\sysinfo_define")
local FORM_WULIN_TEAM_CREATE = "form_stage_main\\form_battlefield_wulin\\form_wulin_team_create"
local wudao_war_file = "share\\War\\WuDaoWar\\wudao_war.ini"
local MAX_TEAM_NAME_LENGTH = 8
local wudao_have_team = "wudao_systeminfo_10004"
local wudao_team_have_bad_word = "wudao_systeminfo_10035"
local wudao_team_empty = "wudao_systeminfo_10016"
local wudao_team_too_long = "wudao_systeminfo_10036"
local wudao_team_not_chinese = "wudao_systeminfo_10037"
function close_form()
  local form = nx_value(FORM_WULIN_TEAM_CREATE)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_wudao_create_form()
  if not is_in_wudao_prepare_scene() then
    return
  end
  local form_create = nx_value(FORM_WULIN_TEAM_CREATE)
  if nx_is_valid(form_create) and not form_create.Visible then
    form_create.Visible = true
  else
    util_show_form(FORM_WULIN_TEAM_CREATE, true)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.team_photo = 0
  self.max_team_photo = 0
end
function on_main_form_open(self)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if player:FindProp("WuDaoWarTeamName") then
    local strTeamName = player:QueryProp("WuDaoWarTeamName")
    if nx_widestr(strTeamName) ~= nx_widestr("") then
      show_caution_info(wudao_have_team)
      return
    end
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  self.btn_ok.Enabled = false
  self.mltbox_1.Visible = false
  init_team_photo_grid(self)
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
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strTeamName = nx_widestr(form.ipt_name.Text)
  if not team_name_ckeck(strTeamName) then
    return
  end
  if nx_int(form.team_photo) <= nx_int(0) or nx_int(form.team_photo) > nx_int(form.max_team_photo) then
    return
  end
  custom_create_wudao_team(strTeamName, nx_int(form.team_photo))
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_ipt_name_changed(ipt)
  local form = ipt.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.btn_ok.Enabled = false
  form.mltbox_1.Visible = false
end
function on_btn_check_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strTeamName = nx_widestr(form.ipt_name.Text)
  if not team_name_ckeck(strTeamName) then
    return
  end
  custom_check_team_name(strTeamName)
end
function on_ipt_name_get_focus(self)
  local gui = nx_value("gui")
  gui.hyperfocused = self
  if nx_widestr(self.Text) == nx_widestr(util_text("ui_wudoa_input_name")) then
    self.Text = ""
  end
end
function on_ipt_name_lost_focus(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(self.Text) == nx_widestr("") then
    self.Text = nx_widestr(util_text("ui_wudoa_input_name"))
  end
end
function on_imagegrid_photo_select_changed(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(form.max_team_photo - 1) then
    return
  end
  form.team_photo = index + 1
  local photo = self:GetItemImage(index)
  if nx_string(photo) == nx_string("") or photo == nil then
    return
  end
  form.imagegrid_1:AddItem(0, nx_string(photo), "", 1, -1)
end
function custom_check_team_name(strTeamName)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_CHECK_WAR_TEAM_NAME), nx_widestr(strTeamName))
end
function custom_create_wudao_team(strTeamName, nPhoto)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_CREATE_BATTLE_TEAM), nx_widestr(strTeamName), nx_int(nPhoto))
end
function rec_team_name_check_result(...)
  local form = nx_value(FORM_WULIN_TEAM_CREATE)
  if not nx_is_valid(form) then
    return
  end
  form.btn_ok.Enabled = true
  form.mltbox_1.Visible = true
end
function team_name_ckeck(strTeamName)
  if nx_widestr(strTeamName) == nx_widestr("") then
    show_caution_info(wudao_team_empty)
    return false
  end
  local length = string.len(nx_string(strTeamName))
  if nx_int(length) > nx_int(MAX_TEAM_NAME_LENGTH) then
    show_caution_info(wudao_team_too_long)
    return false
  end
  local checkwords = nx_value("CheckWords")
  if not nx_is_valid(checkwords) then
    return false
  end
  if not checkwords:CheckChinese(nx_widestr(strTeamName)) then
    show_caution_info(wudao_team_not_chinese)
    return false
  end
  if not checkwords:CheckBadWords(nx_widestr(strTeamName)) then
    show_caution_info(wudao_team_have_bad_word)
    return false
  end
  return true
end
function show_caution_info(strTent)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    local info = util_text(strTent)
    SystemCenterInfo:ShowSystemCenterInfo(info, CENTERINFO_PERSONAL_NO)
  end
end
function init_team_photo_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_photo
  if not nx_is_valid(grid) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", wudao_war_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("team_photo")
  if sec_count < 0 then
    return
  end
  local total_count = ini:GetSectionItemCount(sec_count)
  form.max_team_photo = total_count
  local remainder = math.fmod(total_count, 5)
  local row = 0
  if nx_int(remainder) == nx_int(0) then
    row = math.floor(total_count / 5)
  else
    row = math.floor(total_count / 5) + 1
  end
  grid:Clear()
  grid.RowNum = row
  grid.Height = grid.GridHeight * row + 10
  local visible_eara = nx_string(0) .. nx_string(",") .. nx_string(0) .. nx_string(",") .. nx_string(grid.Width) .. nx_string(",") .. nx_string(grid.Height)
  grid.ViewRect = visible_eara
  for i = 1, total_count do
    local photo = ini:ReadString(sec_count, nx_string(i), "")
    grid:AddItem(nx_int(i - 1), nx_string(photo), "", 1, -1)
  end
  form.groupscrollbox_1.IsEditMode = false
  form.groupscrollbox_1:ResetChildrenYPos()
end
