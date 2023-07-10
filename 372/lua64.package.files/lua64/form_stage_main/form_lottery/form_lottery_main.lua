require("util_functions")
require("util_static_data")
require("util_gui")
local PlayerRequestLotteryForm = 0
local PlayerBuyLottery = 1
local GetYesterdayPrizeList = 2
local GetTodayPrizeList = 3
local ShowLotteryForm = 0
local ShowLastPrizeList = 1
local ShowTodayPrizeList = 2
local RefreshLotteryInfo = 3
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function on_main_form_init(form)
  form.Fixed = true
  form.day_limit_times = 0
  form.month_limit_times = 0
  form.cur_buy_times = 0
  form.cur_month_remain_times = 0
end
function on_main_form_open(form)
  nx_execute("custom_sender", "custom_lottery_msg", PlayerRequestLotteryForm)
  nx_execute("custom_sender", "custom_lottery_msg", GetTodayPrizeList)
  form.rbtn_good_luck.Checked = true
  set_lottery_item(form)
  refresh_lottery_code_list(form)
  form.textgrid_lottery_list:SetColTitle(0, get_text("ui_lottery_award_tips"))
  form.textgrid_lottery_list:SetColTitle(1, get_text("ui_lottery_award_tips_1"))
  form.textgrid_lottery_list:SetColTitle(2, get_text("ui_lottery_award_tips_2"))
  form.mltbox_lottery_desc:Clear()
  form.mltbox_lottery_desc:AddHtmlText(get_text("ui_lottery_tips_1"), -1)
  form.groupbox_code.Visible = false
  local LotterManager = nx_value("LotterManager")
  if nx_is_valid(LotterManager) then
    local info_tbl = LotterManager:GetLotteryDate()
    local length = table.getn(info_tbl)
    if 6 <= length then
      local lottery_date = nx_string(info_tbl[1]) .. "." .. nx_string(info_tbl[2]) .. "." .. nx_string(info_tbl[3]) .. "--" .. nx_string(info_tbl[4]) .. "." .. nx_string(info_tbl[5]) .. "." .. nx_string(info_tbl[6])
      form.lbl_date.Text = nx_widestr(lottery_date)
    end
  end
end
function set_lottery_item(form)
  local ini = get_ini("share\\Life\\Lottery.ini")
  if not nx_is_valid(ini) then
    return
  end
  if not ini:FindSection("Config") then
    return
  end
  local index = ini:FindSectionIndex("Config")
  if -1 == index then
    return
  end
  local day_lottery_cost = ini:ReadString(index, "DayLotteryCost", "")
  local day_prize_item = ini:ReadString(index, "DayPrizeItem", "")
  local day_prize_num = ini:ReadString(index, "DayPrizeNum", "")
  local month_lottery_cost = ini:ReadString(index, "MonthLotteryCost", "")
  local month_prize_item = ini:ReadString(index, "MonthPrizeItem", "")
  local month_prize_num = ini:ReadString(index, "MonthPrizeNum", "")
  local extra_prize_item = ini:ReadString(index, "ExtraPrizeItem", "")
  local extra_prize_num = ini:ReadString(index, "ExtraPrizeItemNum", "")
  form.MaxLottery = ini:ReadString(index, "MaxLottery", "")
  local day_item_name = get_text(day_prize_item)
  local day_item_name_num = get_text("ui_lottery_item", day_item_name, nx_int(day_prize_num))
  form.lbl_day_info.Text = day_item_name_num
  form.lbl_day_cost.Text = format_capital(nx_number(day_lottery_cost))
  local month_item_name = get_text(month_prize_item)
  local month_item_name_num = get_text("ui_lottery_item", month_item_name, nx_int(month_prize_num))
  form.lbl_month_info.Text = month_item_name_num
  form.lbl_month_cost.Text = format_capital(nx_number(month_lottery_cost))
  local month_prize_item_name_num = get_text("ui_lottery_item_1", nx_int(month_prize_num))
  form.month_extra_prize_info.Text = month_prize_item_name_num
  local day_prize_item_name_num = get_text("ui_lottery_item_1", nx_int(day_prize_num))
  form.day_extra_prize_info.Text = day_prize_item_name_num
end
function format_capital(capital)
  local ding = nx_int(capital / 1000000)
  local liang = nx_int((capital - 1000000 * ding) / 1000)
  local wen = nx_int(capital - 1000000 * ding - 1000 * liang)
  local str_capital = get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))
  return str_capital
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_good_luck_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.groupbox_luck.Visible = true
  else
    form.groupbox_luck.Visible = false
  end
end
function on_rbtn_today_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_lottery_msg", GetTodayPrizeList)
  end
end
function on_rbtn_last_checked_changed(cbtn)
  if cbtn.Checked then
    nx_execute("custom_sender", "custom_lottery_msg", GetYesterdayPrizeList)
  end
end
function on_btn_buy_day_click(btn)
  local client_player = get_player()
  local lottery_day = client_player:QueryProp("LotteryDay")
  if nx_int(lottery_day) > nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("16563"))
    return
  end
  local dialog = util_get_form("form_common\\form_connect", true, false)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  if not nx_is_valid(dialog) then
    return
  end
  dialog.btn_51089.Visible = false
  dialog.btn_url.Visible = false
  dialog.btn_ok.Top = 168
  dialog.btn_ok.Left = 120
  dialog.event_name = "buy_lottery"
  local day_lottery_cost = nx_int(form.lbl_price1.Text)
  dialog.info_mltbox.HtmlText = get_text("16566", get_text("ui_lottery_riling"), nx_int(day_lottery_cost) * nx_int(1000))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, dialog.event_name)
  if nx_is_valid(dialog) then
    dialog:Close()
    gui:Delete(dialog)
  end
  if nx_string("ok") == nx_string(res) then
    nx_execute("custom_sender", "custom_lottery_msg", PlayerBuyLottery, 0)
  end
end
function on_btn_buy_month_click(btn)
  local client_player = get_player()
  local lottery_day = client_player:QueryProp("LotteryDay")
  if nx_int(lottery_day) > nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("16563"))
    return
  end
  local dialog = util_get_form("form_common\\form_connect", true, false)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  if not nx_is_valid(dialog) then
    return
  end
  dialog.btn_51089.Visible = false
  dialog.btn_url.Visible = false
  dialog.btn_ok.Top = 168
  dialog.btn_ok.Left = 120
  dialog.event_name = "buy_lottery"
  local month_lottery_cost = nx_int(form.lbl_price2.Text)
  dialog.info_mltbox.HtmlText = get_text("16566", get_text("ui_lottery_yueling"), nx_int(month_lottery_cost) * nx_int(1000))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, dialog.event_name)
  if nx_is_valid(dialog) then
    dialog:Close()
    gui:Delete(dialog)
  end
  if nx_string("ok") == nx_string(res) then
    nx_execute("custom_sender", "custom_lottery_msg", PlayerBuyLottery, 1)
  end
end
function show_last_prize_list(rows, ...)
  set_gird_info(rows, unpack(arg))
end
function show_today_prize_list(rows, ...)
  set_gird_info(rows, unpack(arg))
end
function set_gird_info(rows, ...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local client_player = get_player()
  local player_name = client_player:QueryProp("Name")
  form.textgrid_lottery_list:ClearRow()
  form.textgrid_lottery_list.RowCount = rows
  local index = 1
  for i = 1, rows do
    if nx_int(0) == nx_int(rows - i) then
      form.textgrid_lottery_list:SetGridText(rows - i, 0, nx_widestr(get_text("ui_lottery_award_1")))
    elseif nx_int(1) == nx_int(rows - i) or nx_int(2) == nx_int(rows - i) then
      form.textgrid_lottery_list:SetGridText(rows - i, 0, nx_widestr(get_text("ui_lottery_award_2")))
    else
      form.textgrid_lottery_list:SetGridText(rows - i, 0, nx_widestr(get_text("ui_lottery_award_3")))
    end
    form.textgrid_lottery_list:SetGridText(rows - i, 1, nx_widestr(arg[index + 1]))
    form.textgrid_lottery_list:SetGridText(rows - i, 2, nx_widestr(arg[index + 2]))
    if nx_ws_equal(player_name, arg[index + 1]) then
      form.textgrid_lottery_list:SetGridForeColor(rows - i, 0, "255,82,104,214")
      form.textgrid_lottery_list:SetGridForeColor(rows - i, 1, "255,82,104,214")
      form.textgrid_lottery_list:SetGridForeColor(rows - i, 2, "255,82,104,214")
    end
    index = index + 3
  end
end
function on_server_msg(msg_type, ...)
  if nx_int(msg_type) == nx_int(ShowLotteryForm) then
    show_lottery_form(unpack(arg))
  elseif nx_int(msg_type) == nx_int(ShowLastPrizeList) then
    show_last_prize_list(unpack(arg))
  elseif nx_int(msg_type) == nx_int(ShowTodayPrizeList) then
    show_today_prize_list(unpack(arg))
  elseif nx_int(msg_type) == nx_int(RefreshLotteryInfo) then
    refresh_lottery_info(unpack(arg))
  end
end
function refresh_lottery_info(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local capital = nx_int64(arg[1]) * nx_int64(20000) * nx_int64(30) / nx_int64(100)
  form.lbl_award.Text = format_capital(capital)
  refresh_lottery_code_list(form)
end
function refresh_lottery_code_list(form)
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows("lottery_record")
  form.mltbox_code:Clear()
  local time = 0
  for i = 0, rows - 1 do
    local tempTime = client_player:QueryRecord("lottery_record", i, 0)
    local uid = client_player:QueryRecord("lottery_record", i, 1)
    form.mltbox_code:AddHtmlText(nx_widestr(uid), -1)
    if time < tempTime then
      time = tempTime
    end
  end
  if 1 < nx_number(time) then
    form.lbl_lottery_day.Text = nx_widestr(get_text("ui_lottery_num_2", nx_int(time)))
    form.cur_month_remain_times = time
  else
    form.lbl_lottery_day.Text = nx_widestr(get_text("ui_lottery_num_2", nx_int(0)))
    form.cur_month_remain_times = 0
  end
  form.cur_buy_times = rows
  form.lbl_lottery_time.Text = nx_widestr(nx_string(rows))
  if 1 < form.cur_month_remain_times then
    form.lbl_65.Text = nx_widestr("0")
    local ramain = form.day_limit_times - form.cur_buy_times + 1
    if 0 <= ramain then
      form.lbl_limit_count.Text = nx_widestr(ramain)
    else
      form.lbl_limit_count.Text = nx_widestr("0")
    end
  elseif 0 <= form.day_limit_times - form.cur_buy_times then
    form.lbl_limit_count.Text = nx_widestr(form.day_limit_times - form.cur_buy_times)
  else
    form.lbl_limit_count.Text = nx_widestr("0")
  end
end
function show_lottery_form(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local lottery_name = nx_widestr("")
  lottery_name = nx_widestr(arg[1])
  local lottery_highest_prize = nx_int64(arg[2]) * nx_int64(20000) * nx_int64(30) * nx_int64(50) / nx_int64(10000)
  form.lbl_lottery_name.Text = nx_widestr(format_capital(lottery_highest_prize))
  local capital = nx_int64(arg[3]) * nx_int64(20000) * nx_int64(30) / nx_int64(100)
  form.lbl_award.Text = format_capital(capital)
  local cur_game_step = nx_int(arg[4])
  local cur_sub_game_step = nx_int(arg[5])
  local LotterManager = nx_value("LotterManager")
  if not nx_is_valid(LotterManager) then
    return
  end
  local info_tbl = LotterManager:GetLotteryInfoByGamgeStep(cur_game_step, cur_sub_game_step)
  local length = table.getn(info_tbl)
  if nx_int(length) == 0 then
    return
  end
  form.lbl_price1.Text = nx_widestr(nx_int64(info_tbl[1]) / nx_int64(1000))
  bind_item_grid(form, form.imagegrid_2, nx_string(info_tbl[2]))
  form.lbl_prize_count1.Text = nx_widestr(info_tbl[3])
  form.lbl_goods_1.Text = get_text(nx_string(info_tbl[2]))
  form.lbl_price2.Text = nx_widestr(nx_int64(info_tbl[4]) / nx_int64(1000))
  bind_item_grid(form, form.imagegrid_3, nx_string(info_tbl[5]))
  form.lbl_prize_count2.Text = nx_widestr(info_tbl[6])
  form.lbl_goods_2.Text = get_text(nx_string(info_tbl[5]))
  local buy_enabled = nx_int(info_tbl[9])
  if nx_int(buy_enabled) <= nx_int(0) then
    form.btn_buy_month.Enabled = false
  end
  form.day_limit_times = nx_int(info_tbl[7])
  if 1 < form.cur_month_remain_times then
    form.lbl_65.Text = nx_widestr("0")
    form.lbl_limit_count.Text = nx_widestr(form.day_limit_times - form.cur_buy_times + 1)
  elseif 0 <= form.day_limit_times - form.cur_buy_times then
    form.lbl_limit_count.Text = nx_widestr(form.day_limit_times - form.cur_buy_times)
  else
    form.lbl_limit_count.Text = nx_widestr("0")
  end
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_text(ui_text, ...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  gui.TextManager:Format_SetIDName(ui_text)
  for i = 1, size do
    gui.TextManager:Format_AddParam(arg[i])
  end
  return gui.TextManager:Format_GetText()
end
function on_btn_find_click(btn)
  local form = btn.ParentForm
  local client_player = get_player()
  local player_name = client_player:QueryProp("Name")
  local rows = form.textgrid_lottery_list.RowCount
  local bPrize = false
  for i = 1, rows do
    local grid_text = form.textgrid_lottery_list:GetGridText(i - 1, 1)
    if nx_ws_equal(player_name, grid_text) then
      form.rbtn_luck_list.Checked = true
      bPrize = true
      return
    end
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    local info = get_text("16567")
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
  if not bPrize then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_lottery_name_tips"))
  end
end
function on_btn_showcode_click(btn)
  local form = btn.ParentForm
  if form.groupbox_code.Visible == true then
    form.groupbox_code.Visible = false
  else
    form.groupbox_code.Visible = true
  end
end
function on_btn_close_code_click(btn)
  local form = btn.ParentForm
  form.groupbox_code.Visible = false
end
function on_imagegrid_2_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_2_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_3_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_3_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  nx_execute("tips_game", "show_tips_by_config", prize_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function bind_item_grid(form, grid, item_id)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  grid:AddItem(0, photo, nx_widestr(item_id), nx_int(1), 0)
  grid:SetBindIndex(0, item_id)
end
function on_btn_luck_list_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = true
  form.groupbox_luck.Visible = false
  form.groupbox_introduce.Visible = false
end
function on_btn_show_buy_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = false
  form.groupbox_luck.Visible = true
  form.groupbox_introduce.Visible = false
end
function on_btn_introduce_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = false
  form.groupbox_luck.Visible = false
  form.groupbox_introduce.Visible = true
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.groupbox_list.Visible = false
  form.groupbox_luck.Visible = true
  form.groupbox_introduce.Visible = false
end
