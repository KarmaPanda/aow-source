require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("player_state\\state_input")
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
function main_form_init(self)
  self.Fixed = false
  self.wuxue_name = ""
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("FacultyName", "int", self, nx_current(), "on_Faculty_wuxue_change")
    databinder:AddRolePropertyBind("Faculty", "int", self, nx_current(), "on_Faculty_change")
    databinder:AddRolePropertyBind("TotalFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("CurLevel", "int", self, nx_current(), "on_cur_level_change")
    databinder:AddRolePropertyBind("FillSpeed", "int", self, nx_current(), "on_FillSpeed_change")
    databinder:AddRolePropertyBind("NeigongUseValue", "int", self, nx_current(), "on_NeigongUseValue_change")
    databinder:AddRolePropertyBind("SkillUseValue", "int", self, nx_current(), "on_SkillUseValue_change")
  end
end
function on_main_form_close(self)
  local data_binder = nx_value("data_binder")
  data_binder:DelRolePropertyBind("FacultyName", self)
  data_binder:DelRolePropertyBind("Faculty", self)
  data_binder:DelRolePropertyBind("TotalFillValue", self)
  data_binder:DelRolePropertyBind("CurFillValue", self)
  data_binder:DelRolePropertyBind("CurLevel", self)
  data_binder:DelRolePropertyBind("FillSpeed", self)
  data_binder:DelViewBind(self)
  nx_destroy(self)
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
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  local wuxue_obj = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_wuxue_object", form.wuxue_name, wuxue_type)
  if not nx_is_valid(wuxue_obj) then
    return
  end
  local property = wuxue_obj:QueryProp("WuXing")
  local type_str = "ui_wuxue_prop_" .. nx_string(property)
  form.lbl_property.Text = nx_widestr(util_text(type_str))
end
function on_cur_level_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_level = client_player:QueryProp("CurLevel")
  form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_level_" .. nx_string(cur_level)))
  if nx_int(cur_level) <= nx_int(0) then
    form.lbl_level.Text = nx_widestr(util_text("ui_train_level"))
  end
end
function on_FillSpeed_change(form)
  if not nx_is_valid(form) then
    return false
  end
  refresh_speed(form)
  refresh_time(form)
end
function on_NeigongUseValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local neigong_usevalue = client_player:QueryProp("NeigongUseValue")
  local text = nx_widestr("")
  local yi = math.floor(nx_number(neigong_usevalue) / 10000)
  local wan = math.floor(nx_number(neigong_usevalue) % 10000)
  if nx_int(yi) > nx_int(0) then
    text = nx_widestr(yi) .. nx_widestr(util_text("ui_rank_yi"))
  end
  if nx_int(wan) > nx_int(0) then
    text = nx_widestr(text) .. nx_widestr(wan) .. nx_widestr(util_text("ui_rank_wan"))
  end
  form.lbl_ng_faculty_value.Text = nx_widestr(text)
end
function on_SkillUseValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local skill_usevalue = client_player:QueryProp("SkillUseValue")
  local text = nx_widestr("")
  local yi = math.floor(nx_number(skill_usevalue) / 10000)
  local wan = math.floor(nx_number(skill_usevalue) % 10000)
  if nx_int(yi) > nx_int(0) then
    text = nx_widestr(yi) .. nx_widestr(util_text("ui_rank_yi"))
  end
  if nx_int(wan) > nx_int(0) then
    text = nx_widestr(text) .. nx_widestr(wan) .. nx_widestr(util_text("ui_rank_wan"))
  end
  form.lbl_skill_faculty_value.Text = nx_widestr(text)
end
function on_Faculty_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_faculty = client_player:QueryProp("Faculty")
  form.lbl_faculty.Text = nx_widestr(cur_faculty)
  refresh_speed(form)
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
function refresh_time(form)
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
  local time_text = ""
  if nx_int(day) > nx_int(0) then
    time_text = nx_widestr(time_text) .. nx_widestr(day) .. nx_widestr(util_text("ui_day"))
  end
  if nx_int(hour) > nx_int(0) then
    time_text = nx_widestr(time_text) .. nx_widestr(hour) .. nx_widestr(util_text("ui_hourx"))
  end
  if nx_int(min) > nx_int(0) then
    time_text = nx_widestr(time_text) .. nx_widestr(min) .. nx_widestr(util_text("ui_min"))
  end
  if nx_int(time) == nx_int(0) then
    time_text = nx_widestr("0") .. nx_widestr(util_text("ui_min"))
  end
  form.lbl_time.Text = nx_widestr(time_text)
  return true
end
function refresh_speed(form)
  local faculty_query = nx_value("faculty_query")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local cur_level = client_player:QueryProp("CurLevel")
  local fill_speed = client_player:QueryProp("FillSpeed")
  local base_speed = faculty_query:GetFillSpeed(form.wuxue_name, cur_level)
  local cur_faculty = client_player:QueryProp("Faculty")
  local cur_place = client_player:QueryProp("CurPlaceList")
  local speed_text = ""
  if nx_int(cur_faculty) <= nx_int(fill_speed) then
    speed_text = "ui_train_speed_0"
    form.lbl_speed.ForeColor = "255,255,0,0"
  elseif nx_int(fill_speed) < nx_int(base_speed) then
    speed_text = "ui_train_speed_1"
    form.lbl_speed.ForeColor = "255,255,0,0"
  elseif nx_int(fill_speed) == nx_int(base_speed) then
    speed_text = "ui_train_speed_2"
    form.lbl_speed.ForeColor = "255,0,176,80"
  elseif nx_int(fill_speed) < nx_int(base_speed * 1.14) then
    speed_text = "ui_train_speed_3"
    form.lbl_speed.ForeColor = "255,0,176,240"
  elseif nx_int(fill_speed) < nx_int(base_speed * 2) then
    speed_text = "ui_train_speed_4"
    form.lbl_speed.ForeColor = "255,112,48,160"
  else
    speed_text = "ui_train_speed_5"
    form.lbl_speed.ForeColor = "255,255,136,0"
  end
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  local wuxue_obj = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_wuxue_object", form.wuxue_name, wuxue_type)
  if not nx_is_valid(wuxue_obj) then
    return
  end
  local property = wuxue_obj:QueryProp("WuXing")
  local place_text = ""
  if cur_place ~= "" then
    local place_add = faculty_query:GetSpeedAdd(nx_int(property), cur_place)
    if nx_int(place_add) ~= nx_int(0) then
      place_text = nx_widestr("(") .. nx_widestr(util_text("ui_faculty_place_" .. nx_string(cur_place))) .. nx_widestr(")")
    end
  end
  form.lbl_speed.Text = nx_widestr(nx_widestr(util_text(speed_text)) .. nx_widestr(place_text))
end
