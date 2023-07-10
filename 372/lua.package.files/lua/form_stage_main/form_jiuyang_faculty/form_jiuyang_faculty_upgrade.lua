require("util_gui")
local FORM_JIUYANG_FACULTY_UPGRADE = "form_stage_main\\form_jiuyang_faculty\\form_jiuyang_faculty_upgrade"
function main_form_init(self)
  self.Fixed = false
end
function open_form()
  local form = util_auto_show_hide_form(FORM_JIUYANG_FACULTY_UPGRADE)
end
function on_main_form_open(form)
  set_form_pos(form)
  form.show = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("JiuYangFacultyPointUsed", "int", form, nx_current(), "prop_callback_refresh")
    databinder:AddRolePropertyBind("JiuYangFacultyPoint", "int", form, nx_current(), "faculty_point_callback_refresh")
  end
  refresh_form(form)
  form.show = true
end
function on_main_form_drag_move(form)
  nx_execute("custom_effect", "animation_stop", "sole_prompt_13")
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  return 1
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 1
  end
  local JiuYangSkillCurLevel = player:QueryProp("JiuYangSkillCurLevel")
  for i = 1, 12 do
    local ctr_name = "lbl_level_" .. nx_string(i)
    if nx_find_custom(form, ctr_name) then
      local ctr = nx_custom(form, ctr_name)
      if nx_is_valid(ctr) then
        if i <= JiuYangSkillCurLevel then
          ctr.Visible = true
        else
          ctr.Visible = false
        end
      end
    end
  end
  if nx_int(JiuYangSkillCurLevel) >= nx_int(12) then
    return
  end
  local next_level_need_faculty = skill_data_manager:GetJiuYangSkillLevelNeedFaculty(JiuYangSkillCurLevel + 1)
  local cur_faculty_used = player:QueryProp("JiuYangFacultyPointUsed")
  form.pbar_skill_upgrade.Maximum = next_level_need_faculty
  form.pbar_skill_upgrade.Value = cur_faculty_used
  return 1
end
function prop_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  if form.show == true then
    refresh_form(form)
  end
  return 1
end
function faculty_point_callback_refresh(form, PropName, PropType, Value)
  if not nx_is_valid(form) then
    return 1
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  local JiuYangFacultyPoint = player:QueryProp("JiuYangFacultyPoint")
  form.lbl_cur_jiuyang_faculty_points_value.Text = nx_widestr(JiuYangFacultyPoint)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_canwu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_jiuyang_faculty", nx_int(1))
end
function show_zhaoshi_by_index(index)
  local form = nx_execute("util_gui", "util_get_form", FORM_JIUYANG_FACULTY_UPGRADE, true)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  show_animation("sole_prompt_13")
  local game_visual = nx_value("game_visual")
  local actor2 = game_visual:GetPlayer()
  if not nx_is_valid(actor2) then
    return
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  local play_zhaoshi_id = skill_data_manager:GetJiuYangFacultyActionByIndex(index)
  show_skill_action(actor2, play_zhaoshi_id)
end
function show_skill_action(actor2, skill_id)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
end
function on_pbar_skill_upgrade_get_capture(ctr)
  local form = ctr.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  local JiuYangSkillCurLevel = player:QueryProp("JiuYangSkillCurLevel")
  if nx_int(JiuYangSkillCurLevel) >= nx_int(12) then
    return
  end
  local next_level_need_faculty = form.pbar_skill_upgrade.Maximum
  local cur_faculty_used = form.pbar_skill_upgrade.Value
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("ui_jiuyang_faculty_turnspeed", nx_int(cur_faculty_used), nx_int(next_level_need_faculty))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), form.pbar_skill_upgrade.AbsLeft + 20, form.pbar_skill_upgrade.AbsTop)
end
function on_pbar_skill_upgrade_lost_capture(ctr)
  local form = ctr.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip")
end
function show_animation(ani_name)
  local form = nx_execute("util_gui", "util_get_form", FORM_JIUYANG_FACULTY_UPGRADE, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.Name = nx_string(ani_name)
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = form.Left - 7
  animation.Top = form.Top + 25
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "end_animation")
  animation:Play()
end
function end_animation(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
