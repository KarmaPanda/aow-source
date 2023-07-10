require("form_stage_main\\form_huashan\\form_gamble_main_msg")
require("util_functions")
require("util_gui")
local m_Path = "form_stage_main\\form_huashan\\form_gamble_buy"
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
  form.projectid = ""
  form.playername = nx_widestr("")
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CapitalType2", "int", form, m_Path, "on_captial2_changed")
  end
  form.mltbox_note.buymoney = nx_int64(0)
  form.mltbox_note.Visible = false
  form.groupbox_input.Visible = true
  on_captial2_changed(form, "CapitalType2", "string", 0)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("CapitalType2", form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, form.projectid, "close")
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_gen_event(form, form.projectid, "cancel")
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.mltbox_note.Visible then
    nx_gen_event(form, form.projectid, "ok", form.mltbox_note.buymoney)
    form:Close()
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local nobind_money = nx_int64(client_player:QueryProp("CapitalType2"))
  local money = nx_int64(form.ipt_d.Text) * 1000000 + nx_int64(form.ipt_l.Text) * 1000 + nx_int64(form.ipt_w.Text)
  if money <= 0 or nobind_money < nx_int64(money) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(1000134))), 2)
    end
    return
  end
  form.mltbox_note.buymoney = money
  form.mltbox_note.Visible = true
  form.groupbox_input.Visible = false
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_huashan_yazhu_24")
  gui.TextManager:Format_AddParam(nx_int64(money))
  form.mltbox_note.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
end
function open_form(projectid, playername, school, guild, powerlevel)
  if projectid == nil or nx_string(projectid) == "" then
    return nx_null()
  end
  local form = nx_value(m_Path)
  if nx_is_valid(form) then
    form:Close()
  end
  form = util_get_form(m_Path, true)
  if not nx_is_valid(form) then
    return nx_null()
  end
  form:Show()
  form.Visible = true
  form.mltbox_msg:AddHtmlText(nx_widestr(playername), -1)
  form.mltbox_msg:AddHtmlText(nx_widestr(school), -1)
  form.mltbox_msg:AddHtmlText(nx_widestr(guild), -1)
  form.mltbox_msg:AddHtmlText(nx_widestr(powerlevel), -1)
  form.projectid = nx_string(projectid)
  form.playername = nx_widestr(playername)
  return form
end
function on_captial2_changed(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local nobind_money = client_player:QueryProp("CapitalType2")
  form.lbl_havemoney.Text = nx_widestr(get_money_text(nobind_money))
end
function get_money_text(money)
  return nx_execute("form_stage_main\\form_huashan\\form_gamble_main_huashan", "FormatMoney", nx_int64(money), 2)
end
