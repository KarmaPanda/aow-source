require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
local steps = 0
function form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function refresh_scene_map(sence_id, domain_id)
  local form = util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_domain_preview")
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  local file_name = "share\\Guild\\GuildDomain\\scene_map.ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    nx_msgbox(get_msg_str("msg_418") .. file_name)
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(sence_id))
  if sec_index < 0 then
    return
  end
  local name = ini:ReadString(sec_index, "r", "")
  local map_name = "gui\\map\\scene\\" .. name .. "\\" .. name .. ".dds"
  form.pic_map.Image = map_name
  local file_name = "gui\\map\\scene\\" .. name .. "\\" .. name .. ".ini"
  local ini_2 = get_ini(file_name)
  if not nx_is_valid(ini_2) then
    nx_msgbox(get_msg_str("msg_418") .. file_name)
    return
  end
  local sec_index = ini_2:FindSectionIndex("Map")
  form.pic_map.ZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.ZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  steps = 1
  local zoom = form.pic_map.ZoomWidth
  while zoom <= 1 do
    zoom = zoom * 1.01
    steps = steps + 1
  end
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  if sec_index < 0 then
    return
  end
  if domain_id ~= 0 then
    local scene_posX = ini_2:ReadInteger(sec_index, nx_string(domain_id) .. "X", 0)
    local scene_posZ = ini_2:ReadInteger(sec_index, nx_string(domain_id) .. "Z", 0)
    local TerrainStartX = ini_2:ReadInteger(sec_index, "StartX", 0)
    local TerrainStartZ = ini_2:ReadInteger(sec_index, "StartZ", 0)
    local TerrainWidth = ini_2:ReadInteger(sec_index, "Width", 1024)
    local TerrainHeight = ini_2:ReadInteger(sec_index, "Height", 1024)
    local posX, posY = nx_execute("form_stage_main\\form_map\\form_map_scene", "trans_scene_pos_to_image", scene_posX, scene_posZ, form.pic_map.ImageWidth, form.pic_map.ImageHeight, TerrainStartX, TerrainStartZ, TerrainWidth, TerrainHeight)
    local moveX = posX - form.pic_map.CenterX
    local moveY = posY - form.pic_map.CenterY
    nx_pause(1)
    if not nx_is_valid(form) then
      return
    end
    local game_timer = nx_value("timer_game")
    times = 1
    game_timer:Register(10, -1, nx_current(), "show_domain_position", form, moveX, moveY)
  end
end
function show_domain_position(form, posX, posY)
  form.pic_map.ZoomWidth = form.pic_map.ZoomWidth * 1.01
  form.pic_map.ZoomHeight = form.pic_map.ZoomHeight * 1.01
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2 + posX * (times / steps)
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2 + posY * (times / steps)
  times = times + 1
  if form.pic_map.ZoomWidth > 1 or not form.pic_map.Visible then
    local game_timer = nx_value("timer_game")
    game_timer:UnRegister(nx_current(), "show_domain_position", form)
  end
end
