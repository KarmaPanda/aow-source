require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local CTS_Apply = 0
local CTS_OpenForm = 1
local CTS_QuerySelf = 2
local CTS_QueryRank = 3
local CTS_QueryPlayer = 4
local STC_OpenForm = 0
local STC_QuerySelf = 1
local STC_QueryRank = 2
local STC_QueryPlayer = 3
local MT_Day = 1
local MT_Week = 2
local Mt_School_Week = 3
local Mt_School_Month = 4
local MT_Loser = 0
local MT_Winer = 1
local m_AllowNum = 4
local m_Max = 199
local grop_box_old
function on_main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.self_match_info = nil
  form.player_list = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  if not nx_is_valid(form.self_match_info) then
    form.self_match_info = get_arraylist("form_self_match_info")
  end
  form.self_match_info:ClearChild()
  if not nx_is_valid(form.player_list) then
    form.player_list = get_global_arraylist("form_match_rank_player_list")
  end
  form.maxWheel = 0
  form.nowWheel = 0
  form.seflGroup = 0
end
function on_main_form_close(form)
  if nx_is_valid(form.self_match_info) then
    nx_destroy(form.self_match_info)
  end
  nx_execute("form_stage_main\\form_match\\form_match_rank", "CaneClearArry")
  nx_destroy(form)
end
function on_match_info_form(...)
  if arg[1] == STC_QuerySelf then
    local form = util_get_form(nx_current(), true)
    if not nx_is_valid(form) then
      return false
    end
    form:Show()
    form.Visible = true
    local iType = arg[2]
    local iWheel = arg[3]
    local iGroup = arg[4]
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    gui.TextManager:Format_SetIDName("ui_match_interface09")
    gui.TextManager:Format_AddParam(nx_int(iGroup))
    form.lbl_4.Text = nx_widestr(gui.TextManager:Format_GetText())
    form.lbl_3.Visible = false
    form.type = iType
    if iWheel > form.maxWheel then
      form.maxWheel = iWheel
    end
    form.nowWheel = iWheel
    form.seflGroup = iGroup
    local nName = nx_string(form.type) .. "_" .. nx_string(form.nowWheel)
    local iWheelchild
    if not form.self_match_info:FindChild(nName) then
      iWheelchild = form.self_match_info:CreateChild(nName)
    else
      iWheelchild = form.self_match_info:GetChild(nName)
    end
    local nRows = (table.getn(arg) - 4) / 3
    if nRows < 4 then
      form.ScrollBar1.Maximum = 0
    else
      form.ScrollBar1.Value = 0
      form.ScrollBar1.Maximum = nRows - 4
    end
    local unFindNum = 0
    for i = 1, nRows do
      local grupName = nx_string(iWheel) .. "-" .. nx_string(i)
      local playchild
      if not iWheelchild:FindChild(grupName) then
        playchild = iWheelchild:CreateChild(grupName)
      else
        playchild = iWheelchild:GetChild(grupName)
      end
      local name1 = arg[2 + i * 3]
      local name2 = arg[3 + i * 3]
      local winName = arg[4 + i * 3]
      nx_set_custom(playchild, "name1", nx_widestr(name1))
      nx_set_custom(playchild, "name2", nx_widestr(name2))
      nx_set_custom(playchild, "winName", nx_widestr(winName))
      unFindNum = unFindNum + com_set_player_list(name1, name2)
    end
    local nsRows = iWheelchild:GetChildCount()
    if unFindNum == 0 then
      fresh_info(form)
    else
    end
  end
  if arg[1] == STC_QueryPlayer then
    local form = nx_value("form_stage_main\\form_match\\form_match_info")
    if not nx_is_valid(form) then
      return false
    end
    local iType = arg[2]
    local name = arg[3]
    local school = arg[4]
    local guild = arg[5]
    local powerlevel = arg[6]
    local group = arg[7]
    local my_month, my_day = get_date(arg[8])
    com_set_player_detail(form, name, school, guild, powerlevel, group, my_month, my_day)
    fresh_info(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function fresh_info(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_match_interface19")
  gui.TextManager:Format_AddParam(nx_int(form.nowWheel))
  form.lbl_2.Text = nx_widestr(gui.TextManager:Format_GetText())
  local nName = nx_string(form.type) .. "_" .. nx_string(form.nowWheel)
  if not form.self_match_info:FindChild(nName) then
    return
  end
  local wheelChild = form.self_match_info:GetChild(nName)
  local nRows = wheelChild:GetChildCount()
  local rules_list = wheelChild:GetChildList()
  for i = 1, 4 do
    local winName = nx_widestr("")
    local name1 = nx_widestr("")
    local name2 = nx_widestr("")
    local grop_box = form:Find(nx_string("groupbox_wheel"))
    local grop_box_wheel = grop_box:Find(nx_string("groupbox_wheel_") .. nx_string(i))
    local groupbox_wheel_name1 = grop_box_wheel:Find("groupbox_wheel" .. nx_string(i) .. "_name1")
    local groupbox_wheel_name2 = grop_box_wheel:Find("groupbox_wheel" .. nx_string(i) .. "_name2")
    if i <= nRows then
      winName = rules_list[i + form.ScrollBar1.Value].winName
      name1 = rules_list[i + form.ScrollBar1.Value].name1
      name2 = rules_list[i + form.ScrollBar1.Value].name2
      grop_box_wheel.Visible = true
      fresh_player_info(name1, groupbox_wheel_name1, i, 1, form)
      fresh_player_info(name2, groupbox_wheel_name2, i, 2, form)
      groupbox_wheel_name1.BackImage = "gui\\special\\match\\1_1.png"
      groupbox_wheel_name2.BackImage = "gui\\special\\match\\1_2.png"
      local lblwin1 = groupbox_wheel_name1:Find("lbl_" .. nx_string(i) .. "_" .. nx_string(1) .. "_win")
      local lblwin2 = groupbox_wheel_name2:Find("lbl_" .. nx_string(i) .. "_" .. nx_string(2) .. "_win")
      if not nx_ws_equal(winName, nx_widestr("")) then
        if nx_ws_equal(winName, name1) then
          lblwin1.BackImage = "gui\\language\\ChineseS\\match\\win.png"
          lblwin2.BackImage = "gui\\language\\ChineseS\\match\\lose.png"
          groupbox_wheel_name1.BackImage = "gui\\special\\match\\2_1.png"
          groupbox_wheel_name2.BackImage = "gui\\special\\match\\5_2.png"
        elseif nx_ws_equal(winName, name2) then
          lblwin2.BackImage = "gui\\language\\ChineseS\\match\\win.png"
          lblwin1.BackImage = "gui\\language\\ChineseS\\match\\lose.png"
          groupbox_wheel_name1.BackImage = "gui\\special\\match\\5_1.png"
          groupbox_wheel_name2.BackImage = "gui\\special\\match\\2_2.png"
        end
      else
        lblwin1.BackImage = ""
        lblwin2.BackImage = ""
      end
    else
      grop_box_wheel.Visible = false
    end
  end
end
function fresh_player_info(name, groupBox, row, col, form)
  local sl_lable = groupBox:Find("lbl_" .. nx_string(row) .. "_" .. nx_string(col) .. "_sl")
  local mp_lable = groupBox:Find("lbl_" .. nx_string(row) .. "_" .. nx_string(col) .. "_mp")
  local bp_lable = groupBox:Find("lbl_" .. nx_string(row) .. "_" .. nx_string(col) .. "_bp")
  local name_lable = groupBox:Find("lbl_" .. nx_string(row) .. "_" .. nx_string(col))
  name_lable.Text = nx_widestr(name)
  local list = form.player_list
  if not nx_is_valid(list) then
    return
  end
  if not list:FindChild(nx_string(name)) then
    sl_lable.Text = nx_widestr("")
    mp_lable.Text = nx_widestr("")
    bp_lable.Text = nx_widestr("")
    return
  end
  local child = form.player_list:GetChild(nx_string(name))
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  sl_lable.Text = gui.TextManager:GetText(get_powerlevel_title_one(child.powerlevel))
  mp_lable.Text = nx_widestr(util_text(child.school))
  bp_lable.Text = nx_widestr(child.guild)
end
function on_btn_down_click(btn)
  local form = btn.ParentForm
  if form.nowWheel == 1 then
    return
  end
  local self_type = nx_execute("form_stage_main\\form_match\\form_match", "get_school")
  form.nowWheel = form.nowWheel - 1
  if form.type == MT_Day then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Day, form.nowWheel)
  elseif form.type == MT_Week then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Week, form.nowWheel)
  elseif form.type == self_type then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, self_type, form.nowWheel)
  elseif form.type == 11 then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, 11, form.nowWheel)
  end
  if form.nowWheel == 1 then
    btn.Enable = false
  end
  if form.nowWheel == form.maxWheel - 1 then
    btn.Enable = true
  end
  fresh_info(form)
end
function on_btn_up_click(btn)
  local form = btn.ParentForm
  if form.nowWheel == form.maxWheel then
    return
  end
  local self_type = nx_execute("form_stage_main\\form_match\\form_match", "get_school")
  form.nowWheel = form.nowWheel + 1
  if form.type == MT_Day then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Day, form.nowWheel)
  elseif form.type == MT_Week then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, MT_Week, form.nowWheel)
  elseif form.type == self_type then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, self_type, form.nowWheel)
  elseif form.type == 11 then
    nx_execute("custom_sender", "custom_game_match", CTS_QuerySelf, 11, form.nowWheel)
  end
  if form.nowWheel == form.maxWheel then
    btn.Enable = false
  end
  if form.nowWheel == 1 then
    btn.Enable = true
  end
  fresh_info(form)
end
function com_set_player_list(...)
  local form = nx_value("form_stage_main\\form_match\\form_match_info")
  if not nx_is_valid(form) then
    return -1
  end
  local list = form.player_list
  if not nx_is_valid(list) then
    return -1
  end
  local unFindNum = 0
  for i = 1, table.getn(arg) do
    local name = nx_string(arg[i])
    if name == "" then
      break
    end
    if not list:FindChild(name) then
      unFindNum = unFindNum + 1
      local child = list:CreateChild(name)
      if nx_is_valid(child) then
        nx_set_custom(child, "playername", nx_widestr(arg[i]))
        nx_set_custom(child, "group", 0)
        nx_set_custom(child, "school", "")
        nx_set_custom(child, "guild", nx_widestr(""))
        nx_set_custom(child, "powerlevel", 0)
        nx_set_custom(child, "result", MT_Loser)
        nx_set_custom(child, "month", 0)
        nx_set_custom(child, "day", 0)
      end
      nx_execute("custom_sender", "custom_game_match", CTS_QueryPlayer, form.type, arg[i])
    else
    end
  end
  return unFindNum
end
function com_set_player_detail(form, name, school, guild, powerlevel, group, month, day)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.player_list) then
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
  child.playername = nx_widestr(name)
  child.group = nx_number(group)
  child.school = nx_string(school)
  child.guild = nx_widestr(guild)
  child.powerlevel = nx_number(powerlevel)
  child.month = month
  child.day = day
end
function on_ScrollBar1_value_changed(tbar)
  local form = tbar.ParentForm
  refresh_st(form, nx_int(tbar.Value))
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
function get_date(nTime)
  local cur_date_time = nTime
  local year, month, day, hour, mins, sec = nx_function("ext_decode_date", cur_date_time)
  return nx_int(month), nx_int(day)
end
