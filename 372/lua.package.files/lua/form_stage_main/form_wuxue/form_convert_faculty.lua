require("util_gui")
require("util_functions")
require("share\\view_define")
require("define\\object_type_define")
local TEAM_FACULTY_TYPE_JIUGONG = 3
function main_form_init(self)
  self.Fixed = false
  self.wuxue_name = ""
  self.cur_level = 0
  self.cur_fill = 0
  self.convert_value = 0
  self.total_fill = 0
  self.speed = 0
  self.cur_par = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = gui.Height / 3 * 2
  show_form(self)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "form_alpha_out", self)
  nx_destroy(self)
end
function show_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_wuxue_name.Text = nx_widestr(util_text(form.wuxue_name))
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if nx_is_valid(view) and nx_int(view:QueryProp("PlayType")) == nx_int(TEAM_FACULTY_TYPE_JIUGONG) then
    jiugong_convert_info(form)
  else
    local photo = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_faculty", "get_cur_wuxue_static_data", form, "Photo")
    form.imagegrid_wuxue:AddItem(0, nx_string(photo), 0, 1, -1)
    form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_level_" .. nx_string(form.cur_level)))
    local faculty_query = nx_value("faculty_query")
    local wuxue_type = faculty_query:GetType(form.wuxue_name)
    local wuxue_obj = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_wuxue_object", form.wuxue_name, wuxue_type)
    if not nx_is_valid(wuxue_obj) then
      return
    end
    local property = wuxue_obj:QueryProp("WuXing")
    if nx_int(property) > nx_int(0) and nx_int(property) <= nx_int(7) then
      form.lbl_property.Text = nx_widestr(util_text("ui_wuxue_prop_" .. nx_string(property)))
    end
  end
  local convert_before = form.cur_fill - form.convert_value
  if nx_int(convert_before) < nx_int(0) then
    convert_before = 0
  end
  form.pbar_time.Maximum = form.total_fill
  form.pbar_time.Value = convert_before
  form.cur_par = convert_before
  form.speed = nx_number(form.convert_value / 60.00000000000001)
  show_time(form, form.total_fill - convert_before)
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    common_execute:AddExecute("FacultyConvert", form, nx_float(0.03))
  end
end
function on_pbar_over(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.cur_fill) >= nx_int(form.total_fill) then
    form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_level_" .. nx_string(form.cur_level + 1)))
    form.pbar_time.Value = 0
  end
  show_time(form, form.total_fill - form.cur_fill)
  local change_alpha = form.BlendAlpha / 70
  local timer = nx_value(GAME_TIMER)
  timer:Register(30, -1, nx_current(), "form_alpha_out", form, change_alpha, -1)
end
function form_alpha_out(form, change_alpha)
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(form) then
    timer:UnRegister(nx_current(), "form_alpha_out", form)
    return 0
  end
  form.BlendAlpha = form.BlendAlpha - change_alpha
  if nx_int(form.BlendAlpha) <= nx_int(10) then
    timer:UnRegister(nx_current(), "form_alpha_out", form)
    form:Close()
  end
end
function show_time(form, value)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(value) < nx_int(0) then
    value = nx_int(0)
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local speed = client_player:QueryProp("FillSpeed")
  if nx_int(speed) <= nx_int(0) then
    return false
  end
  local time = math.ceil(value / speed)
  local day = nx_int(time / 1440)
  local hour = nx_int(math.mod(time, 1440) / 60)
  local min = nx_int(math.mod(math.mod(time, 1440), 60))
  form.lbl_time.Text = nx_widestr(day) .. nx_widestr(util_text("ui_day")) .. nx_widestr(hour) .. nx_widestr(util_text("ui_hourx")) .. nx_widestr(min) .. nx_widestr(util_text("ui_min"))
end
function jiugong_convert_info(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local photo = "icon\\zhenfa\\zhenfa_thd_01.png"
  form.imagegrid_wuxue:AddItem(0, nx_string(photo), 0, 1, -1)
  form.lbl_property.Text = nx_widestr(util_text("ui_wuxue_prop_5"))
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local leader = view:QueryProp("LeaderName")
  if nx_ws_equal(nx_widestr(leader), nx_widestr(player_name)) == true then
    form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_jiugong_faculty_impart"))
  else
    form.lbl_level.Text = nx_widestr(util_text("ui_wuxue_jiugong_faculty_realization"))
  end
  form.lbl_time.Visible = false
end
