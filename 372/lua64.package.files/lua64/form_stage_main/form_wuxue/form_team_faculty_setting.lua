require("util_gui")
require("util_functions")
local PERCEPTION_MAX_POINT = 490
local SUB_CLIENT_OPEN = 1
local SUB_CLIENT_SET = 2
local SUB_CLIENT_BEGIN = 3
local SUB_CLIENT_EXIT = 4
TEAM_FACULTY_TYPE_NORMAL = 0
TEAM_FACULTY_TYPE_DONGFANG = 1
TEAM_FACULTY_TYPE_TEACHER = 2
TEAM_FACULTY_TYPE_JIUGONG = 3
function main_form_init(self)
  self.Fixed = false
  self.zhenxing_index = 0
  self.taolu = ""
end
function on_main_form_open(self)
  change_form_size()
  refresh_form(self)
  if not nx_find_custom(self, "is_help") then
    self.btn_begin.Enabled = false
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("HeapPerceptionPoint", "int", self, nx_current(), "on_jiugong_heap_Perception_Point")
  end
  self.mltbox_1.HtmlText = nx_widestr(util_text("ui_train_team_intr"))
end
function on_main_form_close(self)
  local helper_form = nx_value("helper_form")
  if nil == helper_form or not helper_form then
    nx_destroy(self)
  end
end
function on_main_form_shut(self)
end
function on_btn_begin_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.taolu == "" then
    return
  end
  nx_execute("custom_sender", "custom_team_faculty", SUB_CLIENT_OPEN, nx_string(form.taolu))
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_return_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_faculty", true)
end
function on_textgrid_taolu_select_row(self, row)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_taolu.ini")
  if not nx_is_valid(ini) then
    return
  end
  form.taolu = ini:GetSectionByIndex(row)
  form.btn_begin.Enabled = true
  form.mltbox_taolu.HtmlText = nx_widestr(util_text("ui_" .. nx_string(form.taolu)))
  local play_type = ini:ReadInteger(row, "PlayType", 0)
  if nx_int(play_type) == nx_int(TEAM_FACULTY_TYPE_JIUGONG) then
    on_jiugong_heap_Perception_Point(form)
  else
    form.mltbox_1.HtmlText = nx_widestr(util_text("ui_train_team_intr"))
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function refresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_taolu:BeginUpdate()
  form.textgrid_taolu:ClearRow()
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\faculty_team_taolu.ini")
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 1, count do
    local play_type = ini:ReadInteger(i - 1, "PlayType", 0)
    if nx_int(play_type) ~= nx_int(TEAM_FACULTY_TYPE_DONGFANG) then
      local taolu_name = ini:GetSectionByIndex(i - 1)
      local row = form.textgrid_taolu:InsertRow(-1)
      form.textgrid_taolu:SetGridText(row, 0, nx_widestr(util_text(taolu_name)))
    end
  end
  form.textgrid_taolu:EndUpdate()
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_team_faculty_setting", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_jiugong_heap_Perception_Point(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local Perception_Point = client_player:QueryProp("HeapPerceptionPoint")
  if nx_int(Perception_Point) <= nx_int(0) then
    form.mltbox_1.HtmlText = nx_widestr(util_text("ui_xl_thd_002"))
  elseif nx_int(Perception_Point) >= nx_int(PERCEPTION_MAX_POINT) then
    form.mltbox_1.HtmlText = nx_widestr(util_text("ui_xl_thd_002")) .. nx_widestr(util_text("ui_xl_thd_004"))
  else
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_xl_thd_003", nx_int(Perception_Point)))
    form.mltbox_1.HtmlText = nx_widestr(util_text("ui_xl_thd_002")) .. nx_widestr(text)
  end
end
