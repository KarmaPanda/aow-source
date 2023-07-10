require("util_functions")
require("util_gui")
require("share\\view_define")
local ui_home_conditions = {
  "ui_home_goods_01_1",
  "ui_home_goods_02_1",
  "ui_home_goods_03_1",
  "ui_home_goods_04_1",
  "ui_home_goods_05_1",
  "ui_home_goods_06_1"
}
local ui_home_conditions_empty = {
  "ui_home_goods_01_0",
  "ui_home_goods_02_0",
  "ui_home_goods_03_0",
  "ui_home_goods_04_0",
  "ui_home_goods_05_0",
  "ui_home_goods_06_0"
}
local form = "form_stage_main\\form_home\\form_home_build"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  form:Close()
end
function on_btn_build_click(btn)
  local form = btn.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(151), nx_int(1), nx_int(form.id), nx_widestr(form.ipt_name.Text))
end
function open_form(id)
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.id = id
  load_info(form, id)
end
function close_form()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function load_info(form, id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local home_manager = nx_value("HomeManager")
  if not nx_is_valid(home_manager) then
    return
  end
  form.groupscrollbox_1.IsEditMode = true
  local ene = home_manager:GetHomeEne(id, 1)
  form.lbl_style.Text = nx_widestr(util_text(home_manager:GetHomeStyle(id)))
  form.lbl_ene.Text = nx_widestr(ene)
  form.lbl_area.Text = nx_widestr(util_text(home_manager:GetHomeArea(id, 1)))
  form.lbl_servant.Text = nx_widestr(home_manager:GetHomeServant(id, 1))
  form.lbl_warehouse.Text = nx_widestr(home_manager:GetHomeWarehouse(id, 1))
  form.lbl_max_num.Text = nx_widestr(home_manager:GetHomeMaxGoods(id, 1))
  form.lbl_price.HtmlText = nx_widestr("")
  form.lbl_price_more.HtmlText = nx_widestr("")
  local sy = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"top\" only=\"line\" data=\"\" />"
  local price = home_manager:GetHomePrice(id, 1)
  local price_more = home_manager:GetHomePriceMore(id)
  local bind_money = client_player:QueryProp("CapitalType1")
  local nobind_money = client_player:QueryProp("CapitalType2")
  local need_money = nx_int(price) + nx_int(price_more)
  if nx_int(need_money) > nx_int(nobind_money) then
    form.lbl_price.TextColor = "255,255,0,0"
    form.lbl_price_more.TextColor = "255,255,0,0"
  end
  form.lbl_price.HtmlText = nx_widestr(sy) .. nx_widestr(price_to_text(form, gui, price))
  form.lbl_price_more.HtmlText = nx_widestr(sy) .. nx_widestr(price_to_text(form, gui, price_more))
  local have_ene = client_player:QueryProp("Ene")
  if nx_int(ene) > nx_int(have_ene) then
    form.lbl_ene.ForeColor = "255,255,0,0"
  end
  local need_item = home_manager:GetHomeNeedItem(id, 1)
  local condition1 = home_manager:GetHomeCondition1(id, 1)
  local condition2 = home_manager:GetHomeCondition2(id, 1)
  form.mlt_con2_1.HtmlText = nx_widestr(gui.TextManager:GetText("ui_home_con_01"))
  form.mlt_con2_2.HtmlText = nx_widestr(gui.TextManager:GetText("ui_home_con_02"))
  local str_lst = util_split_string(need_item, ",")
  local j = 0
  for i = 1, table.getn(str_lst), 2 do
    local item = nx_string(str_lst[i])
    local num = nx_int(str_lst[i + 1])
    local ItemQuery = nx_value("ItemQuery")
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      form.material_grid:AddItem(j, tempphoto, "", 0, -1)
      local MaterialNum = Get_Material_Num(item, VIEWPORT_MATERIAL_TOOL) + Get_Material_Num(item, VIEWPORT_TOOL)
      if nx_int(MaterialNum) >= nx_int(num) then
        form.material_grid:ChangeItemImageToBW(j, false)
        form.material_grid:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#00aa00\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.material_grid:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      else
        form.material_grid:ChangeItemImageToBW(j, true)
        form.material_grid:SetItemAddInfo(nx_int(j), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.material_grid:ShowItemAddInfo(nx_int(j), nx_int(1), true)
      end
      form.material_grid:SetItemAddInfo(nx_int(j), nx_int(2), nx_widestr(item))
    end
    j = j + 1
  end
  local condition_list = util_split_string(condition1, ",")
  if table.getn(condition_list) ~= 3 then
    return
  end
  form.cbtn_1.Checked = false
  form.cbtn_2.Checked = false
  form.cbtn_3.Checked = false
  if nx_int(condition_list[1]) == nx_int(1) then
    form.cbtn_1.Checked = true
  end
  if condition_list[2] == 1 then
    form.cbtn_2.Checked = true
  end
  if condition_list[3] == 1 then
    form.cbtn_3.Checked = true
  end
  local condition_list_empty = util_split_string(condition2, ",")
  if table.getn(condition_list_empty) ~= 6 then
    return
  end
  if nx_int(condition_list_empty[1]) == nx_int(0) then
    form.mlt_condition1.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[1]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[1])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition1.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[1], text))
  end
  if nx_int(condition_list_empty[2]) == nx_int(0) then
    form.mlt_condition2.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[2]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[2])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition2.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[2], text))
  end
  if nx_int(condition_list_empty[3]) == nx_int(0) then
    form.mlt_condition3.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[3]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[3])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition3.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[3], text))
  end
  if nx_int(condition_list_empty[4]) == nx_int(0) then
    form.mlt_condition4.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[4]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[4])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition4.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[4], text))
  end
  if nx_int(condition_list_empty[5]) == nx_int(0) then
    form.mlt_condition5.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[5]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[5])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition5.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[5], text))
  end
  if nx_int(condition_list_empty[6]) == nx_int(0) then
    form.mlt_condition6.HtmlText = nx_widestr(util_text(ui_home_conditions_empty[6]))
  else
    local test_id = "ui_home_quality_" .. nx_string(condition_list_empty[6])
    local text = gui.TextManager:GetText(test_id)
    form.mlt_condition6.HtmlText = nx_widestr(gui.TextManager:GetFormatText(ui_home_conditions[6], text))
  end
  form.groupscrollbox_1.IsEditMode = false
end
function Get_Material_Num(item, viewID)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewID))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local count = view:GetViewObjCount()
  for j = 1, count do
    local obj = view:GetViewObjByIndex(j - 1)
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return nx_int(cur_amount)
end
function on_material_grid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(2)))
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local item_name, item_type
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if nx_string(bExist) == nx_string("true") then
    item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(photo)
    local GoodsGrid = nx_value("GoodsGrid")
    prop_array.Amount = GoodsGrid:GetItemCount(nx_string(item_config))
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_material_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function price_to_text(form, gui, price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
