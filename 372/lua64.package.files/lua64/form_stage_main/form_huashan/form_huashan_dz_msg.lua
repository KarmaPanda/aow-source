require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_functions")
require("util_gui")
local m_Group = {
  16,
  8,
  4,
  222,
  111,
  2,
  34,
  1
}
local m_Group_Name = {
  [16] = "round_1",
  [8] = "round_2",
  [4] = "round_3",
  [2] = "round_4",
  [1] = "round_8",
  [34] = "round_7",
  [222] = "round_5",
  [111] = "round_6"
}
local m_Scene_NP = {
  [1] = {
    name = "@ui_area_1",
    photo = "gui\\special\\huashan\\form_back_1.png"
  },
  [2] = {
    name = "@ui_area_2",
    photo = "gui\\special\\huashan\\form_back_2.png"
  },
  [3] = {
    name = "@ui_area_3",
    photo = "gui\\special\\huashan\\form_back_3.png"
  },
  [4] = {
    name = "@ui_area_4",
    photo = "gui\\special\\huashan\\form_back_4.png"
  },
  [5] = {
    name = "@ui_area_5",
    photo = "gui\\special\\huashan\\form_back_5.png"
  },
  [6] = {
    name = "@ui_area_6",
    photo = "gui\\special\\huashan\\form_back_6.png"
  }
}
local m_Str = "HS_DZ_MSG"
function main_form_init(form)
  form.Fixed = true
  form.max = table.getn(m_Group)
  form.num = 1
  form.arrayList_nq = nil
  form.arrayList_detail = nil
  form.actionpose = ""
  form.actionfree = ""
  form.lastSelectGroup = nil
end
function on_main_form_open(form)
  local rbtnback
  for i = 1, form.num do
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(i))
    rbtn.index = i
    if 1 == i then
      rbtnback = rbtn
    end
    rbtn.Enabled = false
  end
  init_conf(form)
  if not nx_is_valid(form.arrayList_nq) then
    form.arrayList_nq = get_arraylist("form_huashan_dz_msg_list")
  end
  form.arrayList_nq:ClearChild()
  if not nx_is_valid(form.arrayList_detail) then
    form.arrayList_detail = get_global_arraylist("form_huashan_list_detail")
  end
  ui_ClearModel(form.scenebox_v)
  form.scenebox_v.Transparent = true
  if not nx_is_valid(form.scenebox_v.Scene) then
    util_addscene_to_scenebox(form.scenebox_v)
  end
  ui_ClearModel(form.scenebox_s)
  form.scenebox_s.Transparent = true
  if not nx_is_valid(form.scenebox_s.Scene) then
    util_addscene_to_scenebox(form.scenebox_s)
  end
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_list_first", HuaShanCToS_ReqVSList, -1)
end
function on_main_form_close(form)
  if nx_is_valid(form.arrayList_nq) then
    nx_destroy(form.arrayList_nq)
  end
  if nx_is_valid(form.arrayList_detail) then
    nx_destroy(form.arrayList_detail)
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_btn_enable", form)
  end
  nx_destroy(form)
end
function on_rbtn_click(rbtn)
  rbtn.Checked = true
  local form = rbtn.ParentForm
  rbtn.Text = nx_widestr(nx_string(rbtn.index) .. "/" .. nx_string(form.max))
  local gui = nx_value("gui")
  local str = gui.TextManager:GetText(m_Group_Name[m_Group[rbtn.index]])
  form.lbl_title.Text = nx_widestr(str)
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_list", HuaShanCToS_ReqVSList, m_Group[rbtn.index])
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  change_index(form, -1)
  local rbtn = get_select_rbtn(form)
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Text = nx_widestr(nx_string(rbtn.index) .. "/" .. nx_string(form.max))
  local gui = nx_value("gui")
  local str = gui.TextManager:GetText(m_Group_Name[m_Group[rbtn.index]])
  form.lbl_title.Text = nx_widestr(str)
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  change_index(form, 1)
  local rbtn = get_select_rbtn(form)
  if not nx_is_valid(rbtn) then
    return
  end
  rbtn.Text = nx_widestr(nx_string(rbtn.index) .. "/" .. nx_string(form.max))
  local gui = nx_value("gui")
  local str = gui.TextManager:GetText(m_Group_Name[m_Group[rbtn.index]])
  form.lbl_title.Text = nx_widestr(str)
end
function on_btn_look_click(btn)
  local lookform = nx_value(m_WuLin_Path)
  if nx_is_valid(lookform) then
    self_systemcenterinfo(1000074)
    return
  end
  local client_player = get_player()
  if not nx_is_valid(client_player) then
    return
  end
  local client_scene = get_scene()
  if not nx_is_valid(client_scene) then
    return
  end
  local scene_res = client_scene:QueryProp("Resource")
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  if nx_number(map_query:GetSceneId(scene_res)) ~= 70 then
    self_systemcenterinfo(1000058)
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form.groupbox_dz_detail, "group_state") then
    return
  end
  if not nx_find_custom(form.groupbox_dz_detail, "group_area") then
    return
  end
  if not nx_find_custom(form.groupbox_dz_detail, "group_listnum") then
    return
  end
  if 1 == form.groupbox_dz_detail.group_state then
    self_systemcenterinfo(1000059)
    return
  end
  local cd_number = form.groupbox_dz_detail.group_area
  if nil == m_Scene_NP[cd_number].name then
    return
  end
  local playerA = nx_widestr(form.lbl_name_v.Text)
  local playerB = nx_widestr(form.lbl_name_s.Text)
  if nx_widestr("") == playerA or nx_widestr("") == playerB then
    self_systemcenterinfo(1000061)
    return
  end
  local tempname = get_name(m_Name_NULL)
  if playerA == tempname or playerB == tempname then
    self_systemcenterinfo(1000061)
    return
  end
  tempname = nx_widestr(client_player:QueryProp("Name"))
  if playerA == tempname or playerB == tempname then
    self_systemcenterinfo(1000060)
    return
  end
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_look", HuaShanCToS_ReqAsLooker, cd_number, playerA, playerB)
end
function on_server_msg_look(...)
  if HuaShanSToC_ReqAsLooker ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[3])
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form.groupbox_dz_detail, "group_state") then
    return
  end
  if nx_number(form.groupbox_dz_detail.group_area) ~= nx_number(arg[2]) then
    return
  end
  local playerA = nx_widestr(arg[3])
  local playerB = nx_widestr(arg[4])
  nx_execute(m_WuLin_Path, "on_open_form", playerA, playerB)
end
function on_btn_fresh_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Enabled = false
  local rbtn = get_select_rbtn(form)
  if not nx_is_valid(rbtn) then
    return
  end
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_list", HuaShanCToS_ReqVSList, m_Group[rbtn.index])
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(30000, 1, nx_current(), "refresh_btn_enable", btn, -1, -1)
  end
end
function refresh_btn_enable(btn)
  if nx_is_valid(btn) then
    btn.Enabled = true
  end
end
function on_btn_pour_click(btn)
end
function on_server_msg_list_first(...)
  if HuaShanSToC_ReqVSList ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[3])
  if not nx_is_valid(form) then
    return
  end
  local index = nx_number(arg[2])
  local ishave = false
  for i, groupid in ipairs(m_Group) do
    if groupid == index then
      ishave = true
      index = i
      break
    end
  end
  if not ishave then
    return
  end
  local rbtnback
  for i = 1, form.num do
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(i))
    if 1 == i then
      rbtnback = rbtn
    end
    rbtn.index = index + (i - 1)
    if 1 > rbtn.index or rbtn.index > form.max then
      rbtn.Visible = false
    else
      rbtn.Visible = true
    end
  end
  on_rbtn_click(rbtnback)
end
function on_server_msg_list(...)
  if HuaShanSToC_ReqVSList ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[3])
  if not nx_is_valid(form) then
    return
  end
  local rbtn = get_select_rbtn(form)
  if not nx_is_valid(rbtn) then
    return
  end
  if arg[2] ~= m_Group[rbtn.index] then
    return
  end
  local group = get_child_obj(form.arrayList_nq, m_Str .. nx_string(arg[2]), true)
  if not nx_is_valid(group) then
    return
  end
  group:ClearChild()
  local i = 3
  local j = 1
  while true do
    if not (i < 999) or nil == arg[i] or "" == nx_string(arg[i]) then
      break
    end
    local team = get_child_obj(group, m_Str .. nx_string(arg[2]) .. nx_string(j), true)
    if not nx_is_valid(team) then
      break
    end
    nx_set_custom(team, "group_number", arg[2])
    nx_set_custom(team, "list_num", j)
    j = j + 1
    nx_set_custom(team, "fight_v", get_name(arg[i]))
    i = i + 1
    nx_set_custom(team, "fight_s", get_name(arg[i]))
    i = i + 1
    nx_set_custom(team, "score_v", arg[i])
    i = i + 1
    nx_set_custom(team, "score_s", arg[i])
    i = i + 1
    nx_set_custom(team, "winner", get_name(arg[i]))
    i = i + 1
    nx_set_custom(team, "area", arg[i])
    i = i + 1
    nx_set_custom(team, "loser", get_name(arg[i]))
    i = i + 1
    nx_set_custom(team, "status", arg[i])
    i = i + 1
  end
  fresh_from(form, m_Group[rbtn.index])
end
function fresh_from(form, group_number)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local playername = nx_widestr(player:QueryProp("Name"))
  if not nx_is_valid(form.arrayList_nq) then
    return
  end
  clearform(form)
  local groupboxmain = form.groupscrollbox_dz_list
  local group = get_child_obj(form.arrayList_nq, m_Str .. nx_string(group_number), false)
  if not nx_is_valid(group) then
    return
  end
  groupboxmain.IsEditMode = true
  local gui = nx_value("gui")
  local selectbtnback
  local childlist = group:GetChildList()
  for i, child in ipairs(childlist) do
    if not nx_is_valid(child) then
      break
    end
    local groupbox = gui:Create("GroupBox")
    groupboxmain:Add(groupbox)
    groupbox.Name = "GroupBox_" .. m_Str .. nx_string(group_number) .. nx_string(child.list_num)
    groupbox.Width = groupboxmain.Width - 15
    groupbox.Height = 75
    groupbox.Left = 0
    groupbox.Top = 75 * (i - 1) + 9
    groupbox.DrawMode = "ExpandV"
    local str_backimage = ""
    local state = 1
    if nx_widestr("") == nx_widestr(child.winner) then
      str_backimage = "gui\\special\\huashan\\lab_saichengbiao_3.png"
      state = 0
    elseif nx_widestr(child.fight_v) == nx_widestr(child.winner) then
      str_backimage = "gui\\special\\huashan\\lab_saichengbiao_1.png"
    elseif nx_widestr(child.fight_s) == nx_widestr(child.winner) then
      str_backimage = "gui\\special\\huashan\\lab_saichengbiao_4.png"
    else
      str_backimage = "gui\\special\\huashan\\lab_saichengbiao_2.png"
    end
    groupbox.BackImage = str_backimage
    local name_v = gui:Create("Label")
    groupbox:Add(name_v)
    name_v.Name = "lbl_" .. m_Str .. "name_v" .. nx_string(i)
    name_v.Left = 20
    name_v.Top = 13
    name_v.ForeColor = "255,255,255,255"
    name_v.Font = "HyperLink2"
    name_v.Align = "Center"
    name_v.Text = nx_widestr(child.fight_v)
    local name_s = gui:Create("Label")
    groupbox:Add(name_s)
    name_s.Name = "lbl_" .. m_Str .. "name_s" .. nx_string(i)
    name_s.Left = 20
    name_s.Top = 47
    name_s.ForeColor = "255,255,255,255"
    name_s.Font = "HyperLink2"
    name_s.Align = "Center"
    name_s.Text = nx_widestr(child.fight_s)
    local winner = gui:Create("Label")
    groupbox:Add(winner)
    winner.Name = "lbl_" .. m_Str .. "winner" .. nx_string(i)
    winner.Left = 130
    winner.Top = 30
    winner.ForeColor = "255,254,204,0"
    winner.Font = "HyperLink2"
    winner.Text = nx_widestr(child.winner)
    local ismatch = nx_number(child.status)
    if 0 < ismatch then
      local lbl_ani = gui:Create("Label")
      groupbox:Add(lbl_ani)
      lbl_ani.Name = "lbl_" .. m_Str .. "_ani_" .. nx_string(i)
      lbl_ani.Text = nx_widestr("")
      lbl_ani.Left = 0
      lbl_ani.Top = -14
      lbl_ani.BackImage = "huashan_kuang_4"
      lbl_ani.AutoSize = false
      lbl_ani.Width = groupbox.Width
      lbl_ani.Height = groupbox.Height + 30
      lbl_ani.DrawMode = "FitWindow"
    end
    local selectbtn = gui:Create("Button")
    groupbox:Add(selectbtn)
    selectbtn.Name = "btn_info_" .. nx_string(i)
    selectbtn.Left = 0
    selectbtn.Top = 0
    selectbtn.Width = groupbox.Width
    selectbtn.Height = groupbox.Height
    selectbtn.DrawMode = "FitWindow"
    selectbtn.LineColor = "0,0,0,0"
    selectbtn.BackColor = "0,0,0,0"
    selectbtn.NormalImage = "gui\\special\\huashan\\btn_saichengbiao_out.png"
    selectbtn.FocusImage = "gui\\special\\huashan\\btn_saichengbiao_on.png"
    selectbtn.PushImage = "gui\\special\\huashan\\btn_saichengbiao_down.png"
    nx_bind_script(selectbtn, nx_current())
    nx_callback(selectbtn, "on_click", "on_btn_select_click")
    selectbtn.group_number = group_number
    selectbtn.group_listnum = child.list_num
    selectbtn.group_child = child
    selectbtn.group_state = state
    if 1 == i then
      selectbtnback = selectbtn
    end
    if playername == nx_widestr(child.fight_v) or playername == nx_widestr(child.fight_s) then
      selectbtnback = selectbtn
    end
  end
  groupboxmain.IsEditMode = false
  groupboxmain:ResetChildrenYPos()
  local num = table.getn(childlist)
  if 4 < num and nx_is_valid(selectbtnback) and selectbtnback.group_listnum > 4 then
    groupboxmain.VScrollBar.Value = groupboxmain.VScrollBar.Maximum / num * selectbtnback.group_listnum
  end
  on_btn_select_click(selectbtnback)
end
function on_btn_select_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.arrayList_detail) then
    return
  end
  if not nx_is_valid(btn.group_child) then
    return
  end
  if nx_is_valid(form.lastSelectGroup) then
    form.lastSelectGroup.NormalImage = "gui\\special\\huashan\\btn_saichengbiao_out.png"
  end
  btn.NormalImage = "gui\\special\\huashan\\btn_saichengbiao_down.png"
  form.lastSelectGroup = btn
  cleartitleform(form)
  cleardetailform(form, nil)
  local child = btn.group_child
  form.groupbox_dz_detail.group_child = btn.group_child
  form.groupbox_dz_detail.group_number = btn.group_number
  form.groupbox_dz_detail.group_state = btn.group_state
  form.groupbox_dz_detail.group_area = nx_number(child.area)
  form.groupbox_dz_detail.group_listnum = nx_number(btn.group_listnum)
  form.groupbox_dz_detail.group_v = ""
  form.groupbox_dz_detail.group_s = ""
  form.groupbox_dz_detail.group_action_index = get_action_index(form)
  local now_time = os.time()
  local now_date = os.date("*t", now_time)
  local time_str = string.format("%d-%02d-%02d %02d:%02d:%02d", now_date.year, now_date.month, now_date.day, now_date.hour, now_date.min, now_date.sec)
  form.lbl_place.Text = nx_widestr(m_Scene_NP[child.area].name)
  form.lbl_time.Text = nx_widestr(time_str)
  if 1 == form.groupbox_dz_detail.group_state then
    form.lbl_state.Visible = false
  else
    form.lbl_state.Visible = true
  end
  form.BackImage = m_Scene_NP[child.area].photo
  local child_fight_v = get_child_obj(form.arrayList_detail, nx_string(child.fight_v), false)
  if not nx_is_valid(child_fight_v) then
    nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_detail", HuaShanCToS_ReqPlayerInfo, child.fight_v)
  else
    fresh_from_detail(form, child_fight_v)
  end
  local child_fight_s = get_child_obj(form.arrayList_detail, nx_string(child.fight_s), false)
  if not nx_is_valid(child_fight_s) then
    nx_execute(m_Main_Path, "on_custom_msg", m_child_list[3], "on_server_msg_detail", HuaShanCToS_ReqPlayerInfo, child.fight_s)
  else
    fresh_from_detail(form, child_fight_s)
  end
end
function on_btn_join_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, gui.TextManager:GetText("1000119"))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute(m_Main_Path, "on_custom_msg", "", "", HuaShanCToS_AnswerInvote)
  end
end
function on_server_msg_detail(...)
  if HuaShanSToC_ReqPlayerInfo ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[3])
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.arrayList_detail) then
    return
  end
  local name = arg[2]
  if form.arrayList_detail:FindChild(nx_string(name)) then
    return
  end
  local child_detail = get_child_obj(form.arrayList_detail, nx_string(name), true)
  if not nx_is_valid(child_detail) then
    return
  end
  nx_set_custom(child_detail, "playername", name)
  nx_set_custom(child_detail, "School", arg[3])
  nx_set_custom(child_detail, "Guild", arg[4])
  nx_set_custom(child_detail, "PowerLevel", arg[5])
  nx_set_custom(child_detail, "RoleInfo", arg[6])
  nx_set_custom(child_detail, "NeiGongNum", arg[7])
  nx_set_custom(child_detail, "SkillNum", arg[8])
  nx_set_custom(child_detail, "QingGongNum", arg[9])
  nx_set_custom(child_detail, "XueWeiNum", arg[10])
  nx_set_custom(child_detail, "WuJiCaoNum", arg[11])
  nx_set_custom(child_detail, "IsWashOut", arg[12])
  child_detail:CreateChild("role_info")
  local role_info_data = child_detail:GetChild("role_info")
  if nx_is_valid(role_info_data) and not analysis_role_info(child_detail.RoleInfo, role_info_data) then
    child_detail:RemoveChildByID(role_info_data)
  end
  fresh_from_detail(form, child_detail)
end
function fresh_from_detail(form, child)
  local gui = nx_value("gui")
  local flag = ""
  local index = 1
  local group = form.groupbox_dz_detail.group_child
  if not nx_is_valid(group) then
    return
  end
  if child.playername == group.fight_v then
    flag = "v"
    index = 1
  elseif child.playername == group.fight_s then
    flag = "s"
    index = 2
  else
    return
  end
  cleardetailform(form, flag)
  nx_set_custom(form.groupbox_dz_detail, "group_" .. flag, nx_string(group.group_number) .. "_" .. nx_string(group.list_num))
  local groupbox = get_control_obj(form.groupbox_dz_detail, "groupbox_" .. flag)
  if not nx_is_valid(groupbox) then
    return
  end
  local scenebox = get_control_obj(groupbox, "scenebox_" .. flag)
  local role_info_data = child:GetChild("role_info")
  if nx_is_valid(role_info_data) then
    add_player_model(scenebox, role_info_data)
    local free_table = util_split_string(form.actionfree, ";")
    local frees = util_split_string(nx_string(free_table[form.groupbox_dz_detail.group_action_index]), ",")
    if 2 == table.getn(frees) then
      change_action(scenebox, frees[index])
    end
    set_scenebox_post(form)
  end
  local lbl_name = get_control_obj(groupbox, "lbl_name_" .. flag)
  lbl_name.Text = nx_widestr(child.playername)
  local lbl_school = get_control_obj(groupbox, "lbl_school_" .. flag)
  lbl_school.Text = util_text(child.School)
  if nx_is_valid(role_info_data) then
    local lvlname = gui.TextManager:GetText("desc_" .. role_info_data.level_title)
    local lbl_lvl = get_control_obj(groupbox, "lbl_lvl_" .. flag)
    lbl_lvl.Text = nx_widestr(lvlname)
  end
  local lbl_gang = get_control_obj(groupbox, "lbl_gang_" .. flag)
  lbl_gang.Text = nx_widestr(child.Guild)
  local groupbox_times = get_control_obj(groupbox, "groupbox_times_" .. flag)
  for i = 1, nx_number(group["score_" .. flag]) do
    local lbl = gui:Create("Label")
    groupbox_times:Add(lbl)
    lbl.Name = "lbl_" .. m_Str .. "times_" .. flag .. nx_string(i)
    lbl.BackImage = "gui\\special\\huashan\\icon_win.png"
    lbl.AutoSize = true
    lbl.Left = (i - 1) * lbl.Width + 10
    lbl.Top = 0
  end
end
function clearform(form)
  form.groupscrollbox_dz_list:DeleteAll()
  cleartitleform(form)
  cleardetailform(form, nil)
end
function cleartitleform(form)
  form.lbl_place.Text = nx_widestr("")
  form.lbl_time.Text = nx_widestr("")
  form.lbl_state.Text = nx_widestr("")
  form.lbl_state.Visible = false
end
function cleardetailform(form, flag)
  if nil == flag or "v" == flag then
    form.lbl_name_v.Text = nx_widestr("")
    form.lbl_school_v.Text = nx_widestr("")
    form.lbl_lvl_v.Text = nx_widestr("")
    form.lbl_gang_v.Text = nx_widestr("")
    form.groupbox_times_v:DeleteAll()
    local scene_v = form.scenebox_v.Scene
    if nx_find_custom(scene_v, "model") and nx_is_valid(scene_v.model) then
      scene_v:Delete(scene_v.model)
    end
  end
  if nil == flag or "s" == flag then
    form.lbl_name_s.Text = nx_widestr("")
    form.lbl_school_s.Text = nx_widestr("")
    form.lbl_lvl_s.Text = nx_widestr("")
    form.lbl_gang_s.Text = nx_widestr("")
    form.groupbox_times_s:DeleteAll()
    local scene_s = form.scenebox_s.Scene
    if nx_find_custom(scene_s, "model") and nx_is_valid(scene_s.model) then
      scene_s:Delete(scene_s.model)
    end
  end
end
function get_child_obj(father, flag, is_create)
  if not nx_is_valid(father) then
    return nil
  end
  local name = nx_string(flag)
  if not father:FindChild(name) and is_create then
    father:CreateChild(name)
  end
  return father:GetChild(name)
end
function change_index(form, multiply)
  if 0 < multiply then
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(form.num))
    if rbtn.index >= form.max then
      return
    end
  elseif multiply < 0 then
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(1))
    if rbtn.index <= 1 then
      return
    end
  end
  local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(1))
  if multiply < 0 and rbtn.index <= form.num then
    for ii = 1, form.num do
      if rbtn.index % form.num == 0 then
        break
      end
      rbtn.index = rbtn.index + 1
    end
  end
  local rbtnback
  for i = 1, form.num do
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(i))
    if 1 == i then
      rbtnback = rbtn
    end
    rbtn.index = rbtn.index + form.num * multiply
    if rbtn.index < 1 or rbtn.index > form.max then
      rbtn.Visible = false
    else
      rbtn.Visible = true
    end
  end
  on_rbtn_click(rbtnback)
end
function get_control_obj(group, name)
  return group:Find(name)
end
function get_select_rbtn(form)
  for i = 1, form.num do
    local rbtn = get_control_obj(form.groupbox_change, "rbtn_" .. nx_string(i))
    if rbtn.Checked then
      return rbtn
    end
  end
  return nil
end
function init_conf(form)
  if not nx_is_valid(form) then
    return
  end
  local huashan_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\huashan\\huashanlunjian.ini")
  if not nx_is_valid(huashan_ini) then
    return
  end
  local sec_index = huashan_ini:FindSectionIndex("assort_action")
  if sec_index < 0 then
    return
  end
  form.actionpose = huashan_ini:ReadString(sec_index, "actionpose", "")
  form.actionfree = huashan_ini:ReadString(sec_index, "actionfree", "")
end
function get_random_action(actions)
  if "" == actions then
    return ""
  end
  local action_table = util_split_string(actions, ";")
  local index = math.random(table.getn(action_table))
  return nx_string(action_table[index])
end
function set_scenebox_post(form)
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_dz_detail.group_v ~= form.groupbox_dz_detail.group_s then
    return
  end
  local pose_table = util_split_string(form.actionpose, ";")
  local poses = util_split_string(nx_string(pose_table[form.groupbox_dz_detail.group_action_index]), ",")
  if 2 ~= table.getn(poses) then
    return
  end
  do_once_action(form.scenebox_v, poses[1])
  do_once_action(form.scenebox_s, poses[2])
end
function get_action_index(form)
  local pose_table = util_split_string(form.actionpose, ";")
  local free_table = util_split_string(form.actionfree, ";")
  local index = math.random(table.getn(pose_table))
  if nil == free_table[index] then
    return 0
  end
  return index
end
