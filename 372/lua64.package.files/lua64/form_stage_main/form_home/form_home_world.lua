require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
local home_status = {
  [9] = "ui_home_status_0",
  [1] = "ui_home_status_1",
  [2] = "ui_home_status_2",
  [3] = "ui_home_status_3",
  [4] = "ui_home_status_4"
}
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = true
  form.signid = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.lbl_home_info.Text = nx_widestr("(0/0)")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textgrid_list.RowSelectIndex
  if row < 0 then
    return
  end
  local home_id = nx_string(form.textgrid_list:GetGridText(row, 0))
  local home_name = nx_widestr(form.textgrid_list:GetGridText(row, 1))
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
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textgrid_list.RowSelectIndex
  if row < 0 then
    return
  end
  local home_id = nx_string(form.textgrid_list:GetGridText(row, 0))
  if nx_string(home_id) == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_ENTRY, nx_string(home_id))
end
function on_textgrid_list_select_row(grid, row)
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
  local homestatus = nx_number(grid:GetGridText(row, 3))
  local home_signid = nx_number(grid:GetGridText(row, 4))
  nx_pause(0.1)
  local gui = nx_value("gui")
  local menu_game = nx_value("menu_game")
  if not nx_is_valid(menu_game) then
    menu_game = gui:Create("Menu")
    nx_bind_script(menu_game, "menu_game", "menu_game_init")
    nx_set_value("menu_game", menu_game)
  end
  nx_execute("menu_game", "menu_game_reset", "home_resident", "home_resident")
  nx_execute("menu_game", "menu_recompose", menu_game, homestatus)
  menu_game.home_id = nx_string(home_id)
  menu_game.home_signid = nx_string(home_signid)
  local curx, cury = gui:GetCursorPosition()
  gui:TrackPopupMenu(menu_game, curx, cury)
end
function fresh_home(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.signid) ~= nx_int(arg[1]) then
    return
  end
  local gui = nx_value("gui")
  form.textgrid_list:ClearRow()
  form.textgrid_list:ClearSelect()
  for i = 2, table.getn(arg), 7 do
    local homeid = nx_string(arg[i])
    local homename = nx_widestr(arg[i + 1])
    local playername = nx_widestr(arg[i + 2])
    local homestatus = nx_number(arg[i + 3])
    local home_signid = nx_number(arg[i + 4])
    local home_level = nx_number(arg[i + 5])
    local home_out_level = nx_number(arg[i + 6])
    local text_status = ""
    if homestatus <= 0 then
      homestatus = 9
    end
    if homestatus == 3 then
      text_status = util_text(home_status[homestatus])
    end
    if nx_string(homeid) ~= nx_string("") then
      local row = form.textgrid_list:InsertRow(-1)
      form.textgrid_list:SetGridText(row, 0, nx_widestr(homeid))
      form.textgrid_list:SetGridText(row, 1, nx_widestr(homename))
      form.textgrid_list:SetGridText(row, 3, nx_widestr(homestatus))
      form.textgrid_list:SetGridText(row, 4, nx_widestr(home_signid))
      local lbl1 = gui:Create("Label")
      if nx_number(homestatus) == nx_number(3) then
        lbl1.BackImage = "gui\\special\\home\\main\\chushou.png"
      end
      lbl1.Align = "Center"
      form.textgrid_list:SetGridControl(row, 4, lbl1)
      local lbl = gui:Create("Label")
      lbl.Align = "Center"
      lbl.Transparent = false
      lbl.home_id = homeid
      lbl.home_signid = home_signid
      lbl.home_level = home_level
      lbl.home_out_level = home_out_level
      lbl.home_status = homestatus
      lbl.ForeColor = form.textgrid_list.ForeColor
      lbl.Text = nx_widestr(playername)
      nx_bind_script(lbl, nx_current())
      form.textgrid_list:SetGridControl(row, 2, lbl)
      nx_callback(lbl, "on_get_capture", "on_get_capture")
      nx_callback(lbl, "on_lost_capture", "on_lost_capture")
      nx_callback(lbl, "on_right_click", "on_textgrid_right_click")
      if 0 > form.textgrid_list.RowSelectIndex then
        form.textgrid_list:SelectRow(row)
      end
    end
  end
  update_home_info(arg[1])
end
function click_community_btn(x, y, z)
  local form = nx_value("form_stage_main\\form_home\\form_home")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.sceneid) == nx_string("") then
    return
  end
  local scene_id = form.map_query:GetSceneId(nx_string(form.sceneid))
  if nx_int(scene_id) <= nx_int(0) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local signid = home_manager:GetSignIDByPlace(nx_int(scene_id), nx_float(x), nx_float(y), nx_float(z))
  if nx_int(signid) <= nx_int(0) then
    return
  end
  local form_world = nx_value("form_stage_main\\form_home\\form_home_world")
  if nx_is_valid(form_world) then
    form_world.signid = signid
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_COMMUNITY_HOMES, nx_int(signid))
  form.lbl_place.Text = nx_widestr("")
  form.lbl_style.Text = nx_widestr("")
  form.lbl_size.Text = nx_widestr("")
  form.lbl_money.Text = nx_widestr("")
  local homeid = home_manager:GetHomeID(signid)
  local place = nx_widestr("")
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    local scene_name = "scene_" .. nx_string(form.sceneid)
    place = util_text(scene_name)
    local site = "(" .. nx_string(home_manager:GetHomeX(nx_int(signid))) .. "," .. nx_string(home_manager:GetHomeZ(nx_int(signid))) .. ")"
    place = place .. nx_widestr(site)
  end
  form.lbl_place.Text = place
  form.lbl_style.Text = util_text(home_manager:GetHomeStyle(nx_int(signid)))
  form.lbl_size.Text = util_text(home_manager:GetHomeArea(nx_int(signid), 1))
  form.lbl_money.Text = nx_widestr(trans_capital_string(nx_int64(home_manager:GetHomePrice(nx_int(signid), 1))))
end
function enable_scene_btn(groupbox)
  local form = nx_value("form_stage_main\\form_home\\form_home")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  local childlist = groupbox:GetChildControlList()
  for i = table.maxn(childlist), 1, -1 do
    local control = childlist[i]
    if nx_is_valid(control) then
      local name = nx_string(control.Name)
      if string.len(name) >= 4 then
        local x, y = string.find(name, "btn_")
        if x == 1 and y == 4 then
          local sceneid = string.sub(name, y + 1)
          if not form.map_query:IsSceneVisited(nx_string(sceneid)) then
            control.Enabled = false
          end
        end
      end
    end
  end
end
function btn_open_scene(name)
  if string.len(name) < 4 then
    return
  end
  local x, y = string.find(name, "btn_")
  if x ~= 1 or y ~= 4 then
    return
  end
  local sceneid = string.sub(name, y + 1)
  local parent_form = nx_value("form_stage_main\\form_home\\form_home")
  if not nx_is_valid(parent_form) then
    return
  end
  refresh_map(parent_form, 1, sceneid)
end
function update_home_info(signid)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  local use_count = form.textgrid_list.RowCount
  local max_count = home_manager:GetHomeMaxCount(signid)
  local info = nx_widestr("(") .. nx_widestr(use_count) .. nx_widestr("/") .. nx_widestr(max_count) .. nx_widestr(")")
  form.lbl_home_info.Text = info
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
