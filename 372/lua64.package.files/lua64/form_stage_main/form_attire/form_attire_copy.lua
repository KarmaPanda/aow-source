require("util_gui")
require("util_static_data")
require("role_composite")
require("share\\static_data_type")
require("util_functions")
require("share\\view_define")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("share\\item_static_data_define")
local FORM_PATH = "form_stage_main\\form_attire\\form_attire_copy"
function open_form()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_main_form_init(self)
  self.Fixed = false
  self.playing = false
  self.select_item_id = ""
  self.set_num = 1
end
function on_main_form_open(form)
  form.cbtn_usemoney.Checked = true
  refresh_prize(form)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "play_pbar_animation", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_cbtn_useitem_checked_changed(cbtn)
  if not cbtn.Checked then
    local form = cbtn.ParentForm
    if nx_is_valid(form) then
      refresh_prize(form)
    end
  end
end
function on_cbtn_usemoney_checked_changed(cbtn)
  if not cbtn.Checked then
    local form = cbtn.ParentForm
    if nx_is_valid(form) then
      refresh_prize(form)
    end
  end
end
function on_imagegrid_equip_select_changed(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if form.playing then
    show_system_notice("attire_copy_1")
    gui.GameHand:ClearHand()
    return
  end
  local gamehand_type = gui.GameHand.Type
  if not gui.GameHand:IsEmpty() and gamehand_type == GHT_VIEWITEM then
    local src_viewid = nx_number(gui.GameHand.Para1)
    local src_pos = nx_number(gui.GameHand.Para2)
    gui.GameHand:ClearHand()
    if nx_int(src_viewid) ~= nx_int(VIEWPORT_EQUIP_TOOL) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("16624"))
      return
    end
    local view_item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
    if not nx_is_valid(view_item) then
      return
    end
    local game_client = nx_value("game_client")
    local client_palyer = game_client:GetPlayer()
    if nx_is_valid(client_palyer) then
      local sex = client_palyer:QueryProp("Sex")
      local needsex = GetItemSex(view_item)
      if nx_int(needsex) <= nx_int(1) and nx_int(needsex) ~= nx_int(sex) then
        nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("16599"))
        return
      end
    end
    if not view_item:FindProp("ItemType") then
      return
    end
    local item_type = view_item:QueryProp("ItemType")
    if item_type >= ITEMTYPE_EQUIP_HAT and item_type <= ITEMTYPE_EQUIP_SHOES then
      local config_id = view_item:QueryProp("ConfigID")
      local photo = nx_execute("util_static_data", "queryprop_by_object", view_item, "Photo")
      form.imagegrid_equip:AddItem(0, photo, nx_widestr(config_id), 1, -1)
      form.imagegrid_copy:Clear()
      nx_set_custom(form.imagegrid_equip, "itemobj", view_item)
      local bHasCopy = false
      if view_item:FindProp("ReplacePack") then
        local replace_pack = view_item:QueryProp("ReplacePack")
        if nx_int(replace_pack) > nx_int(0) then
          bHasCopy = true
        end
      end
      if not bHasCopy then
        show_equip_copy_item_info(form, config_id)
      else
        show_system_notice("16598")
      end
    else
      show_system_notice("attire_copy_2")
    end
  end
end
function show_equip_copy_item_info(form, config_id)
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local copy_item_list = attire_manager:GetEquipCopyItemConfigID(config_id)
  local copy_item_config_id = copy_item_list[1]
  if copy_item_config_id == nil or copy_item_config_id == "" then
    show_system_notice("attire_copy_2")
    return
  end
  local item_query = nx_value("ItemQuery")
  if nx_is_valid(item_query) and not item_query:FindItemByConfigID(copy_item_config_id) then
    show_system_notice("16627")
    return
  end
  local photo = query_arrire_item_photo(nx_string(copy_item_config_id), "Photo")
  form.imagegrid_copy:AddItem(0, photo, nx_widestr(copy_item_config_id), 1, -1)
  form.select_item_id = config_id
  refresh_prize(form)
end
function refresh_prize(form)
  local gui = nx_value("gui")
  local attire_manager = nx_value("attire_manager")
  if not nx_is_valid(attire_manager) then
    return
  end
  local num = nx_int(form.ipt_num.Text)
  if num <= nx_int(0) then
    form.ipt_num.Text = nx_widestr("1")
    num = 1
  elseif num > nx_int(30) then
    form.ipt_num.Text = nx_widestr(num)
    num = 30
  end
  if form.cbtn_usemoney.Checked then
    local need_money = nx_int(10000 * num)
    form.lbl_prompt.Text = nx_widestr("@ui_attire_save_12")
    form.lbl_prize.Text = nx_widestr(format_money(need_money))
  else
    form.lbl_prompt.Text = nx_widestr("@ui_attire_save_25")
    form.lbl_prize.Text = gui.TextManager:GetFormatText("ui_attire_save_26", num)
  end
  form.set_num = num
end
function on_ipt_num_changed(ipt)
  local form = ipt.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_prize(form)
end
function on_imagegrid_equip_mousein_grid(grid, index)
  if not nx_find_custom(grid, "itemobj") then
    return
  end
  local obj = nx_custom(grid, "itemobj")
  if not nx_is_valid(obj) then
    return
  end
  nx_execute("tips_game", "show_goods_tip", obj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm, false)
end
function on_imagegrid_equip_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_copy_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_copy_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function query_arrire_item_photo(id, prop, sex)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return ""
  end
  local row = nx_int(item_query:GetItemPropByConfigID(id, "ArtPack"))
  local item_type = item_query:GetItemPropByConfigID(id, "ItemType")
  if sex == nil then
    sex = 0
    local game_client = nx_value("game_client")
    local client_palyer = game_client:GetPlayer()
    if nx_is_valid(client_palyer) then
      sex = client_palyer:QueryProp("Sex")
    end
  end
  if "Photo" == prop and 0 ~= sex then
    prop = "FemalePhoto"
    local result = item_static_query(row, prop, STATIC_DATA_ITEM_ART)
    if "" == result then
      prop = "Photo"
    end
  end
  return item_static_query(row, prop, STATIC_DATA_ITEM_ART)
end
function on_btn_copy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local have_equip = form.imagegrid_copy:GetItemName(0)
  local equip_config_id = form.imagegrid_equip:GetItemName(0)
  if have_equip == nil or nx_string(have_equip) == nx_string("") then
    return
  end
  if equip_config_id == nil or nx_string(equip_config_id) == nx_string("") then
    return
  end
  local num = nx_int(form.ipt_num.Text)
  if num <= nx_int(0) or num > nx_int(30) then
    return
  end
  if form.cbtn_useitem.Checked then
    if not HasBuchangeItem("item_attire_ty", num) then
      local gui = nx_value("gui")
      local info = gui.TextManager:GetText("16630")
      util_form_confirm("", info, MB_OK)
      return
    end
    if not show_buchang_notice_dialog(num) then
      return
    end
  else
    local money = form.lbl_prize.Text
    if not show_money_notice_dialog(money) then
      return
    end
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(100, -1, nx_current(), "play_pbar_animation", form, -1, -1)
    form.playing = true
  end
  form.btn_copy.Enabled = false
  form.ipt_num.Enabled = false
  form.imagegrid_equip.Enabled = false
end
function play_pbar_animation(form, config_id, num)
  local cur_value = form.pbar_animation.Value
  cur_value = cur_value + 20
  if form.pbar_animation.Value >= 100 then
    form.pbar_animation.Value = 100
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "play_pbar_animation", form)
      form.pbar_animation.Value = 0
      form.playing = false
    end
    form.btn_copy.Enabled = true
    form.ipt_num.Enabled = true
    form.imagegrid_equip.Enabled = true
    local use_type = 0
    if form.cbtn_useitem.Checked then
      use_type = 1
    end
    nx_execute("custom_sender", "custom_attire_equip_copy_msg", nx_string(form.select_item_id), form.set_num, use_type)
    return
  end
  form.pbar_animation.Value = cur_value
end
function on_imagegrid_equip_rightclick_grid(grid)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_equip:Clear()
  form.imagegrid_copy:Clear()
end
function format_money(money)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_money2")
  gui.TextManager:Format_AddParam(money)
  local ret = gui.TextManager:Format_GetText()
  return ret
end
function show_system_notice(text_id)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText(text_id), 2)
  end
end
function show_money_notice_dialog(show_money)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("attire_copy_3")
  gui.TextManager:Format_AddParam(show_money)
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return false
  end
  return true
end
function show_buchang_notice_dialog(amount)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("attire_copy_4", nx_int(amount))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return false
  end
  return true
end
function GetItemSex(item)
  if not nx_is_valid(item) then
    return 2
  end
  local item_type = item:QueryProp("ItemType")
  if nx_int(item_type) >= nx_int(ITEMTYPE_HUANPIMIN) and nx_int(item_type) <= nx_int(ITEMTYPE_HUANPIMAX) then
    local needsex = item_query_LogicPack(item, Item_UseSex)
    if nx_int(needsex) > nx_int(0) then
      needsex = needsex - 1
    else
      needsex = 2
    end
    return nx_number(needsex)
  elseif nx_int(item_type) >= nx_int(ITEMTYPE_EQUIP_MIN) and nx_int(item_type) <= nx_int(ITEMTYPE_EQUIP_MAX) then
    return nx_number(item:QueryProp("NeedSex"))
  end
  return 2
end
function HasBuchangeItem(buchang, amount)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return false
  end
  local nHasNumber = nx_int(0)
  local toolobj_list = view:GetViewObjList()
  for j, obj in pairs(toolobj_list) do
    if nx_is_valid(obj) then
      local config_id = obj:QueryProp("ConfigID")
      if nx_string(config_id) == nx_string(buchang) then
        local nCount = obj:QueryProp("Amount")
        nHasNumber = nx_int(nHasNumber) + nx_int(nCount)
      end
    end
  end
  if nx_int(amount) <= nx_int(nHasNumber) then
    return true
  end
  return false
end
