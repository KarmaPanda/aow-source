require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
require("share\\itemtype_define")
require("custom_sender")
require("share\\chat_define")
lj = 2
js = 3
zj = 4
bz = 5
qb = 6
local players = {}
local player_ballot_msg = {}
local players_pm = {}
local mvp_type = zj
local count = 0
local mvp_all_ps, lable_busying, lable_free
local speed = 0
local name_yxt
local vote_zc = 0
local vote_fd = 1
local vote_sj = 2
local vote_zy = 3
local vote_zj = 4
local image_type = {
  [2] = {
    down = "gui\\special\\huashan_mvp\\ljmx_down.png",
    on = "gui\\special\\huashan_mvp\\ljmx_on.png",
    out = "gui\\special\\huashan_mvp\\ljmx_out.png"
  },
  [3] = {
    down = "gui\\special\\huashan_mvp\\jssb_down.png",
    on = "gui\\special\\huashan_mvp\\jssb_on.png",
    out = "gui\\special\\huashan_mvp\\jssb_out.png"
  },
  [4] = {
    down = "gui\\special\\huashan_mvp\\zjwm_down.png",
    on = "gui\\special\\huashan_mvp\\zjwm_on.png",
    out = "gui\\special\\huashan_mvp\\zjwm_out.png"
  },
  [5] = {
    down = "gui\\special\\huashan_mvp\\bzll_down.png",
    on = "gui\\special\\huashan_mvp\\bzll_on.png",
    out = "gui\\special\\huashan_mvp\\bzll_out.png"
  },
  [6] = {
    down = "gui\\special\\huashan_mvp\\qpxm_down.png",
    on = "gui\\special\\huashan_mvp\\qpxm_on.png",
    out = "gui\\special\\huashan_mvp\\qpxm_out.png"
  }
}
local form_name = "form_stage_main\\form_huashan\\form_huashan_tp_mvp"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_get_mvp", 1)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  lable_busying = form.lbl_a
  lable_free = form.lbl_b
  add_btn_tips(form)
  form.btn_1.mvp = lj
  form.btn_2.mvp = js
  form.btn_3.mvp = bz
  form.btn_4.mvp = qb
end
function on_main_form_close(form)
  mvp_type = zj
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_btn_to_enable", form)
  end
  nx_destroy(form)
end
function reset_type(type_op)
  if type_op == 7 then
    type_op = 2
  elseif type_op == 1 then
    type_op = 6
  end
  return type_op
end
function refresh_mvp_image(form)
  form.lbl_a.BackImage = image_type[mvp_type].on
  form.btn_2.NormalImage = image_type[reset_type(mvp_type - 1)].out
  form.btn_2.FocusImage = image_type[reset_type(mvp_type - 1)].on
  form.btn_2.PushImage = image_type[reset_type(mvp_type - 1)].down
  form.btn_3.NormalImage = image_type[reset_type(mvp_type + 1)].out
  form.btn_3.FocusImage = image_type[reset_type(mvp_type + 1)].on
  form.btn_3.PushImage = image_type[reset_type(mvp_type + 1)].down
end
function donghua(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1, -1, nx_current(), "refresh_detail_info", form, -1, -1)
  end
end
function refresh_detail_info(form)
  if not nx_is_valid(form) then
    return
  end
  if lable_free.Left < 2 and lable_free.Left > -2 then
    lable_free.Left = 0
    lable_busying.Left = 300
    local lbl_ls = lable_busying
    lable_busying = lable_free
    lable_free = lbl_ls
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_detail_info", form)
    end
  else
    lable_busying.Left = lable_busying.Left + speed
    lable_free.Left = lable_free.Left + speed
  end
end
function open_form(...)
  mvp_all_ps = {
    [lj] = 0,
    [js] = 0,
    [zj] = 0,
    [bz] = 0,
    [qb] = 0
  }
  if nx_number(arg[1]) == 20 then
    CanSendYXT()
  end
  local mvp_plays = arg[2]
  local players_list = util_split_wstring(mvp_plays, nx_widestr(";"))
  count = table.getn(players_list) - 1
  for i = 1, count do
    local play_msg_list = util_split_wstring(players_list[i], nx_widestr(","))
    mvp_all_ps[lj] = mvp_all_ps[lj] + nx_int(play_msg_list[2])
    mvp_all_ps[js] = mvp_all_ps[js] + nx_int(play_msg_list[3])
    mvp_all_ps[zj] = mvp_all_ps[zj] + nx_int(play_msg_list[4])
    mvp_all_ps[bz] = mvp_all_ps[bz] + nx_int(play_msg_list[5])
    mvp_all_ps[qb] = mvp_all_ps[qb] + nx_int(play_msg_list[6])
    local op = {
      name = nx_widestr(play_msg_list[1]),
      [lj] = nx_widestr(play_msg_list[2]),
      [js] = nx_widestr(play_msg_list[3]),
      [zj] = nx_widestr(play_msg_list[4]),
      [bz] = nx_widestr(play_msg_list[5]),
      [qb] = nx_widestr(play_msg_list[6])
    }
    players[i] = op
  end
  refresh_mvp()
end
function refresh_mvp()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  px_mvp()
  refresh_ldt(form, count)
  refresh_st(form, 0)
  refresh_grid_list(form.textgrid_2)
  refresh_letter(form)
end
function px_mvp()
  for i = 1, count - 1 do
    for j = i + 1, count do
      if nx_int(players[i][mvp_type]) < nx_int(players[j][mvp_type]) then
        local temp = players[i]
        players[i] = players[j]
        players[j] = temp
      end
    end
  end
  for i = 1, count do
    players_pm[nx_string(players[i].name)] = {pm = 0, vote = 0}
    players_pm[nx_string(players[i].name)].pm = i
    players_pm[nx_string(players[i].name)].vote = nx_int(players[i][mvp_type])
  end
end
function refresh_ldt(form)
  local all_people_num = 0
  for i = 1, count do
    all_people_num = all_people_num + 1
  end
  if all_people_num < 6 then
    form.tbar_1.Maximum = 0
  else
    form.tbar_1.Value = 0
    form.tbar_1.Maximum = all_people_num - 6
  end
end
function refresh_st(form, value)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local num = 6
  if count < 6 then
    num = count
  end
  for i = 1, num do
    local grp_box = form.groupbox_8:Find(nx_string("groupbox_pbar_") .. nx_string(i))
    local grp_bar = grp_box:Find(nx_string("pbar_") .. nx_string(i))
    local grp_text = grp_box:Find(nx_string("mltbox_") .. nx_string(i))
    local grp_num = grp_box:Find(nx_string("lbl_num_") .. nx_string(i))
    grp_box.Visible = true
    grp_bar.Maximum = nx_int(players[1][mvp_type])
    grp_bar.Value = nx_int(players[value + i][mvp_type])
    grp_num.Text = players[value + i][mvp_type] .. nx_widestr(util_text("ui_huashan_dp"))
    grp_text.Text = players[value + i].name
    grp_box.BackImage, grp_bar.ProgressImage = choose_color_image(grp_bar.Value * 10 / grp_bar.Maximum)
  end
end
function refresh_letter(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_doc = get_ini("share\\War\\HuaShan\\huashan_mvp.ini")
  if nx_is_null(ini_doc) then
    nx_msgbox("ini\229\138\160\232\189\189\229\164\177\232\180\165")
    return false
  end
  local index = ini_doc:FindSectionIndex(nx_string(mvp_type - 1))
  local mvp_name = ini_doc:ReadString(index, "prize", "")
  local mvp_info = ini_doc:ReadString(index, "info", "")
  form.mltbox_7.Text = nx_widestr(gui.TextManager:GetText(mvp_name))
  form.mltbox_8.Text = nx_widestr(gui.TextManager:GetText(mvp_info))
end
function on_tbar_1_value_changed(tbar)
  local form = tbar.ParentForm
  refresh_st(form, nx_int(tbar.Value))
end
function refresh_grid_list(grid)
  if not nx_is_valid(grid) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  clear_grid_data(grid)
  local form = grid.ParentForm
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rows = client_player:GetRecordRows("HuaShanMvpVoteHistory")
  for i = 0, rows - 1 do
    if client_player:QueryRecord("HuaShanMvpVoteHistory", i, mvp_type) ~= 0 then
      local grid_row = grid:InsertRow(grid.RowCount)
      local name = client_player:QueryRecord("HuaShanMvpVoteHistory", i, 1)
      if players_pm[nx_string(name)] == nil then
        return
      end
      grid:SetGridText(grid_row, 0, name)
      grid:SetGridText(grid_row, 1, nx_widestr(players_pm[nx_string(name)].pm))
      grid:SetGridText(grid_row, 2, nx_widestr(players_pm[nx_string(name)].vote) .. nx_widestr(util_text("ui_huashan_dp")))
    end
  end
  grid:SortRowsByInt(1, false)
  for j = 0, grid.RowCount - 1 do
    local nPm = grid:GetGridText(j, 1)
    gui.TextManager:Format_SetIDName("ui_huashan_mc")
    gui.TextManager:Format_AddParam(nx_int(nPm))
    grid:SetGridText(j, 1, gui.TextManager:Format_GetText())
  end
  grid:EndUpdate()
end
function clear_grid_data(grid)
  if nx_is_valid(grid) then
    for i = 0, grid.RowCount - 1 do
      local data = grid:GetGridTag(i, 0)
      if nx_is_valid(data) then
        nx_destroy(data)
      end
    end
  end
end
function on_btn_vote_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local tp_type = 0
  if btn.Name == "btn_vote1" then
    tp_type = vote_zc
  elseif btn.Name == "btn_vote2" then
    tp_type = vote_fd
  elseif btn.Name == "btn_vote3" then
    tp_type = vote_sj
  elseif btn.Name == "btn_vote4" then
    tp_type = vote_zy
  elseif btn.Name == "btn_vote5" then
    tp_type = vote_zj
  end
  btn_to_false(form, btn)
  local dialog = nx_execute("form_stage_main\\form_huashan\\form_huashan_NameList", "open_form", 1, "ballot_mvp")
  name_yxt = nx_wait_event(100000000, dialog, "ballot_mvp")
  if name_yxt ~= "cancel" and name_yxt ~= "" then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_huashan\\form_huashan_ballot_tip", true, false)
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local tips = "ui_text_ticket" .. nx_string(tp_type + 1)
    dialog.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetText(tips))
    dialog:Show()
    local res = nx_wait_event(100000000, dialog, "ballot_result")
    if not nx_is_valid(form) then
      return
    end
    if res == "yes" then
      nx_execute("custom_sender", "custom_ballot", mvp_type, name_yxt, tp_type)
    end
  end
  btn_to_ture(form)
end
function choose_color_image(scale)
  if scale < 2.5 then
    return "gui\\special\\huashan_mvp\\cao1.png", "gui\\special\\huashan_mvp\\zhu1.png"
  elseif scale < 5 then
    return "gui\\special\\huashan_mvp\\cao2.png", "gui\\special\\huashan_mvp\\zhu2.png"
  elseif scale < 7.5 then
    return "gui\\special\\huashan_mvp\\cao3.png", "gui\\special\\huashan_mvp\\zhu3.png"
  else
    return "gui\\special\\huashan_mvp\\cao4.png", "gui\\special\\huashan_mvp\\zhu4.png"
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return
end
function get_pm_and_votes(name)
  for i = 1, count do
    if nx_widestr(players_pm[i].name) == nx_widestr(name) then
      return players_pm[i].pm, players_pm[i].vote
    end
  end
end
function add_btn_tips(form)
  local ini_doc = get_ini("share\\War\\HuaShan\\HuaShanMvpConfig.ini")
  if nx_is_null(ini_doc) then
    nx_msgbox("ini\229\138\160\232\189\189\229\164\177\232\180\165")
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini_counts = ini_doc:GetSectionCount()
  for i = 1, ini_counts do
    local money = ini_doc:ReadInteger(i - 1, "vote_cost", 0) / 1000
    if i == 5 then
      money = 50
    end
    local cd = ini_doc:ReadInteger(i - 1, "voteCD", 0)
    gui.TextManager:Format_SetIDName("ui_huashan_mvp_ticket" .. nx_string(i))
    gui.TextManager:Format_AddParam(money)
    gui.TextManager:Format_AddParam(cd)
    local grp_btn = form:Find(nx_string("btn_vote") .. nx_string(i))
    grp_btn.HintText = nx_widestr(gui.TextManager:Format_GetText())
  end
end
function on_btn_Mvp_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local mvp_tem = mvp_type
  mvp_type = btn.mvp
  btn.mvp = mvp_tem
  form.lbl_a.BackImage = image_type[mvp_type].on
  btn.NormalImage = image_type[btn.mvp].out
  btn.FocusImage = image_type[btn.mvp].on
  btn.PushImage = image_type[btn.mvp].down
  refresh_mvp()
end
function mvptype_to_text(index)
  if index == lj then
    return "huashan_mvp_name1"
  elseif index == js then
    return "huashan_mvp_name2"
  elseif index == zj then
    return "huashan_mvp_name3"
  elseif index == bz then
    return "huashan_mvp_name4"
  elseif index == qb then
    return "huashan_mvp_name5"
  end
end
function btn_to_false(form, btn)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 5 do
    local nbtn = form:Find(nx_string("btn_vote") .. nx_string(i))
    if nbtn.Name ~= btn.Name then
      nbtn.Enabled = false
    end
  end
end
function btn_to_ture(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 5 do
    local nbtn = form:Find(nx_string("btn_vote") .. nx_string(i))
    if not nbtn.Enabled then
      nbtn.Enabled = true
    end
  end
end
function on_btn_5_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_get_mvp", 1)
  btn.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(30000, 1, nx_current(), "refresh_btn_to_enable", form.btn_5, -1, -1)
  end
end
function refresh_btn_to_enable(btn)
  if nx_is_valid(btn) then
    btn.Enabled = true
  end
end
function CanSendYXT()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_huashan_yxt")
  gui.TextManager:Format_AddParam(name_yxt)
  gui.TextManager:Format_AddParam(gui.TextManager:GetText(mvptype_to_text(mvp_type)))
  local chat_str = nx_widestr(gui.TextManager:Format_GetText())
  local switch = nx_call("form_stage_main\\form_main\\form_laba_info", "get_used_card_type")
  nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, 1, "", switch)
end
