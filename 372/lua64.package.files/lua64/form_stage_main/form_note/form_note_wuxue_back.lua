require("util_gui")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
  local form_note = util_get_form("form_stage_main\\form_note\\form_note_wuxue_record", false, false)
  if nx_is_valid(form_note) then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form_note)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local form_wuxue = util_get_form("form_stage_main\\form_note\\form_note_wuxue_record", false, false)
  if nx_is_valid(form_wuxue) then
    form_wuxue:Close()
  end
  nx_destroy(form)
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_note\\form_note_wuxue_back", false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = 0
  form.Top = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.lbl_back.Width = form.Width
  form.lbl_back.Height = form.Height
end
