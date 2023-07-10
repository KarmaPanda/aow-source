require("util_functions")
require("share\\client_custom_define")
require("const_define")
require("util_gui")
require("control_set")
local CLONE_INFO = {
  "ui_clonerec_dif01",
  "ui_clonerec_dif02",
  "ui_clonerec_dif03",
  "ui_clonerec_dif04"
}
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Desktop.Width - form.Width) / 2
  form.AbsTop = (gui.Desktop.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_gen_event(form, "captain_reset_request", "cancel")
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "captain_reset_request", "ok")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "captain_reset_request", "cancel")
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.Parent
  nx_gen_event(form, "captain_reset_request", "cancel")
  form:Close()
end
function show_info(captain_name, scene_configid, level)
  local form = nx_value("form_stage_main\\form_captain_reset_clone")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form = util_get_form("form_stage_main\\form_captain_reset_clone", true, false)
  form:Show()
  form.Visible = true
  local nametxt = gui.TextManager:GetText(nx_string(scene_configid))
  local leveltxt = gui.TextManager:GetText(CLONE_INFO[nx_number(level)])
  form.mltbox_help_info:AddHtmlText(gui.TextManager:GetFormatText("ui_clone_reset_invite", nx_widestr(captain_name), nx_widestr(nametxt .. leveltxt)), -1)
  local res = nx_wait_event(100000000, form, "captain_reset_request")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACCEPT_CAPTAIN_RESET_CLONE), captain_name, scene_configid, level)
  elseif res == "cancel" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REFUSE_CAPTAIN_RESET_CLONE), captain_name, scene_configid, level)
  end
end
function show_captain_reset_info(captain_name, scene_configid, level)
  show_info(captain_name, scene_configid, level)
end
