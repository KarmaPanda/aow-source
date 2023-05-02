require("util_gui")
require("util_functions")
require("util_static_data")
require("share\\view_define")
require("define\\gamehand_type")
require("role_composite")
require("player_state\\state_const")
FORM_WUXUE_MAIN = "form_stage_main\\form_wuxue\\form_wuxue"
FORM_WUXUE_SKILL = "form_stage_main\\form_wuxue\\form_wuxue_skill"
FORM_WUXUE_NEIGONG = "form_stage_main\\form_wuxue\\form_wuxue_neigong"
FORM_WUXUE_QINGGONG = "form_stage_main\\form_wuxue\\form_wuxue_qinggong"
FORM_WUXUE_JINGMAI = "form_stage_main\\form_wuxue\\form_wuxue_jingmai"
FORM_WUXUE_ANQI = "form_stage_main\\form_wuxue\\form_wuxue_anqi"
FORM_WUXUE_ZHENFA = "form_stage_main\\form_wuxue\\form_wuxue_zhenfa"
FORM_WUXUE_HUIHAI = "form_stage_main\\form_wuxue\\form_wuxue_huihai"
FORM_WUXUE_EXT_FACULTY = "form_stage_main\\form_wuxue\\form_ext_faculty"
INI_FILE_JF_SKILL = "share\\Skill\\HuiHai\\huihai_skill.ini"
INI_FILE_ZHENFA = "share\\Skill\\zhenfa_map.ini"
INI_FILE_ZF_SKILL = "ini\\ui\\wuxue\\wuxue_zhenfa.ini"
INI_FILE_AQ_SHOUFA = "ini\\ui\\wuxue\\wuxue_anqi.ini"
INI_SKILL_NEW = "share\\Skill\\skill_new.ini"
INI_HUIHAI_POS = "share\\Skill\\HuiHai\\huihai_pos.ini"
INI_FILE_QG_GETDESC = "ini\\ui\\wuxue\\qinggong_text.ini"
INI_FILE_ZF_GETDESC = "ini\\ui\\wuxue\\zhenfa_text.ini"
INI_SHARE_WUJI = "share\\Skill\\JingMai\\wuji.ini"
INI_SHARE_WUJI_INFO = "share\\Skill\\JingMai\\wuji_info.ini"
INI_SHARE_WUJI_ACT = "share\\Skill\\JingMai\\wuji_activate.ini"
GRID_ANIMATION = "qinggongkuang"
DEFAULT_PHOTO = "icon\\skill\\jn_all.png"
JINGMAI_BACKIMAGE_DIR = "gui\\language\\ChineseS\\wuxue\\jingmai\\"
QINGGONG_BACKIMAGE_DIR = "gui\\language\\ChineseS\\wuxue\\qinggong\\"
JINGMAI_XUEWEI_OPEN = "gui\\special\\wuxue\\xwd_on.png"
JINGMAI_XUEWEI_CLOSE = "gui\\special\\wuxue\\xwd_off.png"
JINGMAI_XUEWEI_SELECT = "gui\\special\\wuxue\\xwd_down.png"
JINGMAI_XUEWEI_OPEN_R = "gui\\special\\wuxue\\xwd_on_r.png"
JINGMAI_XUEWEI_CLOSE_R = "gui\\special\\wuxue\\xwd_off_r.png"
JINGMAI_XUEWEI_SELECT_R = "gui\\special\\wuxue\\xwd_down_r.png"
JINGMAI_FACULTY_OPEN_Z_DOWN = "gui\\special\\wuxue\\zhengxiu_down.png"
JINGMAI_FACULTY_OPEN_Z_FORBID = "gui\\special\\wuxue\\zhengxiu_forbid.png"
JINGMAI_FACULTY_OPEN_Z_ON = "gui\\special\\wuxue\\zhengxiu_on.png"
JINGMAI_FACULTY_OPEN_Z_OUT = "gui\\special\\wuxue\\zhengxiu_out.png"
JINGMAI_FACULTY_OPEN_N_DOWN = "gui\\special\\wuxue\\nixiu_down.png"
JINGMAI_FACULTY_OPEN_N_FORBID = "gui\\special\\wuxue\\nixiu_forbid.png"
JINGMAI_FACULTY_OPEN_N_ON = "gui\\special\\wuxue\\nixiu_on.png"
JINGMAI_FACULTY_OPEN_N_OUT = "gui\\special\\wuxue\\nixiu_out.png"
JINGMAI_FACULTY_CLOSE_DOWN = "gui\\special\\wuxue\\stop_down.png"
JINGMAI_FACULTY_CLOSE_FORBID = "gui\\special\\wuxue\\stop_forbid.png"
JINGMAI_FACULTY_CLOSE_ON = "gui\\special\\wuxue\\stop_on.png"
JINGMAI_FACULTY_CLOSE_OUT = "gui\\special\\wuxue\\stop_out.png"
XUEWEI_CBTN_OPEN_Z = "gui\\language\\ChineseS\\wuxue\\chongkai.png"
XUEWEI_CBTN_OPEN_N = "gui\\language\\ChineseS\\wuxue\\chongkai_ni.png"
XUEWEI_CBTN_OPEN_ZN = "gui\\language\\ChineseS\\wuxue\\chongkai_all.png"
XUEWEI_CBTN_CLOSE = "gui\\language\\ChineseS\\wuxue\\fengbi.png"
NORMAL_ATTACK_ID = "normal_attack"
ANQI_ATTACK_ID = "normal_anqi_attack"
NEIGONG_ZUOWANGGONG = "ng_jh_001"
ANQI_ATTACK_SKILL = {
  "hw_normal_zl",
  "hw_normal_dw",
  "hw_normal_fd",
  "hw_normal_fb",
  "hw_normal_jk",
  "hw_normal_zl_sky",
  "hw_normal_dw_sky",
  "hw_normal_fd_sky",
  "hw_normal_fb_sky",
  "hw_normal_jk_sky"
}
TABLE_NAME_JINFA = "jinfa_rec"
TABLE_NAME_NG_JINFA = "JinFaRec"
TABLE_NAME_ACTIVE_QGSKILL = "ActiveQGSkillRec"
TABLE_NAME_ACTIVE_QGACTION = "ActiveQGActionRec"
TABLE_NAME_QINGGONG = "QingGongRec"
WUXUE_SHOW_SKILL = "xl_zs_state_01"
WUXUE_SHOW_QINGGONG = "xl_qg_state_01"
WUXUE_SHOW_ZHENFA = "zhenfa_wd_02_start"
WUXUE_SHOW_ANQI = "jn_lmsj_05_02"
WUXUE_NEIGONG = 1
WUXUE_SKILL = 2
WUXUE_QGSKILL = 3
WUXUE_ZHENFA = 4
WUXUE_ANQI = 5
WUXUE_JINGMAI = 6
WUXUE_HUIHAI = 7
XUEWEI_CLOSE = 1
XUEWEI_OPEN = 2
XUEWEI_ENTER = 3
XUEWEI_OUT = 4
JINGFA_TYPE_NONE = 0
JINGFA_TYPE_NUQI = 1
JINGFA_TYPE_DAZHAO = 2
JINGFA_TYPE_MAX = 3
WEAR_JINFA_PUTIN = 1
WEAR_JINFA_PUTOUT = 2
WEAR_JINFA_CLEAR = 3
HUIHAI_ACTIVE = 10
HUIHAI_RESET = 20
NEIGONG_JINFA_COUNT = 5
CALLBACK_WAIT_TIME = 1000
ITEM_BOX_COUNT = 20
NODE_TEXT_COUNT = 10
FORE_COLOR_NORMAL = "255,101,80,63"
FORE_COLOR_SELECT = "255,160,0,0"
UNKNOWN_NODE_NORMAL = "255,128,128,128"
UNKNOWN_NODE_SELECT = "255,163,137,100"
FACULTY_NO = 0
FACULTY_NORMAL = 1
FACULTY_ACTION = 2
WUXUE_FORM_TAB = {
  [WUXUE_NEIGONG] = FORM_WUXUE_NEIGONG,
  [WUXUE_SKILL] = FORM_WUXUE_SKILL,
  [WUXUE_QGSKILL] = FORM_WUXUE_QINGGONG,
  [WUXUE_ZHENFA] = FORM_WUXUE_ZHENFA,
  [WUXUE_ANQI] = FORM_WUXUE_ANQI,
  [WUXUE_JINGMAI] = FORM_WUXUE_JINGMAI,
  [WUXUE_HUIHAI] = FORM_WUXUE_HUIHAI
}
NODE_PROP = {
  [1] = {
    NodeBackImage = "gui\\special\\wuxue\\button\\rbtn1_out.png",
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn1_on.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn1_down.png",
    Font = "font_wuxue_title",
    ItemHeight = 33,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 3,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 5,
    TextOffsetY = 6
  },
  [2] = {
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn2_on.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn2_down.png",
    Font = "font_wuxue_title",
    ItemHeight = 30,
    NodeOffsetY = 0,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 15,
    TextOffsetY = 6
  }
}
NODE_PROP2 = {
  [1] = {
    NodeBackImage = "gui\\special\\wuxue\\button\\rbtn1_out_g.png",
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn1_on_g.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn1_down_g.png",
    Font = "font_text_title1",
    ItemHeight = 33,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 3,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 5,
    TextOffsetY = 6
  },
  [2] = {
    NodeFocusImage = "gui\\special\\wuxue\\button\\rbtn2_on_g.png",
    NodeSelectImage = "gui\\special\\wuxue\\button\\rbtn2_down_g.png",
    Font = "font_text_title1",
    ItemHeight = 30,
    NodeOffsetY = 0,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 5,
    TextOffsetX = 15,
    TextOffsetY = 6
  }
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function set_name_color(form, index, is_selected)
  if nx_number(index) < 1 or nx_number(index) > ITEM_BOX_COUNT then
    return 0
  end
  local gbox_item = form.gpsb_items:Find("gbox_item_" .. nx_string(index))
  if not nx_is_valid(gbox_item) then
    return 0
  end
  local lbl_name = gbox_item:Find("lbl_name_" .. nx_string(index))
  if not nx_is_valid(lbl_name) then
    return 0
  end
  local btn_select = gbox_item:Find("btn_select_" .. nx_string(index))
  if not nx_is_valid(btn_select) then
    return 0
  end
  if is_selected then
    lbl_name.ForeColor = nx_string(FORE_COLOR_SELECT)
    btn_select.BackImage = "gui\\special\\wuxue\\form_back\\bjk.png"
  else
    lbl_name.ForeColor = nx_string(FORE_COLOR_NORMAL)
    btn_select.BackImage = ""
  end
end
function set_node_prop2(node, index)
  if not nx_is_valid(node) then
    return 0
  end
  if 0 > nx_number(index) or nx_number(index) > table.getn(NODE_PROP2) then
    return 0
  end
  for prop_name, value in pairs(NODE_PROP2[nx_number(index)]) do
    nx_set_property(node, nx_string(prop_name), value)
  end
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
function create_skill_action(form)
  if not nx_is_valid(form.scenebox_show.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_show)
    local game_effect = nx_create("GameEffect")
    if nx_is_valid(game_effect) then
      nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox_show.Scene)
      form.scenebox_show.Scene.game_effect = game_effect
      form.scenebox_show.Data = game_effect
    end
  end
  if not nx_is_valid(form.scenebox_show.Scene) then
    return nil
  end
  local action = nx_value("action_module")
  if not nx_is_valid(action) then
    return nil
  end
  if not nx_find_custom(form, "Actor2") or not nx_is_valid(form.Actor2) then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    form.Actor2 = create_scene_obj_composite(form.scenebox_show.Scene, client_player, false)
    if not nx_is_valid(form.Actor2) then
      return nil
    end
    nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_show, form.Actor2)
    form.Actor2:SetAngle(0, math.pi * 130 / 180, 0)
    local camera = form.scenebox_show.Scene.camera
    if nx_is_valid(camera) then
      camera:SetAngle(math.pi * 18 / 180, 0, 0)
      camera:SetPosition(camera.PositionX, camera.PositionY + 1.9, camera.PositionZ - 0.8)
    end
    action:ActionInit(form.Actor2)
    action:BlendAction(form.Actor2, "stand", true, true)
  end
  if not nx_find_custom(form, "Actor2") or not nx_is_valid(form.Actor2) then
    return nil
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return nil
  end
  role_composite:UseWeapon(form.Actor2, "", 0, 108)
  action:ClearAction(form.Actor2)
  action:ClearState(form.Actor2)
  action:BlendAction(form.Actor2, "stand", true, true)
  return action
end
function show_item_action(form, wuxue_name, default_action, is_skill)
  if not nx_is_valid(form) or wuxue_name == nil or default_action == nil then
    return
  end
  local action = create_skill_action(form)
  if action == nil then
    return
  end
  local action_name
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\wuxue\\WuXueAction.ini")
  if nx_is_valid(ini) then
    local sec_index = ini:FindSectionIndex(nx_string(wuxue_name))
    if 0 <= sec_index then
      action_name = ini:ReadString(sec_index, "action", default_action)
    end
  end
  if action_name == nil and is_skill ~= nil and is_skill == true then
    local skill_effect = nx_value("skill_effect")
    if not nx_is_valid(skill_effect) then
      return
    end
    skill_effect:BeginShowZhaoshi(form.Actor2, wuxue_name)
    return
  end
  if action_name ~= nil and action:BlendAction(form.Actor2, action_name, true, true) == true then
    return
  end
  action:BlendAction(form.Actor2, default_action, true, true)
end
function set_grid_data(grid, item, view_id)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return 0
  end
  if not nx_is_valid(grid) then
    return 0
  end
  if not nx_is_valid(item) then
    grid:SetBindIndex(0, nx_int(-1))
    grid.typeid = ""
    grid.canselect = false
    GoodsGrid:GridClear(grid)
    grid:AddItem(0, nx_string(DEFAULT_PHOTO), 0, 1, -1)
    grid:SetItemMark(0, nx_int(-1))
  else
    grid:SetBindIndex(0, nx_int(item.Ident))
    grid.typeid = view_id
    grid.canselect = true
    local prop_table = {}
    local proplist = item:GetPropList()
    for i, prop in pairs(proplist) do
      prop_table[prop] = item:QueryProp(prop)
    end
    if nx_is_valid(GoodsGrid) then
      local item_data = nx_create("ArrayList", nx_current())
      for prop, value in pairs(prop_table) do
        nx_set_custom(item_data, prop, value)
      end
      GoodsGrid:GridAddItem(grid, 0, item_data)
    end
    local static_data = item:QueryProp("StaticData")
    local effect_type = nx_execute("util_static_data", "skill_static_query", static_data, "EffectType")
    grid:SetItemMark(0, nx_int(effect_type))
    local is_item_skill = nx_execute("util_static_data", "skill_static_query", static_data, "IsCustomItemSkill")
    if nx_number(is_item_skill) == 1 then
      grid.canselect = false
    end
  end
end
function auto_select_first(tree)
  local temp_node = tree.RootNode
  while nx_is_valid(temp_node) do
    local sub_node_tab = temp_node:GetNodeList()
    if table.getn(sub_node_tab) > 0 then
      temp_node.Expand = true
      temp_node = sub_node_tab[1]
    else
      tree.SelectNode = temp_node
      break
    end
  end
end
function select_type_node(form_index, type_name)
  local form = nx_value(WUXUE_FORM_TAB[nx_number(form_index)])
  if not nx_is_valid(form) then
    return false
  end
  local root = form.tree_types.RootNode
  if not nx_is_valid(root) then
    return false
  end
  local gui = nx_value("gui")
  local type_text = gui.TextManager:GetText(type_name)
  local type_node = root:FindNode(nx_widestr(type_text))
  if not nx_is_valid(type_node) then
    local node_tab = root:GetNodeList()
    for i = 1, table.getn(node_tab) do
      type_node = node_tab[i]:FindNode(nx_widestr(type_text))
      if nx_is_valid(type_node) then
        break
      end
    end
  end
  if not nx_is_valid(type_node) then
    return false
  end
  form.tree_types.SelectNode = type_node.ParentNode
  form.tree_types.SelectNode = type_node
  return true
end
function select_item_wuxue(form_index, item_name)
  local form = nx_value(WUXUE_FORM_TAB[nx_number(form_index)])
  if not nx_is_valid(form) then
    return false
  end
  for i = 1, ITEM_BOX_COUNT do
    local gbox_item = form.gpsb_items:Find(nx_string("gbox_item_" .. nx_string(i)))
    if not nx_is_valid(gbox_item) then
      return false
    end
    local btn_select = gbox_item:Find(nx_string("btn_select_" .. nx_string(i)))
    if not nx_is_valid(btn_select) then
      return false
    end
    if not nx_find_custom(btn_select, "item_name") then
      return false
    end
    if nx_string(btn_select.item_name) == nx_string(item_name) then
      nx_execute(WUXUE_FORM_TAB[nx_number(form_index)], "select_one_item", form, nx_number(i))
      break
    end
  end
  return true
end
function show_faculty_info(control, prop_name, wuxue_type)
  local gui = nx_value("gui")
  if not nx_find_custom(control, prop_name) then
    return 0
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local item_name = nx_custom(control, prop_name)
  if item_name == nil or nx_string(item_name) == "" then
    return 0
  end
  local item = get_wuxue_object(item_name, wuxue_type)
  if not nx_is_valid(item) then
    return 0
  end
  local fillvalue_cur = item:QueryProp("CurFillValue")
  local fillvalue_all = item:QueryProp("TotalFillValue")
  local text = gui.TextManager:GetFormatText("8026")
  if nx_int(fillvalue_cur) < nx_int(fillvalue_all) then
    text = gui.TextManager:GetFormatText("ui_faculty_need", nx_int(fillvalue_all))
  end
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), control.AbsLeft, control.AbsTop, 150, control.ParentForm)
end
function show_faculty_level(form, item, item_id, wuxue_type)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  if nx_is_valid(item) then
    local level_is_max = check_wuxue_is_maxlevel(item, wuxue_type)
    local fillvalue_cur = item:QueryProp("CurFillValue")
    local fillvalue_all = item:QueryProp("TotalFillValue")
    form.pbar_gate.Maximum = nx_int(fillvalue_all)
    form.pbar_gate.Value = nx_int(fillvalue_cur)
    if nx_int(fillvalue_all) == nx_int(fillvalue_cur) and nx_int(fillvalue_all) ~= nx_int(0) then
      form.lbl_gate_point.Visible = true
    else
      form.lbl_gate_point.Visible = false
    end
    form.btn_faculty.item_name = nx_string(item_id)
    form.btn_faculty.Enabled = not level_is_max
    form.btn_faculty.wuxue_type = wuxue_type
    if level_is_max then
      if nx_number(item:QueryProp("Level")) > 1 then
        form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_max")
      else
        form.lbl_level.Text = nx_widestr("")
      end
      form.gbox_faculty.Visible = false
      form.lbl_faculty_back.Visible = true
    else
      form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_" .. item:QueryProp("Level"))
      form.gbox_faculty.Visible = true
      form.lbl_faculty_back.Visible = false
    end
  else
    form.pbar_gate.Maximum = nx_int(100)
    form.pbar_gate.Value = nx_int(0)
    form.lbl_gate_point.Visible = false
    form.btn_faculty.Enabled = false
    form.btn_faculty.wuxue_type = nil
    form.gbox_faculty.Visible = false
    form.lbl_faculty_back.Visible = true
    form.lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_0")
  end
end
function show_wuxue_level(lbl_level, item, wuxue_type)
  local gui = nx_value("gui")
  if not nx_is_valid(lbl_level) then
    return 0
  end
  if nx_is_valid(item) then
    if check_wuxue_is_maxlevel(item, wuxue_type) then
      if nx_number(item:QueryProp("Level")) > 1 then
        lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_max")
      else
        lbl_level.Text = nx_widestr("")
      end
    else
      lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_" .. item:QueryProp("Level"))
    end
  else
    lbl_level.Text = gui.TextManager:GetText("ui_wuxue_level_0")
  end
end
function add_weapon(form, skill_name)
  if not nx_is_valid(form) or skill_name == nil then
    return false
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  local actor2 = form.Actor2
  if not nx_is_valid(actor2) then
    return false
  end
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  end
  local LimitIndex = nx_execute("tips_data", "get_ini_prop", INI_SKILL_NEW, skill_name, "UseLimit", "")
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
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  local weapon_name = nx_string(get_weapon_name(ItemType))
  local taolu = nx_execute("util_static_data", "skill_static_query_by_id", skill_name, "TaoLu")
  if nx_string(taolu) == "CS_th_bhcs" then
    weapon_name = "flute_thd_002"
  end
  game_visual:SetRoleWeaponName(actor2, nx_string(weapon_name))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) and nx_int(set_index) <= nx_int(8) or nx_int(set_index) >= nx_int(22) and nx_int(set_index) <= nx_int(25) then
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
function add_zhenfa_weapon(form, skill_name)
  if not nx_is_valid(form) or skill_name == nil then
    return false
  end
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  skill = wuxue_query:GetLearnID_ZhenFa(skill_name)
  if not nx_is_valid(skill) then
    return false
  end
  local actor2 = form.Actor2
  if not nx_is_valid(actor2) then
    return false
  end
  if nx_find_custom(actor2, "wuxue_book_set") then
    actor2.wuxue_book_set = nil
  end
  local ItemType = zhenfa_static_query(skill:QueryProp("StaticData"), "NeedWeapon")
  if ItemType == nil or nx_int(ItemType) == nx_int(0) then
    return false
  end
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return false
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleWeaponName(actor2, nx_string(get_weapon_name(ItemType)))
  local set_index = nx_int(ItemType) - 100
  if nx_int(set_index) >= nx_int(1) and nx_int(set_index) <= nx_int(8) or nx_int(set_index) >= nx_int(22) and nx_int(set_index) <= nx_int(25) then
    local action_set = nx_string(set_index) .. "h"
    nx_set_custom(actor2, "wuxue_book_set", action_set)
    role_composite:UseWeapon(actor2, game_visual:QueryRoleWeaponName(actor2), "hand", nx_int(ItemType))
    game_visual:SetRoleLogicState(actor2, 1)
    return true
  end
  return false
end
function get_weapon_name(item_type)
  if item_type == nil then
    return nil
  end
  if nx_int(item_type) == nx_int(101) then
    return "blade_0004"
  elseif nx_int(item_type) == nx_int(102) then
    return "sword_0004"
  elseif nx_int(item_type) == nx_int(103) then
    return "thorn_0004"
  elseif nx_int(item_type) == nx_int(104) then
    return "sblade_0004"
  elseif nx_int(item_type) == nx_int(105) then
    return "ssword_0004"
  elseif nx_int(item_type) == nx_int(106) then
    return "sthorn_0004"
  elseif nx_int(item_type) == nx_int(107) then
    return "lstuff_0004"
  elseif nx_int(item_type) == nx_int(108) then
    return "cosh_00033"
  elseif nx_int(item_type) == nx_int(122) then
    return "claymore_00022"
  elseif nx_int(item_type) == nx_int(123) then
    return "katar_0003"
  elseif nx_int(item_type) == nx_int(124) then
    return "pen_0004"
  elseif nx_int(item_type) == nx_int(125) then
    return "fan_0006"
  elseif nx_int(item_type) == nx_int(126) then
    return "zither_0002"
  elseif nx_int(item_type) == nx_int(127) then
    return "bow_0001"
  end
  return nil
end
function wuxue_faculty_flash()
  open_wuxue_sub_page(WUXUE_NEIGONG, NEIGONG_ZUOWANGGONG)
  local form = nx_value(FORM_WUXUE_NEIGONG)
  if nx_is_valid(form) then
    form.btn_flash.Visible = true
  end
end
function get_player_prop(prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(nx_string(prop_name)) then
    return ""
  end
  return client_player:QueryProp(nx_string(prop_name))
end
function get_type_by_wuxue_id(wuxue_id, wuxue_type)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return ""
  end
  local type_tab = wuxue_query:GetMainNames(wuxue_type)
  for i = 1, table.getn(type_tab) do
    local type_name = type_tab[i]
    if wuxue_type == WUXUE_ANQI or wuxue_type == WUXUE_QGSKILL then
      local item_tab = wuxue_query:GetItemNames(wuxue_type, type_name)
      for j = 1, table.getn(item_tab) do
        if nx_string(wuxue_id) == item_tab[j] then
          if wuxue_type == WUXUE_QGSKILL then
            if wuxue_query:CheckLearn_QingGong(type_name) then
              return type_name
            end
          else
            return type_name
          end
        end
      end
    else
      local sub_type_tab = wuxue_query:GetSubNames(wuxue_type, type_name)
      for j = 1, table.getn(sub_type_tab) do
        local sub_type_name = sub_type_tab[j]
        local item_tab = wuxue_query:GetItemNames(wuxue_type, sub_type_name)
        for k = 1, table.getn(item_tab) do
          if nx_string(wuxue_id) == item_tab[k] then
            if wuxue_type == WUXUE_JINGMAI or wuxue_type == WUXUE_ZHENFA then
              if nx_is_valid(get_wuxue_object(sub_type_name, wuxue_type)) then
                return sub_type_name
              end
            else
              return sub_type_name
            end
          end
        end
      end
    end
  end
  return ""
end
function get_wuxue_object(wuxue_id, wuxue_type)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return nil
  end
  local item
  if wuxue_type == WUXUE_SKILL then
    item = wuxue_query:GetLearnID_Skill(wuxue_id)
  elseif wuxue_type == WUXUE_QGSKILL then
    item = wuxue_query:GetLearnID_QGSkill(wuxue_id)
  elseif wuxue_type == WUXUE_ZHENFA then
    item = wuxue_query:GetLearnID_ZhenFa(wuxue_id)
  elseif wuxue_type == WUXUE_NEIGONG then
    item = wuxue_query:GetLearnID_NeiGong(wuxue_id)
  elseif wuxue_type == WUXUE_ANQI then
    item = wuxue_query:GetLearnID_ShouFa(wuxue_id)
  elseif wuxue_type == WUXUE_JINGMAI then
    item = wuxue_query:GetLearnID_JingMai(wuxue_id)
  end
  return item
end
function get_view_object(view_id, view_index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_id))
  if not nx_is_valid(view) then
    return nil
  end
  return view:GetViewObj(nx_string(view_index))
end
function get_maxlevel_by_conditions(item)
  if not nx_is_valid(item) then
    return 0
  end
  local maxLevel = item:QueryProp("MaxLevel")
  if nx_int(maxLevel) <= nx_int(0) then
    return 0
  end
  local wuxue_id = item:QueryProp("ConfigID")
  if wuxue_id == nil or nx_string(wuxue_id) == "" then
    return 0
  end
  local faculty_query = nx_value("faculty_query")
  if not nx_is_valid(faculty_query) then
    return 0
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return
  end
  for i = 1, maxLevel do
    local condition_id = faculty_query:GetFillCondID(wuxue_id, nx_int(i))
    if condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(condition_id)) == false then
      return i
    end
  end
  return maxLevel
end
function get_wuji_name_by_index(ini, wuji_index)
  if not nx_is_valid(ini) then
    return ""
  end
  if wuji_index <= 0 then
    return ""
  end
  local learn_sec_index = ini:FindSectionIndex("wuji_learn")
  if learn_sec_index < 0 then
    return ""
  end
  local str_name = ini:ReadString(learn_sec_index, nx_string(wuji_index), "")
  local str_name_tab = util_split_string(nx_string(str_name), ",")
  local tab_count = table.getn(str_name_tab)
  if tab_count < 1 then
    return ""
  end
  local wuji_name = str_name_tab[1]
  return wuji_name
end
function get_wuji_wear_type_by_index(ini, wuji_index)
  if not nx_is_valid(ini) then
    return 0
  end
  if 0 >= nx_number(wuji_index) then
    return 0
  end
  local learn_sec_index = ini:FindSectionIndex("wuji_learn")
  if learn_sec_index < 0 then
    return 0
  end
  local str_name = ini:ReadString(learn_sec_index, nx_string(wuji_index), "")
  local str_name_tab = util_split_string(nx_string(str_name), ",")
  local tab_count = table.getn(str_name_tab)
  if tab_count < 2 then
    return 0
  end
  local wuji_type = nx_number(str_name_tab[2])
  local wear_sec_index = ini:FindSectionIndex("wuji_wear_type")
  if wear_sec_index < 0 then
    return 0
  end
  local wear_type = ini:ReadInteger(wear_sec_index, nx_string(wuji_type), 0)
  return wear_type
end
function load_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  free_all_sub_page(form)
  if not nx_find_custom(form, "subpage_array") or not nx_is_valid(form.subpage_array) then
    form.subpage_array = nx_call("util_gui", "get_arraylist", "form_wuxue_subpage_array")
    form.subpage_array:ClearChild()
  end
  local new_wuxue_list = nx_value("new_wuxue_list")
  for i = 1, table.getn(WUXUE_FORM_TAB) do
    local sub_form = util_get_form(WUXUE_FORM_TAB[i], true, false)
    if nx_is_valid(new_wuxue_list) then
      local child = new_wuxue_list:GetChild(nx_string(WUXUE_FORM_TAB[i]))
      if nx_is_valid(child) then
        sub_form.type_name = child.type_name
        sub_form.item_name = child.item_name
        new_wuxue_list:RemoveChildByID(child)
      end
    end
    if form:Add(sub_form) then
      sub_form.Visible = false
      sub_form.Fixed = true
      sub_form.Top = 45
      sub_form.Left = 45
      local child = form.subpage_array:CreateChild(nx_string(i))
      if nx_is_valid(child) then
        child.form = sub_form
        child.rbtn = nx_custom(form, "rbtn_" .. nx_string(i))
      end
    end
  end
  return true
end
function free_all_sub_page(form)
  if not nx_is_valid(form) then
    return false
  end
  if not nx_find_custom(form, "subpage_array") then
    return true
  end
  if not nx_is_valid(form.subpage_array) then
    return true
  end
  local child_tab = form.subpage_array:GetChildList()
  for i = 1, table.getn(child_tab) do
    local child = child_tab[i]
    if nx_is_valid(child) and nx_is_valid(child.form) then
      child.form:Close()
    end
  end
  form.subpage_array:ClearChild()
  nx_destroy(form.subpage_array)
  return true
end
function switch_sub_page(form_index)
  local form = nx_value(FORM_WUXUE_MAIN)
  if not nx_is_valid(form) then
    return false
  end
  if nx_is_valid(form.faculty_form) then
    form.faculty_form.Visible = false
  end
  if nx_find_custom(form, "cur_index") and nx_number(form.cur_index) ~= nx_number(form_index) then
    local child = form.subpage_array:GetChild(nx_string(form.cur_index))
    if nx_is_valid(child) and nx_is_valid(child.form) then
      child.form.Visible = false
    end
  end
  local child = form.subpage_array:GetChild(nx_string(form_index))
  if not (nx_is_valid(child) and nx_is_valid(child.form)) or not nx_is_valid(child.rbtn) then
    return false
  end
  child.form.Visible = true
  child.rbtn.Enabled = false
  child.rbtn.Checked = true
  child.rbtn.ForeColor = FORE_COLOR_SELECT
  child.rbtn.Enabled = true
  form.cur_index = form_index
  local form_wuji_new = util_get_form("form_stage_main\\form_wuxue\\form_wuxue_wuji_new", false, false)
  if not nx_is_valid(form_wuji_new) then
    return
  end
  if nx_int(form_index) == nx_int(WUXUE_SKILL) then
    form.groupbox_1.Visible = true
    if form.rbtn_skill_1.Checked == true then
      form.lbl_bg_2.Visible = false
      if nx_execute("form_stage_main\\form_taosha\\taosha_util", "is_in_taosha_scene") or nx_execute("form_stage_main\\form_taosha\\apex_util", "is_in_apex_scene") or nx_execute("form_stage_main\\form_war_scuffle\\luandou_util", "is_in_luandou_scene") then
        form_wuji_new.Visible = false
      else
        form_wuji_new.Visible = true
      end
    else
      form.lbl_bg_2.Visible = true
      form_wuji_new.Visible = false
    end
  else
    form.groupbox_1.Visible = false
    form.lbl_bg_2.Visible = false
    form_wuji_new.Visible = false
  end
  return true
end
function set_radio_btns()
  local form = nx_value(FORM_WUXUE_MAIN)
  if not nx_is_valid(form) then
    return false
  end
  local top_base = 47
  local show_count = 0
  local child_tab = form.subpage_array:GetChildList()
  for i = 1, table.getn(child_tab) do
    local form = child_tab[i].form
    local rbtn = child_tab[i].rbtn
    if nx_is_valid(form) and nx_is_valid(rbtn) then
      if nx_is_valid(form.tree_types.RootNode) and 0 < form.tree_types.RootNode:GetNodeCount() then
        rbtn.Top = top_base + show_count * rbtn.Height
        show_count = show_count + 1
        rbtn.Visible = true
      else
        rbtn.Visible = false
      end
    end
  end
end
function set_form_pos(form)
  local gui = nx_value("gui")
  if nx_int(form.cur_index) == nx_int(WUXUE_JINGMAI) or nx_int(form.cur_index) == nx_int(WUXUE_SKILL) then
    form.AbsLeft = (gui.Width - form.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
  else
    form.AbsLeft = (gui.Width - form.Width + form.groupbox_wuji.Width) / 2
    form.AbsTop = (gui.Height - form.Height) / 2
  end
end
function hide_radio_btns()
  local form = nx_value(FORM_WUXUE_MAIN)
  if not nx_is_valid(form) then
    return false
  end
  local child_tab = form.subpage_array:GetChildList()
  for i = 1, table.getn(child_tab) do
    local form = child_tab[i].form
    local rbtn = child_tab[i].rbtn
    if nx_is_valid(form) and nx_is_valid(rbtn) then
      rbtn.Visible = false
    end
  end
end
function auto_show_hide_wuxue()
  local form = nx_value(FORM_WUXUE_MAIN)
  if nx_is_valid(form) and form.Visible then
    form:Close()
    return
  end
  util_auto_show_hide_form(FORM_WUXUE_MAIN)
  set_radio_btns()
  local neigong_form = nx_value(FORM_WUXUE_NEIGONG)
  if nx_is_valid(neigong_form) then
    neigong_form.btn_flash.Visible = false
  end
end
function auto_show_hide_ext_faculty()
  local form = nx_value(FORM_WUXUE_EXT_FACULTY)
  if nx_is_valid(form) and form.Visible then
    form:Close()
    return
  else
    util_get_form(FORM_WUXUE_EXT_FACULTY, true, false, "", true)
  end
  util_auto_show_hide_form(FORM_WUXUE_EXT_FACULTY)
  set_radio_btns()
  local neigong_form = nx_value(FORM_WUXUE_NEIGONG)
  if nx_is_valid(neigong_form) then
    neigong_form.btn_flash.Visible = false
  end
end
function open_wuxue_sub_page(form_index, type_name)
  local form = nx_value(FORM_WUXUE_MAIN)
  local gui = nx_value("gui")
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  else
    form = util_auto_show_hide_form(FORM_WUXUE_MAIN)
  end
  if not nx_is_valid(form) then
    return false
  end
  gui.Desktop:ToFront(form)
  set_radio_btns()
  if form_index ~= nil then
    switch_sub_page(form_index)
  end
  if type_name ~= nil then
    select_type_node(form_index, type_name)
  end
  return true
end
function save_new_wuxue(wuxue_id, wuxue_type)
  local type_name = ""
  local item_name = ""
  local form_name = ""
  change_wuxue_btn(true)
  if wuxue_type == "NeiGong" then
    type_name = wuxue_id
    form_name = FORM_WUXUE_NEIGONG
  elseif wuxue_type == "Skill" then
    item_name = wuxue_id
    form_name = FORM_WUXUE_SKILL
    item_name = modify_anqi_attack_id(item_name)
    type_name = get_type_by_wuxue_id(item_name, WUXUE_SKILL)
    if type_name == "" then
      form_name = FORM_WUXUE_ZHENFA
      type_name = get_type_by_wuxue_id(item_name, WUXUE_ZHENFA)
      if type_name == "" then
        return 0
      end
    end
  elseif wuxue_type == "QingGong" then
    type_name = wuxue_id
    form_name = FORM_WUXUE_QINGGONG
  elseif wuxue_type == "QGSkill" then
    item_name = wuxue_id
    form_name = FORM_WUXUE_QINGGONG
    type_name = get_type_by_wuxue_id(item_name, WUXUE_QGSKILL)
    if type_name == "" then
      return 0
    end
  elseif wuxue_type == "ShouFa" then
    item_name = wuxue_id
    type_name = get_type_by_wuxue_id(item_name, WUXUE_ANQI)
    if type_name == "" then
      return 0
    end
    form_name = FORM_WUXUE_ANQI
  elseif wuxue_type == "ZhenFa" then
    type_name = wuxue_id
    form_name = FORM_WUXUE_ZHENFA
  elseif wuxue_type == "JingMai" then
    type_name = wuxue_id
    form_name = FORM_WUXUE_JINGMAI
  elseif wuxue_type == "XueWei" then
    item_name = wuxue_id
    type_name = get_type_by_wuxue_id(item_name, WUXUE_JINGMAI)
    if type_name == "" then
      return 0
    end
    form_name = FORM_WUXUE_JINGMAI
  elseif wuxue_type == "UpXueWei" then
    local form = util_get_form(FORM_WUXUE_JINGMAI, false)
    if nx_is_valid(form) then
      nx_execute(FORM_WUXUE_JINGMAI, "show_jingmai_data", form)
    end
    return 0
  end
  local new_wuxue_list = nx_call("util_gui", "get_global_arraylist", "new_wuxue_list")
  local child = new_wuxue_list:GetChild(nx_string(form_name))
  if not nx_is_valid(child) then
    child = new_wuxue_list:CreateChild(nx_string(form_name))
  end
  if nx_is_valid(child) then
    child.type_name = type_name
    child.item_name = item_name
  end
end
function change_wuxue_btn(flag)
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_shortcut) then
    return
  end
  if flag then
    form_shortcut.btn_4.NormalImage = "skill_t"
    form_shortcut.btn_4.FocusImage = "skill_t"
    form_shortcut.btn_4.PushImage = "skill_t"
  else
    form_shortcut.btn_4.NormalImage = "gui\\special\\btn_main\\btn_wuxue_out.png"
    form_shortcut.btn_4.FocusImage = "gui\\special\\btn_main\\btn_wuxue_on.png"
    form_shortcut.btn_4.PushImage = "gui\\special\\btn_main\\btn_wuxue_down.png"
  end
end
function show_wuxue_info(form, bshow)
  if not nx_is_valid(form) then
    return 0
  end
  if nx_find_custom(form, "cur_index") then
    local child = form.subpage_array:GetChild(nx_string(form.cur_index))
    if nx_is_valid(child) and nx_is_valid(child.form) then
      child.form.Visible = bshow
    end
  end
end
function check_is_curneigong(neigong_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindProp("CurNeiGong") then
    return false
  end
  return nx_string(neigong_id) == nx_string(client_player:QueryProp("CurNeiGong"))
end
function check_qgskill_is_avtive(qgskill_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not client_player:FindRecord(TABLE_NAME_ACTIVE_QGSKILL) and not client_player:FindRecord(TABLE_NAME_ACTIVE_QGACTION) then
    return false
  end
  local row = client_player:FindRecordRow(TABLE_NAME_ACTIVE_QGSKILL, 0, nx_string(qgskill_name))
  if nx_number(row) >= nx_number(0) then
    return true
  end
  row = client_player:FindRecordRow(TABLE_NAME_ACTIVE_QGACTION, 0, nx_string(qgskill_name))
  if nx_number(row) >= nx_number(0) then
    return true
  end
  return false
end
function check_shoufa_is_active(shoufa_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_EQUIP))
  if not nx_is_valid(view) then
    return false
  end
  local viewobj_list = view:GetViewObjList()
  for _, view_item in pairs(viewobj_list) do
    if nx_string(shoufa_id) == nx_string(view_item:QueryProp("NeedShouFa")) then
      return true
    end
  end
  return false
end
function get_learn_skill_count()
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILL))
  if not nx_is_valid(view) then
    return
  end
  local count = view:GetViewObjCount()
  return count
end
function check_taolu_is_learn(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
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
function check_anqi_is_learn(anqitype_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local item_tab = wuxue_query:GetItemNames(WUXUE_ANQI, nx_string(anqitype_name))
  for i = 1, table.getn(item_tab) do
    local shoufa = wuxue_query:GetLearnID_ShouFa(item_tab[i])
    if nx_is_valid(shoufa) then
      return true
    end
  end
  return false
end
function check_wuxue_is_maxlevel(item, wuxue_type)
  if not nx_is_valid(item) then
    return false
  end
  local curLevel = item:QueryProp("Level")
  local maxLevel = item:QueryProp("MaxLevel")
  return nx_int(curLevel) == nx_int(maxLevel)
end
function check_anqi_normal_skill_is_learn()
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return false
  end
  for i = 1, table.getn(ANQI_ATTACK_SKILL) do
    local skill = wuxue_query:GetLearnID_Skill(ANQI_ATTACK_SKILL[i])
    if nx_is_valid(skill) then
      return true
    end
  end
  return false
end
function modify_anqi_attack_id(skill_id)
  for i = 1, table.getn(ANQI_ATTACK_SKILL) do
    if nx_string(skill_id) == nx_string(ANQI_ATTACK_SKILL[i]) then
      return ANQI_ATTACK_ID
    end
  end
  return skill_id
end
function check_wuxue_is_faculty(wuxue_id)
  local faculty_name = get_player_prop("FacultyName")
  local faculty_style = get_player_prop("FacultyStyle")
  if nx_number(faculty_style) ~= FACULTY_NORMAL then
    return false
  end
  return nx_string(faculty_name) == nx_string(wuxue_id)
end
function check_wuxue_is_ext_faculty(wuxue_id)
  local faculty_name = get_player_prop("ExtFacultyName")
  return nx_string(faculty_name) == nx_string(wuxue_id)
end
function check_taolu_is_forget(taolu_name)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local skill_data_manager = nx_value("skill_data_manager")
  if not nx_is_valid(skill_data_manager) then
    return 0
  end
  local fight = nx_value("fight")
  if not nx_is_valid(fight) then
    return 0
  end
  local item_tab = wuxue_query:GetItemNames(WUXUE_SKILL, nx_string(taolu_name))
  for i = 1, table.getn(item_tab) do
    local item_name = item_tab[i]
    if item_name == NORMAL_ATTACK_ID then
      item_name = fight:GetNormalAttackSkillID()
    elseif item_name == ANQI_ATTACK_ID then
      item_name = fight:GetNormalAnqiAttackSkillID(false)
    end
    local result = skill_data_manager:CheckForgetSkill(item_name)
    if result == true then
      return true
    end
  end
  return false
end
function get_start_action(zhenfa_map)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_ZHENFA)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_map))
  if 0 <= index then
    return ini:ReadString(index, "start_action", "")
  end
  return ""
end
function get_state_action(zhenfa_map)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_ZHENFA)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_map))
  if 0 <= index then
    return ini:ReadString(index, "state_action", "")
  end
  return ""
end
function get_finish_action(zhenfa_map)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_ZHENFA)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_map))
  if 0 <= index then
    return ini:ReadString(index, "finish_action", "")
  end
  return ""
end
function get_failed_action(zhenfa_map)
  local ini = nx_call("util_functions", "get_ini", INI_FILE_ZHENFA)
  if not nx_is_valid(ini) then
    return ""
  end
  local index = ini:FindSectionIndex(nx_string(zhenfa_map))
  if 0 <= index then
    return ini:ReadString(index, "failed_action", "")
  end
  return ""
end
function on_useitem_neigong(neigong_id)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local neigong = wuxue_query:GetLearnID_NeiGong(neigong_id)
  if not nx_is_valid(neigong) then
    return 0
  end
  if check_is_curneigong(neigong_id) then
    return 0
  end
  nx_execute("custom_sender", "custom_use_neigong", nx_string(neigong_id))
  return 1
end
function on_useitem_qinggong(qgskill_id)
  local wuxue_query = nx_value("WuXueQuery")
  if not nx_is_valid(wuxue_query) then
    return 0
  end
  local qgskill = wuxue_query:GetLearnID_QGSkill(qgskill_id)
  if not nx_is_valid(qgskill) then
    return 0
  end
  nx_execute("custom_sender", "custom_use_qinggong", nx_string(qgskill_id))
  return 1
end
function on_useitem_zhenfa(zhenfa_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return 0
  end
  local state_index = game_visual:QueryRoleStateIndex(visual_player)
  if state_index == STATE_STATIC_INDEX then
    nx_execute("custom_sender", "custom_use_zhenfa", zhenfa_id)
  end
  return 1
end
function find_type_in_grid(wuxue_type, form_index, type_name, config_id)
  local main_form = nx_value(FORM_WUXUE_MAIN)
  if nx_is_valid(main_form) and nx_find_custom(main_form, "is_help") then
    nx_set_custom(main_form, "is_help", true)
  end
  if not open_wuxue_sub_page(form_index, nil) then
    return nil
  end
  local form = nx_value(wuxue_type)
  if not nx_is_valid(form) then
    return nil
  end
  if not nx_find_custom(form, "gpsb_items") then
    return nil
  end
  local grids = form.gpsb_items
  if not nx_find_custom(form, "tree_types") then
    return nil
  end
  local root_node = form.tree_types.RootNode
  if not nx_is_valid(root_node) then
    return nil
  end
  local sel_node = find_node(root_node, type_name)
  if not nx_is_valid(sel_node) then
    return nil
  else
    form.tree_types.SelectNode = sel_node
  end
  local child_list = grids:GetChildControlList()
  for i = 1, 10 do
    local gbox_item = grids:Find("gbox_item_" .. nx_string(i))
    if nx_is_valid(gbox_item) then
      local image_grid = gbox_item:Find("grid_photo_" .. nx_string(i))
      if nx_is_valid(image_grid) then
        local goods_grid = nx_value("GoodsGrid")
        if not nx_is_valid(goods_grid) then
          return nil
        end
        local item_data = goods_grid:GetItemData(image_grid, 0)
        local config = nx_execute("tips_data", "get_prop_in_item", item_data, "ConfigID")
        if config == config_id then
          local main_form = nx_value(FORM_WUXUE_MAIN)
          main_form.is_help = true
          return image_grid
        end
      end
    end
  end
  return nil
end
function find_node(root_node, type_name)
  local node_list = root_node:GetNodeList()
  for _, node in pairs(node_list) do
    local sel_node = find_node(node, type_name)
    if nx_is_valid(sel_node) then
      return sel_node
    end
    if nx_find_custom(node, "type_name") and node.type_name == type_name then
      return node
    end
  end
  return nil
end
function find_tips_ids(varpropno, ini_filename)
  local varpropini = nx_execute("util_functions", "get_ini", ini_filename)
  if not nx_is_valid(varpropini) then
    return nil, nil
  end
  varpropno = nx_string(varpropno)
  if not varpropini:FindSection(varpropno) then
    return nil, nil
  end
  local sec_index = varpropini:FindSectionIndex(varpropno)
  if sec_index < 0 then
    return nil, nil
  end
  local tips_id_rec = {}
  local pack_id_rec = {}
  local level = 0
  level = varpropini:ReadString(sec_index, "Level", "")
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@PropModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_proppack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@EquipModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_equippack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@SkillModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_skillpack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@BuffModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_buffpack_" .. nx_string(pack_id_rec[i]))
  end
  pack_id_rec = varpropini:GetItemValueList(sec_index, "@TaskModifyPackRec")
  for i = 1, table.getn(pack_id_rec) do
    table.insert(tips_id_rec, "tips_taskpack_" .. nx_string(pack_id_rec[i]))
  end
  return tips_id_rec, level
end
function get_wuji_helper_pos(skill_id)
  if not open_wuxue_sub_page(WUXUE_SKILL, nil) then
    return nil
  end
  local form = nx_value(FORM_WUXUE_SKILL)
  if not nx_is_valid(form) then
    return nil
  end
  if not nx_find_custom(form, "tree_types") then
    return nil
  end
  local root_node = form.tree_types.RootNode
  if not nx_is_valid(root_node) then
    return nil
  end
  local sel_node = find_node(root_node, skill_id)
  if not nx_is_valid(sel_node) then
    return nil
  else
    form.tree_types.SelectNode = sel_node
  end
  return form.btn_wuji_1
end
