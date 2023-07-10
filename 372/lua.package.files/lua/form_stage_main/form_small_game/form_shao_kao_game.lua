require("util_gui")
require("util_functions")
require("const_define")
require("share\\view_define")
require("game_object")
require("util_static_data")
require("const_define")
require("gui")
SUB_STC_OPEN_GAME_FORM = 1
SUB_STC_PLAY_OPEN = 2
SUB_STC_PLAY_CLOSE = 3
SUB_STC_RESULT_SUCCESS = 4
SUB_STC_RESULT_FAILED = 5
SUB_STC_CLOSE_GAME_FORM = 6
SUB_STC_GAME_RESULT = 7
SUB_CTS_START_GAME = 1
SUB_CTS_CANCEL_GAME = 2
SUB_STC_PLAY_SUCCEED = 3
SUB_STC_PLAY_FAILED = 4
function main_form_init(self)
  self.Fixed = true
  self.key_str = ""
  self.time = 0
  self.cur_par = 0
  self.max_par = 0
  self.speed = 0
  self.failed_num = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  InitGameXZ(self)
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.gamelevel = 1
  form.groupbox_time.Visible = false
  form.groupbox_key.Visible = true
  form.groupbox_6.Visible = true
  default_config(form)
  change_form_size()
end
function on_main_form_close(self)
  nx_execute("custom_sender", "custom_xjz_sk_game", SUB_CTS_CANCEL_GAME)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_star_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = form.gamelevel
  nx_execute("custom_sender", "custom_xjz_sk_game", SUB_CTS_START_GAME, level)
  btn.Visible = false
  form.lbl_rou.BackImage = "npm_xjz_kaorou_tips"
  form.lbl_huo.BackImage = "npm_xjz_dz_tips"
end
function get_skill()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILL))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  for i = 1, table.getn(viewobj_list) do
    local configID = viewobj_list[i]:QueryProp("ConfigID")
    if nx_string("xjz_01") == nx_string(configID) then
      return viewobj_list[i]:QueryProp("Level")
    end
  end
  return 0
end
function InitGameXZ(form)
  local level = get_skill()
  if level == 0 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, level do
    local rbtn = form.groupscrollbox_1:Find("rbtn_" .. nx_string(i))
    if not nx_is_valid(rbtn) then
      rbtn = gui:Create("RadioButton")
      rbtn.Name = "rbtn_" .. nx_string(i)
      rbtn.Width = 90
      rbtn.Height = 20
      rbtn.Font = "font_main"
      rbtn.ForeColor = "255,255,180,0"
      rbtn.NormalImage = get_treeview_bg(2, "out")
      rbtn.FocusImage = get_treeview_bg(2, "on")
      rbtn.CheckedImage = get_treeview_bg(2, "on")
      rbtn.Left = 5
      rbtn.Top = 23 * i - 10
      nx_bind_script(rbtn, nx_current())
      nx_callback(rbtn, "on_checked_changed", "on_checked_changed_btn")
    end
    rbtn.level = i
    rbtn.Text = nx_widestr("@Game_level_") .. nx_widestr(i)
    form.groupscrollbox_1:Add(rbtn)
  end
  local rbtn = form.groupscrollbox_1:Find("rbtn_" .. nx_string(1))
  rbtn.Checked = true
end
function on_checked_changed_btn(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gamelevel = btn.level
end
function get_treeview_bg(bglvl, bgtype)
  local path = "gui\\common\\treeview\\tree_" .. nx_string(bglvl) .. "_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function on_shao_kao_msg(...)
  local submsg = nx_int(arg[1])
  if nx_int(submsg) == nx_int(SUB_STC_OPEN_GAME_FORM) then
    form = util_get_form(nx_current(), true)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    form.Visible = true
  elseif nx_int(submsg) == nx_int(SUB_STC_PLAY_OPEN) then
    form = util_get_form(nx_current(), true)
    if not nx_is_valid(form) then
      return
    end
    form.time = nx_int(arg[2])
    form.key_str = nx_string(arg[3])
    start_game(form)
  elseif nx_int(submsg) == nx_int(SUB_STC_PLAY_CLOSE) then
    close_game_form()
  elseif nx_int(submsg) == nx_int(SUB_STC_RESULT_SUCCESS) then
    local form = util_get_form(nx_current(), false)
    if not nx_is_valid(form) then
      return
    end
    form.ani_vic2.Visible = true
    form.ani_vic1.Visible = true
    form.ani_vic1.Loop = false
    form.ani_vic1.PlayMode = 2
    form.ani_vic1:Play()
  elseif nx_int(submsg) == nx_int(SUB_STC_RESULT_FAILED) then
    local form = util_get_form(nx_current(), false)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_6.Visible = true
    local failed_num = nx_int(arg[2])
    if nx_int(1) == nx_int(failed_num) then
      form.lbl_14.BackImage = "gui\\special\\shao_kao_game\\tip\\life_down.png"
    elseif nx_int(2) == nx_int(failed_num) then
      form.lbl_15.BackImage = "gui\\special\\shao_kao_game\\tip\\life_down.png"
    end
    form.failed_num = failed_num
    form.ani_lost2.Visible = true
    form.ani_lost1.Visible = true
    form.ani_lost1.Loop = false
    form.ani_lost1.PlayMode = 2
    form.ani_lost1:Play()
  elseif nx_int(submsg) == nx_int(SUB_STC_CLOSE_GAME_FORM) then
    local form = util_get_form(nx_current(), false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  elseif nx_int(submsg) == nx_int(SUB_STC_GAME_RESULT) then
    local form = util_get_form(nx_current(), false)
    if not nx_is_valid(form) then
      return
    end
    local res = nx_int(arg[2])
    showResult(form, res)
  end
end
function on_key_up(key_value)
  local form = util_get_form(nx_current(), false)
  if not nx_is_valid(form) then
    return
  end
  local key = ""
  if nx_int(key_value) == nx_int(87) or nx_int(key_value) == nx_int(38) then
    key = "W"
  elseif nx_int(key_value) == nx_int(65) or nx_int(key_value) == nx_int(37) then
    key = "A"
  elseif nx_int(key_value) == nx_int(83) or nx_int(key_value) == nx_int(40) then
    key = "S"
  elseif nx_int(key_value) == nx_int(68) or nx_int(key_value) == nx_int(39) then
    key = "D"
  elseif nx_int(key_value) == nx_int(74) then
    key = "J"
  elseif nx_int(key_value) == nx_int(75) then
    key = "K"
  elseif nx_int(key_value) == nx_int(76) then
    key = "L"
  end
  if key == "" then
    return
  end
  local key_count = form.imagegrid_key.ClomnNum
  for index = 0, key_count - 1 do
    local dance_flag = form.imagegrid_key:GetItemMark(index)
    if nx_int(dance_flag) == nx_int(0) then
      if nx_ws_equal(nx_widestr(key), nx_widestr(form.imagegrid_key:GetItemName(index))) then
        form.imagegrid_key:SetItemMark(index, 1)
        do
          local photo = "gui\\special\\shao_kao_game\\tip\\" .. nx_string(key) .. "_1.png"
          form.imagegrid_key:SetItemImage(index, photo)
          if nx_int(index) == nx_int(key_count - 1) then
            nx_execute("custom_sender", "custom_xjz_sk_game", SUB_STC_PLAY_SUCCEED)
            close_game_form()
          end
        end
        break
      end
      for i = 0, key_count - 1 do
        local image_key = form.imagegrid_key:GetItemName(i)
        local photo = "gui\\special\\shao_kao_game\\tip\\" .. nx_string(image_key) .. ".png"
        form.imagegrid_key:SetItemMark(i, 0)
        form.imagegrid_key:SetItemImage(i, photo)
      end
      break
    end
  end
end
function roll_text(form)
  if not nx_is_valid(form) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  common_execute:RemoveExecute("ShaoKaoTimer", form)
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("ShaoKaoTimer", form, nx_float(0.03), nx_current())
  end
end
function start_game(form)
  default_config(form)
  form.groupbox_time.Visible = true
  form.imagegrid_key.Visible = true
  roll_text(form)
  on_refresh_picture(form)
end
function close_game_form()
  form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  common_execute:RemoveExecute("ShaoKaoTimer", form)
  form.pbar_time.Maximum = 100
  form.pbar_time.Value = 0
  form.speed = nx_number(form.pbar_time.Maximum / (form.time / 0.03))
  form.cur_par = 0
  form.max_par = 0
  form.groupbox_time.Visible = false
  form.groupbox_key.Visible = true
  form.imagegrid_key.Visible = false
end
function on_time_over(form)
  if not nx_is_valid(form) then
    return
  end
  close_game_form(form)
end
function on_refresh_picture(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_key:Clear()
  local pic_num = string.len(form.key_str)
  form.imagegrid_key.ClomnNum = pic_num
  local view_left = (form.imagegrid_key.Width - form.imagegrid_key.GridWidth * pic_num) / 2
  local view_right = view_left + form.imagegrid_key.GridWidth * pic_num
  form.imagegrid_key.ViewRect = nx_string(view_left) .. ",8," .. nx_string(view_right) .. ",8"
  form.view_left = nx_int(view_left)
  for i = 1, pic_num do
    local key = string.char(string.byte(form.key_str, i, i))
    local photo = "gui\\special\\shao_kao_game\\tip\\" .. nx_string(key) .. ".png"
    form.imagegrid_key:AddItem(i - 1, photo, 0, 1, -1)
    form.imagegrid_key:SetItemName(i - 1, nx_widestr(nx_string(key)))
    form.imagegrid_key:SetItemMark(i - 1, 0)
    if nx_int(i) == nx_int(1) then
      if nx_string("W") == nx_string(key) then
        form.ani_1.Visible = true
      elseif nx_string("S") == nx_string(key) then
        form.ani_2.Visible = true
      elseif nx_string("A") == nx_string(key) then
        form.ani_3.Visible = true
      elseif nx_string("D") == nx_string(key) then
        form.ani_4.Visible = true
      end
    end
  end
end
function showResult(form, res)
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  form.groupbox_main.Visible = false
  Label.AutoSize = true
  Label.Name = "lab_res"
  if nx_int(res) == nx_int(1) then
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\xjz_minigame\\kaishi\\victory.png"
    Label.AbsTop = (gui.Height - Label.Height) / 2
  else
    Label.BackImage = "gui\\language\\ChineseS\\minigame\\xjz_minigame\\kaishi\\lost.png"
    Label.AbsTop = (gui.Height - Label.Height) / 2
  end
  local timer = nx_value("timer_game")
  timer:Register(2500, -1, nx_current(), "auto_close_form", form, 1, -1)
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
end
function default_config(form)
  form.pbar_time.Maximum = 100
  form.pbar_time.Value = 0
  form.speed = nx_number(form.pbar_time.Maximum / (form.time / 0.03))
  form.cur_par = 0
  form.max_par = 0
  form.ani_1.Visible = false
  form.ani_2.Visible = false
  form.ani_3.Visible = false
  form.ani_4.Visible = false
  form.ani_vic1.Visible = false
  form.ani_vic1.Loop = false
  form.ani_vic2.Visible = false
  form.ani_vic2.Loop = false
  form.ani_lost1.Visible = false
  form.ani_lost1.Loop = false
  form.ani_lost2.Visible = false
  form.ani_lost2.Loop = false
end
function change_form_size()
  local form = util_get_form(nx_current(), false)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.AbsLeft = 0
    form.AbsTop = 0
    form.Width = gui.Width
    form.Height = gui.Height
    form.groupbox_back.Left = 0
    form.groupbox_back.Top = 0
    form.groupbox_back.Width = gui.Width
    form.groupbox_back.Height = gui.Height
    form.groupbox_main.AbsLeft = (gui.Width - form.groupbox_main.Width) / 2
    form.groupbox_main.AbsTop = (gui.Height - form.groupbox_main.Height) / 5 * 2
  end
end
function auto_close_form(form)
  console_log("end")
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "auto_close_form", form)
  form:Close()
end
function on_ani_animation_end(ani)
end
function animation_key_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
