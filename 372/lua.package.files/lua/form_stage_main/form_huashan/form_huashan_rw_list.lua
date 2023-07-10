require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local m_Rank = {
  [0] = {
    number = 0,
    photo = "",
    image = "",
    text = ""
  },
  [8] = {
    number = 1,
    photo = "gui\\language\\ChineseS\\huashan\\num_1.png",
    image = "huashan_num_1",
    text = "round_8"
  },
  [7] = {
    number = 2,
    photo = "gui\\language\\ChineseS\\huashan\\num_2.png",
    image = "huashan_num_2",
    text = "round_7"
  },
  [6] = {
    number = 3,
    photo = "gui\\language\\ChineseS\\huashan\\num_3.png",
    image = "huashan_num_3",
    text = "round_4"
  },
  [5] = {
    number = 4,
    photo = "gui\\language\\ChineseS\\huashan\\num_4.png",
    image = "huashan_num_4",
    text = "round_6"
  },
  [4] = {
    number = 5,
    photo = "gui\\language\\ChineseS\\huashan\\num_5.png",
    image = "huashan_num_5",
    text = "round_5"
  },
  [3] = {
    number = 6,
    photo = "gui\\language\\ChineseS\\huashan\\baqiang.png",
    image = "",
    text = "round_3"
  },
  [2] = {
    number = 7,
    photo = "gui\\language\\ChineseS\\huashan\\16qiang.png",
    image = "",
    text = "round_2"
  },
  [1] = {
    number = 8,
    photo = "gui\\language\\ChineseS\\huashan\\32qiang.png",
    image = "",
    text = "round_1"
  }
}
function main_form_init(form)
  form.Fixed = true
  form.arrayList_rw = nil
  form.arrayList_detail = nil
  form.arrayList_notes = nil
  form.actionpose = ""
  form.actionfree = ""
end
function on_main_form_open(form)
  ui_ClearModel(form.scenebox_player)
  form.scenebox_player.Transparent = true
  if not nx_is_valid(form.scenebox_player.Scene) then
    util_addscene_to_scenebox(form.scenebox_player)
  end
  if not nx_is_valid(form.arrayList_rw) then
    form.arrayList_rw = get_arraylist("form_huashan_rw_list_arraylist")
  end
  form.arrayList_rw:ClearChild()
  if not nx_is_valid(form.arrayList_detail) then
    form.arrayList_detail = get_global_arraylist("form_huashan_list_detail")
  end
  if not nx_is_valid(form.arrayList_notes) then
    form.arrayList_notes = get_arraylist("form_huashan_list_detail")
  end
  form.arrayList_notes:ClearChild()
  init_conf(form)
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[2], "on_server_msg_list", HuaShanCToS_ReqPlayerList)
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[2], "on_server_msg_notes", HuaShanCToS_ReqFightLog)
  form.btn_ballot_mvp.Visible = get_mvp_star()
end
function on_main_form_close(form)
  ui_ClearModel(form.scenebox_player)
  if nx_is_valid(form.arrayList_rw) then
    nx_destroy(form.arrayList_rw)
  end
  if nx_is_valid(form.arrayList_detail) then
    nx_destroy(form.arrayList_detail)
  end
  if nx_is_valid(form.arrayList_notes) then
    nx_destroy(form.arrayList_notes)
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_btn_enable", form)
  end
  nx_destroy(form)
end
function on_btn_fresh_click(btn)
  btn.Enabled = false
  nx_execute(m_Main_Path, "on_custom_msg", m_child_list[2], "on_server_msg_list", HuaShanCToS_ReqPlayerList)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(30000, 1, nx_current(), "refresh_btn_enable", btn, -1, -1)
  end
end
function on_btn_lottery_click(btn)
  nx_execute(m_Lottery_Path, "open_form")
end
function on_btn_gamble_click(btn)
  nx_execute("form_stage_main\\form_huashan\\form_gamble_main_huashan", "open_form")
end
function refresh_btn_enable(btn)
  if nx_is_valid(btn) then
    btn.Enabled = true
  end
end
function on_server_msg_notes(...)
  if HuaShanSToC_ReqFightLog ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[2])
  if not nx_is_valid(form) then
    return
  end
  local j = 2
  for i = 1, 999 do
    if nil == arg[j] or "" == nx_string(arg[j]) then
      break
    end
    local child = form.arrayList_notes:CreateChild("zd_notes_" .. nx_string(i))
    if not nx_is_valid(child) then
      break
    end
    nx_set_custom(child, "winner", get_name(arg[j]))
    j = j + 1
    nx_set_custom(child, "loseer", get_name(arg[j]))
    j = j + 1
    nx_set_custom(child, "phase", arg[j])
    j = j + 1
    nx_set_custom(child, "time", arg[j])
    j = j + 1
    nx_set_custom(child, "score", arg[j])
    j = j + 1
  end
end
function on_server_msg_list(...)
  if HuaShanSToC_ReqPlayerList ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[2])
  if not nx_is_valid(form) then
    return
  end
  form.arrayList_rw:ClearChild()
  local i = 2
  while true do
    if not (i < 99) or nil == arg[i] then
      break
    end
    if nx_string(arg[i]) ~= "" and m_Name_NULL ~= nx_string(arg[i]) then
      local name = nx_widestr(arg[i])
      local child_data = form.arrayList_rw:CreateChild(nx_string(name))
      nx_set_custom(child_data, "playername", name)
      i = i + 1
      nx_set_custom(child_data, "Grade", arg[i])
      i = i + 1
    else
      i = i + 2
    end
  end
  fresh_from(form)
end
function fresh_from(form)
  if not nx_is_valid(form.arrayList_rw) then
    return
  end
  local gui = nx_value("gui")
  clearform(form)
  local grid = form.textgrid_list
  grid.RowHeaderVisible = false
  grid:SetColAlign(2, "center")
  grid:BeginUpdate()
  local rw_list = form.arrayList_rw:GetChildList()
  for i, child_data in ipairs(rw_list) do
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(i))
    grid:SetGridText(row, 1, nx_widestr(child_data.playername))
    local backimage = nx_string(m_Rank[child_data.Grade].photo)
    if "" ~= backimage then
      local groupbox = gui:Create("GroupBox")
      groupbox.Name = "GroupBox_" .. nx_string(i)
      groupbox.Width = grid:GetColWidth(2)
      groupbox.Height = grid.RowHeight
      groupbox.BackColor = "0,255,255,255"
      groupbox.NoFrame = true
      local lbl_back = gui:Create("Label")
      lbl_back.Name = "lbl_back_" .. nx_string(i)
      lbl_back.AutoSize = true
      lbl_back.BackImage = backimage
      lbl_back.Top = (groupbox.Height - lbl_back.Height) / 2
      groupbox:Add(lbl_back)
      grid:SetGridControl(row, 2, groupbox)
    end
    grid:SetGridText(row, 3, nx_widestr(m_Rank[child_data.Grade].number))
  end
  grid:EndUpdate()
  grid:SortRowsByInt(3, false)
  grid:SelectRow(0)
end
function clearform(form)
  form.textgrid_list:ClearRow()
  cleardetailform(form)
end
function cleardetailform(form)
  local scene = form.scenebox_player.Scene
  if nx_find_custom(scene, "model") and nx_is_valid(scene.model) then
    scene:Delete(scene.model)
  end
  form.lbl_name.Text = nx_widestr("")
  form.lbl_lvl.Text = nx_widestr("")
  form.lbl_school.Text = nx_widestr("")
  form.lbl_gang.Text = nx_widestr("")
  form.lbl_ng.Text = nx_widestr("")
  form.lbl_tl.Text = nx_widestr("")
  form.lbl_qg.Text = nx_widestr("")
  form.lbl_jm.Text = nx_widestr("")
  form.lbl_wjc.Text = nx_widestr("")
  form.lbl_rank.BackImage = ""
end
function on_textgrid_list_select_row(grid, row)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local playername = nx_widestr(grid:GetGridText(row, 1))
  local child_data = form.arrayList_rw:GetChild(nx_string(playername))
  if not nx_is_valid(child_data) then
    return
  end
  local child_detail = form.arrayList_detail:GetChild(nx_string(playername))
  if not nx_is_valid(child_detail) then
    nx_execute(m_Main_Path, "on_custom_msg", m_child_list[2], "on_server_msg_detail", HuaShanCToS_ReqPlayerInfo, playername)
    return
  end
  fresh_from_detail(form, child_detail)
end
function on_server_msg_detail(...)
  if HuaShanSToC_ReqPlayerInfo ~= arg[1] then
    return
  end
  local form = nx_value(m_child_list[2])
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.arrayList_rw) then
    return
  end
  if not nx_is_valid(form.arrayList_detail) then
    return
  end
  local name = nx_widestr(arg[2])
  if name ~= form.textgrid_list:GetGridText(form.textgrid_list.RowSelectIndex, 1) then
    return
  end
  local child_data = form.arrayList_rw:GetChild(nx_string(name))
  if not nx_is_valid(child_data) then
    return
  end
  if form.arrayList_detail:FindChild(nx_string(name)) then
    return
  end
  local child_detail = form.arrayList_detail:CreateChild(nx_string(name))
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
  nx_set_custom(child_detail, "Grade", arg[12])
  local role_info_data = child_detail:CreateChild("role_info")
  if nx_is_valid(role_info_data) and not analysis_role_info(child_detail.RoleInfo, role_info_data) then
    child_detail:RemoveChildByID(role_info_data)
  end
  fresh_from_detail(form, child_detail)
end
function fresh_from_detail(form, child_data)
  cleardetailform(form)
  if not nx_is_valid(child_data) then
    return
  end
  if "" == nx_string(child_data.RoleInfo) then
    return
  end
  local role_info_data = child_data:GetChild("role_info")
  if nx_is_valid(role_info_data) and add_player_model(form.scenebox_player, role_info_data) then
    change_action(form.scenebox_player, get_random_action(form.actionfree))
    do_once_action(form.scenebox_player, get_random_action(form.actionpose))
  end
  form.lbl_tt.Visible = false
  form.lbl_rank.BackImage = ""
  if nx_find_custom(child_data, "Grade") then
    if 0 ~= nx_number(child_data.Grade) and 1 ~= nx_number(child_data.Grade) then
      form.lbl_tt.BackImage = ""
      form.lbl_tt.Visible = true
    end
    form.lbl_rank.BackImage = m_Rank[child_data.Grade].image
  end
  local name = nx_widestr(child_data.playername)
  form.lbl_name.Text = name
  if nx_is_valid(role_info_data) then
    local gui = nx_value("gui")
    local lvlname = gui.TextManager:GetText("desc_" .. role_info_data.level_title)
    form.lbl_lvl.Text = nx_widestr(lvlname)
  end
  form.lbl_school.Text = util_text(child_data.School)
  form.lbl_gang.Text = nx_widestr(child_data.Guild)
  form.lbl_ng.Text = nx_widestr(child_data.NeiGongNum)
  form.lbl_tl.Text = nx_widestr(child_data.SkillNum)
  form.lbl_qg.Text = nx_widestr(child_data.QingGongNum)
  form.lbl_jm.Text = nx_widestr(child_data.XueWeiNum)
  form.lbl_wjc.Text = nx_widestr(child_data.WuJiCaoNum)
  local multex = form.mltbox_sszj
  multex:Clear()
  if not nx_is_valid(form.arrayList_notes) then
    return ""
  end
  for i, child in ipairs(form.arrayList_notes:GetChildList()) do
    if not nx_is_valid(child) then
      break
    end
    if nx_widestr(child.winner) == name or nx_widestr(child.loseer) == name then
      local len = string.len(nx_string(child.time))
      local str_time = nx_string(child.time)
      if 3 == len then
        local str_temp = string.sub(str_time, 1, 1)
        str_temp = str_temp .. ":" .. string.sub(str_time, 3)
        str_time = str_temp
      elseif 4 == len then
        local str_temp = string.sub(str_time, 1, 2)
        str_temp = str_temp .. ":" .. string.sub(str_time, 3)
        str_time = str_temp
      end
      local phase = nx_number(child.phase)
      if phase < 0 or 8 < phase then
        break
      end
      local rankchild = m_Rank[phase]
      if nil == rankchild then
        return
      end
      multex:AddHtmlText(util_text(rankchild.text) .. nx_widestr("   ") .. nx_widestr(str_time), -1)
      multex:AddHtmlText(nx_widestr(child.winner) .. nx_widestr(" ") .. util_text("ui_defeat") .. nx_widestr(" ") .. nx_widestr(child.loseer), -1)
    end
  end
end
function init_conf(form)
  if not nx_is_valid(form) then
    return
  end
  local huashan_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\huashan\\huashanlunjian.ini")
  if not nx_is_valid(huashan_ini) then
    return
  end
  local sec_index = huashan_ini:FindSectionIndex("personal_action")
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
  local action_table = util_split_string(actions, ",")
  local index = math.random(table.getn(action_table))
  return nx_string(action_table[index])
end
function get_mvp_star()
  local mgr = nx_value("SwitchManager")
  if not nx_is_valid(mgr) then
    return false
  end
  return mgr:CheckSwitchEnable(ST_FUNCTION_HUASHAN_MVP)
end
function on_btn_ballot_mvp_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_huashan\\form_huashan_tp_mvp")
end
