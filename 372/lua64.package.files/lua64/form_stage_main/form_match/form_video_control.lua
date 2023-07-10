require("util_functions")
require("util_gui")
require("define\\object_type_define")
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.textgrid_list:SetColTitle(0, nx_widestr("warname"))
  form.textgrid_list:SetColTitle(1, nx_widestr("playera"))
  form.textgrid_list:SetColTitle(2, nx_widestr("playerb"))
  form.textgrid_list:SetColTitle(3, nx_widestr("scene"))
  form.textgrid_list:SetColTitle(4, nx_widestr("round"))
  on_btn_refresh_click(form.btn_refresh)
end
function on_main_form_close(form)
  reset_self_view()
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_enter_war_click(btn)
  nx_execute("custom_sender", "custom_revenge_match", 100)
end
function on_btn_leave_war_click(btn)
  nx_execute("custom_sender", "custom_revenge_match", 101)
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_list:ClearSelect()
  form.textgrid_list:ClearRow()
  nx_execute("custom_sender", "custom_revenge_match", 102, 0)
end
function on_btn_enter_match_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local row = form.textgrid_list.RowSelectIndex
  if row < 0 then
    return
  end
  local warname = nx_string(form.textgrid_list:GetGridText(row, 0))
  nx_execute("custom_sender", "custom_revenge_match", 103, warname)
end
function on_btn_xj_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local target = nx_value("game_select_obj")
  if not nx_is_valid(target) then
    return
  end
  local select_type = target:QueryProp("Type")
  if TYPE_PLAYER ~= nx_number(select_type) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetSceneObj(target.Ident)
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_control = client_player.scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Target = visual_player
  game_control.TargetMode = 1
end
function on_btn_xj_2_click(btn)
end
function on_btn_xj_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  reset_self_view()
end
function fresh_list(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(arg), 5 do
    local row = form.textgrid_list:InsertRow(-1)
    form.textgrid_list:SetGridText(row, 0, nx_widestr(arg[i + 0]))
    form.textgrid_list:SetGridText(row, 1, nx_widestr(arg[i + 1]))
    form.textgrid_list:SetGridText(row, 2, nx_widestr(arg[i + 2]))
    form.textgrid_list:SetGridText(row, 3, nx_widestr(arg[i + 3]))
    form.textgrid_list:SetGridText(row, 4, nx_widestr(arg[i + 4]))
  end
  form.textgrid_list:SortRowsByInt(4, false)
end
function reset_self_view()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_control = client_player.scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Target = nx_null()
  game_control.TargetMode = 0
end
