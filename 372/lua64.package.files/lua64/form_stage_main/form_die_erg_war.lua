require("util_functions")
require("form_stage_main\\form_die_util")
local TYPE_RELIVE_FRONT = 0
local TYPE_RELIVE_MAIN = 1
local OUTLAND_WAR_ZHONGYUAN = 2300
local OUTLAND_WAR_WAIYU = 2301
local FORM_PATH = "form_stage_main\\form_die_erg_war"
function main_form_init(form)
  form.Fixed = false
  form.no_need_motion_alpha = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.lbl_revert.Text = nx_widestr(nx_int(60))
  local timer = nx_value(GAME_TIMER)
  timer:Register(1000, -1, nx_current(), "on_update_form_time", form.lbl_revert, -1, -1)
  form.select_relive_index = 0
  form.relive_1.camp_id = 0
  form.relive_2.camp_id = 0
  form.relive_3.camp_id = 0
  form.relive_4.camp_id = 0
  form.player_camp = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND_WAR), nx_int(3))
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_form_time", form)
  nx_destroy(form)
end
function on_update_form_time(form)
  if nx_int(form.Text) == nx_int(0) then
    close_form()
    return
  end
  form.Text = nx_widestr(nx_int(form.Text) - 1)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_PATH, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_return_near_location_click(btn)
  local form = btn.ParentForm
  if form.select_relive_index == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "83038")
    return 0
  end
  nx_execute(nx_current(), "custom_outlandwar_relive", RELIVE_TYPE_OUTLAND_WAR, nx_int(0), nx_int(form.select_relive_index))
end
function show_ok_dialog(form, relive_type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return ""
  end
  local gui = nx_value("gui")
  local dialog = util_get_form("form_stage_main\\form_relive_ok", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local str = get_confirm_info(relive_type, nx_int(0))
  if nx_int(relive_type) == nx_int(RELIVE_TYPE_SPECIAL) then
    relive_type = RELIVE_TYPE_NEAR
  end
  dialog.mltbox_info:Clear()
  dialog.mltbox_info:AddHtmlText(nx_widestr(str), -1)
  local capital_type, capital_num = get_confirm_menoy(relive_type)
  if capital_type == nil or capital_num == nil then
    dialog.mltbox_money_info.Text = ""
  elseif nx_int(capital_type) == nx_int(CAPITAL_TYPE_SILVER) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_suiyin", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  elseif nx_int(capital_type) == nx_int(CAPITAL_TYPE_SILVER_CARD) then
    local money = convert_money(nx_number(capital_num))
    local money_info = gui.TextManager:GetFormatText("ui_fuhuo_yb", money)
    dialog.mltbox_money_info:AddHtmlText(nx_widestr(money_info), -1)
  end
  if relive_type == RELIVE_TYPE_LOCAL or relive_type == RELIVE_TYPE_LOCAL_STRONG then
    local relive_count = player:QueryProp("ReliveCount")
    dialog.lbl_remain_count.Text = nx_widestr(gui.TextManager:GetFormatText("ui_fuhuo_already", nx_int(relive_count)))
  else
    dialog.lbl_remain_count.Visible = false
  end
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    local safe_mode = 0
    nx_execute("custom_sender", "custom_relive", relive_type, safe_mode)
  end
end
function show_relive_point(...)
  local form = util_get_form(FORM_PATH, true)
  if not nx_is_valid(form) then
    return
  end
  local tower_born_camp = 0
  local tower_current_camp = 0
  local tower_born_type = 0
  local is_in_attack = 0
  form.player_camp = nx_int(arg[1])
  for i = 1, 4 do
    tower_current_camp = nx_int(arg[i * 4 - 2])
    tower_born_camp = nx_int(arg[i * 4 - 1])
    tower_born_type = nx_int(arg[i * 4])
    is_in_attack = nx_int(arg[i * 4 + 1])
    set_relive_state(form.player_camp, tower_current_camp, tower_born_camp, tower_born_type, form, is_in_attack)
  end
end
function set_relive_state(player_camp, current_camp, born_camp, born_type, form, is_in_attack)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(born_camp) == nx_int(OUTLAND_WAR_WAIYU) then
    if nx_int(born_type) == nx_int(TYPE_RELIVE_MAIN) then
      if nx_int(player_camp) == nx_int(current_camp) then
        form.relive_1.Enabled = true
      else
        form.relive_1.Enabled = false
      end
      if nx_int(is_in_attack) == nx_int(1) then
        form.relive_1.Enabled = false
      end
    elseif nx_int(born_type) == nx_int(TYPE_RELIVE_FRONT) then
      if nx_int(player_camp) == nx_int(current_camp) then
        form.relive_2.Enabled = true
      else
        form.relive_2.Enabled = false
      end
      if nx_int(is_in_attack) == nx_int(1) then
        form.relive_2.Enabled = false
      end
    end
  elseif nx_int(born_type) == nx_int(TYPE_RELIVE_FRONT) then
    if nx_int(player_camp) == nx_int(current_camp) then
      form.relive_3.Enabled = true
    else
      form.relive_3.Enabled = false
    end
    if nx_int(is_in_attack) == nx_int(1) then
      form.relive_3.Enabled = false
    end
  elseif nx_int(born_type) == nx_int(TYPE_RELIVE_MAIN) then
    if nx_int(player_camp) == nx_int(current_camp) then
      form.relive_4.Enabled = true
    else
      form.relive_4.Enabled = false
    end
    if nx_int(is_in_attack) == nx_int(1) then
      form.relive_4.Enabled = false
    end
  end
end
function on_relive1_click(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.select_relive_index = 1
  end
end
function on_relive2_click(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.select_relive_index = 2
  end
end
function on_relive3_click(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.select_relive_index = 3
  end
end
function on_relive4_click(rbtn)
  if rbtn.Checked then
    local form = rbtn.ParentForm
    if not nx_is_valid(form) then
      return
    end
    form.select_relive_index = 4
  end
end
function custom_outlandwar_relive(relive_type, check, value)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RELIVE), relive_type, check, value)
end
