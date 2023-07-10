require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_yb_ding
  move_position(self)
  return 1
end
function on_main_form_close(self)
  return 1
end
function on_confirm_btn_click(self)
  local form = self.Parent
  local price_yb_ding = nx_int64(form.ipt_yb_ding.Text)
  local price_yb_liang = nx_int64(form.ipt_yb_liang.Text)
  local price_yb_wen = nx_int64(form.ipt_yb_wen.Text)
  local price_yb = price_yb_ding * 1000000 + price_yb_liang * 1000 + price_yb_wen
  if price_yb < 1 then
    local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
    local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
      if form_sysinfo.info_group.Visible == true then
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_InputValidPrice"), 0, 0)
      else
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_InputValidPrice"), SYSTYPE_FIGHT, 0)
      end
    end
    return
  end
  local num = nx_int(form.ipt_number.Text)
  local totalNum = nx_int(form.lbl_total_num.Text)
  if num < nx_int(1) or num > totalNum then
    local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
    local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
      if form_sysinfo.info_group.Visible == true then
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_offline_form_error_num"), 0, 0)
      else
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_offline_form_error_num"), SYSTYPE_FIGHT, 0)
      end
    end
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = ""
  local form_main = util_get_form("form_stage_main\\form_stall\\form_stall_main", false, false)
  if not nx_is_valid(form_main) then
    return
  end
  if form_main.rbtn_chushou.Checked == true then
    text = nx_widestr(gui.TextManager:GetFormatText("ui_offline_form_sell_inputbox_title01", nx_int(price_yb_ding), nx_int(price_yb_liang), nx_int(price_yb_wen)))
  elseif form_main.rbtn_shougou.Checked == true then
    text = nx_widestr(gui.TextManager:GetFormatText("ui_offline_form_sell_inputbox_title02", nx_int(price_yb_ding), nx_int(price_yb_liang), nx_int(price_yb_wen)))
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  form:Close()
  nx_gen_event(form, "sell_stall_price_input_return", "ok", price_yb, num)
  nx_destroy(form)
  return 1
end
function on_cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "sell_stall_price_input_return", "cancel")
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  nx_gen_event(form, "sell_stall_price_input_return", "cancel")
  nx_destroy(form)
  return 1
end
function move_position(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  form.ipt_yb_ding.Text = nx_widestr("0")
  form.ipt_yb_liang.Text = nx_widestr("0")
  form.ipt_yb_wen.Text = nx_widestr("0")
end
function on_ipt_number_changed(self)
  local form = self.ParentForm
  local total_num = nx_int(form.lbl_total_num.Text)
  local count = nx_int(self.Text)
  if total_num < count then
    self.Text = nx_widestr(total_num)
  end
  if count < nx_int(1) then
    self.Text = nx_widestr(1)
  end
  show_total_price(form)
  del_first_value(self)
end
function del_first_value(self)
  local len = string.len(nx_string(self.Text))
  if nx_int(len) > nx_int(1) then
    local first = string.sub(nx_string(self.Text), 1, 1)
    if first == "0" then
      self.Text = nx_widestr(nx_int(self.Text))
      self.InputPos = string.len(nx_string(self.Text))
    end
  end
end
function on_ipt_yb_ding_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_total_price(form)
  del_first_value(self)
end
function on_ipt_yb_liang_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_total_price(form)
  del_first_value(self)
end
function on_ipt_yb_wen_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_total_price(form)
  del_first_value(self)
end
function show_total_price(form)
  if not nx_is_valid(form) then
    return
  end
  local item_num = nx_int(form.ipt_number.Text)
  local price_yb_ding = nx_int64(form.ipt_yb_ding.Text)
  local price_yb_liang = nx_int64(form.ipt_yb_liang.Text)
  local price_yb_wen = nx_int64(form.ipt_yb_wen.Text)
  local price_yb = price_yb_ding * 1000000 + price_yb_liang * 1000 + price_yb_wen
  local tatal_price = item_num * price_yb
  local ding = math.floor(tatal_price / 1000000)
  local liang = math.floor(tatal_price % 1000000 / 1000)
  local wen = math.floor(tatal_price % 1000)
  form.lbl_tatal_ding.Text = nx_widestr(ding)
  form.lbl_tatal_liang.Text = nx_widestr(liang)
  form.lbl_tatal_wen.Text = nx_widestr(wen)
end
