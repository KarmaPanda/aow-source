require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_life\\form_recast_attribute"
local RECAST_EQUIP_RAND = 1
local RECAST_EQUIP_DIRE = 2
local RECAST_EQUIP_DEFEND = 6
local RECAST_EQUIP_DEFEND_PF = 7
local TICKET_PRICE_INI = "share\\Item\\senior_prop_cost_item.ini"
function on_main_form_init(form)
  form.sel_op = -1
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  form.Fixed = false
  form.cost_type = 1
end
function on_main_form_open(form)
  load_ini(form)
  clearform(form)
  form.sel_op = 1
  local btn_rand = form.btn_equip_rand
  local btn_dire = form.btn_equip_dire
  local btn_phydef = form.btn_equip_phydef
  local btn_parry = form.btn_equip_parry
  form.rand_normal = btn_rand.NormalImage
  form.dier_normal = btn_dire.NormalImage
  form.phydef_normal = btn_phydef.NormalImage
  form.parry_normal = btn_parry.NormalImage
  set_btn_focusstatus(form)
  form.btn_ok.Enabled = false
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  if form.is_change then
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 then
      name = gui.TextManager:GetText("recast_equip")
    end
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
function set_btn_focusstatus(form)
  if not nx_is_valid(form) then
    return
  end
  local btn_rand = form.btn_equip_rand
  local btn_dire = form.btn_equip_dire
  local btn_phydef = form.btn_equip_phydef
  local btn_parry = form.btn_equip_parry
  btn_rand.NormalImage = form.rand_normal
  btn_dire.NormalImage = form.dier_normal
  btn_phydef.NormalImage = form.phydef_normal
  btn_parry.NormalImage = form.parry_normal
  if form.sel_op == 1 then
    btn_rand.NormalImage = btn_rand.FocusImage
  elseif form.sel_op == 2 then
    btn_dire.NormalImage = btn_dire.FocusImage
  elseif form.sel_op == 6 then
    btn_phydef.NormalImage = btn_phydef.FocusImage
  elseif form.sel_op == 7 then
    btn_parry.NormalImage = btn_parry.FocusImage
  end
end
function on_btn_equip_rand_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == 1 then
    return
  end
  local check_suc = check_change_btn(form)
  if check_suc ~= true then
    set_btn_focusstatus(form)
    return
  end
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  end
  clearform(form)
  form.sel_op = 1
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_attribute_max")
  form.lbl_title_1.Text = gui.TextManager:GetText("ui_recast_equip_base")
  form.lbl_title_2.Text = text
end
function on_btn_equip_rand_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_equip_rand_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_btn_equip_dire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == 2 then
    return
  end
  local check_suc = check_change_btn(form)
  if check_suc ~= true then
    set_btn_focusstatus(form)
    return
  end
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  end
  clearform(form)
  form.sel_op = 2
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_max")
  form.lbl_title_1.Text = gui.TextManager:GetText("ui_recast_equip_base")
  form.lbl_title_2.Text = text
end
function on_btn_equip_dire_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_equip_dire_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_dire_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_btn_equip_phydef_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == 6 then
    return
  end
  local check_suc = check_change_btn(form)
  if check_suc ~= true then
    set_btn_focusstatus(form)
    return
  end
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  end
  clearform(form)
  form.sel_op = 6
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_base_d")
  form.lbl_title_1.Text = text
  text = gui.TextManager:GetText("ui_recast_equip_max_def")
  form.lbl_title_2.Text = text
end
function on_btn_equip_phydef_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_equip_phydef_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_def_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function get_cur_rtbn(form)
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == 1 then
    return form.rbtn_1
  elseif form.sel_op == 2 then
    return form.rbtn_2
  elseif form.sel_op == 3 then
    return form.rbtn_3
  elseif form.sel_op == 4 then
    return form.rbtn_4
  end
  return nx_null()
end
function check_change_btn(form)
  if not nx_is_valid(form) then
    return false
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  local gui = nx_value("gui")
  if form.is_change then
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 or form.sel_op == 6 or form.sel_op == 7 then
      name = gui.TextManager:GetText("recast_equip")
    end
    custom_sysinfo(1, 1, 1, 2, "recast_close_tip_2", name)
    return false
  end
  return true
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
  local gui = nx_value("gui")
  local gameHand = gui.GameHand
  local open = CheckCurFuncStatus(form.sel_op)
  if open ~= true then
    custom_sysinfo(1, 1, 1, 2, "100059")
    gameHand:ClearHand()
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
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
  if form.cost_type == 1 then
    suecceed = check_money(form, view_item)
  elseif form.cost_type == 2 then
    suecceed = check_cost_item(form, view_item)
  end
  if suecceed == false then
    return
  end
  local dialog = show_dialog_tip(form)
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_attribute_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_msg_recast_randprop", form.sel_view, form.sel_index, form.sel_op, form.cost_type)
    end
  end
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
  if form.sel_op >= 1 and form.sel_op <= 7 then
    local isnewitem = item:QueryProp("NewWorldItem")
    if isnewitem == 1 then
      custom_sysinfo(1, 1, 1, 2, "failed_recast_newworld002")
      return false
    end
  end
  if form.sel_op ~= 8 then
    local isCan = form_attribute:CanEquipRecast(item, form.sel_op)
    if isCan ~= true then
      local text = gui.TextManager:GetText("recast_equip")
      custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
      return false
    end
  end
  local item_type = item:QueryProp("ItemType")
  if form.sel_op ~= 1 and form.sel_op ~= 2 and form.sel_op ~= 6 and form.sel_op ~= 7 or item_type == ITEMTYPE_WEAPON_GLOVES then
  elseif item_type >= ITEMTYPE_WEAPON_MIN and item_type <= ITEMTYPE_WEAPON_QIMEN_MAX then
    local text = gui.TextManager:GetText("recast_equip")
    custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
    return false
  elseif item_type < ITEMTYPE_EQUIP_MIN or item_type > ITEMTYPE_EQUIP_MAX then
    local text = gui.TextManager:GetText("recast_equip")
    custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
    return false
  end
  if form.sel_op == RECAST_EQUIP_DEFEND then
    local check = form_attribute:CheckEquipDefAttr(item, form.sel_op)
    if check ~= true then
      custom_sysinfo(1, 1, 1, 2, "recast_failed_nodef")
      return false
    end
  end
  if form.sel_op == RECAST_EQUIP_DEFEND_PF then
    local check = form_attribute:CheckEquipDefAttr(item, form.sel_op)
    if check ~= true then
      custom_sysinfo(1, 1, 1, 2, "recast_failed_noparry")
      return false
    end
  end
  local bind_status = item:QueryProp("BindStatus")
  if nx_int(bind_status) <= nx_int(0) then
    local text = gui.TextManager:GetText("recast_equip")
    custom_sysinfo(1, 1, 1, 2, "recast_failed_notruss_tip", text)
    return false
  end
  local color_level = item:QueryProp("ColorLevel")
  if nx_number(color_level) ~= 5 and nx_number(color_level) ~= 6 then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_pinzhibugou")
    return false
  end
  local nMaxNum = item:QueryProp("MaxBuildCount")
  local nCurNum = item:QueryProp("CurBuildCount")
  if nMaxNum <= 0 or nCurNum ~= nMaxNum then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_kaiguang")
    return false
  end
  local nHardiness = item:QueryProp("Hardiness")
  if nHardiness <= 0 then
    return false
  end
  local RecoverFlag = item:QueryProp("RecoverFlag")
  if RecoverFlag ~= 0 then
    custom_sysinfo(1, 1, 1, 2, "sys_equip_damaged")
    return false
  end
  return true
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
    custom_sysinfo(1, 1, 1, 2, "recast_failed_siren")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_shuizhong")
    return false
  end
  return true
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
function check_cost_item(form, item)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(item) then
    return false
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return false
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return false
  end
  local item_id = form_attribute:GetCostItem(form.sel_op, item)
  local item_num = form_attribute:GetCostItemNum(form.sel_op, item)
  if item_id ~= "" and item_num ~= 0 then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return false
    end
    local count = GoodsGrid:GetItemCount(item_id)
    if nx_int(count) <= nx_int(0) then
      custom_sysinfo(1, 1, 1, 2, "recast_failed_noticket_tip")
      return false
    end
    if nx_int(count) < nx_int(item_num) then
      local price = get_ticket_price(item_id)
      local need_money = nx_int(item_num - count) * nx_int(price)
      local isCan = capital:CanDecCapital(nx_int(2), nx_int64(need_money))
      if isCan == false then
        custom_sysinfo(1, 1, 1, 2, "recast_failed_noticket_tip_1")
        return false
      end
    end
    return true
  end
  return false
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
  local open = CheckCurFuncStatus(form.sel_op)
  if open ~= true then
    custom_sysinfo(1, 1, 1, 2, "100059")
    gameHand:ClearHand()
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_siren")
    return false
  end
  if form.is_change == false then
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 then
      name = gui.TextManager:GetText("recast_equip")
    end
    custom_sysinfo(1, 1, 1, 2, "recast_nochange_tip", name)
    return
  end
  local op_name = nx_widestr("")
  if form.sel_op == 1 or form.sel_op == 2 then
    op_name = gui.TextManager:GetText("recast_equip")
  end
  gui.TextManager:Format_SetIDName("recast_cover_tip")
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
function on_imagegrid_zb_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_zb_mousein_grid(grid, index)
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
function on_imagegrid_zb_select_changed(grid, index)
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
  local open = CheckCurFuncStatus(form.sel_op)
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
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 then
      name = gui.TextManager:GetText("recast_equip")
    end
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
      gameHand:ClearHand()
      return
    end
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
function on_imagegrid_zb_drag_move(grid, index, move_x, move_y)
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
function on_imagegrid_zb_rightclick_grid(grid, index)
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
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 then
      name = gui.TextManager:GetText("recast_equip")
    end
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
  nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
end
function load_ini(form)
  local form_attribute = nx_value("form_recast_attribute")
  if nx_is_valid(form_attribute) then
    return
  end
  form_attribute = nx_create("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  form_attribute:LoadEquipResouce()
  form_attribute:LoadCostResouce()
  nx_set_value("form_recast_attribute", form_attribute)
end
function clearform(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_zb
  grid:Clear()
  form.lbl_item.Text = nx_widestr("")
  form.mltbox_cost:Clear()
  form.mltbox_cost_item:Clear()
  form.mltbox_value:Clear()
  form.mltbox_max:Clear()
  form.mltbox_result:Clear()
  form.sel_index = -1
  form.sel_view = -1
  form.rbtn_1.Visible = false
  form.rbtn_2.Visible = false
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
  form.rbtn_1.Visible = true
  form.rbtn_2.Visible = true
  form.rbtn_1.Checked = true
  if form.sel_op == 1 then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_equip_addprop(form, view_item)
    update_equip_randprop(form, view_item)
  elseif form.sel_op == 2 then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_equip_addprop(form, view_item)
    update_equip_direprop(form, view_item)
  elseif form.sel_op == 6 then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_equip_addphydef(form, view_item)
    update_equip_direphydef(form, view_item)
  elseif form.sel_op == 7 then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_equip_addphydef(form, view_item)
    update_equip_direphydef(form, view_item)
  end
end
function show_equip_name(form, item, lbl)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  local custom_name = nx_widestr("")
  if item:FindProp("CustomNameDesc") then
    custom_name = item:QueryProp("CustomNameDesc")
  end
  if custom_name ~= nx_widestr("") then
    local list = util_split_wstring(custom_name, nx_widestr("&"))
    if table.getn(list) > 0 then
      text = list[1]
    end
  else
    local name = item:QueryProp("ConfigID")
    local prefix_name = tips_manager:GetEquipScoreName(name, item)
    text = gui.TextManager:GetText(name)
    text = prefix_name .. text
  end
  if nx_is_valid(lbl) then
    lbl.Text = text
    return
  end
  form.lbl_item.Text = text
end
function show_equip_cost(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  form.mltbox_cost:Clear()
  form.mltbox_cost_item:Clear()
  local gui = nx_value("gui")
  local money = form_attribute:GetMoney(form.sel_op, item)
  gui.TextManager:Format_SetIDName("ui_recast_cost")
  gui.TextManager:Format_AddParam(money)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_cost:AddHtmlText(text, -1)
  local item_id = form_attribute:GetCostItem(form.sel_op, item)
  local num = form_attribute:GetCostItemNum(form.sel_op, item)
  local amount = GoodsGrid:GetItemCount(item_id)
  local text_num = nx_widestr("")
  if nx_int(amount) <= nx_int(0) or nx_int(amount) >= nx_int(num) then
    local num = form_attribute:GetCostItemNum(form.sel_op, item)
    gui.TextManager:Format_SetIDName("ui_recast_costitem")
    gui.TextManager:Format_AddParam(nx_int(num))
    text_num = gui.TextManager:Format_GetText()
  else
    local price = get_ticket_price(item_id)
    local need_money = nx_int(num - amount) * nx_int(price)
    gui.TextManager:Format_SetIDName("ui_recast_costitem_money")
    gui.TextManager:Format_AddParam(nx_int(amount))
    gui.TextManager:Format_AddParam(nx_int(need_money))
    text_num = gui.TextManager:Format_GetText()
  end
  form.mltbox_cost_item:AddHtmlText(text_num, -1)
end
function get_ticket_price(ticket)
  local ini = get_ini(TICKET_PRICE_INI, true)
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(ticket))
  if index < 0 then
    return 0
  end
  local money = ini:ReadInteger(index, "money", 0)
  return money
end
function show_equip_addprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_zb
  if not nx_is_valid(item) then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local mltbox = form.mltbox_value
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  local equipprop_table = form_attribute:GetEquipAddPropInfo(item)
  local size = table.getn(equipprop_table)
  for i = 1, size do
    mltbox:AddHtmlText(equipprop_table[i], -1)
  end
end
function update_equip_randprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= 1 then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local prop_table = {}
  prop_table[1] = form_attribute:GetMaxRandPropByConfigId(item, "SpiAdd")
  prop_table[2] = form_attribute:GetMaxRandPropByConfigId(item, "DexAdd")
  prop_table[3] = form_attribute:GetMaxRandPropByConfigId(item, "StaAdd")
  prop_table[4] = form_attribute:GetMaxRandPropByConfigId(item, "StrAdd")
  prop_table[5] = form_attribute:GetMaxRandPropByConfigId(item, "IngAdd")
  local gui = nx_value("gui")
  local index = 1
  local mltbox = form.mltbox_max
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  for i, packid in pairs(prop_table) do
    if 0 < packid then
      local text_id = "tips_proppack_" .. nx_string(packid)
      mltbox:AddHtmlText(gui.TextManager:GetText(text_id), -1)
      index = index + 1
    end
  end
end
function update_equip_direprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= 2 then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local gui = nx_value("gui")
  local prop_table = {}
  local pos = 1
  local prop_num = form_attribute:GetEquipAddPropNum(item)
  for i = 0, prop_num - 1 do
    local packid = form_attribute:GetMaxDirePropByConfigId(item, i)
    if 0 < packid then
      prop_table[pos] = packid
      pos = pos + 1
    end
  end
  local index = 1
  local mltbox = form.mltbox_max
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  for i, prop_id in pairs(prop_table) do
    local text_id = "tips_proppack_" .. nx_string(prop_id)
    mltbox:AddHtmlText(gui.TextManager:GetText(text_id), -1)
    index = index + 1
  end
end
function update_result_prop(form)
  if not nx_is_valid(form) then
    return
  end
end
function trans_price(price)
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  return price_ding, price_liang, price_wen
end
function show_dialog_tip(form)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return nx_null()
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return nx_null()
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(form.sel_view))
  local gui = nx_value("gui")
  if not nx_is_valid(view) then
    return nx_null()
  end
  local viewobj = view:GetViewObj(nx_string(form.sel_index))
  if not nx_is_valid(viewobj) then
    return nx_null()
  end
  if form.cost_type == 1 then
    gui.TextManager:Format_SetIDName("recast_random_tip")
  elseif form.cost_type == 2 then
    local item_id = form_attribute:GetCostItem(form.sel_op, viewobj)
    local item_num = form_attribute:GetCostItemNum(form.sel_op, viewobj)
    local amount = GoodsGrid:GetItemCount(item_id)
    if nx_int(amount) <= nx_int(0) then
      return nx_null()
    end
    if nx_int(amount) >= nx_int(item_num) then
      gui.TextManager:Format_SetIDName("recast_random_tip_ticket")
    else
      gui.TextManager:Format_SetIDName("recast_random_tip_ticket_1")
    end
  end
  local op_name = nx_widestr("")
  if form.sel_op == 1 then
    op_name = gui.TextManager:GetText("ui_recast_equip_random")
  elseif form.sel_op == 2 then
    op_name = gui.TextManager:GetText("ui_recast_equip_random_dire")
  elseif form.sel_op == 6 then
    op_name = gui.TextManager:GetText("ui_recast_equip_random_def")
  elseif form.sel_op == 7 then
    op_name = gui.TextManager:GetText("ui_recast_equip_random_parry")
  elseif form.sel_op == 8 then
    gui.TextManager:Format_SetIDName("zhuishi_random_tip")
    op_name = gui.TextManager:GetText("ui_recast_equip_random_life")
  end
  if form.sel_op ~= 8 then
    gui.TextManager:Format_AddParam(op_name)
  end
  local bcan = false
  if form.cost_type == 1 then
    local money_type = form_attribute:GetMoneyType(form.sel_op, viewobj)
    local money_value = form_attribute:GetMoney(form.sel_op, viewobj)
    if money_type == -1 or money_value == -1 then
      return nx_null()
    end
    gui.TextManager:Format_AddParam(money_value)
    bcan = true
  elseif form.cost_type == 2 then
    local item_id = form_attribute:GetCostItem(form.sel_op, viewobj)
    local item_num = form_attribute:GetCostItemNum(form.sel_op, viewobj)
    local amount = GoodsGrid:GetItemCount(item_id)
    if nx_int(amount) >= nx_int(item_num) then
      gui.TextManager:Format_AddParam(nx_int(item_num))
    else
      local price = get_ticket_price(item_id)
      local need_money = nx_int(item_num - amount) * nx_int(price)
      gui.TextManager:Format_AddParam(nx_int(amount))
      gui.TextManager:Format_AddParam(nx_int(need_money))
    end
    bcan = true
  end
  if bcan ~= true then
    return nx_null()
  end
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_attribute")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  return dialog
end
function on_btn_equip_parry_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == RECAST_EQUIP_DEFEND_PF then
    return
  end
  local check_suc = check_change_btn(form)
  if check_suc ~= true then
    set_btn_focusstatus(form)
    return
  end
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  end
  clearform(form)
  form.sel_op = RECAST_EQUIP_DEFEND_PF
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_base_parry")
  form.lbl_title_1.Text = text
  text = gui.TextManager:GetText("ui_recast_equip_max_parry")
  form.lbl_title_2.Text = text
end
function on_btn_equip_parry_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_equip_parry_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_equip_random_parry_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
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
  local index = 1
  local mltbox = form.mltbox_result
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  for i, value in pairs(show_table) do
    local text_id = "tips_proppack_" .. nx_string(value)
    mltbox:AddHtmlText(gui.TextManager:GetText(text_id), -1)
    index = index + 1
  end
  show_equip_name(form, view_item)
  show_equip_cost(form, view_item)
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
  local name = nx_widestr("")
  if form.sel_op == 1 or form.sel_op == 2 or form.sel_op == 6 then
    name = gui.TextManager:GetText("recast_equip")
  end
  custom_sysinfo(1, 1, 1, 2, "recast_change_tip", name)
  form.is_change = false
  form.mltbox_result:Clear()
  form.btn_ok.Enabled = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  if form.sel_op == 1 or form.sel_op == 2 or form.sel_op == 8 then
    show_equip_addprop(form, view_item)
    show_equip_cost(form, view_item)
  elseif form.sel_op == 6 or form.sel_op == 7 then
    show_equip_addphydef(form, view_item)
    show_equip_cost(form, view_item)
  end
end
function open_form()
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCITON_RECAST_EQUIP)
  if open ~= true then
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) or form.Visible then
  else
    form:Show()
    form.Visible = true
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
    local name = nx_widestr("")
    if form.sel_op == 1 or form.sel_op == 2 then
      name = gui.TextManager:GetText("recast_equip")
    end
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
  local grid = form.imagegrid_zb
  nx_execute("custom_sender", "custom_msg_recast_unlock", form.sel_view, form.sel_index, form.sel_op)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
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
function CheckCurFuncStatus(cur_op)
  if cur_op ~= RECAST_EQUIP_RAND and cur_op ~= RECAST_EQUIP_DIRE and cur_op ~= RECAST_EQUIP_DEFEND and cur_op ~= RECAST_EQUIP_DEFEND_PF then
    return false
  end
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return false
  end
  return SwitchManager:CheckSwitchEnable(ST_FUNCITON_RECAST_EQUIP)
end
function show_equip_addphydef(form, equip)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(equip) then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local mltbox = form.mltbox_value
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  local equipprop_table = form_attribute:GetEquipAddPhyDefInfo(equip)
  local size = table.getn(equipprop_table)
  for i = 1, size do
    mltbox:AddHtmlText(equipprop_table[i], -1)
  end
end
function update_equip_direphydef(form, equip)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(equip) then
    return
  end
  if form.sel_op ~= 6 and form.sel_op ~= 7 then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local gui = nx_value("gui")
  local prop_table = {}
  local pos = 1
  local prop_num = form_attribute:GetEquipAddPropNum(equip)
  for i = 0, prop_num - 1 do
    local packid = form_attribute:GetMaxEquipAddPhyDef(equip, form.sel_op, i)
    if 0 < packid then
      prop_table[pos] = packid
      pos = pos + 1
    end
  end
  local index = 1
  local mltbox = form.mltbox_max
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  for i, prop_id in pairs(prop_table) do
    local text_id = "tips_proppack_" .. nx_string(prop_id)
    mltbox:AddHtmlText(gui.TextManager:GetText(text_id), -1)
    index = index + 1
  end
end
function on_rbtn_1_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.cost_type = 1
  end
end
function on_rbtn_2_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.cost_type = 2
  end
end
function on_rbtn_2_get_capture(rbtn)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetText("ui_recast_costitem_tip")
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(text, x, y, -1, "0-0")
  end
end
function on_rbtn_2_lost_capture(rbtn)
  nx_execute("tips_game", "hide_tip")
end
