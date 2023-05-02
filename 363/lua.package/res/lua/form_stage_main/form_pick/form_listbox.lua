function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function on_lbx_list_select_click(list, index)
  local cur_sel_str = list.SelectString
  local form = list.Parent
  nx_gen_event(form, "listbox_return", nx_widestr(cur_sel_str))
  form:Close()
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
  nx_destroy(form)
end
