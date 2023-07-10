function main_form_init(self)
  return 1
end
function main_form_open(self)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
