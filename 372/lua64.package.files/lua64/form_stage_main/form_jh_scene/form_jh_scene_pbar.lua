require("util_gui")
local form_name = "form_stage_main\\form_jh_scene\\form_jh_scene_pbar"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
end
function on_main_form_close(self)
  self:Close()
  nx_destroy(self)
end
function open_form()
  util_show_form(form_name, true)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_pbar(value)
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form.pbar_1.Value = form.pbar_1.Value + value
  end
end
function set_pbar(value)
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form.pbar_1.Value = nx_int(value)
  end
end
