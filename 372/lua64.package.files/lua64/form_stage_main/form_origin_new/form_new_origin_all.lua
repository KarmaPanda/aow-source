require("util_functions")
require("util_gui")
require("form_stage_main\\form_origin_new\\new_origin_define")
local CHAPTER_ORIGIN_PAGE_NUM = 4
local ORIGIN_GROUPBOX_LINE_MAX_NUM = 4
local TIME_LIMIT_ORIGIN_CONTROL_SPACE = 24
local TIME_LIMIT_ORIGIN_ROWS = 2
local new_type_origin_table = {}
local WUJIDAO_MAG_DATA_COUNT = 12
local MIN_WUJI_ISLAND_CAMP_VALUE = -10000
local MAX_WUJI_ISLAND_CAMP_VALUE = 10000
function refresh_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NEW_ORIGIN_ALL, false, false)
  if not nx_is_valid(form) then
    return
  end
  show_chapters(form)
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  local groupbox_name = "groupbox_name_"
  local groupbox_name_origin = form:Find(groupbox_name)
  if not nx_is_valid(groupbox_name_origin) then
    return
  end
  groupbox_name_origin.Visible = false
  show_chapters(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  table_clear(new_type_origin_table)
  form.Visible = false
  local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
  if nx_is_valid(mainform) then
    nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_MAIN)
  end
end
function close_form()
  local form = nx_value(FORM_NEW_ORIGIN_ALL)
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_chapters(form)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local new_origin_chapter = {}
  new_origin_chapter = origin_manager:GetNewSubTypeList(form.main_type)
  if table.getn(new_origin_chapter) < 2 then
    return
  end
  form.wu_ji_dao_para = new_origin_chapter[1]
  form.time_limit_type = new_origin_chapter[2]
  form.chapter_main_id = new_origin_chapter[3]
  get_new_origin_data(form.chapter_id)
  if form.chapter_id == form.chapter_main_id then
    show_origin_pandect_line(form)
  elseif form.chapter_id == form.time_limit_type then
    show_time_limit_origin(form)
  elseif form.chapter_id == form.wu_ji_dao_para then
    request_wu_ji_dao_para()
  else
    show_origin_chapter_line_all(form)
  end
end
function get_new_origin_data(chapter_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local origin_line_num = origin_manager:GetSubTypeLines(chapter_id)
  table_clear(new_type_origin_table)
  for i = 1, origin_line_num do
    local new_origin_data = {}
    new_origin_data = origin_manager:GetNewTypeOriginList(chapter_id, i)
    table.insert(new_type_origin_table, new_origin_data)
  end
end
function show_origin_pandect_line(form)
  local groupbox_origin = form.groupbox_6
  if not nx_is_valid(groupbox_origin) then
    return
  end
  form.groupbox_6.Visible = true
  form.groupbox_5.Visible = false
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_wjd.Visible = false
  local btn_list = form.groupbox_6:GetChildControlList()
  for n = 1, table.getn(btn_list) do
    local control = btn_list[n]
    control.Visible = false
    control.Enabled = false
  end
  form.lbl_1.Visible = true
  local origin_line_num = table.getn(new_type_origin_table)
  for i = 1, origin_line_num do
    local new_origin_data = {}
    new_origin_data = new_type_origin_table[i]
    local rows = table.getn(new_origin_data)
    for j = 1, rows do
      local btn_name = "btn_" .. nx_string(i) .. "_" .. nx_string(j)
      local lbl_name = "lbl_" .. nx_string(i) .. "_" .. nx_string(j)
      local btn_origin = groupbox_origin:Find(btn_name)
      if not nx_is_valid(btn_origin) then
        return
      end
      local lbl_origin = groupbox_origin:Find(lbl_name)
      if not nx_is_valid(lbl_origin) then
        return
      end
      if 0 < new_origin_data[j] then
        btn_origin.Visible = true
        btn_origin.Enabled = true
        btn_origin.origin_id = new_origin_data[j]
        lbl_origin.Visible = true
        lbl_origin.Enabled = true
        set_new_origin_photo(btn_origin, lbl_origin)
        nx_bind_script(btn_origin, nx_current())
        nx_callback(btn_origin, "on_click", "on_btn_show_origin_data")
      end
    end
  end
end
function show_origin_chapter_line_all(form)
  local groupbox_origin = form.groupbox_5
  if not nx_is_valid(groupbox_origin) then
    return
  end
  form.groupbox_6.Visible = false
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_wjd.Visible = false
  form.groupbox_5.Visible = true
  local origin_line_num = table.getn(new_type_origin_table)
  if origin_line_num > ORIGIN_GROUPBOX_LINE_MAX_NUM then
    return
  end
  for i = 1, origin_line_num do
    show_origin_chapter_line(i, 1)
    page_btn_init(i)
  end
  for j = origin_line_num + 1, ORIGIN_GROUPBOX_LINE_MAX_NUM do
    local groupbox_name = "groupbox_line_" .. nx_string(j)
    local groupbox_line = groupbox_origin:Find(groupbox_name)
    if not nx_is_valid(groupbox_line) then
      return
    end
    groupbox_line.Visible = false
  end
end
function show_origin_chapter_line(line, page)
  local form = nx_value(FORM_NEW_ORIGIN_ALL)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_origin = form.groupbox_5
  if not nx_is_valid(groupbox_origin) then
    return
  end
  if line > table.getn(new_type_origin_table) then
    return
  end
  local groupbox_name = "groupbox_line_" .. nx_string(line)
  local groupbox_line = groupbox_origin:Find(groupbox_name)
  if not nx_is_valid(groupbox_line) then
    return
  end
  groupbox_line.Visible = true
  local new_origin_data = {}
  new_origin_data = new_type_origin_table[line]
  local row_bengin = (page - 1) * CHAPTER_ORIGIN_PAGE_NUM + 1
  local row_end = page * CHAPTER_ORIGIN_PAGE_NUM
  if row_bengin > table.getn(new_origin_data) then
    return
  end
  if row_end > table.getn(new_origin_data) then
    local bengin = CHAPTER_ORIGIN_PAGE_NUM - (row_end - table.getn(new_origin_data)) + 1
    for i = bengin, CHAPTER_ORIGIN_PAGE_NUM do
      local btn_name = "btn_line_" .. nx_string(line) .. "_" .. nx_string(i)
      local lbl_name = "lbl_line_" .. nx_string(line) .. "_" .. nx_string(i)
      local lbl_get_origin_name = "lbl_get_origin_effect_" .. nx_string(line) .. "_" .. nx_string(i)
      local lbl_active_origin_name = "lbl_active_origin_effect_" .. nx_string(line) .. "_" .. nx_string(i)
      local btn_origin = groupbox_line:Find(btn_name)
      if nx_is_valid(btn_origin) then
        btn_origin.Visible = false
      end
      local lbl_origin = groupbox_line:Find(lbl_name)
      if nx_is_valid(lbl_origin) then
        lbl_origin.Visible = false
      end
      local lbl_get_origin = groupbox_line:Find(lbl_get_origin_name)
      if nx_is_valid(lbl_get_origin) then
        lbl_get_origin.Visible = false
      end
      local lbl_active_origin = groupbox_line:Find(lbl_active_origin_name)
      if nx_is_valid(lbl_active_origin) then
        lbl_active_origin.Visible = false
      end
    end
    row_end = table.getn(new_origin_data)
  end
  local btn_index = 1
  for j = row_bengin, row_end do
    local btn_name = "btn_line_" .. nx_string(line) .. "_" .. nx_string(btn_index)
    local lbl_name = "lbl_line_" .. nx_string(line) .. "_" .. nx_string(btn_index)
    local lbl_get_origin_name = "lbl_get_origin_effect_" .. nx_string(line) .. "_" .. nx_string(btn_index)
    local lbl_active_origin_name = "lbl_active_origin_effect_" .. nx_string(line) .. "_" .. nx_string(btn_index)
    local btn_origin = groupbox_line:Find(btn_name)
    if not nx_is_valid(btn_origin) then
      return
    end
    local lbl_origin = groupbox_line:Find(lbl_name)
    if not nx_is_valid(lbl_origin) then
      return
    end
    local lbl_get_origin = groupbox_line:Find(lbl_get_origin_name)
    if not nx_is_valid(lbl_get_origin) then
      return
    end
    local lbl_active_origin = groupbox_line:Find(lbl_active_origin_name)
    if not nx_is_valid(lbl_active_origin) then
      return
    end
    lbl_get_origin.Visible = false
    lbl_active_origin.Visible = false
    btn_origin.Visible = true
    lbl_origin.Visible = true
    btn_origin.origin_id = new_origin_data[j]
    set_new_origin_photo(btn_origin, lbl_origin, lbl_get_origin, lbl_active_origin)
    nx_bind_script(btn_origin, nx_current())
    nx_callback(btn_origin, "on_click", "on_btn_show_origin_data")
    btn_index = btn_index + 1
  end
end
function page_btn_init(line)
  local form = nx_value(FORM_NEW_ORIGIN_ALL)
  if not nx_is_valid(form) then
    return
  end
  if line > table.getn(new_type_origin_table) then
    return
  end
  local new_origin_data = {}
  new_origin_data = new_type_origin_table[line]
  local groupbox_origin = form.groupbox_5
  local groupbox_name = "groupbox_line_" .. nx_string(line)
  local groupbox_line = groupbox_origin:Find(groupbox_name)
  if not nx_is_valid(groupbox_line) then
    return
  end
  local btn_left_pag_name = "btn_left_" .. nx_string(line)
  local btn_right_pag_name = "btn_right_" .. nx_string(line)
  local lbl_origin_level = "lbl_line_" .. nx_string(line)
  local btn_page = groupbox_line:Find(btn_left_pag_name)
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.Visible = true
  btn_page.Enabled = false
  btn_page.line = line
  btn_page.page = 1
  btn_page.max_page = math.ceil(table.getn(new_origin_data) / CHAPTER_ORIGIN_PAGE_NUM)
  nx_bind_script(btn_page, nx_current())
  nx_callback(btn_page, "on_click", "on_btn_left_page_click")
  btn_page = groupbox_line:Find(btn_right_pag_name)
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.Visible = true
  btn_page.line = line
  btn_page.page = 1
  btn_page.max_page = math.ceil(table.getn(new_origin_data) / CHAPTER_ORIGIN_PAGE_NUM)
  if btn_page.page >= btn_page.max_page then
    btn_page.Enabled = false
  else
    btn_page.Enabled = true
  end
  nx_bind_script(btn_page, nx_current())
  nx_callback(btn_page, "on_click", "on_btn_right_page_click")
  local lbl_level = groupbox_line:Find(lbl_origin_level)
  if not nx_is_valid(lbl_level) then
    return
  end
  lbl_level.Visible = true
  lbl_level.Text = nx_widestr(util_text("ui_SubtypeList_" .. nx_string(form.chapter_id) .. "_" .. nx_string(line)))
end
function on_btn_left_page_click(btn)
  if btn.page <= 1 then
    return
  end
  btn.page = btn.page - 1
  page_btn_atate(btn.page, btn.line)
  show_origin_chapter_line(btn.line, btn.page)
end
function on_btn_right_page_click(btn)
  if btn.page >= btn.max_page then
    return
  end
  btn.page = btn.page + 1
  page_btn_atate(btn.page, btn.line)
  show_origin_chapter_line(btn.line, btn.page)
end
function page_btn_atate(page, line)
  local form = nx_value(FORM_NEW_ORIGIN_ALL)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_origin = form.groupbox_5
  if not nx_is_valid(groupbox_origin) then
    return
  end
  local groupbox_name = "groupbox_line_" .. nx_string(line)
  local groupbox_line = groupbox_origin:Find(groupbox_name)
  if not nx_is_valid(groupbox_line) then
    return
  end
  local btn_left_pag_name = "btn_left_" .. nx_string(line)
  local btn_right_pag_name = "btn_right_" .. nx_string(line)
  local btn_page = groupbox_line:Find(btn_left_pag_name)
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.page = page
  if btn_page.page <= 1 then
    btn_page.Enabled = false
  else
    btn_page.Enabled = true
  end
  btn_page = groupbox_line:Find(btn_right_pag_name)
  if not nx_is_valid(btn_page) then
    return
  end
  btn_page.page = page
  if btn_page.page >= btn_page.max_page then
    btn_page.Enabled = false
  else
    btn_page.Enabled = true
  end
end
function on_btn_show_origin_data(btn)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if origin_manager:IsActiveOrigin(btn.origin_id) then
    form.Visible = false
    local mainform = nx_value(FORM_NEW_ORIGIN_MAIN)
    if nx_is_valid(mainform) then
      mainform.return_form_type = FORM_TYPE_SUB
      nx_execute(FORM_NEW_ORIGIN_MAIN, "open_subform", mainform, FORM_TYPE_ORIGIN_INFO, btn.origin_id, "")
    end
  end
end
function set_new_origin_photo(btn, lbl, lbl_get_origin, lbl_active_origin)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local new_origin_data = {}
  new_origin_data = origin_manager:GetOriginInfo(btn.origin_id)
  if table.getn(new_origin_data) < ORIGIN_INFO_GET_PHOTO then
    return
  end
  if origin_manager:IsCompletedOrigin(btn.origin_id) then
    btn.NormalImage = new_origin_data[ORIGIN_INFO_GET_PHOTO]
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr(gui.TextManager:GetText("ui_origin_yhd"))
      lbl.ForeColor = "255,255,128,0"
    end
  elseif origin_manager:IsActiveOrigin(btn.origin_id) then
    btn.NormalImage = new_origin_data[ORIGIN_INFO_ACTIVE_PHOTO]
    local condition_manager = nx_value("ConditionManager")
    if not nx_is_valid(condition_manager) then
      return
    end
    local game_client = nx_value("game_client")
    local player = game_client:GetPlayer()
    if not nx_is_valid(player) then
      return
    end
    local can_get_origin = nx_execute(FORM_NEW_ORIGIN_DESC, "can_get_origin", player, condition_manager, origin_manager, btn.origin_id)
    if nx_is_valid(lbl) then
      if can_get_origin then
        lbl.Text = nx_widestr(gui.TextManager:GetText("ui_origin_khd"))
        lbl.ForeColor = "255,0,219,0"
      else
        lbl.Text = nx_widestr(gui.TextManager:GetText("ui_origin_ktz"))
        lbl.ForeColor = "255,255,0,0"
      end
    end
    local is_new = nx_execute("form_stage_main\\form_main\\form_main_shortcut", "is_new_active_origin", btn.origin_id)
    if is_new and nx_is_valid(lbl_get_origin) then
      lbl_active_origin.Visible = true
      nx_execute("form_stage_main\\form_main\\form_main_shortcut", "del_new_active_origin", btn.origin_id)
      return
    end
    if can_get_origin and nx_is_valid(lbl_get_origin) then
      lbl_get_origin.Visible = true
    end
  else
    btn.NormalImage = new_origin_data[ORIGIN_INFO_UNACTIVE_PHOTO]
    if nx_is_valid(lbl) then
      lbl.Text = nx_widestr(gui.TextManager:GetText("ui_origin_wjh"))
      lbl.ForeColor = "255,204,204,204"
    end
  end
end
function table_clear(t)
  for i = 1, table.getn(t) do
    table.remove(t)
  end
  t = {}
end
function clone_control(control, index)
  local entity_name = nx_name(control)
  if string.len(entity_name) == 0 then
    return nil
  end
  local gui = nx_value("gui")
  local new_control = gui:Create(entity_name)
  new_control.Name = nx_string(control.Name) .. nx_string(index)
  new_control.Top = control.Top
  new_control.Left = control.Left
  new_control.Height = control.Height
  new_control.Width = control.Width
  new_control.VAnchor = control.VAnchor
  new_control.HAnchor = control.HAnchor
  new_control.NoFrame = control.NoFrame
  new_control.DrawMode = control.DrawMode
  new_control.BackImage = control.BackImage
  new_control.AutoSize = control.AutoSize
  new_control.Text = control.Text
  new_control.Font = control.Font
  new_control.ForeColor = control.ForeColor
  new_control.BackColor = control.BackColor
  new_control.BlendColor = control.BlendColor
  new_control.LineColor = control.LineColor
  if entity_name == "Button" then
    new_control.NormalImage = control.NormalImage
    new_control.FocusImage = control.FocusImage
    new_control.PushImage = control.PushImage
    new_control.DisableImage = control.DisableImage
  elseif entity_name == "Label" then
  elseif entity_name == "GroupBox" then
    local control_list = control:GetChildControlList()
    local control_count = table.getn(control_list)
    for i = 1, control_count do
      local new_child = clone_control(control_list[i], index)
      if nx_is_valid(new_child) then
        new_control:Add(new_child)
      end
    end
  end
  return new_control
end
function show_event_origin(form)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local groupbox_origin = form.groupbox_5
  if not nx_is_valid(groupbox_origin) then
    return
  end
  form.groupbox_6.Visible = false
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_wjd.Visible = false
  form.groupbox_5.Visible = true
  local new_origin_events_sort = {}
  new_origin_events_sort = origin_manager:OriginCompletedEventsSort()
  local length = table.getn(new_origin_events_sort)
  if length < 0 then
    return
  end
  local origin_line_num = math.ceil(length / CHAPTER_ORIGIN_PAGE_NUM)
  if origin_line_num > ORIGIN_GROUPBOX_LINE_MAX_NUM then
    origin_line_num = ORIGIN_GROUPBOX_LINE_MAX_NUM
  end
  for jj = origin_line_num + 1, ORIGIN_GROUPBOX_LINE_MAX_NUM do
    local groupbox_name = "groupbox_line_" .. nx_string(jj)
    local groupbox_line = groupbox_origin:Find(groupbox_name)
    if not nx_is_valid(groupbox_line) then
      return
    end
    groupbox_line.Visible = false
  end
  for line = 1, origin_line_num do
    local groupbox_name = "groupbox_line_" .. nx_string(line)
    local groupbox_line = groupbox_origin:Find(groupbox_name)
    if not nx_is_valid(groupbox_line) then
      return
    end
    groupbox_line.Visible = true
    local row_bengin = (line - 1) * CHAPTER_ORIGIN_PAGE_NUM + 1
    local row_end = line * CHAPTER_ORIGIN_PAGE_NUM
    if length < row_bengin then
      return
    end
    if length < row_end then
      local bengin = length - row_bengin + 1 + 1
      for i = bengin, CHAPTER_ORIGIN_PAGE_NUM do
        local btn_name = "btn_line_" .. nx_string(line) .. "_" .. nx_string(i)
        local lbl_name = "lbl_line_" .. nx_string(line) .. "_" .. nx_string(i)
        local lbl_get_origin_name = "lbl_get_origin_effect_" .. nx_string(line) .. "_" .. nx_string(i)
        local lbl_active_origin_name = "lbl_active_origin_effect_" .. nx_string(line) .. "_" .. nx_string(i)
        local btn_origin = groupbox_line:Find(btn_name)
        if nx_is_valid(btn_origin) then
          btn_origin.Visible = false
        end
        local lbl_origin = groupbox_line:Find(lbl_name)
        if nx_is_valid(lbl_origin) then
          lbl_origin.Visible = false
        end
        local lbl_get_origin = groupbox_line:Find(lbl_get_origin_name)
        if nx_is_valid(lbl_get_origin) then
          lbl_get_origin.Visible = false
        end
        local lbl_active_origin = groupbox_line:Find(lbl_active_origin_name)
        if nx_is_valid(lbl_active_origin) then
          lbl_active_origin.Visible = false
        end
      end
      row_end = length
    end
    local btn_index = 1
    for j = row_bengin, row_end do
      local btn_name = "btn_line_" .. nx_string(line) .. "_" .. nx_string(btn_index)
      local lbl_name = "lbl_line_" .. nx_string(line) .. "_" .. nx_string(btn_index)
      local lbl_get_origin_name = "lbl_get_origin_effect_" .. nx_string(line) .. "_" .. nx_string(btn_index)
      local lbl_active_origin_name = "lbl_active_origin_effect_" .. nx_string(line) .. "_" .. nx_string(btn_index)
      local btn_origin = groupbox_line:Find(btn_name)
      if not nx_is_valid(btn_origin) then
        return
      end
      local lbl_origin = groupbox_line:Find(lbl_name)
      if not nx_is_valid(lbl_origin) then
        return
      end
      local lbl_get_origin = groupbox_line:Find(lbl_get_origin_name)
      if not nx_is_valid(lbl_get_origin) then
        return
      end
      local lbl_active_origin = groupbox_line:Find(lbl_active_origin_name)
      if not nx_is_valid(lbl_active_origin) then
        return
      end
      lbl_get_origin.Visible = false
      lbl_active_origin.Visible = false
      btn_origin.Visible = true
      lbl_origin.Visible = true
      btn_origin.origin_id = new_origin_events_sort[j]
      set_new_origin_photo(btn_origin, lbl_origin, lbl_get_origin, lbl_active_origin)
      nx_bind_script(btn_origin, nx_current())
      nx_callback(btn_origin, "on_click", "on_btn_show_origin_data")
      btn_index = btn_index + 1
    end
    local btn_left_pag_name = "btn_left_" .. nx_string(line)
    local btn_right_pag_name = "btn_right_" .. nx_string(line)
    local lbl_origin_level = "lbl_line_" .. nx_string(line)
    local btn_page_left = groupbox_line:Find(btn_left_pag_name)
    if not nx_is_valid(btn_page_left) then
      return
    end
    local btn_page_right = groupbox_line:Find(btn_right_pag_name)
    if not nx_is_valid(btn_page_right) then
      return
    end
    local lbl_level = groupbox_line:Find(lbl_origin_level)
    if not nx_is_valid(lbl_level) then
      return
    end
    btn_page_left.Visible = false
    btn_page_right.Visible = false
    lbl_level.Visible = false
  end
end
function show_time_limit_origin(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local groupbox_origin = form.groupscrollbox_1
  if not nx_is_valid(groupbox_origin) then
    return
  end
  form.groupbox_6.Visible = false
  form.groupbox_5.Visible = false
  form.groupscrollbox_wjd.Visible = false
  groupbox_origin.Visible = true
  groupbox_origin.IsEditMode = true
  groupbox_origin:DeleteAll()
  local groupbox_name = "groupbox_name_"
  local groupbox_name_origin = form:Find(groupbox_name)
  if not nx_is_valid(groupbox_name_origin) then
    return
  end
  local origin_line_num = table.getn(new_type_origin_table)
  for i = 1, origin_line_num do
    local new_origin_data = {}
    new_origin_data = new_type_origin_table[i]
    local rows = table.getn(new_origin_data)
    local control_top = groupbox_origin.Top + (groupbox_name_origin.Height + TIME_LIMIT_ORIGIN_CONTROL_SPACE) * (i - 1)
    local control_left = groupbox_origin.Left + TIME_LIMIT_ORIGIN_CONTROL_SPACE
    local lbl = gui:Create("Label")
    lbl.BackImage = "gui\\language\\ChineseS\\origin_new\\bg_10.png"
    lbl.Visible = true
    lbl.Top = control_top
    lbl.Left = groupbox_origin.Left + 3
    lbl.Height = groupbox_name_origin.Height + TIME_LIMIT_ORIGIN_CONTROL_SPACE
    lbl.Width = groupbox_origin.Width
    groupbox_origin:Add(lbl)
    for j = 1, rows do
      local index = (i - 1) * TIME_LIMIT_ORIGIN_ROWS + j
      local new_child = clone_control(groupbox_name_origin, index)
      if not nx_is_valid(new_child) then
        return
      end
      local new_control_list = new_child:GetChildControlList()
      for n = 1, table.getn(new_control_list) do
        local control = new_control_list[n]
        control.Visible = false
        control.Enabled = false
      end
      groupbox_origin:Add(new_child)
      new_child.Top = control_top
      new_child.Left = control_left
      if j % 2 == 0 then
        new_child.Left = new_child.Left + groupbox_name_origin.Width + TIME_LIMIT_ORIGIN_CONTROL_SPACE
      end
      local btn_origin_name = "btn_name_" .. nx_string(index)
      local btn_origin = new_child:Find(btn_origin_name)
      if not nx_is_valid(btn_origin) then
        return
      end
      if 0 < new_origin_data[j] then
        btn_origin.Visible = true
        btn_origin.origin_id = new_origin_data[j]
        local new_data = {}
        new_data = origin_manager:GetOriginInfo(btn_origin.origin_id)
        if table.getn(new_data) >= ORIGIN_INFO_GET_PHOTO then
          btn_origin.NormalImage = new_data[ORIGIN_INFO_GET_PHOTO]
        end
        request_time_limit_data(btn_origin.origin_id, index)
      end
    end
  end
  groupbox_origin.IsEditMode = false
end
function show_time_limit_person_name(...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_origin_new\\form_new_origin_all")
  if not nx_is_valid(form) then
    return
  end
  local groupbox_origin = form.groupscrollbox_1
  if not nx_is_valid(groupbox_origin) then
    return
  end
  if not groupbox_origin.Visible then
    return
  end
  local count = table.getn(arg)
  if count < 1 then
    return
  end
  local index = arg[1]
  local groupbox_name = "groupbox_name_" .. nx_string(index)
  local groupbox_name_origin = groupbox_origin:Find(groupbox_name)
  if not nx_is_valid(groupbox_name_origin) then
    return
  end
  if count < 2 then
    local lbl_name = "lbl_name_" .. nx_string(1) .. "_" .. nx_string(index)
    local lbl_name_origin = groupbox_name_origin:Find(lbl_name)
    if nx_is_valid(lbl_name_origin) then
      lbl_name_origin.Visible = true
      lbl_name_origin.Text = nx_widestr(gui.TextManager:GetText("ui_origin_tlnull"))
    end
  end
  for i = 2, count do
    local lbl_name = "lbl_name_" .. nx_string(i - 1) .. "_" .. nx_string(index)
    local lbl_name_origin = groupbox_name_origin:Find(lbl_name)
    if nx_is_valid(lbl_name_origin) then
      lbl_name_origin.Visible = true
      lbl_name_origin.Text = nx_widestr(arg[i])
    end
  end
end
function request_time_limit_data(origin_id, index)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ORIGIN), nx_int(SUB_CUSTOMMSG_REQUEST_ORIGIN_OVER_DATA), origin_id, index)
end
function request_wu_ji_dao_para()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ORIGIN), nx_int(SUB_CUSTOMMSG_REQUEST_ORIGIN_WUJIDAO_PARA))
end
function show_wu_ji_dao_para(...)
  local form = nx_value("form_stage_main\\form_origin_new\\form_new_origin_all")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if nx_int(size) ~= nx_int(WUJIDAO_MAG_DATA_COUNT) then
    return
  end
  form.groupbox_6.Visible = false
  form.groupbox_5.Visible = false
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_wjd.Visible = true
  local ming_contribution_value = arg[1]
  local dongying_contribution_value = arg[2]
  local wujidao_camp_value = arg[3]
  form.lbl_damingvalue.Text = nx_widestr(ming_contribution_value)
  form.lbl_dongyingvalue.Text = nx_widestr(dongying_contribution_value)
  form.lbl_daming.Font = "font_title"
  form.lbl_dongying.Font = "font_title"
  if nx_int(wujidao_camp_value) > nx_int(0) then
    form.lbl_dongying.Font = "font_title2"
  elseif nx_int(wujidao_camp_value) < nx_int(0) then
    form.lbl_daming.Font = "font_title2"
  end
  form.pbar_camp.Maximum = MAX_WUJI_ISLAND_CAMP_VALUE + math.abs(MIN_WUJI_ISLAND_CAMP_VALUE)
  form.pbar_camp.Minimum = 0
  form.pbar_camp.Value = form.pbar_camp.Maximum - (wujidao_camp_value + MAX_WUJI_ISLAND_CAMP_VALUE)
  form.lbl_wjd_700.Text = nx_widestr(arg[4])
  form.lbl_wjd_701.Text = nx_widestr(arg[5])
  form.lbl_wjd_702.Text = nx_widestr(arg[6])
  form.lbl_wjd_703.Text = nx_widestr(arg[7])
  form.lbl_wjd_704.Text = nx_widestr(arg[8])
  form.lbl_wjd_705.Text = nx_widestr(arg[9])
  form.lbl_wjd_706.Text = nx_widestr(arg[10])
  form.lbl_wjd_707.Text = nx_widestr(arg[11])
  form.lbl_wjd_708.Text = nx_widestr(arg[12])
end
