require("const_define")
require("util_functions")
require("share\\client_custom_define")
require("form_stage_main\\switch\\url_define")
require("custom_sender")
require("game_config")
require("scene")
require("gameinfo_collector")
function main(world, login_addr, login_port, server_name, area_addr, area_port, server_sdo, select_type, login_account, login_validate)
  nx_function("ext_req_create")
  nx_set_value("world", world)
  math.randomseed(os.clock())
  local dev_caps = nx_create("DeviceCaps", world.RenderName)
  local err_msg = nx_create("ErrorMsg")
  if nx_is_valid(err_msg) then
    nx_set_value("ErrorMsg", err_msg)
    err_msg:SetFile(get_language_path() .. "error_msg.idres")
  end
  if not nx_is_valid(dev_caps) then
    nx_msgbox(get_error_msg("msg_426"))
    return 0
  end
  nx_set_value("device_caps", dev_caps)
  if not dev_caps.DeviceAvailable then
    nx_msgbox(get_error_msg("msg_433"))
    return 0
  end
  if not dev_caps.SupportSSE then
    nx_msgbox(get_error_msg("msg_427"))
    return 0
  end
  dev_caps:QueryVideoMemory()
  if dev_caps.MaxTextures < 8 then
    nx_msgbox(get_error_msg("msg_428"))
    return 0
  end
  if dev_caps.TotalVideoMemory + dev_caps.TotalAgpMemory < 100 then
    nx_msgbox(get_error_msg("msg_429"))
    return 0
  end
  world.sleep_value = world.Sleep
  world.land_scene_info = ""
  local device_level, not_identify = nx_call("device_test", "get_video_card_level", dev_caps)
  world.device_level = device_level
  world.may_device_level = -1
  if not_identify ~= nil then
    world.device_not_identify = true
  end
  local win_device_level = nx_call("device_test", "compare_video_card", dev_caps)
  if device_level < win_device_level and device_level < 1 then
    world.device_level = 1
    nx_call("device_test", "set_may_device_level", win_device_level)
  end
  create_game_config()
  local game_config = nx_value("game_config")
  if login_validate == "steamapp" then
    login_validate = ""
    local AOWSteamClient = nx_create("AOWSteamClient")
    nx_set_value("AOWSteamClient", AOWSteamClient)
    if not AOWSteamClient:InitSteam() then
      nx_destroy(AOWSteamClient)
    end
  end
  game_config.login_verify = ""
  game_config.login_validate = ""
  if nx_string(select_type) == "" or select_type == nil then
    select_type = "2"
  end
  game_config.login_type = nx_string(select_type)
  nx_execute("game_experience", "game_experience_init")
  if login_addr == "ScriptDebug" then
    if game_config.login_addr == nil or game_config.login_addr == "" then
      game_config.login_addr = "127.0.0.1"
      game_config.login_port = 2001
    end
  else
    game_config.login_addr = login_addr
    game_config.login_port = nx_int(login_port)
    if login_account ~= nil and nx_string(login_account) ~= "" then
      game_config.login_account = login_account
    end
    if login_validate ~= nil and nx_string(login_validate) ~= "" then
      game_config.login_validate = login_validate
    end
    if server_name ~= nil and nx_string(server_name) ~= "" and game_config.server_name == nx_widestr("") then
      game_config.server_name = nx_function("ext_utf8_to_widestr", server_name)
    end
    if area_addr ~= nil and nx_string(area_addr) ~= "" then
      game_config.area_addr = area_addr
    end
    if area_port ~= nil and nx_string(area_port) ~= "" then
      game_config.area_port = nx_int(area_port)
    end
    if server_sdo ~= nil and nx_string(server_sdo) ~= "" then
      game_config.server_sdo = nx_string(server_sdo)
    else
      game_config.server_sdo = nx_string(0)
    end
  end
  nx_set_value("stage", "start")
  nx_set_value("stage_main", "exit")
  world.Width = 800
  world.Height = 600
  world.MinDeviceWidth = 1000
  world.MinDeviceHeight = 720
  world.DeviceType = "HAL"
  world.ColorFormat = "X8R8G8B8"
  world.DepthFormat = "D24S8"
  world.MultiSampleType = "NONE"
  world.Title = ""
  world.ShowTitle = true
  world.Windowed = true
  world.Anisotropic = true
  world.BackColor = "0,200,200,200"
  if dev_caps.VendorId == 4318 then
    local nv_version = dev_caps:GetDriverVersionNV()
    if 25600 < nv_version and dev_caps.SupportIntZDepth then
      world.ResolveDepthNV = true
    end
  elseif dev_caps.SupportResolveDepth and dev_caps.SupportIntZDepth then
    world.ResolveDepthATI = true
  end
  if dev_caps.SupportIntZDepth then
    world.UseIntZDepth = true
  elseif dev_caps.SupportRawZDepth and dev_caps.VendorId == 4318 then
    world.UseRawZDepth = true
  end
  world.AsyncRenderScene = true
  world.ExecuteFPS = 0
  apply_window_config_no_reset(game_config)
  world:UpdateWindow()
  nx_log(get_error_msg("msg_432"))
  if not world:CreateDevice("FxRender.DxRender") then
    nx_msgbox(get_error_msg("msg_431"))
    return 0
  end
  if nx_file_exists(nx_work_path() .. "SnailHook.dll") then
    world.HookFileStateInPackage = true
  end
  nx_log(get_error_msg("msg_430"))
  world.GuiUseShader = true
  world.GeometryInstancing = false
  nx_function("ext_adjust_frame_time")
  world.EnableTraceTreeLeaf = false
  world.TraceAloneTexture = 3
  world.TraceAlphaRef = 100
  world.OnlyTraceBoundBoxDistance = 50
  world.SupportPhysics = nx_execute("form_stage_main\\form_system\\form_system_setting", "can_support_physics")
  if dev_caps.SupportPhysxCloth then
    world.SupportPhysicsCloth = true
  end
  local gui = nx_create("Gui", "FxRender.Painter")
  nx_set_value("gui", gui)
  world.MainGui = gui
  if not gui:CreateDesktopForm() then
    nx_msgbox(get_msg_str("msg_431"))
    return false
  end
  apply_window_config_no_reset(game_config)
  nx_log("entry prepare...")
  nx_execute("stage", "set_current_stage", "prepare")
  nx_pause(0)
  GTP_init_game_info_collector()
  GTP_set_collector_time(GTP_LUA_FUNC_EXIT, true, false)
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_ACTIVATE_N_LAUNCH)
  nx_log("show main window")
  world:ShowWindow()
  nx_pause(0)
  world.DisplayFPS = 30
  nx_bind_script(gui, "gui", "gui_init")
  nx_bind_script(gui.GameHand, "game_hand", "gamehand_init")
  local resource_xml = gui.skin_path .. "resource.xml"
  if game_config.Language ~= "" then
    resource_xml = "skin\\resource_" .. nx_string(game_config.Language) .. ".xml"
  end
  gui.Loader.DefResourceName = resource_xml
  GTP_set_collector_time(GTP_LUA_FUNC_LOAD_RESOURCE, true, false)
  nx_log("load gui resource begin...")
  gui.Loader:LoadResource(nx_resource_path(), resource_xml)
  nx_log("load gui resource end")
  gui.Cursor = "Default"
  nx_log("load text resource...")
  local is_64bit_process = nx_function("ext_is_64bit_process")
  gui.TextManager.UseResProcess = not is_64bit_process and get_use_res_process() and game_config.res_process
  local lang_path = nx_execute("util_functions", "get_language_path")
  gui.TextManager:LoadFiles(lang_path)
  local IniManager = nx_create("IniManager", nx_resource_path())
  nx_set_value("IniManager", IniManager)
  IniManager.UseResProcess = not is_64bit_process and get_use_res_process() and game_config.res_process
  local custom_mgr = nx_create("CustomizingManager")
  nx_set_value("customizing_manager", custom_mgr)
  sock = nx_create("GameWinSock")
  sock.ready = false
  nx_set_value("game_sock", sock)
  local text_sock = nx_create("TextSock")
  nx_set_value("text_sock", text_sock)
  nx_bind_script(text_sock, "game_textsock", "game_textsock_init")
  local game_client = nx_create("GameClient")
  game_client.ready = false
  nx_set_value("game_client", game_client)
  local game_visual = nx_create("GameVisual")
  nx_set_value("game_visual", game_visual)
  local game_speaker = nx_create("Speaker")
  nx_set_value("Speaker", game_speaker)
  local xml_manager = nx_create("XMLManager", "")
  nx_set_value("XMLManager", xml_manager)
  local ini = get_ini("ini\\res_ver.ini")
  if nx_is_valid(ini) then
    local sect_index = ini:FindSectionIndex("switch")
    if 0 <= sect_index then
      local res_val = ini:ReadString(sect_index, "WordChangeLine", "0")
      gui.WordChangeLine = res_val == "1"
      res_val = ini:ReadString(sect_index, "LimitWidth", "0")
      gui.LimitWidth = res_val == "1"
      res_val = ini:ReadString(sect_index, "LblLimitWidth", "0")
      gui.LblLimitWidth = res_val == "1"
      gui.BtnVoidRatio = ini:ReadFloat(sect_index, "BtnVoidRatio", 0)
      gui.CheckBtnVoidRatio = ini:ReadFloat(sect_index, "CheckBtnVoidRatio", 0)
      gui.GuildNameOrder = 1 - ini:ReadInteger(sect_index, "IsLeftToRight", 0)
      res_val = ini:ReadString(sect_index, "GUI_InputFilter", "0")
      gui.InputFilter = res_val == "1"
      if gui.InputFilter then
        local region_begin = ini:ReadFloat(sect_index, "GUI_Region_begin", 0)
        local region_end = ini:ReadFloat(sect_index, "GUI_Region_end", 0)
        gui:SetRegion(region_begin, region_end)
      end
    end
  end
  local scene_creator = nx_create("SceneCreator")
  if nx_is_valid(scene_creator) then
    nx_set_value("SceneCreator", scene_creator)
  end
  local short_keys = nx_create("ShortcutKey", nx_resource_path())
  nx_set_value("ShortcutKey", short_keys)
  local game_shortcut = nx_create("GameShortcut")
  nx_set_value("GameShortcut", game_shortcut)
  local map_query = nx_create("MapQuery")
  nx_set_value("MapQuery", map_query)
  local form_logic = nx_create("form_main_general_info")
  nx_set_value("form_main_general_info_logic", form_logic)
  local select_logic = nx_create("SelectLogic")
  nx_set_value("SelectLogic", select_logic)
  local action_module = nx_create("Action")
  nx_set_value("action_module", action_module)
  local skill_effect = nx_create("SkillEffect")
  nx_bind_script(skill_effect, "skill_effect", "skill_effect_init")
  nx_set_value("skill_effect", skill_effect)
  local global_effect = nx_create("CGlobalEffectMgr")
  nx_set_value("global_effect", global_effect)
  local fight = nx_create("Fight")
  nx_set_value("fight", fight)
  local qinggong = nx_create("QingGong")
  nx_set_value("qinggong", qinggong)
  local send_move = nx_create("SendMove")
  nx_set_value("send_move", send_move)
  local tiguan_manager = nx_create("TiGuanManager")
  nx_set_value("tiguan_manager", tiguan_manager)
  local tiguan_border = nx_create("TiGuanBorderManager")
  nx_set_value("tiguan_border", tiguan_border)
  local attribute_mall_manager = nx_create("AttributeMallManager")
  nx_set_value("AttributeMallManager", attribute_mall_manager)
  local cross_server_manager = nx_create("CrossServerManager")
  nx_set_value("CrossServerManager", cross_server_manager)
  local skill_data_manager = nx_create("SkillDataManager")
  nx_set_value("skill_data_manager", skill_data_manager)
  local leitai_reward_manager = nx_create("LeiTaiRewardManager")
  nx_set_value("leitai_reward_manager", leitai_reward_manager)
  local mutual_action = nx_create("MutualAction")
  nx_set_value("mutual_action", mutual_action)
  local attire_manager = nx_create("AttireManager")
  nx_set_value("attire_manager", attire_manager)
  local mouse_control = nx_create("MouseControl")
  nx_set_value("MouseControl", mouse_control)
  local binglu_manager = nx_create("BingLuManager")
  nx_set_value("binglu_manager", binglu_manager)
  local exchange_item_manager = nx_create("ExchangeItemManager")
  nx_set_value("exchange_item_manager", exchange_item_manager)
  local kui_hua_bao_dian_chat = nx_create("KuiHuaBaoDianChat", nx_resource_path())
  nx_set_value("kui_hua_bao_dian_chat", kui_hua_bao_dian_chat)
  local timer_game = nx_create("Timer")
  nx_set_value(GAME_TIMER, timer_game)
  local damage_statistics = nx_create("CDamageStatistics")
  nx_set_value("damage_statistics", damage_statistics)
  local form_plate_award = nx_create("form_plate_award")
  nx_set_value("form_plate_award_logic", form_plate_award)
  local common_execute = nx_create("CommonExecute")
  nx_set_value("common_execute", common_execute)
  local common_array = nx_create("CommonArray")
  nx_set_value("common_array", common_array)
  local scene_music_play_manager = nx_create("SceneMusicPlay")
  nx_set_value("scene_music_play_manager", scene_music_play_manager)
  if nx_is_valid(scene_music_play_manager) then
    nx_bind_script(scene_music_play_manager, "scene_music_play_manager", "init")
    scene_music_play_manager:SetMusicEnable(game_config.music_enable)
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
  local sprite_manager = nx_create("SpriteManager")
  nx_set_value("SpriteManager", sprite_manager)
  local path_finding = nx_create("Trace", nx_resource_path() .. "map\\path\\")
  nx_set_value("path_finding", path_finding)
  local item_query = nx_create("ItemsQuery", nx_resource_path() .. "share\\")
  item_query.Text = gui.TextManager
  nx_set_value("ItemQuery", item_query)
  local AchievementManager = nx_create("AchievementManager", nx_resource_path() .. "share\\")
  AchievementManager.Text = gui.TextManager
  nx_set_value("AchievementManager", AchievementManager)
  local condition_manager = nx_create("ConditionManager", nx_resource_path() .. "share\\")
  nx_set_value("ConditionManager", condition_manager)
  local daily_lp_manager = nx_create("DailyLPManager")
  nx_set_value("DailyLPManager", daily_lp_manager)
  local guild_fire_Mgr = nx_create("GuildFireManager")
  nx_set_value("GuildFireManager", guild_fire_Mgr)
  local origin_manager = nx_create("OriginManager")
  nx_set_value("OriginManager", origin_manager)
  local upgrade_rule_manager = nx_create("UpgradeRuleManager", nx_resource_path() .. "share\\")
  nx_set_value("UpgradeRuleManager", upgrade_rule_manager)
  local offline_job_manager = nx_create("OffLineJobManager", nx_resource_path() .. "share\\")
  nx_set_value("OffLineJobManager", offline_job_manager)
  local http_client = nx_create("GenericHTTPClient")
  if nx_is_valid(http_client) then
    nx_set_value("GenericHTTPClient", http_client)
  end
  local curl_logic = nx_create("CurlLogic")
  if nx_is_valid(curl_logic) then
    nx_set_value("CurlLogic", curl_logic)
  end
  local KarmaMgr = nx_create("Karma", nx_resource_path() .. "share\\")
  nx_set_value("Karma", KarmaMgr)
  local sns_manager = nx_create("SnsManager", nx_resource_path() .. "share\\")
  nx_set_value("sns_manager", sns_manager)
  local npc_sence_query = nx_create("NpcSenceQuery", nx_resource_path() .. "ini\\suggest\\")
  nx_set_value("NpcSenceQuery", npc_sence_query)
  local sys_info_sort = nx_create("SysInfoSort", nx_resource_path() .. "ini\\")
  nx_set_value("SysInfoSort", sys_info_sort)
  local client_npc_manager = nx_create("ClientNpcManager")
  nx_bind_script(client_npc_manager, "client_npc_manager", "init")
  nx_set_value("client_npc_manager", client_npc_manager)
  local scenario_npc_manager = nx_create("ScenarioNpcManager")
  nx_bind_script(scenario_npc_manager, "scenario_npc_manager", "init")
  nx_set_value("scenario_npc_manager", scenario_npc_manager)
  local HomeManager = nx_create("HomeManager")
  nx_set_value("HomeManager", HomeManager)
  local HomeNpcMod = nx_create("HomeNpcMod")
  nx_set_value("HomeNpcMod", HomeNpcMod)
  local HomeWeaponNpc = nx_create("HomeWeaponHangerNpc")
  nx_set_value("HomeWeaponHangerNpc", HomeWeaponNpc)
  local npc_head_talk_manager = nx_create("NpcHeadTalkManager", nx_resource_path() .. "ini\\")
  if nx_is_valid(npc_head_talk_manager) then
    nx_bind_script(npc_head_talk_manager, "npc_head_talk_manager", "init")
    nx_set_value("npc_head_talk_manager", npc_head_talk_manager)
  end
  local task_manager = nx_create("TaskManager", nx_resource_path() .. "share\\")
  nx_set_value("TaskManager", task_manager)
  local switch_manager = nx_create("SwitchManager")
  nx_set_value("SwitchManager", switch_manager)
  local team_manager = nx_value("team_manager")
  if not nx_is_valid(team_manager) then
    team_manager = nx_create("TeamManager")
    nx_set_value("team_manager", team_manager)
  end
  local repute_module = nx_create("ReputeModule", nx_resource_path() .. "share\\")
  nx_set_value("ReputeModule", repute_module)
  local optiontalk_manager = nx_create("OptionTalk", nx_resource_path() .. "share\\")
  nx_set_value("OptionTalk", optiontalk_manager)
  local connectgame = nx_create("ConnectGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("ConnectGame", connectgame)
  local forgegame = nx_create("ForgeGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("ForgeGame", forgegame)
  local findpicgame = nx_create("FindpicGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("FindpicGame", findpicgame)
  local qingame = nx_create("QinGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("QinGame", qingame)
  local picturegame = nx_create("PictureGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("PictureGame", picturegame)
  local handwritinggame = nx_create("HandwritingGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("HandwritingGame", handwritinggame)
  local rpsgame = nx_create("RockPaperScissorsGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("RockPaperScissorsGame", rpsgame)
  local jingmaigame = nx_create("JingmaiGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("JingmaiGame", jingmaigame)
  local RideGame = nx_create("RideGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("RideGame", RideGame)
  local RopeSwingGame = nx_create("RopeSwingGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("RopeSwingGame", RopeSwingGame)
  local weiqigame = nx_create("WeiqiGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("WeiqiGame", weiqigame)
  local fortunetellinggame = nx_create("FortuneTellingGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("FortuneTellingGame", fortunetellinggame)
  local augurgame = nx_create("AugurGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("AugurGame", augurgame)
  local jigsawgame = nx_create("JigsawGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("JigsawGame", jigsawgame)
  local pichaigame = nx_create("PichaiGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("PichaiGame", pichaigame)
  local sudokugame = nx_create("SudokuGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("SudokuGame", sudokugame)
  local rollgame = nx_create("RollGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("RollGame", rollgame)
  local wqgame = nx_create("WqGame", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("WqGame", wqgame)
  local gnugo = nx_create("CGnugo", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("CGnugo", gnugo)
  local minigame = nx_create("MiniGameManage", nx_resource_path() .. "share\\MiniGame")
  nx_set_value("MiniGameManage", minigame)
  local check_words = nx_create("CheckWords", nx_resource_path() .. "ini\\")
  nx_set_value("CheckWords", check_words)
  local fuse_formula_query = nx_create("FuseFormulaQuery", nx_resource_path() .. "share\\Item")
  nx_set_value("FuseFormulaQuery", fuse_formula_query)
  local public_bord = nx_create("PublicBord")
  nx_set_value("PublicBord", public_bord)
  local data_query_manager = nx_create("StaticDataQueryModule")
  nx_set_value("data_query_manager", data_query_manager)
  local query_util = nx_create("QueryUtil")
  nx_set_value("QueryUtil", query_util)
  local taolu_query = nx_create("TaoLuQuery")
  nx_set_value("TaoLuQuery", taolu_query)
  local LogicVmChecker = nx_create("LogicVmChecker")
  nx_set_value("LogicVmChecker", LogicVmChecker)
  local MotionVmChecker = nx_create("MotionVmChecker")
  nx_set_value("MotionVmChecker", MotionVmChecker)
  local skill_query = nx_create("SkillQuery")
  nx_set_value("SkillQuery", skill_query)
  local skill_limit = nx_create("SkillLimit")
  nx_set_value("SkillLimit", skill_limit)
  local wuxue_query = nx_create("WuXueQuery")
  nx_set_value("WuXueQuery", wuxue_query)
  local CommonFunc = nx_create("CommonFunc")
  nx_set_value("common_func", CommonFunc)
  local MotionFunc = nx_create("MotionFunc")
  nx_set_value("motion_func", MotionFunc)
  local jingmai_query = nx_create("JingMaiQuery")
  nx_set_value("JingMaiQuery", jingmai_query)
  local tips_manager = nx_create("TipsManager")
  nx_set_value("tips_manager", tips_manager)
  local HeadGame = nx_create("HeadGame")
  nx_set_value("HeadGame", HeadGame)
  local SkillImmunityLocked = nx_create("SkillImmunityLocked")
  nx_set_value("SkillImmunityLocked", SkillImmunityLocked)
  local guildbuilding_Manager = nx_create("GuildbuildingManager")
  nx_set_value("GuildbuildingManager", guildbuilding_Manager)
  local guildjiguan_Manager = nx_create("GuildJiGuanManager")
  nx_set_value("GuildJiGuanManager", guildjiguan_Manager)
  local pre_create_manager = nx_create("GuildBuildingPreCreate")
  nx_set_value("GuildPreCreateManager", pre_create_manager)
  local marry_decorate_create = nx_create("MarryDecorateNpcCreate")
  nx_set_value("MarryDecorateNpcCreate", marry_decorate_create)
  local light_npc_create = nx_create("LightNpcCreate")
  nx_set_value("LightNpcCreate", light_npc_create)
  local GoodsGrid = nx_create("GoodsGrid")
  nx_set_value("GoodsGrid", GoodsGrid)
  local jewel_game_manager = nx_create("JewelGameManager")
  nx_set_value("jewel_game_manager", jewel_game_manager)
  local faculty_query = nx_create("FacultyQuery")
  nx_set_value("faculty_query", faculty_query)
  local CountLimitManager = nx_create("CountLimitManager")
  nx_set_value("CountLimitManager", CountLimitManager)
  local MessageDelay = nx_create("MessageDelay")
  nx_set_value("MessageDelay", MessageDelay)
  local WeatherTimeManager = nx_create("WeatherTimeManager")
  if nx_is_valid(WeatherTimeManager) then
    nx_set_value("WeatherTimeManager", WeatherTimeManager)
  end
  local weather_manager = nx_create("WeatherManager")
  nx_set_value("weather_manager", weather_manager)
  local weather_wrapper = nx_create("WeatherWrapper")
  if nx_is_valid(weather_wrapper) then
    nx_set_value("WeatherWrapper", weather_wrapper)
  end
  local vip_module = nx_create("VipModule")
  nx_set_value("VipModule", vip_module)
  local guilddomain_Manager = nx_create("GuildDomainManager")
  nx_set_value("GuildDomainManager", guilddomain_Manager)
  local follow_motion = nx_create("FollowManager")
  nx_set_value("FollowManager", follow_motion)
  local taohuadao_Manager = nx_create("TaohuadaoManager")
  nx_set_value("TaohuadaoManager", taohuadao_Manager)
  local playertrackinfo = nx_create("PlayerTrackModule")
  if nx_is_valid(playertrackinfo) then
    nx_set_value("PlayerTrackModule", playertrackinfo)
  end
  local JianghuExploreModule = nx_create("JianghuExploreModule")
  nx_set_value("JianghuExploreModule", JianghuExploreModule)
  local drivenpc = nx_create("DriveNpcMgr")
  nx_set_value("DriveNpcMgr", drivenpc)
  local home_share_furn = nx_create("HomeShareFurnitureNpc")
  if nx_is_valid(home_share_furn) then
    nx_set_value("HomeShareFurnitureNpc", home_share_furn)
  end
  home_share_furn = nx_create("BodyManager")
  if nx_is_valid(home_share_furn) then
    nx_set_value("body_manager", home_share_furn)
  end
  local game_joystick = nx_create("GameJoyStick")
  if nx_is_valid(game_joystick) then
    nx_set_value("game_joystick", game_joystick)
  else
    nx_msgbox(get_msg_str("msg_432"))
  end
  local capital_module = nx_create("CapitalModule")
  if nx_is_valid(capital_module) then
    capital_module:Load()
    nx_set_value("CapitalModule", capital_module)
  end
  create_scene("game_scene")
  local game_scene = nx_value("game_scene")
  game_scene.BackColor = "0,0,0,0"
  game_scene.ClearZBuffer = false
  game_scene.EnableRealizeRefraction = true
  game_scene.EnableRealizeTempRT = true
  game_scene.EnableEarlyZ = true
  if dev_caps.SupportIntZDepth then
    game_scene.EnableRealizeVolumeFog = true
  end
  world.MainScene = game_scene
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, world.MainScene)
  end
  local role_composite = nx_create("RoleComposite")
  if nx_is_valid(role_composite) then
    nx_bind_script(role_composite, "role_composite", "init")
    role_composite.GameClient = game_client
    role_composite.GameVisual = game_visual
    nx_set_value("role_composite", role_composite)
  end
  local road_sign_npc_manager = nx_create("RoadSignNpcManager")
  nx_set_value("RoadSignNpcManager", road_sign_npc_manager)
  local trans_tool_npc_manager = nx_create("TransToolNpcManager")
  nx_set_value("TransToolNpcManager", trans_tool_npc_manager)
  local fall_down_manager = nx_create("FallDownManager")
  nx_set_value("FallDownManager", fall_down_manager)
  local npc_pre_load = nx_create("NpcPreLoad")
  if nx_is_valid(npc_pre_load) then
    nx_set_value("NpcPreLoad", npc_pre_load)
  end
  local scene_obj = nx_create("SceneObj")
  if nx_is_valid(scene_obj) then
    scene_obj.GameClient = game_client
    scene_obj.GameVisual = game_visual
    scene_obj.RoleComposite = role_composite
    scene_obj.GameControl = nx_null()
    scene_obj.ShadowManager = nx_null()
    nx_set_value("scene_obj", scene_obj)
  end
  local buffer_effect = nx_create("BufferEffect")
  if nx_is_valid(buffer_effect) then
    nx_set_value("BufferEffect", buffer_effect)
  end
  local chess_npc_manager = nx_create("ChessNpcManager")
  if nx_is_valid(chess_npc_manager) then
    nx_set_value("ChessNpcManager", chess_npc_manager)
  end
  local MovieSaver_module = nx_create("MovieSaverModule")
  if nx_is_valid(MovieSaver_module) then
    nx_set_value("MovieSaverModule", MovieSaver_module)
  end
  local game_select_decal = nx_create("GameSelectDecal")
  if nx_is_valid(game_select_decal) then
    nx_set_value("GameSelectDecal", game_select_decal)
  end
  local player_bind_manager = nx_create("PlayerBindMgr")
  if nx_is_valid(player_bind_manager) then
    nx_set_value("PlayerBindMgr", player_bind_manager)
  end
  local qg_bind_manager = nx_create("QingGongBind")
  if nx_is_valid(qg_bind_manager) then
    nx_set_value("QingGongBind", qg_bind_manager)
  end
  local ClientDataFetch = nx_create("ClientDataFetch")
  if nx_is_valid(ClientDataFetch) then
    nx_set_value("ClientDataFetch", ClientDataFetch)
  end
  local CollectCardManager = nx_create("CollectCardManager")
  if nx_is_valid(CollectCardManager) then
    nx_set_value("CollectCardManager", CollectCardManager)
  end
  local ActivityManager = nx_create("ActivityManager")
  if nx_is_valid(ActivityManager) then
    nx_set_value("ActivityManager", ActivityManager)
  end
  local SeekMineManager = nx_create("SeekMineManager")
  if nx_is_valid(SeekMineManager) then
    nx_set_value("SeekMineManager", SeekMineManager)
  end
  local GuildWarManager = nx_create("GuildWarManager")
  if nx_is_valid(GuildWarManager) then
    nx_set_value("GuildWarManager", GuildWarManager)
  end
  local EscortNpcManager = nx_create("EscortNpcManager")
  if nx_is_valid(EscortNpcManager) then
    nx_set_value("EscortNpcManager", EscortNpcManager)
  end
  local freshman_helper_mgr = nx_create("FreshmanHelperManager")
  nx_set_value("freshman_helper_mgr", freshman_helper_mgr)
  local MarryNpcManager = nx_create("MarryNpcManager")
  if nx_is_valid(MarryNpcManager) then
    nx_set_value("MarryNpcManager", MarryNpcManager)
  end
  local WorldWarManager = nx_create("WorldWarManager")
  if nx_is_valid(WorldWarManager) then
    nx_set_value("WorldWarManager", WorldWarManager)
  end
  local form_main_buff = nx_create("form_main_buff")
  nx_set_value("form_main_buff", form_main_buff)
  local select_buff_refresh = nx_create("select_buff_refresh")
  nx_set_value("select_buff_refresh", select_buff_refresh)
  local Kapai = nx_create("Kapai")
  if nx_is_valid(Kapai) then
    nx_set_value("Kapai", Kapai)
  end
  local Pet = nx_create("Pet")
  if nx_is_valid(Pet) then
    nx_set_value("Pet", Pet)
  end
  MarryShop = nx_create("MarryShop")
  if nx_is_valid(MarryShop) then
    nx_set_value("MarryShop", MarryShop)
  end
  local SnsWorldShape = nx_create("SnsWorldShape")
  if nx_is_valid(SnsWorldShape) then
    nx_set_value("SnsWorldShape", SnsWorldShape)
  end
  local form_bag_logic = nx_create("form_bag")
  nx_set_value("form_bag_logic", form_bag_logic)
  local GuildManager = nx_create("GuildManager")
  if nx_is_valid(GuildManager) then
    nx_set_value("GuildManager", GuildManager)
  end
  local EgWarModule = nx_create("EgWarModule")
  if nx_is_valid(EgWarModule) then
    nx_set_value("EgWarModule", EgWarModule)
  end
  local PaijiuGame = nx_create("PaijiuGame")
  if nx_is_valid(PaijiuGame) then
    nx_set_value("PaijiuGame", PaijiuGame)
  end
  local LockpickGame = nx_create("LockpickGame")
  if nx_is_valid(LockpickGame) then
    nx_set_value("LockpickGame", LockpickGame)
  end
  local CLFRollGame = nx_create("CLFRollGame")
  if nx_is_valid(CLFRollGame) then
    nx_set_value("CLFRollGame", CLFRollGame)
  end
  DynamicCloneHelperCreate()
  nx_call("gui", "init_money_FormatText", gui)
  local game_name = nx_widestr(util_text("ui_GameName")) .. nx_widestr("  ") .. nx_widestr(game_config.server_name)
  nx_function("ext_set_window_title", game_name)
  local checkads = nx_create("CheckAds")
  if nx_is_valid(checkads) then
    nx_set_value("checkads", checkads)
  end
  local LogicVmChecker = nx_value("LogicVmChecker")
  if nx_is_valid(LogicVmChecker) then
    LogicVmChecker:SetWinTile(game_name)
  end
  local voice_manager = nx_create("CVoiceManager")
  if nx_is_valid(voice_manager) then
    nx_set_value("voice_manager", voice_manager)
  end
  local form_recast_attribute = nx_create("form_recast_attribute")
  if nx_is_valid(form_recast_attribute) then
    nx_set_value("form_recast_attribute", form_recast_attribute)
  end
  local dbomall_manager = nx_create("DboMallManager")
  if nx_is_valid(dbomall_manager) then
    nx_set_value("dbomall_manager", dbomall_manager)
  end
  local LotterManager = nx_create("LotterManager")
  if nx_is_valid(LotterManager) then
    nx_set_value("LotterManager", LotterManager)
  end
  local GuildCrossWarManager = nx_create("GuildCrossWarManager")
  if nx_is_valid(GuildCrossWarManager) then
    nx_set_value("GuildCrossWarManager", GuildCrossWarManager)
  end
  local WuXueCanWuManager = nx_create("WuXueCanWuManager")
  if nx_is_valid(WuXueCanWuManager) then
    nx_set_value("WuXueCanWuManager", WuXueCanWuManager)
  end
  init_entity()
  nx_log("preload game resource..")
  nx_execute("game_preload", "game_preload_load")
  nx_log("load action resource...")
  action_module:LoadResource()
  nx_log("load sprite manager resource...")
  sprite_manager:LoadResource()
  nx_log("load skill effect resource...")
  skill_effect:LoadResource()
  nx_log("load role composite resource...")
  role_composite:LoadResource()
  nx_log("load jewel game resource...")
  jewel_game_manager:LoadResource()
  wuxue_query:LoadResource()
  nx_log("load item query resource...")
  item_query:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load condition manager resource...")
  condition_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load upgrade rule manager resource...")
  upgrade_rule_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load offline job manager resource...")
  offline_job_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load karma manager resource...")
  KarmaMgr:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load sns manager resource...")
  sns_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load npc scene query resource...")
  npc_sence_query:LoadResource(nx_resource_path() .. "ini\\suggest\\")
  nx_log("load sys info sort resource...")
  sys_info_sort:LoadResource(nx_resource_path() .. "ini\\")
  nx_log("load data query manager resource...")
  data_query_manager:LoadResource()
  nx_log("load npc head talk manager resource...")
  npc_head_talk_manager:LoadResource(nx_resource_path() .. "ini\\")
  nx_log("load task manager resource...")
  task_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load repute module resource...")
  repute_module:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load switch module resource...")
  switch_manager:LoadResource()
  nx_log("load optiontalk module resource...")
  optiontalk_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load check words resource...")
  check_words:LoadResource(nx_resource_path() .. "ini\\")
  nx_log("load road sign npc resource...")
  road_sign_npc_manager:LoadResource()
  nx_log("load faculty query resource...")
  faculty_query:LoadResource(nx_resource_path() .. "ini\\")
  nx_log("load origin manager resource...")
  origin_manager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load forge game resource...")
  forgegame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load find picture game resource...")
  findpicgame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load qingame resource...")
  qingame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load picture game resource...")
  picturegame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load hand writing game resource...")
  handwritinggame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load ride game resource...")
  RideGame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load rope swing game resource ...")
  RopeSwingGame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load fortune telling resource...")
  fortunetellinggame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load trans tool npc resource...")
  trans_tool_npc_manager:LoadResource()
  nx_log("load pichaigame resource...")
  pichaigame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load taolu query resource...")
  taolu_query:LoadResource(nx_resource_path() .. "ini\\ui\\wuxue\\wuxue_zhaoshi.ini")
  nx_log("load skill query resource...")
  skill_query:LoadResource(nx_resource_path() .. "share\\Skill\\skill_use_limit.ini")
  nx_log("load jingmai query resource...")
  jingmai_query:LoadResource(nx_resource_path() .. "ini\\ui\\wuxue\\wuxue_jingmai.ini")
  nx_log("load tips_manager resource...")
  tips_manager:LoadResource()
  nx_log("load HeadGame resource...")
  HeadGame:LoadResource()
  nx_log("load weiqi game resource...")
  weiqigame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load goods grid resource...")
  GoodsGrid:LoadEquipPositonInfo(nx_resource_path() .. "ini\\equipbox.ini")
  GoodsGrid:LoadJobItemImageInfo(nx_resource_path() .. "ini\\job_item_image.ini")
  nx_log("load guild building resource...")
  guildbuilding_Manager:LoadResource(nx_resource_path() .. "share\\Guild\\GuildBuilding\\guild_building_upgrade_info.ini")
  guildbuilding_Manager:LoadRevertResource(nx_resource_path() .. "share\\Guild\\GuildBuilding\\guild_building_revert_info.ini")
  guildbuilding_Manager:LoadKengWeiRes(nx_resource_path() .. "share\\Guild\\GuildBuilding\\")
  guildbuilding_Manager:LoadAreaDivideInfo(nx_resource_path() .. "share\\Guild\\GuildBuilding\\gb_area_divide.ini")
  guildbuilding_Manager:LoadUpgradeItemInfo(nx_resource_path() .. "share\\Guild\\GuildBuilding\\gb_skin_change.ini")
  guildbuilding_Manager:LoadNewUpgradeBuildingInfo(nx_resource_path() .. "share\\Guild\\GuildBuilding\\new_gb_skin_change_building.ini")
  guildbuilding_Manager:LoadNewUpgradeItemInfo(nx_resource_path() .. "share\\Guild\\GuildBuilding\\new_gb_skin_change.ini")
  guildbuilding_Manager:LoadYanWuTangRes(nx_resource_path() .. "share\\Guild\\GuildBuilding\\")
  guildbuilding_Manager:LoadUpgradeDrawingsRes(nx_resource_path() .. "share\\Guild\\GuildBuilding\\guild_drawings_upgrade_info.ini")
  guildbuilding_Manager:LoadRes(nx_resource_path() .. "share\\Guild\\")
  nx_log("load guild jiguan resource...")
  guildjiguan_Manager:LoadRemoveInfo(nx_resource_path() .. "share\\Guild\\GuildFuncNpc\\")
  guildjiguan_Manager:LoadPosInfo(nx_resource_path() .. "share\\Guild\\GuildFuncNpc\\")
  nx_log("load guild domain resource...")
  guilddomain_Manager:LoadRemoveInfo(nx_resource_path() .. "share\\Guild\\GuildDomain\\")
  guilddomain_Manager:LoadBuildingInfo(nx_resource_path() .. "share\\Guild\\GuildDomain\\")
  guilddomain_Manager:LoadDomainInfo(nx_resource_path() .. "share\\Guild\\GuildDomain\\")
  guilddomain_Manager:LoadDomainStateInfo(nx_resource_path() .. "share\\Guild\\GuildBuilding\\")
  nx_log("load guild resource...")
  GuildManager:LoadResource(nx_resource_path() .. "share\\Guild\\")
  nx_log("load daily_lp_manager resource...")
  daily_lp_manager:LoadResource()
  nx_log("load guild_fire_Mgr resource...")
  guild_fire_Mgr:LoadResource()
  nx_log("load chess_npc_manager resource...")
  chess_npc_manager:LoadResource()
  nx_log("load freshman_helper_mgr resource...")
  freshman_helper_mgr:LoadResource()
  nx_log("load resource ended")
  CollectCardManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load resource ended")
  fuse_formula_query:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load FuseFormulaQuery resource ended")
  Kapai:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load Kapai resource ended")
  nx_log("load pet resource...")
  Pet:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load pet resource ended..")
  WorldWarManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load WorldWarManager resource ended")
  CountLimitManager:LoadResource()
  nx_log("load CountLimit resource ended")
  LoadDynamicCloneHelperResource()
  MarryNpcManager:LoadResource()
  nx_log("load MarryNpcManager resource ended")
  check_words:LoadFilterRegion()
  nx_log("load FilterRegion resource ended")
  nx_log("load JianghuExploreModulemodule resource...")
  JianghuExploreModule:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load JianghuExploreModuleresource ended")
  form_recast_attribute:LoadEquipResouce()
  form_recast_attribute:LoadWeaponResouce()
  form_recast_attribute:LoadCostResouce()
  nx_log("load form_recast_attribute resource ended")
  nx_log("load LockpickGame resource...")
  LockpickGame:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load LockpickGame ended")
  nx_log("load LockpickCommonGame resource...")
  local LockpickCommonGame = nx_value("LockpickCommonGame")
  if nx_is_valid(LockpickCommonGame) then
    LockpickCommonGame:LoadRes(nx_resource_path() .. "share\\")
  end
  nx_log("load LockpickCommonGame ended")
  nx_log("load GuildWarManager resource...")
  GuildWarManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load GuildWarManager ended")
  nx_log("load LotterManager resource...")
  LotterManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load LotterManager ended")
  nx_log("load GuildCrossWarManager resource...")
  GuildCrossWarManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load GuildCrossWarManager ended")
  nx_log("load WuXueCanWuManager resource...")
  WuXueCanWuManager:LoadResource(nx_resource_path() .. "share\\")
  nx_log("load WuXueCanWuManager ended")
  local mgr = nx_create("InteractManager")
  if nx_is_valid(mgr) then
    nx_set_value("InteractManager", mgr)
  end
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    controlwatch = nx_create("GameControlWatch")
    nx_set_value("ControlWatch", controlwatch)
  end
  world:ClearWorkingSet()
  if nx_function("ext_is_instance_overflow") then
    wait_user_exit_game()
    return 0
  end
  local GameInfoCollector = nx_value("GameInfoCollector")
  if not nx_is_valid(GameInfoCollector) then
  end
  GTP_set_collector_time(GTP_LUA_FUNC_LOAD_RESOURCE, false, false)
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_LOAD_RESOURCE, true)
  nx_log("entry login...")
  nx_execute("stage", "set_current_stage", "login")
  gui:CheckClientSize()
  nx_function("ext_check_window_pos")
  return 1
end
function confirm_exit_game()
  local form = nx_value("exit_game" .. "_form_confirm")
  if nx_is_valid(form) then
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_game")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_SureToExitGame"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "exit_game_confirm_return")
  if res == "cancel" then
    return false
  elseif res == "ok" then
    direct_exit_game()
    return true
  end
end
function wait_exit_game()
  GTP_set_collector_time(GTP_LUA_FUNC_EXIT, false, true)
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_EXIT)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_game")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_format_string("ui_waittoexitgame", nx_int(30)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.ok_btn.Text = nx_widestr(util_text("ui_xiaxian"))
  dialog.cancel_btn.Text = nx_widestr(util_text("ui_fanhui"))
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("WaitExitGame", dialog, 1, nx_int(30))
  end
  local res = nx_wait_event(100000000, dialog, "exit_game_confirm_return")
  if res == "cancel" then
    if nx_is_valid(common_execute) then
      common_execute:RemoveExecute("WaitExitGame", dialog)
    end
    return false
  elseif res == "ok" then
    direct_exit_game()
    return true
  end
end
function wait_user_exit_game()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_game")
  if not nx_is_valid(dialog) then
    direct_exit_game()
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_too_many_ins"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.cancel_btn.Visible = false
  nx_wait_event(100000000, dialog, "exit_game_confirm_return")
  direct_exit_game()
end
function gtp_wait_user_exit_game()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "exit_game")
  if not nx_is_valid(dialog) then
    direct_exit_game()
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_file_failed"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.cancel_btn.Visible = false
  nx_wait_event(100000000, dialog, "exit_game_confirm_return")
  direct_exit_game()
end
function exit_game()
  local world = nx_value("world")
  local scene = world.MainScene
  local gui = nx_value("gui")
  local stage_main_flag = nx_value("stage_main")
  if stage_main_flag == nx_string("success") then
    local form = nx_value("breakconnect_form_confirm")
    if nx_is_valid(form) and form.Visible then
      confirm_exit_game()
      return
    end
    nx_execute("form_stage_main\\form_offline\\form_offline", "open_form_offline")
  else
    confirm_exit_game()
  end
end
local table_module = {
  "control_camera",
  "data_binder",
  "func_manager",
  "timer_game",
  "path_finding",
  "scene_obj",
  "NpcPreLoad",
  "FallDownManager",
  "TransToolNpcManager",
  "RoadSignNpcManager",
  "role_composite",
  "GuildDomainManager",
  "MessageDelay",
  "jewel_game_manager",
  "GoodsGrid",
  "GuildPreCreateManager",
  "GuildJiGuanManager",
  "GuildbuildingManager",
  "JingMaiQuery",
  "TaoLuQuery",
  "data_query_manager",
  "PublicBord",
  "CheckWords",
  "MiniGameManage",
  "SudokuGame",
  "PichaiGame",
  "JigsawGame",
  "AugurGame",
  "FortuneTellingGame",
  "WeiqiGame",
  "RideGame",
  "RopeSwingGame",
  "HandwritingGame",
  "RockPaperScissorsGame",
  "PictureGame",
  "QinGame",
  "FindpicGame",
  "ForgeGame",
  "ConnectGame",
  "faculty_query",
  "TaskManager",
  "SwitchManager",
  "npc_head_talk_manager",
  "scenario_npc_manager",
  "client_npc_manager",
  "SysInfoSort",
  "NpcSenceQuery",
  "OffLineJobManager",
  "UpgradeRuleManager",
  "OriginManager",
  "ConditionManager",
  "ItemQuery",
  "MouseControl",
  "path_finding",
  "SpriteManager",
  "common_execute",
  "fight",
  "skill_effect",
  "action_module",
  "IniManager",
  "XMLManager",
  "game_msg_handler",
  "BufferEffect",
  "QueryUtil",
  "SkillQuery",
  "WuXueQuery",
  "EffectJingMai",
  "HeadGame",
  "SkillImmunityLocked",
  "tips_manager",
  "SceneCreator",
  "ShortcutKey",
  "MapQuery",
  "GameShortcut",
  "global_effect",
  "qinggong",
  "send_move",
  "tiguan_manager",
  "tiguan_border",
  "skill_data_manager",
  "path_finding",
  "DailyLPManager",
  "GuildFireManager",
  "ReputeModule",
  "RollGame",
  "VipModule",
  "CapitalModule",
  "leitai_reward_manager",
  "mutual_action",
  "attire_manager",
  "binglu_manager",
  "exchange_item_manager",
  "weather_manager",
  "kui_hua_bao_dian_chat",
  "GameSelectDecal",
  "customizing_manager",
  "ClientNpcManager",
  "scenario_npc_manager",
  "game_joystick",
  "data_query_manager",
  "team_manager",
  "AttachManager",
  "form_main_buff",
  "damage_statistics",
  "form_bag_logic",
  "CountLimitManager",
  "form_plate_award_logic",
  "voice_manager",
  "form_recast_attribute",
  "form_main_func_btns",
  "GameShortcut",
  "AOWSteamClient",
  "JianghuExploreModule",
  "HomeManager",
  "HomeNpcMod",
  "HomeWeaponHangerNpc",
  "HomeShareFurniture",
  "body_manager",
  "GameInfoCollector"
}
function direct_exit_game()
  local bnExist = nx_file_exists(nx_work_path() .. "Lua\\Main.lua")
  if bnExist == true then
    local plugsys = nx_value("PlugSys")
    if nx_is_valid(plugsys) then
      plugsys:OnBeforeExitGame()
    end
  end
  if nx_running("stage_main", "entry_stage_main") then
    nx_kill("stage_main", "entry_stage_main")
  end
  local world = nx_value("world")
  local gui = nx_value("gui")
  local gEffect = nx_value("global_effect")
  if nx_is_valid(gEffect) then
    gEffect:ClearEffects()
  end
  nx_execute("terrain\\weather_set", "delete_weather_data")
  local weather_wrapper = nx_value("WeatherWrapper")
  if nx_is_valid(weather_wrapper) then
    nx_destroy(weather_wrapper)
  end
  nx_execute("game_preload", "game_preload_clear")
  nx_execute("form_stage_main\\form_main\\form_main_sysinfo", "save_fight_info_tofile")
  nx_call("game_config", "save_game_config", nx_value("game_config"), "system_set.ini", "main")
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "Save_movie_config", true)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "save_fog_info")
  local drama_sel_scene = nx_value("drama_sel_scene")
  if nx_is_valid(drama_sel_scene) then
    nx_call("scene", "delete_scene", drama_sel_scene)
  end
  if nx_is_valid(gui) then
    local screen_width, screen_height = nx_function("ext_get_screen_size")
    local screen_frequency = nx_function("ext_get_cur_system_frequency")
    if nx_find_custom(gui, "old_screen_width") and nx_find_custom(gui, "old_screen_height") and nx_find_custom(gui, "old_screen_frequency") and (gui.old_screen_width ~= screen_width or gui.old_screen_height ~= screen_height or gui.old_screen_frequency ~= screen_frequency) then
      local max_frequency = nx_function("ext_get_max_screen_frequency_bysize", gui.old_screen_width, gui.old_screen_height)
      nx_function("ext_set_screen_size", gui.old_screen_width, gui.old_screen_height, max_frequency)
    end
    nx_destroy(gui)
    world.MainGui = nx_null()
  end
  nx_call("game_preload", "game_form_preload_clear")
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    nx_call("scene", "delete_scene", scene)
  end
  scene = world.MainScene
  if nx_is_valid(scene) then
    nx_call("scene", "delete_scene", scene)
  end
  world.MainScene = nx_null()
  local uisound = nx_value(GAME_UI_SOUND)
  if nx_is_valid(uisound) then
    nx_destroy(uisound)
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:DestroyGameMusic()
    nx_destroy(scene_music_play_manager)
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    local url = switch_manager:GetUrl(URL_TYPE_IE_POP)
    if url ~= "" then
      nx_function("ext_win_exec", "IEpop.exe " .. url)
    end
  end
  local ini_manager = nx_value("IniManager")
  if nx_is_valid(ini_manager) then
    ini_manager:ClearAll()
  end
  nx_function("ext_helper_clear_all")
  local count = table.getn(table_module)
  for i = 1, count do
    local entity = nx_value(table_module[i])
    if not nx_is_valid(entity) or not nx_destroy(entity) then
    end
  end
  local receiver = nx_value("GameReceiver")
  if nx_is_valid(receiver) then
    nx_destroy(receiver)
  end
  local game_sock = nx_value("game_sock")
  if nx_is_valid(game_sock) then
    nx_destroy(game_sock)
  end
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    nx_destroy(game_client)
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    nx_destroy(game_visual)
  end
  world:HideWindow()
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(sdo_login_interface) then
    nx_destroy(sdo_login_interface)
    nx_set_value("SdoLoginInterface", nx_null())
  end
  nx_quit()
  return true
end
function DynamicCloneHelperCreate()
  local DynamicCloneHelper = nx_create("DynamicCloneHelper")
  if nx_is_valid(DynamicCloneHelper) then
    nx_set_value("DynamicCloneHelper", DynamicCloneHelper)
  end
end
function LoadDynamicCloneHelperResource()
  local DynamicCloneHelper = nx_value("DynamicCloneHelper")
  if nx_is_valid(DynamicCloneHelper) then
    nx_log("load dynamic clone resource...")
    DynamicCloneHelper:LoadResource(nx_resource_path() .. "share\\")
    nx_log("load dynamic clone resource ended..")
  end
end
function get_error_msg(str_msg)
  local err_msg = nx_value("ErrorMsg")
  if nx_is_valid(err_msg) then
    local strMsg = err_msg:GetErrMsg(str_msg)
    return nx_string(strMsg)
  end
  return ""
end
function init_entity()
  local home_point_form = nx_create("form_home_point")
  if nx_is_valid(home_point_form) then
    nx_set_value("form_home_point", home_point_form)
  end
  local game1024 = nx_create("Game1024")
  if nx_is_valid(game1024) then
    nx_set_value("Game1024", game1024)
  end
  local redpacket = nx_create("RedPacket")
  if nx_is_valid(redpacket) then
    nx_set_value("RedPacket", redpacket)
  end
  local LockpickCommonGame = nx_create("LockpickCommonGame")
  if nx_is_valid(LockpickCommonGame) then
    nx_set_value("LockpickCommonGame", LockpickCommonGame)
  end
  local WhackEggGame = nx_create("WhackEggGame")
  if nx_is_valid(WhackEggGame) then
    nx_set_value("WhackEggGame", WhackEggGame)
  end
  local SchoolExtinct = nx_create("SchoolExtinct")
  if nx_is_valid(SchoolExtinct) then
    nx_set_value("SchoolExtinct", SchoolExtinct)
  end
  local ShijiaEastZhujianGame = nx_create("ShijiaEastZhujianGame")
  if nx_is_valid(ShijiaEastZhujianGame) then
    nx_set_value("ShijiaEastZhujianGame", ShijiaEastZhujianGame)
  end
  local CoolDownBig = nx_create("CoolDownBig")
  if nx_is_valid(CoolDownBig) then
    nx_set_value("CoolDownBig", CoolDownBig)
  end
  local TaoShaManager = nx_create("TaoShaManager")
  if nx_is_valid(TaoShaManager) then
    nx_set_value("TaoShaManager", TaoShaManager)
  end
  local SJYArmyGame = nx_create("SJYArmyGame")
  if nx_is_valid(SJYArmyGame) then
    nx_set_value("SJYArmyGame", SJYArmyGame)
  end
  local SanHillManager = nx_create("SanHillManager")
  if nx_is_valid(SanHillManager) then
    nx_set_value("SanHillManager", SanHillManager)
  end
  local FiveSkyQuery = nx_create("FiveSkyQuery")
  if nx_is_valid(FiveSkyQuery) then
    nx_set_value("FiveSkyQuery", FiveSkyQuery)
  end
end
