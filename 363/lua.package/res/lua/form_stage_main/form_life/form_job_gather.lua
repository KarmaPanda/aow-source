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
  if nx_string(form.JobID) == "sh_lh" then
    form.btn_show_on_map.Visible = false
  else
    form.btn_show_on_map.Visible = true
  end
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
    sortClass = nowscene
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
  local sec_index = jobinfoini:FindSectionIndex(nx_string(jobid))
  if sec_index < 0 then
    return
  end
  local type_nameid1 = jobinfoini:ReadString(sec_index, "type1", "")
  local type_name1 = nx_string(gui.TextManager:GetFormatText(nx_string(type_nameid1)))
  if type_name1 == "" then
    return
  end
  local gather_info = jobinfoini:ReadString(sec_index, "gather", "")
  if gather_info == "" then
    return
  end
  local gather_root = form.tree_job:CreateRootNode(nx_widestr(type_name1))
  gather_root.search_id = type_name1
  local str_lst = util_split_string(gather_info, ",")
  local str_quanbu = gui.TextManager:GetFormatText("str_quanbu")
  form.combobox_sort.DropListBox:AddString(nx_widestr(str_quanbu))
  local isNull = true
  local selectNode
  for i = 1, table.getn(str_lst) do
    local gather_typeid = nx_string(str_lst[i])
    local sec_index1 = gather_ini:FindSectionIndex(gather_typeid)
    if sec_index1 < 0 then
      return
    end
    local gather_type = gui.TextManager:GetFormatText(gather_typeid)
    form.combobox_sort.DropListBox:AddString(gather_type)
    if nx_widestr(sortClass) == nx_widestr(str_quanbu) or nx_widestr(sortClass) == nx_widestr(gather_type) then
      local gather_type_node = gather_root:CreateNode(gather_type)
      gather_type_node.search_id = nx_string(gather_type)
      gather_type_node.has_child = false
      gather_type_node.has_valid_child = false
      gather_type_node.DrawMode = "FitWindow"
      gather_type_node.ExpandCloseOffsetX = 0
      gather_type_node.ExpandCloseOffsetY = 2
      gather_type_node.TextOffsetX = 25
      gather_type_node.TextOffsetY = 1
      gather_type_node.NodeOffsetY = 5
      gather_type_node.Font = "font_main"
      gather_type_node.ForeColor = "255,255,180,0"
      gather_type_node.NodeBackImage = get_treeview_bg(2, "out")
      gather_type_node.NodeFocusImage = get_treeview_bg(2, "on")
      gather_type_node.NodeSelectImage = get_treeview_bg(2, "on")
      local item_count = gather_ini:GetSectionItemCount(gather_typeid)
      for j = 0, item_count - 1 do
        local temp_str = gather_ini:GetSectionItemValue(sec_index1, nx_number(j))
        local item_list = util_split_string(temp_str, ",")
        for i = 1, table.getn(item_list) do
          local item_id = nx_string(item_list[i])
          local node_name = gui.TextManager:GetFormatText(item_id)
          isNull = false
          if sortString == nx_widestr("") or -1 ~= nx_function("ext_ws_find", node_name, sortString) then
            local subnode = gather_type_node:CreateNode(node_name)
            subnode.search_id = gui.TextManager:GetFormatText(nx_string(node_name))
            gather_type_node.has_child = true
            gather_type_node.has_valid_child = true
            subnode.gather_type = gather_type
            subnode.gather_list = nx_string(item_id)
            subnode.TextOffsetX = 25
            subnode.TextOffsetY = 1
            subnode.Font = "font_main"
            subnode.NodeBackImage = get_treeview_bg(3, "out")
            subnode.NodeFocusImage = get_treeview_bg(3, "on")
            subnode.NodeSelectImage = get_treeview_bg(3, "on")
            local level = 0
            if ItemQuery:FindItemByConfigID(nx_string(item_id)) then
              level = ItemQuery:GetItemPropByConfigID(nx_string(item_id), nx_string("GatherPara2"))
            end
            if jobid == "sh_lh" and ItemQuery:FindItemByConfigID(nx_string(item_id)) then
              level = ItemQuery:GetItemPropByConfigID(nx_string(item_id), nx_string("SkinPara2"))
            end
            subnode.ForeColor = "255,255,255,255"
            if nx_is_valid(subnode) and not nx_is_valid(selectNode) then
              selectNode = subnode
            end
            if nx_is_valid(subnode) and item_id == form.CurFormulaID then
              selectNode = subnode
            end
          end
        end
      end
    end
  end
  form.tree_job.SelectNode = selectNode
  form.combobox_sort.Text = nx_widestr(sortClass)
  if isNull then
    form.ipt_2.Text = nx_widestr(gui.TextManager:GetText("ui_sh_wcj"))
  else
    gather_root:ExpandAll()
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
function fresh_sub_info(self)
  local node = get_down_node(self.tree_job.SelectNode)
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
  if nx_string(jobid) == "sh_lh" then
    if not ItemQuery:FindItemByConfigID(nx_string(gather_item)) then
      return
    end
  else
    if not ItemQuery:FindItemByConfigID(nx_string(gather_item)) then
      return
    end
    if nx_string(jobid) == "sh_nf" then
      local seedid = ItemQuery:GetItemPropByConfigID(nx_string(gather_item), nx_string("SeedId"))
      if not ItemQuery:FindItemByConfigID(nx_string(seedid)) then
        return
      end
      needene = ItemQuery:GetItemPropByConfigID(nx_string(seedid), nx_string("NeedEne"))
    end
  end
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
      form.material_grid:AddItem(i - 1, nx_string(tempphoto), nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>"), 0, -1)
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
      form.material_special_grid:AddItem(i - 1, tempphoto, nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>"), 0, -1)
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
  form.material_special_grid:Clear()
  form.material_special_grid:SetSelectItemIndex(nx_int(-1))
  form.material_grid:Clear()
  form.material_grid:SetSelectItemIndex(nx_int(-1))
end
function on_material_grid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
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
  sortClass = nx_widestr(form.combobox_sort.Text)
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
  self.Text = nx_widestr(sortClass)
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
  local strs = nx_widestr(str)
  if nx_ws_length(strs) <= 5 then
    return strs
  end
  local fornt = nx_function("ext_ws_substr", strs, 0, 4)
  local strs = fornt .. nx_widestr("...")
  return strs
end
function on_btn_show_on_map_click(self)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if is_vip(player, VT_NORMAL) then
    local node = get_down_node(self.ParentForm.tree_job.SelectNode)
    if not nx_is_valid(node) then
      return
    end
    self.ParentForm.node = node
    util_auto_show_hide_form("form_stage_main\\form_life\\form_map_gather")
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "ui_offline_no_vip")
  end
end
