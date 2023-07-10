require("util_static_data")
require("util_functions")
require("share\\itemtype_define")
local KARMA_PRIZE_TYPE_ADD = 10
local KARMA_PRIZE_TYPE_DEC = -10
local KARMA_PRIZE_TYPE_MONEY_BIND = 1
local KARMA_PRIZE_TYPE_MONEY = 2
local KARMA_PRIZE_TYPE_ITEM = 3
local KARMA_PRIZE_TYPE_BUFFER = 4
function main_form_init(self)
  self.Fixed = false
  self.event_type = ""
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  self.mltbox_info:Clear()
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "karma_prize_confirm_return", "cancle")
  else
    nx_gen_event(form, event_type .. "_" .. "karma_prize_confirm_return", "cancle")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function on_btn_giveup_click(btn)
end
function on_btn_accept_click(btn)
  local form = btn.ParentForm
  local event_type = form.event_type
  if event_type == "" then
    nx_gen_event(form, "karma_prize_confirm_return", "ok")
  else
    nx_gen_event(form, event_type .. "_" .. "karma_prize_confirm_return", "ok")
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return 1
end
function show_karma_prize_confirm(form, prize_type, time_out_text, common_text, ...)
  local photo = ""
  local num = 0
  form.data_prize_type = nx_int(prize_type)
  if nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ADD) then
    photo = "gui\\special\\sns_new\\btn_enchou_price\\good.png"
    num = arg[1]
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_DEC) then
    photo = "gui\\special\\sns_new\\btn_enchou_price\\bad.png"
    num = arg[1]
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY_BIND) then
    photo = "icon\\prop\\suiyinzi.png"
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY) then
    photo = "icon\\prop\\yinzi01.png"
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ITEM) then
    if table.getn(arg) == 0 then
      return
    end
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local item_config = nx_string(arg[1])
    if item_config == "" then
      return
    end
    num = nx_int(arg[2])
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(item_config, "ItemType"))
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", item_config, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(item_config, "Photo")
    end
    form.data_config = item_config
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_BUFFER) then
    if table.getn(arg) == 0 then
      return
    end
    local buffer_id = nx_string(arg[1])
    if buffer_id == "" then
      return
    end
    photo = buff_static_query(nx_string(buffer_id), "Photo")
    form.data_config = buffer_id
  end
  add_karma_prize_info(form, photo, num, time_out_text, common_text)
end
function on_imagegrid_item_mousein_grid(self, index)
  if not nx_find_custom(self.ParentForm, "data_prize_type") then
    return
  end
  local prize_type = self.ParentForm.data_prize_type
  if nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_ITEM) then
    if not nx_find_custom(self.ParentForm, "data_config") then
      return
    end
    nx_execute("tips_game", "show_tips_by_config", self.ParentForm.data_config, self.ParentForm.Left + self.ParentForm.Width - 30, self.ParentForm.Top - 28)
  elseif nx_number(prize_type) == nx_number(KARMA_PRIZE_TYPE_BUFFER) then
    if not nx_find_custom(self.ParentForm, "data_config") then
      return
    end
    local str_index = "desc_" .. nx_string(self.ParentForm.data_config) .. "_0"
    local gui = nx_value("gui")
    nx_execute("tips_game", "show_text_tip", nx_widestr(gui.TextManager:GetText(str_index)), self.ParentForm.Left + self.ParentForm.Width - 30, self.ParentForm.Top - 28)
  end
end
function on_imagegrid_item_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function add_karma_prize_info(form, photo, num, time_out_text, common_text)
  form.imagegrid_item:Clear()
  form.imagegrid_item:AddItem(0, photo, nx_widestr(""), nx_int(num), -1)
  form.lbl_timeout.Text = nx_widestr(time_out_text)
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(common_text), -1)
end
function update_time(current_prize_type, time_out_text, ...)
  local prize_confirm = nx_value("form_common\\form_karma_prize_confirm")
  if not nx_is_valid(prize_confirm) then
    return
  end
  if not nx_find_custom(prize_confirm, "data_prize_type") then
    return
  end
  local check_type = arg[1]
  if check_type == nil then
    local data_prize_type = prize_confirm.data_prize_type
    if nx_number(data_prize_type) == nx_number(KARMA_PRIZE_TYPE_MONEY_BIND) then
      data_prize_type = KARMA_PRIZE_TYPE_MONEY
    end
    if nx_number(data_prize_type) ~= nx_number(current_prize_type) then
      return
    end
  end
  if nx_string(time_out_text) == "" then
    if nx_find_custom(prize_confirm, "configid") and nx_string(prize_confirm.configid) ~= "" then
      nx_execute("custom_sender", "apply_add_npc_relation", nx_int(8), nx_string(prize_confirm.configid), nx_int(0))
    end
    prize_confirm:Close()
    return
  end
  prize_confirm.lbl_timeout.Text = nx_widestr(time_out_text)
end
