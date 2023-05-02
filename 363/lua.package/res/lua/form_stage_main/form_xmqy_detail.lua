require("util_static_data")
require("util_functions")
require("share\\view_define")
require("custom_sender")
require("form_stage_main\\form_tvt\\define")
eShowAwardForm = 1
eEndPlateAward = 2
eSucceedOpenPlate = 3
eSucceedGetTreasure = 4
eSucceedGetAllNormalAward = 5
eSucceedGetOneNormalAward = 6
eSCPayOpenPlate = 7
eSCPayPickUpTreasure = 8
eRestartAwardForm = 9
SELECT_ALL_NORMAL_AWARD = 1
OPEN_ONE_PLATE = 3
GET_AWARD_FROM_PLATE = 4
CLOSE_FORM = 5
TRY_OPEN_ONE_PLATE = 6
TRY_GET_AWARD_PLATE = 7
TRY_CLOSE = 8
BUTTONS_REMOVE = {
  btn_remove_1 = 1,
  btn_remove_2 = 2,
  btn_remove_3 = 3,
  btn_remove_4 = 4
}
BUTTONS_GAIN = {
  btn_gain_1 = 1,
  btn_gain_2 = 2,
  btn_gain_3 = 3,
  btn_gain_4 = 4
}
PLATE_LOGIC = "form_plate_award_logic"
MAX_NORMAL_BOX = 7
MODULE_SKIN = {
  TeamFaculty = "form_stage_main\\form_xmqy_detail",
  BattleField = "form_stage_main\\form_battlefield\\form_battlefield_reward",
  MatchDay = "form_stage_main\\form_match\\form_match_Dayreward",
  MatchWeek = "form_stage_main\\form_match\\form_match_Weekreward",
  WeatherWar = "form_stage_main\\form_weather_war\\form_subgroup_award",
  MatchSchool = "form_stage_main\\form_match\\form_match_Dayreward",
  MatchMonth = "form_stage_main\\form_match\\form_match_Weekreward",
  RevengeMatch = "form_stage_main\\form_match\\form_match_Weekreward",
  CommonAward = "form_stage_main\\form_xmqy_detail",
  Guildwar_kuafu = "form_stage_main\\form_guildwar_kuafu",
  SkyHill = "form_stage_main\\form_match\\form_match_below"
}
function change_form_size_change()
  local form = nx_value("form_stage_main\\form_xmqy_detail")
  if nx_is_valid(form) then
    form_layout_center(form)
  end
  form = nx_value("form_stage_main\\form_battlefield\\form_battlefield_reward")
  if nx_is_valid(form) then
    form_layout_center(form)
  end
  form_below = nx_value("form_stage_main\\form_match\\form_match_below")
  if nx_is_valid(form_below) then
    form_blow_layout_center(form_below)
  end
end
function form_blow_layout_center(form_below)
  if nx_string(form.plate_aware_form_value) == nx_string(MODULE_SKIN.SkyHill) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.Left = 0.5 * (gui.Width - form.Width)
      form.Top = 0.5 * gui.Height - 83
    end
  end
end
function form_layout_center(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = 0.5 * (gui.Width - form.Width)
  form.Top = 0.5 * (gui.Height - form.Height)
  if nx_string(form.plate_aware_form_value) == nx_string(MODULE_SKIN.SkyHill) then
    form.Left = 0.5 * (gui.Width - form.Width)
    form.Top = 0.5 * gui.Height - 83
  end
end
function on_main_form_open(form)
  local form_back = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_wuxue\\form_faculty_back", true, false)
  if not nx_is_valid(form_back) then
    return false
  end
  form_layout_center(form)
  if nx_string(form.plate_aware_form_value) == nx_string(MODULE_SKIN.SkyHill) then
    form_back.name = form.plate_aware_form_value
    form_back.lbl_back.BlendColor = "0, 0, 0, 0"
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_wuxue\\form_faculty_back", true)
  else
    form_back.name = form.plate_aware_form_value
    form_back.lbl_back.BlendColor = "255,255,255,255"
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_wuxue\\form_faculty_back", true)
  end
  refresh_plate_form(form)
end
function refresh_plate_form(form)
  for idx = 1, 4 do
    local btn_get = "btn_gain_" .. nx_string(idx)
    local btn_gain = form:Find(btn_get)
    if nx_is_valid(btn_gain) then
      btn_gain.Visible = false
    end
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_PLATE_NORMAL_AWARD, form, nx_current(), "on_awards_viewport_change")
    databinder:AddViewBind(VIEWPORT_PLATE_TREASURE_AWARD, form, nx_current(), "on_treasure_viewport_change")
  end
  on_plate_treasure_viewport_update(form, -1, -1)
end
function on_awards_viewport_change(form, optype, view_ident, index)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_plate_awards_viewport_change", form)
    timer:Register(200, 1, nx_current(), "on_plate_awards_viewport_change", form, -1, -1)
  end
end
function on_plate_awards_viewport_change(form, ...)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_NORMAL_AWARD))
  if not nx_is_valid(view) then
    return 1
  end
  for var = 1, MAX_NORMAL_BOX do
    reset_normal_drop_box(form, view, var)
  end
end
function update_time_limit_info(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if nx_int(form.time_limit) == nx_int(0) then
    timer:UnRegister(nx_current(), "update_time_limit_info", form)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.time_limit = form.time_limit - 1
  form.btn_close.Text = gui.TextManager:GetFormatText("ui_xmqy_award_close", nx_widestr(form.time_limit))
end
function on_main_form_close(self)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_wuxue\\form_faculty_back", false)
  nx_destroy(self)
end
function on_treasure_viewport_change(form, optype, view_ident, index)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  if optype == "additem" then
    timer:UnRegister(nx_current(), "on_plate_treasure_viewport_additem", form)
    timer:Register(100, 1, nx_current(), "on_plate_treasure_viewport_additem", form, nx_string(optype), index)
  elseif optype == "delitem" then
    timer:UnRegister(nx_current(), "on_plate_treasure_viewport_delete", form)
    timer:Register(100, 1, nx_current(), "on_plate_treasure_viewport_delete", form, nx_string(optype), index)
  end
  if form.Visible == false then
    on_plate_treasure_viewport_update(form, -1, -1)
  end
end
function on_plate_treasure_viewport_update(form, ...)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_TREASURE_AWARD))
  if not nx_is_valid(view) then
    return 1
  end
  for var = 1, MAX_NORMAL_BOX do
    reset_treasure_drop_box(form, view, var)
  end
end
function on_plate_treasure_viewport_additem(form, optype, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_TREASURE_AWARD))
  if not nx_is_valid(view) then
    return 1
  end
  for var = 1, 4 do
    form.imagegrid:DelItem(nx_int(var - 1))
    local item = view:GetViewObj(nx_string(var))
    if nx_is_valid(item) then
      local item_config = item:QueryProp("ConfigID")
      local item_count = item:QueryProp("Amount")
      local item_color_level = item:QueryProp("ColorLevel")
      local ItemQuery = nx_value("ItemQuery")
      local item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
      if not nx_is_valid(ItemQuery) then
        return
      end
      local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
      if bExist == false then
        return
      end
      form.imagegrid:AddItem(nx_int(var - 1), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
    end
  end
end
function on_plate_treasure_viewport_delete(form, optype, index)
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid:DelItem(nx_int(index - 1))
end
function reset_normal_drop_box(form, view, index)
  form.imagegrid_normal:DelItem(nx_int(index - 1))
  local viewobj = view:GetViewObj(nx_string(index))
  if nx_is_valid(viewobj) then
    form.imagegrid_normal:DelItem(nx_int(index))
    local item_config = viewobj:QueryProp("ConfigID")
    local item_count = viewobj:QueryProp("Amount")
    local item_color_level = viewobj:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    local item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    form.imagegrid_normal:AddItem(nx_int(index - 1), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
  end
end
function reset_treasure_drop_box(form, view, index)
  form.imagegrid:DelItem(nx_int(index - 1))
  local item = view:GetViewObj(nx_string(index))
  local btn = "btn_remove_" .. nx_string(index)
  local btn_remove = form:Find(btn)
  if not nx_is_valid(btn_remove) then
    return
  end
  local btn_get = "btn_gain_" .. nx_string(index)
  local btn_gain = form:Find(btn_get)
  if not nx_is_valid(btn_gain) then
    return
  end
  local card_ani = "ani_" .. nx_string(index)
  local ani = form:Find(card_ani)
  if not nx_is_valid(ani) then
    return
  end
  if nx_is_valid(item) then
    local item_config = item:QueryProp("ConfigID")
    local item_count = item:QueryProp("Amount")
    local item_color_level = item:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    local item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    form.imagegrid:AddItem(nx_int(index - 1), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
    ani:Play()
    btn_remove.Visible = false
    btn_gain.Visible = true
  else
    btn_remove.Visible = true
    btn_gain.Visible = false
  end
  if nx_number(form.treasure_geted) == nx_number(1) then
    btn_remove.Visible = false
    btn_gain.Visible = false
    ani:Play()
  end
end
function on_server_message(server_cmd_id, module, ...)
  if string.sub(nx_string(module), 1, 10) == "WeatherWar" then
    module = "WeatherWar"
  end
  local skin = MODULE_SKIN[module]
  if not skin or string.len(nx_string(skin)) <= 0 then
    return
  end
  form = nx_value(nx_string(skin))
  if not nx_is_valid(form) then
    if nx_int(server_cmd_id) == nx_int(eEndPlateAward) then
      return
    end
    form = nx_execute("util_gui", "util_get_form", nx_string(skin), true, false)
    if not nx_is_valid(form) then
      return
    end
    if nx_string(nx_value(nx_string(skin))) == "SkyHill" then
      form.plate_aware_form_value = nx_string(skin)
    end
    nx_set_value(nx_string(skin), form)
    form.plate_aware_form_value = nx_string(skin)
    form.time_limit = 0
  end
  if not nx_is_valid(form) then
    return
  end
  if nx_int(server_cmd_id) == nx_int(eShowAwardForm) then
    if nx_number(table.getn(arg)) < nx_number(2) then
      return
    end
    local time_limit = nx_int(arg[1])
    local treasure_geted = nx_int(arg[2])
    local open_count = nx_int(arg[3])
    form.time_limit = time_limit
    form.treasure_geted = treasure_geted
    form.lbl_num.Text = nx_widestr(open_count)
    OnServerShowAwardForm(form, time_limit)
  elseif nx_int(server_cmd_id) == nx_int(eRestartAwardForm) then
    if nx_number(table.getn(arg)) < nx_number(7) then
      return
    end
    local time_limit = nx_int(arg[1])
    local treasure_geted = nx_int(arg[2])
    local open_count = nx_int(arg[3])
    form.time_limit = time_limit
    form.treasure_geted = treasure_geted
    form.lbl_num.Text = nx_widestr(open_count)
    for idx = 1, 4 do
      local btn = "btn_remove_" .. nx_string(idx)
      local btn_remove = form:Find(btn)
      if not nx_is_valid(btn_remove) then
        return
      end
      local btn_get = "btn_gain_" .. nx_string(idx)
      local btn_gain = form:Find(btn_get)
      if not nx_is_valid(btn_gain) then
        return
      end
      local opt = nx_int(arg[3 + idx])
      if opt == nx_int(0) then
        btn_remove.Visible = true
        btn_gain.Visible = false
      elseif opt == nx_int(1) then
        btn_remove.Visible = false
        btn_gain.Visible = true
      elseif opt == nx_int(2) then
        btn_remove.Visible = false
        btn_gain.Visible = false
      end
    end
    OnServerShowAwardForm(form, time_limit)
  elseif nx_int(server_cmd_id) == nx_int(eSCPayOpenPlate) then
    if nx_number(table.getn(arg)) < nx_number(2) then
      return
    end
    local nMoneyType = arg[1]
    local nMoneyPrize = arg[2]
    OnPayOpenPlate(form, nMoneyType, nMoneyPrize)
  elseif nx_int(server_cmd_id) == nx_int(eSCPayPickUpTreasure) then
    if nx_number(table.getn(arg)) < nx_number(2) then
      return
    end
    local nMoneyType = arg[1]
    local nMoneyPrize = arg[2]
    OnPayPickUpTreasure(form, nMoneyType, nMoneyPrize)
  elseif nx_int(server_cmd_id) == nx_int(eEndPlateAward) then
    OnServerEndPlateAward(form, arg)
  elseif nx_int(server_cmd_id) == nx_int(eSucceedGetTreasure) then
    if nx_number(table.getn(arg)) < nx_number(1) then
      return
    end
    local nPlate = arg[1]
    form.lbl_num.Text = nx_widestr(0)
    OnServerSucceedGetTreasure(form, nPlate)
  elseif nx_int(server_cmd_id) == nx_int(eSucceedOpenPlate) then
    if nx_number(table.getn(arg)) < nx_number(2) then
      return
    end
    local nidx = nx_int(arg[1])
    local bActive = nx_int(arg[2])
    local open_count = nx_int(arg[3])
    form.lbl_num.Text = nx_widestr(open_count)
    OnServerSucceedOpenPlate(form, nidx, bActive)
  end
end
function OnServerShowAwardForm(form, time_limit)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "update_time_limit_info", form)
  timer:Register(1000, time_limit, nx_current(), "update_time_limit_info", form, -1, -1)
  update_time_limit_info(form)
  form:Show()
end
function OnServerEndPlateAward(form, ...)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function OnServerSucceedOpenPlate(form, nindex, bActive)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_TREASURE_AWARD))
  if not nx_is_valid(view) then
    return 1
  end
  local card_ani = "ani_" .. nx_string(nindex)
  local ani = form:Find(card_ani)
  if not nx_is_valid(ani) then
    return
  end
  ani:Play()
  local btn = "btn_remove_" .. nx_string(nindex)
  local btn_remove = form:Find(btn)
  if not nx_is_valid(btn_remove) then
    return
  end
  local btn_get = "btn_gain_" .. nx_string(nindex)
  local btn_gain = form:Find(btn_get)
  if not nx_is_valid(btn_gain) then
    return
  end
  if bActive == nx_int(1) then
    btn_gain.Visible = true
    btn_remove.Visible = false
  elseif bActive == nx_int(0) then
    btn_gain.Visible = false
    btn_remove.Visible = false
  end
end
function ShowConfirmInfo(nMoneyType, nMoneyPrize, op)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return true
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local strInfo = nx_widestr("")
  if op == TRY_GET_AWARD_PLATE then
    if nx_number(nMoneyPrize) == nx_number(0) then
      strInfo = gui.TextManager:GetText("ui_xmqy_award_06")
    else
      strInfo = MakeInfoStr(op, nMoneyType, nMoneyPrize)
    end
  elseif op == TRY_OPEN_ONE_PLATE then
    strInfo = MakeInfoStr(op, nMoneyType, nMoneyPrize)
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, strInfo)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res == "ok"
end
function ShowCloseInfo(form)
  if not nx_is_valid(form) then
    return true
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat")
  if not nx_is_valid(dialog) then
    return true
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return true
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return true
  end
  local view_normal = game_client:GetView(nx_string(VIEWPORT_PLATE_NORMAL_AWARD))
  local view_plate = game_client:GetView(nx_string(VIEWPORT_PLATE_TREASURE_AWARD))
  local msgid = nx_string("")
  local plate_count_get = 0
  for idx = 1, 4 do
    local btn_get = "btn_gain_" .. nx_string(idx)
    local btn_gain = form:Find(btn_get)
    if nx_is_valid(btn_gain) and btn_gain.Visible == true then
      plate_count_get = plate_count_get + 1
    end
  end
  if 0 < plate_count_get then
    msgid = nx_string("ui_xmqy_award_09")
  elseif not nx_is_valid(view_plate) then
    msgid = nx_string("ui_xmqy_award_10")
  elseif nx_is_valid(view_normal) then
    local viewobj_list = view_normal:GetViewObjList()
    local count = table.maxn(viewobj_list)
    if 0 < count then
      msgid = nx_string("ui_xmqy_award_08")
    else
      return true
    end
  end
  local strInfo = gui.TextManager:GetText(msgid)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, strInfo)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res == "ok"
end
function MakeInfoStr(op, money_type, money_count)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_widestr("")
  end
  local retStr = nx_widestr("")
  if op == TRY_GET_AWARD_PLATE then
    if nx_number(money_type) == nx_number(1) then
      strInfo = gui.TextManager:GetFormatText("ui_battle_pickupcost1", money_count)
    elseif nx_number(money_type) == nx_number(2) then
      strInfo = gui.TextManager:GetFormatText("ui_battle_pickupcost", money_count)
    elseif nx_number(money_type) == nx_number(100) then
      strInfo = gui.TextManager:GetFormatText("ui_tianti_060", money_count)
    end
  elseif op == TRY_OPEN_ONE_PLATE then
    if nx_number(money_type) == nx_number(1) then
      strInfo = gui.TextManager:GetFormatText("ui_xmqy_award_07", money_count)
    elseif nx_number(money_type) == nx_number(2) then
      strInfo = gui.TextManager:GetFormatText("ui_xmqy_award_04", money_count)
    elseif nx_number(money_type) == nx_number(100) then
      strInfo = gui.TextManager:GetFormatText("ui_tianti_059", money_count)
    end
  end
  return strInfo
end
function OnPayOpenPlate(form, nMoneyType, nMoneyPrize)
  if not ShowConfirmInfo(nMoneyType, nMoneyPrize, TRY_OPEN_ONE_PLATE) then
    return
  end
  local plate_award_module = nx_value("form_plate_award_logic")
  if not nx_is_valid(plate_award_module) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  plate_award_module:SubmitRequest(form, nx_null(), OPEN_ONE_PLATE, 0)
end
function OnPayPickUpTreasure(form, nMoneyType, nMoneyPrize)
  if not ShowConfirmInfo(nMoneyType, nMoneyPrize, TRY_GET_AWARD_PLATE) then
    return
  end
  local module = nx_value("form_plate_award_logic")
  if not nx_is_valid(module) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  module:SubmitRequest(form, nx_null(), GET_AWARD_FROM_PLATE, 0)
end
function OnServerSucceedGetTreasure(form, nPlate)
  if not nx_is_valid(form) then
    return
  end
  local btn = "btn_remove_" .. nx_string(nPlate)
  local btn_remove = form:Find(btn)
  if not nx_is_valid(btn_remove) then
    return
  end
  local btn_get = "btn_gain_" .. nx_string(nPlate)
  local btn_gain = form:Find(btn_get)
  if not nx_is_valid(btn_gain) then
    return
  end
  btn_gain.Visible = false
end
function on_btn_gain_all_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local module = nx_value("form_plate_award_logic")
  if not nx_is_valid(module) then
    return
  end
  module:SubmitRequest(form, self, SELECT_ALL_NORMAL_AWARD, 0)
end
function on_btn_remove_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local module = nx_value("form_plate_award_logic")
  if not nx_is_valid(module) then
    return
  end
  local index = BUTTONS_REMOVE[self.Name]
  module:SubmitRequest(form, self, TRY_OPEN_ONE_PLATE, index)
end
function on_btn_gain_click(self)
  local form = self.Parent
  if not nx_is_valid(form) then
    return
  end
  local module = nx_value("form_plate_award_logic")
  if not nx_is_valid(module) then
    return
  end
  local index = BUTTONS_GAIN[self.Name]
  module:SubmitRequest(form, self, TRY_GET_AWARD_PLATE, index)
end
function on_imagegrid_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_TREASURE_AWARD))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, true)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_imagegrid_normal_mousein_grid(grid, index)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_PLATE_NORMAL_AWARD))
  if not nx_is_valid(view) then
    return
  end
  local viewobj = view:GetViewObj(nx_string(index + 1))
  if not nx_is_valid(viewobj) then
    return
  end
  nx_execute("tips_game", "show_3d_tips_one", viewobj, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm, false)
end
function on_imagegrid_normal_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_btn_close_click(self)
  local form = self.Parent
  if not ShowCloseInfo(form) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local module = nx_value("form_plate_award_logic")
  if not nx_is_valid(module) then
    return
  end
  if nx_string(form.plate_aware_form_value) == nx_string(MODULE_SKIN.SkyHill) then
    custom_skyhill_next(1)
  else
    module:SubmitRequest(form, self, CLOSE_FORM, 0)
    form:Close()
  end
end
function on_animation_end(self)
  self.Visible = false
end
function close_match_below()
  local form = nx_value("form_stage_main\\form_match\\form_match_below")
  if nx_is_valid(form) then
    form:Close()
  end
end
function close_form()
  local form = nx_value("form_stage_main\\form_guildwar_kuafu")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_out_click(btn)
  local form = nx_value(MODULE_SKIN.SkyHill)
  if nx_is_valid(form) and not ShowCloseInfo(form) then
    return
  end
  send_server_msg(g_msg_giveup, nx_int(ITT_SKY_HILL))
end
