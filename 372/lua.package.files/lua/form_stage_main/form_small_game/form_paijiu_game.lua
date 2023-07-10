require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
local inmage_backgroud = "gui\\mainform\\smallgame\\paijiuganme\\paijiu_0.png"
local inmage_path = "gui\\mainform\\smallgame\\paijiuganme\\"
local CLIENT_SUBMSG_PAIIJIU_START = 0
local CLIENT_SUBMSG_PAIIJIU_LOOK = 1
local CLIENT_SUBMSG_PAIIJIU_RESTART = 2
local CLIENT_SUBMSG_PAIIJIU_LUCK = 3
local CLIENT_SUBMSG_PAIIJIU_OPEN = 4
local CLIENT_SUBMSG_PAIIJIU_QUIT = 5
local WIN_SYSTEM = 0
local WIN_PLAYER = 1
local max_pai_indx = 32
local max_pai_number = 12
function main_form_init(form)
  form.Fixed = false
  form.cur_gamble_money = 0
  form.player_win = 0
  form.win_ratio = 0
  form.duju = 0
  form.who_big = 0
  form.system_money = 0
  form.init_money = 0
end
function cur_gamble_money(money)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  form.cur_gamble_money = money
  form.system_money = money * 1000
  form.init_money = form.system_money
  form.lbl_money_num.Text = nx_widestr(money)
  form.lbl_system_money.Text = nx_widestr(form.system_money)
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  show_pai(form, 0, 0, 0, 0)
  form.mltbox_game_message:Clear()
  local message = format_info("ui_paijiu_message_1")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  send_quit_game()
  btn.ParentForm:Close()
end
function on_end_game(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_START))
end
function on_recv_player_pai(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 4 then
    return
  end
  local PaiIndex1 = arg[1]
  local PaiIndex2 = arg[2]
  local palyer_order = arg[3]
  local palyer_lossratio = arg[4]
  show_pai(form, 0, 0, PaiIndex1, PaiIndex2)
  local message = format_info("ui_jiupai_duipai_" .. nx_string(palyer_order), nx_int(palyer_lossratio))
  form.lbl_player_text.HtmlText = nx_widestr(message)
  form.lbl_npc_text.HtmlText = nx_widestr("")
  message = format_info("ui_paijiu_message_3")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
  message = format_info("ui_paijiu_message_4")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function on_btn_look_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_LOOK))
end
function on_recv_sys_pai(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 8 then
    return
  end
  local SysPaiIndex1 = arg[1]
  local SysPaiIndex2 = arg[2]
  local sys_order = arg[3]
  local sys_lossratio = arg[4]
  local PlayerPaiIndex1 = arg[5]
  local PlayerPaiIndex2 = arg[6]
  local palyer_order = arg[7]
  local palyer_lossratio = arg[8]
  show_pai(form, SysPaiIndex1, SysPaiIndex2, PlayerPaiIndex1, PlayerPaiIndex2)
  form.lbl_npc_text.HtmlText = format_info("ui_jiupai_duipai_" .. nx_string(sys_order), nx_int(sys_lossratio))
  form.lbl_player_text.HtmlText = format_info("ui_jiupai_duipai_" .. nx_string(palyer_order), nx_int(palyer_lossratio))
  local message = format_info("ui_paijiu_message_5")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function on_btn_restart_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_RESTART))
end
function on_recv_restart(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 4 then
    return
  end
  local PaiIndex1 = arg[1]
  local PaiIndex2 = arg[2]
  local palyer_order = arg[3]
  local palyer_lossratio = arg[4]
  show_pai(form, 0, 0, PaiIndex1, PaiIndex2)
  local message = format_info("ui_jiupai_duipai_" .. nx_string(palyer_order), nx_int(palyer_lossratio))
  form.lbl_player_text.HtmlText = nx_widestr(message)
  form.lbl_npc_text.HtmlText = nx_widestr("")
  local message = format_info("ui_paijiu_message_6", nx_int(win_number))
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
  message = format_info("ui_paijiu_message_3", nx_int(win_number))
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
  message = format_info("ui_paijiu_message_4", nx_int(win_number))
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function on_btn_luck_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_LUCK))
end
function on_recv_player_luck(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  show_pai(form, 0, 0, 0, 0)
  form.lbl_npc_text.HtmlText = nx_widestr("")
  form.lbl_player_text.HtmlText = nx_widestr("")
  local message = format_info("ui_paijiu_message_2")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function on_btn_open_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local xiazhu_number = nx_int(form.txt_xiazhu_number.Text)
  local form_main_sysinfo = nx_value("form_main_sysinfo")
  if nx_int(xiazhu_number) <= nx_int(0) then
    if nx_is_valid(form_main_sysinfo) then
      form_main_sysinfo:AddSystemInfo(util_text("paijiugame_error6"), 0, 0)
    end
    return 0
  end
  if not show_confirm_info("ui_paijiu_message_10") then
    return 0
  end
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_OPEN), nx_int(form.txt_xiazhu_number.Text))
end
function on_recv_win_result(...)
  local form = nx_value("form_stage_main\\form_small_game\\form_paijiu_game")
  if not nx_is_valid(form) then
    return
  end
  local count = #arg
  if count < 11 then
    return
  end
  local SysPaiIndex1 = arg[1]
  local SysPaiIndex2 = arg[2]
  local sys_order = arg[3]
  local sys_lossratio = arg[4]
  local PlayerPaiIndex1 = arg[5]
  local PlayerPaiIndex2 = arg[6]
  local palyer_order = arg[7]
  local palyer_lossratio = arg[8]
  local win_result = arg[9]
  local win_number = arg[10]
  local cur_money = arg[11]
  show_pai(form, SysPaiIndex1, SysPaiIndex2, PlayerPaiIndex1, PlayerPaiIndex2)
  form.lbl_money_num.Text = nx_widestr(cur_money)
  form.lbl_npc_text.HtmlText = format_info("ui_jiupai_duipai_" .. nx_string(sys_order), nx_int(sys_lossratio))
  form.lbl_player_text.HtmlText = format_info("ui_jiupai_duipai_" .. nx_string(palyer_order), nx_int(palyer_lossratio))
  if nx_int(win_number) <= nx_int(0) then
    win_number = win_number * -1
  end
  if nx_int(win_result) == nx_int(WIN_PLAYER) then
    local message = format_info("ui_paijiu_message_9", nx_int(win_number))
    form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
    form.lbl_who_big.Text = format_info("ui_paijiu_big_player")
    form.system_money = nx_int(form.system_money) - nx_int(win_number)
    if nx_int(form.system_money) <= nx_int(0) then
      form.system_money = form.init_money
    end
    form.player_win = nx_int(form.player_win) + nx_int(1)
  else
    local message = format_info("ui_paijiu_message_8", nx_int(win_number))
    form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
    form.lbl_who_big.Text = format_info("ui_paijiu_big_system")
    form.system_money = nx_int(form.system_money) + nx_int(win_number)
  end
  form.duju = nx_int(form.duju) + nx_int(1)
  form.win_radio = nx_int(form.player_win) / nx_int(form.duju) * nx_int(100)
  form.lbl_duju.Text = nx_widestr(form.duju)
  form.lbl_win_radio.Text = nx_widestr(nx_int(form.win_radio)) .. nx_widestr("%")
  form.lbl_system_money.Text = nx_widestr(form.system_money)
  message = format_info("ui_paijiu_message_1")
  form.mltbox_game_message:AddHtmlText(nx_widestr(message) .. nx_widestr("<br>"), -1)
end
function send_quit_game()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GAME_PAIJIU), nx_int(CLIENT_SUBMSG_PAIIJIU_QUIT))
end
function show_pai(form, SysPaiIndex1, SysPaiIndex2, PlayerPaiIndex1, PlayerPaiIndex2)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_npc_card1.BackImage = nx_resource_path() .. inmage_path .. "paijiu_" .. nx_string(SysPaiIndex1) .. ".png"
  form.lbl_npc_card2.BackImage = nx_resource_path() .. inmage_path .. "paijiu_" .. nx_string(SysPaiIndex2) .. ".png"
  form.lbl_player_card1.BackImage = nx_resource_path() .. inmage_path .. "paijiu_" .. nx_string(PlayerPaiIndex1) .. ".png"
  form.lbl_player_card2.BackImage = nx_resource_path() .. inmage_path .. "paijiu_" .. nx_string(PlayerPaiIndex2) .. ".png"
end
function show_confirm_info(tip, ...)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if nx_is_valid(dialog) then
    dialog.mltbox_info.HtmlText = nx_widestr(format_info(tip, unpack(arg)))
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return false
    end
  end
  return true
end
function format_info(strid, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return strid
  end
  gui.TextManager:Format_SetIDName(strid)
  for i, v in ipairs(arg) do
    gui.TextManager:Format_AddParam(v)
  end
  return gui.TextManager:Format_GetText()
end
function on_cbtn1_checked_changed(CheckButton)
  local form = CheckButton.ParentForm
  if form.cbtn_1.Checked == true then
    form.groupbox_paijiu.Visible = true
    form.groupbox_brief.Visible = false
  end
end
function on_cbtn2_checked_changed(CheckButton)
  local form = CheckButton.ParentForm
  if form.cbtn_2.Checked == true then
    form.groupbox_paijiu.Visible = false
    form.groupbox_brief.Visible = true
  end
end
function on_cbtn_3_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == true then
    form.groupscrollbox_1.Visible = true
    form.groupscrollbox_2.Visible = false
    form.groupscrollbox_3.Visible = false
  end
end
function on_cbtn_4_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == true then
    form.groupscrollbox_1.Visible = false
    form.groupscrollbox_2.Visible = true
    form.groupscrollbox_3.Visible = false
  end
end
function on_cbtn_5_checked_changed(self)
  local form = self.ParentForm
  if self.Checked == true then
    form.groupscrollbox_1.Visible = false
    form.groupscrollbox_2.Visible = false
    form.groupscrollbox_3.Visible = true
  end
end
