require("util_functions")
require("utils")
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function change_form_pos()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_FB_lead")
  if not nx_is_valid(form) then
    return
  end
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  if not nx_is_valid(form_main_select) then
    return
  end
  local desktop = gui.Desktop
  form.Top = desktop.Top
  if nx_is_valid(form_main_select) and nx_find_custom(form_main_select, "select_hp_prog") then
    form.Left = form_main_select.select_hp_prog.AbsLeft + form_main_select.select_hp_prog.Width + 16
  else
    form.Left = desktop.Width / 2 + 84
  end
end
function change_form_size(form, num)
  local gird = form.ImageControlGrid1
  if not nx_is_valid(gird) then
    return
  end
  gird.Width = nx_number(num) * 32
  form.Width = nx_number(num) * 32
  form.Height = gird.Height
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  form.Top = desktop.Top
  local form_main_select = nx_value("form_stage_main\\form_main\\form_main_select")
  if nx_is_valid(form_main_select) and nx_find_custom(form_main_select, "select_hp_prog") then
    form.Left = form_main_select.select_hp_prog.AbsLeft + form_main_select.select_hp_prog.Width + 16
  else
    form.Left = desktop.Width / 2 + 84
  end
end
function on_ImageControlGrid1_mousein_grid(grid, index)
  local prop_table = get_item_data(grid, index)
  if not nx_is_valid(prop_table) then
    return
  end
  local tips_no_use = prop_table.tips_no_use
  local tips_can_use = prop_table.tips_can_use
  local tips_text = tips_no_use
  if not prop_table.no_use then
    tips_text = tips_can_use
  end
  if tips_text == "" or tips_text == nil then
    return
  end
  local gui = nx_value("gui")
  local gui = nx_value("gui")
  nx_execute("tips_game", "show_text_tip", nx_widestr(gui.TextManager:GetFormatText(tips_text)), grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_ImageControlGrid1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function enable_grid_by_index(configid, grid_id, enable)
  local self = nx_value("form_stage_main\\form_FB_lead")
  if not nx_is_valid(self) or self == nil then
    return
  end
  local grid = self.ImageControlGrid1
  if not nx_is_valid(grid) then
    return
  end
  local grid_index
  grid_index = get_gridindex_from_itemName(grid, grid_id)
  local prop_table = get_item_data(grid, grid_index)
  if not nx_is_valid(prop_table) or prop_table == nil then
    return
  end
  prop_table.no_use = true
  if nx_int(enable) == nx_int(1) then
    prop_table.no_use = false
  end
  grid:ChangeItemImageToBW(grid_index, prop_table.no_use)
end
function open_grid_by_configid(configid)
  local self = nx_value("form_stage_main\\form_FB_lead")
  if not nx_is_valid(self) or self == nil then
    self = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_FB_lead", true, false)
  end
  if not nx_is_valid(self) or self == nil then
    return
  end
  self:Show()
  local grid = self.ImageControlGrid1
  if not nx_is_valid(grid) then
    return
  end
  grid.RowNum = 1
  grid.ClomnNum = 9
  local data_table = get_data_by_ini("ini\\ui\\cloneleadui\\FB_clone.ini", configid)
  local num = show_FB_grids(grid, data_table)
  enable_grid_by_index("config4", true)
  change_form_size(self, num)
end
function close_grid_by_configid(configid)
  local self = nx_value("form_stage_main\\form_FB_lead")
  if not nx_is_valid(self) then
    return
  end
  local grid = self.ImageControlGrid1
  if not nx_is_valid(grid) then
    return
  end
  grid:Clear()
  if nx_is_valid(grid.Data) then
    grid.Data:ClearChild()
  end
end
function close_clone_lead_form()
  close_grid_by_configid("")
end
function show_FB_grids(grid, item_list)
  local datatable = {}
  local index = 0
  for _, section in pairs(item_list) do
    if nx_number(index) + nx_number(1) > nx_number(grid.ClomnNum) then
      return index
    end
    grid_add_data(grid, index, section)
    index = index + 1
  end
  return index
end
function get_gridindex_from_itemName(grid, item_name)
  for i = 0, grid.RowNum * grid.ClomnNum - 1 do
    local name = grid:GetItemName(i)
    if nx_string(name) == nx_string(item_name) then
      return i
    end
  end
  return -1
end
function get_item_data(grid, grid_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return nil
  end
  return GoodsGrid:GetItemData(grid, grid_index)
end
function grid_add_data(grid, grid_index, prop_table)
  if not grid:IsEmpty(grid_index) then
    grid_delete_data(grid, grid_index)
  end
  local photo = prop_table.photo
  local tips_no_use = prop_table.tips_no_use
  local tips_can_use = prop_table.tips_can_use
  local grid_id = prop_table.grid_id
  prop_table.no_use = true
  console_log_down("grid_id > " .. nx_string(grid_id))
  grid:AddItem(nx_int(grid_index), nx_string(photo), nx_widestr(grid_id), nx_int(1), nx_int(0))
  grid:ChangeItemImageToBW(grid_index, prop_table.no_use)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", grid_add_data)
  end
  local child_data = nx_create("ArrayList", nx_current())
  child_data.Name = nx_string(grid_index)
  grid.Data:AddChild(child_data)
  for prop, value in pairs(prop_table) do
    nx_set_custom(child_data, prop, value)
  end
end
function grid_delete_data(grid, grid_index)
  grid:DelItem(grid_index)
  if not nx_is_valid(grid.Data) then
    return
  end
  if nx_is_valid(grid.Data) then
    grid.Data:RemoveChild(nx_string(grid_index))
  end
end
function grid_clear(grid)
  grid:Clear()
  if nx_is_valid(grid.Data) then
    grid.Data:ClearChild()
  end
end
function get_data_by_ini(file_name, id)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return 0
  end
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return 0
  end
  local data_table = {}
  local sec_count = ini:GetSectionCount()
  for i = 1, sec_count do
    local section = ini:GetSectionByIndex(i - 1)
    if section == id then
      local index = 1
      local item_count = ini:GetSectionItemCount(i - 1)
      for j = 1, item_count do
        local str = ini:GetSectionItemValue(i - 1, j - 1)
        local str_lst = util_split_string(str, ",")
        local data = {}
        data.grid_id = ini:GetSectionItemKey(i - 1, j - 1)
        data.photo = str_lst[1]
        data.tips_no_use = str_lst[2]
        data.tips_can_use = str_lst[3]
        data_table[index] = data
        index = index + 1
      end
      return data_table
    end
  end
  return data_table
end
