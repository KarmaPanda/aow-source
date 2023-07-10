require("const_define")
require("util_functions")
local table_group_word = {}
local table_group_word_height = {}
local groupbox_total_width = 0
local progress_tag = 1
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  refresh_form_pos(self)
  on_reset_ball(self)
  nx_execute("gui", "gui_close_allsystem_form")
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_back.AbsLeft = 0
  form.groupbox_back.AbsTop = 0
  form.groupbox_back.Width = gui.Width
  form.groupbox_back.Height = gui.Height
  form.groupbox_main.AbsLeft = (gui.Width - form.groupbox_main.Width) / 2
  form.groupbox_main.AbsTop = (gui.Height - form.groupbox_main.Height) / 2
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  refresh_form_pos(form)
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_ride", nx_null())
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if nx_is_valid(form) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_ride", "on_update_ball", form)
    form:Close()
  end
end
function show_close_dialog(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_ride", "on_update_ball", form)
    form:Close()
    local RideGame = nx_value("RideGame")
    RideGame:SendError()
  end
end
function on_reset_ball(form)
  form.lbl_ball.Left = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
  form.lbl_pen.Visible = false
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  on_reset_ball(form)
  local RideGame = nx_value("RideGame")
  if not nx_is_valid(RideGame) then
    return
  end
  RideGame:InitGame()
  RideGame:SetIsInGame(true)
  btn.Visible = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(100, -1, "form_stage_main\\form_small_game\\form_game_ride", "on_update_ball", form, -1, -1)
end
function set_backimage(image)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_word.AutoSize = true
  form.groupbox_word.BackImage = image
  refresh_form_pos(form)
end
function set_btn_pos(close_btn_pos, help_btn_pos, start_btn_pos)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  if nx_string(close_btn_pos) ~= "" then
    local table_close = util_split_string(close_btn_pos, ",")
    if table.getn(table_close) == 2 then
      form.btn_close.Left = nx_number(table_close[1])
      form.btn_close.Top = nx_number(table_close[2])
    end
  end
  if nx_string(help_btn_pos) ~= "" then
    local table_help = util_split_string(help_btn_pos, ",")
    if table.getn(table_help) == 2 then
      form.btn_help.Left = nx_number(table_help[1])
      form.btn_help.Top = nx_number(table_help[2])
    end
  end
  if nx_string(start_btn_pos) ~= "" then
    local table_start = util_split_string(start_btn_pos, ",")
    if table.getn(table_start) == 2 then
      form.btn_start.Left = nx_number(table_start[1])
      form.btn_start.Top = nx_number(table_start[2])
    end
  end
end
function set_wordimage(image, distance, pic_top)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  local table_wordimage = util_split_string(image, ",")
  local image_num = table.getn(table_wordimage)
  if image_num == 0 then
    return
  end
  table_group_word = {}
  table_group_word_height = {}
  groupbox_total_width = 0
  progress_tag = 1
  local width_total = 0
  for i = 1, image_num do
    local groupbox = gui:Create("GroupBox")
    form.groupbox_word:Add(groupbox)
    groupbox.Name = "groupbox_image" .. nx_string(i)
    groupbox.Text = ""
    groupbox.AutoSize = false
    groupbox.NoFrame = true
    groupbox.BackColor = "0,0,0,0"
    groupbox.Visible = false
    local lbl_pic = gui:Create("Label")
    groupbox:Add(lbl_pic)
    lbl_pic.Name = "lbl_image" .. nx_string(i)
    lbl_pic.BackColor = "0,0,0,0"
    lbl_pic.Text = ""
    lbl_pic.AutoSize = true
    lbl_pic.DrawMode = Tile
    lbl_pic.BackImage = table_wordimage[i]
    lbl_pic.Left = 0
    lbl_pic.Top = 0
    groupbox.Left = 0
    groupbox.Top = 0
    groupbox.Width = lbl_pic.Width
    groupbox.Height = 0
    width_total = width_total + lbl_pic.Width + distance
    groupbox_total_width = groupbox_total_width + lbl_pic.Height
    table.insert(table_group_word, groupbox)
    table.insert(table_group_word_height, lbl_pic.Height)
  end
  width_total = width_total - distance
  local init_left = (form.groupbox_word.Width - width_total) / 2
  for j = image_num, 1, -1 do
    local groupbox_temp = table_group_word[j]
    groupbox_temp.Left = init_left
    groupbox_temp.Top = pic_top
    init_left = init_left + groupbox_temp.Width + distance
  end
end
function on_btn_left_click(btn)
  local RideGame = nx_value("RideGame")
  if RideGame == nil or not nx_is_valid(RideGame) then
    return
  end
  RideGame:LeftDown()
end
function on_btn_right_click(btn)
  local RideGame = nx_value("RideGame")
  if RideGame == nil or not nx_is_valid(RideGame) then
    return
  end
  RideGame:RightDown()
end
function on_update_ball(form, param1, param2)
  local RideGame = nx_value("RideGame")
  if RideGame == nil or not nx_is_valid(RideGame) then
    return
  end
  RideGame:UpDateGame()
end
function update_game(current_pos, current_pro)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  if 100 <= current_pro then
    form.lbl_pen.Visible = false
    return
  end
  if current_pos <= -100 or 100 <= current_pos then
    form.lbl_pen.BackImage = "Snsmain_Ink_Zuo"
    return
  end
  form.lbl_pen.Visible = true
  local nDeltaLeft = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
  local pos = nDeltaLeft * current_pos / 100
  form.lbl_ball.Left = nDeltaLeft + pos
  local progress = groupbox_total_width * current_pro / 100
  if progress_tag > table.getn(table_group_word_height) then
    return
  end
  if progress_tag > table.getn(table_group_word) then
    return
  end
  for i = 1, progress_tag - 1 do
    progress = progress - table_group_word_height[i]
  end
  local groupbox = table_group_word[progress_tag]
  groupbox.Visible = true
  groupbox.Height = progress + 1
  if progress >= table_group_word_height[progress_tag] then
    progress_tag = progress_tag + 1
  end
  form.lbl_pen.Left = groupbox.Left + (groupbox.Width - form.lbl_pen.Width) / 2
  form.lbl_pen.Top = groupbox.Top + groupbox.Height
end
function on_game_end(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_ride", "on_update_ball", form)
  form.groupbox_main.Visible = false
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  Label.AutoSize = true
  Label.Name = "lab_res"
  local victory = "gui\\language\\ChineseS\\minigame\\victory.png"
  local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = (gui.Height - Label.Height) / 2 - Label.Height - 40
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
  end
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_ride", "auto_close_form", form, -1, -1)
end
function auto_close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function game_key_down(gui, key, shift, ctrl)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  if shift or ctrl then
    return
  end
  if key == "A" or key == "Left" then
    on_btn_left_click(form.btn_left)
    return
  end
  if key == "D" or key == "Right" then
    on_btn_right_click(form.btn_right)
    return
  end
end
function on_tbar_1_value_changed(self)
  local groupbox = self.ParentForm.groupbox_back
  if self.Value >= 0 and self.Value <= 100 then
    groupbox.BlendAlpha = 255 * self.Value / 100
  end
end
function on_btn_help_click(self)
  groupbox = self.Parent
  local groupboxhelp = groupbox:Find("groupbox_help")
  if not nx_is_valid(groupboxhelp) then
    local gui = nx_value("gui")
    groupboxhelp = gui:Create("GroupBox")
    groupboxhelp.AutoSize = true
    groupboxhelp.Name = "groupbox_help"
    groupboxhelp.BackImage = "gui\\language\\ChineseS\\minigame\\gamehelp.png"
    groupboxhelp.AbsLeft = (groupbox.Width - groupboxhelp.Width) / 2
    groupboxhelp.AbsTop = (groupbox.Height - groupboxhelp.Height) / 2
    local button = gui:Create("Button")
    local closebutton = groupbox:Find("btn_close")
    button.AutoSize = true
    button.NormalImage = closebutton.NormalImage
    button.FocusImage = closebutton.FocusImage
    button.PushImage = closebutton.PushImage
    button.AbsLeft = groupboxhelp.Width - button.Width - 30
    button.AbsTop = 30
    nx_bind_script(button, nx_current(), "")
    nx_callback(button, "on_click", "on_close_helpbox")
    local multitextbox = gui:Create("MultiTextBox")
    multitextbox.AutoSize = true
    multitextbox.AbsLeft = 40
    multitextbox.AbsTop = button.AbsTop + button.Height + 30
    multitextbox.Width = groupboxhelp.Width - 80
    multitextbox.Height = groupboxhelp.Height - 70 - button.Height
    multitextbox.MouseInBarColor = "0,0,0,0"
    multitextbox.ViewRect = nx_string("0,0," .. nx_string(multitextbox.Width) .. "," .. nx_string(multitextbox.Height))
    multitextbox.BackColor = "0,0,0,0"
    multitextbox.LineColor = "0,0,0,0"
    multitextbox.SelectBarColor = "0,0,0,0"
    multitextbox.TextColor = "255,0,0,0"
    multitextbox.HtmlText = nx_widestr(util_text("talk_spa_0101"))
    groupboxhelp:Add(multitextbox)
    groupboxhelp:Add(button)
    groupbox:Add(groupboxhelp)
  else
    groupboxhelp.Visible = true
  end
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_ride")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
