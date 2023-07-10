function main_form_init(self)
  self.Fixed = false
  self.view_id = 0
  self.item_index = 0
  self.left_time = 60
end
function on_main_form_open(form)
  form.left_time = 60
  if nx_running(nx_current(), "form_pickup_tick") then
    nx_kill(nx_current(), "form_pickup_tick")
  end
  set_form_showinfo()
  nx_execute(nx_current(), "form_pickup_tick")
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_pickup_tick") then
    nx_kill(nx_current(), "form_pickup_tick")
  end
  nx_destroy(form)
end
function on_btn_bind_ok_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("custom_sender", "custom_pickup_single_item", form.item_index)
    form:Close()
  end
end
function on_btn_bind_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function form_pickup_tick()
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_pickup")
  while true do
    local step_time = nx_pause(1)
    if not nx_is_valid(form) then
      break
    end
    form.left_time = form.left_time - step_time
    if nx_int(form.left_time) < nx_int(0) then
      form:Close()
      break
    end
  end
end
function set_form_showinfo()
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_pickup")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(form.view_id))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(form.item_index))
  if not nx_is_valid(viewobj) then
    return
  end
  local gui = nx_value("gui")
  local viewobj_name = gui.TextManager:GetText(viewobj:QueryProp("ConfigID"))
  gui.TextManager:Format_SetIDName("1313")
  gui.TextManager:Format_AddParam(viewobj_name)
  local text = gui.TextManager:Format_GetText()
  form.lbl_info.HtmlText = nx_widestr(text)
end
