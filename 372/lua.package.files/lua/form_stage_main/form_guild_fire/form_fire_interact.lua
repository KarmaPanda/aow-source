require("custom_sender")
require("util_gui")
require("util_functions")
local map_res = "gui\\guild\\preview\\"
local map_res_pic = "gui\\special\\tvt\\fanghuo\\"
local control_list = {
  ["5_0"] = {
    bt_name = "btn_ZT",
    lb_name = "lbl_ZT",
    pic_name = {
      [0] = "zhengting_yulantu_00",
      [1] = "zhengting_yulantu_01",
      [2] = "zhengting_yulantu_02",
      [3] = "zhengting_yulantu_03",
      [4] = "zhengting_yulantu_04",
      [5] = "zhengting_yulantu_05"
    },
    main_type = 5,
    sub_type = 0
  },
  ["3_0"] = {
    bt_name = "btn_YST",
    lb_name = "lbl_YST",
    pic_name = {
      [0] = "yishiting_yulantu_00",
      [1] = "yishiting_yulantu_01",
      [2] = "yishiting_yulantu_02",
      [3] = "yishiting_yulantu_03",
      [4] = "yishiting_yulantu_04",
      [5] = "yishiting_yulantu_05"
    },
    main_type = 3,
    sub_type = 0
  },
  ["1_2"] = {
    bt_name = "btn_LGT",
    lb_name = "lbl_LGT",
    pic_name = {
      [0] = "liangongtai_yulantu_00",
      [1] = "liangongtai_yulantu_00",
      [2] = "liangongtai_yulantu_00",
      [3] = "liangongtai_yulantu_00",
      [4] = "liangongtai_yulantu_00",
      [5] = "liangongtai_yulantu_00"
    },
    main_type = 1,
    sub_type = 2
  },
  ["1_5"] = {
    bt_name = "btn_CSY1",
    lb_name = "lbl_CSY1",
    pic_name = {
      [0] = "cangshuyuan_yulantu_00",
      [1] = "cangshuyuan_yulantu_01",
      [2] = "cangshuyuan_yulantu_02",
      [3] = "cangshuyuan_yulantu_03",
      [4] = "cangshuyuan_yulantu_04",
      [5] = "cangshuyuan_yulantu_05"
    },
    main_type = 1,
    sub_type = 5
  },
  ["1_8"] = {
    bt_name = "btn_CSY2",
    lb_name = "lbl_CSY2",
    pic_name = {
      [0] = "cangshuyuan_yulantu_00",
      [1] = "cangshuyuan_yulantu_01",
      [2] = "cangshuyuan_yulantu_02",
      [3] = "cangshuyuan_yulantu_03",
      [4] = "cangshuyuan_yulantu_04",
      [5] = "cangshuyuan_yulantu_05"
    },
    main_type = 1,
    sub_type = 8
  },
  ["6_0"] = {
    bt_name = "btn_CK",
    lb_name = "lbl_CK",
    pic_name = {
      [0] = "cangku_yulantu_00",
      [1] = "cangku_yulantu_01",
      [2] = "cangku_yulantu_02",
      [3] = "cangku_yulantu_03",
      [4] = "cangku_yulantu_04",
      [5] = "cangku_yulantu_05"
    },
    main_type = 6,
    sub_type = 0
  },
  ["8_0"] = {
    bt_name = "btn_DM",
    lb_name = "lbl_DM",
    pic_name = {
      [0] = "damen_yulantu_00",
      [1] = "damen_yulantu_01",
      [2] = "damen_yulantu_02",
      [3] = "damen_yulantu_02",
      [4] = "damen_yulantu_04",
      [5] = "damen_yulantu_05"
    },
    main_type = 8,
    sub_type = 0
  },
  ["11_0"] = {
    bt_name = "btn_JK",
    lb_name = "lbl_JK",
    pic_name = {
      [0] = "jinku_yulantu_00",
      [1] = "jinku_yulantu_01",
      [2] = "jinku_yulantu_02",
      [3] = "jinku_yulantu_03",
      [4] = "jinku_yulantu_04",
      [5] = "jinku_yulantu_05"
    },
    main_type = 11,
    sub_type = 0
  },
  ["2_0"] = {
    bt_name = "btn_JYT",
    lb_name = "lbl_JYT",
    pic_name = {
      [0] = "juyitang_yulantu_00",
      [1] = "juyitang_yulantu_01",
      [2] = "juyitang_yulantu_02",
      [3] = "juyitang_yulantu_03",
      [4] = "juyitang_yulantu_04",
      [5] = "juyitang_yulantu_05"
    },
    main_type = 2,
    sub_type = 0
  },
  ["10_0"] = {
    bt_name = "btn_YWT",
    lb_name = "lbl_YWT",
    pic_name = {
      [0] = "yanwutang_yulantu_00",
      [1] = "yanwutang_yulantu_01",
      [2] = "yanwutang_yulantu_02",
      [3] = "yanwutang_yulantu_03",
      [4] = "yanwutang_yulantu_04",
      [5] = "yanwutang_yulantu_05"
    },
    main_type = 10,
    sub_type = 0
  },
  ["4_0"] = {
    bt_name = "btn_JGF",
    lb_name = "lbl_JGF",
    pic_name = {
      [0] = "jiguanfang_yulantu_00",
      [1] = "jiguanfang_yulantu_01",
      [2] = "jiguanfang_yulantu_02",
      [3] = "jiguanfang_yulantu_03",
      [4] = "jiguanfang_yulantu_04",
      [5] = "jiguanfang_yulantu_05"
    },
    main_type = 4,
    sub_type = 0
  },
  ["1_3"] = {
    bt_name = "btn_JSS",
    lb_name = "lbl_JSS",
    pic_name = {
      [0] = "jingsishi_yulantu_00",
      [1] = "jingsishi_yulantu_01",
      [2] = "jingsishi_yulantu_02",
      [3] = "jingsishi_yulantu_03",
      [4] = "jingsishi_yulantu_04",
      [5] = "jingsishi_yulantu_05"
    },
    main_type = 1,
    sub_type = 3
  },
  ["9_0"] = {
    bt_name = "btn_JBF",
    lb_name = "lbl_JBF",
    pic_name = {
      [0] = "jubaofang_yulantu_00",
      [1] = "jubaofang_yulantu_01",
      [2] = "jubaofang_yulantu_02",
      [3] = "jubaofang_yulantu_03",
      [4] = "jubaofang_yulantu_04",
      [5] = "jubaofang_yulantu_05"
    },
    main_type = 9,
    sub_type = 0
  },
  ["1_4"] = {
    bt_name = "btn_MHZ",
    lb_name = "lbl_MHZ",
    pic_name = {
      [0] = "meihuazhuang_yulantu_00",
      [1] = "meihuazhuang_yulantu_01",
      [2] = "meihuazhuang_yulantu_02",
      [3] = "meihuazhuang_yulantu_03",
      [4] = "meihuazhuang_yulantu_04",
      [5] = "meihuazhuang_yulantu_05"
    },
    main_type = 1,
    sub_type = 4
  },
  ["1_1"] = {
    bt_name = "btn_MRZ",
    lb_name = "lbl_MRZ",
    pic_name = {
      [0] = "murenzhuang_yulantu_00",
      [1] = "murenzhuang_yulantu_01",
      [2] = "murenzhuang_yulantu_02",
      [3] = "murenzhuang_yulantu_03",
      [4] = "murenzhuang_yulantu_04",
      [5] = "murenzhuang_yulantu_05"
    },
    main_type = 1,
    sub_type = 1
  },
  ["14_0"] = {
    bt_name = "btn_MP",
    lb_name = "lbl_MP",
    pic_name = {
      [0] = "mapeng_yulantu_00",
      [1] = "mapeng_yulantu_01",
      [2] = "mapeng_yulantu_02",
      [3] = "mapeng_yulantu_03",
      [4] = "mapeng_yulantu_04",
      [5] = "mapeng_yulantu_05"
    },
    main_type = 14,
    sub_type = 0
  }
}
local build_state_pic = {
  [0] = "",
  [1] = "map_ruin",
  [2] = "map_fire",
  [6] = "map_water",
  [8] = "map_mubiao",
  [9] = "map_mb_ruin",
  [10] = "map_mb_fire"
}
local build_state_lab = {
  [1] = "build_state_lab_normal",
  [2] = "build_state_lab_fire",
  [4] = "build_state_lab_cool"
}
local target_guild_node = {
  [1] = "ui_benbangzhudi",
  [2] = "ui_fanghuozhudi"
}
local level_title_table = {
  [1] = "desc_title001",
  [2] = "desc_title002",
  [3] = "desc_title003",
  [4] = "desc_title004",
  [5] = "desc_title005",
  [6] = "desc_title006",
  [7] = "desc_title007",
  [8] = "desc_title008",
  [9] = "desc_title009",
  [10] = "desc_title010",
  [11] = "desc_title011",
  [12] = "desc_title012",
  [13] = "desc_title013",
  [14] = "desc_title014",
  [15] = "desc_title015"
}
local fire_star_table = {
  [1] = "1-1",
  [2] = "1-2",
  [3] = "1-3",
  [4] = "1-4"
}
local water_star_table = {
  [1] = "2-1",
  [2] = "2-2",
  [3] = "2-3",
  [4] = "2-4"
}
local treeview_ex_table = {
  [1] = "tree_view_ex_1",
  [2] = "tree_view_ex_2"
}
local NODE_PROP = {
  [1] = {
    Font = "font_treeview",
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_1_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_1_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_1_on.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 30,
    TextOffsetY = 6
  },
  [2] = {
    Font = "font_treeview",
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_2_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_2_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_2_on.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 5,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 35,
    TextOffsetY = 6
  },
  [3] = {
    Font = "font_treeview",
    ForeColor = "255,182,177,171",
    NodeBackImage = "gui\\common\\treeview\\tree_3_out.png",
    NodeFocusImage = "gui\\common\\treeview\\tree_3_on.png",
    NodeSelectImage = "gui\\common\\treeview\\tree_3_on.png",
    ItemHeight = 30,
    NodeOffsetY = 1,
    ExpandCloseOffsetX = 0,
    ExpandCloseOffsetY = 6,
    TextOffsetX = 40,
    TextOffsetY = 6
  }
}
function form_fire_build_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  show_tree(form)
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  local domain_id = guild_fire_Mgr.DomainID
  local main_type = guild_fire_Mgr.MainType
  local sub_type = guild_fire_Mgr.SubType
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_map_info.Text = nx_widestr(gui.TextManager:GetText(nx_string(domain_id)))
  custom_req_domain_build_info(domain_id)
  custom_req_single_build_info(domain_id, main_type, sub_type)
  custom_req_self_domain_list()
  custom_req_target_domain_list()
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_mouse_in_node(self, node)
  local form = self.ParentForm
  if node == nil then
    return
  end
  node.ForeColor = "255,255,255,255"
  if node.Level == 2 and node.ImageIndex ~= 2 then
    node.ImageIndex = 0
  end
end
function on_mouse_out_node(self, node)
  local form = self.ParentForm
  if node == nil then
    return
  end
  node.ForeColor = "255,182,177,171"
  if node.Level == 2 and node.ImageIndex ~= 2 then
    node.ImageIndex = 1
  end
end
function on_left_click(self, node)
  if not nx_is_valid(node) then
    return
  end
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local domain_id = node.Mark
  if domain_id <= 0 then
    return
  end
  form.lbl_map_info.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(domain_id)))
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  guild_fire_Mgr.DomainID = domain_id
  local main_type = guild_fire_Mgr.MainType
  local sub_type = guild_fire_Mgr.SubType
  custom_req_domain_build_info(domain_id)
  custom_req_single_build_info(domain_id, main_type, sub_type)
end
function on_btn_checked_changed(btn)
  local form = btn.ParentForm
  local name = btn.Name
  if not btn.Checked then
    return
  end
  for key, list in pairs(control_list) do
    if list.bt_name == name then
      local guild_fire_Mgr = nx_value("GuildFireManager")
      if not nx_is_valid(guild_fire_Mgr) then
        return
      end
      local domain_id = guild_fire_Mgr.DomainID
      local main_type = list.main_type
      local sub_type = list.sub_type
      guild_fire_Mgr.MainType = main_type
      guild_fire_Mgr.SubType = sub_type
      custom_req_single_build_info(domain_id, main_type, sub_type)
      break
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_build_fire_state(...)
  if table.getn(arg) < 1 then
    return
  end
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  guild_fire_Mgr:InitBuildStateData()
  local count = nx_number(arg[1])
  if 0 < count and math.mod(count, 3) == 0 then
    local param_list = {}
    for i = 2, count, 3 do
      local main_type = nx_number(arg[i])
      local sub_type = nx_number(arg[i + 1])
      local state = nx_number(arg[i + 2])
      local key = nx_string(main_type) .. "_" .. nx_string(sub_type)
      table.insert(param_list, key)
      table.insert(param_list, state)
    end
    guild_fire_Mgr:SetBuildStateData(unpack(param_list))
  end
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  if not nx_is_valid(form) then
    return
  end
  update_build_fire_state(form)
end
function update_build_fire_state(form)
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  for key, list in pairs(control_list) do
    if list.lb_name ~= nil then
      local groupbox = form.groupbox_map
      local label = groupbox:Find(list.lb_name)
      if nx_is_valid(label) then
        label.BackImage = ""
      end
    end
  end
  local build_state_list = guild_fire_Mgr:GetBuildStateData()
  local count = table.getn(build_state_list)
  if math.mod(count, 2) ~= 0 then
    return
  end
  for i = 1, count, 2 do
    local key = build_state_list[i]
    local state = build_state_list[i + 1]
    if control_list[key] ~= nil then
      local groupbox = form.groupbox_map
      local label = groupbox:Find(control_list[key].lb_name)
      if nx_is_valid(label) and build_state_pic[state] ~= nil then
        local pic_name = build_state_pic[state]
        label.BackImage = pic_name
      end
    end
  end
end
function set_single_fire_state(...)
  local name = ""
  local state = 0
  local fire_left_time = 0
  local water_left_time = 0
  local build_cur_en = 0
  local build_max_en = 0
  local main_type = 0
  local sub_type = 0
  local build_level = 0
  if table.getn(arg) == 9 then
    name = nx_string(arg[1])
    state = nx_number(arg[2])
    fire_left_time = nx_number(arg[3])
    water_left_time = nx_number(arg[4])
    build_cur_en = nx_number(arg[5])
    build_max_en = nx_number(arg[6])
    main_type = nx_number(arg[7])
    sub_type = nx_number(arg[8])
    build_level = nx_number(arg[9])
  end
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  guild_fire_Mgr:SetFireBuildData(name, state, fire_left_time, water_left_time, build_cur_en, build_max_en, main_type, sub_type, build_level)
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  if not nx_is_valid(form) then
    return
  end
  update_build_info(form)
end
function update_build_info(form)
  local guild_fire_Mgr = nx_value("GuildFireManager")
  if not nx_is_valid(guild_fire_Mgr) then
    return
  end
  local build_info = guild_fire_Mgr:GetFireBuildData()
  if build_info ~= nil and table.getn(build_info) == 9 then
    local build_name = build_info[1]
    local state = build_info[2]
    local fire_left_percent = build_info[3]
    local water_left_percent = build_info[4]
    local cur_build_en = build_info[5]
    local max_build_en = build_info[6]
    local main_type = build_info[7]
    local sub_type = build_info[8]
    local build_level = build_info[9]
    local gui = nx_value("gui")
    form.lbl_build_name.Text = nx_widestr(gui.TextManager:GetText(build_name))
    if build_state_lab[state] ~= nil then
      local state_text = nx_widestr(gui.TextManager:GetText(build_state_lab[state]))
      form.lbl_build_state.Text = state_text
    end
    form.pbar_fire.Value = fire_left_percent
    form.pbar_water.Value = water_left_percent
    form.lbl_build_en.Text = nx_widestr(nx_string(cur_build_en) .. "/" .. nx_string(max_build_en))
    form.lbl_build_level.Text = nx_widestr(build_level)
    form.lbl_pic.BackImage = ""
    local key = nx_string(main_type) .. "_" .. nx_string(sub_type)
    if control_list[key] ~= nil and control_list[key].pic_name[build_level] ~= nil then
      local pic_name = control_list[key].pic_name[build_level]
      local pic_full_name = map_res .. pic_name .. ".png"
      form.lbl_pic.BackImage = pic_full_name
    end
  end
end
function rec_self_domain_info(...)
  if table.getn(arg) < 1 then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  if not nx_is_valid(form) then
    return
  end
  local self_domain_node = nx_custom(form, target_guild_node[1])
  if not nx_is_valid(self_domain_node) then
    return
  end
  for i = 1, table.getn(arg) do
    local sub_node = self_domain_node:CreateNode(nx_widestr(gui.TextManager:GetText(nx_string(arg[i]))))
    sub_node.Mark = nx_int(arg[i])
    set_node_prop(sub_node, 3)
  end
  on_expand_changed(nx_custom(form, treeview_ex_table[1]))
end
function rec_fire_domain_info(...)
  if table.getn(arg) < 1 then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  if not nx_is_valid(form) then
    return
  end
  local fire_domain_node = nx_custom(form, target_guild_node[2])
  if not nx_is_valid(fire_domain_node) then
    return
  end
  local sub_node = fire_domain_node:CreateNode(nx_widestr(gui.TextManager:GetText(nx_string(arg[1]))))
  sub_node.Mark = nx_int(arg[1])
  set_node_prop(sub_node, 3)
  on_expand_changed(nx_custom(form, treeview_ex_table[1]))
end
function show_tree(form)
  local gui = nx_value("gui")
  local guilddomain_Manager = nx_value("GuildDomainManager")
  if not nx_is_valid(guilddomain_Manager) then
    return
  end
  local Control_Top = 0
  local top_control = gui:Create("TreeViewEx")
  top_control.Name = treeview_ex_table[1]
  top_control.Left = 2
  top_control.Top = Control_Top + 3
  top_control.ItemHeight = 30
  top_control.Width = form.groupscrollbox_tree.Width - 21
  top_control.IsNoDrawRoot = false
  top_control.NodeExpandDraw = "gui\\common\\button\\btn_minimum_out.png"
  top_control.NodeCloseDraw = "gui\\common\\button\\btn_maximum_out.png"
  top_control.DrawMode = "ExpandH"
  top_control.ForeColor = "0,255,255,255"
  top_control.BackColor = "0,255,255,255"
  top_control.TreeLineColor = "0,0,0,0"
  top_control.SelectBackColor = "0,0,0,0"
  top_control.SelectForeColor = "255,240,240,240"
  top_control.TextOffsetY = 5
  top_control.NoFrame = true
  top_control.Solid = true
  nx_bind_script(top_control, nx_current())
  nx_callback(top_control, "on_expand_changed", "on_expand_changed")
  nx_callback(top_control, "on_mouse_in_node", "on_mouse_in_node")
  nx_callback(top_control, "on_mouse_out_node", "on_mouse_out_node")
  nx_callback(top_control, "on_left_click", "on_left_click")
  local topRootNode = top_control:CreateRootNode(nx_widestr(gui.TextManager:GetText("ui_mubiaozhudi")))
  set_node_prop(topRootNode, 1)
  topRootNode.Mark = -1
  nx_set_custom(form, treeview_ex_table[1], top_control)
  for n = 1, table.getn(target_guild_node) do
    local mainNode = topRootNode:CreateNode(nx_widestr(gui.TextManager:GetText(target_guild_node[n])))
    set_node_prop(mainNode, 2)
    mainNode.Mark = -1
    mainNode.Expand = true
    nx_set_custom(form, target_guild_node[n], mainNode)
  end
  topRootNode.Expand = true
  local top_control_list = top_control:GetAllNodeList()
  local top_count = table.getn(top_control_list)
  top_control.Height = top_control.ItemHeight * top_count + 10
  Control_Top = Control_Top + top_control.Height + 2
  form.groupscrollbox_tree:Add(top_control)
  local world_list = guilddomain_Manager:GetWorldNoInfo()
  local worldnum = table.getn(world_list)
  local control = gui:Create("TreeViewEx")
  control.Name = treeview_ex_table[2]
  control.Left = 2
  control.Top = Control_Top + 3
  control.ItemHeight = 30
  control.Width = form.groupscrollbox_tree.Width - 21
  control.IsNoDrawRoot = true
  control.NodeExpandDraw = "gui\\common\\button\\btn_minimum_out.png"
  control.NodeCloseDraw = "gui\\common\\button\\btn_maximum_out.png"
  control.DrawMode = "ExpandH"
  control.ForeColor = "255,255,255,255"
  control.BackColor = "0,255,255,255"
  control.TextOffsetY = 5
  control.TreeLineColor = "0,0,0,0"
  control.SelectBackColor = "0,0,0,0"
  control.SelectForeColor = "255,240,240,240"
  control.NoFrame = true
  control.Solid = true
  form.groupscrollbox_tree:Add(control)
  nx_bind_script(control, nx_current())
  nx_callback(control, "on_expand_changed", "on_expand_changed")
  nx_callback(control, "on_mouse_in_node", "on_mouse_in_node")
  nx_callback(control, "on_mouse_out_node", "on_mouse_out_node")
  nx_callback(control, "on_left_click", "on_left_click")
  local rootNode = control:CreateRootNode(nx_widestr("quyu"))
  for k = worldnum, 1, -1 do
    local scene_list = guilddomain_Manager:GetSceneInfo(world_list[k])
    local scenenum = table.getn(scene_list)
    local topNode = rootNode:CreateNode(nx_widestr(gui.TextManager:GetText("ui_tiguan_area_" .. world_list[k])))
    set_node_prop(topNode, 1)
    topNode.Mark = -1
    for m = 1, scenenum do
      local mainNode = topNode:CreateNode(nx_widestr(gui.TextManager:GetText("ui_scene_" .. scene_list[m])))
      set_node_prop(mainNode, 2)
      mainNode.Mark = -1
      local domain_list = guilddomain_Manager:GetDomainInfo(world_list[k], scene_list[m])
      local domainnum = table.getn(domain_list)
      for n = 1, domainnum do
        local node = mainNode:CreateNode(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. domain_list[n])))
        set_node_prop(node, 3)
        node.Mark = nx_int(domain_list[n])
      end
      rootNode.Expand = true
      topNode.Expand = true
      local list = control:GetAllNodeList()
      local count = table.getn(list)
      control.Height = control.ItemHeight * (count - 1) + 20
      Control_Top = Control_Top + control.Height + 2
    end
  end
  form.groupscrollbox_tree.ScrollSize = 17
  form.groupscrollbox_tree.IsEditMode = false
end
function on_expand_changed(self)
  local list = self:GetAllNodeList()
  local count = table.getn(list)
  self.Height = self.ItemHeight * count + 10
  relocate_treeview_position()
end
function relocate_treeview_position()
  local form = nx_value("form_stage_main\\form_guild_fire\\form_fire_interact")
  form.groupscrollbox_tree.IsEditMode = true
  local adjust_width = 10
  local gui = nx_value("gui")
  Control_Top = 0
  local i = 1
  for i = 1, table.getn(treeview_ex_table) do
    local ctrl_name = treeview_ex_table[i]
    if nx_is_valid(form.groupscrollbox_tree:Find(ctrl_name)) then
      local ctrl = form.groupscrollbox_tree:Find(ctrl_name)
      if nx_is_valid(ctrl) then
        ctrl.Top = Control_Top
        Control_Top = ctrl.Height + Control_Top + 2
      end
      i = i + 1
      ctrl_name = "tree_" .. nx_string(i)
    end
  end
  form.groupscrollbox_tree.ScrollSize = 17
  form.groupscrollbox_tree.IsEditMode = false
end
function set_node_prop(node, node_type)
  if not nx_is_valid(node) or node_type == nil then
    return 0
  end
  for key, value in pairs(NODE_PROP[node_type]) do
    nx_set_property(node, nx_string(key), value)
  end
end
