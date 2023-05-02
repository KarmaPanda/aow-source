require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("player_state\\state_input")
require("form_stage_main\\switch\\switch_define")
local SUB_CLIENT_ACT_EXIT = 22
local SUB_CLIENT_ACT_PAY = 23
local FACULTY_STYLE_NOR = 1
local FACULTY_STYLE_ACT = 2
local WUXUE_NEIGONG = 1
local WUXUE_SKILL = 2
local WUXUE_QGSKILL = 3
local WUXUE_ZHENFA = 4
local WUXUE_ANQI = 5
local WUXUE_JINGMAI = 6
local WUXUE_MAX = 7
local WUXUE_VIEW = {
  [WUXUE_NEIGONG] = VIEWPORT_NEIGONG,
  [WUXUE_SKILL] = VIEWPORT_SKILL,
  [WUXUE_QGSKILL] = VIEWPORT_QINGGONG,
  [WUXUE_ZHENFA] = VIEWPORT_ZHENFA,
  [WUXUE_ANQI] = VIEWPORT_SHOUFA,
  [WUXUE_JINGMAI] = VIEWPORT_JINGMAI
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function auto_show_hide_form_wuxue_act(show)
  local skin_path = "form_stage_main\\form_wuxue\\form_wuxue_act"
  local form = nx_value(skin_path)
  if nx_is_valid(form) and form.Visible == show then
    return
  end
  if show == nil then
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    else
      form.Visible = not form.Visible
    end
  else
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    end
    local form = nx_value(skin_path)
    form.Visible = show
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  self.wuxue_name = ""
  self.round_speed = 0
  self.add_speed = 0
  self.dec_speed = 0.14
  self.select_index = 0
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 5 * 4
  self.Top = (gui.Height - self.Height) / 3
  self.exit_flag = 0
end
function on_main_form_open(self)
  self.ani_taiji_effect.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("FacultyName", "int", self, nx_current(), "on_Faculty_wuxue_change")
    databinder:AddRolePropertyBind("Faculty", "int", self, nx_current(), "on_Faculty_change")
    databinder:AddRolePropertyBind("TotalFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurLevel", "int", self, nx_current(), "on_cur_level_change")
    databinder:AddRolePropertyBind("FillSpeed", "int", self, nx_current(), "on_FillSpeed_change")
    databinder:AddRolePropertyBind("ActDayValueLast", "int", self, nx_current(), "on_ActDayValueLast_change")
    databinder:AddRolePropertyBind("ActDayValueUsed", "int", self, nx_current(), "on_ActDayValueUsed_change")
  end
  refresh_act_photo(self)
  local faculty_query = nx_value("faculty_query")
  faculty_query:EnterActCameraMode()
  local form_back = util_get_form("form_stage_main\\form_wuxue\\form_faculty_back", true, false)
  if not nx_is_valid(form_back) then
    return false
  end
  form_back.name = "form_stage_main\\form_wuxue\\form_wuxue_act"
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", true)
  self.rbtn_suiyin.Checked = true
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_ACTFACULTY_BIND_CARD) then
      self.rbtn_yinpiao.Visible = true
    else
      self.rbtn_yinpiao.Visible = false
    end
  end
  local form = util_show_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", false)
end
function on_main_form_close(self)
  nx_execute("util_gui", "ui_destroy_attached_form", self)
  nx_destroy(self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_main_form_shut(self)
  if not nx_is_valid(self) then
    return
  end
  local data_binder = nx_value("data_binder")
  data_binder:DelRolePropertyBind("FacultyName", self)
  data_binder:DelRolePropertyBind("Faculty", self)
  data_binder:DelRolePropertyBind("TotalFillValue", self)
  data_binder:DelRolePropertyBind("CurFillValue", self)
  data_binder:DelRolePropertyBind("CurLevel", self)
  data_binder:DelRolePropertyBind("FillSpeed", self)
  data_binder:DelRolePropertyBind("ActDayValueLast", self)
  data_binder:DelRolePropertyBind("ActDayValueUsed", self)
  data_binder:DelViewBind(self)
  local faculty_query = nx_value("faculty_query")
  faculty_query:OutActCameraMode()
  if (not nx_find_custom(self, "is_help") or not self.is_help) and nx_int(self.exit_flag) ~= nx_int(1) then
    nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_ACT_EXIT, 0)
  end
  util_show_form("form_stage_main\\form_wuxue\\form_faculty_back", false)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", false)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_time_reset_addspeed", self)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:RemoveExecute("ActFaculty", self)
  end
end
function on_msg_act_begin(nPrice)
  auto_show_hide_form_wuxue_act(true)
  local form = nx_value("form_stage_main\\form_wuxue\\form_wuxue_act")
  if nx_is_valid(form) then
    nx_execute("util_gui", "ui_show_attached_form", form)
  end
end
function on_msg_act_play()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_act", false)
  if not nx_is_valid(form) then
    return
  end
  create_path_effect(form)
  form.ani_taiji_effect.Visible = true
  form.ani_taiji_effect:Play()
  local gui = nx_value("gui")
  gui.CoolManager:StartACool(nx_int(24025), 1500, nx_int(-1), 0)
  form.add_speed = 0.2
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("ActFaculty", form, 0.01)
  end
  local timer = nx_value("timer_game")
  timer:Register(2000, 1, "form_stage_main\\form_wuxue\\form_wuxue_act", "on_time_reset_addspeed", form, -1, -1)
end
function on_msg_exit_faculty()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_act", false)
  if not nx_is_valid(form) then
    return
  end
  form.exit_flag = 1
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_imagegrid_act_photo_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(index) < nx_int(0) or nx_int(index) > nx_int(2) then
    return
  end
  local gui = nx_value("gui")
  if gui.CoolManager:IsCooling(nx_int(24025), nx_int(-1)) then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local cost_type = 2
  if form.rbtn_suiyin.Checked then
    cost_type = 1
  elseif form.rbtn_yinpiao.Checked then
    cost_type = 4
  else
    cost_type = 2
  end
  nx_execute("custom_sender", "custom_send_faculty_msg", SUB_CLIENT_ACT_PAY, nx_int(index), nx_int(cost_type))
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", true)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_time_reset_addspeed(form)
  if not nx_is_valid(form) then
    return
  end
  form.add_speed = 0
  return
end
function on_imagegrid_act_photo_mousein_grid(self, index)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local form_tips = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", true)
  if not nx_is_valid(form_tips) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("FacultyName")
  local cur_level = client_player:QueryProp("CurLevel")
  local base_value = faculty_query:GetBaseValue(wuxue_name, cur_level, index)
  local price_ratio = faculty_query:GetPriceRatio(wuxue_name, cur_level)
  local cost_text = nx_execute("util_functions", "trans_capital_string", nx_int(price_ratio * base_value))
  form_tips.lbl_name.Text = nx_widestr(util_text("ui_faculty_act_item_name_" .. nx_string(self:GetItemMark(index))))
  form_tips.mltbox_script.HtmlText = nx_widestr(util_text("ui_faculty_act_item_script_" .. nx_string(self:GetItemMark(index))) .. nx_widestr("<br><br>") .. util_text("ui_train_act_tips2"))
  form_tips.lbl_cost.Text = nx_widestr(cost_text)
  reset_tips_control_pos(form_tips)
  if form.rbtn_suiyin.Checked then
    form_tips.lbl_picture.BackImage = "gui\\common\\money\\suiyin.png"
  elseif form.rbtn_yinpiao.Checked then
    form_tips.lbl_picture.BackImage = "gui\\common\\money\\yinpiao.png"
  else
    form_tips.lbl_picture.BackImage = "gui\\common\\money\\liang.png"
  end
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", true)
  if nx_is_valid(form_tips) then
    form_tips.AbsLeft = self.AbsLeft + 45 + index * 98
    form_tips.AbsTop = self.AbsTop + 30
  end
end
function on_imagegrid_act_photo_mouseout_grid(self)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", false)
end
function on_rbtn_suiyin_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local day_value = client_player:QueryProp("ActDayValue")
  local cost_value = client_player:QueryProp("ActCostSuiYin")
  local remain_value = day_value - cost_value
  if nx_int(remain_value) < nx_int(0) then
    remain_value = 0
  end
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText("ui_act_faculty_silver", nx_int(day_value), nx_int(remain_value)))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 150, form)
end
function on_rbtn_suiyin_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_rbtn_yinzi_get_capture(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local double_days = client_player:QueryProp("ActDoubleDay")
  local double_text = ""
  if nx_int(double_days) > nx_int(0) then
    double_text = nx_widestr(nx_widestr(util_text("ui_act_faculty_double_open")) .. nx_widestr(double_days) .. nx_widestr(util_text("ui_day")))
  else
    local double_need = client_player:QueryProp("DoubleOpenNeed")
    local need_text = nx_execute("util_functions", "trans_capital_string", nx_int(double_need))
    double_text = nx_widestr(util_text("ui_act_faculty_double_close")) .. nx_widestr(need_text)
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(double_text), self.AbsLeft, self.AbsTop, 150, form)
end
function on_rbtn_yinzi_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_rbtn_yinzi_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_Faculty_wuxue_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("FacultyName")
  form.wuxue_name = nx_string(wuxue_name)
  form.lbl_wuxue_name.Text = nx_widestr(util_text(wuxue_name))
  local photo = get_cur_wuxue_static_data(form, "Photo")
  form.imagegrid_wuxue:AddItem(0, nx_string(photo), 0, 1, -1)
end
function on_Faculty_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_faculty = client_player:QueryProp("Faculty")
  form.lbl_faculty.Text = nx_widestr(cur_faculty)
end
function on_FillSpeed_change(form)
  if not nx_is_valid(form) then
    return false
  end
  refresh_time(form)
end
function on_ActDayValueLast_change(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(200, 1, "form_stage_main\\form_wuxue\\form_wuxue_act", "on_time_refresh_ActDayValueLast", form, -1, -1)
  end
end
function on_time_refresh_ActDayValueLast(form)
  if not nx_is_valid(form) then
    return false
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local day_value = client_player:QueryProp("ActDayValueMax")
  if nx_int(day_value) < nx_int(0) then
    return
  end
  local value_used = client_player:QueryProp("ActDayValueUsed")
  local value_last = client_player:QueryProp("ActDayValueLast")
  if nx_int(value_used) <= nx_int(day_value) then
    value_remain = value_last + value_used - day_value
  else
    value_remain = value_last
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(2812) then
    form.lbl_faculty_total_value.Text = nx_widestr(math.max(value_remain, 0))
  else
    form.lbl_faculty_total_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_act_faculty_no_limit"))
  end
end
function on_ActDayValueUsed_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local day_value = client_player:QueryProp("ActDayValueMax")
  if nx_int(day_value) < nx_int(0) then
    return
  end
  local value_used = client_player:QueryProp("ActDayValueUsed")
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(2812) then
    form.lbl_faculty_day_value.Text = nx_widestr(math.max(day_value - value_used, 0))
  else
    form.lbl_faculty_day_value.Text = nx_widestr(gui.TextManager:GetFormatText("ui_act_faculty_no_limit"))
  end
end
function on_cur_level_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_level = client_player:QueryProp("CurLevel")
  form.lbl_level.Text = nx_widestr(gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(cur_level)))
end
function on_FillValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level_faculty = client_player:QueryProp("TotalFillValue")
  local cur_fillvalue = client_player:QueryProp("CurFillValue")
  if level_faculty < cur_fillvalue then
    cur_fillvalue = level_faculty
  end
  form.pbar_fill.Maximum = level_faculty
  form.pbar_fill.Value = cur_fillvalue
  refresh_time(form)
end
function refresh_act_photo(form)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_act_photo:Clear()
  local faculty_query = nx_value("faculty_query")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("FacultyName")
  local cur_level = client_player:QueryProp("CurLevel")
  local max_exps = faculty_query:GetBaseValue(wuxue_name, cur_level, 2)
  local photo_list = get_act_photo_list(max_exps)
  local photo_table = util_split_string(nx_string(photo_list), ",")
  local count = table.getn(photo_table)
  if nx_int(count) ~= nx_int(3) then
    return
  end
  for i = 0, count - 1 do
    local photo = "gui\\special\\xiulian\\exp_item_" .. nx_string(photo_table[i + 1]) .. ".png"
    form.imagegrid_act_photo:AddItem(i, photo, 0, 1, -1)
    form.imagegrid_act_photo:SetCoolType(nx_int(i), nx_int(24025))
    form.imagegrid_act_photo:SetItemMark(i, nx_int(photo_table[i + 1]))
    local base_value = faculty_query:GetBaseValue(wuxue_name, cur_level, i)
    local lbl_faculty = form:Find("lbl_faculty_" .. nx_string(i))
    if nx_is_valid(lbl_faculty) then
      lbl_faculty.Text = nx_widestr(nx_string(base_value))
    end
  end
end
function get_cur_wuxue_id(form)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  if nx_int(wuxue_type) <= nx_int(0) or nx_int(wuxue_type) >= nx_int(WUXUE_MAX) or nx_string(form.wuxue_name) == nx_string("") then
    return nx_null()
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(WUXUE_VIEW[wuxue_type]))
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
  if not nx_is_valid(form) then
    return
  end
  if prop_name == nil or nx_string(prop_name) == nx_string("") then
    return
  end
  local wuxue_id = get_cur_wuxue_id(form)
  if not nx_is_valid(wuxue_id) then
    return
  end
  local Data_Type
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  if nx_int(wuxue_type) == nx_int(WUXUE_SKILL) then
    Data_Type = STATIC_DATA_SKILL_STATIC
  elseif nx_int(wuxue_type) == nx_int(WUXUE_NEIGONG) then
    Data_Type = STATIC_DATA_NEIGONG
  elseif nx_int(wuxue_type) == nx_int(WUXUE_QGSKILL) then
    Data_Type = STATIC_DATA_QGSKILL
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ZHENFA) then
    Data_Type = STATIC_DATA_ZHENFA
  elseif nx_int(wuxue_type) == nx_int(WUXUE_JINGMAI) then
    Data_Type = STATIC_DATA_JINGMAI
  elseif nx_int(wuxue_type) == nx_int(WUXUE_ANQI) then
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
function refresh_time(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level_faculty = client_player:QueryProp("TotalFillValue")
  local cur_fillvalue = client_player:QueryProp("CurFillValue")
  local leave_faculty = level_faculty - cur_fillvalue
  if nx_int(leave_faculty) < nx_int(0) then
    leave_faculty = 0
  end
  local speed = client_player:QueryProp("FillSpeed")
  if nx_int(speed) <= nx_int(0) then
    return false
  end
  local time = math.ceil(leave_faculty / speed)
  local day = nx_int(time / 1440)
  local hour = nx_int(math.mod(time, 1440) / 60)
  local min = nx_int(math.mod(math.mod(time, 1440), 60))
  form.lbl_time.Text = nx_widestr(day) .. nx_widestr(util_text("ui_day")) .. nx_widestr(hour) .. nx_widestr(util_text("ui_hourx")) .. nx_widestr(min) .. nx_widestr(util_text("ui_min"))
  return true
end
function create_path_effect(form)
  if not nx_is_valid(form) then
    return
  end
  local ani_path_pos_list = {}
  ani_path_pos_list[1] = {left = 0, top = 0}
  ani_path_pos_list[1].left = form.lbl_round_photo.AbsLeft + form.lbl_round_photo.Width / 2
  ani_path_pos_list[1].top = form.lbl_round_photo.AbsTop + form.lbl_round_photo.Height / 2
  ani_path_pos_list[3] = {left = 0, top = 0}
  ani_path_pos_list[3].left = form.pbar_fill.AbsLeft + form.pbar_fill.Width * form.pbar_fill.Value / form.pbar_fill.Maximum
  ani_path_pos_list[3].top = form.pbar_fill.AbsTop + form.pbar_fill.Height / 2
  ani_path_pos_list[2] = {left = 0, top = 0}
  ani_path_pos_list[2].left = math.random(math.min(ani_path_pos_list[1].left, ani_path_pos_list[3].left), math.max(ani_path_pos_list[1].left, ani_path_pos_list[3].left))
  ani_path_pos_list[2].top = math.random(math.min(ani_path_pos_list[1].top, ani_path_pos_list[3].top), math.max(ani_path_pos_list[1].top, ani_path_pos_list[3].top))
  local gui = nx_value("gui")
  local ani_path = gui:Create("AnimationPath")
  form:Add(ani_path)
  ani_path.AnimationImage = "gui\\animations\\path_effect\\star.dds"
  ani_path.SmoothPath = true
  ani_path.Loop = false
  ani_path.ClosePath = false
  ani_path.Color = "255,255,126,0"
  ani_path.CreateMinInterval = 5
  ani_path.CreateMaxInterval = 10
  ani_path.RotateSpeed = 2
  ani_path.BeginAlpha = 1
  ani_path.AlphaChangeSpeed = 1
  ani_path.BeginScale = 0.17
  ani_path.ScaleSpeed = 0
  ani_path.MaxTime = 1000
  ani_path.MaxWave = 0.05
  ani_path:ClearPathPoints()
  for i = 1, table.getn(ani_path_pos_list) do
    local ani_path_pos = ani_path_pos_list[i]
    ani_path:AddPathPoint(ani_path_pos.left, ani_path_pos.top)
  end
  ani_path:AddPathPointFinish()
  nx_bind_script(ani_path, nx_current())
  nx_callback(ani_path, "on_animation_end", "on_ani_path_end")
  ani_path:Play()
  return ani_path
end
function on_ani_path_end(self)
  if not nx_is_valid(self) then
    return
  end
  self.Visible = false
  local gui = nx_value("gui")
  gui:Delete(self)
end
function get_act_photo_list(faculty)
  if faculty <= 0 then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\ActFacultyPhoto.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Photo")
  if sec_index < 0 then
    return
  end
  local act_count = ini:GetSectionItemCount(sec_index)
  for i = 0, act_count - 1 do
    local key = ini:GetSectionItemKey(sec_index, i)
    if nx_int(faculty) <= nx_int(key) then
      return ini:GetSectionItemValue(sec_index, i)
    end
  end
  return ini:GetSectionItemValue(sec_index, act_count - 1)
end
function reset_tips_control_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local cur_height = form.mltbox_script:GetContentHeight()
  form.mltbox_script.Height = cur_height + 20
  form.mltbox_script.ViewRect = "0,0,174," .. nx_string(cur_height + 20)
  form.Height = cur_height + 62
end
