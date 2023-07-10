require("role_composite")
require("util_gui")
require("util_functions")
require("share\\client_custom_define")
require("share\\logicstate_define")
require("share\\view_define")
require("game_object")
require("form_stage_main\\form_relation\\relation_define")
local grouptoscene = {
  [RELATION_SUB_JINDI_MSZC] = 29,
  [RELATION_SUB_JINDI_QYB] = 48,
  [RELATION_SUB_JINDI_KQSZ] = 27,
  [RELATION_SUB_JINDI_LMKZ] = 28,
  [RELATION_SUB_JINDI_YMG] = 30
}
local areatoscene = {
  {0, 29},
  {1, 48},
  {2, 27},
  {3, 28},
  {4, 30}
}
local clone_desc = {
  [29] = {
    "ui_sns_backbutton34",
    204
  },
  [48] = {
    "ui_sns_backbutton28",
    207
  },
  [27] = {
    "ui_sns_backbutton25",
    203
  },
  [28] = {
    "ui_sns_backbutton23",
    211
  },
  [30] = {
    "ui_sns_backbutton27",
    220
  }
}
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  change_form_size()
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_jindi = nx_value("form_stage_main\\form_relation\\form_relation_jindi")
    if not nx_is_valid(form_jindi) then
      local form_jindi = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_jindi", true, false)
      if nx_is_valid(form_jindi) then
        form:Add(form_jindi)
        local form_clone = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_clone_describe", true, false)
        if nx_is_valid(form_clone) then
          local ret = form_jindi:Add(form_clone)
          if ret == true then
            form_jindi.form_clone = form_clone
            form_jindi.form_clone.Visible = false
          end
        end
      end
    else
      form_jindi:Show()
      form_jindi.Visible = true
    end
  else
    local form_jindi = nx_value("form_stage_main\\form_relation\\form_relation_jindi")
    if nx_is_valid(form_jindi) then
      form_jindi.Visible = false
    end
  end
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked then
    form.select_scene = rbtn.DataSource
    show_layer_menu()
    local id = 0
    for i = 1, table.getn(areatoscene) do
      local tempdata = areatoscene[i]
      if nx_number(tempdata[2]) == nx_number(rbtn.DataSource) then
        id = tempdata[1]
      end
    end
    local sns_manager = nx_value(SnsManagerCacheName)
    local define_index = sns_manager:GetGroupIdByDefineIndex(RELATION_GROUP_JINDI)
    sns_manager:SetRelationType(define_index, id)
  end
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local form_jindi = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_jindi", true, false)
  if nx_is_valid(form_jindi) then
    form_jindi.AbsLeft = (gui.Width - form.Width) / 2
    form_jindi.Top = 0
    form_jindi.Width = form.Width
    form_jindi.Height = form.Height - form.groupbox_rbtn.Height
    if nx_find_custom(form_jindi, "form_clone") and nx_is_valid(form_jindi.form_clone) then
      form_jindi.form_clone.AbsLeft = (gui.Width - form.Width) / 2
      form_jindi.form_clone.AbsTop = 20
      form_jindi.form_clone.Width = form.Width
      form_jindi.form_clone.Height = form.Height - form.groupbox_rbtn.Height
    end
  end
end
function on_relation_type_change_event(group_id, relation_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_jindi")
  if not nx_is_valid(form) then
    return
  end
  local sns_manager = nx_value(SnsManagerCacheName)
  if not nx_is_valid(sns_manager) then
    return
  end
  local relation_group = sns_manager:GetRelationGroup(group_id)
  if not nx_is_valid(relation_group) then
    return
  end
  local group_index = -1
  if nx_find_custom(relation_group, "group_index") then
    group_index = relation_group.group_index
  end
  if nx_int(group_index) == nx_int(RELATION_GROUP_JINDI) then
    local btnid = -1
    for i = 1, table.getn(areatoscene) do
      local tempdata = areatoscene[i]
      if nx_number(tempdata[1]) == nx_number(relation_type) then
        btnid = tempdata[2]
        break
      end
    end
    if nx_number(btnid) == nx_number(-1) then
      return
    end
    local rbtn_scene = form.groupbox_1:Find("rbtn_" .. nx_string(btnid))
    if nx_is_valid(rbtn_scene) then
      rbtn_scene.Checked = true
    end
    form.groupbox_1.Visible = true
    if nx_is_valid(form.form_clone) then
      form.form_clone.Visible = false
    end
  else
    form.groupbox_1.Visible = false
    nx_execute("form_stage_main\\form_relation\\form_clone_describe", "show_clone_form", nx_number(grouptoscene[group_index]))
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_jindi", "show_layer_menu")
end
function on_focus_change_event(group_id, relation_type, index, name)
  nx_execute("form_stage_main\\form_relation\\form_clone_describe", "on_focus_change_event", group_id, relation_type, index, name)
end
function show_layer_menu()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(name)
  local text = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton21")
  gui.TextManager:Format_AddParam(nx_int(table.getn(areatoscene)))
  text = nx_widestr(text) .. nx_widestr(gui.TextManager:Format_GetText())
  local form_jindi = nx_value("form_stage_main\\form_relation\\form_relation_jindi")
  if nx_is_valid(form_jindi) and nx_find_custom(form_jindi, "select_scene") and nx_is_valid(form_jindi.form_clone) and form_jindi.form_clone.Visible then
    local clone_data = clone_desc[nx_number(form_jindi.select_scene)]
    gui.TextManager:Format_SetIDName(clone_data[1])
    local karmamgr = nx_value("Karma")
    if nx_is_valid(karmamgr) then
      local strNpcList = karmamgr:GetGroupNpc(nx_int(clone_data[2]))
      local table_npc = util_split_string(nx_string(strNpcList), ";")
      local npc_num = table.getn(table_npc)
      gui.TextManager:Format_AddParam(nx_int(npc_num))
    end
    text = nx_widestr(text) .. nx_widestr(gui.TextManager:Format_GetText())
    if form_jindi.form_clone.grpbox_npc.Visible and nx_find_custom(form_jindi.form_clone, "select_npc_name") then
      text = nx_widestr(text) .. nx_widestr("\161\162<font color=\"#E1CC00\">") .. nx_widestr(form_jindi.form_clone.select_npc_name) .. nx_widestr("</font>")
    end
  end
  form.mltbox_title:Clear()
  form.mltbox_title:AddHtmlText(nx_widestr(text), -1)
end
function on_btn_clone_info_click(btn)
  util_show_form("form_stage_main\\form_clone_guide", true)
end
