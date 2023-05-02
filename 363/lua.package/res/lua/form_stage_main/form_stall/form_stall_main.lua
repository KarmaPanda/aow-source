require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("define\\sysinfo_define")
require("share\\capital_define")
require("util_vip")
EOSB_CONFIGID = 0
EOSB_UNIQUEID = 1
EOSB_CONTAINER_POS = 2
EOSB_PACK_POS = 3
EOSB_PACK_INDEX = 4
EOSB_SELL_NUMBER = 5
EOSB_PACK_AMOUNT_NUMBER = 6
EOSB_SELL_SILVER = 7
STALL_SELL_COUNT_VIP = 60
STALL_SELL_COUNT_NO_VIP = 30
STALL_BUY_COUNT_VIP = 60
STALL_BUY_COUNT_NO_VIP = 30
local TableEnum = {
  None = 0,
  ShangJia = 1,
  ShouGou = 2,
  LifeServer = 3,
  JiaoYi = 4,
  LiuYan = 5
}
local Not_Stall_Area = -2
local Not_Stall_Free = -1
local On_Stalled = -3
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(form)
  form.Fixed = false
  form.IsInitServerForm = false
  form.IsInitStallNotesForm = false
  form.IsInitLiuYanNotesForm = false
  form.IsInitSellForm = false
  form.IsInitBuyForm = false
  form.StallName = ""
  form.StallYaoHe = ""
  form.StallTime = 0
  form.StallGold = 0
  form.StyleNumber = 0
  form.TagTable = 0
  form.IsOnline = true
  form.IsServer = false
  form.IsStall = false
  form.SelectNpc = nil
  form.StallPosIndex = -1
  form.IsStalled = false
  return 1
end
function is_enable_stall()
  local area_limit = {
    "run",
    "ride",
    "find_path",
    "map",
    "dive",
    "offline",
    "sword",
    "PVP",
    "PVE",
    "trade",
    "stall",
    "chat",
    "mail",
    "tool",
    "life_skill",
    "qinggong",
    "plant",
    "restore_skill",
    "sit",
    "sound"
  }
  local region_name = {
    "forbid_run",
    "forbid_ride",
    "forbid_find_path",
    "forbid_map",
    "forbid_dive",
    "forbid_offline",
    "forbid_sword",
    "forbid_PVP",
    "forbid_PVE",
    "forbid_trade",
    "permit_stall",
    "forbid_chat",
    "forbid_mail",
    "forbid_tool",
    "forbid_life_skill",
    "forbid_qinggong",
    "permit_plant",
    "forbid_restore_skill",
    "forbid_sit",
    "permit_sound"
  }
  local game_visual = nx_value("game_visual")
  local visual_player = nx_null()
  if nx_is_valid(game_visual) then
    visual_player = game_visual:GetPlayer()
  else
    visual_player = nx_value("main_player")
  end
  if not nx_is_valid(visual_player) then
    return false
  end
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return false
  end
  local terrain = scene.terrain
  if not nx_is_valid(terrain) then
    return false
  end
  for i = 1, table.maxn(area_limit) do
    local region_enable = terrain:GetRegionEnable(region_name[i], visual_player.PositionX, visual_player.PositionZ)
    if area_limit[i] == "stall" and region_enable then
      return true
    end
  end
  return false
end
function on_init_info(form)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return false
  end
  local state = client_role:QueryProp("LogicState")
  local FortuneTellingState = client_role:QueryProp("FortuneTellingState")
  if nx_int(state) == nx_int(LS_STALLED) and nx_int(FortuneTellingState) == nx_int(2) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("7092"), 2)
    end
    form:Close()
    return false
  end
  if nx_int(state) ~= nx_int(LS_STALLED) and nx_int(state) ~= nx_int(0) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "40048")
    form:Close()
    return false
  end
  if nx_is_valid(client_role) then
    local power_level = client_role:QueryProp("PowerLevel")
    if power_level < 11 then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "80012")
      form:Close()
      return false
    end
  end
  local stallName = nx_widestr(client_role:QueryProp("StallName"))
  form.lbl_title_text.Text = nx_widestr(gui.TextManager:GetFormatText("ui_stall_title"))
  form.lbl_stall_mode.Text = nx_widestr(gui.TextManager:GetFormatText("ui_stall_mode_online"))
  if nx_int(state) == nx_int(LS_STALLED) then
    form.btn_offline_stall.Text = nx_widestr(gui.TextManager:GetFormatText("ui_CancelStallBox"))
    form.btn_online_stall.Visible = false
    form.ipt_name.ReadOnly = true
    form.lbl_bj2.Visible = false
    form.ani_loading.Visible = false
    form.IsStalled = true
    form.lbl_stall_pos.Text = gui.TextManager:GetText("@ui_stall_baitanzhong")
    form.lbl_stall_pos.ForeColor = "255,0,255,0"
  else
    if stallName == nx_widestr("0") then
      stallName = gui.TextManager:GetFormatText("ui_stall_mingcheng", nx_widestr(client_role:QueryProp("Name")))
    end
    form.ipt_name.ReadOnly = false
    form.IsStalled = false
    form.lbl_bj2.Visible = true
    form.ani_loading.Visible = true
    form.ani_loading.PlayMode = 0
  end
  form.ipt_name.Text = nx_widestr(stallName)
  form.StallName = nx_widestr(stallName)
  if not form.IsOnline then
    form.btn_online_stall.Visible = false
  end
  return true
end
function on_main_form_open(form)
  if not Stall_Fortunetell_Mutual(form, 0) then
    return
  end
  update_form_pos(form)
  if not on_init_info(form) then
    return
  end
  custom_request_stall(form)
  form.rbtn_shougou.Checked = true
  form.rbtn_chushou.Checked = true
  form.Visible = true
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_tip", false, false)
  if nx_is_valid(dialog) then
    dialog:Close()
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_OFFLINE_SELL_BOX, form, "form_stage_main\\form_stall\\form_stall_main", "on_sellbox_viewport_change")
  end
  return 1
end
function on_main_form_close(form)
  form.Visible = false
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if nx_is_valid(client_role) then
    local state = client_role:QueryProp("LogicState")
    if nx_int(state) ~= nx_int(LS_STALLED) and nx_int(state) ~= nx_int(LS_OFFLINE_STALL) then
      local game_visual = nx_value("game_visual")
      if nx_is_valid(game_visual) then
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REMOVE_ALL_SELL))
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_REQUEST_STALL))
      end
    elseif form.IsStalled then
      local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_tip", true, false)
      dialog:Show()
    end
  end
  nx_destroy(form)
  return 1
end
function on_sellbox_viewport_change(form, optype)
  if "deleteview" == optype and nx_is_valid(form) then
    form:Close()
  end
end
function get_stall_pos_index_okey(stall_pos_index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_main", false, false)
  if not nx_is_valid(form) then
    return
  end
  form.StallPosIndex = stall_pos_index
  local gui = nx_value("gui")
  if nx_int(stall_pos_index) == nx_int(-2) then
    form.lbl_stall_pos.Text = gui.TextManager:GetText("@ui_stall_out")
    form.lbl_stall_pos.ForeColor = "255,255,0,0"
    form.btn_online_stall.Enabled = false
    form.btn_offline_stall.Enabled = false
  elseif nx_int(stall_pos_index) == nx_int(-1) then
    form.lbl_stall_pos.Text = gui.TextManager:GetText("@ui_stall_no")
    form.lbl_stall_pos.ForeColor = "255,255,255,0"
    form.btn_online_stall.Enabled = false
    form.btn_offline_stall.Enabled = false
  else
    form.lbl_stall_pos.Text = gui.TextManager:GetText("@ui_stall_null")
    form.lbl_stall_pos.ForeColor = "255,0,255,0"
    form.btn_online_stall.Enabled = true
    form.btn_offline_stall.Enabled = true
  end
  nx_execute("form_stage_main\\form_stall\\form_stall_sell", "RefreshSell")
  form.lbl_bj2.Visible = false
  form.ani_loading.Visible = false
end
function show_window()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_stall\\form_stall_main", true, false)
  form:Show()
end
function custom_request_stall(form)
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if nx_is_valid(client_role) then
    local state = client_role:QueryProp("LogicState")
    if nx_int(state) == nx_int(LS_STALLED) or nx_int(state) == nx_int(LS_OFFLINE_STALL) then
      return 0
    end
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OPEN_OFFLINE_SELL))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SELECT_REQUEST_STALL))
end
function update_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 250
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
  return 1
end
function hide_other_control(form)
  if form.IsInitSellForm then
    form.page_sell.Visible = false
  end
  if form.IsInitBuyForm then
    form.page_buy.Visible = false
  end
  if form.IsInitLiuYanNotesForm then
    form.page_liuyan.Visible = false
  end
  if form.IsInitServerForm then
    form.page_server.Visible = false
  end
  if form.IsInitStallNotesForm then
    form.page_stallnotes.Visible = false
  end
end
function show_tanwei(form)
  hide_other_control(form)
  if not form.IsInitStallConfigForm then
    local page_stallconfig = util_get_form("form_stage_main\\form_stall\\form_stall_config", true, false)
    if form:Add(page_stallconfig) then
      form.page_stallconfig = page_stallconfig
      form.page_stallconfig.Visible = false
      form.page_stallconfig.Fixed = true
      form.page_stallconfig.Left = 10
      form.page_stallconfig.Top = 80
      form.IsInitStallConfigForm = true
    end
  end
  form.page_stallconfig.Visible = true
  form:ToFront(form.page_stallconfig)
end
function on_rbtn_chushou_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    show_sell_grid(form)
  end
end
function on_rbtn_shougou_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    hide_other_control(form)
    if not form.IsInitBuyForm then
      local page_buy = util_get_form("form_stage_main\\form_stall\\form_stall_buy", true, false)
      if form:Add(page_buy) then
        form.page_buy = page_buy
        form.page_buy.Visible = false
        form.page_buy.Fixed = true
        form.page_buy.Left = form.lbl_back.Left + 10
        form.page_buy.Top = form.lbl_back.Top + 10
        form.IsInitBuyForm = true
      end
    end
    form.btn_clear.Visible = true
    form.TagTable = TableEnum.ShouGou
    form.page_buy.Visible = true
    form:ToFront(form.page_buy)
    if isStalled() then
      form.btn_clear.Visible = false
    end
  end
end
function show_sell_grid(form)
  hide_other_control(form)
  local form_bag = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_bag", true, false)
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if nx_is_valid(client_role) then
    local state = client_role:QueryProp("LogicState")
    if nx_int(state) ~= nx_int(LS_STALLED) and nx_int(state) ~= nx_int(LS_OFFLINE_STALL) then
      form_bag.Visible = true
      form_bag:Show()
    end
  end
  if not form.IsInitSellForm then
    local page_sell = util_get_form("form_stage_main\\form_stall\\form_stall_sell", true, false)
    page_sell.form_bag = form_bag
    if form:Add(page_sell) then
      form.page_sell = page_sell
      form.page_sell.Visible = true
      form.page_sell.Fixed = true
      form.page_sell.Left = form.lbl_back.Left + 10
      form.page_sell.Top = form.lbl_back.Top + 10
      form.IsInitSellForm = true
    end
  end
  form.page_sell.Visible = true
  form.btn_clear.Visible = true
  form.TagTable = TableEnum.ShangJia
  if isStalled() then
    form.TagTable = TableEnum.ShangJia
    form.btn_clear.Visible = false
  end
  form:ToFront(form.page_sell)
end
function on_rbtn_jilu_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    show_jilu(form)
  end
end
function on_rbtn_liuyan_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    hide_other_control(form)
    if not form.IsInitLiuYanNotesForm then
      local page_liuyan = util_get_form("form_stage_main\\form_stall\\form_stall_liuyan", true, false)
      if form:Add(page_liuyan) then
        form.page_liuyan = page_liuyan
        form.page_liuyan.Visible = false
        form.page_liuyan.Fixed = true
        form.page_liuyan.Left = form.lbl_back.Left + 10
        form.page_liuyan.Top = form.lbl_back.Top + 10
        form.IsInitLiuYanNotesForm = true
      end
    else
      nx_execute("form_stage_main\\form_stall\\form_stall_liuyan", "init_info", form.page_liuyan)
    end
    form.btn_clear.Visible = true
    form.TagTable = TableEnum.LiuYan
    form.page_liuyan.Visible = true
    form:ToFront(form.page_liuyan)
  end
end
function show_jilu(form)
  hide_other_control(form)
  if not form.IsInitStallNotesForm then
    local page_stallnotes = util_get_form("form_stage_main\\form_stall\\form_stall_stallnotes", true, false)
    if form:Add(page_stallnotes) then
      form.page_stallnotes = page_stallnotes
      form.page_stallnotes.Visible = false
      form.page_stallnotes.Fixed = true
      form.page_stallnotes.Left = form.lbl_back.Left + 10
      form.page_stallnotes.Top = form.lbl_back.Top + 10
      form.IsInitStallNotesForm = true
    end
  else
    nx_execute("form_stage_main\\form_stall\\form_stall_stallnotes", "init_info", form.page_stallnotes)
  end
  form.btn_clear.Visible = true
  form.TagTable = TableEnum.JiaoYi
  form.page_stallnotes.Visible = true
  form:ToFront(form.page_stallnotes)
end
function check_stall_name(name)
  if nx_ws_length(name) > 0 then
    return true
  end
  return false
end
function check_shougou_data(form)
  if not nx_is_valid(form) then
    return false
  end
  if not form.IsInitBuyForm then
    return false
  end
  if not nx_is_valid(form.page_buy) then
    return false
  end
  if not nx_is_valid(form.page_buy.buy_grid) then
    return false
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(form.page_buy.buy_grid.typeid))
  if not nx_is_valid(view) then
    return false
  end
  if table.getn(view:GetViewObjList()) <= 0 then
    return false
  end
  return true
end
function check_sell_grid(form)
  if not nx_is_valid(form) then
    return false
  end
  if not form.IsInitSellForm then
    return false
  end
  if not nx_is_valid(form.page_sell) then
    return false
  end
  if not nx_is_valid(form.page_sell.sell_grid) then
    return false
  end
  local sellcount = 0
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(form.page_sell.sell_grid.typeid))
  if not nx_is_valid(view) then
    return false
  end
  if 0 >= table.getn(view:GetViewObjList()) then
    return false
  end
  return true
end
function form_error(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
  nx_wait_event(100000000, dialog, "error_return")
end
function is_can_stall(form)
  if form.StallPosIndex < 0 then
    if nx_int(form.StallPosIndex) == nx_int(Not_Stall_Area) then
      form_error(form, "ui_stall_select_tanwei")
      return false
    elseif nx_int(form.StallPosIndex) == nx_int(Not_Stall_Free) then
      form_error(form, "ui_stall_fall_tanwei")
      return false
    end
    return false
  end
  return true
end
function on_btn_online_stall_click(btn)
  local form = btn.ParentForm
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    nx_log("no client player")
    return 0
  end
  local stallName = form.ipt_name.Text
  local stallYaohe
  local stallstate = client_role:QueryProp("LogicState")
  if nx_int(stallstate) ~= nx_int(LS_STALLED) then
    if not is_can_stall(form) then
      return 0
    end
    local name = nx_widestr(stallName)
    if not check_stall_name(name) then
      form_error(form, "ui_StallNameCanNotBeEmpty")
      return 0
    end
    if not check_sell_grid(form) and not check_shougou_data(form) then
      form_error(form, "ui_StallGridCanNotBeEmpty")
      return 0
    end
    local game_visual = nx_value("game_visual")
    local role = nx_value("role")
    if game_visual:QueryRoleFloorIndex(role) < 100 then
      custom_begin_stall(form, 0)
    else
      local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
      local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
        if form_sysinfo.info_group.Visible == true then
          form_main_sysinfo_logic:AddSystemInfo(util_text("ui_StandToMakeStall"), 0, 0)
        else
          form_main_sysinfo_logic:AddSystemInfo(util_text("ui_StandToMakeStall"), SYSTYPE_FIGHT, 0)
        end
      end
    end
  end
  return 1
end
function on_btn_offline_stall_click(btn)
  local form = btn.ParentForm
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    nx_log("no client player")
    return 0
  end
  local stallName = form.ipt_name.Text
  local stallYaohe
  local stallstate = client_role:QueryProp("LogicState")
  local gui = nx_value("gui")
  local vip_status = nx_execute("util_vip", "is_vip", client_role, VT_NORMAL)
  if nx_int(stallstate) ~= nx_int(LS_STALLED) then
    if not vip_status then
      local form_prompt = nx_value("form_stage_main\\form_vip_prompt")
      if nx_is_valid(form_prompt) then
        form_prompt:Close()
      end
      form_prompt = util_show_form("form_stage_main\\form_vip_prompt", true)
      form_prompt.info_mltbox.HtmlText = gui.TextManager:GetText("ui_jhhy_4")
      return
    end
    if not is_can_stall(form) then
      return 0
    end
    local name = nx_widestr(stallName)
    if not check_stall_name(name) then
      form_error(form, "ui_StallNameCanNotBeEmpty")
      return 0
    end
    if not check_sell_grid(form) and not check_shougou_data(form) then
      form_error(form, "ui_StallGridCanNotBeEmpty")
      return 0
    end
    local game_visual = nx_value("game_visual")
    local role = nx_value("role")
    if game_visual:QueryRoleFloorIndex(role) < 100 then
      custom_begin_stall(form, 1)
    else
      local form_sysinfo = nx_value("form_stage_main\\form_main\\form_main_sysinfo")
      local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_sysinfo) and nx_is_valid(form_main_sysinfo_logic) then
        if form_sysinfo.info_group.Visible == true then
          form_main_sysinfo_logic:AddSystemInfo(util_text("ui_StandToMakeStall"), 0, 0)
        else
          form_main_sysinfo_logic:AddSystemInfo(util_text("ui_StandToMakeStall"), SYSTYPE_FIGHT, 0)
        end
      end
    end
  else
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_Stall_Is_JieSu"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_stall_return_ready")
      if nx_is_valid(form) then
        form.IsStalled = false
        form:Close()
      end
    end
  end
  return 1
end
function pathing(npc_id, x, y, z, o, ident)
  local path_finding = nx_value("path_finding")
  local game_client = nx_value("game_client")
  if not nx_is_valid(path_finding) then
    return 1
  end
  if not nx_is_valid(game_client) then
    return 1
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_player = nx_null()
  if nx_is_valid(game_visual) then
    visual_player = game_visual:GetPlayer()
  else
    visual_player = nx_value("main_player")
  end
  visual_player.FindStallNpcIdent = nx_string(ident)
  local city_name = client_scene:QueryProp("Resource")
  path_finding:TraceTargetByID(city_name, nx_float(x), nx_float(y), nx_float(z), nx_float(o), npc_id)
end
function custom_begin_stall(form, isOffline)
  local time = form.StallTime
  local name = nx_widestr(form.ipt_name.Text)
  local isOnline = 1
  if not form.IsOnline then
    isOnline = 0
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local info
  if isOffline == 1 then
    info = gui.TextManager:GetFormatText("ui_offline_form_baitan_confirm")
  elseif isOffline == 0 then
    info = gui.TextManager:GetFormatText("ui_online_form_tanwei_confirm")
  end
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    local CheckWords = nx_value("CheckWords")
    local filter_name = CheckWords:CleanWords(nx_widestr(name))
    if isOffline == 1 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_BEGIN_STALL), nx_widestr(filter_name), nx_int(time), nx_int(0))
    elseif isOffline == 0 then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OFFLINE_BEGIN_STALL), nx_widestr(filter_name), nx_int(time), nx_int(1))
    end
  end
end
function check_item_data(grid, grid_index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return nil
  end
  local data = GoodsGrid:GetItemData(grid, grid_index)
  if nx_string(data) == "" then
    return false
  end
  return true
end
function start_offline_stall()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_START_OFFLINE_STALL))
end
function player_offline()
  nx_execute("main", "direct_exit_game")
end
function custom_online_ok()
  local form = util_get_form("form_stage_main\\form_stall\\form_stall_main", false, false)
  if not nx_is_valid(form) then
    return
  end
  form.IsStalled = true
  local gui = nx_value("gui")
  form.lbl_stall_pos.Text = gui.TextManager:GetText("@ui_stall_baitanzhong")
  form.lbl_stall_pos.ForeColor = "255,0,255,0"
  form.btn_offline_stall.Text = nx_widestr(gui.TextManager:GetFormatText("ui_CancelStallBox"))
  form.btn_online_stall.Visible = false
end
function on_reset()
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_stall_reset_confirm"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_END_STALL))
  end
end
function reset_ok()
  local form = util_get_form("form_stage_main\\form_stall\\form_option", false, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  local form1 = util_get_form("form_stage_main\\form_stall\\form_option", true, false)
  form1:Show()
end
function get_distance(x, y, z, player)
  if not nx_is_valid(player) then
    return -1
  end
  local game_visual = nx_value("game_visual")
  local visual_scene_obj = game_visual:GetSceneObj(player.Ident)
  if not nx_is_valid(visual_scene_obj) then
    return
  end
  local player_x = visual_scene_obj.PositionX
  local player_y = visual_scene_obj.PositionY
  local player_z = visual_scene_obj.PositionZ
  local sx = x - player_x
  local sy = y - player_y
  local sz = z - player_z
  return math.sqrt(sx * sx + sy * sy + sz * sz)
end
function isStalled()
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    return false
  end
  local state = client_role:QueryProp("LogicState")
  if nx_int(state) == nx_int(LS_STALLED) then
    return true
  end
  return false
end
function on_btn_clear_click(btn)
  local form = btn.ParentForm
  if form.TagTable == TableEnum.ShangJia then
    nx_execute("form_stage_main\\form_stall\\form_stall_sell", "on_btn_clear_click", btn)
  elseif form.TagTable == TableEnum.ShouGou then
    nx_execute("form_stage_main\\form_stall\\form_stall_buy", "on_btn_clear_click", btn)
  elseif form.TagTable == TableEnum.JiaoYi then
    nx_execute("form_stage_main\\form_stall\\form_stall_stallnotes", "on_btn_clear_click", btn)
  elseif form.TagTable == TableEnum.LiuYan then
    nx_execute("form_stage_main\\form_stall\\form_stall_liuyan", "on_btn_clear_click", btn)
  end
end
function on_btn_kuorong_click(btn)
  local form = btn.ParentForm
  if form.TagTable == TableEnum.ShangJia then
    nx_execute("form_stage_main\\form_stall\\form_stall_sell", "on_btn_kuorong_click", btn)
  elseif form.TagTable == TableEnum.ShouGou then
    nx_execute("form_stage_main\\form_stall\\form_stall_buy", "on_btn_kuorong_click", btn)
  end
end
function on_btn_sousuo_click(btn)
  local form = btn.ParentForm
  if form.TagTable == TableEnum.ShouGou then
    nx_execute("form_stage_main\\form_stall\\form_stall_buy", "on_btn_sousuo_click", btn)
  end
end
function Stall_Fortunetell_Mutual(form, stall_type)
  if stall_type ~= 0 and stall_type ~= 1 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "80043")
    form:Close()
    return false
  end
  local game_client = nx_value("game_client")
  local client_role = game_client:GetPlayer()
  if not nx_is_valid(client_role) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "80043")
    form:Close()
    return false
  end
  local stallstate = nx_number(client_role:QueryProp("LogicState"))
  local fortuneTellingstate = nx_number(client_role:QueryProp("FortuneTellingState"))
  if stall_type == 0 then
    if fortuneTellingstate == 2 then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "7092")
      form:Close()
      return false
    end
    local form_fortunetelling = nx_value("form_stage_main\\form_life\\form_fortunetelling_op")
    if nx_is_valid(form_fortunetelling) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "80045")
      form:Close()
      return false
    end
  end
  if stall_type == 1 then
    if stallstate == nx_number(LS_STALLED) and fortuneTellingstate ~= 2 then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "12510")
      form:Close()
      return false
    end
    local form_stall = nx_value("form_stage_main\\form_stall\\form_stall_main")
    if nx_is_valid(form_stall) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "80044")
      form:Close()
      return false
    end
  end
  return true
end
function refresh_total_price(viewport)
  local form = nx_value("form_stage_main\\form_stall\\form_stall_main")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewport))
  if not nx_is_valid(view) then
    return
  end
  local total_price = 0
  local viewobj_list = view:GetViewObjList()
  if nx_number(viewport) == nx_number(VIEWPORT_OFFLINE_SELL_BOX) then
    if not view:FindRecord("offline_sellbox_table") then
      return
    end
    for i, item in pairs(viewobj_list) do
      local row = view:FindRecordRow("offline_sellbox_table", EOSB_UNIQUEID, item:QueryProp("UniqueID"))
      if 0 <= row then
        local sell_price = view:QueryRecord("offline_sellbox_table", row, EOSB_SELL_SILVER)
        local sell_count = view:QueryRecord("offline_sellbox_table", row, EOSB_SELL_NUMBER)
        total_price = total_price + sell_price * sell_count
      end
    end
  elseif nx_number(viewport) == nx_number(VIEWPORT_STALL_PURCHASE_BOX) then
    for i, item in pairs(viewobj_list) do
      total_price = total_price + item:QueryProp("PurchasePrice1") * (item:QueryProp("BuyCountAll") - item:QueryProp("BuyedCount"))
    end
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local list = capital:SplitCapital(nx_number(total_price), nx_int(CAPITAL_TYPE_SILVER_CARD))
  if nx_number(viewport) == nx_number(VIEWPORT_OFFLINE_SELL_BOX) then
    form.lbl_sell_ding.Text = nx_widestr(list[1])
    form.lbl_sell_liang.Text = nx_widestr(list[2])
    form.lbl_sell_wen.Text = nx_widestr(list[3])
  elseif nx_number(viewport) == nx_number(VIEWPORT_STALL_PURCHASE_BOX) then
    form.lbl_buy_ding.Text = nx_widestr(list[1])
    form.lbl_buy_liang.Text = nx_widestr(list[2])
    form.lbl_buy_wen.Text = nx_widestr(list[3])
  end
end
function find_empty_pos(viewid, viewsize)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewid))
  if not nx_is_valid(view) then
    return 0
  end
  for pos = 1, viewsize do
    if not nx_is_valid(view:GetViewObj(nx_string(pos))) then
      return pos
    end
  end
  return 0
end
function find_item_price(viewid, configid)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(viewid))
  if not nx_is_valid(view) then
    return 0
  end
  local viewobj_list = view:GetViewObjList()
  if nx_number(viewid) == nx_number(VIEWPORT_OFFLINE_SELL_BOX) then
    if not view:FindRecord("offline_sellbox_table") then
      return 0
    end
    for i, item in pairs(viewobj_list) do
      if configid == item:QueryProp("ConfigID") then
        local row = view:FindRecordRow("offline_sellbox_table", EOSB_CONFIGID, configid)
        if 0 <= row then
          local silverprice = view:QueryRecord("offline_sellbox_table", row, EOSB_SELL_SILVER)
          return nx_execute("form_stage_main\\form_stall\\form_stall_sell", "trans_price", silverprice)
        end
      end
    end
  elseif nx_number(viewid) == nx_number(VIEWPORT_STALL_PURCHASE_BOX) then
    for i, item in pairs(viewobj_list) do
      if configid == item:QueryProp("ConfigID") then
        local silverprice = item:QueryProp("PurchasePrice1")
        return nx_execute("form_stage_main\\form_stall\\form_stall_sell", "trans_price", silverprice)
      end
    end
  end
  return 0
end
function GetSellCount(player)
  if not nx_is_valid(player) then
    return nx_int(STALL_SELL_COUNT_NO_VIP)
  end
  local vip_status = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if vip_status then
    return nx_int(STALL_SELL_COUNT_VIP)
  else
    return nx_int(STALL_SELL_COUNT_NO_VIP)
  end
  return nx_int(STALL_SELL_COUNT_NO_VIP)
end
function GetBuyCount(player)
  if not nx_is_valid(player) then
    return nx_int(STALL_BUY_COUNT_NO_VIP)
  end
  local vip_status = nx_execute("util_vip", "is_vip", player, VT_NORMAL)
  if vip_status then
    return nx_int(STALL_BUY_COUNT_VIP)
  else
    return nx_int(STALL_BUY_COUNT_NO_VIP)
  end
  return nx_int(STALL_BUY_COUNT_NO_VIP)
end
function on_btn_auction_click(btn)
  btn.ParentForm:Close()
  nx_execute("form_stage_main\\form_auction\\form_auction_main", "open_form")
  local form = util_get_form("form_stage_main\\form_auction\\form_auction_main", false, false)
  if nx_is_valid(form) then
    form.rbtn_sell.Checked = true
  end
end
