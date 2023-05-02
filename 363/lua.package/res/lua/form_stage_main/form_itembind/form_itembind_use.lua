function main_form_init(self)
  self.Fixed = false
  self.view_id = 0
  self.item_index = 0
  self.left_time = 60
end
function on_main_form_open(form)
  form.left_time = 60
  if nx_running(nx_current(), "form_use_tick") then
    nx_kill(nx_current(), "form_use_tick")
  end
  nx_execute(nx_current(), "form_use_tick")
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_use_tick") then
    nx_kill(nx_current(), "form_use_tick")
  end
  nx_destroy(form)
end
function on_btn_bind_ok_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local goods_grid = nx_value("GoodsGrid")
    if not nx_is_valid(goods_grid) then
      return
    end
    goods_grid:ViewUseItem(form.view_id, form.item_index, nx_null(), -1)
    form:Close()
  end
end
function on_btn_bind_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function form_use_tick()
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
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
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_use")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_info.Text = nx_widestr(text)
end
