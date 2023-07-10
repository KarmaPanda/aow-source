require("util_gui")
require("util_functions")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_war_res"
local GRID_TEXT_COLOR_SELF = "0,179,139,114"
local GRID_TEXT_COLOR_OUT = "0,255,0,114"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.left_time = 60
  init_grid(form)
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
  form.lbl_left_time.Text = nx_widestr(form.left_time)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
  update_form(1, "\210\187", 11, 1, "ng1", "wx1", "wx2", 3, 1, 1, 10, "\188\242\203\216\199\228", 22, 1, "ng2", "wx12", "wx22", 2, 2, 2, 20, "\200\253", 33, 0, "ng3", "wx13", "wx23", 1, 3, 3, 30, 0, "\203\196", 11, 1, "ng1", "wx1", "wx2", 1, 4, 4, 40, "\182\254", 22, 0, "ng2", "wx12", "wx22", 2, 2, 2, 20, "\200\253", 33, 1, "ng3", "wx13", "wx23", 3, 1, 1, -30)
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
function on_btn_leave_click(btn)
  custom_kof(CTS_SUB_KOF_LEAVE)
end
function init_grid(form)
  for i = 1, 2 do
    local tg = form:Find("tg_" .. nx_string(i))
    tg:SetColTitle(0, nx_widestr(util_text("ui_kof_tg_1")))
    tg:SetColTitle(1, nx_widestr(util_text("ui_kof_tg_2")))
    tg:SetColTitle(2, nx_widestr(util_text("ui_kof_tg_3")))
    tg:SetColTitle(3, nx_widestr(util_text("ui_kof_tg_4")))
    tg:SetColTitle(4, nx_widestr(util_text("ui_kof_tg_5")))
    tg:SetColTitle(5, nx_widestr(util_text("ui_kof_tg_6")))
    tg:SetColTitle(6, nx_widestr(util_text("ui_kof_tg_7")))
    tg:SetColTitle(7, nx_widestr(util_text("ui_kof_tg_8")))
  end
end
function update_form(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  for i = 1, 2 do
    local is_win = nx_number(arg[1 + (i - 1) * 31])
    local arg_index = 1 + (i - 1) * 31
    local tab_info = {}
    for j = 1, 3 do
      local player_name = nx_widestr(arg[arg_index + 1 + (j - 1) * 10])
      local score = nx_number(arg[arg_index + 2 + (j - 1) * 10])
      local is_in = nx_number(arg[arg_index + 3 + (j - 1) * 10])
      local neigong = nx_string(arg[arg_index + 4 + (j - 1) * 10])
      local wuxue1 = nx_string(arg[arg_index + 5 + (j - 1) * 10])
      local wuxue2 = nx_string(arg[arg_index + 6 + (j - 1) * 10])
      local no = nx_number(arg[arg_index + 7 + (j - 1) * 10])
      local kill = nx_number(arg[arg_index + 8 + (j - 1) * 10])
      local damage = nx_number(arg[arg_index + 9 + (j - 1) * 10])
      local score_diff = nx_number(arg[arg_index + 10 + (j - 1) * 10])
      table.insert(tab_info, {
        player_name,
        score,
        is_in,
        neigong,
        wuxue1,
        wuxue2,
        no,
        kill,
        damage,
        score_diff
      })
    end
    table.sort(tab_info, function(a, b)
      return a[7] < b[7]
    end)
    local lbl_res = form:Find("lbl_res_" .. nx_string(i))
    local tg = form:Find("tg_" .. nx_string(i))
    if is_win == 1 then
      lbl_res.BackImage = "gui\\guild\\guild_battle\\B_win.png"
    else
      lbl_res.BackImage = "gui\\guild\\guild_battle\\B_lose.png"
    end
    for i = 1, #tab_info do
      local player_name = tab_info[i][1]
      local score = tab_info[i][2]
      local is_in = tab_info[i][3]
      local neigong = tab_info[i][4]
      local wuxue1 = tab_info[i][5]
      local wuxue2 = tab_info[i][6]
      local no = tab_info[i][7]
      local kill = tab_info[i][8]
      local damage = tab_info[i][9]
      local score_diff = tab_info[i][10]
      local row = tg:InsertRow(-1)
      tg:SetGridText(row, 0, nx_widestr(i))
      tg:SetGridText(row, 1, nx_widestr(player_name))
      tg:SetGridText(row, 2, nx_widestr(util_text(neigong)))
      tg:SetGridText(row, 3, nx_widestr(util_text(wuxue1)))
      tg:SetGridText(row, 4, nx_widestr(util_text(wuxue2)))
      tg:SetGridText(row, 5, nx_widestr(kill))
      tg:SetGridText(row, 6, nx_widestr(damage))
      tg:SetGridText(row, 7, nx_widestr(score_diff))
      if 3 <= kill then
        show_bg(form, tg, row)
      end
      if is_main_player(player_name) then
        tg:SetGridBackColor(row, 0, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 1, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 2, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 3, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 4, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 5, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 6, GRID_TEXT_COLOR_SELF)
        tg:SetGridBackColor(row, 7, GRID_TEXT_COLOR_SELF)
      end
      if is_in == 0 then
        tg:SetGridBackColor(row, 0, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 1, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 2, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 3, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 4, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 5, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 6, GRID_TEXT_COLOR_OUT)
        tg:SetGridBackColor(row, 7, GRID_TEXT_COLOR_OUT)
      end
    end
  end
end
function show_bg(form, tg, row)
  local lbl_bg = create_ctrl("Label", "lbl_" .. nx_string(tg.Text) .. "_" .. nx_string(row), form.lbl_bg_mod, form)
  lbl_bg.Left = tg.Left
  lbl_bg.Top = tg.Top + tg.HeaderRowHeight + tg.RowHeight * row
  form:ToFront(form.tg_1)
  form:ToFront(form.tg_2)
end
function is_main_player(player_name)
  local player = get_player()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("Name") then
    return false
  end
  return player_name == player:QueryProp("Name")
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function a(b)
  nx_msgbox(nx_string(b))
end
