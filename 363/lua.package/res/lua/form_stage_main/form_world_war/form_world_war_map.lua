require("util_functions")
require("define\\gamehand_type")
require("define\\team_rec_define")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_map"
local PLAYER_POSITION_REFRESH = 1000
local TEAM_REC = "team_rec"
local GAME_TIMER = "timer_game"
local map_config = {
  scene01 = {
    "world_war_01"
  },
  scene06 = {
    "world_war_02"
  }
}
local desc_config = {
  scene01 = {
    "ui_worldwar_daming_1",
    "ui_worldwar_xingmeng_2",
    "",
    ""
  },
  scene06 = {
    "ui_worldwar_lxc",
    "ui_worldwar_xssy",
    "ui_worldwar_blg",
    "ui_worldwar_xdm"
  }
}
function main_form_init(form)
  form.Fixed = false
  form.lbl_list = nx_call("util_gui", "get_arraylist", "WorldWarMapNpcData")
  form.lbl_index = nx_call("util_gui", "get_arraylist", "WorldWarMapReliveIndex")
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  load_map(self)
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
  self.rbtn_scene.Checked = true
  self.mltbox_scenedesc:Clear()
  local desc = get_basic_fight_info(self)
  self.mltbox_scenedesc:AddHtmlText(nx_widestr(desc), -1)
  self.editlineindex = 0
  self.selectlineindex = 0
  self.operateicon = nx_null()
  return 1
end
function init_from_size(form)
  if not nx_is_valid(form) then
    return
  end
  local absw = 166
  local absh = 164
  local control_name = {
    "lbl_1",
    "groupbox_npc",
    "pic_map",
    "btn_close",
    "groupbox_player_pos",
    "groupbox_zoom",
    "groupbox_1",
    "groupbox_scene",
    "groupbox_worldwar_lxc_arena",
    "cbtn_lxc_arena"
  }
  for i = 1, table.getn(control_name) do
    local control = form:Find(control_name[i])
    if nx_is_valid(control) then
      control.Left = control.Left - absw
      control.Top = control.Top - absh
    end
  end
end
function set_role_to_map_center(form)
  if not nx_find_custom(form.lbl_role, "x") and not nx_find_custom(form.lbl_role, "z") then
    return
  end
  local x = form.lbl_role.x
  local z = form.lbl_role.z
  local map_x, map_z = trans_pos_to_map(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function set_npc_to_map_center(form, lab)
  local x = lab.x
  local z = lab.z
  local map_x, map_z = trans_pos_to_map(x, z, form.pic_map.ImageWidth, form.pic_map.ImageHeight, form.pic_map.TerrainStartX, form.pic_map.TerrainStartZ, form.pic_map.TerrainWidth, form.pic_map.TerrainHeight)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  local center_x = form.pic_map.CenterX + sx / form.pic_map.ZoomWidth
  local center_z = form.pic_map.CenterY + sz / form.pic_map.ZoomHeight
  set_map_center(form, center_x, center_z)
end
function get_basic_fight_info(form)
  if not nx_is_valid(form.lbl_list) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  local npc_desc_1 = nx_widestr(util_text(desc_config[resource][1])) .. nx_widestr("<br>")
  local npc_desc_2 = nx_widestr(util_text(desc_config[resource][2])) .. nx_widestr("<br>")
  local npc_desc_3 = nx_widestr(util_text(desc_config[resource][3])) .. nx_widestr("<br>")
  local npc_desc_4 = nx_widestr(util_text(desc_config[resource][4])) .. nx_widestr("<br>")
  local child_count = form.lbl_list:GetChildCount()
  for i = 1, child_count do
    local child = form.lbl_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      local lab = child.lbl
      if nx_is_valid(lab) and nx_find_custom(lab, "SideType") and nx_number(lab.SideType) > 0 then
        local temptext = nx_widestr(util_text("NpcState_schoolwar_all_01"))
        if nx_find_custom(lab, "npcstate") then
          local index = nx_number(lab.npcstate)
          if nx_find_custom(lab, "NpcStateDesc") and lab.NpcStateDesc ~= "" then
            local state_desc = nx_function("ext_split_string", nx_string(lab.NpcStateDesc), ";")
            if table.getn(state_desc) >= index + 1 then
              temptext = nx_widestr(gui.TextManager:GetFormatText(nx_string(state_desc[index + 1])))
            end
            if nx_number(index) == 0 then
              if nx_string(temptext) == nx_string("") then
                temptext = nx_widestr(util_text("NpcState_schoolwar_all_01"))
              end
              temptext = nx_widestr("<font color=\"#9C9C9C\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            elseif nx_number(index) == 1 then
              temptext = nx_widestr("<font color=\"#008B00\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            elseif nx_number(index) == 2 then
              temptext = nx_widestr("<font color=\"#FF4500\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            elseif nx_number(index) == 3 then
              temptext = nx_widestr("<font color=\"#FF0000\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            end
          else
            temptext = nx_widestr(gui.TextManager:GetFormatText("ui_worldwar_yy_state_" .. nx_string(index)))
            if nx_number(index) == 0 then
              temptext = nx_widestr("<font color=\"#008B00\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            elseif nx_number(index) == 1 then
              temptext = nx_widestr("<font color=\"#FF4500\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            elseif nx_number(index) == 2 then
              temptext = nx_widestr("<font color=\"#FF0000\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
            end
          end
        else
          temptext = nx_widestr("<font color=\"#9C9C9C\">") .. nx_widestr(temptext) .. nx_widestr("</font>")
        end
        if nx_int(lab.SideType) == nx_int(1) then
          npc_desc_1 = nx_widestr(npc_desc_1) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        elseif nx_int(lab.SideType) == nx_int(2) then
          npc_desc_2 = nx_widestr(npc_desc_2) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        elseif nx_int(lab.SideType) == nx_int(3) then
          npc_desc_3 = nx_widestr(npc_desc_3) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        elseif nx_int(lab.SideType) == nx_int(4) then
          npc_desc_4 = nx_widestr(npc_desc_4) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        end
      end
    end
  end
  local total_desc = nx_widestr(npc_desc_1) .. nx_widestr("<br>") .. nx_widestr(npc_desc_2) .. nx_widestr("<br>") .. nx_widestr(npc_desc_3) .. nx_widestr("<br>") .. nx_widestr(npc_desc_4) .. nx_widestr("<br>")
  return total_desc
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
  local team_manager = nx_value("team_manager")
  if nx_is_valid("team_manager") then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  if nx_find_custom(self, "lbl_list") and nx_is_valid(self.lbl_list) then
    self.lbl_list:ClearChild()
    nx_destroy(self.lbl_list)
  end
  if nx_find_custom(self, "lbl_index") and nx_is_valid(self.lbl_index) then
    self.lbl_index:ClearChild()
    nx_destroy(self.lbl_index)
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
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
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
  update_team_info(form)
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
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  local current_scene = nx_widestr(gui.TextManager:GetText("ui_current_scene")) .. nx_widestr(": ") .. nx_widestr(scene_name)
  form.lbl_current_scene.Text = nx_widestr(current_scene)
  local map_ini = get_ini("ini\\ui\\worldwar\\worldwar_mapinfo.ini")
  if not nx_is_valid(map_ini) then
    return
  end
  local sec_index = map_ini:FindSectionIndex(nx_string(map_config[resource][1]))
  if sec_index < 0 then
    return
  end
  local sec_count = map_ini:GetSectionItemCount(sec_index)
  form.lbl_list:ClearChild()
  form.lbl_index:ClearChild()
  for i = 1, sec_count do
    local sec_item = map_ini:GetSectionItemValue(sec_index, i - 1)
    local item_info = nx_function("ext_split_string", sec_item, ",")
    local new_lbl, index_lbl = create_icon_lable(form, i, unpack(item_info))
    local child = form.lbl_list:GetChild("label" .. nx_string(i))
    if not nx_is_valid(child) then
      child = form.lbl_list:CreateChild("label" .. nx_string(i))
      child.lbl = new_lbl
    end
    local child_index = form.lbl_index:GetChild("label" .. nx_string(i))
    if not nx_is_valid(child_index) and index_lbl ~= nil and nx_is_valid(index_lbl) then
      child_index = form.lbl_index:CreateChild("label" .. nx_string(i))
      child_index.lbl = index_lbl
    end
  end
end
function create_icon_lable(form, index, ...)
  if table.getn(arg) < 3 then
    return nil
  end
  local gui = nx_value("gui")
  local lab = gui:Create("Label")
  if table.getn(arg) >= 5 then
    lab.Name = nx_string(arg[5])
  else
    lab.Name = "npcicon" .. nx_string(index)
  end
  local image = nx_function("ext_split_string", nx_string(arg[3]), ";")
  local imagecount = table.getn(image)
  if 0 == imagecount then
    return
  end
  if tonumber(imagecount) >= 2 then
    lab.npcstate = 0
    for i = 1, imagecount do
      local tempImage = nx_string("stateimage") .. nx_string(i - 1)
      nx_set_custom(lab, tempImage, nx_string(image[i]))
    end
  end
  lab.Width = 20
  lab.Height = 20
  lab.DrawMode = "FitWindow"
  lab.Visible = false
  lab.BackImage = nx_string(image[1])
  lab.Transparent = false
  lab.ClickEvent = true
  lab.Desc = ""
  if table.getn(arg) >= 4 then
    lab.Desc = nx_string(arg[4])
  end
  lab.NpcStateDesc = ""
  if table.getn(arg) >= 6 then
    lab.NpcStateDesc = nx_string(arg[6])
  end
  lab.NpcDetail = ""
  if table.getn(arg) >= 7 then
    lab.NpcDetail = nx_string(arg[7])
  end
  lab.SideType = 0
  if table.getn(arg) >= 8 and arg[8] ~= nil and nx_string(arg[8]) ~= "" then
    lab.SideType = nx_int(arg[8])
  end
  nx_bind_script(lab, nx_current())
  nx_callback(lab, "on_get_capture", "on_label_get_capture")
  nx_callback(lab, "on_lost_capture", "on_label_lost_capture")
  nx_callback(lab, "on_click", "on_label_click")
  form:Add(lab)
  lab.x = nx_int(arg[1])
  lab.z = nx_int(arg[2])
  set_lbl_position(lab, form.pic_map)
  local lab_index
  if table.getn(arg) >= 9 and arg[9] ~= nil and nx_string(arg[9]) ~= "" then
    lab_index = gui:Create("Label")
    lab_index.Width = 15
    lab_index.Height = 15
    lab_index.Font = "font_main"
    lab_index.ForeColor = "255,255,0,0"
    lab_index.BackImage = "gui\\special\\camera\\bg_time_out.png"
    lab_index.Align = "Right"
    lab_index.Text = nx_widestr(arg[9])
    form:Add(lab_index)
    lab_index.x = nx_int(arg[1])
    lab_index.z = nx_int(arg[2]) + nx_int(15)
    set_lbl_position(lab_index, form.pic_map, true)
  end
  return lab, lab_index
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
    local sx = offset_x - pic_map.Width / 2
    local sz = offset_y - pic_map.Height / 2
    local map_x = pic_map.CenterX + sx / pic_map.ZoomWidth
    local map_z = pic_map.CenterY + sz / pic_map.ZoomHeight
    local pos_x, pos_z = trans_pos_to_scene(map_x, map_z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
    form.lbl_pos.Text = nx_widestr(nx_string(nx_int(pos_x)) .. "," .. nx_string(nx_int(pos_z)))
  end
end
function mouse_right_up()
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_map")
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
  local mgr = nx_value("SceneCreator")
  if nx_is_valid(mgr) then
    mgr:UpdateWorldWarLxcArena(false)
  end
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
function reset_scene()
  local form = nx_value("form_stage_main\\form_world_war\\form_world_war_map")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
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
function on_label_click(lab)
  local form = lab.ParentForm
  if nx_find_custom(form, "PreNpcLabel") and nx_is_valid(form.PreNpcLabel) then
    form.PreNpcLabel.BlendColor = "255,255,255,255"
  end
  local gui = nx_value("gui")
  form.lbl_npcname.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(lab.Desc)))
  form.mltbox_npcdesc:Clear()
  if nx_find_custom(lab, "NpcDetail") then
    local text = gui.TextManager:GetFormatText(nx_string(lab.NpcDetail))
    form.mltbox_npcdesc:AddHtmlText(nx_widestr(text), -1)
  end
  form.rbtn_npc.Checked = true
  lab.BlendColor = "200,255,255,255"
  form.PreNpcLabel = lab
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
function on_label_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(lbl.BackImage) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("{@0:name}({@1:x},{@2:y})", nx_string(lbl.Desc), nx_int(lbl.x), nx_int(lbl.z))
  local temptext = ""
  if nx_find_custom(lbl, "npcstate") then
    local index = nx_number(lbl.npcstate)
    if nx_find_custom(lbl, "NpcStateDesc") and lbl.NpcStateDesc ~= "" then
      local state_desc = nx_function("ext_split_string", nx_string(lbl.NpcStateDesc), ";")
      if table.getn(state_desc) >= index + 1 then
        temptext = gui.TextManager:GetFormatText(nx_string(state_desc[index + 1]))
      end
    else
      temptext = gui.TextManager:GetFormatText("ui_school_war_npc_state_" .. nx_string(index))
    end
    temptext = nx_widestr("<br>") .. nx_widestr(temptext)
  end
  text = nx_widestr(text) .. nx_widestr(temptext)
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, form)
end
function on_label_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_npc_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_npc.Visible = rbtn.Checked
  form.groupbox_scene.Visible = not rbtn.Checked
end
function on_rbtn_scene_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_scene.Visible = rbtn.Checked
  form.groupbox_npc.Visible = not rbtn.Checked
  form.mltbox_scenedesc:Clear()
  local desc = get_basic_fight_info(form)
  form.mltbox_scenedesc:AddHtmlText(nx_widestr(desc), -1)
end
function on_cbtn_lxc_arena_checked_changed(rbtn)
  local form_map = rbtn.ParentForm
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  if rbtn.Checked then
    mgr:RefreshWorldWarLxcArena()
  else
    mgr:DeleteWorldWarLxcArena()
  end
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
function open_form_by_npc(...)
  if table.getn(arg) <= 0 then
    return
  end
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
  local lbl = form:Find(nx_string("worldwar10064"))
  if nx_is_valid(lbl) then
    set_npc_to_map_center(form, lbl)
    on_label_click(lbl)
  end
end
function refresh_pic_control(form)
  if not nx_is_valid(form) then
    return
  end
  on_update_role_position(form)
  refresh_npc_lbl_pos(form)
  update_npc_state(form)
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
  if not nx_is_valid(form.lbl_index) then
    return
  end
  child_count = form.lbl_index:GetChildCount()
  for i = 1, child_count do
    local child = form.lbl_index:GetChildByIndex(i - 1)
    if nx_is_valid(child) and nx_is_valid(child.lbl) then
      set_lbl_position(child.lbl, form.pic_map)
    end
  end
end
function update_npc_state(form)
  if not form.Visible then
    return
  end
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord("WorldWarNpcStateRec") then
    return
  end
  local rows = client_scene:GetRecordRows("WorldWarNpcStateRec")
  for i = 0, rows - 1 do
    local strNpcID = client_scene:QueryRecord("WorldWarNpcStateRec", tonumber(i), 0)
    local nState = client_scene:QueryRecord("WorldWarNpcStateRec", tonumber(i), 1)
    local lbl = form:Find(nx_string(strNpcID))
    if nx_is_valid(lbl) and nx_find_custom(lbl, nx_string("stateimage") .. nx_string(nState)) then
      local curimage = nx_custom(lbl, nx_string("stateimage") .. nx_string(nState))
      lbl.BackImage = nx_string(curimage)
      lbl.npcstate = nState
    end
  end
end
function get_ini(file_name)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return nx_null()
  end
  if not IniManager:IsIniLoadedToManager(nx_string(file_name)) then
    IniManager:LoadIniToManager(nx_string(file_name))
  end
  return IniManager:GetIniDocument(nx_string(file_name))
end
function close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
