require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_league_matches\\form_lm_war_info"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  custom_league_matches(9)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
  else
    form:Close()
  end
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
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_side_1.Visible = true
    form.gb_side_2.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_side_1.Visible = false
    form.gb_side_2.Visible = true
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_drag_click(btn)
  nx_execute("form_stage_main\\form_league_matches\\form_lm_drag", "open_form")
end
function on_btn_leave_click(btn)
  custom_league_matches(2)
end
function on_lm_war_info(...)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
  local war_res = nx_number(arg[1])
  local player_side = nx_number(arg[2])
  local info_side = nx_number(arg[3])
  local rows = nx_number(arg[4])
  local tab_war_info = {}
  for i = 1, rows do
    local player_info = nx_widestr(arg[4 + i])
    local tab_info = util_split_wstring(player_info, ",")
    local player_name = nx_widestr(tab_info[1])
    local kill = nx_number(tab_info[2])
    local help = nx_number(tab_info[3])
    local dead = nx_number(tab_info[4])
    local damage = nx_number(tab_info[5])
    local score = nx_number(tab_info[6])
    table.insert(tab_war_info, {
      player_name,
      kill,
      help,
      dead,
      damage,
      score
    })
  end
  table.sort(tab_war_info, function(a, b)
    return a[2] > b[2]
  end)
  local tg_side
  if 0 == info_side then
    tg_side = form.tg_side_1
  else
    tg_side = form.tg_side_2
  end
  tg_side:ClearRow()
  for i = 1, table.getn(tab_war_info) do
    local player_name = tab_war_info[i][1]
    local kill = tab_war_info[i][2]
    local help = tab_war_info[i][3]
    local dead = tab_war_info[i][4]
    local damage = tab_war_info[i][5]
    local score = tab_war_info[i][6]
    local row = tg_side:InsertRow(-1)
    tg_side:SetGridText(row, 0, nx_widestr(i))
    tg_side:SetGridText(row, 1, nx_widestr(player_name))
    tg_side:SetGridText(row, 2, nx_widestr(kill))
    tg_side:SetGridText(row, 3, nx_widestr(help))
    tg_side:SetGridText(row, 4, nx_widestr(dead))
    tg_side:SetGridText(row, 5, nx_widestr(damage))
    tg_side:SetGridText(row, 6, nx_widestr(score))
    if get_player_name() == player_name then
      tg_side:SetGridForeColor(row, 0, "255,255,204,0")
      tg_side:SetGridForeColor(row, 1, "255,255,204,0")
      tg_side:SetGridForeColor(row, 2, "255,255,204,0")
      tg_side:SetGridForeColor(row, 3, "255,255,204,0")
      tg_side:SetGridForeColor(row, 4, "255,255,204,0")
      tg_side:SetGridForeColor(row, 5, "255,255,204,0")
      tg_side:SetGridForeColor(row, 6, "255,255,204,0")
    end
  end
  if 0 == player_side then
    form.rbtn_1.Checked = true
  else
    form.rbtn_2.Checked = true
  end
  if war_res ~= -1 then
    if war_res ~= player_side then
      form.lbl_res_win.Visible = true
      form.lbl_res_lose.Visible = false
    else
      form.lbl_res_win.Visible = false
      form.lbl_res_lose.Visible = true
    end
  else
    form.lbl_res_win.Visible = false
    form.lbl_res_lose.Visible = false
  end
end
function get_player_name()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  return nx_widestr(client_player:QueryProp("Name"))
end
function a(info)
  nx_msgbox(nx_string(info))
end
