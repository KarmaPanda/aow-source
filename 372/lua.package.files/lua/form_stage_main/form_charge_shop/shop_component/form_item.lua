require("util_gui")
require("util_functions")
require("form_stage_main\\form_charge_shop\\shop_util")
local g_form_name = "form_stage_main\\form_charge_shop\\shop_component\\form_item"
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.btn_delete.Visible = false
end
function on_main_form_close(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function set_item_info()
end
function on_mousein_grid(grid)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local manager = nx_value("ChargeShop")
  local index = nx_custom(form, "index")
  local config = manager:GetConfig(index)
  nx_execute("tips_game", "show_tips_by_config", config, x, y, form)
end
function on_mouseout_grid(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_buy_click(btn)
  local form = btn.ParentForm
  local index = nx_custom(form, "index")
  local bCanBuy = can_buy_item(index)
  if bCanBuy then
    buy_item(index)
  else
    util_show_form("form_stage_main\\form_charge_shop\\form_charge_tips", true)
  end
end
function on_btn_give_click(btn)
  local form = btn.ParentForm
  local index = nx_custom(form, "index")
  local bCanBuy = can_buy_item(index)
  if bCanBuy then
    give_item(index)
  else
    util_show_form("form_stage_main\\form_charge_shop\\form_charge_tips", true)
  end
end
function on_delete_fav_click(btn)
  local form = btn.ParentForm
  local index = nx_custom(form, "index")
  if index < 0 then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = util_format_string("ui_shop_del_confirm")
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
    local delete_id = format_fav_id(index)
    send_server_msg(CLIENT_FAVRATE_REMOVE, delete_id)
  end
end
function on_show_model(grid)
  local item = grid.ParentForm
  local index = nx_custom(item, "index")
  local manager = nx_value("ChargeShop")
  if not nx_is_valid(manager) then
    return
  end
  local config = manager:GetConfig(nx_int(index))
  local model_form = "form_stage_main\\form_charge_shop\\shop_component\\form_browser"
  local form = grid.ParentForm
  if is_art_equip(config) or is_shenfen_equip(config) then
    nx_execute(model_form, "show_model", index, 0, form, true)
  elseif is_mount(config) then
    nx_execute(model_form, "show_model", index, 1, form, true)
  else
    nx_execute(model_form, "show_model", index, -1, form, false)
  end
end
