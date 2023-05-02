require("util_functions")
require("util_gui")
local g_sortString = ""
local g_sortClass = ""
function on_open_form(form, ...)
  form.JobID = arg[1]
  form.CurFormulaID = ""
  fresh_form(form)
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
  nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  self.JobID = ""
  self.CurFormulaID = ""
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("job_rec", self, "form_stage_main\\form_life\\form_job_war", "on_job_rec_refresh")
    databinder:AddTableBind("sh_qis_zhanshu", self, "form_stage_main\\form_life\\form_job_war", "on_sh_qis_zhanshu_refresh")
    databinder:AddTableBind("sh_qis_share_rec", self, "form_stage_main\\form_life\\form_job_war", "on_sh_qis_share_rec_refresh")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("job_rec", self)
    databinder:DelTableBind("sh_qis_zhanshu", self)
    databinder:DelTableBind("sh_qis_share_rec", self)
  end
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function fresh_form(self)
  if nx_is_valid(self) then
    self.store_select_sort = nil
    self.store_select_search = nil
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local Text_ss = gui.TextManager:GetText("ui_sh_ss")
    self.ipt_2.Text = nx_widestr(Text_ss)
    g_sortClass = gui.TextManager:GetFormatText("str_quanbu")
    g_sortString = nx_widestr("")
    fresh_form_job(self)
  end
end
function on_job_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if nx_widestr(g_sortClass) == nx_widestr("") then
    local gui = nx_value("gui")
    g_sortClass = gui.TextManager:GetFormatText("str_quanbu")
  end
  if optype == "update" then
    fresh_form_job(form)
  end
end
function on_sh_qis_zhanshu_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if optype == "clear" then
    clear_info(form, "right")
  end
  fresh_form_job(form)
end
function on_sh_qis_share_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  fresh_form_job(form)
end
function fresh_form_job(self)
  local jobid = self.JobID
  if jobid == "" or jobid == nil then
    return
  end
  clear_info(self, "left")
  local job_name, level, all_exp, current_exp = get_current_job_exp(self)
  set_current_job_exp(self, job_name, level, all_exp, current_exp)
  refresh_tree_list(self, job_name, jobid, level)
end
function refresh_tree_list(form, job_name, jobid, job_level)
  local jobinfoini = nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  if not nx_is_valid(jobinfoini) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sec_index = jobinfoini:FindSectionIndex(nx_string(jobid))
  if sec_index < 0 then
    return
  end
  local zhanshu_str = jobinfoini:ReadString(sec_index, "zhanshu", "")
  if zhanshu_str ~= "" then
    local root = form.tree_job:CreateRootNode(nx_widestr(job_name))
    root.search_id = job_name
    refresh_tree_list_gather(form, root, zhanshu_str, job_level)
    root:ExpandAll()
  end
end
function refresh_tree_list_gather(form, root, zhanshu_str, job_level)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local job_gather_prop = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  if not nx_is_valid(job_gather_prop) then
    return
  end
  local str_quanbu = gui.TextManager:GetFormatText("str_quanbu")
  form.combobox_sort.DropListBox:AddString(nx_widestr(str_quanbu))
  local selectNode
  local str_lst = util_split_string(zhanshu_str, ",")
  for i = 1, table.getn(str_lst) do
    local str = str_lst[i]
    local sec_index = job_gather_prop:FindSectionIndex(nx_string(str))
    if nx_int(sec_index) < nx_int(0) then
      break
    end
    local zhanshu_type_name = gui.TextManager:GetText(nx_string(str))
    form.combobox_sort.DropListBox:AddString(nx_widestr(zhanshu_type_name))
    if nx_widestr(g_sortClass) == nx_widestr(str_quanbu) or nx_widestr(g_sortClass) == nx_widestr(zhanshu_type_name) then
      local zhanshu_type_node = creat_first_node(root, zhanshu_type_name)
      local item_count = job_gather_prop:GetSectionItemCount(sec_index)
      for j = 1, item_count do
        local temp_str = job_gather_prop:ReadString(sec_index, nx_string(j), "")
        local node_infos = util_split_string(temp_str, "/")
        if table.getn(node_infos) ~= 3 then
          break
        end
        local zhanshu_id = node_infos[1]
        local zhanshu_name = gui.TextManager:GetText(nx_string(zhanshu_id))
        local b_learn_zhanshu = false
        if is_Learned_zhanshu(zhanshu_id) ~= "qis_info_1" then
          b_learn_zhanshu = true
        end
        if b_learn_zhanshu and (g_sortString == nx_widestr("") or -1 ~= nx_function("ext_ws_find", zhanshu_name, g_sortString)) then
          local zhanshu_node = creat_two_node(zhanshu_type_node, zhanshu_id, zhanshu_name, node_infos[3], zhanshu_type_name)
          if nx_is_valid(zhanshu_node) and not nx_is_valid(selectNode) then
            selectNode = zhanshu_node
          end
          if nx_is_valid(zhanshu_node) and zhanshu_id == form.CurFormulaID then
            selectNode = zhanshu_node
          end
        end
      end
      if zhanshu_type_node.has_child then
        if not zhanshu_type_node.has_valid_child then
          zhanshu_type_node.ForeColor = "255,146,146,146"
        else
          zhanshu_type_node.ForeColor = "255,255,255,255"
        end
      else
        root:RemoveNode(zhanshu_type_node)
      end
    end
  end
  if nx_widestr("") == g_sortClass then
    g_sortClass = str_quanbu
  end
  form.combobox_sort.Text = nx_widestr(g_sortClass)
  form.tree_job.SelectNode = selectNode
  if nx_find_custom(form, "store_select_id") and form.store_select_id ~= nil then
    form.tree_job.SelectNode = get_node(root, form.store_select_id)
  end
  root:ExpandAll()
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
function creat_first_node(root, name)
  local zhanshu_type_node = root:CreateNode(nx_widestr(name))
  zhanshu_type_node.search_id = zhanshu_name
  zhanshu_type_node.has_child = false
  zhanshu_type_node.has_valid_child = false
  zhanshu_type_node.DrawMode = "FitWindow"
  zhanshu_type_node.ExpandCloseOffsetX = 0
  zhanshu_type_node.ExpandCloseOffsetY = 2
  zhanshu_type_node.TextOffsetX = 25
  zhanshu_type_node.TextOffsetY = 1
  zhanshu_type_node.NodeOffsetY = 5
  zhanshu_type_node.Font = "font_main"
  zhanshu_type_node.ForeColor = "255,255,180,0"
  zhanshu_type_node.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "out")
  zhanshu_type_node.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
  zhanshu_type_node.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
  return zhanshu_type_node
end
function creat_two_node(parentnode, id, name, qipus, fathername)
  local zhanshu_node = parentnode:CreateNode(name)
  zhanshu_node.search_id = name
  zhanshu_node.id = id
  zhanshu_node.node_item_str = qipus
  zhanshu_node.father = fathername
  zhanshu_node.Font = "font_main"
  zhanshu_node.TextOffsetX = 25
  zhanshu_node.TextOffsetY = 1
  zhanshu_node.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "out")
  zhanshu_node.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
  zhanshu_node.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
  parentnode.has_child = true
  zhanshu_node.ForeColor = "255,255,255,255"
  if is_Learned_zhanshu(id) ~= "qis_info_1" then
    parentnode.has_valid_child = true
  else
    zhanshu_node.ForeColor = "255,146,146,146"
  end
  return zhanshu_node
end
function clear_info(form, flags)
  if nx_string(flags) == "left" then
    form.tree_job:CreateRootNode(nx_widestr(""))
    form.combobox_sort.Text = nx_widestr("")
    form.combobox_sort.DropListBox:ClearString()
  elseif nx_string(flags) == "right" then
    form.material_grid:Clear()
    form.material_grid:SetSelectItemIndex(nx_int(-1))
    form.icg_now_war:Clear()
    form.icg_now_war:SetSelectItemIndex(nx_int(-1))
    form.mltbox_dec:Clear()
    form.groupscrollbox_qipu:DeleteAll()
  end
end
function get_current_job_exp(form)
  local jobid = form.JobID
  if jobid == "" or jobid == nil then
    return "", 0, 0, 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return "", 0, 0, 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "", 0, 0, 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  local level = client_player:QueryRecord("job_rec", row, 1)
  local current_exp = client_player:QueryRecord("job_rec", row, 2)
  local all_exp = client_player:QueryRecord("job_rec", row, 3)
  local job_name = gui.TextManager:GetText(nx_string(jobid))
  return job_name, level, all_exp, current_exp
end
function set_current_job_exp(form, job_name, level, all_exp, current_exp)
  jobid = form.JobID
  form.lbl_job_name.Text = nx_widestr(job_name)
end
function fresh_sub_info(form)
  local node = get_down_node(form.tree_job.SelectNode)
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "search_id") then
    return
  end
  if not nx_find_custom(node, "node_item_str") then
    return
  end
  if not nx_find_custom(node, "father") then
    return
  end
  clear_info(form, "right")
  fresh_zhanshu_deatil(form, node.id, node.search_id, node.node_item_str, node.father)
end
function get_down_node(node)
  if nx_find_custom(node, "id") then
    return node
  end
  local node_list = node:GetNodeList()
  local node_count = node:GetNodeCount()
  if 0 < node_count then
    return get_down_node(node_list[1])
  end
  return nx_null()
end
function fresh_zhanshu_deatil(form, zhanshu_id, zhanshu_name, qipus, fathername)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local need_point = get_zhanshu_msg(zhanshu_id, "NeedPoint")
  local str_need_point = nx_widestr(gui.TextManager:GetText("ui_sh_xhxd")) .. nx_widestr(need_point)
  form.CurFormulaID = zhanshu_id
  local photo = get_zhanshu_msg(zhanshu_id, "Photo")
  local level = is_Learned_zhanshu(nx_string(zhanshu_id))
  local level_text = gui.TextManager:GetText(level)
  local text = nx_widestr(zhanshu_name) .. nx_widestr("(") .. nx_widestr(level_text) .. nx_widestr(")")
  form.material_grid:AddItem(0, nx_string(photo), text, 0, -1)
  form.material_grid:SetItemAddInfo(0, nx_int(1), nx_widestr(zhanshu_id))
  form.material_grid:SetItemAddInfo(0, nx_int(2), nx_widestr(fathername))
  form.material_grid:SetItemAddInfo(0, nx_int(3), nx_widestr(zhanshu_name))
  local descid = "desc_" .. nx_string(zhanshu_id) .. "_0"
  local descmsg = gui.TextManager:GetText(nx_string(descid))
  form.mltbox_dec:AddHtmlText(nx_widestr(descmsg), nx_int(-1))
  if nx_int(need_point) > nx_int(0) then
    form.mltbox_dec:AddHtmlText(nx_widestr(str_need_point), nx_int(-1))
  end
  form.groupscrollbox_qipu.IsEditMode = true
  form.groupscrollbox_qipu:DeleteAll()
  local group_top = 0
  local qipu_tab = util_split_string(qipus, ",")
  for i = 1, table.getn(qipu_tab) do
    local qipu_item = qipu_tab[i]
    local qipu_name = gui.TextManager:GetText(nx_string(qipu_item))
    local groupbox = gui:Create("GroupBox")
    form.groupscrollbox_qipu:Add(groupbox)
    groupbox.AutoSize = false
    groupbox.Name = "groupbox_info_" .. nx_string(i)
    groupbox.BackColor = "0,0,0,0"
    groupbox.NoFrame = true
    groupbox.Left = 0
    groupbox.Top = group_top
    groupbox.Width = 350
    groupbox.Height = 100
    local lbl_qipuname = gui:Create("Label")
    groupbox:Add(lbl_qipuname)
    lbl_qipuname.Text = nx_widestr(qipu_name)
    lbl_qipuname.Left = 0
    lbl_qipuname.Top = 0
    lbl_qipuname.Width = 200
    lbl_qipuname.Height = 15
    lbl_qipuname.ForeColor = form.groupscrollbox_qipu.ForeColor
    lbl_qipuname.Font = form.groupscrollbox_qipu.Font
    local qipu_id = get_item_info(qipu_item, "QipuID")
    local isread = "qis_info_5"
    if is_Learned_qipu(qipu_id) then
      isread = "qis_info_4"
    end
    local lbl_type = gui:Create("Label")
    groupbox:Add(lbl_type)
    lbl_type.Text = nx_widestr(gui.TextManager:GetText(isread))
    lbl_type.Left = 210
    lbl_type.Top = 0
    lbl_type.Width = 200
    lbl_type.Height = 15
    lbl_type.ForeColor = form.groupscrollbox_qipu.ForeColor
    lbl_type.Font = form.groupscrollbox_qipu.Font
    group_top = group_top + 17
  end
  form.groupscrollbox_qipu.IsEditMode = false
  set_now_zhanshu(form, nil)
end
function set_now_zhanshu(form, now_zhanshu_id)
  if now_zhanshu_id == nil or now_zhanshu_id == "" then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    now_zhanshu_id = client_player:QueryProp("ChessZhanshu")
  end
  if now_zhanshu_id == nil or now_zhanshu_id == "" or string.len(nx_string(now_zhanshu_id)) < 7 then
    now_zhanshu_id = ""
  end
  local photo_now = get_zhanshu_msg(now_zhanshu_id, "Photo")
  form.icg_now_war:AddItem(0, nx_string(photo_now), "", 0, -1)
  form.icg_now_war:SetItemAddInfo(0, nx_int(1), nx_widestr(now_zhanshu_id))
end
function is_Learned_qipu(qipuid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:FindRecordRow("sh_qis_share_rec", 0, nx_string(qipuid), 0)
  if 0 <= rows then
    return true
  else
    return false
  end
end
function is_Learned_zhanshu(zhanshuid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow("sh_qis_zhanshu", 0, nx_string(zhanshuid), 0)
  if row < 0 then
    return "qis_info_1"
  end
  local typeid = client_player:QueryRecord("sh_qis_zhanshu", row, 1)
  if nx_int(typeid) == nx_int(0) then
    return "qis_info_3"
  elseif nx_int(typeid) == nx_int(1) then
    return "qis_info_2"
  elseif nx_int(typeid) == nx_int(2) then
    return "qis_info_1"
  end
  return "qis_info_1"
end
function get_item_info(configid, prop)
  local gui = nx_value("gui")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return ""
  end
  if not ItemQuery:FindItemByConfigID(nx_string(configid)) then
    return ""
  end
  return ItemQuery:GetItemPropByConfigID(nx_string(configid), nx_string(prop))
end
function get_zhanshu_msg(zhanshu_id, prop)
  local zhanshu_ini = nx_execute("util_functions", "get_ini", "share\\Item\\life_zhanshu.ini")
  if not nx_is_valid(zhanshu_ini) then
    return ""
  end
  local index = zhanshu_ini:FindSectionIndex(nx_string(zhanshu_id))
  if nx_int(index) < nx_int(0) then
    return ""
  end
  local value = zhanshu_ini:ReadString(index, nx_string(prop), "")
  return value
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
end
function on_combobox_sort_selected(self)
  local form = self.ParentForm
  g_sortClass = nx_widestr(self.Text)
  g_sortString = nx_widestr("")
  fresh_form_job(form)
  self.Text = nx_widestr(g_sortClass)
end
function on_ipt_2_changed(self)
  g_sortString = nx_widestr(self.Text)
  local form = self.ParentForm
  g_sortClass = form.combobox_sort.Text
  fresh_form_job(form)
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
function on_tree_job_select_changed(self)
  local node = self.SelectNode
  if nx_find_custom(node, "id") then
    self.ParentForm.temp_nodeID = self.SelectNode.id
  end
  fresh_sub_info(self.ParentForm)
  if nx_find_custom(node, "help_node") and node.help_node then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    node.help_node = false
  end
end
function on_material_grid_mousein_grid(grid, index)
  local zhanshu_id = grid:GetItemAddText(index, nx_int(1))
  local fathername = grid:GetItemAddText(index, nx_int(2))
  local zhanshuname = grid:GetItemAddText(index, nx_int(3))
  local text = nx_widestr(zhanshuname) .. nx_widestr("<br>") .. nx_widestr("<font color=\"#FF0000\">") .. nx_widestr(fathername) .. nx_widestr("</font>")
  nx_execute("tips_game", "show_text_tip", text, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_material_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_icg_now_war_mousein_grid(grid, index)
  local zhanshu_id = grid:GetItemAddText(index, nx_int(1))
  if zhanshu_id == nil or nx_string(zhanshu_id) == "" then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local zhanshuname = gui.TextManager:GetText(nx_string(zhanshu_id))
  local descid = "desc_" .. nx_string(zhanshu_id) .. "_0"
  local descmsg = gui.TextManager:GetText(nx_string(descid))
  local need_point = get_zhanshu_msg(zhanshu_id, "NeedPoint")
  gui.TextManager:Format_SetIDName("tips_zhanshu_lifepoint_1")
  gui.TextManager:Format_AddParam(nx_int(need_point))
  local needpointdesc = gui.TextManager:Format_GetText()
  local text = nx_widestr(gui.TextManager:GetText(nx_string("qis_zhuangbei"))) .. nx_widestr(zhanshuname) .. nx_widestr("<br>") .. nx_widestr(descmsg) .. nx_widestr("<br>") .. nx_widestr(needpointdesc)
  nx_execute("tips_game", "show_text_tip", text, grid:GetMouseInItemLeft() + 5, grid:GetMouseInItemTop() + 5, 0, grid.ParentForm)
end
function on_icg_now_war_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_icg_now_war_doubleclick_grid(grid, index)
  local now_zhanshu_id = grid:GetItemAddText(index, nx_int(1))
  if nx_string(now_zhanshu_id) == "" then
    return
  end
  grid:Clear()
  grid:SetSelectItemIndex(nx_int(-1))
  nx_execute("custom_sender", "custom_life_qis_clear_equip_zhanshu")
end
function on_btn_use_click(btn)
  local form = btn.ParentForm
  local zhanshu_id = form.material_grid:GetItemAddText(nx_int(0), nx_int(1))
  if nx_string(zhanshu_id) == "" then
    return
  end
  if is_Learned_zhanshu(zhanshu_id) == "qis_info_1" then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, "11746")
    return
  end
  set_now_zhanshu(form, zhanshu_id)
  nx_execute("custom_sender", "custom_life_qis_equip_zhanshu", nx_string(zhanshu_id))
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
    if nx_find_custom(node, "node_item_str") and node.node_item_str == find_info then
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
