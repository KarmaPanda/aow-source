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
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_server_msg(...)
  local form = util_get_form("form_stage_main\\form_hongbao\\form_hongbao_detail", true, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local name = nx_widestr(arg[1])
  local money = nx_widestr(arg[2])
  local maxuser = nx_number(arg[3])
  local curuser = nx_number(arg[4])
  local bless = nx_widestr(arg[5])
  form.lbl_num.Text = nx_widestr(get_money_text(money))
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_hongbao_open_player")
  gui.TextManager:Format_AddParam(nx_widestr(name))
  form.lbl_from.Text = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_hongbao_detail_1")
  gui.TextManager:Format_AddParam(nx_widestr(curuser))
  gui.TextManager:Format_AddParam(nx_widestr(maxuser))
  text = gui.TextManager:Format_GetText()
  form.lbl_m.Text = text
  form.groupscrollbox_detail.IsEditMode = true
  form.groupscrollbox_detail:DeleteAll()
  local msgsize = 5
  for i = 1, curuser do
    local gb = create_ctrl("GroupBox", "gb_" .. nx_string(i), form.groupbox_templet, form.groupscrollbox_detail)
    if nx_is_valid(gb) then
      local name = nx_widestr(arg[6 + (i - 1) * msgsize])
      local gold = nx_int(arg[7 + (i - 1) * msgsize])
      local reply = nx_widestr(arg[8 + (i - 1) * msgsize])
      local get_time = nx_double(arg[9 + (i - 1) * msgsize])
      local flag = nx_int(arg[10 + (i - 1) * msgsize])
      local lbl_playername = create_ctrl("Label", "lbl_name_" .. nx_string(i), form.lbl_playername, gb)
      local mltbox_num = create_ctrl("MultiTextBox", "mltbox_num_" .. nx_string(i), form.mltbox_num, gb)
      local mltbox_tw = create_ctrl("MultiTextBox", "mltbox_tw_" .. nx_string(i), form.mltbox_tw, gb)
      local lbl_lucky = create_ctrl("Label", "lbl_lucky_" .. nx_string(i), form.lbl_lucky, gb)
      local lbl_line = create_ctrl("Label", "lbl_line_" .. nx_string(i), form.lbl_line, gb)
      if nx_int(flag) == nx_int(0) then
        lbl_lucky.Visible = false
      end
      lbl_playername.Text = name
      local money_text = get_money_text(gold)
      gui.TextManager:Format_SetIDName("ui_hongbao_detail_get")
      gui.TextManager:Format_AddParam(nx_widestr(money_text))
      local text = gui.TextManager:Format_GetText()
      mltbox_num:Clear()
      mltbox_num:AddHtmlText(nx_widestr(text), -1)
      local year, month, day, hour, minu = nx_function("ext_decode_date", nx_double(get_time))
      local year_info = nx_widestr(year) .. nx_widestr("-") .. nx_widestr(month) .. nx_widestr("-") .. nx_widestr(day)
      local hour_info = nx_widestr(hour) .. nx_widestr(":") .. nx_widestr(string.format("%02d", minu))
      gui.TextManager:Format_SetIDName("ui_hongbao_detail_date")
      gui.TextManager:Format_AddParam(nx_widestr(year_info))
      gui.TextManager:Format_AddParam(nx_widestr(hour_info))
      gui.TextManager:Format_AddParam(nx_widestr(reply))
      local timetext = gui.TextManager:Format_GetText()
      mltbox_tw:Clear()
      mltbox_tw:AddHtmlText(nx_widestr(timetext), -1)
    end
  end
  form.groupscrollbox_detail.IsEditMode = false
  form.groupscrollbox_detail:ResetChildrenYPos()
  form.Visible = true
  form:Show()
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
