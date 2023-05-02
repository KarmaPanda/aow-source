require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
STATIN_FORM = "form_stage_main\\form_guild_war\\form_guild_war_task"
function open_form(form)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_domain", true, false)
  if not nx_is_valid(form) then
    return false
  end
  form:Show()
  return true
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  nx_execute(STATIN_FORM, "load_prize_source")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
