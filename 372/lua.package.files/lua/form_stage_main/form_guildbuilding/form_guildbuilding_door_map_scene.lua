local CLIENT_CUSTOMMSG_GUILDBUILDING = 1016
local CLIENT_SUBMSG_REQUEST_TRANS_POS = 141
local CLIENT_SUBMSG_REQUEST_CHOOSE_POS = 142
local CLIENT_SUBMSG_REQUEST_DELETE_POS = 143
local CLIENT_SUBMSG_REQUEST_GET_POSLIST = 144
local CLIENT_SUBMSG_REQUEST_GET_SCENE_POSLIST = 145
local tbl_poslist = {}
function main_form_init(form)
  form.Fixed = false
  form.scene_id = 0
  form.choose_pos_index = -1
  form.build_level = 0
  form.npc_id = ""
  return 1
end
function init_scene(form, scene_id, build_level, npc_id)
  form.scene_id = scene_id
  form.build_level = build_level
  form.npc_id = npc_id
end
function main_form_open(form)
  form.choose_pos_index = -1
  form.btn_ok.Enabled = false
  form.btn_delete.Enabled = false
  form.pic_map.init_width = form.pic_map.Width
  form.pic_map.init_left = form.pic_map.Left
  load_scene_res(form)
  request_opened_transpoint_list(form)
  form.lbl_end.Visible = false
end
function main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local pos_index = form.choose_pos_index
  if pos_index < 0 then
    return false
  end
  nx_gen_event(form, "return_pos_index", "ok", pos_index)
  form:Close()
end
function on_btn_choose_pos_click(btn)
  local form = btn.ParentForm
  local index = btn.index
  local length = table.getn(tbl_poslist)
  if index > length then
    return false
  end
  form.choose_pos_index = index - 1
  local is_open = 0
  if nx_find_custom(btn, "is_open") then
    is_open = btn.is_open
  end
  if is_open == 0 then
    open_trans_point(form)
    return
  end
  show_end(form, index)
  form.btn_ok.Enabled = true
  form.btn_delete.Enabled = true
end
function on_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_get_capture(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local index = btn.index
  if tbl_poslist == nil then
    return false
  end
  local length = table.getn(tbl_poslist)
  if index > length then
    return false
  end
  local posx = tbl_poslist[index][1]
  local posz = tbl_poslist[index][2]
  local pos_name = tbl_poslist[index][3]
  local overdue_time = ""
  if nx_find_custom(btn, "overdue_time") then
    overdue_time = btn.overdue_time
  end
  local name = nx_widestr(gui.TextManager:GetText(pos_name))
  local ui_overdue_time = nx_widestr(gui.TextManager:GetText("ui_overdue_time"))
  local text = nx_widestr(gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">[{@0:name}]</font><br><font color=\"#ED5F00\">({@1:x},{@2:y})</font><br><font color=\"#ED5F00\">{@3:text}{@4:time}</font>", name, id, nx_int(posx), nx_int(posz), ui_overdue_time, overdue_time))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function get_scene_id_by_name(scene_id)
  if nil == name and "" == name then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\rule\\maplist.ini " .. get_msg_str("msg_120"))
    return false
  end
  local item_count = ini:GetSectionItemCount(0)
  local index = 0
  local scene_name = ""
  for i = 1, item_count do
    index = index + 1
    local scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if index == scene_id then
      return scene_name
    end
  end
  return ""
end
function get_trans_pos_list(form)
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  tbl_poslist = {}
  local temp_poslist = {}
  temp_poslist = gb_manager:GetTransPosList(form.scene_id, form.build_level)
  local lenth = table.getn(temp_poslist)
  if lenth < 4 or lenth % 4 ~= 0 then
    return false
  end
  local rows = lenth / 4
  for i = 0, rows - 1 do
    local index = i * 4
    local x = temp_poslist[index + 1]
    local y = temp_poslist[index + 2]
    local pos_name = temp_poslist[index + 3]
    local pos_index = temp_poslist[index + 4]
    table.insert(tbl_poslist, {
      x,
      y,
      pos_name,
      pos_index
    })
  end
  carete_button(form)
end
function carete_button(form)
  local gui = nx_value("gui")
  local designer = gui.Designer
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local length = table.getn(tbl_poslist)
  for i = 1, length do
    local x = tbl_poslist[i][1]
    local z = tbl_poslist[i][2]
    local pos_name = tbl_poslist[i][3]
    local pos_index = tbl_poslist[i][4] + 1
    local map_x, map_y = trans_scene_pos_to_map(x, z, form.pic_map)
    local ctrl_name = "btn_" .. nx_string(pos_index)
    local control = designer:Create("Button")
    control.index = pos_index
    control.is_open = 0
    control.Name = ctrl_name
    control.Top = map_y
    control.Left = map_x
    control.NormalImage = "gui\\map\\yizhan\\yellow-01.png"
    control.FocusImage = "gui\\map\\yizhan\\yellow-02.png"
    control.AutoSize = true
    designer:AddMember(ctrl_name)
    form.groupbox_map:Add(control)
    nx_bind_script(control, nx_current())
    nx_callback(control, "on_get_capture", "on_get_capture")
    nx_callback(control, "on_lost_capture", "on_lost_capture")
    nx_callback(control, "on_click", "on_btn_choose_pos_click")
  end
end
function load_scene_res(form)
  local resource_name = get_scene_id_by_name(form.scene_id)
  refresh_scene_map(form, resource_name)
  get_trans_pos_list(form)
end
function refresh_scene_map(form, resource)
  if resource == nil then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  form.pic_map.Left = form.pic_map.init_left
  form.pic_map.Width = form.pic_map.init_width
  form.pic_map.Image = map_name
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    nx_msgbox(get_msg_str("msg_418") .. file_name)
    return
  end
  local sec_index = ini:FindSectionIndex("Map")
  if sec_index < 0 then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger(sec_index, "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger(sec_index, "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger(sec_index, "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger(sec_index, "Height", 1024)
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  local max_zoom_width = real_zoom_width
  local max_zoom_height = real_zoom_height
  local min_zoom_width = form.pic_map.Width / form.pic_map.ImageWidth
  local min_zoom_height = form.pic_map.Height / form.pic_map.ImageHeight
  if max_zoom_width < min_zoom_width then
    max_zoom_width = min_zoom_width
  end
  if max_zoom_height < min_zoom_height then
    max_zoom_height = min_zoom_height
  end
  local max_zoom_value = 1.2
  if max_zoom_width > max_zoom_value then
    max_zoom_width = max_zoom_value
  end
  if max_zoom_height > max_zoom_value then
    max_zoom_height = max_zoom_value
  end
  form.pic_map.min_zoom_width = min_zoom_width
  form.pic_map.min_zoom_height = min_zoom_height
  form.pic_map.max_zoom_width = max_zoom_width
  form.pic_map.max_zoom_height = max_zoom_height
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
end
function trans_scene_pos_to_map(x, z, pic_map)
  local map_x, map_z
  map_x, map_z = trans_scene_pos_to_image(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function trans_scene_pos_to_image(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function open_trans_point(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_door_chooseitem", true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_chooseitem", "main_form_open", dialog)
  dialog:Show()
  local res, item_id = nx_wait_event(100000000, dialog, "return_item_id")
  if res == "ok" then
  else
    return false
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "choose_pos_index") then
    return false
  end
  if form.choose_pos_index < 0 then
    return false
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_table = {}
  temp_table = gb_manager:GetTransPos(form.scene_id, form.build_level, form.choose_pos_index)
  local lenth = table.getn(temp_table)
  if lenth < 2 then
    return false
  end
  local pos_x = temp_table[1]
  local pos_z = temp_table[2]
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_CHOOSE_POS), nx_int(domain_id), nx_int(form.scene_id), nx_float(pos_x), nx_float(pos_z), nx_string(item_id))
  reset_btn_image(form)
  request_opened_transpoint_list(form)
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.choose_pos_index < 0 then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local length = table.getn(tbl_poslist)
  local index = form.choose_pos_index + 1
  if length < index then
    return false
  end
  local pos_x = tbl_poslist[index][1]
  local pos_z = tbl_poslist[index][2]
  local pos_name = tbl_poslist[index][3]
  local name = nx_widestr(gui.TextManager:GetText(pos_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_delete_point2", name, nx_int(pos_x), nx_int(pos_z)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_DELETE_POS), nx_int(domain_id), nx_int(form.scene_id), nx_float(pos_x), nx_float(pos_z))
  reset_btn_image(form)
  request_opened_transpoint_list(form)
  form.choose_pos_index = -1
  form.btn_ok.Enabled = false
  form.lbl_end.Visible = false
  form.btn_delete.Enabled = false
end
function request_opened_transpoint_list(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_GET_SCENE_POSLIST), nx_int(domain_id), nx_int(form.scene_id))
end
function on_recv_pos_list(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_map_scene")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 3 ~= 0 then
    return 0
  end
  local rows = size / 3
  for i = 1, rows do
    local base = (i - 1) * 3
    local scene_id = nx_int(arg[base + 1])
    local index = nx_int(arg[base + 2])
    local overdue_time = nx_string(arg[base + 3])
    set_opened_btn(form, overdue_time, index + 1)
  end
end
function set_opened_btn(form, overdue_time, index)
  if not nx_is_valid(form) then
    return
  end
  local ctrl = form.groupbox_map:Find("btn_" .. nx_string(index))
  if not nx_is_valid(ctrl) then
    return false
  end
  ctrl.overdue_time = overdue_time
  ctrl.is_open = 1
  ctrl.NormalImage = "gui\\map\\yizhan\\green-01.png"
  ctrl.FocusImage = "gui\\map\\yizhan\\green-02.png"
end
function show_end(form, index)
  form.lbl_end.Visible = false
  local ctrl = form.groupbox_map:Find("btn_" .. nx_string(index))
  if not nx_is_valid(ctrl) then
    return false
  end
  form.lbl_end.Left = ctrl.Left - 75 + form.groupbox_map.Left
  form.lbl_end.Top = ctrl.Top - 75 + form.groupbox_map.Top
  form.lbl_end.Visible = true
end
function reset_btn_image(form)
  local gui = nx_value("gui")
  local designer = gui.Designer
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local length = table.getn(tbl_poslist)
  for i = 1, length do
    local pos_index = tbl_poslist[i][4] + 1
    local ctrl = form.groupbox_map:Find("btn_" .. nx_string(pos_index))
    if not nx_is_valid(ctrl) then
      return false
    end
    ctrl.is_open = 0
    ctrl.NormalImage = "gui\\map\\yizhan\\yellow-01.png"
    ctrl.FocusImage = "gui\\map\\yizhan\\yellow-02.png"
    ctrl.overdue_time = ""
  end
end
