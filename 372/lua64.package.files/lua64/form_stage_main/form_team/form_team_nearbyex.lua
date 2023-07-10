require("util_gui")
require("share\\client_custom_define")
require("define\\team_rec_define")
require("share\\logicstate_define")
require("form_stage_main\\form_team\\team_util_functions")
local FORM_TEAM_RECRUIT = "form_stage_main\\form_team\\form_team_recruit"
local FORM_TEAM_NEARBY = "form_stage_main\\form_team\\form_team_nearbyex"
local fold_normalimage = "gui\\common\\button\\btn_maximum_out.png"
local fold_focusimage = "gui\\common\\button\\btn_maximum_on.png"
local fold_pushimage = "gui\\common\\button\\btn_maximum_down.png"
local unfold_normalimage = "gui\\common\\button\\btn_minimum_out.png"
local unfold_focusimage = "gui\\common\\button\\btn_minimum_on.png"
local unfold_pushimage = "gui\\common\\button\\btn_minimum_down.png"
local TYPE_CAPTAIN = 0
local TYPE_NORMAL = 1
local FOLD_NONE = 0
local FOLD_CAPTAIN = 1
local FOLD_NORMAL = 2
local FOLD_ALL = 3
local STATE_ALREADY_ENTER = 3
local NearPlayerList = {}
local Cur_Fold_Type = FOLD_NONE
local Cur_Selected_Playername = ""
function refresh_form(form)
  if nx_is_valid(form) then
    Cur_Fold_Type = FOLD_NONE
    reset_team_btn()
    refresh_nearplayer_grid(Cur_Fold_Type)
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.groupbox_mark.Visible = false
  form.groupbox_item.Visible = false
  refresh_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_click_refresh(btn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  reset_team_btn()
  refresh_nearplayer_grid(Cur_Fold_Type)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_ext_click(btn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  local mark = btn.Parent
  if mark.bind_type == TYPE_CAPTAIN then
    if Cur_Fold_Type == FOLD_ALL then
      Cur_Fold_Type = FOLD_NORMAL
      mark.is_fold = false
    elseif Cur_Fold_Type == FOLD_NORMAL then
      Cur_Fold_Type = FOLD_ALL
      mark.is_fold = true
    elseif Cur_Fold_Type == FOLD_CAPTAIN then
      Cur_Fold_Type = FOLD_NONE
      mark.is_fold = false
    elseif Cur_Fold_Type == FOLD_NONE then
      Cur_Fold_Type = FOLD_CAPTAIN
      mark.is_fold = true
    end
  elseif mark.bind_type == TYPE_NORMAL then
    if Cur_Fold_Type == FOLD_ALL then
      Cur_Fold_Type = FOLD_CAPTAIN
      mark.is_fold = false
    elseif Cur_Fold_Type == FOLD_CAPTAIN then
      Cur_Fold_Type = FOLD_ALL
      mark.is_fold = true
    elseif Cur_Fold_Type == FOLD_NORMAL then
      Cur_Fold_Type = FOLD_NONE
      mark.is_fold = false
    elseif Cur_Fold_Type == FOLD_NONE then
      Cur_Fold_Type = FOLD_NORMAL
      mark.is_fold = true
    end
  end
  btn.NormalImage = mark.is_fold and fold_normalimage or unfold_normalimage
  btn.FocusImage = mark.is_fold and fold_focusimage or unfold_focusimage
  btn.PushImage = mark.is_fold and fold_pushimage or unfold_pushimage
  reset_team_btn()
  update_nearplayer_grid(NearPlayerList, Cur_Fold_Type)
end
function on_select_changed(rbtn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local item = rbtn.Parent
    clear_selected(rbtn)
    disp_team_btn(form, item.bind_type == TYPE_CAPTAIN)
    Cur_Selected_Playername = item.player_name
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_invite_team_click(btn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  if nx_ws_equal(nx_widestr(Cur_Selected_Playername), nx_widestr("")) then
    return
  end
  nx_execute("custom_sender", "custom_team_invite", nx_widestr(Cur_Selected_Playername))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_require_join_click(btn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  if nx_ws_equal(nx_widestr(Cur_Selected_Playername), nx_widestr("")) then
    return
  end
  nx_execute("custom_sender", "custom_team_request_join", nx_widestr(Cur_Selected_Playername))
end
function refresh_grid()
  reset_team_btn()
  refresh_nearplayer_grid(Cur_Fold_Type)
end
function refresh_nearplayer_grid(fold_type)
  NearPlayerList = get_near_player_table()
  update_nearplayer_grid(NearPlayerList, fold_type)
end
function update_nearplayer_grid(player_table, fold_type)
  local gui = nx_value("gui")
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  clear_grid()
  local captain_table = get_near_players(player_table, TYPE_CAPTAIN)
  local captain_mark, captain_item
  if table.getn(captain_table) > 0 then
    captain_mark = GetNewMark(nx_widestr("@ui_wmdw"))
    captain_mark.Left = 4
    captain_mark.Top = 0
    captain_mark.control_type = "mark"
    captain_mark.bind_type = TYPE_CAPTAIN
    captain_mark.is_fold = fold_type == FOLD_CAPTAIN or fold_type == FOLD_ALL
    captain_mark.btn_ext.NormalImage = captain_mark.is_fold and fold_normalimage or unfold_normalimage
    captain_mark.btn_ext.FocusImage = captain_mark.is_fold and fold_focusimage or unfold_focusimage
    captain_mark.btn_ext.PushImage = captain_mark.is_fold and fold_pushimage or unfold_pushimage
    form.groupbox1:Add(captain_mark)
    if not captain_mark.is_fold then
      for i = 1, table.getn(captain_table) do
        local player = captain_table[i]
        local name = nx_widestr(player.name)
        local school = nx_widestr(gui.TextManager:GetText(player.school))
        local levelname = nx_widestr(player.leveltitle)
        local team_type = 0
        local member_count = 0
        if nx_is_valid(player.obj) then
          team_type = player.obj:QueryProp("TeamType")
          member_count = player.obj:QueryProp("TeamMemberCount")
          name = nx_widestr(name) .. nx_widestr("(") .. nx_widestr(member_count) .. nx_widestr("/") .. nx_widestr(team_type == TYPE_NORAML_TEAM and 6 or 48) .. nx_widestr(")")
        end
        captain_item = GetNewItem(team_type == TYPE_LARGE_TEAM and ICON_COLONEL or ICON_CAPTAIN, name, school, levelname)
        captain_item.Left = 4
        captain_item.Top = captain_mark.Top + captain_mark.Height + (i - 1) * captain_item.Height
        captain_item.control_type = "item"
        captain_item.bind_type = TYPE_CAPTAIN
        captain_item.related_mark = captain_mark
        captain_item.player_name = player.name
        captain_item.player_obj = player.obj
        form.groupbox1:Add(captain_item)
      end
    end
  end
  local normal_table = get_near_players(player_table, TYPE_NORMAL)
  local normal_mark, normal_item
  if table.getn(normal_table) > 0 then
    local top = 0
    if nx_is_valid(captain_mark) then
      if captain_mark.is_fold then
        top = captain_mark.Top + captain_mark.Height
      elseif nx_is_valid(captain_item) then
        top = captain_item.Top + captain_item.Height
      else
        top = captain_mark.Top + captain_mark.Height
      end
    end
    normal_mark = GetNewMark(nx_widestr("@ui_wzd"))
    normal_mark.Left = 4
    normal_mark.Top = top
    normal_mark.control_type = "mark"
    normal_mark.bind_type = TYPE_NORMAL
    normal_mark.is_fold = fold_type == FOLD_NORMAL or fold_type == FOLD_ALL
    normal_mark.btn_ext.NormalImage = normal_mark.is_fold and fold_normalimage or unfold_normalimage
    normal_mark.btn_ext.FocusImage = normal_mark.is_fold and fold_focusimage or unfold_focusimage
    normal_mark.btn_ext.PushImage = normal_mark.is_fold and fold_pushimage or unfold_pushimage
    form.groupbox1:Add(normal_mark)
    if not normal_mark.is_fold then
      for i = 1, table.getn(normal_table) do
        local player = normal_table[i]
        local name = nx_widestr(player.name)
        local school = nx_widestr(gui.TextManager:GetText(player.school))
        local levelname = nx_widestr(player.leveltitle)
        normal_item = GetNewItem("", name, school, levelname)
        normal_item.Left = 4
        normal_item.Top = normal_mark.Top + normal_mark.Height + (i - 1) * normal_item.Height
        normal_item.control_type = "item"
        normal_item.bind_type = TYPE_NORMAL
        normal_item.related_mark = normal_mark
        normal_item.player_name = player.name
        normal_item.player_obj = player.obj
        form.groupbox1:Add(normal_item)
      end
    end
  end
end
function get_near_players(player_list, filter_type)
  local player_table = {}
  if filter_type == TYPE_CAPTAIN then
    for i = 1, table.getn(player_list) do
      local player = player_list[i]
      if player.iscaptain and nx_is_valid(player.obj) then
        local teamtype = player.obj:QueryProp("TeamType")
        local member_count = player.obj:QueryProp("TeamMemberCount")
        local isInSBKillBuff = player.obj:QueryProp("InSBKillBuff")
        local max_count = teamtype == TYPE_NORAML_TEAM and 6 or 48
        if member_count < max_count and nx_int(isInSBKillBuff) <= nx_int(0) then
          table.insert(player_table, player)
        end
      end
    end
  else
    for i = 1, table.getn(player_list) do
      local player = player_list[i]
      if not player.isinteam and nx_is_valid(player.obj) then
        local isInSBKillBuff = player.obj:QueryProp("InSBKillBuff")
        if nx_int(isInSBKillBuff) <= nx_int(0) then
          table.insert(player_table, player)
        end
      end
    end
  end
  return player_table
end
function get_near_player_table()
  if nx_execute("form_stage_main\\form_match\\form_banxuan_taolu", "is_match_revenge") then
    return {}
  end
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local game_player = game_client:GetPlayer()
  local my_name = game_player:QueryProp("Name")
  local game_scene = game_client:GetScene()
  local lst_nearplayer = game_scene:GetSceneObjList()
  local is_clone = game_scene:FindProp("SourceID")
  local b_battlefield = game_player:QueryProp("BattlefieldState") == STATE_ALREADY_ENTER
  if b_battlefield then
    return {}
  end
  local pkmode = game_player:QueryProp("PKMode")
  local selfArenaSide = game_player:QueryProp("ArenaSide")
  local player_table = {}
  local count = 0
  for i, near_obj in pairs(lst_nearplayer) do
    local near_player = game_client:GetSceneObj(near_obj.Ident)
    local ret = true
    local arenaSide = near_player:QueryProp("ArenaSide")
    if nx_boolean(is_clone) and nx_number(pkmode) == 3 and nx_number(selfArenaSide) ~= nx_number(arenaSide) then
      ret = false
    end
    local player_name = near_player:QueryProp("Name")
    local player_type = nx_number(near_player:QueryProp("Type"))
    if nx_int(player_type) == nx_int(2) and nx_boolean(ret) and not nx_ws_equal(nx_widestr(my_name), nx_widestr(player_name)) and not is_player_offline(near_player) then
      count = count + 1
      player_table[count] = {}
      player_table[count].obj = near_player
      player_table[count].name = player_name
      player_table[count].powerlevel = nx_number(near_player:QueryProp("PowerLevel"))
      player_table[count].leveltitle = gui.TextManager:GetText("desc_" .. near_player:QueryProp("LevelTitle"))
      local player_school = near_player:QueryProp("School")
      local player_force = near_player:QueryProp("Force")
      local player_newschool = near_player:QueryProp("NewSchool")
      if player_school ~= nil and nx_string(player_school) ~= nx_string("") and nx_string(player_school) ~= nx_string(0) then
        player_table[count].school = player_school
      elseif player_newschool ~= nil and nx_string(player_newschool) ~= nx_string("") and nx_string(player_newschool) ~= nx_string(0) then
        player_table[count].school = player_newschool
      elseif player_force ~= nil and nx_string(player_force) ~= nx_string("") and nx_string(player_force) ~= nx_string(0) then
        player_table[count].school = player_force
      else
        player_table[count].school = "ui_None"
      end
      player_table[count].isinteam = is_in_team(near_player)
      player_table[count].iscaptain = is_team_captain(near_player)
      player_table[count].captainname = near_player:QueryProp("TeamCaptain")
    end
  end
  return player_table
end
function clear_selected(rbtn)
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  local child_table = form.groupbox1:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "control_type") and "item" == child.control_type then
      if nx_is_valid(rbtn) then
        if not nx_id_equal(child.btn_bg, rbtn) then
          child.btn_hide.Checked = true
        end
      else
        child.btn_hide.Checked = true
      end
    end
  end
end
function clear_grid()
  local gui = nx_value("gui")
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return nil
  end
  local child_table = form.groupbox1:GetChildControlList()
  for i = 1, table.getn(child_table) do
    local child = child_table[i]
    if nx_is_valid(child) and "GroupBox" == nx_name(child) and nx_find_custom(child, "control_type") then
      form.groupbox1:Remove(child)
      gui:Delete(child)
    end
  end
end
function GetNewMark(text)
  local gui = nx_value("gui")
  local mark = gui:Create("GroupBox")
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return nil
  end
  local tpl_mark = form.groupbox_mark
  if nx_is_valid(mark) and nx_is_valid(tpl_mark) then
    mark.Width = tpl_mark.Width
    mark.Height = tpl_mark.Height
    mark.BackColor = tpl_mark.BackColor
    mark.NoFrame = tpl_mark.NoFrame
    local tpl_bg = tpl_mark:Find("mark_bg")
    if nx_is_valid(tpl_bg) then
      local lbl_bg = gui:Create("Label")
      lbl_bg.Left = tpl_bg.Left
      lbl_bg.Top = tpl_bg.Top
      lbl_bg.Width = tpl_bg.Width
      lbl_bg.Height = tpl_bg.Height
      lbl_bg.DrawMode = tpl_bg.DrawMode
      lbl_bg.BackImage = tpl_bg.BackImage
      lbl_bg.AutoSize = tpl_bg.AutoSize
      mark:Add(lbl_bg)
      mark.lbl_bg = lbl_bg
    end
    local tpl_ext = tpl_mark:Find("mark_ext")
    if nx_is_valid(tpl_ext) then
      local btn_ext = gui:Create("Button")
      btn_ext.Left = tpl_ext.Left
      btn_ext.Top = tpl_ext.Top
      btn_ext.Width = tpl_ext.Width
      btn_ext.Height = tpl_ext.Height
      btn_ext.NormalImage = tpl_ext.NormalImage
      btn_ext.FocusImage = tpl_ext.FocusImage
      btn_ext.PushImage = tpl_ext.PushImage
      btn_ext.DrawMode = tpl_ext.DrawMode
      btn_ext.AutoSize = tpl_ext.AutoSize
      nx_bind_script(btn_ext, nx_current())
      nx_callback(btn_ext, "on_click", "on_btn_ext_click")
      mark:Add(btn_ext)
      mark.btn_ext = btn_ext
    end
    local tpl_title = tpl_mark:Find("mark_title")
    if nx_is_valid(tpl_title) then
      local lbl_title = gui:Create("Label")
      lbl_title.Left = tpl_title.Left
      lbl_title.Top = tpl_title.Top
      lbl_title.Width = tpl_title.Width
      lbl_title.Height = tpl_title.Height
      lbl_title.ForeColor = tpl_title.ForeColor
      lbl_title.Font = tpl_title.Font
      lbl_title.Text = text
      mark:Add(lbl_title)
      mark.lbl_title = lbl_title
    end
  end
  return mark
end
function GetNewItem(icon, name, school, level)
  local gui = nx_value("gui")
  local item = gui:Create("GroupBox")
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return nil
  end
  local tpl_item = form.groupbox_item
  if nx_is_valid(item) and nx_is_valid(tpl_item) then
    item.Width = tpl_item.Width
    item.Height = tpl_item.Height
    item.BackColor = tpl_item.BackColor
    item.NoFrame = tpl_item.NoFrame
    local tpl_bg = tpl_item:Find("item_bg")
    if nx_is_valid(tpl_bg) then
      local btn_bg = gui:Create("RadioButton")
      btn_bg.Left = tpl_bg.Left
      btn_bg.Top = tpl_bg.Top
      btn_bg.Width = tpl_bg.Width
      btn_bg.Height = tpl_bg.Height
      btn_bg.NormalImage = tpl_bg.NormalImage
      btn_bg.FocusImage = tpl_bg.FocusImage
      btn_bg.CheckedImage = tpl_bg.CheckedImage
      btn_bg.DrawMode = tpl_bg.DrawMode
      btn_bg.AutoSize = tpl_bg.AutoSize
      nx_bind_script(btn_bg, nx_current())
      nx_callback(btn_bg, "on_checked_changed", "on_select_changed")
      item:Add(btn_bg)
      item.btn_bg = btn_bg
    end
    local tpl_hide = tpl_item:Find("item_hide")
    if nx_is_valid(tpl_hide) then
      local btn_hide = gui:Create("RadioButton")
      btn_hide.Left = tpl_hide.Left
      btn_hide.Top = tpl_hide.Top
      btn_hide.Width = tpl_hide.Width
      btn_hide.Height = tpl_hide.Height
      btn_hide.NormalImage = tpl_hide.NormalImage
      btn_hide.FocusImage = tpl_hide.FocusImage
      btn_hide.CheckedImage = tpl_hide.CheckedImage
      btn_hide.DrawMode = tpl_hide.DrawMode
      btn_hide.AutoSize = tpl_hide.AutoSize
      btn_hide.Visible = false
      item:Add(btn_hide)
      item.btn_hide = btn_hide
    end
    local tpl_flag = tpl_item:Find("item_flag")
    if nx_is_valid(tpl_flag) then
      local lbl_flag = gui:Create("Label")
      lbl_flag.Left = tpl_flag.Left
      lbl_flag.Top = tpl_flag.Top
      lbl_flag.Width = tpl_flag.Width
      lbl_flag.Height = tpl_flag.Height
      lbl_flag.DrawMode = tpl_flag.DrawMode
      lbl_flag.AutoSize = tpl_flag.AutoSize
      lbl_flag.Align = tpl_flag.Align
      lbl_flag.BackImage = icon
      item:Add(lbl_flag)
      item.lbl_flag = lbl_flag
    end
    local tpl_name = tpl_item:Find("item_name")
    if nx_is_valid(tpl_name) then
      local lbl_name = gui:Create("Label")
      lbl_name.Left = tpl_name.Left
      lbl_name.Top = tpl_name.Top
      lbl_name.Width = tpl_name.Width
      lbl_name.Height = tpl_name.Height
      lbl_name.ForeColor = tpl_name.ForeColor
      lbl_name.Font = tpl_name.Font
      lbl_name.Align = tpl_name.Align
      lbl_name.Text = name
      item:Add(lbl_name)
      item.lbl_name = lbl_name
    end
    local tpl_school = tpl_item:Find("item_school")
    if nx_is_valid(tpl_school) then
      local lbl_school = gui:Create("Label")
      lbl_school.Left = tpl_school.Left
      lbl_school.Top = tpl_school.Top
      lbl_school.Width = tpl_school.Width
      lbl_school.Height = tpl_school.Height
      lbl_school.ForeColor = tpl_school.ForeColor
      lbl_school.Font = tpl_school.Font
      lbl_school.Align = tpl_school.Align
      lbl_school.Text = school
      local flag = nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "is_in_wudao_scene")
      if flag then
        lbl_school.Visible = false
      end
      item:Add(lbl_school)
      item.lbl_school = lbl_school
    end
    local tpl_level = tpl_item:Find("item_level")
    if nx_is_valid(tpl_level) then
      local lbl_level = gui:Create("Label")
      lbl_level.Left = tpl_level.Left
      lbl_level.Top = tpl_level.Top
      lbl_level.Width = tpl_level.Width
      lbl_level.Height = tpl_level.Height
      lbl_level.ForeColor = tpl_level.ForeColor
      lbl_level.Font = tpl_level.Font
      lbl_level.Align = tpl_level.Align
      lbl_level.Text = level
      item:Add(lbl_level)
      item.lbl_level = lbl_level
    end
  end
  return item
end
function reset_team_btn()
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  form.btn_require_join.Visible = false
  form.btn_require_join.Enabled = false
  form.btn_invite_team.Visible = false
  form.btn_invite_team.Enabled = false
  Cur_Selected_Playername = ""
  clear_selected(nil)
end
function disp_team_btn(form, target_is_captain)
  if not is_in_team() then
    if target_is_captain then
      form.btn_invite_team.Visible = false
      form.btn_invite_team.Enabled = false
      form.btn_require_join.Visible = true
      form.btn_require_join.Enabled = true
    else
      form.btn_invite_team.Visible = true
      form.btn_invite_team.Enabled = true
      form.btn_require_join.Visible = false
      form.btn_require_join.Enabled = false
    end
  elseif is_team_captain() then
    form.btn_invite_team.Visible = true
    form.btn_invite_team.Enabled = not target_is_captain
    form.btn_require_join.Visible = false
    form.btn_require_join.Enabled = false
  elseif get_team_type() == TYPE_LARGE_TEAM and get_team_work() == 2 then
    form.btn_invite_team.Visible = true
    form.btn_invite_team.Enabled = true
    form.btn_require_join.Visible = false
    form.btn_require_join.Enabled = false
  else
    form.btn_invite_team.Visible = true
    form.btn_invite_team.Enabled = false
    form.btn_require_join.Visible = false
    form.btn_require_join.Enabled = false
  end
end
function recover_default()
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  form.Height = 494
  form.groupbox_nearby.Height = 494
  form.lbl_BackColor.Height = 436
  form.lbl_kuang.Height = 428
  form.lbl_scroll.Height = 432
  form.btn_refresh.Top = 459
  form.btn_require_join.Top = 459
  form.btn_invite_team.Top = 459
  form.lbl_rightline.Height = 458
  form.groupbox1.Height = 428
  form.lbl_bomline.Top = 455
end
function stretch_form(value)
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  form.Height = form.Height + value
  form.groupbox_nearby.Height = form.groupbox_nearby.Height + value
  form.lbl_BackColor.Height = form.lbl_BackColor.Height + value
  form.lbl_kuang.Height = form.lbl_kuang.Height + value
  form.lbl_scroll.Height = form.lbl_scroll.Height + value
  form.btn_refresh.Top = form.btn_refresh.Top + value
  form.btn_require_join.Top = form.btn_require_join.Top + value
  form.btn_invite_team.Top = form.btn_invite_team.Top + value
  form.lbl_rightline.Height = form.lbl_rightline.Height + value
  form.groupbox1.Height = form.groupbox1.Height + value
  form.lbl_bomline.Top = form.lbl_bomline.Top + value
end
function set_use_mode(mode)
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  if mode == 0 then
    recover_default()
    form.lbl_bomline.Visible = false
    form.lbl_rightline.Visible = true
  else
    recover_default()
    stretch_form(26)
    form.lbl_bomline.Visible = true
    form.lbl_rightline.Visible = false
  end
end
