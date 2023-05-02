require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\request_type")
require("define\\gamehand_type")
require("define\\team_rec_define")
require("share\\client_custom_define")
require("define\\player_name_color_define")
require("form_stage_main\\form_team\\team_util_functions")
local FORM_TEAM_RECRUIT = "form_stage_main\\form_team\\form_team_recruit"
local FORM_TEAM_LARGE_RECRUIT = "form_stage_main\\form_team\\form_team_large_recruit"
local FORM_SINGLE_INFO = "form_stage_main\\form_team\\form_team_single_info"
local FORM_TINY_INFO = "form_stage_main\\form_team\\form_team_tiny_info"
local FORM_TEAM_TINY = "form_stage_main\\form_main\\form_main_tiny_team"
local FORM_SINGLE_TINY = "form_stage_main\\form_main\\form_main_tiny_single"
local FORM_QUALITY = "form_stage_main\\form_team\\form_quality"
local shaneimage = {
  [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_chu.png",
  [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia.png",
  [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e.png",
  [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang.png",
  [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie.png"
}
local TEAM_REC = "team_rec"
local gb_name = "gb_team_"
local gb_mb = "gb_mb_"
local btn_name = "Button_MemberBack_"
local label_name = "lbl_Name"
local vo_name = "lbl_Vo"
local vc_name = "lbl_Vc"
local vo_zy = "lbl_Zy"
local shane_name = "lbl_shane"
local Selected_Color = "255,255,255,255"
local PlayerName_Color = "178,153,127"
local PowerLevel_Color = "178,153,127"
local Offline_Color = "255,128,128,128"
local SET_MEMBER_POSITION = 0
local SET_MEMBER_WORK = 1
local TYPE_NORAML_PLAYER = 0
local TYPE_NORAML_LEADER = 1
local TYPE_NORAML_ASSIST = 2
local MAX_TINY_TEAM = 8
local MAX_TINY_TEAM_MEMBER = 6
local STATE_ALREADY_ENTER = 3
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function refresh_form(form)
  if nx_is_valid(form) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    form.team_type = client_player:QueryProp("TeamType")
    refresh_team_grid(form)
    disp_team_pick_mode(form)
    local main_form = nx_value(FORM_TEAM_RECRUIT)
    if nx_is_valid(main_form) then
      main_form.groupbox_nearby.Visible = false
    end
  end
end
function main_form_init(form)
  form.Fixed = true
  form.MaxNumOfTeam = MAX_TINY_TEAM
  form.MaxSmallNumOfMember = MAX_TINY_TEAM_MEMBER
  form.lastSelectIndex = -1
  form.team_type = TYPE_NORAML_TEAM
  util_get_form(FORM_TINY_INFO)
  util_get_form(FORM_SINGLE_INFO)
end
function main_form_open(form)
  PlayerName_Color = nx_string(form.lbl_Name11.ForeColor)
  PowerLevel_Color = nx_string(form.lbl_Zy11.ForeColor)
  adjust_grid_style(form)
  data_bind_prop(form)
  on_refresh_team_grid(form)
  disp_team_pick_mode(form)
end
function on_main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
  util_show_form(FORM_SINGLE_INFO, false)
  util_show_form(FORM_TINY_INFO, false)
end
function data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, self, nx_current(), "on_table_operat")
    databinder:AddRolePropertyBind("TeamType", "int", self, nx_current(), "on_TeamType_Change")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", self, nx_current(), "on_TeamCaptain_Change")
    databinder:AddRolePropertyBind("TeamPickMode", "int", self, nx_current(), "disp_team_pick_mode")
    databinder:AddRolePropertyBind("BattlefieldState", "int", self, nx_current(), "on_BattlefieldState_Change")
  end
end
function del_data_bind_prop(self)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind(TEAM_REC, self)
    data_binder:DelRolePropertyBind("TeamCaptain", self)
    data_binder:DelRolePropertyBind("TeamType", self)
    data_binder:DelRolePropertyBind("TeamPickMode", self)
    data_binder:DelRolePropertyBind("BattlefieldState", self)
  end
end
function on_TeamType_Change(self)
  if not self.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local team_type = client_player:QueryProp("TeamType")
  self.team_type = team_type
  if team_type == TYPE_NORAML_TEAM then
    close_all_team_tiny()
    close_all_single_tiny()
  elseif team_type == TYPE_LARGE_TEAM then
    refresh_team_grid(self)
  end
end
function on_TeamCaptain_Change(self)
  if not self.Visible then
    return
  end
  refresh_team_grid(self)
  disp_team_pick_mode(self)
end
function on_BattlefieldState_Change(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local state = client_player:QueryProp("BattlefieldState")
  local isInBattle = nx_int(state) == nx_int(STATE_ALREADY_ENTER)
  self.btn_show_nearby.Visible = not isInBattle
  local form = nx_value(FORM_TEAM_RECRUIT)
  if form.groupbox_nearlist.Visible then
    nx_execute(FORM_TEAM_RECRUIT, "set_groupbox_nearlist_visible", false)
    nx_execute(FORM_TEAM_RECRUIT, "on_gui_size_change")
  end
end
function on_table_operat(self, tablename, ttype, line, col)
  if self.Visible == true then
    if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_TEAMPOSITION or col == TEAM_REC_COL_TEAMWORK or col == TEAM_REC_COL_ISOFFLINE or col == TEAM_REC_COL_CAMP or col == TEAM_REC_COL_LEVELTITLE or col == TEAM_REC_COL_SCHOOL or col == TEAM_REC_COL_CHARACTERFLAG or col == TEAM_REC_COL_CHARACTERVALUE then
      refresh_team_grid(self)
    end
    if nx_string(ttype) == nx_string("clear") then
      on_refresh_team_grid(self)
    end
    if nx_string(ttype) == nx_string("del") then
      on_refresh_team_grid(self)
    end
  end
end
function refresh_team_grid(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_team_grid", self)
    timer:Register(500, 1, nx_current(), "on_refresh_team_grid", self, -1, -1)
  end
end
function on_refresh_team_grid(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_team_grid", self)
  end
  clear_team_grid(self)
  if self.team_type ~= TYPE_LARGE_TEAM then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local captainname = client_player:QueryProp("TeamCaptain")
  local pick_mode = client_player:QueryProp("TeamPickMode")
  local shanetable = {}
  for i = 1, self.MaxNumOfTeam do
    shanetable[i] = {}
    shanetable[i].flag = 0
    shanetable[i].value = -1
    shanetable[i].count = 0
  end
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  if 0 < item_row_num then
    for i = 0, item_row_num - 1 do
      local playername = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
      local playerpos = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMPOSITION)
      local playerwork = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMWORK)
      local leveltitle = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_LEVELTITLE)
      local OffLinetime = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_ISOFFLINE)
      local Camp = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CAMP)
      local charflag = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CHARACTERFLAG)
      local charvalue = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CHARACTERVALUE)
      if playername == nil or playerpos == nil or playerwork == nil or leveltitle == nil or OffLinetime == nil or Camp == nil or charflag == nil or charvalue == nil then
        return
      end
      local index = nx_int(playerpos / 10) + 1
      shanetable[index].count = shanetable[index].count + 1
      if nx_int(shanetable[index].value) < nx_int(charvalue) then
        shanetable[index].value = charvalue
        shanetable[index].flag = charflag
      end
      show_member(self, playername, pick_mode, playerpos, playerwork, leveltitle, OffLinetime, Camp)
    end
  end
  for i = 1, self.MaxNumOfTeam do
    local groupbox = self:Find(gb_name .. nx_string(i))
    if nx_is_valid(groupbox) then
      local lbl_shane = groupbox:Find(shane_name .. nx_string(i))
      local teamflag = shanetable[i].flag
      if nx_is_valid(lbl_shane) then
        if nx_int(teamflag) < nx_int(0) or nx_int(teamflag) > nx_int(4) or 0 >= shanetable[i].count then
          lbl_shane.BackImage = ""
          lbl_shane.charflag = 0
          lbl_shane.charvalue = -1
          lbl_shane.Visible = false
        else
          lbl_shane.BackImage = shaneimage[nx_number(teamflag)]
          lbl_shane.charflag = shanetable[i].flag
          lbl_shane.charvalue = shanetable[i].value
          lbl_shane.Visible = true
        end
      end
    end
  end
  refresh_openhp_status()
  enable_buttons(self)
end
function refresh_openhp_status()
  local form = nx_value(FORM_TEAM_LARGE_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local small_team_table = {}
  for i = 1, form.MaxNumOfTeam do
    small_team_table[i] = {}
    small_team_table[i].count = 0
  end
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  if 0 < item_row_num then
    for i = 0, item_row_num - 1 do
      local playerpos = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMPOSITION)
      local index = nx_int(playerpos / 10) + 1
      small_team_table[index].count = small_team_table[index].count + 1
    end
  end
  for i = 1, form.MaxNumOfTeam do
    local groupbox = form:Find(gb_name .. nx_string(i))
    local btn_openhp = groupbox:Find("btn_openhp" .. nx_string(i))
    local btn_drag = groupbox:Find("btn_drag" .. nx_string(i))
    if small_team_table[i].count > 0 then
      btn_openhp.Enabled = true
      if util_is_form_visible(FORM_TEAM_TINY, i) then
        btn_openhp.Checked = true
        btn_drag.Enabled = false
      else
        btn_openhp.Checked = false
        btn_drag.Enabled = true
      end
    else
      btn_openhp.Enabled = false
      btn_drag.Enabled = false
    end
  end
end
function refresh_controls_status()
  local form = nx_value(FORM_TEAM_LARGE_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  refresh_openhp_status()
  local count = 0
  for i = 1, form.MaxNumOfTeam do
    if util_is_form_visible(FORM_TEAM_TINY, i) then
      count = count + 1
    end
  end
  if count == 0 then
    form.cbtn_show_all.Checked = false
  end
end
function clear_team_grid(self)
  for j = 1, self.MaxNumOfTeam do
    local groupbox = self:Find(gb_name .. nx_string(j))
    if nx_is_valid(groupbox) then
      local lbl_shane = groupbox:Find(shane_name .. nx_string(j))
      if nx_is_valid(lbl_shane) then
        lbl_shane.Visible = false
      end
      for i = 1, self.MaxSmallNumOfMember do
        local mbbox = groupbox:Find(gb_mb .. nx_string(j) .. nx_string(i))
        local labelname = mbbox:Find(label_name .. nx_string(j) .. nx_string(i))
        local voimg = mbbox:Find(vo_name .. nx_string(j) .. nx_string(i))
        local vcimg = mbbox:Find(vc_name .. nx_string(j) .. nx_string(i))
        local info = mbbox:Find(vo_zy .. nx_string(j) .. nx_string(i))
        labelname.Text = nx_widestr("")
        voimg.BackImage = ""
        vcimg.BackImage = ""
        info.Text = nx_widestr("")
      end
    end
  end
  recover_all_status(self)
end
function show_member(self, playername, pick_mode, playerpos, playerwork, leveltitle, isOffLine, Camp)
  local gui = nx_value("gui")
  playerpos = playerpos + 11
  local pos = nx_int(playerpos) / nx_int(10)
  local groupbox = self:Find(gb_name .. nx_string(nx_int(pos)))
  if not nx_is_valid(groupbox) then
    return
  end
  local mbbox = groupbox:Find(gb_mb .. nx_string(playerpos))
  if not nx_is_valid(mbbox) then
    return
  end
  local vocation_img = mbbox:Find(vo_name .. nx_string(playerpos))
  if not nx_is_valid(vocation_img) then
    return
  end
  local allot_img = mbbox:Find(vc_name .. nx_string(playerpos))
  if not nx_is_valid(allot_img) then
    return
  end
  if is_team_captain_by_name(playername) then
    vocation_img.BackImage = ICON_COLONEL
    if nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
      allot_img.BackImage = ICON_ALLOCATEE
    end
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
    allot_img.BackImage = ICON_ALLOCATEE
    vocation_img.BackImage = ""
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_ASSIST) then
    allot_img.BackImage = ""
    vocation_img.BackImage = ICON_ASSISTANT
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_PLAYER) then
    allot_img.BackImage = ""
    vocation_img.BackImage = ""
  end
  local lblMemberName = mbbox:Find(label_name .. nx_string(playerpos))
  if not nx_is_valid(lblMemberName) then
    return
  end
  lblMemberName.Text = nx_widestr(playername)
  local label_powerlevel = mbbox:Find(vo_zy .. nx_string(playerpos))
  if not nx_is_valid(label_powerlevel) then
    return
  end
  label_powerlevel.Text = gui.TextManager:GetText("desc_" .. nx_string(leveltitle))
  if nx_number(self.lastSelectIndex) == nx_number(playerpos) then
    local superBox = self:Find(gb_name .. string.sub(nx_string(self.lastSelectIndex), 1, 1))
    local groupbox = superBox:Find(gb_mb .. nx_string(self.lastSelectIndex))
    if nx_is_valid(groupbox) then
      groupbox.BackImage = nx_number(playerpos) % 2 == 1 and form.lbl_select1.BackImage or form.lbl_select2.BackImage
    end
    lblMemberName.ForeColor = Selected_Color
    label_powerlevel.ForeColor = Selected_Color
  elseif nx_number(isOffLine) > nx_number(0) then
    lblMemberName.ForeColor = Offline_Color
    label_powerlevel.ForeColor = Offline_Color
  else
    lblMemberName.ForeColor = PlayerName_Color
    label_powerlevel.ForeColor = PowerLevel_Color
  end
end
function find_firstpos_of_smallteam(groupbox, j)
  local form = util_get_form(FORM_TEAM_LARGE_RECRUIT)
  for i = 1, form.MaxSmallNumOfMember do
    local mbbox = groupbox:Find(gb_mb .. nx_string(j) .. nx_string(i))
    local labelname = mbbox:Find(label_name .. nx_string(j) .. nx_string(i))
    if nx_widestr(labelname.Text) == nx_widestr("") then
      return nx_int(i)
    end
  end
  return nx_int(self.MaxSmallNumOfMember + 1)
end
function set_buttonback_on(form, index, drag_x, drag_y)
  local notfind = true
  local drag_index = -1
  for j = 1, form.MaxNumOfTeam do
    local groupbox = form:Find(gb_name .. nx_string(j))
    for i = 1, form.MaxSmallNumOfMember do
      local mbbox = groupbox:Find(gb_mb .. nx_string(j) .. nx_string(i))
      local Btn_Member0 = mbbox:Find(btn_name .. nx_string(j) .. nx_string(i))
      if drag_x and drag_y and notfind and nx_is_valid(Btn_Member0) and is_in_rect(Btn_Member0.AbsLeft, Btn_Member0.AbsTop, Btn_Member0.Width, Btn_Member0.Height, drag_x, drag_y) then
        drag_index = Btn_Member0.DataSource
        notfind = false
      end
      if nx_is_valid(Btn_Member0) then
        Btn_Member0.BackImage = ""
      end
    end
  end
  if index == -1 then
    return drag_index
  end
  local pos = index / 10
  local groupbox = form:Find(gb_name .. nx_string(nx_int(pos)))
  if not nx_is_valid(groupbox) then
    return drag_index
  end
  local mbbox = groupbox:Find(gb_mb .. nx_string(index))
  if not nx_is_valid(mbbox) then
    return drag_index
  end
  local Btn_Member = mbbox:Find(btn_name .. nx_string(index))
  if not nx_is_valid(Btn_Member) then
    return drag_index
  end
  return drag_index
end
function change_Member_Info(form, set_type, set_param, target_name)
  if set_type == SET_MEMBER_POSITION then
    local pos0 = nx_int(set_param) / nx_int(10)
    local pos1 = set_param - pos0 * 10
    if nx_int(pos1) < nx_int(0) or nx_int(pos1) >= nx_int(form.MaxSmallNumOfMember) then
      return
    end
    if nx_int(pos0) < nx_int(0) or nx_int(pos0) >= nx_int(form.MaxNumOfTeam) then
      return
    end
  elseif set_type == SET_MEMBER_WORK then
  end
  if nx_widestr(target_name) == nx_widestr("") then
    return
  end
  nx_execute("custom_sender", "custom_team_member_set", nx_int(set_type), nx_int(set_param), nx_widestr(target_name))
end
function get_name_for_index(form, index)
  local pos = index / 10
  local groupbox = form:Find(gb_name .. nx_string(nx_int(pos)))
  if not nx_is_valid(groupbox) then
    return nx_widestr("")
  end
  local mbbox = groupbox:Find(gb_mb .. nx_string(index))
  if not nx_is_valid(mbbox) then
    return nx_widestr("")
  end
  local labelMembername = mbbox:Find(label_name .. nx_string(index))
  if not nx_is_valid(labelMembername) then
    return nx_widestr("")
  end
  return nx_widestr(labelMembername.Text)
end
function picture_on_rmouse_click(self)
  hide_quality_page()
  local form = util_get_form(FORM_TEAM_LARGE_RECRUIT)
  local index = nx_number(self.DataSource)
  local name = get_name_for_index(form, index)
  if nx_widestr(name) == nx_widestr("") then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "team", "team")
  nx_execute("menu_game", "menu_recompose", menu_game, name)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x, y)
end
function on_btn_openhp_click(cbtn)
  local form = cbtn.ParentForm
  hide_quality_page()
  local btnname = nx_string(cbtn.Name)
  local index = nx_number(string.sub(btnname, string.len("btn_openhp") + 1, string.len(btnname)))
  util_show_form(FORM_TEAM_TINY, cbtn.Checked, index)
  local groupbox = cbtn.Parent
  local btn_drag = groupbox:Find("btn_drag" .. nx_string(index))
  if nx_is_valid(btn_drag) then
    btn_drag.Enabled = not cbtn.Checked
  end
end
function on_lbl_shane_get_capture(label)
  local form_team_recruit = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form_team_recruit) then
    nx_execute(FORM_TEAM_RECRUIT, "show_self_shane_info", label, label.charflag, label.charvalue)
  end
end
function on_lbl_shane_lost_capture(label)
  local form_team_recruit = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form_team_recruit) then
    form_team_recruit.gb_self_shan_e.Visible = false
  end
end
function on_changeCaptain_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local index = form.lastSelectIndex
  if index < 0 then
    return 1
  end
  local membername = get_name_for_index(form, index)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  nx_execute("custom_sender", "custom_caption_change", membername)
  return 0
end
function on_disbandTeam_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  recover_select_status(form)
  set_buttonback_on(form, -1)
  form.lastSelectIndex = -1
  nx_execute("custom_sender", "custom_team_destroy")
end
function on_fireTeam_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local index = form.lastSelectIndex
  if index < 0 then
    return 1
  end
  local membername = get_name_for_index(form, index)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  nx_execute("custom_sender", "custom_kickout_team", membername)
  return 0
end
function on_add_player_click(btn)
  hide_quality_page()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr("@ui_zudui0003")
  dialog.info_label.Text = nx_widestr("@ui_zudui0049")
  dialog.allow_empty = false
  dialog.name_edit.MaxLength = 20
  dialog:ShowModal()
  local res, new_name = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "cancel" then
    return 0
  end
  if new_name == "" then
    disp_error("name is empty")
    return 0
  end
  nx_execute("custom_sender", "custom_team_invite", new_name)
end
function on_set_allocater_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local index = form.lastSelectIndex
  if index < 0 then
    return 1
  end
  local membername = get_name_for_index(form, index)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  change_Member_Info(form, SET_MEMBER_WORK, TYPE_NORAML_LEADER, membername)
  return 0
end
function on_set_assist_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local index = form.lastSelectIndex
  if index < 0 then
    return 1
  end
  local membername = get_name_for_index(form, index)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  if is_team_captain_by_name(membername) then
    return 1
  end
  change_Member_Info(form, SET_MEMBER_WORK, TYPE_NORAML_ASSIST, membername)
  return 0
end
function on_release_work_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local index = form.lastSelectIndex
  if index < 0 then
    return 1
  end
  local membername = get_name_for_index(form, index)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  change_Member_Info(form, SET_MEMBER_WORK, TYPE_NORAML_PLAYER, membername)
  return 0
end
function release_work_byname(membername)
  if nx_string(membername) == nx_string("") then
    return 1
  end
  if is_team_captain_by_name(name) then
    return 1
  end
  change_Member_Info(form, SET_MEMBER_WORK, TYPE_NORAML_PLAYER, membername)
  return 0
end
function hide_quality_page()
  local form = nx_value(FORM_QUALITY)
  if nx_is_valid(form) then
    form.Visible = false
  end
end
function reset_pick_mode(self)
  local timer = nx_value("timer_game")
  hide_quality_page()
  if nx_is_valid(timer) then
    timer:Register(1000, 1, nx_current(), "on_reset_pick_mode", self, -1, -1)
  end
end
function on_reset_pick_mode(self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_reset_pick_mode", self)
  end
  disp_team_pick_mode(self)
end
function team_alloc_free_click(btn)
  local form = btn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_pick_mode(form)
    return
  end
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_FREE)
  reset_pick_mode(form)
end
function team_alloc_turn_click(btn)
  local form = btn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_pick_mode(form)
    return
  end
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_TURN)
  reset_pick_mode(form)
end
function team_alloc_team_click(btn)
  local form = btn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_pick_mode(form)
    return
  end
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_TEAM)
  reset_pick_mode(form)
end
function team_alloc_allocater_click(btn)
  local form = btn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_pick_mode(form)
    return
  end
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_CAPTAIN)
  reset_pick_mode(form)
end
function team_alloc_compete_click(btn)
  local form = btn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_pick_mode(form)
    return
  end
  nx_execute("custom_sender", "custom_set_team_allot_mode", TEAM_PICK_MODE_COMPETE)
  reset_pick_mode(form)
end
function disp_team_pick_mode(self)
  if not self.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  self.rbtn_freeze.Checked = false
  self.rbtn_freeze.Enabled = false
  self.rbtn_turn.Checked = false
  self.rbtn_turn.Enabled = false
  self.rbtn_team.Checked = false
  self.rbtn_team.Enabled = false
  self.rbtn_capital.Checked = false
  self.rbtn_capital.Enabled = false
  self.rbtn_compete.Checked = false
  self.rbtn_compete.Enabled = false
  self.btn_quality_setup1.Visible = false
  self.btn_quality_setup2.Visible = false
  self.btn_quality_setup3.Visible = false
  if not is_in_team() then
    return
  end
  local pick_mode = client_player:QueryProp("TeamPickMode")
  if not is_team_captain() then
    if nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_FREE) then
      self.rbtn_freeze.Checked = true
      self.rbtn_freeze.Enabled = true
    elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_TURN) then
      self.rbtn_turn.Checked = true
      self.rbtn_turn.Enabled = true
    elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_TEAM) then
      self.rbtn_team.Checked = true
      self.rbtn_team.Enabled = true
      self.btn_quality_setup1.Visible = true
    elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_CAPTAIN) then
      self.rbtn_capital.Checked = true
      self.rbtn_capital.Enabled = true
      self.btn_quality_setup2.Visible = true
    elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_COMPETE) then
      self.rbtn_compete.Checked = true
      self.rbtn_compete.Enabled = true
      self.btn_quality_setup3.Visible = true
    end
    return
  end
  self.rbtn_freeze.Enabled = true
  self.rbtn_turn.Enabled = true
  self.rbtn_team.Enabled = true
  self.rbtn_capital.Enabled = true
  self.rbtn_compete.Enabled = true
  if nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_FREE) then
    self.rbtn_freeze.Checked = true
  elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_TURN) then
    self.rbtn_turn.Checked = true
  elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_TEAM) then
    self.rbtn_team.Checked = true
    self.btn_quality_setup1.Visible = true
  elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_CAPTAIN) then
    self.rbtn_capital.Checked = true
    self.btn_quality_setup2.Visible = true
  elseif nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_COMPETE) then
    self.rbtn_compete.Checked = true
    self.btn_quality_setup3.Visible = true
  end
  enable_buttons(self)
end
function enable_buttons(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local selfname = client_player:QueryProp("Name")
  local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(selfname))
  local playerwork = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  local pick_mode = client_player:QueryProp("TeamPickMode")
  if not is_in_team() then
    form.btn_remove_member.Enabled = false
    form.btn_give_capital.Enabled = false
    form.btn_disbuild_team.Enabled = false
    form.btn_set_allocater.Enabled = false
    form.btn_set_assist.Enabled = false
    form.btn_add_normal.Enabled = false
  elseif is_team_captain() then
    form.btn_remove_member.Enabled = true
    form.btn_give_capital.Enabled = true
    form.btn_disbuild_team.Enabled = true
    form.btn_set_assist.Enabled = true
    form.btn_add_normal.Enabled = true
    if nx_number(pick_mode) == nx_number(TEAM_PICK_MODE_CAPTAIN) then
      form.btn_set_allocater.Enabled = true
    else
      form.btn_set_allocater.Enabled = false
    end
    return
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_ASSIST) then
    form.btn_remove_member.Enabled = false
    form.btn_give_capital.Enabled = false
    form.btn_disbuild_team.Enabled = false
    form.btn_set_allocater.Enabled = false
    form.btn_set_assist.Enabled = false
    form.btn_add_normal.Enabled = true
    return
  else
    form.btn_remove_member.Enabled = false
    form.btn_give_capital.Enabled = false
    form.btn_disbuild_team.Enabled = false
    form.btn_set_allocater.Enabled = false
    form.btn_set_assist.Enabled = false
    form.btn_add_normal.Enabled = false
  end
end
function on_btn_push(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "task", "", "", "", "")
  local groupbox = btn.Parent
  btn.DragCenterX = groupbox.AbsLeft
  btn.DragCenterY = groupbox.AbsTop
  local drag_page = util_get_form(FORM_TINY_INFO, true, false)
  if not nx_is_valid(drag_page) then
    return
  end
  local isEmpty = true
  local index0 = nx_number(btn.DataSource) * 10 + 1
  local tmp0 = nx_widestr(get_all_info_for_index(form, index0))
  if nx_string(tmp0) == "" then
    tmp0 = " , , , "
  else
    isEmpty = false
  end
  drag_page.data_source = nx_widestr(tmp0)
  for i = 2, form.MaxSmallNumOfMember do
    local index = nx_number(btn.DataSource) * 10 + i
    local tmp = nx_widestr(get_all_info_for_index(form, index))
    if nx_string(tmp) == "" then
      tmp = " , , , "
    else
      isEmpty = false
    end
    drag_page.data_source = nx_widestr(drag_page.data_source) .. nx_widestr(",") .. nx_widestr(tmp)
    drag_page.eid = btn.DataSource
  end
  if not isEmpty then
    drag_page.AbsLeft = groupbox.AbsLeft
    drag_page.AbsTop = groupbox.AbsTop
    util_show_form(FORM_TINY_INFO, true)
  end
end
function on_btn_drag_move(btn, x, y)
  if not btn.Enabled then
    return
  end
  btn.DragCenterX = btn.DragCenterX + x
  btn.DragCenterY = btn.DragCenterY + y
  local drag_page = util_get_form(FORM_TINY_INFO, true, false)
  drag_page.AbsLeft = btn.DragCenterX
  drag_page.AbsTop = btn.DragCenterY
end
function on_btn_drag_click(btn)
  hide_quality_page()
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "Default", "", "", "", "")
  util_show_form(FORM_TINY_INFO, false)
  local form = util_get_form(FORM_TEAM_LARGE_RECRUIT)
  if not is_in_rect(form.AbsLeft, form.AbsTop, form.Width, form.Height, btn.DragCenterX, btn.DragCenterY) then
    local tiny_team = util_get_form(FORM_TEAM_TINY, true, true, nx_number(btn.DataSource))
    if nx_is_valid(tiny_team) then
      tiny_team.AbsLeft = btn.DragCenterX
      tiny_team.AbsTop = btn.DragCenterY
      tiny_team.isDrag = 1
      util_show_form(FORM_TEAM_TINY, true, nx_number(btn.DataSource))
      local groupbox = btn.Parent
      local btnname = nx_string(btn.Name)
      local index = string.sub(btnname, string.len("btn_drag") + 1, string.len(btnname))
      local btn_openhp = groupbox:Find("btn_openhp" .. index)
      if nx_is_valid(btn_openhp) then
        btn_openhp.Checked = true
      end
      btn.Enabled = false
    end
  end
end
function on_btn_show_nearby_click(btn)
  hide_quality_page()
  local form = nx_value(FORM_TEAM_RECRUIT)
  if form.groupbox_nearlist.Visible then
    nx_execute(FORM_TEAM_RECRUIT, "set_groupbox_nearlist_visible", false)
  else
    nx_execute(FORM_TEAM_RECRUIT, "set_groupbox_nearlist_visible", true)
  end
  nx_execute(FORM_TEAM_RECRUIT, "on_gui_size_change")
end
function on_leaveTeam_click(btn)
  hide_quality_page()
  nx_execute("custom_sender", "custom_leave_team")
end
function on_cbtn_show_all_click(cbtn)
  hide_quality_page()
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "show_all_click", cbtn)
  if cbtn.Checked then
    timer:Register(500, 1, nx_current(), "show_all_click", cbtn, -1, -1)
  else
    close_all_team_tiny()
  end
end
function show_all_click(btn)
  local form = btn.ParentForm
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "show_all_click", btn)
  end
  for i = 1, nx_number(MAX_TINY_TEAM) do
    local member_count = get_member_count(i)
    if nx_int(member_count) > nx_int(0) and not util_is_form_visible(FORM_TEAM_TINY, i) then
      util_auto_show_hide_form(FORM_TEAM_TINY, i)
    end
  end
  for i = 1, form.MaxNumOfTeam do
    local groupbox = form:Find(gb_name .. nx_string(i))
    local btn_openhp = groupbox:Find("btn_openhp" .. nx_string(i))
    local btn_drag = groupbox:Find("btn_drag" .. nx_string(i))
    if nx_is_valid(btn_openhp) then
      btn_openhp.Enabled = false
    end
    if nx_is_valid(btn_drag) then
      btn_drag.Enabled = false
    end
  end
end
function close_all_single_tiny()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  for i = 0, item_row_num - 1 do
    local playername = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
    util_show_form(FORM_SINGLE_TINY, false, nx_string(playername))
  end
end
function close_all_team_tiny()
  for i = 1, nx_number(MAX_TINY_TEAM) do
    if util_is_form_visible(FORM_TEAM_TINY, i) then
      util_show_form(FORM_TEAM_TINY, false, i)
    end
  end
end
function on_Button_MemberBack_drag_move(btn, x, y)
  if not btn.Enabled then
    return
  end
  btn.DragCenterX = btn.DragCenterX + x
  btn.DragCenterY = btn.DragCenterY + y
  local drag_page = util_get_form(FORM_SINGLE_INFO, true, false)
  drag_page.AbsLeft = btn.DragCenterX - btn.Width / 2
  drag_page.AbsTop = btn.DragCenterY - btn.Height / 2
end
function on_Button_MemberBack_push(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "task", "", "", "", "")
  btn.DragCenterX = btn.AbsLeft + btn.Width / 2
  btn.DragCenterY = btn.AbsTop + btn.Height / 2
  local drag_page = util_get_form(FORM_SINGLE_INFO, true)
  if not nx_is_valid(drag_page) then
    return
  end
  drag_page.data_source = nx_widestr(get_all_info_for_index(form, nx_number(btn.DataSource)))
  if drag_page.data_source ~= nx_widestr("") then
    local restindex = nx_number(btn.DataSource)
    recover_all_status(form)
    local superBox = btn.Parent.Parent
    local groupbox = superBox:Find(gb_mb .. nx_string(restindex))
    if nx_is_valid(groupbox) then
      groupbox.BackImage = nx_number(restindex) % 2 == 1 and form.lbl_select1.BackImage or form.lbl_select2.BackImage
      local lblMemberName = groupbox:Find(label_name .. nx_string(restindex))
      if nx_is_valid(lblMemberName) then
        lblMemberName.ForeColor = Selected_Color
      end
      local lblOrigin = groupbox:Find(vo_zy .. nx_string(restindex))
      if nx_is_valid(lblOrigin) then
        lblOrigin.ForeColor = Selected_Color
      end
    end
    drag_page.AbsLeft = btn.AbsLeft
    drag_page.AbsTop = btn.AbsTop
    util_show_form(FORM_SINGLE_INFO, true)
  end
end
function picture_on_click(btn)
  hide_quality_page()
  local form = btn.ParentForm
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "Default", "", "", "", "")
  util_show_form(FORM_SINGLE_INFO, false)
  local restindex = nx_number(btn.DataSource)
  local destindex = restindex
  if nx_widestr(get_all_info_for_index(form, restindex)) ~= nx_widestr("") then
    destindex = set_buttonback_on(form, restindex, btn.DragCenterX, btn.DragCenterY)
  end
  form.lastSelectIndex = restindex
  if nx_number(restindex) ~= nx_number(destindex) then
    if destindex == -1 then
      if not is_in_rect(form.AbsLeft, form.AbsTop, form.Width, form.Height, btn.DragCenterX, btn.DragCenterY) then
        local player_name = get_name_for_index(form, restindex)
        if nx_string(player_name) ~= "" then
          local tiny_single = util_get_form(FORM_SINGLE_TINY, true, true, nx_string(player_name))
          if nx_is_valid(tiny_single) then
            tiny_single.player_name = nx_widestr(get_name_for_index(form, restindex))
            tiny_single.AbsLeft = btn.DragCenterX
            tiny_single.AbsTop = btn.DragCenterY
            util_show_form(FORM_SINGLE_TINY, true, nx_string(player_name))
          end
        end
      end
    elseif is_team_captain() then
      to_change(form, nx_number(restindex), nx_number(destindex))
    end
  end
end
function to_change(form, restindex, destindex)
  local mem0 = destindex - 11
  local mem1 = restindex - 11
  local target0 = get_name_for_index(form, destindex)
  local target1 = get_name_for_index(form, restindex)
  if nx_int(mem0) == nx_int(mem1) then
    set_buttonback_on(form, -1)
    form.lastSelectIndex = -1
    return
  end
  change_Member_Info(form, SET_MEMBER_POSITION, nx_int(mem0), target1)
  change_Member_Info(form, SET_MEMBER_POSITION, nx_int(mem1), target0)
  form.lastSelectIndex = destindex
  set_buttonback_on(form, form.lastSelectIndex)
end
function get_all_info_for_index(form, index)
  local pos = nx_int(index / 10)
  local groupbox = form:Find(gb_name .. nx_string(nx_int(pos)))
  if not nx_is_valid(groupbox) then
    return nx_widestr("")
  end
  local mbbox = groupbox:Find(gb_mb .. nx_string(index))
  if not nx_is_valid(mbbox) then
    return nx_widestr("")
  end
  local name = mbbox:Find(label_name .. nx_string(index))
  if not nx_is_valid(name) then
    return nx_widestr("")
  end
  local nameStr = name.Text
  local voimg = mbbox:Find(vo_name .. nx_string(index))
  if not nx_is_valid(voimg) then
    return nx_widestr("")
  end
  local voStr = nx_string(voimg.BackImage)
  local vcimg = mbbox:Find(vc_name .. nx_string(index))
  if not nx_is_valid(vcimg) then
    return nx_widestr("")
  end
  local vcStr = nx_string(vcimg.BackImage)
  local info = mbbox:Find(vo_zy .. nx_string(index))
  if not nx_is_valid(info) then
    return nx_widestr("")
  end
  local infoStr = info.Text
  if nx_widestr(nameStr) == nx_widestr("") and nx_widestr(voStr) == nx_widestr("") and nx_widestr(vcStr) == nx_widestr("") and nx_widestr(infoStr) == nx_widestr("") then
    return nx_widestr("")
  end
  return nx_widestr(nameStr) .. nx_widestr(",") .. nx_widestr(voStr) .. nx_widestr(",") .. nx_widestr(vcStr) .. nx_widestr(",") .. nx_widestr(infoStr)
end
function on_btn_quality_setup_click(btn)
  local form = nx_value(FORM_TEAM_RECRUIT)
  if not nx_is_valid(form.quality_page) then
    return
  end
  form.quality_page.AbsLeft = btn.AbsLeft - form.quality_page.Width
  form.quality_page.AbsTop = btn.AbsTop - form.quality_page.Height
  if form.quality_page.Visible then
    form.quality_page.Visible = false
  else
    form.quality_page.Visible = true
    form:ToFront(form.quality_page)
    nx_execute(FORM_QUALITY, "refresh_form", form.quality_page)
  end
end
function recover_all_status(form)
  recover_select_status(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  if 0 < item_row_num then
    for i = 0, item_row_num - 1 do
      local playername = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
      local leveltitle = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_LEVELTITLE)
      local playerpos = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMPOSITION)
      local playerwork = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMWORK)
      local OffLinetime = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_ISOFFLINE)
      local Camp = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CAMP)
      if playername == nil or leveltitle == nil or playerpos == nil or playerwork == nil or leveltitle == nil or OffLinetime == nil or Camp == nil then
        return
      end
      set_player_color(form, playername, playerpos, playerwork, leveltitle, OffLinetime, Camp)
    end
  end
end
function recover_select_status(form)
  if not nx_is_valid(form) then
    return
  end
  form.lastSelectIndex = -1
  for i = 1, form.MaxNumOfTeam do
    local superBox = form:Find(gb_name .. nx_string(i))
    if nx_is_valid(superBox) then
      for j = 1, form.MaxSmallNumOfMember do
        local groupbox = superBox:Find(gb_mb .. nx_string(i) .. nx_string(j))
        if nx_is_valid(groupbox) then
          groupbox.BackImage = nx_find_custom(groupbox, "back_image") and groupbox.back_image or ""
        end
      end
    end
  end
end
function set_player_color(form, playername, playerpos, playerwork, leveltitle, isOffLine, Camp)
  playerpos = playerpos + 11
  local pos = nx_int(playerpos) / nx_int(10)
  local groupbox = form:Find(gb_name .. nx_string(nx_int(pos)))
  if not nx_is_valid(groupbox) then
    return
  end
  local mbbox = groupbox:Find(gb_mb .. nx_string(playerpos))
  if not nx_is_valid(mbbox) then
    return
  end
  local lblMemberName = mbbox:Find(label_name .. nx_string(playerpos))
  if not nx_is_valid(lblMemberName) then
    return
  end
  local label_powerlevel = mbbox:Find(vo_zy .. nx_string(playerpos))
  if not nx_is_valid(label_powerlevel) then
    return
  end
  if nx_number(isOffLine) > nx_number(0) then
    lblMemberName.ForeColor = Offline_Color
    label_powerlevel.ForeColor = Offline_Color
  else
    lblMemberName.ForeColor = PlayerName_Color
    label_powerlevel.ForeColor = PowerLevel_Color
  end
end
function adjust_grid_style(form)
  form.lbl_select1.Visible = false
  form.lbl_select2.Visible = false
  for i = 1, form.MaxNumOfTeam do
    local group_team = form:Find(gb_name .. nx_string(i))
    if nx_is_valid(group_team) then
      for j = 1, form.MaxSmallNumOfMember do
        local group_single = group_team:Find(gb_mb .. nx_string(i) .. nx_string(j))
        if nx_is_valid(group_single) then
          group_single.back_image = group_single.BackImage
        end
      end
    end
  end
end
function is_team_captain_by_name(name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local TeamCaptain = client_player:QueryProp("TeamCaptain")
  if nx_ws_equal(nx_widestr(TeamCaptain), nx_widestr(name)) then
    return true
  else
    return false
  end
end
function is_in_rect(Left, Top, Width, Height, x, y)
  if x > Left + Width then
    return false
  end
  if x < Left then
    return false
  end
  if y < Top then
    return false
  end
  if y > Top + Height then
    return false
  end
  return true
end
function is_show_team_page()
  local form = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form) then
    return form.Visible
  end
  return false
end
