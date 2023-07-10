require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\shop_util")
require("role_composite")
ORIGIN_EM_BODY_WOMAN_JUV = 3
ORIGIN_EM_BODY_MAN_JUV = 4
ORIGIN_EM_BODY_WOMAN_MAJ = 5
ORIGIN_EM_BODY_MAN_MAJ = 6
function on_main_form_init(form)
  form.Fixed = false
  form.itemtype = 1
  form.sextype = 2
  form.max_pageno = 0
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  init_rbtn_type(form)
  form.btn_19.MouseDown = false
  form.btn_20.MouseDown = false
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddRolePropertyBind("MarryScore", "int", form, nx_current(), "show_marry_score")
  form.actor2 = nil
  show_marry_score(form)
  local ctrl = {
    [1] = form.ImageControlGrid1,
    [2] = form.ImageControlGrid2,
    [3] = form.ImageControlGrid3,
    [4] = form.ImageControlGrid4,
    [5] = form.ImageControlGrid5,
    [6] = form.ImageControlGrid6,
    [7] = form.ImageControlGrid7,
    [8] = form.ImageControlGrid8,
    [9] = form.ImageControlGrid9
  }
  for i = 1, 9 do
    local imagegrid = ctrl[i]
    nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
  end
  nx_execute("form_stage_main\\form_marry\\form_qingyuanpu", "show_model", "", form)
end
function show_marry_score(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local MarryScore = client_player:QueryProp("MarryScore")
  form.lbl_1.Text = util_format_string("ui_marry_zhufuzhi") .. nx_widestr(nx_string(MarryScore))
end
function on_main_form_close(form)
  nx_destroy(form)
end
function init_rbtn_type(form)
  form.rbtn_1.type = 1
  form.rbtn_2.type = 2
  form.rbtn_3.type = 3
  form.rbtn_4.type = 4
  form.rbtn_5.type = 5
  form.rbtn_6.type = 6
  form.rbtn_7.type = 2
  form.rbtn_8.type = 0
  form.rbtn_9.type = 1
  form.rbtn_1.Checked = true
  form.rbtn_7.Checked = true
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_itemtype_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked == true then
    form.itemtype = rbtn.type
    form.ipt_1.Text = nx_widestr(1)
    show_max_pageno(form)
    form.groupbox_2.Visible = rbtn.type == 1
    show_item(form)
  end
end
function on_rbtn_sextype_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked == true then
    form.sextype = rbtn.type
    form.ipt_1.Text = nx_widestr(1)
    show_max_pageno(form)
    show_item(form)
  end
end
function on_btn_duihuan_click(btn)
  if btn.itemid ~= "" then
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_marry_shop_exchange_confirm")
    gui.TextManager:Format_AddParam(nx_int(btn.score))
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(btn.itemid))
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_msg_marryshop", nx_int(0), btn.itemid)
    end
  end
end
function on_btn_gift_click(btn)
  if btn.itemid ~= "" then
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_marry_shop_present_confirm")
    gui.TextManager:Format_AddParam(nx_int(btn.score))
    gui.TextManager:Format_AddParam(gui.TextManager:GetText(btn.itemid))
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_msg_marryshop", nx_int(1), btn.itemid)
    end
  end
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local pageno = nx_int(form.ipt_1.Text)
  if pageno > nx_int(1) then
    pageno = pageno - 1
    form.ipt_1.Text = nx_widestr(pageno)
    show_item(form)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  local pageno = nx_int(form.ipt_1.Text)
  if nx_int(form.max_pageno) > nx_int(pageno) then
    pageno = pageno + 1
    form.ipt_1.Text = nx_widestr(pageno)
    show_item(form)
  end
end
function on_btn_jump_click(btn)
  local form = btn.ParentForm
  local page_no = nx_int(form.ipt_1.Text)
  if nx_int(page_no) <= nx_int(form.max_pageno) then
    show_item(form)
  end
end
function show_max_pageno(form)
  if not nx_is_valid(form) then
    return
  end
  local MarryShop = nx_value("MarryShop")
  if not nx_is_valid(MarryShop) then
    return
  end
  local item_list = MarryShop:GetItemsInfo(form.itemtype, form.sextype)
  local len = table.getn(item_list)
  if 0 < len then
    local max_pageno = nx_int((nx_int(len / 2) - 1) / 9) + 1
    form.max_pageno = max_pageno
  else
    form.max_pageno = 0
  end
  form.lbl_page.Text = nx_widestr("/") .. nx_widestr(form.max_pageno)
  form.ipt_1.MaxDigit = nx_int(form.max_pageno)
end
function show_item(form)
  local ctrl = {
    [1] = {
      [1] = form.ImageControlGrid1,
      [2] = form.mltbox_1,
      [3] = form.btn_1,
      [4] = form.btn_2,
      [5] = form.groupbox_4,
      [6] = form.lbl_5
    },
    [2] = {
      [1] = form.ImageControlGrid2,
      [2] = form.mltbox_2,
      [3] = form.btn_3,
      [4] = form.btn_4,
      [5] = form.groupbox_5,
      [6] = form.lbl_6
    },
    [3] = {
      [1] = form.ImageControlGrid3,
      [2] = form.mltbox_3,
      [3] = form.btn_5,
      [4] = form.btn_6,
      [5] = form.groupbox_6,
      [6] = form.lbl_7
    },
    [4] = {
      [1] = form.ImageControlGrid4,
      [2] = form.mltbox_4,
      [3] = form.btn_7,
      [4] = form.btn_8,
      [5] = form.groupbox_7,
      [6] = form.lbl_8
    },
    [5] = {
      [1] = form.ImageControlGrid5,
      [2] = form.mltbox_5,
      [3] = form.btn_9,
      [4] = form.btn_10,
      [5] = form.groupbox_8,
      [6] = form.lbl_9
    },
    [6] = {
      [1] = form.ImageControlGrid6,
      [2] = form.mltbox_6,
      [3] = form.btn_11,
      [4] = form.btn_12,
      [5] = form.groupbox_9,
      [6] = form.lbl_10
    },
    [7] = {
      [1] = form.ImageControlGrid7,
      [2] = form.mltbox_7,
      [3] = form.btn_13,
      [4] = form.btn_14,
      [5] = form.groupbox_10,
      [6] = form.lbl_11
    },
    [8] = {
      [1] = form.ImageControlGrid8,
      [2] = form.mltbox_8,
      [3] = form.btn_15,
      [4] = form.btn_16,
      [5] = form.groupbox_11,
      [6] = form.lbl_12
    },
    [9] = {
      [1] = form.ImageControlGrid9,
      [2] = form.mltbox_9,
      [3] = form.btn_17,
      [4] = form.btn_18,
      [5] = form.groupbox_12,
      [6] = form.lbl_13
    }
  }
  local MarryShop = nx_value("MarryShop")
  if not nx_is_valid(MarryShop) then
    return
  end
  local item_list = MarryShop:GetItemsInfo(form.itemtype, form.sextype)
  local max_len = table.getn(item_list)
  for i = 1, 9 do
    local imagegrid = ctrl[i][1]
    clear_imagegrid(imagegrid)
    imagegrid:SetSelectItemIndex(-1)
    local mltbox = ctrl[i][2]
    mltbox:Clear()
    ctrl[i][3].itemid = ""
    ctrl[i][4].itemid = ""
    ctrl[i][5].Visible = false
    ctrl[i][6].Text = nx_widestr("")
    local pageno = nx_int(form.ipt_1.Text)
    if nx_int((pageno - 1) * 9 * 2 + i * 2) <= nx_int(max_len) then
      local pos = (pageno - 1) * 9 * 2 + (i - 1) * 2
      local itemid = item_list[pos + 1]
      local score = item_list[pos + 2]
      if itemid ~= nil and itemid ~= "" then
        init_imagegrid(imagegrid, itemid .. "/" .. "1")
        ctrl[i][5].Visible = true
        ctrl[i][6].Text = util_text(itemid)
        local zhufu = util_text("ui_marry_zhufuzhi") .. nx_widestr(score)
        local time = nx_execute("form_stage_main\\form_charge_shop\\shop_util", "get_prop", itemid, "ValidTime")
        local wtime = util_format_string("ui_shop_item_time", time)
        local wstr = nx_widestr("") .. nx_widestr("<br>") .. nx_widestr("<br>") .. zhufu
        if time ~= nil then
          wstr = wstr .. nx_widestr("<br>") .. wtime
        else
          wstr = wstr .. nx_widestr("<br>") .. util_format_string("ui_marry_shop_time")
        end
        mltbox:Clear()
        mltbox:AddHtmlText(wstr, nx_int(0))
        ctrl[i][3].itemid = itemid
        ctrl[i][3].score = score
        ctrl[i][4].itemid = itemid
        ctrl[i][4].score = score
      end
    end
  end
end
function clear_imagegrid(imagegrid)
  imagegrid:DelItem(0)
  imagegrid.item_id = nil
  imagegrid.item_type = nil
  imagegrid.item_count = 0
end
function init_imagegrid(imagegrid, item_info)
  local tab = util_split_string(item_info, "/")
  if table.getn(tab) ~= 2 then
    nx_log("Error form_act_grouppurchase   init_imagegrid")
    nx_log("item_info = " .. nx_string(item_info))
    return
  end
  item_id = tab[1]
  item_count = tab[2]
  imagegrid.item_id = tab[1]
  imagegrid.item_count = tab[2]
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_id, "Photo")
  imagegrid:AddItem(0, nx_string(photo), nx_widestr(item_id), nx_int(item_count), 0)
  local ItemQuery = nx_value("ItemQuery")
  local item_type = ItemQuery:GetItemPropByConfigID(item_id, "ItemType")
  imagegrid.item_type = item_type
  nx_bind_script(imagegrid, nx_current())
  nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
  nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
end
function on_imagegrid_mousein_grid(imagegrid)
  if imagegrid.item_id == nil then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_common", imagegrid.item_id, nx_number(imagegrid.item_type), x, y, imagegrid.ParentForm)
end
function on_imagegrid_mouseout_grid(imagegrid)
  if imagegrid.item_id == nil then
    return
  end
  nx_execute("tips_game", "hide_tip", imagegrid.ParentForm)
end
function on_imagegrid_select_changed(imagegrid)
  local form = imagegrid.ParentForm
  local ctrl = {
    [1] = form.ImageControlGrid1,
    [2] = form.ImageControlGrid2,
    [3] = form.ImageControlGrid3,
    [4] = form.ImageControlGrid4,
    [5] = form.ImageControlGrid5,
    [6] = form.ImageControlGrid6,
    [7] = form.ImageControlGrid7,
    [8] = form.ImageControlGrid8,
    [9] = form.ImageControlGrid9
  }
  for i = 1, 9 do
    ctrl[i]:SetSelectItemIndex(-1)
  end
  imagegrid:SetSelectItemIndex(0)
  if form.itemtype ~= 1 then
    return
  end
  if imagegrid.item_id == "" or imagegrid.item_id == nil then
    return
  end
  nx_execute("form_stage_main\\form_marry\\form_qingyuanpu", "show_model", imagegrid.item_id, form)
end
function show_model(id, form)
  if not nx_is_valid(form) then
    return
  end
  local radius = 1.8
  form.ismount = 0
  local ret = create_role_model(form, id)
  if not ret then
    return
  end
  form.scenebox_1.Scene.camera:SetPosition(0, radius * 0.46, -radius * 2)
  nx_set_custom(form, "show_item", id)
end
function create_role_model(form, equipid)
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
  local g_config = {
    [140] = {ArtPack = "Hat"},
    [141] = {
      ArtPack = "Cloth",
      HatArtPack = "Hat",
      PlantsArtPack = "Pants",
      ShoesArtPack = "Shoes"
    },
    [142] = {ArtPack = "Pants"},
    [143] = {ArtPack = "Shoes"}
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
  for id, prop in pairs(cfg) do
    local art_id = nx_number(get_prop(equipid, id))
    if art_id < 0 then
      unlink_skin(actor2, prop)
      unlink_skin(actor2, string.lower(prop))
    elseif 0 < art_id then
      local art_prop = item_static_query(art_id, model_prop, STATIC_DATA_ITEM_ART)
      if art_prop ~= nil then
        unlink_skin(actor2, prop)
        unlink_skin(actor2, string.lower(prop))
        if "Cloth" == prop or "cloth" == prop then
          link_cloth_skin(role_composite, actor2, art_prop)
        else
          role_composite:LinkSkin(actor2, prop, art_prop .. ".xmod", false)
        end
      end
    end
  end
  return add_actor2_to_scenebox(form, actor2)
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
  local player_body_type = player:QueryProp("BodyType")
  local player_sex = player:QueryProp("Sex")
  if (item_sex == 2 or item_sex == player_sex) and not body_manager:IsNewBodyType(player) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_WOMAN_JUV) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_MAN_JUV) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) and nx_int(item_body_type) ~= nx_int(ORIGIN_EM_BODY_MAN_MAJ) then
    local show_type = player:QueryProp("ShowEquipType")
    if show_type ~= nil and show_type ~= 1 then
      actor2 = role_composite:CreateSceneObjectWithSubModel(form.scenebox_1.Scene, player, false, false, false)
      form.actor2 = actor2
      form.sex = player_sex
      form.body_type = item_body_type
      return
    end
  end
  if body_manager:IsNewBodyType(player) and nx_number(item_body_type) == nx_number(player_body_type) then
    actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nx_number(item_body_type))
    form.actor2 = actor2
    form.sex = player_sex
    form.body_type = item_body_type
    return
  end
  if nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_JUV) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_WOMAN_MAJ) or nx_int(item_body_type) == nx_int(ORIGIN_EM_BODY_MAN_MAJ) then
    actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nx_number(item_body_type))
    form.actor2 = actor2
    form.sex = item_sex
    form.body_type = item_body_type
    return
  else
    actor2 = create_role_composite(form.scenebox_1.Scene, true, item_sex, nil, nil)
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
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
end
function add_actor2_to_scenebox(form, actor2)
  if not nx_is_valid(form) then
    remove_role(actor2)
    return false
  end
  util_add_model_to_scenebox(form.scenebox_1, actor2)
  local temp_act2 = form.actor2
  form.actor2 = actor2
  return true
end
function remove_role(actor2)
  if nx_is_valid(actor2) then
    local world = nx_value("world")
    world:Delete(actor2)
  end
end
function on_btn_19_click(btn)
  local form = btn.ParentForm
  btn.MouseDown = false
  local speed = 3.1415926
  local elapse = 0.1
  local dist = speed * elapse
  ui_RotateModel(form.scenebox_1, dist)
end
function on_btn_19_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_19_push(btn)
  btn.MouseDown = false
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
function on_btn_20_click(btn)
  local form = btn.ParentForm
  btn.MouseDown = false
  local speed = -3.141592
  local elapse = 0.1
  local dist = speed * elapse
  ui_RotateModel(form.scenebox_1, dist)
end
function on_btn_20_lost_capture(btn)
  btn.MouseDown = false
end
function on_btn_20_push(btn)
  btn.MouseDown = false
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
function msg(str, val)
  nx_msgbox(nx_string(str) .. nx_string(val))
end
