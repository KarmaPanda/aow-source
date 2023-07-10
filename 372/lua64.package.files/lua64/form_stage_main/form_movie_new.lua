require("define\\object_type_define")
require("player_state\\state_input")
require("player_state\\logic_const")
require("role_composite")
require("share\\npc_type_define")
require("util_functions")
require("form_stage_main\\form_team\\team_util_functions")
CONTROLLER_TYPE_POS_X = 0
CONTROLLER_TYPE_POS_Y = 1
CONTROLLER_TYPE_POS_Z = 2
CONTROLLER_TYPE_ANGLE_X = 3
CONTROLLER_TYPE_ANGLE_Y = 4
CONTROLLER_TYPE_ANGLE_Z = 5
CONTROLLER_TYPE_FOV_X = 6
CONTROLLER_TYPE_FOV_Y = 7
CONTROLLER_TYPE_LIGHTNING_KEY = 8
CONTROLLER_TYPE_ACTION = 9
CONTROLLER_TYPE_SKY_ANGLE_Y = 10
CONTROLLER_TYPE_ACTION_KEY = 11
CONTROLLER_TYPE_AMBIENT_INTENSITY = 12
CONTROLLER_TYPE_SUNGLOW_INTENSITY = 13
CONTROLLER_TYPE_SPECULAR_INTENSITY = 14
CONTROLLER_TYPE_SUNHEIGHT = 15
CONTROLLER_TYPE_SUNAZIMUTH = 16
CONTROLLER_TYPE_FOCUSDEPTH = 17
CONTROLLER_TYPE_BLURVALUE = 18
CONTROLLER_TYPE_MAXOFBLUR = 19
CONTROLLER_TYPE_START_DEPTH = 20
CONTROLLER_TYPE_END_DEPTH = 21
CONTROLLER_TYPE_VISIBLE = 22
CONTROLLER_TYPE_BIND_OBJECT = 23
CONTROLLER_TYPE_WIND_SPEED = 24
CONTROLLER_TYPE_WIND_ANGLE = 25
CONTROLLER_TYPE_LIGHT_INTENSITY = 26
CONTROLLER_TYPE_FOG_DENSITY = 27
CONTROLLER_TYPE_FOG_START = 28
CONTROLLER_TYPE_FOG_END = 29
CONTROLLER_TYPE_FOG_HEIGHT = 30
CONTROLLER_TYPE_SKY_TEXTURE = 31
CONTROLLER_TYPE_COLOR_A = 32
CONTROLLER_TYPE_COLOR_R = 33
CONTROLLER_TYPE_COLOR_G = 34
CONTROLLER_TYPE_COLOR_B = 35
CONTROLLER_TYPE_SCALE_X = 36
CONTROLLER_TYPE_SCALE_Y = 37
CONTROLLER_TYPE_SCALE_Z = 38
CONTROLLER_TYPE_LIGHT_RANGE = 39
CONTROLLER_TYPE_SOUND = 40
CONTROLLER_TYPE_FOCUS_OBJECT = 41
CONTROLLER_TYPE_CHANGE_CAMERA = 42
CONTROLLER_TYPE_ALPHA = 43
CONTROLLER_TYPE_ALPHA_PPFILTER = 44
CONTROLLER_TYPE_EFFECT_DIE = 45
CONTROLLER_TYPE_MUSIC = 46
CONTROLLER_TYPE_SHOW_WORDS = 47
CONTROLLER_TYPE_SHAKE = 48
CONTROLLER_TYPE_UI_ANIMATION = 49
CONTROLLER_TYPE_WOBBLE_X = 50
CONTROLLER_TYPE_WOBBLE_Y = 51
CONTROLLER_TYPE_WOBBLE_Z = 52
CONTROLLER_TYPE_WOBBLE_F = 53
CONTROLLER_TYPE_WOBBLE_RX = 54
CONTROLLER_TYPE_WOBBLE_RY = 55
CONTROLLER_TYPE_WOBBLE_RZ = 56
CONTROLLER_TYPE_BLUR = 60
CONTROLLER_TYPE_GROUND_Y = 61
CONTROLLER_TYPE_ACTION_SPEED = 62
CONTROLLER_TYPE_GLOBLE_SPEED = 86
CONTROLLER_TYPE_POSITION_ANGLE = 100
local MAX_MOVIE_COUNT = 20000
local DEFAULT_DIST_CAMERA = 3
local MOVIE_OLD_FILE_TALK_PATH = "share\\Task\\Movie\\MovieTalkList.ini"
local MOVIE_OLD_FILE_INFO_PATH = "share\\Task\\Movie\\Movie.ini"
local MOVIE_BASE_PATH = "ini\\Movie\\"
local SCENARIO_BASE_PATH = "ini\\Scenario\\"
local control_table = {}
local players_table = {}
local npcs_table = {}
local movie_id_table = {}
local role_set = {
  man = 0,
  woman = 1,
  actor = 1,
  actor2 = 2
}
local hide_npc_table = {}
local movie_text_table = {}
local SPECIAL_MOVIE_MODE = 8
function clear_control_table()
  control_table = {}
end
function clear_movie_id_table()
  movie_id_table = {}
end
function clear_hide_npc_table()
  hide_npc_table = {}
end
function clear_movie_text_table()
  movie_text_table = {}
end
local INI_ITEM_MOVIE = "movie"
local INI_ITEM_TALK = "movie_talk_id"
local INI_ITEM_NPC = "hidenpc"
local INI_ITEM_CAMREA = "scenario_camera"
local KEY_CAMERA_PITCH = "endstate_pitch"
local KEY_CAMERA_DISTANCE = "endstate_distance"
local SYSTEM_SECTION_NAME = "system"
function main_form_init(self)
  self.Fixed = true
  self.is_edit_mode = false
  self.npcid = ""
  self.cur_index = 1
  self.cur_text = nx_widestr("")
  self.cur_sound = nx_null()
  self.show_text_speed = 0.1
  self.movie_id = 0
  self.movie_name = ""
  self.movie_type = 0
  self.is_control = 0
  self.movie_number = 0
  self.movie_name_ui = ""
  self.scenario_name = ""
  self.is_pause = 0
  self.movie_mode = 0
  self.team_member_idents = ""
  self.esc_key = false
  self.end_text_pause = true
  self.pause_before_end = false
  self.show_all_npc = false
  self.no_need_motion_alpha = true
  self.is_downing = false
  self.new_movie_words = ""
  self.select_object_id = ""
  self.first_person_camera_id = ""
  self.cant_break = 0
end
function on_main_form_open(form)
  form.mltbox_up.Visible = false
  form.mltbox_down.Visible = false
  close_movie()
  local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
  if b_relationship then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
  end
  local b_sweet_employ = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_main\\form_main_sweet_employ")
  if b_sweet_employ then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_main\\form_main_sweet_employ")
  end
  local voice_manager = nx_value("voice_manager")
  if nx_is_valid(voice_manager) then
    voice_manager:StopAll()
  end
  clear_control_table()
  clear_movie_id_table()
  clear_hide_npc_table()
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    form.dof_enable = game_config.dof_enable
    form.wide_angle = game_config.wide_angle
    form.area_music_enable = game_config.area_music_enable
    local scene = nx_value("game_scene")
    if nx_is_valid(scene) then
      nx_execute("game_config", "set_dof_enable", scene, false)
      nx_execute("game_config", "set_wide_angle", scene, false)
      nx_execute("game_config", "set_logic_sound_enable", scene, 0, false)
    end
  end
  if not init_movie(form) then
    end_movie()
    return
  end
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    nx_execute(nx_current(), "down_black_movie", form)
    form.Transparent = false
    form.mltbox_up.Visible = true
    form.mltbox_down.Visible = true
    form.Visible = true
  else
    form.mltbox_up.Visible = false
    form.mltbox_down.Visible = false
    form.Transparent = true
    form.Visible = false
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if HomeManager.ShowDesignLine then
    HomeManager.ShowDesignLine = false
  end
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetPlayer()
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) and nx_is_valid(role) then
    emit_player_input(role, PLAYER_INPUT_LOGIC, LOGIC_BEGIN_MOVIE)
  end
end
function on_main_form_close(form)
  if nx_find_custom(form, "cur_sound") and nx_is_valid(form.cur_sound) then
    if form.cur_sound.Playing then
      form.cur_sound:Stop()
    end
    nx_execute("util_sound", "delete_sound", form.cur_sound)
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    local scene = nx_value("game_scene")
    if nx_is_valid(scene) then
      nx_execute("game_config", "set_dof_enable", scene, form.dof_enable)
      nx_execute("game_config", "set_wide_angle", scene, form.wide_angle)
      nx_execute("game_config", "set_logic_sound_enable", scene, 0, form.area_music_enable)
    end
  end
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetPlayer()
  if nx_is_valid(role) and nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    emit_player_input(role, PLAYER_INPUT_LOGIC, LOGIC_END_MOVIE)
  end
  nx_destroy(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_pet = client_player:QueryProp("CurSweetPetNpc")
  if nx_string(cur_pet) ~= nx_string("") then
    nx_execute("form_stage_main\\form_main\\form_main_sweet_employ", "open_form", nx_string(cur_pet))
  end
end
function init_movie(form)
  local ret = true
  form.btn_top.Visible = false
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    hide_control()
    hide_around_player()
  end
  ret = on_size_change(form)
  ret = get_movie_info(form)
  form.esc_key = false
  form.show_all_npc = false
  if nx_int(form.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    form.show_all_npc = true
  end
  form.btn_end.Visible = false
  form.end_text_pause = true
  local file_path = SCENARIO_BASE_PATH .. form.scenario_name
  local scenario_ini = get_config_ini(form.is_edit_mode, file_path)
  if nx_is_valid(scenario_ini) then
    local sec_index = scenario_ini:FindSectionIndex(SYSTEM_SECTION_NAME)
    if 0 <= sec_index then
      local esc_key = scenario_ini:ReadString(sec_index, "esc_key", "")
      if esc_key == "1" then
        form.esc_key = true
      end
      local show_all_npc = scenario_ini:ReadString(sec_index, "show_all_npc", "")
      if show_all_npc == "1" then
        form.show_all_npc = true
      end
    end
  end
  if form.show_all_npc then
    hide_npc_in_table()
  else
    hide_npc()
  end
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    clear_movie_player_buffer_effect()
    clear_all_visual_head_show()
  end
  return ret
end
function down_black_movie(form)
  if not nx_is_valid(form) then
    return
  end
  set_control_before_black(form)
  form.is_downing = true
  while true do
    local sec = nx_pause(0.01)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_up.Top = nx_int(form.mltbox_up.Top + sec * 100)
    form.mltbox_down.Top = nx_int(form.mltbox_down.Top - sec * 100)
    if form.mltbox_up.Top >= 0 or form.mltbox_down.Top <= -form.mltbox_down.Height then
      form.mltbox_up.Top = 0
      form.mltbox_down.Top = -form.mltbox_down.Height
      break
    end
  end
  form.is_downing = false
  show_movie(form)
end
function hide_control()
  local gui = nx_value("gui")
  local childlist = gui.Desktop:GetChildControlList()
  for i = 1, table.maxn(childlist) do
    local control = childlist[i]
    if nx_is_valid(control) and nx_script_name(control) ~= "form_stage_main\\form_movie_new" and nx_script_name(control) ~= "form_stage_main\\form_main\\form_main_centerinfo" and control.Visible == true then
      control.Visible = false
      table.insert(control_table, control)
    end
  end
end
function add_hide_control(control)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if nx_int(form_movie_new.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    return
  end
  if nx_is_valid(control) then
    if control.Visible == true then
      control.Visible = false
    end
    table.insert(control_table, control)
  end
end
function del_control_from_hide_list(control)
  if not nx_is_valid(control) then
    return
  end
  for count = table.getn(control_table), 1, -1 do
    local temp_control = control_table[count]
    if nx_is_valid(temp_control) and nx_id_equal(temp_control, control) then
      table.remove(control_table, count)
    end
  end
end
function hide_around_player()
  players_table = get_around_player()
  for count = 1, table.getn(players_table) do
    if nx_is_valid(players_table[count]) then
      players_table[count].Visible = false
    end
  end
end
function hide_npc()
  local form_movie = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie) then
    return
  end
  if nx_find_custom(form_movie, "show_npc") and nx_int(form_movie.show_npc) == nx_int(1) then
    return
  end
  get_hide_npc_table()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  npcs_table = get_around_npc()
  for count = 1, table.getn(npcs_table) do
    local visual_npc = npcs_table[count]
    if nx_is_valid(visual_npc) then
      local client_ident = game_visual:QueryRoleClientIdent(visual_npc)
      local client_npc = game_client:GetSceneObj(nx_string(client_ident))
      if nx_is_valid(client_npc) then
        if not nx_ws_equal(nx_widestr(client_npc:QueryProp("Master")), nx_widestr(client_player:QueryProp("Name"))) and (client_npc:QueryProp("NpcType") ~= NpcType163 and client_npc:QueryProp("NpcType") ~= NpcType165 and client_npc:QueryProp("NpcType") ~= NpcType172 and client_npc:QueryProp("NpcType") ~= NpcType173 and client_npc:QueryProp("NpcType") ~= NpcType48 or is_hide_npc_by_configID(client_npc:QueryProp("ConfigID")) or is_player_offline(client_npc)) then
          visual_npc.Visible = false
          if client_npc:QueryProp("NpcType") == NpcType161 and nx_find_custom(visual_npc, "canpick") then
            local can_pick = visual_npc.canpick
            local effectname
            if can_pick then
              effectname = client_npc:QueryProp("AfterOpenEffect")
            else
              effectname = client_npc:QueryProp("BeforeOpenEffect")
            end
            nx_execute("game_effect", "remove_effect", effectname, visual_npc, visual_npc)
          end
        elseif client_npc:QueryProp("NpcType") == NpcType48 and form_movie.movie_type == 2 then
          visual_npc.Visible = false
        end
      end
    end
  end
end
function hide_npc_in_table()
  get_hide_npc_table()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  npcs_table = get_around_npc()
  for count = 1, table.getn(npcs_table) do
    local visual_npc = npcs_table[count]
    if nx_is_valid(visual_npc) then
      local client_ident = game_visual:QueryRoleClientIdent(visual_npc)
      local client_npc = game_client:GetSceneObj(nx_string(client_ident))
      if nx_is_valid(client_npc) and is_hide_npc_by_configID(client_npc:QueryProp("ConfigID")) then
        visual_npc.Visible = false
      end
    end
  end
end
function add_player_hide_list(visual_obj)
  if not nx_is_valid(visual_obj) then
    return
  end
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if nx_int(form_movie_new.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    return
  end
  visual_obj.Visible = false
  table.insert(players_table, visual_obj)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowHead(visual_obj, false)
  end
end
function add_npc_hide_list(visual_obj)
  if not nx_is_valid(visual_obj) then
    return
  end
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if nx_int(form_movie_new.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    return
  end
  visual_obj.Visible = false
  table.insert(npcs_table, visual_obj)
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ShowHead(visual_obj, false)
  end
  nx_execute("head_game", "cancel_npc_head_effect", visual_obj)
end
function show_control()
  for count = 1, table.getn(control_table) do
    if nx_is_valid(control_table[count]) and can_show_control(control_table[count]) then
      control_table[count].Visible = true
    end
  end
  control_table = {}
end
function can_show_control(control)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(control) or not nx_is_valid(player) then
    return false
  end
  local selectform = nx_value("form_stage_main\\form_main\\form_main_select")
  if nx_id_equal(selectform, control) then
    local lastobject = player:QueryProp("LastObject")
    if not nx_is_valid(lastobject) then
      return false
    end
  end
  return true
end
function show_around_player()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local main_player = game_visual:GetPlayer()
  local b_show_player = not game_visual.HidePlayer
  local game_client = nx_value("game_client")
  for count = 1, table.getn(players_table) do
    if nx_is_valid(players_table[count]) and (b_show_player or nx_id_equal(players_table[count], main_player)) then
      players_table[count].Visible = true
    end
  end
  players_table = {}
  nx_function("ext_hide_player_F9")
  nx_function("ext_hide_no_attack_player")
end
function show_npc()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  for count = 1, table.getn(npcs_table) do
    if nx_is_valid(npcs_table[count]) then
      local visual_npc = npcs_table[count]
      visual_npc.Visible = true
      local client_ident = game_visual:QueryRoleClientIdent(visual_npc)
      if client_ident ~= "" then
        local client_npc = game_client:GetSceneObj(client_ident)
        if nx_is_valid(client_npc) and client_npc:QueryProp("NpcType") == NpcType161 and nx_find_custom(visual_npc, "canpick") then
          local can_pick = visual_npc.canpick
          local effectname
          if can_pick then
            effectname = client_npc:QueryProp("AfterOpenEffect")
          else
            effectname = client_npc:QueryProp("BeforeOpenEffect")
          end
          create_effect(effectname, visual_npc, visual_npc, "", "", "", "", "", true)
        end
      end
    end
  end
  npcs_table = {}
end
function create_effect(effect_name, self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
  if effect_name == nil or nx_string(effect_name) == nx_string("") or nx_string(effect_name) == nx_string("nil") then
    return false
  end
  if not nx_is_valid(self) then
    return false
  end
  local scene = self.scene
  if not nx_is_valid(scene) then
    return false
  end
  local game_effect = scene.game_effect
  if not nx_is_valid(game_effect) then
    return false
  end
  if not nx_is_valid(game_effect.Scene) then
    game_effect.Scene = scene
  end
  if not nx_is_valid(game_effect.Terrain) then
    game_effect.Terrain = scene.terrain
  end
  return game_effect:CreateEffect(nx_string(effect_name), self, target, user_flag, action_name, self_client_ident, target_client_ident, visual_object, bshow)
end
function get_around_player()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  local visual_player_lst = {}
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) then
      local visual_player = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_player) then
        table.insert(visual_player_lst, visual_player)
      end
    end
  end
  return visual_player_lst
end
function get_around_npc()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  local visual_npc_lst = {}
  for i, client_obj in pairs(client_obj_lst) do
    if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
      local visual_npc = game_visual:GetSceneObj(client_obj.Ident)
      if nx_is_valid(visual_npc) then
        table.insert(visual_npc_lst, visual_npc)
      end
    end
  end
  return visual_npc_lst
end
function is_hide_npc_by_configID(configID)
  for count = 1, table.getn(hide_npc_table) do
    if nx_string(configID) == nx_string(hide_npc_table[count]) then
      return true
    end
  end
  return false
end
function on_size_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.btn_top.Left = gui.Width - 110
  form.btn_top.Top = gui.Height - 67
  form.btn_end.Left = gui.Width - 70
  form.btn_end.Top = gui.Height - 67
  form.mltbox_up.Width = gui.Width
  form.mltbox_down.Width = gui.Width
  local dHeight = gui.Height / 8
  form.mltbox_up.AbsTop = 0
  form.mltbox_up.Height = dHeight
  form.mltbox_down.AbsTop = gui.Height - dHeight
  form.mltbox_down.Height = dHeight
  local sWidth = 10
  local sHeight = 20
  local viewLeft = sWidth
  local viewTop = sHeight
  local viewWidth = form.mltbox_up.Width - 2 * sWidth
  local viewHeight = form.mltbox_up.Height - 2 * sHeight
  if viewHeight < 70 then
    viewHeight = 70
  end
  local viewRectStr = viewLeft .. "," .. viewTop .. "," .. viewWidth .. "," .. viewHeight
  form.mltbox_up.ViewRect = viewRectStr
  form.mltbox_down.ViewRect = viewRectStr
  return true
end
function get_movie_info(form)
  if not nx_is_valid(form) then
    return false
  end
  if nx_int(form.movie_id) > nx_int(0) and nx_int(form.movie_id) < nx_int(MAX_MOVIE_COUNT) then
    local file_path = MOVIE_OLD_FILE_INFO_PATH
    local movie_ini = nx_execute("util_functions", "get_ini", file_path)
    if not nx_is_valid(movie_ini) then
      return false
    end
    form.show_text_speed = 0.1
    local sec_index = movie_ini:FindSectionIndex(nx_string(form.movie_id))
    local show_text_speed = ""
    local movie_name = ""
    local pause_before_end = ""
    if 0 <= sec_index then
      show_text_speed = movie_ini:ReadString(sec_index, "ShowTextSpeed", "")
      movie_name = movie_ini:ReadString(sec_index, "MovieName", "")
      pause_before_end = movie_ini:ReadString(sec_index, "PauseBeforeEnd", "")
    end
    if show_text_speed ~= "" then
      show_text_speed = nx_number(show_text_speed)
      if form.show_text_speed >= 0.01 then
        form.show_text_speed = show_text_speed
      end
    end
    if pause_before_end ~= "" then
      form.pause_before_end = true
    end
    if nx_string(movie_name) == nx_string("") then
      return get_movie_info_by_movie_id(form)
    else
      form.movie_name = movie_name
      set_project_info(form)
      if tonumber(form.movie_mode) == 4 then
        return get_game_replay_by_movie_name(form)
      elseif tonumber(form.movie_mode) == SPECIAL_MOVIE_MODE then
        return get_special_replay_by_movie_name(form)
      else
        return get_movie_info_by_movie_name(form)
      end
    end
  else
    return get_movie_info_by_movie_name(form)
  end
  return false
end
function set_project_info(form)
  local str_path = nx_resource_path()
  local new_name = "ini\\quest\\" .. nx_string(form.movie_name) .. "\\project_info.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = str_path .. new_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  local sect_count = table.getn(sect_table)
  if sect_count < 1 then
    return false
  end
  form.show_npc = ini:ReadInteger(sect_table[1], "ShowNpc", 0)
end
function get_movie_info_by_movie_id(form)
  if not nx_is_valid(form) then
    return false
  end
  local file_path = MOVIE_OLD_FILE_TALK_PATH
  local movie_ini = nx_execute("util_functions", "get_ini", file_path)
  if not nx_is_valid(movie_ini) then
    return false
  end
  if not movie_ini:FindSection(nx_string(form.movie_id)) then
    return false
  end
  form.movie_type = 0
  form.is_control = 1
  local sec_index = movie_ini:FindSectionIndex(nx_string(form.movie_id))
  if 0 <= sec_index then
    local talk_text_table = movie_ini:GetItemValueList(sec_index, "r")
    for i = 1, table.getn(talk_text_table) do
      local tmp_table = nx_function("ext_split_string", nx_string(talk_text_table[i]), nx_string(","))
      table.insert(movie_id_table, nx_string(tmp_table[1]))
    end
  end
  return true
end
function get_movie_info_by_movie_name(form)
  if not nx_is_valid(form) then
    return false
  end
  local file_path = MOVIE_BASE_PATH .. form.movie_name
  local movie_ini = get_config_ini(form.is_edit_mode, file_path)
  if not nx_is_valid(movie_ini) then
    return false
  end
  local sec_index = movie_ini:FindSectionIndex(INI_ITEM_MOVIE)
  local movie_type = ""
  local scenario_name = ""
  local movie_number = ""
  local movie_name_ui = ""
  if 0 <= sec_index then
    movie_type = movie_ini:ReadString(sec_index, "type", "")
    scenario_name = movie_ini:ReadString(sec_index, "scenario", "")
    movie_number = movie_ini:ReadString(sec_index, "id", "")
    movie_name_ui = movie_ini:ReadString(sec_index, "name", "")
  end
  if nx_string(movie_type) == nx_string("0") then
    form.is_control = 1
  elseif nx_string(movie_type) == nx_string("1") then
    form.is_control = 0
  else
    return false
  end
  form.movie_type = tonumber(movie_type)
  form.scenario_name = tostring(scenario_name)
  form.movie_number = tonumber(movie_number)
  form.movie_name_ui = tostring(movie_name_ui)
  get_hide_npc_table()
  get_movie_talk_table(form)
  return true
end
function set_control_before_black(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_up.VAnchor = "Top"
  form.mltbox_down.VAnchor = "Bottom"
  form.mltbox_up.Top = -form.mltbox_up.Height
  form.mltbox_down.Top = 0
end
function get_hide_npc_table()
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  local file_path = MOVIE_BASE_PATH .. form_movie_new.movie_name
  local movie_ini = get_config_ini(form_movie_new.is_edit_mode, file_path)
  if not nx_is_valid(movie_ini) then
    return
  end
  local sec_index = movie_ini:FindSectionIndex(INI_ITEM_NPC)
  if 0 <= sec_index then
    hide_npc_table = movie_ini:GetItemValueList(sec_index, "r")
  end
end
function get_movie_talk_table(form)
  if not nx_is_valid(form) then
    return
  end
  if form.movie_type == 0 then
    get_table_movie_type_0(form)
  elseif form.movie_type == 1 then
    get_table_movie_type_1(form)
  end
end
function get_table_movie_type_0(form)
  if not nx_is_valid(form) then
    return
  end
  local file_path = MOVIE_BASE_PATH .. form.movie_name
  local movie_ini = get_config_ini(form.is_edit_mode, file_path)
  if not nx_is_valid(movie_ini) then
    return
  end
  local sec_index = movie_ini:FindSectionIndex(INI_ITEM_TALK)
  if 0 <= sec_index then
    movie_id_table = movie_ini:GetItemValueList(sec_index, "r")
  end
end
function get_table_movie_type_1(form)
  if not nx_is_valid(form) then
    return
  end
  local file_path = SCENARIO_BASE_PATH .. form.scenario_name
  local scenario_ini = get_config_ini(form.is_edit_mode, file_path)
  if not nx_is_valid(scenario_ini) then
    return
  end
  local tmp_table = {}
  local max_talk_num = 100
  for count = 1, max_talk_num do
    local key = "r" .. tostring(count - 1)
    local sec_index = scenario_ini:FindSectionIndex(INI_ITEM_TALK)
    local value = ""
    if 0 <= sec_index then
      value = scenario_ini:ReadString(sec_index, key, "")
    end
    if nx_string(value) == nx_string("") then
      break
    end
    table.insert(tmp_table, value)
  end
  for count = 1, table.getn(tmp_table) do
    local split_tmp_table_1 = nx_function("ext_split_string", nx_string(tmp_table[count]), nx_string(","))
    if table.getn(split_tmp_table_1) >= 3 then
      local sound_info = ""
      if table.getn(split_tmp_table_1) >= 4 then
        sound_info = split_tmp_table_1[4]
      end
      if tonumber(split_tmp_table_1[3]) == 0 then
        local tmp_str = split_tmp_table_1[1] .. "," .. split_tmp_table_1[2] .. ",0,0,0," .. sound_info
        table.insert(movie_id_table, tostring(tmp_str))
      elseif tonumber(split_tmp_table_1[3]) == 1 then
        local split_tmp_table_2 = nx_function("ext_split_string", nx_string(split_tmp_table_1[2]), nx_string("|"))
        local sound_table = util_split_string(nx_string(sound_info), "|")
        for count_2 = 1, table.getn(split_tmp_table_2) do
          local tmp_str = tostring(split_tmp_table_1[1]) .. "," .. split_tmp_table_2[count_2] .. ",1"
          local sound = sound_table[count_2] == nil and "" or sound_table[count_2]
          if count_2 == table.getn(split_tmp_table_2) then
            tmp_str = tmp_str .. ",0,0," .. sound
          else
            tmp_str = tmp_str .. ",1,0," .. sound
          end
          table.insert(movie_id_table, tmp_str)
        end
      elseif tonumber(split_tmp_table_1[3]) == 2 then
        local tmp_str = split_tmp_table_1[1] .. "," .. split_tmp_table_1[2] .. ",0,0,1," .. sound_info
        table.insert(movie_id_table, tostring(tmp_str))
      end
    end
  end
end
function show_movie(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local player_visual = game_visual:GetPlayer()
  if not nx_is_valid(player_visual) then
    return
  end
  if form.movie_type == 0 then
    show_movie_camera(form)
    show_movie_text(form)
  elseif form.movie_type == 1 then
    local scenario_manager = nx_value("scenario_npc_manager")
    if not nx_is_valid(scenario_manager) then
      end_movie()
      return
    end
    if form.scenario_name == "" then
      end_movie()
      return
    end
    local anifile = nx_resource_path() .. "ini\\Scenario\\" .. nx_string(form.scenario_name)
    show_movie_scenario_camera()
    if tonumber(form.movie_mode) == 1 then
      scenario_manager:ClearTeamMember()
      local player_client_ident = game_visual:QueryRoleClientIdent(player_visual)
      local main_player_visual = create_teammember_model(player_client_ident)
      if nx_is_valid(main_player_visual) then
        scenario_manager:AddTeamMemberModel(main_player_visual)
      end
      local other_player_table = nx_function("ext_split_string", form.team_member_idents, "|")
      for count = 1, table.getn(other_player_table) do
        local other_player_ident = nx_string(other_player_table[count])
        if other_player_ident ~= nx_string(player_client_ident) then
          local other_player_visual = create_teammember_model(other_player_ident)
          if nx_is_valid(other_player_visual) then
            scenario_manager:AddTeamMemberModel(other_player_visual)
          end
        end
      end
    elseif tonumber(form.movie_mode) == 3 then
      scenario_manager:ClearTeamMember()
      local other_player_table = nx_function("ext_split_string", form.team_member_idents, "|")
      for count = 1, table.getn(other_player_table) do
        local other_player_ident = nx_string(other_player_table[count])
        local other_player_visual = create_teammember_model(other_player_ident)
        if nx_is_valid(other_player_visual) then
          scenario_manager:AddTeamMemberModel(other_player_visual)
        end
      end
    elseif tonumber(form.movie_mode) == 5 then
      local role = nx_value("role")
      if nx_is_valid(role) and role.Visible then
        role.Visible = false
      end
      scenario_manager:ClearTeamMember()
      local player_client_ident = game_visual:QueryRoleClientIdent(player_visual)
      local main_player_visual = create_teammember_model(player_client_ident)
      if nx_is_valid(main_player_visual) then
        scenario_manager:AddTeamMemberModel(main_player_visual)
      end
      local other_player_table = nx_function("ext_split_string", form.team_member_idents, "|")
      for count = 1, table.getn(other_player_table) do
        local other_player_ident = nx_string(other_player_table[count])
        if other_player_ident ~= nx_string(player_client_ident) then
          local other_player_visual = create_teammember_model(other_player_ident)
          if nx_is_valid(other_player_visual) then
            scenario_manager:AddTeamMemberModel(other_player_visual)
          end
        end
      end
    elseif tonumber(form.movie_mode) == 6 then
      local role = nx_value("role")
      if nx_is_valid(role) and role.Visible then
        role.Visible = false
      end
      scenario_manager:ClearTeamMember()
      local player_client_ident = game_visual:QueryRoleClientIdent(player_visual)
      local main_player_visual = create_teammember_model(player_client_ident)
      if nx_is_valid(main_player_visual) then
        scenario_manager:AddTeamMemberModel(main_player_visual)
      end
      local other_player_table = nx_function("ext_split_string", form.team_member_idents, "|")
      for count = 1, table.getn(other_player_table) do
        local other_player_ident = nx_string(other_player_table[count])
        if other_player_ident ~= nx_string(player_client_ident) then
          local other_player_visual = create_teammember_model(other_player_ident)
          if nx_is_valid(other_player_visual) then
            scenario_manager:AddTeamMemberModel(other_player_visual)
          end
        end
      end
    elseif tonumber(form.movie_mode) == 2 then
      local vip_player_visual = create_teammember_model(form.team_member_idents)
      if nx_is_valid(vip_player_visual) then
        scenario_manager:SetVipPlayerModel(vip_player_visual)
      else
        end_movie()
        return
      end
    end
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) and client_player:FindProp("CurSweetPetNpc") then
      local game_visual = nx_value("game_visual")
      local visual_npc = game_visual:GetSceneObj(nx_string(client_player:QueryProp("CurSweetPetNpc")))
      scenario_manager.SweetPet = visual_npc
    end
    if not scenario_manager:PlayScenario(anifile) then
      end_movie()
    end
  else
    start_time_axis(form)
  end
  nx_execute("custom_sender", "custom_select_cancel")
end
function create_teammember_model(ident)
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetSceneObj(nx_string(ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  local scene = nx_value("game_scene")
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local other_player_visual = role_composite:CreateSceneObjectWithSubModel(scene, client_obj, false, false, false)
  if not nx_is_valid(other_player_visual) then
    return nx_null()
  end
  return other_player_visual
end
function clear_movie_text()
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if nx_running(nx_current(), "form_movie_tick") then
    nx_kill(nx_current(), "form_movie_tick")
  end
  form_movie_new.btn_top.Visible = false
  form_movie_new.btn_end.Visible = false
  form_movie_new.mltbox_down:Clear()
end
function clear_animation_form()
  local gui = nx_value("gui")
  local child_list = gui.Desktop:GetChildControlList()
  for i = table.maxn(child_list), 1, -1 do
    local control = child_list[i]
    if nx_is_valid(control) then
      local script = nx_script_name(control)
      if string.find(script, "form_stage_main\\form_school_war\\form_school_join") then
        control.Visible = false
        control:Close()
      end
    end
  end
end
function end_movie(b_immediately)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  clear_movie_text()
  clear_animation_form()
  if b_immediately == nil or b_immediately == false then
    while true do
      local sec = nx_pause(0.01)
      if not nx_is_valid(form_movie_new) then
        return
      end
      form_movie_new.mltbox_up.Top = nx_int(form_movie_new.mltbox_up.Top - sec * 100)
      form_movie_new.mltbox_down.Top = nx_int(form_movie_new.mltbox_down.Top + sec * 100)
      if form_movie_new.mltbox_up.Top <= -form_movie_new.mltbox_up.Height or form_movie_new.mltbox_down.Top >= 0 then
        form_movie_new.mltbox_up.Top = -form_movie_new.mltbox_up.Height
        form_movie_new.mltbox_down.Top = 0
        break
      end
    end
  end
  if nx_int(form_movie_new.movie_id) > nx_int(0) then
    nx_execute("custom_sender", "custom_movie_end", form_movie_new.movie_id)
  end
  if nx_int(form_movie_new.movie_mode) ~= nx_int(4) and nx_int(form_movie_new.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    end_movie_camera()
  end
  show_control()
  show_around_player()
  show_npc()
  resume_all_visual_head_show()
  form_movie_new:Close()
  nx_execute("freshman_help", "movie_end_callback")
  nx_execute("stage_main", "show_continue_obj")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    local buffer_effect = nx_value("BufferEffect")
    buffer_effect:UpdateBufferEffect(player.Ident)
  end
end
function show_movie_text(form)
  if not nx_is_valid(form) then
    return
  end
  if form.cur_index < 1 or form.cur_index > table.getn(movie_id_table) then
    end_movie()
    return
  end
  local gui = nx_value("gui")
  local str = movie_id_table[form.cur_index]
  form.cur_index = form.cur_index + 1
  local show_text
  clear_movie_text_table()
  if form.movie_type == 0 then
    form.btn_top.Visible = true
    show_text = gui.TextManager:GetText(str)
    movie_text_table = nx_function("ext_movie_text_split_string", show_text)
  elseif form.movie_type == 1 then
    local tmp_table = nx_function("ext_split_string", nx_string(str), nx_string(","))
    show_text = gui.TextManager:GetText(tmp_table[2])
    local game_client = nx_value("game_client")
    if nx_is_valid(game_client) then
      local player = game_client:GetPlayer()
      local name = player:QueryProp("Name")
      local result = nx_function("ext_movie_replace_player_name", show_text, name)
      if table.getn(result) > 0 then
        show_text = result[1]
      end
    end
    if table.getn(tmp_table) >= 5 then
      if tonumber(tmp_table[3]) == 1 then
        form.btn_top.Visible = true
        if tonumber(tmp_table[4]) == 1 then
          form.end_text_pause = true
        else
          form.end_text_pause = false
        end
      else
        form.btn_top.Visible = false
      end
      if tonumber(tmp_table[5]) == 0 then
        movie_text_table = nx_function("ext_movie_text_split_string", show_text)
      else
        table.insert(movie_text_table, show_text)
      end
    else
      movie_text_table = nx_function("ext_movie_text_split_string", show_text)
    end
    if table.getn(tmp_table) >= 6 and tmp_table[6] ~= "" then
      play_movie_text_sound(form, tmp_table[6])
    end
  else
    end_movie()
    return
  end
  form.cur_text = nx_widestr("")
  if nx_running(nx_current(), "form_movie_tick") then
    nx_kill(nx_current(), "form_movie_tick")
  end
  nx_execute(nx_current(), "form_movie_tick")
end
function form_movie_tick()
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if table.getn(movie_text_table) == 0 then
    return
  end
  local pause_time = 0.1
  if nx_find_custom(form_movie_new, "show_text_speed") then
    pause_time = form_movie_new.show_text_speed
  end
  while true do
    local sec = nx_pause(pause_time)
    if not nx_is_valid(form_movie_new) then
      break
    end
    if table.getn(movie_text_table) == 0 then
      movie_text_end_callback()
      break
    end
    form_movie_new.cur_text = form_movie_new.cur_text .. movie_text_table[1]
    table.remove(movie_text_table, 1)
    form_movie_new.mltbox_down:Clear()
    local index = form_movie_new.mltbox_down:AddHtmlText(nx_widestr(form_movie_new.cur_text), -1)
    form_movie_new.mltbox_down:SetHtmlItemSelectable(nx_int(index), false)
    if table.getn(movie_text_table) == 0 then
      movie_text_end_callback()
      break
    end
  end
end
function scenario_per_second_callback(file_name, count)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if form_movie_new.esc_key and not form_movie_new.btn_end.Visible then
    form_movie_new.btn_end.Visible = true
  end
  if form_movie_new.movie_type ~= 1 then
    return
  end
  if 1 > form_movie_new.cur_index or form_movie_new.cur_index > table.getn(movie_id_table) then
    return
  end
  local str = movie_id_table[form_movie_new.cur_index]
  local str_table = nx_function("ext_split_string", nx_string(str), nx_string(","))
  if table.getn(str_table) < 3 then
    return
  end
  if nx_int(count) ~= nx_int(str_table[1]) then
    return
  end
  local pause = tonumber(str_table[3])
  if pause == 1 and form_movie_new.is_pause == 0 then
    local scenario_manager = nx_value("scenario_npc_manager")
    if not nx_is_valid(scenario_manager) then
      end_movie()
      return
    end
    scenario_manager:PauseScenario()
    form_movie_new.is_control = 1
    form_movie_new.is_pause = 1
  end
  show_movie_text(form_movie_new)
  local b_origin = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_origin\\form_origin")
  if b_origin then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_origin\\form_origin")
  end
end
function before_scenario_end_callback(file_name)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if form_movie_new.movie_type ~= 1 then
    return
  end
  if nx_int(form_movie_new.movie_id) == nx_int(0) then
    return
  end
  if form_movie_new.pause_before_end then
    local scenario_manager = nx_value("scenario_npc_manager")
    if nx_is_valid(scenario_manager) then
      scenario_manager:PauseScenario()
      nx_execute("custom_sender", "custom_before_movie_end", form_movie_new.movie_id)
    end
  end
end
function scenario_end_callback(file_name, b_immediately)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    show_control()
    show_around_player()
    show_npc()
    return
  end
  if form_movie_new.movie_type ~= 1 and form_movie_new.movie_type ~= 5 and form_movie_new.movie_type ~= 6 then
    show_control()
    show_around_player()
    show_npc()
    return
  end
  end_movie(b_immediately)
end
function on_btn_top_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if table.getn(movie_text_table) == 0 then
    if form.is_control == 1 then
      show_movie_text(form)
    end
  else
    for count = 1, table.getn(movie_text_table) do
      form.cur_text = form.cur_text .. movie_text_table[count]
    end
    movie_text_table = {}
    form.mltbox_down:Clear()
    local index = form.mltbox_down:AddHtmlText(nx_widestr(form.cur_text), -1)
    form.mltbox_down:SetHtmlItemSelectable(nx_int(index), false)
    if not form.end_text_pause then
      form.btn_top.Visible = false
    end
  end
end
function movie_text_end_callback()
  form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  local movie_text_index = form_movie_new.cur_index - 1
  if movie_text_index < 1 or movie_text_index > table.getn(movie_id_table) then
    return
  end
  if form_movie_new.movie_type == 0 then
  elseif form_movie_new.movie_type == 1 then
    local str = movie_id_table[movie_text_index]
    local str_table = nx_function("ext_split_string", nx_string(str), nx_string(","))
    if table.getn(str_table) < 4 then
      return
    end
    if tonumber(str_table[4]) == 0 and form_movie_new.is_pause == 1 then
      local scenario_manager = nx_value("scenario_npc_manager")
      if not nx_is_valid(scenario_manager) then
        end_movie()
        return
      end
      scenario_manager:ContinueScenario()
      form_movie_new.is_control = 0
      form_movie_new.is_pause = 0
    end
  else
    end_movie()
  end
end
function show_movie_camera(form_movie_new)
  if not nx_is_valid(form_movie_new) then
    return
  end
  local game_visual = nx_value("game_visual")
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = 2
  game_control.CameraCollide = false
  local visual_player = game_visual:GetPlayer()
  local visual_npc = game_visual:GetSceneObj(nx_string(form_movie_new.npcid))
  if nx_is_valid(visual_npc) then
    face_to_face(visual_player, visual_npc)
  else
  end
  local camera_story = game_control:GetCameraController(2)
  if nx_is_valid(camera_story) then
    camera_story.StartPlayerMove = true
  end
  game_control.Distance = DEFAULT_DIST_CAMERA
  game_control.PitchAngle = math.pi / 12
  game_control.YawAngle = visual_player.AngleY
end
function show_movie_scenario_camera()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = 2
  game_control.CameraCollide = false
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  local picth = math.pi / 12
  local distance = DEFAULT_DIST_CAMERA
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if nx_is_valid(form_movie_new) and form_movie_new.movie_type == 1 then
    local file_path = SCENARIO_BASE_PATH .. form_movie_new.scenario_name
    local scenario_ini = get_config_ini(form_movie_new.is_edit_mode, file_path)
    if nx_is_valid(scenario_ini) then
      local sec_index = scenario_ini:FindSectionIndex(INI_ITEM_CAMREA)
      if 0 <= sec_index then
        picth = scenario_ini:ReadFloat(sec_index, KEY_CAMERA_PITCH, math.pi / 12)
        distance = scenario_ini:ReadFloat(sec_index, KEY_CAMERA_DISTANCE, DEFAULT_DIST_CAMERA)
      end
    end
  end
  local camera_story = game_control:GetCameraController(2)
  if nx_is_valid(camera_story) then
    camera_story.EndDistance = distance
    camera_story.EndPitchAngle = picth
    camera_story.EndYawAngle = visual_player.AngleY
  end
end
function end_movie_camera()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  game_control.CameraMode = nx_execute("control_set", "get_camera_mode")
  game_control.CameraCollide = true
  local picth = math.pi / 12
  local distance = DEFAULT_DIST_CAMERA
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if nx_is_valid(form_movie_new) and form_movie_new.movie_type == 1 then
    local file_path = SCENARIO_BASE_PATH .. form_movie_new.scenario_name
    local scenario_ini = get_config_ini(form_movie_new.is_edit_mode, file_path)
    if nx_is_valid(scenario_ini) then
      local sec_index = scenario_ini:FindSectionIndex(INI_ITEM_CAMREA)
      if 0 <= sec_index then
        picth = scenario_ini:ReadFloat(sec_index, KEY_CAMERA_PITCH, math.pi / 12)
        distance = scenario_ini:ReadFloat(sec_index, KEY_CAMERA_DISTANCE, DEFAULT_DIST_CAMERA)
      end
    end
  end
  game_control.Distance = distance
  game_control.PitchAngle = picth
  if nx_is_valid(visual_player) then
    game_control.YawAngle = visual_player.AngleY
  end
  if nx_is_valid(form_movie_new) then
    local scenario_manager = nx_value("scenario_npc_manager")
    if nx_is_valid(scenario_manager) then
      scenario_manager:RecoverNormalCamera()
    end
  end
end
function face_to_face(player, npc)
  local sx = npc.PositionX - player.PositionX
  local sz = npc.PositionZ - player.PositionZ
  local distance = math.sqrt(sx * sx + sz * sz)
  if distance < 0.001 then
    return
  end
  local dest_angle = math.acos(sz / distance)
  if sx < 0 then
    dest_angle = -dest_angle
  end
  player:SetAngle(player.AngleX, dest_angle, player.AngleZ)
  if 0 <= dest_angle then
    npc:SetAngle(npc.AngleX, dest_angle - math.pi, npc.AngleZ)
  else
    npc:SetAngle(npc.AngleX, dest_angle + math.pi, npc.AngleZ)
  end
end
function get_config_ini(b_reload, file_path)
  local ini
  if b_reload then
    local ini_mgr = nx_value("IniManager")
    if not nx_is_valid(ini_mgr) then
      return nx_null()
    end
    if ini_mgr:IsIniLoadedToManager(file_path) then
      ini_mgr:UnloadIniFromManager(file_path)
    end
    ini_mgr:LoadIniToManager(file_path)
    ini = ini_mgr:GetIniDocument(file_path)
    if not nx_is_valid(ini) then
      return nx_null()
    end
  else
    ini = nx_execute("util_functions", "get_ini", file_path)
    if not nx_is_valid(ini) then
      return nx_null()
    end
  end
  return ini
end
function confirm_end_movie()
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if form_movie_new.is_downing then
    return
  end
  if not form_movie_new.esc_key then
    return
  end
  if nx_int(form_movie_new.movie_mode) == nx_int(4) then
    clear_time_axis_objects(form_movie_new)
    recovery_scene_param()
    end_movie()
  elseif nx_int(form_movie_new.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    clear_time_axis_objects(form_movie_new)
    end_movie()
  else
    local scenario_manager = nx_value("scenario_npc_manager")
    if not nx_is_valid(scenario_manager) then
      return
    end
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local wcsInfo = gui.TextManager:GetText("ui_moviecancel")
    dialog.mltbox_info:Clear()
    dialog.mltbox_info.HtmlText = nx_widestr(wcsInfo)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" and nx_is_valid(scenario_manager) then
      if nx_is_valid(form_movie_new) then
        clear_movie_text()
        if form_movie_new.is_pause == 1 then
          scenario_manager:ContinueScenario()
          form_movie_new.is_pause = 0
        end
      end
      scenario_manager:StopScenario()
    end
  end
end
function on_btn_end_click(btn)
  confirm_end_movie()
end
function play_movie_text_sound(form, sound)
  if nx_find_custom(form, "cur_sound") and nx_is_valid(form.cur_sound) then
    if form.cur_sound.Playing then
      form.cur_sound:Stop()
    end
    nx_execute("util_sound", "delete_sound", form.cur_sound)
  end
  local sound_id, sound_distance = get_sound_info(sound)
  if nil == sound_distance or "" == sound_distance then
    sound_distance = 5
  end
  if sound_id ~= nil and sound_id ~= "" then
    local ogg = false
    local pos = string.find(sound_id, ".wav")
    if pos ~= nil then
      sound_id = string.sub(sound_id, 1, pos - 1)
      ogg = false
    else
      pos = string.find(sound_id, ".ogg")
      if pos ~= nil then
        sound_id = "snd\\env\\" .. sound_id
        ogg = true
      end
    end
    local game_visual = nx_value("game_visual")
    local role = game_visual:GetPlayer()
    if sound_id ~= nil and sound_id ~= "" then
      form.cur_sound = nx_execute("util_sound", "play_link_sound", nx_string(sound_id), role, 0, 0, 0, 1, sound_distance, 1, "snd\\env\\", ogg)
    end
  end
end
function clear_movie_player_buffer_effect()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    local buffer_effect = nx_value("BufferEffect")
    buffer_effect:ClearAllBufferEffect(player.Ident)
  end
end
function clear_all_visual_head_show()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  local visual_obj_lst = {}
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) then
      head_game:ShowHead(visual_obj, false)
      nx_execute("head_game", "cancel_npc_head_effect", visual_obj)
    end
  end
  local role = game_visual:GetPlayer()
  if nx_is_valid(role) then
    head_game:ShowHead(role, false)
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:ClearAllTeamSignEffect()
  end
end
function resume_all_visual_head_show()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_visual) or not nx_is_valid(game_client) then
    return
  end
  local head_game = nx_value("HeadGame")
  if not nx_is_valid(head_game) then
    return
  end
  local game_scene = game_client:GetScene()
  if not nx_is_valid(game_scene) then
    return
  end
  local client_obj_lst = game_scene:GetSceneObjList()
  local visual_obj_lst = {}
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) then
      head_game:ShowHead(visual_obj, true)
      if tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_NPC) then
        nx_execute("head_game", "set_npc_head_effect", visual_obj)
      elseif tonumber(client_obj:QueryProp("Type")) == tonumber(TYPE_PLAYER) then
        local head_game = nx_value("HeadGame")
        if nx_is_valid(head_game) then
          head_game:RefreshTeamSignEffect(client_obj)
        end
      end
    end
  end
  local role = game_visual:GetPlayer()
  if nx_is_valid(role) then
    head_game:ShowHead(role, true)
  end
  local head_game = nx_value("HeadGame")
  if nx_is_valid(head_game) then
    head_game:RefreshTeamSignEffect(game_client:GetPlayer())
  end
end
function get_sound_info(info)
  local sound_info = util_split_string(info, ";")
  local sound_id_woman = sound_info[1]
  local sound_id_man = sound_info[2]
  local sound_id_role = sound_info[3]
  local sound_distance = sound_info[4]
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetPlayer()
  local game_client = nx_value("game_client")
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_npc_manager) then
    return
  end
  local sound_id = ""
  local sex = -1
  if sound_id_role ~= nil and sound_id_role ~= "" then
    local _, j = string.find(sound_id_role, "team_member")
    if j == nil then
      local client_ident = game_visual:QueryRoleClientIdent(role)
      if sound_id_role == "player" and client_ident ~= "" then
        local client_player = game_client:GetSceneObj(nx_string(client_ident))
        if nx_is_valid(client_player) then
          sex = client_player:QueryProp("Sex")
        end
      end
    else
      local index = string.sub(sound_id_role, j + 1, -1)
      if index == nil or index == "" then
        index = 0
      end
      local visual_player = scenario_npc_manager:GetTeamMemberModel(nx_int(index))
      local client_ident = game_visual:QueryRoleClientIdent(visual_player)
      if nx_is_valid(visual_player) and client_ident ~= "" then
        local client_obj = game_client:GetSceneObj(nx_string(client_ident))
        if nx_is_valid(client_obj) then
          sex = client_obj:QueryProp("Sex")
        end
      end
    end
    if nx_int(sex) == nx_int(0) then
      sound_id = sound_id_man
    elseif nx_int(sex) == nx_int(1) then
      sound_id = sound_id_woman
    end
  else
    sound_id = sound_id_man
    if sound_id_woman ~= nil and sound_id_woman ~= "" and (sound_id == nil or sound_id == "") then
      sound_id = sound_id_woman
    end
  end
  return sound_id, sound_distance
end
function close_movie_form()
  local scenario_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_manager) then
    scenario_manager:StopScenarioImmediately()
  end
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  if nx_int(form_movie_new.movie_mode) == nx_int(4) then
    clear_time_axis_objects(form_movie_new)
    recovery_scene_param()
    end_movie()
  elseif nx_int(form_movie_new.movie_mode) == nx_int(SPECIAL_MOVIE_MODE) then
    clear_time_axis_objects(form_movie_new)
    end_movie()
  end
end
function close_movie()
  local scenario_manager = nx_value("scenario_npc_manager")
  if nx_is_valid(scenario_manager) then
    scenario_manager:StopScenarioImmediately()
  end
end
function get_game_replay_by_movie_name(form)
  if not nx_is_valid(form) then
    return false
  end
  if not init_prepare_for_time_axis(form) then
    return false
  end
  return open_game_replay_project(form)
end
function init_prepare_for_time_axis(form)
  local scene = nx_value("scene")
  local terrain = get_game_terrain()
  local time_axis = nx_value("time_axis")
  if not nx_is_valid(time_axis) then
    local scene = nx_value("scene")
    time_axis = scene:Create("TimeAxis")
    if not nx_is_valid(time_axis) then
      return false
    end
    nx_set_value("time_axis", time_axis)
    scene:AddObject(time_axis, 20)
    nx_bind_script(time_axis, "form_stage_main\\form_movie_new")
    nx_callback(time_axis, "on_play_over", "on_play_over")
    nx_callback(time_axis, "on_execute_frame", "on_execute_frame")
    nx_callback(time_axis, "on_create_visual", "on_create_visual")
    time_axis.frame_playe_type = 1
  end
  form.select_object_id = ""
  form.first_person_camera_id = ""
  form.btn_end.Visible = false
  form.object_list = nx_create("ArrayList", "object_list")
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    backup_scene_param()
    hide_npc()
    clear_movie_player_buffer_effect()
    clear_all_visual_head_show()
  end
  return true
end
function open_game_replay_project(form)
  local time_axis = nx_value("time_axis")
  local scene = nx_value("scene")
  local terrain = get_game_terrain()
  local movie_config = nx_value("movie_config")
  local movie_name = form.movie_name
  local str_path = nx_resource_path()
  new_name = "ini\\quest\\" .. movie_name .. "\\project_info.ini"
  local file_name, file_ext = nx_function("ext_split_file_name", new_name)
  local pos = string.find(file_name, "\\")
  local pos2 = 0
  while pos ~= nil do
    pos2 = pos
    pos = string.find(file_name, "\\", pos + 1)
  end
  local middle_path = string.sub(new_name, 1, nx_number(pos2))
  if nx_is_valid(time_axis) then
    local ini = nx_create("IniDocument")
    ini.FileName = str_path .. new_name
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return false
    end
    clear_time_axis_objects(form)
    local sect_table = ini:GetSectionList()
    local sect_count = table.getn(sect_table)
    if sect_count < 1 then
      return false
    end
    time_axis:LoadRandomData(str_path .. middle_path .. "rundom.dat")
    time_axis.FrameInterval = ini:ReadFloat(sect_table[1], "FrameTime", 0.03333)
    local frame_number = to_int(1 / time_axis.FrameInterval)
    if frame_number == nx_int(30) then
      time_axis.frame_playe_type = 1
    elseif frame_number == nx_int(24) then
      time_axis.frame_playe_type = 2
    elseif frame_number == nx_int(25) then
      time_axis.frame_playe_type = 3
    else
      time_axis.frame_playe_type = 0
    end
    local start_ = to_int(ini:ReadFloat(sect_table[1], "RulerStart", -1))
    local end_ = to_int(ini:ReadFloat(sect_table[1], "RulerEnd", -1))
    time_axis.BeginTime = start_ * time_axis.FrameInterval
    time_axis.EndTime = end_ * time_axis.FrameInterval
    local camera_x = ini:ReadFloat(sect_table[1], "CameraX", 0)
    local camera_y = ini:ReadFloat(sect_table[1], "CameraY", 0)
    local camera_z = ini:ReadFloat(sect_table[1], "CameraZ", 0)
    local camera_rx = ini:ReadFloat(sect_table[1], "CameraRX", 0)
    local camera_ry = ini:ReadFloat(sect_table[1], "CameraRY", 0)
    local camera_rz = ini:ReadFloat(sect_table[1], "CameraRZ", 0)
    form.cant_break = ini:ReadInteger(sect_table[1], "CanBreak", 0)
    local camera = get_scene_camera()
    if camera_rx ~= 0 or camera_ry ~= 0 or camera_rz ~= 0 then
      camera:SetAngle(camera_rx, camera_ry, camera_rz)
    end
    local host_player_names = ini:ReadString(sect_table[1], "Player", "")
    local host_player_name_tab = nx_function("ext_split_string", host_player_names, ",")
    local host_player_name = ""
    if 0 < table.getn(host_player_name_tab) then
      host_player_name = nx_string(host_player_name_tab[1])
    end
    local player_vector = nx_value("player_vector")
    if nx_is_valid(player_vector) then
      scene:RemoveObject(player_vector)
      scene:Delete(player_vector)
    end
    player_vector = scene:Create("PlayerVector")
    scene:AddObject(player_vector, 20)
    nx_set_value("player_vector", player_vector)
    local ppfilter = get_ppfilter()
    if nx_is_valid(ppfilter) then
      local ppfilter_uiparam = scene.ppfilter_uiparam
      local postprocess_man = scene.postprocess_man
      if nx_is_valid(postprocess_man) and nx_is_valid(ppfilter_uiparam) then
        postprocess_man:RegistPostProcess(ppfilter)
        ppfilter.AdjustEnable = true
        ppfilter.AdjustBrightness = 0
        ppfilter.AdjustBaseColor = ppfilter_uiparam.hsi_basecolor
        ppfilter.AdjustContrast = ppfilter_uiparam.hsi_contrast
        ppfilter.AdjustSaturation = ppfilter_uiparam.hsi_saturation
      end
    end
    for i = 2, sect_count do
      local object_id = sect_table[i]
      if object_id ~= "" then
        local child = form.object_list:CreateChild(object_id)
        child.create_fail = false
        child.world_type = ini:ReadString(object_id, "WorldType", "objects")
        child.object_type = ini:ReadString(object_id, "ObjectType", "")
        child.position_x = ini:ReadFloat(object_id, "PositionX", 0)
        child.position_y = ini:ReadFloat(object_id, "PositionY", 0)
        child.position_z = ini:ReadFloat(object_id, "PositionZ", 0)
        child.angle_x = ini:ReadFloat(object_id, "AngleX", 0)
        child.angle_y = ini:ReadFloat(object_id, "AngleY", 0)
        child.angle_z = ini:ReadFloat(object_id, "AngleZ", 0)
        child.scale_x = ini:ReadFloat(object_id, "ScaleX", 1)
        child.scale_y = ini:ReadFloat(object_id, "ScaleY", 1)
        child.scale_z = ini:ReadFloat(object_id, "ScaleZ", 1)
        child.name32 = ini:ReadString(object_id, "Name", "")
        child.visual_type = ini:ReadString(object_id, "VisualType", "")
        child.is_visible_visual = true
        local visual
        if child.visual_type == "CameraWrapper" or child.object_type == "camera" then
          child.visual_type = "CameraWrapper"
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.camera_type = ini:ReadString(object_id, "CameraType", "")
          child.Fovx = ini:ReadFloat(object_id, "Fovx", to_radian(45))
          local target_visual = nx_null()
          if child.camera_type == "target" then
            child.NameTarget = ini:ReadString(object_id, "NameTarget", "")
            target_visual = terrain:GetVisual(child.NameTarget)
          end
          visual = put_movie_camera(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, target_visual)
          visual.camera_type = child.camera_type
          visual.Fovx = child.Fovx
          visual.Visible = false
        elseif child.visual_type == "Model" then
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          if "" == child.ModelConfig then
            child.is_visible_visual = false
          else
            visual = terrain:GetVisual(child.name32)
            if not nx_is_valid(visual) then
              visual = put_movie_model(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
            end
          end
        elseif child.visual_type == "Music" then
          local music = nx_create("Music")
          child.MusicConfig = ini:ReadString(object_id, "MusicConfig", "")
          music.Name = child.MusicConfig
          music.AsyncLoad = true
          music.LogicType = 2
          if not music:Create() then
            nx_log(" \180\180\189\168\201\249\210\244\202\167\176\220! " .. child.MusicConfig)
            nx_destroy(music)
          end
          visual = music
          child.is_visible_visual = false
        elseif child.visual_type == "Actor" or child.visual_type == "Actor2" then
          child.visual_type = "Actor"
          child.ActorConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.MainPlayer = 0
          if host_player_name == object_id then
            child.MainPlayer = 1
          end
          for j = 1, table.getn(host_player_name_tab) do
            if nx_string(host_player_name_tab[j]) == object_id then
              child.MainPlayer = 1
            end
          end
          visual = put_movie_actor(child.name32, child.ActorConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z, child.MainPlayer)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "EffectModel" then
          child.EffectModelConfig = ini:ReadString(object_id, "EffectConfig", "")
          child.EffectModelName = ini:ReadString(object_id, "EffectName", "")
          visual = put_movie_effectmodel(child.name32, child.EffectModelConfig, child.EffectModelName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "Particle" then
          child.ParticleConfig = ini:ReadString(object_id, "ParticleConfig", "")
          child.ParticleName = ini:ReadString(object_id, "ParName", "")
          visual = put_movie_particle(child.name32, child.ParticleConfig, child.ParticleName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "LightSource" then
          child.LightColor = ini:ReadString(object_id, "LightColor", "255,255,255,255")
          child.LightType = ini:ReadString(object_id, "LightType", "point")
          child.Intensity = ini:ReadFloat(object_id, "Intensity", 0)
          child.Range = ini:ReadFloat(object_id, "Range", 30)
          child.Attenu0 = ini:ReadFloat(object_id, "Attenu0", 0)
          child.Attenu1 = ini:ReadFloat(object_id, "Attenu1", 1)
          child.Attenu2 = ini:ReadFloat(object_id, "Attenu2", 0)
          child.ShadowMapSize = ini:ReadInteger(object_id, "ShadowMapSize", 0)
          child.Blink = ini:ReadFloat(object_id, "Blink", 0)
          child.BlinkPeriod = ini:ReadFloat(object_id, "BlinkPeriod", 0)
          child.BlinkTick = ini:ReadFloat(object_id, "BlinkTick", 0)
          visual = put_movie_light(child.name32, child.LightColor, child.Intensity, child.Range, child.position_x, child.position_y, child.position_z, child.Attenu0, child.Attenu1, child.Attenu2, child.Blink, child.BlinkPeriod, child.BlinkTick)
          if nx_is_valid(visual) then
            visual.LightType = child.LightType
            visual.ShadowMapSize = child.ShadowMapSize
          end
          if child.LightType == "box" then
            child.BoxScaleX = ini:ReadFloat(object_id, "BoxScaleX", 1)
            child.BoxScaleY = ini:ReadFloat(object_id, "BoxScaleY", 1)
            child.BoxScaleZ = ini:ReadFloat(object_id, "BoxScaleZ", 1)
            if nx_is_valid(visual) then
              visual.BoxScaleX = child.BoxScaleX
              visual.BoxScaleY = child.BoxScaleY
              visual.BoxScaleZ = child.BoxScaleZ
            end
          elseif child.LightType == "spot" then
            child.InnerDegree = ini:ReadFloat(object_id, "InnerDegree", 15)
            child.OuterDegree = ini:ReadFloat(object_id, "OuterDegree", 30)
            child.Falloff = ini:ReadFloat(object_id, "Falloff", 1)
            if nx_is_valid(visual) then
              visual.InnerDegree = child.InnerDegree
              visual.OuterDegree = child.OuterDegree
              visual.Falloff = child.Falloff
            end
          end
        elseif child.visual_type == "Sound" then
          child.SoundConfig = ini:ReadString(object_id, "FileName", "")
          child.Volume = ini:ReadFloat(object_id, "Volume", "1")
          child.InDegree = ini:ReadInteger(object_id, "InDegree", 0)
          child.OutDegree = ini:ReadInteger(object_id, "OutDegree", 0)
          child.OutVolume = ini:ReadInteger(object_id, "OutVolume", 0)
          child.MinDistance = ini:ReadFloat(object_id, "MinDistance", 2)
          child.MaxDistance = ini:ReadFloat(object_id, "MaxDistance", 100)
          child.Loop = nx_boolean(ini:ReadInteger(object_id, "Loop", "1"))
          child.MinInterval = ini:ReadInteger(object_id, "MinInterval", 0)
          child.MaxInterval = ini:ReadInteger(object_id, "MaxInterval", 0)
          child.AutoMute = nx_boolean(ini:ReadInteger(object_id, "AutoMute", "1"))
          child.FadeInFadeOutTime = ini:ReadFloat(object_id, "FadeInFadeOutTime", 1)
          visual = put_movie_sound(child.name32, child.SoundConfig, child.position_x, child.position_y, child.position_z, child.Volume, child.InDegree, child.OutDegree, child.OutVolume, child.MinDistance, child.MaxDistance, child.Loop, child.MinInterval, child.MaxInterval, child.AutoMute, _, child.FadeInFadeOutTime)
        else
          child.is_visible_visual = false
        end
        child.visual = visual
        local object_xml = ini:ReadString(object_id, "Path", "")
        time_axis:LoadObjectKeyFrame(object_id, str_path .. middle_path .. object_xml, true)
        add_movie_object(object_id, visual)
        time_axis:SetNeedVisual(object_id, child.is_visible_visual)
        if nx_is_valid(visual) then
          local cameras_list = ini:ReadString(object_id, "CamerasList", "")
          if cameras_list ~= "" then
            if not nx_find_custom(visual, "movie_camera_list") then
              visual.movie_camera_list = nx_create("ArrayList")
            end
            local param_list = nx_function("ext_split_string", cameras_list, ",")
            for _, object_id in pairs(param_list) do
              if object_id ~= "" and not visual.movie_camera_list:FindChild(object_id) then
                visual.movie_camera_list:CreateChild(object_id)
              end
            end
          end
          visual.owner = child
        end
      end
    end
    nx_destroy(ini)
    if host_player_name ~= "" then
      local host_player = terrain:GetVisual(host_player_name)
      if nx_is_valid(host_player) then
        terrain.Player = host_player
      end
    end
    while not time_axis.LoadFinish do
      nx_pause(0.1)
    end
    time_axis:Pause(time_axis.BeginTime)
    form.movie_type = 2
    return true
  end
  return false
end
function get_special_replay_by_movie_name(form)
  if not nx_is_valid(form) then
    return false
  end
  if not init_prepare_for_time_axis(form) then
    return false
  end
  return open_special_replay_project(form)
end
function open_special_replay_project(form)
  local time_axis = nx_value("time_axis")
  local scene = nx_value("scene")
  local terrain = get_game_terrain()
  local movie_config = nx_value("movie_config")
  local movie_name = form.movie_name
  local str_path = nx_resource_path()
  new_name = "ini\\quest\\" .. movie_name .. "\\project_info.ini"
  local file_name, file_ext = nx_function("ext_split_file_name", new_name)
  local pos = string.find(file_name, "\\")
  local pos2 = 0
  while pos ~= nil do
    pos2 = pos
    pos = string.find(file_name, "\\", pos + 1)
  end
  local middle_path = string.sub(new_name, 1, nx_number(pos2))
  if nx_is_valid(time_axis) then
    local ini = nx_create("IniDocument")
    ini.FileName = str_path .. new_name
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return false
    end
    clear_time_axis_objects(form)
    local sect_table = ini:GetSectionList()
    local sect_count = table.getn(sect_table)
    if sect_count < 1 then
      return false
    end
    time_axis:LoadRandomData(str_path .. middle_path .. "rundom.dat")
    time_axis.FrameInterval = ini:ReadFloat(sect_table[1], "FrameTime", 0.03333)
    local frame_number = to_int(1 / time_axis.FrameInterval)
    if frame_number == nx_int(30) then
      time_axis.frame_playe_type = 1
    elseif frame_number == nx_int(24) then
      time_axis.frame_playe_type = 2
    elseif frame_number == nx_int(25) then
      time_axis.frame_playe_type = 3
    else
      time_axis.frame_playe_type = 0
    end
    local start_ = to_int(ini:ReadFloat(sect_table[1], "RulerStart", -1))
    local end_ = to_int(ini:ReadFloat(sect_table[1], "RulerEnd", -1))
    time_axis.BeginTime = start_ * time_axis.FrameInterval
    time_axis.EndTime = end_ * time_axis.FrameInterval
    local host_player_names = ini:ReadString(sect_table[1], "Player", "")
    local host_player_name_tab = nx_function("ext_split_string", host_player_names, ",")
    local host_player_name = ""
    if 0 < table.getn(host_player_name_tab) then
      host_player_name = nx_string(host_player_name_tab[1])
    end
    local player_vector = nx_value("player_vector")
    if nx_is_valid(player_vector) then
      scene:RemoveObject(player_vector)
      scene:Delete(player_vector)
    end
    player_vector = scene:Create("PlayerVector")
    scene:AddObject(player_vector, 20)
    nx_set_value("player_vector", player_vector)
    for i = 2, sect_count do
      local object_id = sect_table[i]
      if object_id ~= "" then
        local child = form.object_list:CreateChild(object_id)
        child.create_fail = false
        child.world_type = ini:ReadString(object_id, "WorldType", "objects")
        child.object_type = ini:ReadString(object_id, "ObjectType", "")
        child.position_x = ini:ReadFloat(object_id, "PositionX", 0)
        child.position_y = ini:ReadFloat(object_id, "PositionY", 0)
        child.position_z = ini:ReadFloat(object_id, "PositionZ", 0)
        child.angle_x = ini:ReadFloat(object_id, "AngleX", 0)
        child.angle_y = ini:ReadFloat(object_id, "AngleY", 0)
        child.angle_z = ini:ReadFloat(object_id, "AngleZ", 0)
        child.scale_x = ini:ReadFloat(object_id, "ScaleX", 1)
        child.scale_y = ini:ReadFloat(object_id, "ScaleY", 1)
        child.scale_z = ini:ReadFloat(object_id, "ScaleZ", 1)
        child.name32 = ini:ReadString(object_id, "Name", "")
        child.visual_type = ini:ReadString(object_id, "VisualType", "")
        child.is_visible_visual = true
        local visual
        if child.visual_type == "CameraWrapper" or child.object_type == "camera" then
          child.visual_type = "CameraWrapper"
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.camera_type = ini:ReadString(object_id, "CameraType", "")
          child.Fovx = ini:ReadFloat(object_id, "Fovx", to_radian(45))
          local target_visual = nx_null()
          if child.camera_type == "target" then
            child.NameTarget = ini:ReadString(object_id, "NameTarget", "")
            target_visual = terrain:GetVisual(child.NameTarget)
          end
          visual = put_movie_camera(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, target_visual)
          visual.camera_type = child.camera_type
          visual.Fovx = child.Fovx
          visual.Visible = false
        elseif child.visual_type == "Model" then
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          if "" == child.ModelConfig then
            child.is_visible_visual = false
          else
            visual = terrain:GetVisual(child.name32)
            if not nx_is_valid(visual) then
              visual = put_movie_model(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
            end
          end
        elseif child.visual_type == "Music" then
          local music = nx_create("Music")
          child.MusicConfig = ini:ReadString(object_id, "MusicConfig", "")
          music.Name = child.MusicConfig
          music.AsyncLoad = true
          music.LogicType = 2
          if not music:Create() then
            nx_log(" \180\180\189\168\201\249\210\244\202\167\176\220! " .. child.MusicConfig)
            nx_destroy(music)
          end
          visual = music
          child.is_visible_visual = false
        elseif child.visual_type == "Actor" or child.visual_type == "Actor2" then
          child.visual_type = "Actor"
          child.ActorConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.MainPlayer = 0
          if host_player_name == object_id then
            child.MainPlayer = 1
          end
          for j = 1, table.getn(host_player_name_tab) do
            if nx_string(host_player_name_tab[j]) == object_id then
              child.MainPlayer = 1
            end
          end
          visual = put_movie_actor(child.name32, child.ActorConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z, child.MainPlayer)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "EffectModel" then
          child.EffectModelConfig = ini:ReadString(object_id, "EffectConfig", "")
          child.EffectModelName = ini:ReadString(object_id, "EffectName", "")
          visual = put_movie_effectmodel(child.name32, child.EffectModelConfig, child.EffectModelName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "Particle" then
          child.ParticleConfig = ini:ReadString(object_id, "ParticleConfig", "")
          child.ParticleName = ini:ReadString(object_id, "ParName", "")
          visual = put_movie_particle(child.name32, child.ParticleConfig, child.ParticleName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "LightSource" then
          child.LightColor = ini:ReadString(object_id, "LightColor", "255,255,255,255")
          child.LightType = ini:ReadString(object_id, "LightType", "point")
          child.Intensity = ini:ReadFloat(object_id, "Intensity", 0)
          child.Range = ini:ReadFloat(object_id, "Range", 30)
          child.Attenu0 = ini:ReadFloat(object_id, "Attenu0", 0)
          child.Attenu1 = ini:ReadFloat(object_id, "Attenu1", 1)
          child.Attenu2 = ini:ReadFloat(object_id, "Attenu2", 0)
          child.ShadowMapSize = ini:ReadInteger(object_id, "ShadowMapSize", 0)
          child.Blink = ini:ReadFloat(object_id, "Blink", 0)
          child.BlinkPeriod = ini:ReadFloat(object_id, "BlinkPeriod", 0)
          child.BlinkTick = ini:ReadFloat(object_id, "BlinkTick", 0)
          visual = put_movie_light(child.name32, child.LightColor, child.Intensity, child.Range, child.position_x, child.position_y, child.position_z, child.Attenu0, child.Attenu1, child.Attenu2, child.Blink, child.BlinkPeriod, child.BlinkTick)
          if nx_is_valid(visual) then
            visual.LightType = child.LightType
            visual.ShadowMapSize = child.ShadowMapSize
          end
          if child.LightType == "box" then
            child.BoxScaleX = ini:ReadFloat(object_id, "BoxScaleX", 1)
            child.BoxScaleY = ini:ReadFloat(object_id, "BoxScaleY", 1)
            child.BoxScaleZ = ini:ReadFloat(object_id, "BoxScaleZ", 1)
            if nx_is_valid(visual) then
              visual.BoxScaleX = child.BoxScaleX
              visual.BoxScaleY = child.BoxScaleY
              visual.BoxScaleZ = child.BoxScaleZ
            end
          elseif child.LightType == "spot" then
            child.InnerDegree = ini:ReadFloat(object_id, "InnerDegree", 15)
            child.OuterDegree = ini:ReadFloat(object_id, "OuterDegree", 30)
            child.Falloff = ini:ReadFloat(object_id, "Falloff", 1)
            if nx_is_valid(visual) then
              visual.InnerDegree = child.InnerDegree
              visual.OuterDegree = child.OuterDegree
              visual.Falloff = child.Falloff
            end
          end
        elseif child.visual_type == "Sound" then
          child.SoundConfig = ini:ReadString(object_id, "FileName", "")
          child.Volume = ini:ReadFloat(object_id, "Volume", "1")
          child.InDegree = ini:ReadInteger(object_id, "InDegree", 0)
          child.OutDegree = ini:ReadInteger(object_id, "OutDegree", 0)
          child.OutVolume = ini:ReadInteger(object_id, "OutVolume", 0)
          child.MinDistance = ini:ReadFloat(object_id, "MinDistance", 2)
          child.MaxDistance = ini:ReadFloat(object_id, "MaxDistance", 100)
          child.Loop = nx_boolean(ini:ReadInteger(object_id, "Loop", "1"))
          child.MinInterval = ini:ReadInteger(object_id, "MinInterval", 0)
          child.MaxInterval = ini:ReadInteger(object_id, "MaxInterval", 0)
          child.AutoMute = nx_boolean(ini:ReadInteger(object_id, "AutoMute", "1"))
          child.FadeInFadeOutTime = ini:ReadFloat(object_id, "FadeInFadeOutTime", 1)
          visual = put_movie_sound(child.name32, child.SoundConfig, child.position_x, child.position_y, child.position_z, child.Volume, child.InDegree, child.OutDegree, child.OutVolume, child.MinDistance, child.MaxDistance, child.Loop, child.MinInterval, child.MaxInterval, child.AutoMute, _, child.FadeInFadeOutTime)
        else
          child.is_visible_visual = false
        end
        child.visual = visual
        local object_xml = ini:ReadString(object_id, "Path", "")
        time_axis:LoadObjectKeyFrame(object_id, str_path .. middle_path .. object_xml, true)
        add_movie_object(object_id, visual)
        time_axis:SetNeedVisual(object_id, child.is_visible_visual)
        if nx_is_valid(visual) then
          local cameras_list = ini:ReadString(object_id, "CamerasList", "")
          if cameras_list ~= "" then
            if not nx_find_custom(visual, "movie_camera_list") then
              visual.movie_camera_list = nx_create("ArrayList")
            end
            local param_list = nx_function("ext_split_string", cameras_list, ",")
            for _, object_id in pairs(param_list) do
              if object_id ~= "" and not visual.movie_camera_list:FindChild(object_id) then
                visual.movie_camera_list:CreateChild(object_id)
              end
            end
          end
          visual.owner = child
        end
      end
    end
    nx_destroy(ini)
    if host_player_name ~= "" then
      local host_player = terrain:GetVisual(host_player_name)
      if nx_is_valid(host_player) then
        terrain.Player = host_player
      end
    end
    while not time_axis.LoadFinish do
      nx_pause(0.1)
    end
    time_axis:Pause(time_axis.BeginTime)
    time_axis:Play()
    form.movie_type = 2
    return true
  end
  return false
end
function get_special_replay_by_movie_name(form)
  if not nx_is_valid(form) then
    return false
  end
  if not init_prepare_for_time_axis(form) then
    return false
  end
  return open_special_replay_project(form)
end
function open_special_replay_project(form)
  local time_axis = nx_value("time_axis")
  local scene = nx_value("scene")
  local terrain = get_game_terrain()
  local movie_config = nx_value("movie_config")
  local movie_name = form.movie_name
  local str_path = nx_resource_path()
  new_name = "ini\\quest\\" .. movie_name .. "\\project_info.ini"
  local file_name, file_ext = nx_function("ext_split_file_name", new_name)
  local pos = string.find(file_name, "\\")
  local pos2 = 0
  while pos ~= nil do
    pos2 = pos
    pos = string.find(file_name, "\\", pos + 1)
  end
  local middle_path = string.sub(new_name, 1, nx_number(pos2))
  if nx_is_valid(time_axis) then
    local ini = nx_create("IniDocument")
    ini.FileName = str_path .. new_name
    if not ini:LoadFromFile() then
      nx_destroy(ini)
      return false
    end
    clear_time_axis_objects(form)
    local sect_table = ini:GetSectionList()
    local sect_count = table.getn(sect_table)
    if sect_count < 1 then
      return false
    end
    time_axis:LoadRandomData(str_path .. middle_path .. "rundom.dat")
    time_axis.FrameInterval = ini:ReadFloat(sect_table[1], "FrameTime", 0.03333)
    local frame_number = to_int(1 / time_axis.FrameInterval)
    if frame_number == nx_int(30) then
      time_axis.frame_playe_type = 1
    elseif frame_number == nx_int(24) then
      time_axis.frame_playe_type = 2
    elseif frame_number == nx_int(25) then
      time_axis.frame_playe_type = 3
    else
      time_axis.frame_playe_type = 0
    end
    local start_ = to_int(ini:ReadFloat(sect_table[1], "RulerStart", -1))
    local end_ = to_int(ini:ReadFloat(sect_table[1], "RulerEnd", -1))
    time_axis.BeginTime = start_ * time_axis.FrameInterval
    time_axis.EndTime = end_ * time_axis.FrameInterval
    local host_player_names = ini:ReadString(sect_table[1], "Player", "")
    local host_player_name_tab = nx_function("ext_split_string", host_player_names, ",")
    local host_player_name = ""
    if 0 < table.getn(host_player_name_tab) then
      host_player_name = nx_string(host_player_name_tab[1])
    end
    local player_vector = nx_value("player_vector")
    if nx_is_valid(player_vector) then
      scene:RemoveObject(player_vector)
      scene:Delete(player_vector)
    end
    player_vector = scene:Create("PlayerVector")
    scene:AddObject(player_vector, 20)
    nx_set_value("player_vector", player_vector)
    for i = 2, sect_count do
      local object_id = sect_table[i]
      if object_id ~= "" then
        local child = form.object_list:CreateChild(object_id)
        child.create_fail = false
        child.world_type = ini:ReadString(object_id, "WorldType", "objects")
        child.object_type = ini:ReadString(object_id, "ObjectType", "")
        child.position_x = ini:ReadFloat(object_id, "PositionX", 0)
        child.position_y = ini:ReadFloat(object_id, "PositionY", 0)
        child.position_z = ini:ReadFloat(object_id, "PositionZ", 0)
        child.angle_x = ini:ReadFloat(object_id, "AngleX", 0)
        child.angle_y = ini:ReadFloat(object_id, "AngleY", 0)
        child.angle_z = ini:ReadFloat(object_id, "AngleZ", 0)
        child.scale_x = ini:ReadFloat(object_id, "ScaleX", 1)
        child.scale_y = ini:ReadFloat(object_id, "ScaleY", 1)
        child.scale_z = ini:ReadFloat(object_id, "ScaleZ", 1)
        child.name32 = ini:ReadString(object_id, "Name", "")
        child.visual_type = ini:ReadString(object_id, "VisualType", "")
        child.is_visible_visual = true
        local visual
        if child.visual_type == "CameraWrapper" or child.object_type == "camera" then
          child.visual_type = "CameraWrapper"
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.camera_type = ini:ReadString(object_id, "CameraType", "")
          child.Fovx = ini:ReadFloat(object_id, "Fovx", to_radian(45))
          local target_visual = nx_null()
          if child.camera_type == "target" then
            child.NameTarget = ini:ReadString(object_id, "NameTarget", "")
            target_visual = terrain:GetVisual(child.NameTarget)
          end
          visual = put_movie_camera(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, target_visual)
          visual.camera_type = child.camera_type
          visual.Fovx = child.Fovx
          visual.Visible = false
        elseif child.visual_type == "Model" then
          child.ModelConfig = ini:ReadString(object_id, "VisualConfig", "")
          if "" == child.ModelConfig then
            child.is_visible_visual = false
          else
            visual = terrain:GetVisual(child.name32)
            if not nx_is_valid(visual) then
              visual = put_movie_model(child.name32, child.ModelConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
            end
          end
        elseif child.visual_type == "Music" then
          local music = nx_create("Music")
          child.MusicConfig = ini:ReadString(object_id, "MusicConfig", "")
          music.Name = child.MusicConfig
          music.AsyncLoad = true
          music.LogicType = 2
          if not music:Create() then
            nx_log(" \180\180\189\168\201\249\210\244\202\167\176\220! " .. child.MusicConfig)
            nx_destroy(music)
          end
          visual = music
          child.is_visible_visual = false
        elseif child.visual_type == "Actor" or child.visual_type == "Actor2" then
          child.visual_type = "Actor"
          child.ActorConfig = ini:ReadString(object_id, "VisualConfig", "")
          child.MainPlayer = 0
          if host_player_name == object_id then
            child.MainPlayer = 1
          end
          for j = 1, table.getn(host_player_name_tab) do
            if nx_string(host_player_name_tab[j]) == object_id then
              child.MainPlayer = 1
            end
          end
          visual = put_movie_actor(child.name32, child.ActorConfig, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z, child.MainPlayer)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "EffectModel" then
          child.EffectModelConfig = ini:ReadString(object_id, "EffectConfig", "")
          child.EffectModelName = ini:ReadString(object_id, "EffectName", "")
          visual = put_movie_effectmodel(child.name32, child.EffectModelConfig, child.EffectModelName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "Particle" then
          child.ParticleConfig = ini:ReadString(object_id, "ParticleConfig", "")
          child.ParticleName = ini:ReadString(object_id, "ParName", "")
          visual = put_movie_particle(child.name32, child.ParticleConfig, child.ParticleName, child.position_x, child.position_y, child.position_z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
          if nx_is_valid(player_vector) then
            player_vector:AddVisual(visual)
          end
        elseif child.visual_type == "LightSource" then
          child.LightColor = ini:ReadString(object_id, "LightColor", "255,255,255,255")
          child.LightType = ini:ReadString(object_id, "LightType", "point")
          child.Intensity = ini:ReadFloat(object_id, "Intensity", 0)
          child.Range = ini:ReadFloat(object_id, "Range", 30)
          child.Attenu0 = ini:ReadFloat(object_id, "Attenu0", 0)
          child.Attenu1 = ini:ReadFloat(object_id, "Attenu1", 1)
          child.Attenu2 = ini:ReadFloat(object_id, "Attenu2", 0)
          child.ShadowMapSize = ini:ReadInteger(object_id, "ShadowMapSize", 0)
          child.Blink = ini:ReadFloat(object_id, "Blink", 0)
          child.BlinkPeriod = ini:ReadFloat(object_id, "BlinkPeriod", 0)
          child.BlinkTick = ini:ReadFloat(object_id, "BlinkTick", 0)
          visual = put_movie_light(child.name32, child.LightColor, child.Intensity, child.Range, child.position_x, child.position_y, child.position_z, child.Attenu0, child.Attenu1, child.Attenu2, child.Blink, child.BlinkPeriod, child.BlinkTick)
          if nx_is_valid(visual) then
            visual.LightType = child.LightType
            visual.ShadowMapSize = child.ShadowMapSize
          end
          if child.LightType == "box" then
            child.BoxScaleX = ini:ReadFloat(object_id, "BoxScaleX", 1)
            child.BoxScaleY = ini:ReadFloat(object_id, "BoxScaleY", 1)
            child.BoxScaleZ = ini:ReadFloat(object_id, "BoxScaleZ", 1)
            if nx_is_valid(visual) then
              visual.BoxScaleX = child.BoxScaleX
              visual.BoxScaleY = child.BoxScaleY
              visual.BoxScaleZ = child.BoxScaleZ
            end
          elseif child.LightType == "spot" then
            child.InnerDegree = ini:ReadFloat(object_id, "InnerDegree", 15)
            child.OuterDegree = ini:ReadFloat(object_id, "OuterDegree", 30)
            child.Falloff = ini:ReadFloat(object_id, "Falloff", 1)
            if nx_is_valid(visual) then
              visual.InnerDegree = child.InnerDegree
              visual.OuterDegree = child.OuterDegree
              visual.Falloff = child.Falloff
            end
          end
        elseif child.visual_type == "Sound" then
          child.SoundConfig = ini:ReadString(object_id, "FileName", "")
          child.Volume = ini:ReadFloat(object_id, "Volume", "1")
          child.InDegree = ini:ReadInteger(object_id, "InDegree", 0)
          child.OutDegree = ini:ReadInteger(object_id, "OutDegree", 0)
          child.OutVolume = ini:ReadInteger(object_id, "OutVolume", 0)
          child.MinDistance = ini:ReadFloat(object_id, "MinDistance", 2)
          child.MaxDistance = ini:ReadFloat(object_id, "MaxDistance", 100)
          child.Loop = nx_boolean(ini:ReadInteger(object_id, "Loop", "1"))
          child.MinInterval = ini:ReadInteger(object_id, "MinInterval", 0)
          child.MaxInterval = ini:ReadInteger(object_id, "MaxInterval", 0)
          child.AutoMute = nx_boolean(ini:ReadInteger(object_id, "AutoMute", "1"))
          child.FadeInFadeOutTime = ini:ReadFloat(object_id, "FadeInFadeOutTime", 1)
          visual = put_movie_sound(child.name32, child.SoundConfig, child.position_x, child.position_y, child.position_z, child.Volume, child.InDegree, child.OutDegree, child.OutVolume, child.MinDistance, child.MaxDistance, child.Loop, child.MinInterval, child.MaxInterval, child.AutoMute, _, child.FadeInFadeOutTime)
        else
          child.is_visible_visual = false
        end
        child.visual = visual
        local object_xml = ini:ReadString(object_id, "Path", "")
        time_axis:LoadObjectKeyFrame(object_id, str_path .. middle_path .. object_xml, true)
        add_movie_object(object_id, visual)
        time_axis:SetNeedVisual(object_id, child.is_visible_visual)
        if nx_is_valid(visual) then
          local cameras_list = ini:ReadString(object_id, "CamerasList", "")
          if cameras_list ~= "" then
            if not nx_find_custom(visual, "movie_camera_list") then
              visual.movie_camera_list = nx_create("ArrayList")
            end
            local param_list = nx_function("ext_split_string", cameras_list, ",")
            for _, object_id in pairs(param_list) do
              if object_id ~= "" and not visual.movie_camera_list:FindChild(object_id) then
                visual.movie_camera_list:CreateChild(object_id)
              end
            end
          end
          visual.owner = child
        end
      end
    end
    nx_destroy(ini)
    if host_player_name ~= "" then
      local host_player = terrain:GetVisual(host_player_name)
      if nx_is_valid(host_player) then
        terrain.Player = host_player
      end
    end
    while not time_axis.LoadFinish do
      nx_pause(0.1)
    end
    time_axis:Pause(time_axis.BeginTime)
    time_axis:Play()
    form.movie_type = 2
    return true
  end
  return false
end
function player_init(role)
  if nx_find_custom(role, "had_init") and role.had_init then
    return
  end
  if not nx_find_custom(role, "state") then
    role.state = "stand"
    role.state_old = ""
  end
  role.move_mode = ""
  role.move_state = ""
  role.move_action = ""
  role.move_v_orient = ""
  role.move_h_orient = ""
  role.move_speed = 6
  role.walk_speed = 3.6
  role.is_run = true
  role.rotate_speed = 8
  role.move_distance = 0
  role.sync_distance = 0
  role.climb_speed = 8
  role.climb_fall = false
  role.climb_wall_angle = 0
  role.fall_speed = 4
  role.floor_index = 0
  role.height = 1.8
  role.jump_speed = 8
  role.jump_gravity = 9.8
  role.jump_time_max = 0
  role.jump_time_count = 0
  role.jump_height_max = 0
  role.jump_height_start = 0
  role.jump_factor_p = 0
  role.jump_times = 0
  role.jump_dive = false
  role.jump_dive_speed = 10
  role.jump_stage = ""
  role.jump_stand_x = 0
  role.jump_stand_y = 0
  role.jump_stand_z = 0
  role.jump_stand_floor = 0
  role.fly_pitch = 0
  role.fly_distance = 0
  role.fly_normal_x = 0
  role.fly_normal_y = 0
  role.fly_normal_z = 0
  if not nx_find_custom(role, "type") then
    role.type = 2
  end
  role.clip_radius = 0
  role.WaterReflect = false
  role.widget = false
  role.tag = "\211\176\202\211\182\212\207\243"
  if not nx_find_custom(role, "name") then
    role.name = gen_unique_name()
  end
  role.had_init = true
  return true
end
function put_movie_camera(name, model_file, x, y, z, angle_x, angle_y, angle_z, target_visual)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  if 32 ~= string.len(name) then
    name = nx_function("ext_gen_unique_name")
  end
  local scene = nx_value("scene")
  local camera_wrapper = scene:Create("CameraWrapper")
  if not nx_is_valid(camera_wrapper) then
    return nx_null()
  end
  scene:AddObject(camera_wrapper, 100)
  local model = scene:Create("Model")
  model.AsyncLoad = true
  model.ModelFile = model_file
  model.ShowBoundBox = false
  model.name = name
  model.no_light = true
  model.only_design = false
  model.clip_radius = 0
  model.light_map_size = 0
  model.WaterReflect = false
  model.co_walkable = false
  model.co_gen_wall = false
  model.co_gen_roof = false
  model.co_through = false
  model.ExtraInfo = ""
  model.tag = "\211\176\202\211\182\212\207\243"
  model.widget = false
  model:SetPosition(x, y, z)
  model:SetAngle(angle_x, angle_y, angle_z)
  model:Load()
  if nx_is_valid(terrain) and terrain:AddVisual(name, model) then
  else
    scene:Delete(model)
    return nx_null()
  end
  camera_wrapper.Camera = model
  camera_wrapper.third_camera = nx_null()
  if nx_is_valid(target_visual) then
    camera_wrapper.Target = target_visual
    model.target_visual = target_visual
    target_visual.camera_visual = model
  end
  return camera_wrapper
end
function put_movie_model(name, model_file, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  if nil == model_file or "" == model_file then
    return nil
  end
  if 32 ~= string.len(name) then
    name = nx_function("ext_gen_unique_name")
  end
  local tex_path_table = terrain:GetTexturePathList()
  local tex_paths = ""
  local tex_num = table.getn(tex_path_table)
  for i = 1, tex_num do
    tex_paths = tex_paths .. tex_path_table[i]
    if i ~= tex_num then
      tex_paths = tex_paths .. "|"
    end
  end
  local scene = nx_value("scene")
  local model = scene:Create("Model")
  model.AsyncLoad = true
  model.ShowBoundBox = false
  model.ModelFile = model_file
  model.LightFile = ""
  model.TexPaths = tex_paths
  model.name = name
  model.no_light = true
  model.only_design = false
  model.clip_radius = 0
  model.light_map_size = 0
  model.WaterReflect = false
  model.co_walkable = false
  model.co_gen_wall = false
  model.co_gen_roof = false
  model.co_through = false
  model.ExtraInfo = ""
  model.tag = "\211\176\202\211\182\212\207\243"
  model.widget = false
  model:SetPosition(x, y, z)
  model:SetAngle(angle_x, angle_y, angle_z)
  model:SetScale(scale_x, scale_y, scale_z)
  model:Load()
  if no_light then
    model.UseVertexColor = false
    model.UseLightMap = false
  else
    model.UseVertexColor = model.HasVertexColor
    if model.HasLightMap then
      model.UseLightMap = true
    end
  end
  if nx_is_valid(terrain) and terrain:AddVisual(name, model) then
  else
    scene:Delete(model)
    return nx_null()
  end
  return model
end
function put_movie_actor(name, config, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z, MainPlayer)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return nx_null()
  end
  local scene = nx_value("scene")
  local actor
  if nx_int(MainPlayer) == nx_int(1) then
    actor = CreateMainRole()
  else
    local skin_info_table = nx_create("ArrayList", "skin_info_table")
    local ret, role_type, action_ini, default_action, sex, hik_file_name, flags, physical_hair
    if nx_file_exists(nx_resource_path() .. config) then
      ret, role_type, action_ini, default_action, sex, hik_file_name, flags, physical_hair = get_role_set_form_ini(nx_resource_path() .. config, skin_info_table)
    else
      ret = false
    end
    if not ret then
      return nx_null()
    end
    actor = scene:Create("Actor2")
    actor.AsyncLoad = true
    actor.ExtraInfo = extra_info
    if not actor:CreateFromIniEx(config, "") then
      nx_log("create actor from ini file failed! " .. config)
      scene:Delete(actor)
      return nx_null()
    end
    while not actor.LoadFinish do
      nx_pause(0)
    end
    if role_type == role_set.actor2 and "" ~= skin_info_table.face then
      local child_actor = create_role_face_no_statemachine(scene, sex, skin_info_table.face)
      if nx_is_valid(child_actor) then
        while not child_actor.LoadFinish do
          nx_pause(0)
        end
        if not nx_is_valid(actor) then
          scene:Delete(actor)
          scene:Delete(child_actor)
          return nx_null()
        end
        actor:LinkToPoint("actor_role_face", "", child_actor)
        actor:SetLinkAngle("actor_role_face", 0, math.pi, 0)
        child_actor:AddParentAction(actor)
        child_actor:SetScale(scale_x, scale_y, scale_z)
      end
    end
  end
  if not nx_is_valid(actor) then
    return nx_null()
  end
  actor:SetPosition(x, y, z)
  actor:SetAngle(angle_x, angle_y, angle_z)
  actor:SetScale(scale_x, scale_y, scale_z)
  actor.name = name
  actor.config = config
  actor.clip_radius = 0
  actor.WaterReflect = false
  actor.WriteVelocity = 1
  actor.no_save = true
  actor.is_role = true
  actor.widget = false
  actor.tag = "\211\176\202\211\182\212\207\243"
  if nx_is_valid(terrain) and terrain:AddVisualRole(name, actor) then
    local shadow_uiparam = nx_value("shadow_uiparam")
    local shadow_man = nx_value("shadow_man")
    if nx_is_valid(shadow_uiparam) and nx_is_valid(shadow_man) then
      shadow = shadow_man:Create(actor)
      if nx_is_valid(shadow) then
        shadow.Visible = shadow_uiparam.shadow_enable
        shadow.ShadowTopColor = shadow_uiparam.topcolor
        shadow.ShadowBottomColor = shadow_uiparam.bottomcolor
        shadow.LightDispersion = shadow_uiparam.lightdispersion
      end
    end
    player_init(actor)
  else
    scene:Delete(actor)
    return nx_null()
  end
  return actor
end
function put_movie_particle(name, config, par_name, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z)
  local terrain = get_game_terrain()
  local particle_man = nx_value("particle_man")
  local particle = particle_man:CreateFromIni(config, par_name)
  if not nx_is_valid(particle) then
    nx_log("create particle failed! " .. config .. " " .. par_name)
    return nx_null()
  end
  particle.name = name
  particle.par_name = par_name
  particle.config = config
  particle.clip_radius = 0
  particle.widget = false
  particle.tag = "\211\176\202\211\182\212\207\243"
  particle:SetPosition(x, y, z)
  particle:SetAngle(angle_x, angle_y, angle_z)
  particle:SetScale(scale_x, scale_y, scale_z)
  if nx_is_valid(terrain) and terrain:AddVisual(name, particle) then
  else
    particle_man:Delete(particle)
    return nx_null()
  end
  return particle
end
function put_movie_effectmodel(name, effectmodel_config, effectmodel_name, x, y, z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z)
  local terrain = get_game_terrain()
  local scene = nx_value("scene")
  local effectmodel = scene:Create("EffectModel")
  effectmodel.AsyncLoad = true
  effectmodel:SetPosition(x, y, z)
  effectmodel:SetAngle(angle_x, angle_y, angle_z)
  effectmodel:SetScale(scale_x, scale_y, scale_z)
  local append_path = ""
  if string.find(effectmodel_config, "map\\") == 1 then
    append_path = "map\\"
  end
  if not effectmodel:CreateFromIniEx(effectmodel_config, effectmodel_name, true, append_path) then
    nx_log("create effectmodel failed! " .. effectmodel_config .. " " .. effectmodel_name)
    scene:Delete(effectmodel)
    return nx_null()
  end
  effectmodel.name = name
  effectmodel.config = effectmodel_config
  effectmodel.effectmodel_config = effectmodel_config
  effectmodel.effectmodel_name = effectmodel_name
  effectmodel.clip_radius = 0
  effectmodel.WaterReflect = false
  effectmodel.widget = false
  effectmodel.tag = "\211\176\202\211\182\212\207\243"
  if nx_is_valid(terrain) and terrain:AddVisual(name, effectmodel) then
  else
    scene:Delete(effectmodel)
    return nx_null()
  end
  effectmodel.Visible = false
  return effectmodel
end
function put_movie_light(name, color, intensity, range, x, y, z, att0, att1, att2, blink, blink_period, blink_tick, only_design)
  local terrain = get_game_terrain()
  local light_man = nx_value("light_man")
  local light = light_man:Create()
  light.Color = color
  light.Intensity = intensity
  light.Range = range
  light.Attenu0 = att0
  light.Attenu1 = att1
  light.Attenu2 = att2
  light.Blink = blink
  light.BlinkPeriod = blink_period
  light.BlinkTick = blink_tick
  light.name = name
  light.tag = "\211\176\202\211\182\212\207\243"
  light.only_design = false
  light:SetPosition(x, y, z)
  if nx_is_valid(terrain) and terrain:AddVisual(name, light) then
  else
    light_man:Delete(light)
    return nx_null()
  end
  return light
end
function put_movie_sound(name, sound_file, x, y, z, volume, in_degree, out_degree, out_volume, min_dist, max_dist, loop, min_interval, max_interval, auto_mute, fadein_time, fadeout_time)
  local terrain = get_game_terrain()
  local scene = nx_value("scene")
  local sound = scene:Create("Sound")
  sound.Volume = volume
  sound.InDegree = in_degree
  sound.OutDegree = out_degree
  sound.OutVolume = out_volume
  sound.MinDistance = min_dist
  sound.MaxDistance = max_dist
  sound.FadeInFadeOutTime = fadeout_time
  sound.Loop = true
  sound.MinInterval = min_interval
  sound.MaxInterval = max_interval
  sound.AutoMute = auto_mute
  sound.NeedFadeInFadeOut = true
  sound.AsyncLoad = true
  sound.Name = sound_file
  sound.name = name
  sound.tag = "\211\176\202\211\182\212\207\243"
  sound:SetPosition(x, y, z)
  sound:Load()
  if nx_is_valid(terrain) and terrain:AddVisual(name, sound) then
  else
    scene:Delete(sound)
    return nx_null()
  end
  return sound
end
function get_game_scene()
  local world = nx_value("world")
  return world.MainScene
end
function get_game_terrain()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return nx_null()
  end
  return scene.terrain
end
function get_scene_camera()
  local scene = get_game_scene()
  if not nx_is_valid(scene) then
    return nx_null()
  end
  return scene.camera
end
function clear_time_axis_objects(form)
  if not nx_is_valid(form) then
    return
  end
  set_third_person_camera()
  local scene = nx_value("scene")
  local time_axis = nx_value("time_axis")
  local child_list = form.object_list:GetChildList()
  for i = 1, table.getn(child_list) do
    if nx_is_valid(child_list[i]) then
      local visual = child_list[i].visual
      if child_list[i].object_type == "camera" then
        local camera_wrapper = visual
        visual = visual.Camera
        if nx_is_valid(camera_wrapper.Camera) then
          camera_wrapper.Camera.object_id = nil
        end
        if nx_is_valid(camera_wrapper) then
          scene:Delete(camera_wrapper)
        end
      elseif child_list[i].object_type == "camera_target" and nx_is_valid(child_list[i].visual) then
        child_list[i].visual.object_id = nil
      end
      if child_list[i].world_type == "music" and nx_is_valid(child_list[i].visual) then
        nx_destroy(child_list[i].visual)
      end
      time_axis:DeleteObject(child_list[i].Name)
      delete_visual(visual)
    end
    form.object_list:RemoveChildByID(child_list[i])
  end
  time_axis:Clear()
  time_axis:PauseNow()
  form.object_list:ClearChild()
  form.new_movie_words = ""
end
function delete_visual(visual)
  local scene = nx_value("scene")
  local terrain = get_game_terrain()
  if nx_is_valid(visual) and nx_is_valid(scene) and nx_is_valid(terrain) then
    terrain:RemoveVisual(visual)
    scene:Delete(visual)
  end
end
function add_movie_object(object_id, visual)
  local time_axis = nx_value("time_axis")
  if nx_is_valid(visual) and nx_is_kind(visual, "IVisBase") then
    local releal_visual = visual
    if "CameraWrapper" == nx_name(visual) then
      set_camera_param(visual)
      releal_visual = visual.Camera
    end
    if nx_is_valid(releal_visual) then
      releal_visual.object_id = object_id
      releal_visual.no_save = true
      releal_visual.curve_old_x = releal_visual.PositionX
      releal_visual.curve_old_y = releal_visual.PositionY
      releal_visual.curve_old_z = releal_visual.PositionZ
      if "Actor" == nx_name(releal_visual) or "Actor2" == nx_name(releal_visual) then
        releal_visual.AnimationLod = false
      end
    end
  end
  if not time_axis:IsObjectExist(object_id) then
    time_axis:AddObject(object_id)
  end
  if nil ~= visual then
    time_axis:SetObjectID(object_id, visual)
  end
  if not nx_is_valid(releal_visual) then
    time_axis:SetNeedVisual(object_id, false)
  end
end
function set_camera_param(wrapper)
  local gui = nx_value("gui")
  wrapper.Aspect = ASPECT
  wrapper:UpdateFovy(gui.Width / gui.Height)
  wrapper.DepthOfField = nx_value("ppdof")
  wrapper.Fovx = to_radian(80)
  wrapper.FocusDepth = 20
end
function on_play_over(time_axis)
  local form = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form) then
    return
  end
  if form.pause_before_end and nx_is_valid(time_axis) then
    time_axis:PauseNow()
    nx_execute("custom_sender", "custom_before_movie_end", form.movie_id)
    return
  end
  clear_time_axis_objects(form)
  if nx_int(form.movie_mode) ~= nx_int(SPECIAL_MOVIE_MODE) then
    recovery_scene_param()
  end
  end_movie()
end
function on_execute_frame(time_axis, object_id, visual, key_time, ...)
  local form_time_axis = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_time_axis) then
    return
  end
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return
  end
  local is_valid = nx_is_valid(visual)
  local is_camera = false
  local real_camera_warpper = false
  local child
  if is_valid then
    child = visual.owner
    if nx_name(visual) == "CameraWrapper" then
      if not nx_is_valid(visual.Camera) then
        on_create_visual(time_axis, object_id)
        return
      end
      local child = visual.owner
      if "target" == child.camera_type and not nx_is_valid(visual.Target) then
        on_create_visual(time_axis, object_id)
        return
      end
      if nx_name(visual.Camera) == "Camera" then
        real_camera_warpper = true
      end
      is_camera = true
    elseif child.is_visible_visual and not visual.LoadFinish then
      return
    end
  end
  local count = #arg
  local i = 1
  local add = 1
  local controller_type = -1
  while count > i do
    controller_type = nx_number(arg[i])
    add = 2
    if controller_type == CONTROLLER_TYPE_POSITION_ANGLE then
      child.position_x = arg[i + 1]
      child.position_y = arg[i + 2]
      child.position_z = arg[i + 3]
      child.angle_x = arg[i + 4]
      child.angle_y = arg[i + 5]
      child.angle_z = arg[i + 6]
      local ground_y = arg[i + 2]
      if nx_find_custom(visual, "need_ground") and visual.need_ground then
        ground_y = terrain:GetWalkHeight(arg[i + 1], arg[i + 3])
        visual.need_ground = false
      end
      if not nx_execute(nx_current(), "is_be_bind", visual) then
        if is_camera then
          terrain:RelocateVisual(visual.Camera, arg[i + 1], ground_y, arg[i + 3])
        else
          terrain:RelocateVisual(visual, arg[i + 1], ground_y, arg[i + 3])
        end
        visual:SetAngle(arg[i + 4], arg[i + 5], arg[i + 6])
        if real_camera_warpper and nx_is_valid(visual.third_camera) then
          terrain:RelocateVisual(visual.third_camera, arg[i + 1], ground_y, arg[i + 3])
          visual.third_camera:SetAngle(arg[i + 4], arg[i + 5], arg[i + 6])
        end
      end
      add = 7
    elseif controller_type == CONTROLLER_TYPE_ACTION then
      local str_list = util_split_string(arg[i + 1], ",")
      if is_valid and str_list[1] ~= nil then
        execute_action_key(visual, str_list[1], str_list[2])
      end
    elseif controller_type == CONTROLLER_TYPE_FOV_X then
      visual.Fovx = arg[i + 1]
    elseif controller_type == CONTROLLER_TYPE_ACTION_KEY then
      local param_str = arg[i + 1]
      local current_time = arg[i + 2]
      local first_frame = nx_boolean(arg[i + 3])
      execute_scale_key(visual, param_str, current_time)
      add = 4
    elseif controller_type == CONTROLLER_TYPE_FOCUSDEPTH then
    elseif controller_type == CONTROLLER_TYPE_BLURVALUE then
    elseif controller_type == CONTROLLER_TYPE_MAXOFBLUR then
    elseif controller_type == CONTROLLER_TYPE_START_DEPTH then
    elseif controller_type == CONTROLLER_TYPE_END_DEPTH then
    elseif controller_type == CONTROLLER_TYPE_SKY_ANGLE_Y then
      local sky = nx_value("sky")
      if nx_is_valid(sky) then
        sky.YawSpeed = 0
        sky:SetAngle(0, arg[i + 1], 0)
      end
    elseif controller_type == CONTROLLER_TYPE_VISIBLE then
      if is_valid then
        local visible = nx_boolean(arg[i + 1])
        visual.Visible = visible
      end
    elseif controller_type == CONTROLLER_TYPE_BIND_OBJECT then
      nx_execute(nx_current(), "bind_object", visual, arg[i + 1])
    elseif controller_type == CONTROLLER_TYPE_WIND_SPEED then
    elseif controller_type == CONTROLLER_TYPE_WIND_ANGLE then
    elseif controller_type == CONTROLLER_TYPE_LIGHT_INTENSITY then
      if is_valid then
        visual.Intensity = nx_number(arg[i + 1])
      end
    elseif controller_type == CONTROLLER_TYPE_SKY_TEXTURE then
      local param_list = util_split_string(arg[i + 1], ",")
      local sky = nx_value("sky")
      if nx_is_valid(sky) then
        sky.FadeInUpTex = param_list[1]
        sky.FadeInSideTex = param_list[2]
        sky.FadeInTime = nx_number(param_list[3])
      end
    elseif controller_type >= CONTROLLER_TYPE_COLOR_A and controller_type <= CONTROLLER_TYPE_COLOR_B then
    elseif controller_type == CONTROLLER_TYPE_SCALE_X then
      visual:SetScale(arg[i + 1], visual.ScaleY, visual.ScaleZ)
    elseif controller_type == CONTROLLER_TYPE_SCALE_Y then
      visual:SetScale(visual.ScaleX, arg[i + 1], visual.ScaleZ)
    elseif controller_type == CONTROLLER_TYPE_SCALE_Z then
      visual:SetScale(visual.ScaleX, visual.ScaleY, arg[i + 1])
    elseif controller_type == CONTROLLER_TYPE_LIGHT_RANGE then
      visual.Range = arg[i + 1]
    elseif controller_type == CONTROLLER_TYPE_FOCUS_OBJECT then
    elseif controller_type == CONTROLLER_TYPE_EFFECT_DIE then
      visual.EmitSwitch = false
    elseif controller_type == CONTROLLER_TYPE_ALPHA then
      local param_str = arg[i + 1]
      local current_time = arg[i + 2]
      local first_frame = nx_boolean(arg[i + 3])
      if current_time < 0 then
        current_time = 0
      elseif 1 < current_time then
        current_time = 1
      end
      visual = get_real_visual(visual)
      local color = visual.Color
      local color_part = string.sub(color, string.find(color, ","), -1)
      if param_str == "FadeIn" then
        visual.Color = nx_string(current_time * 255) .. color_part
      elseif param_str == "FadeOut" then
        visual.Color = nx_string((1 - current_time) * 255) .. color_part
      end
      add = 4
    elseif controller_type == CONTROLLER_TYPE_ALPHA_PPFILTER then
      local param_str = arg[i + 1]
      local current_time = arg[i + 2]
      local first_frame = nx_boolean(arg[i + 3])
      if current_time < 0 then
        current_time = 0
      elseif 1 < current_time then
        current_time = 1
      end
      local ppfilter = get_ppfilter()
      if nx_is_valid(ppfilter) then
        ppfilter.AdjustEnable = true
        if param_str == "FadeIn" then
          ppfilter.AdjustBrightness = current_time * 50
        elseif param_str == "FadeOut" then
          ppfilter.AdjustBrightness = (1 - current_time) * 50
        end
      end
      add = 4
    elseif controller_type == CONTROLLER_TYPE_LIGHTNING_KEY then
      local movie_config = nx_value("movie_config")
      local volume_cloud = nx_value("VolumeCloud")
      local light_volume = nx_value("ProgramLightning")
      if nx_is_valid(volume_cloud) and nx_is_valid(light_volume) then
        local param_list = util_split_string(param_str, "*")
        if #param_list < 4 then
          return
        end
        local time_length = nx_number(param_list[1])
        local pos_x = nx_number(param_list[2])
        local pos_y = nx_number(param_list[3])
        local pos_z = nx_number(param_list[4])
        local time_now = nx_number(current_time)
        volume_cloud.Lightning = false
        light_volume.Frame = light_volume.MaxFrame * time_now / time_length
        light_volume.PosX = pos_x
        light_volume.PosY = pos_y
        light_volume.PosZ = pos_z
      end
      add = 4
    elseif controller_type == CONTROLLER_TYPE_SOUND then
      local param_str = arg[i + 1]
      local current_time = arg[i + 2]
      local first_frame = nx_boolean(arg[i + 3])
      local param_list = util_split_string(param_str, ",")
      local exec_type = param_list[1]
      local loop = nx_boolean(param_list[2])
      if current_time < 0 then
        current_time = 0
      elseif 1 < current_time then
        current_time = 1
      end
      if exec_type == "in" then
        if first_frame then
          if visual.Finished then
            visual:Play()
          end
          visual.Loop = loop
          visual.Current = 0
        end
        visual.Volume = current_time
      elseif exec_type == "out" and visual.Playing then
        visual.Volume = 1 - current_time
      end
      add = 4
    elseif controller_type == CONTROLLER_TYPE_MUSIC then
      local param_str = arg[i + 1]
      local current_time = arg[i + 2]
      local first_frame = nx_boolean(arg[i + 3])
      local param_list = util_split_string(param_str, ",")
      local exec_type = param_list[1]
      local loop = nx_boolean(param_list[2])
      local music = visual
      if current_time < 0 then
        current_time = 0
      elseif 1 < current_time then
        current_time = 1
      end
      if exec_type == "in" then
        if first_frame and nx_is_valid(music) then
          if nx_find_custom(music, "Finished") and music.Finished then
            music:Play(0)
          end
          music.Loop = loop
          music:Reset()
        end
        if nx_is_valid(music) and nx_find_custom(music, "Volume") then
          music.Volume = current_time
        end
      elseif exec_type == "out" and nx_is_valid(music) and music.Playing and nx_find_custom(music, "Volume") then
        music.Volume = 1 - current_time
      end
      add = 4
    elseif controller_type == CONTROLLER_TYPE_CHANGE_CAMERA then
      local param_list = util_split_string(arg[i + 1], ",")
      local new_camera = ""
      if "change_camera" == param_list[1] then
        new_camera = param_list[2]
      elseif "show_words" == param_list[1] then
      else
        new_camera = param_list[1]
      end
      if "" ~= form_time_axis.first_person_camera_id and new_camera ~= form_time_axis.first_person_camera_id then
        set_first_person_camera(new_camera)
      end
    elseif controller_type == CONTROLLER_TYPE_SHOW_WORDS then
      if form_time_axis.new_movie_words ~= arg[i + 1] then
        form_time_axis.new_movie_words = arg[i + 1]
        nx_execute(nx_current(), "moive_new_play_show_words", arg[i + 1])
      end
    elseif controller_type == CONTROLLER_TYPE_SHAKE then
      local param_list = util_split_string(arg[i + 1], ",")
    elseif controller_type == CONTROLLER_TYPE_UI_ANIMATION then
      local form_animation = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_ui_animation", true)
      if nx_is_valid(form_animation) then
        local param_list = util_split_string(arg[i + 1], ",")
        form_animation.animation_image = param_list[1]
        form_animation.loop_times = nx_int(param_list[2])
        form_animation:Show()
      end
    elseif controller_type == CONTROLLER_TYPE_BLUR then
    elseif controller_type == CONTROLLER_TYPE_ACTION_SPEED then
      local player_vector = nx_value("player_vector")
      local param_list = util_split_string(arg[i + 1], ",")
      if nx_is_valid(player_vector) then
        player_vector.Speed = nx_float(param_list[1])
      end
    elseif controller_type == CONTROLLER_TYPE_GROUND_Y then
      local posi_x = visual.PositionX
      local posi_y = visual.PositionY
      local posi_z = visual.PositionZ
      local terrain = get_game_terrain()
      if nx_is_valid(terrain) then
        local ground_y = terrain:GetWalkHeight(posi_x, posi_z)
        terrain:RelocateVisual(visual, posi_x, ground_y, posi_z)
      end
      visual.need_ground = true
      add = 4
    elseif controller_type == CONTROLLER_TYPE_GLOBLE_SPEED then
      local time_axis = nx_value("time_axis")
      local param_list = util_split_string(arg[i + 1], ",")
      if nx_is_valid(time_axis) and nx_find_property(time_axis, "Speed") then
        time_axis.Speed = nx_float(param_list[1])
      end
      local player_vector = nx_value("player_vector")
      if nx_is_valid(player_vector) then
        player_vector.Speed = nx_float(param_list[1])
      end
    end
    i = i + add
  end
end
function on_create_visual(time_axis, object_id)
  local terrain = get_game_terrain()
  if not nx_is_valid(terrain) then
    return
  end
  local form = nx_value("form_stage_main\\form_movie_new")
  local child = form.object_list:GetChild(object_id)
  if nx_is_valid(child) and not child.create_fail then
    if not child.is_visible_visual then
      return
    end
    local x, y, z = child.position_x, child.position_y, child.position_z
    local visual = child.visual
    if child.visual_type == "CameraWrapper" or child.object_type == "camera" then
      if not nx_is_valid(visual.Camera) then
        visual.Camera = put_movie_model(child.name32, child.ModelConfig, x, y, z, child.angle_x, child.angle_y, child.angle_z, 1, 1, 1)
      end
      if child.camera_type == "target" and nx_is_valid(visual.Camera) then
        local target_visual = terrain:GetVisual(child.NameTarget)
        if nx_is_valid(target_visual) then
          visual.Target = target_visual
          visual.Camera.target_visual = target_visual
          target_visual.camera_visual = visual.Camera
        end
      end
    elseif child.visual_type == "Model" then
      visual = put_movie_model(child.name32, child.ModelConfig, x, y, z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
    elseif child.visual_type == "Music" then
      local music = nx_create("Music")
      music.Name = child.MusicConfig
      music.AsyncLoad = true
      if not music:Create() then
        nx_log(" \180\180\189\168\201\249\210\244\202\167\176\220! " .. child.MusicConfig)
        nx_destroy(music)
      end
      visual = music
    elseif "Actor" == child.visual_type or "Actor2" == child.visual_type then
      visual = put_movie_actor(child.name32, child.ActorConfig, x, y, z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z, child.MainPlayer)
    elseif child.visual_type == "EffectModel" then
      visual = put_movie_effectmodel(child.name32, child.EffectModelConfig, child.EffectModelName, x, y, z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
    elseif child.visual_type == "Particle" then
      visual = put_movie_particle(child.name32, child.ParticleConfig, child.ParticleName, x, y, z, child.angle_x, child.angle_y, child.angle_z, child.scale_x, child.scale_y, child.scale_z)
    elseif child.visual_type == "LightSource" then
      visual = put_movie_light(child.name32, child.LightColor, child.Intensity, child.Range, x, y, z, child.Attenu0, child.Attenu1, child.Attenu2, child.Blink, child.BlinkPeriod, child.BlinkTick)
      if nx_is_valid(visual) then
        visual.LightType = child.LightType
        visual.ShadowMapSize = child.ShadowMapSize
        if child.LightType == "box" then
          visual.BoxScaleX = child.BoxScaleX
          visual.BoxScaleY = child.BoxScaleY
          visual.BoxScaleZ = child.BoxScaleZ
        elseif child.LightType == "spot" then
          visual.InnerDegree = child.InnerDegree
          visual.OuterDegree = child.OuterDegree
          visual.Falloff = child.Falloff
        end
      end
    elseif child.visual_type == "Sound" then
      visual = put_movie_sound(child.name32, child.SoundConfig, child.position_x, child.position_y, child.position_z, child.Volume, child.InDegree, child.OutDegree, child.OutVolume, child.MinDistance, child.MaxDistance, child.Loop, child.MinInterval, child.MaxInterval, child.AutoMute, _, child.FadeInFadeOutTime)
    else
      disp_error(child.visual_type .. "\192\224\208\205\178\187\214\167\179\214\180\230\180\162")
    end
    if not nx_is_valid(visual) then
      child.create_fail = true
      return
    end
    child.visual = visual
    visual.owner = child
    add_movie_object(object_id, visual)
  end
end
function start_time_axis(form)
  if not nx_is_valid(form) then
    return
  end
  local object_list = form.object_list:GetChildList()
  local camera_name_list = {}
  for _, child in pairs(object_list) do
    if nx_is_valid(child) and child.object_type == "camera" then
      camera_name_list[#camera_name_list + 1] = child.Name
    end
  end
  local time_axis = nx_value("time_axis")
  if nx_is_valid(time_axis) then
    time_axis:Play()
  end
  if table.getn(camera_name_list) > 0 then
    set_first_person_camera(camera_name_list[1])
  end
  if nx_int(form.cant_break) > nx_int(0) then
    form.btn_end.Visible = false
    form.esc_key = false
  else
    if not form.btn_end.Visible then
      form.btn_end.Visible = true
    end
    form.esc_key = true
  end
end
function set_first_person_camera(camera_id)
  local form = nx_value("form_stage_main\\form_movie_new")
  local time_axis = nx_value("time_axis")
  local camera = get_scene_camera()
  local gui = nx_value("gui")
  local select_object_id = form.select_object_id
  local child = form.object_list:GetChild(camera_id)
  if not nx_is_valid(child) then
    return
  end
  if form.first_person_camera_id == "" then
    form.camera_posx_old = camera.PositionX
    form.camera_posy_old = camera.PositionY
    form.camera_posz_old = camera.PositionZ
    form.camera_anglex_old = camera.AngleX
    form.camera_angley_old = camera.AngleY
    form.camera_anglez_old = camera.AngleZ
  else
    local child_old = form.object_list:GetChild(form.first_person_camera_id)
    if nx_is_valid(child_old) then
      local camera_wrapper_old = child_old.visual
      if nx_find_custom(camera_wrapper_old, "third_camera") and nx_is_valid(camera_wrapper_old.third_camera) then
        camera_wrapper_old.Camera = camera_wrapper_old.third_camera
        camera_wrapper_old.third_camera = nil
      end
      local terrain = get_game_terrain()
      terrain:RelocateVisual(camera_wrapper_old.Camera, camera.PositionX, camera.PositionY, camera.PositionZ)
      camera_wrapper_old.Camera:SetAngle(camera.AngleX, camera.AngleY, camera.AngleZ)
      camera_wrapper_old.Visible = true
      if child_old.Name == select_object_id then
        time_axis:SetPathVisible(child_old.Name, true)
        camera_wrapper_old.PyramidVisible = true
      end
    end
  end
  camera:SetPosition(child.visual.PositionX, child.visual.PositionY, child.visual.PositionZ)
  camera:SetAngle(child.visual.AngleX, child.visual.AngleY, child.visual.AngleZ)
  local camera_wrapper = child.visual
  camera_wrapper.Visible = false
  time_axis:SetPathVisible(camera_id, false)
  camera_wrapper.PyramidVisible = false
  camera_wrapper.third_camera = child.visual.Camera
  camera_wrapper.Camera = camera
  set_first_person_camera_id(camera_id)
  camera_wrapper:UpdateFovy(gui.Width / gui.Height)
  local select_child = form.object_list:GetChild(select_object_id)
  if nx_is_valid(select_child) then
    time_axis:SetPathVisible(select_child.Name, false)
    if select_child.object_type == "camera" then
      select_child.visual.PyramidVisible = false
    end
  end
  local camera_name_list = {}
  local object_list = form.object_list:GetChildList()
  for _, child in pairs(object_list) do
    if nx_is_valid(child) and child.object_type == "camera" then
      camera_name_list[#camera_name_list + 1] = child
    end
  end
  for _, child_camera in pairs(camera_name_list) do
    child_camera.visual.Visible = false
  end
end
function set_first_person_camera_id(camera_id)
  local form = nx_value("form_stage_main\\form_movie_new")
  form.first_person_camera_id = camera_id
  form.look_mode = "first"
end
function execute_scale_key(visual, param_str, current_time)
  local visual_type = nx_name(visual)
  if visual_type == "Model" then
    visual:Pause()
    visual:SetCurrentTimeFloat(current_time)
  elseif visual_type == "Particle" then
    visual:Pause()
    visual.ParticleTime = current_time
  elseif visual_type == "EffectModel" then
    visual.Visible = true
    visual:Pause()
    visual.CurrenTime = current_time
  elseif visual_type == "Actor" or visual_type == "Actor2" then
    local actor_role = visual:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      actor_role = visual
    end
    local blend_action_count = actor_role:GetBlendActionCount()
    if blend_action_count ~= 1 or not actor_role:IsActionBlended(param_str) then
      actor_role:ClearBlendAction()
      actor_role:BlendAction(param_str, false, true)
    end
    actor_role:SetBlendActionPause(param_str, true)
    local action_frame_float = current_time * actor_role:GetActionFPS(param_str) + 3
    actor_role:SetCurrentFrameFloat(param_str, action_frame_float)
  end
end
function get_real_visual(wrapper)
  local visual = wrapper
  if nx_name(wrapper) == "CameraWrapper" then
    visual = wrapper.Camera
    if not nx_is_valid(visual) then
      return nx_null()
    end
    if nx_name(visual) ~= "Model" then
      visual = wrapper.third_camera
    end
  end
  return visual
end
function to_int(value)
  value = nx_number(value)
  local sign = 1
  if value < 0 then
    sign = -1
  end
  local v = math.abs(value)
  v = nx_int(v + 0.1)
  return v * sign
end
function to_radian(value)
  return value * math.pi / 180
end
function set_third_person_camera()
  local form = nx_value("form_stage_main\\form_movie_new")
  local time_axis = nx_value("time_axis")
  local camera = get_scene_camera()
  local select_object_id = form.select_object_id
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "first_person_camera_id") then
    return
  end
  local child = form.object_list:GetChild(form.first_person_camera_id)
  if not nx_is_valid(child) then
    return
  end
  local camera_wrapper = child.visual
  if nx_find_custom(camera_wrapper, "third_camera") and nx_is_valid(camera_wrapper.third_camera) then
    camera_wrapper.Camera = camera_wrapper.third_camera
  else
    camera_wrapper.Camera = nx_null()
    on_create_visual(_, child.Name)
  end
  camera_wrapper.third_camera = nil
  local terrain = get_game_terrain()
  if nx_is_valid(terrain) then
    terrain:RelocateVisual(camera_wrapper.Camera, camera.PositionX, camera.PositionY, camera.PositionZ)
    camera_wrapper:SetAngle(camera.AngleX, camera.AngleY, camera.AngleZ)
  end
  camera:SetPosition(form.camera_posx_old, form.camera_posy_old, form.camera_posz_old)
  camera:SetAngle(form.camera_anglex_old, form.camera_angley_old, form.camera_anglez_old)
  camera_wrapper.Visible = true
  if child.Name == select_object_id then
    time_axis:SetPathVisible(child.Name, true)
    camera_wrapper.PyramidVisible = true
  end
  local camera_name_list = {}
  local object_list = form.object_list:GetChildList()
  for _, child in pairs(object_list) do
    if nx_is_valid(child) and child.object_type == "camera" then
      camera_name_list[#camera_name_list + 1] = child
    end
  end
  for _, child_camera in pairs(camera_name_list) do
    child_camera.visual.Visible = true
  end
  form.first_person_camera_id = ""
end
function get_ppfilter()
  local ppfilter = nx_value("ppfilter")
  if nx_is_valid(ppfilter) then
    return ppfilter
  end
  local scene = nx_value("scene")
  ppfilter = scene:Create("PPFilter")
  local postprocess_man = scene.postprocess_man
  if not nx_is_valid(postprocess_man) then
    scene:Delete(ppfilter)
    return nx_null()
  end
  postprocess_man:RegistPostProcess(ppfilter)
  nx_set_value("ppfilter", ppfilter)
  return ppfilter
end
function backup_scene_param()
  local scene_param = nx_value("scene_param")
  if not nx_is_valid(scene_param) then
    scene_param = nx_create("ArrayList", "movie: scene_param")
    nx_set_value("scene_param", scene_param)
  else
    scene_param:ClearChild()
  end
  local camera = get_scene_camera()
  if nx_is_valid(camera) then
    local child = scene_param:CreateChild("camera")
    child.position_x = camera.PositionX
    child.position_y = camera.PositionY
    child.position_z = camera.PositionZ
    child.angle_x = camera.AngleX
    child.angle_y = camera.AngleY
    child.angle_z = camera.AngleZ
    child.fov = camera.Fov
    child.bind = camera.Bind
    camera.Bind = nx_null()
  end
  local ppfilter = nx_value("ppfilter")
  if nx_is_valid(ppfilter) then
    local child = scene_param:CreateChild("ppdof")
    child.adjust_enable = ppfilter.AdjustEnable
    child.adjust_brightness = ppfilter.AdjustBrightness
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(0)
  end
end
function recovery_scene_param()
  local scene_param = nx_value("scene_param")
  if not nx_is_valid(scene_param) then
    return
  end
  local child = scene_param:GetChild("camera")
  local camera = get_scene_camera()
  if nx_is_valid(camera) then
    camera:SetAngle(child.angle_x, child.angle_y, child.angle_z)
    camera:SetPosition(child.position_x, child.position_y, child.position_z)
    camera.Fov = child.fov
    camera.Bind = child.bind
  end
  local child = scene_param:GetChild("ppfilter")
  if nx_is_valid(child) then
    local ppfilter = nx_value("ppfilter")
    if nx_is_valid(ppfilter) then
      ppfilter.AdjustEnable = child.adjust_enable
      ppfilter.AdjustBrightness = child.adjust_brightness
    end
  else
    local ppfilter = nx_value("ppfilter")
    if nx_is_valid(ppfilter) then
      local scene = nx_value("scene")
      local scenexx = get_game_scene()
      scene:Delete(ppfilter)
    end
  end
  local game_config = nx_value("game_config")
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(game_config) and nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:SetMusicVolume(game_config.music_volume)
  end
  nx_destroy(scene_param)
  nx_set_value("scene_param", nil)
end
function CreateMainRole()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nx_null()
  end
  local client_obj = game_client:GetSceneObj(nx_string(client_player.Ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local actor2 = role_composite:CreateSceneObjectWithSubModel(scene, client_obj, false, false, false)
  if not nx_is_valid(actor2) then
    return nx_null()
  end
  return actor2
end
function moive_new_play_show_words(word_str)
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if not nx_is_valid(form_movie_new) then
    return
  end
  local param_list = util_split_string(word_str, ",")
  if table.getn(param_list) < 4 then
    return
  end
  local gui = nx_value("gui")
  local show_text = gui.TextManager:GetText(param_list[2])
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local player = game_client:GetPlayer()
    local name = player:QueryProp("Name")
    local result = nx_function("ext_movie_replace_player_name", show_text, name)
    if table.getn(result) > 0 then
      show_text = result[1]
    end
  end
  local pause_time = nx_float(param_list[4])
  form_movie_new.cur_text = show_text
  form_movie_new.mltbox_down:Clear()
  local index = form_movie_new.mltbox_down:AddHtmlText(nx_widestr(form_movie_new.cur_text), -1)
  form_movie_new.mltbox_down:SetHtmlItemSelectable(nx_int(index), false)
  nx_pause(pause_time)
  if not nx_is_valid(form_movie_new) then
    return
  end
  form_movie_new.cur_text = show_text
  form_movie_new.mltbox_down:Clear()
end
function execute_action_key(visual, param1, param2)
  local visual_type = nx_name(visual)
  if visual_type == "Actor" or visual_type == "Actor2" then
    if param2 == "loop" then
      local action = nx_value("action_module")
      if nx_is_valid(action) then
        action:ClearState(visual)
        action:BlendAction(visual, param1, true, true)
      end
    else
      local action_count = visual:GetBlendActionCount()
      if 1 == action_count then
        local action_name = visual:GetBlendActionName(0)
        if "" ~= action_name and visual:GetBlendActionPause(action_name) then
          visual:ClearBlendAction()
        end
      end
      visual:BlendAction(param1, false, false)
    end
  elseif visual_type == "EffectModel" then
    visual.Visible = true
    visual.Loop = true
    visual:Resume()
  end
end
function bind_object(bind_object, param)
  local var_list = util_split_string(param, ",")
  local var_num = #var_list
  local visual
  if var_num < 3 then
    return
  end
  local parent_nod = var_list[1]
  local bind_nod = var_list[2]
  local visual_name = var_list[3]
  if parent_nod == "" and bind_nod ~= "" then
    if nx_find_custom(bind_object, "link_parent_visual") then
      visual = bind_object.link_parent_visual
    end
    if not nx_is_valid(visual) then
      return
    end
    if "Model" == nx_name(visual) then
      nx_execute(nx_current(), "model_un_bind_object", bind_object)
      return
    end
    local delete = nx_boolean(visual_name)
    if nx_is_valid(bind_object) then
      visual:UnLink(bind_nod, false)
      bind_object.link_parent_visual = nil
    end
    return
  end
  if var_num < 12 then
    return
  end
  local terrain = get_game_terrain()
  local visual = terrain:GetVisual(visual_name)
  if not nx_is_valid(visual) then
    return
  end
  local pos_x = nx_number(var_list[4])
  local pos_y = nx_number(var_list[5])
  local pos_z = nx_number(var_list[6])
  local angle_x = nx_number(var_list[7])
  local angle_y = nx_number(var_list[8])
  local angle_z = nx_number(var_list[9])
  local scale_x = nx_number(var_list[10])
  local scale_y = nx_number(var_list[11])
  local scale_z = nx_number(var_list[12])
  if "Model" == nx_name(visual) then
    nx_execute(nx_current(), "model_bind_object", visual, bind_object, parent_nod, pos_x, pos_y, pos_z, angle_x, angle_y, angle_z, scale_x, scale_y, scale_z)
    return
  end
  local bind_object2 = visual:GetLinkObject(bind_nod)
  local ret = nx_is_valid(bind_object2)
  if not ret or not nx_id_equal(bind_object2, bind_object) then
    if ret then
      bind_object.link_parent_visual = nil
      visual:UnLink(bind_nod, false)
    end
    visual:LinkToPoint(bind_nod, parent_nod, bind_object)
    bind_object.link_parent_visual = visual
  end
  bind_object.Visible = true
  visual:SetLinkPosition(bind_nod, pos_x, pos_y, pos_z)
  visual:SetLinkAngle(bind_nod, angle_x, angle_y, angle_z)
  visual:SetLinkScale(bind_nod, scale_x, scale_y, scale_z)
end
function model_bind_object(visual, bind_object, point_name, x, y, z, rx, ry, rz, sx, sy, sz)
  bind_object:LinkToPoint(visual, point_name)
  bind_object.link_parent_visual = visual
  bind_object:SetLinkPosition(x, y, z)
  bind_object:SetLinkAngle(rx, ry, rz)
  bind_object:SetLinkScale(sz, sy, sz)
end
function model_un_bind_object(bind_object)
  bind_object:LinkToPoint("", "")
  bind_object.link_parent_visual = nil
end
function is_be_bind(visual)
  if not nx_is_valid(visual) then
    return false
  end
  return nx_find_custom(visual, "link_parent_visual") and nx_is_valid(visual.link_parent_visual)
end
function get_role_set_form_ini(filename, skin_info_table)
  local ini = nx_create("IniDocument")
  ini.FileName = filename
  if not ini:LoadFromFile() then
    disp_error("\197\228\214\195\206\196\188\254(" .. filename .. ")\178\187\180\230\212\218")
    nx_destroy(ini)
    return false
  end
  local sect_table = ini:GetSectionList()
  local sect = sect_table[1]
  local action_ini = ""
  local default_action = ""
  local effect_model = ""
  local sex = ""
  local hik_file_name = ""
  local flags = 0
  local physical_hair = 0
  skin_info_table.main_model = ""
  skin_info_table.face = ""
  local append_path = ""
  local item_list = ini:GetItemList(sect)
  local item_count = ini:GetItemCount(sect)
  for i = 1, item_count do
    local prop = item_list[i]
    local value = ini:ReadString(sect, item_list[i], "")
    if prop == "Action" then
      action_ini = append_path .. value
    elseif prop == "DefaultAction" then
      default_action = value
    elseif prop == "EffectModel" then
      effect_model = append_path .. value
    elseif prop == "Sex" or prop == "sex" then
      sex = nx_number(value)
    elseif prop == "HIKFileName" then
      hik_file_name = value
    elseif prop == "Flags" then
      flags = nx_number(value)
    elseif prop == "main_model" or prop == "tpose" then
      skin_info_table.main_model = append_path .. value
    elseif prop == "PhysicalHair" then
      physical_hair = nx_number(value)
    else
      local ext = ""
      local pos = string.find(value, ".", 1, true)
      if pos ~= nil then
        ext = string.sub(value, pos + 1)
      end
      if ext == "xmod" then
        local item = skin_info_table:CreateChild(prop)
        item.val = append_path .. value
      elseif ext == "ini" then
        skin_info_table.face = append_path .. value
      end
    end
  end
  nx_destroy(ini)
  local role_type = role_set.actor
  if "" ~= action_ini then
    role_type = role_set.actor2
  end
  return true, role_type, action_ini, default_action, sex, hik_file_name, flags, physical_hair
end
function create_actor_local(scene, debug_info)
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local actor = scene:Create("Actor2")
  if not nx_is_valid(actor) then
    return nx_null()
  end
  actor.scene = scene
  return actor
end
function create_role_face_no_statemachine(scene, sex, actor_role, file_name)
  local actor = create_actor_local(scene, "create_role_face")
  actor.AsyncLoad = true
  actor.HIKEnable = false
  if not nx_is_valid(actor) then
    return nx_null()
  end
  if file_name == nil then
    if 0 == sex then
      file_name = "obj\\char\\b_face\\face_5\\composite.ini"
    else
      file_name = "obj\\char\\g_face\\face_5\\composite.ini"
    end
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return nx_null()
  end
  local SECTION = "COMPOSITE"
  local action = ini:ReadString(SECTION, "Action", "")
  local default_action = ini:ReadString(SECTION, "DefaultAction", "")
  local face_model = ""
  if sex == 0 then
    face_model = ini:ReadString(SECTION, "b_face", "")
  else
    face_model = ini:ReadString(SECTION, "g_face", "")
  end
  if not actor:SetActionEx(action, default_action, "", false) then
    scene:Delete(actor)
    nx_destroy(ini)
    return nx_null()
  end
  if not actor:AddSkin("b_face", face_model) then
    scene:Delete(actor)
    nx_destroy(ini)
    return nx_null()
  end
  nx_destroy(ini)
  return actor
end
