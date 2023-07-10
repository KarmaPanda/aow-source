require("util_gui")
require("tips_data")
require("custom_sender")
require("util_functions")
require("util_static_data")
require("share\\itemtype_define")
require("share\\client_custom_define")
local FORM_CHEST = "form_stage_main\\form_treasure_chest"
local TREASURE_CHEST_REC = "chestitem_rec"
local ITEM_ROW_COUNT = 2
local ITEM_COL_COUNT = 3
local ITEM_PAGE_COUNT = 6
local chest_all = 0
local chest_collect = 1
local chest_not_collect = 2
local COLLECT_IMAGE = "gui\\special\\baibaoxiang\\Cbg_2_out.png"
local NOT_COLLECT_IMAGE = "gui\\special\\baibaoxiang\\Cbg_1_out.png"
local ITEM_TEMPLATE = "groupbox_item_template"
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_size(form)
  init_form_data(form)
  add_data_bind(form)
  return 1
end
function on_main_form_close(form)
  del_data_bind(form)
  nx_destroy(form)
  custom_treasure_chest(2)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_form_data(form)
  form.item_list = ""
  form.item_id = ""
  form.chest_id = ""
  form.pageno = 1
  form.maxpageno = 1
  form.collect_type = chest_all
  form.rbtn_all.Checked = true
end
function set_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function change_form_size()
  local form = nx_value(FORM_CHEST)
  if not nx_is_valid(form) then
    return
  end
  set_form_size(form)
end
function set_form_data(form, chest_id)
  form.chest_id = chest_id
  set_type(form, chest_id)
  set_item_list(form)
  set_collect(form)
end
function on_server_msg(...)
  if nx_int(table.getn(arg)) < nx_int(1) then
    return
  end
  local sub_msg = arg[1]
  if nx_number(1) == nx_number(sub_msg) then
    if nx_int(table.getn(arg)) < nx_int(2) then
      return
    end
    local chest_id = arg[2]
    local form = util_show_form(FORM_CHEST, true)
    if not nx_is_valid(form) then
      return
    end
    init_form_data(form)
    set_form_data(form, chest_id)
  end
end
function set_type(form, chest_id)
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return
  end
  local list = mgr:get_treasure_chest_config(chest_id)
  local count = table.getn(list)
  if count % 2 ~= 0 then
    return
  end
  form.groupscrollbox_type:DeleteAll()
  form.groupscrollbox_type.IsEditMode = true
  for i = 1, count / 2 do
    local index = (i - 1) * 2 + 1
    local t = list[index]
    local item_list = list[index + 1]
    local rbtn = create_type(form, i, t)
    if nx_is_valid(rbtn) then
      rbtn.Left = 10
      rbtn.Top = (i - 1) * (rbtn.Height + 3) + 6
      form.groupscrollbox_type:Add(rbtn)
      rbtn.item_list = item_list
      if rbtn.Checked then
        form.item_list = rbtn.item_list
      end
    end
  end
  form.groupscrollbox_type.IsEditMode = false
  form.groupscrollbox_type.HasVScroll = true
  form.groupscrollbox_type.VScrollBar.Value = 0
end
function create_type(form, i, t)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local rbtn = gui:Create("RadioButton")
  if not nx_is_valid(rbtn) then
    return nil
  end
  set_copy_ent_info(form, "rbtn_type_template", rbtn)
  rbtn.Name = "rbtn_type" .. nx_string(i)
  rbtn.TabIndex = i
  if i == 1 then
    rbtn.Checked = true
  end
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return nil
  end
  local list = mgr:get_treasure_chest_type_config(t)
  local count = table.getn(list)
  if count % 3 ~= 0 then
    return nil
  end
  for i = 1, count / 3 do
    local index = (i - 1) * 3 + 1
    rbtn.NormalImage = list[index]
    rbtn.FocusImage = list[index + 1]
    rbtn.CheckedImage = list[index + 2]
  end
  nx_bind_script(rbtn, nx_current())
  nx_callback(rbtn, "on_checked_changed", "on_rbtn_type_click")
  return rbtn
end
function on_rbtn_type_click(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.item_list = rbtn.item_list
    form.pageno = 1
    set_item_list(form)
  end
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function set_item_list(form)
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return
  end
  form.groupbox_list:DeleteAll()
  local list = mgr:get_treasure_chest_item_list(form.item_list, form.collect_type)
  local count = table.getn(list)
  local begin_pos = (form.pageno - 1) * ITEM_PAGE_COUNT + 1
  local end_pos = form.pageno * ITEM_PAGE_COUNT
  if count < end_pos then
    end_pos = count
  end
  if count == 0 then
    form.lbl_page.Text = nx_widestr("0") .. nx_widestr("/") .. nx_widestr("0")
    return
  end
  if count % ITEM_PAGE_COUNT == 0 then
    form.maxpageno = nx_int(count / ITEM_PAGE_COUNT)
  else
    form.maxpageno = nx_int(count / ITEM_PAGE_COUNT) + 1
  end
  local index = 1
  for i = begin_pos, end_pos do
    local item_id = list[i]
    local groupbox = create_item(form, index, item_id)
    if nx_is_valid(groupbox) then
      groupbox.Left = nx_int((index - 1) % ITEM_COL_COUNT) * (groupbox.Width + 6) + 10
      groupbox.Top = nx_int((index - 1) / ITEM_COL_COUNT) * (groupbox.Height + 3) + 10
      form.groupbox_list:Add(groupbox)
      index = index + 1
    end
  end
  form.lbl_page.Text = nx_widestr(form.pageno) .. nx_widestr("/") .. nx_widestr(form.maxpageno)
end
function create_item(form, i, item_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_palyer = game_client:GetPlayer()
  if not nx_is_valid(client_palyer) then
    return
  end
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return nil
  end
  local groupbox = create_item_groupbox(form, i, ITEM_TEMPLATE)
  if not nx_is_valid(groupbox) then
    return nil
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return nil
  end
  local grid = groupbox:Find("imagegrid_item" .. nx_string(i))
  if nx_is_valid(grid) then
    grid.item_id = item_id
    local photo = item_query_ArtPack_by_id(item_id, "Photo")
    local item_type = item_query:GetItemPropByConfigID(item_id, "ItemType")
    local sex = client_palyer:QueryProp("Sex")
    if nx_number(item_type) >= ITEMTYPE_EQUIP_MIN and nx_number(item_type) <= ITEMTYPE_EQUIP_MAX and 0 ~= sex then
      local tmp_photo = item_query_ArtPack_by_id(item_id, "FemalePhoto")
      if nil ~= tmp_photo and "" ~= tmp_photo then
        photo = tmp_photo
      end
    end
    grid:AddItem(0, photo, "", 1, -1)
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_right_click", "on_grid_item_click")
    nx_callback(grid, "on_select_changed", "on_grid_item_click")
    nx_callback(grid, "on_mousein_grid", "on_grid_item_mousein")
    nx_callback(grid, "on_mouseout_grid", "on_grid_item_mouseout")
  end
  local name = groupbox:Find("lbl_item_name" .. nx_string(i))
  if nx_is_valid(name) then
    name.Text = util_text(item_id)
  end
  local is_collect = mgr:is_treasure_chest_item_collect(item_id)
  local collect = groupbox:Find("lbl_item_collect" .. nx_string(i))
  if nx_is_valid(collect) then
    if is_collect then
      collect.BackImage = COLLECT_IMAGE
    else
      collect.BackImage = NOT_COLLECT_IMAGE
    end
  end
  local lbl_select = groupbox:Find("lbl_select" .. nx_string(i))
  if nx_is_valid(lbl_select) then
    lbl_select.Visible = false
    grid.lbl_select = lbl_select
  end
  local cooldown = groupbox:Find("mltbox_cooldown" .. nx_string(i))
  if nx_is_valid(cooldown) then
    cooldown:Clear()
    local cd_time = mgr:get_treasure_chest_item_cd(item_id)
    if 0 < cd_time then
      gui.TextManager:Format_SetIDName("ui_baibaoxiang_001")
      gui.TextManager:Format_AddParam(nx_int(cd_time))
      local text = nx_widestr(gui.TextManager:Format_GetText())
      cooldown:AddHtmlText(text, -1)
    end
  end
  local lbl_cd = groupbox:Find("lbl_cooldown" .. nx_string(i))
  if nx_is_valid(lbl_cd) then
    local cd_time = mgr:get_treasure_chest_item_cd(item_id)
    if 0 < cd_time then
      lbl_cd.Visible = true
    else
      lbl_cd.Visible = false
    end
  end
  return groupbox
end
function create_item_groupbox(form, index, temp_name)
  local source_ent = nx_custom(form, temp_name)
  if not nx_is_valid(source_ent) then
    return nil
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nil
  end
  local groupbox = gui:Create("GroupBox")
  if not nx_is_valid(groupbox) then
    return nil
  end
  groupbox.Name = temp_name .. nx_string(index)
  set_copy_ent_info(form, temp_name, groupbox)
  local child_ctrls = source_ent:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    if nx_is_valid(ctrl_obj) then
      set_copy_ent_info(form, ctrl.Name, ctrl_obj)
      ctrl_obj.Name = ctrl.Name .. nx_string(index)
      if nx_string(nx_name(ctrl)) == "MultiTextBox" then
        copy_scrollbar(ctrl_obj, ctrl)
      end
      groupbox:Add(ctrl_obj)
    end
  end
  return groupbox
end
function copy_scrollbar(richedit, tpl_richedit)
  if nx_is_valid(richedit.VScrollBar) and nx_is_valid(tpl_richedit.VScrollBar) then
    local vscrollbar = richedit.VScrollBar
    local tpl_vscrollbar = tpl_richedit.VScrollBar
    vscrollbar.BackColor = tpl_vscrollbar.BackColor
    vscrollbar.ButtonSize = tpl_vscrollbar.ButtonSize
    vscrollbar.FullBarBack = tpl_vscrollbar.FullBarBack
    vscrollbar.ShadowColor = tpl_vscrollbar.ShadowColor
    vscrollbar.BackImage = tpl_vscrollbar.BackImage
    vscrollbar.NoFrame = tpl_vscrollbar.NoFrame
    vscrollbar.DrawMode = tpl_vscrollbar.DrawMode
    vscrollbar.DecButton.NormalImage = tpl_vscrollbar.DecButton.NormalImage
    vscrollbar.DecButton.FocusImage = tpl_vscrollbar.DecButton.FocusImage
    vscrollbar.DecButton.PushImage = tpl_vscrollbar.DecButton.PushImage
    vscrollbar.DecButton.Width = tpl_vscrollbar.DecButton.Width
    vscrollbar.DecButton.Height = tpl_vscrollbar.DecButton.Height
    vscrollbar.DecButton.DrawMode = tpl_vscrollbar.DecButton.DrawMode
    vscrollbar.IncButton.NormalImage = tpl_vscrollbar.IncButton.NormalImage
    vscrollbar.IncButton.FocusImage = tpl_vscrollbar.IncButton.FocusImage
    vscrollbar.IncButton.PushImage = tpl_vscrollbar.IncButton.PushImage
    vscrollbar.IncButton.Width = tpl_vscrollbar.IncButton.Width
    vscrollbar.IncButton.Height = tpl_vscrollbar.IncButton.Height
    vscrollbar.IncButton.DrawMode = tpl_vscrollbar.IncButton.DrawMode
    vscrollbar.TrackButton.NormalImage = tpl_vscrollbar.TrackButton.NormalImage
    vscrollbar.TrackButton.FocusImage = tpl_vscrollbar.TrackButton.FocusImage
    vscrollbar.TrackButton.PushImage = tpl_vscrollbar.TrackButton.PushImage
    vscrollbar.TrackButton.Width = tpl_vscrollbar.TrackButton.Width
    vscrollbar.TrackButton.Height = tpl_vscrollbar.TrackButton.Height
    vscrollbar.TrackButton.Enabled = tpl_vscrollbar.TrackButton.Enabled
    vscrollbar.TrackButton.DrawMode = tpl_vscrollbar.TrackButton.DrawMode
  end
end
function on_grid_item_click(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.item_id = grid.item_id
  clear_select(form)
  local lbl_select = grid.lbl_select
  if nx_is_valid(lbl_select) then
    lbl_select.Visible = true
  end
end
function on_grid_item_mousein(grid, index)
  local item_id = grid.item_id
  if nx_string("") == nx_string(item_id) then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local item_type = item_query:GetItemPropByConfigID(item_id, "ItemType")
  nx_execute("tips_game", "show_tips_common", item_id, nx_number(item_type), x, y, grid.ParentForm)
end
function on_grid_item_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = form.pageno
  page = page - 1
  if 0 < page then
    form.pageno = page
  end
  set_item_list(form)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = form.pageno
  page = page + 1
  if page <= form.maxpageno then
    form.pageno = page
  end
  set_item_list(form)
end
function on_rbtn_collect_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.collect_type = nx_int(rbtn.DataSource)
    form.pageno = 1
    set_item_list(form)
  end
end
function add_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:AddTableBind(TREASURE_CHEST_REC, form, nx_current(), "on_chest_rec_change")
end
function del_data_bind(form)
  local data_binder = nx_value("data_binder")
  if not nx_is_valid(data_binder) then
    return
  end
  data_binder:DelTableBind(TREASURE_CHEST_REC, form)
end
function on_chest_rec_change(bind_id, rec_name, op_type, row, col)
  if not nx_is_valid(bind_id) then
    return
  end
  local form = nx_value(FORM_CHEST)
  if not nx_is_valid(form) then
    return
  end
  set_item_list(form)
  set_collect(form)
end
function on_btn_takeout_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local item_id = form.item_id
  if item_id == "" then
    return
  end
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return
  end
  local is_collect = mgr:is_treasure_chest_item_collect(item_id)
  if not is_collect then
    show_system_notice("sys_baibaoxiang_001")
    return
  end
  custom_treasure_chest(1, item_id)
end
function set_collect(form)
  local mgr = nx_value("attire_manager")
  if not nx_is_valid(mgr) then
    return
  end
  local pbar = form.pbar_collect
  if not nx_is_valid(pbar) then
    return
  end
  local info = mgr:get_treasure_chest_collect_info(form.chest_id)
  if table.getn(info) ~= 2 then
    return
  end
  pbar.Minimun = 0
  pbar.Maximum = info[2]
  pbar.Value = info[1]
  form.lbl_progress.Text = nx_widestr(info[1]) .. nx_widestr("/") .. nx_widestr(info[2])
end
function show_system_notice(text_id)
  local gui = nx_value("gui")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText(text_id), 2)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function clear_select(form)
  for i = 1, ITEM_PAGE_COUNT do
    local groupbox = form.groupbox_list:Find(ITEM_TEMPLATE .. nx_string(i))
    if nx_is_valid(groupbox) then
      local lbl = groupbox:Find("lbl_select" .. nx_string(i))
      if nx_is_valid(lbl) then
        lbl.Visible = false
      end
    end
  end
end
