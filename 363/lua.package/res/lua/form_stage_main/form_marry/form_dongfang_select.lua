require("util_gui")
require("util_functions")
local CLIENT_SUB_CHOOSE_ACTION = 10
local close_time = 15
local DONGFANG_ACT_INI = "share\\InterActive\\DongFang\\dongfang_act.ini"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  util_show_form("form_stage_main\\form_marry\\form_dongfang_info", false)
  close_time = 15
  form.lbl_close_time.Text = nx_widestr(close_time)
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_close_window", form, -1, -1)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_main_form_shut(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_close_window", self)
  end
end
function on_btn_item_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local room_id = client_player:QueryProp("DongFangNum")
  if nx_int(room_id) <= nx_int(0) then
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("55511"), 2)
    end
    return
  end
  local ini = nx_execute("util_functions", "get_ini", DONGFANG_ACT_INI)
  if not nx_is_valid(ini) then
    return
  end
  local item = ini:GetSectionByIndex(nx_int(self.DataSource))
  if nx_string(item) ~= "" or item ~= nil then
    nx_execute("custom_sender", "custom_dongfang_msg", CLIENT_SUB_CHOOSE_ACTION, nx_string(item))
    form:Close()
  end
end
function on_close_window(form)
  close_time = close_time - 1
  if not nx_is_valid(form) then
    return
  end
  form.lbl_close_time.Text = nx_widestr(close_time)
  if nx_int(close_time) <= nx_int(0) then
    form:Close()
  end
end
function refresh_btn_enabled(man_bodytype, woman_bodytype)
  local form = nx_value("form_stage_main\\form_marry\\form_dongfang_select")
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", DONGFANG_ACT_INI)
  if not nx_is_valid(ini) then
    return 0
  end
  for i = 0, 3 do
    local bodytype_same = ini:ReadInteger(i, "bodytype_same", 0)
    if nx_number(bodytype_same) == 1 and man_bodytype ~= woman_bodytype then
      local btn_item = form:Find("btn_item_" .. nx_string(i))
      if nx_is_valid(btn_item) then
        btn_item.Enabled = false
      end
    end
  end
end
