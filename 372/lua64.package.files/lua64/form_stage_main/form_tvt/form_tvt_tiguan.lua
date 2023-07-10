require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
local FORM_TVT_TIGUAN = "form_stage_main\\form_tvt\\form_tvt_tiguan"
local FORM_TVT_TIGUAN_GUAN = "form_stage_main\\form_tvt\\form_tvt_tiguan_guan"
local TIAOZHAN_PHOTO = {
  "gui\\special\\tiguan\\tz_1.png",
  "gui\\special\\tiguan\\tz_2.png"
}
local NAME_COLOR = {
  "255,40,132,0",
  "255,0,138,110",
  "255,0,169,175",
  "255,23,127,153",
  "255,28,97,145",
  "255,37,61,115"
}
local SORT_COLOR = {
  "255,142,13,0",
  "255,235,72,22",
  "255,174,106,0"
}
local TIAOZHAN_COUNT_MAX = 6
local CHANGGUAN_RELATION_INI = "ini\\ui\\tiguan\\tiguan_relation.ini"
function main_form_init(self)
  self.Fixed = false
  self.opentime = 0
  self.reccount = 0
  self.guan_id_sel = 0
  self.switch = 0
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.gbox_boss.Visible = false
  self.gbox_guan.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 1
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  show_guan_tree(self)
  show_guan_list(self)
  local now_time = nx_function("ext_get_tickcount") / 1000
  if nx_number(self.opentime) == 0 or nx_number(now_time - self.opentime) >= nx_number(REFRESH_TIME) then
    self.opentime = now_time
    self.reccount = 0
    self.ani_connect.Visible = true
    self.ani_connect.PlayMode = 0
    self.lbl_connect.Visible = true
    nx_execute("custom_sender", "custom_get_tiguan_all_info", nx_object(player.Ident))
  end
end
function main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_look_guan_click(self)
  local form = self.ParentForm
  form.gbox_boss.Visible = false
  form.gbox_guan.Visible = true
end
function on_btn_look_boss_click(self)
  local form = self.ParentForm
  form.gbox_boss.Visible = true
  form.gbox_guan.Visible = false
end
function on_btn_look_rank_click(self)
end
function on_cbtn_sel_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(self, "guan_id") then
    return 0
  end
  if not self.Checked then
    if form.guan_id_sel == self.guan_id then
      self.Checked = true
    end
    return 0
  end
  if form.guan_id_sel ~= self.guan_id and nx_find_custom(form, "cbtn_sel_" .. form.guan_id_sel) then
    local cbtn_sel = nx_custom(form, "cbtn_sel_" .. form.guan_id_sel)
    cbtn_sel.Enabled = false
    cbtn_sel.Checked = false
    cbtn_sel.Enabled = true
  end
  form.guan_id_sel = self.guan_id
  nx_execute(FORM_TVT_TIGUAN_GUAN, "show_guan_info_form", form.guan_id_sel)
end
function on_cbtn_box_checked_changed(self)
  if not nx_find_custom(self, "guan_id") then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_BOX_OPEN), 0, nx_int(self.guan_id))
end
function on_lbl_relation_get_capture(self)
  if not nx_find_custom(self, "karma") then
    return 0
  end
  local tips_text = get_desc_by_id(get_group_karma_text(self.karma))
  nx_execute("tips_game", "show_text_tip", nx_widestr(tips_text), self.AbsLeft + self.Width, self.AbsTop, 150, self.ParentForm)
end
function on_lbl_relation_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_tree_guan_select_changed(self, cur_node, old_node)
  local form = self.ParentForm
  local node = self.SelectNode
  if not nx_find_custom(cur_node, "isrefresh") then
    return 0
  end
  if cur_node.isrefresh then
    local game_client = nx_value("game_client")
    if nx_is_valid(game_client) then
      local player = game_client:GetPlayer()
      if nx_is_valid(player) then
        nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(player.Ident), nx_int(cur_node.cgid))
      end
    end
  end
  show_guan_boss(form)
end
function on_btn_switch_guan_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = btn.ParentForm
  local guan_id = nx_number(form.guan_id_sel)
  if guan_id <= 0 then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("30344"))
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local guan_name = gui.TextManager:GetText("ui_tiguan_name_" .. nx_string(guan_id))
  local text = gui.TextManager:GetFormatText("ui_tiguan_move", guan_name)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_SWITCH), nx_int(guan_id))
  end
end
function show_guan_list(form)
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  form.gpsb_guans:DeleteAll()
  local gbox_guans = nx_null()
  local section_count = guan_ui_ini:GetSectionCount()
  for i = 1, section_count do
    local guan_id = guan_ui_ini:GetSectionByIndex(i - 1)
    local gbox_guan = nx_null()
    if i % 2 ~= 0 then
      gbox_guans = create_ctrl("GroupBox", "gbox_guans_" .. guan_id, form.gbox_guans, form.gpsb_guans)
      gbox_guan = create_ctrl("GroupBox", "gbox_guan_" .. guan_id, form.gbox_guan1, gbox_guans)
    else
      gbox_guan = create_ctrl("GroupBox", "gbox_guan_" .. guan_id, form.gbox_guan2, gbox_guans)
    end
    local lbl_baifu = create_ctrl("Label", "lbl_baifu_" .. guan_id, form.lbl_guan_baifu, gbox_guan)
    local grid_baifu = create_ctrl("ImageGrid", "grid_baifu_" .. guan_id, form.grid_guan_baifu, gbox_guan)
    local cbtn_sel = create_ctrl("CheckButton", "cbtn_sel_" .. guan_id, form.cbtn_guan_sel, gbox_guan)
    local cbtn_box = create_ctrl("CheckButton", "cbtn_box_" .. guan_id, form.cbtn_guan_box, gbox_guan)
    local lbl_box = create_ctrl("Label", "lbl_box_" .. guan_id, form.lbl_guan_box, gbox_guan)
    local lbl_relation = create_ctrl("Label", "lbl_relation_" .. guan_id, form.lbl_guan_relation, gbox_guan)
    nx_bind_script(cbtn_box, nx_current())
    nx_callback(cbtn_box, "on_checked_changed", "on_cbtn_box_checked_changed")
    nx_bind_script(cbtn_sel, nx_current())
    nx_callback(cbtn_sel, "on_checked_changed", "on_cbtn_sel_checked_changed")
    nx_bind_script(lbl_relation, nx_current())
    nx_callback(lbl_relation, "on_get_capture", "on_lbl_relation_get_capture")
    nx_callback(lbl_relation, "on_lost_capture", "on_lbl_relation_lost_capture")
    cbtn_sel.guan_id = guan_id
    cbtn_box.guan_id = guan_id
    local group_id = guan_ui_ini:ReadString(i - 1, "Force", "")
    if check_have_relation(group_id) then
      local karma = get_group_karma(group_id)
      lbl_relation.BackImage = get_karma_icon(karma)
      lbl_relation.karma = karma
      lbl_relation.Visible = true
    else
      lbl_relation.Visible = false
    end
    local lbl_sort = create_ctrl("Label", "lbl_sort_" .. guan_id, form.lbl_guan_sort, gbox_guan)
    local lbl_name = create_ctrl("Label", "lbl_name_" .. guan_id, form.lbl_guan_name, gbox_guan)
    local lbl_desc = create_ctrl("Label", "lbl_desc_" .. guan_id, form.lbl_guan_desc, gbox_guan)
    lbl_sort.Text = get_desc_by_id(guan_ui_ini:ReadString(i - 1, "Sort", ""))
    lbl_name.Text = get_desc_by_id(guan_ui_ini:ReadString(i - 1, "Name", ""))
    lbl_desc.Text = get_desc_by_id(guan_ui_ini:ReadString(i - 1, "GeneralDesc", ""))
    local is_open = guan_ui_ini:ReadString(i - 1, "IsOpen", "1")
    if is_open == "0" then
      gbox_guan.BackImage = "gui\\special\\tiguan\\guan_back_hui.png"
      lbl_baifu.Visible = true
    else
      lbl_baifu.Visible = false
    end
    if 1 <= i and i <= 3 then
      lbl_sort.ForeColor = SORT_COLOR[nx_number(i)]
    end
    lbl_name.ForeColor = get_color_by_level(guan_ui_ini:ReadString(i - 1, "Level", ""))
  end
  form.gpsb_guans:ResetChildrenYPos()
end
function refresh_guan_list(form)
  local node_tab = form.tree_guan.RootNode:GetNodeList()
  for i = 1, table.getn(node_tab) do
    local guan_node = node_tab[i]
    if nx_find_custom(guan_node, "guan_id") then
      local guan_id = guan_node.guan_id
      if nx_find_custom(form, "grid_baifu_" .. guan_id) and nx_find_custom(form, "lbl_box_" .. guan_id) and nx_find_custom(form, "cbtn_box_" .. guan_id) then
        local grid_baifu = nx_custom(form, "grid_baifu_" .. guan_id)
        local lbl_box = nx_custom(form, "lbl_box_" .. guan_id)
        local cbtn_box = nx_custom(form, "cbtn_box_" .. guan_id)
        grid_baifu:Clear()
        for j = 1, nx_number(guan_node.limitsucceed) do
          local index = j - 1 + TIAOZHAN_COUNT_MAX - nx_number(guan_node.limitsucceed)
          if j <= nx_number(guan_node.todaysucceed) then
            grid_baifu:AddItem(nx_int(index), TIAOZHAN_PHOTO[1], "", 1, -1)
          else
            grid_baifu:AddItem(nx_int(index), TIAOZHAN_PHOTO[2], "", 1, -1)
          end
        end
        if nx_number(guan_node.todaysucceed) < nx_number(guan_node.limitsucceed) then
          cbtn_box.Visible = true
          lbl_box.Visible = false
          cbtn_box.Enabled = false
        elseif nx_number(guan_node.todayrepick) == 1 then
          cbtn_box.Visible = false
          lbl_box.Visible = true
        else
          cbtn_box.Enabled = true
          cbtn_box.Visible = true
          lbl_box.Visible = false
        end
      end
    end
  end
  if form.switch == 1 then
    form.btn_switch_guan.Enabled = true
  else
    form.btn_switch_guan.Enabled = false
  end
end
function show_guan_tree(form)
  local gui = nx_value("gui")
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local guan_share_ini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(guan_ui_ini) or not nx_is_valid(guan_share_ini) then
    return 0
  end
  local root = form.tree_guan:CreateRootNode(nx_widestr(""))
  local section_count = guan_ui_ini:GetSectionCount()
  for i = 1, section_count do
    local guan_id = guan_ui_ini:GetSectionByIndex(i - 1)
    local name_id = guan_ui_ini:ReadString(i - 1, "Name", "")
    local guan_node = root:CreateNode(get_desc_by_id(name_id))
    if nx_is_valid(guan_node) then
      set_node_prop(guan_node, 1)
      guan_node.guan_id = guan_id
      guan_node.isrefresh = false
      guan_node.entercount = 0
      guan_node.limitcount = 0
      guan_node.todaysucceed = 0
      guan_node.limitsucceed = 0
      guan_node.todayrepick = 0
      guan_node.npcdata = ""
      local index = guan_share_ini:FindSectionIndex(guan_id)
      if 0 <= index then
        guan_node.limitcount = guan_share_ini:ReadString(index, "LimitCountPerDay", "")
        guan_node.limitsucceed = guan_share_ini:ReadString(index, "LimitSuccessPerDay", "")
      end
    end
  end
  if not nx_is_valid(form.tree_guan.SelectNode) and 0 < root:GetNodeCount() then
    local node_tab = root:GetNodeList()
    form.tree_guan.SelectNode = node_tab[1]
  end
  root.Expand = true
end
function show_guan_boss(form)
  local gui = nx_value("gui")
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local tg_mgr = nx_value("tiguan_manager")
  if not nx_is_valid(tg_mgr) then
    return 0
  end
  local node = form.tree_guan.SelectNode
  if not nx_is_valid(node) then
    return 0
  end
  if not nx_find_custom(node, "guan_id") then
    return 0
  end
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local index = guan_ui_ini:FindSectionIndex(nx_string(node.guan_id))
  if index < 0 then
    return 0
  end
  local info_list = tg_mgr:GetKillNpcInfo(nx_int(node.guan_id), nx_string(node.npcdata))
  if table.getn(info_list) % 2 ~= 0 then
    return 0
  end
  local info_tab = {}
  for i = 1, table.getn(info_list) / 2 do
    info_tab[nx_string(info_list[i * 2 - 1])] = nx_number(info_list[i * 2])
  end
  local npc_list = guan_ui_ini:GetItemValueList(index, "Npc")
  for i = 1, table.getn(npc_list) do
    local data_tab = util_split_string(nx_string(npc_list[i]), ",")
    if table.getn(data_tab) ~= 3 then
      return 0
    end
    if nx_number(data_tab[3]) == 1 then
      local npc_id = nx_string(data_tab[1])
      local title = nx_string(data_tab[2])
      local photo = get_large_photo(itemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo")))
      local npc_name = gui.TextManager:GetText(npc_id)
    end
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function get_desc_by_id(text_id)
  local gui = nx_value("gui")
  return gui.TextManager:GetText(nx_string(text_id))
end
function get_color_by_level(level)
  local count = table.getn(NAME_COLOR)
  if nx_number(level) <= 0 or count < nx_number(level) then
    return NAME_COLOR[count]
  end
  return NAME_COLOR[nx_number(level)]
end
function get_karma_icon(karma_value)
  local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex("Karma")
  if sec_index < 0 then
    return ""
  end
  local data_tab = ini:GetItemValueList(sec_index, nx_string("r"))
  for i = 1, table.getn(data_tab) do
    local info_tab = util_split_string(data_tab[i], ",")
    if nx_int(info_tab[1]) <= nx_int(karma_value) and nx_int(info_tab[2]) >= nx_int(karma_value) then
      return nx_string(info_tab[4])
    end
  end
  return ""
end
function get_npc_karma(npc_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("rec_npc_relation") then
    return 0
  end
  local row = client_player:FindRecordRow("rec_npc_relation", 0, npc_id, 0)
  if row < 0 then
    return 0
  end
  return nx_int(client_player:QueryRecord("rec_npc_relation", row, 2))
end
function get_group_karma(group_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("GroupKarmaRec") then
    return 0
  end
  local row = client_player:FindRecordRow("GroupKarmaRec", 0, nx_int(group_id), 0)
  if row < 0 then
    return 0
  end
  return nx_int(client_player:QueryRecord("GroupKarmaRec", row, 1))
end
function check_have_relation(group_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord("GroupKarmaRec") then
    return false
  end
  local row = client_player:FindRecordRow("GroupKarmaRec", 0, nx_int(group_id), 0)
  if row < 0 then
    return false
  end
  return true
end
function get_group_karma_text(karma)
  local ini = nx_execute("util_functions", "get_ini", CHANGGUAN_RELATION_INI)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex("RelaTips")
  if index < 0 then
    return ""
  end
  local data_list = ini:GetItemValueList(index, "r")
  for i = 1, table.getn(data_list) do
    local data_tab = util_split_string(data_list[i], ",")
    if table.getn(data_tab) >= 3 and nx_number(data_tab[1]) <= nx_number(karma) and nx_number(data_tab[2]) >= nx_number(karma) then
      return data_tab[3]
    end
  end
  return ""
end
function show_tiguan_count(type, switch, ...)
  local gui = nx_value("gui")
  local guan_ui_ini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(guan_ui_ini) then
    return 0
  end
  local form = util_get_form(FORM_TVT_TIGUAN, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.switch = nx_number(switch)
  if not nx_is_valid(form.tree_guan.RootNode) then
    return 0
  end
  if nx_number(type) == LOOK_INFO_WIN_NPC then
    if table.getn(arg) < 4 then
      return 0
    end
    local index = guan_ui_ini:FindSectionIndex(nx_string(arg[1]))
    if index < 0 then
      return 0
    end
    local name_id = guan_ui_ini:ReadString(index, "Name", "")
    local guan_node = form.tree_guan.RootNode:FindNode(get_desc_by_id(name_id))
    if nx_is_valid(guan_node) then
      guan_node.isrefresh = true
      guan_node.entercount = nx_number(arg[3])
      guan_node.npcdata = nx_number(arg[4])
    end
  elseif nx_number(type) == LOOK_INFO_WIN_GUAN then
    if table.getn(arg) % 6 ~= 0 then
      return 0
    end
    for i = 1, table.getn(arg) / 6 do
      local index = guan_ui_ini:FindSectionIndex(nx_string(arg[i * 6 - 5]))
      if index < 0 then
        return 0
      end
      local name_id = guan_ui_ini:ReadString(index, "Name", "")
      local guan_node = form.tree_guan.RootNode:FindNode(get_desc_by_id(name_id))
      if nx_is_valid(guan_node) then
        guan_node.entercount = nx_number(arg[i * 6 - 2])
        guan_node.todaysucceed = nx_number(arg[i * 6 - 1])
        guan_node.todayrepick = nx_number(arg[i * 6 - 0])
      end
    end
    form.reccount = nx_number(form.reccount) + nx_number(table.getn(arg) / 6)
    if nx_number(form.tree_guan.RootNode:GetNodeCount()) <= nx_number(form.reccount) then
      form.ani_connect.Visible = false
      form.ani_connect.PlayMode = 2
      form.lbl_connect.Visible = false
    end
  end
  show_guan_boss(form)
  refresh_guan_list(form)
end
function open_form()
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(1))
end
function close_form()
  local form = nx_value(FORM_TVT_TIGUAN)
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_tvt_tiguan_form()
  local form = util_get_form(FORM_TVT_TIGUAN, true, false)
  if not nx_is_valid(form) then
    return 0
  end
  util_show_form(FORM_TVT_TIGUAN, true)
end
