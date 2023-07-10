require("util_functions")
require("util_gui")
require("util_static_data")
require("form_stage_main\\switch\\switch_define")
local array_name = "ExtraSkillArray"
local skill_new_ini = "share\\Skill\\skill_new.ini"
local normal_varprop_ini = "share\\Skill\\skill_normal_varprop.ini"
local lock_varprop_ini = "share\\Skill\\skill_lock_varprop.ini"
SERVER_SUB_MSG_OPEN = 0
SERVER_SUB_MSG_CLOSE = 1
SERVER_SUB_MSG_CONTINUE = 2
local extra_skill_ini = "share\\Skill\\ExtraSkill\\extra_skill.ini"
function on_main_form_init(self)
  self.Fixed = false
  self.type = 0
end
function on_main_form_open(self)
  self.cost_ini = get_ini("ini\\ui\\wuxue\\extra_skill_cost.ini")
  init_form_location(self)
  init_extra_skill_check(self)
end
function on_main_form_close(self)
  local common_array = nx_value("common_array")
  if nx_is_valid(common_array) then
    common_array:RemoveArray(array_name)
  end
  save_form_location(self)
  save_extra_skill_check(self)
  nx_destroy(self)
end
function init_form_location(form)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_location.ini"
  if not ini:LoadFromFile() or not ini:FindSection("extra_skill_shutcut") then
    nx_destroy(ini)
    return
  end
  form.Left = ini:ReadInteger("extra_skill_shutcut", "left", 0)
  form.Top = ini:ReadInteger("extra_skill_shutcut", "top", 0)
  nx_destroy(ini)
end
function save_form_location(form)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_location.ini"
  ini:LoadFromFile()
  if not ini:FindSection("extra_skill_shutcut") then
    ini:AddSection("extra_skill_shutcut")
  end
  ini:WriteInteger("extra_skill_shutcut", "left", form.Left)
  ini:WriteInteger("extra_skill_shutcut", "top", form.Top)
  ini:SaveToFile()
  nx_destroy(ini)
end
function init_extra_skill_check(form)
  local game_config = nx_value("game_config")
  if not nx_custom(game_config, "extra_skill_check") then
    return
  end
  if game_config.extra_skill_check == 1 then
    form.cbtn_1.Checked = true
  end
end
function save_extra_skill_check(form)
  local game_config = nx_value("game_config")
  if form.cbtn_1.Checked == true then
    game_config.extra_skill_check = 1
  else
    game_config.extra_skill_check = 0
  end
end
function on_imagegrid_skill_mousein_grid(grid, index)
  local config_id = get_skill_id_by_index(index)
  local ITEMTYPE_ZHAOSHI = 1000
  if config_id ~= "" then
    local IniManager = nx_value("IniManager")
    local ini = IniManager:LoadIniToManager("share\\Skill\\skill_new.ini")
    if not nx_is_valid(ini) then
      return
    end
    local ini_index = ini:FindSectionIndex(nx_string(config_id))
    if nx_number(index) < 0 then
      return
    end
    local static_data = ini:ReadString(ini_index, "StaticData", "")
    local item_data = nx_execute("tips_game", "get_tips_ArrayList")
    item_data.ConfigID = nx_string(config_id)
    item_data.ItemType = nx_int(ITEMTYPE_ZHAOSHI)
    item_data.Level = 1
    item_data.MaxLevel = 1
    item_data.StaticData = nx_int(static_data)
    item_data.CoolDownTime = nx_number(get_skill_cool_by_index(index))
    nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
  end
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  local skill_id = get_skill_id_by_index(index)
  local skill_flag = get_skill_flag_by_index(index)
  if skill_id == "" or skill_flag == 0 then
    return
  end
  if nx_is_valid(form) then
    if form.cbtn_1.Checked then
      nx_execute("custom_sender", "custom_extra_skill", form.type, skill_flag)
    else
      local text = ""
      local skill_cost = 0
      if nx_is_valid(form.cost_ini) then
        local sec_index = form.cost_ini:FindSectionIndex(skill_id)
        skill_cost = nx_number(form.cost_ini:ReadInteger(sec_index, "cost", 0))
      end
      if skill_cost == 0 then
        nx_execute("custom_sender", "custom_extra_skill", form.type, skill_flag)
        return
      end
      local gui = nx_value("gui")
      if get_bind_card() >= 1000 then
        text = gui.TextManager:GetFormatText("ui_dstiguan_queding2", nx_int(skill_cost))
      else
        text = gui.TextManager:GetFormatText("ui_dstiguan_queding", nx_int(skill_cost))
      end
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
      dialog:ShowModal()
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
      local result = nx_wait_event(100000000, dialog, "confirm_return")
      if "ok" == result and nx_is_valid(form) then
        nx_execute("custom_sender", "custom_extra_skill", form.type, skill_flag)
      end
    end
  end
end
function update_grid(grid)
  grid:Clear()
  local grid_count = grid.ClomnNum * grid.RowNum
  for i = 0, grid_count - 1 do
    local skill_id = get_skill_id_by_index(i)
    if skill_id ~= "" then
      local photo = skill_static_query_by_id(skill_id, "Photo")
      grid:AddItem(i, photo, util_text(skill_id), 1, -1)
      local cool_type = skill_static_query_by_id(skill_id, "CoolDownCategory")
      grid:SetCoolType(i, nx_int(cool_type))
    end
  end
end
function close_form(type)
  local form = nx_value(nx_current())
  if nx_is_valid(form) and form.type == type then
    form:Close()
  end
end
function show_extra_skill(type, ...)
  local form = util_get_form(nx_current(), true)
  if not nx_is_valid(form) then
    return
  end
  reset_form_size(form, type)
  form.type = type
  add_skill_to_array(form, unpack(arg))
  update_grid(form.imagegrid_skill)
end
function add_skill_to_array(form, ...)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(array_name) then
    common_array:AddArray(array_name, form, 3600, false)
  end
  common_array:ClearChild(array_name)
  local count = nx_int(table.getn(arg) / 2)
  for i = 1, nx_number(count) do
    local skill_id = nx_string(arg[i * 2 - 1])
    local skill_flag = nx_number(arg[i * 2])
    local str_id = "skill_id_" .. nx_string(i)
    local str_flag = "skill_flag_" .. nx_string(i)
    local str_cool = "skill_cool_" .. nx_string(i)
    common_array:AddChild(array_name, str_id, skill_id)
    common_array:AddChild(array_name, str_flag, nx_string(skill_flag))
    local cool_time = get_skill_cool_by_ini(skill_id)
    common_array:AddChild(array_name, str_cool, nx_string(cool_time))
  end
end
function get_skill_id_by_index(index)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  index = index + 1
  if not common_array:FindArray(array_name) then
    return ""
  end
  local str_id = "skill_id_" .. nx_string(index)
  local skill_id = common_array:FindChild(array_name, str_id)
  if skill_id == nil then
    return ""
  end
  return skill_id
end
function get_skill_flag_by_index(index)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  index = index + 1
  if not common_array:FindArray(array_name) then
    return 0
  end
  local str_flag = "skill_flag_" .. nx_string(index)
  local skill_flag = common_array:FindChild(array_name, str_flag)
  if skill_flag == nil then
    return 0
  end
  return nx_number(skill_flag)
end
function get_skill_cool_by_index(index)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return 0
  end
  index = index + 1
  if not common_array:FindArray(array_name) then
    return 0
  end
  local str_cool = "skill_cool_" .. nx_string(index)
  local skill_cool = common_array:FindChild(array_name, str_cool)
  if skill_cool == nil then
    return 0
  end
  return nx_number(skill_cool)
end
function get_skill_cool_by_ini(skill_id)
  local static_data = nx_number(get_ini_value(skill_new_ini, skill_id, "StaticData", "0"))
  local skill_type = -1
  local skill_query = nx_value("SkillQuery")
  if nx_is_valid(skill_query) then
    skill_type = skill_query:GetSkillType(skill_id)
  end
  local varprop_paht = lock_varprop_ini
  if nx_number(skill_type) == 1 then
    varprop_paht = normal_varprop_ini
  end
  local var_pkg = nx_number(skill_static_query(static_data, "MinVarPropNo"))
  local cool_time = get_ini_value(varprop_paht, nx_string(var_pkg), "CoolDownTime", "0")
  return nx_number(cool_time)
end
function on_server_msg(sub_msg, type, ...)
  if nx_number(sub_msg) == SERVER_SUB_MSG_OPEN then
    show_extra_skill(type, unpack(arg))
    util_show_form(nx_current(), true)
  elseif nx_number(sub_msg) == SERVER_SUB_MSG_CLOSE then
    close_form(type)
  elseif nx_number(sub_msg) == SERVER_SUB_MSG_CONTINUE then
    show_extra_skill(type, unpack(arg))
  end
end
function open_extra_skill()
  local form = util_get_form(nx_current(), false)
  if nx_is_valid(form) then
    util_show_form(nx_current(), true)
  end
end
function get_bind_card()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return 0
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_POINT_TO_BINDCARD) then
    return 0
  end
  local capital1 = client_player:QueryProp("CapitalType4")
  return nx_number(capital1)
end
function reset_form_size(form, type)
  local base_col = form.imagegrid_skill.ClomnNum
  local base_width = nx_int(form.imagegrid_skill.Width / base_col)
  local max_num = nx_number(get_ini_value(extra_skill_ini, nx_string(type), "MaxNum", 3))
  if base_col == max_num then
    return
  end
  if max_num < 3 then
    max_num = 3
  end
  form.imagegrid_skill.ClomnNum = max_num
  local offset = (base_col - max_num) * base_width
  form.Width = form.Width - offset
  form.imagegrid_skill.Width = form.imagegrid_skill.Width - offset
  form.lbl_1.Width = form.lbl_1.Width - offset
  form.lbl_2.Left = form.lbl_2.Left - offset / 2
  form.cbtn_1.Left = form.cbtn_1.Left - offset / 2
  form.lbl_3.Left = form.lbl_3.Left - offset / 2
  form.imagegrid_skill.ViewRect = "0,0," .. nx_string(form.imagegrid_skill.Width) .. ",32"
end
function get_ini_value(ini_path, section, key, defaut)
  local ini = get_ini(ini_path)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(section)
  if index < 0 then
    return
  end
  return ini:ReadString(index, key, defaut)
end
