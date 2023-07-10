local LOG_MEMORY = "log_memory"
function create_log_memory()
  local log_memory = nx_value(LOG_MEMORY)
  if nx_is_valid(log_memory) then
    return 1
  end
  local log_memory = nx_create("ArrayList", nx_current())
  nx_set_value(LOG_MEMORY, log_memory)
  return 1
end
function destroy_log_memory()
  local log_memory = nx_value(LOG_MEMORY)
  if nx_is_valid(log_memory) then
    nx_destroy(log_memory)
  end
  return 1
end
function main_form_init(self)
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.log_list.curr_undo_pos = 0
  init(self.log_list)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function init(self)
  local log_memory = nx_value(LOG_MEMORY)
  if nx_is_valid(log_memory) then
    local count = log_memory:GetChildCount()
    self:BeginUpdate()
    for i = 0, count - 1 do
      local item = log_memory:GetChildByIndex(i)
      self:AddString(nx_widestr(item.info))
    end
    self:EndUpdate()
    self:SetItemColor(self.curr_undo_pos - 1, "255,255,0,0")
  end
  return 1
end
function update(self)
  self:ClearString()
  init(self)
  return 1
end
function log_list_lost_capture(self)
  self.SelectIndex = -1
  nx_execute("form_task\\form_tips", "close_tips")
  return 1
end
function log_list_select_click(self, row)
  local info = self:GetString(row)
  nx_execute("form_task\\form_tips", "close_tips")
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local list = nx_function("ext_split_string", nx_string(info), ",")
  info = list[1]
  for i = 2, table.getn(list) do
    info = info .. "<br>" .. list[i]
  end
  nx_execute("form_task\\form_tips", "show_tips", x + 10, y + 10, info)
  return 1
end
