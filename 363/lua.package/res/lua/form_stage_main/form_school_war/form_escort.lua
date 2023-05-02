require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("share\\capital_define")
require("form_stage_main\\switch\\switch_define")
local MAX_PATH_COUNT = 9
CARRIAGE_NAME = 1
CARRIAGE_MOVESPEED = 2
CARRIAGE_HP = 3
CARRIAGE_PHOTO = 4
CARRIAGE_SEL = 5
ESCORT_CARRIAGE_TYPE = 1
ESCORT_CARRIAGE_NAME = 2
ESCORT_CARRIAGE_MOVESPEED = 3
ESCORT_CARRIAGE_HP = 4
ESCORT_CARRIAGE_PHOTO_ON = 5
ESCORT_CARRIAGE_PHOTO_OUT = 6
local carriage_name = {
  [1] = {
    [CARRIAGE_NAME] = "lbl_carriage_name1",
    [CARRIAGE_MOVESPEED] = "lbl_movespeed1",
    [CARRIAGE_HP] = "lbl_hp1",
    [CARRIAGE_PHOTO] = "btn_carriage1",
    [CARRIAGE_SEL] = "lbl_carriage_sel1"
  },
  [2] = {
    [CARRIAGE_NAME] = "lbl_carriage_name2",
    [CARRIAGE_MOVESPEED] = "lbl_movespeed2",
    [CARRIAGE_HP] = "lbl_hp2",
    [CARRIAGE_PHOTO] = "btn_carriage2",
    [CARRIAGE_SEL] = "lbl_carriage_sel2"
  },
  [3] = {
    [CARRIAGE_NAME] = "lbl_carriage_name3",
    [CARRIAGE_MOVESPEED] = "lbl_movespeed3",
    [CARRIAGE_HP] = "lbl_hp3",
    [CARRIAGE_PHOTO] = "btn_carriage3",
    [CARRIAGE_SEL] = "lbl_carriage_sel3"
  }
}
ESCORT_TYPE_QI = "gui//language//ChineseS//tvt//yunbiao//icon_easy.png"
ESCORT_TYPE_ZHEN = "gui//language//ChineseS//tvt//yunbiao//icon_normal.png"
ESCORT_TYPE_XIAN = "gui//language//ChineseS//tvt//yunbiao//icon_normal.png"
ESCORT_SEL_CARRIAGE = "gui\\special\\tvt\\yunbiao\\formback\\cbtn_select_down.png"
ESCORT_SEL_PATH = "gui\\common\\combobox\\bg_select_down.png"
ESCORT_PATH_NORMAIL_IMAGE = "gui\\common\\combobox\\bg_select_out.png"
ESCORT_PATH_PUSH_IMAGE = "gui\\common\\combobox\\bg_select_down.png"
local escort_path_info_name = {
  [0] = {},
  [1] = {},
  [2] = {},
  [3] = {},
  [4] = {},
  [5] = {},
  [6] = {},
  [7] = {},
  [8] = {}
}
local escort_path_info_table = {}
local escort_carriage_table = {}
function main_form_init(form)
  form.Fixed = false
  form.carriage_type = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.TimeDown = 0
  form.timer_span = 1000
end
function on_main_form_close(form)
  Reset_Escort_Timedown(form)
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
function on_escort_info_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nEscort_id = btn.Escort_id
  local nAcceptTimes = btn.AcceptTimes
  local nTimeDown = btn.TimeDown
  local Escort_pos = btn.Escort_pos
  fresh_path_state(form.groupbox_escortpathinfo)
  btn.NormalImage = ESCORT_SEL_PATH
  btn.BackImage = ESCORT_SEL_PATH
  ShowEscortInfo(form, nEscort_id, nAcceptTimes, nTimeDown, Escort_pos)
end
function on_btn_escort_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local Escort_id = form.Escort_id
  local npcname = form.npcname
  if not CanEscort(Escort_id, npcname) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local nDeposit = form.nDeposit
  local Name = form.strPathName
  gui.TextManager:Format_SetIDName("ui_escort_jieshouqueren_manzu")
  gui.TextManager:Format_AddParam(nx_int(nDeposit))
  gui.TextManager:Format_AddParam(Name)
  local text = nx_widestr(gui.TextManager:Format_GetText())
  if not ShowTipDialog(text) then
    return
  end
  local nCarriageType = form.carriage_type
  nx_execute("custom_sender", "custom_request_start_escort", npcname, Escort_id, nCarriageType)
end
function on_btn_carriage_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.carriage_type = btn.carriage_type
  local group = form.groupbox_escort_detail_info
  for i = 1, 3 do
    local lbl_Sel = group:Find(carriage_name[i][CARRIAGE_SEL])
    if nx_is_valid(lbl_Sel) then
      lbl_Sel.BackImage = ""
    end
  end
  local lbl_Sel = group:Find(carriage_name[btn.carriage_pos][CARRIAGE_SEL])
  if nx_is_valid(lbl_Sel) then
    lbl_Sel.BackImage = ESCORT_SEL_CARRIAGE
  end
end
function ClosetForm()
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort", true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function ShowEscortForm(npcname, escort_list)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort", true)
  if not nx_is_valid(form) then
    return
  end
  form.npcname = npcname
  escort_path_info_table = {}
  form.timer_span = 1000
  form.bshow_time = false
  Init_Carriage_Table()
  Init_Escort_Path_Info(form, npcname, escort_list)
  util_auto_show_hide_form("form_stage_main\\form_school_war\\form_escort")
end
function on_path_table_scrollbar_value_changed(self, oldvalue)
  local rownum = table.getn(escort_path_info_table)
  if rownum < MAX_PATH_COUNT + 1 then
    return 0
  end
  local endrow = self.Value + MAX_PATH_COUNT
  if rownum < endrow then
    endrow = rownum
  end
  local form = self.ParentForm
  path_fresh(form.groupbox_escortpathinfo, self.Value, endrow, rownum)
end
function CanEscort(Escort_id, npcname)
  local strAcceptNpc, nPowerLevel, nDeposit = Get_Path_LimitInfo(Escort_id)
  if npcname ~= strAcceptNpc then
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local curPowerLevel = GetPowerLevel()
  if nx_int(nPowerLevel) > nx_int(curPowerLevel) then
    gui.TextManager:Format_SetIDName("ui_escort_powerlow")
    gui.TextManager:Format_AddParam(nx_int(nPowerLevel))
    local shengtext = nx_widestr(gui.TextManager:Format_GetText())
    ShowTipDialog(shengtext)
    return false
  end
  local nCapital = GetCapitalValue()
  if nx_int(nDeposit) > nx_int(nCapital) then
    gui.TextManager:Format_SetIDName("ui_escort_jiebiaoyajinbuzutishi02")
    gui.TextManager:Format_AddParam(nx_int(nDeposit))
    local yintext = nx_widestr(gui.TextManager:Format_GetText())
    ShowTipDialog(yintext)
    return false
  end
  return true
end
function CanAceeptEscort(Escort_id, npcname)
  local strAcceptNpc, nPowerLevel, nDeposit = Get_Path_LimitInfo(Escort_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local curPowerLevel = GetPowerLevel()
  if nx_int(nPowerLevel) > nx_int(curPowerLevel) then
    return false
  end
  local nCapital = GetCapitalValue()
  if nx_int(nDeposit) > nx_int(nCapital) then
    return false
  end
  return true
end
function GetCapitalValue()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local nCapital = client_player:QueryProp("CapitalType1") + client_player:QueryProp("CapitalType2")
  return nCapital
end
function Get_ShengWang_Value()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = 0
  local value = 0
  local level = 0
  rows = client_player:FindRecordRow("Repute_Record", 0, "repute_jianghu", 0)
  if 0 <= rows then
    value = client_player:QueryRecord("Repute_Record", rows, 1)
    level = client_player:QueryRecord("Repute_Record", rows, 2) + 1
  else
    value = nx_string("0")
    level = 2
  end
  return value
end
function GetPowerLevel()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  return client_player:QueryProp("PowerLevel")
end
function Init_Escort_Path_Info(form, npcname, escort_list)
  Init_Fix_Path_Info(npcname)
  Init_Probability_Path_Info(form, escort_list)
  local nPathCount = table.getn(escort_path_info_table)
  if nPathCount <= MAX_PATH_COUNT then
    form.path_bar.Visible = false
    if nPathCount <= 0 then
      return 0
    end
  else
    form.path_bar.Visible = true
    form.path_bar.Maximum = nPathCount - MAX_PATH_COUNT
  end
  path_fresh(form.groupbox_escortpathinfo, 0, MAX_PATH_COUNT, nPathCount)
  ShowEscortInfo(form, escort_path_info_table[1][1], escort_path_info_table[1][2], escort_path_info_table[1][3], 1)
end
function Get_Path_LimitInfo(Escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(Escort_id))
  if path_index < 0 then
    return -1
  end
  local strAcceptNpc = formula_path:ReadString(path_index, "AcceptNpc", "")
  local nPowerLevel = formula_path:ReadInteger(path_index, "PowerLevel", 0)
  local nDeposit = formula_path:ReadInteger(path_index, "Deposit", 0)
  return strAcceptNpc, nPowerLevel, nDeposit
end
function Get_Path_Info(Escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(Escort_id))
  if path_index < 0 then
    return -1
  end
  local strStartArea = formula_path:ReadString(path_index, "StartArea", "")
  local strEndArea = formula_path:ReadString(path_index, "EndArea", "")
  local nType = formula_path:ReadInteger(path_index, "Type", 0)
  local strPathName = formula_path:ReadString(path_index, "PathName", "")
  local strTypePhoto = formula_path:ReadString(path_index, "SmallTypePhoto", "")
  return strStartArea, strEndArea, nType, strPathName, strTypePhoto
end
function Get_Path_Carriage_info(Escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(Escort_id))
  if path_index < 0 then
    return -1
  end
  local strCarType = formula_path:ReadString(path_index, "CarType", "")
  return strCarType
end
function GetDetailEscortInfo(Escort_id)
  local formula_path = nx_execute("util_functions", "get_ini", "share\\War\\escort_path.ini")
  if not nx_is_valid(formula_path) then
    return -1
  end
  local path_index = formula_path:FindSectionIndex(nx_string(Escort_id))
  if path_index < 0 then
    return -1
  end
  local strStartArea = formula_path:ReadString(path_index, "StartArea", "")
  local strEndArea = formula_path:ReadString(path_index, "EndArea", "")
  local nType = formula_path:ReadInteger(path_index, "Type", 0)
  local strDes = formula_path:ReadString(path_index, "Describe", "")
  local nTimeLimit = formula_path:ReadInteger(path_index, "TimeLimit", 0)
  local nGoodsNum = formula_path:ReadInteger(path_index, "GoodsNum", 0)
  local nPowerLevel = formula_path:ReadInteger(path_index, "PowerLevel", 0)
  local nDeposit = formula_path:ReadInteger(path_index, "Deposit", 0)
  local strPathName = formula_path:ReadString(path_index, "PathName", "")
  local strPublishTime = formula_path:ReadString(path_index, "Publish", "")
  local strAcceptNpc = formula_path:ReadString(path_index, "AcceptNpc", "")
  local strTypePhoto = formula_path:ReadString(path_index, "TypePhoto", "")
  local strRewardItem = formula_path:ReadString(path_index, "RewardItem", "")
  local strCarType = formula_path:ReadString(path_index, "CarType", "")
  local strAcceptNpcPos = formula_path:ReadString(path_index, "AcceptNpcPos", "")
  local nBaseCredit = formula_path:ReadInteger(path_index, "BaseCredit", 0)
  local nSingleGoodsCredit = formula_path:ReadInteger(path_index, "SingleGoodsCredit", 0)
  local nRewardCoin = formula_path:ReadInteger(path_index, "RewardCoin", 0)
  local nFluctuateCoin = formula_path:ReadInteger(path_index, "FluctuateCoin", 0)
  local nPathType = formula_path:ReadInteger(path_index, "PathType", 0)
  return strStartArea, strEndArea, nType, strDes, nTimeLimit, nGoodsNum, nPowerLevel, nDeposit, strPathName, strPublishTime, strAcceptNpc, strTypePhoto, strRewardItem, strCarType, strAcceptNpcPos, nBaseCredit, nSingleGoodsCredit, nRewardCoin, nFluctuateCoin, nPathType
end
function Init_Carriage_Table()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_carriage.ini")
  if not nx_is_valid(ini) then
    return
  end
  escort_carriage_table = {}
  local nCount = ini:GetSectionCount()
  for i = 0, nCount - 1 do
    local table_carriage = {}
    local section = ini:GetSectionByIndex(i)
    local MoveSpeed = ini:ReadInteger(i, "MoveSpeed", 0)
    local Hp = ini:ReadInteger(i, "HP", 0)
    local Name = ini:ReadString(i, "Name", "")
    local Photo_Out = ini:ReadString(i, "photoOut", "")
    local Photo_On = ini:ReadString(i, "photoOn", "")
    table_carriage[ESCORT_CARRIAGE_TYPE] = nx_int(section)
    table_carriage[ESCORT_CARRIAGE_NAME] = Name
    table_carriage[ESCORT_CARRIAGE_MOVESPEED] = MoveSpeed
    table_carriage[ESCORT_CARRIAGE_HP] = Hp
    table_carriage[ESCORT_CARRIAGE_PHOTO_ON] = Photo_On
    table_carriage[ESCORT_CARRIAGE_PHOTO_OUT] = Photo_Out
    table.insert(escort_carriage_table, table_carriage)
  end
end
function Get_GiveItem_Info(item)
  local ini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("pingzheng_escort_001")
  if index < 0 then
    return
  end
  local image = ini:ReadString(index, "Photo", "")
  return image
end
function Get_Publish_Path(npcname)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_npc.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(npcname)
  if index < 0 then
    return
  end
  local FixPath = ini:ReadString(index, "FixedEscortPath", "")
  return FixPath
end
function Init_Fix_Path_Info(npcname)
  local FixPath = Get_Publish_Path(npcname)
  if FixPath == "" or FixPath == nil then
    return
  end
  local Fix_Path_list = util_split_string(nx_string(FixPath), ",")
  local nCount = table.getn(Fix_Path_list)
  for i = 1, nCount do
    local path = {}
    path[1] = Fix_Path_list[i]
    path[2] = -1
    path[3] = -1
    table.insert(escort_path_info_table, path)
  end
end
function Get_PowerLevel_Name(PowerLevel)
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\FacultyLevel.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  if not ini:FindSection(nx_string("config")) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("config"))
  if sec_index < 0 then
    return ""
  end
  local power_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
  for i = 1, table.getn(power_table) do
    local powerinfo = power_table[i]
    local info_lst = util_split_string(powerinfo, ",")
    if nx_int(PowerLevel) == nx_int(info_lst[1]) then
      return util_text("desc_" .. nx_string(info_lst[3]))
    end
  end
end
function init_escort_path_ctrl_name(self)
  local num = table.getn(escort_path_info_name)
  for i = 0, num do
    escort_path_info_name[i][1] = nx_string("groupbox_path") .. nx_string(i)
    escort_path_info_name[i][2] = nx_string("escort_info") .. nx_string(i)
    escort_path_info_name[i][3] = nx_string("type") .. nx_string(i)
    escort_path_info_name[i][4] = nx_string("escort_name") .. nx_string(i)
    escort_path_info_name[i][5] = nx_string("startarea") .. nx_string(i)
    escort_path_info_name[i][6] = nx_string("endarea") .. nx_string(i)
    escort_path_info_name[i][7] = nx_string("path_tip") .. nx_string(i)
  end
  for row = 0, num do
    local initgroupboxobj = self:Find(nx_string(escort_path_info_name[row][1]))
    if nx_is_valid(initgroupboxobj) then
      initgroupboxobj.Visible = false
    end
  end
end
function Init_Probability_Path_Info(form, escort_list)
  if string.len(escort_list) <= 0 then
    return
  end
  local escort_table = util_split_string(nx_string(escort_list), "|")
  local nCount = table.getn(escort_table)
  for i = 1, nCount do
    local bRet, info = PaserEscortPathInfo(escort_table[i])
    if true == bRet then
      table.insert(escort_path_info_table, info)
    end
  end
  Escort_Timedown_Started(form)
end
function PaserEscortPathInfo(escort_info)
  local info = util_split_string(nx_string(escort_info), ",")
  if table.getn(info) ~= 3 then
    return false
  end
  return true, info
end
function path_fresh(self, startrow, endrow, rownum)
  local num = table.getn(escort_path_info_table)
  local index = 0
  local nShowCount = rownum > endrow + startrow and endrow + startrow or rownum
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  init_escort_path_ctrl_name(self)
  for row = startrow + 1, nShowCount do
    if row <= 0 then
      return
    end
    local nEscort_id = escort_path_info_table[row][1]
    local strStartArea, strEndArea, nType, strPathName, strTypePhoto = Get_Path_Info(nEscort_id)
    local groupboxname = escort_path_info_name[index][1]
    local groupboxobj = self:Find(groupboxname)
    groupboxobj.Visible = true
    local startarea_name = escort_path_info_name[index][5]
    local lbl_startarea = groupboxobj:Find(startarea_name)
    if nx_is_valid(lbl_startarea) then
      lbl_startarea.HtmlText = nx_widestr(util_text(nx_string(strStartArea)))
    end
    local descname = escort_path_info_name[index][6]
    local lbl_desc = groupboxobj:Find(descname)
    if nx_is_valid(lbl_desc) then
      lbl_desc.Text = nx_widestr(util_text(nx_string(strEndArea)))
    end
    local typename = escort_path_info_name[index][3]
    local lbl_type = groupboxobj:Find(typename)
    if nx_is_valid(lbl_type) then
      lbl_type.BackImage = strTypePhoto
    end
    local escort_name = escort_path_info_name[index][4]
    local lbl_escortname = groupboxobj:Find(escort_name)
    if nx_is_valid(lbl_escortname) then
      lbl_escortname.Text = nx_widestr(util_text(nx_string(strPathName)))
    end
    local btn_name = escort_path_info_name[index][2]
    local btn_obj = groupboxobj:Find(btn_name)
    if nx_is_valid(btn_obj) then
      btn_obj.Escort_id = escort_path_info_table[row][1]
      btn_obj.AcceptTimes = escort_path_info_table[row][2]
      btn_obj.TimeDown = escort_path_info_table[row][3]
      btn_obj.Escort_pos = row
      if index == 0 then
        btn_obj.NormalImage = ESCORT_SEL_PATH
        btn_obj.PushImage = ESCORT_SEL_PATH
      end
    end
    local btn_name = escort_path_info_name[index][7]
    local lbl_path_tip = groupboxobj:Find(btn_name)
    if nx_is_valid(lbl_path_tip) then
      if not CanAceeptEscort(nEscort_id, form.npcname) then
        lbl_path_tip.Text = nx_widestr(util_text("ui_escort_acceptlimit"))
      else
        lbl_path_tip.Text = nx_widestr("")
      end
    end
    index = index + 1
    if nx_int(MAX_PATH_COUNT) <= nx_int(index) then
      return
    end
  end
end
function fresh_path_state(grp)
  if not nx_is_valid(grp) then
    return
  end
  local num = table.getn(escort_path_info_name)
  for i = 0, num do
    local groupboxname = escort_path_info_name[i][1]
    if groupboxname ~= nil and groupboxname ~= "" then
      local groupboxobj = grp:Find(groupboxname)
      local btn_name = escort_path_info_name[i][2]
      local btn_obj = groupboxobj:Find(btn_name)
      if nx_is_valid(btn_obj) then
        btn_obj.NormalImage = ESCORT_PATH_NORMAIL_IMAGE
        btn_obj.PushImage = ESCORT_PATH_PUSH_IMAGE
      end
    end
  end
end
function ShowEscortInfo(form, Escort_id, AcceptTimes, TimeDown, Escort_pos)
  if 0 == Escort_id then
    return
  end
  local strStartArea, strEndArea, nType, strDes, nTimeLimit, nGoodsNum, nPowerLevel, nDeposit, strPathName, strPublishTime, strAcceptNpc, strTypePhoto, strRewardItem, strCarType, strAcceptNpcPos, nBaseCredit, nSingleGoodsCredit, nRewardCoin, nFluctuateCoin, nPathType = GetDetailEscortInfo(Escort_id)
  form.bshow_time = false
  local npcname = form.npcname
  form.Escort_id = Escort_id
  form.nDeposit = nDeposit
  form.strPathName = strPathName
  local nCapital = GetCapitalValue()
  if nx_int(nDeposit) > nx_int(nCapital) then
    form.mltbox_deposit.TextColor = "255,255,0,0"
  else
    form.mltbox_deposit.TextColor = "255,95,67,37"
  end
  if nx_int(TimeDown) <= nx_int(0) then
    form.lbl_escort_time.Text = nx_widestr(util_text("ui_escort_nolimit_times"))
    form.lbl_escort_time.ForeColor = "255,95,67,37"
  else
    form.TimeDown = TimeDown
    form.timer_span = 1000
    form.bshow_time = true
  end
  local car_list = util_split_string(strCarType, ",")
  local nCount = table.getn(car_list)
  for i = 1, nCount do
    ShowCarriageInfo(i, car_list[i] + 1)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local Credit = nx_int(nGoodsNum) * nx_int(nSingleGoodsCredit) + nx_int(nBaseCredit)
  form.lbl_credit.Text = nx_widestr(nx_string(Credit))
  if nx_int(AcceptTimes) < nx_int(0) then
    form.lbl_escort_pathtimes.Text = nx_widestr(util_text("ui_escort_nolimit_times"))
    form.lbl_escort_pathtimes.ForeColor = "255,95,67,37"
  elseif nx_int(AcceptTimes) == nx_int(0) then
    form.lbl_escort_pathtimes.Text = nx_widestr(nx_string(AcceptTimes))
    form.lbl_escort_pathtimes.ForeColor = "255,255,0,0"
  else
    form.lbl_escort_pathtimes.Text = nx_widestr(nx_string(AcceptTimes))
    form.lbl_escort_pathtimes.ForeColor = "255,95,67,37"
  end
  if strTypePhoto == "" or strTypePhoto == nil then
    form.lbl_type.Visible = false
  else
    form.lbl_type.Visible = true
  end
  form.lbl_type.BackImage = strTypePhoto
  form.lbl_escort_des.HtmlText = nx_widestr(util_text(nx_string(strDes)))
  form.mltbox_startarea.HtmlText = nx_widestr(util_text(nx_string(strStartArea)))
  form.lbl_endarea.Text = nx_widestr(util_text(nx_string(strEndArea)))
  form.lbl_timelimit.Text = nx_widestr(get_format_time_text(nTimeLimit))
  form.lbl_goodsnum.Text = nx_widestr(nx_string(nGoodsNum))
  form.lbl_powerlevel.Text = nx_widestr(Get_PowerLevel_Name(nPowerLevel))
  form.mltbox_deposit.HtmlText = nx_widestr(get_yin_info(nDeposit))
  form.lbl_escort_name.Text = nx_widestr(util_text(nx_string(strPathName)))
  local image = Get_GiveItem_Info(strRewardItem)
  form.imagegrid_reward:Clear()
  form.imagegrid_reward:AddItem(0, image, nx_widestr(strRewardItem), 1, -1)
  form.lbl_ping_zheng.Text = nx_widestr(nx_string(nGoodsNum))
  local nSliver = nx_int(nRewardCoin) + nx_int(nFluctuateCoin) / nx_int(math.pow(2, 1))
  form.mtb_sliver.HtmlText = nx_widestr(get_yin_info(nSliver))
  local gongxian = get_escort_contribute(nPathType)
  form.lbl_gongxian.Text = nx_widestr(nx_string(gongxian))
  local guild_sliver = get_guild_sliver(nPathType)
  form.mltbox_guild_sliver.HtmlText = nx_widestr(get_yin_info(guild_sliver))
  if nx_int(nPathType) == nx_int(0) then
    form.groupbox_3.Visible = false
  else
    form.groupbox_3.Visible = true
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local flag = switch_manager:CheckSwitchEnable(ST_FUNCTION_GOLD_ESCORT)
  if flag then
    form.lbl_szgold_tips.Visible = false
  else
    form.lbl_szgold_tips.Visible = true
  end
end
function ShowCarriageInfo(pos, carriage_id)
  local form = util_get_form("form_stage_main\\form_school_war\\form_escort")
  if not nx_is_valid(form) then
    return
  end
  if carriage_id > table.getn(escort_carriage_table) then
    return
  end
  local group = form.groupbox_escort_detail_info
  local lbl_name = group:Find(carriage_name[pos][CARRIAGE_NAME])
  if nx_is_valid(lbl_name) then
    lbl_name.Text = nx_widestr(util_text(nx_string(escort_carriage_table[carriage_id][ESCORT_CARRIAGE_NAME])))
  end
  local btn_photo = group:Find(carriage_name[pos][CARRIAGE_PHOTO])
  if nx_is_valid(btn_photo) then
    btn_photo.carriage_pos = pos
    btn_photo.carriage_id = carriage_id
    btn_photo.carriage_type = escort_carriage_table[carriage_id][ESCORT_CARRIAGE_TYPE]
    btn_photo.NormalImage = escort_carriage_table[carriage_id][ESCORT_CARRIAGE_PHOTO_OUT]
    btn_photo.FocusImage = escort_carriage_table[carriage_id][ESCORT_CARRIAGE_PHOTO_ON]
    local lbl_Sel = group:Find(carriage_name[pos][CARRIAGE_SEL])
    if nx_is_valid(lbl_Sel) then
      if 2 == pos then
        lbl_Sel.BackImage = ESCORT_SEL_CARRIAGE
        form.carriage_type = btn_photo.carriage_type
      else
        lbl_Sel.BackImage = ""
      end
    end
  end
end
function get_format_time_text(time)
  local format_time = ""
  local sec = nx_int(time) <= nx_int(0) and 0 or nx_int(math.fmod(nx_number(time), 60))
  local min = nx_int(math.fmod(nx_number(time), 3600)) / nx_int(60)
  local hour = nx_int(time) / nx_int(3600)
  if nx_int(0) >= nx_int(hour) then
    format_time = string.format("00:%02d:%02d", nx_number(min), nx_number(sec))
  else
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  end
  return nx_string(format_time)
end
function Escort_Timedown_Started(form)
  local timer = nx_value(GAME_TIMER)
  timer:Register(nx_int(form.timer_span), -1, nx_current(), "On_Update_Escort_Time", form, -1, -1)
end
function Reset_Escort_Timedown(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "On_Update_Escort_Time", form)
end
function On_Update_Escort_Time(form)
  local nCount = table.getn(escort_path_info_table)
  for i = 1, nCount do
    if nx_int(escort_path_info_table[i][3]) > nx_int(0) then
      escort_path_info_table[i][3] = nx_int(escort_path_info_table[i][3]) - nx_int(1)
    end
  end
  if form.bshow_time == false then
    return
  end
  local time = GetTimeDownFromEscortID(form)
  if nx_int(time) <= nx_int(0) then
    form.lbl_escort_time.Text = nx_widestr(get_format_time_text(0))
    form.lbl_escort_time.ForeColor = "255,255,0,0"
    return
  end
  form.lbl_escort_time.ForeColor = "255,95,67,37"
  form.lbl_escort_time.Text = nx_widestr(get_format_time_text(time))
end
function GetTimeDownFromEscortID(form)
  local time = 0
  local nCount = table.getn(escort_path_info_table)
  for i = 1, nCount do
    if nx_int(escort_path_info_table[i][1]) == nx_int(form.Escort_id) then
      time = nx_int(escort_path_info_table[i][3])
    end
  end
  if nx_int(time) <= nx_int(0) then
    return 0
  end
  return time
end
function on_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nCount = table.getn(escort_carriage_table)
  if nx_int(0) >= nx_int(nCount) then
    return
  end
  local carriage_id = btn.carriage_id
  if nx_int(nCount) < nx_int(carriage_id) then
    return
  end
  local pos = btn.carriage_pos
  local tip_text
  if nx_int(1) == nx_int(pos) then
    tip_text = util_text("ui_escort_kuai")
  elseif nx_int(2) == nx_int(pos) then
    tip_text = util_text("ui_escort_zhong")
  else
    tip_text = util_text("ui_escort_man")
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(tip_text), btn.AbsLeft + 5, btn.AbsTop + 5, 0, btn.ParentForm)
end
function on_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function get_yin_info(n)
  local gui = nx_value("gui")
  local capital_manager = nx_value("CapitalModule")
  local res = {}
  local htmlTextYinZi = nx_widestr("<center>")
  if nx_is_valid(capital_manager) then
    res = capital_manager:SplitCapital(nx_int(n), CAPITAL_TYPE_SILVER)
    local ding = res[1]
    local liang = res[2]
    local wen = res[3]
    local capital = nx_int(n)
    local gui = nx_value("gui")
    local textyZi = nx_widestr("")
    if nx_int(ding) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_ding")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
    end
    if nx_int(liang) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_liang")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
    end
    if nx_int(wen) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
    end
    if capital == 0 then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
    end
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("</center>")
  end
  return htmlTextYinZi
end
function on_imagegrid_skill_mousein_grid(grid, index)
  local skill_configID = grid:GetItemName(index)
  if skill_configID == nil or nx_string(skill_configID) == "" then
    return
  end
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", skill_configID, x, y, form)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_type_get_capture(lbl)
  nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_escort_specialtips")), lbl.AbsLeft + 5, lbl.AbsTop + 5, 0, lbl.ParentForm)
end
function on_type_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function get_escort_contribute(path_type)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_config.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex("EscortContribute")
  if nx_int(0) >= nx_int(index) then
    return
  end
  if nx_int(0) == nx_int(path_type) then
    return ini:ReadInteger(index, "CommonContribute", 0)
  elseif nx_int(1) == nx_int(path_type) or nx_int(2) == nx_int(path_type) then
    return ini:ReadInteger(index, "ConditionContribute", 0)
  end
  return 0
end
function get_guild_sliver(path_type)
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\guild_interact.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section
  if nx_int(0) == nx_int(path_type) then
    section = "1"
  elseif nx_int(1) == nx_int(path_type) or nx_int(2) == nx_int(path_type) then
    section = "2"
  end
  local index = ini:FindSectionIndex(nx_string(section))
  if nx_int(0) > nx_int(index) then
    return
  end
  local value = ini:GetSectionItemValue(index, 0)
  local args = util_split_string(value, ",")
  return nx_int(args[4])
end
