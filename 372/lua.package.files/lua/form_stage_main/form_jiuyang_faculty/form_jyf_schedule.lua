require("util_functions")
require("util_gui")
require("tips_data")
require("custom_sender")
local FORM_PATH = "form_stage_main\\form_jiuyang_faculty\\form_jyf_schedule"
local INI_FILE = "share\\War\\JiuYangFaculty\\jiuyang_faculty_form.ini"
local DEFAULT_LEFT = 5
local DEFAULT_TOP = 20
local DEFAULT_SPACE = 10
local DEBUG_MODE = false
function main_form_init(self)
  local IniManager = nx_value("IniManager")
  if not DEBUG_MODE then
    if not IniManager:IsIniLoadedToManager(INI_FILE) then
      IniManager:LoadIniToManager(INI_FILE)
    end
  else
    IniManager:UnloadIniFromManager(INI_FILE)
    IniManager:LoadIniToManager(INI_FILE)
  end
  self.Fixed = false
  return 1
end
function open_form()
  util_auto_show_hide_form(FORM_PATH)
end
function show_form(is_show)
  if is_show ~= util_is_form_visible(FORM_PATH) then
    util_auto_show_hide_form(FORM_PATH)
  end
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  self.ani_1.Visible = false
  self.lbl_left_title.alpha_control = "ForeColor"
  self.lbl_left_title.alpha_control2 = "BlendColor"
  open_tab(0)
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(3))
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function open_tab(index)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  radiobtn_lock(form, true)
  reset_effect_data(form.groupbox_left, 90)
  reset_effect_data(form.gsbox_right, 30)
  reset_effect_data(form.gbox_radio_tab, 30)
  form.gsbox_right.last_show_finish_ctrl = -1
  form.gsbox_right.callback_show_finish_func = "show_finish"
  form.btn_apply.alpha_control = "ForeColor"
  form.btn_apply.alpha_control2 = "BlendColor"
  if not is_faculty_scene() then
    form.btn_apply.Enabled = false
    form.btn_apply.Visible = false
  end
  form.gbox_visuallayer.Visible = false
  hide_child_ctrl(form.groupbox_left)
  hide_child_ctrl(form.gsbox_right)
  hide_child_ctrl(form.gbox_radio_tab)
  form.lbl_left_title.ForeColor = "0,101,91,73"
  form.lbl_left_title.BlendColor = "0,255,255,255"
  fill_content(form, index)
  fade_in()
end
function show_finish(index)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  index = index + 1
  local ctrls = form.gsbox_right:GetChildControlList()
  if index > table.getn(ctrls) then
    return
  end
  if not nx_find_custom(ctrls[index], "is_grid") or ctrls[index].is_grid ~= 1 then
    return
  end
  ctrls[index].Visible = true
end
function on_ani_1_animation_end(ani)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  form.ani_1.Visible = false
  fade_in()
end
function reset_effect_data(ctrl, total_frame)
  ctrl.need_frame = total_frame
  ctrl.cur_frame = 0
  ctrl.fade_over = 0
  ctrl.callback_sp = FORM_PATH
  ctrl.callback_func = "fade_over"
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("SequenceFadeIn", ctrl) then
    common_execute:RemoveExecute("SequenceFadeIn", ctrl)
  end
end
function fade_in()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:AddExecute("SequenceFadeIn", form.groupbox_left, nx_float(0))
  common_execute:AddExecute("SequenceFadeIn", form.gsbox_right, nx_float(0))
  common_execute:AddExecute("SequenceFadeIn", form.gbox_radio_tab, nx_float(0))
end
function radiobtn_lock(form, is_lock)
  if nx_is_valid(form) then
    local ctrl_count = form.gbox_radio_tab:GetChildControlList()
    for i = 1, table.getn(ctrl_count) do
      ctrl_count[i].Enabled = not is_lock
    end
  end
end
function hide_child_ctrl(ctrl)
  if not nx_is_valid(ctrl) then
    return
  end
  local ctrl_count = ctrl:GetChildControlList()
  for i = 1, table.getn(ctrl_count) do
    ctrl_count[i].BlendColor = "0,255,255,255"
    ctrl_count[i].ForeColor = "0,255,255,255"
  end
end
function fade_over()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_left.fade_over == 1 and form.gbox_radio_tab.fade_over == 1 then
    radiobtn_lock(form, false)
    form.gbox_visuallayer.Visible = true
    form.btn_apply.Visible = true
  end
end
function show_grid(form)
  if nx_is_valid(form) then
    local ctrls = form.gsbox_right:GetChildControlList()
    for i = 1, table.getn(ctrls) do
      if nx_find_custom(ctrls[i], "is_grid") and ctrls[i].is_grid == 1 then
        ctrls[i].Visible = true
      end
    end
  end
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked == false then
    return
  end
  open_tab(rbtn.DataSource)
end
function reset_schedule(...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local data = nx_widestr("")
  for i = 1, table.getn(arg) do
    data = data .. nx_widestr(arg[i])
    if i ~= table.getn(arg) then
      if i % 4 == 0 then
        data = data .. nx_widestr(";")
      else
        data = data .. nx_widestr(",")
      end
    end
  end
  form.schedule_data = nx_widestr(data)
  reset_schedule_layer(form)
end
function sort_schedule(l, r)
  return nx_int(l.date) < nx_int(r.date)
end
function reset_schedule_layer(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_find_custom(form, "schedule_data") or nx_widestr(form.schedule_data) == nx_widestr("") then
    return
  end
  local text_array = util_split_wstring(nx_widestr(form.schedule_data), ";")
  local len = table.getn(text_array)
  if len == 0 then
    return
  end
  local struct = {}
  for i = 1, len do
    local text_info = util_split_wstring(nx_widestr(text_array[i]), ",")
    local info_len = table.getn(text_info)
    local condition = false
    if DEBUG_MODE then
      condition = 4 <= info_len
    else
      condition = 4 <= info_len and nx_int(text_info[3]) == nx_int(0)
    end
    if nx_int(text_info[1]) ~= nx_int(0) then
      condition = false
    end
    if condition then
      table.insert(struct, {
        server_name = nx_widestr(text_info[1]),
        date = nx_int(text_info[2]),
        is_self_server = nx_int(text_info[4])
      })
    end
  end
  table.sort(struct, sort_schedule)
  form.gbox_container:DeleteAll()
  len = table.getn(struct)
  local cur_group_count = 0
  for i = 1, len do
    local day = nx_int(struct[i].date)
    local gbox_name = nx_string("gbox_day_") .. nx_string(day)
    local has_gbox = nx_find_custom(form, gbox_name)
    local groupbox
    if has_gbox then
      groupbox = nx_custom(form, gbox_name)
    else
      groupbox = gui:Create("GroupBox")
      groupbox.BackColor = "0,255,255,255"
      groupbox.NoFrame = true
      groupbox.Width = 91
      groupbox.Height = 141
      groupbox.Top = 0
      groupbox.Left = cur_group_count * (groupbox.Width + 17)
      groupbox.Name = gbox_name
      groupbox.DrawMode = "FitWindow"
      groupbox.BackImage = "gui\\special\\jiuyangshengong\\jiuyangguize\\bg_2.png"
      form.gbox_container:Add(groupbox)
      nx_set_custom(form, nx_string(groupbox.Name), groupbox)
      local strdate = nx_function("format_date_time", nx_double(day))
      local tdate = nx_widestr(string.sub(strdate, 1, 4)) .. nx_widestr("/") .. nx_widestr(string.sub(strdate, 6, 7)) .. nx_widestr("/") .. nx_widestr(string.sub(strdate, 9, 10))
      local lbl_name = gui:Create("Label")
      lbl_name.NoFrame = true
      lbl_name.ForeColor = "255,96,67,19"
      lbl_name.Font = "font_tip"
      lbl_name.Text = tdate
      lbl_name.Width = groupbox.Width
      lbl_name.Height = 30
      lbl_name.Top = 20
      lbl_name.Align = "Center"
      groupbox:Add(lbl_name)
      cur_group_count = cur_group_count + 1
      form.gbox_container.Width = (nx_int(cur_group_count / 4) + 1) * form.gbox_visuallayer.Width
    end
    local lbl_name = gui:Create("Label")
    lbl_name.NoFrame = true
    lbl_name.ForeColor = "255,255,255,255"
    lbl_name.Font = "font_tip"
    lbl_name.Text = nx_widestr(struct[i].server_name)
    lbl_name.Width = groupbox.Width
    lbl_name.Height = 20
    lbl_name.Align = "Center"
    local ctrls = groupbox:GetChildControlList()
    local ctrl_count = table.getn(ctrls)
    lbl_name.Top = ctrls[ctrl_count].Top + ctrls[ctrl_count].Height
    groupbox:Add(lbl_name)
  end
end
function on_btn_priv_click(button)
  local form = button.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.gbox_container.Left >= 0 then
    return
  end
  local t_x = form.gbox_container.Left + form.gbox_visuallayer.Width
  local t_y = form.gbox_container.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.gbox_container) then
    return
  end
  common_execute:AddExecute("ControlMove", form.gbox_container, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function on_btn_next_click(button)
  local form = button.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if -form.gbox_container.Left >= form.gbox_container.Width - form.gbox_visuallayer.Width then
    return
  end
  local t_x = form.gbox_container.Left - form.gbox_visuallayer.Width
  local t_y = form.gbox_container.Top
  local common_execute = nx_value("common_execute")
  if common_execute:FindExecute("ControlMove", form.gbox_container) then
    return
  end
  common_execute:AddExecute("ControlMove", form.gbox_container, nx_float(0), nx_float(t_x), nx_float(t_y), nx_float(0.3), "")
end
function fill_content(form, index)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if ini == nil then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(index))
  if sec_index < 0 then
    return
  end
  form.gsbox_right.IsEditMode = true
  form.gsbox_right:DeleteAll()
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 1, item_count do
    local key = ini:GetSectionItemKey(sec_index, i - 1)
    local var = ini:GetSectionItemValue(sec_index, i - 1)
    local model_index = ini:FindSectionIndex(nx_string(key))
    if 0 <= model_index then
      local create_type = ini:ReadInteger(model_index, "type", -1)
      if create_type == 0 then
        create_title(form, ini, key, var)
      elseif create_type == 1 then
        create_text(form, ini, key, var)
      elseif create_type == 2 then
        create_item_grid(form, ini, key, var)
      elseif create_type == 3 then
        create_skill_grid(form, ini, key, var)
      end
    end
  end
  form.gsbox_right.IsEditMode = false
  sec_index = ini:FindSectionIndex(nx_string("pic"))
  if sec_index < 0 then
    return
  end
  form.lbl_role_bg.BackImage = ini:ReadString(sec_index, nx_string(index), "")
end
function create_title(form, ini, key, var)
  local gui = nx_value("gui")
  local model_index = ini:FindSectionIndex(nx_string(key))
  if model_index < 0 then
    return
  end
  local height = ini:ReadInteger(model_index, "height", 0)
  local bg = ini:ReadString(model_index, "bg", "")
  local bg_width = ini:ReadInteger(model_index, "bg_width", 0)
  local font = ini:ReadString(model_index, "font", "")
  local color = ini:ReadString(model_index, "color", "")
  if height == 0 or bg == "" or bg_width == 0 or font == "" or color == "" then
    return
  end
  local child_ctrls = form.gsbox_right:GetChildControlList()
  local child_counts = table.getn(child_ctrls)
  local top = DEFAULT_TOP
  if 0 < child_counts then
    top = child_ctrls[child_counts].Top + child_ctrls[child_counts].Height + DEFAULT_SPACE
  end
  local lbl_name = gui:Create("Label")
  lbl_name.NoFrame = true
  lbl_name.ForeColor = "0," .. color
  lbl_name.BlendColor = "0,255,255,255"
  lbl_name.Font = font
  lbl_name.Text = gui.TextManager:GetFormatText(var)
  lbl_name.Width = bg_width
  lbl_name.Height = height
  lbl_name.Align = "Center"
  lbl_name.BackImage = bg
  lbl_name.DrawMode = "FitWindow"
  lbl_name.alpha_control = "ForeColor"
  lbl_name.alpha_control2 = "BlendColor"
  lbl_name.Left = (form.gsbox_right.Width - lbl_name.Width) / 2
  lbl_name.Top = top
  form.gsbox_right:Add(lbl_name)
end
function create_text(form, ini, key, var)
  local gui = nx_value("gui")
  local model_index = ini:FindSectionIndex(nx_string(key))
  if model_index < 0 then
    return
  end
  local height = ini:ReadInteger(model_index, "height", 0)
  local font = ini:ReadString(model_index, "font", "")
  local color = ini:ReadString(model_index, "color", "")
  if height == 0 or font == "" or color == "" then
    return
  end
  local child_ctrls = form.gsbox_right:GetChildControlList()
  local child_counts = table.getn(child_ctrls)
  local top = DEFAULT_TOP
  if 0 < child_counts then
    top = child_ctrls[child_counts].Top + child_ctrls[child_counts].Height + DEFAULT_SPACE
  end
  local lbl_name = gui:Create("Label")
  lbl_name.NoFrame = true
  lbl_name.ForeColor = "0," .. color
  lbl_name.BlendColor = "0,255,255,255"
  lbl_name.Font = font
  lbl_name.Text = gui.TextManager:GetFormatText(var)
  lbl_name.Width = bg_width
  lbl_name.Height = height
  lbl_name.Align = "Left"
  lbl_name.alpha_control = "ForeColor"
  lbl_name.Left = DEFAULT_LEFT + 5
  lbl_name.Top = top
  form.gsbox_right:Add(lbl_name)
end
function create_item_grid(form, ini, key, var)
  local text_array = util_split_string(nx_string(var), ",")
  local len = table.getn(text_array)
  if len == 0 then
    return
  end
  local gui = nx_value("gui")
  local model_index = ini:FindSectionIndex(nx_string(key))
  if model_index < 0 then
    return
  end
  local height = ini:ReadInteger(model_index, "height", 0)
  local width = ini:ReadInteger(model_index, "width", 0)
  if height == 0 or width == 0 then
    return
  end
  local child_ctrls = form.gsbox_right:GetChildControlList()
  local child_counts = table.getn(child_ctrls)
  local top = DEFAULT_TOP
  if 0 < child_counts then
    top = child_ctrls[child_counts].Top + child_ctrls[child_counts].Height + DEFAULT_SPACE
  end
  local grids_pos = ""
  for i = 1, len do
    local x = (i - 1) * 50
    grids_pos = grids_pos .. x .. ",0;"
  end
  local grid = gui:Create("ImageGrid")
  grid.Visible = false
  grid.Top = top
  grid.Left = DEFAULT_LEFT + 25
  grid.Width = 50 * len
  grid.Height = 50
  grid.NoFrame = true
  grid.AutoSize = true
  grid.DrawGridBack = ""
  grid.DrawMode = "Expand"
  grid.GridBackOffsetX = -4
  grid.GridBackOffsetY = -4
  grid.Solid = false
  grid.SelectColor = "0,0,0,0"
  grid.MouseInColor = "0,0,0,0"
  grid.CoverColor = "0,0,0,0"
  grid.LockColor = "0,0,0,0"
  grid.DrawGridBack = "gui\\special\\bag\\kuang.png"
  grid.RowNum = 1
  grid.ClomnNum = len
  grid.ShowEmpty = true
  grid.ShowMouseDownState = false
  grid.Center = false
  grid.GridOffsetX = 0
  grid.GridOffsetY = 0
  grid.GridHeight = 38
  grid.GridWidth = 38
  grid.FitGrid = true
  grid.GridsPos = grids_pos
  grid.is_grid = 1
  grid.DataSource = var
  grid:Clear()
  local vars = util_split_string(var, ",")
  for i = 1, len do
    if nx_string(vars[i]) ~= nx_string("") then
      local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(vars[i]), "Photo")
      grid:AddItem(i - 1, photo, "", 1, -1)
    end
  end
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_mousein_grid", "on_item_grid_mousein")
  nx_callback(grid, "on_mouseout_grid", "on_item_grid_mouseout")
  form.gsbox_right:Add(grid)
end
function create_skill_grid(form, ini, key, var)
  local text_array = util_split_string(nx_string(var), ",")
  local len = table.getn(text_array)
  if len == 0 then
    return
  end
  local gui = nx_value("gui")
  local model_index = ini:FindSectionIndex(nx_string(key))
  if model_index < 0 then
    return
  end
  local height = ini:ReadInteger(model_index, "height", 0)
  local width = ini:ReadInteger(model_index, "width", 0)
  if height == 0 or width == 0 then
    return
  end
  local child_ctrls = form.gsbox_right:GetChildControlList()
  local child_counts = table.getn(child_ctrls)
  local top = DEFAULT_TOP
  if 0 < child_counts then
    top = child_ctrls[child_counts].Top + child_ctrls[child_counts].Height + DEFAULT_SPACE
  end
  local grids_pos = ""
  for i = 1, len do
    local x = (i - 1) * 58
    grids_pos = grids_pos .. x .. ",0;"
  end
  local grid = gui:Create("ImageGrid")
  grid.Visible = false
  grid.Top = top
  grid.Left = DEFAULT_LEFT + 80
  grid.Width = 58 * len - 15
  grid.Height = 50
  grid.NoFrame = true
  grid.AutoSize = true
  grid.DrawGridBack = ""
  grid.DrawMode = "Expand"
  grid.GridBackOffsetX = -4
  grid.GridBackOffsetY = -4
  grid.Solid = false
  grid.SelectColor = "0,0,0,0"
  grid.MouseInColor = "0,0,0,0"
  grid.CoverColor = "0,0,0,0"
  grid.LockColor = "0,0,0,0"
  grid.DrawGridBack = "gui\\special\\bag\\kuang.png"
  grid.RowNum = 1
  grid.ClomnNum = len
  grid.ShowEmpty = true
  grid.ShowMouseDownState = false
  grid.Center = false
  grid.GridOffsetX = 0
  grid.GridOffsetY = 0
  grid.GridHeight = 38
  grid.GridWidth = 38
  grid.FitGrid = true
  grid.GridsPos = grids_pos
  grid.is_grid = 1
  grid.DataSource = var
  grid:Clear()
  local vars = util_split_string(var, ",")
  for i = 1, len do
    if nx_string(vars[i]) ~= nx_string("") then
      local photo = nx_execute("util_static_data", "skill_static_query_by_id", nx_string(vars[i]), "Photo")
      grid:AddItem(i - 1, photo, "", 1, -1)
    end
  end
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_mousein_grid", "on_skill_grid_mousein")
  nx_callback(grid, "on_mouseout_grid", "on_skill_grid_mouseout")
  form.gsbox_right:Add(grid)
end
function on_item_grid_mousein(grid, index)
  local data = grid.DataSource
  local vars = util_split_string(data, ",")
  if index >= table.getn(vars) then
    return
  end
  local config_id = vars[index + 1]
  if config_id == nil or nx_string(config_id) == nx_string("") then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not item_query:FindItemByConfigID(config_id) then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_item_grid_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_skill_grid_mousein(grid, index)
  local data = grid.DataSource
  local vars = util_split_string(data, ",")
  if index >= table.getn(vars) then
    return
  end
  local config_id = vars[index + 1]
  if config_id == nil or nx_string(config_id) == nx_string("") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", config_id, "StaticData", "0")
  item.ConfigID = config_id
  item.ItemType = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", config_id, "ItemType", "0")
  item.StaticData = nx_number(static_id)
  item.is_static = true
  item.Level = 1
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_skill_grid_mouseout(grid)
  nx_execute("tips_game", "hide_tip")
end
function is_faculty_scene()
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return false
  end
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  local gui = nx_value("gui")
  local config_id = scene:QueryProp("Resource")
  return nx_int(map_query:GetSceneId(config_id)) == nx_int(13)
end
function on_btn_apply_click(btn)
  if not is_faculty_scene() then
    return
  end
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(7))
end
function get_scene_id()
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return nx_int(-1)
  end
  local config_id = client_scene:QueryProp("ConfigID")
  local ini = nx_execute("util_functions", "get_ini", "ini\\scenes.ini")
  if not nx_is_valid(ini) then
    return nx_int(-1)
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local id = ini:GetSectionByIndex(i)
    local config = ini:ReadString(i, "Config", "")
    if nx_string(config) == nx_string(config_id) then
      return nx_int(id)
    end
  end
  return nx_int(-1)
end
