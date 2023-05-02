require("util_functions")
require("custom_sender")
local MAX_MOVIE_COUNT = 1000
local CAMARA_FOCUS_PLAYER = 0
local CAMARA_FOCUS_NPC = 1
local DEFAULT_DIST_CAMERA = 3
local INI_FILE_NAME = "share\\Task\\Movie\\MovieTalkList.ini"
local movie_table = {}
local control_table = {}
local movie_text_table = {}
function main_form_init(form)
  form.Fixed = true
  form.movieid = 0
  form.npcid = ""
  form.focustype = 0
  form.curIndex = 0
  form.IsPlaying = 0
  form.ScenarioName = ""
  form.cur_text = ""
  return 1
end
function on_main_form_open(form)
  init_movie(form)
  nx_execute(nx_current(), "animtion_movie", form)
  return 1
end
function animtion_movie(form)
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
  show_movie(form)
end
function init_movie(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_top.Visible = false
  local gui = nx_value("gui")
  control_table = {}
  local childlist = gui.Desktop:GetChildControlList()
  for i = 1, table.maxn(childlist) do
    local control = childlist[i]
    if nx_is_valid(control) and nx_script_name(control) ~= "form_stage_main\\form_movie" and control.Visible == true then
      control.Visible = false
      table.insert(control_table, control)
    end
  end
  on_size_change(form)
  form.mltbox_up.VAnchor = "Top"
  form.mltbox_down.VAnchor = "Bottom"
  form.mltbox_up.Top = -form.mltbox_up.Height
  form.mltbox_down.Top = 0
end
function show_movie(form)
  if not nx_is_valid(form) then
    return
  end
  form.btn_top.Visible = true
  form.mltbox_up.NoFrame = true
  form.mltbox_down.NoFrame = true
  on_show_movie_details(form)
end
function on_main_form_close(form)
  return 1
end
function on_show_movie_details(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local ini = nx_execute("util_functions", "get_ini", INI_FILE_NAME)
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  game_control.CameraMode = 2
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  form.mltbox_down:Clear()
  local movie_id = form.movieid
  if movie_id <= 0 or movie_id >= MAX_MOVIE_COUNT then
    end_movie(form)
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_movie", false)
    return 0
  end
  local focus_type = form.focustype
  local npc = form.npcid
  local client_npc = game_client:GetSceneObj(nx_string(npc))
  if not nx_is_valid(client_npc) then
    focus_type = CAMARA_FOCUS_PLAYER
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(npc))
  if not nx_is_valid(visual_npc) then
    focus_type = CAMARA_FOCUS_PLAYER
  end
  movie_table = {}
  form.curIndex = 0
  if not ini:FindSection(nx_string(movie_id)) then
    end_movie(form)
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_movie", false)
    return 0
  end
  local key_count = ini:GetItemCount(nx_string(movie_id))
  if key_count <= 0 then
    end_movie(form)
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_movie", false)
    return 0
  end
  movie_table = ini:GetItemValueList(nx_string(movie_id), "r")
  local str_lst = util_split_string(movie_table[1], ",")
  local str_show = str_lst[1]
  local show_text = gui.TextManager:GetText(str_show)
  movie_text_table = {}
  form.cur_text = ""
  movie_text_table = nx_function("ext_movie_text_split_string", nx_string(show_text))
  if nx_running(nx_current(), "form_movie_tick") then
    nx_kill(nx_current(), "form_movie_tick")
  end
  nx_execute(nx_current(), "form_movie_tick")
  form.curIndex = 1
  local para_count = table.getn(str_lst)
  if 4 <= para_count then
    local scenario_name = str_lst[3]
    local must_player = nx_int(str_lst[4])
    if scenario_name ~= "" and scenario_name ~= nil then
      local scenario_manager = nx_value("scenario_npc_manager")
      if nx_is_valid(scenario_manager) then
        local anifile = nx_resource_path() .. "ini\\Scenario\\" .. nx_string(scenario_name)
        scenario_manager:PlayScenario(anifile)
        form.ScenarioName = anifile
        if nx_int(must_player) > nx_int(0) then
          form.IsPlaying = 1
        end
      end
    end
  end
  if focus_type == CAMARA_FOCUS_PLAYER then
    local camera_story = game_control:GetCameraController(2)
    if nx_is_valid(camera_story) then
      game_control.Distance = DEFAULT_DIST_CAMERA
      game_control.PitchAngle = math.pi / 12
      game_control.YawAngle = visual_player.AngleY
    end
  elseif focus_type == CAMARA_FOCUS_NPC then
    face_to_face(visual_player, visual_npc)
    local camera_story = game_control:GetCameraController(2)
    if nx_is_valid(camera_story) then
      game_control.Distance = DEFAULT_DIST_CAMERA
      game_control.PitchAngle = math.pi / 12
      game_control.YawAngle = visual_player.AngleY
    end
  end
  local visual_obj_lst = get_visuals_players()
  for _, visual_obj in pairs(visual_obj_lst) do
    visual_obj.Visible = false
  end
  nx_execute("custom_sender", "custom_select_cancel")
end
function on_size_change(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.btn_top.Width = gui.Width
  form.btn_top.Height = gui.Height
  form.mltbox_up.Width = gui.Width
  form.mltbox_down.Width = gui.Width
  local dHeight = gui.Height / 8
  form.mltbox_up.AbsTop = 0
  form.mltbox_up.Height = dHeight
  form.mltbox_down.AbsTop = gui.Height - dHeight
  form.mltbox_down.Height = dHeight
  local sWidth = 5
  local sHeight = 2
  local viewLeft = sWidth
  local viewTop = sHeight
  local viewWidth = form.mltbox_up.Width - 2 * sWidth
  local viewHeight = form.mltbox_up.Height - 2 * sHeight
  local viewRectStr = viewLeft .. "," .. viewTop .. "," .. viewWidth .. "," .. viewHeight
  form.mltbox_up.ViewRect = viewRectStr
  form.mltbox_down.ViewRect = viewRectStr
end
function normalize_angle(angle)
  local value = math.fmod(angle, math.pi * 2)
  if value < 0 then
    value = value + math.pi * 2
  end
  return value
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
function on_btn_top_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if form.IsPlaying > 0 then
    return 0
  end
  if table.getn(movie_text_table) == 0 then
    go_next_step(form)
  else
    for count = 1, table.getn(movie_text_table) do
      form.cur_text = form.cur_text .. movie_text_table[count]
    end
    movie_text_table = {}
    form.mltbox_down:Clear()
    local index = form.mltbox_down:AddHtmlText(nx_widestr(form.cur_text), -1)
    form.mltbox_down:SetHtmlItemSelectable(nx_int(index), false)
  end
end
function end_movie(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_down:Clear()
  while true do
    local sec = nx_pause(0.01)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_up.Top = nx_int(form.mltbox_up.Top - sec * 100)
    form.mltbox_down.Top = nx_int(form.mltbox_down.Top + sec * 100)
    if form.mltbox_up.Top <= -form.mltbox_up.Height or form.mltbox_down.Top >= 0 then
      form.mltbox_up.Top = -form.mltbox_up.Height
      form.mltbox_down.Top = 0
      break
    end
  end
  local game_client = nx_value("game_client")
  local npc = form.npcid
  local scene = nx_value("game_scene")
  scene.game_control.CameraMode = 0
  local client_npc = game_client:GetSceneObj(nx_string(npc))
  if nx_is_valid(client_npc) then
    nx_execute("freshman_help", "movie_end_callback", client_npc:QueryProp("ConfigID"))
  else
    nx_execute("freshman_help", "movie_end_callback")
  end
  if form.ScenarioName ~= "" and ScenarioName ~= nil then
    local scenario_manager = nx_value("scenario_npc_manager")
    if nx_is_valid(scenario_manager) then
      local anifile = nx_resource_path() .. "ini\\Scenario\\" .. nx_string(scenario_name)
      scenario_manager:StopScenario()
      form.ScenarioName = ""
      form.IsPlaying = 0
    end
  end
  local gui = nx_value("gui")
  for i = 1, table.getn(control_table) do
    if nx_is_valid(control_table[i]) then
      control_table[i].Visible = true
    end
  end
  local visual_obj_lst = get_visuals_players()
  for _, visual_obj in pairs(visual_obj_lst) do
    visual_obj.Visible = true
  end
  control_table = {}
  movie_table = {}
  form.curIndex = 0
  custom_movie_end(form.movieid)
  form:Close()
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_movie", nx_null())
end
function end_scenario(file_name)
  local bShow = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie")
  if bShow then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_movie", true, false)
    if form.ScenarioName == file_name then
      form.ScenarioName = ""
      form.IsPlaying = 0
      go_next_step(form)
    end
  end
end
function go_next_step(form)
  nx_execute("freshman_help", "movie_step_callback", form.movieid, form.curIndex)
  local gui = nx_value("gui")
  local max_index = table.getn(movie_table)
  local cur_index = form.curIndex
  if max_index <= 0 or max_index < cur_index then
    end_movie(form)
  end
  if max_index > cur_index then
    local str_lst = util_split_string(movie_table[cur_index + 1], ",")
    local str_show = str_lst[1]
    local show_text = gui.TextManager:GetText(str_show)
    form.mltbox_down:Clear()
    movie_text_table = {}
    form.cur_text = ""
    movie_text_table = nx_function("ext_movie_text_split_string", nx_string(show_text))
    if nx_running(nx_current(), "form_movie_tick") then
      nx_kill(nx_current(), "form_movie_tick")
    end
    nx_execute(nx_current(), "form_movie_tick")
    form.curIndex = cur_index + 1
    if form.ScenarioName ~= "" and ScenarioName ~= nil then
      local scenario_manager = nx_value("scenario_npc_manager")
      if nx_is_valid(scenario_manager) then
        local anifile = nx_resource_path() .. "ini\\Scenario\\" .. nx_string(scenario_name)
        scenario_manager:StopScenario()
        form.ScenarioName = ""
        form.IsPlaying = 0
      end
    end
    local para_count = table.getn(str_lst)
    if 4 <= para_count then
      local scenario_name = str_lst[3]
      local must_player = nx_int(str_lst[4])
      if scenario_name ~= "" and scenario_name ~= nil then
        local scenario_manager = nx_value("scenario_npc_manager")
        if nx_is_valid(scenario_manager) then
          local anifile = nx_resource_path() .. "ini\\Scenario\\" .. nx_string(scenario_name)
          scenario_manager:PlayScenario(anifile)
          form.ScenarioName = anifile
          if nx_int(must_player) > nx_int(0) then
            form.IsPlaying = 1
          end
        end
      end
    end
  elseif cur_index == max_index then
    end_movie(form)
  end
end
function get_visuals_players()
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local visual_player = game_visual:GetPlayer()
  local scene = visual_player.scene
  local terrain = scene.terrain
  local game_scene = game_client:GetScene()
  local client_obj_lst = game_scene:GetSceneObjList()
  local visual_obj_lst = {}
  for i, client_obj in pairs(client_obj_lst) do
    local visual_obj = game_visual:GetSceneObj(client_obj.Ident)
    if nx_is_valid(visual_obj) and not nx_id_equal(visual_obj, visual_player) and nx_is_valid(client_obj) and client_obj:QueryProp("Type") == 2 then
      visual_obj_lst[table.getn(visual_obj_lst) + 1] = visual_obj
    end
  end
  return visual_obj_lst
end
function form_movie_tick()
  local form_movie = nx_value("form_stage_main\\form_movie")
  if not nx_is_valid(form_movie) then
    return
  end
  while true do
    local sec = nx_pause(0.1)
    if not nx_is_valid(form_movie) then
      break
    end
    if table.getn(movie_text_table) == 0 then
      break
    end
    form_movie.cur_text = form_movie.cur_text .. movie_text_table[1]
    table.remove(movie_text_table, 1)
    form_movie.mltbox_down:Clear()
    local index = form_movie.mltbox_down:AddHtmlText(nx_widestr(form_movie.cur_text), -1)
    form_movie.mltbox_down:SetHtmlItemSelectable(nx_int(index), false)
  end
end
