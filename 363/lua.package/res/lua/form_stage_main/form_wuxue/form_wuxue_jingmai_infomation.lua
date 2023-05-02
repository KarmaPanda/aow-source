require("util_gui")
require("util_functions")
require("share\\view_define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local MSG_CLIENT_UPDATE_ZQ = 2
local SUB_CLIENT_SET_JINGMAI = 1
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJingMai", "int", self, nx_current(), "on_CurJingMai_change")
    databinder:AddRolePropertyBind("LastJingMai", "int", self, nx_current(), "on_CurJingMai_change")
    databinder:AddRolePropertyBind("ZQPLValue", "int", self, nx_current(), "on_zhenqi_dayvalue_change")
    databinder:AddRolePropertyBind("ZQActValue", "int", self, nx_current(), "on_zhenqi_dayvalue_change")
    databinder:AddRolePropertyBind("ZhenQiDayValue", "int", self, nx_current(), "on_zhenqi_dayvalue_change")
    databinder:AddRolePropertyBind("ZQUnUsedValue", "int", self, nx_current(), "on_zq_unused_value_change")
    databinder:AddViewBind(VIEWPORT_JINGMAI, self, nx_current(), "on_jingmai_viewport_change")
  end
  self.Left = 45
  self.Top = 95
  nx_execute("util_gui", "ui_show_attached_form", self)
  nx_execute("custom_sender", "custom_jingmai_wuji_msg", MSG_CLIENT_UPDATE_ZQ)
end
function on_main_form_close(self)
  ui_destroy_attached_form(self)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("CurJingMai", self)
    databinder:DelRolePropertyBind("LastJingMai", self)
    databinder:DelRolePropertyBind("ZQPLValue", self)
    databinder:DelRolePropertyBind("ZQActValue", self)
    databinder:DelRolePropertyBind("ZhenQiDayValue", self)
    databinder:DelRolePropertyBind("ZQUnUsedValue", self)
    databinder:DelViewBind(self)
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "show_jingmai_data", self)
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
function on_btn_change_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  local jingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
  if jingmai_name == nil or nx_string(jingmai_name) == "" then
    open_wuxue_sub_page(WUXUE_JINGMAI)
  else
    open_wuxue_sub_page(WUXUE_JINGMAI, nx_string(jingmai_name))
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_onfaculty_click(self)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local jingmai_name = nx_string(client_player:QueryProp("LastJingMai"))
  nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, nx_string(jingmai_name))
end
function on_btn_faculty_closed_click(self)
  nx_execute("custom_sender", "custom_jingmai_wuji_msg", SUB_CLIENT_SET_JINGMAI, nx_string(""))
end
function get_jingmai_item()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  local jingmai_name = nx_string(client_player:QueryProp("LastJingMai"))
  if jingmai_name == nil or nx_string(jingmai_name) == "" then
    return nil
  end
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(jingmai_name)
  local item = get_wuxue_object(jingmai_name, wuxue_type)
  if not nx_is_valid(item) then
    return nil
  end
  return item
end
function on_CurJingMai_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil
  end
  local jingmai_name = nx_string(client_player:QueryProp("LastJingMai"))
  if jingmai_name == nil or jingmai_name == "0" or jingmai_name == "" then
    form.lbl_currentJM_name.Visible = false
    form.pbar_fill.Visible = false
    form.mltbox_level.Visible = false
  else
    form.lbl_currentJM_name.Visible = true
    form.pbar_fill.Visible = true
    form.mltbox_level.Visible = true
    form.lbl_currentJM_name.Text = nx_widestr(util_text(jingmai_name))
  end
  show_jingmai_data(form)
  on_zhenqi_dayvalue_change(form)
  on_zq_unused_value_change(form)
  on_active_jingmai_rec_change(form)
  local curjingmai_name = nx_string(client_player:QueryProp("CurJingMai"))
  if curjingmai_name == nil or curjingmai_name == "0" or curjingmai_name == "" then
    form.btn_onfaculty.Visible = true
    form.btn_onfaculty.Enabled = true
    form.btn_faculty_closed.Visible = false
    form.btn_faculty_closed.Enabled = false
    form.lbl_main.BackImage = "gui\\language\\ChineseS\\wuxue\\jingmai\\jingmai_back.png"
    form.lbl_main.DrawMode = "FitWindow"
  else
    form.btn_onfaculty.Visible = false
    form.btn_onfaculty.Enabled = false
    form.btn_faculty_closed.Visible = true
    form.btn_faculty_closed.Enabled = true
    form.lbl_main.BackImage = "gui\\language\\ChineseS\\wuxue\\jingmai\\jingmai_back_2.png"
    form.lbl_main.DrawMode = "FitWindow"
  end
end
function show_jingmai_data(form)
  local item = get_jingmai_item()
  if not nx_is_valid(item) then
    return
  end
  local gui = nx_value("gui")
  local level_faculty = item:QueryProp("TotalFillValue")
  local cur_fillvalue = item:QueryProp("CurFillValue")
  local Level = item:QueryProp("Level")
  local MaxLevel = get_maxlevel_by_conditions(item)
  if level_faculty < cur_fillvalue then
    cur_fillvalue = level_faculty
  end
  if Level >= MaxLevel then
    form.pbar_fill.Visible = false
  end
  form.pbar_fill.Maximum = level_faculty
  form.pbar_fill.Value = cur_fillvalue
  form.mltbox_level.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_curlevel", nx_widestr(Level), nx_widestr(MaxLevel)))
end
function on_zhenqi_dayvalue_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local zqpl_value = client_player:QueryProp("ZQPLValue")
  local zqact_value = client_player:QueryProp("ZQActValue")
  local zqtotal_value = nx_int(zqpl_value) + nx_int(zqact_value)
  local zqday_value = client_player:QueryProp("ZhenQiDayValue")
  form.mltbox_yuzhi_lbl.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_maxyuzhi", nx_widestr(zqday_value), nx_widestr(zqtotal_value)))
end
function on_zq_unused_value_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local ZQUnUsedValue = client_player:QueryProp("ZQUnUsedValue")
  form.mltbox_product_value.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_holdzhenqi", nx_widestr(ZQUnUsedValue)))
end
function on_jingmai_viewport_change(form)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(500, 1, nx_current(), "show_jingmai_data", form, -1, -1)
  end
end
function on_active_jingmai_rec_change(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local view = game_client:GetView(nx_string(VIEWPORT_JINGMAI))
  if not nx_is_valid(view) then
    return
  end
  local gui = nx_value("gui")
  local viewobj_list = view:GetViewObjList()
  local faculty_count = table.maxn(viewobj_list)
  local faculty_num = 0
  for i = 1, faculty_count do
    local jingmaiobj = viewobj_list[i]
    local jingmaiid = jingmaiobj:QueryProp("ConfigID")
    local wuxue_query = nx_value("WuXueQuery")
    if not nx_is_valid(wuxue_query) then
      return
    end
    local jingmai = wuxue_query:GetLearnID_JingMai(nx_string(jingmaiid))
    if not nx_is_valid(jingmai) then
      return
    end
    local maxLevel = get_maxlevel_by_conditions(jingmai)
    local curlevel = jingmaiobj:QueryProp("Level")
    if nx_int(maxLevel) > nx_int(curlevel) then
      faculty_num = faculty_num + 1
    end
  end
  form.mltbox_use_jmtext.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_jingmai_number", nx_widestr(faculty_num), nx_widestr(faculty_count)))
end
