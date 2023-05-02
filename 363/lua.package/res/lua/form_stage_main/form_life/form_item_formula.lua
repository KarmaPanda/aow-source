require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\view_define")
local jobs = {
  {id = "sh_cf_01", name = "sh_jh_cf"},
  {id = "sh_jq_01", name = "sh_jh_jq"},
  {id = "sh_ys_01", name = "sh_jh_ys"},
  {id = "sh_ds_01", name = "sh_jh_ds"}
}
local sortString = ""
local SelectNodeConfigID = ""
local SelectNode
function main_form_init(form)
  form.Fixed = false
  return
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_NEWMATERIALTOOLBOX, form, "form_stage_main\\form_life\\form_item_formula", "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_NEWTOOLBOX, form, "form_stage_main\\form_life\\form_item_formula", "on_toolbox_viewport_change")
  end
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  form.ipt_in.Text = nx_widestr(Text_ss)
  refresh_tree_list_fuse(form)
  return
end
function on_toolbox_viewport_change(form, optype)
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    refresh_node_info(form)
  end
  return
end
function select_node(node_config_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  SelectNodeConfigID = node_config_id or ""
  refresh_tree_list_fuse(form)
  if SelectNode ~= nil then
    form.tree_fuse.SelectNode = SelectNode
  end
  return
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_item_formula_form_open(...)
  local form = util_get_form("form_stage_main\\form_life\\form_item_formula", true)
  if not nx_is_valid(form) then
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_life\\form_item_formula")
  return
end
function on_ipt_in_changed(edit)
  local gui = nx_value("gui")
  if gui.TextManager:GetText("ui_sh_ss") == edit.Text then
    sortString = ""
  else
    sortString = nx_string(edit.Text)
  end
  local form = edit.ParentForm
  refresh_tree_list_fuse(form)
  return
end
function on_tree_fuse_select_changed(tree)
  local form = tree.ParentForm
  SelectNode = tree.SelectNode
  local node = tree.SelectNode
  if nx_find_custom(node, "id") then
    tree.ParentForm.CurID = tree.SelectNode.id
  else
  end
  if nx_find_custom(node, "formula_id") then
    form.CurFormulaID = node.formula_id
  end
  refresh_node_info(form)
  return
end
function refresh_tree_list_fuse(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.tree_fuse.SelectNode = SelectNode
  name_root = "LifeJob"
  form.tree_fuse.LevelWidth = 25
  local fuse_root_node = form.tree_fuse:CreateRootNode(nx_widestr(name_root))
  for _, job in ipairs(jobs) do
    name_job = gui.TextManager:GetFormatText(job.name)
    local fuse_root = fuse_root_node:CreateNode(nx_widestr(name_job))
    fuse_root.ExpandCloseOffsetX = 3
    fuse_root.ExpandCloseOffsetY = 2
    fuse_root.TextOffsetX = 25
    fuse_root.TextOffsetY = 5
    fuse_root.ItemHeight = 22
    fuse_root.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "out")
    fuse_root.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
    fuse_root.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
    fuse_root.Font = "font_main"
    formula_list = get_formula(job.id)
    if formula_list == nil then
      return
    end
    config_sub_node(form, gui, fuse_root, formula_list, "share\\Item\\life_formula.ini")
  end
  fuse_root_node:ExpandAll()
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
function refresh_node_info(form)
  local node = form.tree_fuse.SelectNode
  if not nx_is_valid(node) then
    clear_backImage(form)
    return
  end
  if not nx_find_custom(node, "Material") then
    return
  end
  if not nx_find_custom(node, "formula_id") then
    return
  end
  if not nx_find_custom(node, "price") then
    return
  end
  if not nx_find_custom(node, "price_zy") then
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
  local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  clear_backImage(form)
  local Dorp_item = nx_string(node.formula_id)
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("desc_" .. Dorp_item .. "_0")), -1)
  local photo = ItemQuery:GetItemPropByConfigID(Dorp_item, "Photo")
  form.imagegrid_fuseitem:AddItem(nx_int(0), photo, "", 0, -1)
  form.imagegrid_fuseitem:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(Dorp_item))
  local str_lst = util_split_string(node.Material, ";")
  local cntMaterials = table.getn(str_lst)
  local width = form.imagegrid_material.Width
  local colums = form.imagegrid_material.ClomnNum
  local rows = form.imagegrid_material.RowNum - 1
  if cntMaterials > colums * rows then
    return
  end
  local gridwidth = form.imagegrid_material.GridWidth
  local gridheight = form.imagegrid_material.GridHeight
  local col_distance = math.floor((width - colums * gridwidth) / (colums + 1))
  local row_distance = 30
  local cntGrids = table.getn(str_lst)
  local GridsPos = ""
  local row_pos = {}
  local grid_pos = {left = col_distance, top = 10}
  for i = 1, colums do
    row_pos[i] = {
      left = grid_pos.left,
      top = grid_pos.top
    }
    grid_pos.left = grid_pos.left + gridwidth + col_distance
    GridsPos = GridsPos .. row_pos[i].left .. "," .. row_pos[i].top .. ";"
  end
  nRows = math.ceil(cntMaterials / colums)
  for i = 2, nRows do
    grid_pos = {
      left = row_pos[1].left,
      top = row_pos[1].top
    }
    for j = 1, colums do
      row_pos[j] = {
        left = grid_pos.left,
        top = grid_pos.top + gridheight + row_distance
      }
      grid_pos.left = grid_pos.left + gridwidth + col_distance
      GridsPos = GridsPos .. row_pos[j].left .. "," .. row_pos[j].top .. ";"
    end
  end
  form.imagegrid_material.GridsPos = GridsPos
  form.imagegrid_material.MultiTextBox2.ViewRect = "6,41,60,60"
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = nx_string(str_temp[1])
    local num = nx_int(str_temp[2])
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      form.imagegrid_material:AddItem(i - 1, tempphoto, 0, 0, -1)
      local MaterialNum = Get_Material_Num(item, VIEWPORT_NEWMATERIALTOOLBOX) + Get_Material_Num(item, VIEWPORT_NEWTOOLBOX)
      if nx_int(MaterialNum) >= nx_int(num) then
        form.imagegrid_material:ChangeItemImageToBW(i - 1, false)
        form.imagegrid_material:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#00aa00\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
      else
        form.imagegrid_material:ChangeItemImageToBW(i - 1, true)
        form.imagegrid_material:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
      end
      form.imagegrid_material:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
      form.imagegrid_material:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item))
    end
  end
  return
end
function on_imagegrid_fuse_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(2))
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
    prop_array.is_static = true
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
function on_imagegrid_fuse_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function get_formula(job_id)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return nil
  end
  local formula_list = {}
  local formula_len = 0
  formula = fuse_formula_query:GetFormulas(job_id)
  local formula_num = table.getn(formula)
  for i, item in ipairs(formula) do
    table.insert(formula_list, item)
  end
  return formula_list
end
function clear_backImage(form)
  form.mltbox_desc:Clear()
  form.imagegrid_fuseitem:Clear()
  form.imagegrid_material:Clear()
end
function config_sub_node(form, gui, fuse_root, formula_list, ini_path)
  local fuse_ini = nx_execute("util_functions", "get_ini", ini_path)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local max_num_material = (form.imagegrid_material.RowNum - 1) * form.imagegrid_material.ClomnNum
  for _, formula in ipairs(formula_list) do
    local index = fuse_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local Material_str = fuse_ini:ReadString(index, "Material", "")
      if max_num_material >= table.getn(util_split_string(Material_str, ";")) then
        local fuse_name = fuse_ini:ReadString(index, "ComposeResult", "")
        local fuse_type = fuse_ini:ReadString(index, "Profession", "")
        local money = fuse_ini:ReadString(index, "Money", "")
        local money_zy = fuse_ini:ReadString(index, "Money2", "")
        local PowerLevel = fuse_ini:ReadString(index, "PowerLevel", "")
        local node_name = gui.TextManager:GetFormatText(formula)
        local node_id = fuse_ini:GetSectionByIndex(index)
        if sortString == "" or nil ~= string.find(nx_string(node_name), nx_string(sortString)) then
          local sub_node = fuse_root:CreateNode(nx_widestr(node_name))
          sub_node.ItemHeight = 22
          sub_node.TextOffsetX = 35
          sub_node.TextOffsetY = 5
          sub_node.Material = Material_str
          sub_node.formula_id = fuse_name
          sub_node.id = node_id
          sub_node.price = money
          sub_node.price_zy = money_zy
          sub_node.Font = "font_main"
          sub_node.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "out")
          sub_node.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
          sub_node.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
          if nx_is_valid(sub_node) and not nx_is_valid(form.tree_fuse.SelectNode) then
            form.tree_fuse.SelectNode = sub_node
          end
          if SelectNodeConfigID ~= "" and SelectNodeConfigID == sub_node.formula_id then
            SelectNode = sub_node
            SelectNodeConfigID = ""
          end
        end
      end
    end
  end
end
