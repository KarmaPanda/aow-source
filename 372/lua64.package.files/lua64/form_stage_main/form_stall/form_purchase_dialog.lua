require("util_gui")
require("util_functions")
require("define\\sysinfo_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  gui.Focused = self.ipt_price_ding
  self.rbtn_gold.Visible = false
  self.rbtn_silver.Visible = false
  self.lbl_5.Visible = false
  self.lbl_6.Visible = false
  return 1
end
function main_form_close(self)
  return 1
end
function on_confirm_btn_click(self)
  local form = self.Parent
  local count = nx_int(form.ipt_count.Text)
  local price_ding = nx_int64(form.ipt_price_ding.Text)
  local price_liang = nx_int64(form.ipt_price_liang.Text)
  local price_wen = nx_int64(form.ipt_price_wen.Text)
  local price = price_ding * 10000 + price_liang * 100 + price_wen
  local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  if count < nx_int(1) then
    if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
      if form_sysinfo.info_group.Visible == true then
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_ItemNumberInputError"), 0, 0)
      else
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_ItemNumberInputError"), SYSTYPE_FIGHT, 0)
      end
    end
    return
  end
  if price < 1 then
    if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
      if form_sysinfo.info_group.Visible == true then
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_InputValidPrice"), 0, 0)
      else
        form_main_sysinfo_logic:AddSystemInfo(util_text("ui_InputValidPrice"), SYSTYPE_FIGHT, 0)
      end
    end
  else
    form:Close()
    if form.rbtn_gold.Checked == true then
      nx_gen_event(form, "purchase_price_input_return", "ok", price, 0, count)
    else
      nx_gen_event(form, "purchase_price_input_return", "ok", 0, price, count)
    end
    nx_destroy(form)
  end
  return 1
end
function on_cancel_btn_click(self)
  local form = self.Parent
  form:Close()
  nx_gen_event(form, "stall_price_input_return", "cancel")
  nx_destroy(form)
  return 1
end
function on_rbtn_gold_checked_changed(self)
  local root = self.Parent.Parent
  clear_price_about(root)
  if self.Checked == true then
    root.lbl_silver_mark.Visible = false
    root.lbl_gold_mark.Visible = true
  else
    root.lbl_silver_mark.Visible = true
    root.lbl_gold_mark.Visible = false
  end
end
function on_rbtn_silver_checked_changed(self)
  clear_price_about(self.Parent.Parent)
end
function clear_price_about(root)
  root.ipt_price_ding.Text = nx_widestr(0)
  root.ipt_price_liang.Text = nx_widestr(0)
  root.ipt_price_wen.Text = nx_widestr(0)
end
function check_number(num)
  num = nx_string(num)
  if string.find(num, "-") ~= nil then
    return false
  end
  if string.sub(num, 1, 1) == "0" and 1 < string.len(num) then
    return false
  end
  return true
end
function on_ipt_price_ding_changed(self)
  if not check_number(self.Text) then
    self.Text = nx_widestr(0)
  end
end
function on_ipt_price_liang_changed(self)
  if not check_number(self.Text) then
    self.Text = nx_widestr(0)
  end
end
function on_ipt_price_wen_changed(self)
  if not check_number(self.Text) then
    self.Text = nx_widestr(0)
  end
end
function on_ipt_count_changed(self)
  if not check_number(self.Text) then
    self.Text = nx_widestr(0)
  end
end
