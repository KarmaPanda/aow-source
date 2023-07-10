require("util_gui")
require("util_functions")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(form)
  form.Fixed = true
  form.bookid = ""
  form.model_id = nx_null()
  form.helper_name = ""
  return 1
end
function on_form_open(form)
  on_size_change(form)
  local bookid = form.bookid
  local gui = nx_value("gui")
  local ini = nx_execute("util_functions", "get_ini", "ini\\SelectBook\\books.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("ini\\SelectBook\\books.ini" .. get_msg_str("msg_120"))
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(bookid))
  if sec_index < 0 then
    return
  end
  local text_id = ini:ReadString(sec_index, "ShowTextID", "")
  local show_text = gui.TextManager:GetText(text_id)
  form.mltbox_introduce:Clear()
  local index = form.mltbox_introduce:AddHtmlText(nx_widestr(show_text), nx_int(-1))
  form.mltbox_introduce:SetHtmlItemSelectable(nx_int(index), false)
  form.lbl_back.BlendAlpha = 255
  form.lbl_back.Visible = true
  form.lbl_book.PlayMode = 0
  form.lbl_book.Loop = true
  init_moving_camera(form)
  return 1
end
function on_form_close(form)
  local scene = nx_value("game_scene")
  local world = nx_value("world")
  world.MainScene = scene
  local entity_for_debug = nx_value("entity_for_debug")
  if nx_is_valid(entity_for_debug) then
    nx_destroy(entity_for_debug)
  end
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local bookid = form.bookid
  util_show_form("form_stage_create\\form_book_introduce", false)
  gui.Desktop:Close()
  gui.Loader:LoadDesktop(nx_resource_path(), gui.skin_path .. "form_stage_create\\form_create.xml")
  gui.Desktop.bookid = bookid
  gui.Desktop.Left = 0
  gui.Desktop.Top = 0
  gui.Desktop.Width = gui.Width
  gui.Desktop.Height = gui.Height
  gui.Desktop.Transparent = true
  gui.Desktop:ShowModal()
  nx_set_value("form_stage_create\\form_create", gui.Desktop)
  return 1
end
function on_btn_back_click(btn)
  local form = btn.ParentForm
  util_show_form("form_stage_create\\form_book_introduce", false)
  local form = nx_value("form_stage_create\\form_select_book")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_create\\form_select_book", true, false)
    nx_set_value("form_stage_create\\form_select_book", form)
  end
  util_show_form("form_stage_create\\form_select_book", true)
  return 1
end
function on_size_change(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.mltbox_introduce.AbsTop = form.Height / 9
  form.mltbox_introduce.AbsLeft = 11 * form.Width / 16
  form.mltbox_introduce.Width = form.Width / 4
  form.mltbox_introduce.Height = 2 * form.Height / 3
  local sWidth = 2
  local sHeight = 2
  local viewLeft = sWidth
  local viewTop = sHeight
  local viewWidth = form.mltbox_introduce.Width - 2 * sWidth
  local viewHeight = form.mltbox_introduce.Height - 2 * sHeight
  local viewRectStr = viewLeft .. "," .. viewTop .. "," .. viewWidth .. "," .. viewHeight
  form.mltbox_introduce.ViewRect = viewRectStr
  form.btn_ok.AbsTop = form.Height - 100
  form.btn_ok.AbsLeft = form.Width - 100
  form.btn_back.AbsTop = form.Height - 100
  form.btn_back.AbsLeft = form.Width - 50
  form.lbl_back.AbsLeft = 0
  form.lbl_back.AbsTop = 0
  form.lbl_back.Width = gui.Width
  form.lbl_back.Height = gui.Height
  form.lbl_book.AbsTop = 50
  form.lbl_book.AbsLeft = 50
  form.lbl_up.AbsTop = 0
  form.lbl_up.AbsLeft = 0
  form.lbl_up.Width = gui.Width
  form.lbl_down.AbsTop = gui.Height - form.lbl_down.Height
  form.lbl_down.AbsLeft = 0
  form.lbl_down.Width = gui.Width
  return 1
end
function create_scene(form)
  local scene = nx_value("drama_sel_scene")
  if nx_is_valid(scene) then
    return
  end
  nx_execute("scene", "create_scene", "drama_sel_scene")
  scene = nx_value("drama_sel_scene")
  if not nx_is_valid(scene) then
    return
  end
end
function load_scene_res(form)
  local scene = nx_value("drama_sel_scene")
  if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) and scene.terrain.LoadFinish then
    return false
  end
  nx_execute("scene", "load_scene", scene, "map\\ter\\Drama\\")
  return true
end
function init_moving_camera(form)
  create_scene(form)
  local scene = nx_value("drama_sel_scene")
  local world = nx_value("world")
  world.MainScene = scene
  local ini = nx_execute("util_functions", "get_ini", "ini\\SelectBook\\books.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("ini\\SelectBook\\books.ini" .. get_msg_str("msg_120"))
    return false
  end
  local sect = ini:FindSectionIndex(nx_string(form.bookid))
  if sect < 0 then
    return
  end
  local model_file = ini:ReadString(sect, "Model", "")
  local helper = ini:ReadString(sect, "Helper", "")
  local pos_x = ini:ReadFloat(sect, "ModelX", 0)
  local pos_y = ini:ReadFloat(sect, "ModelY", 0)
  local pos_z = ini:ReadFloat(sect, "ModelZ", 0)
  local angle_x = ini:ReadFloat(sect, "AngleX", 0)
  local angle_y = ini:ReadFloat(sect, "AngleY", 0)
  local angle_z = ini:ReadFloat(sect, "AngleZ", 0)
  local max_value = ini:ReadFloat(sect, "Max", 0)
  local min_value = ini:ReadFloat(sect, "Min", 0)
  local time = ini:ReadFloat(sect, "Time", 0)
  local m_name = ini:ReadString(sect, "MName", "")
  local c_x = ini:ReadFloat(sect, "CameraX", 0)
  local c_y = ini:ReadFloat(sect, "CameraY", 0)
  local c_z = ini:ReadFloat(sect, "CameraZ", 0)
  local ca_x = ini:ReadFloat(sect, "CAngleX", 0)
  local ca_y = ini:ReadFloat(sect, "CAngleY", 0)
  local ca_z = ini:ReadFloat(sect, "CAngleZ", 0)
  if nx_running(nx_current(), "update_camera", scene.camera) then
    nx_kill(nx_current(), "update_camera", scene.camera)
  end
  local model_id = form.model_id
  if nx_is_valid(model_id) then
    scene:Delete(model_id)
  end
  local model = scene:Create("Model")
  model.AsyncLoad = false
  model.ModelFile = "map\\" .. model_file
  model:Load()
  model.Loop = true
  model:SetPosition(pos_x, pos_y, pos_z)
  model:SetAngle(angle_x, angle_y, angle_z)
  scene:AddObject(model, 10)
  form.model_id = model
  form.helper_name = helper
  scene.camera:SetPosition(c_x, c_y, c_z)
  scene.camera:SetAngle(ca_x, ca_y, ca_z)
  scene.load_editor = false
  if load_scene_res(form) then
    nx_pause(3)
    local terrain = scene.terrain
    while not scene.terrain.LoadFinish do
      nx_pause(0.1)
    end
  end
  scene.terrain.WaterVisible = true
  scene.terrain.GroundVisible = true
  scene.terrain.VisualVisible = true
  scene.terrain.HelperVisible = true
  local camera = scene.camera
  change_lbl_alhpa(form, 2)
  if nx_is_valid(form) then
    form.lbl_back.BlendAlpha = 0
  end
  if nx_is_valid(scene) and nx_is_valid(scene.camera) then
    nx_execute(nx_current(), "update_camera", camera, model, helper)
  end
end
function update_camera(camera, model, helper)
  while nx_is_valid(camera) and nx_is_valid(model) do
    local x, y, z = model:GetHelperPosition("", helper)
    if x == nil then
      break
    end
    camera:SetPosition(x, y, z)
    x, y, z = model:GetHelperAngle("", helper)
    camera:SetAngle(x, y, z)
    nx_pause(0)
  end
end
function change_lbl_alhpa(form, all_time)
  local alpha = 255
  local delta_alpha = 255 / (all_time / 0.01)
  while true do
    local sec = nx_pause(0.01)
    alpha = alpha - nx_int(delta_alpha)
    if alpha <= 0 then
      break
    end
    if not nx_is_valid(form) then
      return
    end
    form.lbl_back.BlendAlpha = alpha
  end
end
