require("util_functions")
require("util_gui")
require("util_static_data")
require("define\\team_rec_define")
local FORM_MAIN_SELECT = "form_stage_main\\form_main\\form_main_select"
local FORM_TEAM_LARGE_RECRUIT = "form_stage_main\\form_team\\form_team_large_recruit"
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
SHOW_GOOD_BUFFER = 0
SHOW_BAD_BUFFER = 1
HIDE_ALL_BUFFER = 2
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
  form.isDrag = 0
end
function main_form_open(form)
  form.Visible = false
  local group = form:Find("team_name")
  if not nx_is_valid(group) then
    return 1
  end
  local control = group:Find("lbl_1")
  if not nx_is_valid(control) then
    return 1
  end
  form.DataSource = nx_string(form.instance_id - 1)
  control.Text = nx_widestr("@ui_zudui003" .. nx_string(form.instance_id))
  local row = form.instance_id
  local col = 0
  if form.instance_id > 4 then
    row = nx_number(form.instance_id) - 4
    col = 1
  end
  if form.isDrag ~= 1 then
    form.Left = 221 + nx_number(row) * form.Width
    form.Top = 285 + nx_number(col) * 24
  end
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
  refresh_other_info(form)
  form.sender_menu.Visible = false
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
  nx_execute(FORM_TEAM_LARGE_RECRUIT, "refresh_controls_status")
end
function on_team_rec_update(form, tablename, ttype, line, col)
  if form.Visible == true then
    if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_SCENE or col == TEAM_REC_COL_TEAMWORK or col == TEAM_REC_COL_SCHOOL or col == TEAM_REC_COL_TEAMPOSITION or col == TEAM_REC_COL_ISOFFLINE then
      refresh_base_info(form)
    end
    if nx_string(ttype) == nx_string("clear") then
      refresh_base_info(form)
    end
    if nx_string(ttype) == nx_string("del") then
      refresh_base_info(form)
    end
  end
end
function on_team_sub_rec_update(form, opttye, ...)
  if not form.Visible then
    return
  end
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_HPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_MPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_BUFFERS)) then
    refresh_other_info(form)
  end
end
function on_team_captain_changed(form)
  refresh_base_info(form)
end
function on_team_pickmode_changed(form)
  refresh_base_info(form)
end
function refresh_base_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_base_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_base_info", form, -1, -1)
  end
end
function on_refresh_base_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_base_info", form)
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord(TEAM_REC) then
    return
  end
  local row_count = client_player:GetRecordRows(TEAM_REC)
  if not client_player:FindProp("TeamCaptain") then
    form.Visible = false
    return
  end
  for j = 0, MAX_SINGLE_TEAM_MEMBER do
    show_team_line(form, j, false)
  end
  form.Visible = true
  local line = 0
  for i = 0, row_count - 1 do
    if line <= MAX_SINGLE_TEAM_MEMBER then
      if refresh_line_info(form, i, line) then
        show_team_line(form, line, true)
        line = line + 1
      else
        show_team_line(form, line, false)
      end
    end
  end
  if nx_number(line) == 0 then
    form:Close()
    return
  end
  form.lineCount = line
end
function refresh_line_info(form, row, line)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local playerpos = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMPOSITION)
  if nx_int(form.DataSource) ~= nx_int(playerpos / 10) then
    return false
  end
  local captain = client_player:QueryProp("TeamCaptain")
  local pick_mode = client_player:QueryProp("TeamPickMode")
  local team_type = client_player:QueryProp("TeamType")
  local name = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_NAME)
  local scene = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCENE)
  local playerwork = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  local OffLinetime = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_ISOFFLINE)
  local school = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCHOOL)
  local group = form:Find("group_" .. line + 1)
  if not nx_is_valid(group) then
    return false
  end
  local control = group:Find("name_" .. line + 1)
  if nx_is_valid(control) then
    control.Text = name
    if nx_number(OffLinetime) > nx_number(0) or not sceneid_is_equal(scene) then
      control.ForeColor = OFFLINE_COLOR
    else
      control.ForeColor = ONLINE_COLOR
    end
  end
  control = group:Find("pbar_hp_" .. line + 1)
  if nx_is_valid(control) then
    local flag = nx_number(OffLinetime) > nx_number(0) and "ui_offline" or school
    control.ProgressImage = get_school_image(flag)
  end
  control = group:Find("pbar_mp_" .. line + 1)
  if nx_is_valid(control) then
    local flag = nx_number(OffLinetime) > nx_number(0) and "ui_offline" or "ui_online"
    control.ProgressImage = mpimage[flag]
  end
  local allot_img = group:Find("allot_" .. line + 1)
  control = group:Find("title_" .. line + 1)
  if nx_is_valid(control) and nx_is_valid(allot_img) then
    if nx_string(name) == nx_string(captain) then
      control.BackImage = nx_int(team_type) == nx_int(TYPE_LARGE_TEAM) and ICON_COLONEL or ICON_CAPTAIN
      if nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
        allot_img.BackImage = ICON_ALLOCATEE
      else
        allot_img.BackImage = ""
      end
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
      control.BackImage = ""
      allot_img.BackImage = ICON_ALLOCATEE
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_ASSIST) then
      control.BackImage = ICON_ASSISTANT
      allot_img.BackImage = ""
    elseif nx_int(playerwork) == nx_int(TYPE_NORAML_PLAYER) then
      control.BackImage = ""
      allot_img.BackImage = ""
    end
  end
  return true
end
function show_team_line(form, line, visible)
  local group_box = form:Find("group_" .. line + 1)
  if nx_is_valid(group_box) then
    group_box.Visible = visible
  end
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
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local group = form:Find("group_" .. i)
    if not nx_is_valid(group) then
      return false
    end
    local lbl_name = group:Find("name_" .. i)
    if nx_is_valid(lbl_name) then
      local player_name = nx_widestr(lbl_name.Text)
      local record_table = team_manager:GetPlayerData(player_name)
      if table.getn(record_table) > 0 then
        local hp = record_table[TEAM_SUB_REC_COL_HPRATIO + 1]
        local mp = record_table[TEAM_SUB_REC_COL_MPRATIO + 1]
        local buffers = record_table[TEAM_SUB_REC_COL_BUFFERS + 1]
        local pbar_hp = group:Find("pbar_hp_" .. i)
        if nx_is_valid(pbar_hp) then
          pbar_hp.Value = hp
        end
        local pbar_mp = group:Find("pbar_mp_" .. i)
        if nx_is_valid(pbar_mp) then
          pbar_mp.Value = mp
        end
        local imagegrid_buffer = group:Find("imagegrid_buffer_" .. i)
        if nx_is_valid(imagegrid_buffer) then
          imagegrid_buffer.DataSource = buffers
          set_buff_icon(imagegrid_buffer, buffers)
        end
      end
    end
  end
end
function on_show_team_menu(self, membername)
  local gui = nx_value("gui")
  hide_sender_menu(self.ParentForm)
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "team", "team")
  nx_execute("menu_game", "menu_recompose", menu_game, membername)
  gui:TrackPopupMenu(menu_game, self.AbsLeft + self.Width, self.AbsTop)
end
function on_team_name_right_click(self)
  local gui = nx_value("gui")
  hide_sender_menu(self.ParentForm)
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "tiny_team_info", "tiny_team_info")
  nx_execute("menu_game", "menu_recompose", menu_game, self)
  gui:TrackPopupMenu(menu_game, self.AbsLeft + self.Width, self.AbsTop)
end
function on_close_click(self)
  form = self.ParentForm
  form:Close()
end
function on_show_good_buffer(self)
  form = self.ParentForm
  form.bufferShowState = SHOW_GOOD_BUFFER
  show_good_buffer(form)
  hide_sender_menu(form)
end
function on_show_bad_buffer(self)
  form = self.ParentForm
  form.bufferShowState = SHOW_BAD_BUFFER
  show_bad_buffer(form)
  hide_sender_menu(form)
end
function on_hide_buffer(self)
  form = self.ParentForm
  form.bufferShowState = HIDE_ALL_BUFFER
  hide_all_buffer(form)
  hide_sender_menu(form)
end
function on_pbar_right_click(pbar)
  local num = string.sub(nx_string(pbar.Name), -1, -1)
  local groupbox = pbar.Parent
  local control = groupbox:Find("name_" .. num)
  if nx_is_valid(control) then
    on_show_team_menu(groupbox, control.Text)
  end
end
function on_pbar_left_double_click(pbar)
  local num = string.sub(nx_string(pbar.Name), -1, -1)
  local groupbox = pbar.Parent
  local control = groupbox:Find("name_" .. num)
  if nx_is_valid(control) then
    local target0 = nx_string(control.Text)
    nx_execute(FORM_MAIN_SELECT, "select_target_byName", target0)
  end
end
function on_group_right_click(groupbox)
  local group_name = nx_string(groupbox.Name)
  local index = string.sub(group_name, string.len(group_name))
  local control = groupbox:Find("name_" .. index)
  if nx_is_valid(control) then
    on_show_team_menu(groupbox, control.Text)
  end
end
function on_group_left_double_click(groupbox)
  local group_name = nx_string(groupbox.Name)
  local index = string.sub(group_name, string.len(group_name))
  local control = groupbox:Find("name_" .. index)
  if nx_is_valid(control) then
    local target0 = nx_string(control.Text)
    nx_execute(FORM_MAIN_SELECT, "select_target_byName", target0)
  end
end
function on_imagegrid_buffer_rightclick_grid(grid)
  local grid_name = nx_string(grid.Name)
  local index = string.sub(grid_name, string.len(grid_name))
  local control = grid.Parent:Find("name_" .. index)
  if nx_is_valid(control) then
    on_show_team_menu(grid.Parent, control.Text)
  end
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
function on_btn_setting_click(btn)
  local form = btn.ParentForm
  form.sender_menu.Visible = not form.sender_menu.Visible
end
function hide_sender_menu(form)
  if not nx_is_valid(form) then
    return
  end
  form.sender_menu.Visible = false
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
function show_good_buffer(form)
  on_refresh_other_info(form)
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local group = form:Find("group_" .. i)
    if not nx_is_valid(group) then
      return false
    end
    control = group:Find("imagegrid_buffer_" .. i)
    if not nx_is_valid(control) then
      return false
    end
  end
end
function show_bad_buffer(form)
  on_refresh_other_info(form)
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local group = form:Find("group_" .. i)
    if not nx_is_valid(group) then
      return false
    end
    control = group:Find("imagegrid_buffer_" .. i)
    if not nx_is_valid(control) then
      return false
    end
  end
end
function hide_all_buffer(form)
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local group = form:Find("group_" .. i)
    if not nx_is_valid(group) then
      return false
    end
    control = group:Find("imagegrid_buffer_" .. i)
    if not nx_is_valid(control) then
      return false
    end
    control:Clear()
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
