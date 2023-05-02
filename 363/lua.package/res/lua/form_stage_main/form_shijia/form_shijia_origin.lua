require("util_gui")
require("util_functions")
require("role_composite")
require("util_static_data")
function is_shijia_origin(title_id)
  local ini = get_ini("ini\\shijia\\shijia_origin.ini", true)
  if not nx_is_valid(ini) then
    return false
  end
  local origin_count = ini:GetSectionCount()
  for i = 1, origin_count do
    local sec_index = ini:FindSectionIndex(nx_string(i))
    if sec_index < 0 then
      return false
    end
    local id = ini:ReadInteger(sec_index, "RewardTiTleID", -1)
    if id == title_id then
      return true
    end
  end
  return false
end
function show_shijia_origin(title_id)
  util_show_form("form_stage_main\\form_shijia\\form_shijia_guide", true)
  local form_guide = nx_value("form_stage_main\\form_shijia\\form_shijia_guide")
  if not nx_is_valid(form_guide) then
    return
  end
  local form_origin = nx_null()
  if nx_find_custom(form_guide, "form_origin") and nx_is_valid(form_guide.form_origin) then
    form_origin = form_guide.form_origin
  end
  local form_logic = nx_value("form_shijia_origin")
  if not nx_is_valid(form_logic) then
    return
  end
  if not form_logic:IsShiJiaOrigin(title_id) then
    return
  end
  form_guide.rbtn_origin.Checked = true
  local shijia_id = form_logic:GetShiJiaID(title_id)
  if shijia_id == form_origin.rbtn_shijia_dongfang.DataSource then
    form_origin.rbtn_shijia_dongfang.Checked = true
    form_origin.groupbox_detail.Visible = false
    form_origin.groupbox_origin.Visible = true
  elseif shijia_id == form_origin.rbtn_shijia_nangong.DataSource then
    form_origin.rbtn_shijia_nangong.Checked = true
    form_origin.groupbox_detail.Visible = false
    form_origin.groupbox_origin.Visible = true
  elseif shijia_id == form_origin.rbtn_shijia_yanmen.DataSource then
    form_origin.rbtn_shijia_yanmen.Checked = true
    form_origin.groupbox_detail.Visible = false
    form_origin.groupbox_origin.Visible = true
  elseif shijia_id == form_origin.rbtn_shijia_murong.DataSource then
    form_origin.rbtn_shijia_murong.Checked = true
    form_origin.groupbox_detail.Visible = false
    form_origin.groupbox_origin.Visible = true
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local form_logic = nx_value("form_shijia_origin")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_origin")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_origin", form_logic)
  end
  nx_execute(nx_current(), "show_player_model", form)
  form.rbtn_shijia_dongfang.Checked = true
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddTableBind("Origin_Active", form, nx_current(), "on_update_origin_state")
    data_binder:AddTableBind("Origin_Completed", form, nx_current(), "on_update_origin_state")
    data_binder:AddTableBind("Origin_Prized", form, nx_current(), "on_update_origin_state")
    data_binder:AddTableBind("Origin_Record", form, nx_current(), "on_update_origin_state")
    data_binder:AddRolePropertyBind("MuRongHonour", "string", form, nx_current(), "on_update_honour")
    data_binder:AddRolePropertyBind("YanMenHonour", "string", form, nx_current(), "on_update_honour")
    data_binder:AddRolePropertyBind("DongFangHonour", "string", form, nx_current(), "on_update_honour")
    data_binder:AddRolePropertyBind("NanGongHonour", "string", form, nx_current(), "on_update_honour")
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind("Origin_Active", form)
    data_binder:DelTableBind("Origin_Completed", form)
    data_binder:DelTableBind("Origin_Prized", form)
    data_binder:DelTableBind("Origin_Record", form)
  end
  if nx_running(nx_current(), "show_player_model") then
    nx_kill(nx_current(), "show_player_model")
  end
  nx_destroy(form)
end
function on_update_origin_state(form)
  local form_logic = nx_value("form_shijia_origin")
  if nx_is_valid(form_logic) then
    form_logic:UpdateOriginState()
  end
end
function on_rbtn_shijia_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  local shijia = self.DataSource
  form.cur_shijia_id = shijia
  local form_logic = nx_value("form_shijia_origin")
  if nx_is_valid(form_logic) then
    form.groupbox_detail.Visible = false
    form.groupbox_origin.Visible = true
    form_logic:UpdateOriginList(form, shijia)
    form_logic:UpdateOriginState()
  end
  on_update_honour(form)
end
function on_update_honour(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local value = 0
  local text_id = ""
  shijia_id = form.cur_shijia_id
  if shijia_id == "shijia_dongfang" then
    value = player:QueryProp("DongFangHonour")
    text_id = "ui_dongfang_origin_honour"
  elseif shijia_id == "shijia_nangong" then
    value = player:QueryProp("NanGongHonour")
    text_id = "ui_nangong_origin_honour"
  elseif shijia_id == "shijia_murong" then
    value = player:QueryProp("MuRongHonour")
    text_id = "ui_murong_origin_honour"
  elseif shijia_id == "shijia_yanmen" then
    value = player:QueryProp("YanMenHonour")
    text_id = "ui_yanmen_origin_honour"
  end
  form.lbl_11.Text = util_text(text_id)
  form.lbl_honour.Text = nx_widestr(value)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  show_origin_detail(form, false)
end
function on_btn_reward_click(btn)
  local form = btn.ParentForm
  local title_id = form.cur_title_id
  local reward_type = btn.DataSource
  if reward_type == "1" then
    nx_execute("custom_sender", "custom_form_outland_send_get_origin", title_id)
    form.btn_get_origin.Enabled = false
    form.btn_get_reward.Enabled = true
  elseif reward_type == "2" then
    nx_execute("custom_sender", "custom_form_outland_send_get_item", title_id)
    form.btn_get_reward.Enabled = false
  else
    return
  end
end
function on_ImageControlGrid_cloth_select_changed(grid, index)
  local form = grid.ParentForm
  local form_logic = nx_value("form_shijia_origin")
  if not nx_is_valid(form_logic) then
  end
  local title_id = form.cur_title_id
  local config_id = nx_string(grid:GetItemAddText(index, 0))
  if form_logic:IsClothRewarded(title_id, config_id) then
    change_player_cloth(grid, index)
  end
end
function on_ImageControlGrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  local item_id = grid:GetItemAddText(index, 0)
  if item_id == nx_widestr("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y, form)
end
function on_ImageControlGrid_item_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function show_origin_detail(form, flag)
  if flag then
    form.groupbox_origin.Visible = false
    form.groupbox_detail.Visible = true
  else
    form.groupbox_origin.Visible = true
    form.groupbox_detail.Visible = false
    local form_logic = nx_value("form_shijia_origin")
    if nx_is_valid(form_logic) then
      form_logic:UpdateOriginState()
    end
  end
end
function show_player_model(form)
  local scene_box = form.scenebox_1
  ui_ClearModel(scene_box)
  util_addscene_to_scenebox(scene_box)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local body_manager = nx_value("body_manager")
  if not nx_is_valid(body_manager) then
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local actor2
  if body_manager:IsNewBodyType(client_player) then
    local body = 2
    local body_type = body_manager:GetBodyType(client_player)
    if body_type == 3 then
      body = 1
    end
    local player_sex = get_player_sex()
    actor2 = create_role_composite(scene_box.Scene, false, nx_number(player_sex), "stand", body)
  else
    actor2 = role_composite:CreateSceneObject(scene_box.Scene, client_player, false, false)
  end
  if not nx_is_valid(actor2) then
    return
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  util_add_model_to_scenebox(scene_box, actor2)
  local show_equip_type = 0
  if client_player:FindProp("ShowEquipType") then
    show_equip_type = client_player:QueryProp("ShowEquipType")
  end
  role_composite:RefreshBodyNorEquip(client_player, actor2, show_equip_type)
  form.default_actor = actor2
end
function get_player_sex()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local player = game_client:GetPlayer()
  return player:QueryProp("Sex")
end
function change_player_cloth(grid, index)
  local form = grid.ParentForm
  local scenebox = form.scenebox_1
  local actor = form.default_actor
  if not nx_is_valid(actor) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local sex = get_player_sex()
  local model_name = "MaleModel"
  if 1 == sex then
    model_name = "FemaleModel"
  end
  local cloth = nx_string(grid:GetItemAddText(index, 0))
  local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, "ArtPack"))
  local model_path = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_name)
  local part = {
    "headdress",
    "mask",
    "scarf",
    "shoulders",
    "pendant1",
    "pendant2",
    "cloth",
    "shoes",
    "pants",
    "hat",
    "cloth_h"
  }
  for _, v in pairs(part) do
    role_composite:UnLinkSkin(actor, v)
  end
  role_composite:LinkSkin(actor, "cloth", model_path .. ".xmod", false)
  role_composite:LinkSkin(actor, "cloth_h", model_path .. "_h.xmod", false)
end
function get_player(prop)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil, nil
  end
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_btn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_1, dist)
    end
  end
end
function on_btn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if nx_is_valid(form) then
      nx_execute("util_gui", "ui_RotateModel", form.scenebox_1, dist)
    end
  end
end
function on_btn_left_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_right_click(btn)
  btn.MouseDown = false
  return
end
function on_btn_left_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_right_lost_capture(btn)
  btn.MouseDown = false
  return
end
function on_btn_origin_click(btn)
  local form = btn.ParentForm
  local origin_id = btn.origin_id
  local title_id = btn.title_id
  form.cur_title_id = title_id
  local form_logic = nx_value("form_shijia_origin")
  if nx_is_valid(form_logic) then
    if nx_running(nx_current(), "show_player_model") then
      nx_kill(nx_current(), "show_player_model")
    end
    nx_execute(nx_current(), "show_player_model", form)
    form_logic:ShowOriginDetail(form, origin_id)
    form.groupbox_detail.Visible = true
    form.groupbox_origin.Visible = false
  end
end
