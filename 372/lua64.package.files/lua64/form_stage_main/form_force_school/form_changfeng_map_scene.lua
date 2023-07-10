local tbl_poslist = {}
function main_form_init(form)
  form.Fixed = false
  form.scene_id = 0
  form.choose_npc_config = ""
  form.choose_pos_index = -1
  form.npc_id = ""
  return 1
end
function init_scene(form, scene_id, npc_id)
  form.scene_id = scene_id
  form.npc_id = npc_id
end
function main_form_open(form)
  form.choose_npc_config = ""
  form.choose_pos_index = -1
  form.btn_ok.Enabled = false
  form.lbl_begin.Visible = false
  form.pic_map.init_width = form.pic_map.Width
  form.pic_map.init_left = form.pic_map.Left
  load_scene_res(form)
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
  local npc_config = form.choose_npc_config
  if npc_config == "" then
    return false
  end
  nx_gen_event(form, "return_cfpos_index", "ok", npc_config)
  form:Close()
end
function on_btn_choose_pos_click(btn)
  local form = btn.ParentForm
  local index = btn.index
  local length = table.getn(tbl_poslist)
  if index > length then
    return false
  end
  form.choose_npc_config = btn.npc_config
  form.choose_pos_index = index
  show_end(form, index)
  form.btn_ok.Enabled = true
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
  local name = nx_widestr(gui.TextManager:GetText(pos_name))
  local text = nx_widestr(gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">[{@0:name}]</font><br><font color=\"#ED5F00\">({@1:x},{@2:y})</font>", name, id, nx_int(posx), nx_int(posz)))
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
function get_scene_pos_list(form)
  local task_mgr = nx_value("TaskManager")
  if not nx_is_valid(task_mgr) then
    return false
  end
  tbl_poslist = {}
  local temp_poslist = {}
  temp_poslist = task_mgr:GetTransPosList(form.scene_id)
  local lenth = table.getn(temp_poslist)
  if lenth < 4 or lenth % 4 ~= 0 then
    return false
  end
  local rows = lenth / 4
  for i = 0, rows - 1 do
    local index = i * 4
    local x = temp_poslist[index + 1]
    local z = temp_poslist[index + 2]
    local pos_name = temp_poslist[index + 3]
    local npc_config = temp_poslist[index + 4]
    table.insert(tbl_poslist, {
      x,
      z,
      pos_name,
      npc_config
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
  local index = 1
  for i = 1, length do
    local x = tbl_poslist[i][1]
    local z = tbl_poslist[i][2]
    local pos_name = tbl_poslist[i][3]
    local npc_config = tbl_poslist[i][4]
    local map_x, map_y = trans_scene_pos_to_map(x, z, form.pic_map)
    local ctrl_name = "btn_" .. nx_string(index)
    local control = designer:Create("Button")
    control.npc_config = npc_config
    control.index = index
    control.is_open = 0
    control.Name = ctrl_name
    control.Top = map_y
    control.Left = map_x
    control.NormalImage = "gui\\map\\yizhan\\green-01.png"
    control.FocusImage = "gui\\map\\yizhan\\green-02.png"
    control.AutoSize = true
    designer:AddMember(ctrl_name)
    form.groupbox_map:Add(control)
    nx_bind_script(control, nx_current())
    nx_callback(control, "on_get_capture", "on_get_capture")
    nx_callback(control, "on_lost_capture", "on_lost_capture")
    nx_callback(control, "on_click", "on_btn_choose_pos_click")
    if npc_config == form.npc_id then
      form.lbl_begin.Left = control.Left - 75 + form.groupbox_map.Left
      form.lbl_begin.Top = control.Top - 75 + form.groupbox_map.Top
      form.lbl_begin.Visible = true
    end
    index = index + 1
  end
end
function load_scene_res(form)
  local resource_name = get_scene_id_by_name(form.scene_id)
  refresh_scene_map(form, resource_name)
  get_scene_pos_list(form)
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
  local length = table.getn(tbl_poslist)
  local index = form.choose_pos_index
  if length < index then
    return false
  end
  local pos_x = tbl_poslist[index][1]
  local pos_z = tbl_poslist[index][2]
  local pos_name = tbl_poslist[index][3]
  local npc_config = tbl_poslist[index][4]
  local name = nx_widestr(gui.TextManager:GetText(pos_name))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_delete_point2", name, nx_int(pos_x), nx_int(pos_z)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  form.choose_npc_config = ""
  form.choose_pos_index = -1
  form.btn_ok.Enabled = false
  form.lbl_end.Visible = false
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
