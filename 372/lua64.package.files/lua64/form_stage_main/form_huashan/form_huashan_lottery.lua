require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local LPT_Nil = -1
local LPT_None = 0
local LPT_First = 1
local LPT_Second = 2
local LPT_Three = 3
local LPT_End = 4
local huashan_winners
local tbl_tickets = {}
local tbl_winners = {
  [LPT_First] = {},
  [LPT_Second] = {},
  [LPT_Three] = {}
}
local tbl_prize_id = {
  [LPT_Nil] = "ui_huashan_yazhu_08",
  [LPT_None] = "ui_huashan_yazhu_09",
  [LPT_First] = "ui_huashan_yazhu_10",
  [LPT_Second] = "ui_huashan_yazhu_11",
  [LPT_Three] = "ui_huashan_yazhu_12"
}
local COLOR_STRING_0 = "255,204,204,204"
local COLOR_STRING_1 = "255,255,0,0"
local tbl_prize_name_color = {
  [0] = {
    [1] = COLOR_STRING_0,
    [2] = COLOR_STRING_0,
    [3] = COLOR_STRING_0,
    [4] = COLOR_STRING_0,
    [5] = COLOR_STRING_0
  },
  [11111] = {
    [1] = COLOR_STRING_1,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_1
  },
  [11110] = {
    [1] = COLOR_STRING_1,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_0
  },
  [1111] = {
    [1] = COLOR_STRING_0,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_1
  },
  [11100] = {
    [1] = COLOR_STRING_1,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_0,
    [5] = COLOR_STRING_0
  },
  [1110] = {
    [1] = COLOR_STRING_0,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_0
  },
  [111] = {
    [1] = COLOR_STRING_0,
    [2] = COLOR_STRING_0,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_1
  },
  [10111] = {
    [1] = COLOR_STRING_0,
    [2] = COLOR_STRING_0,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_1,
    [5] = COLOR_STRING_1
  },
  [11101] = {
    [1] = COLOR_STRING_1,
    [2] = COLOR_STRING_1,
    [3] = COLOR_STRING_1,
    [4] = COLOR_STRING_0,
    [5] = COLOR_STRING_0
  }
}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.one_money = ""
end
function on_main_form_shut(form)
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.mltbox_base_rule_desc:Clear()
  form.mltbox_base_rule_desc:AddHtmlText(nx_widestr(util_text("ui_huashan_yazhu_02")), -1)
  form.mltbox_lottery_rule_desc:Clear()
  form.mltbox_lottery_rule_desc:AddHtmlText(nx_widestr(util_text("ui_huashan_yazhu_03")), -1)
  form.lbl_lottery_title.BackImage = "gui\\language\\ChineseS\\huashan\\title_gamble_1.png"
  form.lbl_lottery_title_min.BackImage = "gui\\language\\ChineseS\\huashan\\bg_name_list1.png"
  form.rbtn_lottery_1.Checked = true
  init_conf(form)
end
function on_main_form_close(form)
  clear_winners()
  clear_tickets()
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
function on_btn_buy_click(btn)
  local formlist = nx_execute(m_NameList_Path, "open_form", 5, "on_btn_phb_click")
  local res = nx_wait_event(600, formlist, "on_btn_phb_click")
  if res ~= nil and nx_string(res) ~= nx_string("cancel") then
    local namelist = util_split_wstring(res, ",")
    if table.getn(namelist) == 5 then
      nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_BuyTicket, 0, nx_widestr(res), 1, 20000)
      return
    else
      self_systemcenterinfo(1000135)
    end
  end
end
function on_rbtn_lottery_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_lottery_rule_desc:Clear()
  form.mltbox_lottery_rule_desc:AddHtmlText(nx_widestr(util_text("ui_huashan_yazhu_03")), -1)
  form.lbl_lottery_title.BackImage = "gui\\language\\ChineseS\\huashan\\title_gamble_1.png"
  form.lbl_lottery_title_min.BackImage = "gui\\language\\ChineseS\\huashan\\bg_name_list1.png"
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryPrizeList, 0, 1)
end
function on_rbtn_lottery_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_lottery_rule_desc:Clear()
  form.mltbox_lottery_rule_desc:AddHtmlText(nx_widestr(util_text("ui_huashan_yazhu_04")), -1)
  form.lbl_lottery_title.BackImage = "gui\\language\\ChineseS\\huashan\\title_gamble_2.png"
  form.lbl_lottery_title_min.BackImage = "gui\\language\\ChineseS\\huashan\\bg_name_list2.png"
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryPrizeList, 0, 2)
end
function on_rbtn_lottery_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_lottery_rule_desc:Clear()
  form.mltbox_lottery_rule_desc:AddHtmlText(nx_widestr(util_text("ui_huashan_yazhu_05")), -1)
  form.lbl_lottery_title.BackImage = "gui\\language\\ChineseS\\huashan\\title_gamble_3.png"
  form.lbl_lottery_title_min.BackImage = "gui\\language\\ChineseS\\huashan\\bg_name_list3.png"
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryPrizeList, 0, 3)
end
function open_form()
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return
  end
  local flag = mgr:CheckSwitchEnable(ST_FUNCTION_HUASHAN_LOTTERY)
  if not flag then
    self_systemcenterinfo(100059)
    return
  end
  local form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
    form:Close()
  else
    form.Visible = true
    form:Show()
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryPrizeResult, 0)
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryJCSum, 0)
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryTicketSelf, 0)
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryNextJCSum, 0)
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.TextManager:Format_SetIDName("ui_huashan_yazhu_06")
      gui.TextManager:Format_AddParam(nx_int64(form.one_money))
      local text = gui.TextManager:Format_GetText()
      form.lbl_one_money.Text = nx_widestr(text)
    end
  end
end
function fresh_right_top(form)
  local grid = form.textgrid_winner_list
  grid:BeginUpdate()
  grid:ClearRow()
  grid:ClearSelect()
  if huashan_winners == nil then
    grid:EndUpdate()
    return
  end
  local lpt_type = LPT_Nil
  if form.rbtn_lottery_1.Checked then
    lpt_type = LPT_First
  elseif form.rbtn_lottery_2.Checked then
    lpt_type = LPT_Second
  elseif form.rbtn_lottery_3.Checked then
    lpt_type = LPT_Three
  end
  if lpt_type == LPT_Nil then
    grid:EndUpdate()
    return
  end
  local tbl_name_count = {}
  for i = 1, table.getn(tbl_winners[lpt_type]) do
    local winner_name = tbl_winners[lpt_type][i]
    local new_one = true
    for j = 1, table.getn(tbl_name_count) do
      if nx_string(tbl_name_count[j][1]) == nx_string(winner_name) then
        tbl_name_count[j][2] = tbl_name_count[j][2] + 1
        new_one = false
        break
      end
    end
    if new_one then
      table.insert(tbl_name_count, {winner_name, 1})
    end
  end
  for i = 1, table.getn(tbl_name_count) do
    local row = grid:InsertRow(grid.RowCount)
    grid:SetGridText(row, 0, nx_widestr(i))
    grid:SetGridText(row, 1, nx_widestr(tbl_name_count[i][1]))
    grid:SetGridText(row, 2, nx_widestr(tbl_name_count[i][2]) .. nx_widestr(util_text("ui_huashan_yazhu_20")))
  end
  grid:EndUpdate()
end
function fresh_right_bottom(form)
  local groupboxmain = form.gsb_my_lottery
  groupboxmain:DeleteAll()
  local gui = nx_value("gui")
  for i = 1, table.getn(tbl_tickets) do
    local one_ticket = tbl_tickets[i]
    local one_ticket_name = util_split_wstring(one_ticket[1], ",")
    local one_ticket_flag = nx_number(one_ticket[2])
    local one_ticket_color = get_prize_serial_number(one_ticket_flag, one_ticket_name)
    local groupbox = gui:Create("GroupBox")
    groupboxmain:Add(groupbox)
    groupbox.Name = "groupbox_" .. nx_string(i)
    groupbox.Width = groupboxmain.Width - 20
    groupbox.Height = 40
    groupbox.Left = 0
    groupbox.Top = groupbox.Height * (i - 1)
    groupbox.AutoSize = true
    groupbox.BackImage = "gui\\special\\huashan\\bg_gamble_5.png"
    local lbl_index = gui:Create("Label")
    groupbox:Add(lbl_index)
    lbl_index.Name = "lbl_index_" .. nx_string(i)
    lbl_index.Left = 12
    lbl_index.Top = 2
    lbl_index.Width = 50
    lbl_index.Height = groupbox.Height
    lbl_index.AutoSize = true
    lbl_index.BackImage = "gui\\language\\ChineseS\\huashan\\nub_gamble_" .. nx_string(i) .. ".png"
    local lbl_player1 = gui:Create("Label")
    groupbox:Add(lbl_player1)
    lbl_player1.Text = nx_widestr(one_ticket_name[1])
    lbl_player1.Name = "lbl_player1_" .. nx_string(i)
    lbl_player1.Left = 40
    lbl_player1.Top = 0
    lbl_player1.Width = 80
    lbl_player1.Height = groupbox.Height
    lbl_player1.Align = "Center"
    lbl_player1.Font = "font_main"
    lbl_player1.ForeColor = tbl_prize_name_color[one_ticket_color][1]
    local lbl_player2 = gui:Create("Label")
    groupbox:Add(lbl_player2)
    lbl_player2.Text = nx_widestr(one_ticket_name[2])
    lbl_player2.Name = "lbl_player2_" .. nx_string(i)
    lbl_player2.Left = 122
    lbl_player2.Top = 0
    lbl_player2.Width = 80
    lbl_player2.Height = groupbox.Height
    lbl_player2.Align = "Center"
    lbl_player2.Font = "font_main"
    lbl_player2.ForeColor = tbl_prize_name_color[one_ticket_color][2]
    local lbl_player3 = gui:Create("Label")
    groupbox:Add(lbl_player3)
    lbl_player3.Text = nx_widestr(one_ticket_name[3])
    lbl_player3.Name = "lbl_player3_" .. nx_string(i)
    lbl_player3.Left = 204
    lbl_player3.Top = 0
    lbl_player3.Width = 80
    lbl_player3.Height = groupbox.Height
    lbl_player3.Align = "Center"
    lbl_player3.Font = "font_main"
    lbl_player3.ForeColor = tbl_prize_name_color[one_ticket_color][3]
    local lbl_player4 = gui:Create("Label")
    groupbox:Add(lbl_player4)
    lbl_player4.Text = nx_widestr(one_ticket_name[4])
    lbl_player4.Name = "lbl_player4_" .. nx_string(i)
    lbl_player4.Left = 287
    lbl_player4.Top = 0
    lbl_player4.Width = 80
    lbl_player4.Height = groupbox.Height
    lbl_player4.Align = "Center"
    lbl_player4.Font = "font_main"
    lbl_player4.ForeColor = tbl_prize_name_color[one_ticket_color][4]
    local lbl_player5 = gui:Create("Label")
    groupbox:Add(lbl_player5)
    lbl_player5.Text = nx_widestr(one_ticket_name[5])
    lbl_player5.Name = "lbl_player5_" .. nx_string(i)
    lbl_player5.Left = 367
    lbl_player5.Top = 0
    lbl_player5.Width = 80
    lbl_player5.Height = groupbox.Height
    lbl_player5.Align = "Center"
    lbl_player5.Font = "font_main"
    lbl_player5.ForeColor = tbl_prize_name_color[one_ticket_color][5]
    local lbl_pubinfo = gui:Create("Label")
    groupbox:Add(lbl_pubinfo)
    lbl_pubinfo.Name = "lbl_pubinfo_" .. nx_string(i)
    lbl_pubinfo.Left = 435
    lbl_pubinfo.Top = 0
    lbl_pubinfo.Width = 80
    lbl_pubinfo.Height = groupbox.Height
    lbl_pubinfo.Align = "Center"
    lbl_pubinfo.Font = "font_main"
    lbl_pubinfo.ForeColor = "255,255,180,40"
    lbl_pubinfo.AutoSize = false
    if huashan_winners == nil then
      lbl_pubinfo.Text = nx_widestr(util_text(tbl_prize_id[LPT_Nil]))
    elseif one_ticket_flag > LPT_Nil and one_ticket_flag < LPT_End then
      lbl_pubinfo.Text = nx_widestr(util_text(tbl_prize_id[one_ticket_flag]))
    end
  end
  groupboxmain.IsEditMode = false
  groupboxmain:ResetChildrenYPos()
end
function clear_tickets()
  local num = table.maxn(tbl_tickets)
  for i = num, 1, -1 do
    table.remove(tbl_tickets, i)
  end
end
function clear_winners()
  local num = 0
  num = table.maxn(tbl_winners[LPT_First])
  for i = num, 1, -1 do
    table.remove(tbl_winners[LPT_First], i)
  end
  num = table.maxn(tbl_winners[LPT_Second])
  for i = num, 1, -1 do
    table.remove(tbl_winners[LPT_Second], i)
  end
  num = table.maxn(tbl_winners[LPT_Three])
  for i = num, 1, -1 do
    table.remove(tbl_winners[LPT_Three], i)
  end
end
function get_prize_serial_number(one_ticket_flag, one_ticket_name)
  if huashan_winners == nil or nx_widestr(huashan_winners) == nx_widestr("") then
    return 0
  elseif one_ticket_flag == LPT_None then
    return 0
  elseif one_ticket_flag == LPT_First then
    return 11111
  else
    local winners_name = util_split_wstring(huashan_winners, ",")
    if one_ticket_flag == LPT_Second then
      if winners_name[5] ~= one_ticket_name[5] then
        return 11110
      end
      if winners_name[1] ~= one_ticket_name[1] then
        return 1111
      end
    elseif one_ticket_flag == LPT_Three then
      if winners_name[4] ~= one_ticket_name[4] and winners_name[5] ~= one_ticket_name[5] then
        return 11100
      end
      if winners_name[1] ~= one_ticket_name[1] and winners_name[5] ~= one_ticket_name[5] then
        return 1110
      end
      if winners_name[1] ~= one_ticket_name[1] and winners_name[2] ~= one_ticket_name[2] then
        return 111
      end
      if winners_name[2] ~= one_ticket_name[2] then
        return 10111
      end
      if winners_name[4] ~= one_ticket_name[4] then
        return 11101
      end
    else
      return 0
    end
  end
end
function init_conf(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\HuaShan\\HuaShanLottery.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Lottery_WXC")
  if sec_index < 0 then
    return
  end
  form.one_money = ini:ReadString(sec_index, "OneMoney", "")
end
function on_server_msg_list(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  subtype = arg[2]
  if subtype == HS_LTT_SToC_QueryJCSum then
    form.lbl_total_prize.Text = FormatMoney(nx_int(arg[4]), 2)
  elseif subtype == HS_LTT_SToC_QueryNextJCSum then
    form.lbl_next_total_prize.Text = FormatMoney(nx_int(arg[4]), 2)
  elseif subtype == HS_LTT_SToC_QueryPrizeList then
    local iTicketType = nx_int(arg[3])
    local igrade = nx_int(arg[4])
    clear_winners()
    for n = 5, nx_number(table.getn(arg)), 2 do
      local lpt_type = nx_number(arg[n + 1])
      table.insert(tbl_winners[lpt_type], nx_widestr(arg[n]))
    end
    fresh_right_top(form)
  elseif subtype == HS_LTT_SToC_QueryTicketSelf then
    local itype = arg[3]
    clear_tickets()
    for n = 4, nx_number(table.getn(arg)), 2 do
      local one_ticket = {
        nx_widestr(arg[n]),
        nx_number(arg[n + 1])
      }
      table.insert(tbl_tickets, one_ticket)
    end
    fresh_right_bottom(form)
  elseif subtype == HS_LTT_SToC_BuyTicket then
    local itype = arg[3]
    local one_ticket = {
      nx_widestr(arg[4]),
      nx_number(arg[5])
    }
    table.insert(tbl_tickets, one_ticket)
    fresh_right_bottom(form)
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryJCSum, 0)
    nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryNextJCSum, 0)
  else
    if subtype == HS_LTT_SToC_QueryPrizeResult then
      local itype = arg[3]
      huashan_winners = arg[4]
      if huashan_winners ~= nil and nx_widestr(huashan_winners) ~= nx_widestr("") then
        form.lbl_public_info.Text = nx_widestr(huashan_winners)
        nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_Lottery, HS_LTT_CToS_QueryPrizeList, 0, 1)
      else
        huashan_winners = nil
        form.lbl_public_info.Text = nx_widestr("@ui_huashan_visit_20")
      end
    else
    end
  end
end
function FormatMoney(money_count, money_type)
  local retStr = nx_widestr("")
  if money_type ~= 1 and money_type ~= 2 or not (nx_number(money_count) >= nx_number(0)) then
    return retStr
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return retStr
  end
  local gui = nx_value("gui")
  local tab_money = capital:SplitCapital(money_count, money_type)
  if table.getn(tab_money) == 3 then
    if nx_number(tab_money[1]) == nx_number(0) and nx_number(tab_money[2]) == nx_number(0) and nx_number(tab_money[3]) == nx_number(0) then
      return nx_widestr("0") .. gui.TextManager:GetText("ui_wen")
    end
    if nx_number(tab_money[1]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[1]) .. gui.TextManager:GetText("ui_ding")
    end
    if nx_number(tab_money[2]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[2]) .. gui.TextManager:GetText("ui_liang")
    end
    if nx_number(tab_money[3]) ~= nx_number(0) then
      retStr = retStr .. nx_widestr(tab_money[3]) .. gui.TextManager:GetText("ui_wen")
    end
    return nx_widestr(retStr)
  end
end
