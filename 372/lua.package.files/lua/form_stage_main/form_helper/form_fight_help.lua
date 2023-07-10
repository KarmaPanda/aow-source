local error_image = "gui\\special\\freshman\\icon_undone.png"
local validity_image = "gui\\special\\freshman\\icon_done.png"
local error_image_big = "gui\\special\\freshman\\icon_step_undone.png"
local validity_image_big_1 = "gui\\special\\freshman\\icon_step_done.png"
local validity_image_big_2 = "gui\\special\\freshman\\icon_step_done2.png"
function util_open_fight_info(open_type, light_num)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_helper\\form_fight_help", true, false)
  if not nx_is_valid(form) then
    return 1
  end
  if nx_number(4) == nx_number(open_type) then
    form.Visible = false
    form:Close()
    return 1
  end
  form.Visible = true
  form:Show()
  if 10 ~= nx_number(open_type) then
    set_default_info(form, true)
    on_refresh_form(form, nx_number(open_type), nx_number(light_num))
  else
    set_default_info(form, false)
  end
  return 1
end
function main_form_init(self)
  return 1
end
function on_main_form_open(self)
  self.Left = 100
  self.Top = 200
  return 1
end
function set_default_info(form, vis)
  form.groupbox_2.Visible = not vis
  form.groupbox_1.Visible = vis
end
function on_main_form_close(self)
  nx_destroy(self)
  return 1
end
function on_refresh_form(form, open_type, light_num)
  form.lbl_fight_light_1.BackImage = error_image_big
  form.lbl_fight_light_2.BackImage = error_image_big
  form.lbl_fight_light_3.BackImage = error_image_big
  form.lbl_skill_1.BackImage = error_image
  form.lbl_skill_2.BackImage = error_image
  if 1 == light_num then
    form.lbl_fight_light_1.BackImage = validity_image_big_1
  elseif 2 == light_num then
    form.lbl_fight_light_1.BackImage = validity_image_big_1
    form.lbl_fight_light_2.BackImage = validity_image_big_2
    form.lbl_fight_light_2.Left = form.lbl_fight_light_1.Left + 23
  elseif 3 == light_num then
    form.lbl_fight_light_1.BackImage = validity_image_big_1
    form.lbl_fight_light_2.BackImage = validity_image_big_2
    form.lbl_fight_light_2.Left = form.lbl_fight_light_1.Left + 23
    form.lbl_fight_light_3.BackImage = validity_image_big_2
    form.lbl_fight_light_3.Left = form.lbl_fight_light_1.Left + 58
  end
  if 2 == open_type then
    form.lbl_skill_1.BackImage = validity_image
    form.lbl_skill_2.BackImage = error_image
  elseif 3 == open_type then
    form.lbl_skill_1.BackImage = validity_image
    form.lbl_skill_2.BackImage = validity_image
    local timer = nx_value("timer_game")
    timer:UnRegister(nx_current(), "on_update_time", form)
    timer:Register(3000, 1, nx_current(), "on_update_time", form, -1, -1)
  else
    form.lbl_skill_1.BackImage = error_image
    form.lbl_skill_2.BackImage = error_image
  end
end
function on_update_time(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form.lbl_skill_1.BackImage = error_image
  form.lbl_skill_2.BackImage = error_image
end
