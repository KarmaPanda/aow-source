require("util_gui")
require("form_stage_main\\form_expense\\form_expense_define")
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  nx_set_custom(form, "consume_index", -1)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  return 1
end
function on_take_prize_click(btn)
  local form = btn.ParentForm
  local index = nx_custom(form, "consume_index")
  if index < 1 then
    return
  end
  local mgr = nx_value("ConsumeBackModule")
  if not nx_is_valid(mgr) then
    return
  end
  local amount, prize_status, can_prize, consume_day = mgr:GetBackInfo(index)
  if amount == nil then
    lua_sysinfo("30069")
    return
  end
  if prize_status == G_CBS_TAKED then
    lua_sysinfo("30070")
    return
  end
  if nx_number(amount) <= 0 then
    lua_sysinfo("30069")
    return
  end
  if can_prize == 0 then
    local s = mgr:GetConsumeTime()
    local var = util_split_string(s, ",")
    for i, item in pairs(var) do
      var[i] = nx_number(var[i])
    end
    lua_sysinfo("30071", var[8], var[9], var[10], var[11], var[12], var[13])
    return
  end
  lua_sendmsg_to_server(G_CBM_TACK, consume_day)
end
