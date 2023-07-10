require("util_gui")
require("util_functions")
require("tips_data")
require("share\\client_custom_define")
require("form_stage_main\\form_teacher_pupil_new\\teacherpupil_define_new")
require("form_stage_main\\form_teacher_pupil_new\\form_teacherpupil_func_new")
ID_NAME = 1
ID_SHITU_SEX = 2
ID_SHITU_FLAG = 3
ID_CHUSHICOUNT = 4
ID_SCHOOL = 5
ID_POWER_LEVEL = 6
ID_COMMENT = 7
ID_ONLINE = 8
function on_main_form_init(form)
  form.Fixed = true
  form.shitu_list = nx_call("util_gui", "get_arraylist", "shitu_list_info")
  form.subform_id = -1
  form.shitu_flag = 0
  form.shitu_teacher_sex = 2
  form.subform_id = 0
  form.select_school = ""
end
function on_main_form_open(form)
  nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_REGIST_INFO)
  form.groupbox_menu.Visible = false
  init_select_condition(form)
end
function on_main_form_close(self)
  if nx_find_custom(self, "shitu_list") and nx_is_valid(self.shitu_list) then
    self.shitu_list:ClearChild()
    nx_destroy(self.shitu_list)
  end
  nx_destroy(self)
end
function on_btn_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local request_form = nx_execute("util_gui", "util_get_form", FORM_REGISTER_INFO_NEW, true, false)
  if not nx_is_valid(request_form) then
    return
  end
  request_form.shitu_flag = form.shitu_flag
  request_form:Show()
end
function on_btn_unregiste_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(util_text("ui_shitu_tishi")), -1)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", CUSTOM_MSG_FUN, NT_CTS_ASK_UNREGIST)
  end
end
function on_combobox_sex_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(combox.Text) == nx_widestr(util_text("ui_suoyoushixiong")) or nx_widestr(combox.Text) == nx_widestr(util_text("ui_suoyoushidi")) then
    form.shitu_teacher_sex = 2
    refresh_grid_list(form)
    return
  end
  if nx_widestr(combox.Text) == nx_widestr(util_text("ui_shitu_male")) then
    form.shitu_teacher_sex = 0
    refresh_grid_list(form)
    return
  end
  if nx_widestr(combox.Text) == nx_widestr(util_text("ui_shitu_female")) then
    form.shitu_teacher_sex = 1
    refresh_grid_list(form)
    return
  end
end
function on_combobox_school_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(combox.Text) == nx_widestr(util_text("ui_suoyoumenpai")) then
    form.select_school = ""
    refresh_grid_list(form)
    return
  end
  local count = table.getn(new_school_list)
  for i = 1, count do
    if nx_widestr(combox.Text) == nx_widestr(util_text(new_school_list[i])) then
      form.select_school = new_school_list[i]
      refresh_grid_list(form)
      return
    end
  end
end
function on_btn_baishi_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  local player = form.sel_player
  if nx_widestr("") == nx_widestr(player) then
    return
  end
  nx_execute(FORM_REQUEST_NEW, "custom_request_teacher_pupil", REQUEST_BAISHI, nx_widestr(player))
end
function on_btn_shoutu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  local player = form.sel_player
  if nx_widestr("") == nx_widestr(player) then
    return
  end
  nx_execute(FORM_REQUEST_NEW, "custom_request_teacher_pupil", REQUEST_SHOUTU, nx_widestr(player))
end
function on_btn_queryinfo_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  local player = form.sel_player
  if nx_widestr("") == nx_widestr(player) then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", player)
end
function on_textgrid_list_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = grid:GetGridText(row, 0)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  local is_online = grid:GetGridText(row, 4)
  if nx_int(is_online) == nx_int(0) then
    return
  end
  form.sel_player = player_name
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  form.groupbox_menu.AbsLeft = x
  form.groupbox_menu.AbsTop = y
  form.groupbox_menu.Visible = true
  if nx_int(Senior_fellow_apprentice) == nx_int(form.shitu_flag) then
    form.groupbox_menu.Height = 48
    form.btn_baishi.Visible = true
    form.btn_shoutu.Visible = false
    form.btn_queryinfo.Top = 24
  elseif nx_int(Junior_fellow_apprentice) == nx_int(form.shitu_flag) then
    form.groupbox_menu.Height = 48
    form.btn_baishi.Visible = false
    form.btn_shoutu.Visible = true
    form.btn_shoutu.Top = 0
    form.btn_queryinfo.Top = 24
  end
end
function on_textgrid_list_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
end
function on_btn_return_click(btn)
  nx_execute(FORM_MSG_NEW, "show_main_page")
end
function refresh_form(form)
  refresh_grid_list(form)
end
function init_select_condition(form)
  local subform_id = form.subform_id
  if nx_int(subform_id) == nx_int(SUB_FORM_TEACHER_REGISTER) then
    form.shitu_flag = Senior_fellow_apprentice
    form.combobox_sex.Text = util_text("ui_suoyoushixiong")
    form.btn_request.Text = util_text("ui_shixiongdengji")
    form.combobox_sex.DropListBox:AddString(nx_widestr(util_text("ui_suoyoushixiong")))
  else
    form.shitu_flag = Junior_fellow_apprentice
    form.combobox_sex.Text = util_text("ui_suoyoushidi")
    form.btn_request.Text = util_text("ui_shididengji")
    form.combobox_sex.DropListBox:AddString(nx_widestr(util_text("ui_suoyoushidi")))
  end
  form.combobox_sex.DropListBox:AddString(nx_widestr(util_text("ui_shitu_male")))
  form.combobox_sex.DropListBox:AddString(nx_widestr(util_text("ui_shitu_female")))
  form.combobox_school.Text = util_text("ui_suoyoumenpai")
  form.combobox_school.DropListBox:AddString(nx_widestr(util_text("ui_suoyoumenpai")))
  local count = table.getn(new_school_list)
  for i = 1, count do
    form.combobox_school.DropListBox:AddString(nx_widestr(util_text(new_school_list[i])))
  end
  init_cols_name(form)
end
function refresh_grid_list(form)
  if not nx_find_custom(form, "shitu_list") then
    return
  end
  if not nx_is_valid(form.shitu_list) then
    return
  end
  local grid = form.textgrid_list
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  local child_count = form.shitu_list:GetChildCount()
  if nx_int(child_count) > nx_int(0) then
    for i = 1, child_count do
      local child = form.shitu_list:GetChildByIndex(i - 1)
      if nx_is_valid(child) then
        local continue = true
        if nx_int(child.shitu_flag) ~= nx_int(form.shitu_flag) then
          continue = false
        end
        if nx_string(form.select_school) ~= nx_string("") and nx_string(child.school) ~= nx_string(form.select_school) then
          continue = false
        end
        if nx_string(form.select_school) == nx_string("school_wulin") and nx_string(child.school) == nx_string("") then
          continue = true
        end
        if form.shitu_teacher_sex ~= 2 and child.sex ~= form.shitu_teacher_sex then
          continue = false
        end
        if continue then
          insert_row(grid, child)
        end
      end
    end
  end
  grid:SortRowsByInt(4, true)
  grid:EndUpdate()
end
function insert_row(grid, item)
  if not nx_is_valid(grid) then
    return
  end
  local row = grid.RowCount
  grid:InsertRow(row)
  grid:SetGridText(row, 0, nx_widestr(item.name))
  local sex = nx_int(item.sex)
  local shitu_flag = item.shitu_flag
  if nx_int(Senior_fellow_apprentice) == nx_int(shitu_flag) then
    grid:SetGridText(row, 1, nx_widestr(Get_PowerLevel_Name(item.power_level)))
    grid:SetGridText(row, 2, nx_widestr(item.chushi_count))
    local comment = item.comment
    local checkwords = nx_value("CheckWords")
    if nx_is_valid(checkwords) then
      comment = checkwords:CleanWords(nx_widestr(comment))
    end
    grid:SetGridText(row, 3, nx_widestr(comment))
    grid:SetGridText(row, 4, nx_widestr(item.is_online))
  else
    grid:SetGridText(row, 1, nx_widestr(util_text(nx_string(item.school))))
    grid:SetGridText(row, 2, nx_widestr(Get_PowerLevel_Name(item.power_level)))
    local comment = item.comment
    local checkwords = nx_value("CheckWords")
    if nx_is_valid(checkwords) then
      comment = checkwords:CleanWords(nx_widestr(comment))
    end
    grid:SetGridText(row, 3, nx_widestr(comment))
    grid:SetGridText(row, 4, nx_widestr(item.is_online))
  end
  if nx_int(item.is_online) == nx_int(0) then
    grid:SetGridForeColor(row, 0, "255,160,160,160")
    grid:SetGridForeColor(row, 1, "255,160,160,160")
    grid:SetGridForeColor(row, 2, "255,160,160,160")
    grid:SetGridForeColor(row, 3, "255,160,160,160")
    grid:SetGridForeColor(row, 4, "255,160,160,160")
    grid:SetGridForeColor(row, 5, "255,160,160,160")
  end
end
function init_cols_name(form)
  local subform_id = form.subform_id
  if nx_int(subform_id) == nx_int(SUB_FORM_TEACHER_REGISTER) then
    form.lbl_col1.Text = util_text("ui_shitu_name")
    form.lbl_col2.Text = util_text("ui_shitu_zhuangtai")
    form.lbl_col3.Text = util_text("ui_shitu_chushi")
    form.lbl_col4.Text = util_text("ui_shitu_desc")
  else
    form.lbl_col1.Text = util_text("ui_shitu_name")
    form.lbl_col2.Text = util_text("ui_shitu_menpai")
    form.lbl_col3.Text = util_text("ui_shitu_zhuangtai")
    form.lbl_col4.Text = util_text("ui_shitu_desc")
  end
end
function on_server_msg(...)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  update_shitu_list(form, nx_widestr(arg[1]), nx_int(arg[2]))
  refresh_form(form)
end
function update_shitu_list(form, shitu_list_info, num)
  if not nx_find_custom(form, "shitu_list") then
    return
  end
  if not nx_is_valid(form.shitu_list) then
    return
  end
  if nx_int(num) == nx_int(0) then
    form.shitu_list:ClearChild()
  end
  local child_count = form.shitu_list:GetChildCount()
  if nx_int(child_count) ~= nx_int(num) then
    return
  end
  local shitu_list = util_split_wstring(shitu_list_info, "|")
  for i = 1, table.getn(shitu_list) - 1 do
    local shitu_info = shitu_list[i]
    local shitu = util_split_wstring(shitu_info, ",")
    local child = form.shitu_list:GetChild("index" .. nx_string(i + nx_int(num)))
    if not nx_is_valid(child) then
      child = form.shitu_list:CreateChild("index" .. nx_string(i + nx_int(num)))
      child.name = nx_widestr(shitu[ID_NAME])
      child.sex = nx_int(shitu[ID_SHITU_SEX])
      child.shitu_flag = nx_int(shitu[ID_SHITU_FLAG])
      child.chushi_count = nx_int(shitu[ID_CHUSHICOUNT])
      child.school = nx_widestr(shitu[ID_SCHOOL])
      child.power_level = nx_widestr(shitu[ID_POWER_LEVEL])
      child.comment = nx_widestr(shitu[ID_COMMENT])
      child.is_online = nx_int(shitu[ID_ONLINE])
    end
  end
end
