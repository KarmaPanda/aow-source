require("util_gui")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\sweet_employ_define")
require("form_stage_main\\form_sweet_employ\\sweet_employ_common")
local FORM_GROW_PET = "form_stage_main\\form_sweet_employ\\form_grow_pet"
local FORM_CONFIRM = "form_common\\form_confirm"
local FORM_ESCORT = "form_stage_main\\form_school_war\\form_escort"
local INI_GROW_PET = "share\\SweetEmploy\\Grow\\Grow_pet.ini"
local table_tacit_value = {}
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
  form.Left = (gui.Width - form.Width) / 2 + 300
  form.Top = (gui.Height - form.Height) / 2
end
function load_grow_config()
  local ini = get_ini(INI_GROW_PET)
  if not nx_is_valid(ini) then
    return
  end
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local level = ini:GetSectionByIndex(i)
    local value = ini:ReadInteger(i, "cur_value", 0)
    table_tacit_value[nx_number(level)] = nx_int(value)
  end
end
function set_pet_name(form)
  local name = get_data_from_rec(REC_PET_SHOW, 0, REC_SHOW_NAME)
  if nx_string(name) == "" then
    return
  end
  form.lbl_name.Text = nx_widestr(name)
end
function get_tacit_level()
  local row = 0
  return get_data_from_rec(REC_PET_SHOW, row, REC_SHOW_TACIT_LEVEL)
end
function set_tacit_level(form)
  local level = get_tacit_level()
  if nx_int(level) < nx_int(MIN_LEVEL_TACIT) or nx_int(level) > nx_int(MAX_LEVEL_TACIT) then
    return
  end
  form.lbl_tacit_level.Text = nx_widestr(level)
end
function get_tacit_value()
  local row = 0
  return get_data_from_rec(REC_PET_SHOW, row, REC_SHOW_TACIT_VALUE)
end
function set_tacit_value(form)
  load_grow_config()
  local value = get_tacit_value()
  local level = get_tacit_level()
  if nx_int(level) < nx_int(MIN_LEVEL_TACIT) or nx_int(level) > nx_int(MAX_LEVEL_TACIT) then
    return
  end
  local max_value = 0
  if table_tacit_value[nx_number(level)] ~= nil then
    max_value = table_tacit_value[nx_number(level)]
  end
  local text = util_format_string("ui_sweetemploy_22", value, max_value)
  form.lbl_tacit_value.Text = nx_widestr(text)
  form.pbar_tacit_value.Value = value
  form.pbar_tacit_value.Maximum = max_value
end
function get_level_title()
  local row = 0
  local level = get_data_from_rec(REC_PET_SHOW, row, REC_SHOW_POWERLEVEL)
  return nx_execute(FORM_ESCORT, "Get_PowerLevel_Name", level)
end
function set_level_title(form)
  local title = nx_string(get_level_title())
  form.lbl_level_title.Text = nx_widestr(title)
end
function set_form_data(form)
  load_grow_config()
  set_pet_name(form)
  set_tacit_level(form)
  set_tacit_value(form)
  set_level_title(form)
  local txt = nx_string(get_player_prop("CurPetNeiGong"))
  form.lbl_neigong.Text = util_text(txt)
  local taolu = nx_string(get_player_prop("CurPetTaoLu"))
  form.lbl_wuxue.Text = util_text(taolu)
end
function add_data_bind(form)
  local binder = nx_value("data_binder")
  if not nx_is_valid(binder) then
    return
  end
  binder:AddTableBind(REC_PET_SHOW, form, nx_current(), "on_rec_pet_show_change")
end
function on_rec_pet_show_change(form, rec_name, opt_type, row, col)
  set_form_data(form)
end
