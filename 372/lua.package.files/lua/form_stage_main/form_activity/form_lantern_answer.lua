require("share\\client_custom_define")
require("util_functions")
require("util_gui")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_answer_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_cj_hd05"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(form) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LANTERN), nx_int(2), nx_int(btn.TabIndex))
    form:Close()
  end
end
function on_server_msg(...)
  util_show_form("form_stage_main\\form_activity\\form_lantern_answer", true)
  local form = nx_value("form_stage_main\\form_activity\\form_lantern_answer")
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_question_title.HtmlText = util_text(arg[1])
  if arg[2] ~= "" then
    form.btn_answer_1.Visible = true
    form.btn_answer_1.Text = util_text(arg[2])
  else
    form.btn_answer_1.Visible = false
  end
  if arg[3] ~= "" then
    form.btn_answer_2.Visible = true
    form.btn_answer_2.Text = util_text(arg[3])
  else
    form.btn_answer_2.Visible = false
  end
  if arg[4] ~= "" then
    form.btn_answer_3.Visible = true
    form.btn_answer_3.Text = util_text(arg[4])
  else
    form.btn_answer_3.Visible = false
  end
  if arg[5] ~= "" then
    form.btn_answer_4.Visible = true
    form.btn_answer_4.Text = util_text(arg[5])
  else
    form.btn_answer_4.Visible = false
  end
  local select_form = nx_value("form_stage_main\\form_activity\\form_lantern_select")
  if nx_is_valid(select_form) then
    select_form:Close()
  end
end
