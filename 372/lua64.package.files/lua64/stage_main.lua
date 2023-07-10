require("role_composite")
require("util_functions")
require("define\\camera_mode")
require("define\\fight_operate_mode_define")
require("scene")
require("share\\npc_type_define")
require("define\\object_type_define")
require("define\\request_type")
require("gameinfo_collector")
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
local table_preload_form = {
  "form_stage_main\\form_bag",
  "form_stage_main\\form_task\\form_task_trace",
  "form_stage_main\\form_main\\form_main_face",
  "form_stage_main\\form_talk_movie",
  "form_stage_main\\form_origin\\form_origin_chose",
  "form_stage_main\\form_talk_npc_worldview",
  "form_tips"
}
function entry_stage_main(old_stage)
  console_log("flow entry_stage_main")
  nx_call("game_sock", "reconnect_success")
  local game_select_decal = nx_value("GameSelectDecal")
  if nx_is_valid(game_select_decal) then
    game_select_decal:DeleteSelectDecal()
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  game_client.ready = false
  nx_set_value("loading", true)
  nx_set_value("stage_main", "begin")
  local world = nx_value("world")
  local need_reload_main_form = nx_find_custom(game_client, "need_reload_main_form") and game_client.need_reload_main_form
  local terrain
  if nx_find_custom(world.MainScene, "terrain") then
    terrain = world.MainScene.terrain
  end
  if terrain ~= nil and nx_is_valid(terrain) then
    local role_model = nx_value("role")
    if nx_is_valid(role_model) then
      if nx_is_valid(terrain) then
        terrain:RemoveVisual(role_model)
      end
      local client_ident = game_visual:QueryRoleClientIdent(role_model)
      game_visual:DeleteSceneObj(client_ident, true)
    end
    local scene = world.MainScene
    local vis_list = game_visual:GetSceneObjList()
    for i = 1, table.maxn(vis_list) do
      terrain:RemoveVisual(vis_list[i])
      scene:Delete(vis_list[i])
    end
  end
  move_file_binding_to_account()
  local b_first_intogame = false
  if old_stage ~= "main" or need_reload_main_form then
    console_log("flow begin load form_main")
    game_client.need_reload_main_form = false
    local balls = nx_value("balls")
    if not nx_is_valid(balls) then
      balls = gui:Create("BalloonSet")
      balls.MaxBalloonType = 4
      balls.UseDepthScale = false
      balls.MaxDepthScale = 1
      balls.MinDepthScale = 0.001
      balls.Sort = true
      nx_set_value("balls", balls)
      gui:AddBackControl(balls)
    end
    gui.Desktop:Close()
    gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_main\\form_main\\form_main.xml")
    gui.Desktop.Left = 0
    gui.Desktop.Top = 0
    gui.Desktop.Width = gui.Width
    gui.Desktop.Height = gui.Height
    gui.Desktop.Transparent = true
    gui.Desktop:ShowModal()
    nx_call("game_preload", "game_form_preload_load")
    nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_INTO_GAME)
    b_first_intogame = true
  else
    console_log("flow no load form_main old_stage=" .. old_stage)
  end
  local dialog = nx_value("form_stage_main\\form_close_scene")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  nx_execute("tips_game", "hide_tip")
  nx_execute("tips_game", "hide_link_tips")
  console_log("flow entry_stage_main begin loading")
  local loading_form = nx_execute("util_gui", "util_get_form", "form_common\\form_loading", true, false)
  loading_form.Left = 0
  loading_form.Top = 0
  loading_form.Width = gui.Width
  loading_form.Height = gui.Height
  loading_form:Show()
  if old_stage ~= "main" then
    for i = 1, table.maxn(table_preload_form) do
      local form = nx_call("util_gui", "util_get_form", table_preload_form[i], true, false, "", true)
      form.Visible = false
    end
  end
  local game_scene = nx_value("game_scene")
  nx_execute("form_stage_main\\form_movie_new", "close_movie_form")
  local form_sns = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_sns) then
    form_sns:Close()
  end
  local bExistClone = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_team\\form_team_out_clone")
  if bExistClone then
    local existCloneForm = nx_value("form_stage_main\\form_team\\form_team_out_clone")
    existCloneForm:Close()
  end
  local bExistCloneAward = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_clone_awards")
  if bExistCloneAward then
    local pCloneAwardForm = nx_value("form_stage_main\\form_clone_awards")
    pCloneAwardForm:Close()
  end
  local needcloseform = nx_value("form_stage_main\\form_map\\form_newmap_clearfog")
  if nx_is_valid(needcloseform) then
    needcloseform:Close()
  end
  local form_guild_war_join = nx_value("form_stage_main\\form_guild_war\\form_guild_war_join")
  if nx_is_valid(form_guild_war_join) then
    form_guild_war_join:Close()
  end
  add_main_private_to_scene(game_scene)
  nx_function("ext_log_testor", "load_current_scene begin" .. "\n")
  nx_call("terrain\\weather_set", "delete_weather_data")
  load_current_scene(game_scene)
  nx_function("ext_log_testor", "load_current_scene end" .. "\n")
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetPlayer()
  if nx_is_valid(game_scene.terrain) then
    game_scene.terrain:RemoveVisual(role)
  end
  if nx_is_valid(role) then
    console_log("role not null 7")
  else
    console_log("role is null 7")
  end
  nx_execute("freshman_help", "player_before_entry_scene")
  nx_execute("game_config", "refresh_use_light_map")
  local light_npc_create = nx_value("LightNpcCreate")
  if nx_is_valid(light_npc_create) then
    local client_scene = game_client:GetScene()
    if nx_is_valid(client_scene) then
      local scene_resource = client_scene:QueryProp("Resource")
      light_npc_create:LoadLightNpcXml(scene_resource)
    end
  end
  gui:CheckClientSize()
  local bwolrdwarcenter = nx_execute("form_common\\form_loading", "is_worldwar_center_scene")
  if nx_is_valid(loading_form) then
    if bwolrdwarcenter then
      loading_form.openflag = true
    else
      loading_form.openflag = false
    end
  end
  if nx_is_valid(loading_form) and not loading_form.openflag then
    loading_form:Close()
  end
  console_log("flow entry_stage_main begin loading finish begin open")
  local scene = nx_value("game_scene")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_shortcut")
  local databinder = nx_value("data_binder")
  databinder:RefreshRoleBind()
  if nx_is_valid(role) then
    console_log("role not null 8")
  else
    console_log("role is null 8")
  end
  local cool_logic_manager = nx_value("cool_logic_manager")
  if nx_is_valid(cool_logic_manager) and nx_find_method(cool_logic_manager, "ResetCoolDownRecord") then
    cool_logic_manager:ResetCoolDownRecord()
  end
  local game_config_info = nx_value("game_config_info")
  nx_execute("game_config", "set_ui_scale", game_config_info.ui_scale_enable, game_config_info.ui_scale_value)
  local dialog = nx_value("form_stage_main\\form_close_scene")
  if nx_is_valid(dialog) then
    dialog:Close()
  else
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_close_scene", true, false)
  end
  if nx_is_valid(role) then
    console_log("role not null 9")
  else
    console_log("role is null 9")
  end
  if nx_is_valid(dialog) then
    dialog.mode = "open"
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "scene_change_return")
    if nx_is_valid(dialog) then
      dialog:Close()
      nx_destroy(dialog)
    end
  end
  console_log("flow entry_stage_main begin open finish")
  nx_set_value("stage_main", "success")
  if nx_is_valid(role) then
    console_log("role not null 9-1")
  else
    console_log("role is null 9-1")
  end
  initial_scene_sound()
  role = game_visual:GetPlayer()
  if nx_is_valid(role) then
    console_log("role not null 10")
  else
    console_log("role is null 10")
  end
  nx_set_value("loading", false)
  nx_execute("freshman_help", "player_entry_scene")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) and nx_int(player:QueryProp("LogicState")) == nx_int(101) then
    local form_stall = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_main", true, false)
    if nx_is_valid(form_stall) then
      form_stall:Show()
    end
  end
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "show_form_by_scene")
  local path_finding = nx_value("path_finding")
  local terrain = nx_value("game_scene").terrain
  if nx_is_valid(path_finding) and nx_is_valid(terrain) then
    path_finding.Terrain = terrain
  end
  if nx_is_valid(role) then
    console_log("role not null 11")
  else
    console_log("role is null 11")
  end
  local game_visual = nx_value("game_visual")
  game_visual.Terrain = terrain
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect.GameControl = scene.game_control
    skill_effect.Terrain = terrain
  end
  console_log("flow entry_stage_main send ready desktop visible=" .. nx_string(gui.Desktop.Visible))
  local sock = nx_value("game_sock")
  if nx_is_valid(sock) then
    sock.Sender:ClientReady()
    game_client.client_asyn_time = nx_function("ext_get_tickcount")
    game_client.ready = true
    local EgWar = nx_value("EgWarModule")
    if nx_is_valid(EgWar) and EgWar.IsContinue == 1 then
      nx_execute("custom_sender", "custom_enter_scene", 1)
      EgWar.IsContinue = 0
    end
  end
  if nx_is_valid(role) then
    console_log("role not null 12")
  else
    console_log("role is null 12")
  end
  show_continue_obj()
  if nx_is_valid(role) then
    console_log("role not null 13")
  else
    console_log("role is null 13")
  end
  local controlwatch = nx_value("ControlWatch")
  if not nx_is_valid(controlwatch) then
    controlwatch = nx_create("GameControlWatch")
    nx_set_value("ControlWatch", controlwatch)
  end
  local attach_manager = nx_create("AttachManager")
  nx_set_value("AttachManager", attach_manager)
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) and nx_find_method(goods_grid, "InitData") then
    goods_grid:InitData()
  end
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    if not nx_find_property(game_config_info, "watch_na") then
      nx_set_property(game_config_info, "watch_na", controlwatch.NATime)
    else
      controlwatch.NATime = nx_property(game_config_info, "watch_na")
    end
    local key = util_get_property_key(game_config_info, "watch_autona", 1)
    local bValue = nx_string(key) == nx_string("1")
    if controlwatch.AutoNA ~= bValue then
      controlwatch.AutoNA = bValue
    end
  end
  if nx_is_valid(role) then
    console_log("role not null 14")
  else
    console_log("role is null 14")
  end
  if nx_is_valid(game_visual) then
    local CLIENT_CUSTOMMSG_GUILDBUILDING = 1016
    local CLIENT_SUBMSG_REQUEST_PRECREATE_NPC = 140
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_PRECREATE_NPC))
    local CLIENT_CUSTOMMSG_LEITAI_WAR = 758
    local CLIENT_SUBMSG_LEITAI_ONCONTINUE = 10
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LEITAI_WAR), nx_int(CLIENT_SUBMSG_LEITAI_ONCONTINUE))
    local CLIENT_CUSTOMMSG_MASSES_FIGHT = 949
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MASSES_FIGHT), nx_int(3))
    local CLIENT_CUSTOMMSG_NEW_TERRITORY = 858
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_TERRITORY), nx_int(6))
  end
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("DetectProcess", nx_value("game_client"), 600)
  end
  nx_function("ext_send_fxnet2_code")
  nx_function("ext_send_fxmotion_code")
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "send_dll_code", nx_value("game_client"))
    timer:Register(10000, 5, nx_current(), "send_dll_code", nx_value("game_client"), -1, -1)
  end
  nx_execute("custom_sender", "custom_get_server_id")
  nx_execute("custom_sender", "custom_get_game_step")
  nx_execute("custom_sender", "custom_get_login_account")
  local game_visual = nx_value("game_visual")
  local player_exist = false
  if nx_is_valid(game_visual:GetPlayer()) then
    player_exist = true
  end
  local terrain_exist = false
  if nx_is_valid(game_scene.terrain) then
    terrain_exist = true
  end
  nx_log("entry_stage_main finish.")
  if nx_is_valid(role) then
    console_log("role not null 15")
  else
    console_log("role is null 15")
  end
  local terrain_exist = false
  if nx_is_valid(game_scene.terrain) then
    terrain_exist = true
    nx_pause(0.1)
    while not game_scene.terrain.LoadFinish do
      nx_pause(0.1)
      if not nx_is_valid(game_scene.terrain) then
        console_log("terrain not exist")
        return false
      end
    end
  end
  if nx_is_valid(role) then
    console_log("role not null 16")
  else
    console_log("role is null 16")
  end
  local player_exist = false
  if nx_is_valid(game_visual:GetPlayer()) then
    player_exist = true
  else
    nx_log("flow game_visual:GetPlayer not exist load_current_scene")
    load_current_scene()
  end
  if nx_is_valid(game_scene.terrain) then
    terrain_exist = true
  end
  role = game_visual:GetPlayer()
  if nx_is_valid(role) then
    console_log("role not null 17")
  else
    console_log("role is null 17")
  end
  console_log("player " .. nx_string(player_exist))
  console_log("terrain " .. nx_string(terrain_exist) .. "loadfinish=" .. nx_string(game_scene.terrain.LoadFinish))
  console_log("entry_stage_main finish.")
  if nx_is_valid(game_visual) then
    local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
    local CLIENT_SUBMSG_REQUEST_SHOW_FORM_PRIZEE = 1
    local CLIENT_SUBMSG_REQUEST_SHOW_FORM_WISH = 6
    local form_activity = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_activity\\form_activity_info", true, false)
    if nx_is_valid(form_activity) then
      form_activity:Close()
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SHOW_FORM_PRIZEE))
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SHOW_FORM_WISH))
  end
  nx_execute("form_stage_main\\form_card\\form_card_skill", "show_form_cardskill")
  if nx_is_valid(role) then
    console_log("role not null 18")
  else
    console_log("role is null 18")
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Focused = nx_null()
  end
  if nx_is_valid(terrain) then
    terrain:AddVisualRole("main_role", role)
  else
    return 0
  end
  set_async_load(role, true)
  local bnExist = nx_file_exists(nx_work_path() .. "Lua\\Main.lua")
  if bnExist == true then
    local plugsys = nx_value("PlugSys")
    if nx_is_valid(plugsys) then
      plugsys:OnEntryGameStage()
      local plugmgr = nx_value("PlugMgr")
      if not nx_is_valid(plugmgr) then
        plugmgr = nx_create("PlugMgr")
        if nx_is_valid(plugmgr) then
          nx_set_value("PlugMgr", plugmgr)
        end
      end
    end
  end
  local preload_npc = nx_value("NpcPreLoad")
  preload_npc:readd_preload_npc()
  if old_stage ~= "main" then
    nx_execute("form_stage_main\\form_activity\\form_activity_signin", "is_need_tips")
    nx_execute("form_stage_main\\form_activity\\form_activity_login", "is_need_tips")
  end
  nx_execute("form_stage_main\\form_main\\form_main", "refesh_happy_miaohui")
  nx_execute("form_stage_main\\form_home\\form_home_function", "open_form")
  nx_execute("form_stage_main\\form_home\\form_home_model", "open_form")
  nx_execute("form_stage_main\\form_home\\form_home_enter", "check_close_form")
  nx_execute("form_stage_main\\form_home\\form_home_enter", "check_home_leitai_form")
  nx_execute("form_stage_main\\form_main\\form_main", "check_groupbox_4")
  local game_sock = nx_value("game_sock")
  if not game_sock.Connected and nx_find_custom(game_sock, "dialog") and not nx_is_valid(game_sock.dialog) then
    nx_kill("game_sock", "game_sock_close", game_sock)
    nx_kill("game_sock", "try_reconnect1_server", game_sock)
    game_sock.cant_reconnect = true
    game_sock.try_reconnect = false
    game_sock.Sender.try_reconnect = false
    game_sock.Receiver.try_reconnect = false
    nx_execute("game_sock", "game_sock_close", game_sock)
  end
  local AOWSteamClient = nx_value("AOWSteamClient")
  if nx_is_valid(AOWSteamClient) and old_stage ~= "main" then
    AOWSteamClient:RequestData()
  end
  nx_function("ext_set_scene_effect_dead")
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and game_config.weather_enable then
    nx_execute("terrain\\weather_set", "initialize_weather_data")
  end
  if old_stage == "login" or old_stage == "roles" then
    nx_execute("custom_sender", "custom_get_login_account_id")
  end
  nx_function("ext_release_automempool")
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    local ini = nx_resource_path() .. "ini\\func_btns_ex.ini"
    funcbtns:LoadAddFuncBtnInfo(ini)
    funcbtns:RefreshLeadBtnInfo()
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and game_config.first_lead == true and game_config.freshman_btn_show == true then
    game_config.first_lead = false
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("addbtn_lead_help"), "1")
  end
  local LogicVmChecker = nx_value("LogicVmChecker")
  if nx_is_valid(LogicVmChecker) then
    LogicVmChecker:RegisterUpLoad()
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Focused = nx_null()
  end
  nx_execute("form_stage_main\\form_cross_school_fight\\form_cross_school_fight_wait", "refresh_form")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_list", "close_form")
  local player_form = nx_value("form_stage_main\\form_main\\form_main_player")
  if nx_is_valid(player_form) then
    local form_main_player = nx_value("form_main_player")
    if nx_is_valid(form_main_player) then
      form_main_player:RefreshTeamIcon(player_form)
    end
  end
  nx_execute("form_stage_main\\form_small_game\\form_stage_main_1024", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "hide_player_pickup_num")
  nx_execute("form_stage_main\\form_taosha\\apex_util", "hide_player_pickup_num")
  if nx_boolean(b_first_intogame) then
    nx_execute("gameinfo_collector", "GTP_start_game")
  end
  return 1
end
function set_async_load(role, async_load)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(role) and nx_is_valid(game_visual) then
    role.AsyncLoad = async_load
    local actor_role = game_visual:QueryActRole(role)
    if nx_is_valid(actor_role) then
      actor_role.AsyncLoad = async_load
    end
  end
end
function move_file_binding_to_account()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if not nx_find_property(game_config, "login_account") then
    return
  end
  local account = game_config.login_account
  local exe_path = nx_function("ext_get_current_exe_path")
  nx_function("ext_create_directory", exe_path .. account)
end
function show_continue_obj()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local lists = game_scene:GetSceneObjList()
  for i = 1, table.getn(lists) do
    if not nx_is_valid(game_visual:GetSceneObj(lists[i].Ident)) and not game_client:IsPlayer(lists[i].Ident) then
      show_scene_obj(lists[i].Ident)
    end
  end
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj:RegisterCallBack()
  end
end
local no_delete_form_table = {
  ["form_stage_main\\form_sys_notice"] = true,
  ["form_stage_main\\form_close_scene"] = true,
  ["form_common\\form_loading"] = true,
  form_tips = true
}
function is_need_delete(form_name)
  if no_delete_form_table[form_name] == true then
    return false
  end
  return true
end
function exit_stage_main(new_stage)
  console_log("exit_stage_main")
  nx_execute("form_stage_main\\form_camera\\form_save_camera", "exit_play_camera")
  nx_execute("form_stage_main\\form_main\\form_main_request", "clear_special_request", REQUESTTYPE_MULTI_RIDE)
  nx_execute("form_stage_main\\skill_camera_movie", "movie_stop")
  local attach_manager = nx_value("AttachManager")
  if nx_is_valid(attach_manager) then
    nx_destroy(attach_manager)
  end
  local goods_grid = nx_value("GoodsGrid")
  if nx_is_valid(goods_grid) and nx_find_method(goods_grid, "ClearData") then
    goods_grid:ClearData()
  end
  nx_function("ext_stop_form_fade_by_role_state")
  nx_set_value("stage_main", "exit")
  local gEffect = nx_value("global_effect")
  if nx_is_valid(gEffect) then
    gEffect:ClearEffects()
  end
  delete_main_scene()
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj:Clear()
  end
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) then
    common_array:RemoveAutoDeleteArray()
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "send_dll_code", nx_value("game_client"))
  end
  local gui = nx_value("gui")
  if new_stage ~= "main" and nx_is_valid(gui) then
    local ballset = nx_value("balls")
    if nx_is_valid(ballset) then
      gui:Delete(ballset)
    end
    local childlist = gui:GetAllFormList()
    if childlist == nil then
    else
      for i = 1, table.maxn(childlist) do
        local control = childlist[i]
        if nx_is_valid(control) and not nx_id_equal(control, gui.Desktop) and is_need_delete(control.Name) then
          control.Visible = true
          control:Close()
          if nx_is_valid(control) then
            gui:Delete(control)
          end
        end
      end
    end
    gui.Desktop:Close()
    gui.Desktop:DeleteAll()
    gui.Desktop.BackImage = ""
    nx_bind_script(gui.Desktop, "")
    local game_visual = nx_value("game_visual")
    game_visual:DeleteAll()
    local game_client = nx_value("game_client")
    game_client:ClearAll()
    game_client.need_reload_main_form = true
    nx_set_value("player_ready", false)
    nx_set_value("scene_ready", false)
    local databinder = nx_value("data_binder")
    if nx_is_valid(databinder) then
      databinder:ClearPropBindInfo()
    end
  end
  nx_set_value("exit_success", true)
  nx_execute("form_common\\form_confirm", "clear")
  nx_execute("form_common\\form_connect", "clear")
  nx_execute("form_stage_main\\form_main\\form_main", "clear")
  nx_execute("form_stage_main\\form_main\\form_main_player", "clear")
  nx_execute("form_stage_main\\form_relive_ok", "clear")
  nx_execute("form_stage_main\\form_relation\\form_relation_confirm", "clear")
  nx_execute("form_stage_main\\form_arrest\\form_arrest_confirm", "clear")
  nx_execute("form_stage_main\\form_common_notice", "close_form")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "close_form")
  nx_execute("form_stage_main\\form_main\\form_main_request_right", "hide_modal")
  nx_execute("form_stage_main\\form_freshman\\form_freshman_main", "clear")
  nx_execute("form_stage_main\\form_map\\form_map_scene", "hide_map_label_detail")
  nx_execute("form_stage_main\\form_school_war\\form_school_fight_info", "close_form")
  nx_execute("form_stage_main\\form_school_fight\\form_school_fight_help_info", "close_form")
  nx_execute("form_stage_main\\form_school_war\\form_school_fight_rank", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_join", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_result", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_switch", "close_form")
  nx_execute("form_stage_main\\form_mail\\form_mail", "close_form")
  nx_execute("form_stage_main\\form_life\\form_recast_attribute", "close_form")
  nx_execute("form_stage_main\\form_life\\form_recast_attribute_weapon", "close_form")
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "close_form")
  nx_execute("form_stage_main\\form_card\\form_card_skill", "close_form")
  nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "close_form")
  nx_execute("form_stage_main\\form_main\\form_laba_info", "close_form")
  nx_execute("form_stage_main\\form_school_war\\form_school_war_control", "close_form")
  nx_execute("form_stage_main\\form_school_fight\\form_school_fight_message", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_join", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_lingxiao_stat", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_neiying_tip", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_map", "close_form")
  nx_execute("form_stage_main\\form_school_destroy\\form_protect_school_map", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_stat", "close_form")
  nx_execute("form_stage_main\\form_die_world_war", "close_form")
  nx_execute("form_stage_main\\form_main\\form_main_map", "hide_world_war_btn")
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_one", "close_form")
  nx_execute("form_stage_main\\form_main\\form_school_introduce", "clear")
  nx_execute("form_stage_main\\form_main\\form_school_introduce_video", "clear")
  nx_execute("form_stage_main\\form_main\\form_main_func_btns_ex", "close_form")
  nx_execute("form_stage_main\\form_freshman\\form_freshman_voice", "close_form")
  nx_execute("form_stage_main\\form_life\\form_huohuan_duihuan", "clear")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "on_channel_team")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "on_channel_world_war")
  nx_function("ext_stop_area_music")
  nx_execute("form_stage_main\\form_force\\form_force_wuque", "close_form")
  nx_execute("form_stage_main\\form_home\\form_cease_meun", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_help", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home", "clear_home_form")
  nx_execute("form_stage_main\\form_freshman\\form_freshman_jiayuan", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_zh", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_mutual", "close_form")
  nx_execute("form_stage_main\\form_home\\form_home_func_round", "close_form")
  nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", "close_form")
  nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", "close_form")
  nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", "close_form")
  nx_execute("form_stage_main\\form_force\\form_force_hsp_meet", "close_form")
  nx_execute("form_stage_main\\form_world_war\\form_world_war_join", "close_form")
  nx_execute("form_stage_main\\form_die_hsp_meet", "close_form")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_list", "close_form")
  nx_execute("form_stage_main\\form_clone\\form_dynamic_score", "close_form")
  nx_execute("form_stage_main\\form_die_guild_cross_war", "close_form")
  nx_execute("form_stage_main\\form_xmqy_detail", "close_form")
  nx_execute("form_stage_main\\form_small_game\\form_stage_main_1024", "close_form")
  nx_execute("form_stage_main\\form_clone\\form_taolu_select", "close_form")
  nx_execute("form_stage_main\\form_huashan\\form_huashan_wuxue_canwu", "close_form")
  nx_execute("form_stage_main\\form_die_erg_war", "close_form")
  nx_execute("form_stage_main\\form_outland_war\\form_outland_war_score", "close_form")
  nx_execute("form_stage_main\\form_tongguanjiangli", "close_form")
  nx_execute("form_stage_main\\form_tongguanjiangli_five", "close_form")
  nx_execute("form_stage_main\\form_tongguanshibai", "close_form")
  nx_execute("form_stage_main\\form_school_counterattack\\form_counter_attack_rank", "close_form")
  nx_execute("form_stage_main\\form_die_sanmeng", "close_form")
  nx_execute("form_stage_main\\form_die_luandou", "close_form")
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_dead", "close_form")
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_fight", "close_form")
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_main", "close_form")
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_req", "close_form")
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_score", "close_form")
  nx_execute("form_stage_main\\form_match\\form_sanmeng_wait", "close_form")
  nx_execute("form_stage_main\\form_help\\form_help_qinggong_video", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_result", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance_info", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_score", "balance_war_close_form")
  nx_execute("form_stage_main\\form_match\\form_banxuan_taolu", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_ready_before", "close_form")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_damin", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_search_team", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_team_create", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_result", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready_before", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_ready", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_invite", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_daily", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_apply", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_final", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_kick", "close_form")
  nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_banpick", "close_form")
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "close_form")
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_best", "close_form")
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "close_form")
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "close_form")
  nx_execute("form_stage_main\\form_jiuyang_faculty\\form_jyf_wait", "show_form", false)
  nx_execute("form_stage_main\\form_force\\form_wuque_buy_extra", "close_form")
  nx_execute("form_stage_main\\form_die_new_school_fight", "close_form")
  nx_execute("form_stage_main\\form_new_war_rule\\form_new_war_rule_wait", "close_form")
  nx_execute("form_stage_main\\form_universal_school_fight\\form_universal_school_fight_main", "close_form")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_merge", "close_form")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_tiguan", "close_form")
  nx_execute("form_stage_main\\form_origin\\form_origin", "close_form")
  nx_execute("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_msg_new", "close_form")
  nx_execute("form_stage_main\\form_depot", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_apex_pick", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_apex_apply", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_pick", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_skill_choose", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_map_scene", "close_form")
  nx_execute("form_stage_main\\form_war_scuffle\\form_balance_total", "close_form")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "hide_player_pickup_num")
  nx_execute("form_stage_main\\form_taosha\\apex_util", "hide_player_pickup_num")
  nx_execute("form_stage_main\\form_taosha\\form_taosha_main", "hide_ctrl_entry_taosha", false)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_notice_shortcut", true)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue", "close_form")
  nx_execute("form_stage_main\\form_world_auction\\form_world_auction", "close_form")
  nx_execute("form_stage_main\\form_world_auction\\form_world_auction_see_boss", "close_form")
  nx_execute("form_stage_main\\form_world_auction\\form_black_market", "close_form")
  nx_execute("form_stage_main\\form_guild_battle\\form_cw_invite", "close_form")
  nx_execute("form_stage_main\\form_guild_battle\\form_guild_battle_score", "close_form")
  nx_execute("form_stage_main\\form_die_guildbalance", "close_form")
  nx_execute("form_stage_main\\form_die_guildpower", "close_form")
  nx_execute("form_stage_main\\form_dbomall\\form_dboactreward", "close_form")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_exchange", "close_form")
  nx_execute("form_stage_main\\form_match\\form_guild_union", "close_form")
  nx_execute("form_stage_main\\form_ver_201904\\form_scene_form", "close_form")
  nx_execute("form_stage_main\\form_ver_201904\\form_event_task", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_drag", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_invite", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_see_list", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_war_info", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_see", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_lm_main", "close_form")
  nx_execute("form_stage_main\\form_league_matches\\form_cross_wait", "close_form")
  nx_execute("form_stage_main\\form_die_league_matches", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_apply", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_fighter", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_loading", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_looker", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_main", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_round_res", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_wait", "close_form")
  nx_execute("form_stage_main\\form_kof\\form_kof_war_res", "close_form")
  nx_execute("form_stage_main\\form_dream_land\\form_dream_land", "close_form")
  nx_execute("form_stage_main\\form_die_flee_in_night", "close_form")
  nx_execute("form_stage_main\\form_tiguan\\form_new_tiguan_main", "close_form")
  nx_execute("form_stage_main\\form_home\\form_qin_player", "close_form")
  local form_main_map = nx_value("form_stage_main\\form_main\\form_main_map")
  if nx_is_valid(form_main_map) then
    form_main_map.Visible = true
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:StopAll()
  end
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    game_client.ready = false
  end
  unnitial_scene_sound()
  return 1
end
function add_main_private_to_scene(scene)
  local world = nx_value("world")
  nx_execute("login_scene", "clear_login_scene_private", scene)
  world.MainScene = scene
  local camera = scene.camera
  camera.Fov = 51.8 * math.pi * 2 / 360
  nx_set_value("game_camera", camera)
  local game_control
  if not nx_find_custom(scene, "game_control") or not nx_is_valid(scene.game_control) then
    game_control = scene:Create("GameControl")
    nx_bind_script(game_control, "game_control", "game_control_init")
    game_control.GameVisual = nx_value("game_visual")
    game_control:Load()
    scene:AddObject(game_control, 0)
    scene.game_control = game_control
  else
    game_control = scene.game_control
  end
  game_control.MaxDisplayFPS = 60
  local game_config = nx_value("game_config")
  nx_execute("game_config", "apply_misc_config", scene, game_config)
  return true
end
function delete_main_scene()
  local world = nx_value("world")
  local scene = world.MainScene
  if nx_is_valid(scene) and nx_find_custom(scene, "game_control") then
    scene:Delete(scene.game_control)
  end
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    skill_effect.GameControl = nx_null()
  end
  nx_execute("ocean_edit\\ocean_edit", "terrain_delete_ocean")
  nx_call("terrain\\weather_set", "delete_weather_data")
  return true
end
function load_current_scene()
  console_log("flow load_current_scene begin")
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local scene = world.MainScene
  if nx_find_custom(scene, "physics_scene") and nx_is_valid(scene.physics_scene) then
    scene:Delete(scene.physics_scene)
  end
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, world.MainScene)
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    nx_log(get_msg_str("msg_436"))
    return false
  end
  local gui = nx_value("gui")
  gui.TextManager:SetText("Player", client_player:QueryProp("Name"))
  local form = gui.Desktop
  local posi_x = client_player.PosiX
  local posi_y = client_player.PosiY
  local posi_z = client_player.PosiZ
  local orient = client_player.Orient
  local camera = scene.camera
  camera:SetPosition(posi_x, posi_y + 12, posi_z)
  camera:SetAngle(0, orient, 0)
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    nx_msgbox(get_msg_str("msg_437"))
    return false
  end
  local scene_res_name = client_scene:QueryProp("Resource")
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_SET_SCENE, scene_res_name)
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    mgr = nx_create("SceneCreator")
    nx_set_value("SceneCreator", mgr)
  end
  mgr:LoadSceneXml(scene_res_name, false)
  local terrain_dir = "map\\ter\\" .. scene_res_name .. "\\"
  local weather = client_scene:QueryProp("Weather")
  local weather_config
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\scene_weather.ini")
  local index = ini:FindSectionIndex(nx_string(weather))
  if 0 <= index then
    weather_config = ini:ReadString(index, "WeatherConfig", "")
  end
  load_scene(scene, terrain_dir, false, weather_config)
  local terrain = scene.terrain
  if not nx_find_custom(scene, "terrain") or not nx_is_valid(scene.terrain) then
    local error_text = nx_widestr(util_text("msg_LoadSceneFailedMaoHao")) .. nx_widestr(terrain_dir)
    nx_msgbox(nx_string(error_text))
    return 0
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(terrain) and nx_is_valid(game_visual) then
    game_visual:ResetScene(terrain)
  end
  terrain_show(terrain, false)
  console_log("flow load_current_scene begin test LoadFinish")
  while not terrain.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(terrain) then
      console_log("flow load_current_scene return no terrain not valid")
      return false
    end
  end
  scene.BackColor = scene.weather.FogColor
  world.BackColor = scene.BackColor
  console_log("flow load_current_scene end test LoadFinish")
  local game_config = nx_value("game_config")
  nx_execute("game_config", "apply_performance_config", scene, game_config)
  terrain_show(terrain, true)
  local preload_npc = nx_value("NpcPreLoad")
  preload_npc:create_preload_npc()
  local game_role = nx_value("role")
  if nx_is_valid(game_role) then
    scene:Delete(game_role)
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local role = nx_null()
  if not nx_is_valid(game_role) or not game_visual:QueryRoleCreateFinish(game_role) then
    console_log("flow stage_main: enter scene create new role model")
    role = role_composite:CreateSceneBodyObject(scene, client_player, false, false, true)
    nx_set_value("role", role)
  else
    console_log("flow stage_main: enter scene use old role model")
    role = game_role
  end
  set_async_load(role, false)
  if not nx_is_valid(role) then
    local error_text = nx_widestr(util_text("msg_CreateMainPlayerFailed")) .. nx_widestr(client_player)
    local game_sock = nx_value("game_sock")
    if game_sock.Connected then
      nx_msgbox(nx_string(error_text))
    else
      nx_log(nx_string(error_text))
    end
    return false
  end
  game_visual:CreateRoleUserData(role)
  game_visual:SetRoleClientIdent(role, game_client.PlayerIdent)
  role.client_obj = client_player
  role.is_main_player = true
  role.shadow = nx_null()
  role.WaterReflect = true
  role:SetPosition(posi_x, posi_y, posi_z)
  role:SetAngle(0, orient, 0)
  role:SetScale(1, 1, 1)
  role.TraceEnable = false
  game_visual.PlayerIdent = client_player.Ident
  game_visual:CreateSceneObj(client_player.Ident, role)
  game_visual:ResetSceneObj(client_player.Ident, role)
  local scene_obj = nx_value("scene_obj")
  scene_obj:SceneObjInit(role, client_player)
  while not game_visual:QueryRoleCreateFinish(role) do
    nx_pause(0.1)
    if not nx_is_valid(role) then
      console_log("load_current_scene return no nx_is_valid(role)")
      return false
    end
  end
  terrain:RemoveVisual(role)
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    nx_msgbox(get_msg_str("msg_438"))
    return false
  end
  game_control.Player = role
  game_control.Camera = camera
  game_control.Terrain = terrain
  if game_visual:QueryRoleRiderType(role) == 2 then
    game_control.BindHeight = 4
  else
    game_control.BindHeight = get_scene_obj_boxsize_y(role) * 0.92
  end
  local normal_camera = game_control:GetCameraController(GAME_CAMERA_NORMAL)
  local bindpos_camera = game_control:GetCameraController(GAME_CAMERA_BINDPOS)
  normal_camera.CurYawAngle = role.AngleY
  bindpos_camera.CurYawAngle = role.AngleY
  game_control.CameraMode = nx_int(nx_execute("control_set", "get_camera_mode"))
  game_control.Distance = 6
  game_control.YawAngle = role.AngleY
  game_control.PitchAngle = 0
  if nx_number(game_control.CameraMode) == nx_number(GAME_CAMERA_BINDPOS) then
    game_control.FightOperateMode = FIGHT_OPERATE_MODE_JOYSTICK
  else
    game_control.FightOperateMode = FIGHT_OPERATE_MODE_NORMAL
  end
  game_control.LockRadiusGene = 2
  game_control.LockWantY = 1.5
  game_control.LockMinXZ = 8
  game_control.LockMaxXZ = 20
  game_control.LockMaxRadius = 19
  game_control:ResetCamera()
  if nx_is_valid(role) then
    console_log("role not null 1")
  else
    console_log("role is null 1")
  end
  terrain.Player = role
  local is_on_transtool = 0 < client_player:QueryProp("OnTransToolState")
  if is_on_transtool then
    role.Visible = false
  end
  local client_npc_manager = nx_value("client_npc_manager")
  if nx_is_valid(client_npc_manager) then
    client_npc_manager.Role = role
  end
  local marry_decorate_create = nx_value("MarryDecorateNpcCreate")
  if nx_is_valid(marry_decorate_create) then
    marry_decorate_create.Player = role
    marry_decorate_create:TryToLoadResource()
  end
  if nx_is_valid(role) then
    console_log("role not null 2")
  else
    console_log("role is null 2")
  end
  scene_obj:LocatePlayer(role, posi_x, posi_y, posi_z, orient)
  if nx_is_valid(role) then
    console_log("role not null 3")
  else
    console_log("role is null 3")
  end
  local game_config = nx_value("game_config")
  nx_execute("game_config", "set_shadow_quality", scene, game_config.shadow_quality)
  local balls = nx_value("balls")
  balls.Scene = scene
  balls.Sort = true
  scene_obj:StartMainPlayer(role, client_player)
  if nx_is_valid(role) then
    console_log("role not null 4")
  else
    console_log("role is null 4")
  end
  local random_info = client_scene:QueryProp("RandomTerrainInfo")
  if random_info ~= "" then
    local DynamicCloneHelper = nx_value("DynamicCloneHelper")
    if nx_is_valid(DynamicCloneHelper) then
      DynamicCloneHelper:RandomListInit()
    end
  end
  nx_execute("form_stage_main\\form_bag_new", "reset_scene")
  nx_execute("form_stage_main\\form_gunman", "reset_scene")
  nx_execute("form_stage_main\\form_small_game\\form_stage_main_1024", "close_form")
  game_visual:SetRoleCreateFinish(role, true)
  game_visual:EmitPlayerInput(role, 25)
  game_control:ResetCamera()
  if nx_is_valid(scene_obj) then
    scene_obj.GameControl = game_control
    scene_obj.ShadowManager = shadow_man
  end
  if nx_is_valid(role) then
    console_log("role not null 5")
  else
    console_log("role is null 5")
  end
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_npc_manager) then
    local camera_common = game_control:GetCameraController(0)
    local camera_story = game_control:GetCameraController(2)
    if nx_is_valid(camera_common) then
      scenario_npc_manager.CommonCamera = camera_common
    end
    if nx_is_valid(camera_story) then
      scenario_npc_manager.ScenarioCamera = camera_story
    end
  end
  local buffer_effect = nx_value("BufferEffect")
  if nx_is_valid(buffer_effect) then
    buffer_effect:UpdateBufferEffect(game_client.PlayerIdent)
  end
  local game_client = nx_value("game_client")
  if nx_find_custom(game_client, "special_mode") and game_client.special_mode then
    nx_execute("cj_control", "on_reset")
  end
  update_lock_camera(normal_camera)
  update_fight_track_mode()
  local die_clone_form = nx_value("form_stage_main\\form_die_clone")
  if nx_is_valid(die_clone_form) then
    nx_execute("form_stage_main\\form_die_clone", "fresh_relive_form", die_clone_form)
  end
  if nx_is_valid(role) then
    console_log("role not null 6")
  else
    console_log("role is null 6")
  end
  nx_pause(0.1)
  if nx_is_valid(terrain) then
    while nx_is_valid(terrain) and not terrain.LoadFinish do
      nx_pause(0.1)
      if not nx_is_valid(terrain) then
        nx_log("terrain not exits")
        return false
      end
    end
  end
  nx_log("player pos terrain loadfinish")
  nx_execute("form_stage_main\\form_main\\form_main_map", "reset_scene")
  nx_execute("form_stage_main\\form_map\\form_map_scene", "reset_scene")
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue", "reset_scene")
  nx_execute("form_stage_main\\form_school_fight\\form_school_fight_map", "reset_scene")
  nx_execute("form_stage_main\\form_bag", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main_player", "reset_scene")
  nx_execute("form_stage_main\\form_role_info\\form_role_info", "reset_scene")
  nx_execute("form_stage_main\\form_origin\\form_origin", "reset_scene")
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "reset_scene")
  nx_execute("form_stage_main\\form_homepoint\\form_home_point", "reset_scene")
  nx_execute("form_stage_main\\form_common_notice", "show_form")
  nx_execute("form_stage_main\\form_school_war\\form_escort_trace", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "reset_scene")
  nx_execute("form_stage_main\\form_present_to_npc", "reset_scene")
  nx_execute("form_stage_main\\form_system\\form_system_interface_guide", "reset_scene")
  nx_execute("form_stage_main\\form_equipblend", "reset_scene")
  nx_execute("form_stage_main\\form_card\\form_card_skill", "reset_scene")
  nx_execute("form_stage_main\\form_scene_compete\\form_scene_compete", "reset_scene")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "reset_scene")
  nx_execute("form_stage_main\\form_task\\form_jianghu_explore", "reset_scene")
  nx_execute("form_stage_main\\form_chat_system\\form_new_friend_list", "reset_scene")
  nx_execute("form_stage_main\\form_relation\\form_new_world_player_info", "reset_scene")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main", "show_jh_tour_info")
  nx_execute("form_stage_main\\form_func_guide", "reset_scene")
  nx_execute("form_stage_main\\form_home\\form_home_model", "reset_scene")
  nx_execute("form_stage_main\\form_home\\form_home_function", "reset_scene")
  nx_execute("form_stage_main\\form_home\\form_home_enter", "reset_scene")
  nx_execute("form_stage_main\\form_school_destroy\\form_protect_school_map", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main", "is_show_donghai_activity_btn")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "on_channel_wudao")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "on_channel_luandou")
  nx_execute("form_stage_main\\form_taosha\\taosha_util", "reset_scene")
  nx_execute("form_stage_main\\form_taosha\\apex_util", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main", "hide_wudao_fire")
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "check_close_form")
  nx_execute("form_stage_main\\form_single_notice", "check_jyf_form")
  nx_execute("form_stage_main\\form_main\\form_main", "init_form_main_logic")
  nx_execute("form_stage_main\\form_tiguan\\form_tiguan_dual_play", "reset_scene")
  nx_execute("form_stage_main\\form_main\\form_main", "check_show_sjy_meet_ui")
  nx_execute("form_stage_main\\form_main\\form_main", "check_show_xmg_meet_ui")
  nx_execute("form_stage_main\\form_small_game\\form_game_sjy_army", "open_form", 2)
  return true
end
function terrain_show(terrain, show)
  local world = nx_value("world")
  local scene = world.MainScene
  scene.postprocess_man.Visible = show
  terrain.GroundVisible = show
  terrain.VisualVisible = show
  terrain.WaterVisible = show
  if show then
    local game_config = nx_value("game_config")
    nx_execute("game_config", "set_logic_sound_enable", scene, 0, game_config.area_music_enable)
  end
end
function apply_shadow_param(shadow)
  local world = nx_value("world")
  local scene = world.MainScene
  local shadow_uiparam = scene.shadow_uiparam
  if not nx_is_valid(shadow_uiparam) then
    return false
  end
  shadow.ShadowTopColor = shadow_uiparam.topcolor
  shadow.ShadowBottomColor = shadow_uiparam.bottomcolor
  shadow.LightDispersion = shadow_uiparam.lightdispersion
  return true
end
function show_scene_obj(ident)
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj:AddObject(ident)
    return true
  end
  return false
end
function get_scene_obj_boxsize_y(scene_obj)
  if nx_find_custom(scene_obj, "height") then
    return scene_obj.height
  else
    return nx_float(1.8)
  end
end
function update_lock_camera(normal_camera)
  local lock_camera = false
  local camera_max_dis = 20
  local operate_mode = "0"
  local game_config_info = nx_value("game_config_info")
  if nx_is_valid(game_config_info) then
    lock_camera = nx_string(game_config_info.lock_camera) == nx_string("1") and true or false
    camera_max_dis = nx_float(game_config_info.max_camera_dis)
    operate_mode = game_config_info.operate_control_mode
    if nx_string(operate_mode) == nx_string("0") then
      lock_camera = false
    end
  end
  normal_camera.LockCamera = lock_camera
  if lock_camera then
    normal_camera.CurPitchAngle = 0.4
    normal_camera.CurDistance = camera_max_dis / 2
  end
end
function update_fight_track_mode()
  local TrackMode = {
    "normal",
    "up",
    "down",
    "arc"
  }
  local game_config_info = nx_value("game_config_info")
  local SpriteManager = nx_value("SpriteManager")
  if nx_is_valid(SpriteManager) then
    local index = nx_number(util_get_property_key(game_config_info, "fight_flutter_mode", 1))
    if nil ~= index then
      local word = TrackMode[index]
      if nil ~= word then
        SpriteManager:SetKeyword(TrackMode[index])
      end
    end
  end
end
function get_3d_screen()
  local gui = nx_value("gui")
  console_log("device width = " .. nx_string(gui.DeviceWidth) .. " height= " .. nx_string(gui.DeviceHeight))
end
function get_wnd_size()
  local width, height = nx_function("ext_get_client_rect")
  console_log("window client width = " .. nx_string(width) .. " height= " .. nx_string(height))
end
function initial_scene_sound()
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local scene = world.MainScene
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    local game_sock = nx_value("game_sock")
    if game_sock.Connected then
      nx_msgbox(get_msg_str("msg_437"))
    else
      nx_log(get_msg_str("msg_437"))
    end
    return
  end
  local scene_res_name = client_scene:QueryProp("Resource")
  local sceneid = client_scene:QueryProp("ConfigID")
  if string.find(sceneid, "war") ~= nil then
    local i, j = string.find(sceneid, "ini\\scene\\")
    local music_index_name = string.sub(sceneid, j + 1)
    nx_execute("util_functions", "play_music", scene, "scene", music_index_name)
  else
    local scene_music_play_manager = nx_value("scene_music_play_manager")
    if not nx_is_valid(scene_music_play_manager) then
      return ""
    end
    local map_query = nx_value("MapQuery")
    if not nx_is_valid(map_query) then
      return ""
    end
    local map_id = nx_int(map_query:GetSceneId(scene_res_name))
    local succesful = false
    if map_id ~= nx_int(-1) then
      local init_music = "main_scene_music_init_" .. nx_string(map_id)
      succesful = nx_execute("util_functions", "play_music", scene, "scene", init_music, 0, 1, false)
      if succesful then
        return
      end
    end
    if not succesful then
      nx_execute("util_functions", "play_music", scene, "scene", scene_res_name, 0, 1, true)
    end
  end
  local game_config = nx_value("game_config")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) or not nx_is_valid(game_config) then
    return
  end
  if not game_config.music_enable then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(500, 1, nx_current(), "simulate_close_music", game_config, -1, -1)
      nx_execute("form_stage_main\\form_system\\form_system_music_setting", "set_music_enable", true)
    end
  end
  if not nx_find_custom(game_visual, "area_music") then
    return
  end
  local music = game_visual.area_music
  if game_config.area_music_enable then
    if nx_is_valid(music) then
      music.Volume = game_config.area_music_volume
      music:Play(1)
    end
  elseif nx_is_valid(music) then
    music.Volume = 0
    music:Stop(1)
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
  nx_execute("game_config", "set_sound_volume", scene, game_config.sound_volume)
end
function unnitial_scene_sound()
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:DestroyGameMusic()
  end
end
function simulate_close_music(game_config)
  nx_execute("form_stage_main\\form_system\\form_system_music_setting", "set_music_enable", game_config.music_enable)
end
function on_device_error_reset_all()
  clear_all_form()
  local world = nx_value("world")
  nx_function("ext_clear_all_entitys_byname", "Gui")
  world.MainGui = nx_null()
  nx_function("ext_clear_all_entitys_byname", "ImageList")
  local scene_old = world.MainScene
  delete_main_scene()
  nx_call("scene", "delete_scene", scene_old)
  world.MainScene = nx_null()
  nx_function("ext_clear_all_entitys_byname", "Actor2")
  nx_function("ext_clear_all_entitys_byname", "EffectModel")
  nx_function("ext_clear_all_entitys_byname", "Model")
  nx_function("ext_clear_all_entitys_byname", "Actor")
  nx_function("ext_helper_clear_all_but_nodel")
  nx_pause(0.5)
  world:Clear()
  nx_pause(0.5)
  nx_execute("console", "dump_entity")
  if not world:CreateDevice("FxRender.DxRender") then
    nx_msgbox(get_error_msg("msg_431"))
    return 0
  end
  local gui = nx_create("Gui", "FxRender.Painter")
  nx_set_value("gui", gui)
  world.MainGui = gui
  if not gui:CreateDesktopForm() then
    nx_msgbox(get_msg_str("msg_431"))
    return false
  end
  nx_bind_script(gui, "gui", "gui_init")
  nx_bind_script(gui.GameHand, "game_hand", "gamehand_init")
  local resource_xml = gui.skin_path .. "resource.xml"
  local game_config = nx_value("game_config")
  if game_config.Language ~= "" then
    resource_xml = "skin\\resource_" .. nx_string(game_config.Language) .. ".xml"
  end
  gui.Loader.DefResourceName = resource_xml
  nx_log("load gui resource begin...")
  gui.Loader:LoadResource(nx_resource_path(), resource_xml)
  nx_log("load gui resource end")
  gui.Cursor = "Default"
  local lang_path = nx_execute("util_functions", "get_language_path")
  gui.TextManager:LoadFiles(lang_path)
  nx_call("gui", "init_money_FormatText", gui)
  gui:CheckClientSize()
  local ItemQuery = nx_value("ItemQuery")
  ItemQuery.Text = gui.TextManager
  create_scene("game_scene")
  world.MainScene = nx_value("game_scene")
  entry_stage_main("roles")
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local game_scene = game_client:GetScene()
    local scene_obj = nx_value("scene_obj")
    if nx_is_valid(game_scene) and nx_is_valid(scene_obj) then
      local lst_nearplayer = game_scene:GetSceneObjList()
      for i, near_obj in pairs(lst_nearplayer) do
        scene_obj:ShowSceneObj(near_obj.Ident)
      end
    end
  end
  nx_set_value("entry_scene_success", true)
  return 1
end
function clear_all_form()
  local gui = nx_value("gui")
  local ballset = nx_value("balls")
  if nx_is_valid(ballset) then
    local balloon_list = ballset:GetBalloonList()
    gui:Delete(ballset)
  end
  local childlist = gui:GetAllFormList()
  if childlist == nil then
  else
    for i = 1, table.maxn(childlist) do
      local control = childlist[i]
      if nx_is_valid(control) and not nx_id_equal(control, gui.Desktop) then
        local script_name = nx_script_name(control)
        if script_name == "" then
          script_name = control.Name
        end
        control.Visible = true
        control:Close()
        if nx_is_valid(control) then
          gui:Delete(control)
        end
      end
    end
  end
  if nx_is_valid(gui.Desktop) then
    gui.Desktop:Close()
    gui.Desktop:DeleteAll()
    gui.Desktop.BackImage = ""
    nx_bind_script(gui.Desktop, "")
  end
  return 1
end
function kill_entry_stage_main()
  nx_kill("stage_main", "entry_stage_main")
  return 1
end
function send_dll_code()
  nx_function("ext_send_fxnet2_code")
  nx_function("ext_send_fxmotion_code")
end
