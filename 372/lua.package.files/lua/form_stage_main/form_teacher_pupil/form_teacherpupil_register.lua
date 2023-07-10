require("util_gui")
require("util_functions")
require("define\\request_type")
require("define\\sysinfo_define")
require("tips_data")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
require("share\\static_data_type")
require("share\\client_custom_define")
require("form_stage_main\\form_teacher_pupil\\teacherpupil_define")
ID_NAME = 1
ID_SHITU_SEX = 2
ID_SHITU_FLAG = 3
ID_SHITU_TYPE = 4
ID_TEACHERLEVEL = 5
ID_PUPILCOUNT = 6
ID_CHUSHICOUNT = 7
ID_SCHOOL = 8
ID_NEIGONG_LIST = 9
ID_COMMENT = 10
ID_ONLINE = 11
local Cover_Img = {
  "gui\\language\\ChineseS\\schoolyulan\\mu.png",
  "gui\\language\\ChineseS\\schoolyulan\\tie.png",
  "gui\\language\\ChineseS\\schoolyulan\\yin.png",
  "gui\\language\\ChineseS\\schoolyulan\\jin.png"
}
local FINE_NEIGONG_INI = "share\\Skill\\NeiGong\\neigong.ini"
function on_main_form_init(form)
  form.Fixed = true
  form.shitu_list = nx_call("util_gui", "get_arraylist", "shitu_list_info")
  form.subform_id = -1
  form.shitu_flag = 0
  form.shitu_ng = true
  form.shitu_jm = true
  form.shitu_teacher_level = 0
  form.subform_id = 0
  form.select_school = ""
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.max_neigonglevel = nx_execute(FORM_REQUEST, "get_neigong_level")
  local cur_main_game_step = switch_manager:GetMainGameStep()
  if nx_int(form.max_neigonglevel) > nx_int(cur_main_game_step) then
    form.max_neigonglevel = cur_main_game_step
  end
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_QUERY)
  form.cbtn_ng.Checked = true
  form.cbtn_jm.Checked = true
  form.groupbox_menu.Visible = false
  init_select_condition(form)
end
function on_main_form_close(self)
  if not nx_find_custom(self, "shitu_list") then
    return
  end
  if not nx_is_valid(self.shitu_list) then
    return
  end
  self.shitu_list:ClearChild()
  nx_destroy(self.shitu_list)
  nx_destroy(self)
end
function on_cbtn_jm_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.shitu_jm = cbtn.Checked
  refresh_grid_list(form)
end
function on_cbtn_ng_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.shitu_ng = cbtn.Checked
  if not cbtn.Checked then
    form.combobox_ngl.Visible = false
  else
    form.combobox_ngl.Visible = true
  end
  refresh_grid_list(form)
end
function on_btn_request_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local request_form = nx_execute("util_gui", "util_get_form", FORM_REGISTER_INFO, true, false)
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
    nx_execute("custom_sender", "custom_teacher_pupil", TP_CTS_UN_REGISTER)
  end
end
function on_combobox_ngl_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local max_neigonglevel = form.max_neigonglevel
  if nx_int(form.shitu_flag) == nx_int(Senior_fellow_apprentice) then
    if nx_widestr(combox.Text) == nx_widestr(util_text("ui_suoyoushixiong")) then
      form.shitu_teacher_level = 0
      refresh_grid_list(form)
      return
    end
    for i = 2, max_neigonglevel do
      if nx_widestr(util_text("ui_shixiong_" .. i)) == nx_widestr(combox.Text) then
        form.shitu_teacher_level = i
        refresh_grid_list(form)
        return
      end
    end
  else
    if nx_widestr(combox.Text) == nx_widestr(util_text("ui_suoyoushidi")) then
      form.shitu_teacher_level = 0
      refresh_grid_list(form)
      return
    end
    for i = 2, max_neigonglevel do
      if nx_widestr(util_text("ui_shidi_" .. i)) == nx_widestr(combox.Text) then
        form.shitu_teacher_level = i
        refresh_grid_list(form)
        return
      end
    end
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
  local count = table.getn(school_list)
  for i = 1, count do
    if nx_widestr(combox.Text) == nx_widestr(util_text(school_list[i])) then
      form.select_school = school_list[i]
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
  nx_execute("form_stage_main\\form_teacher_pupil\\form_teacherpupil_request", "custom_request_teacher_pupil", 1, nx_widestr(player))
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
  nx_execute("form_stage_main\\form_teacher_pupil\\form_teacherpupil_request", "custom_request_teacher_pupil", 2, nx_widestr(player))
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
  form.sel_player = player_name
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  form.groupbox_menu.AbsLeft = x
  form.groupbox_menu.AbsTop = y
  form.groupbox_menu.Visible = true
end
function on_textgrid_list_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_menu.Visible = false
  local ng_info = grid:GetGridText(row, 5)
  show_neigong_info(form, ng_info)
end
function on_ImageControlGrid_neigong_mousein_grid(grid, index)
  show_neigong_tips(grid, index)
end
function on_ImageControlGrid_neigong_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_return_click(btn)
  nx_execute(FORM_MSG, "show_main_page")
end
function refresh_form(form)
  refresh_grid_list(form)
end
function init_select_condition(form)
  local subform_id = form.subform_id
  if nx_int(subform_id) == nx_int(SUB_FORM_TEACHER_REGISTER) then
    form.shitu_flag = Senior_fellow_apprentice
    form.combobox_ngl.Text = util_text("ui_suoyoushixiong")
    form.btn_request.Text = util_text("ui_shixiongdengji")
    form.lbl_3.BackImage = MY_PUPIL_PNG
    form.mltbox_1.Visible = true
    form.combobox_ngl.DropListBox:AddString(nx_widestr(util_text("ui_suoyoushixiong")))
    for i = 2, form.max_neigonglevel do
      form.combobox_ngl.DropListBox:AddString(nx_widestr(util_text("ui_shixiong_" .. i)))
    end
  else
    form.shitu_flag = Junior_fellow_apprentice
    form.combobox_ngl.Text = util_text("ui_suoyoushidi")
    form.btn_request.Text = util_text("ui_shididengji")
    form.lbl_3.BackImage = MY_TEACHER_PNG
    form.mltbox_1.Visible = false
    form.textgrid_list.Height = 356
    form.combobox_ngl.DropListBox:AddString(nx_widestr(util_text("ui_suoyoushidi")))
    for i = 2, form.max_neigonglevel do
      form.combobox_ngl.DropListBox:AddString(nx_widestr(util_text("ui_shidi_" .. i)))
    end
  end
  form.combobox_school.Text = util_text("ui_suoyoumenpai")
  form.combobox_school.DropListBox:AddString(nx_widestr(util_text("ui_suoyoumenpai")))
  local count = table.getn(school_list)
  for i = 1, count do
    form.combobox_school.DropListBox:AddString(nx_widestr(util_text(school_list[i])))
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
      local continue = true
      if not form.shitu_jm and nx_int(child.shitu_type) == nx_int(ShiTuType_JingMai) then
        continue = false
      end
      if not form.shitu_ng then
        if nx_int(ShiTuType_NeiGong) == nx_int(child.shitu_type) then
          continue = false
        end
      elseif nx_int(ShiTuType_NeiGong) == nx_int(child.shitu_type) and nx_number(form.shitu_teacher_level) ~= nx_number(0) and nx_number(child.teacher_level) ~= nx_number(form.shitu_teacher_level) then
        continue = false
      end
      if nx_int(child.shitu_flag) ~= nx_int(form.shitu_flag) then
        continue = false
      end
      if nx_string(form.select_school) ~= nx_string("") and nx_string(child.school) ~= nx_string(form.select_school) then
        continue = false
      end
      if continue then
        insert_row(grid, child)
      end
    end
  end
  grid:SortRowsByInt(4, true)
  grid:EndUpdate()
end
function insert_row(grid, item)
  local row = grid.RowCount
  grid:InsertRow(row)
  grid:SetGridText(row, 0, nx_widestr(item.name))
  local teacher_level = nx_number(item.teacher_level)
  local shitu_type = nx_int(item.shitu_type)
  local sex = nx_int(item.sex)
  local shitu_flag = item.shitu_flag
  if nx_int(Senior_fellow_apprentice) == nx_int(shitu_flag) then
    if nx_int(item.shitu_type) == nx_int(ShiTuType_JingMai) then
      grid:SetGridText(row, 1, nx_widestr(util_text("ui_shitu_jingmai_sx_" .. nx_string(sex))))
    else
      grid:SetGridText(row, 1, nx_widestr(util_text("ui_shitu_teacher_0" .. nx_string(teacher_level) .. "_" .. nx_string(sex))))
    end
    grid:SetGridText(row, 2, nx_widestr(item.chushi_count))
    local comment = item.comment
    local checkwords = nx_value("CheckWords")
    if nx_is_valid(checkwords) then
      comment = checkwords:CleanWords(nx_widestr(comment))
    end
    grid:SetGridText(row, 3, nx_widestr(comment))
    grid:SetGridText(row, 4, nx_widestr(item.is_online))
    grid:SetGridText(row, 5, nx_widestr(item.ng_list))
  else
    grid:SetGridText(row, 1, nx_widestr(util_text(nx_string(item.school))))
    if nx_int(item.shitu_type) == nx_int(ShiTuType_JingMai) then
      grid:SetGridText(row, 2, nx_widestr(util_text("ui_shitu_jingmai_sd_" .. nx_string(sex))))
    else
      grid:SetGridText(row, 2, nx_widestr(util_text("ui_shitu_pupil_0" .. nx_string(teacher_level) .. "_" .. nx_string(sex))))
    end
    local comment = item.comment
    local checkwords = nx_value("CheckWords")
    if nx_is_valid(checkwords) then
      comment = checkwords:CleanWords(nx_widestr(comment))
    end
    grid:SetGridText(row, 3, nx_widestr(comment))
    grid:SetGridText(row, 4, nx_widestr(item.is_online))
  end
  if nx_int(item.is_online) == nx_int(-1) then
    grid:SetGridForeColor(row, 0, "255,160,160,160")
    grid:SetGridForeColor(row, 1, "255,160,160,160")
    grid:SetGridForeColor(row, 2, "255,160,160,160")
    grid:SetGridForeColor(row, 3, "255,160,160,160")
    grid:SetGridForeColor(row, 4, "255,160,160,160")
    grid:SetGridForeColor(row, 5, "255,160,160,160")
  end
end
function on_server_msg(...)
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  update_shitu_list(form, nx_widestr(arg[1]))
  refresh_form(form)
end
function update_shitu_list(form, shitu_list_info)
  if not nx_find_custom(form, "shitu_list") then
    return
  end
  if not nx_is_valid(form.shitu_list) then
    return
  end
  form.shitu_list:ClearChild()
  local shitu_list = util_split_wstring(shitu_list_info, ";")
  for i = 1, table.getn(shitu_list) - 1 do
    local shitu_info = shitu_list[i]
    local shitu = util_split_wstring(shitu_info, ",")
    local child = form.shitu_list:GetChild("index" .. nx_string(i))
    if not nx_is_valid(child) then
      child = form.shitu_list:CreateChild("index" .. nx_string(i))
      child.name = nx_widestr(shitu[ID_NAME])
      child.sex = nx_int(shitu[ID_SHITU_SEX])
      child.shitu_flag = nx_int(shitu[ID_SHITU_FLAG])
      child.shitu_type = nx_int(shitu[ID_SHITU_TYPE])
      child.teacher_level = nx_int(shitu[ID_TEACHERLEVEL])
      child.pupil_count = nx_int(shitu[ID_PUPILCOUNT])
      child.chushi_count = nx_int(shitu[ID_CHUSHICOUNT])
      child.school = nx_widestr(shitu[ID_SCHOOL])
      child.ng_list = nx_widestr(shitu[ID_NEIGONG_LIST])
      child.comment = nx_widestr(shitu[ID_COMMENT])
      child.is_online = nx_int(shitu[ID_ONLINE])
    end
  end
end
function show_neigong_info(form, ng_info)
  if nx_int(Junior_fellow_apprentice) == nx_int(form.shitu_flag) then
    return
  end
  local grid = form.ImageControlGrid_neigong
  if not nx_is_valid(grid) then
    return
  end
  local ng_list = util_split_wstring(ng_info, "|")
  grid:Clear()
  local grid_index = 0
  for i, id in ipairs(ng_list) do
    if nx_string(id) ~= nx_string("") then
      local staticdata = get_ini_prop(FINE_NEIGONG_INI, id, "StaticData", "")
      local photo = neigong_static_query(staticdata, "Photo")
      grid:AddItem(grid_index, photo, util_text(nx_string(id)), 1, -1)
      grid:SetItemAddInfo(grid_index, nx_int(2), nx_widestr(id))
      grid_index = grid_index + 1
    end
  end
  form.groupscrollbox_1.Visible = true
  form.mltbox_1.Visible = false
end
function show_neigong_tips(grid, index)
  local neigong_id = grid:GetItemAddText(nx_int(index), nx_int(2))
  if nx_string(neigong_id) == nx_string("") then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local staticdata = get_ini_prop(FINE_NEIGONG_INI, neigong_id, "StaticData", "")
  local min_varpropno = neigong_static_query(staticdata, "MinVarPropNo")
  local bufferlevel = get_ini_prop("share\\Skill\\NeiGong\\neigong_varprop.ini", nx_string(min_varpropno + 35), "BufferLevel")
  local level = 36
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(neigong_id)
  item.ItemType = ITEMTYPE_NEIGONG
  item.StaticData = nx_number(staticdata)
  item.Level = level
  item.BufferLevel = bufferlevel
  item.is_static = true
  item.WuXing = faculty_query:GetWuXing(nx_string(neigong_id))
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
  end
  nx_execute("tips_game", "show_goods_tip", item, x, y, grid.GridWidth, grid.GridHeight, grid.ParentForm)
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
