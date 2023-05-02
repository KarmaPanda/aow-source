require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
local FORM_NAME = "form_stage_main\\form_life\\form_treasure_upgrade"
local FORM_TREASURE_RESET = "form_stage_main\\form_life\\form_treasure_reset"
function on_main_form_active(form)
end
function on_main_form_init(form)
  form.sel_view = -1
  form.sel_index = -1
  form.stuff_view = -1
  form.stuff_index = -1
  form.Fixed = true
end
function on_main_form_open(form)
  local form_tersure = nx_value("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_destroy(form_tersure)
  end
  form_tersure = nx_create("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_set_value("form_recast_tersure", form_tersure)
  end
  form.btn_upgrade.Enabled = false
  form.lbl_title.Text = form.btn_equip_up.Text
  form.Width = 650
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_treasure_hht_cost")
  gui.TextManager:Format_AddParam("0")
  form.lbl_upgrade_minor.Text = gui.TextManager:Format_GetText()
  change_form_size()
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  if form.stuff_view ~= -1 and form.stuff_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.stuff_view, form.stuff_index)
  end
  nx_destroy(form)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_life\\form_treasure_upgrade")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
end
function on_btn_upgrade_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not check_player_status() then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(item) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  if not form_tersure:CanUpgrade(item) then
    return
  end
  local gui = nx_value("gui")
  local text
  local level = item:QueryProp("Level")
  if level == 64 then
    text = gui.TextManager:GetText("ui_recast_treasrue_queding")
  elseif level == 84 then
    text = gui.TextManager:GetText("ui_recast_treasrue_queding_1")
  elseif level == 94 then
    text = gui.TextManager:GetText("ui_recast_treasrue_queding_2")
  else
    return
  end
  if level ~= 94 and (form.sel_view == -1 or form.sel_index == -1 or form.stuff_view == -1 or form.stuff_index == -1) then
    custom_sysinfo(1, 1, 1, 2, "9212")
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "treasure_upgrade")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "treasure_upgrade_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_upgrade_tersure", form.sel_view, form.sel_index, form.stuff_view, form.stuff_index)
    end
  end
end
function on_imagegrid_bw_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not check_player_status() then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return
  end
  if gui.GameHand.Type ~= GHT_VIEWITEM then
    gui.GameHand:ClearHand()
    return
  end
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    gui.GameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    custom_sysinfo(1, 1, 1, 2, "1500")
    gui.GameHand:ClearHand()
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gui.GameHand:ClearHand()
    return
  end
  if index == 0 then
    if form.sel_view == src_viewid and form.sel_index == src_pos then
      gui.GameHand:ClearHand()
      return
    end
    if not form_tersure:CanUpgrade(item) then
      custom_sysinfo(1, 1, 1, 2, "9211")
      gui.GameHand:ClearHand()
      return
    end
    if form.sel_view ~= -1 and form.sel_index ~= -1 then
      nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
    end
    form.sel_view = src_viewid
    form.sel_index = src_pos
    nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
    local level = item:QueryProp("Level")
    if level == 94 then
      form.btn_upgrade.Enabled = true
      form.lbl_tips.Text = util_text("ui_treasure_hht2")
      form.lbl_upgrade_minor.Visible = false
    else
      form.lbl_tips.Text = util_text("ui_treasure_hht1")
      form.lbl_upgrade_minor.Visible = true
    end
  elseif index == 1 then
    local config_id = item:QueryProp("ConfigID")
    if config_id ~= "gn_Procon_001" then
      custom_sysinfo(1, 1, 1, 2, "9212")
      gui.GameHand:ClearHand()
      return
    end
    if form.stuff_view ~= -1 and form.stuff_index ~= -1 then
      nx_execute("custom_sender", "custom_tersure_unlock", form.stuff_view, form.stuff_index)
    end
    if amount < 5 then
      custom_sysinfo(1, 1, 1, 2, "9212")
      gui.GameHand:ClearHand()
      return
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_treasure_hht_cost")
    gui.TextManager:Format_AddParam(nx_string(amount))
    form.lbl_upgrade_minor.Text = gui.TextManager:Format_GetText()
    form.lbl_upgrade_minor.ForeColor = "255,255,255,255"
    form.stuff_view = src_viewid
    form.stuff_index = src_pos
  end
  grid:AddItem(index, photo, "", amount, -1)
  gui.GameHand:ClearHand()
  if form.sel_view ~= -1 and form.sel_index ~= -1 and form.stuff_view ~= -1 and form.stuff_index ~= -1 then
    form.btn_upgrade.Enabled = true
  end
end
function on_imagegrid_bw_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if index == 0 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
    form.sel_view = -1
    form.sel_index = -1
  elseif index == 1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.stuff_view, form.stuff_index)
    form.stuff_view = -1
    form.stuff_index = -1
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_treasure_hht_cost")
    gui.TextManager:Format_AddParam("0")
    form.lbl_upgrade_minor.Text = gui.TextManager:Format_GetText()
    form.lbl_upgrade_minor.ForeColor = "255,255,0,0"
  end
  grid:DelItem(index)
  form.btn_upgrade.Enabled = false
end
function on_imagegrid_bw_drag_move(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local sel_view, sel_index
  if index == 0 then
    sel_view = form.sel_view
    sel_index = form.sel_index
  elseif index == 1 then
    sel_view = form.stuff_view
    sel_index = form.stuff_index
  end
  if sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(sel_view), nx_string(sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("recast_weapon", photo, "", "", "", "")
  end
end
function on_imagegrid_bw_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local sel_view, sel_index
  if index == 0 then
    sel_view = form.sel_view
    sel_index = form.sel_index
  elseif index == 1 then
    sel_view = form.stuff_view
    sel_index = form.stuff_index
  end
  if sel_view ~= VIEWPORT_EQUIP_TOOL then
    return
  end
  local view_item = game_client:GetViewObj(nx_string(sel_view), nx_string(sel_index))
  if not nx_is_valid(view_item) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", view_item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imagegrid_bw_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_equip_up_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.groupbox_upgrade.Visible = true
  form.lbl_title.Text = self.Text
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function get_photo_amont(item)
  local photo = ""
  local amount = 0
  if nx_is_valid(item) then
    photo = nx_execute("util_static_data", "query_equip_photo_by_sex", item)
    amount = item:QueryProp("Amount")
  end
  return photo, amount
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
function open_form()
  if not check_player_status() then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_life\\form_treasure_reset", "add_sub_form", form, 1)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function clear_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.sel_view = -1
  form.sel_index = -1
  form.stuff_view = -1
  form.stuff_index = -1
  form.imagegrid_bw:Clear()
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_treasure_hht_cost")
  gui.TextManager:Format_AddParam("0")
  form.lbl_upgrade_minor.Text = gui.TextManager:Format_GetText()
  form.lbl_upgrade_minor.ForeColor = "255,255,0,0"
end
