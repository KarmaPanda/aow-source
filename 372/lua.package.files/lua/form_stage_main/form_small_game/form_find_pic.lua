require("const_define")
require("util_functions")
local chance = {
  5,
  3,
  2,
  1
}
local tests = {
  8,
  10,
  15,
  25
}
local total_time_limit = {
  70,
  65,
  75,
  80
}
local per_time_limit = {
  10,
  8,
  6,
  4
}
local pic_amount = {
  10,
  15,
  20,
  25
}
function main_form_init(form)
  picini = nx_execute("util_functions", "get_ini", "ini\\ui\\minigame\\findpic.ini")
  if not nx_is_valid(picini) then
    nx_msgbox("ini\\ui\\minigame\\findpic.ini " .. get_msg_str("msg_120"))
  end
  nx_set_value("picini", picini)
  if nx_is_valid(picini) then
    picbase = picini:GetItemList("path")
  end
  local gui = nx_value("gui")
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  for i = 1, 5 do
    local top = 60 + (i - 1) * 100
    for j = 1, 5 do
      local left = 32 + (j - 1) * 100
      local button = gui:Create("Button")
      button.Left = left
      button.Top = top
      button.Width = 68
      button.Height = 92
      button.Visible = flase
      local index = (i - 1) * 5 + j
      button.Name = "button" .. index
      nx_bind_script(button, nx_current())
      nx_callback(button, "on_click", "on_choose_click")
      form:Add(button)
    end
  end
  return 1
end
function on_main_form_open(form)
  form.lbl_timer_per.Visible = false
end
function on_main_form_close(form)
  stop_timer(form)
  nx_destroy(form)
end
function random_pic(times)
  if table.getn(picbase) < 1 then
    return
  end
  for i = 1, game_tests do
    local index1 = math.random(table.getn(picbase))
    local index2 = math.random(table.getn(picbase))
    picbase[index1], picbase[index2] = picbase[index2], picbase[index1]
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_btn_start_click(btn)
  game_flag = true
  local form = btn.Parent
  form.lbl_tips.BackImage = "gui\\animations\\face\\bq011_01.png"
  for i = 1, 5 do
    local lblname = "lbl_life" .. i
    local lbl = form:Find(lblname)
    lbl.BackImage = "gui\\animations\\tip\\Hole.png"
  end
  local level = 1
  if form.rbtn_level1.Checked then
    level = 1
  elseif form.rbtn_level2.Checked then
    level = 2
  elseif form.rbtn_level3.Checked then
    level = 3
  elseif form.rbtn_level4.Checked then
    level = 4
  end
  game_chance = chance[level]
  game_tests = tests[level]
  game_total_time = total_time_limit[level]
  game_per_time = per_time_limit[level]
  game_pic_amount = pic_amount[level]
  for i = 1, game_chance do
    local lblname = "lbl_life" .. i
    local lbl = form:Find(lblname)
    lbl.BackImage = "gui\\animations\\tip\\Implant15.png"
  end
  form.lbl_game_tests.Text = nx_widestr(game_tests)
  refresh_pic(game_pic_amount)
  form.lbl_timer.Visible = true
  local timer = nx_value(GAME_TIMER)
  nx_execute(nx_current(), "on_update_time", form, level)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, level, -1)
end
function refresh_pic(amount)
  random_pic(10)
  local cur_pic_base = {}
  local form = nx_value("form_find_pic")
  for i = 1, 25 do
    local name = "button" .. i
    local abutton = form:Find(name)
    abutton.Visible = false
  end
  for i = 1, amount do
    if i > table.getn(picbase) then
      break
    end
    cur_pic_base[i] = picbase[i]
    local buttonname = "button" .. i
    local button = form:Find(buttonname)
    button.BackImage = picbase[i]
    button.Visible = true
  end
  local pos = math.random(1, table.getn(cur_pic_base))
  local answer_pic = cur_pic_base[pos]
  form.pbar_show.ProgressImage = answer_pic
  form.pbar_show.Value = 0
end
function on_update_time(form, level)
  game_total_time = game_total_time - 1
  game_per_time = game_per_time - 1
  form.lbl_timer.Text = nx_widestr(game_total_time)
  form.lbl_timer_per.Text = nx_widestr(game_per_time)
  if game_total_time <= 0 then
    stop_timer(form)
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_09.png"
    return
  end
  form.pbar_show.Value = form.pbar_show.Value + math.floor(100 / per_time_limit[level])
  if form.pbar_show.Value >= 100 then
    game_tests = game_tests - 1
    form.lbl_game_tests.Text = nx_widestr(game_tests)
    form.pbar_show.Value = 0
    local lbl = form:Find("lbl_life" .. game_chance)
    lbl.BackImage = "gui\\animations\\tip\\Hole.png"
    game_chance = game_chance - 1
    if 0 >= game_chance then
      stop_timer(form)
      form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_09.png"
      return
    end
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq047_01.png"
    refresh_pic(game_pic_amount)
  end
end
function stop_timer(form)
  game_flag = false
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
end
function on_choose_click(self)
  if game_flag == false then
    return
  end
  local form = self.Parent
  game_tests = game_tests - 1
  form.lbl_game_tests.Text = nx_widestr(game_tests)
  if game_tests <= 0 then
    stop_timer(form)
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq050_01.png"
    return
  end
  local temp1 = nx_string(self.BackImage)
  local temp2 = nx_string(form.pbar_show.ProgressImage)
  if temp1 == temp2 then
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq055_01.png"
    refresh_pic(game_pic_amount)
  else
    local lbl = form:Find("lbl_life" .. game_chance)
    lbl.BackImage = "gui\\animations\\tip\\Hole.png"
    game_chance = game_chance - 1
    if 0 >= game_chance then
      stop_timer(form)
      form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_09.png"
      return
    end
    form.lbl_tips.BackImage = "gui\\animations\\face\\bq061_03.png"
  end
end
