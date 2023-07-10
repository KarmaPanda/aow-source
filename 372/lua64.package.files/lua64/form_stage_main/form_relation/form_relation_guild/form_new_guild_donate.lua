require("util_gui")
require("game_object")
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  gui.Focused = self.ipt_price_ding
  return 1
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
  return 1
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, "contribute_return", "cancel")
  form:Close()
end
function on_btn_confirm_click(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local establish_num = nx_int64(form.ipt_price_ding.Text)
  if nx_int64(establish_num) <= nx_int64(0) then
    return
  end
  if nx_int64(form.left_establish) < nx_int64(establish_num) then
    local text = gui.TextManager:GetText("ui_newguild_money_tips_4")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  if nx_int64(form.max_value) < nx_int64(establish_num) then
    local text = gui.TextManager:GetText("ui_newguild_money_tips_3")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  nx_gen_event(form, "contribute_return", "ok", establish_num)
  form:Close()
end
