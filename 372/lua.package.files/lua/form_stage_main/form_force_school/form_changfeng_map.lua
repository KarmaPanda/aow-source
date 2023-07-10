require("util_functions")
require("share\\client_custom_define")
local SERVER_SUBMSG_SHOW_CHANGFENG_MAP = 0
local CLIENT_SUBMSG_CHANGFENG_MOVETO = 0
local scene_btn_list = {
  "btn_13",
  "btn_14",
  "btn_15",
  "btn_16",
  "btn_17"
}
local world_scene_list = {
  [13] = "city01",
  [14] = "city02",
  [15] = "city03",
  [16] = "city04",
  [17] = "city05"
}
local CHANGFENG_FORM = "form_stage_main\\form_force_school\\form_changfeng_map"
local CHANGFENG_FORM_SCENE = "form_stage_main\\form_force_school\\form_changfeng_map_scene"
function main_form_init(form)
  form.Fixed = false
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  form.visual_player = visual_player
  form.from_scene_id = 0
  form.to_scene_id = 0
  form.npc_id = ""
  form.npc_config = ""
  form.pos_x = nx_float(0)
  form.pos_z = nx_float(0)
  form.cd_time = 0
end
function on_main_form_open(form)
  form.lbl_cd_time.Text = nx_widestr("")
  form.lbl_4.Visible = false
  clear_form_info(form)
  change_form_size()
  form.from_scene_id = nx_number(get_cur_scene_id(form.visual_player))
  show_begin(form, form.from_scene_id)
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
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "cd_time_heart", form)
  end
  nx_execute("util_gui", "ui_destroy_attached_form", form)
  nx_destroy(form)
end
function on_changfeng_moveto_msg(...)
  local submsg = arg[1]
  if submsg == SERVER_SUBMSG_SHOW_CHANGFENG_MAP then
    local npc_id = arg[2]
    local cd_time = arg[3]
    show_changfeng_moveto_form(npc_id, cd_time)
  end
end
function show_changfeng_moveto_form(npc_id, cd_time)
  local form = nx_execute("util_gui", "util_get_form", CHANGFENG_FORM, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
  nx_execute("util_gui", "util_show_form", CHANGFENG_FORM, true)
  form = nx_execute("util_gui", "util_get_form", CHANGFENG_FORM, false, false)
  form.npc_id = npc_id
  form.cd_time = cd_time
  form.lbl_cd_time.Text = nx_widestr(get_format_time(form.cd_time))
  form.lbl_4.Visible = false
  if nx_number(form.cd_time) > 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "cd_time_heart", form, -1, -1)
    end
    form.lbl_4.Visible = true
  end
end
function cd_time_heart(form)
  form.cd_time = nx_number(form.cd_time) - 1
  form.lbl_cd_time.Text = nx_widestr(get_format_time(form.cd_time))
  if nx_number(form.cd_time) <= 0 then
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "cd_time_heart", form, -1, -1)
    end
    form.lbl_4.Visible = false
  end
end
function get_format_time(time)
  local time_text = ""
  if nx_number(time) < nx_number(0) then
    return time_text
  end
  local hour = nx_int(nx_number(time) / 3600)
  local minute = nx_int(nx_number(time) % 3600 / 60)
  local second = nx_int(nx_number(time) % 60)
  time_text = string.format("%02d:%02d:%02d", nx_number(hour), nx_number(minute), nx_number(second))
  return time_text
end
function clear_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_end.Visible = false
  form.btn_carriage.Enabled = false
end
function change_form_size()
  local form = nx_execute("util_gui", "util_get_form", CHANGFENG_FORM, false, false)
  if nx_is_valid(form) and form.Visible then
    local gui = nx_value("gui")
    local desktop = gui.Desktop
    form.Left = (desktop.Width - form.Width) / 2
    form.Top = (desktop.Height - form.Height) / 2
  end
end
function get_cur_scene_id(role)
  local game_client = nx_value("game_client")
  local client_scene = game_client:GetScene()
  local resource = client_scene:QueryProp("Resource")
  return get_scene_id_by_name(resource)
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
function on_btn_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_form_info(form)
  to_scene_id = nx_number(btn.DataSource)
  form.to_scene_id = 0
  local game_client = nx_value("game_client")
  local npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(npc) then
    return
  end
  local npc_config = npc:QueryProp("ConfigID")
  local world_scene_list_str = world_scene_list[to_scene_id]
  if world_scene_list_str == nil then
    local info = nx_widestr(gui.TextManager:GetText("ui_changjkaifang"))
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", CHANGFENG_FORM_SCENE, true, false)
  dialog.Left = (gui.Desktop.Width - dialog.Width) / 2
  dialog.Top = (gui.Desktop.Height - dialog.Height) / 2
  nx_execute(CHANGFENG_FORM_SCENE, "init_scene", dialog, to_scene_id, npc_config)
  dialog:Show()
  local res, npc_config = nx_wait_event(100000000, dialog, "return_cfpos_index")
  if not nx_is_valid(form) then
    return
  end
  if res == "ok" then
    if npc_config == "" then
      return false
    end
    form.npc_config = npc_config
    form.to_scene_id = to_scene_id
  else
    return false
  end
  if form.to_scene_id ~= 0 and 0 >= form.cd_time then
    form.btn_carriage.Enabled = true
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
function get_btn_hit(index)
  local form = nx_execute("util_gui", "util_get_form", CHANGFENG_FORM, false, false)
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
function show_info(form, from, to)
  if not nx_is_valid(form) then
    return
  end
  local from_scene = form.gbx_info:Find("qidian")
  if nx_is_valid(from_scene) then
    from_scene.Text = nx_widestr(from)
  end
  local scene_to = form.gbx_info:Find("zhongdian")
  if nx_is_valid(scene_to) then
    scene_to.Text = nx_widestr(to)
  end
end
function on_btn_carriage_click(btn_carriage)
  local form = btn_carriage.ParentForm
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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHANGFENG_MOVETO), nx_int(CLIENT_SUBMSG_CHANGFENG_MOVETO), nx_string(form.npc_config))
  form:Close()
end
