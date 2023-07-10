require("util_gui")
require("util_functions")
require("role_composite")
require("share\\view_define")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_looker"
local FORM_NAME_P1 = "form_stage_main\\form_kof\\form_kof_role_left"
local FORM_NAME_P2 = "form_stage_main\\form_kof\\form_kof_role_right"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.groupbox_6.Fixed = false
  form.is_looking = false
  form.left_time = 300
  load_form_players(form)
  change_form_size()
  init_team_info(form)
  nx_execute("form_stage_main\\form_main\\form_main_team", "hide_team_panel")
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_KOF_A, form, nx_current(), "on_viewport_change")
    databinder:AddViewBind(VIEWPORT_KOF_B, form, nx_current(), "on_viewport_change")
  end
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
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
  end
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", self)
  end
  nx_execute("gui", "gui_open_closedsystem_form_easy")
  nx_execute("form_stage_main\\form_main\\form_main_team", "update_team_panel")
  nx_destroy(self)
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form_and_hide()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = false
  end
end
function hide_some_gb()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = false
  form.gb_p1.Visible = false
  form.gb_p2.Visible = false
  form.groupbox_6.Visible = false
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "remove_buff_cyc", form.form_p1)
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "remove_buff_cyc", form.form_p2)
  form.form_p1.canshowsprite = false
  form.form_p2.canshowsprite = false
  form.is_looking = false
end
function is_looking()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return false
  end
  return form.is_looking
end
function show_some_gb()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_3.Visible = true
  form.gb_p1.Visible = true
  form.gb_p2.Visible = true
  form.groupbox_6.Visible = true
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "add_buff_cyc", form.form_p1)
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "add_buff_cyc", form.form_p2)
  form.form_p1.canshowsprite = true
  form.form_p2.canshowsprite = true
  form.is_looking = true
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  if form.left_time > 0 then
    form.left_time = form.left_time - 1
  end
  form.lbl_left_time.Text = nx_widestr(form.left_time)
  if form.pbar_chat.Value ~= 100 then
    form.pbar_chat.Value = form.pbar_chat.Value + 10
    if form.pbar_chat.Value == 100 then
      enable_looker_chat(form)
    end
  end
end
function forbid_looker_chat(form)
  form.pbar_chat.Value = 0
  for i = 1, 30 do
    local btn = form.groupbox_6:Find("btn_chat_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Enabled = false
    end
  end
end
function enable_looker_chat(form)
  for i = 1, 30 do
    local btn = form.groupbox_6:Find("btn_chat_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Enabled = true
    end
  end
end
function on_btn_chat_click(btn)
  local form = btn.ParentForm
  forbid_looker_chat(form)
  custom_kof(CTS_SUB_KOF_LOOKER_CHAT, nx_number(btn.DataSource))
end
function on_btn_reset_view_click(btn)
  reset_self_view()
end
function load_form_players(form)
  local form_p1 = util_get_form(FORM_NAME_P1, true)
  form.gb_p1:Add(form_p1)
  form.form_p1 = form_p1
  form_p1.Top = 0
  form_p1.Left = 0
  form_p1.Visible = true
  local form_p2 = util_get_form(FORM_NAME_P2, true)
  form.gb_p2:Add(form_p2)
  form.form_p2 = form_p2
  form_p2.Top = 0
  form_p2.Left = 0
  form_p2.Visible = true
end
function on_viewport_change(form, optype, view_ident)
  if not nx_find_custom(form, "form_p1") or not nx_find_custom(form, "form_p2") then
    return
  end
  if optype ~= "updateview" and optype ~= "createview" then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  if VIEWPORT_KOF_A == view_ident then
    nx_execute("form_stage_main\\form_kof\\form_kof_role", "refresh_form", form.form_p1, view)
  elseif VIEWPORT_KOF_B == view_ident then
    nx_execute("form_stage_main\\form_kof\\form_kof_role", "refresh_form", form.form_p2, view)
  else
    return
  end
end
function other_skill_changed(player, skillid)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if string.len(skillid) < 3 then
    return
  end
  if not nx_is_valid(player) then
    return
  end
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "refresh_skill_new", form.form_p1, player, skillid)
  nx_execute("form_stage_main\\form_kof\\form_kof_role", "refresh_skill_new", form.form_p2, player, skillid)
end
function init_team_info(form)
  for i = 1, 6 do
    local gb_t = form.gb_t1
    local gb_mod_t = form.gb_mod_t1
    local lbl_mod_t_bg = form.lbl_mod_t1_bg
    local lbl_mod_t_name = form.lbl_mod_t1_name
    local lbl_mod_t_score = form.lbl_mod_t1_score
    local lbl_mod_t_score_level = form.lbl_mod_t1_score_level
    local lbl_mod_t_ng = form.lbl_mod_t1_ng
    local lbl_mod_t_wx1 = form.lbl_mod_t1_wx1
    local lbl_mod_t_wx2 = form.lbl_mod_t1_wx2
    local lbl_mod_t_in = form.lbl_mod_t1_in
    local lbl_mod_t_lose = form.lbl_mod_t1_lose
    local lbl_mod_t_fighting = form.lbl_mod_t1_fighting
    local mltbox_mod_t_chat = form.mltbox_mod_t1_chat
    local lbl_mod_t_my = form.lbl_mod_t1_my
    if 3 < i then
      gb_t = form.gb_t2
      gb_mod_t = form.gb_mod_t2
      lbl_mod_t_bg = form.lbl_mod_t2_bg
      lbl_mod_t_name = form.lbl_mod_t2_name
      lbl_mod_t_score = form.lbl_mod_t2_score
      lbl_mod_t_score_level = form.lbl_mod_t2_score_level
      lbl_mod_t_ng = form.lbl_mod_t2_ng
      lbl_mod_t_wx1 = form.lbl_mod_t2_wx1
      lbl_mod_t_wx2 = form.lbl_mod_t2_wx2
      lbl_mod_t_in = form.lbl_mod_t2_in
      lbl_mod_t_lose = form.lbl_mod_t2_lose
      lbl_mod_t_fighting = form.lbl_mod_t2_fighting
      mltbox_mod_t_chat = form.mltbox_mod_t2_chat
      lbl_mod_t_my = form.lbl_mod_t2_my
    end
    local gb_mod_one = create_ctrl("GroupBox", "gb_mod_one_" .. nx_string(i), gb_mod_t, gb_t)
    local lbl_t_bg = create_ctrl("Label", "lbl_t_bg_" .. nx_string(i), lbl_mod_t_bg, gb_mod_one)
    local lbl_t_name = create_ctrl("Label", "lbl_t_name_" .. nx_string(i), lbl_mod_t_name, gb_mod_one)
    local lbl_t_score_level = create_ctrl("Label", "lbl_t_score_level_" .. nx_string(i), lbl_mod_t_score_level, gb_mod_one)
    local lbl_t_score = create_ctrl("Label", "lbl_t_score_" .. nx_string(i), lbl_mod_t_score, gb_mod_one)
    local lbl_t_ng = create_ctrl("Label", "lbl_t_ng_" .. nx_string(i), lbl_mod_t_ng, gb_mod_one)
    local lbl_t_wx1 = create_ctrl("Label", "lbl_t_wx1_" .. nx_string(i), lbl_mod_t_wx1, gb_mod_one)
    local lbl_t_wx2 = create_ctrl("Label", "lbl_t_wx2_" .. nx_string(i), lbl_mod_t_wx2, gb_mod_one)
    local lbl_t_in = create_ctrl("Label", "lbl_t_in_" .. nx_string(i), lbl_mod_t_in, gb_mod_one)
    local lbl_t_lose = create_ctrl("Label", "lbl_t_lose_" .. nx_string(i), lbl_mod_t_lose, gb_mod_one)
    local lbl_t_fighting = create_ctrl("Label", "lbl_t_fighting_" .. nx_string(i), lbl_mod_t_fighting, gb_mod_one)
    local mltbox_t_chat = create_ctrl("MultiTextBox", "mltbox_t_chat_" .. nx_string(i), mltbox_mod_t_chat, gb_mod_one)
    local lbl_t_my = create_ctrl("Label", "lbl_t_my_" .. nx_string(i), lbl_mod_t_my, gb_mod_one)
    lbl_t_my.Visible = false
    mltbox_t_chat.Visible = false
    gb_mod_one.Left = 0
    gb_mod_one.Top = gb_mod_one.Height * (i - 1)
    if 3 < i then
      gb_mod_one.Top = gb_mod_one.Height * (i - 4)
    end
  end
end
function update_team_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local arg_count = #arg
  local is_fighter = 0
  for i = 1, arg_count / 8 do
    local player_name = nx_widestr(arg[1 + (i - 1) * 8])
    local score = nx_number(arg[2 + (i - 1) * 8])
    local is_in = nx_number(arg[3 + (i - 1) * 8])
    local neigong = nx_string(arg[4 + (i - 1) * 8])
    local wuxue1 = nx_string(arg[5 + (i - 1) * 8])
    local wuxue2 = nx_string(arg[6 + (i - 1) * 8])
    local is_lose = nx_number(arg[7 + (i - 1) * 8])
    local fighting = nx_number(arg[8 + (i - 1) * 8])
    local gb_t = form.gb_t1
    if 3 < i then
      gb_t = form.gb_t2
    end
    local gb_mod_one = gb_t:Find("gb_mod_one_" .. nx_string(i))
    if nx_is_valid(gb_mod_one) then
      local lbl_t_name = gb_mod_one:Find("lbl_t_name_" .. nx_string(i))
      local lbl_t_score_level = gb_mod_one:Find("lbl_t_score_level_" .. nx_string(i))
      local lbl_t_score = gb_mod_one:Find("lbl_t_score_" .. nx_string(i))
      local lbl_t_ng = gb_mod_one:Find("lbl_t_ng_" .. nx_string(i))
      local lbl_t_wx1 = gb_mod_one:Find("lbl_t_wx1_" .. nx_string(i))
      local lbl_t_wx2 = gb_mod_one:Find("lbl_t_wx2_" .. nx_string(i))
      local lbl_t_in = gb_mod_one:Find("lbl_t_in_" .. nx_string(i))
      local lbl_t_lose = gb_mod_one:Find("lbl_t_lose_" .. nx_string(i))
      local lbl_t_fighting = gb_mod_one:Find("lbl_t_fighting_" .. nx_string(i))
      local lbl_t_my = gb_mod_one:Find("lbl_t_my_" .. nx_string(i))
      if is_main_player(player_name) then
        lbl_t_my.Visible = true
      end
      gb_mod_one.player_name = player_name
      lbl_t_name.Text = player_name
      lbl_t_score_level.BackImage = get_score_image(score)
      lbl_t_score.Text = nx_widestr(score)
      lbl_t_ng.Text = nx_widestr(util_text(neigong))
      lbl_t_wx1.Text = nx_widestr(util_text(wuxue1))
      lbl_t_wx2.Text = nx_widestr(util_text(wuxue2))
      if fighting == 1 then
        lbl_t_fighting.BackImage = "gui\\special\\kof\\fighting.png"
      elseif is_lose == 1 then
        lbl_t_fighting.BackImage = "gui\\special\\kof\\is_lose.png"
      elseif is_in == 0 then
        lbl_t_fighting.BackImage = "gui\\special\\kof\\leave.png"
      else
        lbl_t_fighting.BackImage = "gui\\special\\kof\\waiting.png"
      end
    end
    if is_main_player(player_name) and fighting == 1 then
      is_fighter = 1
    end
  end
  if is_fighter == 1 then
    show_fighter()
  else
    show_looker()
  end
end
function update_stage_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local stage = nx_number(arg[1])
  local left_time = nx_number(arg[2])
  form.lbl_stage.Text = nx_widestr(get_round_stage_text(stage))
  form.lbl_left_time.Text = nx_widestr(left_time)
  form.left_time = left_time
  form.form_p1.sub_stage = stage
  form.form_p2.sub_stage = stage
end
function looker_chat(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local player_name = nx_widestr(arg[1])
  local ui_chat = nx_string(arg[2])
  local is_team = nx_number(arg[3])
  local gb_one, index = find_gb_player_one(form, player_name)
  local mltbox_t_chat = gb_one:Find("mltbox_t_chat_" .. nx_string(index))
  if is_team == 1 then
    local main_player_name = get_main_player_name()
    local gb_main, index_main = find_gb_player_one(form, main_player_name)
    if math.floor((index - 1) / 3) ~= math.floor((index_main - 1) / 3) then
      return
    end
    mltbox_t_chat.HtmlText = nx_widestr(ui_chat)
  else
    mltbox_t_chat.HtmlText = nx_widestr(util_text(ui_chat))
  end
  mltbox_t_chat.Visible = true
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "timer_callback", mltbox_t_chat)
    timer:Register(5000, 1, nx_current(), "timer_callback", mltbox_t_chat, -1, -1)
  end
end
function timer_callback(mltbox, param1, param2)
  mltbox.Visible = false
end
function find_gb_player_one(form, player_name)
  for i = 1, 6 do
    local gb_t = form.gb_t1
    if 3 < i then
      gb_t = form.gb_t2
    end
    local gb_mod_one = gb_t:Find("gb_mod_one_" .. nx_string(i))
    if gb_mod_one.player_name == player_name then
      return gb_mod_one, i
    end
  end
  return nil, nil
end
