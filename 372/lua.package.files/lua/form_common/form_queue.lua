require("util_gui")
require("utils")
require("tips_game")
require("form_stage_main\\switch\\url_define")
function main_form_init(self)
  self.Fixed = false
  self.on_queue = false
  self.vip = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.web_view.Visible = false
  local left = self.web_view.Left
  local top = self.web_view.Top
  self.web_view.Left = 0
  self.web_view.Top = 0
  self.web_view.Left = left
  self.web_view.Top = top
  self.mltbox_tips_desc.Visible = false
  local info = nx_widestr(gui.TextManager:GetFormatText("tips_queue_vip"))
  self.mltbox_tips_desc:AddHtmlText(info, -1)
  self.Default = self.cancel_btn
  local sock = nx_value("game_sock")
  nx_gen_event(sock.Receiver, "event_login", "queue", 0)
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and 3 == game_config.server_sdo then
    self.btn_6.Visible = false
  end
end
function on_main_form_close(self)
  self.web_view:Disable()
  nx_destroy(self)
  nx_set_value(nx_current(), nil)
end
function refresh(vip, number, vipnum)
  local form = util_get_form(nx_current(), true)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 1
  end
  if number == 0 then
    nx_gen_event(form, nx_current(), "succeed")
    form:Close()
    return
  end
  if not form.btn_vip.Visible then
    return
  end
  form.vip = vip
  local info = nx_widestr("")
  if vip == 0 then
    form.lbl_1.Visible = true
    form.lbl_vip.Visible = false
    info = nx_widestr(gui.TextManager:GetFormatText("ui_queue_vip_sit", nx_int(vipnum)))
    form.lbl_tips.Visible = true
  else
    form.lbl_1.Visible = false
    form.lbl_vip.Visible = true
  end
  form.mltbox_info:Clear()
  local game_config = nx_value("game_config")
  if nx_find_property(game_config, "server_name") then
    local info = gui.TextManager:GetText("ui_queue_server") .. nx_widestr(game_config.server_name)
    form.mltbox_info:AddHtmlText(info, -1)
  end
  local desc = gui.TextManager:GetText("ui_queue_sit") .. nx_widestr(number)
  form.mltbox_info:AddHtmlText(desc, -1)
  form.lbl_tips.Text = desc
  local w = form.lbl_tips.TextWidth
  form.lbl_tips.Left = w + form.mltbox_info.Left
  form.lbl_tips.Text = info
  form.lbl_tips.Width = form.lbl_tips.TextWidth
  local second = GetWaitTime(number, form)
  form.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_queue_time")) .. nx_widestr(TimeToString(gui.TextManager, second)), -1)
  form.Visible = true
  form.on_queue = true
  local dialog = util_get_form("form_common\\form_confirm", false)
  if not nx_is_valid(dialog) then
    form:ShowModal()
  end
end
function cancel_btn_click(self)
  local gui = nx_value("gui")
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(gui.TextManager:GetText("ui_queue_exit"), -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  dialog:Close()
  gui:Delete(dialog)
  local form = self.ParentForm
  nx_gen_event(form, nx_current(), "failed")
  nx_execute("form_stage_login\\form_login", "set_login_enabled")
  form:Close()
end
function resize()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function GetWaitTime(number, form)
  local default = 60
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return default * number
  end
  local ini = IniManager:LoadIniToManager("ini\\queue.ini")
  if not nx_is_valid(ini) then
    return default * number
  end
  local sec_index = ini:FindSectionIndex("times")
  if sec_index == -1 then
    return default * number
  end
  local item_index = ini:FindSectionItemIndex(sec_index, "-1")
  if item_index == -1 then
    return default * number
  end
  default = ini:ReadInteger(sec_index, "-1", 60)
  local items = ini:GetSectionItemCount(sec_index) - 1
  local time_table = {}
  for i = 0, items do
    if i ~= item_index then
      time_table[i + 1] = {}
      time_table[i + 1].key = nx_int(ini:GetSectionItemKey(sec_index, i))
      time_table[i + 1].value = nx_int(ini:GetSectionItemValue(sec_index, i))
    end
  end
  table.sort(time_table, function(a, b)
    if a == nil then
      return true
    end
    if b == nil then
      return false
    end
    return nx_int(a.key) < nx_int(b.key)
  end)
  for i, v in pairs(time_table) do
    if nx_int(number) <= nx_int(v.key) then
      return nx_int(number) * nx_int(v.value)
    end
  end
  return default * number
end
function TimeToString(txt, second)
  local max_hour = 5
  local min_minutes = 1
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    local ini = IniManager:LoadIniToManager("ini\\queue.ini")
    if nx_is_valid(ini) then
      local sec_index = ini:FindSectionIndex("critical")
      if sec_index ~= -1 then
        local item_max = ini:FindSectionItemIndex(sec_index, "max")
        if item_max ~= -1 then
          max_hour = nx_int(ini:GetSectionItemValue(sec_index, item_max))
        end
        local item_min = ini:FindSectionItemIndex(sec_index, "min")
        if item_min ~= -1 then
          min_minutes = nx_int(ini:GetSectionItemValue(sec_index, item_min))
        end
      end
    end
  end
  if nx_int(second) < nx_int(min_minutes * 60) then
    return nx_widestr(txt:GetFormatText("ui_queue_lessminute", nx_int(min_minutes)))
  end
  if nx_int(second) > nx_int(max_hour * 3600) then
    return nx_widestr(txt:GetFormatText("ui_queue_morehour", nx_int(max_hour)))
  end
  local hour = nx_int(second / 3600)
  local minite = nx_int((second - hour * 3600) / 60)
  if hour == nx_int(0) then
    return nx_widestr(minite) .. nx_widestr(txt:GetText("ui_fengzhong"))
  else
    return nx_widestr(hour) .. nx_widestr(txt:GetText("ui_g_hours")) .. nx_widestr(minite) .. nx_widestr(txt:GetText("ui_fengzhong"))
  end
end
function on_btn_vip_click(self)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_authority_btn_click(self)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_9YIN_BBS)
  end
end
function on_authority_btn_get_capture(self)
  self.ForeColor = "255,255,0,0"
end
function on_authority_btn_lost_capture(self)
  self.ForeColor = "255,255,255,255"
end
function on_btn_6_click(self)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.web_view.Visible = true
end
function on_btn_6_get_capture(self)
  self.ForeColor = "255,255,0,0"
end
function on_btn_6_lost_capture(self)
  self.ForeColor = "255,255,255,255"
end
function on_lbl_tips_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local mouse_x, mouse_z = gui:GetCursorPosition()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_tips_desc.Left = mouse_x - form.Left + 40
  form.mltbox_tips_desc.Top = mouse_z - form.Top + 10
  form.mltbox_tips_desc.Visible = true
end
function on_lbl_tips_lost_capture(self)
  local form = self.ParentForm
  form.mltbox_tips_desc.Visible = false
end
function change_form_size(form)
  form.web_view.Left = 0
  form.web_view.Top = 0
  form.web_view.Visible = false
  form.web_view.Left = left
  form.web_view.Top = top
end
function web_close_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) and form.Visible then
    form.web_view.Visible = false
  else
    nx_execute("form_stage_main\\form_main\\form_main", "web_close_form")
  end
end
