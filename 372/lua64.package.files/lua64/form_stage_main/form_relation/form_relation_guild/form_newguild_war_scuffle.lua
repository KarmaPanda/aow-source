require("util_gui")
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function on_btn_goto_click(self)
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "open_form")
end
