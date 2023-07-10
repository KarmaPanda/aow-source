require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("define\\sysinfo_define")
local select_btn
local qin_compose_id = ""
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function on_open_form(form, ...)
  form.job_id = arg[1]
  form.CurFormulaID = ""
  open_fresh_form(form)
end
function get_life_form_visible()
  local form = nx_value("form_stage_main\\form_life\\form_job_main_new")
  if nx_is_valid(form) then
    return form.Visible
  else
    return false
  end
end
function main_form_init(form)
  form.Fixed = true
  nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  form.job_id = ""
  form.store_select_id = nil
  form.sortClass = ""
  form.sortString = ""
  form.CurFormulaID = ""
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("job_rec", form, "form_stage_main\\form_life\\form_job_qishi", "on_job_rec_refresh")
    databinder:AddTableBind("sh_qis_share_rec", form, "form_stage_main\\form_life\\form_job_qishi", "on_qishi_rec_refresh")
    databinder:AddTableBind("sh_qg_share_rec", form, "form_stage_main\\form_life\\form_job_qishi", "on_qigai_rec_refresh")
    databinder:AddTableBind("sh_qs_share_rec", form, "form_stage_main\\form_life\\form_job_qishi", "on_qinshi_rec_refresh")
    databinder:AddTableBind("FormulaRec", form, "form_stage_main\\form_life\\form_job_qishi", "on_formula_rec_refresh")
  end
end
function on_main_form_close(form)
  if nx_is_valid(form.tree_job.SelectNode) and nx_find_custom(form.tree_job.SelectNode, "search_id") then
    form.store_select_id = form.tree_job.SelectNode.search_id
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("job_res", form)
    databinder:DelTableBind("sh_qis_share_rec", form)
    databinder:DelTableBind("sh_qg_share_rec", form)
    databinder:DelTableBind("sh_qs_share_rec", form)
    databinder:DelTableBind("FormulaRec", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function open_fresh_form(form)
  local gui = nx_value("gui")
  local text_ss = gui.TextManager:GetText("ui_sh_ss")
  form.ipt_search.Text = nx_widestr(text_ss)
  form.sortString = ""
  form.sortClass = gui.TextManager:GetFormatText("str_quanbu")
  select_btn = nil
  qin_compose_id = ""
  fresh_form(form)
end
function fresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  clear_info(form)
  refresh_exp_info(form)
  refresh_tree_list(form)
end
function refresh_exp_info(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local gui = nx_value("gui")
  local job_id = form.job_id
  if not find_life_job(job_id) then
    return
  end
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_job_id.Text = gui.TextManager:GetFormatText(job_id)
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return
  end
end
function refresh_tree_list(form)
  if not nx_is_valid(form) then
    return
  end
  local job_id = form.job_id
  if not find_life_job(job_id) then
    return
  end
  refresh_tree_gather_list(form, job_id)
end
function refresh_tree_gather_list(form, job_id)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not find_life_job(job_id) then
    return
  end
  local tree_list = form.tree_job
  tree_list.IsNoDrawRoot = true
  local job_info_ini = nx_execute("util_functions", "get_ini", "share\\Life\\job_info.ini")
  local gather_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\life\\job_gather_prop.ini")
  local life_formula_ini
  if form.job_id == "sh_qs" or form.job_id == "sh_qg" then
    life_formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  elseif form.job_id == "sh_qis" or form.job_id == "sh_gs" then
    life_formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  else
    return
  end
  if not nx_is_valid(gather_ini) then
    return
  end
  if not nx_is_valid(job_info_ini) then
    return
  end
  if not nx_is_valid(life_formula_ini) then
    return
  end
  local sec_index = job_info_ini:FindSectionIndex(nx_string(job_id))
  if sec_index < 0 then
    nx_log("share\\Life\\job_info.ini sec_index= " .. nx_string(job_id))
    return
  end
  local type_name_id = job_info_ini:ReadString(sec_index, "type1", "")
  local type_name = gui.TextManager:GetFormatText(nx_string(type_name_id))
  if nx_widestr(type_name) == nx_widestr("") then
    return
  end
  local gather_root = tree_list:CreateRootNode(nx_widestr(type_name))
  gather_root.search_id = type_name
  local gather_info = job_info_ini:ReadString(sec_index, "gather", "")
  if nx_string(gather_info) == "" then
    return
  end
  local selectNode
  local str_quanbu = gui.TextManager:GetFormatText("str_quanbu")
  form.combobox_sort.DropListBox:AddString(nx_widestr(str_quanbu))
  local gather_lst = util_split_string(gather_info, ",")
  for i = 1, table.getn(gather_lst) do
    local gather_type_id = gather_lst[i]
    local sec_index1 = gather_ini:FindSectionIndex(nx_string(gather_type_id))
    if sec_index1 < 0 then
      nx_log("ini\\ui\\life\\job_gather_prop.ini sec_index= " .. nx_string(gather_type_id))
      return
    end
    local item_count = gather_ini:GetSectionItemCount(sec_index1)
    local gather_type = gui.TextManager:GetFormatText(nx_string(gather_type_id))
    local show_list = false
    for j = 1, item_count do
      local qipu_str = gather_ini:ReadString(sec_index1, nx_string(j), "")
      local node_info = util_split_string(qipu_str, "/")
      if table.getn(node_info) ~= 3 then
        return
      end
      local node_item_str = nx_string(node_info[3])
      local node_item_str_table = util_split_string(node_item_str, ",")
      local color_level = 0
      if 0 < table.getn(node_item_str_table) then
        local formula_sec_index = life_formula_ini:FindSectionIndex(nx_string(node_item_str_table[1]))
        color_level = life_formula_ini:ReadInteger(formula_sec_index, "ColorLevel", 0)
      end
      local b_learn = false
      if nx_string(job_id) == "sh_qis" then
        if not is_nothing_qipu_learned(node_item_str) then
          b_learn = true
        end
      elseif nx_string(job_id) == "sh_qg" or nx_string(job_id) == "sh_qs" then
        if not is_nothing_learned(node_item_str) then
          b_learn = true
        end
      elseif nx_string(job_id) == "sh_gs" then
        b_learn = true
      end
      if b_learn or color_level < 2 then
        show_list = true
      end
    end
    if show_list then
      form.combobox_sort.DropListBox:AddString(nx_widestr(gather_type))
    end
    if nx_widestr(form.sortClass) == nx_widestr(str_quanbu) or nx_widestr(form.sortClass) == nx_widestr(gather_type) then
      local gather_type_node = gather_root:CreateNode(nx_widestr(gather_type))
      gather_type_node.search_id = gather_type
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
      for j = 1, item_count do
        local qipu_str = gather_ini:ReadString(sec_index1, nx_string(j), "")
        local node_info = util_split_string(qipu_str, "/")
        if table.getn(node_info) ~= 3 then
          return
        end
        local node_name = nx_string(node_info[1])
        local node_name1 = gui.TextManager:GetFormatText(nx_string(node_name))
        if nx_widestr(form.sortString) == nx_widestr("") or -1 ~= nx_function("ext_ws_find", node_name1, form.sortString) then
          local node_item_str = nx_string(node_info[3])
          local node_item_str_table = util_split_string(node_item_str, ",")
          local color_level = 0
          if 0 < table.getn(node_item_str_table) then
            local formula_sec_index = life_formula_ini:FindSectionIndex(nx_string(node_item_str_table[1]))
            color_level = life_formula_ini:ReadInteger(formula_sec_index, "ColorLevel", 0)
          end
          local __item_str = ""
          local qipu_node
          for k = 1, table.getn(node_item_str_table) do
            local node_need_lv = get_qipu_level(life_formula_ini, job_id, node_item_str_table[k])
            local job_level = get_job_level(job_id)
            qipu_node = nil
            if nx_int(job_level) >= nx_int(node_need_lv) then
              __item_str = nx_string(__item_str) .. nx_string(node_item_str_table[k]) .. ","
            end
          end
          if nx_string(__item_str) ~= "" and 1 < string.len(__item_str) then
            local b_learn = false
            if nx_string(job_id) == "sh_qis" then
              if not is_nothing_qipu_learned(node_item_str) then
                b_learn = true
              end
            elseif nx_string(job_id) == "sh_qg" or nx_string(job_id) == "sh_qs" then
              if not is_nothing_learned(node_item_str) then
                b_learn = true
              end
            elseif nx_string(job_id) == "sh_gs" then
              b_learn = true
            end
            if b_learn or color_level < 2 then
              qipu_node = gather_type_node:CreateNode(node_name1)
              qipu_node.search_id = node_name1
              qipu_node.id = node_name
              qipu_node.node_item_str = nx_string(__item_str)
              qipu_node.ItemHeight = 20
              qipu_node.LevelWidth = 10
              qipu_node.TextOffsetX = 25
              qipu_node.TextOffsetY = 1
              qipu_node.NodeOffsetX = 0
              qipu_node.NodeOffsetY = 0
              qipu_node.Font = "font_main"
              qipu_node.NodeBackImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "out")
              qipu_node.NodeFocusImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
              qipu_node.NodeSelectImage = nx_execute("form_stage_main\\form_life\\form_job_gather", "get_treeview_bg", 3, "on")
              gather_type_node.has_child = true
              qipu_node.ForeColor = "255,255,255,255"
              if nx_string(job_id) == "sh_qis" then
                if b_learn then
                  gather_type_node.has_valid_child = true
                else
                  qipu_node.ForeColor = "255,146,146,146"
                end
              elseif nx_string(job_id) == "sh_qg" or nx_string(job_id) == "sh_qs" then
                if b_learn then
                  gather_type_node.has_valid_child = true
                else
                  qipu_node.ForeColor = "255,146,146,146"
                end
              elseif nx_string(job_id) == "sh_gs" then
                gather_type_node.has_valid_child = true
              end
            end
          end
          if nx_is_valid(qipu_node) and not nx_is_valid(selectNode) then
            selectNode = qipu_node
          end
          if nx_is_valid(qipu_node) and __item_str == form.CurFormulaID then
            selectNode = qipu_node
          end
        end
      end
      if not gather_type_node.has_child then
        gather_root:RemoveNode(gather_type_node)
      end
    end
  end
  form.combobox_sort.Text = nx_widestr(form.sortClass)
  if not nx_find_custom(form.tree_job, "find_info") or "" == nx_custom(form.tree_job, "find_info") then
    form.tree_job.SelectNode = selectNode
    if nx_find_custom(form, "store_select_id") and form.store_select_id ~= nil then
      form.tree_job.SelectNode = get_node(gather_root, form.store_select_id)
    end
  else
    local node = find_tree_item(form.tree_job, nx_custom(form.tree_job, "find_info"))
    if nx_is_valid(node) then
      node.help_node = true
    end
  end
  gather_root:ExpandAll()
end
function get_qipu_level(ini_obj, jobid, itemid)
  local sec_index = ini_obj:FindSectionIndex(nx_string(itemid))
  if sec_index < 0 then
    return 0
  end
  local need_lvl_flag = "ProfessonLevel"
  local ini_ = ini_obj
  local item_lvl = ""
  if jobid == "sh_qs" then
  elseif jobid == "sh_qis" then
    local qipuid = ini_obj:ReadString(sec_index, "QipuID", "")
    local lifeqipu = nx_execute("util_functions", "get_ini", "share\\Item\\life_qipu.ini")
    if not nx_is_valid(lifeqipu) then
      return 0
    end
    sec_index = lifeqipu:FindSectionIndex(nx_string(qipuid))
    if sec_index < 0 then
      return 0
    end
    ini_ = lifeqipu
    need_lvl_flag = "NeedLevel"
  elseif jobid == "sh_gs" then
    local gsid = ini_obj:ReadString(sec_index, "FortuneTellingID", "")
    local ini_gs = nx_execute("util_functions", "get_ini", "share\\Life\\fortunetelling.ini")
    if not nx_is_valid(ini_gs) then
      return 0
    end
    sec_index = ini_gs:FindSectionIndex(nx_string(gsid))
    if sec_index < 0 then
      return 0
    end
    ini_ = ini_gs
    need_lvl_flag = "Level"
  elseif jobid == "sh_qg" then
    ini_ = nx_execute("util_functions", "get_ini", "share\\Life\\BegSkillInfo.ini")
    if not nx_is_valid(ini_) then
      return 0
    end
    sec_index = ini_:FindSectionIndex(nx_string(itemid))
    if sec_index < 0 then
      return 0
    end
    need_lvl_flag = "Level"
  else
    return 0
  end
  if item_lvl == "" then
    item_lvl = ini_:ReadInteger(sec_index, need_lvl_flag, 0)
  end
  return item_lvl
end
function clear_info(form)
  form.tree_job:CreateRootNode(nx_widestr(""))
  form.combobox_sort.Text = nx_widestr("")
  form.combobox_sort.DropListBox:ClearString()
  form.groupscrollbox_desc:DeleteAll()
end
function on_qishi_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if nx_string(form.job_id) == "sh_qis" then
    fresh_form(form)
  end
end
function on_qigai_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if nx_string(form.job_id) == "sh_qg" then
    fresh_form(form)
  end
end
function on_qinshi_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  if nx_string(form.job_id) == "sh_qs" then
    fresh_form(form)
  end
end
function on_formula_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  fresh_form(form)
end
function on_job_rec_refresh(form, recordname, optype, row, clomn)
  if not get_life_form_visible() then
    return
  end
  fresh_form(form)
end
function on_ipt_search_changed(self)
  local form = self.ParentForm
  form.sortString = nx_widestr(self.Text)
  sortClass = form.combobox_sort.Text
  fresh_form(form)
end
function on_ipt_search_get_focus(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local all = gui.TextManager:GetText("ui_sh_ss")
  if nx_widestr(self.Text) == nx_widestr(all) then
    self.Text = nx_widestr("")
  end
end
function on_combobox_sort_selected(self)
  local form = self.ParentForm
  if nx_widestr(form.sortClass) == nx_widestr(self.Text) then
    return
  end
  form.tree_job.SelectNode = nil
  form.store_select_id = nil
  form.sortClass = nx_widestr(self.Text)
  fresh_form(form)
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.Visible = false
  nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
end
function on_btn_qing_click(btn)
  if nx_string(btn.qin_compose_id) ~= "" then
    nx_execute("custom_sender", "custom_send_compose", nx_string(btn.qin_compose_id), 1, 0)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_tree_job_select_changed(self)
  local form = self.ParentForm
  local node = self.SelectNode
  if nx_find_custom(node, "help_node") and node.help_node then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    node.help_node = false
    form.tree_job.find_info = ""
  end
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "id") then
    return
  end
  if not nx_find_custom(node, "node_item_str") then
    return
  end
  show_info(form, node.id, node.node_item_str)
end
function show_info(form, formula_id, items_str)
  if nx_string(items_str) == "" then
    return
  end
  form.CurFormulaID = items_str
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local lol_msg, qin_ini
  if form.job_id == "sh_qs" or form.job_id == "sh_qg" then
    lol_msg = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
    qin_ini = nx_execute("util_functions", "get_ini", "share\\Life\\Qin.ini")
  elseif form.job_id == "sh_qis" or form.job_id == "sh_gs" then
    lol_msg = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  else
    return
  end
  if not nx_is_valid(lol_msg) then
    return
  end
  local gui = nx_value("gui")
  local job_level = get_job_level(form.job_id)
  form.groupscrollbox_desc.IsEditMode = true
  form.groupscrollbox_desc:DeleteAll()
  local formula_table = util_split_string(items_str, ",")
  local group_top = 0
  for i = 1, table.getn(formula_table) do
    local formula_item_id = formula_table[i]
    local item_id = formula_item_id
    local ini_
    local sec_index = 0
    local item_lvl = ""
    local item_cus = ""
    local item_epid = ""
    local item_DelPoint = 0
    local item_AddPoint = 0
    local need_lvl_flag = "ProfessonLevel"
    local need_ene_flag = "ComposeUseStrenth"
    local need_exp_flag = "ExpPackageID"
    sec_index = lol_msg:FindSectionIndex(nx_string(formula_item_id))
    if sec_index < 0 then
      break
    end
    if form.job_id == "sh_qs" then
      item_id = lol_msg:ReadString(sec_index, "ComposeResult", "")
      item_AddPoint = lol_msg:ReadString(sec_index, "NeedPoint", "")
      if not nx_is_valid(qin_ini) then
        return
      end
      local qin_sec_index = qin_ini:FindSectionIndex(nx_string(formula_item_id))
      item_DelPoint = qin_ini:ReadInteger(qin_sec_index, "NeedPoint", 0)
      ini_ = lol_msg
    elseif form.job_id == "sh_qis" then
      local qipuid = lol_msg:ReadString(sec_index, "QipuID", "")
      formula_item_id = qipuid
      local lifeqipu = nx_execute("util_functions", "get_ini", "share\\Item\\life_qipu.ini")
      if not nx_is_valid(lifeqipu) then
        break
      end
      sec_index = lifeqipu:FindSectionIndex(nx_string(qipuid))
      if sec_index < 0 then
        break
      end
      item_AddPoint = nx_int(lifeqipu:ReadInteger(sec_index, "LifePoint", 0))
      ini_ = lifeqipu
      need_lvl_flag = "NeedLevel"
      need_ene_flag = "NeedEne"
      need_exp_flag = "LifeExpPackage"
    elseif form.job_id == "sh_gs" then
      local gsid = lol_msg:ReadInteger(sec_index, "FortuneTellingID", 0)
      local ini_gs = nx_execute("util_functions", "get_ini", "share\\Life\\fortunetelling.ini")
      if not nx_is_valid(ini_gs) then
        break
      end
      sec_index = ini_gs:FindSectionIndex(nx_string(gsid))
      if sec_index < 0 then
        break
      end
      ini_ = ini_gs
      need_lvl_flag = "Level"
      need_ene_flag = "UseStrenth"
      need_exp_flag = "ExpPackageID"
    elseif form.job_id == "sh_qg" then
      item_id = lol_msg:ReadString(sec_index, "ComposeResult", "")
      ini_ = nx_execute("util_functions", "get_ini", "share\\Life\\BegSkillInfo.ini")
      if not nx_is_valid(ini_) then
        break
      end
      sec_index = ini_:FindSectionIndex(nx_string(formula_item_id))
      if sec_index < 0 then
        break
      end
      need_lvl_flag = "Level"
      need_ene_flag = "UseStrenth"
      need_exp_flag = "ExpPackageID"
      local qg_cus = ini_:ReadInteger(sec_index, "Rank", 0)
      local ini_qg = nx_execute("util_functions", "get_ini", "share\\Life\\BegInfo.ini")
      if not nx_is_valid(ini_qg) then
        break
      end
      item_cus = ini_qg:ReadInteger(qg_cus - 1, need_ene_flag, 0)
      local baginforank = ini_qg:ReadInteger(qg_cus - 1, "Rank", 0)
      if nx_int(baginforank) ~= nx_int(qg_cus) then
        break
      end
    else
      break
    end
    if item_lvl == "" then
      item_lvl = ini_:ReadInteger(sec_index, need_lvl_flag, 0)
    end
    if nx_int(job_level) < nx_int(item_lvl) then
      break
    end
    if item_cus == "" then
      item_cus = ini_:ReadInteger(sec_index, need_ene_flag, 0)
    end
    item_epid = ini_:ReadString(sec_index, need_exp_flag, "")
    local temp_job_id, job_exp = nx_execute("form_stage_main\\form_life\\form_job_composite", "get_exp_from_package", nx_string(item_epid))
    local photo = get_item_info(item_id, "photo")
    local name = gui.TextManager:GetFormatText(nx_string(item_id))
    local str_lvl = gui.TextManager:GetFormatText("ui_sh_qis1", nx_int(item_lvl))
    local str_cus = nx_widestr(gui.TextManager:GetText("ui_sh_xhtl")) .. nx_widestr(item_cus)
    local str_exp = nx_widestr(gui.TextManager:GetText("ui_sh_tssld")) .. nx_widestr(job_exp)
    local groupbox = gui:Create("GroupBox")
    form.groupscrollbox_desc:Add(groupbox)
    groupbox.AutoSize = false
    groupbox.Name = "groupbox_info_" .. nx_string(i)
    groupbox.BackColor = "0,0,0,0"
    groupbox.NoFrame = true
    groupbox.Left = 0
    groupbox.Top = group_top
    groupbox.Width = 405
    groupbox.Height = 90
    local lbl_line = gui:Create("Label")
    groupbox:Add(lbl_line)
    lbl_line.Text = ""
    lbl_line.Left = 0
    lbl_line.Top = 11
    lbl_line.Width = groupbox.Width
    lbl_line.Height = 4
    lbl_line.DrawMode = "Expand"
    lbl_line.BackImage = "gui\\common\\form_line\\line_bg2.png"
    local mult_text = gui:Create("MultiTextBox")
    groupbox:Add(mult_text)
    mult_text.Left = 80
    mult_text.Top = 32
    mult_text.Width = 300
    mult_text.Height = 55
    mult_text.NoFrame = true
    mult_text.ViewRect = "0,0,300,55"
    mult_text.Font = "font_text"
    mult_text.TextColor = "255,95,67,37"
    mult_text.MouseInBarColor = "0,0,0,0"
    if nx_int(item_cus) > nx_int(0) then
      mult_text:AddHtmlText(nx_widestr(str_cus), nx_int(-1))
    end
    if form.job_id == "sh_qs" then
      local str_AddPoint = nx_widestr(gui.TextManager:GetText("ui_sh_qs_hdxd")) .. nx_widestr(0 - item_AddPoint)
      local str_DelPoint = nx_widestr(gui.TextManager:GetText("ui_sh_qs_xhxd")) .. nx_widestr(item_DelPoint)
      mult_text:AddHtmlText(nx_widestr(str_AddPoint), nx_int(-1))
      if item_DelPoint ~= 0 then
        mult_text:AddHtmlText(nx_widestr(str_DelPoint), nx_int(-1))
      end
    end
    if form.job_id == "sh_qis" then
      local str_AddPoint = nx_widestr(gui.TextManager:GetText("ui_sh_hdxd")) .. nx_widestr(0 - item_AddPoint)
      mult_text:AddHtmlText(nx_widestr(str_AddPoint), nx_int(-1))
    end
    local btn = gui:Create("Button")
    groupbox:Add(btn)
    btn.Name = "btn_info_" .. nx_string(i)
    btn.Left = 0
    btn.Top = 13
    btn.Width = groupbox.Width
    btn.Height = 80
    btn.DrawMode = "FitWindow"
    btn.LineColor = "0,0,0,0"
    btn.BackColor = "0,0,0,0"
    btn.FocusImage = "gui\\special\\life\\bg_select.png"
    btn.PushImage = "gui\\special\\life\\bg_select.png"
    btn.qin_compose_id = formula_item_id
    nx_bind_script(btn, nx_current(), "")
    nx_callback(btn, "on_click", "on_btn_info_click")
    if form.job_id == "sh_qs" and is_Learned_formula(formula_item_id) then
      local btn_qing = gui:Create("Button")
      groupbox:Add(btn_qing)
      btn_qing.Name = "btn_qing_" .. nx_string(i)
      btn_qing.Text = gui.TextManager:GetText("@ui_life_skill_form_sh_qs")
      btn_qing.ForeColor = "255,255,255,255"
      btn_qing.Left = 330
      btn_qing.Top = 33
      btn_qing.Width = 60
      btn_qing.Height = 24
      btn_qing.DrawMode = "FitWindow"
      btn_qing.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
      btn_qing.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
      btn_qing.PushImage = "gui\\common\\button\\btn_normal1_down.png"
      btn_qing.qin_compose_id = formula_item_id
      nx_bind_script(btn_qing, nx_current(), "")
      nx_callback(btn_qing, "on_click", "on_btn_qing_click")
      nx_set_custom(form, btn_qing.Name, btn_qing)
    end
    local lbl_bg = gui:Create("Label")
    groupbox:Add(lbl_bg)
    lbl_bg.Text = nx_widestr(name)
    lbl_bg.Left = 110
    lbl_bg.Top = 0
    lbl_bg.Width = 200
    lbl_bg.Height = 27
    lbl_bg.ForeColor = "255,76,61,44"
    lbl_bg.Font = "font_text_title1"
    lbl_bg.Align = "Center"
    lbl_bg.DrawMode = "ExpandH"
    lbl_bg.BackImage = "gui\\special\\life\\bg_title.png"
    local imagegrid = gui:Create("ImageControlGrid")
    groupbox:Add(imagegrid)
    imagegrid.AutoSize = false
    imagegrid.Name = "ImageControlGrid_info_" .. nx_string(i)
    imagegrid.DrawGridBack = "gui\\common\\imagegrid\\icon_item2.png"
    imagegrid.DrawMode = "Expand"
    imagegrid.NoFrame = true
    imagegrid.HasVScroll = false
    imagegrid.Width = 58
    imagegrid.Height = 58
    imagegrid.Left = 15
    imagegrid.Top = 25
    imagegrid.RowNum = 1
    imagegrid.ClomnNum = 1
    imagegrid.GridBackOffsetX = -4
    imagegrid.GridBackOffsetY = -3
    imagegrid.GridWidth = 36
    imagegrid.GridHeight = 36
    imagegrid.GridsPos = "5,10"
    imagegrid.RoundGrid = false
    imagegrid.DrawMouseIn = "xuanzekuang"
    imagegrid.BackColor = "0,0,0,0"
    imagegrid.SelectColor = "0,0,0,0"
    imagegrid.MouseInColor = "0,0,0,0"
    imagegrid.CoverColor = "0,0,0,0"
    nx_bind_script(imagegrid, nx_current(), "")
    nx_callback(imagegrid, "on_mousein_grid", "on_imagegrid_mousein_grid")
    nx_callback(imagegrid, "on_mouseout_grid", "on_imagegrid_mouseout_grid")
    nx_callback(imagegrid, "on_select_changed", "on_imagegrid_select_changed")
    nx_callback(imagegrid, "on_rightclick_grid", "on_imagegrid_rightclick_grid")
    imagegrid.HasMultiTextBox = true
    imagegrid.MultiTextBoxCount = 2
    imagegrid.MultiTextBox1.NoFrame = true
    imagegrid.MultiTextBox1.Width = 345
    imagegrid.MultiTextBox1.Height = 80
    imagegrid.MultiTextBox1.LineHeight = 20
    imagegrid.MultiTextBox1.ViewRect = "0,0,345,80"
    imagegrid.MultiTextBox1.TextColor = "255,95,67,37"
    imagegrid.MultiTextBoxPos = "75,0"
    imagegrid.ViewRect = "0,0,67,67"
    imagegrid:AddItem(0, photo, "", 1, -1)
    imagegrid:SetItemAddInfo(nx_int(0), nx_int(1), nx_widestr(item_id))
    imagegrid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(formula_item_id))
    nx_set_custom(form, imagegrid.Name, imagegrid)
    if form.job_id == "sh_qs" or form.job_id == "sh_qg" then
      if is_Learned_formula(formula_item_id) == false then
        imagegrid:ChangeItemImageToBW(nx_int(0), true)
      else
        imagegrid:ChangeItemImageToBW(nx_int(0), false)
      end
    elseif form.job_id == "sh_qis" then
      if is_Learned_qipu(formula_item_id) == false then
        imagegrid:ChangeItemImageToBW(nx_int(0), true)
      else
        imagegrid:ChangeItemImageToBW(nx_int(0), false)
      end
    elseif form.job_id == "sh_gs" then
      imagegrid:ChangeItemImageToBW(nx_int(0), false)
    else
      imagegrid:ChangeItemImageToBW(nx_int(0), true)
    end
    group_top = group_top + 90
  end
  form.groupscrollbox_desc:ResetChildrenYPos()
  form.groupscrollbox_desc.IsEditMode = false
end
function on_imagegrid_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(index, nx_int(1)))
  if item_config == "" then
    return
  end
  local item_name = get_item_info(item_config, "Name")
  local item_type = get_item_info(item_config, "ItemType")
  local item_sellPrice1 = get_item_info(item_config, "sellPrice1")
  local photo = get_item_info(item_config, "Photo")
  local prop_array = {}
  prop_array.ConfigID = nx_string(item_config)
  prop_array.ItemType = nx_int(item_type)
  prop_array.SellPrice1 = nx_int(item_sellPrice1)
  prop_array.Photo = nx_string(photo)
  if not nx_is_valid(grid.Data) then
    grid.Data = nx_create("ArrayList", nx_current())
  end
  grid.Data:ClearChild()
  for prop, value in pairs(prop_array) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_select_changed(grid, index)
  local formula_ini = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  if not nx_is_valid(formula_ini) then
    return
  end
  local form = grid.ParentForm
  local job_id = form.job_id
  local formula_item_id = nx_string(grid:GetItemAddText(index, nx_int(2)))
  local sec_index = formula_ini:FindSectionIndex(nx_string(formula_item_id))
  if sec_index < 0 then
    nx_log("share\\Item\\life_formula.ini sec_index= " .. nx_string(formula_item_id))
    return
  end
  local item_id = formula_ini:ReadString(sec_index, "ComposeResult", "")
  if not is_Learned_formula(formula_item_id) then
    return
  end
  local gui = nx_value("gui")
  local func_manager = nx_value("func_manager")
  if nx_is_valid(func_manager) then
    local photo = get_item_info(item_id, "photo")
    if not nx_is_valid(gui) then
      return
    end
    if gui.GameHand:IsEmpty() then
      if nx_string(job_id) == "sh_qs" then
        gui.GameHand:SetHand(GHT_QIN, photo, "qin", formula_item_id, "", "")
      elseif nx_string(job_id) == "sh_qg" then
        gui.GameHand:SetHand(GHT_BEG, photo, "beg", formula_item_id, "", "")
      end
    else
      gui.GameHand:ClearHand()
    end
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_imagegrid_rightclick_grid(grid, index)
  local formula_item_id = nx_string(grid:GetItemAddText(index, nx_int(2)))
  if nx_string(formula_item_id) == "" then
    return
  end
  if not is_Learned_formula(formula_item_id) then
    return
  end
  local form = grid.ParentForm
  local job_id = form.job_id
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
  if nx_string(job_id) == "sh_qs" then
    nx_execute("custom_sender", "custom_doqin", formula_item_id)
  elseif nx_string(job_id) == "sh_qg" then
    nx_execute("form_stage_main\\form_life\\form_job_qishi", "life_skill_beg", formula_item_id)
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(select_btn) then
    select_btn.NormalImage = ""
  end
  select_btn = btn
  btn.NormalImage = "gui\\special\\life\\bg_select.png"
end
function get_job_level(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("job_rec", row, 1)
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
function is_nothing_qipu_learned(qipuitem_str)
  local qipuitem_list = util_split_string(nx_string(qipuitem_str), ",")
  for i = 1, table.getn(qipuitem_list) do
    local qipuitem_id = qipuitem_list[i]
    local qipu_id = get_item_info(qipuitem_id, "QipuID")
    if nx_string(qipu_id) ~= "" and is_Learned_qipu(qipu_id) then
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
function find_life_job(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if 0 <= client_player:FindRecordRow("job_rec", 0, job_id, 0) then
    return true
  end
  return false
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
function open_form_job(job_id)
end
function life_skill_beg(para)
  if not is_Learned_formula(para) then
    return
  end
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
function find_grid_item(grid, find_config_id)
  local row_num = grid.RowNum
  local clomn_num = grid.ClomnNum
  local clomn_num = grid.ClomnNum
  local size = clomn_num * row_num
  for i = 1, size do
    local item_config = nx_string(grid:GetItemAddText(i - 1, nx_int(1)))
    if item_config == find_config_id then
      return i - 1
    end
  end
  return -1
end
function find_tree_item(tree, find_info)
  local root_node = tree.RootNode
  if not nx_is_valid(root_node) then
    return nil
  end
  tree.find_info = find_info
  return find_node(root_node, find_info)
end
function find_node(root_node, find_info)
  local node_list = root_node:GetNodeList()
  for i, node in ipairs(node_list) do
    if nx_find_custom(node, "node_item_str") and get_skill_node(node.node_item_str, find_info) then
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
function get_skill_node(node_item_str, find_skill_id)
  local node_item_str_table = util_split_string(node_item_str, ",")
  for i, skill_id in ipairs(node_item_str_table) do
    if skill_id == find_skill_id then
      return true
    end
  end
  return false
end
