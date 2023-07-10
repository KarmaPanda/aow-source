require("share\\view_define")
require("share\\itemtype_define")
require("share\\logicstate_define")
require("define\\tip_define")
require("define\\gamehand_type")
require("custom_handler")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("util_static_data")
require("util_gui")
local COST_ITEM_INI = "share\\Item\\Inscription_cost.ini"
local NAME_LEN = "share\\Item\\Inscription_num.ini"
local FORM_PATH = "form_stage_main\\form_life\\form_mingke_equip"
function on_main_form_init(self)
  self.sel_view = -1
  self.sel_index = -1
  self.need_item = ""
  self.need_amount = 0
  self.need_money = 0
  self.is_item = false
end
function on_main_form_open(self)
  self.sel_view = -1
  self.sel_index = -1
  self.need_item = ""
  self.need_amount = 0
  self.need_money = 0
  self.tips_dialog = nx_null()
  self.redit_desc.Remember = true
  self.redit_desc.ReturnAllFormat = true
  self.redit_desc.ReturnFontFormat = false
  self.btn_ok.Enabled = false
  self.btn_start.Enabled = false
  self.mltbox_cost.Visible = false
  nx_execute("util_gui", "ui_show_attached_form", self)
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  local tips_dialog = nx_value("mingke_equip_form_confirm")
  if nx_is_valid(tips_dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", tips_dialog.cancel_btn)
  end
  ui_destroy_attached_form(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if form.sel_view ~= -1 or form.sel_index ~= -1 then
    nx_execute("custom_sender", "custom_equip_name_start", 2, form.sel_view, form.sel_index)
  end
  on_main_form_close(form)
end
function on_btn_help_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_active(form)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", form)
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if form.sel_index == -1 or form.sel_view == -1 then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  show_equip_name(form, item)
  Show_equip_desc(form, item)
  form.btn_ok.Enabled = false
  form.btn_start.Enabled = false
end
function on_btn_ok_click(btn)
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_EUIQP_NAME)
  if open ~= true then
    return
  end
  if not check_player_status() then
    return
  end
  local form = btn.ParentForm
  if form.sel_view == -1 or form.sel_index == -1 then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local src_viewid = form.sel_view
  local src_pos = form.sel_index
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    return
  end
  if not check_item(item) then
    return
  end
  local equip_name = nx_function("ext_ws_replace", form.ipt_name.Text, nx_widestr("<br/>"), nx_widestr(""))
  local equip_desc = nx_function("ext_ws_replace", form.redit_desc.Text, nx_widestr("<br/>"), nx_widestr(""))
  if not check_input_info(form, item, equip_name, equip_desc) then
    return
  end
  if not check_need_item(item) then
    return
  end
  local gui = nx_value("gui")
  local item_name = gui.TextManager:GetText(form.need_item)
  gui.TextManager:Format_SetIDName("mingke_cost_tip")
  gui.TextManager:Format_AddParam(item_name)
  gui.TextManager:Format_AddParam(form.need_amount)
  gui.TextManager:Format_AddParam(nx_int(form.need_money))
  local text = gui.TextManager:Format_GetText()
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "mingke_equip")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  if nx_is_valid(dialog) then
    local res = nx_wait_event(100000000, dialog, "mingke_equip_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_equip_name_start", 3, form.sel_view, form.sel_index, equip_name, equip_desc)
    end
  end
end
function on_btn_more_click(btn)
end
function on_imagegrid_wq_select_changed(grid, index)
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_EUIQP_NAME)
  if open ~= true then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  if not grid:IsEmpty(index) then
    custom_sysinfo(1, 1, 1, 2, "mingke_wrong_exist")
    return
  end
  if not check_player_status() then
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
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
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
  if not check_item(item) then
    return
  end
  local photo, amount = get_photo_amont(item)
  if "" == photo then
    gameHand:ClearHand()
    return
  end
  local form = grid.ParentForm
  clearform(form)
  grid:AddItem(index, photo, "", 1, -1)
  show_equip_name(form, item)
  Show_equip_desc(form, item)
  show_equip_cost(form, item)
  form.sel_view = src_viewid
  form.sel_index = src_pos
  gameHand:ClearHand()
  nx_execute("custom_sender", "custom_equip_name_start", 1, form.sel_view, form.sel_index)
end
function on_imagegrid_wq_rightclick_grid(grid, index)
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_EUIQP_NAME)
  if open ~= true then
    return
  end
  local form = grid.ParentForm
  if grid:IsEmpty(index) then
    return
  end
  if form.sel_view == -1 and form.sel_index == -1 then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local src_viewid = form.sel_view
  local src_pos = form.sel_index
  if not GoodsGrid:IsToolBoxViewport(nx_int(src_viewid)) then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", src_viewid, src_pos)
  if not nx_is_valid(item) then
    return
  end
  nx_execute("custom_sender", "custom_equip_name_start", 2, form.sel_view, form.sel_index)
  clearform(form)
end
function on_imagegrid_wq_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if grid:IsEmpty(index) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_mingke_ep_tip")
    local x = grid.AbsLeft
    local y = grid.AbsTop
    nx_execute("tips_game", "show_text_tip", text, x, y, 0, grid.ParentForm)
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
function on_imagegrid_wq_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ipt_name_get_focus(ipt)
  local form = ipt.ParentForm
  set_input_max_len(form, 1)
end
function on_redit_desc_get_focus(ipt)
  local form = ipt.ParentForm
  set_input_max_len(form, 2)
end
function on_chat_redit_changed(ipt)
  local form = ipt.ParentForm
  form.btn_ok.Enabled = true
  form.btn_start.Enabled = true
end
function on_ipt_name_changed(ipt)
  local form = ipt.ParentForm
  if form.is_item then
    form.btn_ok.Enabled = true
    form.btn_start.Enabled = true
  else
    form.is_item = true
  end
end
function set_input_max_len(form, ipt_type)
  if not nx_is_valid(form) then
    return
  end
  if ipt_type ~= 1 and ipt_type ~= 2 then
    return
  end
  if form.sel_view == -1 or form.sel_index == -1 then
    return
  end
  local item = nx_execute("goods_grid", "get_view_item", form.sel_view, form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local ini = get_ini(NAME_LEN)
  if not nx_is_valid(ini) then
    return
  end
  local name = ""
  if ipt_type == 1 then
    name = "Name"
  elseif ipt_type == 2 then
    name = "Desc"
  end
  local color_lv = item:QueryProp("ColorLevel")
  local count = ini:GetSectionCount()
  local max_len = 0
  for i = 0, count do
    local lv = ini:ReadInteger(i, "ColorLevel", 0)
    local name_1 = ini:ReadString(i, "job", "")
    if color_lv == lv and name_1 == name then
      max_len = ini:ReadInteger(i, "Number", 0)
    elseif color_lv == lv and name_1 == name then
      max_len = ini:ReadInteger(i, "Number", 0)
    end
  end
  if ipt_type == 1 then
    form.ipt_name.MaxLength = max_len
  elseif ipt_type == 2 then
    form.redit_desc.MaxLength = max_len + 1
  end
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
function check_item(item)
  if not nx_is_valid(item) then
    return false
  end
  local nNewWorldItem = item:QueryProp("NewWorldItem")
  if nNewWorldItem == 1 then
    custom_sysinfo(1, 1, 1, 2, "failed_recast_newworld002")
    return false
  end
  local RecoverFlag = item:QueryProp("RecoverFlag")
  if RecoverFlag ~= 0 then
    custom_sysinfo(1, 1, 1, 2, "sys_equip_damaged")
    return false
  end
  if not check_item_type(item) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_no")
    return false
  end
  local color_level = item:QueryProp("ColorLevel")
  if nx_number(color_level) ~= 5 and nx_number(color_level) ~= 6 then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_jinyu")
    return false
  end
  local bind_status = item:QueryProp("BindStatus")
  if nx_int(bind_status) <= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_notruss")
    return false
  end
  return true
end
function check_item_type(item)
  if not nx_is_valid(item) then
    return false
  end
  local ItemType = item:QueryProp("ItemType")
  if ItemType == ITEMTYPE_WEAPON_GLOVES then
    return true
  end
  if ItemType > ITEMTYPE_WEAPON_MIN and ItemType <= ITEMTYPE_WEAPON_QIMEN_MAX then
    return true
  end
  if ItemType == ITEMTYPE_EQUIP_HAT or ItemType == ITEMTYPE_EQUIP_CLOTH or ItemType == ITEMTYPE_EQUIP_PANTS or ItemType == ITEMTYPE_EQUIP_SHOES or ItemType == ITEMTYPE_EQUIP_LEG or ItemType == ITEMTYPE_EQUIP_WRIST or ItemType == ITEMTYPE_EQUIP_NECKLACE or ItemType == ITEMTYPE_EQUIP_EARRING or ItemType == ITEMTYPE_EQUIP_FINGERRING then
    return true
  end
  return false
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
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_siren")
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(LS_FIGHTING) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_STALLED) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_baitanzhong")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_SERIOUS_INJURY) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_zhongshang")
    return false
  end
  if nx_int(logic_state) == nx_int(LS_DIED) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_siren")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_machezhong")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_shuizhong")
    return false
  end
  return true
end
function check_need_item(item)
  if not nx_is_valid(item) then
    return false
  end
  local color_lv = item:QueryProp("ColorLevel")
  local ItemType = item:QueryProp("ItemType")
  local ini = get_ini(COST_ITEM_INI)
  if not nx_is_valid(ini) then
    return false
  end
  local money = 0
  local item_config = ""
  local item_amount = 0
  local count = ini:GetSectionCount()
  for i = 0, count do
    local lv = ini:ReadInteger(i, "ColorLevel", -1)
    local item_type = ini:ReadInteger(i, "ItemType", -1)
    if color_lv == lv and ItemType == item_type then
      money = ini:ReadInteger(i, "Cost", 0)
      item_config = ini:ReadString(i, "Consume", "")
      item_amount = ini:ReadInteger(i, "Amount", 0)
      break
    end
  end
  if money <= 0 then
    return false
  end
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return false
  end
  if not CapitalModule:CanDecCapital(2, money) then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_cost2")
    return false
  end
  if item_config ~= "" and item_amount ~= 0 then
    local GoodsGrid = nx_value("GoodsGrid")
    if not nx_is_valid(GoodsGrid) then
      return false
    end
    local count = GoodsGrid:GetItemCount(item_config)
    if item_amount > count then
      custom_sysinfo(1, 1, 1, 2, "mingke_failed_cost1")
      return false
    end
  end
  return true
end
function check_input_info(form, item, equip_name, equip_desc)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_is_valid(item) then
    return false
  end
  local ini = get_ini(NAME_LEN)
  if not nx_is_valid(ini) then
    return false
  end
  local count = ini:GetSectionCount()
  local color_lv = item:QueryProp("ColorLevel")
  local new_name = equip_name
  if new_name == nx_widestr("") then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_noname")
    return false
  end
  local new_desc = equip_desc
  local name_len = nx_ws_length(new_name)
  if name_len <= 0 then
    custom_sysinfo(1, 1, 1, 2, "mingke_failed_noname")
    return false
  end
  local desc_len = nx_ws_length(new_desc)
  local name_res = false
  local desc_res = false
  local len_res = false
  for i = 0, count do
    local lv = ini:ReadInteger(i, "ColorLevel", 0)
    local name = ini:ReadString(i, "job", "")
    if color_lv == lv and name == "Name" then
      if name_len <= ini:ReadInteger(i, "Number", 0) then
        name_res = true
      end
    elseif color_lv == lv and name == "Desc" and desc_len <= ini:ReadInteger(i, "Number", 0) then
      desc_res = true
    end
    if name_res and desc_res then
      len_res = true
    end
  end
  if not len_res then
    if not name_res and not desc_res then
      custom_sysinfo(1, 1, 1, 2, "mingke_wrong_both")
    elseif not name_res then
      custom_sysinfo(1, 1, 1, 2, "mingke_name_length")
    elseif not desc_res then
      custom_sysinfo(1, 1, 1, 2, "mingke_desc_length")
    end
    return
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return false
  end
  if not CheckWords:CheckChinese(new_name) then
    custom_sysinfo(1, 1, 1, 2, "mingke_wrong_name")
    return false
  end
  if not CheckWords:CheckBadWords(new_name) then
    custom_sysinfo(1, 1, 1, 2, "mingke_wrong_name")
    return false
  end
  if not CheckWords:CheckChineseExp(new_desc) then
    custom_sysinfo(1, 1, 1, 2, "mingke_wrong_desc")
    return false
  end
  if not CheckWords:CheckBadWords(new_desc) then
    custom_sysinfo(1, 1, 1, 2, "mingke_wrong_desc")
    return false
  end
  return true
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
  form.ipt_name.MaxLength = 0
  form.ipt_name.Text = text
end
function Show_equip_desc(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  local data = nx_widestr("")
  if item:FindProp("CustomNameDesc") then
    data = item:QueryProp("CustomNameDesc")
  end
  if data ~= nx_widestr("") then
    local list = util_split_wstring(data, nx_widestr("&"))
    if table.getn(list) >= 2 then
      text = list[2]
    end
  else
    local name = item:QueryProp("ConfigID")
    local desc = "desc_" .. name
    text = gui.TextManager:GetText(desc)
  end
  form.redit_desc.MaxLength = 0
  form.redit_desc.Text = text
end
function show_equip_cost(form, item)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(item) then
    return
  end
  local color_lv = item:QueryProp("ColorLevel")
  local ItemType = item:QueryProp("ItemType")
  local ini = get_ini(COST_ITEM_INI)
  if not nx_is_valid(ini) then
    return
  end
  local money = 0
  local item_config = ""
  local item_amount = 0
  local count = ini:GetSectionCount()
  for i = 0, count do
    local lv = ini:ReadInteger(i, "ColorLevel", -1)
    local item_type = ini:ReadInteger(i, "ItemType", -1)
    if color_lv == lv and ItemType == item_type then
      money = ini:ReadInteger(i, "Cost", 0)
      item_config = ini:ReadString(i, "Consume", "")
      item_amount = ini:ReadInteger(i, "Amount", 0)
      break
    end
  end
  if money <= 0 then
    return
  end
  form.need_money = money
  if item_config ~= "" and item_amount ~= 0 then
    local item_query = nx_value("ItemQuery")
    if nx_is_valid(item_query) then
      local value = item_query:GetItemPropByConfigID(item_config, "Photo")
      if nil ~= value and "" ~= nx_string(value) then
        form.imagegrid_item:AddItem(0, value, "", 1, -1)
        form.need_item = item_config
        form.need_amount = item_amount
      end
    end
  end
  local gui = nx_value("gui")
  local item_name = gui.TextManager:GetText(form.need_item)
  gui.TextManager:Format_SetIDName("mingke_cost")
  gui.TextManager:Format_AddParam(item_name)
  gui.TextManager:Format_AddParam(form.need_amount)
  gui.TextManager:Format_AddParam(nx_int(form.need_money))
  local text = gui.TextManager:Format_GetText()
  form.mltbox_cost:Clear()
  form.mltbox_cost:AddHtmlText(text, -1)
  form.mltbox_cost.Visible = true
end
function clearform(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_eq:Clear()
  form.imagegrid_eq:SetSelectItemIndex(-1)
  form.ipt_name.Text = nx_widestr("")
  form.redit_desc.Text = nx_widestr("")
  form.imagegrid_item:Clear()
  form.imagegrid_item:SetSelectItemIndex(-1)
  form.need_item = ""
  form.sel_view = -1
  form.sel_index = -1
  form.need_amount = 0
  form.need_money = 0
  form.mltbox_cost:Clear()
  form.mltbox_cost.Visible = false
  form.btn_ok.Enabled = false
  form.btn_start.Enabled = false
  form.is_item = false
end
function on_imagegrid_item_get_capture(grid, index)
  if grid:IsEmpty(index) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_mingke_it_tip")
    local x = grid.AbsLeft
    local y = grid.AbsTop
    nx_execute("tips_game", "show_text_tip", text, x, y, 0, grid.ParentForm)
    return
  end
  local form = grid.ParentForm
  if form.need_item ~= "" then
    local x = grid:GetMouseInItemLeft()
    local y = grid:GetMouseInItemTop()
    nx_execute("tips_game", "show_tips_by_config", form.need_item, x, y, form)
  end
end
function on_imagegrid_item_lost_capture(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function open_form()
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return
  end
  local open = SwitchManager:CheckSwitchEnable(ST_FUNCTION_EUIQP_NAME)
  if open ~= true then
    return
  end
  local form = util_get_form(FORM_PATH, true)
  if nx_is_valid(form) then
    if form.Visible then
      form.Visible = false
      form:Close()
    else
      form:Show()
      form.Visible = true
    end
  end
end
function on_equip_name_succeed()
  local form = nx_value(FORM_PATH)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    local item_name = gui.TextManager:GetText(form.need_item)
    custom_sysinfo(1, 1, 1, 2, "mingke_success_cost", item_name, form.need_amount, nx_int(form.need_money))
    clearform(form)
  end
end
