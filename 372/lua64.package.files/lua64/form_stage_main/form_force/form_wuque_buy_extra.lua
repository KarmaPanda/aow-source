require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\client_custom_define")
require("custom_sender")
require("tips_data")
local FORM_NAME = "form_stage_main\\form_force\\form_wuque_buy_extra"
local FORM_MAP_NAME = "form_stage_main\\form_main\\form_main_map"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.price = 5000000
  load_ini(form)
  form.imagegrid_1.item_id = "yihua_wuque_004"
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", form.imagegrid_1.item_id, "Photo")
  form.imagegrid_1:AddItem(0, nx_string(photo), nx_widestr(form.imagegrid_1.item_id), nx_int(item_count), 0)
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, FORM_NAME, "on_captial2_changed")
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_form_time", form, -1, -1)
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_form_time", form)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_update_form_time(form)
  form.left_time = form.left_time - 1
  local minute = math.floor(nx_number(form.left_time) / 60)
  local second = math.floor(nx_number(form.left_time) % 60)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_wuque_buy_001", nx_int(minute), nx_int(second)))
  form.lbl_left_time.Text = text
  local form_map = util_get_form(FORM_MAP_NAME, false, false)
  if nx_is_valid(form_map) then
    form_map.lbl_wuque_buy.Text = nx_widestr(string.format("%02d:%02d", nx_number(minute), nx_number(second)))
  end
  if form.left_time <= 0 then
    close_form()
  end
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
  else
    form.Visible = true
  end
end
function open_form(...)
  local nums = nx_int(arg[2])
  local left_time = nx_number(arg[3])
  local form = util_get_form(FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local form_map = util_get_form(FORM_MAP_NAME, false, false)
  if nx_is_valid(form_map) then
    form_map.btn_wuque_buy.Visible = true
    form_map.lbl_wuque_buy.Visible = true
  end
  form.lbl_nums.Text = nx_widestr(nums)
  form.left_time = left_time
  local minute = math.floor(form.left_time / 60)
  local second = math.floor(form.left_time % 60)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_wuque_buy_001", nx_int(minute), nx_int(second)))
  form.lbl_left_time.Text = text
  local form_map = util_get_form(FORM_MAP_NAME, false, false)
  if nx_is_valid(form_map) then
    form_map.lbl_wuque_buy.Text = nx_widestr(string.format("%02d:%02d", nx_number(minute), nx_number(second)))
  end
  form.ipt_buy.MaxDigit = nums
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local form_map = util_get_form(FORM_MAP_NAME, false, false)
  if nx_is_valid(form_map) then
    form_map.btn_wuque_buy.Visible = false
    form_map.lbl_wuque_buy.Visible = false
  end
end
function on_btn_close_click(btn)
  open_or_hide()
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if nx_number(form.ipt_buy.Text) <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_wuque_buy_extra_006"))
    return
  end
  local nums = nx_int(form.ipt_buy.Text)
  local price = nums * nx_int(form.price)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_wuque_buy_confirm", nx_int(price), nx_int(nums))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_send_hwq_choice(nx_int(4), nums, price)
  end
end
function on_imagegrid_1_mousein_grid(self, index)
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.is_static = true
    item.ConfigID = nx_string(self.item_id)
    item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(self.item_id), "ItemType", "0")
    nx_execute("tips_game", "show_goods_tip", item, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 40, 40, self.ParentForm)
  end
end
function on_imagegrid_1_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_ipt_buy_changed(ipt)
  local form = ipt.ParentForm
  local nums = nx_number(ipt.Text)
  local price_total = nums * nx_number(form.price)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType2")
  local add_color = price_total > capital
  local ding1 = math.floor(price_total / 1000000)
  local liang1 = math.floor(price_total % 1000000 / 1000)
  local wen1 = math.floor(price_total % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  form.mltbox_price_total.HtmlText = util_text("ui_wuque_buy_total") .. htmlTextYinKa
  if add_color then
    form.btn_buy.Enabled = false
  else
    form.btn_buy.Enabled = true
  end
end
function on_captial2_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital1 = client_player:QueryProp("CapitalType2")
  local ding1 = math.floor(capital1 / 1000000)
  local liang1 = math.floor(capital1 % 1000000 / 1000)
  local wen1 = math.floor(capital1 % 1000)
  local CapitalModule = nx_value("CapitalModule")
  if not nx_is_valid(CapitalModule) then
    return
  end
  local add_color = capital1 > CapitalModule:GetMaxValue(2)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      ding1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(ding1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      liang1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(liang1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    if add_color then
      wen1 = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(nx_int(wen1)) .. nx_widestr("</font>")
    end
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  if capital1 == 0 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr("0") .. nx_widestr(htmlText)
  end
  form.mltbox_yinka.HtmlText = util_text("ui_wuque_buy_own") .. htmlTextYinKa
end
function load_ini(form)
  local ini = get_ini("share\\Force\\yihua_huawuque.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string("HWQ_CONFIG"))
  if sec_index < 0 then
    return false
  end
  form.price = ini:ReadInteger(sec_index, "BuyExtraPrice", 0)
  local ding1 = math.floor(form.price / 1000000)
  local liang1 = math.floor(form.price % 1000000 / 1000)
  local wen1 = math.floor(form.price % 1000)
  local gui = nx_value("gui")
  local htmlTextYinKa = nx_widestr("")
  if 0 < ding1 then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(ding1) .. nx_widestr(htmlText)
  end
  if 0 < liang1 then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(liang1) .. nx_widestr(htmlText)
  end
  if 0 < wen1 then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr("<font color=\"#B1B1B1\">") .. nx_widestr(text) .. nx_widestr("</font>")
    htmlTextYinKa = htmlTextYinKa .. nx_widestr(" ") .. nx_widestr(wen1) .. nx_widestr(htmlText)
  end
  form.mltbox_price.HtmlText = util_text("ui_wuque_buy_price") .. htmlTextYinKa
  return true
end
