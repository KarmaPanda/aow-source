require("const_define")
function main_form_init(self)
end
function on_main_form_open(self)
  self.lbl_timer.Text = nx_widestr("0")
  local nScrWidth = self.lbl_sbg.Width
  local nWidthPerSection = nScrWidth / 20
  self.BaseSpeed = nWidthPerSection
  self.BaseOffset = nWidthPerSection / 5
  self.Interval = 5
  self.IncAcceleration = 0.34
  self.Speed = self.BaseOffset
  self.Limit = 20
  on_reset_ball(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = 150
  local timer = nx_value(GAME_TIMER)
  timer:Register(100, -1, "form_stage_main\\form_smallgame\\form_game_stump", "on_update_ball", self, -1, -1)
end
function on_main_form_close(self)
end
function on_reset_ball(form)
  local nDeltaLeft = form.lbl_sbg.Width / 2
  local nDeltaLeft = nDeltaLeft - form.lbl_ball.Width / 2
  form.lbl_ball.AbsLeft = form.lbl_sbg.AbsLeft + nDeltaLeft
end
function on_btn_left_click(btn)
  local form = btn.Parent
  form.Speed = form.Speed - form.IncAcceleration * form.BaseOffset
end
function on_btn_right_click(btn)
  local form = btn.Parent
  form.Speed = form.Speed + form.IncAcceleration * form.BaseOffset
end
local nTempTimer = 0
local nTempRandomTracker = 0
function on_update_ball(form, param1, param2)
  local nDelta1 = form.lbl_ball.AbsLeft - form.lbl_sbg.AbsLeft
  local ball_AbsRight = form.lbl_ball.AbsLeft + form.lbl_ball.Width
  local sbg_AbsRight = form.lbl_sbg.AbsLeft + form.lbl_sbg.Width
  local nDelta2 = sbg_AbsRight - ball_AbsRight
  if nx_int(nDelta1) <= nx_int(0) or nx_int(nDelta2) <= nx_int(0) then
    on_game_end(form, 0, nx_int(form.lbl_timer.Text))
    return
  end
  nTempRandomTracker = nTempRandomTracker + 1
  if nx_int(nTempRandomTracker) >= nx_int(form.Interval) then
    nTempRandomTracker = 0
    local nRandDir = math.random(2)
    if nx_int(nRandDir) == nx_int(1) then
      form.Speed = form.Speed + form.BaseOffset
    else
      form.Speed = form.Speed - form.BaseOffset
    end
  end
  form.lbl_ball.AbsLeft = form.lbl_ball.AbsLeft + form.Speed
  form.lbl_speed.Text = nx_widestr(form.Speed .. "   " .. form.BaseOffset)
  if nx_int(form.lbl_ball.AbsLeft) <= nx_int(form.lbl_sbg.AbsLeft) then
    form.lbl_ball.AbsLeft = form.lbl_sbg.AbsLeft
  end
  if nx_int(ball_AbsRight) >= nx_int(sbg_AbsRight) then
    form.lbl_ball.AbsLeft = sbg_AbsRight - form.lbl_ball.Width
  end
  nTempTimer = nTempTimer + 1
  if nx_int(nTempTimer) >= nx_int(10) then
    nTempTimer = 0
    local nCurTime = nx_int(form.lbl_timer.Text)
    local LimitTime = nx_int(form.Limit)
    if nCurTime >= nx_int(LimitTime) then
      form.lbl_timer.Text = nx_widestr(form.Limit)
      on_game_end(form, 1, nx_int(form.lbl_timer.Text))
      return
    else
      nCurTime = nCurTime + 1
      form.lbl_timer.Text = nx_widestr(nCurTime)
    end
  end
end
function on_game_end(form, result, time)
  form:Close()
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_smallgame\\form_game_stump", "on_update_ball", form)
  nx_destroy(form)
  nx_set_value("form_stage_main\\form_smallgame\\form_game_stump", nx_null())
end
function stump_game_stop(form)
  on_game_end(form, 0, 0)
end
function stump_game_key_down(gui, key, shift, ctrl)
  local form_stump = nx_value("form_stage_main\\form_smallgame\\form_game_stump")
  if not nx_is_valid(form_stump) then
    return
  end
  if shift or ctrl then
    return
  end
  if key == "A" or key == "Left" then
    on_btn_left_click(form_stump.btn_left)
    return
  end
  if key == "D" or key == "Right" then
    on_btn_right_click(form_stump.btn_right)
    return
  end
end
