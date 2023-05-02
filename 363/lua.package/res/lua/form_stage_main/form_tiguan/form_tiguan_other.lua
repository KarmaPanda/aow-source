require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
function main_form_init(self)
  self.Fixed = false
  self.reccount = 0
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.gpb_xiangxi.Visible = true
  load_guan_tree(self)
  self.reccount = 0
  self.ani_connect.Visible = true
  self.ani_connect.PlayMode = 0
  self.lbl_connect.Visible = true
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 1
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return 1
  end
  local lastobject = nx_object(player:QueryProp("LastObject"))
  local client_target = game_client:GetSceneObj(nx_string(lastobject))
  if not nx_is_valid(client_target) then
    return 1
  end
  self.lbl_player_name.Text = nx_widestr(client_target:QueryProp("Name"))
  nx_execute("custom_sender", "custom_get_tiguan_all_info", nx_object(lastobject))
end
function main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_tree_guan_select_changed(self, cur_node, old_node)
  local form = self.ParentForm
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
          local lastobject = nx_object(player:QueryProp("LastObject"))
          local client_target = game_client:GetSceneObj(nx_string(lastobject))
          if nx_is_valid(client_target) then
            nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(lastobject), nx_int(cur_node.cgid))
          end
        end
      end
    end
  elseif cur_node.type == NODE_TYPE_NPC then
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
          local lastobject = nx_object(player:QueryProp("LastObject"))
          local client_target = game_client:GetSceneObj(nx_string(lastobject))
          if nx_is_valid(client_target) then
            nx_execute("custom_sender", "custom_get_tiguan_one_info", nx_object(lastobject), nx_int(node.cgid))
          end
        end
      end
    end
  end
  show_guan_data(self.ParentForm)
end
function load_guan_tree(form)
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
      cg_node.cgid = cg_id
      cg_node.type = NODE_TYPE_CG
      cg_node.count = 0
      cg_node.entercount = 0
      cg_node.photo = changguanini:ReadString(i - 1, "Photo", "")
      cg_node.camptype = changguanini:ReadString(i - 1, "CampType", "")
      cg_node.location = changguanini:ReadString(i - 1, "Location", "")
      cg_node.level = changguanini:ReadString(i - 1, "Level", "")
      local index = sharecgini:FindSectionIndex(cg_id)
      if index < 0 then
        break
      end
      cg_node.limitcount = sharecgini:ReadString(index, "LimitCountPerDay", "")
      local npc_list = changguanini:GetItemValueList(i - 1, "Npc")
      for j = 1, table.getn(npc_list) do
        local data_tab = util_split_string(nx_string(npc_list[j]), ",")
        if table.getn(data_tab) ~= 3 then
          return 0
        end
        if nx_number(data_tab[3]) == 1 then
          local npc_id = nx_string(data_tab[1])
          local title = nx_string(data_tab[2])
          local photo = get_large_photo(itemQuery:GetItemPropByConfigID(npc_id, nx_string("Photo")))
          local npc_name = gui.TextManager:GetText("ui_tiguan_npcname_" .. npc_id)
          local npc_node = cg_node:CreateNode(nx_widestr(npc_name))
          if nx_is_valid(cg_node) then
            set_node_prop(npc_node, 2)
            npc_node.ShowCoverImage = false
            npc_node.ForeColor = NODE_FORECOLOR_DISABLE
            npc_node.npcid = npc_id
            npc_node.type = NODE_TYPE_NPC
            npc_node.count = 0
            npc_node.photo = photo
            npc_node.title = title
          end
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
function show_tiguan_count(type, info)
  local gui = nx_value("gui")
  local tg_mge = nx_value("tiguan_manager")
  if not nx_is_valid(tg_mge) then
    return 0
  end
  local form = util_get_form(FORM_TIGUAN_OTHER, false)
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
      cg_node.count = nx_int(data_tab[2])
      cg_node.entercount = nx_number(data_tab[3])
      cg_node.isrefresh = true
    end
    local npc_tab = tg_mge:GetKillNpcInfo(nx_int(data_tab[1]), nx_string(data_tab[4]))
    if table.getn(npc_tab) % 2 ~= 0 then
      return 0
    end
    for i = 1, table.getn(npc_tab) / 2 do
      local npc_name = gui.TextManager:GetText("ui_tiguan_npcname_" .. nx_string(npc_tab[i * 2 - 1]))
      local npc_node = cg_node:FindNode(nx_widestr(npc_name))
      if nx_is_valid(npc_node) then
        npc_node.count = nx_int(npc_tab[i * 2])
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
    show_guan_data(form)
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
        if 0 < nx_number(data_tab[2]) then
          cg_node.ShowCoverImage = true
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
end
