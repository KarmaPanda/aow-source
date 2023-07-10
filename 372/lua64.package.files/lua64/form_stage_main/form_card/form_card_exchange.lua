require("util_gui")
require("role_composite")
require("util_static_data")
require("define\\sysinfo_define")
require("share\\client_custom_define")
require("tips_data")
local FORM_EXCHANGE = "form_stage_main\\form_card\\form_card_exchange"
local image_lable = "\\gui\\special\\card\\"
local inmage_path = "gui\\language\\ChineseS\\card\\"
local CLIENT_CUSTOMMSG_CARD_EXCHANGE = 3
local card_exchange_table = {}
local card_get_table = {}
function main_form_init(form)
  form.Fixed = false
  form.old_card_id = 0
  form.new_card_id = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_exchange_list(form)
  init_actived_list(form)
  data_bind_prop(form)
end
function on_main_form_close(form)
  card_get_table = {}
  card_exchange_table = {}
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("CardRec", form, nx_current(), "on_update_card_rec")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("CardRec", form)
  end
end
function on_update_card_rec(form, tablename, ttype, line, col)
  init_actived_list(form)
end
function open_form()
  local form = nx_value(FORM_EXCHANGE)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_show_form(FORM_EXCHANGE, true)
end
function on_cmb_card1_selected(self)
  local form = self.ParentForm
  form.old_card_id = card_get_table[self.DropListBox.SelectIndex]
  if nil == form.old_card_id then
    card_exchange_table = {}
    init_actived_list(form)
    init_exchange_list(form)
    form.lbl_card1.BackImage = ""
    form.lbl_card2.BackImage = ""
    return
  end
  local photo = image_lable .. nx_string(form.old_card_id) .. ".png"
  form.lbl_card1.BackImage = photo
  form.lbl_card2.BackImage = ""
  get_exchange_list_by_type(form, form.old_card_id)
end
function on_cmb_card2_selected(self)
  local form = self.ParentForm
  form.new_card_id = card_exchange_table[self.DropListBox.SelectIndex]
  local photo = image_lable .. nx_string(form.new_card_id) .. ".png"
  form.lbl_card2.BackImage = photo
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local list = collect_card_manager:GetNeedItemNumber(form.new_card_id)
  local count = table.getn(list)
  if count < 1 then
    return
  end
  form.lbl_number.Text = nx_widestr(list[1])
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if form.old_card_id == 0 or form.new_card_id == 0 then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_card_exchangeok", name)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CARD), nx_int(CLIENT_CUSTOMMSG_CARD_EXCHANGE), nx_int(form.old_card_id), nx_int(form.new_card_id))
    form:Close()
  end
end
function init_exchange_list(form)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  local list = collect_card_manager:GetExchangeList()
  local count = table.getn(list)
  if count < 1 then
    return
  end
  local gui = nx_value("gui")
  form.cmb_card2.DropListBox:ClearString()
  form.cmb_card2.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
  for i = 1, count do
    local id = list[i]
    form.cmb_card2.DropListBox:AddString(gui.TextManager:GetText("card_item_" .. nx_string(id)))
    form.cmb_card2.DropListBox.SelectIndex = 0
    table.insert(card_exchange_table, id)
  end
  form.cmb_card2.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
end
function get_exchange_list_by_type(form, card_id)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  card_exchange_table = {}
  local list = collect_card_manager:GetExchangeListByType(card_id)
  local count = table.getn(list)
  if count < 1 then
    return
  end
  local gui = nx_value("gui")
  form.cmb_card2.DropListBox:ClearString()
  form.cmb_card2.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
  for i = 1, count do
    local id = list[i]
    form.cmb_card2.DropListBox:AddString(gui.TextManager:GetText("card_item_" .. nx_string(id)))
    form.cmb_card2.DropListBox.SelectIndex = 0
    table.insert(card_exchange_table, id)
  end
  form.cmb_card2.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
end
function init_actived_list(form)
  if not nx_is_valid(form) then
    return
  end
  local collect_card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(collect_card_manager) then
    return
  end
  card_get_table = {}
  local list = collect_card_manager:GetCardActivedUnlimitedList()
  local count = table.getn(list)
  if count < 1 then
    return
  end
  local gui = nx_value("gui")
  form.cmb_card1.DropListBox:ClearString()
  form.cmb_card1.DropListBox:AddString(gui.TextManager:GetText("ui_card_state_0"))
  for i = 1, count do
    local id = list[i]
    form.cmb_card1.DropListBox:AddString(gui.TextManager:GetText("card_item_" .. nx_string(id)))
    form.cmb_card1.DropListBox.SelectIndex = 0
    table.insert(card_get_table, id)
  end
  form.cmb_card1.Text = nx_widestr(gui.TextManager:GetText("ui_card_state_0"))
end
