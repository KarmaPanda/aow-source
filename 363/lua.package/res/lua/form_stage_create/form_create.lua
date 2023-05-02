require("util_functions")
require("const_define")
require("util_gui")
require("utils")
require("util_static_data")
require("role_composite")
require("scenario_npc_manager")
require("scene")
require("form_stage_create\\create_logic")
require("tips_data")
local Y_VALUE = 0.9
local Z_VALUE = 2.25
local Y_ANGLE = 8
local CREATE_NEW_INI = "ini\\form\\creat_new.ini"
local RESET_FACE_MAX_BEFOREHAND = 50
local face_ui_info = {
  face_1 = "ui_create_mx",
  face_2 = "ui_create_mg",
  face_3 = "ui_create_mm",
  face_4 = "ui_create_yx",
  face_5 = "ui_create_yd",
  face_6 = "ui_create_yw",
  face_7 = "ui_create_bx",
  face_8 = "ui_create_bt",
  face_9 = "ui_create_bw",
  face_10 = "ui_create_ew",
  face_11 = "ui_create_ex",
  face_12 = "ui_create_ed",
  face_13 = "ui_create_qw",
  face_14 = "ui_create_qx",
  face_15 = "ui_create_qd",
  face_16 = "ui_create_zw",
  face_17 = "ui_create_sc",
  face_18 = "ui_create_xc",
  face_19 = "ui_create_xex",
  face_20 = "ui_create_xjw",
  face_21 = "ui_create_xbw",
  face_22 = "ui_create_yk"
}
function get_pi(degree)
  return math.pi * degree / 180
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_method(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local method_list = nx_method_list(ent)
  log("method_list bagin")
  for _, method in ipairs(method_list) do
    log("method = " .. method)
  end
  log("method_list end")
end
function on_main_form_init(form)
  return 1
end
function on_main_form_open(form)
  local create_role = nx_create("CreateRole")
  nx_set_value("create_role", create_role)
  show_new_role_controls(form, false)
  local world = nx_value("world")
  world:CollectResource()
  create_role:LoadResource()
  form.role_actor2 = nx_null()
  form.role_person = nx_null()
  init_role_info(form)
  change_create_size(form, true)
  form.sex = 0
  form.book = "book1"
  init_camera()
  set_main_rbtn_offset_info(form)
  local scene = nx_value("game_scene")
  nx_execute("create_scene", "clear_game_control", scene)
  form.rbtn_man.is_init_role_info = true
  form.rbtn_woman.is_init_role_info = true
  if nx_find_custom(form, "select_sex") then
    form.groupbox_1.Visible = false
    if form.select_sex == 1 then
      form.rbtn_woman.Checked = true
    else
      form.rbtn_man.Checked = true
    end
  else
    form.rbtn_man.Checked = true
  end
  change_create_or_frist_name(form, true)
  init_equip_grid_info(form)
  init_weapon_grid_info(form)
  init_wuxue_grid_info(form)
  init_role_grid_info(form)
  init_newequip_grid_info(form)
  init_newweapon_grid_info(form)
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("SceneBlendColor", form)
  form.lbl_bg.speed_time = 100
  form.lbl_bg.stop_time = 3
  form.lbl_bg.cur_blend = 255
  form.lbl_bg.BlendColor = "255,255,255,255"
  asynor:AddExecute("SceneBlendColor", form, nx_float(0), form.lbl_bg, nx_current(), "call_back_blend_color_visible")
  local game_config = nx_value("game_config")
  if not nx_find_custom(game_config, "login_type") then
    game_config.login_type = "2"
  end
  if game_config.login_type == "2" then
    reset_form_ui(form)
    add_light(scene)
  else
    nx_execute("terrain\\terrain", "load_scene_screeneffect", scene, nx_resource_path() .. "ini\\create\\weather_login\\login_3\\", true)
  end
end
function init_role_info(form)
  form.beforehand = 1
  form.cloth = 1
  form.pants = 1
  form.shoes = 1
  form.hat = 1
  form.feature = 1
  form.photo = 1
  form.weapon = ""
  form.item_type = ""
  local create_role = nx_value("create_role")
  create_role:InitPlayerFaceData()
  create_role.PlayerFaceBeard = 1
  create_role.PlayerFaceFeature = 1
end
function on_main_form_close(form)
  local frist_name = nx_value("form_stage_main\\form_firstname_list")
  recover_play_dof_info(form)
  if nx_is_valid(frist_name) then
    frist_name:Close()
  end
  if nx_running(nx_current(), "exe_action_finished") then
    nx_kill(nx_current(), "exe_action_finished")
  end
  local open_dialog = nx_value("form_common\\form_open_file")
  if nx_is_valid(open_dialog) then
    open_dialog:Close()
  end
  local save_dialog = nx_value("form_common\\form_save_file")
  if nx_is_valid(save_dialog) then
    save_dialog:Close()
  end
  nx_call("form_stage_create\\form_face_edit", "clear_face_data")
  nx_set_value("form_stage_create\\form_create", nil)
  local create_role = nx_value("create_role")
  nx_destroy(create_role)
  remove_role(form)
  if nx_is_valid(form.role_person) then
    local world = nx_value("world")
    world:Delete(form.role_person)
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local file = account .. "\\func_" .. nx_string(game_config.server_name) .. ".ini"
  nx_function("ext_delete_file", file)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(CREATE_NEW_INI)
  end
  local scene = nx_value("gmae_scene")
  if nx_is_valid(scene) and nx_find_custom(scene, "weather_model") and nx_is_valid(scene.weather_model) then
    scene:Delete(scene.weather_model)
  end
  if nx_is_valid(scene) and nx_find_custom(scene, "light") and nx_is_valid(scene.light) then
    scene:Delete(scene.light)
  end
  set_camera_direct("far")
end
function player_face_random_action(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(form) or not nx_find_custom(form, "role_actor2") then
    return nil
  end
  if not nx_is_valid(form.role_actor2) then
    return nil
  end
  local role_actor2 = form.role_actor2
  role_actor2.random_eyes_time = math.random(2) + 4
  asynor:AddExecute("FaceRandomAction", role_actor2, nx_float(0))
end
function change_create_size(form, is_checked)
  local gui = nx_value("gui")
  form.groupbox_main.Width = gui.Width
  form.groupbox_main.Height = gui.Height
  form.lbl_bg.Width = gui.Width
  form.lbl_bg.Height = gui.Height
  form.lbl_bg.Visible = true
  if not nx_is_valid(form.role_person) and (nil == is_checked or false == is_checked) then
    if form.rbtn_beforehand.Checked then
      on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
    else
      form.rbtn_beforehand.Checked = true
    end
  end
  local name_form = nx_value("form_stage_main\\form_firstname_list")
  if nx_is_valid(name_form) then
  end
end
function on_rbtn_man_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    form.sex = 0
    if btn.is_init_role_info then
      init_role_info(form)
    end
    checked_role_changed(form)
    btn.is_init_role_info = true
  end
  init_role_grid_info(form)
  return
end
function on_rbtn_woman_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    form.sex = 1
    if btn.is_init_role_info then
      init_role_info(form)
    end
    checked_role_changed(form)
    btn.is_init_role_info = true
  end
  init_role_grid_info(form)
  return
end
function checked_role_changed(form)
  form.rbtn_woman.Enabled = false
  form.rbtn_man.Enabled = false
  form.btn_back_create.Enabled = false
  form.btn_back_login.Enabled = false
  form.btn_random.Enabled = false
  init_select_role(form, "logoin_stand_2")
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_beforehand.Checked then
    on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
  else
    form.rbtn_beforehand.Checked = true
  end
end
function init_select_role(form, default_action)
  remove_role(form)
  form.role_actor2 = create_cur_role(form, default_action)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_actor2) then
    return
  end
  form.role_actor2.create_module = true
  player_face_random_action(form)
end
function on_btn_enter_frist_name_click(btn)
  local form = btn.ParentForm
  change_create_or_frist_name(form, false)
end
function on_btn_enter_game_click(btn)
  local form = btn.ParentForm
  enter_game(form)
end
function on_btn_enter_game_click(btn)
  local form = btn.ParentForm
  enter_game(form)
end
function enter_game(form)
  local frist_name = nx_value("form_stage_main\\form_firstname_list")
  local ClientDataFetch = nx_value("ClientDataFetch")
  if nx_is_valid(ClientDataFetch) then
    ClientDataFetch:BeginAct(3)
  end
  local role_name = nx_widestr("")
  if nx_is_valid(frist_name) then
    role_name = frist_name.ipt_name.Text
  end
  if nx_ws_length(role_name) == 0 then
    disp_error(util_text("ui_NoRoleName"))
    return 0
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return 0
  end
  local rule_info = CheckWords:GetNameRule()
  if #rule_info < 4 then
    return 0
  end
  if nx_int(rule_info[1]) == nx_int(1) then
    local bRes = CheckWords:CheckBadName(nx_widestr(role_name), nx_int(0))
    if nx_string(bRes) ~= nx_string("0") then
      if nx_string(bRes) == nx_string("1") then
        disp_error(util_text("ui_NameLenth_error"))
        return 0
      elseif nx_string(bRes) == nx_string("2") then
        disp_error(util_text("ui_FirstName_error"))
        return 0
      elseif nx_string(bRes) == nx_string("3") then
        disp_error(util_text("ui_NoSecondName"))
        return 0
      elseif nx_string(bRes) == nx_string("4") then
        disp_error(util_text("ui_SecondName_error"))
        return 0
      elseif nx_string(bRes) == nx_string("5") then
        disp_error(util_text("ui_Cant_Single_FirstName"))
        return 0
      elseif nx_string(bRes) == nx_string("6") then
        disp_error(util_text("ui_Cant_Double_FirstName"))
        return 0
      end
    end
  end
  local bRes = CheckWords:CheckSecondNames(nx_widestr(role_name))
  if not bRes then
    disp_error(util_text("ui_CheckSecondName"))
    return 0
  end
  local result = check_name_separator(role_name, "role_name")
  if 0 < result then
    disp_error(util_text("ui_SeparatorError_" .. nx_string(result)))
    return 0
  end
  local create_role = nx_value("create_role")
  local sex = form.sex
  local bookid = form.bookid
  if not nx_find_custom(form, "school_id") then
    form.school_id = ""
  end
  local school_id = form.school_id
  local photo = form.photo
  local face = create_role:GetPlayerFaceData()
  local hat = get_equip_info("hat", sex, nx_int(form.hat) - 1)
  local c_, cloth = create_role:GetEquipInfo(nx_string("cloth"), nx_int(sex), nx_int(form.cloth) - 1)
  local p_, pants = create_role:GetEquipInfo(nx_string("pants"), nx_int(sex), nx_int(form.pants) - 1)
  local s_, shoes = create_role:GetEquipInfo(nx_string("shoes"), nx_int(sex), nx_int(form.shoes) - 1)
  local p_ = get_equip_info("photo", sex, nx_int(form.photo) - 1, true)
  nx_execute("client", "create_role", 0, role_name, sex, 0, 0, 1, bookid, p_, face, "1", hat, cloth, pants, shoes, school_id)
  return 1
end
function on_btn_back_create_click(btn)
  local form = btn.ParentForm
  change_create_or_frist_name(form, true)
  return 1
end
function on_btn_back_login_click(btn)
  nx_execute("stage", "set_current_stage", "create")
  return 1
end
function change_create_or_frist_name(form, is_create)
  form.groupbox_main.Visible = is_create
  form.btn_enter_game.Visible = not is_create
  form.btn_back_create.Visible = not is_create
  form.lbl_23.Visible = not is_create
  local frist_name = nx_value("form_stage_main\\form_firstname_list")
  if not is_create then
    if not nx_is_valid(frist_name) then
      frist_name = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_firstname_list", true, false)
      frist_name:Show()
      frist_name.Visible = true
    end
  elseif nx_is_valid(frist_name) then
    frist_name:Close()
  end
end
function create_cur_role(form, default_action)
  local ini = get_ini("ini\\form\\create_pos.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_name = "role_pos"
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    sec_name = "role_pos_new"
  end
  local index = ini:FindSectionIndex(nx_string(sec_name))
  if -1 == index then
    return
  end
  local str_pos = ini:ReadString(index, "pos", "0,0,0")
  local pos_list = util_split_string(str_pos, ",")
  local str_ang = ini:ReadString(index, "ang", "0")
  local ang_list = util_split_string(str_ang, ",")
  local sex = form.sex
  local hat = nx_int(form.hat) - nx_int(1)
  local cloth = nx_int(form.cloth) - nx_int(1)
  local pants = nx_int(form.pants) - nx_int(1)
  local shoes = nx_int(form.shoes) - nx_int(1)
  local hat_model = get_equip_info("hat", sex, hat)
  local cloth_model = get_equip_info("cloth", sex, cloth)
  local pants_model = get_equip_info("pants", sex, pants)
  local shoes_model = get_equip_info("shoes", sex, shoes)
  local actor2 = create_role_add_cur_scene(form, sex, nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]), nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]), default_action)
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  local skin_info = {
    [1] = {link_name = "hat", model_name = hat_model},
    [2] = {link_name = "cloth", model_name = cloth_model},
    [3] = {link_name = "pants", model_name = pants_model},
    [4] = {link_name = "shoes", model_name = shoes_model}
  }
  for i, info in ipairs(skin_info) do
    if info.model_name ~= nil and "" ~= info.model_name then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  nx_function("ext_set_role_create_finish", actor2, true)
  set_camera_direct("far")
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) then
    role_composite:LinkFaceSkin(actor2, form.sex, nx_int(form.beforehand), true)
  end
  local actor2_face = get_role_face_form_actor2(actor2)
  nx_execute("form_stage_create\\create_logic", "set_face_materialfile", actor2_face, form.sex, form.beforehand, form.feature)
  local create_role = nx_value("create_role")
  for i = 0, 21 do
    local index = nx_string("face_" .. i + 1)
    local value_list = create_role:GetPlayerFaceDetailHV(index)
    nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2_face, nx_int(value_list[1]), nx_int(value_list[2]), index, nx_float(4.0E-4), nx_float(0))
  end
  recover_play_dof_info(form)
  set_play_dof_info(form, actor2)
  return actor2
end
function get_role_face_form_actor2(role_actor2)
  local actor_role = role_actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
end
function on_rbtn_face_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_mianbu.Visible = true
    form.groupbox_mianbu.AbsTop = rbtn.AbsTop + rbtn.Height
    form.rbtn_meimao.Checked = true
    on_rbtn_face_prop_checked_changed(form.rbtn_meimao)
    form.groupbox_2.Visible = true
    set_camera_direct("near")
  else
    form.groupbox_2.Visible = false
    form.groupbox_mianbu.Visible = false
  end
end
function on_rbtn_feature_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_11, "feature", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_11.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_11.Visible = true
    local feature = form.feature
    set_group_box_rbtns_init(form, "rbtn_feature_", feature)
    set_camera_direct("near")
  else
    form.groupbox_11.Visible = false
  end
end
function on_rbtn_beforehand_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_6, "beforehand", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_6.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_6.Visible = true
    local beforehand = form.beforehand
    beforehand = fix_beforehand_index(form, beforehand)
    set_group_box_rbtns_init(form, "rbtn_", beforehand)
    set_camera_direct("near")
  else
    form.groupbox_6.Visible = false
  end
end
function on_rbtn_photo_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_13, "head", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_13.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_13.Visible = true
    local photo = form.photo
    set_group_box_rbtns_init(form, "rbtn_photo_", photo)
    set_camera_direct("far")
  else
    form.groupbox_13.Visible = false
  end
end
function on_rbtn_dress_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_8, "cloth", form.sex)
    set_rbtn_stage_photo(form.groupbox_9, "shoes", form.sex)
    set_rbtn_stage_photo(form.groupbox_10, "pants", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_7.Visible = true
    form.groupbox_7.AbsTop = rbtn.AbsTop + rbtn.Height
    local cloth = form.cloth
    set_group_box_rbtns_init(form, "rbtn_cloth_", cloth)
    local pants = form.pants
    set_group_box_rbtns_init(form, "rbtn_pants_", pants)
    local shoes = form.shoes
    set_group_box_rbtns_init(form, "rbtn_shoes_", shoes)
    set_camera_direct("far")
  else
    form.groupbox_7.Visible = false
  end
end
function on_rbtn_hairstyle_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_12, "hairstyle", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_12.Visible = true
    form.groupbox_12.AbsTop = rbtn.AbsTop + rbtn.Height
    local hat = form.hat
    set_group_box_rbtns_init(form, "rbtn_hat_", hat)
    set_camera_direct("near")
  else
    form.groupbox_12.Visible = false
  end
end
function on_rbtn_face_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local game_config = nx_value("game_config")
    if game_config.login_type == "1" then
      form.groupbox_2.AbsTop = rbtn.AbsTop - rbtn.Height / 2
    else
      form.groupbox_2.AbsTop = form.groupbox_mianbu.AbsTop + 150
      form.groupbox_2.AbsLeft = form.groupbox_mianbu.AbsLeft + 50
      form.lbl_21.Visible = false
    end
    local data_source = rbtn.DataSource
    local face_list = util_split_string(data_source, ",")
    form.trackrect_1.face_type = face_list[1]
    form.trackrect_2.face_type = face_list[2]
    form.trackrect_3.face_type = face_list[3]
    local gui = nx_value("gui")
    form.lbl_2.Text = gui.TextManager:GetText(face_ui_info[face_list[1]])
    form.lbl_11.Text = gui.TextManager:GetText(face_ui_info[face_list[2]])
    form.lbl_12.Text = gui.TextManager:GetText(face_ui_info[face_list[3]])
    local create_role = nx_value("create_role")
    if nx_string(face_list[1]) == nx_string("face_1") then
      set_trackrect_max(form.trackrect_1, 60, 60)
      set_trackrect_max(form.trackrect_2, 60, 60)
      set_trackrect_max(form.trackrect_3, 60, 60)
    else
      set_trackrect_max(form.trackrect_1, 100, 100)
      set_trackrect_max(form.trackrect_2, 100, 100)
      set_trackrect_max(form.trackrect_3, 100, 100)
    end
    local value_list = create_role:GetPlayerFaceDetailHV(face_list[1])
    form.trackrect_1.HorizonValue = nx_int(value_list[1])
    form.trackrect_1.VerticalValue = nx_int(value_list[2])
    value_list = create_role:GetPlayerFaceDetailHV(face_list[2])
    form.trackrect_2.HorizonValue = nx_int(value_list[1])
    form.trackrect_2.VerticalValue = nx_int(value_list[2])
    value_list = create_role:GetPlayerFaceDetailHV(face_list[3])
    form.trackrect_3.HorizonValue = nx_int(value_list[1])
    form.trackrect_3.VerticalValue = nx_int(value_list[2])
    form.lbl_21.AbsTop = rbtn.AbsTop + (rbtn.Height - form.lbl_21.Height) / 2
    form.lbl_21.AbsLeft = rbtn.AbsLeft + rbtn.Width + 20
  end
end
function on_trackrect_prop_value_changed(self)
  local form = self.ParentForm
  local face_type = self.face_type
  local actor2_face = get_role_face(form)
  nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2_face, self.HorizonValue, self.VerticalValue, face_type, nx_float(4.0E-4), nx_float(0))
  local create_role = nx_value("create_role")
  create_role:SetPlayerFaceDetailHV(face_type, self.HorizonValue, self.VerticalValue)
end
function set_main_rbtn_pos(groupbox, offset_btn)
  local child_control_list = groupbox:GetChildControlList()
  local offset_y = 32
  for _, rbtn in ipairs(child_control_list) do
    rbtn.Top = offset_y
    offset_y = offset_y + rbtn.Height
    if nx_id_equal(offset_btn, rbtn) then
      offset_y = offset_y + rbtn.offset_y
    end
  end
end
function set_main_rbtn_offset_info(form)
  form.rbtn_face.offset_x = 0
  form.rbtn_face.offset_y = form.groupbox_mianbu.Height
  form.rbtn_feature.offset_x = 0
  form.rbtn_feature.offset_y = form.groupbox_11.Height
  form.rbtn_beforehand.offset_x = 0
  form.rbtn_beforehand.offset_y = form.groupbox_6.Height
  form.rbtn_photo.offset_x = 0
  form.rbtn_photo.offset_y = form.groupbox_13.Height
  form.rbtn_dress.offset_x = 0
  form.rbtn_dress.offset_y = form.groupbox_7.Height
  form.rbtn_hairstyle.offset_x = 0
  form.rbtn_hairstyle.offset_y = form.groupbox_12.Height
end
function on_rbtn_beforehand_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    local str_sex = form.sex == 0 and "b_face" or "g_face"
    local face_id = face_list[2]
    local need_model_face = false
    if nx_find_custom(rbtn, "model_face_id") then
      face_id = rbtn.model_face_id
      need_model_face = true
    end
    if need_model_face == false then
      return
    end
    local face_path = "obj\\char\\" .. str_sex .. "\\face_" .. face_id .. "\\face.ini"
    local create_role = nx_value("create_role")
    if not nx_is_valid(create_role) then
      return
    end
    local actor2_face = get_role_face(form)
    if nil == actor2_face then
      return
    end
    local role_composite = nx_value("role_composite")
    if not nx_is_valid(role_composite) then
      return
    end
    if nx_int(face_id) <= nx_int(RESET_FACE_MAX_BEFOREHAND) then
      reset_face_model(actor2_face, form.sex)
    else
      role_composite:LinkFaceSkin(form.role_actor2, form.sex, nx_int(face_id), true)
    end
    create_role:ApplyAdvanceFace(face_path, actor2_face)
    form.beforehand = nx_int(face_id)
    create_role.PlayerFaceFeature = nx_int(form.beforehand)
    set_face_materialfile(actor2_face, form.sex, form.beforehand, form.feature)
  end
end
function on_rbtn_dress_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    model = get_equip_info(face_list[2], form.sex, nx_int(face_list[3]) - 1)
    nx_set_custom(form, face_list[2], face_list[3])
    refresh_actor_info(form)
  end
end
function on_rbtn_feature_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    local actor2_face = get_role_face(form)
    form.feature = face_list[3]
    local create_role = nx_value("create_role")
    create_role.PlayerFaceBeard = nx_int(face_list[3])
    set_face_materialfile(actor2_face, form.sex, form.beforehand, face_list[3])
  end
end
function on_rbtn_photo_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    model = get_equip_info(face_list[2], form.sex, nx_int(face_list[3]) - 1)
    nx_set_custom(form, face_list[2], face_list[3])
  end
end
function on_btn_read_click(self)
  local dialog = util_get_form("form_stage_create\\form_face_read", true, false)
  dialog.Visible = true
  dialog:ShowModal()
  local res, full_name = nx_wait_event(100000000, dialog, "read_face_return")
  if "ok" == res then
    if not nx_is_valid(self) then
      return false
    end
    local form = self.ParentForm
    apply_save_ini(form, full_name)
  end
end
function on_btn_save_click(self)
  local dialog = util_get_form("form_stage_create\\form_face_save", true, false)
  dialog.Visible = true
  dialog:ShowModal()
  local res, full_name = nx_wait_event(100000000, dialog, "save_face_return")
  if "ok" == res then
    if not nx_is_valid(self) then
      return
    end
    local form = self.ParentForm
    nx_execute("form_stage_create\\create_logic", "set_save_face", form, full_name)
  end
end
function apply_save_ini(form, file_name)
  local str_data = nx_function("ext_read_face_file", "", file_name)
  if "" == str_data then
    return false
  end
  local old_sex = form.sex
  if not read_str_set_form_data(str_data, form, "sex", 0, 1) then
    return false
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return false
  end
  if game_config.login_type == "2" and form.sex ~= old_sex then
    form.sex = old_sex
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_creat_face_tips_1"), 2)
    end
    return false
  end
  local hat = form.hat
  local cloth = form.cloth
  local pants = form.pants
  local shoes = form.shoes
  local feature = form.feature
  local beforehand = form.beforehand
  local photo = form.photo
  if not (read_str_set_form_data(str_data, form, "hat", 0, 9) and read_str_set_form_data(str_data, form, "cloth", 0, 3) and read_str_set_form_data(str_data, form, "pants", 0, 3) and read_str_set_form_data(str_data, form, "shoes", 0, 3) and read_str_set_form_data(str_data, form, "feature", 1, 6) and read_str_set_form_data(str_data, form, "beforehand", 1, 126)) or not read_str_set_form_data(str_data, form, "photo", 0, 3) then
    form.hat = hat
    form.cloth = cloth
    form.pants = pants
    form.shoes = shoes
    form.feature = feature
    form.beforehand = beforehand
    form.photo = photo
    form.sex = old_sex
    return false
  end
  local face = string.sub(str_data, 1, 46)
  local str_size = string.len(str_data)
  if str_size < 44 then
    return false
  end
  local create_role = nx_value("create_role")
  for i = 0, 21 do
    index = nx_string("face_" .. i + 1)
    local hor = nx_number(string.byte(string.sub(str_data, i * 2 + 1, i * 2 + 1)))
    local ver = nx_number(string.byte(string.sub(str_data, i * 2 + 2, i * 2 + 2)))
    if -1 < hor and hor < 102 and -1 < ver and ver < 102 then
      create_role:SetPlayerFaceDetailHV(index, hor, ver)
    end
  end
  local create_role = nx_value("create_role")
  create_role.PlayerFaceFeature = nx_int(form.beforehand)
  create_role.PlayerFaceBeard = nx_int(form.feature)
  if old_sex == form.sex then
    checked_role_changed(form)
  elseif 0 == form.sex then
    form.rbtn_man.is_init_role_info = false
    form.rbtn_man.Checked = true
  else
    form.rbtn_woman.is_init_role_info = false
    form.rbtn_woman.Checked = true
  end
  on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
end
function set_group_box_rbtns_init(form, addition, value)
  local rbtn_name = addition .. nx_string(value)
  local rbtn = nx_custom(form, rbtn_name)
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
end
function set_ent_property(source_node, target_node)
  if not nx_is_valid(source_node) or not nx_is_valid(target_node) then
    return
  end
  local prop_list = nx_property_list(source_node)
  for i, prop in ipairs(prop_list) do
    local value = nx_property(target_node, prop)
    local custom_type = nx_type(value)
    if "number" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_number(nx_property(source_node, prop)))
    elseif "string" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_property(source_node, prop))
    elseif "boolean" == nx_string(custom_type) then
      nx_set_property(target_node, prop, nx_boolean(nx_property(source_node, prop)))
    end
  end
end
function create_single_control(form, source_control)
  local gui = nx_value("gui")
  local control = gui:Create(nx_name(source_control))
  set_ent_property(source_control, control)
  return control
end
function init_weapon_grid_info(form)
  form.groupscrollbox_2:DeleteAll()
  local ini = get_ini("ini\\form\\equip_info.ini", true)
  local index = ini:FindSectionIndex("weapon")
  local gui = nx_value("gui")
  if -1 == index then
    return
  end
  local sect_list = ini:GetItemValueList(index, "node")
  local count = table.getn(sect_list) - 6
  for i = 1, count do
    local index = math.random(table.getn(sect_list))
    table.remove(sect_list, index)
  end
  local grid_box_row = -1
  for i, sect in ipairs(sect_list) do
    local lbl = create_single_control(form, form.lbl_8)
    local image_grid = create_single_control(form, form.imagegrid_1)
    local grid_box = create_single_control(form, form.groupbox_14)
    grid_box:Add(lbl)
    grid_box:Add(image_grid)
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      local j = (i - 1) % 3
      if j == 0 then
        grid_box_row = grid_box_row + 1
      end
      grid_box.Left = j * grid_box.Width
      grid_box.Top = grid_box_row * (grid_box.Height + 20)
    else
      local j = (i - 1) % 2
      local row = i / 2
      grid_box.Left = j * grid_box.Width
      grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
    end
    grid_box.Visible = true
    local res = form.groupscrollbox_2:Add(grid_box)
    index = ini:FindSectionIndex(sect)
    if -1 ~= index then
      local model = ini:ReadString(index, "mode", "")
      local photo = ini:ReadString(index, "photo", "")
      local title = ini:ReadString(index, "title", "")
      local item_type = ini:ReadString(index, "item_type", "")
      local skill_id = ini:ReadString(index, "skill_id", "")
      lbl.Text = gui.TextManager:GetText(title)
      image_grid.model = model
      image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
      image_grid.parent_form = form
      image_grid.item_type = item_type
      image_grid.skill_id = skill_id
      nx_bind_script(image_grid, nx_current())
      nx_callback(image_grid, "on_select_changed", "on_imagegrid_weapon_grid_select_changed")
    end
  end
end
function init_role_grid_info(form)
  form.groupscrollbox_4:DeleteAll()
  local gui = nx_value("gui")
  local ini = get_ini("ini\\form\\role_info.ini", true)
  local sex = form.sex
  if 1 == sex then
    local index = ini:FindSectionIndex("woman")
    if -1 == index then
      return
    end
    local sect_list = ini:GetItemValueList(index, "node")
    local grid_box_row = -1
    for i, sect in ipairs(sect_list) do
      local lbl = create_single_control(form, form.lbl_8)
      local image_grid = create_single_control(form, form.imagegrid_1)
      local grid_box = create_single_control(form, form.groupbox_14)
      grid_box:Add(lbl)
      grid_box:Add(image_grid)
      local game_config = nx_value("game_config")
      if game_config.login_type == "2" then
        local j = (i - 1) % 3
        if j == 0 then
          grid_box_row = grid_box_row + 1
        end
        grid_box.Left = j * grid_box.Width
        grid_box.Top = grid_box_row * (grid_box.Height + 20)
      else
        local j = (i - 1) % 2
        local row = i / 2
        grid_box.Left = j * grid_box.Width
        grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
      end
      grid_box.Visible = true
      local res = form.groupscrollbox_4:Add(grid_box)
      index = ini:FindSectionIndex(sect)
      if -1 ~= index then
        local photo = ini:ReadString(index, "photo", "")
        local body_type = ini:ReadString(index, "body_type", "")
        image_grid.BackImage = photo
        image_grid.body_type = body_type
        image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
        nx_bind_script(image_grid, nx_current())
        nx_callback(image_grid, "on_select_changed", "on_imagegrid_role_grid_select_changed")
      end
    end
  else
    local index = ini:FindSectionIndex("man")
    if -1 == index then
      return
    end
    local sect_list = ini:GetItemValueList(index, "node")
    local grid_box_row = -1
    for i, sect in ipairs(sect_list) do
      local lbl = create_single_control(form, form.lbl_8)
      local image_grid = create_single_control(form, form.imagegrid_1)
      local grid_box = create_single_control(form, form.groupbox_14)
      grid_box:Add(lbl)
      grid_box:Add(image_grid)
      local game_config = nx_value("game_config")
      if game_config.login_type == "2" then
        local j = (i - 1) % 3
        if j == 0 then
          grid_box_row = grid_box_row + 1
        end
        grid_box.Left = j * grid_box.Width
        grid_box.Top = grid_box_row * (grid_box.Height + 20)
      else
        local j = (i - 1) % 2
        local row = i / 2
        grid_box.Left = j * grid_box.Width
        grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
      end
      grid_box.Visible = true
      local res = form.groupscrollbox_4:Add(grid_box)
      index = ini:FindSectionIndex(sect)
      if -1 ~= index then
        local photo = ini:ReadString(index, "photo", "")
        local body_type = ini:ReadString(index, "body_type", "")
        image_grid.BackImage = photo
        image_grid.body_type = body_type
        image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
        nx_bind_script(image_grid, nx_current())
        nx_callback(image_grid, "on_select_changed", "on_imagegrid_role_grid_select_changed")
      end
    end
  end
end
function init_newequip_grid_info(form)
  form.groupscrollbox_25:DeleteAll()
  local ini = get_ini("ini\\form\\new_equip_info.ini", true)
  local index = ini:FindSectionIndex("cloth")
  local gui = nx_value("gui")
  if -1 == index then
    return
  end
  local sect_list = ini:GetItemValueList(index, "node")
  local grid_box_row = -1
  for i, sect in ipairs(sect_list) do
    local lbl = create_single_control(form, form.lbl_8)
    local image_grid = create_single_control(form, form.imagegrid_1)
    local grid_box = create_single_control(form, form.groupbox_14)
    grid_box:Add(lbl)
    grid_box:Add(image_grid)
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      local j = (i - 1) % 3
      if j == 0 then
        grid_box_row = grid_box_row + 1
      end
      grid_box.Left = j * grid_box.Width
      grid_box.Top = grid_box_row * (grid_box.Height + 20)
    else
      local j = (i - 1) % 2
      local row = i / 2
      grid_box.Left = j * grid_box.Width
      grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
    end
    grid_box.Visible = true
    local res = form.groupscrollbox_25:Add(grid_box)
    index = ini:FindSectionIndex(sect)
    if -1 ~= index then
      local model_f = ini:ReadString(index, "FemaleModelData", "")
      local model_m = ini:ReadString(index, "MaleModelData", "")
      local photo = ini:ReadString(index, "photo", "")
      local skill_id = ini:ReadString(index, "skill_id", "")
      local title = ini:ReadString(index, "title", "")
      lbl.Text = gui.TextManager:GetText(title)
      image_grid.model = model_m .. "|" .. model_f
      image_grid.skill_id = skill_id
      image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
      image_grid.parent_form = form
      nx_bind_script(image_grid, nx_current())
      nx_callback(image_grid, "on_select_changed", "on_imagegrid_newequip_grid_select_changed")
    end
  end
end
function init_newweapon_grid_info(form)
  form.groupscrollbox_26:DeleteAll()
  local gui = nx_value("gui")
  local ini = get_ini("ini\\form\\new_equip_info.ini", true)
  local index = ini:FindSectionIndex("weapon")
  if -1 == index then
    return
  end
  local sect_list = ini:GetItemValueList(index, "node")
  local grid_box_row = -1
  for i, sect in ipairs(sect_list) do
    local lbl = create_single_control(form, form.lbl_8)
    local image_grid = create_single_control(form, form.imagegrid_1)
    local grid_box = create_single_control(form, form.groupbox_14)
    grid_box:Add(lbl)
    grid_box:Add(image_grid)
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      local j = (i - 1) % 3
      if j == 0 then
        grid_box_row = grid_box_row + 1
      end
      grid_box.Left = j * grid_box.Width
      grid_box.Top = grid_box_row * (grid_box.Height + 20)
    else
      local j = (i - 1) % 2
      local row = i / 2
      grid_box.Left = j * grid_box.Width
      grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
    end
    grid_box.Visible = true
    local res = form.groupscrollbox_26:Add(grid_box)
    index = ini:FindSectionIndex(sect)
    if -1 ~= index then
      local model = ini:ReadString(index, "mode", "")
      local photo = ini:ReadString(index, "photo", "")
      local title = ini:ReadString(index, "title", "")
      local item_type = ini:ReadString(index, "item_type", "")
      local skill_id = ini:ReadString(index, "skill_id", "")
      lbl.Text = gui.TextManager:GetText(title)
      image_grid.model = model
      image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
      image_grid.parent_form = form
      image_grid.item_type = item_type
      image_grid.skill_id = skill_id
      nx_bind_script(image_grid, nx_current())
      nx_callback(image_grid, "on_select_changed", "on_imagegrid_newweapon_grid_select_changed")
    end
  end
end
function on_imagegrid_newequip_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  local model = image_grid.model
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_info_list = util_split_string(model, "|")
  local sex = form.sex
  set_camera_direct("far")
  local role_person = form.role_person
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local model_list = util_split_string(model_info_list[sex + 1], ";")
  for i, model in ipairs(model_list) do
    local model_value_list = util_split_string(model_list[i], ",")
    local prop_name = nx_string(nx_ws_lower(nx_widestr(model_value_list[1])))
    local prop_value = model_value_list[2] .. ".xmod"
    link_skin(form.role_person, prop_name, prop_value)
  end
end
function on_imagegrid_newweapon_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  local model = image_grid.model
  local item_type = image_grid.item_type
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_list = util_split_string(model, ",")
  local sex = form.sex
  set_camera_direct("far")
  link_weapon(form.role_person, model_list[sex + 1], item_type)
  form.weapon = model_list[sex + 1]
  form.item_type = item_type
  local role_person = form.role_person
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ActionInit(role_person)
  action:ClearAction(role_person)
  action:ClearState(role_person)
  local skill_effect = nx_value("skill_effect")
  skill_effect:EndShowZhaoshi(role_person, "")
  skill_effect:BeginShowZhaoshi(role_person, skill_id_list[sex + 1])
end
function on_imagegrid_role_grid_select_changed(image_grid)
  local form = image_grid.ParentForm
  hide_main_controls(form)
  init_role_info(form)
  refresh_weapon()
  set_newrbtn_stage_photo(form.groupbox_21, "newhairstyle", form.sex)
  form.groupbox_21.Visible = true
  set_newrbtn_stage_photo(form.groupbox_20, "newbeforehand", form.sex)
  form.groupbox_20.Visible = true
  form.groupbox_1.Visible = false
  form.role_actor2.Visible = false
  show_new_role_controls(form, true)
  form.groupscrollbox_2.Visible = true
  set_camera_direct("far")
  local scene = nx_value("game_scene")
  local sex = form.sex
  local body_type = nx_number(image_grid.body_type)
  if nx_is_valid(form.role_person) then
    local world = nx_value("world")
    world:Delete(form.role_person)
  end
  local ini = get_ini("ini\\form\\create_pos.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_name = "role_pos"
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    sec_name = "role_pos_new"
  end
  local index = ini:FindSectionIndex(nx_string(sec_name))
  if -1 == index then
    return
  end
  local str_pos = ini:ReadString(index, "pos", "0,0,0")
  local pos_list = util_split_string(str_pos, ",")
  local str_ang = ini:ReadString(index, "ang", "0")
  local ang_list = util_split_string(str_ang, ",")
  local actor2 = create_role_add_cur_scene(form, sex, nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]), nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]), "logoin_stand_2", body_type)
  if not nx_is_valid(form) or not nx_is_valid(actor2) then
    return
  end
  form.role_person = actor2
  form.role_person.create_module = true
end
function on_rbtn_newhairstyle_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  set_camera_direct("nearly")
  local role_person = form.role_person
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    local sex = form.sex
    if sex == 0 then
      model = "obj\\char\\b_s_" .. face_list[2] .. "_" .. face_list[3] .. "_b\\b_s_" .. face_list[2] .. "_" .. face_list[3] .. "_b_h.xmod"
      link_skin(form.role_person, "hat", model)
    else
      model = "obj\\char\\g_s_" .. face_list[2] .. "_" .. face_list[3] .. "_g\\g_s_" .. face_list[2] .. "_" .. face_list[3] .. "_g_h.xmod"
      link_skin(form.role_person, "hat", model)
    end
  end
end
function on_rbtn_newbeforehand_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  set_camera_direct("nearly")
  local face_list = util_split_string(rbtn.Name, "_")
  local role_person = form.role_person
  if rbtn.Checked then
    local role_face = get_player_face()
    if nx_is_valid(role_face) then
      if form.sex == 0 then
        local link_pos = "b_face"
        local face_path = "obj\\char\\b_face\\b_s_" .. face_list[2] .. "\\b_s_" .. face_list[2] .. ".xmod"
        link_skin(role_face, link_pos, face_path)
      elseif form.sex == 1 then
        local link_pos = "g_face"
        local face_path = "obj\\char\\g_face\\g_s_" .. face_list[2] .. "\\g_s_" .. face_list[2] .. ".xmod"
        link_skin(role_face, link_pos, face_path)
      end
    end
  end
end
function get_player_face()
  local form = nx_value(nx_current())
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local role_person = form.role_person
  if nx_is_valid(role_person) then
    local actor_role = role_person:GetLinkObject("actor_role")
    if not nx_is_valid(actor_role) then
      return
    end
    actor2_face = actor_role:GetLinkObject("actor_role_face")
    return actor2_face
  end
  return
end
function set_newrbtn_stage_photo(group_box, item_type, sex)
  local child_control_list = group_box:GetChildControlList()
  local game_config = nx_value("game_config")
  local ini = get_ini("ini\\form\\new_role_body.ini", true)
  local index = ini:FindSectionIndex(item_type)
  if -1 == index then
    return
  end
  local item_value_list = ini:GetItemValueList(index, "photo")
  for i, rbtn in ipairs(child_control_list) do
    if i < table.getn(item_value_list) + 1 then
      local value_list = util_split_string(item_value_list[i], ";")
      local stage_list = util_split_string(value_list[1 + sex], ",")
      rbtn.AutoSize = true
      rbtn.NormalImage = stage_list[1]
      rbtn.FocusImage = stage_list[2]
      rbtn.CheckedImage = stage_list[3]
      rbtn.DisableImage = stage_list[4]
    end
  end
end
function show_new_role_controls(form, is_show)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini("ini\\form\\new_hide_controls.ini", true)
  local index = ini:FindSectionIndex("control")
  if -1 == index then
    return
  end
  local hide_item = ini:ReadString(index, "node", "")
  local tbItems = nx_function("ext_split_string", nx_string(hide_item), ",")
  for _, item in pairs(tbItems) do
    local control = nx_custom(form, item)
    if nx_is_valid(control) then
      control.Visible = is_show
    end
  end
end
function hide_main_controls(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini("ini\\form\\main_hide_controls.ini", true)
  local index = ini:FindSectionIndex("main_hide")
  if -1 == index then
    return
  end
  local hide_item = ini:ReadString(index, "controls", "")
  local tbItems = nx_function("ext_split_string", nx_string(hide_item), ",")
  for _, item in pairs(tbItems) do
    local control = nx_custom(form, item)
    if nx_is_valid(control) then
      control.Visible = false
    end
  end
end
function show_main_controls(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini("ini\\form\\main_hide_controls.ini", true)
  local index = ini:FindSectionIndex("main_show")
  if -1 == index then
    return
  end
  local hide_item = ini:ReadString(index, "controls", "")
  local tbItems = nx_function("ext_split_string", nx_string(hide_item), ",")
  for _, item in pairs(tbItems) do
    local control = nx_custom(form, item)
    if nx_is_valid(control) then
      control.Visible = true
    end
  end
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.role_person) then
    local world = nx_value("world")
    world:Delete(form.role_person)
  end
  local game_config = nx_value("game_config")
  if not nx_find_custom(game_config, "login_type") then
    game_config.login_type = "2"
  end
  if game_config.login_type == "2" then
    reset_form_ui(form)
    form.groupbox_1.Visible = false
  elseif game_config.login_type == "1" then
    form.groupbox_1.Visible = true
  end
  init_role_info(form)
  form.role_actor2.Visible = true
  refresh_weapon()
  show_new_role_controls(form, false)
  form.rbtn_beforehand.Checked = true
  on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
  show_main_controls(form)
end
function init_equip_grid_info(form)
  form.groupscrollbox_1:DeleteAll()
  local ini = get_ini("ini\\form\\equip_info.ini", true)
  local index = ini:FindSectionIndex("cloth")
  local gui = nx_value("gui")
  if -1 == index then
    return
  end
  local sect_list = ini:GetItemValueList(index, "node")
  local count = table.getn(sect_list) - 6
  for i = 1, count do
    local index = math.random(table.getn(sect_list))
    table.remove(sect_list, index)
  end
  local grid_box_row = -1
  for i, sect in ipairs(sect_list) do
    local lbl = create_single_control(form, form.lbl_8)
    local image_grid = create_single_control(form, form.imagegrid_1)
    local grid_box = create_single_control(form, form.groupbox_14)
    grid_box:Add(lbl)
    grid_box:Add(image_grid)
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      local j = (i - 1) % 3
      if j == 0 then
        grid_box_row = grid_box_row + 1
      end
      grid_box.Left = j * grid_box.Width
      grid_box.Top = grid_box_row * (grid_box.Height + 20)
    else
      local j = (i - 1) % 2
      local row = i / 2
      grid_box.Left = j * grid_box.Width
      grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
    end
    grid_box.Visible = true
    local res = form.groupscrollbox_1:Add(grid_box)
    index = ini:FindSectionIndex(sect)
    if -1 ~= index then
      local model_f = ini:ReadString(index, "FemaleModelData", "")
      local model_m = ini:ReadString(index, "MaleModelData", "")
      local photo = ini:ReadString(index, "photo", "")
      local skill_id = ini:ReadString(index, "skill_id", "")
      local title = ini:ReadString(index, "title", "")
      lbl.Text = gui.TextManager:GetText(title)
      image_grid.model = model_m .. "|" .. model_f
      image_grid.skill_id = skill_id
      image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
      image_grid.parent_form = form
      nx_bind_script(image_grid, nx_current())
      nx_callback(image_grid, "on_select_changed", "on_imagegrid_equip_grid_select_changed")
    end
  end
end
function init_wuxue_grid_info(form)
  form.groupscrollbox_3:DeleteAll()
  local ini = get_ini("ini\\form\\equip_info.ini", true)
  local index = ini:FindSectionIndex("wuxue")
  local gui = nx_value("gui")
  if -1 == index then
    return
  end
  local sect_list = ini:GetItemValueList(index, "node")
  for i = 1, count do
    local index = math.random(table.getn(sect_list))
    table.remove(sect_list, index)
  end
  local grid_box_row = -1
  for i, sect in ipairs(sect_list) do
    local lbl = create_single_control(form, form.lbl_8)
    local image_grid = create_single_control(form, form.imagegrid_1)
    local grid_box = create_single_control(form, form.groupbox_14)
    grid_box:Add(lbl)
    grid_box:Add(image_grid)
    local game_config = nx_value("game_config")
    if game_config.login_type == "2" then
      local j = (i - 1) % 3
      if j == 0 then
        grid_box_row = grid_box_row + 1
      end
      grid_box.Left = j * grid_box.Width
      grid_box.Top = grid_box_row * grid_box.Height
    else
      local j = (i - 1) % 2
      local row = i / 2
      grid_box.Left = j * grid_box.Width
      grid_box.Top = (i - 1 - nx_int(row)) * grid_box.Height
    end
    grid_box.Visible = true
    local res = form.groupscrollbox_3:Add(grid_box)
    index = ini:FindSectionIndex(sect)
    if -1 ~= index then
      local skill_id = ini:ReadString(index, "skill_id", "")
      local photo = ini:ReadString(index, "photo", "")
      local title = ini:ReadString(index, "title", "")
      lbl.Text = gui.TextManager:GetText(title)
      image_grid.skill_id = skill_id
      image_grid:AddItem(0, photo, nx_widestr(""), 0, 0)
      image_grid.parent_form = form
      nx_bind_script(image_grid, nx_current())
      nx_callback(image_grid, "on_select_changed", "on_imagegrid_wuxue_grid_select_changed")
    end
  end
  form.groupscrollbox_3:ResetChildrenYPos()
end
function on_imagegrid_equip_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  local model = image_grid.model
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_info_list = util_split_string(model, "|")
  local sex = form.sex
  set_camera_direct("far")
  form:ToFront(form.lbl_v_2)
  form:ToFront(form.lbl_v_1)
  form.lbl_v_1.Left = form.groupscrollbox_1.Left
  form.lbl_v_1.Top = form.groupscrollbox_1.Top
  form.lbl_v_1.Width = form.groupscrollbox_1.Width
  form.lbl_v_1.Height = form.groupscrollbox_1.Height
  form.lbl_v_1.Visible = true
  form.lbl_v_2.Left = form.groupscrollbox_2.Left
  form.lbl_v_2.Top = form.groupscrollbox_2.Top
  form.lbl_v_2.Width = form.groupscrollbox_2.Width
  form.lbl_v_2.Height = form.groupscrollbox_2.Height
  form.lbl_v_2.Visible = true
  local actor2 = form.role_actor2
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local model_list = util_split_string(model_info_list[sex + 1], ";")
  refresh_actor_info(form)
  for i, model in ipairs(model_list) do
    local model_value_list = util_split_string(model_list[i], ",")
    local prop_name = nx_string(nx_ws_lower(nx_widestr(model_value_list[1])))
    local prop_value = model_value_list[2] .. ".xmod"
    link_skin(form.role_actor2, prop_name, prop_value)
  end
end
function on_imagegrid_weapon_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  local model = image_grid.model
  local item_type = image_grid.item_type
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_list = util_split_string(model, ",")
  local sex = form.sex
  set_camera_direct("far")
  form:ToFront(form.lbl_v_2)
  form:ToFront(form.lbl_v_1)
  form.lbl_v_1.Left = form.groupscrollbox_1.Left
  form.lbl_v_1.Top = form.groupscrollbox_1.Top
  form.lbl_v_1.Width = form.groupscrollbox_1.Width
  form.lbl_v_1.Height = form.groupscrollbox_1.Height
  form.lbl_v_1.Visible = true
  form.lbl_v_2.Left = form.groupscrollbox_2.Left
  form.lbl_v_2.Top = form.groupscrollbox_2.Top
  form.lbl_v_2.Width = form.groupscrollbox_2.Width
  form.lbl_v_2.Height = form.groupscrollbox_2.Height
  form.lbl_v_2.Visible = true
  link_weapon(form.role_actor2, model_list[sex + 1], item_type)
  form.weapon = model_list[sex + 1]
  form.item_type = item_type
  local actor2 = form.role_actor2
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  local skill_effect = nx_value("skill_effect")
  skill_effect:EndShowZhaoshi(actor2, "")
  skill_effect:BeginShowZhaoshi(actor2, skill_id_list[sex + 1])
end
function on_imagegrid_wuxue_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  local skill_id = image_grid.skill_id
  set_camera_direct("far")
  local skill_id_list = util_split_string(skill_id, ",")
  local sex = form.sex
  nx_execute("form_stage_create\\create_logic", "show_skill_action", skill_id_list[sex + 1], form.role_actor2)
  link_weapon(form.role_actor2, form.weapon, form.item_type)
end
function refresh_weapon()
  local form = nx_value(nx_current())
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if nx_is_valid(form) then
    if nx_is_valid(form.role_person) then
      link_weapon(form.role_person, form.weapon, form.item_type)
      action:BlendAction(form.role_person, "logoin_stand_2", true, true)
    else
      link_weapon(form.role_actor2, form.weapon, form.item_type)
      form.lbl_v_2.Visible = false
      form.lbl_v_1.Visible = false
      action:BlendAction(form.role_actor2, "logoin_stand_2", true, true)
    end
  end
end
function action_finished(form, actor2, action_name)
  if nx_running(nx_current(), "exe_action_finished") then
    nx_kill(nx_current(), "exe_action_finished")
  end
  nx_execute(nx_current(), "exe_action_finished", form, actor2, action_name)
end
function exe_action_finished(form, actor2, action_name)
  local action = nx_value("action_module")
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  local time_count = 0
  while nx_is_valid(action) and not action:ActionFinished(actor2, action_name) do
    time_count = time_count + nx_pause(0)
  end
  if not (nx_is_valid(action) and nx_is_valid(actor2)) or not nx_is_valid(form) then
    return
  end
  action:BlendAction(actor2, "logoin_stand_2", true, true)
  form.lbl_v_2.Visible = false
  form.lbl_v_1.Visible = false
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_left_push(btn)
  local form = btn.ParentForm
  if nx_is_valid(form.role_person) then
    set_model_angle(btn, 1, form.role_person)
  elseif not nx_is_valid(form.role_person) then
    set_model_angle(btn, 1, form.role_actor2)
  end
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_right_push(btn)
  local form = btn.ParentForm
  if nx_is_valid(form.role_person) then
    set_model_angle(btn, -1, form.role_person)
  elseif not nx_is_valid(form.role_person) then
    set_model_angle(btn, -1, form.role_actor2)
  end
end
function call_back_blend_color_visible(form)
end
function init_camera()
  local scene = nx_value("game_scene")
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local ini = get_ini("ini\\form\\create_pos.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local camera_type
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    camera_type = "camera_new"
  else
    camera_type = "camera"
  end
  local index = ini:FindSectionIndex(nx_string(camera_type))
  local str_pos = ini:ReadString(index, "pos", "0,0,0")
  local pos_list = util_split_string(str_pos, ",")
  local str_ang = ini:ReadString(index, "ang", "0")
  local ang_list = util_split_string(str_ang, ",")
  camera.Fov = 0.1388888888888889 * math.pi * 2
  camera.fov_angle = 50
  camera:SetPosition(nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]))
  camera:SetAngle(nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]))
end
function set_camera_direct(camera_type)
  local scene = nx_value("game_scene")
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  camera.t_time = 2000
  camera.s_time = 0
  local asynor = nx_value("common_execute")
  asynor:RemoveExecute("MoveCamera", camera)
  local ini = get_ini("ini\\form\\create_pos.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local game_config = nx_value("game_config")
  if game_config.login_type == "2" then
    camera_type = nx_string(camera_type) .. "_new"
  end
  local index = ini:FindSectionIndex(nx_string(camera_type))
  if -1 == index then
    return
  end
  local str_pos = ini:ReadString(index, "pos", "0,0,0")
  local pos_list = util_split_string(str_pos, ",")
  local str_ang = ini:ReadString(index, "ang", "0")
  local ang_list = util_split_string(str_ang, ",")
  asynor:AddExecute("MoveCamera", camera, nx_float(0), nx_float(camera.PositionX), nx_float(camera.PositionY), nx_float(camera.PositionZ), nx_float(camera.AngleX), nx_float(camera.AngleY), nx_float(camera.AngleZ), nx_float(pos_list[1]), nx_float(pos_list[2]), nx_float(pos_list[3]), nx_float(ang_list[1]), nx_float(ang_list[2]), nx_float(ang_list[3]))
end
function refresh_actor_info(form)
  local sex = form.sex
  local hat = nx_int(form.hat) - nx_int(1)
  local cloth = nx_int(form.cloth) - nx_int(1)
  local pants = nx_int(form.pants) - nx_int(1)
  local shoes = nx_int(form.shoes) - nx_int(1)
  local hat_model = get_equip_info("hat", sex, hat)
  local cloth_model = get_equip_info("cloth", sex, cloth)
  local pants_model = get_equip_info("pants", sex, pants)
  local shoes_model = get_equip_info("shoes", sex, shoes)
  local role_actor2 = form.role_actor2
  local skin_info = {
    [1] = {link_name = "hat", model_name = hat_model},
    [2] = {link_name = "cloth", model_name = cloth_model},
    [3] = {link_name = "pants", model_name = pants_model},
    [4] = {link_name = "shoes", model_name = shoes_model}
  }
  for i, info in ipairs(skin_info) do
    if info.model_name ~= nil and "" ~= info.model_name then
      link_skin(role_actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
end
function on_btn_random_click(btn)
  local form = btn.ParentForm
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  math.randomseed(os.time())
  form.beforehand = math.random(10)
  create_role.PlayerFaceFeature = form.beforehand
  form.cloth = math.random(3)
  form.pants = math.random(3)
  form.shoes = math.random(3)
  form.hat = math.random(3)
  form.feature = math.random(6)
  create_role.PlayerFaceBeard = form.feature
  form.photo = math.random(3)
  checked_role_changed(form)
end
function set_play_dof_info(form, visual_player)
  local game_config = nx_value("game_config")
  local game_scene = nx_value("game_scene")
  local ppdof_uiparam = game_scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) then
    return
  end
  form.old_focusdepth = ppdof_uiparam.focusdepth
  form.old_blurvalue = ppdof_uiparam.blurvalue
  form.old_maxofblur = ppdof_uiparam.maxofblur
  form.old_dof_enable = ppdof_uiparam.enable
  ppdof_uiparam.focusdepth = 17
  ppdof_uiparam.blurvalue = 1
  ppdof_uiparam.maxofblur = 3
  nx_execute("game_config", "set_dof_enable", game_scene, true)
  local ppdof = game_scene.ppdof
  if nx_is_valid(ppdof) then
    ppdof.FocusObject = visual_player
  end
end
function recover_play_dof_info(form)
  local game_scene = nx_value("game_scene")
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_scene) or not nx_is_valid(game_config) then
    return
  end
  local ppdof_uiparam = game_scene.ppdof_uiparam
  if not nx_is_valid(ppdof_uiparam) or not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "old_focusdepth") then
    ppdof_uiparam.focusdepth = form.old_focusdepth
  end
  if nx_find_custom(form, "old_blurvalue") then
    ppdof_uiparam.blurvalue = form.old_blurvalue
  end
  if nx_find_custom(form, "old_maxofblur") then
    ppdof_uiparam.maxofblur = form.old_maxofblur
  end
  if nx_find_custom(form, "old_dof_enable") then
    ppdof_uiparam.enable = form.old_dof_enable
  end
  nx_execute("game_config", "set_dof_enable", game_scene, ppdof_uiparam.enable)
end
function set_trackrect_max(trackrect, max_h, mn_v)
  if not nx_is_valid(trackrect) then
    return
  end
  trackrect.HorizonMax = max_h
  trackrect.VerticalMax = max_h
end
function set_control_ui(control)
  if not nx_is_valid(control) then
    return
  end
  local out_image = get_ini_prop(CREATE_NEW_INI, control.Name, "out", "")
  local on_image = get_ini_prop(CREATE_NEW_INI, control.Name, "on", "")
  local down_image = get_ini_prop(CREATE_NEW_INI, control.Name, "down", "")
  local left = get_ini_prop(CREATE_NEW_INI, control.Name, "left", "")
  local top = get_ini_prop(CREATE_NEW_INI, control.Name, "top", "")
  local width = get_ini_prop(CREATE_NEW_INI, control.Name, "width", "")
  local height = get_ini_prop(CREATE_NEW_INI, control.Name, "height", "")
  if nx_name(control) == "Label" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Button" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.PushImage = down_image
    end
  elseif nx_name(control) == "CheckButton" or nx_name(control) == "RadioButton" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.CheckedImage = down_image
    end
  elseif nx_name(control) == "GroupBox" or nx_name(control) == "GroupScrollableBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "TrackRect" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
    control.TrackButton.NormalImage = get_ini_prop(CREATE_NEW_INI, "TrackButton", "out", "")
    control.TrackButton.FocusImage = get_ini_prop(CREATE_NEW_INI, "TrackButton", "on", "")
    control.TrackButton.PushImage = get_ini_prop(CREATE_NEW_INI, "TrackButton", "down", "")
  else
    return
  end
  if left ~= "" and top ~= "" then
    control.Left = nx_number(left)
    control.Top = nx_number(top)
  end
  if width ~= "" and height ~= "" then
    control.Width = nx_number(width)
    control.Height = nx_number(height)
  end
end
function reset_form_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", CREATE_NEW_INI)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local control = nx_custom(form, sec_name)
    if nx_is_valid(control) then
      set_control_ui(control)
    end
  end
end
function add_light(scene)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\form\\light_set_create.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local point_light_red = ini:ReadInteger("light", "point_light_red", game_config.point_light_red)
  local point_light_green = ini:ReadInteger("light", "point_light_green", game_config.point_light_green)
  local point_light_blue = ini:ReadInteger("light", "point_light_blue", game_config.point_light_blue)
  local point_light_range = ini:ReadFloat("light", "point_light_range", game_config.point_light_range)
  local point_light_intensity = ini:ReadFloat("light", "point_light_intensity", game_config.point_light_intensity)
  local point_light_pos_x = ini:ReadFloat("light", "point_light_pos_x", game_config.point_light_pos_x)
  local point_light_pos_y = ini:ReadFloat("light", "point_light_pos_y", game_config.point_light_pos_y)
  local point_light_pos_z = ini:ReadFloat("light", "point_light_pos_z", game_config.point_light_pos_z)
  nx_destroy(ini)
  if not nx_is_valid(scene) then
    return
  end
  local light_man = scene.light_man
  if not nx_is_valid(light_man) then
    return
  end
  if not nx_find_custom(scene, "light") or not nx_is_valid(scene.light) then
    local light = light_man:Create()
    scene.light = light
  end
  local light = scene.light
  light.LightType = "point"
  light:Load()
  scene:AddObject(light, 20)
  light.Color = "255," .. nx_string(point_light_red) .. "," .. nx_string(point_light_green) .. "," .. nx_string(point_light_blue)
  light.Range = point_light_range
  light.Intensity = point_light_intensity
  light.Attenu0 = 0
  light.Attenu1 = 1
  light.Attenu2 = 0
  light:SetPosition(point_light_pos_x, point_light_pos_y, point_light_pos_z)
  scene:Load()
end
function fix_beforehand_index(form, index)
  if not nx_is_valid(form) then
    return index
  end
  local group_box = form.groupbox_6
  local fix_index = index
  local child_control_list = group_box:GetChildControlList()
  for i, rbtn in ipairs(child_control_list) do
    if nx_find_custom(rbtn, "model_face_id") and nx_int(rbtn.model_face_id) == nx_int(index) then
      local face_list = util_split_string(rbtn.Name, "_")
      fix_index = nx_number(face_list[2])
    end
  end
  return fix_index
end
function reset_face_model(actor_role_face, sex)
  if not nx_is_valid(actor_role_face) then
    return
  end
  local link_name = ""
  local model_path = ""
  if sex == 0 then
    link_name = "b_face"
    model_path = "obj\\char\\b_face\\b_face.xmod"
  elseif sex == 1 then
    link_name = "g_face"
    model_path = "obj\\char\\g_face\\g_face.xmod"
  end
  link_skin(actor_role_face, link_name, model_path, true)
end
