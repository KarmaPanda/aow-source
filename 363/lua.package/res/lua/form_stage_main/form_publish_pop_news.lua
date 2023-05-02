require("util_functions")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\switch\\url_define")
local g_path = "form_stage_main\\form_publish_pop_news"
function on_main_form_init(form)
  form.Fixed = false
  nx_set_value(g_path, form)
  return 1
end
function on_main_form_open(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local pop_status = client_player:QueryProp("NewsSetting")
  form.cbtn_1.Checked = pop_status ~= 0
end
function on_main_form_close(form)
end
function show_content(info)
  local form = nx_value(g_path)
  if form == nil or not nx_is_valid(form) then
    form = util_get_form(g_path, true)
    nx_set_value(g_path, form)
  end
  form.mltbox_msg.HtmlText = nx_widestr(info)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local pop_status = client_player:QueryProp("NewsSetting")
  if pop_status ~= 0 then
  else
    util_show_form(g_path, true)
  end
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  form.btn_server.Visible = true
end
function close_news(form)
  form.Visible = false
  form:Close()
end
function on_btn_xiangxi_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_9YIN_WEB)
  end
end
function on_btn_ok_click(btn)
  close_news(btn.ParentForm)
end
function on_setting_checked_changed(btn)
  custom_send_msg(nx_int(btn.Checked))
end
function custom_send_msg(subtype, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEWSSETTING_MSG), nx_int(subtype), unpack(arg))
end
