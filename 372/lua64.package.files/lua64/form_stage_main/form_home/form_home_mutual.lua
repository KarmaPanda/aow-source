require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("tips_data")
require("share\\view_define")
require("util_static_data")
require("share\\view_define")
local MAX_LIST_NUM = 5
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.home_id = homeid
  home_mutual_query(form)
end
function main_form_init(form)
  form.Fixed = false
  form.home_id = ""
  form.show_type = 0
  form.home_name = ""
  form.cur_page = 1
  form.max_page = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("neighbour_rec", form, nx_current(), "on_near_home_rec_refresh")
    databinder:AddViewBind(VIEWPORT_HOME_BOX, form, nx_current(), "on_view_operat_home_box")
  end
  form.rbtn_friend.Checked = true
  form.rbtn_friend.Checked = false
  fresh_home_log(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_close_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function home_mutual_query(form)
  if form.home_id == "" then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY_VISITORS, nx_string(form.home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_UPDATE_NEIGHBOUR)
end
function on_rbtn_home_page_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page_index = 0
  if btn.Checked then
    page_index = btn.DataSource
  end
  if nx_int(page_index) == nx_int(1) then
    form.textgrid_list.Visible = false
    form.textgrid_wife.Visible = true
  elseif nx_int(page_index) == nx_int(2) then
    form.textgrid_list.Visible = true
    form.textgrid_wife.Visible = false
  end
end
function on_cbtn_wife_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.textgrid_wife
  if cbtn.Checked then
    for i = 0, grid.RowCount - 1 do
      local gb = grid:GetGridControl(i, 1)
      local cbtn = gb.cbtn_mod
      if cbtn.Checked == false then
        return
      end
    end
    form.cbtn_all.Checked = true
  else
    form.cbtn_all.Checked = false
  end
end
function on_cbtn_list_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local grid = form.textgrid_list
  if cbtn.Checked then
    for i = 0, grid.RowCount - 1 do
      local gb = grid:GetGridControl(i, 1)
      local cbtn = gb.cbtn_mod
      if cbtn.Checked == false then
        return
      end
    end
    form.cbtn_all.Checked = true
  else
    form.cbtn_all.Checked = false
  end
end
function on_cbtn_all_click(cbtn)
  local form = cbtn.ParentForm
  local grid
  if form.rbtn_friend.Checked then
    grid = form.textgrid_wife
  else
    grid = form.textgrid_list
  end
  if cbtn.Checked then
    local rows = grid.RowCount
    for i = 0, rows - 1 do
      local gb = grid:GetGridControl(i, 1)
      local cbtn = gb.cbtn_mod
      if nx_is_valid(cbtn) then
        cbtn.Checked = true
      end
    end
  else
    local rows = grid.RowCount
    for i = 0, rows - 1 do
      local gb = grid:GetGridControl(i, 1)
      local cbtn = gb.cbtn_mod
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function confirm_dialog(text)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
end
function on_btn_send_click(btn)
  local form = btn.ParentForm
  local grid
  if form.rbtn_friend.Checked then
    grid = form.textgrid_wife
    if confirm_dialog(nx_widestr(util_text("ui_delete_home_neighbor"))) then
      for i = grid.RowCount - 1, 0, -1 do
        local gb = grid:GetGridControl(i, 1)
        local cbtn = gb.cbtn_mod
        if nx_is_valid(cbtn) and cbtn.Checked then
          local home_id = get_current_homeid()
          local player_id = nx_string(grid:GetGridText(i, 2))
          nx_execute("custom_sender", "custom_home", CLIENT_SUB_DEL_VISITORS, nx_string(home_id), nx_string(player_id))
        end
      end
    end
  else
    grid = form.textgrid_list
    if confirm_dialog(nx_widestr(util_text("ui_delete_home_neighbor"))) then
      for i = grid.RowCount - 1, 0, -1 do
        local gb = grid:GetGridControl(i, 1)
        local cbtn = gb.cbtn_mod
        if nx_is_valid(cbtn) and cbtn.Checked then
          local home_id = nx_string(grid:GetGridText(i, 2))
          nx_execute("custom_sender", "custom_home", CLIENT_SUB_DEL_NEIGHBOUR, nx_string(home_id))
        end
      end
    end
  end
end
function on_near_home_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_neighbor(form)
end
function fresh_neighbor(form)
  local recordname = "neighbour_rec"
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.textgrid_list:ClearRow()
  form.textgrid_list:ClearSelect()
  local gui = nx_value("gui")
  local nRows = client_player:GetRecordRows(recordname)
  for i = 0, nRows - 1 do
    local homeid = client_player:QueryRecord(recordname, i, 0)
    local homename = client_player:QueryRecord(recordname, i, 1)
    local nameid = client_player:QueryRecord(recordname, i, 2)
    local name = client_player:QueryRecord(recordname, i, 3)
    local home_signid = client_player:QueryRecord(recordname, i, 5)
    local home_level = client_player:QueryRecord(recordname, i, 6)
    local home_out_level = client_player:QueryRecord(recordname, i, 7)
    if 0 < nx_ws_length(name) then
      local row = form.textgrid_list:InsertRow(-1)
      local gb = create_ctrl("GroupBox", "gb_visit_" .. nx_string(i), form.gb_mod, nil)
      local cbtn = create_ctrl("CheckButton", "cbtn_visit_" .. nx_string(i), form.cbtn_mod, gb)
      gb.cbtn_mod = cbtn
      form.textgrid_list:SetGridControl(row, 1, gb)
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_list_checked_changed")
      form.textgrid_list:SetGridText(row, 2, nx_widestr(homeid))
      form.textgrid_list:SetGridText(row, 3, nx_widestr(homename))
      form.textgrid_list:SetGridText(row, 4, nx_widestr(nameid))
      local lbl = gui:Create("Label")
      lbl.Align = "Center"
      lbl.Transparent = false
      lbl.home_id = homeid
      lbl.home_signid = home_signid
      lbl.home_level = home_level
      lbl.home_out_level = home_out_level
      lbl.ForeColor = form.textgrid_list.ForeColor
      lbl.Text = nx_widestr(name)
      nx_bind_script(lbl, nx_current())
      form.textgrid_list:SetGridControl(row, 5, lbl)
      nx_callback(lbl, "on_get_capture", "on_get_capture")
      nx_callback(lbl, "on_lost_capture", "on_lost_capture")
      if 0 > form.textgrid_list.RowSelectIndex then
        form.textgrid_list:SelectRow(row)
      end
    end
  end
end
function fresh_wife_home(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.home_id) ~= nx_string(arg[1]) then
    return
  end
  form.textgrid_wife:ClearSelect()
  form.textgrid_wife:ClearRow()
  for i = 2, table.getn(arg), 2 do
    local player_id = nx_string(arg[i])
    local player_name = nx_widestr(arg[i + 1])
    if player_id ~= nx_string("") and nx_ws_length(player_name) > 0 then
      local row = form.textgrid_wife:InsertRow(-1)
      local gb = create_ctrl("GroupBox", "gb_wife_" .. nx_string(i / 2), form.gb_mod, nil)
      local cbtn = create_ctrl("CheckButton", "cbtn_wife_" .. nx_string(i / 2), form.cbtn_mod, gb)
      gb.cbtn_mod = cbtn
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_wife_checked_changed")
      form.textgrid_wife:SetGridControl(row, 1, gb)
      form.textgrid_wife:SetGridText(row, 2, nx_widestr(player_id))
      form.textgrid_wife:SetGridText(row, 3, nx_widestr(player_name))
    end
  end
end
function init_mutual_menu(grid, row, col, menutype, target, mutual_type)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(row) < nx_number(0) or nx_number(row) >= nx_number(grid.RowCount) then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() then
    return
  end
  grid:SelectGrid(row, col)
  local home_id
  if nx_int(mutual_type) == nx_int(1) then
    home_id = get_current_homeid()
  elseif nx_int(mutual_type) == nx_int(2) then
    home_id = nx_string(grid:GetGridText(row, 0))
  end
  if home_id == nil or nx_string(home_id) == nx_string("") then
    return
  end
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", menutype, target)
  nx_execute("menu_game", "menu_recompose", menu_game)
  menu_game.home_id = nx_string(home_id)
  if nx_int(mutual_type) == nx_int(1) then
    menu_game.player_id = nx_string(grid:GetGridText(row, 0))
  end
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function fresh_home_event(form, home_id, table_grid)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(table_grid) then
    return
  end
  table_grid:ClearRow()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("CurHomeUID") then
    return
  end
  local homeid = nx_string(client_player:QueryProp("CurHomeUID"))
  if homeid == "" or homeid ~= nx_string(home_id) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_HOME_BOX))
  if not nx_is_valid(view) then
    return
  end
  local tablename = {
    {
      "clean_rec",
      "ui_home_myhome_m1"
    },
    {
      "trouble_rec",
      "ui_home_myhome_m2"
    }
  }
  for i = 1, table.maxn(tablename) do
    if view:FindRecord(tablename[i][1]) then
      local rows = view:GetRecordRows(tablename[i][1])
      for j = 0, rows - 1 do
        local uid = nx_string(view:QueryRecord(tablename[i][1], j, 0))
        local name = nx_widestr(view:QueryRecord(tablename[i][1], j, 1))
        local value = nx_number(view:QueryRecord(tablename[i][1], j, 2))
        local time = nx_double(view:QueryRecord(tablename[i][1], j, 3))
        local year, month, day, hour, mins, sec = nx_function("ext_decode_date", nx_double(time))
        local text = util_format_string(nx_string(tablename[i][2]), nx_int(year), nx_int(month), nx_int(day), nx_widestr(name), nx_int(value))
        local row = table_grid:InsertRow(-1)
        table_grid:SetGridText(row, 0, nx_widestr(text))
      end
    end
  end
end
function get_current_homeid()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("CurHomeUID") then
    return ""
  end
  return nx_string(client_player:QueryProp("CurHomeUID"))
end
local HOME_LOG_TYPE_USE_SKILL = 1
local HOME_LOG_TYPE_LEVEL_UP = 2
local HOME_LOG_TYPE_CHANGE_NAME = 3
local HOME_LOG_TYPE_USE_FURNITURE = 4
local HOME_LOG_TYPE_ENTER_HOME = 5
local enter_type_null = 0
local enter_type_owner = 1
local enter_type_visit = 2
local enter_type_open_lock = 3
function on_view_operat_home_box(grid, optype, view_ident, index, prop_name)
  if optype ~= "updaterecord" then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  fresh_home_log(form)
end
function fresh_home_log(form)
  local gui = nx_value("gui")
  local recordname = "home_log_rec"
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
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
  local view = game_client:GetView(nx_string(VIEWPORT_HOME_BOX))
  if not nx_is_valid(view) then
    return
  end
  form.mltbox_list:Clear()
  local nRows = view:GetRecordRows(recordname)
  form.max_page = nx_int(nRows / MAX_LIST_NUM)
  if nRows > form.max_page * MAX_LIST_NUM then
    form.max_page = form.max_page + 1
  end
  form.lab_page.Text = nx_widestr(form.cur_page) .. nx_widestr(" / ") .. nx_widestr(form.max_page)
  local begin_index = (form.cur_page - 1) * MAX_LIST_NUM
  local end_index = begin_index + MAX_LIST_NUM
  if nx_int(end_index) > nx_int(nRows) then
    end_index = nRows
  end
  for i = begin_index, end_index - 1 do
    local log_time = view:QueryRecord(recordname, i, 0)
    local player_name = view:QueryRecord(recordname, i, 1)
    local player_shenfen = view:QueryRecord(recordname, i, 2)
    local log_type = view:QueryRecord(recordname, i, 3)
    local log_info_1 = view:QueryRecord(recordname, i, 4)
    local log_info_2 = view:QueryRecord(recordname, i, 5)
    local Time = os.date("*t", nx_number(log_time))
    local time_format = string.format("%d-%02d-%02d %02d:%02d:%02d", Time.year, Time.month, Time.day, Time.hour, Time.min, Time.sec)
    local info = nx_widestr("")
    if nx_number(log_type) == nx_number(HOME_LOG_TYPE_USE_SKILL) then
      local desc_id = HomeManager:GetHomeSKillDescID(nx_string(log_info_1))
      if log_info_2 ~= nil or log_info_2 ~= "" then
        info = nx_widestr(gui.TextManager:GetFormatText(nx_string(desc_id), nx_widestr(player_name), nx_widestr(log_info_2)))
      end
    elseif nx_number(log_type) == nx_number(HOME_LOG_TYPE_LEVEL_UP) then
      info = nx_widestr(gui.TextManager:GetFormatText("home_level_up", nx_int(log_info_1)))
    elseif nx_number(log_type) == nx_number(HOME_LOG_TYPE_CHANGE_NAME) then
      info = nx_widestr(gui.TextManager:GetFormatText("home_change_name", nx_widestr(log_info_2)))
    elseif nx_number(log_type) == nx_number(HOME_LOG_TYPE_USE_FURNITURE) then
      local item_name = util_text(log_info_1)
      info = nx_widestr(gui.TextManager:GetFormatText("home_use_furniture", player_name, item_name))
    elseif nx_number(log_type) == nx_number(HOME_LOG_TYPE_ENTER_HOME) then
      if nx_number(player_shenfen) == nx_number(enter_type_visit) then
        info = nx_widestr(gui.TextManager:GetFormatText("home_enter_home_a", nx_widestr(player_name)))
      elseif nx_number(player_shenfen) == nx_number(enter_type_open_lock) then
        info = nx_widestr(gui.TextManager:GetFormatText("home_enter_home_b", nx_widestr(player_name)))
      end
    end
    if nx_widestr(info) ~= nx_widestr("") then
      local out_text = nx_widestr(time_format) .. nx_widestr("<br/>") .. nx_widestr(info) .. nx_widestr("<br/>")
      ShowHomeMutualInfo(form, out_text)
    end
  end
end
function ShowHomeMutualInfo(form, info)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.mltbox_list) then
    form.mltbox_list:AddHtmlText(nx_widestr(info), -1)
  end
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_page) <= nx_int(1) then
    return
  end
  form.cur_page = form.cur_page - 1
  fresh_home_log(form)
  form.lab_page.Text = nx_widestr(form.cur_page) .. nx_widestr(" / ") .. nx_widestr(form.max_page)
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_page) >= nx_int(form.max_page) then
    return
  end
  form.cur_page = form.cur_page + 1
  fresh_home_log(form)
  form.lab_page.Text = nx_widestr(form.cur_page) .. nx_widestr(" / ") .. nx_widestr(form.max_page)
end
function on_get_capture(lbl)
  if not nx_is_valid(lbl) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local jhmgr = nx_value("JianghuExploreModule")
  if not nx_is_valid(jhmgr) then
    return
  end
  local home_signid = lbl.home_signid
  local home_level = lbl.home_level
  local home_out_level = lbl.home_out_level
  local home_sceneid = home_manager:GetHomeSceneID(nx_int(home_signid))
  local home_scenename = util_text("ui_scene_" .. nx_string(home_sceneid))
  local home_x = home_manager:GetHomeX(nx_int(home_signid))
  local home_z = home_manager:GetHomeZ(nx_int(home_signid))
  local home_style = home_manager:GetHomeStyle(nx_int(home_signid))
  local tip_text
  if nx_int(1) == nx_int(home_level) then
    tip_text = util_text("home_lvstar_1")
  elseif nx_int(2) == nx_int(home_level) then
    tip_text = util_text("home_lvstar_2")
  else
    tip_text = util_text("home_lvstar_3")
  end
  local tip_text_out = ""
  if nx_int(1) == nx_int(home_out_level) then
    tip_text_out = util_text("home_lvstar_1")
  elseif nx_int(2) == nx_int(home_out_level) then
    tip_text_out = util_text("home_lvstar_2")
  elseif nx_int(3) == nx_int(home_out_level) then
    tip_text_out = util_text("home_lvstar_3")
  end
  local text = nx_widestr(gui.TextManager:GetFormatText("tips_home_info_text", home_scenename, nx_int(home_x), nx_int(home_z), tip_text, tip_text_out, home_style))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, lbl.ParentForm)
end
function on_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_textgrid_list_right_click(lbl)
  if not nx_is_valid(lbl) then
    return
  end
  local home_id = lbl.home_id
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_neighbor", "home_neighbor")
  nx_execute("menu_game", "menu_recompose", menu_game)
  menu_game.home_id = nx_string(home_id)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(refer_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
