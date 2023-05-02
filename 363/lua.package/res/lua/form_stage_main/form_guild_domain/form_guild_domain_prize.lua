require("util_functions")
require("share\\client_custom_define")
require("role_composite")
local CLIENT_SUBMSG_AWARD_SUZHOU_OCCUPY = 39
local TYPE_AWARD_SUZHOU_OCCUPY = 2
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  gui.Desktop:ToFront(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_award_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_AWARD_SUZHOU_OCCUPY))
end
function on_imagegrid_award_item_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == nx_string("") then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", nx_string(item_config), grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_award_item_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_form(...)
  if table.getn(arg) < 1 then
    return
  end
  local extra_data_num = 1
  local award_flag = nx_int(arg[1])
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuildDomainAwardExtra.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(TYPE_AWARD_SUZHOU_OCCUPY))
  if index < 0 then
    return
  end
  local cycle = ini:ReadInteger(index, "Cycle", 5)
  local award_item = ini:ReadString(index, "AwardItem", "")
  local arg_num = table.getn(arg)
  local vaild_num = 2 * cycle
  if nx_int(arg_num - extra_data_num) ~= nx_int(vaild_num) then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.btn_award.Enabled = false
  if nx_int(award_flag) == nx_int(1) then
    form.btn_award.Enabled = true
  end
  local photo = ItemQuery:GetItemPropByConfigID(nx_string(award_item), "Photo")
  form.imagegrid_award_item:AddItem(0, nx_string(photo), nx_widestr(award_item), nx_int(1), nx_int(-1))
  form.textgrid_occupy_list:ClearRow()
  form.textgrid_occupy_list:SetColTitle(0, nx_widestr(util_text("ui_activity_rank")))
  form.textgrid_occupy_list:SetColTitle(1, nx_widestr(util_text("ui_activity_name")))
  local base_index = extra_data_num + 1
  for i = base_index, table.getn(arg), 2 do
    local occupy_date = nx_double(arg[i])
    local occupy_guildname = nx_widestr(arg[i + 1])
    local occupy_end_date = occupy_date + nx_double(6)
    local b_year, b_month, b_day, b_hour, b_mins, b_sec = nx_function("ext_decode_date", nx_double(occupy_date))
    local e_year, e_month, e_day, e_hour, e_mins, e_sec = nx_function("ext_decode_date", nx_double(occupy_end_date))
    local row = form.textgrid_occupy_list:InsertRow(-1)
    local date_text = util_format_string(nx_string("ui_guildnew_jiaozi_time"), nx_int(b_year), nx_int(b_month), nx_int(b_day), nx_int(e_year), nx_int(e_month), nx_int(e_day))
    form.textgrid_occupy_list:SetGridText(row, 0, nx_widestr(date_text))
    form.textgrid_occupy_list:SetGridText(row, 1, nx_widestr(occupy_guildname))
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_award)
  if not nx_is_valid(form.scenebox_award.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_award)
  end
  local actor2 = form.scenebox_award.Scene:Create("Actor2")
  if not nx_is_valid(actor2) then
    return
  end
  actor2.AsyncLoad = true
  load_from_ini(actor2, nx_string("ini\\npc\\ride_banghui_01.ini"))
  if not nx_is_valid(actor2) or actor2 == nil then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  actor2:SetScale(0.5, 0.5, 0.5)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_award, actor2)
  nx_execute(nx_current(), "rotate_y", actor2, math.pi / 6)
end
function rotate_y(mode, rotate_y)
  local angle = 0
  while nx_is_valid(mode) do
    angle = rotate_y * nx_pause(0)
    if nx_is_valid(mode) then
      mode:SetAngle(mode.AngleX, mode.AngleY + angle, mode.AngleZ)
    end
  end
end
