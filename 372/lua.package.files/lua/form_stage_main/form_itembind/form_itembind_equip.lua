require("share\\view_define")
function main_form_init(self)
  self.Fixed = false
  self.view_id = 0
  self.item_index = 0
  self.left_time = 60
  self.equip_grid = nx_null()
  self.src_viewid = 0
end
function on_main_form_open(form)
  form.left_time = 60
  if nx_running(nx_current(), "form_equip_tick") then
    nx_kill(nx_current(), "form_equip_tick")
  end
  nx_execute(nx_current(), "form_equip_tick")
end
function on_main_form_close(form)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  if nx_running(nx_current(), "form_equip_tick") then
    nx_kill(nx_current(), "form_equip_tick")
  end
  nx_destroy(form)
end
function on_btn_bind_ok_click(btn)
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  local form = btn.ParentForm
  if nx_is_valid(form) then
    if nx_is_valid(form.equip_grid) then
      goodsgrid:ViewGridOnSelectItem(form.equip_grid, -1)
    else
      goodsgrid:ViewUseItem(form.src_viewid, form.item_index, nx_null(), -1)
    end
    form:Close()
  end
end
function on_btn_bind_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function form_equip_tick()
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
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
  local form = nx_value("form_stage_main\\form_itembind\\form_itembind_equip")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local view_id = nx_int(0)
  local view_pos = nx_int(0)
  if nx_is_valid(form.equip_grid) then
    view_id = nx_int(gui.GameHand.Para1)
    view_pos = nx_int(gui.GameHand.Para2)
  else
    view_id = nx_int(form.src_viewid)
    view_pos = nx_int(form.item_index)
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(view_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  local viewobj_name = gui.TextManager:GetText(viewobj:QueryProp("ConfigID"))
  gui.TextManager:Format_SetIDName("1312")
  gui.TextManager:Format_AddParam(viewobj_name)
  local text = gui.TextManager:Format_GetText()
  form.lbl_info.HtmlText = nx_widestr(text)
end
