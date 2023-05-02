require("form_task\\common")
require("form_task\\tool")
require("theme")
function main_form_init(self)
  self.Fixed = false
  self.LimitInScreen = false
  self.task_info = nil
  self.main_text_form = nil
  self.dialog_text_form = nil
  load_question_res()
  return 1
end
function main_form_open(self)
  self.btn_save.Visible = false
  load_from_file()
  load_default_params_setting()
  load_main_text_form(self)
  load_dialog_text_form(self)
  self.rbtn_form_text.Checked = true
  self.rbtn_preview.Checked = true
  self.btn_color.aim_rich_edit = nil
  self.btn_quick_color.aim_rich_edit = nil
  self.btn_quick_color.BackColor = DEFAULT_QUICK_BUTTON_COLOR
  set_edit_lock_property(self)
  return 1
end
function main_form_close(self)
  nx_destroy(self)
  return 1
end
function btn_close_click(self)
  local form = self.Parent
  set_text_form(false, form.rbtn_form_text.Checked)
  form:Close()
  return 1
end
function rbtn_form_text_checked_changed(self)
  local form = self.Parent
  show_main_text_form(form, self.Checked)
  if self.Checked then
    form.default_params_setting.edit_type = "main_text"
  end
  return 1
end
local is_need_default_text = function(property_name)
  if property_name == "TrackInfo" or property_name == "TrackInfoID" or property_name == "LineNextInfo" then
    return true
  end
  return false
end
function rbtn_dialog_text_checked_changed(self)
  local form = self.Parent
  show_dialog_text_form(form, self.Checked)
  if self.Checked then
    form.default_params_setting.edit_type = "dialog_text"
  end
  return 1
end
function load_main_text_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form.main_text_form) then
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_main_text.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 10
      dialog.Top = 50
      dialog.Visible = false
      form.main_text_form = dialog
      load_main_text(form, dialog.ctrlbox_form_text)
      load_trace_text(form, dialog.ctrlbox_track_text)
    end
  end
  return 1
end
function show_main_text_form(form, is_show)
  local gui = nx_value("gui")
  if nx_is_valid(form.main_text_form) then
    form.main_text_form.Visible = is_show
  end
  return 1
end
function load_dialog_text_form(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form.dialog_text_form) then
    local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_dialog_text.xml")
    local is_load = form:Add(dialog)
    if is_load then
      dialog.Left = 10
      dialog.Top = 50
      dialog.Visible = false
      form.dialog_text_form = dialog
      load_dialog_text(form, dialog.ctrlbox_dialog_text)
      load_process_dialog_text(form, dialog.ctrlbox_step_text)
    end
  end
  return 1
end
function show_dialog_text_form(form, is_show)
  local gui = nx_value("gui")
  if nx_is_valid(form.dialog_text_form) then
    form.dialog_text_form.Visible = is_show
  end
  return 1
end
local remove_sub_sect = function(value, sect_name)
  while true do
    local begin_str = "<" .. sect_name
    local end_str = "</" .. sect_name .. ">"
    local sect_begin_pos = string.find(value, begin_str)
    if sect_begin_pos == nil then
      break
    end
    local sect_begin_end_pos = string.find(value, ">", sect_begin_pos + string.len(begin_str))
    if sect_begin_end_pos == nil then
      break
    end
    local sect_end_pos = string.find(value, end_str)
    if sect_end_pos == nil then
      break
    end
    local pre_value = string.sub(value, 1, sect_begin_pos - 1)
    local aft_value = string.sub(value, sect_end_pos + string.len(end_str), string.len(value))
    value = pre_value .. string.sub(value, sect_begin_end_pos + 1, sect_end_pos - 1) .. aft_value
  end
  return value
end
local remove_sub_value = function(value, sect_value)
  while true do
    local pos = string.find(value, sect_value)
    if pos == nil then
      break
    end
    local len = string.len(sect_value)
    local pre_value = string.sub(value, 1, pos - 1)
    local aft_value = string.sub(value, pos + len, string.len(value))
    value = pre_value .. aft_value
  end
  return value
end
local remove_last_value = function(value, sect_value)
  local last_pos = -1
  local pos = string.find(value, sect_value)
  while pos ~= nil do
    last_pos = pos
    pos = string.find(value, sect_value, last_pos + string.len(sect_value))
  end
  if last_pos == -1 then
    return value
  end
  return string.sub(value, 1, last_pos - 1)
end
local optimize_html_string = function(value)
  local format_list = {}
  local text_list = {}
  local count = 0
  local format_beg = string.find(value, "<font")
  while nil ~= format_beg do
    local format_beg_1 = string.find(value, ">", format_beg)
    count = count + 1
    format_list[count] = string.sub(value, format_beg, format_beg_1)
    local format_end = string.find(value, "</font>", format_beg_1)
    text_list[count] = string.sub(value, format_beg_1 + 1, format_end - 1)
    format_beg = string.find(value, "<font", format_end)
  end
  if count == 0 then
    return value
  end
  while true do
    local is_find = false
    for i = 1, count - 1 do
      if format_list[i] == format_list[i + 1] then
        text_list[i] = text_list[i] .. text_list[i + 1]
        table.remove(format_list, i + 1)
        table.remove(text_list, i + 1)
        count = count - 1
        is_find = true
        break
      end
    end
    if not is_find then
      break
    end
  end
  value = ""
  for i = 1, count do
    value = value .. format_list[i] .. text_list[i] .. "</font>"
  end
  return value
end
function leave_the_changes(self)
  local prop = self.prop
  local control_box = self.Parent.Parent
  local text_name = self.text_name
  local value = nx_string(self.Text)
  if nx_find_custom(self, "lock_state") and self.lock_state == true then
    value = remove_sub_sect(value, "font")
    value = remove_sub_value(value, "<br/>")
    self.Text = nx_widestr(value)
  end
  value = remove_last_value(value, "<br/>")
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) and text_form.rbtn_dialog_text.Checked then
    value = make_string_to_white(value)
  end
  if "" ~= prop then
    local text_files = nx_value("text_files")
    if nx_is_valid(text_files) then
      local child = get_node(text_files, prop)
      if nx_is_valid(child) then
        if value ~= child.value then
          set_modify_text(prop, child.value, value, control_box.Name)
          child.value = value
          set_changes(prop, value, text_name)
          update_other_place(prop, value)
        end
      else
        nx_msgbox("\206\222\183\168\213\210\181\189\207\224\211\166\181\196Key:" .. prop .. "\163\172\199\235\192\169\180\243\210\235\206\196\206\196\188\254\181\196\183\182\206\167")
      end
    end
  end
  return 1
end
function update_other_place(prop, value)
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    search_controlbox(text_form.main_text_form.ctrlbox_form_text, prop, value)
    search_controlbox(text_form.main_text_form.ctrlbox_track_text, prop, value)
    search_controlbox(text_form.dialog_text_form.ctrlbox_dialog_text, prop, value)
    search_controlbox(text_form.dialog_text_form.ctrlbox_step_text, prop, value)
  end
  return 1
end
function search_controlbox(controlbox, prop, value)
  for i = 0, controlbox.ItemCount - 1 do
    local ctrl = controlbox:GetControl(i)
    if nx_name(ctrl) == "GroupBox" then
      local child_list = ctrl:GetChildControlList()
      for j = 1, table.getn(child_list) do
        if (nx_name(child_list[j]) == "Edit" or nx_name(child_list[j]) == "RichEdit") and nx_find_custom(child_list[j], "prop") then
          local key = nx_custom(child_list[j], "prop")
          if string.lower(key) == string.lower(prop) then
            child_list[j].Text = nx_widestr(value)
          end
        end
      end
    end
  end
  return 1
end
function show_other_place(prop)
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    local control_box = text_form.main_text_form.ctrlbox_form_text
    if show_controlbox(control_box, prop) then
      load_main_text(text_form, control_box)
      text_form.rbtn_form_text.Checked = true
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
      return true
    end
    local control_box = text_form.main_text_form.ctrlbox_track_text
    if show_controlbox(control_box, prop) then
      load_trace_text(text_form, control_box)
      text_form.rbtn_form_text.Checked = true
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
      return true
    end
    local control_box = text_form.dialog_text_form.ctrlbox_dialog_text
    if show_controlbox(control_box, prop) then
      load_dialog_text(text_form, control_box)
      text_form.rbtn_dialog_text.Checked = true
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
      return true
    end
    local control_box = text_form.dialog_text_form.ctrlbox_step_text
    if show_controlbox(control_box, prop) then
      load_process_dialog_text(text_form, control_box)
      text_form.rbtn_dialog_text.Checked = true
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
      return true
    end
  end
  return false
end
function reload_control_box(control_box)
  local text_form = nx_value("text_form")
  if nx_is_valid(text_form) then
    if nx_id_equal(control_box, text_form.main_text_form.ctrlbox_form_text) then
      load_main_text(text_form, control_box)
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
    elseif nx_id_equal(control_box, text_form.main_text_form.ctrlbox_track_text) then
      load_trace_text(text_form, control_box)
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
    elseif nx_id_equal(control_box, text_form.dialog_text_form.ctrlbox_dialog_text) then
      load_dialog_text(text_form, control_box)
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
    elseif nx_id_equal(control_box, text_form.dialog_text_form.ctrlbox_step_text) then
      load_process_dialog_text(text_form, control_box)
      if text_form.rbtn_code.Checked then
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "Edit")
      else
        nx_execute("form_task\\form_text", "change_multi_control_mode", control_box, "RichEdit")
      end
    end
    set_edit_lock_property(text_form)
  end
  return 1
end
function show_controlbox(controlbox, prop)
  for i = 0, controlbox.ItemCount - 1 do
    local ctrl = controlbox:GetControl(i)
    if nx_name(ctrl) == "Grid" then
      local prop_ins = nx_string(ctrl:GetGridText(0, 0))
      if prop_ins == prop then
        return true
      end
    end
  end
  return false
end
function on_drag_richedit(self)
  local form = self.Parent.Parent.Parent.Parent
  form.btn_color.aim_rich_edit = self
  form.btn_quick_color.aim_rich_edit = self
  return 1
end
function on_get_focus_richedit(self)
  if nx_name(self) == "RichEdit" then
    local form = self.Parent.Parent.Parent.Parent
    form.custom_hyper_button.aim_rich_edit = self
  end
  return 1
end
function add_image_into_control(id, control_box)
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. COMMON_NPC
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return 1
  end
  local gui = nx_value("gui")
  local picture = CREATE_CONTROL("Picture")
  picture.Width = PICTURE_WIDTH
  picture.Height = PICTURE_HEIGHT
  picture.Image = ini:ReadString(id, "Photo", "")
  control_box:AddControl(picture)
  nx_destroy(ini)
  return 1
end
function add_label_into_control(name, control_box)
  local gui = nx_value("gui")
  local label = CREATE_CONTROL("Label")
  label.Text = nx_widestr(name)
  label.Width = control_box.Width - 17
  label.Height = LABEL_HEIGHT
  label.Solid = true
  label.BackColor = LABEL_BACK_COLOR
  label.ForeColor = LABEL_FORE_COLOR
  label.Font = "WRYH16"
  control_box:AddControl(label)
  return label
end
function add_grid_into_control(prop, control_box, form, index, is_lock)
  local gui = nx_value("gui")
  local grid = CREATE_CONTROL("Grid")
  grid.ColCount = GRID_COUNT
  grid.RowHeaderVisible = false
  grid.SelectBackColor = GRID_BACK_COLOR
  grid.SelectForeColor = GRID_FORE_COLOR
  local value
  if nx_type(form) == "string" then
    value = form
  elseif nx_type(form) == "object" then
    value = nx_custom(form.task_info, prop)
  end
  if nil == value then
    value = ""
  end
  local row = grid:InsertRow(-1)
  grid:SetGridText(row, 0, nx_widestr(prop))
  grid:SetGridText(row, 1, nx_widestr(value))
  grid:SetGridBackColor(row, 0, GRID_BACK_COLOR)
  grid:SetGridBackColor(row, 1, GRID_BACK_COLOR)
  local btn = CREATE_CONTROL("Button")
  btn.Text = nx_widestr("\196\172\200\207\201\232\214\195")
  btn.grid = grid
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_click_default_single_btn")
  grid:SetGridControl(row, 2, btn)
  local rtn = CREATE_CONTROL("CheckButton")
  rtn.Text = nx_widestr("\203\248\182\168\215\180\204\172")
  rtn.HideBox = true
  rtn.grid = grid
  if is_lock then
    rtn.ForeColor = "255, 255, 0, 0"
    rtn.Checked = true
  else
    rtn.ForeColor = "255, 0, 0, 0"
    rtn.Checked = false
  end
  nx_bind_script(rtn, nx_current())
  nx_callback(rtn, "on_checked_changed", "on_checked_changed_rtn")
  grid:SetGridControl(row, 3, rtn)
  local col_width = (control_box.Width - 18 - GRID_DEFAULT_BTN_WIDTH * 2) / (GRID_COUNT - 2)
  grid:SetColWidth(0, col_width)
  grid:SetColWidth(1, col_width)
  grid:SetColWidth(2, GRID_DEFAULT_BTN_WIDTH)
  grid:SetColWidth(3, GRID_DEFAULT_BTN_WIDTH)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_double_click_grid", "grid_double_click_grid")
  grid.Width = 2 * col_width + GRID_DEFAULT_BTN_WIDTH * 2 + 1
  grid.Height = grid.RowHeight * grid.RowCount
  if -1 ~= index then
    control_box:AddControlByIndex(grid, index)
  else
    control_box:AddControl(grid)
  end
  return grid
end
function set_grid_value(grid, item, flag1, flag2, flag3)
  if item ~= nil then
    grid.item = item
  end
  if flag1 ~= nil then
    grid.flag1 = flag1
  end
  if flag2 ~= nil then
    grid.flag2 = flag2
  end
  if flag3 ~= nil then
    grid.flag3 = flag3
  end
  return 1
end
function add_new_and_delete_btn_into_control(control_box)
  local gui = nx_value("gui")
  local add_btn = CREATE_CONTROL("Button")
  add_btn.Text = nx_widestr(ADD_SAME_ID_BTN_TITLE)
  local delete_btn = CREATE_CONTROL("Button")
  delete_btn.Text = nx_widestr(DELETE_SAME_ID_BTN_TITLE)
  local grid = CREATE_CONTROL("Grid")
  grid.ColCount = 2
  grid.ColWidth = 80
  grid.Width = 161
  grid.RowHeaderVisible = false
  grid.Height = 25
  grid.LineColor = "0, 0, 0, 0"
  local row = grid:InsertRow(-1)
  grid:SetGridControl(row, 0, add_btn)
  grid:SetGridControl(row, 1, delete_btn)
  grid.add_btn = add_btn
  grid.delete_btn = delete_btn
  control_box:AddControl(grid)
  return grid
end
function add_multi_into_control(prop, control_box, form, text_name, index, ctrl_name, is_direct_value)
  local gui = nx_value("gui")
  local value
  if nx_type(form) == "string" then
    value = form
  else
    value = nx_custom(form.task_info, prop)
  end
  local str_list = nx_function("ext_split_string", value, SPLIT_CHAR)
  if prop == "AcceptDialogId" or prop == "CompleteDialogId" then
    local str_list_tmp = {}
    local index = 1
    for i = 1, table.getn(str_list) do
      local more_str_list = nx_function("ext_split_string", str_list[i], SPLIT_CHAR_1)
      for j = 1, table.getn(more_str_list) do
        str_list_tmp[index] = more_str_list[j]
        index = index + 1
      end
    end
    str_list = str_list_tmp
  end
  local groupbox_ctrl, current_groupbox
  for i = 1, table.getn(str_list) do
    local groupbox = CREATE_CONTROL("GroupBox")
    groupbox.Width = control_box.Width - 17
    groupbox.Height = GROUPBOX_HEIGHT
    groupbox.LineColor = "0,0,0,0"
    groupbox.BackColor = "255,210,214,217"
    local label_info
    if TALK_OBJ_TYPE[prop] ~= nil then
      label_info = TALK_OBJ_TYPE[prop][(i + 1) % 2 + 1]
    end
    local label
    if label_info ~= nil then
      label = CREATE_CONTROL("Label")
      label.Width = LABEL_WIDTH
      label.Height = EDIT_HEIGHT
      label.Text = nx_widestr(label_info)
    end
    local edit = CREATE_CONTROL("Edit")
    if nx_is_valid(label) then
      edit.Left = LABEL_WIDTH
    end
    edit.Width = control_box.Width - edit.Left - 17
    edit.Height = EDIT_HEIGHT
    if is_direct_value == true then
      edit.Text = nx_widestr(str_list[i])
    else
      edit.Text = nx_widestr(get_value(str_list[i]))
    end
    edit.prop = str_list[i]
    edit.Visible = false
    edit.BackColor = EDIT_BACKCOLOR
    edit.text_name = text_name
    if is_direct_value ~= true then
      nx_bind_script(edit, nx_current())
      nx_callback(edit, "on_lost_focus", "leave_the_changes")
      nx_callback(edit, "on_enter", "leave_the_changes")
    end
    local richedit = CREATE_CONTROL("RichEdit")
    richedit.ReturnAllFormat = true
    richedit.EditMode = true
    local view_rect = RICHEDIT_VIEW_TABLE[prop]
    if view_rect == nil then
      view_rect = RICHEDIT_VIEW_TABLE.default
    end
    richedit.ViewRect = view_rect
    if nx_is_valid(label) then
      richedit.Left = LABEL_WIDTH
    end
    richedit.Width = control_box.Width - richedit.Left - 17
    richedit.Height = RICHEDIT_HEIGHT
    if is_direct_value == true then
      richedit.Text = nx_widestr(str_list[i])
    else
      richedit.Text = nx_widestr(get_value(str_list[i]))
    end
    richedit.Solid = false
    richedit.HasVScroll = true
    richedit.prop = str_list[i]
    richedit.Visible = false
    richedit.DragEvent = true
    richedit.BackColor = RICHEDIT_BACKCOLOR
    richedit.text_name = text_name
    if is_direct_value ~= true then
      nx_bind_script(richedit, nx_current())
      nx_callback(richedit, "on_lost_focus", "leave_the_changes")
      nx_callback(richedit, "on_drag", "on_drag_richedit")
      nx_callback(richedit, "on_get_focus", "on_get_focus_richedit")
    end
    if nx_is_valid(label) then
      groupbox:Add(label)
    end
    groupbox.edit = edit
    groupbox.richedit = richedit
    groupbox:Add(edit)
    groupbox:Add(richedit)
    if nil ~= index then
      control_box:AddControlByIndex(groupbox, index)
      index = index + 1
    else
      control_box:AddControl(groupbox)
    end
    if ctrl_name == "Edit" then
      edit.Visible = true
    elseif ctrl_name == "RichEdit" then
      richedit.Visible = true
    end
    if groupbox_ctrl == nil then
      groupbox_ctrl = groupbox
    else
      current_groupbox.groupbox = groupbox
    end
    current_groupbox = groupbox
  end
  return groupbox_ctrl
end
function add_splitter_into_control(control_box)
  local gui = nx_value("gui")
  return 1
end
function add_button_for_question(control_box, grid_ctrl)
  local gui = nx_value("gui")
  local add_btn = CREATE_CONTROL("Button")
  add_btn.Text = nx_widestr(ADD_NEW_ANSWER_BTN_TITLE)
  nx_bind_script(add_btn, nx_current())
  nx_callback(add_btn, "on_click", "add_button_click")
  local delete_btn = CREATE_CONTROL("Button")
  delete_btn.Text = nx_widestr(DELETE_LAST_ANSWER_BTN_TITLE)
  nx_bind_script(delete_btn, nx_current())
  nx_callback(delete_btn, "on_click", "delete_button_click")
  local grid = CREATE_CONTROL("Grid")
  grid.ColCount = 2
  grid.ColWidth = 160
  grid.Width = grid.ColWidth * grid.ColCount + 1
  grid.RowHeaderVisible = false
  grid.Height = 25
  grid.LineColor = "0, 0, 0, 0"
  local row = grid:InsertRow(-1)
  grid:SetGridControl(row, 0, add_btn)
  grid:SetGridControl(row, 1, delete_btn)
  grid.add_btn = add_btn
  grid.delete_btn = delete_btn
  grid.grid_ctrl = grid_ctrl
  control_box:AddControl(grid)
  return grid
end
function load_main_text(form, control_box)
  control_box:ClearControl()
  control_box.ScrollSmooth = true
  add_label_into_control("\200\206\206\241\195\251", control_box)
  local grid = add_grid_into_control("TitleId", control_box, form, -1, true)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("TitleId", control_box, form, "text1")
  grid.groupbox = groupbox
  add_splitter_into_control(control_box)
  add_label_into_control("\200\206\206\241\195\232\202\246", control_box)
  local grid = add_grid_into_control("ContextId", control_box, form, -1, true)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("ContextId", control_box, form, "text1")
  grid.groupbox = groupbox
  add_splitter_into_control(control_box)
  add_label_into_control("\200\206\206\241\196\191\177\234", control_box)
  local grid = add_grid_into_control("TaskTargetId", control_box, form, -1, true)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("TaskTargetId", control_box, form, "text1")
  grid.groupbox = groupbox
  add_splitter_into_control(control_box)
  add_label_into_control("\206\222\200\206\206\241\204\225\202\190", control_box)
  local grid = add_grid_into_control("LineNextInfo", control_box, form, -1, true)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("LineNextInfo", control_box, form, "text1")
  grid.groupbox = groupbox
  local default_text = "Default"
  local groupbox_ctrl = add_multi_into_control("Default", control_box, default_text, "text1", nil, nil, true)
  groupbox_ctrl.edit.ReadOnly = true
  groupbox_ctrl.richedit.ReadOnly = true
  grid.default_groupbox = groupbox_ctrl
  set_summary_edit_text_default_value(grid)
  add_splitter_into_control(control_box)
  return 1
end
function load_trace_text(form, control_box)
  control_box:ClearControl()
  control_box.ScrollSmooth = true
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    local grid = task_form.subtask_process_form.process_list_grid
    for i = 0, grid.RowCount - 1 do
      local order = nx_string(grid:GetGridText(i, 0))
      local type = nx_string(grid:GetGridText(i, 1))
      local id = nx_string(grid:GetGridText(i, 2))
      local id_sect = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", type, id)
      if nx_is_valid(id_sect) then
        local id_sect_count = id_sect:GetChildCount()
        local order_number = nx_execute("form_task\\form_subtask_process", "get_process_number", grid, i)
        local text
        if 0 <= order_number then
          text = "\178\189\214\232 " .. nx_string(order_number) .. INTERVAL .. type_list[type][3]
        else
          text = "\178\189\214\232\206\180\204\238\208\180" .. INTERVAL .. type_list[type][3]
        end
        if nx_is_valid(id_sect) then
          local prop_list
          if type == "hunter" then
            prop_list = {"TrackInfo"}
            local sect = id_sect:GetChildByIndex(0)
            if sect:FindChild("IsQieCuo") then
              local is_qie_cuo = sect:GetChild("IsQieCuo").item_name
              if is_qie_cuo == "" or is_qie_cuo == "0" then
                text = text .. INTERVAL .. "\206\222\199\208\180\232"
                local item = sect:GetChild("NpcId")
                text = text .. INTERVAL .. "NpcId=" .. get_npc_name(item.item_name)
                add_image_into_control(item.item_name, control_box)
              end
            end
          elseif type == "collect" then
            prop_list = {"TrackInfo"}
          elseif type == "interact" then
            prop_list = {"TrackInfo"}
          elseif type == "story" then
            prop_list = {
              "TrackInfoID"
            }
          elseif type == "question" then
            prop_list = {
              "TrackInfoID"
            }
          elseif type == "useitem" then
            prop_list = {
              "TrackInfoID"
            }
          elseif type == "convoy" then
            prop_list = {"TrackInfo"}
          elseif type == "choose" then
            prop_list = {
              "TrackInfoID"
            }
          elseif type == "special" then
            prop_list = {
              "TrackInfoID"
            }
          end
          add_label_into_control(text, control_box)
          for k = 0, id_sect_count - 1 do
            local sect = id_sect:GetChildByIndex(k)
            for i = 1, table.getn(prop_list) do
              if sect:FindChild(prop_list[i]) then
                local item = sect:GetChild(prop_list[i])
                local grid_ctrl = add_grid_into_control(prop_list[i], control_box, item.item_name, -1, true)
                set_grid_value(grid_ctrl, sect, "subfunction", type, k)
                grid_ctrl.type = type
                grid_ctrl.id = id
                if is_need_default_text(prop_list[i]) then
                  if sect:FindChild("SceneID") then
                    grid_ctrl.scene_id = sect:GetChild("SceneID").item_name
                  elseif sect:FindChild("SceneId") then
                    grid_ctrl.scene_id = sect:GetChild("SceneId").item_name
                  end
                  if sect:FindChild("NpcID") then
                    grid_ctrl.npc_id = sect:GetChild("NpcID").item_name
                  elseif sect:FindChild("NpcId") then
                    grid_ctrl.npc_id = sect:GetChild("NpcId").item_name
                  end
                  if sect:FindChild("TargetConfig") then
                    grid_ctrl.target_config = sect:GetChild("TargetConfig").item_name
                  end
                  if sect:FindChild("ItemID") then
                    grid_ctrl.item_id = sect:GetChild("ItemID").item_name
                  elseif sect:FindChild("ItemId") then
                    grid_ctrl.item_id = sect:GetChild("ItemId").item_name
                  end
                  if sect:FindChild("QuestionNpc") then
                    grid_ctrl.question_npc = sect:GetChild("QuestionNpc").item_name
                  end
                  if sect:FindChild("GetItems") then
                    grid_ctrl.get_items = sect:GetChild("GetItems").item_name
                  end
                  if sect:FindChild("LostItems") then
                    grid_ctrl.lost_items = sect:GetChild("LostItems").item_name
                  end
                end
                local groupbox_ctrl = add_multi_into_control(prop_list[i], control_box, item.item_name, "text2")
                grid_ctrl.groupbox = groupbox_ctrl
                if is_need_default_text(prop_list[i]) then
                  default_text = "Default"
                  local default_groupbox_ctrl = add_multi_into_control("Default", control_box, default_text, "text2", nil, nil, true)
                  default_groupbox_ctrl.edit.ReadOnly = true
                  default_groupbox_ctrl.richedit.ReadOnly = true
                  grid_ctrl.default_groupbox = default_groupbox_ctrl
                  set_subtask_edit_text_default_value(grid_ctrl)
                  if nx_is_valid(groupbox_ctrl) and item.item_name == nx_string(groupbox_ctrl.richedit.Text) then
                    groupbox_ctrl.edit.Text = nx_widestr(default_groupbox_ctrl.edit.Text)
                    groupbox_ctrl.richedit.Text = nx_widestr(default_groupbox_ctrl.richedit.Text)
                  end
                end
                add_splitter_into_control(control_box)
              end
            end
          end
        end
      end
    end
    local task_info = form.task_info
    local text = "\206\222\178\189\214\232 \215\220\177\237"
    local val = nx_custom(task_info, "SubmitNpc")
    if val == nil then
      val = ""
    end
    text = text .. INTERVAL .. "SubmitNpc=" .. get_npc_name(val)
    add_image_into_control(val, control_box)
    add_label_into_control(text, control_box)
    local grid_ctrl = add_grid_into_control("SubmitNpcEx", control_box, form, -1, true)
    set_grid_value(grid_ctrl, form.task_info, "task")
    local groupbox_ctrl = add_multi_into_control("SubmitNpcEx", control_box, form, "text2")
    grid_ctrl.groupbox = groupbox_ctrl
    add_splitter_into_control(control_box)
  end
  return 1
end
function load_dialog_text(form, control_box)
  control_box:ClearControl()
  control_box.ScrollSmooth = true
  local text = "\189\211\202\220\200\206\206\241\206\196\177\190\180\174 "
  local value = nx_custom(form.task_info, "AcceptNpc")
  if nil == value then
    value = ""
  end
  local gui = nx_value("gui")
  text = text .. "AcceptNpc " .. get_npc_name(value)
  add_image_into_control(value, control_box)
  add_label_into_control(text, control_box)
  local grid = add_grid_into_control("AcceptDialogId", control_box, form, -1, false)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("AcceptDialogId", control_box, form, "text1")
  grid.groupbox = groupbox
  local grid = add_grid_into_control("CanAcceptMenu", control_box, form, -1, false)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("CanAcceptMenu", control_box, form, "text1")
  grid.groupbox = groupbox
  add_splitter_into_control(control_box)
  local text = "\205\234\179\201\200\206\206\241\206\196\177\190\180\174 "
  local value = nx_custom(form.task_info, "SubmitNpc")
  if nil == value then
    value = ""
  end
  text = text .. "SubmitNpc " .. get_npc_name(value)
  add_image_into_control(value, control_box)
  add_label_into_control(text, control_box)
  local grid = add_grid_into_control("CompleteDialogId", control_box, form, -1, false)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("CompleteDialogId", control_box, form, "text1")
  grid.groupbox = groupbox
  local grid = add_grid_into_control("CompleteMenu", control_box, form, -1, false)
  set_grid_value(grid, form.task_info, "task")
  local groupbox = add_multi_into_control("CompleteMenu", control_box, form, "text1")
  grid.groupbox = groupbox
  add_splitter_into_control(control_box)
  return 1
end
function load_process_dialog_text(form, control_box)
  control_box:ClearControl()
  control_box.ScrollSmooth = true
  local task_form = nx_value("task_form")
  local grid = task_form.subtask_process_form.process_list_grid
  for i = 0, grid.RowCount - 1 do
    local order = nx_string(grid:GetGridText(i, 0))
    local type = nx_string(grid:GetGridText(i, 1))
    local id = nx_string(grid:GetGridText(i, 2))
    local id_sect = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", type, id)
    if nx_is_valid(id_sect) then
      local id_sect_count = id_sect:GetChildCount()
      local order_number = nx_execute("form_task\\form_subtask_process", "get_process_number", grid, i)
      local text
      if 0 <= order_number then
        text = "\178\189\214\232 " .. nx_string(order_number) .. INTERVAL .. type_list[type][3]
      else
        text = "\178\189\214\232\206\180\204\238\208\180" .. INTERVAL .. type_list[type][3]
      end
      local prop_list_text = {}
      local split = false
      local label
      if type == "hunter" then
        prop_list_text = {}
        split = true
      elseif type == "interact" then
        prop_list_text = {"DialogID", "OkMenu"}
        split = true
      elseif type == "story" then
        prop_list_text = {
          "contextId",
          "titleId",
          "LeaveTextID"
        }
        split = true
      elseif type == "question" then
        prop_list_text = {
          "MainText",
          "FalseBuffer",
          "FalseTalk"
        }
        split = true
      end
      local label = add_label_into_control(type_list[type][3], control_box)
      if 1 <= id_sect_count then
        local sect = id_sect:GetChildByIndex(0)
        local text = ""
        local npc_id
        if sect:FindChild("NpcID") then
          npc_id = sect:GetChild("NpcID").item_name
          text = "NpcID " .. get_npc_name(npc_id)
        end
        if sect:FindChild("NpcId") then
          npc_id = sect:GetChild("NpcId").item_name
          text = "NpcId " .. get_npc_name(npc_id)
        end
        if sect:FindChild("QuestionNpc") then
          npc_id = sect:GetChild("QuestionNpc").item_name
          text = "QuestionNPC " .. get_npc_name(npc_id)
        end
        if npc_id ~= nil then
          add_image_into_control(npc_id, control_box)
        end
        if text ~= "" then
          label.Text = label.Text .. nx_widestr("  ") .. nx_widestr(text)
        end
      end
      if "story" == type or "question" == type then
        local title, text_key
        if "story" == type then
          title = "\185\202\202\194\200\235\191\218"
          text_key = "story_menu_" .. id
        else
          title = "\180\240\204\226\200\235\191\218"
          text_key = "quest_menu_" .. id
        end
        local grid_ctrl = add_grid_into_control(title, control_box, text_key, -1, false)
        grid_ctrl.id = id
        set_grid_value(grid_ctrl, grid_ctrl)
        local groupbox_ctrl = add_multi_into_control(title, control_box, text_key, "text2")
        grid_ctrl.groupbox = groupbox_ctrl
      end
      for i = 0, id_sect_count - 1 do
        local sect = id_sect:GetChildByIndex(i)
        if type == "question" then
          if sect:FindChild("QuestionID") then
            local question_id = sect:GetChild("QuestionID").item_name
            local questiongroup_sect = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", "questiongroup", question_id)
            if nx_is_valid(questiongroup_sect) then
              local questiongroup_sect_count = questiongroup_sect:GetChildCount()
              local question_contend = nx_value("question_contend")
              for j = 0, questiongroup_sect_count - 1 do
                local question = questiongroup_sect:GetChildByIndex(j)
                local question_count = question:GetChildCount()
                local grid_ctrl = add_grid_into_control("QuestionID", control_box, question.Name, -1, false)
                grid_ctrl.id = id
                set_grid_value(grid_ctrl, grid_ctrl)
                local groupbox_ctrl = add_multi_into_control("QuestionID", control_box, question.Name, "text3")
                grid_ctrl.groupbox = groupbox_ctrl
                for k = 0, question_count - 1 do
                  local pro = question:GetChildByIndex(k)
                  if nil ~= string.find(pro.Name, "questid") then
                    local pro_id = pro.item_name
                    if pro_id ~= "" then
                      local quest_grid_ctrl = add_grid_into_control(pro.Name, control_box, pro_id, -1, false)
                      quest_grid_ctrl.id = id
                      set_grid_value(quest_grid_ctrl, question, "questiongroup", "questiongroup", j)
                      local info
                      if question_contend:FindChild(pro_id) then
                        info = question_contend:GetChild(pro_id)
                      elseif question_contend:FindChild("title_info") then
                        info = question_contend:CreateChild(pro_id)
                        local title_info = question_contend:GetChild("title_info")
                        local title_info_count = title_info:GetChildCount()
                        for m = 0, title_info_count - 1 do
                          local title_child = title_info:GetChildByIndex(m)
                          local title_name = title_child.item_name
                          local child = info:CreateChild(title_name)
                          child.item_name = ""
                        end
                      end
                      if info ~= nil then
                        local grid_ctrl = add_grid_into_control("RightAnswer", control_box, info:GetChild("RightAnswer").item_name, -1, false)
                        grid_ctrl.id = id
                        set_grid_value(grid_ctrl, info, "question", "no_text")
                        for m = 1, table.getn(prop_list_text) do
                          if info:FindChild(prop_list_text[m]) then
                            local val = info:GetChild(prop_list_text[m]).item_name
                            local grid_ctrl = add_grid_into_control(prop_list_text[m], control_box, val, -1, false)
                            grid_ctrl.id = id
                            set_grid_value(grid_ctrl, info, "question", "has_text")
                            grid_ctrl.pro_id = pro_id
                            local groupbox_ctrl = add_multi_into_control(prop_list_text[m], control_box, val, "text2")
                            grid_ctrl.groupbox = groupbox_ctrl
                          end
                        end
                        local m = 1
                        while true do
                          local child = info:GetChild("ZZAnswerText" .. nx_string(m))
                          if nx_is_valid(child) and child.item_name ~= "" then
                            local grid_ctrl = add_grid_into_control("ZZAnswerText" .. nx_string(m), control_box, child.item_name, -1, false)
                            grid_ctrl.id = id
                            set_grid_value(grid_ctrl, info, "question", "has_text")
                            grid_ctrl.pro_id = pro_id
                            local groupbox_ctrl = add_multi_into_control("ZZAnswerText" .. nx_string(m), control_box, child.item_name, "text2")
                            grid_ctrl.groupbox = groupbox_ctrl
                          elseif true then
                            break
                          else
                            break
                          end
                          m = m + 1
                        end
                        add_button_for_question(control_box, quest_grid_ctrl)
                      end
                    end
                  end
                end
              end
            end
          end
        else
          if type == "hunter" then
            local child = sect:GetChild("IsQieCuo")
            if nx_is_valid(child) and child.item_name == "1" then
              prop_list_text = {
                "QiecuoTitle",
                "QiecuoMenu"
              }
            end
          end
          for j = 1, table.getn(prop_list_text) do
            if sect:FindChild(prop_list_text[j]) then
              local val = sect:GetChild(prop_list_text[j]).item_name
              local grid_ctrl = add_grid_into_control(prop_list_text[j], control_box, val, -1, false)
              grid_ctrl.id = id
              set_grid_value(grid_ctrl, sect, "subfunction", type, i)
              local groupbox_ctrl = add_multi_into_control(prop_list_text[j], control_box, val, "text2")
              grid_ctrl.groupbox = groupbox_ctrl
            end
          end
          if type == "convoy" and sect:FindChild("PathID") then
            local path_id = sect:GetChild("PathID").item_name
            local path_item = nx_execute("form_task\\form_path_overview", "get_path_info", path_id)
            if nx_is_valid(path_item) then
              local path_info_count = path_item:GetChildCount()
              for k = 0, path_info_count - 1 do
                local path_info = path_item:GetChildByIndex(k)
                if nx_is_valid(path_info) then
                  local grid_ctrl = add_grid_into_control("TalkID", control_box, nx_custom(path_info, "TalkID"), -1, false)
                  grid_ctrl.id = id
                  set_grid_value(grid_ctrl, path_item, "convoypoint", "TalkID", k)
                  local groupbox_ctrl = add_multi_into_control("TalkID", control_box, nx_custom(path_info, "TalkID"), "text2")
                  grid_ctrl.groupbox = groupbox_ctrl
                end
              end
            end
          end
        end
      end
      if type == "story" then
        local grid = add_new_and_delete_btn_into_control(control_box)
        nx_bind_script(grid.delete_btn, nx_current())
        nx_callback(grid.delete_btn, "on_click", "on_delete_story_same_id_btn_click")
        nx_bind_script(grid.add_btn, nx_current())
        nx_callback(grid.add_btn, "on_click", "on_add_story_same_id_btn_click")
        grid.add_btn.type = type
        grid.add_btn.id = id
        grid.delete_btn.type = type
        grid.delete_btn.id = id
      end
      if split == true then
        add_splitter_into_control(control_box)
      end
    end
  end
  add_splitter_into_control(control_box)
  return 1
end
function on_add_story_same_id_btn_click(self)
  nx_execute("form_task\\form_subtask_process", "on_add_same_id_btn_click", self)
  return 1
end
function on_delete_story_same_id_btn_click(self)
  local type = self.type
  local id = self.id
  local info_struct = nx_execute("form_task\\form_subtask_overview", "get_subtask_info", type, id)
  if info_struct:GetChildCount() >= 2 then
    nx_execute("form_task\\form_subtask_process", "on_delete_same_id_btn_click", self)
  end
  return 1
end
function delete_button_click(self)
  local self_grid = self.Parent
  local control_box = self_grid.Parent
  local grid_ctrl = self_grid.grid_ctrl
  local question_id = nx_string(grid_ctrl:GetGridText(0, 1))
  local question_contend = nx_value("question_contend")
  if not nx_is_valid(question_contend) then
    return 0
  end
  local question = question_contend:GetChild(question_id)
  if not nx_is_valid(question) then
    return 0
  end
  local index = control_box:FindControl(self_grid)
  for i = index - 1, 0, -1 do
    local ctrl = control_box:GetControl(i)
    if "Grid" == nx_name(ctrl) then
      local prop = nx_string(ctrl:GetGridText(0, 0))
      local begin_index, end_index = string.find(prop, "ZZAnswerText")
      if begin_index ~= nil then
        local item = question:GetChild(prop)
        if nx_is_valid(item) then
          if item.item_name ~= "" then
            item.item_name = ""
            set_question_changes(question_id, question)
          end
          for j = index - 1, i, -1 do
            local control = control_box:GetControl(j)
            control_box:RemoveControl(control)
          end
        end
        break
      end
    end
  end
  return 1
end
function add_button_click(self)
  local self_grid = self.Parent
  local control_box = self_grid.Parent
  local grid_ctrl = self_grid.grid_ctrl
  local question_id = nx_string(grid_ctrl:GetGridText(0, 1))
  local question_contend = nx_value("question_contend")
  if not nx_is_valid(question_contend) then
    return 0
  end
  local question = question_contend:GetChild(question_id)
  if not nx_is_valid(question) then
    return 0
  end
  local index = control_box:FindControl(self_grid)
  for i = index - 1, 0, -1 do
    local ctrl = control_box:GetControl(i)
    if "Grid" == nx_name(ctrl) then
      local prop = nx_string(ctrl:GetGridText(0, 0))
      local begin_index, end_index = string.find(prop, "ZZAnswerText")
      local num = 0
      if begin_index ~= nil then
        num = nx_string(string.sub(prop, end_index + 1, string.len(prop)))
      end
      num = num + 1
      local new_prop = "ZZAnswerText" .. nx_string(num)
      if question:FindChild(new_prop) then
        local grid_control = add_grid_into_control(new_prop, control_box, "", index, true)
        grid_control.pro_id = question_id
        set_grid_value(grid_control, question, "question", "has_text")
      end
      break
    end
  end
  return 1
end
function load_question_res()
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local question_contend = nx_value("question_contend")
  if not nx_is_valid(question_contend) then
    question_contend = nx_create("ArrayList", nx_current())
    nx_set_value("question_contend", question_contend)
  end
  local work_path = nx_value("work_path")
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("questions")
    if nx_is_valid(child) then
      local text_grid = nx_create("TextGrid")
      text_grid.FileName = work_path .. child.file_name
      if not text_grid:LoadFromFile(2) then
        nx_destroy(text_grid)
        return 0
      end
      local row_count = text_grid.RowCount
      local col_count = text_grid.ColCount
      local title_info_child = question_contend:CreateChild("title_info")
      for i = 0, col_count - 1 do
        local title_name = nx_string(text_grid:GetColName(nx_int(i)))
        local title_child = title_info_child:CreateChild("")
        title_child.item_name = title_name
      end
      for i = 0, row_count - 1 do
        local id = text_grid:GetValueString(nx_int(i), nx_int(0))
        if id ~= "" then
          local value = text_grid:GetValueString(nx_int(i), "ID")
          local result = nx_execute("form_task\\form_task", "is_in_range", value, child)
          if result then
            local question = question_contend:CreateChild(id)
            for j = 1, col_count - 1 do
              local col_name = text_grid:GetColName(j)
              local pro = question:CreateChild(col_name)
              pro.item_name = nx_string(text_grid:GetValueString(nx_int(i), nx_int(j)))
            end
          end
        end
      end
      nx_destroy(text_grid)
    end
  end
  return 1
end
function get_value(key)
  local gui = nx_value("gui")
  if "" == key then
    return ""
  end
  local text_files = nx_value("text_files")
  if nx_is_valid(text_files) then
    local child = get_node(text_files, key)
    if not nx_is_valid(child) then
      child = text_files:CreateChild(key)
      child.value = nx_string(gui.TextManager:GetText(key))
    end
    return child.value
  end
  return ""
end
function get_node(node, key)
  local child_list = node:GetChildList()
  for i = 1, table.getn(child_list) do
    if string.lower(child_list[i].Name) == string.lower(key) then
      return child_list[i]
    end
  end
  return nil
end
function revert_old_value(key)
  local gui = nx_value("gui")
  if "" == key then
    return ""
  end
  local text_files = nx_value("text_files")
  if nx_is_valid(text_files) then
    local child = get_node(text_files, key)
    if nx_is_valid(child) then
      child.value = nx_string(gui.TextManager:GetText(key))
    end
  end
  return 1
end
function save_value(key, value, text_name)
  local gui = nx_value("gui")
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return false
  end
  if not nx_is_valid(task_form.sect_node) then
    return false
  end
  if "" == key then
    return false
  end
  local i = 1
  while true do
    local child = task_form.sect_node:GetChild("text" .. nx_string(i))
    if not nx_is_valid(child) then
      break
    end
    local ret = save_into_file(child.file_name, key, value)
    if ret == 1 then
      return true
    end
    if ret == 2 then
      return false
    end
    i = i + 1
  end
  if string.lower(key) ~= string.lower(value) then
    local res = show_confirm_box("\211\239\209\212\176\252\214\208\195\187\211\208\213\210\181\189key\163\186" .. key .. " \202\199\183\241\208\232\210\170\180\180\189\168\163\191")
    if res then
      local child
      child = task_form.sect_node:GetChild(text_name)
      if nx_is_valid(child) then
        add_into_file(child.file_name, key, value)
      end
    end
  end
  return true
end
function load_from_file()
  local text_files = nx_value("text_files")
  if nx_is_valid(text_files) then
    return true
  end
  text_files = nx_create("ArrayList", "text_files")
  nx_set_value("text_files", text_files)
  return true
end
function save_into_file(file_name, key, value)
  local idres_doc = nx_create("IdresDocument")
  idres_doc.FileName = nx_resource_path() .. file_name
  if not idres_doc:LoadFromFile() then
    nx_destroy(idres_doc)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. nx_resource_path() .. file_name .. ")\202\167\176\220")
    return 0
  end
  local item_list = idres_doc:GetItemList()
  local item_count = table.getn(item_list)
  for i = 1, item_count do
    if string.lower(item_list[i]) == string.lower(key) then
      idres_doc:WriteString(item_list[i], value)
      if not idres_doc:SaveToFile() then
        nx_msgbox(idres_doc.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
        nx_destroy(idres_doc)
        return 2
      end
      nx_destroy(idres_doc)
      return 1
    end
  end
  nx_destroy(idres_doc)
  return 0
end
function add_into_file(file_name, key, value)
  local idres_doc = nx_create("IdresDocument")
  idres_doc.FileName = nx_resource_path() .. file_name
  if not idres_doc:LoadFromFile() then
    nx_destroy(idres_doc)
    nx_msgbox("\182\193\200\161\206\196\188\254(" .. nx_resource_path() .. file_name .. ")\202\167\176\220")
    return true
  end
  local row = idres_doc:AddString(key, value)
  idres_doc:SaveToFile()
  nx_destroy(idres_doc)
  return false
end
function show_multi_control(groupbox, ctrl_name)
  local child_control_table = groupbox:GetChildControlList()
  local text
  for i = 1, table.getn(child_control_table) do
    local child = child_control_table[i]
    if ctrl_name == nx_name(child) then
      child.Visible = true
    elseif nx_name(child) ~= "Label" then
      child.Visible = false
      text = child.Text
    end
  end
  for i = 1, table.getn(child_control_table) do
    local child = child_control_table[i]
    if ctrl_name == nx_name(child) then
      child.Text = text
    end
  end
end
function change_multi_control_mode(controlbox, mode)
  for i = 0, controlbox.ItemCount do
    local child = controlbox:GetControl(i)
    if "GroupBox" == nx_name(child) then
      show_multi_control(child, mode)
    end
  end
  return 1
end
function rbtn_code_checked_changed(self)
  local form = self.Parent.Parent
  local controlbox = form.main_text_form.ctrlbox_form_text
  if self.Checked then
    change_multi_control_mode(controlbox, "Edit")
  end
  controlbox = form.main_text_form.ctrlbox_track_text
  if self.Checked then
    change_multi_control_mode(controlbox, "Edit")
  end
  controlbox = form.dialog_text_form.ctrlbox_dialog_text
  if self.Checked then
    change_multi_control_mode(controlbox, "Edit")
  end
  controlbox = form.dialog_text_form.ctrlbox_step_text
  if self.Checked then
    change_multi_control_mode(controlbox, "Edit")
  end
  return 1
end
function rbtn_preview_checked_changed(self)
  local form = self.Parent.Parent
  local controlbox = form.main_text_form.ctrlbox_form_text
  if self.Checked then
    change_multi_control_mode(controlbox, "RichEdit")
  end
  controlbox = form.main_text_form.ctrlbox_track_text
  if self.Checked then
    change_multi_control_mode(controlbox, "RichEdit")
  end
  controlbox = form.dialog_text_form.ctrlbox_dialog_text
  if self.Checked then
    change_multi_control_mode(controlbox, "RichEdit")
  end
  controlbox = form.dialog_text_form.ctrlbox_step_text
  if self.Checked then
    change_multi_control_mode(controlbox, "RichEdit")
  end
  return 1
end
function btn_color_click(self)
  if not self.Parent.rbtn_preview.Checked then
    return 0
  end
  local gui = nx_value("gui")
  local color = "0,0,0,0"
  local res, alpha, red, green, blue = get_color(color)
  if res ~= "cancel" then
    color = nx_string(alpha) .. "," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
    if nx_is_valid(self.aim_rich_edit) then
      self.aim_rich_edit:ChangeSelectColor(color)
      leave_the_changes(self.aim_rich_edit)
    end
  end
end
function parse_color(color)
  local alpha = 0
  local red = 0
  local green = 0
  local blue = 0
  local pos1 = string.find(color, ",")
  if pos1 == nil then
    return alpha, red, green, blue
  end
  local pos2 = string.find(color, ",", pos1 + 1)
  if pos2 == nil then
    return alpha, red, green, blue
  end
  local pos3 = string.find(color, ",", pos2 + 1)
  if pos3 == nil then
    return alpha, red, green, blue
  end
  local alpha = nx_number(string.sub(color, 1, pos1 - 1))
  local red = nx_number(string.sub(color, pos1 + 1, pos2 - 1))
  local green = nx_number(string.sub(color, pos2 + 1, pos3 - 1))
  local blue = nx_number(string.sub(color, pos3 + 1))
  return alpha, red, green, blue
end
function get_color(default_color)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_set_color.xml")
  local a, r, g, b = parse_color(default_color)
  dialog.alpha = a
  dialog.red = r
  dialog.green = g
  dialog.blue = b
  dialog:ShowModal()
  local res, alpha, red, green, blue = nx_wait_event(100000000, dialog, "set_color_return")
  return res, alpha, red, green, blue
end
function save_text_form()
  local b_success = true
  local text_changes_list = nx_value("text_changes_list")
  if nx_is_valid(text_changes_list) then
    local item_list = text_changes_list:GetChildList()
    for i = 1, table.getn(item_list) do
      if not save_value(item_list[i].Name, item_list[i].value, item_list[i].text_name) then
        b_success = false
      else
        text_changes_list:RemoveChildByID(item_list[i])
      end
    end
  end
  local question_changes_list = nx_value("question_changes_list")
  if nx_is_valid(question_changes_list) then
    local item_list = question_changes_list:GetChildList()
    for i = 1, table.getn(item_list) do
      if 0 == save_question(item_list[i]) then
        b_success = false
      else
        question_changes_list:RemoveChildByID(item_list[i])
      end
    end
  end
  if not b_success then
    return 0
  end
  return 1
end
function set_changes(key, value, text_name)
  local text_changes_list = nx_value("text_changes_list")
  if not nx_is_valid(text_changes_list) then
    text_changes_list = nx_create("ArrayList", "text_changes_list")
    nx_set_value("text_changes_list", text_changes_list)
  end
  local item = text_changes_list:GetChild(key)
  if not nx_is_valid(item) then
    item = text_changes_list:CreateChild(key)
  end
  item.value = value
  item.text_name = text_name
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    task_form.btn_save.Enabled = true
  end
  return 1
end
function delete_changes(key)
  local text_changes_list = nx_value("text_changes_list")
  if nx_is_valid(text_changes_list) then
    text_changes_list:RemoveChild(key)
  end
  return 1
end
function is_in_changes(key)
  local text_changes_list = nx_value("text_changes_list")
  if nx_is_valid(text_changes_list) then
    local child = text_changes_list:GetChild(key)
    if nx_is_valid(child) then
      return true
    end
  end
  return false
end
function grid_double_click_grid(self, row, col)
  local gui = nx_value("gui")
  if col == 1 then
    local ctrl = CREATE_CONTROL("Edit")
    ctrl.Width = self:GetColWidth(col)
    ctrl.Text = self:GetGridText(row, col)
    ctrl.BackColor = EDIT_COLOR
    nx_bind_script(ctrl, nx_current())
    nx_callback(ctrl, "on_enter", "edit_enter")
    nx_callback(ctrl, "on_lost_focus", "edit_enter")
    self:SetGridControl(row, col, ctrl)
    gui.Focused = ctrl
    self.cur_select_row = row
    self.cur_select_col = col
    return ctrl
  end
  return 1
end
function edit_enter(self)
  local grid = self.Parent
  local control_box = grid.Parent
  local form = control_box.Parent.Parent
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  if not nx_is_valid(task_form.sect_node) then
    return 0
  end
  local old = grid:GetGridControl(grid.cur_select_row, grid.cur_select_col)
  if nx_is_valid(old) then
    local name = nx_string(grid:GetGridText(grid.cur_select_row, 0))
    local new_value = nx_string(old.Text)
    if nx_find_custom(grid, "item") then
      local node_info = nx_custom(grid, "item")
      if nx_is_valid(node_info) then
        local old_value = nx_string(grid:GetGridText(grid.cur_select_row, 1))
        grid:ClearGridControl(grid.cur_select_row, grid.cur_select_col)
        if new_value ~= old_value then
          local res, error = nx_execute("form_task\\form_task", "is_text_in_range", new_value, task_form.sect_node)
          if not res then
            nx_msgbox(new_value .. error)
            return 0
          end
          local flag1 = nx_custom(grid, "flag1")
          local flag2 = nx_custom(grid, "flag2")
          local flag3 = nx_custom(grid, "flag3")
          if flag1 == "task" then
            nx_set_custom(node_info, name, new_value)
            set_modify_task_info("modify_task_info", node_info.ID, name, old_value, new_value)
            nx_execute("form_task\\form_task", "set_change", node_info, "task")
            nx_execute("form_task\\form_task_info", "update_task_info", task_form.task_info_form, task_form.task_info)
          elseif flag1 == "subfunction" then
            local child = node_info:GetChild(name)
            child.item_name = new_value
            set_modify_subtask_overview("grid_subtask_overview", flag2, node_info.Name, name, flag3, old_value, new_value)
            nx_execute("form_task\\form_task", "set_change", node_info.Name, flag2)
            if nx_is_valid(task_form.subtask_process_form) then
              nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
            end
          elseif flag1 == "questiongroup" then
            local child = node_info:GetChild(name)
            child.item_name = new_value
            local prop_list_text = {
              "ZZAnswerText3",
              "ZZAnswerText2",
              "ZZAnswerText1",
              "MainText"
            }
            local question_contend = nx_value("question_contend")
            if new_value ~= "" and not question_contend:FindChild(new_value) then
              if not nx_is_valid(task_form.sect_node) then
                return 0
              end
              local child = task_form.sect_node:GetChild("questions")
              if nx_is_valid(child) then
                local result, error = nx_execute("form_task\\form_task", "is_in_range", new_value, child)
                if not result then
                  nx_msgbox("\206\202\204\226ID " .. error)
                  return 0
                end
              else
                return 0
              end
              local res = show_confirm_box("\202\199\183\241\208\194\189\168\206\202\204\226" .. new_value)
              if res then
                local info = question_contend:CreateChild(new_value)
                local title_info = question_contend:GetChild("title_info")
                local title_info_count = title_info:GetChildCount()
                for m = 0, title_info_count - 1 do
                  local title_child = title_info:GetChildByIndex(m)
                  local title_name = title_child.item_name
                  local child = info:CreateChild(title_name)
                  child.item_name = ""
                end
                set_question_changes(info.Name, info)
              end
            end
            set_modify_subtask_overview("grid_subtask_overview", flag2, node_info.Name, name, flag3, old_value, new_value)
            nx_execute("form_task\\form_task", "set_change", node_info.Name, "questiongroup")
            if nx_is_valid(task_form.subtask_process_form) then
              nx_execute("form_task\\form_subtask_process", "update_subtask_process_view", task_form.subtask_process_form)
            end
          elseif flag1 == "question" then
            local child = node_info:GetChild(name)
            child.item_name = new_value
            set_modify_questions(node_info.Name, name, old_value, new_value)
            set_question_changes(node_info.Name, node_info)
          elseif flag1 == "convoypoint" then
            local path_info = node_info:GetChildByIndex(flag3)
            if nx_is_valid(path_info) then
              nx_set_custom(path_info, flag2, new_value)
              nx_execute("form_task\\form_task", "set_change", node_info, PATH)
              local path_overview_form = nx_value("path_overview_form")
              if nx_is_valid(path_overview_form) then
                nx_execute("form_task\\form_path_overview", "update_path_overview", path_overview_form)
              end
            end
          end
          reload_control_box(control_box)
        end
      end
    end
  end
  return 1
end
function set_question_changes(id, node)
  local question_changes_list = nx_value("question_changes_list")
  if not nx_is_valid(question_changes_list) then
    question_changes_list = nx_create("ArrayList", "question_changes_list")
    nx_set_value("question_changes_list", question_changes_list)
  end
  local child = question_changes_list:GetChild(id)
  if not nx_is_valid(child) then
    child = question_changes_list:CreateChild(id)
  end
  child.info = node
  local task_form = nx_value("task_form")
  if nx_is_valid(task_form) then
    task_form.btn_save.Enabled = true
  end
  return 1
end
function move_question_changes(id)
  local question_changes_list = nx_value("question_changes_list")
  if nx_is_valid(question_changes_list) then
    question_changes_list:RemoveChild(id)
  end
  return 1
end
function save_question(node)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local id = node.Name
  local info = node.info
  local work_path = nx_value("work_path")
  if nx_is_valid(task_form.sect_node) then
    local child = task_form.sect_node:GetChild("questions")
    if nx_is_valid(child) then
      local textgrid = nx_create("TextGrid")
      textgrid.FileName = work_path .. child.file_name
      textgrid:LoadFromFile(2)
      local index = textgrid:FindRowIndexs(nx_int(0), id)
      if 0 < table.getn(index) then
        if not nx_is_valid(info) then
          textgrid:RemoveRowByIndex(nx_int(index[1]))
        else
          for j = 1, textgrid.ColCount - 1 do
            local prop = textgrid:GetColName(j)
            local child = info:GetChild(prop)
            if nx_is_valid(child) then
              textgrid:SetValueString(nx_int(index[1]), prop, child.item_name)
            end
          end
        end
      elseif nx_is_valid(info) then
        local row = textgrid:AddRow(info.Name)
        for j = 1, textgrid.ColCount - 1 do
          local prop = textgrid:GetColName(j)
          local child = info:GetChild(prop)
          if nx_is_valid(child) then
            textgrid:SetValueString(nx_int(row), prop, child.item_name)
          end
        end
      end
      if not textgrid:SaveToFile() then
        nx_msgbox(textgrid.FileName .. " - \206\196\188\254\177\163\180\230\180\237\206\243")
        nx_destroy(textgrid)
        return 0
      end
      nx_destroy(textgrid)
    end
  end
  return 1
end
local change_sub_string = function(s, s1, s2)
  if s == nil or s1 == nil or s2 == nil then
    return s
  end
  local ret = ""
  local pos = string.find(s, s1)
  if pos == nil then
    return s
  end
  local len = string.len(s1)
  local s_len = string.len(s)
  ret = string.sub(s, 1, pos - 1) .. s2 .. string.sub(s, pos + len, s_len)
  return ret
end
local function set_grid_default_value(value_map, task_id, obj)
  local key = nx_string(obj:GetGridText(0, 0))
  local value = nx_string(obj:GetGridText(0, 1))
  if value_map:FindChild(key) then
    local default_value = value_map:GetChild(key).item_name
    if nil ~= string.find(default_value, "TaskID") then
      local list = nx_function("ext_split_string", default_value, ";")
      default_value = ""
      for j = 1, table.getn(list) do
        default_value = default_value .. SPLIT_CHAR .. change_sub_string(list[j], "TaskID", task_id)
      end
      default_value = string.sub(default_value, 2, string.len(default_value))
    end
    if nil ~= string.find(default_value, "\178\189\214\232ID") then
      local list = nx_function("ext_split_string", default_value, ";")
      default_value = ""
      for j = 1, table.getn(list) do
        if nx_find_custom(obj, "id") then
          local new_value = change_sub_string(list[j], "\178\189\214\232ID", obj.id)
          if nil ~= string.find(new_value, "\185\202\202\194Order") and nx_find_custom(obj, "flag3") then
            new_value = change_sub_string(new_value, "\185\202\202\194Order", nx_string(obj.flag3 + 1))
          end
          default_value = default_value .. SPLIT_CHAR .. new_value
        end
      end
      default_value = string.sub(default_value, 2, string.len(default_value))
    end
    if nil ~= string.find(default_value, "\204\226\196\191ID") then
      local list = nx_function("ext_split_string", default_value, ";")
      default_value = ""
      for j = 1, table.getn(list) do
        if nx_find_custom(obj, "pro_id") then
          default_value = default_value .. SPLIT_CHAR .. change_sub_string(list[j], "\204\226\196\191ID", obj.pro_id)
        end
      end
      default_value = string.sub(default_value, 2, string.len(default_value))
    end
    if nil ~= string.find(default_value, "OrderID") then
      local list = nx_function("ext_split_string", default_value, ";")
      default_value = ""
      for j = 1, table.getn(list) do
        if nx_find_custom(obj, "flag3") then
          default_value = default_value .. SPLIT_CHAR .. change_sub_string(list[j], "OrderID", obj.flag3 + 1)
        end
      end
      default_value = string.sub(default_value, 2, string.len(default_value))
    end
    if default_value ~= value then
      local edit = grid_double_click_grid(obj, 0, 1)
      edit.Text = nx_widestr(default_value)
      edit_enter(edit)
    end
  elseif (key == "TrackInfo" or key == "TrackInfoID") and nx_find_custom(obj, "type") then
    local rel_key
    if obj.type == "useitem" or obj.type == "story" or obj.type == "question" or obj.type == "choose" or obj.type == "special" then
      rel_key = obj.type .. "_TrackInfoID"
    else
      rel_key = obj.type .. "_TrackInfo"
    end
    if value_map:FindChild(rel_key) then
      local default_value = value_map:GetChild(rel_key).item_name
      if nil ~= string.find(default_value, "\178\189\214\232ID") then
        local list = nx_function("ext_split_string", default_value, ";")
        default_value = ""
        for j = 1, table.getn(list) do
          if nx_find_custom(obj, "id") then
            default_value = default_value .. SPLIT_CHAR .. change_sub_string(list[j], "\178\189\214\232ID", obj.id)
          end
        end
        default_value = string.sub(default_value, 2, string.len(default_value))
        if default_value ~= value then
          local edit = grid_double_click_grid(obj, 0, 1)
          edit.Text = nx_widestr(default_value)
          edit_enter(edit)
        end
      end
    end
  end
  return 1
end
local make_hyper_link = function(href, text)
  return "<a href=\"" .. href .. "\" style=\"HLStype1\">" .. text .. "</a>"
end
function make_default_text_1(scene_id, npc_id, direct_text)
  local ret = ""
  local href = "findnpc_new," .. nx_string(scene_id) .. "," .. nx_string(npc_id)
  local hyper_link_text, text
  if direct_text ~= nil then
    text = direct_text
  else
    text = get_npc_name(nx_string(npc_id))
  end
  hyper_link_text = make_hyper_link(href, text)
  return hyper_link_text
end
function make_default_text_2(scene_id, target_config, item_id, direct_text)
  local gui = nx_value("gui")
  local ret = ""
  if target_config == "" then
    local href = "TASK_ITEM," .. nx_string(item_id)
    local text
    if direct_text ~= nil then
      text = direct_text
    else
      text = nx_string(gui.TextManager:GetText(nx_string(item_id)))
    end
    ret = make_hyper_link(href, text)
  else
    local href_1 = "findnpc_new," .. nx_string(scene_id) .. "," .. target_config
    local hyper_link_1 = make_hyper_link(href_1, get_npc_name(nx_string(target_config)))
    local href_2 = "TASK_ITEM," .. item_id
    local hyper_link_2 = make_hyper_link(href_2, nx_string(gui.TextManager:GetText(nx_string(item_id))))
    ret = hyper_link_1 .. hyper_link_2
  end
  return ret
end
function make_default_text_3(scene_id, npc_id, direct_convoy_type, direct_target_pos_x, direct_target_pos_y, direct_target_pos_z, direct_text)
  local ret = ""
  local convoy_type = get_npc_property(npc_id, "convoy_type")
  if direct_convoy_type ~= nil then
    convoy_type = direct_convoy_type
  end
  if convoy_type == "1" or convoy_type == "2" then
    local target_pos_x, target_pos_y, target_pos_z
    if direct_target_pos_x ~= nil then
      target_pos_x = direct_target_pos_x
    else
      target_pos_x = get_npc_property(npc_id, "target_pos_x")
    end
    if direct_target_pos_y ~= nil then
      target_pos_y = direct_target_pos_y
    else
      target_pos_y = "0"
    end
    if direct_target_pos_z ~= nil then
      target_pos_z = direct_target_pos_z
    else
      target_pos_z = get_npc_property(npc_id, "target_pos_z")
    end
    local bref = "findnpc," .. scene_id .. "," .. target_pos_x .. "," .. target_pos_y .. "," .. target_pos_z
    local text
    if direct_text ~= nil then
      text = direct_text
    else
      text = "\196\179\181\216"
    end
    ret = make_hyper_link(bref, text)
  elseif convoy_type == "3" then
    ret = get_npc_name(nx_string(npc_id))
  end
  return ret
end
function set_summary_edit_text_default_value(obj)
  local task_form = nx_value("task_form")
  if not nx_is_valid(task_form) then
    return 0
  end
  local task_info = task_form.task_info
  local groupbox = obj.default_groupbox
  local edit = groupbox.edit
  local richedit = groupbox.richedit
  local scene_id = nx_custom(task_info, "SubmitSceneID")
  local submit_npc = nx_custom(task_info, "SubmitNpc")
  local scene_desc = get_scene_info_by_number(scene_id)
  local text = make_default_text_1(scene_desc, submit_npc)
  edit.Text = nx_widestr(text)
  richedit.Text = nx_widestr(text)
  return 1
end
function set_subtask_edit_text_default_value(obj)
  local type, id
  if nx_find_custom(obj, "type") then
    type = obj.type
  else
    return 0
  end
  if nx_find_custom(obj, "id") then
    id = obj.id
  else
    return 0
  end
  local groupbox = obj.default_groupbox
  local edit = groupbox.edit
  local richedit = groupbox.richedit
  local scene_id = nx_custom(obj, "scene_id")
  local npc_id = nx_custom(obj, "npc_id")
  local item_id = nx_custom(obj, "item_id")
  local target_config = nx_custom(obj, "target_config")
  local question_npc = nx_custom(obj, "question_npc")
  local get_items = nx_custom(obj, "get_items")
  local lost_items = nx_custom(obj, "lost_items")
  local text = ""
  local scene_desc = get_scene_info_by_number(scene_id)
  if type == "hunter" or type == "collect" or type == "interact" or type == "story" then
    text = make_default_text_1(scene_desc, npc_id)
    if type == "hunter" then
      text = "\187\247\176\220" .. text
    end
    if type == "collect" then
      text = "\202\213\188\175" .. text
    end
    if type == "interact" then
      text = "\211\235" .. text .. "\189\187\204\184"
    end
    if type == "story" then
      text = "\204\253" .. text .. "\203\223\203\181"
    end
  elseif type == "question" then
    text = make_default_text_1(scene_desc, question_npc)
    text = "\187\216\180\240" .. text .. "\181\196\206\202\204\226"
  elseif type == "useitem" then
    text = make_default_text_2(scene_desc, target_config, item_id)
    text = "\202\185\211\195" .. text
  elseif type == "convoy" then
    text = make_default_text_3(scene_desc, npc_id)
    text = "\180\248" .. text
  end
  if npc_id ~= nil and npc_id ~= "" then
    text = text .. "<br/>NpcId=" .. get_npc_name(nx_string(npc_id))
  end
  if get_items ~= nil and get_items ~= "" then
    text = text .. "<br/>GetItems=" .. get_npc_name(nx_string(get_items))
  end
  if lost_items ~= nil and lost_items ~= "" then
    text = text .. "<br/>LostItems=" .. get_npc_name(nx_string(lost_items))
  end
  if item_id ~= nil and item_id ~= "" then
    text = text .. "<br/>ItemId=" .. get_npc_name(nx_string(item_id))
  end
  edit.Text = nx_widestr(text)
  richedit.Text = nx_widestr(text)
  return 1
end
local function set_default_value(ctlbox, value_map, task_id)
  local i = 0
  while true do
    local obj = ctlbox:GetControl(i)
    if nx_name(obj) == "Grid" then
      local key = nx_string(obj:GetGridText(0, 0))
      if key ~= "SubmitNpcEx" then
        set_grid_default_value(value_map, task_id, obj)
      end
    end
    i = i + 1
    if i >= ctlbox.ItemCount then
      break
    end
  end
  return 1
end
function load_default_params_setting()
  local work_path = nx_value("work_path")
  if "" == work_path then
    return false
  end
  local ini = nx_create("IniDocument")
  ini.FileName = work_path .. DEFAULT_PARAMS_SETTING
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local default_params_setting = nx_value("default_params_setting")
  if not nx_is_valid(default_params_setting) then
    default_params_setting = nx_create("ArrayList", "default_params_setting")
    nx_set_value("default_params_setting", default_params_setting)
  else
    default_params_setting:ClearChild()
  end
  local sect_list = ini:GetSectionList()
  local sect_count = table.getn(sect_list)
  for i = 1, sect_count do
    local sect_name = sect_list[i]
    local sect = default_params_setting:CreateChild(sect_name)
    local item_list = ini:GetItemList(sect_name)
    local item_count = table.getn(item_list)
    for j = 1, item_count do
      local item_name = item_list[j]
      local item = sect:CreateChild(item_name)
      item.item_name = ini:ReadString(sect_name, item_name, "")
    end
  end
  nx_destroy(ini)
  return 1
end
function default_params_setting_click(self)
  local form = self.Parent
  local edit_type = self.edit_type
  local default_params_setting = nx_value("default_params_setting")
  if not nx_is_valid(default_params_setting) then
    return 0
  end
  if edit_type == "main_text" then
    local ctrlbox_form_text = form.main_text_form.ctrlbox_form_text
    local ctrlbox_track_text = form.main_text_form.ctrlbox_track_text
    set_default_value(ctrlbox_form_text, default_params_setting:GetChild("main_text"), form.task_info.ID)
    set_default_value(ctrlbox_track_text, default_params_setting:GetChild("main_text"), form.task_info.ID)
  elseif edit_type == "dialog_text" then
    local ctrlbox_dialog_text = form.dialog_text_form.ctrlbox_dialog_text
    local ctrlbox_step_text = form.dialog_text_form.ctrlbox_step_text
    set_default_value(ctrlbox_dialog_text, default_params_setting:GetChild("dialog_text"), form.task_info.ID)
    set_default_value(ctrlbox_step_text, default_params_setting:GetChild("dialog_text"), form.task_info.ID)
  end
  return 1
end
function on_click_default_single_btn(self)
  local default_params_setting = nx_value("default_params_setting")
  if not nx_is_valid(default_params_setting) then
    return 0
  end
  local grid = self.grid
  local form = grid.Parent.Parent.Parent
  local value_map = default_params_setting:GetChild(form.default_params_setting.edit_type)
  return set_grid_default_value(value_map, form.task_info.ID, self.grid)
end
function on_checked_changed_rtn(self)
  local grid = self.grid
  if not nx_find_custom(grid, "groupbox") or grid.groupbox == nil then
    return 0
  end
  if self.Checked then
    self.Text = nx_widestr("\203\248\182\168\215\180\204\172")
    self.ForeColor = "255, 255, 0, 0"
  else
    self.Text = nx_widestr("\189\226\179\253\203\248\182\168")
    self.ForeColor = "255, 0, 0, 0"
  end
  local groupbox = grid.groupbox
  while true do
    local richedit = groupbox.richedit
    local edit = groupbox.edit
    richedit.lock_state = self.Checked
    edit.lock_state = self.Checked
    leave_the_changes(richedit)
    if not nx_find_custom(groupbox, "groupbox") or groupbox.groupbox == nil then
      break
    else
      groupbox = groupbox.groupbox
    end
  end
  return 1
end
function show_confirm_box(title)
  local gui = nx_value("gui")
  local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_yes_no_cancel.xml")
  dialog.info_label.Text = nx_widestr(title)
  dialog.cancel_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "yes_no_cancel_return")
  if res == "yes" then
    return true
  end
  return false
end
function btn_quick_color_click(self)
  if not self.Parent.rbtn_preview.Checked then
    return 0
  end
  if nx_is_valid(self.aim_rich_edit) then
    self.aim_rich_edit:ChangeSelectColor(self.BackColor)
    leave_the_changes(self.aim_rich_edit)
  end
  return 1
end
function btn_quick_color_right_click(self)
  local gui = nx_value("gui")
  local color = self.BackColor
  local res, alpha, red, green, blue = get_color(color)
  if res ~= "cancel" then
    color = nx_string(alpha) .. "," .. nx_string(red) .. "," .. nx_string(green) .. "," .. nx_string(blue)
    self.BackColor = color
  end
  return 1
end
function make_string_to_white(text)
  local aft_text = ""
  local start = 1
  local pos = string.find(text, "#000000")
  while pos ~= nil do
    aft_text = aft_text .. string.sub(text, start, pos - 1) .. "#ffffff"
    start = pos + string.len("#000000")
    pos = string.find(text, "#000000", start)
  end
  aft_text = aft_text .. string.sub(text, start, string.len(text))
  return aft_text
end
local make_black_to_white = function(ctrlbox)
  local item_count = ctrlbox.ItemCount
  for i = 0, item_count - 1 do
    local ctrl = ctrlbox:GetControl(i)
    if nx_name(ctrl) == "GroupBox" and nx_find_custom(ctrl.edit, "lock_state") and not ctrl.edit.lock_state and ctrl.richedit.prop ~= "Default" then
      local old_text = nx_string(ctrl.edit.Text)
      local new_text = make_string_to_white(old_text)
      ctrl.edit.Text = nx_widestr(new_text)
      ctrl.richedit.Text = nx_widestr(new_text)
      leave_the_changes(ctrl.richedit)
    end
  end
  return 1
end
function btn_set_white_click(self)
  local form = self.Parent
  local edit_type = ""
  if form.rbtn_form_text.Checked then
    edit_type = "main_text"
  else
    edit_type = "dialog_text"
  end
  if edit_type == "main_text" then
    local ctrlbox_form_text = form.main_text_form.ctrlbox_form_text
    local ctrlbox_track_text = form.main_text_form.ctrlbox_track_text
    make_black_to_white(ctrlbox_form_text)
    make_black_to_white(ctrlbox_track_text)
  elseif edit_type == "dialog_text" then
    local ctrlbox_dialog_text = form.dialog_text_form.ctrlbox_dialog_text
    local ctrlbox_step_text = form.dialog_text_form.ctrlbox_step_text
    make_black_to_white(ctrlbox_dialog_text)
    make_black_to_white(ctrlbox_step_text)
  end
  return 1
end
function set_edit_lock_property(form)
  local ctrlbox_list = {
    form.main_text_form.ctrlbox_form_text,
    form.main_text_form.ctrlbox_track_text,
    form.dialog_text_form.ctrlbox_dialog_text,
    form.dialog_text_form.ctrlbox_step_text
  }
  local ctrlbox_count = table.getn(ctrlbox_list)
  for i = 1, ctrlbox_count do
    local ctrlbox = ctrlbox_list[i]
    local item_count = ctrlbox.ItemCount
    for j = 0, item_count - 1 do
      local ctrl = ctrlbox:GetControl(j)
      if nx_name(ctrl) == "Grid" then
        local lock_rtn = ctrl:GetGridControl(0, 3)
        local groupbox
        if nx_find_custom(ctrl, "groupbox") then
          groupbox = ctrl.groupbox
        end
        while groupbox ~= nil do
          groupbox.edit.lock_state = lock_rtn.Checked
          groupbox.richedit.lock_state = lock_rtn.Checked
          if nx_find_custom(groupbox, "groupbox") then
            groupbox = groupbox.groupbox
          else
            groupbox = nil
          end
        end
      end
    end
  end
  return 1
end
function custom_hyper_button_click(self)
  if not nx_find_custom(self, "aim_rich_edit") then
    return 0
  end
  if not nx_is_valid(self.aim_rich_edit) then
    return 0
  end
  local groupbox = self.aim_rich_edit.Parent
  local ctrlbox = groupbox.Parent
  local item_count = ctrlbox.ItemCount
  for j = 0, item_count - 1 do
    local ctrl = ctrlbox:GetControl(j)
    if nx_name(ctrl) == "Grid" and nx_id_equal(ctrl.groupbox, groupbox) then
      local gui = nx_value("gui")
      local dialog = LOAD_FORM(nx_resource_path(), gui.skin_path .. "form_task\\form_custom_define_hyper.xml")
      dialog.grid = ctrl
      dialog:ShowModal()
      return 1
    end
  end
  return 0
end
