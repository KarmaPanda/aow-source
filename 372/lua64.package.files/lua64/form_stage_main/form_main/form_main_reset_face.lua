require("util_functions")
require("role_composite")
require("util_gui")
require("define\\camera_mode")
require("form_stage_main\\form_talk_movie")
local FACE_CAMERA_INI = "ini\\form\\face_camera.ini"
local ROLE_FACE_INI = "ini\\form\\face.ini"
local MAX_ITEM_COUNT = 9
local SET_FACE_INFO = 0
local SET_BASE_FACE_INFO = 1
local FORM_NAME = "form_stage_main\\form_main\\form_main_reset_face"
local Khbd_Set_Face_Item = "item_npcyr_khbd"
local ST_Khbd_Set_Face = 623
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
local face_list = {
  brow = {
    "face_1",
    "face_2",
    "face_3"
  },
  eye = {
    "face_4",
    "face_5",
    "face_6"
  },
  nose = {
    "face_7",
    "face_8",
    "face_9"
  },
  ear = {
    "face_10",
    "face_11",
    "face_12"
  },
  zygoma = {
    "face_13",
    "face_14",
    "face_15"
  },
  mouth = {
    "face_16",
    "face_17",
    "face_18"
  },
  jaw = {
    "face_19",
    "face_20",
    "face_21"
  }
}
local face_ui_info = {
  face_1 = "ui_create_mx",
  face_2 = "ui_create_mg",
  face_3 = "ui_create_mm",
  face_4 = "ui_create_yd",
  face_5 = "ui_create_yx",
  face_6 = "ui_create_yw",
  face_7 = "ui_create_bx",
  face_8 = "ui_create_bw",
  face_9 = "ui_create_bt",
  face_10 = "ui_create_ew",
  face_11 = "ui_create_ed",
  face_12 = "ui_create_ex",
  face_13 = "ui_create_qw",
  face_14 = "ui_create_qx",
  face_15 = "ui_create_qd",
  face_16 = "ui_create_zw",
  face_17 = "ui_create_xc",
  face_18 = "ui_create_sc",
  face_19 = "ui_create_xex",
  face_20 = "ui_create_xjw",
  face_21 = "ui_create_xbw",
  face_22 = "ui_create_yk"
}
local function get_custom(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local custom_list = nx_custom_list(ent)
  log("custom_list bagin")
  for _, custom in ipairs(custom_list) do
    log("custom = " .. custom)
  end
  log("custom_list end")
end
local function get_property(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local property_list = nx_property_list(ent)
  log("property_list bagin")
  for _, property in ipairs(property_list) do
    log("property = " .. property)
  end
  log("property_list end")
end
function on_main_form_init(form)
  form.cost_total = 0
  form.min_page = 0
  form.max_page = 0
  form.max_face = 0
  form.last_face = ""
  form.is_drag = false
  form.last_rbtn = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.cost_total = 0
  form.Left = 0
  form.Top = 0
  form.min_page = 0
  form.max_page = 0
  form.max_face = 0
  form.is_drag = false
  form.actor2 = nx_null()
  form.last_face = ""
  form.last_rbtn = ""
  form.imagegrid_trait.show_index = 0
  change_form_size()
  set_ini_info(form)
  create_role_model(form)
  nx_execute(nx_current(), "set_camera_movie", form)
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    form_main_reset_face = nx_create("form_main_reset_face")
    nx_set_value("form_main_reset_face", form_main_reset_face)
  end
  local face_type = get_face_type_index()
  local client_player = get_player()
  form_main_reset_face:LoadCostIni()
  form_main_reset_face:InitPlayerFaceData(client_player)
  form_main_reset_face.PlayerFaceFeature = nx_int(face_type)
  local rbtn = get_frist_rbtn(form.groupbox_btn)
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
  local face_rbtn = get_frist_rbtn(form.groupbox_3)
  if nx_is_valid(face_rbtn) then
    face_rbtn.Checked = true
  end
  init_face_data(form)
  init_face_change_btn(form)
  hide_control_desktop()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    form_main.mltbox_battle.Visible = false
  end
  hide_around_obj()
  hide_head_info()
  remove_task_effect()
  remove_life_effect()
  local game_visual = nx_value("game_visual")
  local self_player = game_visual:GetPlayer()
  self_player.Visible = false
  form.Visible = true
  on_show_btn(form)
end
function on_show_btn(form)
  if not nx_is_valid(form) then
    return
  end
  local base_face = get_player_face(true)
  local cur_face = get_player_face(false)
  local enable = true
  if base_face == cur_face then
    enable = false
  else
    if base_face == nil or string.len(base_face) < 46 then
      enable = false
    end
    if not can_khbd_set_face() then
      enable = false
      form.btn_clear.Enabled = false
    end
  end
  form.btn_restore.Enabled = enable
end
function on_btn_restore_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_btn_restore_get_capture(btn)
  if btn.Enabled ~= false then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("16614")
  local x = btn.AbsLeft
  local y = btn.AbsTop
  if is_khbd() then
    if not is_khbd_set_face_switch_open() then
      text = gui.TextManager:GetFormatText("sys_khbd_yr_forbid")
    elseif not can_khbd_set_face() then
      text = gui.TextManager:GetFormatText("16620", gui.TextManager:GetText(Khbd_Set_Face_Item))
    end
  end
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, btn.ParentForm)
end
function on_main_form_close(form)
  if nx_running(nx_current(), "on_main_form_open") then
    nx_kill(nx_current(), "on_main_form_open")
  end
  local game_visual = nx_value("game_visual")
  local self_player = game_visual:GetPlayer()
  self_player.Visible = true
  show_control_desktop()
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if nx_is_valid(form_main) then
    form_main.mltbox_battle.Visible = true
  end
  cancel_ppdof_effect()
  show_around_obj()
  show_head_info()
  if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
    local world = nx_value("world")
    if nx_is_valid(world) then
      local scene = world.MainScene
      if nx_is_valid(scene) and nx_find_custom(scene, "terrain") then
        local terrain = scene.terrain
        if nx_is_valid(terrain) then
          terrain:RemoveVisual(form.actor2)
          terrain:RefreshVisual()
        end
      end
    end
  end
  set_camra_normal(form)
  nx_destroy(form)
  local tips_dialog = nx_value("form_reset_face_form_confirm")
  if nx_is_valid(tips_dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", tips_dialog.cancel_btn)
  end
end
function on_btn_exit_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function change_form_size()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Width = gui.Width
  form.Height = gui.Height
end
function get_role_face(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "actor2") then
    return nil
  end
  if not nx_is_valid(form.actor2) then
    return nil
  end
  local actor_role = form.actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor2_face = actor_role:GetLinkObject("actor_role_face")
  return actor2_face
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
function set_ini_info(form)
  local gui = nx_value("gui")
  local ini = get_ini(ROLE_FACE_INI, true)
  if not nx_is_valid(ini) or not ini:FindSection("root") then
    return
  end
  local index = ini:FindSectionIndex("root")
  local item_value_list = ini:GetItemValueList(index, "i")
  form.rbtn_type_template.Visible = true
  form.groupbox_btn:DeleteAll()
  local sex_name = ""
  local sex = get_player_sex()
  if nx_string(sex) == nx_string(0) then
    sex_name = "male"
  elseif nx_string(sex) == nx_string(1) then
    sex_name = "female"
  end
  if sex_name == "" then
    return
  end
  for i, item_value in ipairs(item_value_list) do
    if item_value == sex_name then
      local rbtn = gui:Create("RadioButton")
      set_ent_property(form.rbtn_type_template, rbtn)
      rbtn.Left = 0 * (rbtn.Width + 10)
      rbtn.Top = 0
      rbtn.Name = "ui_type_" .. item_value
      rbtn.Text = nx_widestr(gui.TextManager:GetText("ui_type_" .. item_value))
      rbtn.index = 0
      rbtn.item_value = item_value
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_rbtn_type_checked_changed")
      form.groupbox_btn:Add(rbtn)
    end
  end
  form.rbtn_type_template.Visible = false
end
function get_frist_rbtn(groupbox)
  local child_list = groupbox:GetChildControlList()
  for i, child in ipairs(child_list) do
    if not nx_find_custom(child, "index") then
      return child
    end
    if 0 == child.index then
      return child
    end
  end
  return
end
function set_trait_info(form, section)
  local gui = nx_value("gui")
  local ini = get_ini(ROLE_FACE_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  local sect_index = ini:FindSectionIndex(section)
  if sect_index < 0 then
    return
  end
  form.imagegrid_trait:Clear()
  local sex = get_player_sex()
  local value_list = ini:GetItemValueList(sect_index, nx_string(sex))
  local item_count = table.getn(value_list)
  local page_num = item_count / MAX_ITEM_COUNT
  local page_mod = item_count % MAX_ITEM_COUNT
  if page_mod == 0 then
    form.max_page = page_num
  else
    form.max_page = page_num + 1
  end
  for i, value in ipairs(value_list) do
    form.imagegrid_trait:AddItem(i - 1, nx_string(value), nx_widestr(i), nx_int(1), nx_int(1))
  end
  form.imagegrid_trait.Left = 0
  form.imagegrid_trait.show_index = 1
  form.lbl_curpage.Text = nx_widestr(1)
  form.min_page = nx_int(1)
  form.rbtn_page_template.Visible = false
  form.max_face = item_count
  if nx_int(nx_string(form.lbl_curpage.Text)) == nx_int(form.max_page) then
    form.btn_after.Enabled = false
  else
    form.btn_pre.Enabled = true
  end
  if nx_int(nx_string(form.lbl_curpage.Text)) == nx_int(form.min_page) then
    form.btn_pre.Enabled = false
  else
    form.btn_after.Enabled = true
  end
end
function on_imagegrid_trait_select_changed(image_grid)
  local index = image_grid:GetSelectItemIndex()
  local form = image_grid.ParentForm
  local max_face = form.max_face
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  if is_khbd() then
    if not is_khbd_set_face_switch_open() then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("sys_khbd_yr_forbid")
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      image_grid:SetSelectItemIndex(-1)
      return
    elseif not can_khbd_set_face() then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("16619", gui.TextManager:GetText(Khbd_Set_Face_Item))
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      image_grid:SetSelectItemIndex(-1)
      return
    end
  end
  if index < 0 or 9 < index or index >= max_face then
    return
  end
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local real_index = 20 + (image_grid.show_index - 1) * 9 + index
  if form_main_reset_face.PlayerFaceBeard == real_index then
    return
  end
  local face_index = ""
  local sex = get_player_sex()
  if nx_string(sex) == nx_string(0) then
    face_index = "face_b_"
  elseif nx_string(sex) == nx_string(1) then
    face_index = "face_g_"
  end
  local face_index = face_index .. nx_string(real_index)
  local bExists = form_main_reset_face:IsFaceExists(face_index)
  if bExists ~= true then
    return
  end
  local actor2 = get_role_face(form)
  set_face_materialfile(actor2, real_index)
  local last_cost = 0
  if form.last_face ~= "" then
    last_cost = form_main_reset_face:GetCostByName(form.last_face)
  end
  local cost = form_main_reset_face:GetCostByName(face_index)
  if 0 <= cost then
    form.cost_total = form.cost_total + cost - last_cost
    on_show_price(form)
  end
  form.last_face = face_index
end
function on_rbtn_type_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    set_trait_info(form, rbtn.item_value)
    form.item_value = rbtn.item_value
  end
end
function on_btn_reset_click(btn)
end
function on_btn_change_face_click(btn)
  local form = btn.ParentForm
  local old_face = get_player_face()
  local form_main_reset_face = nx_value("form_main_reset_face")
  local client_player = get_player()
  if not nx_is_valid(form_main_reset_face) or not nx_is_valid(client_player) then
    return
  end
  if not form_main_reset_face:IsChangeFace(client_player) then
    return
  end
  local gui = nx_value("gui")
  local sex = get_player_sex()
  local form_main_reset_face = nx_value("form_main_reset_face")
  local cost_total = form_main_reset_face:GetCostTotal(sex)
  local text
  if is_khbd() then
    if not is_khbd_set_face_switch_open() then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetFormatText("sys_khbd_yr_forbid"), 2)
      end
      return
    end
    text = gui.TextManager:GetFormatText("sys_khbd_yr_02", nx_int(cost_total), gui.TextManager:GetText(Khbd_Set_Face_Item))
  else
    text = gui.TextManager:GetFormatText("ui_reset_face_money", nx_int(cost_total))
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "form_reset_face")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "form_reset_face_confirm_return")
    if res == "ok" then
      local new_face = form_main_reset_face:GetPlayerFaceData()
      nx_execute("custom_sender", "custom_face", SET_FACE_INFO, new_face)
    end
  end
end
function on_rbtn_page_checked_changed(rbtn)
end
function move_page_grid(form, show_index)
  local time_count = 0
  local imagegrid_trait = form.imagegrid_trait
  local grid_width = form.imagegrid_trait.GridWidth
  local distance = nx_int(nx_int(grid_width) * 3) * show_index
  local left = imagegrid_trait.Left
  local total_time = 0.2
  while true do
    time_count = time_count + nx_pause(0)
    if total_time < time_count then
      time_count = total_time
      imagegrid_trait.Left = left + distance * (time_count / total_time)
      return true
    end
    imagegrid_trait.Left = left + distance * (time_count / total_time)
  end
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
  local client_obj = game_client:GetSceneObj(nx_string(client_player.Ident))
  if not nx_is_valid(client_obj) then
    return nx_null()
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return nx_null()
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nx_null()
  end
  local visual_player = role_composite:CreateSceneObject(scene, client_obj, false, false)
  if not nx_is_valid(visual_player) then
    return nx_null()
  end
  form.actor2 = visual_player
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
function on_rbtn_edit_face_details_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local gui = nx_value("gui")
    form.lbl_direction.Top = rbtn.Top + (rbtn.Height - form.lbl_direction.Height) / 2
    form.groupbox_track_rect.Left = form.lbl_direction.Left + form.lbl_direction.Width
    form.groupbox_track_rect.Top = rbtn.Top + (rbtn.Height - form.groupbox_track_rect.Height) / 2
    local index_1 = face_list[rbtn.DataSource][1]
    local index_2 = face_list[rbtn.DataSource][2]
    local index_3 = face_list[rbtn.DataSource][3]
    form.trackrect_1.index = nil
    form.trackrect_2.index = nil
    form.trackrect_3.index = nil
    if nx_string(rbtn.DataSource) == nx_string("brow") then
      set_trackrect_max(form.trackrect_1, 60, 60)
      set_trackrect_max(form.trackrect_2, 60, 60)
      set_trackrect_max(form.trackrect_3, 60, 60)
    else
      set_trackrect_max(form.trackrect_1, 100, 100)
      set_trackrect_max(form.trackrect_2, 100, 100)
      set_trackrect_max(form.trackrect_3, 100, 100)
    end
    set_trackrect_value(form.trackrect_1, index_1)
    set_trackrect_value(form.trackrect_2, index_2)
    set_trackrect_value(form.trackrect_3, index_3)
    form.trackrect_1.index = face_list[rbtn.DataSource][1]
    form.trackrect_1.index_s = rbtn.DataSource
    form.lbl_15.Text = nx_widestr(gui.TextManager:GetText(face_ui_info[form.trackrect_1.index]))
    form.trackrect_2.index = face_list[rbtn.DataSource][2]
    form.trackrect_2.index_s = rbtn.DataSource
    form.lbl_16.Text = nx_widestr(gui.TextManager:GetText(face_ui_info[form.trackrect_2.index]))
    form.trackrect_3.index = face_list[rbtn.DataSource][3]
    form.trackrect_3.index_s = rbtn.DataSource
    form.lbl_17.Text = nx_widestr(gui.TextManager:GetText(face_ui_info[form.trackrect_3.index]))
    form.last_rbtn = rbtn.DataSource
  end
end
function set_trackrect_value(trackrect, index)
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local value_list = form_main_reset_face:GetPlayerFaceDetailHV(index)
  local h = value_list[1]
  local v = value_list[2]
  if nil == v or nil == h then
    return
  end
  trackrect.HorizonValue = h
  trackrect.VerticalValue = v
end
function set_change_face(face)
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local value_list = form_main_reset_face:GetPlayerFaceDetailHV(face)
  local h = value_list[1]
  local v = value_list[2]
  if nil == v or nil == h then
    return
  end
  form_main_reset_face:SetChangeFaceDetailHV(face, h, v)
end
function on_trackrect_horizon_vertical_changed(self)
  if not nx_find_custom(self, "index") or nil == self.index then
    return
  end
  if not nx_find_custom(self, "index_s") or nil == self.index_s then
    return
  end
  local actor2 = get_role_face(self.ParentForm)
  if not nx_is_valid(actor2) then
    return
  end
  local form_main_reset_face = nx_value("form_main_reset_face")
  if nx_is_valid(form_main_reset_face) and not form_main_reset_face.EditFace then
    nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, self.HorizonValue, self.VerticalValue, self.index, nx_float(4.0E-4), nx_float(0))
    form_main_reset_face:SetPlayerFaceDetailHV(self.index, self.HorizonValue, self.VerticalValue)
    form_main_reset_face:SetChangeFaceDetailHV(self.index, self.HorizonValue, self.VerticalValue)
    on_set_change_btn(self.ParentForm, self.index_s)
  end
end
function init_face_data(form)
  local actor2 = get_role_face(form)
  while not nx_is_valid(actor2) do
    nx_pause(0.1)
    actor2 = get_role_face(form)
  end
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  for i = 1, 21 do
    local index = nx_string("face_" .. i)
    local value_list = form_main_reset_face:GetPlayerFaceDetailHV(index)
    local h = value_list[1]
    local v = value_list[2]
    if nil == h or nil == v then
      return
    end
    nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, h, v, index, nx_float(4.0E-4), nx_float(0))
  end
  player_face_random_action(form)
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
function set_model_angle(btn, direction)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926 * direction
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    local model = form.actor2
    if nx_is_valid(model) then
      local angle_x = model.AngleX
      local angle_y = model.AngleY
      local angle_z = model.AngleZ
      angle_y = angle_y + dist
      model:SetAngle(angle_x, angle_y, angle_z)
    end
  end
end
function player_face_random_action(form)
  local asynor = nx_value("common_execute")
  if not nx_is_valid(form) or not nx_find_custom(form, "actor2") then
    return nil
  end
  if not nx_is_valid(form.actor2) then
    return nil
  end
  local role_actor2 = form.actor2
  role_actor2.random_eyes_time = 3
  asynor:AddExecute("FaceRandomAction", role_actor2, nx_float(0))
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
function get_face_type_index(is_base_face)
  local face = get_player_face(is_base_face)
  local length = string.len(face)
  if length < 46 then
    return ""
  end
  local face_type = string.sub(face, 45, 45)
  return string.byte(face_type)
end
function get_face_type_face_beard(is_base_face)
  local face = get_player_face(is_base_face)
  local length = string.len(face)
  if length < 46 then
    return ""
  end
  local face_type = string.sub(face, 46, 46)
  return string.byte(face_type)
end
function get_player_face(is_base_face)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return ""
  end
  local face = client_player:QueryProp("Face")
  if nil ~= is_base_face and true == is_base_face then
    face = client_player:QueryProp("BaseFace")
  end
  return face
end
function get_player_sex()
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return ""
  end
  local sex = client_player:QueryProp("Sex")
  return sex
end
function set_face_materialfile(actor2, index)
  local sex = get_player_sex()
  local str_sex = sex == 0 and "b_face" or "g_face"
  local skin = actor2:GetLinkObject(str_sex)
  local face_type = get_face_type_index()
  if "" == face_type then
    return
  end
  local face_path = get_face_path(sex, face_type, index)
  if not nx_is_valid(skin) then
    return
  end
  del_beard(actor2)
  if 0 == sex and 1 < index and index < 5 then
    set_beard(actor2, sex, face_type, index)
  end
  change_face_skin_material(skin, "DiffuseMap", face_path)
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  form_main_reset_face.PlayerFaceBeard = index
end
function get_beard_path(sex, face_type, index)
  local str_sex = sex == 0 and "b_face" or "g_face"
  local str = nx_string("face_") .. nx_string(face_type)
  local beard_path = str_sex .. "\\" .. str .. "\\b_huzi_" .. index
  return beard_path
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
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function del_beard(actor2)
  local skin = actor2:GetLinkObject("beard")
  if nx_is_valid(skin) then
    actor2:DeleteSkin("beard")
    local world = nx_value("world")
    world:Delete(skin)
  end
end
function set_beard(actor2, sex, face_type, index)
  local beard_path = "obj\\char\\" .. get_beard_path(sex, face_type, index)
  link_skin(actor2, "beard", nx_string(beard_path) .. ".xmod")
  return true
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
function get_scene_obj_height_ex(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return actor2.BoxSizeY
  end
  if actor_role:NodeIsExist("BoneRUe05") then
    local x, y, z = actor_role:GetNodePosition("BoneRUe05")
    return y + 0.05
  end
  return actor2.BoxSizeY
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
  local actor2 = form.actor2
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
  local visual_npc = form.actor2
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
function on_btn_read_click(self)
  local form = self.ParentForm
  if nx_is_valid(nx_value("form_stage_create\\form_face_save")) then
    return
  end
  local dialog = util_get_form("form_stage_create\\form_face_read", true, false)
  dialog:ShowModal()
  local res, full_name = nx_wait_event(100000000, dialog, "read_face_return")
  if "ok" == res then
    if not nx_is_valid(self) then
      return false
    end
    local str_data = nx_function("ext_read_face_file", "", full_name)
    local face = string.sub(str_data, 1, 46)
    if "" == str_data then
      return
    end
    local actor2 = get_role_face(form)
    local role_composite = nx_value("role_composite")
    local sex = get_player_sex()
    local form_main_reset_face = nx_value("form_main_reset_face")
    local client_player = get_player()
    if not nx_is_valid(actor2) or not nx_is_valid(form_main_reset_face) then
      return
    end
    role_composite:SetPlayerFaceDetial(actor2, face, sex, nx_null())
    form_main_reset_face:SetLocalFaceData(face)
    form.cbtn_brow.Checked = false
    form.cbtn_eye.Checked = false
    form.cbtn_nose.Checked = false
    form.cbtn_zygoma.Checked = false
    form.cbtn_ear.Checked = false
    form.cbtn_mouth.Checked = false
    form.cbtn_jaw.Checked = false
    init_face_data(form)
    if form.last_rbtn ~= "" then
      local btn_name = form.last_rbtn
      local groupbox = form.groupbox_3
      local rbtn = groupbox:Find("rbtn_" .. btn_name)
      if nx_is_valid(rbtn) then
        local index_1 = face_list[btn_name][1]
        local index_2 = face_list[btn_name][2]
        local index_3 = face_list[btn_name][3]
        form_main_reset_face.EditFace = true
        set_trackrect_value(form.trackrect_1, index_1)
        set_trackrect_value(form.trackrect_2, index_2)
        set_trackrect_value(form.trackrect_3, index_3)
        form_main_reset_face.EditFace = false
      end
    end
    local sex = get_player_sex()
    on_show_price(form)
  end
end
function on_btn_save_click(self)
  local form_logic = nx_value("form_main_reset_face")
  if not nx_is_valid(form_logic) then
    return
  end
  local form = self.ParentForm
  local data = form_logic:GetPlayerFaceData()
  if data == "" then
    return
  end
  if nx_is_valid(nx_value("form_stage_create\\form_face_read")) then
    return
  end
  local dialog = util_get_form("form_stage_create\\form_face_save", true, false)
  dialog:ShowModal()
  local res, full_name = nx_wait_event(100000000, dialog, "save_face_return")
  if "ok" == res then
    if not nx_is_valid(self) then
      return
    end
    data = data .. string.char(1)
    data = data .. string.char(1)
    data = data .. string.char(1)
    data = data .. string.char(1)
    data = data .. string.char(1)
    local sex = get_player_sex()
    data = data .. string.char(sex + 1)
    data = data .. string.char(1)
    data = data .. string.char(1)
    local create_time = os.date("%Y.%m.%d %H:%M")
    data = data .. create_time
    nx_function("ext_write_face_file", "", full_name, data)
  end
end
function on_btn_restore_click(btn)
  local form = btn.ParentForm
  local actor2 = get_role_face(form)
  local role_composite = nx_value("role_composite")
  local sex = get_player_sex()
  local form_main_reset_face = nx_value("form_main_reset_face")
  local client_player = get_player()
  if not (nx_is_valid(actor2) and nx_is_valid(form_main_reset_face)) or not nx_is_valid(client_player) then
    return
  end
  if not can_khbd_set_face() then
    return
  end
  local succeed = form_main_reset_face:RestoreBaseFace(client_player, form.actor2)
  if succeed ~= true then
    return
  end
  form.is_drag = true
  form.cbtn_brow.Checked = false
  form.cbtn_eye.Checked = false
  form.cbtn_nose.Checked = false
  form.cbtn_zygoma.Checked = false
  form.cbtn_ear.Checked = false
  form.cbtn_mouth.Checked = false
  form.cbtn_jaw.Checked = false
  form.is_drag = false
  form.imagegrid_trait:SetSelectItemIndex(-1)
  if form.last_rbtn ~= "" then
    local btn_name = form.last_rbtn
    local groupbox = form.groupbox_3
    local rbtn = groupbox:Find("rbtn_" .. btn_name)
    if nx_is_valid(rbtn) then
      local index_1 = face_list[btn_name][1]
      local index_2 = face_list[btn_name][2]
      local index_3 = face_list[btn_name][3]
      form_main_reset_face.EditFace = true
      set_trackrect_value(form.trackrect_1, index_1)
      set_trackrect_value(form.trackrect_2, index_2)
      set_trackrect_value(form.trackrect_3, index_3)
      form_main_reset_face.EditFace = false
    end
  end
  local old_beard = form_main_reset_face.PlayerFaceBeard
  local actor2 = get_role_face(form)
  set_face_materialfile(actor2, nx_number(old_beard))
  form.last_face = ""
  form.cost_total = 0
  for part_name, index_list in pairs(face_list) do
    local index_1 = index_list[1]
    local index_2 = index_list[2]
    local index_3 = index_list[3]
    if index_1 ~= nil and index_2 ~= nil and index_3 ~= nil then
      local change_1 = form_main_reset_face:IsChangeFacePart(index_1)
      local change_2 = form_main_reset_face:IsChangeFacePart(index_2)
      local change_3 = form_main_reset_face:IsChangeFacePart(index_3)
      if change_1 == false or change_2 == false or change_3 == false then
        local cost = form_main_reset_face:GetCostByName(part_name)
        if 0 <= cost then
          form.cost_total = form.cost_total + cost
        end
      end
    end
  end
  on_show_price(form)
end
function on_set_change_btn(form, btn_name)
  if btn_name == "" or btn_name == nil then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_5
  local btn = groupbox:Find("cbtn_" .. btn_name)
  if not nx_is_valid(btn) then
    return
  end
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local index_1 = face_list[btn_name][1]
  local index_2 = face_list[btn_name][2]
  local index_3 = face_list[btn_name][3]
  if index_1 == nil or index_1 == "" then
    return
  end
  if index_2 == nil or index_2 == "" then
    return
  end
  if index_3 == nil or index_3 == "" then
    return
  end
  local change_1 = form_main_reset_face:IsChangeFacePart(index_1)
  local change_2 = form_main_reset_face:IsChangeFacePart(index_2)
  local change_3 = form_main_reset_face:IsChangeFacePart(index_3)
  if (change_1 == false or change_2 == false or change_3 == false) and btn.Checked ~= true then
    if btn.Enabled == true then
      set_change_face(index_1)
      set_change_face(index_2)
      set_change_face(index_3)
    else
      btn.Enabled = true
    end
    form.is_drag = true
    btn.Checked = true
    form.is_drag = false
    local cost = form_main_reset_face:GetCostByName(btn.DataSource)
    if 0 <= cost then
      form.cost_total = form.cost_total + cost
    end
    on_show_price(form)
  end
end
function init_face_change_btn(form)
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_brow.Enabled = false
  form.cbtn_eye.Enabled = false
  form.cbtn_nose.Enabled = false
  form.cbtn_zygoma.Enabled = false
  form.cbtn_ear.Enabled = false
  form.cbtn_mouth.Enabled = false
  form.cbtn_jaw.Enabled = false
end
function on_show_price(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "cost_total") then
    return
  end
  form.mltbox_1:Clear()
  local sex = get_player_sex()
  local form_main_reset_face = nx_value("form_main_reset_face")
  local cost_total = form_main_reset_face:GetCostTotal(sex)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_recast_cost")
  gui.TextManager:Format_AddParam(cost_total)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_1:AddHtmlText(text, -1)
  form.mltbox_1.Visible = true
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  if is_khbd() then
    if not is_khbd_set_face_switch_open() then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("sys_khbd_yr_forbid")
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      return
    elseif not can_khbd_set_face() then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("16619", gui.TextManager:GetText(Khbd_Set_Face_Item))
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      return
    end
  end
  local new_beard = form_main_reset_face.PlayerFaceBeard
  if nx_int(new_beard) < nx_int(10) then
    form.imagegrid_trait:SetSelectItemIndex(-1)
    return
  end
  local old_beard = get_face_type_face_beard()
  local actor2 = get_role_face(form)
  set_face_materialfile(actor2, old_beard)
  form.imagegrid_trait:SetSelectItemIndex(-1)
  local face_index = ""
  local sex = get_player_sex()
  if nx_string(sex) == nx_string(0) then
    face_index = "face_b_"
  elseif nx_string(sex) == nx_string(1) then
    face_index = "face_g_"
  end
  local face_index = face_index .. nx_string(new_beard)
  local cost = form_main_reset_face:GetCostByName(face_index)
  if 0 <= cost then
    form.cost_total = form.cost_total - cost
    on_show_price(form)
  end
  form.last_face = ""
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  local cur_page = form.imagegrid_trait.show_index
  cur_page = cur_page - 1
  if form.btn_after.Enabled == false then
    form.btn_after.Enabled = true
  end
  if cur_page <= 1 then
    btn.Enabled = false
  end
  on_show_cur_page(form, cur_page)
end
function on_btn_after_click(btn)
  local form = btn.ParentForm
  local cur_page = form.imagegrid_trait.show_index
  cur_page = cur_page + 1
  if form.btn_pre.Enabled == false then
    form.btn_pre.Enabled = true
  end
  if nx_int(cur_page) >= nx_int(form.max_page) then
    btn.Enabled = false
  end
  on_show_cur_page(form, cur_page)
end
function on_show_cur_page(form, page)
  if not nx_is_valid(form) then
    return
  end
  if page <= 0 or nx_int(page) > nx_int(form.max_page) then
    return
  end
  local show_index = page
  local ini = get_ini(ROLE_FACE_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  local sect_index = ini:FindSectionIndex(form.item_value)
  if sect_index < 0 then
    return
  end
  form.imagegrid_trait:Clear()
  form.imagegrid_trait:SetSelectItemIndex(-1)
  local sex = get_player_sex()
  local value_list = ini:GetItemValueList(sect_index, nx_string(sex))
  local item_count = table.getn(value_list)
  local begin_index = (show_index - 1) * MAX_ITEM_COUNT + 1
  local show_count = item_count - begin_index
  if 9 < show_count then
    show_count = 9
  end
  show_count = show_count + begin_index
  local item_index = 0
  for i = begin_index, show_count do
    form.imagegrid_trait:AddItem(item_index, nx_string(value_list[i]), nx_widestr(item_index), nx_int(1), nx_int(1))
    item_index = item_index + 1
  end
  form.imagegrid_trait.show_index = show_index
  form.lbl_curpage.Text = nx_widestr(show_index)
end
function on_cbtn_reset_face_part(cbtn)
  local form = cbtn.ParentForm
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  if form.is_drag == true then
    return
  end
  local actor2 = get_role_face(form)
  if not nx_is_valid(actor2) then
    return
  end
  local checked = cbtn.Checked
  local index_1 = face_list[cbtn.DataSource][1]
  local index_2 = face_list[cbtn.DataSource][2]
  local index_3 = face_list[cbtn.DataSource][3]
  if checked then
    form_main_reset_face:UpDataFaceDetailHV(index_1)
    form_main_reset_face:UpDataFaceDetailHV(index_2)
    form_main_reset_face:UpDataFaceDetailHV(index_3)
  else
    form_main_reset_face:ResetPlayerFaceDetail(index_1)
    form_main_reset_face:ResetPlayerFaceDetail(index_2)
    form_main_reset_face:ResetPlayerFaceDetail(index_3)
  end
  local value_list = form_main_reset_face:GetPlayerFaceDetailHV(index_1)
  local h = value_list[1]
  local v = value_list[2]
  nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, h, v, index_1, nx_float(4.0E-4), nx_float(0))
  value_list = form_main_reset_face:GetPlayerFaceDetailHV(index_2)
  h = value_list[1]
  v = value_list[2]
  nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, h, v, index_2, nx_float(4.0E-4), nx_float(0))
  value_list = form_main_reset_face:GetPlayerFaceDetailHV(index_3)
  h = value_list[1]
  v = value_list[2]
  nx_execute("form_stage_create\\form_face_edit", "set_actor2_parameter", actor2, h, v, index_3, nx_float(4.0E-4), nx_float(0))
  local cost = form_main_reset_face:GetCostByName(cbtn.DataSource)
  form.cost_total = 0
  if 0 <= cost then
    if checked then
      local change_1 = form_main_reset_face:IsChangeFacePart(index_1)
      local change_2 = form_main_reset_face:IsChangeFacePart(index_2)
      local change_3 = form_main_reset_face:IsChangeFacePart(index_3)
      if change_1 == false or change_2 == false or change_3 == false then
        form.cost_total = form.cost_total + cost
      end
    else
      form.cost_total = form.cost_total - cost
    end
    on_show_price(form)
  end
  local groupbox = form.groupbox_3
  local rbtn = groupbox:Find("rbtn_" .. cbtn.DataSource)
  if not nx_is_valid(rbtn) then
    return
  end
  form_main_reset_face.EditFace = true
  if rbtn.Checked == true then
    set_trackrect_value(form.trackrect_1, index_1)
    set_trackrect_value(form.trackrect_2, index_2)
    set_trackrect_value(form.trackrect_3, index_3)
  end
  form_main_reset_face.EditFace = false
end
function reset_face_succeed()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local form_main_reset_face = nx_value("form_main_reset_face")
  if not nx_is_valid(form_main_reset_face) then
    return
  end
  local client_player = get_player()
  form_main_reset_face:InitPlayerFaceData(client_player)
  form_main_reset_face.PlayerFaceBeard = get_face_type_face_beard()
  form.is_drag = true
  form.cbtn_brow.Enabled = false
  form.cbtn_brow.Checked = false
  form.cbtn_eye.Enabled = false
  form.cbtn_eye.Checked = false
  form.cbtn_nose.Enabled = false
  form.cbtn_nose.Checked = false
  form.cbtn_zygoma.Enabled = false
  form.cbtn_zygoma.Checked = false
  form.cbtn_ear.Enabled = false
  form.cbtn_ear.Checked = false
  form.cbtn_mouth.Enabled = false
  form.cbtn_mouth.Checked = false
  form.cbtn_jaw.Enabled = false
  form.cbtn_jaw.Checked = false
  form.is_drag = false
  form.cost_total = 0
  form.last_face = ""
  on_show_btn(form)
  on_show_price(form)
end
function set_trackrect_max(trackrect, max_h, mn_v)
  if not nx_is_valid(trackrect) then
    return
  end
  trackrect.HorizonMax = max_h
  trackrect.VerticalMax = max_h
end
function is_khbd()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local khbd_level = client_player:QueryProp("SB_KHBD_Level")
  local modify_face = client_player:QueryProp("ModifyFace")
  return 0 < khbd_level or modify_face ~= "" and modify_face ~= 0
end
function has_item(item_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local view_id = goods_grid:GetToolBoxViewport(nx_string(item_id))
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return false
  end
  local count = view:GetViewObjCount()
  for i = 1, count do
    local obj = view:GetViewObjByIndex(i - 1)
    if nx_string(obj:QueryProp("ConfigID")) == nx_string(item_id) then
      return true
    end
  end
  return false
end
function is_khbd_set_face_switch_open()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  return switch_manager:CheckSwitchEnable(ST_Khbd_Set_Face)
end
function can_khbd_set_face()
  if is_khbd() then
    if not is_khbd_set_face_switch_open() then
      return false
    end
    return has_item(Khbd_Set_Face_Item)
  else
    return true
  end
end
