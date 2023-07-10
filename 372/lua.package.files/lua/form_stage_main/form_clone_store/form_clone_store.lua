require("share\\itemtype_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.cool_time = 0
  form.work_time = 0
  form.work_tick_count = 0
  form.punish_tick_count = 0
end
function on_main_form_open(form)
  on_gui_size_change()
  set_control_relation(form)
  form.lbl_punish.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  local title = gui.TextManager:GetText("str_tishi")
  local content = gui.TextManager:GetText("ui_clonestore_exit")
  local res = util_form_confirm(title, content, MB_OKCANCEL, true)
  if res == "cancel" then
    return
  end
  if nx_is_valid(form) then
    form:Close()
  end
  nx_execute("custom_sender", "custom_clonestore_purchase", -1, "")
end
function on_btn_click(btn)
  local form = btn.ParentForm
  local groupbox = btn.Parent
  local pos = nx_int(groupbox.imggrid.item_pos)
  local config_id = nx_string(groupbox.imggrid.config_id)
  if nx_int(pos) >= nx_int(0) and nx_string(config_id) ~= nx_string("") then
    if is_limit_mouse() then
      return
    end
    nx_execute("custom_sender", "custom_clonestore_purchase", pos, config_id)
  end
end
function on_imagegrid_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_find_custom(grid, "config_id") then
    return
  end
  local config_id = grid.config_id
  if nx_string(config_id) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", config_id, x, y, form)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_gui_size_change()
  local form = nx_value("form_stage_main\\form_clone_store\\form_clone_store")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function set_control_relation(form)
  form.groupbox_1.lblname = form.lbl_equipname1
  form.groupbox_1.imggrid = form.imagegrid_icon1
  form.groupbox_1.lblcool = form.lbl_cooldown1
  form.groupbox_1.mbmoney = form.mltbox_money1
  form.imagegrid_icon1.item_pos = -1
  form.imagegrid_icon1.config_id = ""
  form.lbl_cooldown1.deftop = form.lbl_cooldown1.Top
  form.lbl_cooldown1.defheight = form.lbl_cooldown1.Height
  form.groupbox_2.lblname = form.lbl_equipname2
  form.groupbox_2.imggrid = form.imagegrid_icon2
  form.groupbox_2.lblcool = form.lbl_cooldown2
  form.groupbox_2.mbmoney = form.mltbox_money2
  form.imagegrid_icon2.item_pos = -1
  form.imagegrid_icon2.config_id = ""
  form.lbl_cooldown2.deftop = form.lbl_cooldown2.Top
  form.lbl_cooldown2.defheight = form.lbl_cooldown2.Height
  form.groupbox_3.lblname = form.lbl_equipname3
  form.groupbox_3.imggrid = form.imagegrid_icon3
  form.groupbox_3.lblcool = form.lbl_cooldown3
  form.groupbox_3.mbmoney = form.mltbox_money3
  form.imagegrid_icon3.item_pos = -1
  form.imagegrid_icon3.config_id = ""
  form.lbl_cooldown3.deftop = form.lbl_cooldown3.Top
  form.lbl_cooldown3.defheight = form.lbl_cooldown3.Height
end
function update_store_goods(form, cool_time, work_time, ...)
  local gui = nx_value("gui")
  form.cool_time = cool_time
  form.work_time = work_time
  local goods_num = table.getn(arg) / 3
  if goods_num <= 0 then
    return
  end
  form.groupbox_1.Visible = 1 <= goods_num
  form.groupbox_2.Visible = 2 <= goods_num
  form.groupbox_3.Visible = 3 <= goods_num
  form.lbl_work_time.Text = nx_widestr(work_time)
  for i = 1, goods_num do
    local goods_pos = nx_number(arg[3 * i - 2])
    local goods_configid = nx_string(arg[3 * i - 1])
    local goods_price = nx_number(arg[3 * i])
    local groupbox = get_groupbox(form, i)
    if nx_is_valid(groupbox) then
      local name = nx_widestr(gui.TextManager:GetText(goods_configid))
      groupbox.lblname.Text = name
      local photo = get_photo(goods_configid)
      groupbox.imggrid:AddItem(0, photo, name, 1, -1)
      groupbox.imggrid.item_pos = goods_pos
      groupbox.imggrid.config_id = goods_configid
      groupbox.mbmoney.HtmlText = get_price_content(goods_price)
    end
  end
  reset_all_cool_timer(form, cool_time)
end
function update_selled_goods(form, pos, configid)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 3 do
    local groupbox = get_groupbox(form, i)
    if nx_is_valid(groupbox) and nx_int(groupbox.imggrid.item_pos) == nx_int(pos) and nx_string(groupbox.imggrid.config_id) == nx_string(configid) then
      groupbox.lblname.Text = nx_widestr("")
      groupbox.imggrid:DelItem(0)
      groupbox.mbmoney.HtmlText = nx_widestr("")
      groupbox.imggrid.item_pos = -1
      groupbox.imggrid.config_id = ""
      return
    end
  end
end
function refresh_current_cooling(form, cool_time, ...)
  if not nx_is_valid(form) then
    return
  end
  local goods_num = table.getn(arg) / 2
  if goods_num <= 0 then
    return
  end
  form.cool_time = cool_time
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_work_timer_update", form)
  end
  form.lbl_work_time.Text = nx_widestr(form.work_time)
  for i = 1, goods_num do
    local goods_pos = nx_number(arg[2 * i - 1])
    local goods_configid = nx_string(arg[2 * i])
    for j = 1, 3 do
      local groupbox = get_groupbox(form, j)
      if nx_int(groupbox.imggrid.item_pos) == nx_int(goods_pos) and nx_string(groupbox.imggrid.config_id) == nx_string(goods_configid) then
        reset_cool_timer(groupbox, cool_time)
      end
    end
  end
end
function update_punish_time(form, punish_time)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_punish.Visible = true
  reset_punish_timer(form, punish_time)
end
function get_groupbox(form, index)
  if nx_int(index) == nx_int(1) then
    return form.groupbox_1
  elseif nx_int(index) == nx_int(2) then
    return form.groupbox_2
  elseif nx_int(index) == nx_int(3) then
    return form.groupbox_3
  end
  return nil
end
function get_photo(config_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("ItemType"))
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local sex = client_player:QueryProp("Sex")
  if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  return photo
end
function get_price_content(price)
  local gui = nx_value("gui")
  local price = nx_number(price)
  local ding = nx_int(price / 1000000)
  local liang = nx_int((price - ding * 1000 * 1000) / 1000)
  local wen = nx_int(price - ding * 1000 * 1000 - liang * 1000)
  local str_money = nx_widestr("")
  if ding ~= nx_int(0) then
    str_money = str_money .. nx_widestr(gui.TextManager:GetFormatText("ui_money_ding", ding))
  end
  if liang ~= nx_int(0) then
    str_money = str_money .. nx_widestr(gui.TextManager:GetFormatText("ui_money_liang", liang))
  end
  if wen ~= nx_int(0) then
    str_money = str_money .. nx_widestr(gui.TextManager:GetFormatText("ui_money_wen", wen))
  end
  gui.TextManager:Format_SetIDName("ui_clonestore_price")
  gui.TextManager:Format_AddParam(str_money)
  return nx_widestr(gui.TextManager:Format_GetText())
end
function is_limit_mouse()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_time = os.time()
  if nx_find_custom(client_player, "lastclonestorebuytick") and os.difftime(cur_time, client_player.lastclonestorebuytick) <= 1 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8957"))
    return
  end
  client_player.lastclonestorebuytick = cur_time
end
function clear_mouse_limit()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  util_remove_custom(client_player, "lastclonestorebuytick")
end
function reset_all_cool_timer(form, count)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_work_timer_update", form)
  end
  reset_cool_timer(form.groupbox_1, count)
  reset_cool_timer(form.groupbox_2, count)
  reset_cool_timer(form.groupbox_3, count)
end
function reset_cool_timer(groupbox, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox.cool_tick_count = nx_number(count)
  groupbox.lblcool.Visible = true
  groupbox.lblcool.Top = groupbox.lblcool.deftop
  groupbox.lblcool.Height = groupbox.lblcool.defheight
  timer:UnRegister(nx_current(), "on_cool_timer_update", groupbox)
  timer:Register(1000, -1, nx_current(), "on_cool_timer_update", groupbox, -1, -1)
end
function on_cool_timer_update(groupbox, param1, param2)
  local form = groupbox.ParentForm
  groupbox.cool_tick_count = groupbox.cool_tick_count - 1
  if groupbox.cool_tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_cool_timer_update", groupbox)
    end
    groupbox.lblcool.Visible = false
    reset_work_timer(form, form.work_time)
  else
    update_cooldown(groupbox.lblcool)
  end
end
function update_cooldown(lbl)
  if not nx_is_valid(lbl) then
    return
  end
  local form = lbl.ParentForm
  local groupbox = lbl.Parent
  local offset = lbl.defheight / form.cool_time
  local height = groupbox.cool_tick_count * offset
  local bottom = lbl.Top + lbl.Height
  lbl.Top = bottom - nx_int(height)
  lbl.Height = nx_int(height)
end
function reset_work_timer(form, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.work_tick_count = nx_number(count)
  timer:UnRegister(nx_current(), "on_work_timer_update", form)
  timer:Register(1000, -1, nx_current(), "on_work_timer_update", form, -1, -1)
end
function on_work_timer_update(form, param1, param2)
  form.work_tick_count = form.work_tick_count - 1
  if form.work_tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_work_timer_update", form)
    end
    form.lbl_work_time.Text = nx_widestr("0")
  else
    form.lbl_work_time.Text = nx_widestr(form.work_tick_count)
  end
end
function reset_punish_timer(form, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.punish_tick_count = nx_number(count)
  timer:UnRegister(nx_current(), "on_punish_time_update", form)
  timer:Register(1000, -1, nx_current(), "on_punish_time_update", form, -1, -1)
end
function on_punish_time_update(form, param1, param2)
  form.punish_tick_count = form.punish_tick_count - 1
  if form.punish_tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_punish_time_update", form)
    end
    form.lbl_punish.Visible = false
  else
  end
end
