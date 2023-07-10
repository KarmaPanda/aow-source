require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("util_static_data")
local SKILL_POWER_INI = "share\\Faculty\\skill_power.ini"
local SKILL_FORGET_INI = "share\\Skill\\skill_forget.ini"
local CLIENT_MSG_FORGET_SKILL = 0
local CLIENT_MSG_RECALL_SKILL = 1
local CLIENT_MSG_REQUEST_SKILL = 2
local CLIENT_MSG_CLEAR_LEVEL = 3
local SERVER_MSG_FORGET_INFO = 0
local SERVER_MSG_REQUST_OVER = 1
local SERVER_MSG_DEL_FORGET_SKILL = 2
local SERVER_MSG_ADD_FORGET_SKILL = 3
local MSG_CLIENT_WUJI_ACTIVATE = 25
local MSG_CLIENT_WUJI_CANCEL = 26
local WUJI_PER_ROW_BIT = 32
local UNKNOWN_NODE = {
  NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn2_on.png",
  NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn2_down.png",
  Font = "font_text_title1",
  ItemHeight = 30,
  NodeOffsetY = 0,
  ExpandCloseOffsetX = 0,
  ExpandCloseOffsetY = 5,
  TextOffsetX = 15,
  TextOffsetY = 6,
  ForeColor = "255,128,128,128"
}
function main_form_init(form)
  form.Fixed = true
  form.sel_item_index = -1
  form.sel_forget_item_index = -1
  form.last_gb_type = 0
  form.wuji_skill_id = ""
  return 1
end
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function open_form()
  nx_execute(FORM_WUXUE_MAIN, "open_form")
end
function main_form_open(form)
  hide_item_data(form)
  hide_skill_data(form)
  form.lbl_ani_photo.Visible = false
  form.btn_faculty_on.Visible = false
  form.btn_ext_faculty_on.Visible = false
  form.is_open = false
  form.grid_photo_forget.MaxLevel = 1
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("ActionSet", "string", form, nx_current(), "prop_callback_actionset")
    databinder:AddViewBind(VIEWPORT_EQUIP, form, nx_current(), "on_equip_view_operat")
    databinder:AddViewBind(VIEWPORT_SKILL, form, nx_current(), "on_skill_view_operat")
    databinder:AddViewBind(VIEWPORT_NORMALATTACK, form, nx_current(), "on_skill_view_operat")
    databinder:AddRolePropertyBind("FacultyName", "string", form, nx_current(), "prop_callback_facultyname")
    databinder:AddRolePropertyBind("ExtFacultyName", "string", form, nx_current(), "prop_callback_extfacultyname")
    databinder:AddRolePropertyBind("FacultyStyle", "int", form, nx_current(), "prop_callback_facultystyle")
  end
  form.is_open = true
  local bshow_unknown = false
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    bshow_unknown = game_config.show_unknown_skill
  end
  if bshow_unknown == true then
    form.cbtn_1.Checked = true
  else
    show_type_data(form)
  end
  form.gonglue_name = get_wuxue_gl_name(form)
  if nx_string(form.gonglue_name) == "" or nx_string(form.gonglue_name) == nil then
    form.btn_strategy.Visible = false
  else
    form.btn_strategy.Visible = true
  end
  nx_execute("custom_sender", "custom_send_forget_skill_msg", CLIENT_MSG_REQUEST_SKILL)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local conditon_manager = nx_value("ConditionManager")
  if nx_is_valid(conditon_manager) then
    local condition_id = get_forget_condition_id()
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, condition_id)
    if bsucc then
      form.btn_recall_skill.Enabled = true
      form.btn_forget_skill.Enabled = true
      form.btn_clear_forget_skill_level.Enabled = true
    else
      form.btn_recall_skill.Enabled = false
      form.btn_forget_skill.Enabled = false
      form.btn_clear_forget_skill_level.Enabled = false
    end
  end
  return 1
end
function main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(form)
    databinder:DelRolePropertyBind("FacultyName", form)
    databinder:DelRolePropertyBind("FacultyStyle", form)
    databinder:DelRolePropertyBind("ExtFacultyName", form)
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if nx_is_valid(skill_data_manager) then
    skill_data_manager:ClearForgetSkill()
  end
  if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
    form.scenebox_show.Scene:Delete(form.Actor2)
  end
  nx_execute("scene", "delete_scene", form.scenebox_show.Scene)
  nx_destroy(form)
end
function on_grid_photo_mousein_grid(grid, index)
  local form = grid.ParentForm
  if grid.DataSource == "" then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    if nx_find_custom(grid, "item_name_old") and grid.item_name_old ~= nil then
      local gui = nx_value("gui")
      local func_manager = nx_value("func_manager")
      local tips_id = func_manager:GetFuncTip(grid.item_name_old)
      nx_execute("tips_game", "show_tips_common", tips_id, 1014, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
    end
    if nx_find_custom(grid, "unknown_name") and grid.unknown_name ~= ANQI_ATTACK_ID then
      local item = nx_execute("tips_game", "get_tips_ArrayList")
      local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", grid.unknown_name, "StaticData", "0")
      item.ConfigID = grid.unknown_name
      item.ItemType = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", grid.unknown_name, "ItemType", "0")
      item.StaticData = nx_number(static_id)
      item.is_static = true
      item.Level = 1
      nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, form)
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
function on_btn_faculty_get_capture(self)
  show_faculty_info(self, "item_name", WUXUE_SKILL)
end
function on_btn_ext_faculty_get_capture(self)
  local form = self.ParentForm
  local grid_photo = form.grid_photo
  if not nx_find_custom(grid_photo, "item_name_old") then
    return
  end
  local skill_id_old = grid_photo.item_name_old
  if skill_id_old == NORMAL_ATTACK_ID then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = gui.TextManager:GetFormatText("tips_btn_ext_tuanlian_3")
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
  local form_team_faculty = nx_value("form_stage_main\\form_wuxue\\form_team_faculty_member")
  if not nx_is_valid(form_team_faculty) then
    return
  elseif not form_team_faculty.Visible then
    return
  end
  show_faculty_info(self, "item_name", WUXUE_SKILL)
end
function on_btn_faculty_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_pbar_gate_get_capture(self)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  local text = gui.TextManager:GetFormatText("tips_ng_xw_01", nx_int(self.Value), nx_int(self.Maximum))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y)
end
function on_pbar_gate_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_pbar_skill_count_get_capture(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local x, y = gui:GetCursorPosition()
  local nPerValue = self.Value * 100 / self.Maximum
  if nPerValue < 99 then
    nPerValue = math.ceil(nPerValue)
  end
  local text = gui.TextManager:GetFormatText("tips_learn_skill_count", nx_int(nPerValue))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y)
end
function on_pbar_skill_count_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  if nx_find_custom(form, "type_name") and nx_find_custom(cur_node, "type_name") and form.type_name ~= cur_node.type_name then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  show_item_data(form)
  form.gonglue_name = get_wuxue_gl_name(form)
  if nx_string(form.gonglue_name) == "" or nx_string(form.gonglue_name) == nil then
    form.btn_strategy.Visible = false
  else
    form.btn_strategy.Visible = true
  end
  local form_main_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local gbox = form_main_shortcut.groupbox_skill_4
  if not nx_is_valid(gbox) or not gbox.Visible then
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(14))
end
function on_tree_types_mouse_in_node(tree, node, x, y)
  local form = tree.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(node, "type_name") then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local skill_list = wuxue_query:GetItemNames(WUXUE_SKILL, node.type_name)
  if table.getn(skill_list) <= 0 then
    return
  end
  local skill_name = nx_string(skill_list[1])
  local skill_obj = wuxue_query:GetLearnID_Skill(skill_name)
  if not nx_is_valid(skill_obj) then
    return
  end
  local end_time = skill_obj:QueryProp("ExpiredDate")
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local now_date = msg_delay:GetServerDateTime()
  if nx_double(end_time) < nx_double(now_date) then
    return
  end
  local diff = nx_double(end_time - now_date)
  local day = nx_int(diff)
  local time = nx_number(diff * 86400)
  local hour = nx_int(math.mod(time, 86400) / 3600)
  local mins = nx_int(math.mod(math.mod(time, 86400), 3600) / 60)
  tree.HintText = util_format_string("ui_hone_wuxuexl_26", nx_int(day), nx_int(hour), nx_int(mins))
end
function on_tree_types_mouse_out_node(tree, node, x, y)
  tree.HintText = nx_widestr("")
end
function on_grid_photo_select_changed(grid, index)
  local gui = nx_value("gui")
  select_one_item(grid.ParentForm, grid.DataSource)
  local helper_form = nx_value("helper_form")
  if helper_form then
    gui.GameHand:ClearHand()
  end
  if gui.GameHand:IsEmpty() and nx_find_custom(grid, "item_name_old") and grid.item_name_old ~= nil then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand(GHT_FUNC, photo, "func", grid.item_name_old, "", "")
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return 0
  elseif gui.GameHand.Type == GHT_FUNC then
    if gui.GameHand.Para1 == "func" and gui.GameHand.Para2 == grid.item_name_old then
      gui.GameHand:ClearHand()
    end
    return 0
  end
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
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_grid_photo_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_grid_photo_drag_move(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    if not game_hand.IsDragged then
      game_hand.IsDragged = true
      if gui.GameHand:IsEmpty() and nx_find_custom(grid, "item_name_old") and grid.item_name_old ~= nil then
        local photo = grid:GetItemImage(index)
        gui.GameHand:SetHand(GHT_FUNC, photo, "func", grid.item_name_old, "", "")
        return 0
      elseif gui.GameHand.Type == GHT_FUNC then
        if gui.GameHand.Para1 == "func" and gui.GameHand.Para2 == grid.item_name_old then
          gui.GameHand:ClearHand()
        end
        return 0
      end
      local goodsgrid = nx_value("GoodsGrid")
      if not nx_is_valid(goodsgrid) then
        return
      end
      goodsgrid:ViewGridOnSelectItem(grid, -1)
    end
  end
end
function on_btn_select_click(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "sel_item_index") or nx_number(form.sel_item_index) ~= nx_number(self.DataSource) then
    form.lbl_ani_photo.Visible = false
    form.type_name = ""
    form.item_name = ""
  end
  if form.groupbox_wuji.Visible then
    show_wuji_info(form, self.DataSource)
  else
    select_one_item(form, self.DataSource)
  end
end
function on_btn_faculty_click(self)
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
end
function on_btn_ext_faculty_click(self)
  if not nx_find_custom(self, "item_name") then
    return 0
  end
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", self.item_name, 1)
  if bSuccess == true then
    auto_show_hide_wuxue()
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_skill_view_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  refresh_skill_count_pbar(form)
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    return 1
  end
  local parent = form.Parent
  if nx_is_valid(parent) and not parent.rbtn_skill_1.Checked then
    parent.rbtn_skill_1.Checked = true
  end
  if nx_string(optype) == "delitem" then
    show_item_data(form)
    return 1
  end
  local item = get_view_object(view_ident, index)
  if not nx_is_valid(item) then
    return 0
  end
  local item_name = item:QueryProp("ConfigID")
  item_name = modify_anqi_attack_id(item_name)
  local type_name = get_type_by_wuxue_id(item_name, WUXUE_SKILL)
  if type_name == "" then
    return 0
  end
  form.type_name = type_name
  form.item_name = item_name
  show_type_data(form)
  set_radio_btns()
  switch_sub_page(WUXUE_SKILL)
end
function on_equip_view_operat(form, optype, view_ident, index)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  if nx_string(optype) == "updateitem" then
    local timer = nx_value("timer_game")
    timer:Register(CALLBACK_WAIT_TIME, 1, nx_current(), "show_item_data", form, -1, -1)
  else
    show_item_data(form)
  end
end
function prop_callback_actionset(form, prop_name, prop_type, prop_value)
  if nx_is_valid(form) and not form.is_open then
    return 0
  end
  show_item_data(form)
end
function prop_callback_facultyname(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  if not nx_find_custom(form.btn_faculty_on, "item_name") then
    return 0
  end
  form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
end
function prop_callback_extfacultyname(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  if not nx_find_custom(form.btn_ext_faculty_on, "item_name") then
    return 0
  end
  form.btn_ext_faculty_on.Visible = check_wuxue_is_ext_faculty(form.btn_ext_faculty_on.item_name)
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
    form.btn_ext_faculty_on.Visible = false
    form.btn_ext_faculty.Visible = false
  end
end
function prop_callback_facultystyle(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return 0
  end
  if not form.is_open then
    return 0
  end
  if not nx_find_custom(form.btn_faculty_on, "item_name") then
    return 0
  end
  form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
end
function on_btn_strategy_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.gonglue_name) == "" or nx_string(form.gonglue_name) == nil then
    return
  end
  local data = nx_string(form.gonglue_name)
  util_auto_show_hide_form("form_stage_main\\form_helper\\form_theme_helper")
  local form_help = util_get_form("form_stage_main\\form_helper\\form_theme_helper", false)
  if nx_is_valid(form_help) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "click_hyperlink", form_help, data)
  end
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
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local power_lev = client_player:QueryProp("PowerLevel")
  local bshow_unknown = false
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    bshow_unknown = game_config.show_unknown_skill
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  local learned_tl_count = 0
  local sel_type_node
  form.tree_types:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    local limit_type = wuxue_query:IsFilterWuxueType(type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      if check_taolu_is_learn(sub_type_name) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_node_prop(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          set_node_prop(sub_type_node, 2)
        end
        if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(sub_type_name) then
          sel_type_node = sub_type_node
        end
        learned_tl_count = learned_tl_count + 1
      elseif bshow_unknown == true then
        local limit_taolu = wuxue_query:IsFilterWuxueTaoLu(type_name, sub_type_name)
        if limit_type == false and limit_taolu == false and show_unknown_taolu(power_lev, sub_type_name) then
          if not nx_is_valid(type_node) then
            type_node = root:CreateNode(gui.TextManager:GetText(type_name))
            set_node_prop(type_node, 1)
          end
          local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
          if nx_is_valid(sub_type_node) then
            sub_type_node.type_name = sub_type_name
            set_unknown_prop(sub_type_node)
          end
        end
      end
    end
  end
  form.lbl_tlcount.Text = nx_widestr(learned_tl_count)
  if nx_is_valid(sel_type_node) then
    form.tree_types.SelectNode = sel_type_node
  else
    auto_select_first(form.tree_types)
  end
  root.Expand = true
  form.tree_types:EndUpdate()
  refresh_skill_count_pbar(form)
end
function hide_item_data(form)
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. nx_string(i))
    if nx_is_valid(gbox_item) then
      gbox_item.Visible = false
    end
  end
  set_name_color(form, form.sel_item_index, false)
  form.sel_item_index = -1
  form.gpsb_items:ResetChildrenYPos()
end
function show_item_data(form)
  local sel_item_index = 1
  if nx_int(form.sel_item_index) > nx_int(0) then
    sel_item_index = form.sel_item_index
  end
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
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
  end
  hide_item_data(form)
  hide_wuji_btn(form)
  switch_skill_groupbox(form, 1)
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, sel_node.type_name)
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. i)
    if not nx_is_valid(gbox_item) then
      break
    end
    local grid_photo = gbox_item:Find("grid_photo_" .. i)
    local lbl_name = gbox_item:Find("lbl_name_" .. i)
    local lbl_level = gbox_item:Find("lbl_level_" .. i)
    local btn_select = gbox_item:Find("btn_select_" .. i)
    local btn_wuji = gbox_item:Find("btn_wuji_" .. i)
    if not (nx_is_valid(grid_photo) and nx_is_valid(lbl_name) and nx_is_valid(lbl_level) and nx_is_valid(btn_select)) or not nx_is_valid(btn_wuji) then
      break
    end
    local item_name_old = item_name
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    if item_name == "" then
      item_name = item_name_old
    end
    local is_learn_anqi = false
    if item_name_old == ANQI_ATTACK_ID then
      is_learn_anqi = check_anqi_normal_skill_is_learn()
    end
    local item = wuxue_query:GetLearnID_Skill(item_name)
    btn_select.item_name = nx_string(item_name)
    lbl_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(item_name)))
    show_wuxue_level(lbl_level, item, WUXUE_SKILL)
    btn_wuji.Visible = is_exist_wuji(form, item_name)
    btn_wuji.item_name = nx_string(item_name)
    if nx_is_valid(item) or is_learn_anqi then
      if item_name_old == ANQI_ATTACK_ID then
        if nx_is_valid(item) then
          set_grid_data(grid_photo, item, VIEWPORT_SKILL)
        else
          local func_manager = nx_value("func_manager")
          local photo = func_manager:GetFuncPhoto(item_name_old)
          grid_photo:SetBindIndex(0, nx_int(-1))
          grid_photo.typeid = ""
          grid_photo.canselect = true
          local GoodsGrid = nx_value("GoodsGrid")
          GoodsGrid:GridClear(grid_photo)
          grid_photo:AddItem(0, nx_string(photo), 0, 1, -1)
          grid_photo:SetItemMark(0, nx_int(-1))
          lbl_level.Text = nx_widestr("")
        end
        grid_photo.item_name_old = item_name_old
        btn_select.item_name_old = item_name_old
      elseif item_name_old == NORMAL_ATTACK_ID then
        set_grid_data(grid_photo, item, VIEWPORT_NORMALATTACK)
        grid_photo.item_name_old = item_name_old
        btn_select.item_name_old = item_name_old
      else
        set_grid_data(grid_photo, item, VIEWPORT_SKILL)
        grid_photo.item_name_old = nil
        btn_select.item_name_old = nil
      end
      if nx_find_custom(form, "item_name") and (nx_string(form.item_name) == nx_string(item_name) or nx_string(form.item_name) == nx_string(item_name_old)) then
        sel_item_index = i
      end
    else
      set_grid_data(grid_photo, item, VIEWPORT_SKILL)
      grid_photo.item_name_old = nil
      btn_select.item_name_old = nil
      grid_photo.unknown_name = item_name
    end
    gbox_item.Visible = true
  end
  form.gpsb_items:ResetChildrenYPos()
  if 1 < table.getn(item_tab) then
    select_one_item(form, sel_item_index)
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
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  local item_name_old = ""
  if nx_find_custom(btn_select, "item_name_old") then
    item_name_old = btn_select.item_name_old
  end
  switch_skill_groupbox(form, 1)
  show_skill_data(form, btn_select.item_name, item_name_old)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local powerlevel = get_skill_powerlevel(nx_string(btn_select.item_name))
  if nx_int(powerlevel) == nx_int(0) then
    form.lbl_skill_power_level.Visible = false
    form.groupbox_powerlevel.Visible = false
  else
    form.lbl_skill_power_level.Visible = true
    form.groupbox_powerlevel.Visible = true
  end
  local level_photo = creat_level_photo(nx_int(powerlevel))
  form.groupbox_powerlevel.item_name = btn_select.item_name
  form.groupbox_powerlevel:DeleteAll()
  form.groupbox_powerlevel:Add(level_photo)
  local wuji_action_name = get_activate_wuji_action(form, btn_select.item_name)
  if wuji_action_name ~= "" then
    local skill_effect = nx_value("skill_effect")
    if not nx_is_valid(skill_effect) then
      return
    end
    local action = create_skill_action(form)
    if action == nil then
      return
    end
    skill_effect:BeginShowZhaoshi(form.Actor2, wuji_action_name)
  else
    local skill_effect = nx_value("skill_effect")
    if nx_is_valid(skill_effect) and nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
      skill_effect:EndShowZhaoshi(form.Actor2, nx_string(item_name_old))
    end
    show_item_action(form, btn_select.item_name, WUXUE_SHOW_SKILL, true)
    add_weapon(form, btn_select.item_name)
  end
end
function hide_skill_data(form)
  form.lbl_name.Text = nx_widestr("")
  form.btn_faculty.item_name = nil
  form.btn_faculty_on.item_name = nil
  form.btn_ext_faculty.item_name = nil
  form.btn_ext_faculty_on.item_name = nil
  form.lbl_level.Text = nx_widestr("")
  form.mltbox_desc:Clear()
  form.grid_photo:Clear()
  form.grid_photo:SetSelectItemIndex(-1)
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(form.grid_photo)
  end
  form.grid_photo.item_name_old = nil
  form.gbox_info.Visible = false
end
function show_skill_data(form, skill_id, skill_id_old)
  local gui = nx_value("gui")
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  hide_skill_data(form)
  form.lbl_name.Text = gui.TextManager:GetText(nx_string(skill_id))
  form.mltbox_desc:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. skill_id)), -1)
  local skill = wuxue_query:GetLearnID_Skill(skill_id)
  show_faculty_level(form, skill, skill_id, WUXUE_SKILL)
  local nForget = nx_number(skill_static_query_by_id(skill_id, "IsForget"))
  if nx_is_valid(skill) and nForget == 0 then
    form.btn_forget_skill.DataSource = skill_id
    form.btn_forget_skill.Visible = true
  else
    form.btn_forget_skill.Visible = false
  end
  form.btn_ext_faculty.Enabled = form.btn_faculty.Enabled
  form.btn_ext_faculty.item_name = nx_string(skill_id)
  local form_team_faculty = nx_value("form_stage_main\\form_wuxue\\form_team_faculty_member")
  if not nx_is_valid(form_team_faculty) then
    form.btn_ext_faculty.Enabled = false
  elseif not form_team_faculty.Visible then
    form.btn_ext_faculty.Enabled = false
  end
  if nx_is_valid(skill) then
    if skill_id_old == ANQI_ATTACK_ID then
      set_grid_data(form.grid_photo, skill, VIEWPORT_SKILL)
      form.grid_photo.item_name_old = skill_id_old
    elseif skill_id_old == NORMAL_ATTACK_ID then
      set_grid_data(form.grid_photo, skill, VIEWPORT_NORMALATTACK)
      form.grid_photo.item_name_old = skill_id_old
      form.gbox_faculty.Visible = false
      form.btn_ext_faculty.Enabled = false
      form.lbl_faculty_back.Visible = true
    else
      set_grid_data(form.grid_photo, skill, VIEWPORT_SKILL)
      form.grid_photo.item_name_old = nil
    end
    form.btn_faculty_on.item_name = nx_string(skill_id)
    form.btn_faculty_on.Enabled = form.btn_faculty.Enabled
    form.btn_ext_faculty_on.item_name = nx_string(skill_id)
    form.btn_ext_faculty_on.Enabled = form.btn_ext_faculty.Enabled
    form.btn_faculty_on.Visible = check_wuxue_is_faculty(form.btn_faculty_on.item_name)
    form.btn_ext_faculty_on.Visible = check_wuxue_is_ext_faculty(form.btn_ext_faculty_on.item_name)
    show_wuxue_level(form.lbl_level, skill, WUXUE_SKILL)
  else
    if skill_id_old == ANQI_ATTACK_ID then
      local func_manager = nx_value("func_manager")
      local photo = func_manager:GetFuncPhoto(skill_id_old)
      form.grid_photo:SetBindIndex(0, nx_int(-1))
      form.grid_photo.typeid = ""
      form.grid_photo.canselect = true
      local GoodsGrid = nx_value("GoodsGrid")
      GoodsGrid:GridClear(form.grid_photo)
      form.grid_photo:AddItem(0, nx_string(photo), 0, 1, -1)
      form.grid_photo:SetItemMark(0, nx_int(-1))
      form.grid_photo.item_name_old = skill_id_old
      form.lbl_level.Text = nx_widestr("")
    else
      set_grid_data(form.grid_photo, skill, VIEWPORT_SKILL)
      form.grid_photo.item_name_old = nil
    end
    form.btn_faculty_on.Enabled = false
    form.btn_ext_faculty_on.Enabled = false
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(29871)) then
    form.btn_ext_faculty_on.Visible = false
    form.btn_ext_faculty.Visible = false
  end
  form.gbox_info.Visible = true
  show_new_body_skill(form, nx_string(skill_id))
end
function get_wuxue_gl_name(form)
  if not nx_is_valid(form) then
    return ""
  end
  local g_TaoLuu_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\school_taolu.ini")
  if not nx_is_valid(g_TaoLuu_ini) then
    return ""
  end
  local sel_node = form.tree_types.SelectNode
  if not nx_is_valid(sel_node) then
    return ""
  end
  if not nx_find_custom(sel_node, "type_name") then
    return ""
  end
  local type_name = nx_string(sel_node.type_name)
  local sec_index = g_TaoLuu_ini:FindSectionIndex(nx_string(type_name))
  if sec_index < 0 then
    return ""
  end
  local data = g_TaoLuu_ini:ReadString(sec_index, "help", "")
  return data
end
function get_skill_powerlevel(skill_id)
  local ini = nx_execute("util_functions", "get_ini", SKILL_POWER_INI)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(skill_id))
  if sec_index < 0 then
    return 0
  end
  local powerlevel = ini:ReadInteger(sec_index, "r", 0)
  if powerlevel == nil then
    return 0
  end
  return powerlevel
end
function creat_level_photo(level)
  local gui = nx_value("gui")
  local grp = gui:Create("GroupBox")
  grp:DeleteAll()
  grp.LineColor = "0,0,0,0"
  grp.BackColor = "0,0,0,0"
  grp.Transparent = true
  grp.Width = 120
  grp.Height = 40
  if nx_int(level) <= nx_int(0) or nx_int(level) > nx_int(20) then
    return grp
  end
  local onelevel = nx_int((level + 1) / 2)
  for i = 1, nx_number(onelevel) do
    local lbl = gui:Create("Label")
    lbl.Left = i * 18
    lbl.Top = 16
    lbl.AutoSize = true
    lbl.BackImage = "gui\\special\\wuxue-gonglue\\skillstar_001.png"
    if nx_int(i) == nx_int(onelevel) and nx_int(level) == nx_int(nx_int(level / 2) * 2 + 1) then
      lbl.BackImage = "gui\\special\\wuxue-gonglue\\skillstar_002.png"
    end
    if 5 < i then
      lbl.Top = 32
      lbl.Left = (i - 5) * 18
      grp.Top = lbl.Top - 40
      grp.Width = 120
      grp.Height = 80
    end
    grp:Add(lbl)
  end
  return grp
end
function refresh_skill_count_pbar(form)
  if not nx_is_valid(form) then
    return 0
  end
  form.pbar_skill_count.Value = get_learn_skill_count()
end
function on_server_msg(...)
  local form = nx_value(FORM_WUXUE_MAIN)
  if not nx_is_valid(form) then
    return 0
  end
  local skill_form = nx_value(FORM_WUXUE_SKILL)
  if not nx_is_valid(skill_form) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local msg_sub_type = arg[1]
  if msg_sub_type == SERVER_MSG_FORGET_INFO then
    if 1 >= table.getn(arg) then
      return 0
    end
    local count = (table.getn(arg) - 1) / 2
    for i = 1, count do
      local static_data = arg[2 + (i - 1) * 2]
      local level = arg[3 + (i - 1) * 2]
      skill_data_manager:SetForgetSkill(nx_int(static_data), nx_int(level))
    end
  elseif msg_sub_type == SERVER_MSG_REQUST_OVER then
    skill_form.lbl_connect.Visible = false
    skill_form.ani_connect.Visible = false
    refresh_forget_type_data(skill_form)
  elseif msg_sub_type == SERVER_MSG_DEL_FORGET_SKILL then
    if table.getn(arg) < 2 then
      return 0
    end
    local static_data = arg[2]
    skill_data_manager:RemoveForgetSkill(nx_int(static_data))
    refresh_forget_type_data(skill_form)
  elseif msg_sub_type == SERVER_MSG_ADD_FORGET_SKILL then
    if table.getn(arg) < 3 then
      return 0
    end
    local static_data = arg[2]
    local level = arg[3]
    skill_data_manager:SetForgetSkill(nx_int(static_data), nx_int(level))
    refresh_forget_type_data(skill_form)
  end
end
function on_tree_types_forget_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not set_node_select(self, cur_node, pre_node) then
    return 0
  end
  refresh_forget_item_data(form)
end
function on_btn_select_forget_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  select_one_forget_item(form, btn.DataSource)
end
function set_forget_item_color(form, index, is_selected)
  local gbox_item = form.gpsb_items_forget:Find("gbox_item_forget_" .. nx_string(index))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local lbl_name = gbox_item:Find("lbl_name_forget_" .. nx_string(index))
  if not nx_is_valid(lbl_name) then
    return 0
  end
  local btn_select = gbox_item:Find("btn_select_forget_" .. nx_string(index))
  if not nx_is_valid(btn_select) then
    return 0
  end
  if is_selected then
    lbl_name.ForeColor = nx_string(FORE_COLOR_SELECT)
    btn_select.BackImage = "gui\\special\\wuxue\\form_back\\bjk.png"
  else
    lbl_name.ForeColor = nx_string(FORE_COLOR_NORMAL)
    btn_select.BackImage = ""
  end
end
function select_one_forget_item(form, sel_item_index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local gbox_item = form.gpsb_items_forget:Find(nx_string("gbox_item_forget_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_forget_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return 0
  end
  set_forget_item_color(form, form.sel_forget_item_index, false)
  form.sel_forget_item_index = nx_number(sel_item_index)
  set_forget_item_color(form, form.sel_forget_item_index, true)
  if not nx_find_custom(btn_select, "item_name") then
    return 0
  end
  refresh_forget_skill_data(form, btn_select.item_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  if btn_select.item_name ~= "" and form.gbox_forget_info.Visible then
    show_item_action(form, btn_select.item_name, WUXUE_SHOW_SKILL, true)
    add_weapon(form, btn_select.item_name)
  end
end
function clear_forget_skill_data(form)
  form.lbl_name_forget.Text = nx_widestr("")
  form.lbl_level_forget.Text = nx_widestr("")
  form.mltbox_desc_forget:Clear()
  form.grid_photo_forget:Clear()
  form.grid_photo_forget:SetSelectItemIndex(-1)
end
function refresh_forget_skill_data(form, skill_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  clear_forget_skill_data(form)
  form.lbl_name_forget.Text = gui.TextManager:GetText(nx_string(skill_id))
  form.mltbox_desc_forget:AddHtmlText(nx_widestr(gui.TextManager:GetText("desc_" .. skill_id)), -1)
  form.btn_recall_skill.DataSource = skill_id
  form.btn_clear_forget_skill_level.DataSource = skill_id
  if skill_id ~= "" then
    local effect_type = nx_execute("util_static_data", "skill_static_query_by_id", skill_id, "EffectType")
    local photo = nx_execute("util_static_data", "skill_static_query_by_id", skill_id, "Photo")
    form.grid_photo_forget:SetItemMark(0, nx_int(effect_type))
    form.grid_photo_forget:AddItem(0, nx_string(photo), 0, 1, -1)
    form.grid_photo_forget.DataSource = skill_id
    form.grid_photo_forget.MaxLevel = nx_number(skill_data_manager:GetForgetSkillLevel(skill_id))
  end
end
function refresh_forget_type_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local root = form.tree_types_forget:CreateRootNode(nx_widestr(""))
  local learned_tl_count = 0
  local sel_type_node
  form.gpsb_items_forget:DeleteAll()
  form.tree_types_forget:BeginUpdate()
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local type_node
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      if check_taolu_is_forget(sub_type_name) then
        if not nx_is_valid(type_node) then
          type_node = root:CreateNode(gui.TextManager:GetText(type_name))
          set_node_prop2(type_node, 1)
        end
        local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(sub_type_name))
        if nx_is_valid(sub_type_node) then
          sub_type_node.type_name = sub_type_name
          set_node_prop2(sub_type_node, 2)
        end
        if nx_find_custom(form, "type_name") and nx_string(form.type_name) == nx_string(sub_type_name) then
          sel_type_node = sub_type_node
        end
      end
    end
  end
  learned_tl_count = skill_data_manager:GetForgetSkillCount()
  form.lbl_tlcount_forget.Text = nx_widestr(learned_tl_count)
  if learned_tl_count == 0 then
    form.gbox_skill_forget.Visible = false
  else
    form.gbox_skill_forget.Visible = true
  end
  if nx_is_valid(sel_type_node) then
    form.tree_types_forget.SelectNode = sel_type_node
  else
    auto_select_first(form.tree_types_forget)
  end
  root.Expand = true
  form.tree_types_forget:EndUpdate()
end
function refresh_forget_item_data(form)
  local gui = nx_value("gui")
  local sel_node = form.tree_types_forget.SelectNode
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
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
  end
  form.gpsb_items_forget.IsEditMode = true
  form.gpsb_items_forget:DeleteAll()
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, sel_node.type_name)
  local index = 1
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    local result = skill_data_manager:CheckForgetSkill(item_name)
    if result then
      local groupbox = create_ctrl("GroupBox", "gbox_item_forget_" .. nx_string(index), form.gbox_item_forget_templete, form.gpsb_items_forget)
      if nx_is_valid(groupbox) then
        local lbl_line_forget = create_ctrl("Label", "lbl_line_forget_" .. nx_string(index), form.lbl_line_forget_templete, groupbox)
        local btn_select_forget = create_ctrl("Button", "btn_select_forget_" .. nx_string(index), form.btn_select_forget_templete, groupbox)
        local grid_photo_forget = create_ctrl("ImageGrid", "grid_photo_forget_" .. nx_string(index), form.grid_photo_forget_templete, groupbox)
        local lbl_name_forget = create_ctrl("Label", "lbl_name_forget_" .. nx_string(index), form.lbl_name_forget_templete, groupbox)
        local lbl_level_forget = create_ctrl("Label", "lbl_level_forget_" .. nx_string(index), form.lbl_level_forget_templete, groupbox)
        lbl_name_forget.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(item_name)))
        local effect_type = nx_execute("util_static_data", "skill_static_query_by_id", item_name, "EffectType")
        local photo = nx_execute("util_static_data", "skill_static_query_by_id", item_name, "Photo")
        grid_photo_forget:SetItemMark(0, nx_int(effect_type))
        grid_photo_forget:AddItem(0, nx_string(photo), 0, 1, -1)
        grid_photo_forget.DataSource = nx_string(item_name)
        grid_photo_forget.MaxLevel = max_level
        nx_bind_script(grid_photo_forget, nx_current())
        nx_callback(grid_photo_forget, "on_get_capture", "on_grid_photo_forget_get_capture")
        nx_callback(grid_photo_forget, "on_lost_capture", "on_grid_photo_forget_lost_capture")
        nx_bind_script(btn_select_forget, nx_current())
        nx_callback(btn_select_forget, "on_click", "on_btn_select_forget_click")
        btn_select_forget.DataSource = nx_string(index)
        btn_select_forget.item_name = nx_string(item_name)
        index = index + 1
      end
    end
  end
  form.gpsb_items_forget.IsEditMode = false
  form.gpsb_items_forget:ResetChildrenYPos()
  if 1 < index then
    select_one_forget_item(form, 1)
  end
end
function on_btn_forget_skill_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if btn.DataSource == "" then
    return 0
  end
  local data_source = btn.DataSource
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return 0
  end
  local text = nx_widestr("")
  gui.TextManager:Format_SetIDName("ui_wuxue_forget_skill_2")
  gui.TextManager:Format_AddParam(nx_int(50000))
  text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_forget_skill_msg", CLIENT_MSG_FORGET_SKILL, data_source)
  elseif res == "cancel" then
  else
    return 0
  end
end
function on_btn_clear_level_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if btn.DataSource == "" then
    return 0
  end
  local static_data = get_skill_static_data(btn.DataSource)
  if static_data == 0 then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return 0
  end
  local text = nx_widestr("")
  gui.TextManager:Format_SetIDName("ui_wuxue_forget_skill_3")
  text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_forget_skill_msg", CLIENT_MSG_CLEAR_LEVEL, static_data)
  elseif res == "cancel" then
  else
    return 0
  end
end
function on_btn_recall_skill_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  if btn.DataSource == "" then
    return 0
  end
  local static_data = get_skill_static_data(btn.DataSource)
  if static_data == 0 then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return 0
  end
  gui.TextManager:Format_SetIDName("ui_wuxue_forget_skill_1")
  local text = gui.TextManager:Format_GetText()
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_send_forget_skill_msg", CLIENT_MSG_RECALL_SKILL, static_data)
  elseif res == "cancel" then
  else
    return 0
  end
end
function on_grid_photo_forget_get_capture(grid)
  local config_id = grid.DataSource
  local ITEMTYPE_ZHAOSHI = 1000
  if config_id ~= "" then
    local IniManager = nx_value("IniManager")
    local ini = IniManager:LoadIniToManager("share\\Skill\\skill_new.ini")
    if not nx_is_valid(ini) then
      return
    end
    local index = ini:FindSectionIndex(nx_string(config_id))
    if nx_number(index) < 0 then
      return
    end
    local static_data = ini:ReadString(index, "StaticData", "")
    local item_data = nx_execute("tips_game", "get_tips_ArrayList")
    item_data.ConfigID = nx_string(config_id)
    item_data.ItemType = nx_int(ITEMTYPE_ZHAOSHI)
    item_data.Level = 1
    item_data.MaxLevel = grid.MaxLevel
    item_data.StaticData = nx_int(static_data)
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local row = client_player:FindRecordRow("ForgetSkillRec", 0, nx_int(static_data))
    if 0 <= row then
      item_data.Level = math.max(1, client_player:QueryRecord("ForgetSkillRec", row, 2))
      item_data.MaxLevel = client_player:QueryRecord("ForgetSkillRec", row, 1)
    end
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
end
function on_grid_photo_forget_lost_capture(grid)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function get_skill_static_data(skill_id)
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager("share\\Skill\\skill_new.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex(nx_string(skill_id))
  if 0 > nx_number(index) then
    return 0
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  if static_data ~= "" then
    return nx_number(static_data)
  end
  return 0
end
function get_forget_condition_id()
  local ini = nx_execute("util_functions", "get_ini", SKILL_FORGET_INI)
  if not nx_is_valid(ini) then
    return 0
  end
  local sec_index = ini:FindSectionIndex("forget_skill")
  if sec_index < 0 then
    return 0
  end
  local condition_id = ini:ReadInteger(sec_index, "ConditionID", 0)
  if condition_id == nil then
    return 0
  end
  return condition_id
end
function hide_wuji_btn(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 20 do
    local gbox_item = form.gpsb_items:Find("gbox_item_" .. i)
    if not nx_is_valid(gbox_item) then
      break
    end
    local btn_wuji = gbox_item:Find("btn_wuji_" .. i)
    if nx_is_valid(btn_wuji) then
      btn_wuji.Visible = false
    end
  end
end
function is_exist_wuji(form, skill_id)
  if not nx_is_valid(form) then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return false
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return false
  end
  local func_manager = nx_value("func_manager")
  if not nx_is_valid(func_manager) then
    return false
  end
  local sec_index = ini:FindSectionIndex("wuji_skill")
  if sec_index < 0 then
    return false
  end
  local wuji_index_str = ini:ReadString(sec_index, nx_string(skill_id), "")
  local wuji_index_tab = util_split_string(nx_string(wuji_index_str), ",")
  local rec_count = table.getn(wuji_index_tab)
  if nx_int(rec_count) > nx_int(0) then
    return true
  end
  return false
end
function is_activate_wuji(wuji_index)
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return false
  end
  local func_manager = nx_value("func_manager")
  if not nx_is_valid(func_manager) then
    return false
  end
  local wuji_count = skill_data_manager:GetActivateWuJiCount()
  if wuji_count <= 0 then
    return false
  end
  local wuji_index = nx_number(wuji_index)
  if 0 < wuji_index then
    local in_col = nx_int((wuji_index - 1) % WUJI_PER_ROW_BIT + 1)
    local in_row = nx_int((wuji_index - 1) / WUJI_PER_ROW_BIT)
    local rec_value = skill_data_manager:GetActivateWuJi(in_row)
    local result = func_manager:Check32BitFlag(rec_value, in_col)
    if 0 < result then
      return true
    end
  end
end
function is_learn_wuji(wuji_index)
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return false
  end
  local func_manager = nx_value("func_manager")
  if not nx_is_valid(func_manager) then
    return false
  end
  local wuji_count = skill_data_manager:GetLearnWuJiCount()
  if wuji_count <= 0 then
    return false
  end
  local wuji_index = nx_number(wuji_index)
  if 0 < wuji_index then
    local in_col = nx_int((wuji_index - 1) % WUJI_PER_ROW_BIT + 1)
    local in_row = nx_int((wuji_index - 1) / WUJI_PER_ROW_BIT)
    local rec_value = skill_data_manager:GetLearnWuJi(in_row)
    local result = func_manager:Check32BitFlag(rec_value, in_col)
    if 0 < result then
      return true
    end
  end
end
function get_wuji_action(wuji_ini, wuji_index)
  local sec_index = wuji_ini:FindSectionIndex("wuji_action")
  if sec_index < 0 then
    return ""
  end
  local wuji_info_str = wuji_ini:ReadString(sec_index, nx_string(wuji_index), "")
  local wuji_info_tab = util_split_string(nx_string(wuji_info_str), ",")
  local rec_count = table.getn(wuji_info_tab)
  if rec_count < 2 then
    return ""
  end
  return wuji_info_tab[3]
end
function get_activate_wuji_action(form, skill_id)
  local func_manager = nx_value("func_manager")
  if not nx_is_valid(func_manager) then
    return ""
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return ""
  end
  local wuji_count = skill_data_manager:GetLearnWuJiCount()
  if wuji_count <= 0 then
    return ""
  end
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex("wuji_skill")
  if sec_index < 0 then
    return ""
  end
  local ini_act = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_ACT)
  if not nx_is_valid(ini_act) then
    return ""
  end
  form.wuji_skill_id = nx_string(skill_id)
  local wuji_index_str = ini:ReadString(sec_index, nx_string(skill_id), "")
  local wuji_index_tab = util_split_string(nx_string(wuji_index_str), ",")
  local rec_count = table.getn(wuji_index_tab)
  for i = 1, rec_count do
    local wuji_index = nx_number(wuji_index_tab[i])
    if 0 < wuji_index then
      local in_row = nx_int((wuji_index - 1) / WUJI_PER_ROW_BIT)
      local in_col = nx_int((wuji_index - 1) % WUJI_PER_ROW_BIT + 1)
      if in_row < nx_int(wuji_count) then
        local rec_value = skill_data_manager:GetLearnWuJi(in_row)
        local result = func_manager:Check32BitFlag(rec_value, in_col)
        if 0 < result and is_activate_wuji(wuji_index) then
          return get_wuji_action(ini_act, wuji_index)
        end
      end
    end
  end
  return ""
end
function refresh_skill_wuji_info(form, skill_id)
  local func_manager = nx_value("func_manager")
  if not nx_is_valid(func_manager) then
    return false
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI)
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex("wuji_skill")
  if sec_index < 0 then
    return false
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return false
  end
  local learn_sec_index = ini_info:FindSectionIndex("wuji_learn")
  if learn_sec_index < 0 then
    return false
  end
  form.wuji_skill_id = nx_string(skill_id)
  local wuji_index_str = ini:ReadString(sec_index, nx_string(skill_id), "")
  local wuji_index_tab = util_split_string(nx_string(wuji_index_str), ",")
  local rec_count = table.getn(wuji_index_tab)
  form.imagegrid_wuji_1:Clear()
  form.imagegrid_wuji_2:Clear()
  form.imagegrid_wuji_replace:Clear()
  local grid_index_1 = 0
  local grid_index_2 = 0
  local grid_index_3 = 0
  for i = 1, rec_count do
    local wuji_index = nx_number(wuji_index_tab[i])
    if 0 < wuji_index then
      local is_learn = 0
      if is_learn_wuji(wuji_index) then
        is_learn = 1
      end
      local wuji_name = get_wuji_name_by_index(ini_info, wuji_index)
      local wear_type = get_wuji_wear_type_by_index(ini_info, wuji_index)
      if wear_type == 1 then
        add_wuji(form, ini, wuji_index, wuji_name, wear_type, grid_index_1, is_learn)
        grid_index_1 = grid_index_1 + 1
      elseif wear_type == 2 then
        add_wuji(form, ini, wuji_index, wuji_name, wear_type, grid_index_2, is_learn)
        grid_index_2 = grid_index_2 + 1
      elseif wear_type == 3 then
        add_wuji(form, ini, wuji_index, wuji_name, wear_type, grid_index_3, is_learn)
        grid_index_3 = grid_index_3 + 1
      end
    end
  end
  refresh_wuji_activate_Status()
end
function refresh_wuji_activate_Status()
  local skill_form = nx_value(FORM_WUXUE_SKILL)
  if not nx_is_valid(skill_form) then
    return
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return
  end
  local grid = skill_form.imagegrid_wuji_replace
  local max_size = grid.MaxSize
  for i = 1, max_size do
    local pic = skill_form.groupbox_wuji:Find("lbl_empty_" .. nx_string(i))
    if nx_is_valid(pic) then
      pic.Visible = false
    end
  end
  for i = 1, max_size do
    local wuji_index = nx_number(grid:GetItemName(i - 1))
    if 0 < wuji_index and is_activate_wuji(wuji_index) then
      local pic = skill_form.groupbox_wuji:Find("lbl_empty_" .. nx_string(i))
      if nx_is_valid(pic) then
        pic.Visible = true
      end
    end
  end
end
function refresh_skill_wuji_status()
  local form = nx_value(FORM_WUXUE_SKILL)
  if not nx_is_valid(form) then
    return
  end
  show_item_data(form)
  if form.wuji_skill_id ~= "" then
    refresh_skill_wuji_info(form, form.wuji_skill_id)
  end
end
function add_wuji(form, ini, wuji_index, wuji_name, wear_type, grid_index, is_learn)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(ini) then
    return false
  end
  local photo_sec_index = ini:FindSectionIndex("combo")
  if photo_sec_index < 0 then
    return false
  end
  local wuji_photo = ini:ReadString(photo_sec_index, nx_string(wuji_name), "")
  if wear_type == 1 then
    form.imagegrid_wuji_1:AddItem(grid_index, nx_string(wuji_photo), nx_widestr(wuji_index), 1, -1)
    if 0 < is_learn then
      form.imagegrid_wuji_1:ChangeItemImageToBW(grid_index, false)
    else
      form.imagegrid_wuji_1:ChangeItemImageToBW(grid_index, true)
    end
  elseif wear_type == 2 then
    form.imagegrid_wuji_2:AddItem(grid_index, nx_string(wuji_photo), nx_widestr(wuji_index), 1, -1)
    if 0 < is_learn then
      form.imagegrid_wuji_2:ChangeItemImageToBW(grid_index, false)
    else
      form.imagegrid_wuji_2:ChangeItemImageToBW(grid_index, true)
    end
  elseif wear_type == 3 then
    form.imagegrid_wuji_replace:AddItem(grid_index, nx_string(wuji_photo), nx_widestr(wuji_index), 1, -1)
    if 0 < is_learn then
      form.imagegrid_wuji_replace:ChangeItemImageToBW(grid_index, false)
    else
      form.imagegrid_wuji_replace:ChangeItemImageToBW(grid_index, true)
    end
  end
end
function show_wuji_info(form, item_index)
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(item_index)))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local btn_wuji = gbox_item:Find(nx_string("btn_wuji_" .. nx_string(item_index)))
  if not nx_is_valid(btn_wuji) then
    return 0
  end
  select_one_item(form, btn_wuji.DataSource)
  refresh_skill_wuji_info(form, btn_wuji.item_name)
  if btn_wuji.Visible then
    switch_skill_groupbox(form, 2)
  else
    switch_skill_groupbox(form, 1)
  end
end
function on_btn_wuji_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  select_one_item(form, btn.DataSource)
  switch_skill_groupbox(form, 2)
  refresh_skill_wuji_info(form, btn.item_name)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_imagegrid_wuji_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local photo = grid:GetItemImage(index)
  local wuji_index = nx_number(grid:GetItemName(index))
  if not is_learn_wuji(wuji_index) then
    return
  end
  if wuji_index ~= 0 then
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", "auto_wuji_drop_in", nx_number(grid.DataSource), photo, wuji_index)
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_imagegrid_wuji_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  if gui.GameHand:IsEmpty() then
    local photo = grid:GetItemImage(index)
    local wuji_index = nx_string(grid:GetItemName(index))
    if is_learn_wuji(wuji_index) then
      gui.GameHand:SetHand(GHT_COMBO, photo, photo, wuji_index, "", "")
      gui.GameHand.IsDropped = false
    end
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", "show_empty_pic", nx_number(wuji_index))
  end
end
function on_imagegrid_wuji_drag_enter(grid, index)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local game_hand = gui.GameHand
    game_hand.IsDragged = false
    game_hand.IsDropped = false
  end
end
function on_imagegrid_wuji_drag_move(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local gamehand = gui.GameHand
  if not gamehand.IsDragged then
    local photo = grid:GetItemImage(index)
    local wuji_index = nx_string(grid:GetItemName(index))
    if is_learn_wuji(wuji_index) then
      gamehand.IsDragged = true
      gui.GameHand:SetHand(GHT_COMBO, photo, photo, wuji_index, "", "")
    end
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", "show_empty_pic", nx_number(wuji_index))
  end
end
function on_imagegrid_wuji_mousein_grid(grid, index)
  show_wuji_tips(grid, index)
end
function on_imagegrid_wuji_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_wuji_replace_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wuji_index = nx_number(grid:GetItemName(index))
  if not is_learn_wuji(wuji_index) then
    return
  end
  if 0 < wuji_index and is_activate_wuji(wuji_index) then
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_CANCEL, wuji_index)
  else
    nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_WUJI_ACTIVATE, wuji_index)
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function show_wuji_tips(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local ini_info = nx_execute("util_functions", "get_ini", INI_SHARE_WUJI_INFO)
  if not nx_is_valid(ini_info) then
    return false
  end
  local wuji_index = nx_number(grid:GetItemName(index))
  if wuji_index == 0 then
    return
  end
  local name = get_wuji_name_by_index(ini_info, wuji_index)
  local item_data = nx_execute("tips_game", "get_tips_ArrayList")
  item_data.ConfigID = nx_string(name)
  item_data.ItemType = nx_int(ITEMTYPE_WUJI)
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function switch_skill_groupbox(form, gb_type)
  if form.last_gb_type == gb_type then
    return 0
  end
  if gb_type == 1 then
    form.groupbox_wuji.Visible = false
    form.gbox_forget_info.Visible = false
    form.gbox_forget_list.Visible = false
    form.gbox_list.Visible = true
    form.gbox_skill.Visible = true
    form.scenebox_show.Visible = true
    form.lbl_name.Visible = true
  elseif gb_type == 2 then
    form.gbox_skill.Visible = false
    form.scenebox_show.Visible = false
    form.gbox_forget_info.Visible = false
    form.gbox_forget_list.Visible = false
    form.gbox_list.Visible = true
    form.groupbox_wuji.Visible = true
    form.lbl_name.Visible = false
  elseif gb_type == 3 then
    form.groupbox_wuji.Visible = false
    form.gbox_forget_info.Visible = true
    form.gbox_forget_list.Visible = true
    form.gbox_list.Visible = false
    form.gbox_skill.Visible = false
    form.scenebox_show.Visible = true
    form.lbl_name.Visible = true
  end
  form.last_gb_type = gb_type
end
function on_btn_wuji_back_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  switch_skill_groupbox(form, 1)
end
function on_cbtn_1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    game_config.show_unknown_skill = cbtn.Checked
  end
  show_type_data(form)
end
function set_unknown_prop(taolu_node)
  if not nx_is_valid(taolu_node) then
    return
  end
  taolu_node.unknown = 1
  for prop_name, value in pairs(UNKNOWN_NODE) do
    nx_set_property(taolu_node, nx_string(prop_name), value)
  end
end
function on_btn_1_click(btn)
  local form = btn.ParentForm
  local sel_item_index = form.sel_item_index
  local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(sel_item_index)))
  if not nx_is_valid(gbox_item) then
    return
  end
  local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(sel_item_index)))
  if not nx_is_valid(btn_select) then
    return
  end
  if not nx_find_custom(btn_select, "item_name") then
    return
  end
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_show_skill", "on_show_form", btn_select.item_name)
end
function show_unknown_taolu(power_lv, taolu_id)
  local lv = get_taolu_quality(taolu_id)
  if lv <= 0 then
    return false
  end
  if power_lv <= 6 then
    if lv <= 2 then
      return true
    end
  elseif 6 < power_lv and power_lv < 21 then
    if lv <= 3 then
      return true
    end
  elseif 21 <= power_lv then
  end
  return true
end
function get_taolu_quality(taolu_id)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return 0
  end
  local lv = 0
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, nx_string(taolu_id))
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    lv = faculty_query:GetQuality(nx_string(item_name))
  end
  return lv
end
function show_new_body_skill(form, skill_id)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local bShow = wuxue_query:IsBodyAddSkill(skill_id)
  local btn = form.btn_bodysize
  if bShow then
    local sex = client_player:QueryProp("Sex")
    local body_type = 0
    if sex == 0 then
      body_type = 4
    else
      body_type = 3
    end
    local bset = false
    local btn_photo = wuxue_query:GetBodyBtn(body_type)
    if btn_photo ~= "" then
      local table_photo = util_split_string(btn_photo, ";")
      if 3 <= table.getn(table_photo) then
        btn.NormalImage = table_photo[1]
        btn.FocusImage = table_photo[2]
        btn.PushImage = table_photo[3]
        bset = true
      end
    end
    bShow = bset
  end
  btn.Visible = bShow
end
function on_btn_bodysize_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_attire\\form_attire_body_desc")
end
function on_btn_set_click(btn)
  nx_execute("custom_sender", "custom_taosha", nx_int(14))
end
function rec_skill_yushe_info(...)
  local form_skill = nx_value(FORM_WUXUE_SKILL)
  if not nx_is_valid(form_skill) then
    return
  end
  local tree = form_skill.tree_types
  if not nx_is_valid(tree) then
    return nil
  end
  local select_node = tree.SelectNode
  if select_node == nil then
    return
  end
  local strWuXue = select_node.type_name
  if nx_string(strWuXue) == nx_string("") or strWuXue == nil then
    return
  end
  if nx_string(strWuXue) == nx_string("skill_changyon_sjm") or nx_string(strWuXue) == nx_string("CS_jh_cqgf") then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("yuxuan_systeminfo_10007"), 2)
    end
    return
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "show_skill_yu_xaun_gbox")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "synchro_shortcut_index")
  nx_execute("custom_sender", "custom_taosha", nx_int(11), nx_string(strWuXue))
end
function on_btn_cover_click(btn)
  local form_main_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local lbl_page = form_main_shortcut.lbl_page
  if not nx_is_valid(lbl_page) then
    return
  end
  local gbox = form_main_shortcut.groupbox_skill_4
  if not gbox.Visible then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("yuxuan_systeminfo_10008"), 2)
    end
    return
  end
  local nPage = nx_string(nx_int(lbl_page.Text) - 1)
  local grid = form_main_shortcut.imagegrid_1
  if not nx_is_valid(grid) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local nLearned = 0
  local strTotal = nPage .. ","
  for i = 0, 9 do
    local strSkill = nx_string(grid:GetItemName(i))
    local skill_view = wuxue_query:GetLearnID_Skill(strSkill)
    if not nx_is_valid(skill_view) then
      strSkill = ""
    else
      nLearned = nLearned + 1
    end
    if i ~= 9 then
      strTotal = strTotal .. strSkill .. ","
    else
      strTotal = strTotal .. strSkill
    end
  end
  if nLearned <= 0 then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_yuxuan_reset_faile"), 2)
    end
    return
  end
  nx_execute("custom_sender", "custom_taosha", nx_int(13), strTotal)
end
function rec_taolu_info(...)
  if nx_int(#arg) < nx_int(2) then
    return
  end
  local strTaoLu = nx_string(arg[1])
  if strTaoLu == "" or strTaoLu == nil then
    return
  end
  local form_main_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_main_shortcut) then
    return
  end
  local grid = form_main_shortcut.imagegrid_1
  if not nx_is_valid(grid) then
    return
  end
  grid.SelectTaoLu = strTaoLu
  grid:Clear()
  clear_cover_image(grid)
  if nx_int(arg[2]) == nx_int(1) then
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, strTaoLu)
    for i = 1, #item_tab do
      if item_tab[i] ~= "" and item_tab[i] ~= nil then
        set_skill_to_grid(grid, nx_string(item_tab[i]), i)
      end
    end
  elseif nx_int(arg[2]) == nx_int(2) then
    for j = 3, #arg do
      if nx_string(arg[j]) ~= "" and nx_string(arg[j]) ~= nil then
        set_skill_to_grid(grid, nx_string(arg[j]), nx_int(j - 2))
      end
    end
  end
end
function set_skill_to_grid(grid, strSkill, index)
  set_cover_image(grid, strSkill, nx_int(index - 1))
  local photo = skill_static_query_by_id(strSkill, "Photo")
  grid:AddItem(index - 1, nx_string(photo), nx_widestr(""), nx_int(0), nx_int(0))
  grid:SetItemName(index - 1, nx_widestr(strSkill))
end
function set_cover_image(grid, strSkill, index)
  if not nx_is_valid(grid) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(9) then
    return
  end
  if nx_string(strSkill) == nx_string("") then
    return
  end
  local effect_type = nx_execute("util_static_data", "skill_static_query_by_id", strSkill, "EffectType")
  local strCoverImage = get_photo_by_effecttype(effect_type)
  if strCoverImage == "" then
    return
  end
  grid:SetItemCoverImage(index, strCoverImage)
  grid:CoverItem(index, true)
end
function get_photo_by_effecttype(nEffectType)
  local image = ""
  if nx_int(nEffectType) == nx_int(1) then
    image = "gui\\mainform\\icon_red_move.png"
  elseif nx_int(nEffectType) == nx_int(2) then
    image = "gui\\mainform\\icon_blue_move.png"
  elseif nx_int(nEffectType) == nx_int(3) then
    image = "gui\\mainform\\icon_green_move.png"
  end
  return image
end
function clear_cover_image(grid)
  for i = 0, 9 do
    grid:SetItemCoverImage(nx_int(i), "")
    grid:CoverItem(nx_int(i), false)
  end
end
