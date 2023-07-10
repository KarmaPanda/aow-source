local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
local FRIEND_REC_NAME = 1
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.combobox_friend
  get_combobox_list(self, FRIEND_REC)
  get_combobox_list(self, BUDDY_REC)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function ok_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "input_search_return", "ok", nx_widestr(form.combobox_friend.Text))
  form:Close()
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  nx_gen_event(form, "input_search_return", "cancel")
  form:Close()
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function get_combobox_list(form, table_name)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  for i = 0, rows - 1 do
    local friend_name = nx_widestr(player:QueryRecord(table_name, i, FRIEND_REC_NAME))
    form.combobox_friend.DropListBox:AddString(friend_name)
  end
end
