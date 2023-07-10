require("form_stage_main\\form_wuxue\\form_wuxue_util")
local HUIHAI_ACTIVE = 10
local HUIHAI_RESET = 20
local JinFa_NONE = 0
local JinFa_NuQi = 1
local JinFa_DaZhao = 2
local JinFa_MAX = 3
local JinFa_Col = 10
local JinFa_Row = 10
local HUIHAI_SHOW_LIMIT = 10000
function main_form_init(form)
  form.Fixed = true
  return 1
end
function main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_JINGMAI, form, nx_current(), "on_jingmai_viewport_change")
    databinder:AddTableBind(TABLE_NAME_JINFA, form, nx_current(), "on_jinfa_rec_refresh")
    databinder:AddRolePropertyBind("MaxHuiPoint", "int", form, nx_current(), "prop_callback_maxhuipoint")
  end
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelTableBind(TABLE_NAME_JINFA, form)
    databinder:DelRolePropertyBind("MaxHuiPoint", form)
  end
  nx_destroy(form)
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  huihai_refresh(self.ParentForm)
end
function on_jingmai_viewport_change(form, optype, view_ident, index)
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_type_data", form, -1, -1)
  else
    show_type_data(form)
    set_radio_btns()
  end
end
function on_jinfa_rec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return 0
  end
  huihai_refresh(form)
  return 1
end
function prop_callback_maxhuipoint(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  local huipoint_max = get_player_prop("MaxHuiPoint")
  if nx_int(huipoint_max) <= nx_int(HUIHAI_SHOW_LIMIT) then
    return 0
  end
  if nx_is_valid(form.tree_types.RootNode) and 0 < form.tree_types.RootNode:GetNodeCount() then
    return 0
  end
  show_type_data(form)
end
function show_type_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  if nx_int(get_player_prop("MaxHuiPoint")) <= nx_int(HUIHAI_SHOW_LIMIT) then
    return 0
  end
  local learned_jm_count = 0
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_JINGMAI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_JINGMAI, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      local item = wuxue_query:GetLearnID_JingMai(sub_type_name)
      if nx_is_valid(item) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_node_prop(type_node, 1)
        end
        local sub_type_root = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_root) then
          sub_type_root.type_name = sub_type_name
          set_node_prop(sub_type_root, 2)
        end
        learned_jm_count = learned_jm_count + 1
      end
    end
  end
  auto_select_first(form.tree_types)
  root.Expand = true
  form.tree_types:EndUpdate()
end
function huihai_refresh(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  form.grid_huihai:Clear()
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  local jingmai_name = sel_node.type_name
  if jingmai_name == nil then
    return 0
  end
  for i = 0, JinFa_Col * JinFa_Row - 1 do
    local temp_name = get_pos_str(jingmai_name, i)
    if nx_string(temp_name) ~= "" and nx_string(temp_name) ~= "0" then
      if nx_string(temp_name) == nx_string("1") then
        local photo = "gui\\special\\wuxue\\button\\hhd_1.png"
        form.grid_huihai:AddItem(i, nx_string(photo), 0, 1, -1)
      elseif check_has_jinfa(temp_name) then
        local photo = get_jinfa_prop(temp_name, "Photo")
        form.grid_huihai:AddItem(i, nx_string(photo), 0, 1, -1)
        form.grid_huihai:ChangeItemImageToBW(nx_int(i), false)
      else
        local bSideLearn = check_side(jingmai_name, i)
        if bSideLearn then
          local photo = get_jinfa_prop(temp_name, "Photo")
          form.grid_huihai:AddItem(i, nx_string(photo), 0, 1, -1)
          form.grid_huihai:ChangeItemImageToBW(nx_int(i), true)
        else
          form.grid_huihai:AddItem(i, nx_string(DEFAULT_PHOTO), 0, 1, -1)
        end
      end
    end
  end
end
function get_pos_str(jingmai_id, index)
  if jingmai_id == nil then
    return ""
  end
  if index == nil or nx_int(index) < nx_int(0) or nx_int(index) >= nx_int(JinFa_Col * JinFa_Row) then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", INI_HUIHAI_POS)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(jingmai_id))
  if sec_index < 0 then
    return ""
  end
  local col = nx_number(nx_int(index / JinFa_Row + 1))
  local row = nx_number(nx_int(index % JinFa_Row + 1))
  local item_list = ini:GetItemValueList(sec_index, "r")
  if table.getn(item_list) ~= JinFa_Col then
    return ""
  end
  local value_list = nx_function("ext_split_string", item_list[col], ",")
  if table.getn(value_list) ~= JinFa_Row then
    return ""
  end
  return nx_string(value_list[row])
end
function check_side(jingmai_id, index)
  if jingmai_id == nil then
    return false
  end
  if index == nil or nx_int(index) < nx_int(0) or nx_int(index) >= nx_int(JinFa_Col * JinFa_Row) then
    return false
  end
  if nx_int(index) >= nx_int(JinFa_Col) then
    local up_index = index - JinFa_Col
    local jinfa_name = get_pos_str(jingmai_id, up_index)
    if jinfa_name ~= nil and (nx_string(jinfa_name) == nx_string("1") or check_has_jinfa(jinfa_name)) then
      return true
    end
  end
  if nx_int(index) < nx_int((JinFa_Row - 1) * JinFa_Col) then
    local down_index = index - JinFa_Col
    local jinfa_name = get_pos_str(jingmai_id, down_index)
    if jinfa_name ~= nil and (nx_string(jinfa_name) == nx_string("1") or check_has_jinfa(jinfa_name)) then
      return true
    end
  end
  if nx_int(index % JinFa_Col) ~= nx_int(0) then
    local left_index = index - 1
    local jinfa_name = get_pos_str(jingmai_id, left_index)
    if jinfa_name ~= nil and (nx_string(jinfa_name) == nx_string("1") or check_has_jinfa(jinfa_name)) then
      return true
    end
  end
  if nx_int(index % JinFa_Col) ~= nx_int(JinFa_Col - 1) then
    local right_index = index + 1
    local jinfa_name = get_pos_str(jingmai_id, right_index)
    if jinfa_name ~= nil and (nx_string(jinfa_name) == nx_string("1") or check_has_jinfa(jinfa_name)) then
      return true
    end
  end
  return false
end
function check_has_jinfa(jinfa_name)
  if jinfa_name == nil or nx_string(jinfa_name) == nx_string("") then
    return false
  end
  local game_client = nx_value("game_client")
  local client_obj = game_client:GetPlayer()
  local row = client_obj:FindRecordRow("jinfa_rec", 0, nx_string(jinfa_name), 0)
  if 0 <= row then
    return true
  end
  return false
end
function get_jinfa_prop(jinfa_name, prop)
  local jinfaini = nx_execute("util_functions", "get_ini", INI_FILE_JF_SKILL)
  if not nx_is_valid(jinfaini) then
    return ""
  end
  local sec_index = jinfaini:FindSectionIndex(nx_string(jinfa_name))
  if sec_index < 0 then
    return ""
  end
  return jinfaini:ReadString(sec_index, nx_string(prop), "")
end
function on_grid_huihai_select_changed(grid, index)
  local gui = nx_value("gui")
  local form = grid.ParentForm
  grid:SetSelectItemIndex(-1)
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  local jingmai_name = sel_node.type_name
  if jingmai_name == nil then
    return 0
  end
  local name = get_pos_str(jingmai_name, index)
  if name == nil then
    return
  end
  if nx_string(name) == nx_string("0") or nx_string(name) == nx_string("1") then
    return
  end
  if check_has_jinfa(name) == false then
    local photo = grid:GetItemImage(index)
    if nx_string(photo) == nx_string(DEFAULT_PHOTO) then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = "\200\183\200\207\188\164\187\238:" .. get_jinfa_prop(name, "Name") .. " \207\251\186\196\187\219\181\227:" .. get_jinfa_prop(name, "CastPoint")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_wear_jinfa", HUIHAI_ACTIVE, jingmai_name, name)
    end
  end
end
function on_btn_reset_click(btn)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = "\200\183\200\207\202\199\183\241\214\216\214\195\203\249\211\208\190\162\183\168?"
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_wear_jinfa", HUIHAI_RESET, "", "")
  end
  return
end
function on_grid_huihai_mousein_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  local jingmai_name = sel_node.type_name
  if jingmai_name == nil then
    return 0
  end
  local name = get_pos_str(jingmai_name, index)
  if name == nil or nx_string(name) == nx_string("0") then
    return
  end
  if nx_string(name) == nx_string("1") then
    local tip_text = "\187\219\184\249: \187\219\186\163\205\188\181\196\198\240\181\227\163\172\180\211\213\226\192\239\191\170\198\244\190\162\183\168\163\174"
    nx_execute("tips_game", "show_text_tip", nx_widestr(tip_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
    return
  end
  local photo = grid:GetItemImage(index)
  if check_has_jinfa(name) == false and nx_string(photo) == nx_string(DEFAULT_PHOTO) then
    local tip_text = "**\206\180\214\170**"
    nx_execute("tips_game", "show_text_tip", nx_widestr(tip_text), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 150, grid.ParentForm)
  else
    nx_execute("tips_game", "show_tips_common", name, 1013, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
  end
end
function on_grid_huihai_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
