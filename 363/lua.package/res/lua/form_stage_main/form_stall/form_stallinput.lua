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
  return 1
end
function main_form_close(self)
  return 1
end
function on_confirm_btn_click(self)
  local form = self.Parent
  local price_ding = nx_int64(form.ipt_price_ding.Text)
  local price_liang = nx_int64(form.ipt_price_liang.Text)
  local price_wen = nx_int64(form.ipt_price_wen.Text)
  local price = price_ding * 1000000 + price_liang * 1000 + price_wen
  if price < 1 then
    local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
    local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
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
      nx_gen_event(form, "stall_price_input_return", "ok", price, 0)
    else
      nx_gen_event(form, "stall_price_input_return", "ok", 0, price)
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
