require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_life\\form_recast_zhuishi"
local RECAST_TYPE_EQUIP_SUBSIST_RAND = 8
function on_main_form_init(form)
  form.sel_op = -1
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  form.Fixed = false
  form.cost_type = 1
end
function on_main_form_open(form)
  nx_execute("form_stage_main\\form_life\\form_recast_attribute", "load_ini", form)
  clearform(form)
  init(form)
  form.btn_ok.Enabled = false
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  if form.is_change then
    local name = gui.TextManager:GetText("recast_weapon")
    gui.TextManager:Format_SetIDName("zhuishi_close_tip_0")
    gui.TextManager:Format_AddParam(name)
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  nx_destroy(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  on_main_form_close(form)
end
function clearform(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_equip
  grid:Clear()
  form.lbl_name.Text = nx_widestr("")
  form.mltbox_cost:Clear()
  form.mltbox_src_1:Clear()
  form.mltbox_max_1:Clear()
  form.mltbox_skill_1:Clear()
  form.mltbox_result:Clear()
  form.sel_index = -1
  form.sel_view = -1
end
function init(form)
  if not nx_is_valid(form) then
    return
  end
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  end
  clearform(form)
  form.sel_op = RECAST_TYPE_EQUIP_SUBSIST_RAND
  form.mltbox_max_1.Visible = true
  form.mltbox_skill_1.Visible = false
end
function on_imagegrid_wq_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_wq_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = 1
  end
  return photo, amount
end
function on_imagegrid_wq_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  local gamehand_type = gameHand.Type
  if gamehand_type ~= GHT_VIEWITEM then
    gameHand:ClearHand()
    return
  end
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  if form.sel_view == src_viewid and form.sel_index == src_pos then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
    gameHand:ClearHand()
    return
  end
  local open = true
  if open ~= true then
    custom_sysinfo(1, 1, 1, 2, "100059")
    gameHand:ClearHand()
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    gameHand:ClearHand()
    return
  end
  local suecceed = check_player_status()
  if suecceed == false then
    gameHand:ClearHand()
    return
  end
  suecceed = check_equip_item(form, item)
  if suecceed == false then
    gameHand:ClearHand()
    return
  end
  if form.is_change then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_close_tip_1")
    gameHand:ClearHand()
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  clearform(form)
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view = src_viewid
  form.sel_index = src_pos
  form.is_change = false
  nx_execute("custom_sender", "custom_msg_recast_lock", form.sel_view, form.sel_index, form.sel_op)
  gameHand:ClearHand()
  refreshform(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local open = true
  if open ~= true then
    custom_sysinfo(1, 1, 1, 2, "100059")
    gameHand:ClearHand()
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_siren")
    return false
  end
  if form.is_change == false then
    local name = gui.TextManager:GetText("recast_equip")
    custom_sysinfo(1, 1, 1, 2, "recast_nochange_tip", name)
    return
  end
  local op_name = gui.TextManager:GetText("recast_equip")
  gui.TextManager:Format_SetIDName("zhuishi_cover_tip")
  gui.TextManager:Format_AddParam(op_name)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_coverprop")
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "recast_coverprop_confirm_return")
  if res ~= "ok" then
    return
  end
  nx_execute("custom_sender", "custom_msg_recast_sureprop", form.sel_view, form.sel_index, form.sel_op)
end
function clear_recast_info(opType)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  local gui = nx_value("gui")
  if form.sel_op ~= opType then
    return
  end
  local name = gui.TextManager:GetText("recast_equip")
  custom_sysinfo(1, 1, 1, 2, "zhuishi_change_tip", name)
  form.is_change = false
  form.btn_ok.Enabled = false
  form.mltbox_result:Clear()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  show_life_addprop(form, view_item)
end
function refreshform(form)
  if not nx_is_valid(form) then
    return
  end
  if form.sel_view == -1 or form.sel_index == -1 then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_equip_name", form, view_item, form.lbl_name)
  show_equip_cost(form, view_item)
  show_life_addprop(form, view_item)
  update_life_randprop(form, view_item)
end
function show_life_addprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  local mltbox = form.mltbox_src_1
  mltbox:Clear()
  mltbox.ShadowColor = "0,255,0,0"
  if not nx_is_valid(item) then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local equipprop_table = form_attribute:GetEquipLifePropInfo(item)
  local size = table.getn(equipprop_table)
  for i = 1, size do
    mltbox:AddHtmlText(equipprop_table[i], -1)
  end
end
function update_life_randprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= 8 then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local prop_table = {}
  prop_table[1] = form_attribute:GetMaxLifeRandPropVal(item, "DeCold")
  prop_table[2] = form_attribute:GetMaxLifeRandPropVal(item, "DeHot")
  prop_table[3] = form_attribute:GetMaxLifeRandPropVal(item, "Comfort")
  local gui = nx_value("gui")
  local index = 1
  local mltbox = form.mltbox_max_1
  mltbox:Clear()
  mltbox.TextColor = "255,0,139,0"
  for i, packid in pairs(prop_table) do
    if 0 < packid then
      local text_id = "tips_proppack_" .. nx_string(packid)
      local text = gui.TextManager:GetText(text_id)
      mltbox:AddHtmlText(text, -1)
    end
  end
end
function on_imagegrid_wq_drag_move(grid, index, move_x, move_y)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local gui = nx_value("gui")
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("recast_equip", photo, "", "", "", "")
  end
end
function on_imagegrid_wq_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  if form.is_change then
    local name = gui.TextManager:GetText("recast_weapon")
    gui.TextManager:Format_SetIDName("zhuishi_close_tip_0")
    gui.TextManager:Format_AddParam(name)
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local open = true
  if open ~= true then
    custom_sysinfo(1, 1, 1, 2, "100059")
    gameHand:ClearHand()
    return
  end
  local suecceed = check_player_status()
  if suecceed == false then
    return
  end
  suecceed = check_equip_item(form, view_item)
  if suecceed == false then
    return
  end
  suecceed = check_money(form, view_item)
  if suecceed == false then
    return
  end
  local dialog = nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_dialog_tip", form)
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_attribute_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_msg_recast_randprop", form.sel_view, form.sel_index, form.sel_op, nx_int(1))
    end
  end
end
function show_randprop_succeed(op_type, newpackprop)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local recast_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(recast_attribute) then
    return
  end
  local gui = nx_value("gui")
  if form.sel_op ~= op_type then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local money = recast_attribute:GetMoney(form.sel_op, view_item)
  custom_sysinfo(1, 1, 1, 2, "recast_ok_tip", money)
  form.is_change = true
  form.btn_ok.Enabled = true
  local newpack_table = util_split_string(newpackprop, ":")
  local num = table.getn(newpack_table)
  local show_table = {}
  local pos = 1
  for i = 1, num do
    local pack_table = util_split_string(newpack_table[i], ",")
    local size = table.getn(pack_table)
    if size == 2 and pack_table[2] ~= "" then
      show_table[pos] = pack_table[2]
      pos = pos + 1
    end
  end
  local mltbox = form.mltbox_result
  mltbox:Clear()
  local text_prefix = ""
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
    text_prefix = "tips_skillpack_"
    mltbox.ShadowColor = "0,0,0,0"
  elseif form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE or form.sel_op == 8 then
    text_prefix = "tips_proppack_"
    mltbox.ShadowColor = "0,255,0,0"
  end
  for i, value in pairs(show_table) do
    local text_id = text_prefix .. nx_string(value)
    local text = gui.TextManager:GetText(text_id)
    mltbox:AddHtmlText(text, -1)
  end
  nx_execute("form_stage_main\\form_life\\form_recast_attribute", "show_equip_name", form, view_item, form.lbl_name)
end
function open_form()
  local suecceed = check_player_status()
  if suecceed == false then
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) or form.Visible then
  else
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local tips_dialog = nx_value("recast_attribute_form_confirm")
  if nx_is_valid(tips_dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", tips_dialog.cancel_btn)
  end
  local no_finish = nx_value("recast_no_finish_form_confirm")
  if nx_is_valid(no_finish) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", no_finish.cancel_btn)
  end
  local cover_dialog = nx_value("recast_coverprop_form_confirm")
  if nx_is_valid(cover_dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", cover_dialog.cancel_btn)
  end
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.is_change = false
    form.Visible = false
    form:Close()
  end
end
function del_equip_info()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local gui = nx_value("gui")
  if form.sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  if form.is_change then
    local name = gui.TextManager:GetText("recast_equip")
    gui.TextManager:Format_SetIDName("recast_close_tip_0")
    gui.TextManager:Format_AddParam(name)
    local text = gui.TextManager:Format_GetText()
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
    if not nx_is_valid(dialog) then
      return
    end
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  local grid = form.imagegrid_equip
  nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
end
function check_player_status()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_siren")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_shuizhong")
    return false
  end
  return true
end
function check_equip_item(form, item)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(item) then
    return false
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return false
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return false
  end
  local gui = nx_value("gui")
  if form.sel_op ~= 8 then
    local isCan = form_attribute:CanEquipRecast(item, form.sel_op)
    if isCan ~= true then
      local text = gui.TextManager:GetText("recast_equip")
      custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
      return false
    end
  end
  local item_type = item:QueryProp("ItemType")
  if form.sel_op == 8 then
    if item_type < ITEMTYPE_EQUIP_HAT then
      local text = gui.TextManager:GetText("recast_equip")
      custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_equip", text)
      return false
    end
    if item_type > ITEMTYPE_EQUIP_WRIST then
      local text = gui.TextManager:GetText("recast_equip")
      custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_equip", text)
      return false
    end
  end
  local color_level = item:QueryProp("ColorLevel")
  if nx_number(color_level) < 4 then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_colorlevel")
    return false
  end
  local level = item:QueryProp("Level")
  if nx_number(level) < 31 then
    custom_sysinfo(1, 1, 1, 2, "zhuishi_failed_level")
    return false
  end
  local RecoverFlag = item:QueryProp("RecoverFlag")
  if RecoverFlag ~= 0 then
    custom_sysinfo(1, 1, 1, 2, "sys_equip_damaged")
    return false
  end
  return true
end
function show_equip_cost(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local gui = nx_value("gui")
  local money = form_attribute:GetMoney(form.sel_op, item)
  gui.TextManager:Format_SetIDName("ui_recast_cost")
  gui.TextManager:Format_AddParam(money)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_cost:AddHtmlText(text, -1)
end
function check_money(form, item)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(item) then
    return false
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return false
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return false
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local gui = nx_value("gui")
  local money_type = form_attribute:GetMoneyType(form.sel_op, item)
  local money_value = form_attribute:GetMoney(form.sel_op, item)
  if money_value <= 0 then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_nomoney_tip")
    return false
  end
  local isCan = capital:CanDecCapital(nx_int(money_type), nx_int64(money_value))
  if isCan ~= true then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_nomoney_tip")
  end
  return isCan
end
