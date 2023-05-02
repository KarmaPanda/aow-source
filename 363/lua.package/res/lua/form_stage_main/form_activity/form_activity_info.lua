require("util_functions")
local CLIENT_CUSTOMMSG_ACTIVITY_MANAGE = 182
local CLIENT_SUBMSG_REQUEST_REMAIN_PRIRZ_TIME = 0
function main_form_init(form)
  form.Fixed = false
  form.UpdateFlag = true
  form.HideFlag = false
  form.show = true
  form.remain_time = 0
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local ActivityManager = nx_value("ActivityManager")
  if nx_is_valid(ActivityManager) then
    ActivityManager:RegisterOnlinePrizeTimer(form.remain_time)
  end
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form.groupbox_girl)
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form.btn_show)
  end
  return 1
end
function on_main_form_close(form)
  form.UpdateFlag = true
  form.HideFlag = false
  form.Visible = false
  local ActivityManager = nx_value("ActivityManager")
  if nx_is_valid(ActivityManager) then
    ActivityManager:EndTimer()
  end
  nx_destroy(form)
end
function on_btn_hide_click(btn)
  local form = btn.ParentForm
  if form.show then
    form.groupbox_girl.Visible = false
    form.btn_show.Visible = true
    form.show = false
  else
    form.groupbox_girl.Visible = true
    form.btn_show.Visible = false
    form.show = true
  end
  if form.HideFlag then
    form.Height = 134
  else
    form.BlendColor = "255,255,255,255"
    change_time_form(form)
  end
end
function change_time_form(form)
  local gui = nx_value("gui")
  form.Height = nx_number(40)
  if form.UpdateFlag then
    form.Width = nx_number(60)
    form.UpdateFlag = false
  else
    form.UpdateFlag = true
    form.Height = nx_number(134)
    form.Width = nx_number(250)
  end
end
function on_main_form_lost_capture(form)
  if form.Height ~= 134 then
    return
  end
  if is_mouse_in_control(form.btn_hide) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  form.cur_alpha = nx_float(temp[1])
  common_execute:AddExecute("FormBlendColorOut", form, nx_float(0.8))
end
function is_mouse_in_control(self)
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(self.AbsLeft) and nx_float(mouse_x) < nx_float(self.AbsLeft + self.Width) and nx_float(mouse_y) > nx_float(self.AbsTop) and nx_float(mouse_y) < nx_float(self.AbsTop + self.Height) then
    return true
  else
    return false
  end
end
function init_info(form)
  form.lbl_need_hour.Text = nx_widestr("")
  form.lbl_remain_time.Text = nx_widestr("")
end
