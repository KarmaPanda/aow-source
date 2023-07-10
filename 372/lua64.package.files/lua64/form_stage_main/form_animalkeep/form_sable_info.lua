require("share\\view_define")
require("define\\gamehand_type")
require("util_gui")
require("util_functions")
require("custom_sender")
require("role_composite")
require("util_static_data")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("define\\map_lable_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  form.Visible = true
end
function init_sableinfo(form, item_config, item_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mountmodel)
  if not nx_is_valid(form.scenebox_mountmodel.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mountmodel)
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  local actor2 = form.scenebox_mountmodel.Scene:Create("Actor2")
  actor2.AsyncLoad = true
  actor2.sable = ""
  if nx_string(item_config) == nx_string("fengzheng_gensui") then
    load_from_ini(actor2, "ini\\npc\\part_back_1_16_2.ini")
    actor2:SetScale(0.3, 0.3, 0.3)
  else
    local itemArtPack = nx_int(get_item_info(item_config, "ArtPack"))
    if itemArtPack ~= "" then
      actor2.sable = item_static_query(itemArtPack, 0, STATIC_DATA_ITEM_ART)
      if 0 < string.len(actor2.sable) then
        load_from_ini(actor2, "ini\\" .. actor2.sable .. ".ini")
      end
    end
  end
  if not nx_is_valid(actor2) then
    return
  end
  if nx_string(item_config) == nx_string("pet_peacock_gensui") then
    actor2:SetScale(0.3, 0.3, 0.3)
  end
  if nx_string(item_config) == nx_string("pet_kuilei_gensui") then
    actor2:SetScale(0.3, 0.3, 0.3)
  end
  if nx_string(item_config) == nx_string("pet_pig_gensui") then
    actor2:SetScale(0.5, 0.5, 0.5)
  end
  if not nx_is_valid(form) then
    form.scenebox_mountmodel.Scene:Delete(actor2)
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mountmodel, actor2)
  form.scenebox_mountmodel.Visible = true
  local scene = form.scenebox_mountmodel.Scene
  if not nx_is_valid(scene) then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SABLE_HANDLE), 0, 1)
    main_form_close(form)
    return
  end
  local radius = 0.3
  if string.find(item_config, "_line") then
    radius = 1
  end
  if string.find(item_config, "mianyang") then
    radius = 0.5
  end
  if string.find(item_config, "xuelang") then
    radius = 1.2
  end
  if string.find(item_config, "xiaolu") then
    radius = 1.1
  end
  if string.find(item_config, "keji") then
    radius = 0.7
  end
  scene.camera:SetPosition(0, radius * 0.6, -radius * 2.8)
  scene.BackColor = "0,0,0,0"
  actor2:SetPosition(0, 0.065, 0)
  scene.camera.Fov = 0.125 * math.pi * 2
  local dist = -0.785
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
  form.lbl_name.Text = gui.TextManager:GetText(item_config)
  form.mltbox_words:Clear()
  local words_id = "ui_" .. item_config
  form.mltbox_words:AddHtmlText(nx_widestr(gui.TextManager:GetText(words_id)), nx_int(-1))
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Sable", "string", form, nx_current(), "refresh_Sable")
  end
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
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
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
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
  end
end
function main_form_close(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mountmodel)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("Sable", form)
  end
  form.lbl_name.Text = ""
  form.mltbox_words:Clear()
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SABLE_HANDLE), 0, 0)
  main_form_close(form)
end
function on_btn_unite_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SABLE_HANDLE), 0, 1)
  main_form_close(form)
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function refresh_Sable(form, prop_name, prop_type, prop_value)
  if prop_value == "" then
    main_form_close(form)
  end
end
function sable_map_pos_handle(...)
  local msg_type = arg[2]
  if msg_type == 0 then
    local sable_x = arg[3]
    local sable_z = arg[4]
    nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", SEARCH_SABLE, sable_x, sable_z)
  else
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", SEARCH_SABLE)
  end
end
