require("util_functions")
local MAX_ITEM_NUM = 24
local FILE_INI = "ini\\form_main_bbyd.ini"
function open_form()
  nx_execute("util_gui", "util_show_form", nx_current(), true)
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Desktop.Width - form.Width) / 2
    form.Top = (gui.Desktop.Height - form.Height) / 2
  end
  local form_ini = get_ini(FILE_INI, true)
  if not nx_is_valid(form_ini) then
    return
  end
  form.form_ini = form_ini
  form.ini_section_count = form_ini:GetSectionCount()
  local row = 2
  local col = 7
  local grid_width = form.ImageControlGrid_items.GridWidth
  local grid_height = form.ImageControlGrid_items.GridHeight
  local str_pos = nx_string("")
  for row = 0, 2 do
    for col = 0, 7 do
      local left = col * (grid_width + 16)
      local top = row * (grid_height + 16) + row * 30
      str_pos = str_pos .. nx_string(left) .. "," .. nx_string(top) .. ";"
    end
  end
  form.ImageControlGrid_items.GridsPos = str_pos
  refresh_grid(form, "1")
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "page_count") then
    return
  end
  local page_count = nx_number(form.page_count)
  local page_num = nx_number(rbtn.DataSource)
  if page_num < 0 or page_count < page_num then
    return
  end
  refresh_grid(form, rbtn.DataSource)
end
function on_ImageControlGrid_items_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "form_ini") then
    return
  end
  local form_ini = form.form_ini
  if not nx_is_valid(form_ini) then
    return
  end
  local item_name = nx_string(grid:GetItemName(index))
  local sec_index = form_ini:FindSectionIndex(item_name)
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local form_path = form_ini:ReadString(sec_index, "FormPath", "")
  if form_path == "" then
    return
  end
  nx_execute("util_gui", "util_show_form", form_path, true)
end
function on_ImageControlGrid_items_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "form_ini") then
    return
  end
  local form_ini = form.form_ini
  if not nx_is_valid(form_ini) then
    return
  end
  local item_name = nx_string(grid:GetItemName(index))
  local sec_index = form_ini:FindSectionIndex(item_name)
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local item_tips = form_ini:ReadString(sec_index, "TipsText", "")
  if item_tips == "" then
    return
  end
  local text = util_text(item_tips)
  nx_execute("tips_game", "show_text_tip", text, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
end
function on_ImageControlGrid_items_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function refresh_grid(form, form_page)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "form_ini") then
    return
  end
  local form_ini = form.form_ini
  if not nx_is_valid(form_ini) then
    return
  end
  local imagegrid = form.ImageControlGrid_items
  imagegrid:Clear()
  imagegrid:SetSelectItemIndex(nx_int(-1))
  if not nx_find_custom(form, "ini_section_count") then
    return
  end
  local item_count = form.ini_section_count
  local item_name, item_photo, item_tips = "", "", ""
  local imagegrid_index = 0
  for i = 0, item_count - 1 do
    local item_page = form_ini:ReadString(i, "Type", "")
    if item_page == form_page then
      local item_name = form_ini:GetSectionByIndex(i)
      local item_photo = form_ini:ReadString(i, "Image", "")
      if "" ~= item_photo and "" ~= item_name then
        imagegrid:AddItem(imagegrid_index, item_photo, nx_widestr(item_name), 1, -1)
        imagegrid:SetItemAddInfo(imagegrid_index, 0, util_text(item_name))
        imagegrid:ShowItemAddInfo(imagegrid_index, 0, true)
        imagegrid_index = imagegrid_index + 1
        if imagegrid_index >= MAX_ITEM_NUM then
          return
        end
      end
    end
  end
end
