require("util_functions")
require("const_define")
require("util_gui")
require("utils")
require("util_static_data")
require("role_composite")
require("scenario_npc_manager")
require("scene")
require("form_stage_main\\form_talk_movie")
require("form_stage_create\\create_logic")
require("tips_data")
require("define\\camera_mode")
require("custom_handler")
local Y_VALUE = 0.9
local Z_VALUE = 2.25
local Y_ANGLE = 8
local RESET_FACE_MAX_BEFOREHAND = 50
local CREATE_NEW_INI = "ini\\form\\creat_new.ini"
local FACE_CAMERA_INI = "ini\\form\\face_camera.ini"
local FACE_COST_ITEM = "share\\Activity\\reset_exterior.ini"
local SET_PALYER_EXT = 3
local FORM_NAME = "form_stage_create\\form_create_on"
local Khbd_Set_Face_Item = "item_npcyr_khbd"
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
  form.role_actor2 = nx_null()
end
function on_main_form_open(form)
  local create_role = nx_create("CreateRole")
  nx_set_value("create_role", create_role)
  form.sex = 0
  form.cost_item = ""
  form.cost_num = 0
  change_create_size(form, true)
  form.edit_face = false
  form.trackrect_1.sel_index = nil
  form.trackrect_2.sel_index = nil
  form.trackrect_3.sel_index = nil
  create_role:LoadResource()
  local player = get_player()
  create_role:LoadPlayerFaceData(player)
  init_role_info(form)
  set_main_rbtn_offset_info(form)
  on_sex_init(form)
  init_face_data(form)
end
function on_sex_init(form)
  if not nx_is_valid(form) then
    return
  end
  local sex = get_player_sex()
  if sex == 0 then
    form.sex = 0
    checked_role_changed(form)
  elseif sex == 1 then
    form.sex = 1
    checked_role_changed(form)
  end
end
function init_role_info(form)
  if not nx_is_valid(form) then
    return
  end
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  create_role:LoadPlayerFaceData(player)
  form.cloth = 1
  form.pants = 1
  form.shoes = 1
  form.beforehand = nx_int(0)
  form.hat = nx_int(0)
  form.feature = nx_int(0)
  form.photo = nx_int(0)
  form.weapon = ""
  form.item_type = ""
end
function on_main_form_close(form)
  if nx_running(nx_current(), "on_main_form_open") then
    nx_kill(nx_current(), "on_main_form_open")
  end
  nx_destroy(form)
  local create_role = nx_value("create_role")
  nx_destroy(create_role)
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
  form.Left = 0
  form.Top = 0
end
function on_rbtn_man_checked_changed(btn)
end
function on_rbtn_woman_checked_changed(btn)
end
function checked_role_changed(form)
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_beforehand.Checked then
    on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
  else
    form.rbtn_beforehand.Checked = true
  end
end
function on_btn_enter_frist_name_click(btn)
  local form = btn.ParentForm
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local is_khbd = nx_execute("form_stage_main\\form_main\\form_main_reset_face", "is_khbd")
  if is_khbd then
    local is_khbd_set_face_switch_open = nx_execute("form_stage_main\\form_main\\form_main_reset_face", "is_khbd_set_face_switch_open")
    if not is_khbd_set_face_switch_open then
      local gui = nx_value("gui")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_khbd_yr_forbid"), 2)
      end
      return
    else
      local can_khbd_set_face = nx_execute("form_stage_main\\form_main\\form_main_reset_face", "can_khbd_set_face")
      if not can_khbd_set_face then
        local gui = nx_value("gui")
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("16619", gui.TextManager:GetText(Khbd_Set_Face_Item)), 2)
        end
        return
      end
    end
  end
  local stritem, num = check_cost_item(form)
  if stritem == nil or num == nil then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("99705"), 2)
    end
    return
  end
  local gui = nx_value("gui")
  local text = nx_string("")
  local is_khbd = nx_execute("form_stage_main\\form_main\\form_main_reset_face", "is_khbd")
  if is_khbd then
    text = gui.TextManager:GetFormatText("sys_khbd_yr_01", stritem, gui.TextManager:GetText(Khbd_Set_Face_Item))
  else
    text = gui.TextManager:GetFormatText("99708", stritem)
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "create_resetface")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "create_resetface_confirm_return")
  if res ~= "ok" then
    return
  end
  local hat_changle = 1
  local photo_changle = 1
  local hat = player:QueryProp("Hair")
  local photo = player:QueryProp("Photo")
  if nx_int(form.hat) > nx_int(0) then
    hat_changle = 2
    hat = get_equip_info("hat", form.sex, nx_int(form.hat) - 1)
  end
  if nx_int(form.photo) > nx_int(0) then
    photo_changle = 2
    photo = get_equip_info("photo", form.sex, nx_int(form.photo) - 1, true)
  end
  local face = create_role:GetPlayerFaceData()
  nx_execute("custom_sender", "custom_face", SET_PALYER_EXT, face, hat_changle, hat, photo_changle, photo)
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
function get_role_face_form_actor2(role_actor2)
  if not nx_is_valid(role_actor2) then
    return nil
  end
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
    form.groupbox_mianbu.AbsLeft = rbtn.AbsLeft
    form.groupbox_mianbu.AbsTop = rbtn.AbsTop + rbtn.Height
    form.rbtn_meimao.Checked = true
    on_rbtn_face_prop_checked_changed(form.rbtn_meimao)
    form.groupbox_2.Visible = true
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
    form.groupbox_11.AbsLeft = rbtn.AbsLeft
    form.groupbox_11.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_11.Visible = true
  else
    form.groupbox_11.Visible = false
  end
end
function on_rbtn_beforehand_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_6, "beforehand", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_6.AbsLeft = rbtn.AbsLeft
    form.groupbox_6.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_6.Visible = true
  else
    form.groupbox_6.Visible = false
  end
end
function on_rbtn_photo_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    set_rbtn_stage_photo(form.groupbox_13, "head", form.sex)
    set_main_rbtn_pos(form.groupbox_resetface, rbtn)
    form.groupbox_13.AbsLeft = rbtn.AbsLeft
    form.groupbox_13.AbsTop = rbtn.AbsTop + rbtn.Height
    form.groupbox_13.Visible = true
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
    form.groupbox_12.AbsLeft = rbtn.AbsLeft
    form.groupbox_12.AbsTop = rbtn.AbsTop + rbtn.Height
  else
    form.groupbox_12.Visible = false
  end
end
function on_rbtn_face_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_2.AbsTop = form.groupbox_mianbu.AbsTop + 150
    form.groupbox_2.AbsLeft = form.groupbox_mianbu.AbsLeft + 50
    form.lbl_21.Visible = false
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
    form.trackrect_1.sel_index = nil
    form.trackrect_2.sel_index = nil
    form.trackrect_3.sel_index = nil
    if nx_string(face_list[1]) == nx_string("face_1") or nx_string(face_list[1]) == nx_string("face_4") then
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
    form.trackrect_1.sel_index = face_list[1]
    form.trackrect_2.sel_index = face_list[2]
    form.trackrect_3.sel_index = face_list[3]
    form.lbl_21.AbsTop = rbtn.AbsTop + (rbtn.Height - form.lbl_21.Height) / 2
    form.lbl_21.AbsLeft = rbtn.AbsLeft + rbtn.Width + 20
  end
end
function on_trackrect_prop_value_changed(self)
  if not nx_find_custom(self, "sel_index") or nil == self.sel_index then
    return
  end
  local form = self.ParentForm
  if form.edit_face == true then
    return
  end
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
  local form = groupbox.ParentForm
  form.groupbox_1.Top = offset_y + 50
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
    local feature = form.feature
    if nx_int(form.feature) == nx_int(0) then
      feature = nx_int(1)
      create_role.PlayerFaceBeard = feature
    end
    set_face_materialfile(actor2_face, form.sex, nx_string(form.beforehand), nx_string(feature))
  end
end
function on_rbtn_dress_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    nx_set_custom(form, face_list[2], nx_int(face_list[3]))
    refresh_actor_hat(form)
  end
end
function refresh_actor_hat(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local sex = form.sex
  local hat = nx_int(form.hat) - nx_int(1)
  local hat_model = get_equip_info("hat", sex, hat)
  if hat_model ~= nil then
    link_skin(form.role_actor2, "hat", hat_model .. ".xmod")
  end
end
function on_rbtn_feature_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    local actor2_face = get_role_face(form)
    form.feature = nx_int(face_list[3])
    local create_role = nx_value("create_role")
    create_role.PlayerFaceBeard = nx_int(face_list[3])
    local beforehand = form.beforehand
    if nx_int(form.beforehand) == nx_int(0) then
      beforehand = nx_int(1)
      create_role.PlayerFaceFeature = beforehand
    end
    set_face_materialfile(actor2_face, form.sex, nx_string(beforehand), face_list[3])
  end
end
function on_rbtn_photo_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local face_list = util_split_string(rbtn.Name, "_")
  if rbtn.Checked then
    model = get_equip_info(face_list[2], form.sex, nx_int(face_list[3]) - 1)
    nx_set_custom(form, face_list[2], nx_int(face_list[3]))
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
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local face_beard = nx_int(create_role.PlayerFaceBeard)
  if nx_int(face_beard) > nx_int(19) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_creat_nielian_tips")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "creat_face_on")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "creat_face_on_confirm_return")
    if res ~= "ok" then
      return
    end
    face_beard = nx_int(1)
  end
  local dialog = util_get_form("form_stage_create\\form_face_save", true, false)
  dialog.Visible = true
  dialog:ShowModal()
  local res, full_name = nx_wait_event(100000000, dialog, "save_face_return")
  if "ok" == res then
    if not nx_is_valid(self) then
      return
    end
    local copy_playerfacebeard = create_role.PlayerFaceBeard
    local copy_playerfacefeature = create_role.PlayerFaceFeature
    local form = self.ParentForm
    if nx_int(form.hat) == nx_int(0) then
      form.hat = nx_int(1)
    end
    form.feature = nx_int(face_beard)
    create_role.PlayerFaceBeard = nx_int(face_beard)
    form.beforehand = nx_int(create_role.PlayerFaceFeature)
    if nx_int(form.photo) == nx_int(0) then
      form.photo = nx_int(1)
    end
    nx_execute("form_stage_create\\create_logic", "set_save_face", form, full_name)
    create_role.PlayerFaceBeard = copy_playerfacebeard
    create_role.PlayerFaceFeature = copy_playerfacefeature
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
  if form.sex ~= old_sex then
    form.sex = old_sex
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("ui_creat_face_tips_1"), 2)
    end
    return false
  end
  local hat = form.hat
  local feature = form.feature
  local beforehand = form.beforehand
  local photo = form.photo
  if not (read_str_set_form_data(str_data, form, "hat", 0, 9) and read_str_set_form_data(str_data, form, "feature", 1, 6) and read_str_set_form_data(str_data, form, "beforehand", 1, 126)) or not read_str_set_form_data(str_data, form, "photo", 0, 3) then
    form.hat = hat
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
  apply_save_ini_beforehand(form)
  apply_save_ini_feature(form)
  local actor2_face = get_role_face(form)
  if not nx_is_valid(actor2_face) then
    return
  end
  refresh_actor_info(form)
  set_group_box_rbtns_init(form, "rbtn_hat_", form.hat)
  set_group_box_rbtns_init(form, "rbtn_photo_", form.photo)
  checked_role_changed(form)
  on_rbtn_beforehand_checked_changed(form.rbtn_beforehand)
  local actor2_face = get_role_face(form)
  if not nx_is_valid(actor2_face) then
    return
  end
  for i = 0, 21 do
    index = nx_string("face_" .. i + 1)
    local hor = nx_number(string.byte(string.sub(str_data, i * 2 + 1, i * 2 + 1)))
    local ver = nx_number(string.byte(string.sub(str_data, i * 2 + 2, i * 2 + 2)))
    if 1 <= hor and hor < 102 and 1 <= ver and ver < 102 then
      create_role:SetPlayerFaceDetailHV(index, hor - 1, ver - 1)
      nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2_face, nx_int(hor - 1), nx_int(ver - 1), index, nx_float(4.0E-4), nx_float(0))
    end
  end
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
    local j = (i - 1) % 3
    if j == 0 then
      grid_box_row = grid_box_row + 1
    end
    grid_box.Left = j * grid_box.Width
    grid_box.Top = grid_box_row * (grid_box.Height + 20)
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
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local model = image_grid.model
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_info_list = util_split_string(model, "|")
  local sex = form.sex
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
  for i, model in ipairs(model_list) do
    local model_value_list = util_split_string(model_list[i], ",")
    local prop_name = nx_string(nx_ws_lower(nx_widestr(model_value_list[1])))
    local prop_value = model_value_list[2] .. ".xmod"
    link_skin(form.role_actor2, prop_name, prop_value)
  end
end
function on_imagegrid_weapon_grid_select_changed(image_grid)
  local form = image_grid.parent_form
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local model = image_grid.model
  local item_type = image_grid.item_type
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local model_list = util_split_string(model, ",")
  local sex = form.sex
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
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local skill_id = image_grid.skill_id
  local skill_id_list = util_split_string(skill_id, ",")
  local sex = form.sex
  nx_execute("form_stage_create\\create_logic", "show_skill_action", skill_id_list[sex + 1], form.role_actor2)
  link_weapon(form.role_actor2, form.weapon, form.item_type)
end
function refresh_weapon()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_actor2) then
    return
  end
  if nx_is_valid(form) then
    link_weapon(form.role_actor2, form.weapon, form.item_type)
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  form.lbl_v_2.Visible = false
  form.lbl_v_1.Visible = false
  action:BlendAction(form.role_actor2, "logoin_stand_2", true, true)
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
  set_model_angle(btn, 1)
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
  set_model_angle(btn, -1)
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
function refresh_actor_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local sex = form.sex
  local hat = nx_int(form.hat) - nx_int(1)
  local hat_model = get_equip_info("hat", sex, hat)
  local cloth_model = get_equip_info("cloth", sex, 0)
  local pants_model = get_equip_info("pants", sex, 0)
  local shoes_model = get_equip_info("shoes", sex, 0)
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
  form.beforehand = math.random(10)
  create_role.PlayerFaceFeature = form.beforehand
  form.hat = math.random(3)
  form.feature = math.random(6)
  create_role.PlayerFaceBeard = form.feature
  form.photo = math.random(3)
  apply_save_ini_beforehand(form)
  apply_save_ini_feature(form)
  refresh_actor_info(form)
  set_group_box_rbtns_init(form, "rbtn_hat_", form.hat)
  set_group_box_rbtns_init(form, "rbtn_photo_", form.photo)
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
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local ambient_red = ini:ReadInteger("light", "ambient_red", game_config.ambient_red)
  local ambient_green = ini:ReadInteger("light", "ambient_green", game_config.ambient_green)
  local ambient_blue = ini:ReadInteger("light", "ambient_blue", game_config.ambient_blue)
  local ambient_intensity = ini:ReadFloat("light", "ambient_intensity", game_config.ambient_intensity)
  local sunglow_red = ini:ReadInteger("light", "sunglow_red", game_config.sunglow_red)
  local sunglow_green = ini:ReadInteger("light", "sunglow_green", game_config.sunglow_green)
  local sunglow_blue = ini:ReadInteger("light", "sunglow_blue", game_config.sunglow_blue)
  local sunglow_intensity = ini:ReadFloat("light", "sunglow_intensity", game_config.sunglow_intensity)
  local sun_height = ini:ReadInteger("light", "sun_height", game_config.sun_height)
  local sun_azimuth = ini:ReadInteger("light", "sun_azimuth", game_config.sun_azimuth)
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
  local weather = scene.Weather
  if not nx_is_valid(weather) then
    return
  end
  weather.FogEnable = false
  weather.AmbientColor = "255," .. nx_string(ambient_red) .. "," .. nx_string(ambient_green) .. "," .. nx_string(ambient_blue)
  weather.SunGlowColor = "255," .. nx_string(sunglow_red) .. "," .. nx_string(sunglow_green) .. "," .. nx_string(sunglow_blue)
  weather.SpecularColor = "255,196,196,196"
  weather.AmbientIntensity = ambient_intensity
  weather.SunGlowIntensity = sunglow_intensity
  weather.SpecularIntensity = 2
  local sun_height_rad = sun_height / 360 * math.pi * 2
  local sun_azimuth_rad = sun_azimuth / 360 * math.pi * 2
  weather:MakeSunDirection(sun_height_rad, sun_azimuth_rad)
  if not nx_find_custom(scene, "light") then
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
function create_role_model(form)
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
  local sex = client_player:QueryProp("Sex")
  local client_obj = game_client:GetSceneObj(nx_string(client_player.Ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local visual_player = create_role_composite(scene, false, sex, "logoin_stand_2")
  if not nx_is_valid(visual_player) then
    return nx_null()
  end
  while nx_call("role_composite", "is_loading", 2, visual_player) do
    nx_pause(0)
  end
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = "obj\\char\\b_hair\\b_hair1"
    },
    [2] = {
      link_name = "cloth",
      model_name = "obj\\char\\b_jianghu001\\b_cloth001"
    },
    [3] = {
      link_name = "pants",
      model_name = "obj\\char\\b_jianghu001\\b_pants001"
    },
    [4] = {
      link_name = "shoes",
      model_name = "obj\\char\\b_jianghu001\\b_shoes001"
    }
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(visual_player, info.link_name, info.model_name .. ".xmod")
    end
  end
  while nx_is_valid(visual_player) and not visual_player.LoadFinish do
    nx_log("not visual_player.LoadFinish")
    nx_pause(0)
  end
  if not nx_is_valid(visual_player) then
    return
  end
  nx_pause(0.1)
  form.role_actor2 = visual_player
  visual_player.Visible = true
  while not visual_player.LoadFinish do
    nx_pause(0.1)
  end
  visual_player.modify_face = client_obj:QueryProp("ModifyFace")
  local actor_role = visual_player:GetLinkObject("actor_role")
  if nx_is_valid(actor_role) then
    actor_role:BlendAction("logoin_stand_2", true, true)
  end
  nx_execute("game_config", "create_effect", "player_shadow", visual_player, visual_player, "", "", "", "", "", true)
  game_visual:SetRoleClientIdent(visual_player, client_player.Ident)
  local posx, posy, posz, anglex, angley, anglez = get_config_data(get_scene_id())
  local terrain = scene.terrain
  terrain:AddVisualRole("", visual_player)
  terrain:RelocateVisual(visual_player, posx, posy, posz)
  terrain:RefreshVisual()
  visual_player:SetAngle(anglex, angley, anglez)
  return visual_player
end
function set_camera_movie(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local scene_id = get_scene_id()
  local camera_min_dis = get_config_item(scene_id, "camera_min_dis")
  local camera_max_dis = get_config_item(scene_id, "camera_max_dis")
  local camera_dis = get_config_item(scene_id, "camera_dis")
  local camera_offset_y = get_config_item(scene_id, "camera_offset_y")
  local camera_lookat_scale = get_config_item(scene_id, "camera_lookat_scale")
  camera_min_dis = camera_min_dis == 0 and DEF_CAMERA_MIN_DISTANCE or camera_min_dis
  camera_max_dis = camera_max_dis == 0 and DEF_CAMERA_MAX_DISTANCE or camera_max_dis
  camera_dis = camera_dis == 0 and DEF_CAMERA_DISTANCE or camera_dis
  camera_lookat_scale = camera_lookat_scale == 0 and DEF_CAMERA_LOOKAT_SCALE or camera_lookat_scale
  game_control.CameraMode = GAME_CAMERA_FIXTARGET
  game_control.CameraCollide = false
  local camera_fix = game_control:GetCameraController(GAME_CAMERA_FIXTARGET)
  if not nx_is_valid(camera_fix) then
    return
  end
  camera_fix.CanWheel = true
  camera_fix.CanSlide = true
  camera_fix.MinDistance = camera_min_dis
  camera_fix.MaxDistance = camera_max_dis
  camera_fix.ShortDisMode = true
  local actor2 = form.role_actor2
  if not nx_is_valid(actor2) then
    return
  end
  local time_count = 0
  while nx_is_valid(actor2) and nx_execute("role_composite", "is_loading", 2, actor2) do
    time_count = time_count + nx_pause(0.1)
    if 5 < time_count then
      return
    end
  end
  if not nx_is_valid(actor2) then
    return
  end
  local box_size_y = nx_execute("util_functions", "get_scene_obj_height", actor2)
  local actor_head_height = box_size_y * camera_lookat_scale
  local actor_pos_y = box_size_y
  local actor_pos_x = actor2.PositionX
  local actor_pos_z = actor2.PositionZ
  local actor_angle_y = actor2.AngleY
  local camera_pos_x = actor_pos_x + camera_dis * math.sin(actor_angle_y)
  local camera_pos_z = actor_pos_z + camera_dis * math.cos(actor_angle_y)
  local camera_pos_y = actor_pos_y + camera_offset_y
  local camera_angle_x = 0
  local camera_angle_y = actor_angle_y + math.pi
  local camera_angle_z = 0
  if camera_pos_y - actor2.PositionY < 0.5 then
    camera_pos_y = actor_pos_y + actor_head_height
    camera_angle_x = math.atan(actor_head_height / camera_dis)
  end
  camera_pos_y = camera_pos_y - actor_head_height / 12
  camera_fix:SetFixTarget(camera_pos_x, box_size_y, camera_pos_z, actor_pos_x, actor_pos_y, actor_pos_z)
end
function get_scene_id()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_int(-1)
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = get_ini("ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
function get_config_item(scene_id, item_name)
  local ini = get_ini(FACE_CAMERA_INI, true)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(scene_id))
  if sec_index < 0 then
    return 0
  end
  local value = nx_number(ini:ReadString(sec_index, nx_string(item_name), "0"))
  return value
end
function set_camra_normal(form)
  if not nx_is_valid(form) then
    return
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local visual_npc = form.role_actor2
  if not nx_is_valid(visual_npc) then
    return
  end
  local camera = scene.camera
  if not nx_is_valid(camera) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.CameraMode = GAME_CAMERA_NORMAL
  game_control.CameraCollide = true
  if CAMERA_ANGLE_X == nil or CAMERA_ANGLE_Y == nil or CAMERA_DISTANCE == nil then
    return
  end
  game_control.PitchAngle = CAMERA_ANGLE_X
  game_control.YawAngle = CAMERA_ANGLE_Y
  game_control.Distance = CAMERA_DISTANCE
end
function get_player_sex()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return ""
  end
  local sex = client_player:QueryProp("Sex")
  return sex
end
function set_rbtn_stage_photo(group_box, item_type, sex)
  local child_control_list = group_box:GetChildControlList()
  local ini
  ini = get_ini("ini\\form\\create_form_new.ini", true)
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
      if nx_string(item_type) == nx_string("beforehand") and table.getn(value_list) >= 3 then
        rbtn.model_face_id = value_list[3]
      end
    end
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function init_face_data(form)
  local actor2 = get_role_face(form)
  while not nx_is_valid(actor2) do
    nx_pause(0.1)
    actor2 = get_role_face(form)
  end
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  for i = 1, 21 do
    local index = nx_string("face_" .. i)
    local value_list = create_role:GetPlayerFaceDetailHV(index)
    local h = value_list[1]
    local v = value_list[2]
    if nil == h or nil == v then
      return
    end
    nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, h, v, index, nx_float(4.0E-4), nx_float(0))
  end
  if nx_int(create_role.PlayerFaceBeard) > nx_int(19) then
    set_init_face_materialfile(actor2, form)
  else
    set_face_materialfile(actor2, form.sex, nx_string(create_role.PlayerFaceFeature), nx_string(create_role.PlayerFaceBeard))
  end
  player_face_random_action(form)
end
function get_config_data(scene_id)
  local ini = get_ini(FACE_CAMERA_INI, true)
  if not nx_is_valid(ini) then
    return 0, 0, 0, 0, 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(scene_id))
  if sec_index < 0 then
    return 0, 0, 0, 0, 0, 0
  end
  local posx = nx_number(ini:ReadString(sec_index, "role_posx", "0"))
  local posy = nx_number(ini:ReadString(sec_index, "role_posy", "0"))
  local posz = nx_number(ini:ReadString(sec_index, "role_posz", "0"))
  local anglex = nx_number(ini:ReadString(sec_index, "role_anglex", "0"))
  local angley = nx_number(ini:ReadString(sec_index, "role_angley", "0"))
  local anglez = nx_number(ini:ReadString(sec_index, "role_anglez", "0"))
  return posx, posy, posz, anglex, angley, anglez
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function apply_save_ini_beforehand(form)
  if not nx_is_valid(form) then
    return
  end
  local str_sex = form.sex == 0 and "b_face" or "g_face"
  local face_path = "obj\\char\\" .. str_sex .. "\\face_" .. nx_string(form.beforehand) .. "\\face.ini"
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local actor2_face = get_role_face(form)
  if nil == actor2_face then
    return
  end
  create_role:ApplyAdvanceFace(face_path, actor2_face)
  create_role.PlayerFaceFeature = nx_int(form.beforehand)
  local feature = form.feature
  if nx_int(form.feature) == nx_int(0) then
    feature = nx_int(1)
  end
  set_face_materialfile(actor2_face, form.sex, nx_string(form.beforehand), nx_string(feature))
  local beforehand = fix_beforehand_index(form, form.beforehand)
  set_group_box_rbtns_init(form, "rbtn_", beforehand)
end
function apply_save_ini_feature(form)
  if not nx_is_valid(form) then
    return
  end
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local actor2_face = get_role_face(form)
  if nil == actor2_face then
    return
  end
  create_role.PlayerFaceBeard = nx_int(form.feature)
  local beforehand = form.beforehand
  if nx_int(form.beforehand) == nx_int(0) then
    beforehand = nx_int(1)
  end
  set_face_materialfile(actor2_face, form.sex, nx_string(beforehand), nx_string(form.feature))
  set_group_box_rbtns_init(form, "rbtn_feature_", form.feature)
end
function load_cost_ini(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini(FACE_COST_ITEM, true)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("item")
  if index < 0 then
    return false
  end
  local stritem = ini:ReadString(index, "id", "")
  local num = ini:ReadInteger(index, "num", 0)
  if stritem == "" or num <= 0 then
    return
  end
  form.cost_item = stritem
  form.cost_num = num
end
function check_cost_item(form)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return nil, nil
  end
  local ini = get_ini(FACE_COST_ITEM, true)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("item")
  if index < 0 then
    return nil, nil
  end
  local maxLv = ini:ReadInteger(index, "MaxLv", 0)
  if maxLv <= 0 then
    return nil, nil
  end
  for i = maxLv, 1, -1 do
    local sec_index = ini:FindSectionIndex(nx_string(i))
    if 0 <= index then
      local stritem = ini:ReadString(sec_index, "id", "")
      local num = ini:ReadInteger(sec_index, "num", 0)
      if stritem ~= "" and 0 < num and GoodsGrid:CheckItemCount(stritem, num) then
        return stritem, num
      end
    end
  end
  return nil, nil
end
function hide_main_form()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form_main.btn_func_guide.Visible = false
end
function show_main_form()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  form_main.btn_func_guide.Visible = true
end
function init_actor_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.role_actor2) then
    return
  end
  local sex = form.sex
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local hat_model = player:QueryProp("Hair")
  local cloth_model = get_equip_info("cloth", sex, 0)
  local pants_model = get_equip_info("pants", sex, 0)
  local shoes_model = get_equip_info("shoes", sex, 0)
  local role_actor2 = form.role_actor2
  local skin_info = {
    [1] = {link_name = "cloth", model_name = cloth_model},
    [2] = {link_name = "pants", model_name = pants_model},
    [3] = {link_name = "shoes", model_name = shoes_model},
    [4] = {link_name = "hat", model_name = hat_model}
  }
  for i, info in ipairs(skin_info) do
    if info.model_name ~= nil and "" ~= info.model_name then
      link_skin(role_actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
end
function reset_face_succeed()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local client_player = get_player()
  create_role:LoadPlayerFaceData(client_player)
end
function set_init_face_materialfile(actor2, form)
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local create_role = nx_value("create_role")
  if not nx_is_valid(create_role) then
    return
  end
  local sex = form.sex
  local str_sex = sex == 0 and "b_face" or "g_face"
  local skin = actor2:GetLinkObject(str_sex)
  local face_type = nx_string(create_role.PlayerFaceFeature)
  local index = nx_string(create_role.PlayerFaceBeard)
  if "" == face_type then
    return
  end
  local face_path = get_face_path(sex, face_type, index)
  if not nx_is_valid(skin) then
    return
  end
  on_del_beard(actor2)
  if 0 == sex and nx_int(index) > nx_int(1) and nx_int(index) < nx_int(5) then
    on_set_beard(actor2, sex, face_type, index)
  end
  change_face_skin_material(skin, "DiffuseMap", face_path)
end
function on_del_beard(actor2)
  local skin = actor2:GetLinkObject("beard")
  if nx_is_valid(skin) then
    actor2:DeleteSkin("beard")
    local world = nx_value("world")
    world:Delete(skin)
  end
end
function on_set_beard(actor2, sex, face_type, index)
  local beard_path = "obj\\char\\" .. get_beard_path(sex, face_type, index)
  link_skin(actor2, "beard", nx_string(beard_path) .. ".xmod")
  return true
end
function get_face_path(sex, face_type, index)
  local str_sex = sex == 0 and "b_face" or "g_face"
  if nx_int(index) > nx_int(19) then
    return "public\\" .. str_sex .. "_" .. index .. ".dds"
  else
    local str = nx_string("face_") .. nx_string(face_type)
    local face_path = str .. "\\" .. str_sex .. "_" .. index .. ".dds"
    return face_path
  end
  return ""
end
function change_face_skin_material(skin, key, value)
  if not nx_is_valid(skin) then
    return
  end
  local material_name_list = skin:GetMaterialNameList()
  if type(material_name_list) ~= "table" or table.getn(material_name_list) == 0 then
    return
  end
  for i, _ in ipairs(material_name_list) do
    if material_name_list[i] ~= "Standard_3" then
      skin:SetCustomMaterialValue(material_name_list[i], key, value)
    end
  end
  return skin:ReloadCustomMaterialTextures()
end
function get_beard_path(sex, face_type, index)
  local str_sex = sex == 0 and "b_face" or "g_face"
  local str = nx_string("face_") .. nx_string(face_type)
  local beard_path = str_sex .. "\\" .. str .. "\\b_huzi_" .. index
  return beard_path
end
function reset_face(form, role_model)
  if not nx_is_valid(form) or not nx_is_valid(role_model) then
    return
  end
  form.role_actor2 = role_model
  form.Visible = true
  init_face_data(form)
  local sex = form.sex
  local hat = nx_int(form.hat) - nx_int(1)
  local hat_model = get_equip_info("hat", sex, hat)
  if hat_model ~= nil and hat_model ~= "" then
    link_skin(role_model, "hat", hat_model .. ".xmod")
  end
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
