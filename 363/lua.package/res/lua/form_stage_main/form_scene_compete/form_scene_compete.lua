require("share\\itemtype_define")
require("util_functions")
require("form_stage_main\\form_scene_compete\\util_scene_compete_define")
function main_form_init(form)
  form.Fixed = false
  form.item_array_data = nil
end
function on_main_form_open(form)
  change_form_size()
  update_timer(form)
  init_imagegrid(form)
  init_base_price(form)
  init_cur_price(form)
  init_offerprice(form)
  init_form_desc(form)
  update_meicon(form, form.owner_name)
  form.btn_yikoujia.Visible = nx_int(form.super_price) > nx_int(0)
end
function on_main_form_close(form)
  if nx_is_valid(form.item_array_data) then
    nx_destroy(form.item_array_data)
  end
  nx_destroy(form)
end
function reset_scene()
  local form = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_yikoujia_click(btn)
  local form = btn.ParentForm
  local super_price = nx_number(form.super_price)
  if nx_int(super_price) <= nx_int(0) then
    return
  end
  local ding = nx_int(super_price / 1000000)
  local liang = nx_int((super_price - ding * 1000 * 1000) / 1000)
  local wen = nx_int(super_price - ding * 1000 * 1000 - liang * 1000)
  form.ipt_ding.Text = nx_widestr(ding)
  form.ipt_liang.Text = nx_widestr(liang)
  form.ipt_wen.Text = nx_widestr(wen)
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
  local money = ding + liang + wen
  nx_execute("custom_sender", "custom_send_scene_compete_msg", nx_int(OP_SCENE_COMPETE_OFFERPRICE), nx_int(money))
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
function on_imagegrid_goods_mousein_grid(grid)
  local form = grid.ParentForm
  nx_execute("tips_game", "show_goods_tip", form.item_array_data, grid.AbsLeft + grid.Width, grid.AbsTop, grid.Width, grid.Height, form)
end
function on_imagegrid_goods_mouseout_grid(grid)
  local form = grid.ParentForm
  nx_execute("tips_game", "hide_tip", form)
end
function open_form(...)
  local form = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if nx_is_valid(form) then
    form.Visible = true
  else
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_scene_compete\\form_scene_compete", true, false)
    if not nx_is_valid(form) then
      return
    end
  end
  form.item_info = nx_string(arg[1])
  form.amount = nx_number(arg[2])
  form.owner_name = nx_widestr(arg[3])
  form.cur_price = nx_number(arg[4])
  form.tick_count = nx_number(arg[5])
  form.base_price = nx_number(arg[6])
  form.super_price = nx_number(arg[7])
  form.isviewer = nx_int(arg[8]) == nx_int(1)
  form.desc_id = nx_string(arg[9])
  form:Show()
end
function close_form()
  local form = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_base_price(form)
  local base_price = nx_number(form.base_price)
  local ding = nx_int(base_price / 1000000)
  local liang = nx_int((base_price - ding * 1000 * 1000) / 1000)
  local wen = nx_int(base_price - ding * 1000 * 1000 - liang * 1000)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_baseprice2")
  gui.TextManager:Format_AddParam(ding)
  gui.TextManager:Format_AddParam(liang)
  gui.TextManager:Format_AddParam(wen)
  form.mltbox_baseprice.HtmlText = gui.TextManager:Format_GetText()
end
function init_cur_price(form)
  local base_price = nx_number(form.cur_price)
  local ding = nx_int(base_price / 1000000)
  local liang = nx_int((base_price - ding * 1000 * 1000) / 1000)
  local wen = nx_int(base_price - ding * 1000 * 1000 - liang * 1000)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_curprice2")
  gui.TextManager:Format_AddParam(ding)
  gui.TextManager:Format_AddParam(liang)
  gui.TextManager:Format_AddParam(wen)
  form.mltbox_curprice.HtmlText = gui.TextManager:Format_GetText()
end
function init_offerprice(form)
  form.ipt_ding.Text = nx_widestr("0")
  form.ipt_liang.Text = nx_widestr("0")
  form.ipt_wen.Text = nx_widestr("0")
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
  form.item_array_data = nx_call("util_gui", "get_arraylist", "scene_compete_item_show")
  get_arraylist_by_parse_xmldata(form.item_info, form.item_array_data)
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
function init_form_desc(form)
  local gui = nx_value("gui")
  if not nx_find_custom(form, "desc_id") or nx_string(form.desc_id) == "" then
    form.desc_id = "scene_compete_default_desc"
  end
  form.mltbox_notes.HtmlText = nx_widestr(gui.TextManager:GetText(nx_string(form.desc_id)))
end
function update_timer(form)
  local bShowTick = nx_int(form.tick_count) > nx_int(0)
  form.groupbox_tick.Visible = bShowTick
  if bShowTick then
    form.lbl_tick.Text = nx_widestr(form.tick_count)
    local timer = nx_value("timer_game")
    if not nx_is_valid(timer) then
      return
    end
    timer:UnRegister(nx_current(), "on_timer_update", form)
    timer:Register(1000, -1, nx_current(), "on_timer_update", form, -1, -1)
  end
end
function on_timer_update(form, param1, param2)
  form.tick_count = form.tick_count - 1
  if form.tick_count <= 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_timer_update", form)
    end
  else
    form.lbl_tick.Text = nx_widestr(form.tick_count)
  end
end
function on_player_offer_item(player_name, money, tick_count)
  local form = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if not nx_is_valid(form) then
    return
  end
  update_meicon(form, player_name)
  local money = nx_number(money)
  local ding = nx_int(money / 1000000)
  local liang = nx_int((money - ding * 1000 * 1000) / 1000)
  local wen = nx_int(money - ding * 1000 * 1000 - liang * 1000)
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_curprice2")
  gui.TextManager:Format_AddParam(ding)
  gui.TextManager:Format_AddParam(liang)
  gui.TextManager:Format_AddParam(wen)
  form.mltbox_curprice.HtmlText = gui.TextManager:Format_GetText()
  form.tick_count = tick_count
  update_timer(form)
end
function update_meicon(form, player_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  local self_name = client_palyer:QueryProp("Name")
  if nx_ws_equal(nx_widestr(player_name), nx_widestr(self_name)) then
    form.lbl_me.Visible = true
  else
    form.lbl_me.Visible = false
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_scene_compete\\form_scene_compete")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
