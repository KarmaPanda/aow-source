require("util_gui")
require("util_functions")
require("role_composite")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_loading"
local action_list = {
  "stand",
  "logoin_stand",
  "grd_0h_stand",
  "logoin_stand_2",
  "fwz_s060_stand",
  "logoin_stand"
}
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  change_form_size()
  form.open_time = 0
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_time", form, -1, -1)
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "reset_ng_page")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_bind_by_index", 1, 1)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_bind_by_index", 2, 2)
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "update_to_srv")
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_time", self)
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "sel_ng_first")
  nx_destroy(self)
end
function update_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.open_time = form.open_time + 1
  if form.open_time >= 10 then
    close_form()
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.gb_role.Width = form.Width
  form.gb_role.Height = form.Height
end
function update_form(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  local arg_count = #arg
  for i = 1, arg_count / 11 do
    local player_name = nx_widestr(arg[1 + (i - 1) * 11])
    local is_in = nx_number(arg[2 + (i - 1) * 11])
    local neigong = nx_string(arg[3 + (i - 1) * 11])
    local wuxue1 = nx_string(arg[4 + (i - 1) * 11])
    local wuxue2 = nx_string(arg[5 + (i - 1) * 11])
    local sex = nx_number(arg[6 + (i - 1) * 11])
    local face = nx_string(arg[7 + (i - 1) * 11])
    local hat = nx_string(arg[8 + (i - 1) * 11])
    local cloth = nx_string(arg[9 + (i - 1) * 11])
    local pants = nx_string(arg[10 + (i - 1) * 11])
    local shoes = nx_string(arg[11 + (i - 1) * 11])
    local gb_player_one = create_ctrl("GroupBox", "gb_player_" .. nx_string(i), form.gb_mod, form.gb_role)
    local lbl_1 = create_ctrl("Label", "lbl_1_" .. nx_string(i), form.lbl_1, gb_player_one)
    local lbl_3 = create_ctrl("Label", "lbl_3_" .. nx_string(i), form.lbl_3, gb_player_one)
    local lbl_4 = create_ctrl("Label", "lbl_4_" .. nx_string(i), form.lbl_4, gb_player_one)
    local lbl_6 = create_ctrl("Label", "lbl_6_" .. nx_string(i), form.lbl_6, gb_player_one)
    local sb_mod = create_ctrl("SceneBox", "sb_mod_" .. nx_string(i), form.sb_mod, gb_player_one)
    local lbl_mod_index = create_ctrl("Label", "lbl_mod_index_" .. nx_string(i), form.lbl_mod_index, gb_player_one)
    local lbl_mod_name = create_ctrl("Label", "lbl_mod_name_" .. nx_string(i), form.lbl_mod_name, gb_player_one)
    local lbl_mod_ng = create_ctrl("Label", "lbl_mod_ng_" .. nx_string(i), form.lbl_mod_ng, gb_player_one)
    local lbl_mod_wx1 = create_ctrl("Label", "lbl_mod_wx1_" .. nx_string(i), form.lbl_mod_wx1, gb_player_one)
    local lbl_mod_wx2 = create_ctrl("Label", "lbl_mod_wx2_" .. nx_string(i), form.lbl_mod_wx2, gb_player_one)
    local lbl_mod_in = create_ctrl("Label", "lbl_mod_in_" .. nx_string(i), form.lbl_mod_in, gb_player_one)
    if is_main_player(player_name) then
      local lbl_mod_my = create_ctrl("Label", "lbl_mod_my_" .. nx_string(i), form.lbl_mod_my, gb_player_one)
    end
    lbl_mod_name.Text = player_name
    lbl_mod_ng.Text = nx_widestr(util_text(neigong))
    lbl_mod_wx1.Text = nx_widestr(util_text(wuxue1))
    lbl_mod_wx2.Text = nx_widestr(util_text(wuxue2))
    if is_in == 1 then
      lbl_mod_in.BackImage = "gui\\special\\kof\\is_in.png"
    else
      lbl_mod_in.BackImage = "gui\\special\\kof\\not_in.png"
    end
    deal_scenebox(sb_mod, sex, face, hat, cloth, pants, shoes, is_in, wuxue1, i)
    gb_player_one.Top = 0
    if i <= 3 then
      gb_player_one.Left = gb_player_one.Width * 3 - gb_player_one.Width * i
      lbl_mod_index.Text = nx_widestr(util_text("ui_kof_war_index_" .. nx_string(i)))
    else
      gb_player_one.Left = form.gb_role.Width - gb_player_one.Width * (7 - i)
      lbl_mod_index.Text = nx_widestr(util_text("ui_kof_war_index_" .. nx_string(i - 3)))
      gb_player_one.HAnchor = "Right"
    end
  end
end
function get_default_model()
  local hat = "obj\\char\\b_hair\\b_hair1"
  local cloth = "obj\\char\\b_jianghu001\\b_cloth001"
  local pants = "obj\\char\\b_jianghu001\\b_pants001"
  local shoes = "obj\\char\\b_jianghu001\\b_shoes001"
  return hat, cloth, pants, shoes
end
function deal_scenebox(scenebox, sex, face, hat, cloth, pants, shoes, is_in, wuxue1, index)
  if is_in == 0 then
    hat, cloth, pants, shoes = get_default_model()
  end
  if nx_find_custom(scenebox, "role_actor2") and nx_is_valid(scenebox.role_actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.role_actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    util_addscene_to_scenebox(scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = create_role_composite(scenebox.Scene, false, nx_number(sex), action_list[index])
  nx_execute("role_composite", "unlink_skin", actor2, "Hat")
  link_skin(actor2, "hat", hat .. ".xmod", false)
  link_skin(actor2, "cloth", cloth .. ".xmod", false)
  link_skin(actor2, "pants", pants .. ".xmod", false)
  link_skin(actor2, "shoes", shoes .. ".xmod", false)
  local role_composite = nx_value("role_composite")
  if nx_is_valid(role_composite) and 0 < string.len(face) then
    role_composite:SetPlayerFaceDetial(get_role_face(actor2), nx_string(face), nx_int(sex), nx_null())
  end
  util_add_model_to_scenebox(scenebox, actor2)
  scenebox.role_actor2 = actor2
  if is_in == 0 then
    nx_function("ext_set_model_single_color", actor2, "0.05,0.05,0.05")
    nx_function("ext_set_model_around_color", actor2, "0.69,0.825,0.996", "0.005")
  end
  if index <= 3 then
    ui_RotateModel(scenebox, -0.8)
  else
    ui_RotateModel(scenebox, 0.8)
  end
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local wuxue_query = nx_value("WuXueQuery")
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  local weapon_name = nx_string(get_weapon_name(ItemType))
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  if nx_string(taolu) == "CS_th_bhcs" then
    weapon_name = "flute_thd_002"
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function get_weapon_name(item_type)
  if item_type == nil then
    return nil
  end
  if nx_int(item_type) == nx_int(101) then
    return "blade_0004"
  elseif nx_int(item_type) == nx_int(102) then
    return "sword_0004"
  elseif nx_int(item_type) == nx_int(103) then
    return "thorn_0004"
  elseif nx_int(item_type) == nx_int(104) then
    return "sblade_0004"
  elseif nx_int(item_type) == nx_int(105) then
    return "ssword_0004"
  elseif nx_int(item_type) == nx_int(106) then
    return "sthorn_0004"
  elseif nx_int(item_type) == nx_int(107) then
    return "lstuff_0004"
  elseif nx_int(item_type) == nx_int(108) then
    return "cosh_00033"
  elseif nx_int(item_type) == nx_int(122) then
    return "claymore_00022"
  elseif nx_int(item_type) == nx_int(123) then
    return "katar_0003"
  elseif nx_int(item_type) == nx_int(124) then
    return "pen_0004"
  elseif nx_int(item_type) == nx_int(125) then
    return "fan_0006"
  elseif nx_int(item_type) == nx_int(126) then
    return "zither_0002"
  elseif nx_int(item_type) == nx_int(127) then
    return "bow_0001"
  end
  return nil
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function get_role_face(actor2)
  local actor_role = actor2:GetLinkObject("actor_role")
  if not nx_is_valid(actor_role) then
    return nil
  end
  local actor_role_face = actor_role:GetLinkObject("actor_role_face")
  if not nx_is_valid(actor_role_face) then
    return nil
  end
  return actor_role_face
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(b)
  nx_msgbox(nx_string(b))
end
