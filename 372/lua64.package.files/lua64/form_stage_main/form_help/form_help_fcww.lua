require("util_gui")
local FORM_NAME = "form_stage_main\\form_help\\form_help_fcww"
function open_form()
  local form_transfer = nx_value("form_stage_main\\form_life\\form_newtreasure_transfer")
  if nx_is_valid(form_transfer) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_transfer", "on_btn_close_click", form_transfer.btn_close)
    return false
  end
  local form_grave = nx_value("form_stage_main\\form_life\\form_newtreasure_grave")
  if nx_is_valid(form_grave) then
    nx_execute("form_stage_main\\form_life\\form_newtreasure_grave", "on_btn_close_click", form_grave.btn_close)
    return false
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return false
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = false
  form.page_index = 1
  form.count = 5
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.page_index = 1
  form.btn_front.Enabled = false
end
function on_main_form_close(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) and form_talk.Visible then
    form_talk:Close()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function on_btn_front_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 2 or form.page_index > form.count then
    return
  end
  local groupbox_old = form:Find("groupbox_" .. nx_string(form.page_index))
  if nx_is_valid(groupbox_old) then
    groupbox_old.Visible = false
  end
  local groupbox_new = form:Find("groupbox_" .. nx_string(form.page_index - 1))
  if nx_is_valid(groupbox_new) then
    groupbox_new.Visible = true
  end
  if form.page_index == 2 then
    form.btn_front.Enabled = false
  end
  if form.page_index == form.count then
    form.btn_next.Enabled = true
  end
  form.page_index = form.page_index - 1
  return
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page_index < 1 or form.page_index > form.count then
    return
  end
  local groupbox_old = form:Find("groupbox_" .. nx_string(form.page_index))
  if nx_is_valid(groupbox_old) then
    groupbox_old.Visible = false
  end
  local groupbox_new = form:Find("groupbox_" .. nx_string(form.page_index + 1))
  if nx_is_valid(groupbox_new) then
    groupbox_new.Visible = true
  end
  if form.page_index == form.count - 1 then
    form.btn_next.Enabled = false
  end
  if form.page_index == 1 then
    form.btn_front.Enabled = true
  end
  form.page_index = form.page_index + 1
  return
end
