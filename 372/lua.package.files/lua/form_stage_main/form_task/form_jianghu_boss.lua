require("util_gui")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.show_ID = 0
  form.huihe = 0
  return 1
end
function on_btn_minize_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  util_show_form("form_stage_main\\form_task\\form_JiangHu_show_tips", true)
end
function on_main_form_open(form)
  form.Fixed = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("JhBoss_Accept_Rec", form, nx_current(), "on_accept_record_change")
  end
  return 1
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("JhBoss_Accept_Rec", form)
  end
  nx_destroy(form)
  return 1
end
function show_form(...)
  if is_jyf_attacker() then
    return
  end
  local nType = arg[1]
  if nx_int(nType) == nx_int(4) then
    battle_begin_animation("second_three")
    return
  elseif nx_int(nType) == nx_int(5) then
    battle_animation_stop("second_three")
    return
  elseif nx_int(nType) == nx_int(6) then
    battle_begin_animation("second_ten")
    return
  elseif nx_int(nType) == nx_int(7) then
    battle_animation_stop("second_ten")
    return
  end
  local form = nx_value("form_stage_main\\form_task\\form_JiangHu_Boss")
  if not nx_is_valid(form) then
    form = util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", true)
  end
  local id = arg[2]
  local boss_config = arg[3]
  local boss_cur_anger = arg[4]
  local boss_max_anger = arg[5]
  local boss_title = arg[6]
  local headDir = arg[7]
  local huihe = arg[8]
  headDir = nx_string("gui\\special\\JHBoss\\boss") .. nx_string(headDir) .. nx_string(".png")
  if nx_int(nType) == nx_int(1) then
    form.show_ID = nx_int(id)
    update_form(form, boss_config, boss_cur_anger, boss_max_anger, boss_title, id, headDir, huihe)
    return
  end
  if nx_int(nType) == nx_int(2) then
    form.show_ID = nx_int(id)
    update_form(form, boss_config, boss_cur_anger, boss_max_anger, boss_title, id, headDir, huihe)
    return
  end
  if nx_int(nType) == nx_int(3) then
    if nx_int(form.show_ID) == nx_int(0) then
      util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", false)
      nx_execute("form_stage_main\\form_single_notice", "remove_item", nx_number(2), nx_number(29), nx_string("ui_jh_004"))
      return
    end
    if nx_int(id) == nx_int(0) then
      form.show_ID = nx_int(0)
      util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", false)
      nx_execute("form_stage_main\\form_single_notice", "remove_item", nx_number(2), nx_number(29), nx_string("ui_jh_004"))
      return
    end
    if nx_int(form.show_ID) == nx_int(id) then
      form.show_ID = nx_int(0)
      util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", false)
      nx_execute("form_stage_main\\form_single_notice", "remove_item", nx_number(2), nx_number(29), nx_string("ui_jh_004"))
    end
    return
  end
  util_show_form("form_stage_main\\form_task\\form_JiangHu_Boss", false)
  return
end
function update_form(form, boss_config, barCur, barMax, title, id, headDir, huihe)
  if nx_int(form.show_ID) == nx_int(id) then
    local gui = nx_value("gui")
    form.lbl_head.BackImage = nx_string(headDir)
    form.pbar_1.Value = nx_int(barCur)
    form.pbar_1.Maximum = nx_int(barMax)
    form.mltbox_talk.HtmlText = nx_widestr(util_text(title))
    if check_date(id, huihe) == false then
      huihe = nx_int(0)
    end
    form.huihe = huihe
    show_quntou(form, huihe + 1)
    form.tips = "ui_jh_00" .. nx_string(huihe + 1)
    nx_execute("form_stage_main\\form_single_notice", "show_form", nx_number(2), nx_number(29), nx_string("ui_jh_004"), form.huihe)
    local var = barCur * 100 / barMax
    if nx_int(var) <= nx_int(40) then
      form.lbl_fire.BackImage = "fireL"
    elseif nx_int(var) <= nx_int(80) then
      form.lbl_fire.BackImage = "fireM"
    else
      form.lbl_fire.BackImage = "fireL"
    end
  end
end
function on_accept_record_change(self, recordname, optype, row, clomn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local rows = 0
  local find_rec = client_player:FindRecord("JhBoss_Accept_Rec")
  if not find_rec then
    return 0
  end
  rows = client_player:GetRecordRows("JhBoss_Accept_Rec")
  if rows == 0 then
    return 0
  end
  for i = 0, rows - 1 do
    local id = client_player:QueryRecord("JhBoss_Accept_Rec", i, 0)
    if nx_int(id) == nx_int(self.show_ID) then
      local value = nx_int(client_player:QueryRecord("JhBoss_Accept_Rec", i, 1))
      local maxlue = nx_int(client_player:QueryRecord("JhBoss_Accept_Rec", i, 2))
      self.pbar_1.Value = nx_int(value)
      local var = value * 100 / maxlue
      if nx_int(var) <= nx_int(40) then
        self.lbl_fire.BackImage = "fireS"
      elseif nx_int(var) <= nx_int(80) then
        self.lbl_fire.BackImage = "fireM"
      else
        self.lbl_fire.BackImage = "fireL"
      end
    end
  end
  return 1
end
function show_quntou(form, lun)
  local skinpath = "gui\\special\\JHBoss\\quan.png"
  for i = 1, 5 do
    local lbl_str = "lbl_" .. nx_string(i)
    local lbl = form.gbox_lun:Find(lbl_str)
    if nx_is_valid(lbl) then
      lbl.BackImage = nx_string("")
    end
  end
  if nx_int(lun) < nx_int(1) then
    lun = 1
  end
  if nx_int(lun) > nx_int(5) then
    lun = 5
  end
  for i = 1, lun do
    local lbl_str = "lbl_" .. nx_string(i)
    local lbl = form.gbox_lun:Find(lbl_str)
    if nx_is_valid(lbl) then
      lbl.BackImage = nx_string(skinpath)
    end
  end
  return
end
function check_date(id, huihe)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local rows = 0
  local find_rec = client_player:FindRecord("JhBoss_Round_Rec")
  if not find_rec then
    return false
  end
  rows = client_player:GetRecordRows("JhBoss_Round_Rec")
  if rows == 0 then
    return false
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return false
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local y, m, d, __, __, __ = nx_function("ext_decode_date", cur_date_time)
  local ymd = nx_int(y) * 10000 + nx_int(m) * 100 + nx_int(d)
  for i = 0, rows - 1 do
    local valId = client_player:QueryRecord("JhBoss_Round_Rec", i, 0)
    if nx_int(id) == nx_int(valId) then
      local dbtime = client_player:QueryRecord("JhBoss_Round_Rec", i, 2)
      if nx_int(ymd) ~= nx_int(dbtime) then
        return false
      else
        return true
      end
    end
  end
  return false
end
function battle_begin_animation(ani_name)
  local gui = nx_value("gui")
  local animation = gui:Create("Animation")
  animation.Name = nx_string(ani_name)
  animation.AnimationImage = ani_name
  animation.Transparent = true
  gui.Desktop:Add(animation)
  animation.Left = (gui.Width - 110) / 2
  animation.Top = gui.Height / 4
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "battle_animation_end")
  animation:Play()
end
function battle_animation_stop(ani_name)
  local gui = nx_value("gui")
  local animation = gui.Desktop:Find(nx_string(ani_name))
  if nx_is_valid(animation) then
    gui:Delete(animation)
  end
end
function battle_animation_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  if nx_is_valid(self) then
    gui:Delete(self)
  end
end
function is_jyf_attacker()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  return nx_int(client_player:QueryProp("IsJYFaucltyAttacker")) == nx_int(1)
end
