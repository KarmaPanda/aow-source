require("util_functions")
require("form_stage_main\\form_task\\task_define")
local form_name = "form_stage_main\\form_talk_share"
local top_pos = 2
function main_form_init(self)
  self.Fixed = false
  self.task_id = 0
  self.task_title = ""
  self.sharer_name = ""
  return 1
end
function main_form_open(form)
  on_size_change(form)
  fresh_text(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
end
function show_window(task_id, task_title, sharer_name)
  local form_talk_share = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_talk_share", true, false, task_id)
  if not nx_is_valid(form_talk_share) then
    return
  end
  form_talk_share.task_id = task_id
  form_talk_share.task_title = task_title
  form_talk_share.sharer_name = sharer_name
  form_talk_share:Show()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_accept_share_task")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_size_change(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / top_pos
  if top_pos <= 1.5 then
    top_pos = 2
  end
  top_pos = top_pos - 0.1
end
function fresh_text(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.lbl_title.Text = gui.TextManager:GetText("ui_share") .. gui.TextManager:GetText("ui_renwu")
  local title = nx_string(form.task_title)
  local name = nx_string(form.sharer_name)
  form.mltbox_info.HtmlText = util_format_string("ui_task_share_text", name, title)
end
