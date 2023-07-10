require("util_functions")
require("util_gui")
require("role_composite")
require("define\\gamehand_type")
require("util_vip")
require("share\\view_define")
require("tips_data")
require("share\\server_custom_define")
local form_name = "form_stage_main\\form_school_war\\form_new_school_msg_info"
INI_FORCE_INFO = "share\\War\\force_config.ini"
PIKONGZHANG_CONFIG = "share\\ForceSchool\\PiKongZhangRule.ini"
FORM_WIDTH_WANFA = 998
FORM_WIDTH = 766
TVT_PKZ = 23
local str_to_int = {
  force_yihua = 1,
  force_taohua = 2,
  force_xujia = 3,
  force_wanshou = 4,
  force_jinzhen = 5,
  force_wugen = 6
}
local force_to_repute = {
  force_yihua = "repute_yihua",
  force_taohua = "repute_taohua",
  force_xujia = "repute_xujia",
  force_wanshou = "repute_wanshou",
  force_jinzhen = "repute_jinzhen",
  force_wugen = "repute_wugen"
}
local force_sf_pos = {
  force_yihua = 2310,
  force_taohua = 2320,
  force_xujia = 2330,
  force_wugen = 2340,
  force_wanshou = 2350,
  force_jinzhen = 2360
}
local condition_pack = {}
local STC_SchoolMsg = 0
local gg_msg = "gg"
local ry_msg = "ry"
local cf_msg = "cf"
local kickout_force_value = 400
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  self.Left = (gui.Width - self.Width) / 2 + 111
  self.Top = (gui.Height - self.Height) / 2
  self.new_school_info = get_arraylist("new_school_info")
  self.new_school_info:ClearChild()
  self.force_round_task_info = get_arraylist("force_round_task_info")
  self.force_round_task_info:ClearChild()
  self.force_task_info = get_arraylist("force_task_info")
  self.force_task_info:ClearChild()
  InitMsg(self)
  InitDate(self)
  BingBoxToBtn(self)
  self.actor2 = nil
  set_force(self)
  self.grp_tvt_info.Visible = false
  self.grp_task.Visible = false
  self.task_id = 0
  self.tvt_type = 0
  query_condtion_msg()
  self.Width = FORM_WIDTH
  self.task_id = 0
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
  form.school = get_force(form)
  if nx_string(form.school) == "0" or nx_string(form.school) == "" then
    nx_destroy(form)
  end
  local gui = nx_value("gui")
  form.lbl_Title.Text = nx_widestr(gui.TextManager:GetFormatText(form.school))
  form.groupbox_m1.finsh_fresh = false
  form.groupbox_m2.finsh_fresh = false
  form.groupbox_m3.finsh_fresh = false
  form.groupbox_m4.finsh_fresh = false
  form.groupbox_m5.finsh_fresh = false
  form.groupbox_m6.finsh_fresh = false
  form.groupbox_m7.finsh_fresh = false
  form.groupbox_m1.Visible = false
  form.groupbox_m2.Visible = false
  form.groupbox_m3.Visible = false
  form.groupbox_m4.Visible = false
  form.groupbox_m5.Visible = false
  form.groupbox_m6.Visible = false
  form.groupbox_m7.Visible = false
  if form.school ~= "force_wugen" then
    form.rbtn_m5.Visible = false
  end
end
function on_main_form_close(self)
  self.new_school_info:ClearChild()
  self.force_round_task_info:ClearChild()
  self.force_task_info:ClearChild()
  clear_grid_data(self.textgrid_1, 2, 4)
  clear_grid_data(self.textgrid_2, 2, 5)
  nx_destroy(self)
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
  form.rbtn_m7.box = form.groupbox_m7
  form.rbtn_m1.freshUI = "freshPag1"
  form.rbtn_m2.freshUI = "freshPag2"
  form.rbtn_m3.freshUI = "freshPag3"
  form.rbtn_m4.freshUI = "freshPag4"
  form.rbtn_m5.freshUI = "freshPag5"
  form.rbtn_m6.freshUI = "freshPag6"
  form.rbtn_m7.freshUI = "freshPag7"
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
  local playerschool = client_player:QueryProp("Force")
  local skill_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\ForceSkillPoint.ini")
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
  if nx_ws_equal(nx_widestr(form.player_guild), nx_widestr("0")) then
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
  if btn.Checked == true and not btn.box.finsh_fresh then
    nx_execute(form_name, btn.freshUI, form, btn.box)
  end
  btn.box.Visible = btn.Checked
  if form.rbtn_m4.Checked == true then
    form.grp_tvt_info.Visible = true
    form.Width = FORM_WIDTH_WANFA
  else
    form.grp_tvt_info.Visible = false
    form.grp_task.Visible = false
    form.Width = FORM_WIDTH
  end
  if form.rbtn_m5.Checked == true then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return false
    end
    game_visual:CustomSend(nx_int(919), nx_int(0))
  end
end
function freshPag1(form, box)
  local base_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLibase.ini")
  if not nx_is_valid(base_ini) then
    return
  end
  local nIndex = base_ini:FindSectionIndex(nx_string(form.school))
  local BJInfo = base_ini:ReadString(nIndex, "BJInfo", "")
  local BJText = base_ini:ReadString(nIndex, "BJText", "")
  local DataText = base_ini:ReadString(nIndex, "DataText", "")
  local DataFL = base_ini:ReadString(nIndex, "DataFL", "")
  local gui = nx_value("gui")
  form.lbl_66.Text = nx_widestr(gui.TextManager:GetFormatText(BJText))
  form.mltbox_4.HtmlText = nx_widestr(gui.TextManager:GetFormatText(BJInfo))
  form.lbl_100.Text = nx_widestr(gui.TextManager:GetFormatText(DataText))
  local DataList = util_split_string(DataFL, ",")
  for i = 1, table.getn(DataList) do
    local name = "rbtn_a" .. nx_string(i)
    local rBtn = form.groupbox_11:Find(nx_string(name))
    if nx_is_valid(rBtn) then
      rBtn.info = nx_string(DataList[i])
    end
  end
  form.rbtn_a1.Checked = true
  box.finsh_fresh = true
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
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLigrow.ini")
  if not nx_is_valid(ini) then
    return
  end
  local nCount = ini:GetSectionCount()
  local gui = nx_value("gui")
  for i = 0, nCount - 1 do
    local force = ini:ReadInteger(i, "force", 0)
    local forceId = str_to_int[nx_string(form.school)]
    local condition = ini:ReadInteger(i, "Condition", 0)
    if forceId == force and nx_int(condition_pack[nx_string(condition)]) == nx_int(1) then
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
      if _k == 1 then
        if btn.condition == 1 then
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
    local force = ini:ReadInteger(i, "force", 0)
    local forceId = str_to_int[nx_string(form.school)]
    local condition = ini:ReadInteger(i, "Condition", 0)
    if forceId == force and nx_int(condition_pack[nx_string(condition)]) ~= nx_int(1) then
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
      if _k == 1 then
        if btn.condition == 1 then
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
  if btn.Checked == false then
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
      if nx_int(School) == nx_int(force) then
        local section = ruleini:GetSectionByIndex(sec_index)
        local Chapters = ruleini:ReadInteger(sec_index, "Chapters", 0)
        local Crime = ruleini:ReadInteger(sec_index, "Crime", 0)
        local Type = ruleini:ReadString(sec_index, "Type", "")
        local UiRes = ruleini:ReadString(sec_index, "UiRes", "")
        if nx_int(Type) == nx_int(rulekey) then
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
            rule_node.ForeColor = "255,128,101,74"
            rule_node.DrawMode = "FitWindow"
            rule_node.ItemHeight = 30
            if Chapters == 0 then
              rule_node.NodeBackImage = "gui\\common\\treeview\\tree4_1_out.png"
              rule_node.NodeFocusImage = "gui\\common\\treeview\\tree4_1_on.png"
              rule_node.NodeSelectImage = "gui\\common\\treeview\\tree4_1_on.png"
            else
              rule_node.NodeBackImage = "gui\\common\\treeview\\tree4_2_out.png"
              rule_node.NodeFocusImage = "gui\\common\\treeview\\tree4_2_on.png"
              rule_node.NodeSelectImage = "gui\\common\\treeview\\tree4_2_on.png"
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
  if form.rbtn_0.Visible == true then
    form.rbtn_0.Checked = true
  elseif form.rbtn_1.Visible == true then
    form.rbtn_1.Checked = true
  elseif form.rbtn_2.Visible == true then
    form.rbtn_2.Checked = true
  elseif form.rbtn_3.Visible == true then
    form.rbtn_3.Checked = true
  elseif form.rbtn_4.Visible == true then
    form.rbtn_4.Checked = true
  end
  box.finsh_fresh = true
end
function hide_or_show_child4(form)
  local base_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLibase.ini")
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
    if nx_number(k) ~= nx_number(name_list[i]) then
      local op = {
        Top = btn.Top,
        Left = btn.Left
      }
      tm4_btn[nx_number(name_list[i])] = op
    end
    if tm4_btn[nx_number(k)] == nil then
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
  if btn.Checked == false then
    btn.grid.true_num = btn.grid.true_num - 1
    if btn.grid.true_num == 0 then
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
  local forceId = str_to_int[nx_string(form.school)]
  btn.grid:BeginUpdate()
  btn.grid:ClearRow()
  local RW_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLiplay.ini")
  if not nx_is_valid(RW_ini) then
    return
  end
  local gui = nx_value("gui")
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
  if not client_player:FindRecord("force_activity_record") then
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
    if Type == nType and Force == forceId and nx_int(condition_pack[nx_string(condition)]) == nx_int(1) then
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
      local row = client_player:FindRecordRow("force_activity_record", 0, nx_int(tvt_type))
      local tvt_times = client_player:QueryRecord("force_activity_record", row, 3)
      local show_num = 0
      if nx_int(task_id) > nx_int(0) then
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
        if nx_int(child.round) < nx_int(0) then
          child.round = 0
        end
        if nx_int(child.max_round) < nx_int(0) then
          child.circle = 0
        end
        show_num = child.round
        if nType ~= 4 then
          MaxRoundNumber = child.max_round
        end
      else
        show_num = tvt_times
      end
      if nx_int(show_num) > nx_int(MaxRoundNumber) then
        show_num = MaxRoundNumber
      end
      if nx_int(show_num) < nx_int(0) then
        show_num = 0
      end
      if one_key == 1 then
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
      if nx_int(MaxRoundNumber) == nx_int(0) then
        btn.grid:SetGridText(nRow, 4, nx_widestr("-/-"))
      else
        btn.grid:SetGridText(nRow, 4, nx_widestr(show_num) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
      end
      btn.grid:SetGridText(nRow, 6, nx_widestr(0))
      btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
      btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      btn.grid:SetGridText(nRow, 13, nx_widestr(1))
      if nx_int(show_num) == nx_int(MaxRoundNumber) then
        btn.grid:SetGridText(nRow, 14, nx_widestr(1))
      else
        btn.grid:SetGridText(nRow, 14, nx_widestr(0))
      end
      if nx_int(tvt_type) == nx_int(TVT_PKZ) then
        if nx_int(btn.grid:GetGridText(nRow, 14)) == nx_int(1) then
          btn.grid:SetGridText(nRow, 9, nx_widestr(0))
        else
          btn.grid:SetGridText(nRow, 9, nx_widestr(get_pikongzhang_price()))
        end
        btn.grid:SetGridText(nRow, 12, nx_widestr(tvt_type))
      end
      gui.TextManager:Format_SetIDName(NpcPos)
      gui.TextManager:Format_AddParam(nx_string(Npc))
      local mText = gui:Create("MultiTextBox")
      set_copy_ent_info(form, "mltbox_ex4", mText)
      local npc_info = nx_widestr(gui.TextManager:Format_GetText())
      mText:Clear()
      mText:AddHtmlText(nx_widestr("<center>") .. nx_widestr(npc_info) .. nx_widestr("</center>"), nx_int(-1))
      if nType == 4 then
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
        if nx_int(child.round) > nx_int(MaxRoundNumber) then
          child.round = MaxRoundNumber
        end
        if nx_int(child.circle) > nx_int(MaxLoop) then
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
    if Type == nType and Force == forceId and nx_int(condition_pack[nx_string(condition)]) ~= nx_int(1) then
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
      local row = client_player:FindRecordRow("force_activity_record", 0, nx_int(tvt_type))
      local tvt_times = client_player:QueryRecord("force_activity_record", row, 3)
      local show_num = 0
      if nx_int(task_id) > nx_int(0) then
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
        if nx_int(child.round) < nx_int(0) then
          child.round = 0
        end
        if nx_int(child.max_round) < nx_int(0) then
          child.circle = 0
        end
        show_num = child.round
        if nType ~= 4 then
          MaxRoundNumber = child.max_round
        end
      else
        show_num = tvt_times
      end
      if nx_int(show_num) > nx_int(MaxRoundNumber) then
        show_num = MaxRoundNumber
      end
      if nx_int(show_num) < nx_int(0) then
        show_num = 0
      end
      if one_key == 1 then
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
      if nx_int(MaxRoundNumber) == nx_int(0) then
        btn.grid:SetGridText(nRow, 4, nx_widestr("-/-"))
      else
        btn.grid:SetGridText(nRow, 4, nx_widestr(show_num) .. nx_widestr("/") .. nx_widestr(MaxRoundNumber))
      end
      btn.grid:SetGridText(nRow, 6, nx_widestr(0))
      btn.grid:SetGridText(nRow, 10, nx_widestr(task_id))
      btn.grid:SetGridText(nRow, 11, nx_widestr(one_key))
      btn.grid:SetGridText(nRow, 13, nx_widestr(0))
      if nx_int(show_num) == nx_int(MaxRoundNumber) then
        btn.grid:SetGridText(nRow, 14, nx_widestr(1))
      else
        btn.grid:SetGridText(nRow, 14, nx_widestr(0))
      end
      if nx_int(tvt_type) == nx_int(TVT_PKZ) then
        btn.grid:SetGridText(nRow, 9, nx_widestr(get_pikongzhang_price()))
        btn.grid:SetGridText(nRow, 12, nx_widestr(tvt_type))
      end
      gui.TextManager:Format_SetIDName(NpcPos)
      gui.TextManager:Format_AddParam(nx_string(Npc))
      local mText = gui:Create("MultiTextBox")
      set_copy_ent_info(form, "mltbox_ex4", mText)
      local npc_info = nx_widestr(gui.TextManager:Format_GetText())
      mText:Clear()
      mText:AddHtmlText(nx_widestr("<center>") .. nx_widestr(npc_info) .. nx_widestr("</center>"), nx_int(-1))
      if nType == 4 then
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
        if nx_int(child.round) > nx_int(MaxRoundNumber) then
          child.round = MaxRoundNumber
        end
        if nx_int(child.circle) > nx_int(MaxLoop) then
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
  if nx_int(btn.grid:GetGridText(0, 11)) == nx_int(1) and nx_int(btn.grid:GetGridText(0, 13)) == nx_int(1) then
    form.grp_task.Visible = true
    form.task_id = nx_int(btn.grid:GetGridText(0, 10))
    if nx_int(btn.grid:GetGridText(0, 14)) == nx_int(1) then
      form.btn_task.Enabled = false
      form.btn_task.Text = util_text("ui_taskfinish")
      show_task_price(nx_int(0))
    else
      form.btn_task.Enabled = true
      form.btn_task.Text = util_text("ui_onekeyfinish")
      show_task_price(btn.grid:GetGridText(0, 9))
    end
    if nx_int(btn.grid:GetGridText(0, 12)) == nx_int(TVT_PKZ) then
      form.tvt_type = TVT_PKZ
    else
      form.tvt_type = 0
    end
  else
    form.grp_task.Visible = false
  end
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
    if nx_int(self:GetGridText(row, 12)) == nx_int(TVT_PKZ) then
      form.tvt_type = TVT_PKZ
    else
      form.tvt_type = 0
    end
  else
    form.grp_task.Visible = false
  end
end
function freshPag5(form, box)
  CreateChlieAndBindP5(form)
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
function CreateChlieAndBindP6(form)
  local gui = nx_value("gui")
  local base_ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLibase.ini")
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
  local gui = nx_value("gui")
  local nTips = nx_widestr(gui.TextManager:GetFormatText(nx_string(form.skill_point_tips)))
  form.lbl_18.Text = nx_widestr(nTips)
  form.pbar_3.Maximum = nx_number(form.skill_point_max)
  form.pbar_3.Value = nx_number(form.skill_point)
end
function on_btn_mg_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local nType = btn.type
  local forceId = str_to_int[nx_string(form.school)]
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLizaxue.ini")
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
      name.Align = "Center"
      lbl_pt.BackImage = nx_string(Photo)
      mutext.HtmlText = nx_widestr(gui.TextManager:GetFormatText(nx_string(Desc)))
      gui.TextManager:Format_SetIDName(nx_string(NpcTrack))
      if nx_string(Npc) ~= "" then
        gui.TextManager:Format_AddParam(nx_string(Npc))
      end
      mutext1.HtmlText = nx_widestr(gui.TextManager:Format_GetText())
      local lbl_leader = clone_label(form.lbl_leader)
      local lbl_origin = clone_label(form.lbl_origin)
      local lbl_origin1 = clone_label(form.lbl_origin1)
      local origin_list1 = util_split_string(origin1, ",")
      if nx_int(table.getn(origin_list1)) == nx_int(2) then
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
      if nx_int(table.getn(origin_list2)) == nx_int(2) then
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
      if nx_int(table.getn(origin_list3)) == nx_int(2) then
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
      if nx_string(Npc) == "" then
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
  set_player_info(form)
  CreateChlieAndBindP7(form)
  show_left_box(form, 1)
  box.finsh_fresh = true
  request_msg()
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
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_FORCE_ACTIVITY), nx_int(3), nx_int(force_id))
end
function fresh_force_msg(...)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) or not nx_is_valid(form.mltbox_school_msg_info) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLidongtai.ini")
  if not nx_is_valid(ini) then
    return
  end
  local force_id = arg[2]
  local row = arg[3]
  for i = 0, nx_number(row) - 1 do
    local msgtype = arg[i * 5 + 4]
    local startTime = arg[i * 5 + 5]
    local msginfo = arg[i * 5 + 6]
    local deletime = arg[i * 5 + 7]
    local index = ini:FindSectionIndex(nx_string(msgtype))
    local desc = ""
    local typedesc = ""
    if index < 0 then
      return
    end
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
function show_mount_model(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if nx_find_custom(form, "actor2") and nx_is_valid(form.actor2) then
    local world = nx_value("world")
    world:Delete(form.actor2)
  end
  if not nx_is_valid(form.scenebox_1.Scene) then
    util_addscene_to_scenebox(form.scenebox_1)
  end
  local actor2
  actor2 = create_scene_obj_composite(form.scenebox_1.Scene, client_player, false)
  util_add_model_to_scenebox(form.scenebox_1, actor2)
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
function open_form()
  local form = nx_value("form_stage_main\\form_school_war\\form_new_school_msg_info")
  if nx_is_valid(form) then
    form:Close()
  else
    form = util_get_form("form_stage_main\\form_school_war\\form_new_school_msg_info", true)
    form:Show()
    form.Visible = true
    form.rbtn_m7.Checked = true
  end
end
function GetTitles(nType)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if client_player:GetRecordRows("title_rec") <= 0 then
    return nil
  end
  local list_titles = {}
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_type = client_player:QueryRecord("title_rec", r, 1)
    if nx_int(rec_type) == nx_int(nType) then
      local rec_title = client_player:QueryRecord("title_rec", r, 0)
      table.insert(list_titles, rec_title)
    end
  end
  return list_titles
end
function GetShenfen(force)
  if nx_string(force) == "0" or nx_string(force) == "" then
    return ""
  end
  local pos_end = force_sf_pos[force]
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
  if -1 == rows then
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
  local force = player:QueryProp("Force")
  if force == nil or nx_string(force) == nx_string("") then
    return
  end
  local force_ini = get_ini(INI_FORCE_INFO)
  if not nx_is_valid(force_ini) then
    return
  end
  local index = force_ini:FindSectionIndex(force)
  local force_id = force_ini:ReadInteger(index, "ID", 0)
  nx_set_custom(form, "force_id", nx_int(force_id))
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
function query_condtion_msg(...)
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
  local player_force = player:QueryProp("Force")
  if nil == player_force or "" == player_force then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\ForceSchool\\forceUI\\ShiLiCondition.ini")
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
    if nx_int(condition) > nx_int(0) and player_force == force then
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
  if nx_int(form.tvt_type) == nx_int(TVT_PKZ) then
    local text = nx_widestr(gui.TextManager:GetFormatText("ui_yijianwancheng_tips", nx_int(form.lbl_ding.Text), nx_int(form.lbl_liang.Text), nx_int(form.lbl_wen.Text), nx_widestr(util_text("Forcefun_taohua09"))))
    if not ShowTipDialog(nx_widestr(text)) then
      return
    end
    nx_execute("custom_sender", "custom_pikongzhang_activity", 2)
  else
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
end
function get_pikongzhang_price()
  local pkz_ini = get_ini(PIKONGZHANG_CONFIG)
  if not nx_is_valid(pkz_ini) then
    return 0
  end
  local sec_index = pkz_ini:FindSectionIndex("onekeycomplete")
  return pkz_ini:ReadInteger(sec_index, "Money", 0)
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
function fresh_pkz()
  local form = nx_value(form_name)
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
  if not client_player:FindRecord("force_activity_record") then
    return
  end
  local row = client_player:FindRecordRow("force_activity_record", 0, nx_int(TVT_PKZ))
  local tvt_times = client_player:QueryRecord("force_activity_record", row, 3)
  if nx_int(tvt_times) == nx_int(1) then
    local list = form.textgrid_1
    for i = 0, list.RowCount - 1 do
      if nx_ws_equal(nx_widestr(list:GetGridText(i, 1)), nx_widestr(util_text("Forcefun_taohua09"))) then
        list:SetGridText(i, 4, nx_widestr(1) .. nx_widestr("/") .. nx_widestr(1))
        list:SetGridText(i, 9, nx_widestr(0))
        list:SetGridText(i, 14, nx_widestr(1))
        form.btn_task.Enabled = false
        form.btn_task.Text = util_text("ui_taskfinish")
        show_task_price(0)
      end
    end
  end
end
