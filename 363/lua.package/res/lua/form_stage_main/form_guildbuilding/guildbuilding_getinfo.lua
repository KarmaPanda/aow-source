require("util_gui")
require("custom_effect")
require("form_stage_main\\switch\\switch_define")
local goods_color = "<font color=\"#FF0000\">"
local guild_paibian_dds = {
  GuildBuildingNPC122 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC222 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC422 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC722 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC872 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC1072 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC1172 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC1422 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC1572 = "GuildBuildingTex1_3_6_0_shi.dds",
  GuildBuildingNPC622 = "GuildBuildingTex1_3_6_0_mu.dds",
  GuildBuildingNPC1272 = "GuildBuildingTex1_3_6_0_mu.dds",
  GuildBuildingNPC1322 = "GuildBuildingTex1_3_6_0_mu.dds"
}
function log(info)
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(nx_widestr(info), 11, false)
  end
end
function get_building_name(main_type, sub_type)
  return nx_widestr(util_text("ui_guildbuilding_name_" .. main_type .. "_" .. sub_type))
end
function get_building_content(main_type, sub_type)
  return nx_widestr(util_text("ui_guildbuilding_desc_" .. main_type .. "_" .. sub_type))
end
function get_building_level_desc(main_type, sub_type, level)
  return nx_widestr(util_text("ui_guildbuilding_desc_" .. main_type .. "_" .. sub_type .. "_" .. level))
end
function get_building_level_info_desc(main_type, sub_type, level)
  local info_text = nx_widestr(util_text("ui_guildbuilding_desc_" .. main_type .. "_" .. sub_type .. "_" .. level .. "_xinxi_1"))
  info_text = info_text .. nx_widestr("<br>") .. nx_widestr(util_text("ui_guildbuilding_desc_xinxi_2")) .. nx_widestr(get_build_edure(main_type, sub_type, level))
  info_text = info_text .. nx_widestr("<br>") .. nx_widestr(util_text("ui_guildbuilding_desc_" .. main_type .. "_" .. sub_type .. "_" .. level .. "_xinxi_3"))
  if nx_int(main_type) == nx_int(5) and nx_int(sub_type) == nx_int(0) then
    info_text = info_text .. nx_widestr("<br>") .. nx_widestr(util_text("ui_guildbuilding_occupy_" .. main_type .. "_" .. sub_type .. "_" .. level))
  end
  return nx_widestr(info_text)
end
function get_building_zengyi(main_type, sub_type, level)
  local gui = nx_value("gui")
  local gb_manager = nx_value("GuildbuildingManager")
  local infos = gb_manager:GetGuildBuildingLevelInfo(main_type, sub_type, level)
  local add = 0
  if table.getn(infos) >= 9 then
    add = infos[6]
  end
  return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_zengyi", nx_int(add)))
end
function get_building_level(level)
  local gui = nx_value("gui")
  if nx_int(level) >= nx_int(5) then
    return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_level", nx_int(level), nx_int(level)))
  end
  return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_level", nx_int(level), nx_int(level + 1)))
end
function get_building_leftTime(stopLeftTime, coolLeftTime)
  local gui = nx_value("gui")
  if 0 < stopLeftTime then
    hour, min = getHourMin(stopLeftTime)
    return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_uptime", nx_int(hour), nx_int(min)))
  elseif 0 < coolLeftTime then
    hour, min = getHourMin(coolLeftTime)
    return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_cooltime", nx_int(hour), nx_int(min)))
  else
    return nx_widestr(gui.TextManager:GetFormatText("ui_guildbuilding_cooltime", nx_int(0), nx_int(0)))
  end
end
function getHourMin(time)
  local allmin = math.floor(time / 60000)
  local hour = math.floor(allmin / 60)
  local min = math.floor(allmin % 60)
  return nx_int(hour), nx_int(min) + nx_int(1)
end
function get_building_btn(level)
  return nx_widestr(util_text("ui_guild_levelup"))
end
function refresh_guild_paibian(visual_npc, client_npc)
  if not nx_is_valid(client_npc) or not nx_is_valid(visual_npc) then
    return
  end
  local ActorVisualList = visual_npc:GetVisualList()
  if type(ActorVisualList) ~= "table" or table.getn(ActorVisualList) == 0 then
    return
  end
  local skin
  for _, obj in pairs(ActorVisualList) do
    if nx_is_valid(obj) then
      if nx_name(obj) == "EffectModel" then
        skin = obj.ModelID
        break
      elseif nx_name(obj) == "Skin" then
        skin = obj
        break
      end
    end
  end
  if not nx_is_valid(skin) then
    return
  end
  local config = client_npc:QueryProp("ConfigID")
  if guild_paibian_dds[config] == nil then
    return
  end
  skin:SetCustomMaterialValue("1", "DiffuseMap", guild_paibian_dds[config])
  skin:ReloadCustomMaterialTexture("1", "DiffuseMap")
end
function a(info)
  nx_msgbox(nx_string(info))
end
function on_refresh_guildbuilding(visual_npc, client_npc)
  if not nx_is_valid(client_npc) or not nx_is_valid(visual_npc) then
    return
  end
  local main_id = client_npc:QueryProp("DomainID")
  local main_type = client_npc:QueryProp("MainType")
  local sub_type = client_npc:QueryProp("SubType")
  local level = client_npc:QueryProp("CurLevel")
  sub_on_refresh_guildbuilding(visual_npc, main_id, main_type, sub_type, level)
end
function sub_on_refresh_guildbuilding(visual_npc, main_id, main_type, sub_type, level)
  if not nx_is_valid(visual_npc) then
    return
  end
  local manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(manager) then
    return
  end
  local guildwarmanager = nx_value("GuildWarManager")
  if not nx_is_valid(guildwarmanager) then
    return
  end
  local switchmgr = nx_value("SwitchManager")
  if not nx_is_valid(switchmgr) then
    return
  end
  local new_level = level
  if switchmgr:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    new_level = guildwarmanager:GetDomainLevel(main_id) - 1
  end
  if nx_find_custom(visual_npc, "guild_main_tex_index") then
    local cur_guild_main_tex_index = nx_custom(visual_npc, "guild_main_tex_index")
    local new_guild_main_tex_index = nx_string(main_type) .. "." .. nx_string(sub_type) .. "." .. nx_string(new_level)
    if nx_string(cur_guild_main_tex_index) == nx_string(new_guild_main_tex_index) then
      return
    end
  else
    visual_npc.guild_main_tex_index = nx_string(main_type) .. "." .. nx_string(sub_type) .. "." .. nx_string(new_level)
  end
  local relist
  if switchmgr:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    relist = manager:GetNewGuildBuildingPiecesInfo(nx_int(main_type), nx_int(sub_type), nx_int(new_level))
  else
    relist = manager:GetGuildBuildingPiecesInfo(nx_int(main_type), nx_int(sub_type), nx_int(new_level))
  end
  if 1 >= table.getn(relist) or table.getn(relist) % 2 ~= 0 then
    return
  end
  change_building_tex(visual_npc, main_type, sub_type, new_level)
  change_item_tex(visual_npc, main_type, sub_type, new_level)
end
function change_building_tex(visual_npc, main_type, sub_type, level)
  local manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(manager) then
    return
  end
  local switchmgr = nx_value("SwitchManager")
  if not nx_is_valid(switchmgr) then
    return
  end
  local relist
  if switchmgr:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    relist = manager:GetNewGuildBuildingPiecesInfo(nx_int(main_type), nx_int(sub_type), nx_int(level))
  else
    relist = manager:GetGuildBuildingPiecesInfo(nx_int(main_type), nx_int(sub_type), nx_int(level))
  end
  if table.getn(relist) <= 1 or table.getn(relist) % 2 ~= 0 then
    return
  end
  local ActorVisualList = visual_npc:GetVisualList()
  if type(ActorVisualList) ~= "table" or table.getn(ActorVisualList) == 0 then
    return
  end
  local skin
  for _, obj in pairs(ActorVisualList) do
    if nx_is_valid(obj) then
      if nx_name(obj) == "EffectModel" then
        skin = obj.ModelID
        break
      elseif nx_name(obj) == "Skin" then
        skin = obj
        break
      end
    end
  end
  if not nx_is_valid(skin) then
    return
  end
  while not skin.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(skin) then
      return
    end
  end
  local count = table.getn(relist) / 2
  local index = 1
  local exist_custom_mat = true
  for i = 1, count do
    local mat_name = relist[index]
    local exist_mat = skin:FindCustomMaterial(mat_name)
    if not exist_mat then
      exist_custom_mat = false
    end
    skin:SetCustomMaterialValue(nx_string(mat_name), "DiffuseMap", nx_string(relist[index + 1]) .. ".dds")
    skin:ReloadCustomMaterialTexture(mat_name, "DiffuseMap")
    index = index + 2
  end
  nx_set_custom(visual_npc, "guild_main_tex_index", nx_string(main_type) .. "." .. nx_string(sub_type) .. "." .. nx_string(level))
  if not exist_custom_mat then
    skin:ReloadCustomMaterialTextures()
  end
end
function get_model_obj(visual_npc, model_name)
  if not nx_find_custom(visual_npc, "item_list") then
    visual_npc.item_list = get_global_arraylist("guildbuilding_getinfo_item_list")
  end
  if visual_npc.item_list:FindChild(model_name) then
    local node = visual_npc.item_list:GetChild(model_name)
    if nx_is_valid(node.model) then
      return node.model
    else
      visual_npc.item_list:RemoveChild(model_name)
    end
  end
  local model_obj = nx_execute("util_functions", "util_create_model", model_name, "", "", "", "", false)
  local child = visual_npc.item_list:CreateChild(model_name)
  child.model = model_obj
  return model_obj
end
function change_item_tex(visual_npc, main_type, sub_type, level)
  local manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(manager) then
    return
  end
  local switchmgr = nx_value("SwitchManager")
  if not nx_is_valid(switchmgr) then
    return
  end
  local model_list = manager:GetItemModelList(nx_int(main_type), nx_int(sub_type))
  for i = 1, table.getn(model_list) do
    local modpath = "map\\mdl\\bangpai001\\" .. model_list[i]
    local model = get_model_obj(visual_npc, modpath)
    while not model.LoadFinish do
      nx_pause(0.1)
      if not nx_is_valid(model) then
        return
      end
    end
    local tex_list
    if switchmgr:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
      tex_list = manager:GetNewSkinPieces(nx_string(model_list[i]), nx_int(level))
    else
      tex_list = manager:GetSkinPieces(nx_string(model_list[i]), nx_int(level))
    end
    local tex_count = table.getn(tex_list) / 2
    local idx = 1
    for j = 1, tex_count do
      local tex = nx_string(tex_list[idx + 1]) .. ".dds"
      local MaterialNameList = model:GetMaterialNameList()
      if type(MaterialNameList) ~= "table" or table.maxn(MaterialNameList) == 0 then
        break
      end
      for k = 1, table.getn(MaterialNameList) do
        if nx_string(MaterialNameList[k]) == nx_string(tex_list[idx]) then
          model:SetMaterialValue(MaterialNameList[k], "DiffuseMap", tex)
          break
        end
      end
      idx = idx + 2
    end
    model:ReloadMaterialTextures()
  end
end
function show_upgrade_effect(visual_npc, client_npc)
  if not nx_is_valid(client_npc) or not nx_is_valid(visual_npc) then
    return
  end
  local main_type = client_npc:QueryProp("MainType")
  local sub_type = client_npc:QueryProp("SubType")
  local level = client_npc:QueryProp("CurLevel")
  local is_upgrade = client_npc:QueryProp("IsUpgrading")
  local isDoor = client_npc:QueryProp("IsDoor")
  if nx_int(isDoor) > nx_int(0) then
    return
  end
  if nx_int(is_upgrade) ~= nx_int(1) then
    model = nx_value("updatebuildingmode" .. nx_string(main_type) .. nx_string(sub_type))
    if nx_is_valid(model) then
      model.LifeTime = 0
    end
    return
  end
  local manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(manager) then
    return
  end
  local infos = manager:GetEffectNameTime(main_type, sub_type, level)
  if table.getn(infos) ~= 2 then
    return
  end
  local effect_name = infos[1]
  local left_time = nx_int(infos[2]) * 60
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local bind_model = get_role_model(visual_npc)
  if nx_string(effect_name) ~= nx_string("") then
    model = nx_execute("game_effect", "create_linktopoint_effect_by_target", nx_string(effect_name), nx_int(left_time), bind_model, "", 0, 0, 0, 0, 0, 0, 1, 1, 1)
    nx_set_value("updatebuildingmode" .. nx_string(main_type) .. nx_string(sub_type), model)
  end
end
function transform_time(time)
  local gui = nx_value("gui")
  if time < 0 then
    time = 0
  end
  local days = math.floor(time / 86400000)
  local hrs = math.floor((time - days * 86400000) / 3600000)
  local mins = math.floor((time - days * 86400000 - hrs * 3600000) / 60000)
  local secs = math.floor((time - days * 86400000 - hrs * 3600000 - mins * 60000) / 1000)
  local final_time
  if 0 < days then
    final_time = nx_widestr(days) .. nx_widestr(gui.TextManager:GetText("ui_day")) .. nx_widestr(hrs) .. nx_widestr(gui.TextManager:GetText("ui_hourx")) .. nx_widestr(mins) .. nx_widestr(gui.TextManager:GetText("ui_min")) .. nx_widestr(secs) .. nx_widestr(gui.TextManager:GetText("ui_sec"))
  elseif 0 < hrs then
    final_time = nx_widestr(hrs) .. nx_widestr(gui.TextManager:GetText("ui_hourx")) .. nx_widestr(mins) .. nx_widestr(gui.TextManager:GetText("ui_min")) .. nx_widestr(secs) .. nx_widestr(gui.TextManager:GetText("ui_sec"))
  elseif 0 < mins then
    final_time = nx_widestr(mins) .. nx_widestr(gui.TextManager:GetText("ui_min")) .. nx_widestr(secs) .. nx_widestr(gui.TextManager:GetText("ui_sec"))
  else
    final_time = nx_widestr(secs) .. nx_widestr(gui.TextManager:GetText("ui_sec"))
  end
  return final_time
end
function get_build_edure(main_type, sub_type, level)
  local gui = nx_value("gui")
  local file_name = "share\\Rule\\guild_building_repair.ini"
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local ini_main_type = ini:ReadInteger(i, "MainType", 1)
    local ini_sub_type = ini:ReadInteger(i, "SubType", 0)
    local ini_level = ini:ReadInteger(i, "Level", 0)
    if ini_main_type == main_type and ini_sub_type == sub_type and ini_level == level then
      local ini_endure = ini:ReadInteger(i, "MaxEndure", 0)
      if nx_number(ini_endure) > nx_number(10000) then
        ini_endure = nx_widestr(nx_number(ini_endure) / 10000) .. nx_widestr(gui.TextManager:GetText("ui_buildlevel_w"))
      end
      return nx_string(ini_endure)
    end
  end
  return 0
end
