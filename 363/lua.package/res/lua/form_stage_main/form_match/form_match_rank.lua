require("util_functions")
require("util_gui")
local CTS_Apply = 0
local CTS_OpenForm = 1
local CTS_QuerySelf = 2
local CTS_QueryRank = 3
local CTS_QueryPlayer = 4
local STC_OpenForm = 0
local STC_QuerySelf = 1
local STC_QueryRank = 2
local STC_QueryPlayer = 3
local STC_QueryApplyRec = 4
local MT_Day = 1
local MT_Week = 2
local MT_Loser = 0
local MT_Winer = 1
local Page_Index_list = {}
local school_name = {
  [1] = "school_jinyiwei",
  [2] = "school_gaibang",
  [3] = "school_junzitang",
  [4] = "school_jilegu",
  [5] = "school_tangmen",
  [6] = "school_emei",
  [7] = "school_wudang",
  [8] = "school_shaolin",
  [9] = "force_yihua",
  [10] = "force_taohua",
  [11] = "force_wanshou",
  [12] = "force_jinzhen",
  [13] = "force_wugen",
  [14] = "force_xujia",
  [15] = "ui_wu_menpai"
}
function on_main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.player_list = nil
  form.itype = 1
  form.page = 1
  form.allnumber = 0
  form.number = 10
  Page_Index_list[form.page] = 0
  form.page_index = Page_Index_list[form.page]
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  if not nx_is_valid(form.player_list) then
    form.player_list = get_global_arraylist("form_match_rank_player_list")
  end
  form.textgrid_list:SetColTitle(0, nx_widestr(util_text("ui_match_interface14")))
  form.textgrid_list:SetColTitle(1, nx_widestr(util_text("ui_match_interface15")))
  form.textgrid_list:SetColTitle(2, nx_widestr(util_text("ui_match_interface16")))
  form.textgrid_list:SetColTitle(3, nx_widestr(util_text("ui_match_interface17")))
  form.textgrid_list:SetColTitle(4, nx_widestr(util_text("ui_match_interface18")))
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("Name") then
    return
  end
  form.playerName = nx_widestr(client_player:QueryProp("Name"))
  local ss = gui.TextManager:GetFormatText("ui_match_interface47")
  form.combobox_school.Text = nx_widestr(ss)
  form.combobox_school.DropListBox:ClearString()
  local ss1 = gui.TextManager:GetFormatText("ui_match_interface48")
  form.combobox_date.Text = nx_widestr(ss1)
  form.combobox_date.DropListBox:ClearString()
  local str_quanbu = gui.TextManager:GetFormatText("ui_match_interface43")
  form.combobox_school.DropListBox:AddString(nx_widestr(str_quanbu))
  local all_time = gui.TextManager:GetFormatText("ui_match_interface44")
  form.combobox_date.DropListBox:AddString(nx_widestr(all_time))
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Dateinfo_number = get_arraylist("Dateinfo_number")
  form.Dateinfo_number:ClearChild()
  form.school_menpai = get_arraylist("school_menpai")
  form.school_menpai:ClearChild()
  local str_quanbu = gui.TextManager:GetFormatText("ui_match_interface43")
  form.school = nx_widestr(str_quanbu)
  form.month = 0
  form.day = 0
  form.stc_type = 0
end
function on_main_form_close(form)
  form.page = 1
  Page_Index_list[form.page] = 0
  nx_destroy(form)
  nx_execute("form_stage_main\\form_match\\form_match_rank", "CaneClearArry")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = form.page - 1
  if page <= 0 then
    return
  end
  form.page = page
  fresh_form_grid(form)
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.page * form.number > form.allnumber then
    return
  end
  local page = form.page + 1
  form.page = page
  fresh_form_grid(form)
end
function com_open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    return form
  end
  form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return nx_null()
  end
  form.Visible = true
  form:Show()
  return form
end
function com_set_player_list(names)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if not nx_is_valid(form) then
    return -1
  end
  local list = form.player_list
  if not nx_is_valid(list) then
    return -1
  end
  local unFindNum = 0
  local name = nx_string(names)
  local child
  if not list:FindChild(name) then
    child = list:CreateChild(name)
    if nx_is_valid(child) then
      nx_set_custom(child, "playername", nx_widestr(names))
      nx_set_custom(child, "group", 0)
      nx_set_custom(child, "school", "")
      nx_set_custom(child, "guild", nx_widestr(""))
      nx_set_custom(child, "powerlevel", 0)
      nx_set_custom(child, "result", MT_Winer)
      nx_set_custom(child, "month", 0)
      nx_set_custom(child, "day", 0)
    end
    unFindNum = unFindNum + 1
    nx_execute("custom_sender", "custom_game_match", CTS_QueryPlayer, form.itype, names)
  else
    child = form.player_list:GetChild(nx_string(name))
    nx_set_custom(child, "result", MT_Winer)
  end
  local row = form.textgrid_list:InsertRow(-1)
  local group_text = nx_widestr("/")
  if child.group ~= 0 then
    group_text = nx_widestr(child.group)
  end
  form.textgrid_list:SetGridText(row, 0, nx_widestr(group_text))
  form.textgrid_list:SetGridText(row, 1, nx_widestr(child.playername))
  form.textgrid_list:SetGridText(row, 2, nx_widestr(util_text(child.school)))
  form.textgrid_list:SetGridText(row, 3, nx_widestr(child.guild))
  form.textgrid_list:SetGridText(row, 4, nx_widestr(util_text(get_powerlevel_title_one(child.powerlevel))))
  return unFindNum
end
function com_set_player_detail(name, school, guild, powerlevel, group, month, day)
  local form = nx_value("form_stage_main\\form_match\\form_match_rank")
  if not nx_is_valid(form) then
    return
  end
  local list = form.player_list
  if not nx_is_valid(list) then
    return
  end
  local child = form.player_list:GetChild(nx_string(name))
  if not nx_is_valid(child) then
    return
  end
  child.group = nx_number(group)
  child.school = nx_string(school)
  child.guild = nx_widestr(guild)
  child.powerlevel = nx_number(powerlevel)
  child.month = nx_int(month)
  child.day = nx_int(day)
  local list = form.textgrid_list
  for i = 0, list.RowCount - 1 do
    if nx_ws_equal(list:GetGridText(i, 1), nx_widestr(name)) then
      local group_text = nx_widestr("/")
      if child.group ~= 0 then
        group_text = nx_widestr(child.group)
      end
      list:SetGridText(i, 0, nx_widestr(group_text))
      list:SetGridText(i, 1, nx_widestr(child.playername))
      list:SetGridText(i, 2, nx_widestr(util_text(child.school)))
      list:SetGridText(i, 3, nx_widestr(child.guild))
      list:SetGridText(i, 4, nx_widestr(util_text(get_powerlevel_title_one(child.powerlevel))))
    end
  end
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_match_interface46")
  gui.TextManager:Format_AddParam(nx_int(child.month))
  gui.TextManager:Format_AddParam(nx_int(child.day))
  local my_time = nx_widestr(gui.TextManager:Format_GetText())
  if not form.Dateinfo_number:FindChild(nx_string(my_time)) then
    form.combobox_date.DropListBox:AddString(my_time)
    local iFoodchild = form.Dateinfo_number:CreateChild(nx_string(my_time))
    nx_set_custom(iFoodchild, "nMonth", nx_int(child.month))
    nx_set_custom(iFoodchild, "nDay", nx_int(child.day))
  end
  local school_name = nx_widestr(util_text(child.school))
  if nx_ws_equal(nx_widestr(school_name), nx_widestr("")) then
    school_name = gui.TextManager:GetFormatText("ui_match_interface42")
  end
  if not form.school_menpai:FindChild(nx_string(child.school)) then
    form.combobox_school.DropListBox:AddString(school_name)
    local iFoodchild1 = form.school_menpai:CreateChild(nx_string(child.school))
    nx_set_custom(iFoodchild1, "name", school_name)
  end
end
function fresh_form_grid(form)
  if not nx_is_valid(form) then
    return
  end
  if form.allnumber <= 0 then
    return
  end
  if (form.page - 1) * form.number > form.allnumber then
    return
  end
  local index = (form.page - 1) * form.number
  if index > form.allnumber then
    return
  end
  local row_max = form.number
  if form.allnumber - index < form.number then
    row_max = form.allnumber - index
  end
  form.textgrid_list:BeginUpdate()
  form.textgrid_list:ClearRow()
  local page_index = Page_Index_list[form.page]
  local max_player = form.allnumber
  local gui = nx_value("gui")
  local rownum = 0
  for j = nx_number(page_index), max_player - 1 do
    child = form.player_list:GetChildByIndex(page_index)
    page_index = page_index + 1
    if nx_is_valid(child) then
      local bDate = false
      if child.month == form.month and child.day == form.day or 0 == form.month then
        bDate = true
      end
      local bSchool = false
      local str_quanbu = gui.TextManager:GetFormatText("ui_match_interface43")
      if nx_ws_equal(nx_widestr(util_text(child.school)), nx_widestr(form.school)) or nx_ws_equal(nx_widestr(str_quanbu), nx_widestr(form.school)) then
        bSchool = true
      end
      if bDate == true and bSchool == true and child.result == MT_Winer and not nx_ws_equal(child.playername, nx_widestr("")) then
        local row = form.textgrid_list:InsertRow(-1)
        if nx_ws_equal(nx_widestr(child.playername), nx_widestr(form.playerName)) and row ~= 0 then
          local nRow = row
          form.textgrid_list:SetGridText(nRow, 0, form.textgrid_list:GetGridText(0, 0))
          form.textgrid_list:SetGridText(nRow, 1, form.textgrid_list:GetGridText(0, 1))
          form.textgrid_list:SetGridText(nRow, 2, form.textgrid_list:GetGridText(0, 2))
          form.textgrid_list:SetGridText(nRow, 3, form.textgrid_list:GetGridText(0, 3))
          form.textgrid_list:SetGridText(nRow, 4, form.textgrid_list:GetGridText(0, 4))
          row = 0
        end
        local group_text = nx_widestr("/")
        if child.group ~= 0 then
          group_text = nx_widestr(child.group)
        end
        form.textgrid_list:SetGridText(row, 0, nx_widestr(group_text))
        form.textgrid_list:SetGridText(row, 1, nx_widestr(child.playername))
        form.textgrid_list:SetGridText(row, 2, nx_widestr(util_text(child.school)))
        form.textgrid_list:SetGridText(row, 3, nx_widestr(child.guild))
        form.textgrid_list:SetGridText(row, 4, nx_widestr(util_text(get_powerlevel_title_one(child.powerlevel))))
        rownum = rownum + 1
        if row_max <= rownum then
          break
        end
      end
    end
  end
  form.textgrid_list:EndUpdate()
  Page_Index_list[1 + form.page] = page_index
  form.lbl_page.Text = nx_widestr(form.page)
end
function get_powerlevel_title_one(powerlevel)
  local pl = nx_number(powerlevel)
  if pl < 6 then
    return "tips_title_0"
  elseif 151 <= pl then
    return "tips_title_151"
  elseif 136 <= pl then
    return "tips_title_136"
  elseif 121 <= pl then
    return "tips_title_121"
  end
  local s = powerlevel / 10
  local y = powerlevel % 10
  if 6 <= y then
    y = 6
  elseif y == 0 then
    s = s - 1
    y = 6
  else
    y = 1
  end
  return "tips_title_" .. nx_string(nx_int(s) * 10 + y)
end
function on_match_rank_form(...)
  if arg[1] == STC_QueryRank or arg[1] == STC_QueryApplyRec then
    local form = util_get_form(nx_current(), true)
    if not nx_is_valid(form) then
      return
    end
    form.page = 1
    Page_Index_list[form.page] = 0
    form:Show()
    form.Visible = true
    local iType = arg[2]
    if iType == MT_Day then
      form.lbl_title.Text = nx_widestr("@ui_match_interface13")
    elseif iType == MT_Week then
      form.lbl_title.Text = nx_widestr("@ui_match_rank_week")
    end
    form.itype = iType
    form.stc_type = arg[1]
    local nRows = table.getn(arg) - 2
    form.allnumber = form.allnumber + nRows
    for i = 1, nRows do
      local playerName = arg[2 + i]
      com_set_player_list(playerName)
    end
    fresh_form_grid(form)
    if arg[1] == STC_QueryApplyRec then
      form.combobox_date.Visible = true
      form.lbl_title.Text = nx_widestr("@ui_match_interface45")
    end
    if arg[1] == STC_QueryRank then
      form.lbl_title.Text = nx_widestr("@ui_match_interface13")
      form.combobox_date.Visible = false
    end
  end
  if arg[1] == STC_QueryPlayer then
    local iType = arg[2]
    local name = arg[3]
    local school = arg[4]
    local guild = arg[5]
    local powerlevel = arg[6]
    local group = arg[7]
    local monte, day = get_date(arg[8])
    local form = nx_value("form_stage_main\\form_match\\form_match_rank")
    if nx_is_valid(form) and form.month == 0 then
      form.month = monte
      form.day = day
    end
    com_set_player_detail(name, school, guild, powerlevel, group, monte, day)
  end
end
function CaneClearArry()
  local form1 = nx_value("form_stage_main\\form_match\\form_match_rank")
  local form2 = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form1) and not nx_is_valid(form2) then
    local player_list = get_global_arraylist("form_match_rank_player_list")
    nx_destroy(player_list)
  end
end
function get_date(nTime)
  local cur_date_time = nTime
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_date_time)
  return nx_int(month), nx_int(day)
end
function on_combobox_date_selected(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local my_time = self.Text
  form.month = 0
  form.day = 0
  if form.Dateinfo_number:FindChild(nx_string(my_time)) then
    local node = form.Dateinfo_number:GetChild(nx_string(my_time))
    form.month = node.nMonth
    form.day = node.nDay
  end
  fresh_form_grid(form)
end
function on_combobox_school_selected(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.school = nx_widestr(self.Text)
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText("ui_match_interface42")
  if nx_ws_equal(nx_widestr(self.Text), nx_widestr(name)) then
    form.school = nx_widestr("")
  end
  fresh_form_grid(form)
end
