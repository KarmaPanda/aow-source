require("util_static_data")
require("share\\client_custom_define")
require("goods_grid")
require("share\\view_define")
require("util_functions")
require("util_gui")
require("goods_grid")
require("player_state\\state_const")
require("tips_func_skill")
require("util_static_data")
require("define\\shortcut_key_define")
require("share\\itemtype_define")
require("define\\define")
local MAXGRIDSIZE = 8
local ITT_STEALIN_GET_INTELLIGENCE = 136
local ITT_STEALIN_SAVE_HOSTAGE = 137
local PIS_IN_GAME = 3
local normal_varprop_ini = "share\\Skill\\skill_normal_varprop.ini"
function main_form_init(self)
  self.Fixed = true
  self.no_need_motion_alpha = true
  self.cur_skill = ""
  return 1
end
function on_main_form_open(self)
  if is_jh_scene() then
    self.btn_bag.Visible = false
    self.btn_relive.Visible = false
    self.btn_task.Visible = false
    self.btn_team.Visible = false
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(shortcut_grid) then
    shortcut_grid.cantopen = true
  end
  refresh_form(self, "", "", nil)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("Mount", "string", self, nx_current(), "on_mount_change")
  end
end
function on_main_form_close(self)
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if nx_is_valid(shortcut_grid) then
    shortcut_grid.cantopen = false
  end
  nx_destroy(self)
end
function on_main_form_shut(self)
  if nx_is_valid(self.scenebox_mountmodel) then
    if nx_find_custom(self, "Actor2") and nx_is_valid(self.Actor2) then
      self.scenebox_mountmodel.Scene:Delete(self.Actor2)
    end
    nx_execute("scene", "delete_scene", self.scenebox_mountmodel.Scene)
  end
end
function refresh_ride_shotcut_pos()
end
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function refresh_form(form, skill_id_lst, photo, skillini)
  refresh_shortcut_key()
  local grid = form.imagegrid_1
  local GoodsGrid = nx_value("GoodsGrid")
  if nx_is_valid(GoodsGrid) then
    GoodsGrid:GridClear(grid)
  end
  if nx_string(photo) ~= "" then
    form.lbl_photo.Visible = false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local skill_tmp_lst = util_split_string(skill_id_lst, ",")
  for i = 1, table.getn(skill_tmp_lst) do
    if skill_tmp_lst[i] == "" then
      table.remove(skill_tmp_lst, i)
    end
  end
  if skillini == nil then
    return
  end
  for i = 1, table.getn(skill_tmp_lst) do
    if skillini:FindSection(nx_string(skill_tmp_lst[i])) then
      local sec_index = skillini:FindSectionIndex(nx_string(skill_tmp_lst[i]))
      if 0 <= sec_index then
        local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
        local name = skillini:GetSectionByIndex(sec_index)
        local photo = skill_static_query(static_data, "Photo")
        local cooltype = skill_static_query(static_data, "CoolDownCategory")
        local coolteam = skill_static_query(static_data, "CoolDownTeam")
        grid:AddItem(nx_int(i - 1), nx_string(photo), nx_widestr(name), nx_int(0), i)
        if 0 < nx_number(cooltype) then
          grid:SetCoolType(nx_int(i - 1), nx_int(cooltype))
        end
        if 0 < nx_number(coolteam) then
          grid:SetCoolTeam(nx_int(i - 1), nx_int(coolteam))
        end
        local canuse = skill_static_query(static_data, "CanUse")
        grid:ChangeItemImageToBW(nx_int(i - 1), false)
      end
    end
  end
end
function refresh_shortcut_key()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_ride")
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
function on_rightclick_grid(self, index)
  if not nx_is_valid(self) then
    return
  end
  local form = self.ParentForm
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
  local name = self:GetItemName(index)
  if 0 == nx_ws_length(name) then
    return
  end
  local target_type = get_skill_info(name, "TargetType")
  if target_type == 1 and "riding_wjd_huopao" ~= nx_string(name) then
    form.cur_skill = name
    show_circle_select(form, name)
    return
  end
  local game_visual = nx_value("game_visual")
  local player = game_visual:GetPlayer()
  local state_index = game_visual:QueryRoleStateIndex(player)
  if state_index == STATE_RIDE_WITH_OTHER then
    local game_visual = nx_value("game_visual")
    if nx_is_valid(game_visual) then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_MULTIRIDE_REQUEST), 0, nx_widestr(name))
    end
    return
  end
  if nx_string(name) == "riding_saddle" then
    local saddle_item = check_is_exist_saddle()
    if nx_is_valid(saddle_item) and 1 > saddle_item:QueryProp("LockStatus") then
      nx_execute("custom_sender", "custom_use_item", nx_number(VIEWPORT_TOOL), nx_number(saddle_item.Ident))
    end
  end
  if state_index == STATE_RIDE_INDEX or state_index == STATE_RIDE_STAY_INDEX or state_index == STATE_RIDE_SPURT_INDEX or nx_string(name) == "riding_kick_passenger" or nx_string(name) == "riding_yizhichan_01" then
    local scene = nx_value("game_scene")
    local game_control = scene.game_control
    if nx_is_valid(game_control) and game_control.DriveNpcMode == 2 and "riding_wjd_huopao" == nx_string(name) then
      local drivenpc = nx_value("DriveNpcMgr")
      if not nx_is_valid(drivenpc) then
        return
      end
      local pos = drivenpc:GetTargetPos()
      nx_execute("custom_sender", "custom_send_ride_skill", nx_string(name), nx_float(pos[2]), nx_float(pos[3]), nx_float(pos[4]))
      return
    end
    nx_execute("custom_sender", "custom_send_ride_skill", nx_string(name))
    return
  end
  if nx_string(name) == "riding_dismount" or nx_string(name) == "riding_dismount_diao" or nx_string(name) == "riding_wjd_01" then
    nx_execute("custom_sender", "custom_send_ride_skill", nx_string(name))
    return
  end
  local gui = nx_value("gui")
  local info = gui.TextManager:GetFormatText("1161")
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if nx_is_valid(SystemCenterInfo) then
    SystemCenterInfo:ShowSystemCenterInfo(info, 2)
  end
end
function on_select_changed(self, index)
  on_rightclick_grid(self, index)
end
function on_mousein_grid(grid, index)
  local tips_manager = nx_value("tips_manager")
  if not nx_is_valid(tips_manager) then
    return
  end
  tips_manager.InShortcut = true
  local name = grid:GetItemName(index)
  name = nx_string(name)
  if name == "" then
    return
  end
  local item = nx_execute("tips_game", "get_tips_ArrayList")
  item.ConfigID = name
  item.ItemType = ITEMTYPE_ZHAOSHI
  local StaticData = nx_execute("tips_data", "get_ini_prop", "share\\Skill\\skill_new.ini", name, "StaticData", "0")
  item.StaticData = nx_number(StaticData)
  item.is_static = true
  nx_execute("tips_game", "show_goods_tip", item, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), 32, 32, grid.ParentForm)
end
function on_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function check_is_exist_saddle()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(VIEWPORT_TOOL))
  if not nx_is_valid(view) then
    return
  end
  local viewobj_list = view:GetViewObjList()
  local count = table.maxn(viewobj_list)
  for i = 1, count do
    local view_obj = viewobj_list[i]
    local item_type = view_obj:QueryProp("ItemType")
    local bind_state = view_obj:QueryProp("BindStatus")
    if item_type == ITEMTYPE_MOUNT_SADDLE and 0 < bind_state then
      return view_obj
    end
  end
  return nil
end
function server_up_special_ride(Index, name)
  nx_pause(0.5)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local item_query = nx_value("ItemQuery")
  local mount = client_player:QueryProp("Mount")
  if string.len(mount) == 0 or mount == 0 then
    return
  end
  local skill_lst = item_query:GetItemPropByConfigID(nx_string(name), "RideSkillID")
  local ArtPack_id = item_query:GetItemPropByConfigID(nx_string(name), "ArtPack")
  local ArtPackini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  if not nx_is_valid(ArtPackini) then
    nx_msgbox("share\\Item\\ItemArtStatic.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if not ArtPackini:FindSection(nx_string(ArtPack_id)) then
    return
  end
  local sec_index_ArtPack = ArtPackini:FindSectionIndex(nx_string(ArtPack_id))
  if sec_index_ArtPack < 0 then
    return ""
  end
  local photo = ArtPackini:ReadString(sec_index_ArtPack, "Photo", "")
  local saddle = client_player:QueryProp("Saddle")
  if string.len(saddle) == 0 or saddle == 0 then
    local saddle_item = check_is_exist_saddle()
    if nx_is_valid(saddle_item) then
      skill_lst = skill_lst .. "," .. "riding_saddle"
    end
  else
    skill_lst = skill_lst .. "," .. "riding_kick_passenger"
  end
  skill_lst = skill_lst .. "," .. client_player:QueryProp("MountChargeSkill") .. "," .. client_player:QueryProp("MountSpurtSkill")
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    nx_msgbox("share\\Skill\\skill_new.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  local form_main_shortcut_ride = util_get_form("form_stage_main\\form_main\\form_main_shortcut_ride", true)
  if not nx_is_valid(form_main_shortcut_ride) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  client_player.mount_name = name
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  shortcut_grid.old_visible = false
  form_main_shortcut_ride:Show()
  nx_execute(nx_current(), "show_3D_mount", form_main_shortcut_ride, mount, client_player)
  if nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship") then
    form_main_shortcut_ride.Visible = false
  else
    form_main_shortcut_ride.Visible = true
  end
  local form_movie_new = nx_value("form_stage_main\\form_movie_new")
  if nx_is_valid(form_movie_new) then
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form_main_shortcut_ride)
    nx_execute("form_stage_main\\form_movie_new", "del_control_from_hide_list", shortcut_grid)
  end
  local mounttype = client_player:QueryProp("CurRiderType")
  if mounttype == 10 then
    util_show_form("form_stage_main\\form_gunman", true)
    local drivenpc = nx_value("DriveNpcMgr")
    if not nx_is_valid(drivenpc) then
      return
    end
    drivenpc:SetDriveMode(2)
  end
  refresh_form(form_main_shortcut_ride, skill_lst, photo, skillini)
end
function server_dn_special_ride(Index)
  local form_main_shortcut_ride = util_get_form("form_stage_main\\form_main\\form_main_shortcut_ride", true)
  if not nx_is_valid(form_main_shortcut_ride) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  local itemskill_shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_itemskill")
  local buff_common_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut_buff_common")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  if nx_is_valid(itemskill_shortcut_grid) and itemskill_shortcut_grid.Visible == true then
    shortcut_grid.Visible = false
  end
  if IsInStealInActivity() then
    shortcut_grid.Visible = false
  end
  if nx_is_valid(buff_common_grid) and buff_common_grid.Visible == true and buff_common_grid.isclose_shortgrid == 0 and buff_common_grid.isclose_shortgrid == 0 then
    shortcut_grid.Visible = false
  end
  shortcut_grid.old_visible = true
  form_main_shortcut_ride.imagegrid_1:Clear()
  form_main_shortcut_ride.Visible = false
  form_main_shortcut_ride:Close()
  local scene = nx_value("game_scene")
  local game_control = scene.game_control
  if nx_is_valid(game_control) and game_control.DriveNpcMode == 2 then
    util_show_form("form_stage_main\\form_gunman", false)
    local drivenpc = nx_value("DriveNpcMgr")
    if not nx_is_valid(drivenpc) then
      return
    end
    drivenpc:FinishDriveNpcControl()
  end
end
function IsInStealInActivity()
  local interactmgr = nx_value("InteractManager")
  if not nx_is_valid(interactmgr) then
    return false
  end
  if interactmgr:GetInteractStatus(ITT_STEALIN_GET_INTELLIGENCE) == PIS_IN_GAME or interactmgr:GetInteractStatus(ITT_STEALIN_SAVE_HOSTAGE) == PIS_IN_GAME then
    return true
  end
  return false
end
function show_3D_mount(form, mount, player)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  nx_execute("util_gui", "ui_ClearModel", form.scenebox_mountmodel)
  if not nx_is_valid(form.scenebox_mountmodel.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.scenebox_mountmodel)
    form.scenebox_mountmodel.Scene.RoundScene = true
  end
  local actor2 = form.scenebox_mountmodel.Scene:Create("Actor2")
  if not nx_is_valid(actor2) then
    nx_execute("util_gui", "ui_ClearModel", form.scenebox_mountmodel)
    return
  end
  actor2.AsyncLoad = true
  nx_execute("role_composite", "load_from_ini", actor2, "ini\\" .. mount .. ".ini")
  while not actor2.LoadFinish do
    nx_pause(0)
    if not nx_is_valid(actor2) then
      return
    end
  end
  if not nx_is_valid(actor2) then
    return
  end
  if not nx_is_valid(form) then
    main_scene:Delete(actor2)
    return
  end
  actor2:BlendAction("ride_Tpose", true, true)
  form.Actor2 = actor2
  local result = nx_execute("util_gui", "util_add_model_to_scenebox", form.scenebox_mountmodel, actor2)
  if not result then
    return
  end
  form.scenebox_mountmodel.Visible = true
  local scene = form.scenebox_mountmodel.Scene
  local radius = 0.5
  if not nx_is_valid(player) then
    return
  end
  local mounttype = player:QueryProp("CurRiderType")
  local pos_x = -0.8
  local pos_y = 2
  local rate_num = 4.5
  if mounttype == 1 then
    pos_y = 1.5
  elseif mounttype == 5 then
    pos_x = -1.9
    pos_y = 2.2
    rate_num = 18
  elseif mounttype == 2 then
    pos_x = -0.8
    pos_y = 1.1
    rate_num = 5
    actor2:SetAngle(actor2.AngleX - 0.3, actor2.AngleY, actor2.AngleZ)
  elseif mounttype == 6 then
    pos_x = -1.1
    pos_y = 2.4
    rate_num = 5.5
  elseif mounttype == 7 then
    pos_x = -1.9
    pos_y = 2.2
    rate_num = 18
  elseif mounttype == 9 then
    pos_x = -2
    pos_y = 1.2
    rate_num = 10
  elseif mounttype == 11 then
    pos_x = -1
    pos_y = 1.5
    rate_num = 10
  elseif mounttype == 13 then
    pos_x = -1
    pos_y = 1.8
    rate_num = 10
  elseif mounttype == 14 then
    pos_x = -0.9
    pos_y = 1.9
    rate_num = 5.5
  end
  scene.camera:SetPosition(pos_x, pos_y, -radius * rate_num)
  local dist = 0.785
  nx_execute("util_gui", "ui_RotateModel", form.scenebox_mountmodel, dist)
end
function on_mount_change(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_find_custom(form, "Actor2") or not nx_is_valid(form.Actor2) then
    return
  end
  if client_player:FindProp("Mount") then
    local Mount = client_player:QueryProp("Mount")
    if Mount ~= "" then
      nx_execute(nx_current(), "show_3D_mount", form, Mount, client_player)
    end
  end
end
function multi_ride_handle(msg_type, data)
  if msg_type == 1 then
    server_up_multi_ride()
  elseif msg_type == 3 then
    add_skill(data, "riding_kick_passenger")
  else
    nx_execute(nx_current(), "server_dn_multi_ride")
  end
end
function add_skill(name, new_skill)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local mount = client_player:QueryProp("Mount")
  if string.len(mount) == 0 or mount == 0 then
    return
  end
  local itemini = nx_execute("util_functions", "get_ini", "share\\Item\\tool_item.ini")
  if not nx_is_valid(itemini) then
    nx_msgbox("share\\Item\\tool_item.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if not itemini:FindSection(nx_string(name)) then
    return
  end
  local sec_index = itemini:FindSectionIndex(nx_string(name))
  if sec_index < 0 then
    return ""
  end
  local skill_lst = itemini:ReadString(sec_index, "RideSkillID", "")
  local ArtPack_id = itemini:ReadString(sec_index, "ArtPack", "")
  local ArtPackini = nx_execute("util_functions", "get_ini", "share\\Item\\ItemArtStatic.ini")
  if not nx_is_valid(ArtPackini) then
    nx_msgbox("share\\Item\\ItemArtStatic.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if not ArtPackini:FindSection(nx_string(ArtPack_id)) then
    return
  end
  local sec_index_ArtPack = ArtPackini:FindSectionIndex(nx_string(ArtPack_id))
  if sec_index_ArtPack < 0 then
    return ""
  end
  local photo = ArtPackini:ReadString(sec_index_ArtPack, "Photo", "")
  skill_lst = skill_lst .. "," .. new_skill .. "," .. client_player:QueryProp("MountChargeSkill") .. "," .. client_player:QueryProp("MountSpurtSkill")
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    nx_msgbox("share\\Skill\\skill_new.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  local form_main_shortcut_ride = util_get_form("form_stage_main\\form_main\\form_main_shortcut_ride", true)
  if not nx_is_valid(form_main_shortcut_ride) then
    return
  end
  refresh_form(form_main_shortcut_ride, skill_lst, photo, skillini)
end
function server_up_multi_ride()
  nx_pause(0.5)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local skill_lst = "riding_dismount_passenger,0"
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    return
  end
  local form_main_shortcut_ride = util_get_form("form_stage_main\\form_main\\form_main_shortcut_ride", true)
  if not nx_is_valid(form_main_shortcut_ride) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = false
  shortcut_grid.old_visible = false
  form_main_shortcut_ride:Show()
  if nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship") then
    form_main_shortcut_ride.Visible = false
  else
    form_main_shortcut_ride.Visible = true
  end
  local link_name = client_player:QueryProp("RideLinkName")
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local obj_list = client_scene:GetSceneObjList()
  local parent_obj = ""
  for i = 1, table.maxn(obj_list) do
    local client_obj = obj_list[i]
    if client_obj:FindProp("Name") then
      local name = client_obj:QueryProp("Name")
      if name == link_name then
        parent_obj = client_obj
        break
      end
    end
  end
  if nx_is_valid(parent_obj) then
    local mount = parent_obj:QueryProp("Mount")
    if string.len(mount) == 0 or mount == 0 then
    else
      nx_execute(nx_current(), "show_3D_mount", form_main_shortcut_ride, mount, parent_obj)
    end
  end
  refresh_form(form_main_shortcut_ride, skill_lst, photo, skillini)
end
function server_dn_multi_ride()
  nx_pause(0.5)
  local form_main_shortcut_ride = nx_value("form_stage_main\\form_main\\form_main_shortcut_ride")
  if not nx_is_valid(form_main_shortcut_ride) then
    return
  end
  local shortcut_grid = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(shortcut_grid) then
    return
  end
  shortcut_grid.Visible = true
  shortcut_grid.old_visible = true
  form_main_shortcut_ride.imagegrid_1:Clear()
  form_main_shortcut_ride.Visible = false
  form_main_shortcut_ride:Close()
end
function on_btn_role_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_role_info\\form_role_info")
end
function on_btn_bag_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_bag")
end
function on_btn_skill_click(btn)
  nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "auto_show_hide_wuxue")
end
function on_btn_team_click(btn)
  nx_execute("form_stage_main\\form_team\\form_team_recruit", "auto_show_hide_team")
end
function on_btn_task_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_task\\form_task_main")
end
function on_btn_relive_click(btn)
  nx_execute("form_stage_main\\form_homepoint\\form_home_point", "auto_show_hide_point_form")
end
function show_circle_select(form, skill_id)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if form.cur_skill == "" or form.cur_skill == nil then
    return
  end
  local cooltype = get_skill_info(form.cur_skill, "CoolDownCategory")
  local coolteam = get_skill_info(form.cur_skill, "CoolDownTeam")
  if gui.CoolManager:IsCooling(cooltype, coolteam) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("8029"), 2)
    end
    return
  end
  gui.GameHand.wait_ride_skill = 1
  local var_pkg = get_skill_info(skill_id, "MinVarPropNo")
  local target_shape_pkg = get_ini_value(normal_varprop_ini, nx_string(var_pkg), "TargetShapePkg", "-1")
  local hit_shape_pkg = get_ini_value(normal_varprop_ini, nx_string(var_pkg), "HitShapePkg", "-1")
  local data_query = nx_value("data_query_manager")
  if not nx_is_valid(data_query) then
    return
  end
  local target_shape = nx_number(data_query:Query(STATIC_DATA_SKILL_TARGETSHAPE, nx_number(target_shape_pkg), "TargetShapePara2"))
  local hite_shape = nx_number(data_query:Query(STATIC_DATA_SKILL_HITSHAPE, nx_number(hit_shape_pkg), "HitShapePara2"))
  nx_execute("game_effect", "add_ground_pick_effect", hite_shape * 2, target_shape, 1)
end
function get_skill_info(skill_id, info_name)
  local skillini = nx_execute("util_functions", "get_ini", "share\\Skill\\skill_new.ini")
  if not nx_is_valid(skillini) then
    nx_msgbox("share\\Skill\\skill_new.ini" .. " " .. get_msg_str("msg_120"))
    return
  end
  if skillini:FindSection(nx_string(skill_id)) then
    local sec_index = skillini:FindSectionIndex(nx_string(skill_id))
    if 0 <= sec_index then
      local static_data = skillini:ReadInteger(sec_index, "StaticData", 0)
      return skill_static_query(static_data, info_name)
    end
  end
end
function use_circle_select_skill()
  local form = nx_value("form_stage_main\\form_main\\form_main_shortcut_ride")
  if not nx_is_valid(form) then
    return
  end
  local decal = nx_value("ground_pick_decal")
  if not nx_is_valid(decal) then
    return
  end
  if form.cur_skill ~= "" and form.cur_skill ~= nil then
    nx_execute("custom_sender", "custom_send_ride_skill", nx_string(form.cur_skill), decal.PosX, decal.PosY, decal.PosZ)
  end
end
function get_ini_value(ini_path, section, key, defaut)
  local ini = get_ini(ini_path)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(section)
  if index < 0 then
    return
  end
  return ini:ReadString(index, key, defaut)
end
function is_jh_scene()
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if not player:FindProp("CurJHSceneConfigID") then
    return false
  end
  local jh_scene = player:QueryProp("CurJHSceneConfigID")
  if jh_scene == nil or jh_scene == "" then
    return false
  end
  return true
end
