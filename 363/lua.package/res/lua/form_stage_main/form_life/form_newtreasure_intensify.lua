require("util_gui")
require("util_functions")
require("form_stage_main\\form_life\\form_newtreasure_grave")
local FATHER_NAME = "form_stage_main\\form_life\\form_newtreasure_grave"
local FORM_NAME = "form_stage_main\\form_life\\form_newtreasure_intensify"
local ini_table = {
  "AddPropLevel_1",
  "AddPropLevel_2",
  "AddPropLevel_3",
  "AddPropLevel_4"
}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.ToFront = true
  form.Left = (gui.Desktop.Width - form.Width) / 2 + 50
  form.Top = (gui.Desktop.Height - form.Height) / 2 + 70
  show_intensify_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  local father_form = nx_value(FATHER_NAME)
  if nx_is_valid(father_form) then
    father_form.imagegrid_target.Enabled = true
    father_form.mltbox_target.SelectBarColor = "255,0,0,0"
    father_form.mltbox_target.SelectBarDraw = "gui\\special\\baowu_check01.png"
    father_form.lbl_select.Visible = false
  end
  nx_destroy(form)
end
function open_form()
  local form_main = nx_value(FORM_NAME)
  if not nx_is_valid(form_main) then
    form_main = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  end
  form_main:ShowModal()
end
function close_form()
  local form_main = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local father_form = nx_value(FATHER_NAME)
  if nx_is_valid(father_form) then
    father_form.imagegrid_target.Enabled = true
    father_form.mltbox_target.SelectBarColor = "255,0,0,0"
    father_form.mltbox_target.SelectBarDraw = "gui\\special\\baowu_check01.png"
    father_form.lbl_select.Visible = false
  end
  form:Close()
end
function on_btn_intensify_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local father_form = nx_value(FATHER_NAME)
  local item = nx_execute("goods_grid", "get_view_item", father_form.sel_view, father_form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  if not item:QueryProp("EquipType") == nx_string("NewTreasure") then
    return
  end
  if not item:FindRecord("RandomPropRec") then
    return
  end
  if not check_player_status() then
    return
  end
  local select = father_form.select_target
  nx_execute("custom_sender", "custom_newtersure_intensify", father_form.sel_view, father_form.sel_index, select)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_intensify_info(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local father_form = nx_value(FATHER_NAME)
  local item = nx_execute("goods_grid", "get_view_item", father_form.sel_view, father_form.sel_index)
  if not nx_is_valid(item) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local exp_info = player:QueryProp("NewTersureValue")
  form.lbl_value_info.Text = nx_widestr(exp_info)
  local curlevel = item:QueryProp("Level")
  local select = father_form.select_target
  local revise_id = item:QueryRecord("RandomPropRec", select, 0)
  local revise_value = item:QueryRecord("RandomPropRec", select, 1)
  local revise_level = item:QueryRecord("RandomPropRec", select, 4)
  local revise_power = item:QueryRecord("RandomPropRec", select, 5)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\NewTersure\\AddPropExp.ini")
  if not nx_is_valid(ini) then
    return
  end
  local value = 0
  if ini:FindSection("Limit") then
    local section_index = ini:FindSectionIndex("Limit")
    if section_index < 0 then
      return
    end
    local item_count = ini:GetSectionItemCount(section_index)
    for i = 0, item_count - 1 do
      local count = ini:GetSectionItemKey(section_index, i)
      if nx_int(count) == nx_int(curlevel) then
        value = ini:GetSectionItemValue(section_index, i)
      end
    end
  end
  form.lbl_maxlevel_info.Text = gui.TextManager:GetFormatText("ui_menu_newtreasure_intensify_2_1", nx_widestr(value))
  form.lbl_level_info.Text = gui.TextManager:GetFormatText("ui_menu_newtreasure_intensify_3_1", nx_widestr(revise_power), nx_widestr(revise_power + 1))
  local res = nx_string(ini_table[revise_level])
  local child_ini = nx_execute("util_functions", "get_ini", "share\\Rule\\RandomEquipRule\\NewTersure\\" .. res .. ".ini")
  if not nx_is_valid(child_ini) then
    return
  end
  local section = nx_string(revise_id)
  local power_value_1 = 0
  local power_value = 0
  if child_ini:FindSection(section) then
    local section_id = child_ini:FindSectionIndex(section)
    if section_id < 0 then
      return
    end
    local all_count = child_ini:GetSectionItemCount(section_id)
    for i = 0, all_count - 1 do
      local count_id = child_ini:GetSectionItemKey(section_id, i)
      if nx_int(count_id) == nx_int(revise_power) then
        local power_info = child_ini:GetSectionItemValue(section_id, i)
        local tmp_lst = util_split_string(power_info, ",")
        power_value = tmp_lst[2]
        local power_info_1 = child_ini:GetSectionItemValue(section_id, i + 1)
        local tmp_lst_1 = util_split_string(power_info_1, ",")
        power_value_1 = tmp_lst_1[1]
      end
    end
  end
  form.lbl_pro_info.Text = gui.TextManager:GetFormatText("ui_menu_newtreasure_intensify_4_1", nx_widestr(revise_value), nx_widestr(power_value_1))
  form.lbl_cost_info.Text = nx_widestr(power_value)
end
function get_player()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  return game_client:GetPlayer()
end
