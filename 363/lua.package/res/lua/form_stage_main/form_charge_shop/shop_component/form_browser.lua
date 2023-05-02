require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\shop_util")
require("role_composite")
local g_form_name = "form_stage_main\\form_charge_shop\\shop_component\\form_browser"
ORIGIN_EM_BODY_WOMAN_JUV = 3
ORIGIN_EM_BODY_MAN_JUV = 4
ORIGIN_EM_BODY_WOMAN_MAJ = 5
ORIGIN_EM_BODY_MAN_MAJ = 6
local g_face_model = {
  [0] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;",
  [1] = "50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;50;"
}
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  nx_set_custom(form, "show_item", "")
  local g_lbl = {
    form.lbl_select1,
    form.lbl_select2,
    form.lbl_select3,
    form.lbl_select4
  }
  form.ismount = 0
  for i, item in pairs(g_lbl) do
    nx_set_custom(item, "itemid", "")
    nx_set_custom(item, "itemtype", 0)
  end
  form.actor2 = nil
  nx_set_custom(form, "item_num", 0)
  nx_set_custom(form, "select", 0)
  form.hat = ""
  form.cloth = ""
  form.pants = ""
  form.shoes = ""
  local mgr = nx_value("ChargeShop")
  if nx_is_valid(mgr) then
    mgr:RemoveTryItem(0)
  end
end
function on_main_form_close(form)
  remove_role(form.actor2)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function show_try_item(form)
  local g_lbl = {
    form.lbl_select1,
    form.lbl_select2,
    form.lbl_select3,
    form.lbl_select4
  }
  local select = form.select
  if 0 < select and select <= 4 then
    local lbl = g_lbl[select]
    form.lbl_select.BackImage = "xuanzekuang"
    form.lbl_select.Visible = true
    form.lbl_select.Top = lbl.Top
    form.lbl_select.Left = lbl.Left
    form.lbl_select.Width = lbl.Width
    form.lbl_select.Height = lbl.Height
  end
end
function get_select_charge_id()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return -1
  end
  local select = form.select
  local g_lbl = {
    form.lbl_select1,
    form.lbl_select2,
    form.lbl_select3,
    form.lbl_select4
  }
  local lbl = g_lbl[select]
  if lbl == nil then
    return -1
  end
  if not lbl.Visible then
    return -1
  end
  return nx_custom(lbl, "base_index")
end
function add_try_item(form, chargeid)
  local g_lbl = {
    form.lbl_select1,
    form.lbl_select2,
    form.lbl_select3,
    form.lbl_select4
  }
  local ChargeShop = nx_value("ChargeShop")
  if not nx_is_valid(ChargeShop) then
    return
  end
  if not ChargeShop:AddTryItem(chargeid) then
    return
  end
  local items = ChargeShop:GetTryItems()
  local num = table.getn(items)
  if 4 < num then
    num = 4
  end
  for i = 1, num do
    local lbl = g_lbl[i]
    if lbl ~= nil then
      local index = ChargeShop:FindItemBaseIndex(nx_int(items[i]))
      local itemid = ChargeShop:GetConfig(index)
      lbl.itemid = itemid
      nx_set_custom(lbl, "charge_id", items[i])
      nx_set_custom(lbl, "base_index", index)
      lbl.itemtype = get_prop(itemid, "ItemType")
      local photo = item_query_ArtPack_by_id(itemid, "Photo")
      lbl.BackImage = photo
      if chargeid == items[i] then
        form.select = i
        on_try_click(lbl)
      end
    end
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
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local g_lbl_index = {
    lbl_select1 = 1,
    lbl_select2 = 2,
    lbl_select3 = 3,
    lbl_select4 = 4
  }
  local index = g_lbl_index[lbl.Name]
  if index ~= nil then
    lbl.ParentForm.select = index
    show_try_item(lbl.ParentForm)
  end
  local itemtype = nx_custom(lbl, "itemtype")
  local chargeid = nx_custom(lbl, "charge_id")
  if itemtype == 0 then
    return
  end
  local baseindex = mgr:FindItemBaseIndex(nx_int(chargeid))
  local itemid = nx_custom(lbl, "itemid")
  local type = 0
  if is_mount(itemid) then
    type = 1
  end
  show_model(baseindex, type, lbl.ParentForm, false)
end
function on_left_click(btn)
  btn.MouseDown = false
end
function on_left_lost_capture(btn)
  btn.MouseDown = false
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
function on_right_lost_capture(btn)
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
  console_log("create_role_model")
  local query = nx_value("ItemQuery")
  if not nx_is_valid(query) then
    return false
  end
  local itemsex = nx_number(query:GetItemPropByConfigID(equipid, "NeedSex"))
  local item_body_type = nx_number(query:GetItemPropByConfigID(equipid, "BodyType"))
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if equipid == "" then
    itemsex = player:QueryProp("Sex")
    item_body_type = player:QueryProp("BodyType")
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, form.scenebox_1.Scene)
  end
  check_actor2_model(form, player, itemsex, item_body_type)
  local actor2 = form.actor2
  if not nx_is_valid(actor2) then
    remove_role(actor2)
    return false
  end
  while nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    remove_role(actor2)
    return false
  end
  if equipid ~= "" then
    local g_config = {
      [140] = {ArtPack = "Hat"},
      [141] = {
        ArtPack = "Cloth",
        HatArtPack = "Hat",
        PlantsArtPack = "Pants",
        ShoesArtPack = "Shoes"
      },
      [142] = {ArtPack = "Pants"},
      [143] = {ArtPack = "Shoes"},
      [180] = {
        HatArtPack = "Hat",
        PlantsArtPack = "Pants",
        ShoesArtPack = "Shoes",
        ArtPack = "Cloth"
      }
    }
    if not nx_is_valid(query) then
      remove_role(actor2)
      return false
    end
    local itemtype = nx_number(query:GetItemPropByConfigID(equipid, "ItemType"))
    local cfg = g_config[itemtype]
    if cfg == nil then
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
    local role_composite = nx_value("role_composite")
    local sex = form.sex
    local is_mout_equip = false
    local temp_equip_table = {}
    nx_execute("role_composite", "unlink_skin", actor2, "cloth_h")
    for id, prop in pairs(cfg) do
      local art_id = nx_number(get_prop(equipid, id))
      if art_id == 0 then
        local mode_name = string.lower(prop)
        if nx_find_custom(form, mode_name) then
          local mode_prop = nx_custom(form, mode_name)
          if mode_prop ~= nil and 0 < string.len(mode_prop) then
            console_log("1 link = " .. mode_name .. " model=" .. mode_prop)
            nx_execute("role_composite", "unlink_skin", actor2, mode_prop)
            role_composite:LinkSkin(actor2, mode_name, mode_prop, false)
          end
        end
      elseif art_id < 0 then
        local table_prop = {
          shoes = "Shoes",
          cloth = "Cloth",
          pants = "Pants",
          hat = "Hat"
        }
        prop = table_prop[string.lower(prop)]
        role_composite:UnLinkSkin(actor2, prop)
        console_log("2 unlink = " .. prop)
        is_mout_equip = true
      elseif 0 < art_id then
        local art_prop = item_static_query(art_id, model_prop, STATIC_DATA_ITEM_ART)
        if art_prop ~= nil then
          local new_body_type_origin_cloth = false
          if (nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_MAJ)) and nx_number(180) == nx_number(itemtype) and ("Cloth" == prop or "cloth" == prop) then
            new_body_type_origin_cloth = true
          end
          role_composite:LinkSkin(actor2, string.lower(prop), art_prop .. ".xmod", false)
          if new_body_type_origin_cloth then
            role_composite:LinkSkin(actor2, string.lower("cloth_h"), art_prop .. ".xmod", false)
          end
          console_log("3 link = " .. prop)
          prop = string.lower(prop)
          temp_equip_table[prop] = art_prop .. ".xmod"
        end
      end
    end
    if not is_mout_equip then
      for prop, art_prop in pairs(temp_equip_table) do
        console_log("save prop =" .. prop .. " value=" .. art_prop)
        nx_set_custom(form, prop, art_prop)
      end
    end
    if itemtype == 142 then
      console_log("test142")
      role_composite:LinkSkin(actor2, "hat", form.hat, false)
      role_composite:LinkSkin(actor2, "cloth", form.cloth, false)
      role_composite:LinkSkin(actor2, "shoes", form.shoes, false)
    elseif itemtype == 143 then
      console_log("test143")
      role_composite:LinkSkin(actor2, "hat", form.hat, false)
      console_log("4 link prop = cloth  value=" .. form.cloth)
      role_composite:LinkSkin(actor2, "cloth", form.cloth, false)
      console_log("4 link prop = pants  value=" .. form.pants)
      role_composite:LinkSkin(actor2, "pants", form.pants, false)
    end
  end
  return add_actor2_to_scenebox(form, actor2)
end
function add_actor2_to_scenebox(form, actor2)
  if not nx_is_valid(form) then
    remove_role(actor2)
    return false
  end
  local temp_act2 = form.actor2
  if temp_act2 ~= nil and nx_string(temp_act2) ~= nx_string(actor2) then
    remove_role(temp_act2)
  end
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  form.actor2 = actor2
  return true
end
function check_actor2_model(form, player, item_sex, item_body_type)
  if not nx_is_valid(form) or not nx_is_valid(player) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    if item_sex ~= 2 and item_sex ~= form.sex then
      remove_role(actor2)
    end
    if item_body_type ~= form.body_type then
      remove_role(actor2)
    end
  end
  if actor2 ~= nil then
    while nx_call("role_composite", "is_loading", 2, actor2) do
      nx_pause(0)
    end
  end
  if nx_is_valid(actor2) then
    return
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local player_sex = player:QueryProp("Sex")
  local player_body_type = player:QueryProp("BodyType")
  local mode_str = ".xmod"
  local need_new_create = true
  if (item_sex == 2 or item_sex == player_sex) and not body_manager:IsNewBodyType(player) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_WOMAN_JUV) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_MAN_JUV) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_MAN_MAJ) then
    local show_type = player:QueryProp("ShowEquipType")
    if show_type ~= nil and show_type ~= 1 then
      actor2 = role_composite:CreateSceneObjectWithSubModel(form.scenebox_1.Scene, player, false, false, false)
      need_new_create = false
    end
  end
  if body_manager:IsNewBodyType(player) and nx_number(item_body_type) == nx_number(player_body_type) then
    actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nx_number(item_body_type))
    need_new_create = false
    form.actor2 = actor2
    form.sex = item_sex
    form.body_type = item_body_type
    return
  end
  if need_new_create then
    if nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_MAJ) then
      actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nx_number(item_body_type))
      form.actor2 = actor2
      form.sex = item_sex
      form.body_type = item_body_type
      return
    else
      actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nil)
    end
  end
  form.actor2 = actor2
  form.sex = item_sex
  form.body_type = item_body_type
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
      local art = info.model_name .. ".xmod"
      if need_new_create then
        role_composite:LinkSkin(actor2, string.lower(info.link_name), art, false)
      end
      local prop = string.lower(info.link_name)
      if nx_find_custom(form, prop) then
        nx_set_custom(form, prop, art)
      end
    end
  end
  if item_sex == player_sex and item_body_type == player_body_type then
    local is_mount_cloth = false
    local hat_model = player:QueryProp("Hat")
    if 1 < string.len(hat_model) then
      nx_set_custom(form, "hat", hat_model .. mode_str)
    else
      is_mount_cloth = true
    end
    local pants_model = player:QueryProp("Pants")
    if 1 < string.len(pants_model) then
      nx_set_custom(form, "pants", pants_model .. mode_str)
    else
      is_mount_cloth = true
    end
    local shoes_model = player:QueryProp("Shoes")
    if 1 < string.len(shoes_model) then
      nx_set_custom(form, "shoes", shoes_model .. mode_str)
    else
      is_mount_cloth = true
    end
    if not is_mount_cloth then
      console_log("save prop =" .. "cloth" .. " value=" .. player:QueryProp("Cloth") .. mode_str)
      nx_set_custom(form, "cloth", player:QueryProp("Cloth") .. mode_str)
    end
  end
end
function remove_role(actor2)
  if nx_is_valid(actor2) then
    while nx_call("role_composite", "is_loading", 2, actor2) do
      nx_pause(0)
    end
    local world = nx_value("world")
    world:Delete(actor2)
  end
end
function show_mount_model(form, id)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local query = nx_value("ItemQuery")
  if not nx_is_valid(query) then
    return false
  end
  remove_role(form.actor2)
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local world = nx_value("world")
  if nx_is_valid(world) then
    nx_call("scene", "support_physics", world, form.scenebox_1.Scene)
    nx_log("support_physics " .. nx_current())
  else
    nx_log("not support_physics " .. nx_current())
  end
  local actor2 = create_actor2(form.scenebox_1.Scene, "create mount")
  local temp_act2 = form.actor2
  if temp_act2 ~= nil and nx_string(temp_act2) ~= nx_string(actor2) then
    remove_role(temp_act2)
  end
  form.actor2 = actor2
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
    return false
  end
  load_from_ini(actor2, "ini\\" .. file .. ".ini")
  if not nx_is_valid(actor2) then
    return false
  end
  if not nx_is_valid(form) then
    remove_role(actor2)
    return false
  end
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  ui_RotateModel(form.scenebox_1, -1.3)
  form.sex = -1
  return true
end
local show_time_count = 0
function show_model(baseindex, type, shop, bAdd)
  local now = nx_function("ext_get_tickcount")
  console_log("now = " .. nx_string(now) .. " show_time_count=" .. nx_string(show_time_count))
  if now - show_time_count < 200 then
    return
  end
  show_time_count = now
  console_log("show_model")
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  form.btn_give.Visible = false
  form.btn_buy.Visible = false
  form.btn_2.Visible = false
  form.lbl_select.Visible = false
  local act2 = form.actor2
  if act2 ~= nil and is_loading(2, act2) then
    return
  end
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    return
  end
  local id = manager:GetConfig(nx_int(baseindex))
  local chargeid = manager:GetChargeID(nx_int(baseindex))
  local price_type = manager:GetPriceType(nx_int(baseindex))
  local money_type = manager:QueryFilterInfo("money_type")[1]
  if money_type == nil then
    money_type = 0
  end
  if 0 <= baseindex then
    local info = manager:GetSelectItem(baseindex)
    local infos = util_split_string(info, ",")
    form.btn_give.Visible = type ~= -1 and price_type == 0
    form.btn_give.Enabled = item_type ~= 5
    form.btn_buy.Visible = type ~= -1
    form.btn_2.Visible = type == 0
    form.lbl_select.Visible = type == 0
  end
  local radius = 1.8
  if type == 0 then
    form.ismount = 0
    local ret = create_role_model(form, id)
    if not ret then
      return
    end
    form.scenebox_1.Scene.camera:SetPosition(0, radius * 0.46, -radius * 2)
    nx_set_custom(form, "show_item", id)
    nx_set_custom(form, "base_index", baseindex)
  elseif type == 1 then
    form.ismount = 1
    local ret = show_mount_model(form, id)
    if not ret then
      return
    end
    form.scenebox_1.Scene.camera:SetPosition(0, radius * 0.6, -radius * 4.5)
    nx_set_custom(form, "show_item", id)
    nx_set_custom(form, "base_index", baseindex)
  end
  if bAdd and -1 < form.ismount then
    add_try_item(form, chargeid)
  end
end
function on_add_fav_click(btn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local base_index = nx_int(nx_custom(btn.ParentForm, "base_index"))
  local fav_id = format_fav_id(base_index)
  send_server_msg(CLIENT_FAVRATE, fav_id, mgr:GetConfig(base_index))
end
function on_show_fav_click(btn)
  nx_execute(g_filter_form, "filter_favrate")
end
function on_buy_click(btn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local base_index = get_select_charge_id()
  if base_index < 0 then
    return
  end
  local bCanBuy = can_buy_item(base_index)
  if bCanBuy then
    buy_item(base_index)
  else
    util_show_form("form_stage_main\\form_charge_shop\\form_charge_tips", true)
  end
end
function on_give_click(btn)
  local mgr = nx_value("ChargeShop")
  if not nx_is_valid(mgr) then
    return
  end
  local base_index = get_select_charge_id()
  if base_index < 0 then
    return
  end
  local bCanBuy = can_buy_item(base_index)
  if bCanBuy then
    give_item(base_index)
  else
    util_show_form("form_stage_main\\form_charge_shop\\form_charge_tips", true)
  end
end
function on_money_type_changed(money_type)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local base_index = get_select_charge_id()
  reset_browser(form)
end
function reset_browser(form)
  local g_lbl = {
    form.lbl_select1,
    form.lbl_select2,
    form.lbl_select3,
    form.lbl_select4
  }
  for i, item in pairs(g_lbl) do
  end
  if form.actor2 == nil or not nx_is_valid(form.actor2) then
    show_model(-1, 0, nx_value(g_shop_form), false)
  end
end
