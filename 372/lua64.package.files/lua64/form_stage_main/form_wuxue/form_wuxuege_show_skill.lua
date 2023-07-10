require("util_functions")
require("form_stage_create\\create_logic")
local FORM_WUXUEGE = "form_stage_main\\form_wuxue\\form_wuxuege_show_skill"
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    form_wuxuege = nx_create("form_wuxuege")
    nx_set_value("form_wuxuege", form_wuxuege)
  end
  form.default_actor = nx_null()
  form.default_time = form_wuxuege:GetCameraMoveTime("default")
  form.taolu_id = set_default_taolu(form)
  set_cover(form, false)
  if not load_scenebox(form) then
    return
  end
  if not add_model_to_scenebox_from_ini(form, form.taolu_id) then
    return
  end
  if not load_skill_grid(form, form.taolu_id) then
    return
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "set_cover", form)
  end
  if nx_running(nx_current(), "add_model_to_scenebox_from_ini") then
    nx_kill(nx_current(), "add_model_to_scenebox_from_ini")
  end
  if nx_running(nx_current(), "wait_skill_end") then
    nx_kill(nx_current(), "wait_skill_end")
  end
  if nx_running(nx_current(), "set_camera_position") then
    nx_kill(nx_current(), "set_camera_position")
  end
  if nx_running(nx_current(), "show_skill_action") then
    nx_kill(nx_current(), "show_skill_action")
  end
  local form_wuxuege = nx_value("form_wuxuege")
  if nx_is_valid(form_wuxuege) then
    nx_destroy(form_wuxuege)
  end
  if not nx_is_valid(form) then
    return
  end
  local scene = form.scenebox_xlsbz.Scene
  if nx_is_valid(scene) then
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      scene:Delete(scene.game_effect)
    end
    if nx_is_valid(form.default_actor) then
      scene:Delete(form.default_actor)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_xlsbz)
  nx_destroy(form)
end
function on_ImageControlGrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local actor2 = form.default_actor
  if not nx_is_valid(actor2) then
    return
  end
  local skill_id = get_select_skill_id(form, index)
  if "" == skill_id then
    return
  end
  show_skill_action(form, skill_id, actor2)
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_xlsbz, dist)
    end
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_xlsbz, dist)
    end
  end
end
function on_rbtn_wx_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked ~= true then
    return
  end
  local TaoluID = nx_string(rbtn.DataSource)
  form.taolu_id = TaoluID
  form.lbl_3.BackImage = "gui\\language\\ChineseS\\yulan\\" .. TaoluID .. ".png"
  form.mltbox_1.HtmlText = util_text(TaoluID .. "_js")
  form.mltbox_2.HtmlText = util_text(TaoluID .. "_get")
  add_model_to_scenebox_from_ini(form, TaoluID)
  load_skill_grid(form, TaoluID)
  set_camera_position("default", false)
end
function on_ImageControlGrid_skill_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local skill_id = get_select_skill_id(form, index)
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    return false
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local level = nx_int(form_wuxuege:GetLevelShowTips(skill_id))
  if level <= nx_int(0) then
    level = 1
  end
  item.Level = level
  if skill_id == "CS_jh_xlsbz07_hs" then
    skill_id = "CS_jh_xlsbz07"
  end
  item.ConfigID = skill_id
  item.ItemType = 1000
  item.is_static = true
  nx_execute("tips_game", "show_3d_tips_one", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), form)
end
function on_ImageControlGrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function load_scenebox(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_xlsbz)
  if not nx_is_valid(form.scenebox_xlsbz.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_xlsbz)
    local terrain = nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "create_terrain", form.scenebox_xlsbz.Scene, 1, 4, 100, 100)
    terrain.GroundVisible = false
    local game_effect = nx_create("GameEffect")
    nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox_xlsbz.Scene)
    form.scenebox_xlsbz.Scene.game_effect = game_effect
    return true
  end
  return false
end
function add_model_to_scenebox_from_ini(form, taolu_id)
  if not nx_is_valid(form) or not nx_is_valid(form.scenebox_xlsbz.Scene) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    return false
  end
  local target_scene = form.scenebox_xlsbz.Scene
  local model_path = form_wuxuege:GetModelPathByTaoluID(nx_string(taolu_id))
  if nx_is_valid(form.default_actor) then
    target_scene:Delete(form.default_actor)
  end
  local actor2 = nx_execute("role_composite", "create_actor2", target_scene)
  if not nx_is_valid(actor2) then
    return false
  end
  local result = role_composite:CreateSceneObjectFromIni(actor2, model_path)
  if not result then
    target_scene:Delete(actor2)
    return false
  end
  actor2.sex = 0
  actor2.model_path = model_path
  actor2.AsyncLoad = false
  game_visual:CreateRoleUserData(actor2)
  nx_function("ext_set_role_create_finish", actor2, true)
  form.default_actor = actor2
  if not nx_is_valid(actor2) then
    return false
  end
  util_add_model_to_scenebox(form.scenebox_xlsbz, actor2)
  return true
end
function load_skill_grid(form, taolu_id)
  if not nx_is_valid(form) then
    return false
  end
  local grid = form.ImageControlGrid_skill
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    return false
  end
  local skill = form_wuxuege:GetSkillList(nx_string(taolu_id))
  if skill == "" then
    grid:Clear()
    return false
  end
  local skill_list = util_split_string(skill, ",")
  if table.getn(skill_list) == nx_int(0) then
    return false
  end
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(skill_list) do
    if id == "CS_jh_xlsbz07_hs" then
      id = "CS_jh_xlsbz07"
    end
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", id, "Photo")
    grid:AddItem(grid_index, photo, util_text(id), 1, -1)
    grid_index = grid_index + 1
  end
  return true
end
function set_default_taolu(form)
  if not nx_is_valid(form) then
    return
  end
  local rbtns = form.groupbox_wx:GetChildControlList()
  for _, rbtn in ipairs(rbtns) do
    if nx_name(rbtn) == "RadioButton" and rbtn.Checked then
      return nx_string(rbtn.DataSource)
    end
  end
  return nx_string(rbtns[1].DataSource)
end
function get_select_skill_id(form, skill_grid_index)
  if not nx_is_valid(form) then
    return ""
  end
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    return ""
  end
  local skill = form_wuxuege:GetSkillList(form.taolu_id)
  if skill == "" then
    return ""
  end
  local skill_list = util_split_string(skill, ",")
  if table.getn(skill_list) == nx_int(0) then
    return ""
  end
  if skill_grid_index >= table.getn(skill_list) then
    return ""
  end
  local name = skill_list[skill_grid_index + 1]
  return name
end
function show_skill_action(form, skill_id, actor2)
  if not nx_is_valid(form) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  set_cover(form, true)
  set_camera_position(skill_id, true)
  skill_effect:EndShowZhaoshi(actor2, "")
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
  wait_skill_end(form, actor2)
end
function wait_skill_end(form, actor2)
  if not nx_is_valid(form) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  while nx_is_valid(action) and skill_effect:IsPlayShowZhaoShi(actor2) do
    nx_pause(0.1)
  end
  set_camera_position("default", true)
  wait_move_camera_end(form, false)
end
function wait_move_camera_end(form, b_show)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  timer:Register(nx_float(form.default_time) * 1000, 1, nx_current(), "set_cover", form, form, b_show)
end
function set_cover(form, b_show)
  if not nx_is_valid(form) then
    return
  end
  form.cover_when_show_skill.Visible = b_show
end
function change_form_size(form_yipinge)
  local form = nx_value(FORM_WUXUEGE)
  if not nx_is_valid(form) then
    return
  end
  form.Left = 0
  form.Top = 0
  form.Width = form_yipinge.groupbox_wuxuege_info.Width
  form.Height = form_yipinge.groupbox_wuxuege_info.Height
  form.cover_when_show_skill.Width = form.Width
  form.cover_when_show_skill.Height = form.Height
  form.scenebox_xlsbz.Width = form.Width
  form.scenebox_xlsbz.Height = form.Height
  form.groupbox_xlsbz.Width = form.Width
  form.groupbox_xlsbz.Height = form.Height
end
function set_camera_position(mode, b_move)
  local form = nx_value(FORM_WUXUEGE)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.scenebox_xlsbz.Scene) then
    return
  end
  local camera = form.scenebox_xlsbz.Scene.camera
  if not nx_is_valid(camera) then
    return false
  end
  local asynor = nx_value("common_execute")
  if not nx_is_valid(asynor) then
    return false
  end
  asynor:RemoveExecute("MoveCamera", camera)
  local form_wuxuege = nx_value("form_wuxuege")
  if not nx_is_valid(form_wuxuege) then
    return false
  end
  local pos = form_wuxuege:GetCameraMovePosition(nx_string(mode))
  local pos_list = util_split_string(pos, ",")
  local str_ang = form_wuxuege:GetCameraMoveAngle(nx_string(mode))
  local ang_list = util_split_string(str_ang, ",")
  local time_to_end = nx_float(form_wuxuege:GetCameraMoveTime(nx_string(mode)))
  if time_to_end <= nx_float(0) or time_to_end > nx_float(10) then
    time_to_end = nx_float(0.8)
  end
  camera.t_time = nx_int(time_to_end * 1000)
  camera.s_time = 0
  if b_move then
    asynor:AddExecute("MoveCamera", camera, nx_float(0), nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(camera.AngleY), nx_float(camera.AngleZ), nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]), nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]))
  else
    camera:SetPosition(nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]))
    camera:SetAngle(nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]))
  end
end
function util_add_model_to_scenebox(scenebox, model)
  if not nx_is_valid(scenebox) then
    return false
  end
  if not nx_is_valid(model) then
    return false
  end
  if not nx_is_valid(scenebox.Scene) then
    return false
  end
  local scene = scenebox.Scene
  while not model.LoadFinish do
    nx_pause(0.1)
    if not nx_is_valid(scene) or not nx_is_valid(model) then
      return false
    end
  end
  model:SetPosition(0, 0, 0)
  model:SetAngle(0, math.pi, 0)
  scene:AddObject(model, 20)
  scene.model = model
  scene.ClearZBuffer = true
  set_camera_position("default", false)
  return true
end
