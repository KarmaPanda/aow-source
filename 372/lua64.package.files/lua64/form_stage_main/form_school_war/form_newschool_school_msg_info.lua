require("util_functions")
require("util_gui")
require("role_composite")
require("define\\gamehand_type")
require("util_vip")
require("share\\view_define")
require("tips_data")
require("share\\server_custom_define")
require("util_static_data")
require("share\\static_data_type")
require("custom_sender")
local form_name = "form_stage_main\\form_school_war\\form_newschool_school_msg_info"
local SUB_REQUEST_NEW_SCHOOL_TRENDS = 0
INI_FORCE_INFO = "share\\War\\new_school_config.ini"
INI_DEVELOP_PROP = "share\\NewSchool\\NianLuoDevelopProp.ini"
FORM_WIDTH_WANFA = 998
FORM_WIDTH = 766
local Cover_Ng_Img = {
  "gui\\create\\school_select\\bq_1n.png",
  "gui\\create\\school_select\\bq_2n.png",
  "gui\\create\\school_select\\bq_3n.png",
  "gui\\create\\school_select\\bq_4n.png"
}
local Cover_Cloth_Img = {
  "gui\\create\\school_select\\bq_dz.png",
  "gui\\create\\school_select\\bq_zs.png",
  "gui\\create\\school_select\\bq_zl.png",
  "gui\\create\\school_select\\bq_zm.png"
}
local ArtPack = {
  ArtPack = "Cloth",
  HatArtPack = "Hat",
  PlantsArtPack = "Pants",
  ShoesArtPack = "Shoes"
}
local str_to_int = {
  newschool_gumu = 1,
  newschool_xuedao = 2,
  newschool_huashan = 3,
  newschool_damo = 4,
  newschool_shenshui = 5,
  newschool_changfeng = 6,
  newschool_nianluo = 7,
  newschool_wuxian = 8,
  newschool_shenji = 9,
  newschool_xingmiao = 10
}
local force_to_repute = {
  newschool_gumu = "repute_gumu",
  newschool_xuedao = "repute_xuedao",
  newschool_huashan = "repute_huashan",
  newschool_damo = "repute_damo",
  newschool_shenshui = "repute_shenshui",
  newschool_changfeng = "repute_changfeng",
  newschool_nianluo = "repute_nianluoba",
  newschool_wuxian = "repute_wuxian",
  newschool_shenji = "repute_shenji",
  newschool_xingmiao = "repute_xingmiao"
}
local force_sf_pos = {}
local force_to_rule = {
  newschool_gumu = "ui_schoollaw_rule_gumu",
  newschool_xuedao = "ui_schoollaw_rule_xuedao",
  newschool_huashan = "ui_schoollaw_rule_huashan",
  newschool_damo = "ui_schoollaw_rule_damo",
  newschool_shenshui = "ui_schoollaw_rule_shenshui",
  newschool_changfeng = "ui_schoollaw_rule_changfeng",
  newschool_nianluo = "ui_schoollaw_rule_nianluo",
  newschool_wuxian = "ui_schoollaw_rule_wuxian"
}
local condition_pack = {}
local lot_title = {
  "0,199,ui_lot_title_01",
  "200,999999,ui_lot_title_02"
}
local STC_SchoolMsg = 0
local gg_msg = "gg"
local ry_msg = "ry"
local cf_msg = "cf"
local kickout_force_value = 400
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2 + 111
  form.Top = (gui.Height - form.Height) / 2
  load_fqfs(form)
  load_ssg_yjp(form)
  form.new_school_info = get_arraylist("new_school_info")
  form.new_school_info:ClearChild()
  form.force_round_task_info = get_arraylist("force_round_task_info")
  form.force_round_task_info:ClearChild()
  form.force_task_info = get_arraylist("force_task_info")
  form.force_task_info:ClearChild()
  form.school = get_force(form)
  InitMsg(form)
  InitDate(form)
  BingBoxToBtn(form)
  InitRuleDate(form)
  form.actor2 = nil
  set_force(form)
  form.grp_tvt_info.Visible = false
  form.grp_shaqi_info.Visible = false
  form.grp_task.Visible = false
  form.task_id = 0
  form.tvt_type = 0
  query_condtion_msg()
  form.Width = FORM_WIDTH
  form.task_id = 0
  form.cloth = ""
  form.cloth_offset = 0
  form.neigong = ""
  form.neigong_offset = 0
  form.taolu = ""
  form.taolu_offset = 0
end
function hide_or_show(form)
  local base_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLibase.ini")
  if not nx_is_valid(base_ini) then
    return
  end
  local nIndex = base_ini:FindSectionIndex(nx_string(form.school))
  local str_lal = base_ini:ReadString(nIndex, "Label", "")
  local name_list = util_split_string(str_lal, ",")
  local t_btn = {}
  for i = 1, table.getn(name_list) do
    local pos_btn = form.groupbox_main_menu:Find("rbtn_m" .. nx_string(i))
    local btn = form.groupbox_main_menu:Find("rbtn_m" .. nx_string(name_list[i]))
    if nx_number(i) ~= nx_number(name_list[i]) then
      local op = {
        Top = btn.Top,
        Left = btn.Left
      }
      t_btn[nx_number(name_list[i])] = op
    end
    if t_btn[nx_number(i)] == nil then
      btn.Top = pos_btn.Top
      btn.Left = pos_btn.Left
    else
      btn.Top = t_btn[nx_number(i)].Top
      btn.Left = t_btn[nx_number(i)].Left
    end
    btn.Visible = true
  end
end
function InitMsg(form)
  form.new_school_info:CreateChild(nx_string(gg_msg))
  form.new_school_info:CreateChild(nx_string(ry_msg))
  form.new_school_info:CreateChild(nx_string(cf_msg))
  form.msg_num_gg = 0
  form.msg_num_ry = 0
  form.msg_num_cf = 0
end
function InitDate(form)
  if nx_string(form.school) == "0" or nx_string(form.school) == "" then
    return
  end
  local gui = nx_value("gui")
  form.lbl_Title.Text = nx_widestr(gui.TextManager:GetFormatText(form.school))
  form.groupbox_m1.finsh_fresh = false
  form.groupbox_m2.finsh_fresh = false
  form.groupbox_m3.finsh_fresh = false
  form.groupbox_m4.finsh_fresh = false
  form.groupbox_m5.finsh_fresh = false
  form.groupbox_m6.finsh_fresh = false
  form.groupbox_msg.finsh_fresh = false
  form.groupbox_gumu.finsh_fresh = false
  form.groupbox_shimen.finsh_fresh = false
  form.groupbox_nianluo.finsh_fresh = false
  form.groupbox_changfeng.finsh_fresh = false
  form.groupbox_shenshui.finsh_fresh = false
  form.groupbox_wuxian.finsh_fresh = false
  form.groupbox_jingshu.finsh_fresh = false
  form.groupbox_m1.Visible = false
  form.groupbox_m2.Visible = false
  form.groupbox_m3.Visible = false
  form.groupbox_m4.Visible = false
  form.groupbox_m5.Visible = false
  form.groupbox_m6.Visible = false
  form.groupbox_msg.Visible = false
  form.groupbox_gumu.Visible = false
  form.groupbox_shimen.Visible = false
  form.groupbox_nianluo.Visible = false
  form.groupbox_changfeng.Visible = false
  form.groupbox_shenshui.Visible = false
  form.groupbox_wuxian.Visible = false
  form.groupbox_jingshu.Visible = false
  if "newschool_nianluo" ~= form.school then
    form.rbtn_m5.Visible = false
  end
  if "newschool_gumu" ~= form.school then
    form.rbtn_m8.Visible = false
  end
  if "newschool_nianluo" ~= form.school then
    form.rbtn_m12.Visible = false
  end
  if "newschool_changfeng" ~= form.school then
    form.rbtn_m10.Visible = false
  end
  if "newschool_shenshui" ~= form.school then
    form.rbtn_m13.Visible = false
  end
  if "newschool_wuxian" ~= form.school then
    form.rbtn_m14.Visible = false
  end
  if "newschool_damo" ~= form.school then
    form.rbtn_m15.Visible = false
  end
  if "newschool_nianluo" == form.school then
    form.rbtn_m5.Visible = false
  end
end
function on_main_form_close(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_2)
  form.new_school_info:ClearChild()
  form.force_round_task_info:ClearChild()
  form.force_task_info:ClearChild()
  clear_grid_data(form.textgrid_1, 2, 4)
  clear_grid_data(form.textgrid_2, 2, 5)
  local form_create_introduce = nx_value("form_create_introduce")
  if nx_is_valid(form_create_introduce) then
    nx_destroy(form_create_introduce)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function BingBoxToBtn(form)
  form.rbtn_m1.box = form.groupbox_m1
  form.rbtn_m2.box = form.groupbox_m2
  form.rbtn_m3.box = form.groupbox_m3
  form.rbtn_m4.box = form.groupbox_m4
  form.rbtn_m5.box = form.groupbox_m5
  form.rbtn_m6.box = form.groupbox_m6
  form.rbtn_m7.box = form.groupbox_msg
  form.rbtn_m8.box = form.groupbox_gumu
  form.rbtn_m9.box = form.groupbox_shimen
  form.rbtn_m10.box = form.groupbox_changfeng
  form.rbtn_m12.box = form.groupbox_nianluo
  form.rbtn_m13.box = form.groupbox_shenshui
  form.rbtn_m14.box = form.groupbox_wuxian
  form.rbtn_m15.box = form.groupbox_jingshu
  form.rbtn_m1.freshUI = "freshPag1"
  form.rbtn_m2.freshUI = "freshPag2"
  form.rbtn_m3.freshUI = "freshPag3"
  form.rbtn_m4.freshUI = "freshPag4"
  form.rbtn_m5.freshUI = "freshPag5"
  form.rbtn_m6.freshUI = "freshPag6"
  form.rbtn_m7.freshUI = "freshPag7"
  form.rbtn_m8.freshUI = "freshPag8"
  form.rbtn_m9.freshUI = "freshPag9"
  form.rbtn_m10.freshUI = "freshPag10"
  form.rbtn_m12.freshUI = "freshPag12"
  form.rbtn_m13.freshUI = "freshPag13"
  form.rbtn_m14.freshUI = "freshPag14"
  form.rbtn_m15.freshUI = "freshPag15"
end
function get_force(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "0"
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "0"
  end
  local playerschool = client_player:QueryProp("NewSchool")
  local skill_ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolSkillPoint.ini")
  local nIndex = skill_ini:FindSectionIndex(nx_string(playerschool))
  local skill_point_name = skill_ini:ReadString(nIndex, "Name", "")
  local skill_point_max = skill_ini:ReadString(nIndex, "MaxAll", "")
  local skill_point_tips = skill_ini:ReadString(nIndex, "Tips", "")
  local skill_point = client_player:QueryProp(nx_string(skill_point_name))
  form.skill_point = nx_int(skill_point)
  form.skill_point_max = nx_int(skill_point_max)
  form.skill_point_tips = nx_string(skill_point_tips)
  form.player_name = client_player:QueryProp("Name")
  form.player_shili = client_player:QueryProp("PowerLevel")
  form.player_guild = client_player:QueryProp("GuildName")
  if nx_ws_equal(nx_widestr("0"), nx_widestr(form.player_guild)) then
    form.player_guild = nx_widestr("")
  end
  form.player_repute = get_player_repute_record_force(client_player, playerschool)
  local str_sf = GetShenfen(nx_string(playerschool))
  local gui = nx_value("gui")
  form.player_sf = nx_widestr(gui.TextManager:GetFormatText(str_sf))
  return nx_string(playerschool)
end
function on_m_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked and not btn.box.finsh_fresh then
    nx_execute(form_name, btn.freshUI, form, btn.box)
  end
  btn.box.Visible = btn.Checked
  form.grp_task.Visible = false
  if form.rbtn_m4.Checked then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = false
    form.btn_notice_close.Visible = false
    form.grp_tvt_info.Visible = true
    form.Width = FORM_WIDTH_WANFA
  elseif not form.rbtn_m7.Checked then
    form.grp_tvt_info.Visible = false
    form.Width = FORM_WIDTH
  end
  if form.rbtn_m7.Checked then
    form.groupbox_notice.Visible = true
    form.btn_notice.Visible = false
    form.btn_notice_close.Visible = true
    form.grp_tvt_info.Visible = false
    form.Width = FORM_WIDTH_WANFA
  elseif not form.rbtn_m4.Checked then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = false
    form.btn_notice_close.Visible = false
    form.Width = FORM_WIDTH
  end
  if form.rbtn_m9.Checked == false then
    form.groupbox_paihang.Visible = false
  elseif "newschool_nianluo" ~= form.school and "newschool_shenji" ~= form.school then
    form.groupbox_paihang.Visible = true
  end
  if form.rbtn_m5.Checked then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(919), nx_int(0))
  end
  local is_xue_dao = is_player_in_xuedao()
  form.grp_shaqi_info.Visible = is_xue_dao and form.rbtn_m6.Checked
  if form.rbtn_m6.Checked then
    if is_xue_dao then
      form.Width = FORM_WIDTH_WANFA
    else
      form.Width = FORM_WIDTH
    end
  end
end
function is_player_in_xuedao()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local force = player:QueryProp("NewSchool")
  if nil == force or nx_string("") == nx_string(force) then
    return false
  end
  return force == "newschool_xuedao"
end
function freshPag1(form, box)
  LoadNewSchoolInfo(form)
  create_model(form)
  if nx_is_valid(box) then
    box.finsh_fresh = true
  end
end
function LoadNewSchoolInfo(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = get_ini("share\\NewSchool\\NewSchoolUI\\NewSchoolInfo.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(nx_string(form.force_id))
    if 0 <= index then
      local desc1 = ini:ReadString(index, "r1", "")
      local desc2 = ini:ReadString(index, "r2", "")
      local desc3 = ini:ReadString(index, "r3", "")
      local desc4 = ini:ReadString(index, "r4", "")
      form.rbtn_5.desc = desc1
      form.rbtn_6.desc = desc2
      form.rbtn_7.desc = desc3
      form.rbtn_8.desc = desc4
    end
  end
  form.rbtn_5.Checked = true
  ini = get_ini("ini\\form\\menpai_create.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(nx_string(form.school))
    if 0 <= index then
      form.cloth = ini:ReadString(index, "cloth", "")
      form.neigong = ini:ReadString(index, "neigong", "")
      form.taolu = ini:ReadString(index, "taolu", "")
      show_cloth(form, form.cloth)
      show_neigong(form, form.neigong)
      show_taolu(form, form.taolu)
    end
  end
end
function on_btn_cloth_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local datasource = btn.DataSource
  if "0" == nx_string(datasource) then
    form.cloth_offset = form.cloth_offset + 1
  elseif "1" == nx_string(datasource) then
    form.cloth_offset = form.cloth_offset - 1
  end
  show_cloth(form, form.cloth)
end
function on_btn_neigong_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local datasource = btn.DataSource
  if "0" == nx_string(datasource) then
    form.neigong_offset = form.neigong_offset + 1
  elseif "1" == nx_string(datasource) then
    form.neigong_offset = form.neigong_offset - 1
  end
  show_neigong(form, form.neigong)
end
function on_btn_taolu_left_right_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local datasource = btn.DataSource
  if "0" == nx_string(datasource) then
    form.taolu_offset = form.taolu_offset + 1
  elseif "1" == nx_string(datasource) then
    form.taolu_offset = form.taolu_offset - 1
  end
  show_taolu(form, form.taolu)
end
function show_cloth(form, cloth)
  if 0 > form.cloth_offset then
    form.cloth_offset = 0
  end
  local cloth_list = util_split_string(cloth, ",")
  if form.cloth_offset + 4 > table.getn(cloth_list) then
    form.cloth_offset = table.getn(cloth_list) - 4
    if 0 > form.cloth_offset then
      form.cloth_offset = 0
    end
  end
  local grid = form.ImageControlGrid2
  grid:Clear()
  local sex = form.sex
  local size = 4
  local grid_index = 0
  for i = form.cloth_offset + 1, table.getn(cloth_list) do
    local cloth_id = cloth_list[i]
    local photo = item_query_ArtPack_by_id(cloth_id, "Photo", sex)
    grid:AddItem(grid_index, photo, nx_widestr(cloth_id), 1, -1)
    grid_index = grid_index + 1
    if 4 <= grid_index then
      break
    end
  end
  form.btn_9.Visible = form.cloth_offset ~= 0
  form.btn_8.Visible = table.getn(cloth_list) - 4 > form.cloth_offset
end
function show_neigong(form, neigong)
  if not nx_is_valid(form) then
    return
  end
  if 0 > form.neigong_offset then
    form.neigong_offset = 0
  end
  local ng_list = util_split_string(neigong, ",")
  if form.neigong_offset + 4 > table.getn(ng_list) then
    form.neigong_offset = table.getn(ng_list) - 4
    if 0 > form.neigong_offset then
      form.neigong_offset = 0
    end
  end
  local grid = form.ImageControlGrid3
  grid:Clear()
  local grid_index = 0
  for i = form.neigong_offset + 1, table.getn(ng_list) do
    local id = ng_list[i]
    local staticdata = get_ini_prop("share\\Skill\\NeiGong\\neigong.ini", id, "StaticData", "")
    local photo = neigong_static_query(staticdata, "Photo")
    grid:AddItem(grid_index, photo, nx_widestr(id), 1, -1)
    grid_index = grid_index + 1
    if 4 <= grid_index then
      break
    end
  end
  form.btn_11.Visible = form.neigong_offset ~= 0
  form.btn_10.Visible = table.getn(ng_list) - 4 > form.neigong_offset
end
function show_taolu(form, taolu)
  if not nx_is_valid(form) then
    return
  end
  if 0 > form.taolu_offset then
    form.taolu_offset = 0
  end
  local taolu_list = util_split_string(taolu, ",")
  if form.taolu_offset + 4 > table.getn(taolu_list) then
    form.taolu_offset = table.getn(taolu_list) - 4
    if 0 > form.taolu_offset then
      form.taolu_offset = 0
    end
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    form_create_introduce = nx_create("form_create_introduce")
    nx_set_value("form_create_introduce", form_create_introduce)
  end
  local grid = form.ImageControlGrid4
  grid:Clear()
  local grid_index = 0
  for i = form.taolu_offset + 1, table.getn(taolu_list) do
    local id = taolu_list[i]
    local photo = form_create_introduce:GetTaoluPic(id)
    grid:AddItem(grid_index, photo, nx_widestr(id), 1, -1)
    grid_index = grid_index + 1
    if 4 <= grid_index then
      break
    end
  end
  if 0 < grid_index then
    on_ImageControlGrid4_select_changed(form.ImageControlGrid4, 0)
    form.ImageControlGrid4:SetSelectItemIndex(0)
  end
  form.btn_13.Visible = form.taolu_offset ~= 0
  form.btn_12.Visible = table.getn(taolu_list) - 4 > form.taolu_offset
end
function on_ImageControlGrid4_select_changed(grid, index)
  local form = grid.ParentForm
  local school_id = form.school
  if "" == school_id then
    return
  end
  local taolu_id = nx_string(grid:GetItemAddText(index, 0))
  show_skill(form, school_id, taolu_id)
  form.lbl_79.Text = util_text(taolu_id)
end
function on_ImageControlGrid3_select_changed(grid, index)
  local form = grid.ParentForm
  form.rbtn_7.Checked = true
end
function on_ImageControlGrid2_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local cloth = nx_string(grid:GetItemAddText(index, 0))
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = cloth
  item.ItemType = ITEMTYPE_ORIGIN_SUIT
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ImageControlGrid3_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return
  end
  local neigong = nx_string(grid:GetItemAddText(index, 0))
  local staticdata = get_ini_prop("share\\Skill\\NeiGong\\neigong.ini", neigong, "StaticData", "")
  local min_varpropno = neigong_static_query(staticdata, "MinVarPropNo")
  local bufferlevel = get_ini_prop("share\\Skill\\NeiGong\\neigong_varprop.ini", nx_string(min_varpropno + 35), "BufferLevel")
  local level = 36
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = neigong
  item.ItemType = ITEMTYPE_NEIGONG
  item.StaticData = nx_number(staticdata)
  item.Level = level
  item.BufferLevel = bufferlevel
  item.is_static = true
  item.WuXing = faculty_query:GetWuXing(neigong)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager.InShortcut = true
  end
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ImageControlGrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local skill = nx_string(grid:GetItemAddText(index, 0))
  local staticdata = get_ini_prop("share\\Skill\\skill_new.ini", skill, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = skill
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_ImageControlGrid3_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_ImageControlGrid2_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sex = form.sex
  local cloth_id = nx_string(grid:GetItemAddText(index, 0))
  change_cloth(cloth_id, form.actor2, sex)
end
function change_cloth(cloth, actor2, sex)
  if nil == cloth or "" == cloth then
    return
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local model_name = "MaleModel"
  if 1 == sex then
    model_name = "FemaleModel"
  end
  actor2.AsyncLoad = false
  local nArtPack = item_query_ArtPack_by_id(cloth, "ArtPack", sex)
  local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(nArtPack), model_name)
  local part = {
    "headdress",
    "mask",
    "scarf",
    "shoulders",
    "pendant1",
    "pendant2",
    "cloth",
    "shoes",
    "pants",
    "hat",
    "cloth_h"
  }
  for _, v in pairs(part) do
    role_composite:UnLinkSkin(actor2, v)
  end
  role_composite:LinkSkin(actor2, "Hat", " ", false)
  for id, prop in pairs(ArtPack) do
    local art_id = nx_number(item_query:GetItemPropByConfigID(cloth, id))
    if art_id < 0 then
      nx_execute("role_composite", "unlink_skin", actor2, prop)
      nx_execute("role_composite", "unlink_skin", actor2, string.lower(prop))
    elseif 0 < art_id then
      local model = data_query:Query(STATIC_DATA_ITEM_ART, nx_int(art_id), model_name)
      if "Cloth" == prop or "cloth" == prop then
        role_composite:LinkClothSkin(actor2, model)
        role_composite:LinkSkin(actor2, "cloth_h", model .. "_h.xmod", false)
      else
        role_composite:LinkSkin(actor2, prop, model .. ".xmod", false)
      end
    end
  end
  actor2.AsyncLoad = true
end
function show_skill(form, school_id, taolu_id)
  if not nx_is_valid(form) then
    return
  end
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local grid = form.ImageControlGrid_skill
  local skill = form_create_introduce:GetTaoluSkill(taolu_id)
  local skill_list = util_split_string(skill, ",")
  grid:Clear()
  local grid_index = 0
  for _, id in ipairs(skill_list) do
    local photo = skill_static_query_by_id(id, "Photo")
    grid:AddItem(grid_index, photo, nx_widestr(id), 1, -1)
    grid_index = grid_index + 1
  end
  show_taolu_info(form, school_id, taolu_id)
end
function show_taolu_info(form, school_id, taolu_id)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local taolu_attack = form_create_introduce:GetTaoluAttack(taolu_id)
  local taolu_defend = form_create_introduce:GetTaoluDefend(taolu_id)
  local taolu_recover = form_create_introduce:GetTaoluRecover(taolu_id)
  local taolu_operate = form_create_introduce:GetTaoluOperate(taolu_id)
  local taolu_site = form_create_introduce:GetTaoluSite(taolu_id)
  set_star(form.groupbox_attack, taolu_attack)
  set_star(form.groupbox_defend, taolu_defend)
  set_star(form.groupbox_recover, taolu_recover)
  set_star(form.groupbox_operate, taolu_operate)
  form.mltbox_site:Clear()
  form.mltbox_site:AddHtmlText(util_text(taolu_site), -1)
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
  local quotientr = num / 2
  for i = 1, quotientr do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
  local remainder = num % 2
  if 1 == remainder then
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = quotientr * 20 - 10
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_1.png"
    lbl_star.AutoSize = true
  end
end
function on_ImageControlGrid_skill_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local skill_id = get_skill_id(index)
  if nil == skill_id or "" == skill_id then
    return
  end
  show_skill_action(skill_id, form.actor2)
end
function get_skill_id(skill_grid_index)
  local form_create_introduce = nx_value("form_create_introduce")
  if not nx_is_valid(form_create_introduce) then
    return
  end
  local taolu_id = get_cur_taolu_id()
  if "" == taolu_id then
    return
  end
  local skill = form_create_introduce:GetTaoluSkill(taolu_id)
  local skill_list = util_split_string(skill, ",")
  if skill_grid_index >= table.getn(skill_list) then
    return
  end
  local name = skill_list[skill_grid_index + 1]
  return name
end
function get_cur_taolu_id()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return ""
  end
  local grid = form.ImageControlGrid4
  local index = grid:GetSelectItemIndex()
  if 0 <= index then
    return nx_string(grid:GetItemName(index))
  else
    return ""
  end
end
function show_skill_action(skill_id, actor2)
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  local skill_effect = nx_value("skill_effect")
  if not nx_is_valid(skill_effect) then
    return
  end
  skill_effect:EndShowZhaoshi(actor2, "")
  action:ActionInit(actor2)
  action:ClearAction(actor2)
  action:ClearState(actor2)
  action:BlendAction(actor2, "stand", true, true)
  skill_effect:BeginShowZhaoshi(actor2, skill_id)
  add_weapon(actor2, skill_id)
end
function add_weapon(actor2, skill_name)
  if skill_name == nil then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  if not nx_is_valid(actor2) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  role_composite:UnLinkWeapon(actor2)
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  else
    nx_set_custom(actor2, "wuxue_book_set", "")
  end
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  local g_weapon_ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\skill_weapon.ini")
  if not nx_is_valid(g_weapon_ini) then
    return false
  end
  local sec_index = g_weapon_ini:FindSectionIndex("weapon_name")
  if sec_index < 0 then
    return false
  end
  local weapon_name = g_weapon_ini:ReadString(sec_index, nx_string(taolu), "")
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", skill_name, "UseLimit", "")
  if LimitIndex == nil or nx_int(LimitIndex) == nx_int(0) then
    return false
  end
  local skill_query = nx_value("SkillQuery")
  if not nx_is_valid(skill_query) then
    return false
  end
  local ItemType = skill_query:GetSkillWeaponType(nx_int(LimitIndex))
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) or nx_int(set_index) <= nx_int(8) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
  end
  role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), 2, nx_int(ItemType))
  if nx_int(ItemType) == nx_int(116) then
    role_composite:LinkWeapon(actor2, "ShotWeapon", "main_model::H_weaponR_01", "ini\\npc\\hw_fz001")
    local actor_role = game_visual:QueryActRole(actor2)
    local shot_weapon = actor_role:GetLinkObject("ShotWeapon")
    shot_weapon.Visible = false
  end
  game_visual:SetRoleLogicState(actor2, 1)
  return true
end
function get_weapon_name(item_type)
  if nil == item_type then
    return ""
  end
  if nx_int(item_type) == nx_int(101) then
    return "blade_0024"
  elseif nx_int(item_type) == nx_int(102) then
    return "sword_0020"
  elseif nx_int(item_type) == nx_int(103) then
    return "thorn_0005"
  elseif nx_int(item_type) == nx_int(104) then
    return "sblade_00232"
  elseif nx_int(item_type) == nx_int(105) then
    return "ssword_0004"
  elseif nx_int(item_type) == nx_int(106) then
    return "sthorn_00141"
  elseif nx_int(item_type) == nx_int(107) then
    return "npcitem210"
  elseif nx_int(item_type) == nx_int(108) then
    return "cosh_00223"
  end
  return ""
end
function on_rbtn_desc_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(rbtn, "desc") then
    return
  end
  form.mltbox_5:Clear()
  form.mltbox_5:AddHtmlText(gui.TextManager:GetFormatText(rbtn.desc), -1)
end
function on_ma_checked_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked == false then
    return
  end
  local nInfo_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLiInfo.ini")
  local nIndex = nInfo_ini:FindSectionIndex(nx_string(btn.info))
  local Text = nInfo_ini:ReadString(nIndex, "Text", "")
  local Info = nInfo_ini:ReadString(nIndex, "Info", "")
  local gui = nx_value("gui")
  form.lbl_5.Text = nx_widestr(gui.TextManager:GetFormatText(Text))
  form.mltbox_5.HtmlText = nx_widestr(gui.TextManager:GetFormatText(Info))
  form.lbl_ra2.BackImage = nx_string("")
  form.mltbox_ra2.HtmlText = nx_widestr("")
  if nx_string(btn.Name) == nx_string("rbtn_a2") then
    form.mltbox_5:Clear()
    local photo = nInfo_ini:ReadString(nIndex, "Logo", "")
    form.lbl_ra2.BackImage = nx_string(photo)
    form.mltbox_ra2.HtmlText = nx_widestr(gui.TextManager:GetFormatText(Info))
  end
end
function freshPag2(form, box)
  CreateChlieAndBindP2(form)
  show_new_school_contribute(form)
  box.finsh_fresh = true
end
function on_rbtn_mb_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.Checked == false then
    return
  end
end
function CreateChlieAndBindP2(form)
  form.groupscrollbox_1:DeleteAll()
  form.groupscrollbox_1.IsEditMode = true
  local ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolGrow.ini")
  if not nx_is_valid(ini) then
    return
  end
  local nCount = ini:GetSectionCount()
  local gui = nx_value("gui")
  for i = 0, nCount - 1 do
    local force = ini:ReadString(i, "NewSchool", "")
    local forceId = nx_string(form.school)
    local condition = ini:ReadInteger(i, "Condition", 0)
    if force == forceId and nx_int(1) == nx_int(condition_pack[nx_string(condition)]) then
      local clonegroupbox = clone_groupbox(form.groupbox_funnpcsimple)
      form.groupscrollbox_1:Add(clonegroupbox)
      local nIndex = i
      local Chapters = ini:ReadInteger(nIndex, "Chapters", 0)
      local NpcDesc = ini:ReadString(nIndex, "NpcDesc", "")
      local NpcID = ini:ReadString(nIndex, "NpcID", "")
      local NpcTrack = ini:ReadString(nIndex, "NpcTrack", "")
      local SchoolFunc = ini:ReadString(nIndex, "SchoolFunc", "")
      local SchoolLogo = ini:ReadString(nIndex, "SchoolLogo", "")
      local SchoolPicture = ini:ReadString(nIndex, "SchoolPicture", "")
      local ntype = ini:ReadInteger(nIndex, "type", 0)
      local btn = clone_button(form.btn_7)
      btn.ForeColor = "255,255,255,180"
      btn.Align = form.btn_7.Align
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_mb_click")
      btn.school_logo = SchoolLogo
      btn.school_picture = SchoolPicture
      btn.npc_desc = NpcDesc
      btn.condition = 1
      local pos = clone_mltboxbox(form.mltbox_8)
      gui.TextManager:Format_SetIDName(NpcTrack)
      gui.TextManager:Format_AddParam(nx_string(NpcID))
      pos:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
      btn.Text = nx_widestr("   ") .. nx_widestr(gui.TextManager:GetFormatText(SchoolFunc))
      pos.Align = Left
      pos.Left = 200
      clonegroupbox:Add(btn)
      clonegroupbox:Add(pos)
      local _k = form.groupscrollbox_1:GetChildControlCount()
      if 1 == _k then
        if 1 == btn.condition then
          form.lbl_pass.Visible = true
          form.lbl_ban.Visible = false
        else
          form.lbl_pass.Visible = false
          form.lbl_ban.Visible = true
        end
        on_btn_mb_click(btn)
      end
    end
  end
  for i = 0, nCount - 1 do
    local force = ini:ReadString(i, "NewSchool", "")
    local forceId = nx_string(form.school)
    local condition = ini:ReadInteger(i, "Condition", 0)
    if force == forceId and nx_int(1) ~= nx_int(condition_pack[nx_string(condition)]) then
      local clonegroupbox = clone_groupbox(form.groupbox_funnpcsimple)
      form.groupscrollbox_1:Add(clonegroupbox)
      local nIndex = i
      local Chapters = ini:ReadInteger(nIndex, "Chapters", 0)
      local NpcDesc = ini:ReadString(nIndex, "NpcDesc", "")
      local NpcID = ini:ReadString(nIndex, "NpcID", "")
      local NpcTrack = ini:ReadString(nIndex, "NpcTrack", "")
      local SchoolFunc = ini:ReadString(nIndex, "SchoolFunc", "")
      local SchoolLogo = ini:ReadString(nIndex, "SchoolLogo", "")
      local SchoolPicture = ini:ReadString(nIndex, "SchoolPicture", "")
      local ntype = ini:ReadInteger(nIndex, "type", 0)
      local btn = clone_button(form.btn_7)
      btn.ForeColor = "255,220,0,0"
      btn.Align = form.btn_7.Align
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_mb_click")
      btn.school_logo = SchoolLogo
      btn.school_picture = SchoolPicture
      btn.npc_desc = NpcDesc
      btn.condition = 0
      local pos = clone_mltboxbox(form.mltbox_8)
      gui.TextManager:Format_SetIDName(NpcTrack)
      gui.TextManager:Format_AddParam(nx_string(NpcID))
      pos:AddHtmlText(gui.TextManager:Format_GetText(), nx_int(-1))
      btn.Text = nx_widestr("   ") .. nx_widestr(gui.TextManager:GetFormatText(SchoolFunc))
      pos.Align = Left
      pos.Left = 200
      clonegroupbox:Add(btn)
      clonegroupbox:Add(pos)
      local _k = form.groupscrollbox_1:GetChildControlCount()
      if 1 == _k then
        if 1 == btn.condition then
          form.lbl_pass.Visible = true
          form.lbl_ban.Visible = false
        else
          form.lbl_pass.Visible = false
          form.lbl_ban.Visible = true
        end
        on_btn_mb_click(btn)
      end
    end
  end
  form.groupbox_funnpcsimple.Visible = false
  form.groupscrollbox_1:ResetChildrenYPos()
  form.groupscrollbox_1.IsEditMode = false
end
function get_treeview_bg(bglvl, bgtype)
  local path = "gui\\common\\treeview\\tree_" .. nx_string(bglvl) .. "_" .. nx_string(bgtype) .. ".png"
  return nx_string(path)
end
function on_btn_mb_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.lbl_104.Text = nx_widestr(btn.Text)
  form.lbl_105.BackImage = nx_string(btn.school_picture)
  form.lbl_106.BackImage = nx_string(btn.school_logo)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string(btn.npc_desc))
  form.mltbox_6.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
  if btn.condition == 1 then
    form.lbl_pass.Visible = true
    form.lbl_ban.Visible = false
  else
    form.lbl_pass.Visible = false
    form.lbl_ban.Visible = true
  end
end
function freshPag3(form, box)
  form.rbtn_cs.ruleType = 1
  form.rbtn_xs.ruleType = 0
  form.rbtn_cs.Checked = true
  box.finsh_fresh = true
end
function on_rbtn_mc_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not btn.Checked then
    return
  end
  local rulekey = btn.ruleType
  local ruleini = nx_execute("util_functions", "get_ini", "share\\War\\school_rule.ini")
  local gui = nx_value("gui")
  if not nx_is_valid(ruleini) then
    return
  end
  local force = form.force_id
  if not nx_is_valid(form.tree_ex_force_rule) then
    return
  end
  clear_tree_view(form.tree_ex_force_rule)
  local root_node = form.tree_ex_force_rule.RootNode
  if not nx_is_valid(root_node) then
    root_node = form.tree_ex_force_rule:CreateRootNode(nx_widestr(""))
    root_node.Mark = 0
    root_node.DrawMode = "Tile"
  end
  local nCount = ruleini:GetSectionCount()
  for i = 1, nCount do
    local sec_index = ruleini:FindSectionIndex(nx_string(i))
    if 0 <= sec_index then
      local School = ruleini:ReadString(sec_index, "School", "")
      if nx_int(force) == nx_int(School) then
        local section = ruleini:GetSectionByIndex(sec_index)
        local Chapters = ruleini:ReadInteger(sec_index, "Chapters", 0)
        local Crime = ruleini:ReadInteger(sec_index, "Crime", 0)
        local Type = ruleini:ReadString(sec_index, "Type", "")
        local UiRes = ruleini:ReadString(sec_index, "UiRes", "")
        if nx_int(rulekey) == nx_int(Type) then
          local main_node
          if nx_int(Chapters) == nx_int(0) then
            main_node = root_node
          else
            main_node = root_node:FindNodeByMark(nx_int(Chapters))
          end
          if nx_is_valid(main_node) then
            local rule_node = main_node:CreateNode(nx_widestr(gui.TextManager:GetText(UiRes)))
            rule_node.Mark = nx_int(section)
            rule_node.Font = "font_treeview"
            rule_node.ShadowColor = "0,200,0,0"
            rule_node.TextOffsetX = 30
            rule_node.TextOffsetY = 6
            rule_node.ForeColor = "255,197,184,159"
            rule_node.DrawMode = "FitWindow"
            rule_node.ItemHeight = 30
            if 0 == Chapters then
              rule_node.NodeBackImage = "gui\\special\\school\\2_bg_2_1.png"
              rule_node.NodeFocusImage = "gui\\special\\school\\2_bg_2_1.png"
              rule_node.NodeSelectImage = "gui\\special\\school\\2_bg_2_1.png"
            else
              rule_node.NodeBackImage = "gui\\special\\school\\2_bg_2_2.png"
              rule_node.NodeFocusImage = "gui\\special\\school\\2_bg_2_2.png"
              rule_node.NodeSelectImage = "gui\\special\\school\\2_bg_2_2.png"
            end
          end
        end
      end
    end
  end
  root_node:ExpandAll()
  local value = get_school_rule_value()
  if nx_int(value) >= nx_int(kickout_force_value) then
    form.pbar_crime.ProgressImage = "gui\\common\\progressbar\\pbr_1.png"
  end
  form.pbar_crime.Value = value
  form.lbl_Crime.Text = gui.TextManager:GetText("ui_schoollaw_punishment") .. nx_widestr(value)
end
function freshPag4(form, box)
  CreateChlieAndBindP4(form)
  hide_or_show_child4(form)
  if form.rbtn_0.Visible then
    form.rbtn_0.Checked = true
  elseif form.rbtn_1.Visible then
    form.rbtn_1.Checked = true
  elseif form.rbtn_2.Visible then
    form.rbtn_2.Checked = true
  elseif form.rbtn_3.Visible then
    form.rbtn_3.Checked = true
  elseif form.rbtn_4.Visible then
    form.rbtn_4.Checked = true
  end
  box.finsh_fresh = true
end
function hide_or_show_child4(form)
  local base_ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolBase.ini")
  if not nx_is_valid(base_ini) then
    return
  end
  local nIndex = base_ini:FindSectionIndex(nx_string(form.school))
  local str_lal = base_ini:ReadString(nIndex, "Tasktype", "")
  local name_list = util_split_string(str_lal, ",")
  local tm4_btn = {}
  for i = 1, table.getn(name_list) do
    local k = i - 1
    local pos_btn = form.groupscrollbox_2:Find("rbtn_" .. nx_string(k))
    local btn = form.groupscrollbox_2:Find("rbtn_" .. nx_string(name_list[i]))
    if nx_number(name_list[i]) ~= nx_number(k) then
      local op = {
        Top = btn.Top,
        Left = btn.Left
      }
      tm4_btn[nx_number(name_list[i])] = op
    end
    if nil == tm4_btn[nx_number(k)] then
      btn.Top = pos_btn.Top
      btn.Left = pos_btn.Left
    else
      btn.Top = tm4_btn[nx_number(k)].Top
      btn.Left = tm4_btn[nx_number(k)].Left
    end
    btn.Visible = true
  end
end
function CreateChlieAndBindP4(form)
  form.rbtn_0.type = 0
  form.rbtn_1.type = 1
  form.rbtn_2.type = 2
  form.rbtn_3.type = 3
  form.rbtn_4.type = 4
  form.rbtn_0.grid = form.textgrid_1
  form.rbtn_1.grid = form.textgrid_1
  form.rbtn_2.grid = form.textgrid_1
  form.rbtn_3.grid = form.textgrid_1
  form.rbtn_4.grid = form.textgrid_2
  form.textgrid_1:SetColTitle(1, nx_widestr(util_text("ui_force_name")))
  form.textgrid_1:SetColTitle(2, nx_widestr(util_text("ui_force_prize")))
  form.textgrid_1:SetColTitle(3, nx_widestr(util_text("ui_force_time")))
  form.textgrid_1:SetColTitle(4, nx_widestr(util_text("ui_force_round")))
  form.textgrid_1:SetColTitle(5, nx_widestr(util_text("ui_force_npc")))
  form.textgrid_2:SetColTitle(1, nx_widestr(util_text("ui_force_firsttask")))
  form.textgrid_2:SetColTitle(2, nx_widestr(util_text("ui_force_prize")))
  form.textgrid_2:SetColTitle(3, nx_widestr(util_text("ui_force_time")))
  form.textgrid_2:SetColTitle(4, nx_widestr(util_text("ui_force_round")))
  form.textgrid_2:SetColTitle(5, nx_widestr(util_text("ui_force_loop")))
  form.textgrid_2:SetColTitle(6, nx_widestr(util_text("ui_force_giveup")))
  form.textgrid_2:SetColTitle(7, nx_widestr("           ") .. nx_widestr(util_text("ui_force_npc")))
  form.textgrid_1.Visible = false
  form.textgrid_2.Visible = false
  form.textgrid_1.true_num = 0
  form.textgrid_2.true_num = 0
  form.rbtn_0.Visible = false
  form.rbtn_1.Visible = false
  form.rbtn_2.Visible = false
  form.rbtn_3.Visible = false
  form.rbtn_4.Visible = false
end
function on_rbtn_md_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(form.force_task_info) then
    return
  end
  if not nx_is_valid(form.force_round_task_info) then
    return
  end
  if not btn.Checked then
    btn.grid.true_num = btn.grid.true_num - 1
    if 0 == btn.grid.true_num then
      btn.grid.Visible = false
    end
    return
  end
  btn.grid.Visible = true
  btn.grid.true_num = btn.grid.true_num + 1
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local nType = btn.type
  local forceId = form.force_id
  btn.grid:BeginUpdate()
  btn.grid:ClearRow()
  local RW_ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolPlay.ini")
  if not nx_is_valid(RW_ini) then
    return
  end
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
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
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  local count = RW_ini:GetSectionCount()
  for nIndex = 0, count - 1 do
    local Type = RW_ini:ReadInteger(nIndex, "Type", 0)
    local Force = RW_ini:ReadInteger(nIndex, "Force", 0)
    local condition = RW_ini:ReadInteger(nIndex, "Condition", 0)
    if nType == Type and forceId == Force and nx_int(1) == nx_int(condition_pack[nx_string(condition)]) then
      local nRow = btn.grid:InsertRow(-1)
      local Name = RW_ini:GetSectionByIndex(nIndex)
      local Prize = RW_ini:ReadString(nIndex, "Prize", "")
      local Time = RW_ini:ReadString(nIndex, "Time", "")
      local MaxRoundNumber = RW_ini:ReadInteger(nIndex, "MaxRoundNumber", 0)
      local NpcPos = RW_ini:ReadString(nIndex, "Npc", "")
      local Npc = RW_ini:ReadString(nIndex, "Npcsearch", "")
      local tvt_type = RW_ini:ReadString(nIndex, "Tvt_type", "")
      local task_id = RW_ini:ReadString(nIndex, "Task_id", "")
      local tvt_info = RW_ini:ReadString(nIndex, "Tvt_info", "")
      local one_key = RW_ini:ReadInteger(nIndex, "OneKey", 0)
      local tvt_times = get_tvt_times(tvt_type)
      local show_num = 0
      if nx_int(0) < nx_int(task_id) then
        if not form.force_task_info:FindChild(nx_string(task_id)) then
          local op = form.force_task_info:CreateChild(nx_string(task_id))
          nx_set_custom(op, "round", nx_int(0))
          nx_set_custom(op, "max_round", nx_int(0))
          nx_set_custom(op, "name", nx_widestr(util_text(nx_string(Name))))
          nx_set_custom(op, "price", nx_int(0))
          nx_set_custom(op, "task_id", nx_int(Task_id))
          nx_set_custom(op, "one_key", nx_int(one_key))
          send_msg_get_taskinfo(2, task_id)
        else
          local op = form.force_task_info:GetChild(nx_string(task_id))
          btn.grid:SetGridText(nRow, 9, nx_widestr(op.price))
        end
        local child = form.force_task_info:GetChild(nx_string(task_id))
        if nx_int(0) > nx_int(child.round) then
          child.round = 0
        end
        if nx_int(0) > nx_int(child.max_round) then
          child.circle = 0
        end
        show_num = child.round
        if 4 ~= nType then
          MaxRoundNumber = child.max_round
        end
      else
        show_num = tvt_times
      end
      if nx_int(MaxRoundNumber) < nx_int(show_num) then
        show_num = MaxRoundNumber
      end
      if nx_int(0) > nx_int(show_num) then
        show_num = 0
      end
      if nil == show_num then
        show_num = 0
      end
      if 1 == one_key then
        local label = gui:Create("Label")
        label.BackImage = "gui\\special\\forceschool\\onekey.png"
        label.AutoSize = true
        btn.grid:SetGridControl(nRow, 0, label)
        btn.grid:SetColAlign(0, "center")
      end
      btn.grid:SetGridText(nRow, 1, nx_widestr(util_text(Name)))
      local prize_list = util_split_string(Prize, ",")
      local taa = CreateImage(prize_list)
      btn.grid:SetGridControl(nRow, 2, taa)
      btn.grid:SetGridText(nRow, 3, nx_widestr(util_text(Time)))
      if nx_int(0) == nx_int(MaxRoundNumber) then
        btn.grid:SetGridText(nRow, 4, nx_widestr("-/-"))
      else
        btn.grid:SetGridText(nRow, 4, nx_widestr(show_num) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
      end
      btn.grid:SetGridText(nRow, 6, nx_widestr(0))
      btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
      btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      btn.grid:SetGridText(nRow, 13, nx_widestr(1))
      if nx_int(MaxRoundNumber) == nx_int(show_num) then
        btn.grid:SetGridText(nRow, 14, nx_widestr(1))
      else
        btn.grid:SetGridText(nRow, 14, nx_widestr(0))
      end
      gui.TextManager:Format_SetIDName(NpcPos)
      gui.TextManager:Format_AddParam(nx_string(Npc))
      local mText = gui:Create("MultiTextBox")
      set_copy_ent_info(form, "mltbox_ex4", mText)
      local npc_info = nx_widestr(gui.TextManager:Format_GetText())
      mText:Clear()
      mText:AddHtmlText(nx_widestr("<center>") .. nx_widestr(npc_info) .. nx_widestr("</center>"), nx_int(-1))
      if 4 == nType then
        local Task_id = RW_ini:ReadInteger(nIndex, "Task_id", 0)
        local MaxLoop = RW_ini:ReadInteger(nIndex, "MaxLoop", 0)
        if not form.force_round_task_info:FindChild(nx_string(Task_id)) then
          local op = form.force_round_task_info:CreateChild(nx_string(Task_id))
          nx_set_custom(op, "circle", nx_int(0))
          nx_set_custom(op, "round", nx_int(0))
          nx_set_custom(op, "name", nx_widestr(btn.grid:GetGridText(nRow, 1)))
          nx_set_custom(op, "max_circle", nx_int(MaxLoop))
          nx_set_custom(op, "max_round", nx_int(MaxRoundNumber))
          nx_set_custom(op, "price", nx_int(0))
          nx_set_custom(op, "task_id", nx_int(Task_id))
          nx_set_custom(op, "one_key", nx_int(one_key))
          nx_set_custom(op, "giveup", nx_int(0))
          send_msg_get_taskinfo(1, Task_id)
        else
          local op = form.force_round_task_info:GetChild(nx_string(task_id))
          btn.grid:SetGridText(nRow, 6, nx_widestr(op.giveup))
          btn.grid:SetGridText(nRow, 9, nx_widestr(op.price))
          if nx_int(op.max_round) == nx_int(op.round) then
            btn.grid:SetGridText(nRow, 14, nx_widestr(1))
          else
            btn.grid:SetGridText(nRow, 14, nx_widestr(0))
          end
        end
        local child = form.force_round_task_info:GetChild(nx_string(Task_id))
        if nx_int(MaxRoundNumber) < nx_int(child.round) then
          child.round = MaxRoundNumber
        end
        if nx_int(MaxLoop) < nx_int(child.circle) then
          child.circle = MaxLoop
        end
        btn.grid:SetGridText(nRow, 4, nx_widestr(child.round) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
        btn.grid:SetGridText(nRow, 5, nx_widestr(child.circle) .. nx_widestr("/") .. nx_widestr(MaxLoop))
        btn.grid:SetGridControl(nRow, 7, mText)
        btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
        btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      else
        btn.grid:SetGridControl(nRow, 5, mText)
      end
      btn.grid:SetGridText(nRow, 8, nx_widestr(util_text(nx_string(tvt_info))))
    end
  end
  for nIndex = 0, count - 1 do
    local Type = RW_ini:ReadInteger(nIndex, "Type", 0)
    local Force = RW_ini:ReadInteger(nIndex, "Force", 0)
    local condition = RW_ini:ReadInteger(nIndex, "Condition", 0)
    if nType == Type and forceId == Force and nx_int(1) ~= nx_int(condition_pack[nx_string(condition)]) then
      local nRow = btn.grid:InsertRow(-1)
      local Name = RW_ini:GetSectionByIndex(nIndex)
      local Prize = RW_ini:ReadString(nIndex, "Prize", "")
      local Time = RW_ini:ReadString(nIndex, "Time", "")
      local MaxRoundNumber = RW_ini:ReadInteger(nIndex, "MaxRoundNumber", 0)
      local NpcPos = RW_ini:ReadString(nIndex, "Npc", "")
      local Npc = RW_ini:ReadString(nIndex, "Npcsearch", "")
      local tvt_type = RW_ini:ReadString(nIndex, "Tvt_type", "")
      local task_id = RW_ini:ReadString(nIndex, "Task_id", "")
      local tvt_info = RW_ini:ReadString(nIndex, "Tvt_info", "")
      local one_key = RW_ini:ReadInteger(nIndex, "OneKey", 0)
      local tvt_times = get_tvt_times(tvt_type)
      local show_num = 0
      if nx_int(0) < nx_int(task_id) then
        if not form.force_task_info:FindChild(nx_string(task_id)) then
          local op = form.force_task_info:CreateChild(nx_string(task_id))
          nx_set_custom(op, "round", nx_int(0))
          nx_set_custom(op, "max_round", nx_int(0))
          nx_set_custom(op, "name", nx_widestr(util_text(nx_string(Name))))
          nx_set_custom(op, "price", nx_int(0))
          nx_set_custom(op, "task_id", nx_int(Task_id))
          nx_set_custom(op, "one_key", nx_int(one_key))
          send_msg_get_taskinfo(2, task_id)
        else
          local op = form.force_task_info:GetChild(nx_string(task_id))
          btn.grid:SetGridText(nRow, 9, nx_widestr(op.price))
        end
        local child = form.force_task_info:GetChild(nx_string(task_id))
        if nx_int(0) > nx_int(child.round) then
          child.round = 0
        end
        if nx_int(0) > nx_int(child.max_round) then
          child.circle = 0
        end
        show_num = child.round
        if 4 ~= nType then
          MaxRoundNumber = child.max_round
        end
      else
        show_num = tvt_times
      end
      if nx_int(MaxRoundNumber) < nx_int(show_num) then
        show_num = MaxRoundNumber
      end
      if nx_int(0) > nx_int(show_num) then
        show_num = 0
      end
      if nil == show_num then
        show_num = 0
      end
      if 1 == one_key then
        local label = gui:Create("Label")
        label.BackImage = "gui\\special\\forceschool\\onekey.png"
        label.AutoSize = true
        btn.grid:SetGridControl(nRow, 0, label)
        btn.grid:SetColAlign(0, "center")
      end
      btn.grid:SetGridText(nRow, 1, nx_widestr(util_text(Name)))
      local prize_list = util_split_string(Prize, ",")
      local taa = CreateImage(prize_list)
      btn.grid:SetGridControl(nRow, 2, taa)
      btn.grid:SetGridText(nRow, 3, nx_widestr(util_text(Time)))
      if nx_int(0) == nx_int(MaxRoundNumber) then
        btn.grid:SetGridText(nRow, 4, nx_widestr("-/-"))
      else
        btn.grid:SetGridText(nRow, 4, nx_widestr(show_num) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
      end
      btn.grid:SetGridText(nRow, 6, nx_widestr(0))
      btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
      btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      btn.grid:SetGridText(nRow, 13, nx_widestr(0))
      if nx_int(MaxRoundNumber) == nx_int(show_num) then
        btn.grid:SetGridText(nRow, 14, nx_widestr(1))
      else
        btn.grid:SetGridText(nRow, 14, nx_widestr(0))
      end
      gui.TextManager:Format_SetIDName(NpcPos)
      gui.TextManager:Format_AddParam(nx_string(Npc))
      local mText = gui:Create("MultiTextBox")
      set_copy_ent_info(form, "mltbox_ex4", mText)
      local npc_info = nx_widestr(gui.TextManager:Format_GetText())
      mText:Clear()
      mText:AddHtmlText(nx_widestr("<center>") .. nx_widestr(npc_info) .. nx_widestr("</center>"), nx_int(-1))
      if 4 == nType then
        local Task_id = RW_ini:ReadInteger(nIndex, "Task_id", 0)
        local MaxLoop = RW_ini:ReadInteger(nIndex, "MaxLoop", 0)
        if not form.force_round_task_info:FindChild(nx_string(Task_id)) then
          local op = form.force_round_task_info:CreateChild(nx_string(Task_id))
          nx_set_custom(op, "circle", nx_int(0))
          nx_set_custom(op, "round", nx_int(0))
          nx_set_custom(op, "name", nx_widestr(btn.grid:GetGridText(nRow, 1)))
          nx_set_custom(op, "max_circle", nx_int(MaxLoop))
          nx_set_custom(op, "max_round", nx_int(MaxRoundNumber))
          nx_set_custom(op, "price", nx_int(0))
          nx_set_custom(op, "task_id", nx_int(Task_id))
          nx_set_custom(op, "one_key", nx_int(one_key))
          nx_set_custom(op, "giveup", nx_int(0))
          send_msg_get_taskinfo(1, Task_id)
        else
          local op = form.force_round_task_info:GetChild(nx_string(task_id))
          btn.grid:SetGridText(nRow, 6, nx_widestr(op.giveup))
          btn.grid:SetGridText(nRow, 9, nx_widestr(op.price))
          if nx_int(op.max_round) == nx_int(op.round) then
            btn.grid:SetGridText(nRow, 14, nx_widestr(1))
          else
            btn.grid:SetGridText(nRow, 14, nx_widestr(0))
          end
        end
        local child = form.force_round_task_info:GetChild(nx_string(Task_id))
        if nx_int(MaxRoundNumber) < nx_int(child.round) then
          child.round = MaxRoundNumber
        end
        if nx_int(MaxLoop) < nx_int(child.circle) then
          child.circle = MaxLoop
        end
        btn.grid:SetGridText(nRow, 4, nx_widestr(child.round) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
        btn.grid:SetGridText(nRow, 5, nx_widestr(child.circle) .. nx_widestr("/") .. nx_widestr(MaxLoop))
        btn.grid:SetGridControl(nRow, 7, mText)
        btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
        btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      else
        btn.grid:SetGridControl(nRow, 5, mText)
      end
      btn.grid:SetGridText(nRow, 8, nx_widestr(util_text(nx_string(tvt_info))))
      btn.grid:SetGridForeColor(nRow, 1, "255,220,0,0")
    end
  end
  btn.grid:EndUpdate()
  btn.grid:ClearSelect()
  btn.grid:SelectRow(0)
  if nx_int(1) == nx_int(btn.grid:GetGridText(0, 11)) and nx_int(1) == nx_int(btn.grid:GetGridText(0, 13)) then
    form.grp_task.Visible = true
    form.task_id = nx_int(btn.grid:GetGridText(0, 10))
    if nx_int(1) == nx_int(btn.grid:GetGridText(0, 14)) then
      form.btn_task.Enabled = false
      form.btn_task.Text = util_text("ui_taskfinish")
      show_task_price(nx_int(0))
    else
      form.btn_task.Enabled = true
      form.btn_task.Text = util_text("ui_onekeyfinish")
      show_task_price(btn.grid:GetGridText(0, 9))
    end
    form.tvt_type = 0
  else
    form.grp_task.Visible = false
  end
end
function get_tvt_times(tvt_type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  if not client_player:FindRecord("new_school_activity_record") then
    return 0
  end
  local row = client_player:FindRecordRow("new_school_activity_record", 0, nx_int(tvt_type))
  if row < 0 then
    return 0
  end
  return client_player:QueryRecord("new_school_activity_record", row, 3)
end
function on_textgrid_select_row(self, row)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_tvt_name.Text = self:GetGridText(row, 1)
  form.mltbox_tvt_info.HtmlText = self:GetGridText(row, 8)
  if nx_int(self:GetGridText(row, 11)) == nx_int(1) and nx_int(self:GetGridText(row, 13)) == nx_int(1) then
    form.grp_task.Visible = true
    form.task_id = nx_int(self:GetGridText(row, 10))
    if nx_int(self:GetGridText(row, 14)) == nx_int(1) then
      form.btn_task.Enabled = false
      form.btn_task.Text = util_text("ui_taskfinish")
      show_task_price(nx_int(0))
    else
      form.btn_task.Enabled = true
      form.btn_task.Text = util_text("ui_onekeyfinish")
      show_task_price(self:GetGridText(row, 9))
    end
    form.tvt_type = 0
  else
    form.grp_task.Visible = false
  end
end
function freshPag5(form, box)
  CreateChlieAndBindP5(form)
  LoadDevelopInfo(form)
  form.rbtn_f1.Checked = true
  box.finsh_fresh = true
end
function CreateChlieAndBindP5(form)
  form.rbtn_f1.box = form.groupbox_fb1
  form.rbtn_f2.box = form.groupbox_fb2
  form.rbtn_f3.box = form.groupbox_fb3
  form.rbtn_f4.box = form.groupbox_fb4
  form.groupbox_fb1.Visible = false
  form.groupbox_fb2.Visible = false
  form.groupbox_fb3.Visible = false
  form.groupbox_fb4.Visible = false
end
function LoadDevelopInfo(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini = get_ini("share\\NewSchool\\NewSchoolUI\\NewSchoolDevelop.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(form.force_id))
  if index < 0 then
    return
  end
  local image = ini:ReadString(index, "image", "")
  local info = ini:ReadString(index, "info", "")
  local desc = ini:ReadString(index, "desc", "")
  local r0 = util_split_string(ini:ReadString(index, "r0", ""), ",")
  local r1 = util_split_string(ini:ReadString(index, "r1", ""), ",")
  local r2 = util_split_string(ini:ReadString(index, "r2", ""), ",")
  local r3 = util_split_string(ini:ReadString(index, "r3", ""), ",")
  local r4 = util_split_string(ini:ReadString(index, "r4", ""), ",")
  local r5 = util_split_string(ini:ReadString(index, "r5", ""), ",")
  form.lbl_21.BackImage = image
  form.mltbox_3:Clear()
  form.mltbox_3:AddHtmlText(gui.TextManager:GetFormatText(info), -1)
  form.mltbox_2:Clear()
  form.mltbox_2:AddHtmlText(gui.TextManager:GetFormatText(desc), -1)
  if 2 < table.getn(r0) then
    form.lbl_7.Text = gui.TextManager:GetFormatText(r0[1])
    form.lbl_13.Text = gui.TextManager:GetFormatText(r0[2])
    form.lbl_14.Text = gui.TextManager:GetFormatText(r0[3])
  end
  if 2 < table.getn(r1) then
    form.lbl_23.Text = gui.TextManager:GetFormatText(r1[1])
    form.lbl_24.Text = gui.TextManager:GetFormatText(r1[2])
    form.lbl_25.Text = gui.TextManager:GetFormatText(r1[3])
  end
  if 2 < table.getn(r2) then
    form.lbl_45.Text = gui.TextManager:GetFormatText(r2[1])
    form.lbl_55.Text = gui.TextManager:GetFormatText(r2[2])
    form.lbl_67.Text = gui.TextManager:GetFormatText(r2[3])
  end
  if 2 < table.getn(r3) then
    form.lbl_52.Text = gui.TextManager:GetFormatText(r3[1])
    form.lbl_63.Text = gui.TextManager:GetFormatText(r3[2])
    form.lbl_68.Text = gui.TextManager:GetFormatText(r3[3])
  end
  if 2 < table.getn(r4) then
    form.lbl_53.Text = gui.TextManager:GetFormatText(r4[1])
    form.lbl_64.Text = gui.TextManager:GetFormatText(r4[2])
    form.lbl_69.Text = gui.TextManager:GetFormatText(r4[3])
  end
  if 2 < table.getn(r5) then
    form.lbl_54.Text = gui.TextManager:GetFormatText(r5[1])
    form.lbl_65.Text = gui.TextManager:GetFormatText(r5[2])
    form.lbl_70.Text = gui.TextManager:GetFormatText(r5[3])
  end
end
function on_rbtn_fm_changed(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.box.Visible = btn.Checked
end
function freshPag6(form, box)
  CreateChlieAndBindP6(form)
  box.finsh_fresh = true
end
function freshPag8(form, box)
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 24)
  box.finsh_fresh = true
end
function freshPag9(form, box)
  load_page_shimen(form)
  box.finsh_fresh = true
end
function freshPag10(form, box)
  form.groupbox_changfeng.Visible = true
  box.finsh_fresh = true
end
function freshPag12(form, box)
  loadDevelopProp(form)
  box.finsh_fresh = true
end
function freshPag13(form, box)
  form.groupbox_shenshui.Visible = true
  box.finsh_fresh = true
end
function freshPag15(form, box)
  form.groupbox_jingshu.Visible = true
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local grid = form.ImageControlGrid5
  grid:Clear()
  local item_id = "jsbook_dm_01"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid6
  grid:Clear()
  item_id = "jsbook_dm_02"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid7
  grid:Clear()
  item_id = "jsbook_dm_03"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid8
  grid:Clear()
  item_id = "jsbook_dm_04"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  box.finsh_fresh = true
end
function loadDevelopProp(form)
  local item_ini = get_ini(INI_DEVELOP_PROP)
  if not nx_is_valid(item_ini) then
    return
  end
  local grid = form.imagegrid_1
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local index = item_ini:FindSectionIndex("props")
  if index < 0 then
    return
  end
  grid:Clear()
  local counts = item_ini:GetSectionItemCount(index)
  for i = 0, counts - 1 do
    local item_id = item_ini:ReadString(index, nx_string(i + 1), "")
    if item_id ~= "" then
      photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
      grid:AddItem(i, photo, nx_widestr(item_id), 1, -1)
    end
  end
end
function on_imagegrid_1_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_imagegrid_1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function CreateChlieAndBindP6(form)
  local gui = nx_value("gui")
  local base_ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolBase.ini")
  local nIndex = base_ini:FindSectionIndex(nx_string(form.school))
  local str_ZaXue = base_ini:ReadString(nIndex, "Zaxue", "")
  local ZaXue_list = util_split_string(str_ZaXue, ",")
  local nCoutn = table.getn(ZaXue_list)
  form.groupscrollbox_4:DeleteAll()
  form.groupscrollbox_4.IsEditMode = true
  for i = 1, nCoutn do
    local rbtn = clone_button(form.rbtn_gl)
    form.groupscrollbox_4:Add(rbtn)
    rbtn.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(ZaXue_list[i])))
    rbtn.type = nx_string(ZaXue_list[i])
    nx_bind_script(rbtn, nx_current())
    nx_callback(rbtn, "on_click", "on_btn_mg_click")
    if i == 1 then
      on_btn_mg_click(rbtn)
    end
  end
  form.rbtn_gl.Visible = false
  form.groupscrollbox_4:ResetChildrenYPos()
  form.groupscrollbox_4.IsEditMode = false
  local nTips = nx_widestr(gui.TextManager:GetFormatText(nx_string(form.skill_point_tips)))
  form.lbl_18.Text = nx_widestr(nTips)
  form.lbl_47.Text = nx_widestr(form.skill_point)
  form.lbl_47.Visible = true
  form.pbar_3.Maximum = nx_number(form.skill_point_max)
  form.pbar_3.Value = nx_number(form.skill_point)
  form.pbar_3.Visible = true
  if nx_string("newschool_xuedao") ~= nx_string(form.school) then
    form.lbl_18.Text = util_text("ui_gumu_mpjy_22")
    form.lbl_47.Visible = false
    form.pbar_3.Visible = false
  end
end
function on_btn_mg_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local nType = btn.type
  local forceId = form.force_id
  local ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolCharacter.ini")
  if not nx_is_valid(ini) then
    return
  end
  local nCount = ini:GetSectionCount()
  form.groupscrollbox_6:DeleteAll()
  form.groupscrollbox_6.IsEditMode = true
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  for nIndex = 0, nCount - 1 do
    local Type = ini:ReadString(nIndex, "Type", "")
    local Force = ini:ReadInteger(nIndex, "Force", 0)
    local condition = ini:ReadInteger(nIndex, "Condition", 0)
    if nx_string(Type) == nx_string(nType) and nx_int(Force) == nx_int(forceId) then
      local Name = ini:GetSectionByIndex(nIndex)
      local Desc = ini:ReadString(nIndex, "Desc", "")
      local Npc = ini:ReadString(nIndex, "Npcid", "")
      local NpcTrack = ini:ReadString(nIndex, "NpcTrack", "")
      local Photo = ini:ReadString(nIndex, "Photo", "")
      local origin1 = ini:ReadString(nIndex, "Origin1", "")
      local origin2 = ini:ReadString(nIndex, "Origin2", "")
      local origin3 = ini:ReadString(nIndex, "Origin3", "")
      local clonegroupbox = clone_groupbox(form.groupbox_expss)
      form.groupscrollbox_6:Add(clonegroupbox)
      local name = clone_label(form.lbl_26)
      local lbl_bg = clone_label(form.lbl_10)
      lbl_bg.BackImage = form.lbl_10.BackImage
      local lbl_pt = clone_label(form.lbl_11)
      local mutext = clone_mltboxbox(form.mltbox_9)
      local mutext1 = clone_mltboxbox(form.mltbox_7)
      name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(Name)))
      name.Align = "Left"
      lbl_pt.BackImage = nx_string(Photo)
      mutext.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(Desc)))
      gui.TextManager:Format_SetIDName(nx_string(NpcTrack))
      if "" ~= nx_string(Npc) then
        gui.TextManager:Format_AddParam(nx_string(Npc))
      end
      mutext1.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
      local lbl_leader = clone_label(form.lbl_leader)
      local lbl_origin = clone_label(form.lbl_origin)
      local lbl_origin1 = clone_label(form.lbl_origin1)
      local origin_list1 = util_split_string(origin1, ",")
      if nx_int(2) == nx_int(table.getn(origin_list1)) then
        text = nx_string(origin_list1[1])
        condition = nx_string(origin_list1[2])
        lbl_origin1.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(text)))
        if condition_manager:CanSatisfyCondition(player, player, nx_int(condition)) then
          lbl_origin1.ForeColor = "255,0,125,0"
        else
          lbl_origin1.ForeColor = "255,220,0,0"
        end
      else
        lbl_origin1.Text = ""
      end
      local lbl_origin2 = clone_label(form.lbl_origin2)
      local origin_list2 = util_split_string(origin2, ",")
      if nx_int(2) == nx_int(table.getn(origin_list2)) then
        text = nx_string(origin_list2[1])
        condition = nx_string(origin_list2[2])
        lbl_origin2.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(text)))
        if condition_manager:CanSatisfyCondition(player, player, nx_int(condition)) then
          lbl_origin2.ForeColor = "255,0,125,0"
        else
          lbl_origin2.ForeColor = "255,220,0,0"
        end
      else
        lbl_origin2.Text = ""
      end
      local lbl_origin3 = clone_label(form.lbl_origin3)
      local origin_list3 = util_split_string(origin3, ",")
      if nx_int(2) == nx_int(table.getn(origin_list3)) then
        text = nx_string(origin_list3[1])
        condition = nx_string(origin_list3[2])
        lbl_origin3.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(text)))
        if condition_manager:CanSatisfyCondition(player, player, nx_int(condition)) then
          lbl_origin3.ForeColor = "255,0,125,0"
        else
          lbl_origin3.ForeColor = "255,220,0,0"
        end
      else
        lbl_origin3.Text = ""
      end
      clonegroupbox:Add(lbl_bg)
      clonegroupbox:Add(lbl_pt)
      clonegroupbox:Add(name)
      clonegroupbox:Add(mutext)
      clonegroupbox:Add(mutext1)
      clonegroupbox:Add(lbl_leader)
      clonegroupbox:Add(lbl_origin)
      clonegroupbox:Add(lbl_origin1)
      clonegroupbox:Add(lbl_origin2)
      clonegroupbox:Add(lbl_origin3)
      if "" == nx_string(Npc) then
        nx_bind_script(mutext1, nx_current())
        nx_callback(mutext1, "on_click_hyperlink", "on_mltbox_mhb_click_hyperlink")
      end
      clonegroupbox.Left = 15
    end
  end
  form.groupbox_expss.Visible = false
  form.groupscrollbox_6:ResetChildrenYPos()
  form.groupscrollbox_6.IsEditMode = false
end
function on_mltbox_mhb_click_hyperlink(self, index, data)
end
function freshPag7(form, box)
  LoadTreasureInfo(form)
  LoadNewSchoolPoseInfo(form)
  box.finsh_fresh = true
  request_msg()
  request_school_notice(form)
end
function request_school_notice(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 21)
  form.redit_notice.ReadOnly = true
  form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_bianji"))
  form.groupbox_notice.Visible = true
  form.btn_notice.Visible = false
  form.btn_notice_close.Visible = true
  if not is_school_leader() then
    form.btn_notice_modify.Enabled = false
  end
end
function refresh_school_notice(notice_info)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form.redit_notice.Text = nx_widestr(notice_info)
end
function is_school_leader()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local rows = client_player:FindRecordRow("SchoolPoseRec", 1, name)
  if 0 <= rows then
    local rank = nx_int(client_player:QueryRecord("SchoolPoseRec", rows, 0) % 100 / 10)
    if rank == nx_int(1) then
      return true
    end
  end
  return false
end
function on_btn_notice_modify_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not is_school_leader() then
    return
  end
  local gui = nx_value("gui")
  if form.redit_notice.ReadOnly then
    form.redit_notice.ReadOnly = false
    form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_complete"))
  else
    form.redit_notice.ReadOnly = true
    form.btn_notice_modify.Text = gui.TextManager:GetText(nx_string("ui_bianji"))
    local CheckWords = nx_value("CheckWords")
    if not nx_is_valid(CheckWords) then
      return 0
    end
    local new_word = nx_widestr(CheckWords:CleanWords(nx_widestr(form.redit_notice.Text)))
    if nx_ws_length(new_word) >= 512 then
      return
    end
    nx_execute("custom_sender", "custom_send_request_look_school_fight_info", 22, nx_widestr(new_word))
  end
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.groupbox_notice.Visible then
    form.groupbox_notice.Visible = true
    form.btn_notice.Visible = false
    form.btn_notice_close.Visible = true
  end
end
function on_btn_notice_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.groupbox_notice.Visible then
    form.groupbox_notice.Visible = false
    form.btn_notice.Visible = true
    form.btn_notice_close.Visible = false
  end
end
function LoadTreasureInfo(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini = get_ini("share\\NewSchool\\NewSchoolUI\\NewSchoolTreasure.ini")
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(nx_string(form.force_id))
  if index < 0 then
    return
  end
  local image = ini:ReadString(index, "image", "")
  local info = ini:ReadString(index, "info", "")
  form.lbl_school_tresure.BackImage = image
  form.mltbox_treasure_info.HtmlText = gui.TextManager:GetFormatText(info)
end
function LoadNewSchoolPoseInfo(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_my_name.Text = nx_widestr(client_player:QueryProp("Name"))
  local level_title = "desc_" .. client_player:QueryProp("LevelTitle")
  form.lbl_my_power.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(level_title)))
  local guildname = client_player:QueryProp("GuildName")
  if 0 == guildname then
    guildname = ""
  end
  form.lbl_my_guild.Text = nx_widestr(form.player_repute)
  local CharacterFlag = nx_number(client_player:QueryProp("CharacterFlag"))
  local CharacterValue = nx_number(client_player:QueryProp("CharacterValue"))
  local text = get_xiae_text(CharacterFlag, CharacterValue)
  form.lbl_my_shane.Text = nx_widestr(text)
  form.lbl_121.Visible = false
  form.lbl_faction.Visible = false
  form.lbl_219.Visible = true
  form.lbl_my_shane.Visible = true
  if nx_string("newschool_xuedao") == nx_string(form.school) then
    local faction = nx_number(client_player:QueryProp("XueDaoFaction"))
    form.lbl_faction.Text = util_text("ui_xuedaopaixi_" .. nx_string(faction))
    form.lbl_219.Visible = false
    form.lbl_my_shane.Visible = false
    form.lbl_121.Visible = true
    form.lbl_faction.Visible = true
  end
  local titlerec = GetTitles(2)
  if nil ~= titlerec and 0 < table.getn(titlerec) then
    form.lbl_my_origin.Text = nx_widestr(gui.TextManager:GetFormatText("role_title_" .. titlerec[table.getn(titlerec)]))
  else
    form.lbl_my_origin.Text = nx_widestr("")
  end
  local zhangmenid = form.force_id * 100 + 11
  local ini = get_ini("share\\War\\SchoolPose_Info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local rows = client_player:FindRecordRow("SchoolPoseRec", 0, zhangmenid)
  if rows < 0 then
    return
  end
  local index = ini:FindSectionIndex(nx_string(zhangmenid))
  if index < 0 then
    return
  end
  local postitle = "origin_" .. ini:ReadString(index, "GetOrigin", "")
  local poseuser = client_player:QueryRecord("SchoolPoseRec", rows, 1)
  level_title = "desc_" .. client_player:QueryRecord("SchoolPoseRec", rows, 3)
  form.lbl_school_zhangmen_name.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(poseuser)))
  form.lbl_school_zhangmen_power.Text = nx_widestr(gui.TextManager:GetFormatText(nx_string(level_title)))
  form.lbl_school_zhangmen_origin.Text = nx_widestr(gui.TextManager:GetFormatText(postitle))
end
function get_xiae_text(CharacterFlag, CharacterValue)
  local text = nx_execute("form_stage_main\\form_role_info\\form_role_info", "get_xiae_text", CharacterFlag, CharacterValue)
  return text
end
function GetTitles(type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if 0 >= client_player:GetRecordRows("title_rec") then
    return nil
  end
  local list_titles = {}
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_type = client_player:QueryRecord("title_rec", r, 1)
    if nx_int(rec_type) == nx_int(type) then
      local rec_title = client_player:QueryRecord("title_rec", r, 0)
      table.insert(list_titles, rec_title)
    end
  end
  return list_titles
end
function request_msg()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  local force_id = str_to_int[nx_string(form.school)]
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_NEW_SCHOOL_TRENDS), nx_int(SUB_REQUEST_NEW_SCHOOL_TRENDS), nx_int(force_id))
end
function refresh_new_school_trends(new_school_id, ...)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) or not nx_is_valid(form.mltbox_school_msg_info) then
    return
  end
  form.mltbox_school_msg_info:Clear()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolTrends.ini")
  if not nx_is_valid(ini) then
    return
  end
  for i = 1, table.getn(arg) do
    local info = arg[i]
    local info_list = util_split_wstring(info, nx_widestr("|"))
    if table.getn(info_list) >= 3 then
      local msgtype = info_list[1]
      local startTime = info_list[2]
      local msginfo = info_list[3]
      local index = ini:FindSectionIndex(nx_string(msgtype))
      local desc = ""
      local typedesc = ""
      if 0 <= index then
        desc = ini:ReadString(index, "DescID", "")
        typedesc = ini:ReadString(index, "TypeDescID", "")
        gui.TextManager:Format_SetIDName(desc)
        local paralst = util_split_string(nx_string(msginfo), ";")
        for i, buf in pairs(paralst) do
          gui.TextManager:Format_AddParam(buf)
        end
        local wcsInfo = gui.TextManager:GetText(nx_string(typedesc)) .. nx_widestr("  ") .. nx_widestr(startTime) .. nx_widestr("  ") .. nx_widestr(gui.TextManager:Format_GetText())
        form.mltbox_school_msg_info:AddHtmlText(nx_widestr(wcsInfo), nx_int(i - 1))
      end
    end
  end
end
function CreateChlieAndBindP7(form)
  form.groupbox_4.box = 1
end
function on_btn_hl_click(btn)
  local form = btn.ParentForm
  if form.groupbox_4.box == 1 then
    return
  end
  local nOld = form.groupbox_4.box
  form.groupbox_4.box = form.groupbox_4.box - 1
  show_left_box(form, nOld)
end
function set_player_info(form)
  local gui = nx_value("gui")
  form.lbl_name1.Text = nx_widestr(form.player_name)
  form.lbl_shenfeng1.Text = nx_widestr(form.player_sf)
  form.lbl_force1.Text = gui.TextManager:GetText(get_powerlevel_title_one(form.player_shili))
  form.lbl_guid1.Text = nx_widestr(form.player_guild)
  form.lbl_shengw1.Text = nx_widestr(form.player_repute)
end
function on_btn_hr_click(btn)
  local form = btn.ParentForm
  if form.groupbox_4.box == 2 then
    return
  end
  local nOld = form.groupbox_4.box
  form.groupbox_4.box = form.groupbox_4.box + 1
  show_left_box(form, nOld)
end
function show_left_box(form, old)
  local old_box = form.groupbox_4:Find("groupbox_mh_a" .. nx_string(old))
  local new_box = form.groupbox_4:Find("groupbox_mh_a" .. nx_string(form.groupbox_4.box))
  new_box.Visible = true
  old_box.Visible = false
  form.lbl_12.Text = nx_widestr(form.groupbox_4.box) .. nx_widestr("/2")
end
function clone_button(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Button")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.PushImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_checkbutton(source)
  local gui = nx_value("gui")
  local clone = gui:Create("CheckButton")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.PushImage = source.CheckedImage
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.DrawMode = source.DrawMode
  clone.ClickEvent = source.ClickEvent
  clone.HideBox = source.HideBox
  return clone
end
function clone_mltboxbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("MultiTextBox")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.HAlign = source.HAlign
  clone.VAlign = source.VAlign
  clone.ViewRect = source.ViewRect
  clone.HtmlText = source.HtmlText
  clone.MouseInBarColor = source.MouseInBarColor
  clone.SelectBarColor = source.SelectBarColor
  clone.TextColor = source.TextColor
  clone.Font = source.Font
  clone.NoFrame = source.NoFrame
  clone.LineColor = source.LineColor
  clone.ViewRect = source.ViewRect
  clone.LineHeight = source.LineHeight
  clone.TextColor = source.TextColor
  clone.SelectBarColor = source.SelectBarColor
  clone.MouseInBarColor = source.MouseInBarColor
  return clone
end
function clone_groupbox(source)
  local gui = nx_value("gui")
  local clone = gui:Create("GroupBox")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = 0
  clone.Top = 0
  clone.Width = source.Width
  clone.Height = source.Height
  clone.LineColor = source.LineColor
  clone.NoForm = false
  clone.DrawMode = source.DrawMode
  clone.BackImage = source.BackImage
  return clone
end
function clone_label(source)
  local gui = nx_value("gui")
  local clone = gui:Create("Label")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.Text = source.Text
  clone.BackImage = source.BackImage
  clone.DrawMode = source.DrawMode
  return clone
end
function clone_Image(source)
  local gui = nx_value("gui")
  local clone = gui:Create("ImageGrid")
  clone.AutoSize = source.AutoSize
  clone.Name = source.Name
  clone.BackColor = source.BackColor
  clone.NoFrame = source.NoFrame
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.GridWidth = source.GridWidth
  clone.GridHeight = source.GridHeight
  clone.LineColor = source.LineColor
  clone.RowNum = source.RowNum
  clone.ClomnNum = source.ClomnNum
  clone.DrawGridBack = source.DrawGridBack
  clone.NoFrame = true
  return clone
end
function create_model(form)
  if not nx_is_valid(form) then
    return
  end
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
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
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_2)
  nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_2)
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox_2.Scene)
    form.scenebox_2.Scene.game_effect = game_effect
  end
  local terrain = form.scenebox_2.Scene:Create("Terrain")
  form.scenebox_2.Scene.terrain = terrain
  local actor2 = nx_execute("role_composite", "create_scene_obj_composite", form.scenebox_2.Scene, client_player, false)
  while nx_is_valid(form) and nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  if not nx_is_valid(form) then
    return
  end
  actor2.modify_face = client_player:QueryProp("ModifyFace")
  nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_2, actor2)
  local action = nx_value("action_module")
  if nx_is_valid(action) then
    action:BlendAction(actor2, "stand", false, true)
  end
  actor2:SetAngle(actor2.AngleX, actor2.AngleY, actor2.AngleZ)
  form.scenebox_2.Scene.camera.Fov = 0.1388888888888889 * math.pi * 2
  form.actor2 = actor2
end
function on_right_click(btn)
  btn.MouseDown = false
end
function on_right_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  if not nx_is_valid(form.actor2) then
    return
  end
  local speed = -3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    ui_RotateModel(form.scenebox_1, dist)
  end
end
function on_left_click(btn)
  btn.MouseDown = false
end
function on_left_push(btn)
  btn.MouseDown = true
  local form = btn.ParentForm
  if not nx_is_valid(form.actor2) then
    return
  end
  local speed = 3.1415926
  while btn.MouseDown do
    local elapse = nx_pause(0)
    local dist = speed * elapse
    if not nx_is_valid(form) or not nx_is_valid(form.scenebox_1) then
      break
    end
    ui_RotateModel(form.scenebox_1, dist)
  end
end
function on_cbtn_player_info_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked then
    form.grp_tvt_info.Visible = true
    form.Width = FORM_WIDTH_WANFA
    set_player_info(form)
  else
    form.Width = FORM_WIDTH
    form.grp_tvt_info.Visible = false
  end
end
function on_btn_player_info_hide_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_1.Checked = false
end
function open_form()
  local form = nx_value("form_stage_main\\form_school_war\\form_newschool_school_msg_info")
  if nx_is_valid(form) then
    form:Close()
  else
    form = util_get_form("form_stage_main\\form_school_war\\form_newschool_school_msg_info", true)
    form:Show()
    form.Visible = true
    form.rbtn_m7.Checked = true
  end
end
function GetShenfen(force)
  if nx_string(force) == "0" or nx_string(force) == "" then
    return ""
  end
  local pos_end = force_sf_pos[force]
  if pos_end == nil then
    return ""
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local min_pos = (pos_end - 9) / 32
  if min_pos >= client_player:GetRecordRows("Origin_Completed") then
    return ""
  end
  for i = pos_end, pos_end - 9, -1 do
    local row = nx_int(i / 32)
    local row_value = client_player:QueryRecord("Origin_Completed", row, 0)
    local pos = i % 32
    local pos_value = 2 ^ pos
    local result = nx_int(row_value / nx_int(pos_value))
    local result1 = 0
    if row_value < 0 then
      result = result * -1 + 2 ^ (31 - pos)
    end
    if nx_number(result) % 2 == 1 then
      return "origin_" .. i
    end
  end
  return ""
end
function get_player_repute_record_force(client_player, force)
  if not nx_is_valid(client_player) then
    return 0
  end
  local repute = force_to_repute[nx_string(force)]
  local rows = client_player:FindRecordRow("Repute_Record", 0, nx_string(repute), 0)
  if rows < 0 then
    return 0
  end
  return client_player:QueryRecord("Repute_Record", rows, 1)
end
function send_msg_get_taskinfo(sub_type, task_id)
  if nx_int(task_id) <= nx_int(0) then
    return
  end
  nx_execute("custom_sender", "custom_send_query_round_task", nx_int(sub_type), nx_int(task_id))
end
function on_school_msg(msg_type, ...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if arg[0] == STC_SchoolMsg then
    local ini = nx_execute("util_functions", "get_ini", "share\\War\\School_MsgInfo.ini")
    if not nx_is_valid(ini) then
      return
    end
    local ss = arg[2]
    local nIndex = ini:FindSectionIndex(nx_string(ss))
    local DeleteTime = {
      hour = 0,
      ms = 0,
      ntimes = 0,
      del = 0
    }
    local DeleteType = ini:ReadInteger(nIndex, "DeleteType", 0)
    if DeleteType == 1 then
      DeleteTime.ntimes = ini:ReadInteger(nIndex, "DeleteTime", 0)
    elseif DeleteType == 2 then
      local str_time = ini:ReadString(nIndex, "DeleteTime", "")
      local time_list = util_split_string(str_time, ";")
      DeleteTime.hour = nx_int(time_list[1])
      DeleteTime.ms = nx_int(time_list[2])
    end
    DeleteTime.del = DeleteType
    local DescID = ini:ReadString(nIndex, "DescID", "")
    local Priority = ini:ReadInteger(nIndex, "Priority", 0)
    local TypeDescID = ini:ReadString(nIndex, "TypeDescID", "")
    local f_child = form.new_school_info:FindChild(nx_string(DeleteType))
    local nCount = f_child:GetChildCount()
    local child = f_child:CreateChild(nx_string(nCount))
    nx_set_custom(child, "DeleteType", nx_int(DeleteType))
    nx_set_custom(child, "DeleteTime", DeleteTime)
    nx_set_custom(child, "DescID", nx_string(DescID))
    nx_set_custom(child, "Priority", nx_int(Priority))
    nx_set_custom(child, "TypeDescID", nx_string(TypeDescID))
    local info_ss = {}
    local num = table.getn(arg)
    for i = 3, num do
      info_ss[i] = arg[i]
    end
    nx_set_custom(child, "TypeDescID", info_ss)
  elseif msg_type == SERVER_CUSTOMMSG_ROUND_TASK then
    local sub_type = arg[1]
    local task_id = arg[2]
    if nx_int(sub_type) == nx_int(1) then
      local circle = arg[3]
      local max_circle = arg[4]
      local round = arg[5]
      local max_round = arg[6]
      local price = arg[7]
      local giveup = arg[8]
      if not nx_is_valid(form) then
        return
      end
      if not nx_find_custom(form, "force_round_task_info") then
        return
      end
      if not nx_is_valid(form.force_round_task_info) then
        return
      end
      if nx_int(max_circle) <= nx_int(0) or nx_int(circle) > nx_int(max_circle) then
        return
      end
      if not form.force_round_task_info:FindChild(nx_string(task_id)) then
        return
      end
      local child = form.force_round_task_info:GetChild(nx_string(task_id))
      child.circle = nx_int(circle)
      child.round = nx_int(round)
      child.max_circle = nx_int(max_circle)
      child.max_round = nx_int(max_round)
      child.price = nx_int(price)
      child.task_id = nx_int(task_id)
      child.giveup = nx_int(giveup)
      fresh_round_task(form, child)
    elseif nx_int(sub_type) == nx_int(2) then
      if not nx_is_valid(form) then
        return
      end
      if not nx_find_custom(form, "force_task_info") then
        return
      end
      if not nx_is_valid(form.force_task_info) then
        return
      end
      if not form.force_task_info:FindChild(nx_string(task_id)) then
        return
      end
      local child = form.force_task_info:GetChild(nx_string(task_id))
      child.round = nx_int(arg[3])
      child.max_round = nx_int(arg[4])
      child.price = nx_int(arg[5])
      child.task_id = nx_int(task_id)
      fresh_task(form, child)
    elseif nx_int(sub_type) == nx_int(4) then
      if not nx_is_valid(form) then
        return
      end
      local task_id = nx_int(arg[2])
      local task_money = nx_int(arg[3])
      if not form.force_round_task_info:FindChild(nx_string(form.task_id)) then
        return
      end
      local child = form.force_round_task_info:GetChild(nx_string(form.task_id))
      if nx_int(task_money) < nx_int(0) then
        return
      end
      local price_ding = nx_int64(task_money / 1000000)
      local temp = nx_int64(task_money - price_ding * 1000000)
      local price_liang = nx_int64(temp / 1000)
      local price_wen = nx_int64(temp - price_liang * 1000)
      local gui = nx_value("gui")
      local text = nx_widestr(gui.TextManager:GetFormatText("ui_yijianwancheng_tips", nx_int(price_ding), nx_int(price_liang), nx_int(price_wen), nx_widestr(child.name)))
      if not ShowTipDialog(nx_widestr(text)) then
        return
      end
      if nx_is_valid(form) then
        nx_execute("custom_sender", "custom_send_query_round_task", nx_int(4), nx_int(form.task_id))
      end
    end
  end
end
function fresh_round_task(form, child)
  if not nx_is_valid(form) then
    return
  end
  local list = form.textgrid_2
  for i = 0, list.RowCount - 1 do
    if nx_ws_equal(nx_widestr(list:GetGridText(i, 1)), nx_widestr(child.name)) then
      list:SetGridText(i, 4, nx_widestr(child.round) .. nx_widestr("/") .. nx_widestr(child.max_round))
      list:SetGridText(i, 5, nx_widestr(child.circle) .. nx_widestr("/") .. nx_widestr(child.max_circle))
      list:SetGridText(i, 6, nx_widestr(child.giveup))
      list:SetGridText(i, 9, nx_widestr(child.price))
      if nx_int(child.round) == nx_int(child.max_round) then
        list:SetGridText(i, 14, nx_widestr(1))
      else
        list:SetGridText(i, 14, nx_widestr(0))
      end
      if i == 0 then
        form.task_id = child.task_id
        if nx_int(list:GetGridText(i, 14)) == nx_int(1) then
          form.btn_task.Enabled = false
          form.btn_task.Text = util_text("ui_taskfinish")
          show_task_price(0)
        else
          form.btn_task.Enabled = true
          form.btn_task.Text = util_text("ui_onekeyfinish")
          show_task_price(child.price)
        end
      end
    end
  end
end
function fresh_task(form, child)
  if not nx_is_valid(form) then
    return
  end
  local list = form.textgrid_1
  for i = 0, list.RowCount - 1 do
    if nx_ws_equal(nx_widestr(list:GetGridText(i, 1)), nx_widestr(child.name)) then
      list:SetGridText(i, 4, nx_widestr(child.round) .. nx_widestr("/") .. nx_widestr(child.max_round))
      list:SetGridText(i, 9, nx_widestr(child.price))
      if nx_int(child.round) == nx_int(child.max_round) then
        list:SetGridText(i, 14, nx_widestr(1))
      else
        list:SetGridText(i, 14, nx_widestr(0))
      end
      if i == 0 then
        form.task_id = child.task_id
        if nx_int(list:GetGridText(i, 14)) == nx_int(1) then
          form.btn_task.Enabled = false
          form.btn_task.Text = util_text("ui_taskfinish")
          show_task_price(0)
        else
          form.btn_task.Enabled = true
          form.btn_task.Text = util_text("ui_onekeyfinish")
          show_task_price(child.price)
        end
      end
    end
  end
end
function CreateImage(item_list)
  local gui = nx_value("gui")
  local tmp_imagegrid = gui:Create("ImageGrid")
  local form = nx_value(nx_current())
  set_copy_ent_info(form, "imagegrid_ex4", tmp_imagegrid)
  nx_bind_script(tmp_imagegrid, nx_current())
  nx_callback(tmp_imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  nx_callback(tmp_imagegrid, "on_select_changed", "on_select_changed")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  tmp_imagegrid:Clear()
  local count = table.getn(item_list)
  local grid_index = 0
  tmp_imagegrid.ClomnNum = count
  for i = 1, count do
    local nItem = nx_string(item_list[i])
    local photo = ItemQuery:GetItemPropByConfigID(nItem, "Photo")
    tmp_imagegrid:AddItem(grid_index, photo, "", 1, -1)
    grid_index = grid_index + 1
    nx_set_custom(tmp_imagegrid, "config" .. i, nItem)
  end
  return tmp_imagegrid
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function clear_grid_data(grid, ...)
  local count = table.getn(arg)
  if nx_is_valid(grid) then
    for i = 0, grid.RowCount - 1 do
      for j = 1, count do
        local data = grid:GetGridTag(i, arg[j])
        if nx_is_valid(data) then
          nx_destroy(data)
        end
      end
    end
  end
end
function set_force(form)
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local force = player:QueryProp("NewSchool")
  if nil == force or nx_string("") == nx_string(force) then
    return
  end
  local force_ini = get_ini(INI_FORCE_INFO)
  if not nx_is_valid(force_ini) then
    return
  end
  local index = force_ini:FindSectionIndex(force)
  local force_id = force_ini:ReadInteger(index, "ID", 0)
  nx_set_custom(form, "force_id", nx_int(force_id))
  local sex = player:QueryProp("Sex")
  nx_set_custom(form, "sex", nx_int(sex))
end
function clear_tree_view(tree_view)
  if not nx_is_valid(tree_view) then
    return
  end
  local root_node = tree_view.RootNode
  if not nx_is_valid(root_node) then
    return
  end
  local table_main_node = root_node:GetNodeList()
  for i, main_node in pairs(table_main_node) do
    main_node:ClearNode()
  end
  root_node:ClearNode()
end
function get_school_rule_value()
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return 0
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return 0
  end
  local value = 0
  if player:FindProp("SchoolRuleValue") then
    value = player:QueryProp("SchoolRuleValue")
  end
  return value
end
function get_powerlevel_title_one(powerlevel)
  local pl = nx_number(powerlevel)
  if pl < 6 then
    return "tips_title_0"
  elseif 151 <= pl then
    return "tips_title_151"
  elseif 136 <= pl then
    return "tips_title_136"
  elseif 121 <= pl then
    return "tips_title_121"
  end
  local s = powerlevel / 10
  local y = powerlevel % 10
  if 6 <= y then
    y = 6
  elseif 1 <= y then
    y = 1
  else
    y = 6
    if nx_int(s) > nx_int(0) then
      s = s - 1
    end
  end
  return "tips_title_" .. nx_string(nx_int(s) * 10 + y)
end
function on_mousein_grid(grid, index)
  index = index + 1
  if nx_find_custom(grid, "config" .. index) then
    show_tips(grid, nx_custom(grid, "config" .. index))
  end
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_tips(grid, item_config)
  if nx_string(item_config) == nx_string("") or nx_string(item_config) == nx_string("nil") then
    return
  end
  local ItemQuery = nx_value("ItemQuery")
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(ItemQuery) or not nx_is_valid(IniManager) then
    return
  end
  if ItemQuery:FindItemByConfigID(nx_string(item_config)) then
    local item_type = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("ItemType"))
    local item_level = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Level"))
    local item_sellPrice1 = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("sellPrice1"))
    local item_photo = ItemQuery:GetItemPropByConfigID(nx_string(item_config), nx_string("Photo"))
    local prop_array = {}
    prop_array.ConfigID = nx_string(item_config)
    prop_array.ItemType = nx_int(item_type)
    prop_array.Level = nx_int(item_level)
    prop_array.SellPrice1 = nx_int(item_sellPrice1)
    prop_array.Photo = nx_string(item_photo)
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList")
    end
    grid.Data:ClearChild()
    for prop, value in pairs(prop_array) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_execute("tips_game", "show_goods_tip", grid.Data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
    return
  end
end
function on_btn_fb1_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_force_school\\form_wgm_info")
  form:Close()
end
function query_condtion_msg()
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_loading.Visible = true
  form.ani_loading.Visible = true
  form.ani_loading.PlayMode = 0
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local player_force = player:QueryProp("NewSchool")
  if nil == player_force or "" == player_force then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\NewSchool\\NewSchoolUI\\NewSchoolCondition.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("condition")
  if sec_index < 0 then
    return
  end
  local condition_pass = ""
  for i = 0, ini:GetSectionItemCount(sec_index) - 1 do
    local condition = ini:GetSectionItemKey(sec_index, i)
    local force = ini:GetSectionItemValue(sec_index, i)
    if nx_int(0) < nx_int(condition) and player_force == force then
      if condition_manager:CanSatisfyCondition(player, player, nx_int(condition)) then
        condition_pack[nx_string(condition)] = 1
      else
        condition_pack[nx_string(condition)] = 0
      end
    end
  end
  form.lbl_loading.Visible = false
  form.ani_loading.Visible = false
end
function show_task_price(_price)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  local price = nx_int(_price)
  if nx_int(price) < nx_int(0) then
    form.lbl_ding.Text = ""
    form.lbl_liang.Text = ""
    form.lbl_wen.Text = ""
    return
  end
  local price_ding = nx_int64(price / 1000000)
  local temp = nx_int64(price - price_ding * 1000000)
  local price_liang = nx_int64(temp / 1000)
  local price_wen = nx_int64(temp - price_liang * 1000)
  form.lbl_ding.Text = nx_widestr(price_ding)
  form.lbl_liang.Text = nx_widestr(price_liang)
  form.lbl_wen.Text = nx_widestr(price_wen)
end
function on_btn_task_click(btn)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_int(form.task_id) <= nx_int(0) then
    return
  end
  local child
  local is_round = false
  if form.force_round_task_info:FindChild(nx_string(form.task_id)) then
    child = form.force_round_task_info:GetChild(nx_string(form.task_id))
    is_round = true
  elseif form.force_task_info:FindChild(nx_string(form.task_id)) then
    child = form.force_task_info:GetChild(nx_string(form.task_id))
  else
    return
  end
  if is_round then
    if nx_is_valid(form) then
      nx_execute("custom_sender", "custom_send_query_round_task", nx_int(3), nx_int(form.task_id))
    end
  else
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_yijianwancheng_tips", nx_int(form.lbl_ding.Text), nx_int(form.lbl_liang.Text), nx_int(form.lbl_wen.Text), nx_widestr(child.name)))
    if not ShowTipDialog(nx_widestr(text)) then
      return
    end
    if nx_is_valid(form) then
      nx_execute("custom_sender", "send_task_msg", nx_int(12), nx_int(form.task_id))
    end
  end
end
function CreateZaXueImage(path)
  local gui = nx_value("gui")
  local tmp_imagegrid = gui:Create("ImageGrid")
  local form = nx_value(nx_current())
  set_copy_ent_info(form, "imagegrid_ex4", tmp_imagegrid)
  nx_bind_script(tmp_imagegrid, nx_current())
  nx_callback(tmp_imagegrid, "on_mousein_grid", "on_mousein_grid")
  nx_callback(tmp_imagegrid, "on_mouseout_grid", "on_mouseout_grid")
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  tmp_imagegrid:Clear()
  local photo = ItemQuery:GetItemPropByConfigID(path, "Photo")
  tmp_imagegrid:AddItem(grid_index, photo, "", 1, -1)
  grid_index = grid_index + 1
  nx_set_custom(tmp_imagegrid, "config" .. i, nItem)
  return tmp_imagegrid
end
function show_new_school_contribute(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local new_school = client_player:QueryProp("NewSchool")
  if nil == new_school or "" == new_school then
    return
  end
  local total_score = client_player:QueryProp("NewSchoolContribute")
  local day_score = client_player:QueryProp("NewDailyContribute")
end
function on_btn_lot_exchange_click(btn)
  nx_execute("custom_sender", "custom_ancient_tomb_sender", 25, 1)
end
function on_imagegrid_lot_mousein_grid(grid, index)
  nx_execute("tips_game", "show_skill_tips", "CS_single_sjhb", 1001, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_lot_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function load_page_shimen(form)
  local new_school = form.school
  if nx_string(new_school) == nx_string("") then
    return false
  end
  local ini = get_ini("share\\ForceSchool\\gmp_shimen.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_index = ini:FindSectionIndex(nx_string(new_school))
  if sec_index < 0 then
    return false
  end
  local back = ini:ReadString(sec_index, "back", "")
  local text = ini:ReadString(sec_index, "text", "")
  form.lbl_shimen.BackImage = nx_string(back)
  form.mltbox_shimen:Clear()
  form.mltbox_shimen:AddHtmlText(nx_widestr(util_text(text)), -1)
  return true
end
function on_btn_paihang_click(btn)
  local form = btn.ParentForm
  if nx_string("newschool_gumu") == nx_string(form.school) then
    nx_execute("form_stage_main\\form_force\\form_force_gumupai_smdh", "open_form")
  elseif nx_string("newschool_changfeng") == nx_string(form.school) then
    nx_execute("form_stage_main\\form_force\\form_force_longmen_smdh", "open_form")
  elseif nx_string("newschool_shenshui") == nx_string(form.school) then
    nx_execute("form_stage_main\\form_force\\form_force_ssg_smdh", "open_form")
  elseif nx_string("newschool_wuxian") == nx_string(form.school) then
    nx_execute("form_stage_main\\form_force\\form_force_wxj_smdh", "open_form")
  elseif nx_string("newschool_damo") == nx_string(form.school) then
    nx_execute("form_stage_main\\form_force\\form_force_dmp_smdh", "open_form")
  elseif nx_string("newschool_xuedao") == nx_string(form.school) then
    util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
    local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
    if not nx_is_valid(rang_form) then
      return
    end
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_8_xdm_sqz")
  elseif nx_string("newschool_huashan") == nx_string(form.school) then
    util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
    local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
    if not nx_is_valid(rang_form) then
      return
    end
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_8_hsp_qclj")
  end
end
function update_lot_info(...)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_lot_name.Text = nx_widestr(arg[1])
  if nx_widestr(arg[1]) == nx_widestr("") then
    form.lbl_lot_name.Text = nx_widestr(util_text("ui_lot_005"))
    form.lbl_lot_time.Text = nx_widestr(util_text("ui_lot_005"))
    form.pbar_lot_value.Value = 0
    form.lbl_lot_title.Text = nx_widestr(util_text("ui_lot_005"))
    form.btn_lot_exchange.Enabled = false
  else
    form.lbl_lot_time.Text = nx_widestr(util_format_string("ui_lot_004", arg[2], arg[3], arg[4]))
    form.lbl_lot_value.Text = nx_widestr(arg[5])
    form.pbar_lot_value.Value = nx_int(arg[6])
    local lot_value = nx_int(arg[5])
    for i = 1, table.getn(lot_title) do
      local var = util_split_string(nx_string(lot_title[i]), ",")
      if lot_value >= nx_int(var[1]) and lot_value <= nx_int(var[2]) then
        form.lbl_lot_title.Text = nx_widestr(util_text(var[3]))
      end
    end
    form.btn_lot_exchange.Enabled = true
  end
end
function load_fqfs(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_id1 = "item_cfbj_gezi001"
  local item_photo1 = ItemQuery:GetItemPropByConfigID(item_id1, "Photo")
  local item_count1 = nx_int(1)
  form.ImageControlGrid_gezi:Clear()
  form.ImageControlGrid_gezi:AddItem(0, item_photo1, "", item_count1, -1)
  form.ImageControlGrid_gezi:SetItemAddInfo(0, nx_int(1), nx_widestr(item_id1))
  local item_id2 = "item_cfbj_ying001"
  local item_photo2 = ItemQuery:GetItemPropByConfigID(item_id2, "Photo")
  local item_count2 = nx_int(1)
  form.ImageControlGrid_ying:Clear()
  form.ImageControlGrid_ying:AddItem(0, item_photo2, "", item_count2, -1)
  form.ImageControlGrid_ying:SetItemAddInfo(0, nx_int(1), nx_widestr(item_id2))
  local item_id3 = "item_cfbj_jiu001"
  local item_photo3 = ItemQuery:GetItemPropByConfigID(item_id3, "Photo")
  local item_count3 = nx_int(1)
  form.ImageControlGrid_jiu:Clear()
  form.ImageControlGrid_jiu:AddItem(0, item_photo3, "", item_count3, -1)
  form.ImageControlGrid_jiu:SetItemAddInfo(0, nx_int(1), nx_widestr(item_id3))
end
function load_ssg_yjp(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local item_id = "item_yjp_1"
  local item_photo = ItemQuery:GetItemPropByConfigID(item_id, "Photo")
  local item_count = nx_int(1)
  form.ImageControlGrid_ss_yjp:Clear()
  form.ImageControlGrid_ss_yjp:AddItem(0, item_photo, "", item_count, -1)
  form.ImageControlGrid_ss_yjp:SetItemAddInfo(0, nx_int(1), nx_widestr(item_id))
  form.rbtn_ss_1.Checked = true
end
function on_icg_mousein_grid(grid, index)
  local item_config = grid:GetItemAddText(nx_int(index), nx_int(1))
  if nx_widestr(item_config) == nx_widestr("") or nx_widestr(item_config) == nx_widestr("nil") then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(item_config)
  item.ItemType = get_ini_prop("share\\Item\\tool_item.ini", nx_string(item_config), "ItemType", "0")
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_icg_mouseout_grid(grid, index)
  grid:SetSelectItemIndex(-1)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_rbtn_ss_1_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    form.groupbox_ss_1.Visible = true
    form.groupbox_ss_2.Visible = false
    form.groupbox_ss_3.Visible = false
  end
end
function on_rbtn_ss_2_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    form.groupbox_ss_1.Visible = false
    form.groupbox_ss_2.Visible = true
    form.groupbox_ss_3.Visible = false
  end
end
function on_rbtn_ss_3_checked_changed(btn)
  local form = btn.ParentForm
  if btn.Checked then
    form.groupbox_ss_1.Visible = false
    form.groupbox_ss_2.Visible = false
    form.groupbox_ss_3.Visible = true
  end
end
function InitRuleDate(form)
  if nx_string(form.school) == "0" or nx_string(form.school) == "" then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local repute = force_to_rule[nx_string(form.school)]
  form.mltbox_rule.HtmlText = gui.TextManager:GetFormatText("ui_schoollaw_rule") .. gui.TextManager:GetFormatText(repute)
end
function freshPag14(form, box)
  form.groupbox_wuxian.Visible = true
  load_guzhong_tool(form)
  box.finsh_fresh = true
end
function load_guzhong_tool(form)
  local ItemQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemQuery) then
    return
  end
  local grid = form.ImageControlGrid_guchong01
  grid:Clear()
  local item_id = "item_wxinsect_a"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid_guchong02
  grid:Clear()
  item_id = "item_wxinsect_b"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid_guchong03
  grid:Clear()
  item_id = "item_wxinsect_c"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
  grid = form.ImageControlGrid_guchong04
  grid:Clear()
  item_id = "item_wxinsect_d"
  photo = nx_string(ItemQuery:GetItemPropByConfigID(item_id, "Photo"))
  grid:AddItem(0, photo, nx_widestr(item_id), 1, -1)
end
function on_icg_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_icg_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_ImageControlGrid5_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_ImageControlGrid5_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_ImageControlGrid6_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_ImageControlGrid6_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_ImageControlGrid7_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_ImageControlGrid7_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_ImageControlGrid8_mousein_grid(grid, index)
  local item_config = grid:GetItemName(index)
  if nx_string(item_config) == "" then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", item_config, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid)
end
function on_ImageControlGrid8_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
