require("util_gui")
require("custom_sender")
require("define\\team_rec_define")
local FORM_NAME = "form_stage_main\\form_outland_war\\form_outland_war_map"
local PLAYER_POSITION_REFRESH = 100
local TEAM_POSITION_REFRESH = 1000
local TEAM_REC = "team_rec"
local GAME_TIMER = "timer_game"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.Visible = true
  form:Show()
  load_map(form)
  custom_outland_war(4)
  on_update_role_position(form)
  on_update_team_position(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(PLAYER_POSITION_REFRESH, -1, nx_current(), "on_update_role_position", form, -1, -1)
  timer:Register(TEAM_POSITION_REFRESH, -1, nx_current(), "on_update_team_position", form, -1, -1)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, form, nx_current(), "on_team_rec_update")
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", form)
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_role_position", form)
    timer:UnRegister(nx_current(), "on_update_team_position", form)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(TEAM_REC, form)
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid("team_manager") then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function auto_show_hide_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  open_form()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function load_map(form)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local resource = client_scene:QueryProp("Resource")
  form.pic_map.Image = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  form.map_query = nx_value("MapQuery")
  form.map_query:GroupmapInit(form)
  form.map_query:LoadMapText(form, resource)
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  form.pic_map.MinZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.MinZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  form.pic_map.MaxZoomWidth = real_zoom_width * 1.5
  form.pic_map.MaxZoomHeight = real_zoom_height * 1.5
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2 + 100
  form.pic_map.ZoomWidth = 1.4
  form.pic_map.ZoomHeight = 1.4
end
function update_form(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local map_info = nx_string(arg[1])
  local map_info_rec = util_split_string(map_info, ";")
  for i = 1, table.getn(map_info_rec) do
    local lbl_info_rec = util_split_string(map_info_rec[i], ",")
    if nx_number(table.getn(lbl_info_rec)) == nx_number(2) then
      local config = lbl_info_rec[1]
      local state = lbl_info_rec[2]
      local lbl = form.groupbox_1:Find("lbl_" .. config)
      lbl.BackImage = nx_string(lbl.DataSource .. nx_string(state) .. ".png")
    end
  end
end
function on_update_role_position(form, param1, param2)
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  form.lbl_role.x = visual_player.PositionX
  form.lbl_role.y = visual_player.PositionY
  form.lbl_role.z = visual_player.PositionZ
  set_lbl_position(form.lbl_role, form.pic_map)
  form.lbl_role.AngleZ = -visual_player.AngleY + math.pi
end
function on_update_team_position(form, param1, param2)
  update_team_info(form)
end
function set_lbl_position(label, pic_map, bshow)
  if not nx_is_valid(label) then
    return
  end
  if not nx_find_custom(label, "x") and not nx_find_custom(label, "z") then
    return
  end
  local x = label.x
  local z = label.z
  local sx, sz = get_pos_in_map(label.x, label.z, pic_map)
  local gui = nx_value("gui")
  label.AbsLeft = pic_map.AbsLeft + sx - label.Width / 2
  label.AbsTop = pic_map.AbsTop + sz - label.Height / 2
  if nil ~= bshow then
    label.Visible = bshow
  else
    label.Visible = is_in_map(label, pic_map)
    if label.BackImage == nil or string.len(nx_string(label.BackImage)) == 0 then
      label.Visible = false
    end
  end
end
function is_in_map(control, pic_map)
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    return map_query:IsInMap(control, pic_map)
  end
  return false
end
function get_pos_in_map(x, z, pic_map)
  local map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function trans_pos_to_map(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function update_team_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_team_info", form)
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local self_name = nx_widestr(client_player:QueryProp("Name"))
  local row_num = client_player:GetRecordRows(TEAM_REC)
  local cur_scene_id = nx_string(client_scene:QueryProp("ConfigID"))
  local back_image = "gui\\map\\npcicon\\npctype168.png"
  if nx_int(client_player:QueryProp("TeamType")) == nx_int(1) then
    back_image = "gui\\map\\npcicon\\npctype169.png"
  end
  local team_manager = nx_value("team_manager")
  if not nx_is_valid(team_manager) then
    return
  end
  for index = 0, row_num - 1 do
    local player_name = nx_widestr(client_player:QueryRecord(TEAM_REC, index, TEAM_REC_COL_NAME))
    if self_name ~= player_name then
      local scene_id = nx_string(client_player:QueryRecord(TEAM_REC, index, TEAM_REC_COL_SCENE))
      local record_table = team_manager:GetPlayerData(player_name)
      local pos_x = 0
      local pos_z = 0
      if 0 < table.getn(record_table) then
        pos_x = record_table[TEAM_SUB_REC_COL_X + 1]
        pos_z = record_table[TEAM_SUB_REC_COL_Z + 1]
      end
      if cur_scene_id == scene_id then
        local lab = form:Find(nx_string(player_name))
        if not nx_is_valid(lab) then
          lab = gui:Create("Label")
          lab.Name = nx_string(player_name)
          lab.AutoSize = true
          lab.DrawMode = "FitWindow"
          lab.BackImage = nx_string(back_image)
          lab.Visible = true
          lab.Transparent = false
          nx_bind_script(lab, nx_current())
          nx_callback(lab, "on_get_capture", "on_team_label_get_capture")
          nx_callback(lab, "on_lost_capture", "on_team_label_lost_capture")
          form:Add(lab)
        end
        form:ToFront(lab)
        lab.x = pos_x
        lab.z = pos_z
        set_lbl_position(lab, form.pic_map)
      end
    end
  end
end
function on_team_rec_update(form, tablename, ttype, line, col)
  if col ~= TEAM_REC_COL_NAME and col ~= TEAM_REC_COL_SCENE then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_team_info", form)
    timer:Register(1000, 1, nx_current(), "update_team_info", form, -1, -1)
  end
end
function on_team_sub_rec_update(form, opttype, ...)
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_X)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_Z)) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "update_team_info", form)
      timer:Register(1000, 1, nx_current(), "update_team_info", form, -1, -1)
    end
  end
end
function on_team_label_get_capture(lab)
  local form = lab.ParentForm
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("{@0:name}({@1:x},{@2:y})", nx_string(lab.Name), nx_int(lab.x), nx_int(lab.z))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, form)
end
function on_team_label_lost_capture(lab)
  local form = lab.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
