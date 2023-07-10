require("share\\itemtype_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.tick_count = 0
  form.item_array_data = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.ipt_ding.Text = nx_widestr("0")
  form.ipt_liang.Text = nx_widestr("0")
  form.ipt_wen.Text = nx_widestr("0")
  init_baseprice(form)
  init_imagegrid(form)
  reset_timer(form, 30)
end
function on_main_form_close(form)
  if nx_is_valid(form.item_array_data) then
    nx_destroy(form.item_array_data)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  on_btn_cancel_click(btn)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_ipt_changed(ipt)
  if nx_string(ipt.Text) == "-" then
    ipt.Text = nx_widestr("0")
    return
  end
  local text = nx_string(ipt.Text)
  local value = nx_number(text)
  if value < 0 then
    ipt.Text = nx_widestr("0")
    return
  elseif 1000 <= value then
    text = string.sub(text, 1, string.len(text) - 1)
    ipt.Text = nx_widestr(text)
    ipt.InputPos = nx_ws_length(ipt.Text)
    return
  end
  _, count = string.gsub(text, "[.]", ".")
  if 1 <= count then
    text = string.sub(text, 1, string.len(text) - 1)
    ipt.Text = nx_widestr(text)
    ipt.InputPos = nx_ws_length(ipt.Text)
  end
end
function on_imagegrid_goods_mousein_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "show_goods_tip", form.item_array_data, grid.AbsLeft + grid.Width, grid.AbsTop, grid.Width, grid.Height, form)
end
function on_imagegrid_goods_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local ding = 0
  if not nx_ws_equal(nx_widestr(form.ipt_ding.Text), nx_widestr("")) then
    ding = nx_number(form.ipt_ding.Text) * 1000 * 1000
  end
  local liang = 0
  if not nx_ws_equal(nx_widestr(form.ipt_liang.Text), nx_widestr("")) then
    liang = nx_number(form.ipt_liang.Text) * 1000
  end
  local wen = 0
  if not nx_ws_equal(nx_widestr(form.ipt_wen.Text), nx_widestr("")) then
    wen = nx_number(form.ipt_wen.Text)
  end
  nx_execute("custom_sender", "custom_compete_item_result", form.item, ding + liang + wen)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  nx_execute("custom_sender", "custom_compete_item_result", form.item, -1)
end
function init_baseprice(form)
  local gui = nx_value("gui")
  local base_price = nx_number(form.base_price)
  local ding = nx_int(base_price / 1000000)
  local liang = nx_int((base_price - ding * 1000 * 1000) / 1000)
  local wen = nx_int(base_price - ding * 1000 * 1000 - liang * 1000)
  gui.TextManager:Format_SetIDName("ui_baseprice")
  gui.TextManager:Format_AddParam(ding)
  gui.TextManager:Format_AddParam(liang)
  gui.TextManager:Format_AddParam(wen)
  form.mltbox_baseprice.HtmlText = gui.TextManager:Format_GetText()
end
function init_imagegrid(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  local xmldoc = nx_create("XmlDocument")
  if not xmldoc:ParseXmlData(form.item_info, 1) then
    return
  end
  local xmlroot = xmldoc.RootElement
  local xmlelement = xmlroot:GetChildByIndex(0)
  form.item_array_data = nx_call("util_gui", "get_arraylist", "compete:" .. nx_string(form.item))
  for i = 0, xmlelement:GetAttrCount() - 1 do
    local name = xmlelement:GetAttrName(i)
    local value = xmlelement:GetAttrValue(i)
    nx_set_custom(form.item_array_data, name, value)
  end
  nx_destroy(xmldoc)
  local config_id = nx_custom(form.item_array_data, "ConfigID")
  local item_type = nx_custom(form.item_array_data, "ItemType")
  local color_level = nx_custom(form.item_array_data, "ColorLevel")
  local photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "Photo"))
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local equip_type = ""
  if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX then
    equip_type = item_query:GetItemPropByConfigID(config_id, "EquipType")
  end
  local sex = client_palyer:QueryProp("Sex")
  if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and 0 ~= sex then
    local tmp_photo = nx_string(nx_execute("util_static_data", "item_query_ArtPack_by_id", config_id, "FemalePhoto"))
    if nil ~= tmp_photo and "" ~= tmp_photo then
      photo = tmp_photo
    end
  end
  local item_back_image = get_grid_treasure_back_image(equip_type, color_level)
  form.imagegrid_goods:AddItemEx(0, photo, nx_widestr(nx_string(name)), form.amount, -1, item_back_image)
  form.lbl_goodsname.Text = gui.TextManager:GetText(nx_custom(form.item_array_data, "ConfigID"))
end
function reset_timer(form, count)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  form.lbl_tick.Text = nx_widestr(count)
  form.tick_count = nx_number(count)
  timer:UnRegister(nx_current(), "on_timer_update", form)
  timer:Register(1000, -1, nx_current(), "on_timer_update", form, -1, -1)
end
function on_timer_update(form, param1, param2)
  form.tick_count = form.tick_count - 1
  if form.tick_count == 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_timer_update", form)
      form:Close()
    end
  else
    form.lbl_tick.Text = nx_widestr(form.tick_count)
  end
end
function add_log_content(form, msg)
  if not nx_is_valid(form) then
    return
  end
  local mltbox_list = form.mltbox_notes
  if nx_is_valid(mltbox_list) then
    mltbox_list:AddHtmlText(nx_widestr(msg), -1)
    mltbox_list.VScrollBar.Value = mltbox_list.VScrollBar.Maximum
  end
end
function append_bidden_msg(form, player_name, money)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local money = nx_number(money)
  local ding = nx_int(money / 1000000)
  local liang = nx_int((money - ding * 1000 * 1000) / 1000)
  local wen = nx_int(money - ding * 1000 * 1000 - liang * 1000)
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
  local Time = os.date("*t", os.time())
  local str_time = string.format("%02d:%02d:%02d", Time.hour, Time.min, Time.sec)
  gui.TextManager:Format_SetIDName("ui_bidden_msg")
  gui.TextManager:Format_AddParam(str_time)
  gui.TextManager:Format_AddParam(player_name)
  gui.TextManager:Format_AddParam(str_money)
  local msg = gui.TextManager:Format_GetText()
  add_log_content(form, msg)
  gui.TextManager:Format_SetIDName("ui_cur_max_bidden")
  gui.TextManager:Format_AddParam(str_money)
  gui.TextManager:Format_AddParam(player_name)
  form.mltbox_biddeninfo.HtmlText = gui.TextManager:Format_GetText()
  reset_timer(form, 10)
end
function append_abandon_msg(form, player_name)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local Time = os.date("*t", os.time())
  local str_time = string.format("%02d:%02d:%02d", Time.hour, Time.min, Time.sec)
  gui.TextManager:Format_SetIDName("ui_abandon_msg")
  gui.TextManager:Format_AddParam(str_time)
  gui.TextManager:Format_AddParam(player_name)
  local msg = gui.TextManager:Format_GetText()
  add_log_content(form, msg)
end
