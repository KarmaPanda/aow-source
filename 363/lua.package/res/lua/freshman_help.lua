require("util_gui")
require("util_functions")
require("define\\freshman_help_define")
require("define\\freshman_help_effect_define")
local HelpStepEndID = "Freshman_End"
function init_freshman_help()
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return 0
  end
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return 0
  end
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("HelpStepID", "string", player_client, nx_current(), "prop_callback")
  databinder:AddTableBind("Task_Accepted", player_client, nx_current(), "on_task_accept_callback")
  return 1
end
function player_onready(stepID)
  init_freshman_help()
end
function player_before_entry_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local b_hide = need_hide_player(client_player)
  if b_hide then
    local role = nx_value("role")
    if nx_is_valid(role) then
      role.Visible = false
    end
  end
end
function player_entry_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  prop_callback(client_player)
end
function prop_callback(player, PropName, PropType, Value)
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  close_scene_map_effect()
  close_zhaoshi_form_effect()
  close_grid_skill_effect()
  close_bag_item_effect()
  close_task_effect()
  close_sys_map_effect()
  if "" == stepID or HelpStepEndID == stepID then
    return 1
  end
  local freshman_help_ini = nx_call("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return 1
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return 1
  end
  play_animation()
  auto_show_movie()
  bag_item_effect()
  scene_map_effect()
  zhaoshi_normal_attack_effect()
  shourt_skill_effect()
  play_sound()
  return 1
end
function on_task_accept_callback(player, recordname, optype, row, clomn)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_TASK_CAN_SUBMIT) then
    if optype ~= "update" then
      return
    end
    if 0 > tonumber(row) then
      return
    end
    local update_taskid = player_client:QueryRecord(recordname, row, 0)
    local taskid = freshman_help_ini:ReadString(sec_index, "task", "0")
    if tonumber(update_taskid) ~= tonumber(taskid) then
      return
    end
    local tasktitle = player_client:QueryRecord(recordname, row, 5)
    local complete_pos
    complete_pos = string.find(tasktitle, "%(@0%)")
    if nil ~= complete_pos then
      local gui = nx_value("gui")
      local sound = freshman_help_ini:ReadString(sec_index, "sound", "")
      local game_visual = nx_value("game_visual")
      local player_visual = game_visual:GetPlayer()
      nx_execute("util_sound", "play_link_sound", sound, player_visual, 0, 0, 0)
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", HelpStepEndID)
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function auto_show_form()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local gui = nx_value("gui")
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_SHOW_FORM) then
    local auto_show = freshman_help_ini:ReadString(sec_index, "autoshow", "0")
    if nx_int(auto_show) == nx_int(1) then
      local form_name = freshman_help_ini:ReadString(sec_index, "form", "")
      if form_name ~= "" then
        if form_name == "form_stage_main\\form_sys_notice" then
          local scene_resource = ""
          local game_client = nx_value("game_client")
          if nx_is_valid(game_client) then
            local client_scene = game_client:GetScene()
            if nx_is_valid(client_scene) then
              scene_resource = client_scene:QueryProp("Resource")
            end
          end
          local form_sys_notice = nx_value("form_stage_main\\form_sys_notice")
          if nx_is_valid(form_sys_notice) and form_sys_notice.Visible == true then
            nx_execute("freshman_help", "form_on_open_callback", "form_stage_main\\form_sys_notice")
          end
          nx_execute("form_stage_main\\form_sys_notice", "show_notice", scene_resource)
          nx_execute("freshman_help", "form_on_open_callback", "form_stage_main\\form_sys_notice")
        elseif form_name == "form_stage_main\\form_wuxue\\form_wuxue_skill" then
          local form_wuxue_skill = nx_value("form_stage_main\\form_wuxue\\form_wuxue_skill")
          if nx_is_valid(form_wuxue_skill) then
            nx_execute("freshman_help", "form_on_open_callback", "form_stage_main\\form_wuxue\\form_wuxue_skill")
          end
          nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "open_wuxue_sub_page", 2)
        elseif form_name == "form_stage_main\\form_drama" then
          local origin_id = freshman_help_ini:ReadString(sec_index, "origin", "")
          if "" ~= origin_id then
            nx_execute("custom_sender", "custom_send_get_origin", origin_id)
          end
          local form_drama = nx_value("form_stage_main\\form_drama")
          if nx_is_valid(form_drama) then
            nx_execute("form_stage_main\\form_drama", "init_form_data")
            nx_execute("form_stage_main\\form_drama", "refresh_drama_content")
            nx_execute("freshman_help", "form_on_open_callback", "form_drama")
          else
            form_drama = util_get_form("form_stage_main\\form_drama", true)
            if nx_is_valid(form_drama) then
              util_show_form("form_stage_main\\form_drama", true)
            end
          end
        elseif form_name == "form_stage_main\\form_task\\form_task_main" then
        else
          local form = nx_value(nx_string(form_name))
          if nx_is_valid(form) then
            nx_execute("freshman_help", "form_on_open_callback", nx_string(form_name))
          end
          local form = util_get_form(nx_string(form_name), true)
          if nx_is_valid(form) then
            util_show_form(nx_string(form_name), true)
          end
        end
      end
    elseif nx_int(auto_show) == nx_int(0) then
      local form_name = freshman_help_ini:ReadString(sec_index, "form", "")
      local form = nx_value(nx_string(form_name))
      if nx_is_valid(form) and form.Visible == true then
        nx_execute("freshman_help", "form_on_open_callback", nx_string(form_name))
      end
    end
  end
end
function need_hide_player(client_player)
  if not nx_is_valid(client_player) then
    return false
  end
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return false
  end
  local stepID = ""
  if client_player:FindProp("HelpStepID") then
    stepID = client_player:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return false
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return false
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return false
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_AUTO_MOVIE) then
    local movie_id = tonumber(freshman_help_ini:ReadString(sec_index, "movie", "0"))
    local b_show_self = freshman_help_ini:ReadString(sec_index, "bShowSelf", "-1")
    if nx_string(b_show_self) == nx_string("0") and movie_id ~= 0 then
      return true
    end
  end
  return false
end
function auto_show_movie()
  local bMovie = util_is_form_visible("form_stage_main\\form_movie_new")
  if bMovie then
    return
  end
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_AUTO_MOVIE) then
    local gui = nx_value("gui")
    local form = nx_value("form_stage_main\\form_movie_new")
    if not nx_is_valid(form) then
      form = util_get_form("form_stage_main\\form_movie_new", true, false)
      nx_set_value("form_stage_main\\form_movie_new", form)
    end
    local movie_id = tonumber(freshman_help_ini:ReadString(sec_index, "movie", "1"))
    if movie_id ~= 0 then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      local player_visual = game_visual:GetPlayer()
      if not nx_is_valid(player_visual) then
        return
      end
      local b_show_self = freshman_help_ini:ReadString(sec_index, "bShowSelf", "-1")
      if nx_string(b_show_self) == nx_string("0") then
        player_visual.Visible = false
      elseif nx_string(b_show_self) == nx_string("1") then
        player_visual.Visible = true
      end
      player_visual.Visible = false
      local gui = nx_value("gui")
      local form = nx_value("form_stage_main\\form_movie_new")
      if not nx_is_valid(form) then
        form = util_get_form("form_stage_main\\form_movie_new", true, false)
        nx_set_value("form_stage_main\\form_movie_new", form)
      end
      form.movie_id = movie_id
      form.npcid = nx_null()
      form.movie_mode = 0
      util_show_form("form_stage_main\\form_movie_new", true)
    end
  end
end
function play_animation()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_PALY_ANIMATION) then
    local anifile = freshman_help_ini:ReadString(sec_index, "anifile", "")
    if anifile ~= "" then
      local scenario_npc_manager = nx_value("scenario_npc_manager")
      if not nx_is_valid(scenario_npc_manager) then
        return
      end
      local scene = nx_value("game_scene")
      local game_control = scene.game_control
      game_control.CameraMode = 2
      scenario_npc_manager:PlayScenario(nx_resource_path() .. anifile)
      local game_visual = nx_value("game_visual")
      local player_visual = game_visual:GetPlayer()
      local b_show_self = freshman_help_ini:ReadString(sec_index, "bShowSelf", "-1")
      if nx_string(b_show_self) == nx_string("0") then
        player_visual.Visible = false
      elseif nx_string(b_show_self) == nx_string("1") then
        player_visual.Visible = true
      end
    end
  end
end
function play_sound()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_PLAY_SOUND) then
    local gui = nx_value("gui")
    local sound = freshman_help_ini:ReadString(sec_index, "sound", "")
    local game_visual = nx_value("game_visual")
    local player_visual = game_visual:GetPlayer()
    nx_execute("util_sound", "play_link_sound", sound, player_visual, 0, 0, 0)
    local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", HelpStepEndID)
    nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
  end
end
function select_npc_callback(obj_npc)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local client_npc = game_client:GetSceneObj(nx_string(obj_npc))
  if not nx_is_valid(client_npc) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_MOVIE_NPC_TALK) then
    local npc = freshman_help_ini:ReadString(sec_index, "npc", "")
    if npc ~= "" then
      local npc_configID = client_npc:QueryProp("ConfigID")
      if nx_string(npc_configID) == nx_string(npc) then
        local movie_id = tonumber(freshman_help_ini:ReadString(sec_index, "movie", "1"))
        nx_execute("custom_sender", "custom_movie_start", obj_npc, movie_id)
      end
    end
  end
end
function form_on_open_callback(cur_form_name)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_SHOW_FORM) then
    local form_name = freshman_help_ini:ReadString(sec_index, "form", "")
    if nx_string(form_name) == nx_string(cur_form_name) then
      if nx_string(form_name) == "form_stage_main\\form_task\\form_task_main" then
        local task_id = freshman_help_ini:ReadString(sec_index, "task", "")
        if "" ~= task_id then
          nx_execute("custom_sender", "custom_accept_task", nx_int(task_id))
        end
      end
      local open_end = freshman_help_ini:ReadString(sec_index, "openend", "0")
      if nx_int(open_end) == nx_int(1) then
        local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
        nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
      end
    end
  end
  if nx_int(step_type) == nx_int(FH_TIP_FORM) then
    local open_end = freshman_help_ini:ReadString(sec_index, "openend", "0")
    if nx_int(open_end) == nx_int(1) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
  if cur_form_name == "form_stage_main\\form_task\\form_task_main" then
    close_task_effect()
  end
end
function form_on_close_callback(cur_form_name, npcID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_SHOW_FORM) then
    local form_name = freshman_help_ini:ReadString(sec_index, "form", "")
    if nx_string(form_name) == nx_string(cur_form_name) then
      local open_end = freshman_help_ini:ReadString(sec_index, "openend", "0")
      if nx_int(open_end) == nx_int(0) then
        local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
        nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
      end
    end
  end
  if nx_int(step_type) == nx_int(FH_TIP_FORM) then
    local open_end = freshman_help_ini:ReadString(sec_index, "openend", "0")
    if nx_int(open_end) == nx_int(0) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
  if nx_int(step_type) == nx_int(FH_NPC_TALK) and nx_string("form_talk") == nx_string(cur_form_name) then
    local npc = freshman_help_ini:ReadString(sec_index, "npc", "")
    if npc ~= "" and nx_string(npc) == nx_string(npcID) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
  if cur_form_name == "form_stage_main\\form_bag" then
    close_bag_item_effect()
  end
end
function movie_step_callback(movie_id, step_id)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_AUTO_MOVIE) then
    local movie = freshman_help_ini:ReadString(sec_index, "movie", "-1")
    local moviestepid = freshman_help_ini:ReadString(sec_index, "moviestepid", "-1")
    if tonumber(movie) == tonumber(movie_id) and tonumber(step_id) == tonumber(moviestepid) then
      local scenario_npc_manager = nx_value("scenario_npc_manager")
      local anifile = freshman_help_ini:ReadString(sec_index, "anifile", "")
      if nx_is_valid(scenario_npc_manager) and tostring(scenario_npc_manager.FilePath) == tostring(nx_resource_path() .. anifile) then
        local b = scenario_npc_manager:ContinueScenario()
        if b == true then
          local form_movie = nx_value("form_stage_main\\form_movie")
          if nx_is_valid(form_movie) then
            form_movie.IsPlaying = 1
          end
        end
      end
    end
  end
end
function movie_end_callback(npcID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_MOVIE_NPC_TALK) then
    local npc = freshman_help_ini:ReadString(sec_index, "npc", "")
    if npc ~= "" and nx_string(npc) == nx_string(npcID) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
  if nx_int(step_type) == nx_int(FH_AUTO_MOVIE) then
    local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
    nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      local player_visual = game_visual:GetPlayer()
      if nx_is_valid(player_visual) then
        player_visual.Visible = true
      end
    end
  end
end
function ani_step_begin_callback(filename, step_id)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_PALY_ANIMATION) then
    local anifile = freshman_help_ini:ReadString(sec_index, "anifile", "")
    local anistepend = freshman_help_ini:ReadString(sec_index, "anistepend", "-1")
    if nx_string(nx_resource_path() .. anifile) == nx_string(filename) and tonumber(anistepend) == tonumber(step_id) then
      local scenario_npc_manager = nx_value("scenario_npc_manager")
      if nx_is_valid(scenario_npc_manager) then
        scenario_npc_manager:PauseScenario()
      end
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function ani_step_end_callback(filename, step_id)
end
function end_animation(filename)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
end
function use_item_callback(item_configID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_USE_ITEM) then
    local itemID = freshman_help_ini:ReadString(sec_index, "item", "")
    if nx_string(itemID) == nx_string(item_configID) or itemID == "" then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function get_item_callback(item_configID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_GET_ITEM) then
    local itemID = freshman_help_ini:ReadString(sec_index, "item", "")
    if nx_string(itemID) == nx_string(item_configID) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function use_skill_callback(skill_configID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_USE_SKILL) then
    local skillID = freshman_help_ini:ReadString(sec_index, "skill", "")
    if nx_string(skillID) == nx_string(skill_configID) or skillID == "" then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function study_skill_callback(skill_configID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_STUDY_SKILL) then
    local skillID = freshman_help_ini:ReadString(sec_index, "skill", "")
    if nx_string(skillID) == nx_string(skill_configID) then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
    end
  end
end
function buy_item_callback(item_configID)
end
function select_item_callback(item_configID)
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_SELECT_ITEM) then
    local itemID = freshman_help_ini:ReadString(sec_index, "item", "")
    if nx_string(itemID) == nx_string(item_configID) or itemID == "" then
      local next_stepID = freshman_help_ini:ReadString(sec_index, "nextStepID", "")
      nx_execute("custom_sender", "custom_help_step_complete", next_stepID)
      close_grid_skill_effect()
    end
  end
end
function click_wuxue_callback()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return 0
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return 0
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return 0
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return 0
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local step_type = freshman_help_ini:ReadString(sec_index, "type", "-1")
  if nx_int(step_type) == nx_int(FH_SHOW_FORM) then
    local form_name = freshman_help_ini:ReadString(sec_index, "form", "")
    if form_name == "form_stage_main\\form_wuxue\\form_wuxue_skill" then
      nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "open_wuxue_sub_page", 2)
      return 1
    end
  end
  return 0
end
function expend_shourtcut_side()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_SHOURTCUT_BAG) then
    local ani_side_expend_effect = nx_value("ani_side_expend_effect")
    if nx_is_valid(ani_side_expend_effect) then
      ani_side_expend_effect.Visible = false
    end
  elseif nx_int(effectID) == nx_int(FHE_SHOURTCUT_TASK) then
    local ani_side_expend_effect = nx_value("ani_side_expend_effect")
    if nx_is_valid(ani_side_expend_effect) then
      ani_side_expend_effect.Visible = false
    end
  end
end
function task_click_shourtcut_side()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_SHOURTCUT_TASK) then
    local ani_task_effect = nx_value("ani_task_effect")
    if nx_is_valid(ani_task_effect) then
      ani_task_effect.Visible = false
    end
  end
end
function close_task_effect()
  local ani_task_effect = nx_value("ani_task_effect")
  if nx_is_valid(ani_task_effect) then
    ani_task_effect.Visible = false
  end
  local ani_side_expend_effect = nx_value("ani_side_expend_effect")
  if nx_is_valid(ani_side_expend_effect) then
    ani_side_expend_effect.Visible = false
  end
end
function bag_item_effect()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_BAG_ITEM) then
    local form_bag = util_get_form("form_stage_main\\form_bag", true)
    if nx_is_valid(form_bag) and false == form_bag.Visible then
      util_show_form("form_stage_main\\form_bag", true)
    end
    local itemID = freshman_help_ini:ReadString(sec_index, "item", "")
    local item_pos = nx_execute("form_stage_main\\form_task\\form_task_trace", "getItemIndex", itemID)
    if nx_int(item_pos) < nx_int(0) then
      return
    end
    grid_bag_item_effect(form_bag, nx_int(item_pos), "ani_bag_item_effect_1")
    itemID = freshman_help_ini:ReadString(sec_index, "item1", "")
    item_pos = nx_execute("form_stage_main\\form_task\\form_task_trace", "getItemIndex", itemID)
    if nx_int(item_pos) < nx_int(0) then
      return
    end
    grid_bag_item_effect(form_bag, nx_int(item_pos), "ani_bag_item_effect_2")
  end
end
function grid_bag_item_effect(form_bag, pos, ani_name)
  if not nx_is_valid(form_bag) then
    return
  end
  local ani_bag_item_effect_1 = nx_value(nx_string(ani_name))
  if nx_is_valid(ani_bag_item_effect_1) then
    ani_bag_item_effect_1.Visible = true
  else
    local gui = nx_value("gui")
    ani_bag_item_effect_1 = gui:Create("Label")
    if not nx_is_valid(ani_bag_item_effect_1) then
      return
    end
    ani_bag_item_effect_1.Left = form_bag.goods_grid.Left + form_bag.goods_grid:GetItemLeft(nx_int(pos)) + 10
    ani_bag_item_effect_1.Top = form_bag.goods_grid.Top + form_bag.goods_grid:GetItemTop(nx_int(pos)) + 10
    ani_bag_item_effect_1.Height = form_bag.goods_grid.GridHeight
    ani_bag_item_effect_1.Width = form_bag.goods_grid.GridWidth
    ani_bag_item_effect_1.DrawMode = "Expand"
    ani_bag_item_effect_1.BackImage = "BoxShow"
    form_bag:Add(ani_bag_item_effect_1)
    nx_set_value(nx_string(ani_name), ani_bag_item_effect_1)
    ani_bag_item_effect_1.Visible = true
  end
end
function close_bag_item_effect()
  local ani_bag_item_effect_1 = nx_value("ani_bag_item_effect_1")
  if nx_is_valid(ani_bag_item_effect_1) then
    ani_bag_item_effect_1.Visible = false
  end
  local ani_bag_item_effect_2 = nx_value("ani_bag_item_effect_2")
  if nx_is_valid(ani_bag_item_effect_2) then
    ani_bag_item_effect_2.Visible = false
  end
end
function scene_map_effect()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_SCENE_MAP) then
    btn_scene_map_effect()
    grid_sys_map_effect()
  end
end
function btn_scene_map_effect()
  local form_main_map = util_get_form("form_stage_main\\form_main\\form_main_map", true)
  if not nx_is_valid(form_main_map) then
    return
  end
  local ani_scene_map_effect = nx_value("ani_scene_map_effect")
  if nx_is_valid(ani_scene_map_effect) then
    ani_scene_map_effect.Visible = true
  else
    local gui = nx_value("gui")
    ani_scene_map_effect = gui:Create("Label")
    if not nx_is_valid(ani_scene_map_effect) then
      return
    end
    ani_scene_map_effect.AbsLeft = form_main_map.btn_bigmap.AbsLeft
    ani_scene_map_effect.AbsTop = form_main_map.btn_bigmap.AbsTop
    ani_scene_map_effect.VAnchor = form_main_map.btn_bigmap.VAnchor
    ani_scene_map_effect.HAnchor = form_main_map.btn_bigmap.HAnchor
    ani_scene_map_effect.Height = form_main_map.btn_bigmap.Height
    ani_scene_map_effect.Width = form_main_map.btn_bigmap.Width
    ani_scene_map_effect.BackImage = "MapShow"
    form_main_map:Add(ani_scene_map_effect)
    nx_set_value("ani_scene_map_effect", ani_scene_map_effect)
    ani_scene_map_effect.Visible = true
  end
end
function close_scene_map_effect()
  local ani_scene_map_effect = nx_value("ani_scene_map_effect")
  if nx_is_valid(ani_scene_map_effect) then
    ani_scene_map_effect.Visible = false
  end
end
function grid_sys_map_effect()
  local form_sys_notice = util_get_form("form_stage_main\\form_sys_notice", true)
  if not nx_is_valid(form_sys_notice) then
    return
  end
  local ani_sys_map_effect = nx_value("ani_sys_map_effect")
  if nx_is_valid(ani_sys_map_effect) then
    ani_sys_map_effect.Visible = true
  else
    local pos = nx_execute("form_stage_main\\form_sys_notice", "get_map_sys_notice_pos")
    if tonumber(pos) < tonumber(0) then
      return
    end
    local gui = nx_value("gui")
    ani_sys_map_effect = gui:Create("Label")
    if not nx_is_valid(ani_sys_map_effect) then
      return
    end
    ani_sys_map_effect.Left = form_sys_notice.grid_sys_notice:GetItemLeft(nx_int(pos))
    ani_sys_map_effect.Top = form_sys_notice.grid_sys_notice:GetItemTop(nx_int(pos))
    ani_sys_map_effect.Height = form_sys_notice.grid_sys_notice.GridHeight
    ani_sys_map_effect.Width = form_sys_notice.grid_sys_notice.GridWidth
    ani_sys_map_effect.BackImage = "SysMapShow"
    form_sys_notice:Add(ani_sys_map_effect)
    nx_set_value("ani_sys_map_effect", ani_sys_map_effect)
    ani_sys_map_effect.Visible = true
  end
end
function close_sys_map_effect()
  local ani_sys_map_effect = nx_value("ani_sys_map_effect")
  if nx_is_valid(ani_sys_map_effect) then
    ani_sys_map_effect.Visible = false
  end
end
function sys_notice_click_callback()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_SCENE_MAP) then
    close_sys_map_effect()
  end
end
function zhaoshi_normal_attack_effect()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_ZHAOSHI_NORMAL_ATTACK) then
    grid_zhaoshi_skill_effect()
  end
end
function grid_zhaoshi_skill_effect()
  local form_wuxue = nx_value("form_stage_main\\form_wuxue\\form_wuxue")
  if not nx_is_valid(form_wuxue) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "open_wuxue_sub_page", 2)
  end
  local form_skill = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_skill", false)
  if not nx_is_valid(form_skill) then
    return
  end
  local ani_zhaoshi_skill_effect = nx_value("ani_zhaoshi_skill_effect")
  if nx_is_valid(ani_zhaoshi_skill_effect) then
    ani_zhaoshi_skill_effect.Visible = true
  else
    local gui = nx_value("gui")
    ani_zhaoshi_skill_effect = gui:Create("Label")
    if not nx_is_valid(ani_zhaoshi_skill_effect) then
      return
    end
    ani_zhaoshi_skill_effect.BackImage = "BoxShow"
    form_skill.groupbox_2:Add(ani_zhaoshi_skill_effect)
    nx_set_value("ani_zhaoshi_skill_effect", ani_zhaoshi_skill_effect)
    ani_zhaoshi_skill_effect.Visible = true
  end
end
function close_zhaoshi_skill_effect()
  local ani_zhaoshi_skill_effect = nx_value("ani_zhaoshi_skill_effect")
  if nx_is_valid(ani_zhaoshi_skill_effect) then
    ani_zhaoshi_skill_effect.Visible = false
  end
end
function close_zhaoshi_form_effect()
  close_zhaoshi_skill_effect()
end
function shourt_skill_effect()
  local freshman_help_ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\freshmanhelp.ini")
  if not nx_is_valid(freshman_help_ini) then
    return
  end
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local stepID = ""
  if player_client:FindProp("HelpStepID") then
    stepID = player_client:QueryProp("HelpStepID")
  end
  if "" == stepID or HelpStepEndID == stepID then
    return
  end
  if not freshman_help_ini:FindSection(nx_string(stepID)) then
    return
  end
  local sec_index = freshman_help_ini:FindSectionIndex(nx_string(stepID))
  if sec_index < 0 then
    return
  end
  local effectID = freshman_help_ini:ReadString(sec_index, "effect", "-1")
  if nx_int(effectID) == nx_int(FHE_SHOURTCUT_SKILL) then
    grid_skill_effect()
    local form_task = nx_value("form_stage_main\\form_task\\form_task_main")
    if nx_is_valid(form_task) then
      form_task:Close()
    end
  end
end
function grid_skill_effect()
  local form_main_shortcut = util_get_form("form_stage_main\\form_main\\form_main_shortcut", true)
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local grid_skill_effect = nx_value("grid_skill_effect")
  if nx_is_valid(grid_skill_effect) then
    grid_skill_effect.Visible = true
  else
    local gui = nx_value("gui")
    grid_skill_effect = gui:Create("Label")
    if not nx_is_valid(grid_skill_effect) then
      return
    end
    grid_skill_effect.VAnchor = form_main_shortcut.groupbox_2.VAnchor
    grid_skill_effect.HAnchor = form_main_shortcut.groupbox_2.HAnchor
    local grid = form_main_shortcut.grid_shortcut_main
    local x1 = form_main_shortcut.groupbox_2.Left
    local y1 = form_main_shortcut.groupbox_2.Top
    local x2 = grid:GetItemLeft(nx_int(0))
    local y2 = grid:GetItemTop(nx_int(0))
    grid_skill_effect.Left = x1 + x2 - 15
    grid_skill_effect.Top = y1 + y2 + 20
    grid_skill_effect.Height = grid.GridHeight
    grid_skill_effect.Width = grid.GridWidth
    grid_skill_effect.BackImage = "BoxShow"
    form_main_shortcut:Add(grid_skill_effect)
    nx_set_value("grid_skill_effect", grid_skill_effect)
    grid_skill_effect.Visible = true
  end
end
function close_grid_skill_effect()
  local grid_skill_effect = nx_value("grid_skill_effect")
  if nx_is_valid(grid_skill_effect) then
    grid_skill_effect.Visible = false
  end
end
function first_in_game_adjust_camera()
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  if not nx_is_valid(player_client) then
    return
  end
  local b_first_in_game = false
  local help_step_ID = nx_string(player_client:QueryProp("HelpStepID"))
  if help_step_ID == nx_string("") or help_step_ID == nx_string("0") then
    b_first_in_game = true
  elseif help_step_ID == nx_string("yanyuzhuang_00") or help_step_ID == nx_string("suzhou_00") or help_step_ID == nx_string("qiandengzhen_00") then
    b_first_in_game = true
  end
  if not b_first_in_game then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local city_name = client_scene:QueryProp("Resource")
  local ini = nx_execute("util_functions", "get_ini", "ini\\freshmanhelp\\camera_pos.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("ini\\freshmanhelp\\camera_pos.ini " .. get_msg_str("msg_120"))
    return
  end
  if not ini:FindSection(nx_string(city_name)) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(city_name))
  if sec_index < 0 then
    return
  end
  local x = ini:ReadString(sec_index, "x", "")
  local y = ini:ReadString(sec_index, "y", "")
  local z = ini:ReadString(sec_index, "z", "")
  local o = ini:ReadString(sec_index, "rotate", "")
  if x == "" or y == "" or z == "" or o == "" then
    return
  end
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = 2
  game_control.CameraCollide = false
  local camera_story = game_control:GetCameraController(2)
  camera_story:AddMovePoint(true, nx_float(x), nx_float(y), nx_float(z), 0, nx_float(o), 0, 1)
  camera_story.StartAutoMove = true
end
