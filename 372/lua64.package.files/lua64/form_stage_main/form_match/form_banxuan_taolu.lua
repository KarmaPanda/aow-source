require("util_functions")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local FORM_PATH = "form_stage_main\\form_match\\form_banxuan_taolu"
local bxtl_array_name = "form_banxuan_taolu_array"
local bxtl_sx_array_name = "form_banxuan_sx_array"
local array_name_index = "form_ban_array_"
local form_combobox = "combobox_"
local form_sx_table = {}
local CUSMSG_BAN_TAOLU_OPEN = 0
local CUSMSG_BAN_TAOLU_TIME = 1
local CUSMSG_BAN_TAOLU_TAOLU = 2
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local width = form.textgrid_1.Width
  form.textgrid_1:SetColWidth(0, width - 20)
  form.Banxuan_Count = 0
  form.Over_Time = 0
  form.limit_id = 0
  form.WuqiIndex = 0
  form.WuXueIndex = 0
  form.SanzhaoIndex = 0
  form.lbl_26.Visible = false
  form.lbl_17.Visible = false
  form.lbl_18.Visible = false
  form.lbl_19.Visible = false
  form.lbl_20.Visible = false
  form_sx_table = {}
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  common_array:ClearChild(bxtl_array_name)
  if not common_array:FindArray(bxtl_array_name) then
    common_array:AddArray(bxtl_array_name, form, 60, false)
  end
  if not common_array:FindArray(bxtl_sx_array_name) then
    common_array:AddArray(bxtl_sx_array_name, form, 60, false)
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("msg_add_taolu_01"))
  nx_destroy(form)
end
function open_form(...)
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  local BanxuanCount = nx_int(arg[1])
  local limit_id = nx_int(arg[2])
  local server_time = nx_int(arg[3])
  nx_log("time info" .. " - " .. nx_string(get_cur_time()) .. " - " .. nx_string(wait_time) .. " - " .. nx_string(server_time))
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_MATCH_REVENGE_BAN_TAOLU)
  if BanxuanCount == 0 or not enable then
    nx_log("open confirm " .. " - " .. nx_string(BanxuanCount) .. " - " .. nx_string(enable))
    nx_execute("form_stage_main\\form_match\\form_taolu_confirm_new", "open_form", 8, limit_id)
    form:Close()
    return
  end
  form:Show()
  form.Visible = true
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("msg_ban_taolu_01"))
  form.Banxuan_Count = BanxuanCount
  form.Over_Time = server_time
  form.limit_id = limit_id
  form.lbl_2.Text = nx_widestr(form.Banxuan_Count)
  form.btn_1.Enabled = false
  LoadBanxuanTaolu()
  LoadShaixuan()
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(bxtl_array_name) then
    return
  end
  local list = common_array:GetChildList(bxtl_array_name)
  if 1 > table.getn(list) then
    return
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, table.getn(list) do
    if nx_string(list[i]) ~= nx_string("") then
      local row = form.textgrid_1:InsertRow(-1)
      form.textgrid_1:SetGridText(row, 0, nx_widestr(util_text(list[i])))
      form.textgrid_1:SetGridText(row, 1, nx_widestr(list[i]))
    end
  end
  form.textgrid_1:EndUpdate()
  for i = 1, table.getn(form_sx_table) do
    local table_info = form_sx_table[i]
    local sx_type = table_info[1]
    local form_cb = form_combobox .. nx_string(sx_type)
    local cb = nx_custom(form, form_cb)
    if nx_is_valid(cb) then
      cb.DropListBox:AddString(nx_widestr(util_text(table_info[3])))
    end
  end
  form.combobox_wuqi.DropListBox.SelectIndex = 0
  form.combobox_wuqi.Text = nx_widestr(form.combobox_wuqi.DropListBox:GetString(form.combobox_wuqi.DropListBox.SelectIndex))
  form.combobox_wuxue.DropListBox.SelectIndex = 0
  form.combobox_wuxue.Text = nx_widestr(form.combobox_wuxue.DropListBox:GetString(form.combobox_wuxue.DropListBox.SelectIndex))
  form.combobox_sanzhao.DropListBox.SelectIndex = 0
  form.combobox_sanzhao.Text = nx_widestr(form.combobox_sanzhao.DropListBox:GetString(form.combobox_sanzhao.DropListBox.SelectIndex))
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textgrid_1.RowSelectIndex
  if row < 0 then
    return
  end
  local taolu_id = form.textgrid_1:GetGridText(row, 1)
  btn.DataSource = nx_string(taolu_id)
  SendBanxuanOper(form)
end
function on_combobox_wuqi_selected(cbox)
  local form = cbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(cbox, "wuqi"))
  if index == "" then
    return
  end
  form.WuqiIndex = index
  ShaixuanShow(form)
end
function on_combobox_wuxue_selected(cbox)
  local form = cbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(cbox, "wuxue"))
  if index == "" then
    return
  end
  form.WuXueIndex = index
  ShaixuanShow(form)
end
function on_combobox_sanzhao_selected(cbox)
  local form = cbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(cbox, "sanzhao"))
  if index == "" then
    return
  end
  form.SanzhaoIndex = index
  ShaixuanShow(form)
end
function on_timer(form)
  if not nx_is_valid(form) then
    return
  end
  local cur_time = get_cur_time()
  local delay_time = form.Over_Time - cur_time
  form.lbl_4.Text = nx_widestr(delay_time)
  if delay_time < 1 then
    nx_log("delay_time  " .. nx_string(delay_time) .. "  " .. nx_string(form.Over_Time) .. "  " .. nx_string(form.Over_Time))
    SendBanxuanOper(form)
  end
end
function LoadBanxuanTaolu()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_BanSkill.ini")
  if not nx_is_valid(ini) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(bxtl_array_name) then
    return
  end
  if not common_array:FindArray(bxtl_sx_array_name) then
    return
  end
  local SectionCount = ini:GetSectionCount()
  for i = 0, SectionCount - 1 do
    local SectionItemCount = ini:GetSectionItemCount(i)
    for num = 0, SectionItemCount - 1 do
      local banxuan_taolu = ini:ReadString(i, nx_string(num), "")
      local table_date = util_split_string(banxuan_taolu, ",")
      if table.getn(table_date) == 2 and table_date[1] ~= "" then
        common_array:AddChild(bxtl_array_name, table_date[1], table_date[1])
        common_array:AddChild(bxtl_sx_array_name, table_date[1], table_date[2])
      end
    end
  end
end
function LoadShaixuan()
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\match\\match_revenge_ban.ini")
  if not nx_is_valid(ini) then
    return
  end
  local SectionCount = ini:GetSectionCount()
  for i = 0, SectionCount - 1 do
    local name_nodeid1 = ini:GetSectionByIndex(i)
    local SectionItemCount = ini:GetSectionItemCount(i)
    for num = 0, SectionItemCount - 1 do
      local saixuan_info = ini:ReadString(i, nx_string(num), "")
      local table_date = util_split_string(saixuan_info, ",")
      local table_count = table.getn(form_sx_table)
      form_sx_table[table_count + 1] = {
        name_nodeid1,
        table_date[1],
        table_date[2]
      }
    end
  end
end
function get_server_time()
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return 0
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local strdate = nx_function("format_date_time", nx_double(cur_date_time))
  local table_date = util_split_string(strdate, ";")
  if table.getn(table_date) ~= 2 then
    return 0
  end
  local table_time = util_split_string(table_date[2], ":")
  if table.getn(table_time) ~= 3 then
    return 0
  end
  return nx_number(table_time[1]), nx_number(table_time[2]), nx_number(table_time[3])
end
function get_cur_time()
  local hour, minute, second = get_server_time()
  local cur_time = nx_int(hour) * nx_int(3600) + nx_int(minute) * nx_int(60) + nx_int(second)
  return cur_time
end
function get_now_group_index(cbox, sx_type)
  local text = nx_widestr(cbox.DropListBox:GetString(cbox.DropListBox.SelectIndex))
  for i = 1, table.maxn(form_sx_table) do
    local table_type = nx_string(form_sx_table[i][1])
    local table_taolu = nx_string(form_sx_table[i][3])
    local _taolu = util_text(table_taolu)
    if text == _taolu and sx_type == table_type then
      return form_sx_table[i][2]
    end
  end
  return ""
end
function ShaixuanShow(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(bxtl_array_name) then
    return
  end
  if not common_array:FindArray(bxtl_sx_array_name) then
    return
  end
  local list = common_array:GetChildList(bxtl_array_name)
  if table.getn(list) < 1 then
    return
  end
  form.textgrid_1:BeginUpdate()
  form.textgrid_1:ClearRow()
  for i = 1, table.getn(list) do
    if nx_string(list[i]) ~= nx_string("") then
      local taolu_sx_type = common_array:FindChild(bxtl_sx_array_name, list[i])
      if taolu_sx_type ~= nil then
        local taolu_sx_type_value = nx_int(taolu_sx_type)
        local wuqi_index = math.floor(taolu_sx_type_value / 100)
        local wuxue_index = math.floor(math.fmod(tonumber(tostring(taolu_sx_type)), 100) / 10)
        local sanzhao_index = math.fmod(tonumber(tostring(taolu_sx_type)), 10)
        if (nx_int(form.WuqiIndex) == nx_int(0) and nx_int(form.WuqiIndex) < nx_int(wuqi_index) or nx_int(form.WuqiIndex) == nx_int(wuqi_index)) and (nx_int(form.WuXueIndex) == nx_int(0) and nx_int(form.WuXueIndex) < nx_int(wuxue_index) or nx_int(form.WuXueIndex) == nx_int(wuxue_index)) and (nx_int(form.SanzhaoIndex) == nx_int(0) and nx_int(form.SanzhaoIndex) < nx_int(sanzhao_index) or nx_int(form.SanzhaoIndex) == nx_int(sanzhao_index)) then
          local row = form.textgrid_1:InsertRow(-1)
          form.textgrid_1:SetGridText(row, 0, nx_widestr(util_text(list[i])))
          form.textgrid_1:SetGridText(row, 1, nx_widestr(list[i]))
        end
      end
    end
  end
  form.textgrid_1:EndUpdate()
end
function SetOverTime(...)
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("ui_msg_ban_ziji"))
  local wait_time = nx_int(arg[1])
  form.btn_1.Enabled = true
  form.btn_1.DataSource = nx_string("")
  form.lbl_26.Visible = true
  form.lbl_15.Visible = false
  local cur_time = get_cur_time()
  if cur_time > form.Over_Time then
    form.Over_Time = cur_time
  end
  form.Over_Time = form.Over_Time + wait_time
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "on_timer", form, -1, -1)
  end
end
function ShowBanTao(...)
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  local ban_taolu = nx_string(arg[1])
  local baner_name = nx_widestr(arg[2])
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local self_name = client_player:QueryProp("Name")
  local is_owner = false
  if self_name == baner_name then
    is_owner = true
  end
  if ban_taolu == "" then
    ban_taolu = "ui_banxuan_kong"
  end
  if is_owner then
    if form.lbl_13.Text ~= nx_widestr("") then
      form.lbl_14.Text = nx_widestr(util_text(ban_taolu))
      form.lbl_20.Visible = true
    else
      form.lbl_13.Text = nx_widestr(util_text(ban_taolu))
      form.lbl_19.Visible = true
    end
  elseif form.lbl_11.Text ~= nx_widestr("") then
    form.lbl_12.Text = nx_widestr(util_text(ban_taolu))
    form.lbl_18.Visible = true
  else
    form.lbl_11.Text = nx_widestr(util_text(ban_taolu))
    form.lbl_17.Visible = true
  end
  form.textgrid_1:BeginUpdate()
  local rows = form.textgrid_1.RowCount
  for r = rows - 1, 0, -1 do
    local grid_taolu_id = form.textgrid_1:GetGridText(r, 1)
    if ban_taolu == nx_string(grid_taolu_id) then
      form.textgrid_1:DeleteRow(r)
      break
    end
  end
  form.textgrid_1:EndUpdate()
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(bxtl_array_name) then
    return
  end
  common_array:RemoveChild(bxtl_array_name, ban_taolu)
end
function CustomMsgOper(submsg, oper_msg, ...)
  if CUSMSG_BAN_TAOLU_OPEN == oper_msg then
    open_form(unpack(arg))
  elseif CUSMSG_BAN_TAOLU_TIME == oper_msg then
    SetOverTime(unpack(arg))
  elseif CUSMSG_BAN_TAOLU_TAOLU == oper_msg then
    ShowBanTao(unpack(arg))
  end
end
function SendBanxuanOper(form)
  local taolu_id = form.btn_1.DataSource
  nx_execute("custom_sender", "custom_egwar_trans", 12, taolu_id)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_timer", form)
  end
  form.btn_1.Enabled = false
  form.lbl_26.Visible = false
  form.lbl_15.Visible = true
  form.lbl_4.Text = nx_widestr("")
end
function is_match_revenge(target)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local is_revenge = client_player:QueryProp("IsRevenge")
  if nx_int(is_revenge) == nx_int(1) then
    return true
  end
  return false
end
function close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
