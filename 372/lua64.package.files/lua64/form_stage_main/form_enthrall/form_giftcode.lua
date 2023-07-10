require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function on_main_form_init(self)
  self.Fixed = false
  self.card_type = ""
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local code = nx_string(form.ipt_code.Text)
  local count = string.len(nx_string(code))
  if nx_int(count) ~= nx_int(8) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_giftcode_input_failed")
    return
  end
  if check_new_code(code) then
    local mgr = nx_value("UnenthrallModule")
    if not nx_is_valid(mgr) then
      mgr = nx_create("UnenthrallModule")
      nx_set_value("UnenthrallModule", mgr)
    end
    local ret_tab = mgr:NewCardCodeConfirm(form.account, form.server, form.ipt_code.Text)
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if not nx_is_valid(SystemCenterInfo) then
      return
    end
    local ret = ret_tab[1]
    if nx_int(ret) == nx_int(1) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000010"), 2)
      form:Close()
    elseif nx_int(ret) == nx_int(13101) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_not_exsit_account"), 2)
    elseif nx_int(ret) == nx_int(52009) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000068"), 2)
    elseif nx_int(ret) == nx_int(11113) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000068"), 2)
    elseif nx_int(ret) == nx_int(30112) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000069"), 2)
    elseif nx_int(ret) == nx_int(30102) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000070"), 2)
    elseif nx_int(ret) == nx_int(40102) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000071"), 2)
    elseif nx_int(ret) == nx_int(40103) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000071"), 2)
    elseif nx_int(ret) == nx_int(10009) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000072"), 2)
    elseif nx_int(ret) == nx_int(11102) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("1000073"), 2)
    else
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_cardcode_failed"), 2)
    end
    return
  end
  form.card_type = "C"
  local base = 20120000
  for i = 1, 100 do
    local temp = base + i
    if nx_string(code) == nx_string(temp) then
      form.card_type = "B"
      break
    end
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GIFT_COMFIRM), nx_string(form.ipt_code.Text), nx_string(form.card_type))
  form:Close()
end
function check_new_code(code)
  if nx_string(code) == "9yin2012" then
    return false
  end
  if nx_string(code) == "20120808" then
    return false
  end
  local base = 20120000
  for i = 1, 200 do
    local temp = base + i
    if nx_string(code) == nx_string(temp) then
      return false
    end
  end
  return true
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(...)
  local account = arg[1]
  local address = arg[2]
  local server = arg[3]
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_enthrall\\form_giftcode", true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.mltbox_2.Visible = false
  form.mltbox_1.Visible = true
  form.account = nx_widestr(account)
  form.address = nx_widestr(address)
  form.server = nx_widestr(server)
end
