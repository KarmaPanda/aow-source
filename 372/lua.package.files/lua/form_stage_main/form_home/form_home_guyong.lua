require("util_functions")
require("util_gui")
require("tips_data")
require("form_stage_main\\form_home\\form_home_msg")
local array_name = "form_home_guyong_array_hf"
function tc(msg)
  nx_msgbox(nx_string(msg))
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = false
  form.ini = nil
  form.select = ""
  form.select_index = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local ini = get_ini("share\\Home\\HomeEmployNpc.ini", true)
  if not nx_is_valid(ini) then
    form:Close()
    return
  end
  form.ini = ini
  form_init(form)
  form.btn_ok.npcid = ""
  on_rbtn_click(form.rbtn_qjg)
end
function on_main_form_close(form)
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) and common_array:FindArray(array_name) then
    common_array:RemoveArray(array_name)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_rbtn_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  rbtn.Checked = true
  local index = rbtn.TabIndex
  form.select = "npc_" .. nx_string(index) .. "_"
  form.select_index = index
  fresh_form(form)
  if nx_number(index) == 2 then
    local helper_form = nx_value("helper_form")
    if helper_form then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  if nx_string(btn.npcid) == nx_string("") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = util_format_string("ui_home_gy_money", nx_int(btn.money))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if nx_string(res) ~= "ok" then
    return
  end
  home_manager:SetCurrentGoods(btn.npcid, btn.npcid, 334, btn.day)
  form:Close()
end
function on_combobox_time_selected(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  fresh_form(form)
end
function on_combobox_lvl_selected(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  fresh_form(form)
end
function fresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local section = form.select
  if section == "" then
    return
  end
  local lvl = nx_int(nx_string(form.combobox_lvl.DropListBox:GetTag(form.combobox_lvl.DropListBox.SelectIndex)))
  section = section .. nx_string(lvl)
  local point = get_conf_i(section, "point")
  local pay_value = get_conf_f(section, "pay_value")
  form.lbl_explain.HtmlText = util_format_string("ui_home_gy_explain_" .. nx_string(form.select_index), nx_int(point))
  local conf_id = nx_execute("form_stage_main\\form_home\\form_home_enter", "get_conf_id")
  if nx_int(conf_id) == nx_int(0) then
    return
  end
  local money = get_conf_money(conf_id)
  if nx_number(form.select_index) == nx_number(3) then
    money = 1
  end
  local day = nx_int(nx_string(form.combobox_time.DropListBox:GetTag(form.combobox_time.DropListBox.SelectIndex)))
  local all_money = day * 24 * point * money * pay_value
  form.lbl_money.Text = trans_capital_string(nx_int64(all_money))
  form.btn_ok.npcid = get_conf_s(section, "ConfigID")
  form.btn_ok.money = all_money
  form.btn_ok.day = day
end
function form_init(form)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.ini) then
    return
  end
  local sec_index = form.ini:FindSectionIndex("npc_time")
  if sec_index < 0 then
    return
  end
  form.combobox_time.DropListBox:ClearString()
  form.combobox_lvl.DropListBox:ClearString()
  local time_table = form.ini:GetItemValueList(sec_index, "r")
  for i = 1, table.getn(time_table) do
    local time = time_table[i]
    local text = nx_widestr(time) .. util_text("ui_home_gy_tian")
    local index = form.combobox_time.DropListBox:AddString(text)
    local id = nx_string(time) .. "-0"
    form.combobox_time.DropListBox:SetTag(index, nx_object(id))
  end
  local index = 0
  index = form.combobox_lvl.DropListBox:AddString(util_text("ui_home_gy_pt"))
  form.combobox_lvl.DropListBox:SetTag(index, nx_object("1-0"))
  index = form.combobox_lvl.DropListBox:AddString(util_text("ui_home_gy_zj"))
  form.combobox_lvl.DropListBox:SetTag(index, nx_object("2-0"))
  index = form.combobox_lvl.DropListBox:AddString(util_text("ui_home_gy_gj"))
  form.combobox_lvl.DropListBox:SetTag(index, nx_object("3-0"))
  form.combobox_time.DropListBox.SelectIndex = 0
  form.combobox_time.Text = nx_widestr(form.combobox_time.DropListBox:GetString(form.combobox_time.DropListBox.SelectIndex))
  form.combobox_lvl.DropListBox.SelectIndex = 0
  form.combobox_lvl.Text = nx_widestr(form.combobox_lvl.DropListBox:GetString(form.combobox_lvl.DropListBox.SelectIndex))
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(array_name) then
    common_array:AddArray(array_name, form, 60, true)
  end
  common_array:ClearChild(array_name)
  sec_index = form.ini:FindSectionIndex("home_price")
  if sec_index < 0 then
    return
  end
  local money_table = form.ini:GetItemValueList(sec_index, "r")
  for i = 1, table.getn(money_table) do
    local moneys = util_split_string(nx_string(money_table[i]), ",")
    if table.maxn(moneys) == 2 then
      local conf_id = moneys[1]
      local money = moneys[2]
      common_array:AddChild(array_name, nx_string(conf_id), nx_string(money))
    end
  end
end
function get_conf_money(conf_id)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  if not common_array:FindArray(array_name) then
    return 0
  end
  return nx_int(common_array:FindChild(array_name, nx_string(conf_id)))
end
function get_conf_s(section, flag)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return ""
  end
  if not nx_is_valid(form.ini) then
    return ""
  end
  local index = form.ini:FindSectionIndex(nx_string(section))
  if index < 0 then
    return ""
  end
  return form.ini:ReadString(index, nx_string(flag), "")
end
function get_conf_i(section, flag)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(form.ini) then
    return 0
  end
  local index = form.ini:FindSectionIndex(nx_string(section))
  if index < 0 then
    return 0
  end
  return form.ini:ReadInteger(index, nx_string(flag), 0)
end
function get_conf_f(section, flag)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(form.ini) then
    return 0
  end
  local index = form.ini:FindSectionIndex(nx_string(section))
  if index < 0 then
    return 0
  end
  return form.ini:ReadFloat(index, nx_string(flag), 0)
end
