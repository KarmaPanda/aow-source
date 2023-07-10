require("util_functions")
require("define\\gamehand_type")
require("util_static_data")
require("util_gui")
require("share\\client_custom_define")
local binglu_type = {
  [0] = {
    text = "ui_binglu_tushou",
    typeid = 100,
    image = "tushou.png",
    name = "unarmed"
  },
  [1] = {
    text = "ui_binglu_dandao",
    typeid = 101,
    image = "dandao.png",
    name = "blade"
  },
  [2] = {
    text = "ui_binglu_danjian",
    typeid = 102,
    image = "danjian.png",
    name = "sword"
  },
  [3] = {
    text = "ui_binglu_bishou",
    typeid = 103,
    image = "bishou.png",
    name = "dagger"
  },
  [4] = {
    text = "ui_binglu_shuangdao",
    typeid = 104,
    image = "shuangdao.png",
    name = "dblade"
  },
  [5] = {
    text = "ui_binglu_shuangjian",
    typeid = 105,
    image = "shuangjian.png",
    name = "dsword"
  },
  [6] = {
    text = "ui_binglu_shuangci",
    typeid = 106,
    image = "shuangchi.png",
    name = "ddagger"
  },
  [7] = {
    text = "ui_binglu_changgun",
    typeid = 107,
    image = "changgun.png",
    name = "lstaff"
  },
  [8] = {
    text = "ui_binglu_duangun",
    typeid = 108,
    image = "duangun.png",
    name = "sstaff"
  },
  [9] = {
    text = "ui_binglu_anqi",
    typeid = 110,
    image = "anqi.png",
    name = "hidden"
  },
  [10] = {
    text = "ui_binglu_newweapon",
    typeid = 111,
    image = "qimen.png",
    name = "newweapon"
  }
}
local SENDTYPE_LETTER = 1
local SENDTYPE_BAG = 2
function main_form_init(self)
  self.Fixed = false
  nx_set_custom(self, "cur_sel_binglu", nil)
  nx_set_custom(self, "cur_sel_price", 0)
end
function open_form()
  local form = nx_execute("util_gui", "util_show_form", "form_stage_main\\form_tiguan\\form_binglu_huishou", true)
  if nx_is_valid(form) then
    form:Show()
    nx_execute("util_gui", "ui_show_attached_form", form)
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Desktop.Width - self.Width) / 2
  self.Top = (gui.Desktop.Height - self.Height) / 2
  nx_execute("form_stage_main\\form_role_info\\form_binglu", "open_form")
  local binglu_form = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(binglu_form) then
    gui.Desktop:ToFront(binglu_form)
  end
  local combobox = self.combobox_k
  combobox.DropListBox:ClearString()
  for i = 0, table.getn(binglu_type) do
    combobox.DropListBox:AddString(nx_widestr(util_text(binglu_type[i].text)))
  end
  data_bind_prop(self)
  self.rbtn_1.Checked = true
end
function on_main_form_close(self)
  local form_info = nx_value("form_stage_main\\form_role_info\\form_role_info")
  if nx_is_valid(form_info) and form_info.Visible then
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
  end
  ui_destroy_attached_form(self)
  del_data_bind_prop(self)
  nx_destroy(self)
end
function on_main_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_exchange(btn)
  local self = btn.ParentForm
  if not nx_is_valid(self) then
    return
  end
  if not nx_find_custom(self, "cur_sel_binglu") or self.cur_sel_binglu == nil then
    return
  end
  if not nx_find_custom(self, "cur_sel_price") or self.cur_sel_price == nil then
    return
  end
  if check_player_status() == false then
    return
  end
  local cur_lv = get_cur_level(self.cur_sel_binglu)
  if cur_lv == nil or cur_lv < get_binglu_level_limit() then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_damage")
    return
  end
  local need_money = self.cur_sel_price
  if money_is_enough(need_money) == false then
    show_system_notice("recover_failed_money")
    return
  end
  open_confirm_form()
end
function on_combobox_k_selected(combo)
  local self = combo.ParentForm
  if not nx_is_valid(self) then
    return
  end
  local index = combo.DropListBox.SelectIndex
  if not nx_find_custom(self, "cur_sel_binglu") or self.cur_sel_binglu == index then
    return
  end
  local binglu_info = binglu_type[index]
  if binglu_info == nil then
    return
  end
  local photo = "gui\\special\\tiguan\\" .. binglu_info.image
  self.imagegrid_qk:Clear()
  self.imagegrid_qk:AddItem(0, photo, "", 1, -1)
  self.imagegrid_qk.GridWidth = self.imagegrid_qk.Width
  self.imagegrid_qk.GridHeight = self.imagegrid_qk.Height
  self.imagegrid_qk.DrawMode = "Expand"
  self.cur_sel_binglu = index
  refresh_binglu(self)
end
function open_confirm_form()
  local self = nx_value("form_stage_main\\form_tiguan\\form_binglu_huishou")
  if not nx_is_valid(self) then
    return
  end
  if not nx_find_custom(self, "cur_sel_binglu") or self.cur_sel_binglu == nil then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "binglu_huishou")
  local rows = self.cur_sel_binglu
  if self.cur_sel_binglu >= 9 then
    rows = self.cur_sel_binglu + 1
  end
  local item_config = get_itemid_by_binglu_type(rows + 100)
  if item_config == nil or item_config == "" then
    return
  end
  local cur_lv, fill_value, cur_max_lv = get_binglu_info_by_rows(rows)
  if cur_lv == nil or fill_value == nil or cur_max_lv == nil then
    return
  end
  local total_fill_value = calu_total_fill_val(rows, cur_lv, fill_value, cur_max_lv)
  local totalnum = calu_count_by_total_fill_value(item_config, total_fill_value)
  local price = calu_money(totalnum)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_binglu_recover_cost", binglu_type[self.cur_sel_binglu].text, gui.TextManager:GetText(nx_string(item_config)), nx_int(totalnum), nx_int(price)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:Show()
  gui.Desktop:ToFront(dialog)
  dialog.AbsLeft = (gui.Width - dialog.Width) / 2
  dialog.AbsTop = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "binglu_huishou_confirm_return")
  if res == "ok" then
    if check_player_status() == false then
      return
    end
    if money_is_enough(price) == false then
      show_system_notice("recover_failed_money")
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    local send_type = 0
    if self.rbtn_1.Checked == true then
      send_type = SENDTYPE_LETTER
    elseif self.rbtn_2.Checked == true then
      send_type = SENDTYPE_BAG
    else
      return
    end
    local binglu_type = rows + 100
    if binglu_type == 111 then
      binglu_type = binglu_type + 11
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MODIFY_BINGLU), nx_int(2), nx_int(binglu_type), send_type)
  end
end
function data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:AddTableBind("binglu_rank_rec", self, nx_current(), "refresh_binglu")
end
function del_data_bind_prop(self)
  if not nx_is_valid(self) then
    return
  end
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelTableBind("binglu_rank_rec", self)
end
function get_cur_level(binglu_type_index)
  local rows = binglu_type_index
  if 9 <= binglu_type_index then
    rows = binglu_type_index + 1
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindRecord("binglu_rank_rec") then
    return client_player:QueryRecord("binglu_rank_rec", rows, 0)
  end
  return nil
end
function get_cur_fill(binglu_type_index)
  local rows = binglu_type_index
  if binglu_type_index == 9 then
    rows = binglu_type_index + 1
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindRecord("binglu_rank_rec") then
    return client_player:QueryRecord("binglu_rank_rec", rows, 1)
  end
  return nil
end
function calu_money(item_count)
  if item_count == nil or item_count == 0 then
    return nil
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\ExchangePrice.ini")
  if nx_is_valid(ini) then
    return ini:ReadInteger(0, nx_string("Cost"), 0) * item_count
  end
  return nil
end
function money_is_enough(money)
  local mgr = nx_value("CapitalModule")
  if nx_is_valid(mgr) then
    return money <= mgr:GetCapital(2)
  end
  return false
end
function show_system_notice(text_id)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText(text_id), 2)
  end
end
function check_player_status()
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if nx_int(logic_state) == nx_int(101) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_baitanzhong")
    return false
  end
  local isexchange = client_player:QueryProp("IsExchange")
  if nx_int(isexchange) == 1 then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_jiaoyizhong")
    return false
  end
  local OnTransToolState = client_player:QueryProp("OnTransToolState")
  if nx_int(OnTransToolState) ~= nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_machezhong")
    return false
  end
  if nx_int(logic_state) == nx_int(1) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_fighting")
    return false
  end
  if nx_int(logic_state) == nx_int(121) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_zhongshang")
    return false
  end
  local dead = client_player:QueryProp("Dead")
  if nx_int(dead) > nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_siren")
    return false
  end
  if nx_int(logic_state) == nx_int(120) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_siren")
    return false
  end
  local self = game_visual:GetPlayer()
  local pos_x = self.PositionX
  local pos_y = self.PositionY
  local pos_z = self.PositionZ
  local terrain = game_visual.Terrain
  if terrain:GetWalkWaterExists(pos_x, pos_z) and pos_y < terrain:GetWalkWaterHeight(pos_x, pos_z) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_shuizhong")
    return false
  end
  return true
end
function get_itemid_by_binglu_type(binglu_type)
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\binglu_exchange.ini")
  if nx_is_valid(ini) then
    if 110 < binglu_type then
      binglu_type = binglu_type + 11
    end
    local sec_index = ini:FindSectionIndex(nx_string(binglu_type))
    return ini:ReadString(sec_index, nx_string("ID"), "")
  end
  return nil
end
function calu_count_by_total_fill_value(config_id, total_fill_value)
  local ItemQuery = nx_value("ItemQuery")
  local addvalue = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("AddValue"))
  if nx_int(addvalue) <= nx_int(0) then
    return 0
  end
  local total_num = nx_int(total_fill_value) / nx_int(addvalue)
  return nx_int(total_num)
end
function get_binglu_info_by_rows(rows)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:FindRecord("binglu_rank_rec") then
    local CurLevel = client_player:QueryRecord("binglu_rank_rec", rows, 0)
    local FillValue = client_player:QueryRecord("binglu_rank_rec", rows, 1)
    local CurMaxLevel = client_player:QueryRecord("binglu_rank_rec", rows, 2)
    return CurLevel, FillValue, CurMaxLevel
  end
  return nil, nil, nil
end
function get_binglu_level_limit()
  local ini = nx_execute("util_functions", "get_ini", "share\\Skill\\BingLu\\binglu_exchange.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex("limit")
    return ini:ReadInteger(sec_index, nx_string("level_min"), -1)
  end
  return -1
end
function calu_total_fill_val(rows, cur_lv, fill_value, cur_max_lv)
  local binglu_manager = nx_value("binglu_manager")
  if not nx_is_valid(binglu_manager) then
    return 0
  end
  local total_fill_value = 0
  if 0 < cur_lv then
    for index = 0, cur_lv - 1 do
      total_fill_value = total_fill_value + binglu_manager:GetValueNeed(rows, index)
    end
  end
  local real_max_lv = 0
  if cur_max_lv == 0 then
    real_max_lv = binglu_manager:GetMaxLevel(rows)
  else
    real_max_lv = cur_max_lv
  end
  if cur_lv < real_max_lv then
    total_fill_value = total_fill_value + fill_value
  end
  return total_fill_value
end
function refresh_binglu(self)
  local gui = nx_value("gui")
  self.mltbox_1:Clear()
  self.imagegrid_bl.tips_config = nil
  if not nx_find_custom(self, "cur_sel_binglu") or self.cur_sel_binglu == nil then
    return
  end
  if not nx_find_custom(self, "cur_sel_price") or self.cur_sel_price == nil then
    return
  end
  local Level_Limit = get_binglu_level_limit()
  if Level_Limit == -1 then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "recover_failed_damage")
    return
  end
  local rows = self.cur_sel_binglu
  if self.cur_sel_binglu >= 9 then
    rows = self.cur_sel_binglu + 1
  end
  local CurLevel, FillValue, CurMaxLevel = get_binglu_info_by_rows(rows)
  if CurLevel ~= nil and FillValue ~= nil and CurMaxLevel ~= nil then
    local TotalFillValue = 0
    if Level_Limit <= CurLevel then
      TotalFillValue = calu_total_fill_val(rows, CurLevel, FillValue, CurMaxLevel)
    end
    if nx_find_custom(self, "imagegrid_bl") and nx_find_custom(self, "lbl_1") and nx_find_custom(self, "mltbox_1") then
      self.imagegrid_bl:Clear()
      local item_config = get_itemid_by_binglu_type(rows + 100)
      if item_config ~= nil or item_config ~= "" then
        local ItemQuery = nx_value("ItemQuery")
        local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
        self.imagegrid_bl:AddItem(0, photo, "", 1, -1)
        self.imagegrid_bl.GridWidth = self.imagegrid_bl.Width
        self.imagegrid_bl.GridHeight = self.imagegrid_bl.Height
        self.imagegrid_bl.DrawMode = "Expand"
        self.imagegrid_bl.tips_config = item_config
        local totalnum = calu_count_by_total_fill_value(item_config, TotalFillValue)
        self.lbl_1.Text = nx_widestr(nx_int(totalnum)) .. nx_widestr(gui.TextManager:GetFormatText("ui_binglu_tip04"))
        local price = calu_money(totalnum)
        if price ~= nil and Level_Limit <= CurLevel then
          self.mltbox_1:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_binglu_cost", nx_int(price))), -1)
          self.cur_sel_price = price
        else
          self.mltbox_1:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_binglu_cost", nx_int(0))), -1)
          self.cur_sel_price = price
        end
      end
    end
  end
end
function on_mousein_grid(grid, index)
  local config_id = nx_custom(grid, "tips_config")
  if config_id == nil or nx_string(config_id) == nx_string("") then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not item_query:FindItemByConfigID(config_id) then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
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
