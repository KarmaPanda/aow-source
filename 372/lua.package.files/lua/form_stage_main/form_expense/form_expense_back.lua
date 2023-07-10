require("util_gui")
require("form_stage_main\\switch\\switch_define")
require("form_stage_main\\form_expense\\form_expense_define")
function open_form()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_SNDA_ACTIVITY_CONSUME_BACK) then
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "open_form", G_FORM_CONSUME_BACK_MAIN)
  end
end
function on_main_form_init(form)
  form.Fixed = true
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local mgr = nx_value("ConsumeBackModule")
  if not nx_is_valid(mgr) then
    mgr = nx_create("ConsumeBackModule")
    nx_set_value("ConsumeBackModule", mgr)
  end
end
function on_main_form_open(form)
  init_prize_controls(form)
  lua_sendmsg_to_server(G_CBM_QUERY)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function init_prize_controls(form)
  local w, h = form.groupbox_prizeinfo.Width / G_PRIZE_ITEM_COLS, form.groupbox_prizeinfo.Height / G_PRIZE_ITEM_ROWS
  for i = 1, G_PRIZE_ITEM_ROWS do
    for j = 1, G_PRIZE_ITEM_COLS do
      local index = (i - 1) * G_PRIZE_ITEM_ROWS + j
      local control = util_get_form(G_FORM_CONSUME_BACK_PRIZE, true, false, nx_string(index))
      form.groupbox_prizeinfo:Add(control)
      control.Fixed, control.Left, control.Top = true, (j - 1) * w, (i - 1) * h
      nx_set_custom(form, "item_prize_info" .. nx_string(index), control)
      control.Visible = true
    end
  end
end
function refresh_back_info(form, mgr)
  for i = 1, G_PRIZE_ITEM_ROWS do
    for j = 1, G_PRIZE_ITEM_COLS do
      local index = (i - 1) * G_PRIZE_ITEM_ROWS + j
      local amount, prize_status, can_prize, consume_day, year, mon, day = mgr:GetBackInfo(index)
      local control = nx_custom(form, "item_prize_info" .. nx_string(index))
      set_control_info(index, control, amount, prize_status, can_prize, consume_day, year, mon, day)
    end
  end
  local s = mgr:GetConsumeTime()
  local var = util_split_string(s, ",")
  for i, item in pairs(var) do
    var[i] = nx_number(var[i])
  end
  if table.getn(var) > 8 then
    var[1] = nx_int(100 / nx_number(var[1]))
    form.mltbox_text01.HtmlText = util_format_string("expense_back_03", unpack(var))
  end
end
function set_control_info(index, control, amount, prize_status, can_prize, consume_day, year, mon, day)
  if not nx_is_valid(control) then
    return
  end
  nx_set_custom(control, "consume_index", index)
  local item_status = control.lbl_status
  local item_value = control.lbl_back_value
  local item_day = control.lbl_index
  local item_box = control.btn_box
  item_status.Visible = prize_status == G_CBS_TAKED
  item_box.Enabled = 0 < amount and prize_status ~= G_CBS_TAKED and can_prize == 1
  item_day.Text = util_format_string("expense_back_05", mon, day)
  if 0 < amount then
    item_value.Text = util_format_string("expense_back_04", amount)
  elseif prize_status == G_CBS_TAKED then
    item_value.Text = util_format_string("expense_back_06")
  else
    item_value.Text = util_format_string("expense_back_07")
  end
  function set_btn_bg(btn, on, out, down)
    local path = "gui\\special\\expense\\"
    if out == "fanlibaoxiang02" then
      btn.NormalImage = out
    else
      btn.NormalImage = path .. out .. ".png"
    end
    btn.FocusImage = path .. on .. ".png"
    btn.PushImage = path .. down .. ".png"
  end
  if prize_status == G_CBS_TAKED then
    set_btn_bg(item_box, "bd01_down_2", "bd01_down_2", "bd01_down_2")
  elseif 0 < amount then
    if can_prize == 1 then
      set_btn_bg(item_box, "bd01_down", "fanlibaoxiang02", "bd01_down")
    else
      set_btn_bg(item_box, "box_down", "box_out", "box_on")
      item_box.Enabled = true
    end
  else
    set_btn_bg(item_box, "bd01_out", "bd01_out", "bd01_out")
  end
end
function on_server_msg(...)
  local cmd = nx_number(arg[1])
  if cmd == G_CBM_QUERY then
    local info = nx_string(arg[2])
    local mgr = nx_value("ConsumeBackModule")
    if not nx_is_valid(mgr) then
      return
    end
    local form = nx_value(G_FORM_CONSUME_BACK_MAIN)
    if not nx_is_valid(form) then
      return
    end
    mgr:InitConsumeBackInfo(info)
    refresh_back_info(form, mgr)
  end
end
