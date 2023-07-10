require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
local FORM_MOVIE_CHOSE = "form_stage_main\\form_outland\\form_movie_chose"
local server_sub_msg_show_event_item = 1
local client_sub_msg_select_event_item = 1
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_server_msg(sub_msg, ...)
  if nx_int(table.getn(arg)) < nx_int(4) then
    return
  end
  local form = util_show_form(FORM_MOVIE_CHOSE, true)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_msg) == nx_int(server_sub_msg_show_event_item) then
    nx_set_custom(form.btn_1, "item_id", nx_int(arg[1]))
    nx_set_custom(form.btn_2, "item_id", nx_int(arg[2]))
    form.mltbox_1.HtmlText = util_text(arg[3])
    form.mltbox_2.HtmlText = util_text(arg[4])
  end
end
function on_btn_1_click(btn)
  if not nx_find_custom(btn, "item_id") then
    return
  end
  local item_id = btn.item_id
  custom_outland_event_select_item(nx_int(client_sub_msg_select_event_item), nx_int(item_id))
  local form = nx_value(FORM_MOVIE_CHOSE)
  form:Close()
end
function on_btn_2_click(btn)
  if not nx_find_custom(btn, "item_id") then
    return
  end
  local item_id = btn.item_id
  custom_outland_event_select_item(nx_int(client_sub_msg_select_event_item), nx_int(item_id))
  local form = nx_value(FORM_MOVIE_CHOSE)
  form:Close()
end
