require("util_gui")
require("util_functions")
require("custom_sender")
require("share\\chat_define")
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_fight"
local scene_tab = {}
local GRID_TEXT_COLOR = "255,179,139,114"
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  load_ini(self)
  self.cur_round = 1
  self.sel_player = ""
  self.gb_menu.Visible = false
  self.btn_laba_1.Visible = false
  self.btn_laba_2.Visible = false
  self.btn_leader_award.Visible = false
  self.lbl_round_res_a.Visible = false
  self.lbl_round_res_b.Visible = false
  self.lbl_war_res.Visible = false
  self.my_camp_id = 2351
  self.sl_round = ""
  init_textgrid(self)
  init_camp()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function on_btn_close_click(self)
  close_form()
end
function on_btn_ready_click(btn)
  custom_agree_war(nx_int(9))
end
function on_btn_ready_cancel_click(btn)
  custom_agree_war(nx_int(10))
end
function on_rbtn_camp_a_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_camp_a.Visible = true
    form.gb_camp_b.Visible = false
    form.gb_menu.Visible = false
  end
end
function on_rbtn_camp_b_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_camp_a.Visible = false
    form.gb_camp_b.Visible = true
    form.gb_menu.Visible = false
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    get_war_info()
    return
  end
  close_form()
end
function reopen_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    close_form()
  end
  form = util_get_form(FORM_NAME, true)
  form:Show()
  form.Visible = true
  get_war_info()
end
function open_form_round_end(round)
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    close_form()
  end
  form = util_get_form(FORM_NAME, true)
  form:Show()
  form.Visible = true
end
function get_war_info()
  custom_agree_war(nx_int(13), nx_int(0))
end
function on_textgrid_all_a_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = grid:GetGridText(row, 1)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  form.sel_player = player_name
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  form.gb_menu.AbsLeft = x
  form.gb_menu.AbsTop = y
  form.gb_menu.Visible = true
end
function on_textgrid_all_b_right_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local player_name = grid:GetGridText(row, 1)
  if nx_widestr(player_name) == nx_widestr("") then
    return
  end
  form.sel_player = player_name
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorPosition()
  form.gb_menu.AbsLeft = x
  form.gb_menu.AbsTop = y
  form.gb_menu.Visible = true
end
function on_textgrid_all_a_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gb_menu.Visible = false
end
function on_textgrid_all_b_select_grid(grid, row, col)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gb_menu.Visible = false
end
function on_btn_kick_click(btn)
  local form = btn.ParentForm
  if nx_widestr("") == nx_widestr(form.sel_player) then
    return
  end
  custom_agree_war(nx_int(5), nx_widestr(form.sel_player))
  form.gb_menu.Visible = false
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.gb_menu.Visible = false
  local player = form.sel_player
  if nx_widestr("") == nx_widestr(player) then
    return
  end
  nx_execute("custom_sender", "custom_send_get_player_game_info", player)
  form.gb_menu.Visible = false
end
function on_btn_laba_1_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "camp_win") then
    return
  end
  if nx_int(form.my_camp_id) ~= nx_int(form.camp_win) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_agree_war_laba_1")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local chat_str = ""
    local chat_str = get_chat_str_1(form)
    local switch = nx_execute("form_stage_main\\form_main\\form_laba_info", "get_used_card_type")
    nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, 1, "xiaolaba_ani_revenge", switch)
  end
end
function on_btn_laba_2_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "camp_win") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_agree_war_laba_2")))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local chat_str = ""
    local chat_str = get_chat_str_2(form)
    local switch = nx_execute("form_stage_main\\form_main\\form_laba_info", "get_used_card_type")
    nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, 1, "xiaolaba_ani_revenge", switch)
  end
end
function on_btn_leader_award_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "camp_win") then
    return
  end
  local form_score = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_score", false)
  if not nx_is_valid(form_score) then
    return
  end
  local scale = form_score.scale
  local gui = nx_value("gui")
  local cost = 0
  local text = ""
  if nx_int(form.my_camp_id) == nx_int(form.camp_win) then
    cost = get_leader_award_win_cost_by_scale(nx_int(scale) + 1)
    text = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_agree_war_leader_award_win"), nx_int(cost)))
  else
    cost = get_leader_award_lose_cost_by_scale(nx_int(scale) + 1)
    text = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_agree_war_leader_award_lose"), nx_int(cost)))
  end
  if nx_int(cost) > nx_int(0) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_agree_war(nx_int(22))
    end
  else
    custom_agree_war(nx_int(22))
  end
end
function get_chat_str_1(form)
  local form_score = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_score", false)
  if not nx_is_valid(form_score) then
    return
  end
  local guild_a = form_score.lbl_guild_a.Text
  local guild_b = form_score.lbl_guild_b.Text
  local score_a = form_score.lbl_score_a.Text
  local score_b = form_score.lbl_score_b.Text
  local point_a = form_score.point_a
  local point_b = form_score.point_b
  local guild_self = ""
  local guild_target = ""
  local score_self = ""
  local score_target = ""
  local point_self = ""
  if nx_int(form.my_camp_id) == nx_int(2351) then
    guild_self = guild_a
    guild_target = guild_b
    score_self = score_a
    score_target = score_b
    point_self = point_a
  else
    guild_self = guild_b
    guild_target = guild_a
    score_self = score_b
    score_target = score_a
    point_self = point_b
  end
  local gui = nx_value("gui")
  local chat_str = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_chat_laba_1"), nx_widestr(guild_self), nx_widestr(guild_target), nx_int(score_self), nx_int(score_target), nx_int(point_self)))
  return chat_str
end
function get_chat_str_2(form)
  local form_score = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_score", false)
  if not nx_is_valid(form_score) then
    return
  end
  local guild_a = form_score.lbl_guild_a.Text
  local guild_b = form_score.lbl_guild_b.Text
  local point_a = form_score.point_a
  local point_b = form_score.point_b
  local guild_self = ""
  local guild_target = ""
  local point_self = ""
  if nx_int(form.my_camp_id) == nx_int(2351) then
    guild_self = guild_a
    guild_target = guild_b
    point_self = point_a
  else
    guild_self = guild_b
    guild_target = guild_a
    point_self = point_b
  end
  local gui = nx_value("gui")
  local chat_str = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_chat_laba_2"), nx_widestr(guild_target), nx_widestr(guild_self)))
  return chat_str
end
function on_cbtn_sl_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    if nx_string(form.sl_round) == nx_string(cbtn.sl_round) then
      return
    end
    form.lbl_round_res_a.Visible = false
    form.lbl_round_res_b.Visible = false
    if nx_string(form.sl_round) ~= nx_string("") then
      local gb = form.gsb_round:Find("gb_round_" .. nx_string(form.sl_round))
      if nx_is_valid(gb) then
        local cbtn_old = gb:Find("cbtn_sl_" .. nx_string(form.sl_round))
        if nx_is_valid(cbtn_old) then
          form.sl_round = cbtn.sl_round
          cbtn_old.Checked = false
        end
      end
      custom_agree_war(nx_int(14), nx_int(form.sl_round), nx_int(0))
      init_camp()
    else
      form.sl_round = cbtn.sl_round
    end
  elseif nx_string(form.sl_round) == nx_string(cbtn.sl_round) then
    cbtn.Checked = true
  end
end
function update_round_info(info)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local info_list = util_split_string(info)
  local cur_round = nx_number(info_list[1])
  form.cur_round = cur_round
  form.gsb_round.IsEditMode = true
  form.gsb_round:DeleteAll()
  local index = 1
  for i = 1, cur_round do
    local gb_round = create_ctrl("GroupBox", "gb_round_" .. nx_string(i), form.gb_model, form.gsb_round)
    gb_round.Left = 0
    local cbtn_sl = create_ctrl("CheckButton", "cbtn_sl_" .. nx_string(i), form.cbtn_sl, gb_round)
    cbtn_sl.sl_round = i
    nx_bind_script(cbtn_sl, nx_current())
    nx_callback(cbtn_sl, "on_checked_changed", "on_cbtn_sl_checked_changed")
    local lbl_round = create_ctrl("Label", "lbl_round_" .. nx_string(i), form.lbl_round, gb_round)
    local lbl_round_score_a = create_ctrl("Label", "lbl_round_score_a_" .. nx_string(i), form.lbl_round_score_a, gb_round)
    local lbl_round_score_b = create_ctrl("Label", "lbl_round_score_b_" .. nx_string(i), form.lbl_round_score_b, gb_round)
    local lbl_round_point_a = create_ctrl("Label", "lbl_round_point_a_" .. nx_string(i), form.lbl_round_point_a, gb_round)
    local lbl_round_point_b = create_ctrl("Label", "lbl_round_point_b_" .. nx_string(i), form.lbl_round_point_b, gb_round)
    local lbl_mod_1 = create_ctrl("Label", "lbl_mod_1_" .. nx_string(i), form.lbl_mod_1, gb_round)
    local lbl_mod_2 = create_ctrl("Label", "lbl_mod_2_" .. nx_string(i), form.lbl_mod_2, gb_round)
    local lbl_mod_3 = create_ctrl("Label", "lbl_mod_3_" .. nx_string(i), form.lbl_mod_3, gb_round)
    local lbl_mod_4 = create_ctrl("Label", "lbl_mod_4_" .. nx_string(i), form.lbl_mod_4, gb_round)
    local lbl_light = create_ctrl("Label", "lbl_light_" .. nx_string(i), form.lbl_light, gb_round)
    if i == cur_round then
      cbtn_sl.Checked = true
    end
    local score_a = info_list[index + 1]
    local score_b = info_list[index + 2]
    local point_a = info_list[index + 3]
    local point_b = info_list[index + 4]
    if nx_int(score_a) == nx_int(-1) then
      score_a = "--"
    end
    if nx_int(score_b) == nx_int(-1) then
      score_b = "--"
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_agree_war_round", nx_int(i))
    lbl_round.Text = nx_widestr(text)
    lbl_round_score_a.Text = nx_widestr(score_a)
    lbl_round_score_b.Text = nx_widestr(score_b)
    lbl_round_point_a.Text = nx_widestr(point_a)
    lbl_round_point_b.Text = nx_widestr(point_b)
    if nx_widestr(score_a) == nx_widestr(0) and nx_widestr(score_b) == nx_widestr(0) then
      lbl_light.BackImage = form.lbl_draw.BackImage
      lbl_light.Visible = true
    elseif nx_int(form.my_camp_id) == nx_int(2351) then
      if nx_widestr(score_a) == nx_widestr(1) then
        lbl_light.BackImage = form.lbl_win.BackImage
        lbl_light.Visible = true
      elseif nx_widestr(score_a) == nx_widestr(0) then
        lbl_light.BackImage = form.lbl_lose.BackImage
        lbl_light.Visible = true
      end
    elseif nx_int(form.my_camp_id) == nx_int(2352) then
      if nx_widestr(score_b) == nx_widestr(1) then
        lbl_light.BackImage = form.lbl_win.BackImage
        lbl_light.Visible = true
      elseif nx_widestr(score_b) == nx_widestr(0) then
        lbl_light.BackImage = form.lbl_lose.BackImage
        lbl_light.Visible = true
      end
    end
    index = index + 4
  end
  form.gsb_round.IsEditMode = false
  form.gsb_round:ResetChildrenYPos()
end
function update_fight_info(camp_id, info)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local textgrid_all, textgrid_self
  if nx_int(2351) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_a
    textgrid_self = form.textgrid_self_a
  elseif nx_int(2352) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_b
    textgrid_self = form.textgrid_self_b
  else
    return
  end
  local round = form.cur_round
  local gb_round = form.gsb_round:Find("gb_round_" .. nx_string(round))
  local lbl_round_score_a = gb_round:Find("lbl_round_score_a_" .. nx_string(round))
  local lbl_round_score_b = gb_round:Find("lbl_round_score_b_" .. nx_string(round))
  form.lbl_round_res_a.Visible = false
  form.lbl_round_res_b.Visible = false
  if nx_widestr(lbl_round_score_a.Text) == nx_widestr(0) and nx_widestr(lbl_round_score_b.Text) == nx_widestr(0) then
    form.lbl_round_res_a.BackImage = form.lbl_round_draw.BackImage
    form.lbl_round_res_a.Visible = true
    form.lbl_round_res_b.BackImage = form.lbl_round_draw.BackImage
    form.lbl_round_res_b.Visible = true
  else
    if nx_widestr(lbl_round_score_a.Text) == nx_widestr(1) then
      form.lbl_round_res_a.BackImage = form.lbl_round_win.BackImage
      form.lbl_round_res_a.Visible = true
    elseif nx_widestr(lbl_round_score_a.Text) == nx_widestr(0) then
      form.lbl_round_res_a.BackImage = form.lbl_round_lose.BackImage
      form.lbl_round_res_a.Visible = true
    end
    if nx_widestr(lbl_round_score_b.Text) == nx_widestr(1) then
      form.lbl_round_res_b.BackImage = form.lbl_round_win.BackImage
      form.lbl_round_res_b.Visible = true
    elseif nx_widestr(lbl_round_score_b.Text) == nx_widestr(0) then
      form.lbl_round_res_b.BackImage = form.lbl_round_lose.BackImage
      form.lbl_round_res_b.Visible = true
    end
  end
  local info_list = util_split_string(info)
  local index = 1
  index = index + 1
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  local player_name = client_role:QueryProp("Name")
  index = index + 1
  local rows = info_list[index]
  local cache_table = {}
  for i = 1, rows do
    local player_name = info_list[index + 1]
    local guild_name = info_list[index + 2]
    local level_title = info_list[index + 3]
    local damage = info_list[index + 4]
    local kill = info_list[index + 5]
    local assist = info_list[index + 6]
    local dead = info_list[index + 7]
    local relive = info_list[index + 8]
    local bedamage = info_list[index + 9]
    local nurse = info_list[index + 10]
    index = index + 10
    table.insert(cache_table, {
      player_name,
      guild_name,
      level_title,
      damage,
      kill,
      assist,
      dead,
      relive,
      bedamage,
      nurse
    })
  end
  table.sort(cache_table, function(a, b)
    return a[5] > b[5]
  end)
  textgrid_all:BeginUpdate()
  textgrid_self:BeginUpdate()
  textgrid_all:ClearRow()
  textgrid_self:ClearRow()
  textgrid_self:InsertRow(-1)
  textgrid_self:SetGridText(0, 0, nx_widestr("--"))
  textgrid_self:SetGridText(0, 1, nx_widestr("--"))
  textgrid_self:SetGridText(0, 2, nx_widestr("--"))
  textgrid_self:SetGridText(0, 3, nx_widestr("--"))
  textgrid_self:SetGridText(0, 4, nx_widestr("--"))
  textgrid_self:SetGridText(0, 5, nx_widestr("--"))
  textgrid_self:SetGridText(0, 6, nx_widestr("--"))
  textgrid_self:SetGridText(0, 7, nx_widestr("--"))
  textgrid_self:SetGridText(0, 8, nx_widestr("--"))
  textgrid_self:SetGridText(0, 9, nx_widestr("--"))
  for i = 1, table.getn(cache_table) do
    local row = textgrid_all:InsertRow(-1)
    textgrid_all:SetGridText(row, 0, nx_widestr(row + 1))
    textgrid_all:SetGridText(row, 1, nx_widestr(cache_table[i][1]))
    textgrid_all:SetGridText(row, 2, nx_widestr(cache_table[i][2]))
    textgrid_all:SetGridText(row, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
    textgrid_all:SetGridText(row, 4, nx_widestr(cache_table[i][4]))
    textgrid_all:SetGridText(row, 5, nx_widestr(cache_table[i][5]))
    textgrid_all:SetGridText(row, 6, nx_widestr(cache_table[i][6]))
    textgrid_all:SetGridText(row, 7, nx_widestr(cache_table[i][7]))
    textgrid_all:SetGridText(row, 8, nx_widestr(cache_table[i][8]))
    textgrid_all:SetGridText(row, 9, nx_widestr(cache_table[i][9]))
    if nx_widestr(player_name) == nx_widestr(cache_table[i][1]) then
      textgrid_self:SetGridText(0, 0, nx_widestr(row + 1))
      textgrid_self:SetGridText(0, 1, nx_widestr(cache_table[i][1]))
      textgrid_self:SetGridText(0, 2, nx_widestr(cache_table[i][2]))
      textgrid_self:SetGridText(0, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
      textgrid_self:SetGridText(0, 4, nx_widestr(cache_table[i][4]))
      textgrid_self:SetGridText(0, 5, nx_widestr(cache_table[i][5]))
      textgrid_self:SetGridText(0, 6, nx_widestr(cache_table[i][6]))
      textgrid_self:SetGridText(0, 7, nx_widestr(cache_table[i][7]))
      textgrid_self:SetGridText(0, 8, nx_widestr(cache_table[i][8]))
      textgrid_self:SetGridText(0, 9, nx_widestr(cache_table[i][9]))
      textgrid_all:SetGridForeColor(row, 1, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 2, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 3, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 4, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 5, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 6, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 7, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 8, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 9, GRID_TEXT_COLOR)
    end
  end
  textgrid_all:EndUpdate()
  textgrid_self:EndUpdate()
end
function update_ready_info(camp_id, info)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local textgrid_all, textgrid_self
  if nx_int(2351) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_a
    textgrid_self = form.textgrid_self_a
  elseif nx_int(2352) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_b
    textgrid_self = form.textgrid_self_b
  else
    return
  end
  local info_list = util_split_string(info)
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  local player_name = client_role:QueryProp("Name")
  local index = 1
  local rows = info_list[index]
  local cache_table = {}
  for i = 1, rows do
    local player_name = info_list[index + 1]
    local guild_name = info_list[index + 2]
    local level_title = info_list[index + 3]
    local damage = 0
    local kill = 0
    local assist = 0
    local dead = 0
    local relive = 0
    local bedamage = 0
    local nurse = 0
    index = index + 4
    table.insert(cache_table, {
      player_name,
      guild_name,
      level_title,
      damage,
      kill,
      assist,
      dead,
      relive,
      bedamage,
      nurse
    })
  end
  table.sort(cache_table, function(a, b)
    return a[3] > b[3]
  end)
  textgrid_all:BeginUpdate()
  textgrid_self:BeginUpdate()
  textgrid_all:ClearRow()
  textgrid_self:ClearRow()
  textgrid_self:InsertRow(-1)
  textgrid_self:SetGridText(0, 0, nx_widestr("--"))
  textgrid_self:SetGridText(0, 1, nx_widestr("--"))
  textgrid_self:SetGridText(0, 2, nx_widestr("--"))
  textgrid_self:SetGridText(0, 3, nx_widestr("--"))
  textgrid_self:SetGridText(0, 4, nx_widestr("--"))
  textgrid_self:SetGridText(0, 5, nx_widestr("--"))
  textgrid_self:SetGridText(0, 6, nx_widestr("--"))
  textgrid_self:SetGridText(0, 7, nx_widestr("--"))
  textgrid_self:SetGridText(0, 8, nx_widestr("--"))
  textgrid_self:SetGridText(0, 9, nx_widestr("--"))
  for i = 1, table.getn(cache_table) do
    local row = textgrid_all:InsertRow(-1)
    textgrid_all:SetGridText(row, 0, nx_widestr(row + 1))
    textgrid_all:SetGridText(row, 1, nx_widestr(cache_table[i][1]))
    textgrid_all:SetGridText(row, 2, nx_widestr(cache_table[i][2]))
    textgrid_all:SetGridText(row, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
    textgrid_all:SetGridText(row, 4, nx_widestr(cache_table[i][4]))
    textgrid_all:SetGridText(row, 5, nx_widestr(cache_table[i][5]))
    textgrid_all:SetGridText(row, 6, nx_widestr(cache_table[i][6]))
    textgrid_all:SetGridText(row, 7, nx_widestr(cache_table[i][7]))
    textgrid_all:SetGridText(row, 8, nx_widestr(cache_table[i][8]))
    textgrid_all:SetGridText(row, 9, nx_widestr(cache_table[i][9]))
    if nx_widestr(player_name) == nx_widestr(cache_table[i][1]) then
      textgrid_self:SetGridText(0, 0, nx_widestr(row + 1))
      textgrid_self:SetGridText(0, 1, nx_widestr(cache_table[i][1]))
      textgrid_self:SetGridText(0, 2, nx_widestr(cache_table[i][2]))
      textgrid_self:SetGridText(0, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
      textgrid_self:SetGridText(0, 4, nx_widestr(cache_table[i][4]))
      textgrid_self:SetGridText(0, 5, nx_widestr(cache_table[i][5]))
      textgrid_self:SetGridText(0, 6, nx_widestr(cache_table[i][6]))
      textgrid_self:SetGridText(0, 7, nx_widestr(cache_table[i][7]))
      textgrid_self:SetGridText(0, 8, nx_widestr(cache_table[i][8]))
      textgrid_self:SetGridText(0, 9, nx_widestr(cache_table[i][9]))
      textgrid_all:SetGridForeColor(row, 1, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 2, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 3, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 4, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 5, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 6, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 7, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 8, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 9, GRID_TEXT_COLOR)
    end
  end
  textgrid_all:EndUpdate()
  textgrid_self:EndUpdate()
end
function update_round_more_info(camp_id, info)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local textgrid_all, textgrid_self
  if nx_int(2351) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_a
    textgrid_self = form.textgrid_self_a
  elseif nx_int(2352) == nx_int(camp_id) then
    textgrid_all = form.textgrid_all_b
    textgrid_self = form.textgrid_self_b
  else
    return
  end
  local info_list = util_split_string(info)
  local round = info_list[1]
  local gb_round = form.gsb_round:Find("gb_round_" .. nx_string(round))
  local lbl_round_score_a = gb_round:Find("lbl_round_score_a_" .. nx_string(round))
  local lbl_round_score_b = gb_round:Find("lbl_round_score_b_" .. nx_string(round))
  form.lbl_round_res_a.Visible = false
  form.lbl_round_res_b.Visible = false
  if nx_widestr(lbl_round_score_a.Text) == nx_widestr(0) and nx_widestr(lbl_round_score_b.Text) == nx_widestr(0) then
    form.lbl_round_res_a.BackImage = form.lbl_round_draw.BackImage
    form.lbl_round_res_a.Visible = true
    form.lbl_round_res_b.BackImage = form.lbl_round_draw.BackImage
    form.lbl_round_res_b.Visible = true
  else
    if nx_widestr(lbl_round_score_a.Text) == nx_widestr(1) then
      form.lbl_round_res_a.BackImage = form.lbl_round_win.BackImage
      form.lbl_round_res_a.Visible = true
    elseif nx_widestr(lbl_round_score_a.Text) == nx_widestr(0) then
      form.lbl_round_res_a.BackImage = form.lbl_round_lose.BackImage
      form.lbl_round_res_a.Visible = true
    end
    if nx_widestr(lbl_round_score_b.Text) == nx_widestr(1) then
      form.lbl_round_res_b.BackImage = form.lbl_round_win.BackImage
      form.lbl_round_res_b.Visible = true
    elseif nx_widestr(lbl_round_score_b.Text) == nx_widestr(0) then
      form.lbl_round_res_b.BackImage = form.lbl_round_lose.BackImage
      form.lbl_round_res_b.Visible = true
    end
  end
  local score_a = info_list[3]
  local point_a = info_list[4]
  local damage_a = info_list[5]
  local kill_a = info_list[6]
  local dead_a = info_list[7]
  local relive_a = info_list[8]
  local score_b = info_list[9]
  local point_b = info_list[10]
  local damage_b = info_list[11]
  local kill_b = info_list[12]
  local dead_b = info_list[13]
  local relive_b = info_list[14]
  index = 14
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  if not client_role:FindProp("Name") then
    return
  end
  local player_name = client_role:QueryProp("Name")
  index = index + 1
  local rows = info_list[index]
  local cache_table = {}
  for i = 1, rows do
    local player_name = info_list[index + 1]
    local guild_name = info_list[index + 2]
    local level_title = info_list[index + 3]
    local damage = info_list[index + 4]
    local kill = info_list[index + 5]
    local assist = info_list[index + 6]
    local dead = info_list[index + 7]
    local relive = info_list[index + 8]
    local bedamage = info_list[index + 9]
    local nurse = info_list[index + 10]
    index = index + 10
    table.insert(cache_table, {
      player_name,
      guild_name,
      level_title,
      damage,
      kill,
      assist,
      dead,
      relive,
      bedamage,
      nurse
    })
  end
  table.sort(cache_table, function(a, b)
    return a[5] > b[5]
  end)
  textgrid_all:BeginUpdate()
  textgrid_self:BeginUpdate()
  textgrid_all:ClearRow()
  textgrid_self:ClearRow()
  textgrid_self:InsertRow(-1)
  textgrid_self:SetGridText(0, 0, nx_widestr("--"))
  textgrid_self:SetGridText(0, 1, nx_widestr("--"))
  textgrid_self:SetGridText(0, 2, nx_widestr("--"))
  textgrid_self:SetGridText(0, 3, nx_widestr("--"))
  textgrid_self:SetGridText(0, 4, nx_widestr("--"))
  textgrid_self:SetGridText(0, 5, nx_widestr("--"))
  textgrid_self:SetGridText(0, 6, nx_widestr("--"))
  textgrid_self:SetGridText(0, 7, nx_widestr("--"))
  textgrid_self:SetGridText(0, 8, nx_widestr("--"))
  textgrid_self:SetGridText(0, 9, nx_widestr("--"))
  for i = 1, table.getn(cache_table) do
    local row = textgrid_all:InsertRow(-1)
    textgrid_all:SetGridText(row, 0, nx_widestr(row + 1))
    textgrid_all:SetGridText(row, 1, nx_widestr(cache_table[i][1]))
    textgrid_all:SetGridText(row, 2, nx_widestr(cache_table[i][2]))
    textgrid_all:SetGridText(row, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
    textgrid_all:SetGridText(row, 4, nx_widestr(cache_table[i][4]))
    textgrid_all:SetGridText(row, 5, nx_widestr(cache_table[i][5]))
    textgrid_all:SetGridText(row, 6, nx_widestr(cache_table[i][6]))
    textgrid_all:SetGridText(row, 7, nx_widestr(cache_table[i][7]))
    textgrid_all:SetGridText(row, 8, nx_widestr(cache_table[i][8]))
    textgrid_all:SetGridText(row, 9, nx_widestr(cache_table[i][9]))
    if nx_widestr(player_name) == nx_widestr(cache_table[i][1]) then
      textgrid_self:SetGridText(0, 0, nx_widestr(row + 1))
      textgrid_self:SetGridText(0, 1, nx_widestr(cache_table[i][1]))
      textgrid_self:SetGridText(0, 2, nx_widestr(cache_table[i][2]))
      textgrid_self:SetGridText(0, 3, nx_widestr(util_text("desc_" .. cache_table[i][3])))
      textgrid_self:SetGridText(0, 4, nx_widestr(cache_table[i][4]))
      textgrid_self:SetGridText(0, 5, nx_widestr(cache_table[i][5]))
      textgrid_self:SetGridText(0, 6, nx_widestr(cache_table[i][6]))
      textgrid_self:SetGridText(0, 7, nx_widestr(cache_table[i][7]))
      textgrid_self:SetGridText(0, 8, nx_widestr(cache_table[i][8]))
      textgrid_self:SetGridText(0, 9, nx_widestr(cache_table[i][9]))
      textgrid_all:SetGridForeColor(row, 1, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 2, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 3, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 4, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 5, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 6, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 7, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 8, GRID_TEXT_COLOR)
      textgrid_all:SetGridForeColor(row, 9, GRID_TEXT_COLOR)
    end
  end
  textgrid_all:EndUpdate()
  textgrid_self:EndUpdate()
end
function update_war_res(my_camp_id, camp_win)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.my_camp_id = my_camp_id
  form.camp_win = camp_win
  form.lbl_war_res.Visible = true
  form.btn_leader_award.Visible = true
  if nx_int(my_camp_id) == nx_int(camp_win) then
    form.lbl_war_res.BackImage = form.lbl_war_win.BackImage
    form.btn_laba_1.Visible = true
    check_show_btn_laba_2()
  else
    form.lbl_war_res.BackImage = form.lbl_war_lose.BackImage
  end
end
function check_show_btn_laba_2()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local score_a = 0
  local score_b = 0
  local point_a = 0
  local point_b = 0
  for i = 1, nx_number(form.cur_round) do
    local gb = form.gsb_round:Find("gb_round_" .. nx_string(i))
    if nx_is_valid(gb) then
      local lbl_score_a = gb:Find("lbl_round_score_a_" .. nx_string(i))
      local lbl_score_b = gb:Find("lbl_round_score_b_" .. nx_string(i))
      local lbl_point_a = gb:Find("lbl_round_point_a_" .. nx_string(i))
      local lbl_point_b = gb:Find("lbl_round_point_b_" .. nx_string(i))
      score_a = score_a + nx_number(lbl_score_a.Text)
      score_b = score_b + nx_number(lbl_score_b.Text)
      point_a = point_a + nx_number(lbl_point_a.Text)
      point_b = point_b + nx_number(lbl_point_b.Text)
    end
  end
  if point_a ~= 0 or point_b ~= 0 then
    return
  end
  if score_a ~= 0 and score_b ~= 0 then
    return
  end
  if score_a == 0 and score_b == 0 then
    return
  end
  form.btn_laba_2.Visible = true
end
function change_stage()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
end
function init_textgrid(form)
  form.textgrid_all_a:SetColTitle(0, nx_widestr(util_text("ui_agree_war_list_1")))
  form.textgrid_all_a:SetColTitle(1, nx_widestr(util_text("ui_agree_war_list_2")))
  form.textgrid_all_a:SetColTitle(2, nx_widestr(util_text("ui_agree_war_list_3")))
  form.textgrid_all_a:SetColTitle(3, nx_widestr(util_text("ui_agree_war_list_4")))
  form.textgrid_all_a:SetColTitle(4, nx_widestr(util_text("ui_agree_war_list_5")))
  form.textgrid_all_a:SetColTitle(5, nx_widestr(util_text("ui_agree_war_list_6")))
  form.textgrid_all_a:SetColTitle(6, nx_widestr(util_text("ui_agree_war_list_7")))
  form.textgrid_all_a:SetColTitle(7, nx_widestr(util_text("ui_agree_war_list_8")))
  form.textgrid_all_a:SetColTitle(8, nx_widestr(util_text("ui_agree_war_list_9")))
  form.textgrid_all_a:SetColTitle(9, nx_widestr(util_text("ui_agree_war_list_10")))
  form.textgrid_all_b:SetColTitle(0, nx_widestr(util_text("ui_agree_war_list_1")))
  form.textgrid_all_b:SetColTitle(1, nx_widestr(util_text("ui_agree_war_list_2")))
  form.textgrid_all_b:SetColTitle(2, nx_widestr(util_text("ui_agree_war_list_3")))
  form.textgrid_all_b:SetColTitle(3, nx_widestr(util_text("ui_agree_war_list_4")))
  form.textgrid_all_b:SetColTitle(4, nx_widestr(util_text("ui_agree_war_list_5")))
  form.textgrid_all_b:SetColTitle(5, nx_widestr(util_text("ui_agree_war_list_6")))
  form.textgrid_all_b:SetColTitle(6, nx_widestr(util_text("ui_agree_war_list_7")))
  form.textgrid_all_b:SetColTitle(7, nx_widestr(util_text("ui_agree_war_list_8")))
  form.textgrid_all_b:SetColTitle(8, nx_widestr(util_text("ui_agree_war_list_9")))
  form.textgrid_all_b:SetColTitle(9, nx_widestr(util_text("ui_agree_war_list_10")))
end
function init_camp()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local form_score = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_score", false)
  local is_ready = false
  if nx_is_valid(form_score) then
    form.my_camp_id = form_score.my_camp_id
  else
    form.my_camp_id = 2351
    return
  end
  form.rbtn_camp_a.Text = form_score.lbl_guild_a.Text
  form.rbtn_camp_b.Text = form_score.lbl_guild_b.Text
  if nx_int(form.my_camp_id) == nx_int(2351) then
    form.rbtn_camp_a.Checked = true
    is_ready = form_score.lbl_ready_a.Visible
  elseif nx_int(form.my_camp_id) == nx_int(2352) then
    form.rbtn_camp_b.Checked = true
    is_ready = form_score.lbl_ready_b.Visible
  end
  if is_ready then
    form.btn_ready.Visible = false
    form.btn_ready_cancel.Visible = true
  else
    form.btn_ready.Visible = true
    form.btn_ready_cancel.Visible = false
  end
  if nx_int(form_score.lbl_stage.Text) ~= nx_int(0) then
    form.btn_ready_cancel.Visible = false
  end
end
function send_laba_test(chat_str)
  local switch = nx_execute("form_stage_main\\form_main\\form_laba_info", "get_used_card_type")
  nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, 1, "", switch)
end
function get_leader_award_win_cost_by_scale(scale)
  return scene_tab[nx_number(scale)].leader_awar_win_cost
end
function get_leader_award_lose_cost_by_scale(scale)
  return scene_tab[nx_number(scale)].leader_awar_lose_cost
end
function load_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\agree_war\\agree_war.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section = ini:FindSectionIndex("property")
  if section < 0 then
    return
  end
  scene_tab = {}
  local scene_id_str = ini:ReadString(section, "scene_id", "")
  local leader_awar_win_cost_str = ini:ReadString(section, "leader_award_win_cost", "")
  local leader_awar_lose_cost_str = ini:ReadString(section, "leader_award_lose_cost", "")
  local scene_id_list = util_split_string(scene_id_str, ",")
  local leader_awar_win_cost_list = util_split_string(leader_awar_win_cost_str, ",")
  local leader_awar_lose_cost_list = util_split_string(leader_awar_lose_cost_str, ",")
  for i = 1, table.getn(scene_id_list) do
    local scene_id = nx_int(scene_id_list[i])
    local tab = {}
    tab.scene_id = scene_id
    tab.leader_awar_win_cost = nx_int(leader_awar_win_cost_list[i])
    tab.leader_awar_lose_cost = nx_int(leader_awar_lose_cost_list[i])
    table.insert(scene_tab, i, tab)
  end
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
