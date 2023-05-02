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
require("define\\sysinfo_define")
NODE_TYPE_COMPOSITE = 2
local JOB_ID_TABLE = {}
local sortString = ""
local sortClass = ""
local life_btn_name_table = {
  sh_kg = {
    "@ui_btn_kg",
    "@ui_sh_jinggong"
  },
  sh_nf = {
    "@ui_btn_nf",
    "@ui_sh_jinggong"
  },
  sh_cf = {
    "@ui_btn_cf",
    "@ui_btn_cf_1"
  },
  sh_cs = {
    "@ui_btn_cs",
    "@ui_btn_cs_1"
  },
  sh_ds = {
    "@ui_btn_ds",
    "@ui_btn_ds_1"
  },
  sh_jq = {
    "@ui_btn_jq",
    "@ui_btn_jq_1"
  },
  sh_tj = {
    "@ui_btn_tj",
    "@ui_btn_tj_1"
  },
  sh_ys = {
    "@ui_btn_ys",
    "@ui_btn_ys_1"
  },
  sh_qs = {
    "@ui_LianXi",
    "@ui_sh_jinggong"
  },
  sh_ss = {
    "@ui_btn_ss",
    "@ui_sh_jinggong"
  },
  sh_hs = {
    "@ui_btn_hs",
    "@ui_sh_jinggong"
  }
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
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
  self.JobID = ""
  self.CurFormulaID = ""
  self.vscroll_value = 0
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("job_rec", self, "form_stage_main\\form_life\\form_job_composite", "on_job_rec_refresh")
    databinder:AddTableBind("FormulaRec", self, "form_stage_main\\form_life\\form_job_composite", "on_formula_rec_refresh")
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, self, "form_stage_main\\form_life\\form_job_composite", "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, self, "form_stage_main\\form_life\\form_job_composite", "on_toolbox_viewport_change")
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("job_rec", self)
    databinder:DelTableBind("FormulaRec", self)
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
end
function on_btn_composite_get_capture(self)
end
function on_btn_composite_lost_capture(self)
end
function on_btn_composite_refine_get_capture(self)
end
function on_btn_composite_refine_lost_capture(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form:Close()
end
function on_formula_rec_refresh(self, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  fresh_form_job(self)
end
function on_toolbox_viewport_change(form, optype, view_ident, index)
  if not get_life_form_visible() then
    return
  end
  fresh_form(form)
end
function fresh_form(self)
  local gui = nx_value("gui")
  local job_name = gui.TextManager:GetText(nx_string(self.JobID))
  self.lbl_job_name.Text = nx_widestr(job_name)
  self.mltbox_dec:Clear()
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  self.ipt_2.Text = nx_widestr(Text_ss)
  sortString = nx_widestr("")
  sortClass = gui.TextManager:GetFormatText("str_quanbu")
  if "sh_kg" == nx_string(self.JobID) or "sh_nf" == nx_string(self.JobID) then
    self.btn_set_share.Visible = false
  end
  fresh_form_job(self)
end
function fresh_form_job(self)
  local gui = nx_value("gui")
  sortClass = gui.TextManager:GetFormatText("str_quanbu")
  fresh_info(self)
end
function clear_info(form)
  form.combobox_sort.Text = nx_widestr("")
  form.combobox_sort.DropListBox:ClearString()
  return 1
end
function fresh_info(self)
  clear_info(self)
  local jobid = self.JobID
  if jobid == "" or jobid == nil then
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
  if not client_player:FindRecord("job_rec") then
    return
  end
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  local level = client_player:QueryRecord("job_rec", row, 1)
  local gui = nx_value("gui")
  local job_name = gui.TextManager:GetText(nx_string(jobid))
  refresh_tree_list(self, job_name, jobid, level)
end
function on_job_rec_refresh(form, recordname, optype, row, clomn)
  if optype == "update" then
    fresh_form(form)
  end
end
function refresh_current_job_exp(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local temp_node
  local jobid = form.JobID
  if jobid == "" or jobid == nil then
    return
  end
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  if row < 0 then
    return
  end
  local level = client_player:QueryRecord("job_rec", row, 1)
end
function get_job_level(jobid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local temp_node
  if jobid == "" or jobid == nil then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, jobid, 0)
  local level = client_player:QueryRecord("job_rec", row, 1)
  return level
end
function refresh_tree_list(form, job_name, jobid, job_level)
  local gui = nx_value("gui")
  local jobinfoini = nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  if not nx_is_valid(jobinfoini) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local sec_index = jobinfoini:FindSectionIndex(nx_string(jobid))
  if sec_index < 0 then
    return
  end
  form.tree_job:BeginUpdate()
  local type_nameid2 = jobinfoini:ReadString(sec_index, "type2", "")
  local type_name2 = gui.TextManager:GetFormatText(nx_string(type_nameid2))
  if nx_widestr(type_name2) ~= nx_widestr("") then
    local composite_root = form.tree_job:CreateRootNode(nx_widestr(type_name2))
    composite_root.search_id = nx_widestr(type_name2)
    local compositestr = jobinfoini:ReadString(sec_index, "composite", "")
    refresh_tree_list_composite(form, composite_root, compositestr, job_level)
    composite_root:ExpandAll()
  end
  form.tree_job:EndUpdate()
  form.tree_job.VScrollBar.Value = form.vscroll_value
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
function refresh_tree_list_composite(form, root, composite_info, job_level)
  local gui = nx_value("gui")
  local composite_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_composite_prop.ini")
  if not nx_is_valid(composite_ini) then
    return
  end
  if composite_info == "" or composite_info == nil then
    return
  end
  local str_lst = util_split_string(composite_info, ",")
  local IniManager = nx_value("IniManager")
  local iniformula = IniManager:GetIniDocument("share\\Item\\life_formula.ini")
  local str_quanbu = gui.TextManager:GetFormatText("str_quanbu")
  form.combobox_sort.DropListBox:AddString(nx_widestr(str_quanbu))
  local selectNode
  for i = 1, table.getn(str_lst) do
    local str = str_lst[i]
    local sec_index = composite_ini:FindSectionIndex(nx_string(str))
    if 0 <= sec_index then
      local item_count = composite_ini:GetSectionItemCount(sec_index)
      local composite_typeid = str
      local composite_txt = gui.TextManager:GetFormatText(nx_string(composite_typeid))
      local gather_type_node = root:CreateNode(nx_widestr(composite_txt))
      gather_type_node.search_id = composite_txt
      gather_type_node.has_child = false
      gather_type_node.has_valid_child = false
      gather_type_node.DrawMode = "FitWindow"
      gather_type_node.ExpandCloseOffsetX = 0
      gather_type_node.ExpandCloseOffsetY = 2
      gather_type_node.TextOffsetX = 25
      gather_type_node.TextOffsetY = 1
      gather_type_node.NodeOffsetY = 5
      gather_type_node.ForeColor = "255,255,180,0"
      gather_type_node.Font = "font_main"
      gather_type_node.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "out")
      gather_type_node.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
      gather_type_node.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 2, "on")
      local showdroplist = false
      for j = 0, item_count - 1 do
        local temp_str = composite_ini:GetSectionItemValue(sec_index, nx_string(j))
        local node_info = util_split_string(temp_str, "/")
        if table.getn(node_info) == 1 then
          local compositeNum = 0
          local str_lst = util_split_string(node_info[1], ",")
          for i = 1, table.getn(str_lst) do
            local formula_id = str_lst[i]
            local sec_item_index = iniformula:FindSectionIndex(formula_id)
            local porduct_item = ""
            local ProfessonLevel = 0
            local is_formula_valid = false
            if 0 <= sec_item_index then
              is_formula_valid = true
              porduct_item = iniformula:ReadString(sec_item_index, "ComposeResult", "")
              ProfessonLevel = iniformula:ReadString(sec_item_index, "ProfessonLevel", "0")
            end
            if is_formula_valid and nx_number(ProfessonLevel) <= nx_number(get_job_level(form.JobID)) then
              showdroplist = true
              local node_name = gui.TextManager:GetFormatText(porduct_item)
              if can_show_formula(iniformula, formula_id) and (sortString == nx_widestr("") or -1 ~= nx_function("ext_ws_find", node_name, sortString)) then
                local subnode
                compositeNum = count_item(nx_string(formula_id))
                if is_Learned_formula(formula_id) and 0 < nx_number(compositeNum) then
                  compositeNum = " (" .. nx_string(compositeNum) .. ")"
                else
                  compositeNum = ""
                end
                subnode = gather_type_node:CreateNode(nx_widestr(node_name) .. nx_widestr(compositeNum))
                subnode.search_id = node_name
                gather_type_node.has_child = true
                subnode.id = node_name
                subnode.ntype = NODE_TYPE_COMPOSITE
                subnode.formula_list = nx_string(formula_id)
                subnode.TextOffsetX = 25
                subnode.TextOffsetY = 1
                subnode.Font = "font_main"
                subnode.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "out")
                subnode.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
                subnode.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
                if is_nothing_learned(nx_string(formula_id)) then
                  subnode.ForeColor = "255,146,146,146"
                else
                  subnode.ForeColor = "255,255,255,255"
                  gather_type_node.has_valid_child = true
                end
                if nx_is_valid(subnode) and not nx_is_valid(selectNode) then
                  selectNode = subnode
                end
                if nx_is_valid(subnode) and formula_id == form.CurFormulaID then
                  selectNode = subnode
                end
              end
            end
          end
        end
      end
      if nx_widestr(sortClass) == nx_widestr(str_quanbu) or nx_widestr(sortClass) == nx_widestr(composite_txt) then
        if gather_type_node.has_child == false then
          root:RemoveNode(gather_type_node)
        end
      else
        root:RemoveNode(gather_type_node)
      end
      if showdroplist then
        form.combobox_sort.DropListBox:AddString(nx_widestr(composite_txt))
      end
    end
  end
  form.tree_job.SelectNode = selectNode
  form.combobox_sort.Text = nx_widestr(sortClass)
end
function on_tree_job_select_changed(self)
  local node = self.SelectNode
  if not nx_is_valid(node) then
    return
  end
  fresh_sub_info(self.ParentForm)
end
function on_tree_job_left_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
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
function fresh_sub_info(self)
  local node = get_down_node(self.tree_job.SelectNode)
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "ntype") then
    return
  end
  local id = node.id
  if not nx_find_custom(node, "formula_list") then
    return
  end
  fresh_formula(self, id, node.formula_list)
end
function on_btn_composite_click(btn)
  local form = btn.ParentForm
  if not CanComposite(form) then
    return
  end
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local formula_id = form.CurFormulaID
  on_ipt_1_changed(form.ipt_1)
  local num = nx_int(form.ipt_1.Text)
  local sec_index = iniformula:FindSectionIndex(formula_id)
  if sec_index < 0 then
    return
  end
  local TableNPCLimit = iniformula:ReadString(sec_index, nx_string("TableNPCLimit"), "")
  if TableNPCLimit ~= "" then
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_dazaotai_info06"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_send_compose", nx_string(formula_id), num, 0, 0)
    end
  else
    nx_execute("custom_sender", "custom_send_compose", nx_string(formula_id), num, 0, 0)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_composite_refine_click(btn)
  local form = btn.ParentForm
  if not CanComposite(form) then
    return
  end
  local formula_id = form.CurFormulaID
  on_ipt_1_changed(form.ipt_1)
  local num = nx_int(form.ipt_1.Text)
  nx_execute("custom_sender", "custom_send_compose", nx_string(formula_id), num, 0, 1)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function CanComposite(form)
  if not nx_find_custom(form, "CurFormulaID") then
    return false
  end
  local formula_id = form.CurFormulaID
  local num = nx_int(form.ParentForm.ipt_1.Text)
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local sec_index = iniformula:FindSectionIndex(formula_id)
  if sec_index < 0 then
    return false
  end
  if not nx_is_valid(iniformula) then
    return false
  end
  local needene = iniformula:ReadString(sec_index, "ComposeUseStrenth", "")
  local needmoney = iniformula:ReadString(sec_index, "CompositeNeedMoney", "")
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  local tool_id = iniformula:ReadInteger(sec_index, "ToolLimitedID", 0)
  if not is_Learned_formula(formula_id) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1801"))
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local capital = client_player:QueryProp("CapitalType1") + client_player:QueryProp("CapitalType2")
  if nx_number(needmoney) > nx_number(capital) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("12409"))
    return false
  end
  local cur_ene = client_player:QueryProp("Ene")
  if nx_int(needene) > nx_int(cur_ene) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1802"))
    return false
  end
  local str_lst = util_split_string(needitem, ";")
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = nx_string(str_temp[1])
    local num = nx_int(str_temp[2])
    local MaterialNum = Get_Material_Num(item, VIEWPORT_MATERIAL_TOOL) + Get_Material_Num(item, VIEWPORT_TOOL)
    if nx_int(MaterialNum) < nx_int(num) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1813"))
      return false
    end
  end
  if 0 < nx_number(tool_id) then
    local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeToolLimitInfo.ini")
    if not nx_is_valid(ini) then
      return false
    end
    if not ini:FindSection(nx_string(tool_id)) then
      return false
    end
    local bRes = false
    local sec_index = ini:FindSectionIndex(nx_string(tool_id))
    if sec_index < 0 then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1144"))
      return false
    end
    local tool_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(tool_table) do
      local tool_info = tool_table[i]
      local info_lst = util_split_string(tool_info, ",")
      if table.getn(info_lst) == 3 and nx_int(Get_Material_Num(info_lst[1], VIEWPORT_TOOL)) > nx_int(0) then
        bRes = true
        break
      end
    end
    if not bRes then
      if form.JobID == "sh_ss" or form.JobID == "sh_hs" then
        return true
      end
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("1144"))
      return false
    end
  end
  return true
end
function is_Learned_formula(formulaid)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:FindRecordRow("FormulaRec", 1, nx_string(formulaid), 0)
  if 0 <= rows then
    return true
  else
    return false
  end
end
function is_nothing_learned(formula_str)
  local formula_list = util_split_string(nx_string(formula_str), ",")
  for i = 1, table.getn(formula_list) do
    local formula_id = formula_list[i]
    if is_Learned_formula(formula_id) == true then
      return false
    end
  end
  return true
end
function fresh_formula(form, id, formula_str)
  control_info_clear(form)
  show_composite_info(form, nx_string(formula_str))
end
function control_info_clear(form)
  form.CurFormulaID = ""
  form.product_grid:Clear()
  form.product_grid:SetSelectItemIndex(nx_int(-1))
  form.material_grid:Clear()
  form.material_grid:SetSelectItemIndex(nx_int(-1))
end
function on_product_grid_select_changed(grid, index)
  local form = grid.ParentForm
  local jobid = form.JobID
  if jobid == "" or jobid == nil then
    return
  end
  if jobid ~= "sh_qs" and jobid ~= "sh_qg" then
    return
  end
  if not nx_find_custom(form, "CurFormulaID") then
    return
  end
  local func_name = nx_string(grid:GetItemAddText(index, nx_int(2)))
  local formula_id = form.CurFormulaID
  if not is_Learned_formula(formula_id) then
    return
  end
  if func_name == nil then
    return
  end
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(func_name), "Photo")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if gui.GameHand:IsEmpty() then
    local formula_id = form.CurFormulaID
    if jobid == "sh_qs" then
      gui.GameHand:SetHand(GHT_QIN, photo, "qin", formula_id, "", "")
    elseif jobid == "sh_qg" then
      gui.GameHand:SetHand(GHT_BEG, photo, "beg", formula_id, "", "")
    end
  else
    gui.GameHand:ClearHand()
  end
end
function on_product_grid_right_click(self)
  local form = self.ParentForm
  local formula_id = form.CurFormulaID
  local job_name = form.lbl_job_name.Text
  local idindex = form.combobox_sort.DropListBox:FindString(job_name)
  local jobid = JOB_ID_TABLE[idindex]
  nx_execute("tips_game", "hide_tip", self.ParentForm)
  if jobid == "" or jobid == nil then
    return
  end
  if jobid == "sh_qs" then
    nx_execute("custom_sender", "custom_doqin", formula_id)
  elseif jobid == "sh_qg" then
    nx_execute("form_stage_main\\form_life\\form_job_composite", "life_skill_beg", formula_id)
  end
end
function show_composite_info(form, formula_id)
  local ItemQuery = nx_value("ItemQuery")
  local gui = nx_value("gui")
  form.product_grid:Clear()
  form.material_grid:Clear()
  if not nx_is_valid(ItemQuery) or not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if formula_id == "" or formula_id == "nil" then
    return
  end
  form.CurFormulaID = nx_string(formula_id)
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local sec_index = iniformula:FindSectionIndex(formula_id)
  if sec_index < 0 then
    return
  end
  if not nx_is_valid(iniformula) then
    return
  end
  local needene = iniformula:ReadString(sec_index, "ComposeUseStrenth", "")
  local needmoney = iniformula:ReadString(sec_index, "CompositeNeedMoney", "")
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  local porduct_item = iniformula:ReadString(sec_index, "ComposeResult", "")
  local exp_package = iniformula:ReadInteger(sec_index, "ExpPackageID", 0)
  local needpoint = iniformula:ReadInteger(sec_index, "NeedPoint", 0)
  local Profession = iniformula:ReadString(sec_index, "Profession", "")
  local gamename = iniformula:ReadString(sec_index, "GameName", "")
  local npc_limit_table = iniformula:ReadString(sec_index, "TableNPCLimit", "")
  local temp_job_id, job_exp = get_exp_from_package(exp_package)
  local item_type = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), "ItemType"))
  if item_type >= ITEMTYPE_EQUIP_MIN and item_type <= ITEMTYPE_EQUIP_MAX then
    photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(porduct_item), "Photo")
  else
    photo = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), nx_string("Photo"))
  end
  local name = gui.TextManager:GetFormatText(nx_string(porduct_item))
  local Text_tl = gui.TextManager:GetText("ui_sh_xhtl")
  local Text_sl = gui.TextManager:GetText("ui_sh_tssld")
  local Text_xd
  if Profession == "sh_ss" or Profession == "sh_hs" then
    Text_xd = gui.TextManager:GetText("ui_sh_qs_hdxd")
  else
    Text_xd = gui.TextManager:GetText("ui_sh_xhxd")
  end
  local Text_zsxy = gui.TextManager:GetText("ui_sh_zsxy")
  local tool_name = gui.TextManager:GetText(Profession)
  form.mltbox_dec:Clear()
  local dec_text = nx_widestr("")
  if nx_int(needpoint) ~= nx_int(0) then
    dec_text = dec_text .. nx_widestr(Text_xd) .. nx_widestr(-needpoint) .. nx_widestr("   ")
  end
  if needmoney ~= nil and needmoney ~= "" and nx_int(needmoney) > nx_int(0) then
    local Text_jq = gui.TextManager:GetText("ui_off_money_pay")
    local money_text = format_prize_money(nx_int64(needmoney))
    form.mltbox_dec:AddHtmlText(nx_widestr(Text_jq) .. nx_widestr(money_text), nx_int(-1))
  end
  if nx_string(needene) ~= nx_string("") then
    dec_text = dec_text .. nx_widestr(Text_tl) .. nx_widestr(needene)
  end
  form.mltbox_dec:AddHtmlText(nx_widestr(dec_text), nx_int(-1))
  if nx_int(needene) > nx_int(0) then
    form.lbl_ene_value.Text = nx_widestr(nx_string(needene))
    form.groupbox_ene.Visible = true
  else
    form.groupbox_ene.Visible = false
  end
  if nx_int(job_exp) > nx_int(0) then
    form.lbl_exp_value.Text = nx_widestr(nx_string(job_exp))
    form.groupbox_exp.Visible = true
  else
    form.groupbox_exp.Visible = false
  end
  form.product_grid:AddItem(0, photo, nx_widestr(name), 1, -1)
  form.product_grid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(porduct_item))
  if Profession == "sh_cs" or Profession == "sh_ds" or Profession == "sh_ys" then
    local pz_key, pz_value = get_ydc_pingzhi(Profession, ItemQuery, porduct_item)
    form.product_grid:SetItemAddInfo(nx_int(0), nx_int(4), nx_widestr(nx_string(pz_key)))
    form.product_grid:SetItemAddInfo(nx_int(0), nx_int(5), nx_widestr(nx_string(pz_value)))
  end
  local str_lst = util_split_string(needitem, ";")
  form.groupbox_3.Visible = true
  for i = 1, table.getn(str_lst) do
    local str_temp = util_split_string(str_lst[i], ",")
    local item = nx_string(str_temp[1])
    local num = nx_int(str_temp[2])
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item))
    if bExist then
      local tempphoto = ItemQuery:GetItemPropByConfigID(nx_string(item), nx_string("Photo"))
      local itemname = nx_execute("form_stage_main\\form_life\\form_job_gather", "takeoutmore_str", gui.TextManager:GetText(item))
      itemname = gui.TextManager:GetText(item)
      local text = nx_widestr("<font color=\"#5f4325\">") .. nx_widestr(itemname) .. nx_widestr("</font>")
      form.material_grid:AddItem(i - 1, tempphoto, text, 0, -1)
      local MaterialNum = Get_Material_Num(item, VIEWPORT_MATERIAL_TOOL) + Get_Material_Num(item, VIEWPORT_TOOL)
      if nx_int(MaterialNum) >= nx_int(num) then
        form.material_grid:ChangeItemImageToBW(i - 1, false)
        form.material_grid:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#00aa00\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.material_grid:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
      else
        form.material_grid:ChangeItemImageToBW(i - 1, true)
        form.material_grid:SetItemAddInfo(nx_int(i - 1), nx_int(1), nx_widestr("<font color=\"#ff0000\">" .. nx_string(MaterialNum) .. "/" .. nx_string(num) .. "</font>"))
        form.material_grid:ShowItemAddInfo(nx_int(i - 1), nx_int(1), true)
        form.groupbox_3.Visible = false
      end
      form.material_grid:SetItemAddInfo(nx_int(i - 1), nx_int(2), nx_widestr(item))
    end
  end
  local num = count_item(nx_string(formula_id))
  if nx_int(num) > nx_int(50) then
    num = nx_int(50)
  end
  form.ipt_1.MaxDigit = nx_int(num)
  if nx_number(num) >= 1 then
    form.ipt_1.Text = nx_widestr(1)
  else
    form.ipt_1.Text = nx_widestr(0)
  end
  form.btn_composite.Text = nx_widestr(life_btn_name_table[nx_string(Profession)][1])
  form.btn_composite_refine.Text = nx_widestr(life_btn_name_table[nx_string(Profession)][2])
  if not is_Learned_formula(formula_id) then
    form.product_grid:ChangeItemImageToBW(nx_int(0), true)
    form.groupbox_3.Visible = false
    form.btn_add_to_share.Visible = false
  elseif check_can_share(form) == false then
    form.btn_add_to_share.Visible = false
  else
    form.btn_add_to_share.Visible = true
  end
  if npc_limit_table ~= "" then
    form.btn_add_to_share.Visible = false
  end
  if Profession == "sh_qg" then
    form.groupbox_3.Visible = false
  end
  local GameModule = iniformula:ReadString(sec_index, nx_string("GameName"), "")
  local TableNPCLimit = iniformula:ReadString(sec_index, nx_string("TableNPCLimit"), "")
  if TableNPCLimit ~= "" then
    form.lbl_tabletips.Visible = true
  else
    form.lbl_tabletips.Visible = false
  end
  if GameModule == "BrokenDoorModule" and TableNPCLimit == "" then
    form.btn_composite.Visible = true
    form.btn_composite_refine.Visible = true
    form.ipt_1.Visible = true
    form.lbl_10.Visible = true
  else
    form.btn_composite.Visible = true
    form.btn_composite_refine.Visible = false
    if GameModule ~= "" then
      form.ipt_1.Visible = false
      form.lbl_10.Visible = false
    else
      form.ipt_1.Visible = true
      form.lbl_10.Visible = true
    end
  end
end
function get_ydc_pingzhi(jobid, ItemQuery, porduct_item)
  local pingzhi_key = ""
  local pingzhi_value = ""
  if nx_string(jobid) == "sh_cs" then
    pingzhi_key = "CSSkillLevel"
    pingzhi_value = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), nx_string(pingzhi_key))
  elseif nx_string(jobid) == "sh_ys" then
    for i = 1, 3 do
      local key = "YSSkillLevel"
      pingzhi_key = nx_string(key) .. nx_string(i)
      pingzhi_value = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), nx_string(pingzhi_key))
      if pingzhi_key ~= nil and pingzhi_value ~= "" then
        if pingzhi_key == "YSSkillLevel1" then
          pingzhi_value = nx_int(pingzhi_value) / 10
        end
        break
      end
    end
  elseif nx_string(jobid) == "sh_ds" then
    pingzhi_key = "DSSkillLevel"
    pingzhi_value = ItemQuery:GetItemPropByConfigID(nx_string(porduct_item), nx_string(pingzhi_key))
  else
    pingzhi_key = ""
    pingzhi_value = ""
  end
  return pingzhi_key, pingzhi_value
end
function format_prize_money(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  local money_text = ""
  if nx_number(ding) > 0 then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_bag_ding"))
  end
  if nx_number(liang) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(liang) .. nx_widestr(util_text("ui_bag_liang"))
  end
  if nx_number(wen) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(wen) .. nx_widestr(util_text("ui_bag_wen"))
  end
  return money_text
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
function on_product_grid_mousein_grid(grid, index)
  local item_key = nx_string(grid:GetItemAddText(index, nx_int(4)))
  local item_value = nx_string(grid:GetItemAddText(index, nx_int(5)))
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
  if item_config == "" then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
  if bExist == false then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Name"))
  local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
  local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  prop_array.PZKey = nx_string(item_key)
  prop_array.PZValue = nx_string(item_value)
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
function on_product_grid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function count_item(composite)
  local game_client = nx_value("game_client")
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local sec_index = iniformula:FindSectionIndex(composite)
  if sec_index < 0 then
    return
  end
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  local str_lst = util_split_string(needitem, ";")
  local flag = false
  local min_num = 999
  if 0 < table.getn(str_lst) then
    for i = 1, table.getn(str_lst) do
      local str_temp = util_split_string(str_lst[i], ",")
      local item = str_temp[1]
      local num = nx_int(str_temp[2])
      if num <= nx_int(0) then
        num = 1
      end
      local total = Get_Material_Num(item, VIEWPORT_MATERIAL_TOOL) + Get_Material_Num(item, VIEWPORT_TOOL)
      local temp_min_num = nx_int(total / nx_int(num))
      if nx_int(temp_min_num) < nx_int(min_num) then
        min_num = temp_min_num
      end
    end
  else
    flag = true
    min_num = 1
  end
  return min_num
end
function on_ipt_2_changed(self)
  sortString = nx_widestr(self.Text)
  local form = self.ParentForm
  sortClass = nx_widestr(form.combobox_sort.Text)
  fresh_info(form)
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
function on_ipt_1_changed(self)
  local value = nx_int(self.Text)
  if value > nx_int(self.MaxDigit) then
    self.Text = nx_widestr(self.MaxDigit)
  elseif value < nx_int(0) then
    self.Text = nx_widestr("0")
  end
end
function Get_Material_Num(item, viewID)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewID))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  return nx_int(cur_amount)
end
function life_skill_beg(para)
  local game_client = nx_value("game_client")
  local game_visual = nx_value("game_visual")
  local client_player = game_client:GetPlayer()
  local target = game_client:GetSceneObj(nx_string(client_player:QueryProp("LastObject")))
  if not nx_is_valid(target) then
    local gui = nx_value("gui")
    local info = gui.TextManager:GetText("12400")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_chat_13")
    gui.TextManager:Format_AddParam(info)
    local chat_info = gui.TextManager:Format_GetText()
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(chat_info, SYSTYPE_FIGHT, 0)
    end
    return
  end
  local path_finding = nx_value("path_finding")
  local objtype = target:QueryProp("Type")
  nx_execute("custom_sender", "custom_send_beg", para)
end
function open_form_job(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_job_composite", true)
  if not nx_is_valid(form) then
    return
  end
  form.JobID = job_id
  util_auto_show_hide_form("form_stage_main\\form_life\\form_job_composite")
end
function on_btn_set_share_click(btn)
  local form = btn.ParentForm
  local jobid = form.job_id
  if jobid == "" or jobid == nil then
    return
  end
  local formshareset = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(formshareset) then
    return
  end
  if formshareset.Visible == true then
    nx_execute("form_stage_main\\form_life\\form_job_share_set", "close_form_job", jobid)
  else
    nx_execute("form_stage_main\\form_life\\form_job_share_set", "open_form_job", jobid)
  end
end
function on_btn_add_to_share_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn.ParentForm, "CurFormulaID") then
    return
  end
  local gui = nx_value("gui")
  local job_id = btn.ParentForm.JobID
  local formshareset = util_get_form("form_stage_main\\form_life\\form_job_share_set", true)
  if not nx_is_valid(formshareset) then
    return
  end
  local formula_id = btn.ParentForm.CurFormulaID
  if is_Learned_formula(formula_id) then
    if formshareset.Visible == false then
      nx_execute("form_stage_main\\form_life\\form_job_share_set", "open_form_job", job_id, formula_id)
    else
      nx_execute("form_stage_main\\form_life\\form_job_share_set", "add_temp_formula_id", job_id, formula_id)
      nx_execute("form_stage_main\\form_life\\form_job_share_set", "form_refresh", job_id)
    end
  end
end
function change_share_set_open(job_id)
end
function check_can_share(form)
  local jobid = form.JobID
  if jobid == "" or jobid == nil then
    return false
  end
  local SHARE_TABLE = {
    "sh_tj_share_rec",
    "sh_ds_share_rec",
    "sh_ys_share_rec",
    "sh_cf_share_rec",
    "sh_cs_share_rec",
    "sh_jq_share_rec"
  }
  local recname = jobid .. "_share_rec"
  for i = 1, table.getn(SHARE_TABLE) do
    if recname == SHARE_TABLE[i] then
      return true
    end
  end
  return false
end
function on_combobox_sort_selected(self)
  local form = self.ParentForm
  sortClass = nx_widestr(self.Text)
  sortString = nx_widestr("")
  fresh_info(form)
  self.Text = nx_widestr(sortClass)
end
function get_exp_from_package(exp_package)
  if nx_number(exp_package) < 0 then
    return "", 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "", 0
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\LifeExpInfo.ini")
  if not nx_is_valid(ini) then
    return "", 0
  end
  if ini:FindSection(nx_string(exp_package)) then
    local sec_index = ini:FindSectionIndex(nx_string(exp_package))
    if sec_index < 0 then
      return "", 0
    end
    local exp_table = ini:GetItemValueList(nx_number(sec_index), nx_string("r"))
    for i = 1, table.getn(exp_table) do
      local exp_info = exp_table[i]
      local info_lst = util_split_string(exp_info, ",")
      if table.getn(info_lst) >= 8 then
        local res1 = false
        local res2 = false
        local row = client_player:FindRecordRow("job_rec", 0, info_lst[1], 0)
        if 0 <= row then
          local job_level = client_player:QueryRecord("job_rec", row, 1)
          res1 = cmp_level_with_op(info_lst[2], job_level, info_lst[3])
        end
        row = client_player:FindRecordRow("job_rec", 0, info_lst[4], 0)
        if 0 <= row then
          local job_level = client_player:QueryRecord("job_rec", row, 1)
          res2 = cmp_level_with_op(info_lst[5], job_level, info_lst[6])
        end
        if res1 and res2 then
          return info_lst[7], info_lst[8]
        end
      end
    end
  end
  return "", 0
end
function cmp_level_with_op(op, cur_level, cmp_val)
  if nx_string(op) == nil or nx_string(op) == "" then
    return false
  end
  cur_level = nx_int(cur_level)
  cmp_val = nx_int(cmp_val)
  if nx_string(op) == ">=" then
    if cur_level >= cmp_val then
      return true
    end
  elseif nx_string(op) == "<=" then
    if cur_level <= cmp_val then
      return true
    end
  elseif nx_string(op) == "=" or nx_string(op) == "==" then
    if cur_level == cmp_val then
      return true
    end
  elseif nx_string(op) == ">" then
    if cur_level > cmp_val then
      return true
    end
  elseif nx_string(op) == "<" and cur_level < cmp_val then
    return true
  end
  return false
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
    if nx_find_custom(node, "formula_list") and node.formula_list == find_info then
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
function can_show_formula(ini, formula_id)
  if is_Learned_formula(formula_id) then
    return true
  else
    local index = ini:FindSectionIndex(formula_id)
    if index < 0 then
      return false
    end
    if 1 == ini:ReadInteger(index, "ColorLevel", 0) then
      return true
    else
      return false
    end
  end
  return false
end
function on_lbl_tabletips_get_capture(self)
  local form = self.ParentForm
  local formula_id = form.CurFormulaID
  local gui = nx_value("gui")
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  local sec_index = iniformula:FindSectionIndex(formula_id)
  if sec_index < 0 then
    return
  end
  local TableNpcToolinfo = iniformula:ReadString(sec_index, nx_string("TableNpcToolinfo"), "")
  if TableNpcToolinfo ~= "" then
    local str_lst = util_split_string(TableNpcToolinfo, ";")
    local tipstext = nx_widestr("")
    for i = 1, table.getn(str_lst) do
      local str = str_lst[i]
      tipstext = nx_widestr(tipstext) .. nx_widestr(gui.TextManager:GetText("desc_" .. str .. "_1")) .. nx_widestr("<br>")
    end
    local x, y = gui:GetCursorPosition()
    nx_execute("tips_game", "show_text_tip", nx_widestr(tipstext), x, y, 0, form)
  end
end
function on_lbl_tabletips_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_tree_job_vscroll_changed(self, value)
  local form = self.ParentForm
  form.vscroll_value = value
end
