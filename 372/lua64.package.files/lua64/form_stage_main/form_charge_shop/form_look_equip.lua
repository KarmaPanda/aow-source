require("role_composite")
require("util_functions")
require("util_gui")
require("utils")
require("util_static_data")
require("share\\chat_define")
local g_form_name = "form_stage_main\\form_charge_shop\\form_look_equip"
local g_shop_name = "form_stage_main\\form_charge_shop\\form_charge_shop"
local g_face_model = {
  [0] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;",
  [1] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;"
}
function on_main_form_init(form)
  form.Fixed = false
  form.actor2 = nil
  form.sex = 0
  nx_set_value("form_stage_main\\form_charge_shop\\form_look_equip", form)
end
function on_main_form_open(form)
  local g_lbl = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4
  }
  form.ismount = 0
  for i, item in pairs(g_lbl) do
    item.BackImage = "gui\\common\\imagegrid_new\\icn_2.png"
    nx_set_custom(item, "itemid", "")
    nx_set_custom(item, "itemtype", 0)
  end
  form.lbl_select.Visible = false
  nx_set_custom(form, "item_num", 0)
  nx_set_custom(form, "select", 0)
end
function on_main_form_close(form)
  remove_role(form.actor2)
  nx_destroy(form)
end
function on_close_form(btn)
  local form = btn.ParentForm
  remove_role(form.actor2)
  form:Close()
  return 1
end
function on_left_click(btn)
  btn.MouseDown = false
end
function show_try_item(form)
  local g_lbl = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4
  }
  for i, item in pairs(g_lbl) do
    local itemid = item.itemid
    if nx_string(itemid) ~= "" then
      local photo = item_query_ArtPack_by_id(itemid, "Photo")
      item.BackImage = photo
    end
  end
  local select = form.select
  local num = form.item_num
  if 0 < select and select <= num then
    local lbl = g_lbl[select]
    form.lbl_select.Visible = true
    form.lbl_select.Top = lbl.Top
    form.lbl_select.Left = lbl.Left
  end
end
function add_try_item(form, itemid)
  local g_lbl = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4
  }
  local num = form.item_num
  local lbl = g_lbl[num]
  if lbl ~= nil and nx_string(itemid) == lbl.itemid then
    return
  end
  if num < 4 then
    local lbl = g_lbl[num + 1]
    if lbl ~= nil then
      lbl.itemid = itemid
      lbl.itemtype = nx_execute(g_shop_name, "get_prop", itemid, "ItemType")
      form.item_num = num + 1
      form.select = num + 1
    end
  else
    for i = 1, num - 1 do
      local lbl, next_lbl = g_lbl[i], g_lbl[i + 1]
      if lbl ~= nil and next_lbl ~= nil then
        lbl.itemid = next_lbl.itemid
        lbl.itemtype = next_lbl.itemtype
      end
    end
    local lbl = g_lbl[num]
    lbl.itemid = itemid
    lbl.itemtype = nx_execute(g_shop_name, "get_prop", itemid, "ItemType")
    form.select = num
  end
  show_try_item(form)
end
function on_get_capture(lbl)
  local itemtype = nx_custom(lbl, "itemtype")
  if itemtype == 0 then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local itemid = nx_custom(lbl, "itemid")
  nx_execute("tips_game", "show_tips_common", itemid, nx_number(itemtype), x, y, lbl.ParentForm)
end
function on_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_try_click(lbl)
  local g_lbl_index = {
    lbl_1 = 1,
    lbl_2 = 2,
    lbl_3 = 3,
    lbl_4 = 4
  }
  local index = g_lbl_index[lbl.Name]
  if index ~= nil then
    lbl.ParentForm.select = index
    show_try_item(lbl.ParentForm)
  end
  local itemtype = nx_custom(lbl, "itemtype")
  if itemtype == 0 then
    return
  end
  local itemid = nx_custom(lbl, "itemid")
  show_model(itemid, 0, lbl.ParentForm)
end
function on_left_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  if not nx_is_valid(form.actor2) then
    return
  end
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    ui_RotateModel(form.scenebox_1, dist)
  end
end
function on_right_click(btn)
  btn.MouseDown = false
end
function on_right_push(btn)
  btn.MouseDown = true
  local form = btn.Parent
  if not nx_is_valid(form.actor2) then
    return
  end
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    ui_RotateModel(form.scenebox_1, dist)
  end
end
function create_role_model(form, equipid)
  local query = nx_value("ItemQuery")
  if not nx_is_valid(query) then
    return
  end
  local itemsex = nx_number(query:GetItemPropByConfigID(equipid, "NeedSex"))
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, form.scenebox_1.Scene)
  end
  check_actor2_model(form, player, itemsex)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    return
  end
  while nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  local itemtype = nx_number(query:GetItemPropByConfigID(equipid, "ItemType"))
  local g_item_type_link = {
    [140] = "hat",
    [141] = "cloth",
    [142] = "pants",
    [143] = "shoes"
  }
  local link = g_item_type_link[itemtype]
  if link == nil or link == "" then
    return add_actor2_to_scenebox(form, actor2)
  end
  local g_model_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local model_prop = g_model_prop[form.sex]
  if model_prop == nil or model_prop == "" then
    return add_actor2_to_scenebox(form, actor2)
  end
  local model = get_weaponmode_path_by_name(equipid, model_prop)
  if model == nil or model == "" then
    return add_actor2_to_scenebox(form, actor2)
  end
  local role_composite = nx_value("role_composite")
  unlink_skin(actor2, link)
  if link == "Cloth" or link == "cloth" then
    unlink_skin(actor2, "pants")
    link_cloth_skin(role_composite, actor2, model)
  else
    role_composite:LinkSkin(actor2, link, model .. ".xmod", false)
  end
  return add_actor2_to_scenebox(form, actor2)
end
function add_actor2_to_scenebox(form, actor2)
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  local temp_act2 = form.actor2
  if nx_is_valid(temp_act2) then
  end
  form.actor2 = actor2
end
function check_actor2_model(form, player, item_sex)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) and item_sex ~= 2 and item_sex ~= form.sex then
    remove_role(actor2)
  end
  if nx_is_valid(actor2) then
    return
  end
  local player_sex = player:QueryProp("Sex")
  if item_sex == 2 or item_sex == player_sex then
    local show_type = player:QueryProp("ShowEquipType")
    if show_type ~= nil and show_type ~= 1 then
      actor2 = create_scene_obj_composite(form.scenebox_1.Scene, player, false)
      form.sex = player_sex
      form.actor2 = actor2
      return
    end
  end
  actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex)
  form.sex = item_sex
  local g_hat_model = {
    [0] = "obj\\char\\b_hair\\b_hair1",
    [1] = "obj\\char\\g_hair\\g_hair1"
  }
  local g_face_model = {
    [0] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;",
    [1] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;"
  }
  local g_cloth_model = {
    [0] = "cloth_b0001",
    [1] = "cloth_g0001"
  }
  local g_pants_model = {
    [0] = "pants_b0001",
    [1] = "pants_g0001"
  }
  local g_shoes_model = {
    [0] = "shoes_b0001",
    [1] = "shoes_g0001"
  }
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local fm = g_face_model[item_sex]
  local im = ""
  local hm = g_hat_model[item_sex]
  local cm = get_weaponmode_path_by_name(g_cloth_model[item_sex], g_sex_prop[item_sex])
  local pm = get_weaponmode_path_by_name(g_pants_model[item_sex], g_sex_prop[item_sex])
  local sm = get_weaponmode_path_by_name(g_shoes_model[item_sex], g_sex_prop[item_sex])
  local skin_info = {
    [1] = {link_name = "face", model_name = fm},
    [2] = {link_name = "impress", model_name = im},
    [3] = {link_name = "hat", model_name = hm},
    [4] = {link_name = "cloth", model_name = cm},
    [5] = {link_name = "pants", model_name = pm},
    [6] = {link_name = "shoes", model_name = sm}
  }
  for i, info in pairs(skin_info) do
    if info.model_name ~= nil then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  form.actor2 = actor2
end
function remove_role(actor2)
  if nx_is_valid(actor2) then
    local world = nx_value("world")
    world:Delete(actor2)
  end
end
function show_mount_model(form, id)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local query = nx_value("ItemQuery")
  if not nx_is_valid(query) then
    return
  end
  remove_role(form.actor2)
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local actor2 = create_actor2(form.scenebox_1.Scene, "create mount")
  local g_sex_prop = {
    [0] = "MaleModel",
    [1] = "FemaleModel"
  }
  local prop_name = g_sex_prop[player:QueryProp("Sex")]
  if prop_name == nil then
    prop_name = g_sex_prop[0]
  end
  local file = item_query_ArtPack_by_id(nx_string(id), nx_string(prop_name))
  if file == nil or file == "" then
    remove_role(actor2)
    return
  end
  load_from_ini(actor2, "ini\\" .. file .. ".ini")
  if not nx_is_valid(actor2) then
    return
  end
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  ui_RotateModel(form.scenebox_1, -1.3)
  form.actor2 = actor2
  form.sex = -1
end
function show_model(id, type, shop, bAdd)
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_charge_shop\\form_look_equip", true)
  local form = nx_value("form_stage_main\\form_charge_shop\\form_look_equip")
  if not nx_is_valid(form) then
    return
  end
  local radius = 1.8
  if type == 0 then
    form.ismount = 0
    create_role_model(form, id)
    form.scenebox_1.Scene.camera:SetPosition(0, radius * 0.46, -radius * 2)
  elseif type == 1 then
    form.ismount = 1
    show_mount_model(form, id)
    form.scenebox_1.Scene.camera:SetPosition(0, radius * 0.6, -radius * 4.5)
  end
  if bAdd and form.ismount == 0 then
    add_try_item(form, id)
  end
end
function sysinfo(sInfo, ...)
  info = util_format_string(sInfo, unpack(arg))
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
  end
end
