require("util_gui")
require("util_functions")
require("form_stage_main\\form_tvt\\define")
local form_tvt_main = "form_stage_main\\form_tvt\\form_tvt_main"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
local function set_ent_property(ent, name)
  local create_info = get_global_list("tvt_recommend")
  local node = create_info:GetChild(name)
  if not nx_is_valid(node) then
    return
  end
  local custom_list = nx_custom_list(node)
  for i, custom in ipairs(custom_list) do
    local value = nx_property(ent, custom)
    local custom_type = nx_type(value)
    if "number" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_number(nx_custom(node, custom)))
    elseif "string" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_custom(node, custom))
    elseif "boolean" == nx_string(custom_type) then
      nx_set_property(ent, custom, nx_boolean(nx_custom(node, custom)))
    end
  end
end
local function load_create_info(ini_name)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. ini_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local create_info_list = get_new_global_list("tvt_recommend")
  local info_list = ini:GetSectionList()
  for i, info in ipairs(info_list) do
    local node = create_info_list:CreateChild(info)
    local prop_list = ini:GetItemList(info)
    for j, prop in ipairs(prop_list) do
      local value = ini:ReadString(info, prop, "")
      nx_set_custom(node, prop, value)
    end
  end
  nx_destroy(ini)
end
function on_main_form_init(self)
end
function on_main_form_open(self)
  self.Fixed = false
  local gui = nx_value("gui")
  gui.Desktop:ToFront(self)
  self.lbl_select.Visible = false
end
function refresh_form(form)
  load_create_info("ini\\form\\recommend_ini.ini")
  load_recommend_ini(form)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function load_recommend_ini(form)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. "ini\\func_info.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return false
  end
  local sect_list = ini:GetSectionList()
  form.groupscrollbox_main:DeleteAll()
  for i, sect in ipairs(sect_list) do
    create_element_grid(form.groupscrollbox_main, ini, sect)
  end
  local child_control_list = form.groupscrollbox_main:GetChildControlList()
  local child_control_count = table.getn(child_control_list)
  local template_grid = form.groupbox_template
  form.scroll_bar_info.Maximum = (template_grid.Height + 0) * (child_control_count - 3)
  form.lbl_select.Width = template_grid.Width
  form.lbl_select.Height = template_grid.Height
  set_grid_power(form)
  nx_destroy(ini)
end
function create_element_grid(group_scrollable_box, ini, sect)
  local power = ini:ReadInteger(sect, "power", -1)
  if nx_int(0) == nx_int(power) then
    return
  end
  if nx_int(0) > nx_int(power) and nx_int(-1) ~= nx_int(power) then
    return
  end
  local gui = nx_value("gui")
  local form = group_scrollable_box.ParentForm
  local child_control_list = group_scrollable_box:GetChildControlList()
  local child_control_count = table.getn(child_control_list)
  local grid = gui:Create("GroupBox")
  grid.Name = "grid_" .. nx_string(child_control_count)
  local bg_image = gui:Create("Label")
  bg_image.Name = "image_" .. nx_string(child_control_count)
  local lbl_image = gui:Create("Label")
  lbl_image.Name = "image_" .. nx_string(child_control_count)
  local lbl_title = gui:Create("Label")
  lbl_title.Name = "title_" .. nx_string(child_control_count)
  local multi_desc = gui:Create("MultiTextBox")
  multi_desc.Name = "desc_" .. nx_string(child_control_count)
  local multi_award = gui:Create("MultiTextBox")
  multi_award.Name = "award_" .. nx_string(child_control_count)
  local multi_recommend = gui:Create("MultiTextBox")
  multi_recommend.Name = "recommend_" .. nx_string(child_control_count)
  local multi_info = gui:Create("MultiTextBox")
  multi_info.Name = "info_" .. nx_string(child_control_count)
  local lbl_bg = gui:Create("Label")
  lbl_bg.Name = "bg_" .. nx_string(child_control_count)
  grid:Add(lbl_bg)
  grid:Add(bg_image)
  grid:Add(lbl_image)
  grid:Add(lbl_title)
  grid:Add(multi_desc)
  grid:Add(multi_award)
  grid:Add(multi_recommend)
  grid:Add(multi_info)
  if not group_scrollable_box:Add(grid) then
    return
  end
  nx_set_custom(form, grid.Name, grid)
  nx_set_custom(grid, multi_info.Name, multi_info)
  nx_set_custom(grid, multi_recommend.Name, multi_recommend)
  set_copy_ent_info(form, "groupbox_template", grid)
  set_copy_ent_info(form, "bg_image", bg_image)
  set_copy_ent_info(form, "lbl_bg", lbl_bg)
  set_copy_ent_info(form, "lbl_image", lbl_image)
  set_copy_ent_info(form, "mltbox_desc", multi_desc)
  set_copy_ent_info(form, "mltbox_award", multi_award)
  set_copy_ent_info(form, "lbl_title", lbl_title)
  set_copy_ent_info(form, "mltbox_recommend", multi_recommend)
  set_copy_ent_info(form, "mltbox_info", multi_info)
  lbl_image.BackImage = ini:ReadString(sect, "photo", "")
  lbl_title.Text = nx_widestr("@" .. ini:ReadString(sect, "title", ""))
  local level = ini:ReadString(sect, "level", "")
  local value = ini:ReadString(sect, "desc", "")
  multi_desc.HtmlText = gui.TextManager:GetText(value)
  value = ini:ReadString(sect, "award", "")
  multi_award.HtmlText = gui.TextManager:GetText(value)
  value = ini:ReadString(sect, "recommend", "")
  multi_recommend.HtmlText = gui.TextManager:GetText(value)
  value = ini:ReadInteger(sect, "type", -1)
  grid.type_info = nx_int(value)
  grid.Top = child_control_count * grid.Height + 4
  grid.Left = 8
  grid.power = power
  grid.normal_pos = nx_number(grid.Top)
  nx_bind_script(grid, nx_current())
  nx_callback(grid, "on_get_capture", "on_groupbox_get_capture")
  set_mltbox_info(form, grid, gui, child_control_count, level)
end
function set_multi_w_h(multi)
  local w = multi:GetContentWidth()
  local h = multi:GetContentHeight()
  if w < multi.Width then
    multi.Width = w
  end
  if h < multi.Height then
    multi.Height = h
  end
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function set_mltbox_info(form, grid, gui, count, level)
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return
  end
  if nx_is_valid(grid) then
    local type_info = grid.type_info
    if nx_int(-1) < nx_int(type_info) and nx_int(type_info) < nx_int(ITT_COUNT) then
      local info_list = mgr:GetTvtBaseInfo(type_info)
      local base_info = get_interact_base_info(type_info)
      local value = nx_widestr("")
      if base_info[3] == nil or base_info[3] == "0" then
        value = util_format_string("wuxianzhi")
      else
        value = nx_widestr(base_info[3])
      end
      local interact_time = nx_string(mgr:GetInteractTime(type_info))
      local text = gui.TextManager:GetFormatText("ui_tvt_info", info_list[13], base_info[5], nx_string(interact_time .. " "), value, info_list[14])
      local multi_info = nx_custom(grid, "info_" .. count)
      if nx_is_valid(multi_info) then
        multi_info.HtmlText = nx_widestr(text)
      end
      set_recommend_info(gui, grid, count, nx_number(level))
    elseif 80 == type_info then
      set_recommend_info(gui, grid, count, nx_number(level))
      local multi_info = nx_custom(grid, "info_" .. count)
      if nx_is_valid(multi_info) then
        multi_info.HtmlText = gui.TextManager:GetFormatText("ui_tvt_info1")
      end
    elseif 81 == type_info then
      set_recommend_info(gui, grid, count, nx_number(level))
      local multi_info = nx_custom(grid, "info_" .. count)
      if nx_is_valid(multi_info) then
        multi_info.HtmlText = gui.TextManager:GetFormatText("ui_tvt_info2")
      end
    end
  end
end
function set_recommend_info(gui, grid, count, level)
  local recommend_text = gui.TextManager:GetText("ui_recommend")
  local value = nx_widestr(recommend_text) .. nx_widestr(" ")
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local power_level = client_player:QueryProp("PowerLevel")
  local abs_level = math.abs(power_level - level)
  local size = 4 - abs_level / 10
  value = value .. nx_widestr("<img src=\"gui\\special\\tvt\\txt_star.png\"/>")
  for i = 1, size do
    value = value .. nx_widestr("<img src=\"gui\\special\\tvt\\txt_star.png\"/>")
  end
  local multi_recommend = nx_custom(grid, "recommend_" .. count)
  if nx_is_valid(multi_recommend) then
    multi_recommend.HtmlText = nx_widestr(value)
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function on_scroll_bar_info_value_changed(self, value)
  local form = self.ParentForm
  local child_control_list = form.groupscrollbox_main:GetChildControlList()
  local lbl = form.lbl_select
  for i, grid in ipairs(child_control_list) do
    grid.Top = grid.normal_pos - self.Value
    if nx_find_custom(lbl, "sel_grid") and nx_is_valid(lbl.sel_grid) and nx_id_equal(lbl.sel_grid, grid) then
      lbl.Top = grid.Top
    end
  end
end
function on_groupbox_get_capture(grid)
  local form = grid.ParentForm
  form.lbl_select.Top = grid.Top
  form.lbl_select.Left = grid.Left
  form.lbl_select.sel_grid = grid
  form.lbl_select.Visible = true
end
function on_lbl_select_click(lbl)
  if not nx_find_custom(lbl, "sel_grid") or not nx_is_valid(lbl.sel_grid) then
    return
  end
  nx_execute(form_tvt_main, "show_type_info", lbl.sel_grid.type_info)
end
function set_grid_power(form)
  local child_control_list = form.groupscrollbox_main:GetChildControlList()
  local grid_top = 0
  local normal_pos = 0
  local count = table.getn(child_control_list)
  local grid
  for i = 1, count do
    local grid_i = child_control_list[i]
    local power_i = grid_i.power
    for j = i + 1, count do
      local grid_j = child_control_list[j]
      if nx_is_valid(grid_j) then
        local power_j = grid_j.power
        if nx_number(power_i) > nx_number(power_j) then
          grid_top = grid_i.Top
          normal_pos = grid_i.normal_pos
          grid_i.Top = grid_j.Top
          grid_i.normal_pos = nx_number(grid_j.Top)
          grid_j.Top = grid_top
          grid_j.normal_pos = nx_number(normal_pos)
          grid = grid_i
          child_control_list[i] = grid_j
          child_control_list[j] = grid
        end
      end
    end
  end
end
