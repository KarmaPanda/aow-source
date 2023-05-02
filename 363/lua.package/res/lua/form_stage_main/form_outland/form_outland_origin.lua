require("util_gui")
require("util_functions")
require("role_composite")
require("util_static_data")
local FILE_INI = "share\\Rule\\outland\\form_outland_origin.ini"
local CAN_GET_ORIGIN_LIST = {}
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local outland_ini = get_ini(FILE_INI, true)
  if not nx_is_valid(outland_ini) then
    return
  end
  form.outland_ini = outland_ini
  form.ini_section_count = outland_ini:GetSectionCount()
  local _, sex = get_player_prop("Sex")
  form.player_sex = nx_number(sex)
  form.default_actor = nx_null()
  form.origin_step = -1
  data_bind_prop(form)
  show_origin_reward_info_form(form, false)
end
function on_main_form_close(form)
  if nx_running(nx_current(), "util_addscene_to_scenebox") then
    nx_kill(nx_current(), "util_addscene_to_scenebox")
  end
  if nx_running(nx_current(), "util_add_model_to_scenebox") then
    nx_kill(nx_current(), "util_add_model_to_scenebox")
  end
  if nx_running(nx_current(), "show_client_body") then
    nx_kill(nx_current(), "show_client_body")
  end
  if nx_running(nx_current(), "outland_origin_change_cloth") then
    nx_kill(nx_current(), "outland_origin_change_cloth")
  end
  if not nx_is_valid(form) then
    return
  end
  del_data_bind_prop(form)
  ui_ClearModel(form.scenebox_1)
  nx_destroy(form)
end
function on_btn_step_select_change(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_origin_reward_info_form(form, true)
  local origin_step = nx_number(btn.DataSource)
  show_client_body(form)
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = nx_number(form.ini_section_count) - 1
  if 1 <= origin_step and origin_step <= section_count then
    show_origin_info(form, origin_step)
    refresh_state(form)
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_origin_reward_info_form(form, false)
end
function on_btn_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "origin_step") then
    return
  end
  if nx_number(form.origin_step) < 0 then
    return
  end
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = nx_number(form.ini_section_count) - 1
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local btn_type = nx_number(btn.DataSource)
  local tips_info = ""
  if 1 <= btn_type and section_count >= btn_type then
    tips_info = get_outland_ini_item_id(form, "TipsID", form.origin_step)
    if tips_info == "" then
      return
    end
  else
    return
  end
  local cur_camp_offset = 1
  local next_step_need = 2
  gui.TextManager:Format_SetIDName(nx_string(tips_info))
  gui.TextManager:Format_AddParam(cur_camp_offset)
  gui.TextManager:Format_AddParam(next_step_need)
  local tips = gui.TextManager:Format_GetText()
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips), btn.AbsLeft, btn.AbsTop, 0, form)
end
function on_btn_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_btn_reward_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "origin_step") then
    return
  end
  if nx_number(form.origin_step) < 0 then
    return
  end
  local origin_id = get_outland_ini_item_id(form, "RewardTiTleID", form.origin_step)
  if origin_id == "" then
    return
  end
  local reward_type = btn.DataSource
  if reward_type == "1" then
    nx_execute("custom_sender", "custom_form_outland_send_get_origin", origin_id)
  elseif reward_type == "2" then
    nx_execute("custom_sender", "custom_form_outland_send_get_item", origin_id)
  else
    return
  end
end
function on_ImageControlGrid_cloth_select_changed(grid, index)
  if index ~= 0 then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  outland_origin_change_cloth(form)
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
function show_origin_reward_info_form(form, b_show)
  if not nx_is_valid(form) then
    return
  end
  if b_show then
    form.groupbox_origin_line.Visible = false
    form.groupbox_origin_reward.Visible = true
  else
    form.groupbox_origin_line.Visible = true
    form.groupbox_origin_reward.Visible = false
    refresh_state(form)
  end
end
function show_origin_info(form, origin_step)
  if not nx_is_valid(form) then
    return
  end
  local client_player, _ = get_player_prop()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  form.origin_step = origin_step
  local tmp_text = get_outland_ini_item_id(form, "OriginNameText", origin_step)
  if tmp_text == "" then
    return
  end
  form.lbl_origin_name.Text = util_text(tmp_text)
  local condition_ids = get_outland_ini_item_id(form, "ConditionID", origin_step)
  if condition_ids == "" then
    return
  end
  local condition_id = util_split_string(nx_string(condition_ids), ",")
  local condition_list = get_outland_ini_item_id(form, "ConditionText", origin_step)
  if condition_list == "" then
    return
  end
  local condition = util_split_string(nx_string(condition_list), ",")
  local complete_list = get_outland_ini_item_id(form, "CompleteConditionText", origin_step)
  if complete_list == "" then
    return
  end
  local complele_condition = util_split_string(nx_string(complete_list), ",")
  local num_condition_text = table.getn(condition)
  local num_condition_id = table.getn(condition_id)
  local num_complele = table.getn(complele_condition)
  if num_condition_text ~= num_condition_id or num_complele ~= num_condition_text then
    return
  end
  local condition_html = nx_widestr("")
  for i = 1, num_condition_id do
    local tmp = util_text(complele_condition[i])
    local tmp2 = util_text(condition[i])
    if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id[i])) then
      condition_html = condition_html .. tmp .. nx_widestr("<br>")
    else
      condition_html = condition_html .. tmp2 .. nx_widestr("<br>")
    end
  end
  form.mltbox_condition.HtmlText = condition_html
  local reward_info_id = get_outland_ini_item_id(form, "RewardText", origin_step)
  if reward_info_id == "" then
    return
  end
  form.mltbox_reward.HtmlText = util_text(reward_info_id)
  local grid = form.ImageControlGrid_item
  grid:Clear()
  local items_index = 0
  local cloths = get_outland_ini_item_id(form, "ModelClothID", origin_step)
  if cloths ~= "" then
    if not nx_find_custom(form, "player_sex") then
      return
    end
    local player_sex = nx_number(form.player_sex)
    if player_sex ~= 0 and player_sex ~= 1 then
      return
    end
    local cloth_id = util_split_string(cloths, ",")
    if table.getn(cloth_id) ~= 2 then
      return
    end
    photo = item_query_ArtPack_by_id(cloth_id[player_sex + 1], "Photo")
    grid:AddItem(items_index, photo, nx_widestr(cloth_id[player_sex + 1]), 1, -1)
    grid:CoverItem(items_index, true)
    items_index = 1
  end
  local items = get_outland_ini_item_id(form, "RewardItemID", origin_step)
  if items == "" then
    return
  end
  local item_list = util_split_string(items, ",")
  if table.getn(item_list) <= 0 then
    return
  end
  local grid_index = items_index
  local photo = ""
  for _, item_id in ipairs(item_list) do
    photo = item_query_ArtPack_by_id(item_id, "Photo")
    grid:AddItem(grid_index, photo, nx_widestr(item_id), 1, -1)
    grid:CoverItem(grid_index, true)
    grid_index = grid_index + 1
  end
  local _, landflag_index = get_player_prop("Landflag")
  local land_flag_list = get_outland_ini_item_id(form, "LandFlagText", "All")
  if land_flag_list == "" then
    return
  end
  local land_flag = util_split_string(nx_string(land_flag_list), ",")
  local index = nx_number(landflag_index)
  if index < 0 or 3 <= index then
    return
  end
  form.lbl_landflag.Text = util_text(land_flag[index + 1])
end
function show_client_body(form)
  if not nx_is_valid(form) then
    return
  end
  local scene_box = form.scenebox_1
  if not nx_find_custom(form, "player_sex") then
    return
  end
  ui_ClearModel(scene_box)
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
  util_addscene_to_scenebox(scene_box)
  local client_player, _ = get_player_prop()
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
    actor2 = create_role_composite(scene_box.Scene, false, nx_number(form.player_sex), "stand", body)
  else
    actor2 = role_composite:CreateSceneObject(scene_box.Scene, client_player, false, false)
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if not nx_is_valid(actor2) then
    return
  end
  form.default_actor = actor2
  util_add_model_to_scenebox(scene_box, actor2)
  local show_equip_type = 0
  if client_player:FindProp("ShowEquipType") then
    show_equip_type = client_player:QueryProp("ShowEquipType")
  end
  role_composite:RefreshBodyNorEquip(client_player, form.default_actor, show_equip_type)
end
function outland_origin_change_cloth(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "default_actor") then
    return
  end
  local actor2 = form.default_actor
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_find_custom(form, "origin_step") then
    return
  end
  local origin_step = form.origin_step
  if nx_number(origin_step) < 0 then
    return
  end
  if not nx_find_custom(form, "player_sex") then
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
  local cloth_list = get_outland_ini_item_id(form, "ModelClothID", origin_step)
  if cloth_list == "" then
    return
  end
  local cloth_id = util_split_string(cloth_list, ",")
  if table.getn(cloth_id) ~= 2 then
    return
  end
  local model_sex = "MaleModel"
  local cloth = cloth_id[1]
  if form.player_sex == 1 then
    model_sex = "FemaleModel"
    cloth = cloth_id[2]
  end
  local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, "ArtPack"))
  local model_path = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_sex)
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
    role_composite:UnLinkSkin(actor2, v)
  end
  role_composite:LinkSkin(actor2, "cloth", model_path .. ".xmod", false)
  role_composite:LinkSkin(actor2, "cloth_h", model_path .. "_h.xmod", false)
end
function data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Origin_Active", form, nx_current(), "on_refresh_outland_origin")
    databinder:AddTableBind("Origin_Completed", form, nx_current(), "on_refresh_outland_origin")
    databinder:AddTableBind("Origin_Prized", form, nx_current(), "on_refresh_outland_origin")
    databinder:AddTableBind("Origin_Record", form, nx_current(), "on_refresh_outland_origin")
  end
end
function del_data_bind_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Origin_Active", form)
    databinder:DelTableBind("Origin_Completed", form)
    databinder:DelTableBind("Origin_Prized", form)
    databinder:DelTableBind("Origin_Record", form)
  end
end
function get_outland_ini_item_id(form, choice, section)
  if not nx_is_valid(form) then
    return ""
  end
  if choice == "" then
    return ""
  end
  if not nx_find_custom(form, "outland_ini") then
    return ""
  end
  local outland_ini = form.outland_ini
  if not nx_is_valid(outland_ini) then
    return ""
  end
  local sec_index = outland_ini:FindSectionIndex(nx_string(section))
  if sec_index < 0 then
    return ""
  end
  return outland_ini:ReadString(sec_index, nx_string(choice), "")
end
function get_player_prop(prop)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nil, nil
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil, nil
  end
  if prop == nil then
    return client_player, nil
  end
  if not client_player:FindProp(nx_string(prop)) then
    return client_player, nil
  end
  return client_player, client_player:QueryProp(nx_string(prop))
end
function get_player_reward_state(form, origin_step)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(origin_step) < 0 then
    return
  end
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = nx_number(form.ini_section_count) - 1
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local reward_origin_id = get_outland_ini_item_id(form, "RewardTiTleID", origin_step)
  local b_active = origin_manager:IsActiveOrigin(nx_int(reward_origin_id))
  local b_origin = origin_manager:IsCompletedOrigin(nx_int(reward_origin_id))
  local b_item = origin_manager:IsOriginGetPrize(nx_int(reward_origin_id))
  if table.getn(CAN_GET_ORIGIN_LIST) ~= section_count then
    return
  end
  local b_condition = CAN_GET_ORIGIN_LIST[nx_number(origin_step)]
  return b_active, b_origin, b_item, b_condition
end
function on_refresh_outland_origin(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  refresh_state(form)
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
function refresh_state(form)
  if not nx_is_valid(form) then
    return
  end
  refresh_get_condition_complete_state(form)
  refresh_player_get_reward(form)
  if form.groupbox_origin_line.Visible then
    refresh_player_reward_state(form)
  end
end
function refresh_get_condition_complete_state(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = form.ini_section_count - 1
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local client_player, _ = get_player_prop()
  if not nx_is_valid(client_player) then
    return
  end
  for i = 1, section_count do
    local b_can_get_origin = true
    local condition_ids = get_outland_ini_item_id(form, "ConditionID", i)
    if condition_ids == "" then
      return
    end
    local condition_id = util_split_string(nx_string(condition_ids), ",")
    for i = 1, table.getn(condition_id) do
      if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id[i])) then
        b_can_get_origin = false
        break
      end
    end
    CAN_GET_ORIGIN_LIST[i] = b_can_get_origin
  end
end
function refresh_player_get_reward(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = form.ini_section_count - 1
  if not nx_find_custom(form, "origin_step") then
    return
  end
  if nx_number(form.origin_step) < 0 or section_count < nx_number(form.origin_step) then
    return
  end
  local reward_origin_id = get_outland_ini_item_id(form, "RewardTiTleID", form.origin_step)
  if reward_origin_id == "" then
    form.btn_get_origin.Enabled = false
    form.btn_get_reward.Enabled = false
  else
    local b_active, b_origin, b_item, b_condition = get_player_reward_state(form, form.origin_step)
    if b_active == nil or b_origin == nil or b_item == nil or b_condition == nil then
      return
    end
    if b_origin then
      form.btn_get_origin.Enabled = false
      if b_item then
        form.btn_get_reward.Enabled = false
      else
        form.btn_get_reward.Enabled = true
      end
    elseif b_active and b_condition then
      form.btn_get_origin.Enabled = true
      form.btn_get_reward.Enabled = false
    else
      form.btn_get_origin.Enabled = false
      form.btn_get_reward.Enabled = false
    end
  end
end
function refresh_player_reward_state(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local section_count = form.ini_section_count - 1
  local state_id_list = get_outland_ini_item_id(form, "RewardStateText", "All")
  if state_id_list == "" then
    return
  end
  local state_id = util_split_string(nx_string(state_id_list), ",")
  local tmp_text = ""
  local btn, lbl_flash, lbl_name
  local reward_origin_id = 0
  local b_active, b_origin, b_item, b_condition = false, false, false, false
  for i = 1, section_count do
    reward_origin_id = get_outland_ini_item_id(form, "RewardTiTleID", i)
    if reward_origin_id == "" then
      break
    end
    b_active, b_origin, b_item, b_condition = get_player_reward_state(form, i)
    if b_active == nil or b_origin == nil or b_item == nil or b_condition == nil then
      break
    end
    tmp_text = "btn_" .. nx_string(i)
    btn = nx_custom(form, tmp_text)
    tmp_text = "lbl_bg_" .. nx_string(i)
    lbl_flash = nx_custom(form, tmp_text)
    tmp_text = "mltbox_name_" .. nx_string(i)
    lbl_name = nx_custom(form, tmp_text)
    if b_active then
      btn.Enabled = true
      if b_condition then
        if b_origin then
          if b_item then
            lbl_flash.Visible = false
            lbl_name.HtmlText = util_text(state_id[4])
          else
            lbl_flash.Visible = true
            lbl_name.HtmlText = util_text(state_id[3])
          end
        else
          lbl_flash.Visible = true
          lbl_name.HtmlText = util_text(state_id[3])
        end
      elseif not b_origin and not b_item then
        lbl_flash.Visible = false
        lbl_name.HtmlText = util_text(state_id[1])
      elseif b_origin and b_item then
        lbl_flash.Visible = false
        lbl_name.HtmlText = util_text(state_id[4])
      else
        lbl_flash.Visible = true
        lbl_name.HtmlText = util_text(state_id[3])
      end
    else
      btn.Enabled = false
      lbl_flash.Visible = false
      lbl_name.HtmlText = util_text(state_id[2])
    end
  end
end
function is_outland_origin(origin_id)
  local ini = get_ini(FILE_INI, true)
  if not nx_is_valid(ini) then
    return false
  end
  local origin_count = ini:GetSectionCount() - 1
  local res = false
  for i = 1, origin_count do
    local sec_index = ini:FindSectionIndex(nx_string(i))
    if sec_index < 0 then
      return false
    end
    local outland_origin = ini:ReadString(sec_index, "RewardTiTleID", "")
    if origin_id == outland_origin then
      res = true
      break
    end
  end
  return res
end
