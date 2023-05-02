require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_force\\form_force_wxj_smdh"
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Visible = true
  form:Show()
  form.rbtn_con.Checked = true
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_con_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.rbtn_damage.Checked = false
  set_rank_title(form, 1)
  nx_execute("custom_sender", "custom_wxj_schoolmeet", 1)
end
function on_rbtn_damage_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.rbtn_con.Checked = false
  set_rank_title(form, 2)
  nx_execute("custom_sender", "custom_wxj_schoolmeet", 2)
end
function server_msg_handle(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local sub_msg = arg[1]
  if nx_number(0) == nx_number(sub_msg) then
    if table.getn(arg) < 4 then
      return
    end
    if not form.rbtn_con.Checked then
      return
    end
    local name_str = nx_widestr(arg[2])
    local gx_str = nx_string(arg[3])
    local my_gx_value = nx_int(arg[4])
    set_rank_title(form, 1)
    update_rank_con(form, name_str, gx_str, my_gx_value)
  elseif nx_number(1) == nx_number(sub_msg) then
    if table.getn(arg) < 3 then
      return
    end
    if not form.rbtn_damage.Checked then
      return
    end
    local name_str = nx_widestr(arg[2])
    local damage_str = nx_string(arg[3])
    set_rank_title(form, 2)
    update_rank_damage(form, name_str, damage_str)
  end
end
function set_rank_title(form, index)
  local gui = nx_value("gui")
  form.textgrid_con:ClearRow()
  form.textgrid_my_con:ClearRow()
  if nx_int(index) == nx_int(1) then
    form.textgrid_con:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_at_con_list_0")))
    form.textgrid_con:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_ssg_player_name")))
    form.textgrid_con:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_at_con_list_2")))
  elseif nx_int(index) == nx_int(2) then
    form.textgrid_con:SetColTitle(0, nx_widestr(gui.TextManager:GetText("ui_at_damage_list_0")))
    form.textgrid_con:SetColTitle(1, nx_widestr(gui.TextManager:GetText("ui_ssg_player_name")))
    form.textgrid_con:SetColTitle(2, nx_widestr(gui.TextManager:GetText("ui_wxj_smdh_02")))
  end
end
function update_rank_con(form, name_str, gx_str, my_gx_value)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local player_name = client_player:QueryProp("Name")
  local player_num = 0
  local name_tab = {}
  local gx_tab = {}
  if nx_widestr(name_str) ~= nx_widestr("") then
    name_tab = util_split_wstring(nx_widestr(name_str), ",")
    gx_tab = util_split_string(nx_string(gx_str), ",")
  end
  for i = 1, table.getn(name_tab) do
    local row = form.textgrid_con:InsertRow(-1)
    form.textgrid_con:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_con:SetGridText(row, 1, nx_widestr(name_tab[i]))
    form.textgrid_con:SetGridText(row, 2, nx_widestr(gx_tab[i]))
    if nx_widestr(name_tab[i]) == nx_widestr(player_name) then
      player_num = i
    end
  end
  if nx_int(my_gx_value) >= nx_int(0) then
    local row = form.textgrid_my_con:InsertRow(-1)
    if nx_int(player_num) > nx_int(0) then
      form.textgrid_my_con:SetGridText(row, 0, nx_widestr(player_num))
    else
      form.textgrid_my_con:SetGridText(row, 0, nx_widestr("--"))
    end
    form.textgrid_my_con:SetGridText(row, 1, nx_widestr(player_name))
    form.textgrid_my_con:SetGridText(row, 2, nx_widestr(my_gx_value))
  else
    local row = form.textgrid_my_con:InsertRow(-1)
    form.textgrid_my_con:SetGridText(row, 0, nx_widestr("--"))
    form.textgrid_my_con:SetGridText(row, 1, nx_widestr("--"))
    form.textgrid_my_con:SetGridText(row, 2, nx_widestr("--"))
  end
end
function update_rank_damage(form, name_str, damage_str)
  local name_tab = {}
  local damage_tab = {}
  if nx_widestr(name_str) ~= nx_widestr("") then
    name_tab = util_split_wstring(nx_widestr(name_str), ",")
    damage_tab = util_split_string(nx_string(damage_str), ",")
  end
  for i = 1, table.getn(name_tab) do
    local row = form.textgrid_con:InsertRow(-1)
    form.textgrid_con:SetGridText(row, 0, nx_widestr(i))
    form.textgrid_con:SetGridText(row, 1, nx_widestr(name_tab[i]))
    form.textgrid_con:SetGridText(row, 2, nx_widestr(damage_tab[i]))
  end
end
