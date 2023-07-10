require("util_static_data")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
local FORM_NAME = "form_stage_main\\form_sweet_employ\\form_offline_employee"
function main_form_init(form)
  form.Fixed = false
  form.item_array_data = nil
end
function move_sub_form(form)
  if not nx_is_valid(form) then
    return
  end
  local sub_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_sub_employee")
  if not nx_is_valid(sub_form) then
    return
  end
  sub_form.AbsLeft = form.AbsLeft + form.Width
  sub_form.AbsTop = form.AbsTop
end
function on_main_form_open(form)
  change_form_size(form)
  ShowDetailData(form)
  form.rbtn_offline.Visible = false
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("rec_pet_show_base_prop", form, nx_current(), "on_rec_change")
    databinder:AddRolePropertyBind("CurPetTaoLu", "string", form, nx_current(), "refresh_taolu_button")
    databinder:AddRolePropertyBind("CurPetNeiGong", "string", form, nx_current(), "refresh_neigong_button")
  end
  local equips = GetFormatStringFromRecord(7)
  form.equips = equips
  form.btn_jingmaiquery.Visible = false
  form.lbl_7.Visible = false
end
function refresh_taolu_button(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  form.btn_taoluquery.Text = util_text(prop_value)
  form.lbl_taolu.type_name = prop_value
end
function refresh_neigong_button(form, prop_name, prop_type, prop_value)
  if not nx_is_valid(form) then
    return
  end
  form.btn_neigongquery.Text = util_text(prop_value)
end
function on_rec_change(form, recordname, optype, row, col)
  if nx_string(recordname) == nx_string("rec_pet_show_base_prop") then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "UpdataEmployerStatus", form)
      timer:Register(500, 1, nx_current(), "UpdataEmployerStatus", form, -1, -1)
    end
  end
  return
end
function UpdataEmployerStatus(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local status = client_player:QueryRecord("rec_pet_show_base_prop", 0, 3)
  if nx_number(status) == nx_number(0) then
    form.lbl_status.Text = util_text("ui_sweetemploy_08")
    form.btn_chuzhan.Enabled = true
    form.btn_xiuxi.Enabled = false
  else
    form.lbl_status.Text = util_text("ui_sweetemploy_07")
    form.btn_chuzhan.Enabled = false
    form.btn_xiuxi.Enabled = true
  end
end
function ShowDetailData(form)
  local uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex, tacitLevel, tacitValue = get_sweetpet_showinfo()
  if uid == nil or uid == "" then
    return
  end
  form.lbl_photo.BackImage = photo
  form.lbl_name.Text = nx_widestr(name)
  form.lbl_shili.Text = nx_execute("form_stage_main\\form_school_war\\form_escort", "Get_PowerLevel_Name", powerlevel)
  form.lbl_level.Text = nx_widestr(tacitLevel)
  local txt = nx_string(GetPlayerProp("CurPetNeiGong"))
  form.btn_neigongquery.Text = util_text(txt)
  local taolu = nx_string(GetPlayerProp("CurPetTaoLu"))
  form.btn_taoluquery.Text = util_text(taolu)
  form.lbl_taolu.type_name = taolu
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindRecord("rec_pet_show_base_prop") then
    return
  end
  local status = client_player:QueryRecord("rec_pet_show_base_prop", 0, 3)
  if nx_number(status) == nx_number(0) then
    form.lbl_status.Text = util_text("ui_sweetemploy_08")
    form.btn_chuzhan.Enabled = true
    form.btn_xiuxi.Enabled = false
  else
    form.lbl_status.Text = util_text("ui_sweetemploy_07")
    form.btn_chuzhan.Enabled = false
    form.btn_xiuxi.Enabled = true
  end
end
function on_main_form_close(form)
  local sub_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_sub_employee")
  if nx_is_valid(sub_form) then
    sub_form.Visible = false
    sub_form:Close()
  end
  if nx_is_valid(form.item_array_data) then
    nx_destroy(form.item_array_data)
  end
  local sub_form_learn = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn")
  if nx_is_valid(sub_form_learn) then
    sub_form_learn.Visible = false
    sub_form_learn:Close()
    nx_destroy(sub_form_learn)
  end
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelTableBind("rec_pet_show_base_prop", form)
    data_binder:DelRolePropertyBind("CurPetTaoLu", form)
    data_binder:DelRolePropertyBind("CurPetNeiGong", form)
  end
  nx_destroy(form)
end
function open_form()
  if not IsBuildEmployRelation() then
    hide_form_control()
  else
    auto_show_hide_employee_info()
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(148) then
    local form = nx_value(FORM_NAME)
    if nx_is_valid(form) then
      form.Visible = false
      form:Close()
      return
    end
  end
end
function auto_show_hide_employee_info()
  if not IsOpenFormOfflineEmp() then
    return
  end
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
    return
  end
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  show_sweet_model(form.scenebox_role)
  form:Show()
  form.Visible = true
  on_rbtn_online_checked_changed(form.rbtn_online)
end
function on_btn_turn_left_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_role, dist)
  end
end
function on_btn_turn_right_click(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_lost_capture(btn)
  btn.MouseDown = false
  return 1
end
function on_btn_turn_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) then
      return
    end
    nx_execute("util_gui", "ui_RotateModel", form.scenebox_role, dist)
  end
end
function change_form_size(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_neigongquery_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  local neigong = GetFormatStringFromRecord(1, nx_string(GetPlayerProp("CurPetNeiGong")))
  form.neigong = neigong
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "initsweetnpcinfor", form.neigong, "", "")
  local sub_form = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "InitSubForm", 1)
  if not nx_is_valid(sub_form) then
    return
  end
  sub_form.parent_form = form
  move_sub_form(form)
  sub_form.Visible = true
  sub_form:Show()
end
function on_btn_jingmaiquery_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sub_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_sub_employee")
  if nx_is_valid(sub_form) then
    sub_form:Close()
    return
  end
  local jingmai = GetFormatStringFromRecord(6)
  form.jingmai = jingmai
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "initsweetnpcinfor", "", "", form.jingmai)
  sub_form = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "InitSubForm", 6)
  if not nx_is_valid(sub_form) then
    return
  end
  sub_form.parent_form = form
  move_sub_form(form)
  sub_form.Visible = true
  sub_form:Show()
end
function on_btn_taoluquery_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  local zhaoshi = GetFormatStringFromRecord(2)
  form.zhaoshi = zhaoshi
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "initsweetnpcinfor", "", form.zhaoshi, "")
  local type_name = ""
  type_name = nx_string(GetPlayerProp("CurPetTaoLu"))
  local sub_form = nx_execute("form_stage_main\\form_sweet_employ\\form_offline_sub_employee", "InitSubForm", 2, nx_string(type_name))
  if not nx_is_valid(sub_form) then
    return
  end
  sub_form.parent_form = form
  move_sub_form(form)
  sub_form.Visible = true
  sub_form:Show()
end
function on_btn_chuzhan_click(btn)
  nx_execute("custom_sender", "custom_offline_employ", nx_number(6))
end
function ShowItemData(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "sel_index") then
    return
  end
  local uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex = get_sweetpet_showinfo()
  if uid == nil or uid == "" then
    return
  end
  form.sex = sex
  local type = form.sel_index
  local tmp_str = ""
  if nx_find_custom(form, "equips") then
    tmp_str = form.equips
  end
  local str_lst = util_split_string(nx_string(tmp_str), ";")
  for _, val in ipairs(str_lst) do
    local str_temp = util_split_string(val, ",")
    if table.getn(str_temp) == nx_number(2) then
      local id = str_temp[1]
      local position = str_temp[2]
      if nx_string(id) ~= nx_string("") then
        local photo = item_query_ArtPack_by_id(nx_string(id), "Photo", nx_number(sex))
        local imagegrid = form.groupbox_online_equip:Find("imagegrid_" .. nx_string(position))
        local treasure = form.groupbox_online_treasure:Find("imagegrid_" .. nx_string(position))
        if nx_is_valid(imagegrid) then
          imagegrid:AddItem(0, nx_string(photo), 0, 1, -1)
          imagegrid.type_name = id
        elseif nx_is_valid(treasure) then
          treasure:AddItem(0, nx_string(photo), 0, 1, -1)
          treasure.type_name = id
        end
      end
    end
  end
end
function ShowEquips(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "sel_index") then
    return
  end
  local type = form.sel_index
  if nx_number(type) == nx_number(1) then
    InitOnlineEquip(form)
  elseif nx_number(type) == nx_number(2) then
    InitOnlineTreature(form)
  elseif nx_number(type) == nx_number(3) then
    InitofflineEquip(form)
  end
  ShowItemData(form)
end
function InitOnlineEquip(form)
  form.groupbox_switch.Visible = true
  form.groupbox_online_equip.Visible = true
  form.groupbox_online_treasure.Visible = false
  form.groupbox_offline.Visible = false
end
function InitOnlineTreature(form)
  form.groupbox_switch.Visible = true
  form.groupbox_online_equip.Visible = false
  form.groupbox_online_treasure.Visible = true
  form.groupbox_offline.Visible = false
end
function InitofflineEquip(form)
  form.groupbox_switch.Visible = false
  form.groupbox_online_equip.Visible = false
  form.groupbox_online_treasure.Visible = false
  form.groupbox_offline.Visible = true
end
function on_rbtn_online_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if form.rbtn_equip.Checked then
      form.sel_index = 1
    else
      form.sel_index = 2
    end
    ShowEquips(form)
  end
end
function on_rbtn_offline_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.sel_index = 3
    ShowEquips(form)
  end
end
function on_rbtn_equip_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.sel_index = 1
    ShowEquips(form)
  end
end
function on_rbtn_treasure_checked_changed(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    form.sel_index = 2
    ShowEquips(form)
  end
end
function get_tips_infor(item_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "", ""
  end
  local record_name = "sweet_pet_eq"
  if not client_player:FindRecord(record_name) then
    return "", ""
  end
  local row = client_player:FindRecordRow(record_name, 0, nx_string(item_id))
  if nx_number(row) < nx_number(0) then
    return "", ""
  end
  local condition = 0
  local tips = client_player:QueryRecord(record_name, row, 2)
  return condition, tips
end
function on_imagegrid_mousein_grid(grid, index)
  if not nx_find_custom(grid, "type_name") then
    return
  end
  local item_id = grid.type_name
  local condition, tips = get_tips_infor(item_id)
  local x = grid:GetMouseInItemLeft()
  local y = grid:GetMouseInItemTop()
  show_hyper_link_iteminfo(tips, x, y, condition)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_hyper_link_iteminfo(item_info, x, y, condition)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "sex") then
    return
  end
  local sex = form.sex
  form.item_array_data = nx_call("util_gui", "get_arraylist", "form_offline_employee:ArrayList", true)
  nx_set_custom(form.item_array_data, "ActivatePack", nx_int(condition))
  get_arraylist_by_parse_xmldata(item_info, form.item_array_data)
  nx_execute("tips_game", "ShowOfflineEmployEquipTips", form.item_array_data, x, y, form, true, sex)
end
function on_imagegrid_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local child_list = form.groupbox_online_equip:GetChildControlList()
  local child_count = table.getn(child_list)
  for i = 1, child_count do
    child_list[i].DrawMouseSelect = ""
  end
  grid.DrawMouseSelect = "xuanzekuang"
  local select_equip = ""
  if nx_find_custom(grid, "type_name") then
    select_equip = grid.type_name
  end
  form.select_equip = select_equip
end
function on_imagegrid_treasure_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local child_list = form.groupbox_online_treasure:GetChildControlList()
  local child_count = table.getn(child_list)
  for i = 1, child_count do
    child_list[i].DrawMouseSelect = ""
  end
  grid.DrawMouseSelect = "xuanzekuang"
  local select_equip = ""
  if nx_find_custom(grid, "type_name") then
    select_equip = grid.type_name
  end
  form.select_equip = select_equip
end
function on_btn_xiuxi_click(btn)
  nx_execute("custom_sender", "custom_offline_employ", nx_number(5))
end
function on_btn_learn_new_click(btn)
  local xiulian_form = nx_value("form_stage_main\\form_sweet_employ\\form_offline_wuxue_xiulian")
  if nx_is_valid(xiulian_form) then
    xiulian_form.Visible = false
    xiulian_form:Close()
    nx_destroy(xiulian_form)
  end
  nx_execute("form_stage_main\\form_sweet_employ\\form_offline_wuxue_learn", "open_form")
end
function hide_form_control()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_5.Visible = false
  form.groupbox_1.Visible = false
  form.scenebox_role.Visible = false
  form.lbl_employee_name.Visible = false
  form.lbl_line_2.Visible = false
  form.groupbox_equipment.Visible = false
  form.groupbox_action.Visible = false
  form.lbl_line_3.Visible = false
  form.groupbox_radiobutton.Visible = false
  form.groupbox_online_equip.Visible = false
  form.groupbox_offline.Visible = false
  form.groupbox_online_treasure.Visible = false
  form.groupbox_switch.Visible = false
  form.btn_turn_left.Visible = false
  form.btn_turn_right.Visible = false
  form.lbl_9.Visible = false
  form.lbl_10.Visible = false
  form.groupbox_lixianqingyuan.Visible = true
  form:Show()
  form.Visible = true
end
function on_btn_qingyuan_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_sweet_employ\\form_qingyuan")
end
function on_btn_release_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local uid, name, photo, hair, cloth, pants, shoes, school, powerlevel, sex, tacitLevel, tacitValue, targetfaccost = get_sweetpet_showinfo()
  if tacitLevel == nil or targetfaccost == nil then
    return
  end
  local money = 19000 + nx_number(tacitLevel) * 1500 + nx_number(targetfaccost) * nx_number(0.03)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_format_string("ui_sweetemploy_25", nx_int(money)))
  dialog:ShowModal()
  local gui = nx_value("gui")
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "cancel" then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_number(2), nx_string(uid))
  form.Visible = false
  form:Close()
end
