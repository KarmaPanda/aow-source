require("util_gui")
local FORM_GUILD_LOOK_COMPETE = "form_stage_main\\form_guild_domain\\form_guild_look_compete"
local DC_STAGE_NONE = 0
local DC_STAGE_FIRST_TURN = 1
local DC_STAGE_SECOND_TURN = 2
local DC_STAGE_THIRD_TURN = 3
local DC_STAGE_SELECT = 4
local ST_FUNCTION_NEW_GUILDWAR = 219
function main_form_init(form)
  form.Fixed = true
  form.stage = DC_STAGE_NONE
end
function on_main_form_open(form)
  local gui = nx_value("gui")
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_time", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form_guild_domain_map
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_new_map")
  else
    form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_declare", "show_or_hide_declare_result", form_guild_domain_map)
end
function on_textgrid_compete_mousein_row_changed(grid, new_row, old_row)
  local form = grid.ParentForm
  if new_row < 0 or nx_int(form.stage) ~= nx_int(DC_STAGE_NONE) then
    grid.HintText = ""
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = nx_string(form.Name) .. nx_string(new_row)
  if not common_array:FindArray(array_name) then
    return
  end
  local self_silver = common_array:FindChild(array_name, nx_string(4))
  local guild_silver = common_array:FindChild(array_name, nx_string(5))
  grid.HintText = nx_widestr(util_format_string("ui_declare_result_tips", nx_int(self_silver), nx_int(guild_silver)))
end
function open_form_by_server_data(...)
  local form = nx_value(FORM_GUILD_LOOK_COMPETE)
  if not nx_is_valid(form) then
    return
  end
  local stage = arg[1]
  form.stage = DC_STAGE_NONE
  local select_index = arg[3]
  form.lbl_title.Text = nx_widestr(util_text("ui_gc_title_" .. nx_string(stage)))
  form.textgrid_compete:SetColTitle(0, nx_widestr(util_text("ui_guildcompete_guild_name")))
  form.textgrid_compete:SetColTitle(1, nx_widestr(util_text("ui_guildcompete_guild_host")))
  table.remove(arg, 1)
  table.remove(arg, 1)
  table.remove(arg, 1)
  table.remove(arg, 1)
  if stage >= DC_STAGE_FIRST_TURN and stage <= DC_STAGE_THIRD_TURN then
    form.textgrid_compete:SetColTitle(2, nx_widestr(util_text("ui_guild_compete_status")))
    random_arrange_result(form, unpack(arg))
  else
    form.textgrid_compete:SetColTitle(2, nx_widestr(util_text("ui_guild_compete_money")))
    init_compete_grid(form, select_index, unpack(arg))
  end
end
function show_declare_result(...)
  local form = nx_value(FORM_GUILD_LOOK_COMPETE)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  form.stage = stage
  form.lbl_title.Text = nx_widestr(util_text("ui_dr_title"))
  form.textgrid_compete:SetColTitle(0, nx_widestr(util_text("ui_dr_col_name_0")))
  form.textgrid_compete:SetColTitle(1, nx_widestr(util_text("ui_dr_col_name_2")))
  form.textgrid_compete:SetColTitle(2, nx_widestr(util_text("ui_dr_col_name_1")))
  form.textgrid_compete:ClearRow()
  local gui = nx_value("gui")
  local rows = #arg / 5
  for i = 0, rows - 1 do
    local row = form.textgrid_compete:InsertRow(-1)
    form.textgrid_compete:SetGridText(row, 0, nx_widestr(arg[i * 5 + 1]))
    form.textgrid_compete:SetGridText(row, 1, nx_widestr(arg[i * 5 + 3]))
    form.textgrid_compete:SetGridText(row, 2, nx_widestr(util_text("ui_dipan_" .. nx_string(arg[i * 5 + 2]))))
    local array_name = nx_string(form.Name) .. nx_string(row)
    if common_array:FindArray(array_name) then
      common_array:RemoveArray(array_name)
    end
    common_array:AddArray(array_name, form, 60, true)
    common_array:AddChild(array_name, nx_string(4), nx_widestr(arg[i * 5 + 4]))
    common_array:AddChild(array_name, nx_string(5), nx_widestr(arg[i * 5 + 5]))
  end
end
function init_compete_grid(form, select_index, ...)
  local gui = nx_value("gui")
  local rows = #arg / 3
  form.textgrid_compete:ClearRow()
  for i = 0, rows - 1 do
    local row = form.textgrid_compete:InsertRow(-1)
    form.textgrid_compete:SetGridText(row, 0, nx_widestr(arg[i * 3 + 1]))
    form.textgrid_compete:SetGridText(row, 1, nx_widestr(arg[i * 3 + 2]))
    form.textgrid_compete:SetGridText(row, 2, nx_widestr(gui.TextManager:GetFormatText("ui_gc_money", nx_int(arg[i * 3 + 3]))))
    local color = "255,76,61,44"
    if row < select_index - 1 then
      color = "255,0,255,0"
    end
    for i = 0, 2 do
      form.textgrid_compete:SetGridForeColor(row, i, color)
    end
  end
end
function random_arrange_result(form, ...)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  form.textgrid_compete:ClearRow()
  math.randomseed(os.time())
  local rows = #arg / 3
  for i = 0, rows - 1 do
    local rand_index = math.random(0, #arg / 3 - 1)
    local row = 0
    local text = "ui_guild_compete"
    if nx_widestr(guild_name) == nx_widestr(arg[rand_index * 3 + 1]) then
      row = form.textgrid_compete:InsertRow(0)
      if row == 0 then
        local pos = arg[rand_index * 3 + 3]
        if pos <= 3 then
          text = "ui_guild_compete_pos_1"
        elseif pos <= 10 then
          text = "ui_guild_compete_pos_2"
        else
          text = "ui_guild_compete_pos_3"
        end
      end
    else
      row = form.textgrid_compete:InsertRow(-1)
    end
    form.textgrid_compete:SetGridText(row, 0, nx_widestr(arg[rand_index * 3 + 1]))
    form.textgrid_compete:SetGridText(row, 1, nx_widestr(arg[rand_index * 3 + 2]))
    form.textgrid_compete:SetGridText(row, 2, nx_widestr(util_text(text)))
    table.remove(arg, rand_index * 3 + 1)
    table.remove(arg, rand_index * 3 + 1)
    table.remove(arg, rand_index * 3 + 1)
  end
end
