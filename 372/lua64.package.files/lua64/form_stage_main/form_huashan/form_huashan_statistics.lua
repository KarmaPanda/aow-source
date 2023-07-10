require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("share\\view_define")
require("util_functions")
require("util_gui")
require("share\\itemtype_define")
require("custom_sender")
require("role_composite")
require("define\\request_type")
TIMEOUT_CLOSEFORM = 30
function main_form_init(form)
  form.Fixed = false
  form.tick_count = 0
  form.winner_name = nx_widestr("")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function open_form(winner_name)
  local form_stat = nx_execute("util_gui", "util_show_form", m_Game_Stat, true, false)
  if nx_is_valid(form_stat) then
    form_stat.winner_name = winner_name
    form_stat:Show()
    fresh_form(form_stat)
    reset_timer(form_stat, TIMEOUT_CLOSEFORM)
  end
end
function fresh_form(form)
  if form.winner_name == nil or nx_string(form.winner_name) == nx_string("") then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player_name_a = "Empty"
  local player_name_b = "Empty"
  local DamageAll_a = 0
  local DamageAll_b = 0
  local DamageMax_a = 0
  local DamageMax_b = 0
  local FightDodge_a = 0
  local FightDodge_b = 0
  local FightVa_a = 0
  local FightVa_b = 0
  local FightBreakParry_a = 0
  local FightBreakParry_b = 0
  local FightParry_a = 0
  local FightParry_b = 0
  local FightLastTime_a = 0
  local FightLastTime_b = 0
  local DamagePerSec_a = 0
  local DamagePerSec_b = 0
  local view_a = game_client:GetView(nx_string(VIEWPORT_HUASHAN_FIGHT_ST_PLAYERA))
  local view_b = game_client:GetView(nx_string(VIEWPORT_HUASHAN_FIGHT_ST_PLAYERB))
  if nx_is_valid(view_a) then
    player_name_a = view_a:QueryProp("PlayerA")
    DamageAll_a = view_a:QueryProp("DamageAll")
    DamageMax_a = view_a:QueryProp("DamageMax")
    FightDodge_a = view_a:QueryProp("FightDodge")
    FightVa_a = view_a:QueryProp("FightVa")
    FightBreakParry_a = view_a:QueryProp("FightBreakParry")
    FightParry_a = view_a:QueryProp("FightParry")
    FightLastTime_a = view_a:QueryProp("FightLastTime")
    local sec_FightLastTime_a = FightLastTime_a / 1000
    if 0 < sec_FightLastTime_a then
      DamagePerSec_a = DamageAll_a / sec_FightLastTime_a
    end
  end
  if nx_is_valid(view_b) then
    player_name_b = view_b:QueryProp("PlayerB")
    DamageAll_b = view_b:QueryProp("DamageAll")
    DamageMax_b = view_b:QueryProp("DamageMax")
    FightDodge_b = view_b:QueryProp("FightDodge")
    FightVa_b = view_b:QueryProp("FightVa")
    FightBreakParry_b = view_b:QueryProp("FightBreakParry")
    FightParry_b = view_b:QueryProp("FightParry")
    FightLastTime_b = view_b:QueryProp("FightLastTime")
    local sec_FightLastTime_b = FightLastTime_b / 1000
    if 0 < sec_FightLastTime_b then
      DamagePerSec_b = DamageAll_b / sec_FightLastTime_b
    end
  end
  form.lbl_name_a.Text = get_name(player_name_a)
  form.lbl_name_b.Text = get_name(player_name_b)
  if form.winner_name == player_name_a then
    form.lbl_win_a.BackImage = "gui\\special\\huashan\\bg_yazhu_win.png"
    form.lbl_win_b.BackImage = "gui\\special\\huashan\\bg_yazhu_fail.png"
  elseif form.winner_name == player_name_b then
    form.lbl_win_a.BackImage = "gui\\special\\huashan\\bg_yazhu_fail02.png"
    form.lbl_win_b.BackImage = "gui\\special\\huashan\\bg_yazhu_win02.png"
  end
  if DamageAll_a == DamageAll_b then
    if DamageAll_a == 0 then
      form.pbar_1_a.Value = 0
      form.pbar_1_b.Value = 0
    else
      form.pbar_1_a.Value = 100
      form.pbar_1_b.Value = 100
    end
  elseif DamageAll_a > DamageAll_b then
    form.pbar_1_a.Value = 100
    form.pbar_1_b.Value = 100 * DamageAll_b / DamageAll_a
  else
    form.pbar_1_b.Value = 100
    form.pbar_1_a.Value = 100 * DamageAll_a / DamageAll_b
  end
  if DamageMax_a == DamageMax_b then
    if DamageMax_a == 0 then
      form.pbar_2_a.Value = 0
      form.pbar_2_b.Value = 0
    else
      form.pbar_2_a.Value = 100
      form.pbar_2_b.Value = 100
    end
  elseif DamageMax_a > DamageMax_b then
    form.pbar_2_a.Value = 100
    form.pbar_2_b.Value = 100 * DamageMax_b / DamageMax_a
  else
    form.pbar_2_b.Value = 100
    form.pbar_2_a.Value = 100 * DamageMax_a / DamageMax_b
  end
  if DamagePerSec_a == DamagePerSec_b then
    if DamagePerSec_a == 0 then
      form.pbar_3_a.Value = 0
      form.pbar_3_b.Value = 0
    else
      form.pbar_3_a.Value = 100
      form.pbar_3_b.Value = 100
    end
  elseif DamagePerSec_a > DamagePerSec_b then
    form.pbar_3_a.Value = 100
    form.pbar_3_b.Value = 100 * DamagePerSec_b / DamagePerSec_a
  else
    form.pbar_3_b.Value = 100
    form.pbar_3_a.Value = 100 * DamagePerSec_a / DamagePerSec_b
  end
  if FightParry_a == FightParry_b then
    if FightParry_a == 0 then
      form.pbar_4_a.Value = 0
      form.pbar_4_b.Value = 0
    else
      form.pbar_4_a.Value = 100
      form.pbar_4_b.Value = 100
    end
  elseif FightParry_a > FightParry_b then
    form.pbar_4_a.Value = 100
    form.pbar_4_b.Value = 100 * FightParry_b / FightParry_a
  else
    form.pbar_4_b.Value = 100
    form.pbar_4_a.Value = 100 * FightParry_a / FightParry_b
  end
  if FightDodge_a == FightDodge_b then
    if FightDodge_a == 0 then
      form.pbar_5_a.Value = 0
      form.pbar_5_b.Value = 0
    else
      form.pbar_5_a.Value = 100
      form.pbar_5_b.Value = 100
    end
  elseif FightDodge_a > FightDodge_b then
    form.pbar_5_a.Value = 100
    form.pbar_5_b.Value = 100 * FightDodge_b / FightDodge_a
  else
    form.pbar_5_b.Value = 100
    form.pbar_5_a.Value = 100 * FightDodge_a / FightDodge_b
  end
  if FightVa_a == FightVa_b then
    if FightVa_a == 0 then
      form.pbar_6_a.Value = 0
      form.pbar_6_b.Value = 0
    else
      form.pbar_6_a.Value = 100
      form.pbar_6_b.Value = 100
    end
  elseif FightVa_a > FightVa_b then
    form.pbar_6_a.Value = 100
    form.pbar_6_b.Value = 100 * FightVa_b / FightVa_a
  else
    form.pbar_6_b.Value = 100
    form.pbar_6_a.Value = 100 * FightVa_a / FightVa_b
  end
  if FightBreakParry_a == FightBreakParry_b then
    if FightBreakParry_a == 0 then
      form.pbar_7_a.Value = 0
      form.pbar_7_b.Value = 0
    else
      form.pbar_7_a.Value = 100
      form.pbar_7_b.Value = 100
    end
  elseif FightBreakParry_a > FightBreakParry_b then
    form.pbar_7_a.Value = 100
    form.pbar_7_b.Value = 100 * FightBreakParry_b / FightBreakParry_a
  else
    form.pbar_7_b.Value = 100
    form.pbar_7_a.Value = 100 * FightBreakParry_a / FightBreakParry_b
  end
  form.lbl_stat_val_1_a.Text = nx_widestr(DamageAll_a)
  form.lbl_stat_val_1_b.Text = nx_widestr(DamageAll_b)
  form.lbl_stat_val_2_a.Text = nx_widestr(DamageMax_a)
  form.lbl_stat_val_2_b.Text = nx_widestr(DamageMax_b)
  form.lbl_stat_val_3_a.Text = nx_widestr(nx_int(DamagePerSec_a))
  form.lbl_stat_val_3_b.Text = nx_widestr(nx_int(DamagePerSec_b))
  form.lbl_stat_val_4_a.Text = nx_widestr(FightParry_a)
  form.lbl_stat_val_4_b.Text = nx_widestr(FightParry_b)
  form.lbl_stat_val_5_a.Text = nx_widestr(FightDodge_a)
  form.lbl_stat_val_5_b.Text = nx_widestr(FightDodge_b)
  form.lbl_stat_val_6_a.Text = nx_widestr(FightVa_a)
  form.lbl_stat_val_6_b.Text = nx_widestr(FightVa_b)
  form.lbl_stat_val_7_a.Text = nx_widestr(FightBreakParry_a)
  form.lbl_stat_val_7_b.Text = nx_widestr(FightBreakParry_b)
end
function reset_timer(form, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.lbl_tick.Text = nx_widestr(count)
  form.tick_count = nx_number(count)
  timer:UnRegister(nx_current(), "on_timer_update", form)
  timer:Register(1000, -1, nx_current(), "on_timer_update", form, -1, -1)
end
function on_timer_update(form, param1, param2)
  form.tick_count = form.tick_count - 1
  if form.tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_timer_update", form)
    end
    form:Close()
  else
    form.lbl_tick.Text = nx_widestr(form.tick_count)
  end
end
