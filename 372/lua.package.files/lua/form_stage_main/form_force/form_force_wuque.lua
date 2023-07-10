require("util_functions")
require("util_gui")
require("role_composite")
require("share\\client_custom_define")
require("custom_sender")
require("form_stage_main\\form_scene_compete\\util_scene_compete_define")
local form_name = "form_stage_main\\form_force\\form_force_wuque"
local ui_can_buy_state = {
  [1] = "ui_yhd",
  [2] = "ui_kjg",
  [3] = "ui_bkhd"
}
local RaceState_Stop = 0
local RaceState_Invite = 1
local RaceState_JingPai = 2
local RaceState_RaceReady = 3
local RaceState_WuDou1 = 4
local RaceState_WuDou2 = 5
local RaceState_WuDouEnd = 6
local RaceState_WenDou1 = 7
local RaceState_WenDou2 = 8
local RaceState_WenDou3 = 9
local RaceState_WaitResult = 10
local RaceState_RaceEnd = 11
function main_form_init(form)
  form.Fixed = false
  form.arrayList_players = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.rbtn_top_1.Checked = true
  form.rbtn_1.Checked = true
  init_rbtn_player_index(form)
  if not nx_is_valid(form.arrayList_players) then
    form.arrayList_players = get_global_arraylist("form_wuque_list_players")
  end
  ui_ClearModel(form.scenebox_2)
  form.scenebox_2.Transparent = true
  if not nx_is_valid(form.scenebox_2.Scene) then
    util_addscene_to_scenebox(form.scenebox_2)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_HUAWUQUE_RACE), nx_int(3))
end
function on_main_form_close(form)
  if nx_is_valid(form.arrayList_players) then
    nx_destroy(form.arrayList_players)
  end
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_1_click(btn)
  util_show_form("form_stage_main\\form_rank\\form_rank_main", true)
end
function on_btn_see_click(btn)
  nx_execute("custom_sender", "custom_send_scene_compete_msg", OP_SCENE_COMPETE_REQUESTDLG)
end
function on_rbtn_top_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_1.Visible = rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
    form.groupbox_hzqj.Visible = not rbtn.Checked
    form.groupbox_hgrw.Visible = not rbtn.Checked
    form.rbtn_1.Checked = true
  end
end
function on_rbtn_top_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_1.Visible = not rbtn.Checked
    form.groupbox_hgrw.Visible = rbtn.Checked
    form.groupbox_hzqj.Visible = not rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
    form.rbtn_hgrw_1.Checked = true
    form.rbtn_hgrw_4.Enabled = false
    if form.state == 1 then
      form.rbtn_hgrw_4.Enabled = true
    end
  end
end
function on_rbtn_top_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_1.Visible = not rbtn.Checked
    form.groupbox_hgrw.Visible = not rbtn.Checked
    form.groupbox_hzqj.Visible = rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
    form.rbtn_hzqj_1.Checked = true
    form.rbtn_hzqj_4.Enabled = false
    if form.state == 2 then
      form.rbtn_hzqj_4.Enabled = true
    end
  end
end
function on_rbtn_top_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_gycj.Visible = rbtn.Checked
    form.groupbox_jxrw.Visible = not rbtn.Checked
    form.groupbox_gzzg.Visible = not rbtn.Checked
    form.groupbox_bsym.Visible = not rbtn.Checked
    form.groupbox_hgdz.Visible = not rbtn.Checked
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_gycj.Visible = not rbtn.Checked
    form.groupbox_jxrw.Visible = rbtn.Checked
    form.groupbox_gzzg.Visible = not rbtn.Checked
    form.groupbox_bsym.Visible = not rbtn.Checked
    form.groupbox_hgdz.Visible = not rbtn.Checked
  end
end
function on_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_gycj.Visible = not rbtn.Checked
    form.groupbox_jxrw.Visible = not rbtn.Checked
    form.groupbox_gzzg.Visible = rbtn.Checked
    form.groupbox_bsym.Visible = not rbtn.Checked
    form.groupbox_hgdz.Visible = not rbtn.Checked
  end
end
function on_rbtn_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_gycj.Visible = not rbtn.Checked
    form.groupbox_jxrw.Visible = not rbtn.Checked
    form.groupbox_gzzg.Visible = not rbtn.Checked
    form.groupbox_bsym.Visible = rbtn.Checked
    form.groupbox_hgdz.Visible = not rbtn.Checked
  end
end
function on_rbtn_5_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_gycj.Visible = not rbtn.Checked
    form.groupbox_jxrw.Visible = not rbtn.Checked
    form.groupbox_gzzg.Visible = not rbtn.Checked
    form.groupbox_bsym.Visible = not rbtn.Checked
    form.groupbox_hgdz.Visible = rbtn.Checked
  end
end
function on_rbtn_hgrw_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hgrw_1.Visible = rbtn.Checked
    form.groupbox_hgrw_2.Visible = not rbtn.Checked
    form.groupbox_hgrw_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hgrw_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hgrw_1.Visible = not rbtn.Checked
    form.groupbox_hgrw_2.Visible = rbtn.Checked
    form.groupbox_hgrw_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hgrw_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hgrw_1.Visible = not rbtn.Checked
    form.groupbox_hgrw_2.Visible = not rbtn.Checked
    form.groupbox_hgrw_3.Visible = rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hgrw_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hgrw_1.Visible = not rbtn.Checked
    form.groupbox_hgrw_2.Visible = not rbtn.Checked
    form.groupbox_hgrw_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = rbtn.Checked
    form.btn_see.Visible = not rbtn.Checked
    clear_player_info(form)
    cancel_cbtn_player_checked(form)
    form.cbtn_player_1.Checked = true
  end
end
function on_rbtn_hzqj_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hzqj_1.Visible = rbtn.Checked
    form.groupbox_hzqj_2.Visible = not rbtn.Checked
    form.groupbox_hzqj_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hzqj_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hzqj_1.Visible = not rbtn.Checked
    form.groupbox_hzqj_2.Visible = rbtn.Checked
    form.groupbox_hzqj_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hzqj_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hzqj_1.Visible = not rbtn.Checked
    form.groupbox_hzqj_2.Visible = not rbtn.Checked
    form.groupbox_hzqj_3.Visible = rbtn.Checked
    form.groupbox_2.Visible = not rbtn.Checked
  end
end
function on_rbtn_hzqj_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if rbtn.Checked == true then
    form.groupbox_hzqj_1.Visible = not rbtn.Checked
    form.groupbox_hzqj_2.Visible = not rbtn.Checked
    form.groupbox_hzqj_3.Visible = not rbtn.Checked
    form.groupbox_2.Visible = rbtn.Checked
    form.btn_see.Visible = rbtn.Checked
    clear_player_info(form)
    cancel_cbtn_player_checked(form)
    form.cbtn_player_1.Checked = true
  end
end
function on_cbtn_player_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cbtn.Checked == true then
    cancel_cbtn_player_checked(cbtn.ParentForm, cbtn.index)
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_2)
    if not nx_is_valid(form.scenebox_2.Scene) then
      nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_2)
    end
    local groupbox_player = form.groupbox_2:Find("groupbox_player_" .. nx_string(cbtn.index))
    if not nx_is_valid(groupbox_player) then
      return
    end
    local lbl_name = groupbox_player:Find("lbl_name_" .. nx_string(cbtn.index))
    if not nx_is_valid(lbl_name) then
      return
    end
    local name = lbl_name.Text
    local child_player = get_child_obj(form.arrayList_players, nx_string(name), false)
    if not nx_is_valid(child_player) then
      return
    end
    local role_info_data = child_player:GetChild("role_info")
    if nx_is_valid(role_info_data) then
      add_player_model(form.scenebox_2, role_info_data)
      change_action(form.scenebox_2, "huashan010")
    end
    if form.rbtn_top_2.Checked == true then
      form.lbl_xiuqiu.Text = nx_widestr(child_player.xiuqiu_num1)
    elseif form.rbtn_top_3.Checked == true then
      form.lbl_xiuqiu.Text = nx_widestr(child_player.xiuqiu_num2)
    end
  end
end
function open_form()
  util_show_form(form_name, true)
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", form_name, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_groupbox_1(form, ...)
  update_textgrid(form, 1)
  form.lbl_2.Text = nx_widestr(util_text(nx_string(arg[1])))
  form.lbl_3.Text = nx_widestr(util_text(nx_string(arg[2])))
end
function update_textgrid(form, index)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local grid, ini_path
  if nx_int(index) == nx_int(1) then
    grid = form.textgrid_gycj
    ini_path = "ini\\ui\\force\\force_wuque_gycj.ini"
  elseif nx_int(index) == nx_int(2) then
    grid = form.textgrid_jxrw
    ini_path = "ini\\ui\\force\\force_wuque_jxrw.ini"
  elseif nx_int(index) == nx_int(3) then
    grid = form.textgrid_gzzg
    ini_path = "ini\\ui\\force\\force_wuque_gzzg.ini"
  end
  local ini = nx_execute("util_functions", "get_ini", ini_path)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex("col_top")
  if sec_index < 0 then
    return
  end
  grid:SetColTitle(0, util_text(ini:ReadString(sec_index, "col_top_1", "")))
  grid:SetColTitle(1, util_text(ini:ReadString(sec_index, "col_top_2", "")))
  grid:SetColTitle(2, util_text(ini:ReadString(sec_index, "col_top_3", "")))
  for i = 1, 99 do
    local sec_index = ini:FindSectionIndex("sort" .. nx_string(i))
    if sec_index < 0 then
      break
    end
    local name = ini:ReadString(sec_index, "col_1", "")
    local rule = ini:ReadString(sec_index, "col_2", "")
    local text = ini:ReadString(sec_index, "col_3", "")
    local row = grid:InsertRow(-1)
    grid:SetGridText(row, 0, nx_widestr(util_text(name)))
    grid:SetGridText(row, 1, nx_widestr(util_text(rule)))
    grid:SetGridText(row, 2, nx_widestr(util_text(text)))
  end
end
function update_player_info(i, name, school, power)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local groupbox = form.groupbox_2:Find("groupbox_player_" .. nx_string(i))
  if not nx_is_valid(groupbox) then
    return
  end
  local cbtn_str = "cbtn_player_" .. nx_string(i)
  local lbl_name_str = "lbl_name_" .. nx_string(i)
  local lbl_school_str = "lbl_school_" .. nx_string(i)
  local lbl_power_str = "lbl_power_" .. nx_string(i)
  local cbtn = groupbox:Find(cbtn_str)
  if nx_is_valid(cbtn) then
    cbtn.Enabled = true
  end
  local lbl_name = groupbox:Find(lbl_name_str)
  if nx_is_valid(lbl_name) then
    lbl_name.Text = nx_widestr(name)
  end
  local lbl_school = groupbox:Find(lbl_school_str)
  if nx_is_valid(lbl_school) then
    lbl_school.Text = nx_widestr(util_text(school))
  end
  local lbl_power = groupbox:Find(lbl_power_str)
  if nx_is_valid(lbl_power) then
    lbl_power.Text = nx_widestr(util_text(power))
  end
end
function cancel_cbtn_player_checked(form, index)
  for i = 1, 16 do
    if i ~= index then
      local groupbox_player = form.groupbox_2:Find("groupbox_player_" .. nx_string(i))
      if not nx_is_valid(groupbox_player) then
        return
      end
      local cbtn = groupbox_player:Find("cbtn_player_" .. nx_string(i))
      if not nx_is_valid(cbtn) then
        return
      end
      cbtn.Checked = false
    end
  end
end
function clear_player_info(form)
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_2)
  if not nx_is_valid(form.scenebox_2.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_2)
  end
  form.lbl_xiuqiu.Text = nx_widestr("")
end
function init_rbtn_player_index(form)
  form.cbtn_player_1.index = 1
  form.cbtn_player_2.index = 2
  form.cbtn_player_3.index = 3
  form.cbtn_player_4.index = 4
  form.cbtn_player_5.index = 5
  form.cbtn_player_6.index = 6
  form.cbtn_player_7.index = 7
  form.cbtn_player_8.index = 8
  form.cbtn_player_9.index = 9
  form.cbtn_player_10.index = 10
  form.cbtn_player_11.index = 11
  form.cbtn_player_12.index = 12
  form.cbtn_player_13.index = 13
  form.cbtn_player_14.index = 14
  form.cbtn_player_15.index = 15
  form.cbtn_player_16.index = 16
  form.cbtn_player_1.Enabled = flase
  form.cbtn_player_2.Enabled = flase
  form.cbtn_player_3.Enabled = flase
  form.cbtn_player_4.Enabled = flase
  form.cbtn_player_5.Enabled = flase
  form.cbtn_player_6.Enabled = flase
  form.cbtn_player_7.Enabled = flase
  form.cbtn_player_8.Enabled = flase
  form.cbtn_player_9.Enabled = flase
  form.cbtn_player_10.Enabled = flase
  form.cbtn_player_11.Enabled = flase
  form.cbtn_player_12.Enabled = flase
  form.cbtn_player_13.Enabled = flase
  form.cbtn_player_14.Enabled = flase
  form.cbtn_player_15.Enabled = flase
  form.cbtn_player_16.Enabled = flase
end
function on_server_msg(...)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local state_id = nx_int(arg[2])
  form.state = 0
  if nx_int(state_id) >= nx_int(RaceState_WuDou1) and nx_int(state_id) <= nx_int(RaceState_WuDouEnd) then
    form.state = 1
  elseif nx_int(state_id) >= nx_int(RaceState_WenDou1) and nx_int(state_id) <= nx_int(RaceState_WaitResult) then
    form.state = 2
  end
  update_groupbox_1(form, arg[3], ui_can_buy_state[nx_int(arg[4]) + 1])
  local player_table = util_split_string(arg[5], ";")
  if table.getn(player_table) == 0 then
    return
  end
  for i = 1, table.getn(player_table) do
    local player_info = util_split_string(player_table[i], ":")
    if table.getn(player_info) == 0 then
      clear_player_info(form)
    else
      local name = player_info[1]
      local child_player = get_child_obj(form.arrayList_players, nx_string(name), true)
      if not nx_is_valid(child_player) then
        return
      end
      if nx_string(player_info[2]) == nx_string("") then
        nx_set_custom(child_player, "School", "school_wulin")
      else
        nx_set_custom(child_player, "School", player_info[2])
      end
      nx_set_custom(child_player, "playername", name)
      nx_set_custom(child_player, "power", player_info[3])
      nx_set_custom(child_player, "roleinfo", player_info[4])
      nx_set_custom(child_player, "ruwei", player_info[5])
      nx_set_custom(child_player, "xiuqiu_num1", player_info[6])
      nx_set_custom(child_player, "xiuqiu_num2", player_info[7])
      child_player:CreateChild("role_info")
      local role_info_data = child_player:GetChild("role_info")
      if nx_is_valid(role_info_data) and not analysis_role_info(child_player.roleinfo, role_info_data) then
        child_player:RemoveChildByID(role_info_data)
      end
      if nx_is_valid(role_info_data) then
        update_player_info(i, name, child_player.School, "desc_" .. role_info_data.level_title)
      end
    end
  end
end
function change_action(scenebox, action)
  local scene = scenebox.Scene
  if not nx_is_valid(scene) then
    return
  end
  if not nx_find_custom(scene, "model") then
    return
  end
  local actor2 = scene.model
  if not nx_is_valid(actor2) then
    return
  end
  local action_module = nx_value("action_module")
  if not nx_is_valid(action_module) then
    return
  end
  local isExists = action_module:ActionExists(actor2, action)
  if not isExists then
    return
  end
  local is_in_list = action_module:ActionBlended(actor2, action)
  if not is_in_list then
    action_module:BlendAction(actor2, action, true, true)
  end
end
function add_player_model(scenebox, role_info_obj)
  if not nx_is_valid(scenebox) or not nx_is_valid(role_info_obj) then
    return false
  end
  local actor2 = create_role_composite(scenebox.Scene, true, role_info_obj.sex)
  if not nx_is_valid(actor2) then
    return false
  end
  while nx_is_valid(actor2) and nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  local skin_info = {
    [1] = {
      link_name = "mask",
      model_name = role_info_obj.mask
    },
    [2] = {
      link_name = "hat",
      model_name = role_info_obj.hat
    },
    [3] = {
      link_name = "cloth",
      model_name = role_info_obj.cloth
    },
    [4] = {
      link_name = "pants",
      model_name = role_info_obj.pants
    },
    [5] = {
      link_name = "shoes",
      model_name = role_info_obj.shoes
    },
    [6] = {
      link_name = "mantle",
      model_name = role_info_obj.mantle
    }
  }
  local effect_info = {
    [1] = {
      link_name = "WeaponEffect",
      model_name = role_info_obj.weaponeffect
    },
    [2] = {
      link_name = "MaskEffect",
      model_name = role_info_obj.maskeffect
    },
    [3] = {
      link_name = "HatEffect",
      model_name = role_info_obj.hateffect
    },
    [4] = {
      link_name = "ClothEffect",
      model_name = role_info_obj.clotheffect
    },
    [5] = {
      link_name = "PantsEffect",
      model_name = role_info_obj.pantseffect
    },
    [6] = {
      link_name = "ShoesEffect",
      model_name = role_info_obj.shoeseffect
    },
    [7] = {
      link_name = "MantleEffect",
      model_name = role_info_obj.mantleeffect
    }
  }
  for i, info in pairs(skin_info) do
    if 0 < string.len(nx_string(info.model_name)) then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  if nx_int(1) == nx_int(role_info_obj.show_equip_type) then
    link_skin(actor2, "cloth_h", nx_string(nx_string(role_info_obj.cloth) .. "_h" .. ".xmod"))
  end
  for i, info in pairs(effect_info) do
    if model_name ~= nil and model_name ~= null then
      link_effect(actor2, info.link_name, info.model_name)
    end
  end
  if role_info_obj.weapon ~= "" then
    actor2.weapon_name = role_info_obj.weapon
    refresh_weapon_position(actor2)
  end
  nx_execute("util_gui", "util_add_model_to_scenebox", scenebox, actor2)
  return true
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
function analysis_role_info(role_info, arraylist_obj)
  if "" == role_info or not nx_is_valid(arraylist_obj) then
    return false
  end
  local role_info_table = nx_function("ext_split_string", nx_string(role_info), ",")
  if table.getn(role_info_table) < 24 then
    return false
  end
  nx_set_custom(arraylist_obj, "sex", nx_number(role_info_table[1]))
  nx_set_custom(arraylist_obj, "face", role_info_table[6])
  local offset = get_offset(role_info_table)
  nx_set_custom(arraylist_obj, "show_equip_type", role_info_table[7 + offset])
  nx_set_custom(arraylist_obj, "hat", role_info_table[8 + offset])
  nx_set_custom(arraylist_obj, "mask", role_info_table[9 + offset])
  nx_set_custom(arraylist_obj, "cloth", role_info_table[10 + offset])
  nx_set_custom(arraylist_obj, "pants", role_info_table[11 + offset])
  nx_set_custom(arraylist_obj, "shoes", role_info_table[12 + offset])
  nx_set_custom(arraylist_obj, "weapon", role_info_table[13 + offset])
  nx_set_custom(arraylist_obj, "mantle", role_info_table[14 + offset])
  nx_set_custom(arraylist_obj, "hateffect", role_info_table[15 + offset])
  nx_set_custom(arraylist_obj, "maskeffect", role_info_table[16 + offset])
  nx_set_custom(arraylist_obj, "clotheffect", role_info_table[17 + offset])
  nx_set_custom(arraylist_obj, "pantseffect", role_info_table[18 + offset])
  nx_set_custom(arraylist_obj, "shoeseffect", role_info_table[19 + offset])
  nx_set_custom(arraylist_obj, "weaponeffect", role_info_table[20 + offset])
  nx_set_custom(arraylist_obj, "mantleeffect", role_info_table[21 + offset])
  nx_set_custom(arraylist_obj, "action_set", role_info_table[22 + offset])
  nx_set_custom(arraylist_obj, "level_title", role_info_table[24 + offset])
  return true
end
function get_offset(role_info_table)
  local face = role_info_table[6]
  local count = table.getn(role_info_table)
  local offset = 0
  for i = 7, count do
    if string.len(face) > 46 or string.len(face) == 46 then
      return offset
    end
    face = face .. string.char(44) .. role_info_table[i]
    offset = offset + 1
  end
  return offset
end
