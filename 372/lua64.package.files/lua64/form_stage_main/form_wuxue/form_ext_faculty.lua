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
function change_form_size()
  local gui = nx_value("gui")
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("ExtFacultyName", "int", self, nx_current(), "on_Ext_Faculty_wuxue_change")
    databinder:AddRolePropertyBind("Faculty", "int", self, nx_current(), "on_Faculty_change")
    databinder:AddRolePropertyBind("ExtTotalFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("ExtCurFillValue", "int", self, nx_current(), "on_FillValue_change")
    databinder:AddRolePropertyBind("ExtCurLevel", "int", self, nx_current(), "on_cur_level_change")
  end
  change_form_size(self)
end
function on_main_form_close(self)
  local data_binder = nx_value("data_binder")
  data_binder:DelRolePropertyBind("ExtFacultyName", self)
  data_binder:DelRolePropertyBind("Faculty", self)
  data_binder:DelRolePropertyBind("ExtTotalFillValue", self)
  data_binder:DelRolePropertyBind("ExtCurFillValue", self)
  data_binder:DelRolePropertyBind("ExtCurLevel", self)
  nx_destroy(self)
end
function on_Ext_Faculty_wuxue_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local wuxue_name = client_player:QueryProp("ExtFacultyName")
  form.wuxue_name = nx_string(wuxue_name)
  form.lbl_wuxue_name.Text = nx_widestr(util_text(wuxue_name))
  local photo = get_cur_wuxue_static_data(form, "Photo")
  form.imagegrid_wuxue:AddItem(0, nx_string(photo), 0, 1, -1)
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(form.wuxue_name)
  local wuxue_obj = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_wuxue_object", form.wuxue_name, wuxue_type)
  if not nx_is_valid(wuxue_obj) then
    form.lbl_property.Text = nx_widestr("")
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
  local cur_level = client_player:QueryProp("ExtCurLevel")
  form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_level_" .. nx_string(cur_level)))
  if nx_int(cur_level) <= nx_int(0) then
    form.lbl_level.Text = nx_widestr(util_text("ui_train_level"))
  end
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
function on_FillValue_change(form)
  if not nx_is_valid(form) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local level_faculty = client_player:QueryProp("ExtTotalFillValue")
  local cur_fillvalue = client_player:QueryProp("ExtCurFillValue")
  if level_faculty < cur_fillvalue then
    cur_fillvalue = level_faculty
  end
  if level_faculty == 0 then
    level_faculty = 100
  end
  form.pbar_fill.Maximum = level_faculty
  form.pbar_fill.Value = cur_fillvalue
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
  local count = view:GetViewObjCount()
  for i = 1, count do
    local wuxue_id = view:GetViewObjByIndex(i - 1)
    local temp_name = wuxue_id:QueryProp("ConfigID")
    if nx_string(temp_name) == nx_string(form.wuxue_name) then
      return wuxue_id
    end
  end
  return nx_null()
end
function on_photo_click(self)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_imagegrid_wuxue_rightclick_grid(self)
  local bSuccess = nx_execute("faculty", "set_faculty_wuxue", "", 2)
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
