require("util_gui")
require("util_functions")
require("share\\view_define")
require("form_stage_main\\puzzle_quest\\puzzle_quest_define")
function log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
  nx_function("ext_trace_log", info)
end
local PUZZLE_QUEST_SET_INI = "ini\\ui\\puzzlequest\\effect_set.ini"
local DEF_PLAYER_PHOTO = ""
local BTN_NORMAL_PHOTO = ""
local ROLE_INFO = {
  ["0"] = "gui\\special\\life\\puzzle_quest\\tiejiang\\role_l.png",
  ["1"] = "gui\\special\\life\\puzzle_quest\\tiejiang\\role_r.png"
}
local ENABLE_SKILL_ANI = {
  ["0"] = "tjskillbtn",
  ["1"] = "tjskill2btn"
}
local BTN_WIDTH = 190
local DEF_MAX_COUNT_PLAYER = 4
local DEF_MAX_COUNT_DENGLONG = 5
local DEF_MAX_COUNT_SKILL = 5
local CAMP_INDEX_SELF = 0
local CAMP_INDEX_YOUR = 1
local SKILL_NEED_STONE = {}
local CONTROL_NAME_SUFFIX = {
  ["0"] = "a",
  ["1"] = "b"
}
local TIPS_ID_DAMAGE = {
  "tips_gembattle_1",
  "tips_gembattle_2",
  "tips_gembattle_3",
  "tips_gembattle_10"
}
local TIPS_ID_FIGHT = "tips_gembattle_4"
local TIPS_ID_DL = {
  "tips_gembattle_5",
  "tips_gembattle_6",
  "tips_gembattle_7",
  "tips_gembattle_8",
  "tips_gembattle_9"
}
local NPC_TALK_ID = {
  [1] = {
    "ui_gem_help_1_1",
    "ui_gem_help_1_2",
    "ui_gem_help_1_3"
  },
  [2] = {
    "ui_gem_help_2_1",
    "ui_gem_help_2_2"
  },
  [3] = {
    "ui_gem_help_3_1",
    "ui_gem_help_3_2",
    "ui_gem_help_3_3"
  }
}
local ALL_CONTROL = {}
local hits = 0
local isHit = false
function bg_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  load_effect_set_ini(self)
end
function async_close_helper_form(self)
  nx_pause(0)
  if nx_is_valid(self) then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "close_helper_form")
    self:Close()
  end
end
function on_bg_form_open(self)
  if not nx_find_custom(self, "type") then
    self.type = 1
    nx_execute(nx_current(), "async_close_helper_form", self)
    return
  end
  SKILL_NEED_STONE = get_skill_need_image(self.type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  self.gemgame_lst = nx_create("ArrayList", nx_current())
  self.gemgame_lst.CurOPName = ""
  self.gemgame_lst.CurOPGroup = -1
  self.gemgame_lst.RemainTime = 0
  self.gemgame_lst.CurGroupAIndex = 0
  self.gemgame_lst.CurGroupBIndex = 0
  self.gemgame_lst.Width = 0
  self.gemgame_lst.Height = 0
  self.group_a_lst = nx_call("util_gui", "get_arraylist", "form_caifeng:group_a_lst")
  self.group_b_lst = nx_call("util_gui", "get_arraylist", "form_caifeng:group_b_lst")
  self.role_name = client_player:QueryProp("Name")
  FORM_CAIFENG = skin_lst[self.gem_game_type]
  self.job_id = job_id[self.gem_game_type]
  local all_players_info = nx_call("util_gui", "get_global_arraylist", "all_players_info")
  all_players_info:ClearChild()
  self.playername = ""
  self.gem_game_times = 1
  local game_client = nx_value("game_client")
  if nx_is_valid(game_client) then
    local player = game_client:GetPlayer()
    if nx_is_valid(player) then
      self.playername = player:QueryProp("Name")
      self.gem_game_times = nx_number(player:QueryProp("GemGameTimes")) + 1
    end
  end
  get_all_control(self)
  self.rbtn_photo1_a.view_id = VIEWPORT_GEM_GROUP_A
  self.rbtn_photo2_a.view_id = VIEWPORT_GEM_GROUP_A
  self.rbtn_photo3_a.view_id = VIEWPORT_GEM_GROUP_A
  self.rbtn_photo4_a.view_id = VIEWPORT_GEM_GROUP_A
  self.rbtn_photo1_b.view_id = VIEWPORT_GEM_GROUP_B
  self.rbtn_photo2_b.view_id = VIEWPORT_GEM_GROUP_B
  self.rbtn_photo3_b.view_id = VIEWPORT_GEM_GROUP_B
  self.rbtn_photo4_b.view_id = VIEWPORT_GEM_GROUP_B
  self.lbl_photo_a.view_id = VIEWPORT_GEM_GROUP_A
  self.lbl_photo_b.view_id = VIEWPORT_GEM_GROUP_B
  self.lbl_name_a.view_id = VIEWPORT_GEM_GROUP_A
  self.lbl_name_b.view_id = VIEWPORT_GEM_GROUP_B
  self.grid_buff_a.view_id = VIEWPORT_GEM_GROUP_A
  self.grid_buff_b.view_id = VIEWPORT_GEM_GROUP_B
  self.mltbox_help.Visible = false
  self.btn_next_help.Visible = false
  self.lbl_tishi_1.Visible = false
  self.lbl_tishi_2.Visible = false
  self.lbl_tishi_3.Visible = false
  self.ani_weapon_a.Visible = false
  self.ani_weapon_b.Visible = false
  self.ani_armor_a.Visible = false
  self.ani_armor_b.Visible = false
  if self.type ~= gem_game_type.gt_tiejiang then
    self.ani_0.Visible = false
    self.ani_1.Visible = false
  end
  self.ani_game_level.Visible = false
  self.chance_player = ""
  self.chance_camp = -1
  self.chance_index = -1
  self.sel_index_self = 0
  self.sel_index_your = 0
  self.gem_help_index = 0
  show_help_info(self)
  show_help_ani(self)
  clear_all_info(self, CAMP_INDEX_SELF)
  clear_all_info(self, CAMP_INDEX_YOUR)
  local jewel_game_manager = nx_value("jewel_game_manager")
  jewel_game_manager:SendServerOperate(op_create)
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_GEM_BOX, self, nx_current(), "on_gem_box_view_operat")
  databinder:AddViewBind(VIEWPORT_GEM_GROUP_A, self, nx_current(), "on_gem_group_view_operat")
  databinder:AddViewBind(VIEWPORT_GEM_GROUP_B, self, nx_current(), "on_gem_group_view_operat")
  return 1
end
function on_bg_close(self)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "hide_help_ani", self)
  end
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self)
  nx_execute("tips_game", "hide_tip")
  if nx_find_custom(self, "group_a_lst") then
    nx_destroy(self.group_a_lst)
  end
  if nx_find_custom(self, "group_b_lst") then
    nx_destroy(self.group_b_lst)
  end
  nx_destroy(self)
  nx_execute("custom_sender", "custom_cancel_open_life_skill_flag", 2)
end
function on_rbtn_photo_a_checked_changed(self)
  local form = self.ParentForm
  if not self.Checked then
    return 0
  end
  form.sel_index_self = nx_number(self.DataSource)
  clear_one_info(form, CAMP_INDEX_SELF)
  show_player_info(form, CAMP_INDEX_SELF, form.sel_index_self)
  on_select_player(0, form.sel_index_self)
end
function on_rbtn_photo_b_checked_changed(self)
  local form = self.ParentForm
  if not self.Checked then
    return 0
  end
  form.sel_index_your = nx_number(self.DataSource)
  clear_one_info(form, CAMP_INDEX_YOUR)
  show_player_info(form, CAMP_INDEX_YOUR, form.sel_index_your)
  show_player_info(form, CAMP_INDEX_YOUR, form.sel_index_your)
  on_select_player(1, form.sel_index_your)
end
function on_btn_skill_a_click(self)
  local form = self.ParentForm
  local camp = CAMP_INDEX_SELF
  local index = form.sel_index_self
  local skill_index = nx_number(self.DataSource)
  play_skill_ani(0)
  on_use_skill(skill_index)
end
function on_btn_skill_b_click(self)
  local form = self.ParentForm
  local camp = CAMP_INDEX_YOUR
  local index = form.sel_index_your
  local skill_index = nx_number(self.DataSource)
  play_skill_ani(1)
  on_use_skill(skill_index)
end
function on_grid_item_select_changed(self)
  self:SetSelectItemIndex(-1)
  if not nx_find_custom(self, "camp") then
    return 0
  end
  if not nx_find_custom(self, "can_use") then
    return 0
  end
  if not self.can_use then
    return 0
  end
  if nx_number(self.camp) == CAMP_INDEX_SELF then
    on_use_fight(0, self.DataSource)
    if self.DataSource == "gemskill_defense" then
      play_skill_ani(0)
    end
  elseif nx_number(self.camp) == CAMP_INDEX_YOUR then
    on_use_fight(1, self.DataSource)
    if self.DataSource == "gemskill_defense" then
      play_skill_ani(1)
    end
  end
end
function on_btn_next_help_click(self)
  show_help_info(self.ParentForm)
end
function on_photo_get_capture(self)
  if not nx_find_custom(self, "view_index") or self.view_index == nil then
    return 0
  end
  nx_execute("tips_game", "show_puzzle_player", self.view_id, nx_int(self.view_index), self.AbsLeft, self.AbsTop)
end
function on_photo_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_add_get_capture(self)
  local gui = nx_value("gui")
  local tips_id = TIPS_ID_DAMAGE[nx_number(self.DataSource)]
  if tips_id == nil then
    return 0
  end
  local tips_text = gui.TextManager:GetFormatText(tips_id)
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
end
function on_lbl_add_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_fight_get_capture(self)
  local gui = nx_value("gui")
  local tips_text = gui.TextManager:GetText(TIPS_ID_FIGHT)
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft, self.AbsTop, 150, self.ParentForm)
end
function on_btn_fight_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_grid_item_mousein_grid(self)
  if not nx_find_custom(self, "item_id") then
    return 0
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  local item = nx_string(self.item_id)
  if item == nx_string(0) then
    return 0
  end
  local gui = nx_value("gui")
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_tips_common", item, 74, x, y)
end
function on_grid_item_mouseout_grid(self)
  nx_execute("tips_game", "hide_tip")
end
function on_mousein_grid(self, index)
  local buff_id = nx_string(self:GetItemName(index))
  if buff_id == "" then
    return 0
  end
  nx_execute("tips_game", "show_puzzle_buffer", buff_id, self.view_id, self.view_index, self:GetMouseInItemLeft(), self:GetMouseInItemTop(), 200)
end
function on_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip")
end
function on_dl_get_capture(self)
  local gui = nx_value("gui")
  if not nx_find_custom(self, "max_value") or self.max_value == nil then
    return 0
  end
  local tips_id = TIPS_ID_DL[nx_number(self.DataSource)]
  if tips_id == nil then
    return 0
  end
  local tips_text = nx_widestr(gui.TextManager:GetText(tips_id)) .. nx_widestr(self.max_value)
  nx_execute("tips_game", "show_text_tip", tips_text, self.AbsLeft, self.AbsTop, 160, self.ParentForm)
end
function on_dl_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_get_capture(self)
  if not nx_find_custom(self, "skill_id") then
    return 0
  end
  nx_execute("tips_game", "show_tips_common", self.skill_id, 1017, self.AbsLeft, self.AbsTop)
end
function on_btn_lost_capture(self)
  nx_execute("tips_game", "hide_tip")
end
function load_effect_set_ini(form)
  form.increasetimehp = 30
  form.increasetimesh = 30
  form.increasetimeqt = 30
  form.increasetimest = 30
  local effectini = nx_execute("util_functions", "get_ini", PUZZLE_QUEST_SET_INI)
  if not nx_is_valid(effectini) then
    return 0
  end
  local index = effectini:FindSectionIndex("caifeng")
  if index < 0 then
    return 0
  end
  form.increasetimehp = effectini:ReadString(index, "increasetimehp", "")
  form.increasetimesh = effectini:ReadString(index, "increasetimesh", "")
  form.increasetimeqt = effectini:ReadString(index, "increasetimeqt", "")
  form.increasetimest = effectini:ReadString(index, "increasetimest", "")
end
function get_all_control(form)
  local ctl_name = ""
  ALL_CONTROL = {}
  for _, suffix in pairs(CONTROL_NAME_SUFFIX) do
    local gb_all_role = form:Find("gb_all_role_" .. suffix)
    if nx_is_valid(gb_all_role) then
      ctl_name = "lbl_selback_" .. suffix
      ALL_CONTROL[ctl_name] = gb_all_role:Find(ctl_name)
      for i = 1, DEF_MAX_COUNT_PLAYER do
        ctl_name = "rbtn_photo" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_all_role:Find(ctl_name)
        ctl_name = "lbl_photo" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_all_role:Find(ctl_name)
        ctl_name = "pbar_hp" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_all_role:Find(ctl_name)
      end
    end
    local gb_one_role = form:Find("gb_one_role_" .. suffix)
    if nx_is_valid(gb_one_role) then
      ctl_name = "pbar_hp_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "lbl_name_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "lbl_photo_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "lbl_att_add_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "lbl_def_add_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "lbl_sku_add_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
      ctl_name = "grid_buff_" .. suffix
      ALL_CONTROL[ctl_name] = gb_one_role:Find(ctl_name)
    end
    local gb_weapon = form:Find("gb_weapon_" .. suffix)
    if nx_is_valid(gb_weapon) then
      ctl_name = "grid_item_left_" .. suffix
      ALL_CONTROL[ctl_name] = gb_weapon:Find(ctl_name)
      ctl_name = "grid_item_right_" .. suffix
      ALL_CONTROL[ctl_name] = gb_weapon:Find(ctl_name)
      ctl_name = "lbl_fight_count_" .. suffix
      ALL_CONTROL[ctl_name] = gb_weapon:Find(ctl_name)
      ctl_name = "btn_fight_" .. suffix
      ALL_CONTROL[ctl_name] = gb_weapon:Find(ctl_name)
    end
    local gb_denglong = form:Find("gb_denglong_" .. suffix)
    if nx_is_valid(gb_denglong) then
      for i = 1, DEF_MAX_COUNT_DENGLONG do
        ctl_name = "lbl_dlback" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_denglong:Find(ctl_name)
        ctl_name = "lbl_dlpoint" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_denglong:Find(ctl_name)
        ctl_name = "pbar_dl" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_denglong:Find(ctl_name)
        ctl_name = "lbl_dl" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_denglong:Find(ctl_name)
        ctl_name = "lbl_dlcnt" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_denglong:Find(ctl_name)
      end
    end
    local gb_all_skill = form:Find("gb_all_skill_" .. suffix)
    if nx_is_valid(gb_all_skill) then
      for i = 1, DEF_MAX_COUNT_SKILL do
        ctl_name = "gb_skill" .. nx_string(i) .. "_" .. suffix
        ALL_CONTROL[ctl_name] = gb_all_skill:Find(ctl_name)
        local gb_skill = ALL_CONTROL[ctl_name]
        if nx_is_valid(gb_skill) then
          ctl_name = "lbl_skillname" .. nx_string(i) .. "_" .. suffix
          ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          ctl_name = "lbl_skillani" .. nx_string(i) .. "_" .. suffix
          ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          ctl_name = "grid_stone" .. nx_string(i) .. "_" .. suffix
          ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          ctl_name = "btn_skill" .. nx_string(i) .. "_" .. suffix
          ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          ctl_name = "lbl_new_skill" .. nx_string(i) .. "_" .. suffix
          ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          for j = 1, DEF_MAX_COUNT_DENGLONG do
            ctl_name = "lbl_stone_pic_" .. nx_string(j) .. nx_string(i) .. "_" .. suffix
            ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
            ctl_name = "lbl_stone_cnt_" .. nx_string(j) .. nx_string(i) .. "_" .. suffix
            ALL_CONTROL[ctl_name] = gb_skill:Find(ctl_name)
          end
        end
      end
    end
  end
end
function show_help_info(form)
  local gui = nx_value("gui")
  do return 0 end
  form.gem_help_index = form.gem_help_index + 1
  local help_count = table.getn(NPC_TALK_ID[form.gem_game_times])
  if help_count < form.gem_help_index then
    form.mltbox_help.Visible = false
    form.btn_next_help.Visible = false
    return 0
  end
  local text = gui.TextManager:GetText(NPC_TALK_ID[form.gem_game_times][form.gem_help_index])
  form.mltbox_help:Clear()
  form.mltbox_help:AddHtmlText(text, -1)
  if form.gem_help_index == help_count then
  else
  end
  form.mltbox_help.Visible = true
  form.btn_next_help.Visible = true
  return 1
end
function show_help_ani(form)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  if form.gem_game_times < 2 or form.gem_game_times > 3 then
    return 0
  end
  if form.gem_game_times == 2 then
    form.lbl_tishi_1.Visible = true
    form.lbl_tishi_2.Visible = true
  end
  if form.gem_game_times == 3 then
    form.lbl_tishi_3.Visible = true
  end
  timer:Register(5000, 1, nx_current(), "hide_help_ani", form, -1, -1)
end
function hide_help_ani(form)
  if not nx_is_valid(form) then
    return 0
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "hide_help_ani", form)
  end
  form.lbl_tishi_1.Visible = false
  form.lbl_tishi_2.Visible = false
  form.lbl_tishi_3.Visible = false
end
function clear_all_info(form, camp)
  local lbl_selback = ALL_CONTROL["lbl_selback_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]]
  if not nx_is_valid(lbl_selback) then
    return false
  end
  lbl_selback.Visible = false
  for i = 1, DEF_MAX_COUNT_PLAYER do
    local suffix = nx_string(i) .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
    local rbtn_photo = ALL_CONTROL["rbtn_photo" .. suffix]
    local lbl_photo = ALL_CONTROL["lbl_photo" .. suffix]
    local pbar_hp = ALL_CONTROL["pbar_hp" .. suffix]
    if not (nx_is_valid(rbtn_photo) and nx_is_valid(lbl_photo)) or not nx_is_valid(pbar_hp) then
      return false
    end
    rbtn_photo.Checked = false
    rbtn_photo.Enabled = false
    pbar_hp.Value = 0
    pbar_hp.value_new = nil
    pbar_hp.value_old = nil
    pbar_hp.elapse_time = nil
    rbtn_photo.view_index = nil
  end
  clear_one_info(form, camp)
end
function clear_one_info(form, camp)
  local suffix = CONTROL_NAME_SUFFIX[nx_string(camp)]
  local lbl_photo = ALL_CONTROL["lbl_photo_" .. suffix]
  local lbl_name = ALL_CONTROL["lbl_name_" .. suffix]
  local pbar_hp = ALL_CONTROL["pbar_hp_" .. suffix]
  local lbl_att_add = ALL_CONTROL["lbl_att_add_" .. suffix]
  local lbl_def_add = ALL_CONTROL["lbl_def_add_" .. suffix]
  local lbl_sku_add = ALL_CONTROL["lbl_sku_add_" .. suffix]
  local grid_buff = ALL_CONTROL["grid_buff_" .. suffix]
  if not (nx_is_valid(lbl_photo) and nx_is_valid(lbl_name) and nx_is_valid(pbar_hp) and nx_is_valid(lbl_att_add) and nx_is_valid(lbl_def_add) and nx_is_valid(lbl_sku_add)) or not nx_is_valid(grid_buff) then
    return false
  end
  lbl_name.Text = nx_widestr("")
  pbar_hp.Value = nx_int(0)
  pbar_hp.Maximum = nx_int(0)
  lbl_att_add.Text = nx_widestr("")
  lbl_def_add.Text = nx_widestr("")
  lbl_sku_add.Text = nx_widestr("")
  grid_buff:Clear()
  lbl_photo.view_index = nil
  grid_buff.view_index = nil
  pbar_hp.value_new = nil
  pbar_hp.value_old = nil
  pbar_hp.elapse_time = nil
  lbl_att_add.value_new = nil
  lbl_att_add.value_old = nil
  lbl_att_add.elapse_time = nil
  lbl_def_add.value_new = nil
  lbl_def_add.value_old = nil
  lbl_def_add.elapse_time = nil
  lbl_sku_add.value_new = nil
  lbl_sku_add.value_old = nil
  lbl_sku_add.elapse_time = nil
  local grid_item_left = ALL_CONTROL["grid_item_left_" .. suffix]
  local grid_item_right = ALL_CONTROL["grid_item_right_" .. suffix]
  local lbl_fight_count = ALL_CONTROL["lbl_fight_count_" .. suffix]
  local btn_fight = ALL_CONTROL["btn_fight_" .. suffix]
  if not (nx_is_valid(grid_item_left) and nx_is_valid(grid_item_right) and nx_is_valid(lbl_fight_count)) or not nx_is_valid(btn_fight) then
    return false
  end
  grid_item_left.item_id = ""
  grid_item_right.item_id = ""
  grid_item_left.camp = ""
  grid_item_right.camp = ""
  grid_item_left.can_use = false
  grid_item_right.can_use = false
  grid_item_left:Clear()
  grid_item_right:Clear()
  lbl_fight_count.Text = nx_widestr("")
  lbl_fight_count.value_new = nil
  lbl_fight_count.value_old = nil
  lbl_fight_count.elapse_time = nil
  for i = 1, DEF_MAX_COUNT_DENGLONG do
    local lbl_dlback = ALL_CONTROL["lbl_dlback" .. nx_string(i) .. "_" .. suffix]
    local lbl_dlpoint = ALL_CONTROL["lbl_dlpoint" .. nx_string(i) .. "_" .. suffix]
    local pbar_dl = ALL_CONTROL["pbar_dl" .. nx_string(i) .. "_" .. suffix]
    local lbl_dl = ALL_CONTROL["lbl_dl" .. nx_string(i) .. "_" .. suffix]
    local lbl_dlcnt = ALL_CONTROL["lbl_dlcnt" .. nx_string(i) .. "_" .. suffix]
    if not (nx_is_valid(lbl_dlback) and nx_is_valid(lbl_dlpoint) and nx_is_valid(pbar_dl) and nx_is_valid(lbl_dl)) or not nx_is_valid(lbl_dlcnt) then
      return false
    end
    lbl_dlpoint.Visible = false
    pbar_dl.Value = 0
    lbl_dl.Visible = false
    lbl_dlcnt.Text = nx_widestr("")
    pbar_dl.max_value = nil
    lbl_dlback.max_value = nil
    pbar_dl.value_new = nil
    pbar_dl.value_old = nil
    pbar_dl.elapse_time = nil
    lbl_dlcnt.value_new = nil
    lbl_dlcnt.value_old = nil
    lbl_dlcnt.elapse_time = nil
  end
  for i = 1, DEF_MAX_COUNT_SKILL do
    local gb_skill = ALL_CONTROL["gb_skill" .. nx_string(i) .. "_" .. suffix]
    if not nx_is_valid(gb_skill) then
      return false
    end
    gb_skill.Visible = false
  end
end
function show_one_player(form, camp, index, is_increase)
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  local suffix = nx_string(index) .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
  local rbtn_photo = ALL_CONTROL["rbtn_photo" .. suffix]
  local lbl_photo = ALL_CONTROL["lbl_photo" .. suffix]
  local pbar_hp = ALL_CONTROL["pbar_hp" .. suffix]
  if not (nx_is_valid(rbtn_photo) and nx_is_valid(lbl_photo)) or not nx_is_valid(pbar_hp) then
    return false
  end
  lbl_photo.Text = nx_widestr(child.playername)
  pbar_hp.Maximum = nx_number(child.maxhp)
  rbtn_photo.Enabled = true
  rbtn_photo.view_index = index
  set_control_value(pbar_hp, "Value", child.curhp, is_increase)
  local player_count = 0
  local child_tab = all_players_info:GetChildList()
  for i = 1, table.getn(child_tab) do
    if nx_number(child_tab[i].camp) == nx_number(camp) then
      player_count = player_count + 1
    end
  end
  if player_count <= 1 then
    if nx_number(camp) == CAMP_INDEX_SELF then
      form.gb_all_role_a.Visible = false
    elseif nx_number(camp) == CAMP_INDEX_YOUR then
      form.gb_all_role_b.Visible = false
    end
  elseif nx_number(camp) == CAMP_INDEX_SELF then
    form.gb_all_role_a.Visible = true
    for i = 1, player_count do
      local photo = form.gb_all_role_a:Find("lbl_photo" .. i .. "_a")
      if nx_is_valid(photo) then
        photo.Visible = true
      end
      local hp = form.gb_all_role_a:Find("pbar_hp" .. i .. "_a")
      if nx_is_valid(hp) then
        hp.Visible = true
      end
    end
    for j = player_count + 1, 4 do
      local photo = form.gb_all_role_a:Find("lbl_photo" .. j .. "_a")
      if nx_is_valid(photo) then
        photo.Visible = false
      end
      local hp = form.gb_all_role_a:Find("pbar_hp" .. j .. "_a")
      if nx_is_valid(hp) then
        hp.Visible = false
      end
    end
  elseif nx_number(camp) == CAMP_INDEX_YOUR then
    form.gb_all_role_b.Visible = true
    for i = 1, player_count do
      local photo = form.gb_all_role_b:Find("lbl_photo" .. i .. "_b")
      if nx_is_valid(photo) then
        photo.Visible = true
      end
      local hp = form.gb_all_role_b:Find("pbar_hp" .. i .. "_b")
      if nx_is_valid(hp) then
        hp.Visible = true
      end
    end
    for j = player_count + 1, 4 do
      local photo = form.gb_all_role_b:Find("lbl_photo" .. j .. "_b")
      if nx_is_valid(photo) then
        photo.Visible = false
      end
      local hp = form.gb_all_role_b:Find("pbar_hp" .. j .. "_b")
      if nx_is_valid(hp) then
        hp.Visible = false
      end
    end
  end
  if nx_number(camp) == CAMP_INDEX_SELF then
    if nx_number(form.sel_index_self) == 0 then
      rbtn_photo.Checked = true
    end
  elseif nx_number(camp) == CAMP_INDEX_YOUR and nx_number(form.sel_index_your) == 0 then
    rbtn_photo.Checked = true
  end
  return true
end
function show_player_info(form, camp, index, is_increase)
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  if nx_number(camp) == CAMP_INDEX_SELF then
    if form.sel_index_self ~= nx_number(index) then
      return false
    end
  elseif nx_number(camp) == CAMP_INDEX_YOUR and form.sel_index_your ~= nx_number(index) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  local suffix = CONTROL_NAME_SUFFIX[nx_string(camp)]
  local rbtn_photo = ALL_CONTROL["rbtn_photo" .. nx_string(index) .. "_" .. suffix]
  local lbl_photo = ALL_CONTROL["lbl_photo" .. nx_string(index) .. "_" .. suffix]
  local pbar_hp = ALL_CONTROL["pbar_hp" .. nx_string(index) .. "_" .. suffix]
  if not (nx_is_valid(rbtn_photo) and nx_is_valid(lbl_photo)) or not nx_is_valid(pbar_hp) then
    return false
  end
  lbl_photo.Text = nx_widestr(child.playername)
  pbar_hp.Maximum = nx_number(child.maxhp)
  rbtn_photo.Enabled = true
  rbtn_photo.view_index = index
  set_control_value(pbar_hp, "Value", child.curhp, is_increase)
  if nx_number(camp) == CAMP_INDEX_SELF then
    if nx_number(form.sel_index_self) == 0 then
      rbtn_photo.Checked = true
    end
  elseif nx_number(camp) == CAMP_INDEX_YOUR and nx_number(form.sel_index_your) == 0 then
    rbtn_photo.Checked = true
  end
  local lbl_photo = ALL_CONTROL["lbl_photo_" .. suffix]
  local lbl_name = ALL_CONTROL["lbl_name_" .. suffix]
  local pbar_hp = ALL_CONTROL["pbar_hp_" .. suffix]
  local lbl_att_add = ALL_CONTROL["lbl_att_add_" .. suffix]
  local lbl_def_add = ALL_CONTROL["lbl_def_add_" .. suffix]
  local lbl_sku_add = ALL_CONTROL["lbl_sku_add_" .. suffix]
  local grid_buff = ALL_CONTROL["grid_buff_" .. suffix]
  if not (nx_is_valid(lbl_photo) and nx_is_valid(lbl_name) and nx_is_valid(pbar_hp) and nx_is_valid(lbl_att_add) and nx_is_valid(lbl_def_add) and nx_is_valid(lbl_sku_add)) or not nx_is_valid(grid_buff) then
    return false
  end
  lbl_photo.view_index = index
  lbl_name.view_index = index
  lbl_name.Text = nx_widestr(child.playername)
  pbar_hp.Maximum = nx_number(child.maxhp)
  set_control_value(pbar_hp, "Value", child.curhp, is_increase)
  set_control_value(lbl_att_add, "Text", child.attcnt, is_increase)
  set_control_value(lbl_def_add, "Text", child.defcnt, is_increase)
  set_control_value(lbl_sku_add, "Text", child.skucnt, is_increase)
  grid_buff.view_index = index
  grid_buff:Clear()
  local buff_tab = util_split_string(nx_string(child.buffers), ",")
  if table.getn(buff_tab) % 3 == 0 then
    for i = 1, table.getn(buff_tab) / 3 do
      if i < 5 then
        local buffid = nx_string(buff_tab[(i - 1) * 3 + 1])
        local photo = nx_string(buff_tab[(i - 1) * 3 + 3])
        grid_buff:AddItem(nx_int(i - 1), photo, nx_widestr(buffid), nx_int(1), nx_int(0))
      end
    end
  end
  local grid_item_left = ALL_CONTROL["grid_item_left_" .. suffix]
  local grid_item_right = ALL_CONTROL["grid_item_right_" .. suffix]
  local lbl_fight_count = ALL_CONTROL["lbl_fight_count_" .. suffix]
  local btn_fight = ALL_CONTROL["btn_fight_" .. suffix]
  if not (nx_is_valid(grid_item_left) and nx_is_valid(grid_item_right) and nx_is_valid(lbl_fight_count)) or not nx_is_valid(btn_fight) then
    return false
  end
  grid_item_left.item_id = nx_string(child.weapon)
  grid_item_right.item_id = nx_string(child.armor)
  grid_item_left.camp = camp
  grid_item_right.camp = camp
  grid_item_left.can_use = check_item_is_can_use(grid_item_left.item_id, child.qtcnt, child.cantuseitem)
  grid_item_right.can_use = check_item_is_can_use(grid_item_right.item_id, child.qtcnt, child.cantuseitem)
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(child.weapon), "Photo")
  if photo ~= "" then
    photo = "gui\\special\\life\\puzzle_quest\\" .. photo
    grid_item_left:AddItem(0, photo, "", 1, -1)
  end
  local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(child.armor), "Photo")
  if photo ~= "" then
    photo = "gui\\special\\life\\puzzle_quest\\" .. photo
    grid_item_right:AddItem(0, photo, "", 1, -1)
  end
  set_control_value(lbl_fight_count, "Text", child.qtcnt, is_increase)
  for i = 1, DEF_MAX_COUNT_DENGLONG do
    set_one_denglong(form, camp, child, i, is_increase)
  end
  show_player_skill(form, camp, index, is_increase)
  return true
end
function set_one_denglong(form, camp, player_child, dl_index, is_increase)
  local suffix = nx_string(dl_index) .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
  local lbl_dlback = ALL_CONTROL["lbl_dlback" .. suffix]
  local lbl_dlpoint = ALL_CONTROL["lbl_dlpoint" .. suffix]
  local pbar_dl = ALL_CONTROL["pbar_dl" .. suffix]
  local lbl_dl = ALL_CONTROL["lbl_dl" .. suffix]
  local lbl_dlcnt = ALL_CONTROL["lbl_dlcnt" .. suffix]
  if not (nx_is_valid(lbl_dlback) and nx_is_valid(lbl_dlpoint) and nx_is_valid(pbar_dl) and nx_is_valid(lbl_dl)) or not nx_is_valid(lbl_dlcnt) then
    return false
  end
  local max = nx_custom(player_child, "stonemax" .. nx_string(dl_index))
  local value = nx_custom(player_child, "stone" .. nx_string(dl_index))
  pbar_dl.Maximum = nx_int(max)
  pbar_dl.max_value = nx_int(max)
  lbl_dlback.max_value = nx_int(max)
  set_control_value(lbl_dlcnt, "Text", value, is_increase)
  set_control_value(pbar_dl, "Value", value, is_increase)
  if pbar_dl.Value == pbar_dl.Maximum then
    lbl_dl.Visible = true
    lbl_dlpoint.Visible = true
  else
    lbl_dl.Visible = false
    lbl_dlpoint.Visible = false
  end
  return true
end
function show_player_skill(form, camp, index, is_increase)
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  if nx_number(camp) == CAMP_INDEX_SELF then
    if form.sel_index_self ~= nx_number(index) then
      return false
    end
  elseif nx_number(camp) == CAMP_INDEX_YOUR and form.sel_index_your ~= nx_number(index) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  local skill_tab = child:GetChildList()
  for i = 1, table.getn(skill_tab) do
    set_one_skill(form, camp, child, skill_tab[i], i)
  end
  return true
end
function set_one_skill(form, camp, player_child, skill_child, skill_index)
  local gui = nx_value("gui")
  local suffix = nx_string(skill_index) .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
  local gb_one_skill = ALL_CONTROL["gb_skill" .. suffix]
  if not nx_is_valid(gb_one_skill) then
    return false
  end
  local lbl_name = ALL_CONTROL["lbl_skillname" .. suffix]
  local grid_stone = ALL_CONTROL["grid_stone" .. suffix]
  local btn_skill = ALL_CONTROL["btn_skill" .. suffix]
  local lbl_ani = ALL_CONTROL["lbl_skillani" .. suffix]
  local lbl_flag = ALL_CONTROL["lbl_new_skill" .. suffix]
  if not (nx_is_valid(lbl_name) and nx_is_valid(grid_stone) and nx_is_valid(btn_skill)) or not nx_is_valid(lbl_ani) then
    return false
  end
  gb_one_skill.Visible = true
  lbl_name.Text = nx_widestr(gui.TextManager:GetText(nx_string(skill_child.Name)))
  grid_stone:Clear()
  local stone_tab = util_split_string(nx_string(skill_child.stones), ",")
  local is_all_enough = true
  for i = 1, table.getn(stone_tab) do
    local need_stone = nx_number(stone_tab[i])
    lbl_stone_pic = ALL_CONTROL["lbl_stone_pic_" .. nx_string(i) .. suffix]
    lbl_stone_cnt = ALL_CONTROL["lbl_stone_cnt_" .. nx_string(i) .. suffix]
    if not nx_is_valid(lbl_stone_pic) or not nx_is_valid(lbl_stone_cnt) then
      return false
    end
    lbl_stone_pic.Visible = false
    lbl_stone_cnt.Text = nx_widestr("")
    if 0 < need_stone then
      local have_stone = nx_number(nx_custom(player_child, "stone" .. nx_string(i)))
      grid_stone:AddItem(nx_int(i - 1), SKILL_NEED_STONE["image" .. nx_string(i)], "", nx_int(1), nx_int(0))
      lbl_stone_cnt.Text = nx_widestr(need_stone)
      if need_stone <= have_stone then
        lbl_stone_pic.Visible = true
      else
        is_all_enough = false
      end
    end
  end
  if is_all_enough and 0 >= nx_number(skill_child.cdturn) and nx_number(player_child.cantuseskill) == 0 then
    lbl_ani.Width = lbl_ani.Parent.Width
    lbl_ani.Visible = true
  elseif is_all_enough and 0 < nx_number(skill_child.cdturn) and nx_number(player_child.cantuseskill) == 0 and 0 < nx_number(skill_child.max_cdturn) and 0 < skill_child.max_cdturn - skill_child.cdturn then
    lbl_ani.Width = (skill_child.max_cdturn - skill_child.cdturn) / skill_child.max_cdturn * lbl_ani.Parent.Width
    lbl_ani.Visible = true
  else
    lbl_ani.Visible = false
  end
  btn_skill.skill_id = skill_child.Name
  if nx_string(form.playername) ~= "" and nx_string(form.playername) == nx_string(form.chance_player) and nx_string(form.playername) == nx_string(player_child.playername) and is_all_enough and 0 >= nx_number(skill_child.cdturn) and nx_number(player_child.cantuseskill) == 0 then
    btn_skill.Enabled = true
    btn_skill.NormalImage = BTN_NORMAL_PHOTO
  else
    btn_skill.Enabled = false
    if is_all_enough and 0 >= nx_number(skill_child.cdturn) and nx_number(player_child.cantuseskill) == 0 then
      btn_skill.NormalImage = BTN_NORMAL_PHOTO
    else
      btn_skill.NormalImage = ""
    end
  end
  if nx_is_valid(lbl_flag) then
    if is_new_equip_skill(btn_skill.skill_id) then
      lbl_flag.Visible = true
    else
      lbl_flag.Visible = false
    end
  end
  return true
end
function check_item_is_can_use(item_id, qt_count, cantuseitem, ...)
  if arg[1] ~= true then
    local GoodsGrid = nx_value("GoodsGrid")
    local item = GoodsGrid:GetItem(nx_string(item_id))
    if not nx_is_valid(item) then
      return false
    end
    local need_fist = nx_execute("tips_data", "get_prop_in_item", item, "NeedFist")
    if nx_number(need_fist) <= nx_number(qt_count) and nx_number(cantuseitem) == 0 then
      return true
    end
    return false
  else
    local need_fist = nx_execute("tips_data", "get_ini_prop", "share\\Item\\tool_item.ini", item_id, "NeedFist", 0)
    if nx_number(need_fist) ~= 0 and nx_number(need_fist) <= nx_number(qt_count) and nx_number(cantuseitem) == 0 then
      return true
    end
  end
end
function set_control_value(control, prop_name, new_value, is_increase)
  if not nx_is_valid(control) then
    return 0
  end
  control.elapse_time = nil
  if is_increase == true then
    control.value_new = nx_number(new_value)
    control.value_old = nx_number(nx_property(control, prop_name))
  else
    control.value_new = nil
    control.value_old = nil
    if prop_name == "Value" then
      nx_set_property(control, prop_name, nx_int(new_value))
    elseif prop_name == "Text" then
      nx_set_property(control, prop_name, nx_widestr(new_value))
    end
  end
end
function increase_all_to_final_count(form, time)
  if not nx_is_valid(form) then
    return 0
  end
  for _, suffix in pairs(CONTROL_NAME_SUFFIX) do
    local gb_all_role = form:Find("gb_all_role_" .. suffix)
    if nx_is_valid(gb_all_role) then
      for j = 1, DEF_MAX_COUNT_PLAYER do
        local pbar_hp = gb_all_role:Find("pbar_hp" .. nx_string(j) .. "_" .. suffix)
        if nx_is_valid(pbar_hp) then
          increase_one_to_final_count(pbar_hp, "Value", time, nx_number(form.increasetimehp))
        end
      end
    end
    local gb_one_role = form:Find("gb_one_role_" .. suffix)
    if nx_is_valid(gb_one_role) then
      local pbar_hp = gb_one_role:Find("pbar_hp_" .. suffix)
      if nx_is_valid(pbar_hp) then
        increase_one_to_final_count(pbar_hp, "Value", time, nx_number(form.increasetimehp))
      end
      local lbl_att_add = gb_one_role:Find("lbl_att_add_" .. suffix)
      if nx_is_valid(lbl_att_add) then
        increase_one_to_final_count(lbl_att_add, "Text", time, nx_number(form.increasetimesh))
      end
      local lbl_def_add = gb_one_role:Find("lbl_def_add_" .. suffix)
      if nx_is_valid(lbl_def_add) then
        increase_one_to_final_count(lbl_def_add, "Text", time, nx_number(form.increasetimesh))
      end
      local lbl_sku_add = gb_one_role:Find("lbl_sku_add_" .. suffix)
      if nx_is_valid(lbl_sku_add) then
        increase_one_to_final_count(lbl_sku_add, "Text", time, nx_number(form.increasetimesh))
      end
    end
    local gb_weapon = form:Find("gb_weapon_" .. suffix)
    if nx_is_valid(gb_weapon) then
      local lbl_fight_count = gb_weapon:Find("lbl_fight_count_" .. suffix)
      if nx_is_valid(lbl_fight_count) then
        increase_one_to_final_count(lbl_fight_count, "Text", time, nx_number(form.increasetimeqt))
      end
    end
    local gb_denglong = form:Find("gb_denglong_" .. suffix)
    local gb_special = form:Find("gb_special_" .. suffix)
    if nx_is_valid(gb_denglong) then
      for j = 1, DEF_MAX_COUNT_DENGLONG do
        local pbar_dl = gb_denglong:Find("pbar_dl" .. nx_string(j) .. "_" .. suffix)
        if nx_is_valid(pbar_dl) then
          if form.type == gem_game_type.gt_caifeng or form.type == gem_game_type.gt_yaoshi or form.type == gem_game_type.gt_chushi then
            if nx_is_valid(gb_special) then
              local gb_progress = gb_special:Find("gb_progress_" .. nx_string(j) .. "_" .. suffix)
              if nx_is_valid(gb_progress) then
                local special_value = 0
                if nx_find_custom(pbar_dl, "value_new") then
                  if pbar_dl.value_new == nil then
                    pbar_dl.value_new = 0
                  end
                  if pbar_dl.value_new ~= 0 then
                    special_value = math.floor(nx_number(pbar_dl.value_new) / (nx_number(pbar_dl.Maximum) / 5)) + 1
                  end
                  for i = 1, special_value do
                    local lab_progress = gb_progress:Find("lab_progress_" .. nx_string(j) .. nx_string(i) .. "_" .. suffix)
                    if nx_is_valid(lab_progress) then
                      gb_progress.Visible = true
                      lab_progress.Visible = true
                    end
                  end
                  for k = special_value + 1, 5 do
                    local lab_progress = gb_progress:Find("lab_progress_" .. nx_string(j) .. nx_string(k) .. "_" .. suffix)
                    if nx_is_valid(lab_progress) then
                      lab_progress.Visible = false
                    end
                  end
                end
              end
            end
          else
            increase_one_to_final_count(pbar_dl, "Value", time, nx_number(form.increasetimest))
          end
        end
        local lbl_dlcnt = gb_denglong:Find("lbl_dlcnt" .. nx_string(j) .. "_" .. suffix)
        if nx_is_valid(lbl_dlcnt) then
          increase_one_to_final_count(lbl_dlcnt, "Text", time, nx_number(form.increasetimest))
        end
        local lbl_dlpoint = gb_denglong:Find("lbl_dlpoint" .. nx_string(j) .. "_" .. suffix)
        local lbl_dl = gb_denglong:Find("lbl_dl" .. nx_string(j) .. "_" .. suffix)
        if nx_is_valid(pbar_dl) and nx_is_valid(lbl_dlpoint) and nx_is_valid(lbl_dl) then
          if pbar_dl.Value == pbar_dl.Maximum then
            lbl_dlpoint.Visible = true
            lbl_dl.Visible = true
          else
            lbl_dlpoint.Visible = false
            lbl_dl.Visible = false
          end
        end
      end
    end
  end
end
function increase_one_to_final_count(control, prop_name, one_time, pre_time)
  if not nx_find_custom(control, "value_old") or control.value_old == nil then
    return 0
  end
  if not nx_find_custom(control, "value_new") or control.value_new == nil then
    return 0
  end
  local value_old = nx_number(control.value_old)
  local value_new = nx_number(control.value_new)
  if value_new == nx_number(nx_property(control, prop_name)) then
    return 1
  end
  if not nx_find_custom(control, "elapse_time") or control.elapse_time == nil then
    control.elapse_time = nx_number(one_time)
  else
    control.elapse_time = nx_number(control.elapse_time) + nx_number(one_time)
  end
  local symbol = nx_number(value_new - value_old) / math.abs(nx_number(value_new - value_old))
  local new_count = nx_int(value_old + symbol * nx_number(control.elapse_time) / nx_number(pre_time))
  if prop_name == "Value" then
    nx_set_property(control, prop_name, nx_int(new_count))
  elseif prop_name == "Text" then
    nx_set_property(control, prop_name, nx_widestr(new_count))
  end
  return 1
end
function add_one_player(camp, index, playername, photo, maxhp, stones_max, weapon, armor)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  if all_players_info:FindChild(nx_string(id)) then
    return false
  end
  local child = all_players_info:CreateChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  child.camp = camp
  child.index = index
  child.playername = playername
  child.photo = photo
  child.maxhp = maxhp
  child.weapon = weapon
  child.armor = armor
  child.cantuseitem = 0
  child.cantuseskill = 0
  child.curhp = maxhp
  child.attcnt = "0"
  child.defcnt = "0"
  child.skucnt = "0"
  child.qtcnt = "0"
  child.buffers = ""
  child.stone1 = "0"
  child.stone2 = "0"
  child.stone3 = "0"
  child.stone4 = "0"
  child.stone5 = "0"
  child.stonemax1 = "0"
  child.stonemax2 = "0"
  child.stonemax3 = "0"
  child.stonemax4 = "0"
  child.stonemax5 = "0"
  local stonemax_tab = util_split_string(nx_string(stones_max), ",")
  for i = 1, table.getn(stonemax_tab) do
    nx_set_custom(child, "stonemax" .. nx_string(i), stonemax_tab[i])
  end
  show_one_player(form, camp, index)
  return true
end
function set_player_skill(camp, index, skillname, infos, max_cdturn)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  if child:FindChild(nx_string(skillname)) then
    return false
  end
  local skill = child:CreateChild(nx_string(skillname))
  if not nx_is_valid(skill) then
    return false
  end
  skill.stones = nx_string(infos)
  skill.cdturn = 0
  skill.max_cdturn = max_cdturn
  show_player_info(form, camp, index)
  return true
end
function set_player_fight(camp, index, curhp, att, def, sku, qt, stones, cantuseitem, cantuseskill)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  child.curhp = curhp
  child.attcnt = att
  child.defcnt = def
  child.skucnt = sku
  child.qtcnt = qt
  child.cantuseitem = cantuseitem
  child.cantuseskill = cantuseskill
  local stone_tab = util_split_string(nx_string(stones), ",")
  for i = 1, table.getn(stone_tab) do
    nx_set_custom(child, "stone" .. nx_string(i), stone_tab[i])
  end
  show_player_info(form, camp, index, true)
  return true
end
function set_player_buffers(camp, index, buffers)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  child.buffers = buffers
  show_player_info(form, camp, index, true)
end
function set_player_skill_cd(camp, index, skillname, cdturn)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  local skill = child:GetChild(nx_string(skillname))
  if not nx_is_valid(skill) then
    return false
  end
  skill.cdturn = nx_number(cdturn)
  show_player_info(form, camp, index, true)
  return true
end
function set_player_chance(camp, index)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local all_players_info = nx_value("all_players_info")
  if not nx_is_valid(all_players_info) then
    return false
  end
  local id = nx_number(camp) * DEF_MAX_COUNT_PLAYER + index
  local child = all_players_info:GetChild(nx_string(id))
  if not nx_is_valid(child) then
    return false
  end
  local gb_all_role = form:Find("gb_all_role_" .. CONTROL_NAME_SUFFIX[nx_string(camp)])
  if not nx_is_valid(gb_all_role) then
    return false
  end
  local suffix = nx_string(index) .. "_" .. CONTROL_NAME_SUFFIX[nx_string(camp)]
  local rbtn_photo = gb_all_role:Find("rbtn_photo" .. suffix)
  local lbl_selback = gb_all_role:Find("lbl_selback_" .. CONTROL_NAME_SUFFIX[nx_string(camp)])
  if not nx_is_valid(rbtn_photo) or not nx_is_valid(lbl_selback) then
    return false
  end
  form.chance_player = nx_string(child.playername)
  if form.chance_camp ~= -1 and form.chance_index ~= -1 then
    show_player_skill(form, form.chance_camp, form.chance_index)
  end
  show_player_info(form, camp, index, true)
  form.chance_camp = camp
  form.chance_index = index
  form.lbl_selback_a.Visible = false
  form.lbl_selback_b.Visible = false
  rbtn_photo.Checked = true
  lbl_selback.Left = rbtn_photo.Left + 1
  lbl_selback.Visible = true
  return true
end
function set_op_left_time(camp, time)
  local form = util_get_form(FORM_CAIFENG, false)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if nx_find_custom(form, "lbl_left_time") then
    local group_name = ""
    if nx_number(camp) == 0 then
      group_name = nx_widestr(gui.TextManager:GetText("ui_diamond_a"))
    else
      group_name = nx_widestr(gui.TextManager:GetText("ui_diamond_b"))
    end
    local pbar_left_time = form:Find("pbar_left_time")
    pbar_left_time.Value = nx_number(time)
    form.lbl_left_time.Text = group_name .. nx_widestr(gui.TextManager:GetText("ui_diamond_lefttime")) .. nx_widestr(time) .. nx_widestr(gui.TextManager:GetText("ui_diamond_second"))
  end
end
function create_fight(form, view, view_ident, index)
  local camp = 0
  local parent_form = nx_value(FORM_PUZZLE_QUEST)
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    camp = 0
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    camp = 1
  end
  local player_list = view:GetViewObjList()
  local all_players_info
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    form.group_a_lst:ClearChild()
    all_players_info = form.group_a_lst
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    form.group_b_lst:ClearChild()
    all_players_info = form.group_b_lst
  end
  for j, view_item in pairs(player_list) do
    local group_player_info = all_players_info:CreateChild(nx_string(j))
    group_player_info.CanOP = 0
    group_player_info.AFK = 0
    group_player_info.PlayerName = ""
    group_player_info.Photo = ""
    group_player_info.ObjType = 0
    group_player_info.HP = 0
    group_player_info.MaxHP = 0
    group_player_info.MaxRed = 0
    group_player_info.MaxYellow = 0
    group_player_info.MaxBlue = 0
    group_player_info.MaxGreen = 0
    group_player_info.MaxPurple = 0
    group_player_info.Red = 0
    group_player_info.Yellow = 0
    group_player_info.Blue = 0
    group_player_info.Green = 0
    group_player_info.Purple = 0
    group_player_info.Fist = 0
    group_player_info.Defence = 0
    group_player_info.Damage = 0
    group_player_info.SkullDamage = 0
    group_player_info.Weapon = ""
    group_player_info.Armor = ""
    group_player_info.CantUseItem = 0
    group_player_info.CantUseSkill = 0
    group_player_info.CanOp = nx_number(view_item:QueryProp("CanOp"))
    group_player_info.AFK = nx_number(view_item:QueryProp("AFK"))
    local gui = nx_value("gui")
    local name = nx_widestr("")
    if nx_number(view_item:QueryProp("ObjType")) == nx_number(1) then
      name = gui.TextManager:GetText(nx_string(view_item:QueryProp("PlayerName")))
    else
      name = nx_widestr(view_item:QueryProp("PlayerName"))
    end
    group_player_info.PlayerName = nx_widestr(name)
    group_player_info.Photo = nx_string(view_item:QueryProp("Photo"))
    group_player_info.ObjType = nx_number(view_item:QueryProp("ObjType"))
    group_player_info.MaxHP = nx_number(view_item:QueryProp("MaxHP"))
    group_player_info.MaxRed = nx_number(view_item:QueryProp("MaxRed"))
    group_player_info.MaxYellow = nx_number(view_item:QueryProp("MaxYellow"))
    group_player_info.MaxBlue = nx_number(view_item:QueryProp("MaxBlue"))
    group_player_info.MaxGreen = nx_number(view_item:QueryProp("MaxGreen"))
    group_player_info.MaxPurple = nx_number(view_item:QueryProp("MaxPurple"))
    group_player_info.Weapon = nx_string(view_item:QueryProp("Weapon"))
    group_player_info.Armor = nx_string(view_item:QueryProp("Armor"))
    nx_execute(FORM_CAIFENG, "add_one_player", camp, j, group_player_info.PlayerName, group_player_info.Photo, group_player_info.MaxHP, nx_string(group_player_info.MaxRed) .. "," .. nx_string(group_player_info.MaxYellow) .. "," .. nx_string(group_player_info.MaxBlue) .. "," .. nx_string(group_player_info.MaxGreen) .. "," .. nx_string(group_player_info.MaxPurple), group_player_info.Weapon, group_player_info.Armor)
    local rows = view_item:GetRecordRows("TempGemSkillRec")
    local str_skill = nx_string(op_skill)
    for i = 0, rows - 1 do
      str_skill = str_skill .. ","
      str_skill = str_skill .. nx_string(view_item:QueryRecord("TempGemSkillRec", i, 0))
    end
    local jewel_game_manager = nx_value("jewel_game_manager")
    local skill_data = jewel_game_manager:QueryDataOperate(str_skill)
    local skill_data_list = util_split_string(skill_data, ",")
    for i = 1, rows do
      local red_need = skill_data_list[(i - 1) * 5 + 1]
      local blue_need = skill_data_list[(i - 1) * 5 + 2]
      local yellow_need = skill_data_list[(i - 1) * 5 + 3]
      local green_need = skill_data_list[(i - 1) * 5 + 4]
      local purple_need = skill_data_list[(i - 1) * 5 + 5]
      local str_skill_id = nx_string(view_item:QueryRecord("TempGemSkillRec", i - 1, 0))
      local max_cdturn = nx_number(jewel_game_manager:GetCDTurns(str_skill_id))
      nx_execute(FORM_CAIFENG, "set_player_skill", camp, j, str_skill_id, nx_string(red_need) .. "," .. nx_string(blue_need) .. "," .. nx_string(yellow_need) .. "," .. nx_string(green_need) .. "," .. nx_string(purple_need), max_cdturn)
    end
    if nx_string(form.role_name) == nx_string(group_player_info.PlayerName) then
      parent_form.self_group = camp
      parent_form.self_index = j
    end
    view_item.skill_count = -2
    reflesh_fight(form, view, view_ident, j, true)
  end
  local cur_index = 0
  if nx_number(view:QueryProp("CurOPGroup")) == 0 then
    cur_index = form.gemgame_lst.CurGroupAIndex
  else
    cur_index = form.gemgame_lst.CurGroupBIndex
  end
  nx_execute(FORM_CAIFENG, "set_player_chance", nx_number(form.gemgame_lst.CurOPGroup), nx_number(cur_index))
end
function reflesh_fight(form, view, view_ident, index, flag)
  local camp = 0
  local parent_form = nx_value(FORM_PUZZLE_QUEST)
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    camp = 0
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    camp = 1
  end
  local view_item = view:GetViewObj(nx_string(index))
  if not nx_is_valid(view_item) then
    return
  end
  local group_player_info
  if nx_number(view_ident) == VIEWPORT_GEM_GROUP_A then
    group_player_info = form.group_a_lst:GetChild(nx_string(index))
  elseif nx_number(view_ident) == VIEWPORT_GEM_GROUP_B then
    group_player_info = form.group_b_lst:GetChild(nx_string(index))
  end
  if not nx_is_valid(group_player_info) then
    return
  end
  if not flag then
    if nx_number(view_item:QueryProp("HP")) < group_player_info.HP then
      nx_execute(FORM_PUZZLE_QUEST, "play_sound", "do_hurt")
      local hurt = group_player_info.HP - nx_number(view_item:QueryProp("HP"))
      local player_name = nx_string(view_item:QueryProp("PlayerName"))
    elseif nx_number(view_item:QueryProp("HP")) > group_player_info.HP and 0 < group_player_info.HP then
      nx_execute(FORM_PUZZLE_QUEST, "play_sound", "recover")
    end
    if nx_number(view_item:QueryProp("Defence")) > group_player_info.Defence then
      nx_execute(FORM_PUZZLE_QUEST, "play_sound", "defend_up")
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_def_add", "gemdef0")
    elseif nx_number(view_item:QueryProp("Defence")) < group_player_info.Defence then
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_def_add", "gemdef1")
    end
    if nx_number(view_item:QueryProp("SkullDamage")) > group_player_info.SkullDamage then
      nx_execute(FORM_PUZZLE_QUEST, "play_sound", "defend_up")
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_att_add", "gematt0")
    elseif nx_number(view_item:QueryProp("SkullDamage")) < group_player_info.SkullDamage then
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_att_add", "gematt1")
    end
    if nx_number(view_item:QueryProp("Damage")) > group_player_info.Damage then
      nx_execute(FORM_PUZZLE_QUEST, "play_sound", "defend_up")
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_sku_add", "gemsku0")
    elseif nx_number(view_item:QueryProp("Damage")) < group_player_info.Damage then
      nx_execute(FORM_PUZZLE_QUEST, "create_diamond_prop_effect", parent_form, camp, "lbl_sku_add", "gemsku1")
    end
  end
  group_player_info.HP = nx_number(view_item:QueryProp("HP"))
  group_player_info.Red = nx_number(view_item:QueryProp("Red"))
  group_player_info.Yellow = nx_number(view_item:QueryProp("Yellow"))
  group_player_info.Blue = nx_number(view_item:QueryProp("Blue"))
  group_player_info.Green = nx_number(view_item:QueryProp("Green"))
  group_player_info.Purple = nx_number(view_item:QueryProp("Purple"))
  group_player_info.Fist = nx_number(view_item:QueryProp("Fist"))
  group_player_info.Defence = nx_number(view_item:QueryProp("Defence"))
  group_player_info.Damage = nx_number(view_item:QueryProp("Damage"))
  group_player_info.SkullDamage = nx_number(view_item:QueryProp("SkullDamage"))
  group_player_info.CantUseItem = math.abs(1 - nx_number(view_item:QueryProp("CanUseItem")))
  group_player_info.CantUseSkill = math.abs(1 - nx_number(view_item:QueryProp("CanUseSkill")))
  if not nx_find_custom(parent_form, "init_damage_" .. nx_string(camp)) then
    nx_set_custom(parent_form, "init_damage_" .. nx_string(camp), group_player_info.Damage)
  end
  if not nx_find_custom(parent_form, "init_defence_" .. nx_string(camp)) then
    nx_set_custom(parent_form, "init_defence_" .. nx_string(camp), group_player_info.Defence)
  end
  if not nx_find_custom(parent_form, "init_skullDamage_" .. nx_string(camp)) then
    nx_set_custom(parent_form, "init_skullDamage_" .. nx_string(camp), group_player_info.SkullDamage)
  end
  nx_execute(nx_current(), "set_fight_prop_effect", nx_custom(parent_form, "init_damage_" .. nx_string(camp)), group_player_info.Damage, "lbl_att_add_", camp)
  nx_execute(nx_current(), "set_fight_prop_effect", nx_custom(parent_form, "init_defence_" .. nx_string(camp)), group_player_info.Defence, "lbl_def_add_", camp)
  nx_execute(nx_current(), "set_fight_prop_effect", nx_custom(parent_form, "init_skullDamage_" .. nx_string(camp)), group_player_info.SkullDamage, "lbl_sku_add_", camp)
  nx_execute(FORM_CAIFENG, "set_player_fight", camp, index, group_player_info.HP, group_player_info.Damage, group_player_info.Defence, group_player_info.SkullDamage, group_player_info.Fist, nx_string(group_player_info.Red) .. "," .. nx_string(group_player_info.Yellow) .. "," .. nx_string(group_player_info.Blue) .. "," .. nx_string(group_player_info.Green) .. "," .. nx_string(group_player_info.Purple), nx_number(group_player_info.CantUseItem), nx_number(group_player_info.CantUseSkill))
  reflesh_fight_dyn_info()
end
function on_gem_box_view_operat(form, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local view = game_client:GetView(nx_string(view_ident))
  local parent_form = nx_value(FORM_PUZZLE_QUEST)
  if not nx_is_valid(view) then
    return
  end
  if optype == "createview" or optype == "updateview" then
    if form.gemgame_lst.CurOPName ~= nx_string(view:QueryProp("CurOPName")) then
      local timer = nx_value("timer_game")
      timer:UnRegister(FORM_PUZZLE_QUEST, "give_tip", parent_form)
      if nx_string(form.role_name) == nx_string(view:QueryProp("CurOPName")) then
        parent_form.self_control = true
        timer:Register(15000, -1, FORM_PUZZLE_QUEST, "give_tip", parent_form, -1, -1)
      else
        parent_form.self_control = false
        nx_execute(FORM_PUZZLE_QUEST, "hid_tip", parent_form)
      end
      if nx_widestr(view:QueryProp("CurOPName")) == nx_widestr(form.role_name) then
        gui.GameHand:SetHand("show", "Default", "", "", "", "")
        form.cursor = "Default"
      else
        gui.GameHand:SetHand("show", "disable", "", "", "", "")
        form.cursor = "disable"
      end
    end
    form.gemgame_lst.CurOPName = nx_string(view:QueryProp("CurOPName"))
    if form.gemgame_lst.CurOPGroup ~= nx_number(view:QueryProp("CurOPGroup")) then
      nx_execute(FORM_PUZZLE_QUEST, "clear_diamond_select")
      nx_execute(FORM_PUZZLE_QUEST, "change_control", parent_form, nx_number(view:QueryProp("CurOPGroup")))
      local cur_index = 0
      if nx_number(view:QueryProp("CurOPGroup")) == 0 then
        cur_index = form.gemgame_lst.CurGroupAIndex
      else
        cur_index = form.gemgame_lst.CurGroupBIndex
      end
      reflesh_fight_dyn_info()
      nx_execute(FORM_CAIFENG, "set_player_chance", nx_number(view:QueryProp("CurOPGroup")), nx_number(cur_index))
    end
    form.gemgame_lst.CurOPGroup = nx_number(view:QueryProp("CurOPGroup"))
    if form.gemgame_lst.RemainTime ~= nx_number(view:QueryProp("RemainTime")) then
    end
    form.gemgame_lst.RemainTime = nx_number(view:QueryProp("RemainTime"))
    nx_execute(FORM_CAIFENG, "set_op_left_time", nx_number(view:QueryProp("CurOPGroup")), form.gemgame_lst.RemainTime)
    if form.gemgame_lst.CurGroupAIndex ~= nx_number(view:QueryProp("CurGroupAIndex")) then
      reflesh_fight_dyn_info()
      if form.gemgame_lst.CurOPGroup == 0 then
        nx_execute(FORM_CAIFENG, "set_player_chance", 0, nx_number(view:QueryProp("CurGroupAIndex")))
      end
    end
    form.gemgame_lst.CurGroupAIndex = nx_number(view:QueryProp("CurGroupAIndex"))
    if form.gemgame_lst.CurGroupBIndex ~= nx_number(view:QueryProp("CurGroupBIndex")) then
      reflesh_fight_dyn_info()
      if form.gemgame_lst.CurOPGroup == 1 then
        nx_execute(FORM_CAIFENG, "set_player_chance", 1, nx_number(view:QueryProp("CurGroupBIndex")))
      end
    end
    form.gemgame_lst.CurGroupBIndex = nx_number(view:QueryProp("CurGroupBIndex"))
    if form.gemgame_lst.Width ~= nx_number(view:QueryProp("Width")) then
    end
    form.gemgame_lst.Width = nx_number(view:QueryProp("Width"))
    if form.gemgame_lst.Height ~= nx_number(view:QueryProp("Height")) then
    end
    form.gemgame_lst.Height = nx_number(view:QueryProp("Height"))
    local temp_hits = nx_number(view:QueryProp("EliminateNum"))
    if temp_hits ~= 0 and temp_hits > hits then
      hits = temp_hits
      isHit = true
    end
    if isHit and temp_hits == 0 then
      if 3 <= hits then
        if 5 < hits then
          hits = 5
        end
        local gui = nx_value("gui")
        nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "create_diamond_hits_img_effect", gui.Desktop.Width / 2 - 260, gui.Desktop.Height / 3, nx_number(hits))
      end
      hits = 0
      isHit = false
    end
  elseif optype == "deleteview" then
  end
  return 1
end
function on_gem_group_view_operat(form, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if optype == "createview" then
    create_fight(form, view, view_ident, index)
  elseif optype == "deleteview" then
  elseif optype == "addview" then
  elseif optype == "updateitem" then
    reflesh_fight(form, view, view_ident, index, flag)
  elseif optype == "delitem" then
  end
  return 1
end
function reflesh_fight_dyn_info()
  local game_client = nx_value("game_client")
  local form = nx_value(FORM_PUZZLE_QUEST)
  if not nx_is_valid(form) then
    return
  end
  local form_job
  if nx_find_custom(form, "puzzle_page") and nx_is_valid(form.puzzle_page) then
    form_job = form.puzzle_page
  end
  local view_lst = {}
  view_lst[1] = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
  view_lst[2] = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_B))
  for i = 1, 2 do
    local weapon_ani, armor_ani
    if nx_is_valid(form_job) then
      local weapon = form_job:Find("gb_weapon_" .. CONTROL_NAME_SUFFIX[nx_string(i - 1)])
      if nx_is_valid(weapon) then
        weapon_ani = weapon:Find("ani_weapon_" .. CONTROL_NAME_SUFFIX[nx_string(i - 1)])
      end
      local armor = form_job:Find("gb_weapon_" .. CONTROL_NAME_SUFFIX[nx_string(i - 1)])
      if nx_is_valid(armor) then
        armor_ani = armor:Find("ani_armor_" .. CONTROL_NAME_SUFFIX[nx_string(i - 1)])
      end
    end
    if not nx_is_valid(view_lst[i]) then
      return
    end
    local player_list = view_lst[i]:GetViewObjList()
    for j, view_item in pairs(player_list) do
      if nx_is_valid(weapon_ani) then
        if check_item_is_can_use(view_item:QueryProp("Weapon"), view_item:QueryProp("Fist"), math.abs(1 - nx_number(view_item:QueryProp("CanUseItem"))), true) then
          weapon_ani.Visible = true
        else
          weapon_ani.Visible = false
        end
      end
      if nx_is_valid(armor_ani) then
        if check_item_is_can_use(view_item:QueryProp("Armor"), view_item:QueryProp("Fist"), math.abs(1 - nx_number(view_item:QueryProp("CanUseItem"))), true) then
          armor_ani.Visible = true
        else
          armor_ani.Visible = false
        end
      end
      local rows = view_item:GetRecordRows("TempGemSkillRec")
      if 0 <= rows then
        for t = 0, rows - 1 do
          local skill_id = nx_string(view_item:QueryRecord("TempGemSkillRec", t, 0))
          local cd_turn = nx_string(view_item:QueryRecord("TempGemSkillRec", t, 1))
          nx_execute(FORM_CAIFENG, "set_player_skill_cd", i - 1, j, skill_id, cd_turn)
        end
      end
      local jewel_game_manager = nx_value("jewel_game_manager")
      rows = view_item:GetRecordRows("TempBuffRec")
      if 0 <= rows then
        local buffer = ""
        for t = 0, rows - 1 do
          local buff_id = view_item:QueryRecord("TempBuffRec", t, 0)
          local active_count = view_item:QueryRecord("TempBuffRec", t, 1)
          local photo = jewel_game_manager:GetBuffPhoto(nx_string(buff_id))
          buffer = buffer .. nx_string(buff_id) .. "," .. nx_string(active_count) .. "," .. nx_string(photo)
          if t ~= rows - 1 then
            buffer = buffer .. ","
          end
        end
        nx_execute(FORM_CAIFENG, "set_player_buffers", i - 1, j, buffer)
      end
    end
  end
end
function on_select_player(camp, index)
  local jewel_game_manager = nx_value("jewel_game_manager")
  local form = nx_value(FORM_PUZZLE_QUEST)
  if nx_is_valid(form) then
    if camp == form.self_group then
      jewel_game_manager:SendServerOperate(op_select_member, index)
    else
      jewel_game_manager:SendServerOperate(op_select_target, index)
    end
  end
end
function on_use_fight(camp, useskill)
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.self_group ~= camp then
    return
  end
  if form.self_control then
    local jewel_game_manager = nx_value("jewel_game_manager")
    jewel_game_manager:SendServerOperate(op_skill, useskill, -1)
  end
end
function on_use_skill(index)
  local jewel_game_manager = nx_value("jewel_game_manager")
  local game_client = nx_value("game_client")
  local view_index = -1
  local form = nx_value(FORM_PUZZLE_QUEST)
  if form.self_group == 0 then
    view_index = VIEWPORT_GEM_GROUP_A
  else
    view_index = VIEWPORT_GEM_GROUP_B
  end
  if view_index == -1 then
    return
  end
  local view = game_client:GetView(nx_string(view_index))
  if not nx_is_valid(view) then
    return
  end
  local view_item = view:GetViewObj(nx_string(form.self_index))
  if not nx_is_valid(view_item) then
    return
  end
  local rows = view_item:GetRecordRows("TempGemSkillRec")
  if rows <= 0 then
    return
  end
  local skill_id = view_item:QueryRecord("TempGemSkillRec", index - 1, 0)
  form.select_skill_id = skill_id
  form.skill_type = jewel_game_manager:GetNeedPos(skill_id)
  if form.skill_type == 0 then
    local select_index = -1
    if form.src_select ~= nil then
      select_index = (form.src_select.diamond_row - 1) * rows + form.src_select.diamond_col - 1
    end
    jewel_game_manager:SendServerOperate(op_skill, skill_id, select_index)
  else
    local gui = nx_value("gui")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(gui.TextManager:GetText("8040"), 2)
    end
    gui.GameHand:SetHand("diamond_skill", "Attack", 0, "", "", "")
  end
end
function get_gem_box_view()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GEM_BOX))
  return view
end
function get_gem_group_view(group)
  local game_client = nx_value("game_client")
  local view
  if group == 1 then
    view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_A))
  elseif group == 2 then
    view = game_client:GetView(nx_string(VIEWPORT_GEM_GROUP_B))
  end
  return view
end
function get_gem_group_item(view, index)
  if not nx_is_valid(view) then
    return nx_null()
  end
  return view:GetViewObj(nx_string(index))
end
function play_skill_ani(cur_group)
  local form = nx_value(FORM_CAIFENG)
  local is_play_anim = false
  if cur_group == 0 then
    if nx_is_valid(form) and nx_is_valid(form:Find("ani_0")) and nx_is_valid(form:Find("ani_1")) then
      form.ani_0.Visible = true
      form.ani_1.Visible = false
      form.ani_0.Loop = false
      form.ani_0:Play()
      is_play_anim = true
    end
  elseif nx_is_valid(form) and nx_is_valid(form:Find("ani_1")) and nx_is_valid(form:Find("ani_0")) then
    form.ani_0.Visible = false
    form.ani_1.Visible = true
    form.ani_1.Loop = false
    form.ani_1:Play()
    is_play_anim = true
  end
end
function on_anim_end(self)
  self:Stop()
  local caifeng_form = self.Parent
  if nx_is_valid(caifeng_form) and caifeng_form.type ~= gem_game_type.gt_tiejiang then
    self.Visible = false
  end
end
function on_btn_help_click(self)
  local form = nx_value(FORM_CAIFENG)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  local help_form = nx_value(help_skin_lst[form.gem_game_type])
  if nx_is_valid(help_form) then
    help_form.Visible = not help_form.Visible
  else
    help_form = nx_execute("util_gui", "util_get_form", help_skin_lst[form.gem_game_type], true, false)
    help_form.count = 8
    help_form:Show()
  end
  help_form.no_need_motion_alpha = false
end
function on_btn_quit_click(self)
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_quest", "hide_form")
end
function reset_cursor()
  local form = nx_value("form_stage_main\\puzzle_quest\\form_puzzle_quest")
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "puzzle_page") then
    return
  end
  if nx_is_valid(form.puzzle_page) and nx_find_custom(form.puzzle_page, "cursor") and form.puzzle_page.cursor ~= "Default" then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui.GameHand:SetHand("show", "disable", "", "", "", "")
    end
  end
end
function set_fight_prop_effect(init_value, current_value, label_name, camp)
  local after_str_lst = {
    [0] = "a",
    [1] = "b"
  }
  local form = nx_value(FORM_CAIFENG)
  if not nx_is_valid(form) then
    return
  end
  local control_group = form:Find("gb_one_role_" .. nx_string(after_str_lst[camp]))
  if not nx_is_valid(control_group) then
    return
  end
  local control = control_group:Find(label_name .. nx_string(after_str_lst[camp]))
  if not nx_is_valid(control) then
    return
  end
  if nx_number(current_value) > nx_number(init_value) then
    control.ForeColor = "255,255,0,0"
  elseif nx_number(current_value) == nx_number(init_value) then
    control.ForeColor = "255,255,255,255"
  else
    control.ForeColor = "255,0,255,0"
  end
end
function get_job_level(job_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("job_rec", 0, job_id, 0)
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("job_rec", row, 1)
end
function on_btn_sx_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "job_id") then
    return
  end
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_life_fight", "set_job", form.job_id, get_job_level(form.job_id), true)
  nx_execute("form_stage_main\\puzzle_quest\\form_puzzle_life_fight", "auto_show_hide_form_puzzle_life_fight", 2)
end
function is_new_equip_skill(skill_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local view = game_client:GetView(nx_string(VIEWPORT_GAME_SUBOBJ_BOX))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  local view_item = viewobj_list[1]
  if not nx_is_valid(view_item) then
    return false
  end
  local row = view_item:FindRecordRow("JobGemSkillRec", 0, skill_id, 0)
  if nx_int(0) > nx_int(row) then
    return false
  end
  local skill_flg = math.pow(nx_number(2), nx_number(row))
  local flag = client_player:QueryProp("NewEquipSkill")
  local value = nx_function("ext_bit_band", flag, skill_flg)
  if nx_int(value) > nx_int(0) then
    return false
  end
  return true
end
