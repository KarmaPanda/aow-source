require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("util_functions")
require("share\\logicstate_define")
require("form_stage_main\\form_battlefield\\battlefield_define")
require("util_gui")
require("form_stage_main\\switch\\switch_define")
local FORM_BATTLEFIELD_JOIN = "form_stage_main\\form_battlefield\\form_battlefield_join"
local TVT_INI_PATH = "ini\\ui\\battlefield\\tvt_battlefield.ini"
local RULE_TYPE = {
  [BATTLEFIELD_RULETYPE_1] = "ui_force",
  [BATTLEFIELD_RULETYPE_2] = "ui_death"
}
local NUM_TYPE = {
  [0] = "ui_6v6",
  [1] = "ui_12v12",
  [2] = "ui_24v24",
  [3] = "ui_battle_12",
  [4] = "ui_battle_24",
  [5] = "ui_battle_48",
  [6] = "ui_3v3"
}
local BUDDY_TYPE = {
  "ui_battle_matching",
  "ui_battle_team"
}
local PLAY_WAY = {
  "gui\\language\\ChineseS\\battlefield\\battle_kill.png",
  "gui\\language\\ChineseS\\battlefield\\battle_occupy.png",
  "gui\\language\\ChineseS\\battlefield\\battle_banner.png",
  "gui\\language\\ChineseS\\battlefield\\battle_alive.png"
}
local PLAY_MYZ_MAPID = {
  "6X6_myz",
  "6X6_myz_max",
  "12X12_myz",
  "12X12_myz_max"
}
local PLAY_GMP_MAPID = {
  "6X6_gmp",
  "6X6_gmp_max"
}
local PLAY_GMP = 1
local PLAY_MYZ = 2
local SIDE_UNKNOWN = 0
local SIDE_NORMAL = 1
local SIDE_BOSS = 2
local SIDE_WHITE = 3
local SIDE_BLACK = 4
local CLIENT_SUBMSG_REQUEST_ENTER = 1
local CLIENT_SUBMSG_REQUEST_LEAVE = 2
local CLIENT_SUBMSG_REQUEST_LOOK = 3
local CLIENT_SUBMSG_QUERY_FORCE_INFO = 4
local array_name_gumu = "gumu_score_array"
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_custom(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local custom_list = nx_custom_list(ent)
  log("custom_list bagin")
  for _, custom in ipairs(custom_list) do
    log(custom .. " = " .. nx_custom(ent, custom))
  end
  log("custom_list end")
end
function main_form_init(form)
  form.Fixed = false
  form.ini = nx_null()
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.ini = nx_execute("util_functions", "get_ini", TVT_INI_PATH)
  if not nx_is_valid(form.ini) then
    nx_msgbox(TVT_INI_PATH .. get_msg_str("msg_120"))
    return
  end
  show_battlefield_tree(form, ENTER_MODE_SINGLE)
  form.gmp_all_score = 0
  form.gmp_week_score = 0
  form.myz_all_score = 0
  form.myz_week_score = 0
  load_gumu_ini(form)
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_QUERY_FORCE_INFO)
  form.ani_connect.Visible = true
  form.ani_connect.PlayMode = 2
  form.lbl_connect.Visible = true
  form.lbl_count_kill.Visible = false
  form.lbl_kill.Visible = false
end
function main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function show_battlefield_tree(form, select_buddy)
  local gui = nx_value("gui")
  local ini = form.ini
  if not nx_is_valid(ini) then
    return
  end
  local root = form.tree_guan:CreateRootNode(nx_widestr(""))
  if not nx_is_valid(root) then
    return
  end
  local node_type = root:FindNode(nx_widestr(util_text("ui_battle_jointype")))
  if not nx_is_valid(node_type) then
    node_type = root:CreateNode(nx_widestr(util_text("ui_battle_jointype")))
    if nx_is_valid(node_type) then
      set_node_prop(node_type, 1)
      node_type.ItemHeight = 30
      node_type.TextOffsetY = 4
      node_type.Font = "font_text_title1"
      node_type.Expand = true
    end
    for j, v in ipairs(BUDDY_TYPE) do
      local node_buddy = node_type:FindNode(nx_widestr(util_text(v)))
      if not nx_is_valid(node_buddy) then
        node_buddy = node_type:CreateNode(nx_widestr(util_text(v)))
        if nx_is_valid(node_buddy) then
          set_node_prop(node_buddy, 2)
          node_buddy.ItemHeight = 28
          node_buddy.TextOffsetY = 6
          node_buddy.NodeSelectImage = "gui\\special\\battlefield\\btn_down.png"
          if j == select_buddy then
            node_buddy.NodeBackImage = "gui\\special\\battlefield\\btn_down.png"
            node_buddy.NodeFocusImage = "gui\\special\\battlefield\\btn_down.png"
            form.select_buddy = select_buddy
          end
        end
      end
    end
  end
  for i = 0, table.getn(RULE_TYPE) do
    if i ~= 1 and i ~= 2 then
      local node_1 = root:CreateNode(nx_widestr(util_text(RULE_TYPE[i])))
      if nx_is_valid(node_1) then
        set_node_prop(node_1, 1)
        node_1.ItemHeight = 30
        node_1.TextOffsetY = 4
      end
    end
  end
  local select_node = nx_null()
  local section_count = ini:GetSectionCount()
  for i = 1, section_count do
    local sec_index = i - 1
    local id = ini:ReadString(sec_index, "map_id", "")
    local rule = ini:ReadInteger(sec_index, "rule", 0)
    local num = ini:ReadInteger(sec_index, "num", 0)
    local name = ini:ReadString(sec_index, "name", "")
    local play_way = ini:ReadInteger(sec_index, "playway", 0)
    local match_type = ini:ReadInteger(sec_index, "match_type", 0)
    local rule_text = RULE_TYPE[rule]
    local num_text = NUM_TYPE[num]
    if rule_text ~= nil and num_text ~= nil then
      local node_1 = root:FindNode(nx_widestr(util_text(rule_text)))
      if nx_is_valid(node_1) then
        node_1.Font = "font_text_title1"
        local node_2 = node_1:FindNode(nx_widestr(util_text(num_text)))
        if not nx_is_valid(node_2) then
          node_2 = node_1:CreateNode(nx_widestr(util_text(num_text)))
          if nx_is_valid(node_2) then
            set_node_prop(node_2, 2)
            node_2.ItemHeight = 28
            node_2.TextOffsetY = 6
          end
        end
        if not nx_is_valid(node_2) then
          break
        end
        if match_type == select_buddy or match_type == MATCH_TYPE_ALL then
          local node_3 = node_2:CreateNode(nx_widestr(util_text(name)))
          if nx_is_valid(node_3) then
            set_node_prop(node_3, 2)
            node_3.ItemHeight = 28
            node_3.TextOffsetY = 6
            node_3.id = id
            node_3.rule = rule
            node_3.play_way = play_way
            node_3.ForeColor = "255,242,240,233"
            node_3.NodeSelectImage = "gui\\special\\battlefield\\btn_down.png"
            if not nx_is_valid(select_node) then
              select_node = node_3
              node_1.Expand = true
              node_2.Expand = true
            end
          end
        end
      end
    end
  end
  if not nx_is_valid(form.tree_guan.SelectNode) then
    form.tree_guan.SelectNode = select_node
  end
  root.Expand = true
end
function show_battlefield_detail(form, node)
  if not nx_is_valid(form.ini) then
    return
  end
  if not nx_find_custom(node, "id") or not nx_find_custom(node, "rule") then
    return
  end
  local sec_index = get_mapid_section_index(form.ini, node.id, node.rule)
  if sec_index < 0 then
    return
  end
  local area = form.ini:ReadString(sec_index, "area", "")
  local photo = form.ini:ReadString(sec_index, "photo", "")
  local scale = form.ini:ReadString(sec_index, "scale", "")
  local rule = form.ini:ReadInteger(sec_index, "rule", 0)
  form.lbl_bg_main.BackImage = photo
  if form.rbtn_scenario.Checked then
    on_rbtn_checked_changed(form.rbtn_scenario)
  else
    form.rbtn_scenario.Checked = true
  end
  form.lbl_name.Text = nx_widestr("")
  local rule_text = RULE_TYPE[node.rule]
  form.lbl_name.Text = nx_widestr(util_text(rule_text)) .. nx_widestr(" ") .. nx_widestr(util_text(scale))
  if rule == BATTLEFIELD_RULETYPE_1 and (not nx_find_custom(node, "white_force") or not nx_find_custom(node, "black_force")) then
    return
  end
  form.mltbox_cgdesc:Clear()
  local node = form.tree_guan.SelectNode
  if not (nx_is_valid(node) and nx_find_custom(node, "id")) or not nx_find_custom(node, "rule") then
    return
  end
  local sec_index = get_mapid_section_index(form.ini, node.id, node.rule)
  if sec_index < 0 then
    return
  end
  local scenario_desc = form.ini:ReadString(sec_index, "scenario_desc", "")
  local play_desc = form.ini:ReadString(sec_index, "play_desc", "")
  local limit_desc = form.ini:ReadString(sec_index, "limit_desc", "")
  if form.rbtn_scenario.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(scenario_desc)), 1)
  elseif form.rbtn_play.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(play_desc)), 1)
  elseif form.rbtn_limit.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(limit_desc)), 1)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local playtype = get_playtype_by_mapid(node.id)
  if playtype == PLAY_GMP then
    form.lbl_all_score.Text = gui.TextManager:GetText("ui_battle_point")
    form.lbl_count_all_score.Text = nx_widestr(form.gmp_all_score)
    form.btn_vs.Text = gui.TextManager:GetText("ui_battlefield_SelfWeekTotalScore") .. nx_widestr(":") .. nx_widestr(form.gmp_week_score)
  elseif playtype == PLAY_MYZ then
    form.lbl_all_score.Text = gui.TextManager:GetText("ui_battle_pointMyz")
    form.lbl_count_all_score.Text = nx_widestr(form.myz_all_score)
    form.btn_vs.Text = gui.TextManager:GetText("ui_battlefield_SelfWeekTotalScoreMyz") .. nx_widestr(":") .. nx_widestr(form.myz_week_score)
  end
  show_gb_gumu(form)
end
function update_battlefield_info(...)
  if table.getn(arg) < 1 then
    return 0
  end
  local form = util_get_form(FORM_BATTLEFIELD_JOIN, false)
  if not nx_is_valid(form) then
    return
  end
  local ini = form.ini
  if not nx_is_valid(ini) then
    return
  end
  if not nx_is_valid(form.tree_guan.RootNode) then
    return
  end
  local node_1 = form.tree_guan.RootNode:FindNode(nx_widestr(util_text(RULE_TYPE[BATTLEFIELD_RULETYPE_1])))
  if not nx_is_valid(node_1) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local karma_vs_a = ""
  local karma_vs_b = ""
  local batt_table = util_split_string(arg[1], ";")
  for i = 1, table.getn(batt_table) do
    local value_tab = util_split_string(batt_table[i], ",")
    if table.getn(value_tab) >= 3 then
      local id = value_tab[1]
      local white_force = value_tab[2]
      local black_force = value_tab[3]
      karma_vs_a = white_force
      karma_vs_b = black_force
      local sec_index = get_mapid_section_index(form.ini, id, BATTLEFIELD_RULETYPE_1)
      local sec_index_fight = get_mapid_section_index(form.ini, id, BATTLEFIELD_RULETYPE_3)
      if 0 <= sec_index then
        local num = ini:ReadInteger(sec_index, "num", 0)
        local name = ini:ReadString(sec_index, "name", "")
        local num_type = NUM_TYPE[num]
        if num_type ~= nil then
          local node_2 = node_1:FindNode(nx_widestr(util_text(num_type)))
          if nx_is_valid(node_2) then
            local node_3 = node_2:FindNode(nx_widestr(util_text(name)))
            if nx_is_valid(node_3) then
              node_3.white_force = white_force
              node_3.black_force = black_force
            end
          end
        end
      end
      if 0 <= sec_index_fight then
        local num = ini:ReadInteger(sec_index_fight, "num", 0)
        local name = ini:ReadString(sec_index_fight, "name", "")
        local num_type = NUM_TYPE[num]
        if num_type ~= nil and node_1_fight ~= nil then
          local node_2_fight = node_1_fight:FindNode(nx_widestr(util_text(num_type)))
          if nx_is_valid(node_2_fight) then
            local node_3_fight = node_2_fight:FindNode(nx_widestr(util_text(name)))
            if nx_is_valid(node_3_fight) then
              node_3_fight.white_force = white_force
              node_3_fight.black_force = black_force
            end
          end
        end
      end
    end
  end
  if nx_is_valid(form.tree_guan.SelectNode) then
    show_battlefield_detail(form, form.tree_guan.SelectNode)
  end
  form.lbl_count_win.Text = nx_widestr(nx_int(arg[3]))
  form.lbl_count_join.Text = nx_widestr(nx_int(arg[4]))
  form.lbl_count_kill.Text = nx_widestr(nx_int(arg[5]))
  form.lbl_count_money.Text = nx_widestr(nx_int(arg[6]))
  form.gmp_all_score = nx_int(arg[2])
  form.gmp_week_score = nx_int(arg[7])
  form.myz_all_score = nx_int(arg[8])
  form.myz_week_score = nx_int(arg[9])
  if nx_is_valid(form.tree_guan.SelectNode) then
    show_battlefield_detail(form, form.tree_guan.SelectNode)
  end
  form.lbl_info.Text = nx_widestr("")
  form.btn_request.Text = gui.TextManager:GetText("ui_battlefield_join")
  form.btn_request.Enabled = false
  if can_join_battle(form.lbl_info) then
    form.btn_request.Enabled = true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) then
    local battlefield_state = client_player:QueryProp("BattlefieldState")
    if 0 < battlefield_state and 4 ~= battlefield_state then
      form.btn_request.Text = gui.TextManager:GetText("ui_battlefield_quit")
      form.btn_request.Enabled = true
    end
  end
  local gumu_score = nx_int(arg[10])
  init_gumu_gb(form, gumu_score)
  form.ani_connect.Visible = false
  form.ani_connect.PlayMode = 0
  form.lbl_connect.Visible = false
end
function a(info)
  nx_msgbox(nx_string(info))
end
function init_gumu_gb(form, gumu_score)
  show_gb_gumu(form)
  form.lbl_gumu_score.Text = nx_widestr(gumu_score)
  local cur_level, score_next = get_gumu_score_level(gumu_score)
  local text = ""
  if score_next == 0 then
    text = util_format_string("ui_gumu_score_hint_01", cur_level)
  else
    text = util_format_string("ui_gumu_score_hint_02", cur_level, score_next)
  end
  form.lbl_gumu_score.HintText = nx_widestr(text)
  if is_gumu_score_time() then
    form.lbl_gumu_state.ForeColor = "255,0,255,0"
    form.lbl_gumu_state.Text = nx_widestr(util_text("ui_gumu_score_state_01"))
  else
    form.lbl_gumu_state.ForeColor = "255,255,0,0"
    form.lbl_gumu_state.Text = nx_widestr(util_text("ui_gumu_score_state_02"))
  end
end
function show_gb_gumu(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_BATTLE_GUMU_MATCH) then
    return
  end
  if nx_is_valid(form.tree_guan.SelectNode) then
    local playtype = get_playtype_by_mapid(form.tree_guan.SelectNode.id)
    if playtype == PLAY_GMP and form.select_buddy ~= ENTER_MODE_TEAM then
      form.gb_gumu.Visible = true
      return
    end
  end
  form.gb_gumu.Visible = false
end
function load_gumu_ini(form)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\battlefield_gumu.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("score_level")
  if sec_index < 0 then
    return
  end
  local sec_item_count = ini:GetSectionItemCount(sec_index)
  local level_nums = sec_item_count
  for i = 0, nx_number(sec_item_count) - 1 do
    local str_value = ini:GetSectionItemValue(sec_index, i)
    local tab_value = util_split_string(str_value, ",")
    local level = nx_number(tab_value[1])
    local left = nx_number(tab_value[2])
    local right = nx_number(tab_value[3])
    local array_name = get_array_name(level)
    common_array:RemoveArray(array_name)
    common_array:AddArray(array_name, form, 600, true)
    common_array:AddChild(array_name, "level", level)
    common_array:AddChild(array_name, "left", left)
    common_array:AddChild(array_name, "right", right)
  end
  sec_index = ini:FindSectionIndex("property")
  if sec_index < 0 then
    return
  end
  local score_time = ini:ReadString(sec_index, "score_time", "")
  common_array:RemoveArray(array_name_gumu)
  common_array:AddArray(array_name_gumu, form, 600, true)
  common_array:AddChild(array_name_gumu, "level_nums", nx_number(level_nums))
  common_array:AddChild(array_name_gumu, "score_time", nx_string(score_time))
end
function get_array_name(level)
  return array_name_gumu .. nx_string(level)
end
function get_gumu_score_level(gumu_score)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local cur_level = 0
  local score_next = 0
  local level_nums = nx_number(common_array:FindChild(array_name_gumu, "level_nums"))
  for i = 1, level_nums do
    local array_name = get_array_name(i)
    local level = nx_number(common_array:FindChild(array_name, "level"))
    local left = nx_number(common_array:FindChild(array_name, "left"))
    local right = nx_number(common_array:FindChild(array_name, "right"))
    if left <= nx_number(gumu_score) and right >= nx_number(gumu_score) then
      cur_level = level
    end
  end
  if level_nums > cur_level then
    local array_name = get_array_name(cur_level + 1)
    local left = nx_number(common_array:FindChild(array_name, "left"))
    score_next = left - nx_number(gumu_score)
  end
  return cur_level, score_next
end
function is_gumu_score_time()
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local msg_delay = nx_value("MessageDelay")
  if not nx_is_valid(msg_delay) then
    return
  end
  local cur_date_time = msg_delay:GetServerDateTime()
  local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
  local score_time = nx_string(common_array:FindChild(array_name_gumu, "score_time"))
  local tab_hour = util_split_string(score_time, ",")
  for i = 1, table.getn(tab_hour) do
    if nx_number(cur_hour) == nx_number(tab_hour[i]) then
      return true
    end
  end
  return false
end
function on_tree_guan_select_changed(self, cur_node, old_node)
  local parent_node = cur_node.ParentNode
  if nx_is_valid(parent_node) then
    local select_buddy = self.ParentForm.select_buddy
    local temp1_node = parent_node:FindNode(nx_widestr(util_text(BUDDY_TYPE[select_buddy])))
    if nx_is_valid(temp1_node) then
      for i, v in ipairs(BUDDY_TYPE) do
        if i ~= select_buddy and nx_ws_equal(nx_widestr(util_text(v)), cur_node.Text) then
          local temp2_node = parent_node:FindNode(cur_node.Text)
          if nx_is_valid(temp2_node) then
            temp1_node.NodeBackImage = "gui\\common\\treeview\\tree_2_out.png"
            temp1_node.NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png"
            temp2_node.NodeBackImage = "gui\\special\\battlefield\\btn_down.png"
            temp2_node.NodeFocusImage = "gui\\special\\battlefield\\btn_down.png"
            self.ParentForm.select_buddy = i
            local root_node = parent_node.ParentNode
            root_node:ClearNode()
            show_battlefield_tree(self.ParentForm, i)
            nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_QUERY_FORCE_INFO)
            return
          end
        end
      end
    end
  end
  local form = self.ParentForm
  if not nx_is_valid(cur_node) then
    return
  end
  show_battlefield_detail(form, cur_node)
  if nx_find_custom(cur_node, "help_node") then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
  show_battlefield_play_way(form, cur_node)
end
function show_battlefield_play_way(form, cur_node)
  if nx_is_valid(form) and nx_find_custom(cur_node, "play_way") then
    local play_way = cur_node.play_way
    if play_way == 10 then
      form.lbl_play_way.BackImage = PLAY_WAY[1]
    elseif play_way == 1 or play_way == 2 or play_way == 3 or play_way == 4 then
      form.lbl_play_way.BackImage = PLAY_WAY[play_way]
    end
  end
end
function on_tree_guan_vscroll_changed(self, value)
  if value == 0 then
    self.ParentForm.lbl_1.Visible = true
  else
    self.ParentForm.lbl_1.Visible = false
  end
end
function on_rbtn_checked_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form.ini) then
    return
  end
  form.mltbox_cgdesc:Clear()
  local node = form.tree_guan.SelectNode
  if not (nx_is_valid(node) and nx_find_custom(node, "id")) or not nx_find_custom(node, "rule") then
    return
  end
  local sec_index = get_mapid_section_index(form.ini, node.id, node.rule)
  if sec_index < 0 then
    return
  end
  local scenario_desc = form.ini:ReadString(sec_index, "scenario_desc", "")
  local play_desc = form.ini:ReadString(sec_index, "play_desc", "")
  local limit_desc = form.ini:ReadString(sec_index, "limit_desc", "")
  if form.rbtn_scenario.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(scenario_desc)), 1)
  elseif form.rbtn_play.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(play_desc)), 1)
  elseif form.rbtn_limit.Checked then
    form.mltbox_cgdesc:AddHtmlText(nx_widestr(util_text(limit_desc)), 1)
  end
end
function on_btn_request_click(self)
  local form = self.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) then
    local battlefield_state = client_player:QueryProp("BattlefieldState")
    if 0 < battlefield_state and 4 ~= battlefield_state then
      request_leave_battlefield()
      form:Close()
      return
    end
  end
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    nx_pause(0.5)
  end
  local node = form.tree_guan.SelectNode
  if not nx_is_valid(node) then
    return
  end
  if not nx_find_custom(node, "rule") or not nx_find_custom(node, "id") then
    return
  end
  if node.rule == BATTLEFIELD_RULETYPE_1 then
    if not nx_find_custom(node, "white_force") or not nx_find_custom(node, "black_force") then
      return
    end
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_switch", "show_form", form.ini, node.id, node.rule, node.play_way, node.white_force, node.black_force, form.select_buddy)
  elseif node.rule == BATTLEFIELD_RULETYPE_2 then
    nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_ENTER, ENTER_MODE_SINGLE, node.id, node.rule, node.play_way, SIDE_NORMAL, "", "")
  elseif node.rule == BATTLEFIELD_RULETYPE_3 then
    if not nx_find_custom(node, "white_force") or not nx_find_custom(node, "black_force") then
      return
    end
    nx_execute("form_stage_main\\form_battlefield\\form_battlefield_switch", "show_form", form.ini, node.id, node.rule, node.play_way, node.white_force, node.black_force, form.select_buddy)
  end
  form.lbl_info.Text = nx_widestr("")
  form.btn_request.Enabled = false
  if can_join_battle(form.lbl_info) then
    form.btn_request.Enabled = true
  end
  form:Close()
end
function get_mapid_section_index(ini, map_id, rule_type)
  if not nx_is_valid(ini) then
    return -1
  end
  local section_count = ini:GetSectionCount()
  for i = 1, section_count do
    local sec_index = i - 1
    local id = ini:ReadString(sec_index, "map_id", "")
    local rule = ini:ReadInteger(sec_index, "rule", 0)
    if id == map_id and rule_type == rule then
      return sec_index
    end
  end
  return -1
end
function on_btn_result_click(btn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not client_player:FindProp("Name") then
    return
  end
  local player_name = client_player:QueryProp("Name")
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_LOOK, player_name)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_result", true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function request_leave_battlefield()
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:QueryProp("BattlefieldState") == 3 and not nx_function("find_buffer", client_player, "buff_battlefield_lock") then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = gui.TextManager:GetText("ui_battle_exit")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "cancel" then
      return
    end
  end
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_LEAVE)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_BATTLEFIELD_JOIN, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function can_join_battle(lbl_reason)
  if not nx_is_valid(lbl_reason) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local scene = game_client:GetScene()
  if not nx_is_valid(scene) then
    return false
  end
  local is_dead = client_player:QueryProp("Dead")
  if 0 < is_dead then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("1805"))
    return false
  end
  local is_red_name = client_player:QueryProp("IsRedName")
  if 1 == is_red_name then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37085"))
    return false
  end
  local logic_state = client_player:QueryProp("LogicState")
  if LS_FIGHTING == logic_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37061"))
    return false
  end
  if LS_SITCROSS == logic_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37067"))
    return false
  end
  if LS_FACULTY == logic_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37069"))
    return false
  end
  if LS_STALLED == logic_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37065"))
    return false
  end
  if scene:FindProp("SourceID") then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37063"))
    return false
  end
  local is_on_trans = client_player:QueryProp("OnTransToolState")
  if is_on_trans ~= 0 then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37068"))
    return false
  end
  local interact_status = client_player:QueryProp("InteractStatus")
  if interact_status ~= -1 then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37059"))
    return false
  end
  local prison_type = client_player:QueryProp("PrisonType")
  if prison_type ~= 0 then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37077"))
    return false
  end
  local level_title = client_player:QueryProp("LevelTitle")
  local learn_job = client_player:QueryProp("HasLearnJob")
  if "title001" == level_title or "title002" == level_title and learn_job ~= 1 then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37060"))
    return false
  end
  local fresh_man = client_player:QueryProp("FreshManProtect")
  if 0 < fresh_man then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37060"))
    return false
  end
  local in_arena = client_player:QueryProp("PKMode")
  if PKMODE_ARENA == in_arena then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37086"))
    return false
  end
  local guild_war_side = client_player:QueryProp("GuildWarSide")
  if guild_war_side ~= 0 then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37070"))
    return false
  end
  local in_schoo_fight = client_player:QueryProp("IsInSchoolFight")
  if 1 == in_schoo_fight then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37211"))
    return false
  end
  local battle_state = client_player:QueryProp("BattlefieldState")
  if STATE_WAIT_RESPOND == battle_state or STATE_WAIT_ENTER == battle_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37211"))
    return false
  end
  if STATE_ALREADY_ENTER == battle_state then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37058"))
    return false
  end
  local run_away = nx_function("find_buffer", client_player, "buff_battlefield_runaway")
  if run_away then
    lbl_reason.Text = nx_widestr(gui.TextManager:GetText("37208"))
    return false
  end
  return true
end
function find_tree_item(tree, find_info)
  local root_node = tree.RootNode
  if not nx_is_valid(root_node) then
    return nil
  end
  return find_node(root_node, find_info)
end
function find_node(root_node, find_info)
  local node_list = root_node:GetNodeList()
  for i, node in ipairs(node_list) do
    if nx_find_custom(node, "id") and node.id == find_info then
      return node
    else
      local node_find = find_node(node, find_info)
      if nx_is_valid(node_find) then
        return node_find
      end
    end
  end
  return nil
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,wodezhanchang03,zhanchangjj04")
end
function on_btn_vs_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local node = form.tree_guan.SelectNode
  if not (nx_is_valid(node) and nx_find_custom(node, "id")) or not nx_find_custom(node, "rule") then
    return
  end
  local playtype = get_playtype_by_mapid(node.id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_battlefield\\form_battlefield_self_score", true)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_self_score", "request_score", nx_int(playtype))
  form.Visible = true
  form:Show()
end
function open_form()
  local show = on_is_show_form()
  if show == true then
    util_auto_show_hide_form(FORM_BATTLEFIELD_JOIN)
  end
end
function on_is_show_form()
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return false
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local can_show = false
  local power_level = player:QueryProp("PowerLevel")
  if 5 < power_level then
    can_show = true
  else
    local taskid = {
      1233,
      1245,
      1412,
      1261,
      1420,
      1277,
      1281,
      1293
    }
    for i = 1, 8 do
      local completed = taskmgr:CompletedByRec(nx_string(taskid[i]))
      if 1 == completed then
        can_show = true
      end
    end
  end
  return can_show
end
function get_playtype_by_mapid(map_id)
  for i = 1, table.getn(PLAY_GMP_MAPID) do
    if nx_string(map_id) == nx_string(PLAY_GMP_MAPID[i]) then
      return PLAY_GMP
    end
  end
  for i = 1, table.getn(PLAY_MYZ_MAPID) do
    if nx_string(map_id) == nx_string(PLAY_MYZ_MAPID[i]) then
      return PLAY_MYZ
    end
  end
  return nil
end
