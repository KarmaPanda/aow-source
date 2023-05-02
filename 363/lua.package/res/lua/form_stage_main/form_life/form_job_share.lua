require("util_functions")
require("share\\itemtype_define")
require("define\\request_type")
require("define\\gamehand_type")
require("share\\view_define")
require("util_gui")
local gather_path = "form_stage_main\\form_life\\form_job_gather"
function main_form_init(self)
  self.Fixed = false
  self.job_id = ""
  self.target = nil
  self.formula_id = ""
  self.formula_severmoney = 0
  self.formula_type = ""
  self.item_uniqueid = ""
  self.compose_num = 1
  self.item_obj = nil
  self.item_cb_money = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("temp_share_rec", self, "form_stage_main\\form_life\\form_job_share", "on_temp_share_rec_refresh")
    databinder:AddTableBind("temp_job_skill_share_rec", self, "form_stage_main\\form_life\\form_job_share", "on_temp_share_rec_refresh")
    databinder:AddRolePropertyBind("CapitalType1", "int", self, "form_stage_main\\form_life\\form_job_share", "on_captial1_changed")
    databinder:AddRolePropertyBind("CapitalType2", "int", self, "form_stage_main\\form_life\\form_job_share", "on_captial2_changed")
  end
  if self.job_id == "" or not nx_is_valid(self.target) then
    return
  end
  local player_name, job_name, job_lvl, point = get_job_and_level(self)
  self.lbl_ser_name.Text = nx_widestr(player_name)
  self.lbl_job_lvl.Text = nx_widestr(job_lvl)
  self.lbl_2.Visible = false
  self.fipt_num.Text = nx_widestr(1)
  self.groupbox_number.Visible = false
  fresh_main_info(self)
  return 1
end
function get_job_and_level(form)
  if not nx_is_valid(form) then
    return "", "", "", ""
  end
  if form.job_id == "" or not nx_is_valid(form.target) then
    return "", "", "", ""
  end
  local target_name = form.target:QueryProp("Name")
  local target = form.target
  local recname = "share_job_rec"
  local level = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "", "", "", ""
  end
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SHARE_BOX))
  if not nx_is_valid(view) then
    return "", "", "", ""
  end
  if not view:FindRecord(recname) then
    return "", "", "", ""
  end
  local rownum = view:GetRecordRows(recname)
  if rownum < 0 then
    return "", "", "", ""
  end
  for row = 0, rownum - 1 do
    local id = view:QueryRecord(recname, row, 0)
    if nx_string(id) == nx_string(form.job_id) then
      level = view:QueryRecord(recname, row, 1)
      break
    end
  end
  local point = 0
  local gui = nx_value("gui")
  local job_name = gui.TextManager:GetText(nx_string(form.job_id))
  local job_lvl = ""
  local sf_ini = nx_execute("util_functions", "get_ini", "share\\Item\\lifesfname.ini")
  if nx_is_valid(sf_ini) then
    local index = sf_ini:FindSectionIndex(nx_string(form.job_id))
    if 0 <= index then
      job_lvl = gui.TextManager:GetText("role_title_" .. sf_ini:ReadString(index, nx_string(level), ""))
    end
  end
  return target_name, job_name, job_lvl, point
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelTableBind("temp_share_rec", self)
  databinder:DelTableBind("temp_job_skill_share_rec", self)
  databinder:DelRolePropertyBind("CapitalType1", self)
  databinder:DelRolePropertyBind("CapitalType2", self)
  ui_destroy_attached_form(self)
  self.item_obj = nil
  self.item_cb_money = 0
  nx_destroy(self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function fresh_main_info(form)
  local gui = nx_value("gui")
  if form.job_id == "" or not nx_is_valid(form.target) then
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
  local bind_money = client_player:QueryProp("CapitalType1")
  local nobind_money = client_player:QueryProp("CapitalType2")
  form.lbl_bind_money.Text = nx_widestr(get_money_text(bind_money))
  form.lbl_nobind_money.Text = nx_widestr(get_money_text(nobind_money))
  local tree_root = form.tree_info:CreateRootNode(nx_widestr("share_root"))
  fresh_skill_list(form, tree_root)
  fresh_formula_list(form, tree_root)
  form.formula_id = ""
  on_tree_info_select_changed(form.tree_info)
end
function fresh_skill_list(form, root)
  if not nx_is_valid(form) then
    return
  end
  local target = form.target
  if not nx_is_valid(target) then
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
  local recname = "temp_job_skill_share_rec"
  if not client_player:FindRecord(recname) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local rownum = client_player:GetRecordRows(recname)
  local tree_node
  if 1 <= rownum then
    tree_node = root:CreateNode(nx_widestr(gui.TextManager:GetText("ui_server2")))
    tree_node.has_child = false
    tree_node.DrawMode = "ExpandH"
    tree_node.ExpandCloseOffsetX = 0
    tree_node.ExpandCloseOffsetY = 2
    tree_node.TextOffsetX = 25
    tree_node.TextOffsetY = 1
    tree_node.NodeOffsetX = 0
    tree_node.NodeOffsetY = 5
    tree_node.Font = "font_text_title2"
    tree_node.ForeColor = "255,255,255,255"
    tree_node.NodeBackImage = nx_execute(gather_path, "get_treeview_bg", 2, "out")
    tree_node.NodeFocusImage = nx_execute(gather_path, "get_treeview_bg", 2, "on")
    tree_node.NodeSelectImage = nx_execute(gather_path, "get_treeview_bg", 2, "on")
  else
    return
  end
  for row = 1, rownum do
    local job_id = client_player:QueryRecord(recname, row - 1, 0)
    if nx_string(job_id) == form.job_id then
      local isShare = client_player:QueryRecord(recname, row - 1, 4)
      if nx_string(isShare) == "1" then
        local skillname = client_player:QueryRecord(recname, row - 1, 1)
        local prize = client_player:QueryRecord(recname, row - 1, 3)
        local photo, name = get_skill_display_info(skillname)
        local sname = nx_widestr(get_special_show_sp(name))
        local subnode = tree_node:CreateNode(nx_widestr(sname))
        tree_node.has_child = true
        subnode.formula_id = skillname
        subnode.formula_type = "skill"
        subnode.ForeColor = "255,255,255,255"
        subnode.TextOffsetX = 20
        subnode.TextOffsetY = 1
        subnode.Font = "font_text"
        subnode.NodeBackImage = nx_execute(gather_path, "get_treeview_bg", 3, "out")
        subnode.NodeFocusImage = nx_execute(gather_path, "get_treeview_bg", 3, "on")
        subnode.NodeSelectImage = nx_execute(gather_path, "get_treeview_bg", 3, "on")
        if not nx_is_valid(form.tree_info.SelectNode) then
          form.tree_info.SelectNode = subnode
        end
      end
    end
  end
  root:ExpandAll()
end
function fresh_formula_list(form, root)
  if not nx_is_valid(form) then
    return
  end
  local iniformula = load_ini("share\\Item\\life_formula.ini")
  if not nx_is_valid(iniformula) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rownum = client_player:GetRecordRows("temp_share_rec")
  if 1 <= rownum then
    tree_node = root:CreateNode(nx_widestr(gui.TextManager:GetText("ui_server1")))
    tree_node.has_child = false
    tree_node.DrawMode = "ExpandH"
    tree_node.ExpandCloseOffsetX = 0
    tree_node.ExpandCloseOffsetY = 2
    tree_node.TextOffsetX = 25
    tree_node.TextOffsetY = 1
    tree_node.NodeOffsetX = 0
    tree_node.NodeOffsetY = 5
    tree_node.Font = "font_text_title2"
    tree_node.ForeColor = "255,255,255,255"
    tree_node.NodeBackImage = nx_execute(gather_path, "get_treeview_bg", 2, "out")
    tree_node.NodeFocusImage = nx_execute(gather_path, "get_treeview_bg", 2, "on")
    tree_node.NodeSelectImage = nx_execute(gather_path, "get_treeview_bg", 2, "on")
  else
    return
  end
  for row = 1, rownum do
    local formula_id = client_player:QueryRecord("temp_share_rec", row - 1, 0)
    local prize = client_player:QueryRecord("temp_share_rec", row - 1, 1)
    local sec_index = iniformula:FindSectionIndex(formula_id)
    if sec_index < 0 then
      nx_log("share\\Item\\life_formula.ini sec_index= " .. nx_string(formula_id))
      return
    end
    local porduct_item = iniformula:ReadString(sec_index, "ComposeResult", "")
    local bExist = ItemQuery:FindItemByConfigID(porduct_item)
    if bExist then
      local item_type = nx_number(ItemQuery:GetItemPropByConfigID(porduct_item, "ItemType"))
      local photo = ""
      if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
        photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", porduct_item, "Photo")
      else
        photo = ItemQuery:GetItemPropByConfigID(porduct_item, "Photo")
      end
      local name = gui.TextManager:GetFormatText(porduct_item)
      local sname = nx_widestr(get_special_show_sp(name))
      local subnode = tree_node:CreateNode(nx_widestr(sname))
      tree_node.has_child = true
      subnode.formula_id = formula_id
      subnode.formula_type = "compose"
      subnode.ForeColor = "255,255,255,255"
      subnode.TextOffsetX = 20
      subnode.TextOffsetY = 1
      subnode.Font = "font_text"
      subnode.NodeBackImage = nx_execute(gather_path, "get_treeview_bg", 3, "out")
      subnode.NodeFocusImage = nx_execute(gather_path, "get_treeview_bg", 3, "on")
      subnode.NodeSelectImage = nx_execute(gather_path, "get_treeview_bg", 3, "on")
      if not nx_is_valid(form.tree_info.SelectNode) then
        form.tree_info.SelectNode = subnode
      end
    end
  end
  root:ExpandAll()
end
function get_special_show_sp(name, prize)
  local temp_name = name
  return temp_name
end
function on_tree_info_select_changed(self)
  local node = nx_execute(gather_path, "get_down_node", self.SelectNode)
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "formula_id") then
    return
  end
  if not nx_find_custom(node, "formula_type") then
    return
  end
  local form = self.ParentForm
  form.formula_id = node.formula_id
  form.formula_severmoney = 0
  form.btn_ok.Enabled = false
  form.ImageControlGrid_selected.grid_type = ""
  form.ImageControlGrid_selected.item_configid = ""
  form.ImageControlGrid_selected.item_uniqueid = ""
  form.ImageControlGrid_selected.view_obj = nil
  if node.formula_type == "compose" then
    form.lbl_notel.Visible = false
    form.groupbox_server_name.Visible = true
    fresh_compose_materials_and_prize(form)
  elseif node.formula_type == "skill" then
    form.lbl_notel.Visible = true
    form.groupbox_server_name.Visible = false
    fresh_skill_materials_and_prize(form)
  end
end
function fresh_compose_materials_and_prize(form)
  if not nx_is_valid(form) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local iniformula = load_ini("share\\Item\\life_formula.ini")
  if not nx_is_valid(iniformula) then
    return
  end
  if nx_string(form.formula_id) == "" then
    return
  end
  local formula_id = nx_string(form.formula_id)
  local sec_item_index = iniformula:FindSectionIndex(formula_id)
  if sec_item_index < 0 then
    nx_log("share\\Item\\life_formula.ini sec_index= " .. nx_string(formula_id))
    return
  end
  local needitem = iniformula:ReadString(sec_item_index, "Material", "")
  local porduct_item = iniformula:ReadString(sec_item_index, "ComposeResult", "")
  local needmoney = iniformula:ReadInteger(sec_item_index, "CompositeNeedMoney", "")
  local prize = 0
  local row = client_player:FindRecordRow("temp_share_rec", 0, formula_id, 0)
  if 0 <= row then
    prize = client_player:QueryRecord("temp_share_rec", row, 1)
  end
  form.groupbox_made.Visible = true
  form.groupbox_server.Visible = true
  local count = form.compose_num
  form.lbl_money_made.Text = nx_widestr(get_money_text(needmoney * count))
  form.lbl_money_selected.Text = nx_widestr(get_money_text(prize * count))
  form.formula_severmoney = prize
  local grid = form.ImageControlGrid_selected
  local bExist = ItemQuery:FindItemByConfigID(porduct_item)
  if bExist then
    local item_type = nx_number(ItemQuery:GetItemPropByConfigID(porduct_item, "ItemType"))
    local photo = ""
    if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
      photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", porduct_item, "Photo")
    else
      photo = ItemQuery:GetItemPropByConfigID(porduct_item, "Photo")
    end
    local name = gui.TextManager:GetFormatText(porduct_item)
    grid:AddItem(0, photo, name, nx_int(1), nx_int(0))
    grid:SetItemAddInfo(0, nx_int(1), nx_widestr(porduct_item))
    grid.item_configid = porduct_item
  end
  local imagegrid_materials = form.ImageControlGrid_materials
  imagegrid_materials:Clear()
  local str_lst = util_split_string(needitem, ";")
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = nx_string(str_temp[1])
    local num = nx_int(str_temp[2]) * nx_int(count)
    local bExist = ItemQuery:FindItemByConfigID(item)
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(item, "Photo")
      imagegrid_materials:AddItem(i - 1, tempphoto, "", 0, -1)
      local curnum_material = nx_execute("form_stage_main\\form_life\\form_job_composite", "Get_Material_Num", item, VIEWPORT_MATERIAL_TOOL)
      local curnum_none = nx_execute("form_stage_main\\form_life\\form_job_composite", "Get_Material_Num", item, VIEWPORT_TOOL)
      local curnum = nx_int(curnum_material) + nx_int(curnum_none)
      if nx_int(curnum) >= nx_int(num) then
        imagegrid_materials:ChangeItemImageToBW(i - 1, false)
        imagegrid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#00ff00\">" .. nx_string(curnum) .. "/" .. nx_string(num) .. "</font>"))
        imagegrid_materials:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
      else
        imagegrid_materials:ChangeItemImageToBW(i - 1, true)
        imagegrid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(curnum) .. "/" .. nx_string(num) .. "</font>"))
        imagegrid_materials:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
      end
      imagegrid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item))
    end
  end
  form.formula_type = "compose"
  form.btn_ok.Enabled = true
end
function fresh_skill_materials_and_prize(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.formula_id) == "" then
    return
  end
  local target = form.target
  if not nx_is_valid(target) then
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
  local recname = "temp_job_skill_share_rec"
  if not client_player:FindRecord(recname) then
    return
  end
  local skill_id = nx_string(form.formula_id)
  local row = client_player:FindRecordRow(recname, 1, skill_id)
  if row < 0 then
    return
  end
  form.lbl_money_made.Text = ""
  form.groupbox_made.Visible = false
  form.groupbox_server.Visible = true
  local skill_type = client_player:QueryRecord(recname, row, 2)
  local prize = client_player:QueryRecord(recname, row, 3)
  form.lbl_money_selected.Text = nx_widestr(get_money_text(prize))
  form.formula_severmoney = prize
  local grid_selected = form.ImageControlGrid_selected
  local grid_materials = form.ImageControlGrid_materials
  grid_selected.grid_type = ""
  if nx_int(skill_type) == nx_int(1) then
    grid_selected.grid_type = "compose"
  elseif nx_int(skill_type) == nx_int(2) then
    grid_selected.grid_type = "enhance"
  elseif nx_int(skill_type) == nx_int(3) then
    grid_selected.grid_type = "pizhushu"
  elseif nx_int(skill_type) == nx_int(4) then
    grid_selected.grid_type = "pizhuhua"
  elseif nx_int(skill_type) == nx_int(5) then
    grid_selected.grid_type = "chaolu"
  end
  grid_materials:Clear()
  grid_selected:Clear()
end
function on_ImageControlGrid_selected_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if gui.GameHand:IsEmpty() then
    return
  end
  if gui.GameHand.Type ~= GHT_VIEWITEM then
    return
  end
  local src_viewid = nx_int(gui.GameHand.Para1)
  local src_pos = nx_int(gui.GameHand.Para2)
  local src_amount = nx_int(gui.GameHand.Para3)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(src_viewid))
  local viewobj = view:GetViewObj(nx_string(src_pos))
  if not nx_is_valid(viewobj) then
    return
  end
  if nx_string(viewobj:QueryProp("UniqueID")) == nx_string(grid.item_uniqueid) then
    return
  end
  grid.item_uniqueid = nx_string(viewobj:QueryProp("UniqueID"))
  grid.view_obj = viewobj
  local configid = nx_string(viewobj:QueryProp("ConfigID"))
  if not is_equal_skill_type(form, configid, grid, viewobj) then
    return
  end
  form.btn_ok.Enabled = true
  form.formula_type = "skill"
  fill_skill_itemgrid_and_materials(form, configid, grid, viewobj)
  form.item_uniqueid = grid.item_uniqueid
  gui.GameHand:ClearHand()
  form.lbl_notel.Visible = false
  form.groupbox_server_name.Visible = true
end
function is_equal_skill_type(form, configid, grid, item)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return false
  end
  if configid == "" then
    return false
  end
  local grid_type = nx_string(grid.grid_type)
  if grid_type == "enhance" then
    local prop_get_pack = item:QueryProp("PropGetPack")
    if nx_int(prop_get_pack) <= nx_int(0) then
      return false
    end
    local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\equip_prop_rand.ini")
    if not nx_is_valid(ini) then
      return
    end
    local sec_index = ini:FindSectionIndex(nx_string(prop_get_pack))
    if sec_index < 0 then
      nx_log("share\\Rule\\equip_prop_rand.ini = " .. nx_string(prop_get_pack))
      return false
    end
    local jobid = ini:ReadString(sec_index, "JobName", "")
    if nx_string(jobid) == nx_string(form.job_id) then
      return true
    end
  elseif grid_type == "pizhushu" then
    local item_type = ItemQuery:GetItemPropByConfigID(configid, "ItemType")
    if nx_int(item_type) == nx_int(ITEMTYPE_WEAPON_BOOK) then
      return true
    end
  elseif grid_type == "pizhuhua" then
    local item_type = ItemQuery:GetItemPropByConfigID(configid, "ItemType")
    if nx_int(item_type) == nx_int(ITEMTYPE_WEAPON_PAINT) then
      return true
    end
  elseif grid_type == "chaolu" then
    local chaoluPackageid = ItemQuery:GetItemPropByConfigID(configid, "ChaoluPack")
    if nx_int(chaoluPackageid) > nx_int(0) then
      return true
    end
  end
  return false
end
function fill_skill_itemgrid_and_materials(form, configid, grid, item)
  local gui = nx_value("gui")
  local name = gui.TextManager:GetFormatText(configid)
  grid:AddItem(0, nx_string(gui.GameHand.Image), name, nx_int(1), nx_int(0))
  grid:SetItemAddInfo(0, nx_int(1), nx_widestr(configid))
  grid.item_configid = configid
  local grid_materials = form.ImageControlGrid_materials
  grid_materials:Clear()
  local ItemQuery = nx_value("ItemQuery")
  local items = ""
  local grid_type = nx_string(grid.grid_type)
  if grid_type == "enhance" then
    local prop_get_pack = item:QueryProp("PropGetPack")
    if nx_int(prop_get_pack) <= nx_int(0) then
      return
    end
    local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\equip_prop_rand.ini")
    if not nx_is_valid(ini) then
      return
    end
    local sec_index = ini:FindSectionIndex(nx_string(prop_get_pack))
    if sec_index < 0 then
      nx_log("share\\Rule\\equip_prop_rand.ini = " .. nx_string(prop_get_pack))
      return false
    end
    items = ini:ReadString(sec_index, "Item", "")
    local cb_money = ini:ReadInteger(sec_index, "Cost", 0)
    form.item_obj = item
    form.item_cb_money = cb_money
  elseif grid_type == "chaolu" then
    local chaolu_pack = item:QueryProp("ChaoluPack")
    if nx_int(chaolu_pack) <= nx_int(0) then
      return
    end
    local ini = nx_execute("util_functions", "get_ini", "share\\Life\\ScholarCopy.ini")
    if not nx_is_valid(ini) then
      return
    end
    local sec_index = ini:FindSectionIndex(nx_string(chaolu_pack))
    if sec_index < 0 then
      nx_log("share\\Rule\\equip_prop_rand.ini = " .. nx_string(chaolu_pack))
      return false
    end
    items = ini:ReadString(sec_index, "Material", "")
  end
  items = util_split_string(items, ";")
  for i = 1, table.getn(items) do
    local str_temp = util_split_string(items[i], ",")
    if table.getn(str_temp) == 3 then
      local item = nx_string(str_temp[1])
      local num = nx_int(str_temp[2])
      local temp_type = nx_int(str_temp[3])
      local bExist = ItemQuery:FindItemByConfigID(item)
      if bExist then
        local tempphoto = ItemQuery:GetItemPropByConfigID(item, "Photo")
        grid_materials:AddItem(i - 1, tempphoto, "", 0, -1)
        local curnum = nx_execute("form_stage_main\\form_life\\form_job_composite", "Get_Material_Num", item, VIEWPORT_MATERIAL_TOOL)
        if num <= nx_int(curnum) then
          grid_materials:ChangeItemImageToBW(i - 1, false)
          grid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#00ff00\">" .. nx_string(curnum) .. "/" .. nx_string(num) .. "</font>"))
          grid_materials:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
        else
          grid_materials:ChangeItemImageToBW(i - 1, true)
          grid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(curnum) .. "/" .. nx_string(num) .. "</font>"))
          grid_materials:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
        end
        grid_materials:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item))
      end
    end
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not (nx_string(form.formula_id) ~= "" and nx_string(form.formula_type) ~= "" and nx_is_valid(form.target)) or nx_string(form.job_id) == "" then
    error_info(form)
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
  local target = form.target
  if not nx_is_valid(target) then
    return
  end
  local target_name = target:QueryProp("Name")
  if nx_string(form.formula_type) == "compose" then
    nx_execute("custom_sender", "custom_request_life_share", 1, nx_widestr(target_name), nx_string(form.formula_id), nx_int64(form.formula_severmoney), nx_int(form.compose_num))
  elseif nx_string(form.formula_type) == "skill" then
    if nx_string(form.item_uniqueid) == "" then
      error_info(form)
      return
    end
    local recname = "temp_job_skill_share_rec"
    if not client_player:FindRecord(recname) then
      error_info(form)
      return
    end
    local skill_id = nx_string(form.formula_id)
    local row = client_player:FindRecordRow(recname, 1, skill_id)
    if row < 0 then
      error_info(form)
      return
    end
    local skill_type = client_player:QueryRecord(recname, row, 2)
    local reduceitem = ""
    local dialog = nx_value("form_stage_main\\form_life\\form_enhance_reduce")
    if nx_is_valid(dialog) then
      dialog:Close()
      if nx_is_valid(dialog) then
        nx_destroy(dialog)
      end
    end
    if nx_int(skill_type) == nx_int(2) and nx_is_valid(form.item_obj) and nx_int(form.item_obj:QueryProp("ColorLevel")) <= nx_int(4) then
      local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_enhance_reduce", true, false)
      if nx_is_valid(dialog) then
        nx_execute("form_stage_main\\form_life\\form_enhance_reduce", "fresh_combox", dialog, form.item_obj, form.item_cb_money)
        dialog:Show()
        dialog.type = 1
        reduceitem = nx_wait_event(100000000, dialog, "form_enhance_reduce_input_return")
      end
    end
    if not nx_is_valid(form) then
      return
    end
    if nx_string(reduceitem) == "close_ui" then
      form:Close()
      return
    end
    nx_execute("custom_sender", "custom_request_life_share", nx_int(skill_type), nx_widestr(target_name), nx_string(form.job_id), skill_id, nx_string(form.item_uniqueid), nx_int64(form.formula_severmoney), reduceitem)
  end
  form:Close()
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function error_info(form)
  form:Close()
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "60018")
end
function on_ImageControlGrid_mousein_grid(grid, index)
  if judge_is_skill(grid, index) then
    nx_execute("form_stage_main\\form_life\\form_job_share_set", "on_skill_imagegrid_mousein_grid", grid, index)
  else
    if not nx_find_custom(grid, "view_obj") then
      return
    end
    if not nx_is_valid(grid.view_obj) or grid.view_obj == nil then
      nx_execute("form_stage_main\\form_life\\form_job_composite", "on_product_grid_mousein_grid", grid, index)
      return
    end
    local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
    if item_config == "" then
      return
    end
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local view_obj = grid.view_obj
    if not nx_is_valid(view_obj) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local PzCount = view_obj:QueryProp("PzCount")
    local NeedPoint = view_obj:QueryProp("NeedPoint")
    local MaxPzCount = view_obj:QueryProp("MaxPzCount")
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Photo = nx_string(photo)
    prop_array.PzCount = nx_int(PzCount)
    prop_array.MaxPzCount = nx_int(MaxPzCount)
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
end
function judge_is_skill(grid, index)
  local skill_configID = nx_string(grid:GetItemAddText(index, nx_int(1)))
  local x, _ = string.find(nx_string(skill_configID), "life_skill_")
  if x ~= nil then
    return true
  end
  return false
end
function on_ImageControlGrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageControlGrid_materials_mousein_grid(grid, index)
  nx_execute("form_stage_main\\form_life\\form_job_composite", "on_material_grid_mousein_grid", grid, index)
end
function on_ImageControlGrid_materials_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_temp_share_rec_refresh(form, recordname, optype, row, clomn)
  fresh_main_info(form)
end
function on_captial1_changed(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
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
  local bind_money = client_player:QueryProp("CapitalType1")
  form.lbl_bind_money.Text = nx_widestr(get_money_text(bind_money))
end
function on_captial2_changed(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
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
  local nobind_money = client_player:QueryProp("CapitalType2")
  form.lbl_nobind_money.Text = nx_widestr(get_money_text(nobind_money))
end
function is_material_enough(materials)
  local game_client = nx_value("game_client")
  local str_lst = util_split_string(material, ";")
  if table.getn(str_lst) <= 0 then
    return true
  end
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item_id = str_temp[1]
    local num = str_temp[2]
    local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
    if nx_is_valid(view) then
      local viewobj_list = view:GetViewObjList()
      local total = 0
      for i, obj in pairs(viewobj_list) do
        local tempid = obj:QueryProp("ConfigID")
        if nx_string(tempid) == nx_string(item_id) then
          local cur_amount = obj:QueryProp("Amount")
          total = total + cur_amount
        end
      end
      if nx_int(total) < nx_int(num) then
        return false
      end
    end
  end
  return true
end
function get_money_text(money)
  if money <= 0 then
    return nx_widestr("0") .. nx_widestr(util_text("ui_Wen"))
  end
  local ding, liang, wen = 0, 0, 0
  ding, liang, wen = nx_execute("form_stage_main\\form_mail\\form_mail_send", "trans_price", money)
  local money_text = nx_widestr("")
  if 0 < ding then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_Ding"))
  end
  if 0 < liang then
    money_text = money_text .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang"))
  end
  if 0 < wen then
    money_text = money_text .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen"))
  end
  return money_text
end
function load_ini(path)
  return nx_execute("util_functions", "get_ini", nx_string(path))
end
function open_form(target, job_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_life\\form_job_share", true)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(target) then
    return
  end
  form.target = target
  form.job_id = job_id
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_life\\form_job_share")
  nx_execute("util_gui", "ui_show_attached_form", form)
end
function get_skill_display_info(skillid)
  local gui = nx_value("gui")
  local job_skill_ini = nx_execute("util_functions", "get_ini", "share\\Life\\job_skill.ini")
  if not nx_is_valid(job_skill_ini) then
    return "", ""
  end
  local sec_index = job_skill_ini:FindSectionIndex(skillid)
  if sec_index < 0 then
    nx_log("share\\Life\\job_skill.ini sec_index = " .. nx_string(sub_str[i]))
    return "", "", ""
  end
  local photo = job_skill_ini:ReadString(sec_index, "photo", "")
  local name = gui.TextManager:GetFormatText("ui_" .. nx_string(skillid))
  return photo, name
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_fipt_num_changed(self)
  local snum = nx_string(self.Text)
  if snum == "0" or snum == "-" then
    self.Text = nx_widestr(1)
  end
  local nnum = nx_int(self.Text)
  if nnum <= nx_int(0) or nnum > nx_int(50) then
    self.Text = nx_widestr(1)
  end
  local form = self.ParentForm
  form.compose_num = nx_int(self.Text)
  if nx_string(form.formula_type) == "compose" then
    fresh_compose_materials_and_prize(form)
  end
end
