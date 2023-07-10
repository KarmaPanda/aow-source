require("util_functions")
function log(str)
end
function show_guild_stamp(actor2, guildname, showlogo)
  if not nx_is_valid(actor2) then
    log("error,actor2 invalid!")
    return
  end
  local filename = "diffuse_" .. nx_string(guildname) .. ".dds"
  log("debug, diffuse file:" .. filename)
  local res_list = util_split_string(showlogo, "#")
  local res_count = table.getn(res_list)
  if res_count < 2 then
    log("error, invalid logo:" .. showlogo)
    return
  end
  local pic_frame = util_split_string(res_list[1], ".")
  if table.getn(pic_frame) ~= 2 then
    log("error, first logo pic invalid:" .. res_list[1])
    return
  end
  local pic_logo = util_split_string(res_list[2], ".")
  if table.getn(pic_logo) ~= 2 then
    log("error, second logo pic invalid:" .. res_list[2])
    return
  end
  local scene = nx_value("game_scene")
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
  end
  local stamp_table = {
    [1] = {
      "Tpose_kneeL_01",
      "map\\tex\\guild_logo\\f" .. pic_frame[1] .. ".dds",
      0.1
    },
    [2] = {
      "Tpose_kneeL_01",
      "map\\tex\\guild_logo\\i" .. pic_logo[1] .. ".dds",
      0.1
    }
  }
  stamp_demo(scene, actor2, stamp_table, filename)
end
function show_guild_stamp_npc(actor2, guildname, showlogo)
  if not nx_is_valid(actor2) then
    log("error,actor2 invalid!")
    return
  end
  local filename = "diffuse_" .. nx_string(guildname) .. ".dds"
  log("debug, diffuse file:" .. filename)
  local res_list = util_split_string(showlogo, "#")
  local res_count = table.getn(res_list)
  if res_count < 2 then
    log("error, invalid logo:" .. showlogo)
    return
  end
  local stamp_table = {}
  local pic_frame = util_split_string(res_list[1], ".")
  if table.getn(pic_frame) == 2 then
    table.insert(stamp_table, {
      "Guild_qizhi01",
      "map\\tex\\guild_logo\\f" .. pic_frame[1] .. ".dds",
      0.4
    })
  end
  local pic_logo = util_split_string(res_list[2], ".")
  if table.getn(pic_logo) == 2 then
    table.insert(stamp_table, {
      "Guild_qizhi01",
      "map\\tex\\guild_logo\\i" .. pic_logo[1] .. ".dds",
      0.4
    })
  end
  if table.getn(stamp_table) == 0 then
    log("error, invalid logo:" .. showlogo)
    return
  end
  local scene = nx_value("game_scene")
  while not actor2.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(actor2) then
      return
    end
  end
  stamp_demo(scene, actor2, stamp_table, filename)
end
function stamp_demo(scene, actor2, stamp_table, filename)
  if not nx_is_valid(scene) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local tpose = actor2:GetLinkObject("Tpose")
  if nx_is_valid(tpose) then
    tpose.Visible = false
  end
  local stamp = scene:Create("Stamp")
  if not nx_is_valid(stamp) then
    return false
  end
  scene:AddObject(stamp, 130)
  if not stamp:SetTarget(actor2, scene) then
    scene:Delete(stamp)
    return false
  end
  local world = nx_value("world")
  local old_trace_hide_model = world.TraceHideModel
  world.TraceHideModel = false
  for _, item in pairs(stamp_table) do
    if not stamp:AddStampByPoint(item[1], item[2], item[3]) then
      log("stamp:AddStampByPoint failed, helper_name(" .. nx_string(item[1]) .. ") stamp_file(" .. nx_string(item[2]) .. " scale(" .. nx_string(item[3]) .. ")")
      scene:Delete(stamp)
      world.TraceHideModel = old_trace_hide_model
      return false
    end
  end
  local new_diffuse_name = filename
  if not stamp:Apply("DiffuseMap", "", new_diffuse_name) then
    log("stamp:Apply failed")
    scene:Delete(stamp)
    world.TraceHideModel = old_trace_hide_model
    return false
  end
  world.TraceHideModel = old_trace_hide_model
  while nx_is_valid(stamp) and not stamp:GetComplete() do
    nx_pause(0)
  end
  if nx_is_valid(stamp) then
    scene:Delete(stamp)
  end
  log("ok")
  return true
end
function init_guildname_npc(npc, guild_name, main_type)
  if not nx_is_valid(npc) then
    log("error,npc invalid!")
    return
  end
  local scene = nx_value("game_scene")
  local textmodel = scene:Create("TextModel")
  textmodel.Visible = false
  npc:UnLink("GuildNameLink", true)
  npc:LinkToPoint("GuildNameLink", "GuildNamePoint", textmodel)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  textmodel.PainterName = gui.PainterName
  if main_type == 7 then
    textmodel.Color = "255,52,31,6"
  else
    textmodel.Color = "255,137,75,1"
  end
  local text_manager = gui.TextManager
  local font = text_manager:GetText("ui_font_lishu")
  if not textmodel:Create(nx_string(guild_name), nx_string(font)) then
    scene:Delete(textmodel)
    return
  end
  textmodel.Extrusion = 0.8
  local scale_x = math.abs(npc.BoxSizeX) / (math.abs(textmodel.BoxSizeX) + math.abs(npc.BoxSizeX) * 0.222)
  log(nx_string(scale_x))
  local scale_y = math.abs(npc.BoxSizeY) / (math.abs(textmodel.BoxSizeY) + math.abs(npc.BoxSizeY) * 0.222)
  log(nx_string(scale_y))
  local scale_z = math.abs(npc.BoxSizeZ) / (math.abs(textmodel.BoxSizeZ) + math.abs(npc.BoxSizeZ) * 0.222)
  log(nx_string(scale_z))
  npc:SetLinkScale("GuildNameLink", scale_x, 1, scale_y)
  textmodel.Visible = true
end
