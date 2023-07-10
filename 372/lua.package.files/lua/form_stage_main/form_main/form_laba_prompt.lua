function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.Default = form.ok_btn
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CapitalType2", "int", form, nx_current(), "update_silver")
  databinder:AddRolePropertyBind("CapitalType4", "int", form, nx_current(), "update_bind_card")
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("CapitalType2", form)
  databinder:DelRolePropertyBind("CapitalType4", form)
  nx_destroy(form)
end
function on_ok_btn_click(btn)
  local form = btn.ParentForm
  if not second_word_unlock() then
    return
  end
  if not check_account(form) then
    return
  end
  nx_gen_event(form, "confirm_return", "ok")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cancel_btn_click(btn)
  local form = btn.ParentForm
  nx_gen_event(form, "confirm_return", "cancel")
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_silver(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(prop_name) == "CapitalType2" then
    local gold = nx_int(prop_value / 1000)
    if gold > nx_int(999999) then
      form.lbl_silver.Text = nx_widestr("999999...")
    else
      form.lbl_silver.Text = nx_widestr(gold)
    end
  end
end
function second_word_unlock()
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  local condition_manager = nx_value("ConditionManager")
  if nx_is_valid(condition_manager) then
    local b_ok = condition_manager:CanSatisfyCondition(player, player, 23600)
    if not b_ok then
      return true
    end
  end
  local is_have_second_word = nx_int(player:QueryProp("IsHaveSecondWord"))
  if is_have_second_word == nx_int(0) then
    nx_execute("custom_sender", "request_set_second_word")
    return false
  end
  local is_have_lock = nx_int(player:QueryProp("IsCheckPass"))
  if is_have_lock == nx_int(0) then
    nx_execute("form_stage_main\\from_word_protect\\form_protect_sure", "show_form_protect_sure")
    return false
  end
  return true
end
function check_account(form)
  local mgr = nx_value("CapitalModule")
  if not nx_is_valid(mgr) then
    return false
  end
  local gold = mgr:GetCapital(2)
  if form.groupbox_3.Visible then
    gold = mgr:GetCapital(4)
  end
  gold = nx_int(gold / 1000)
  if gold < nx_int(50) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "xiaolaba_ani_nomoney")
    return false
  end
  return true
end
function set_prompt(prompt, confirm_id, switch)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_laba_prompt", false, false, nx_string(confirm_id))
  if not nx_is_valid(form) then
    return
  end
  if 0 == switch then
    form.groupbox_3.Visible = false
    form.groupbox_2.Visible = true
  elseif 1 == switch then
    form.groupbox_2.Visible = false
    form.groupbox_3.Visible = true
  end
  form.mltbox_info:Clear()
  form.mltbox_info:AddHtmlText(nx_widestr(prompt), -1)
end
function update_bind_card(form)
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("CapitalModule")
  local gold = mgr:GetCapital(4)
  gold = nx_int(gold / 1000)
  if gold > nx_int(999999) then
    form.yinpiao_num.Text = nx_widestr("999999...")
  else
    form.yinpiao_num.Text = nx_widestr(gold)
  end
end
