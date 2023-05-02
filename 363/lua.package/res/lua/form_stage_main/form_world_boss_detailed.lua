require("util_gui")
require("util_functions")
require("tips_data")
require("tips_game")
local BOSS_GENERAL = "form_stage_main\\form_world_boss_general"
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size(form)
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  local general_form = util_get_form(BOSS_GENERAL, false)
  if not nx_is_valid(general_form) then
    local set_info_list = get_global_arraylist("set_info_list")
    if nx_is_valid(set_info_list) then
      nx_destroy(set_info_list)
    end
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_uncommon_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local lbl_page = form.lbl_uncommon_page
  if not nx_find_custom(lbl_page, "page_no") then
    return
  end
  local data_source = btn.DataSource
  if "0" == data_source then
    lbl_page.page_no = lbl_page.page_no - 1
  elseif "1" == data_source then
    lbl_page.page_no = lbl_page.page_no + 1
  end
  local remark = nx_string(form.DataSource)
  if nil == remark or "" == remark then
    return
  end
  nx_execute(BOSS_GENERAL, "get_node_info_item", form, remark, "uncommon")
end
function on_btn_common_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local lbl_page = form.lbl_common_page
  if not nx_find_custom(lbl_page, "page_no") then
    return
  end
  local data_source = btn.DataSource
  if "0" == data_source then
    lbl_page.page_no = lbl_page.page_no - 1
  elseif "1" == data_source then
    lbl_page.page_no = lbl_page.page_no + 1
  end
  local remark = nx_string(form.DataSource)
  if nil == remark or "" == remark then
    return
  end
  nx_execute(BOSS_GENERAL, "get_node_info_item", form, remark, "common")
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local remark = nx_string(form.DataSource)
  if nil == remark or "" == remark then
    return
  end
  local data_source = nx_string(grid.DataSource)
  local prop = ""
  if "0" == data_source then
    prop = "uncommon"
  elseif "1" == data_source then
    prop = "common"
  end
  if nil == prop or "" == prop then
    return
  end
  local item_id = nx_execute(BOSS_GENERAL, "get_item_id", form, remark, prop, index)
  if nil == item_id or "" == item_id then
    return
  end
  local item = get_tips_ArrayList()
  if not nx_is_valid(item) then
    return
  end
  item.is_static = true
  item.ConfigID = item_id
  item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", item_id, "ItemType", "0")
  show_goods_tip(item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 40, 40, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  hide_tip(grid.ParentForm)
end
