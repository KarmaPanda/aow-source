require("util_gui")
require("utils")
require("custom_sender")
require("role_composite")
require("share\\client_custom_define")
require("share\\view_define")
local SCHOOL_BACKGROUND_INFO = {
  school_shaolin = "gui\\loading\\school01.png",
  school_wudang = "gui\\loading\\school02.png",
  school_emei = "gui\\loading\\school03.png",
  school_junzitang = "gui\\loading\\school04.png",
  school_jinyiwei = "gui\\loading\\school05.png",
  school_jilegu = "gui\\loading\\school06.png",
  school_gaibang = "gui\\loading\\school07.png",
  school_tangmen = "gui\\loading\\school08.png",
  school_nil = "gui\\loading\\school08.png"
}
local LeiTai_ZhaoShi_Name_List = {
  "tvt_ltlx_001",
  "tvt_ltlx_002",
  "tvt_ltlx_003",
  "tvt_ltlx_004",
  "tvt_ltlx_005"
}
local UPDATA_SHOW_MODEL_NUM_MAX = 2
local LEITI_BET_INFO_REC = "leiti_bet_info_rec"
function main_form_init(self)
  self.select_npc = nil
  self.show_model_num = 0
  self.wager_limit = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  reset_form_size()
  on_update_leiti_bet_info_rec(self)
  if self.select_npc ~= nil then
    self.wager_limit = self.select_npc:QueryProp("WagerLimit")
    local text_money = format_prize_money(self.wager_limit)
    local counttxt = gui.TextManager:GetFormatText("ui_yazhushangxian") .. nx_widestr(text_money)
    self.lbl_total_moey_info.Text = nx_widestr(counttxt)
  end
  local game_timer = nx_value("timer_game")
  if game_timer then
    game_timer:UnRegister(nx_current(), "on_update_leiti_bet_info_rec", self)
    game_timer:Register(1000, -1, nx_current(), "on_update_leiti_bet_info_rec", self, -1, -1)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddSelObjPropertyBind("Status", "int", self, nx_current(), "check_inject_money")
    databinder:AddSelObjPropertyBind("TotalMoney", "int64", self, nx_current(), "refush_total_money")
  end
end
function on_main_form_close(self)
  local form = self.ParentForm
  clear_model(form)
  local data_binder = nx_value("data_binder")
  if data_binder then
    data_binder:DelSelObjPropertyBind("Status", form)
    data_binder:DelSelObjPropertyBind("TotalMoney", form)
  end
  local game_timer = nx_value("timer_game")
  if game_timer then
    game_timer:UnRegister(nx_current(), "on_update_leiti_bet_info_rec", self)
  end
  nx_destroy(form)
end
function clear_model(form)
  if nx_is_valid(form.scenebox_left_model) then
    if nx_find_custom(form, "Actor1") and nx_is_valid(form.Actor1) then
      form.scenebox_left_model.Scene:Delete(form.Actor1)
    end
    nx_execute("scene", "delete_scene", form.scenebox_left_model.Scene)
  end
  if nx_is_valid(form.scenebox_right_model) then
    if nx_find_custom(form, "Actor2") and nx_is_valid(form.Actor2) then
      form.scenebox_right_model.Scene:Delete(form.Actor2)
    end
    nx_execute("scene", "delete_scene", form.scenebox_right_model.Scene)
  end
  form.show_model_num = 0
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function reset_form_size()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_leitai\\form_leitai_gamble")
  if not nx_is_valid(form) then
    return
  end
  form.Width = gui.Width
  form.Height = gui.Height
  form.Left = 0
  form.Top = 0
end
function on_update_leiti_bet_info_rec(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local left_player_power, Right_player_power
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  form.select_npc = game_client:GetSceneObj(nx_string(self.leitai_wager_npc_id))
  if not nx_is_valid(form.select_npc) then
    return false
  end
  local view = game_client:GetView(nx_string(VIEWPORT_BOCAI_BOX))
  if not nx_is_valid(view) then
    return false
  end
  if not view:FindRecord(LEITI_BET_INFO_REC) then
    form.lbl_red.Visible = false
    form.lbl_blue.Visible = false
    return false
  else
    form.lbl_red.Visible = true
    form.lbl_blue.Visible = true
  end
  local rows = view:GetRecordRows(LEITI_BET_INFO_REC)
  if nx_int(rows) ~= nx_int(2) then
    return false
  end
  for i = 0, rows - 1 do
    local player_name = view:QueryRecord(LEITI_BET_INFO_REC, i, 0)
    local player_school = gui.TextManager:GetText(nx_string(view:QueryRecord(LEITI_BET_INFO_REC, i, 1)))
    if nx_string(player_school) == nil or nx_string(player_school) == "" then
      player_school = gui.TextManager:GetText("ui_task_school_null")
    end
    local player_power = gui.TextManager:GetText("desc_" .. view:QueryRecord(LEITI_BET_INFO_REC, i, 2))
    local leitai_addup_num = view:QueryRecord(LEITI_BET_INFO_REC, i, 3)
    local player_addup_fraction = view:QueryRecord(LEITI_BET_INFO_REC, i, 4)
    local player_odds = view:QueryRecord(LEITI_BET_INFO_REC, i, 5)
    local player_head = view:QueryRecord(LEITI_BET_INFO_REC, i, 6)
    if i == 0 then
      refush_palyer1_info(self, player_name, player_school, player_power, leitai_addup_num, player_addup_fraction, player_odds, player_head)
      left_player_power = string.sub(nx_string(view:QueryRecord(LEITI_BET_INFO_REC, i, 2)), 6, 9)
    else
      refush_palyer2_info(self, player_name, player_school, player_power, leitai_addup_num, player_addup_fraction, player_odds, player_head)
      Right_player_power = string.sub(nx_string(view:QueryRecord(LEITI_BET_INFO_REC, i, 2)), 6, 9)
    end
  end
  if left_player_power ~= nil and Right_player_power ~= nil then
    refush_player_shili_info(self, left_player_power, Right_player_power)
  else
    form.lbl_red.Visible = false
    form.lbl_blue.Visible = false
  end
  return true
end
function get_leitai_gamble_num(self)
  local form = self.ParentForm
  local money_limit = form.wager_limit
  local money_wen = form.ipt_wen.Text
  local money_liang = form.ipt_liang.Text
  local money_ding = form.ipt_ding.Text
  local cur_wager_money = nx_int64(money_wen) + nx_int64(money_liang) * 1000 + nx_int64(money_ding) * 1000 * 1000
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_silver = client_player:QueryProp("CapitalType2")
  if nx_int64(cur_wager_money) <= nx_int64(0) then
    local text_info = gui.TextManager:GetText("82076")
    show_confirm(text_info)
    return 0
  elseif nx_int64(cur_wager_money) > nx_int64(money_limit) then
    local text_info = gui.TextManager:GetText("82078")
    show_confirm(text_info)
    return 0
  elseif nx_number(player_silver) < nx_number(gamble_money) then
    local text_info = gui.TextManager:GetText("82078")
    show_confirm(text_info)
    return 0
  else
    return nx_int64(cur_wager_money)
  end
end
function send_leitai_gamble_msg(self, player_name, npc)
  local gamble_money = get_leitai_gamble_num(self)
  if nx_number(gamble_money) <= nx_number(0) then
    return
  end
  if player_name ~= nil and player_name ~= "" then
    nx_execute("custom_sender", "custom_send_leitai_wager_info", player_name, gamble_money, npc)
  end
end
function on_btn_right_gamble_click(self)
  local form = self.ParentForm
  local playerName = nx_widestr(form.lbl_right_name.Text)
  send_leitai_gamble_msg(self, playerName, form.leitai_wager_npc_id)
  self.Parent:Close()
end
function on_btn_left_gamble_click(self)
  local form = self.ParentForm
  local playerName = nx_widestr(form.lbl_left_name.Text)
  send_leitai_gamble_msg(self, playerName, form.leitai_wager_npc_id)
  self.Parent:Close()
end
function refush_palyer1_info(self, name, school, power, num, fraction, odds, head)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.lbl_left_name.Text = nx_widestr(name)
  self.lbl_left_school.Text = nx_widestr(school)
  self.lbl_left_num.Text = gui.TextManager:GetText("ui_daleishu") .. nx_widestr(":") .. nx_widestr(num)
  self.lbl_left_fraction.Text = gui.TextManager:GetText("ui_JiFen") .. nx_widestr(":") .. nx_widestr(fraction)
  self.lbl_left_odds.Text = gui.TextManager:GetText("ui_peilv") .. nx_widestr(":") .. nx_widestr("1:") .. nx_widestr(odds)
  show_player_model(self, self.scenebox_left_model, name)
end
function refush_palyer2_info(self, name, school, power, num, fraction, odds, head)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.lbl_right_name.Text = nx_widestr(name)
  self.lbl_right_school.Text = nx_widestr(school)
  self.lbl_right_num.Text = gui.TextManager:GetText("ui_daleishu") .. nx_widestr(": ") .. nx_widestr(num)
  self.lbl_right_fraction.Text = gui.TextManager:GetText("ui_JiFen") .. nx_widestr(": ") .. nx_widestr(fraction)
  self.lbl_right_odds.Text = gui.TextManager:GetText("ui_peilv") .. nx_widestr(": ") .. nx_widestr("1:") .. nx_widestr(odds)
  show_player_model(self, self.scenebox_right_model, name)
end
function refush_total_money(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(form.select_npc) then
    return
  end
  local total_money = form.select_npc:QueryProp("TotalMoney")
  local text_money = format_prize_money(total_money)
  local counttxt = gui.TextManager:GetFormatText("ui_zongjinge") .. nx_widestr(text_money)
  self.lbl_all_money.Text = nx_widestr(counttxt)
end
function check_inject_money(self)
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(form.select_npc) then
    return
  end
  local cur_status = form.select_npc:QueryProp("Status")
  if nx_int(cur_status) == nx_int(0) then
    form.btn_left_gamble.Enabled = false
    form.btn_right_gamble.Enabled = false
  else
    form.btn_left_gamble.Enabled = true
    form.btn_right_gamble.Enabled = true
  end
end
function refush_school_background(self, school, leftorright)
  local image_name = SCHOOL_BACKGROUND_INFO[nx_string(school)]
  if nx_string(image_name) == "" or image_name == nil then
    image_name = nx_string(SCHOOL_BACKGROUND_INFO.school_nil)
  end
  if nx_string(leftorright) == "left" then
    self.lbl_background1.BackImage = nx_string(image_name)
  elseif nx_string(leftorright) == "right" then
    self.lbl_background2.BackImage = nx_string(image_name)
  else
    return
  end
end
function show_player_model(self, scenebox_control, player_name)
  if self.show_model_num >= UPDATA_SHOW_MODEL_NUM_MAX then
    return
  end
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  local form = self.ParentForm
  if not nx_is_valid(scenebox_control.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox_control)
  end
  get_player_inview(self, scenebox_control, player_name)
end
function get_player_inview(self, scenebox_control, player_name)
  local form = self.ParentForm
  local game_visual = nx_value("game_visual")
  local game_client = nx_value("game_client")
  form.show_model_num = form.show_model_num + 1
  local game_scene = game_client:GetScene()
  local table_client_obj = game_scene:GetSceneObjList()
  for i = 1, table.maxn(table_client_obj) do
    local client_obj = table_client_obj[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      local obj_type = client_obj:QueryProp("Type")
      if nx_int(obj_type) == nx_int(2) and nx_string(name) == nx_string(player_name) then
        show_model(self, scenebox_control, client_obj)
        return
      end
    end
  end
  clear_model(form)
end
function show_model(self, scenebox_control, client_player)
  local form = self.ParentForm
  scenebox_control.Scene.camera.Fov = math.pi * 0.2
  scenebox_control.Scene.camera:SetPosition(0, 0.9, 3.2)
  scenebox_control.Scene.camera:YawAngle(math.pi)
  if client_player == nil then
    return
  end
  local type = client_player:QueryProp("Type")
  local actor2 = create_scene_obj_composite(scenebox_control.Scene, client_player, false)
  if not nx_is_valid(actor2) then
    return
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", scenebox_control, actor2)
  if nx_int(form.show_model_num) == nx_int(1) then
    form.Actor1 = actor2
  else
    form.Actor2 = actor2
  end
  local action_module = nx_value("action_module")
  action_module:ActionInit(actor2)
  action_module:BlendAction(actor2, "stand", true, true)
  local skill_effect = nx_value("skill_effect")
  if nx_is_valid(skill_effect) then
    local random_zhaoshi_name = get_random_zhaoshi_name()
    skill_effect:BeginShowZhaoshi(actor2, nx_string(random_zhaoshi_name))
  end
end
function get_random_zhaoshi_name()
  local zhaoshi_num = table.getn(LeiTai_ZhaoShi_Name_List)
  local random_index = math.random(zhaoshi_num)
  return nx_string(LeiTai_ZhaoShi_Name_List[random_index])
end
function refush_player_shili_info(self, left_palyer_shili, right_palyer_shili)
  local balance_num = (nx_int(left_palyer_shili) + nx_int(right_palyer_shili)) / nx_int(left_palyer_shili)
  local value_num = nx_int(100) / nx_int(balance_num)
  if nx_float(value_num) > nx_float(80) then
    value_num = nx_float(80)
  elseif nx_float(value_num) < nx_float(20) then
    value_num = nx_float(20)
  end
  self.pbar_shili_contrast.Value = nx_float(value_num)
  refush_control_pos(self, nx_float(value_num))
end
function refush_control_pos(self, value)
  local form = self.ParentForm
  local control_width = form.pbar_shili_contrast.Width
  local control_top = form.pbar_shili_contrast.Top
  form.lbl_red.Left = nx_float(form.pbar_shili_contrast.Left + value / 100 * control_width - form.lbl_red.Width) + 4
  form.lbl_red.Top = nx_float(control_top) - 4
  form.lbl_blue.Left = nx_float(form.lbl_red.Left) + form.lbl_blue.Width - 4
  form.lbl_blue.Top = form.lbl_red.Top
end
function format_prize_money(money)
  money = nx_number(money)
  local ding = nx_int64(money / 1000000)
  local temp = nx_int64(money - ding * 1000000)
  local liang = nx_int64(temp / 1000)
  local wen = nx_int64(temp - liang * 1000)
  local money_text = ""
  if nx_number(ding) > 0 then
    money_text = nx_widestr(ding) .. nx_widestr(util_text("ui_ding"))
  end
  if nx_number(liang) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(liang) .. nx_widestr(util_text("ui_liang"))
  end
  if nx_number(wen) > 0 then
    money_text = nx_widestr(money_text) .. nx_widestr(wen) .. nx_widestr(util_text("ui_wen"))
  end
  if nx_string(money_text) == "" then
    money_text = nx_widestr("0") .. util_text("ui_wen")
  end
  return money_text
end
