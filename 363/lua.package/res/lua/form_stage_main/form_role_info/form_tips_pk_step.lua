require("util_gui")
function out_show(pk_value, pk_step)
  local form = util_get_form("form_stage_main\\form_role_info\\form_tips_pk_step", true)
  if not nx_is_valid(form) then
    return
  end
  form.pk_value = pk_value
  form.pk_step = pk_step
  util_show_form("form_stage_main\\form_role_info\\form_tips_pk_step", true)
end
function main_form_init(self)
  self.pk_value = 0
  self.pk_step = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  local HeadText = gui.TextManager:GetText("ui_role_pk_step_" .. nx_string(self.pk_step))
  local tipText = gui.TextManager:GetText("ui_role_info_tip")
  local RightText = nx_widestr(tipText .. nx_widestr(self.pk_value))
  local DescText = gui.TextManager:GetText("desc_pk_step_" .. nx_string(self.pk_step))
  self.mltbox_name:Clear()
  self.mltbox_name:AddHtmlText(HeadText, -1)
  self.lbl_type.Text = RightText
  self.mltbox_prop:Clear()
  self.mltbox_prop:AddHtmlText(DescText, -1)
  local height = self.mltbox_prop:GetContentHeight()
  self.mltbox_prop.Height = height
  self.Height = self.mltbox_prop.Top + self.mltbox_prop.Height + 10
  self.lbl_back.Height = self.Height
end
function on_main_form_close(self)
  nx_destroy(self)
end
