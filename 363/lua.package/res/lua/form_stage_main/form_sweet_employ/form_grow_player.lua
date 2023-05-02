require("util_gui")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\sweet_employ_define")
require("form_stage_main\\form_sweet_employ\\sweet_employ_common")
local FORM_GROW_PLAYER = "form_stage_main\\form_sweet_employ\\form_grow_player"
local FORM_CONFIRM = "form_common\\form_confirm"
local FORM_ESCORT = "form_stage_main\\form_school_war\\form_escort"
local FORM_BUY_CHARM = "form_stage_main\\form_sweet_employ\\form_buy_charm"
local FORM_BUY_INSTRUCTION = "form_stage_main\\form_sweet_employ\\form_buy_instruction"
local INI_GROW_PLAYER = "share\\SweetEmploy\\Grow\\Grow_player.ini"
local table_used_charm_value = {}
local table_cur_charm_value = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  add_data_bind(form)
  set_form_data(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 300
  form.Top = (gui.Height - form.Height) / 2
end
function load_grow_config()
  local ini = get_ini(INI_GROW_PLAYER)
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local level = ini:GetSectionByIndex(i)
    local use_value = ini:ReadInteger(i, "use_value", 0)
    local cur_value = ini:ReadInteger(i, "cur_value", 0)
    local level_ration = ini:ReadInteger(i, "level_ration", 0)
    table_used_charm_value[nx_number(level)] = nx_int(use_value)
    table_cur_charm_value[nx_number(level)] = nx_int(cur_value)
  end
end
function set_player_name(form)
  local name = get_player_prop("Name")
  form.lbl_name.Text = nx_widestr(name)
end
function set_charm_level(form)
  local level = get_player_prop("CharmLevel")
  if nx_int(level) < nx_int(MIN_LEVEL_CHARM) or nx_int(level) > nx_int(MAX_LEVEL_CHARM) then
    return
  end
  form.lbl_charm_level.Text = nx_widestr(level)
end
function set_used_charm_value(form)
  load_grow_config()
  local value = nx_int(get_player_prop("UsedCharmValue"))
  local level = get_player_prop("CharmLevel")
  if nx_int(level) < nx_int(MIN_LEVEL_CHARM) or nx_int(level) > nx_int(MAX_LEVEL_CHARM) then
    return
  end
  local max_value = 0
  if table_used_charm_value[nx_number(level)] ~= nil then
    max_value = table_used_charm_value[nx_number(level)]
  end
  local text = util_format_string("ui_sweetemploy_22", value, max_value)
  form.lbl_used_charm_value.Text = nx_widestr(text)
  form.pbar_used_charm_value.Value = value
  form.pbar_used_charm_value.Maximum = max_value
end
function set_charm_value(form)
  load_grow_config()
  local value = nx_int(get_player_prop("CharmValue"))
  local level = get_player_prop("CharmLevel")
  if nx_int(level) < nx_int(MIN_LEVEL_CHARM) or nx_int(level) > nx_int(MAX_LEVEL_CHARM) then
    return
  end
  local max_value = 0
  if table_cur_charm_value[nx_number(level)] ~= nil then
    max_value = table_cur_charm_value[nx_number(level)]
  end
  local text = util_format_string("ui_sweetemploy_22", value, max_value)
  form.lbl_charm_value.Text = nx_widestr(text)
end
function get_level_title(form)
  local power_level = nx_int(get_player_prop("PowerLevel"))
  local charm_level = nx_int(get_player_prop("CharmLevel"))
  if nx_int(charm_level) < nx_int(MIN_LEVEL_CHARM) or nx_int(charm_level) > nx_int(MAX_LEVEL_CHARM) then
    return
  end
  local level = nx_int(5 * (nx_int(power_level / 5) + nx_int(charm_level / 4) + 1))
  if nx_int(level) < nx_int(MIN_POWER_LEVEL) then
    level = MIN_POWER_LEVEL
  elseif nx_int(level) > nx_int(MAX_POWER_LEVEL) then
    level = MAX_POWER_LEVEL
  end
  return nx_execute(FORM_ESCORT, "Get_PowerLevel_Name", level)
end
function set_level_title(form)
  local title = get_level_title(form)
  form.lbl_level_title.Text = nx_widestr(title)
end
function set_form_data(form)
  load_grow_config()
  set_player_name(form)
  set_charm_level(form)
  set_used_charm_value(form)
  set_charm_value(form)
  set_level_title(form)
end
function add_data_bind(form)
  local binder = nx_value("data_binder")
  if not nx_is_valid(binder) then
    return
  end
  binder:AddRolePropertyBind("CharmLevel", "int", form, nx_current(), "on_charm_level_change")
  binder:AddRolePropertyBind("UsedCharmValue", "int", form, nx_current(), "on_used_charm_value_change")
  binder:AddRolePropertyBind("CharmValue", "int", form, nx_current(), "on_charm_value_change")
  binder:AddRolePropertyBind("PowerLevel", "int", form, nx_current(), "on_power_level_change")
end
function on_charm_level_change(form)
  set_form_data(form)
end
function on_used_charm_value_change(form)
  set_used_charm_value(form)
end
function on_charm_value_change(form)
  set_charm_value(form)
end
function on_power_level_change(form)
  set_level_title(form)
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_show_form(FORM_BUY_INSTRUCTION, true)
end
