require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_life\\form_recast_attribute_weapon"
local RECAST_TYPE_WEAPON_RAND = 3
local RECAST_TYPE_WEAPON_DIRE = 4
local RECAST_TYPE_SKILL_RAND = 5
function on_main_form_init(form)
  form.sel_op = -1
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  form.Fixed = false
end
function on_main_form_open(form)
  load_ini(form)
  clearform(form)
  local btn_rand = form.btn_weapon_rand
  local btn_dire = form.btn_weapon_dire
  local btn_skill = form.btn_skill_random
  form.rand_normal = btn_rand.NormalImage
  form.dier_normal = btn_dire.NormalImage
  form.skill_normal = btn_skill.NormalImage
  on_btn_weapon_rand_click(form.btn_weapon_rand)
  form.btn_ok.Enabled = false
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  if form.is_change then
    local name = nx_widestr("")
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
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
  local btn_rand = form.btn_weapon_rand
  local btn_dire = form.btn_weapon_dire
  local btn_skill = form.btn_skill_random
  btn_rand.NormalImage = form.rand_normal
  btn_dire.NormalImage = form.dier_normal
  btn_skill.NormalImage = form.skill_normal
  if form.sel_op == RECAST_TYPE_WEAPON_RAND then
    btn_rand.NormalImage = btn_rand.FocusImage
  elseif form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    btn_dire.NormalImage = btn_dire.FocusImage
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    btn_skill.NormalImage = btn_skill.FocusImage
  end
end
function on_btn_weapon_rand_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == RECAST_TYPE_WEAPON_RAND then
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
  form.sel_op = RECAST_TYPE_WEAPON_RAND
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local title_1 = gui.TextManager:GetText("ui_recast_weapon_base_0")
  local title_2 = gui.TextManager:GetText("ui_recast_weapon_random_attribute_0")
  form.lbl_title_src_1.Text = title_1
  form.lbl_title_max_1.Text = title_2
  form.mltbox_max_1.Visible = true
  form.mltbox_skill_1.Visible = false
end
function on_btn_weapon_rand_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_weapon_rand_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_weapon_random_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_btn_weapon_dire_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == RECAST_TYPE_WEAPON_DIRE then
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
  form.sel_op = RECAST_TYPE_WEAPON_DIRE
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local title_1 = gui.TextManager:GetText("ui_recast_weapon_base_0")
  local title_2 = gui.TextManager:GetText("ui_recast_weapon_random_attribute")
  form.lbl_title_src_1.Text = title_1
  form.lbl_title_max_1.Text = title_2
  form.mltbox_max_1.Visible = true
  form.mltbox_skill_1.Visible = false
end
function on_btn_weapon_dire_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_weapon_dire_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_weapom_random_dire_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
end
function on_btn_skill_random_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
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
  form.sel_op = RECAST_TYPE_SKILL_RAND
  set_btn_focusstatus(form)
  local gui = nx_value("gui")
  local title_1 = gui.TextManager:GetText("ui_recast_skill_present")
  local title_2 = gui.TextManager:GetText("ui_recast_skill_random")
  form.lbl_title_src_1.Text = title_1
  form.lbl_title_max_1.Text = title_2
  form.mltbox_max_1.Visible = false
  form.mltbox_skill_1.Visible = true
end
function on_btn_skill_random_lost_capture(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_skill_random_get_capture(btn)
  local x = btn.AbsLeft
  local y = btn.AbsTop
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_recast_skill_random_dire_tips")
  nx_execute("tips_game", "show_text_tip", text, x, y)
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
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
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
  local view_item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local open = CheckCurFuncStatus(form.sel_op)
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
  local dialog = show_dialog_tip(form)
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_attribute_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_msg_recast_randprop", form.sel_view, form.sel_index, form.sel_op, nx_int(1))
    end
  end
end
function check_equip_item(form, item, bfirst)
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
  local gui = nx_value("gui")
  if form.sel_op >= 1 and form.sel_op <= 7 then
    local isnewitem = item:QueryProp("NewWorldItem")
    if isnewitem == 1 then
      custom_sysinfo(1, 1, 1, 2, "failed_recast_newworld002")
      return false
    end
  end
  local item_type = item:QueryProp("ItemType")
  if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    if item_type < ITEMTYPE_WEAPON_MIN or item_type > ITEMTYPE_WEAPON_QIMEN_MAX then
      local text = gui.TextManager:GetText("recast_weapon")
      custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
      return false
    end
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND and (item_type < ITEMTYPE_EQUIP_MIN or item_type > ITEMTYPE_EQUIP_MAX) then
    local text = nx_widestr("")
    if bfirst ~= nil and bfirst == true then
      text = gui.TextManager:GetText("recast_all")
    else
      text = get_cur_equip_text(form, item)
    end
    custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
    return false
  end
  local isCan = form_attribute:CanEquipRecast(item, form.sel_op)
  if isCan ~= true then
    local text = nx_widestr("")
    if form.sel_op == RECAST_TYPE_SKILL_RAND then
      local row = item:GetRecordRows("SkillModifyPackRec")
      if row <= 0 then
        custom_sysinfo(1, 1, 1, 2, "recast_failed_wuzhaoshi")
        return false
      elseif bfirst ~= nil and bfirst == true then
        text = gui.TextManager:GetText("recast_all")
      else
        text = get_cur_equip_text(form, item)
      end
    elseif form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      text = gui.TextManager:GetText("recast_weapon")
    end
    custom_sysinfo(1, 1, 1, 2, "recast_failed_equip", text)
    return false
  end
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
    isCan = form_attribute:GetCanScopeCount(item, RECAST_TYPE_SKILL_RAND)
    if isCan ~= true then
      local text = get_cur_equip_text(form, item)
      custom_sysinfo(1, 1, 1, 2, "recast_noexist_tip", text)
      return false
    end
  end
  local bind_status = item:QueryProp("BindStatus")
  if nx_int(bind_status) <= nx_int(0) then
    local text = nx_widestr("")
    if form.sel_op == RECAST_TYPE_SKILL_RAND then
      text = get_cur_equip_text(form, item)
    elseif form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      text = gui.TextManager:GetText("recast_weapon")
    end
    custom_sysinfo(1, 1, 1, 2, "recast_failed_notruss_tip", text)
    return false
  end
  local color_level = item:QueryProp("ColorLevel")
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
    if nx_number(color_level) ~= 4 and nx_number(color_level) ~= 5 and nx_number(color_level) ~= 6 then
      custom_sysinfo(1, 1, 1, 2, "recast_failed_pinzhibugou")
      return false
    end
  elseif (form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE) and nx_number(color_level) ~= 5 and nx_number(color_level) ~= 6 then
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
  if money_type < 0 or money_value < 0 then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_nomoney_tip")
    return false
  end
  local isCan = capital:CanDecCapital(nx_int(money_type), nx_int64(money_value))
  if isCan ~= true then
    custom_sysinfo(1, 1, 1, 2, "recast_failed_nomoney_tip")
  end
  return isCan
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
    return
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
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
    end
    custom_sysinfo(1, 1, 1, 2, "recast_nochange_tip", name)
    return
  end
  local op_name = nx_widestr("")
  if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    op_name = gui.TextManager:GetText("recast_weapon")
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    op_name = get_cur_equip_text(form)
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
  suecceed = check_equip_item(form, item, true)
  if suecceed == false then
    gameHand:ClearHand()
    return
  end
  if form.is_change then
    local name = nx_widestr("")
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
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
    gui.GameHand:SetHand("recast_weapon", photo, "", "", "", "")
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
    local name = nx_widestr("")
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
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
function on_mltbox_skill_1_mouseout_hyperlink(mltbox, selIndex, link)
  nx_execute("tips_game", "hide_tip")
end
function on_mltbox_skill_1_mousein_hyperlink(mltbox, selIndex, link, x, y)
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local skill_index = mltbox:GetItemKeyByIndex(selIndex)
  local skill_Detail_table = form_attribute:GetSkillPropDetailInfo(form.sel_op, skill_index)
  local text = nx_widestr("")
  local size = table.getn(skill_Detail_table)
  for i = 1, size do
    local strDetail = skill_Detail_table[i]
    text = text .. strDetail .. nx_widestr("<br>")
  end
  local gui = nx_value("gui")
  local mouseX, mouseY = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, mouseX + 32, mouseY - 20, 230)
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
  form_attribute:LoadWeaponResouce()
  form_attribute:LoadCostResouce()
  nx_set_value("form_recast_attribute", form_attribute)
end
function clearform(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_wq
  grid:Clear()
  form.lbl_item.Text = nx_widestr("")
  form.mltbox_cost:Clear()
  form.mltbox_src_1:Clear()
  form.mltbox_max_1:Clear()
  form.mltbox_skill_1:Clear()
  form.mltbox_result:Clear()
  form.sel_index = -1
  form.sel_view = -1
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
  if form.sel_op == RECAST_TYPE_WEAPON_RAND then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_weapon_addprop(form, view_item)
    update_weapon_randprop(form, view_item)
  elseif form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_weapon_addprop(form, view_item)
    update_weapon_direprop(form, view_item)
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    show_equip_name(form, view_item)
    show_equip_cost(form, view_item)
    show_equip_zhaoshi(form, view_item)
    show_equip_rand_zhaoshi(form, view_item)
  end
end
function show_equip_name(form, item)
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
  form.lbl_item.Text = text
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
function show_weapon_addprop(form, item)
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
  local equipprop_table = form_attribute:GetWeaponAddPropInfo(item)
  local size = table.getn(equipprop_table)
  for i = 1, size do
    mltbox:AddHtmlText(equipprop_table[i], -1)
  end
end
function update_weapon_randprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= RECAST_TYPE_WEAPON_RAND then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local prop_table = {}
  prop_table[1] = form_attribute:GetWeaponMaxPropByConfigId(item, "MeleeDamage")
  prop_table[2] = form_attribute:GetWeaponMaxPropByConfigId(item, "AIPhyDef")
  prop_table[3] = form_attribute:GetWeaponMaxPropByConfigId(item, "MinShotDamage")
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
function update_weapon_direprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= RECAST_TYPE_WEAPON_DIRE then
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
    local packid = form_attribute:GetWeaponMaxDirePropByConfigId(item, i)
    if 0 < packid then
      prop_table[pos] = packid
      pos = pos + 1
    end
  end
  local index = 1
  local mltbox = form.mltbox_max_1
  mltbox:Clear()
  for i, prop_id in pairs(prop_table) do
    local text_id = "tips_proppack_" .. nx_string(prop_id)
    local text = gui.TextManager:GetText(text_id)
    mltbox:AddHtmlText(text, -1)
  end
end
function show_equip_zhaoshi(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= RECAST_TYPE_SKILL_RAND then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local mltbox = form.mltbox_src_1
  mltbox:Clear()
  mltbox.ShadowColor = "0,0,0,0"
  local gui = nx_value("gui")
  local equipskill_table = form_attribute:GetEquipSkillPropInfo(item)
  local size = table.getn(equipskill_table)
  for i = size, 1, -1 do
    mltbox:AddHtmlText(equipskill_table[i], -1)
  end
end
function show_equip_rand_zhaoshi(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if form.sel_op ~= RECAST_TYPE_SKILL_RAND then
    return
  end
  local form_attribute = nx_value("form_recast_attribute")
  if not nx_is_valid(form_attribute) then
    return
  end
  local skill_name_table = form_attribute:GetCanSkillNameInfo(item)
  local skill_index_table = form_attribute:GetCanSkillMaskInfo(item)
  local name_size = table.getn(skill_name_table)
  local index_size = table.getn(skill_index_table)
  if name_size ~= index_size then
    return
  end
  local mltbox = form.mltbox_skill_1
  mltbox:Clear()
  mltbox.LineHeight = 20
  local gui = nx_value("gui")
  for i = 1, name_size do
    local skill_name = skill_name_table[i]
    local skill_index = skill_index_table[i]
    if skill_name ~= "" and 0 < skill_index then
      local text_id = "recast_skill_" .. nx_string(skill_name)
      local text = gui.TextManager:GetText(text_id)
      mltbox:AddHtmlText(text, skill_index)
    end
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
  local money_type = form_attribute:GetMoneyType(form.sel_op, viewobj)
  local money_value = form_attribute:GetMoney(form.sel_op, viewobj)
  if money_type == -1 or money_value == -1 then
    return nx_null()
  end
  local text_ding = nx_widestr("")
  local text_liang = nx_widestr("")
  local text_wen = nx_widestr("")
  local moeny_ding, money_liang, money_wen = trans_price(money_value)
  if nx_number(money_ding) > nx_number(0) then
    local text = gui.TextManager:GetText("ui_ding")
    text_ding = nx_widestr(money_ding) .. text
  end
  if nx_number(money_liang) > nx_number(0) then
    local text = gui.TextManager:GetText("ui_liang")
    text_liang = nx_widestr(money_liang) .. text
  end
  if nx_number(money_wen) > nx_number(0) then
    local text = gui.TextManager:GetText("ui_wen")
    text_wen = nx_widestr(money_wen) .. text
  end
  local show_money = text_ding .. text_liang .. text_wen
  local op_name = nx_widestr("")
  if form.sel_op == RECAST_TYPE_WEAPON_RAND then
    op_name = gui.TextManager:GetText("ui_recast_weapon_random_0")
  elseif form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    op_name = gui.TextManager:GetText("ui_recast_weapon_random_dire")
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    op_name = gui.TextManager:GetText("ui_recast_skill_random_nor")
  end
  gui.TextManager:Format_SetIDName("recast_random_tip")
  gui.TextManager:Format_AddParam(op_name)
  gui.TextManager:Format_AddParam(money_value)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_attribute")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
  end
  return dialog
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
  if nx_int(op_type) == nx_int(5) then
    for i = num, 1, -1 do
      local pack_table = util_split_string(newpack_table[i], ",")
      local size = table.getn(pack_table)
      if size == 2 and pack_table[2] ~= "" then
        show_table[pos] = pack_table[2]
        pos = pos + 1
      end
    end
  else
    for i = 1, num do
      local pack_table = util_split_string(newpack_table[i], ",")
      local size = table.getn(pack_table)
      if size == 2 and pack_table[2] ~= "" then
        show_table[pos] = pack_table[2]
        pos = pos + 1
      end
    end
  end
  local mltbox = form.mltbox_result
  mltbox:Clear()
  local text_prefix = ""
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
    text_prefix = "tips_skillpack_"
    mltbox.ShadowColor = "0,0,0,0"
  elseif form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    text_prefix = "tips_proppack_"
    mltbox.ShadowColor = "0,255,0,0"
  end
  for i, value in pairs(show_table) do
    local text_id = text_prefix .. nx_string(value)
    local text = gui.TextManager:GetText(text_id)
    mltbox:AddHtmlText(text, -1)
  end
  show_equip_name(form, view_item)
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
  if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    name = gui.TextManager:GetText("recast_weapon")
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    name = get_cur_equip_text(form)
  end
  custom_sysinfo(1, 1, 1, 2, "recast_change_tip", name)
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
  if form.sel_op == RECAST_TYPE_SKILL_RAND then
    show_equip_zhaoshi(form, view_item)
  elseif form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    show_weapon_addprop(form, view_item)
  end
end
function open_form()
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_RECAST_WEAPON)
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
    if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
      name = gui.TextManager:GetText("recast_weapon")
    elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
      name = get_cur_equip_text(form)
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
  local grid = form.imagegrid_wq
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
function get_cur_equip_text(form, item)
  if not nx_is_valid(form) then
    return nx_widestr("")
  end
  local real_item = item
  if not nx_is_valid(real_item) then
    real_item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  end
  if not nx_is_valid(real_item) then
    return nx_widestr("")
  end
  local gui = nx_value("gui")
  local item_type = real_item:QueryProp("ItemType")
  local text = nx_widestr("")
  if form.sel_op == RECAST_TYPE_WEAPON_RAND or form.sel_op == RECAST_TYPE_WEAPON_DIRE then
    text = gui.TextManager:GetText("recast_weapon")
  elseif form.sel_op == RECAST_TYPE_SKILL_RAND then
    if item_type >= ITEMTYPE_WEAPON_MIN and item_type <= ITEMTYPE_WEAPON_QIMEN_MAX then
      text = gui.TextManager:GetText("recast_weapon")
    else
      text = gui.TextManager:GetText("recast_equip")
    end
  end
  return text
end
function CheckCurFuncStatus(cur_op)
  if cur_op ~= RECAST_TYPE_WEAPON_RAND and cur_op ~= RECAST_TYPE_WEAPON_DIRE and cur_op ~= RECAST_TYPE_SKILL_RAND then
    return false
  end
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return false
  end
  return SwitchManager:CheckSwitchEnable(ST_FUNCTION_RECAST_WEAPON)
end
