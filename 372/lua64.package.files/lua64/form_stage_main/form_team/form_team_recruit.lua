require("util_gui")
require("share\\client_custom_define")
require("share\\view_define")
require("define\\request_type")
require("define\\player_name_color_define")
require("define\\team_rec_define")
require("form_stage_main\\form_team\\team_util_functions")
require("form_stage_main\\form_relation\\relation_define")
local FORM_TEAM_RECRUIT = "form_stage_main\\form_team\\form_team_recruit"
local FORM_TEAM_LARGE_RECRUIT = "form_stage_main\\form_team\\form_team_large_recruit"
local FORM_RECRUIT = "form_stage_main\\form_team\\form_recruit"
local FORM_QUALITY = "form_stage_main\\form_team\\form_quality"
local FORM_NEARBY = "form_stage_main\\form_team\\form_team_nearbyex"
local TEAM_REC = "team_rec"
local label_name = "Label_name"
local label_level = "Label_level"
local label_scene = "Label_job"
local label_school = "Label_school"
local pic_head = "Picture_head"
local group_box = "GroupBox"
local label_fp = "Label_fp"
local button_invate = "Button_invite"
local select_img = "gui\\special\\team\\team_select1.png"
local schoolimage = {
  school_shaolin = "gui\\special\\team_head\\head_shaolin.png",
  school_wudang = "gui\\special\\team_head\\head_wudang.png",
  school_gaibang = "gui\\special\\team_head\\head_gaibang.png",
  school_tangmen = "gui\\special\\team_head\\head_tangmen.png",
  school_emei = "gui\\special\\team_head\\head_emei.png",
  school_jinyiwei = "gui\\special\\team_head\\head_jinyi.png",
  school_jilegu = "gui\\special\\team_head\\head_jile.png",
  school_junzitang = "gui\\special\\team_head\\head_junzitang.png",
  school_mingjiao = "gui\\special\\team_head\\head_mingjiao.png",
  school_tianshan = "gui\\special\\team_head\\head_tianshan.png",
  ui_None = "gui\\special\\team_head\\head_jianghu.png"
}
local shaneimage = {
  [0] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_chu.png",
  [1] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xia.png",
  [2] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_e.png",
  [3] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_kuang.png",
  [4] = "gui\\language\\ChineseS\\sns_new\\mark\\mark_xie.png"
}
local CurMemberIndex = -1
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
  nx_function("ext_trace_log", info)
end
function auto_show_hide_team()
  local form = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form) then
    form:Close()
  else
    if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") then
      return
    end
    if nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") then
      return
    end
    if nx_execute("form_stage_main\\form_night_forever\\form_fin_main", "is_in_flee_in_night") then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_fin_023"))
      return
    end
    nx_execute("util_gui", "util_auto_show_hide_form", FORM_TEAM_RECRUIT)
  end
  local form = nx_value(FORM_TEAM_RECRUIT)
  ui_show_attached_form(form)
end
function reset_scene()
  local bVisible = false
  local form = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form) then
    bVisible = form.Visible
    form:Close()
  else
    bVisible = false
  end
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_TEAM_RECRUIT)
  form = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form) then
    form.Visible = bVisible
    form.team_type = get_team_type()
    if form.team_type == -1 then
      form.team_type = TYPE_NORAML_TEAM
    end
    if bVisible and form.team_type == TYPE_LARGE_TEAM then
      form.large_team_page.Visible = true
    else
      form.large_team_page.Visible = false
    end
    form.recruit_page.Visible = false
    form.quality_page.Visible = false
  end
end
function refresh_form(form)
  if nx_is_valid(form) then
    on_refresh_team_grid(form)
    disp_team_pick_mode(form)
    clear_selected_flag(form)
  end
end
function main_form_init(self)
  self.Fixed = false
  self.recruit_page = nil
  self.large_team_page = nil
  self.MaxNumOfMember = 6
  self.team_type = TYPE_NORAML_TEAM
end
function main_form_open(self)
  load_nearby_page(self)
  load_recruit_page(self)
  load_large_team_page(self)
  load_quality_page(self)
  data_bind_prop(self)
  init_form(self)
  refresh_form(self)
  hide_school(self)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  del_data_bind_prop(form)
  if nx_find_custom(form, "nearby_page") and nx_is_valid(form.nearby_page) then
    form.nearby_page:Close()
  end
  if nx_find_custom(form, "recruit_page") and nx_is_valid(form.recruit_page) then
    form.recruit_page:Close()
  end
  if nx_find_custom(form, "large_team_page") and nx_is_valid(form.large_team_page) then
    form.large_team_page:Close()
  end
  if nx_find_custom(form, "quality_page") and nx_is_valid(form.quality_page) then
    form.quality_page:Close()
  end
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, self, nx_current(), "on_table_operat")
    databinder:AddRolePropertyBind("TeamPickMode", "int", self, nx_current(), "disp_team_pick_mode")
    databinder:AddRolePropertyBind("TeamType", "int", self, nx_current(), "on_TeamType_Change")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", self, nx_current(), "on_TeamCaptain_Change")
  end
end
function del_data_bind_prop(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(TEAM_REC, self)
    databinder:DelRolePropertyBind("TeamPickMode", self)
    databinder:DelRolePropertyBind("TeamCaptain", self)
    databinder:DelRolePropertyBind("TeamType", self)
  end
end
function init_form(form)
  form:ToBack(form.lbl_bg_form)
  set_groupbox_nearlist_visible(false)
  form.lbl_shanelogo.Visible = false
  form.gb_self_shan_e.Visible = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.teamgridselectedIndex = -1
  nx_execute(FORM_NEARBY, "refresh_form", nx_value(FORM_NEARBY))
  show_cur_page(form)
end
function load_nearby_page(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  local team_type = client_player:QueryProp("TeamType")
  local nearby_page = nx_execute("util_gui", "util_get_form", FORM_NEARBY, true, false)
  local is_load = false
  if team_type == TYPE_NORAML_TEAM then
    is_load = self.groupbox_nearby:Add(nearby_page)
    nx_execute(FORM_NEARBY, "set_use_mode", TYPE_NORAML_TEAM)
  elseif team_type == TYPE_LARGE_TEAM then
    is_load = self.groupbox_nearby2:Add(nearby_page)
    nx_execute(FORM_NEARBY, "set_use_mode", TYPE_LARGE_TEAM)
  end
  if is_load == true then
    self.nearby_page = nearby_page
    self.nearby_page.Left = 0
    self.nearby_page.Top = 0
    self.nearby_page.Visible = true
  end
  return nearby_page
end
function transfer_nearby_page()
  local form = nx_value(FORM_TEAM_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "nearby_page") and nx_is_valid(form.nearby_page) then
    form.groupbox_nearby2:Remove(form.nearby_page)
    form.groupbox_nearby:Remove(form.nearby_page)
    form.nearby_page = nil
  end
  load_nearby_page(form)
end
function load_recruit_page(self)
  local recruit_page = nx_execute("util_gui", "util_get_form", FORM_RECRUIT, true, false)
  local is_load = self.groupbox_main:Add(recruit_page)
  if is_load == true then
    self.recruit_page = recruit_page
    self.recruit_page.Left = 8
    self.recruit_page.Top = 62
  end
  self.recruit_page.Visible = false
  return recruit_page
end
function load_large_team_page(self)
  local large_team_page = nx_execute("util_gui", "util_get_form", FORM_TEAM_LARGE_RECRUIT, true, false)
  local is_load = self.groupbox_main:Add(large_team_page)
  if is_load == true then
    self.large_team_page = large_team_page
    self.large_team_page.Left = 7
    self.large_team_page.Top = 22
  end
  self.large_team_page.Visible = false
  return large_team_page
end
function load_quality_page(self)
  local quality_page = nx_execute("util_gui", "util_get_form", FORM_QUALITY, true, false)
  local is_load = self.groupbox_main:Add(quality_page)
  if is_load == true then
    self.quality_page = quality_page
    self.quality_page.Left = 0
    self.quality_page.Top = 0
  end
  self.quality_page.Visible = false
  return quality_page
end
function on_table_operat(self, tablename, ttype, line, col)
  if not self.Visible then
    return
  end
  if self.Down_GroupBox.Visible == true then
    if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_SCENE or col == TEAM_REC_COL_POWERLEVEL or col == TEAM_REC_COL_CAMP or col == TEAM_REC_COL_LEVELTITLE or col == TEAM_REC_COL_SCHOOL or col == TEAM_REC_COL_CHARACTERFLAG or col == TEAM_REC_COL_CHARACTERVALUE then
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
function on_TeamCaptain_Change(self)
  if not self.Visible then
    return
  end
  local captain_name = get_team_captain_name()
  if nx_ws_length(nx_widestr(captain_name)) < 1 then
    set_quality_page_visible(self, false)
  end
  refresh_team_grid(self)
  disp_team_pick_mode(self)
end
function on_TeamType_Change(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local team_type = client_player:QueryProp("TeamType")
  self.groupbox_nearby.Visible = team_type ~= TYPE_LARGE_TEAM and not self.recruit_page.Visible
  transfer_nearby_page()
  if not self.Visible then
    return
  end
  if not nx_is_valid(self.recruit_page) or not nx_is_valid(self.large_team_page) then
    return
  end
  if team_type == TYPE_NORAML_TEAM then
    self.Down_GroupBox.Visible = not self.recruit_page.Visible
    self.rbtn_tagteam.Text = nx_widestr("@ui_zudui0018")
    set_groupbox_nearby_layer(true)
    self.large_team_page.Visible = false
  elseif team_type == TYPE_LARGE_TEAM then
    self.Down_GroupBox.Visible = false
    self.rbtn_tagteam.Text = nx_widestr("@ui_zudui0039")
    set_groupbox_nearby_layer(false)
    self.large_team_page.Visible = not self.recruit_page.Visible
    nx_execute(FORM_TEAM_LARGE_RECRUIT, "refresh_form", nx_value(FORM_TEAM_LARGE_RECRUIT))
  end
  nx_execute(FORM_NEARBY, "refresh_grid")
  set_groupbox_nearlist_visible(false)
  set_quality_page_visible(self, false)
  self.team_type = team_type
  on_gui_size_change()
end
function clear_team_grid(self)
  local groupform = self.Down_GroupBox
  local groupbox = groupform:Find(group_box .. nx_string(1))
  local captaintag = groupbox:Find("Label_capital_flag")
  if nx_is_valid(captaintag) then
    captaintag.Visible = false
  end
  for j = 1, self.MaxNumOfMember do
    local groupbox = groupform:Find(group_box .. nx_string(j))
    local labelname = groupbox:Find(label_name .. nx_string(j))
    local labelorigin = groupbox:Find(label_level .. nx_string(j))
    local labelscene = groupbox:Find(label_scene .. nx_string(j))
    local picturehead = groupbox:Find(pic_head .. nx_string(j))
    local fpname = groupbox:Find(label_fp .. nx_string(j))
    local labelschool = groupbox:Find(label_school .. nx_string(j))
    local btn_invate = groupbox:Find(button_invate .. nx_string(j))
    labelname.Text = nx_widestr("")
    labelorigin.Text = nx_widestr("")
    labelscene.Text = nx_widestr("")
    labelschool.Text = nx_widestr("")
    picturehead.Image = ""
    fpname.Text = nx_widestr("")
    if is_in_team() then
      groupbox.BackImage = "gui\\map\\mapn\\select_down.png"
    else
      groupbox.BackImage = ""
    end
    btn_invate.Visible = false
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
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  local gui = nx_value("gui")
  local groupform = self.Down_GroupBox
  local maxcharvalue = -1
  local teamflag = 0
  local captainname = client_player:QueryProp("TeamCaptain")
  if 0 < item_row_num then
    local groupbox = groupform:Find(group_box .. nx_string(1))
    local captaintag = groupbox:Find("Label_capital_flag")
    if nx_is_valid(captaintag) then
      captaintag.Visible = true
    end
    local index = 2
    for i = 0, item_row_num - 1 do
      local playername = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
      local sceneid = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_SCENE)
      local FP = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_LEVELTITLE)
      local Camp = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CAMP)
      local school = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_SCHOOL)
      local charflag = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CHARACTERFLAG)
      local charvalue = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_CHARACTERVALUE)
      if nx_int(maxcharvalue) < nx_int(charvalue) then
        maxcharvalue = charvalue
        teamflag = charflag
      end
      if not nx_ws_equal(nx_widestr(captainname), nx_widestr(playername)) then
        show_member(groupform, index, playername, sceneid, school, FP, Camp)
        index = index + 1
      else
        show_member(groupform, 1, playername, sceneid, school, FP, Camp)
      end
    end
    if is_team_captain() and item_row_num < self.MaxNumOfMember then
      local groupbox2 = groupform:Find(group_box .. nx_string(item_row_num + 1))
      local btn_invate = groupbox2:Find(button_invate .. nx_string(item_row_num + 1))
      if nx_is_valid(btn_invate) then
        btn_invate.Visible = true
      end
    end
  else
    self.Button_back1.BackImage = ""
    self.Button_back2.BackImage = ""
    self.Button_back3.BackImage = ""
    self.Button_back4.BackImage = ""
    self.Button_back5.BackImage = ""
    self.Button_back6.BackImage = ""
  end
  if nx_int(teamflag) < nx_int(0) or nx_int(teamflag) > nx_int(4) or item_row_num <= 0 then
    self.lbl_shanelogo.BackImage = ""
    self.lbl_shanelogo.charflag = 0
    self.lbl_shanelogo.charvalue = -1
    self.lbl_shanelogo.Visible = false
  else
    self.lbl_shanelogo.BackImage = shaneimage[nx_number(teamflag)]
    self.lbl_shanelogo.charflag = teamflag
    self.lbl_shanelogo.charvalue = maxcharvalue
    self.lbl_shanelogo.Visible = true
  end
  update_limit_btns(self)
  if item_row_num <= 0 then
    self.btn_create_team.Enabled = true
    self.btn_create_team.Visible = true
    self.btn_leave_team.Enabled = false
    self.btn_leave_team.Visible = false
  else
    self.btn_create_team.Enabled = false
    self.btn_create_team.Visible = false
    self.btn_leave_team.Enabled = true
    self.btn_leave_team.Visible = true
  end
end
function update_limit_btns(self)
  if is_team_captain() then
    self.btn_create_team.Enabled = false
    self.btn_remove_member.Enabled = true
    self.btn_give_capital.Enabled = true
    self.btn_disbuild_team.Enabled = true
    self.btn_change_teamtype.Enabled = true
  else
    self.btn_create_team.Enabled = false
    self.btn_remove_member.Enabled = false
    self.btn_give_capital.Enabled = false
    self.btn_disbuild_team.Enabled = false
    self.btn_change_teamtype.Enabled = false
  end
end
function show_member(groupform, index, playername, sceneid, school, FP, Camp)
  local from = groupform.ParentForm
  if index <= 0 or index > from.MaxNumOfMember then
    return
  end
  local gui = nx_value("gui")
  local schoolpic = get_school_image(school)
  local groupname = group_box .. nx_string(index)
  local name = label_name .. nx_string(index)
  local lv = label_level .. nx_string(index)
  local lbl_school = label_school .. nx_string(index)
  local job = label_scene .. nx_string(index)
  local pic = pic_head .. nx_string(index)
  local fp = label_fp .. nx_string(index)
  local groupbox = groupform:Find(nx_string(groupname))
  if not nx_is_valid(groupbox) then
    return
  end
  local labelname = groupbox:Find(name)
  local labelorigin = groupbox:Find(lv)
  local labelscene = groupbox:Find(job)
  local labelschool = groupbox:Find(lbl_school)
  local schoolicon = groupbox:Find(pic)
  local label_fp = groupbox:Find(fp)
  local scenename = gui.TextManager:GetText(sceneid)
  local fpVal = gui.TextManager:GetText("desc_" .. nx_string(FP))
  labelname.Text = nx_widestr(playername)
  labelscene.Text = nx_widestr(scenename)
  local ini = nx_execute("util_functions", "get_ini", "ini\\form_main_player.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section = ini:FindSectionIndex("school_name")
  if section < 0 then
    return
  end
  local school_image = ini:ReadString(section, school, "")
  labelschool.BackImage = school_image
  if nx_string(school) ~= nx_string("") and school ~= nil then
    labelschool.HintText = nx_widestr(gui.TextManager:GetFormatText(nx_string(school)))
  else
    labelschool.HintText = nx_widestr(gui.TextManager:GetText("ui_none"))
  end
  label_fp.Text = nx_widestr(fpVal)
  schoolicon.Image = schoolpic
  local captaintag = groupbox:Find("Label_capital_flag")
  if nx_is_valid(captaintag) then
    captaintag.Left = labelname.Left + labelname.TextWidth
  end
end
function on_lbl_shanelogo_get_capture(label)
  show_self_shane_info(label, label.charflag, label.charvalue)
end
function on_lbl_shanelogo_lost_capture(label)
  local form = label.ParentForm
  form.gb_self_shan_e.Visible = false
end
function on_Button_invite_click(btn)
  local gui = nx_value("gui")
  set_quality_page_visible(btn.ParentForm, false)
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
  if nx_ws_length(new_name) < 1 then
    disp_error("name is empty")
    return 0
  end
  nx_execute("custom_sender", "custom_team_invite", new_name)
end
function on_fireTeam_click(btn)
  local form = btn.ParentForm
  local index = form.teamgridselectedIndex
  set_quality_page_visible(form, false)
  if index < 0 then
    return 1
  end
  local groupform = form.Down_GroupBox
  local groupname = group_box .. nx_string(index)
  local name = label_name .. nx_string(index)
  local groupbox = groupform:Find(nx_string(groupname))
  local labelname = groupbox:Find(name)
  nx_execute("custom_sender", "custom_kickout_team", labelname.Text)
end
function on_change_teamtype_click(btn)
  nx_execute("custom_sender", "custom_change_team_type", nx_int(1))
end
function on_changeCaptain_click(btn)
  local form = btn.ParentForm
  local index = form.teamgridselectedIndex
  set_quality_page_visible(form, false)
  if index < 0 then
    return 1
  end
  local groupform = form.Down_GroupBox
  local groupname = group_box .. nx_string(index)
  local name = label_name .. nx_string(index)
  local groupbox = groupform:Find(nx_string(groupname))
  local labelname = groupbox:Find(name)
  nx_execute("custom_sender", "custom_caption_change", labelname.Text)
end
function on_disbandTeam_click(btn)
  set_quality_page_visible(btn.ParentForm, false)
  nx_execute("custom_sender", "custom_team_destroy")
end
function on_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  nx_execute("custom_sender", "custom_team_player_close")
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    auto_show_hide_team()
  else
    form.is_help = false
    nx_execute("form_stage_main\\form_helper\\form_move_win", "util_open_move_win", form.AbsLeft, form.AbsTop, form.Width, form.Height, "", "open_form_friend,btn_friend")
    auto_show_hide_team()
  end
  return 1
end
function on_btn_hide_click(btn)
  set_groupbox_nearlist_visible(false)
end
function on_rbtn_tagteam_checked_changed(btn)
  show_cur_page(btn.ParentForm)
  set_quality_page_visible(btn.ParentForm, false)
  local team_type = get_team_type()
  if nx_int(team_type) == nx_int(0) or nx_int(team_type) == nx_int(-1) then
    refresh_form(btn.ParentForm)
  elseif nx_int(team_type) == nx_int(1) then
    nx_execute(FORM_TEAM_LARGE_RECRUIT, "refresh_form", nx_value(FORM_TEAM_LARGE_RECRUIT))
  end
end
function on_rbtn_tagunite_checked_changed(btn)
  show_cur_page(btn.ParentForm)
  set_quality_page_visible(btn.ParentForm, false)
  nx_execute(FORM_RECRUIT, "refresh_form", nx_value(FORM_RECRUIT))
end
function show_cur_page(self)
  if not nx_is_valid(self.recruit_page) or not nx_is_valid(self.large_team_page) then
    return
  end
  if self.rbtn_tagteam.Checked == true then
    self:ToBack(self.lbl_bg_form)
    if self.team_type == TYPE_NORAML_TEAM then
      self.Down_GroupBox.Visible = true
      self.groupbox_nearby.Visible = true
      self.recruit_page.Visible = false
      self.large_team_page.Visible = false
    else
      self.Down_GroupBox.Visible = false
      self.recruit_page.Visible = false
      self.large_team_page.Visible = true
    end
    set_groupbox_nearby_layer(true)
    nx_execute("custom_sender", "custom_team_player_close")
  elseif self.rbtn_tagunite.Checked == true then
    self:ToBack(self.lbl_bg_form)
    self.Down_GroupBox.Visible = false
    self.groupbox_nearby.Visible = false
    self.recruit_page.Visible = true
    self.large_team_page.Visible = false
    set_groupbox_nearby_layer(false)
    nx_execute("custom_sender", "custom_team_player_open")
  end
end
function picture_on_click(self)
  local index = nx_number(self.DataSource)
  local form = self.ParentForm
  set_quality_page_visible(form, false)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_row_num = client_player:GetRecordRows(TEAM_REC)
  local curindex = string.sub(nx_string(self.Name), -1, -1)
  if nx_int(curindex) > nx_int(item_row_num) then
    return
  end
  if index ~= CurMemberIndex then
    if nx_int(index) == nx_int(1) then
      form.Button_back1.BackImage = select_img
      form.Button_back2.BackImage = ""
      form.Button_back3.BackImage = ""
      form.Button_back4.BackImage = ""
      form.Button_back5.BackImage = ""
      form.Button_back6.BackImage = ""
    elseif nx_int(index) == nx_int(2) then
      form.Button_back1.BackImage = ""
      form.Button_back2.BackImage = select_img
      form.Button_back3.BackImage = ""
      form.Button_back4.BackImage = ""
      form.Button_back5.BackImage = ""
      form.Button_back6.BackImage = ""
    elseif nx_int(index) == nx_int(3) then
      form.Button_back1.BackImage = ""
      form.Button_back2.BackImage = ""
      form.Button_back3.BackImage = select_img
      form.Button_back4.BackImage = ""
      form.Button_back5.BackImage = ""
      form.Button_back6.BackImage = ""
    elseif nx_int(index) == nx_int(4) then
      form.Button_back1.BackImage = ""
      form.Button_back2.BackImage = ""
      form.Button_back3.BackImage = ""
      form.Button_back4.BackImage = select_img
      form.Button_back5.BackImage = ""
      form.Button_back6.BackImage = ""
    elseif nx_int(index) == nx_int(5) then
      form.Button_back1.BackImage = ""
      form.Button_back2.BackImage = ""
      form.Button_back3.BackImage = ""
      form.Button_back4.BackImage = ""
      form.Button_back5.BackImage = select_img
      form.Button_back6.BackImage = ""
    elseif nx_int(index) == nx_int(6) then
      form.Button_back1.BackImage = ""
      form.Button_back2.BackImage = ""
      form.Button_back3.BackImage = ""
      form.Button_back4.BackImage = ""
      form.Button_back5.BackImage = ""
      form.Button_back6.BackImage = select_img
    end
    form.teamgridselectedIndex = nx_int(index)
    CurMemberIndex = nx_int(index)
  end
  return 1
end
function picture_mouse_on(self)
  local index = nx_number(self.DataSource)
  local form = self.ParentForm
  if index == CurMemberIndex or index == 1 then
  elseif index == 2 then
  elseif index == 3 then
  elseif index == 4 then
  elseif index == 5 then
  elseif index == 6 then
  end
  return 1
end
function picture_mouse_leave(self)
  local index = nx_number(self.DataSource)
  local form = self.ParentForm
  if nx_int(index) ~= nx_int(CurMemberIndex) then
    if index == 1 then
      form.Button_back1.BackImage = ""
    elseif index == 2 then
      form.Button_back2.BackImage = ""
    elseif index == 3 then
      form.Button_back3.BackImage = ""
    elseif index == 4 then
      form.Button_back4.BackImage = ""
    elseif index == 5 then
      form.Button_back5.BackImage = ""
    elseif index == 6 then
      form.Button_back6.BackImage = ""
    end
  end
  return 1
end
function clear_selected_flag(form)
  CurMemberIndex = -1
  form.Button_back1.BackImage = ""
  form.Button_back2.BackImage = ""
  form.Button_back3.BackImage = ""
  form.Button_back4.BackImage = ""
  form.Button_back5.BackImage = ""
  form.Button_back6.BackImage = ""
end
function on_createteam_click(btn)
  nx_execute("custom_sender", "custom_team_create")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_leaveTeam_click(btn)
  nx_execute("custom_sender", "custom_leave_team")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function reset_pick_mode(self)
  local timer = nx_value("timer_game")
  self.quality_page.Visible = false
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
function team_alloc_leader_click(btn)
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
end
function get_school_image(school)
  if school == nil or nx_string(school) == nx_string("") then
    school = "ui_None"
  end
  local pic = schoolimage[school]
  if pic == nil then
    return schoolimage.ui_None
  end
  return pic
end
function on_btn_quality_setup_click(self)
  local form = util_get_form(FORM_TEAM_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "quality_page") then
    return
  end
  if not nx_is_valid(form.quality_page) then
    return
  end
  form.quality_page.AbsLeft = self.AbsLeft - form.quality_page.Width
  form.quality_page.AbsTop = self.AbsTop - form.quality_page.Height
  if form.quality_page.Visible then
    form.quality_page.Visible = false
  else
    form.quality_page.Visible = true
    form:ToFront(form.quality_page)
    nx_execute(FORM_QUALITY, "refresh_form", form.quality_page)
  end
end
function set_groupbox_nearlist_visible(bVisible)
  local form = nx_value(FORM_TEAM_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  if bVisible then
    form.groupbox_nearlist.Left = 0
    form.groupbox_nearlist.Top = 0
    form.groupbox_main.Left = form.groupbox_nearlist.Left + form.groupbox_nearlist.Width
    form.groupbox_main.Top = 0
    form.Width = form.groupbox_nearlist.Width + form.groupbox_main.Width
  else
    form.groupbox_main.Left = 0
    form.groupbox_main.Top = 0
    form.Width = form.groupbox_main.Width
  end
  form.groupbox_nearlist.Visible = bVisible
end
function set_groupbox_nearby_layer(bFront)
  local form = nx_value(FORM_TEAM_RECRUIT)
  if nx_is_valid(form) then
    if bFront then
      form:ToFront(form.groupbox_nearby)
      form:ToFront(form.lbl_linebottom)
    else
      form:ToBack(form.groupbox_nearby)
      form:ToBack(form.lbl_linebottom)
    end
    form:ToFront(form.lbl_tagback)
    form:ToFront(form.rbtn_tagteam)
    form:ToFront(form.rbtn_tagunite)
  end
end
function set_quality_page_visible(form, bVisible)
  if nx_find_custom(form, "quality_page") and nx_is_valid(form.quality_page) then
    form.quality_page.Visible = bVisible
  end
end
function on_gui_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function show_self_shane_info(control, CharacterFlag, CharacterValue)
  local form = nx_value(FORM_TEAM_RECRUIT)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_xie.Top = 28
  form.lbl_xie.Left = 32
  form.lbl_kuang.Top = 28
  form.lbl_kuang.Left = 64
  if CharacterFlag == 0 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
  elseif CharacterFlag == 1 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xia.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = true
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_colour.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xia_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 2 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_e.png"
    form.lbl_e_bar.Visible = true
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_colour.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_e_bar.Height = nx_number(30 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 3 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_kuang.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = false
    form.lbl_kuang_bar.Visible = true
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_bai.png"
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_colour.png"
    form.lbl_kuang.Top = 8
    form.lbl_kuang.Left = 48
    form.lbl_xie.Top = 28
    form.lbl_xie.Left = 32
    form.lbl_kuang_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_kuang_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  elseif CharacterFlag == 4 then
    form.gb_sanjiao.BackImage = "gui\\special\\sns_new\\triangle_mark\\triangle_xie.png"
    form.lbl_e_bar.Visible = false
    form.lbl_xia_bar.Visible = false
    form.lbl_xie_bar.Visible = true
    form.lbl_kuang_bar.Visible = false
    form.lbl_e.BackImage = "gui\\special\\sns_new\\triangle_mark\\e_bai.png"
    form.lbl_xia.BackImage = "gui\\special\\sns_new\\triangle_mark\\xia_bai.png"
    form.lbl_xie.BackImage = "gui\\special\\sns_new\\triangle_mark\\xie_colour.png"
    form.lbl_xie.Top = 8
    form.lbl_xie.Left = 48
    form.lbl_kuang.Top = 28
    form.lbl_kuang.Left = 64
    form.lbl_kuang.BackImage = "gui\\special\\sns_new\\triangle_mark\\kuang_bai.png"
    form.lbl_xie_bar.Height = nx_number(60 / MaxCharacterValue * CharacterValue)
    form.lbl_xie_bar.Top = 60 - nx_number(60 / MaxCharacterValue * CharacterValue)
  end
  form.groupbox_main:ToFront(form.gb_self_shan_e)
  local left = control.AbsLeft - form.Left + 20
  if left + form.gb_self_shan_e.Width > form.groupbox_main.Width then
    left = control.AbsLeft - form.Left - form.gb_self_shan_e.Width - 5
  end
  local top = control.AbsTop - form.Top
  if top + form.gb_self_shan_e.Height > form.groupbox_main.Height then
    top = control.AbsTop - form.Top - form.gb_self_shan_e.Height
  end
  form.gb_self_shan_e.Left = left
  form.gb_self_shan_e.Top = top
  form.gb_self_shan_e.Visible = true
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function hide_school(form)
  if not nx_is_valid(form) then
    return
  end
  local flag = nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
  if not flag then
    return
  end
  local parent_gbox = form.Down_GroupBox
  if not nx_is_valid(parent_gbox) then
    return
  end
  for i = 1, 6 do
    local gbox_name = "GroupBox" .. nx_string(i)
    local gbox = parent_gbox:Find(gbox_name)
    if nx_is_valid(gbox) then
      local lbl_name = "Label_school" .. nx_string(i)
      local lbl = gbox:Find(lbl_name)
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
    end
  end
end
