require("util_functions")
require("util_gui")
require("form_stage_main\\form_relation\\relation_define")
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
local clone_karma_table = {
  [27] = 203,
  [28] = 211,
  [29] = 204,
  [30] = 220,
  [48] = 207
}
local karma_clone_table = {
  [203] = 27,
  [211] = 28,
  [204] = 29,
  [220] = 30,
  [207] = 48
}
local clone_relation_table = {
  [27] = RELATION_SUB_JINDI_KQSZ,
  [28] = RELATION_SUB_JINDI_LMKZ,
  [29] = RELATION_SUB_JINDI_MSZC,
  [30] = RELATION_SUB_JINDI_YMG,
  [48] = RELATION_SUB_JINDI_QYB
}
local clone_level_tipsinfo = {
  [27] = {
    "desc_sns_condtion_clone001_1",
    "desc_sns_condtion_clone001_2",
    "desc_sns_condtion_clone001_3"
  },
  [28] = {
    "desc_sns_condtion_clone002_1",
    "desc_sns_condtion_clone002_2",
    "desc_sns_condtion_clone002_3"
  },
  [29] = {
    "desc_sns_condtion_clone003_1",
    "desc_sns_condtion_clone003_2",
    "desc_sns_condtion_clone003_3"
  },
  [30] = {},
  [48] = {
    "desc_sns_condtion_clone021_1",
    "desc_sns_condtion_clone021_2",
    "desc_sns_condtion_clone021_3"
  }
}
local clone_score_limit_info = {
  [27] = "ui_clonescore_kq",
  [28] = "ui_clonescore_lm",
  [29] = "ui_clonescore_ms",
  [30] = "ui_clonescore_ym",
  [48] = "ui_clonescore_qy"
}
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
local CloneChallengeRecName = "clone_challenge_success_rec"
function get_show_clonenpc_model(shili_id)
  local power_level = get_player_powerlevel()
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(scene_file_name) then
    IniManager:LoadIniToManager(scene_file_name)
  end
  local scene_ini = IniManager:GetIniDocument(scene_file_name)
  local section_count = scene_ini:GetSectionCount()
  local sec_index = -1
  for i = 1, section_count do
    local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
    if nx_number(clonescene) == nx_number(karma_clone_table[shili_id]) then
      sec_index = i - 1
      break
    end
  end
  if 0 <= sec_index then
    local EntryLimited = scene_ini:ReadString(sec_index, "EntryLimited1", "")
    local scene_limit_level = get_clone_scene_powerlevel(nx_string(EntryLimited))
    if nx_int(power_level) >= nx_int(scene_limit_level) then
      return true
    end
  end
  return false
end
function main_form_init(self)
  self.Fixed = true
  load_clone_scene_data(self)
end
function main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 20
  local form_rela = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form_rela) then
    form.Width = form_rela.Width
    form.Height = gui.Height - form_rela.groupbox_rbtn.Height
  end
  form.btn_hidenpc.Visible = true
  form.btn_shownpc.Visible = false
  form.groupbox_character.Visible = false
  form.selectstate = false
end
function main_form_close(form)
  if nx_find_custom(form, "challenge_data") and nx_is_valid(form.challenge_data) then
    nx_destroy(form.challenge_data)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function show_clone_form(cloneid)
  local form_clone = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_clone_describe")
  if not nx_is_valid(form_clone) then
    return
  end
  if not form_clone.Visible then
    form_clone.cloneid = cloneid
    load_clone_challenge_data(form_clone)
    form_clone.groupbox_karma_rbtn:DeleteAll()
    form_clone.groupbox_npc:DeleteAll()
    create_karma_rbtn(form_clone, clone_karma_table[nx_number(form_clone.cloneid)])
    form_clone.Visible = true
  end
  if nx_find_custom(form_clone, "selectstate") and not form_clone.selectstate then
    form_clone.type = NODE_TYPE_SCENE
    show_clonescene_data(form_clone, form_clone.cloneid)
  end
  form_clone.selectstate = false
end
function create_karma_rbtn(form, karma_id)
  local gui = nx_value("gui")
  local NORMAL_IMAGE = "gui\\special\\sns_new\\cbtn_sub2_out.png"
  local FOCUS_IMAGE = "gui\\special\\sns_new\\cbtn_sub2_on.png"
  local CHECK_IMAGE = "gui\\special\\sns_new\\cbtn_sub2_on.png"
  local DISABLE_IMAGE = ""
  local rbtn_width = 71
  local rbtn_height = 82
  local IniManager = nx_value("IniManager")
  local scene_ini = IniManager:GetIniDocument(scene_file_name)
  local section_count = scene_ini:GetSectionCount()
  local sec_index = -1
  for i = 1, section_count do
    local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
    if nx_number(clonescene) == nx_number(form.cloneid) then
      sec_index = i - 1
      break
    end
  end
  local groupid = {}
  if sec_index ~= -1 then
    local grouplist = scene_ini:ReadString(sec_index, "Group", "")
    groupid = util_split_string(nx_string(grouplist), ",")
  end
  local karma_rbtn = gui:Create("RadioButton")
  form.groupbox_karma_rbtn:Add(karma_rbtn)
  nx_bind_script(karma_rbtn, nx_current())
  nx_callback(karma_rbtn, "on_checked_changed", "on_karma_rbtn_relive_changed")
  karma_rbtn.Width = rbtn_width
  karma_rbtn.Height = rbtn_height
  karma_rbtn.Left = form.groupbox_karma_rbtn.Width - (karma_rbtn.Width + 10)
  karma_rbtn.DrawMode = "Tile"
  karma_rbtn.ForeColor = "255,204,204,204"
  karma_rbtn.Font = "font_sns_main"
  karma_rbtn.AutoSize = true
  local strtext = gui.TextManager:GetText("ui_shili")
  if groupid[1] ~= nil then
    strtext = gui.TextManager:GetText(groupid[1])
  end
  karma_rbtn.NormalImage = NORMAL_IMAGE
  karma_rbtn.FocusImage = FOCUS_IMAGE
  karma_rbtn.CheckedImage = CHECK_IMAGE
  karma_rbtn.DisableImage = DISABLE_IMAGE
  karma_rbtn.karmaid = karma_id
  karma_rbtn.Checked = true
  local lab_name = gui:Create("Label")
  form.groupbox_karma_rbtn:Add(lab_name)
  lab_name.Left = form.groupbox_karma_rbtn.Width - (karma_rbtn.Width + 15)
  lab_name.Top = 10
  lab_name.ForeColor = "255,204,204,204"
  lab_name.Font = "font_sns_main"
  lab_name.Align = "Center"
  lab_name.Text = nx_widestr(strtext)
  local npc_num = 0
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    local strNpcList = karmamgr:GetGroupNpc(nx_int(karma_rbtn.karmaid))
    local table_npc = util_split_string(nx_string(strNpcList), ";")
    npc_num = table.getn(table_npc)
  end
  local lab_count = gui:Create("Label")
  form.groupbox_karma_rbtn:Add(lab_count)
  lab_count.Left = form.groupbox_karma_rbtn.Width - (karma_rbtn.Width + 15)
  lab_count.Top = 40
  lab_count.ForeColor = "255,204,204,204"
  lab_count.Font = "font_sns_title_hual_2"
  lab_count.Align = "Center"
  lab_count.Text = nx_widestr(npc_num - 1)
  form.groupbox_karma_rbtn.Visible = false
end
function on_karma_rbtn_relive_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "add_npc", form, rbtn.karmaid)
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "add_relation", form, rbtn.karmaid)
  end
end
function load_clone_challenge_data(form)
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetPlayer()
  if not nx_is_valid(player_obj) then
    return
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "challenge_data") or not nx_is_valid(form.challenge_data) then
    form.challenge_data = nx_call("util_gui", "get_arraylist", "challenge_data")
  end
  form.challenge_data:ClearChild()
  if player_obj:FindRecord(CloneChallengeRecName) then
    local rows = player_obj:GetRecordRows(CloneChallengeRecName)
    for i = 1, rows do
      local clone_configid = nx_string(player_obj:QueryRecord(CloneChallengeRecName, i - 1, 0))
      local success_count = nx_number(player_obj:QueryRecord(CloneChallengeRecName, i - 1, 1))
      local success_score = nx_number(player_obj:QueryRecord(CloneChallengeRecName, i - 1, 2))
      local child = form.challenge_data:CreateChild(nx_string(clone_configid))
      child.challenge_count = success_count
      child.challenge_score = success_score
    end
  end
end
function on_rbtn_desc_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if rbtn.Checked then
    local IniManager = nx_value("IniManager")
    local scene_ini = IniManager:GetIniDocument(scene_file_name)
    local section_count = scene_ini:GetSectionCount()
    local sec_index = -1
    for i = 1, section_count do
      local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
      if nx_number(clonescene) == nx_number(form.cloneid) then
        sec_index = i - 1
        break
      end
    end
    if sec_index < 0 then
      return
    end
    if rbtn.DataSource == "1" then
      local story = scene_ini:ReadString(sec_index, "Story", "")
      form.mltbox_scenedesc:Clear()
      form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(story), 1)
    elseif rbtn.DataSource == "2" then
      local play = scene_ini:ReadString(sec_index, "Play", "")
      form.mltbox_scenedesc:Clear()
      form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(play), 1)
    elseif rbtn.DataSource == "3" then
      local limit = scene_ini:ReadString(sec_index, "Limit", "")
      form.mltbox_scenedesc:Clear()
      form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(limit), 1)
    end
  end
end
function show_clonescene_tree(form)
  local gui = nx_value("gui")
  local root = form.tree_scene:CreateRootNode("clone_scene")
  local IniManager = nx_value("IniManager")
  local scene_ini = IniManager:GetIniDocument(scene_file_name)
  local npc_ini = IniManager:GetIniDocument(npc_file_name)
  local default_index = 0
  local clondid = 29
  if nx_find_custom(form, "cloneid") then
    clondid = form.cloneid
  end
  local section_count = scene_ini:GetSectionCount()
  for i = 1, section_count do
    local id = scene_ini:GetSectionByIndex(i - 1)
    local name = scene_ini:ReadString(i - 1, "Name", "")
    local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
    if nx_number(clondid) == nx_number(clonescene) then
      default_index = i - 1
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
      form.tree_scene.SelectNode = scene_node
      form.tree_scene.SelectNode.Expand = true
    end
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
function show_clonescene_data(form, data_index)
  local gui = nx_value("gui")
  form.select_npc_name = ""
  form.groupbox_character.Visible = false
  local IniManager = nx_value("IniManager")
  if form.type == NODE_TYPE_SCENE then
    form.grpbox_clonescene.Visible = true
    form.groupbox_scenedesc.Visible = true
    form.grpbox_npc.Visible = false
    form.groupbox_npcdesc.Visible = false
    local scene_ini = IniManager:GetIniDocument(scene_file_name)
    local section_count = scene_ini:GetSectionCount()
    local sec_index = -1
    for i = 1, section_count do
      local clonescene = scene_ini:ReadInteger(i - 1, "CloneScene", "")
      if nx_number(clonescene) == nx_number(data_index) then
        sec_index = i - 1
        break
      end
    end
    if sec_index < 0 then
      return
    end
    local clonescene = scene_ini:ReadString(sec_index, "CloneScene", "")
    local configid = scene_ini:ReadString(sec_index, "ConfigID", "")
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
    form.lbl_score_count.Text = nx_widestr("0")
    if nx_find_custom(form, "challenge_data") and nx_is_valid(form.challenge_data) and form.challenge_data:FindChild(nx_string(configid)) then
      local child = form.challenge_data:GetChild(nx_string(configid))
      form.lbl_success_count.Text = nx_widestr(child.challenge_count)
      form.lbl_score_count.Text = nx_widestr(child.challenge_score)
    end
    form.img_clone_scene:Clear()
    form.img_clone_scene:AddItem(0, nx_string(photo), "", 1, -1)
    form.mltbox_scenedesc:Clear()
    form.mltbox_scenedesc:AddHtmlText(gui.TextManager:GetText(story), 1)
    form.rbtn_story.Checked = true
    local player_powerlevel = get_player_powerlevel()
    for i = 1, 3 do
      local lbl_name = "lbl_s" .. i
      local lbl = form.grpbox_clonescene:Find(lbl_name)
      local EntryLimited = scene_ini:ReadString(sec_index, "EntryLimited" .. i, "")
      local scene_powerlevel = get_clone_scene_powerlevel(EntryLimited)
      if scene_powerlevel ~= nil then
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
    end
  elseif form.type == NODE_TYPE_NPC then
    form.grpbox_clonescene.Visible = false
    form.groupbox_scenedesc.Visible = false
    form.grpbox_npc.Visible = true
    form.groupbox_npcdesc.Visible = true
    local npc_ini = IniManager:GetIniDocument(npc_file_name)
    local sec_index = npc_ini:FindSectionIndex(nx_string(data_index))
    if sec_index < 0 then
      return
    end
    local npc_group = npc_ini:ReadString(sec_index, "Group", "")
    local npc_identity = npc_ini:ReadString(sec_index, "Identity", "")
    local npc_weapon = npc_ini:ReadString(sec_index, "Weapon", "")
    local npc_power = npc_ini:ReadString(sec_index, "Power", "")
    local npc_photo = npc_ini:ReadString(sec_index, "Photo", "")
    local npc_desc = npc_ini:ReadString(sec_index, "Desc", "")
    form.lbl_npcname.Text = nx_widestr(gui.TextManager:GetText(nx_string(data_index)))
    form.lbl_npc_section.Text = nx_widestr(gui.TextManager:GetText(npc_group))
    form.lbl_npc_identity.Text = nx_widestr(gui.TextManager:GetText(npc_identity))
    form.lbl_npc_weapon.Text = nx_widestr(gui.TextManager:GetText(npc_weapon))
    form.lbl_npc_power.Text = nx_widestr(gui.TextManager:GetText(npc_power))
    form.image_npc:Clear()
    form.image_npc:AddItem(0, nx_string(npc_photo), "", 1, -1)
    form.mltbox_npcdesc:Clear()
    form.mltbox_npcdesc:AddHtmlText(gui.TextManager:GetText(npc_desc), 1)
    local CharacterFlag = 0
    local ItemQuery = nx_value("ItemQuery")
    if nx_is_valid(ItemQuery) then
      CharacterFlag = nx_number(ItemQuery:GetItemPropByConfigID(nx_string(data_index), nx_string("Character")))
    end
    local CharacterValue = 100
    nx_execute("form_stage_main\\form_relation\\form_relation_shili\\form_group_karma", "show_character_info", form, CharacterFlag, CharacterValue)
    form.groupbox_character.Visible = true
    form.select_npc_name = form.lbl_npcname.Text
    nx_execute("form_stage_main\\form_relation\\form_relation_jindi", "show_layer_menu")
  end
end
function get_power_space(player_powerlevel, clonescene_powerlevel)
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
  console_log("on_tree_scene_select_changed")
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
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    if rbtn.DataSource == "1" then
      form.Visible = true
    elseif rbtn.DataSource == "2" then
      form.Visible = false
    elseif rbtn.DataSource == "3" then
      form.Visible = false
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
function on_gb_get_capture(gb)
  local lbl_select = gb:Find("lbl_select" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_select) then
    return
  end
  lbl_select.Visible = true
end
function on_gb_lost_capture(gb)
  local lbl_select = gb:Find("lbl_select" .. nx_string(gb.Name))
  if not nx_is_valid(lbl_select) then
    return
  end
  lbl_select.Visible = false
end
function on_btn_npc_left_double_click(btn)
  local form = btn.ParentForm
  local gb = btn.Parent
  if not nx_is_valid(form) or not nx_is_valid(gb) then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  form.selectstate = true
  if form.select_npc_name == nil or form.select_npc_name == "" then
    form.selectstate = false
  end
  form.type = NODE_TYPE_NPC
  show_clonescene_data(form, gb.Name)
  focus_npc(clone_relation_table[nx_number(form.cloneid)], gb.Name)
end
function on_btn_npc_right_click(btn)
end
function focus_npc(group_id, select_npc_id)
  nx_execute("form_stage_main\\form_relationship", "focus_player_model", nx_int(group_id), 0, nx_string(select_npc_id))
end
function on_rbtn_scene_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    show_clone_form(nx_number(rbtn.DataSource))
  end
end
function on_focus_change_event(group_id, relation_type, index, name)
  local form_clone = nx_value("form_stage_main\\form_relation\\form_clone_describe")
  if not nx_is_valid(form_clone) then
    return
  end
  local karmamgr = nx_value("Karma")
  if not nx_is_valid(karmamgr) then
    return
  end
  if not nx_find_custom(form_clone, "cloneid") then
    return
  end
  local strNpcList = karmamgr:GetGroupNpc(nx_int(clone_karma_table[nx_number(form_clone.cloneid)]))
  local table_npc = util_split_string(nx_string(strNpcList), ";")
  local table_npc_info = util_split_string(nx_string(table_npc[index + 1]), ",")
  local npc_id = nx_string(table_npc_info[1])
  form_clone.type = NODE_TYPE_NPC
  show_clonescene_data(form_clone, npc_id)
end
function on_btn_hidenpc_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local npcvis = form.groupbox_npc.Visible
  form.btn_hidenpc.Visible = not npcvis
  form.btn_shownpc.Visible = npcvis
  form.groupbox_npc.Visible = not npcvis
end
function on_mltbox_get_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local descinfo = clone_level_tipsinfo[nx_number(form.cloneid)]
  if table.getn(descinfo) == 0 then
    return
  end
  local text = gui.TextManager:GetFormatText(nx_string(descinfo[nx_number(self.DataSource)]))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_mltbox_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_lbl_success_count_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local descinfo = clone_score_limit_info[nx_number(form.cloneid)]
  if descinfo == nil or nx_string(descinfo) == "" then
    return
  end
  local text = gui.TextManager:GetFormatText(nx_string(descinfo))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_lbl_success_count_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_lbl_score_count_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local descinfo = clone_score_limit_info[nx_number(form.cloneid)]
  if descinfo == nil or nx_string(descinfo) == "" then
    return
  end
  local text = gui.TextManager:GetFormatText(nx_string(descinfo))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_lbl_score_count_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
