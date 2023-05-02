EventTable = {}
function push_event(feed_type, name, text, ...)
  push_into_table(feed_type, name, text)
  update_event_show()
end
function push_into_table(feed_type, name, text)
  local index = table.getn(EventTable) + 1
  EventTable[index] = {
    Feed_Type = feed_type,
    Name = name,
    Text = text
  }
end
function update_event_show()
  local gui = nx_value("gui")
  local form_event = nx_value("form_stage_main\\form_main\\form_event")
  if nx_is_valid(form_event) then
  else
    dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_event", true, false)
    dialog.Left = gui.Width / 1.5
    dialog.Top = gui.Height / 4
    dialog:Show()
  end
  pop_event_btn()
end
function pop_event_btn(index)
  local form_event = nx_value("form_stage_main\\form_main\\form_event")
  local count = table.getn(EventTable)
  if index == 1 then
    form_event.btn_1.Text = form_event.btn_2.Text
    form_event.btn_2.Text = form_event.btn_3.Text
    if 2 < count then
      form_event.btn_3.Text = nx_widestr(EventTable[3].Text)
    end
  elseif index == 2 then
    form_event.btn_2.Text = form_event.btn_3.Text
    if 2 < count then
      form_event.btn_3.Text = nx_widestr(EventTable[3].Text)
    end
  elseif index == 3 and 2 < count then
    form_event.btn_3.Text = nx_widestr(EventTable[3].Text)
  end
  if table.getn(EventTable) == 0 then
    form_event.Visible = false
    form_event.btn_1.Visible = false
    form_event.btn_2.Visible = false
    form_event.btn_3.Visible = false
  elseif table.getn(EventTable) == 1 then
    form_event.Visible = true
    form_event.btn_1.Visible = true
    form_event.btn_2.Visible = false
    form_event.btn_3.Visible = false
    form_event.btn_1.Text = nx_widestr(EventTable[1].Text)
  elseif table.getn(EventTable) == 2 then
    form_event.Visible = true
    form_event.btn_1.Visible = true
    form_event.btn_2.Visible = true
    form_event.btn_3.Visible = false
    form_event.btn_2.Text = nx_widestr(EventTable[2].Text)
  elseif table.getn(EventTable) == 3 then
    form_event.Visible = true
    form_event.btn_1.Visible = true
    form_event.btn_2.Visible = true
    form_event.btn_3.Visible = true
    form_event.btn_3.Text = nx_widestr(EventTable[3].Text)
  end
end
function delete_element_table(index)
  if table.getn(EventTable) == 0 then
    pop_event_btn(index)
    return
  end
  local info = EventTable[index]
  table.remove(EventTable, index)
  pop_event_btn(index)
  return info.Feed_Type, info.Name, info.Text
end
