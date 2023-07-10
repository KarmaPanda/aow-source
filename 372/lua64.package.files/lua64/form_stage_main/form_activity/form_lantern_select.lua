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
function on_btn_lantern_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_text("ui_cj_hd04"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" and nx_is_valid(form) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LANTERN), nx_int(1), nx_int(btn.TabIndex))
    form:Close()
  end
end
function on_server_msg(...)
  util_show_form("form_stage_main\\form_activity\\form_lantern_select", true)
  local form = nx_value("form_stage_main\\form_activity\\form_lantern_select")
  if not nx_is_valid(form) then
    return
  end
  local tab = {
    [1] = form.btn_lantern_1,
    [2] = form.btn_lantern_2,
    [3] = form.btn_lantern_3,
    [4] = form.btn_lantern_4
  }
  for j = 1, table.getn(tab) do
    local btn = tab[i]
    if nx_is_valid(btn) then
      btn.Visible = false
    end
  end
  for i = 1, table.getn(arg) do
    local index = nx_int(arg[i])
    local btn = tab[i]
    if nx_is_valid(btn) then
      btn.Visible = true
      btn.Text = util_text("ui_lantern_question_" .. nx_string(index))
      btn.TabIndex = nx_int(index)
    end
  end
  local answer_form = nx_value("form_stage_main\\form_activity\\form_lantern_answer")
  if nx_is_valid(answer_form) then
    answer_form:Close()
  end
end
