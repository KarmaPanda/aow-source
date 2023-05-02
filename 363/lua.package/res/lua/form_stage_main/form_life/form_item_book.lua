require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\view_define")
local m_Path = "form_stage_main\\form_life\\form_item_book"
local m_School = {
  "jh",
  "sl",
  "wd",
  "em",
  "jz",
  "jy",
  "gb",
  "jl",
  "tm",
  "mj",
  "ts"
}
local m_Job = {"sh_ss", "sh_hs"}
local m_SelectNode
function main_form_init(form)
  form.Fixed = false
  form.job_id = "sh_ss"
  form.curid = 0
  form.curformulaid = ""
  form.material = ""
  form.material_bind = 0
  form.select_type = 1
  form.nodeid = 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_TOOL, form, m_Path, "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_JOB_COMPOUND, form.ImageControlGrid, m_Path, "on_compound_box_change")
    databinder:AddViewBind(VIEWPORT_JOB_SKILLPAGE, form.ImageControlGrid_hs, m_Path, "on_skillpage_hs_box_change")
    databinder:AddViewBind(VIEWPORT_SPLIT_BOOK, form.imagegrid_cs, m_Path, "on_split_book_box_change")
  end
  form.ImageControlGrid.typeid = VIEWPORT_JOB_COMPOUND
  form.ImageControlGrid_hs.typeid = VIEWPORT_JOB_SKILLPAGE
  for i = 1, 10 do
    form.ImageControlGrid:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  for i = 1, 20 do
    form.ImageControlGrid_hs:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  for i = 1, 20 do
    form.imagegrid_cs:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  form.material_bind = 0
  form.ipt_num.Text = nx_widestr("1")
  form_refresh(form)
  form.rbtn_hs.Checked = true
  on_rbtn_click(form.rbtn_hs)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form.ImageControlGrid)
  end
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
  nx_execute("custom_sender", "custom_cancel_compound", CLIENT_CUSTOMMSG_COMPOUND)
  nx_execute("custom_sender", "custom_cancel_compound", CLIENT_CUSTOMMSG_SKILLPAGE)
  nx_execute("custom_sender", "custom_cancel_split_book")
end
function on_fuse_form_open(job_id)
  local form = util_get_form(m_Path, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if false == check_param(m_Job, job_id) then
    return
  end
  form.job_id = job_id
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  form.ipt_in.Text = nx_widestr(Text_ss)
  util_auto_show_hide_form(m_Path)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_rbtn_click(btn)
  local form = btn.ParentForm
  form.select_type = btn.TabIndex
  local gui = nx_value("gui")
  local str = ""
  closeallform(form)
  if 1 == btn.TabIndex then
    form.groupbox_zd.Visible = true
    str = "ui_fuse_bind"
    form.nodeid = 1
    form_refresh(form)
  elseif 2 == btn.TabIndex then
    form.groupbox_zd.Visible = true
    str = "ui_fuse_tidy"
    form.nodeid = 2
    form_refresh(form)
  elseif 3 == btn.TabIndex then
    form.groupbox_td.Visible = true
    str = "ui_fuse_infer"
  elseif 4 == btn.TabIndex then
    form.groupbox_hs.Visible = true
    str = "ui_fuse_combbook"
  elseif 5 == btn.TabIndex then
    form.groupbox_cs.Visible = true
    str = "ui_fuse_takebook"
  end
  str = gui.TextManager:GetText(str)
  form.btn_fuse.Text = nx_widestr(str)
  on_ipt_in_changed(form.ipt_in)
end
function closeallform(form)
  form.groupbox_td.Visible = false
  form.groupbox_zd.Visible = false
  form.groupbox_hs.Visible = false
  form.groupbox_cs.Visible = false
end
function form_refresh(form)
  clear_message(form)
  form_init(form)
  refresh_tree_list_fuse(form)
  refresh_node_info(form)
end
function form_init(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local name_fuse = gui.TextManager:GetFormatText("ui_ronghe1")
  local root = form.tree_fuse:CreateRootNode(nx_widestr(name_fuse))
  for i = 1, table.getn(m_School) do
    local name_school = gui.TextManager:GetFormatText("ui_fuse_" .. nx_string(m_School[i]))
    local node = root:CreateNode(nx_widestr(name_school))
    node.school = nx_string(m_School[i])
    node.name = nx_string(name_school)
    node.Font = "font_treeview"
    node.ForeColor = "255,255,180,40"
    node.ExpandCloseOffsetX = 3
    node.ExpandCloseOffsetY = 5
    node.TextOffsetX = 10
    node.TextOffsetY = 7
    node.NodeBackImage = "gui\\common\\treeview\\tree_1_out.png"
    node.NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png"
    node.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
    node.ItemHeight = 30
    node.DrawMode = "Expand"
  end
  root:ExpandAll()
end
function refresh_tree_list_fuse(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local formula_list = get_wx_formula(game_client, form.job_id, form.nodeid)
  if nil == formula_list then
    return
  end
  local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_wx.ini")
  for _, formula in ipairs(formula_list) do
    local index = fuse_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local fuse_name = fuse_ini:ReadString(index, "ComposeResult", "")
      local fuse_material = fuse_ini:ReadString(index, "Material", "")
      local fuse_job = fuse_ini:ReadString(index, "Profession", "")
      local fuse_money = fuse_ini:ReadString(index, "Money", "")
      local fuse_school = fuse_ini:ReadString(index, "School", "")
      if check_param(m_School, fuse_school) and check_param(m_Job, fuse_job) and fuse_name ~= "" and fuse_material ~= "" then
        local father_node = get_node_by_shcool(form, fuse_school)
        if nil ~= father_node then
          local node_name = gui.TextManager:GetFormatText(fuse_name)
          local node_id = fuse_ini:GetSectionByIndex(index)
          local canfuse_num = nx_string(get_canfuse_num(fuse_material))
          if nx_int(canfuse_num) == nx_int(0) then
            canfuse_num = ""
          else
            canfuse_num = " (" .. canfuse_num .. ")"
          end
          local name = nx_widestr(node_name) .. nx_widestr(canfuse_num)
          local sub_node = father_node:CreateNode(nx_widestr(name))
          sub_node.ItemHeight = 20
          sub_node.TextOffsetX = 25
          sub_node.TextOffsetY = 2
          sub_node.Font = "font_treeview"
          sub_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
          sub_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png"
          sub_node.NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png"
          sub_node.name = name
          sub_node.id = node_id
          sub_node.fuse_name = fuse_name
          sub_node.fuse_material = fuse_material
          sub_node.fuse_money = fuse_money
          if nx_is_valid(sub_node) and not nx_is_valid(m_SelectNode) then
            m_SelectNode = sub_node
          end
          if nx_is_valid(sub_node) and node_id == form.curid then
            m_SelectNode = sub_node
          end
        end
      end
    end
  end
  if nx_is_valid(m_SelectNode) then
    form.tree_fuse.SelectNode = m_SelectNode
  end
  form.tree_fuse.RootNode:ExpandAll()
end
function check_param(table_name, param)
  for i = 1, table.getn(table_name) do
    if nx_string(table_name[i]) == nx_string(param) then
      return true
    end
  end
  return false
end
function get_node_by_shcool(form, school)
  local tree = form.tree_fuse
  local node_list = tree:GetAllNodeList()
  for i = 1, table.getn(node_list) do
    local node = node_list[i]
    if nx_find_custom(node, "school") and nx_string(node.school) == nx_string(school) then
      return node
    end
  end
  return nil
end
function on_tree_fuse_select_changed(tree)
  local form = tree.ParentForm
  m_SelectNode = tree.SelectNode
  local node = tree.SelectNode
  if nx_find_custom(node, "id") then
    tree.ParentForm.curid = tree.SelectNode.id
  end
  if nx_find_custom(node, "fuse_name") then
    form.curformulaid = node.fuse_name
    form.material = node.fuse_material
  end
  refresh_node_info(form)
end
function refresh_node_info(form)
  clear_old_message(form)
  local node = form.tree_fuse.SelectNode
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "fuse_material") then
    return
  end
  if not nx_find_custom(node, "fuse_name") then
    return
  end
  if not nx_find_custom(node, "fuse_money") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local htmlTextYinZi = nx_execute("form_stage_main\\form_life\\form_job_composite", "format_prize_money", node.fuse_money)
  if node.fuse_money == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  form.lbl_price.Text = nx_widestr(htmlTextYinZi)
  local str_lst = util_split_string(node.fuse_material, ";")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local fuse_name = nx_string(node.fuse_name)
  local photo = ItemQuery:GetItemPropByConfigID(fuse_name, "Photo")
  form.imagegrid_fuseitem:AddItem(nx_int(0), photo, "", 0, -1)
  form.imagegrid_fuseitem:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(fuse_name))
  for i = 1, table.getn(str_lst) do
    if 4 < i then
      return
    end
    local GridName = "ImageControlGrid" .. i
    local ImageGrid = form.groupbox_fuse:Find(GridName)
    local str_temp = util_split_string(str_lst[i], ",")
    local item_id = nx_string(str_temp[1])
    local need_num = nx_int(str_temp[2])
    local have_num = get_item_num(item_id)
    local temp_bind = get_item_bind(item_id)
    form.material_bind = temp_bind
    local bExist = ItemQuery:FindItemByConfigID(item_id)
    local node_name = gui.TextManager:GetFormatText(item_id)
    if bExist then
      local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      if nx_number(have_num) >= nx_number(need_num) then
        ImageGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      else
        ImageGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
      end
    end
    ImageGrid:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(item_id))
  end
end
function on_btn_fuse_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if 1 == form.select_type or 2 == form.select_type then
    if nx_find_custom(form, "curid") then
      local formula_id = form.curid
      local fuse_num = form.ipt_num.Text
      local max_num = get_canfuse_num(form.material)
      local str_lst = util_split_string(form.material, ",")
      local item_config = str_lst[1]
      local item_num = get_item_num(item_config)
      if nx_number(fuse_num) > nx_number(max_num) then
        form.ipt_num.Text = nx_widestr(max_num)
      end
      fuse_num = form.ipt_num.Text
      if 1 == form.select_type then
        if nx_int(item_num) > nx_int(0) then
          local gui = nx_value("gui")
          local dialog = util_get_form("form_common\\form_confirm", true, false)
          if not nx_is_valid(dialog) then
            return
          end
          gui.TextManager:Format_SetIDName("ui_jhnghc_fc_001")
          if nx_int(form.material_bind) == nx_int(1) then
            gui.TextManager:Format_AddParam(nx_string(gui.TextManager:GetText("ui_jhnghc_fc_002")))
          else
            gui.TextManager:Format_AddParam(nx_string(gui.TextManager:GetText("ui_jhnghc_fc_003")))
          end
          dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
          dialog.relogin_btn.Visible = false
          dialog:ShowModal()
          local res = nx_wait_event(100000000, dialog, "confirm_return")
          if res == "ok" then
            nx_execute("custom_sender", "custom_send_fuse", nx_string(formula_id), nx_int(fuse_num), 0, 2)
          end
        end
      else
        nx_execute("custom_sender", "custom_send_fuse", nx_string(formula_id), nx_int(fuse_num), 0, 2)
      end
      form_refresh(form)
    end
  elseif 3 == form.select_type then
    nx_execute("custom_sender", "custom_start_compound", CLIENT_CUSTOMMSG_COMPOUND)
  elseif 4 == form.select_type then
    nx_execute("custom_sender", "custom_start_compound", CLIENT_CUSTOMMSG_SKILLPAGE)
  elseif 5 == form.select_type then
    nx_execute("custom_sender", "custom_start_split_book")
  end
end
function get_item_num(item_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    viewobj_list = tool:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return nx_int(cur_amount)
end
function get_item_bind(item_id)
  local bind_status = 0
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local viewobj_list = view:GetViewObjList()
  for j, obj in pairs(viewobj_list) do
    local tempid = obj:QueryProp("ConfigID")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      local temp_status = obj:QueryProp("BindStatus")
      if nx_int(temp_status) > nx_int(0) then
        bind_status = temp_status
      end
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    viewobj_list = tool:GetViewObjList()
    for j, obj in pairs(viewobj_list) do
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) then
        local temp_status = obj:QueryProp("BindStatus")
        if nx_int(temp_status) > nx_int(0) then
          bind_status = temp_status
        end
      end
    end
  end
  return bind_status
end
function on_imagegrid_fuse_mousein_grid(grid, index)
  local item_config = nx_string(grid:GetItemAddText(nx_int(index), nx_int(2)))
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
function on_ipt_in_changed(edit)
  local str = nx_string(edit.Text)
  if nx_string("") == str then
    return
  end
  local gui = nx_value("gui")
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  if nx_string(Text_ss) == str then
    return
  end
  local form = edit.ParentForm
  local tree = form.tree_fuse
  local node_list = tree:GetAllNodeList()
  for i = 1, table.getn(node_list) do
    local node = node_list[i]
    if nx_find_custom(node, "name") and nil ~= string.find(nx_string(node.name), nx_string(str)) then
      tree.SelectNode = node
    end
  end
end
function on_ipt_num_changed(edit)
  local value = nx_int(edit.Text)
  if value > nx_int(edit.MaxDigit) then
    edit.Text = nx_widestr(edit.MaxDigit)
  elseif value < nx_int(0) then
    edit.Text = nx_widestr("0")
  end
end
function on_toolbox_viewport_change(form, optype)
  if optype ~= "additem" and optype ~= "delitem" and optype ~= "updateitem" then
    return
  end
  if optype == "delitem" then
    local iNumber = nx_int(form.ipt_num.Text)
    if iNumber > nx_int(0) then
      form.ipt_num.Text = nx_widestr(iNumber - 1)
    else
      form.ipt_num.Text = nx_widestr(0)
    end
  end
  form_refresh(form)
end
function get_canfuse_num(Materials)
  if Materials == "" then
    return 0
  end
  local game_client = nx_value("game_client")
  local str_lst = util_split_string(Materials, ";")
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
      local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
      local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
      if nx_is_valid(view) then
        local viewobj_list = view:GetViewObjList()
        local toolobj_list = tool:GetViewObjList()
        local total = 0
        local Material_total = 0
        local Tool_total = 0
        for i, obj in pairs(viewobj_list) do
          local tempid = obj:QueryProp("ConfigID")
          if tempid == item then
            flag = true
            local cur_amount = obj:QueryProp("Amount")
            Material_total = Material_total + cur_amount
          end
        end
        for i, obj in pairs(toolobj_list) do
          local tempid = obj:QueryProp("ConfigID")
          if tempid == item then
            flag = true
            local cur_amount = obj:QueryProp("Amount")
            Tool_total = Tool_total + cur_amount
          end
        end
        local Material_total = nx_int(Material_total / nx_int(num))
        local Tool_total = nx_int(Tool_total / nx_int(num))
        local temp_min_num = 0
        if Material_total > Tool_total then
          temp_min_num = Material_total
        else
          temp_min_num = Tool_total
        end
        if nx_int(temp_min_num) < nx_int(min_num) then
          min_num = temp_min_num
        end
      end
    end
  else
    flag = true
    min_num = 1
  end
  if flag == false then
    min_num = 0
  end
  return min_num
end
function clear_old_message(form)
  for i = 1, 4 do
    local GirdName = "ImageControlGrid" .. i
    local ImageGird = form.groupbox_fuse:Find(GirdName)
    ImageGird:Clear()
  end
  form.imagegrid_fuseitem:Clear()
  form.lbl_price.Text = nx_widestr("")
end
function clear_message(form)
  form.tree_fuse:CreateRootNode(nx_widestr(""))
  clear_old_message(form)
end
function get_wx_formula(game_client, job_id, nodeid)
  local game_client = nx_value("game_client")
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(game_client) or not nx_is_valid(fuse_formula_query) then
    return nil
  end
  local formula_list = {}
  local formula_set = {}
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return nil
  end
  local tool_list = tool:GetViewObjList()
  for _, obj in ipairs(tool_list) do
    local id = obj:QueryProp("ConfigID")
    if id then
      local wx_formula = fuse_formula_query:GetWxFormulas(id, job_id, nodeid)
      for i, item in ipairs(wx_formula) do
        if formula_set[item] == nil then
          table.insert(formula_list, item)
          formula_set[item] = true
        end
      end
    end
  end
  return formula_list
end
function on_compound_box_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "updateitem" or optype == "delitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function ShowItem(form, view, viewobj, index)
  if not nx_is_valid(viewobj) then
    form.ImageControlGrid:DelItem(index - 1)
    form.lbl_price_td.Text = ""
    return
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
  form.ImageControlGrid:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.lbl_price_td.Text = ""
  if not nx_is_valid(view) then
    return
  end
  local itemFirst = view:GetViewObj(nx_string(1))
  local itemSecond = view:GetViewObj(nx_string(2))
  if not nx_is_valid(itemFirst) or not nx_is_valid(itemSecond) then
    return
  end
  if itemFirst:QueryProp("ConfigID") == itemSecond:QueryProp("ConfigID") then
    local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_book.ini")
    local sec_index = fuse_ini:FindSectionIndex(itemFirst:QueryProp("ConfigID"))
    local Money = 0
    if 0 <= sec_index then
      Money = fuse_ini:ReadString(sec_index, "Money", "")
    end
    local htmlTextYinZi = ""
    if nx_int(0) >= nx_int(Money) then
      htmlTextYinZi = "0"
    else
      htmlTextYinZi = nx_execute("form_stage_main\\form_life\\form_job_composite", "format_prize_money", Money)
    end
    form.lbl_price_td.Text = nx_widestr(htmlTextYinZi)
  end
end
function on_imagegrid_compound_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_COMPOUND))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_compound_item", CLIENT_CUSTOMMSG_COMPOUND, index + 1)
  end
end
function on_imagegrid_compound_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_add_compound_item", CLIENT_CUSTOMMSG_COMPOUND, src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_compound_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_COMPOUND))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_imagegrid_compound_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageControlGrid_hs_rightclick_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SKILLPAGE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_compound_item", CLIENT_CUSTOMMSG_SKILLPAGE, index + 1)
  end
end
function on_ImageControlGrid_hs_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_add_compound_item", CLIENT_CUSTOMMSG_SKILLPAGE, src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_ImageControlGrid_hs_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JOB_SKILLPAGE))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_ImageControlGrid_hs_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_skillpage_hs_box_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "updateitem" or optype == "delitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem_hs(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function on_split_book_box_change(grid, optype, view_ident, index)
  if not nx_is_valid(grid) then
    return 1
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local form = grid.ParentForm
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  if optype == "createview" then
    GoodsGrid:GridClear(grid)
    GoodsGrid:ViewUpdateItem(grid, index)
  elseif optype == "deleteview" then
    GoodsGrid:GridClear(grid)
  elseif optype == "additem" or optype == "updateitem" or optype == "delitem" then
    local viewobj = view:GetViewObj(nx_string(index))
    ShowItem_cs(form, view, viewobj, index)
  end
  local form_bag = nx_value("form_stage_main\\form_bag")
  if nx_is_valid(form_bag) then
    nx_execute("form_stage_main\\form_bag", "refresh_lock_item", form_bag)
  end
  return 1
end
function ShowItem_cs(form, view, viewobj, index)
  if not nx_is_valid(viewobj) then
    form.imagegrid_cs:DelItem(index - 1)
    form.lbl_price_td.Text = ""
    return
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
  form.imagegrid_cs:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.lbl_price_td.Text = ""
end
function ShowItem_hs(form, view, viewobj, index)
  if not nx_is_valid(viewobj) then
    form.ImageControlGrid_hs:DelItem(index - 1)
    form.lbl_price_td.Text = ""
    return
  end
  local photo = nx_execute("util_static_data", "queryprop_by_object", viewobj, "Photo")
  form.ImageControlGrid_hs:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  form.lbl_price_td.Text = ""
end
function on_imagegrid_cs_right_click(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SPLIT_BOOK))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    nx_execute("custom_sender", "custom_remove_split_book", index + 1)
  end
end
function on_imagegrid_cs_select_changed(grid)
  local gui = nx_value("gui")
  local selected_index = grid:GetSelectItemIndex()
  if gui.GameHand:IsEmpty() then
    return
  end
  if not grid:IsEmpty(selected_index) then
    return
  end
  if gui.GameHand.Type == GHT_VIEWITEM then
    local src_viewid = nx_int(gui.GameHand.Para1)
    local src_pos = nx_int(gui.GameHand.Para2)
    local amount = nx_int(gui.GameHand.Para3)
    nx_execute("custom_sender", "custom_add_split_book", src_viewid, src_pos, selected_index + 1)
    gui.GameHand:ClearHand()
  end
end
function on_imagegrid_cs_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SPLIT_BOOK))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if nx_is_valid(viewobj) then
    viewobj.view_obj = viewobj
    nx_execute("tips_game", "show_goods_tip", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_imagegrid_cs_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
