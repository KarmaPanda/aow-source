require("const_define")
require("util_functions")
require("custom_sender")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
require("define\\request_type")
local reply_num = 7
function main_form_init(form)
  form.Fixed = false
  form.pack_id = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  form.ipt_replay.Text = nx_widestr(util_text("ui_hongbao_send_wishdesc"))
  init_replay(form)
end
function init_replay(form)
  if not nx_is_valid(form) then
    return
  end
  local replay_com = form.combobox_replay
  for i = 1, reply_num do
    local temp_name = "ui_hongbao_open_wishdesc_"
    temp_name = temp_name .. nx_string(i - 1)
    replay_com.DropListBox:AddString(nx_widestr(util_text(temp_name)))
  end
  replay_com.Text = nx_widestr(util_text("ui_hongbao_send_wishdesc_0"))
end
function on_main_form_close(form)
  form.pack_id = ""
  nx_destroy(form)
end
function on_btn_open_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_get_newpacket(nx_string(form.pack_id))
end
function on_btn_close_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_record_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_see_getrecord()
end
function on_btn_detail_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  custom_see_singlepacket(nx_string(form.pack_id))
end
function on_btn_replay_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local text = nx_widestr(form.combobox_replay.Text)
  local comment = nx_widestr("")
  local checkwords = nx_value("CheckWords")
  if nx_is_valid(checkwords) then
    comment = checkwords:CleanWords(nx_widestr(text))
  end
  custom_reply_packet(nx_string(form.pack_id), nx_widestr(comment))
  form:Close()
end
function on_server_msg(...)
  local form = util_get_form("form_stage_main\\form_hongbao\\form_hongbao_open", true, false)
  if not nx_is_valid(form) then
    return
  end
  local sucess = nx_int(arg[1])
  form.pack_id = nx_string(arg[2])
  local name = nx_widestr(arg[3])
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_hongbao_open_player")
  gui.TextManager:Format_AddParam(nx_widestr(name))
  form.lbl_player.Text = gui.TextManager:Format_GetText()
  if nx_int(sucess) == nx_int(0) then
    form.lbl_nomoney.Visible = false
    form.lbl_get.Visible = true
    form.lbl_yinzi.Visible = true
    form.lbl_money.Visible = true
    form.ipt_replay.Visible = true
    form.btn_replay.Visible = true
    form.lbl_1.Visible = false
    form.groupbox_get.Visible = true
    local bless = nx_widestr(arg[4])
    local gold = nx_int(arg[5])
    local gold_text = nx_execute("util_functions", "trans_capital_string", gold)
    form.lbl_money.Text = nx_widestr(gold_text)
  elseif nx_int(sucess) == nx_int(1) then
    form.lbl_nomoney.Visible = true
    form.groupbox_get.Visible = false
    form.combobox_replay.Visible = false
    form.lbl_replay_back.Visible = false
    gui.TextManager:Format_SetIDName("ui_hongbao_open_fail_1")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    local text = gui.TextManager:Format_GetText()
    form.lbl_nomoney.Text = nx_widestr(text)
  elseif nx_int(sucess) == nx_int(2) then
    form.lbl_nomoney.Visible = true
    form.groupbox_get.Visible = false
    form.combobox_replay.Visible = false
    form.lbl_replay_back.Visible = false
    gui.TextManager:Format_SetIDName("ui_hongbao_open_fail_2")
    gui.TextManager:Format_AddParam(nx_widestr(name))
    local text = gui.TextManager:Format_GetText()
    form.lbl_nomoney.Text = nx_widestr(text)
  elseif nx_int(sucess) == nx_int(3) then
    form.groupbox_get.Visible = true
    form.lbl_get.Visible = false
    form.lbl_yinzi.Visible = false
    form.lbl_money.Visible = false
    form.ipt_replay.Visible = false
    form.btn_replay.Visible = false
    form.lbl_nomoney.Visible = false
    form.combobox_replay.Visible = false
    form.lbl_replay_back.Visible = false
    form.lbl_1.Visible = true
  end
  form.Visible = true
  form:Show()
end
