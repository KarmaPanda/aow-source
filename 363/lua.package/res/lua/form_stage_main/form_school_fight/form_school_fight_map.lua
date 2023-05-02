require("util_functions")
require("define\\gamehand_type")
require("define\\team_sign_define")
require("define\\team_rec_define")
local FORM_NAME = "form_stage_main\\form_school_fight\\form_school_fight_map"
local PLAYER_POSITION_REFRESH = 1000
local TEAM_REC = "team_rec"
local COLOR_REC = {
  "255,255,0,0",
  "255,0,255,0",
  "255,0,0,255",
  "255,255,255,0",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255",
  "255,0,255,255"
}
local CMD_ICON_WIDTH = 35
local CMD_ICON_HEIGHT = 35
local MAX_CMD_LINE = 12
local MAX_LINE_NODE = 5
local MAX_DEFAULT_CONFIG_CMD = 6
local MAX_CMD_DESC_WORD = 9
local MAX_CMD_NAME_WORD = 5
local MAX_PLAYER_NAME_WORD = 20
local MAX_TEAM_DESC_WORD = 10
local DEFAULT_CMD_NAME = {
  "ui_command_common_1",
  "ui_command_common_2",
  "ui_command_common_3",
  "ui_command_common_4",
  "ui_command_common_5",
  "ui_command_common_6"
}
local TimeEventName = "schoolfight002"
local TimeLimitRecTableName = "Time_Limit_Form_Rec"
local line_node_index = 13
local PUBLISH_CMD_INTERVAL = 30
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = false
  self.lbl_list = nx_call("util_gui", "get_arraylist", "SchoolFightMapNpcData")
  self.lbl_index = nx_call("util_gui", "get_arraylist", "SchoolFightMapReliveIndex")
  self.report_sel_index = nx_call("util_gui", "get_arraylist", "SchoolFightMapReportSelIndex")
end
function on_main_form_open(self)
  init_from_size(self)
  load_map(self)
  self.pic_map.right_down = false
  self.pic_map.mouse_move = false
  self.groupbox_menu.Visible = false
  self.groupbox_player_list.Visible = false
  self.groupbox_team_list.Visible = false
  self.groupbox_cmd_edit_rule.Visible = false
  self.groupbox_report_list.Visible = false
  self:ToFront(self.groupbox_move)
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
  self:ToFront(self.groupbox_move)
  self:ToFront(self.groupbox_menu)
  self:ToFront(self.groupbox_player_list)
  self:ToFront(self.groupbox_team_list)
  self:ToFront(self.groupbox_report_list)
  self.rbtn_scene.Checked = true
  self.mltbox_scenedesc:Clear()
  local desc = get_basic_fight_info(self)
  self.mltbox_scenedesc:AddHtmlText(nx_widestr(desc), -1)
  if not nx_find_custom(self, "map_draw_lines") or not nx_is_valid(self.map_draw_lines) then
    self.map_draw_lines = new_draw_lines(self, 1, "255,255,0,0")
  end
  self.editlineindex = 0
  self.selectlineindex = 0
  self.operateicon = nx_null()
  self.btn_photo.Enabled = false
  self.ipt_cmd.Enabled = false
  self.groupbox_mark.Visible = false
  self.groupbox_edit.Visible = false
  self.groupbox_team_list_btn.Visible = false
  if is_command_leader(self) then
    create_cmd_mark_list(self)
    self.groupbox_mark.Visible = true
    self.groupbox_edit.Visible = true
    self.groupbox_team_list_btn.Visible = true
    self.cmd_config_ini = load_form_config_ini()
    init_config_cmd_info(self)
  end
  self.btn_publish_cmd.Enabled = false
  self.btn_all.Enabled = false
  self.btn_kick.Enabled = false
  self.btn_refuse.Enabled = false
  return 1
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
  if not client_scene:FindRecord("SchoolFightNpcStateRec") then
    return
  end
  local rows = client_scene:GetRecordRows("SchoolFightNpcStateRec")
  for i = 0, rows - 1 do
    local strNpcID = client_scene:QueryRecord("SchoolFightNpcStateRec", tonumber(i), 0)
    local nState = client_scene:QueryRecord("SchoolFightNpcStateRec", tonumber(i), 1)
    local lbl = form:Find(nx_string(strNpcID))
    if nx_is_valid(lbl) and nx_find_custom(lbl, nx_string("stateimage") .. nx_string(nState)) then
      local curimage = nx_custom(lbl, nx_string("stateimage") .. nx_string(nState))
      lbl.BackImage = nx_string(curimage)
      lbl.npcstate = nState
    end
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
  local map_ini = get_ini("ini\\ui\\schoolfight\\schoolfight_mapinfo.ini")
  if not nx_is_valid(map_ini) then
    return
  end
  local sec_index = map_ini:FindSectionIndex(nx_string(resource))
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
  refresh_fight_time(form)
end
function refresh_pic_control(form)
  if not nx_is_valid(form) then
    return
  end
  on_update_role_position(form)
  refresh_npc_lbl_pos(form)
  update_npc_state(form)
  refresh_cmd_data_line(form)
  refresh_cmd_data_icon(form)
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
  lab.Width = 30
  lab.Height = 30
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
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_role_position", self)
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
  if nx_find_custom(self, "report_sel_index") and nx_is_valid(self.report_sel_index) then
    self.report_sel_index:ClearChild()
    nx_destroy(self.report_sel_index)
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
  if nx_find_custom(self, "map_draw_lines") and nx_is_valid(self.map_draw_lines) then
    delete_draw_lines(self, self.map_draw_lines)
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
function on_label_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
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
  local form = nx_value("form_stage_main\\form_school_fight\\form_school_fight_map")
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
  form.groupbox_menu.Visible = false
  form.operateicon = nx_null()
end
function on_pic_map_right_up(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  pic_map.right_down = false
end
function on_pic_map_left_down(pic_map)
  local form = pic_map.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  form.operateicon = nx_null()
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local pos_x, pos_z = get_pos_in_scene(x - form.pic_map.Left - form.Left, y - form.pic_map.Top - form.Top, form.pic_map)
  if not gui.GameHand:IsEmpty() then
    if nx_string(gui.GameHand.Para1) == nx_string("SchoolCmdIconHand") then
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
      dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_pic"))
      dialog.info_label.Text = nx_widestr(util_text("ui_schoolwar_pictxt"))
      dialog.allow_empty = false
      dialog.name_edit.MaxLength = MAX_CMD_DESC_WORD
      dialog:ShowModal()
      local res, text = nx_wait_event(100000000, dialog, "input_name_return")
      if res == "ok" then
        if not nx_is_valid(form) then
          return
        end
        local desc = nx_widestr(text)
        local iconindex = nx_number(gui.GameHand.Para2)
        local ident = form.editlineindex
        if iconindex == nil or nx_number(iconindex) <= 0 then
          return
        end
        if nx_number(iconindex) ~= line_node_index or not is_line_node_ident(form, ident) then
          save_line_cmd_data(form, ident)
        end
        if form.editlineindex == 0 then
          ident = get_idle_cmd_line(form)
        end
        if nx_number(ident) ~= 0 and not is_max_node_line(form, ident) then
          add_cmd_data_icon(form, ident, iconindex, pos_x, pos_z, desc)
        else
          local SystemCenterInfo = nx_value("SystemCenterInfo")
          if nx_is_valid(SystemCenterInfo) then
            SystemCenterInfo:ShowSystemCenterInfo(util_text("83191"), 2)
          end
          gui.GameHand:ClearHand()
        end
      end
    elseif nx_string(gui.GameHand.Para1) == nx_string("DefaultSchoolCmdIconHand") then
      local iconindex = nx_number(gui.GameHand.Para2)
      local desc = nx_widestr(gui.GameHand.Para3)
      local ident = form.editlineindex
      if nx_number(iconindex) ~= line_node_index or not is_line_node_ident(form, ident) then
        save_line_cmd_data(form, ident)
      end
      if form.editlineindex == 0 then
        ident = get_idle_cmd_line(form)
      end
      if nx_number(ident) ~= 0 and not is_max_node_line(form, ident) then
        add_cmd_data_icon(form, ident, iconindex, pos_x, pos_z, desc)
      else
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(util_text("83191"), 2)
        end
        gui.GameHand:ClearHand()
      end
    end
  end
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
  refresh_pic_control(form)
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
  end
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_school_fight\\form_school_fight_map")
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
          nx_bind_script(lab, nx_current(), "")
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
function get_basic_fight_info(form)
  if not nx_is_valid(form.lbl_list) then
    return
  end
  local gui = nx_value("gui")
  local def_npc_desc = nx_widestr(util_text("schoolfight_fujiang_def")) .. nx_widestr("<br>")
  local att_npc_desc = nx_widestr(util_text("schoolfight_fujiang_att")) .. nx_widestr("<br>")
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
            temptext = nx_widestr(gui.TextManager:GetFormatText("ui_school_war_npc_state_" .. nx_string(index)))
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
          def_npc_desc = nx_widestr(def_npc_desc) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        elseif nx_int(lab.SideType) == nx_int(2) then
          att_npc_desc = nx_widestr(att_npc_desc) .. nx_widestr(util_text(lab.Desc)) .. nx_widestr(" ") .. nx_widestr(temptext) .. nx_widestr("<br>")
        end
      end
    end
  end
  local total_desc = nx_widestr(def_npc_desc) .. nx_widestr("<br>") .. nx_widestr(att_npc_desc) .. nx_widestr("<br>") .. nx_widestr(util_text("ui_map_schoolwar_directions"))
  return total_desc
end
function is_command_leader(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if nx_number(client_player:QueryProp("SchoolFightCommandLeader")) == 0 then
    return false
  end
  if not nx_find_custom(form, "main_school_leader") or not form.main_school_leader then
    return false
  end
  return true
end
function iscommandleader()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if nx_number(client_player:QueryProp("SchoolFightCommandLeader")) == 1 then
    return true
  end
  return false
end
function isschoolleader()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local row = client_player:GetRecordRows("SchoolPoseRec")
  if nx_int(row) < nx_int(0) then
    return false
  end
  local player_name = client_player:QueryProp("Name")
  for i = 0, row - 1 do
    local posindex = client_player:QueryRecord("SchoolPoseRec", i, 0)
    local poseuser = client_player:QueryRecord("SchoolPoseRec", i, 1)
    local tmpindex = math.floor(math.fmod(posindex, 100) / 10)
    if nx_number(tmpindex) == 1 and nx_ws_equal(nx_widestr(player_name), nx_widestr(poseuser)) then
      return true
    end
  end
  return false
end
function request_open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  else
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 14)
  end
end
function open_form(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  save_cmd_data(form, unpack(arg))
  form.Visible = true
  form:Show()
  refresh_cmd_data_line(form)
  create_cmd_data_icon(form)
  refresh_operate_control(form)
  refresh_player_list(form)
end
function save_cmd_data(form, ...)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local arg_num = table.getn(arg)
  if nx_number(arg_num) == 0 then
    return
  end
  local arg_index = 1
  local data_source = nx_number(arg[arg_index])
  if data_source == 2 then
    form.main_school_leader = true
  end
  arg_index = arg_index + 1
  if nx_number(data_source) == 0 then
    return
  end
  local item_col = nx_number(arg[arg_index])
  local item_count = nx_number(arg[arg_index + 1])
  if nx_number(item_count) > 0 and (not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec)) then
    form.cmd_data_rec = nx_call("util_gui", "get_arraylist", "schoolcommandinforec")
  end
  if nx_find_custom(form, "cmd_data_rec") and nx_is_valid(form.cmd_data_rec) then
    form.cmd_data_rec:ClearChild()
  end
  arg_index = arg_index + 2
  local pre_ident = 0
  local pre_start = 1
  for i = 1, item_count do
    local iconindex = nx_number(arg[arg_index])
    local pozx = nx_float(arg[arg_index + 1])
    local pozz = nx_float(arg[arg_index + 2])
    local desc = nx_widestr(arg[arg_index + 3])
    local ident = nx_number(arg[arg_index + 4])
    if nx_number(pre_ident) == 0 then
      pre_ident = ident
    end
    if nx_number(pre_ident) ~= nx_number(ident) then
      pre_ident = ident
      pre_start = i
    end
    local cmd_node = form.cmd_data_rec:GetChild(nx_string(ident))
    if not nx_is_valid(cmd_node) then
      cmd_node = form.cmd_data_rec:CreateChild(nx_string(ident))
    end
    local index = i - pre_start + 1
    local child = cmd_node:CreateChild(nx_string(index))
    child.iconindex = iconindex
    child.pozx = pozx
    child.pozz = pozz
    child.desc = desc
    child.ident = ident
    arg_index = arg_index + item_col
  end
  if nx_number(data_source) == 2 then
    local obs_item_col = nx_number(arg[arg_index])
    local obs_item_count = nx_number(arg[arg_index + 1])
    if nx_number(obs_item_count) > 0 and (not nx_find_custom(form, "obs_data_rec") or not nx_is_valid(form.obs_data_rec)) then
      form.obs_data_rec = nx_call("util_gui", "get_arraylist", "schoolobserverrec")
    end
    if nx_find_custom(form, "obs_data_rec") and nx_is_valid(form.obs_data_rec) then
      form.obs_data_rec:ClearChild()
    end
    arg_index = arg_index + 2
    for j = 1, obs_item_count do
      local obsname = nx_widestr(arg[arg_index])
      local obsschool = nx_string(arg[arg_index + 1])
      local child = form.obs_data_rec:GetChild(nx_string(obsname))
      if not nx_is_valid(child) then
        child = form.obs_data_rec:CreateChild(nx_string(obsname))
      end
      child.obsname = obsname
      child.obsschool = obsschool
      arg_index = arg_index + obs_item_col
    end
    form.accept_option = nx_number(arg[arg_index])
  end
end
function refresh_cmd_data_line(form)
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  if not nx_find_custom(form, "map_draw_lines") or not nx_is_valid(form.map_draw_lines) then
    form.map_draw_lines = new_draw_lines(form, 1, "255,255,0,0")
  end
  clear_draw_lines(form.map_draw_lines)
  for i = 1, form.cmd_data_rec:GetChildCount() do
    local child = form.cmd_data_rec:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      add_line(form, form.map_draw_lines, i, child)
    end
  end
  refresh_draw_lines(form, form.map_draw_lines)
end
function create_cmd_data_icon(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  if not nx_find_custom(form, "cmd_btn_list") or not nx_is_valid(form.cmd_btn_list) then
    form.cmd_btn_list = nx_call("util_gui", "get_arraylist", "school_command_btn_icon_list")
  end
  form.cmd_btn_list:ClearChild()
  for i = 1, form.cmd_data_rec:GetChildCount() do
    local cmd_node = form.cmd_data_rec:GetChildByIndex(i - 1)
    local child_count = cmd_node:GetChildCount()
    for j = 1, child_count do
      local child = cmd_node:GetChildByIndex(j - 1)
      local image_index = nx_string(child.iconindex)
      if nx_number(j) == nx_number(child_count) and j ~= 1 then
        image_index = "end"
      end
      local btn_icon = create_new_cmd_icon_btn(image_index)
      if nx_is_valid(btn_icon) then
        btn_icon.iconindex = child.iconindex
        btn_icon.x = child.pozx
        btn_icon.z = child.pozz
        btn_icon.desc = child.desc
        btn_icon.ident = child.ident
        btn_icon.index = j
        form:Add(btn_icon)
        set_lbl_position(btn_icon, form.pic_map)
        local btn_index = nx_string(child.ident) * 100 + j
        local btn_child = form.cmd_btn_list:GetChild(nx_string(btn_index))
        if not nx_is_valid(btn_child) then
          btn_child = form.cmd_btn_list:CreateChild(nx_string(btn_index))
        end
        btn_child.btn = btn_icon
      end
    end
  end
  form:ToFront(form.groupbox_player_list)
  form:ToFront(form.groupbox_team_list)
  form:ToFront(form.groupbox_report_list)
end
function add_cmd_data_icon(form, ident, iconindex, pozx, pozz, desc)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    form.cmd_data_rec = nx_call("util_gui", "get_arraylist", "schoolcommandinforec")
  end
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(ident))
  if not nx_is_valid(cmd_node) then
    cmd_node = form.cmd_data_rec:CreateChild(nx_string(ident))
  end
  local child_count = cmd_node:GetChildCount()
  local new_index = child_count + 1
  local child = cmd_node:CreateChild(nx_string(new_index))
  child.iconindex = iconindex
  child.pozx = pozx
  child.pozz = pozz
  child.desc = desc
  child.ident = ident
  if not nx_find_custom(form, "cmd_btn_list") or not nx_is_valid(form.cmd_btn_list) then
    form.cmd_btn_list = nx_call("util_gui", "get_arraylist", "school_command_btn_icon_list")
  end
  local btn_icon = create_new_cmd_icon_btn(nx_string(iconindex))
  if nx_is_valid(btn_icon) then
    btn_icon.iconindex = child.iconindex
    btn_icon.x = child.pozx
    btn_icon.z = child.pozz
    btn_icon.desc = child.desc
    btn_icon.ident = child.ident
    btn_icon.index = new_index
    form:Add(btn_icon)
    set_lbl_position(btn_icon, form.pic_map)
    local btn_index = ident * 100 + new_index
    local btn_child = form.cmd_btn_list:CreateChild(nx_string(btn_index))
    btn_child.btn = btn_icon
  end
  refresh_cmd_data_line(form)
  form.editlineindex = ident
  form:ToFront(form.groupbox_player_list)
  form:ToFront(form.groupbox_team_list)
  form:ToFront(form.groupbox_report_list)
end
function create_new_cmd_icon_btn(iconindex)
  local file_name = "ini\\ui\\schoolfight\\schoolfight_commandicon.ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local btn_icon = gui:Create("Button")
  btn_icon.Width = CMD_ICON_WIDTH + 15
  btn_icon.Height = CMD_ICON_HEIGHT + 11
  btn_icon.AutoSize = false
  btn_icon.Transparent = false
  btn_icon.DragEvent = true
  btn_icon.DrawMode = "FitWindow"
  local item_info = ini:ReadString("icon", nx_string(iconindex), "")
  local image_arr = nx_function("ext_split_string", item_info, ";")
  btn_icon.BackImage = nx_string(image_arr[2])
  nx_bind_script(btn_icon, nx_current())
  nx_callback(btn_icon, "on_drag_move", "on_cmd_btn_drag_move")
  nx_callback(btn_icon, "on_right_click", "on_cmd_btn_right_click")
  nx_callback(btn_icon, "on_get_capture", "on_cmd_btn_get_capture")
  nx_callback(btn_icon, "on_lost_capture", "on_cmd_btn_lost_capture")
  return btn_icon
end
function refresh_cmd_data_icon(form)
  if not nx_find_custom(form, "cmd_btn_list") or not nx_is_valid(form.cmd_btn_list) then
    return
  end
  local child_count = form.cmd_btn_list:GetChildCount()
  for i = 1, child_count do
    local child = form.cmd_btn_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      set_lbl_position(child.btn, form.pic_map)
    end
  end
end
function check_position(pic_map, left, top)
  if left > pic_map.Width + pic_map.Left - CMD_ICON_WIDTH then
    left = pic_map.Width + pic_map.Left - CMD_ICON_WIDTH
  end
  if top > pic_map.Height + pic_map.Top - CMD_ICON_HEIGHT then
    top = pic_map.Height + pic_map.Top - CMD_ICON_HEIGHT
  end
  if left < pic_map.Left then
    left = pic_map.Left
  end
  if top < pic_map.Top then
    top = pic_map.Top
  end
  return left, top
end
function on_cmd_btn_drag_move(btn, drag_x, drag_y)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not iseditcmdline(form, btn.ident) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  form.pic_map.Enabled = false
  local left = btn.Left + drag_x
  local top = btn.Top + drag_y
  left, top = check_position(form.pic_map, left, top)
  local pos_x, pos_z = get_pos_in_scene(left - form.pic_map.Left + btn.Width / 2, top - form.pic_map.Top + btn.Height / 2, form.pic_map)
  btn.Left = left
  btn.Top = top
  btn.x = pos_x
  btn.z = pos_z
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(btn.ident))
  if nx_is_valid(cmd_node) then
    local data_index = math.fmod(btn.index, 100)
    local child = cmd_node:GetChild(nx_string(data_index))
    if nx_is_valid(child) then
      child.pozx = pos_x
      child.pozz = pos_z
    end
  end
  refresh_cmd_data_line(form)
  form.pic_map.Enabled = true
end
function on_cmd_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    return
  end
  form:ToFront(form.groupbox_menu)
  form.groupbox_menu.Visible = true
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  form.groupbox_menu.AbsLeft = x
  form.groupbox_menu.AbsTop = y
  form.selectlineindex = btn.ident
  form.operateicon = btn
end
function on_cmd_btn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("({@0:x},{@1:y})", nx_int(btn.x), nx_int(btn.z))
  text = nx_widestr(btn.desc) .. nx_widestr(text)
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, form)
end
function on_cmd_btn_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_edit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  form.editlineindex = form.selectlineindex
  form.groupbox_menu.Visible = false
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  if nx_number(form.editlineindex) ~= nx_number(form.selectlineindex) then
    return
  end
  save_line_cmd_data(form, form.editlineindex)
  form.groupbox_menu.Visible = false
end
function save_line_cmd_data(form, line_index)
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  if not nx_find_custom(form, "cmd_btn_list") or not nx_is_valid(form.cmd_btn_list) then
    return
  end
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(line_index))
  if not nx_is_valid(cmd_node) then
    return
  end
  for i = 1, cmd_node:GetChildCount() do
    local child = cmd_node:GetChildByIndex(i - 1)
    local btn_index = nx_number(line_index) * 100 + i
    local btn_child = form.cmd_btn_list:GetChild(nx_string(btn_index))
    if nx_is_valid(btn_child) then
      local icon_btn = btn_child.btn
      child.pozx = icon_btn.x
      child.pozz = icon_btn.z
    end
  end
  refresh_cmd_data_line(form)
  refresh_cmd_data_icon(form)
  form.editlineindex = 0
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  if not nx_find_custom(form, "operateicon") or not nx_is_valid(form.operateicon) then
    return
  end
  local operate_icon = form.operateicon
  local ident = operate_icon.ident
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  if not nx_find_custom(form, "cmd_btn_list") or not nx_is_valid(form.cmd_btn_list) then
    return
  end
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(ident))
  if not nx_is_valid(cmd_node) then
    return
  end
  for i = cmd_node:GetChildCount(), 1, -1 do
    local child = cmd_node:GetChildByIndex(i - 1)
    local btn_index = ident * 100 + i
    local child_btn = form.cmd_btn_list:GetChild(nx_string(btn_index))
    if nx_is_valid(child_btn) then
      local icon_btn = child_btn.btn
      local gui = nx_value("gui")
      form:Remove(icon_btn)
      gui:Delete(icon_btn)
    end
    form.cmd_btn_list:RemoveChild(nx_string(btn_index))
  end
  cmd_node:ClearChild()
  refresh_cmd_data_line(form)
  refresh_cmd_data_icon(form)
  form.groupbox_menu.Visible = false
end
function on_btn_default_cmd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  if not nx_find_custom(form, "operateicon") or not nx_is_valid(form.operateicon) then
    return
  end
  local operate_icon = form.operateicon
  local ini = form.cmd_config_ini
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    if nx_is_valid(rbtn) and not rbtn.Enabled then
      local sec = "cmd" .. nx_string(i)
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
      dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_custom"))
      dialog.info_label.Text = nx_widestr(util_text("ui_schoolwar_customtxt"))
      dialog.allow_empty = false
      dialog.name_edit.MaxLength = MAX_CMD_NAME_WORD
      dialog:ShowModal()
      local res, text = nx_wait_event(100000000, dialog, "input_name_return")
      if res == "ok" then
        if not nx_is_valid(form) then
          return
        end
        rbtn.Text = nx_widestr(text)
        rbtn.iconindex = operate_icon.iconindex
        rbtn.desc = nx_widestr(operate_icon.desc)
        rbtn.Enabled = true
        ini:WriteInteger(sec, "index", operate_icon.iconindex)
        ini:WriteString(sec, "name", nx_string(text))
        ini:WriteString(sec, "desc", nx_string(operate_icon.desc))
        ini:SaveToFile()
        if rbtn.Checked then
          local ini = get_ini("ini\\ui\\schoolfight\\schoolfight_commandicon.ini")
          if nx_is_valid(ini) then
            form.btn_photo.Enabled = true
            form.ipt_cmd.Enabled = true
            local item_info = ini:ReadString("icon", nx_string(rbtn.iconindex), "")
            local image_arr = nx_function("ext_split_string", item_info, ";")
            form.btn_photo.BackImage = nx_string(image_arr[1])
            form.ipt_cmd.Text = nx_widestr(rbtn.desc)
            form.btn_photo.iconindex = rbtn.iconindex
            form.btn_photo.desc = rbtn.desc
          end
        end
      end
      if not nx_is_valid(form) then
        return
      end
      form.groupbox_menu.Visible = false
      form.operateicon = nx_null()
      return
    end
  end
  form.groupbox_menu.Visible = false
  form.operateicon = nx_null()
end
function on_btn_shut_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
end
function iseditcmdline(form, ident)
  if not is_command_leader(form) then
    return false
  end
  if nx_number(form.editlineindex) ~= nx_number(ident) then
    return false
  end
  return true
end
function send_cmd_to_server(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return
  end
  local cmd_list = {}
  for i = 1, form.cmd_data_rec:GetChildCount() do
    local cmd_node = form.cmd_data_rec:GetChildByIndex(i - 1)
    if nx_is_valid(cmd_node) then
      for j = 1, cmd_node:GetChildCount() do
        local child = cmd_node:GetChildByIndex(j - 1)
        if nx_is_valid(child) then
          table.insert(cmd_list, nx_int(child.iconindex))
          table.insert(cmd_list, nx_int(child.pozx))
          table.insert(cmd_list, nx_int(child.pozz))
          table.insert(cmd_list, nx_widestr(child.desc))
          table.insert(cmd_list, nx_int(child.ident))
        end
      end
    end
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 0, unpack(cmd_list))
end
function new_draw_lines(form, style, color)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local draw_lines = gui:Create("DrawLines")
  draw_lines.Left = form.pic_map.Left
  draw_lines.Top = form.pic_map.Top
  draw_lines.LineWidth = 2
  draw_lines.LineStyle = style
  draw_lines.LineColor = color
  draw_lines.UseTexture = false
  draw_lines.PointImage = "gui\\map\\path_point.png"
  draw_lines.PointThickness = 0.25
  draw_lines.line_list = nx_call("util_gui", "get_arraylist", "school_command_line_list")
  form.groupbox_line:Add(draw_lines)
  return draw_lines
end
function delete_draw_lines(form, draw_lines)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(draw_lines) then
    return 0
  end
  local gui = nx_value("gui")
  clear_draw_lines(draw_lines)
  nx_destroy(draw_lines.line_list)
  form:Remove(draw_lines)
  gui:Delete(draw_lines)
  return 1
end
function clear_draw_lines(draw_lines)
  if not nx_is_valid(draw_lines) then
    return 0
  end
  draw_lines.line_list:ClearChild()
  draw_lines:Clear()
  return 1
end
function add_line(form, draw_lines, ident, line)
  if not (nx_is_valid(form) and nx_is_valid(draw_lines)) or not nx_is_valid(line) then
    return 0
  end
  local line_node = draw_lines.line_list:GetChild(nx_string(ident))
  if not nx_is_valid(line_node) then
    line_node = draw_lines.line_list:CreateChild(nx_string(ident))
    line_node.color = COLOR_REC[ident]
  end
  for i = 1, line:GetChildCount() do
    local item = line:GetChildByIndex(i - 1)
    local child = line_node:CreateChild(nx_string(i))
    child.x = item.pozx
    child.z = item.pozz
  end
  return 1
end
function refresh_draw_lines(form, draw_lines)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(draw_lines) then
    return 0
  end
  draw_lines:Clear()
  if nx_find_custom(draw_lines, "line_list") then
    local line_node_list = draw_lines.line_list:GetChildList()
    for i = 1, table.getn(line_node_list) do
      local line = line_node_list[i]
      local item_table = line:GetChildList()
      local item_count = table.getn(item_table)
      if 1 < item_count then
        local item = item_table[1]
        local begin_x, begin_z = get_pos_in_map(item.x, item.z, form.pic_map)
        begin_x = begin_x - form.groupbox_line.Left
        begin_z = begin_z - form.groupbox_line.Top
        for i = 2, item_count do
          local item = item_table[i]
          local end_x, end_z = get_pos_in_map(item.x, item.z, form.pic_map)
          end_x = end_x - form.groupbox_line.Left
          end_z = end_z - form.groupbox_line.Top
          local index = draw_lines:AddLine(begin_x, begin_z, end_x, end_z)
          if nx_find_custom(line, "color") then
            draw_lines:SetLineColor(index, line.color)
          end
          begin_x = end_x
          begin_z = end_z
        end
      end
    end
  end
  return 1
end
function create_cmd_mark_list(form)
  if not nx_is_valid(form) then
    return
  end
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return
  end
  local file_name = "ini\\ui\\schoolfight\\schoolfight_commandicon.ini"
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local sec_index = ini:FindSectionIndex("icon")
  if sec_index < 0 then
    return
  end
  local absleft = {
    22,
    31,
    40
  }
  local abstop = {
    68,
    70,
    108,
    110,
    223,
    225,
    227,
    25
  }
  for i = 1, ini:GetSectionItemCount(sec_index) - 1 do
    local item_val = ini:GetSectionItemValue(sec_index, i - 1)
    local image_arr = nx_function("ext_split_string", nx_string(item_val), ";")
    local abs_index = i
    if i > line_node_index then
      abs_index = abs_index - 1
    end
    local row = math.floor((abs_index - 1) / 3)
    local col = nx_number(abs_index - 1 - row * 3)
    if i == line_node_index then
      row = table.getn(abstop) - 1
      col = table.getn(absleft) - 1
    end
    local btn = gui:Create("Button")
    local extratop = 0
    if row + 1 > table.getn(abstop) then
      extratop = abstop[5]
    else
      extratop = abstop[row + 1]
    end
    btn.Left = col * CMD_ICON_WIDTH + absleft[col + 1]
    btn.Top = row * CMD_ICON_HEIGHT + row * 5 + extratop
    btn.Width = CMD_ICON_WIDTH
    btn.Height = CMD_ICON_HEIGHT
    btn.AutoSize = false
    btn.Transparent = false
    btn.DrawMode = "FitWindow"
    btn.BackImage = nx_string(image_arr[1])
    btn.iconindex = i
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_mark_btn_click")
    form.groupbox_mark:Add(btn)
  end
end
function on_mark_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, btn.BackImage, "SchoolCmdIconHand", nx_string(btn.iconindex), "", "")
end
function get_idle_cmd_line(form)
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return 1
  end
  for i = 1, MAX_CMD_LINE do
    local cmd_node = form.cmd_data_rec:GetChild(nx_string(i))
    if not nx_is_valid(cmd_node) or cmd_node:GetChildCount() == 0 then
      return i
    end
  end
  return 0
end
function is_max_node_line(form, ident)
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return false
  end
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(ident))
  if nx_is_valid(cmd_node) and cmd_node:GetChildCount() >= MAX_LINE_NODE then
    return true
  end
  return false
end
function is_line_node_ident(form, ident)
  if not nx_find_custom(form, "cmd_data_rec") or not nx_is_valid(form.cmd_data_rec) then
    return false
  end
  local cmd_node = form.cmd_data_rec:GetChild(nx_string(ident))
  if not nx_is_valid(cmd_node) or cmd_node:GetChildCount() == 0 then
    return true
  end
  local child = cmd_node:GetChildByIndex(0)
  if nx_is_valid(child) and nx_number(child.iconindex) == line_node_index then
    return true
  end
  return false
end
function reset_cmd_operate_data(form)
  form.editlineindex = 0
  form.selectlineindex = 0
  form.operateicon = nx_null()
  form.groupbox_mark.Visible = false
  form.groupbox_menu.Visible = false
  form.groupbox_player_list.Visible = false
  form.groupbox_team_list_btn.Visible = false
  local gui = nx_value("gui")
  if not gui.GameHand:IsEmpty() and nx_string(gui.GameHand.Para1) == nx_string("SchoolCmdIconHand") then
    gui.GameHand:ClearHand()
  end
end
function on_rbtn_cmd_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    local file_name = "ini\\ui\\schoolfight\\schoolfight_commandicon.ini"
    local ini = get_ini(file_name)
    if not nx_is_valid(ini) then
      return
    end
    form.btn_photo.Enabled = true
    form.ipt_cmd.Enabled = true
    local item_info = ini:ReadString("icon", nx_string(rbtn.iconindex), "")
    local image_arr = nx_function("ext_split_string", item_info, ";")
    form.btn_photo.BackImage = nx_string(image_arr[1])
    form.ipt_cmd.Text = nx_widestr(rbtn.desc)
    form.btn_photo.iconindex = rbtn.iconindex
    form.btn_photo.desc = rbtn.desc
  end
end
function on_btn_photo_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, btn.BackImage, "DefaultSchoolCmdIconHand", nx_string(btn.iconindex), nx_string(btn.desc), "")
end
function on_btn_delete_cmd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  local ini = form.cmd_config_ini
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked then
      local sec = "cmd" .. nx_string(i)
      rbtn.desc = form.ipt_cmd.Text
      ini:DeleteSection(sec)
      ini:SaveToFile()
      form.btn_photo.BackImage = "gui\\common\\checkbutton\\cbtn_5_out.png"
      form.ipt_cmd.Text = nx_widestr("")
      rbtn.Text = nx_widestr(util_text(DEFAULT_CMD_NAME[i]))
      form.btn_photo.Enabled = false
      form.ipt_cmd.Enabled = false
      rbtn.Enabled = false
      return
    end
  end
end
function on_btn_save_cmd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  local ini = form.cmd_config_ini
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked then
      local sec = "cmd" .. nx_string(i)
      rbtn.desc = form.ipt_cmd.Text
      ini:WriteString(sec, "desc", nx_string(form.ipt_cmd.Text))
      ini:SaveToFile()
      form.btn_photo.desc = rbtn.desc
      return
    end
  end
end
function on_btn_reset_cmd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  local ini = form.cmd_config_ini
  form.btn_photo.Enabled = false
  form.ipt_cmd.Enabled = false
  form.btn_photo.BackImage = "gui\\common\\checkbutton\\cbtn_5_out.png"
  form.ipt_cmd.Text = nx_widestr("")
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    local sec = "cmd" .. nx_string(i)
    if nx_is_valid(rbtn) then
      rbtn.iconindex = 0
      rbtn.desc = nx_widestr("")
      rbtn.Text = nx_widestr(util_text(DEFAULT_CMD_NAME[i]))
      rbtn.Enabled = false
      rbtn.Checked = false
    end
    ini:DeleteSection(sec)
    ini:SaveToFile()
  end
end
function on_rbtn_player_select_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 4, nx_number(rbtn.DataSource))
  end
end
function on_btn_publish_cmd_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not nx_is_valid(vis_player) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(util_text("ui_schoolwar_pubtxt"))
  dialog.lbl_1.Text = nx_widestr(util_text("ui_schoolwar_pub"))
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    send_cmd_to_server(form)
    btn.Enabled = false
    local msg_delay = nx_value("MessageDelay")
    vis_player.origin_publish_time = msg_delay:GetServerNowTime()
  end
  if not nx_is_valid(form) then
    return
  end
  form.editlineindex = 0
  form.selectlineindex = 0
end
function refresh_operate_control(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "accept_option") then
    if nx_number(form.accept_option) == 0 then
      form.rbtn_total.Checked = true
    elseif nx_number(form.accept_option) == 1 then
      form.rbtn_list.Checked = true
    end
  end
end
function on_btn_playerlist_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_player_list.Visible = not form.groupbox_player_list.Visible
end
function refresh_player_list(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "obs_data_rec") or not nx_is_valid(form.obs_data_rec) then
    return
  end
  local obs_list_count = form.obs_data_rec:GetChildCount()
  form.ImageControlGrid:Clear()
  form.gridselectRow = -1
  for i = 1, obs_list_count do
    local child = form.obs_data_rec:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      local obsname = nx_widestr(child.obsname)
      local obsschool = nx_string(child.obsschool)
      form.ImageControlGrid:AddItem(i - 1, "gui\\common\\checkbutton\\cbtn_2_out.png", nx_widestr(obsname), nx_int(0), nx_int(0))
      form.ImageControlGrid:SetItemAddInfo(i - 1, 0, nx_widestr(obsname))
      form.ImageControlGrid:ShowItemAddInfo(i - 1, 0, true)
      form.ImageControlGrid:SetItemAddInfo(i - 1, 1, nx_widestr(util_text(nx_string(obsschool))))
      form.ImageControlGrid:ShowItemAddInfo(i - 1, 1, true)
    end
  end
end
function on_ImageControlGrid_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local prevrow = -1
  if nx_find_custom(form, "gridselectRow") then
    prevrow = form.gridselectRow
  end
  if nx_number(prevrow) ~= -1 then
    grid:SetItemImage(prevrow, "gui\\common\\checkbutton\\cbtn_2_out.png")
  end
  form.gridselectRow = index
  grid:SetItemImage(index, "gui\\common\\checkbutton\\cbtn_2_down.png")
end
function on_btn_add_player_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_add"))
  dialog.info_label.Text = nx_widestr(util_text("ui_schoolwar_addtxt"))
  dialog.ok_btn.Text = nx_widestr(util_text("ui_add"))
  dialog.allow_empty = false
  dialog.name_edit.MaxLength = MAX_PLAYER_NAME_WORD
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 1, nx_widestr(text))
  end
end
function on_btn_delete_player_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.ImageControlGrid:GetSelectItemIndex()
  if nx_number(index) == -1 or form.ImageControlGrid:IsEmpty(index) then
    return
  end
  local name = form.ImageControlGrid:GetItemName(index)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(util_text("ui_schoolwar_deltxt"))
  dialog.lbl_1.Text = nx_widestr(util_text("ui_schoolwar_del"))
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 2, nx_widestr(name))
  end
end
function on_btn_clear_list_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(util_text("ui_schoolwar_cleartxt"))
  dialog.lbl_1.Text = nx_widestr(util_text("ui_schoolwar_clear"))
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 3)
  end
end
function on_btn_list_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_player_list.Visible = false
end
function receive_observer_change_success(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "obs_data_rec") or not nx_is_valid(form.obs_data_rec) then
    form.obs_data_rec = nx_call("util_gui", "get_arraylist", "schoolobserverrec")
  end
  local obs_list_count = form.obs_data_rec:GetChildCount()
  if nx_number(arg[1]) == 0 then
    local obsname = nx_widestr(arg[2])
    local obsschool = nx_string(arg[3])
    local child = form.obs_data_rec:GetChild(nx_string(obsname))
    if not nx_is_valid(child) then
      child = form.obs_data_rec:CreateChild(nx_string(obsname))
    end
    child.obsname = obsname
    child.obsschool = obsschool
  elseif nx_number(arg[1]) == 1 then
    local obsname = nx_widestr(arg[2])
    if form.obs_data_rec:FindChild(nx_string(obsname)) then
      form.obs_data_rec:RemoveChild(nx_string(obsname))
    end
  elseif nx_number(arg[1]) == 2 then
    form.obs_data_rec:ClearChild()
  end
  refresh_player_list(form)
end
function load_form_config_ini()
  local file_name = "schoolfightmapui.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. file_name
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  return ini
end
function init_config_cmd_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  local ini = form.cmd_config_ini
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local sec = "cmd" .. nx_string(i)
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    if nx_is_valid(rbtn) then
      rbtn.Enabled = false
      if ini:FindItem(sec, "index") and ini:FindItem(sec, "name") and ini:FindItem(sec, "desc") then
        rbtn.iconindex = ini:ReadInteger(sec, "index", 0)
        rbtn.desc = ini:ReadString(sec, "desc", "")
        rbtn.Text = nx_widestr(ini:ReadString(sec, "name", ""))
        rbtn.Enabled = true
      end
    end
  end
end
function save_config_cmd_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cmd_config_ini") or not nx_is_valid(form.cmd_config_ini) then
    return
  end
  local ini = form.cmd_config_ini
  for i = 1, MAX_DEFAULT_CONFIG_CMD do
    local rbtn = form.groupbox_cmd:Find("rbtn_cmd" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Enabled then
      local sec = "cmd" .. nx_string(i)
      ini:WriteInteger(sec, "index", rbtn.iconindex)
      ini:WriteString(sec, "name", nx_string(rbtn.Text))
      ini:WriteString(sec, "desc", nx_string(rbtn.desc))
    end
  end
  ini:SaveToFile()
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
function on_btn_teamlist_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_team_list.Visible then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 15)
  end
  form.groupbox_team_list.Visible = not form.groupbox_team_list.Visible
end
function on_btn_teamlist_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_team_list.Visible = false
end
function on_ImageControlGrid1_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local prevrow = -1
  if nx_find_custom(form, "teamgridselectRow") then
    prevrow = form.teamgridselectRow
  end
  if nx_number(prevrow) ~= -1 then
    grid:SetItemImage(prevrow, "gui\\common\\checkbutton\\cbtn_2_out.png")
  end
  form.teamgridselectRow = index
  grid:SetItemImage(index, "gui\\common\\checkbutton\\cbtn_2_down.png")
end
function refresh_team_list(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_team_list.Visible then
    return
  end
  form.ImageControlGrid1:Clear()
  form.teamgridselectRow = -1
  local arg_num = table.getn(arg)
  if nx_number(arg_num) == 0 then
    return
  end
  local arg_index = 1
  local item_col = nx_number(arg[arg_index])
  local item_count = math.floor((arg_num - 1) / item_col)
  if nx_number(item_count) == 0 then
    return
  end
  arg_index = arg_index + 1
  for i = 1, item_count do
    local teamid = nx_number(arg[arg_index])
    local name = nx_widestr(arg[arg_index + 1])
    local count = nx_number(arg[arg_index + 2])
    local desc = nx_widestr(arg[arg_index + 3])
    local gui = nx_value("gui")
    if nx_ws_length(desc) == 0 then
      gui.TextManager:Format_SetIDName("ui_command_team")
      gui.TextManager:Format_AddParam(name)
      desc = nx_widestr(gui.TextManager:Format_GetText())
    end
    form.ImageControlGrid1:AddItem(i - 1, "gui\\common\\checkbutton\\cbtn_2_out.png", nx_widestr(teamid), nx_int(0), nx_int(0))
    form.ImageControlGrid1:SetItemAddInfo(i - 1, 0, nx_widestr(name))
    form.ImageControlGrid1:ShowItemAddInfo(i - 1, 0, true)
    form.ImageControlGrid1:SetItemAddInfo(i - 1, 1, nx_widestr(desc))
    form.ImageControlGrid1:ShowItemAddInfo(i - 1, 1, true)
    form.ImageControlGrid1:SetItemAddInfo(i - 1, 2, nx_widestr(count))
    form.ImageControlGrid1:ShowItemAddInfo(i - 1, 2, true)
    arg_index = arg_index + item_col
  end
end
function on_btn_add_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_teamadd"))
  dialog.info_label.Text = nx_widestr(util_text("ui_schoolwar_teamaddtxt"))
  dialog.ok_btn.Text = nx_widestr(util_text("ui_add"))
  dialog.allow_empty = false
  dialog.name_edit.MaxLength = MAX_PLAYER_NAME_WORD
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 5, nx_widestr(text))
  end
end
function on_btn_del_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  local index = form.ImageControlGrid1:GetSelectItemIndex()
  if nx_number(index) == -1 or form.ImageControlGrid1:IsEmpty(index) then
    return
  end
  local teamid = form.ImageControlGrid1:GetItemName(index)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(util_text("ui_schoolwar_teamdektxt"))
  dialog.lbl_1.Text = nx_widestr(util_text("ui_schoolwar_teamdel"))
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 6, nx_number(teamid))
  end
end
function on_btn_modify_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) then
    reset_cmd_operate_data(form)
    return
  end
  local index = form.ImageControlGrid1:GetSelectItemIndex()
  if nx_number(index) == -1 or form.ImageControlGrid1:IsEmpty(index) then
    return
  end
  local teamid = form.ImageControlGrid1:GetItemName(index)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_input_name", true, false)
  dialog.lbl_title.Text = nx_widestr(util_text("ui_schoolwar_teamcus"))
  dialog.info_label.Text = nx_widestr(util_text("ui_schoolwar_teamcustxt"))
  dialog.ok_btn.Text = nx_widestr(util_text("ui_add"))
  dialog.allow_empty = false
  dialog.name_edit.MaxLength = MAX_TEAM_DESC_WORD
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_name_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 12, 7, nx_number(teamid), nx_widestr(text))
  end
end
function on_btn_join_team_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = form.ImageControlGrid1:GetSelectItemIndex()
  if nx_number(index) == -1 or form.ImageControlGrid1:IsEmpty(index) then
    return
  end
  local teamid = form.ImageControlGrid1:GetItemName(index)
  local captain = form.ImageControlGrid1:GetItemAddText(index, 0)
  local teamdesc = form.ImageControlGrid1:GetItemAddText(index, 1)
  nx_execute("custom_sender", "custom_team_request_join", nx_widestr(captain))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("83190"), 2)
  end
end
function refresh_fight_time(form)
  if not nx_is_valid(form) then
    return
  end
  if form.btn_publish_cmd.Enabled then
    return
  end
  local game_visual = nx_value("game_visual")
  local vis_player = game_visual:GetPlayer()
  if not nx_is_valid(vis_player) then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  local curservertime = msg_delay:GetServerNowTime()
  local last_time = 0
  if nx_find_custom(vis_player, "origin_publish_time") then
    last_time = vis_player.origin_publish_time
  end
  local live_time = (nx_int64(curservertime) - nx_int64(last_time)) / 1000
  live_time = PUBLISH_CMD_INTERVAL - live_time
  if nx_int(live_time) <= nx_int(0) then
    form.btn_publish_cmd.Enabled = true
    live_time = 0
  end
  form.lbl_time.Text = nx_widestr(get_format_time_text(live_time))
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time)
end
function init_from_size(form)
  if not nx_is_valid(form) then
    return
  end
  if is_command_leader(form) then
    return
  end
  local absw = form.groupbox_mark.Width
  local absh = form.groupbox_edit.Height
  form.Width = form.Width - absw
  form.Height = form.Height - absh
  local control_name = {
    "lbl_7",
    "groupbox_npc",
    "pic_map",
    "btn_close",
    "groupbox_player_pos",
    "groupbox_move",
    "groupbox_1",
    "groupbox_scene",
    "groupbox_line",
    "btn_teamlist",
    "groupbox_team_list",
    "btn_reportlist",
    "groupbox_report_list"
  }
  for i = 1, table.getn(control_name) do
    local control = form:Find(control_name[i])
    if nx_is_valid(control) then
      control.Left = control.Left - absw
      control.Top = control.Top - absh
    end
  end
end
function on_btn_edit_rule_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_cmd_edit_rule.Visible = true
  form:ToFront(form.groupbox_cmd_edit_rule)
end
function on_btn_rule_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_cmd_edit_rule.Visible = false
end
function on_btn_reportlist_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_report_list.Visible then
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 23)
  end
  form.groupbox_report_list.Visible = not form.groupbox_report_list.Visible
end
function on_btn_reportlist_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_report_list.Visible = false
end
function refresh_report_list(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_report_list.Visible then
    return
  end
  form.ImageControlGrid2:Clear()
  form.report_sel_index:ClearChild()
  local arg_num = table.getn(arg)
  if nx_number(arg_num) == 0 then
    return
  end
  local arg_index = 1
  local main_leader = nx_number(arg[arg_index])
  if main_leader == 1 then
    form.btn_all.Enabled = true
    form.btn_kick.Enabled = true
    form.btn_refuse.Enabled = true
  end
  arg_index = arg_index + 1
  local item_count = nx_number(arg[arg_index])
  if nx_number(item_count) == 0 then
    return
  end
  form.report_list_count = item_count
  local item_col = 4
  if nx_number(math.floor((arg_num - arg_index) / item_col)) ~= item_count then
    return
  end
  arg_index = arg_index + 1
  for i = 1, item_count do
    local br_name = nx_widestr(arg[arg_index])
    local br_school = nx_string(arg[arg_index + 1])
    local br_ranking = nx_number(arg[arg_index + 2])
    local r_name = nx_widestr(arg[arg_index + 3])
    local gui = nx_value("gui")
    form.ImageControlGrid2:AddItem(i - 1, "gui\\common\\checkbutton\\cbtn_2_out.png", nx_widestr(br_name), nx_int(0), nx_int(0))
    form.ImageControlGrid2:SetItemAddInfo(i - 1, 0, nx_widestr(br_name))
    form.ImageControlGrid2:ShowItemAddInfo(i - 1, 0, true)
    form.ImageControlGrid2:SetItemAddInfo(i - 1, 1, nx_widestr(gui.TextManager:GetText(br_school)))
    form.ImageControlGrid2:ShowItemAddInfo(i - 1, 1, true)
    form.ImageControlGrid2:SetItemAddInfo(i - 1, 2, nx_widestr(br_ranking))
    form.ImageControlGrid2:ShowItemAddInfo(i - 1, 2, true)
    form.ImageControlGrid2:SetItemAddInfo(i - 1, 3, nx_widestr(r_name))
    form.ImageControlGrid2:ShowItemAddInfo(i - 1, 3, true)
    arg_index = arg_index + item_col
  end
end
function on_ImageControlGrid2_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) and not isschoolleader() then
    return
  end
  if not nx_find_custom(form, "report_sel_index") then
    return
  end
  local find_index = -1
  local child_count = form.report_sel_index:GetChildCount()
  for i = 1, child_count do
    local child = form.report_sel_index:GetChildByIndex(i - 1)
    if nx_is_valid(child) and nx_number(index) == nx_number(child.index) then
      find_index = i - 1
      break
    end
  end
  if find_index == -1 then
    local child = form.report_sel_index:GetChild("report" .. nx_string(index))
    if not nx_is_valid(child) then
      child = form.report_sel_index:CreateChild("report" .. nx_string(index))
      child.index = index
    end
    grid:SetItemImage(index, "gui\\common\\checkbutton\\cbtn_2_down.png")
  else
    form.report_sel_index:RemoveChildByIndex(find_index)
    grid:SetItemImage(index, "gui\\common\\checkbutton\\cbtn_2_out.png")
  end
end
function on_btn_all_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) and not isschoolleader() then
    return
  end
  if not nx_find_custom(form, "report_sel_index") or not nx_find_custom(form, "report_list_count") then
    return
  end
  if nx_number(form.report_list_count) == 0 then
    return
  end
  if form.report_sel_index:GetChildCount() == 0 then
    for i = 1, nx_number(form.report_list_count) do
      local child = form.report_sel_index:GetChild("report" .. nx_string(i - 1))
      if not nx_is_valid(child) then
        child = form.report_sel_index:CreateChild("report" .. nx_string(i - 1))
        child.index = i - 1
      end
      form.ImageControlGrid2:SetItemImage(i - 1, "gui\\common\\checkbutton\\cbtn_2_down.png")
    end
  else
    form.report_sel_index:ClearChild()
    for i = 1, nx_number(form.report_list_count) do
      form.ImageControlGrid2:SetItemImage(i - 1, "gui\\common\\checkbutton\\cbtn_2_out.png")
    end
  end
end
function on_btn_kick_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) and not isschoolleader() then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ui_schoolfight_report_001"))
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    if not is_command_leader(form) and not isschoolleader() then
      return
    end
    if not nx_find_custom(form, "report_sel_index") then
      return
    end
    if form.report_sel_index:GetChildCount() == 0 then
      return
    end
    local arg_list = {}
    for i = 1, form.report_sel_index:GetChildCount() do
      local child = form.report_sel_index:GetChildByIndex(i - 1)
      if nx_is_valid(child) and not form.ImageControlGrid2:IsEmpty(child.index) then
        local name = form.ImageControlGrid2:GetItemName(child.index)
        table.insert(arg_list, name)
      end
    end
    if table.getn(arg_list) == 0 then
      return
    end
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 24, 1, unpack(arg_list))
  end
end
function on_btn_refuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_command_leader(form) and not isschoolleader() then
    return
  end
  if not nx_find_custom(form, "report_sel_index") then
    return
  end
  if form.report_sel_index:GetChildCount() == 0 then
    return
  end
  local arg_list = {}
  for i = 1, form.report_sel_index:GetChildCount() do
    local child = form.report_sel_index:GetChildByIndex(i - 1)
    if nx_is_valid(child) and not form.ImageControlGrid2:IsEmpty(child.index) then
      local name = form.ImageControlGrid2:GetItemName(child.index)
      table.insert(arg_list, name)
    end
  end
  if table.getn(arg_list) == 0 then
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 25, unpack(arg_list))
end
function CanKickTarget()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if client_player:QueryProp("IsInSchoolFight") ~= 1 then
    return false
  end
  if not iscommandleader() and not isschoolleader() then
    return false
  end
  return true
end
