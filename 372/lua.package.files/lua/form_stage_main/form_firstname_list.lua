require("util_gui")
require("utils")
require("util_functions")
require("tips_data")
local SINGLE_ROW_NUMS = 6
local DOUBLE_ROW_NUMS = 3
local ROW_NUMS = 4
local PAGE_NUMS = 30
local SINGLE_OFFSET_X = 2
local SINGLE_OFFSET_Y = -7
local DOUBLE_OFFSET_X = 30
local DOUBLE_OFFSET_Y = -7
local FIRST_NAME_DATA = "first_name_data"
local select_color = "255,0,255,255"
local normal_color = "255,255,255,255"
local FIRST_NAME_TEXT = 1
local FIRST_NAME_TIPS = 2
local FIRST_NAME_RAND = 3
local FIRST_NAME_ROW = 4
local FIRST_NAME_COL = 5
local FIRST_NAEM_NEW_INI = "ini\\form\\firstname.ini"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(form)
  form.Fixed = true
  form.Visible = true
end
local get_global_list = function(global_list_name)
  return nx_call("util_gui", "get_global_arraylist", global_list_name)
end
function main_form_open(form)
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local rule_info = CheckWords:GetNameRule()
  if #rule_info < 4 then
    return
  end
  form.btn_random.use_bjk = rule_info[1]
  if nx_int(rule_info[1]) == nx_int(1) then
    form.groupbox_bjx.Visible = true
  else
    form.groupbox_bjx.Visible = false
  end
  if nx_int(rule_info[2]) == nx_int(1) then
    form.btn_random.Visible = true
  else
    form.btn_random.Visible = false
  end
  form.rbtn_double.Checked = true
  form.rbtn_single.Checked = true
  form.mltbox_descrip.Visible = false
  form.boy_ini = nil
  form.girl_ini = nil
  local gui = nx_value("gui")
  form.ipt_name.Text = gui.TextManager:GetText(nx_string("ui_norolename"))
  set_search_visible(form, false, -1, -1)
  local game_config = nx_value("game_config")
  if not nx_find_custom(game_config, "login_type") then
    game_config.login_type = "2"
  end
  if game_config.login_type == "2" then
    reset_form_ui(form)
  end
  return 1
end
function on_main_form_close(form)
  if nx_is_valid(form.girl_ini) then
    nx_destroy(form.girl_ini)
  end
  if nx_is_valid(form.boy_ini) then
    nx_destroy(form.boy_ini)
  end
  nx_kill(nx_current(), "vis_name_info")
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_firstname_list", nx_null())
  local first_name_data = get_global_list(FIRST_NAME_DATA)
  nx_destroy(first_name_data)
  nx_set_value(FIRST_NAME_DATA, nil)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(FIRST_NAEM_NEW_INI)
  end
end
function load_firstname_list(form)
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  CheckWords:LoadName(nx_resource_path())
end
function refresh_grid(grid, name_type, col)
  local i = col
  local j = 0
  local pos = 0
  local res = true
  local offset = 7
  if col == 6 then
    offset = 4
  end
  grid.ColWidth = grid.Width / col - offset
  grid.ColCount = col
  while res do
    res, j, i, pos = set_page_info(grid, j, i, name_type, pos)
    if res then
      grid:InsertRow(-1)
      j = j + 1
      pos = pos - 1
    end
  end
end
function set_page_info(grid, row, col, name_type, pos)
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local child_size = CheckWords:GetNameCount(nx_int(name_type))
  local node
  local c = 1
  local r = 1
  local k = 1
  for i = 1, col do
    c = i
    for j = row + 1, row + 4 do
      r = j
      if child_size < pos + k then
        return false, r, c, k + pos
      end
      if j > grid.RowCount then
        grid:InsertRow(-1)
      end
      local name_info = CheckWords:GetNameInfoByIndex(name_type, pos + k - 1)
      if 0 < #name_info then
        grid:SetGridText(j - 1, col - i, nx_widestr(name_info[FIRST_NAME_TEXT]))
        CheckWords:SetNameRow(name_type, pos + k - 1, j - 1)
        CheckWords:SetNameCol(name_type, pos + k - 1, col - i)
        k = k + 1
      end
    end
  end
  return true, r, c, k + pos
end
function on_rbtn_single_checked_changed(btn)
  if not btn.Checked then
    btn.ForeColor = normal_color
    return 1
  end
  btn.ForeColor = select_color
  local form = btn.ParentForm
  local first_name_data = get_global_list(FIRST_NAME_DATA)
  local node = first_name_data:GetChild("single")
  set_search_visible(form, false, -1, -1)
  refresh_grid(form.textgrid_firstname, 1, 6)
  return 1
end
function on_rbtn_double_checked_changed(btn)
  if not btn.Checked then
    btn.ForeColor = normal_color
    return 1
  end
  btn.ForeColor = select_color
  local form = btn.ParentForm
  local first_name_data = get_global_list(FIRST_NAME_DATA)
  local node = first_name_data:GetChild("double")
  set_search_visible(form, false, -1, -1)
  refresh_grid(form.textgrid_firstname, 2, 3)
  return 1
end
function on_textgrid_firstname_lost_capture(grid)
  local form = grid.ParentForm
  nx_kill(nx_current(), "vis_name_info")
  form.mltbox_descrip.Visible = false
end
function vis_name_info(grid)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  local time_count = 0
  while nx_is_valid(form) do
    time_count = time_count + nx_pause(0.1)
    local cursor_x, cursor_y = gui:GetCursorPosition()
    local row, col = grid:InGrid(cursor_x, cursor_y)
    local first_name = grid:GetGridText(row, col)
    if 0 ~= nx_ws_length(nx_widestr(first_name)) then
      local tips_id = get_tips_info(nx_widestr(first_name))
      dis_name_description_tips(form, grid, form.mltbox_descrip, row, col, tips_id)
      set_search_visible(form, true, row, col)
    end
  end
end
function dis_name_description_tips(form, grid, descrip, disp_row, disp_col, description_id)
  local gui = nx_value("gui")
  local col_wide = grid.ColWidth
  local row_height = grid.RowHeight
  descrip:Clear()
  descrip.Visible = true
  init_tip_textbox(descrip)
  descrip:AddHtmlText(nx_widestr(gui.TextManager:GetText(nx_string(description_id))), 0)
  autosize_tip_textbox(descrip, 20, 20, 32, 32, grid, grid.RowSelectIndex, grid.ColSelectIndex)
  descrip.Visible = true
end
function init_tip_textbox(tip_control)
  tip_control:Clear()
  tip_control.Width = 20 + tip_control.TipMaxWidth
  local view_rect = util_split_string(tip_control.ViewRect, ",")
  tip_control.ViewRect = view_rect[1] .. "," .. view_rect[2] .. "," .. tip_control.TipMaxWidth .. "," .. 50
end
function autosize_tip_textbox(tip_control, x, y, width, height, grid, row, col)
  local gui = nx_value("gui")
  tip_control.Width = width + tip_control:GetContentWidth()
  tip_control.Height = height + tip_control:GetContentHeight()
  local pos_x, pos_y = get_pos_grid(grid, row, col)
  local cursor_x, cursor_y = gui:GetCursorPosition()
  tip_control.Left = cursor_x - grid.AbsLeft + 20
  tip_control.Top = cursor_y - grid.AbsTop + 150
  local view_rect = util_split_string(tip_control.ViewRect, ",")
  tip_control.ViewRect = view_rect[1] .. "," .. view_rect[2] .. "," .. tip_control.Width .. "," .. tip_control.Height - 10
end
function give_firstname_into_edit(form)
  local form_create = nx_value("form_stage_create\\form_create")
  if not nx_is_valid(form_create) then
    return
  end
  nx_execute("form_stage_create\\form_create", "do_lead_state", form_create.first_name_edit)
  local text = form_create.first_name_edit.Text
  form_create.first_name_edit.Text = nx_widestr(form.FirstName) .. nx_widestr(text)
  nx_execute("form_stage_create\\form_create", "on_first_name_edit_changed", form_create.first_name_edit)
end
function on_textgrid_firstname_vscroll_changed(grid)
  local form = grid.ParentForm
  set_search_visible(form, false, -1, -1)
end
function on_textgrid_firstname_get_capture(grid)
  nx_execute(nx_current(), "vis_name_info", grid)
end
function on_textgrid_firstname_select_grid(grid, row, col)
  local form = grid.ParentForm
  local first_name = grid:GetGridText(row, col)
  if nx_string(first_name) == nx_string("") then
    return 1
  end
  form.ipt_name.Text = first_name
  set_search_visible(form, false, -1, -1)
  return 1
end
function on_ipt_name_lost_focus(edit)
  if nx_string(edit.Text) == nx_string("") then
    local gui = nx_value("gui")
    edit.Text = gui.TextManager:GetText(nx_string("ui_norolename"))
  end
end
function on_ipt_name_get_focus(edit)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText(nx_string("ui_norolename"))
  if nx_string(edit.Text) == nx_string(text) then
    edit.Text = ""
  end
end
function get_tips_info(name)
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local name_info = CheckWords:GetNameInfoByName(1, nx_widestr(name))
  if 5 <= #name_info then
    return name_info[FIRST_NAME_TIPS]
  end
  name_info = {}
  name_info = CheckWords:GetNameInfoByName(2, nx_widestr(name))
  if 5 <= #name_info then
    return name_info[FIRST_NAME_TIPS]
  end
  return ""
end
function on_btn_random_name_click(btn)
  local name = ""
  if nx_custom(btn, "use_bjk") and nx_int(btn.use_bjk) == nx_int(1) then
    name = firstname_random(9, 1)
  end
  local form = btn.ParentForm
  form.ipt_name.Text = nx_widestr(name) .. nx_widestr(secondname_random(form))
end
function firstname_random(single, double)
  local name_type = math.random(10)
  if single > name_type then
    name_type = 1
  else
    name_type = 2
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local name_count = CheckWords:GetNameCount(nx_int(name_type))
  local all_firstname = {}
  for i = 1, nx_number(name_count) do
    local name_info = CheckWords:GetNameInfoByIndex(name_type, i - 1)
    if 5 <= #name_info then
      for j = 1, nx_number(name_info[FIRST_NAME_RAND]) do
        table.insert(all_firstname, i)
      end
    end
  end
  local count = table.getn(all_firstname)
  if count == 0 then
    local node = child_list[math.random(name_count)]
    local name_info = CheckWords:GetNameInfoByIndex(name_type, math.random(name_count) - 1)
    if 5 <= #name_info then
      return nx_widestr(name_info[FIRST_NAME_TEXT])
    else
      return nx_widestr("")
    end
  end
  local index = math.random(count)
  local name_info = CheckWords:GetNameInfoByIndex(name_type, all_firstname[index] - 1)
  if 5 <= #name_info then
    return nx_widestr(name_info[FIRST_NAME_TEXT])
  else
    return nx_widestr("")
  end
end
function secondname_random(form)
  local ini
  local boy_ini = form.boy_ini
  if not nx_is_valid(boy_ini) then
    boy_ini = nx_create("IniDocument")
    boy_ini.FileName = nx_resource_path() .. "ini\\name\\second_name_boy.ini"
    if not boy_ini:LoadFromFile() then
      nx_destroy(boy_ini)
    end
    form.boy_ini = boy_ini
  end
  local girl_ini = form.girl_ini
  if not nx_is_valid(girl_ini) then
    girl_ini = nx_create("IniDocument")
    girl_ini.FileName = nx_resource_path() .. "ini\\name\\second_name_girl.ini"
    if not girl_ini:LoadFromFile() then
      nx_destroy(girl_ini)
    end
    form.girl_ini = girl_ini
  end
  local form_create = nx_value("form_stage_create\\form_create")
  local sex = nx_int(form_create.sex)
  if nx_int(sex) == nx_int(0) then
    ini = boy_ini
  else
    ini = girl_ini
  end
  local second_name = ini:GetSectionList()
  local nNameCount = nx_int(ini:GetSectionCount())
  local randoms = math.random(nx_number(nNameCount))
  local name = ini:ReadString(nx_string(second_name[randoms]), "SecondName", "")
  return nx_widestr(util_text(name))
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  local len = nx_ws_length(form.ipt_search.Text)
  if len < 1 or 2 < len then
    return 1
  end
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local name_type = 1
  if len == 1 then
    name_type = 1
  elseif len == 2 then
    name_type = 2
  end
  local name_info = CheckWords:GetNameInfoByName(name_type, nx_widestr(form.ipt_search.Text))
  if #name_info < 5 then
    disp_error("@ui_namesearch_error")
    return
  end
  if len == 1 then
    form.rbtn_single.Checked = true
  elseif len == 2 then
    form.rbtn_double.Checked = true
  end
  form.textgrid_firstname:SelectGrid(name_info[FIRST_NAME_ROW], name_info[FIRST_NAME_COL])
  set_search_visible(form, true, name_info[FIRST_NAME_ROW], name_info[FIRST_NAME_COL])
  return 1
end
function set_search_visible(form, vis, row, col)
  if not vis then
    form.lbl_search.Visible = false
    return
  end
  local offset_x = SINGLE_OFFSET_X
  local offset_y = SINGLE_OFFSET_Y
  if form.rbtn_single.Checked then
    offset_x = SINGLE_OFFSET_X
    offset_y = SINGLE_OFFSET_Y
  elseif form.rbtn_double.Checked then
    offset_x = DOUBLE_OFFSET_X
    offset_y = DOUBLE_OFFSET_Y
  end
  local pos_x, pos_y = get_pos_grid(form.textgrid_firstname, row, col)
  form.lbl_search.Left = pos_x + offset_x
  form.lbl_search.Top = pos_y + offset_y
  form.lbl_search.Visible = true
end
function get_pos_grid(grid, row, col)
  local vis_row = grid.VisRow
  local offset_row = row - vis_row
  local pos_x = 0
  for i = 1, col do
    pos_x = pos_x + grid.ColWidth
  end
  local pos_y = grid.RowHeight * offset_row
  return grid.Left + pos_x, grid.Top + pos_y
end
function on_btn_edit_click(self)
  local form = nx_value("form_stage_create\\form_create")
  nx_execute("form_stage_create\\form_create", "back_btn_click", form.back_btn)
  util_auto_show_hide_form("form_stage_create\\form_face_edit", "")
end
function change_create_size(form)
  local gui = nx_value("gui")
  form.Width = gui.Width
  form.Height = gui.Height
end
function set_control_ui(control)
  if not nx_is_valid(control) then
    return
  end
  local out_image = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "out", "")
  local on_image = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "on", "")
  local down_image = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "down", "")
  local left = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "left", "")
  local top = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "top", "")
  local width = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "width", "")
  local height = get_ini_prop(FIRST_NAEM_NEW_INI, control.Name, "height", "")
  if nx_name(control) == "Label" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Button" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.PushImage = down_image
    end
  elseif nx_name(control) == "CheckButton" or nx_name(control) == "RadioButton" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.CheckedImage = down_image
    end
  elseif nx_name(control) == "GroupBox" or nx_name(control) == "GroupScrollableBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Edit" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "MultiTextBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  else
    return
  end
  if left ~= "" and top ~= "" then
    control.Left = nx_number(left)
    control.Top = nx_number(top)
  end
  if width ~= "" and height ~= "" then
    control.Width = nx_number(width)
    control.Height = nx_number(height)
  end
end
function reset_form_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", FIRST_NAEM_NEW_INI)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local control = nx_custom(form, sec_name)
    if nx_is_valid(control) then
      set_control_ui(control)
    end
  end
end
