require("util_functions")
require("util_gui")
require("util_static_data")
require("define\\team_rec_define")
require("form_stage_main\\form_team\\team_util_functions")
local FORM_MAIN_SELECT = "form_stage_main\\form_main\\form_main_select"
local FORM_TINY_SINGLE = "form_stage_main\\form_main\\form_main_tiny_single"
local schoolimage = {
  school_shaolin = "gui\\mainform\\team\\pbr_hp_sl.png",
  school_wudang = "gui\\mainform\\team\\pbr_hp_wd.png",
  school_gaibang = "gui\\mainform\\team\\pbr_hp_gb.png",
  school_tangmen = "gui\\mainform\\team\\pbr_team_hp_tm.png",
  school_emei = "gui\\mainform\\team\\pbr_hp_em.png",
  school_jinyiwei = "gui\\mainform\\team\\pbr_hp_jyw.png",
  school_jilegu = "gui\\mainform\\team\\pbr_hp_jlg.png",
  school_junzitang = "gui\\mainform\\team\\pbr_hp_jzt.png",
  ui_None = "gui\\mainform\\team\\pbr_team_hp_wu.png",
  ui_offline = "gui\\mainform\\team\\pbr_team_hp_offine.png"
}
local mpimage = {
  ui_online = "gui\\mainform\\team\\pbr_mp.png",
  ui_offline = "gui\\mainform\\team\\pbr_team_mp_offine.png"
}
local ONLINE_COLOR = "255,255,255,255"
local OFFLINE_COLOR = "255,128,128,128"
local TEAM_REC = "team_rec"
local MAX_SINGLE_TEAM_MEMBER = 6
local SHOW_GOOD_BUFFER = 0
local SHOW_BAD_BUFFER = 1
local HIDE_ALL_BUFFER = 2
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function form_main_team_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
  form.bufferShowState = HIDE_ALL_BUFFER
  form.lineCount = 0
  form.player_name = nx_widestr("")
end
function main_form_open(form)
  if nx_widestr(form.player_name) == nx_widestr("") then
    form.Visible = false
    form:Close()
    return 1
  end
  form.Visible = true
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, form, nx_current(), "on_team_rec_update")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", form, nx_current(), "on_team_captain_changed")
    databinder:AddRolePropertyBind("TeamPickMode", "int", form, nx_current(), "on_team_pickmode_changed")
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", form)
  end
  on_refresh_base_info(form)
  on_refresh_other_info(form)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(TEAM_REC, form)
    databinder:DelRolePropertyBind("TeamCaptain", form)
    databinder:DelRolePropertyBind("TeamPickMode", form)
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", form)
  end
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function on_team_captain_changed(form)
  on_refresh_base_info(form)
end
function on_team_pickmode_changed(form)
  on_refresh_base_info(form)
end
function on_team_rec_update(form, tablename, ttype, line, col)
  if form.Visible == true then
    if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_SCENE or col == TEAM_REC_COL_TEAMWORK or col == TEAM_REC_COL_SCHOOL or col == TEAM_REC_COL_TEAMPOSITION or col == TEAM_REC_COL_ISOFFLINE then
      refresh_base_info(form, line)
    end
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(form.player_name))
    if nx_number(row) < 0 then
      form:Close()
    end
  end
end
function on_team_sub_rec_update(form, opttype, ...)
  if not form.Visible then
    return
  end
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_HPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_MPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_BUFFERS)) then
    refresh_other_info(form)
  end
end
function refresh_base_info(form, row)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_base_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_base_info", form, row, -1)
  end
end
function on_refresh_base_info(form, row)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if row then
    local name = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_NAME)
    if nx_string(name) == nx_string(form.player_name) then
      refresh_line_info(form, row)
    end
  else
    local row1 = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(form.player_name))
    if row1 < 0 then
      return
    end
    refresh_line_info(form, row1)
  end
end
function refresh_line_info(form, row)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local captain = client_player:QueryProp("TeamCaptain")
  local pick_mode = client_player:QueryProp("TeamPickMode")
  local team_type = client_player:QueryProp("TeamType")
  local name = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_NAME)
  local scene = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCENE)
  local playerpos = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMPOSITION)
  local playerwork = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  local OffLinetime = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_ISOFFLINE)
  local school = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCHOOL)
  local group = form:Find("group_1")
  if not nx_is_valid(group) then
    return false
  end
  local control = group:Find("name_1")
  if nx_is_valid(control) then
    control.Text = name
    if nx_number(OffLinetime) > nx_number(0) or not sceneid_is_equal(scene) then
      control.ForeColor = OFFLINE_COLOR
    else
      control.ForeColor = ONLINE_COLOR
    end
  end
  control = group:Find("pbar_hp_1")
  if nx_is_valid(control) then
    local flag = nx_number(OffLinetime) > nx_number(0) and "ui_offline" or school
    control.ProgressImage = get_school_image(flag)
  end
  control = group:Find("pbar_mp_1")
  if nx_is_valid(control) then
    local flag = nx_number(OffLinetime) > nx_number(0) and "ui_offline" or "ui_online"
    control.ProgressImage = mpimage[flag]
  end
  control = group:Find("title_1")
  allot_img = group:Find("allot_1")
  if nx_is_valid(control) then
    if nx_string(name) == nx_string(captain) then
      control.BackImage = nx_int(team_type) == nx_int(TYPE_LARGE_TEAM) and ICON_COLONEL or ICON_CAPTAIN
      if nx_is_valid(allot_img) then
        if nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
          allot_img.BackImage = ICON_ALLOCATEE
        else
          allot_img.BackImage = ""
        end
      end
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) then
      control.BackImage = ""
      if nx_is_valid(allot_img) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
        allot_img.BackImage = ICON_ALLOCATEE
      end
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_ASSIST) then
      control.BackImage = ICON_ASSISTANT
      if nx_is_valid(allot_img) then
        allot_img.BackImage = ""
      end
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_PLAYER) then
      control.BackImage = ""
      if nx_is_valid(allot_img) then
        allot_img.BackImage = ""
      end
    end
  end
  return true
end
function refresh_other_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_other_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_other_info", form, -1, -1)
  end
end
function on_refresh_other_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_other_info", form)
  end
  local team_manager = nx_value("team_manager")
  if not nx_is_valid(team_manager) then
    return
  end
  local group = form:Find("group_1")
  if not nx_is_valid(group) then
    return
  end
  local lbl_name = group:Find("name_1")
  if nx_is_valid(lbl_name) then
    local player_name = nx_widestr(lbl_name.Text)
    local record_table = team_manager:GetPlayerData(player_name)
    if table.getn(record_table) > 0 then
      local hp = record_table[TEAM_SUB_REC_COL_HPRATIO + 1]
      local mp = record_table[TEAM_SUB_REC_COL_MPRATIO + 1]
      local buffers = record_table[TEAM_SUB_REC_COL_BUFFERS + 1]
      local pbar_hp = group:Find("pbar_hp_1")
      if nx_is_valid(pbar_hp) then
        pbar_hp.Value = hp
      end
      local pbar_mp = group:Find("pbar_mp_1")
      if nx_is_valid(pbar_mp) then
        pbar_mp.Value = mp
      end
      local imagegrid_buffer = group:Find("imagegrid_buffer_1")
      if nx_is_valid(imagegrid_buffer) then
        imagegrid_buffer.DataSource = buffers
        set_buff_icon(imagegrid_buffer, buffers)
      end
    end
  end
end
function on_close_click(self)
  form = self.Parent
  form:Close()
end
function on_show_good_buffer(self)
  form = self.Parent
  form.bufferShowState = SHOW_GOOD_BUFFER
  show_good_buffer(form)
end
function on_show_bad_buffer(self)
  form = self.Parent
  form.bufferShowState = SHOW_BAD_BUFFER
  show_bad_buffer(form)
end
function on_hide_buffer(self)
  form = self.Parent
  form.bufferShowState = HIDE_ALL_BUFFER
  hide_all_buffer(form)
end
function hide_all_buffer(form)
  local group = form:Find("group_1")
  if not nx_is_valid(group) then
    return false
  end
  control = group:Find("imagegrid_buffer_1")
  if not nx_is_valid(control) then
    return false
  end
  control:Clear()
end
function show_good_buffer(form)
  on_refresh_other_info(form)
  local group = form:Find("group_1")
  if not nx_is_valid(group) then
    return false
  end
  control = group:Find("imagegrid_buffer_1")
  if not nx_is_valid(control) then
    return false
  end
end
function show_bad_buffer(form)
  on_refresh_other_info(form)
  local group = form:Find("group_1")
  if not nx_is_valid(group) then
    return false
  end
  control = group:Find("imagegrid_buffer_1")
  if not nx_is_valid(control) then
    return false
  end
end
function on_show_menu(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "tiny_single_info", "tiny_single_info")
  nx_execute("menu_game", "menu_recompose", menu_game, groupbox)
  gui:TrackPopupMenu(menu_game, groupbox.AbsLeft + groupbox.Width, groupbox.AbsTop)
end
function select_target(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local control = groupbox:Find("name_1")
  if nx_is_valid(control) then
    local target0 = nx_string(control.Text)
    nx_execute(FORM_MAIN_SELECT, "select_target_byName", target0)
  end
end
function on_name_1_right_click(label)
  on_show_menu(label.Parent)
end
function on_name_1_left_double_click(label)
  select_target(label.Parent)
end
function on_pbar_right_click(self)
  on_show_menu(self.Parent)
end
function on_pbar_left_double_click(self)
  select_target(self.Parent)
end
function on_group_1_right_click(self)
  on_show_menu(self)
end
function on_group_1_left_double_click(self)
  select_target(self)
end
function on_imagegrid_buffer_1_rightclick_grid(grid)
  on_show_menu(grid.Parent)
end
function set_buff_icon(grid, buff_ids)
  grid:Clear()
  local form = grid.ParentForm
  if form.bufferShowState == HIDE_ALL_BUFFER then
    hide_all_buffer(form)
  end
  local buff_lst = util_split_string(buff_ids, " ")
  local count = nx_number(table.getn(buff_lst))
  local index = 0
  for i = 1, count do
    if index > grid.RowNum * grid.ClomnNum then
      return
    end
    buff_id = buff_lst[i]
    local buffer_id = string_trim(nx_string(buff_id))
    if buffer_id ~= "" then
      local photo, IsDamage, IsVisible = get_buff_photo_and_type(nx_string(buffer_id))
      if nx_int(IsVisible) == nx_int(1) then
        if form.bufferShowState == SHOW_GOOD_BUFFER then
          if IsDamage == 0 then
            grid:AddItem(index, nx_string(photo), nx_widestr(nx_string(buff_id)), 1, -1)
            index = index + 1
          end
        elseif form.bufferShowState == SHOW_BAD_BUFFER and IsDamage == 1 then
          grid:AddItem(index, nx_string(photo), nx_widestr(nx_string(buff_id)), 1, -1)
          index = index + 1
        end
      end
    end
  end
end
function get_buff_photo_and_type(buff_id)
  local tmp_buff_id = string.sub(buff_id, 0, -3)
  local photo_path = buff_static_query(nx_string(tmp_buff_id), "Photo")
  local IsDamage = buff_static_query(nx_string(tmp_buff_id), "IsDamage")
  local IsVisible = buff_static_query(nx_string(tmp_buff_id), "Visible")
  return photo_path, IsDamage, IsVisible
end
function on_imagegrid_buffer_mousein_grid(grid, index)
  local buff_id = nx_string(grid:GetItemName(index))
  if buff_id == "" or buff_id == nil then
    return
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("desc_" .. nx_string(buff_id)), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_imagegrid_buffer_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
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
function sceneid_is_equal(sceneid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(client_player:QueryProp("Name")))
  if row < 0 then
    return false
  end
  local mysceneid = nx_string(client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCENE))
  return nx_string(sceneid) == nx_string(mysceneid)
end
function string_trim(str)
  if str == nil then
    return nil
  end
  str = string.gsub(str, " ", "")
  return str
end
function refresh_all_form()
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  for i = 1, table.getn(childlist) do
    local control = childlist[i]
    if nx_is_valid(control) and nx_name(control) == "Form" and nx_script_name(control) == FORM_TINY_SINGLE then
      if is_in_team() and nx_find_custom(control, "name_1") then
        local player_name = nx_widestr(control.name_1.Text)
        local name_list = util_split_wstring(player_name, "@")
        if 1 <= table.getn(name_list) then
          control.name_1.Text = nx_widestr(name_list[1])
        end
      else
        control:Close()
      end
    end
  end
end
