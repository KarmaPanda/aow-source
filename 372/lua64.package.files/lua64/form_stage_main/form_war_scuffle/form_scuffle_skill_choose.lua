require("util_gui")
require("util_functions")
require("custom_sender")
require("util_static_data")
local CLIENT_CUSTOMMSG_LUAN_DOU = 784
local LuanDouClientMsg_RequestCanSelectSkill = 2
local LuanDouClientMsg_RequestOwnSkill = 3
local LuanDouClientMsg_SaveEquip = 4
local LuanDouClientMsg_SaveChannels = 5
local LuanDouClientMsg_SaveNeiGong = 6
local LuanDouClientMsg_AddSkill = 7
local LuanDouClientMsg_DelateSkill = 8
local FORM_SKILL_CHOOSE = "form_stage_main\\form_war_scuffle\\form_scuffle_skill_choose"
local neigong_file = "share\\War\\LuanDou\\luandou_ui_neigong.ini"
local MAX_LEVEL = "share\\War\\LuanDou\\luandou_ui_neigong_maxlevel.ini"
local channels_file = "share\\War\\LuanDou\\luandou_ui_jingmai.ini"
local baseskill_file = "share\\War\\LuanDou\\luandou_ui_skill_base.ini"
local uniquekill_file = "share\\War\\LuanDou\\luandou_ui_skill_update.ini"
local luandoukill_file = "share\\War\\LuanDou\\luandou_ui_skill_chaos.ini"
local luandoukill_type = "share\\War\\LuanDou\\luandou_war_wuxue.ini"
local FILE_SKILL_INI = "share\\Skill\\skill_new.ini"
local MAX_CHANNELS_NUM = 8
local TOTAL_CHANNELS_NUM = 0
local TOTAL_NEIGONG_NUM = 0
local NEIGONG_COL_NUM = 9
local JINGMAI_COL_NUM = 9
local luandou_tip_1 = "luandou_systeminfo_10101"
local luandou_tip_2 = "luandou_systeminfo_10102"
local luandou_tip_3 = "luandou_systeminfo_10103"
local luandou_tip_4 = "luandou_systeminfo_10104"
local luandou_tip_5 = "luandou_systeminfo_10105"
local luandou_tip_6 = "luandou_systeminfo_10106"
local player_own_skill_list = {}
local conform_argument_list = {}
local colour_table = {
  "255,201,88,81",
  "255,152,160,205",
  "255,186,151,114",
  "255,153,153,153",
  "255,233,192,80",
  "255,163,202,68"
}
local taolu_prop_colour = {
  "255,232,192,146",
  "255,209,152,43",
  "255,255,136,0"
}
local taolu_prop = {
  "ui_choswar_interface_001",
  "ui_choswar_interface_002",
  "ui_choswar_interface_003"
}
local own_skill_backimage = {
  "gui\\special\\war_scuffle\\2_btn_cy.png",
  "gui\\special\\war_scuffle\\2_btn_jr.png",
  "gui\\special\\war_scuffle\\2_btn_bz.png"
}
local jm_name = {}
local menpai_name = {}
local logo_name = {}
function open_form()
  local form = nx_value(FORM_SKILL_CHOOSE)
  if nx_is_valid(form) and not form.Visible then
    form.Visible = true
    form:Show()
  else
    util_show_form(FORM_SKILL_CHOOSE, true)
  end
end
function main_form_init(self)
  self.Fixed = true
  self.equip_plane = 0
  self.wuqi_plane = 0
  self.shangyi_plane = 0
  self.neigong_plane = 0
  self.prop = 0
  self.total_taolu = 0
  self.select_taolu_id = ""
end
function on_main_form_open(self)
  self.rbtn_skill.Checked = true
  init_ng_jm_num(self)
  init_jm_ng_name(self)
  init_neigong_data(self)
  init_jingmai_grid(self)
  get_player_own_equip_plane(self)
  get_player_own_channels_plane(self)
  get_player_own_neigong_plane(self)
  self.rbtn_all.Checked = true
  custom_request_selecte_skill()
  custom_request_all_can_select_skill()
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  player_own_skill_list = {}
  nx_destroy(self)
end
function on_rbtn_skill_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = true
  form.groupbox_equip.Visible = false
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = false
end
function on_rbtn_equip_mian_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = false
  form.groupbox_equip.Visible = true
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = false
end
function on_rbtn_channels_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = false
  form.groupbox_equip.Visible = false
  form.groupbox_channels.Visible = true
  form.groupbox_neigong.Visible = false
end
function on_rbtn_neigong_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_skill.Visible = false
  form.groupbox_equip.Visible = false
  form.groupbox_channels.Visible = false
  form.groupbox_neigong.Visible = true
end
function on_rbtn_skill_type_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  local taolu_type = nx_int(rbtn.DataSource)
  control_rbtn_visible(form, taolu_type)
end
function on_btn_add_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local strTaoLu = form.select_taolu_id
  if nx_string(strTaoLu) == nx_string("") then
    SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_5), 2)
    return
  end
  if nx_int(#player_own_skill_list / 2) >= nx_int(3) then
    SystemCenterInfo:ShowSystemCenterInfo(util_text("luandou_systeminfo_10021"), 2)
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "luandou_add_skill")
  if not nx_is_valid(dialog) then
    return
  end
  local text = get_confirm_text(form, nx_int(1))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "luandou_add_skill_confirm_return")
  if res ~= "ok" then
    return
  end
  local nProp = nx_int(form.prop)
  custom_add_skill(nx_string(strTaoLu), nx_int(nProp))
end
function on_btn_delate_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(btn, "TaoLuID") then
    return
  end
  local strTaoLu = nx_string(btn.TaoLuID)
  if nx_string(strTaoLu) == nx_string("") then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_5), 2)
    end
    return
  end
  custom_delate_skill(strTaoLu)
end
function on_rbtn_equip_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.equip_plane = nx_int(rbtn.DataSource)
end
function on_rbtn_wuqi_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.wuqi_plane = nx_int(rbtn.DataSource)
end
function on_rbtn_shangyi_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  form.shangyi_plane = nx_int(rbtn.DataSource)
end
function on_btn_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.equip_plane) < nx_int(1) or nx_int(form.equip_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_2), 2)
    end
    return
  end
  if nx_int(form.wuqi_plane) < nx_int(1) or nx_int(form.wuqi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_3), 2)
    end
    return
  end
  if nx_int(form.shangyi_plane) < nx_int(1) or nx_int(form.shangyi_plane) > nx_int(5) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_4), 2)
    end
    return
  end
  local strPlane = nx_string(form.equip_plane) .. nx_string(",") .. nx_string(form.wuqi_plane) .. nx_string(",") .. nx_string(form.shangyi_plane)
  custom_save_equip_plane(nx_string(strPlane))
end
function on_btn_channels_save_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strChannels = get_player_select_channels()
  local temp_table = util_split_string(strChannels, ",")
  local count = table.getn(temp_table)
  if nx_int(count - 1) ~= nx_int(MAX_CHANNELS_NUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("sys_balance_war_channels_1"), 2)
    end
    return
  end
  local strNew = ""
  for i = 1, MAX_CHANNELS_NUM do
    if i ~= MAX_CHANNELS_NUM then
      strNew = strNew .. nx_string(temp_table[i]) .. nx_string(",")
    else
      strNew = strNew .. nx_string(temp_table[i])
    end
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "luandou_save_jingmai")
  if not nx_is_valid(dialog) then
    return
  end
  local text = get_confirm_text(form, nx_int(2))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "luandou_save_jingmai_confirm_return")
  if res ~= "ok" then
    return
  end
  custom_save_channels_plane(strNew)
end
function on_cbtn_neigong_index_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  form.neigong_plane = nx_int(cbtn.self_index)
  for i = 1, TOTAL_NEIGONG_NUM do
    local gb_name = "groupbox_neigong_" .. nx_string(i)
    local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_1_" .. nx_string(i)
      local cbtn_ng = gbox:Find(nx_string(cbtn_name))
      if cbtn_ng.self_index ~= cbtn.self_index then
        cbtn_ng.Checked = false
      end
    end
  end
  show_neigong_prop(form, cbtn)
end
function on_btn_save_neigong_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local nIndex = nx_int(form.neigong_plane)
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(TOTAL_NEIGONG_NUM) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_1), 2)
    end
    return
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "luandou_save_neigong")
  if not nx_is_valid(dialog) then
    return
  end
  local text = get_confirm_text(form, nx_int(3))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "luandou_save_neigong_confirm_return")
  if res ~= "ok" then
    return
  end
  custom_save_neigong_plane(nIndex)
end
function on_imagegrid_neigong_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "neigong_config") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local neigong_config = grid.neigong_config
  local ng_level, buff_level, wu_xing = get_neigong_max_level(nx_string(neigong_config))
  local neigong = nx_execute("tips_game", "get_tips_ArrayList")
  neigong.ConfigID = nx_string(neigong_config)
  neigong.ItemType = 1002
  neigong.Level = nx_int(ng_level)
  neigong.MaxLevel = nx_int(ng_level)
  neigong.StaticData = nx_int(grid.static_data)
  neigong.BufferLevel = nx_int(buff_level)
  neigong.WuXing = nx_int(wu_xing)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", neigong, x, y, 32, 32, form, false)
end
function on_imagegrid_neigong_mouseout_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_imagegrid_get_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(grid, "jingmai_id") then
    return
  end
  if not nx_find_custom(grid, "static_data") then
    return
  end
  local jingmai_id = grid.jingmai_id
  local jingmai = nx_execute("tips_game", "get_tips_ArrayList")
  jingmai.ConfigID = nx_string(jingmai_id)
  jingmai.ItemType = 1003
  jingmai.Level = 216
  jingmai.StaticData = nx_int(grid.static_data)
  local x = grid.AbsLeft
  local y = grid.AbsTop
  nx_execute("tips_game", "show_goods_tip", jingmai, x, y, 32, 32, form, false)
end
function on_imagegrid_lost_capture(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_rbtn_can_select_skill_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not rbtn.Checked then
    return
  end
  if not rbtn.Visible then
    return
  end
  form.prop = rbtn.prop
  local taolu_id = rbtn.TaoLuID
  form.select_taolu_id = taolu_id
  local nAttack, nExist, nControl, nOperation, strDefine, nColour = get_taolu_prop(taolu_id, form.prop, 1)
  if nAttack == "" then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text(luandou_tip_6), 2)
    end
    return
  end
  form.lbl_wuxue_title.Text = nx_widestr(util_text(taolu_id))
  form.lbl_wuxue_title.ForeColor = nx_string(colour_table[nColour])
  set_star(form.groupbox_attack, nAttack)
  set_star(form.groupbox_defend, nExist)
  set_star(form.groupbox_recover, nControl)
  set_star(form.groupbox_operate, nOperation)
  form.mltbox_site.HtmlText = nx_widestr(util_text(strDefine))
  local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(rbtn.prop, taolu_id)
  if nx_int(neigong_wuxing) > nx_int(0) and nx_int(neigong_wuxing) < nx_int(6) then
    form.mltbox_ng.HtmlText = nx_widestr(util_text("desc_luandou_neigong_define_" .. nx_string(neigong_wuxing)))
  end
  if nx_int(jingmai_wuxing) > nx_int(0) and nx_int(jingmai_wuxing) < nx_int(6) then
    form.mltbox_jm.HtmlText = nx_widestr(util_text("desc_luandou_jingmai_define_" .. nx_string(jingmai_wuxing)))
  end
  local strSkill = get_taolu_prop(taolu_id, form.prop, 2)
  local skill_list = util_split_string(strSkill, ";")
  local grid = form.imagegrid_skill
  if not nx_is_valid(grid) then
    return
  end
  grid:Clear()
  for j = 1, #skill_list do
    if skill_list[j] ~= "" then
      local photo = skill_static_query_by_id(nx_string(skill_list[j]), "Photo")
      grid:AddItem(nx_int(j - 1), photo, util_text(skill_list[j]), 1, -1)
    end
  end
end
function on_imagegrid_skill_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local strTaolu = form.select_taolu_id
  if nx_string(strTaolu) == nx_string("") then
    return
  end
  local nProp = form.prop
  local strSkill = get_taolu_prop(strTaolu, nProp, 2)
  local skill_list = util_split_string(strSkill, ";")
  local skill_id = skill_list[index + 1]
  if nx_string(skill_id) == nx_string("") then
    return
  end
  local staticdata = nx_execute("tips_data", "get_ini_prop", FILE_SKILL_INI, skill_id, "StaticData", "")
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(skill_id)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(staticdata)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.GridWidth, grid.GridHeight, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function on_cbtn_neigong_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  clear_all_select_jm(form)
  if cbtn.Checked then
    form.cbtn_jm_1.Checked = true
    form.cbtn_jm_2.Checked = true
    form.cbtn_jm_4.Checked = true
    form.cbtn_jm_5.Checked = true
    form.cbtn_jm_10.Checked = true
    form.cbtn_jm_11.Checked = true
    form.cbtn_jm_13.Checked = true
    form.cbtn_jm_14.Checked = true
  end
end
function on_cbtn_waigong_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not cbtn.Checked then
    return
  end
  clear_all_select_jm(form)
  if cbtn.Checked then
    form.cbtn_jm_3.Checked = true
    form.cbtn_jm_6.Checked = true
    form.cbtn_jm_7.Checked = true
    form.cbtn_jm_8.Checked = true
    form.cbtn_jm_12.Checked = true
    form.cbtn_jm_15.Checked = true
    form.cbtn_jm_16.Checked = true
    form.cbtn_jm_17.Checked = true
  end
end
function custom_add_skill(strSkill, prop)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_AddSkill), nx_string(strSkill), nx_int(prop))
end
function custom_delate_skill(strSkill)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_DelateSkill), nx_string(strSkill))
end
function custom_save_equip_plane(strEquipPlane)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_SaveEquip), nx_string(strEquipPlane))
end
function custom_save_channels_plane(strChannelsPlane)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_SaveChannels), nx_string(strChannelsPlane))
end
function custom_save_neigong_plane(nNeiGong)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_SaveNeiGong), nx_int(nNeiGong))
end
function custom_request_selecte_skill()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_RequestOwnSkill))
end
function custom_request_all_can_select_skill()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_LUAN_DOU), nx_int(LuanDouClientMsg_RequestCanSelectSkill))
end
function rec_all_player_can_select_skill(...)
  local form = nx_value(FORM_SKILL_CHOOSE)
  if not nx_is_valid(form) then
    return
  end
  local skill_type_list = util_split_string(nx_string(arg[1]), "|")
  if nx_int(#skill_type_list) ~= nx_int(3) then
    return
  end
  local gbox = form.gsb_wuxue
  if not nx_is_valid(gbox) then
    return
  end
  local count = 0
  gbox:DeleteAll()
  for i = 3, 1, -1 do
    local strSkill = skill_type_list[i]
    local skill_list = util_split_string(strSkill, ",")
    if math.mod(#skill_list, 2) == 0 then
      local rbtn
      for j = 1, #skill_list, 2 do
        if i == 1 then
          if nx_int(skill_list[j + 1]) == nx_int(0) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module_3, gbox)
          elseif nx_int(skill_list[j + 1]) == nx_int(1) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module_6, gbox)
          end
        elseif i == 2 then
          if nx_int(skill_list[j + 1]) == nx_int(0) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module_2, gbox)
          elseif nx_int(skill_list[j + 1]) == nx_int(1) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module_5, gbox)
          end
        elseif i == 3 then
          if nx_int(skill_list[j + 1]) == nx_int(0) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module, gbox)
          elseif nx_int(skill_list[j + 1]) == nx_int(1) then
            rbtn = create_ctrl("RadioButton", "rbtn_can_select_" .. nx_string(count), form.rbtn_module_4, gbox)
          end
        end
        if nx_is_valid(rbtn) then
          rbtn.prop = nx_int(i)
          local nType = get_skill_type(skill_list[j])
          rbtn.type = nx_int(nType)
          rbtn.TaoLuID = skill_list[j]
          rbtn.Text = util_text(skill_list[j])
          rbtn.ForeColor = taolu_prop_colour[i]
          rbtn.Visible = true
          nx_bind_script(rbtn, nx_current())
          nx_callback(rbtn, "on_checked_changed", "on_rbtn_can_select_skill_checked_changed")
          count = count + 1
        end
        change_ctrl_position(rbtn, count)
      end
    end
  end
  form.total_taolu = nx_int(count)
  gbox.IsEditMode = false
  gbox:ApplyChildrenCustomYPos()
end
function rec_player_own_skill(...)
  local form = nx_value(FORM_SKILL_CHOOSE)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.groupbox_own_skill
  if not nx_is_valid(gbox) then
    return
  end
  clear_own_skill_label(gbox)
  local count = table.getn(arg)
  if math.mod(count, 2) ~= 0 then
    return
  end
  player_own_skill_list = {}
  local index = 1
  for i = count - 1, 1, -2 do
    local lbl_name = "lbl_own_" .. nx_string(index)
    local btn_name = "btn_delate_" .. nx_string(index)
    local lbl_prop_name = "lbl_own_prop_" .. nx_string(index)
    local lbl = gbox:Find(nx_string(lbl_name))
    local btn = gbox:Find(nx_string(btn_name))
    local lbl_prop = gbox:Find(nx_string(lbl_prop_name))
    if nx_is_valid(lbl) and nx_is_valid(btn) and nx_is_valid(lbl_prop) then
      lbl.Text = util_text(nx_string(arg[i]))
      lbl.ForeColor = taolu_prop_colour[arg[i + 1]]
      btn.TaoLuID = nx_string(arg[i])
      btn.Visible = true
      lbl_prop.BackImage = own_skill_backimage[arg[i + 1]]
    end
    table.insert(player_own_skill_list, arg[i])
    table.insert(player_own_skill_list, arg[i + 1])
    index = index + 1
  end
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "updata_player_own_skill_data", unpack(player_own_skill_list))
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  ctrl.Name = name
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  return ctrl
end
function init_ng_jm_num(form)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  TOTAL_NEIGONG_NUM = nx_number(ini:GetSectionItemCount(sec_count))
  local ini = nx_execute("util_functions", "get_ini", channels_file)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  TOTAL_CHANNELS_NUM = nx_number(ini:GetSectionItemCount(sec_count))
end
function init_jm_ng_name(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\LuanDou\\luandou_ui_name.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:FindSectionIndex("jm_name")
  if sec_count < 0 then
    return ""
  end
  local num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local jingmai_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(jm_name, nx_string(jingmai_name))
  end
  sec_count = ini:FindSectionIndex("menpai_name")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local neigong_name = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(menpai_name, nx_string(neigong_name))
  end
  sec_count = ini:FindSectionIndex("menpai_logo")
  if sec_count < 0 then
    return ""
  end
  num = nx_number(ini:GetSectionItemCount(sec_count))
  for i = 1, num do
    local logo = ini:ReadString(sec_count, nx_string(i), "")
    table.insert(logo_name, nx_string(logo))
  end
end
function init_neigong_data(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_ng_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_ng
  local gb_str = "groupbox_neigong_"
  local cbtn_ng_str = "cbtn_1_"
  local lbl_bg_str = "lbl_bg_"
  local lbl_mp_name_str = "lbl_mp_name_"
  local lbl_logo_str = "lbl_logo_"
  local imagegrid_ng_str = "imagegrid_1_"
  local lbl_ng_name_str = "lbl_ng_name_"
  local cbtn_ng_mod = form.cbtn_ng_mod
  local lbl_bg_mod = form.lbl_bg_mod
  local lbl_mp_name_mod = form.lbl_mp_name_mod
  local lbl_logo_mod = form.lbl_logo_mod
  local imagegrid_ng_mod = form.imagegrid_ng_mod
  local lbl_ng_name_mod = form.lbl_ng_name_mod
  for i = 1, TOTAL_NEIGONG_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_neigong = create_ctrl("CheckButton", nx_string(cbtn_ng_str) .. nx_string(i), cbtn_ng_mod, gb)
    local lbl_bg = create_ctrl("Label", nx_string(lbl_bg_str) .. nx_string(i), lbl_bg_mod, gb)
    local lbl_mp = create_ctrl("Label", nx_string(lbl_mp_name_str) .. nx_string(i), lbl_mp_name_mod, gb)
    local lbl_logo = create_ctrl("Label", nx_string(lbl_logo_str) .. nx_string(i), lbl_logo_mod, gb)
    local imagegrid_ng = create_ctrl("ImageGrid", nx_string(imagegrid_ng_str) .. nx_string(i), imagegrid_ng_mod, gb)
    local lbl_ng_name = create_ctrl("Label", nx_string(lbl_ng_name_str) .. nx_string(i), lbl_ng_name_mod, gb)
    gb.Left = math.fmod(i - 1, NEIGONG_COL_NUM) * gb.Width + 2
    gb.Top = math.floor((i - 1) / NEIGONG_COL_NUM) * gb.Height + 2
    nx_bind_script(cbtn_neigong, nx_current())
    nx_callback(cbtn_neigong, "on_checked_changed", "on_cbtn_neigong_index_checked_changed")
    nx_bind_script(imagegrid_ng, nx_current())
    nx_callback(imagegrid_ng, "on_mousein_grid", "on_imagegrid_neigong_mousein_grid")
    nx_callback(imagegrid_ng, "on_mouseout_grid", "on_imagegrid_neigong_mouseout_grid")
    cbtn_neigong.self_index = nx_number(i)
    local neigong_cbtn = search_neigong_cbtn(form, nx_string(i))
    local neigong_config = get_neigong_config_id(neigong_cbtn, nx_string(i))
    if neigong_config ~= "" then
      local neigong_photo, neigong_static_data = query_photo_by_configid(nx_string(neigong_config), nx_int(2))
      local label = find_neigong_grid_and_label(form, i)
      local grid = search_neigong_grid(form, i)
      local menpai_lbl, menpI_logo = get_menpai_lbl_logo(form, nx_string(i))
      if nx_is_valid(grid) and nx_is_valid(label) and nx_is_valid(menpai_lbl) and nx_is_valid(menpI_logo) then
        grid:AddItem(0, neigong_photo, nx_widestr(neigong_config), 1, -1)
        grid.neigong_config = neigong_config
        grid.static_data = neigong_static_data
        menpai_lbl.Text = nx_widestr(util_text(menpai_name[i]))
        local temp = "gui\\special\\battlefiled_balance\\logo\\" .. nx_string(logo_name[i])
        menpI_logo.BackImage = temp
        label.Text = nx_widestr(util_text(neigong_config))
      end
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function get_menpai_lbl_logo(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local menpai_lbl = nx_null()
  local menpai_logo = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local menpai_lbl_name = "lbl_mp_name_" .. nx_string(index)
    local menpai_logo_name = "lbl_logo_" .. nx_string(index)
    menpai_lbl = gbox:Find(nx_string(menpai_lbl_name))
    menpai_logo = gbox:Find(nx_string(menpai_logo_name))
  end
  return menpai_lbl, menpai_logo
end
function get_neigong_config_id(cbtn, index)
  local ini = nx_execute("util_functions", "get_ini", neigong_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_neigong")
  if sec_count < 0 then
    return ""
  end
  local neigong = ini:ReadString(sec_count, nx_string(index), "")
  local neigong_list = util_split_string(neigong, ";")
  if nx_int(#neigong_list) ~= nx_int(6) then
    return ""
  end
  if nx_is_valid(cbtn) then
    cbtn.bili = nx_int(neigong_list[2])
    cbtn.shenfa = nx_int(neigong_list[3])
    cbtn.neixi = nx_int(neigong_list[4])
    cbtn.gangqi = nx_int(neigong_list[5])
    cbtn.tipo = nx_int(neigong_list[6])
  end
  local neigong_id = neigong_list[1]
  return neigong_id
end
function query_photo_by_configid(config_id, item_type)
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return ""
  end
  local file_name = ""
  if nx_int(item_type) == nx_int(1) then
    file_name = "share\\Skill\\JingMai\\jingmai.ini"
  elseif nx_int(item_type) == nx_int(2) then
    file_name = "share\\Skill\\NeiGong\\neigong.ini"
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:LoadIniToManager(file_name)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(config_id))
  if nx_number(index) < 0 then
    return ""
  end
  local static_data = ini:ReadString(index, "StaticData", "")
  IniManager:UnloadIniFromManager(file_name)
  local photo = ""
  if nx_int(item_type) == nx_int(1) then
    photo = data_query:Query(9, nx_int(static_data), "Photo")
  elseif nx_int(item_type) == nx_int(2) then
    photo = data_query:Query(26, nx_int(static_data), "Photo")
  end
  return photo, static_data
end
function find_neigong_grid_and_label(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local lbl = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local lbl_name = "lbl_ng_name_" .. nx_string(index)
    lbl = gbox:Find(nx_string(lbl_name))
  end
  return lbl
end
function get_neigong_max_level(strConfig)
  if strConfig == nil or strConfig == "" then
    return 0, 0
  end
  local ini = nx_execute("util_functions", "get_ini", MAX_LEVEL)
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(strConfig)
  if sec_index < 0 then
    return 0, 0
  end
  local max_level = ini:ReadInteger(sec_index, "value", 0)
  local buff_level = ini:ReadInteger(sec_index, "buff_level", 0)
  local wux_xing = ini:ReadInteger(sec_index, "define_deviation", 0)
  return max_level, buff_level, wux_xing
end
function search_neigong_cbtn(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local cbtn = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local rbtn_name = "cbtn_1_" .. nx_string(index)
    cbtn = gbox:Find(nx_string(rbtn_name))
  end
  return cbtn
end
function search_neigong_grid(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local grid = nx_null()
  local gb_name = "groupbox_neigong_" .. nx_string(index)
  local gbox = form.groupscrollbox_ng:Find(nx_string(gb_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_1_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
  end
  return grid
end
function show_neigong_prop(form, rbtn)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(rbtn) then
    return
  end
  form.lbl_bili.Text = nx_widestr(rbtn.bili)
  form.lbl_shenfa.Text = nx_widestr(rbtn.shenfa)
  form.lbl_neixi.Text = nx_widestr(rbtn.neixi)
  form.lbl_gangqi.Text = nx_widestr(rbtn.gangqi)
  form.lbl_tipo.Text = nx_widestr(rbtn.tipo)
end
function init_jingmai_grid(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_mod = form.groupbox_jingmai_mod
  if not nx_is_valid(gb_mod) then
    return
  end
  local gsb = form.groupscrollbox_jingmai_mod
  local gb_str = "groupbox_jingmai_"
  local cbtn_jm_str = "cbtn_jm_"
  local imagegrid_jm_str = "imagegrid_jm_"
  local lbl_jm_name_str = "lbl_jm_name_"
  local cbtn_jm_mod = form.cbtn_jm_mod
  local imagegrid_jm_mod = form.imagegrid_jm_mod
  local lbl_jm_name_mod = form.lbl_jm_name_mod
  for i = 1, TOTAL_CHANNELS_NUM do
    local gb = create_ctrl("GroupBox", nx_string(gb_str) .. nx_string(i), gb_mod, gsb)
    local cbtn_jingmai = create_ctrl("CheckButton", nx_string(cbtn_jm_str) .. nx_string(i), cbtn_jm_mod, gb)
    local imagegrid_jm = create_ctrl("ImageGrid", nx_string(imagegrid_jm_str) .. nx_string(i), imagegrid_jm_mod, gb)
    local lbl_jm_name = create_ctrl("MultiTextBox", nx_string(lbl_jm_name_str) .. nx_string(i), lbl_jm_name_mod, gb)
    gb.Left = math.fmod(i - 1, JINGMAI_COL_NUM) * gb.Width
    gb.Top = math.floor((i - 1) / JINGMAI_COL_NUM) * gb.Height
    nx_bind_script(imagegrid_jm, nx_current())
    nx_callback(imagegrid_jm, "on_lost_capture", "on_imagegrid_lost_capture")
    nx_callback(imagegrid_jm, "on_get_capture", "on_imagegrid_get_capture")
    local jingmai_id = get_jingmai_id(nx_string(i))
    local grid, lbl = get_jingmai_grid(form, nx_int(i))
    if nx_is_valid(grid) and nx_is_valid(lbl) then
      local photo, static_data = query_photo_by_configid(nx_string(jingmai_id), nx_int(1))
      lbl.HtmlText = nx_widestr(util_text(jm_name[i]))
      grid:AddItem(0, photo, nx_widestr(jingmai_id), 1, -1)
      grid.jingmai_id = jingmai_id
      grid.static_data = static_data
    end
  end
  gsb.IsEditMode = false
  gsb.Height = gsb.Height
end
function get_jingmai_id(index)
  local ini = nx_execute("util_functions", "get_ini", channels_file)
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_count = ini:FindSectionIndex("ui_balance_war_jingmai")
  if sec_count < 0 then
    return ""
  end
  local jingmai_id = ini:ReadString(sec_count, nx_string(index), "")
  return jingmai_id
end
function get_jingmai_grid(form, index)
  if not nx_is_valid(form) then
    return nx_null()
  end
  local grid = nx_null()
  local lbl = nx_null()
  local gbox_name = "groupbox_jingmai_" .. nx_string(index)
  local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local grid_name = "imagegrid_jm_" .. nx_string(index)
    grid = gbox:Find(nx_string(grid_name))
    local lbl_name = "lbl_jm_name_" .. nx_string(index)
    lbl = gbox:Find(nx_string(lbl_name))
  end
  return grid, lbl
end
function get_player_select_channels()
  local strChannels = ""
  local form = nx_value(FORM_SKILL_CHOOSE)
  if not nx_is_valid(form) then
    return strChannels
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_jingmai_" .. nx_string(i)
    local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_jm_" .. nx_string(i)
      local cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) and cbtn.Checked then
        strChannels = strChannels .. nx_string(i) .. nx_string(",")
      end
    end
  end
  return strChannels
end
function find_channels_cbtn(form, index)
  local cbtn = nx_null()
  if not nx_is_valid(form) then
    return cbtn
  end
  local gbox_name = "groupbox_jingmai_" .. nx_string(index)
  local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
  if nx_is_valid(gbox) then
    local cbtn_name = "cbtn_jm_" .. nx_string(index)
    cbtn = gbox:Find(nx_string(cbtn_name))
  end
  return cbtn
end
function get_player_own_equip_plane(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local strEquip = player:QueryProp("LuanDouEquipPlane")
  local equip_list = util_split_string(strEquip, ",")
  if nx_int(#equip_list) ~= nx_int(3) then
    return
  end
  local rbtn_equip_name = "rbtn_equip_" .. nx_string(equip_list[1])
  local rbtn_wuqi_name = "rbtn_wuqi_" .. nx_string(equip_list[2])
  local rbtn_shangyi_name = "rbtn_shangyi_" .. nx_string(equip_list[3])
  local rbtn_equip = form.groupbox_11:Find(nx_string(rbtn_equip_name))
  local rbtn_wuqi = form.groupbox_12:Find(nx_string(rbtn_wuqi_name))
  local rbtn_shangyi = form.groupbox_13:Find(nx_string(rbtn_shangyi_name))
  if nx_is_valid(rbtn_equip) and nx_is_valid(rbtn_wuqi) and nx_is_valid(rbtn_shangyi) then
    rbtn_equip.Checked = true
    rbtn_wuqi.Checked = true
    rbtn_shangyi.Checked = true
  end
end
function get_player_own_channels_plane(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local strChannels = player:QueryProp("LuanDouChannelsPlane")
  local channels_list = util_split_string(strChannels, ",")
  if nx_int(#channels_list) ~= nx_int(MAX_CHANNELS_NUM) then
    return
  end
  for i = 1, MAX_CHANNELS_NUM do
    local cbtn = find_channels_cbtn(form, channels_list[i])
    if nx_is_valid(cbtn) then
      cbtn.Checked = true
    end
  end
end
function get_player_own_neigong_plane(form)
  if not nx_is_valid(form) then
    return
  end
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local nNeiGongIndex = player:QueryProp("LuanDouNeiGongIndex")
  local neigong_cbtn = search_neigong_cbtn(form, nNeiGongIndex)
  if nx_is_valid(neigong_cbtn) then
    neigong_cbtn.Checked = true
  end
end
function get_player()
  local client = nx_value("game_client")
  local client_player = client:GetPlayer()
  return client_player
end
function change_ctrl_position(rbtn, index)
  if not nx_is_valid(rbtn) then
    return
  end
  if nx_int(index) <= nx_int(0) then
    return
  end
  local count = nx_number(index - 1)
  local row = math.fmod(count, 5)
  local col = math.floor(count / 5)
  rbtn.Left = (rbtn.Width + 12) * row + 12
  rbtn.Top = (rbtn.Height + 5) * col + 5
end
function get_taolu_prop(taolu_id, prop, nIndex)
  if taolu_id == nil or taolu_id == "" then
    return ""
  end
  if nx_int(nIndex) < nx_int(1) or nx_int(nIndex) > nx_int(2) then
    return ""
  end
  local ini = nx_null()
  if nx_int(prop) == nx_int(1) then
    ini = nx_execute("util_functions", "get_ini", baseskill_file)
  elseif nx_int(prop) == nx_int(2) then
    ini = nx_execute("util_functions", "get_ini", uniquekill_file)
  elseif nx_int(prop) == nx_int(3) then
    ini = nx_execute("util_functions", "get_ini", luandoukill_file)
  end
  if not nx_is_valid(ini) then
    return ""
  end
  local sec_index = ini:FindSectionIndex(taolu_id)
  if sec_index < 0 then
    return ""
  end
  if nx_int(nIndex) == nx_int(2) then
    local strSkill = ini:ReadString(sec_index, "1", "")
    return strSkill
  end
  local nAttack = ini:ReadInteger(sec_index, "attack", 0)
  local nExist = ini:ReadInteger(sec_index, "exist", 0)
  local nControl = ini:ReadInteger(sec_index, "control", 0)
  local nOperation = ini:ReadInteger(sec_index, "operation", 0)
  local strDefine = ini:ReadString(sec_index, "definition", "")
  local nColour = ini:ReadInteger(sec_index, "colourset", "")
  return nAttack, nExist, nControl, nOperation, strDefine, nColour
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
  for i = 1, num do
    local lbl_star = gui:Create("Label")
    groupbox:Add(lbl_star)
    lbl_star.Left = (i - 1) * 20
    lbl_star.Top = 0
    lbl_star.BackImage = "gui\\special\\helper\\school_introduction\\star_2.png"
    lbl_star.AutoSize = true
  end
end
function control_rbtn_visible(form, taolu_type)
  if not nx_is_valid(form) then
    return
  end
  local gbox = form.gsb_wuxue
  if not nx_is_valid(gbox) then
    return
  end
  local visible_num = 0
  for i = 1, form.total_taolu do
    local rbtn_name = "rbtn_can_select_" .. nx_string(i - 1)
    local rbtn = gbox:Find(rbtn_name)
    if nx_is_valid(rbtn) then
      if nx_int(taolu_type) == nx_int(0) then
        rbtn.Visible = true
        visible_num = visible_num + 1
        change_ctrl_position(rbtn, visible_num)
      elseif nx_int(rbtn.type) ~= nx_int(taolu_type) then
        rbtn.Visible = false
      else
        rbtn.Visible = true
        visible_num = visible_num + 1
        change_ctrl_position(rbtn, visible_num)
      end
    end
  end
  gbox.IsEditMode = false
  gbox:ApplyChildrenCustomYPos()
end
function clear_own_skill_label(gbox)
  if not nx_is_valid(gbox) then
    return
  end
  for i = 1, 3 do
    local lbl_name = "lbl_own_" .. nx_string(i)
    local lbl_prop_name = "lbl_own_prop_" .. nx_string(i)
    local btn_name = "btn_delate_" .. nx_string(i)
    local lbl = gbox:Find(nx_string(lbl_name))
    local lbl_prop = gbox:Find(nx_string(lbl_prop_name))
    local btn = gbox:Find(nx_string(btn_name))
    if nx_is_valid(lbl) and nx_is_valid(lbl_prop) and nx_is_valid(btn) then
      lbl.Text = nx_widestr("")
      lbl_prop.BackImage = ""
      if nx_find_custom(btn, "TaoLuID") then
        btn.TaoLuID = nx_string("")
      end
      btn.Visible = false
    end
  end
end
function get_neigong_and_jingmai_devation(nProp, strWuXue)
  if strWuXue == nil or strWuXue == "" then
    return 0, 0
  end
  if nx_int(nProp) < nx_int(1) or nx_int(nProp) > nx_int(3) then
    return 0, 0
  end
  local ini = nx_null()
  if nx_int(nProp) == nx_int(1) then
    ini = nx_execute("util_functions", "get_ini", baseskill_file)
  elseif nx_int(nProp) == nx_int(2) then
    ini = nx_execute("util_functions", "get_ini", uniquekill_file)
  elseif nx_int(nProp) == nx_int(3) then
    ini = nx_execute("util_functions", "get_ini", luandoukill_file)
  end
  if not nx_is_valid(ini) then
    return 0, 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(strWuXue))
  if sec_index < 0 then
    return 0, 0
  end
  local neigong_deviation = ini:ReadInteger(sec_index, "deviation_neigong", 0)
  local jingmai_deviation = ini:ReadInteger(sec_index, "deviation_jingmai", 0)
  return neigong_deviation, jingmai_deviation
end
function get_skill_type(strWuXue)
  if strWuXue == nil or strWuXue == "" then
    return -1
  end
  local ini = nx_execute("util_functions", "get_ini", luandoukill_type)
  if not nx_is_valid(ini) then
    return -1
  end
  local sec_count = ini:FindSectionIndex(strWuXue)
  if sec_count < 0 then
    return -1
  end
  local nType = ini:ReadInteger(sec_count, "color", -1)
  return nType
end
function clear_all_select_jm(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, TOTAL_CHANNELS_NUM do
    local gbox_name = "groupbox_jingmai_" .. nx_string(i)
    local gbox = form.groupscrollbox_jingmai_mod:Find(nx_string(gbox_name))
    if nx_is_valid(gbox) then
      local cbtn_name = "cbtn_jm_" .. nx_string(i)
      cbtn = gbox:Find(nx_string(cbtn_name))
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
end
function get_confirm_text(form, text_type)
  local text = nx_widestr("")
  if not nx_is_valid(form) then
    return text
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return text
  end
  if nx_int(text_type) == nx_int(1) then
    gui.TextManager:Format_SetIDName("ui_choswar_interface_006")
  elseif nx_int(text_type) == nx_int(2) then
    gui.TextManager:Format_SetIDName("ui_choswar_interface_007")
  elseif nx_int(text_type) == nx_int(3) then
    gui.TextManager:Format_SetIDName("ui_choswar_interface_008")
  else
    return text
  end
  get_confirm_argument_num(form, text_type)
  for i = 1, #conform_argument_list do
    gui.TextManager:Format_AddParam(nx_widestr(conform_argument_list[i]))
  end
  text = gui.TextManager:Format_GetText()
  return text
end
function get_confirm_argument_num(form, index)
  conform_argument_list = {}
  if not nx_is_valid(form) then
    return
  end
  if math.mod(#player_own_skill_list, 2) ~= 0 then
    return
  end
  local skill_num = #player_own_skill_list / 2
  if nx_int(index) == nx_int(1) then
    for i = 1, #player_own_skill_list, 2 do
      local skill_id = nx_string(player_own_skill_list[i])
      local skill_prop = nx_int(player_own_skill_list[i + 1])
      local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(skill_prop, skill_id)
      table.insert(conform_argument_list, util_text("luandou_" .. skill_id))
      table.insert(conform_argument_list, util_text("desc_luandou_neigong_define_choose_" .. nx_string(neigong_wuxing)))
      table.insert(conform_argument_list, util_text("desc_luandou_jingmai_define_choose_" .. nx_string(jingmai_wuxing)))
    end
    local left_num = 2 - skill_num
    for j = 1, left_num do
      table.insert(conform_argument_list, util_text("ui_choswar_interface_009"))
      table.insert(conform_argument_list, util_text("ui_choswar_interface_005"))
      table.insert(conform_argument_list, util_text("ui_choswar_interface_005"))
    end
    local select_neigong_wuxing, select_jingmai_wuxing = get_neigong_and_jingmai_devation(form.prop, form.select_taolu_id)
    table.insert(conform_argument_list, util_text(nx_string("luandou_" .. form.select_taolu_id)))
    table.insert(conform_argument_list, util_text("desc_luandou_neigong_define_choose_" .. nx_string(select_neigong_wuxing)))
    table.insert(conform_argument_list, util_text("desc_luandou_jingmai_define_choose_" .. nx_string(select_jingmai_wuxing)))
  elseif nx_int(index) == nx_int(2) then
    for i = 1, #player_own_skill_list, 2 do
      local skill_id = nx_string(player_own_skill_list[i])
      local skill_prop = nx_int(player_own_skill_list[i + 1])
      local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(skill_prop, skill_id)
      table.insert(conform_argument_list, util_text("luandou_" .. skill_id))
      table.insert(conform_argument_list, util_text("desc_luandou_jingmai_define_choose_" .. nx_string(jingmai_wuxing)))
    end
    local left_num = 3 - skill_num
    for j = 1, left_num do
      table.insert(conform_argument_list, util_text("ui_choswar_interface_009"))
      table.insert(conform_argument_list, util_text("ui_choswar_interface_005"))
    end
  elseif nx_int(index) == nx_int(3) then
    for i = 1, #player_own_skill_list, 2 do
      local skill_id = nx_string(player_own_skill_list[i])
      local skill_prop = nx_int(player_own_skill_list[i + 1])
      local neigong_wuxing, jingmai_wuxing = get_neigong_and_jingmai_devation(skill_prop, skill_id)
      table.insert(conform_argument_list, util_text("luandou_" .. skill_id))
      table.insert(conform_argument_list, util_text("desc_luandou_neigong_define_choose_" .. nx_string(neigong_wuxing)))
    end
    local left_num = 3 - skill_num
    for j = 1, left_num do
      table.insert(conform_argument_list, util_text("ui_choswar_interface_009"))
      table.insert(conform_argument_list, util_text("ui_choswar_interface_005"))
    end
  end
end
function a(d)
  nx_msgbox(nx_string(d))
end
