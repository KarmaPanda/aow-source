require("util_gui")
local PlayerInfoSize = 2
function main_form_init(self)
  self.Fixed = false
end
function show_rank_form(...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_fight\\form_masses_fight_rank", true, false)
  if nx_is_valid(dialog) then
    dialog:Show()
    nx_set_value("form_stage_main\\form_fight\\form_masses_fight_rank", dialog)
    on_get_msg(dialog, arg)
  end
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.grid_rank.ColCount = nx_int(PlayerInfoSize) + 1
  form.grid_rank.ColWidths = "96,110,118"
  form.grid_rank:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_schoolwar_order")))
  form.grid_rank:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_name")))
  form.grid_rank:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_qunzhan_fight_01")))
  local thd_manager = nx_value("TaohuadaoManager")
  if not nx_is_valid(thd_manager) then
    nx_msgbox("In valid taohuad")
    return
  end
end
function on_get_msg(form, args)
  if not nx_is_valid(form) then
    return
  end
  form.grid_rank:BeginUpdate()
  local count = #args
  local gui = nx_value("gui")
  if count < PlayerInfoSize or math.mod(count, PlayerInfoSize) ~= 0 then
    return
  end
  form.grid_rank:ClearRow()
  for i = 0, count / PlayerInfoSize - 1 do
    row = form.grid_rank:InsertRow(-1)
    form.grid_rank:SetGridText(row, 0, nx_widestr(nx_int(i) + 1))
    form.grid_rank:SetGridText(row, 1, nx_widestr(args[i * PlayerInfoSize + 1]))
    form.grid_rank:SetGridText(row, 2, nx_widestr(args[i * PlayerInfoSize + 2]))
  end
  form.grid_rank:EndUpdate()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local thd_manager = nx_value("TaohuadaoManager")
  if nx_is_valid(thd_manager) then
    thd_manager:EndRankTimer()
  end
  form:Close()
end
