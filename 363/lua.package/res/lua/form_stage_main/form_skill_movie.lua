local INI_PATH = "ini\\Movie\\SkillMovie\\skill_movie.ini"
function init_form(self)
  self.Fixed = true
end
function set_form_pos(form, x, y, width, height)
  if nx_is_valid(form) then
    form.AbsLeft = x
    form.AbsTop = y
    form.Width = width
    form.Height = height
    form.scenebox_1.Width = width
    form.scenebox_1.Height = height
  end
end
function on_main_form_open(form)
  if not nx_find_custom(form, "movie_name") then
    form:Close()
    return
  end
  local ini = nx_execute("util_functions", "get_ini", INI_PATH)
  if not nx_is_valid(ini) then
    form:Close()
    return
  end
  local sec_index = ini:FindSectionIndex(form.movie_name)
  if sec_index < 0 then
    form:Close()
    return
  end
  nx_set_value("form_stage_main\\form_skill_movie", form)
  local bind_model = ini:ReadString(sec_index, "camera_bind", "")
  local zhaoshi = ini:ReadString(sec_index, "zhaoshi", "")
  local action_name = ini:ReadString(sec_index, "action_name", "")
  local camera_fov = ini:ReadFloat(sec_index, "camera_fov", 0)
  local x = ini:ReadInteger(sec_index, "x", 0)
  local y = ini:ReadInteger(sec_index, "y", 0)
  local width = ini:ReadInteger(sec_index, "width", 300)
  local height = ini:ReadInteger(sec_index, "height", 300)
  local back_image = ini:ReadString(sec_index, "back_image", "")
  set_form_pos(form, x, y, width, height)
  local gui = nx_value("gui")
  gui.Desktop:ToBack(form)
  if back_image ~= "" then
    form.scenebox_1.BackImage = back_image
  end
  play_skill_movie(form, bind_model, camera_fov, zhaoshi, action_name)
end
function on_main_form_close(form)
  form.Visible = false
  local skillStringEffectform = nx_value("form_stage_main\\form_main\\form_main_fightvs_skill")
  if nx_is_valid(skillStringEffectform) and skillStringEffectform.Visible == true then
    skillStringEffectform:Close()
  end
  clear_model(form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_skill_movie", nx_null())
end
function play_skill_movie(form, bind_model, camera_fov, zhaoshi, action_name)
  if not nx_is_valid(form) then
    return
  end
  clear_model(form)
  if not nx_running(nx_current(), "form_showrole") then
    nx_execute(nx_current(), "form_showrole", form, bind_model, camera_fov, zhaoshi, action_name)
  end
end
function clear_model(form)
  if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
    local scene = form.scenebox_1.Scene
    if nx_is_valid(scene) and nx_find_custom(form, "model") and nx_is_valid(form.model) then
      scene:Delete(form.model)
    end
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_1)
  end
end
function form_showrole(form, bind_model, camera_fov, zhaoshi, action_name)
  if zhaoshi == "" then
    return
  end
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetPlayer()
  if not nx_is_valid(client_obj) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_1)
  end
  local scene = form.scenebox_1.Scene
  if not nx_is_valid(scene) then
    return
  end
  local actor2 = role_composite:CreateSceneObject(scene, client_obj, false, false)
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_1, actor2)
  form.actor2 = actor2
  local model = scene:Create("Model")
  if not nx_is_valid(model) then
    return
  end
  model.ModelFile = bind_model
  model:SetPosition(0, 0, 0)
  model:SetAngle(0, 0, 0)
  model.AsyncLoad = false
  model:Load()
  scene:AddObject(model, 20)
  model.Loop = false
  model:Pause()
  model:SetCurrentFrame(0)
  form.model = model
  local camera = scene.camera
  if nx_is_valid(camera) then
    camera.Fov = camera_fov / 180
    camera:LinkToPoint(model, "Camera01")
  end
  action:ActionInit(actor2)
  if action_name ~= "" then
    action:BlendAction(actor2, action_name, false, true)
    form.action_name = action_name
    common_execute:AddExecute("skill_movie", form, 0)
  else
    local skill_effect = nx_value("skill_effect")
    if nx_is_valid(skill_effect) then
      skill_effect:BeginShowZhaoshi(actor2, zhaoshi)
      actor2.skill_movie = form
    end
    model:Play()
  end
end
