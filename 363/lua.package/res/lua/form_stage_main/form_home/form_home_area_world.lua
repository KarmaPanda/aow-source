require("util_functions")
require("util_gui")
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  local name = nx_string(btn.Name)
  if string.len(name) < 4 then
    return
  end
  local x, y = string.find(name, "btn_")
  if x ~= 1 or y ~= 4 then
    return
  end
  local areaid = string.sub(name, y + 1)
  local parent_form = nx_value("form_stage_main\\form_home\\form_home")
  if not nx_is_valid(parent_form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home", "refresh_map", parent_form, 2, areaid)
end
