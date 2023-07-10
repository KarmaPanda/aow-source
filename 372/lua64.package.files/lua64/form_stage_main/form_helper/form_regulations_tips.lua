require("util_gui")
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_custom(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local custom_list = nx_custom_list(ent)
  log("custom_list bagin")
  for _, custom in ipairs(custom_list) do
    log("custom = " .. custom)
  end
  log("custom_list end")
end
local function get_property(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local prop_list = nx_property_list(ent)
  log("prop_list bagin")
  for _, prop in ipairs(prop_list) do
    log("property = " .. prop)
  end
  log("prop_list end")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function util_refresh_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_current(), true, true)
    if not nx_is_valid(form) then
      return false
    end
    form.Visible = true
    form:Show()
  end
  form.Visible = true
  set_image_control_grid_info(form)
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  set_image_control_grid_info(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_image_control_grid_select_changed(image_control_grid)
  local index = image_control_grid:GetSelectItemIndex()
  local i = image_control_grid:GetItemMark(index)
  local regulations_new = get_global_list("regulations_new")
  local child = regulations_new:GetChildByIndex(i)
  local gui = nx_value("gui")
  if not nx_is_valid(child) then
    return 1
  end
  local condition_mgr = nx_value("ConditionManager")
  local freshman_helper_mgr = nx_value("freshman_helper_mgr")
  local desc_info = freshman_helper_mgr:GetFreshmanHelperInfo(child.Name, "desc_image")
  local client_player = get_player()
  local desc = get_coincidence_info(condition_mgr, client_player, desc_info)
  local gui_desc = gui.TextManager:GetText(desc)
  local form = image_control_grid.ParentForm
  form.mltbox_info:AddHtmlText(nx_widestr(gui_desc), -1)
end
function on_btn_read_click(btn)
  local form = btn.ParentForm
  local image_control_grid = form.image_control_grid
  local index = image_control_grid:GetSelectItemIndex()
  local i = image_control_grid:GetItemMark(index)
  local regulations_new = get_global_list("regulations_new")
  local child = regulations_new:GetChildByIndex(i)
  if nx_is_valid(child) then
    child.open = true
  else
    return 1
  end
  set_image_control_grid_info(form)
  nx_execute("form_stage_main\\form_helper\\form_regulations_helper", "regulations_select_helper", child.path)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function set_image_control_grid_info(form)
  local regulations_new = get_global_list("regulations_new")
  local image_control_grid = form.image_control_grid
  local child_list = regulations_new:GetChildList()
  local open_count = 0
  image_control_grid:Clear()
  for i, child in ipairs(child_list) do
    if not nx_find_custom(child, "open") and false == nx_custom(child, "open") then
      open_count = open_count + 1
    end
  end
  local col = image_control_grid.ClomnNum
  local row = (open_count + col - 1) / col
  image_control_grid.RowNum = row
  image_control_grid.MultiTextBoxLeft = nx_int(0)
  set_image_control_grid_image(image_control_grid)
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function set_image_control_grid_image(image_control_grid)
  local row = image_control_grid.RowNum
  local col = image_control_grid.ClomnNum
  local regulations_new = get_global_list("regulations_new")
  local condition_mgr = nx_value("ConditionManager")
  local freshman_helper_mgr = nx_value("freshman_helper_mgr")
  freshman_helper_mgr:ReloadResource()
  local client_player = get_player()
  local child_list = regulations_new:GetChildList()
  local gui = nx_value("gui")
  local count = row * col
  local index = 0
  for i, child in ipairs(child_list) do
    if not nx_find_custom(child, "open") or false == nx_custom(child, "open") then
      local title_info = freshman_helper_mgr:GetFreshmanHelperInfo(child.Name, "title")
      local image_info = freshman_helper_mgr:GetFreshmanHelperInfo(child.Name, "tips_image")
      local image = get_coincidence_info(condition_mgr, client_player, image_info)
      local title = get_coincidence_info(condition_mgr, client_player, title_info)
      local gui_title = gui.TextManager:GetText(title)
      image_control_grid:AddItem(nx_int(index), image, nx_widestr(""), nx_int(0), nx_int(i - 1))
      image_control_grid:ShowItemAddInfo(nx_int(index), nx_int(0), true)
      image_control_grid:SetItemInfo(nx_int(index), nx_widestr(gui_title))
      index = index + 1
    end
  end
end
function get_coincidence_info(condition_mgr, client_player, image_info)
  local info = nx_execute("form_stage_main\\form_helper\\form_regulations_helper", "get_coincidence_info", condition_mgr, client_player, image_info)
  return info
end
