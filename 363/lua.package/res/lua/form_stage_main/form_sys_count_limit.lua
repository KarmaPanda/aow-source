require("util_functions")
require("share\\client_custom_define")
local CountLimitTable = {}
local CountLimitRecTableName = "Count_Limit_Form_Rec"
function main_form_init(form)
  form.Fixed = false
  CountLimitTable = {}
  form.UpdateFlag = true
  form.HideFlag = false
  return 1
end
function on_main_form_open(form)
end
function on_main_form_close(form)
end
function change_count_form(form)
  local gui = nx_value("gui")
  local count = table.getn(CountLimitTable)
  form.Height = nx_number(60 + 20 * count)
  form.ImageControlGrid.Width = 180
  form.ImageControlGrid.Height = 20 * count
  form.ImageControlGrid.RowNum = count
  form.ImageControlGrid.ClomnNum = 1
  form.ImageControlGrid.ViewRect = string.format("%d,%d,%d,%d", 0, 0, form.Width, 20 * count)
  if form.UpdateFlag then
    change_position(form)
    form.UpdateFlag = false
  end
  return 1
end
function change_position(form)
  local form_main_map = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_map", false, false)
  local form_time = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_time_limit", false, false, "timelimitform")
  local gui = nx_value("gui")
  if nx_is_valid(form_main_map) then
    if nx_is_valid(form_time) and form_time.Visible then
      if form_time.AbsTop + form_time.Height + 10 >= gui.Desktop.Height then
        form.AbsTop = form_time.AbsTop - form.Height
        form.AbsLeft = form_time.AbsLeft
      else
        form.AbsTop = form_time.AbsTop + form_time.Height
        form.AbsLeft = form_time.AbsLeft
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
function create_countlimit_table()
  CountLimitTable = {}
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(client_scene) then
    return
  end
  if not client_scene:FindRecord(CountLimitRecTableName) then
    return
  end
  local rows = client_scene:GetRecordRows(CountLimitRecTableName)
  if rows == 0 then
    clear_count_limit(form)
    return
  end
  local cdtkmgr = nx_value("ConditionManager")
  if not nx_is_valid(cdtkmgr) then
    return
  end
  local gui = nx_value("gui")
  for i = 0, rows - 1 do
    local strId = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 0))
    local strDescId = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 1))
    local strDesc = gui.TextManager:GetText(strDescId)
    local nCount = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 2))
    local nTag = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 3))
    local strCondition = nx_string(client_scene:QueryRecord(CountLimitRecTableName, i, 4))
    local nFlag = nx_number(client_scene:QueryRecord(CountLimitRecTableName, i, 5))
    if not IsExistCountLimitTable(strId) then
      if nTag == 1 then
        local tempTab = {}
        tempTab[1] = strDesc
        tempTab[2] = nCount
        tempTab[3] = strId
        tempTab[4] = nFlag
        table.insert(CountLimitTable, tempTab)
      elseif cdtkmgr:CanSatisfyCondition(player_obj, player_obj, nx_int(strCondition)) then
        local tempTab = {}
        tempTab[1] = strDesc
        tempTab[2] = nCount
        tempTab[3] = strId
        tempTab[4] = nFlag
        table.insert(CountLimitTable, tempTab)
      end
    end
  end
end
function do_show_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_count_limit", true, false, "CountLimitform")
  create_countlimit_table()
  if table.getn(CountLimitTable) == 0 then
    clear_count_limit(form)
    return
  end
  if form.HideFlag then
    return
  end
  change_count_form(form)
  form.Visible = true
  form:Show()
  update_info(form)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  return 1
end
function show_count_limit_form()
  return do_show_form()
end
function close_count_limit_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_count_limit", false, false, "CountLimitform")
  if not nx_is_valid(form) then
    return
  end
  clear_count_limit(form)
end
function IsExistCountLimitTable(strId)
  for i = 1, table.getn(CountLimitTable) do
    local countlimitdesc_tab = CountLimitTable[i]
    local sId = nx_string(countlimitdesc_tab[3])
    if sId == strId then
      return true
    end
  end
  return false
end
function update_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.ImageControlGrid:Clear()
  local item_num = table.getn(CountLimitTable)
  for i = 0, item_num - 1 do
    local CountLimitdesc_tab = CountLimitTable[i + 1]
    local strDesc = nx_string(CountLimitdesc_tab[1])
    local count = nx_number(CountLimitdesc_tab[2])
    local index_name = nx_string(CountLimitdesc_tab[3])
    local nflag = nx_number(CountLimitdesc_tab[4])
    local file_name = "share\\Rule\\CountLimit.ini"
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
    if ini:FindSectionItemIndex(sec_index, "MaxCount") ~= -1 then
      local max_count = ini:ReadString(sec_index, "MaxCount", "")
      form.ImageControlGrid:SetItemAddInfo(i, 1, nx_widestr(count .. "/" .. nx_string(max_count)))
    else
      form.ImageControlGrid:SetItemAddInfo(i, 1, nx_widestr(count))
    end
    form.ImageControlGrid:ShowItemAddInfo(i, 1, true)
    if nflag == 0 then
      form.ImageControlGrid:ChangeItemImageToBW(i, true)
    end
  end
end
function clear_count_limit(form)
  if not nx_is_valid(form) then
    return
  end
  CountLimitTable = {}
  form.UpdateFlag = true
  form.HideFlag = false
  form.ImageControlGrid:Clear()
  form:Close()
  nx_destroy(form)
end
function on_ImageControlGrid_mousein_grid(self, index)
  local gui = nx_value("gui")
  local item_num = table.getn(CountLimitTable)
  if index >= item_num then
    return false
  end
  local CountLimitdesc_tab = CountLimitTable[index + 1]
  local index_name = nx_string(CountLimitdesc_tab[3])
  local file_name = "share\\Rule\\CountLimit.ini"
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
  local nFlag = nx_number(CountLimitdesc_tab[4])
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
  form.HideFlag = not form.HideFlag
  if form.HideFlag then
    form.Height = 50
  else
    form.BlendColor = "255,255,255,255"
    show_count_limit_form()
  end
end
function on_main_form_get_capture(form)
  if form.Height ~= 50 then
    return
  end
  if is_mouse_in_control(form.btn_help) or is_mouse_in_control(form.btn_hide) then
    return
  end
  form.btn_help.Visible = true
  form.btn_hide.Visible = true
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
  form.btn_help.Visible = false
  form.btn_hide.Visible = false
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
