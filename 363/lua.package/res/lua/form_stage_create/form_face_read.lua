require("utils")
function on_main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local path = nx_work_path() .. "face\\"
  form.path = path
  if not nx_path_exists(path) then
    nx_path_create(path)
  end
  local file_search = nx_create("FileSearch")
  form.file_search = file_search
  nx_execute("form_stage_create\\form_face_share", "update_cards_show", form)
  return 1
end
function on_main_form_close(self)
  nx_gen_event(self, "save_face_return", "cancel")
  if nx_is_valid(self.file_search) then
    nx_destroy(self.file_search)
  end
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function on_btn_ok_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if not nx_find_custom(form, "select_file") then
    return
  end
  local file_name = form.select_file
  if 0 == string.len(file_name) then
    return
  end
  local full_name = form.path .. file_name
  nx_gen_event(form, "read_face_return", "ok", full_name)
  form:Close()
end
function on_btn_close_click(btn)
  on_btn_cancel_click(btn)
end
function on_btn_cancel_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.file_search) then
    nx_destroy(form.file_search)
  end
  nx_gen_event(form, "save_face_return", "cancel")
  form:Close()
end
function on_btn_open_dir_click(btn)
  local dir = nx_work_path() .. "face\\"
  if not nx_path_exists(dir) then
    nx_path_create(dir)
  end
  local cmd = "explorer " .. dir
  nx_function("ext_win_exec", cmd)
end
