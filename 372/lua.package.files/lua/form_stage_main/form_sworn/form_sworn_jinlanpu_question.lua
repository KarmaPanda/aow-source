require("util_gui")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_sworn\\form_sworn_jinlanpu_question"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  form.Visible = true
  form:Show()
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked == true then
    nx_execute("custom_sender", "custom_sworn", 2, nx_int(rbtn.ParentForm.index), nx_string(rbtn.answer))
  end
end
function open_form(time, index, ...)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.index = index
  form.Visible = true
  form:Show()
  form.mltbox_q:Clear()
  form.mltbox_q:AddHtmlText(nx_widestr(util_text(arg[1])), -1)
  local s_list = {}
  for i = 2, 5 do
    table.insert(s_list, arg[i])
    local rand = math.random(1, nx_number(table.getn(s_list)))
    local temp = s_list[rand]
    s_list[rand] = s_list[table.getn(s_list)]
    s_list[table.getn(s_list)] = temp
  end
  form.rbtn_1.Checked = false
  form.rbtn_2.Checked = false
  form.rbtn_3.Checked = false
  form.rbtn_4.Checked = false
  form.rbtn_1.Text = nx_widestr(util_text(s_list[1]))
  form.rbtn_1.answer = s_list[1]
  form.rbtn_2.Text = nx_widestr(util_text(s_list[2]))
  form.rbtn_2.answer = s_list[2]
  form.rbtn_3.Text = nx_widestr(util_text(s_list[3]))
  form.rbtn_3.answer = s_list[3]
  form.rbtn_4.Text = nx_widestr(util_text(s_list[4]))
  form.rbtn_4.answer = s_list[4]
  form.lbl_time.Text = nx_widestr(time)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) <= nx_int(0) then
    close_form()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - nx_int(1))
end
