require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
local FortunetellingTipsText = {
  "tips_gua_1",
  "tips_gua_2",
  "tips_gua_3",
  "tips_gua_4",
  "tips_gua_5",
  "tips_gua_6",
  "tips_gua_7",
  "tips_gua_8",
  "tips_gua_9",
  "tips_gua_10"
}
local LblTipsText = {
  btn_1 = "tips_guatu_1",
  btn_2 = "tips_guatu_2",
  btn_3 = "tips_guatu_3"
}
local answer
local castmoney = {
  0,
  0,
  0
}
local fortunetelling_rank = 1
local cur_select_type = 1
local fortunetelling_type_num = 3
local Primary_Image = "gui\\common\\button\\btn_normal2_on.png"
local Select_Image = "gui\\common\\button\\btn_normal2_down.png"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function get_fortune_offline_state(target)
  local game_client = nx_value("game_client")
  local client_role = game_client:GetSceneObj(nx_string(target))
  if not nx_is_valid(client_role) then
    nx_msgbox(":" .. nx_string(client_role))
    return false
  end
  local OffLineJobManager = nx_value("OffLineJobManager")
  local LifeServerState = nx_int(client_role:QueryProp("LifeServerState"))
  if OffLineJobManager:PlaceOpera(LifeServerState, 256) == 256 then
    return true
  end
  return false
end
function Init(target, sprite, person, god, rank)
  local form = nx_value("form_stage_main\\form_life\\form_fortunetelling_list")
  if not nx_is_valid(form) then
    return
  end
  answer = target
  castmoney[1] = sprite
  castmoney[2] = person
  castmoney[3] = god
  fortunetelling_rank = rank
  local level = 3
  local offline_state = get_fortune_offline_state(target)
  show_qianzi_type(rank)
end
function show_qianzi_type(rank)
  local file_name = "share\\Life\\fortunetelling.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  bound_money = ini:ReadInteger(rank - 1, "BoundMoney", 0)
  not_bound_money = ini:ReadInteger(rank - 1, "Money", 0)
  local form = nx_value("form_stage_main\\form_life\\form_fortunetelling_list")
  if not nx_is_valid(form) then
    return
  end
  gold_type = form.groupbox_1:Find("lbl_bind_money")
  gold_type.Text = get_money_format(bound_money)
  silver_type = form.groupbox_1:Find("lbl_unbind_money")
  silver_type.Text = get_money_format(not_bound_money)
end
function change_form_position(form, level)
  if level >= fortunetelling_type_num or level <= 0 then
    return
  end
  local delat = form.groupbox_1.Height - form.groupbox_1.Height * level / fortunetelling_type_num
  form.groupbox_1.Height = form.groupbox_1.Height * level / fortunetelling_type_num
  form.Height = form.Height - delat
end
function on_btn_click(btn)
  local form = btn.ParentForm
  cur_select_type = nx_number(btn.Name)
  local select_btn = form.groupbox_1:Find(nx_string(cur_select_type))
  select_btn.NormalImage = "gui\\mainform\\smallgame\\guashi\\btn" .. nx_string(cur_select_type) .. "_down.png"
  if cur_select_type == 2 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("suangua"))
    return
  end
  local money_type
  if form.rbtn_unbind_money.Checked then
    money_type = 0
  else
    money_type = 1
  end
  need_fortunetelling(cur_select_type, money_type)
  if nx_is_valid(btn) then
    btn.ParentForm:Close()
  end
end
function need_fortunetelling(fortunetelling_type, money_type)
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(nx_string(answer))
  if not nx_is_valid(target_obj) then
    return
  end
  local type = target_obj:QueryProp("Type")
  if TYPE_PLAYER ~= tonumber(type) then
    return
  end
  local name = target_obj:QueryProp("Name")
  local offline_state = get_fortune_offline_state(answer)
  if not offline_state then
    local state = target_obj:QueryProp("FortuneTellingState")
    if 2 ~= state then
      return
    end
  end
  local file_name = "share\\Life\\fortunetelling.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local money = castmoney[fortunetelling_type]
  local moneysys = 0
  if money_type == 0 then
    moneysys = ini:ReadInteger(fortunetelling_rank - 1, "Money", 0)
  else
    moneysys = ini:ReadInteger(fortunetelling_rank - 1, "BoundMoney", 0)
  end
  local gold = ini:ReadInteger(fortunetelling_type - 1, "Gold", 0)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local money_format = get_money_format(money)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if 1 == fortunetelling_type then
    if money_type == 0 then
      gui.TextManager:Format_SetIDName("ui_sh_gsgq6")
    else
      gui.TextManager:Format_SetIDName("ui_sh_gsgq13")
    end
    gui.TextManager:Format_AddParam(money)
    gui.TextManager:Format_AddParam(moneysys)
  elseif 3 == fortunetelling_type then
    if money_type == 0 then
      gui.TextManager:Format_SetIDName("ui_sh_gsgq12")
    else
      gui.TextManager:Format_SetIDName("ui_sh_gsgq12_01")
    end
    gui.TextManager:Format_AddParam(money_format)
    gui.TextManager:Format_AddParam(get_money_format(moneysys))
  end
  local text = gui.TextManager:Format_GetText()
  dialog.mltbox_info:AddHtmlText(text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if 1 == fortunetelling_type then
      request_fortunetelling(name, fortunetelling_type, money_type, money)
    elseif 3 == fortunetelling_type then
      search_xuechou(name, fortunetelling_type, money_type, money)
    end
  end
end
function request_fortunetelling(name, rank, money_type, money)
  local game_client = nx_value("game_client")
  local visual_player = game_client:GetPlayer()
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_FORTUNETELLING, nx_widestr(name), nx_int(rank), nx_int(money_type), nx_int(money), nx_int(money_type))
end
function on_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_get_capture(btn)
end
function on_btn_lost_capture(btn)
end
function on_tip_btn_get_capture(lbl)
end
function on_tip_btn_lost_capture(lbl)
end
function get_money_format(money)
  local text = nx_widestr("")
  if money <= 0 then
    text = nx_widestr("0") .. nx_widestr(util_text("ui_bag_wen"))
    return text
  end
  local gold = money / 1000000
  gold = math.floor(gold)
  local silver = (money - gold * 1000000) / 1000
  local silver = math.floor(silver)
  local copper = money - silver * 1000 - gold * 1000000
  if gold ~= 0 then
    text = nx_widestr(gold) .. util_text("ui_bag_ding")
  end
  if silver ~= 0 then
    text = nx_widestr(text) .. nx_widestr(silver) .. nx_widestr(util_text("ui_bag_liang"))
  end
  if copper ~= 0 then
    text = nx_widestr(text) .. nx_widestr(copper) .. nx_widestr(util_text("ui_bag_wen"))
  end
  return text
end
function search_xuechou(name, type, money_type, money)
  local form = util_get_form("form_stage_main\\form_relation\\form_xuechou_search", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.name = name
  form.type = type
  form.money_type = money_type
  form.money = money
  form:Show()
end
function xuechou_trace_msg(msg_id, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_int(0) == nx_int(msg_id) then
    ShowTipDialog(util_text(nx_string(arg[1])), 0)
  elseif nx_int(1) == nx_int(msg_id) then
    gui.TextManager:Format_SetIDName("ui_xuechou_track_01")
    gui.TextManager:Format_AddParam(nx_widestr(arg[1]))
    gui.TextManager:Format_AddParam(util_text("ui_scene_" .. nx_string(nx_int(arg[2]))))
    local text = gui.TextManager:Format_GetText()
    nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(10), text)
    gui.TextManager:Format_SetIDName("ui_xuechou_track")
    gui.TextManager:Format_AddParam(nx_widestr(arg[1]))
    gui.TextManager:Format_AddParam(util_text("ui_scene_" .. nx_string(nx_int(arg[2]))))
    gui.TextManager:Format_AddParam(nx_int(arg[3]))
    local info = gui.TextManager:Format_GetText()
    local res = ShowTipDialog(info, 1)
    if not res then
      return
    end
    res = ShowTipDialog(util_text("ui_xuechou_goto_query"), 0)
    if not res then
      return
    end
    deliver_to_player_pos(nx_int(arg[2]))
  elseif nx_int(2) == nx_int(msg_id) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "show_chouren", true, nx_widestr(arg[1]), nx_int(arg[3]), nx_int(arg[4]), nx_string(arg[2]))
    gui.TextManager:Format_SetIDName("ui_xuechou_track_01")
    gui.TextManager:Format_AddParam(nx_widestr(arg[1]))
    gui.TextManager:Format_AddParam(util_text("ui_scene_" .. nx_string(nx_int(arg[5]))))
    local info = gui.TextManager:Format_GetText()
    nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(10), info)
  elseif nx_int(3) == nx_int(msg_id) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "show_chouren", false, nx_widestr(""), 0, 0, 0)
    gui.TextManager:Format_SetIDName("ui_menu_divine_offline")
    gui.TextManager:Format_AddParam(nx_widestr(arg[1]))
    local info = gui.TextManager:Format_GetText()
    nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(10), info)
  elseif nx_int(4) == nx_int(msg_id) then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "show_chouren", false, nx_widestr(""), 0, 0, 0)
    nx_execute("form_stage_main\\form_single_notice", "ClearText", nx_int(10))
  elseif nx_int(5) == nx_int(msg_id) then
    nx_execute("form_stage_main\\form_single_notice", "NotifyText", nx_int(10), util_text("ui_xuechou_track_fail"))
  end
end
function ShowTipDialog(content, tip_type)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  if nx_int(tip_type) == nx_int(1) then
    dialog.ok_btn.Text = nx_widestr(util_text("ui_xuechou_goto"))
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  dialog:Close()
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function deliver_to_player_pos(scene)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(872), nx_int(1), scene)
end
