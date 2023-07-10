require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("share\\itemtype_define")
require("tips_data")
local SUB_CLIENT_SET_JINGMAI = 1
local SUB_CLIENT_ACTIVE_JINGMAI = 1
local SUB_CLIENT_CLOSE_JINGMAI = 2
local MSG_SERVER_GET_ZQ = 2
local MSG_SERVER_MAX_LEVEL = 3
local MAX_YUQI_UP = 500
local REASON_GOOD = 0
local REASON_UNKNOWN = 1
local REASON_MAX_LVL = 2
local REASON_MAX_YUQI = 3
local FORM_NAME = "form_stage_main\\form_wuxue\\form_wuxue_jingmai"
local JINGMAI_VARPROP_INI = "share\\Skill\\JingMai\\jingmai_varprop.ini"
function main_form_init(form)
  form.Fixed = true
  form.sel_item_index = -1
  return 1
end
function main_form_open(form)
  form.xuewei_ctrl_list = nx_call("util_gui", "get_arraylist", "xuewei_ctrl_list")
  form.ani_ctrl = nil
  hide_item_data(form)
  form.lbl_ani_photo.Visible = false
  form.lbl_ani_photo_n.Visible = false
  form.is_open = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_JINGMAI, form, nx_current(), "on_jingmai_viewport_change")
    databinder:AddViewBind(VIEWPORT_XUEWEI, form, nx_current(), "on_xuewei_viewport_change")
    databinder:AddRolePropertyBind("CurJingMai", "int", form, nx_current(), "on_CurJingMai_change")
    databinder:AddTableBind("active_jingmai_rec", form, nx_current(), "on_active_jingmai_rec_change")
  end
  form.is_open = true
  show_type_data(form)
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelRolePropertyBind("CurJingMai", form)
    databinder:DelTableBind("active_jingmai_rec", form)
  end
  if nx_find_custom(form, "xuewei_ctrl_list") and nx_is_valid(form.xuewei_ctrl_list) then
    form.xuewei_ctrl_list:ClearChild()
    nx_destroy(form.xuewei_ctrl_list)
  end
  nx_destroy(form)
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid.DataSource == "" then
    form.lbl_ani_photo.Visible = false
    form.lbl_ani_photo_n.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    if nx_find_custom(grid, "item_name") then
      local gui = nx_value("gui")
      local x, y = gui:GetCursorPosition()
      if grid.item_name ~= "" then
        nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_nixiu_" .. grid.item_name), x, y)
      else
        nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_nixiu_000"), x, y)
      end
    end
    return 0
  end
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = false
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_grid_photo_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_grid_tonic_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "item_name") then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(grid.item_name))
  if not nx_is_valid(jingmai) then
    return
  end
  local rows = jingmai:GetRecordRows("plug_record")
  if nx_int(rows) <= nx_int(0) then
    return
  end
  local prop_name = jingmai:QueryRecord("plug_record", 0, 0)
  local prop_value = jingmai:QueryRecord("plug_record", 0, 1)
  local ConfigID = jingmai:QueryRecord("plug_record", 0, 2)
  local item_data = nx_call("util_gui", "get_arraylist", "qizhen_list")
  item_data.ConfigID = nx_string(ConfigID)
  item_data.ItemType = nx_int(ITEMTYPE_QIZHEN)
  item_data.PropName = nx_string(prop_name)
  item_data.PropValue = nx_int(prop_value)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTips(nx_string(item_data.ConfigID), item_data, nx_int(item_data.ItemType), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
  end
end
function on_grid_tonic_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_pbar_gate_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  if jingmai_query:CheckJingMaiZhengNi(self.item_name, false) then
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\zqt1_on.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\zqt2_on.png"
  else
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\qzt_1.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\qyt_1.png"
  end
  local gui = nx_value("gui")
  local total_value = form.pbar_gate_left.Maximum + form.pbar_gate_right.Maximum
  local cur_value = form.pbar_gate_left.Value + form.pbar_gate_right.Value
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_zhenqi_tips_1", nx_widestr(cur_value), nx_widestr(total_value)))
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y)
end
function on_pbar_gate_lost_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(self) then
    return
  end
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  if jingmai_query:CheckJingMaiZhengNi(self.item_name, false) then
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\zqt1_out.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\zqt2_out.png"
  else
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\qzt.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\qyt.png"
  end
  nx_execute("tips_game", "hide_tip")
end
function on_btn_use_tonic_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  set_usetonic_tips(form)
end
function on_btn_use_tonic_lost_capture(self)
  self.HintText = nx_widestr("")
end
function on_btn_select_get_capture(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  set_xw_select(form, self.DataSource)
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. self.DataSource))
  if nx_is_valid(gbox_item) then
    local lbl_ani = gbox_item:Find(nx_string("lbl_ani_" .. self.DataSource))
    if nx_is_valid(lbl_ani) then
      lbl_ani.Visible = false
    end
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  if nx_is_valid(item) then
    item.ConfigID = self.item_name
    item.ItemType = 1004
    local gui = nx_value("gui")
    local x, y = gui:GetCursorPosition()
    nx_execute("tips_game", "show_goods_tip", item, x, y, 32, 32, form)
  end
end
function on_btn_select_lost_capture(self)
  local form = self.ParentForm
  nx_execute("tips_game", "hide_tip", form)
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  set_xw_select(form, form.sel_item_index)
end
function on_btn_active_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local rows = client_player:GetRecordRows("active_jingmai_rec")
  local total_num = client_player:QueryProp("jmActCount")
  local gui = nx_value("gui")
  local txt = gui.TextManager:GetFormatText("tips_jingmai_active_num", nx_int(rows), nx_int(total_num))
  nx_execute("tips_game", "show_text_tip", nx_widestr(txt), self.AbsLeft, self.AbsTop, 0, form)
end
function on_btn_active_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_faculty_right_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local jingmai_id = self.item_name
  if jingmai_id == "" then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_nixiu_000"), x, y)
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai = wuxue_query:GetLearnID_JingMai(jingmai_id)
  if not nx_is_valid(jingmai) then
    nx_execute("tips_game", "show_text_tip", gui.TextManager:GetText("tips_nixiu_" .. jingmai_id), x, y)
  end
end
function on_btn_faculty_right_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  if nx_find_custom(form, "type_name") and nx_find_custom(cur_node, "type_name") and form.type_name ~= cur_node.type_name then
    form.lbl_ani_photo.Visible = false
    form.lbl_ani_photo_n.Visible = false
    form.type_name = ""
    if nx_find_custom(form, "item_name") then
      local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. form.sel_item_index))
      if nx_is_valid(gbox_item) then
        local lbl_ani = gbox_item:Find(nx_string("lbl_ani_" .. form.sel_item_index))
        if nx_is_valid(lbl_ani) then
          lbl_ani.Visible = false
          form.item_name = ""
        end
      end
    end
  end
  show_item_data(form)
end
function on_grid_photo_select_changed(grid, index)
  select_one_item(grid.ParentForm, grid.DataSource)
  set_xw_select(grid.ParentForm, grid.DataSource)
end
function on_btn_select_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "sel_item_index") or nx_number(form.sel_item_index) ~= nx_number(self.DataSource) then
    local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. form.sel_item_index))
    if nx_is_valid(gbox_item) then
      local lbl_ani = gbox_item:Find(nx_string("lbl_ani_" .. form.sel_item_index))
      if nx_is_valid(lbl_ani) then
        lbl_ani.Visible = false
        form.item_name = ""
      end
    end
  end
  select_one_item(form, self.DataSource)
  set_xw_select(form, self.DataSource)
end
function on_btn_faculty_left_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form.btn_faculty_left, "item_name") then
    return 0
  end
  local jingmai_id = nx_string(form.btn_faculty_left.item_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_jingmai = client_player:QueryProp("CurJingMai")
  local jingmai = wuxue_query:GetLearnID_JingMai(jingmai_id)
  show_xuewei_map(form, jingmai_id)
  show_jingmai_faculty(form, jingmai, jingmai_id)
  show_xuewei_ani(form, jingmai_id)
  form.ani_left:Stop()
  form.ani_left:Play()
  if nx_is_valid(jingmai) and not check_wuxue_is_maxlevel(jingmai, WUXUE_JINGMAI) then
    if nx_string(cur_jingmai) == jingmai_id then
      nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, nx_string(""))
    else
      nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, jingmai_id)
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
end
function on_btn_faculty_right_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form.btn_faculty_right, "item_name") then
    return 0
  end
  local jingmai_id = nx_string(form.btn_faculty_right.item_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_jingmai = client_player:QueryProp("CurJingMai")
  local jingmai = wuxue_query:GetLearnID_JingMai(jingmai_id)
  show_xuewei_map(form, jingmai_id)
  show_jingmai_faculty(form, jingmai, jingmai_id)
  show_xuewei_ani(form, jingmai_id)
  form.ani_right:Stop()
  form.ani_right:Play()
  if nx_is_valid(jingmai) and not check_wuxue_is_maxlevel(jingmai, WUXUE_JINGMAI) then
    if nx_string(cur_jingmai) == jingmai_id then
      nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, nx_string(""))
    else
      nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, jingmai_id)
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
end
function on_btn_active_click(self)
  if not nx_find_custom(self, "item_name") or nx_string(self.item_name) == "" then
    return
  end
  nx_execute("custom_sender", "custom_jingmai_msg", SUB_CLIENT_ACTIVE_JINGMAI, nx_string(self.item_name))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_remove_click(self)
  if not nx_find_custom(self, "item_name") or nx_string(self.item_name) == "" then
    return
  end
  nx_execute("custom_sender", "custom_jingmai_msg", SUB_CLIENT_CLOSE_JINGMAI, nx_string(self.item_name))
end
function on_btn_use_tonic_click(self)
  local form = self.ParentForm
  use_tonic_item(form)
end
function use_tonic_item(form)
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local item_list = view:GetViewObjList()
  for i, item in pairs(item_list) do
    local jingmai = item:QueryProp("jingmai")
    local itemtype = item:QueryProp("ItemType")
    if nx_string(jingmai) == nx_string(sel_node.type_name) and nx_int(itemtype) == nx_int(ITEMTYPE_TONIC_ITEM) then
      local form_tonic = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_wuxue\\form_use_tonicitem", true, false)
      form_tonic.jingmai = jingmai
      form_tonic.uid = item:QueryProp("UniqueID")
      form_tonic.curitem = item
      nx_execute("util_gui", "util_show_form", "form_stage_main\\form_wuxue\\form_use_tonicitem", true)
      return
    end
  end
end
function set_usetonic_tips(form)
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return
  end
  if not nx_find_custom(sel_node, "type_name") then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local item_list = view:GetViewObjList()
  for i, item in pairs(item_list) do
    local jingmai = item:QueryProp("jingmai")
    if nx_string(jingmai) == nx_string(sel_node.type_name) then
      form.btn_use_tonic.HintText = nx_widestr("")
      return
    end
  end
  local gui = nx_value("gui")
  form.btn_use_tonic.HintText = nx_widestr(gui.TextManager:GetText("tips_no_usetonic"))
end
function on_jingmai_viewport_change(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_jingmai_data", form, -1, -1)
    return 1
  end
  local item = get_view_object(view_ident, index)
  if not nx_is_valid(item) then
    return 0
  end
  local type_name = item:QueryProp("ConfigID")
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = ""
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_JINGMAI)
end
function on_xuewei_viewport_change(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    return 1
  end
  local item = get_view_object(view_ident, index)
  if not nx_is_valid(item) then
    return 0
  end
  local item_name = item:QueryProp("ConfigID")
  local type_name = get_type_by_wuxue_id(item_name, WUXUE_JINGMAI)
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = item_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_JINGMAI)
end
function on_CurJingMai_change(form)
  set_faculty_btn_image(form)
end
function on_active_jingmai_rec_change(form)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_find_custom(form.btn_active, "item_name") and form.btn_active.item_name ~= "" then
    form.btn_active.Visible = not check_jingmai_active(nx_string(form.btn_active.item_name))
    form.btn_remove.Visible = not form.btn_active.Visible
  end
  if nx_find_custom(form.btn_active_n, "item_name") and form.btn_active_n.item_name ~= "" then
    form.btn_active_n.Visible = not check_jingmai_active(nx_string(form.btn_active_n.item_name))
    form.btn_remove_n.Visible = not form.btn_active_n.Visible
  end
  refresh_jingmai_active_state(form)
end
function show_type_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  local learned_jm_count = 0
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_JINGMAI)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_JINGMAI, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      if check_jingmai_is_show(sub_type_name) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_node_prop(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          set_node_prop(sub_type_node, 2)
          sub_type_node.NodeCoverImage = "gui\\special\\wuxue\\button\\jihuo.png"
          sub_type_node.ShowCoverImage = check_jingmai_active_showcoverimage(sub_type_name)
        end
        if nx_find_custom(form, "type_name") then
          if nx_string(form.type_name) == nx_string(sub_type_name) then
            sel_type_node = sub_type_node
            form.lbl_ani_photo.Visible = true
          elseif nx_string(form.type_name) == jingmai_query:GetConvertJingMai(sub_type_name) then
            sel_type_node = sub_type_node
            form.lbl_ani_photo_n.Visible = true
          end
        end
        learned_jm_count = learned_jm_count + 1
      end
    end
  end
  form.lbl_jmcount.Text = nx_widestr(learned_jm_count)
  if nx_is_valid(sel_type_node) then
    form.tree_types.SelectNode = sel_type_node
  else
    auto_select_first(form.tree_types)
  end
  root.Expand = true
  form.tree_types:EndUpdate()
end
function hide_item_data(form)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return false
  end
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. i))
    if nx_is_valid(gbox_item) then
      gbox_item.Visible = false
    end
  end
  form.gpsb_items:ResetChildrenYPos()
  form.lbl_name.Text = nx_widestr("")
  form.btn_active.item_name = ""
  form.btn_remove.item_name = ""
  form.btn_active_n.item_name = ""
  form.btn_remove_n.item_name = ""
  form.btn_faculty_left.item_name = ""
  form.btn_faculty_right.item_name = ""
  form.lbl_level.Text = nx_widestr("")
  form.grid_photo.item_name = ""
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.grid_photo_n.item_name = ""
  form.grid_photo_n:Clear()
  form.grid_photo_n:SetSelectItemIndex(-1)
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo_n)
  end
  form.gbox_info.Visible = false
end
function show_item_data(form)
  local gui = nx_value("gui")
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
  hide_item_data(form)
  show_jingmai_data(form)
  local sel_item_index = 1
  local item_tab = wuxue_query:GetItemNames(WUXUE_JINGMAI, sel_node.type_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. i))
    if not nx_is_valid(gbox_item) then
      break
    end
    local lbl_name = gbox_item:Find(nx_string("lbl_name_" .. i))
    local lbl_ani = gbox_item:Find(nx_string("lbl_ani_" .. i))
    local cbtn_open = gbox_item:Find(nx_string("cbtn_open_" .. i))
    local btn_select = gbox_item:Find(nx_string("btn_select_" .. i))
    if not (nx_is_valid(lbl_name) and nx_is_valid(lbl_ani) and nx_is_valid(cbtn_open)) or not nx_is_valid(btn_select) then
      break
    end
    lbl_name.Text = gui.TextManager:GetFormatText(item_name)
    lbl_ani.Visible = false
    btn_select.item_name = item_name
    set_xuewei_cbtn_image(cbtn_open, item_name)
    if nx_find_custom(form, "item_name") and nx_string(form.item_name) == nx_string(item_name) then
      sel_item_index = i
      lbl_ani.Visible = true
      form.lbl_ani_photo.Visible = false
      form.lbl_ani_photo_n.Visible = false
    end
    gbox_item.Visible = true
  end
  form.gpsb_items:ResetChildrenYPos()
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = -1
  if 0 < table.getn(item_tab) then
    select_one_item(form, sel_item_index)
    set_xw_select(form, sel_item_index)
  end
end
function select_one_item(form, sel_item_index)
  local gui = nx_value("gui")
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return 0
  end
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = nx_number(sel_item_index)
  set_name_color(form, form.sel_item_index, true)
end
function set_xw_select(form, sel_item_index)
  if not nx_find_custom(form, "xuewei_ctrl_list") then
    return 0
  end
  if not nx_is_valid(form.xuewei_ctrl_list) then
    return 0
  end
  local xuewei_ctrl_obj = form.xuewei_ctrl_list:GetChild(nx_string(sel_item_index))
  if not nx_is_valid(xuewei_ctrl_obj) then
    return 0
  end
  xuewei_ctrl_obj.button.Enabled = false
  xuewei_ctrl_obj.button.Checked = true
  xuewei_ctrl_obj.button.Enabled = true
end
function show_xuewei_ani(form, jingmai_id)
  if not nx_find_custom(form, "xuewei_ctrl_list") then
    return 0
  end
  if not nx_is_valid(form.xuewei_ctrl_list) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  if nx_is_valid(form.ani_ctrl) then
    on_ani_path_end(form.ani_ctrl)
    form.ani_ctrl = nil
  end
  local xuewei_tab = form.xuewei_ctrl_list:GetChildList()
  local xuewei_count = table.getn(xuewei_tab)
  if xuewei_count < 2 then
    return 0
  end
  local is_ni = jingmai_query:CheckJingMaiZhengNi(jingmai_id, false)
  if is_ni then
    if xuewei_tab[xuewei_count].button.xuewei_open == false or xuewei_tab[xuewei_count - 1].button.xuewei_open == false then
      return 0
    end
  elseif xuewei_tab[1].button.xuewei_open == false or xuewei_tab[2].button.xuewei_open == false then
    return 0
  end
  local color = "255,0,255,0"
  if is_ni then
    color = "255,255,0,0"
  end
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  form:Add(ani_path)
  form.ani_ctrl = ani_path
  ani_path.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_path.SmoothPath = true
  ani_path.Loop = false
  ani_path.ClosePath = false
  ani_path.Color = color
  ani_path.CreateMinInterval = 5
  ani_path.CreateMaxInterval = 10
  ani_path.RotateSpeed = 2
  ani_path.BeginAlpha = 1
  ani_path.AlphaChangeSpeed = 1
  ani_path.BeginScale = 0.05
  ani_path.ScaleSpeed = 0
  ani_path.MaxTime = 1000
  ani_path.MaxWave = 0.05
  ani_path:ClearPathPoints()
  local is_break = false
  for i = 1, table.getn(xuewei_tab) do
    local button = xuewei_tab[i].button
    if is_ni then
      button = xuewei_tab[xuewei_count - i + 1].button
    end
    if nx_is_valid(button) and button.xuewei_open == true then
      if is_break == false then
        ani_path:AddPathPoint(button.AbsLeft + button.Width / 2, button.AbsTop + button.Height / 2)
      end
    else
      is_break = true
    end
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
end
function on_ani_path_end(self)
  local gui = nx_value("gui")
  if not nx_is_valid(self) then
    return 0
  end
  self.Visible = false
  gui:Delete(self)
end
function show_jingmai_data(form)
  local gui = nx_value("gui")
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
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  local jingmai_id = sel_node.type_name
  local jingmai_id_n = jingmai_query:GetConvertJingMai(jingmai_id)
  local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_id))
  if nx_is_valid(jingmai) then
    form.grid_tonic.item_name = nx_string(jingmai_id)
    show_tonic_photo(form, jingmai)
    form.btn_active.item_name = nx_string(jingmai_id)
    form.btn_remove.item_name = nx_string(jingmai_id)
    if check_wuxue_is_maxlevel(jingmai, WUXUE_JINGMAI) then
      form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_max")
    else
      local canLevel = get_maxlevel_by_conditions(jingmai)
      local curLevel = jingmai:QueryProp("Level")
      if nx_int(player:QueryProp("IsJYFaucltyAttacker")) == nx_int(1) and nx_int(curLevel) > nx_int(canLevel) then
        canLevel = curLevel
      end
      form.lbl_level.Text = nx_widestr(nx_string(curLevel) .. "/" .. nx_string(canLevel)) .. nx_widestr(util_text("ui_cycle_day"))
    end
    set_grid_data(form.grid_photo, jingmai, VIEWPORT_JINGMAI)
  else
    form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_0")
    set_grid_data(form.grid_photo)
  end
  form.grid_photo.item_name = jingmai_id
  form.btn_active.Visible = not check_jingmai_active(jingmai_id)
  form.btn_remove.Visible = not form.btn_active.Visible
  form.btn_faculty_left.item_name = nx_string(jingmai_id)
  form.btn_faculty_left.wuxue_type = WUXUE_JINGMAI
  form.btn_faculty_right.Enabled = jingmai_id_n ~= ""
  local jingmai_n = wuxue_query:GetLearnID_JingMai(nx_string(jingmai_id_n))
  if nx_is_valid(jingmai_n) then
    form.btn_active_n.Enabled = true
    form.btn_remove_n.Enabled = true
    form.btn_faculty_right.Enabled = true
    form.btn_active_n.item_name = nx_string(jingmai_id_n)
    form.btn_remove_n.item_name = nx_string(jingmai_id_n)
    if check_wuxue_is_maxlevel(jingmai_n, WUXUE_JINGMAI) then
      form.lbl_level_n.Text = gui.TextManager:GetText("ui_wuxue_level_max")
    else
      local canLevel = get_maxlevel_by_conditions(jingmai_n)
      local curLevel = jingmai_n:QueryProp("Level")
      form.lbl_level_n.Text = nx_widestr(nx_string(curLevel) .. "/" .. nx_string(canLevel)) .. nx_widestr(util_text("ui_cycle_day"))
    end
    set_grid_data(form.grid_photo_n, jingmai_n, VIEWPORT_JINGMAI)
  else
    form.btn_active_n.Enabled = false
    form.btn_remove_n.Enabled = false
    form.btn_faculty_right.Enabled = false
    form.lbl_level_n.Text = gui.TextManager:GetText("ui_wuxue_level_0")
    set_grid_data(form.grid_photo_n)
  end
  form.grid_photo_n.item_name = jingmai_id_n
  form.btn_active_n.Visible = not check_jingmai_active(jingmai_id_n)
  form.btn_remove_n.Visible = not form.btn_active_n.Visible
  form.btn_faculty_right.item_name = nx_string(jingmai_id_n)
  form.btn_faculty_right.wuxue_type = WUXUE_JINGMAI
  set_faculty_btn_image(form)
  show_xuewei_map(form, jingmai_id)
  show_jingmai_faculty(form, jingmai, jingmai_id)
end
function show_xuewei_map(form, jingmai_id)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  local is_ni = jingmai_query:CheckJingMaiZhengNi(jingmai_id, false)
  form.gbox_xuewei_map.BackImage = ""
  form.gbox_xuewei_map:DeleteAll()
  form.xuewei_ctrl_list:ClearChild()
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(jingmai_id))
  form.gbox_xuewei_map.BackImage = JINGMAI_BACKIMAGE_DIR .. nx_string(jingmai_id) .. ".png"
  local xuewei_list = wuxue_query:GetItemNames(WUXUE_JINGMAI, nx_string(jingmai_id))
  for i = 1, table.getn(xuewei_list) do
    local xuewei_id = xuewei_list[i]
    local pos_x, pos_y = jingmai_query:GetXueWeiPos(nx_string(jingmai_id), i - 1)
    local rbtn_wuewei = gui:Create("RadioButton")
    if nx_is_valid(rbtn_wuewei) then
      rbtn_wuewei.Left = nx_int(pos_x)
      rbtn_wuewei.Top = nx_int(pos_y)
      rbtn_wuewei.AutoSize = true
    end
    local item = wuxue_query:GetLearnID_XueWei(xuewei_id)
    if is_ni then
      if nx_is_valid(item) then
        rbtn_wuewei.NormalImage = JINGMAI_XUEWEI_OPEN_R
        rbtn_wuewei.FocusImage = JINGMAI_XUEWEI_OPEN_R
        rbtn_wuewei.CheckedImage = JINGMAI_XUEWEI_SELECT_R
        rbtn_wuewei.xuewei_open = true
      else
        rbtn_wuewei.NormalImage = JINGMAI_XUEWEI_CLOSE_R
        rbtn_wuewei.FocusImage = JINGMAI_XUEWEI_OPEN_R
        rbtn_wuewei.CheckedImage = JINGMAI_XUEWEI_SELECT_R
        rbtn_wuewei.xuewei_open = false
      end
    elseif nx_is_valid(item) then
      rbtn_wuewei.NormalImage = JINGMAI_XUEWEI_OPEN
      rbtn_wuewei.FocusImage = JINGMAI_XUEWEI_OPEN
      rbtn_wuewei.CheckedImage = JINGMAI_XUEWEI_SELECT
      rbtn_wuewei.xuewei_open = true
    else
      rbtn_wuewei.NormalImage = JINGMAI_XUEWEI_CLOSE
      rbtn_wuewei.FocusImage = JINGMAI_XUEWEI_OPEN
      rbtn_wuewei.CheckedImage = JINGMAI_XUEWEI_SELECT
      rbtn_wuewei.xuewei_open = false
    end
    rbtn_wuewei.item_name = gui.TextManager:GetText(xuewei_id)
    rbtn_wuewei.item_index = i
    form.gbox_xuewei_map:Add(rbtn_wuewei)
    form.gbox_xuewei_map:ToFront(rbtn_wuewei)
    nx_bind_script(rbtn_wuewei, nx_current())
    nx_callback(rbtn_wuewei, "on_get_capture", "on_xw_get_capture")
    nx_callback(rbtn_wuewei, "on_lost_capture", "on_xw_lost_capture")
    nx_callback(rbtn_wuewei, "on_checked_changed", "on_xw_checked_changed")
    local child = form.xuewei_ctrl_list:CreateChild(nx_string(i))
    if nx_is_valid(child) then
      child.button = rbtn_wuewei
    end
  end
  form.gbox_info.Visible = true
end
function check_jingmai_active(name)
  if name == nil or nx_string(name) == "" then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local row = client_player:FindRecordRow("active_jingmai_rec", 0, nx_string(name), 0)
  if nx_int(row) >= nx_int(0) then
    return true
  end
  return false
end
function refresh_jingmai_active_state(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_types.RootNode
  if not nx_is_valid(root) then
    return
  end
  local node_count = root:GetNodeCount()
  local node_list = root:GetNodeList()
  for i = 1, node_count do
    if nx_is_valid(node_list[i]) then
      local child_count = node_list[i]:GetNodeCount()
      local child_list = node_list[i]:GetNodeList()
      for j = 1, child_count do
        if nx_is_valid(child_list[j]) and nx_find_custom(child_list[j], "type_name") then
          child_list[j].ShowCoverImage = check_jingmai_active_showcoverimage(child_list[j].type_name)
        end
      end
    end
  end
end
function show_tonic_photo(form, item)
  if not nx_is_valid(form) or not nx_is_valid(item) then
    return
  end
  local rows = item:GetRecordRows("plug_record")
  if nx_int(rows) > nx_int(0) then
    local tonic_id = item:QueryRecord("plug_record", 0, 2)
    if tonic_id == nil or nx_string(tonic_id) == "" then
      return
    end
    form.grid_tonic.HintText = nx_widestr("")
    local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(tonic_id), "Photo")
    form.grid_tonic:AddItem(0, photo, 0, 1, -1)
  else
    form.grid_tonic.HintText = nx_widestr(util_text("ui_tonic_nil"))
    form.grid_tonic:AddItem(0, "icon\\skill\\jn_all.png", 0, 1, -1)
  end
end
function check_jingmai_is_show(jingmai_id)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return false
  end
  if jingmai_query:CheckJingMaiZhengNi(jingmai_id, false) then
    return false
  end
  local item_z = wuxue_query:GetLearnID_JingMai(jingmai_id)
  if nx_is_valid(item_z) then
    return true
  end
  local jingmai_id_n = jingmai_query:GetConvertJingMai(jingmai_id)
  if jingmai_id_n == "" then
    return false
  end
  local item_n = wuxue_query:GetLearnID_JingMai(jingmai_id_n)
  if nx_is_valid(item_n) then
    return true
  end
  return false
end
function check_jingmai_active_showcoverimage(jingmai_id)
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return false
  end
  if check_jingmai_active(jingmai_id) then
    return true
  end
  local jingmai_id_n = jingmai_query:GetConvertJingMai(jingmai_id)
  if jingmai_id_n == "" then
    return false
  end
  if check_jingmai_active(jingmai_id_n) then
    return true
  end
  return false
end
function set_faculty_btn_image(form)
  if not nx_is_valid(form) then
    return 0
  end
  local cur_jingmai = get_player_prop("CurJingMai")
  if nx_find_custom(form.btn_faculty_left, "item_name") and nx_string(cur_jingmai) ~= "" and nx_string(cur_jingmai) == nx_string(form.btn_faculty_left.item_name) then
    form.btn_faculty_left.NormalImage = JINGMAI_FACULTY_CLOSE_OUT
    form.btn_faculty_left.FocusImage = JINGMAI_FACULTY_CLOSE_ON
    form.btn_faculty_left.PushImage = JINGMAI_FACULTY_CLOSE_DOWN
    form.btn_faculty_left.DisableImage = JINGMAI_FACULTY_CLOSE_FORBID
  else
    form.btn_faculty_left.NormalImage = JINGMAI_FACULTY_OPEN_Z_OUT
    form.btn_faculty_left.FocusImage = JINGMAI_FACULTY_OPEN_Z_ON
    form.btn_faculty_left.PushImage = JINGMAI_FACULTY_OPEN_Z_DOWN
    form.btn_faculty_left.DisableImage = JINGMAI_FACULTY_OPEN_Z_FORBID
  end
  if nx_find_custom(form.btn_faculty_right, "item_name") and nx_string(cur_jingmai) ~= "" and nx_string(cur_jingmai) == nx_string(form.btn_faculty_right.item_name) then
    form.btn_faculty_right.NormalImage = JINGMAI_FACULTY_CLOSE_OUT
    form.btn_faculty_right.FocusImage = JINGMAI_FACULTY_CLOSE_ON
    form.btn_faculty_right.PushImage = JINGMAI_FACULTY_CLOSE_DOWN
    form.btn_faculty_right.DisableImage = JINGMAI_FACULTY_CLOSE_FORBID
  else
    form.btn_faculty_right.NormalImage = JINGMAI_FACULTY_OPEN_N_OUT
    form.btn_faculty_right.FocusImage = JINGMAI_FACULTY_OPEN_N_ON
    form.btn_faculty_right.PushImage = JINGMAI_FACULTY_OPEN_N_DOWN
    form.btn_faculty_right.DisableImage = JINGMAI_FACULTY_OPEN_N_FORBID
  end
end
function set_xuewei_cbtn_image(cbtn, xuewei_id)
  if not nx_is_valid(cbtn) then
    return false
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  local xuewei_id_n = jingmai_query:GetConvertXueWei(xuewei_id)
  local xuewei = wuxue_query:GetLearnID_XueWei(xuewei_id)
  local xuewei_n = wuxue_query:GetLearnID_XueWei(xuewei_id_n)
  cbtn.NormalImage = XUEWEI_CBTN_CLOSE
  cbtn.FocusImage = XUEWEI_CBTN_CLOSE
  if nx_is_valid(xuewei) and nx_is_valid(xuewei_n) then
    cbtn.CheckedImage = XUEWEI_CBTN_OPEN_ZN
  elseif nx_is_valid(xuewei) then
    cbtn.CheckedImage = XUEWEI_CBTN_OPEN_Z
  elseif nx_is_valid(xuewei_n) then
    cbtn.CheckedImage = XUEWEI_CBTN_OPEN_N
  end
  cbtn.Checked = nx_is_valid(xuewei) or nx_is_valid(xuewei_n)
  return true
end
function on_xw_get_capture(self)
  local form = self.ParentForm
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return 0
  end
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  tips_manager:ShowTextTips(nx_widestr(self.item_name), self.AbsLeft, self.AbsTop, 64, form)
end
function on_xw_lost_capture(self)
  local form = self.ParentForm
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return 0
  end
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  tips_manager:HideTips(form)
end
function on_xw_checked_changed(self)
  local form = self.ParentForm
  if not self.Checked then
    return 0
  end
  if not nx_find_custom(self, "item_index") then
    return 0
  end
  select_one_item(form, self.item_index)
end
function show_jingmai_faculty(form, jingmai, jingmai_id)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local jingmai_query = nx_value("JingMaiQuery")
  if not nx_is_valid(jingmai_query) then
    return 0
  end
  if jingmai_query:CheckJingMaiZhengNi(jingmai_id, false) then
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\zqt1_out.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\zqt2_out.png"
    form.lbl_back_left.BackImage = "gui\\special\\wuxue\\qzd_r.png"
    form.lbl_back_right.BackImage = "gui\\special\\wuxue\\qyd_r.png"
  else
    form.pbar_gate_left.ProgressImage = "gui\\special\\wuxue\\qzt.png"
    form.pbar_gate_right.ProgressImage = "gui\\special\\wuxue\\qyt.png"
    form.lbl_back_left.BackImage = "gui\\special\\wuxue\\qzd.png"
    form.lbl_back_right.BackImage = "gui\\special\\wuxue\\qyd.png"
  end
  form.pbar_gate_left.item_name = jingmai_id
  form.pbar_gate_right.item_name = jingmai_id
  if nx_is_valid(jingmai) then
    local fillvalue_cur = jingmai:QueryProp("CurFillValue")
    local fillvalue_all = jingmai:QueryProp("TotalFillValue")
    local fillvalue_par = nx_int(fillvalue_all / 2)
    form.pbar_gate_left.Maximum = fillvalue_par
    form.pbar_gate_right.Maximum = fillvalue_par
    if nx_int(fillvalue_cur) <= nx_int(fillvalue_par) then
      form.pbar_gate_left.Value = fillvalue_cur
      form.pbar_gate_right.Value = 0
    elseif nx_int(fillvalue_all) ~= nx_int(0) then
      form.pbar_gate_left.Value = fillvalue_par
      form.pbar_gate_right.Value = fillvalue_cur - fillvalue_par
    end
  else
    form.pbar_gate_left.Maximum = nx_int(100)
    form.pbar_gate_left.Value = nx_int(0)
    form.pbar_gate_right.Maximum = nx_int(100)
    form.pbar_gate_right.Value = nx_int(0)
  end
end
function jingmai_is_max_level(jingmai_name, jingmai_level)
  local gui = nx_value("gui")
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "jingmai_lvlup")
  local text = gui.TextManager:GetFormatText(nx_string("ui_jingmai_level_max"), nx_string(jingmai_name))
  dialog.ok_btn.Visible = false
  dialog.cancel_btn.Width = 120
  dialog.cancel_btn.Left = 240
  dialog.cancel_btn.Text = gui.TextManager:GetText(nx_string("ui_reset_jingmai"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:Show()
  local form_load = nx_value("form_common\\form_loading")
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(dialog)
  else
    gui.Desktop:ToFront(dialog)
  end
  dialog.AbsLeft = (gui.Width - dialog.Width) / 10 * 9
  dialog.AbsTop = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "jingmai_lvlup_confirm_return")
  if res == "cancel" then
    open_wuxue_sub_page(WUXUE_JINGMAI, nx_string(jingmai_name))
  end
end
function on_jingmai_msg(sub_cmd, arg1, arg2)
  if nx_int(sub_cmd) == nx_int(MSG_SERVER_MAX_LEVEL) then
    jingmai_is_max_level(arg1, arg2)
  elseif nx_int(sub_cmd) == nx_int(MSG_SERVER_GET_ZQ) then
    nx_execute("form_stage_main\\form_main\\form_main_player", "play_zhenqi_aination")
    nx_execute("form_stage_main\\form_main\\form_main_shortcut", "play_zhenqi_aination")
  end
end
function on_tonic_msg()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_jingmai", false)
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_jingmai", "show_jingmai_data", form)
  end
end
