require("utils")
require("util_gui")
require("util_functions")
local FACULTY_ONE = 300000
local FACULTY_TWO = 1000000
local FACULTY_THREE = 3000000
local FACULTY_FOUR = 5000000
local FACULTY_FIVE = 7500000
local FACULTY_SIX = 10000000
local MYRIAD = 10000
local CLIENT_SUB_BUY_FACULTY = 4
local CLIENT_SUB_NEIGONG_STEP = 5
local CAPITAL_TYPE_GOLDEN = 0
function main_form_init(form)
  form.Fixed = false
  form.step = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurMaxFaculty", "int", form, nx_current(), "prop_callback_refresh")
  end
  nx_execute("custom_sender", "custom_buy_faculty", CLIENT_SUB_NEIGONG_STEP, nx_int(0), nx_int(0))
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("Faculty", form)
  databinder:DelRolePropertyBind("CurMaxFaculty", form)
  databinder:DelViewBind(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_exchange_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local cost_gold = 0
  local buy_faculty = 0
  if form.cbtn_one.Checked == true then
    buy_faculty = form.lbl_faculty_1.Text
    cost_gold = form.lbl_money_1.Text
  elseif form.cbtn_two.Checked == true then
    buy_faculty = form.lbl_faculty_2.Text
    cost_gold = form.lbl_money_2.Text
  elseif form.cbtn_three.Checked == true then
    buy_faculty = form.lbl_faculty_3.Text
    cost_gold = form.lbl_money_3.Text
  elseif form.cbtn_four.Checked == true then
    buy_faculty = form.lbl_faculty_4.Text
    cost_gold = form.lbl_money_4.Text
  elseif form.cbtn_five.Checked == true then
    buy_faculty = form.lbl_faculty_5.Text
    cost_gold = form.lbl_money_5.Text
  elseif form.cbtn_six.Checked == true then
    buy_faculty = form.lbl_faculty_6.Text
    cost_gold = form.lbl_money_6.Text
  else
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("8082"), 2)
    end
    return
  end
  exchange_dialog(cost_gold, buy_faculty)
end
function on_cbtn_one_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_one.Checked == true then
    form.cbtn_two.Checked = false
    form.cbtn_three.Checked = false
    form.cbtn_four.Checked = false
    form.cbtn_five.Checked = false
    form.cbtn_six.Checked = false
  end
end
function on_cbtn_two_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_two.Checked == true then
    form.cbtn_one.Checked = false
    form.cbtn_three.Checked = false
    form.cbtn_four.Checked = false
    form.cbtn_five.Checked = false
    form.cbtn_six.Checked = false
  end
end
function on_cbtn_three_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_three.Checked == true then
    form.cbtn_one.Checked = false
    form.cbtn_two.Checked = false
    form.cbtn_four.Checked = false
    form.cbtn_five.Checked = false
    form.cbtn_six.Checked = false
  end
end
function on_cbtn_four_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_four.Checked == true then
    form.cbtn_one.Checked = false
    form.cbtn_two.Checked = false
    form.cbtn_three.Checked = false
    form.cbtn_five.Checked = false
    form.cbtn_six.Checked = false
  end
end
function on_cbtn_five_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_five.Checked == true then
    form.cbtn_one.Checked = false
    form.cbtn_two.Checked = false
    form.cbtn_three.Checked = false
    form.cbtn_four.Checked = false
    form.cbtn_six.Checked = false
  end
end
function on_cbtn_six_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_six.Checked == true then
    form.cbtn_one.Checked = false
    form.cbtn_two.Checked = false
    form.cbtn_three.Checked = false
    form.cbtn_four.Checked = false
    form.cbtn_five.Checked = false
  end
end
function on_btn_click_one_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_one.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange1_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange1_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_one_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_btn_click_two_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_two.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange2_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange2_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_two_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_btn_click_three_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_three.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange3_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange3_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_three_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_btn_click_four_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_four.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange4_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange4_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_four_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_btn_click_five_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_five.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange5_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange5_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_five_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_btn_click_six_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.cbtn_six.Enabled == true then
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange6_tips")), self.AbsLeft, self.AbsTop, 0, self)
  else
    nx_execute("tips_game", "show_text_tip", nx_widestr(util_text("ui_faculty_exchange6_null")), self.AbsLeft, self.AbsTop, 0, self)
  end
end
function on_btn_click_six_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self)
end
function on_msg(arg1)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local form = util_get_form("form_stage_main\\form_wuxue\\form_faculty_exchange", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.step = nx_int(arg1)
  local max_faculty = client_player:QueryProp("CurMaxFaculty")
  if nx_int(max_faculty) >= nx_int(FACULTY_FOUR) and nx_int(arg1) >= nx_int(1) then
    form.cbtn_four.Enabled = true
    form.groupbox_4.BlendColor = "255,255,255,255"
  end
  if nx_int(max_faculty) >= nx_int(FACULTY_FIVE) and nx_int(arg1) >= nx_int(2) then
    form.cbtn_five.Enabled = true
    form.groupbox_5.BlendColor = "255,255,255,255"
  end
  if nx_int(max_faculty) >= nx_int(FACULTY_SIX) and nx_int(arg1) >= nx_int(4) then
    form.cbtn_six.Enabled = true
    form.groupbox_6.BlendColor = "255,255,255,255"
  end
  local full_faculty = 0
  if nx_int(max_faculty) >= nx_int(FACULTY_FOUR) then
    full_faculty = nx_int(500)
  end
  if nx_int(max_faculty) >= nx_int(FACULTY_FIVE) then
    full_faculty = nx_int(750)
  end
  if nx_int(max_faculty) >= nx_int(FACULTY_SIX) then
    full_faculty = nx_int(1000)
  end
  if nx_int(full_faculty) > nx_int(0) then
    form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_faculty_exchange_07", nx_int(full_faculty)))
  end
end
function prop_callback_refresh(form, PropName, PropType, Value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  set_control(form)
  local max_faculty = client_player:QueryProp("CurMaxFaculty")
  if nx_int(max_faculty) >= nx_int(FACULTY_ONE) and nx_int(max_faculty) < nx_int(FACULTY_TWO) then
    form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_faculty_exchange_07", nx_int(FACULTY_ONE / MYRIAD)))
    form.cbtn_one.Enabled = true
    form.cbtn_two.Enabled = false
    form.cbtn_three.Enabled = false
    form.cbtn_four.Enabled = false
    form.cbtn_five.Enabled = false
    form.cbtn_six.Enabled = false
    form.groupbox_1.BlendColor = "255,255,255,255"
    form.groupbox_2.BlendColor = "255,0,0,0"
    form.groupbox_3.BlendColor = "255,0,0,0"
    form.groupbox_4.BlendColor = "255,0,0,0"
    form.groupbox_5.BlendColor = "255,0,0,0"
    form.groupbox_6.BlendColor = "255,0,0,0"
  elseif nx_int(max_faculty) >= nx_int(FACULTY_TWO) and nx_int(max_faculty) < nx_int(FACULTY_THREE) then
    form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_faculty_exchange_07", nx_int(FACULTY_TWO / MYRIAD)))
    form.cbtn_one.Enabled = true
    form.cbtn_two.Enabled = true
    form.cbtn_three.Enabled = false
    form.cbtn_four.Enabled = false
    form.cbtn_five.Enabled = false
    form.cbtn_six.Enabled = false
    form.groupbox_1.BlendColor = "255,255,255,255"
    form.groupbox_2.BlendColor = "255,255,255,255"
    form.groupbox_3.BlendColor = "255,0,0,0"
    form.groupbox_4.BlendColor = "255,0,0,0"
    form.groupbox_5.BlendColor = "255,0,0,0"
    form.groupbox_6.BlendColor = "255,0,0,0"
  elseif nx_int(max_faculty) >= nx_int(FACULTY_THREE) then
    form.mltbox_text.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_faculty_exchange_07", nx_int(FACULTY_THREE / MYRIAD)))
    form.cbtn_one.Enabled = true
    form.cbtn_two.Enabled = true
    form.cbtn_three.Enabled = true
    form.cbtn_four.Enabled = false
    form.cbtn_five.Enabled = false
    form.cbtn_six.Enabled = false
    form.groupbox_1.BlendColor = "255,255,255,255"
    form.groupbox_2.BlendColor = "255,255,255,255"
    form.groupbox_3.BlendColor = "255,255,255,255"
    form.groupbox_4.BlendColor = "255,0,0,0"
    form.groupbox_5.BlendColor = "255,0,0,0"
    form.groupbox_6.BlendColor = "255,0,0,0"
  else
    form.cbtn_one.Enabled = false
    form.cbtn_two.Enabled = false
    form.cbtn_three.Enabled = false
    form.cbtn_four.Enabled = false
    form.cbtn_five.Enabled = false
    form.cbtn_six.Enabled = false
    form.groupbox_1.BlendColor = "255,0,0,0"
    form.groupbox_2.BlendColor = "255,0,0,0"
    form.groupbox_3.BlendColor = "255,0,0,0"
    form.groupbox_4.BlendColor = "255,0,0,0"
    form.groupbox_5.BlendColor = "255,0,0,0"
    form.groupbox_6.BlendColor = "255,0,0,0"
  end
  on_msg(nx_int(form.step))
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local capital = manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, capital)
  form.mltbox_gold.HtmlText = txt
end
function set_control(form)
  if not nx_is_valid(form) then
    return
  end
  local buy_faculty_ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\BuyFaculty.ini")
  if not nx_is_valid(buy_faculty_ini) then
    return
  end
  local index = buy_faculty_ini:GetSectionCount()
  for i = 0, index - 1 do
    local sec_value = buy_faculty_ini:GetSectionByIndex(i)
    local key_value = buy_faculty_ini:ReadString(i, "faculty", "")
    local groupbox = form:Find("groupbox_" .. nx_string(nx_int(i + 1)))
    if not nx_is_valid(groupbox) then
      return
    end
    local lbl_faculty = groupbox:Find("lbl_faculty_" .. nx_string(nx_int(i + 1)))
    local lbl_money = groupbox:Find("lbl_money_" .. nx_string(nx_int(i + 1)))
    if not nx_is_valid(lbl_faculty) or not nx_is_valid(lbl_money) then
      return
    end
    lbl_faculty.Text = nx_widestr(nx_int(key_value) / nx_int(MYRIAD))
    lbl_money.Text = nx_widestr(sec_value)
  end
end
function exchange_dialog(money, faculty)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_faculty_exchange_confirm", nx_int(money), nx_int(faculty)))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    faculty = nx_int(faculty) * nx_int(MYRIAD)
    nx_execute("custom_sender", "custom_buy_faculty", CLIENT_SUB_BUY_FACULTY, nx_int(money), nx_int(faculty))
  end
end
