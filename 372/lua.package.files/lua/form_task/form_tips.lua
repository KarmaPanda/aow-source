require("theme")
function show_tips(left, top, info)
  if "" == info then
    return 0
  end
  local tips_form = nx_value("tips_form")
  if not nx_is_valid(tips_form) then
    local gui = nx_value("gui")
    tips_form = LOAD_FORM(nx_resource_path(), gui.skin_path .. "\\form_task\\form_tips.xml")
    tips_form.Left = left
    tips_form.Top = top
    tips_form:Show()
    nx_set_value("tips_form", tips_form)
  end
  tips_form.mltbox_info.HtmlText = nx_widestr(info)
  return 1
end
function close_tips()
  local tips_form = nx_value("tips_form")
  if nx_is_valid(tips_form) then
    tips_form:Close()
    nx_destroy(tips_form)
  end
  return 1
end
function btn_close_click(self)
  local form = self.Parent
  form:Close()
  nx_destroy(form)
end
