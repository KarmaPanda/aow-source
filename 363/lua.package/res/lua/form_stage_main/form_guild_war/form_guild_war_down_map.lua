require("util_gui")
require("define\\team_rec_define")
require("define\\map_lable_define")
local GUILD_WAR_MAP_SHOW_REC = "guild_war_map_down_show_rec"
local DOWN_BELONG_REC = "guild_war_down_belong_rec"
local ST_ORIGIN = 0
local ST_DOOR = 6
local ST_REVIVE = 7
local ST_STONE_DOOR = 8
local ST_PILLAR = 9
local origin_x = 1065
local origin_z = -132
local orient_o = 0
local base_x = 350
local base_z = 350
local base_o = 0
local zoom_ratio = 1.22
local VIEWPORT_GUILDWAR_BOX = 132
local machine_belong_table = {}
local down_map_show_table = {}
local FORM_NAME = "form_stage_main\\form_guild_war\\form_guild_war_down_map"
function auto_show_hide_form_guild_war_down_map(show)
  local skin_path = "form_stage_main\\form_guild_war\\form_guild_war_down_map"
  local form = nx_value(skin_path)
  if nx_is_valid(form) then
    form:Close()
  else
    util_show_form(skin_path, true)
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.groupbox_transparence.Visible = false
  self.lbl_self.Visible = false
  self.tbar_transparence.Value = 255
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("GuildWarDomainID", "int", self, nx_current(), "on_guild_war_changed")
  databinder:AddViewBind(VIEWPORT_GUILDWAR_BOX, self, nx_current(), "on_map_view_oper")
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:AddBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  get_map_data(self)
  get_origin_info(self)
  on_role_pos_changed(self)
  local game_timer = nx_value("timer_game")
  if nx_is_valid(game_timer) then
    game_timer:Register(500, -1, nx_current(), "on_role_pos_changed", self, -1, -1)
  end
end
function on_main_form_close(self)
  ui_destroy_attached_form(form)
  local team_manager = nx_value("team_manager")
  if nx_is_valid(team_manager) then
    team_manager:DelBinder(nx_current(), "on_team_sub_rec_update", self)
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_role_pos_changed", self)
  end
  nx_destroy(self)
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_lock_click(self)
  local form = self.ParentForm
  form.Fixed = not form.Fixed
end
function on_btn_transparence_click(btn)
  local form = btn.ParentForm
  if form.groupbox_transparence.Visible == false then
    form.groupbox_transparence.Visible = true
  else
    form.groupbox_transparence.Visible = false
  end
end
function on_tbar_transparence_drag_leave(self)
  local group_box = self.Parent
  group_box.Visible = false
end
function on_tbar_transparence_value_changed(self)
  local lbl = self.ParentForm.lbl_p
  local form = self.ParentForm
  lbl.Top = self.Top
  lbl.Left = self.Left
  local length = self.TrackButton.Left
  if 5 < length then
    length = length + 3
  end
  lbl.Width = length
  local num = nx_int(self.Value / 255 * 100)
  if num == nx_int(0) then
    lbl.Visible = false
  else
    lbl.Visible = true
  end
  self.ParentForm.lbl_num.Text = nx_widestr(nx_string(num) .. nx_string("%"))
  if self.Value >= 0 and self.Value <= 255 then
    form.cur_back_alpha = self.Value
    set_BlendColor(form, form.cur_back_alpha)
    set_BlendColor(form.groupbox_buildings, form.cur_back_alpha)
    local control_list = form.groupbox_buildings:GetChildControlList()
    for i = 1, table.getn(control_list) do
      set_BlendColor(control_list[i], self.Value)
    end
  end
end
function set_BlendColor(control, alpha)
  control.BlendColor = nx_string(nx_int(alpha)) .. ",255,255,255"
end
function TransPosToMap(world_x, world_z)
  local map_x = base_x - zoom_ratio * (world_x - origin_x)
  local map_y = base_z + zoom_ratio * (world_z - origin_z)
  return map_x, map_y
end
function on_role_pos_changed(form)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local map_x, map_y = TransPosToMap(visual_player.PositionX, visual_player.PositionZ)
  form.lbl_self.Top = map_y - 10
  form.lbl_self.Left = map_x - 10
  form.lbl_self.AngleZ = orient_o - visual_player.AngleY + math.pi
  if not form.lbl_self.Visible then
    form.lbl_self.Visible = true
  end
  form:ToFront(form.lbl_self)
end
function on_guild_war_changed(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("GuildWarDomainID") then
    local guild_war_domainID = client_player:QueryProp("GuildWarDomainID")
    if nx_number(guild_war_domainID) == 0 then
      form:Close()
    end
  else
    form:Close()
  end
end
function refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
    timer:Register(500, 1, nx_current(), "on_refresh_all_info", form, -1, -1)
  end
end
function on_refresh_all_info(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_refresh_all_info", form)
  end
  local team_manager = nx_value("team_manager")
  if not nx_is_valid(team_manager) then
    return
  end
  local gui = nx_value("gui")
  local designer = gui.Designer
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = client_player:QueryProp("Name")
  local control_num = 0
  local record_table = team_manager:GetAllData()
  local rows = #record_table / 7
  if rows <= 0 then
    return
  end
  for index = 0, rows - 1 do
    local name = record_table[7 * index + TEAM_SUB_REC_COL_NAME + 1]
    if name ~= self_name then
      local posX = record_table[7 * index + TEAM_SUB_REC_COL_X + 1]
      local posY = record_table[7 * index + TEAM_SUB_REC_COL_Z + 1]
      local map_x, map_y = TransPosToMap(posX, posY)
      local ctrl_name = "player_" .. nx_string(control_num)
      local ctrl = form.groupbox_buildings:Find(ctrl_name)
      if nx_is_valid(ctrl) then
        ctrl.Top = map_y
        ctrl.Left = map_x
      else
        local control = designer:Create("Label")
        control.Name = ctrl_name
        control.Top = map_y
        control.Left = map_x
        control.BackImage = "gui\\guild\\guildwarmap\\duiyou.png"
        control.AutoSize = true
        control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_friend"))
        designer:AddMember(ctrl_name)
        form.groupbox_buildings:Add(control)
        form:ToFront(control)
      end
      control_num = control_num + 1
    end
  end
  local i = control_num
  local ctrl_name = "player_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    form.groupbox_buildings:Remove(form.groupbox_buildings:Find(ctrl_name))
    i = i + 1
    ctrl_name = "player_" .. nx_string(i)
  end
end
function on_team_sub_rec_update(form, opttype, ...)
  local cols = table.concat(arg, ",")
  if string.find(cols, nx_string(TEAM_SUB_REC_COL_X)) or string.find(cols, nx_string(TEAM_SUB_REC_COL_Z)) or nx_string(opttype) == nx_string("clear") or nx_string(opttype) == nx_string("del") or nx_string(opttype) == nx_string("add") or nx_string(opttype) == nx_string("update") then
    refresh_all_info(form)
  end
end
function on_npc_belong_changed(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_war_domainID = client_player:QueryProp("GuildWarDomainID")
  local length = table.getn(machine_belong_table)
  for i = 1, length do
    local domain_id = machine_belong_table[i][1]
    if guild_war_domainID == domain_id then
      local build_obj = machine_belong_table[i][2]
      local build_state = machine_belong_table[i][3]
      local show_type = machine_belong_table[i][4]
      local index = get_index(build_obj)
      if index == nil then
        return
      end
      if nx_int(index) > nx_int(0) then
        set_npc_belong_back_image(form, build_state, index - 1, show_type)
      end
    end
  end
end
function get_index(build_obj)
  if down_map_show_table == nil then
    return 0
  end
  local length = table.getn(down_map_show_table)
  for i = 1, length do
    local build_id = machine_belong_table[i][2]
    if nx_string(build_id) == nx_string(build_obj) then
      return i
    end
  end
end
function set_npc_belong_back_image(form, build_state, index, show_type)
  if not nx_is_valid(form) then
    return
  end
  local control_name = "NPC_" .. nx_string(index)
  local control = form.groupbox_buildings:Find(control_name)
  if not nx_is_valid(control) then
    return
  end
  if show_type == ST_DOOR then
    if build_state == 1 then
      control.BackImage = "gui\\guild\\guildwarmap\\chuansongmen.png"
    elseif build_state == 2 then
      control.BackImage = "gui\\guild\\guildwarmap\\chuansongmen_g.png"
    end
  elseif show_type == ST_STONE_DOOR then
    if build_state == 1 then
      control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underorgan_s.png"
    elseif build_state == 2 then
      control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underorgan_g.png"
    end
  elseif show_type == ST_PILLAR then
    if build_state == 1 then
      control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underpillar_b.png"
    elseif build_state == 2 then
      control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underpillar_r.png"
    end
  end
end
function on_guild_war_map_changed(form)
  local gui = nx_value("gui")
  local designer = gui.Designer
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_war_domainID = client_player:QueryProp("GuildWarDomainID")
  local length = table.getn(down_map_show_table)
  local control_num = 0
  for i = 1, length do
    local domain_id = down_map_show_table[i][1]
    local obj_id = down_map_show_table[i][2]
    local show_type = down_map_show_table[i][3]
    if guild_war_domainID == domain_id and nx_string(obj_id) ~= nx_string(client_player.Ident) and guild_war_domainID ~= show_type then
      local posX = down_map_show_table[i][4]
      local posZ = down_map_show_table[i][6]
      local orient = down_map_show_table[i][7]
      local map_x, map_y = TransPosToMap(posX, posZ)
      local ctrl_name = "NPC_" .. nx_string(control_num)
      local ctrl = form.groupbox_buildings:Find(ctrl_name)
      if nx_is_valid(ctrl) then
        ctrl.Top = map_y
        ctrl.Left = map_x
        if show_type == ST_STONE_DOOR then
          ctrl.Top = map_y - 10
          ctrl.Left = map_x - 10
          ctrl.BackImage = "gui\\guild\\guildwarmap\\guildwar_underorgan_s.png"
          ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_jiguan"))
        elseif show_type == ST_DOOR then
          ctrl.Top = map_y - 10
          ctrl.Left = map_x - 10
          ctrl.BackImage = "gui\\guild\\guildwarmap\\chuansongmen.png"
          ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_chuansongmeng"))
        elseif show_type == ST_REVIVE then
          ctrl.Top = map_y - 10
          ctrl.Left = map_x - 10
          ctrl.BackImage = "gui\\guild\\guildwarmap\\fuhuodian.png"
          ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_fuhuodian"))
        elseif show_type == ST_PILLAR then
          ctrl.Top = map_y - 10
          ctrl.Left = map_x - 10
          ctrl.BackImage = "gui\\guild\\guildwarmap\\guildwar_underpillar_b.png"
          ctrl.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_liangzhu"))
        end
      else
        local control = designer:Create("Label")
        control.Name = ctrl_name
        control.Top = map_y
        control.Left = map_x
        if show_type == ST_STONE_DOOR then
          control.Top = map_y - 10
          control.Left = map_x - 10
          control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underorgan_s.png"
          control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_jiguan"))
        elseif show_type == ST_DOOR then
          control.Top = map_y - 10
          control.Left = map_x - 10
          control.BackImage = "gui\\guild\\guildwarmap\\chuansongmen.png"
          control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_chuansongmeng"))
        elseif show_type == ST_REVIVE then
          control.Top = map_y - 10
          control.Left = map_x - 10
          control.BackImage = "gui\\guild\\guildwarmap\\fuhuodian.png"
          control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_fuhuodian"))
        elseif show_type == ST_PILLAR then
          control.Top = map_y - 10
          control.Left = map_x - 10
          control.BackImage = "gui\\guild\\guildwarmap\\guildwar_underpillar_b.png"
          control.HintText = nx_widestr(gui.TextManager:GetText("ui_guild_war_map_liangzhu"))
        end
        control.AutoSize = true
        designer:AddMember(ctrl_name)
        form.groupbox_buildings:Add(control)
      end
      control_num = control_num + 1
    end
  end
  local i = control_num
  local ctrl_name = "NPC_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    form.groupbox_buildings:Remove(form.groupbox_buildings:Find(ctrl_name))
    i = i + 1
    ctrl_name = "NPC_" .. nx_string(i)
  end
end
function get_origin_info(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_war_domainID = client_player:QueryProp("GuildWarDomainID")
  local length = table.getn(down_map_show_table)
  for i = 1, length do
    local domain_id = down_map_show_table[i][1]
    local show_type = down_map_show_table[i][3]
    if guild_war_domainID == domain_id and show_type == domain_id then
      origin_x = down_map_show_table[i][4]
      origin_z = down_map_show_table[i][6]
      orient_o = down_map_show_table[i][7]
      if origin_x == nil or origin_z == nil or orient_o == nil then
        origin_x = 0
        origin_z = 0
        orient_o = 0
      end
      form.lbl_title.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_" .. domain_id))
      return
    end
  end
end
function on_map_view_oper(form, op_type, view_ident, index)
  if not nx_is_valid(form) or not form.Visible then
    return false
  end
  local new_time = nx_function("ext_get_tickcount")
  if new_time - form.refresh_time < 1000 then
    return 0
  end
  form.refresh_time = new_time
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return false
  end
  if op_type == "createview" then
    get_map_data(form)
    get_origin_info(form)
  elseif op_type == "deleteview" then
    map_show_table = {}
    belong_table = {}
  elseif op_type == "additem" then
    get_map_data(form)
  elseif op_type == "delitem" then
    get_map_data(form)
  elseif op_type == "updateitem" then
    get_map_data(form)
  elseif op_type == "updaterecord" then
    get_map_data(form)
  end
  return true
end
function get_map_data(form)
  get_down_show_data(form)
  get_belong_data(form)
  on_guild_war_map_changed(form)
  on_npc_belong_changed(form)
end
function get_down_show_data(form)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_GUILDWAR_BOX))
  if not nx_is_valid(view) then
    return false
  end
  if not view:FindRecord(GUILD_WAR_MAP_SHOW_REC) then
    return false
  end
  down_map_show_table = {}
  local rows = view:GetRecordRows(GUILD_WAR_MAP_SHOW_REC)
  for i = 0, rows - 1 do
    local domain_id = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 0)
    local obj_id = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 1)
    local show_type = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 2)
    local x = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 3)
    local y = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 4)
    local z = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 5)
    local o = view:QueryRecord(GUILD_WAR_MAP_SHOW_REC, i, 6)
    table.insert(down_map_show_table, {
      domain_id,
      obj_id,
      show_type,
      x,
      y,
      z,
      o
    })
  end
  return true
end
function get_belong_data(form)
  local cur_domain_id = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if nx_is_valid(client_player) and client_player:FindProp("GuildWarDomainID") then
    cur_domain_id = client_player:QueryProp("GuildWarDomainID")
  end
  local view = game_client:GetView(nx_string(VIEWPORT_GUILDWAR_BOX))
  if not nx_is_valid(view) then
    return false
  end
  if not view:FindRecord(DOWN_BELONG_REC) then
    return false
  end
  machine_belong_table = {}
  rows = view:GetRecordRows(DOWN_BELONG_REC)
  for i = 0, rows - 1 do
    local domain_id = view:QueryRecord(DOWN_BELONG_REC, i, 0)
    if domain_id == cur_domain_id then
      local obj_id = view:QueryRecord(DOWN_BELONG_REC, i, 1)
      local state = view:QueryRecord(DOWN_BELONG_REC, i, 2)
      local show_type = view:QueryRecord(DOWN_BELONG_REC, i, 3)
      table.insert(machine_belong_table, {
        domain_id,
        obj_id,
        state,
        show_type
      })
    end
  end
  return true
end
function add_label_to_map(id, x, z, label_type, tips)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sx, sz = TransPosToMap(x, z)
  local lab = form.groupbox_label:Find("map_label_" .. nx_string(id))
  if not nx_is_valid(lab) then
    lab = gui:Create("Label")
    lab.Name = "map_label_" .. nx_string(id)
    lab.AutoSize = true
    lab.BackImage = map_lable_icon[id]
    lab.Left = sx - lab.Width / 2
    lab.Top = sz - lab.Height / 2
    lab.Transparent = false
    if tips ~= nil then
      lab.HintText = nx_widestr(util_text(tips))
    end
    form.groupbox_label:Add(lab)
  else
    lab.Left = sx - lab.Width / 2
    lab.Top = sz - lab.Height / 2
  end
end
function add_label_to_map_ani(id, x, z, width, height, label_type, tips)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local sx, sz = TransPosToMap(x, z)
  local lab = form.groupbox_label:Find("map_label_" .. nx_string(id))
  if not nx_is_valid(lab) then
    lab = gui:Create("Label")
    lab.Name = "map_label_" .. nx_string(id)
    lab.BackImage = map_lable_icon[id]
    lab.Left = sx - width / 2
    lab.Top = sz - height / 2
    lab.Width = width
    lab.Height = height
    lab.Transparent = false
    if tips ~= nil then
      lab.HintText = nx_widestr(util_text(tips))
    end
    form.groupbox_label:Add(lab)
  else
    lab.Left = sx - width / 2
    lab.Top = sz - height / 2
  end
end
function delete_map_label(id)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local lab = form.groupbox_label:Find("map_label_" .. nx_string(id))
  if nx_is_valid(lab) then
    gui:Delete(lab)
  end
end
function create_circle(name, x, z, raduis, image)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local ctrl_circle = form.groupbox_circle:Find(nx_string(name))
  if nx_is_valid(ctrl_circle) then
    gui:Delete(ctrl_circle)
  end
  ctrl_circle = gui:Create("ConvexPolygonBox")
  if not nx_is_valid(ctrl_circle) then
    return
  end
  ctrl_circle.Name = nx_string(name)
  ctrl_circle.BlendColor = "255,255,255,255"
  ctrl_circle.Image = nx_string(image)
  ctrl_circle.Enabled = false
  ctrl_circle.NoFrame = false
  ctrl_circle.Transparent = true
  ctrl_circle.BorderWidth = 9
  form.groupbox_circle:Add(ctrl_circle)
  ctrl_circle.CircleX = nx_int(x)
  ctrl_circle.CircleZ = nx_int(z)
  ctrl_circle.CircleRaduis = nx_int(raduis)
  ctrl_circle.CircleImage = nx_int(image)
  local count = 60
  local min_x = 10000
  local min_y = 10000
  local max_x = -10000
  local max_y = -10000
  for i = 0, count - 1 do
    local nx = x - raduis * math.cos(2 * math.pi / count * i)
    local nz = z + raduis * math.sin(2 * math.pi / count * i)
    local point_x, point_y = TransPosToMap(nx, nz)
    if min_x < point_x then
      min_x = point_x
    end
    if min_y < point_y then
      min_y = point_y
    end
    if max_x < point_x then
      max_x = point_x
    end
    if max_y < point_y then
      max_y = point_y
    end
  end
  ctrl_circle.Left = min_x
  ctrl_circle.Top = min_y
  ctrl_circle.Width = max_x - min_x + 1
  ctrl_circle.Height = max_y - min_y + 1
  ctrl_circle:ClearPoint()
  for i = 0, count - 1 do
    local nx = x - raduis * math.cos(2 * math.pi / count * i)
    local nz = z + raduis * math.sin(2 * math.pi / count * i)
    local point_x, point_y = TransPosToMap(nx, nz)
    ctrl_circle:AddPoint(nx_int(point_x - min_x), nx_int(point_y - min_y))
  end
end
function delete_circle(name)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local ctrl_circle = form.groupbox_circle:Find(nx_string(name))
  if nx_is_valid(ctrl_circle) then
    gui:Delete(ctrl_circle)
  end
end
