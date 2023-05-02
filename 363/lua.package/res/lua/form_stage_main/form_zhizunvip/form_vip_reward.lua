require("util_gui")
require("util_functions")
require("util_vip")
local g_form_name = "form_stage_main\\form_zhizunvip\\form_vip_reward"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  send_vip_msg(VIP_GET_PRIZE_INFO, VT_NORMAL)
  local vis = is_week_get_prize()
  form.lbl_aget.Visible = vis
  form.btn_get.Enabled = false
end
function get_prop(id, prop)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return nil
  end
  local value = item_query:GetItemPropByConfigID(id, prop)
  if value ~= nil and value ~= "" then
    return value
  end
  return nil
end
function on_server_msg(type, ...)
  if type ~= VIP_GET_PRIZE_INFO then
    return
  end
  local itemid = arg[1]
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  local ctl = form.imagegrid_item
  local addnum = 0
  local icon = get_prop(itemid, "Photo")
  if icon ~= nil and ctl:AddItem(0, nx_string(icon), nx_widestr(itemid), 1, -1) then
    addnum = addnum + 1
  end
  if addnum < 1 then
    form.btn_get.Enabled = false
  else
    local vis = is_week_get_prize()
    form.btn_get.Enabled = not vis
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_btn_get_click(btn)
  send_vip_msg(VIP_GIVE_PRIZE, VT_NORMAL)
  util_show_form(g_form_name, false)
end
function on_imagegrid_item_mousein_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local config = nx_string(grid:GetItemName(index))
  if config == nil or string.len(config) > 0 then
    nx_execute("tips_game", "show_tips_by_config", config, x, y, form)
  end
end
function on_imagegrid_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_check_click(btn)
  nx_execute("form_stage_main\\form_origin\\form_origin", "auto_show_hide_origin")
end
