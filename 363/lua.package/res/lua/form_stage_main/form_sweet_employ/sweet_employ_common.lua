require("util_functions")
require("form_stage_main\\form_sweet_employ\\sweet_employ_define")
function is_sweet_pet(role, target)
  local pet_type = get_pet_prop("NpcType")
  if nx_int(pet_type) ~= nx_int(TYPE_PET_SWEET) then
    return false
  end
  local master_name = get_pet_prop("Master")
  local player_name = get_player_prop("Name")
  if not nx_ws_equal(nx_widestr(master_name), nx_widestr(player_name)) then
    return false
  end
  local pet = get_sweet_pet()
  if not nx_is_valid(pet) then
    return false
  end
  if not nx_id_equal(target, pet) then
    return false
  end
  return true
end
function is_have_sweet_pet()
  local pet = get_sweet_pet()
  if not nx_is_valid(pet) then
    return false
  end
  return true
end
function get_player_prop(prop)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  if not player:FindProp(nx_string(prop)) then
    return ""
  end
  return player:QueryProp(nx_string(prop))
end
function get_pet_prop(prop)
  local pet = get_sweet_pet()
  if not nx_is_valid(pet) then
    return ""
  end
  if not pet:FindProp(nx_string(prop)) then
    return ""
  end
  return pet:QueryProp(nx_string(prop))
end
function get_sweet_pet()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return nx_null()
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return nx_null()
  end
  local pet_id = ""
  if player:FindProp("CurSweetPetNpc") then
    pet_id = player:QueryProp("CurSweetPetNpc")
  end
  return client:GetSceneObj(nx_string(pet_id))
end
function get_data_from_rec(rec_name, row, col)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return ""
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  local count = player:GetRecordRows(rec_name)
  if nx_int(row) < nx_int(0) or nx_int(row) > nx_int(count - 1) then
    return ""
  end
  count = player:GetRecordCols(rec_name)
  if nx_int(col) < nx_int(0) or nx_int(col) > nx_int(count - 1) then
    return ""
  end
  return player:QueryRecord(rec_name, row, col)
end
function split_money(money)
  money = nx_int64(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  return ding, liang, wen
end
function format_money_text(money)
  if nx_int(money) <= nx_int(0) then
    return nx_widestr("0") .. nx_widestr(util_text("ui_Wen"))
  end
  local ding, liang, wen = 0, 0, 0
  ding, liang, wen = split_money(money)
  local money_text = nx_widestr("")
  if nx_int(ding) > nx_int(0) then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_Ding"))
  end
  if nx_int(liang) > nx_int(0) then
    money_text = money_text .. nx_widestr(liang) .. nx_widestr(util_text("ui_Liang"))
  end
  if nx_int(wen) > nx_int(0) then
    money_text = money_text .. nx_widestr(wen) .. nx_widestr(util_text("ui_Wen"))
  end
  return money_text
end
