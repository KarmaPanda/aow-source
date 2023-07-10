require("const_define")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local mostLeft = self.lbl_4.Left
  local mostRight = mostLeft + self.lbl_4.Width - self.lbl_ball.Width
  self.mostLeft = mostLeft
  self.mostRight = mostRight
  self.speed = 1
  self.maxCount = 0
  self.needGood = 0
  on_reset_ball(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = 150
  self.good = 0
  self.bad = 0
  self.direct = 1
  self.isAction = false
  self.ballPos = self.lbl_ball.Left
  self.doing = false
end
function on_main_form_close(self)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_pichai", nx_null())
end
function on_reset_ball(form)
  local pos = (form.mostLeft + form.mostRight) / 2
  form.lbl_ball.AbsLeft = pos
end
function on_btn_start_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  if form.maxCount == 0 then
    return
  end
  form.doing = true
  btn.Visible = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(50, -1, "form_stage_main\\form_small_game\\form_game_pichai", "game_run", form, -1, -1)
end
function on_btn_pichai_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  if not form.doing then
    return
  end
  if form.isAction then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_visual = nx_value("game_visual")
  local role = game_visual:GetSceneObj(client_player.Ident)
  if not nx_is_valid(role) then
    return
  end
  local action_module = nx_value("action_module")
  action_module:DoAction(role, "interact21")
  form.isAction = true
  form.ballPos = form.lbl_ball.Left
end
function on_btn_end_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form.doing = false
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_pichai", "game_run", form)
  form:Close()
  local PichaiGame = nx_value("PichaiGame")
  PichaiGame:SendError()
end
function set_level(maxCount, goodCount, speed)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_pichai")
  if not nx_is_valid(form) then
    return
  end
  form.speed = speed
  form.maxCount = maxCount
  form.needGood = goodCount
  form.lbl_remain.Text = nx_widestr(maxCount)
end
function game_run(form, param1, param2)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(game_client) then
    return
  end
  local role = game_visual:GetSceneObj(client_player.Ident)
  if not nx_is_valid(role) then
    return
  end
  if not form.doing then
    return
  end
  local left = form.mostLeft
  local right = form.mostRight
  local pos = form.lbl_ball.Left
  local direct = form.direct
  local offset = direct * form.lbl_4.Width * (form.speed / 100)
  local setPos = pos + offset
  if left > setPos then
    setPos = left
    form.direct = 1
  end
  if right <= setPos then
    setPos = right
    form.direct = -1
  end
  form.lbl_ball.Left = setPos
  local action_module = nx_value("action_module")
  local isact = form.isAction
  if isact then
    local ret = action_module:ActionFinished(role, "interact21")
    if ret then
      form.isAction = false
      add_num(form)
    end
  end
end
function on_end_game(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_pichai")
  if not nx_is_valid(form) then
    return
  end
  form.doing = false
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_pichai", "game_run", form)
  if res == 1 then
  elseif res == 2 then
  end
end
function add_num(form)
  local st = (form.mostLeft + form.mostRight) / 2
  local ed = st + (form.mostLeft + form.mostRight) / 4
  if st < form.ballPos and ed > form.ballPos then
    form.good = form.good + 1
  else
    form.bad = form.bad + 1
  end
  form.lbl_good.Text = nx_widestr(form.good)
  form.lbl_bad.Text = nx_widestr(form.bad)
  local remain_num = form.maxCount - form.good - form.bad
  form.lbl_remain.Text = nx_widestr(remain_num)
  if remain_num <= 0 then
    if form.good >= form.needGood then
      local PichaiGame = nx_value("PichaiGame")
      PichaiGame:SendResult()
    else
      local PichaiGame = nx_value("PichaiGame")
      PichaiGame:SendError()
    end
    return
  end
  if form.bad > form.maxCount - form.needGood then
    local PichaiGame = nx_value("PichaiGame")
    PichaiGame:SendError()
    return
  end
end
