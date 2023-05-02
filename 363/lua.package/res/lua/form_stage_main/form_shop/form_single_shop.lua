require("custom_sender")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("form_stage_main\\form_tvt\\define")
require("util_gui")
local temp_table = {}
SingleShop_ClientMsg_OpenShop = 1
SingleShop_ClientMsg_BuyItem = 2
SingleShop_ClientMsg_Refresh = 3
SingleShop_ServerMsg_OpenShop = 1
SingleShop_ServerMsg_CloseShop = 2
SingleShop_ServerMsg_Refresh = 3
REFRESH_TYPE_HOUR = 0
REFRESH_TYPE_DAY = 1
REFRESH_TYPE_WEEK = 2
REFRESH_TYPE_MONTH = 3
BUYTYPE_SILVER = 0
BUYTYPE_ITEM = 1
BUYTYPE_PROP = 2
item_col = 1
buytype_col = 2
silver_type_col = 3
silver_count_col = 4
islimit_col = 5
limit_count_col = 6
condition_col = 7
col_count = 7
local FORM = "form_stage_main\\form_shop\\form_single_shop"
function main_form_init(form)
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  form.shopid = ""
  form.str_page = ""
  form.pageinfo = ""
  form.refreshinfo = ""
  form.cur_page = 1
  form.silver_type = 0
  form.silver_price = 0
  form.item_config = ""
  form.item_count = 0
  form.prop_config = ""
  form.prop_count = 0
  form.rbtn_1.Checked = true
  local groupbox = form.groupbox_1
  for i = 1, 5 do
    local child_name = string.format("%s_%s", nx_string("rbtn"), nx_string(i))
    local btn_control = groupbox:Find(child_name)
    if nx_is_valid(btn_control) then
      btn_control.Visible = false
    end
  end
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(SingleShop_ServerMsg_OpenShop) then
    local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    if not nx_is_valid(form) then
      return
    end
    form.shopid = arg[1]
    form.str_page = arg[2]
    form.pageinfo = arg[3]
    form.refreshinfo = arg[4]
    form.silver_type = nx_int(arg[5])
    form.silver_price = nx_int(arg[6])
    form.item_config = arg[7]
    form.item_count = nx_int(arg[8])
    form.prop_config = arg[9]
    form.prop_count = nx_int(arg[10])
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    temp_table = arg
    refresh_form(form)
    refresh_refreshinfo(form)
  elseif nx_int(sub_msg) == nx_int(SingleShop_ServerMsg_CloseShop) then
    local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  elseif nx_int(sub_msg) == nx_int(SingleShop_ServerMsg_Refresh) then
    local form = nx_execute("util_gui", "util_get_form", FORM, true, false)
    if not nx_is_valid(form) then
      return
    end
    temp_table = arg
    refresh_form(form)
    refresh_refreshinfo(form)
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function refresh_refreshinfo(form)
  local gui = nx_value("gui")
  local str = util_split_string(form.refreshinfo, ",")
  local refresh_type = nx_int(str[1])
  if refresh_type == nx_int(REFRESH_TYPE_HOUR) then
    local refresh_min = nx_int(str[2])
    local refresh_time = nx_int(str[3])
    local hour = nx_int(refresh_min / nx_int(60))
    local minute = nx_int(refresh_min) - hour * 60
    gui.TextManager:Format_SetIDName("randomshop_signlerule_0")
    gui.TextManager:Format_AddParam(nx_int(hour))
    gui.TextManager:Format_AddParam(nx_int(minute))
    gui.TextManager:Format_AddParam(nx_int(refresh_time))
    form.lbl_desc.Text = nx_widestr(gui.TextManager:Format_GetText())
  elseif refresh_type == nx_int(REFRESH_TYPE_DAY) then
    local refresh_min = nx_int(str[2])
    local hour = nx_int(refresh_min / nx_int(60))
    local minute = nx_int(refresh_min) - hour * 60
    gui.TextManager:Format_SetIDName("randomshop_signlerule_1")
    gui.TextManager:Format_AddParam(nx_int(hour))
    gui.TextManager:Format_AddParam(nx_int(minute))
    form.lbl_desc.Text = nx_widestr(gui.TextManager:Format_GetText())
  elseif refresh_type == nx_int(REFRESH_TYPE_WEEK) then
    local refresh_min = nx_int(str[2])
    local refresh_weekday = nx_int(str[3])
    local hour = nx_int(refresh_min / nx_int(60))
    local minute = nx_int(refresh_min) - hour * 60
    gui.TextManager:Format_SetIDName("randomshop_signlerule_2")
    gui.TextManager:Format_AddParam(nx_widestr(refresh_weekday))
    gui.TextManager:Format_AddParam(nx_int(hour))
    gui.TextManager:Format_AddParam(nx_int(minute))
    form.lbl_desc.Text = nx_widestr(gui.TextManager:Format_GetText())
  elseif refresh_type == nx_int(REFRESH_TYPE_MONTH) then
    local refresh_min = nx_int(str[2])
    local refresh_month = nx_int(str[3])
    local hour = nx_int(refresh_min / nx_int(60))
    local minute = nx_int(refresh_min) - hour * 60
    gui.TextManager:Format_SetIDName("randomshop_signlerule_3")
    gui.TextManager:Format_AddParam(nx_widestr(refresh_month))
    gui.TextManager:Format_AddParam(nx_int(hour))
    gui.TextManager:Format_AddParam(nx_int(minute))
    form.lbl_desc.Text = nx_widestr(gui.TextManager:Format_GetText())
  end
end
function refresh_form(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local framebox = form.framebox
  local item_box = form.item_box
  local str = util_split_string(form.str_page, ";")
  if nx_int(form.cur_page) > nx_int(table.getn(str)) then
    return
  end
  local item_count = nx_int(str[form.cur_page])
  local befor_item = 0
  for i = 1, form.cur_page - 1 do
    befor_item = befor_item + nx_int(str[i]) * col_count
  end
  local gui = nx_value("gui")
  framebox:DeleteAll()
  framebox.IsEditMode = true
  local index = 1
  for i = 1, nx_number(item_count) do
    local item_box = clone_control(form, "item_box", nx_string(i))
    item_box.Visible = true
    framebox:Add(item_box)
    item_box.Top = nx_int((i - 1) / 2) * item_box.Height
    item_box.Left = nx_int((i - 1) % 2) * item_box.Width + 5
    local index = befor_item + (i - 1) * col_count + item_col
    local item_id = temp_table[index]
    index = befor_item + (i - 1) * col_count + buytype_col
    local buytype = temp_table[index]
    index = befor_item + (i - 1) * col_count + silver_type_col
    local silver_type = temp_table[index]
    index = befor_item + (i - 1) * col_count + silver_count_col
    local silver_count = temp_table[index]
    index = befor_item + (i - 1) * col_count + islimit_col
    local islimit = temp_table[index]
    index = befor_item + (i - 1) * col_count + limit_count_col
    local limit_count = temp_table[index]
    index = befor_item + (i - 1) * col_count + condition_col
    local condition = temp_table[index]
    local child_name = string.format("%s_%s", nx_string("imagegrid_item"), nx_string(i))
    local imagegrid_item_control = item_box:Find(child_name)
    local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
    imagegrid_item_control:AddItem(0, photo, nx_widestr(item_id), 1, 0)
    imagegrid_item_control.itemid = item_id
    nx_bind_script(imagegrid_item_control, nx_current())
    nx_callback(imagegrid_item_control, "on_mousein_grid", "on_mousein_imagegrid_item_grid")
    nx_callback(imagegrid_item_control, "on_mouseout_grid", "on_mouseout_imagegrid_item_grid")
    nx_callback(imagegrid_item_control, "on_rightclick_grid", "on_rightclick_imagegrid_item_grid")
    child_name = string.format("%s_%s", nx_string("lbl_name"), nx_string(i))
    local lbl_name_control = item_box:Find(child_name)
    lbl_name_control.Text = nx_widestr(gui.TextManager:GetText(item_id))
    child_name = string.format("%s_%s", nx_string("lbl_price"), nx_string(i))
    local lbl_price_control = item_box:Find(child_name)
    if nx_int(buytype) == nx_int(BUYTYPE_SILVER) then
      local str_silver_type = ""
      if nx_int(silver_type) == nx_int(1) then
        str_silver_type = "ui_singleshop_002"
      else
        str_silver_type = "ui_singleshop_003"
      end
      gui.TextManager:Format_SetIDName(str_silver_type)
      gui.TextManager:Format_AddParam(nx_int(silver_count))
      lbl_price_control.Text = nx_widestr(gui.TextManager:Format_GetText())
    elseif nx_int(buytype) == nx_int(BUYTYPE_ITEM) then
      local str_item_price = nx_widestr("")
      str_item_price = nx_widestr(gui.TextManager:GetText(silver_type)) .. nx_widestr("*") .. nx_widestr(silver_count)
      lbl_price_control.Text = nx_widestr(str_item_price)
    elseif nx_int(buytype) == nx_int(BUYTYPE_PROP) then
      local str_prop_price = "ui_singleshop_" .. nx_string(silver_type)
      str_item_price = nx_widestr(gui.TextManager:GetText(str_prop_price)) .. nx_widestr("*") .. nx_widestr(silver_count)
      lbl_price_control.Text = nx_widestr(str_prop_price)
    end
    child_name = string.format("%s_%s", nx_string("lbl_limit"), nx_string(i))
    local lbl_limit_control = item_box:Find(child_name)
    if nx_int(islimit) > nx_int(0) then
      lbl_limit_control.Text = nx_widestr(nx_int(limit_count))
    else
      lbl_limit_control.Text = nx_widestr(gui.TextManager:GetText("ui_singleshop_004"))
    end
    child_name = string.format("%s_%s", nx_string("lbl_condition"), nx_string(i))
    local lbl_condition_control = item_box:Find(child_name)
    if nx_string(condition) == "" then
      lbl_condition_control.Text = nx_widestr(gui.TextManager:GetText("ui_singleshop_004"))
    else
      lbl_condition_control.Text = nx_widestr(gui.TextManager:GetText(condition))
    end
  end
  framebox.IsEditMode = false
  refresh_rbtn(form)
end
function refresh_rbtn(form)
  local gui = nx_value("gui")
  local groupbox = form.groupbox_1
  local str = util_split_string(form.pageinfo, ",")
  for i = 1, table.getn(str) do
    local child_name = string.format("%s_%s", nx_string("rbtn"), nx_string(i))
    local btn_control = groupbox:Find(child_name)
    if nx_is_valid(btn_control) then
      btn_control.Visible = true
      local text = nx_string(form.shopid) .. "_" .. nx_string(str[i])
      btn_control.Text = nx_widestr(gui.TextManager:GetText(text))
    end
  end
end
function on_rightclick_imagegrid_item_grid(grid, index)
  local form = grid.ParentForm
  local box = grid.Parent
  local gui = nx_value("gui")
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  gui.TextManager:Format_SetIDName("ui_singleshop_001")
  gui.TextManager:Format_AddParam(nx_widestr(gui.TextManager:GetText(grid.itemid)))
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
  dialog.relogin_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_single_shop_msg", SingleShop_ClientMsg_BuyItem, form.shopid, grid.itemid)
  end
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local str_param = nx_widestr("")
  if nx_int(form.silver_price) > nx_int(0) then
    local str_silver_type = ""
    if nx_int(form.silver_type) == nx_int(1) then
      str_silver_type = "ui_singleshop_002"
    else
      str_silver_type = "ui_singleshop_003"
    end
    gui.TextManager:Format_SetIDName(str_silver_type)
    gui.TextManager:Format_AddParam(nx_int(form.silver_price))
    str_param = str_param .. nx_widestr(gui.TextManager:Format_GetText()) .. nx_widestr("<br>")
  end
  if nx_string(form.item_config) ~= nx_string("") then
    str_param = str_param .. nx_widestr(gui.TextManager:GetText(form.item_config)) .. nx_widestr("*") .. nx_widestr(form.item_count) .. nx_widestr("<br>")
  end
  if nx_string(form.prop_config) ~= nx_string("") then
    str_param = str_param .. nx_widestr(gui.TextManager:GetText("ui_singleshop_" .. form.prop_config)) .. nx_widestr("*") .. nx_widestr(form.prop_count) .. nx_widestr("<br>")
  end
  gui.TextManager:Format_SetIDName("ui_singleshop_005")
  gui.TextManager:Format_AddParam(nx_widestr(str_param))
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
  dialog.relogin_btn.Visible = false
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_single_shop_msg", SingleShop_ClientMsg_Refresh, form.shopid)
  end
end
function on_mousein_imagegrid_item_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_mouseout_imagegrid_item_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
  if 0 >= table.getn(table_prop_name) then
    return
  end
  table_prop_value.ConfigID = nx_string(prize_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", "task_grid_data")
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_set_custom(grid.Data, "is_static", true)
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
  grid.Data:ClearChild()
end
function on_rbtn_1_click(rbtn)
  local form = rbtn.ParentForm
  form.cur_page = 1
  refresh_form(form)
end
function on_rbtn_2_click(rbtn)
  local form = rbtn.ParentForm
  form.cur_page = 2
  refresh_form(form)
end
function on_rbtn_3_click(rbtn)
  local form = rbtn.ParentForm
  form.cur_page = 3
  refresh_form(form)
end
function on_rbtn_4_click(rbtn)
  local form = rbtn.ParentForm
  form.cur_page = 4
  refresh_form(form)
end
function on_rbtn_5_click(rbtn)
  local form = rbtn.ParentForm
  form.cur_page = 5
  refresh_form(form)
end
