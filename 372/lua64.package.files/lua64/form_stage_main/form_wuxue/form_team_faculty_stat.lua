require("util_gui")
require("util_functions")
require("share\\view_define")
local MAX_MEMBER = 10
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  change_form_size()
  on_refresh_info(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_refresh_info(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_TEAM_FACULTY))
  if not nx_is_valid(view) then
    return
  end
  local row_count = view:GetRecordRows("team_faculty_rec")
  if nx_int(row_count) > nx_int(MAX_MEMBER) then
    row_count = nx_int(MAX_MEMBER)
  end
  form.textgrid_info:BeginUpdate()
  form.textgrid_info:ClearRow()
  form.textgrid_info:SetColTitle(0, nx_widestr(util_text("ui_schoolwar_order")))
  form.textgrid_info:SetColTitle(1, nx_widestr(util_text("ui_Player")))
  form.textgrid_info:SetColTitle(2, nx_widestr(util_text("ui_train_team_defen")))
  for row = 0, row_count - 1 do
    local name = view:QueryRecord("team_faculty_rec", row, 2)
    local score = view:QueryRecord("team_faculty_rec", row, 3)
    form.textgrid_info:InsertRow(-1)
    form.textgrid_info:SetGridText(row, 1, nx_widestr(name))
    form.textgrid_info:SetGridText(row, 2, nx_widestr(score))
  end
  form.textgrid_info:SortRowsByInt(2, true)
  for i = 1, row_count do
    form.textgrid_info:SetGridText(i - 1, 0, nx_widestr(i))
  end
  form.textgrid_info:EndUpdate()
  form.lbl_score.Text = nx_widestr(view:QueryProp("TotalScore"))
  form.lbl_queue.Text = nx_widestr(view:QueryProp("MaxQueue"))
end
function change_form_size()
  local form = util_get_form("form_stage_main\\form_wuxue\\form_team_faculty_stat", false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
