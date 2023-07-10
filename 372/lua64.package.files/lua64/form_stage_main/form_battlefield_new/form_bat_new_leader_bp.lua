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
local GuDianClientMsg_RequestCanSelectSkill, GuDianClientMsg_RequestOwnSkill
local GuDianClientMsg_SaveEquip = 1
local GuDianClientMsg_SaveChannels = 2
local GuDianClientMsg_SaveNeiGong, GuDianClientMsg_AddSkill, GuDianClientMsg_DelateSkill
local CLIENT_SUB_SAVE_BP_TAOLU = 507
local CLIENT_SUB_REQUEST_OPEN_FORM = 510
local CLIENT_SUB_DEL_BP_TAOLU = 514
local CLIENT_SUB_IS_TEAM_LEADER = 516
local CLIENT_SUB_REC_BP_TL = 517
local BP_COUNT = 3
local FORM_NAME = "form_stage_main\\form_battlefield_new\\form_bat_new_leader_BP"
local wuxue_file = "share\\War\\GuDianNew\\gudian_ui_wuxue.ini"
local wuxue_prop_file = "share\\War\\GuDianNew\\gudian_ui_wuxue_prop.ini"
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
  self.sl_node = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_wuxue_num(form)
  init_wuxue_data(form)
  custom_request_is_leader()
  form.cbtn_wuxue_type_nei.Checked = true
  form.cbtn_wuxue_type_wai.Checked = true
  form.btn_del_1.Visible = false
  form.btn_del_2.Visible = false
  form.btn_del_3.Visible = false
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function open_form_test()
  open_form(50)
end
function open_form(...)
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_NAME, true)
  end
  form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = arg[1]
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:UnRegister(nx_current(), "update_left_time", form)
    game_timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.left_time = form.left_time - 1
  if nx_int(form.left_time) <= nx_int(0) then
    local game_timer = nx_value("timer_game")
    if nx_is_valid(game_timer) then
      game_timer:UnRegister(nx_current(), "update_left_time", form)
    end
    form:Close()
  else
    form.lbl_1.Text = nx_widestr(form.left_time)
  end
end
function close_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  on_main_form_close(form)
end
function custom_request_is_leader()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_IS_TEAM_LEADER))
end
function rec_is_Leader(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local is_leader = arg[1]
  if nx_int(is_leader) == nx_int(0) then
    form.btn_del_1.Visible = false
    form.btn_del_2.Visible = false
    form.btn_del_3.Visible = false
    form.btn_forb.Visible = false
    form.btn_recommend.Visible = true
  elseif nx_int(is_leader) == nx_int(1) then
    form.btn_del_1.Visible = true
    form.btn_del_2.Visible = true
    form.btn_del_3.Visible = true
    form.btn_forb.Visible = true
    form.btn_recommend.Visible = false
  end
  form.lbl_7.Text = nx_widestr(nx_string(arg[2]))
end
function on_btn_recommend_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.select_wuxue_id) == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_REC_BP_TL), nx_string(form.select_wuxue_id))
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
    form.rbtn_wuxue_1.Checked = true
  end
  gsb.IsEditMode = false
end
function on_btn_forb_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.select_wuxue_id) == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_SAVE_BP_TAOLU), nx_string(form.select_wuxue_id))
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
function updata_bp_wuxue_info(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gb = form.groupbox_bp
  if not nx_is_valid(gb) then
    return
  end
  form.btn_del_1.Visible = false
  form.btn_del_2.Visible = false
  form.btn_del_3.Visible = false
  form.btn_del_1.wuxue_config = ""
  form.btn_del_2.wuxue_config = ""
  form.btn_del_3.wuxue_config = ""
  form.lbl_bp_wx_1.Text = ""
  form.lbl_bp_wx_2.Text = ""
  form.lbl_bp_wx_3.Text = ""
  for i = 1, form.wuxue_num do
    local gsb = form.groupscrollbox_8
    local rbtn = gsb:Find(nx_string("rbtn_wuxue_") .. nx_string(i))
    if not nx_is_valid(form) then
      return
    end
    rbtn.Enabled = true
  end
  for i = 1, #arg do
    local lbl_wuxue_name = "lbl_bp_wx_" .. nx_string(i)
    local lbl_wuxue = gb:Find(nx_string(lbl_wuxue_name))
    local btn_del_name = "btn_del_" .. nx_string(i)
    local btn_del = gb:Find(nx_string(btn_del_name))
    if not nx_is_valid(lbl_wuxue) then
      return
    end
    if not nx_is_valid(btn_del) then
      return
    end
    btn_del.Visible = true
    local wuxue_config = arg[i]
    btn_del.wuxue_config = arg[i]
    lbl_wuxue.Text = util_text(nx_string(wuxue_config))
    forb_wx_btn(wuxue_config)
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
    end
  end
end
function on_btn_del_bp_click(btn)
  if not nx_find_custom(btn, "wuxue_config") then
    return
  end
  local wuxue_str = nx_string(btn.wuxue_config)
  if wuxue_str == "" then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_WAR), nx_int(CLIENT_SUB_DEL_BP_TAOLU), nx_string(wuxue_str))
end
function a(b)
  nx_msgbox(nx_string(b))
end
