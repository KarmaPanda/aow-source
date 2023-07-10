require("util_functions")
require("util_gui")
function main_form_init(form)
  form.Fixed = true
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  form.ani_djs:Stop()
  form.ani_djs:Play()
  local ready_form = util_get_form("form_stage_main\\form_match\\form_war_ready", false, true)
  if nx_is_valid(ready_form) then
    ready_form.Visible = false
    ready_form:Close()
  end
  local confirm_form = util_get_form("form_stage_main\\form_match\\form_taolu_confirm_new", false, true)
  if nx_is_valid(confirm_form) then
    confirm_form.Visible = false
    confirm_form:Close()
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_ani_djs_animation_end(ani)
  local form = ani.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
