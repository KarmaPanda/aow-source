require("util_functions")
require("util_gui")
local NODE_TYPE_SCENE = 1
local NODE_TYPE_NPC = 2
local scene_file_name = "ini\\ui\\clonescene\\clonescenedesc.ini"
local npc_file_name = "ini\\ui\\clonescene\\clonenpcdesc.ini"
local condition_file = "share\\Rule\\condition.ini"
local condition_formula_file = "share\\Rule\\condition_formula.ini"
local check_image = "gui\\common\\checkbutton\\rbtn_bg_down.png"
local normal_image = "gui\\common\\checkbutton\\rbtn_bg_out.png"
local LEVEL_NAME = {
  "ui_clonegui_dif01",
  "ui_clonegui_dif02",
  "ui_clonegui_dif03"
}
local LEVEL_POWER = {
  "ui_clonegui_dif11",
  "ui_clonegui_dif12",
  "ui_clonegui_dif13"
}
local FONT_COLOR = {
  "255,150,50,50",
  "255,50,150,50"
}
local NODE_PROP = {
  first = {
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 25,
    TextOffsetY = 6,
    Font = "font_treeview"
  },
  second = {
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 20,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 2,
    TextOffsetX = 35,
    TextOffsetY = 3,
    Font = "font_treeview"
  }
}
local CloneChallengeRecName = "clone_challenge_success_rec"
function main_form_init(self)
  self.Fixed = false
  load_clone_scene_data(self)
  local clone_team_page = util_get_form("form_stage_main\\form_team\\form_team_clone", true, false)
  local ret = self:Add(clone_team_page)
  if ret == true then
    self.clone_team_page = clone_team_page
    self.clone_team_page.Left = 6
    self.clone_team_page.Top = 84
    self.clone_team_page.Visible = false
  end
  local clone_guide_page = util_get_form("form_stage_main\\form_clone_guide", true, false)
  local ret = self:Add(clone_guide_page)
  if ret == true then
    self.clone_guide_page = clone_guide_page
    self.clone_guide_page.Left = 6
    self.clone_guide_page.Top = 84
    self.clone_guide_page.Visible = false
  end
end
function main_form_open(form)
  form.Visible = false
  do return end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.rbtn_overview.Checked = true
  form:ToFront(form.clone_team_page)
  form:ToFront(form.clone_guide_page)
  btn_state_process(form.btn_1)
  show_clonescene_tree(form)
end
function main_form_close(form)
  nx_destroy(form.challenge_data)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_clone_scene_desc_form(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_describe", true)
  if nx_is_valid(form) then
    if not nx_find_custom(form, "challenge_data") or not nx_is_valid(form.challenge_data) then
      form.challenge_data = nx_call("util_gui", "get_arraylist", "challenge_data")
    end
    form.challenge_data:ClearChild()
    for i = 1, table.getn(arg), 2 do
      local child = form.challenge_data:CreateChild(nx_string(arg[i]))
      child.Name = "challenge_data_child_" .. nx_string(child)
      child.scene_proto_id = arg[i]
      child.challenge_count = arg[i + 1]
    end
    form:Show()
    form.Visible = true
  end
end
function show_oneself_desc_form(cloneid)
  local challenge_rec = {}
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_describe", true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
    form:Close()
    return
  end
  form.object = player_obj
  form.cloneid = cloneid
  if player_obj:FindRecord(CloneChallengeRecName) then
    local rows = player_obj:GetRecordRows(CloneChallengeRecName)
    for i = 1, rows + 1 do
      local clone_id = nx_number(player_obj:QueryRecord(CloneChallengeRecName, i - 1, 0))
      local success_count = nx_number(player_obj:QueryRecord(CloneChallengeRecName, i - 1, 1))
      table.insert(challenge_rec, clone_id)
      table.insert(challenge_rec, success_count)
    end
  end
  show_clone_scene_desc_form(unpack(challenge_rec))
end
function request_show_clonescene_challenge_form(target, cloneid)
  if not nx_is_valid(target) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_describe", true)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible then
    form.Visible = false
    form:Close()
    return
  end
  form.object = target
  form.cloneid = cloneid
  if nx_id_equal(player_obj, target) then
    show_oneself_desc_form(cloneid)
  else
    nx_execute("custom_sender", "custom_send_clone_challenge_rec", target)
  end
end
function on_btn_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local IniManager = nx_value("IniManager")
  local scene_ini = IniManager:GetIniDocument(scene_file_name)
  if not nx_is_valid(form.tree_scene.SelectNode) then
    return
  end
  local cur_node = form.tree_scene.SelectNode
  local sec_index = scene_ini:FindSectionIndex(nx_string(cur_node.id))
  if sec_index < 0 then
    return
  end
  btn_state_process(btn)
  if btn.DataSource == "1" then
    local story = scene_ini:ReadString(sec_index, "Story", "")
    form.mltbox_scenedesc:Clear()
    form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(story), 1)
  elseif btn.DataSource == "2" then
    local play = scene_ini:ReadString(sec_index, "Play", "")
    form.mltbox_scenedesc:Clear()
    form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(play), 1)
  elseif btn.DataSource == "3" then
    local limit = scene_ini:ReadString(sec_index, "Limit", "")
    form.mltbox_scenedesc:Clear()
    form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(limit), 1)
  end
end
function show_clonescene_tree(form)
  local gui = nx_value("gui")
  local root = form.tree_scene:CreateRootNode("clone_scene")
  local IniManager = nx_value("IniManager")
  local scene_ini = IniManager:GetIniDocument(scene_file_name)
  local npc_ini = IniManager:GetIniDocument(npc_file_name)
  local default_index = 0
  local clondid = 0
  if nx_find_custom(form, "cloneid") then
    clondid = form.cloneid
  end
  local section_count = scene_ini:GetSectionCount()
  for i = 1, section_count do
    local id = scene_ini:GetSectionByIndex(i - 1)
    local name = scene_ini:ReadString(i - 1, "Name", "")
    local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
    if clondid == clonescene then
      default_index = i - 1
    end
    local scene_name = gui.TextManager:GetText(name)
    local scene_node = root:CreateNode(nx_widestr(scene_name))
    scene_node.Expand = true
    if nx_is_valid(scene_node) then
      scene_node.id = id
      scene_node.type = NODE_TYPE_SCENE
      set_node_prop(scene_node, "first")
    end
    local bosslist = scene_ini:ReadString(i - 1, "BossList", "")
    local boss_id = util_split_string(nx_string(bosslist), ",")
    for i = 1, table.getn(boss_id) do
      local sec_index = npc_ini:FindSectionIndex(nx_string(boss_id[i]))
      if 0 <= sec_index then
        local name = nx_string(boss_id[i])
        local npc_name = gui.TextManager:GetText(name)
        local npc_node = scene_node:CreateNode(nx_widestr(npc_name))
        if nx_is_valid(npc_node) then
          npc_node.id = boss_id[i]
          npc_node.type = NODE_TYPE_NPC
          set_node_prop(npc_node, "second")
        end
      end
    end
  end
  if not nx_is_valid(form.tree_scene.SelectNode) and 0 < section_count then
    local name = scene_ini:ReadString(default_index, "Name", "")
    local scene_name = gui.TextManager:GetText(name)
    local scene_node = form.tree_scene.RootNode:FindNode(scene_name)
    form.tree_scene.SelectNode = scene_node
    form.tree_scene.SelectNode.Expand = true
  end
  root.Expand = true
  form.groupscrollbox_scene.IsEditMode = true
  if form.tree_scene.Visible then
    local table_node = form.tree_scene:GetShowNodeList()
    form.tree_scene.Height = table.getn(table_node) * 22 + 20
  end
  form.groupscrollbox_scene.Height = 428
  form.groupscrollbox_scene.IsEditMode = false
end
function show_clonescene_data(form)
  local gui = nx_value("gui")
  local node = form.tree_scene.SelectNode
  if not nx_is_valid(node) then
    return 0
  end
  if not nx_find_custom(node, "type") or not nx_find_custom(node, "id") then
    return 0
  end
  local IniManager = nx_value("IniManager")
  if node.type == NODE_TYPE_SCENE then
    form.grpbox_clonescene.Visible = true
    form.grpbox_npc.Visible = false
    local scene_ini = IniManager:GetIniDocument(scene_file_name)
    local sec_index = scene_ini:FindSectionIndex(nx_string(node.id))
    if sec_index < 0 then
      return
    end
    local clonescene = scene_ini:ReadString(sec_index, "CloneScene", "")
    local name = scene_ini:ReadString(sec_index, "Name", "")
    local guild = scene_ini:ReadString(sec_index, "Guild", "")
    local location = scene_ini:ReadString(sec_index, "Location", "")
    local level = scene_ini:ReadString(sec_index, "Level", "")
    local photo = scene_ini:ReadString(sec_index, "Photo", "")
    local story = scene_ini:ReadString(sec_index, "Story", "")
    local play = scene_ini:ReadString(sec_index, "Play", "")
    local limit = scene_ini:ReadString(sec_index, "Limit", "")
    form.lbl_name.Text = nx_widestr(gui.TextManager:GetText(name))
    form.lbl_guild.Text = nx_widestr(gui.TextManager:GetText(guild))
    form.lbl_location.Text = nx_widestr(gui.TextManager:GetText(location))
    form.lbl_level.Text = nx_widestr(gui.TextManager:GetText(level))
    form.lbl_success_count.Text = nx_widestr("0")
    if nx_is_valid(form.challenge_data) and form.challenge_data:FindChild(nx_string(clonescene)) then
      local child = form.challenge_data:GetChild(nx_string(clonescene))
      form.lbl_success_count.Text = nx_widestr(child.challenge_count)
    end
    form.img_clone_scene:Clear()
    form.img_clone_scene:AddItem(0, nx_string(photo), "", 1, -1)
    form.mltbox_scenedesc:Clear()
    form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(story), 1)
    local player_powerlevel = get_player_powerlevel()
    for i = 1, 3 do
      local lbl_name = "lbl_s" .. i
      local lbl = form.grpbox_clonescene:Find(lbl_name)
      local EntryLimited = scene_ini:ReadString(sec_index, "EntryLimited" .. i, "")
      local scene_powerlevel = get_clone_scene_powerlevel(EntryLimited)
      if nx_is_valid(lbl) then
        lbl.Text = nx_widestr(gui.TextManager:GetText(LEVEL_NAME[i]))
      end
      local mltbox_name = "mltbox_s" .. i
      local mltbox = form.grpbox_clonescene:Find(mltbox_name)
      if nx_is_valid(mltbox) then
        mltbox:Clear()
        mltbox.TextColor = FONT_COLOR[2]
        if nx_number(player_powerlevel) < nx_number(scene_powerlevel) then
          mltbox.TextColor = FONT_COLOR[1]
        end
        local mltbox_text = get_power_text(player_powerlevel, scene_powerlevel)
        mltbox:AddHtmlText(gui.TextManager:GetText(mltbox_text), 1)
      end
    end
  elseif node.type == NODE_TYPE_NPC then
    form.grpbox_clonescene.Visible = false
    form.grpbox_npc.Visible = true
    local npc_ini = IniManager:GetIniDocument(npc_file_name)
    local sec_index = npc_ini:FindSectionIndex(nx_string(node.id))
    if sec_index < 0 then
      return
    end
    local npc_group = npc_ini:ReadString(sec_index, "Group", "")
    local npc_identity = npc_ini:ReadString(sec_index, "Identity", "")
    local npc_weapon = npc_ini:ReadString(sec_index, "Weapon", "")
    local npc_power = npc_ini:ReadString(sec_index, "Power", "")
    local npc_photo = npc_ini:ReadString(sec_index, "Photo", "")
    local npc_desc = npc_ini:ReadString(sec_index, "Desc", "")
    form.lbl_npcname.Text = nx_widestr(gui.TextManager:GetText(nx_string(node.id)))
    form.lbl_npc_section.Text = nx_widestr(gui.TextManager:GetText(npc_group))
    form.lbl_npc_identity.Text = nx_widestr(gui.TextManager:GetText(npc_identity))
    form.lbl_npc_weapon.Text = nx_widestr(gui.TextManager:GetText(npc_weapon))
    form.lbl_npc_power.Text = nx_widestr(gui.TextManager:GetText(npc_power))
    form.image_npc:Clear()
    form.image_npc:AddItem(0, nx_string(npc_photo), "", 1, -1)
    form.mltbox_npcdesc:Clear()
    form.mltbox_npcdesc:AddHtmlText(gui.TextManager:GetText(npc_desc), 1)
  end
end
function get_power_space(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return LEVEL_NAME[1]
  end
  local space = nx_number(player_powerlevel) - nx_int(clonescene_powerlevel)
  if 10 < space then
    return LEVEL_NAME[1]
  elseif 0 <= space then
    return LEVEL_NAME[2]
  else
    return LEVEL_NAME[3]
  end
end
function get_power_text(player_powerlevel, clonescene_powerlevel)
  if player_powerlevel == nil or clonescene_powerlevel == nil then
    return LEVEL_POWER[1]
  end
  local space = nx_number(player_powerlevel - clonescene_powerlevel)
  if 10 < space then
    return LEVEL_POWER[1]
  elseif 0 <= space then
    return LEVEL_POWER[2]
  else
    return LEVEL_POWER[3]
  end
end
function get_player_powerlevel()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local power_level = player:QueryProp("PowerLevel")
  return power_level
end
function get_clone_scene_powerlevel(limit_id)
  local condition_ini = nx_execute("util_functions", "get_ini", condition_file)
  local sec_index = condition_ini:FindSectionIndex(nx_string(limit_id))
  if sec_index < 0 then
    return 0
  end
  local limit_min = condition_ini:ReadString(sec_index, "min", "")
  if limit_min == "" or limit_min == nil then
    return 0
  end
  return limit_min
end
function on_tree_scene_expand_changed(tree, node)
  local form = tree.ParentForm
end
function on_tree_scene_select_changed(tree, node, old_node)
  local form = tree.ParentForm
  if not nx_find_custom(node, "type") then
    return 0
  end
  if nx_is_valid(node) then
    node.ForeColor = "255,255,204,0"
  end
  if nx_is_valid(old_node) then
    old_node.ForeColor = "255,182,177,171"
  end
  btn_state_process(form.btn_1)
  show_clonescene_data(form)
end
function load_clone_scene_data(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(scene_file_name) then
    IniManager:LoadIniToManager(scene_file_name)
  end
  if not IniManager:IsIniLoadedToManager(npc_file_name) then
    IniManager:LoadIniToManager(npc_file_name)
  end
end
function btn_state_process(btn)
  local form = btn.ParentForm
  if nx_find_custom(form, "pre_btn") then
    local prebtn = form.pre_btn
    if nx_is_valid(prebtn) then
      prebtn.NormalImage = normal_image
    end
  end
  form.pre_btn = btn
  btn.NormalImage = check_image
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not (nx_is_valid(form.gpb_detail) and nx_is_valid(form.clone_team_page)) or not nx_is_valid(form.clone_guide_page) then
    return
  end
  if rbtn.Checked then
    if rbtn.DataSource == "1" then
      form.gpb_detail.Visible = true
      form.clone_team_page.Visible = false
      form.clone_guide_page.Visible = false
    elseif rbtn.DataSource == "2" then
      form.gpb_detail.Visible = false
      form.clone_team_page.Visible = true
      form.clone_guide_page.Visible = false
    elseif rbtn.DataSource == "3" then
      form.gpb_detail.Visible = false
      form.clone_team_page.Visible = false
      form.clone_guide_page.Visible = true
    end
  end
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
function a(str)
  nx_msgbox(nx_string(str))
end
