require("const_define")
require("util_gui")
require("define\\define")
require("form_stage_main\\form_home\\form_home_enter")
function gui_init(gui)
  gui.gui_close_allsystem_value = 0
  gui.ShowFPS = false
  gui:SetSupportShareTexFont(true)
  gui:AddShareTexFont(1, 20, 2048, 1024)
  gui:AddShareTexFont(20, 30, 512, 512)
  gui:AddDefaultFont()
  gui.skin_path = "skin\\"
  local databinder = nx_create("DataBinder")
  nx_set_value("data_binder", databinder)
  nx_call("entity_init", "cool_manager_init", gui.CoolManager)
  nx_bind_script(gui.HyperLinkManager, "hyperlink_manager", "hyperlink_manager_init")
  nx_bind_script(gui.AnimationManager, "image_animation_manager", "image_animation_manager_init")
  gui.CoolManager.AnimationMng = gui.AnimationManager
  local funcmanager = nx_create("FuncManager")
  funcmanager:LoadFuncItems(nx_resource_path() .. "ini\\function.xml")
  nx_set_value("func_manager", funcmanager)
  nx_callback(gui, "on_func_key", "gui_func_key")
  nx_callback(gui, "on_key_down", "gui_key_down")
  nx_callback(gui, "on_key_up", "gui_key_up")
  nx_callback(gui, "on_size", "win_size")
  nx_callback(gui, "on_restore", "gui_restore")
  nx_callback(gui, "on_minimize", "gui_minimize")
  nx_callback(gui, "on_maximize", "gui_maximize")
  nx_callback(gui, "on_close", "gui_close")
  nx_callback(gui, "on_play_sound", "gui_play_sound")
  nx_callback(gui, "on_active", "gui_active")
  nx_callback(gui, "on_unactive", "gui_unactive")
  nx_callback(gui, "on_whatever_key_down", "gui_whatever_key_down")
  nx_callback(gui, "on_show_hint", "on_show_hint")
  nx_callback(gui, "on_hide_hint", "on_hide_hint")
  gui.HintDelay = 0
  local label = gui:GetHint("Default")
  label.BackImage = "gui\\common\\form_back\\bg_menu.png"
  label.AutoSize = true
  label.DrawMode = "Expand"
  label.ForeColor = "255,255,255,255"
  label = gui:GetHint("TextHint")
  if nx_is_valid(label) then
    label.BackImage = "gui\\common\\form_back\\bg_menu.png"
    label.DrawMode = "Expand"
  end
  label = gui:GetHint("MultTextHint")
  if nx_is_valid(label) then
    label.BackImage = "gui\\common\\form_back\\bg_menu.png"
  end
  gui.TextManager.FloatNumber = 1
  local screen_width, screen_height = nx_function("ext_get_screen_size")
  gui.old_screen_width = screen_width
  gui.old_screen_height = screen_height
  gui.old_screen_frequency = nx_function("ext_get_cur_system_frequency")
  gui.TextManager.CheckRepeatID = true
  return 1
end
function init_money_FormatText(gui)
  gui.TextManager:AddConvertionFormatRule(nx_widestr("$"), 2, false, gui.TextManager:GetText("ui_bag_ding"), 1000000, gui.TextManager:GetText("ui_bag_liang"), 1000, gui.TextManager:GetText("ui_bag_wen"), 1)
end
function reload_text()
  local time = nx_function("ext_get_tickcount")
  local gui = nx_value("gui")
  gui.TextManager:Clear()
  local lang_path = nx_execute("util_functions", "get_language_path")
  gui.TextManager:LoadFiles(lang_path)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    gui.TextManager:SetText("Player", player:QueryProp("Name"))
  end
  time = nx_function("ext_get_tickcount") - time
  nx_msgbox("ReloadText = " .. nx_string(nx_int(time)))
end
function on_show_hint(control, hint_text, hint_type, x, y)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return 0
  end
  tips_manager:ShowTextTips(hint_text, x, y, -1, "0-0")
  return 1
end
function on_hide_hint(control)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return 0
  end
  tips_manager:HideTips("0-0")
  return 1
end
function gui_func_key(gui, key)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) and not game_visual.GameTest then
    return
  end
  if key == "F1" then
    local console = nx_value("console")
    if not nx_is_valid(console) then
      create_console()
    end
  elseif key == "F2" then
    local world = nx_value("world")
    if not world.DispWire and not world.BlackWhiteDiffuse then
      world.DispWire = true
      world.BlackWhiteDiffuse = false
    elseif world.DispWire and not world.BlackWhiteDiffuse then
      world.DispWire = false
      world.BlackWhiteDiffuse = true
    else
      world.DispWire = false
      world.BlackWhiteDiffuse = false
    end
  elseif key == "F3" then
    util_auto_show_hide_form("form_test\\form_scene_box_light")
    local world = nx_value("world")
    world:ReloadAllScript()
  elseif key == "F4" then
    gui.ShowFPS = true
    gui.ShowRenderInfo = not gui.ShowRenderInfo
    show_performance_form()
    add_render_info()
  elseif key == "F5" then
    util_auto_show_hide_form("form_test\\form_debug")
  elseif key == "F6" then
    util_auto_show_hide_form("effect_editor\\form_tool_bar_effect")
  elseif key == "F7" then
    reload_text()
  elseif key == "F8" then
    util_auto_show_hide_form("story_editor\\form_add_client_npc")
  elseif key == "F9" then
    local scene = nx_value("game_scene")
    local terrain = scene.terrain
    if not nx_find_custom(scene, "show_walk") then
      scene.show_walk = 1
    end
    scene.show_walk = (scene.show_walk + 1) % 3
    if nx_is_valid(terrain) then
      if scene.show_walk == 0 then
        terrain.ShowWalkable = false
        terrain.ShowSpaceHeight = false
      elseif scene.show_walk == 1 then
        terrain.ShowWalkable = true
        terrain.ShowSpaceHeight = false
      else
        terrain.ShowWalkable = true
        terrain.ShowSpaceHeight = true
      end
    end
  elseif key == "F;" then
    util_auto_show_hide_form("form_test\\form_camera")
  elseif key == "F<" then
    util_auto_show_hide_form("task_editor\\form_task_edit")
  end
  return 0
end
function gui_key_down(gui, key, shift, ctrl)
  if key == "Enter" or key == "Num Enter" then
    nx_execute("form_stage_create\\form_select_book", "enter_game")
  end
  if ctrl and nx_string(key) == "-" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) and game_visual.GameTest then
      util_auto_show_hide_form("form_stage_main\\form_match\\form_video_control")
    end
    return 0
  end
  if ctrl then
    nx_execute("form_stage_main\\form_clone\\form_clone_info", "ctrl_tip_open")
  end
  if key == "M" and ctrl then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) and game_visual.GameTest and nx_id_equal(gui.Desktop, gui.ModalForm) then
      local dialog = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_test\\form_edit_material.xml")
      dialog.tool_form_path = "form_common\\"
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "edit_material_return")
      if res == "cancel" then
        return 0
      end
      return 1
    end
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    return 0
  end
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_forgegame")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_connect")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_fortunetellinggame")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_jingmai")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_rps")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_handwriting", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_openlocker")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_openlocker", "on_key_down", key)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_openlocker_common")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_openlocker_common", "on_key_down", key)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_rope_swing")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_rope_swing", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form_talk) then
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_qingame")
  if nx_is_valid(form_talk) then
    return false
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_mini_qingame")
  if nx_is_valid(form_talk) then
    return false
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_zhujian")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_zhujian", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_zhujian_kaifeng")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_kaifeng", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_sjy_army")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_sjy_army", "game_key_down", gui, key, shift, ctrl)
    return true
  end
  form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    return true
  end
  local cur_stage = nx_value("stage")
  if key == "xxxxxxNum Lock" then
    if cur_stage == "login" then
      gui.ModalForm.Visible = not gui.ModalForm.Visible
    elseif cur_stage == "roles" then
      nx_execute("form_stage_roles\\form_roles", "auto_show_and_hide")
    elseif cur_stage == "create" then
      nx_execute("form_stage_create\\form_create", "auto_show_and_hide")
    else
      local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
      if b_relationship then
        nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
      end
      gui.Desktop.Visible = not gui.Desktop.Visible
      nx_execute("form_stage_main\\form_system\\form_system_Fight_info_Setting", "refresh_obj_head")
    end
  end
  if cur_stage ~= "main" then
    return 0
  end
  if key == "1" then
    cast_tool_skill(gui, 0)
  elseif key == "2" then
    cast_tool_skill(gui, 1)
  elseif key == "3" then
    cast_tool_skill(gui, 2)
  elseif key == "4" then
    cast_tool_skill(gui, 3)
  elseif key == "5" then
    cast_tool_skill(gui, 4)
  elseif key == "F2" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) and game_visual.GameTest then
      local world = nx_value("world")
      world:ReloadAllEffect()
    end
  elseif key == "F3" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) and game_visual.GameTest then
      nx_execute("util_gui", "util_auto_show_hide_form", "move_test\\form_collide_test")
    end
  elseif key == "F5" then
    nx_execute("custom_sender", "custom_use_qinggong", "qinggong_8")
  elseif key == "F6" then
    nx_execute("custom_sender", "custom_use_qinggong", "qinggong_9")
  elseif key == "F7" then
    nx_execute("custom_sender", "custom_use_qinggong", "qinggong_2")
  elseif key == "F8" then
    nx_execute("custom_sender", "custom_use_qinggong", "qinggong_11")
  end
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_small_game\\form_game_ride", "game_key_down", gui, key, shift, ctrl)
    return 1
  end
  nx_execute("form_stage_main\\form_battlefield_wulin\\wudao_util", "game_key_down", gui, key, shift, ctrl)
  nx_execute("form_stage_main\\form_taosha\\taosha_util", "game_key_down", gui, key, shift, ctrl)
  nx_execute("form_stage_main\\form_taosha\\apex_util", "game_key_down", gui, key, shift, ctrl)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) and game_visual.GameTest and key == "E" and ctrl and nx_is_debug() then
    local form = nx_value("test_action_form")
    if not nx_is_valid(form) then
      form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_test\\form_test_action.xml")
      form:Show()
      nx_set_value("test_action_form", form)
    end
  end
  if key == "`" then
    nx_execute("form_stage_main\\form_taosha\\form_taosha_map_scene", "show_or_hide_form")
  end
  return 0
end
function gui_key_up(gui, key, shift, ctrl)
  local form_clone_info = nx_value("form_stage_main\\form_clone\\form_clone_info")
  if nx_is_valid(form_clone_info) and not ctrl then
    nx_execute("form_stage_main\\form_clone\\form_clone_info", "ctrl_tip_close")
  end
  if key == "Esc" then
    local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
    if b_relationship then
      sns_close_form()
      return 1
    end
  end
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_game_openlocker")
  if nx_is_valid(form_talk) then
    nx_execute("form_stage_main\\form_small_game\\form_game_openlocker", "on_key_up", key)
    return true
  end
  local form_game_openlocker_common = nx_value("form_stage_main\\form_small_game\\form_game_openlocker_common")
  if nx_is_valid(form_game_openlocker_common) then
    nx_execute("form_stage_main\\form_small_game\\form_game_openlocker_common", "on_key_up", key)
    return true
  end
  return 0
end
function cast_tool_skill(gui, pos)
  local form = gui.Desktop
  if not nx_is_valid(form) then
    return false
  end
  local btn_name = "tool_skill_btn_" .. nx_string(pos)
  if not nx_find_custom(form, btn_name) then
    return false
  end
  local btn_id = nx_custom(form, btn_name)
  if not nx_is_valid(btn_id) then
    return false
  end
  nx_execute("form_stage_main\\form_main\\form_main", "tool_skill_btn_click", btn_id)
  return true
end
function win_size(gui, width, height)
  local game_config = nx_value("game_config")
  if nx_find_property(game_config, "set_display") and game_config.set_display then
    return
  end
  local world = nx_value("world")
  if width < world.MinDeviceWidth then
    width = world.MinDeviceWidth
  end
  if height < world.MinDeviceHeight then
    height = world.MinDeviceHeight
  end
  world.FixDeviceWidth = width
  world.FixDeviceHeight = height
  world:ResetDevice()
  gui_size(gui, width, height)
end
function gui_size(gui, width, height)
  local game_config = nx_value("game_config")
  local world = nx_value("world")
  local scale_enable = gui.ScaleEnable
  if scale_enable then
    gui.ScaleEnable = false
  end
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) and nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
    local water_table = scene.terrain:GetWaterList()
    for i = 1, table.getn(water_table) do
      if water_table[i].CubeMapStatic then
        water_table[i].CubeMapStatic = true
      end
    end
  end
  local desktop = gui.Desktop
  gui.ScaleEnable = scale_enable
  desktop.Width = gui.Width
  desktop.Height = gui.Height
  local cur_stage = nx_value("stage")
  if cur_stage == "login" then
    local login_form = nx_value("form_stage_login\\form_login")
    if nx_is_valid(login_form) then
      nx_execute("form_stage_login\\form_login", "change_form_size", login_form)
    end
  elseif cur_stage == "roles" or cur_stage == "create" then
    local hometown_form = nx_value("form_stage_create\\form_create")
    if nx_is_valid(hometown_form) then
      nx_execute("form_stage_create\\form_create", "change_create_size", hometown_form)
    end
    local form = nx_value("form_stage_create\\form_create_select_menpai")
    if nx_is_valid(form) then
      nx_execute("form_stage_create\\form_create_select_menpai", "change_form_size")
    end
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ChangeFormSize()
  end
  nx_execute("form_stage_main\\form_bag", "reset_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_map", "reset_form_size")
  nx_execute("form_stage_main\\form_life\\form_job_animation", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_light", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_panel", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_window", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_history", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_ad_setting", "change_form_size")
  nx_execute("form_stage_main\\form_chat_system\\form_chat_ad_edit", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "change_form_size")
  local form_karma_prize = nx_value("form_stage_main\\form_relation\\form_npc_karma_prize")
  if nx_is_valid(form_karma_prize) then
    nx_execute("form_stage_main\\form_relation\\form_npc_karma_prize", "change_form_size", form_karma_prize)
  end
  nx_execute("form_stage_main\\form_main\\form_laba_info", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "change_form_size")
  nx_execute("form_common\\form_loading", "change_form_size")
  nx_execute("form_stage_main\\form_close_scene", "change_form_size")
  nx_call("form_stage_main\\form_map\\form_map_scene", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_select", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_chat", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_trumpet", "change_form_size")
  nx_execute("form_stage_main\\form_world_trans_tool", "change_form_size")
  nx_execute("form_stage_main\\form_world_trans_tool", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_ride", "refresh_ride_shotcut_pos")
  nx_execute("form_stage_main\\form_FB_lead", "change_form_pos")
  nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_fightvs_alone_ex", "change_form_size")
  nx_execute("form_stage_main\\form_wuxue\\form_faculty_back", "change_form_size")
  nx_execute("form_stage_main\\form_wuxue\\form_team_faculty_setting", "change_form_size")
  nx_execute("form_stage_main\\form_wuxue\\form_team_faculty_dance", "change_form_size")
  nx_execute("form_stage_main\\form_wuxue\\form_team_faculty_member", "change_form_size")
  nx_execute("form_stage_main\\form_wuxue\\form_team_faculty_stat", "change_form_size")
  nx_execute("form_stage_main\\form_school_dance\\form_school_dance_member", "change_form_size")
  nx_execute("form_stage_main\\form_school_dance\\form_school_dance_key", "change_form_size")
  nx_execute("form_stage_main\\form_note\\form_note_wuxue_back", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_forgegame.lua", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_mini_qingame.lua", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_connect.lua", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_qingame.lua", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_fortunetellinggame", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_augurgame", "change_form_size")
  nx_execute("form_stage_main\\form_life\\form_fishing_op", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_picture", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_handwriting", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_ride", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_rope_swing", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_weiqi", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_wq", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_curseloading", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_breath_pro", "change_form_size")
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_chessnpc", "change_form_size")
  nx_execute("form_stage_main\\form_leitai\\form_challenge_lose", "change_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_buff", "change_form_size")
  nx_execute("form_stage_main\\form_task_findpath", "change_form_size")
  nx_execute("form_stage_main\\form_talk_movie", "change_form_size")
  nx_execute("form_stage_main\\form_relation\\form_avenge_watch", "change_form_size")
  nx_execute("form_stage_main\\form_scene_compete\\form_scene_compete", "change_form_size")
  nx_execute("form_stage_main\\form_life\\form_reclaim", "change_form_size")
  nx_execute("form_stage_main\\form_relation\\form_scene_jhpk_skill", "change_form_size")
  nx_execute("form_stage_main\\form_sworn\\form_sworn_info", "change_form_size")
  nx_execute("form_stage_main\\form_sworn\\form_main_sworn_skill", "change_form_size")
  nx_execute("form_stage_main\\form_force\\form_force_gumupai_srtx", "change_form_size")
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if nx_is_valid(form_movie_new) then
    local bShow = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
    if bShow then
      nx_execute("form_stage_main\\form_movie_new", "on_size_change", form_movie_new)
    end
  end
  local form_movie_effect = nx_value("form_stage_main\\form_movie_effect")
  if nx_is_valid(form_movie_effect) then
    local bEffectMovieShow = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_effect")
    if bEffectMovieShow then
      nx_execute("form_stage_main\\form_movie_effect", "on_size_change", form_movie_effect)
    end
  end
  nx_execute("form_stage_main\\form_movie_notice", "on_size_change")
  local form_intr = nx_value("form_stage_create\\form_book_introduce")
  if nx_is_valid(form_intr) then
    bShow = nx_execute("util_gui", "util_is_form_visible", "form_stage_create\\form_book_introduce")
    if bShow then
      nx_execute("form_stage_create\\form_book_introduce", "on_size_change", form_intr)
    end
  end
  local sel_book_form = nx_value("form_stage_create\\form_select_book")
  if nx_is_valid(sel_book_form) then
    nx_execute("form_stage_create\\form_select_book", "on_size_change", sel_book_form)
  end
  local role_form = nx_value("form_stage_roles\\form_roles")
  if nx_is_valid(role_form) then
    nx_execute("form_stage_roles\\form_roles", "on_info_size_change", role_form)
  end
  local form_task_trace = nx_value("form_stage_main\\form_task\\form_task_trace")
  if nx_is_valid(form_task_trace) then
    nx_execute("form_stage_main\\form_task\\form_task_trace", "refresh_trace_info", form_task_trace)
  end
  nx_execute("form_stage_main\\form_system\\form_system_option", "on_gui_size_change")
  nx_execute("form_stage_main\\form_system\\form_system_setting", "on_gui_size_change")
  nx_execute("form_stage_main\\form_system\\form_system_interface_setting", "on_gui_size_change")
  nx_execute("form_stage_main\\form_system\\form_system_interface_fightfreedom", "on_gui_size_change")
  nx_execute("form_stage_main\\form_system\\form_system_interface_guide", "on_gui_size_change")
  nx_execute("form_stage_main\\form_main\\form_main", "change_size")
  nx_execute("form_stage_main\\form_team\\form_team_recruit", "on_gui_size_change")
  nx_execute("form_stage_main\\form_equipblend", "on_gui_size_change")
  nx_execute("form_stage_main\\form_blendexhibit", "on_gui_size_change")
  nx_execute("form_stage_main\\form_blendpreview", "on_gui_size_change")
  nx_execute("form_stage_main\\form_clone_store\\form_clone_store", "on_gui_size_change")
  nx_execute("form_stage_main\\form_help\\form_help_control", "on_gui_size_change")
  nx_execute("form_stage_main\\form_help\\form_help_QingGong", "on_gui_size_change")
  nx_execute("form_stage_main\\form_help\\form_help_anqi01", "on_gui_size_change")
  nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "change_form_size")
  nx_execute("form_common\\form_revert_time", "on_gui_size_change")
  nx_execute("form_stage_main\\form_main\\form_main_select", "on_gui_size_change")
  nx_execute("form_stage_main\\form_tvt\\form_tvt_skill", "refurbish")
  local form_clone_awards = nx_value("form_stage_main\\form_clone_awards")
  if nx_is_valid(form_clone_awards) then
    nx_execute("form_stage_main\\form_clone_awards", "change_form_size", form_clone_awards)
  end
  local form_clone_awards_min = nx_value("form_stage_main\\form_clone_awards_min")
  if nx_is_valid(form_clone_awards_min) then
    nx_execute("form_stage_main\\form_clone_awards_min", "change_form_size", form_clone_awards_min)
  end
  nx_execute("form_stage_main\\form_main\\form_area_info", "on_size_change")
  nx_execute("form_stage_main\\form_relationship", "change_form_size")
  nx_execute("form_stage_main\\form_leitai\\form_leitai_gamble", "reset_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_request_right", "reset_form_size")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_trans", "refresh_ride_shotcut_pos")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "change_form_size")
  nx_execute("form_stage_main\\form_card\\form_card", "on_size_change")
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild", "on_size_change")
  nx_execute("form_stage_main\\form_camera\\form_save_camera_playing", "on_size_change")
  nx_execute("form_stage_main\\form_map\\form_map_scene_trans", "on_size_change")
  nx_execute("form_stage_main\\form_fight\\form_fight_main", "on_size_change")
  local form_advanced_weapon_and_origin = nx_value("form_stage_main\\form_advanced_weapon_and_origin")
  if nx_is_valid(form_advanced_weapon_and_origin) then
    nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "change_form_size")
  end
  nx_execute("form_stage_main\\form_huashan\\form_huashan_fight_main", "on_size_change")
  nx_execute("form_stage_main\\form_marry\\form_marry_util", "on_size_change")
  nx_execute("form_stage_main\\form_card\\form_card_skill", "on_gui_size_change")
  nx_execute("form_stage_main\\form_animalkeep\\form_sable_skill", "on_gui_size_change")
  nx_execute("form_stage_main\\form_ver_201904\\form_scene_form", "on_gui_size_change")
  nx_execute("form_stage_main\\form_marry\\form_marry_sns", "change_form_size")
  nx_execute("form_stage_main\\form_xmqy_detail", "change_form_size_change")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_fight", "change_form_size")
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_trace", "on_size_change")
  nx_execute("form_stage_main\\form_single_check", "on_size_change")
  nx_execute("form_stage_main\\form_freshman\\form_freshman_voice", "on_size_change")
  nx_execute("form_stage_main\\form_main\\form_school_introduce", "on_size_change")
  nx_execute("form_stage_main\\form_main\\form_main_fightvs_musical_note", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_shao_kao_game", "change_form_size")
  nx_execute("form_stage_main\\form_transfer_server", "change_form_size")
  nx_execute("form_stage_main\\form_sweet_employ\\form_sweet_sns", "change_form_size")
  nx_execute("form_stage_main\\form_home\\form_home_enter", "on_size_change")
  nx_execute("form_stage_main\\form_home\\form_home_function", "on_size_change")
  nx_execute("form_stage_main\\form_home\\form_home_model", "on_size_change")
  nx_execute("form_stage_main\\form_home\\form_home_myhome", "on_size_change")
  nx_execute("form_stage_main\\form_sweet_employ\\form_task_skill", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_openlocker", "on_size_change")
  nx_execute("form_stage_main\\form_small_game\\form_game_openlocker_common", "on_size_change")
  nx_execute("form_stage_main\\puzzle_quest\\form_game_whackegg", "on_size_change")
  nx_execute("form_stage_main\\form_attire\\form_attire_main", "change_form_size")
  nx_execute("form_stage_main\\form_attire\\form_attire_save", "change_form_size")
  nx_execute("form_stage_main\\form_huashan\\form_huashan_wuxue_canwu", "change_form_size")
  nx_execute("form_common\\form_play_video", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_songjing", "change_form_size")
  nx_execute("form_stage_main\\form_tongguanjiangli", "change_form_size_change")
  nx_execute("form_stage_main\\form_tongguanjiangli_five", "change_form_size_change")
  nx_execute("form_stage_main\\form_tongguanshibai", "change_form_size_change")
  nx_execute("form_stage_main\\form_small_game\\form_game_zhujian", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_qiaoda", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_cuihuo", "change_form_size")
  nx_execute("form_stage_main\\form_small_game\\form_game_zhujian_kaifeng", "change_form_size")
  nx_execute("form_stage_main\\form_shijia\\form_shijia_yanwu", "change_form_size")
  nx_execute("form_stage_main\\form_help\\form_help_qinggong_video", "change_form_size")
  nx_execute("form_stage_main\\form_world_auction\\form_boss_auction_drop", "change_form_size")
  nx_execute("form_stage_main\\form_taosha\\form_team_ts_succeed", "change_form_size")
  nx_execute("form_stage_main\\form_treasure_chest", "change_form_size")
  return 1
end
function scale_change()
  local form_task_time = nx_value("form_stage_main\\form_task\\form_task_time_limit")
  if nx_is_valid(form_task_time) then
    nx_execute("form_stage_main\\form_task\\form_task_time_limit", "reset_form_position", form_task_time)
  end
end
function gui_close(gui)
  local loading_flag = nx_value("loading")
  if loading_flag then
    return
  end
  local stage_main_flag = nx_value("stage_main")
  if nx_string(loading_flag) == nx_string("false") and nx_string(stage_main_flag) == nx_string("success") then
    local form = nx_value("breakconnect_form_confirm")
    if nx_is_valid(form) and nx_string(form.Visible) == nx_string(true) then
      nx_execute("main", "exit_game")
    else
      nx_execute("main", "exit_game")
    end
  else
    nx_execute("main", "exit_game")
  end
  return 1
end
function sound_mute()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local scene = nx_value("game_scene")
  if nx_is_valid(scene) then
    nx_execute("game_config", "set_logic_sound_volume", scene, 0, 0)
    nx_execute("game_config", "set_logic_sound_volume", scene, 1, 0)
    nx_execute("game_config", "set_logic_sound_volume", scene, 2, 0)
    nx_execute("game_config", "set_logic_sound_volume", scene, 3, 0)
  end
  local form = nx_value("form_stage_login\\form_login")
  if nx_is_valid(form) then
    form.video_1:Pause()
  end
end
function sound_volume_restore()
  local game_config = nx_value("game_config")
  local scene = nx_value("game_scene")
  if nx_is_valid(game_config) and nx_is_valid(scene) then
    nx_execute("game_config", "set_logic_sound_volume", scene, 0, game_config.area_music_volume)
    nx_execute("game_config", "set_logic_sound_volume", scene, 1, game_config.sound_volume)
    nx_execute("game_config", "set_logic_sound_volume", scene, 2, game_config.music_volume)
    nx_execute("game_config", "set_logic_sound_volume", scene, 3, game_config.sound_volume)
  end
  local form = nx_value("form_stage_login\\form_login")
  if nx_is_valid(form) then
    form.video_1:Play()
  end
end
function gui_restore(gui)
  sound_volume_restore()
  return 1
end
function gui_minimize(gui)
  sound_mute()
  return 1
end
function gui_maximize(gui)
  sound_volume_restore()
  return 1
end
function gui_active(gui)
  local world = nx_value("world")
  world.Sleep = world.sleep_value
  nx_function("ext_active_stickyhotkey", false)
  return 1
end
function on_sock_close()
  local form_talk = nx_value("form_stage_main\\form_small_game\\form_forgegame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_connect")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_fortunetellinggame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_augurgame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_qingame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  form_talk = nx_value("form_stage_main\\form_small_game\\form_mini_qingame")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function gui_unactive(gui)
  local world = nx_value("world")
  world.Sleep = world.sleep_value
  nx_function("ext_active_stickyhotkey", true)
  return 1
end
function gui_play_sound(gui, name, filename)
  nx_function("ext_play_gui_sound", name, filename)
  return 1
end
function create_console()
  local console = nx_create("Console")
  nx_bind_script(console, "console", "console_init")
  console.LogFile = "console.log"
  console:ClearLogFile()
  nx_set_value("console", console)
  return 1
end
function show_performance_form()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local performance_form = nx_value("performance_form")
  if gui.ShowRenderInfo then
    if not nx_is_valid(performance_form) then
      performance_form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. "form_test\\form_performance.xml")
      performance_form:Show()
      performance_form.close_btn.Visible = false
      nx_set_value("performance_form", performance_form)
    end
  elseif nx_is_valid(performance_form) then
    performance_form:Close()
  end
end
function add_render_info()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local line_count = 4
  local info = ""
  while nx_is_valid(gui) and gui.ShowRenderInfo do
    local device_caps = nx_value("device_caps")
    if not nx_is_valid(device_caps) then
      return 0
    end
    gui:ClearRenderInfo()
    local s = {
      "TotalVideoMemory = ",
      "FreeVideoMemory = ",
      "TotalAgpMemory = ",
      "FreeAgpMemory = "
    }
    local mem_table = device_caps:QueryVideoMemory()
    for i = 1, table.getn(mem_table) - (line_count - 1), line_count do
      info = ""
      for j = 0, line_count - 1 do
        info = info .. nx_string(s[i + j]) .. nx_decimals(mem_table[i + j], 2) .. "(M) "
      end
      gui:AddRenderInfo(info)
    end
    local remainder = math.fmod(table.getn(mem_table), line_count)
    if 0 < remainder then
      info = ""
      for i = table.getn(mem_table) - remainder + 1, table.getn(mem_table) do
        info = info .. "" .. nx_string(s[i]) .. nx_decimals(mem_table[i], 2) .. "(M) "
      end
      gui:AddRenderInfo(info)
    end
    local s2 = {
      "PageFaultCount = ",
      "PeakWorkingSetSize = ",
      "WorkingSetSize = ",
      "QuotaPeakPagedPoolUsage = ",
      "QuotaPagedPoolUsage = ",
      "QuotaPeakNonPagedPoolUsage = ",
      "QuotaNonPagedPoolUsage = ",
      "PagefileUsage = ",
      "PeakPagefileUsage = "
    }
    local mem_table = device_caps:QueryCurrentProcessMemory()
    for i = 1, table.getn(mem_table) - (line_count - 1), line_count do
      info = ""
      for j = 0, line_count - 1 do
        info = info .. nx_string(s2[i + j]) .. nx_decimals(mem_table[i + j], 2) .. "(M) "
      end
      gui:AddRenderInfo(info)
    end
    local remainder = math.fmod(table.getn(mem_table), line_count)
    if 0 < remainder then
      info = ""
      for i = table.getn(mem_table) - remainder + 1, table.getn(mem_table) do
        info = info .. "" .. nx_string(s2[i]) .. nx_decimals(mem_table[i], 2) .. "(M) "
      end
      gui:AddRenderInfo(info)
    end
    local mem_table = device_caps:QueryMemory()
    info = "MemoryLoad = " .. nx_string(mem_table[1]) .. "%"
    gui:AddRenderInfo(info)
    info = "TotalPhys = " .. nx_decimals(mem_table[2], 2) .. "(M) " .. "AvailPhys = " .. nx_decimals(mem_table[3], 2) .. "(M) " .. "UsedPhys = " .. nx_decimals(mem_table[2] - mem_table[3], 2) .. "(M)"
    gui:AddRenderInfo(info)
    info = "TotalPageFile = " .. nx_decimals(mem_table[4], 2) .. "(M) " .. "AvailPageFile = " .. nx_decimals(mem_table[5], 2) .. "(M) " .. "UsedPageFile = " .. nx_decimals(mem_table[4] - mem_table[5], 2) .. "(M)"
    gui:AddRenderInfo(info)
    info = "TotalVirtual = " .. nx_decimals(mem_table[6], 2) .. "(M) " .. "AvailVirtual = " .. nx_decimals(mem_table[7], 2) .. "(M) " .. "UsedVirtual = " .. nx_decimals(mem_table[6] - mem_table[7], 2) .. "(M)"
    gui:AddRenderInfo(info)
    nx_pause(1)
  end
  if nx_is_valid(gui) and not gui.ShowRenderInfo then
    gui:ClearRenderInfo()
  end
  return 1
end
function gui_whatever_key_down(gui, key, shift, control)
  local game_visual = nx_value("game_visual")
  if not game_visual.GameTest then
    return
  end
  if key == "F1" and not control then
    local bFocus = true
    local form_gm_command = nx_value("form_test\\form_gm_command")
    if not nx_is_valid(form_gm_command) then
      form_gm_command = nx_execute("util_gui", "util_get_form", "form_test\\form_gm_command", true, false)
      form_gm_command:Show()
      nx_set_value("form_test\\form_gm_command", form_gm_command)
    else
      nx_execute("util_gui", "util_auto_show_hide_form", "form_test\\form_gm_command")
      bFocus = form_gm_command.Visible
    end
    if bFocus then
      gui.Focused = form_gm_command.InputBox
    else
      gui.Focused = nx_null()
    end
  end
end
local cant_close_form_table_minigame = {
  "form_stage_main\\form_main\\form_main_map",
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_main\\form_main_buff",
  "form_stage_main\\form_main\\form_main_player",
  "form_stage_main\\form_relationship",
  "form_stage_main\\form_life\\form_fishing_op",
  "form_stage_main\\form_skyhill\\form_sanhill_fight"
}
local cant_close_form_table_all = {
  "form_stage_main\\form_relationship",
  "form_stage_main\\form_life\\form_fishing_op"
}
local cant_close_form_table_home = {
  "form_stage_main\\form_home\\form_home_model",
  "form_stage_main\\form_main\\form_main_trumpet",
  "form_stage_main\\form_home\\form_cease_meun",
  "form_stage_main\\form_helper\\form_main_helper",
  "form_stage_main\\form_chat_system\\form_chat_light",
  "form_stage_main\\form_main\\form_main_shortcut_extraskill",
  "form_stage_main\\form_main\\form_main_shortcut_buff_common",
  "form_stage_main\\form_main\\form_notice_shortcut"
}
local cant_close_form_table_facultyteam = {
  "form_stage_main\\form_relationship",
  "form_stage_main\\form_life\\form_fishing_op",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_main\\form_main_buff",
  "form_stage_main\\form_chat_system\\form_chat_light",
  "form_stage_main\\form_main\\form_main_trumpet",
  "form_stage_main\\form_main\\form_main_marry",
  "form_stage_main\\form_helper\\form_main_helper",
  "form_stage_main\\form_marry\\form_marry_btns",
  "form_stage_main\\form_common_notice",
  "form_stage_main\\form_main\\form_notice_shortcut"
}
local cant_open_form_table_all = {
  "form_stage_main\\form_main\\form_main_fightvs_alone",
  "form_stage_main\\form_main\\form_main_fightvs_musical_note"
}
local cant_open_form_home = {
  "form_stage_main\\form_main\\form_main_shortcut"
}
local control_close_table = {}
function gui_close_allsystem_form(closetype)
  local gui = nx_value("gui")
  gui.gui_close_allsystem_value = gui.gui_close_allsystem_value + 1
  if gui.gui_close_allsystem_value > 1 then
    return
  end
  local cant_close_form_table = cant_close_form_table_all
  if closetype == 1 then
    cant_close_form_table = cant_close_form_table_minigame
  elseif closetype == 2 then
    cant_close_form_table = cant_close_form_table_facultyteam
  elseif closetype == 3 then
    cant_close_form_table = cant_close_form_table_home
  end
  local childlist = gui.Desktop:GetChildControlList()
  for i = table.maxn(childlist), 1, -1 do
    local control = childlist[i]
    if nx_is_valid(control) and nx_is_kind(control, "Form") and control.Visible then
      local name = nx_script_name(control)
      local cant_close = false
      for k = 1, table.getn(cant_close_form_table) do
        if cant_close_form_table[k] == name then
          cant_close = true
          break
        end
      end
      if not cant_close and name ~= "form_stage_main\\form_system\\form_system_option" then
        if name == "form_stage_main\\form_map\\form_map_scene" then
          nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
        elseif name == "form_stage_main\\puzzle_quest\\form_puzzle_quest" then
          nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "hide_form")
        else
          control.Visible = false
        end
        table.insert(control_close_table, control)
      end
    end
  end
  local hides = table.getn(control_close_table)
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function gui_open_closedsystem_form()
  local gui = nx_value("gui")
  gui.gui_close_allsystem_value = gui.gui_close_allsystem_value - 1
  if gui.gui_close_allsystem_value > 0 then
    return
  end
  local homeid = get_current_homeid()
  for i = table.maxn(control_close_table), 1, -1 do
    local control = control_close_table[i]
    if nx_is_valid(control) and nx_is_kind(control, "Form") then
      local name = nx_script_name(control)
      local cant_open = true
      for k = 1, table.getn(cant_open_form_table_all) do
        if cant_open_form_table_all[k] == name then
          cant_open = false
          break
        end
      end
      if homeid ~= nx_string("") then
        for j = 1, table.getn(cant_open_form_home) do
          if cant_open_form_home[j] == name then
            cant_open = false
            break
          end
        end
      end
      if cant_open then
        if nx_find_custom(control, "cantopen") and control.cantopen == true then
          control.Visible = false
        else
          control.Visible = true
        end
      end
    end
  end
  control_close_table = {}
end
function is_empty_file(file_name)
  if file_name == nil or file_name == "" then
    return true
  end
  if string.find(file_name, "\\%.wav") ~= nil then
    return true
  end
  return false
end
function switch_gui()
  local cur_stage = nx_value("stage")
  local gui = nx_value("gui")
  if cur_stage == "login" then
    gui.ModalForm.Visible = not gui.ModalForm.Visible
  elseif cur_stage == "roles" then
    nx_execute("form_stage_roles\\form_roles", "auto_show_and_hide")
  elseif cur_stage == "create" then
    nx_execute("form_stage_create\\form_create", "auto_show_and_hide")
  else
    local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
    if b_relationship then
      nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
    end
    gui.Desktop.Visible = not gui.Desktop.Visible
    nx_execute("form_stage_main\\form_system\\form_system_Fight_info_Setting", "refresh_obj_head")
  end
end
function sns_close_form()
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  local num = table.getn(childlist)
  local control = childlist[num]
  if nx_is_valid(control) and nx_is_kind(control, "Form") then
    local name = nx_script_name(control)
    if control.Visible and name == "form_stage_main\\form_main\\form_main_chat" then
      control = childlist[num - 1]
    end
    if nx_is_valid(control) and nx_is_kind(control, "Form") and control.Visible then
      control:Close()
    end
  end
end
