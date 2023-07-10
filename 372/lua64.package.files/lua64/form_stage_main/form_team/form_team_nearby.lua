require("util_gui")
require("share\\client_custom_define")
require("define\\team_rec_define")
require("share\\logicstate_define")
require("form_stage_main\\form_team\\team_util_functions")
local FORM_TEAM_RECRUIT = "form_stage_main\\form_team\\form_team_recruit"
local FORM_TEAM_NEARBY = "form_stage_main\\form_team\\form_team_nearby"
local captain_img = "gui\\special\\team\\icon_captain.png"
local SORT_DEFAULT = 0
local SORT_SCHOOL = 1
local SORT_POWER = 2
local SORT_POWER_DESC = 3
local SORT_BOTH = 4
local sort_scholl_rule = {
  "school_shaolin",
  "school_wudang",
  "school_gaibang",
  "school_tangmen",
  "school_emei",
  "school_jinyiwei",
  "school_jilegu",
  "school_junzitang",
  "ui_None"
}
local NearPlayerList = {}
local Cur_Sort_Mode = SORT_DEFAULT
function refresh_form(form)
  if nx_is_valid(form) then
    Cur_Sort_Mode = SORT_DEFAULT
    reset_team_btn()
    refresh_nearplayer_grid(Cur_Sort_Mode)
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  init_form(form)
  refresh_nearplayer_grid(Cur_Sort_Mode)
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_click_refresh(btn)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  refresh_nearplayer_grid(Cur_Sort_Mode)
  reset_team_btn()
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_click_join(self)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  local form = self.ParentForm
  local index = form.playergridselectedIndex
  if index < 0 then
    return 1
  end
  nx_execute("custom_sender", "custom_team_request_join", NearPlayerList[index + 1].name)
end
function on_click_create(self)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  local form = self.ParentForm
  local index = form.playergridselectedIndex
  if index < 0 then
    return 1
  end
  nx_execute("custom_sender", "custom_team_invite", NearPlayerList[index + 1].name)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_playergrid_select(grid, row)
  nx_execute(FORM_TEAM_RECRUIT, "set_quality_page_visible", nx_value(FORM_TEAM_RECRUIT), false)
  local form = grid.ParentForm
  form.playergridselectedIndex = row
  disp_team_btn(form, row + 1)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function init_form(form)
  local rowheight = 24
  local colwidth = 100
  form.playergrid.ColCount = 4
  form.playergrid.RowHeight = rowheight
  form.playergrid:SetColAlign(0, "center")
  form.playergrid:SetColAlign(1, "center")
  form.playergrid:SetColAlign(2, "center")
  form.playergrid:SetColAlign(3, "center")
  form.playergrid:SetColWidth(0, 16)
  form.playergrid:SetColWidth(1, form.btn_name.Width)
  form.playergrid:SetColWidth(2, form.btn_school.Width)
  form.playergrid:SetColWidth(3, form.btn_powerlevel.Width)
  form.playergridselectedIndex = -1
  reset_team_btn()
end
function refresh_grid()
  reset_team_btn()
  refresh_nearplayer_grid(Cur_Sort_Mode)
end
function refresh_nearplayer_grid(sort_mode)
  local gui = nx_value("gui")
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  form.playergrid.RowCount = 0
  NearPlayerList = get_near_players(sort_mode)
  for i = 1, table.getn(NearPlayerList) do
    local name = NearPlayerList[i].name
    local school = NearPlayerList[i].school
    local leveltitle = NearPlayerList[i].leveltitle
    local row = form.playergrid:InsertRow(-1)
    local Image = ""
    if NearPlayerList[i].iscaptain then
      local team_type = 0
      local member_count = 0
      local player = NearPlayerList[i].obj
      if nx_is_valid(player) then
        team_type = player:QueryProp("TeamType")
        member_count = player:QueryProp("TeamMemberCount")
        name = nx_widestr(name) .. nx_widestr(member_count) .. nx_widestr("/") .. nx_widestr(team_type == TYPE_NORAML_TEAM and 6 or 48)
      end
      Image = team_type == TYPE_LARGE_TEAM and ICON_COLONEL or ICON_CAPTAIN
    end
    local lbl_captainimg = gui:Create("Label")
    lbl_captainimg.DrawMode = "FitWindow"
    lbl_captainimg.BackImage = Image
    lbl_captainimg.Width = 20
    lbl_captainimg.Height = 20
    form.playergrid:SetGridControl(row, 0, lbl_captainimg)
    form.playergrid:SetGridText(row, 1, nx_widestr(name))
    form.playergrid:SetGridText(row, 2, nx_widestr(gui.TextManager:GetText(school)))
    form.playergrid:SetGridText(row, 3, nx_widestr(leveltitle))
  end
end
function get_near_players(sorttype)
  if sorttype == SORT_DEFAULT or sorttype == nil then
    return do_sort_default()
  elseif sorttype == SORT_POWER then
    return do_sort_powerlevel()
  elseif sorttype == SORT_POWER_DESC then
    return do_sort_powerlevel_desc()
  elseif sorttype == SORT_SCHOOL then
    return do_sort_school()
  elseif sorttype == SORT_BOTH then
    return do_sort_both()
  end
  return {}
end
function get_near_player_table()
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local game_player = game_client:GetPlayer()
  local my_name = game_player:QueryProp("Name")
  local game_scene = game_client:GetScene()
  local lst_nearplayer = game_scene:GetSceneObjList()
  local player_table = {}
  local count = 0
  for i, near_obj in pairs(lst_nearplayer) do
    local near_player = game_client:GetSceneObj(near_obj.Ident)
    local player_name = near_player:QueryProp("Name")
    local player_type = nx_number(near_player:QueryProp("Type"))
    if nx_int(player_type) == nx_int(2) and not nx_ws_equal(nx_widestr(my_name), nx_widestr(player_name)) and not is_player_offline(near_player) then
      count = count + 1
      player_table[count] = {}
      player_table[count].obj = near_player
      player_table[count].name = player_name
      player_table[count].powerlevel = nx_number(near_player:QueryProp("PowerLevel"))
      player_table[count].leveltitle = gui.TextManager:GetText("desc_" .. near_player:QueryProp("LevelTitle"))
      local player_school = near_player:QueryProp("School")
      if player_school == nil or nx_string(player_school) == nx_string("") or nx_string(player_school) == nx_string(0) then
        player_school = "ui_None"
      end
      player_table[count].school = player_school
      player_table[count].isinteam = is_in_team(near_player)
      player_table[count].iscaptain = is_team_captain(near_player)
      player_table[count].captainname = near_player:QueryProp("TeamCaptain")
    end
  end
  return player_table
end
function do_sort_default()
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return {}
  end
  local player_table = get_near_player_table()
  local default_table = {}
  local orgintype = 0
  if is_in_team() then
    if is_team_captain() then
      orgintype = 2
    else
      orgintype = 1
    end
  end
  local count = 0
  if nx_int(orgintype) == nx_int(2) or nx_int(orgintype) == nx_int(1) then
    local my_captain = game_player:QueryProp("TeamCaptain")
    for i = 1, table.getn(player_table) do
      if nx_ws_equal(nx_widestr(player_table[i].captainname), nx_widestr(my_captain)) then
        count = count + 1
        default_table[count] = player_table[i]
        player_table[i] = {}
      end
    end
  else
    for i = 1, table.getn(player_table) do
      if player_table[i].iscaptain then
        count = count + 1
        default_table[count] = player_table[i]
        player_table[i] = {}
      end
    end
  end
  for i = 1, table.getn(player_table) do
    if player_table[i].isinteam ~= nil and not player_table[i].isinteam then
      count = count + 1
      default_table[count] = player_table[i]
      player_table[i] = {}
    end
  end
  for i = 1, table.getn(player_table) do
    if player_table[i].name ~= nil then
      count = count + 1
      default_table[count] = player_table[i]
      player_table[i] = {}
    end
  end
  return default_table
end
function do_sort_powerlevel()
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return {}
  end
  local player_table = get_near_player_table()
  for i = 1, table.getn(player_table) - 1 do
    local max_index = i
    for j = i + 1, table.getn(player_table) do
      if nx_number(player_table[max_index].powerlevel) < nx_number(player_table[j].powerlevel) then
        max_index = j
      end
    end
    if i < max_index then
      player_table[i], player_table[max_index] = player_table[max_index], player_table[i]
    end
  end
  return player_table
end
function do_sort_powerlevel_desc()
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  if not nx_is_valid(game_player) then
    return {}
  end
  local player_table = get_near_player_table()
  for i = 1, table.getn(player_table) - 1 do
    local min_index = i
    for j = i + 1, table.getn(player_table) do
      if nx_number(player_table[min_index].powerlevel) > nx_number(player_table[j].powerlevel) then
        min_index = j
      end
    end
    if i < min_index then
      player_table[i], player_table[min_index] = player_table[min_index], player_table[i]
    end
  end
  return player_table
end
function do_sort_school()
  local player_table = get_near_player_table()
  local school_table = {}
  local rule_count = table.getn(sort_scholl_rule)
  for i = 1, rule_count do
    school_table[i] = {}
  end
  school_table[rule_count + 1] = {}
  for i = 1, table.getn(player_table) do
    local index = get_sort_index(player_table[i].school)
    if index == 0 then
      index = rule_count + 1
    end
    table.insert(school_table[index], player_table[i])
  end
  player_table = {}
  for i = 1, table.getn(school_table) do
    for j = 1, table.getn(school_table[i]) do
      table.insert(player_table, school_table[i][j])
    end
  end
  return player_table
end
function get_sort_index(school)
  for i = 1, table.getn(sort_scholl_rule) do
    if nx_string(sort_scholl_rule[i]) == nx_string(school) then
      return i
    end
  end
  return 0
end
function do_sort_both()
  local player_table = get_near_player_table()
  local both_table = {}
  local rule_count = table.getn(sort_scholl_rule)
  for i = 1, rule_count do
    both_table[i] = {}
  end
  both_table[rule_count + 1] = {}
  for i = 1, table.getn(player_table) do
    local index = get_sort_index(player_table[i].school)
    if index == 0 then
      index = rule_count + 1
    end
    if table.getn(both_table[index]) == 0 then
      table.insert(both_table[index], player_table[i])
    else
      local insert_index = 0
      for j = 1, table.getn(both_table[index]) do
        if nx_number(player_table[i].powerlevel) > nx_number(both_table[index][j].powerlevel) then
          insert_index = j
          break
        end
      end
      if insert_index == 0 then
        table.insert(both_table[index], player_table[i])
      else
        table.insert(both_table[index], insert_index, player_table[i])
      end
    end
  end
  player_table = {}
  for i = 1, table.getn(both_table) do
    for j = 1, table.getn(both_table[i]) do
      table.insert(player_table, both_table[i][j])
    end
  end
  return player_table
end
function on_btn_school_click(btn)
  if Cur_Sort_Mode == SORT_DEFAULT then
    Cur_Sort_Mode = SORT_SCHOOL
  elseif Cur_Sort_Mode == SORT_SCHOOL then
    Cur_Sort_Mode = SORT_DEFAULT
  elseif Cur_Sort_Mode == SORT_POWER then
    Cur_Sort_Mode = SORT_BOTH
  elseif Cur_Sort_Mode == SORT_POWER_DESC then
    Cur_Sort_Mode = SORT_SCHOOL
  elseif Cur_Sort_Mode == SORT_BOTH then
    Cur_Sort_Mode = SORT_POWER
  else
    Cur_Sort_Mode = SORT_DEFAULT
  end
  refresh_nearplayer_grid(Cur_Sort_Mode)
end
function on_btn_powerlevel_click(btn)
  if Cur_Sort_Mode == SORT_DEFAULT then
    Cur_Sort_Mode = SORT_POWER
  elseif Cur_Sort_Mode == SORT_POWER then
    Cur_Sort_Mode = SORT_POWER_DESC
  elseif Cur_Sort_Mode == SORT_POWER_DESC then
    Cur_Sort_Mode = SORT_POWER
  elseif Cur_Sort_Mode == SORT_SCHOOL then
    Cur_Sort_Mode = SORT_BOTH
  elseif Cur_Sort_Mode == SORT_BOTH then
    Cur_Sort_Mode = SORT_POWER_DESC
  else
    Cur_Sort_Mode = SORT_DEFAULT
  end
  refresh_nearplayer_grid(Cur_Sort_Mode)
end
function disp_team_btn(form, row)
  local visual_obj = NearPlayerList[row]
  if visual_obj == nil then
    form.btn_require_join.Visible = false
    form.btn_require_join.Enabled = false
    form.btn_invite_team.Visible = false
    form.btn_invite_team.Enabled = false
    return
  end
  if not is_in_team() then
    form.btn_invite_team.Visible = false
    form.btn_invite_team.Enabled = false
    form.btn_require_join.Visible = true
    form.btn_require_join.Enabled = false
    if is_in_team(visual_obj.obj) then
      if is_team_captain(visual_obj.obj) then
        form.btn_require_join.Enabled = true
      else
        form.btn_require_join.Enabled = false
      end
    else
      form.btn_invite_team.Visible = true
      form.btn_invite_team.Enabled = true
      form.btn_require_join.Visible = false
      form.btn_require_join.Enabled = false
    end
  else
    form.btn_require_join.Visible = false
    form.btn_require_join.Enabled = false
    form.btn_invite_team.Visible = true
    form.btn_invite_team.Enabled = false
    if not is_team_captain() then
      return
    end
    if is_in_team(visual_obj.obj) then
      form.btn_invite_team.Enabled = false
    else
      form.btn_invite_team.Enabled = true
    end
  end
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
  form.playergridselectedIndex = -1
  form.playergrid:ClearSelect()
end
function recover_default()
  local form = nx_value(FORM_TEAM_NEARBY)
  if not nx_is_valid(form) then
    return
  end
  form.Height = 494
  form.groupbox_nearby.Height = 494
  form.lbl_BackColor.Height = 404
  form.lbl_kuang.Height = 401
  form.lbl_scroll.Height = 400
  form.btn_refresh.Top = 459
  form.btn_require_join.Top = 459
  form.btn_invite_team.Top = 459
  form.lbl_rightline.Height = 457
  form.playergrid.Height = 397
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
  form.playergrid.Height = form.playergrid.Height + value
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
