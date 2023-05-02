function util_get_form(formname, iscreate, isclose)
  if string.len(formname) == 0 then
    return
  end
  local form = nx_value(formname)
  if not nx_is_valid(form) and iscreate then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) or not nx_is_valid(gui.Loader) then
      return nx_null()
    end
    form = gui.Loader:LoadForm(nx_resource_path(), gui.skin_path .. formname .. ".xml")
    if not nx_is_valid(form) then
      nx_msgbox(util_text("msg_CreateFormFailed - ") .. gui.skin_path .. formname .. ".xml")
      return 0
    end
    if isclose == nil or isclose then
      form.Visible = false
      form:Close()
    end
    nx_set_value(formname, form)
    return form
  end
  return form
end
function util_auto_show_hide_form(formname)
  local form = util_get_form(formname, true)
  if not nx_is_valid(form) then
    return 0
  end
  if form.Visible then
    form.Visible = false
    form:Close()
  else
    form.Visible = true
    form:Show()
  end
end
function util_show_form(formname, visible)
  local form = util_get_form(formname, false)
  if not visible then
    if not nx_is_valid(form) then
      return 1
    else
      form.Visible = false
      form:Close()
    end
  else
    form = util_get_form(formname, true)
    if nx_is_valid(form) then
      form.Visible = true
      form:Show()
    end
  end
end
