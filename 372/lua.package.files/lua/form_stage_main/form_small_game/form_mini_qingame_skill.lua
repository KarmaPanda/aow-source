require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_gui")
require("tips_func_skill")
require("define\\shortcut_key_define")
local MAXQINSKILLSIZE = 10
local g_QinSkillPath = "form_stage_main\\form_small_game\\form_mini_qingame_skill"
function main_form_init(form)
  form.Fixed = true
  form.no_need_motion_alpha = true
  form.qinpuid = ""
  form.skillid_list = ""
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = gui.Height - form.Height
  for i = 1, 10 do
    form.imagegrid_skill:SetBindIndex(nx_int(i - 1), nx_int(i))
  end
  refresh_shortcut_key(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_imagegrid_skill_select_changed(grid, index)
  if not nx_is_valid(grid) then
    return
  end
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  local AllowControl = nx_execute("form_stage_main\\form_main\\form_main_buff", "IsAllowControl")
  if not AllowControl then
    return
  end
  local name = grid:GetItemName(index)
  if 0 == nx_ws_length(name) then
    return
  end
  nx_execute("custom_sender", "custom_qin_use_skill", nx_string(name))
end
function on_imagegrid_skill_mousein_grid(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  tips_manager.InShortcut = true
  local StaticData = nx_string(grid:GetItemAddText(index, nx_int(0)))
  local name = grid:GetItemName(index)
  if nx_string(name) == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = nx_string(name)
  item.ItemType = ITEMTYPE_ZHAOSHI
  item.StaticData = nx_number(StaticData)
  item.Level = 1
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_imagegrid_skill_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function open_mini_qingame_form(qinpuid)
  local qinpu = nx_string(qinpuid)
  if nx_string("") == qinpu then
    return false
  end
  local qinini = nx_execute("util_functions", "get_ini", "share\\Life\\Qin.ini")
  if not nx_is_valid(qinini) then
    return false
  end
  local index = qinini:FindSectionIndex(qinpuid)
  if index < 0 then
    return false
  end
  local skillid_list = qinini:ReadString(index, "QinSkillID", "")
  if "" == skillid_list then
    return false
  end
  local condition_id = qinini:ReadString(index, "ConditionID", "")
  if "" == condition_id then
    return false
  end
  local condition_mgr = nx_value("ConditionManager")
  if not nx_is_valid(condition_mgr) then
    return false
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if not condition_mgr:CanSatisfyCondition(client_player, client_player, nx_int(condition_id)) then
    return false
  end
  local form = util_show_form(g_QinSkillPath, true)
  if not nx_is_valid(form) then
    return false
  end
  form.qinpuid = qinpu
  form.skillid_list = skillid_list
  fresh_form(form)
  return true
end
function fresh_form(form)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_skill
  grid:Clear()
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    return
  end
  local skill_tmp_lst = util_split_string(form.skillid_list, ",")
  for i = 1, table.getn(skill_tmp_lst) do
    if skill_tmp_lst[i] == "" then
      table.remove(skill_tmp_lst, i)
    end
  end
  for i = 1, table.getn(skill_tmp_lst) do
    if skillini:FindSection(nx_string(skill_tmp_lst[i])) then
      local sec_index = skillini:FindSectionIndex(nx_string(skill_tmp_lst[i]))
      if 0 <= sec_index then
        local name = skillini:GetSectionByIndex(sec_index)
        local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
        local photo = skill_static_query(static_data, "Photo")
        local cooltype = skill_static_query(static_data, "CoolDownCategory")
        local coolteam = skill_static_query(static_data, "CoolDownTeam")
        grid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(name), 1, -1)
        grid:SetItemAddInfo(i - 1, nx_int(0), nx_widestr(nx_string(static_data)))
        if 0 < nx_number(cooltype) then
          grid:SetCoolType(nx_int(i - 1), nx_int(cooltype))
        end
        if 0 < nx_number(coolteam) then
          grid:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
        end
        grid:ChangeItemImageToBW(nx_int(i - 1), false)
      end
    end
  end
end
function refresh_shortcut_key(form)
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  form.lbl_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index1))
  form.lbl_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index2))
  form.lbl_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index3))
  form.lbl_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index4))
  form.lbl_5.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_MainShortcutGrid_Index5))
end
