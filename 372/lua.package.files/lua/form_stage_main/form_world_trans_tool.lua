require("util_gui")
scene_btn_list = {
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
  "btn_26",
  "btn_70",
  "btn_604",
  "btn_603",
  "btn_605"
}
scene_path_list = {
  "4_13_down",
  "13_18_down",
  "5_13_down",
  "13_19_down",
  "13_20_down",
  "13_15_down",
  "15_16_down",
  "15_17_down",
  "14_15_down",
  "8_14_down",
  "14_24_down",
  "7_14_down",
  "3_14_down",
  "12_16_down",
  "16_26_down",
  "2_16_down",
  "11_16_down",
  "2_25_down",
  "1_17_down",
  "17_22_down",
  "17_21_down",
  "10_17_down",
  "9_17_down",
  "1_23_down",
  "6_13_down",
  "16_70_down",
  "3_604_down",
  "603_604_down",
  "604_605_down",
  "603_605_down"
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
  [25] = "scene08",
  [70] = "scene10",
  [603] = "scene17",
  [604] = "scene16",
  [605] = "scene19",
  [769] = "school20",
  [832] = "school22"
}
active_scene_list = {}
path_scene_list = {}
local SUB_CUSTOMMSG_TRANS_BY_HORSE = 1
local SUB_CUSTOMMSG_TRANS_BY_CARRIAGE = 2
function main_form_init(form)
  form.Fixed = true
  form.trans_tool_npc_manager = nx_value("TransToolNpcManager")
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  form.visual_player = visual_player
  form.from_scene_id = 0
  form.to_scene_id = 0
  form.money = 0
  form.gold = 0
  form.ask_dialog = nil
  form.err_dialog = nil
end
function on_main_form_open(form)
  clear_form_info(form)
  change_form_size()
  form.from_scene_id = nx_number(get_cur_scene_id(form.visual_player))
  show_begin(form, form.from_scene_id)
  active_scene_list = form.trans_tool_npc_manager:GetAllActiveWorldSceneList(form.visual_player, form.from_scene_id)
  init_scene_btn(form)
  nx_execute("custom_sender", "custom_ws_check_test_server_open")
end
function on_main_form_close(form)
  if nx_is_valid(form.ask_dialog) then
    form.ask_dialog:Close()
    form.ask_dialog = nil
  end
  if nx_is_valid(form.err_dialog) then
    form.err_dialog:Close()
    form.err_dialog = nil
  end
  nx_destroy(form)
end
function on_btn_click(self)
  local form = self.Parent.Parent
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  clear_form_info(form)
  form.to_scene_id = nx_number(self.DataSource)
  if form.to_scene_id == 70 or form.to_scene_id == 18 then
    show_msgbox(form, "ui_changjkaifang_1")
    clear_form_info(form)
    return
  end
  if form.from_scene_id == form.to_scene_id then
    form.btn_horse.Enabled = false
    form.btn_carriage.Enabled = false
    return
  end
  local map_query = nx_value("MapQuery")
  if not nx_is_valid(map_query) then
    return
  end
  local world_scene_list_str = world_scene_list[form.to_scene_id]
  if world_scene_list_str == nil then
    show_msgbox(form, "ui_changjkaifang")
    clear_form_info(form)
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return
  end
  if form.to_scene_id == SchoolExtinct:GetExtinctSchoolSceneId() then
    form_error(form, "sys_wywl_mm_ct_04")
    return
  end
  if nx_string(form.to_scene_id) == "769" then
    form_error(form, "ui_form_trans_mingjiao")
    return
  end
  if nx_string(form.to_scene_id) == "832" then
    form_error(form, "ui_form_trans_tianshan")
    return
  end
  local res = form.trans_tool_npc_manager:GetActiveWorldTransPathList(form.visual_player, nx_string(form.from_scene_id), nx_string(form.to_scene_id))
  local horse_cost_res = form.trans_tool_npc_manager:GetWorldTransHorseCostList(form.visual_player, nx_string(form.from_scene_id), nx_string(form.to_scene_id))
  local count = table.getn(res)
  local horse_cost_count = table.getn(horse_cost_res)
  if count <= 0 then
    show_msgbox(form, "ui_weikt")
    return
  end
  form.money = nx_string(res[1])
  form.gold = nx_string(horse_cost_res[1])
  path_scene_list = {}
  for i = 2, count do
    path_scene_list[i - 1] = nx_string(res[i])
  end
  show_path(form)
  local from = nx_widestr(get_btn_hit(path_scene_list[1]))
  local count = nx_widestr(table.getn(path_scene_list))
  local to = nx_widestr(get_btn_hit(path_scene_list[nx_number(count)]))
  local money = nx_widestr(form.money)
  local gold = nx_widestr(form.gold)
  show_info(form, from, to, count, money, gold)
  show_end(form, form.to_scene_id)
end
function on_btn_close_click(self)
  local form = self.Parent
  form:Close()
end
function on_btn_horse_click(btn_horse)
  local form = btn_horse.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_create_world_trans_tool", nx_int(SUB_CUSTOMMSG_TRANS_BY_HORSE), nx_string(form.to_scene_id))
end
function on_btn_carriage_click(btn_carriage)
  local form = btn_carriage.Parent.Parent
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_create_world_trans_tool", nx_int(SUB_CUSTOMMSG_TRANS_BY_CARRIAGE), nx_string(form.to_scene_id))
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
  local scene_name = ""
  for i = 1, item_count do
    scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if name == scene_name then
      return ini:GetSectionItemKey(0, i - 1)
    end
  end
end
function get_btn_hit(index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_trans_tool", false, false)
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
      check_scene_school_extinct(btn_scene)
    end
  end
  for i = 1, table.getn(active_scene_list) do
    local active_scene_id = active_scene_list[i]
    local btn_name = "btn_" .. active_scene_id
    local btn_scene = form.gbx_scene:Find(btn_name)
    if nx_is_valid(btn_scene) then
      btn_scene.Enabled = true
    end
  end
  form.btn_horse.Enabled = false
  form.btn_horse.Visible = false
  form.btn_carriage.Enabled = false
end
function show_path(form)
  for i = 1, table.getn(scene_path_list) do
    local path_name = scene_path_list[i]
    local label_path = form.gbx_path_down:Find(path_name)
    if nx_is_valid(btn_scene) then
      label_path.Visible = false
    end
  end
  for i = 1, table.getn(path_scene_list) - 1 do
    local from = nx_number(path_scene_list[i])
    local to = nx_number(path_scene_list[i + 1])
    if from > to then
      tmp = from
      from = to
      to = tmp
    end
    local path_name = nx_string(from) .. "_" .. nx_string(to) .. "_down"
    local label_path = form.gbx_path_down:Find(path_name)
    if nx_is_valid(label_path) then
      label_path.Visible = true
    end
  end
end
function show_info(form, from, to, count, money, gold)
  if not nx_is_valid(form) then
    return
  end
  form.btn_horse.Enabled = true
  form.btn_carriage.Enabled = true
  local from_scene = form.gbx_info:Find("qidian")
  if nx_is_valid(from_scene) then
    from_scene.Text = nx_widestr(from)
  end
  local scene_to = form.gbx_info:Find("zhongdian")
  if nx_is_valid(scene_to) then
    scene_to.Text = nx_widestr(to)
  end
  local scene_count = form.gbx_info:Find("tujing")
  if nx_is_valid(scene_count) then
    scene_count.Text = nx_widestr(count)
  end
  local scene_cost = form.gbx_info:Find("feiyong")
  local capital_module = nx_value("CapitalModule")
  if nx_is_valid(scene_cost) then
    scene_cost.HtmlText = nx_widestr(capital_module:GetFormatCapitalHtml(1, nx_number(money)))
  end
end
function clear_form_info(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(scene_path_list) do
    local path_name = scene_path_list[i]
    local label_path = form.gbx_path_down:Find(path_name)
    if nx_is_valid(label_path) then
      label_path.Visible = false
    end
  end
  local from_scene = form.gbx_info:Find("qidian")
  if nx_is_valid(from_scene) then
    from_scene.Text = nx_widestr("")
  end
  local scene_to = form.gbx_info:Find("zhongdian")
  if nx_is_valid(scene_to) then
    scene_to.Text = nx_widestr("")
  end
  local scene_count = form.gbx_info:Find("tujing")
  if nx_is_valid(scene_count) then
    scene_count.Text = nx_widestr("")
  end
  local scene_cost = form.gbx_info:Find("feiyong")
  if nx_is_valid(scene_cost) then
    scene_cost.HtmlText = nx_widestr("")
  end
  form.lbl_end.Visible = false
  form.to_scene_id = 0
  form.btn_carriage.Enabled = false
end
function change_form_size()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_world_trans_tool", false, false)
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
function show_msgbox(form, msg_id)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  dialog.info_label.Text = util_text(msg_id)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
end
function form_error(form, text)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  local info = gui.TextManager:GetFormatText(text)
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), nx_int(-1))
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  dialog.Left = form.Left + (form.Width - dialog.Width) / 2
  dialog.Top = form.Top + (form.Height - dialog.Height) / 2
  dialog:ShowModal()
end
function on_rec_test_server(...)
  local form = nx_value("form_stage_main\\form_world_trans_tool")
  if not nx_is_valid(form) or table.getn(arg) < 1 then
    return
  end
  form.btn_horse.Visible = arg[1] == 1
end
function check_scene_school_extinct(btn)
  if not nx_is_valid(btn) then
    return
  end
  local SchoolExtinct = nx_value("SchoolExtinct")
  if not nx_is_valid(SchoolExtinct) then
    return
  end
  local scene_id = nx_number(btn.DataSource)
  if scene_id == SchoolExtinct:GetExtinctSchoolSceneId() then
    btn.NormalImage = "gui\\map\\yizhan\\ditu-maoxianqu-01.png"
    btn.FocusImage = "gui\\map\\yizhan\\ditu-maoxianqu-02.png"
  end
end
