require("share\\itemtype_define")
require("util_functions")
local FORM_BASEPRICE = "form_stage_main\\form_compete\\form_baseprice"
local FORM_COMPETE = "form_stage_main\\form_compete\\form_compete"
CompeteItemTable = {}
CompeteShowTrack = {
  top = 0,
  mid = 0,
  bot = 0
}
function main_form_init(form)
  form.Fixed = false
  form.item_array_data = nil
end
function on_main_form_open(form)
  form.ipt_ding.Text = nx_widestr("0")
  form.ipt_liang.Text = nx_widestr("0")
  form.ipt_wen.Text = nx_widestr("0")
  init_imagegrid(form)
end
function on_main_form_close(form)
  reset_display_pos(form.dispos)
  if nx_is_valid(form.item_array_data) then
    nx_destroy(form.item_array_data)
  end
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local form_compete = nx_value(FORM_COMPETE .. nx_string(form.item))
  if nx_is_valid(form_compete) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("8948"))
    return
  end
  local ding = nx_string(form.ipt_ding.Text)
  local liang = nx_string(form.ipt_liang.Text)
  local wen = nx_string(form.ipt_wen.Text)
  ding = ding ~= "" and ding or "0"
  liang = liang ~= "" and liang or "0"
  wen = wen ~= "" and wen or "0"
  local dispos = form.dispos
  local item = form.item
  local mode = form.mode
  local money = nx_number(ding) * 1000 * 1000 + nx_number(liang) * 1000 + nx_number(wen)
  form:Close()
  send_setting_result(dispos, item, mode, money)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  local dispos = form.dispos
  local item = form.item
  local mode = form.mode
  form:Close()
  send_setting_result(dispos, item, mode, -1)
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
function on_imagegrid_icon_mousein_grid(grid, index)
  local form = grid.ParentForm
  nx_execute("tips_game", "show_goods_tip", form.item_array_data, grid.AbsLeft + grid.Width, grid.AbsTop, grid.Width, grid.Height, form)
end
function on_imagegrid_icon_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
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
  form.item_array_data = nx_call("util_gui", "get_arraylist", "baseprice:" .. nx_string(form.item))
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
  form.imagegrid_icon:AddItemEx(0, photo, nx_widestr(nx_string(name)), form.amount, -1, item_back_image)
end
function push_compete_item(item, item_info, amount, mode)
  local form_compete = nx_value(FORM_COMPETE .. nx_string(item))
  if nx_is_valid(form_compete) then
    return
  end
  local form = nx_value(FORM_BASEPRICE .. nx_string(item))
  if not nx_is_valid(form) then
    push_into_table(item, item_info, amount, mode)
    update_baseprice_show()
  else
    local dispos = form.dispos
    form:Close()
    create_baseprice_form(dispos, item, item_info, amount, mode)
  end
end
function update_baseprice_show()
  local dispos = get_display_pos()
  if dispos == -1 then
    return
  end
  local bhave, info = pop_from_table()
  if bhave then
    create_baseprice_form(dispos, info.item, info.item_info, info.amount, info.mode)
  end
end
function create_baseprice_form(dispos, item, item_info, amount, mode)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", FORM_BASEPRICE, true, false, nx_string(item))
  dialog.item = item
  dialog.item_info = item_info
  dialog.amount = amount
  dialog.mode = mode
  dialog.dispos = dispos
  dialog.Left = (gui.Width - dialog.Width) / 4
  dialog.Top = gui.Height / 1.5 - dialog.Height * dispos
  dialog:Show()
  set_display_pos(dispos)
end
function send_setting_result(dispos, item, mode, money)
  reset_display_pos(dispos)
  nx_execute("custom_sender", "custom_set_compete_baseprice", item, money, mode)
  update_baseprice_show()
end
function push_into_table(item, item_info, amount, mode)
  local count = table.getn(CompeteItemTable)
  for i = 1, count do
    local data = CompeteItemTable[i]
    if nx_string(item) == nx_string(data.item) and nx_string(item_info) == nx_string(data.item_info) and nx_int(amount) == nx_int(amount) and nx_int(mode) == nx_int(mode) then
      return
    end
  end
  local index = count + 1
  CompeteItemTable[index] = {
    item = item,
    item_info = item_info,
    amount = amount,
    mode = mode
  }
end
function pop_from_table()
  if table.getn(CompeteItemTable) <= 0 then
    return false, nil
  end
  local info = table.remove(CompeteItemTable, 1)
  return true, info
end
function set_display_pos(dispos)
  if nx_int(dispos) == nx_int(0) then
    CompeteShowTrack.top = 1
  elseif nx_int(dispos) == nx_int(1) then
    CompeteShowTrack.mid = 1
  elseif nx_int(dispos) == nx_int(2) then
    CompeteShowTrack.bot = 1
  else
    return false
  end
  return true
end
function reset_display_pos(dispos)
  if nx_int(dispos) == nx_int(0) then
    CompeteShowTrack.top = 0
  elseif nx_int(dispos) == nx_int(1) then
    CompeteShowTrack.mid = 0
  elseif nx_int(dispos) == nx_int(2) then
    CompeteShowTrack.bot = 0
  else
    return false
  end
  return true
end
function get_display_pos()
  if CompeteShowTrack.top == 0 then
    return 0
  end
  if CompeteShowTrack.mid == 0 then
    return 1
  end
  if CompeteShowTrack.bot == 0 then
    return 2
  end
  return -1
end
