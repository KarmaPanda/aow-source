require("share\\view_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("util_gui")
local TERSURE_PROP_LOCK = 6
local TERSURE_PROP_UNLOCK = 7
local TERSURE_LOCK_REFRESH = 8
local SAVE_LOCK_REFRESH_VALUE = 9
local TERSURE_REFRESH_SKILL = 10
local SAVE_REFRESH_SKILL_VALUE = 11
local FORM_TREASURE_RESET = "form_stage_main\\form_life\\form_treasure_reset"
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
  form.rbtn_prop.Checked = true
  on_rbtn_prop_checked_changed(form.rbtn_prop)
  form.groupbox_notice.Visible = false
  form.groupbox_upgrade_notice.Visible = false
  form.btn_upgrade_notice.Visible = false
  form.Width = 650
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
  if not form_tersure:CanReset(item) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_in_failed")
    return
  end
  if not item:FindRecord("RandomPropRec") or not item:FindRecord("RandomSkillRec") then
    return
  end
  local level = item:QueryProp("ColorLevel")
  if level ~= 6 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "treasure_reset_in_failed")
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
  elseif nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_find_custom(form.sub_form, "is_change") and form.sub_form.is_change then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetText("ui_treasure_recast_1")
      local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
      if res ~= "ok" then
        return
      end
    end
    form.sub_form:Close()
    form:Close()
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
  if not form_tersure:CanReset(item) then
    return
  end
  if not check_player_status() then
    return
  end
  local msg_type = TERSURE_LOCK_REFRESH
  local text_id = "ui_treasure_reset_begin"
  local skill_type = -1
  if form.rbtn_skill.Checked then
    msg_type = TERSURE_REFRESH_SKILL
    text_id = "ui_treasure_reset_begin_1"
    if form.rbtn_school.Checked then
      skill_type = 0
    end
    if form.rbtn_jianghu.Checked then
      skill_type = 1
    end
    if skill_type < 0 then
      custom_sysinfo(1, 1, 1, 2, "treasure_reset_select")
      return
    end
  end
  local text = util_text(text_id)
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_refresh_tersure", msg_type, form.sel_view, form.sel_index, skill_type)
      form.btn_unlock.Enabled = false
      form.btn_lock.Enabled = false
    end
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  local msg_type = SAVE_LOCK_REFRESH_VALUE
  if form.rbtn_skill.Checked then
    msg_type = SAVE_REFRESH_SKILL_VALUE
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_treasure_reset")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_save_tersure_pro", msg_type, form.sel_view, form.sel_index)
      form.mltbox_result_lock_pro:Clear()
      form.mltbox_result_pro:Clear()
      form.mltbox_result_skill:Clear()
      form.mltbox_result_prop:Clear()
      form.is_change = false
      form.btn_ok.Enabled = false
    end
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset")
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
  form.mltbox_result_lock_pro:Clear()
  form.mltbox_result_pro:Clear()
  form.mltbox_result_skill:Clear()
  form.mltbox_lock_pro:Clear()
  form.mltbox_pro:Clear()
  form.mltbox_skill:Clear()
  form.mltbox_prop:Clear()
  form.mltbox_result_prop:Clear()
  form.lbl_name.Text = nx_widestr("")
  form.lbl_lock.Visible = false
  form.sel_index = -1
  form.sel_view = -1
  form.is_change = false
  form.btn_ok.Enabled = false
  form.btn_start.Enabled = false
  form.btn_lock.Enabled = false
  form.btn_unlock.Enabled = false
end
function rbtn_change(form, type)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_result_lock_pro:Clear()
  form.mltbox_result_pro:Clear()
  form.mltbox_result_skill:Clear()
  form.mltbox_desc:Clear()
  form.is_change = false
  form.btn_ok.Enabled = false
  form.btn_start.Enabled = true
  form.mltbox_desc:AddHtmlText(util_text("ui_treasure_reset_tip"), -1)
  if type == "skill" then
    form.btn_lock.Visible = false
    form.btn_unlock.Visible = false
  elseif type == "prop" then
    form.btn_lock.Visible = true
    form.btn_unlock.Visible = true
    local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
    if not nx_is_valid(item) then
      form.btn_lock.Enabled = false
      form.btn_unlock.Enabled = false
      return
    end
    local is_lock = false
    local row_count = item:GetRecordRows("RandomPropRec")
    for row_index = 0, row_count - 1 do
      local lock = item:QueryRecord("RandomPropRec", row_index, 2)
      if nx_int(lock) == nx_int(1) then
        is_lock = true
        break
      end
    end
    if is_lock then
      form.btn_lock.Enabled = false
      form.btn_unlock.Enabled = true
    else
      form.btn_lock.Enabled = true
      form.btn_unlock.Enabled = false
    end
  end
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  form.Width = 918
  form.groupbox_notice.Visible = true
  form.btn_notice_close.Visible = true
  form.btn_notice.Visible = false
  change_form_size()
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  form.Width = 650
  form.groupbox_notice.Visible = false
  form.btn_notice_close.Visible = false
  form.btn_notice.Visible = true
  change_form_size()
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
  form.mltbox_pro:Clear()
  form.mltbox_lock_pro:Clear()
  form.mltbox_skill:Clear()
  form.mltbox_prop:Clear()
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local id = item:QueryRecord("RandomPropRec", row_index, 0)
    local value = item:QueryRecord("RandomPropRec", row_index, 1)
    local info = form_tersure:GetPropText(id, nx_int(value))
    if info ~= nx_widestr("") then
      form.mltbox_prop:AddHtmlText(info, -1)
      if row_index < 2 then
        form.mltbox_lock_pro:AddHtmlText(info, -1)
      else
        form.mltbox_pro:AddHtmlText(info, -1)
      end
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
  local is_lock = false
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local lock = item:QueryRecord("RandomPropRec", row_index, 2)
    if nx_int(lock) == nx_int(1) then
      is_lock = true
      form.lbl_lock.Top = form.mltbox_pro.Top + 20 * (row_index - 2) + 7
      form.lbl_lock.Visible = true
      break
    end
  end
  local config_id = item:QueryProp("ConfigID")
  form.lbl_name.Text = util_text(config_id)
  if is_lock then
    form.btn_lock.Enabled = false
    form.btn_unlock.Enabled = true
  else
    form.btn_lock.Enabled = true
    form.btn_unlock.Enabled = false
    form.lbl_lock.Visible = false
  end
  if form.rbtn_skill.Checked then
    form.btn_lock.Enabled = false
    form.btn_unlock.Enabled = false
  end
end
function show_tersuer_result(sub_type)
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset")
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
  if 3 == sub_type or 7 == sub_type then
    nx_execute("custom_sender", "custom_tersure_lock", form.sel_view, form.sel_index)
    show_equip_addprop(form, item)
    return
  elseif 4 == sub_type then
    form.btn_unlock.Enabled = true
    form.btn_lock.Enabled = false
    local row_count = item:GetRecordRows("RandomPropRec")
    for row_index = 0, row_count - 1 do
      local lock = item:QueryRecord("RandomPropRec", row_index, 2)
      if nx_int(lock) == nx_int(1) then
        form.lbl_lock.Top = form.mltbox_pro.Top + 20 * (row_index - 2) + 7
        form.lbl_lock.Visible = true
        break
      end
    end
    return
  elseif 5 == sub_type then
    form.btn_unlock.Enabled = false
    form.btn_lock.Enabled = true
    form.lbl_lock.Visible = false
    return
  end
  if not (item:FindRecord("TempTersureRec") and item:FindRecord("RandomSkillRec")) or not item:FindRecord("RandomPropRec") then
    return
  end
  form.mltbox_result_lock_pro:Clear()
  form.mltbox_result_pro:Clear()
  form.mltbox_result_skill:Clear()
  form.mltbox_result_prop:Clear()
  local row_count = item:GetRecordRows("TempTersureRec")
  for row_index = 0, row_count - 1 do
    local type = item:QueryRecord("TempTersureRec", row_index, 0)
    local id = item:QueryRecord("TempTersureRec", row_index, 1)
    local value = item:QueryRecord("TempTersureRec", row_index, 2)
    if nx_string(type) == "1" then
      local info = form_tersure:GetPropText(id, nx_int(value))
      if info ~= nx_widestr("") then
        if row_index < 2 then
          form.mltbox_result_lock_pro:AddHtmlText(info, -1)
        else
          form.mltbox_result_pro:AddHtmlText(info, -1)
        end
      end
    elseif nx_string(type) == "0" then
      local skill_id = item:QueryRecord("TempTersureRec", row_index, 3)
      local info = form_tersure:GetSkillText(id, skill_id, nx_int(value))
      if info ~= nx_widestr("") then
        form.mltbox_result_skill:AddHtmlText(info, -1)
      end
    end
  end
  if form.rbtn_prop.Checked then
    local row_count = item:GetRecordRows("RandomSkillRec")
    for row_index = 0, row_count - 1 do
      local id = item:QueryRecord("RandomSkillRec", row_index, 0)
      local skill_id = item:QueryRecord("RandomSkillRec", row_index, 1)
      local value = item:QueryRecord("RandomSkillRec", row_index, 2)
      local info = form_tersure:GetSkillText(id, skill_id, nx_int(value))
      if info ~= nx_widestr("") then
        form.mltbox_result_skill:AddHtmlText(info, -1)
      end
    end
  end
  if form.rbtn_skill.Checked then
    local row_count = item:GetRecordRows("RandomPropRec")
    for row_index = 0, row_count - 1 do
      local id = item:QueryRecord("RandomPropRec", row_index, 0)
      local value = item:QueryRecord("RandomPropRec", row_index, 1)
      local info = form_tersure:GetPropText(id, nx_int(value))
      if info ~= nx_widestr("") then
        form.mltbox_result_prop:AddHtmlText(info, -1)
      end
    end
  end
  form.btn_ok.Enabled = true
  form.is_change = true
end
function show_tersuer_max_value(...)
  local form = nx_value("form_stage_main\\form_life\\form_treasure_reset")
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
  if not check_player_status() then
    return false
  end
  local form_up = nx_value("form_stage_main\\form_life\\form_treasure_upgrade")
  if nx_is_valid(form_up) then
    form_up:Close()
    return false
  end
  local form_recast = nx_value("form_stage_main\\form_life\\form_treasure_recast")
  if nx_is_valid(form_recast) then
    nx_execute("form_stage_main\\form_life\\form_treasure_recast", "on_btn_close_click", form_recast.btn_close)
    return false
  end
  local form_reset_add = nx_value("form_stage_main\\form_life\\form_treasure_reset_add")
  if nx_is_valid(form_reset_add) then
    nx_execute("form_stage_main\\form_life\\form_treasure_reset_add", "on_btn_close_click", form_reset_add.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_treasure_reset", true, false)
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
function on_btn_lock_click(btn)
  local form = btn.ParentForm
  local mltbox_index = form.mltbox_pro:GetSelectItemIndex() + 2
  if mltbox_index < 2 then
    custom_sysinfo(1, 1, 1, 2, "treasure_lock_select")
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local lock = item:QueryRecord("RandomPropRec", row_index, 2)
    if nx_int(lock) == nx_int(1) then
      custom_sysinfo(1, 1, 1, 2, "treasure_lock_fail")
      return
    end
  end
  local text = util_text("ui_treasure_lock")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_tersure_lock_prop", TERSURE_PROP_LOCK, form.sel_view, form.sel_index, mltbox_index)
    end
  end
end
function on_btn_unlock_click(btn)
  local form = btn.ParentForm
  local mltbox_index = form.mltbox_pro:GetSelectItemIndex() + 2
  if mltbox_index < 2 then
    custom_sysinfo(1, 1, 1, 2, "treasure_unlock_select")
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local is_lock = false
  local row_count = item:GetRecordRows("RandomPropRec")
  for row_index = 0, row_count - 1 do
    local lock = item:QueryRecord("RandomPropRec", row_index, 2)
    if nx_int(lock) == nx_int(1) then
      is_lock = true
      break
    end
  end
  if is_lock then
    local text = util_text("ui_treasure_unlock")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    if nx_is_valid(dialog) then
      local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
      if res == "ok" then
        nx_execute("custom_sender", "custom_tersure_lock_prop", TERSURE_PROP_UNLOCK, form.sel_view, form.sel_index, mltbox_index)
      end
    end
  else
    custom_sysinfo(1, 1, 1, 2, "treasure_unlock_fail")
  end
end
function on_mltbox_pro_select_item_change(mltbox, index)
end
function on_rbtn_prop_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(230) then
    form.rbtn_prop.Checked = true
  end
  if not rbtn.Checked then
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
      if res ~= "ok" then
        form.rbtn_skill.Enabled = false
        form.rbtn_skill.Checked = true
        form.rbtn_skill.Enabled = true
        return
      end
    end
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_find_custom(form.sub_form, "is_change") and form.sub_form.is_change then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetText("ui_treasure_recast_1")
      local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
      if res ~= "ok" then
        form.rbtn_treasure_recast.Enabled = false
        form.rbtn_treasure_recast.Checked = true
        form.rbtn_treasure_recast.Enabled = true
        return
      end
    end
    form.sub_form:Close()
    form.sub_form = nil
    form.subform_type = 0
  end
  form.mltbox_result_prop:Clear()
  form.groupbox_skill_type.Visible = false
  form.groupbox_prop.Visible = true
  form.groupbox_skill.Visible = false
  rbtn_change(form, "prop")
  if form.groupbox_notice.Visible == true then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = true
  end
  if form.groupbox_1.Visible == false then
    form.groupbox_1.Visible = true
    form.btn_notice.Visible = true
    form.btn_upgrade_notice.Visible = false
    if form.groupbox_upgrade_notice.Visible == true then
      form.groupbox_upgrade_notice.Visible = false
    end
  end
  reset_form_size(form, 0)
end
function on_rbtn_skill_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(230) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("7109"), 2)
    end
    form.groupbox_skill.Visible = false
    form.rbtn_prop.Enabled = false
    form.rbtn_prop.Checked = true
    form.rbtn_prop.Enabled = true
  end
  if form.is_change then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_treasure_reset_quit")
    local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_treasure")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    if nx_is_valid(dialog) then
      local res = nx_wait_event(100000000, dialog, "recast_treasure_confirm_return")
      if res ~= "ok" then
        form.rbtn_prop.Enabled = false
        form.rbtn_prop.Checked = true
        form.rbtn_prop.Enabled = true
        return
      end
    end
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_find_custom(form.sub_form, "is_change") and form.sub_form.is_change then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetText("ui_treasure_recast_1")
      local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
      if res ~= "ok" then
        form.rbtn_treasure_recast.Enabled = false
        form.rbtn_treasure_recast.Checked = true
        form.rbtn_treasure_recast.Enabled = true
        return
      end
    end
    form.sub_form:Close()
    form.sub_form = nil
    form.subform_type = 0
  end
  if form.groupbox_notice.Visible == true then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = true
  end
  if form.groupbox_1.Visible == false then
    form.groupbox_1.Visible = true
    form.btn_notice.Visible = true
    form.btn_upgrade_notice.Visible = false
    if form.groupbox_upgrade_notice.Visible == true then
      form.groupbox_upgrade_notice.Visible = false
    end
  end
  form.groupbox_skill_type.Visible = true
  form.groupbox_prop.Visible = false
  form.groupbox_skill.Visible = true
  rbtn_change(form, "skill")
  reset_form_size(form, 0)
end
function on_rbtn_treasure_recast_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  if condition_manager:CanSatisfyCondition(client_player, client_player, 19323) == false or nx_int(cur_main_game_step) < nx_int(4) then
    nx_pause(0)
    if form.groupbox_skill_type.Visible == true then
      form.rbtn_skill.Enabled = false
      form.rbtn_skill.Checked = true
      form.rbtn_skill.Enabled = true
    elseif form.groupbox_prop.Visible == true then
      form.rbtn_prop.Enabled = false
      form.rbtn_prop.Checked = true
      form.rbtn_prop.Enabled = true
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if not nx_is_valid(SystemCenterInfo) then
      return
    end
    SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_treasure_reset_close"), CENTERINFO_PERSONAL_NO)
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
      if res ~= "ok" then
        if form.groupbox_skill_type.Visible == true then
          form.rbtn_skill.Enabled = false
          form.rbtn_skill.Checked = true
          form.rbtn_skill.Enabled = true
        elseif form.groupbox_prop.Visible == true then
          form.rbtn_prop.Enabled = false
          form.rbtn_prop.Checked = true
          form.rbtn_prop.Enabled = true
        end
        return
      end
    end
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  form.imagegrid_zb:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
  nx_execute("form_stage_main\\form_life\\form_treasure_recast", "open_form")
end
function on_rbtn_treasure_upgrade_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_main_game_step = switch_manager:GetMainGameStep()
  if condition_manager:CanSatisfyCondition(client_player, client_player, 19323) == false or nx_int(cur_main_game_step) < nx_int(4) then
    nx_pause(0)
    if form.groupbox_skill_type.Visible == true then
      form.rbtn_skill.Enabled = false
      form.rbtn_skill.Checked = true
      form.rbtn_skill.Enabled = true
    elseif form.groupbox_prop.Visible == true then
      form.rbtn_prop.Enabled = false
      form.rbtn_prop.Checked = true
      form.rbtn_prop.Enabled = true
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if not nx_is_valid(SystemCenterInfo) then
      return
    end
    SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_treasure_reset_close"), CENTERINFO_PERSONAL_NO)
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
      if res ~= "ok" then
        if form.groupbox_skill_type.Visible == true then
          form.rbtn_skill.Enabled = false
          form.rbtn_skill.Checked = true
          form.rbtn_skill.Enabled = true
        elseif form.groupbox_prop.Visible == true then
          form.rbtn_prop.Enabled = false
          form.rbtn_prop.Checked = true
          form.rbtn_prop.Enabled = true
        end
        return
      end
    end
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_tersure_unlock", form.sel_view, form.sel_index)
  end
  form.imagegrid_zb:Clear()
  form.sel_view = -1
  form.sel_index = -1
  form.is_change = false
  clearform(form)
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    if nx_find_custom(form.sub_form, "is_change") and form.sub_form.is_change then
      local gui = nx_value("gui")
      local text = gui.TextManager:GetText("ui_treasure_recast_1")
      local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "recast_no_finish")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "recast_no_finish_confirm_return")
      if res ~= "ok" then
        form.rbtn_treasure_recast.Enabled = false
        form.rbtn_treasure_recast.Checked = true
        form.rbtn_treasure_recast.Enabled = true
        return
      end
    end
    form.sub_form:Close()
    form.sub_form = nil
    form.subform_type = 0
  end
  nx_execute("form_stage_main\\form_life\\form_treasure_upgrade", "open_form")
end
function add_sub_form(subface, type)
  local form = nx_execute("util_gui", "util_get_form", FORM_TREASURE_RESET, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  if nx_find_custom(form, "subform_type") and form.subform_type == type then
    return
  end
  if nx_find_custom(form, "sub_form") and nx_is_valid(form.sub_form) then
    form.sub_form:Close()
    form.sub_form = nil
    form.subform_type = 0
  end
  if form.groupbox_1.Visible then
    form.groupbox_1.Visible = false
    if form.groupbox_notice.Visible == true then
      form.groupbox_notice.Visible = false
    end
  end
  form.groupbox_sub_form:Add(subface)
  form.sub_form = subface
  form.subform_type = type
  subface.Top = 0
  subface.Left = 0
  subface.Visible = true
  if type == 1 then
    form.rbtn_prop.Checked = false
    form.rbtn_skill.Checked = false
    form.rbtn_treasure_recast.Checked = false
    form.rbtn_treasure_upgrade.Checked = true
    form.btn_upgrade_notice.Visible = true
    form.groupbox_upgrade_notice.Visible = false
    local gui = nx_value("gui")
    form.mltbox_3:Clear()
    form.mltbox_3:AddHtmlText(gui.TextManager:GetText("ui_recast_treasrue_rule"), -1)
  elseif type == 2 then
    form.rbtn_prop.Checked = false
    form.rbtn_skill.Checked = false
    form.rbtn_treasure_recast.Checked = true
    form.rbtn_treasure_upgrade.Checked = false
    form.btn_upgrade_notice.Visible = false
    form.groupbox_upgrade_notice.Visible = false
  end
  reset_form_size(form, type)
end
function on_btn_upgrade_notice_click(self)
  form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.Width = 938
  form.groupbox_upgrade_notice.Visible = true
  self.Visible = false
  change_form_size()
end
function on_btn_upgrade_notice_close_click(self)
  form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.Width = 650
  form.groupbox_upgrade_notice.Visible = false
  form.btn_upgrade_notice.Visible = true
  change_form_size()
end
function reset_form_size(form, type)
  if type == 2 then
    form.Width = 590
    form.Height = 742
    form.lbl_main.Width = 590
    form.lbl_main.Height = 742
    form.groupbox_title.Width = 590
    form.groupbox_sub_form.Width = 590
    form.groupbox_sub_form.Height = 740
    form.lbl_6.Width = 590
    form.btn_help.Left = 540
    form.btn_close.Left = 565
  elseif type == 1 then
    form.Width = 490
    form.Height = 606
    form.lbl_main.Width = 480
    form.lbl_main.Height = 606
    form.groupbox_title.Width = 478
    form.groupbox_sub_form.Width = 480
    form.groupbox_sub_form.Height = 606
    form.lbl_6.Width = 480
    form.btn_help.Left = 430
    form.btn_close.Left = 450
    form.btn_upgrade_notice.Left = 470
  else
    form.Width = 650
    form.Height = 606
    form.lbl_main.Width = 642
    form.lbl_main.Height = 606
    form.groupbox_title.Width = 645
    form.groupbox_sub_form.Width = 654
    form.groupbox_sub_form.Height = 606
    form.lbl_6.Width = 636
    form.btn_help.Left = 592
    form.btn_close.Left = 616
  end
end
