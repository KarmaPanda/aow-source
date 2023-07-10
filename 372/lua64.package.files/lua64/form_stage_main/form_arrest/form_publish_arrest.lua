require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_arrest\\form_arrest_define")
require("define\\sysinfo_define")
require("util_functions")
local min_money = 0
local unit_money = 1
function on_main_form_init(form)
  form.Fixed = false
  form.wanted_name = ""
  form.select_count = 0
  form.select_count_max = 0
  form.group_index = 1
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_enemy.Visible = true
  form.groupbox_money.Visible = false
  form.groupbox_reason.Visible = false
  form.groupbox_all_info.Visible = false
  form.btn_publish.Enabled = false
  form.btn_next.Enabled = false
  form.btn_front.Enabled = false
  local rows = 0
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local client_player = game_client:GetPlayer()
    if nx_is_valid(client_player) then
      rows = client_player:GetRecordRows("Arrest_Warrant_Rec")
    end
  end
  nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_ini")
  min_money, unit_money, be_wanted_rate, max_tasknum = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_publish_need_info")
  form.select_count_max = nx_number(max_tasknum) - rows
  local need_money = money_info(min_money)
  local money_ding, money_liang, money_wen = money_break(min_money)
  gui.TextManager:Format_SetIDName("ui_arrest_money_desc")
  gui.TextManager:Format_AddParam(need_money)
  local text = gui.TextManager:Format_GetText()
  form.mltbox_money_desc.HtmlText = nx_widestr(text)
  show_all_enemy(form)
  nx_execute("util_gui", "ui_show_attached_form", form)
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
  return
end
function on_btn_help_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function show_all_enemy(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  form.groupscrollbox_enemy.IsEditMode = true
  form.groupscrollbox_enemy:DeleteAll()
  local space_row = 90
  local space_col = 25
  local real_count = 0
  local rec_table = {
    "rec_enemy",
    "rec_blood",
    "rec_enemy",
    "rec_blood"
  }
  for i = 1, table.maxn(rec_table) do
    local rec_name = rec_table[i]
    local rows = client_player:GetRecordRows(rec_name)
    for j = 0, rows - 1 do
      local olstate = client_player:QueryRecord(rec_name, j, 8)
      if i <= table.maxn(rec_table) / 2 and nx_int(olstate) == nx_int(0) or i > table.maxn(rec_table) / 2 and nx_int(olstate) ~= nx_int(0) then
        local name = client_player:QueryRecord(rec_name, j, 0)
        local name_text = client_player:QueryRecord(rec_name, j, 1)
        local power_level = client_player:QueryRecord(rec_name, j, 4)
        local characterflag = client_player:QueryRecord(rec_name, j, 13)
        local charactervalue = client_player:QueryRecord(rec_name, j, 14)
        local row = nx_int(real_count / 5)
        local col = real_count % 5
        real_count = real_count + 1
        local check_box = gui:Create("CheckButton")
        nx_set_custom(form, "cbtn_name_" .. nx_string(real_count), check_box)
        check_box.player_name = name_text
        check_box.characterflag = characterflag
        check_box.charactervalue = charactervalue
        check_box.power_level = power_level
        check_box.Name = name
        check_box.Left = col * space_row
        check_box.Top = row * space_col
        check_box.Width = 16
        check_box.Height = 16
        check_box.AutoSize = "True"
        check_box.DrawMode = "Title"
        check_box.ClickEvent = true
        check_box.CheckedImage = nx_string("gui\\common\\checkbutton\\cbtn_2_down.png")
        check_box.NormalImage = nx_string("gui\\common\\checkbutton\\cbtn_2_out.png")
        check_box.FocusImage = nx_string("gui\\common\\checkbutton\\cbtn_2_on.png")
        nx_bind_script(check_box, nx_current())
        nx_callback(check_box, "on_checked_changed", "on_cbtn_checked_change")
        if name_text == form.wanted_name then
          check_box.Checked = true
        end
        form.groupscrollbox_enemy:Add(check_box)
        local label_name = gui:Create("Label")
        label_name.Name = "label_name_" .. nx_string(i)
        label_name.Left = col * space_row + 20
        label_name.Top = row * space_col
        label_name.Width = 65
        label_name.Height = 20
        label_name.Font = "font_sns_list"
        label_name.Align = "Left"
        label_name.Text = name_text
        label_name.ForeColor = "255,128,101,74"
        form.groupscrollbox_enemy:Add(label_name)
      end
    end
  end
  form.groupscrollbox_enemy.Height = 142
  form.groupscrollbox_enemy.IsEditMode = false
end
function show_select_enemy(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  local money_ding = nx_int(form.ipt_money_ding.Text)
  local money_liang = nx_int(form.ipt_money_liang.Text)
  local money_wen = nx_int(form.ipt_money_wen.Text)
  local money_info = format_money_info(money_ding, money_liang, money_wen)
  local all_money = money_ding * 1000000 + money_liang * 1000 + money_wen
  local unit_money, prison_div, max_prison = nx_execute("form_stage_main\\form_arrest\\form_arrest_define", "get_arrest_add_need_info")
  local lock_time = nx_int(all_money / unit_money * prison_div)
  if nx_int(lock_time) > nx_int(max_prison) then
    lock_time = nx_int(max_prison)
  end
  local checkword = nx_value("CheckWords")
  local desc_text = nx_widestr("")
  if nx_is_valid(checkword) then
    desc_text = checkword:CleanWords(form.redit_reason.Text)
  end
  form.gpsbox_select.IsEditMode = true
  form.gpsbox_select:DeleteAll()
  local all_count = 1
  local sel_count = 1
  while true do
    local ctrl_name = "cbtn_name_" .. nx_string(all_count)
    if not nx_find_custom(form, ctrl_name) then
      break
    end
    local cbtn_ctrl = nx_custom(form, ctrl_name)
    if not nx_is_valid(cbtn_ctrl) then
      break
    end
    if cbtn_ctrl.Checked == true then
      local gpbox = create_ctrl("GroupBox", "gbox_one_" .. nx_string(sel_count), form.gpbox_one, form.gpsbox_select)
      local lbl_name_title = create_ctrl("Label", "lbl_name_title" .. nx_string(sel_count), form.lbl_name_title, gpbox)
      local lbl_name = create_ctrl("Label", "lbl_name" .. nx_string(sel_count), form.lbl_name, gpbox)
      local lbl_power_level_title = create_ctrl("Label", "lbl_power_level_title" .. nx_string(sel_count), form.lbl_power_level_title, gpbox)
      local lbl_power_level = create_ctrl("Label", "lbl_power_level" .. nx_string(sel_count), form.lbl_power_level, gpbox)
      local lbl_shane_name_title = create_ctrl("Label", "lbl_shane_name_title" .. nx_string(sel_count), form.lbl_shane_name_title, gpbox)
      local lbl_shane_name = create_ctrl("Label", "lbl_shane_name" .. nx_string(sel_count), form.lbl_shane_name, gpbox)
      local lbl_money_info_title = create_ctrl("Label", "lbl_money_info_title" .. nx_string(sel_count), form.lbl_money_info_title, gpbox)
      local lbl_money_info = create_ctrl("Label", "lbl_money_info" .. nx_string(sel_count), form.lbl_money_info, gpbox)
      local lbl_lock_time_title = create_ctrl("Label", "lbl_lock_time_title" .. nx_string(sel_count), form.lbl_lock_time_title, gpbox)
      local lbl_lock_time = create_ctrl("Label", "lbl_lock_time" .. nx_string(sel_count), form.lbl_lock_time, gpbox)
      local redit_reason_info = create_ctrl("RichEdit", "redit_reason_info" .. nx_string(sel_count), form.redit_reason_info, gpbox)
      lbl_name.Text = cbtn_ctrl.player_name
      lbl_power_level.Text = nx_widestr(gui.TextManager:GetText("desc_" .. karmamgr:ParseColValue(4, nx_string(cbtn_ctrl.power_level))))
      lbl_shane_name.Text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", cbtn_ctrl.characterflag, cbtn_ctrl.charactervalue)
      lbl_money_info.Text = nx_widestr(money_info)
      lbl_lock_time.Text = nx_widestr(nx_int(lock_time / 60)) .. nx_widestr(util_text("ui_fengzhong"))
      redit_reason_info.Text = desc_text
      sel_count = sel_count + 1
    end
    all_count = all_count + 1
  end
  form.gpsbox_select.IsEditMode = false
  form.gpsbox_select:ResetChildrenYPos()
end
function on_cbtn_allselect_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local checked = cbtn.Checked
  local count = 1
  while true do
    local ctrl_name = "cbtn_name_" .. nx_string(count)
    if not nx_find_custom(form, ctrl_name) then
      break
    end
    local cbtn_ctrl = nx_custom(form, ctrl_name)
    if not nx_is_valid(cbtn_ctrl) then
      break
    end
    cbtn_ctrl.Checked = checked
    count = count + 1
  end
end
function on_cbtn_checked_change(cbtn)
  local gui = nx_value("gui")
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked == true then
    if nx_number(form.select_count) == nx_number(form.select_count_max) then
      cbtn.Enabled = false
      cbtn.Checked = false
      cbtn.Enabled = true
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
      end
      return
    end
    form.select_count = form.select_count + 1
  else
    form.select_count = form.select_count - 1
  end
  if nx_number(form.select_count) > 0 then
    form.btn_next.Enabled = true
  else
    form.btn_next.Enabled = false
  end
end
function on_add_publish(enemy_name)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_arrest\\form_publish_arrest", true, false)
  if not nx_is_valid(form) then
    return
  end
  form.wanted_name = enemy_name
  util_show_form("form_stage_main\\form_arrest\\form_publish_arrest", true)
  form.groupbox_enemy.Visible = false
  form.groupbox_money.Visible = true
  form.groupbox_reason.Visible = false
  form.groupbox_all_info.Visible = false
  form.group_index = 2
  form.btn_next.Enabled = true
  form.btn_front.Enabled = true
  form.btn_publish.Enabled = false
end
function on_btn_next_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return
  end
  local capital = mgr:GetCapital(2)
  local form_group = {
    form.groupbox_enemy,
    form.groupbox_money,
    form.groupbox_reason,
    form.groupbox_all_info
  }
  local group_index = form.group_index
  if 3 < group_index then
    return
  end
  if group_index == 1 then
    form.btn_front.Enabled = true
  end
  if group_index == 2 then
    local money_ding = nx_int(form.ipt_money_ding.Text)
    local money_liang = nx_int(form.ipt_money_liang.Text)
    local money_wen = nx_int(form.ipt_money_wen.Text)
    local money_num = money_ding * 1000000 + money_liang * 1000 + money_wen
    if nx_int(money_num) < nx_int(min_money) then
      local min_ding, min_liang, min_wen = money_break(min_money)
      form.ipt_money_ding.Text = nx_widestr(min_ding)
      form.ipt_money_liang.Text = nx_widestr(min_liang)
      form.ipt_money_wen.Text = nx_widestr(min_wen)
      return
    end
    if nx_number(capital) < nx_number(money_num) * nx_number(form.select_count) then
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("83301"), CENTERINFO_PERSONAL_NO)
      end
      return
    end
  end
  if group_index == 3 then
    form.btn_publish.Enabled = true
    form.btn_next.Enabled = false
    show_select_enemy(form)
  end
  form.groupbox_enemy.Visible = false
  form.groupbox_money.Visible = false
  form.groupbox_reason.Visible = false
  form.groupbox_all_info.Visible = false
  form_group[group_index + 1].Visible = true
  form.group_index = group_index + 1
end
function on_btn_front_click(btn)
  form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_group = {
    form.groupbox_enemy,
    form.groupbox_money,
    form.groupbox_reason,
    form.groupbox_all_info
  }
  local group_index = form.group_index
  if group_index < 2 then
    return
  end
  if group_index == 2 then
    form.btn_front.Enabled = false
  end
  if group_index == 4 then
    form.btn_publish.Enabled = false
    form.btn_next.Enabled = true
  end
  form.groupbox_enemy.Visible = false
  form.groupbox_money.Visible = false
  form.groupbox_reason.Visible = false
  form.groupbox_all_info.Visible = false
  form_group[group_index - 1].Visible = true
  form.group_index = group_index - 1
  return
end
function on_btn_publish_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local money_ding = nx_int(form.ipt_money_ding.Text)
  local money_liang = nx_int(form.ipt_money_liang.Text)
  local money_wen = nx_int(form.ipt_money_wen.Text)
  local money = money_ding * 1000000 + money_liang * 1000 + money_wen
  local reason = form.redit_reason.Text
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText(nx_string("ui_publish_arrest")))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local count = 1
  while true do
    local ctrl_name = "cbtn_name_" .. nx_string(count)
    if not nx_find_custom(form, ctrl_name) then
      break
    end
    local cbtn_ctrl = nx_custom(form, ctrl_name)
    if not nx_is_valid(cbtn_ctrl) then
      break
    end
    if cbtn_ctrl.Checked == true then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ARREST_WARRANT), ARREST_CUSTOMMSG_PUBLIC_ARREST, nx_widestr(cbtn_ctrl.player_name), nx_int(money), nx_widestr(reason))
    end
    count = count + 1
  end
  if nx_is_valid(form) then
    form:Close()
  end
  return
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
  return ctrl
end
