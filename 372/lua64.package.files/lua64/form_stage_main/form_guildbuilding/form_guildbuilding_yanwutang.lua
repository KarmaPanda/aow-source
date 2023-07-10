require("custom_sender")
require("util_static_data")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_guild\\form_guild_util")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\form_guildbuilding\\sub_command_define")
require("define\\sysinfo_define")
require("util_functions")
function main_form_init(form)
  form.Fixed = false
  form.sel_item_index = -1
  form.sel_item_level = -1
  form.cur_zhenfaid = ""
  form.npc_id = nil
  form.building_npc = nil
  form.cur_select_node = nil
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.mltbox_zfdesc.HtmlText = nx_widestr("")
  load_zhenfa_tree(form)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_show)
  nx_execute("scene", "delete_scene", form.scenebox_show.Scene)
  nx_execute("tips_game", "hide_tip", self)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form:Close()
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  if cur_node.Level == 0 then
    return 0
  end
  form.sel_item_index = cur_node._zhenfa_index
  form.sel_item_level = cur_node._Level
  show_item_data(self.ParentForm)
  show_zf_action(self.ParentForm)
  show_zf_condition(self.ParentForm)
  form.cur_select_node = cur_node
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
end
function on_grid_photo_mouseout_grid(grid, index)
end
function on_grid_photo_select_changed(grid, index)
  local view_index = grid:GetBindIndex(index)
  if view_index < 0 then
    return 0
  end
  local goodsgrid = nx_value("GoodsGrid")
  if not nx_is_valid(goodsgrid) then
    return
  end
  goodsgrid:ViewGridOnSelectItem(grid, -1)
  grid:SetSelectItemIndex(-1)
end
function request_yanxi_contribute(form, res_id, res_num)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local zhenfa_level = form.sel_item_level
  local zhenfa_index = form.sel_item_index
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_ZHENFA_YANXI_CONTRIBUTE), form.npc_id, nx_int(zhenfa_level), nx_int(zhenfa_index), nx_string(res_id), res_num)
end
function on_btn_zf_faculty_click(self)
  local from = self.ParentForm
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_ZHENFA_XUEXI), from.npc_id, nx_string(self.zhenfaid))
end
function load_zhenfa_tree(form)
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return 0
  end
  local root = form.tree_types:CreateRootNode("")
  local zhenfa_list = gb_manager:GetYanWuTangZhenFa()
  if zhenfa_list == nil then
    return
  end
  local zhenfa_arg_num = table.getn(zhenfa_list)
  local i = 1
  local level = 1
  form.tree_types:BeginUpdate()
  while zhenfa_arg_num >= i do
    local level_num = zhenfa_list[i]
    i = i + 1
    local level_node = root:CreateNode(nx_widestr(guild_util_get_text("ui_zhenfatree", nx_int(level))))
    set_node_prop(level_node, 1)
    for j = 0, level_num - 1 do
      local zhenfa_id = nx_string(zhenfa_list[i + j])
      local type_text = guild_util_get_text(zhenfa_id)
      local sub_level_node = level_node:CreateNode(nx_widestr(type_text))
      set_node_prop(sub_level_node, 2)
      sub_level_node.type_name = zhenfa_id
      sub_level_node._zhenfa_index = j
      sub_level_node._Level = level
    end
    i = i + level_num
    level = level + 1
  end
  form.tree_types:EndUpdate()
  root.Expand = true
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
  local game_client = nx_value("game_client")
  local build_npc = game_client:GetSceneObj(nx_string(form.building_npc))
  form.lbl_zfcount.Text = nx_widestr(form.learned_zf_count)
  if nx_is_valid(form.cur_select_node) then
    form.tree_types.SelectNode = form.cur_select_node
    show_zf_condition(form)
  else
    auto_select_first(form.tree_types)
  end
  form.tree_types.RootNode.Expand = true
end
function clear_cur_res()
  local cur_con_info = nx_value("cur_res_info")
  if nx_is_valid(cur_con_info) then
    cur_con_info:ClearChild()
  end
end
function get_cur_res_node(res_id)
  local cur_con_info = nx_value("cur_res_info")
  if not nx_is_valid(cur_con_info) then
    cur_con_info = nx_create("ArrayList", nx_current())
    nx_set_value("cur_res_info", cur_con_info)
  end
  local node = cur_con_info:GetChild(res_id)
  if not nx_is_valid(node) then
    node = cur_con_info:CreateChild(res_id)
  else
    return node
  end
  if nx_is_valid(node) then
    node._cur_num = nx_int(0)
  end
  return node
end
function on_recv_yanxi_info(...)
  local gui = nx_value("gui")
  local size = table.getn(arg)
  if size < 3 then
    return 0
  end
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_yanwutang")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_yanwutang", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_yanwutang", form)
  end
  local offset = 1
  form.npc_id = arg[offset]
  offset = offset + 1
  form.building_npc = arg[offset]
  offset = offset + 1
  form.cur_zhenfaid = arg[offset]
  offset = offset + 1
  local zhenfa_table = util_split_string(arg[offset], ",")
  form.learned_zf_count = table.getn(zhenfa_table)
  form.zhenfa_str = nx_string(arg[offset])
  offset = offset + 1
  clear_cur_res()
  local cond_num = (size - offset + 1) / 2
  for i = 1, cond_num do
    local goods_id = arg[offset]
    offset = offset + 1
    local goods_num = arg[offset]
    offset = offset + 1
    local res_node = get_cur_res_node(goods_id)
    if nx_is_valid(res_node) then
      res_node._cur_num = goods_num
    end
  end
  form:Show()
  form.Visible = true
  show_type_data(form)
end
function show_item_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local sel_item_index = 1
  form.mltbox_zfdesc.HtmlText = nx_widestr(gui.TextManager:GetFormatText("desc_" .. sel_node.type_name))
end
function show_zf_action(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  show_item_action(form, sel_node.type_name, WUXUE_SHOW_ZHENFA)
end
function show_zf_condition(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "type_name") then
    return 0
  end
  form.lbl_name.Text = nx_widestr(gui.TextManager:GetText("ui_guild_build_upgrade_zijin"))
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return 0
  end
  local game_client = nx_value("game_client")
  local build_npc = game_client:GetSceneObj(nx_string(form.building_npc))
  if not nx_is_valid(build_npc) then
    return 0
  end
  local temp_flag = false
  local zhenfa_table = util_split_string(nx_string(form.zhenfa_str), ",")
  for i = 1, table.getn(zhenfa_table) do
    local temp_str = zhenfa_table[i]
    if nx_string(temp_str) == nx_string(sel_node.type_name) then
      temp_flag = true
    end
  end
  if temp_flag == false then
    show_yanxi_condition(form, sel_node, gb_manager)
  else
    show_study_condition(form, sel_node, gb_manager)
  end
end
function show_yanxi_condition(form, sel_node, gb_manager)
  form.groupscrollbox_1.Visible = true
  form.groupscrollbox_2.Visible = false
  for i = 1, 3 do
    local btn_obj = form.groupscrollbox_1:Find("btn_item" .. nx_string(i))
    if nx_is_valid(btn_obj) then
      btn_obj.Visible = false
    end
    local lbl_obj = form.groupscrollbox_1:Find("lbl_item" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
    local backlbl_obj = form.groupscrollbox_1:Find("lbl_" .. nx_string(i + 7))
    if nx_is_valid(backlbl_obj) then
      backlbl_obj.Visible = false
    end
  end
  form.lbl_build.Text = nx_widestr(guild_util_get_text("ui_yanxizhenfa"))
  local cond_tab = gb_manager:GetYanWuTangYanxiInfo(sel_node._Level, sel_node._zhenfa_index)
  local arg_num = table.getn(cond_tab)
  if arg_num <= 0 then
    return
  end
  local offset = 1
  local needTime = cond_tab[offset]
  offset = offset + 1
  local capitalType0 = cond_tab[offset]
  offset = offset + 1
  local capitalType1 = cond_tab[offset]
  offset = offset + 1
  form.btn_faculty._goods_id = "CapitalType1"
  if form.cur_zhenfaid == nx_string(sel_node.type_name) then
    local cur_node = get_cur_res_node(form.btn_faculty._goods_id)
    form.btn_faculty._cur_num = cur_node._cur_num
  else
    form.btn_faculty._cur_num = 0
  end
  form.btn_faculty._goods_num = capitalType1
  form.btn_faculty._contribute = 1
  form.pbar_exp.Maximum = capitalType1
  form.pbar_exp.Value = form.btn_faculty._cur_num
  local item_num = cond_tab[offset]
  offset = offset + 1
  for i = 1, item_num do
    local goods_id = cond_tab[offset]
    offset = offset + 1
    local goods_num = cond_tab[offset]
    offset = offset + 1
    local contribute = cond_tab[offset]
    offset = offset + 1
    local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", goods_id, "Photo")
    local btn_obj = form.groupscrollbox_1:Find("btn_item" .. nx_string(i))
    if nx_is_valid(btn_obj) then
      btn_obj.NormalImage = photo
      btn_obj._goods_id = goods_id
      if form.cur_zhenfaid == nx_string(sel_node.type_name) then
        local cur_node = get_cur_res_node(goods_id)
        btn_obj._cur_num = cur_node._cur_num
      else
        btn_obj._cur_num = 0
      end
      btn_obj._goods_num = goods_num
      btn_obj._contribute = contribute
      btn_obj.Visible = true
    end
    local lbl_obj = form.groupscrollbox_1:Find("lbl_item" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      lbl_obj.Text = nx_widestr(nx_string(btn_obj._cur_num) .. "/" .. nx_string(goods_num))
      lbl_obj.Visible = true
    end
  end
end
function show_study_condition(form, sel_node, gb_manager)
  form.groupscrollbox_1.Visible = false
  form.groupscrollbox_2.Visible = true
  form.lbl_build.Text = nx_widestr(guild_util_get_text("ui_studyzhenfa"))
  for i = 1, 3 do
    local btn_obj = form.groupscrollbox_2:Find("btn_neigong" .. nx_string(i))
    if nx_is_valid(btn_obj) then
      btn_obj.Visible = false
    end
    local lbl_obj = form.groupscrollbox_2:Find("lbl_neigong" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      lbl_obj.Visible = false
    end
  end
  local game_client = nx_value("game_client")
  local game_player = game_client:GetPlayer()
  local school = game_player:QueryProp("School")
  local cond_tab = gb_manager:GetYanWuTangStudyInfo(nx_string(school), nx_string(sel_node.type_name))
  local arg_num = table.getn(cond_tab)
  if arg_num <= 0 then
    return
  end
  form.btn_faculty2.zhenfaid = nx_string(sel_node.type_name)
  local offset = 1
  local cost_contribution = cond_tab[offset]
  offset = offset + 1
  form.lbl_contribute.Text = nx_widestr(guild_util_get_text("19277", nx_int(1), nx_int(cost_contribution)))
  local cond_num = cond_tab[offset]
  offset = offset + 1
  for i = 1, cond_num do
    local neigong_id = cond_tab[offset]
    offset = offset + 1
    local neigong_level = cond_tab[offset]
    offset = offset + 1
    local lbl_obj = form.groupscrollbox_2:Find("lbl_neigong" .. nx_string(i))
    if nx_is_valid(lbl_obj) then
      local ng = guild_util_get_text(neigong_id)
      lbl_obj.Text = nx_widestr(guild_util_get_text("19276", ng, nx_int(neigong_level)))
      lbl_obj.Visible = true
    end
  end
end
function on_mousein_btn(self, index)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_by_config", self._goods_id, x, y, form)
end
function on_mouseout_btn(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_btn_click(self)
  local ownform = self.ParentForm
  nx_execute("tips_game", "hide_tip", ownform)
  local game_client = nx_value("game_client")
  local build_npc = game_client:GetSceneObj(nx_string(ownform.building_npc))
  if not nx_is_valid(build_npc) then
    return 0
  end
  local building_level = build_npc:QueryProp("CurLevel")
  if building_level < ownform.sel_item_level then
    local info = guild_util_get_text("19269", nx_int(ownform.sel_item_level))
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm", form)
  end
  local MaxValue = self._goods_num - self._cur_num
  nx_set_value("MaxValue", MaxValue)
  nx_set_value("configID", self._goods_id)
  nx_set_value("contribute", self._contribute)
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form:ShowModal()
  form.Visible = true
  local result, capital = nx_wait_event(100000000, form, "form_guild_depot_contributemoneyconfirm_return")
  if result == "ok" then
    if capital + self._cur_num > self._goods_num then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19240"), SYSTYPE_FIGHT, 0)
      end
    else
      request_yanxi_contribute(self.ParentForm, self._goods_id, capital)
    end
  end
end
