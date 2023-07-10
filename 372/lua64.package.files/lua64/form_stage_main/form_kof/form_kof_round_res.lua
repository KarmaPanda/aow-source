require("util_gui")
require("util_functions")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_round_res"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.left_time = 10
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  nx_destroy(self)
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  if form.left_time > 0 then
    form.left_time = form.left_time - 1
  end
  if form.left_time == 8 then
    form.Visible = true
  end
  if form.left_time <= 0 then
    close_form()
  end
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = false
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function update_info(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = false
  local tab_info = {}
  for i = 1, 2 do
    local player_name = nx_widestr(arg[1 + (i - 1) * 14])
    local score = nx_number(arg[2 + (i - 1) * 14])
    local is_in = nx_number(arg[3 + (i - 1) * 14])
    local neigong = nx_string(arg[4 + (i - 1) * 14])
    local wuxue1 = nx_string(arg[5 + (i - 1) * 14])
    local wuxue2 = nx_string(arg[6 + (i - 1) * 14])
    local is_lose = nx_number(arg[7 + (i - 1) * 14])
    local damage_all = nx_number(arg[8 + (i - 1) * 14])
    local damage_max = nx_number(arg[9 + (i - 1) * 14])
    local dodge = nx_number(arg[10 + (i - 1) * 14])
    local va = nx_number(arg[11 + (i - 1) * 14])
    local break_parry = nx_number(arg[12 + (i - 1) * 14])
    local parry = nx_number(arg[13 + (i - 1) * 14])
    local last_time = nx_number(arg[14 + (i - 1) * 14])
    local gb_p = form:Find("gb_p" .. nx_string(i))
    local gb_p_info = gb_p:Find("gb_p" .. nx_string(i) .. "_info")
    local lbl_p_name = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_name")
    local lbl_p_score_level = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_score_level")
    local lbl_p_score = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_score")
    local lbl_p_ng = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_ng")
    local lbl_p_wx1 = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_wx1")
    local lbl_p_wx2 = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_wx2")
    local lbl_p_lose = gb_p_info:Find("lbl_p" .. nx_string(i) .. "_lose")
    lbl_p_name.Text = player_name
    lbl_p_score_level.BackImage = get_score_image(score)
    lbl_p_score.Text = nx_widestr(score)
    lbl_p_ng.Text = nx_widestr(util_text(neigong))
    lbl_p_wx1.Text = nx_widestr(util_text(wuxue1))
    lbl_p_wx2.Text = nx_widestr(util_text(wuxue2))
    if is_lose == 1 then
      lbl_p_lose.BackImage = "gui\\special\\bhss\\bhls\\lose.png"
    else
      lbl_p_lose.BackImage = "gui\\special\\bhss\\bhls\\win.png"
      if i == 2 then
        form.BackImage = "gui\\special\\kof\\ebg_2.png"
      else
        form.BackImage = "gui\\special\\kof\\ebg_1.png"
      end
    end
    local damage_sec = damage_all
    if 0 < last_time then
      damage_sec = math.floor(damage_all / last_time)
    end
    table.insert(tab_info, i, {
      damage_all,
      damage_max,
      dodge,
      va,
      break_parry,
      parry,
      damage_sec
    })
  end
  for i = 1, 2 do
    local gb_p = form:Find("gb_p" .. nx_string(i))
    local gb_p_pbar = gb_p:Find("gb_p" .. nx_string(i) .. "_pbar")
    local it_self = i
    local it_other = i + 1
    if i == 2 then
      it_other = i - 1
    end
    create_pbar(form, i, gb_p_pbar, "ui_kof_damage_all", tab_info[it_self][1], tab_info[it_other][1], 1)
    create_pbar(form, i, gb_p_pbar, "ui_kof_damage_max", tab_info[it_self][2], tab_info[it_other][2], 2)
    create_pbar(form, i, gb_p_pbar, "ui_kof_dodge", tab_info[it_self][3], tab_info[it_other][3], 3)
    create_pbar(form, i, gb_p_pbar, "ui_kof_va", tab_info[it_self][4], tab_info[it_other][4], 4)
    create_pbar(form, i, gb_p_pbar, "ui_kof_break_parry", tab_info[it_self][5], tab_info[it_other][5], 5)
    create_pbar(form, i, gb_p_pbar, "ui_kof_parry", tab_info[it_self][6], tab_info[it_other][6], 6)
    create_pbar(form, i, gb_p_pbar, "ui_kof_damage_sec", tab_info[it_self][7], tab_info[it_other][7], 7)
  end
end
function create_pbar(form, index, gb_p_pbar, ui_lbl, value1, value2, gb_index)
  local gb_mod, lbl_mod, pbar1_mod, pbar2_mod, lbl_mod_value1, lbl_mod_value2
  local max_value = value1
  if value2 < value1 then
    gb_mod = form.gb_mod_win
    lbl_mod = form.lbl_mod_win
    pbar1_mod = form.pbar_mod_win1
    pbar2_mod = form.pbar_mod_win2
    lbl_mod_value1 = form.lbl_mod_win_value1
    lbl_mod_value2 = form.lbl_mod_win_value2
    max_value = value1
  elseif value1 < value2 then
    gb_mod = form.gb_mod_lose
    lbl_mod = form.lbl_mod_lose
    pbar1_mod = form.pbar_mod_lose1
    pbar2_mod = form.pbar_mod_lose2
    lbl_mod_value1 = form.lbl_mod_lose_value1
    lbl_mod_value2 = form.lbl_mod_lose_value2
    max_value = value2
  elseif value1 == value2 then
    gb_mod = form.gb_mod_draw
    lbl_mod = form.lbl_mod_draw
    pbar1_mod = form.pbar_mod_draw1
    pbar2_mod = form.pbar_mod_draw2
    lbl_mod_value1 = form.lbl_mod_draw_value1
    lbl_mod_value2 = form.lbl_mod_draw_value2
  end
  local gb = create_ctrl("GroupBox", "gb_pbar_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), gb_mod, gb_p_pbar)
  local lbl = create_ctrl("Label", "lbl_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), lbl_mod, gb)
  local pbar1 = create_ctrl("ProgressBar", "pbar1_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), pbar1_mod, gb)
  local pbar2 = create_ctrl("ProgressBar", "pbar2_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), pbar2_mod, gb)
  local lbl_value1 = create_ctrl("Label", "lbl_value1_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), lbl_mod_value1, gb)
  local lbl_value2 = create_ctrl("Label", "lbl_value2_" .. nx_string(index) .. "_" .. nx_string(ui_lbl), lbl_mod_value2, gb)
  pbar1.Maximum = max_value
  pbar2.Maximum = max_value
  pbar1.Value = value1
  pbar2.Value = value2
  lbl.Text = nx_widestr(util_text(ui_lbl))
  lbl_value1.Text = nx_widestr(value1)
  lbl_value2.Text = nx_widestr(value2)
  gb.Left = 0
  gb.Top = (gb_index - 1) * gb.Height
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(b)
  nx_msgbox(nx_string(b))
end
