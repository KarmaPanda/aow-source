require("util_gui")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\form_offline_employee_utils")
local FORM_SWEET_SNS = "form_stage_main\\form_sweet_employ\\form_sweet_sns"
local FORM_OFFLINE_EMPLOYEE = "form_stage_main\\form_sweet_employ\\form_offline_employee"
local FORM_OFFLINE_QINGYUAN = "form_stage_main\\form_sweet_employ\\form_qingyuan"
local FORM_GROW_PLAYER = "form_stage_main\\form_sweet_employ\\form_grow_player"
local FORM_GROW_PET = "form_stage_main\\form_sweet_employ\\form_grow_pet"
local FORM_BUY_CHARM = "form_stage_main\\form_sweet_employ\\form_buy_charm"
local FORM_SWEET_SHOP = "form_stage_main\\form_sweet_employ\\form_sweet_pet_shop"
local SHOP_ITEM_INI = "share\\SweetEmploy\\shop\\shopitem.ini"
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = true
  form.self_actor2 = nil
  form.sweet_actor2 = nil
  form.shopiteminfo = nx_null()
  return 1
end
function on_main_form_open(form)
  change_form_size()
  load_ini(form)
  show_model(form)
  if IsBuildEmployRelation() and IsOpenFormOfflineEmp() then
    change_pet_clothes(form.scenebox_famale)
  end
  if IsBuildEmployRelation() and IsOpenFormOfflineEmp() then
    util_auto_show_hide_form(FORM_GROW_PLAYER)
    util_auto_show_hide_form(FORM_GROW_PET)
  end
  return 1
end
function load_ini(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini(SHOP_ITEM_INI, true)
  if not nx_is_valid(ini) then
    return
  end
  form.shopiteminfo = ini
end
function change_pet_clothes(scenebox)
  if not nx_is_valid(scenebox) then
    return
  end
  if not nx_find_custom(scenebox, "role_actor2") then
    return
  end
  local actor2 = scenebox.role_actor2
  if not nx_is_valid(actor2) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindProp("SweetEmployClothes") then
    return
  end
  local clothes = player:QueryProp("SweetEmployClothes")
  if clothes == "" then
    return
  end
  local form = scenebox.ParentForm
  if not nx_is_valid(form.shopiteminfo) then
    return
  end
  local sec_index = form.shopiteminfo:FindSectionIndex(clothes)
  if sec_index < 0 then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local _, sex, body_type = get_pet_cloth_and_sex()
  if sex == nil then
    return
  end
  local work_cloth = form.shopiteminfo:ReadString(sec_index, "workcloth", "")
  actor2.body_type_fake = body_type
  role_composite:link_pet_fashion_cloth(actor2, sex, work_cloth)
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function get_pet_cloth_and_sex()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return nil, nil
  end
  local table_name = "rec_pet_show"
  if not client_player:FindRecord(table_name) then
    return nil, nil
  end
  local rows = client_player:GetRecordRows(table_name)
  if rows ~= 1 then
    return nil, nil
  end
  local row = 0
  local cloth = nx_string(client_player:QueryRecord(table_name, row, 4))
  local sex = nx_int(client_player:QueryRecord(table_name, row, 9))
  local body_type = nx_int(client_player:QueryRecord(table_name, row, 14))
  return cloth, sex, body_type
end
function on_main_form_close(form)
  local ini_mgr = nx_value("IniManager")
  if nx_is_valid(ini_mgr) then
    ini_mgr:UnloadIniFromManager(SHOP_ITEM_INI)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
  local form_employ = nx_value(FORM_OFFLINE_EMPLOYEE)
  if nx_is_valid(form_employ) then
    form_employ:Close()
  end
  local form_qingyuan = nx_value(FORM_OFFLINE_QINGYUAN)
  if nx_is_valid(form_qingyuan) then
    form_qingyuan:Close()
  end
  local form_grow_player = nx_value(FORM_GROW_PLAYER)
  if nx_is_valid(form_grow_player) then
    form_grow_player:Close()
  end
  local form_grow_pet = nx_value(FORM_GROW_PET)
  if nx_is_valid(form_grow_pet) then
    form_grow_pet:Close()
  end
  local form_buy_charm = nx_value(FORM_BUY_CHARM)
  if nx_is_valid(form_buy_charm) then
    form_buy_charm:Close()
  end
end
function change_form_size()
  local form = nx_value(FORM_SWEET_SNS)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Desktop.Width
  form.Height = gui.Desktop.Height
  form.groupbox_btn.Top = form.Height - form.groupbox_btn.Height
  form.groupbox_btn.Width = form.Width
  form.groupbox_sweet.Width = form.Width
  form.groupbox_sweet.Height = form.Height - form.groupbox_btn.Height
  form.lbl_back.Width = form.Width
  form.lbl_back.Height = form.Height + 38
end
function show_model(form)
  local self_scenebox = form.scenebox_male
  local sweet_scenebox = form.scenebox_famale
  show_self_model(self_scenebox)
  if IsBuildEmployRelation() and IsOpenFormOfflineEmp() then
    show_sweet_model(sweet_scenebox)
    if not nx_find_custom(self_scenebox, "role_actor2") or not nx_find_custom(sweet_scenebox, "role_actor2") then
      return
    end
    if not nx_is_valid(self_scenebox.role_actor2) or not nx_is_valid(sweet_scenebox.role_actor2) then
      return
    end
    if is_self_body() or is_npc_body() then
      form.scenebox_male.Left = -322
      form.scenebox_famale.Left = -194
      if is_self_body() then
        doPossAction(self_scenebox.role_actor2, "new_stand_free01")
      else
        doPossAction(self_scenebox.role_actor2, "stand")
      end
      if is_npc_body() then
        doPossAction(sweet_scenebox.role_actor2, "new_stand_free04")
      else
        doPossAction(sweet_scenebox.role_actor2, "stand")
      end
    else
      form.scenebox_male.Left = -260
      form.scenebox_famale.Left = form.scenebox_male.Left + 76
      doPossAction(self_scenebox.role_actor2, "interact_we_04")
      doPossAction(sweet_scenebox.role_actor2, "interact_we_05")
    end
  else
    show_black_model(sweet_scenebox)
  end
end
function on_btn_sweet_click(btn)
  if not IsBuildEmployRelation() or not IsOpenFormOfflineEmp() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_sweetemploy_19"), 2)
    end
  else
    util_auto_show_hide_form(FORM_GROW_PLAYER)
    util_auto_show_hide_form(FORM_GROW_PET)
  end
end
function on_btn_fight_click(btn)
  if not IsBuildEmployRelation() then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("ui_sweetemploy_19"), 2)
    end
  else
    nx_execute(FORM_OFFLINE_EMPLOYEE, "auto_show_hide_employee_info")
  end
end
function on_btn_xieshou_click(btn)
end
function on_btn_hongdou_click(btn)
  nx_execute(FORM_SWEET_SHOP, "show_form")
end
function on_btn_jianghu_click(btn)
  util_auto_show_hide_form(FORM_OFFLINE_QINGYUAN)
end
function on_lbl_male_click(lbl)
end
function on_lbl_famale_click(lbl)
end
function on_btn_baixiao_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jbjh")
end
