require("util_functions")
require("share\\logicstate_define")
require("role_composite")
require("const_define")
require("share\\chat_define")
local FADE_IN = 0
local FADE_OUT = 1
local FADE_APHOTIC = 2
local FADE_DICHROMATIC_IN = 3
local FADE_DICHROMATIC_OUT = 4
local PPDOF_DISABLE = 0
local PPDOF_ENABLE = 1
local PPDOF_CHANGE = 2
local BLUR_ENABLE = 1
local BLUR_DISABLE = 0
local MUSIC_STOP = 0
local MUSIC_PLAY = 1
local NOT_HAVE_MUSIC_SCENARIO_START = 2
local NOT_HAVE_MUSIC_SCENARIO_END = 3
local SCENARIO_PAUSE = false
local MUSIC_PATH = "mus\\music.ini"
local SOUND_PATH = "snd\\action\\"
function create_scene_npc(terrain, res_name, scene)
  local world = nx_value("world")
  if nil == scene then
    scene = nx_value("game_scene")
  end
  local actor2 = nx_null()
  if res_name ~= nil and string.len(res_name) > 0 then
    actor2 = create_actor2(scene)
    if not nx_is_valid(actor2) then
      return 0
    end
    actor2.AsyncLoad = true
    local result = load_from_ini(actor2, "ini\\" .. res_name .. ".ini")
    if not result then
      scene:Delete(actor2)
      nx_msgbox(get_msg_str("msg_434") .. nx_string(res_name))
      return nx_null()
    end
  end
  return actor2
end
function init(manager)
  nx_callback(manager, "on_npc_create", "on_npc_create")
  nx_callback(manager, "on_npc_delete", "on_npc_delete")
  nx_callback(manager, "on_npc_talk", "on_npc_talk")
  nx_callback(manager, "on_npc_sound", "on_npc_sound")
  nx_callback(manager, "on_before_scenario_end", "on_before_scenario_end")
  nx_callback(manager, "on_scenario_end", "on_scenario_end")
  nx_callback(manager, "on_scenario_pause", "on_scenario_pause")
  nx_callback(manager, "on_scenario_continue", "on_scenario_continue")
  nx_callback(manager, "timer_per_second", "on_timer_per_second")
  nx_callback(manager, "on_npc_point_begin", "on_npc_point_begin")
  nx_callback(manager, "on_npc_point_end", "on_npc_point_end")
  nx_callback(manager, "on_fade_change", "on_fade_change")
  nx_callback(manager, "on_ppdof_change", "on_ppdof_change")
  nx_callback(manager, "on_scene_effect", "on_scene_effect")
  nx_callback(manager, "delete_scene_effect", "delete_scene_effect")
  nx_callback(manager, "on_model_effect", "on_model_effect")
  nx_callback(manager, "on_scene_music", "on_scene_music")
  nx_callback(manager, "on_sound", "on_sound")
  nx_callback(manager, "on_scene_param", "on_scene_param")
  nx_callback(manager, "on_blur_change", "on_blur_change")
  nx_callback(manager, "on_scenario_start", "on_scenario_start")
  nx_callback(manager, "on_target_terrain_load_start", "on_target_terrain_load_start")
  nx_callback(manager, "on_target_terrain_load_end", "on_terrain_load_end")
  nx_callback(manager, "on_origin_terrain_load_end", "on_terrain_load_end")
end
function on_npc_create(manager, name, resource, nameid, info, isshow)
  local actor2 = create_scene_npc(manager.Terrain, resource)
  if not nx_is_valid(actor2) then
    return 1
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if nx_is_valid(actor2) then
    actor2.Color = "0,255,255,255"
    manager:SetNpcModel(name, actor2)
    if isshow then
      actor2.show_name = true
      actor2.name = nameid
    else
      actor2.name = name
    end
    actor2.info = info
    nx_execute("head_game", "create_client_npc_head", actor2)
  end
  return 1
end
function on_npc_delete(manager, name, model)
  local scene = nx_value("game_scene")
  if nx_is_valid(model) then
    scene:Delete(model)
  end
end
function on_npc_talk(manager, name, model, talk_id, show_head_to_chat)
  local gui = nx_value("gui")
  local wide_str = gui.TextManager:GetText(talk_id)
  local head_game = nx_value("HeadGame")
  if show_head_to_chat then
    local wide_str_name = gui.TextManager:GetText(name)
    wide_str = wide_str_name .. wide_str
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      form_main_chat_logic:AddChatInfoEx(wide_str, CHATTYPE_SYSTEM, false)
    end
  end
  if nx_is_valid(head_game) then
    head_game:ShowClientNpcChatTextOnHead(model, nx_widestr(wide_str), 5000)
  end
end
function on_npc_sound(manager, name, model, sound, loop, distance, loop_times)
  if not nx_is_valid(model) then
    return
  end
  loop_times = loop_times or 1
  nx_execute("util_sound", "play_link_sound", "npc\\" .. nx_string(sound), model, 0, 0, 0, 1, distance, loop_times)
end
function on_before_scenario_end(manager, file_name)
  nx_execute("form_stage_main\\form_movie_new", "before_scenario_end_callback", nx_string(file_name))
end
function on_scenario_end(manager, file_name, b_immediately)
  nx_execute("freshman_help", "end_animation", nx_string(file_name))
  nx_execute("npc_animation", "play_end_notice", nx_string(file_name))
  local form = nx_execute("util_gui", "util_get_form", "story_editor\\form_scenario_v3_play", false, false)
  if nx_is_valid(form) then
    nx_execute("story_editor\\form_add_client_npc", "on_scenario_end", nx_string(file_name))
    nx_execute("story_editor\\form_scenario_editor", "on_scenario_end", nx_string(file_name))
    nx_execute("story_editor\\form_scenario_v3_play", "on_scenario_end", nx_string(file_name))
  end
  nx_execute("form_stage_main\\form_movie_new", "scenario_end_callback", nx_string(file_name), b_immediately)
  delete_scene_effect(manager)
  if SCENARIO_PAUSE then
    SCENARIO_PAUSE = false
    nx_gen_event(manager, "SCENARIO_CONTINUE")
  end
end
function on_scenario_pause(manager, file_name)
  if not SCENARIO_PAUSE then
    SCENARIO_PAUSE = true
  end
end
function on_scenario_continue(manager, file_name)
  if SCENARIO_PAUSE then
    SCENARIO_PAUSE = false
    nx_gen_event(manager, "SCENARIO_CONTINUE")
  end
end
function on_timer_per_second(manager, file_name, time_count)
  local form = nx_execute("util_gui", "util_get_form", "story_editor\\form_scenario_v3_play", false, false)
  if nx_is_valid(form) then
    nx_execute("story_editor\\form_add_client_npc", "on_scenario_timer_per_second", nx_string(file_name))
    nx_execute("story_editor\\form_scenario_editor", "on_scenario_timer_per_second", nx_string(file_name))
    nx_execute("story_editor\\form_scenario_v3_play", "on_scenario_timer_per_second", nx_string(file_name), time_count)
  end
  nx_execute("form_stage_main\\form_movie_new", "scenario_per_second_callback", nx_string(file_name), nx_int(time_count))
end
function on_npc_point_begin(manager, file_name, action_index)
  nx_execute("freshman_help", "ani_step_begin_callback", file_name, action_index)
  nx_execute("npc_animation", "npc_ani_begin_callback", file_name, action_index)
end
function on_npc_point_end(manager, file_name, action_index)
  nx_execute("freshman_help", "ani_step_end_callback", file_name, action_index)
  nx_execute("npc_animation", "npc_ani_end_callback", file_name, action_index)
end
function on_fade_change(manager, file_name, flag, keep_time)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local ppfilter_uiparam = scene.ppfilter_uiparam
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(ppfilter_uiparam) or not nx_is_valid(postprocess_man) then
    return
  end
  if flag == FADE_DICHROMATIC_IN then
    local ppfilter = scene:Create("PPFilter")
    if not nx_is_valid(ppfilter) then
      return
    end
    postprocess_man:RegistPostProcess(ppfilter)
    ppfilter.AdjustEnable = true
    ppfilter.AdjustBaseColor = "255,255,255,255"
    ppfilter.AdjustBrightness = 50
    ppfilter.AdjustContrast = 0
    ppfilter.AdjustSaturation = 0
    manager.dich_ppfilter = ppfilter
    return
  elseif flag == FADE_DICHROMATIC_OUT then
    if nx_find_custom(manager, "dich_ppfilter") and nx_is_valid(manager.dich_ppfilter) then
      postprocess_man:UnregistPostProcess(manager.dich_ppfilter)
      scene:Delete(manager.dich_ppfilter)
    end
    return
  end
  if nx_find_custom(manager, "dich_ppfilter") and nx_is_valid(manager.dich_ppfilter) then
    postprocess_man:UnregistPostProcess(manager.dich_ppfilter)
    scene:Delete(manager.dich_ppfilter)
  end
  local ppfilter = scene:Create("PPFilter")
  if not nx_is_valid(ppfilter) then
    return
  end
  manager.dich_ppfilter = ppfilter
  postprocess_man:RegistPostProcess(ppfilter)
  ppfilter.AdjustEnable = true
  ppfilter.AdjustBaseColor = ppfilter_uiparam.hsi_basecolor
  ppfilter.AdjustBrightness = ppfilter_uiparam.hsi_brightness
  ppfilter.AdjustContrast = ppfilter_uiparam.hsi_contrast
  ppfilter.AdjustSaturation = ppfilter_uiparam.hsi_saturation
  local delay_time = 0
  local value = ppfilter_uiparam.hsi_brightness
  if flag == FADE_APHOTIC then
    nx_execute("custom_sender", "custom_scenario_black")
  end
  while true do
    if not (keep_time > delay_time) or not nx_is_valid(ppfilter) then
      break
    end
    if flag == FADE_OUT then
      ppfilter.AdjustBrightness = value * (1 - delay_time / keep_time)
    elseif flag == FADE_IN then
      ppfilter.AdjustBrightness = value * (delay_time / keep_time)
    elseif flag == FADE_APHOTIC then
      ppfilter.AdjustBrightness = 0
    end
    delay_time = delay_time + nx_pause(0.1)
    if flag == FADE_APHOTIC and SCENARIO_PAUSE then
      nx_wait_event(100000000, manager, "SCENARIO_CONTINUE")
    end
  end
  if nx_is_valid(ppfilter) then
    postprocess_man:UnregistPostProcess(ppfilter)
    scene:Delete(ppfilter)
  end
  return 1
end
function on_ppdof_change(manager, file_name, flag, arg1, arg2)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local ppdof_uiparam = scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if flag == PPDOF_ENABLE then
    manager.old_FocusDepth = ppdof_uiparam.focusdepth
    manager.old_BlurValue = ppdof_uiparam.blurvalue
    manager.old_MaxofBlur = ppdof_uiparam.maxofblur
    manager.old_dof_enable = game_config.dof_enable
    arg1 = arg1 or 0.6
    arg2 = arg2 or 2
    game_config.dof_enable = true
    ppdof_uiparam.blurvalue = nx_number(arg1)
    ppdof_uiparam.maxofblur = nx_number(arg2)
    ppdof_uiparam.focusdepth = 100
  elseif flag == PPDOF_DISABLE then
    ppdof_uiparam.focusdepth = manager.old_FocusDepth
    ppdof_uiparam.blurvalue = manager.old_BlurValue
    ppdof_uiparam.maxofblur = manager.old_MaxofBlur
    game_config.dof_enable = manager.old_dof_enable
  else
    ppdof_uiparam.focusdepth = arg1
  end
  nx_execute("game_config", "set_dof_enable", scene, game_config.dof_enable, false)
end
local effect_table = {}
local link_effect_table = {}
function on_scene_effect(manager, file_name, eff_name, x, y, z, loop, life_time, anglex, angley, anglez, speed)
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  if not (x and y) or not z then
    return
  end
  local eff = nx_execute("game_effect", "create_eff_model_in_mainscene", scene, eff_name, x, y, z)
  if not nx_is_valid(eff) then
    return
  end
  if anglex and angley and anglez then
    eff:SetAngle(nx_float(anglex), nx_float(angley), nx_float(anglez))
  end
  if loop then
    eff.Loop = true
  else
    eff.Loop = false
  end
  if life_time then
    eff.LifeTime = life_time
  end
  if speed then
    eff.Speed = speed
  end
  table.insert(effect_table, eff)
end
function delete_scene_effect(manager)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local postprocess_man = scene.postprocess_man
  if nx_is_valid(postprocess_man) and nx_find_custom(manager, "dich_ppfilter") and nx_is_valid(manager.dich_ppfilter) then
    postprocess_man:UnregistPostProcess(manager.dich_ppfilter)
    scene:Delete(manager.dich_ppfilter)
  end
  for i = 1, table.getn(effect_table) do
    if nx_is_valid(effect_table[i]) then
      nx_execute("game_effect", "delete_eff_model_in_mainscene", scene, effect_table[i])
    end
  end
  for i = 1, table.getn(link_effect_table) do
    if nx_is_valid(link_effect_table[i]) then
      nx_execute("game_effect", "delete_eff_model", scene, link_effect_table[i])
    end
  end
  effect_table = {}
  link_effect_table = {}
end
function on_model_effect(manager, name, model, effect_name, pointname, distance, speed)
  if not nx_is_valid(model) then
    return
  end
  local actor_role = model:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    model = actor_role
  end
  if not effect_name or not pointname then
    return
  end
  local eff = nx_execute("game_effect", "create_linktopoint_effect_by_target", effect_name, distance, model, pointname, 0, 0, 0, 0, 0, 0, 1, 1, 1)
  nx_pause(0)
  if not nx_is_valid(eff) then
    return
  end
  if speed ~= nil and nx_find_custom(eff, "Speed") then
    eff.Speed = speed
  end
  if name == "player" or name == "team_member0" then
    table.insert(link_effect_table, eff)
  end
end
function on_scene_music(manager, flag, music_name)
  console_log("[on_scene_music] flag=" .. nx_string(flag) .. " music=" .. nx_string(music_name))
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scenario_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_manager) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local sound_man = scene.sound_man
  if not nx_is_valid(sound_man) then
    return
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if not nx_is_valid(scene_music_play_manager) then
    return
  end
  local cur_music_name = scene_music_play_manager:GetGameMusicName()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_music = client_scene:QueryProp("Resource")
  if flag == MUSIC_PLAY then
    local volume = nx_number(game_config.music_volume) * nx_number(0.6)
    nx_execute("util_functions", "play_music", scene, "scene", music_name, 0, 1, true, volume)
  elseif flag == MUSIC_STOP then
    if cur_music_name == scene_music then
      return
    end
    nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_music)
  elseif flag == NOT_HAVE_MUSIC_SCENARIO_START then
    local music = scene_music_play_manager:GetGameMusic()
    if nx_is_valid(music) and nx_find_custom(music, "Volume") then
      music.Volume = nx_number(game_config.music_volume) * nx_number(0.4)
    end
  elseif flag == NOT_HAVE_MUSIC_SCENARIO_END then
    if cur_music_name == scene_music then
      local music = scene_music_play_manager:GetGameMusic()
      if not nx_is_valid(music) then
        return
      end
      if nx_is_valid(music) and nx_find_custom(music, "Volume") then
        music.Volume = game_config.music_volume
      end
    else
      nx_execute("util_functions", "play_scene_random_music", scene, "scene", scene_music)
    end
  end
end
function on_sound(manager, sound_name, file_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(nx_string(sound_name)) then
    gui:AddSound(nx_string(sound_name), nx_resource_path() .. SOUND_PATH .. nx_string(file_name))
  end
  gui:PlayingSound(nx_string(sound_name))
end
function on_scene_param(manager, file_path)
end
function on_blur_change(manager, file_name, state)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local scene = visual_player.scene
  if not nx_is_valid(scene) then
    return
  end
  if state == BLUR_ENABLE then
    local scenario_blur = nx_value("scenario_blur")
    if nx_is_valid(scenario_blur) then
      scenario_blur.Visible = true
      return
    end
    scene.EnableRealizeDepth = true
    scene.EnableRealizeVelocity = true
    scenario_blur = nx_create("PPMotionBlur")
    scenario_blur.DynamicBlur = true
    scenario_blur.StaticBlur = true
    scenario_blur.NumSamples = 8
    scenario_blur.MaxVelocity = 4
    scenario_blur.VelocityScale = 0.01
    scenario_blur:Load()
    scene.postprocess_man:RegistPostProcess(scenario_blur)
    scenario_blur.Visible = true
    nx_set_value("scenario_blur", scenario_blur)
    return
  elseif state == BLUR_DISABLE then
    local scenario_blur = nx_value("scenario_blur")
    if nx_is_valid(scenario_blur) then
      scene.postprocess_man:UnregistPostProcess(scenario_blur)
      nx_destroy(scenario_blur)
    end
    return
  end
end
function on_terrain_load_end(manager, scenario_name)
  local ini = nx_create("IniDocument")
  ini.FileName = scenario_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  local wait_terrain = ini:ReadString("system", "wait_terrain", "")
  if wait_terrain ~= "1" then
    return
  end
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local ppfilter_uiparam = scene.ppfilter_uiparam
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(ppfilter_uiparam) or not nx_is_valid(postprocess_man) then
    return
  end
  local ppfilter
  if nx_find_custom(manager, "wait_ppfilter") then
    ppfilter = manager.wait_ppfilter
  end
  if ppfilter == nil or not nx_is_valid(ppfilter) then
    ppfilter = scene:Create("PPFilter")
  end
  if not nx_is_valid(ppfilter) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  common_execute:RemoveExecute("terrain_load_end_fade_in", manager)
  common_execute:AddExecute("terrain_load_end_fade_in", manager, 0, ppfilter, nx_float(ppfilter_uiparam.hsi_brightness))
  nx_pause(3)
  postprocess_man:UnregistPostProcess(ppfilter)
  scene:Delete(ppfilter)
end
function on_target_terrain_load_start(manager, scenario_name)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(scenario_name)
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  local wait_terrain = ini:ReadString("system", "wait_terrain", "0")
  if wait_terrain ~= "1" then
    return
  end
  local role = nx_value("role")
  if not nx_is_valid(role) then
    return
  end
  local scene = role.scene
  if not nx_is_valid(scene) then
    return
  end
  local ppfilter_uiparam = scene.ppfilter_uiparam
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(ppfilter_uiparam) or not nx_is_valid(postprocess_man) then
    return
  end
  local ppfilter
  if nx_find_custom(manager, "wait_ppfilter") then
    ppfilter = manager.wait_ppfilter
  end
  if ppfilter == nil or not nx_is_valid(ppfilter) then
    ppfilter = scene:Create("PPFilter")
  end
  if not nx_is_valid(ppfilter) then
    return
  end
  postprocess_man:RegistPostProcess(ppfilter)
  ppfilter.AdjustEnable = true
  ppfilter.AdjustBaseColor = ppfilter_uiparam.hsi_basecolor
  ppfilter.AdjustBrightness = 0
  ppfilter.AdjustContrast = ppfilter_uiparam.hsi_contrast
  ppfilter.AdjustSaturation = ppfilter_uiparam.hsi_saturation
  manager.wait_ppfilter = ppfilter
end
function music_fade_out_end()
  local scenario_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_manager) then
    nx_gen_event(scenario_manager, "music_fade_out_end")
  end
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function on_scenario_start(manager, file_name)
end
