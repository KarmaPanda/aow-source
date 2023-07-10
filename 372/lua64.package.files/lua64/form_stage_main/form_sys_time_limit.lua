require("util_functions")
require("share\\client_custom_define")
local TimeLimitTable = {}
local TimeLimitRecTableName = "Time_Limit_Form_Rec"
local CountLimitRecTableName = "Count_Limit_Form_Rec"
local ServerTime = 0
function main_form_init(form)
  form.Fixed = false
  form.TimeUpdateFlag = true
  form.TimeHideFlag = false
  form.show = true
  TimeLimitTable = {}
  return 1
end
function on_main_form_open(form)
  form.btn_show.Visible = false
end
function on_main_form_close(form)
  form.TimeUpdateFlag = true
  form.TimeHideFlag = false
end
function change_time_form(form)
  local gui = nx_value("gui")
  local count = 0
  for i = 1, table.getn(TimeLimitTable) do
    local timelimitdesc_tab = TimeLimitTable[i]
    if 0 < nx_int(timelimitdesc_tab[2]) - nx_int(nx_function("ext_get_tickcount")) then
      count = count + 1
    end
  end
  form.Height = nx_number(60 + 20 * count)
  form.groupbox_time.Height = nx_number(60 + 20 * count)
  form.ImageControlGrid.Width = 200
  form.ImageControlGrid.Height = 20 * count
  form.ImageControlGrid.RowNum = count
  form.ImageControlGrid.ClomnNum = 1
  form.ImageControlGrid.ViewRect = string.format("%d,%d,%d,%d", 0, 0, 200, nx_number(20 * count))
  if form.TimeUpdateFlag then
    change_position(form)
    form.TimeUpdateFlag = false
  end
end
function change_position(form)
  local form_main_map = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_map", false, false)
  local form_count = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_count_limit", false, false, "CountLimitform")
  local gui = nx_value("gui")
  if nx_is_valid(form_main_map) then
    if nx_is_valid(form_count) and form_count.Visible then
      if form_count.AbsTop + form_count.Height + 10 >= gui.Desktop.Height then
        form.AbsTop = form_count.AbsTop - form.Height
        form.AbsLeft = form_count.AbsLeft
      else
        form.AbsTop = form_count.AbsTop + form_count.Height
        form.AbsLeft = form_count.AbsLeft
      end
    else
      form.AbsTop = form_main_map.AbsTop
      form.AbsLeft = form_main_map.AbsLeft - 62
    end
  else
    form.Left = (gui.Width - form.Width) / 2
    form.Top = 10
  end
  return 1
end
function asyn_server_time(server_time)
  ServerTime = server_time
  do_show_form()
end
function create_timelimit_table()
  TimeLimitTable = {}
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord(TimeLimitRecTableName) then
    return
  end
  local rows = client_scene:GetRecordRows(TimeLimitRecTableName)
  if rows == 0 then
    close_time_limit_form()
    return
  end
  local server_time = ServerTime
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return false
  end
  local gui = nx_value("gui")
  for i = 0, rows - 1 do
    local strId = client_scene:QueryRecord(TimeLimitRecTableName, i, 0)
    if strId ~= nil then
      strId = nx_string(strId)
      local strDescId = client_scene:QueryRecord(TimeLimitRecTableName, i, 1)
      local strDesc = gui.TextManager:GetText(nx_string(strDescId))
      local nTimer = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 2))
      local nTimeLimit = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 3))
      local nTag = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 4))
      local strCondition = nx_string(client_scene:QueryRecord(TimeLimitRecTableName, i, 5))
      local nFlag = nx_number(client_scene:QueryRecord(TimeLimitRecTableName, i, 6))
      local nGroupID = nx_int(client_scene:QueryRecord(TimeLimitRecTableName, i, 7))
      strDesc = GetDomainName(strId, strDesc)
      if not IsExistTimeLimitTable(strId) and IsExistGroupID(nGroupID) and server_time < nTimeLimit then
        local ClientTimeLimit = nTimeLimit - server_time + nx_function("ext_get_tickcount")
        if nTag == 1 then
          local tempTab = {}
          tempTab[1] = strDesc
          tempTab[2] = ClientTimeLimit
          tempTab[3] = strId
          tempTab[4] = nFlag
          tempTab[5] = nGroupID
          table.insert(TimeLimitTable, tempTab)
        elseif cdtkmgr:CanSatisfyCondition(player_obj, player_obj, nx_int(strCondition)) then
          local tempTab = {}
          tempTab[1] = strDesc
          tempTab[2] = ClientTimeLimit
          tempTab[3] = strId
          tempTab[4] = nFlag
          tempTab[5] = nGroupID
          table.insert(TimeLimitTable, tempTab)
        end
      end
    end
  end
end
function do_show_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_time_limit", true, false, "timelimitform")
  create_timelimit_table()
  if table.getn(TimeLimitTable) == 0 then
    close_time_limit_form()
    return
  end
  if not form.TimeHideFlag then
    change_time_form(form)
  end
  form.Visible = true
  form:Show()
  update_info(form)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  init_timer(form)
  return 1
end
function show_time_limit_form()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_AS_TIME))
  return 1
end
function close_time_limit_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_time_limit", false, false, "timelimitform")
  if not nx_is_valid(form) then
    return
  end
  clear_time_limit(form)
  end_timer(form)
end
function init_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(500, -1, nx_current(), "on_update_time", form, -1, -1)
end
function get_format_time_text(time)
  local format_time = ""
  if nx_number(time) >= 3600 then
    local hour = nx_int(time / 3600)
    local min = nx_int(math.mod(time, 3600) / 60)
    local sec = nx_int(math.mod(math.mod(time, 3600), 60))
    format_time = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(min), nx_number(sec))
  elseif nx_number(time) >= 60 then
    local min = nx_int(time / 60)
    local sec = nx_int(math.mod(time, 60))
    format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  else
    local sec = nx_int(time)
    format_time = string.format("00:%02d", nx_number(sec))
  end
  return nx_string(format_time) .. "<br>"
end
function IsExistTimeLimitTable(strId)
  for i = 1, table.getn(TimeLimitTable) do
    local timelimitdesc_tab = TimeLimitTable[i]
    local sId = nx_string(timelimitdesc_tab[3])
    if sId == strId then
      return true
    end
  end
  return false
end
function IsExistGroupID(nGroupID)
  if nx_int(-1) == nx_int(nGroupID) then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local player_groupid = client_player:QueryProp("GroupID")
  if nx_int(nGroupID) == nx_int(player_groupid) then
    return true
  end
  return false
end
function update_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.ImageControlGrid:Clear()
  local item_num = table.getn(TimeLimitTable)
  for i = 0, item_num - 1 do
    local timelimitdesc_tab = TimeLimitTable[i + 1]
    local strDesc = nx_string(timelimitdesc_tab[1])
    local timer = (nx_int(timelimitdesc_tab[2]) - nx_int(nx_function("ext_get_tickcount"))) / 1000
    if nx_int(timer) < nx_int(0) then
      timer = 0
    end
    local format_timer = get_format_time_text(timer)
    local index_name = nx_string(timelimitdesc_tab[3])
    local nflag = nx_number(timelimitdesc_tab[4])
    local file_name = "share\\Rule\\TimeLimit.ini"
    local IniManager = nx_value("IniManager")
    local ini = IniManager:GetIniDocument(file_name)
    local sec_index = ini:FindSectionIndex(nx_string(index_name))
    if sec_index < 0 then
      return
    end
    local photo = ini:ReadString(sec_index, "Photo", "")
    form.ImageControlGrid:AddItem(i, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
    form.ImageControlGrid:SetItemName(i, nx_widestr(index_name))
    form.ImageControlGrid:SetItemAddInfo(i, 0, nx_widestr(strDesc))
    form.ImageControlGrid:ShowItemAddInfo(i, 0, true)
    form.ImageControlGrid:SetItemAddInfo(i, 1, nx_widestr(format_timer))
    form.ImageControlGrid:ShowItemAddInfo(i, 1, true)
    if nflag == 0 then
      form.ImageControlGrid:ChangeItemImageToBW(i, true)
    end
  end
end
function on_update_time(form)
  for index = 1, table.getn(TimeLimitTable) do
    local temp = TimeLimitTable[index]
    if not IsExistGroupID(temp[5]) then
      table.remove(TimeLimitTable, index)
    end
  end
  update_info(form)
  local bExist = false
  for i = 1, table.getn(TimeLimitTable) do
    local timelimitdesc_tab = TimeLimitTable[i]
    local CurClientTime = nx_function("ext_get_tickcount")
    local ClientTimeLimit = timelimitdesc_tab[2]
    if nx_number(CurClientTime) < nx_number(ClientTimeLimit) then
      bExist = true
    end
  end
  if not bExist then
    clear_time_limit(form)
    end_timer(form)
  end
end
function end_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  form.ImageControlGrid:Clear()
  form:Close()
  nx_destroy(form)
end
function clear_time_limit(form)
  TimeLimitTable = {}
end
function on_ImageControlGrid_mousein_grid(self, index)
  local gui = nx_value("gui")
  local item_num = table.getn(TimeLimitTable)
  if index >= item_num then
    return false
  end
  local timelimitdesc_tab = TimeLimitTable[index + 1]
  local index_name = nx_string(timelimitdesc_tab[3])
  local file_name = "share\\Rule\\TimeLimit.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index_name))
  if sec_index < 0 then
    return false
  end
  local tips_text = ini:ReadString(sec_index, "TipsText", "")
  local TipsArray = util_split_string(nx_string(tips_text), ",")
  if 0 == table.getn(TipsArray) then
    return false
  end
  local nFlag = nx_number(timelimitdesc_tab[4])
  local strTips = TipsArray[nFlag + 1]
  local text = gui.TextManager:GetFormatText(nx_string(strTips))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, self.ParentForm)
end
function on_ImageControlGrid_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
end
function on_btn_hide_click(btn)
  local form = btn.ParentForm
  local vis = form.ImageControlGrid.Visible
  form.ImageControlGrid.Visible = not vis
  form.TimeHideFlag = not form.TimeHideFlag
  if form.show then
    form.groupbox_time.Visible = false
    form.btn_show.Visible = true
    form.show = false
  else
    form.groupbox_time.Visible = true
    form.btn_show.Visible = false
    form.show = true
  end
  if form.TimeHideFlag then
    form.Height = 50
  else
    form.BlendColor = "255,255,255,255"
    change_time_form(form)
  end
end
function on_main_form_get_capture(form)
  if form.Height ~= 50 then
    return
  end
  if is_mouse_in_control(form.btn_help) or is_mouse_in_control(form.btn_hide) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorOut", form)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  form.cur_alpha = nx_float(temp[1])
  common_execute:AddExecute("FormBlendColorIn", form, nx_float(0.01), nx_float(255))
end
function on_main_form_lost_capture(form)
  if form.Height ~= 50 then
    return
  end
  if is_mouse_in_control(form.btn_help) or is_mouse_in_control(form.btn_hide) then
    return
  end
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("FormBlendColorIn", form)
  local blend = form.BlendColor
  local temp = util_split_string(blend, ",")
  form.cur_alpha = nx_float(temp[1])
  common_execute:AddExecute("FormBlendColorOut", form, nx_float(0.01))
end
function is_mouse_in_control(self)
  local gui = nx_value("gui")
  local mouse_x, mouse_y = gui:GetCursorPosition()
  if nx_float(mouse_x) > nx_float(self.AbsLeft) and nx_float(mouse_x) < nx_float(self.AbsLeft + self.Width) and nx_float(mouse_y) > nx_float(self.AbsTop) and nx_float(mouse_y) < nx_float(self.AbsTop + self.Height) then
    return true
  else
    return false
  end
end
function GetDomainName(strId, strDesc)
  local gui = nx_value("gui")
  local domain_name = ""
  if string.find(strId, "guildwar001") ~= nil or string.find(strId, "guildwar002") ~= nil then
    local str_lst = nx_function("ext_split_string", strId, "_")
    local count = table.getn(str_lst)
    if nx_int(count) >= nx_int(2) then
      local domain_id = str_lst[2]
      local name_str = "ui_dipan_" .. nx_string(domain_id)
      domain_name = gui.TextManager:GetText(name_str)
      domain_name = nx_string(domain_name) .. nx_string(":") .. nx_string(strDesc)
    end
  else
    return strDesc
  end
  return domain_name
end
