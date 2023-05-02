require("util_functions")
require("form_stage_main\\form_die_util")
local TYPE_RELIVE_ATT = 1
local TYPE_RELIVE_DEF = 2
local TYPE_RELIVE_GUILD = 3
local TYPE_RELIVE_PUBLIC = 4
local SIDE_ERROR = 0
local SIDE_DEFEND = 1
local SIDE_ATTACK = 2
local FILE_INDEX = {
  "share\\War\\schoolfight_attackpoint.ini",
  "share\\War\\schoolfight_defendpoint.ini",
  "share\\War\\schoolfight_guildpoint.ini",
  "share\\War\\schoolfight_publicpoint.ini"
}
local FILE_MAP_POINT = "ini\\ui\\relive\\schoolfight_maprange.ini"
local NORMAL_IMAGE = "gui\\special\\relive\\hospital\\hospital_normal.png"
local FOCUS_IMAGE = "gui\\special\\relive\\hospital\\hospital_focus.png"
local CHECK_IMAGE = "gui\\special\\relive\\hospital\\hospital_checked.png"
local DISABLE_IMAGE = "gui\\special\\relive\\hospital\\hospital_disable.png"
local BUFF_BAOHU = "gui\\special\\action_show\\zhaohu.png"
local BUFF_XURUO = "gui\\special\\action_show\\baiji.png"
local BUFF_KUANG = "gui\\special\\relive\\buff_high_light.png"
local MOV_FPS = 30
local TOP_X = 104
local TOP_Y = 82
local MID_X = 104
local MID_Y = 200
local BOTTOM_X = 104
local BOTTOM_Y = 264
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
  local local_buff_id = nx_execute("form_stage_main\\form_die_util", "get_relive_buff", RELIVE_TYPE_LOCAL, 0)
  form.local_buff = get_buff_photo(local_buff_id)
  form.safe_buff = get_buff_photo(RELIVE_SAFE_BUFFER)
  form.select_type = RELIVE_TYPE_SCHOOL
  fresh_relive_form(form)
  form.select_relive_index = 0
  form.select_relive_type = 0
  form.btn_return_near_location.Enabled = false
  form.CanEnableReliveBtn = false
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) and client_player:FindProp("SchoolFightLeader") and client_player:QueryProp("SchoolFightLeader") == 1 then
    local relive_timer = nx_value("timer_game")
    relive_timer:UnRegister(nx_current(), "on_update_time", form)
    relive_timer:Register(15000, 1, nx_current(), "on_update_time", form, -1, -1)
  else
    on_update_time(form)
  end
end
function on_main_form_close(form)
  local timer = nx_value("common_execute")
  timer:RemoveExecute("relive_fresh_timer", form)
  local relive_timer = nx_value("timer_game")
  relive_timer:UnRegister(nx_current(), "on_update_time", form)
  if nx_find_custom(form, "relive_data") and nx_is_valid(form.relive_data) then
    form.relive_data:ClearChild()
    nx_destroy(form.relive_data)
  end
  local ok_dialog = nx_value("form_stage_main\\form_relive_ok")
  if nx_is_valid(ok_dialog) then
    ok_dialog:Close()
  end
  nx_destroy(form)
end
function on_update_time(form)
  form.btn_return_near_location.Enabled = true
  form.CanEnableReliveBtn = true
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
  if not show_ok_dialog(form, RELIVE_TYPE_SCHOOL, nx_int(0), nx_int(0)) then
    return 0
  end
  nx_execute(nx_current(), "custom_schoolwar_relive", RELIVE_TYPE_SCHOOL, nx_int(0), nx_int(form.select_relive_index), nx_int(form.select_relive_type))
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
function on_cbtn_fight_get_capture(btn)
  local form = btn.ParentForm
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_fuhuo_immediately_tips")), btn.AbsLeft, btn.AbsTop, 0, form)
end
function on_cbtn_fight_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_cbtn_health_get_capture(btn)
  local form = btn.ParentForm
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_fuhuo_health_tips")), btn.AbsLeft, btn.AbsTop, 0, form)
end
function on_cbtn_health_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function load_relive_location_info(form, sceneid, ...)
  if not nx_find_custom(form, "relive_data") or not nx_is_valid(form.relive_data) then
    form.relive_data = nx_call("util_gui", "get_arraylist", "schoolwar_relive_data")
  end
  form.relive_data:ClearChild()
  local fight_force = get_fight_force()
  if SIDE_ERROR == fight_force then
    return
  end
  form.sceneid = sceneid
  CreatePlayerRelivePoint(form, TYPE_RELIVE_GUILD)
  if SIDE_ATTACK == fight_force then
    CreatePlayerRelivePoint(form, TYPE_RELIVE_ATT)
  elseif SIDE_DEFEND == fight_force then
    CreatePlayerRelivePoint(form, TYPE_RELIVE_DEF)
  end
  for i = 1, table.getn(arg), 2 do
    local relive_type = arg[i]
    local relive_index = arg[i + 1]
    local child = form.relive_data:GetChild(nx_string(relive_type) .. nx_string(relive_index))
    if not nx_is_valid(child) then
      local findinfo = FindPlayerRelivePoint(form, tonumber(relive_type), tonumber(relive_index))
      if findinfo ~= nil then
        child = form.relive_data:CreateChild(nx_string(relive_type) .. nx_string(relive_index))
        child.relive_type = relive_type
        child.relive_index = relive_index
        child.relive_posx = findinfo[2]
        child.relive_posz = findinfo[4]
        child.relive_name = findinfo[6]
        child.relive_number = findinfo[7]
        child.relive_image_n = NORMAL_IMAGE
        child.relive_image_f = FOCUS_IMAGE
        child.relive_image_c = CHECK_IMAGE
        child.relive_image_d = DISABLE_IMAGE
        child.relive_state = 1
        local image_arr = util_split_string(findinfo[8], ";")
        if table.getn(image_arr) >= 8 then
          if fight_force == SIDE_DEFEND then
            child.relive_image_n = image_arr[1]
            child.relive_image_f = image_arr[2]
            child.relive_image_c = image_arr[3]
            child.relive_image_d = image_arr[4]
          elseif fight_force == SIDE_ATTACK then
            child.relive_image_n = image_arr[5]
            child.relive_image_f = image_arr[6]
            child.relive_image_c = image_arr[7]
            child.relive_image_d = image_arr[8]
          end
        end
      end
    else
      child.relive_state = 1
    end
  end
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(FILE_MAP_POINT) then
    IniManager:LoadIniToManager(FILE_MAP_POINT)
  end
  local ini = IniManager:GetIniDocument(FILE_MAP_POINT)
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
  if not nx_find_custom(form.pic_map, "showwidth") then
    form.pic_map.showwidth = 1000
  end
  if not nx_find_custom(form.pic_map, "showheight") then
    form.pic_map.showheight = 1000
  end
  if not nx_find_custom(form.pic_map, "startx") then
    form.pic_map.startx = 0
  end
  if not nx_find_custom(form.pic_map, "startz") then
    form.pic_map.startz = 0
  end
  form.pic_map.ZoomWidth = form.pic_map.Width / form.pic_map.showwidth
  form.pic_map.ZoomHeight = form.pic_map.Height / form.pic_map.showheight
  local tempx = form.pic_map.startx - form.pic_map.showwidth / 2
  local tempz = form.pic_map.startz + form.pic_map.showheight / 2
  form.pic_map.CenterX, form.pic_map.CenterY = scene_to_map(form, tempx, tempz)
  local gui = nx_value("gui")
  for i = 1, form.relive_data:GetChildCount() do
    local relive_info = form.relive_data:GetChildByIndex(i - 1)
    local new_rbtn = gui:Create("RadioButton")
    form.groupbox_2:Add(new_rbtn)
    nx_bind_script(new_rbtn, nx_current())
    nx_callback(new_rbtn, "on_checked_changed", "on_rbtn_relive_changed")
    nx_callback(new_rbtn, "on_get_capture", "on_rbtn_get_capture")
    nx_callback(new_rbtn, "on_lost_capture", "on_rbtn_lost_capture")
    new_rbtn.relive_type = relive_info.relive_type
    new_rbtn.relive_index = relive_info.relive_index
    new_rbtn.relive_posx = relive_info.relive_posx
    new_rbtn.relive_posz = relive_info.relive_posz
    new_rbtn.relive_name = relive_info.relive_name
    new_rbtn.relive_state = relive_info.relive_state
    new_rbtn.Width = 27
    new_rbtn.Height = 27
    new_rbtn.Left, new_rbtn.Top = get_pos_in_map_control(form, relive_info.relive_posx, relive_info.relive_posz)
    new_rbtn.Left = new_rbtn.Left - new_rbtn.Width / 2
    new_rbtn.Top = new_rbtn.Top - new_rbtn.Height / 2
    if 0 > new_rbtn.Left or new_rbtn.Left > form.pic_map.Width or 0 > new_rbtn.Top or new_rbtn.Top > form.pic_map.Height then
      process_relive_out_of_range(form, new_rbtn)
    end
    new_rbtn.NormalImage = relive_info.relive_image_n
    new_rbtn.FocusImage = relive_info.relive_image_f
    new_rbtn.CheckedImage = relive_info.relive_image_c
    new_rbtn.DisableImage = relive_info.relive_image_d
    if 0 == relive_info.relive_state then
      new_rbtn.Enabled = false
    end
    local lab = gui:Create("Label")
    lab.Width = 15
    lab.Height = 15
    lab.Left = new_rbtn.Left
    lab.Top = new_rbtn.Top + 15
    lab.Font = "font_main"
    lab.ForeColor = "255,255,0,0"
    lab.Align = "Right"
    lab.Text = nx_widestr(relive_info.relive_number)
    form.groupbox_2:Add(lab)
  end
end
function process_relive_out_of_range(form, btn)
  local gui = nx_value("gui")
  local icon_lab = gui:Create("Label")
  form.groupbox_2:Add(icon_lab)
  local btnOffSet = 0
  local iconOffSet = 0
  local recordx = btn.Left
  local recordy = btn.Top
  icon_lab.Left = 0
  icon_lab.Top = 0
  if 0 > btn.Left then
    btn.Left = btnOffSet
    icon_lab.Left = btn.Left - iconOffSet
  elseif btn.Left > form.pic_map.Width then
    btn.Left = form.pic_map.Width - btn.Width - btnOffSet
    icon_lab.Left = btn.Left + iconOffSet
  end
  if 0 > btn.Top then
    btn.Top = btnOffSet
    icon_lab.Top = btn.Top - iconOffSet
  elseif btn.Top > form.pic_map.Height then
    btn.Top = form.pic_map.Height - btn.Height - btnOffSet
    icon_lab.Top = btn.Top + iconOffSet
  end
  if icon_lab.Left == 0 then
    icon_lab.Left = btn.Left
  end
  if icon_lab.Top == 0 then
    icon_lab.Top = btn.Top
  end
  local angle = get_angle(recordx - btn.Left, recordy - btn.Top)
  icon_lab.Rotate = true
  icon_lab.AngleZ = angle + math.pi / 2
  icon_lab.Width = 26
  icon_lab.Height = 26
  icon_lab.BackImage = "relive_arrowhead"
  icon_lab.DrawMode = "FitWindow"
  form.groupbox_2:ToFront(btn)
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
  local map_x = form.pic_map.ImageWidth - (x - form.pic_map.TerrainStartX) / form.pic_map.TerrainWidth * form.pic_map.ImageWidth
  local map_z = (z - form.pic_map.TerrainStartZ) / form.pic_map.TerrainHeight * form.pic_map.ImageHeight
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
    form.mltbox_count.HtmlText = nx_widestr(count_str)
  else
    local left_count = nx_int(MAX_RELIVE_COUNT_DAILY) - nx_int(relive_count)
    local count_str = gui.TextManager:GetFormatText("ui_revive_count", nx_int(left_count))
    form.mltbox_count.HtmlText = nx_widestr(count_str)
  end
end
function image_moving(obj, end_Left, end_Top)
  if not nx_is_valid(obj) then
    return
  end
  if false == obj.Visible then
    return
  end
  if nx_number(obj.Left) == nx_number(end_Left) and nx_number(obj.Top) == nx_number(end_Top) then
    return
  end
  local obj_x = obj.Left
  local obj_y = obj.Top
  local dis_x = end_Left - obj.Left
  local dis_y = end_Top - obj.Top
  for i = 1, MOV_FPS do
    nx_pause(0.01)
    if not nx_is_valid(obj) then
      return
    end
    local move_x = nx_int(nx_float(dis_x / MOV_FPS) * i)
    local move_y = nx_int(nx_float(dis_y / MOV_FPS) * i)
    obj.Left = obj_x + move_x
    obj.Top = obj_y + move_y
  end
  obj.Left = nx_number(end_Left)
  obj.Top = nx_number(end_Top)
end
function syn_image_moving(obj, end_Left, end_Top)
  nx_execute(nx_current(), "image_moving", obj, end_Left, end_Top)
end
function show_life_water(form)
  nx_pause(2)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_life_water.Visible = true
  form.lbl_life_water.Top = form.Height
  image_moving(form.lbl_life_water, BOTTOM_X, BOTTOM_Y)
end
function on_time_over(form)
  local near_type, near_index = get_near_relive_point(form)
  nx_execute(nx_current(), "custom_schoolwar_relive", RELIVE_TYPE_SCHOOL, nx_int(0), nx_int(near_index), nx_int(near_type))
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
  local pointname
  if relive_type == RELIVE_TYPE_SCHOOL then
    local child = form.relive_data:GetChild(nx_string(form.select_relive_type) .. nx_string(form.select_relive_index))
    if nx_is_valid(child) then
      pointname = child.relive_name
    end
  end
  fight = 0
  local str = get_confirm_info(relive_type, fight, pointname)
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
