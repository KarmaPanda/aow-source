require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("define\\team_rec_define")
local FORM_NAME = "form_stage_main\\form_school_destroy\\form_protect_school_map"
local PLAYER_POSITION_REFRESH = 1000
local TEAM_REC = "team_rec"
local GAME_TIMER = "timer_game"
local camp_icons = {
  [1] = {
    "49.png",
    "4.png",
    "64.png"
  },
  [2] = {
    "47.png",
    "2.png",
    "62.png"
  },
  [3] = {
    "57.png",
    "10.png",
    "72.png"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.lbl_list = nx_call("util_gui", "get_arraylist", "ProtectSchoolCampList")
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  load_map_pic(self)
  self.pic_map.right_down = false
  self:ToFront(self.groupbox_zoom)
  refresh_pic_control(self)
  set_role_to_map_center(self)
  local timer = nx_value(GAME_TIMER)
  timer:Register(PLAYER_POSITION_REFRESH, -1, nx_current(), "on_update_role_position", self, -1, -1)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(TEAM_REC, self, nx_current(), "on_team_rec_update")
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  self:ToFront(self.lbl_role)
  self:ToFront(self.btn_close)
  self:ToFront(self.groupbox_player_pos)
  self:ToFront(self.groupbox_zoom)
  self:ToFront(self.btn_trace)
  self.btn_trace.Visible = false
  self.editlineindex = 0
  self.selectlineindex = 0
  self.operateicon = nx_null()
  nx_execute("custom_sender", "custom_shcool_destroy", 20)
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    self.show_role_pos = true
    asynor:AddExecute("RefreshMapScenePlayer", self, 0)
    asynor:AddExecute("RefreshMapMaskPic", self, 0)
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if nx_is_valid(visual_player) then
    self.lbl_role.x = visual_player.PositionX
    self.lbl_role.z = visual_player.PositionZ
    set_role_to_map_center(self)
  end
  return 1
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_role_position", self)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(TEAM_REC, self)
  end
  local asynor = nx_value("common_execute")
  if nx_is_valid(asynor) then
    asynor:RemoveExecute("RefreshMapScenePlayer", self)
    asynor:RemoveExecute("RefreshMapMaskPic", self)
  end
  local team_manager = nx_value("team_manager")
  if nx_is_valid("team_manager") then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  if nx_find_custom(self, "lbl_list") and nx_is_valid(self.lbl_list) then
    self.lbl_list:ClearChild()
    nx_destroy(self.lbl_list)
  end
  if nx_find_custom(self, "cmd_btn_list") and nx_is_valid(self.cmd_btn_list) then
    self.cmd_btn_list:ClearChild()
    nx_destroy(self.cmd_btn_list)
  end
  if nx_find_custom(self, "cmd_data_rec") and nx_is_valid(self.cmd_data_rec) then
    self.cmd_data_rec:ClearChild()
    nx_destroy(self.cmd_data_rec)
  end
  if nx_find_custom(self, "obs_data_rec") and nx_is_valid(self.obs_data_rec) then
    self.obs_data_rec:ClearChild()
    nx_destroy(self.obs_data_rec)
  end
  if nx_find_custom(self, "cmd_config_ini") and nx_is_valid(self.cmd_config_ini) then
    save_config_cmd_info(self)
    nx_destroy(self.cmd_config_ini)
    self.cmd_config_ini = nx_null()
  end
  nx_destroy(self)
end
function show_scene_text(form)
  local gui = nx_value("gui")
  form.mltbox_scenedesc:Clear()
  local title = gui.TextManager:GetFormatText(nx_string("ui_mmzw_dyrq_maptitle_") .. nx_string(form.school_id))
  local info = gui.TextManager:GetFormatText(nx_string("ui_mmzw_dyrq_mapinfo_") .. nx_string(form.school_id))
  form.lbl_4.Text = title
  form.mltbox_scenedesc:AddHtmlText(nx_widestr(info), -1)
end
function on_map_msg(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local n = #arg
  if n <= 8 or n % 7 ~= 1 then
    return
  end
  form.school_id = arg[1]
  for i = 2, n, 7 do
    local camp_id = arg[i]
    local camp_state = arg[i + 1]
    local camp_type = arg[i + 2]
    local npc_id = arg[i + 3]
    local x = arg[i + 4]
    local y = arg[i + 5]
    local z = arg[i + 6]
    put_camp(form, camp_id, npc_id, camp_type, camp_state, x, y, z)
  end
  show_scene_text(form)
  set_role_to_map_center(form)
  form:ToFront(form.groupbox_zoom)
end
function on_camp_msg(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local n = #arg
  if n % 2 ~= 0 then
    return
  end
  for i = 1, n, 2 do
    local camp_id = arg[i]
    local camp_state = arg[i + 1]
    update_camp(form, camp_id, camp_state)
  end
end
function put_camp(form, camp_id, npc_id, camp_type, camp_state, x, y, z)
  local camp_lbl = form.lbl_list:GetChild(get_camp_label_id(camp_id))
  if nx_is_valid(camp_lbl) then
    return
  end
  local gui = nx_value("gui")
  local lab = gui:Create("Label")
  lab.Name = get_camp_icon(camp_type, camp_state)
  lab.camp_state = camp_state
  lab.camp_type = camp_type
  lab.Width = 25
  lab.Height = 25
  lab.DrawMode = "FitWindow"
  lab.Visible = false
  lab.BackImage = get_camp_icon(camp_type, camp_state)
  lab.Transparent = false
  lab.ClickEvent = true
  lab.Desc = text
  nx_bind_script(lab, nx_current())
  nx_callback(lab, "on_get_capture", "on_label_get_capture")
  nx_callback(lab, "on_lost_capture", "on_label_lost_capture")
  nx_callback(lab, "on_click", "on_label_click")
  form:Add(lab)
  lab.x = x
  lab.y = y
  lab.z = z
  lab.npc_id = npc_id
  set_lbl_position(lab, form.pic_map)
  local camp_label_id = get_camp_label_id(camp_id)
  local child = form.lbl_list:GetChild(camp_label_id)
  if not nx_is_valid(child) then
    child = form.lbl_list:CreateChild(camp_label_id)
    child.lbl = lab
  end
end
function update_camp(form, camp_id, camp_state)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local child = form.lbl_list:GetChild(get_camp_label_id(camp_id))
  if not nx_is_valid(child) then
    return
  end
  local lbl = child.lbl
  lbl.camp_state = camp_state
  lbl.BackImage = get_camp_icon(lbl.camp_type, camp_state)
end
function on_label_click(lab)
  local form = lab.ParentForm
  local path_finding = nx_value("path_finding")
  path_finding:TraceTargetByID(form.current_map, nx_float(lab.x), nx_float(lab.y), nx_float(lab.z), 1.8, lab.npc_id)
end
function get_camp_icon(camp_type, camp_state)
  if camp_type < 1 or 3 < camp_type or camp_state < 0 or 2 < camp_state then
    return ""
  end
  local camp_icon = camp_icons[camp_type][camp_state + 1]
  return nx_string("gui\\special\\WorldWar\\menuicon\\") .. nx_string(camp_icon)
end
function get_camp_label_id(camp_id)
  return "label" .. nx_string(camp_id)
end
function get_camp_state_text(camp_state)
  if camp_state == 0 then
    return "mmzw_dyrq_camp_status_safe"
  elseif camp_state == 1 then
    return "mmzw_dyrq_camp_status_underattack"
  elseif camp_state == 2 then
    return "mmzw_dyrq_camp_status_fall"
  end
  return ""
end
function on_label_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(lbl.BackImage) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text = lbl.Desc
  if nx_find_custom(lbl, "camp_type") then
    local school_name = nx_string("")
    local school_extinct = nx_value("SchoolExtinct")
    if nx_is_valid(school_extinct) then
      school_name = school_extinct:GetSchoolName(nx_int(form.school_id))
    end
    local str_camp_type = gui.TextManager:GetText(nx_string("mmzw_dyrq_camp_type_") .. nx_string(lbl.camp_type))
    local str_npc_name = gui.TextManager:GetText(lbl.npc_id)
    local str_school = gui.TextManager:GetText(school_name)
    local str_camp_status = gui.TextManager:GetText(nx_string(get_camp_state_text(lbl.camp_state)))
    text = gui.TextManager:GetFormatText(nx_string("tips_mmzw_dyrq_camp"), str_school, str_camp_type, str_npc_name, nx_int(lbl.x), nx_int(lbl.z), str_camp_status)
  end
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, form)
end
function init_from_size(form)
  if not nx_is_valid(form) then
    return
  end
  local absw = 166
  local absh = 164
  local control_name = {
    "lbl_1",
    "pic_map",
    "btn_close",
    "groupbox_player_pos",
    "groupbox_zoom",
    "groupbox_scene"
  }
  for i = 1, table.getn(control_name) do
    local control = form:Find(control_name[i])
    if nx_is_valid(control) then
      control.Left = control.Left - absw
      control.Top = control.Top - absh
    end
  end
end
function on_btn_find_pos_click(self)
  local form = self.ParentForm
  local x = nx_number(form.ipt_x.Text)
  local y = nx_number(form.ipt_y.Text)
  if not point_is_in_map(form, x, y) then
    return
  end
  set_pos_to_map_center(form, x, y)
  set_trace_npc_id(nil, x, -10000, y, form.current_map, true)
end
function point_is_in_map(form, x, y)
  local gui = nx_value("gui")
  if "" == nx_string(form.ipt_x.Text) or "" == nx_string(form.ipt_y.Text) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
    if nx_is_valid(dialog) then
      dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_map_zuobiao_Tips")), -1)
      dialog.Left = form.Left + (form.Width - dialog.Width) / 2
      dialog.Top = form.Top + (form.Height - dialog.Height) / 2
      dialog:ShowModal()
    end
    return false
  end
  local start_x = form.pic_map.TerrainStartX
  local start_y = form.pic_map.TerrainStartZ
  local map_width = form.pic_map.TerrainWidth
  local map_height = form.pic_map.TerrainHeight
  if x < start_x or x > start_x + map_width or y < start_y or y > start_y + map_height then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
    if nx_is_valid(dialog) then
      dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_map_zuobiao_serch")), -1)
      dialog.Left = form.Left + (form.Width - dialog.Width) / 2
      dialog.Top = form.Top + (form.Height - dialog.Height) / 2
      dialog:ShowModal()
    end
    return false
  end
  return true
end
function on_btn_trace_click(self)
  local form = self.ParentForm
  local map_query = form.map_query
  if not nx_find_custom(map_query, "x") or map_query.x == nil then
    return
  end
  if not nx_find_custom(map_query, "y") or map_query.y == nil then
    return
  end
  if not nx_find_custom(map_query, "z") or map_query.z == nil then
    return
  end
  if not nx_find_custom(map_query, "scene_id") or map_query.scene_id == nil then
    return
  end
  local npc_id
  if nx_find_custom(map_query, "npc_id") and map_query.npc_id ~= nil then
    npc_id = map_query.npc_id
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  if trace_flag == 3 then
    return
  end
  if npc_id == nil then
    path_finding:FindPathScene(map_query.scene_id, map_query.x, map_query.y, map_query.z, 0)
  else
    path_finding:TraceTargetByID(map_query.scene_id, map_query.x, map_query.y, map_query.z, 1.8, map_query.npc_id)
  end
end
function on_btn_trace_get_capture(self)
  local form = self.ParentForm
  local map_query = form.map_query
  local x, z, npc_id, scene_id
  if not nx_find_custom(map_query, "x") then
    return
  end
  if not nx_find_custom(map_query, "z") then
    return
  end
  if not nx_find_custom(map_query, "scene_id") then
    return
  end
  x = map_query.x
  z = map_query.z
  scene_id = map_query.scene_id
  if nx_find_custom(map_query, "npc_id") then
    npc_id = map_query.npc_id
  end
  local text = nx_widestr("(") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(z) .. nx_widestr(")")
  local gui = nx_value("gui")
  if npc_id ~= nil and nx_string(gui.TextManager:GetText(npc_id)) ~= "" then
    text = gui.TextManager:GetText(npc_id) .. nx_widestr("<br>") .. text
  end
  if scene_id ~= nil and form.current_map ~= scene_id then
    local scene_name = gui.TextManager:GetText("scene_" .. scene_id)
    text = nx_widestr(scene_name) .. nx_widestr("<br>") .. text
  end
  nx_execute("tips_game", "show_text_tip", text, self.AbsLeft, self.AbsTop, 0, form)
end
function on_btn_trace_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function set_trace_npc_id(npc_id, npc_x, npc_y, npc_z, scene_id, no_center)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local btn_trace = form.btn_trace
  if not nx_find_custom(btn_trace, "npc_id") then
    btn_trace.npc_id = nil
  end
  if not nx_find_custom(btn_trace, "scene_id") then
    btn_trace.scene_id = nil
  end
  form.btn_trace.old_npc_id = form.btn_trace.npc_id
  form.btn_trace.old_scene_id = form.btn_trace.scene_id
  form.btn_trace.scene_id = scene_id
  form.btn_trace.npc_id = npc_id
  form.btn_trace.x = nx_number(nx_int(npc_x))
  form.btn_trace.y = nx_number(nx_int(npc_y))
  form.btn_trace.z = nx_number(nx_int(npc_z))
  local map_query = form.map_query
  if not nx_find_custom(map_query, "npc_id") then
    map_query.npc_id = nil
  end
  if not nx_find_custom(map_query, "scene_id") then
    map_query.scene_id = nil
  end
  map_query.old_npc_id = map_query.npc_id
  map_query.old_scene_id = map_query.scene_id
  map_query.scene_id = scene_id
  map_query.npc_id = npc_id
  map_query.x = nx_number(nx_int(npc_x))
  map_query.y = nx_number(nx_int(npc_y))
  map_query.z = nx_number(nx_int(npc_z))
  if map_query.old_npc_id == nil then
    map_query.old_npc_id = map_query.npc_id
  end
  if map_query.old_scene_id == nil then
    map_query.old_scene_id = map_query.scene_id
  end
  if not no_center and npc_id ~= nil and npc_x ~= nil and npc_z ~= nil then
    if scene_id == form.current_map then
      set_pos_to_map_center(form, npc_x, npc_z)
    else
      local path_finding = nx_value("path_finding")
      if nx_is_valid(path_finding) then
        local draw_count = path_finding:GetDrawPointCount(form.current_map, true)
        if 0 < draw_count then
          dest_point = path_finding:GetPointByIndex(draw_count - 1, form.current_map)
          if dest_point ~= nil and dest_point[1] ~= nil and dest_point[3] ~= nil then
            set_pos_to_map_center(form, dest_point[1], dest_point[3])
          end
        end
      end
    end
  end
  form.btn_trace.Visible = true
  btn_trace.x = map_query.x
  btn_trace.z = map_query.z
  update_trace_pos(form)
end
function update_trace_pos(form)
  set_btn_position(form.btn_trace, form.pic_map)
  form:ToFront(form.btn_trace)
end
function set_role_to_map_center(form)
  if not nx_find_custom(form.lbl_role, "x") and not nx_find_custom(form.lbl_role, "z") then
    return
  end
  local x = form.lbl_role.x
  local z = form.lbl_role.z
  set_pos_to_map_center(form, x, z)
end
function set_pos_to_map_center(form, x, z)
  if not nx_find_custom(form.pic_map, "TerrainStartX") then
    return
  end
  local map_x, map_z = trans_pos_to_map(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_role_position(form, param1, param2)
  update_team_info(form)
  render_path_finding(form)
  update_trace_pos(form)
end
function load_map_pic(form)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local resource = client_scene:QueryProp("Resource")
  form.pic_map.Image = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  form.map_query = nx_value("MapQuery")
  form.map_query:GroupmapInit(form)
  form.groupmap_objs:Clear()
  form.groupmap_objs.Left = form.pic_map.Left
  form.groupmap_objs.Top = form.pic_map.Top
  form.groupmap_objs.Width = form.pic_map.Width
  form.groupmap_objs.Height = form.pic_map.Height
  form.groupmap_objs:InitTerrain(form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  form.current_map = resource
  form.map_query:LoadMapText(form, resource)
  form.groupmap_objs:ShowText("A", true)
  form.groupmap_objs:ShowText("B", true)
  form.groupmap_objs:ShowText("C", true)
  form:ToFront(form.groupmap_objs)
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  form.pic_map.MinZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.MinZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  form.pic_map.MaxZoomWidth = real_zoom_width * 1.5
  form.pic_map.MaxZoomHeight = real_zoom_height * 1.5
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_map.ZoomWidth = 1
  form.pic_map.ZoomHeight = 1
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  ratio = 1 - ratio
  form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
  local gui = nx_value("gui")
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  local current_scene = nx_widestr(gui.TextManager:GetText("ui_current_scene")) .. nx_widestr(": ") .. nx_widestr(scene_name)
  form.lbl_current_scene.Text = nx_widestr(current_scene)
  form.lbl_list:ClearChild()
end
function on_pic_map_mouse_move(pic_map, offset_x, offset_y)
  local form = pic_map.ParentForm
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if nx_find_custom(pic_map, "right_down") and pic_map.right_down then
    on_pic_map_drag_move(pic_map, offset_x - pic_map.click_offset_x, offset_y - pic_map.click_offset_y)
  else
    local pos_x, pos_z = get_pos_in_scene(offset_x, offset_y, pic_map)
    form.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
  end
end
function on_pic_map_left_up(pic_map, x, y)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local path_finding = nx_value("path_finding")
  local trace_flag = path_finding.AutoTraceFlag
  local pos_x, pos_z = get_pos_in_scene(x, y, pic_map)
  set_trace_npc_id(nil, pos_x, -10000, pos_z, form.current_map, false)
  if trace_flag == 1 or trace_flag == 2 then
  end
end
function mouse_right_up()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down then
    on_pic_map_right_up(form.pic_map, 0, 0)
  end
end
function on_pic_map_right_down(pic_map, x, y)
  local form = pic_map.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "snapmap", "", "", "", "")
  pic_map.right_down = true
  pic_map.click_center_x = pic_map.CenterX
  pic_map.click_center_z = pic_map.CenterY
  pic_map.click_offset_x = x
  pic_map.click_offset_y = y
end
function on_pic_map_right_up(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  pic_map.right_down = false
end
function on_tbar_zoom_value_changed(self)
  local form = self.ParentForm
  local ratio = self.Value / (self.Maximum - self.Minimum)
  ratio = 1 - ratio
  local zoom_width = form.pic_map.MinZoomWidth + ratio * (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  local zoom_height = form.pic_map.MinZoomHeight + ratio * (form.pic_map.MaxZoomHeight - form.pic_map.MinZoomHeight)
  local lbl_back = form.lbl_track
  lbl_back.AbsTop = form.tbar_zoom.TrackButton.AbsTop + form.tbar_zoom.TrackButton.Height - 2
  lbl_back.Height = form.tbar_zoom.Height - form.tbar_zoom.TrackButton.Top - form.tbar_zoom.TrackButton.Height - 2
  lbl_back.Visible = 0.0010000000000000009 < ratio
  set_map_zoom(form, zoom_width, zoom_height)
  refresh_pic_control(form)
end
function set_map_zoom(form, zoom_width, zoom_height)
  form.pic_map.ZoomWidth = zoom_width
  form.pic_map.ZoomHeight = zoom_height
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x_min > form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_min
  end
  if center_x_max < form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_max
  end
  if center_z_min > form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_min
  end
  if center_z_max < form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_max
  end
end
function on_btn_zoom_in_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = true
  while self.mouse_down_zoom_in do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth + 0.05
    local zoom_height = form.pic_map.ZoomHeight + 0.05
    if zoom_width >= form.pic_map.MaxZoomWidth or zoom_height >= form.pic_map.MaxZoomHeight then
      zoom_width = form.pic_map.MaxZoomWidth
      zoom_height = form.pic_map.MaxZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    refresh_pic_control(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
    end
  end
end
function on_btn_zoom_in_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = false
end
function on_btn_zoom_out_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = true
  while self.mouse_down_zoom_out do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local zoom_width = form.pic_map.ZoomWidth - 0.05
    local zoom_height = form.pic_map.ZoomHeight - 0.05
    if zoom_width <= form.pic_map.MinZoomWidth or zoom_height <= form.pic_map.MinZoomHeight then
      zoom_width = form.pic_map.MinZoomWidth
      zoom_height = form.pic_map.MinZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    refresh_pic_control(form)
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
    end
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function on_btn_up_click(self)
  self.mouse_down_move_up = false
end
function on_btn_up_push(self)
  local form = self.ParentForm
  self.mouse_down_move_up = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_up do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY - 10
    if center_z_min >= center_y then
      center_y = center_z_min
    end
    form.pic_map.CenterY = center_y
    refresh_pic_control(form)
    if center_z_min >= center_y then
      break
    end
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
    end
  end
end
function on_btn_down_click(self)
  self.mouse_down_move_down = false
end
function on_btn_down_push(self)
  local form = self.ParentForm
  self.mouse_down_move_down = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_down do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_y = form.pic_map.CenterY + 10
    if center_z_max <= center_y then
      center_y = center_z_max
    end
    form.pic_map.CenterY = center_y
    refresh_pic_control(form)
    if center_z_max <= center_y then
      break
    end
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
    end
  end
end
function on_btn_left_click(self)
  self.mouse_down_move_left = false
end
function on_btn_left_push(self)
  local form = self.ParentForm
  self.mouse_down_move_left = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_left do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX - 10
    if center_x_min >= center_x then
      center_x = center_x_min
    end
    form.pic_map.CenterX = center_x
    refresh_pic_control(form)
    if center_x_min >= center_x then
      break
    end
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
    end
  end
end
function on_btn_right_click(self)
  self.mouse_down_move_right = false
end
function on_btn_right_push(self)
  local form = self.ParentForm
  self.mouse_down_move_right = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_right do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form) then
      return
    end
    local center_x = form.pic_map.CenterX + 10
    if center_x_max <= center_x then
      center_x = center_x_max
    end
    form.pic_map.CenterX = center_x
    refresh_pic_control(form)
    if center_x_max <= center_x then
      break
    end
    local mgr = nx_value("SceneCreator")
    if nx_is_valid(mgr) then
      mgr:UpdateWorldWarLxcArena(false)
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
function on_pic_map_drag_move(pic_map, offset_x, offset_y)
  if not nx_find_custom(pic_map, "click_center_x") then
    return
  end
  local sx = -offset_x / pic_map.ZoomWidth * 0.5
  local sz = -offset_y / pic_map.ZoomHeight * 0.5
  local map_x = sx + pic_map.click_center_x
  local map_z = sz + pic_map.click_center_z
  local form = pic_map.ParentForm
  set_map_center(form, map_x, map_z)
end
function set_map_center(form, center_x, center_z)
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x < center_x_min then
    center_x = center_x_min
  end
  if center_x_max < center_x then
    center_x = center_x_max
  end
  if center_z < center_z_min then
    center_z = center_z_min
  end
  if center_z_max < center_z then
    center_z = center_z_max
  end
  form.pic_map.CenterX = center_x
  form.pic_map.CenterY = center_z
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdateWorldWarLxcArena(false)
  end
  refresh_pic_control(form)
end
function trans_pos_to_map(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = terrain_width - x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
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
function set_btn_position(btn, pic_map, bshow)
  if not nx_find_custom(btn, "x") and not nx_find_custom(btn, "z") then
    return
  end
  local x = btn.x
  local z = btn.z
  local sx, sz = get_pos_in_map(x, z, pic_map)
  local gui = nx_value("gui")
  btn.AbsLeft = pic_map.AbsLeft + sx - btn.Width / 2
  btn.AbsTop = pic_map.AbsTop + sz - btn.Height / 2
  btn.Visible = is_in_map(btn, pic_map)
end
function get_pos_in_map(x, z, pic_map)
  local map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function get_pos_in_scene(x, z, pic_map)
  local map_x = (x - pic_map.Width / 2) / pic_map.ZoomWidth + pic_map.CenterX
  local map_z = (z - pic_map.Height / 2) / pic_map.ZoomHeight + pic_map.CenterY
  local pos_x, pos_z = trans_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  return pos_x, pos_z
end
function is_in_map(control, pic_map)
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    return map_query:IsInMap(control, pic_map)
  end
  return false
end
function on_label_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function open_form(...)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function refresh_pic_control(form)
  if not nx_is_valid(form) then
    return
  end
  on_update_role_position(form)
  refresh_npc_lbl_pos(form)
end
function refresh_npc_lbl_pos(form)
  if not nx_is_valid(form.lbl_list) then
    return
  end
  local child_count = form.lbl_list:GetChildCount()
  for i = 1, child_count do
    local child = form.lbl_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      set_lbl_position(child.lbl, form.pic_map)
    end
  end
end
function reset_scene()
  close_form()
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function render_path_finding(form)
  form.line_path:Clear()
  form.line_path.Visible = true
  if form.current_map ~= form.map_query:GetCurrentScene() then
    return
  end
  form.map_query:RenderPathFinding(form, form.line_path, form.pic_map)
  form:ToFront(form.line_path)
end
