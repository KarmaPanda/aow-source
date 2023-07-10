require("util_functions")
require("form_stage_main\\form_die_util")
local TYPE_RELIVE_FORCE = 1
local TYPE_RELIVE_PUBLIC = 2
local FILE_MAP_POINT = "ini\\ui\\relive\\worldwar_maprange.ini"
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.revert = os.time() + 180
  form.LuaScript = nx_current()
  local timer = nx_value("common_execute")
  timer:AddExecute("relive_fresh_timer", form, nx_float(0.5))
  fresh_relive_form(form)
  form.select_relive_index = 0
  form.select_relive_type = 0
  local client = nx_value("game_client")
  local scene = client:GetScene()
  local scene_id = scene:QueryProp("SourceID")
  form.scene_id = scene_id
  load_relive_location_info(form, scene_id)
end
function on_main_form_close(form)
  local timer = nx_value("common_execute")
  timer:RemoveExecute("relive_fresh_timer", form)
  local relive_timer = nx_value("timer_game")
  relive_timer:UnRegister(nx_current(), "on_update_time", form)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    ok_dialog:Close()
  end
  nx_destroy(form)
end
function close_form()
  local form = nx_value("form_stage_main\\form_die_world_war")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_relive_local_click(btn)
  local form = btn.ParentForm
  if not show_ok_dialog(form, RELIVE_TYPE_LOCAL, nx_int(0), nx_int(0)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_LOCAL, nx_int(0))
end
function on_btn_relive_strong_click(btn)
  local form = btn.ParentForm
  if not show_ok_dialog(form, RELIVE_TYPE_LOCAL_STRONG, nx_int(1), nx_int(0)) then
    return 0
  end
  nx_execute("custom_sender", "custom_relive", RELIVE_TYPE_LOCAL_STRONG, nx_int(0))
end
function on_btn_return_near_location_click(btn)
  local form = btn.ParentForm
  if form.select_relive_index == 0 or form.select_relive_type == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "83038")
    return 0
  end
  if not show_ok_dialog(form, RELIVE_TYPE_WORLD_NEAR, nx_int(0), nx_int(0)) then
    return 0
  end
  nx_execute(nx_current(), "custom_schoolwar_relive", RELIVE_TYPE_WORLD_NEAR, nx_int(0), nx_int(form.select_relive_index), nx_int(form.select_relive_type))
end
function on_btn_relive_local_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_LOCAL
  fresh_relive_form(form)
end
function on_btn_relive_local_lost_capture(btn)
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.select_type = RELIVE_TYPE_SCHOOL
  fresh_relive_form(form)
end
function load_relive_location_info(form, sceneid, ...)
  form.sceneid = sceneid
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(FILE_MAP_POINT) then
    IniManager:LoadIniToManager(FILE_MAP_POINT)
  end
  local ini = IniManager:GetIniDocument(FILE_MAP_POINT)
  if not nx_is_valid(ini) then
    return
  end
  local sec_map = ini:FindSectionIndex(nx_string(form.sceneid))
  if -1 ~= sec_map then
    form.pic_map.startx = ini:ReadFloat(sec_map, "StartX", 0)
    form.pic_map.startz = ini:ReadFloat(sec_map, "StartZ", 0)
    form.pic_map.showwidth = ini:ReadFloat(sec_map, "Width", 0)
    form.pic_map.showheight = ini:ReadFloat(sec_map, "Height", 0)
  end
  show_picture_control(form)
end
function CreatePlayerRelivePoint(form, relive_type)
  local IniManager = nx_value("IniManager")
  local filename = FILE_INDEX[relive_type]
  if not IniManager:IsIniLoadedToManager(filename) then
    IniManager:LoadIniToManager(filename)
  end
  local ini = IniManager:GetIniDocument(filename)
  local sec_index = ini:FindSectionIndex(nx_string(form.sceneid))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 1, item_count do
    local info = ini:GetSectionItemValue(sec_index, i - 1)
    local itemlist = util_split_string(info, ",")
    if table.getn(itemlist) == 8 then
      local child = form.relive_data:CreateChild(nx_string(relive_type) .. nx_string(itemlist[1]))
      child.relive_type = relive_type
      child.relive_index = itemlist[1]
      child.relive_posx = itemlist[2]
      child.relive_posz = itemlist[4]
      child.relive_name = itemlist[6]
      child.relive_number = itemlist[7]
      child.relive_image_n = NORMAL_IMAGE
      child.relive_image_f = FOCUS_IMAGE
      child.relive_image_c = CHECK_IMAGE
      child.relive_image_d = DISABLE_IMAGE
      child.relive_state = 0
      local image_arr = util_split_string(itemlist[8], ";")
      if table.getn(image_arr) >= 8 then
        if get_fight_force() == SIDE_DEFEND then
          child.relive_image_n = image_arr[1]
          child.relive_image_f = image_arr[2]
          child.relive_image_c = image_arr[3]
          child.relive_image_d = image_arr[4]
        elseif get_fight_force() == SIDE_ATTACK then
          child.relive_image_n = image_arr[5]
          child.relive_image_f = image_arr[6]
          child.relive_image_c = image_arr[7]
          child.relive_image_d = image_arr[8]
        end
      end
    end
  end
end
function FindPlayerRelivePoint(form, relive_type, relive_index)
  local IniManager = nx_value("IniManager")
  local filename = FILE_INDEX[relive_type]
  if not IniManager:IsIniLoadedToManager(filename) then
    IniManager:LoadIniToManager(filename)
  end
  local ini = IniManager:GetIniDocument(filename)
  local sec_index = ini:FindSectionIndex(nx_string(form.sceneid))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 1, item_count do
    local info = ini:GetSectionItemValue(sec_index, i - 1)
    local itemlist = util_split_string(info, ",")
    if table.getn(itemlist) == 8 and tonumber(itemlist[1]) == tonumber(relive_index) then
      return itemlist
    end
  end
  return nil
end
function show_picture_control(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
  local resource = client_scene:QueryProp("Resource")
  local map_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  form.pic_map.Image = map_name
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex("Map")
  if sec_index < 0 then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger(sec_index, "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger(sec_index, "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger(sec_index, "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger(sec_index, "Height", 1024)
  form.pic_map.ZoomWidth = form.pic_map.Width / form.pic_map.showwidth
  form.pic_map.ZoomHeight = form.pic_map.Height / form.pic_map.showheight
  local tempx = form.pic_map.startx - form.pic_map.showwidth / 2
  local tempz = form.pic_map.startz + form.pic_map.showheight / 2
  form.pic_map.CenterX, form.pic_map.CenterY = scene_to_map(form, tempx, tempz)
  local gui = nx_value("gui")
  local relive_file_name = "share\\relive\\worldwar_relive.ini"
  if not IniManager:IsIniLoadedToManager(relive_file_name) then
    IniManager:LoadIniToManager(relive_file_name)
  end
  local relive_ini = IniManager:GetIniDocument(relive_file_name)
  local scene_sec_index = relive_ini:FindSectionIndex(nx_string(client_scene:QueryProp("SourceID")))
  if scene_sec_index < 0 then
    return
  end
  local player = game_client:GetPlayer()
  local force_index = player:QueryProp("WorldWarForce")
  local force_id = "force" .. nx_string(force_index)
  local relive_point_list = relive_ini:GetItemValueList(scene_sec_index, nx_string(force_id))
  for i = 1, table.getn(relive_point_list) do
    local relive_info_list = util_split_string(relive_point_list[i], ",")
    local new_rbtn = gui:Create("RadioButton")
    form.groupbox_2:Add(new_rbtn)
    nx_bind_script(new_rbtn, nx_current())
    nx_callback(new_rbtn, "on_checked_changed", "on_rbtn_relive_changed")
    nx_callback(new_rbtn, "on_get_capture", "on_rbtn_get_capture")
    nx_callback(new_rbtn, "on_lost_capture", "on_rbtn_lost_capture")
    new_rbtn.relive_type = TYPE_RELIVE_FORCE
    new_rbtn.relive_index = relive_info_list[1]
    new_rbtn.relive_posx = relive_info_list[2]
    new_rbtn.relive_posz = relive_info_list[4]
    new_rbtn.relive_name = "ui_fuhuo_" .. nx_string(form.scene_id) .. "_" .. nx_string(force_index) .. "_" .. nx_string(i)
    new_rbtn.relive_state = 1
    new_rbtn.Width = 27
    new_rbtn.Height = 27
    new_rbtn.Left, new_rbtn.Top = scene_to_map(form, relive_info_list[2], relive_info_list[4])
    new_rbtn.Left = new_rbtn.Left - new_rbtn.Width / 2
    new_rbtn.Top = new_rbtn.Top - new_rbtn.Height / 2
    new_rbtn.NormalImage = "gui\\special\\schoolwar\\map_new1\\camp_def_out.png"
    new_rbtn.FocusImage = "gui\\special\\schoolwar\\map_new1\\camp_def_on.png"
    new_rbtn.CheckedImage = "gui\\specialschoolwar\\map_new1\\camp_def_down.png"
    new_rbtn.DisableImage = "gui\\specialschoolwar\\map_new1\\camp_forbid.png"
    local lab = gui:Create("Label")
    lab.Width = 15
    lab.Height = 15
    lab.Left = new_rbtn.Left
    lab.Top = new_rbtn.Top + 15
    lab.Font = "font_main"
    lab.ForeColor = "255,255,0,0"
    lab.Align = "Right"
    lab.Text = nx_widestr(i)
    form.groupbox_2:Add(lab)
  end
  if not nx_find_value("worldwar_public_info") then
    return
  end
  local worldwar_public_info = nx_value("worldwar_public_info")
  local public_point_list = relive_ini:GetItemValueList(scene_sec_index, "publicpoint")
  for i = 1, table.getn(public_point_list) do
    if force_index == nx_custom(worldwar_public_info, "arg" .. nx_string(i)) then
      local relive_info_list = util_split_string(public_point_list[i], ",")
      local new_rbtn = gui:Create("RadioButton")
      form.groupbox_2:Add(new_rbtn)
      nx_bind_script(new_rbtn, nx_current())
      nx_callback(new_rbtn, "on_checked_changed", "on_rbtn_relive_changed")
      nx_callback(new_rbtn, "on_get_capture", "on_rbtn_get_capture")
      nx_callback(new_rbtn, "on_lost_capture", "on_rbtn_lost_capture")
      new_rbtn.relive_type = TYPE_RELIVE_PUBLIC
      new_rbtn.relive_index = i
      new_rbtn.relive_posx = relive_info_list[2]
      new_rbtn.relive_posz = relive_info_list[4]
      new_rbtn.relive_name = "ui_fuhuo_" .. nx_string(form.scene_id) .. "_publicpoint_" .. nx_string(i)
      new_rbtn.relive_state = 1
      new_rbtn.Width = 27
      new_rbtn.Height = 27
      new_rbtn.Left, new_rbtn.Top = scene_to_map(form, relive_info_list[2], relive_info_list[4])
      new_rbtn.Left = new_rbtn.Left - new_rbtn.Width / 2
      new_rbtn.Top = new_rbtn.Top - new_rbtn.Height / 2
      new_rbtn.NormalImage = "gui\\special\\schoolwar\\map_new1\\camp_def_out.png"
      new_rbtn.FocusImage = "gui\\special\\schoolwar\\map_new1\\camp_def_on.png"
      new_rbtn.CheckedImage = "gui\\specialschoolwar\\map_new1\\camp_def_down.png"
      new_rbtn.DisableImage = "gui\\specialschoolwar\\map_new1\\camp_forbid.png"
    end
  end
end
function get_angle(x, y)
  local ret = 0
  if -0.001 < x and x < 0.001 then
    if 0 < y then
      return 0
    elseif y < 0 then
      return math.pi
    end
  end
  ret = math.atan2(x, y)
  return nip_radian(ret)
end
function on_rbtn_relive_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked then
    form.select_relive_index = btn.relive_index
    form.select_relive_type = btn.relive_type
    form.select_rbtn = btn
  end
end
function on_rbtn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.lbl_location_name.Text = nx_widestr(gui.TextManager:GetFormatText(btn.relive_name))
  if 0 == btn.relive_state then
    local statename = gui.TextManager:GetFormatText("ui_schoolwar_relive_cantcapture")
    form.lbl_location_state.Text = nx_widestr(statename)
  else
    local statename = gui.TextManager:GetFormatText("ui_schoolwar_relive_capture")
    form.lbl_location_state.Text = nx_widestr(statename)
  end
end
function on_rbtn_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_location_name.Text = nx_widestr("")
  form.lbl_location_state.Text = nx_widestr("")
  if nx_find_custom(form, "select_rbtn") and nx_is_valid(form.select_rbtn) then
    local gui = nx_value("gui")
    form.lbl_location_name.Text = nx_widestr(gui.TextManager:GetFormatText(form.select_rbtn.relive_name))
    if 0 == form.select_rbtn.relive_state then
      local statename = gui.TextManager:GetFormatText("ui_schoolwar_relive_cantcapture")
      form.lbl_location_state.Text = nx_widestr(statename)
    else
      local statename = gui.TextManager:GetFormatText("ui_schoolwar_relive_capture")
      form.lbl_location_state.Text = nx_widestr(statename)
    end
  end
end
function scene_to_map(form, x, z)
  local map_x = form.pic_map.Width - (x - form.pic_map.TerrainStartX) / form.pic_map.TerrainWidth * form.pic_map.Width
  local map_z = (z - form.pic_map.TerrainStartZ) / form.pic_map.TerrainHeight * form.pic_map.Height
  return map_x, map_z
end
function map_to_scene(form, x, z)
  local pos_x = form.pic_map.TerrainWidth - x * form.pic_map.TerrainWidth / form.pic_map.ImageWidth + form.pic_map.TerrainStartX
  local pos_z = z * form.pic_map.TerrainHeight / form.pic_map.ImageHeight + form.pic_map.TerrainStartZ
  return pos_x, pos_z
end
function get_pos_in_map_control(form, x, z)
  local map_x, map_z = scene_to_map(form, x, z)
  local sx = (map_x - form.pic_map.CenterX) * form.pic_map.ZoomWidth
  local sz = (map_z - form.pic_map.CenterY) * form.pic_map.ZoomHeight
  sx = sx + form.pic_map.Width / 2
  sz = sz + form.pic_map.Height / 2
  return sx, sz
end
function get_near_relive_point(form)
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0, 0
  end
  if not nx_find_custom(form, "relive_data") or not nx_is_valid(form.relive_data) then
    return 0, 0
  end
  local x = visual_player.PositionX
  local z = visual_player.PositionZ
  local result_type = 0
  local result_index = 0
  local curDistance = -1
  for i = 1, form.relive_data:GetChildCount() do
    local relive_info = form.relive_data:GetChildByIndex(i - 1)
    local targetx = relive_info.relive_posx
    local targetz = relive_info.relive_posz
    local distance = (targetx - x) * (targetx - x) + (targetz - z) * (targetz - z)
    if -1 == curDistance then
      curDistance = distance
    end
    if distance < curDistance then
      curDistance = distance
      result_type = relive_info.relive_type
      result_index = relive_info.relive_index
    end
  end
  return result_type, result_index
end
function custom_schoolwar_relive(relive_type, check, value, valuetype)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE), relive_type, check, value, valuetype)
end
function fresh_relive_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_find_custom(form, "CanEnableReliveBtn") and form.CanEnableReliveBtn then
    form.btn_return_near_location.Enabled = true
  end
  local buff_str = gui.TextManager:GetFormatText("ui_fuhuo_weak")
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local power_level = player:QueryProp("PowerLevel")
  if 10 < power_level then
    form.lbl_free.Visible = false
    local capital_type = 0
    local money = 0
    capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL)
    if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
      if check_is_enough_money(capital_type, money) or check_is_enough_money(CAPITAL_TYPE_SILVER_CARD, money) then
        form.btn_relive_local.Enabled = true
      else
        form.btn_relive_local.Enabled = false
      end
    end
    capital_type, money = nx_execute("form_stage_main\\form_die_util", "get_confirm_menoy", RELIVE_TYPE_LOCAL_STRONG)
    if nx_int(capital_type) ~= nx_int(0) and nx_int(money) > nx_int(0) then
      if check_is_enough_money(capital_type, money) then
        form.btn_relive_strong.Enabled = true
      else
        form.btn_relive_strong.Enabled = false
      end
    end
  else
    form.lbl_free.Visible = true
  end
  local relive_count = player:QueryProp("DailyReliveCount")
  if nx_int(relive_count) >= nx_int(MAX_RELIVE_COUNT_DAILY) then
    form.btn_relive_strong.Enabled = false
    form.btn_relive_local.Enabled = false
    local count_str = gui.TextManager:GetFormatText("ui_revive_max", nx_int(relive_count))
    form.lbl_count.Text = nx_widestr(count_str)
  else
    local left_count = nx_int(MAX_RELIVE_COUNT_DAILY) - nx_int(relive_count)
    local count_str = gui.TextManager:GetFormatText("ui_revive_count", nx_int(left_count))
    form.lbl_count.Text = nx_widestr(count_str)
  end
end
function on_time_over(form)
  local near_type, near_index = get_near_relive_point(form)
  nx_execute(nx_current(), "custom_schoolwar_relive", RELIVE_TYPE_WORLD_NEAR, nx_int(0), nx_int(near_index), nx_int(near_type))
end
function show_ok_dialog(form, relive_type, health, fight)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local dialog = util_get_form("form_stage_main\\form_relive_ok", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  local str = ""
  if nx_int(relive_type) == TYPE_RELIVE_FORCE or nx_int(relive_type) == nx_int(TYPE_RELIVE_PUBLIC) then
    str = get_confirm_info(relive_type, 0, form.select_rbtn.relive_name)
  else
    str = get_confirm_info(relive_type, 0, "")
  end
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(str), -1)
  local capital_type, capital_num = get_confirm_menoy(relive_type)
  if capital_type == nil or capital_num == nil then
    dialog.mltbox_money_info.Text = ""
  elseif nx_int(capital_type) == nx_int(1) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_suiyin", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  elseif nx_int(capital_type) == nx_int(2) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_yb", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  end
  if relive_type == RELIVE_TYPE_LOCAL or relive_type == RELIVE_TYPE_LOCAL_STRONG then
    local relive_count = player:QueryProp("ReliveCount")
    dialog.lbl_remain_count.Text = nx_widestr(gui.TextManager:GetFormatText("ui_fuhuo_already", nx_int(relive_count)))
  else
    dialog.lbl_remain_count.Visible = false
  end
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  end
  return false
end
function get_fight_force()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return SIDE_ERROR
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return SIDE_ERROR
  end
  local fight_force = client_player:QueryProp("SchoolFightForce")
  return fight_force
end
