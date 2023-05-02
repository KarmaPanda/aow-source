require("util_gui")
require("custom_handler")
require("share\\client_custom_define")
require("util_functions")
require("share\\view_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("form_stage_main\\form_bag")
local FORM_NAME = "form_stage_main\\form_life\\form_newtreasure_grave"
local lbl_table = {
  "lbl_repeat_1",
  "lbl_repeat_2",
  "lbl_repeat_3",
  "lbl_repeat_4",
  "lbl_repeat_5"
}
function main_form_init(form)
  form.sel_view = -1
  form.sel_index = -1
  form.prop_count = -1
  form.select_target = -1
  form.revise_count = -1
  form.Fixed = false
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
  clear_target(form)
  form.btn_grave.Enabled = false
  form.btn_intensify.Enabled = false
  form.btn_replace.Enabled = false
  form.groupbox_notice.Visible = false
  form.rbtn_one.Checked = true
  form.lbl_select.Visible = false
  form.imagegrid_target.DragEnabled = false
  for i = 1, table.getn(lbl_table) do
    local lbl = form.groupbox_grave_repeat:Find("lbl_repeat_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.Visible = false
    end
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = false
  end
  local player = get_player()
  local exp_info = player:QueryProp("NewTersureValue")
  form.lbl_exp_info.Text = nx_widestr(exp_info)
  resize_form(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if nx_is_valid(form_tersure) then
    nx_destroy(form_tersure)
  end
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    form_bag.btn_arrange.Enabled = true
  end
  local child_form = nx_value("form_stage_main\\form_life\\form_newtreasure_intensify")
  if nx_is_valid(child_form) then
    child_form:Close()
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view, form.sel_index)
  end
  nx_destroy(form)
end
function resize_form(form)
  if form.groupbox_notice.Visible then
    form.Width = form.groupbox_serve.Width + form.groupbox_notice.Width
  else
    form.Width = form.groupbox_serve.Width
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_notice.Visible == true then
    form.btn_notice_close.Visible = true
    form.btn_notice.Visible = false
  else
    form.groupbox_notice.Visible = true
    form.btn_notice_close.Visible = true
    form.btn_notice.Visible = false
  end
  resize_form(form)
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_notice.Visible = true
  form.btn_notice_close.Visible = true
  form.btn_notice.Visible = false
  resize_form(form)
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_notice.Visible = false
  form.btn_notice_close.Visible = false
  form.btn_notice.Visible = true
  resize_form(form)
end
function clear_target(form)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local imagegrid_target = form.imagegrid_target
  if not nx_is_valid(imagegrid_target) then
    return
  end
  imagegrid_target:Clear()
  form.mltbox_target:Clear()
  form.mltbox_material:Clear()
  for i = 1, table.getn(lbl_table) do
    local lbl = form.groupbox_grave_repeat:Find("lbl_repeat_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.Visible = false
    end
  end
  form.sel_index = -1
  form.sel_view = -1
end
function on_imagegrid_target_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
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
  local src_viewid_1 = nx_int(gui.GameHand.Para1)
  local src_pos_1 = nx_int(gui.GameHand.Para2)
  if form.sel_view == src_viewid_1 and form.sel_index == src_pos_1 then
    gameHand:ClearHand()
    return
  end
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid_1)) then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "9215")
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid_1, src_pos_1)
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
  if item:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_1")
    return
  end
  if not item:FindRecord("RandomPropRec") then
    return
  end
  local level = item:QueryProp("ColorLevel")
  if level < 3 then
    gameHand:ClearHand()
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_1")
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  if form.sel_view ~= -1 and form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view, form.sel_index)
  end
  clear_target(form)
  grid:AddItem(index, photo, "", amount, -1)
  form.sel_view = src_viewid_1
  form.sel_index = src_pos_1
  nx_execute("custom_sender", "custom_newtersure_lock", form.sel_view, form.sel_index)
  gameHand:ClearHand()
  show_target_addprop(form, item)
  check_update_state()
end
function on_imagegrid_target_rightclick_grid(grid, index)
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
  nx_execute("custom_sender", "custom_newtersure_unlock", form.sel_view, form.sel_index)
  grid:Clear()
  form.sel_view = -1
  form.sel_index = -1
  clear_target(form)
  check_update_state()
end
function on_imagegrid_target_drag_move(grid, index)
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
function on_imagegrid_target_mousein_grid(grid, index)
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
function on_imagegrid_target_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_target_addprop(form, item)
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
  form.mltbox_target:Clear()
  if not item:FindRecord("RandomPropRec") and item:FindRecord("TempTersureRec") then
    return
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  local counts = 0
  for row_index = 0, row_count - 1 do
    local flag = item:QueryRecord("RandomPropRec", row_index, 3)
    if flag == 0 then
      counts = counts + 1
    end
  end
  for row_index = counts, row_count - 1 do
    local flag = item:QueryRecord("RandomPropRec", row_index, 3)
    if flag == 1 then
      local id = item:QueryRecord("RandomPropRec", row_index, 0)
      local value = item:QueryRecord("RandomPropRec", row_index, 1)
      local revise_level = item:QueryRecord("RandomPropRec", row_index, 4)
      local revise_power = item:QueryRecord("RandomPropRec", row_index, 5)
      local info = form_tersure:GetNewPropText(id, nx_int(value), nx_int(revise_level), nx_int(revise_power))
      form.mltbox_target:AddHtmlText(info, -1)
    end
  end
  local row_count_1 = item:GetRecordRows("TempTersureRec")
  for row_index = 0, row_count_1 - 1 do
    local flag = item:QueryRecord("TempTersureRec", row_index, 4)
    if flag == 1 then
      local id = item:QueryRecord("TempTersureRec", row_index, 1)
      local value = item:QueryRecord("TempTersureRec", row_index, 2)
      local revise_level = item:QueryRecord("TempTersureRec", row_index, 5)
      local revise_power = item:QueryRecord("TempTersureRec", row_index, 6)
      local info = form_tersure:GetNewPropText(id, nx_int(value), nx_int(revise_level), nx_int(revise_power))
      if info ~= nx_widestr("") then
        form.mltbox_material:AddHtmlText(info, -1)
      end
    end
  end
end
function on_rbtn_one_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_one.Checked == true then
    form.revise_count = 0
    local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
    if not nx_is_valid(item) then
      form.btn_grave.Enabled = false
    else
      form.btn_grave.Enabled = true
    end
  end
end
function on_rbtn_ten_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.rbtn_ten.Checked == true then
    form.revise_count = 1
    local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
    if not nx_is_valid(item) then
      form.btn_grave.Enabled = false
    else
      form.btn_grave.Enabled = true
    end
  end
end
function on_btn_grave_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local cost_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\NewTersure\\NewTreasureCost.ini")
  if not nx_is_valid(cost_ini) then
    return
  end
  local section_index = cost_ini:FindSectionIndex("Normal")
  if section_index < 0 then
    return
  end
  local key_count = cost_ini:GetSectionItemCount(section_index)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local revise_count = form.revise_count
  local sel_count
  if revise_count == 0 then
    sel_count = 1
  else
    sel_count = 5
  end
  local cur_count = player:QueryProp("NewTersureCount")
  local value = 0
  if key_count >= cur_count + sel_count then
    if cost_ini:FindSection("Normal") then
      local section_index = cost_ini:FindSectionIndex("Normal")
      if section_index < 0 then
        return
      end
      for i = cur_count, cur_count + sel_count - 1 do
        local count = cost_ini:GetSectionItemKey(section_index, i)
        if nx_int(count) == nx_int(i) then
          value = value + cost_ini:GetSectionItemValue(section_index, i)
        end
      end
    end
  elseif key_count > cur_count and key_count < cur_count + sel_count and cur_count + sel_count <= key_count + 5 then
    if cost_ini:FindSection("Normal") then
      local section_index = cost_ini:FindSectionIndex("Normal")
      if section_index < 0 then
        return
      end
      for j = cur_count, key_count - 1 do
        local count = cost_ini:GetSectionItemKey(section_index, j)
        if nx_int(count) == nx_int(j) then
          value = value + cost_ini:GetSectionItemValue(section_index, j)
        end
      end
    end
    if cost_ini:FindSection("Special") then
      local section_index_1 = cost_ini:FindSectionIndex("Special")
      if section_index_1 < 0 then
        return
      end
      for k = 1, cur_count + sel_count - key_count do
        value = value + cost_ini:GetSectionItemValue(section_index_1, 0)
      end
    end
  elseif cost_ini:FindSection("Special") then
    local section_index_1 = cost_ini:FindSectionIndex("Special")
    if section_index_1 < 0 then
      return
    end
    for k = 1, sel_count do
      value = value + cost_ini:GetSectionItemValue(section_index_1, 0)
    end
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local count = goods_grid:GetItemCount("newtreasure_grave")
  local text = ""
  if nx_int(count) <= nx_int(0) or nx_int(sel_count) == nx_int(5) then
    text = nx_widestr(gui.TextManager:GetFormatText("ui_newtreasure_cost", value))
  else
    text = nx_widestr(gui.TextManager:GetFormatText("ui_newtreasure_cost_1", nx_int(count)))
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "update_newtreasure")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "update_newtreasure_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_newtersure_grave", form.sel_view, form.sel_index, form.revise_count)
    end
  end
end
function on_btn_replace_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("TempTersureRec") and item:FindRecord("RandomPropRec") then
    return
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  local max_num = item:QueryProp("TersureMaxPropNum")
  local select_index = form.mltbox_target:GetSelectItemIndex()
  if select_index < 0 and row_count == max_num then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_4")
    return
  end
  local select_1 = -1
  if select_index < 0 and row_count <= max_num then
    select_1 = -1
  elseif 0 <= select_index then
    select_1 = select_index + 1
  end
  local row_count_2 = item:GetRecordRows("TempTersureRec")
  local select_2 = form.mltbox_material:GetSelectItemIndex()
  local value
  if row_count_2 == 1 then
    value = 0
  elseif select_2 < 0 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_10")
    return
  else
    value = select_2
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if row_count < 6 and select_1 < 0 then
    nx_execute("custom_sender", "custom_newtersure_replace", form.sel_view, form.sel_index, nx_int(select_1), nx_int(value))
  else
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog.lbl_3.Visible = false
    dialog.mltbox_info:Clear()
    dialog.mltbox_info:AddHtmlText(nx_widestr(util_text("ui_newtreasure_update")), -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
    nx_execute("custom_sender", "custom_newtersure_replace", form.sel_view, form.sel_index, nx_int(select_1), nx_int(value))
  end
end
function on_btn_intensify_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local mltbox_target = form.mltbox_target
  if not nx_is_valid(mltbox_target) then
    return
  end
  local select_index = form.mltbox_target:GetSelectItemIndex() + 1
  if select_index < 1 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_11")
    return
  end
  form.select_target = select_index
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local curlevel = item:QueryProp("Level")
  local revise_power = item:QueryRecord("RandomPropRec", select_index, 5)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\NewTersure\\AddPropExp.ini")
  if not nx_is_valid(ini) then
    return
  end
  if ini:FindSection("Limit") then
    local section_index = ini:FindSectionIndex("Limit")
    if section_index < 0 then
      return
    end
    local item_count = ini:GetSectionItemCount(section_index)
    for i = 0, item_count - 1 do
      local count = ini:GetSectionItemKey(section_index, i)
      if nx_int(count) == nx_int(curlevel) then
        local level = ini:GetSectionItemValue(section_index, i)
        if nx_int(level) == nx_int(revise_power) then
          custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_7")
          return
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_life\\form_newtreasure_intensify", "open_form")
end
function show_temp_info(form, item)
  if not nx_is_valid(form) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("TempTersureRec") then
    return
  end
  local player = get_player()
  local exp_info = player:QueryProp("NewTersureValue")
  form.lbl_exp_info.Text = nx_widestr(exp_info)
  local row_count_1 = item:GetRecordRows("TempTersureRec")
  if row_count_1 < 1 then
    form.btn_replace.Enabled = false
  else
    form.btn_replace.Enabled = true
  end
  for row_index = 0, row_count_1 - 1 do
    local flag = item:QueryRecord("TempTersureRec", row_index, 4)
    if flag == 1 then
      local id = item:QueryRecord("TempTersureRec", row_index, 1)
      local value = item:QueryRecord("TempTersureRec", row_index, 2)
      local revise_level = item:QueryRecord("TempTersureRec", row_index, 5)
      local revise_power = item:QueryRecord("TempTersureRec", row_index, 6)
      local info = form_tersure:GetNewPropText(id, nx_int(value), nx_int(revise_level), nx_int(revise_power))
      if info ~= nx_widestr("") then
        form.mltbox_material:AddHtmlText(info, -1)
      end
    end
  end
  refresh_repeat_id(form, item)
end
function refresh_repeat_id(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("TempTersureRec") or not item:FindRecord("RandomPropRec") then
    return
  end
  for i = 1, table.getn(lbl_table) do
    local lbl = form.groupbox_grave_repeat:Find("lbl_repeat_" .. nx_string(i))
    if nx_is_valid(lbl) then
      lbl.Visible = false
    end
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  local row_count_1 = item:GetRecordRows("TempTersureRec")
  for i = 1, row_count - 1 do
    local base_id = item:QueryRecord("RandomPropRec", i, 0)
    for row_index = 0, row_count_1 - 1 do
      local add_id = item:QueryRecord("TempTersureRec", row_index, 1)
      if base_id == add_id then
        local lbl_warn = form.groupbox_grave_repeat:Find("lbl_repeat_" .. nx_string(row_index + 1))
        if nx_is_valid(lbl_warn) then
          lbl_warn.Visible = true
        end
      end
    end
  end
end
function show_replace_prop(form)
  if not nx_is_valid(form) then
    return
  end
  local form_tersure = nx_value("form_recast_tersure")
  if not nx_is_valid(form_tersure) then
    return
  end
  local player = get_player()
  local exp_info = player:QueryProp("NewTersureValue")
  form.lbl_exp_info.Text = nx_widestr(exp_info)
  form.mltbox_target:Clear()
  form.mltbox_material:Clear()
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("RandomPropRec") then
    return
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  if 1 < row_count then
    form.btn_intensify.Enabled = true
  else
    form.btn_intensify.Enabled = false
  end
  for row_index = 0, row_count - 1 do
    local flag = item:QueryRecord("RandomPropRec", row_index, 3)
    if flag == 1 then
      local id = item:QueryRecord("RandomPropRec", row_index, 0)
      local value = item:QueryRecord("RandomPropRec", row_index, 1)
      local revise_level = item:QueryRecord("RandomPropRec", row_index, 4)
      local revise_power = item:QueryRecord("RandomPropRec", row_index, 5)
      local info = form_tersure:GetNewPropText(id, nx_int(value), nx_int(revise_level), nx_int(revise_power))
      if info ~= nx_widestr("") then
        form.mltbox_target:AddHtmlText(info, -1)
      end
    end
  end
  form.mltbox_target.SelectBarColor = "255,0,0,0"
  form.mltbox_target.SelectBarDraw = "gui\\special\\newtersure\\check01.png"
  if not item:FindRecord("TempTersureRec") then
    return
  end
  local row_count_1 = item:GetRecordRows("TempTersureRec")
  for row_index = 0, row_count_1 - 1 do
    local flag = item:QueryRecord("TempTersureRec", row_index, 4)
    if flag == 1 then
      local id = item:QueryRecord("TempTersureRec", row_index, 1)
      local value = item:QueryRecord("TempTersureRec", row_index, 2)
      local revise_level = item:QueryRecord("TempTersureRec", row_index, 5)
      local revise_power = item:QueryRecord("TempTersureRec", row_index, 6)
      local info = form_tersure:GetNewPropText(id, nx_int(value), nx_int(revise_level), nx_int(revise_power))
      if info ~= nx_widestr("") then
        form.mltbox_material:AddHtmlText(info, -1)
      end
    end
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if row_count < 6 then
    form.btn_replace.Text = gui.TextManager:GetText("ui_newtreasure_grave_2_1")
    form.btn_replace.HintText = gui.TextManager:GetText("tips_newtreasure_grave_2_1")
  else
    form.btn_replace.Text = gui.TextManager:GetText("ui_newtreasure_grave_2")
    form.btn_replace.HintText = gui.TextManager:GetText("tips_newtreasure_grave_2")
  end
  refresh_repeat_id(form, item)
end
function check_update_state()
  local form = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if not nx_is_valid(form) then
    return
  end
  form.btn_grave.Enabled = false
  form.btn_intensify.Enabled = false
  form.btn_replace.Enabled = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local item = game_client:GetViewObj(nx_string(form.sel_view), nx_string(form.sel_index))
  if not nx_is_valid(item) then
    return
  end
  if item:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    return
  end
  local count = form.revise_count
  if count < 0 then
    form.btn_grave.Enabled = false
  else
    form.btn_grave.Enabled = true
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local row_count = item:GetRecordRows("RandomPropRec")
  if 1 < row_count then
    form.btn_intensify.Enabled = true
  else
    form.btn_intensify.Enabled = false
  end
  if row_count < 6 then
    form.btn_replace.Text = gui.TextManager:GetText("ui_newtreasure_grave_2_1")
    form.btn_replace.HintText = gui.TextManager:GetText("tips_newtreasure_grave_2_1")
  else
    form.btn_replace.Text = gui.TextManager:GetText("ui_newtreasure_grave_2")
    form.btn_replace.HintText = gui.TextManager:GetText("tips_newtreasure_grave_2")
  end
  local row_count_1 = item:GetRecordRows("TempTersureRec")
  if row_count_1 < 1 then
    form.btn_replace.Enabled = false
  else
    form.btn_replace.Enabled = true
  end
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
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_dead")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_failed_shuizhong")
    return false
  end
  return true
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
function show_newtersure_grave_result(sub_type)
  local form = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if not nx_is_valid(form) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  if not item:FindRecord("TempTersureRec") then
    return
  end
  form.mltbox_material:Clear()
  if 10 == sub_type then
    show_temp_info(form, item)
  end
end
function show_newtersure_replace_result(sub_type)
  local form = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if not nx_is_valid(form) then
    return
  end
  if 11 == sub_type then
    show_replace_prop(form)
  end
end
function show_intensify_result(sub_type)
  local child_form = nx_value("form_stage_main\\form_life\\form_newtreasure_intensify")
  if nx_is_valid(child_form) then
    child_form:Close()
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if 13 == sub_type then
    show_replace_prop(form)
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local curlevel = item:QueryProp("Level")
  local select_index = form.select_target
  local revise_power = item:QueryRecord("RandomPropRec", select_index, 5)
  form.lbl_select.Visible = true
  form.lbl_select.Top = 206 + (select_index - 1) * 22
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\NewTersure\\AddPropExp.ini")
  if not nx_is_valid(ini) then
    return
  end
  if ini:FindSection("Limit") then
    local section_index = ini:FindSectionIndex("Limit")
    if section_index < 0 then
      return
    end
    local item_count = ini:GetSectionItemCount(section_index)
    for i = 0, item_count - 1 do
      local count = ini:GetSectionItemKey(section_index, i)
      if nx_int(count) == nx_int(curlevel) then
        local level = ini:GetSectionItemValue(section_index, i)
        if nx_int(level) == nx_int(revise_power) then
          custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_7")
          form.lbl_select.Visible = false
          local child_form = nx_value("form_stage_main\\form_life\\form_newtreasure_intensify")
          if nx_is_valid(child_form) then
            nx_execute("form_stage_main\\form_life\\form_newtreasure_intensify", "close_form")
          end
          return
        end
      end
    end
  end
  nx_execute("form_stage_main\\form_life\\form_newtreasure_intensify", "open_form")
end
function add_item_by_rightclick(grid, index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local form = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.imagegrid_target) and not nx_is_valid(form.imagegrid_material) then
    return
  end
  local src_viewid = grid.typeid
  local src_pos = index + 1
  local view_index = grid:GetBindIndex(index)
  local addbag_index = nx_execute("form_stage_main\\form_bag_func", "get_addbag_index", view_index)
  if addbag_index ~= 0 then
    src_pos = view_index
  end
  local view = game_client:GetView(nx_string(src_viewid))
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if viewobj:FindProp("CantExchange") then
    local cant_exchange = viewobj:QueryProp("CantExchange")
    if nx_int(cant_exchange) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7055"))
      return
    end
  end
  if viewobj:FindProp("LockStatus") then
    local lock_status = viewobj:QueryProp("LockStatus")
    if nx_int(lock_status) > nx_int(0) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("7054"))
      return
    end
  end
  if viewobj:QueryProp("EquipType") ~= nx_string("NewTreasure") then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_1")
    return
  end
  if not viewobj:FindRecord("RandomPropRec") then
    return
  end
  local level = viewobj:QueryProp("ColorLevel")
  if level < 3 then
    custom_sysinfo(1, 1, 1, 2, "newtreasure_grave_info_1")
    return
  end
  local item_config = viewobj:QueryProp("ConfigID")
  local item_name = gui.TextManager:GetText(item_config)
  local photo, amount = get_photo_amont(viewobj)
  if "" == photo then
    return
  end
  local grid_1 = form.imagegrid_target
  if grid_1:IsEmpty(0) then
    form.sel_view = src_viewid
    form.sel_index = src_pos
    grid_1:AddItem(0, photo, nx_widestr(item_name), amount, -1)
    nx_execute("custom_sender", "custom_newtersure_lock", form.sel_view, form.sel_index)
    show_target_addprop(form, viewobj)
  end
  check_update_state()
end
function open_form()
  local ST_FUNCTION_NEWTRESURE_CL = 382
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_NEWTRESURE_CL) then
    custom_sysinfo(1, 1, 1, 2, "19919")
    return
  end
  if not check_player_status() then
    return
  end
  local form_transfer = nx_value("form_stage_main\\form_life\\form_newtreasure_transfer")
  if nx_is_valid(form_transfer) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_transfer", "on_btn_close_click", form_transfer.btn_close)
    return false
  end
  local form_help = nx_value("form_stage_main\\form_help\\form_help_fcww")
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_help\\form_help_fcww", "on_btn_close_click", form_help.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
