require("util_gui")
require("util_functions")
require("share\\client_custom_define")
local g_form_name = "form_stage_main\\form_clone\\form_clone_main"
local SUB_FORM = {
  Tuijian = "form_stage_main\\form_clone\\form_clone_info",
  Ziliao = "form_stage_main\\form_clone\\form_clone_describe",
  Shashou = "form_stage_main\\form_clone\\form_clone_killer",
  Tuandui = "form_stage_main\\form_clone\\form_clone_team",
  TongTianFeng = "form_stage_main\\form_skyhill\\form_ttf_template",
  ChengJiu = "form_stage_main\\form_skyhill\\form_clone_skyhill_achievement",
  SanHill = "form_stage_main\\form_skyhill\\form_sanhill",
  SanHillExchange = "form_stage_main\\form_skyhill\\form_sanhill_exchange",
  SanHillRank = "form_stage_main\\form_skyhill\\form_sanhill_rank"
}
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2 - 120
  form.Top = (gui.Height - form.Height) / 2
  form.rbtn_1.cloneclass = "Tuijian"
  form.rbtn_4.cloneclass = "Shashou"
  form.rbtn_7.cloneclass = "Tuijian"
  form.rbtn_8.cloneclass = "TongTianFeng"
  form.rbtn_10.cloneclass = "TongTianFeng"
  form.rbtn_11.cloneclass = "ChengJiu"
  form.rbtn_12.cloneclass = "SanHill"
  form.rbtn_13.cloneclass = "SanHill"
  form.rbtn_14.cloneclass = "SanHillExchange"
  form.rbtn_15.cloneclass = "SanHillRank"
  for key, value in pairs(SUB_FORM) do
    local sub_form = util_get_form(value, true, false)
    if nx_is_valid(sub_form) then
      if form:Add(sub_form) then
        sub_form.Visible = false
        sub_form.Fixed = true
        sub_form.Top = 65
        sub_form.Left = 109
      end
      nx_set_custom(form, nx_string(key), sub_form)
    end
  end
  nx_set_custom(form, "cloneclass", "Tuijian")
  form.rbtn_1.Checked = true
  form.rbtn_7.Checked = true
  form.rbtn_10.Visible = false
  form.rbtn_11.Visible = false
  form.btn_1.Visible = false
  form.btn_2.Visible = false
  form.rbtn_4.Visible = true
  local sub_form = nx_value(SUB_FORM.Tuijian)
  nx_set_custom(form, "btn_Reset", sub_form.btn_Reset)
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local b_ok_1 = condition_manager:CanSatisfyCondition(player, player, 29723)
  if not b_ok_1 then
    form.rbtn_12.Enabled = false
  else
    form.rbtn_12.Enabled = true
  end
  sanhill_ani_logic(form)
  local b_ok = condition_manager:CanSatisfyCondition(player, player, 28571)
  if not b_ok then
    local text_id = condition_manager:GetConditionDesc(nx_int(condition))
    form.rbtn_8.Enabled = false
    return
  end
  local ST_TONG_TIAN_FENG = 608
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_TONG_TIAN_FENG) then
    form.rbtn_8.Enabled = false
    return
  else
    form.rbtn_8.Enabled = true
  end
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  for key, value in pairs(SUB_FORM) do
    if nx_find_custom(form, nx_string(key)) then
      local sub_form = nx_custom(form, nx_string(key))
      if nx_is_valid(sub_form) then
        sub_form:Close()
      end
    end
  end
  nx_destroy(form)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_close_click(btn)
  util_show_form(g_form_name, false)
  local drop_form = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  if nx_is_valid(drop_form) then
    drop_form.gpsb_items:DeleteAll()
    drop_form:Close()
  end
  local reset_form = nx_value("form_stage_main\\form_clone\\form_clone_guide")
  if nx_is_valid(reset_form) then
    reset_form:Close()
  end
end
function on_clonetype_changed(rbtn)
  if not rbtn.Checked then
    return 0
  end
  local form = rbtn.ParentForm
  form.cloneclass = rbtn.cloneclass
  if rbtn.cloneclass == "TongTianFeng" or rbtn.cloneclass == "ChengJiu" then
    form.rbtn_10.Visible = true
    form.rbtn_11.Visible = true
    form.rbtn_1.Visible = false
    form.rbtn_4.Visible = false
    form.rbtn_13.Visible = false
    form.rbtn_14.Visible = false
    form.rbtn_15.Visible = false
    form.rbtn_10.Checked = true
  elseif rbtn.cloneclass == "SanHill" or rbtn.cloneclass == "SanHillExchange" or rbtn.cloneclass == "SanHillRank" then
    form.rbtn_10.Visible = false
    form.rbtn_11.Visible = false
    form.rbtn_1.Visible = false
    form.rbtn_4.Visible = false
    form.rbtn_13.Visible = true
    form.rbtn_14.Visible = true
    form.rbtn_15.Visible = true
    form.rbtn_13.Checked = true
    if form.ani_sanhill.Visible == true then
      form.ani_sanhill.Visible = false
      nx_execute("custom_sender", "custom_sanhill_msg", 15)
    end
  else
    form.rbtn_10.Visible = false
    form.rbtn_11.Visible = false
    form.rbtn_1.Visible = true
    form.rbtn_4.Visible = true
    form.rbtn_13.Visible = false
    form.rbtn_14.Visible = false
    form.rbtn_15.Visible = false
  end
  if rbtn.cloneclass == "Shashou" then
    form.btn_1.Visible = true
    form.btn_2.Visible = true
  else
    form.btn_1.Visible = false
    form.btn_2.Visible = false
  end
  if nx_find_custom(form, "cur_form") and nx_is_valid(form.cur_form) then
    form.cur_form.Visible = false
  end
  if not nx_find_custom(form, nx_string(rbtn.cloneclass)) then
    return 0
  end
  local sub_form = nx_custom(form, nx_string(rbtn.cloneclass))
  if not nx_is_valid(sub_form) then
    return 0
  end
  sub_form.Visible = true
  form.cur_form = sub_form
  close_child_form()
end
function close_child_form()
  local reset_form = nx_value("form_stage_main\\form_clone\\form_clone_guide")
  if nx_is_valid(reset_form) then
    reset_form:Close()
  end
  local drop_form = nx_value("form_stage_main\\form_clone\\form_clone_drop")
  if nx_is_valid(drop_form) then
    drop_form.gpsb_items:DeleteAll()
    drop_form:Close()
  end
end
function show_type_info(child_type)
  util_show_form(g_form_name, true)
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(101) == nx_int(child_type) then
    form.rbtn_1.Checked = true
    return
  elseif nx_int(102) == nx_int(child_type) then
    return
  elseif nx_int(103) == nx_int(child_type) then
    form.rbtn_3.Checked = true
    return
  elseif nx_int(104) == nx_int(child_type) then
    form.rbtn_4.Checked = true
    return
  end
end
function open_form()
  local form_clone_main = nx_value(g_form_name)
  if nx_is_valid(form_clone_main) then
    if form_clone_main.Visible == true then
      util_show_form(g_form_name, false)
    else
      util_show_form(g_form_name, true)
    end
  else
    util_show_form(g_form_name, true)
    local form = nx_value(g_form_name)
    nx_execute("util_gui", "ui_show_attached_form", form)
  end
end
function close_form()
  local form_clone_main = nx_value(g_form_name)
  if nx_is_valid(form_clone_main) then
    on_btn_close_click(form_clone_main.btn_close)
  end
end
function on_btn_killer_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_APPLY_BOSS_HELPER))
end
function cancel_apply_killer()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CANCEL_BOSS_HELPER))
end
function on_btn_killer_score_click(btn)
  local form = util_get_form("form_stage_main\\form_rank\\form_rank_main", true, true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
    form:Close()
    return
  else
    form.Visible = true
    form:Show()
  end
  nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", form, "rank_6_killer")
end
function goto_tongtianfeng()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    return
  end
  form.rbtn_8.Checked = true
  on_clonetype_changed(form.rbtn_8)
end
function goto_shashou()
  local form = nx_value(g_form_name)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == false then
    return
  end
  form.rbtn_4.Checked = true
  on_clonetype_changed(form.rbtn_4)
end
function sanhill_ani_logic(form)
  form.ani_sanhill.Visible = false
  if form.rbtn_12.Enabled == false then
    return
  end
  local client = nx_value("game_client")
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local isneed = player:QueryProp("SanHillIsNeedLead")
  if nx_int(isneed) > nx_int(0) then
    return
  end
  form.ani_sanhill.Visible = true
end
