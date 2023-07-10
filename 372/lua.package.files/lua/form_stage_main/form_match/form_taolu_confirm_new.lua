require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_match\\form_taolu_confirm_new"
local WUXUE_SKILL = 2
local INI_RULE_PICK = 3
function tc(aaa, bbb, ccc, ddd)
  nx_msgbox(nx_string(aaa) .. "/" .. nx_string(bbb) .. "/" .. nx_string(ccc) .. "/" .. nx_string(ddd))
end
local sz_array_name = "form_taolu_pick_sanzhao"
local array_name = "form_taolu_confirm_array"
local cbox_taolu_list = {
  "ui_match_taolu_1",
  "ui_match_taolu_2",
  "ui_match_taolu_3",
  "ui_match_taolu_4",
  "ui_match_taolu_5",
  "ui_match_taolu_6",
  "ui_match_taolu_7",
  "ui_match_taolu_8",
  "ui_match_taolu_9",
  "ui_match_taolu_10"
}
NODE_PROP = {
  [1] = {
    NodeBackImage = "gui\\special\\wuxue\\button\\rbtn1_out.png",
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn1_on.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn1_down.png",
    Font = "font_text_title1",
    ItemHeight = 33,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 3,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 5,
    TextOffsetY = 6
  },
  [2] = {
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn2_on.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn2_on.png",
    Font = "font_text_title1",
    ItemHeight = 30,
    NodeOffsetY = 0,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 15,
    TextOffsetY = 6
  }
}
function main_form_init(form)
  form.Fixed = false
  form.LimitInScreen = true
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.lbl_taolu_1.taolu_id = ""
  form.lbl_taolu_2.taolu_id = ""
  form.lbl_taolu_3.taolu_id = ""
  form.lbl_taolu_4.taolu_id = ""
  form.limit_id = 0
  local bantl_form = util_get_form("form_stage_main\\form_match\\form_banxuan_taolu", true)
  if nx_is_valid(bantl_form) then
    bantl_form.Visible = false
    bantl_form:Close()
  end
  local ready_form = util_get_form("form_stage_main\\form_match\\form_war_ready", true)
  if nx_is_valid(ready_form) then
    ready_form.Visible = true
    ready_form:Show()
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(array_name) then
    common_array:AddArray(array_name, form, 60, true)
  end
  common_array:ClearChild(array_name)
  if not common_array:FindArray(sz_array_name) then
    common_array:AddArray(sz_array_name, form, 60, false)
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form(...)
  form = nx_execute("util_gui", "util_get_form", FORM_PATH, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  form.limit_id = nx_int(arg[2])
  LoadTaolu()
  LoadSanzhao()
  form.cbox_taolu.Text = util_text(cbox_taolu_list[1])
  count = table.getn(cbox_taolu_list)
  for i = 1, count do
    form.cbox_taolu.DropListBox:AddString(nx_widestr(util_text(cbox_taolu_list[i])))
  end
  form.cbox_taolu.DropListBox.SelectIndex = 0
  form.cbox_taolu.Text = nx_widestr(form.cbox_taolu.DropListBox:GetString(form.cbox_taolu.DropListBox.SelectIndex))
  on_cbox_taolu_selected(form.cbox_taolu)
  form.textgrid_ban_taolu:BeginUpdate()
  form.textgrid_ban_taolu:ClearRow()
  local taolu_id = ""
  for i = 3, table.getn(arg) do
    if nx_string(arg[i]) ~= nx_string("") then
      local row = form.textgrid_ban_taolu:InsertRow(-1)
      form.textgrid_ban_taolu:SetGridText(row, 0, nx_widestr(util_text(arg[i])))
      taolu_id = taolu_id .. arg[i] .. ","
    end
  end
  form.textgrid_ban_taolu.DataSource = taolu_id
  form.textgrid_ban_taolu:EndUpdate()
  show_all_taolu(form)
  form.btn_add.Enabled = false
  form.sel_taolu = ""
  check_btn_del_enable(form)
  form.grid_taolu_list:EndUpdate()
  check_can_submit(form)
end
function on_btn_submit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  nx_execute("custom_sender", "custom_egwar_trans", nx_number(8), nx_number(form.limit_id), nx_string(form.lbl_taolu_1.taolu_id), nx_string(form.lbl_taolu_2.taolu_id), nx_string(form.lbl_taolu_3.taolu_id), nx_string(form.lbl_taolu_4.taolu_id))
  SaveTaolu()
  form:Close()
end
function on_cbox_taolu_selected(cbox)
  local form = cbox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    record_oper_info(1, "get now group index is null.")
    return
  end
  form.lbl_taolu_1.Text = nx_widestr("")
  form.lbl_taolu_2.Text = nx_widestr("")
  form.lbl_taolu_3.Text = nx_widestr("")
  form.lbl_taolu_4.Text = nx_widestr("")
  form.lbl_taolu_1.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_1")
  form.lbl_taolu_2.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_2")
  form.lbl_taolu_3.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_3")
  form.lbl_taolu_4.taolu_id = Get_taolu(nx_string(form.limit_id) .. "_" .. index .. "_4")
  if nx_string(form.lbl_taolu_1.taolu_id) ~= "" then
    form.lbl_taolu_1.Text = util_text(form.lbl_taolu_1.taolu_id)
  end
  if nx_string(form.lbl_taolu_2.taolu_id) ~= "" then
    form.lbl_taolu_2.Text = util_text(form.lbl_taolu_2.taolu_id)
  end
  if nx_string(form.lbl_taolu_3.taolu_id) ~= "" then
    form.lbl_taolu_3.Text = util_text(form.lbl_taolu_3.taolu_id)
  end
  if nx_string(form.lbl_taolu_4.taolu_id) ~= "" then
    form.lbl_taolu_4.Text = util_text(form.lbl_taolu_4.taolu_id)
  end
  check_btn_del_enable(form)
  check_can_submit(form)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_string(form.sel_taolu) == nx_string("") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local taolu_name = gui.TextManager:GetText(form.sel_taolu)
  local taolu_id = form.sel_taolu
  if nx_widestr(taolu_name) == nx_widestr("") or nx_string(taolu_id) == nx_string("") then
    return
  end
  local normal_ctrl, sanzhao_ctrl = get_empty_taolu_option_ctrl(form)
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    return
  end
  local type_value = form.limit_id
  if type_value < 0 then
    return
  end
  local ctrl_index = 0
  if is_sanzhao(taolu_id) then
    if sanzhao_ctrl == nil or not nx_is_valid(sanzhao_ctrl) then
      return
    end
    sanzhao_ctrl.Text = nx_widestr(taolu_name)
    sanzhao_ctrl.taolu_id = nx_string(taolu_id)
    ctrl_index = 4
  else
    if normal_ctrl == nil or not nx_is_valid(normal_ctrl) then
      return
    end
    if nx_string(normal_ctrl) == nx_string(form.lbl_taolu_1) then
      ctrl_index = 1
    elseif nx_string(normal_ctrl) == nx_string(form.lbl_taolu_2) then
      ctrl_index = 2
    elseif nx_string(normal_ctrl) == nx_string(form.lbl_taolu_3) then
      ctrl_index = 3
    else
      return
    end
    normal_ctrl.Text = nx_widestr(taolu_name)
    normal_ctrl.taolu_id = nx_string(taolu_id)
  end
  if ctrl_index == 0 then
    return
  end
  check_btn_del_enable(form, ctrl_index)
  check_btn_add_enable(form)
  Del_taolu(nx_string(type_value) .. "_" .. index .. "_" .. nx_string(ctrl_index))
  Add_taolu(nx_string(type_value) .. "_" .. index .. "_" .. nx_string(ctrl_index), nx_string(taolu_id))
  check_can_submit(form)
end
function on_btn_del_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    return
  end
  local type_value = form.limit_id
  if type_value < 0 then
    return
  end
  form.lbl_taolu_1.Text = nx_widestr("")
  form.lbl_taolu_1.taolu_id = nx_string("")
  Del_taolu(nx_string(type_value) .. "_" .. index .. "_1")
  Add_taolu(nx_string(type_value) .. "_" .. index .. "_1", "")
  check_btn_del_enable(form, 1)
  check_btn_add_enable(form)
  check_can_submit(form)
end
function on_btn_del_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    return
  end
  local type_value = form.limit_id
  if type_value < 0 then
    return
  end
  form.lbl_taolu_2.Text = nx_widestr("")
  form.lbl_taolu_2.taolu_id = nx_string("")
  Del_taolu(nx_string(type_value) .. "_" .. index .. "_2")
  Add_taolu(nx_string(type_value) .. "_" .. index .. "_2", "")
  check_btn_del_enable(form, 2)
  check_btn_add_enable(form)
  check_can_submit(form)
end
function on_btn_del_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    return
  end
  local type_value = form.limit_id
  if type_value < 0 then
    return
  end
  form.lbl_taolu_3.Text = nx_widestr("")
  form.lbl_taolu_3.taolu_id = nx_string("")
  Del_taolu(nx_string(type_value) .. "_" .. index .. "_3")
  Add_taolu(nx_string(type_value) .. "_" .. index .. "_3", "")
  check_btn_del_enable(form, 3)
  check_btn_add_enable(form)
  check_can_submit(form)
end
function on_btn_del_4_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local index = nx_string(get_now_group_index(form))
  if index == "" then
    return
  end
  local type_value = form.limit_id
  if type_value < 0 then
    return
  end
  form.lbl_taolu_4.Text = nx_widestr("")
  form.lbl_taolu_4.taolu_id = nx_string("")
  Del_taolu(nx_string(type_value) .. "_" .. index .. "_4")
  Add_taolu(nx_string(type_value) .. "_" .. index .. "_4", "")
  check_btn_del_enable(form, 4)
  check_btn_add_enable(form)
  check_can_submit(form)
end
function LoadTaolu()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    record_oper_info(1, "create ini failed.")
    return
  end
  ini.FileName = account .. "\\match_taolu.ini"
  if not ini:LoadFromFile() then
    local error_info = "load ini failed. FileName is " .. ini.FileName
    record_oper_info(1, error_info)
  end
  for i = 1, table.maxn(cbox_taolu_list) do
    local ctaolu = nx_string(form.limit_id) .. "_" .. nx_string(cbox_taolu_list[i])
    if ctaolu ~= "" then
      local taolu_1 = ini:ReadString(nx_string(ctaolu), "taolu1", "")
      local taolu_2 = ini:ReadString(nx_string(ctaolu), "taolu2", "")
      local taolu_3 = ini:ReadString(nx_string(ctaolu), "taolu3", "")
      local taolu_4 = ini:ReadString(nx_string(ctaolu), "taolu4", "")
      Add_taolu(ctaolu .. "_1", nx_string(taolu_1))
      Add_taolu(ctaolu .. "_2", nx_string(taolu_2))
      Add_taolu(ctaolu .. "_3", nx_string(taolu_3))
      Add_taolu(ctaolu .. "_4", nx_string(taolu_4))
    end
  end
  nx_destroy(ini)
end
function LoadSanzhao()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\Match\\Match_Sanzhao.ini")
  if not nx_is_valid(ini) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(sz_array_name) then
    return
  end
  local SectionCount = ini:GetSectionCount()
  for i = 0, SectionCount - 1 do
    local SectionItemCount = ini:GetSectionItemCount(i)
    for num = 0, SectionItemCount - 1 do
      local sanzhao_taolu = ini:ReadString(i, nx_string(num), "")
      if sanzhao_taolu ~= "" then
        common_array:AddChild(sz_array_name, nx_string(sanzhao_taolu), nx_string(sanzhao_taolu))
      end
    end
  end
end
function Add_taolu(section, values)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return false
  end
  if not common_array:FindArray(array_name) then
    local error_info = "Add_taolu Oper FindArray failed. array_name is " .. array_name
    record_oper_info(1, error_info)
    return false
  end
  common_array:RemoveChild(array_name, nx_string(section))
  return common_array:AddChild(array_name, nx_string(section), nx_string(values))
end
function Get_taolu(section)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return ""
  end
  if not common_array:FindArray(array_name) then
    local error_info = "Get_taolu oper FindArray failed. array_name is " .. array_name
    record_oper_info(1, error_info)
    return ""
  end
  local section_value = common_array:FindChild(array_name, nx_string(section))
  if not nx_is_valid(section_value) or section_value == "" then
    record_oper_info(1, "get taolu is null. taolu_section is " .. section)
  end
  return section_value
end
function Del_taolu(section)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return false
  end
  if not common_array:FindArray(array_name) then
    return false
  end
  return common_array:RemoveChild(array_name, nx_string(section))
end
function GetLearnTaolu()
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  local taolu_list = ""
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    for j = 1, table.getn(sub_type_tab) do
      local sub_type_name = sub_type_tab[j]
      if check_taolu_is_learn(sub_type_name) then
        taolu_list = nx_string(taolu_list) .. "," .. nx_string(sub_type_name) .. ","
      end
    end
  end
  return taolu_list
end
function check_taolu_is_learn(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return false
  end
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, nx_string(taolu_name))
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    local skill = wuxue_query:GetLearnID_Skill(item_name)
    if nx_is_valid(skill) then
      return true
    end
  end
  return false
end
function get_now_group_index(form)
  local text = nx_widestr(form.cbox_taolu.DropListBox:GetString(form.cbox_taolu.DropListBox.SelectIndex))
  for i = 1, table.maxn(cbox_taolu_list) do
    local group = nx_string(cbox_taolu_list[i])
    local _text = util_text(group)
    if text == _text then
      return group
    end
  end
  return ""
end
function SaveTaolu()
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  if not common_array:FindArray(array_name) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local filename = account .. "\\match_taolu.ini"
  clearfile(filename)
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = filename
  ini:LoadFromFile()
  for i = 1, table.maxn(cbox_taolu_list) do
    local ctaolu = nx_string(form.limit_id) .. "_" .. nx_string(cbox_taolu_list[i])
    if ctaolu ~= "" then
      local taolu_1 = common_array:FindChild(array_name, nx_string(ctaolu) .. "_1")
      local taolu_2 = common_array:FindChild(array_name, nx_string(ctaolu) .. "_2")
      local taolu_3 = common_array:FindChild(array_name, nx_string(ctaolu) .. "_3")
      local taolu_4 = common_array:FindChild(array_name, nx_string(ctaolu) .. "_4")
      if taolu_1 == nil then
        taolu_1 = ""
      end
      if taolu_2 == nil then
        taolu_2 = ""
      end
      if taolu_3 == nil then
        taolu_3 = ""
      end
      if taolu_4 == nil then
        taolu_4 = ""
      end
      ini:WriteString(ctaolu, "taolu1", nx_string(taolu_1))
      ini:WriteString(ctaolu, "taolu2", nx_string(taolu_2))
      ini:WriteString(ctaolu, "taolu3", nx_string(taolu_3))
      ini:WriteString(ctaolu, "taolu4", nx_string(taolu_4))
    end
  end
  ini:SaveToFile()
  nx_pause(0.1)
  nx_destroy(ini)
end
function clearfile(filename)
  local file = io.open(filename, "w")
  file:write("")
  file:close()
end
function record_oper_info(msgType, msg_info)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_RECEIVE_LOG_MSG), nx_int(msgType), nx_string(msg_info))
end
function show_all_taolu(form)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local root = form.tree_types:CreateRootNode(nx_widestr(""))
  local type_tab = wuxue_query:GetMainNames(WUXUE_SKILL)
  form.tree_types:BeginUpdate()
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    local sub_type_tab = wuxue_query:GetSubNames(WUXUE_SKILL, type_name)
    local sub_type_len = table.getn(sub_type_tab)
    if 0 < sub_type_len then
      local temp_taolu_list = ""
      for j = 1, sub_type_len do
        local sub_type_name = sub_type_tab[j]
        if check_taolu_is_learn(sub_type_name) and not is_ban(form, sub_type_name) then
          temp_taolu_list = nx_string(temp_taolu_list) .. nx_string(sub_type_name) .. ","
        end
      end
      if temp_taolu_list ~= "" then
        type_node = root:CreateNode(gui.TextManager:GetText(type_name))
        set_node_prop(type_node, 1)
        local lst = util_split_string(temp_taolu_list, ",")
        for i = 1, table.getn(lst) do
          if nx_string(lst[i]) ~= nx_string("") then
            local sub_type_node = type_node:CreateNode(gui.TextManager:GetText(nx_string(lst[i])))
            if nx_is_valid(sub_type_node) then
              sub_type_node.type_name = nx_string(lst[i])
              set_node_prop(sub_type_node, 2)
            end
          end
        end
      end
    end
  end
  root.Expand = true
  form.tree_types:EndUpdate()
end
function set_node_prop(node, index)
  if not nx_is_valid(node) then
    return 0
  end
  if 0 > nx_number(index) or nx_number(index) > table.getn(NODE_PROP) then
    return 0
  end
  for prop_name, value in pairs(NODE_PROP[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
end
function get_empty_taolu_option_ctrl(form)
  local normal_ctrl, sanzhao_ctrl
  if form.lbl_taolu_1.Text == nx_widestr("") then
    normal_ctrl = form.lbl_taolu_1
  elseif form.lbl_taolu_2.Text == nx_widestr("") then
    normal_ctrl = form.lbl_taolu_2
  elseif form.lbl_taolu_3.Text == nx_widestr("") then
    normal_ctrl = form.lbl_taolu_3
  end
  if form.lbl_taolu_4.Text == nx_widestr("") then
    sanzhao_ctrl = form.lbl_taolu_4
  end
  return normal_ctrl, sanzhao_ctrl
end
function sel_taolu_is_repeat(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local taolu_name = gui.TextManager:GetText(form.sel_taolu)
  if form.lbl_taolu_1.Text == taolu_name then
    return true
  elseif form.lbl_taolu_2.Text == taolu_name then
    return true
  elseif form.lbl_taolu_3.Text == taolu_name then
    return true
  elseif form.lbl_taolu_4.Text == taolu_name then
    return true
  else
    return false
  end
end
function set_ctrl_enabled(form, ctrl_name, enabled)
  if not nx_is_valid(form) then
    return
  end
  local ctrl = nx_custom(form, nx_string(ctrl_name))
  if not nx_is_valid(ctrl) then
    return
  end
  ctrl.Enabled = enabled
end
function check_btn_del_enable(form, index)
  if not nx_is_valid(form) then
    return
  end
  local ctrl
  if index ~= nil then
    ctrl = form.groupbox_taolu:Find("lbl_taolu_" .. nx_string(i))
  end
  if ctrl == nil or not nx_is_valid(ctrl) then
    for i = 1, 4 do
      ctrl = form.groupbox_taolu:Find("lbl_taolu_" .. nx_string(i))
      if nx_is_valid(ctrl) then
        if nx_widestr(ctrl.Text) == nx_widestr("") then
          set_ctrl_enabled(form, "btn_del_" .. nx_string(i), false)
        else
          set_ctrl_enabled(form, "btn_del_" .. nx_string(i), true)
        end
      end
    end
  elseif nx_widestr(ctrl.Text) == nx_widestr("") then
    set_ctrl_enabled(form, "btn_del_" .. nx_string(i), false)
  else
    set_ctrl_enabled(form, "btn_del_" .. nx_string(i), true)
  end
end
function is_sanzhao(taolu_id)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return false
  end
  if not common_array:FindArray(sz_array_name) then
    return false
  end
  local sanzhao_taolu = common_array:FindChild(sz_array_name, nx_string(taolu_id))
  return sanzhao_taolu ~= nil
end
function sel_taolu_can_put_in(form)
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  if not nx_find_custom(form, "sel_taolu") then
    return false
  end
  local normal_ctrl, sanzhao_ctrl = get_empty_taolu_option_ctrl(form)
  local taolu_name = gui.TextManager:GetText(form.sel_taolu)
  if is_sanzhao(form.sel_taolu) then
    if sanzhao_ctrl ~= nil and nx_is_valid(sanzhao_ctrl) then
      return true
    else
      return false
    end
  elseif normal_ctrl ~= nil and nx_is_valid(normal_ctrl) then
    return true
  else
    return false
  end
end
function check_btn_add_enable(form)
  if form.sel_taolu ~= "" and sel_taolu_can_put_in(form) == true and sel_taolu_is_repeat(form) == false then
    form.btn_add.Enabled = true
  else
    form.btn_add.Enabled = false
  end
end
function set_node_select(tree, cur_node, pre_node)
  if not nx_is_valid(tree) or not nx_is_valid(cur_node) then
    return false
  end
  if nx_is_valid(pre_node) and nx_id_equal(cur_node, pre_node.ParentNode) then
    tree.SelectNode = pre_node
    return false
  end
  local child = cur_node:GetNodeList()
  if table.getn(child) <= 0 then
    if nx_is_valid(pre_node) then
      if nx_find_custom(pre_node, "unknown") then
        pre_node.ForeColor = UNKNOWN_NODE_NORMAL
      else
        pre_node.ForeColor = FORE_COLOR_NORMAL
      end
      if not nx_id_equal(pre_node, cur_node.ParentNode) and nx_is_valid(pre_node.ParentNode) and 0 >= pre_node:GetNodeCount() then
        pre_node.ParentNode.Expand = false
      end
    end
    if nx_find_custom(cur_node, "unknown") then
      cur_node.ForeColor = UNKNOWN_NODE_SELECT
    else
      cur_node.ForeColor = FORE_COLOR_SELECT
    end
    if nx_is_valid(cur_node.ParentNode) then
      cur_node.ParentNode.Expand = true
    end
    return true
  else
    if nx_is_valid(pre_node) and nx_is_valid(pre_node.ParentNode) then
      pre_node.ParentNode.Expand = false
      pre_node.ForeColor = FORE_COLOR_NORMAL
    end
    cur_node.Expand = true
    tree.SelectNode = child[1]
    return false
  end
  return false
end
function on_tree_types_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.sel_taolu = ""
  if not nx_find_custom(cur_node, "type_name") then
    check_btn_add_enable(form)
    return
  end
  form.sel_taolu = cur_node.type_name
  check_btn_add_enable(form)
end
function on_tree_types_mouse_in_node(tree, node, x, y)
end
function on_tree_types_mouse_out_node(tree, node, x, y)
end
function check_can_submit(form)
  if not nx_is_valid(form) then
    return
  end
  local is_can = true
  for i = 1, 4 do
    ctrl = form.groupbox_taolu:Find("lbl_taolu_" .. nx_string(i))
    if nx_is_valid(ctrl) and nx_find_custom(ctrl, "taolu_id") and ctrl.taolu_id ~= nx_string("") then
      if is_ban(form, ctrl.taolu_id) then
        is_can = false
        ctrl.ForeColor = "255,255,0,0"
      else
        ctrl.ForeColor = "255,255,255,255"
      end
    end
  end
  if not is_can then
    form.btn_submit.Enabled = false
  else
    form.btn_submit.Enabled = true
  end
end
function is_ban(form, taolu_id)
  if not nx_is_valid(form) then
    return false
  end
  local lst = util_split_string(form.textgrid_ban_taolu.DataSource, ",")
  for i = 1, table.getn(lst) do
    if nx_string(taolu_id) == nx_string(lst[i]) then
      return true
    end
  end
  return false
end
