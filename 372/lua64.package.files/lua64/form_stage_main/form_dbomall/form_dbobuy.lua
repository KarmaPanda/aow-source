require("utils")
local FORM_DBOBUY = "form_stage_main\\form_dbomall\\form_dbobuy"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
end
function on_main_form_close(form)
  if not nx_find_custom(form, "close_type") or nx_string(form.close_type) == nx_string("cancel") then
    nx_gen_event(form, "dbobuy_confirm_return", "cancel", nx_widestr(""))
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.close_type = "cancel"
    form:Close()
  end
end
function on_btn_cancel_click(btn)
  on_btn_close_click(btn)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.close_type = "ok"
    nx_gen_event(form, "dbobuy_confirm_return", "ok", nx_widestr(""))
    form:Close()
  end
end
function on_grid_main_mousein_grid(grid)
  local form = grid.ParentForm
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = config_id
  item.ItemType = ItemQuery:GetItemPropByConfigID(nx_string(configid), "ItemType")
  item.BindStatus = ItemQuery:GetItemPropByConfigID(nx_string(configid), "BindStatus")
  nx_execute("tips_game", "show_goods_tip", item, x, y, 0, 0, form)
end
function on_grid_main_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function change_form_size()
  local form = nx_value(FORM_DBOBUY)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
