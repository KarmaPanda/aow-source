require("const_define")
require("util_functions")
require("custom_sender")
require("util_gui")
require("tips_data")
require("role_composite")
require("share\\client_custom_define")
require("define\\request_type")
function main_form_init(form)
  form.Fixed = false
  form.pack_id = ""
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 4
  form.combobox_type.Text = nx_widestr("")
  form.combobox_type.DropListBox:ClearString()
  gui.TextManager:Format_SetIDName("ui_hongbao_record_send")
  local text = gui.TextManager:Format_GetText()
  form.combobox_type.DropListBox:AddString(nx_widestr(text))
  gui.TextManager:Format_SetIDName("ui_hongbao_record_receive")
  text = gui.TextManager:Format_GetText()
  form.combobox_type.DropListBox:AddString(nx_widestr(text))
end
function on_main_form_close(form)
  form.pack_id = ""
  nx_destroy(form)
end
function on_btn_close_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_combobox_type_selected(combox)
  local form = combox.ParentForm
  local select_index = combox.DropListBox.SelectIndex
  if nx_int(select_index) == nx_int(0) then
    custom_see_sendrecord()
  else
    custom_see_getrecord()
  end
end
function on_btn_record_click(btn)
  local form = btn.ParentForm
  local uid_packet = nx_custom(btn, "uid_packet")
  custom_see_singlepacket(nx_string(uid_packet))
end
function on_server_get_record(...)
  local form = util_get_form("form_stage_main\\form_hongbao\\form_hongbao_record", true, false)
  if not nx_is_valid(form) then
    return
  end
  local valid_num = nx_number(arg[1])
  local gui = nx_value("gui")
  form.mltbox_receive.Visible = true
  form.mltbox_send.Visible = false
  form.groupscrollbox_detail.IsEditMode = true
  form.groupscrollbox_detail:DeleteAll()
  local gold_count = 0
  local good_count = 0
  local msgsize = 6
  for i = 1, valid_num do
    local uid_packet = nx_string(arg[2 + (i - 1) * msgsize])
    local name_sender = nx_widestr(arg[3 + (i - 1) * msgsize])
    local gold = nx_int(arg[4 + (i - 1) * msgsize])
    local flag = nx_int(arg[5 + (i - 1) * msgsize])
    local good_flag = nx_int(arg[6 + (i - 1) * msgsize])
    local time1 = nx_double(arg[7 + (i - 1) * msgsize])
    gold_count = nx_int(gold_count) + nx_int(gold)
    if nx_int(1) == nx_int(good_flag) then
      good_count = nx_int(good_count) + 1
    end
    local gb = create_ctrl("GroupBox", "gb_" .. nx_string(i), form.groupbox_templet_get, form.groupscrollbox_detail)
    if nx_is_valid(gb) then
      local btn_record = create_ctrl("Button", "btn_record_" .. nx_string(i), form.btn_get, gb)
      local lbl_type = create_ctrl("Label", "lbl_type_" .. nx_string(i), form.lbl_player, gb)
      local lbl_pin = create_ctrl("Label", "lbl_pin_" .. nx_string(i), form.lbl_pin, gb)
      local mltbox_money_g = create_ctrl("MultiTextBox", "mltbox_money_g_" .. nx_string(i), form.mltbox_money_g, gb)
      local mltbox_date_g = create_ctrl("MultiTextBox", "mltbox_date_g_" .. nx_string(i), form.mltbox_date_g, gb)
      nx_set_custom(btn_record, "uid_packet", uid_packet)
      nx_bind_script(btn_record, nx_current())
      nx_callback(btn_record, "on_click", "on_btn_record_click")
      lbl_type.Text = name_sender
      local year, month, day, hour, minu = nx_function("ext_decode_date", nx_double(time1))
      local year_info = nx_widestr(year) .. nx_widestr("-") .. nx_widestr(month) .. nx_widestr("-") .. nx_widestr(day)
      local hour_info = nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(string.format("%02d", minu))
      gui.TextManager:Format_SetIDName("ui_hongbao_record_date")
      gui.TextManager:Format_AddParam(nx_widestr(year_info))
      gui.TextManager:Format_AddParam(nx_widestr(hour_info))
      local text = nx_widestr(gui.TextManager:Format_GetText())
      mltbox_date_g:Clear()
      mltbox_date_g:AddHtmlText(nx_widestr(text), -1)
      if nx_int(1) == nx_int(flag) then
        lbl_pin.Visible = true
      else
        lbl_pin.Visible = false
      end
      local money_text = get_money_text(gold)
      gui.TextManager:Format_SetIDName("ui_hongbao_detail_get")
      gui.TextManager:Format_AddParam(nx_widestr(money_text))
      local text = gui.TextManager:Format_GetText()
      mltbox_money_g:Clear()
      mltbox_money_g:AddHtmlText(nx_widestr(text), -1)
    end
  end
  form.groupscrollbox_detail.IsEditMode = false
  form.groupscrollbox_detail:ResetChildrenYPos()
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local name = player_client:QueryProp("Name")
  local money_text = get_money_text(gold_count)
  gui.TextManager:Format_SetIDName("ui_hongbao_record_player_1")
  gui.TextManager:Format_AddParam(nx_widestr(name))
  gui.TextManager:Format_AddParam(nx_widestr(money_text))
  local text = gui.TextManager:Format_GetText()
  form.mltbox_receive:Clear()
  form.mltbox_receive:AddHtmlText(nx_widestr(text), -1)
  gui.TextManager:Format_SetIDName("ui_hongbao_record_num_1")
  gui.TextManager:Format_AddParam(nx_widestr(valid_num))
  form.lbl_hongbao_num.Text = nx_widestr(gui.TextManager:Format_GetText())
  gui.TextManager:Format_SetIDName("ui_hongbao_record_num_2")
  gui.TextManager:Format_AddParam(nx_widestr(good_count))
  form.lbl_lucky_num.Visible = true
  form.lbl_lucky_num.Text = nx_widestr(gui.TextManager:Format_GetText())
  form.Visible = true
  form:Show()
  gui.TextManager:Format_SetIDName("ui_hongbao_record_receive")
  form.combobox_type.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function on_server_send_record(...)
  local form = util_get_form("form_stage_main\\form_hongbao\\form_hongbao_record", true, false)
  if not nx_is_valid(form) then
    return
  end
  local valid_num = nx_number(arg[1])
  local gui = nx_value("gui")
  form.mltbox_receive.Visible = false
  form.mltbox_send.Visible = true
  form.lbl_lucky_num.Visible = false
  form.groupscrollbox_detail.IsEditMode = true
  form.groupscrollbox_detail:DeleteAll()
  local msgsize = 6
  local gold_count = 0
  for i = 1, valid_num do
    local uid_packet = nx_string(arg[2 + (i - 1) * msgsize])
    local rule = nx_int(arg[3 + (i - 1) * msgsize])
    local maxcount = nx_int(arg[4 + (i - 1) * msgsize])
    local curcount = nx_int(arg[5 + (i - 1) * msgsize])
    local gold = nx_int(arg[6 + (i - 1) * msgsize])
    local time1 = nx_double(arg[7 + (i - 1) * msgsize])
    gold_count = nx_int(gold_count) + nx_int(gold)
    local gb = create_ctrl("GroupBox", "gb_" .. nx_string(i), form.groupbox_templet_send, form.groupscrollbox_detail)
    if nx_is_valid(gb) then
      local btn_record = create_ctrl("Button", "btn_record_" .. nx_string(i), form.btn_send, gb)
      local lbl_type = create_ctrl("Label", "lbl_type_" .. nx_string(i), form.lbl_type, gb)
      local lbl_m = create_ctrl("Label", "lbl_m_" .. nx_string(i), form.lbl_m, gb)
      local mltbox_money_s = create_ctrl("MultiTextBox", "mltbox_money_s_" .. nx_string(i), form.mltbox_money_s, gb)
      local mltbox_date_s = create_ctrl("MultiTextBox", "mltbox_date_s_" .. nx_string(i), form.mltbox_date_s, gb)
      nx_set_custom(btn_record, "uid_packet", uid_packet)
      nx_bind_script(btn_record, nx_current())
      nx_callback(btn_record, "on_click", "on_btn_record_click")
      local ruleid = "ui_hongbao_send_type_putong"
      if nx_int(rule) == nx_int(1) then
        ruleid = "ui_hongbao_send_type_pin"
      end
      gui.TextManager:Format_SetIDName(nx_string(ruleid))
      lbl_type.Text = gui.TextManager:Format_GetText()
      local year, month, day, hour, minu = nx_function("ext_decode_date", nx_double(time1))
      local year_info = nx_widestr(year) .. nx_widestr("-") .. nx_widestr(month) .. nx_widestr("-") .. nx_widestr(day)
      local hour_info = nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(string.format("%02d", minu))
      gui.TextManager:Format_SetIDName("ui_hongbao_record_date")
      gui.TextManager:Format_AddParam(nx_widestr(year_info))
      gui.TextManager:Format_AddParam(nx_widestr(hour_info))
      local text = nx_widestr(gui.TextManager:Format_GetText())
      mltbox_date_s:Clear()
      mltbox_date_s:AddHtmlText(nx_widestr(text), -1)
      local money_text = get_money_text(gold)
      gui.TextManager:Format_SetIDName("ui_hongbao_detail_get")
      gui.TextManager:Format_AddParam(nx_widestr(money_text))
      local text = gui.TextManager:Format_GetText()
      mltbox_money_s:Clear()
      mltbox_money_s:AddHtmlText(nx_widestr(text), -1)
      ruleid = "ui_hongbao_record_result_1"
      if nx_int(curcount) < nx_int(maxcount) then
        ruleid = "ui_hongbao_record_result_2"
      end
      gui.TextManager:Format_SetIDName(nx_string(ruleid))
      gui.TextManager:Format_AddParam(nx_widestr(curcount))
      gui.TextManager:Format_AddParam(nx_widestr(maxcount))
      lbl_m.Text = gui.TextManager:Format_GetText()
      if nx_string(ruleid) == "ui_hongbao_record_result_2" then
        lbl_m.ForeColor = "255,255,0,0"
      end
    end
  end
  form.groupscrollbox_detail.IsEditMode = false
  form.groupscrollbox_detail:ResetChildrenYPos()
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  local name = player_client:QueryProp("Name")
  gui.TextManager:Format_SetIDName("ui_hongbao_record_num_1")
  gui.TextManager:Format_AddParam(nx_widestr(valid_num))
  form.lbl_hongbao_num.Text = nx_widestr(gui.TextManager:Format_GetText())
  local money_text = get_money_text(gold_count)
  gui.TextManager:Format_SetIDName("ui_hongbao_record_player_2")
  gui.TextManager:Format_AddParam(nx_widestr(name))
  gui.TextManager:Format_AddParam(nx_widestr(money_text))
  local text = gui.TextManager:Format_GetText()
  form.mltbox_send:Clear()
  form.mltbox_send:AddHtmlText(nx_widestr(text), -1)
  form.Visible = true
  form:Show()
  gui.TextManager:Format_SetIDName("ui_hongbao_record_send")
  form.combobox_type.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function get_money_text(capital)
  local text = ""
  local gui = nx_value("gui")
  local ding = math.floor(nx_number(capital) / 1000000)
  local liang = math.floor(nx_number(capital) % 1000000 / 1000)
  local wen = math.floor(nx_number(capital) % 1000)
  if nx_number(ding) > 0 then
    text = nx_widestr(ding) .. nx_widestr(gui.TextManager:GetText("ui_ding"))
  end
  if nx_number(liang) > 0 then
    text = nx_widestr(text) .. nx_widestr(liang) .. nx_widestr(gui.TextManager:GetText("ui_liang"))
  end
  if nx_number(wen) > 0 then
    text = nx_widestr(text) .. nx_widestr(wen) .. nx_widestr(gui.TextManager:GetText("ui_Wen"))
  end
  return nx_widestr(text)
end
function get_time_text(time1)
  local year, month, day, hour, minu = nx_function("ext_decode_date", nx_double(time1))
  local text = nx_widestr("[") .. nx_widestr(year) .. nx_widestr("-") .. nx_widestr(month) .. nx_widestr("-") .. nx_widestr(day) .. nx_widestr(" ") .. nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(minu) .. nx_widestr("]")
  return text
end
