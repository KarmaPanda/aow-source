require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_small_game\\form_game_question"
local timelimit = 20
local formtimelimit = 0
count = 10
rightnum = 6
local questionlist = {}
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.is_start = false
  self.ani_right.Top = nx_int(self.anitop)
  self.ani_right.Left = nx_int(self.anileft)
  self.ani_wrong.Top = nx_int(self.anitop)
  self.ani_wrong.Left = nx_int(self.anileft)
  self.ani_right.Visible = false
  self.ani_wrong.Visible = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_form_time", self, -1, -1)
end
function on_update_form_time(form)
  if nx_int(form.formtimelimit) == nx_int(0) then
    close_form()
    return
  end
  form.formtimelimit = nx_widestr(nx_int(form.formtimelimit) - 1)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", self)
    timer:UnRegister(nx_current(), "on_update_form_time", self)
  end
  local ret = check_result()
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 1, nx_int(ret))
  nx_destroy(self)
end
function open_form_by_diff(diff)
  if load_resource(diff) == false then
    return
  end
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  init_form()
  form.Visible = true
  form:Show()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_start_click(btn)
  btn.ParentForm.is_start = 1
  local form = btn.ParentForm
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  btn.Visible = false
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_ok_click(btn)
  close_form()
end
function on_update_time(form)
  if nx_int(form.lbl_time.Text) == nx_int(0) then
    close_form()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(form.lbl_time.Text) - 1)
  form.pbar_1.Value = nx_int(form.lbl_time.Text)
end
function load_resource(diff)
  local ini = get_ini("share\\Life\\QuestionGame.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(diff))
  if sec_index < 0 then
    return false
  end
  timelimit = ini:ReadInteger(sec_index, "timelimit", 0)
  formtimelimit = ini:ReadInteger(sec_index, "formtimelimit", 0)
  count = ini:ReadInteger(sec_index, "count", 0)
  rightnum = ini:ReadInteger(sec_index, "rightnum", 0)
  anileft = ini:ReadInteger(sec_index, "anileft", 0)
  anitop = ini:ReadInteger(sec_index, "anitop", 0)
  questionlist = {}
  for i = 1, 50 do
    local question = ini:ReadString(sec_index, "question" .. nx_string(i), "")
    if nx_string(question) == nx_string("") then
      break
    end
    table.insert(questionlist, nx_string(question))
    local rand = math.random(1, nx_number(table.getn(questionlist)))
    local temp = questionlist[rand]
    questionlist[rand] = questionlist[table.getn(questionlist)]
    questionlist[table.getn(questionlist)] = temp
  end
  return true
end
function init_form()
  init_bind_callback()
  init_time()
  show_question(1)
end
function on_btn_s_click(btn)
  local form = btn.ParentForm
  if not form.is_start then
    return
  end
  if nx_int(form.right_index) == nx_int(btn.DataSource) then
    form.lbl_right.Text = nx_widestr(nx_int(form.lbl_right.Text) + nx_int(1))
    form.ani_right.Visible = true
    form.ani_right.PlayMode = 2
    form.ani_right:Play()
    if nx_int(form.lbl_right.Text) == nx_int(rightnum) then
      close_form()
      return
    end
  else
    form.ani_wrong.Visible = true
    form.ani_wrong.PlayMode = 2
    form.ani_wrong:Play()
  end
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_timer_shut_tip", form)
  timer:Register(300, 1, nx_current(), "on_timer_shut_tip", form, -1, -1)
  form.lbl_current.Text = nx_widestr(nx_int(form.lbl_current.Text) + nx_int(1))
  if nx_int(form.lbl_current.Text) == nx_int(count) then
    close_form()
    return
  end
  show_question(nx_int(form.lbl_current.Text))
end
function on_timer_shut_tip(form)
  if form.ani_right.Visible == true then
    form.ani_right.Visible = false
  else
    form.ani_wrong.Visible = false
  end
end
function init_bind_callback()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  nx_bind_script(form.btn_close, nx_current())
  nx_callback(form.btn_close, "on_click", "on_btn_close_click")
  nx_bind_script(form.btn_start, nx_current())
  nx_callback(form.btn_start, "on_click", "on_btn_start_click")
  nx_bind_script(form.btn_s_1, nx_current())
  nx_callback(form.btn_s_1, "on_click", "on_btn_s_click")
  nx_bind_script(form.btn_s_2, nx_current())
  nx_callback(form.btn_s_2, "on_click", "on_btn_s_click")
end
function init_time()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.anitop = anitop
  form.anileft = anileft
  form.lbl_time.Text = nx_widestr(timelimit)
  form.formtimelimit = formtimelimit
  form.pbar_1.Maximum = timelimit
  form.pbar_1.Minimum = 0
  form.pbar_1.Value = timelimit
end
function show_question(index)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) > nx_int(count) then
    close_form()
  end
  if nx_int(index) > nx_int(table.getn(questionlist)) then
    close_form()
  end
  local question_str = questionlist[nx_number(index)]
  local question_table = util_split_string(nx_string(question_str), ",")
  local q = question_table[1]
  local s1 = question_table[2]
  local s2 = question_table[3]
  local right_index = question_table[4]
  form.mltbox_question:Clear()
  form.mltbox_question:AddHtmlText(nx_widestr(util_text(q)), -1)
  form.btn_s_1.Text = nx_widestr(util_text(s1))
  form.btn_s_2.Text = nx_widestr(util_text(s2))
  form.lbl_current.Text = nx_widestr(index)
  form.lbl_left.Text = nx_widestr(nx_int(count) - nx_int(index))
  form.right_index = nx_int(right_index)
end
function check_result()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.lbl_right.Text) >= nx_int(rightnum) then
    return 1
  end
  return 0
end
function custom_sender(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(773), unpack(arg))
end
