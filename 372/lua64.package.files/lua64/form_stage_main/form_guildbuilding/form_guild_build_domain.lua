require("util_gui")
require("custom_sender")
require("share\\client_custom_define")
local CUSTOMMSG_OPER_GUILD_DOMAIN_BUY = 0
local CUSTOMMSG_OPER_GUILD_DOMAIN_INFO = 1
local CUSTOMMSG_GET_GUILD_DOMAIN_INFO = 2
local get_part_domain_info = 0
local get_all_domain_info = 1
local selectedNode
local visible = false
local times, steps, lastName = 0, 0, 0
function auto_show_hide_form_guild_build_domain(show)
  local skin_path = "form_stage_main\\form_guildbuilding\\form_guild_build_domain"
  local form = nx_value(skin_path)
  if nx_is_valid(form) and form.Visible == show then
    return
  end
  if show == nil then
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    else
      form.Visible = not form.Visible
    end
  else
    if not nx_is_valid(form) then
      util_show_form(skin_path, true)
    end
    local form = nx_value(skin_path)
    form.Visible = show
  end
  local form = nx_value(skin_path)
  ui_show_attached_form(form)
end
function form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.tips_new = nx_call("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_domain_list", true, true)
  form:Add(form.tips_new)
  form:AddTopLayer(form.tips_new)
  form.tips_new.Visible = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.pic_map.Visible = false
  form.btn_return.Visible = false
  form.btn_buy.Visible = false
  show_tree(form)
  request_data(CUSTOMMSG_OPER_GUILD_DOMAIN_INFO)
end
function on_main_form_close(form)
  ui_destroy_attached_form(form)
  nx_destroy(form)
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
function on_btn_close_click(btn)
  auto_show_hide_form_guild_build_domain("form_stage_main\\form_guildbuilding\\form_guild_build_domain", false)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_pic_get_capture(pic, get)
  local photo = pic.Image
  pic.Image = string.gsub(photo, "_bc.png", ".png")
end
function on_pic_lost_capture(pic, lost)
  local photo = pic.Image
  pic.Image = string.gsub(photo, ".png", "_bc.png")
end
function on_pic_left_up(pic)
  local form = pic.ParentForm
  if form.tips_new.Visible then
    form.tips_new.Visible = false
  else
    GetGuildDomainInfo(pic.worldID, pic.sceneID)
  end
end
function request_data(msgid, ...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  if msgid == CUSTOMMSG_OPER_GUILD_DOMAIN_BUY then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDDOMAIN_OPER), nx_int(msgid), arg[1])
  elseif msgid == CUSTOMMSG_OPER_GUILD_DOMAIN_INFO then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDDOMAIN_OPER), nx_int(msgid))
  elseif msgid == CUSTOMMSG_GET_GUILD_DOMAIN_INFO then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDDOMAIN_OPER), nx_int(msgid), arg[1], arg[2])
  end
  return true
end
function recv_data(msgid, ...)
  if msgid == CUSTOMMSG_OPER_GUILD_DOMAIN_BUY then
  elseif msgid == CUSTOMMSG_OPER_GUILD_DOMAIN_INFO then
    GetGuildDomainInfoForMap(arg[1], arg[2])
  elseif msgid == CUSTOMMSG_GET_GUILD_DOMAIN_INFO then
    if arg[2] == 0 then
      GetGuildDomainInfo(unpack(arg))
    else
      local parentform = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
      if not nx_is_valid(parentform) then
        return
      end
      if parentform.btn_buy.Visible then
        if arg[10] == 1 then
          parentform.btn_buy.Visible = false
          return
        end
        local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain")
        if not nx_is_valid(form) then
          form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain", true, false)
          nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain", form)
        end
        form.row = arg[5]
        form.domainID = arg[1]
        form.fieldNum = arg[4]
        form:Show()
        form.Visible = true
      else
        local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
        if not nx_is_valid(form) then
          form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info", true, false)
          nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info", form)
        end
        parentform:Add(form)
        parentform:AddTopLayer(form)
        form.Top = (parentform.pic_map.Height - form.Height) / 2
        form.Left = (parentform.pic_map.Width - form.Width) / 2
        form:Show()
        form.Visible = true
        nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info", "show_domain_info", form, unpack(arg))
      end
    end
  end
end
function GetGuildDomainInfoForMap(domainID, flag)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
  if not nx_is_valid(form) then
    return false
  end
  if flag == 1 then
    local node = FindNodeByMark(domainID, false)
    if nx_is_valid(node) then
      node.ImageIndex = 2
    end
  end
end
function FindNodeByMark(domainID, IsSelected)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
  if not nx_is_valid(form) then
    return false
  end
  local designer = gui.Designer
  local sceneID = string.sub(nx_string(domainID), 1, -3)
  local i = 1
  local ctrl_name = "tree_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    local ctrl = form.groupscrollbox_tree:Find(ctrl_name)
    if nx_is_valid(ctrl) and ctrl.type == 2 then
      local nodelist = ctrl.RootNode:GetNodeList()
      if table.getn(nodelist) > 0 then
        node = nodelist[1]:FindNodeByMark(domainID)
        if nx_is_valid(node) then
          if IsSelected then
            ctrl.SelectNode = node
            selectedNode = node
          end
          return node
        end
      end
    end
    i = i + 1
    ctrl_name = "tree_" .. nx_string(i)
  end
  return nil
end
function GetGuildDomainInfo(...)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
  for i = 1, 4 do
    local lbl_obj = form.tips_new:Find("lbl_" .. nx_string(n))
    local pic_obj = form.tips_new:Find("pic_" .. nx_string(n))
    if nx_is_valid(lbl_obj) and nx_is_valid(pic_obj) then
      lbl_obj.Visible = false
      pic_obj.Visible = false
    end
  end
  local gui = nx_value("gui")
  local guilddomain_Manager = nx_value("GuildDomainManager")
  local domain_list = guilddomain_Manager:GetDomainInfo(arg[1], arg[2])
  local domain_num = table.getn(domain_list)
  for n = 1, domain_num do
    local lbl_obj = form.tips_new:Find("lbl_" .. nx_string(n))
    local pic_obj = form.tips_new:Find("pic_" .. nx_string(n))
    if nx_is_valid(lbl_obj) and nx_is_valid(pic_obj) then
      lbl_obj.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_" .. domain_list[n]))
      lbl_obj.domainID = domain_list[n]
      local node = FindNodeByMark(domain_list[n], false)
      if nx_is_valid(node) and node.ImageIndex == 2 then
        pic_obj.flag = 1
        pic_obj.Image = "gui\\special\\task\\icon-mengpai.png"
      else
        pic_obj.flag = 0
        pic_obj.Image = "gui\\guild\\guildbuy\\sj_1.png"
      end
      form.tips_new.Height = lbl_obj.Top + lbl_obj.Height + 15
      lbl_obj.Visible = true
      pic_obj.Visible = true
    end
  end
  if not nx_is_valid(form) then
    return false
  end
  local pic_name = "pic_" .. nx_string(arg[2])
  local pic_obj = form.groupbox_left:Find(pic_name)
  if not nx_is_valid(pic_obj) then
    return false
  end
  form.tips_new.AbsLeft = pic_obj.AbsLeft + pic_obj.Width
  form.tips_new.AbsTop = pic_obj.AbsTop + pic_obj.Height
  if form.tips_new.AbsLeft + form.tips_new.Width > gui.Width then
    form.tips_new.AbsLeft = gui.Width - form.tips_new.Width
  end
  if form.tips_new.AbsTop + form.tips_new.Height > gui.Height then
    form.tips_new.AbsTop = gui.Height - form.tips_new.Height
  end
  form.tips_new.Visible = true
end
function show_tree(form)
  local gui = nx_value("gui")
  local guilddomain_Manager = nx_value("GuildDomainManager")
  local world_list = guilddomain_Manager:GetWorldNoInfo()
  local worldnum = table.getn(world_list)
  local Control_Top = 0
  local designer = gui.Designer
  for k = worldnum, 1, -1 do
    local control = designer:Create("Label")
    local i = 1
    local ctrl_name = "tree_" .. nx_string(i)
    while designer:FindMember(ctrl_name) do
      i = i + 1
      ctrl_name = "tree_" .. nx_string(i)
    end
    control.Name = ctrl_name
    control.Text = nx_widestr(gui.TextManager:GetText("ui_tiguan_area_" .. world_list[k]))
    control.Left = 0
    control.Top = Control_Top
    control.Height = 40
    Control_Top = Control_Top + control.Height
    control.Width = form.groupscrollbox_tree.Width
    control.Align = "Center"
    control.BackImage = "gui\\guild\\formback\\fyan_2.png"
    control.DrawMode = "FitWindow"
    control.ForeColor = "255,255,255,0"
    control.Font = "font_text_title1"
    control.type = 1
    designer:AddMember(ctrl_name)
    form.groupscrollbox_tree:Add(control)
    local scene_list = guilddomain_Manager:GetSceneInfo(world_list[k])
    local scenenum = table.getn(scene_list)
    for m = 1, scenenum do
      local control = designer:Create("TreeView")
      local i = 1
      local ctrl_name = "tree_" .. nx_string(i)
      while designer:FindMember(ctrl_name) do
        i = i + 1
        ctrl_name = "tree_" .. nx_string(i)
      end
      control.Name = ctrl_name
      local imagelist = gui:CreateImageList()
      imagelist:AddImage("gui\\guild\\guildbuy\\sj_1.png")
      imagelist:AddImage("gui\\guild\\guildbuy\\sj_2.png")
      imagelist:AddImage("gui\\guild\\formback\\icon-bangpai.png")
      control.ImageList = imagelist
      local rootNode = control:CreateRootNode(nx_widestr(scene_list[m]))
      local mainNode = rootNode:CreateNode(nx_widestr(gui.TextManager:GetText("ui_scene_" .. scene_list[m])))
      mainNode.Font = "font_btn"
      selectedNode = mainNode
      mainNode.Mark = -1
      control.Left = 5
      control.Top = Control_Top + 2
      control.ItemHeight = 26
      control.Width = form.groupscrollbox_tree.Width - 10
      control.IsNoDrawRoot = true
      control.BackImage = "gui\\guild\\guildbuy\\bg_1.png"
      control.NodeExpandDraw = "gui\\guild\\guildbuy\\jianh_out.png"
      control.NodeCloseDraw = "gui\\guild\\guildbuy\\jiah_out.png"
      control.SelectBackDraw = "gui\\guild\\guildbuy\\bg_1.png"
      control.DrawMode = "Expand"
      control.ForeColor = "255,255,255,255"
      control.TextOffsetY = 5
      control.TreeLineColor = "0,0,0,0"
      mainNode.ImageIndex = -1
      control.type = 2
      designer:AddMember(ctrl_name)
      form.groupscrollbox_tree:Add(control)
      nx_bind_script(control, nx_current())
      nx_callback(control, "on_expand_changed", "on_expand_changed")
      nx_callback(control, "on_mouse_in_node", "on_mouse_in_node")
      nx_callback(control, "on_mouse_out_node", "on_mouse_out_node")
      nx_callback(control, "on_left_click", "on_left_click")
      local domain_list = guilddomain_Manager:GetDomainInfo(world_list[k], scene_list[m])
      local pic_obj = form.groupbox_left:Find("pic_" .. scene_list[m])
      if nx_is_valid(pic_obj) then
        pic_obj.worldID = world_list[k]
        pic_obj.sceneID = scene_list[m]
        nx_callback(pic_obj, "on_left_up", "on_pic_left_up")
      end
      local domainnum = table.getn(domain_list)
      for n = 1, domainnum do
        local node = mainNode:CreateNode(nx_widestr(gui.TextManager:GetText("ui_dipan_" .. domain_list[n])))
        node.Font = "font_text"
        node.ImageIndex = 1
        node.Mark = nx_int(domain_list[n])
      end
      rootNode.Expand = true
      local list = control:GetAllNodeList()
      local count = table.getn(list)
      control.Height = control.ItemHeight * (count - 1)
      Control_Top = Control_Top + control.Height + 2
    end
  end
end
function on_mouse_in_node(self, node)
  local form = self.ParentForm
  if node ~= nil then
    node.ForeColor = "255,255,255,0"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 0
    end
  end
  local pic_name = "pic_" .. nx_string(self.RootNode.Text)
  local pic_obj = form.groupbox_left:Find(pic_name)
  if nx_is_valid(pic_obj) then
    local photo = pic_obj.Image
    pic_obj.Image = string.gsub(photo, "_bc.png", ".png")
  end
end
function on_mouse_out_node(self, node)
  local form = self.ParentForm
  if node ~= nil then
    node.ForeColor = "255,255,255,255"
    if node.Level == 2 and node.ImageIndex ~= 2 then
      node.ImageIndex = 1
    end
  end
  local pic_name = "pic_" .. nx_string(self.RootNode.Text)
  local pic_obj = form.groupbox_left:Find(pic_name)
  if nx_is_valid(pic_obj) then
    local photo = pic_obj.Image
    pic_obj.Image = string.gsub(photo, ".png", "_bc.png")
  end
end
function on_expand_changed(self)
  local list = self:GetAllNodeList()
  local count = table.getn(list)
  self.Height = self.ItemHeight * (count - 1)
  relocate_treeview_position()
  local form = self.ParentForm
  form.tips_new.Visible = false
end
function on_left_click(self, node)
  if not nx_is_valid(node) then
    return
  end
  local form = self.ParentForm
  selectedNode = node
  local IsVisible = true
  if form.pic_map.Visible then
    IsVisible = false
  end
  form.tips_new.Visible = false
  form.pic_map.Visible = false
  form.btn_return.Visible = false
  form.btn_buy.Visible = false
  if node.Mark > 0 and IsVisible then
    request_data(CUSTOMMSG_GET_GUILD_DOMAIN_INFO, node.Mark, get_all_domain_info)
  end
end
function relocate_treeview_position()
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
  form.groupscrollbox_tree.IsEditMode = true
  local adjust_width = 10
  local gui = nx_value("gui")
  local designer = gui.Designer
  Control_Top = 0
  local i = 1
  local ctrl_name = "tree_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    local ctrl = form.groupscrollbox_tree:Find(ctrl_name)
    if nx_is_valid(ctrl) then
      ctrl.Top = Control_Top
      Control_Top = ctrl.Height + Control_Top + 2
    end
    i = i + 1
    ctrl_name = "tree_" .. nx_string(i)
  end
  local content_height = form.groupscrollbox_tree:GetContentHeight()
  if content_height > form.groupscrollbox_tree.Height then
    adjust_width = 27
  end
  i = 1
  local ctrl_name = "tree_" .. nx_string(i)
  while designer:FindMember(ctrl_name) do
    local ctrl = form.groupscrollbox_tree:Find(ctrl_name)
    if nx_is_valid(ctrl) then
      if ctrl.type == 1 then
        ctrl.Width = form.groupscrollbox_tree.Width - (adjust_width - 10)
      else
        ctrl.Width = form.groupscrollbox_tree.Width - adjust_width
      end
    end
    i = i + 1
    ctrl_name = "tree_" .. nx_string(i)
  end
  form.groupscrollbox_tree.ScrollSize = 17
  form.groupscrollbox_tree.IsEditMode = false
end
function refresh_scene_map(name, vis)
  visible = vis
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_domain")
  local map_name = "gui\\map\\scene\\" .. name .. "\\" .. name .. ".dds"
  form.pic_map.Image = map_name
  local file_name = "gui\\map\\scene\\" .. name .. "\\" .. name .. ".ini"
  local ini = get_ini(file_name)
  if not nx_is_valid(ini) then
    nx_msgbox(get_msg_str("msg_418") .. file_name)
    return
  end
  local sec_index = ini:FindSectionIndex("Map")
  form.pic_map.ZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.ZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  if nx_string(name) ~= nx_string(lastName) then
    steps = 1
    local zoom = form.pic_map.ZoomWidth
    while zoom <= 1 do
      zoom = zoom * 1.01
      steps = steps + 1
    end
    lastName = name
  end
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_map.Visible = true
  if sec_index < 0 then
    return ""
  end
  if selectedNode ~= nil then
    local scene_posX = ini:ReadInteger(sec_index, selectedNode.Mark .. "X", 0)
    local scene_posZ = ini:ReadInteger(sec_index, selectedNode.Mark .. "Z", 0)
    local TerrainStartX = ini:ReadInteger(sec_index, "StartX", 0)
    local TerrainStartZ = ini:ReadInteger(sec_index, "StartZ", 0)
    local TerrainWidth = ini:ReadInteger(sec_index, "Width", 1024)
    local TerrainHeight = ini:ReadInteger(sec_index, "Height", 1024)
    local posX, posY = nx_execute("form_stage_main\\form_map\\form_map_scene", "trans_scene_pos_to_image", scene_posX, scene_posZ, form.pic_map.ImageWidth, form.pic_map.ImageHeight, TerrainStartX, TerrainStartZ, TerrainWidth, TerrainHeight)
    local moveX = posX - form.pic_map.CenterX
    local moveY = posY - form.pic_map.CenterY
    nx_pause(1)
    local game_timer = nx_value("timer_game")
    times = 1
    game_timer:Register(10, -1, nx_current(), "show_domain_position", form, moveX, moveY)
  end
end
function show_domain_position(form, posX, posY)
  form.pic_map.ZoomWidth = form.pic_map.ZoomWidth * 1.01
  form.pic_map.ZoomHeight = form.pic_map.ZoomHeight * 1.01
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2 + posX * (times / steps)
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2 + posY * (times / steps)
  times = times + 1
  if form.pic_map.ZoomWidth > 1 or not form.pic_map.Visible then
    local game_timer = nx_value("timer_game")
    game_timer:UnRegister(nx_current(), "show_domain_position", form)
    if form.pic_map.Visible then
      form.btn_return.Visible = true
      form.btn_buy.Visible = visible
    end
  end
end
function on_pic_map_right_up(self)
  local form = self.ParentForm
  self.Visible = false
  form.btn_return.Visible = false
  form.btn_buy.Visible = false
end
function on_btn_return_click(btn)
  local form = btn.ParentForm
  form.pic_map.Visible = false
  form.btn_buy.Visible = false
  btn.Visible = false
end
function on_btn_buy_click(btn)
  local form = btn.ParentForm
  if selectedNode.Mark > 0 then
    request_data(CUSTOMMSG_GET_GUILD_DOMAIN_INFO, selectedNode.Mark, get_all_domain_info)
  end
end
function on_lbl_map_click(lbl)
  local form = lbl.ParentForm
  if form.tips_new.Visible then
    form.tips_new.Visible = false
  end
end
