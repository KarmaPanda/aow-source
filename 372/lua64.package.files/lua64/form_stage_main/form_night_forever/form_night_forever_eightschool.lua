require("util_gui")
require("util_functions")
require("share\\server_custom_define")
EIGHT_SCHOOL_INI_FILE = "ini\\ui\\night_forever\\eightschool.ini"
FORM_NIGHT_FOREVER_EIGHTSCHOOL = "form_stage_main\\form_night_forever\\form_night_forever_eightschool"
EIGHTSCHOOL_ARRAY_NAME = "night_forever_eightschool_array"
function main_form_init(form)
  form.Fixed = false
  form.select_eight_school_name = ""
  form.eightschool_array = nx_null()
end
function on_main_form_open(form)
  show_eight_school(form)
end
function on_main_form_close(form)
  nx_destroy(form.eightschool_array)
  nx_destroy(form)
end
function show_eight_school(form)
  local ini = nx_execute("util_functions", "get_ini", EIGHT_SCHOOL_INI_FILE)
  if not nx_is_valid(ini) then
    return false
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return false
  end
  form.eightschool_array = nx_call("util_gui", "get_arraylist", EIGHTSCHOOL_ARRAY_NAME)
  if not nx_is_valid(form.eightschool_array) then
    return false
  end
  form.eightschool_array:ClearChild()
  local default_select = true
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local section = ini:GetSectionByIndex(i)
    local enabled = nx_boolean(ini:ReadString(i, "Enabled", "false"))
    local point_prop_name = ini:ReadString(i, "PointPropName", "")
    local point_prop_desc = ini:ReadString(i, "PointPropDesc", "")
    local point_prop_hint = ini:ReadString(i, "PointPropHintText", "")
    local switch_id = nx_int(ini:ReadString(i, "SwitchID", "0"))
    if switch_id > nx_int(0) and not switch_manager:CheckSwitchEnable(switch_id) then
      enabled = false
    end
    local eight_school_child = form.eightschool_array:CreateChild(section)
    if nx_is_valid(eight_school_child) then
      local task_tab = ini:GetItemValueList(i, "r")
      for j = 1, table.getn(task_tab) do
        local tab_value = util_split_string(task_tab[j], ",")
        local task_child = eight_school_child:CreateChild(tab_value[2])
        if nx_is_valid(task_child) then
          task_child.one_key = nx_int(tab_value[1])
          task_child.task_id = nx_int(tab_value[2])
          task_child.price = nx_int(0)
          task_child.cur_round = nx_int(0)
          task_child.max_round = nx_int(0)
        end
      end
    end
    local rbtn_eightschool = nx_custom(form, "rbtn_eightschool_" .. nx_string(i + 1))
    if nx_is_valid(rbtn_eightschool) then
      rbtn_eightschool.Text = util_text(section)
      rbtn_eightschool.Enabled = enabled
      rbtn_eightschool.eight_school_name = section
      rbtn_eightschool.point_prop_name = point_prop_name
      rbtn_eightschool.point_prop_desc = point_prop_desc
      rbtn_eightschool.point_prop_hint = point_prop_hint
      if enabled == true and default_select == true then
        rbtn_eightschool.Checked = true
        default_select = false
      end
    end
  end
end
function on_refresh_task_info(msg_type, ...)
  if msg_type ~= SERVER_CUSTOMMSG_ROUND_TASK then
    return false
  end
  local form = nx_value(FORM_NIGHT_FOREVER_EIGHTSCHOOL)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "eightschool_array") then
    return false
  end
  if not nx_is_valid(form.eightschool_array) then
    return false
  end
  local sub_type = nx_int(arg[1])
  local task_id = nx_int(arg[2])
  local cur_round = nx_int(arg[3])
  local max_round = nx_int(arg[4])
  local price = nx_int(arg[5])
  if nx_int(sub_type) ~= nx_int(2) then
    return false
  end
  local eight_school_tab = form.eightschool_array:GetChildList()
  for i = 1, table.getn(eight_school_tab) do
    local eight_school_child = eight_school_tab[i]
    local task_tab = eight_school_child:GetChildList()
    local find = false
    for j = 1, table.getn(task_tab) do
      local task_child = task_tab[j]
      if nx_string(task_child.task_id) == nx_string(task_id) then
        task_child.price = price
        task_child.cur_round = cur_round
        task_child.max_round = max_round
        find = true
        break
      end
      if find == true then
        break
      end
    end
  end
  local rows = form.textgrid_task.RowCount
  for i = 0, rows - 1 do
    local rec_task_child = form.textgrid_task:GetGridTag(i, 0)
    if nx_is_valid(rec_task_child) and nx_string(rec_task_child.task_id) == nx_string(task_id) then
      local lbl_round = nx_custom(form, "lbl_round_" .. nx_string(task_id))
      if nx_is_valid(lbl_round) then
        lbl_round.Text = nx_widestr(nx_string(cur_round) .. "/" .. nx_string(max_round))
      end
      local btn_one_key = nx_custom(form, "btn_one_key_" .. nx_string(task_id))
      if nx_is_valid(btn_one_key) then
        btn_one_key.price = price
        btn_one_key.Enabled = nx_int(price) > nx_int(0)
      end
      break
    end
  end
end
function on_rbtn_eightschool_checked_changed(self)
  local form = self.ParentForm
  if self.Checked ~= true then
    return false
  end
  if not (nx_find_custom(self, "eight_school_name") and nx_find_custom(self, "point_prop_name") and nx_find_custom(self, "point_prop_desc")) or not nx_find_custom(self, "point_prop_hint") then
    return false
  end
  if not nx_find_custom(form, "eightschool_array") or not nx_is_valid(form.eightschool_array) then
    return false
  end
  form.select_eight_school_name = self.eight_school_name
  local eight_school_child = form.eightschool_array:GetChild(form.select_eight_school_name)
  if not nx_is_valid(eight_school_child) then
    return false
  end
  form.lbl_points.Text = nx_widestr("")
  form.lbl_point_desc.Text = util_text(self.point_prop_desc)
  form.lbl_point_desc.HintText = util_text(self.point_prop_hint)
  if self.point_prop_name ~= "" then
    local game_client = nx_value("game_client")
    if nx_is_valid(game_client) then
      local client_player = game_client:GetPlayer()
      if nx_is_valid(client_player) then
        local points = client_player:QueryProp(self.point_prop_name)
        form.lbl_points.Text = nx_widestr(points)
      end
    end
  end
  form.textgrid_task:BeginUpdate()
  form.textgrid_task:ClearRow()
  local task_tab = eight_school_child:GetChildList()
  for i = 1, table.getn(task_tab) do
    local task_child = task_tab[i]
    local task_id = task_child.task_id
    local one_key = task_child.one_key
    local price = task_child.price
    local cur_round = task_child.cur_round
    local max_round = task_child.max_round
    local row = form.textgrid_task:InsertRow(-1)
    form.textgrid_task:SetGridTag(row, 0, task_child)
    local gbox_task = create_ctrl("GroupBox", "gbox_task_" .. task_id, form.gbox_task, nx_null())
    local cbtn_sel = create_ctrl("CheckButton", "cbtn_sel_" .. task_id, form.cbtn_sel, gbox_task)
    local lbl_func = create_ctrl("Label", "lbl_func_" .. task_id, form.lbl_func, gbox_task)
    local lbl_prize = create_ctrl("Label", "lbl_prize_" .. task_id, form.lbl_prize, gbox_task)
    local lbl_time = create_ctrl("Label", "lbl_time_" .. task_id, form.lbl_time, gbox_task)
    local lbl_round = create_ctrl("Label", "lbl_round_" .. task_id, form.lbl_round, gbox_task)
    local mltbox_accept = create_ctrl("MultiTextBox", "mltbox_accept_" .. task_id, form.mltbox_accept, gbox_task)
    local btn_one_key = create_ctrl("Button", "btn_one_key_" .. task_id, form.btn_one_key, gbox_task)
    lbl_func.Text = nx_widestr(util_text("ui_eight_school_func_" .. task_id))
    lbl_prize.Text = nx_widestr(util_text("ui_eight_school_prize_" .. task_id))
    lbl_time.Text = nx_widestr(util_text("ui_eight_school_time_" .. task_id))
    lbl_round.Text = nx_widestr(nx_string(cur_round) .. "/" .. nx_string(max_round))
    mltbox_accept.HtmlText = util_text("ui_eight_school_accept_" .. task_id)
    btn_one_key.Text = util_text("ui_onekeyfinish")
    nx_bind_script(btn_one_key, nx_current())
    nx_callback(btn_one_key, "on_click", "on_btn_one_key_click")
    nx_bind_script(cbtn_sel, nx_current())
    nx_callback(cbtn_sel, "on_checked_changed", "on_cbtn_sel_checked_changed")
    form.textgrid_task:SetGridControl(row, 0, gbox_task)
    nx_set_custom(form, "btn_one_key_" .. task_id, btn_one_key)
    nx_set_custom(form, "lbl_round_" .. task_id, lbl_round)
    nx_set_custom(form, "cbtn_sel_" .. task_id, cbtn_sel)
    btn_one_key.task_id = task_id
    btn_one_key.price = price
    btn_one_key.Enabled = 0 < price
    btn_one_key.Visible = nx_int(one_key) == nx_int(1)
    if i == 1 then
      form.mltbox_task_info.HtmlText = util_text("ui_eight_school_task_info_" .. nx_string(task_id))
    end
    nx_execute("custom_sender", "custom_send_query_round_task", nx_int(2), nx_int(task_id))
  end
  form.textgrid_task:EndUpdate()
end
function on_btn_one_key_click(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  if not nx_find_custom(self, "task_id") or not nx_find_custom(self, "price") then
    return false
  end
  local task_id = self.task_id
  local price = self.price
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local text = gui.TextManager:GetFormatText("ui_yijianwancheng_tips", nx_int(ding), nx_int(liang), nx_int(wen), util_text("ui_eight_school_func_" .. task_id))
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return false
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return false
  end
  nx_execute("custom_sender", "send_task_msg", nx_int(12), nx_int(task_id))
end
function on_cbtn_sel_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == false then
    return false
  end
  local rows = form.textgrid_task.RowCount
  for i = 0, rows - 1 do
    local task_child = form.textgrid_task:GetGridTag(i, 0)
    if nx_is_valid(task_child) then
      local cbtn_sel = nx_custom(form, "cbtn_sel_" .. task_child.task_id)
      if nx_is_valid(cbtn_sel) then
        if not nx_id_equal(self, cbtn_sel) then
          cbtn_sel.Checked = false
        else
          form.mltbox_task_info.HtmlText = util_text("ui_eight_school_task_info_" .. task_child.task_id)
        end
      end
    end
  end
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
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
