require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("tips_data")
local image_lable = "\\gui\\special\\card\\"
local inmage_path = "gui\\language\\ChineseS\\card\\"
local inmage_backgroud = "gui\\language\\ChineseS\\card\\0.png"
local FORM_CARD = "form_stage_main\\form_card\\form_card"
local CARD_FILL_PATH = "share\\Rule\\card.ini"
local CARD_FILL_STATIC_INFO_PATH = "share\\Item\\ItemArtStatic.ini"
local FORM_EXCHANGE = "form_stage_main\\form_card\\form_card_replace"
local CARD_MAIN_TYPE_WEAPON = 1
local CARD_MAIN_TYPE_EQUIP = 2
local CARD_MAIN_TYPE_HORSE = 3
local CARD_MAIN_TYPE_OTHENR = 4
local CARD_MAIN_TYPE_DECORATE = 5
local CLIENT_CUSTOMMSG_CARD = 180
local CLIENT_CUSTOMMSG_CARD_REPLACE = 5
local card_id_table = {}
local replace_id_table = {}
local choose_id_table = {}
local config_cloth_table = {}
function main_form_init(form)
  form.Fixed = false
  form.key_card_id = 0
  form.old_card_id = 0
  form.new_card_id = 0
  form.actor2 = nil
  form.refresh_time = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  load_card_list(form)
  show_role_model(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_main_form_shut(form)
  if nx_is_valid(form.role_box) then
    if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
      form.role_box.Scene:Delete(form.actor2)
    end
    nx_execute("scene", "delete_scene", form.role_box.Scene)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function open_form()
  local form = nx_value(FORM_EXCHANGE)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_show_form(FORM_EXCHANGE, true)
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
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
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
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function on_cmb_card1_selected(self)
  local form = self.ParentForm
  local index = form.cmb_card1.DropListBox.SelectIndex
  local length = table.getn(card_id_table)
  if nx_int(index) >= nx_int(length) then
    return
  end
  local card_id = card_id_table[index + 1]
  form.key_card_id = card_id
  form.old_card_id = 0
  form.new_card_id = 0
  local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
  form.lbl_card1.BackImage = photo
  load_card2_list(form, card_id)
end
function on_cmb_card2_selected(self)
  local form = self.ParentForm
  local index = form.cmb_card2.DropListBox.SelectIndex
  local length = table.getn(replace_id_table)
  if nx_int(index) >= nx_int(length) then
    return
  end
  local card_id = replace_id_table[index + 1]
  form.old_card_id = card_id
  form.new_card_id = 0
  local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
  form.lbl_card1.BackImage = photo
  load_card3_list(form)
  priview_mode(form, card_id)
end
function on_cmb_card3_selected(self)
  local form = self.ParentForm
  local index = form.cmb_card3.DropListBox.SelectIndex
  local length = table.getn(choose_id_table)
  if nx_int(index) >= nx_int(length) then
    return
  end
  local card_id = choose_id_table[index + 1]
  form.new_card_id = card_id
  local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
  form.lbl_card2.BackImage = photo
  priview_mode(form, card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetReplaceItemNeedNumber(form.new_card_id)
  local length = table.getn(card_info_table)
  if length < 1 then
    return
  end
  form.lbl_number.Text = nx_widestr(card_info_table[1])
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if form.old_card_id == 0 or form.new_card_id == 0 then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_card_exchangeok", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_REPLACE), nx_int(form.key_card_id), nx_int(form.old_card_id), nx_int(form.new_card_id))
  end
end
function load_card_list(form)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  card_id_table = collect_card_manager:GetReplaceList()
  local length = table.getn(card_id_table)
  if length == 0 then
    return
  end
  form.cmb_card1.DropListBox:ClearString()
  for i = 1, length do
    local card_id = card_id_table[i]
    local card_name = util_text("card_item_" .. nx_string(card_id))
    form.cmb_card1.DropListBox:AddString(nx_widestr(card_name))
    form.cmb_card1.DropListBox.SelectIndex = 0
  end
  form.cmb_card1.Text = nx_widestr("")
end
function load_card2_list(form, choose_card_id)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  replace_id_table = {}
  replace_id_table = collect_card_manager:GetReplaceListByID(choose_card_id)
  local length = table.getn(replace_id_table)
  if length == 0 then
    return
  end
  local card_id = replace_id_table[1]
  local card_name = util_text("card_item_" .. nx_string(card_id))
  form.lbl_name.Text = nx_widestr(card_name)
  form.old_card_id = card_id
  form.new_card_id = 0
  local photo = nx_resource_path() .. inmage_path .. nx_string(card_id) .. ".png"
  form.lbl_card1.BackImage = photo
  load_card3_list(form)
  priview_mode(form, card_id)
end
function load_card3_list(form)
  local length = table.getn(replace_id_table)
  if length == 0 then
    return
  end
  choose_id_table = {}
  local index = 0
  form.cmb_card3.DropListBox:ClearString()
  for i = 1, length do
    if i ~= index + 1 then
      local card_id = replace_id_table[i]
      local card_name = util_text("card_item_" .. nx_string(card_id))
      form.cmb_card3.DropListBox:AddString(nx_widestr(card_name))
      form.cmb_card3.DropListBox.SelectIndex = 0
      table.insert(choose_id_table, card_id)
    end
  end
  form.cmb_card3.Text = nx_widestr("")
end
function show_role_model(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local game_effect = nx_create("GameEffect")
  nx_bind_script(game_effect, "game_effect", "game_effect_init", form.role_box.Scene)
  form.role_box.Scene.game_effect = game_effect
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    form.role_box.Scene:Delete(actor2)
  end
  local client_player = game_client:GetPlayer()
  local sex = client_player:QueryProp("Sex")
  local body_type = client_player:QueryProp("BodyType")
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local actor2
  if body_type == 3 or body_type == 4 or body_type == 5 or body_type == 6 then
    actor2 = create_role_composite(form.role_box.Scene, false, sex, "stand", body_type)
    role_composite:RefreshBodyNorEquip(client_player, actor2, 0)
  else
    actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  end
  if not nx_is_valid(actor2) then
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  form.actor2 = actor2
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  local scene = form.role_box.Scene
  local radius = 1.5
  scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
end
function priview_mode(form, card_id)
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.refresh_time < 1000 then
    return 0
  end
  form.refresh_time = new_time
  local gui = nx_value("gui")
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local card_info_table = {}
  card_info_table = collect_card_manager:GetCardInfo(card_id)
  local length = table.getn(card_info_table)
  if length < 0 then
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
  if main_type == CARD_MAIN_TYPE_WEAPON then
    show_weapon(form, config_id, card_id)
  elseif main_type == CARD_MAIN_TYPE_EQUIP then
    show_cloth(form, female_model, male_model)
  elseif main_type == CARD_MAIN_TYPE_HORSE then
    show_mount(form, female_model, male_model)
  end
end
function show_cloth(form, female_model, male_model)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local action_module = nx_value("action_module")
  action_module:BlendAction(actor2, "stand", true, true)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  local sex = actor:QueryProp("Sex")
  local show_equip_type = actor:QueryProp("ShowEquipType")
  if nx_int(show_equip_type) ~= nx_int(0) then
    change_jianghu_cloth(actor2, sex)
  end
  local mode = ""
  if sex == 1 then
    model = female_model
  else
    model = male_model
  end
  local model_table = util_split_string(model, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  config_cloth_table = {}
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        local prop_name = base_table[1]
        local prop_value = base_table[2]
        if prop_name == "Hat" then
          nx_execute("role_composite", "unlink_skin", actor2, "Hat")
        elseif prop_name == "Shoes" then
          nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
        elseif prop_name == "Cloth" then
          nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
        elseif prop_name == "Pants" then
          nx_execute("role_composite", "unlink_skin", actor2, "Pants")
        end
        table.insert(config_cloth_table, {prop_name})
        reshresh_cloth(actor2, prop_name, prop_value)
      end
    end
  end
  reshresh_no_con_cloth(form)
  local scene = form.role_box.Scene
  local radius = 1.5
  local dist = 0
  scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function reshresh_cloth(actor2, prop_name, prop_value)
  if not nx_is_valid(actor2) then
    return
  end
  if string.len(prop_name) <= 0 or string.len(prop_value) <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  if prop_name == "Hat" then
    nx_execute("role_composite", "link_skin", actor2, "hat", prop_value .. ".xmod")
  elseif prop_name == "Cloth" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", prop_value .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", prop_value .. "_h" .. ".xmod")
  elseif prop_name == "Shoes" then
    nx_execute("role_composite", "link_skin", actor2, "shoes", prop_value .. ".xmod")
  elseif prop_name == "Pants" then
    nx_execute("role_composite", "link_skin", actor2, "pants", prop_value .. ".xmod")
  end
end
function reshresh_no_con_cloth(form)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local prop_value = ""
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local is_in = is_in_config_cloth_table("Hat")
  if is_in == false then
    nx_execute("role_composite", "unlink_skin", actor2, "Hat")
    prop_value = client_player:QueryProp("Hair")
    reshresh_cloth(actor2, "Hat", prop_value)
  end
end
function is_in_config_cloth_table(prop_name)
  local is_in = false
  if config_cloth_table == nil then
    return false
  end
  local len = table.getn(config_cloth_table)
  if nx_int(len) == nx_int(0) then
    return false
  end
  for i = 1, len do
    local name = config_cloth_table[i][1]
    if nx_string(name) == nx_string(prop_name) then
      return true
    end
  end
  return false
end
function show_weapon(form, weapon, card_id)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local action_module = nx_value("action_module")
  action_module:ClearState(actor2)
  role_composite:DeleteRideBase(actor2)
  actor2.card_id = card_id
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local temp_table = {}
  temp_table = collect_card_manager:GetCardInfo(card_id)
  if temp_table == nil then
    return
  end
  local length = table.getn(temp_table)
  if nx_int(length) < nx_int(max_info_count) then
    return
  end
  local main_type = temp_table[2]
  local sub_type = temp_table[3]
  role_composite:RefreshCustomWeaponFormArtPack(actor2, weapon)
  if main_type == 1 and sub_type == 6 then
    local scene = form.role_box.Scene
    local radius = 1.8
    local dist = -0
    scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  else
    local scene = form.role_box.Scene
    local radius = 1.5
    local dist = -0
    scene.camera:SetPosition(-0.2, radius * 0.6, -radius * 2.5)
    nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
  end
end
function show_mount(form, female_model, male_model)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  role_composite:DeleteRideBase(actor2)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  if not nx_is_valid(actor) then
    return
  end
  local sex = actor:QueryProp("Sex")
  local mount = ""
  local mode = ""
  if sex == 0 then
    mount = female_model
  else
    mount = male_model
  end
  local model_name = ""
  local model_table = util_split_string(mount, ";")
  local count = table.getn(model_table)
  if count == 0 then
    return
  end
  for i = 1, count do
    local base_table = util_split_string(model_table[i], ":")
    if base_table ~= nil then
      local base_count = table.getn(base_table)
      if base_count == 2 then
        model_name = base_table[2]
        break
      end
    end
  end
  if 0 >= string.len(model_name) then
    return
  end
  if 0 < string.len(mount) then
    local role_composite = nx_value("role_composite")
    if not nx_is_valid(role_composite) then
      return
    end
    role_composite:CreateRideBase(actor2, model_name)
  end
  local action_module = nx_value("action_module")
  action_module:ClearState(actor2)
  action_module:BlendAction(actor2, "ride_stand", true, true)
  local scene = form.role_box.Scene
  local radius = 2.75
  local dist = 0
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.5)
  nx_execute("util_gui", "ui_RotateModel", form.role_box, dist)
end
function change_jianghu_cloth(actor2, sex)
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local jh_table = {}
  jh_table = collect_card_manager:GetClothModeList()
  local length = table.getn(jh_table)
  if length < 4 then
    return
  end
  local hat = jh_table[1]
  local cloth = jh_table[2]
  local pants = jh_table[3]
  local shoes = jh_table[4]
  nx_execute("role_composite", "unlink_skin", actor2, "Shoes")
  nx_execute("role_composite", "unlink_skin", actor2, "Cloth")
  nx_execute("role_composite", "unlink_skin", actor2, "Pants")
  local def_hat, def_cloth, def_pants, def_shoes = "", "", "", ""
  if nx_int(sex) == nx_int(0) then
    def_cloth = "obj\\char\\b_jianghu000\\b_cloth000"
    def_pants = "obj\\char\\b_jianghu000\\b_pants000"
    def_shoes = "obj\\char\\b_jianghu000\\b_shoes000"
  else
    def_cloth = "obj\\char\\g_jianghu000\\g_cloth000"
    def_pants = "obj\\char\\g_jianghu000\\g_pants000"
    def_shoes = "obj\\char\\g_jianghu000\\g_shoes000"
  end
  if string.len(cloth) == 0 then
    reshresh_cloth(actor2, "Cloth", def_cloth)
  else
    reshresh_cloth(actor2, "Cloth", cloth)
  end
  if string.len(pants) == 0 then
    reshresh_cloth(actor2, "Pants", def_cloth)
  else
    reshresh_cloth(actor2, "Pants", pants)
  end
  if string.len(shoes) == 0 then
    reshresh_cloth(actor2, "Shoes", def_pants)
  else
    reshresh_cloth(actor2, "Shoes", shoes)
  end
end
function reshresh_cloth(actor2, prop_name, prop_value)
  if not nx_is_valid(actor2) then
    return
  end
  if string.len(prop_name) <= 0 or string.len(prop_value) <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_ident = game_visual:QueryRoleClientIdent(actor2)
  local actor = game_client:GetSceneObj(nx_string(client_ident))
  if prop_name == "Hat" then
    nx_execute("role_composite", "link_skin", actor2, "hat", prop_value .. ".xmod")
  elseif prop_name == "Cloth" then
    nx_execute("role_composite", "link_skin", actor2, "cloth", prop_value .. ".xmod")
    nx_execute("role_composite", "link_skin", actor2, "cloth_h", prop_value .. "_h" .. ".xmod")
  elseif prop_name == "Shoes" then
    nx_execute("role_composite", "link_skin", actor2, "shoes", prop_value .. ".xmod")
  elseif prop_name == "Pants" then
    nx_execute("role_composite", "link_skin", actor2, "pants", prop_value .. ".xmod")
  end
end
