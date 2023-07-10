require("util_functions")
require("share\\view_define")
require("util_gui")
require("define\\gamehand_type")
require("share\\itemtype_define")
require("share\\chat_define")
require("const_define")
require("define\\object_type_define")
require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\npc_type_define")
require("util_vip")
local form_name = "form_stage_main\\form_life\\form_job_gather"
NODE_TYPE_GATHER = 1
NODE_TYPE_COMPOSITE = 2
NODE_TYPE_OTHER = 3
local JOB_ID_TABLE = {}
local sortString = ""
local sortClass = ""
function on_open_form(form, ...)
  form.JobID = arg[1]
  if nx_string(form.JobID) == "" or form.JobID == nil then
    return
  end
  form.CurFormulaID = ""
  fresh_form(form, nx_string(form.JobID))
end
function get_life_form_visible()
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form) then
    return form.Visible
  else
    return false
  end
end
function main_form_init(self)
  self.Fixed = true
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return 0
  end
  nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_drop.ini")
  main_form = self
  self.store_select_job = nil
  self.JobID = ""
  self.CurFormulaID = ""
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("job_rec", self, form_name, "on_job_rec_refresh")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("job_rec", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function fresh_form(form, jobid)
  if not nx_is_valid(form) or jobid == "" then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.store_select_sort = nil
  form.store_select_search = nil
  local job_name = gui.TextManager:GetText(nx_string(jobid))
  form.lbl_job_name.Text = nx_widestr(job_name)
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  form.ipt_2.Text = nx_widestr(Text_ss)
  local nowscene = get_cur_scene_name()
  if nowscene == nil or nowscene == "" or "sh_nf" == nx_string(jobid) then
    sortClass = gui.TextManager:GetFormatText("str_quanbu")
  else
    local gather_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
    local map_index = gather_ini:FindSectionIndex("map")
    local map_info = gather_ini:ReadString(map_index, nx_string(1), "")
    local map_lst = util_split_string(map_info, ",")
    for i = 1, table.getn(map_lst) do
      local map_typeid = nx_string(map_lst[i])
      local submap_index = gather_ini:FindSectionIndex(map_typeid)
      local submap_info = gather_ini:ReadString(submap_index, nx_string(jobid), "")
      local submap_lst = util_split_string(submap_info, ",")
      for j = 1, table.getn(submap_lst) do
        local submap_name = gui.TextManager:GetFormatText(submap_lst[j])
        if submap_name == nowscene then
          sortClass = gui.TextManager:GetFormatText(map_typeid)
          break
        end
      end
    end
  end
  fresh_form_job(form, jobid)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
end
function on_formula_rec_refresh(self, recordname, optype, row, clomn)
  fresh_form_job(self)
end
function clear_info(form)
  form.tree_job:CreateRootNode(nx_widestr(""))
  form.combobox_sort.Text = nx_widestr("")
  form.combobox_sort.DropListBox:ClearString()
  return 1
end
function fresh_form_job(form, jobid)
  if not nx_is_valid(form) or jobid == "" then
    return
  end
  clear_info(form)
  refresh_tree_list(form, jobid)
end
function on_job_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if optype == "update" then
    fresh_form(form, nx_string(form.JobID))
  end
end
function refresh_tree_list(form, jobid)
  if not nx_is_valid(form) or jobid == "" then
    return
  end
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
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local jobinfoini = nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  local gather_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  if not nx_is_valid(jobinfoini) or not nx_is_valid(gather_ini) then
    return
  end
  local map_index = gather_ini:FindSectionIndex("map")
  local map_info = gather_ini:ReadString(map_index, nx_string(1), "")
  local map_lst = util_split_string(map_info, ",")
  local sec_index = jobinfoini:FindSectionIndex(nx_string(jobid))
  if sec_index < 0 then
    return
  end
  local type_nameid1 = jobinfoini:ReadString(sec_index, "type1", "")
  local type_name1 = nx_string(gui.TextManager:GetFormatText(nx_string(type_nameid1)))
  if type_name1 == "" then
    return
  end
  local map_root = form.tree_job:CreateRootNode(nx_widestr(type_name1))
  map_root.search_id = type_name1
  local str_quanbu = gui.TextManager:GetFormatText("str_quanbu")
  form.combobox_sort.DropListBox:AddString(nx_widestr(str_quanbu))
  local isNull = true
  local selectNode
  for i = 1, table.getn(map_lst) do
    local map_typeid = nx_string(map_lst[i])
    local sec_index1 = gather_ini:FindSectionIndex(map_typeid)
    if sec_index1 < 0 then
      return
    end
    local map_type = gui.TextManager:GetFormatText(map_typeid)
    form.combobox_sort.DropListBox:AddString(map_type)
    local submap_index = gather_ini:FindSectionIndex(map_typeid)
    local submap_info = gather_ini:ReadString(submap_index, nx_string(jobid), "")
    local submap_lst = util_split_string(submap_info, ",")
    if nx_widestr(sortClass) == nx_widestr(str_quanbu) or nx_widestr(sortClass) == nx_widestr(map_type) then
      form.combobox_sort.Text = nx_widestr(sortClass)
      local map_type_node = map_root:CreateNode(map_type)
      map_type_node.search_id = nx_string(map_type)
      map_type_node.has_child = false
      map_type_node.has_valid_child = false
      map_type_node.DrawMode = "FitWindow"
      map_type_node.ExpandCloseOffsetX = 0
      map_type_node.ExpandCloseOffsetY = 2
      map_type_node.TextOffsetX = 25
      map_type_node.TextOffsetY = 1
      map_type_node.NodeOffsetY = 5
      map_type_node.Font = "font_main"
      map_type_node.ForeColor = "255,255,180,0"
      map_type_node.NodeBackImage = get_treeview_bg(2, "out")
      map_type_node.NodeFocusImage = get_treeview_bg(2, "on")
      map_type_node.NodeSelectImage = get_treeview_bg(2, "on")
      for j = 1, table.getn(submap_lst) do
        local submap_id = nx_string(submap_lst[j])
        local node_name = gui.TextManager:GetFormatText(submap_id)
        isNull = false
        if sortString == nx_widestr("") or -1 ~= nx_function("ext_ws_find", node_name, sortString) then
          local subnode = map_type_node:CreateNode(node_name)
          subnode.gather_id = submap_lst[j]
          subnode.search_id = node_name
          map_type_node.has_child = true
          map_type_node.has_valid_child = true
          subnode.TextOffsetX = 25
          subnode.TextOffsetY = 1
          subnode.Font = "font_main"
          subnode.NodeBackImage = get_treeview_bg(3, "out")
          subnode.NodeFocusImage = get_treeview_bg(3, "on")
          subnode.NodeSelectImage = get_treeview_bg(3, "on")
          if nx_is_valid(subnode) and not nx_is_valid(selectNode) then
            selectNode = subnode
          end
          if nx_is_valid(subnode) and item_id == form.CurFormulaID then
            selectNode = subnode
          end
        end
      end
      if map_type_node.has_child == false then
        map_root:RemoveNode(map_type_node)
      end
    end
  end
  form.tree_job.SelectNode = selectNode
  if isNull then
    form.ipt_2.Text = nx_widestr(gui.TextManager:GetText("ui_sh_wcj"))
  else
    map_root:ExpandAll()
  end
end
function get_node(root, id)
  if not nx_is_valid(root) then
    return nx_null()
  end
  if nx_string(root.search_id) == nx_string(id) then
    return root
  end
  local node_list = root:GetNodeList()
  local node_count = root:GetNodeCount()
  for i = 1, node_count do
    local node = get_node(node_list[i], id)
    if nx_is_valid(node) then
      return node
    end
  end
  return nx_null()
end
function get_treeview_bg(bglvl, bgtype)
  local path = "gui\\common\\treeview\\tree_" .. nx_string(bglvl) .. "_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function on_tree_job_select_changed(self)
  local node = self.SelectNode
  fresh_sub_info(self.ParentForm)
  if nx_find_custom(node, "help_node") and node.help_node then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    node.help_node = false
  end
end
function get_down_node(node)
  if not nx_is_valid(node) then
    return nx_null()
  end
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    local node_list = node:GetNodeList()
    return get_down_node(node_list[1])
  else
    return node
  end
  return nx_null()
end
function on_material_imagegrid_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(index, nx_int(1))
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
  if not bExist then
    return
  end
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
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  grid.Data.is_static = true
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_material_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function fresh_sub_info(self)
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local node = get_down_node(self.tree_job.SelectNode)
  local drop_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_drop.ini")
  local drop_index = drop_ini:FindSectionIndex(node.gather_id)
  local drop_info = drop_ini:ReadString(drop_index, "CommonDrop", "")
  local drop_lst = util_split_string(drop_info, ",")
  local has_place = false
  local groupbox_tmp = self.groupbox_1
  local groupbox_material = groupbox_tmp:Find("groupbox_materials")
  groupbox_material:DeleteAll()
  local group_top = 0
  local groupbox_row, groupbox_column
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  for i = 1, table.getn(drop_lst) do
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(drop_lst[i]), nx_string("Photo"))
    if has_place == false then
      groupbox_row = gui:Create("GroupBox")
      groupbox_material:Add(groupbox_row)
      groupbox_row.AutoSize = false
      groupbox_row.BackColor = "0,0,0,0"
      groupbox_row.DrawMode = "FitWindow"
      groupbox_row.NoFrame = true
      groupbox_row.Left = 0
      groupbox_row.Top = group_top
      groupbox_row.Width = 414
      groupbox_row.Height = 205
      groupbox_column = gui:Create("GroupBox")
      groupbox_row:Add(groupbox_column)
      groupbox_column.gather_list = node.gather_id
      groupbox_column.AutoSize = false
      groupbox_column.BackColor = "0,0,0,0"
      groupbox_column.DrawMode = "FitWindow"
      groupbox_column.NoFrame = true
      groupbox_column.Left = 0
      groupbox_column.Top = 0
      groupbox_column.Width = 387
      groupbox_column.Height = 107
      has_place = true
    else
      groupbox_column = gui:Create("GroupBox")
      groupbox_row:Add(groupbox_column)
      groupbox_column.gather_list = node.gather_id
      groupbox_column.AutoSize = false
      groupbox_column.BackColor = "0,0,0,0"
      groupbox_column.DrawMode = "FitWindow"
      groupbox_column.NoFrame = true
      groupbox_column.Left = 0
      groupbox_column.Top = 107
      groupbox_column.Width = 387
      groupbox_column.Height = 107
      has_place = false
    end
    local imagegrid = gui:Create("ImageControlGrid")
    groupbox_column:Add(imagegrid)
    imagegrid.AutoSize = true
    imagegrid.Width = 50
    imagegrid.Height = 50
    imagegrid.DrawGridBack = "gui\\special\\life\\bg_sub2.png"
    imagegrid.DrawMode = "Expand"
    imagegrid.NoFrame = true
    imagegrid.HasVScroll = false
    imagegrid.Left = 30
    imagegrid.Top = 20
    imagegrid.RowNum = 1
    imagegrid.ClomnNum = 1
    imagegrid.GridWidth = 50
    imagegrid.GridHeight = 50
    imagegrid.RoundGrid = false
    imagegrid.GridBackOffsetX = -10
    imagegrid.GridBackOffsetY = -10
    imagegrid.BackColor = "0,0,0,0"
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.CoverColor = "0,0,0,0"
    imagegrid.ViewRect = "0,0,67,67"
    imagegrid:AddItem(0, photo, "", 1, -1)
    imagegrid:SetItemAddInfo(0, nx_int(1), nx_widestr(nx_string(drop_lst[i])))
    nx_bind_script(imagegrid, nx_current(), "")
    nx_callback(imagegrid, "on_mousein_grid", "on_material_imagegrid_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_material_imagegrid_mouseout_grid")
    local gather_lbl = gui:Create("MultiTextBox")
    groupbox_column:Add(gather_lbl)
    gather_lbl.Left = 90
    gather_lbl.Top = 20
    gather_lbl.TextColor = "255,95,67,37"
    gather_lbl.Font = "font_treeview"
    gather_lbl.ShadowColor = "255,255,255,255"
    gather_lbl.NoFrame = true
    gather_lbl.Height = 55
    gather_lbl.Width = 300
    gather_lbl.ViewRect = "0,0,240,55"
    gather_lbl.Transparent = true
    gather_lbl.HtmlText = gui.TextManager:GetText(drop_lst[i])
  end
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "gather_list") then
    return
  end
  if not nx_find_custom(node, "gather_type") then
    return
  end
  fresh_gather(self, node.gather_type, node.gather_list)
end
function get_item_info(id, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(gui) or not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(id))
  if not bExist then
    return nil
  end
  local retstr = ItemQuery:GetItemPropByConfigID(nx_string(id), nx_string(prop))
  return retstr
end
function show_item_info(form, gather_type, gather_item)
  if not nx_is_valid(form) then
    return
  end
  if gather_item == "" or gather_item == "nil" then
    return
  end
  form.CurFormulaID = gather_item
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local jobinfoini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_drop.ini")
  if not nx_is_valid(jobinfoini) then
    return
  end
  local jobid = nx_string(form.JobID)
  if jobid == "" or jobid == "nil" then
    return
  end
  local exp_index = -1
  local exp_package = 0
  local exp_needlvl = 0
  local exp_jobid = ""
  local needene = 0
  if nx_string(jobid) == "sh_lh" then
    if not ItemQuery:FindItemByConfigID(nx_string(gather_item)) then
      return
    end
    exp_package = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("LifeExpPackage"))
    exp_needlvl = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("SkinPara2"))
    exp_jobid = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("SkinPara1"))
    needene = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("NeedEne"))
  else
    if not ItemQuery:FindItemByConfigID(nx_string(gather_item)) then
      return
    end
    exp_package = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("LifeExpPackage"))
    exp_needlvl = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("GatherPara2"))
    exp_jobid = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("GatherPara1"))
    needene = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("NeedEne"))
    if nx_string(jobid) == "sh_nf" then
      local seedid = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("SeedId"))
      if not ItemQuery:FindItemByConfigID(nx_string(seedid)) then
        return
      end
      needene = ItemQuery:GetItemPropByConfigID(nx_string(seedid), nx_string("NeedEne"))
    end
  end
  local Text_cjdj = ""
  if nx_string(exp_jobid) == nx_string(jobid) and nx_int(exp_needlvl) > nx_int(0) then
    if nx_string(form.JobID) == "sh_nf" then
      Text_cjdj = gui.TextManager:GetFormatText("ui_sh_cjnf", nx_int(exp_needlvl), nx_string(gather_type))
    elseif nx_string(form.JobID) == "sh_lh" then
      Text_cjdj = gui.TextManager:GetFormatText("ui_sh_cjlh", nx_int(exp_needlvl))
    else
      Text_cjdj = gui.TextManager:GetFormatText("ui_sh_cjdj", nx_int(exp_needlvl))
    end
  end
  local temp_job_id, job_exp = nx_execute("form_stage_main\\form_life\\form_job_composite", "get_exp_from_package", nx_string(exp_package))
  form.lbl_cjdj.Text = nx_widestr(Text_cjdj)
  if nx_int(needene) > nx_int(0) then
    form.groupbox_ene.Visible = true
    form.lbl_ene_value.Text = nx_widestr(nx_string(needene))
  else
    form.groupbox_ene.Visible = false
  end
  if nx_int(job_exp) > nx_int(0) then
    form.groupbox_exp.Visible = true
    form.lbl_exp_value.Text = nx_widestr(nx_string(job_exp))
  else
    form.groupbox_exp.Visible = false
  end
  local temp_job_id, job_exp = get_exp_from_package(exp_package)
  local Text_tl = gui.TextManager:GetText("ui_sh_xhtl")
  form.mltbox_dec:AddHtmlText(nx_widestr(nx_string(Text_tl) .. nx_string(needene)), nx_int(-1))
  local Text_sl = gui.TextManager:GetText("ui_sh_tssld")
  form.mltbox_dec:AddHtmlText(nx_widestr(nx_string(Text_sl) .. nx_string(job_exp)), nx_int(-1))
  local Text_zsxy = gui.TextManager:GetText("ui_sh_zsxy")
  local Text_hgjgj1 = gui.TextManager:GetText("ui_sh_hgjgj1")
  local tool_name = nx_string(form.lbl_job_name.Text)
  local Text_hgjgj3 = gui.TextManager:GetText("ui_sh_hgjgj3")
  form.mltbox_dec:Clear()
  local sec_index = jobinfoini:FindSectionIndex(nx_string(gather_item))
  if sec_index < 0 then
    return
  end
  local CommonDrop = jobinfoini:ReadString(sec_index, "CommonDrop", "")
  local SepcialDrop = jobinfoini:ReadString(sec_index, "SepcialDrop", "")
  local str_lst = util_split_string(CommonDrop, ",")
  for i = 1, table.getn(str_lst) do
    local item = str_lst[i]
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      local itemname = takeoutmore_str(gui.TextManager:GetText(item))
      form.material_grid:AddItem(i - 1, nx_string(tempphoto), nx_widestr("<font color=\"#5f4325\">" .. itemname .. "</font>"), 0, -1)
      form.material_grid:SetItemAddInfo(i - 1, nx_int(1), nx_widestr(nx_string(item)))
    end
  end
  str_lst = util_split_string(SepcialDrop, ",")
  for i = 1, table.getn(str_lst) do
    local item = str_lst[i]
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      local itemname = takeoutmore_str(gui.TextManager:GetText(item))
      form.material_special_grid:AddItem(i - 1, tempphoto, nx_widestr("<font color=\"#5f4325\">" .. itemname .. "</font>"), 0, -1)
      form.material_special_grid:SetItemAddInfo(i - 1, nx_int(1), nx_widestr(nx_string(item)))
    end
  end
end
function fresh_gather(form, gather_type, gather_str)
  control_info_clear(form)
  show_item_info(form, nx_string(gather_type), nx_string(gather_str))
end
function control_info_clear(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_cjdj.Text = ""
  form.lbl_ene_value.Text = ""
  form.lbl_exp_value.Text = ""
  form.material_special_grid:Clear()
  form.material_special_grid:SetSelectItemIndex(nx_int(-1))
  form.material_grid:Clear()
  form.material_grid:SetSelectItemIndex(nx_int(-1))
end
function on_material_grid_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(index, nx_int(1))
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
  if not bExist then
    return
  end
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
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  grid.Data.is_static = true
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_material_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ipt_2_changed(self)
  local strs = nx_string(self.Text)
  local gui = nx_value("gui")
  if strs == nx_string(gui.TextManager:GetText("ui_sh_ss")) then
    return
  end
  sortString = nx_widestr(self.Text)
  local form = self.ParentForm
  sortClass = form.combobox_sort.Text
  fresh_form_job(form, nx_string(form.JobID))
end
function on_ipt_2_get_focus(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local all = gui.TextManager:GetText("ui_sh_ss")
  if nx_string(self.Text) == nx_string(all) then
    self.Text = ""
  end
end
function find_life_job(job_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if 0 <= client_player:FindRecordRow("job_rec", 0, job_id, 0) then
    return true
  else
    return false
  end
end
function open_form_job(job_id)
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "open_life_form_by_sh_id", jobid)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form.JobID = job_id
  util_auto_show_hide_form(form_name)
end
function on_combobox_sort_selected(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  sortClass = nx_widestr(self.Text)
  sortString = nx_widestr("")
  form.ipt_2.Text = nx_widestr(gui.TextManager:GetText("ui_sh_ss"))
  fresh_form_job(form, nx_string(form.JobID))
end
function get_cur_scene_name()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return ""
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local scene_config = client_scene:QueryProp("ConfigID")
  local scene_name = gui.TextManager:GetFormatText(scene_config)
  return scene_name
end
function find_tree_item(tree, find_info)
  local root_node = tree.RootNode
  if not nx_is_valid(root_node) then
    return nil
  end
  return find_node(root_node, find_info)
end
function find_node(root_node, find_info)
  local node_list = root_node:GetNodeList()
  for i, node in ipairs(node_list) do
    if nx_find_custom(node, "gather_list") and node.gather_list == find_info then
      return node
    else
      local node_find = find_node(node, find_info)
      if nx_is_valid(node_find) then
        return node_find
      end
    end
  end
  return nil
end
function takeoutmore_str(str)
  local strs = nx_string(str)
  if string.len(strs) <= 8 then
    return strs
  end
  local fornt = string.sub(strs, 1, 8)
  local texts = fornt .. "..."
  return texts
end
function on_btn_show_on_map_click(self)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if is_vip(player, VT_NORMAL) then
    local node = self.parent
    local form = nx_value("form_stage_main\\form_life\\form_job_gather_new")
    form.node = node
    util_auto_show_hide_form("form_stage_main\\form_life\\form_map_gather_new")
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_offline_no_vip")
  end
end
