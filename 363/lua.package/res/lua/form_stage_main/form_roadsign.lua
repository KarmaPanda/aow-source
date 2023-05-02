require("util_functions")
local MAX_DISTANCE = 25
function form_roadsign_tick()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  local form_roadsign = nx_value("form_stage_main\\form_roadsign")
  if not nx_is_valid(form_roadsign) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form_roadsign.npc))
  if not nx_is_valid(visual_npc) then
    return
  end
  while true do
    local sec = nx_pause(1)
    if not nx_is_valid(form_roadsign) then
      break
    end
    if not nx_is_valid(visual_npc) then
      break
    end
    local dest_x = visual_player.PositionX
    local dest_z = visual_player.PositionZ
    local sx = dest_x - visual_npc.PositionX
    local sz = dest_z - visual_npc.PositionZ
    local distance = math.sqrt(sx * sx + sz * sz)
    if tonumber(distance) > tonumber(MAX_DISTANCE) then
      if nx_is_valid(form_roadsign) then
        form_roadsign:Close()
      end
      break
    end
    updata_player_pos()
  end
end
function init_main_form(self)
  self.npc = ""
  self.center_x = 0
  self.center_z = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.pic_map.TerrainStartX = 0
  form.pic_map.TerrainStartZ = 0
  form.pic_map.TerrainWidth = 1024
  form.pic_map.TerrainHeight = 1024
  show_map(form)
  if nx_running(nx_current(), "form_roadsign_tick") then
    nx_kill(nx_current(), "form_roadsign_tick")
  end
  nx_execute(nx_current(), "form_roadsign_tick")
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_roadsign_tick") then
    nx_kill(nx_current(), "form_roadsign_tick")
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form_roadsign = btn.ParentForm
  if nx_is_valid(form_roadsign) then
    form_roadsign:Close()
  end
end
function get_obj_pos(visual_obj, form_roadsign)
  local ret_x = 0
  local ret_z = 0
  if not nx_is_valid(visual_obj) then
    return ret_x, ret_z
  end
  if not nx_is_valid(form_roadsign) then
    return ret_x, ret_z
  end
  local terrain_width = form_roadsign.pic_map.TerrainWidth
  local terrain_height = form_roadsign.pic_map.TerrainHeight
  local terrain_start_x = form_roadsign.pic_map.TerrainStartX
  local terrain_start_z = form_roadsign.pic_map.TerrainStartZ
  local map_width = form_roadsign.pic_map.ImageWidth
  local map_height = form_roadsign.pic_map.ImageHeight
  local obj_x = visual_obj.PositionX
  local obj_z = visual_obj.PositionZ
  ret_x = map_width - (obj_x - terrain_start_x) / terrain_width * map_width
  ret_z = (obj_z - terrain_start_z) / terrain_height * map_height
  return ret_x, ret_z
end
function show_map(form)
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npc))
  if not nx_is_valid(visual_npc) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local resource = client_scene:QueryProp("Resource")
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  form.pic_map.Image = map_name
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini")
  if not ini:LoadFromFile() then
    return false
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  nx_destroy(ini)
  form.pic_map.ZoomWidth = 1
  form.pic_map.ZoomHeight = 1
  local center_x = 0
  local center_z = 0
  center_x, center_z = get_obj_pos(visual_npc, form)
  form.center_x = center_x
  form.center_z = center_z
  form.pic_map.CenterX = nx_int(center_x)
  form.pic_map.CenterY = nx_int(center_z)
  local funcnpc_ini = nx_execute("util_functions", "get_ini", "share\\Npc\\funcnpc.ini")
  if not nx_is_valid(funcnpc_ini) then
    return false
  end
  local client_npc = game_client:GetSceneObj(nx_string(form.npc))
  if not nx_is_valid(client_npc) then
    return false
  end
  local index = 0
  local text = ""
  local npc_config = client_npc:QueryProp("ConfigID")
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignNorth", "")
  if nx_string(text) == nx_string("") then
    form.lbl_north.Visible = false
  end
  index = form.mtb_north:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_north:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignSouth", "")
  if nx_string(text) == nx_string("") then
    form.lbl_south.Visible = false
  end
  index = form.mtb_south:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_south:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignWest", "")
  if nx_string(text) == nx_string("") then
    form.lbl_west.Visible = false
  end
  index = form.mtb_west:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_west:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_west.Height = form.mtb_west:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_west.Width .. "," .. form.mtb_west.Height
  form.mtb_west.ViewRect = viewrect
  form.mtb_west:Reset()
  form.mtb_west.Top = (form.Height - form.mtb_west.Height) / 2
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignEast", "")
  if nx_string(text) == nx_string("") then
    form.lbl_east.Visible = false
  end
  index = form.mtb_east:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_east:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_east.Height = form.mtb_east:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_east.Width .. "," .. form.mtb_east.Height
  form.mtb_east.ViewRect = viewrect
  form.mtb_east:Reset()
  form.mtb_east.Top = (form.Height - form.mtb_east.Height) / 2
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignEN", "")
  if nx_string(text) == nx_string("") then
    form.lbl_en.Visible = false
  end
  index = form.mtb_eastnorth:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_eastnorth:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignWN", "")
  if nx_string(text) == nx_string("") then
    form.lbl_wn.Visible = false
  end
  index = form.mtb_westnorth:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_westnorth:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignES", "")
  if nx_string(text) == nx_string("") then
    form.lbl_es.Visible = false
  end
  index = form.mtb_eastsouth:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_eastsouth:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignWS", "")
  if nx_string(text) == nx_string("") then
    form.lbl_ws.Visible = false
  end
  index = form.mtb_westsouth:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_westsouth:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignNL", "")
  if nx_string(text) == nx_string("") then
    form.lbl_n_l.Visible = false
  end
  index = form.mtb_n_l:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_n_l:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignNR", "")
  if nx_string(text) == nx_string("") then
    form.lbl_n_r.Visible = false
  end
  index = form.mtb_n_r:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_n_r:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignWT", "")
  if nx_string(text) == nx_string("") then
    form.lbl_w_t.Visible = false
  end
  index = form.mtb_w_t:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_w_t:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_w_t.Height = form.mtb_w_t:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_w_t.Width .. "," .. form.mtb_w_t.Height
  form.mtb_w_t.ViewRect = viewrect
  form.mtb_w_t:Reset()
  form.mtb_w_t.Top = form.Height / 3 - form.mtb_w_t.Height / 2
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignWD", "")
  if nx_string(text) == nx_string("") then
    form.lbl_w_d.Visible = false
  end
  index = form.mtb_w_d:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_w_d:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_w_d.Height = form.mtb_w_d:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_w_d.Width .. "," .. form.mtb_w_d.Height
  form.mtb_w_d.ViewRect = viewrect
  form.mtb_w_d:Reset()
  form.mtb_w_d.Top = form.Height * 2 / 3 - form.mtb_w_d.Height / 2
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignSL", "")
  if nx_string(text) == nx_string("") then
    form.lbl_s_l.Visible = false
  end
  index = form.mtb_s_l:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_s_l:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignSR", "")
  if nx_string(text) == nx_string("") then
    form.lbl_s_r.Visible = false
  end
  index = form.mtb_s_r:AddHtmlText(nx_widestr("<center>" .. nx_string(gui.TextManager:GetText(text)) .. "</center>"), nx_int(-1))
  form.mtb_s_r:SetHtmlItemSelectable(nx_int(index), false)
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignET", "")
  if nx_string(text) == nx_string("") then
    form.lbl_e_t.Visible = false
  end
  index = form.mtb_e_t:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_e_t:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_e_t.Height = form.mtb_e_t:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_e_t.Width .. "," .. form.mtb_e_t.Height
  form.mtb_e_t.ViewRect = viewrect
  form.mtb_e_t:Reset()
  form.mtb_e_t.Top = form.Height / 3 - form.mtb_e_t.Height / 2
  text = funcnpc_ini:ReadString(nx_string(npc_config), "RoadSignED", "")
  if nx_string(text) == nx_string("") then
    form.lbl_e_d.Visible = false
  end
  index = form.mtb_e_d:AddHtmlText(gui.TextManager:GetText(text), nx_int(-1))
  form.mtb_e_d:SetHtmlItemSelectable(nx_int(index), false)
  form.mtb_e_d.Height = form.mtb_e_d:GetContentHeight()
  local viewrect = "0,0," .. form.mtb_e_d.Width .. "," .. form.mtb_e_d.Height
  form.mtb_e_d.ViewRect = viewrect
  form.mtb_e_d:Reset()
  form.mtb_e_d.Top = form.Height * 2 / 3 - form.mtb_e_d.Height / 2
  return true
end
function updata_player_pos()
  local form_roadsign = nx_value("form_stage_main\\form_roadsign")
  if not nx_is_valid(form_roadsign) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local angle = -visual_player.AngleY + math.pi
  form_roadsign.lbl_me.AngleZ = angle
  local player_x = 0
  local player_z = 0
  player_x, player_z = get_obj_pos(visual_player, form_roadsign)
  local center_x = form_roadsign.center_x
  local center_z = form_roadsign.center_z
  local player_pic_x = form_roadsign.pic_map.AbsLeft + player_x - center_x + form_roadsign.pic_map.Width / 2 - form_roadsign.lbl_me.Width / 2
  local player_pic_z = form_roadsign.pic_map.AbsTop + player_z - center_z + form_roadsign.pic_map.Height / 2 - form_roadsign.lbl_me.Height / 2
  form_roadsign.lbl_me.AbsLeft = player_pic_x
  form_roadsign.lbl_me.AbsTop = player_pic_z
end
