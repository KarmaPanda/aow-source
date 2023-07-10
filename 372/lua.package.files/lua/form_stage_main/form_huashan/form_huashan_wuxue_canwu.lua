require("util_gui")
require("util_vip")
require("util_functions")
require("share\\view_define")
require("define\\request_type")
require("define\\object_type_define")
require("util_role_prop")
local FORM_WUXUE_CANWU = "form_stage_main\\form_huashan\\form_huashan_wuxue_canwu"
local SUB_WUXUE_CANWU_INFO = 1
local SUB_WUXUE_CANWU_CANWU = 2
local HuaShanCToS_CANWU = 15
local HuaShanCToS_CanWuQuit = 17
local CANWU_STATE_NORMAL = 1
local CANWU_STATE_BAOJI = 2
local CANWU_STATE_FAILE = 3
local CANWU_STATE_LEVELUP = 4
local EFFECT_CANWU_STATE_NORMAL = "npm_xjz_shuayou_tips"
local EFFECT_CANWU_STATE_BAOJI = "npm_xjz_zuoliao_tips"
local EFFECT_CANWU_STATE_FAILE = "npm_xjz_jianhuo_tips"
local EFFECT_CANWU_STATE_LEVELUP = "npm_xjz_jiahuo_tips"
local CANWU_NEIGONG_TAOLU_ID = 2
local CANWU_WAIGONG_TAOLU_ID = 1
local CANWU_MAX_LEVEL = 12
function main_form_init(self)
  self.Fixed = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = gui.Height - self.Height
end
function on_main_form_open(self)
  on_hide_other_form()
  self.Visible = true
  self.rbtn_taolu_1.Checked = true
  self.taolu = CANWU_WAIGONG_TAOLU_ID
  self.canwu_level = 1
  self.groupbox_1.Visible = false
end
function on_main_form_close(self)
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_CanWuQuit)
  on_show_hided_form()
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function close_form()
  local form = nx_value(FORM_WUXUE_CANWU)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function change_form_size()
  local form = nx_value(FORM_WUXUE_CANWU)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = gui.Height - form.Height
end
function on_hide_other_form()
  util_show_form("form_stage_main\\form_relationship", false)
  local form_game = util_get_form("form_stage_main\\puzzle_quest\\form_puzzle_quest", false)
  if nx_is_valid(form_game) then
    nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "show_world_alpha_out")
    form_game:Close()
  end
  nx_execute("form_stage_main\\form_main\\form_main", "move_over")
  nx_execute("gui", "gui_close_allsystem_form", 2)
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) then
    form_main.groupbox_4.Visible = false
    form_main.groupbox_5.Visible = false
    form_main.groupbox_update.Visible = false
  end
end
function on_show_hided_form()
  nx_execute("gui", "gui_open_closedsystem_form")
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    local bIsNewJHModule = is_newjhmodule()
    if not bIsNewJHModule then
      form_main.groupbox_4.Visible = true
      form_main.groupbox_5.Visible = true
      if nx_is_valid(form_main.groupbox_update) then
        form_main.groupbox_update.Visible = true
      end
    end
  end
end
function open_form()
  local form = util_auto_show_hide_form(FORM_WUXUE_CANWU)
  if not nx_is_valid(form) then
    return
  end
  init_form_info(form)
end
function init_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local canwu_manager = nx_value("WuXueCanWuManager")
  if not nx_is_valid(canwu_manager) then
    return
  end
  local table_taolu_name = canwu_manager:GetCanWuTaoLuName(nx_int(form.taolu))
  if table.getn(table_taolu_name) <= 0 then
    return
  end
  local taolu_query = wuxue_query:GetLearnID_Skill(nx_string(table_taolu_name[1]))
  local max_learned_level = 0
  local max_level = canwu_manager:GetCanWuMaxLevel(nx_int(form.taolu))
  if nx_is_valid(taolu_query) then
    max_learned_level = taolu_query:QueryProp("MaxLevel")
  end
  if nx_int(max_level) > nx_int(CANWU_MAX_LEVEL) then
    max_level = CANWU_MAX_LEVEL
  end
  if nx_int(max_learned_level) > nx_int(max_level) then
    max_learned_level = max_level
  end
  form.canwu_level = max_learned_level + 1
  local special_level = canwu_manager:GetCanWuSpecialLevel(nx_int(form.taolu))
  if nx_int(special_level) > nx_int(max_level) then
    special_level = max_level
  end
  on_show_level_lbl(form, max_learned_level, special_level, max_level)
  local canwu_value = canwu_manager:GetCanWuValue(nx_int(form.taolu))
  local max_canwu_value = canwu_manager:GetMaxCanWuValue(nx_int(form.taolu), nx_int(form.canwu_level))
  if nx_int(max_learned_level) >= nx_int(max_level) then
    form.btn_buy.Enabled = false
    form.pbar_canwu_value.Value = 0
  else
    form.btn_buy.Enabled = true
    form.pbar_canwu_value.Maximum = max_canwu_value
    form.pbar_canwu_value.Value = canwu_value
  end
end
function on_show_level_lbl(form, max_learned_level, special_level, max_level)
  local canwu_manager = nx_value("WuXueCanWuManager")
  if not nx_is_valid(canwu_manager) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  local groupbox_star = form.groupbox_star
  if not nx_is_valid(groupbox_star) then
    return
  end
  if nx_int(max_learned_level) > nx_int(0) then
    for i = nx_number(1), nx_number(max_learned_level) do
      on_show_level_image(groupbox_star, i, true, false, true)
    end
  end
  local is_special = false
  local is_can = false
  if nx_int(form.canwu_level) <= nx_int(max_level) then
    for i = nx_number(form.canwu_level), nx_number(max_level) do
      is_can = canwu_manager:IsCanSatisfyCondition(nx_int(form.taolu), nx_int(i))
      if nx_int(i) >= nx_int(special_level) then
        is_special = true
      end
      on_show_level_image(groupbox_star, i, false, is_special, is_can)
    end
  end
end
function on_show_level_image(groupbox_star, index, is_learn, is_special, is_can)
  if not nx_is_valid(groupbox_star) then
    return
  end
  local lbl_name = "lbl_level_" .. nx_string(index)
  local lbl_level = groupbox_star:Find(lbl_name)
  if not nx_is_valid(lbl_level) then
    return
  end
  if is_learn then
    lbl_level.BackImage = "gui\\special\\huashan\\xlsbz\\" .. nx_string(index) .. "_on.png"
  elseif is_special then
    if is_can then
      lbl_level.BackImage = "gui\\special\\huashan\\xlsbz\\" .. nx_string(index) .. "_out.png"
    else
      lbl_level.BackImage = "gui\\special\\huashan\\xlsbz\\" .. nx_string(index) .. "_down.png"
    end
  elseif is_can then
    lbl_level.BackImage = "gui\\special\\huashan\\xlsbz\\" .. nx_string(index) .. "_out.png"
  else
    lbl_level.BackImage = "gui\\special\\huashan\\xlsbz\\" .. nx_string(index) .. "_down.png"
  end
end
function on_clear_level_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local groupbox_star = form.groupbox_star
  if not nx_is_valid(groupbox_star) then
    return
  end
  for i = nx_number(1), nx_number(CANWU_MAX_LEVEL) do
    local lbl_name = "lbl_level_" .. nx_string(i)
    local lbl_level = groupbox_star:Find(lbl_name)
    if nx_is_valid(lbl_level) then
      lbl_level.BackImage = ""
    end
  end
end
function on_wuxue_canwu_result(...)
  local form = nx_value(FORM_WUXUE_CANWU)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  local actor2 = game_visual:GetPlayer()
  if not nx_is_valid(actor2) then
    return
  end
  local canwu_manager = nx_value("WuXueCanWuManager")
  if not nx_is_valid(canwu_manager) then
    return
  end
  local size = table.getn(arg)
  if nx_int(size) <= nx_int(0) then
    return
  end
  local canwu_state = arg[2]
  local play_zhaoshi_id = arg[3]
  show_skill_action(actor2, play_zhaoshi_id)
  local canwu_value = canwu_manager:GetCanWuValue(nx_int(form.taolu))
  form.pbar_canwu_value.Value = canwu_value
  if nx_int(canwu_state) == nx_int(CANWU_STATE_NORMAL) then
    play_canwu_ani(EFFECT_CANWU_STATE_NORMAL)
  end
  if nx_int(canwu_state) == nx_int(CANWU_STATE_BAOJI) then
    play_canwu_ani(EFFECT_CANWU_STATE_BAOJI)
  end
  if nx_int(canwu_state) == nx_int(CANWU_STATE_FAILE) then
    play_canwu_ani(EFFECT_CANWU_STATE_FAILE)
  end
  if nx_int(canwu_state) == nx_int(CANWU_STATE_LEVELUP) then
    play_canwu_ani(EFFECT_CANWU_STATE_LEVELUP)
    init_form_info(form)
  end
end
function on_canwu_scene_zhaoshi_action(...)
  local game_visual = nx_value("game_visual")
  local actor2 = game_visual:GetPlayer()
  if not nx_is_valid(actor2) then
    return
  end
  local canwu_manager = nx_value("WuXueCanWuManager")
  if not nx_is_valid(canwu_manager) then
    return
  end
  local size = table.getn(arg)
  if nx_int(size) <= nx_int(0) then
    return
  end
  local canwu_player = arg[2]
  local play_zhaoshi_id = arg[3]
  local actor = canwu_manager:GetCanWuZhaoShiPlayer(canwu_player)
  if not nx_is_valid(actor) then
    return
  end
  if nx_id_equal(actor2, actor) then
    return
  end
  show_skill_action(actor, play_zhaoshi_id)
end
function on_btn_can_wu_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local canwu_manager = nx_value("WuXueCanWuManager")
  if not nx_is_valid(canwu_manager) then
    return
  end
  if nx_int(form.taolu) ~= nx_int(CANWU_WAIGONG_TAOLU_ID) and nx_int(form.taolu) ~= nx_int(CANWU_NEIGONG_TAOLU_ID) then
    self_systemcenterinfo("sys_xlsbz_taolu_failed")
    return
  end
  local canwu_cost = canwu_manager:GetCanWuCost(nx_int(form.taolu), nx_int(form.canwu_level))
  if not ShowTipDialog(nx_widestr(util_text("xlsbz_warning")), canwu_cost) then
    return
  end
  nx_execute("custom_sender", "custom_request_huashan", HuaShanCToS_CANWU, nx_int(form.taolu))
end
function on_rbtn_taolu_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.taolu = CANWU_WAIGONG_TAOLU_ID
  on_clear_level_lbl(form)
  init_form_info(form)
end
function on_rbtn_taolu_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.taolu = CANWU_NEIGONG_TAOLU_ID
  on_clear_level_lbl(form)
  init_form_info(form)
end
function play_canwu_ani(ani)
  local form = nx_value(FORM_WUXUE_CANWU)
  if not nx_is_valid(form) then
    return
  end
  form.ani_canwu_value.AnimationImage = ani
  form.ani_canwu_value.Visible = true
  form.ani_canwu_value.Loop = false
  form.ani_canwu_value.PlayMode = 0
end
function on_ani_canwu_value_animation_end(self)
  self.Visible = false
  self.AnimationImage = ""
end
function self_systemcenterinfo(msgid)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(util_text(nx_string(msgid))), 2)
  end
end
function show_skill_action(actor2, skill_id)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local weapon_name = get_weapon_name(ItemType)
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  if nx_string(taolu) == "CS_th_bhcs" then
    weapon_name = "flute_thd_002"
  elseif nx_string(taolu) == "CS_xjz_wmcf" then
    weapon_name = "rule_xjz_001"
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function on_cbtn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.groupbox_1) then
    return
  end
  form.groupbox_1.Visible = self.Checked
end
function on_btn_1_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.btn_help) then
    return
  end
  form.btn_help.Checked = false
end
