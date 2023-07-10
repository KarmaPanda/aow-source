require("const_define")
require("gui")
require("util_functions")
local FORM_MAIN = "form_stage_main\\form_small_game\\form_game_sjy_army"
local INI_FILE = "share\\Life\\SJYArmyGame.ini"
local DEBUG_MODE = true
local ELAPSE_MILLSEC = 16
local DEFAULT_MIN_SPEED = 0.1
local DEFAULT_MAX_SPEED = 0.3
local DEFAULT_WAY = 6
local ACCELERATION = 1.3
local ELE_PREPARE = 1
local ELE_SHOW = 2
local ELE_DEAD = 3
local ELE_CLICKED = 4
local OPEN = 1
local CLOSE = 2
local DELAY_CLOSE_WIN = 3
local DELAY_CLOSE_LOSE = 4
function open_form(show_type)
  if show_type == OPEN and not util_is_form_visible(FORM_MAIN) then
    util_auto_show_hide_form(FORM_MAIN)
  elseif show_type == CLOSE and util_is_form_visible(FORM_MAIN) then
    util_auto_show_hide_form(FORM_MAIN)
  elseif show_type == DELAY_CLOSE_LOSE or show_type == DELAY_CLOSE_WIN then
    local form = nx_value(FORM_MAIN)
    if not nx_is_valid(form) then
      return
    end
    local sec_index = form.ini:FindSectionIndex("base")
    if sec_index < 0 then
      return
    end
    local cfg_item_name = ""
    if show_type == DELAY_CLOSE_WIN then
      cfg_item_name = "over_win"
    else
      cfg_item_name = "over_lose"
    end
    local var = form.ini:ReadString(sec_index, cfg_item_name, "")
    local vars = util_split_string(nx_string(var), ",")
    if table.getn(vars) < 3 then
      game_finished(form)
      return
    end
    if nx_string(vars[3]) == nx_string("") then
      game_finished(form)
      return
    end
    local gui = nx_value("gui")
    local animation = gui:Create("Animation")
    animation.Top = (form.Height - vars[2]) / 3
    animation.Left = (form.Width - vars[1]) / 2
    animation.AnimationImage = vars[3]
    animation.Loop = false
    animation.PlayMode = 2
    animation.Visible = true
    animation:Play()
    form:Add(animation)
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "animation_over_end")
  end
end
function game_finished(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("tips_sjyagm_4"))
  form:Close()
end
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local IniManager = nx_value("IniManager")
  if not DEBUG_MODE then
    if not IniManager:IsIniLoadedToManager(INI_FILE) then
      IniManager:LoadIniToManager(INI_FILE)
    end
  else
    IniManager:UnloadIniFromManager(INI_FILE)
    IniManager:LoadIniToManager(INI_FILE)
  end
  self.ini = IniManager:GetIniDocument(INI_FILE)
  self.Visible = true
  refresh_form_pos(self)
  pre_load(self)
  pre_create(self)
  self.lbl_score.Text = nx_widestr(0)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_close_dialog(form)
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Enabled = false
  close_update(form)
  reset_element(form)
  reset_data(form)
  form.lbl_score.Text = nx_widestr(form.score)
  local sec_index = form.ini:FindSectionIndex("base")
  if sec_index < 0 then
    return
  end
  local var = form.ini:ReadString(sec_index, "count_down", "")
  local vars = util_split_string(nx_string(var), ",")
  if table.getn(vars) < 3 then
    return
  end
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.Width = vars[1]
  animation.Height = vars[2]
  animation.Top = (form.groupbox_main.Height - animation.Height) / 3
  animation.Left = (form.groupbox_main.Width - animation.Width) / 2
  animation.AnimationImage = vars[3]
  animation.Loop = false
  animation.PlayMode = 2
  animation.Visible = true
  animation:Play()
  form.groupbox_main:Add(animation)
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "animation_cd_end")
end
function animation_cd_end(animation, ani_name, mode)
  local form = animation.ParentForm
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      if nx_is_valid(form) then
        form:Remove(animation)
      end
      gui:Delete(animation)
    end
  end
  if nx_is_valid(form) then
    open_update(form)
  end
end
function refresh_form_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function change_form_size()
  send_result(2, 0)
end
function on_main_form_close(self)
  close_update(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function game_key_down(gui, key, shift, ctrl)
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
function reset_element(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ctrl_count = form.groupbox_main:GetChildControlList()
  for i = 1, table.getn(ctrl_count) do
    if nx_is_valid(ctrl_count[i]) and "Button" == nx_name(ctrl_count[i]) then
      ctrl_count[i].status = ELE_PREPARE
      ctrl_count[i].Top = 0 - ctrl_count[i].Height
      ctrl_count[i].click_count = ctrl_count[i].max_click_count
      ctrl_count[i].DisableEnter = true
      ctrl_count[i].Visible = true
    end
  end
end
function reset_data(form)
  if not nx_is_valid(form) then
    return
  end
  form.score = 0
end
function open_update(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.cur_frame = 0
  timer:Register(ELAPSE_MILLSEC, -1, nx_current(), "on_update", form, -1, -1)
end
function close_update(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "on_update", form)
end
function on_update(form)
  form.cur_frame = form.cur_frame + 1
  local elapse_sec = form.cur_frame * ELAPSE_MILLSEC / 1000
  form.lbl_countdown.Text = nx_widestr(math.floor(elapse_sec))
  local is_over = true
  local ctrl_list = form.groupbox_main:GetChildControlList()
  for _, child in ipairs(ctrl_list) do
    if nx_is_valid(child) and "Button" == nx_name(child) then
      if child.status == ELE_PREPARE then
        handle_show_element(form, child, elapse_sec)
        is_over = false
      elseif child.status == ELE_SHOW then
        handle_fall_element(form, child)
        is_over = false
      end
    end
  end
  if is_over then
    close_update(form)
    if nx_int(form.score) >= nx_int(form.min_finish_score) then
      send_result(1, form.score)
    else
      send_result(0, 0)
    end
  end
end
function animation_over_end(animation, ani_name, mode)
  if nx_is_valid(animation) then
    local form = animation.ParentForm
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function pre_load(form)
  if not nx_is_valid(form) then
    return
  end
  form.way = DEFAULT_WAY
  form.min_speed = DEFAULT_MIN_SPEED
  form.max_speed = DEFAULT_MAX_SPEED
  if form.ini == nil then
    return
  end
  local sec_index = form.ini:FindSectionIndex("base")
  if sec_index < 0 then
    return
  end
  form.way = form.ini:ReadInteger(sec_index, "way", DEFAULT_WAY)
  form.min_speed = form.ini:ReadInteger(sec_index, "min_speed", DEFAULT_MIN_SPEED)
  form.max_speed = form.ini:ReadInteger(sec_index, "max_speed", DEFAULT_MAX_SPEED)
  form.min_finish_score = form.ini:ReadInteger(sec_index, "min_finish_score", 0)
end
function pre_create(form)
  if form.ini == nil then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sec_index = form.ini:FindSectionIndex("sequence")
  local total_count = form.ini:GetSectionItemCount(sec_index)
  local res_sec_index = form.ini:FindSectionIndex("res")
  for i = 1, total_count do
    local var = form.ini:GetSectionItemValue(sec_index, i - 1)
    local btn_element = gui:Create("Button")
    local ele_w, ele_h, nor_res, focus_res, push_res, boom_w, boom_h, boom_res
    local vars = util_split_string(nx_string(var), "_")
    if table.getn(vars) >= 2 then
      btn_element.show_sec = nx_number(vars[1])
      btn_element.click_count = nx_int(vars[2])
      btn_element.max_click_count = nx_int(vars[2])
      if 0 <= res_sec_index then
        local res_var = form.ini:ReadString(res_sec_index, nx_string(vars[2]), "")
        if res_var ~= "" then
          local res_vars = util_split_string(nx_string(res_var), ",")
          if table.getn(res_vars) >= 8 then
            ele_w = res_vars[1]
            ele_h = res_vars[2]
            nor_res = res_vars[3]
            focus_res = res_vars[4]
            push_res = res_vars[5]
            boom_w = res_vars[6]
            boom_h = res_vars[7]
            boom_res = res_vars[8]
          end
        end
      end
    end
    btn_element.Left = -1000
    btn_element.Top = -1000
    btn_element.Width = nx_int(ele_w)
    btn_element.Height = nx_int(ele_h)
    btn_element.NormalImage = nx_string(nor_res)
    btn_element.FocusImage = nx_string(focus_res)
    btn_element.PushImage = nx_string(push_res)
    btn_element.DrawMode = "FitWindow"
    btn_element.status = ELE_PREPARE
    btn_element.boom_res = nx_string(boom_res)
    btn_element.boom_w = nx_int(boom_w)
    btn_element.boom_h = nx_int(boom_h)
    form.groupbox_main:Add(btn_element)
    nx_set_custom(form, nx_string("btn_ele_" .. nx_string(i)), btn_element)
    nx_bind_script(btn_element, nx_current())
    nx_callback(btn_element, "on_click", "on_btn_ele_click")
  end
  form.total_element_count = total_count
end
function on_btn_ele_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.click_count = btn.click_count - 1
  if btn.click_count <= 0 then
    btn.Visible = false
    btn.status = ELE_CLICKED
    form.score = form.score + btn.max_click_count
    form.lbl_score.Text = nx_widestr(form.score)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local animation = gui:Create("Animation")
    animation.Width = btn.boom_w
    animation.Height = btn.boom_h
    animation.Top = btn.Top
    animation.Left = btn.Left
    animation.AnimationImage = btn.boom_res
    animation.Loop = false
    animation.PlayMode = 2
    animation.Visible = true
    animation:Play()
    form.groupbox_main:Add(animation)
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "animation_event_end")
  end
end
function animation_event_end(animation, ani_name, mode)
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      local form = animation.ParentForm
      if nx_is_valid(form) then
        form.groupbox_main:Remove(animation)
      end
      gui:Delete(animation)
    end
  end
end
function get_random_way(form)
  local way = DEFAULT_WAY
  if nx_is_valid(form) then
    way = form.way
  end
  return math.random(way)
end
function get_speed(form)
  local min_speed = DEFAULT_MIN_SPEED
  local max_speed = DEFAULT_MAX_SPEED
  if nx_is_valid(form) then
    min_speed = form.min_speed
    max_speed = form.max_speed
  end
  return math.random() * (max_speed - min_speed) + min_speed
end
function handle_show_element(form, btn_ele, elapse_sec)
  if not nx_is_valid(btn_ele) then
    return
  end
  if nx_number(btn_ele.show_sec) <= nx_number(elapse_sec) then
    local way = get_random_way(form)
    local single_way_width = form.groupbox_main.Width / 6
    btn_ele.Left = single_way_width * way - single_way_width / 2 - btn_ele.Width / 2
    btn_ele.Top = 0 - btn_ele.Height
    btn_ele.speed = get_speed(form)
    btn_ele.status = ELE_SHOW
  end
end
function calc_fall_speed(base_speed, y_percent)
  return base_speed * (1 + math.tan(y_percent + 0.2))
end
function handle_fall_element(form, btn_ele)
  if not nx_is_valid(btn_ele) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if btn_ele.Top >= form.groupbox_main.Height then
    btn_ele.status = ELE_DEAD
    return
  end
  local y_percent = (btn_ele.Top + btn_ele.Height) / form.groupbox_main.Height
  local fall_pixel = calc_fall_speed(btn_ele.speed, y_percent)
  fall_pixel = math.max(fall_pixel, 1)
  btn_ele.Top = btn_ele.Top + fall_pixel
end
function send_result(res, score)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(505), nx_int(11), nx_int(res), nx_int(score))
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
    send_result(2, 0)
  end
end
