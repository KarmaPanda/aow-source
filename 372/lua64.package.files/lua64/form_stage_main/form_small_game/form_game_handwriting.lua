require("const_define")
require("util_functions")
local table_group_word = {}
local table_group_word_height = {}
local groupbox_total_width = 0
local progress_tag = 1
local formula_id = ""
function main_form_init(self)
  self.Fixed = true
  self.ratio = 1
end
function on_main_form_open(self)
  nx_execute("gui", "gui_close_allsystem_form")
  refresh_form_pos(self)
  on_reset_ball(self)
  set_allow_control(false)
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
  local Width = form.groupbox_word.Width
  local Height = form.groupbox_word.Height
  if Width < Height then
    form.lbl_name.Left = (gui.Width - form.lbl_name.Width) / 2 - 370
    form.lbl_name.Top = gui.Width / 10
    form.mltbox_desc.Left = gui.Width / 2 + 250
    form.mltbox_desc.Top = gui.Height / 2 + 50
  else
    form.lbl_name.Left = (gui.Width - form.lbl_name.Width) / 2
    form.lbl_name.Top = gui.Width / 10 - 50
    form.mltbox_desc.Left = gui.Width / 2 + 300
    form.mltbox_desc.Top = gui.Height / 2 + 200
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_handwriting", "on_update_ball", form)
  form:Close()
  local HandwritingGame = nx_value("HandwritingGame")
  HandwritingGame:SendError()
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  set_allow_control(true)
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_handwriting", nx_null())
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if nx_is_valid(form) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_handwriting", "on_update_ball", form)
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
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_handwriting", "on_update_ball", form)
    form:Close()
    local HandwritingGame = nx_value("HandwritingGame")
    HandwritingGame:SendError()
  end
end
function on_reset_ball(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_ball.Left = form.groupbox_sbg.Width / 2 - form.lbl_ball.Width / 2
  form.lbl_pen.Visible = false
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  on_reset_ball(form)
  local HandwritingGame = nx_value("HandwritingGame")
  if not nx_is_valid(HandwritingGame) then
    return
  end
  HandwritingGame:InitGame()
  HandwritingGame:SetIsInGame(true)
  btn.Visible = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(100, -1, "form_stage_main\\form_small_game\\form_game_handwriting", "on_update_ball", form, -1, -1)
end
function set_backimage(image)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local width = gui.Width * 0.8
  form.groupbox_word.AutoSize = true
  form.groupbox_word.BackImage = image
  local ratio = 1
  if width < form.groupbox_word.Width then
    ratio = width / form.groupbox_word.Width
    form.groupbox_word.AutoSize = false
    form.groupbox_word.Width = width
  end
  form.ratio = ratio
  form.groupbox_main.Width = form.groupbox_word.Width
  form.groupbox_main.Height = form.groupbox_word.Height + form.groupbox_sbg.Height
  form.groupbox_word.Left = 0
  form.groupbox_word.Top = 0
  form.groupbox_sbg.Left = (form.groupbox_main.Width - form.groupbox_sbg.Width) / 2
  form.groupbox_sbg.Top = form.groupbox_word.Height
  form.btn_start.Left = form.groupbox_main.Width - 150
  form.btn_start.Top = form.groupbox_word.Height
  form.btn_close.Left = form.groupbox_main.Width - 100
  form.btn_close.Top = 70
  form.btn_help.Left = form.groupbox_main.Width - 100
  form.btn_help.Top = 130
  refresh_form_pos(form)
end
function set_btn_pos(close_btn_pos, help_btn_pos, start_btn_pos)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  local init_left = form.groupbox_word.AbsLeft
  local init_top = form.groupbox_word.AbsTop
  local ratio = form.ratio
  if nx_string(close_btn_pos) ~= "" then
    local table_close = util_split_string(close_btn_pos, ",")
    if table.getn(table_close) == 2 then
      form.btn_close.Left = init_left + nx_number(table_close[1]) * ratio
      form.btn_close.Top = init_top + nx_number(table_close[2])
    end
  end
  if nx_string(help_btn_pos) ~= "" then
    local table_help = util_split_string(help_btn_pos, ",")
    if table.getn(table_help) == 2 then
      form.btn_help.Left = init_left + nx_number(table_help[1]) * ratio
      form.btn_help.Top = init_top + nx_number(table_help[2])
    end
  end
  if nx_string(start_btn_pos) ~= "" then
    local table_start = util_split_string(start_btn_pos, ",")
    if table.getn(table_start) == 2 then
      form.btn_start.Left = nx_number(table_start[1]) * ratio
      form.btn_start.Top = nx_number(table_start[2])
    end
  end
end
function set_wordimage(image, distance, pic_top)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
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
  local ratio = form.ratio
  distance = distance * ratio
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
    lbl_pic.DrawMode = "FitWindow"
    lbl_pic.BackImage = table_wordimage[i]
    lbl_pic.Left = 0
    lbl_pic.Top = 0
    lbl_pic.AutoSize = false
    lbl_pic.Width = lbl_pic.Width * ratio
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
  form.lbl_pen.Parent:ToFront(form.lbl_pen)
end
function set_pen_type(pen_type)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  pen_type = nx_int(pen_type)
  if pen_type == 1 then
    form.lbl_pen.BackImage = "handwriting_pen2"
  else
    form.lbl_pen.BackImage = "handwriting_pen1"
  end
end
function set_game_name(name)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  formula_id = name
  if formula_id == nil or formula_id == "" then
    return
  end
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  if not nx_is_valid(iniformula) then
    return 0
  end
  local porduct_item_index = iniformula:FindSectionIndex(nx_string(formula_id))
  if porduct_item_index < 0 then
    return 0
  end
  local porduct_item = iniformula:ReadString(porduct_item_index, "ComposeResult", "")
  local item_name = gui.TextManager:GetFormatText(porduct_item)
  form.lbl_name.Text = nx_widestr(item_name)
  local item_info = gui.TextManager:GetFormatText("desc_" .. porduct_item)
  local addtext = nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(item_name) .. nx_widestr("</font><br>") .. nx_widestr(item_info)
  form.mltbox_desc:AddHtmlText(addtext, nx_int(-1))
end
function set_help_text(text)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  form.helptext = nx_string(text)
end
function on_btn_left_click(btn)
  local HandwritingGame = nx_value("HandwritingGame")
  if HandwritingGame == nil or not nx_is_valid(HandwritingGame) then
    return
  end
  HandwritingGame:LeftDown()
end
function on_btn_right_click(btn)
  local HandwritingGame = nx_value("HandwritingGame")
  if HandwritingGame == nil or not nx_is_valid(HandwritingGame) then
    return
  end
  HandwritingGame:RightDown()
end
function on_update_ball(form, param1, param2)
  local HandwritingGame = nx_value("HandwritingGame")
  if HandwritingGame == nil or not nx_is_valid(HandwritingGame) then
    return
  end
  HandwritingGame:UpDateGame()
end
function update_game(current_pos, current_pro)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
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
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox.Visible = true
  groupbox.Height = progress + 1
  if progress >= table_group_word_height[progress_tag] then
    progress_tag = progress_tag + 1
  end
  form.lbl_pen.Left = groupbox.Left + groupbox.Width / 2
  form.lbl_pen.Top = groupbox.Top + groupbox.Height
end
function on_game_end(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_handwriting", "on_update_ball", form)
  form.groupbox_main.Visible = false
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  Label.AutoSize = true
  Label.Name = "lab_res"
  local victory = "gui\\language\\ChineseS\\minigame\\victory.png"
  local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  local sfile = ""
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = (gui.Height - Label.Height) / 2 - Label.Height - 40
    sfile = "snd\\action\\minigame\\qinshi\\7110_5.wav"
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
    sfile = "snd\\action\\minigame\\qinshi\\7110_6.wav"
  end
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  play_sound("sound_qingame", sfile)
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_handwriting", "auto_close_form", form, -1, -1)
end
function auto_close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function game_key_down(gui, key, shift, ctrl)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
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
  if key == "Esc" then
    show_close_dialog(form)
  end
end
function on_tbar_1_value_changed(self)
  local groupbox = self.ParentForm.groupbox_back
  if self.Value >= 0 and self.Value <= 100 then
    groupbox.BlendAlpha = 255 * self.Value / 100
  end
end
function on_btn_help_click(self)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
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
    multitextbox.HtmlText = nx_widestr(gui.TextManager:GetText(form.helptext))
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
  local form = nx_value("form_stage_main\\form_small_game\\form_game_handwriting")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
function set_allow_control(allow)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.AllowControl = allow
end
function play_sound(flag, filename)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not gui:FindSound(nx_string(flag)) then
    gui:AddSound(nx_string(flag), nx_resource_path() .. nx_string(filename))
  end
  gui:PlayingSound(nx_string(flag))
end
