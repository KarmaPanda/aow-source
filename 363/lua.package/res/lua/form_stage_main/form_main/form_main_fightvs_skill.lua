require("form_stage_main\\form_main\\form_main_fightvs_util")
function main_form_init(form)
  form.Fixed = true
  form.skill_id = ""
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  nx_set_value("form_stage_main\\form_main\\form_main_fightvs_skill", form)
  gui.Desktop:ToFront(form)
end
function main_form_close(form)
  form.Visible = false
  local skillMovieform = nx_value("form_stage_main\\form_skill_movie")
  if nx_is_valid(skillMovieform) and skillMovieform.Visible == true then
    skillMovieform:Close()
  end
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_main\\form_main_fightvs_skill", nx_null())
end
function change_form_size()
  local form = util_get_form(FORM_FIGHT_VS_SKILL, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.AbsLeft = 250
  form.AbsTop = 200
end
function hide_skill_state(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.skill_id = ""
  form:Close()
end
function show_skill_state(skill_id)
  local form = util_get_form(FORM_FIGHT_VS_SKILL, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.skill_id = skill_id
  form.lbl_back.Visible = false
  form.ani_back.PlayMode = 2
  form.ani_type.Visible = true
  form.ani_type.AnimationImage = skill_id
  form.ani_type.Loop = false
  form.ani_type.PlayMode = 0
  form.pbar_time.Visible = false
  util_show_form(FORM_FIGHT_VS_SKILL, true)
end
function on_ani_type_animation_end(ani_control, name)
  local form = util_get_form(FORM_FIGHT_VS_SKILL, false)
  if not nx_is_valid(form) then
    return
  end
  hide_skill_state(form)
end
