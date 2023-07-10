require("util_gui")
function on_main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  local form_logic = nx_value("form_shijia_info")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  form_logic = nx_create("form_shijia_info")
  if nx_is_valid(form_logic) then
    nx_set_value("form_shijia_info", form_logic)
    form_logic:InitUI(self)
  end
end
function on_main_form_close(self)
  local form_logic = nx_value("form_shijia_info")
  if nx_is_valid(form_logic) then
    nx_destroy(form_logic)
  end
  nx_destroy(self)
end
function on_btn_click(self)
  local form = nx_value("form_stage_main\\form_shijia\\form_shijia_guide")
  if nx_is_valid(form) then
    form.rbtn_play.Checked = true
    local id = self.shijia_id
    nx_execute("form_stage_main\\form_shijia\\form_shijia_play", "open_form", nx_string(id))
  end
end
