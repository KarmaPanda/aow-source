require("util_gui")
require("custom_sender")
require("define\\gamehand_type")
local FORM_NAME = "form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 4
    form.Top = (gui.Height - form.Height) / 2
  end
  form.Visible = true
  form:Show()
  local ini = get_ini("share\\ForceSchool\\hsp_wxjz.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex("client")
  if sec_index < 0 then
    return false
  end
  form.bar_speed = ini:ReadInteger(sec_index, "bar_speed", 0)
  form.bar_speed_de = ini:ReadInteger(sec_index, "bar_speed_de", 0)
  form.bar_state = 0
  form.bar_o = true
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(100, -1, nx_current(), "on_update_time", form, -1, -1)
  set_pbar_image(form)
  set_pbar_speed(form)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_update_time(form, param1, param2)
  local speed = get_bar_speed(form)
  if form.bar_o then
    form.pbar_1.Value = form.pbar_1.Value + nx_int(speed)
    if form.pbar_1.Value >= form.pbar_1.Maximum then
      form.bar_o = false
    end
  else
    form.pbar_1.Value = form.pbar_1.Value - nx_int(speed)
    if form.pbar_1.Value <= 0 then
      form.bar_o = true
    end
  end
end
function set_bar_state(form, state)
  form.bar_state = state
end
function get_bar_speed(form)
  if nx_int(form.bar_state) == nx_int(0) then
    return form.bar_speed
  else
    return form.bar_speed_de
  end
end
function set_pbar_image(form)
  local form_skill = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", false)
  if not nx_is_valid(form_skill) then
    return
  end
  if nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", "check_debuffer", form_skill) then
    form.pbar_1.ProgressImage = nx_string("gui\\common\\progressbar\\yjfx_pbar_1.png")
  else
    form.pbar_1.ProgressImage = nx_string("gui\\common\\progressbar\\yjfx_pbar_2.png")
  end
end
function set_pbar_speed(form)
  local form_skill = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", false)
  if not nx_is_valid(form_skill) then
    return
  end
  if nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", "check_debuffer_speedup", form_skill) then
    set_bar_state(form, 1)
  else
    set_bar_state(form, 0)
  end
end
function add_debuff(type)
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form.pbar_1.ProgressImage = nx_string("gui\\common\\progressbar\\yjfx_pbar_1.png")
    if nx_int(type) == nx_int(3) then
      set_bar_state(form, 1)
    elseif nx_int(type) == nx_int(4) then
      local form_skill = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", false)
      if not nx_is_valid(form_skill) then
        return
      end
      if form_skill.in_skill then
        local gui = nx_value("gui")
        local game_hand = gui.GameHand
        game_hand:SetHand(GHT_GROUD_PICK_2, "Default", nx_string(form_skill.decal_fly), "" .. nx_string(form_skill.range_fly_de), "form_stage_main\\form_force\\form_force_hsp_wxjz_skill,on_wxjz_fly_hit", nx_string(50))
      end
    end
  end
end
function remove_debuff(type)
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form.pbar_1.ProgressImage = nx_string("gui\\common\\progressbar\\yjfx_pbar_2.png")
    if nx_int(type) == nx_int(3) then
      set_bar_state(form, 0)
    elseif nx_int(type) == nx_int(4) then
      local form_skill = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_skill", false)
      if not nx_is_valid(form_skill) then
        return
      end
      if form_skill.in_skill then
        local gui = nx_value("gui")
        local game_hand = gui.GameHand
        game_hand:SetHand(GHT_GROUD_PICK_2, "Default", nx_string(form_skill.decal_fly), "" .. nx_string(form_skill.range_fly), "form_stage_main\\form_force\\form_force_hsp_wxjz_skill,on_wxjz_fly_hit", nx_string(50))
      end
    end
  end
end
