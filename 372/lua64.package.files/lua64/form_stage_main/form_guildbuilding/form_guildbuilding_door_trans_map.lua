require("util_functions")
local CLIENT_CUSTOMMSG_GUILDBUILDING = 1016
local CLIENT_SUBMSG_REQUEST_TRANS_POS = 141
local CLIENT_SUBMSG_REQUEST_CHOOSE_POS = 142
local CLIENT_SUBMSG_REQUEST_DELETE_POS = 143
local CLIENT_SUBMSG_REQUEST_GET_POSLIST = 144
local scene_btn_list = {
  "btn_1",
  "btn_2",
  "btn_3",
  "btn_4",
  "btn_5",
  "btn_6",
  "btn_7",
  "btn_8",
  "btn_9",
  "btn_10",
  "btn_11",
  "btn_12",
  "btn_13",
  "btn_14",
  "btn_15",
  "btn_16",
  "btn_17",
  "btn_18",
  "btn_19",
  "btn_20",
  "btn_21",
  "btn_22",
  "btn_23",
  "btn_24",
  "btn_25",
  "btn_26"
}
local world_scene_list = {
  [1] = "born04",
  [2] = "born02",
  [3] = "born03",
  [4] = "born01",
  [5] = "school01",
  [6] = "school02",
  [7] = "school03",
  [8] = "school04",
  [9] = "school05",
  [10] = "school06",
  [11] = "school07",
  [12] = "school08",
  [13] = "city01",
  [14] = "city02",
  [15] = "city03",
  [16] = "city04",
  [17] = "city05",
  [25] = "scene08"
}
local active_scene_list = {}
local guanyi_point_list = {}
function main_form_init(form)
  form.Fixed = false
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  form.visual_player = visual_player
  form.from_scene_id = 0
  form.to_scene_id = 0
  form.build_level = 0
  form.npc_id = ""
  form.index = 0
  form.pos_x = nx_float(0)
  form.pos_z = nx_float(0)
  form.cost_type = 0
  form.cost_silver = 0
  form.contribute = 0
  form.cur_points = 0
  form.max_points = 0
end
function on_main_form_open(form)
  form.lbl_point_number.Text = nx_widestr("")
  clear_form_info(form)
  change_form_size()
  form.from_scene_id = nx_number(get_cur_scene_id(form.visual_player))
  show_begin(form, form.from_scene_id)
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  active_scene_list = gb_manager:GetSceneList(form.build_level)
  init_scene_btn(form)
  get_trans_cost(form)
  form.cur_points = nx_int(0)
  get_max_point(form)
  get_all_guanyi_point_list(form)
  request_opened_transpoint_list(form)
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
function on_main_form_close(form)
  nx_execute("util_gui", "ui_destroy_attached_form", form)
  nx_destroy(form)
end
function on_btn_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_form_info(form)
  form.to_scene_id = nx_number(btn.DataSource)
  local world_scene_list_str = world_scene_list[form.to_scene_id]
  if world_scene_list_str == nil then
    local info = nx_widestr(gui.TextManager:GetText("ui_changjkaifang"))
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  if nx_int(form.build_level) <= nx_int(4) then
    form.index = 0
    if not nx_find_custom(btn, "is_active") then
      btn.is_active = 0
    end
    if btn.is_active == 0 then
      open_trans_point(form)
      return
    end
  else
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_door_map_scene", true, false)
    dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
    dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
    nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_map_scene", "init_scene", dialog, form.to_scene_id, form.build_level, form.npc_id)
    dialog:Show()
    local res, pos_index = nx_wait_event(100000000, dialog, "return_pos_index")
    if not nx_is_valid(form) then
      return
    end
    if res == "ok" then
      if pos_index < 0 then
        return false
      end
      form.index = pos_index
    else
      return false
    end
  end
  local from = nx_widestr(get_btn_hit(form.from_scene_id))
  local to = nx_widestr(get_btn_hit(form.to_scene_id))
  show_info(form, from, to)
  show_end(form, form.to_scene_id)
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function on_btn_carriage_click(btn_carriage)
  local form = btn_carriage.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  if form.index < 0 then
    return
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    local form_main_sysinfo = nx_value("form_main_sysinfo")
    if nx_is_valid(form_main_sysinfo) then
      form_main_sysinfo:AddSystemInfo(util_text("80624"), 0, 0)
    end
    return false
  end
  local domain_id = npc:QueryProp("DomainID")
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_table = {}
  temp_table = gb_manager:GetTransPos(form.to_scene_id, form.build_level, form.index)
  local lenth = table.getn(temp_table)
  if lenth < 2 then
    return false
  end
  local pos_x = temp_table[1]
  local pos_z = temp_table[2]
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_TRANS_POS), nx_int(domain_id), nx_int(form.to_scene_id), nx_float(pos_x), nx_float(pos_z))
  form:Close()
end
function get_cur_scene_id(role)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local resource = client_scene:QueryProp("Resource")
  return get_scene_id_by_name(resource)
end
function get_trans_cost(form)
  if not nx_is_valid(form) then
    return
  end
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_table = {}
  temp_table = gb_manager:GetTransCostInfo(form.build_level)
  local lenth = table.getn(temp_table)
  if lenth < 3 then
    return false
  end
  form.cost_type = temp_table[1]
  form.cost_silver = temp_table[2]
  form.contribute = temp_table[3]
  form.max_points = temp_table[4]
  local scene_cost = form.gbx_info:Find("feiyong")
  local capital_module = nx_value("CapitalModule")
  if nx_is_valid(scene_cost) then
    scene_cost.HtmlText = nx_widestr(capital_module:GetFormatCapitalHtml(form.cost_type, nx_number(form.cost_silver)))
  end
  form.lbl_contribute.Text = nx_widestr(form.contribute)
end
function get_scene_id_by_name(name)
  if nil == name and "" == name then
    return false
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\rule\\maplist.ini " .. get_msg_str("msg_120"))
    return false
  end
  local item_count = ini:GetSectionItemCount(0)
  local index = 0
  local scene_name = ""
  for i = 1, item_count do
    index = index + 1
    scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if name == scene_name then
      return index
    end
  end
end
function get_btn_hit(index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_door_trans_map", false, false)
  if not nx_is_valid(form) then
    return ""
  end
  for i = 1, table.getn(scene_btn_list) do
    local btn_name = scene_btn_list[i]
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) and nx_number(btn_scene.DataSource) == nx_number(index) then
      return nx_string(btn_scene.Text)
    end
  end
  return ""
end
function init_scene_btn(form)
  for i = 1, table.getn(scene_btn_list) do
    local btn_name = scene_btn_list[i]
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) then
      btn_scene.Enabled = false
    end
  end
  local lenth = table.getn(active_scene_list)
  for i = 1, lenth do
    local active_scene_id = active_scene_list[i]
    local btn_name = "btn_" .. active_scene_id
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) then
      btn_scene.Enabled = true
      btn_scene.NormalImage = "gui\\map\\yizhan\\yellow-01.png"
      btn_scene.FocusImage = "gui\\map\\yizhan\\yellow-02.png"
      btn_scene.BlendColor = ""
      btn_scene.is_open = 1
    end
  end
  form.btn_carriage.Enabled = false
  form.btn_delete.Enabled = false
end
function show_info(form, from, to)
  if not nx_is_valid(form) then
    return
  end
  form.btn_carriage.Enabled = true
  form.btn_delete.Enabled = true
  local from_scene = form.gbx_info:Find("qidian")
  if nx_is_valid(from_scene) then
    from_scene.Text = nx_widestr(from)
  end
  local scene_to = form.gbx_info:Find("zhongdian")
  if nx_is_valid(scene_to) then
    scene_to.Text = nx_widestr(to)
  end
  form.btn_carriage.Enabled = true
  form.btn_delete.Enabled = true
end
function clear_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  local from_scene = form.gbx_info:Find("qidian")
  if nx_is_valid(from_scene) then
    from_scene.Text = nx_widestr("")
  end
  local scene_to = form.gbx_info:Find("zhongdian")
  if nx_is_valid(scene_to) then
    scene_to.Text = nx_widestr("")
  end
  form.lbl_end.Visible = false
  form.btn_carriage.Enabled = false
  form.btn_delete.Enabled = false
end
function change_form_size()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_door_trans_map", false, false)
  if nx_is_valid(form) and form.Visible then
    local gui = nx_value("gui")
    local desktop = gui.Desktop
    form.Left = (desktop.Width - form.Width) / 2
    form.Top = (desktop.Height - form.Height) / 2
  end
end
function show_begin(form, index)
  form.lbl_begin.Visible = false
  for i = 1, table.getn(scene_btn_list) do
    local btn_name = scene_btn_list[i]
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) and nx_number(btn_scene.DataSource) == nx_number(index) then
      form.lbl_begin.Left = btn_scene.Left - 10 + form.gbx_scene.Left
      form.lbl_begin.Top = btn_scene.Top - 30 + form.gbx_scene.Top
      form.lbl_begin.Visible = true
    end
  end
end
function show_end(form, index)
  form.lbl_end.Visible = false
  for i = 1, table.getn(scene_btn_list) do
    local btn_name = scene_btn_list[i]
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) and nx_number(btn_scene.DataSource) == nx_number(index) then
      form.lbl_end.Left = btn_scene.Left - 10 + form.gbx_scene.Left
      form.lbl_end.Top = btn_scene.Top - 30 + form.gbx_scene.Top
      form.lbl_end.Visible = true
    end
  end
end
function on_btn_delete_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if form.index < 0 then
    return
  end
  local game_client = nx_value("game_client")
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(gui.TextManager:GetText("ui_delete_point1"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_table = {}
  temp_table = gb_manager:GetTransPos(form.to_scene_id, form.build_level, form.index)
  local lenth = table.getn(temp_table)
  if lenth < 2 then
    return false
  end
  local pos_x = temp_table[1]
  local pos_z = temp_table[2]
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_DELETE_POS), nx_int(domain_id), nx_int(form.to_scene_id), nx_float(pos_x), nx_float(pos_z))
end
function open_trans_point(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guildbuilding_door_chooseitem", true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  nx_execute("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_chooseitem", "main_form_open", dialog)
  dialog:Show()
  local res, item_id = nx_wait_event(100000000, dialog, "return_item_id")
  if res == "ok" then
  else
    return false
  end
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "index") then
    return
  end
  if form.index < 0 then
    return
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_table = {}
  temp_table = gb_manager:GetTransPos(form.to_scene_id, form.build_level, form.index)
  local lenth = table.getn(temp_table)
  if lenth < 2 then
    return false
  end
  local pos_x = temp_table[1]
  local pos_z = temp_table[2]
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_CHOOSE_POS), nx_int(domain_id), nx_int(form.to_scene_id), nx_float(pos_x), nx_float(pos_z), nx_string(item_id))
end
function request_opened_transpoint_list(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local domain_id = npc:QueryProp("DomainID")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_REQUEST_GET_POSLIST), nx_int(domain_id))
end
function on_recv_pos_list(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_trans_map")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 0 or size % 3 ~= 0 then
    return 0
  end
  local rows = size / 3
  for i = 1, rows do
    local base = (i - 1) * 3
    local scene_id = nx_int(arg[base + 1])
    local index = nx_int(arg[base + 2])
    local overdue_time = nx_string(arg[base + 3])
    set_choosed_btn(form, scene_id, overdue_time, index)
  end
  form.cur_points = rows
  get_max_point(form)
end
function set_choosed_btn(form, scene_id, overdue_time, index)
  if not nx_is_valid(form) then
    return
  end
  local name = "btn_" .. nx_string(scene_id)
  local length = table.getn(scene_btn_list)
  for i = 1, length do
    local btn_name = scene_btn_list[i]
    if name == btn_name then
      local btn_scene = form.gbx_scene:Find(btn_name)
      if nx_is_valid(btn_scene) then
        btn_scene.is_active = 1
        if not nx_find_custom(btn_scene, "is_image") then
          btn_scene.is_image = 0
        end
        btn_scene.NormalImage = "gui\\map\\yizhan\\green-01.png"
        btn_scene.FocusImage = "gui\\map\\yizhan\\green-02.png"
        btn_scene.is_image = 1
        if nx_int(index) == nx_int(0) then
          btn_scene.overdue_time = overdue_time
        end
      end
      return
    end
  end
end
function on_recv_open_ok(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_trans_map")
  if not nx_is_valid(form) then
    return 0
  end
  local size = table.getn(arg)
  if size < 2 then
    return 0
  end
  local scene_id = nx_int(arg[1])
  local index = nx_int(arg[2])
  local overdue_time = nx_string(arg[3])
  local length = table.getn(scene_btn_list)
  for i = 1, length do
    local name = "btn_" .. nx_string(scene_id)
    local btn_name = scene_btn_list[i]
    if name == btn_name then
      local btn_scene = form.gbx_scene:Find(btn_name)
      if nx_is_valid(btn_scene) then
        btn_scene.is_active = 1
        btn_scene.NormalImage = "gui\\map\\yizhan\\green-01.png"
        btn_scene.FocusImage = "gui\\map\\yizhan\\green-02.png"
        if nx_int(index) == nx_int(0) then
          btn_scene.overdue_time = overdue_time
        end
        form.cur_points = form.cur_points + 1
        get_max_point(form)
        return
      end
    end
  end
end
function on_recv_delete_ok(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guildbuilding_door_trans_map")
  if not nx_is_valid(form) then
    return
  end
  local size = table.getn(arg)
  if size < 2 then
    return
  end
  clear_form_info(form)
  form.btn_carriage.Enabled = false
  form.btn_delete.Enabled = false
  local scene_id = nx_int(arg[1])
  local index = nx_int(arg[2])
  local length = table.getn(scene_btn_list)
  for i = 1, length do
    local name = "btn_" .. nx_string(scene_id)
    local btn_name = scene_btn_list[i]
    if name == btn_name then
      local btn_scene = form.gbx_scene:Find(btn_name)
      if nx_is_valid(btn_scene) then
        btn_scene.is_active = 0
        form.cur_points = form.cur_points - 1
        get_max_point(form)
        if nx_int(index) == nx_int(0) then
          btn_scene.NormalImage = "gui\\map\\yizhan\\yellow-01.png"
          btn_scene.FocusImage = "gui\\map\\yizhan\\yellow-02.png"
          btn_scene.overdue_time = ""
        end
        return
      end
    end
  end
end
function get_max_point(form)
  if not nx_is_valid(form) then
    return
  end
  local info = nx_string(form.cur_points) .. "/" .. nx_string(form.max_points)
  form.lbl_point_number.Text = nx_widestr(info)
end
function on_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_get_capture(btn)
  local gui = nx_value("gui")
  local form = btn.ParentForm
  if form.build_level == 5 then
    return
  end
  local index = nx_number(btn.DataSource)
  if guanyi_point_list == nil then
    return false
  end
  local length = table.getn(guanyi_point_list)
  if index > length then
    return false
  end
  local world_scene_list_str = world_scene_list[index]
  if world_scene_list_str == nil then
    return
  end
  if nx_find_custom(btn, "is_active") then
    local is_active = btn.is_active
    if is_active == 0 then
      return
    end
  else
    return
  end
  for i = 1, length do
    local scene_id = guanyi_point_list[i][5]
    if nx_int(scene_id) == nx_int(index) then
      local posx = guanyi_point_list[i][1]
      local posz = guanyi_point_list[i][2]
      local pos_name = guanyi_point_list[i][3]
      local overdue_time = nx_string("")
      if nx_find_custom(btn, "overdue_time") then
        overdue_time = btn.overdue_time
      end
      local name = nx_widestr(gui.TextManager:GetText(pos_name))
      local ui_overdue_time = nx_widestr(gui.TextManager:GetText("ui_overdue_time"))
      local text = nx_widestr(gui.TextManager:GetFormatText("<font color=\"#FFFFFF\">[{@0:name}]</font><br><font color=\"#ED5F00\">({@1:x},{@2:y})</font><br><font color=\"#ED5F00\">{@3:text}{@4:time}</font>", name, id, nx_int(posx), nx_int(posz), ui_overdue_time, overdue_time))
      local x, y = gui:GetCursorPosition()
      nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
      return
    end
  end
end
function get_all_guanyi_point_list(form)
  guanyi_point_list = {}
  local gb_manager = nx_value("GuildbuildingManager")
  if not nx_is_valid(gb_manager) then
    return false
  end
  local temp_poslist = {}
  temp_poslist = gb_manager:GetAllSceneFirstPoint()
  local lenth = table.getn(temp_poslist)
  if lenth < 5 or lenth % 5 ~= 0 then
    return false
  end
  local rows = lenth / 5
  for i = 0, rows - 1 do
    local index = i * 5
    local x = temp_poslist[index + 1]
    local y = temp_poslist[index + 2]
    local pos_name = temp_poslist[index + 3]
    local pos_index = temp_poslist[index + 4]
    local scene_id = temp_poslist[index + 5]
    table.insert(guanyi_point_list, {
      x,
      y,
      pos_name,
      pos_index,
      scene_id
    })
  end
end
