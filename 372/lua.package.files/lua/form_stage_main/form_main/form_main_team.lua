require("util_functions")
require("define\\team_sign_define")
require("util_static_data")
require("define\\team_rec_define")
require("form_stage_main\\form_team\\team_util_functions")
local FORM_MAIN_TEAM = "form_stage_main\\form_main\\form_main_team"
local TEAM_REC = "team_rec"
local schoolimage = {
  school_shaolin = "gui\\language\\ChineseS\\team\\team_word_sl.png",
  school_wudang = "gui\\language\\ChineseS\\team\\team_word_wd.png",
  school_gaibang = "gui\\language\\ChineseS\\team\\team_word_gb.png",
  school_tangmen = "gui\\language\\ChineseS\\team\\team_word_tm.png",
  school_emei = "gui\\language\\ChineseS\\team\\team_word_em.png",
  school_jinyiwei = "gui\\language\\ChineseS\\team\\team_word_jyw.png",
  school_jilegu = "gui\\language\\ChineseS\\team\\team_word_jlg.png",
  school_junzitang = "gui\\language\\ChineseS\\team\\team_word_jzt.png",
  school_mingjiao = "gui\\language\\ChineseS\\team\\team_word_mj.png",
  school_tianshan = "gui\\language\\ChineseS\\team\\team_word_ts.png",
  force_yihua = "gui\\language\\ChineseS\\team\\team_world_yhg.png",
  force_taohua = "gui\\language\\ChineseS\\team\\team_world_thd.png",
  force_xujia = "gui\\language\\ChineseS\\team\\team_world_xjz.png",
  force_wanshou = "gui\\language\\ChineseS\\team\\team_world_wssz.png",
  force_jinzhen = "gui\\language\\ChineseS\\team\\team_word_jzsj.png",
  force_wugen = "gui\\language\\ChineseS\\team\\team_world_wgm.png",
  newschool_gumu = "gui\\language\\ChineseS\\team\\team_world_gm.png",
  newschool_xuedao = "gui\\language\\ChineseS\\team\\team_world_xdm.png",
  newschool_huashan = "gui\\language\\ChineseS\\team\\team_world_hs.png",
  newschool_damo = "gui\\language\\ChineseS\\team\\team_world_dm.png",
  newschool_shenshui = "gui\\language\\ChineseS\\team\\team_world_ss.png",
  newschool_changfeng = "gui\\language\\ChineseS\\team\\team_world_cf.png",
  newschool_nianluo = "gui\\language\\ChineseS\\team\\team_world_nl.png",
  newschool_wuxian = "gui\\language\\ChineseS\\team\\team_world_wx.png",
  newschool_shenji = "gui\\language\\ChineseS\\team\\team_world_shj.png",
  newschool_xingmiao = "gui\\language\\ChineseS\\team\\team_world_xm.png",
  ui_None = "gui\\language\\ChineseS\\team\\team_word_wu.png"
}
local hp_def_img = "gui\\mainform\\pbr_team_hp.png"
local hp_gray_img = "gui\\mainform\\pbr_team_offline1.png"
local hp_other_img = "gui\\mainform\\pbr_team_far1.png"
local mp_def_img = "gui\\mainform\\pbr_team_mp.png"
local mp_gray_img = "gui\\mainform\\pbr_team_offline2.png"
local mp_other_img = "gui\\mainform\\pbr_team_far2.png"
local chat_backimg = "gui\\mainform\\bg_talk.png"
local COLOR_GRAY = "255,128,128,128"
local COLOR_DEFAULT = "255,255,255,255"
local MAX_SINGLE_TEAM_MEMBER = 5
HEAD_MAX_WIDTH = 160
HEAD_MAX_HEIGHT = 100
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function form_main_team_init(form)
  form.Fixed = true
  form.no_need_motion_alpha = true
  form.team_type = TYPE_NORAML_TEAM
  form.selfPosInTeam = 0
end
function main_form_open(form)
  init_form_main_team_logic()
  form.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, form, nx_current(), "on_team_rec_update")
    databinder:AddRolePropertyBind("TeamCaptain", "widestr", form, nx_current(), "on_team_captain_changed")
    databinder:AddRolePropertyBind("TeamType", "int", form, nx_current(), "on_TeamType_Change")
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", form)
  end
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(TEAM_REC, form)
    databinder:DelRolePropertyBind("TeamCaptain", form)
    databinder:DelRolePropertyBind("TeamType", form)
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", form)
  end
  destroy_form_main_team_logic()
end
function init_form_main_team_logic()
  local form_logic = nx_value("form_main_team_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_main_team")
  nx_set_value("form_main_team_logic", form_logic)
end
function destroy_form_main_team_logic()
  local form_logic = nx_value("form_main_team_logic")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
end
function on_team_captain_changed(form)
  on_refresh_base_info(form)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshAllTeamSignEffect()
  end
end
function on_TeamType_Change(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local team_type = client_player:QueryProp("TeamType")
  form.team_type = team_type
  on_refresh_base_info(form)
end
function on_team_rec_update(form, tablename, ttype, line, col)
  if col == TEAM_REC_COL_SIGN_STR then
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:RefreshAllTeamSignEffect()
    end
  end
  if form.Visible == true then
    if col == TEAM_REC_COL_NAME or col == TEAM_REC_COL_SCENE or col == TEAM_REC_COL_TEAMPOSITION or col == TEAM_REC_COL_TEAMWORK or col == TEAM_REC_COL_SCHOOL or col == TEAM_REC_COL_ISOFFLINE then
      refresh_base_info(form)
    end
    if nx_string(ttype) == nx_string("clear") then
      on_refresh_base_info(form)
    end
    if nx_string(ttype) == nx_string("del") then
      on_refresh_base_info(form)
      del_or_add_teamMember(form)
    end
    if nx_string(ttype) == nx_string("add") then
      on_refresh_base_info(form)
      del_or_add_teamMember(form)
    end
  end
end
function on_team_sub_rec_update(form, opttype, ...)
  if not form.Visible then
    return
  end
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_HPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_MPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_SPRATIO)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_BUFFERS)) then
    local form_logic = nx_value("form_main_team_logic")
    if nx_is_valid(form_logic) then
      form_logic:RefreshOtherInfo(form)
    end
  end
end
function on_del_or_add_teamMember(form)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ClearAllTeamSignEffect()
    head_game:RefreshAllTeamSignEffect()
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_del_or_add_teamMember", form)
  end
end
function del_or_add_teamMember(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_del_or_add_teamMember", form)
    timer:Register(1000, -1, nx_current(), "on_del_or_add_teamMember", form, -1, -1)
  end
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
  if not can_refresh_team_panel() then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.selfPosInTeam = get_role_TeamPos(form, client_player)
  for i = 0, MAX_SINGLE_TEAM_MEMBER do
    show_team_line(form, i, false)
  end
  form.lbl_TeamName.Visible = false
  form.Visible = false
  if is_have_team(client_player) then
    form.Visible = true
    form.old_visible = true
    local line = 0
    local row_count = client_player:GetRecordRows(TEAM_REC)
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
    if nx_number(get_team_type()) == TYPE_LARGE_TEAM then
      form.lbl_TeamName.Visible = true
      local team_num = nx_int(nx_number(form.selfPosInTeam) / 10) + 1
      form.lbl_TeamName.Text = nx_widestr("@ui_zudui003" .. nx_string(team_num))
    end
  else
    form.old_visible = false
    local head_game = nx_value("HeadGame")
    if nx_is_valid(head_game) then
      head_game:ClearAllTeamSignEffect()
    end
  end
end
function refresh_line_info(form, row, line)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_NAME)
  local scene = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCENE)
  local playerwork = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  local school = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCHOOL)
  local offlineState = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_ISOFFLINE)
  local playerpos = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMPOSITION)
  if playerpos == nil then
    return false
  end
  if form.team_type == TYPE_LARGE_TEAM then
    if form.selfPosInTeam == nil or form.selfPosInTeam < 0 then
      return false
    end
    if nx_int(form.selfPosInTeam / 10) ~= nx_int(playerpos / 10) then
      return false
    end
  end
  local captain = client_player:QueryProp("TeamCaptain")
  if nx_ws_equal(name, client_player:QueryProp("Name")) then
    return false
  end
  local group = form:Find("group_" .. line + 1)
  if not nx_is_valid(group) then
    return false
  end
  local control = group:Find("lbl_name_" .. line + 1)
  if nx_is_valid(control) then
    control.Text = name
  end
  control = group:Find("lbl_photo_" .. line + 1)
  if nx_is_valid(control) then
    control.BackImage = get_school_image(school)
    if nx_number(offlineState) > nx_number(0) then
      refresh_PlayerPhoto_State(client_player, TEAM_REC_COL_ISOFFLINE, row, control)
    else
      refresh_PlayerPhoto_State(client_player, TEAM_REC_COL_SCENE, row, control)
    end
  end
  local teamtype = client_player:QueryProp("TeamType")
  local pick_mode = client_player:QueryProp("TeamPickMode")
  control = group:Find("lbl_icon_" .. line + 1)
  if nx_is_valid(control) then
    if is_team_captain_by_name(name) then
      control.BackImage = nx_int(teamtype) == nx_int(TYPE_LARGE_TEAM) and ICON_COLONEL or ICON_CAPTAIN
    elseif form.team_type == TYPE_LARGE_TEAM and nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) and nx_int(pick_mode) == nx_int(TEAM_PICK_MODE_CAPTAIN) then
      control.BackImage = ICON_ALLOCATEE
    else
      control.BackImage = ""
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
  if not is_in_team() then
    return
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
    local lbl_name = group:Find("lbl_name_" .. i)
    if nx_is_valid(lbl_name) then
      local player_name = nx_widestr(lbl_name.Text)
      local record_table = team_manager:GetPlayerData(player_name)
      if table.getn(record_table) > 0 then
        local hp = record_table[TEAM_SUB_REC_COL_HPRATIO + 1]
        local mp = record_table[TEAM_SUB_REC_COL_MPRATIO + 1]
        local sp = record_table[TEAM_SUB_REC_COL_SPRATIO + 1]
        local buffers = record_table[TEAM_SUB_REC_COL_BUFFERS + 1]
        local pbar_hp = group:Find("pbar_hp_" .. i)
        if nx_is_valid(pbar_hp) then
          pbar_hp.Value = nx_int(hp)
        end
        local pbar_mp = group:Find("pbar_mp_" .. i)
        if nx_is_valid(pbar_mp) then
          pbar_mp.Value = nx_int(mp)
        end
        show_nuqi_value(group, sp, i)
        local imagegrid_buffer = group:Find("imagegrid_buffer_" .. i)
        if nx_is_valid(imagegrid_buffer) and nx_string(imagegrid_buffer.DataSource) ~= nx_string(buffers) then
          imagegrid_buffer.DataSource = buffers
          set_buff_icon(imagegrid_buffer, buffers)
        end
      end
    end
  end
end
function refresh_PlayerPhoto_State(client_player, col, line, control)
  if not nx_is_valid(client_player) then
    return true
  end
  local num = string.sub(nx_string(control.Name), -1, -1)
  local groupbox = control.Parent
  local lblname = groupbox:Find("lbl_name_" .. num)
  local parhp = groupbox:Find("pbar_hp_" .. num)
  local parmp = groupbox:Find("pbar_mp_" .. num)
  if col == TEAM_REC_COL_SCENE then
    local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(client_player:QueryProp("Name")))
    if row < 0 then
      return true
    end
    local sceneid = nx_string(client_player:QueryRecord(TEAM_REC, row, col))
    local playersceneid = nx_string(client_player:QueryRecord(TEAM_REC, line, col))
    if nx_string(sceneid) == nx_string(playersceneid) then
      if nx_is_valid(lblname) then
        lblname.ForeColor = COLOR_DEFAULT
      end
      if nx_is_valid(parhp) then
        parhp.ProgressImage = hp_def_img
      end
      if nx_is_valid(parmp) then
        parmp.ProgressImage = mp_def_img
      end
      return true
    else
      if nx_is_valid(lblname) then
        lblname.ForeColor = COLOR_GRAY
      end
      if nx_is_valid(parhp) then
        parhp.ProgressImage = hp_other_img
      end
      if nx_is_valid(parmp) then
        parmp.ProgressImage = mp_other_img
      end
      return false
    end
  elseif col == TEAM_REC_COL_ISOFFLINE then
    local offlineState = nx_string(client_player:QueryRecord(TEAM_REC, line, col))
    if nx_number(offlineState) > nx_number(0) then
      if nx_is_valid(lblname) then
        lblname.ForeColor = COLOR_GRAY
      end
      if nx_is_valid(parhp) then
        parhp.ProgressImage = hp_gray_img
      end
      if nx_is_valid(parmp) then
        parmp.ProgressImage = mp_gray_img
      end
      return false
    else
      if nx_is_valid(lblname) then
        lblname.ForeColor = COLOR_DEFAULT
      end
      if nx_is_valid(parhp) then
        parhp.ProgressImage = hp_def_img
      end
      if nx_is_valid(parmp) then
        parmp.ProgressImage = mp_def_img
      end
      return true
    end
  end
end
function get_role_TeamPos(form, client_player)
  if form.team_type == TYPE_LARGE_TEAM then
    local row_count = client_player:GetRecordRows(TEAM_REC)
    for i = 0, row_count - 1 do
      local name = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_NAME)
      if nx_string(name) == nx_string(client_player:QueryProp("Name")) then
        local teampos = client_player:QueryRecord(TEAM_REC, i, TEAM_REC_COL_TEAMPOSITION)
        return teampos
      end
    end
  end
  return -1
end
function can_refresh_team_panel()
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return false
  end
  local bMovieEffect = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
  if bMovieEffect then
    return false
  end
  local bTeamFaculty = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_wuxue\\form_team_faculty_member")
  if bTeamFaculty then
    return false
  end
  return true
end
function show_team_line(form, line, visible)
  local group_box = form:Find("group_" .. line + 1)
  if nx_is_valid(group_box) then
    group_box.Visible = visible
  end
end
function on_show_team_menu(self, membername)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "team", "team")
  nx_execute("menu_game", "menu_recompose", menu_game, membername)
  local x, y = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, x + 25, y)
end
function on_mouse_right_click(self)
  local num = string.sub(nx_string(self.Name), -1, -1)
  local groupbox = self.Parent
  local control = groupbox:Find("lbl_name_" .. num)
  if nx_is_valid(control) then
    on_show_team_menu(groupbox, control.Text)
  end
end
function on_group_right_click(self)
  local num = string.sub(nx_string(self.Name), -1, -1)
  local control = self:Find("lbl_name_" .. num)
  if nx_is_valid(control) then
    on_show_team_menu(self, control.Text)
  end
end
function set_buff_icon(grid, buff_ids)
  grid:Clear()
  local buff_lst = util_split_string(buff_ids, " ")
  local count = nx_number(table.getn(buff_lst))
  local icon_index_up = 0
  local icon_index_down = 6
  local bShow = false
  for i = 1, count do
    if i >= grid.RowNum * grid.ClomnNum then
      return
    end
    buff_id = buff_lst[i]
    local tmp_buff_id = string.sub(buff_id, 0, -3)
    local photo = buff_static_query(nx_string(tmp_buff_id), "Photo")
    local buff_visible = buff_static_query(tmp_buff_id, "Visible")
    local buff_damage = buff_static_query(tmp_buff_id, "IsDamage")
    if nx_int(buff_visible) ~= nx_int(0) and nx_string(buff_visible) ~= nx_string("") and buff_visible ~= nil then
      if buff_damage == 0 and icon_index_up < 6 then
        grid:AddItem(icon_index_up, nx_string(photo), nx_widestr(nx_string(buff_id)), 1, -1)
        icon_index_up = icon_index_up + 1
      elseif icon_index_down < 12 then
        grid:AddItem(icon_index_down, nx_string(photo), nx_widestr(nx_string(buff_id)), 1, -1)
        icon_index_down = icon_index_down + 1
      end
      bShow = true
    end
  end
  grid.Visible = bShow
end
function on_imagegrid_buffer_mousein_grid(grid, index)
  local buff_id = nx_string(grid:GetItemName(index))
  local tmp_buff_id = string.sub(buff_id, 0, -3)
  local buff_visible = buff_static_query(tmp_buff_id, "Visible")
  if buff_id == "" or buff_id == nil or buff_visible == 0 then
    return
  end
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("desc_" .. nx_string(buff_id)), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_imagegrid_buffer_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_nuqi_value(group, value, index)
  if not nx_is_valid(group) then
    return
  end
  local num = nx_int(value * 5)
  num = nx_number(num)
  if num < 1 then
    num = 0
  end
  if 5 < num then
    num = 5
  end
  local name = ""
  local lbl
  local close_image = "gui\\mainform\\zudui_nv3.png"
  local open_image = "gui\\mainform\\zudui_nv4.png"
  if 0 < num then
    for i = 1, num do
      name = "lbl_nv" .. nx_string(index) .. "_" .. nx_string(i + 1)
      lbl = group:Find(name)
      if nx_is_valid(lbl) then
        lbl.BackImage = open_image
      end
    end
  end
  if num < 5 then
    for i = num + 1, 5 do
      name = "lbl_nv" .. nx_string(index) .. "_" .. nx_string(i + 1)
      lbl = group:Find(name)
      if nx_is_valid(lbl) then
        lbl.BackImage = close_image
      end
    end
  end
  local photo = ""
  if 0 < num then
    photo = "gui\\mainform\\zudui_nv2.png"
  else
    photo = "gui\\mainform\\zudui_nv1.png"
  end
  local control = group:Find("lbl_nv" .. nx_string(index) .. "_1")
  if nx_is_valid(control) then
    control.BackImage = photo
  end
end
function show_member_tips(player_name)
  local gui = nx_value("gui")
  local out_text = nx_widestr("")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local captain_name = client_player:QueryProp("TeamCaptain")
  local team_type = client_player:QueryProp("TeamType")
  local row = client_player:FindRecordRow(TEAM_REC, TEAM_REC_COL_NAME, nx_widestr(player_name))
  if row < 0 then
    return
  end
  local scene = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCENE)
  local playerwork = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_TEAMWORK)
  local leveltitle = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_LEVELTITLE)
  local OffLinetime = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_ISOFFLINE)
  local school = client_player:QueryRecord(TEAM_REC, row, TEAM_REC_COL_SCHOOL)
  gui.TextManager:Format_SetIDName("tips_team_player_name")
  gui.TextManager:Format_AddParam(player_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br/>")
  local work_name = ""
  if nx_ws_equal(nx_widestr(player_name), nx_widestr(captain_name)) then
    work_name = gui.TextManager:GetText(nx_int(team_type) == nx_int(TYPE_LARGE_TEAM) and "ui_team_work_tuanzhang" or "ui_team_work_duizhang")
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_LEADER) then
    work_name = gui.TextManager:GetText("ui_team_work_fenpeiduizhang")
  elseif nx_int(playerwork) == nx_int(TYPE_NORAML_ASSIST) then
    work_name = gui.TextManager:GetText("ui_team_work_zhuli")
  else
    work_name = gui.TextManager:GetText("ui_team_work_none")
  end
  gui.TextManager:Format_SetIDName("tips_team_player_work")
  gui.TextManager:Format_AddParam(work_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br/>")
  local school_name = ""
  if school == nil or nx_string(school) == nx_string("") then
    school_name = gui.TextManager:GetText("ui_none")
  else
    school_name = gui.TextManager:GetText(school)
  end
  gui.TextManager:Format_SetIDName("tips_team_player_school")
  gui.TextManager:Format_AddParam(school_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br/>")
  local title_name = gui.TextManager:GetText("desc_" .. nx_string(leveltitle))
  gui.TextManager:Format_SetIDName("tips_team_player_leveltitle")
  gui.TextManager:Format_AddParam(title_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br/>")
  local scene_name = gui.TextManager:GetText(scene)
  gui.TextManager:Format_SetIDName("tips_team_player_scene")
  gui.TextManager:Format_AddParam(scene_name)
  out_text = out_text .. nx_widestr(gui.TextManager:Format_GetText())
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(out_text), x, y, -1, "0-0")
  end
end
function on_lbl_photo_get_capture(label)
  local labelname = nx_string(label.Name)
  local index = string.sub(labelname, string.len(labelname))
  local groupbox = label.Parent
  local lbl_name = groupbox:Find("lbl_name_" .. index)
  if not nx_is_valid(lbl_name) then
    return
  end
  show_member_tips(lbl_name.Text)
end
function on_lbl_photo_lost_capture(label)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_photo_click(label)
  local labelname = nx_string(label.Name)
  local index = string.sub(labelname, string.len(labelname))
  local groupbox = label.Parent
  local lbl_name = groupbox:Find("lbl_name_" .. index)
  if nx_is_valid(lbl_name) then
    select_teamlist_headphoto(lbl_name.Text)
  end
end
function select_teamlist_headphoto(player_name)
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local scene = game_client:GetScene()
  local scene_obj_table = scene:GetSceneObjList()
  for i, val in ipairs(scene_obj_table) do
    if not nx_is_valid(val) then
      return
    end
    if nx_ws_equal(nx_widestr(player_name), nx_widestr(val:QueryProp("Name"))) then
      local target_obj = game_visual:GetSceneObj(val.Ident)
      if nx_is_valid(target_obj) then
        local fight = nx_value("fight")
        fight:SelectTarget(target_obj)
        return
      end
    end
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
function is_team_captain_by_name(name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local TeamCaptain = client_player:QueryProp("TeamCaptain")
  if nx_string(TeamCaptain) == nx_string(name) then
    return true
  else
    return false
  end
end
function show_chat_info(name, info)
  local game_config_info = nx_value("game_config_info")
  local show_team_chat_info = util_get_property_key(game_config_info, "show_team_chat_info", 1)
  if nx_int(show_team_chat_info) == nx_int(0) then
    return
  end
  local form = nx_value(FORM_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local playername = client_player:QueryProp("Name")
  if nx_string(playername) == nx_string(name) then
    return
  end
  for i = 1, MAX_SINGLE_TEAM_MEMBER do
    local groupbox = form:Find("group_" .. i)
    if nx_is_valid(groupbox) and groupbox.Visible then
      local lblname = groupbox:Find("lbl_name_" .. i)
      if nx_is_valid(lblname) and nx_string(lblname.Text) == nx_string(name) then
        local mltbox = form:Find("MultiTextBox_" .. i)
        if nx_is_valid(mltbox) then
          set_chat_text(groupbox, mltbox, info)
        end
      end
    end
  end
end
function set_chat_text(groupbox, mltbox, info)
  mltbox.Width = HEAD_MAX_WIDTH
  mltbox.Height = HEAD_MAX_HEIGHT
  mltbox.ViewRect = "10,10," .. HEAD_MAX_WIDTH - 10 .. "," .. HEAD_MAX_HEIGHT - 10
  mltbox.BackColor = "100,0,0,0"
  mltbox.NoFrame = true
  mltbox.Solid = true
  mltbox.BackImage = chat_backimg
  mltbox.Font = "HEIT12"
  mltbox.TextColor = "255,0,0,0"
  mltbox.LineHeight = 1
  mltbox.HtmlText = nx_widestr(info)
  mltbox.Width = 20 + mltbox:GetContentWidth()
  mltbox.Height = 20 + mltbox:GetContentHeight()
  if mltbox.Width < 60 or mltbox.Height < 42 then
    local gap_Width = 60 - mltbox.Width
    local gap_Height = 42 - mltbox.Height
    local draw_left = 0
    local draw_top = 0
    if gap_Width < 0 then
      draw_left = 10
    else
      mltbox.Width = 60
      draw_left = 10 + gap_Width / 2
    end
    if gap_Height < 0 then
      draw_top = 7
    else
      mltbox.Height = 42
      draw_top = 7 + gap_Height / 2
    end
    mltbox.ViewRect = nx_string(draw_left .. "," .. draw_top .. "," .. mltbox:GetContentWidth() + draw_left .. "," .. 10 + mltbox:GetContentHeight() + draw_top)
  else
    mltbox.ViewRect = "10,7," .. mltbox:GetContentWidth() .. "," .. 10 + mltbox:GetContentHeight()
  end
  mltbox.Top = groupbox.Top + 40 - mltbox.Height
  mltbox.Visible = true
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", mltbox)
    timer:Register(5000, 1, nx_current(), "timer_callback", mltbox, -1, -1)
  end
end
function timer_callback(mltbox, param1, param2)
  mltbox.Visible = false
end
function update_team_panel()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  local form = nx_value(FORM_MAIN_TEAM)
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", FORM_MAIN_TEAM, true, false)
    if not nx_is_valid(form) then
      return
    end
    form.Visible = false
  end
  local team_id = game_role:QueryProp("TeamID")
  if nx_int(team_id) <= nx_int(0) then
    return
  end
  refresh_base_info(form)
  local form_logic = nx_value("form_main_team_logic")
  if nx_is_valid(form_logic) then
    form_logic:RefreshOtherInfo(form)
  end
end
function hide_team_panel()
  local form = nx_value(FORM_MAIN_TEAM)
  if not nx_is_valid(form) then
    return
  end
  for i = 0, MAX_SINGLE_TEAM_MEMBER do
    show_team_line(form, i, false)
  end
  form.Visible = false
end
function is_in_team_large()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("TeamType") then
    return
  end
  local team_type = client_player:QueryProp("TeamType")
  return nx_int(TYPE_LARGE_TEAM) == nx_int(team_type)
end
