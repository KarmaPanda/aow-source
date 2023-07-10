require("faculty")
require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\gamehand_type")
require("share\\capital_define")
require("share\\itemtype_define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
require("form_stage_main\\puzzle_quest\\puzzle_effect_data")
local FILL_STATE = 1
local BREAK_STATE = 2
local prize_skill_count = 2
local cdtime1 = 500
local cdtime2 = 600
local WUXUE_VIEW = {
  [WUXUE_NEIGONG] = VIEWPORT_NEIGONG,
  [WUXUE_SKILL] = VIEWPORT_SKILL,
  [WUXUE_QGSKILL] = VIEWPORT_QINGGONG,
  [WUXUE_ZHENFA] = VIEWPORT_ZHENFA,
  [WUXUE_ANQI] = VIEWPORT_SHOUFA,
  [WUXUE_JINGMAI] = VIEWPORT_JINGMAI
}
local SUB_CLIENT_GEN_BEGIN = 31
local SUB_CLIENT_GEN_EXIT = 32
local g_wuxue_type = 0
local g_wuxue_name = ""
local MAX_SKILL_ONE_PAGE = 6
function main_form_init(self)
  self.Fixed = true
  self.faculty_state = 0
  self.cur_fill_state = 0
  self.select_skill_id = ""
  self.select_skill_index = 0
  self.select_skill_type = 0
  self.wuxue_type = g_wuxue_type
  self.wuxue_name = g_wuxue_name
  self.wuxue_ratio = 0
  self.wuxue_manual_value = 0
  self.direct = 0
  self.max_skill_page = 0
  self.cur_skill_page = 0
  self.isfaculty = false
  set_jm_diamond_ratio(self, nx_string(self.wuxue_name))
end
function on_main_form_open(self)
  self.lt_area.Visible = false
  self.gb_down.Visible = false
  self.gb_right.Visible = true
  self.imagegrid_skill.DragEnabled = true
  self.imagegrid_shortcut.DragEnabled = false
  local grid_count = self.imagegrid_shortcut.RowNum * self.imagegrid_shortcut.ClomnNum
  self.imagegrid_shortcut.beginindex = 150
  self.imagegrid_shortcut.endindex = self.imagegrid_shortcut.beginindex + grid_count - 1
  self.imagegrid_shortcut.page = 0
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CurGate", "int", self, nx_current(), "on_cur_gate_change")
  databinder:AddRolePropertyBind("CurLevel", "int", self, nx_current(), "on_cur_level_change")
  databinder:AddRolePropertyBind("CantFaculty", "int", self, nx_current(), "on_cant_faculty_change")
  databinder:AddRolePropertyBind("CurFillValue", "int", self, nx_current(), "on_cur_total_fill_value_change")
  databinder:AddRolePropertyBind("TotalFillValue", "int", self, nx_current(), "on_cur_total_fill_value_change")
  databinder:AddTableBind("shortcut_rec", self.imagegrid_shortcut, nx_current(), "on_shortcut_record_change")
  databinder:AddViewBind(VIEWPORT_TOOL, self.imagegrid_shortcut, nx_current(), "on_view_operat_main_shortcut")
  databinder:AddViewBind(VIEWPORT_EQUIP_TOOL, self.imagegrid_shortcut, nx_current(), "on_view_operat_main_shortcut")
  databinder:AddViewBind(VIEWPORT_MATERIAL_TOOL, self.imagegrid_shortcut, nx_current(), "on_view_operat_main_shortcut")
  databinder:AddViewBind(VIEWPORT_TASK_TOOL, self.imagegrid_shortcut, nx_current(), "on_view_operat_main_shortcut")
  databinder:AddViewBind(VIEWPORT_SKILL, self.imagegrid_shortcut, nx_current(), "on_view_operat_main_shortcut")
  local jewel_game_manager = nx_value("jewel_game_manager")
  jewel_game_manager:SendServerOperate(op_create)
  refresh_form(self)
  return
end
function on_main_form_close(self)
  local data_binder = nx_value("data_binder")
  data_binder:DelRolePropertyBind(self, "FacultyState")
  data_binder:DelRolePropertyBind(self, "CurLevel")
  data_binder:DelRolePropertyBind(self, "CurGate")
  data_binder:DelRolePropertyBind(self, "CurFillValue")
  data_binder:DelRolePropertyBind(self, "CurPlaceList")
  data_binder:DelRolePropertyBind(self, "CurGoldValue")
  data_binder:DelRolePropertyBind(self, "CurWoodValue")
  data_binder:DelRolePropertyBind(self, "CurWaterValue")
  data_binder:DelRolePropertyBind(self, "CurFireValue")
  data_binder:DelRolePropertyBind(self, "CurEarthValue")
  data_binder:DelRolePropertyBind(self, "CurDarkValue")
  data_binder:DelRolePropertyBind(self, "CurLightValue")
  data_binder:DelRolePropertyBind(self, "Faculty")
  data_binder:DelRolePropertyBind(self, "DiamondValue")
  data_binder:DelTableBind("shortcut_rec", self.imagegrid_shortcut)
  data_binder:DelViewBind(self)
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_GEN_EXIT, 0)
  nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "clear_jingmai_effect")
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  nx_destroy(self)
  nx_set_value(FORM_JINGMAI, nx_null())
end
function set_faculty_wuxue()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_type = client_player:QueryProp("FacultyType")
  local wuxue_name = client_player:QueryProp("FacultyName")
  g_wuxue_type = nx_int(wuxue_type)
  g_wuxue_name = nx_string(wuxue_name)
end
function on_msg_ready_faculty()
  set_faculty_wuxue()
  nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "init_jingmai_effect")
  nx_execute(FORM_PUZZLE_QUEST, "show_form", gem_game_type.gt_datongjingmai)
  nx_pause(2)
  form = nx_value(FORM_JINGMAI)
  if not nx_is_valid(form) then
    nx_msgbox(get_msg_str("msg_423"))
  end
  on_msg_begin_faculty(form)
  local helper_form = nx_value("helper_form")
  if helper_form then
    if not form.gb_down.Visible then
      form.gb_down.Visible = true
    end
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_msg_begin_faculty(form)
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("Faculty", "int", form, nx_current(), "on_faculty_change")
  databinder:AddRolePropertyBind("CurFillState", "int", form, nx_current(), "on_cur_fill_state_change")
  databinder:AddRolePropertyBind("DiamondValue", "int", form, nx_current(), "on_diamond_value_change")
  databinder:AddRolePropertyBind("CurPlaceList", "string", form, nx_current(), "on_cur_place_list_change")
  databinder:AddRolePropertyBind("CurGoldValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurWoodValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurWaterValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurFireValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurEarthValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurDarkValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurLightValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  databinder:AddRolePropertyBind("CurDirtyValue", "int", form, nx_current(), "on_cur_diamond_value_change")
  reflesh_skill_rec(form, 1)
  reflesh_shortcut(form)
end
function on_msg_exit_faculty(form)
  local form = nx_value(FORM_PUZZLE_QUEST)
  local self = nx_value(FORM_JINGMAI)
  if nx_is_valid(form) and form.Visible and self.isfaculty then
    form:Close()
  end
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local jewel_game_manager = nx_value("jewel_game_manager")
  local wuxue_id = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_id) then
    return
  end
  local photo = get_cur_wuxue_static_data(form, "Photo")
  form.imagegrid_xiuwei_photo:AddItem(0, nx_string(photo), 0, 1, -1)
  local configid = wuxue_id:QueryProp("ConfigID")
  local wuxue_name = gui.TextManager:GetFormatText(nx_string(configid))
  form.lbl_xiuwei_name.Text = nx_widestr(wuxue_name)
  local type = jewel_game_manager:GetJMWuXueType(nx_string(configid))
  local type_str = "ui_wuxue_prop_" .. nx_string(type)
  form.lbl_property.Text = nx_widestr(gui.TextManager:GetFormatText(type_str))
end
function show_fill_ball_process()
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  effect_jingmai:ShowBallEffect(0, 0, true)
end
function show_break_ball_process(break_lst)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  local b_first = true
  for i = 1, table.getn(break_lst) do
    if break_lst[i] ~= 0 then
      effect_jingmai:ShowBallEffect(1, i - 1, b_first)
      b_first = false
    end
  end
end
function refresh_place_list(form, place_string)
  if not nx_is_valid(form) then
    return 1
  end
  if place_string == nil then
    place_string = ""
  end
  if string.find(place_string, "1") ~= nil then
    form.btn_shan.Enabled = true
  else
    form.btn_shan.Enabled = false
  end
  if string.find(place_string, "2") ~= nil then
    form.btn_shui.Enabled = true
  else
    form.btn_shui.Enabled = false
  end
  if string.find(place_string, "3") ~= nil then
    form.btn_dong.Enabled = true
  else
    form.btn_dong.Enabled = false
  end
  if string.find(place_string, "4") ~= nil then
    form.btn_lin.Enabled = true
  else
    form.btn_lin.Enabled = false
  end
  if string.find(place_string, "5") ~= nil then
    form.btn_xue.Enabled = true
  else
    form.btn_xue.Enabled = false
  end
end
function on_btn_show_left_click(self)
  local form = nx_value(FORM_JINGMAI)
  form.lt_area.Visible = not form.lt_area.Visible
end
function on_btn_show_right_click(self)
  local form = nx_value(FORM_JINGMAI)
  form.gb_right.Visible = not form.gb_right.Visible
end
function on_btn_show_down_click(self)
  local form = nx_value(FORM_JINGMAI)
  form.gb_down.Visible = not form.gb_down.Visible
end
function on_btn_down_click(self)
  local form = nx_value(FORM_JINGMAI)
  if form.cur_skill_page == 1 then
    return
  end
  reflesh_skill_rec(form, form.cur_skill_page - 1)
  form.lbl_page.Text = nx_widestr(form.cur_skill_page) .. nx_widestr("/") .. nx_widestr(form.max_skill_page)
end
function on_btn_up_click(self)
  local form = nx_value(FORM_JINGMAI)
  if form.cur_skill_page == form.max_skill_page then
    return
  end
  reflesh_skill_rec(form, form.cur_skill_page + 1)
  form.lbl_page.Text = nx_widestr(form.cur_skill_page) .. nx_widestr("/") .. nx_widestr(form.max_skill_page)
end
function on_imagegrid_prize_skill_rightclick_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local form = nx_value(FORM_JINGMAI)
  local skill_name = self:GetItemName(index)
  use_jingmai_skill(skill_name, index, true)
end
function on_imagegrid_prize_skill_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local form = self.ParentForm
  local skill_name = self:GetItemName(index)
  nx_execute("tips_game", "show_tips_common", skill_name, 14, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), form)
end
function on_imagegrid_prize_skill_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_skill_rightclick_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local form = nx_value(FORM_JINGMAI)
  local skill_name = self:GetItemName(index)
  use_jingmai_skill(skill_name, index, false)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_imagegrid_skill_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  local form = self.ParentForm
  local skill_name = self:GetItemName(index)
  nx_execute("tips_game", "show_tips_common", skill_name, 14, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), form)
end
function on_imagegrid_skill_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_imagegrid_shortcut_drag_enter(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  game_hand.IsDragged = false
  game_hand.IsDropped = false
end
function on_imagegrid_shortcut_drag_move(self, index)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  if not game_hand.IsDragged then
    game_hand.IsDragged = true
  end
end
function on_imagegrid_shortcut_rightclick_grid(self, index)
  if self:IsEmpty(index) then
    local helper_form = nx_value("helper_form")
    if helper_form then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
    return
  end
  local beginindex = self.beginindex + self.page * (self.RowNum * self.ClomnNum)
  local row = nx_execute("shortcut_game", "get_shortcut_row_by_index", index + beginindex)
  local index2, para1, para2 = nx_execute("shortcut_game", "get_shortcut_info_by_row", row)
  local game_shortcut = nx_value("GameShortcut")
  if not nx_is_valid(game_shortcut) then
    return
  end
  local item = game_shortcut:FindItemInBagByUID(para2)
  if not nx_is_valid(item) then
    local helper_form = nx_value("helper_form")
    if helper_form then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
    return
  end
  local configid = nx_string(item:QueryProp("ConfigID"))
  use_jingmai_item(configid, index)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_imagegrid_shortcut_mousein_grid(self, index)
  if self:IsEmpty(index) then
    return
  end
  nx_execute("shortcut_game", "show_shortcut_tips", self, index)
end
function on_imagegrid_shortcut_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function set_jm_diamond_ratio(form, wuxue_id)
  local jewel_game_manager = nx_value("jewel_game_manager")
  form.jm_ratio1 = jewel_game_manager:GetJMWuXueGoldRatio(wuxue_id)
  form.jm_ratio2 = jewel_game_manager:GetJMWuXueWoodRatio(wuxue_id)
  form.jm_ratio3 = jewel_game_manager:GetJMWuXueWaterRatio(wuxue_id)
  form.jm_ratio4 = jewel_game_manager:GetJMWuXueFireRatio(wuxue_id)
  form.jm_ratio5 = jewel_game_manager:GetJMWuXueEarthRatio(wuxue_id)
  form.jm_ratio7 = jewel_game_manager:GetJMWuXueDarkRatio(wuxue_id)
  form.jm_ratio8 = jewel_game_manager:GetJMWuXueLightRatio(wuxue_id)
end
function get_cur_wuxue_id(form)
  if not nx_is_valid(form) then
    return nx_null()
  end
  if nx_int(form.wuxue_type) <= nx_int(0) or nx_int(form.wuxue_type) > nx_int(table.getn(WUXUE_VIEW)) or nx_string(form.wuxue_name) == nx_string("") then
    return nx_null()
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(WUXUE_VIEW[form.wuxue_type]))
  if not nx_is_valid(view) then
    return nx_null()
  end
  local view_lst = view:GetViewObjList()
  for _, wuxue_id in ipairs(view_lst) do
    local temp_name = wuxue_id:QueryProp("ConfigID")
    if nx_string(temp_name) == nx_string(form.wuxue_name) then
      return wuxue_id
    end
  end
  return nx_null()
end
function get_cur_wuxue_static_data(form, prop_name)
  if prop_name == nil or nx_string(prop_name) == nx_string("") then
    return
  end
  local wuxue_id = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_id) then
    return
  end
  local Data_Type
  local wuxue_type = nx_int(form.wuxue_type)
  if wuxue_type == nx_int(WUXUE_SKILL) then
    Data_Type = STATIC_DATA_SKILL_STATIC
  elseif wuxue_type == nx_int(WUXUE_NEIGONG) then
    Data_Type = STATIC_DATA_NEIGONG
  elseif wuxue_type == nx_int(WUXUE_QGSKILL) then
    Data_Type = STATIC_DATA_QGSKILL
  elseif wuxue_type == nx_int(WUXUE_ZHENFA) then
    Data_Type = STATIC_DATA_ZHENFA
  elseif wuxue_type == nx_int(WUXUE_JINGMAI) then
    Data_Type = STATIC_DATA_JINGMAI
  elseif wuxue_type == nx_int(WUXUE_ANQI) then
    Data_Type = STATIC_DATA_SHOUFA
  end
  if Data_Type == nil then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local staticdata = wuxue_id:QueryProp("StaticData")
  local prop = data_query:Query(nx_int(Data_Type), nx_int(staticdata), prop_name)
  return prop
end
function set_jingmai(wuxue_name, cur_fill_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local level = client_player:QueryProp("CurLevel")
  local next_gate = client_player:QueryProp("CurGate") + 1
  local jewel_game_manager = nx_value("jewel_game_manager")
  local max_fill_value = client_player:QueryProp("TotalFillValue")
  if max_fill_value <= 0 then
    max_fill_value = jewel_game_manager:GetFacultyGateFillValue(wuxue_name, level, next_gate)
  end
  local xuewei_name = jewel_game_manager:GetFacultyGateXueWeiName(wuxue_name, level, next_gate)
  local ratio = 1 - nx_float(cur_fill_value) / nx_float(max_fill_value)
  if ratio < 0 then
    ratio = 0
  end
  if 1 < ratio then
    ration = 1
  end
  nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "set_jingmai", "form_jingmai", xuewei_name, ratio)
end
function find_grid_item(grid, find_skill_id)
  local form = nx_value(FORM_JINGMAI)
  if not nx_is_valid(form) then
    return -1
  end
  if nx_id_equal(grid, form.imagegrid_shortcut) then
    if not nx_is_valid(grid) then
      return -1
    end
    local rows = grid.RowNum
    local cols = grid.ClomnNum
    local size = rows * cols
    for i = 1, size do
      local beginindex = grid.beginindex + grid.page * size
      local row = nx_execute("shortcut_game", "get_shortcut_row_by_index", i + beginindex - 1)
      local index2, para1, para2 = nx_execute("shortcut_game", "get_shortcut_info_by_row", row)
      local game_shortcut = nx_value("GameShortcut")
      if not nx_is_valid(game_shortcut) then
        return
      end
      local item = game_shortcut:FindItemInBagByUID(para2)
      if nx_is_valid(item) then
        local configid = nx_string(item:QueryProp("ConfigID"))
        if nx_string(configid) == nx_string(find_skill_id) then
          return i - 1
        end
      end
    end
  elseif nx_id_equal(grid, form.imagegrid_skill) then
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
    if not nx_is_valid(view) then
      return -1
    end
    local view_item = view:GetViewObj("1")
    local rows = view_item:GetRecordRows("TempGemSkillRec")
    for i = 0, rows - 1 do
      local skill_id = view_item:QueryRecord("TempGemSkillRec", i, 0)
      if skill_id == find_skill_id then
        return i
      end
    end
  end
  return -1
end
function set_fill_ball_process(value, max_value)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  local form = nx_value(FORM_JINGMAI)
  if form.cur_fill_state == FILL_STATE then
    effect_jingmai:SetBallRatio(0, 0, nx_number(value), nx_number(max_value))
  end
end
function set_break_ball_process(index, value, max_value)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return
  end
  local form = nx_value(FORM_JINGMAI)
  if form.cur_fill_state == BREAK_STATE then
    effect_jingmai:SetBallRatio(1, index - 1, nx_number(value), nx_number(max_value))
  end
end
function set_process(form, value, max_value, index)
  local visible = max_value ~= 0
  if visible then
    nx_set_custom(form, "break_max_value" .. nx_string(index), max_value)
    set_break_ball_process(index, value, max_value)
  end
end
function get_view_item(view_id, view_index)
  local game_client = nx_value("game_client")
  return game_client:GetViewObj(nx_string(view_id), nx_string(view_index))
end
function create_jingmai(wuxue_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local level = client_player:QueryProp("CurLevel")
  local jewel_game_manager = nx_value("jewel_game_manager")
  local get_count = jewel_game_manager:GetFacultyLevelMaxGate(wuxue_name, level)
  local xuewei_list = {}
  for i = 0, get_count - 1 do
    xuewei_list[i + 1] = jewel_game_manager:GetFacultyGateXueWeiName(wuxue_name, level, i)
  end
  nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "create_jingmai", "form_jingmai", unpack(xuewei_list))
end
function reflesh_shortcut(self)
  local goods_grid = nx_value("GoodsGrid")
  local game_client = nx_value("game_client")
  local item_list = goods_grid:GetItemsByItemType(ITEMTYPE_JM_FACULTY)
  local client_player = game_client:GetPlayer()
  for i = self.imagegrid_shortcut.beginindex, self.imagegrid_shortcut.endindex do
    nx_execute("shortcut_game", "remove_shortcut", i)
  end
  local index = self.imagegrid_shortcut.beginindex
  for key, item in pairs(item_list) do
    if index <= self.imagegrid_shortcut.endindex then
      local unique_id = nx_string(item:QueryProp("UniqueID"))
      local config_id = item:QueryProp("ConfigID")
      local faculty_quality = nx_number(nx_execute("tips_func_goods", "get_prop_in_ItemQuery", config_id, "FacultyQuality"))
      local cur_quality = client_player:QueryProp("CurQuality")
      if faculty_quality == cur_quality then
        nx_execute("shortcut_game", "set_shortcut", index, "item", unique_id)
        index = index + 1
      end
    end
  end
end
function reflesh_skill_rec(self, cur_page)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
  local view_item = view:GetViewObj("1")
  local rows = view_item:GetRecordRows("TempGemSkillRec")
  if rows <= 0 then
    return
  end
  local max_page = nx_int(nx_number(rows) / nx_number(MAX_SKILL_ONE_PAGE))
  local left_skill_count = math.mod(nx_number(rows), nx_number(MAX_SKILL_ONE_PAGE))
  if 0 < left_skill_count then
    max_page = max_page + 1
  end
  self.max_skill_page = max_page
  self.cur_skill_page = cur_page
  self.lbl_page.Text = nx_widestr(cur_page) .. nx_widestr("/") .. nx_widestr(max_page)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  local func_manager = nx_value("func_manager")
  local begin_index = MAX_SKILL_ONE_PAGE * (cur_page - 1)
  local end_index = MAX_SKILL_ONE_PAGE * cur_page - 1
  if begin_index > rows - 1 then
    return
  end
  if end_index > rows - 1 then
    end_index = rows - 1
  end
  self.imagegrid_skill:Clear()
  local jewel_game_manager = nx_value("jewel_game_manager")
  local index = 0
  for i = begin_index, end_index do
    local cd_time = view_item:QueryRecord("TempGemSkillRec", i, 1)
    if cd_time ~= cdtime1 and cd_time ~= cdtime2 then
      local skill_id = view_item:QueryRecord("TempGemSkillRec", i, 0)
      local photo = jewel_game_manager:GetJMPhoto(nx_string(skill_id))
      local name = nx_widestr(skill_id)
      self.imagegrid_skill:AddItem(nx_int(index), photo, name, nx_int(0), i)
      self.imagegrid_skill:SetCoolType(nx_int(index), nx_int(984125))
      index = index + 1
    end
  end
end
function use_jingmai_skill(para2, index, is_prize)
  local form = nx_value(FORM_JINGMAI)
  form.select_skill_id = nx_string(para2)
  form.select_skill_index = index
  local jewel_game_manager = nx_value("jewel_game_manager")
  form.select_skill_type = jewel_game_manager:GetJMNeedPos(form.select_skill_id)
  if form.select_skill_type ~= 0 then
    if is_prize then
      form.select_skill_type = 3
    else
      form.select_skill_type = 1
    end
  end
  if form.select_skill_type == 0 then
    on_use_jingmai_skill(para2, index)
    local gui = nx_value("gui")
  else
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("8040"), 2)
    end
    gui.GameHand:SetHand("diamond_skill", "Attack", 0, "", "", "")
  end
end
function on_use_jingmai_item(para2, index)
  local form = nx_value(FORM_JINGMAI)
  local self = form.imagegrid_shortcut
  local select_diamond_index = -1
  local puzzle_form = nx_value(FORM_PUZZLE_QUEST)
  if puzzle_form.src_select ~= nil then
    select_diamond_index = (puzzle_form.src_select.diamond_row - 1) * puzzle_form.max_row + puzzle_form.src_select.diamond_col - 1
  end
  local jewel_game_manager = nx_value("jewel_game_manager")
  jewel_game_manager:SendServerOperate(op_useitem, nx_string(para2), select_diamond_index)
end
function use_jingmai_item(para2, index)
  local form = nx_value(FORM_JINGMAI)
  form.select_skill_id = nx_string(para2)
  form.select_skill_index = index
  local jewel_game_manager = nx_value("jewel_game_manager")
  form.select_skill_type = jewel_game_manager:GetJMNeedPos(form.select_skill_id)
  if form.select_skill_type ~= 0 then
    form.select_skill_type = 2
  end
  if form.select_skill_type == 0 then
    on_use_jingmai_item(para2, index)
  else
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("8040"), 2)
    end
    gui.GameHand:SetHand("diamond_skill", "Attack", 0, "", "", "")
  end
end
function on_use_jingmai_skill(para2, index)
  local form = nx_value(FORM_JINGMAI)
  form.select_skill_id = nx_string(para2)
  local gui = nx_value("gui")
  local capital_module = nx_value("CapitalModule")
  local jewel_game_manager = nx_value("jewel_game_manager")
  local gold = capital_module:GetCapital(CAPITAL_TYPE_GOLDEN)
  local need_gold = jewel_game_manager:GetJMNeedMoney(nx_string(para2))
  if need_gold == 0 then
    local select_diamond_index = -1
    local puzzle_form = nx_value(FORM_PUZZLE_QUEST)
    if puzzle_form.src_select ~= nil then
      select_diamond_index = (puzzle_form.src_select.diamond_row - 1) * puzzle_form.max_row + puzzle_form.src_select.diamond_col - 1
    end
    jewel_game_manager:SendServerOperate(op_skill, nx_string(para2), select_diamond_index)
    form.imagegrid_skill.select_index = index
    gui.CoolManager:StartACool(nx_int(984125), 1000, nx_int(-1), 0)
  elseif gold > need_gold then
    ask(need_gold, para2, index)
  else
    local err_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local form = nx_value(FORM_JINGMAI)
    nx_execute("form_common\\form_confirm", "show_common_text", err_dialog, nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_skill_error", nx_int(need_gold), nx_int(gold), nx_int(need_gold - gold))))
    err_dialog.Left = form.Left + (form.Width - err_dialog.Width) / 2
    err_dialog.Top = form.Top + (form.Height - err_dialog.Height) / 2
    err_dialog:ShowModal()
    nx_wait_event(100000000, err_dialog, "confirm_return")
  end
end
function manger_blackandwhite_effect()
end
function sysn_skill()
  local form = nx_value(FORM_JINGMAI)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
  local view_item = view:GetViewObj("1")
  local rows = view_item:GetRecordRows("TempGemSkillRec")
  if rows <= prize_skill_count then
    return
  end
  form.imagegrid_prize_skill:Clear()
  local jewel_game_manager = nx_value("jewel_game_manager")
  local index = 0
  for i = rows - prize_skill_count, rows do
    local cd_time = view_item:QueryRecord("TempGemSkillRec", i, 1)
    if cd_time == cdtime1 or cd_time == cdtime2 then
      local skill_id = view_item:QueryRecord("TempGemSkillRec", i, 0)
      local photo = jewel_game_manager:GetJMPhoto(nx_string(skill_id))
      local name = nx_widestr(skill_id)
      form.imagegrid_prize_skill:AddItem(nx_int(index), photo, name, nx_int(0), i)
      form.imagegrid_prize_skill:SetCoolType(nx_int(index), nx_int(984125))
      index = index + 1
    end
  end
  reflesh_skill_rec(form, form.cur_skill_page)
end
function get_focus_pos(...)
  local effect_jingmai = nx_value("EffectJingMai")
  if not nx_is_valid(effect_jingmai) then
    return 0, 0, 40, 40
  end
  local pos = effect_jingmai:GetBall2DPos(1, 8)
  if nil == pos[1] or nil == pos[2] then
    return 0, 0, 40, 40
  end
  return pos[1], pos[2], 40, 40
end
function ask(need_gold, para2, index)
  local gui = nx_value("gui")
  local form = nx_value(FORM_JINGMAI)
  local ask_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  ask_dialog.Left = form.Left + (form.Width - ask_dialog.Width) / 2
  ask_dialog.Top = form.Top + (form.Height - ask_dialog.Height) / 2
  nx_execute("form_common\\form_confirm", "show_common_text", ask_dialog, nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_skill_ask", nx_int(need_gold))))
  ask_dialog:ShowModal()
  local res = nx_wait_event(100000000, ask_dialog, "confirm_return")
  if res == "ok" then
    local select_diamond_index = -1
    local puzzle_form = nx_value(FORM_PUZZLE_QUEST)
    if puzzle_form.src_select ~= nil then
      select_diamond_index = (puzzle_form.src_select.diamond_row - 1) * puzzle_form.max_row + puzzle_form.src_select.diamond_col - 1
    end
    local jewel_game_manager = nx_value("jewel_game_manager")
    jewel_game_manager:SendServerOperate(op_skill, nx_string(para2), select_diamond_index)
    form.imagegrid_skill.select_index = index
    gui.CoolManager:StartACool(nx_int(984125), 1000, nx_int(-1), 0)
  end
  return
end
function on_shortcut_record_change(grid, recordname, optype, row, clomn)
  nx_execute("shortcut_game", "on_shortcut_record_change", grid, recordname, optype, row, clomn)
end
function on_view_operat_main_shortcut(grid, optype, view_ident, index)
  on_shortcut_record_change(grid)
end
function on_cur_fill_state_change(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local jewel_game_manager = nx_value("jewel_game_manager")
  form.cur_fill_state = nx_number(prop_value)
  if form.cur_fill_state == BREAK_STATE then
    local break_lst = jewel_game_manager:GetFacultyGateBreakValue(nx_string(form.wuxue_name), nx_number(client_player:QueryProp("CurLevel")), nx_number(client_player:QueryProp("CurGate") + 1))
    if nx_number(break_lst[8]) == -1 then
      return
    end
    show_break_ball_process(break_lst)
    set_process(form, client_player:QueryProp("CurGoldValue"), nx_number(break_lst[1]), 1)
    set_process(form, client_player:QueryProp("CurWoodValue"), nx_number(break_lst[2]), 2)
    set_process(form, client_player:QueryProp("CurWaterValue"), nx_number(break_lst[3]), 3)
    set_process(form, client_player:QueryProp("CurFireValue"), nx_number(break_lst[4]), 4)
    set_process(form, client_player:QueryProp("CurEarthValue"), nx_number(break_lst[5]), 5)
    set_process(form, client_player:QueryProp("CurDarkValue"), nx_number(break_lst[6]), 6)
    set_process(form, client_player:QueryProp("CurLightValue"), nx_number(break_lst[7]), 7)
    set_process(form, client_player:QueryProp("CurDirtyValue"), nx_number(break_lst[8]), 8)
  else
    local fill_value = jewel_game_manager:GetFacultyGateFillValue(nx_string(form.wuxue_name), nx_number(client_player:QueryProp("CurLevel")), nx_number(client_player:QueryProp("CurGate") + 1))
    show_fill_ball_process()
    set_fill_ball_process(nx_number(client_player:QueryProp("CurFillValue")), nx_number(fill_value))
  end
end
function on_cur_level_change(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local jewel_game_manager = nx_value("jewel_game_manager")
  create_jingmai(form.wuxue_name)
  local cur_gate = client_player:QueryProp("CurGate")
  local cur_level = client_player:QueryProp("CurLevel")
  local max_gate = jewel_game_manager:GetFacultyLevelMaxGate(nx_string(form.wuxue_name), nx_number(cur_level)) - 1
  if max_gate < 0 then
    max_gate = 0
  end
  form.lbl_wuxue_gate.Text = nx_widestr(nx_string(cur_gate) .. "/" .. nx_string(max_gate))
end
function on_cur_gate_change(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local jewel_game_manager = nx_value("jewel_game_manager")
  local cur_gate = client_player:QueryProp("CurGate")
  local cur_level = client_player:QueryProp("CurLevel")
  local max_gate = jewel_game_manager:GetFacultyLevelMaxGate(nx_string(form.wuxue_name), nx_number(cur_level)) - 1
  if max_gate < 0 then
    max_gate = 0
  end
  nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "init_jingmai_process", "form_jingmai", form.wuxue_name, cur_level, cur_gate)
  set_jingmai(nx_string(form.wuxue_name), nx_number(client_player:QueryProp("CurFillValue")))
  form.lbl_wuxue_gate.Text = nx_widestr(nx_string(cur_gate) .. "/" .. nx_string(max_gate))
end
function on_cur_place_list_change(form, prop_name, prop_type, prop_value)
  refresh_place_list(form, prop_value)
end
function on_cur_total_fill_value_change(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cur_value = client_player:QueryProp("CurFillValue")
  local total_value = client_player:QueryProp("TotalFillValue")
  set_fill_ball_process(nx_number(cur_value), nx_number(total_value))
  set_jingmai(form.wuxue_name, nx_number(cur_value))
end
function on_cur_diamond_value_change(form, prop_name, prop_type, prop_value)
  if form.cur_fill_state ~= BREAK_STATE then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local ball_type, max_value, break_full_name
  if nx_string(prop_name) == nx_string("CurGoldValue") then
    ball_type = 1
    max_value = form.break_max_value1
    break_full_name = "break_full1"
  elseif nx_string(prop_name) == nx_string("CurWoodValue") then
    ball_type = 2
    max_value = form.break_max_value2
    break_full_name = "break_full2"
  elseif nx_string(prop_name) == nx_string("CurWaterValue") then
    ball_type = 3
    max_value = form.break_max_value3
    break_full_name = "break_full3"
  elseif nx_string(prop_name) == nx_string("CurFireValue") then
    ball_type = 4
    max_value = form.break_max_value4
    break_full_name = "break_full4"
  elseif nx_string(prop_name) == nx_string("CurEarthValue") then
    ball_type = 5
    max_value = form.break_max_value5
    break_full_name = "break_full5"
  elseif nx_string(prop_name) == nx_string("CurDarkValue") then
    ball_type = 6
    max_value = form.break_max_value6
    break_full_name = "break_full6"
  elseif nx_string(prop_name) == nx_string("CurLightValue") then
    ball_type = 7
    max_value = form.break_max_value7
    break_full_name = "break_full7"
  elseif nx_string(prop_name) == nx_string("CurDirtyValue") then
    ball_type = 8
    max_value = form.break_max_value8
    break_full_name = "break_full8"
  end
  nx_set_custom(form, nx_string("break_full" .. ball_type), nx_int(prop_value) >= nx_int(max_value))
  set_break_ball_process(nx_number(ball_type), nx_number(prop_value), nx_number(max_value))
end
function on_faculty_change(form, prop_name, prop_type, prop_value)
  form.lbl_xiuwei.Text = nx_widestr(prop_value)
end
function on_diamond_value_change(form, prop_name, prop_type, prop_value)
  form.lbl_ratio.Text = nx_widestr("X" .. nx_string(prop_value))
end
function on_cant_faculty_change(form, prop_name, prop_type, prop_value)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local cant_faculty = client_player:QueryProp("CantFaculty")
  local cur_fill_state = client_player:QueryProp("CurFillState")
  local next_gate = client_player:QueryProp("CurGate") + 1
  local cur_level = client_player:QueryProp("CurLevel")
  local jewel_game_manager = nx_value("jewel_game_manager")
  local xuewei_name = jewel_game_manager:GetFacultyGateXueWeiName(form.wuxue_name, cur_level, next_gate)
  if nx_int(cant_faculty) > nx_int(0) then
    form.isfaculty = true
    nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "set_xuewei_effect", "form_jingmai", xuewei_name, "point_H_05")
    nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "set_jingmai_process_effect", "form_jingmai", "point_H_05")
    local form_back = nx_value("form_stage_main\\puzzle_quest\\form_back")
    if nx_is_valid(form_back) then
      form_back.lbl_cantfaculty.Visible = true
      form_back.lbl_cantfaculty.Left = form_back.Width / 2 - form_back.lbl_cantfaculty.Width / 2
      form_back.lbl_cantfaculty.Top = form_back.Height / 2 - form_back.lbl_cantfaculty.Height / 2
    end
    form.gb_up.Visible = false
    nx_execute(FORM_JINGMAI, "manger_blackandwhite_effect")
  else
    form.isfaculty = false
    local form_back = nx_value("form_stage_main\\puzzle_quest\\form_back")
    if nx_is_valid(form_back) then
      form_back.lbl_cantfaculty.Visible = false
    end
    form.gb_up.Visible = true
    if cur_fill_state == BREAK_STATE then
      nx_execute("form_stage_main\\puzzle_quest\\form_jingmai_effect", "set_xuewei_effect", "form_jingmai", xuewei_name, "point_H_01")
    end
  end
end
