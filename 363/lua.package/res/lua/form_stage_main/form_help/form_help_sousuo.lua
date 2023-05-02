function form_help_SouSuo_Init(self)
  self.Fixed = true
end
function form_help_SouSuo_Open(self)
end
function form_help_SouSuo_ClearList()
  local self = nx_execute("util_gui", "util_get_form", "form_help_SouSuo")
  if self.form_help_ss_JieGuo.ItemCount > 0 then
    self.form_help_ss_JieGuo:ClearString()
  end
end
function form_help_SouSuo_AddResult(name, html)
  local self = nx_execute("util_gui", "util_get_form", "form_help_SouSuo")
  self.form_help_ss_JieGuo:AddString(name)
  self.form_help_ss_Html:Clear()
  self.form_help_ss_Html:AddHtmlText(html, -1)
end
