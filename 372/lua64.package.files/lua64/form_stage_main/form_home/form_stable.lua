require("util_functions")
require("util_gui")
require("form_stage_main\\form_home\\form_home_msg")
require("role_composite")
local FORM_STABLE = "form_stage_main\\form_home\\form_stable"
local FORM_STABLE_SELECT = "form_stage_main\\form_home\\form_stable_select"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.building_id = nil
  form.player_uid = nil
end
function on_main_form_close(form)
  nx_execute(FORM_STABLE_SELECT, "close_form")
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local str = ""
  for i = 1, 10 do
    local gb = form.gb_horse:Find("gb_horse_" .. nx_string(i))
    if nx_is_valid(gb) then
      str = str .. nx_string(gb.id) .. "," .. nx_string(gb.player_uid) .. ";"
    end
  end
  client_to_server_msg(CLIENT_SUB_STABLE_SELECT, nx_string(form.building_id), nx_string(str))
end
function on_btn_set_click(btn)
  nx_execute(FORM_STABLE_SELECT, "open_form", btn.index)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  clear_horse(form, btn.index)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_horse(index, card_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE, false, false)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local gb = form.gb_horse:Find("gb_horse_" .. nx_string(index))
  if nx_is_valid(gb) then
    gb.id = card_id
    gb.player_uid = form.player_uid
    gb.putter_name = client_player:QueryProp("Name")
  end
  refresh_horse_single(form, index)
end
function check_card_id_in(card_id)
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE, false, false)
  if not nx_is_valid(form) then
    return false
  end
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  for i = 1, 10 do
    local gb = form.gb_horse:Find("gb_horse_" .. nx_string(i))
    if nx_is_valid(gb) and nx_int(gb.id) == nx_int(card_id) and nx_widestr(gb.putter_name) == client_player:QueryProp("Name") then
      return true
    end
  end
  return false
end
function test()
  local building_id = "stable"
  local horse_list = ",;230,\206\210;124,\203\251;11,\203\251;203,\206\210;374,\203\251;"
  on_server_msg(building_id, horse_list)
end
function test2()
  nx_execute("custom_sender", "custom_use_temp_skill", "itmski_neixiu_lzy_001")
end
function test3()
  nx_execute("custom_sender", "custom_use_temp_skill", "itmski_neixiu_srtx_004")
end
function test4()
  nx_execute("custom_sender", "custom_use_temp_skill", "itmski_neixiu_07")
end
function test5()
  nx_execute("custom_sender", "custom_use_temp_skill", "ski_shuxing_nx_01")
end
function test6()
  nx_execute("custom_sender", "custom_use_temp_skill", "jn_tg05_015")
end
function test7()
  nx_execute("custom_sender", "custom_use_temp_skill", "clone013_f_shanbi")
end
function test8()
  nx_execute("custom_sender", "custom_use_temp_skill", "Clone004_huyanxiao_04")
end
function on_server_msg(...)
  local form = nx_execute("util_gui", "util_get_form", FORM_STABLE, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  local building_id = nx_string(arg[1])
  local player_uid = nx_string(arg[2])
  local horse_list = nx_string(arg[3])
  form.building_id = building_id
  form.player_uid = player_uid
  local var_horse_list = util_split_string(horse_list, ";")
  for i = 1, 10 do
    local gb = form.gb_horse:Find("gb_horse_" .. nx_string(i))
    if nx_is_valid(gb) then
      gb.id = 0
      gb.player_uid = ""
      gb.putter_name = nx_widestr("")
      if i < table.getn(var_horse_list) then
        local var = util_split_string(var_horse_list[i], ",")
        gb.id = nx_int(var[1])
        gb.putter_name = nx_widestr(var[3])
        gb.player_uid = nx_string(var[4])
      end
    end
  end
  refresh_horse(form)
end
function refresh_horse(form)
  for i = 1, 10 do
    if not nx_is_valid(form) then
      return
    end
    local gb = form.gb_horse:Find("gb_horse_" .. nx_string(i))
    if nx_is_valid(gb) then
      local sb_horse = gb:Find("sb_horse_" .. nx_string(i))
      local btn_set = gb:Find("btn_set_" .. nx_string(i))
      local btn_cancel = gb:Find("btn_cancel_" .. nx_string(i))
      local lbl_name = gb:Find("lbl_name_" .. nx_string(i))
      local lbl_putter = gb:Find("lbl_putter_" .. nx_string(i))
      if nx_is_valid(sb_horse) and nx_is_valid(btn_set) and nx_is_valid(btn_cancel) and nx_is_valid(lbl_name) and nx_is_valid(lbl_putter) then
        btn_set.index = nx_int(i)
        btn_cancel.index = nx_int(i)
        lbl_putter.Text = nx_widestr(gb.putter_name)
        show_horse(sb_horse, gb.id, lbl_name)
      end
    end
  end
end
function refresh_horse_single(form, index)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.gb_horse:Find("gb_horse_" .. nx_string(index))
  if nx_is_valid(gb) then
    local sb_horse = gb:Find("sb_horse_" .. nx_string(index))
    local btn_set = gb:Find("btn_set_" .. nx_string(index))
    local lbl_name = gb:Find("lbl_name_" .. nx_string(index))
    local lbl_putter = gb:Find("lbl_putter_" .. nx_string(index))
    if nx_is_valid(sb_horse) and nx_is_valid(btn_set) and nx_is_valid(lbl_name) and nx_is_valid(lbl_putter) then
      lbl_putter.Text = nx_widestr(gb.putter_name)
      show_horse(sb_horse, gb.id, lbl_name)
    end
  end
end
function clear_horse(form, index)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.gb_horse:Find("gb_horse_" .. nx_string(index))
  if nx_is_valid(gb) then
    local sb_horse = gb:Find("sb_horse_" .. nx_string(index))
    local btn_set = gb:Find("btn_set_" .. nx_string(index))
    local lbl_name = gb:Find("lbl_name_" .. nx_string(index))
    local lbl_putter = gb:Find("lbl_putter_" .. nx_string(index))
    if nx_is_valid(sb_horse) and nx_is_valid(btn_set) and nx_is_valid(lbl_name) and nx_is_valid(lbl_putter) then
      gb.id = 0
      lbl_putter.Text = nx_widestr("")
      show_horse(sb_horse, 0, lbl_name)
    end
  end
end
function show_horse(sb_horse, card_id, lbl_name)
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if nx_find_custom(sb_horse, "horse_model") and nx_is_valid(sb_horse.horse_model) and nx_is_valid(sb_horse.Scene) then
    sb_horse.Scene:Delete(sb_horse.horse_model)
    local scene = sb_horse.Scene
    if nx_find_custom(scene, "terrain") and nx_is_valid(scene.terrain) then
      scene:Delete(scene.terrain)
    end
  end
  lbl_name.Text = nx_widestr("")
  nx_execute("util_gui", "ui_ClearModel", sb_horse)
  if nx_int(card_id) == nx_int(0) then
    return
  end
  local card_manager = nx_value("CollectCardManager")
  if not nx_is_valid(card_manager) then
    return
  end
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local sex = client_player:QueryProp("Sex")
  local card_info = {}
  card_info = card_manager:GetCardInfo(card_id)
  local count = table.getn(card_info)
  if nx_int(count) == nx_int(0) then
    return
  end
  local female_model = card_info[10]
  local male_model = card_info[11]
  local model = ""
  if nx_number(sex) == nx_number(SEX_FEMALE) then
    model = female_model
  else
    model = male_model
  end
  local mount_info = util_split_string(model, ":")
  local model_path = mount_info[2]
  if nx_running("role_composite", "load_from_ini") then
    nx_kill("role_composite", "load_from_ini")
  end
  if not nx_is_valid(sb_horse.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", sb_horse)
  end
  local actor2 = create_actor2(sb_horse.Scene)
  if not nx_is_valid(actor2) then
    return
  end
  sb_horse.horse_model = actor2
  actor2.AsyncLoad = true
  actor2.mount = model_path
  local result = role_composite:CreateSceneObjectFromIni(actor2, "ini\\" .. nx_string(actor2.mount) .. ".ini")
  if not result then
    sb_horse.Scene:Delete(actor2)
  end
  if not nx_is_valid(actor2) then
    return
  end
  while nx_is_valid(form) and nx_is_valid(actor2) and not role_composite:GetNpcLoadFinish(actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(actor2) or not nx_is_valid(sb_horse) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", sb_horse, actor2)
  local radius = 2.1
  local scene = sb_horse.Scene
  if nx_is_valid(scene) then
    scene.camera:SetPosition(0, radius * 0.6, -radius * 3)
  end
  local dist = 1.2
  nx_execute("util_gui", "ui_RotateModel", sb_horse, dist)
  local fix_id = nx_int(10000) + nx_int(card_id)
  local config_id = "card_item_" .. nx_string(fix_id)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_name = ItemQuery:GetItemPropByConfigID(nx_string(config_id), nx_string("Name"))
  if nx_is_valid(lbl_name) then
    lbl_name.Text = nx_widestr(item_name)
  end
end
