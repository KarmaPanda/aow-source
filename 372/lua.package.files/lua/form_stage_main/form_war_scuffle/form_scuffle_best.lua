require("util_gui")
require("util_functions")
require("util_static_data")
require("define\\sysinfo_define")
require("custom_sender")
require("form_stage_main\\form_war_scuffle\\luandou_util")
local FORM_NAME = "form_stage_main\\form_war_scuffle\\form_scuffle_best"
local laundou_zhaunbei = "luandou_zhaungbei_"
local array_ui = {}
function open_form(...)
  local form = get_form()
  if not nx_is_valid(form) then
    util_show_form(FORM_NAME, true)
  end
  receive_ui(unpack(arg))
end
function request_open_form()
  request_ui()
end
function close_form()
  local form = get_form()
  if nx_is_valid(form) then
    form:Close()
  end
end
local array_event = {}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.groupbox_5.Visible = false
  reset_form_position()
  clear()
  load_scenebox(form.scenebox_1)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  stop_skill_action()
  delete_role_model(form.scenebox_1)
  nx_destroy(form)
end
function reset_form_position()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local score_form = nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_score", "get_form")
  if nx_is_valid(score_form) then
    local self_width = form.lbl_4.Left + form.lbl_4.Width
    local gap = 5
    local total_width = self_width + score_form.Width + gap
    form.AbsLeft = (gui.Width - total_width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
    score_form.AbsLeft = form.AbsLeft + self_width + gap
    score_form.AbsTop = (gui.Height - score_form.Height) / 2
  else
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
  end
end
function on_btn_1_click(btn)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_5.Visible = not form.groupbox_5.Visible
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
end
function request_ui()
  custom_taosha(nx_int(109))
end
function receive_ui(...)
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local n = #arg
  if n < 26 then
    return
  end
  clear()
  for i = 1, 3 do
    local index = 7 * (i - 1) + 1
    local ui = array_ui[index]
    show_kill(ui.label, ui.label_star, nx_int(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_help_kill(ui.label, ui.label_star, nx_int(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_damage(ui.label, ui.label_star, nx_int64(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_flag(ui.label, ui.label_star, nx_int(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_kill_combo(ui.label, ui.label_star, nx_int(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_control_skill_count(ui.label, ui.label_star, nx_int(arg[index]))
    index = index + 1
    ui = array_ui[index]
    show_help_skill_count(ui.label, ui.label_star, nx_int(arg[index]))
  end
  local mvp_name = nx_widestr(arg[22])
  local mvp_neigong = nx_string(arg[23])
  local mvp_wuxue = nx_string(arg[24])
  local mvp_equip = nx_string(arg[25])
  local mvp_jingmai = nx_string(arg[26])
  form.lbl_1.Text = mvp_name
  show_name(mvp_neigong, "", form.lbl_ng)
  show_name(mvp_wuxue, "", form.lbl_own_skill_1, form.lbl_own_skill_2, form.lbl_own_skill_3)
  show_name(mvp_jingmai, "", form.lbl_jm_1, form.lbl_jm_2, form.lbl_jm_3, form.lbl_jm_4, form.lbl_jm_5, form.lbl_jm_6, form.lbl_jm_7, form.lbl_jm_8)
  show_name(mvp_equip, "luandou_zhaungbei_", form.lbl_equip, form.lbl_wuqi, form.lbl_shangyi)
  if 27 < n then
    local array_mvp_model = {}
    for i = 27, n do
      table.insert(array_mvp_model, arg[i])
    end
    stop_skill_action()
    show_mvp_model(form.scenebox_1, unpack(array_mvp_model))
    local mvp_skill_id_list = get_skill_id_list(mvp_wuxue)
    show_zhaoshi(mvp_skill_id_list)
  end
end
function l(info)
  nx_msgbox(nx_string(info))
end
function get_form()
  local form = nx_value(FORM_NAME)
  return form
end
function init()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  array_ui = {}
  for i = 1, 21 do
    table.insert(array_ui, {})
  end
  array_ui[1] = {
    label = form.lbl_8,
    label_star = form.lbl_11
  }
  array_ui[2] = {
    label = form.lbl_9,
    label_star = form.lbl_12
  }
  array_ui[3] = {
    label = form.lbl_10,
    label_star = form.lbl_13
  }
  array_ui[4] = {
    label = form.lbl_44,
    label_star = form.lbl_48
  }
  array_ui[5] = {
    label = form.lbl_45,
    label_star = form.lbl_49
  }
  array_ui[6] = {
    label = form.lbl_46,
    label_star = form.lbl_50
  }
  array_ui[7] = {
    label = form.lbl_47,
    label_star = form.lbl_51
  }
  array_ui[8] = {
    label = form.lbl_28,
    label_star = form.lbl_31
  }
  array_ui[9] = {
    label = form.lbl_29,
    label_star = form.lbl_32
  }
  array_ui[10] = {
    label = form.lbl_30,
    label_star = form.lbl_33
  }
  array_ui[11] = {
    label = form.lbl_60,
    label_star = form.lbl_68
  }
  array_ui[12] = {
    label = form.lbl_61,
    label_star = form.lbl_69
  }
  array_ui[13] = {
    label = form.lbl_62,
    label_star = form.lbl_70
  }
  array_ui[14] = {
    label = form.lbl_63,
    label_star = form.lbl_71
  }
  array_ui[15] = {
    label = form.lbl_18,
    label_star = form.lbl_21
  }
  array_ui[16] = {
    label = form.lbl_19,
    label_star = form.lbl_22
  }
  array_ui[17] = {
    label = form.lbl_20,
    label_star = form.lbl_23
  }
  array_ui[18] = {
    label = form.lbl_64,
    label_star = form.lbl_72
  }
  array_ui[19] = {
    label = form.lbl_65,
    label_star = form.lbl_73
  }
  array_ui[20] = {
    label = form.lbl_66,
    label_star = form.lbl_74
  }
  array_ui[21] = {
    label = form.lbl_67,
    label_star = form.lbl_75
  }
end
function clear()
  local form = get_form()
  if not nx_is_valid(form) then
    return
  end
  init()
  form.lbl_best_kill = form.groupbox_2:Find("lbl_8")
  form.lbl_best_help_kill = form.lbl_2
  form.lbl_best_damage = form.lbl_2
  for i = 1, #array_ui do
    local ui = array_ui[i]
    clear_label(ui.label)
    show_star(ui.label_star, 4)
  end
  clear_label(form.lbl_ng)
  clear_label(form.lbl_own_skill_1)
  clear_label(form.lbl_own_skill_2)
  clear_label(form.lbl_own_skill_3)
  clear_label(form.lbl_jm_1)
  clear_label(form.lbl_jm_2)
  clear_label(form.lbl_jm_3)
  clear_label(form.lbl_jm_4)
  clear_label(form.lbl_jm_5)
  clear_label(form.lbl_jm_6)
  clear_label(form.lbl_jm_7)
  clear_label(form.lbl_jm_8)
  clear_label(form.lbl_equip)
  clear_label(form.lbl_wuqi)
  clear_label(form.lbl_shangyi)
end
function clear_label(lbl)
  lbl.Text = nx_widestr("")
end
function show_star(lbl, star)
  if nx_int(star) > nx_int(5) then
    star = nx_int(5)
  end
  if nx_int(star) <= nx_int(0) then
    star = nx_int(1)
  end
  lbl.BackImage = nx_string("gui\\language\\ChineseS\\newtvt\\star") .. nx_string(nx_int(star)) .. nx_string(".png")
end
function show_kill(lbl_kill, lbl_star, kill)
  local star = nx_int(kill / 3)
  lbl_kill.Text = nx_widestr(kill)
  show_star(lbl_star, star)
end
function show_help_kill(lbl_help_kill, lbl_star, help_kill)
  local star = nx_int(help_kill / 3)
  lbl_help_kill.Text = nx_widestr(help_kill)
  show_star(lbl_star, star)
end
function show_damage(lbl_damage, lbl_star, damage)
  local star = nx_int(damage / 150000)
  lbl_damage.Text = get_damage(damage)
  show_star(lbl_star, star)
end
function show_kill_combo(lbl, lbl_star, kill_combo)
  local star = nx_int(kill_combo / 3)
  lbl.Text = nx_widestr(kill_combo)
  show_star(lbl_star, star)
end
function show_flag(lbl, lbl_star, flag)
  local star = nx_int(flag / 3)
  lbl.Text = nx_widestr(flag)
  show_star(lbl_star, star)
end
function show_control_skill_count(lbl, lbl_star, count)
  local star = nx_int(count / 6)
  lbl.Text = nx_widestr(count)
  show_star(lbl_star, star)
end
function show_help_skill_count(lbl, lbl_star, count)
  local star = nx_int(count / 3)
  lbl.Text = nx_widestr(count)
  show_star(lbl_star, star)
end
function get_damage(num)
  local damage = nx_int(num)
  if damage >= nx_int(0) and damage < nx_int(10000) then
    return nx_widestr(damage)
  elseif damage == nx_int(10000) then
    return nx_widestr("1") .. util_text("ui_wan")
  elseif damage > nx_int(10000) then
    local wan_num = nx_int(damage / 10000)
    local temp_num = nx_int(math.mod(nx_number(damage), 10000))
    local temp_num2 = nx_int((temp_num + 50) / 100)
    local temp_text = util_text("ui_wan")
    return nx_widestr(wan_num) .. util_text("ui_wan")
  else
    return nx_widestr("")
  end
end
function show_name(id_list_text, prefix, ...)
  local list = util_split_string(id_list_text, nx_widestr(","))
  local n = #list
  for i = 1, #arg do
    local label = arg[i]
    if i > n then
      break
    end
    label.Text = util_format_string(nx_string(prefix) .. list[i])
  end
end
function delete_role_model(scenebox)
  if not nx_is_valid(scenebox) then
    return
  end
  local actor2 = get_actor2(scenebox)
  if nx_is_valid(actor2) then
    scenebox.Scene:Delete(actor2)
  end
  local scene = scenebox.Scene
  if nx_is_valid(scene) then
    if nx_find_custom(scene, "game_effect") and nx_is_valid(scene.game_effect) then
      scene:Delete(scene.game_effect)
    end
    local actor2 = get_actor2(scenebox)
    if nx_is_valid(actor2) then
      scene:Delete(actor2)
    end
  end
  nx_execute("util_gui", "ui_ClearModel", scenebox)
  nx_execute("scene", "delete_scene", scenebox.Scene)
end
function get_actor2(scenebox)
  if not nx_find_custom(scenebox, "actor2") then
    return nil
  end
  return scenebox.actor2
end
function show_skill_action(skill_id, actor2)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
  add_weapon(actor2, skill_id)
  wait_skill_end(actor2, skill_id)
end
function wait_skill_end(actor2, skill_id)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  while nx_is_valid(action) and skill_effect:IsPlayShowZhaoShi(actor2) do
    nx_pause(0)
  end
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  local weapon_name = get_weapon_name(taolu)
  if weapon_name == "" then
    return false
  end
  local weapon_list = util_split_string(weapon_name, ",")
  local count = table.getn(weapon_list)
  local bow, arrow_case = "", ""
  if count == 2 then
    bow = nx_string(weapon_list[1])
    arrow_case = nx_string(weapon_list[2])
    if bow ~= "" and arrow_case ~= "" and bow ~= nil and arrow_case ~= nil and nx_int(ItemType) == nx_int(127) then
      show_bow_n_arrow(true, actor2, bow, arrow_case)
    end
  elseif count == 1 then
    game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  end
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    if nx_is_valid(actor_role) then
      local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
      if nx_is_valid(shot_weapon) then
        shot_weapon.Visible = false
      end
    end
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function show_bow_n_arrow(b_link, actor2, bow, arrow_case)
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local actor_role = game_visual:QueryActRole(actor2)
  if not nx_is_valid(actor_role) then
    return
  end
  if nx_boolean(b_link) then
    nx_set_custom(actor2, "wuxue_book_set", "0h")
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", bow)
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::B_weaponR_01", arrow_case)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    if nx_is_valid(shot_weapon) then
      shot_weapon.Visible = true
    end
    game_visual:SetRoleWeaponName(actor2, bow)
  else
    if nx_find_custom(actor2, "wuxue_book_set") then
      actor2.wuxue_book_set = nil
    else
      nx_set_custom(actor2, "wuxue_book_set", "")
    end
    role_composite:UnLinkWeapon(actor2)
    actor_role:UnLink("ShotWeapon", false)
  end
end
function get_weapon_name(skill_id)
  local ini = get_ini("ini\\ui\\wuxue\\skill_weapon.ini", true)
  if not nx_is_valid(ini) then
    return ""
  end
  local weapon_name = ini:ReadString("weapon_name", skill_id, "")
  return weapon_name
end
function load_scenebox(scenebox)
  nx_execute("util_gui", "ui_ClearModel", scenebox)
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
    local terrain = nx_execute("form_stage_main\\form_advanced_weapon_and_origin", "create_terrain", scenebox.Scene, 1, 4, 100, 100)
    terrain.GroundVisible = false
    local game_effect = nx_create("GameEffect")
    nx_bind_script(game_effect, "game_effect", "game_effect_init", scenebox.Scene)
    scenebox.Scene.game_effect = game_effect
  end
end
function stop_skill_action()
  if nx_running(FORM_NAME, "show_skill_action") then
    nx_kill(FORM_NAME, "show_skill_action")
  end
  if nx_running(FORM_NAME, "wait_skill_end") then
    nx_kill(FORM_NAME, "wait_skill_end")
  end
  if nx_running(FORM_NAME, "show_zhaoshi") then
    nx_kill(FORM_NAME, "show_zhaoshi")
  end
end
function show_zhaoshi(skill_list_text)
  local list = util_split_string(skill_list_text, nx_string(";"))
  local n = #list
  while nx_is_valid(get_form()) do
    nx_pause(0.1)
    local form = get_form()
    if not nx_is_valid(form) then
      break
    end
    local actor2 = get_actor2(form.scenebox_1)
    for i = 1, n do
      local skill_id = list[i]
      show_skill_action(skill_id, actor2)
    end
  end
end
function show_mvp_model(scenebox, ...)
  if not nx_is_valid(scenebox) then
    return
  end
  if nx_is_valid(get_actor2(scenebox)) then
    return
  end
  local n = #arg
  if n < 14 then
    return
  end
  local sex = nx_int(arg[1])
  local show_equip_type = nx_int(arg[2])
  local hat = nx_string(arg[3])
  local cloth = nx_string(arg[4])
  local pants = nx_string(arg[5])
  local face = nx_string(arg[6])
  local shoes = nx_string(arg[7])
  local weapon = nx_string(arg[8])
  local modify_face = nx_string(arg[9])
  local body_type = nx_int(arg[10])
  local body_face = nx_int(arg[11])
  local hair = nx_string(arg[12])
  local work_cloth = nx_string(arg[13])
  local fwz_card_id_list = nx_string(arg[14])
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, scenebox.Scene)
  end
  local actor2 = nx_execute("role_composite", "create_role_composite", scenebox.Scene, false, nx_number(sex))
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if nx_int(body_type) >= nx_int(3) and nx_int(body_type) <= nx_int(6) then
    actor2.sex = sex
    actor2.body_type = body_type
    actor2.body_face = body_face
    role_composite:refresh_body(actor2, true)
  end
  local skin_info = {
    {link_name = "hat", model_name = hair},
    {link_name = "pants", model_name = pants},
    {link_name = "face", model_name = face},
    {link_name = "shoes", model_name = shoes},
    {link_name = "weapon", model_name = weapon},
    {
      link_name = "modify_face",
      model_name = modify_face
    }
  }
  for i = 1, #skin_info do
    local info = skin_info[i]
    if info.model_name ~= nil and string.len(nx_string(info.model_name)) > 0 then
      nx_execute("role_composite", "link_skin", actor2, info.link_name, info.model_name .. ".xmod", false)
    end
  end
  role_composite:link_pet_fashion_cloth(actor2, sex, work_cloth)
  show_fwz(scenebox, actor2, fwz_card_id_list, sex)
  nx_function("ext_set_role_create_finish", actor2, true)
  nx_execute("util_gui", "util_add_model_to_scenebox", scenebox, actor2)
  scenebox.actor2 = actor2
end
function get_skill_id_list(taolu_id_list)
  local result = nx_string("")
  local list = util_split_string(taolu_id_list, nx_string(","))
  local n = #list
  for i = 1, n do
    local taolu_id = list[i]
    local skill_id_list = get_skill_id_list_by_taolu(taolu_id)
    if nx_string(skill_id_list) ~= nx_string("") then
      result = result .. nx_string(";") .. skill_id_list
    end
  end
  return result
end
function get_skill_id_list_by_taolu(taolu_id)
  for i = 1, 3 do
    local skill_id_list = nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose", "get_taolu_prop", taolu_id, nx_int(i), 2)
    if skill_id_list ~= nill and nx_string(skill_id_list) ~= nx_string("") then
      return skill_id_list
    end
  end
  return ""
end
function add_face_effect(scenebox, actor2, card_id, sex)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local BufferEffect = nx_value("BufferEffect")
  if not nx_is_valid(BufferEffect) then
    return
  end
  local buff_id = collect_card_manager:GetFaceEffectIDBySex(card_id, sex)
  if nx_string(buff_id) == nx_string("") then
    return
  end
  local effect_id = BufferEffect:GetBufferEffectInfoByID(buff_id, "effect")
  local game_effect = scenebox.Scene.game_effect
  if game_effect:FindEffect(effect_id, actor2, actor2) then
    return
  end
  game_effect:CreateEffect(nx_string(effect_id), actor2, actor2, "", "", "", "", actor2, true)
end
function show_fwz(scenebox, actor2, fwz_card_id_list, sex)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:link_fwz(actor2, sex, fwz_card_id_list)
  local array_card_id = util_split_string(fwz_card_id_list, nx_string(","))
  for i = 1, #array_card_id do
    local card_id = nx_int(array_card_id[i])
    show_fwz_by_card_id(scenebox, actor2, card_id, sex)
  end
end
function show_fwz_by_card_id(scenebox, actor2, card_id, sex)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  add_face_effect(scenebox, actor2, card_id, sex)
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(card_info_table)
  if length < 13 then
    return
  end
  local card_id = card_info_table[1]
  local main_type = card_info_table[2]
  local level = card_info_table[5]
  local author = card_info_table[6]
  local book = card_info_table[7]
  local config_id = card_info_table[8]
  local condition = card_info_table[9]
  local female_model = card_info_table[10]
  local male_model = card_info_table[11]
  local flag = card_info_table[12]
  local sub_type = card_info_table[13]
  show_decorate(actor2, sex, female_model, male_model)
end
function show_decorate(actor2, sex, female_model, male_model)
  if not nx_is_valid(actor2) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local mode = ""
  if nx_int(sex) == nx_int(1) then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        collect_card_manager:LinkCardDecorate(actor2, prop_value)
      end
    end
  end
end
