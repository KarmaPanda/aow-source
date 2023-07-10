require("util_gui")
require("util_functions")
require("form_stage_main\\form_relation\\form_world_city_kapai_trace")
local FORM_KAPAI = "form_stage_main\\form_origin\\form_kapai"
local ENCHOU_TYPE = {
  [1] = {
    101,
    102,
    103,
    104,
    105,
    106
  },
  [2] = {
    201,
    202,
    203
  },
  [3] = {
    301,
    302,
    303
  },
  [4] = {401, 402}
}
local relation_name = {
  [1] = "ui_sns_world_tips_zy",
  [2] = "ui_sns_world_tips_hy",
  [3] = "ui_sns_world_tips_gz",
  [4] = "ui_sns_world_tips_ym",
  [5] = "ui_sns_world_tips_xh",
  [6] = "ui_sns_world_tips_hq",
  [7] = "ui_sns_world_tips_pd",
  [8] = "ui_sns_world_tips_fg",
  [9] = "ui_sns_world_tips_ty",
  [10] = "ui_sns_world_tips_zw"
}
local WORLD_MODE = 0
local CITY_MODE = 1
function on_main_form_init(self)
  self.Fixed = true
  self.scene_mode = WORLD_MODE
  self.scene_id = -1
end
function on_main_form_open(self)
  self.groupbox_degree.Visible = false
  self.gb_degree_tips.Visible = false
  self.lbl_green.Visible = false
  self.lbl_line.Visible = false
  self.groupbox_1.Visible = false
  self.btn_trace.Visible = false
  change_form_size()
  init_tree_ec()
  init_world_city_button(self)
end
function on_main_form_close(self)
  local form_npc = nx_value("form_stage_main\\form_relation\\form_npc_info")
  if nx_is_valid(form_npc) then
    nx_destroy(form_npc)
  end
  local form_karma = nx_value("form_stage_main\\form_relation\\super_book_trace\\form_npc_karma")
  if nx_is_valid(form_karma) then
    nx_destroy(form_karma)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local child_table_scene = self.groupbox_scene:GetChildControlList()
  for i = 1, table.getn(child_table_scene) do
    if nx_is_valid(child_table_scene[i]) then
      child_table_scene[i]:Close()
      self.groupbox_scene:Remove(child_table_scene[i])
    end
  end
  local child_table = self.groupbox_world:GetChildControlList()
  for i = 1, table.getn(child_table) do
    if nx_is_valid(child_table[i]) then
      child_table[i]:Close()
      self.groupbox_world:Remove(child_table[i])
    end
  end
  local child_table_scene_relation = self.groupbox_scene_relation:GetChildControlList()
  for i = 1, table.getn(child_table) do
    if nx_is_valid(child_table[i]) then
      gui:Delete(child_table[i])
      self.groupbox_scene_relation:Remove(child_table[i])
    end
  end
  nx_execute("form_stage_main\\form_relation\\form_world_city_npc_info", "close_form_when_enter_world")
  nx_destroy(self)
end
function show_form(flag)
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  if flag then
    local form_world = nx_value("form_stage_main\\form_relation\\form_relation_world")
    if not nx_is_valid(form_world) then
      local form_world = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_world", true, false)
      if nx_is_valid(form_world) then
        form:Add(form_world)
        set_title()
      end
    else
      form_world:Show()
      form_world.Visible = true
      set_title()
    end
  else
    local form_world = nx_value("form_stage_main\\form_relation\\form_relation_world")
    if nx_is_valid(form_world) then
      form_world.Visible = false
    end
  end
end
function set_title(scene_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local name = client_player:QueryProp("Name")
  local gui = nx_value("gui")
  gui.TextManager:Format_SetIDName("ui_sns_backbutton1")
  gui.TextManager:Format_AddParam(name)
  local text1 = gui.TextManager:Format_GetText()
  gui.TextManager:Format_SetIDName("ui_sns_backbutton96")
  local text2 = gui.TextManager:Format_GetText()
  local form = nx_value("form_stage_main\\form_relationship")
  if nx_is_valid(form) then
    form.mltbox_title:Clear()
    if scene_id == nil then
      form.mltbox_title:AddHtmlText(nx_widestr(text1 .. text2), -1)
    else
      gui.TextManager:Format_SetIDName("ui_sns_scene_" .. nx_string(scene_id))
      local text3 = gui.TextManager:Format_GetText()
      form.mltbox_title:AddHtmlText(nx_widestr(text1 .. text2 .. text3), -1)
    end
  end
  form.cur_scene_id = nx_int(scene_id)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_relationship")
  if not nx_is_valid(form) then
    return
  end
  local form_world = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_world", true, false)
  if nx_is_valid(form_world) then
    form_world.Left = 0
    form_world.Top = 0
    form_world.Width = form.Width
    form_world.Height = form.Height - form.groupbox_rbtn.Height
    form_world.groupbox_world.Width = form_world.Width
    form_world.groupbox_world.Height = form_world.Height
    form_world.groupbox_scene.Width = form_world.Width
    form_world.groupbox_scene.Height = form_world.Height
    form_world.groupbox_scene_relation.Width = form_world.Width
    form_world.groupbox_scene_relation.Height = form_world.Height
  end
end
function show_tree_ec(flag)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form) then
    return
  end
  form.tree_ec.Visible = flag
  form.groupbox_filter.Visible = not flag
  show_hide_kapai_trace(form, flag)
end
function init_tree_ec()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form) then
    return
  end
  local root = form.tree_ec.RootNode
  if not nx_is_valid(root) then
    root = form.tree_ec:CreateRootNode(nx_widestr(""))
  end
  root.id = -1
  for i, val in ipairs(ENCHOU_TYPE) do
    create_sub_tree(root, i)
  end
  root:ExpandAll()
end
function create_sub_tree(root, id)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText("ECTypeName_" .. nx_string(id)))
  local node = root:CreateNode(text)
  set_main_node_style(node)
  node.id = id
  for _, val in ipairs(ENCHOU_TYPE[id]) do
    local text = nx_widestr(gui.TextManager:GetText("ECName_" .. nx_string(val)))
    local sub = node:CreateNode(text)
    set_sub_node_style(sub)
    sub.id = val
    sub.parent = id
  end
end
function set_main_node_style(node)
  node.Font = "font_btn"
  node.TextOffsetY = 4
  node.ItemHeight = 26
  node.NodeBackImage = "gui\\special\\sns_new\\tree_2_out.png"
  node.NodeFocusImage = "gui\\special\\sns_new\\tree_2_on.png"
  node.NodeSelectImage = "gui\\special\\sns_new\\tree_2_on.png"
  node.ExpandCloseOffsetX = 130
  node.ExpandCloseOffsetY = 8
  node.NodeOffsetY = 3
end
function set_sub_node_style(node)
  node.Font = "font_text"
  node.NodeImageOffsetX = 30
  node.TextOffsetX = 10
  node.TextOffsetY = 2
  node.NodeFocusImage = "gui\\special\\sns_new\\tree_3_on.png"
  node.NodeSelectImage = "gui\\special\\sns_new\\tree_3_on.png"
end
function on_tree_ec_left_click(tree, node)
  if nx_number(node.Level) ~= nx_number(2) then
    return
  end
  util_show_form("form_stage_main\\form_relation\\form_relation_enchou", true)
  local gui = nx_value("gui")
  gui.Desktop:ToFront(nx_value("form_stage_main\\form_relation\\form_relation_enchou"))
  nx_execute("form_stage_main\\form_relation\\form_relation_enchou", "open_form_by_type", node.parent, node.id)
end
function on_btn_ec_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_enchou", true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(nx_value("form_stage_main\\form_relation\\form_relation_enchou"))
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "scene_id") or not nx_find_custom(form, "scene_mode") then
    return
  end
  if CITY_MODE == form.scene_mode then
    local form_ec = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
    if not nx_is_valid(form_ec) then
      return
    end
    nx_execute("form_stage_main\\form_relation\\form_relation_enchou", "open_form_by_type", 5, -1)
    local form_ec_npc_list = nx_value("form_stage_main\\form_relation\\form_enchou_npc_list")
    if not nx_is_valid(form_ec_npc_list) then
      return
    end
    if not nx_find_custom(form_ec_npc_list, "scene_id") then
      return
    end
    form_ec_npc_list.scene_id = form.scene_id
    nx_execute("form_stage_main\\form_relation\\form_enchou_npc_list", "set_combobox_show", form_ec_npc_list)
  end
end
function show_world_city_button(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_world", true, false)
    if not nx_is_valid(form) then
      return
    end
  end
  local isupdate = arg[1]
  local scene_id = arg[2]
  local city_index = arg[3]
  local city_btn = form:Find(nx_string("btn_" .. nx_string(city_index)))
  if not nx_is_valid(city_btn) then
    return
  end
  city_btn.scene_id = scene_id
  city_btn.Left = nx_number(arg[4]) - city_btn.Width / 2
  city_btn.Top = nx_number(arg[5]) - city_btn.Height / 2
  if not is_has_relation_npc(scene_id) then
    city_btn.Enabled = false
  end
  city_btn.Visible = true
  if nx_execute("form_stage_main\\form_origin\\form_kapai", "is_open_degree_kapai") then
    local degree_left, degree_top = get_gb_degree_pos(city_btn, city_index)
    show_degree_info(form, scene_id, degree_left, degree_top)
    show_degree_type4(form)
    form:ToFront(form.groupbox_world)
  end
  if not nx_find_custom(form, "scene_id") or not nx_find_custom(form, "scene_mode") then
    return
  end
  form.scene_mode = WORLD_MODE
  form.scene_id = -1
end
function init_world_city_button(form)
  local city_list = get_world_city_button_list(form)
  for i = 1, table.getn(city_list) do
    city_list[i].Visible = false
    city_list[i].scene_id = 0
  end
end
function get_world_city_tips(btn)
  if not btn.Visible then
    return
  end
  if not nx_find_custom(btn, "scene_id") then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local item_query = nx_value("ItemQuery")
  local game_client = nx_value("game_client")
  if not (nx_is_valid(gui) and nx_is_valid(item_query)) or not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local x = btn.Left + btn.Width
  local y = btn.Top + btn.Height
  if not btn.Enabled then
    nx_execute("tips_game", "show_text_tip", nx_widestr(gui.TextManager:GetText("tips_sns_world_none")), x, y)
  else
    local relation_list = get_npc_relation_list(btn.scene_id)
    nx_execute("tips_game", "ShowLeftPhoto3DTips", x, y, btn.DataSource, btn.scene_id, true, relation_list)
  end
  return
end
function hide_world_city_tips(btn)
  nx_execute("tips_game", "hide_tip")
end
function is_has_relation_npc(scene_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local rnr_rows = client_player:GetRecordRows("rec_npc_relation")
  local ra_rows = client_player:GetRecordRows("rec_npc_attention")
  if nx_int(0) == nx_int(rnr_rows) and nx_int(0) == nx_int(ra_rows) then
    return false
  end
  if nx_int(rnr_rows) ~= nx_int(0) then
    for i = 0, rnr_rows do
      local tem_scene_id = client_player:QueryRecord("rec_npc_relation", i, 1)
      if nx_number(scene_id) == nx_number(tem_scene_id) then
        return true
      end
    end
  end
  if nx_int(ra_rows) ~= nx_int(0) then
    for i = 0, ra_rows do
      local tem_scene_id = client_player:QueryRecord("rec_npc_attention", i, 1)
      if nx_number(scene_id) == nx_number(tem_scene_id) then
        return true
      end
    end
  end
  return false
end
function get_npc_relation_list(scene_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local rnr_rows = client_player:GetRecordRows("rec_npc_relation")
  local ra_rows = client_player:GetRecordRows("rec_npc_attention")
  if nx_int(0) == nx_int(rnr_rows) and nx_int(0) == nx_int(ra_rows) then
    return ""
  end
  local attention_count = 0
  local friend_count = 0
  local buddy_count = 0
  local yangmu_count = 0
  local xihuan_count = 0
  local haoqi_count = 0
  local pingdan_count = 0
  local fangan_count = 0
  local taoyan_count = 0
  local zengwu_count = 0
  if nx_int(ra_rows) ~= nx_int(0) then
    for i = 0, ra_rows do
      local tem_scene_id = client_player:QueryRecord("rec_npc_attention", i, 1)
      if nx_number(scene_id) == nx_number(tem_scene_id) then
        attention_count = attention_count + 1
        if nx_int(rnr_rows) ~= nx_int(0) then
          local att_npc_id = client_player:QueryRecord("rec_npc_attention", i, 0)
          local is_in_relation = false
          for j = 0, rnr_rows do
            local rel_npc_id = client_player:QueryRecord("rec_npc_relation", j, 0)
            local rel_npc_scene = client_player:QueryRecord("rec_npc_relation", j, 1)
            if nx_number(rel_npc_scene) == nx_number(tem_scene_id) and nx_string(rel_npc_id) == nx_string(att_npc_id) then
              is_in_relation = true
              break
            end
          end
          if not is_in_relation then
            pingdan_count = pingdan_count + 1
          end
        end
      end
    end
  end
  if nx_int(ra_rows) ~= nx_int(0) and nx_int(rnr_rows) == nx_int(0) then
    for i = 0, ra_rows do
      local tem_scene_id = client_player:QueryRecord("rec_npc_attention", i, 1)
      if nx_number(scene_id) == nx_number(tem_scene_id) then
        pingdan_count = pingdan_count + 1
      end
    end
  end
  if nx_int(rnr_rows) ~= nx_int(0) then
    for i = 0, rnr_rows do
      local tem_scene_id = client_player:QueryRecord("rec_npc_relation", i, 1)
      if nx_number(scene_id) == nx_number(tem_scene_id) then
        local relation_type = client_player:QueryRecord("rec_npc_relation", i, 3)
        local relation_value = client_player:QueryRecord("rec_npc_relation", i, 2)
        if nx_number(0) == nx_number(relation_type) then
          friend_count = friend_count + 1
        elseif nx_number(1) == nx_number(relation_type) then
          buddy_count = buddy_count + 1
        end
        if nx_number(0) == nx_number(relation_value) then
          pingdan_count = pingdan_count + 1
        else
          local ini = nx_execute("util_functions", "get_ini", "share\\sns\\msg_config.ini")
          if nx_is_valid(ini) then
            local sec_index = ini:FindSectionIndex("Karma")
            if nx_number(sec_index) < nx_number(0) then
              sec_index = "0"
            end
            local GroupMsgData = ini:GetItemValueList(sec_index, nx_string("r"))
            for m = 1, nx_number(table.getn(GroupMsgData)) do
              local stepData = util_split_string(GroupMsgData[m], ",")
              if nx_int(stepData[1]) <= nx_int(relation_value) and nx_int(relation_value) <= nx_int(stepData[2]) then
                if nx_int(1) == nx_int(m) then
                  zengwu_count = zengwu_count + 1
                elseif nx_int(2) == nx_int(m) then
                  taoyan_count = taoyan_count + 1
                elseif nx_int(3) == nx_int(m) then
                  fangan_count = fangan_count + 1
                elseif nx_int(5) == nx_int(m) then
                  haoqi_count = haoqi_count + 1
                elseif nx_int(6) == nx_int(m) then
                  xihuan_count = xihuan_count + 1
                elseif nx_int(7) == nx_int(m) then
                  yangmu_count = yangmu_count + 1
                end
              end
            end
          end
        end
      end
    end
  end
  return buddy_count .. "," .. friend_count .. "," .. attention_count .. "," .. yangmu_count .. "," .. xihuan_count .. "," .. haoqi_count .. "," .. pingdan_count .. "," .. fangan_count .. "," .. taoyan_count .. "," .. zengwu_count
end
function on_btn_city_click(btn)
  if not btn.Enabled or not btn.Visible then
    return
  end
  if not nx_find_custom(btn, "scene_id") then
    return
  end
  local SnsWorldShape = nx_value("SnsWorldShape")
  if not nx_is_valid(SnsWorldShape) then
    return
  end
  SnsWorldShape:ClickCityButton(btn.scene_id)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "scene_id") or not nx_find_custom(form, "scene_mode") then
    return
  end
  form.scene_mode = CITY_MODE
  form.scene_id = btn.scene_id
end
function hide_all_city_button()
  local form = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_world", true, false)
    if not nx_is_valid(form) then
      return
    end
  end
  local city_list = get_world_city_button_list(form)
  for i = 1, table.getn(city_list) do
    city_list[i].Visible = false
    if nx_find_custom(city_list[i], "scene_id") then
      hide_gb_degree_info(form, city_list[i].scene_id)
    end
  end
  hide_degree_type4(form)
end
function hide_one_city_button(...)
  local scene_id = arg[1]
  local form = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_world", true, false)
    if not nx_is_valid(form) then
      return
    end
  end
  local city_btn_list = get_world_city_button_list(form)
  for i = 1, table.getn(city_btn_list) do
    if not nx_find_custom(city_btn_list[i], "scene_id") then
      return
    end
    if nx_int(scene_id) == nx_int(city_btn_list[i].scene_id) then
      city_btn_list[i].Visible = false
      hide_gb_degree_info(form, scene_id)
      return
    end
  end
end
function get_world_city_button_list(form)
  local city_btn_list = {
    form.btn_born01,
    form.btn_born02,
    form.btn_born03,
    form.btn_born04,
    form.btn_city01,
    form.btn_city02,
    form.btn_city03,
    form.btn_city04,
    form.btn_city05,
    form.btn_scene01,
    form.btn_scene02,
    form.btn_scene03,
    form.btn_scene04,
    form.btn_scene05,
    form.btn_scene06,
    form.btn_scene07,
    form.btn_scene08,
    form.btn_scene09,
    form.btn_school01,
    form.btn_school02,
    form.btn_school03,
    form.btn_school04,
    form.btn_school05,
    form.btn_school06,
    form.btn_school07,
    form.btn_school08
  }
  return city_btn_list
end
function show_hide_kapai_trace(form, flag)
  if not nx_is_valid(form) then
    return
  end
  if not nx_execute("form_stage_main\\form_origin\\form_kapai", "is_open_degree_kapai") then
    return
  end
  if not nx_find_custom(form, "scene_id") then
    return
  end
  local form_world = nx_value("form_stage_main\\form_relation\\form_relation_world")
  if not nx_is_valid(form_world) then
    return
  end
  local form_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_city_kapai_trace", true, false)
  if flag then
    if nx_is_valid(form_trace) then
      form_trace:Close()
      form_world.btn_trace.Visible = false
    end
  elseif nx_is_valid(form_world) and nx_is_valid(form_trace) then
    form_world:Add(form_trace)
    form_world.btn_trace.Visible = true
  end
end
function show_degree_info(form, scene_id, left, top)
  local gb_info = form:Find("gb_info_" .. nx_string(scene_id))
  if not nx_is_valid(gb_info) then
    local gui = nx_value("gui")
    gb_info = gui:Create("GroupBox")
    gb_info.Name = "gb_info_" .. nx_string(scene_id)
    gb_info.Width = form.groupbox_degree.Width
    gb_info.Height = form.groupbox_degree.Height
    gb_info.NoFrame = form.groupbox_degree.NoFrame
    gb_info.BackColor = "0,0,0,0"
    form:Add(gb_info)
    for i = 1, 3 do
      local form_btn_type = form.groupbox_degree:Find("btn_type_" .. nx_string(i))
      if nx_is_valid(form_btn_type) then
        local btn_type = gui:Create("Button")
        btn_type.Name = "btn_type_" .. nx_string(i) .. "_" .. nx_string(scene_id)
        btn_type.Left = form_btn_type.Left
        btn_type.Top = form_btn_type.Top
        btn_type.Width = form_btn_type.Width
        btn_type.Height = form_btn_type.Height
        btn_type.NormalImage = form_btn_type.NormalImage
        btn_type.FocusImage = form_btn_type.FocusImage
        btn_type.PushImage = form_btn_type.PushImage
        btn_type.DrawMode = form_btn_type.DrawMode
        nx_bind_script(btn_type, nx_current())
        nx_callback(btn_type, "on_click", "on_btn_type_click")
        nx_callback(btn_type, "on_get_capture", "on_btn_type_get_capture")
        nx_callback(btn_type, "on_lost_capture", "on_btn_type_lost_capture")
        gb_info:Add(btn_type)
      end
      local form_lbl_num = form.groupbox_degree:Find("lbl_num_" .. nx_string(i))
      if nx_is_valid(form_lbl_num) then
        local lbl_num = gui:Create("Label")
        lbl_num.Name = "lbl_num_" .. nx_string(i) .. "_" .. nx_string(scene_id)
        lbl_num.Left = form_lbl_num.Left
        lbl_num.Top = form_lbl_num.Top
        lbl_num.Width = form_lbl_num.Width
        lbl_num.Height = form_lbl_num.Height
        lbl_num.Font = form_lbl_num.Font
        lbl_num.ForeColor = form_lbl_num.ForeColor
        lbl_num.Align = form_lbl_num.Align
        lbl_num.Transparent = false
        lbl_num.NoFrame = form_lbl_num.NoFrame
        lbl_num.BackImage = form_lbl_num.BackImage
        lbl_num.DrawMode = form_lbl_num.DrawMode
        nx_bind_script(lbl_num, nx_current())
        nx_callback(lbl_num, "on_get_capture", "on_btn_type_get_capture")
        nx_callback(lbl_num, "on_lost_capture", "on_btn_type_lost_capture")
        gb_info:Add(lbl_num)
      end
    end
  end
  local table_temp = {}
  for i = 1, 3 do
    local num, max_num = get_degree_num_info(scene_id, i)
    local btn_type = gb_info:Find("btn_type_" .. nx_string(i) .. "_" .. nx_string(scene_id))
    local lbl_num = gb_info:Find("lbl_num_" .. nx_string(i) .. "_" .. nx_string(scene_id))
    if nx_is_valid(btn_type) and nx_is_valid(lbl_num) then
      btn_type.Visible = false
      lbl_num.Visible = false
      if max_num ~= 0 then
        btn_type.Visible = true
        lbl_num.Visible = true
        lbl_num.Text = nx_widestr(num) .. nx_widestr("/") .. nx_widestr(max_num)
        btn_type.Top = (btn_type.Height - 4) * (i - 1)
        lbl_num.Top = btn_type.Top + 3
        table.insert(table_temp, i)
      end
    end
  end
  local count_temp = table.getn(table_temp)
  if count_temp == 1 then
    local btn_type = gb_info:Find("btn_type_" .. nx_string(table_temp[1]) .. "_" .. nx_string(scene_id))
    local lbl_num = gb_info:Find("lbl_num_" .. nx_string(table_temp[1]) .. "_" .. nx_string(scene_id))
    if nx_is_valid(btn_type) and nx_is_valid(lbl_num) then
      btn_type.Top = btn_type.Height - 4
      lbl_num.Top = btn_type.Top + 3
    end
  elseif count_temp == 2 then
    local btn_type = gb_info:Find("btn_type_" .. nx_string(table_temp[1]) .. "_" .. nx_string(scene_id))
    local lbl_num = gb_info:Find("lbl_num_" .. nx_string(table_temp[1]) .. "_" .. nx_string(scene_id))
    if nx_is_valid(btn_type) and nx_is_valid(lbl_num) then
      btn_type.Top = (btn_type.Height - 4) / 2
      lbl_num.Top = btn_type.Top + 3
    end
    local btn_type = gb_info:Find("btn_type_" .. nx_string(table_temp[2]) .. "_" .. nx_string(scene_id))
    local lbl_num = gb_info:Find("lbl_num_" .. nx_string(table_temp[2]) .. "_" .. nx_string(scene_id))
    if nx_is_valid(btn_type) and nx_is_valid(lbl_num) then
      btn_type.Top = btn_type.Height - 4 + (btn_type.Height - 4) / 2
      lbl_num.Top = btn_type.Top + 3
    end
  end
  gb_info.Left = left
  gb_info.Top = top - 8
  gb_info.Visible = true
  return
end
function get_gb_degree_pos(city_btn, city_index)
  local left = city_btn.Left + 75
  local top = city_btn.Top + 10
  local ini = nx_execute("util_functions", "get_ini", "share\\Karma\\degree_pos.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(nx_string(city_index))
    if 0 <= index then
      local left_offset = ini:ReadFloat(index, "left_offset", 0)
      local top_offset = ini:ReadFloat(index, "top_offset", 0)
      left = city_btn.Left + left_offset
      top = city_btn.Top + top_offset
    end
  end
  return left, top
end
function get_degree_num_info(scene_id, degree_type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0, 0
  end
  local kapai_manager = nx_value("Kapai")
  if not nx_is_valid(kapai_manager) then
    return 0, 0
  end
  local num = 0
  local max_num = 0
  local row = client_player:GetRecordRows("Origin_Kapai")
  for i = 0, row - 1 do
    local kapai_id = client_player:QueryRecord("Origin_Kapai", i, 0)
    local sub_kapai_id = client_player:QueryRecord("Origin_Kapai", i, 1)
    local kapai_type = client_player:QueryRecord("Origin_Kapai", i, 2)
    local kapai_state = client_player:QueryRecord("Origin_Kapai", i, 3)
    if nx_number(degree_type) == nx_number(kapai_type) and check_kapai_scene(kapai_id, scene_id) then
      max_num = max_num + 1
      if nx_number(kapai_state) == nx_number(3) then
        num = num + 1
      end
    end
  end
  return num, max_num
end
function on_btn_degree_click(btn)
  local form = util_show_form(FORM_KAPAI, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_type_click(btn)
  local res = util_split_string(btn.Name, "_")
  local degree_type = res[3]
  local form_kapai = util_auto_show_hide_form(FORM_KAPAI)
  if not nx_is_valid(form_kapai) then
    return
  end
  local rbtn = form_kapai.groupbox_tab:Find("rbtn_type_" .. nx_string(degree_type))
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
end
function on_btn_type_get_capture(btn)
  local res = util_split_string(btn.Name, "_")
  local degree_type = res[3]
  local scene_id = res[4]
  local form = btn.ParentForm
  add_degree_tips(form, scene_id, degree_type)
  form.gb_degree_tips.Left = btn.AbsLeft + btn.Width
  form.gb_degree_tips.Top = btn.AbsTop + 20
  form.gb_degree_tips.Visible = true
  form:ToFront(form.gb_degree_tips)
end
function on_btn_type_lost_capture(btn)
  local res = util_split_string(btn.Name, "_")
  local degree_type = res[2]
  local scene_id = res[3]
  local form = btn.ParentForm
  form.gb_degree_tips.Visible = false
end
function hide_gb_degree_info(form, scene_id)
  local gb_info = form:Find("gb_info_" .. nx_string(scene_id))
  if not nx_is_valid(gb_info) then
    return
  end
  gb_info.Visible = false
end
function add_degree_tips(form, scene_id, degree_type)
  local num, max_num = get_degree_num_info(scene_id, degree_type)
  form.lbl_scene.Text = util_text("ui_scene_" .. nx_string(scene_id)) .. nx_widestr("(") .. nx_widestr(num) .. nx_widestr("/") .. nx_widestr(max_num) .. nx_widestr(")")
  form.lbl_image.BackImage = "gui\\language\\ChineseS\\prestige\\icon_type" .. degree_type .. ".png"
  form.lbl_type.Text = util_text("type_prestige_" .. nx_string(degree_type))
  local table_kapai = get_scene_kapai_info(scene_id, degree_type)
  if table_kapai == nil then
    return
  end
  local kapai_num = table.getn(table_kapai)
  if nx_int(kapai_num) ~= nx_int(nx_int(nx_int(kapai_num) / nx_int(3)) * nx_int(3)) then
    return
  end
  local gui = nx_value("gui")
  form.groupbox_kapai:DeleteAll()
  form.groupbox_kapai.Height = 0
  local index = 0
  for i = 1, kapai_num, 3 do
    local kapai_name = nx_widestr(table_kapai[i])
    local kapai_state = nx_int(table_kapai[i + 1])
    local lbl_kapai = gui:Create("Label")
    lbl_kapai.Name = "lbl_kapai_" .. nx_string(index)
    lbl_kapai.Width = form.lbl_green.Width
    lbl_kapai.Height = form.lbl_green.Height
    lbl_kapai.Left = form.lbl_green.Left
    lbl_kapai.Top = form.lbl_green.Height * index
    lbl_kapai.Font = form.lbl_green.Font
    lbl_kapai.ForeColor = get_kapai_color(kapai_state)
    if nx_number(kapai_state) == nx_number(0) then
      lbl_kapai.ForeColor = "255,128,101,74"
    end
    lbl_kapai.Align = form.lbl_green.Align
    lbl_kapai.NoFrame = form.lbl_green.NoFrame
    lbl_kapai.Text = kapai_name
    form.groupbox_kapai:Add(lbl_kapai)
    local lbl_kapai_line = gui:Create("Label")
    lbl_kapai_line.Name = "lbl_kapai_line_" .. nx_string(index)
    lbl_kapai_line.Width = form.lbl_line.Width
    lbl_kapai_line.Height = form.lbl_line.Height
    lbl_kapai_line.Left = form.lbl_line.Left
    lbl_kapai_line.Top = lbl_kapai.Top + lbl_kapai.Height - 4
    lbl_kapai_line.BackImage = form.lbl_line.BackImage
    form.groupbox_kapai:Add(lbl_kapai_line)
    index = index + 1
    form.groupbox_kapai.Height = lbl_kapai_line.Top + lbl_kapai_line.Height + 3
  end
  form.lbl_back.Height = form.groupbox_kapai.Top - form.lbl_back.Top + form.groupbox_kapai.Height + 4
  form.gb_degree_tips.Height = form.groupbox_kapai.Top + form.groupbox_kapai.Height + 5
end
function on_btn_trace_click(btn)
  local form_trace = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_world_city_kapai_trace", true, false)
  if not nx_is_valid(form_trace) then
    return
  end
  if form_trace.Visible then
    form_trace.Visible = false
  else
    form_trace.Visible = true
  end
end
function show_degree_type4(form)
  if not nx_is_valid(form) then
    return
  end
  local info = {
    {
      1001,
      "btn_born01",
      -77,
      306
    },
    {
      1002,
      "btn_born02",
      200,
      -68
    },
    {
      1003,
      "btn_born03",
      -192,
      -20
    },
    {
      1004,
      "btn_born04",
      -228,
      136
    }
  }
  for i = 1, 4 do
    local scene_id = info[i][1]
    local gb = form:Find("gb_type_4_" .. nx_string(scene_id))
    if not nx_is_valid(gb) then
      local gui = nx_value("gui")
      gb = gui:Create("GroupBox")
      gb.Name = "gb_type_4_" .. nx_string(scene_id)
      gb.Width = form.groupbox_1.Width
      gb.Height = form.groupbox_1.Height
      gb.NoFrame = form.groupbox_1.NoFrame
      gb.BackColor = form.groupbox_1.BackColor
      form:Add(gb)
      local btn_type = gui:Create("Button")
      btn_type.Name = "btn_type_4_" .. nx_string(scene_id)
      btn_type.Left = form.btn_type4.Left
      btn_type.Top = form.btn_type4.Top
      btn_type.Width = form.btn_type4.Width
      btn_type.Height = form.btn_type4.Height
      btn_type.NormalImage = form.btn_type4.NormalImage
      btn_type.FocusImage = form.btn_type4.FocusImage
      btn_type.PushImage = form.btn_type4.PushImage
      btn_type.DrawMode = form.btn_type4.DrawMode
      nx_bind_script(btn_type, nx_current())
      nx_callback(btn_type, "on_click", "on_btn_type_click")
      nx_callback(btn_type, "on_get_capture", "on_btn_type_get_capture")
      nx_callback(btn_type, "on_lost_capture", "on_btn_type_lost_capture")
      gb:Add(btn_type)
      local lbl_num = gui:Create("Label")
      lbl_num.Name = "lbl_num_4_" .. nx_string(scene_id)
      lbl_num.Left = form.lbl_num4.Left
      lbl_num.Top = form.lbl_num4.Top
      lbl_num.Width = form.lbl_num4.Width
      lbl_num.Height = form.lbl_num4.Height
      lbl_num.Font = form.lbl_num4.Font
      lbl_num.ForeColor = form.lbl_num4.ForeColor
      lbl_num.Align = form.lbl_num4.Align
      lbl_num.Transparent = false
      lbl_num.NoFrame = form.lbl_num4.NoFrame
      lbl_num.BackImage = form.lbl_num4.BackImage
      lbl_num.DrawMode = form.lbl_num4.DrawMode
      nx_bind_script(lbl_num, nx_current())
      nx_callback(lbl_num, "on_get_capture", "on_btn_type_get_capture")
      nx_callback(lbl_num, "on_lost_capture", "on_btn_type_lost_capture")
      gb:Add(lbl_num)
      form:Add(gb)
    end
    local btn = form:Find(info[i][2])
    if nx_is_valid(btn) then
      gb.Left = btn.Left + info[i][3]
      gb.Top = btn.Top + info[i][4]
    end
    local lbl_num = gb:Find("lbl_num_4_" .. nx_string(scene_id))
    if nx_is_valid(lbl_num) then
      local num, max_num = get_degree_num_info(scene_id, 4)
      lbl_num.Text = nx_widestr(num) .. nx_widestr("/") .. nx_widestr(max_num)
    end
    gb.Visible = true
  end
end
function hide_degree_type4(form)
  if not nx_is_valid(form) then
    return
  end
  local info = {
    1001,
    1002,
    1003,
    1004
  }
  for i = 1, 4 do
    local gb = form:Find("gb_type_4_" .. nx_string(info[i]))
    if nx_is_valid(gb) then
      gb.Visible = false
    end
  end
end
