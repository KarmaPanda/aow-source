require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_jhscene_boss_stat"
local CLIENT_MSG_JHSCENE_BOSS_PRIZE = 0
function main_form_init(form)
  if not nx_is_valid(form) then
    return
  end
  form.Fixed = false
  form.npcid = nil
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
  form.grid_info:SetColTitle(0, nx_widestr(util_text("ui_jhscene_boss_player_rank")))
  form.grid_info:SetColTitle(1, nx_widestr(util_text("ui_jhscene_boss_player_name")))
  form.grid_info:SetColTitle(2, nx_widestr(util_text("ui_jhscene_boss_player_amount")))
  return
end
function on_btn_close_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  btn.ParentForm:Close()
end
function on_btn_prize_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_send_world_boss", CLIENT_MSG_JHSCENE_BOSS_PRIZE, form.npcid)
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
  form.npcid = arg[1]
  if nx_string(form.npcid) == nx_string("") then
    form.btn_prize.Visible = false
  end
  local rank = nx_int(arg[2])
  if nx_int(rank) <= nx_int(0) then
    form.lbl_myrank.Text = nx_widestr("")
    form.btn_prize.Enabled = false
  else
    form.lbl_myrank.Text = nx_widestr(rank)
  end
  local count = #arg - 2
  local PlayerInfoSize = 2
  if count < PlayerInfoSize or math.mod(count, PlayerInfoSize) ~= 0 then
    return
  end
  for i = 1, count / PlayerInfoSize do
    local row = form.grid_info:InsertRow(-1)
    form.grid_info:SetGridText(row, 0, nx_widestr(i))
    form.grid_info:SetGridText(row, 1, nx_widestr(arg[i * PlayerInfoSize + 1]))
    form.grid_info:SetGridText(row, 2, nx_widestr(arg[i * PlayerInfoSize + 2]))
  end
end
