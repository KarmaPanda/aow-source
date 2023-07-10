require("util_functions")
require("define\\gamehand_type")
require("util_gui")
require("share\\itemtype_define")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
require("custom_sender")
require("share\\view_define")
local sortString = ""
local SelectNode = ""
local Fuse_OnlyUseBindType = 0
local Fuse_OnlyUseUnbindType = 1
local Fuse_UseAllType = 2
function main_form_init(form)
  form.Fixed = false
  form.BindType = Fuse_UseAllType
  form.job_id = "sizebody"
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2 - 40
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, form, "form_stage_main\\form_life\\form_item_fuse_bianshen", "on_toolbox_viewport_change")
    databinder:AddViewBind(VIEWPORT_TOOL, form, "form_stage_main\\form_life\\form_item_fuse_bianshen", "on_toolbox_viewport_change")
  end
  form.rbtn_bangding.Checked = true
  form.cbtn_bdgx.Checked = true
  form.BindType = Fuse_UseAllType
  refresh_tree_list_fuse(form)
  refresh_node_info(form)
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_destroy(form)
  local form_talk = nx_value("form_stage_main\\form_talk_movie")
  if nx_is_valid(form_talk) then
    form_talk:Close()
  end
end
function on_fuse_form_open(job_id)
  local form = util_get_form("form_stage_main\\form_life\\form_item_fuse_bianshen", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.job_id = job_id
  local Text_ss = gui.TextManager:GetText("ui_sh_ss")
  form.ipt_in.Text = nx_widestr(Text_ss)
  util_auto_show_hide_form("form_stage_main\\form_life\\form_item_fuse_bianshen")
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function refresh_tree_list_fuse(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.tree_fuse.SelectNode = SelectNode
  name_ronghe = gui.TextManager:GetFormatText("ui_ronghe1")
  if nx_string(form.job_id) == nx_string("sizebody") then
    form.lbl_tile.Text = gui.TextManager:GetFormatText("ui_fuse_bianshen_01")
    name_ronghe = gui.TextManager:GetFormatText("ui_fuse_bianshen_02")
    form.lbl_cailiao.Text = gui.TextManager:GetFormatText("ui_fuse_bianshen_03")
    form.btn_fuse.Text = gui.TextManager:GetFormatText("ui_fuse_bianshen_04")
    form.btn_cancel.Text = gui.TextManager:GetFormatText("ui_fuse_bianshen_05")
  end
  form.tree_fuse.LevelWidth = 25
  local fuse_root_node = form.tree_fuse:CreateRootNode(nx_widestr(name_ronghe))
  local job_id = nx_string(form.job_id)
  local fuse_root = fuse_root_node:CreateNode(nx_widestr(name_ronghe))
  fuse_root.ExpandCloseOffsetX = 3
  fuse_root.ExpandCloseOffsetY = 2
  fuse_root.TextOffsetX = 25
  fuse_root.TextOffsetY = 5
  fuse_root.ItemHeight = 30
  fuse_root.NodeFocusImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeCoverImage = "gui\\common\\treeview\\tree_1_out.png"
  fuse_root.NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png"
  fuse_root.Font = "font_playername"
  fuse_root.ForeColor = "255,255,255,255"
  formula_list = get_formula(job_id)
  if formula_list == nil then
    return
  end
  config_sub_node(form, gui, fuse_root, formula_list, "share\\Item\\fuse_formula.ini")
  fuse_root_node:ExpandAll()
end
function on_tree_fuse_select_changed(tree)
  local form = tree.ParentForm
  SelectNode = tree.SelectNode
  local node = tree.SelectNode
  if nx_find_custom(node, "id") then
    tree.ParentForm.CurID = tree.SelectNode.id
    if nx_int(get_canfuse_num(node.id, form.job_id, form.BindType)) == nx_int(0) then
      form.btn_fuse.Visible = false
      form.btn_cancel.Visible = false
    else
      form.btn_fuse.Visible = true
      form.btn_cancel.Visible = false
    end
  else
    form.btn_fuse.Visible = false
  end
  if nx_find_custom(node, "formula_id") then
    form.CurFormulaID = node.formula_id
  end
  refresh_node_info(form)
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
  form.lbl_price1.HtmlText = nx_widestr("")
  form.lbl_price2.HtmlText = nx_widestr("")
  local sy = "<img src=\"gui\\common\\money\\suiyin.png\" valign=\"top\" only=\"line\" data=\"\" />"
  form.lbl_price1.HtmlText = nx_widestr(sy) .. nx_widestr(price_to_text(form, gui, node.price))
  if node.price_zy ~= "" and node.price_zy ~= 0 then
    local yyb = "<img src=\"gui\\common\\money\\yyb.png\" valign=\"center\" only=\"line\" data=\"\" />"
    form.lbl_price2.HtmlText = nx_widestr(yyb) .. nx_widestr(price_to_text(form, gui, node.price_zy))
  end
  local str_lst = util_split_string(node.Material, ";")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  local job_id = nx_string(form.job_id)
  clear_backImage(form)
  local Dorp_item = nx_string(node.formula_id)
  local photo = ItemQuery:GetItemPropByConfigID(Dorp_item, "Photo")
  form.imagegrid_fuseitem:AddItem(nx_int(0), photo, "", 0, -1)
  form.imagegrid_fuseitem:SetItemAddInfo(nx_int(0), nx_int(2), nx_widestr(Dorp_item))
  for i = 1, table.getn(str_lst) do
    if 8 < i then
      return
    end
    local GridName = "ImageControlGrid" .. i
    local ImageGrid = form.groupbox_fuse:Find(GridName)
    local sec_index = fuse_ini:FindSectionIndex(nx_string(i))
    local fuse_type = ""
    if 0 <= sec_index then
      fuse_type = fuse_ini:ReadString(sec_index, "Profession", "")
    end
    local str_temp = util_split_string(str_lst[i], ",")
    local item_id = nx_string(str_temp[1])
    local need_num = nx_int(str_temp[2])
    local have_num = get_item_num(item_id, form.BindType)
    local bExist = ItemQuery:FindItemByConfigID(item_id)
    local node_name = gui.TextManager:GetFormatText(item_id)
    if bExist then
      local photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
      if nx_number(have_num) >= nx_number(need_num) then
        ImageGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#00ff00\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        ImageGrid:ChangeItemImageToBW(0, false)
      else
        ImageGrid:AddItem(nx_int(0), photo, nx_widestr("<font color=\"#ff0000\">" .. nx_string(have_num) .. "/" .. nx_string(need_num) .. "</font>"), 0, -1)
        ImageGrid:ChangeItemImageToBW(0, true)
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
  if nx_find_custom(form, "CurID") then
    local formula_id = form.CurID
    local fuse_num = form.ipt_num.Text
    local max_num = get_canfuse_num(formula_id, form.job_id, form.BindType)
    if nx_number(fuse_num) > nx_number(max_num) then
      form.ipt_num.Text = nx_widestr(max_num)
    end
    nx_execute("custom_sender", "custom_send_fuse", nx_string(formula_id), nx_int(fuse_num), 0, form.BindType)
  end
end
function on_btn_cancel_click(btn)
  nx_execute("custom_sender", "custom_cancel_fuse")
end
function on_rbtn_bangding_checked_changed(btn)
  if btn.Checked == false then
    return
  end
  local form = btn.ParentForm
  form.groupbox_select.Visible = true
  if form.cbtn_bdgx.Checked then
    form.BindType = Fuse_UseAllType
  else
    form.BindType = Fuse_OnlyUseBindType
  end
  refresh_tree_list_fuse(form)
  refresh_node_info(form)
end
function on_rbtn_feibangding_checked_changed(btn)
  if btn.Checked == false then
    return
  end
  local form = btn.ParentForm
  form.groupbox_select.Visible = false
  form.BindType = Fuse_OnlyUseUnbindType
  refresh_tree_list_fuse(form)
  refresh_node_info(form)
end
function on_cbtn_bdgx_click(btn)
  if btn.ParentForm.cbtn_bdgx.Checked then
    btn.ParentForm.BindType = Fuse_UseAllType
  else
    btn.ParentForm.BindType = Fuse_OnlyUseBindType
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  refresh_tree_list_fuse(btn.ParentForm)
  refresh_node_info(btn.ParentForm)
end
function get_item_num(item_id, bind_type)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return nx_int(0)
  end
  local cur_amount = nx_int(0)
  local count = view:GetViewObjCount()
  for j = 1, count do
    local obj = view:GetViewObjByIndex(j - 1)
    local tempid = obj:QueryProp("ConfigID")
    local bind_status = obj:QueryProp("BindStatus")
    if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) and (bind_type == Fuse_OnlyUseBindType and bind_status == 1 or bind_type == Fuse_OnlyUseUnbindType and bind_status == 0 or bind_type == Fuse_UseAllType) then
      cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
    end
  end
  if nx_int(cur_amount) == nx_int(0) then
    local count = tool:GetViewObjCount()
    for j = 1, count do
      local obj = tool:GetViewObjByIndex(j - 1)
      local tempid = obj:QueryProp("ConfigID")
      if nx_ws_equal(nx_widestr(tempid), nx_widestr(item_id)) and (bind_type == Fuse_OnlyUseBindType and bind_status == 1 or bind_type == Fuse_OnlyUseUnbindType and bind_status == 0 or bind_type == Fuse_UseAllType) then
        cur_amount = nx_int(cur_amount) + nx_int(obj:QueryProp("Amount"))
      end
    end
  end
  return nx_int(cur_amount)
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
function on_ipt_in_changed(edit)
  local gui = nx_value("gui")
  if gui.TextManager:GetText("ui_sh_ss") == edit.Text then
    sortString = ""
  else
    sortString = nx_string(edit.Text)
  end
  local form = edit.ParentForm
  refresh_tree_list_fuse(form)
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
  if optype == "updateitem" or optype == "additem" or optype == "delitem" then
    refresh_tree_list_fuse(form)
    refresh_node_info(form)
  end
end
function get_canfuse_num(node_id, job_id, bind_type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local iniformula
  if job_id == "sh_ss" or job_id == "sh_hs" then
    iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_wx.ini")
  else
    iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  end
  local sec_index = iniformula:FindSectionIndex(nx_string(node_id))
  if sec_index < 0 then
    return 0
  end
  local needitem = iniformula:ReadString(sec_index, "Material", "")
  if needitem == "" then
    return 0
  end
  local view = game_client:GetView(nx_string(VIEWPORT_MATERIAL_TOOL))
  if not nx_is_valid(view) then
    return 0
  end
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return 0
  end
  local viewobj_count = view:GetViewObjCount()
  local toolobj_count = tool:GetViewObjCount()
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
      local total = 0
      local Material_total = 0
      local Tool_total = 0
      for i = 1, viewobj_count do
        local obj = view:GetViewObjByIndex(i - 1)
        local tempid = obj:QueryProp("ConfigID")
        local bind_status = obj:QueryProp("BindStatus")
        if tempid == item and (bind_type == Fuse_OnlyUseBindType and bind_status == 1 or bind_type == Fuse_OnlyUseUnbindType and bind_status == 0 or bind_type == Fuse_UseAllType) then
          flag = true
          local cur_amount = obj:QueryProp("Amount")
          Material_total = Material_total + cur_amount
        end
      end
      for i = 1, toolobj_count do
        local obj = tool:GetViewObjByIndex(i - 1)
        local tempid = obj:QueryProp("ConfigID")
        local bind_status = obj:QueryProp("BindStatus")
        if tempid == item and (bind_type == Fuse_OnlyUseBindType and bind_status == 1 or bind_type == Fuse_OnlyUseUnbindType and bind_status == 0 or bind_type == Fuse_UseAllType) then
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
  else
    flag = true
    min_num = 1
  end
  if flag == false then
    min_num = 0
  end
  return min_num
end
function clear_backImage(form)
  for i = 1, 8 do
    local GirdName = "ImageControlGrid" .. i
    local ImageGird = form.groupbox_fuse:Find(GirdName)
    ImageGird:Clear()
  end
  form.imagegrid_fuseitem:Clear()
end
function refresh_btn_state(form)
  local cur_load = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if nx_is_valid(cur_load) then
    form.btn_cancel.Visible = true
  else
    form.btn_cancel.Visible = false
  end
end
function get_wx_formula(game_client, job_id)
  local fuse_formula_query = nx_value("FuseFormulaQuery")
  if not nx_is_valid(fuse_formula_query) then
    return nil
  end
  local formula_list = {}
  local formula_set = {}
  local tool = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(tool) then
    return nil
  end
  local count = tool:GetViewObjCount()
  for i = 1, count do
    local obj = tool:GetViewObjByIndex(i - 1)
    local id = obj:QueryProp("ConfigID")
    if id then
      local wx_formula = fuse_formula_query:GetWxFormulas(id, job_id, 0)
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
function config_sub_node(form, gui, fuse_root, formula_list, ini_path)
  local fuse_ini = nx_execute("util_functions", "get_ini", ini_path)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  for _, formula in ipairs(formula_list) do
    local index = fuse_ini:FindSectionIndex(nx_string(formula))
    if 0 <= index then
      local fuse_name = fuse_ini:ReadString(index, "ComposeResult", "")
      local Material_str = fuse_ini:ReadString(index, "Material", "")
      local fuse_type = fuse_ini:ReadString(index, "Profession", "")
      local money = fuse_ini:ReadString(index, "Money", "")
      local money_zy = fuse_ini:ReadString(index, "Money2", "")
      local PowerLevel = fuse_ini:ReadString(index, "PowerLevel", "")
      if fuse_name ~= "" and Material_str ~= "" and nx_number(PowerLevel) <= nx_number(client_player:QueryProp("PowerLevel")) then
        local node_name = gui.TextManager:GetFormatText(fuse_name)
        local node_id = fuse_ini:GetSectionByIndex(index)
        if sortString == "" or nil ~= string.find(nx_string(node_name), nx_string(sortString)) then
          local canfuse_num = nx_string(get_canfuse_num(node_id, form.job_id, form.BindType))
          if nx_int(canfuse_num) == nx_int(0) then
            canfuse_num = ""
          else
            canfuse_num = " (" .. canfuse_num .. ")"
          end
          local sub_node = fuse_root:CreateNode(nx_widestr(node_name) .. nx_widestr(canfuse_num))
          sub_node.ItemHeight = 34
          sub_node.TextOffsetX = 35
          sub_node.TextOffsetY = 5
          sub_node.Material = Material_str
          sub_node.formula_id = fuse_name
          sub_node.id = node_id
          sub_node.price = money
          sub_node.price_zy = money_zy
          sub_node.NodeFocusImage = "gui\\special\\sizebody\\fuse\\btn_out.png"
          sub_node.NodeCoverImage = "gui\\special\\sizebody\\fuse\\btn_out.png"
          sub_node.NodeSelectImage = "gui\\special\\sizebody\\fuse\\btn_down.png"
          sub_node.Font = "font_playername"
          sub_node.ForeColor = "255,255,255,255"
          if nx_is_valid(sub_node) and not nx_is_valid(form.tree_fuse.SelectNode) then
            form.tree_fuse.SelectNode = sub_node
          end
        end
      end
    end
  end
end
function test_ini()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local fuse_ini = nx_execute("util_functions", "get_ini", "share\\Item\\fuse_formula.ini")
  local sec_index = fuse_ini:FindSectionIndex("2")
  if sec_index < 0 then
    return
  end
  local value = fuse_ini:ReadString(sec_index, "ComposeResult", "-1")
  node_name = gui.TextManager:GetFormatText(value)
end
function a(str)
  nx_msgbox(nx_string(str))
end
function process_break_btn_show(form, show)
  if show == 1 then
    form.btn_fuse.Visible = false
    form.btn_cancel.Visible = true
  else
    form.btn_fuse.Visible = true
    form.btn_cancel.Visible = false
  end
end
function price_to_text(form, gui, price)
  local ding = math.floor(nx_number(price) / 1000000)
  local liang = math.floor(nx_number(price) % 1000000 / 1000)
  local wen = math.floor(nx_number(price) % 1000)
  local htmlTextYinZi = nx_widestr("")
  if 0 < ding then
    local text = gui.TextManager:GetText("ui_ding")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(nx_int(ding)) .. nx_widestr(htmlText)
  end
  if 0 < liang then
    local text = gui.TextManager:GetText("ui_liang")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
  end
  if 0 < wen then
    local text = gui.TextManager:GetText("ui_wen")
    local htmlText = nx_widestr(text)
    htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
  end
  if price == 0 then
    htmlTextYinZi = htmlTextYinZi .. nx_widestr("0")
  end
  return nx_widestr(htmlTextYinZi)
end
