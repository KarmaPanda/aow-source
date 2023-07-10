require("util_functions")
local item_id1 = "guild_manger_tool_01"
local item_id2 = "guild_manger_tool_02"
function main_form_init(form)
  form.item_id = ""
end
function main_form_open(form)
  form.combobox_item.OnlySelect = true
  form.combobox_item.DropListBox:ClearString()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return 0
  end
  local gui = nx_value("gui")
  local item_name1 = gui.TextManager:GetText(item_id1)
  local item_name2 = gui.TextManager:GetText(item_id2)
  form.combobox_item.DropListBox:AddString(item_name1)
  form.combobox_item.DropListBox:AddString(item_name2)
  form.combobox_item.DropListBox.SelectIndex = 0
end
function main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if form.item_id == nil or form.item_id == "" then
    return false
  end
  nx_gen_event(form, "return_item_id", "ok", form.item_id)
  form:Close()
end
function on_combobox_item_selected(combobox)
  local form = combobox.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local select_index = combobox.DropListBox.SelectIndex
  if select_index == 0 then
    form.item_id = item_id1
  else
    form.item_id = item_id2
  end
end
