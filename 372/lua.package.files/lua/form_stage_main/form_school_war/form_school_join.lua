require("util_functions")
require("util_gui")
require("util_static_data")
function main_form_init(form)
  form.Fixed = true
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "delay_close_form", form)
  end
  nx_destroy(form)
end
function on_join_school(cartoon_id)
  local str = nx_string(cartoon_id)
  if "" == str then
    return
  end
  local form = util_auto_show_hide_form("form_stage_main\\form_school_war\\form_school_join")
  if not nx_is_valid(form) then
    return
  end
  form.ani_join.AnimationImage = str
  form.Visible = true
  form.ani_join:Stop()
  form.ani_join:Play()
  nx_execute("form_stage_main\\form_school_war\\form_school_join", "cartoon_end", form)
end
function cartoon_end(form)
  nx_pause(3)
  if nx_is_valid(form) then
    form:Close()
  end
end
function display_animation(id, left, top, width, height, loop, maxsize, dur_time)
  local gui = nx_value("gui")
  local cartoon_id = nx_string(id)
  if "" == cartoon_id then
    return
  end
  local form = util_auto_show_hide_form("form_stage_main\\form_school_war\\form_school_join", id)
  if not nx_is_valid(form) then
    return
  end
  if maxsize == true then
    form.Width = gui.Width
    form.Height = gui.Height
    form.Left = 0
    form.Top = 0
    form.ani_join.Visible = false
    form.DrawMode = "FitWindow"
    form.BackImage = cartoon_id
    form.Visible = true
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "delay_close_form", form)
      timer:Register(dur_time, 1, nx_current(), "delay_close_form", form, -1, -1)
    end
  else
    form.ani_join.Width = nx_number(width)
    form.ani_join.Height = nx_number(height)
    form.ani_join.AnimationImage = cartoon_id
    form.ani_join.Loop = nx_boolean(loop)
    form.VAnchor = "Center"
    form.HAnchor = "Center"
    form.Left = nx_number(left)
    form.Top = nx_number(top)
    form.Width = form.ani_join.Width + form.ani_join.Left * 2
    form.Height = form.ani_join.Height + form.ani_join.Top * 2
    form.Visible = true
    form.ani_join:Stop()
    form.ani_join:Play()
  end
end
function on_ani_join_animation_loop(ani)
  local scenario_npc_manager = nx_value("scenario_npc_manager")
  if not nx_is_valid(scenario_npc_manager) then
    return
  end
  if scenario_npc_manager:IsPlaying() then
    return
  end
  local form = ani.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_ani_join_animation_end(ani)
  local form = ani.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function delay_close_form(form)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
