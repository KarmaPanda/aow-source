require("util_gui")
require("util_static_data")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
local Form_Name = "form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian"
local Parent_Form = "form_stage_main\\form_sweet_employ\\form_offline_sub_employee"
local WUXUE_NEIGONG = 1
local WUXUE_ZHAOSHI = 2
local WUXUE_JINGMAI = 6
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("sweet_pet_ng", form, nx_current(), "on_rec_change")
    databinder:AddTableBind("sweet_pet_jm", form, nx_current(), "on_rec_change")
    databinder:AddTableBind("sweet_pet_zs", form, nx_current(), "on_rec_change")
  end
  show_data(form)
  change_form_size(form)
end
function on_main_form_close(form)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", false)
end
function show_data(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "wuxue_name") then
    return
  end
  local wuxue_name = form.wuxue_name
  if nx_string(wuxue_name) == nx_string("") then
    return
  end
  local faculty_query = nx_value("faculty_query")
  local wuxue_type = faculty_query:GetType(wuxue_name)
  local photo = ""
  local level = 0
  local fillvalue_cur = 0
  local fillvalue_all = 0
  if nx_int(wuxue_type) == nx_int(WUXUE_ZHAOSHI) then
    photo = skill_static_query_by_id(wuxue_name, "Photo")
    level = GetDataFromRecord("sweet_pet_zs", 1, wuxue_name)
    fillvalue_cur = GetDataFromRecord("sweet_pet_zs", 3, wuxue_name)
  elseif nx_int(wuxue_type) == nx_int(WUXUE_NEIGONG) then
    photo = neigong_query_photo_by_configid(nx_string(wuxue_name))
    level = GetDataFromRecord("sweet_pet_ng", 1, wuxue_name)
    fillvalue_cur = GetDataFromRecord("sweet_pet_ng", 3, wuxue_name)
  elseif nx_int(wuxue_type) == nx_int(WUXUE_JINGMAI) then
    local static_id = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\JingMai\\jingmai.ini", wuxue_name, "StaticData", "0")
    photo = jingmai_static_query(static_id, "Photo")
    level = GetDataFromRecord("sweet_pet_jm", 1, wuxue_name)
    fillvalue_cur = GetDataFromRecord("sweet_pet_jm", 3, wuxue_name)
  end
  fillvalue_all = GetMaxFacutlyValue(nx_string(wuxue_name), nx_number(level))
  form.imagegrid_photo:AddItem(0, nx_string(photo), 0, 1, -1)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_wuxue.Text = gui.TextManager:GetText(nx_string(wuxue_name))
  if not IsJingmai(wuxue_name) then
    form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_" .. nx_string(nx_int(level)))
  else
    local canlevel = GetDataFromRecord("sweet_pet_jm", 2, wuxue_name)
    form.lbl_level.Text = nx_widestr(level)
    form.lbl_level.Text = form.lbl_level.Text .. nx_widestr("/")
    form.lbl_level.Text = form.lbl_level.Text .. nx_widestr(nx_string(canlevel))
    form.lbl_level.Text = form.lbl_level.Text .. nx_widestr(nx_string(util_text("ui_cycle_day")))
  end
  form.pbar_time.Maximum = nx_int(fillvalue_all)
  form.pbar_time.Value = nx_int(fillvalue_cur)
  if IsJingmai(wuxue_name) then
    show_jingmai_item_photo(form, wuxue_name, level)
  else
    show_act_photo(form, wuxue_name, level)
  end
end
function show_act_photo(form, wuxue_name, level)
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local max_exps = faculty_query:GetBaseValue(wuxue_name, level, 2)
  local photo_list = get_act_photo_list(max_exps)
  local photo_table = util_split_string(nx_string(photo_list), ",")
  local count = table.getn(photo_table)
  if nx_int(count) ~= nx_int(3) then
    return
  end
  local base_value = faculty_query:GetBaseValue(wuxue_name, level, 0)
  local photo = "gui\\special\\xiulian\\exp_item_" .. nx_string(photo_table[1]) .. ".png"
  form.imagegrid_yao_1:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_1:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_1:SetItemMark(0, nx_int(photo_table[1]))
  form.lbl_money_1.Text = nx_widestr(nx_string(base_value))
  form.imagegrid_yao_1.wuxue_name = wuxue_name
  form.imagegrid_yao_1.level = level
  base_value = faculty_query:GetBaseValue(wuxue_name, level, 1)
  photo = "gui\\special\\xiulian\\exp_item_" .. nx_string(photo_table[2]) .. ".png"
  form.imagegrid_yao_2:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_2:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_2:SetItemMark(0, nx_int(photo_table[2]))
  form.lbl_money_2.Text = nx_widestr(nx_string(base_value))
  form.imagegrid_yao_2.wuxue_name = wuxue_name
  form.imagegrid_yao_2.level = level
  base_value = faculty_query:GetBaseValue(wuxue_name, level, 2)
  photo = "gui\\special\\xiulian\\exp_item_" .. nx_string(photo_table[3]) .. ".png"
  form.imagegrid_yao_3:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_3:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_3:SetItemMark(0, nx_int(photo_table[3]))
  form.lbl_money_3.Text = nx_widestr(nx_string(base_value))
  form.imagegrid_yao_3.wuxue_name = wuxue_name
  form.imagegrid_yao_3.level = level
end
function show_jingmai_item_photo(form, wuxue_name, level)
  local photo = "gui\\special\\xiulian\\exp_item_1.png"
  form.imagegrid_yao_1:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_1:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_1:SetItemMark(0, nx_int(1))
  local money = 1000
  form.imagegrid_yao_1.money = nx_string(nx_int(money))
  form.lbl_money_1.Text = nx_widestr(nx_string(money))
  form.imagegrid_yao_1.wuxue_name = wuxue_name
  form.imagegrid_yao_1.level = level
  photo = "gui\\special\\xiulian\\exp_item_2.png"
  form.imagegrid_yao_2:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_2:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_2:SetItemMark(0, nx_int(2))
  local money = 5000
  form.imagegrid_yao_2.money = nx_string(nx_int(money))
  form.lbl_money_2.Text = nx_widestr(nx_string(money))
  form.imagegrid_yao_2.wuxue_name = wuxue_name
  form.imagegrid_yao_2.level = level
  photo = "gui\\special\\xiulian\\exp_item_3.png"
  form.imagegrid_yao_3:AddItem(0, photo, 0, 1, -1)
  form.imagegrid_yao_3:SetCoolType(0, nx_int(24025))
  form.imagegrid_yao_3:SetItemMark(0, nx_int(3))
  local money = 10000
  form.imagegrid_yao_3.money = nx_string(nx_int(money))
  form.lbl_money_3.Text = nx_widestr(nx_string(money))
  form.imagegrid_yao_3.wuxue_name = wuxue_name
  form.imagegrid_yao_3.level = level
end
function change_form_size(form)
  local parent_form = nx_value(Parent_Form)
  if not nx_is_valid(parent_form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = parent_form.AbsTop + (parent_form.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function get_act_photo_list(faculty)
  if faculty <= 0 then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Faculty\\ActFacultyPhoto.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("Photo")
  if sec_index < 0 then
    return
  end
  local act_count = ini:GetSectionItemCount(sec_index)
  for i = 0, act_count - 1 do
    local key = ini:GetSectionItemKey(sec_index, i)
    if nx_int(faculty) <= nx_int(key) then
      return ini:GetSectionItemValue(sec_index, i)
    end
  end
  return ini:GetSectionItemValue(sec_index, act_count - 1)
end
function on_imagegrid_yao_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not (nx_is_valid(form) and nx_find_custom(grid, "wuxue_name")) or not nx_find_custom(grid, "level") then
    return
  end
  local wuxue_name = grid.wuxue_name
  local cur_level = grid.level
  local form_tips = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", true)
  if not nx_is_valid(form_tips) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if nx_string(grid.Name) == nx_string("imagegrid_yao_1") then
    index = 0
  elseif nx_string(grid.Name) == nx_string("imagegrid_yao_2") then
    index = 1
  elseif nx_string(grid.Name) == nx_string("imagegrid_yao_3") then
    index = 2
  end
  local cost_text = 0
  if not IsJingmai(wuxue_name) then
    local base_value = faculty_query:GetBaseValue(wuxue_name, cur_level, index)
    local price_ratio = faculty_query:GetPriceRatio(wuxue_name, cur_level)
    cost_text = nx_execute("util_functions", "trans_capital_string", nx_int(price_ratio * base_value * 4))
  elseif nx_find_custom(grid, "money") then
    cost_text = nx_execute("util_functions", "trans_capital_string", nx_int(grid.money))
  else
    cost_text = nx_execute("util_functions", "trans_capital_string", nx_int(70))
  end
  form_tips.lbl_name.Text = nx_widestr(util_text("ui_faculty_act_item_name_" .. nx_string(grid:GetItemMark(0))))
  form_tips.mltbox_script.HtmlText = nx_widestr(util_text("ui_faculty_act_item_script_" .. nx_string(grid:GetItemMark(0))) .. nx_widestr("<br><br>") .. util_text("ui_train_act_tips2"))
  form_tips.lbl_cost.Text = nx_widestr(cost_text)
  form_tips.lbl_picture.BackImage = "gui\\common\\money\\liang.png"
  reset_tips_control_pos(form_tips)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", true)
  if nx_is_valid(form_tips) then
    form_tips.AbsLeft = grid:GetMouseInItemLeft() + 40
    form_tips.AbsTop = grid:GetMouseInItemTop() + 32
  end
end
function on_imagegrid_yao_mouseout_grid(grid, index)
  util_show_form("form_stage_main\\form_wuxue\\form_wuxue_act_tips", false)
end
function on_imagegrid_yao_select_changed(grid, index)
  local form = grid.ParentForm
  if not (nx_is_valid(form) and nx_find_custom(grid, "wuxue_name")) or not nx_find_custom(grid, "level") then
    return
  end
  form.imagegrid_yao_1.DrawMouseSelect = ""
  form.imagegrid_yao_2.DrawMouseSelect = ""
  form.imagegrid_yao_3.DrawMouseSelect = ""
  grid.DrawMouseSelect = "xuanzekuang"
  local wuxue_name = grid.wuxue_name
  local level = grid.level
  local gui = nx_value("gui")
  if gui.CoolManager:IsCooling(nx_int(24025), nx_int(-1)) then
    return
  end
  if nx_string(grid.Name) == nx_string("imagegrid_yao_1") then
    index = 0
  elseif nx_string(grid.Name) == nx_string("imagegrid_yao_2") then
    index = 1
  elseif nx_string(grid.Name) == nx_string("imagegrid_yao_3") then
    index = 2
  end
  if not IsJingmai(wuxue_name) then
    nx_execute("custom_sender", "custom_offline_employ", nx_number(8), nx_number(index), nx_string(wuxue_name), nx_number(level))
  else
    local money = 0
    if nx_find_custom(grid, "money") then
      money = grid.money
    end
    nx_execute("custom_sender", "custom_offline_employ", nx_number(8), nx_number(index), nx_string(wuxue_name), nx_number(level), nx_int(money))
  end
end
function reset_tips_control_pos(form)
  if not nx_is_valid(form) then
    return
  end
  local cur_height = form.mltbox_script:GetContentHeight()
  form.mltbox_script.Height = cur_height + 20
  form.mltbox_script.ViewRect = "0,0,174," .. nx_string(cur_height + 20)
  form.Height = cur_height + 62
end
function on_rec_change(form, recordname, optype, row, col)
  if optype ~= "update" then
    return
  end
  if nx_int(col) == nx_int(3) or nx_int(col) == nx_int(1) then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_refresh_panel", form)
      timer:Register(500, 1, nx_current(), "on_refresh_panel", form, -1, -1)
    end
  end
  return
end
function on_refresh_panel(form, param1, param2)
  if not (nx_is_valid(form) and nx_find_custom(form, "wuxue_name")) or not nx_find_custom(form, "type") then
    return
  end
  local wuxue_name = form.wuxue_name
  if nx_string(wuxue_name) == nx_string("") then
    return
  end
  local type = form.type
  local record_name = ""
  if nx_number(type) == nx_number(1) then
    record_name = "sweet_pet_ng"
  elseif nx_number(type) == nx_number(2) then
    record_name = "sweet_pet_zs"
  elseif nx_number(type) == nx_number(6) then
    record_name = "sweet_pet_jm"
  end
  local canlevel = GetDataFromRecord(record_name, 2, wuxue_name)
  local level = GetDataFromRecord(record_name, 1, wuxue_name)
  if nx_number(canlevel) == nx_number(level) then
    form:Close()
    nx_destroy(form)
    return
  end
  show_data(form)
end
function IsJingmai(wuxue_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local record_name = "sweet_pet_jm"
  if not client_player:FindRecord(record_name) then
    return false
  end
  local row = client_player:FindRecordRow(record_name, 0, nx_string(wuxue_id))
  if nx_number(row) < nx_number(0) then
    return false
  else
    return true
  end
end
