require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2 + (gui.Width - self.Width) / 3
  self.AbsTop = (gui.Height - self.Height) / 8
  self.pk_value = 0
  self.ani_addpk.Visible = false
  self.ani_subpk.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NewTerritoryPKVal", "int", self, nx_current(), "on_pk_value_change")
  end
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_show_click(btn)
  local form = btn.ParentForm
  if form.groupbox.Visible == false then
    form.groupbox.Visible = true
  else
    form.groupbox.Visible = false
  end
end
function on_pk_value_change(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return
  end
  form.pbar_pk.Value = Value
  form.pkvalue_percent.Text = nx_widestr(Value) .. nx_widestr("/") .. nx_widestr(form.pbar_pk.Maximum)
  if nx_number(Value) > nx_number(form.pk_value) then
    play_add_ani()
  elseif nx_number(Value) < nx_number(form.pk_value) then
    play_sub_ani()
  end
  form.pk_value = Value
end
function on_inform_camp_count(light_count, dark_count)
  local form = nx_value("form_stage_main\\form_new_territory\\form_main_new_territory")
  if not nx_is_valid(form) then
    return
  end
  form.pbar_camp.Maximum = light_count + dark_count
  form.pbar_camp.Value = light_count
  form.camp_count_percent.Text = nx_widestr(light_count) .. nx_widestr("/") .. nx_widestr(dark_count)
end
function on_ani_pk_animation_end(self)
  self.Visible = false
  self.AnimationImage = self.AnimationImage
end
function play_add_ani()
  local form = nx_value("form_stage_main\\form_new_territory\\form_main_new_territory")
  if not nx_is_valid(form) then
    return
  end
  form.ani_addpk.Visible = true
  form.ani_addpk.Loop = false
  form.ani_addpk.PlayMode = 0
end
function play_sub_ani()
  local form = nx_value("form_stage_main\\form_new_territory\\form_main_new_territory")
  if not nx_is_valid(form) then
    return
  end
  form.ani_subpk.Visible = true
  form.ani_subpk.Loop = false
  form.ani_subpk.PlayMode = 0
end
