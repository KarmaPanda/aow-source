require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
function main_form_init(self)
  self.Fixed = false
  self.opentime = 0
  self.reccount = 0
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 1
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  self.rbtn_zonglan.Checked = true
  self.gpb_zonglan.Visible = true
  self.gpb_xiangxi.Visible = false
  show_area_tree(self)
  show_guan_tree(self)
  local now_time = nx_function("ext_get_tickcount") / 1000
  if nx_int(self.opentime) == 0 or nx_int(now_time - self.opentime) >= nx_int(REFRESH_TIME) then
    self.opentime = now_time
    self.reccount = 0
    self.ani_connect.Visible = true
    self.ani_connect.PlayMode = 0
    self.lbl_connect.Visible = true
    nx_execute("custom_sender", "custom_get_tiguan_all_info", nx_object(player.Ident))
  end
end
function main_form_close(self)
  nx_execute("util_gui", "util_show_form", FORM_TIGUAN_MAIN, false)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    if self.DataSource == "1" then
      form.gpb_zonglan.Visible = true
      form.gpb_xiangxi.Visible = false
    elseif self.DataSource == "2" then
      form.gpb_zonglan.Visible = false
      form.gpb_xiangxi.Visible = true
    end
  end
end
function on_tree_area_select_changed(self, cur_node, old_node)
  local form = self.ParentForm
  if nx_is_valid(old_node) then
    old_node.scr_value = form.gpsb_cgs.VScrollBar.Value
  end
  show_area_data(form)
end
function on_tree_guan_select_changed(self, cur_node, old_node)
  local form = self.ParentForm
  local node = self.SelectNode
  if not nx_find_custom(cur_node, "type") then
    return 0
  end
  if cur_node.type == NODE_TYPE_CG then
    if not nx_find_custom(cur_node, "isrefresh") then
      return 0
    end
    if not cur_node.isrefresh then
      local game_client = nx_value("game_client")
      if nx_is_valid(game_client) then
        local player = game_client:GetPlayer()
        if nx_is_valid(player) then
          nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(player.Ident), nx_int(cur_node.cgid))
        end
      end
    end
  elseif cur_node.type == NODE_TYPE_NPC and nx_number(cur_node.count) <= -2 then
    local scrollvalue = form.tree_guan.VScrollBar.Value
    self.SelectNode = old_node
    form.tree_guan.VScrollBar.Value = scrollvalue
    play_sound(TIGUAN_SOUND[1])
    return 0
  end
  show_guan_data(form)
end
function on_tree_guan_expand_changed(self, node)
  local form = self.ParentForm
  if not node.Expand then
    return 0
  end
  if not nx_find_custom(node, "type") then
    return 0
  end
  if node.type == NODE_TYPE_CG then
    if not nx_find_custom(node, "isrefresh") then
      return 0
    end
    if not node.isrefresh then
      local game_client = nx_value("game_client")
      if nx_is_valid(game_client) then
        local player = game_client:GetPlayer()
        if nx_is_valid(player) then
          nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(player.Ident), nx_int(node.cgid))
        end
      end
    end
  end
  show_guan_data(self.ParentForm)
end
function on_btn_select_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  if not nx_find_custom(self, "cg_id") then
    return 0
  end
  local cg_name = gui.TextManager:GetText("ui_tiguan_name_" .. nx_string(self.cg_id))
  local cg_node = form.tree_guan.RootNode:FindNode(nx_widestr(cg_name))
  if nx_is_valid(cg_node) then
    form.rbtn_xiangxi.Checked = true
    form.tree_guan.SelectNode = cg_node
    cg_node.Expand = true
  end
end
function show_area_tree(form)
  local gui = nx_value("gui")
  local areaini = nx_execute("util_functions", "get_ini", CHANGGUAN_AREA_INI)
  if not nx_is_valid(areaini) then
    return 0
  end
  local root = form.tree_area:CreateRootNode(nx_widestr(""))
  local section_count = areaini:GetSectionCount()
  for i = 1, section_count do
    local area_id = areaini:GetSectionByIndex(i - 1)
    local cgs_id = areaini:ReadString(i - 1, "ChangGuan", "")
    local cgs_tab = util_split_string(nx_string(cgs_id), ",")
    local name = gui.TextManager:GetText(nx_string("ui_tiguan_difficult_" .. area_id))
    local info = "(0/" .. nx_string(table.getn(cgs_tab)) .. ")"
    local cg_area = root:CreateNode(name .. nx_widestr(info))
    if nx_is_valid(cg_area) then
      set_node_prop(cg_area, 1)
      cg_area.Mark = nx_int(area_id)
      cg_area.area_id = area_id
      cg_area.scr_value = 0
    end
  end
  if not nx_is_valid(form.tree_area.SelectNode) and 0 < root:GetNodeCount() then
    local node_tab = root:GetNodeList()
    form.tree_area.SelectNode = node_tab[1]
  end
  root.Expand = true
end
function show_guan_tree(form)
  local gui = nx_value("gui")
  local changguanini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local sharecgini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(changguanini) or not nx_is_valid(sharecgini) then
    return 0
  end
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local text = nx_execute("util_functions", "util_text", "ui_ChangGuan")
  local root = form.tree_guan:CreateRootNode(text)
  local section_count = changguanini:GetSectionCount()
  for i = 1, section_count do
    local cg_id = changguanini:GetSectionByIndex(i - 1)
    local cg_name = gui.TextManager:GetText("ui_tiguan_name_" .. cg_id)
    local cg_node = root:CreateNode(nx_widestr(cg_name))
    if nx_is_valid(cg_node) then
      set_node_prop(cg_node, 1)
      cg_node.ShowCoverImage = false
      cg_node.isrefresh = false
      cg_node.type = NODE_TYPE_CG
      cg_node.cgid = cg_id
      cg_node.count = 0
      cg_node.entercount = 0
      cg_node.photo = changguanini:ReadString(i - 1, "Photo", "")
      cg_node.camptype = changguanini:ReadString(i - 1, "CampType", "")
      cg_node.location = changguanini:ReadString(i - 1, "Location", "")
      cg_node.level = changguanini:ReadString(i - 1, "Level", "")
      local index = sharecgini:FindSectionIndex(nx_string(cg_id))
      if index < 0 then
        break
      end
      cg_node.minplayer = sharecgini:ReadString(index, "MinPlayerCount", "")
      cg_node.maxplayer = sharecgini:ReadString(index, "MaxPlayerCount", "")
      cg_node.limitcount = sharecgini:ReadString(index, "LimitCountPerDay", "")
      cg_node.condition = sharecgini:ReadString(index, "MemberConditionID", "")
      cg_node.difficult = sharecgini:ReadString(index, "Difficult", "")
    end
    local npc_list = changguanini:GetItemValueList(i - 1, "Npc")
    for j = 1, table.getn(npc_list) do
      local data_tab = util_split_string(nx_string(npc_list[j]), ",")
      if table.getn(data_tab) ~= 3 then
        return 0
      end
      if nx_number(data_tab[3]) == 1 then
        local npc_id = nx_string(data_tab[1])
        local title = nx_string(data_tab[2])
        local npc_name = gui.TextManager:GetText("ui_tiguan_npcname_" .. npc_id)
        local npc_node = cg_node:CreateNode(nx_widestr(npc_name))
        if nx_is_valid(npc_node) then
          set_node_prop(npc_node, 2)
          npc_node.ShowCoverImage = false
          npc_node.ForeColor = NODE_FORECOLOR_DISABLE
          npc_node.type = NODE_TYPE_NPC
          npc_node.npcid = npc_id
          npc_node.count = -2
          npc_node.photo = get_large_photo(itemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo")))
          npc_node.title = title
        end
      end
    end
  end
  if not nx_is_valid(form.tree_guan.SelectNode) and 0 < root:GetNodeCount() then
    local node_tab = root:GetNodeList()
    form.tree_guan.SelectNode = node_tab[1]
  end
  root.Expand = true
end
function show_area_data(form)
  local gui = nx_value("gui")
  for i = 1, AREA_CG_COUNT do
    local gpb_cg = form.gpsb_cgs:Find("gpb_cg" .. nx_string(i))
    if nx_is_valid(gpb_cg) then
      gpb_cg.Visible = false
    end
  end
  local areaini = nx_execute("util_functions", "get_ini", CHANGGUAN_AREA_INI)
  local changguanini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  local sharecgini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not (nx_is_valid(areaini) and nx_is_valid(changguanini)) or not nx_is_valid(sharecgini) then
    return 0
  end
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return 0
  end
  local sel_node = form.tree_area.SelectNode
  if not nx_is_valid(sel_node) then
    return 0
  end
  if not nx_find_custom(sel_node, "area_id") then
    return 0
  end
  local area_id = sel_node.area_id
  local sec_index = areaini:FindSectionIndex(nx_string(area_id))
  if 0 > nx_number(sec_index) then
    return 0
  end
  local cgs_id = areaini:ReadString(sec_index, "ChangGuan", "")
  local cg_tab = util_split_string(nx_string(cgs_id), ",")
  if table.getn(cg_tab) > AREA_CG_COUNT then
    return 0
  end
  for i = 1, table.getn(cg_tab) do
    local cg_id = nx_string(cg_tab[i])
    local gpb_cg = form.gpsb_cgs:Find("gpb_cg" .. nx_string(i))
    if not nx_is_valid(gpb_cg) then
      return 0
    end
    local grid_photo = gpb_cg:Find("grid_photo" .. nx_string(i))
    local lbl_name = gpb_cg:Find("lbl_name" .. nx_string(i))
    local lbl_addr = gpb_cg:Find("lbl_addr" .. nx_string(i))
    local lbl_count = gpb_cg:Find("lbl_count" .. nx_string(i))
    local mltbox_cdt = gpb_cg:Find("mltbox_cdt" .. nx_string(i))
    local grid_dif = gpb_cg:Find("grid_dif" .. nx_string(i))
    local btn_select = gpb_cg:Find("btn_select" .. nx_string(i))
    local lbl_entercount = gpb_cg:Find("lbl_entercount" .. nx_string(i))
    if not (nx_is_valid(grid_photo) and nx_is_valid(lbl_name) and nx_is_valid(lbl_addr) and nx_is_valid(mltbox_cdt) and nx_is_valid(lbl_count) and nx_is_valid(grid_dif) and nx_is_valid(btn_select)) or not nx_is_valid(lbl_entercount) then
      return 0
    end
    local sec_index_1 = changguanini:FindSectionIndex(nx_string(cg_id))
    local sec_index_2 = sharecgini:FindSectionIndex(nx_string(cg_id))
    if 0 > nx_number(sec_index_1) or 0 > nx_number(sec_index_2) then
      return 0
    end
    local photo = changguanini:ReadString(sec_index_1, "Photo", "")
    local condition = sharecgini:ReadString(sec_index_2, "MemberConditionID", "")
    local minplayer = sharecgini:ReadString(sec_index_2, "MinPlayerCount", "")
    local maxplayer = sharecgini:ReadString(sec_index_2, "MaxPlayerCount", "")
    local difficult = sharecgini:ReadString(sec_index_2, "Difficult", "")
    local cg_node = form.tree_guan.RootNode:FindNode(nx_widestr(gui.TextManager:GetText("ui_tiguan_name_" .. cg_id)))
    if nx_is_valid(cg_node) and nx_find_custom(cg_node, "entercount") and nx_find_custom(cg_node, "limitcount") then
      lbl_entercount.Text = nx_widestr(nx_string(cg_node.entercount) .. "/" .. nx_string(cg_node.limitcount))
    else
      lbl_entercount.Text = nx_widestr("")
    end
    grid_photo:Clear()
    grid_photo:AddItem(0, nx_string(photo), "", 1, -1)
    lbl_name.Text = gui.TextManager:GetText("ui_tiguan_name_" .. cg_id)
    lbl_addr.Text = gui.TextManager:GetText("ui_tiguan_addr_" .. cg_id)
    mltbox_cdt:Clear()
    local cdt_tab = util_split_string(nx_string(condition), ";")
    for j = 1, table.getn(cdt_tab) do
      local condition_desc = gui.TextManager:GetText(nx_string(cdt_mgr:GetConditionDesc(nx_int(cdt_tab[j]))))
      if check_iscan_enter(condition) then
        mltbox_cdt:AddHtmlText(nx_widestr("<font color=\"#008000\">") .. condition_desc .. nx_widestr("</font>"), -1)
      else
        mltbox_cdt:AddHtmlText(nx_widestr("<font color=\"#ff0000\">") .. condition_desc .. nx_widestr("</font>"), -1)
      end
    end
    local counttxt = gui.TextManager:GetFormatText("ui_tiguan_players_const", nx_int(minplayer))
    if minplayer ~= maxplayer then
      counttxt = gui.TextManager:GetFormatText("ui_tiguan_players_minmax", nx_int(minplayer), nx_int(maxplayer))
    end
    lbl_count.Text = nx_widestr(counttxt)
    local level = nx_number(difficult) / 5
    if level > CHANGGUAN_DIT_LEVEL then
      level = CHANGGUAN_DIT_LEVEL
    end
    grid_dif:Clear()
    for j = 1, CHANGGUAN_DIT_LEVEL / 2 do
      if level >= j * 2 then
        grid_dif:AddItem(nx_int(j - 1), DIFFICULT_PHOTO[3], "", 1, -1)
      elseif j * 2 == level + 1 then
        grid_dif:AddItem(nx_int(j - 1), DIFFICULT_PHOTO[2], "", 1, -1)
      else
        grid_dif:AddItem(nx_int(j - 1), DIFFICULT_PHOTO[1], "", 1, -1)
      end
    end
    btn_select.cg_id = cg_id
    gpb_cg.Visible = true
  end
  form.gpsb_cgs:ResetChildrenYPos()
  form.gpsb_cgs.VScrollBar.Value = sel_node.scr_value
end
function show_guan_data(form)
  local gui = nx_value("gui")
  local node = form.tree_guan.SelectNode
  if not nx_is_valid(node) then
    return 0
  end
  if node.type == NODE_TYPE_CG then
    form.grpbox_cg.Visible = true
    form.grpbox_npc.Visible = false
    form.lbl_name.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_name_" .. node.cgid))
    form.lbl_camptype.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_camptype_" .. node.camptype))
    form.lbl_location.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_location_" .. node.location))
    form.lbl_level.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_level_" .. node.level))
    form.lbl_cgcount.Text = nx_widestr(node.count)
    if node.entercount > nx_number(node.limitcount) then
      node.entercount = nx_number(node.limitcount)
    end
    form.lbl_entercount.Text = nx_widestr(nx_string(node.entercount) .. "/" .. nx_string(node.limitcount))
    form.grid_image:Clear()
    form.grid_image:AddItem(0, nx_string(node.photo), "", 1, -1)
    form.mltbox_cgdesc:Clear()
    form.mltbox_cgdesc:AddHtmlText(gui.TextManager:GetText(nx_string("ui_tiguan_desc_" .. node.cgid)), 1)
  elseif node.type == NODE_TYPE_NPC then
    form.grpbox_cg.Visible = false
    form.grpbox_npc.Visible = true
    form.lbl_npcname.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_npcname_" .. node.npcid))
    form.lbl_cgname.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_name_" .. node.ParentNode.cgid))
    form.lbl_npctitle.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_npctitle_" .. node.ParentNode.cgid .. "_" .. node.title))
    form.lbl_npcadept.Text = nx_widestr(gui.TextManager:GetText(nx_string("ui_tiguan_npcadept_" .. node.npcid)))
    if 0 > nx_number(node.count) then
      form.lbl_npccount.Text = nx_widestr(0)
    else
      form.lbl_npccount.Text = nx_widestr(node.count)
    end
    form.grid_npcimage:Clear()
    form.grid_npcimage:AddItem(0, nx_string(node.photo), "", 1, -1)
    form.mltbox_npcdesc:Clear()
    form.mltbox_npcdesc:AddHtmlText(gui.TextManager:GetText(nx_string("ui_tiguan_npcdesc_" .. node.npcid)), 1)
  end
end
function refresh_area_tree(form)
  local gui = nx_value("gui")
  local areaini = nx_execute("util_functions", "get_ini", CHANGGUAN_AREA_INI)
  if not nx_is_valid(areaini) then
    return 0
  end
  local section_count = areaini:GetSectionCount()
  for i = 1, section_count do
    local area_id = areaini:GetSectionByIndex(i - 1)
    local cur_count = 0
    local cgs_id = areaini:ReadString(i - 1, "ChangGuan", "")
    local cg_tab = util_split_string(nx_string(cgs_id), ",")
    for j = 1, table.getn(cg_tab) do
      local cg_name = gui.TextManager:GetText("ui_tiguan_name_" .. cg_tab[j])
      local cg_node = form.tree_guan.RootNode:FindNode(nx_widestr(cg_name))
      if nx_find_custom(cg_node, "success_all") and nx_number(cg_node.success_all) == 1 then
        cur_count = cur_count + 1
      end
    end
    local name = gui.TextManager:GetText(nx_string("ui_tiguan_difficult_" .. area_id))
    local info = "(" .. nx_string(cur_count) .. "/" .. nx_string(table.getn(cg_tab)) .. ")"
    local area_node = form.tree_area.RootNode:FindNodeByMark(nx_int(area_id))
    if nx_is_valid(area_node) then
      area_node.Text = nx_widestr(name .. nx_widestr(info))
    end
  end
end
function check_iscan_enter(conditions_id)
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local cdt_tab = util_split_string(nx_string(conditions_id), ";")
  for i = 1, table.getn(cdt_tab) do
    if not cdt_mgr:CanSatisfyCondition(player, player, nx_int(cdt_tab[i])) then
      return false
    end
  end
  return true
end
function show_tiguan_count(type, info)
  local gui = nx_value("gui")
  local tg_mge = nx_value("tiguan_manager")
  if not nx_is_valid(tg_mge) then
    return 0
  end
  local form = util_get_form(FORM_TIGUAN_MAIN, false)
  if not nx_is_valid(form) then
    return 0
  end
  if not nx_is_valid(form.tree_guan.RootNode) then
    return 0
  end
  if nx_number(type) == LOOK_INFO_WIN_NPC then
    local data_tab = util_split_string(nx_string(info), "/")
    if table.getn(data_tab) ~= 4 then
      return 0
    end
    local cg_name = gui.TextManager:GetText("ui_tiguan_name_" .. nx_string(data_tab[1]))
    local cg_node = form.tree_guan.RootNode:FindNode(nx_widestr(cg_name))
    if nx_is_valid(cg_node) then
      cg_node.isrefresh = true
      cg_node.count = nx_number(data_tab[2])
      cg_node.entercount = nx_number(data_tab[3])
    end
    local npc_tab = tg_mge:GetKillNpcInfo(nx_int(data_tab[1]), nx_string(data_tab[4]))
    if table.getn(npc_tab) % 2 ~= 0 then
      return 0
    end
    for i = 1, table.getn(npc_tab) / 2 do
      local npc_name = gui.TextManager:GetText("ui_tiguan_npcname_" .. nx_string(npc_tab[i * 2 - 1]))
      local npc_node = cg_node:FindNode(nx_widestr(npc_name))
      if nx_is_valid(npc_node) then
        npc_node.count = nx_number(npc_tab[i * 2])
        if nx_number(npc_tab[i * 2]) == -2 then
          npc_node.ForeColor = NODE_FORECOLOR_DISABLE
        elseif nx_number(npc_tab[i * 2]) == -1 then
          npc_node.ForeColor = NODE_FORECOLOR_NORMAL
        elseif 0 <= nx_number(npc_tab[i * 2]) then
          npc_node.ShowCoverImage = true
          npc_node.ForeColor = NODE_FORECOLOR_NORMAL
        end
      end
    end
  elseif nx_number(type) == LOOK_INFO_WIN_GUAN then
    local cg_tab = util_split_string(nx_string(info), ";")
    for i = 1, table.getn(cg_tab) do
      local data_tab = util_split_string(nx_string(cg_tab[i]), ",")
      if table.getn(data_tab) ~= 4 then
        return 0
      end
      local cg_name = gui.TextManager:GetText("ui_tiguan_name_" .. nx_string(data_tab[1]))
      local cg_node = form.tree_guan.RootNode:FindNode(nx_widestr(cg_name))
      if nx_is_valid(cg_node) then
        cg_node.count = nx_number(data_tab[3])
        cg_node.entercount = nx_number(data_tab[4])
        cg_node.success_all = 0
        if 0 < nx_number(data_tab[2]) then
          cg_node.ShowCoverImage = true
          cg_node.success_all = 1
        end
      end
    end
    form.reccount = nx_number(form.reccount) + nx_number(table.getn(cg_tab))
    local cg_count = form.tree_guan.RootNode:GetNodeCount()
    if nx_number(cg_count) <= nx_number(form.reccount) then
      form.ani_connect.Visible = false
      form.ani_connect.PlayMode = 2
      form.lbl_connect.Visible = false
    end
  end
  refresh_area_tree(form)
  show_guan_data(form)
end
