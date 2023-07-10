require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("tips_data")
require("share\\view_define")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = true
  form.home_id = ""
  form.select_name = nx_widestr("")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.ipt_name.Text = get_ipt_name_default()
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_UPDATE_NEIGHBOUR)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("neighbour_rec", form, nx_current(), "on_near_home_rec_refresh")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("neighbour_rec", form)
  end
  nx_destroy(form)
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(form.home_id))
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  clear_detail(form)
  local name = form.ipt_name.Text
  if nx_ws_length(name) < 2 then
    return
  end
  form.select_name = nx_widestr(name)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ROLE_HOMES, nx_widestr(name))
end
function on_btn_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textgrid_home.RowSelectIndex
  if row < 0 then
    return
  end
  local home_id = nx_string(form.textgrid_home:GetGridText(row, 0))
  local home_name = nx_widestr(form.textgrid_home:GetGridText(row, 1))
  if home_id == nx_string("") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_home\\form_home_input_name", true, false)
  dialog.lbl_text.HtmlText = nx_widestr("@ui_home_qingqiu")
  dialog.ipt_name.Text = nx_widestr(home_name)
  dialog.ipt_name.ReadOnly = true
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "form_home_input_name")
  if nx_string(res) == "cancel" or nx_string(res) == "" then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ADD_NEIGHBOUR, nx_string(home_id))
end
function on_near_home_rec_refresh(form, recordname, optype, row, clomn)
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  fresh_neighbor(form)
end
function on_textgrid_list_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local homeid = nx_string(grid:GetGridText(row, 0))
  if homeid ~= nx_string("") then
    form.home_id = homeid
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY, homeid)
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HIRENPC_INFO, nx_string(homeid))
    nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_BUILDING_ACTIVE_NUMBER, nx_string(homeid))
  end
end
function on_textgrid_list_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  grid:SelectGrid(row, col)
  local home_id = nx_string(grid:GetGridText(row, 0))
  if home_id == nil or nx_string(home_id) == nx_string("") then
    return
  end
  local home_status = grid:GetGridText(row, 4)
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_neighbor", "home_neighbor")
  nx_execute("menu_game", "menu_recompose", menu_game, home_status)
  menu_game.home_id = nx_string(home_id)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function on_textgrid_home_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(grid:GetGridText(row, 0))
  form.home_id = home_id
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_QUERY, home_id)
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_HIRENPC_INFO, nx_string(home_id))
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_REQUEST_BUILDING_ACTIVE_NUMBER, nx_string(home_id))
end
function on_textgrid_home_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  grid:SelectGrid(row, col)
  local home_id = nx_string(grid:GetGridText(row, 0))
  if home_id == nil or nx_string(home_id) == nx_string("") then
    return
  end
  local home_signid = nx_string(grid:GetGridText(row, 4))
  local home_status = grid:GetGridText(row, 3)
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_resident", "home_resident")
  nx_execute("menu_game", "menu_recompose", menu_game, home_status)
  menu_game.home_id = nx_string(home_id)
  menu_game.home_signid = nx_string(home_signid)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
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
    local homestatus = client_player:QueryRecord(recordname, i, 4)
    local home_signid = client_player:QueryRecord(recordname, i, 5)
    local home_level = client_player:QueryRecord(recordname, i, 6)
    local home_out_level = client_player:QueryRecord(recordname, i, 7)
    if 0 < nx_ws_length(name) then
      local row = form.textgrid_list:InsertRow(-1)
      form.textgrid_list:SetGridText(row, 0, nx_widestr(homeid))
      form.textgrid_list:SetGridText(row, 1, nx_widestr(homename))
      form.textgrid_list:SetGridText(row, 2, nx_widestr(nameid))
      form.textgrid_list:SetGridText(row, 4, nx_widestr(homestatus))
      if nx_number(homestatus) == nx_number(3) then
        local lbl1 = gui:Create("Label")
        lbl1.BackImage = "gui\\special\\home\\main\\chushou.png"
        lbl1.Align = "Center"
        form.textgrid_list:SetGridControl(row, 5, lbl1)
      end
      local lbl = gui:Create("Label")
      lbl.Align = "Center"
      lbl.Transparent = false
      lbl.home_id = homeid
      lbl.home_signid = home_signid
      lbl.home_level = home_level
      lbl.home_out_level = home_out_level
      lbl.home_status = homestatus
      lbl.ForeColor = form.textgrid_list.ForeColor
      lbl.Text = nx_widestr(name)
      nx_bind_script(lbl, nx_current())
      form.textgrid_list:SetGridControl(row, 3, lbl)
      nx_callback(lbl, "on_get_capture", "on_get_capture")
      nx_callback(lbl, "on_lost_capture", "on_lost_capture")
      nx_callback(lbl, "on_right_click", "on_textgrid_list_right_click")
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
  if nx_widestr(form.select_name) ~= nx_widestr(arg[1]) then
    return
  end
  form.textgrid_home:ClearSelect()
  form.textgrid_home:ClearRow()
  local gui = nx_value("gui")
  for i = 2, table.getn(arg), 7 do
    local home_id = nx_string(arg[i])
    local home_name = nx_widestr(arg[i + 1])
    local master_name = nx_widestr(arg[i + 2])
    local home_status = nx_widestr(arg[i + 3])
    local home_signid = nx_number(arg[i + 4])
    local home_level = nx_number(arg[i + 5])
    local home_out_level = nx_number(arg[i + 6])
    if home_id == nx_string("") then
      break
    end
    local row = form.textgrid_home:InsertRow(-1)
    form.textgrid_home:SetGridText(row, 0, nx_widestr(home_id))
    form.textgrid_home:SetGridText(row, 1, nx_widestr(home_name))
    form.textgrid_home:SetGridText(row, 3, nx_widestr(home_status))
    form.textgrid_home:SetGridText(row, 4, nx_widestr(home_signid))
    local lbl1 = gui:Create("Label")
    if nx_number(home_status) == nx_number(3) then
      lbl1.BackImage = "gui\\special\\home\\main\\chushou.png"
    end
    lbl1.Align = "Center"
    form.textgrid_home:SetGridControl(row, 4, lbl1)
    local lbl = gui:Create("Label")
    lbl.Align = "Center"
    lbl.Transparent = false
    lbl.home_id = home_id
    lbl.home_signid = home_signid
    lbl.home_level = home_level
    lbl.home_out_level = home_out_level
    lbl.home_status = home_status
    lbl.ForeColor = form.textgrid_home.ForeColor
    lbl.Text = nx_widestr(master_name)
    nx_bind_script(lbl, nx_current())
    form.textgrid_home:SetGridControl(row, 2, lbl)
    nx_callback(lbl, "on_get_capture", "on_get_capture")
    nx_callback(lbl, "on_lost_capture", "on_lost_capture")
    nx_callback(lbl, "on_right_click", "on_textgrid_right_click")
  end
end
function fresh_home_detail(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(arg[1])
  if home_id ~= nx_string(form.home_id) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local home_name = nx_widestr(arg[2])
  local conf_id = nx_int(arg[3])
  local master_name = nx_widestr(arg[5])
  local home_scene = nx_int(arg[6])
  local sign_id = nx_int(arg[7])
  local home_lvl = nx_int(arg[11])
  local home_status = nx_int(arg[12])
  local home_stay = nx_int(arg[13])
  local home_pretty = nx_int(arg[14])
  local home_des = nx_int(arg[15])
  form.lbl_name.Text = home_name
  local place = nx_widestr("")
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    local home_scene_father = nx_int(home_manager:GetHomeSceneID(sign_id))
    local scene_name = "scene_" .. map_query:GetSceneName(nx_string(home_scene_father))
    place = util_text(scene_name)
    local site = "(" .. nx_string(home_manager:GetHomeX(sign_id)) .. "," .. nx_string(home_manager:GetHomeZ(sign_id)) .. ")"
    place = place .. nx_widestr(site)
  end
  form.lbl_place.Text = place
  local gui = nx_value("gui")
  for i = 1, nx_number(home_lvl) do
    local lbl_star = gui:Create("Label")
    form.groupbox_x:Add(lbl_star)
    lbl_star.Name = "lbl_star_" .. nx_string(i)
    lbl_star.Left = (i - 1) * 20 + 8
    lbl_star.Top = 9
    lbl_star.BackImage = "gui\\special\\wuxue-gonglue\\skillstar_001.png"
    lbl_star.AutoSize = true
  end
  form.pbar_wear.Maximum = nx_int(home_manager:GetHomeMaxStay(sign_id, home_lvl))
  form.pbar_wear.Value = nx_int(home_stay)
  local msg_delay = nx_value("MessageDelay")
  if nx_is_valid(msg_delay) then
    local feiq_day = nx_int(msg_delay:GetServerDateTime()) - home_des
    if nx_int(feiq_day) <= nx_int(0) then
      feiq_day = nx_int(0)
    end
    local max_day = nx_int(get_ini_prop("share\\Home\\HomeSystemConf.ini", "main", "over_time_day", "0"))
    if max_day < nx_int(feiq_day) then
      feiq_day = max_day
    end
    form.pbar_feiqi.Maximum = nx_int(max_day)
    form.pbar_feiqi.Value = nx_int(feiq_day)
  end
  form.lbl_superb.Text = nx_widestr(home_pretty)
end
function fresh_guyong(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_id = nx_string(arg[1])
  if home_id ~= nx_string(form.home_id) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local num1 = nx_int(arg[2])
  local max1 = nx_int(arg[3])
  local num2 = nx_int(arg[4])
  local max2 = nx_int(arg[5])
  local num3 = nx_int(arg[6])
  local max3 = nx_int(arg[7])
  form.pbar_yahuan_2.Maximum = max1
  form.pbar_yahuan_2.Value = num1
  form.pbar_huwei.Maximum = max2
  form.pbar_huwei.Value = num2
  form.pbar_yahuan_1.Maximum = max3
  form.pbar_yahuan_1.Value = num3
end
function clear_detail(form)
  form.textgrid_home:ClearSelect()
  form.textgrid_home:ClearRow()
  form.home_id = ""
  form.select_name = nx_widestr("")
  form.lbl_name.Text = nx_widestr("")
  form.lbl_place.Text = nx_widestr("")
  form.groupbox_x:DeleteAll()
  form.pbar_wear.Maximum = 0
  form.pbar_wear.Value = 0
  form.pbar_feiqi.Maximum = 0
  form.pbar_feiqi.Value = 0
  form.lbl_superb.Text = 0
  form.pbar_huwei.Maximum = 0
  form.pbar_huwei.Value = 0
  form.pbar_yahuan_1.Maximum = 0
  form.pbar_yahuan_1.Value = 0
  form.pbar_yahuan_2.Maximum = 0
  form.pbar_yahuan_2.Value = 0
end
function on_ipt_name_get_focus(edit)
  if edit.Text == get_ipt_name_default() then
    edit.Text = nx_widestr("")
  end
end
function on_ipt_name_lost_focus(edit)
  if edit.Text == nx_widestr("") then
    edit.Text = get_ipt_name_default()
  end
end
function get_ipt_name_default()
  return util_text("ui_home_myhomeshow_34")
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
function on_textgrid_right_click(lbl)
  if not nx_is_valid(lbl) then
    return
  end
  local home_id = lbl.home_id
  local home_signid = lbl.home_signid
  local home_status = lbl.home_status
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_resident", "home_resident")
  nx_execute("menu_game", "menu_recompose", menu_game, home_status)
  menu_game.home_id = nx_string(home_id)
  menu_game.home_signid = nx_string(home_signid)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function on_textgrid_list_right_click(lbl)
  if not nx_is_valid(lbl) then
    return
  end
  local home_id = lbl.home_id
  local home_status = lbl.home_status
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_neighbor", "home_neighbor")
  nx_execute("menu_game", "menu_recompose", menu_game, home_status)
  menu_game.home_id = nx_string(home_id)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
