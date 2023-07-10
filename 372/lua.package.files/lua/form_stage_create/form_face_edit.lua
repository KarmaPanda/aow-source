require("share\\view_define")
require("util_functions")
require("util_gui")
require("role_composite")
require("util_functions")
require("define\\camera_mode")
require("scene")
require("form_stage_create\\form_create")
local SelectTexture = "face_5;b_face_1"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local FaceData = "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;100;50;"
function main_form_init(self)
  self.loaded = false
  self.obj = nx_null()
  self.skin_face = nx_null()
  self.role_actor2 = nx_null()
  self.left_rotate_down = false
  self.right_rotate_down = false
  return 1
end
function actor2_face_data()
  if FaceData ~= "" and FaceData ~= nil then
    local face = nx_string(nx_string(FaceData) .. nx_string(SelectTexture))
    return face
  end
  return ""
end
function init_face_data()
  FaceData = "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;50;50;" .. "50;50;50;50;50;50;50;50;50;100;50;"
end
local BONE_INFO = "bone_info"
local FACE_INFO = "face_info"
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function clear_face_data()
  local bone_info = nx_value(BONE_INFO)
  if nx_is_valid(bone_info) then
    nx_destroy(bone_info)
  end
  local face_info = nx_value(FACE_INFO)
  if nx_is_valid(face_info) then
    nx_destroy(face_info)
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if self.loaded then
    return 1
  end
  self.variation_box.Visible = false
  self.variation_box.Fixed = false
  if not nx_is_valid(self.scenebox_1.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", self.scenebox_1)
  end
  local CreateForm = nx_value("form_stage_create\\form_create")
  self.obj = get_role_face(CreateForm)
  if CreateForm.sex == 0 then
    self.skin_face = "b_face"
  else
    self.skin_face = "g_face"
  end
  self.role_actor2 = CreateForm.role_actor2
  self.loaded = true
  nx_execute(nx_current(), "form_showrole", self)
  nx_execute(nx_current(), "tick_rotate", self)
  self.listbox_face.SelectIndex = 0
  self.model_path.Text = "face_2"
  on_listbox_face_select_double_click(self.listbox_face)
  set_face_type(self)
  return 1
end
function set_face_type(form)
  local file_name = "face_1"
  local index = 1
  while nx_file_exists(nx_resource_path() .. "obj\\char\\b_face\\" .. file_name .. "\\face.ini") do
    form.listbox_face:AddString(nx_widestr(file_name))
    index = index + 1
    file_name = nx_string("face_" .. nx_string(index))
  end
end
function close_btn_click(self)
  local form = self.Parent
  set_standard_face(form)
  set_camera_distance_offsetpos(2.5, 0, 0, 0)
  form:Close()
  nx_destroy(form)
  return 1
end
function set_camera_distance_offsetpos(Distance, x, y, z)
  local scene = nx_value("game_scene")
  local login_control = scene.login_control
  if nx_is_valid(login_control) then
    login_control:SetTargetOffsetPoint(x, y, z)
    login_control:SetCameraDirect(894, 12.4, 495.7, 0, 3.05, 0)
    login_control:SetCameraCurDistance(Distance)
  end
end
function on_fixbtn_face_click(self)
  local form = self.ParentForm
  FaceData = get_face_data(form)
  local CreateForm = nx_value("form_stage_create\\form_create")
  set_camera_distance_offsetpos(2.5, 0, 0, 0)
  form:Close()
  nx_destroy(form)
end
function hint_btn_click(self)
  local form = self.Parent
  form:Close()
  return 1
end
function select_path_btn_click(self)
  local form = self.Parent
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "story_editor\\form_filename", true, false)
  dialog.path = nx_resource_path() .. "\\obj\\char\\b_face\\"
  dialog.ext = "*.ini"
  dialog.scene_name = true
  dialog.select_node = true
  dialog.select_file = true
  dialog:ShowModal()
  local res, new_name = nx_wait_event(100000000, dialog, "filename_return")
  if res == "cancel" then
    return 0
  end
  self.path = new_name
  form.model_path.Text = nx_widestr(self.path)
  return 1
end
function brow_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_3")
  return 1
end
function glabella_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_2")
  return 1
end
function brow_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_1")
  return 1
end
function eye_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_6")
  return 1
end
function eye_scale_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_5")
  return 1
end
function canthus_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_4")
  return 1
end
function on_nose_bridge_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_7")
  return 1
end
function on_nose_head_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_8")
end
function on_nose_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_9")
  return 1
end
function on_ear_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_10")
  return 1
end
function on_ear_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_11")
end
function on_ear_size_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_12")
end
function on_cheekbone_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_13")
end
function on_cheekbone_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_15")
end
function on_cheekbone_size_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_14")
end
function on_lip_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_16")
end
function on_toplip_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_17")
end
function on_bottomlip_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_18")
end
function on_mandible_shape_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_19")
end
function on_mandible_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_20")
end
function on_chin_pos_changed(self, value)
  local form = self.Parent
  set_changed(form, self.HorizonValue, self.VerticalValue, "face_21")
end
function on_eye_horizon_changed(self, value)
  local form = self.Parent
  local actor2 = form.obj
  self.VerticalValue = 50
  set_actor2_parameter(actor2, self.HorizonValue, 0, "face_22", nx_float(0.001), nx_float(0.05))
end
function get_mid_value(Value, ScaleValue)
  local lvalue = (nx_number(Value) - 50) * nx_number(ScaleValue)
  return lvalue
end
function set_changed(form, HorizonValue, VerticalValue, index)
  if not nx_is_valid(form.obj) then
    return
  end
  local actor2 = form.obj
  set_actor2_parameter(actor2, HorizonValue, VerticalValue, index, nx_float(4.0E-4), 0)
end
function set_actor2_parameter(actor2, horizon_value, vertical_value, index, fRatio, offset)
  if not nx_is_valid(actor2) then
    return
  end
  get_face_info()
  get_bone_info()
  local face_info = get_global_list(FACE_INFO)
  local bone_info = get_global_list(BONE_INFO)
  if fRatio == nil then
    fRatio = 4.0E-4
    offset = 0
  end
  if horizon_value == nil or vertical_value == nil or horizon_value == "face_22" then
    horizon_value = 50
    vertical_value = 50
    index = nx_string("face_22")
  end
  if index == nx_string("face_22") then
    fRatio = 0.0025
    offset = 0.05
    vertical_value = 0
  end
  local horizon = get_mid_value(horizon_value, fRatio) - offset
  local vertical = get_mid_value(vertical_value, fRatio) - offset
  local node_info = face_info:GetChild(nx_string(index))
  if nx_is_valid(node_info) then
    local face_node_list = node_info:GetChildList()
    for i, face_node in pairs(face_node_list) do
      local node = bone_info:GetChild(face_node.Name)
      if nx_is_valid(node) then
        set_bone_pos(actor2, face_node.Name, horizon, vertical, node)
        set_bone_angle(actor2, face_node.Name, horizon, vertical, node)
        set_bone_scale(actor2, face_node.Name, horizon, vertical, node)
      end
    end
  end
end
function set_control_changed(form, self, index)
  if not nx_is_value(form.obj) then
    return
  end
  local actor2 = form.obj
  set_actor2_parameter(actor2, HorizonValue, VerticalValue, index, nx_float(4.0E-4), nx_float(0))
end
function write_bone_pos(actor2, iniinfo, horizon, vertical)
end
function set_bone_pos(actor2, boneinfo, horizon, vertical, node)
  local bonename = node.bone_name
  local x, y, z = actor2:GetBonePosition(bonename)
  local postion_x = nx_float(node.postion_x)
  local postion_y = nx_float(node.postion_y)
  local postion_z = nx_float(node.postion_z)
  local value = 0
  if postion_x ~= nx_float(0) then
    value = node.postion_cast_x == "x" and horizon or vertical
    x = postion_x * value
    actor2:SetBonePosition(bonename, x, y, z)
  end
  if postion_y ~= nx_float(0) then
    value = node.postion_cast_y == "x" and horizon or vertical
    y = postion_y * value
    actor2:SetBonePosition(bonename, x, y, z)
  end
  if postion_z ~= nx_float(0) then
    value = node.postion_cast_z == "x" and horizon or vertical
    z = postion_z * value
    actor2:SetBonePosition(bonename, x, y, z)
  end
end
function set_bone_angle(actor2, boneinfo, horizon, vertical, node)
  local bonename = node.bone_name
  local x, y, z = actor2:GetBoneAngle(bonename)
  local angle_x = nx_float(node.angle_x)
  local angle_y = nx_float(node.angle_y)
  local angle_z = nx_float(node.angle_z)
  local value = 0
  if angle_x ~= nx_float(0) then
    value = node.angle_cast_x == "x" and horizon or vertical
    x = angle_x * value
    actor2:SetBoneAngle(bonename, x, y, z)
  end
  if angle_y ~= nx_float(0) then
    value = node.angle_cast_y == "x" and horizon or vertical
    y = angle_y * value
    actor2:SetBoneAngle(bonename, x, y, z)
  end
  if angle_z ~= nx_float(0) then
    value = node.angle_cast_z == "x" and horizon or vertical
    z = angle_z * value
    actor2:SetBoneAngle(bonename, x, y, z)
  end
end
function set_bone_scale(actor2, boneinfo, horizon, vertical, node)
  local bonename = node.bone_name
  local x, y, z = actor2:GetBoneScale(bonename)
  local scale_x = nx_float(node.scale_x)
  local scale_y = nx_float(node.scale_y)
  local scale_z = nx_float(node.scale_z)
  local value = 0
  if scale_x ~= nx_float(0) then
    scale_x = nx_float(scale_x) > nx_float(0) and nx_float(scale_x) or nx_float(scale_x)
    value = node.scale_cast_x == "x" and horizon or vertical
    x = 1 + scale_x * value
    actor2:SetBoneScale(bonename, x, y, z)
  end
  if scale_y ~= nx_float(0) then
    scale_y = nx_float(scale_y) > nx_float(0) and nx_float(scale_y) or nx_float(scale_y)
    value = node.scale_cast_y == "x" and horizon or vertical
    y = 1 + scale_y * value
    actor2:SetBoneScale(bonename, x, y, z)
  end
  if scale_z ~= nx_float(0) then
    scale_z = nx_float(scale_z) > nx_float(0) and nx_float(scale_z) or nx_float(scale_z)
    value = node.scale_cast_z == "x" and horizon or vertical
    z = 1 + scale_z * value
    actor2:SetBoneScale(bonename, x, y, z)
  end
end
function form_showrole(form)
  local actor2 = form.obj
  if not nx_is_valid(actor2) then
    return
  end
  while true do
    if not nx_is_valid(actor2) or actor2.LoadFinish then
      break
    end
    nx_pause(0.1)
  end
  if not nx_is_valid(form) then
    form.scenebox_1.Scene:Delete(actor2)
    return 0
  end
  local weather = form.scenebox_1.Scene.Weather
  weather.SunGlowColor = "255,249,201,244"
  weather.AmbientColor = "150,140,148,163"
  weather.SpecularColor = "150,140,148,163"
  weather.GlobalAmbientColor = "150,140,148,163"
  weather.AmbientIntensity = 1.8
  weather.SunGlowIntensity = 1.6
  weather.SpecularIntensity = 1.8
end
function get_face_info()
  local face_info = get_global_list(FACE_INFO)
  if face_info:GetChildCount() > 0 then
    return
  end
  local file_path = "ini\\bone\\faceinfo.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. file_path)
  if not ini:LoadFromFile() then
    return
  end
  local sections = ini:GetSectionList()
  for i, sect in pairs(sections) do
    local bone_list = ini:GetItemValueList(nx_string(sect), nx_string("Bone"))
    local node = face_info:CreateChild(sect)
    for j, info in pairs(bone_list) do
      node:CreateChild(info)
    end
  end
  nx_destroy(ini)
end
function get_bone_info()
  local bone_info = get_global_list(BONE_INFO)
  if bone_info:GetChildCount() > 0 then
    return
  end
  local file_path = "ini\\bone\\boneinfo.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. file_path)
  if not ini:LoadFromFile() then
    return
  end
  local sections = ini:GetSectionList()
  for i, sect in pairs(sections) do
    local Postion = ini:ReadString(sect, "Postion", "0,0,0")
    local PostionCast = ini:ReadString(sect, "PostionCast", "0,0,0")
    local Angle = ini:ReadString(sect, "Angle", "0,0,0")
    local AngleCast = ini:ReadString(sect, "AngleCast", "0,0,0")
    local Scale = ini:ReadString(sect, "Scale", "0,0,0")
    local ScaleCast = ini:ReadString(sect, "ScaleCast", "0,0,0")
    local BoneName = ini:ReadString(sect, "BoneName", "")
    local node = bone_info:CreateChild(sect)
    local tuple = util_split_string(Postion, ",")
    node.postion_x = nx_float(tuple[1])
    node.postion_y = nx_float(tuple[2])
    node.postion_z = nx_float(tuple[3])
    tuple = util_split_string(PostionCast, ",")
    node.postion_cast_x = tuple[1]
    node.postion_cast_y = tuple[2]
    node.postion_cast_z = tuple[3]
    tuple = util_split_string(Angle, ",")
    node.angle_x = nx_float(tuple[1])
    node.angle_y = nx_float(tuple[2])
    node.angle_z = nx_float(tuple[3])
    tuple = util_split_string(AngleCast, ",")
    node.angle_cast_x = tuple[1]
    node.angle_cast_y = tuple[2]
    node.angle_cast_z = tuple[3]
    tuple = util_split_string(Scale, ",")
    node.scale_x = nx_float(tuple[1])
    node.scale_y = nx_float(tuple[2])
    node.scale_z = nx_float(tuple[3])
    tuple = util_split_string(ScaleCast, ",")
    node.scale_cast_x = tuple[1]
    node.scale_cast_y = tuple[2]
    node.scale_cast_z = tuple[3]
    node.bone_name = BoneName
  end
  nx_destroy(ini)
end
function set_standard_face(form)
  form.model_path.Text = ""
  local index = ""
  for i = 1, 21 do
    index = nx_string("face_" .. i)
    control = get_face_control(form, index)
    control.HorizonValue = 50
    control.VerticalValue = 50
    set_actor2_parameter(form.obj, 50, 50, index, nx_float(4.0E-4), nx_float(0))
  end
  control = get_face_control(form, "face_22")
  control.HorizonValue = 100
  control.VerticalValue = 50
  set_actor2_parameter(form.obj, 100, 50, "face_22", nx_float(0.001), nx_float(0.05))
end
function set_save_face(form, file_name)
  local path = "obj\\char\\" .. form.skin_face .. "\\" .. file_name
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. path)
  if not ini:LoadFromFile() then
    nx_msgbox(get_msg_str("msg_411") .. ini.FileName)
    return
  end
  local index = nx_string("face_" .. 1)
  local control
  for i = 1, 22 do
    index = nx_string("face_" .. i)
    control = get_face_control(form, index)
    ini:WriteString(index, "HorizonValue", nx_string(control.HorizonValue))
    ini:WriteString(index, "VerticalValue", nx_string(control.VerticalValue))
  end
  ini:SaveToFile()
  nx_destroy(ini)
end
function save_btn_click(self)
  local form = self.Parent
  local file_name = nx_string(form.model_path.Text) .. "\\face.ini"
  set_save_face(form, nx_string(file_name))
  return 1
end
function set_MaterialFile(form, skinface)
  local file_name = form.skin_face .. "\\" .. skinface .. "\\face.ini"
  local actor2 = form.obj
  local skin = actor2:GetLinkObject(form.skin_face)
  on_set_face(form, file_name)
  form.model_path.Text = nx_widestr(skinface)
  if not nx_is_valid(skin) then
    return
  end
  local MaterialNameList = skin:GetMaterialNameList()
  if type(MaterialNameList) ~= "table" then
    nx_msgbox(get_msg_str("msg_412"))
    return
  end
  local Texture = skinface .. "\\" .. form.skin_face .. "_1.dds"
  if not skin:SetMaterialValue(MaterialNameList[1], "DiffuseMap", Texture) then
    nx_msgbox("::::")
  end
  if not skin:ReloadMaterialTextures() then
    nx_msgbox(get_msg_str("msg_413"))
  end
  SelectTexture = nx_string(skinface) .. ";" .. nx_string("b_face_1") .. ";"
end
function refresh_xmod(form)
  local CreateForm = nx_value("form_stage_create\\form_create")
  local actor2 = CreateForm.role_actor2:GetLinkObject("actor_role")
  local file_name = nx_string(form.model_path.Text)
  local path = "obj\\char\\" .. form.skin_face .. "\\" .. file_name .. "\\" .. "composite.ini"
  local skin = actor2:GetLinkObject("create_role_face")
  actor2:DeleteSkin("create_role_face")
  local world = nx_value("world")
  world:Delete(skin)
  local scene = world.MainScene
  local sex = form.skin_face == "b_face" and 0 or 1
  local child_actor2 = nx_execute("role_composite", "create_role_face", scene, sex, path)
  if not nx_is_valid(child_actor2) then
    return 1
  end
  actor2:LinkToPoint("actor_role_face", "mount::Point01", child_actor2)
  actor2:AddChildAction(child_actor2)
  child_actor2:AddParentAction(actor2)
  form.obj = get_role_face(CreateForm)
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:SetActFace(CreateForm.role_actor2, child_actor2)
  end
end
function on_set_face(form, file_name)
  local path = "obj\\char\\" .. file_name
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. path)
  if not ini:LoadFromFile() then
    nx_msgbox("ini.FileName = " .. nx_string(ini.FileName))
    return
  end
  local index = nx_string("face_" .. 1)
  for i = 1, 22 do
    index = nx_string("face_" .. i)
    local control = get_face_control(form, index)
    control.HorizonValue = ini:ReadFloat(index, "HorizonValue", 50)
    control.VerticalValue = ini:ReadFloat(index, "VerticalValue", 50)
  end
  nx_destroy(ini)
end
function get_face_data(form)
  local strtext = ""
  local strHorizonValue = ""
  local strVerticalValue = ""
  local index = ""
  local control
  for i = 1, 22 do
    index = nx_string("face_" .. i)
    control = get_face_control(form, index)
    strHorizonValue = nx_string(control.HorizonValue)
    strVerticalValue = nx_string(control.VerticalValue)
    strtext = strtext .. strHorizonValue .. ";" .. strVerticalValue .. ";"
  end
  return strtext
end
function get_face_control(form, index)
  if index == "face_1" then
    return form.brow_shape_rect
  elseif index == "face_2" then
    return form.glabella_pos_rect
  elseif index == "face_3" then
    return form.brow_pos_rect
  elseif index == "face_4" then
    return form.canthus_shape_rect
  elseif index == "face_5" then
    return form.eye_scale_rect
  elseif index == "face_6" then
    return form.eye_pos_rect
  elseif index == "face_7" then
    return form.nose_bridge
  elseif index == "face_8" then
    return form.nose_head
  elseif index == "face_9" then
    return form.nose_pos
  elseif index == "face_10" then
    return form.ear_pos
  elseif index == "face_11" then
    return form.ear_shape
  elseif index == "face_12" then
    return form.ear_size
  elseif index == "face_13" then
    return form.cheekbone_pos
  elseif index == "face_14" then
    return form.cheekbone_size
  elseif index == "face_15" then
    return form.cheekbone_shape
  elseif index == "face_16" then
    return form.lip_pos
  elseif index == "face_17" then
    return form.toplip_shape
  elseif index == "face_18" then
    return form.bottomlip_shape
  elseif index == "face_19" then
    return form.mandible_shape
  elseif index == "face_20" then
    return form.mandible_pos
  elseif index == "face_21" then
    return form.chin_pos
  elseif index == "face_22" then
    return form.eye
  end
end
function on_turn_left_btn_push(btn)
  local form = btn.Parent
  form.left_rotate_down = true
end
function on_turn_left_btn_click(btn)
  local form = btn.Parent
  form.left_rotate_down = false
end
function on_turn_left_btn_lost_capture(btn)
  local form = btn.Parent
  form.left_rotate_down = false
end
function on_turn_right_btn_push(btn)
  local form = btn.Parent
  form.right_rotate_down = true
end
function on_turn_right_btn_click(btn)
  local form = btn.Parent
  form.right_rotate_down = false
end
function on_turn_right_btn_lost_capture(btn)
  local form = btn.Parent
  form.right_rotate_down = false
end
function tick_rotate(form)
  while true do
    local step_time = nx_pause(0.01)
    if nx_is_valid(form) then
      local actor = form.role_actor2
      if nx_is_valid(actor) then
        local angle = 0
        if form.left_rotate_down == true then
          angle = -step_time * 2.5
        elseif form.right_rotate_down == true then
          angle = step_time * 2.5
        end
        actor:SetAngle(0, actor.AngleY + angle, 0)
      end
    else
      return
    end
  end
end
function on_Variation_Btn_click(self)
  local form = self.Parent
  form.variation_box.Visible = not form.variation_box.Visible
  if form.variation_box.Visible then
    set_control_image(form, 0)
  end
end
function set_control_image(form, sex)
  local path = "ini\\bone\\boneimage.ini"
  local ini = nx_create("IniDocument")
  ini.FileName = nx_string(nx_resource_path() .. path)
  if not ini:LoadFromFile() then
    return
  end
  local Imagelist = ini:GetItemValueList(nx_string(sex), nx_string("Image"))
  for i, sect in pairs(Imagelist) do
    form.ImageControlGridVariation:AddItem(nx_int(i - 1), sect, "", nx_int(1), nx_int(0))
  end
end
function on_ImageControlGridVariation_select_changed(grid, index)
  local form = grid.ParentForm
  local ItemImage = grid:GetItemImage(index)
  local actor2 = form.obj
  if index == 1 then
    ItemImage = "obj\\char\\g_face\\face\\g_face03.mtl"
  elseif index == 2 then
    ItemImage = "obj\\char\\g_face\\face\\g_face03.mtl"
  elseif index == 0 then
    ItemImage = "obj\\char\\g_face\\face\\g_face03.mtl"
  end
  local skin = actor2:GetLinkObject("b_face1")
end
function on_listbox_face_select_double_click(self)
  local select = self.SelectIndex + 1
  local form = self.Parent
  if nx_ws_equal(form.model_path.Text, nx_widestr("face_" .. nx_string(select))) then
    return
  end
  form.model_path.Text = nx_widestr("face_" .. nx_string(select))
  refresh_xmod(form)
  set_MaterialFile(form, "face_" .. nx_string(select))
  local file_name = form.skin_face .. "\\face_" .. nx_string(select) .. "\\face.ini"
  local path = "obj\\char\\" .. file_name
  local res = nx_function("ext_set_file_Attribute_Nor", nx_resource_path() .. path)
end
function svn_command(path_name, op)
  local command = "TortoiseProc.exe /path:" .. nx_string(path_name) .. " /command:" .. op
  local ret = nx_function("ext_win_exec", command)
  if false == ret then
    nx_msgbox(get_msg_str("msg_275"))
  end
  return ret
end
function svn_update(path_name)
  svn_command(path_name, "update")
end
function svn_commit(path_name)
  svn_command(path_name, "commit")
end
function svn_add(path_name)
  svn_command(path_name, "add")
end
function svn_remove(path_name)
  svn_command(path_name, "remove")
end
function svn_cleanup(path_name)
  svn_command(path_name, "cleanup")
end
function svn_lock(path_name)
  svn_command(path_name, "lock")
end
function svn_unlock(path_name)
  svn_command(path_name, "unlock")
end
function svn_checkout(path_name)
  svn_command(path_name, "checkout")
end
