require("utils")
require("util_gui")
require("const_define")
require("form_stage_main\\form_fight\\form_fight_main")
local STALL_INFO_NUM = 6
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  refresh_fight_view_form(self)
end
function on_main_form_close(self)
  nx_destroy(self)
end
function refresh_fight_view_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.textgrid_view:BeginUpdate()
  form.textgrid_view:ClearRow()
  form.textgrid_view.ColCount = 7
  form.textgrid_view.ColWidths = "90, 90, 90, 90, 90, 90, 90"
  form.textgrid_view:SetColTitle(0, nx_widestr(util_text("ui_arena_query_11")))
  form.textgrid_view:SetColTitle(1, nx_widestr(util_text("ui_arena_query_12")))
  form.textgrid_view:SetColTitle(2, nx_widestr(util_text("ui_arena_query_13")))
  form.textgrid_view:SetColTitle(3, nx_widestr(util_text("ui_arena_query_14")))
  form.textgrid_view:SetColTitle(4, nx_widestr(util_text("ui_arena_query_15")))
  form.textgrid_view:SetColTitle(5, nx_widestr(util_text("ui_arena_query_16")))
  form.textgrid_view:SetColTitle(6, nx_widestr(util_text("ui_arena_query_17")))
  local string_table = util_split_wstring(nx_widestr(form.info_string), ",")
  local stall_num = form.row
  local begin_index = 1
  for i = 0, stall_num - 1 do
    local row = form.textgrid_view:InsertRow(-1)
    local btn = gui:Create("Button")
    btn.Text = nx_widestr(util_text("ui_arena_query_9"))
    btn.NormalImage = "gui\\special\\jianghu_log\\btn_month_out.png"
    btn.FocusImage = "gui\\special\\jianghu_log\\btn_month_on.png"
    btn.PushImage = "gui\\special\\jianghu_log\\btn_month_down.png"
    btn.DrawMode = "ExpandH"
    btn.sence = nx_widestr(string_table[begin_index])
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_enter_click")
    form.textgrid_view:SetGridText(row, 0, nx_widestr(string_table[begin_index]))
    form.textgrid_view:SetGridText(row, 1, nx_widestr(string_table[begin_index + 1]))
    form.textgrid_view:SetGridText(row, 2, nx_widestr(string_table[begin_index + 2]))
    form.textgrid_view:SetGridText(row, 3, nx_widestr(string_table[begin_index + 3]))
    form.textgrid_view:SetGridText(row, 4, nx_widestr(string_table[begin_index + 4]))
    form.textgrid_view:SetGridText(row, 5, nx_widestr(string_table[begin_index + 5]))
    form.textgrid_view:SetGridControl(row, 6, btn)
    begin_index = begin_index + STALL_INFO_NUM
  end
  form.textgrid_view:EndUpdate()
end
function on_enter_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if self.sence == nil then
    return
  end
  nx_execute("custom_sender", "custom_arena_join", nx_int(self.sence))
  form:Close()
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_msg(arg1, arg2)
  local form_view = util_get_form("form_stage_main\\form_fight\\form_fight_view", true)
  if arg1 == nil or arg2 == nil then
    return
  end
  form_view.row = nx_int(arg1)
  form_view.info_string = nx_widestr(arg2)
  util_show_form(nx_current(), true)
end
