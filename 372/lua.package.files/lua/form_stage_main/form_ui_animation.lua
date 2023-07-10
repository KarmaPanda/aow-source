require("util_functions")
require("define\\define")
require("define\\gamehand_type")
require("define\\team_rec_define")
require("form_stage_main\\form_map\\map_logic")
require("share\\logicstate_define")
require("share\\client_custom_define")
require("form_stage_main\\form_task\\task_define")
require("define\\sysinfo_define")
require("util_gui")
require("define\\map_lable_define")
require("tips_data")
require("util_role_prop")
function main_form_open(form)
  local gui = nx_value("gui")
  form.Fixed = true
  form.Width = gui.Width
  form.Height = gui.Height
  form.animation_ctl.Width = gui.Width
  form.animation_ctl.Height = gui.Height
  if form.animation_image == "" then
    form:Close()
  end
  form.Visible = true
  if form.loop_times <= 0 then
    form.loop_times = 1
  end
  if form.loop_times > 1 then
    form.animation_ctl.Loop = true
  else
    form.animation_ctl.Loop = false
  end
  form.animation_ctl.AnimationImage = form.animation_image
  form.animation_ctl:Play()
end
function main_form_close(form)
  nx_destroy(form)
end
function animation_ctl_animation_loop(self)
  local form = self.ParentForm
  form.loop_times = form.loop_times - 1
  if form.loop_times == 0 then
    self:Stop()
    form:Close()
  end
end
function animation_ctl_animation_end(self)
  local form = self.ParentForm
  form:Close()
end
