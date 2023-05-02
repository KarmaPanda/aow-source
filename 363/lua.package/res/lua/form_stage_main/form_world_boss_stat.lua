require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_world_boss_stat"
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  clear_grid(form)
  form.grid_info:SetColTitle(0, nx_widestr(util_text("ui_world_boss_team_rank")))
  form.grid_info:SetColTitle(1, nx_widestr(util_text("ui_world_boss_team_captain_name")))
  form.grid_info:SetColTitle(2, nx_widestr(util_text("ui_world_boss_team_amount")))
  return
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  btn.ParentForm:Close()
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function clear_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.grid_info
  grid:BeginUpdate()
  grid:ClearRow()
  grid:EndUpdate()
end
function on_server_msg(...)
  util_show_form(FORM_NAME, true)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_grid(form)
  local count = #arg
  local TeamInfoSize = 3
  if count < TeamInfoSize or math.mod(count, TeamInfoSize) ~= 0 then
    return
  end
  for i = 0, count / TeamInfoSize - 1 do
    local row = form.grid_info:InsertRow(-1)
    local rank_text = nx_widestr(i + 1)
    local team_status = arg[i * TeamInfoSize + 1]
    if team_status == 2 then
      rank_text = rank_text .. util_format_string("tips_leader_leave")
    end
    form.grid_info:SetGridText(row, 0, rank_text)
    form.grid_info:SetGridText(row, 1, nx_widestr(arg[i * TeamInfoSize + 2]))
    form.grid_info:SetGridText(row, 2, nx_widestr(arg[i * TeamInfoSize + 3]))
  end
end
