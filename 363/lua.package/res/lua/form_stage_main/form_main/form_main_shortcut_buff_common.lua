require("define\\gamehand_type")
require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_static_data")
require("util_gui")
require("goods_grid")
require("player_state\\state_input")
require("tips_func_skill")
require("util_static_data")
require("define\\gamehand_type")
require("form_stage_main\\switch\\switch_define")
require("share\\itemtype_define")
local MAXGRIDSIZE = 10
local FORM_BUFF_SKILL = "form_stage_main\\form_main\\form_main_shortcut_buff_common"
function main_form_init(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  ini.FileName = account .. "\\shortcut.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  local left = ini:ReadInteger("shortcut_buff_common", "Left", 0)
  local top = ini:ReadInteger("shortcut_buff_common", "Top", 0)
  if left == 0 and top == 0 then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = gui.Desktop.Height - self.Height - shortcut_grid.groupbox_shortcut_1.Height
  else
    self.Left = left
    self.Top = top
  end
  nx_destroy(ini)
  self.isshortcut_grid = 1
  self.isitemskill_grid = 1
end
function on_main_form_close(form)
  form.isshortcut_grid = 1
  form.isitemskill_grid = 1
  form.isclose_shortgrid = -1
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  ini.FileName = account .. "\\shortcut.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  ini:WriteInteger("shortcut_buff_common", "Left", form.Left)
  ini:WriteInteger("shortcut_buff_common", "Top", form.Top)
  ini:SaveToFile()
  nx_destroy(ini)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
  end
end
function on_skill_change(grid, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  local viewobj = view:GetViewObj(nx_string(index))
  if not nx_is_valid(viewobj) then
    return
  end
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local configid = viewobj:QueryProp("ConfigID")
  for i = 0, grid.ClomnNum - 1 do
    local item = GoodsGrid:GetItemData(grid, i)
    if not nx_is_null(item) and nx_find_custom(item, "ConfigID") then
      local skillid = item.ConfigID
      if nx_string(skillid) == nx_string(viewobj:QueryProp("ConfigID")) then
        local canuse = viewobj:QueryProp("CanUse")
        if canuse == 0 or canuse == nil then
          grid:ChangeItemImageToBW(nx_int(i), true)
        else
          grid:ChangeItemImageToBW(nx_int(i), false)
        end
      end
    end
  end
end
function delay_show_form(form_main_shortcut_common_skillgrid, ...)
  if not nx_is_valid(form_main_shortcut_common_skillgrid) then
    return
  end
  local nCount = table.getn(arg)
  local grid = form_main_shortcut_common_skillgrid.imagegrid_1
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(grid)
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local skill_count = view:GetViewObjCount()
  local view_skill = game_client:GetView(nx_string(VIEWPORT_USING_BUFF_BOX))
  if not nx_is_valid(view_skill) then
    util_show_form(FORM_BUFF_SKILL, false)
    return
  end
  local is_close = view_skill:QueryProp("IsCloseOtherGrid")
  if nx_int(is_close) ~= nx_int(0) then
    form_main_shortcut_common_skillgrid.isclose_shortgrid = -1
  end
  if not view_skill:FindRecord("usingbuff_skillid") then
    util_show_form(FORM_BUFF_SKILL, false)
    return
  end
  local rows = view_skill:GetRecordRows("usingbuff_skillid")
  if rows <= 0 then
    util_show_form(FORM_BUFF_SKILL, false)
    return
  end
  local index = 0
  for i = 1, rows do
    local skill_id = view_skill:QueryRecord("usingbuff_skillid", i - 1, 0)
    for j = 1, skill_count do
      local skill = view:GetViewObjByIndex(j - 1)
      if nx_string(skill_id) == nx_string(skill:QueryProp("ConfigID")) then
        grid:SetBindIndex(i - 1, nx_int(skill.Ident))
        local prop_table = {}
        local proplist = skill:GetPropList()
        for i, prop in pairs(proplist) do
          prop_table[prop] = skill:QueryProp(prop)
        end
        prop_table.CoolDownCategory = skill_static_query_by_id(skill:QueryProp("ConfigID"), "CoolDownCategory")
        prop_table.CoolDownTeam = skill_static_query_by_id(skill:QueryProp("ConfigID"), "CoolDownTeam")
        local GoodsGrid = nx_value("GoodsGrid")
        if nx_is_valid(GoodsGrid) then
          local item_data = nx_create("ArrayList", nx_current())
          for prop, value in pairs(prop_table) do
            nx_set_custom(item_data, prop, value)
          end
          GoodsGrid:GridAddItem(grid, i - 1, item_data)
        end
        local canuse = skill:QueryProp("CanUse")
        if canuse == 0 or canuse == nil then
          grid:ChangeItemImageToBW(nx_int(i - 1), true)
        else
          grid:ChangeItemImageToBW(nx_int(i - 1), false)
        end
        index = index + 1
      end
    end
  end
  form_main_shortcut_common_skillgrid.imagegrid_1.Width = index * 48
  form_main_shortcut_common_skillgrid.lbl_s_back.Width = form_main_shortcut_common_skillgrid.imagegrid_1.Width + 70
  form_main_shortcut_common_skillgrid.gbox_skill.Width = form_main_shortcut_common_skillgrid.lbl_s_back.Width + 40
  form_main_shortcut_common_skillgrid.Width = form_main_shortcut_common_skillgrid.lbl_s_back.Width + 40
  if form_main_shortcut_common_skillgrid.isclose_shortgrid == 0 then
    local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
    local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
    if nx_is_valid(shortcut_grid) then
      if shortcut_grid.Visible == false then
        form_main_shortcut_common_skillgrid.isshortcut_grid = 0
      else
        shortcut_grid.Visible = false
      end
    end
    if nx_is_valid(itemskill_shortcut_grid) then
      if itemskill_shortcut_grid.Visible == false then
        form_main_shortcut_common_skillgrid.isitemskill_grid = 0
      else
        itemskill_shortcut_grid.Visible = false
      end
    end
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_main_shortcut_buff_common", true)
end
function on_show_skillgrid(...)
  local Isshow_other_grid = arg[1]
  local form_main_shortcut_common_skillgrid = util_get_form("form_stage_main\\form_main\\form_main_shortcut_buff_common", true)
  if not nx_is_valid(form_main_shortcut_common_skillgrid) then
    return
  end
  form_main_shortcut_common_skillgrid.isclose_shortgrid = Isshow_other_grid
  if nx_int(form_main_shortcut_common_skillgrid.isclose_shortgrid) ~= nx_int(0) then
    form_main_shortcut_common_skillgrid.isclose_shortgrid = -1
  end
  local stage_main_flag = nx_value("stage_main")
  local loading_flag = nx_value("loading")
  while loading_flag or nx_string(stage_main_flag) ~= nx_string("success") do
    nx_pause(0.5)
    stage_main_flag = nx_value("stage_main")
    loading_flag = nx_value("loading")
  end
  delay_show_form(form_main_shortcut_common_skillgrid, unpack(arg))
end
function refresh_shortcut_key()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  form.lbl_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index1))
  form.lbl_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index2))
  form.lbl_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index3))
  form.lbl_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index4))
  form.lbl_5.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index5))
  form.lbl_6.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index6))
  form.lbl_7.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index7))
  form.lbl_8.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index8))
  form.lbl_9.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index9))
  form.lbl_10.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index10))
end
function is_in_home()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CurHomeUID") then
    return false
  end
  local home_uid = player:QueryProp("CurHomeUID")
  return home_uid ~= nil and home_uid ~= ""
end
function on_close_common_skill_grid()
  local form_main_shortcut_common_skillgrid = util_get_form("form_stage_main\\form_main\\form_main_shortcut_buff_common", true)
  if not nx_is_valid(form_main_shortcut_common_skillgrid) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  if not is_in_home() then
    if nx_is_valid(shortcut_grid) then
      shortcut_grid.Visible = true
    end
    if nx_is_valid(itemskill_shortcut_grid) then
      itemskill_shortcut_grid.Visible = true
    end
  end
  form_main_shortcut_common_skillgrid.isclose_shortgrid = -1
  form_main_shortcut_common_skillgrid.imagegrid_1:Clear()
  form_main_shortcut_common_skillgrid:Close()
end
function on_select_changed(grid, index)
  on_rightclick_grid(grid, index)
end
function on_rightclick_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_SKILLITEM_BOX))
  if not nx_is_valid(view) then
    return
  end
  local skillident = grid:GetBindIndex(index)
  local skill = view:GetViewObj(nx_string(skillident))
  if not nx_is_valid(skill) then
    return
  end
  grid.right_click_itemskill = skill
  local skillid = skill:QueryProp("ConfigID")
  local static_data = nx_number(get_ini_value("share\\Skill\\skill_new.ini", skillid, "StaticData", "0"))
  local target_type = skill_static_query(static_data, "TargetType")
  if target_type == 1 then
    local fight = nx_value("fight")
    if not nx_is_valid(fight) then
      return
    end
    local replace_id = fight:GetReplayeSkillID(static_data)
    if replace_id == nil or replace_id == "" then
      replace_id = skillid
    end
    local cool_type = skill_static_query(static_data, "CoolDownCategory")
    form.skillid = skillid
    show_circle_select(nx_string(replace_id), cool_type)
  else
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_ITEMSKILL), nx_string(skillid))
    end
  end
end
function show_circle_select(skill_id, cool_type)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local is_cool = gui.CoolManager:IsCooling(nx_int(cool_type), nx_int(-1))
  if is_cool then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("8029"), 2)
    end
    return
  end
  gui.GameHand.wait_buff_skill = 1
  local skill_query = nx_value("SkillQuery")
  if nx_is_valid(skill_query) then
    skill_type = skill_query:GetSkillType(skill_id)
  end
  local varprop_paht = "share\\Skill\\skill_lock_varprop.ini"
  if nx_number(skill_type) == 1 then
    varprop_paht = "share\\Skill\\skill_normal_varprop.ini"
  end
  local static_data = nx_int(get_ini_value("share\\Skill\\skill_new.ini", skill_id, "StaticData", "0"))
  local var_pkg = nx_number(skill_static_query(static_data, "MinVarPropNo"))
  local hit_shape_pak = nx_int(get_ini_value(varprop_paht, nx_string(var_pkg), "HitShapePkg", "-1"))
  local target_shape_pak = nx_int(get_ini_value(varprop_paht, nx_string(var_pkg), "TargetShapePkg", "-1"))
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local hit_shape = data_query:Query(STATIC_DATA_SKILL_HITSHAPE, nx_number(hit_shape_pak), "HitShapePara2")
  local target_shape = data_query:Query(STATIC_DATA_SKILL_TARGETSHAPE, nx_number(target_shape_pak), "TargetShapePara2")
  nx_execute("game_effect", "add_ground_pick_effect", hit_shape * 2, target_shape)
end
function use_circle_select_skill()
  local form = util_get_form("form_stage_main\\form_main\\form_main_shortcut_buff_common", false)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "skillid") then
    return
  end
  local skillid = form.skillid
  if skillid == nil or skillid == "" then
    return
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return
  end
  local game_visual = nx_value("game_visual")
  if nx_is_valid(game_visual) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_USE_ITEMSKILL), nx_string(skillid), decal.PosX, decal.PosY, decal.PosZ)
  end
end
function get_ini_value(ini_path, section, key, defaut)
  local ini = get_ini(ini_path, true)
  if not nx_is_valid(ini) then
    return defaut
  end
  local index = ini:FindSectionIndex(section)
  if index < 0 then
    return defaut
  end
  return ini:ReadString(index, key, defaut)
end
function on_mousein_grid(grid, index)
  local GoodsGrid = nx_value("GoodsGrid")
  if not nx_is_valid(GoodsGrid) then
    return
  end
  local item_data = GoodsGrid:GetItemData(grid, index)
  if not nx_is_valid(item_data) then
    return
  end
  nx_execute("tips_game", "show_goods_tip", item_data, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function shortcut_buff_common_view()
  local form_buff_common = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
  nx_execute("form_stage_main\\form_main\\form_main_shortcut_buff_common", "on_show_skillgrid", 0, "")
end
