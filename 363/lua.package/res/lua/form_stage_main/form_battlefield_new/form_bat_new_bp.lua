require("util_gui")
require("util_functions")
require("util_static_data")
require("custom_sender")
require("share\\client_custom_define")
require("form_stage_main\\form_attribute_mall\\form_attribute_shop")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("form_stage_main\\form_tvt\\define")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
local CLIENT_SUB_SAVE_OPEN_FORM = 505
local CLIENT_SUB_SAVE_PLANE_NAME = 506
local CLIENT_SUB_ALL_BP_TAOLU = 508
local CLIENT_SUB_REQUEST_TEAM_INFO = 509
local MAX_CHANNELS_NUM = 8
local TOTAL_MEMBER_NUM = 12
local CLIENT_SUB_SAVE_TL_PLANE = 503
local CLIENT_SUB_DEL_TL_PLANE = 504
local CLIENT_SUB_REQUEST_ENTER_WAR = 511
local power_count = 5
local FORM_NAME = "form_stage_main\\form_battlefield_new\\form_bat_new_BP"
local wuxue_file = "share\\War\\GuDianNew\\gudian_ui_wuxue.ini"
local wuxue_prop_file = "share\\War\\GuDianNew\\gudian_ui_wuxue_prop.ini"
local zhunagbei_tips = {
  "ui_balance_scuffle_zhuangbei_chisong_content",
  "ui_balance_scuffle_zhuangbei_tuohui_content",
  "ui_balance_scuffle_zhuangbei_jiuxian_content",
  "ui_balance_scuffle_zhuangbei_danran_content",
  "ui_balance_scuffle_zhuangbei_yongse_content",
  "ui_balance_scuffle_wuqi_chisong_content",
  "ui_balance_scuffle_wuqi_tuohui_content",
  "ui_balance_scuffle_wuqi_jiuxian_content",
  "ui_balance_scuffle_wuqi_danran_content",
  "ui_balance_scuffle_wuqi_yongse_content",
  "ui_balance_scuffle_shangyi_chisong_content",
  "ui_balance_scuffle_shangyi_tuohui_content",
  "ui_balance_scuffle_shangyi_jiuxian_content",
  "ui_balance_scuffle_shangyi_danran_content",
  "ui_balance_scuffle_shangyi_yongse_content"
}
NODE_PROP = {
  first = {
    ForeColor = "255,255,249,194",
    NodeBackImage = "gui\\special\\war_scuffle\\2_btn1_out.png",
    NodeFocusImage = "gui\\special\\war_scuffle\\2_btn1_on.png",
    NodeSelectImage = "gui\\special\\war_scuffle\\2_btn1_down.png",
    ItemHeight = 30,
    TextOffsetX = 10,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,255,249,194",
    NodeBackImage = "gui\\special\\war_scuffle\\2_btn1_out.png",
    NodeFocusImage = "gui\\special\\war_scuffle\\2_btn1_on.png",
    NodeSelectImage = "gui\\special\\war_scuffle\\2_btn1_down.png",
    ItemWidth = 20,
    ItemHeight = 30,
    TextOffsetX = 10,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  third = {
    ForeColor = "255,255,255,255",
    NodeBackImage = "gui\\guild\\guild_battle\\C_btn1_out.png",
    NodeFocusImage = "gui\\guild\\guild_battle\\C_btn1_on.png",
    NodeSelectImage = "gui\\guild\\guild_battle\\C_btn1_down.png",
    ItemWidth = 56,
    ItemHeight = 28,
    TextOffsetX = 5,
    TextOffsetY = 6,
    Font = "font_treeview"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.wuxue_num = 0
  self.plane_index = 0
  self.sl_node = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_wuxue_num(form)
  init_wuxue_data(form)
  clear_taolu_lbl(form)
  init_member_info_ctrl(form)
  init_member_info(form)
  custom_request_team_info(form)
  custom_request_BP_info(form)
  form.btn_show_side.Visible = false
  form.btn_plane_1.Checked = true
end
function on_update_lbl_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = form.left_time - 1
  if nx_int(form.left_time) <= nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "on_update_lbl_time", form)
    end
    form:Close()
  else
    form.lbl_1.Text = nx_widestr(form.left_time)
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function open_form_test()
  open_form(60)
end
function open_form(...)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = arg[1]
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "on_update_lbl_time", form)
    game_timer:Register(1000, -1, nx_current(), "on_update_lbl_time", form, -1, -1)
  end
end
function close_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function cuntom_request_plane_name(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_PLANE_NAME), nx_int(0), nx_int(1))
end
function custom_request_team_info(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQUEST_TEAM_INFO), nx_int(0), nx_int(1))
end
function custom_request_BP_info(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_ALL_BP_TAOLU))
end
function init_member_info_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  local gsb_self = form.groupbox_self
  local gsb_enemy = form.groupbox_enemy
  local gb_mod = form.groupbox_play_mod
  local lbl_player_bg_mod = form.lbl_player_bg_mod
  local lbl_player_name_mod = form.lbl_player_name_mod
  local lbl_player_skill_1_mod = form.lbl_player_skill_1_mod
  local lbl_player_skill_2_mod = form.lbl_player_skill_2_mod
  local btn_delete_skill_1_mod = form.btn_del_skill_3
  local btn_delete_skill_2_mod = form.btn_del_skill_4
  local gb_mod_str = "gb_player_"
  local lbl_player_bg_str = "lbl_player_bg_"
  local lbl_player_name_str = "lbl_player_name_"
  local lbl_player_skill_1_str = "lbl_player_skill_1_"
  local lbl_player_skill_2_str = "lbl_player_skill_2_"
  local btn_delete_skill_1_str = "btn_detlete_skill_1_"
  local btn_delete_skill_2_str = "btn_detlete_skill_2_"
  for i = 1, nx_number(TOTAL_MEMBER_NUM) do
    local gsb
    if nx_int(i) <= nx_int(nx_number(TOTAL_MEMBER_NUM) / 2) then
      gsb = gsb_self
    else
      gsb = gsb_enemy
    end
    gsb.IsEditMode = true
    local gb = create_ctrl("GroupBox", nx_string(gb_mod_str) .. nx_string(i), gb_mod, gsb)
    local lbl_player_bg = create_ctrl("Label", nx_string(lbl_player_bg_str) .. nx_string(i), lbl_player_bg_mod, gb)
    local lbl_player_name = create_ctrl("Label", nx_string(lbl_player_name_str) .. nx_string(i), lbl_player_name_mod, gb)
    local lbl_player_skill_1 = create_ctrl("Label", nx_string(lbl_player_skill_1_str) .. nx_string(i), lbl_player_skill_1_mod, gb)
    local lbl_player_skill_2 = create_ctrl("Label", nx_string(lbl_player_skill_2_str) .. nx_string(i), lbl_player_skill_2_mod, gb)
    lbl_player_skill_1.ForeColor = "255,255,0,0"
    lbl_player_skill_2.ForeColor = "255,255,0,0"
    lbl_player_bg.Visible = false
    gb.Top = math.fmod(i - 1, TOTAL_MEMBER_NUM / 2) * (gb.Height + 10) + 10
    gb.Left = 2
    gsb.IsEditMode = true
  end
end
function init_member_info(form)
end
function init_wuxue_num(form)
  local ini = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_wuxue")
  if sec_count < 0 then
    return ""
  end
  form.wuxue_num = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_tree_wuxue_node(form)
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_wuxue_type:CreateRootNode(nx_widestr(util_text("ui_guild_battle_wuxue_type")))
  form.tree_wuxue_type:BeginUpdate()
  set_node_prop(root, "first")
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuDianNew\\gudian_ui_power_tree.ini")
  if not nx_is_valid(ini) then
    return
  end
  local main_count = ini:GetSectionCount()
  for i = 0, main_count - 1 do
    local main_name = ini:GetSectionByIndex(i)
    local main_root = root:CreateNode(nx_widestr(util_text(main_name)))
    set_node_prop(main_root, "second")
    main_root.main_type = nx_number(i) + 1
    local sub_count = ini:GetSectionItemCount(i)
    for j = 0, sub_count - 1 do
      local sub_name = ini:GetSectionItemValue(i, j)
      local sub_root = main_root:CreateNode(nx_widestr(util_text(sub_name)))
      set_node_prop(sub_root, "third")
      sub_root.main_type = nx_number(i) + 1
      sub_root.sub_type = nx_number(j) + 1
    end
  end
  root.Expand = true
  form.tree_wuxue_type:EndUpdate()
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function init_wuxue_data(form)
  if not nx_is_valid(form) then
    return
  end
  init_tree_wuxue_node(form)
  local gsb = form.groupscrollbox_8
  local rbtn_wuxue_str = "rbtn_wuxue_"
  local rbtn_wuxue_mod = form.rbtn_wuxue_mod
  for i = 1, form.wuxue_num do
    local rbtn_wuxue = create_ctrl("RadioButton", nx_string(rbtn_wuxue_str) .. nx_string(i), rbtn_wuxue_mod, gsb)
    rbtn_wuxue.Height = 30
    rbtn_wuxue.Width = 95
    local wuxue_configid, wuxue_actionid, wuxue_nei_wai_type, wuxue_total_type, wuxue_sub_type = get_wuxue_configid(i)
    rbtn_wuxue.configid = wuxue_configid
    rbtn_wuxue.actionid = wuxue_actionid
    rbtn_wuxue.wuxue_nei_wai_type = nx_number(wuxue_nei_wai_type)
    rbtn_wuxue.main_type = nx_number(wuxue_total_type)
    rbtn_wuxue.sub_type = nx_number(wuxue_sub_type)
    local nAttack, nExist, nControl, nOperation, strDefine, nColour, wuji = get_taolu_prop(rbtn_wuxue.configid, 1)
    rbtn_wuxue.wuji_mark = wuji
    if nx_int(rbtn_wuxue.wuji_mark) == nx_int(1) then
      rbtn_wuxue.NormalImage = "gui\\special\\war_scuffle\\2_btn_cy_out_wuji.png"
      rbtn_wuxue.FocusImage = "gui\\special\\war_scuffle\\2_btn_cy_on_wuji.png"
      rbtn_wuxue.CheckedImage = "gui\\special\\war_scuffle\\2_btn_cy_down_wuji.png"
    end
    nx_bind_script(rbtn_wuxue, nx_current())
    nx_callback(rbtn_wuxue, "on_checked_changed", "on_rbtn_can_select_skill_checked_changed")
    rbtn_wuxue.Text = util_text(nx_string(wuxue_configid))
    rbtn_wuxue.Top = math.floor((i - 1) / 5) * (rbtn_wuxue.Height + 5) + 5
    rbtn_wuxue.Left = math.fmod(i - 1, 5) * (rbtn_wuxue.Width + 10) + 5
  end
  form.rbtn_wuxue_1.Checked = true
  form.cbtn_wuxue_type_nei.Checked = true
  form.cbtn_wuxue_type_wai.Checked = true
  gsb.IsEditMode = false
  init_side_jm_data(form)
end
function init_side_jm_data(form)
  local gsb = form.groupbox_side_jm
  gsb.IsEditMode = true
  local jm_side_gb_mod = form.groupbox_side_jm_mod
  local jm_side_grid_mod = form.imagegrid_side_jm
  local jm_side_lbl_mod = form.lbl_side_jm
  local jm_side_gb_mod_str = "jm_side_gb_"
  local jm_side_grid_str = "jm_side_grid_"
  local jm_side_lbl_str = "jm_side_lbl_"
  for i = 1, MAX_CHANNELS_NUM do
    local gb = create_ctrl("GroupBox", nx_string(jm_side_gb_mod_str) .. nx_string(i), jm_side_gb_mod, gsb)
    local imagegrid_jm = create_ctrl("ImageGrid", nx_string(jm_side_grid_str) .. nx_string(i), jm_side_grid_mod, gb)
    local lbl_jm_name = create_ctrl("Label", nx_string(jm_side_lbl_str) .. nx_string(i), jm_side_lbl_mod, gb)
    nx_bind_script(imagegrid_jm, nx_current())
    nx_callback(imagegrid_jm, "on_lost_capture", "on_imagegrid_side_lost_capture")
    nx_callback(imagegrid_jm, "on_get_capture", "on_imagegrid_side_get_capture")
    gb.Top = 20 + (gb.Height + 2) * (i - 1)
    gb.Left = 10
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
  nx_bind_script(form.imagegrid_side_ng, nx_current())
  nx_callback(form.imagegrid_side_ng, "on_mousein_grid", "on_imagegrid_neigong_mousein_grid")
  nx_callback(form.imagegrid_side_ng, "on_mouseout_grid", "on_imagegrid_neigong_mouseout_grid")
end
function on_imagegrid_neigong_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "neigong_config") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local neigong_config = grid.neigong_config
  local ng_level, buff_level, wu_xing = get_neigong_max_level(nx_string(neigong_config))
  local neigong = nx_execute("tips_game", "get_tips_ArrayList")
  neigong.ConfigID = nx_string(neigong_config)
  neigong.ItemType = 1002
  neigong.Level = nx_int(ng_level)
  neigong.MaxLevel = nx_int(ng_level)
  neigong.StaticData = nx_int(grid.static_data)
  neigong.BufferLevel = nx_int(buff_level)
  neigong.WuXing = nx_int(wu_xing)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", neigong, x, y, 32, 32, form, false)
end
function get_neigong_max_level(strConfig)
  if strConfig == nil or strConfig == "" then
    return 0, 0
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuDianNew\\gudian_ui_neigong_maxlevel.ini")
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(strConfig)
  if sec_index < 0 then
    return 0, 0
  end
  local max_level = ini:ReadInteger(sec_index, "value", 0)
  local buff_level = ini:ReadInteger(sec_index, "buff_level", 0)
  local wux_xing = ini:ReadInteger(sec_index, "define_deviation", 0)
  return max_level, buff_level, wux_xing
end
function on_imagegrid_neigong_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_imagegrid_side_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_imagegrid_side_get_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "jm_id") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local jingmai_id = grid.jm_id
  local jingmai = nx_execute("tips_game", "get_tips_ArrayList")
  jingmai.ConfigID = nx_string(jingmai_id)
  jingmai.ItemType = 1003
  jingmai.Level = 216
  jingmai.StaticData = nx_int(grid.static_data)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", jingmai, x, y, 32, 32, form, false)
end
function on_rbtn_can_select_skill_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local wuxue_id = rbtn.configid
  form.select_wuxue_id = wuxue_id
  local nAttack, nExist, nControl, nOperation, strDefine, nColour = get_taolu_prop(wuxue_id, 1)
  if nAttack == "" then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_6), 2)
    end
    return
  end
  form.lbl_wuxue_title.Text = nx_widestr(util_text(wuxue_id))
  set_star(form.groupbox_attack, nAttack)
  set_star(form.groupbox_defend, nExist)
  set_star(form.groupbox_recover, nControl)
  set_star(form.groupbox_operate, nOperation)
  form.mltbox_site.HtmlText = nx_widestr(util_text(strDefine))
  local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(wuxue_id)
  if nx_int(neigong_wuxing) > nx_int(0) and nx_int(neigong_wuxing) < nx_int(6) then
    form.mltbox_ng.HtmlText = nx_widestr(util_text("desc_luandou_neigong_define_" .. nx_string(neigong_wuxing)))
  end
  if nx_int(jingmai_wuxing) > nx_int(0) and nx_int(jingmai_wuxing) < nx_int(6) then
    form.mltbox_jm.HtmlText = nx_widestr(util_text("desc_luandou_jingmai_define_" .. nx_string(jingmai_wuxing)))
  end
  local strSkill = get_taolu_prop(wuxue_id, 2)
  local skill_list = util_split_string(strSkill, ";")
  local grid = form.imagegrid_skill
  if not nx_is_valid(grid) then
    return
  end
  grid:Clear()
  for j = 1, #skill_list do
    if skill_list[j] ~= "" then
      local photo = skill_static_query_by_id(nx_string(skill_list[j]), "Photo")
      grid:AddItem(nx_int(j - 1), photo, util_text(skill_list[j]), 1, -1)
    end
  end
  local action_id = nx_string(rbtn.actionid)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "show_item_action", form, action_id, WUXUE_SHOW_SKILL, true)
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strTaolu = form.select_wuxue_id
  if nx_string(strTaolu) == nx_string("") then
    return
  end
  local strSkill = get_taolu_prop(strTaolu, 2)
  local skill_list = util_split_string(strSkill, ";")
  local skill_id = skill_list[index + 1]
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local staticdata = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_id, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(skill_id)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function set_star(groupbox, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox:DeleteAll()
  for i = 1, num do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
end
function get_neigong_and_jingmai_devation(strWuXue)
  if strWuXue == nil or strWuXue == "" then
    return 0, 0
  end
  local ini = nx_null()
  ini = nx_execute("util_functions", "get_ini", wuxue_prop_file)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(strWuXue))
  if sec_index < 0 then
    return 0, 0
  end
  local neigong_deviation = ini:ReadInteger(sec_index, "deviation_neigong", 0)
  local jingmai_deviation = ini:ReadInteger(sec_index, "deviation_jingmai", 0)
  return neigong_deviation, jingmai_deviation
end
function get_wuxue_configid(index)
  local ini = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_wuxue")
  if sec_count < 0 then
    return ""
  end
  local wuxue = ini:ReadString(sec_count, nx_string(index), "")
  local wuxue_list = util_split_string(wuxue, ";")
  local wuxue_id = wuxue_list[1]
  local wuxue_actionid = wuxue_list[2]
  local wuxue_nei_wai_type = wuxue_list[3]
  local wuxue_total_type = wuxue_list[4]
  local wuxue_sub_type = wuxue_list[5]
  return wuxue_id, wuxue_actionid, wuxue_nei_wai_type, wuxue_total_type, wuxue_sub_type
end
function get_taolu_prop(taolu_id, nIndex)
  if taolu_id == nil or taolu_id == "" then
    return ""
  end
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(2) then
    return ""
  end
  local ini = nx_null()
  ini = nx_execute("util_functions", "get_ini", wuxue_prop_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(taolu_id)
  if sec_index < 0 then
    return ""
  end
  if nx_int(nIndex) == nx_int(2) then
    local strSkill = ini:ReadString(sec_index, "1", "")
    return strSkill
  end
  local nAttack = ini:ReadInteger(sec_index, "attack", 0)
  local nExist = ini:ReadInteger(sec_index, "exist", 0)
  local nControl = ini:ReadInteger(sec_index, "control", 0)
  local nOperation = ini:ReadInteger(sec_index, "operation", 0)
  local strDefine = ini:ReadString(sec_index, "definition", "")
  local nColour = ini:ReadInteger(sec_index, "colourset", "")
  local wuji = ini:ReadInteger(sec_index, "wuji", "")
  return nAttack, nExist, nControl, nOperation, strDefine, nColour, wuji
end
function sift(form)
  local wuxue_gsb = form.groupscrollbox_8
  wuxue_gsb.IsEditMode = true
  local sl_node = form.sl_node
  local sift_main_type = 0
  if sl_node ~= nil and nx_find_custom(sl_node, "main_type") then
    sift_main_type = sl_node.main_type
  end
  local show_index = 0
  for i = 1, form.wuxue_num do
    local rbtn_name = "rbtn_wuxue_" .. nx_string(i)
    local rbtn = form.groupscrollbox_8:Find(nx_string(rbtn_name))
    if not nx_is_valid(rbtn) then
      return
    end
    rbtn.Visible = false
    local is_show = false
    if rbtn.wuxue_nei_wai_type == 1 then
      if form.cbtn_wuxue_type_nei.Checked then
        is_show = true
      end
    elseif rbtn.wuxue_nei_wai_type == 2 and form.cbtn_wuxue_type_wai.Checked then
      is_show = true
    end
    if rbtn.main_type ~= sift_main_type and sift_main_type ~= 0 then
      is_show = false
    end
    if is_show then
      show_index = show_index + 1
      rbtn.Visible = true
      rbtn.Top = math.floor((show_index - 1) / 5) * (rbtn.Height + 5) + 5
      rbtn.Left = math.fmod(show_index - 1, 5) * (rbtn.Width + 10) + 5
    end
  end
  wuxue_gsb.IsEditMode = false
  wuxue_gsb.Height = wuxue_gsb.Height
end
function on_cbtn_wuxue_type_checked_changed(cbtn)
  local form = cbtn.ParentForm
  sift(form)
end
function on_btn_power_set_again_click(btn)
  nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "open_form")
end
function on_tree_wuxue_type_select_changed(self, cur_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.sl_node = cur_node
  sift(form)
end
function on_btn_search_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wuxue_gsb = form.groupscrollbox_8
  wuxue_gsb.IsEditMode = true
  local show_index = 0
  for i = 1, form.wuxue_num do
    local rbtn_name = "rbtn_wuxue_" .. nx_string(i)
    local rbtn = form.groupscrollbox_8:Find(nx_string(rbtn_name))
    if not nx_is_valid(rbtn) then
      return
    end
    rbtn.Visible = false
    local is_show = false
    if 0 <= nx_function("ext_ws_find", nx_widestr(rbtn.Text), nx_widestr(form.ipt_search.Text)) then
      is_show = true
    end
    if is_show then
      show_index = show_index + 1
      rbtn.Visible = true
      rbtn.Top = math.floor((show_index - 1) / 5) * (rbtn.Height + 5) + 5
      rbtn.Left = math.fmod(show_index - 1, 5) * (rbtn.Width + 10) + 5
    end
  end
  wuxue_gsb.IsEditMode = false
  wuxue_gsb.Height = wuxue_gsb.Height
end
function on_btn_add_wuxue_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wuxue_str = form.select_wuxue_id
  if nx_string(wuxue_str) == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_TL_PLANE), nx_int(0), nx_string(wuxue_str))
end
function on_btn_delete_wuxue_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = btn.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_DEL_TL_PLANE), nx_int(0), nx_int(data))
end
function on_btn_delete_wuxue_click_2(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = btn.data
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_DEL_TL_PLANE), nx_int(0), nx_int(data))
end
function on_btn_plane_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.plane_index = btn.DataSource
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_OPEN_FORM), nx_int(btn.DataSource), nx_int(1))
end
function updata_player_tl_data_test()
  updata_player_tl_data("1", "CS_th_bhcs")
end
function updata_player_tl_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local player_name = arg[1]
  clear_taolu_lbl(form)
  local index = 1
  for i = 1, #arg - 1 do
    local strSkill = nx_string(arg[i + 1])
    if strSkill ~= "" and strSkill ~= nil then
      local lbl_name = "lbl_own_skill_" .. nx_string(index)
      local lbl = form.groupbox_side_skill:Find(nx_string(lbl_name))
      if nx_is_valid(lbl) then
        lbl.Text = util_text(strSkill)
        lbl.ForeColor = nx_string("255,197,184,159")
      end
      local btn = form.groupbox_side_skill:Find("btn_del_skill_" .. nx_string(i))
      if nx_is_valid(btn) then
        btn.Visible = true
      end
    end
    index = index + 1
  end
end
function show_team_select_wuxue_test()
  show_team_select_wuxue("\210\187", "CS_th_bhcs,CS_th_bhcs")
end
function show_team_select_wuxue(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local player_name = arg[1]
  local taolustr = arg[2]
  for i = 1, nx_number(TOTAL_MEMBER_NUM) do
    local gsb
    if nx_number(i) <= nx_number(TOTAL_MEMBER_NUM) / 2 then
      gsb = form.groupbox_self
    else
      gsb = form.groupbox_enemy
    end
    local gb_name = "gb_player_" .. nx_string(i)
    local lbl_bg_name = "lbl_player_bg_" .. nx_string(i)
    local lbl_player_name = "lbl_player_name_" .. nx_string(i)
    local lbl_skill_1_name = "lbl_player_skill_1_" .. nx_string(i)
    local lbl_skill_2_name = "lbl_player_skill_2_" .. nx_string(i)
    local gb = gsb:Find(nx_string(gb_name))
    if not nx_is_valid(gb) then
      return
    end
    local lbl_player = gb:Find(nx_string(lbl_player_name))
    local lbl_skill_1 = gb:Find(nx_string(lbl_skill_1_name))
    local lbl_skill_2 = gb:Find(nx_string(lbl_skill_2_name))
    if nx_is_valid(lbl_player) and nx_is_valid(lbl_skill_1) and nx_is_valid(lbl_skill_2) and nx_widestr(lbl_player.Text) == nx_widestr(player_name) then
      lbl_skill_1.Text = nx_widestr(util_text("ui_gudian2_shp_009"))
      lbl_skill_2.Text = nx_widestr(util_text("ui_gudian2_shp_010"))
      lbl_skill_1.ForeColor = "255,255,0,0"
      lbl_skill_2.ForeColor = "255,255,0,0"
      local temp_table = util_split_string(taolustr, ",")
      local count = table.getn(temp_table)
      if nx_int(count) == nx_int(1) then
        lbl_skill_1.Text = nx_widestr(util_text(temp_table[1]))
        lbl_skill_1.ForeColor = "255,204,204,204"
      elseif nx_int(count) == nx_int(2) then
        lbl_skill_1.Text = nx_widestr(util_text(temp_table[1]))
        lbl_skill_2.Text = nx_widestr(util_text(temp_table[2]))
        lbl_skill_1.ForeColor = "255,204,204,204"
        lbl_skill_2.ForeColor = "255,204,204,204"
      end
    end
  end
end
function clear_taolu_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_side_skill
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 2 do
    local lbl_name = "lbl_own_skill_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    if nx_is_valid(lbl) then
      lbl.Text = util_text("ui_choswar_interface_005")
      lbl.ForeColor = nx_string("255,255,0,0")
    end
    local btn = gbox:Find("btn_del_skill_" .. nx_string(i))
    if nx_is_valid(btn) then
      btn.Visible = false
    end
  end
end
function updata_player_equip_data_test()
  updata_player_equip_data("1,2,5")
end
function updata_player_equip_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  clear_equip_lbl(form)
  local strEquip = nx_string(arg[2])
  local equip_list = util_split_string(strEquip, ",")
  if nx_int(#equip_list) ~= nx_int(3) then
    return
  end
  form.lbl_equip.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[1]))
  form.lbl_equip.ForeColor = nx_string("255,197,184,159")
  form.lbl_equip.HintText = util_text(zhunagbei_tips[nx_number(equip_list[1])])
  form.lbl_wuqi.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[2]))
  form.lbl_wuqi.ForeColor = nx_string("255,197,184,159")
  form.lbl_wuqi.HintText = util_text(zhunagbei_tips[nx_number(5) + nx_number(equip_list[2])])
  form.lbl_shangyi.Text = nx_widestr(util_text("luandou_zhaungbei_" .. equip_list[3]))
  form.lbl_shangyi.ForeColor = nx_string("255,197,184,159")
  form.lbl_shangyi.HintText = util_text(zhunagbei_tips[nx_number(10) + nx_number(equip_list[3])])
end
function clear_equip_lbl(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_equip.Text = util_text("ui_choswar_interface_005")
  form.lbl_equip.ForeColor = nx_string("255,255,0,0")
  form.lbl_wuqi.Text = util_text("ui_choswar_interface_005")
  form.lbl_wuqi.ForeColor = nx_string("255,255,0,0")
  form.lbl_shangyi.Text = util_text("ui_choswar_interface_005")
  form.lbl_shangyi.ForeColor = nx_string("255,255,0,0")
end
function updata_player_jm_data_test()
  updata_player_jm_data("11,12,13,14,15,16,17,18")
end
function updata_player_jm_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local strChannels = nx_string(arg[2])
  if nx_string(strChannels) == "" then
    local gbox = form.groupbox_side_jm
    for i = 1, 8 do
      local gb_jm = gbox:Find(nx_string("jm_side_gb_") .. nx_string(i))
      if not nx_is_valid(gb_jm) then
        return
      end
      local grid_jm = gb_jm:Find(nx_string("jm_side_grid_") .. nx_string(i))
      local lbl_jm = gb_jm:Find(nx_string("jm_side_lbl_") .. nx_string(i))
      grid_jm.jm_id = ""
      local photo, static_data = query_photo_by_configid(nx_string(grid_jm.jm_id), nx_int(1))
      grid_jm:DelItem(0)
      grid_jm.static_data = static_data
      lbl_jm.Text = util_text("ui_choswar_interface_005")
      lbl_jm.ForeColor = nx_string("255,255,0,0")
    end
  end
  local channels_list = util_split_string(strChannels, ",")
  if nx_int(#channels_list) ~= nx_int(8) then
    return
  end
  local gbox = form.groupbox_side_jm
  for i = 1, #channels_list do
    local gb_jm = gbox:Find(nx_string("jm_side_gb_") .. nx_string(i))
    if not nx_is_valid(gb_jm) then
      return
    end
    local jm_index = nx_number(channels_list[i])
    local grid_jm = gb_jm:Find(nx_string("jm_side_grid_") .. nx_string(i))
    local lbl_jm = gb_jm:Find(nx_string("jm_side_lbl_") .. nx_string(i))
    grid_jm.jm_id = get_jingmai_id(nx_string(jm_index))
    local photo, static_data = query_photo_by_configid(nx_string(grid_jm.jm_id), nx_int(1))
    grid_jm:AddItem(0, photo, nx_widestr(jm_id), 1, -1)
    grid_jm.static_data = static_data
    lbl_jm.Text = util_text(grid_jm.jm_id)
    lbl_jm.ForeColor = nx_string("255,197,184,159")
  end
end
function get_jingmai_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuDianNew\\gudian_ui_jingmai.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  local jingmai_id = ini:ReadString(sec_count, nx_string(index), "")
  return jingmai_id
end
function query_photo_by_configid(config_id, item_type)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local file_name = ""
  if nx_int(item_type) == nx_int(1) then
    file_name = "share\\Skill\\JingMai\\jingmai.ini"
  elseif nx_int(item_type) == nx_int(2) then
    file_name = "share\\Skill\\NeiGong\\neigong.ini"
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager(file_name)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(config_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  IniManager:UnloadIniFromManager(file_name)
  local photo = ""
  if nx_int(item_type) == nx_int(1) then
    photo = data_query:Query(9, nx_int(static_data), "Photo")
  elseif nx_int(item_type) == nx_int(2) then
    photo = data_query:Query(26, nx_int(static_data), "Photo")
  end
  return photo, static_data
end
function updata_player_ng_data_test()
  updata_player_ng_data(1)
end
function updata_player_ng_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local grid_ng = form.imagegrid_side_ng
  local lbl_ng = form.lbl_side_ng_name
  local nNeiGongIndex = nx_int(arg[2])
  if nx_int(nNeiGongIndex) == nx_int(0) then
    local strConfig = ""
    local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(strConfig), nx_int(2))
    grid_ng.neigong_config = strConfig
    grid_ng.static_data = neigong_static_data
    grid_ng:DelItem(0)
    form.lbl_side_ng_name.Text = util_text("ui_choswar_interface_005")
    form.lbl_side_ng_name.ForeColor = nx_string("255,255,0,0")
    return
  end
  local strConfig = get_ng_config_id(nNeiGongIndex)
  local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(strConfig), nx_int(2))
  grid_ng.neigong_config = strConfig
  grid_ng.static_data = neigong_static_data
  grid_ng:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
  form.lbl_side_ng_name.Text = util_text(grid_ng.neigong_config)
  form.lbl_side_ng_name.ForeColor = nx_string("255,197,184,159")
end
function updata_player_pn_data_test()
  updata_player_pn_data("")
end
function updata_player_pn_data(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_4
  for i = 1, power_count do
    local btn = gb:Find("btn_plane_" .. nx_string(i))
    if not nx_is_valid(btn) then
      return
    end
    if nx_widestr(arg[i + 1]) ~= nx_widestr(nx_string("")) then
      btn.Text = nx_widestr(arg[i + 1])
    else
      btn.Text = nx_widestr(nx_string(util_text("ui_nbw_plane_name")) .. nx_string(i))
    end
  end
end
function get_ng_config_id(index)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\GuDianNew\\gudian_ui_neigong.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local neigong = ini:ReadString(sec_count, nx_string(index), "")
  local neigong_list = util_split_string(neigong, ";")
  local neigong_id = neigong_list[1]
  return neigong_id
end
function show_team_self_name_info_test()
  show_team_self_name_info("\198\223", "\176\203", "\190\197", "\202\174", "\202\174\210\187", "\202\174\182\254")
end
function show_team_self_name_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  local self_name = client_role:QueryProp("Name")
  local gsb_self = form.groupbox_self
  for i = 1, #arg do
    local player_name = nx_widestr(arg[i])
    local gb_name = "gb_player_" .. nx_string(i)
    local lbl_bg_name = "lbl_player_bg_" .. nx_string(i)
    local lbl_player_name = "lbl_player_name_" .. nx_string(i)
    local gb = gsb_self:Find(nx_string(gb_name))
    if not nx_is_valid(gb) then
      return
    end
    local lbl_bg = gb:Find(nx_string(lbl_bg_name))
    local lbl_player = gb:Find(nx_string(lbl_player_name))
    if nx_is_valid(lbl_bg) and nx_is_valid(lbl_player) then
      lbl_player.Text = nx_widestr(player_name)
      if nx_widestr(self_name) == nx_widestr(player_name) then
        lbl_bg.Visible = true
      end
    end
  end
end
function show_team_enemy_name_info_test()
  show_team_enemy_name_info("\210\187", "\182\254", "\200\253", "\209\207\192\215", "\206\229")
end
function show_team_enemy_name_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local client = nx_value("game_client")
  local client_role = client:GetPlayer()
  if not nx_is_valid(client_role) then
    return
  end
  local self_name = client_role:QueryProp("Name")
  local gsb_enemy = form.groupbox_enemy
  for i = 1, #arg do
    local player_name = nx_widestr(arg[i])
    local gb_name = "gb_player_" .. nx_string(i + 6)
    local lbl_bg_name = "lbl_player_bg_" .. nx_string(i + 6)
    local lbl_player_name = "lbl_player_name_" .. nx_string(i + 6)
    local gb = gsb_enemy:Find(nx_string(gb_name))
    if not nx_is_valid(gb) then
      return
    end
    local lbl_bg = gb:Find(nx_string(lbl_bg_name))
    local lbl_player = gb:Find(nx_string(lbl_player_name))
    if nx_is_valid(lbl_bg) and nx_is_valid(lbl_player) then
      lbl_player.Text = nx_widestr(player_name)
      if nx_widestr(self_name) == nx_widestr(player_name) then
        lbl_bg.Visible = true
      end
    end
  end
end
function updata_self_bp_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_BP
  if not nx_is_valid(gb) then
    return
  end
  for i = 1, #arg do
    local lbl_bp_name = "lbl_self_bp_tl_" .. nx_string(i)
    local lbl_self_bp = gb:Find(nx_string(lbl_bp_name))
    if not nx_is_valid(lbl_self_bp) then
      return
    end
    lbl_self_bp.Text = nx_widestr(util_text(arg[i]))
    forb_wx_btn(arg[i])
  end
end
function forb_wx_btn(wuxue_config)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gsb = form.groupscrollbox_8
  for i = 1, form.wuxue_num do
    local rbtn = gsb:Find(nx_string("rbtn_wuxue_") .. nx_string(i))
    if not nx_is_valid(form) then
      return
    end
    if nx_string(wuxue_config) == nx_string(rbtn.configid) then
      rbtn.Enabled = false
    else
    end
  end
end
function updata_enemy_bp_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_BP
  if not nx_is_valid(gb) then
    return
  end
  for i = 1, #arg do
    local lbl_bp_name = "lbl_enemy_bp_tl_" .. nx_string(i)
    local lbl_enemy_bp = gb:Find(nx_string(lbl_bp_name))
    if not nx_is_valid(lbl_enemy_bp) then
      return
    end
    lbl_enemy_bp.Text = nx_widestr(util_text(arg[i]))
    forb_wx_btn(arg[i])
  end
end
function updata_left_select_num(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local wx_str = nx_string(arg[1])
  local left_num = nx_int(arg[2])
  local gb = form.groupscrollbox_8
  local rbtn_str = "rbtn_wuxue_"
  for i = 1, nx_number(form.wuxue_num) do
    local rbtn_name = "rbtn_wuxue_" .. nx_string(i)
    local rbtn = gb:Find(nx_string(rbtn_name))
    if not nx_is_valid(rbtn) then
      return
    end
    if nx_string(rbtn.configid) == nx_string(wx_str) then
      if nx_int(rbtn.wuji_mark) == nx_int(1) then
        if left_num == nx_int(0) then
          rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_wuji_0.png"
          rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_wuji_0.png"
          rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_wuji_0.png"
        elseif left_num == nx_int(1) then
          rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_wuji_1.png"
          rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_wuji_1.png"
          rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_wuji_1.png"
        elseif left_num == nx_int(2) then
          rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_wuji_2.png"
          rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_wuji_2.png"
          rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_wuji_2.png"
        end
      elseif left_num == nx_int(0) then
        rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_0.png"
        rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_0.png"
        rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_0.png"
      elseif left_num == nx_int(1) then
        rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_1.png"
        rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_1.png"
        rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_1.png"
      elseif left_num == nx_int(2) then
        rbtn.NormalImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_out_2.png"
        rbtn.FocusImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_on_2.png"
        rbtn.CheckedImage = "gui\\special\\battlefiled_balance_new\\2_btn_cy_down_2.png"
      end
    end
  end
end
function on_btn_show_hide_side_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local data = btn.DataSource
  if nx_int(data) == nx_int(1) then
    form.btn_show_side.Visible = false
    form.groupbox_side.Visible = true
  end
  if nx_int(data) == nx_int(0) then
    form.btn_show_side.Visible = true
    form.groupbox_side.Visible = false
  end
end
function on_btn_enter_click(btn)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REQUEST_ENTER_WAR), nx_int(form.plane_index), nx_int(0))
end
function a(b)
  nx_msgbox(nx_string(b))
end
