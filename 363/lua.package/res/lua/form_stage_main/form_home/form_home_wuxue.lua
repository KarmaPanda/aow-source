require("util_functions")
require("share\\client_custom_define")
require("share\\itemtype_define")
require("share\\view_define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local FUNC_TYPE_FACULTY = 1
local FUNC_TYPE_UPGRADE = 2
local HWX_INDEX_WUXUE_ID = 0
local HWX_INDEX_WUXUE_LEVEL = 1
local HWX_INDEX_FACULTY_LEVEL = 2
local HWX_INDEX_F_ITEM_SUM = 3
local HWX_INDEX_S_ITEM_SUM = 4
local HWX_INDEX_RENT_GOLD = 5
local UPGRADE_TYPE_F_ITEM = 0
local UPGRADE_TYPE_S_ITEM = 1
local SUB_MSG_UPGRADE_WUXUE = 11
local SUB_MSG_ADVANCE_WUXUE = 12
local SUB_MSG_RENT_WUXUE = 13
local SUB_MSG_SYN_WUXUE = 19
local RENT_TYPE_SILVER = 0
local RENT_TYPE_ITEM = 1
local RENT_TYPE_GOLD = 2
local RENT_GOLD_TYPE_NONE = 0
local RENT_GOLD_TYPE_FINISH = 1
local DAY_PRE_INFO = "homewuxueday_"
local HOME_WUXUE_RENT_REC = "HomeWuXueRentRec"
local HWR_INDEX_WUXUE_ID = 0
local HWR_INDEX_RENT_COUNT = 1
function main_form_init(form)
  form.Fixed = false
  form.sel_item_index = -1
  form.func_type = FUNC_TYPE_FACULTY
  form.cur_action = ""
  form.Actor2 = nx_null()
  return 1
end
function on_main_form_open(form)
  hide_item_data(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "prop_callback_faculty")
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_home\\form_home_wuxue", "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, form, "form_stage_main\\form_home\\form_home_wuxue", "on_toolbox_viewport_change")
    databinder:AddTableBind("HomeWuXueRentRec", form, nx_current(), "table_callback_wuxue_rent")
  end
  show_type_data(form)
  create_skill_action(form)
  switch_func_groupbox(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("Faculty", form)
    databinder:DelViewBind(form)
    databinder:DelTableBind("HomeWuXueRentRec", form)
  end
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    form.scenebox_show.Scene:Delete(form.Actor2)
  end
  nx_execute("scene", "delete_scene", form.scenebox_show.Scene)
  nx_destroy(form)
end
function prop_callback_faculty(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  form.lbl_faculty.Text = nx_widestr(prop_value)
end
function on_toolbox_viewport_change(form, optype)
  if not form.gbox_skill_upgrade.Visible then
    return
  end
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    switch_rent_sub_page(form, RENT_TYPE_ITEM)
  end
end
function table_callback_wuxue_rent(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if optype ~= "add" and optype ~= "del" and optype ~= "clear" and optype ~= "update" then
    return
  end
  update_rent_info(form)
end
function show_type_data(form)
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  form.tree_types:BeginUpdate()
  local home_wuxue_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(home_wuxue_ini) then
    return 0
  end
  local wuxue_count = home_wuxue_ini:GetSectionCount()
  for i = 1, wuxue_count do
    local wuxue_id = home_wuxue_ini:GetSectionByIndex(i - 1)
    local main_type_name = home_wuxue_ini:ReadString(i - 1, "MainTypeName", "")
    local main_type_node = root:FindNode(util_text(main_type_name))
    if not nx_is_valid(main_type_node) then
      main_type_node = root:CreateNode(util_text(main_type_name))
      set_node_prop(main_type_node, 1)
    end
    local sub_type_node = main_type_node:FindNode(util_text(wuxue_id))
    if not nx_is_valid(sub_type_node) then
      sub_type_node = main_type_node:CreateNode(util_text(wuxue_id))
      set_node_prop(sub_type_node, 2)
      sub_type_node.type_name = wuxue_id
    end
  end
  root.Expand = true
  form.tree_types:EndUpdate()
  auto_select_first(form.tree_types)
end
function hide_item_data(form)
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. nx_string(i))
    if nx_is_valid(gbox_item) then
      gbox_item.Visible = false
    end
  end
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = -1
  form.gpsb_items:ResetChildrenYPos()
end
function show_item_data(form)
  if not nx_is_valid(form) then
    return 0
  end
  local sel_item_index = 1
  if nx_int(form.sel_item_index) > nx_int(0) then
    sel_item_index = form.sel_item_index
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  hide_item_data(form)
  local gui = nx_value("gui")
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, sel_node.type_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. i)
    if not nx_is_valid(gbox_item) then
      break
    end
    local grid_photo = gbox_item:Find("grid_photo_" .. i)
    local lbl_name = gbox_item:Find("lbl_name_" .. i)
    local lbl_level = gbox_item:Find("lbl_level_" .. i)
    local btn_select = gbox_item:Find("btn_select_" .. i)
    if not (nx_is_valid(grid_photo) and nx_is_valid(lbl_name) and nx_is_valid(lbl_level)) or not nx_is_valid(btn_select) then
      break
    end
    btn_select.item_name = nx_string(item_name)
    lbl_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(item_name)))
    local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", item_name, "StaticData", "0")
    local item_photo = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_static.ini", static_id, "Photo", DEFAULT_PHOTO)
    grid_photo:Clear()
    grid_photo:AddItem(nx_int(0), item_photo, nx_widestr(item_name), 1, -1)
    grid_photo.item_name = item_name
    gbox_item.Visible = true
  end
  form.gpsb_items:ResetChildrenYPos()
  if 1 < table.getn(item_tab) then
    select_one_item(form, sel_item_index)
  end
end
function select_one_item(form, sel_item_index)
  if not nx_is_valid(form) then
    return 0
  end
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return 0
  end
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = nx_number(sel_item_index)
  set_name_color(form, form.sel_item_index, true)
  local actor2 = form.Actor2
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  refresh_skill_show(form)
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not set_node_select(self, cur_node, pre_node) then
    return
  end
  show_item_data(form)
  refresh_func_info(form)
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", grid.item_name, "StaticData", "0")
  item.ConfigID = grid.item_name
  item.ItemType = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", grid.item_name, "ItemType", "0")
  item.StaticData = nx_number(static_id)
  item.is_static = true
  item.Level = 1
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
end
function on_grid_photo_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_select_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  select_one_item(form, self.DataSource)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_loop_play_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  refresh_skill_show(form)
end
function refresh_skill_show(form)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.gbox_skill_faculty.Visible then
    return 0
  end
  local sel_item_index = form.sel_item_index
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return 0
  end
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  local item_name_old = form.cur_action
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) and nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    skill_effect:EndShowZhaoshi(form.Actor2, nx_string(item_name_old))
  end
  show_item_action(form, btn_select.item_name, WUXUE_SHOW_SKILL, true)
  add_weapon(form, btn_select.item_name)
end
function show_faculty_info(form)
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local max_level = faculty_maxlevel(client_obj, sel_node.type_name)
  form.lbl_f_name.Text = util_text(nx_string(sel_node.type_name))
  local level_str = get_format_str("ui_hone_wuxuexl_22", nx_number(cur_level), nx_number(max_level))
  form.mltbox_f_level.HtmlText = nx_widestr(level_str)
  form.lbl_next_faculty.Text = nx_widestr(faculty_consume(sel_node.type_name, cur_level + 1))
end
function show_upgrade_info(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  form.lbl_u_name.Text = util_text(nx_string(sel_node.type_name))
  local curlevel = faculty_curlevel(client_obj, sel_node.type_name)
  local maxlevel = faculty_maxlevel(client_obj, sel_node.type_name)
  local level_str = get_format_str("ui_hone_wuxuexl_22", nx_number(curlevel), nx_number(maxlevel))
  form.mltbox_u_level.HtmlText = nx_widestr(level_str)
  local f_item_name, f_item_max_num = upgrade_item(sel_node.type_name, maxlevel + 1, UPGRADE_TYPE_F_ITEM)
  form.imagegrid_f_item:Clear()
  local f_item_photo = ItemQuery:GetItemPropByConfigID(f_item_name, "Photo")
  form.imagegrid_f_item:AddItem(nx_int(0), f_item_photo, nx_widestr(f_item_name), 1, -1)
  form.lbl_f_item_name.Text = util_text(nx_string(f_item_name))
  local f_item_cur_num = upgrade_curitemnum(client_obj, sel_node.type_name, UPGRADE_TYPE_F_ITEM)
  form.lbl_f_next_count.Text = nx_widestr(f_item_cur_num) .. nx_widestr("/") .. nx_widestr(f_item_max_num)
  form.gbox_f_item.Visible = true
  if nx_number(f_item_max_num) == 0 then
    form.gbox_f_item.Visible = false
  end
  local s_item_name, s_item_max_num = upgrade_item(sel_node.type_name, maxlevel + 1, UPGRADE_TYPE_S_ITEM)
  form.imagegrid_s_item:Clear()
  local s_item_photo = ItemQuery:GetItemPropByConfigID(s_item_name, "Photo")
  form.imagegrid_s_item:AddItem(nx_int(0), s_item_photo, nx_widestr(s_item_name), 1, -1)
  form.lbl_s_item_name.Text = util_text(nx_string(s_item_name))
  local s_item_cur_num = upgrade_curitemnum(client_obj, sel_node.type_name, UPGRADE_TYPE_S_ITEM)
  form.lbl_s_next_count.Text = nx_widestr(s_item_cur_num) .. nx_widestr("/") .. nx_widestr(s_item_max_num)
  form.gbox_s_item.Visible = true
  if nx_number(s_item_max_num) == 0 then
    form.gbox_s_item.Visible = false
  end
  local rent_count = home_wuxue_rent_count(sel_node.type_name)
  form.lbl_rent_count.Text = util_format_string("ui_hone_wuxuexl_24", nx_int(rent_count))
  switch_rent_sub_page(form, RENT_TYPE_ITEM)
end
function on_btn_faculty_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local maxlevel = faculty_maxlevel(client_obj, sel_node.type_name)
  if nx_number(cur_level) >= nx_number(maxlevel) then
    return
  end
  local faculty_value = faculty_consume(sel_node.type_name, cur_level + 1)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = get_format_str("ui_hone_wuxuexl_01", nx_number(faculty_value))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_ADVANCE_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name))
    end
  end
end
function on_btn_f_item_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local maxlevel = faculty_maxlevel(client_obj, sel_node.type_name)
  local f_item_name, f_item_max_num = upgrade_item(sel_node.type_name, maxlevel + 1, UPGRADE_TYPE_F_ITEM)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  dialog.info_label.Text = nx_widestr(util_text("ui_hone_wuxuexl_02"))
  dialog.name_edit.Max = f_item_max_num
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_box_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_UPGRADE_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name), UPGRADE_TYPE_F_ITEM, nx_number(text))
  end
end
function on_btn_s_item_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local maxlevel = faculty_maxlevel(client_obj, sel_node.type_name)
  local s_item_name, s_item_max_num = upgrade_item(sel_node.type_name, maxlevel + 1, UPGRADE_TYPE_S_ITEM)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_inputbox", true, false)
  dialog.info_label.Text = nx_widestr(util_text("ui_hone_wuxuexl_02"))
  dialog.name_edit.Max = s_item_max_num
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_box_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_UPGRADE_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name), UPGRADE_TYPE_S_ITEM, nx_number(text))
  end
end
function on_rbtn_rent_checked_changed(self)
  if not self.Checked then
    return
  end
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  switch_rent_sub_page(form, nx_number(self.DataSource))
end
function switch_rent_sub_page(form, rent_type)
  if not nx_is_valid(form) then
    return
  end
  form.gbox_rent_silver.Visible = false
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  form.btn_rent_gold.Enabled = true
  if get_rent_gold(client_obj, sel_node.type_name) == RENT_GOLD_TYPE_FINISH then
    form.btn_rent_gold.Enabled = false
  end
  form.btn_tongbu.Visible = true
  form.gbox_rent.Visible = true
  form.mltbox_rent_desc.Visible = false
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  if nx_number(cur_level) == nx_number(0) then
    form.gbox_rent.Visible = false
    form.mltbox_rent_desc.Visible = true
    form.btn_tongbu.Visible = false
    return
  end
  form.gbox_rent_item.Visible = true
  form.combobox_item_day.DropListBox:ClearString()
  local days_list = rent_item_days_list(sel_node.type_name, cur_level)
  local days_list_str = ""
  for i = 1, table.getn(days_list) do
    local day = nx_string(DAY_PRE_INFO) .. nx_string(days_list[i])
    form.combobox_item_day.DropListBox:AddString(nx_widestr(util_text(nx_string(day))))
    days_list_str = nx_string(days_list_str) .. nx_string(days_list[i])
    if i < table.getn(days_list) then
      days_list_str = nx_string(days_list_str) .. "|"
    end
  end
  form.combobox_item_day.days_list_str = days_list_str
  form.combobox_item_day.DropListBox.SelectIndex = 0
  form.combobox_item_day.InputEdit.Text = form.combobox_item_day.DropListBox.SelectString
  local select_day = parse_days(days_list_str, 1)
  local item_id, need_item_count = rent_item_amount(sel_node.type_name, cur_level, select_day)
  local have_item_count = get_item_num(item_id)
  form.ICGrid_rent_item:Clear()
  local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  form.ICGrid_rent_item:AddItem(0, nx_string(photo), nx_widestr(item_id), 1, -1)
  local desc_info = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(have_item_count) .. nx_widestr("/") .. nx_widestr(need_item_count) .. nx_widestr("</font>")
  if need_item_count <= have_item_count then
    desc_info = nx_widestr("<font color=\"#00ff00\">") .. nx_widestr(have_item_count) .. nx_widestr("/") .. nx_widestr(need_item_count) .. nx_widestr("</font>")
  end
  form.ICGrid_rent_item:SetItemAddInfo(0, 0, nx_widestr(desc_info))
  form.gbox_rent_gold.Visible = true
  local gold_value = rent_gold_amount(sel_node.type_name)
  local gold_photo = "<img src=\"gui\\common\\money\\jyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  form.mltbox_rent_gold.HtmlText = nx_widestr(gold_photo) .. nx_widestr(gold_value)
end
function on_combobox_silver_day_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sel_index = form.combobox_silver_day.DropListBox.SelectIndex
  local days = parse_days(nx_string(form.combobox_silver_day.days_list_str), nx_number(sel_index) + 1)
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local silver_value = rent_silver_amount(sel_node.type_name, cur_level, days)
  local silver_photo = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  form.mltbox_price_silver.HtmlText = nx_widestr(silver_photo) .. nx_widestr(price_to_text(silver_value))
end
function on_btn_silver_rent_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local sel_index = form.combobox_silver_day.DropListBox.SelectIndex
  local days = parse_days(nx_string(form.combobox_silver_day.days_list_str), nx_number(sel_index) + 1)
  if days == 0 then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local silver_value = rent_silver_amount(sel_node.type_name, cur_level, days)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local silver_photo = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local silver_str = nx_string(silver_photo) .. nx_string(price_to_text(silver_value))
  local tips_str = get_format_str("ui_hone_wuxuexl_03", nx_string(silver_str), nx_number(days))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_RENT_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name), RENT_TYPE_SILVER, nx_number(days))
    end
  end
end
function on_combobox_item_day_selected(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local sel_index = form.combobox_item_day.DropListBox.SelectIndex
  local days = parse_days(nx_string(form.combobox_item_day.days_list_str), nx_number(sel_index) + 1)
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local item_id, need_item_count = rent_item_amount(sel_node.type_name, cur_level, days)
  local have_item_count = get_item_num(item_id)
  form.ICGrid_rent_item:Clear()
  local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  form.ICGrid_rent_item:AddItem(0, nx_string(photo), nx_widestr(item_id), 1, -1)
  local desc_info = nx_widestr("<font color=\"#ff0000\">") .. nx_widestr(have_item_count) .. nx_widestr("/") .. nx_widestr(need_item_count) .. nx_widestr("</font>")
  if need_item_count <= have_item_count then
    desc_info = nx_widestr("<font color=\"#00ff00\">") .. nx_widestr(have_item_count) .. nx_widestr("/") .. nx_widestr(need_item_count) .. nx_widestr("</font>")
  end
  form.ICGrid_rent_item:SetItemAddInfo(0, 0, nx_widestr(desc_info))
end
function on_btn_rent_item_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local sel_index = form.combobox_item_day.DropListBox.SelectIndex
  local days = parse_days(nx_string(form.combobox_item_day.days_list_str), nx_number(sel_index) + 1)
  if days == 0 then
    return
  end
  local cur_level = faculty_curlevel(client_obj, sel_node.type_name)
  local item_id, need_item_count = rent_item_amount(sel_node.type_name, cur_level, days)
  local have_item_count = get_item_num(item_id)
  if need_item_count > have_item_count then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = get_format_str("ui_hone_wuxuexl_04", nx_number(need_item_count), nx_string(item_id), nx_number(days))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_RENT_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name), RENT_TYPE_ITEM, nx_number(days))
    end
  end
end
function on_btn_rent_gold_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gold_value = rent_gold_amount(sel_node.type_name)
  local gold_photo = "<img src=\"gui\\common\\money\\jyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
  local gold_str = nx_string(gold_photo) .. nx_string(gold_value)
  local tips_str = get_format_str("ui_hone_wuxuexl_05", nx_string(gold_str))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_RENT_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name), RENT_TYPE_GOLD, 0)
    end
  end
end
function on_btn_tongbu_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local client_obj = form.op_client_obj
  if not nx_is_valid(client_obj) then
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local tips_str = get_format_str("ui_hone_wuxuexl_30")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FURNITURE), SUB_MSG_SYN_WUXUE, nx_object(client_obj.Ident), nx_string(sel_node.type_name))
    end
  end
end
function on_btn_wx_faculty_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.func_type = FUNC_TYPE_FACULTY
  switch_func_groupbox(form)
end
function on_btn_wx_upgrade_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.func_type = FUNC_TYPE_UPGRADE
  switch_func_groupbox(form)
end
function on_imagegrid_f_item_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_f_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_s_item_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_s_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ICGrid_rent_item_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_ICGrid_rent_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function open_form(client_obj, func_type)
  if not nx_is_valid(client_obj) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.op_client_obj = client_obj
  form.func_type = func_type
  form.Visible = true
  form:Show()
end
function switch_func_groupbox(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "func_type") then
    return
  end
  if nx_number(form.func_type) == FUNC_TYPE_FACULTY then
    form.gbox_skill_faculty.Visible = true
    form.gbox_skill_upgrade.Visible = false
  elseif nx_number(form.func_type) == FUNC_TYPE_UPGRADE then
    form.gbox_skill_faculty.Visible = false
    form.gbox_skill_upgrade.Visible = true
  end
  refresh_func_info(form)
end
function refresh_func_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "func_type") then
    return
  end
  if nx_number(form.func_type) == FUNC_TYPE_FACULTY then
    show_faculty_info(form)
  elseif nx_number(form.func_type) == FUNC_TYPE_UPGRADE then
    show_upgrade_info(form)
  end
end
function update_wuxue_info()
  local form = nx_execute("util_gui", "util_get_form", nx_current())
  if not nx_is_valid(form) then
    return
  end
  refresh_func_info(form)
end
function update_rent_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  if not nx_find_custom(form, "func_type") then
    return
  end
  if nx_number(form.func_type) ~= FUNC_TYPE_UPGRADE then
    return
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local rent_count = home_wuxue_rent_count(sel_node.type_name)
  form.lbl_rent_count.Text = util_format_string("ui_hone_wuxuexl_24", nx_int(rent_count))
end
function get_rent_gold(client_obj, wuxue_id)
  if not nx_is_valid(client_obj) then
    return -1
  end
  local find_row = client_obj:FindRecordRow("HomeWuXueRec", HWX_INDEX_WUXUE_ID, nx_string(wuxue_id), 0)
  if find_row < 0 then
    return -1
  end
  return client_obj:QueryRecord("HomeWuXueRec", find_row, HWX_INDEX_RENT_GOLD)
end
function faculty_curlevel(client_obj, wuxue_id)
  if not nx_is_valid(client_obj) then
    return 0
  end
  local find_row = client_obj:FindRecordRow("HomeWuXueRec", HWX_INDEX_WUXUE_ID, nx_string(wuxue_id), 0)
  if find_row < 0 then
    return 0
  end
  return client_obj:QueryRecord("HomeWuXueRec", find_row, HWX_INDEX_WUXUE_LEVEL)
end
function faculty_maxlevel(client_obj, wuxue_id)
  if not nx_is_valid(client_obj) then
    return 0
  end
  local find_row = client_obj:FindRecordRow("HomeWuXueRec", HWX_INDEX_WUXUE_ID, nx_string(wuxue_id), 0)
  if find_row < 0 then
    return 0
  end
  return client_obj:QueryRecord("HomeWuXueRec", find_row, HWX_INDEX_FACULTY_LEVEL)
end
function faculty_consume(wuxue_id, level)
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return 0
  end
  local consume_value = ini:ReadString(index, "upgradeconsume", "")
  local consume_list = util_split_string(consume_value, ";")
  for i = table.getn(consume_list), 1, -1 do
    local level_info = util_split_string(consume_list[i], ",")
    if table.getn(level_info) > 1 and nx_number(level) >= nx_number(level_info[1]) then
      return nx_number(level_info[2])
    end
  end
  return 0
end
function upgrade_item(wuxue_id, upgrade_level, upgrade_type)
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return "", 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return "", 0
  end
  local upgradeitem_value = ini:ReadString(index, "upgradeitem", "")
  local find_index = 0
  local upgradeitem_list = util_split_string(upgradeitem_value, ";")
  for i = table.getn(upgradeitem_list), 1, -1 do
    local upgradeitem_info = util_split_string(upgradeitem_list[i], ",")
    if table.getn(upgradeitem_info) > 1 and nx_number(upgrade_level) >= nx_number(upgradeitem_info[1]) then
      find_index = nx_number(upgradeitem_info[2])
      break
    end
  end
  if find_index <= 0 then
    return "", 0
  end
  local upgradeitem_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueItemUpgrade.ini")
  if not nx_is_valid(upgradeitem_ini) then
    return "", 0
  end
  local sec_index = upgradeitem_ini:FindSectionIndex(nx_string(find_index))
  if sec_index < 0 then
    return "", 0
  end
  local item_name = nx_string(nx_number(upgrade_type) + 1)
  local item_index = upgradeitem_ini:FindSectionItemIndex(sec_index, nx_string(item_name))
  if item_index < 0 then
    return "", 0
  end
  local item_value = upgradeitem_ini:GetSectionItemValue(sec_index, item_index)
  local item_list = util_split_string(item_value, ",")
  if table.getn(item_list) < 2 then
    return "", 0
  end
  return nx_string(item_list[1]), nx_number(item_list[2])
end
function upgrade_curitemnum(client_obj, wuxue_id, upgrade_type)
  if not nx_is_valid(client_obj) then
    return 0
  end
  local find_row = client_obj:FindRecordRow("HomeWuXueRec", HWX_INDEX_WUXUE_ID, nx_string(wuxue_id), 0)
  if find_row < 0 then
    return 0
  end
  if upgrade_type == UPGRADE_TYPE_F_ITEM then
    return client_obj:QueryRecord("HomeWuXueRec", find_row, HWX_INDEX_F_ITEM_SUM)
  elseif upgrade_type == UPGRADE_TYPE_S_ITEM then
    return client_obj:QueryRecord("HomeWuXueRec", find_row, HWX_INDEX_S_ITEM_SUM)
  end
  return 0
end
function rent_silver_amount(wuxue_id, level, days)
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return 0
  end
  local silver_value = ini:ReadString(index, "rentmoney", "")
  local find_index = 0
  local silver_list = util_split_string(silver_value, ";")
  for i = table.getn(silver_list), 1, -1 do
    local silver_info = util_split_string(silver_list[i], ",")
    if table.getn(silver_info) > 1 and nx_number(level) >= nx_number(silver_info[1]) then
      find_index = nx_number(silver_info[2])
      break
    end
  end
  if find_index <= 0 then
    return 0
  end
  local silver_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueSilverRent.ini")
  if not nx_is_valid(silver_ini) then
    return 0
  end
  local sec_index = silver_ini:FindSectionIndex(nx_string(find_index))
  if sec_index < 0 then
    return 0
  end
  local item_index = silver_ini:FindSectionItemIndex(sec_index, nx_string(days))
  if item_index < 0 then
    return 0
  end
  return silver_ini:GetSectionItemValue(sec_index, item_index)
end
function rent_item_amount(wuxue_id, level, days)
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return "", 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return "", 0
  end
  local find_index = 0
  local item_value = ini:ReadString(index, "rentitem", "")
  local item_list = util_split_string(item_value, ";")
  for i = table.getn(item_list), 1, -1 do
    local item_info = util_split_string(item_list[i], ",")
    if table.getn(item_info) > 1 and nx_number(level) >= nx_number(item_info[1]) then
      find_index = nx_number(item_info[2])
      break
    end
  end
  if find_index <= 0 then
    return "", 0
  end
  local item_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueItemRent.ini")
  if not nx_is_valid(item_ini) then
    return "", 0
  end
  local sec_index = item_ini:FindSectionIndex(nx_string(find_index))
  if sec_index < 0 then
    return "", 0
  end
  local item_index = item_ini:FindSectionItemIndex(sec_index, nx_string(days))
  if item_index < 0 then
    return "", 0
  end
  local ret_value = item_ini:GetSectionItemValue(sec_index, item_index)
  local ret_info = util_split_string(ret_value, ",")
  if table.getn(ret_info) < 2 then
    return "", 0
  end
  return nx_string(ret_info[1]), nx_number(ret_info[2])
end
function rent_silver_days_list(wuxue_id, level)
  local days_list = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return days_list
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return days_list
  end
  local silver_value = ini:ReadString(index, "rentmoney", "")
  local find_index = 0
  local silver_list = util_split_string(silver_value, ";")
  for i = table.getn(silver_list), 1, -1 do
    local silver_info = util_split_string(silver_list[i], ",")
    if table.getn(silver_info) > 1 and nx_number(level) >= nx_number(silver_info[1]) then
      find_index = nx_number(silver_info[2])
      break
    end
  end
  if find_index <= 0 then
    return days_list
  end
  local silver_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueSilverRent.ini")
  if not nx_is_valid(silver_ini) then
    return days_list
  end
  local sec_index = silver_ini:FindSectionIndex(nx_string(find_index))
  if sec_index < 0 then
    return days_list
  end
  local item_count = silver_ini:GetSectionItemCount(sec_index)
  for j = 1, item_count do
    local item_key = silver_ini:GetSectionItemKey(sec_index, j - 1)
    table.insert(days_list, nx_number(item_key))
  end
  table.sort(days_list)
  return days_list
end
function rent_item_days_list(wuxue_id, level)
  local days_list = {}
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return days_list
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return days_list
  end
  local find_index = 0
  local item_value = ini:ReadString(index, "rentitem", "")
  local item_list = util_split_string(item_value, ";")
  for i = table.getn(item_list), 1, -1 do
    local item_info = util_split_string(item_list[i], ",")
    if table.getn(item_info) > 1 and nx_number(level) >= nx_number(item_info[1]) then
      find_index = nx_number(item_info[2])
      break
    end
  end
  if find_index <= 0 then
    return days_list
  end
  local item_ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueItemRent.ini")
  if not nx_is_valid(item_ini) then
    return days_list
  end
  local sec_index = item_ini:FindSectionIndex(nx_string(find_index))
  if sec_index < 0 then
    return days_list
  end
  local item_count = item_ini:GetSectionItemCount(sec_index)
  for j = 1, item_count do
    local item_key = item_ini:GetSectionItemKey(sec_index, j - 1)
    table.insert(days_list, nx_number(item_key))
  end
  table.sort(days_list)
  return days_list
end
function rent_gold_amount(wuxue_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Home\\HomeWuxueConf.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(wuxue_id))
  if index < 0 then
    return 0
  end
  local free_rent_count = ini:ReadInteger(index, "free_rent_count", 45)
  local rent_count = home_wuxue_rent_count(wuxue_id)
  if nx_number(rent_count) >= nx_number(free_rent_count) then
    return 0
  end
  return ini:ReadInteger(index, "once_money", 0)
end
function get_item_num(item_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local box_list = {VIEWPORT_TOOL, VIEWPORT_MATERIAL_TOOL}
  local item_num = 0
  for i = 1, table.getn(box_list) do
    local toolbox = game_client:GetView(nx_string(box_list[i]))
    if not nx_is_valid(toolbox) then
      return 0
    end
    local toolbox_objlist = toolbox:GetViewObjList()
    for j, obj in pairs(toolbox_objlist) do
      local config_id = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(config_id), nx_widestr(item_id)) then
        item_num = nx_number(item_num) + nx_number(obj:QueryProp("Amount"))
      end
    end
  end
  return item_num
end
function home_wuxue_rent_count(wuxue_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local find_row = client_player:FindRecordRow(HOME_WUXUE_RENT_REC, HWR_INDEX_WUXUE_ID, nx_string(wuxue_id))
  if find_row < 0 then
    return 0
  end
  return client_player:QueryRecord(HOME_WUXUE_RENT_REC, find_row, HWR_INDEX_RENT_COUNT)
end
function price_to_text(price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = util_text("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = util_text("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = util_text("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
function parse_days(day_text, index)
  if day_text == "" or day_text == nil then
    return 0
  end
  local days_list = util_split_string(day_text, "|")
  if index > table.getn(days_list) then
    return 0
  end
  return nx_number(days_list[index])
end
function get_format_str(str_id, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return str_id
  end
  gui.TextManager:Format_SetIDName(str_id)
  for i, para in pairs(arg) do
    local para_type = nx_type(para)
    if para_type == "number" then
      gui.TextManager:Format_AddParam(nx_int(para))
    elseif para_type == "string" then
      gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
    else
      gui.TextManager:Format_AddParam(para)
    end
  end
  return gui.TextManager:Format_GetText()
end
