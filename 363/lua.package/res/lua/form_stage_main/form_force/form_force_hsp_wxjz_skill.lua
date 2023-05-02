require("util_gui")
require("custom_sender")
require("define\\gamehand_type")
local FORM_NAME = "form_stage_main\\form_force\\form_force_hsp_wxjz_skill"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
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
  form.decal_fly = ini:ReadString(sec_index, "decal_fly", "")
  form.skill_fly_cd = ini:ReadInteger(sec_index, "skill_fly_cd", 0)
  form.skill_throw_cd = ini:ReadInteger(sec_index, "skill_throw_cd", 0)
  form.skill_fly_btn_on = ini:ReadString(sec_index, "skill_fly_btn_on", "")
  form.skill_fly_btn_out = ini:ReadString(sec_index, "skill_fly_btn_out", "")
  form.skill_fly_btn_down = ini:ReadString(sec_index, "skill_fly_btn_down", "")
  form.skill_throw_btn_on = ini:ReadString(sec_index, "skill_throw_btn_on", "")
  form.skill_throw_btn_out = ini:ReadString(sec_index, "skill_throw_btn_out", "")
  form.skill_throw_btn_down = ini:ReadString(sec_index, "skill_throw_btn_down", "")
  sec_index = ini:FindSectionIndex("property")
  if sec_index < 0 then
    return false
  end
  form.range_fly = ini:ReadInteger(sec_index, "range_fly", 0)
  form.range_fly_de = ini:ReadInteger(sec_index, "range_fly_de", 0)
  form.debuffer_forbin = ini:ReadString(sec_index, "debuffer_forbin", "")
  form.debuffer_reverse = ini:ReadString(sec_index, "debuffer_reverse", "")
  form.debuffer_speedup = ini:ReadString(sec_index, "debuffer_speedup", "")
  form.debuffer_small = ini:ReadString(sec_index, "debuffer_small", "")
  form.in_skill = false
  form.skill = ""
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_cooldown_time", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function open_form(skill)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form.Visible = true
    form:Show()
    if nx_string(form.skill) == nx_string(skill) then
      return
    end
    form.skill = nx_string(skill)
    init_skill_btn(form, 0)
    form.btn_skill.HintText = nx_widestr(util_text("ui_wxjz_" .. nx_string(skill)))
    if nx_string(skill) == nx_string("fly") then
      form.btn_skill.NormalImage = nx_string(form.skill_fly_btn_out)
      form.btn_skill.FocusImage = nx_string(form.skill_fly_btn_on)
      form.btn_skill.PushImage = nx_string(form.skill_fly_btn_down)
      nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", "close_form")
    elseif nx_string(skill) == nx_string("throw") then
      form.btn_skill.NormalImage = nx_string(form.skill_throw_btn_out)
      form.btn_skill.FocusImage = nx_string(form.skill_throw_btn_on)
      form.btn_skill.PushImage = nx_string(form.skill_throw_btn_down)
    end
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", false)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_skill_btn(form, cool)
  form.btn_skill.cool_cur = 0
  form.btn_skill.cool = cool
  form.btn_skill.Enabled = true
  form.lbl_cool.Top = form.lbl_cool.Height
end
function on_btn_skill_click(btn)
  local form = btn.ParentForm
  if nx_string(form.skill) == nx_string("fly") then
    if not on_wxjz_fly(form) then
      return
    end
    init_skill_btn(form, form.skill_fly_cd)
  elseif nx_string(form.skill) == nx_string("throw") then
    on_wxjz_throw(form)
    init_skill_btn(form, form.skill_throw_cd)
    if nx_int(form.btn_skill.cool) > nx_int(0) then
      btn.Enabled = false
      form.lbl_cool.Top = 0
      local timer = nx_value(GAME_TIMER)
      timer:UnRegister(nx_current(), "on_cooldown_time", form)
      timer:Register(1000, -1, nx_current(), "on_cooldown_time", form, -1, -1)
    end
  end
end
function on_cooldown_time(form, param1, param2)
  if nx_int(form.btn_skill.cool_cur) >= nx_int(form.btn_skill.cool) then
    form.btn_skill.Enabled = true
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_cooldown_time", form)
    return
  end
  form.btn_skill.cool_cur = form.btn_skill.cool_cur + 1
  form.lbl_cool.Top = nx_int(form.btn_skill.cool_cur) * nx_int(form.lbl_cool.Height) / nx_int(form.btn_skill.cool)
end
function on_wxjz_fly(form)
  if check_debuffer_forbin(form) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_hsp_wxjz_008"))
    return false
  end
  form.in_skill = true
  local decal_size
  if check_debuffer_small(form) then
    decal_size = nx_int(form.range_fly_de)
  else
    decal_size = nx_int(form.range_fly)
  end
  nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", "open_form")
  nx_execute("game_effect", "del_ground_pick_decal")
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand:SetHand(GHT_GROUD_PICK_2, "Default", nx_string(form.decal_fly), "" .. nx_string(decal_size), "form_stage_main\\form_force\\form_force_hsp_wxjz_skill,on_wxjz_fly_hit", nx_string(50))
  return true
end
function on_wxjz_fly_hit(...)
  local x = arg[2]
  local y = arg[3]
  local z = arg[4]
  form_bar = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", false)
  if not nx_is_valid(form_bar) then
    return
  end
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if arg[1] then
    local bar = nx_int(form_bar.pbar_1.Value) * 100 / nx_int(form_bar.pbar_1.Maximum)
    nx_execute("custom_sender", "custom_huashan_school", nx_int(1), nx_float(x), nx_float(y), nx_float(z), nx_int(bar))
    if nx_int(form.btn_skill.cool) > nx_int(0) then
      form.btn_skill.Enabled = false
      form.lbl_cool.Top = 0
      local timer = nx_value(GAME_TIMER)
      timer:UnRegister(nx_current(), "on_cooldown_time", form)
      timer:Register(1000, -1, nx_current(), "on_cooldown_time", form, -1, -1)
    end
  end
  nx_execute("form_stage_main\\form_force\\form_force_hsp_wxjz_fly_bar", "close_form")
  form.in_skill = false
end
function on_wxjz_throw()
  form_bar = util_get_form("form_stage_main\\form_force\\form_force_hsp_wxjz_throw_bar", false)
  if not nx_is_valid(form_bar) then
    return
  end
  local bar = nx_int(form_bar.pbar_1.Value) * 100 / nx_int(form_bar.pbar_1.Maximum)
  nx_execute("custom_sender", "custom_huashan_school", nx_int(2), nx_int(bar))
end
function check_debuffer_forbin(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local has_buff = nx_function("find_buffer", client_player, nx_string(form.debuffer_forbin))
  if has_buff then
    return true
  end
  return false
end
function test_find_buff()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local has_buff = nx_function("find_buffer", client_player, "buf_hu_book")
  if has_buff then
    nx_msgbox("test111")
    return
  end
end
function check_debuffer_reverse(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local has_buff = nx_function("find_buffer", client_player, nx_string(form.debuffer_reverse))
  if has_buff then
    return true
  end
  return false
end
function check_debuffer_speedup(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local has_buff = nx_function("find_buffer", client_player, nx_string(form.debuffer_speedup))
  if has_buff then
    return true
  end
  return false
end
function check_debuffer_small(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local has_buff = nx_function("find_buffer", client_player, nx_string(form.debuffer_small))
  if has_buff then
    return true
  end
  return false
end
function check_debuffer(form)
  if check_debuffer_forbin(form) then
    return true
  end
  if check_debuffer_reverse(form) then
    return true
  end
  if check_debuffer_speedup(form) then
    return true
  end
  if check_debuffer_small(form) then
    return true
  end
  return false
end
