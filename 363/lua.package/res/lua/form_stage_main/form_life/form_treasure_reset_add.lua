require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("util_gui")
local NORMAL_TERSURE_REFRESH_SKILL = 12
local SAVE_NORMAL_REFRESH_SKILL_VALUE = 13
local ST_FUNCTION_NORMAL_RESET = 231
function on_main_form_init(form)
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  form.Fixed = false
end
function on_main_form_active(form)
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
  clearform(form)
  form.groupbox_notice.Visible = false
  form.Width = 645
  change_form_size()
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_tersure = nx_value("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_destroy(form_tersure)
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  nx_destroy(form)
end
function on_imagegrid_zb_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if form.is_change then
    local text = gui.TextManager:GetText("ui_treasure_recast_1")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gameHand = gui.GameHand
  if gameHand:IsEmpty() then
    return
  end
  if gameHand.Type ~= GHT_VIEWITEM then
    gameHand:ClearHand()
    return
  end
  if not check_player_status() then
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
    custom_sysinfo(1, 1, 1, 2, "9215")
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    gameHand:ClearHand()
    return
  end
  local lock_status = item:QueryProp("LockStatus")
  if 0 < lock_status then
    custom_sysinfo(1, 1, 1, 2, "1500")
    gameHand:ClearHand()
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    gameHand:ClearHand()
    return
  end
  local tersure_type = item:QueryProp("TersureType")
  if tersure_type < 0 or 2 < tersure_type then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_in_failed_1")
    return
  end
  if not item:FindRecord("RandomPropRec") or not item:FindRecord("RandomSkillRec") then
    return
  end
  local level = item:QueryProp("ColorLevel")
  if level ~= 6 and level ~= 5 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_in_failed_1")
    return
  end
  local bind_status = item:QueryProp("BindStatus")
  if bind_status == 0 then
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_in_failed_2")
    gameHand:ClearHand()
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  clearform(form)
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view = src_viewid
  form.sel_index = src_pos
  form.is_change = false
  form.btn_start.Enabled = true
  nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
  gameHand:ClearHand()
  show_equip_addprop(form, item)
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
    local text = gui.TextManager:GetText("ui_treasure_recast_1")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
    if res ~= "ok" then
      return
    end
  end
  nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
end
function on_imagegrid_zb_drag_move(grid, index)
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
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("recast_weapon", photo, "", "", "", "")
  end
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
function on_imagegrid_zb_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_close_click(self)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.is_change then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_treasure_reset_quit")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    if nx_is_valid(dialog) then
      local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
      if res == "ok" then
        form:Close()
      end
    end
  else
    form:Close()
  end
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
  local item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(item) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  if not check_player_status() then
    return
  end
  local skill_type = -1
  if form.rbtn_jianghu.Checked then
    skill_type = 1
  end
  if form.rbtn_school.Checked then
    skill_type = 0
  end
  if skill_type < 0 then
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_select")
    return
  end
  local text = util_text("ui_treasure_reset_begin_2")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_refresh_tersure", NORMAL_TERSURE_REFRESH_SKILL, form.sel_view, form.sel_index, skill_type + 2)
    end
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_treasure_reset")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_save_tersure_pro", SAVE_NORMAL_REFRESH_SKILL_VALUE, form.sel_view, form.sel_index)
      form.mltbox_result_pro:Clear()
      form.mltbox_result_skill:Clear()
      form.is_change = false
      form.btn_ok.Enabled = false
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset_add")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
end
function clearform(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_zb
  grid:Clear()
  form.mltbox_result_pro:Clear()
  form.mltbox_result_skill:Clear()
  form.mltbox_pro:Clear()
  form.mltbox_skill:Clear()
  form.lbl_name.Text = nx_widestr("")
  form.sel_index = -1
  form.sel_view = -1
  form.is_change = false
  form.btn_ok.Enabled = false
  form.btn_start.Enabled = false
end
function show_equip_addprop(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  if not item:FindRecord("RandomPropRec") or not item:FindRecord("RandomSkillRec") then
    return
  end
  local config_id = item:QueryProp("ConfigID")
  form.lbl_name.Text = util_text(config_id)
  form.mltbox_pro:Clear()
  form.mltbox_skill:Clear()
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomPropRec", row_index, 0)
    local value = item:QueryRecord("RandomPropRec", row_index, 1)
    local info = form_tersure:GetPropText(id, nx_int(value))
    if info ~= nx_widestr("") then
      form.mltbox_pro:AddHtmlText(info, -1)
    end
  end
  local row_count = item:GetRecordRows("RandomSkillRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomSkillRec", row_index, 0)
    local skill_id = item:QueryRecord("RandomSkillRec", row_index, 1)
    local value = item:QueryRecord("RandomSkillRec", row_index, 2)
    local info = form_tersure:GetSkillText(id, skill_id, nx_int(value))
    if info ~= nx_widestr("") then
      form.mltbox_skill:AddHtmlText(info, -1)
    end
  end
end
function show_tersuer_result(sub_type)
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset_add")
  if not nx_is_valid(form) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  if 9 == sub_type then
    nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
    show_equip_addprop(form, item)
    return
  end
  if not (item:FindRecord("TempTersureRec") and item:FindRecord("RandomSkillRec")) or not item:FindRecord("RandomPropRec") then
    return
  end
  form.mltbox_result_pro:Clear()
  form.mltbox_result_skill:Clear()
  local row_count = item:GetRecordRows("TempTersureRec")
  for row_index = 0, row_count - 1 do
    local type = item:QueryRecord("TempTersureRec", row_index, 0)
    local id = item:QueryRecord("TempTersureRec", row_index, 1)
    local value = item:QueryRecord("TempTersureRec", row_index, 2)
    if nx_string(type) == "1" then
      local info = form_tersure:GetPropText(id, nx_int(value))
      if info ~= nx_widestr("") then
        form.mltbox_result_pro:AddHtmlText(info, -1)
      end
    elseif nx_string(type) == "0" then
      local skill_id = item:QueryRecord("TempTersureRec", row_index, 3)
      local info = form_tersure:GetSkillText(id, skill_id, nx_int(value))
      if info ~= nx_widestr("") then
        form.mltbox_result_skill:AddHtmlText(info, -1)
      end
    end
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomPropRec", row_index, 0)
    local value = item:QueryRecord("RandomPropRec", row_index, 1)
    local info = form_tersure:GetPropText(id, nx_int(value))
    if info ~= nx_widestr("") then
      form.mltbox_result_pro:AddHtmlText(info, -1)
    end
  end
  form.btn_ok.Enabled = true
  form.is_change = true
end
function show_tersuer_max_value(...)
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset_add")
  if not nx_is_valid(form) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  form.mltbox_max:Clear()
  if not item:FindRecord("RandomPropRec") then
    return
  end
  if not item:FindRecord("RandomSkillRec") then
    return
  end
  local index = 1
  local count = table.getn(arg)
  local text = nx_widestr("")
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomPropRec", row_index, 0)
    if index > count then
      break
    end
    local info = form_tersure:GetPropText(id, nx_int(arg[index]))
    if info ~= nx_widestr("") then
      text = text .. info .. nx_widestr("<br>")
    end
    index = index + 1
  end
  row_count = item:GetRecordRows("RandomSkillRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomSkillRec", row_index, 0)
    local skill_id = item:QueryRecord("RandomSkillRec", row_index, 1)
    if count < index then
      break
    end
    local info = form_tersure:GetSkillText(id, skill_id, nx_int(arg[index]))
    if info ~= nx_widestr("") then
      text = text .. info .. nx_widestr("<br>")
    end
    index = index + 1
  end
  form.mltbox_max:AddHtmlText(text, -1)
end
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(231) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("7109"), 2)
    end
  end
  if not check_player_status() then
    return false
  end
  local form_reset = nx_value("form_stage_main\\form_life\\form_treasure_reset")
  if nx_is_valid(form_reset) then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset", "on_btn_close_click", form_reset.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_treasure_reset_add", true, false)
  if not nx_is_valid(form) then
    return false
  end
  form:Show()
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
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.Width = 918
  form.groupbox_notice.Visible = true
  btn.Visible = false
  change_form_size()
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.Width = 645
  form.groupbox_notice.Visible = false
  form.btn_notice.Visible = true
  change_form_size()
end
