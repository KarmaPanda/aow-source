require("util_functions")
require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  bind_call_back(self)
  set_netbar_info(self)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function bind_call_back(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("NetBarDayPrize", "int", form, "form_stage_main\\form_netbar\\form_netbar_woniu", "on_netbar_changed")
  end
end
function on_netbar_changed(form)
  set_netbar_info(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function set_netbar_info(form)
  form.groupbox_gold.Visible = false
  form.groupbox_silver.Visible = false
  form.groupbox_diamond.Visible = false
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local right_level = client_player:QueryProp("NetBarRight")
  if right_level == 1 then
    show_silver_info(form, right_level)
  elseif right_level == 2 then
    show_gold_info(form, right_level)
  elseif right_level == 3 then
    show_diamond_info(form, right_level)
  end
end
function show_normal_info(form, right_level)
  form.groupbox_normal.Visible = true
end
function show_silver_info(form, right_level)
  form.groupbox_silver.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local now_time = os.time()
  local now_date = os.date("*t", now_time)
  local format_date = now_date.year * 10000 + now_date.month * 100 + now_date.day
  local last_date = client_player:QueryProp("NetBarDayPrize")
  if format_date <= last_date then
    form.btn_silver_can_2.Visible = false
    form.btn_silver_cant_2.Visible = true
  else
    form.btn_silver_can_2.Visible = true
    form.btn_silver_cant_2.Visible = false
  end
  form.btn_silver_can_2.Visible = true
  form.btn_silver_cant_2.Visible = false
end
function show_gold_info(form, right_level)
  form.groupbox_gold.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local now_time = os.time()
  local now_date = os.date("*t", now_time)
  local format_date = now_date.year * 10000 + now_date.month * 100 + now_date.day
  local last_date = client_player:QueryProp("NetBarDayPrize")
  if format_date <= last_date then
    form.btn_gold_can_2.Visible = false
    form.btn_gold_cant_2.Visible = true
  else
    form.btn_gold_can_2.Visible = true
    form.btn_gold_cant_2.Visible = false
  end
  form.btn_gold_can_2.Visible = true
  form.btn_gold_cant_2.Visible = false
end
function show_diamond_info(form, right_level)
  form.groupbox_diamond.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local now_time = os.time()
  local now_date = os.date("*t", now_time)
  local format_date = now_date.year * 10000 + now_date.month * 100 + now_date.day
  local last_date = client_player:QueryProp("NetBarDayPrize")
  if format_date <= last_date then
    form.btn_diamond_can_2.Visible = false
    form.btn_diamond_cant_2.Visible = true
  else
    form.btn_diamond_can_2.Visible = true
    form.btn_diamond_cant_2.Visible = false
  end
  form.btn_diamond_can_2.Visible = true
  form.btn_diamond_cant_2.Visible = false
end
function on_btn_day_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NETBAR_GET_RPIZE), 0)
end
function on_btn_update_click(btn)
  util_show_form("form_stage_main\\form_netbar\\form_netbar_update_rule", true)
end
