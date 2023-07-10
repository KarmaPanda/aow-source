require("util_gui")
require("util_functions")
require("form_stage_main\\form_wuxue\\form_wuxue_util")
require("form_stage_main\\form_kof\\kof_util")
local FORM_NAME = "form_stage_main\\form_kof\\form_kof_apply"
local rbtn_wuxue_str = "rbtn_wuxue_"
local wuxue_file = "share\\War\\NewBalanceWar\\new_balance_war_ui_wuxue.ini"
local wuxue_prop_file = "share\\War\\NewBalanceWar\\new_balance_war_wuxue_bank.ini"
local kof_rule_file = "share\\War\\Kof\\KofRule.ini"
local ARRAY_NAME_RULE = "array_kof_rule_"
local ARRAY_NAME_WUXUE = "array_kof_wuxue_"
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
  self.sl_node = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.week_kill = 0
  form.week_damage = 0
  form.week_sp_nums = 0
  form.joins_max = 0
  form.rule = -1
  form.wuxue_limit = 1
  form.wuxue_sel = 2
  load_ini(form)
  init_ig(form)
  init_tg_rank_score(form)
  form.cbtn_wuxue_type_nei.Checked = true
  form.cbtn_wuxue_type_wai.Checked = true
  custom_kof(CTS_SUB_KOF_GET_PLAYER_INFO)
  form.rbtn_1.Checked = true
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  stop_rank_rock(self)
  nx_destroy(self)
end
function init_ig(form)
  local ItemsQuery = nx_value("ItemQuery")
  local ig_photo_1 = ItemsQuery:GetItemPropByConfigID(form.imagegrid_1.DataSource, "Photo")
  form.imagegrid_1:AddItem(0, ig_photo_1, form.imagegrid_1.DataSource, 1, 0)
  local ig_photo_2 = ItemsQuery:GetItemPropByConfigID(form.imagegrid_2.DataSource, "Photo")
  form.imagegrid_2:AddItem(0, ig_photo_2, form.imagegrid_2.DataSource, 1, 0)
  local ig_photo_3 = ItemsQuery:GetItemPropByConfigID(form.imagegrid_3.DataSource, "Photo")
  form.imagegrid_3:AddItem(0, ig_photo_3, form.imagegrid_3.DataSource, 1, 0)
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_close_click(btn)
  close_form()
end
function on_imagegrid_mousein_grid(grid, index)
  local config = grid.DataSource
  nx_execute("tips_game", "show_tips_by_config", config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    form.gb_3.Visible = false
    form.gb_4.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = true
    form.gb_3.Visible = false
    form.gb_4.Visible = false
  end
end
function on_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = false
    form.gb_3.Visible = true
    form.gb_4.Visible = false
  end
end
function on_rbtn_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = false
    form.gb_3.Visible = false
    form.gb_4.Visible = true
  end
end
function on_btn_set_click(btn)
  nx_execute("form_stage_main\\form_battlefield_new\\form_bat_new_power_set", "open_form")
end
function on_btn_entry_click(btn)
  nx_execute("form_stage_main\\form_battlefield\\form_battlefield_balance", "custom_entre_cross_war")
end
function on_btn_apply_click(btn)
  custom_kof(CTS_SUB_KOF_APPLY)
end
function update_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local score = nx_number(arg[1])
  local win = nx_number(arg[2])
  local kill = nx_number(arg[3])
  local damage = nx_number(arg[4])
  local sp_nums = nx_number(arg[5])
  local joins = nx_number(arg[6])
  local is_cross = nx_number(arg[7])
  local joins_total = nx_number(arg[8])
  local win_total = nx_number(arg[9])
  local kill_total = nx_number(arg[10])
  local damage_total = nx_number(arg[11])
  form.lbl_joins_total.Text = nx_widestr(joins_total)
  form.lbl_win_total.Text = nx_widestr(win_total)
  form.lbl_kill_total.Text = nx_widestr(kill_total)
  form.lbl_damage_total.Text = nx_widestr(fix_damage(damage_total))
  win = math.min(win, 1)
  kill = math.min(kill, form.week_kill)
  damage = math.min(damage, form.week_damage)
  sp_nums = math.min(sp_nums, form.week_sp_nums)
  if win == -1 then
    win = 1
  end
  if kill == -1 then
    kill = form.week_kill
  end
  if damage == -1 then
    damage = form.week_damage
  end
  if sp_nums == -1 then
    sp_nums = form.week_sp_nums
  end
  form.lbl_score.Text = nx_widestr(score)
  form.lbl_score_level.BackImage = get_score_image(score)
  form.lbl_week_1.Text = nx_widestr(nx_string(win) .. "/" .. nx_string(1))
  form.lbl_week_2.Text = nx_widestr(nx_string(kill) .. "/" .. nx_string(form.week_kill))
  form.lbl_week_3.Text = nx_widestr(fix_damage(damage)) .. nx_widestr("/") .. nx_widestr(fix_damage(form.week_damage))
  form.lbl_week_4.Text = nx_widestr(nx_string(sp_nums) .. "/" .. nx_string(form.week_sp_nums))
  form.lbl_joins.Text = nx_widestr(nx_string(joins) .. "/" .. nx_string(form.joins_max))
  if win == 1 then
    form.lbl_week_1.ForeColor = "255,0,255,0"
  end
  if kill == form.week_kill then
    form.lbl_week_2.ForeColor = "255,0,255,0"
  end
  if damage == form.week_damage then
    form.lbl_week_3.ForeColor = "255,0,255,0"
  end
  if sp_nums == form.week_sp_nums then
    form.lbl_week_4.ForeColor = "255,0,255,0"
  end
  if form.joins_max - joins == 0 then
    form.lbl_joins.ForeColor = "255,255,0,0"
  end
  if is_cross == 1 then
    form.btn_apply.Visible = true
    form.btn_set.Visible = true
    form.btn_entry.Visible = false
  else
    form.btn_apply.Visible = false
    form.btn_set.Visible = true
    form.btn_entry.Visible = true
  end
end
function fix_damage(damage)
  return util_format_string("ui_newguildinterface_text", nx_int(damage / 10000))
end
function load_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Kof\\Kof.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("property")
  form.week_kill = nx_number(ini:ReadInteger(sec_index, "week_kill", 0))
  form.week_damage = nx_number(ini:ReadInteger(sec_index, "week_damage", 0))
  form.week_sp_nums = nx_number(ini:ReadInteger(sec_index, "week_sp_nums", 0))
  form.joins_max = nx_number(ini:ReadInteger(sec_index, "joins_max", 0))
end
function update_rule(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local rule = nx_number(arg[1])
  form.rule = rule
  load_wuxue_ini(form, rule)
  init_wuxue_data(form)
end
function update_rank_test()
  update_rank("ng_1,ng_2", "ng_3,ng_4", "wx_3,wx_4", "wx_1,wx_2")
end
function update_rank(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local ng_sel = nx_string(arg[1])
  local ng_win = nx_string(arg[2])
  local wx_sel = nx_string(arg[3])
  local wx_win = nx_string(arg[4])
  clear_rank(form)
  add_rank(form, "ui_kof_rank_title_1", ng_sel)
  add_rank(form, "ui_kof_rank_title_2", ng_win)
  add_rank(form, "ui_kof_rank_title_3", wx_sel)
  add_rank(form, "ui_kof_rank_title_4", wx_win)
  rank_rock(form)
end
function clear_rank(form)
  form.rank_nums = 0
  local gui = nx_value("gui")
  for i = 1, 4 do
    local gb_rank = form.gb_rank:Find("gb_rank_" .. nx_string(i))
    if nx_is_valid(gb_rank) then
      gui:Delete(gb_rank)
    end
    local rbtn_rank = form.gb_rank_rbtn:Find("rbtn_rank_" .. nx_string(i))
    if nx_is_valid(rbtn_rank) then
      gui:Delete(rbtn_rank)
    end
  end
  form.gb_rank.Visible = false
end
function add_rank(form, title, rank_info)
  if rank_info == "" or rank_info == nil then
    return
  end
  form.gb_rank.Visible = true
  form.rank_nums = form.rank_nums + 1
  local index = form.rank_nums
  local rbtn_rank = create_ctrl("RadioButton", "rbtn_rank_" .. nx_string(index), form.rbtn_rank_mod, form.gb_rank_rbtn)
  rbtn_rank.DataSource = nx_string(index)
  rbtn_rank.Top = 0
  rbtn_rank.Left = 5 + (index - 1) * (rbtn_rank.Width + 5)
  nx_bind_script(rbtn_rank, nx_current())
  nx_callback(rbtn_rank, "on_checked_changed", "on_rbtn_rank_checked_changed")
  local gb_rank = create_ctrl("GroupBox", "gb_rank_" .. nx_string(index), form.gb_rank_mod, form.gb_rank)
  gb_rank.Left = 0
  gb_rank.Top = 0
  local lbl_rank_title = create_ctrl("Label", "lbl_rank_title_" .. nx_string(index), form.lbl_rank_title_mod, gb_rank)
  local tg_rank = create_ctrl("Grid", "tg_rank_" .. nx_string(index), form.tg_rank_mod, gb_rank)
  lbl_rank_title.Text = nx_widestr(util_text(title))
  local tab_info = util_split_string(rank_info, ",")
  for i = 1, #tab_info do
    local name = tab_info[i]
    local row = tg_rank:InsertRow(-1)
    tg_rank:SetGridText(row, 0, nx_widestr(i))
    tg_rank:SetGridText(row, 1, nx_widestr(util_text(name)))
  end
end
function on_rbtn_rank_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local index = nx_number(rbtn.DataSource)
    for i = 1, form.rank_nums do
      local gb_rank = form.gb_rank:Find("gb_rank_" .. nx_string(i))
      if i == index then
        gb_rank.Visible = true
      else
        gb_rank.Visible = false
      end
    end
    stop_rank_rock(form)
    start_rank_rock(form)
  end
end
function rank_rock(form)
  if form.rank_nums <= 1 then
    return
  end
  local rbtn_rank = form.gb_rank_rbtn:Find("rbtn_rank_" .. nx_string(1))
  rbtn_rank.Checked = true
  start_rank_rock(form)
end
function start_rank_rock(form)
  local game_timer = nx_value("timer_game")
  game_timer:Register(20000, -1, nx_current(), "rank_rock_timer", form, -1, -1)
end
function stop_rank_rock(form)
  local game_timer = nx_value("timer_game")
  game_timer:UnRegister(nx_current(), "rank_rock_timer", form)
end
function rank_rock_timer(form)
  for i = 1, form.rank_nums do
    local rbtn_rank = form.gb_rank_rbtn:Find("rbtn_rank_" .. nx_string(i))
    if rbtn_rank.Checked then
      local new_index = math.mod(i, form.rank_nums) + 1
      local new_rbtn = form.gb_rank_rbtn:Find("rbtn_rank_" .. nx_string(new_index))
      new_rbtn.Checked = true
      return
    end
  end
end
function init_tg_rank_score(form)
  form.tg_rank_score:SetColTitle(0, nx_widestr(util_text("ui_kof_score_rank_1")))
  form.tg_rank_score:SetColTitle(1, nx_widestr(util_text("ui_kof_score_rank_2")))
  form.tg_rank_score:SetColTitle(2, nx_widestr(util_text("ui_kof_score_rank_3")))
end
function update_rank_score(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local ori_server_id = nx_number(arg[1])
  local info = nx_widestr(arg[2])
  form.tg_rank_score:ClearRow()
  local tab_score = util_split_wstring(info, ",")
  for i = 1, #tab_score / 3 do
    local name = tab_score[(i - 1) * 3 + 1]
    local score = tab_score[(i - 1) * 3 + 2]
    local server_id = nx_number(tab_score[(i - 1) * 3 + 3])
    local row = form.tg_rank_score:InsertRow(-1)
    form.tg_rank_score:SetGridText(row, 0, nx_widestr(i))
    form.tg_rank_score:SetGridText(row, 1, nx_widestr(name))
    form.tg_rank_score:SetGridText(row, 2, nx_widestr(score))
    local is_self = false
    if is_main_player(name) then
      is_self = true
    else
      local tab_name = util_split_wstring(name, "@")
      local ori_name = tab_name[1]
      if is_main_player(ori_name) and ori_server_id == server_id then
        is_self = true
      end
    end
    if is_self then
      form.tg_rank_score:SetGridForeColor(row, 0, "255,255,204,0")
      form.tg_rank_score:SetGridForeColor(row, 1, "255,255,204,0")
      form.tg_rank_score:SetGridForeColor(row, 2, "255,255,204,0")
    end
  end
end
function load_wuxue_ini(form, rule)
  local array_rule = get_array_rule(rule)
  local common_array = nx_value("common_array")
  common_array:RemoveArray(array_rule)
  common_array:AddArray(array_rule, form, 600, true)
  local ini_rule = nx_execute("util_functions", "get_ini", kof_rule_file)
  if not nx_is_valid(ini_rule) then
    return
  end
  local ini_wuxue = nx_execute("util_functions", "get_ini", wuxue_file)
  if not nx_is_valid(ini_wuxue) then
    return
  end
  local ini_wuxue_prop = nx_execute("util_functions", "get_ini", wuxue_prop_file)
  if not nx_is_valid(ini_wuxue_prop) then
    return
  end
  local tab_wuxue = {}
  local sec_index_wuxue = ini_wuxue:FindSectionIndex("ui_balance_war_wuxue")
  local item_count_wuxue = ini_wuxue:GetSectionItemCount(sec_index_wuxue)
  for i = 0, item_count_wuxue - 1 do
    local wuxue_str = ini_wuxue:GetSectionItemValue(sec_index_wuxue, i)
    local tab_wuxue_str = util_split_string(wuxue_str, ";")
    local wuxue = tab_wuxue_str[1]
    tab_wuxue[wuxue] = wuxue_str
  end
  local array_wuxue = get_array_wuxue()
  common_array:RemoveArray(array_wuxue)
  common_array:AddArray(array_wuxue, form, 600, true)
  local sec_index = ini_rule:FindSectionIndex(nx_string(rule))
  if sec_index < 0 then
    return
  end
  local item_count = ini_rule:GetSectionItemCount(sec_index)
  form.wuxue_limit = ini_rule:ReadInteger(sec_index, "same_wuxue", 0)
  form.wuxue_sel = ini_rule:ReadInteger(sec_index, "sel_wuxue", 0)
  form.lbl_same_wuxue.Text = nx_widestr(form.wuxue_limit)
  form.lbl_sel_wuxue.Text = nx_widestr(form.wuxue_sel)
  for i = 2, item_count - 1 do
    local wuxue = ini_rule:GetSectionItemValue(sec_index, i)
    common_array:AddChild(array_rule, nx_string(i), wuxue)
    common_array:AddChild(array_wuxue, wuxue, tab_wuxue[wuxue])
  end
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
  local rbtn_wuxue_mod = form.rbtn_wuxue_mod
  local common_array = nx_value("common_array")
  local rule_list = common_array:GetChildList(get_array_rule(form.rule))
  for i = 1, table.getn(rule_list) do
    local wuxue = rule_list[i]
    local rbtn_wuxue = create_ctrl("RadioButton", rbtn_wuxue_str .. wuxue, rbtn_wuxue_mod, gsb)
    rbtn_wuxue.Height = 30
    rbtn_wuxue.Width = 95
    local wuxue_configid, wuxue_actionid, wuxue_nei_wai_type, wuxue_total_type, wuxue_sub_type = get_wuxue_configid(wuxue)
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
    rbtn_wuxue.sels = 0
    if i == 1 then
      rbtn_wuxue.Checked = true
    end
  end
  gsb.IsEditMode = false
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
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "add_weapon", form, action_id)
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
function get_wuxue_configid(wuxue)
  local common_array = nx_value("common_array")
  local wuxue_config = common_array:FindChild(get_array_wuxue(), wuxue)
  local wuxue_list = util_split_string(wuxue_config, ";")
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
  if sl_node ~= nil and nx_is_valid(sl_node) and nx_find_custom(sl_node, "main_type") then
    sift_main_type = sl_node.main_type
  end
  local show_index = 0
  local common_array = nx_value("common_array")
  local rule_list = common_array:GetChildList(get_array_rule(form.rule))
  for i = 1, table.getn(rule_list) do
    local wuxue = rule_list[i]
    local rbtn_name = rbtn_wuxue_str .. wuxue
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
  local common_array = nx_value("common_array")
  local rule_list = common_array:GetChildList(get_array_rule(form.rule))
  for i = 1, table.getn(rule_list) do
    local wuxue = rule_list[i]
    local rbtn_name = rbtn_wuxue_str .. wuxue
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
function get_array_rule(rule)
  return ARRAY_NAME_RULE .. nx_string(rule)
end
function get_array_wuxue()
  return ARRAY_NAME_WUXUE
end
