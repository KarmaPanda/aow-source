require("util_gui")
require("util_functions")
REC_PLAYER_COL = 1
REC_DAMAGE_COL = 2
REC_COLNUM = 2
local FORM = "form_stage_main\\form_task\\form_yubi_activity"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.self_row = 0
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_server_msg(sub_msg, ...)
  local form = nx_execute("util_gui", "util_get_form", FORM, true, false, 1)
  form:Show()
  if not nx_is_valid(form) then
    return
  end
  if nx_int(sub_msg) == nx_int(3) then
    on_refresh_form(form, unpack(arg))
  end
end
function on_refresh_form(form, ...)
  local temp_table = {}
  temp_table = arg
  if nx_number(table.getn(temp_table)) < nx_number(2) then
    return
  end
  local rows = temp_table[1]
  form.self_row = temp_table[2] + 1
  table.remove(temp_table, 1)
  table.remove(temp_table, 1)
  local gui = nx_value("gui")
  local grid = form.grid_yubi
  grid:ClearRow()
  local index = 1
  for i = index, rows do
    local player_name = nx_widestr(temp_table[(i - 1) * REC_COLNUM + REC_PLAYER_COL])
    local damage = nx_widestr(temp_table[(i - 1) * REC_COLNUM + REC_DAMAGE_COL])
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(row + 1))
    grid:SetGridText(row, 1, nx_widestr(player_name))
    grid:SetGridText(row, 2, nx_widestr(damage))
  end
  on_refresh_selfdata(form)
end
function on_refresh_selfdata(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_int(form.self_row) > nx_int(0) then
    form.lbl_snum.Text = nx_widestr(form.self_row)
  else
    form.lbl_snum.Text = nx_widestr("--")
  end
  local self_name = client_player:QueryProp("Name")
  form.lbl_sname.Text = nx_widestr(self_name)
  local self_damage = client_player:QueryProp("YubiDamage")
  form.lbl_sdamage.Text = nx_widestr(self_damage)
end
