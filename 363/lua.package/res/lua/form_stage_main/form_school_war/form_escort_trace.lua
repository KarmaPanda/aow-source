require("util_functions")
require("define\\gamehand_type")
PLAYER_POSITION_REFRESH = 1000
ANSHAOLIST_SHOW_POS = 630
ANSHAOLIST_HEIGHT = 24
ANSHAO_NormalImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_out.png"
ANSHAO_FocusImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_on.png"
ANSHAO_PushImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_down.png"
ANSHAO_select_NormalImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_select_out.png"
ANSHAO_select_FocusImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_select_on.png"
ANSHAO_select_PushImage = "gui\\special\\tvt\\yunbiao\\sign\\btn_sentry_select_down.png"
MASS_NormalImage = "gui\\language\\ChineseS\\animations\\yunbiao\\yunbiao_3.png"
MASS_FocusImage = "ling_yunbiao"
MASS_PushImage = "gui\\language\\ChineseS\\animations\\yunbiao\\yunbiao_2.png"
ANSHAO_KuoChong = "gui\\language\\ChineseS\\homepoint\\icon_extend.png"
ANSHAO_INI_FILE = "share\\War\\escort_sentry.ini"
ANSHAO_COUNT_LIMIT = "share\\War\\escort_countlimit.ini"
NormalImage = "gui\\map\\mapn\\cbtn1_out.png"
FocusImage = "gui\\map\\mapn\\cbtn1_on.png"
PushImage = "gui\\map\\mapn\\cbtn2_on.png"
FORM_ESCORT = "form_stage_main\\form_school_war\\form_escort_trace"
ESCORT_ICON = "gui\\special\\tvt\\yunbiao\\sign\\icon_target.png"
ANSHAO_SET = 0
ANSHAO_KUOCHONG = 1
TEAM_ID = 1
TEAM_PLAYERNAME = 2
TEAM_POWERLEVEL = 3
TEAM_GUILD = 4
TEAM_NUM = 5
TEAM_GOODSNUM = 6
TEAM_X = 7
TEAM_Z = 8
EscortMsg_ThrowAnShao = 0
EscortMsg_CancelAnShao = 1
EscortMsg_Deliver = 2
EscortMsg_Mass = 3
EscortMsg_Help = 4
EscortMsg_Rob = 5
EscortMsg_CanYuRob = 6
Escort_AnShao_None = 0
Escort_AnShao_Mass = 1
EscortMsg_IsSpecTime_QueryPath = 0
EscortMsg_IsSpecTime_Mass = 1
local escort_path_detailinfo_table = {}
local escort_mass_timeout = 0
local escort_mass_state = Escort_AnShao_None
local cur_resource = ""
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  self.pic_map.right_down = false
  self.pic_map.mouse_move = false
  self.lbl_team_tip.Visible = false
  self.lbl_team_num.Visible = false
  self.lbl_mass_timeout_tip.Visible = false
  self.lbl_mass_timeout.Visible = false
  self.Parent:ToFront(self)
  self.mltbox_help.HtmlText = nx_widestr(util_text("ui_escort_rule_anshaocontent"))
  self.btn_list = nx_call("util_gui", "get_arraylist", "EscortAnShaoData")
  self.team_list = nx_call("util_gui", "get_arraylist", "EscortTeamData")
  local nteam_count = table.getn(escort_path_detailinfo_table)
  if 0 < nteam_count then
    self.mass = Escort_AnShao_Mass
  else
    self.mass = Escort_AnShao_None
  end
  local resource = ""
  if escort_mass_state == Escort_AnShao_None or cur_resource == "" or cur_resource == nil then
    resource = get_curscene_resource()
  else
    resource = cur_resource
  end
  local scene_id = get_scene_id(resource)
  load_map(self, resource, scene_id)
  show_anshao_list(self)
  init_scene_anshao(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("ThrowedAnShaoList", self, nx_current(), "on_anshao_rec_refresh")
    databinder:AddRolePropertyBind("CanYuRob", "int", self, nx_current(), "on_canyu_changed")
  end
  return 1
end
function load_map(form, resource, scene_id)
  local IniManager = nx_value("IniManager")
  if not nx_is_valid(IniManager) then
    return
  end
  form.pic_map.Image = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".dds"
  local pic_width = form.pic_map.ImageWidth * form.pic_map.Height / form.pic_map.ImageHeight
  form.pic_map.Left = -310
  form.pic_map.Width = 620
  local file_name = "gui\\map\\scene\\" .. resource .. "\\" .. resource .. ".ini"
  if not IniManager:IsIniLoadedToManager(file_name) then
    IniManager:LoadIniToManager(file_name)
  end
  local ini = IniManager:GetIniDocument(file_name)
  if not nx_is_valid(ini) then
    return
  end
  form.pic_map.TerrainStartX = ini:ReadInteger("Map", "StartX", 0)
  form.pic_map.TerrainStartZ = ini:ReadInteger("Map", "StartZ", 0)
  form.pic_map.TerrainWidth = ini:ReadInteger("Map", "Width", 1024)
  form.pic_map.TerrainHeight = ini:ReadInteger("Map", "Height", 1024)
  local real_zoom_width = form.pic_map.TerrainWidth / form.pic_map.ImageWidth
  local real_zoom_height = form.pic_map.TerrainHeight / form.pic_map.ImageHeight
  form.pic_map.MinZoomWidth = form.pic_map.Width / form.pic_map.ImageWidth
  form.pic_map.MinZoomHeight = form.pic_map.Height / form.pic_map.ImageHeight
  form.pic_map.MaxZoomWidth = real_zoom_width * 1.5
  form.pic_map.MaxZoomHeight = real_zoom_height * 1.5
  form.pic_map.CenterX = form.pic_map.ImageWidth / 2
  form.pic_map.CenterY = form.pic_map.ImageHeight / 2
  form.pic_map.ZoomWidth = 0.35
  form.pic_map.ZoomHeight = 0.35
  local ratio = (form.pic_map.ZoomWidth - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  ratio = 1 - ratio
  form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_sentry.ini")
  if not nx_is_valid(ini) then
    return
  end
  local nCount = ini:GetSectionCount()
  if nCount <= 0 then
    return
  end
  clear_anshao_data(form)
  for sec_index = 0, nCount - 1 do
    local scene = ini:ReadString(sec_index, "Sentryscene", "")
    if resource == scene then
      local anshao_id = ini:GetSectionByIndex(sec_index)
      local x = ini:ReadInteger(sec_index, "SentryposX", 0)
      local z = ini:ReadInteger(sec_index, "SentryposZ", 0)
      local anshao_name = ini:ReadString(sec_index, "SentryName", "")
      local new_ctl = create_icon_btn(form, anshao_name, x, z, anshao_name, anshao_id)
      local child = form.btn_list:GetChild("btn" .. nx_string(sec_index))
      if not nx_is_valid(child) then
        child = form.btn_list:CreateChild("btn" .. nx_string(sec_index))
        child.ctl = new_ctl
      end
    end
  end
  refresh_team_info(form)
  form.scene_id = scene_id
  cur_resource = resource
  form.lbl_current_scene.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
  form.combobox_anshao.Text = nx_widestr(util_text("ui_scene_" .. nx_string(scene_id)))
end
function get_curscene_resource()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return
  end
  local resource = client_scene:QueryProp("Resource")
  local count = get_scene_anshao_count(resource)
  if count <= 0 then
    local ini = nx_execute("util_functions", "get_ini", "ini\\escort\\sceneres.ini")
    if not nx_is_valid(ini) then
      return
    end
    local sec_count = ini:GetSectionCount()
    if sec_count < 0 then
      return
    end
    resource = ini:ReadString(0, "SceneRes", "")
  end
  return resource
end
function get_scene_anshao_count(resource)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_sentry.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local nCount = ini:GetSectionCount()
  if nCount <= 0 then
    return 0
  end
  local scene_count = 0
  for sec_index = 0, nCount - 1 do
    local scene = ini:ReadString(sec_index, "Sentryscene", "")
    if resource == scene then
      scene_count = scene_count + 1
    end
  end
  return scene_count
end
function get_anshao_count()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local anshaocount = client_player:GetRecordRows("ThrowedAnShaoList")
  return anshaocount
end
function get_max_anshao_count()
  local ini = nx_execute("util_functions", "get_ini", ANSHAO_COUNT_LIMIT)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  if sec_count <= 0 then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local nCount = 0
  local nPlayerLevel = client_player:QueryProp("PowerLevel")
  for index = 0, sec_count - 1 do
    local level = nx_int(ini:GetSectionByIndex(index))
    local nPowerCount = ini:ReadInteger(index, "CountLimit", 0)
    if nx_int(nPlayerLevel) >= nx_int(level) and nCount < nPowerCount then
      nCount = nPowerCount
    end
  end
  return nCount
end
function get_anshao_info(anshao_id)
  local ini = nx_execute("util_functions", "get_ini", ANSHAO_INI_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local index = ini:FindSectionIndex(anshao_id)
  if index < 0 then
    return
  end
  local name = ini:ReadString(index, "SentryName", "")
  return name
end
function clear_anshao_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form.btn_list) then
    return
  end
  local child_count = form.btn_list:GetChildCount()
  for i = 1, child_count do
    local child = form.btn_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      form:Remove(child.ctl)
      gui:Delete(child.ctl)
    end
  end
  form.btn_list:ClearChild()
end
function clear_team_data(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(form.team_list) then
    return
  end
  local child_count = form.team_list:GetChildCount()
  for i = 1, child_count do
    local child = form.team_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      form:Remove(child.ctl)
      gui:Delete(child.ctl)
    end
  end
  form.team_list:ClearChild()
end
function init_scene_anshao(form)
  if not nx_is_valid(form) then
    return
  end
  local nCount = form.combobox_anshao.DropListBox.ItemCount
  if nx_int(0) < nx_int(nCount) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\escort\\sceneres.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_count = ini:GetSectionCount()
  if sec_count < 0 then
    return false
  end
  for i = 0, sec_count - 1 do
    local scene_name = ini:ReadString(i, "SceneName", "")
    form.combobox_anshao.DropListBox:AddString(nx_widestr(util_text(scene_name)))
  end
end
function get_scene_resource(scene_name)
  local ini = nx_execute("util_functions", "get_ini", "ini\\escort\\sceneres.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_count = ini:GetSectionCount()
  if sec_count < 0 then
    return false
  end
  for i = 0, sec_count - 1 do
    local name = ini:ReadString(i, "SceneName", "")
    if nx_widestr(util_text(name)) == nx_widestr(scene_name) then
      local res = ini:ReadString(i, "SceneRes", "")
      local scene_id = ini:GetSectionByIndex(i)
      return res, scene_id
    end
  end
end
function get_scene_id(resource)
  local ini = nx_execute("util_functions", "get_ini", "ini\\escort\\sceneres.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local sec_count = ini:GetSectionCount()
  if sec_count < 0 then
    return false
  end
  for i = 0, sec_count - 1 do
    local res = ini:ReadString(i, "SceneRes", "")
    if nx_string(res) == nx_string(resource) then
      local scene_id = ini:GetSectionByIndex(i)
      return scene_id
    end
  end
end
function get_escort_configinfo()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_config.ini")
  if not nx_is_valid(ini) then
    return -1
  end
  local index = ini:FindSectionIndex("BaseInfo")
  if index < 0 then
    return -1
  end
  local nBuyTeamInfoMoney = ini:ReadInteger(index, "BuyTeamInfoMoney", 0)
  local nTimeDown = ini:ReadInteger(index, "MassTimeOut", 0)
  return nBuyTeamInfoMoney, nTimeDown
end
function get_mass_timeout()
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\escort_config.ini")
  if not nx_is_valid(ini) then
    return 0
  end
  local index = ini:FindSectionIndex("BaseInfo")
  if index < 0 then
    return 0
  end
  local nTimeDown = ini:ReadInteger(index, "MassTimeOut", 0)
  return nTimeDown
end
function get_team_desc(escort_info)
  local desc = nx_widestr(util_text("ui_escort_teamcaptain_info")) .. nx_widestr(escort_info[TEAM_PLAYERNAME])
  desc = desc .. nx_widestr("(") .. nx_widestr(util_text("desc_" .. nx_string(escort_info[TEAM_POWERLEVEL]))) .. nx_widestr(")<br>")
  desc = desc .. nx_widestr(util_text("ui_bangpai")) .. nx_widestr(": ") .. nx_widestr(escort_info[TEAM_GUILD]) .. nx_widestr("<br>")
  desc = desc .. nx_widestr(util_text("ui_escort_peoplenumber")) .. nx_widestr(escort_info[TEAM_NUM]) .. nx_widestr("<br>")
  return desc
end
function on_combobox_anshao_selected(combox)
  local form = combox.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local res, scene_id = get_scene_resource(combox.Text)
  load_map(form, res, scene_id)
end
function refresh_npc_lbl_pos(form)
  if not nx_is_valid(form.btn_list) then
    return
  end
  local child_count = form.btn_list:GetChildCount()
  for i = 1, child_count do
    local child = form.btn_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      set_lbl_position(child.ctl, form.pic_map)
    end
  end
end
function refresh_team_lbl_pos(form)
  if not nx_is_valid(form.team_list) then
    return
  end
  local child_count = form.team_list:GetChildCount()
  for i = 1, child_count do
    local child = form.team_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      set_lbl_position(child.ctl, form.pic_map)
    end
  end
end
function set_lbl_position(ctl, pic_map, bshow)
  if not nx_is_valid(ctl) then
    return
  end
  if not nx_find_custom(ctl, "x") and not nx_find_custom(ctl, "z") then
    return
  end
  local x = ctl.x
  local z = ctl.z
  local sx, sz = get_pos_in_map(ctl.x, ctl.z, pic_map)
  local gui = nx_value("gui")
  ctl.AbsLeft = pic_map.AbsLeft + sx - ctl.Width / 2
  ctl.AbsTop = pic_map.AbsTop + sz - ctl.Height / 2
  if nil ~= bshow then
    ctl.Visible = bshow
  else
    ctl.Visible = is_in_map(ctl, pic_map)
  end
end
function is_in_map(control, pic_map)
  local map_query = nx_value("MapQuery")
  if nx_is_valid(map_query) then
    return map_query:IsInMap(control, pic_map)
  end
  return false
end
function is_throwed_anshao(anshao_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local row = client_player:FindRecordRow("ThrowedAnShaoList", 0, anshao_id, 0)
  if row < 0 then
    return false
  end
  return true
end
function create_icon_lable(form, name, x, z, image, desc)
  local gui = nx_value("gui")
  local lab = gui:Create("Label")
  if nx_is_valid(lab) then
    lab.Name = name
  end
  lab.Width = 30
  lab.Height = 30
  lab.DrawMode = "FitWindow"
  lab.BackImage = nx_string(image)
  lab.Visible = true
  lab.Transparent = false
  lab.Desc = desc
  nx_bind_script(lab, nx_current(), "")
  nx_callback(lab, "on_get_capture", "on_label_get_capture")
  nx_callback(lab, "on_lost_capture", "on_label_lost_capture")
  form:Add(lab)
  lab.x = x
  lab.z = z
  set_lbl_position(lab, form.pic_map)
  return lab
end
function create_icon_btn(form, name, x, z, desc, anshao_id)
  local gui = nx_value("gui")
  local btn = gui:Create("Button")
  if nx_is_valid(btn) then
    btn.Name = name
  end
  btn.Width = 30
  btn.Height = 30
  btn.DrawMode = "FitWindow"
  btn.Visible = true
  btn.Transparent = false
  btn.Desc = desc
  if escort_mass_state == Escort_AnShao_None then
    if is_throwed_anshao(anshao_id) then
      btn.NormalImage = ANSHAO_select_NormalImage
      btn.FocusImage = ANSHAO_select_FocusImage
      btn.PushImage = ANSHAO_select_PushImage
    else
      btn.NormalImage = ANSHAO_NormalImage
      btn.FocusImage = ANSHAO_FocusImage
      btn.PushImage = ANSHAO_PushImage
    end
  else
    btn.NormalImage = MASS_NormalImage
    btn.FocusImage = MASS_FocusImage
    btn.PushImage = MASS_PushImage
  end
  nx_bind_script(btn, nx_current(), "")
  nx_callback(btn, "on_get_capture", "on_button_get_capture")
  nx_callback(btn, "on_lost_capture", "on_button_lost_capture")
  nx_callback(btn, "on_click", "on_anshao_click")
  form:Add(btn)
  btn.x = x
  btn.z = z
  btn.anshao_id = anshao_id
  set_lbl_position(btn, form.pic_map)
  return btn
end
function create_ansho_item_btn(grp, index, type, anshao_id)
  if not nx_is_valid(grp) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local anshao_grp = gui:Create("GroupBox")
  anshao_grp.BackColor = "0,0,0,0"
  anshao_grp.LineColor = "0,0,0,0"
  anshao_grp.Width = grp.Width
  anshao_grp.Height = ANSHAOLIST_HEIGHT
  anshao_grp.Top = 10 + index * ANSHAOLIST_HEIGHT
  anshao_grp.Name = nx_string("anshaogrp" .. nx_string(index))
  local hp_anshao = gui:Create("Button")
  hp_anshao.DrawMode = "Expand"
  hp_anshao.Height = ANSHAOLIST_HEIGHT
  hp_anshao.Width = grp.Width
  hp_anshao.NormalImage = NormalImage
  hp_anshao.FocusImage = FocusImage
  hp_anshao.PushImage = PushImage
  nx_bind_script(hp_anshao, nx_current(), "")
  nx_callback(hp_anshao, "on_left_double_click", "on_anshao_list_double_click")
  hp_anshao.anshao_id = anshao_id
  anshao_grp:Add(hp_anshao)
  if ANSHAO_KUOCHONG == type then
  else
    local label_name = gui:Create("Label")
    label_name.Left = 0
    label_name.Top = 6
    label_name.Width = grp.Width
    label_name.Height = 16
    label_name.Font = "font_btn"
    label_name.ForeColor = "255,95,67,37"
    label_name.Align = "Center"
    local name = get_anshao_info(anshao_id)
    label_name.Text = nx_widestr(util_text(name))
    anshao_grp:Add(label_name)
  end
  grp:Add(anshao_grp)
end
function show_anshao_list(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.groupbox_anshao:DeleteAll()
  local nCount = client_player:GetRecordRows("ThrowedAnShaoList")
  for i = 0, nCount - 1 do
    local anshao_id = client_player:QueryRecord("ThrowedAnShaoList", i, 0)
    create_ansho_item_btn(form.groupbox_anshao, i, ANSHAO_SET, anshao_id)
  end
  local max_count = get_max_anshao_count()
  local anshaocount = get_anshao_count()
  form.lbl_anshao_num.Text = nx_widestr(util_text("ui_main_sentrycount")) .. nx_widestr(nx_string(anshaocount)) .. nx_widestr("/") .. nx_widestr(nx_string(nx_int(max_count)))
end
function refresh_ansho_flag(form, mass)
  if not nx_is_valid(form.btn_list) then
    return
  end
  local child_count = form.btn_list:GetChildCount()
  for i = 1, child_count do
    local child = form.btn_list:GetChildByIndex(i - 1)
    if nx_is_valid(child) then
      if nx_int(Escort_AnShao_None) == nx_int(mass) then
        if is_throwed_anshao(child.ctl.anshao_id) then
          child.ctl.NormalImage = ANSHAO_select_NormalImage
          child.ctl.FocusImage = ANSHAO_select_FocusImage
          child.ctl.PushImage = ANSHAO_select_PushImage
        else
          child.ctl.NormalImage = ANSHAO_NormalImage
          child.ctl.FocusImage = ANSHAO_FocusImage
          child.ctl.PushImage = ANSHAO_PushImage
        end
      else
        child.ctl.NormalImage = MASS_NormalImage
        child.ctl.FocusImage = MASS_FocusImage
        child.ctl.PushImage = MASS_PushImage
      end
    end
  end
  if nx_int(Escort_AnShao_Mass) == nx_int(mass) then
    form.combobox_anshao.Enabled = false
  else
    form.combobox_anshao.Enabled = true
  end
  escort_mass_state = mass
end
function renounce_mass(form)
  if not nx_is_valid(form) then
    return
  end
  escort_mass_state = Escort_AnShao_None
  form.btn_path.Text = nx_widestr(util_text("ui_escort_pathquery"))
  form.mltbox_help.HtmlText = nx_widestr(util_text("ui_escort_rule_anshaocontent"))
  form.lbl_team_tip.Visible = false
  form.lbl_team_num.Visible = false
  escort_path_detailinfo_table = {}
  clear_team_data(form)
  refresh_ansho_flag(form, Escort_AnShao_None)
  reset_mass_timedown(form)
end
function on_main_form_close(self)
  clear_anshao_data(self)
  clear_team_data(self)
  if nx_find_custom(self, "btn_list") and nx_is_valid(self.btn_list) then
    self.btn_list:ClearChild()
    nx_destroy(self.btn_list)
  end
  if nx_find_custom(self, "team_list") and nx_is_valid(self.team_list) then
    self.team_list:ClearChild()
    nx_destroy(self.team_list)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_label_get_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(lbl.Desc))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function on_label_lost_capture(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_button_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("tips_game", "hide_tip", form)
end
function on_button_get_capture(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(btn.Desc))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, form)
end
function ShowMsgDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_error", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return true
end
function IsSpecialTime(nIsTime)
  local form = nx_value("form_stage_main\\form_school_war\\form_escort_trace")
  if nIsTime == 0 then
    return
  end
  if nx_int(escort_mass_state) == nx_int(Escort_AnShao_None) then
    local gui = nx_value("gui")
    if not nx_is_valid(gui) then
      return
    end
    local nMoney, nTimeDown = get_escort_configinfo()
    gui.TextManager:Format_SetIDName("ui_buy_team_detailinfo")
    gui.TextManager:Format_AddParam(nx_int(nMoney))
    local text = nx_widestr(gui.TextManager:Format_GetText())
    if not ShowTipDialog(text) then
      return
    end
    nx_execute("custom_sender", "custom_get_escort_info", nx_int(form.scene_id))
  else
    renounce_mass(form)
  end
end
function on_path_query_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("custom_sender", "custom_get_is_special_time", EscortMsg_IsSpecTime_QueryPath)
end
function on_anshao_click(btn)
  local anshao_id = btn.anshao_id
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(escort_mass_state) == nx_int(Escort_AnShao_None) then
    if is_throwed_anshao(anshao_id) then
      nx_execute("custom_sender", "custom_escort_anshao_msg", EscortMsg_CancelAnShao, anshao_id)
    else
      nx_execute("custom_sender", "custom_escort_anshao_msg", EscortMsg_ThrowAnShao, anshao_id)
    end
  else
    if not ShowTipDialog(util_text("ui_main_transmission")) then
      return
    end
    nx_execute("custom_sender", "custom_escort_anshao_msg", EscortMsg_Mass, anshao_id)
  end
end
function on_btn_anshao_list_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if true == form.groupbox_anshao.Visible then
    form.groupbox_anshao.Visible = false
  else
    form.groupbox_anshao.Visible = true
  end
end
function on_anshao_list_double_click(btn)
  local anshao_id = btn.anshao_id
  nx_execute("custom_sender", "custom_escort_anshao_msg", EscortMsg_CancelAnShao, anshao_id)
end
function on_pic_map_right_down(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:SetHand(GHT_FUNC, "snapmap", "", "", "", "")
  pic_map.right_down = true
  pic_map.click_center_x = pic_map.CenterX
  pic_map.click_center_z = pic_map.CenterY
  pic_map.click_offset_x = x
  pic_map.click_offset_y = y
end
function on_pic_map_right_up(pic_map, x, y)
  local gui = nx_value("gui")
  gui.GameHand:ClearHand()
  pic_map.right_down = false
end
function mouse_right_up()
  local form = nx_value("form_stage_main\\form_school_war\\form_escort_trace")
  if nx_is_valid(form) and nx_find_custom(form.pic_map, "right_down") and form.pic_map.right_down then
    on_pic_map_right_up(form.pic_map, 0, 0)
  end
end
function on_escort_team_info(escort_info_table)
  escort_path_detailinfo_table = {}
  local form = nx_value(FORM_ESCORT)
  if not nx_is_valid(form) then
    return
  end
  local escort_team_table = util_split_wstring(nx_widestr(escort_info_table), ";")
  local nCount = table.getn(escort_team_table)
  for i = 1, nCount - 1 do
    escort_path_detailinfo_table[i] = util_split_wstring(nx_widestr(escort_team_table[i]), ",")
  end
  clear_team_data(form)
  nCount = table.getn(escort_path_detailinfo_table)
  for i = 1, nCount do
    local new_ctl = create_icon_lable(form, "team" .. nx_string(i), nx_int(escort_path_detailinfo_table[i][TEAM_X]), nx_int(escort_path_detailinfo_table[i][TEAM_Z]), ESCORT_ICON, get_team_desc(escort_path_detailinfo_table[i]))
    local child = form.team_list:GetChild("team" .. nx_string(sec_index))
    if not nx_is_valid(child) then
      child = form.team_list:CreateChild("team" .. nx_string(sec_index))
      child.ctl = new_ctl
    end
  end
  form.btn_path.Text = nx_widestr(util_text("ui_escort_fangqijijie"))
  form.lbl_team_tip.Visible = true
  form.lbl_team_num.Visible = true
  form.lbl_team_num.Text = nx_widestr(nx_int(nCount))
  form.mltbox_help.HtmlText = nx_widestr(util_text("ui_escort_rule_jijiecontent"))
  refresh_ansho_flag(form, Escort_AnShao_Mass)
  mass_timedown_started(form)
end
function refresh_team_info(form)
  if nx_int(escort_mass_state) == nx_int(Escort_AnShao_None) then
    return
  end
  form.btn_path.Text = nx_widestr(util_text("ui_escort_fangqijijie"))
  form.lbl_team_tip.Visible = true
  form.lbl_team_num.Visible = true
  form.lbl_team_num.Text = nx_widestr(nx_int(nCount))
  form.mltbox_help.HtmlText = nx_widestr(util_text("ui_escort_rule_jijiecontent"))
  form.lbl_mass_timeout_tip.Visible = true
  form.lbl_mass_timeout.Visible = true
  refresh_ansho_flag(form, Escort_AnShao_Mass)
  local nCount = table.getn(escort_path_detailinfo_table)
  if nCount <= 0 then
    return
  end
  clear_team_data(form)
  for i = 1, nCount do
    local new_ctl = create_icon_lable(form, "team" .. nx_string(i), nx_int(escort_path_detailinfo_table[i][TEAM_X]), nx_int(escort_path_detailinfo_table[i][TEAM_Z]), ESCORT_ICON, get_team_desc(escort_path_detailinfo_table[i]))
    local child = form.team_list:GetChild("team" .. nx_string(sec_index))
    if not nx_is_valid(child) then
      child = form.team_list:CreateChild("team" .. nx_string(sec_index))
      child.ctl = new_ctl
    end
  end
end
function auto_show_hide_escort_form()
  local form = nx_value(FORM_ESCORT)
  if nx_is_valid(form) then
    form.Visible = not form.Visible
    if form.Visible then
      center_for_screen(form)
      form.rbtn_hp.Checked = true
      DelayExecute(300, 1, FORM_HOME_POINT, "refresh_form")
    else
      ClearDelay(FORM_ESCORT, "refresh_form")
      reset_homepoint_timedown(form)
      form.pbar_timedown.Value = 0
      form.time.Text = ""
    end
  else
    nx_execute("util_gui", "util_auto_show_hide_form", FORM_ESCORT)
  end
end
function trans_pos_to_map(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local map_x = map_width - (x - terrain_start_x) / terrain_width * map_width
  local map_z = (z - terrain_start_z) / terrain_height * map_height
  return map_x, map_z
end
function trans_pos_to_scene(x, z, map_width, map_height, terrain_start_x, terrain_start_z, terrain_width, terrain_height)
  local pos_x = terrain_width - x * terrain_width / map_width + terrain_start_x
  local pos_z = z * terrain_height / map_height + terrain_start_z
  return pos_x, pos_z
end
function get_pos_in_map(x, z, pic_map)
  local map_x, map_z = trans_pos_to_map(x, z, pic_map.ImageWidth, pic_map.ImageHeight, pic_map.TerrainStartX, pic_map.TerrainStartZ, pic_map.TerrainWidth, pic_map.TerrainHeight)
  local sx = (map_x - pic_map.CenterX) * pic_map.ZoomWidth
  local sz = (map_z - pic_map.CenterY) * pic_map.ZoomHeight
  sx = sx + pic_map.Width / 2
  sz = sz + pic_map.Height / 2
  return sx, sz
end
function set_map_center(form, center_x, center_z)
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x < center_x_min then
    center_x = center_x_min
  end
  if center_x_max < center_x then
    center_x = center_x_max
  end
  if center_z < center_z_min then
    center_z = center_z_min
  end
  if center_z_max < center_z then
    center_z = center_z_max
  end
  form.pic_map.CenterX = center_x
  form.pic_map.CenterY = center_z
  refresh_npc_lbl_pos(form)
  refresh_team_lbl_pos(form)
end
function on_pic_map_drag_move(pic_map, offset_x, offset_y)
  if not nx_find_custom(pic_map, "click_center_x") then
    return
  end
  local sx = -offset_x / pic_map.ZoomWidth * 0.5
  local sz = -offset_y / pic_map.ZoomHeight * 0.5
  local map_x = sx + pic_map.click_center_x
  local map_z = sz + pic_map.click_center_z
  local form = pic_map.ParentForm
  set_map_center(form, map_x, map_z)
end
function set_map_zoom(form, zoom_width, zoom_height)
  form.pic_map.ZoomWidth = zoom_width
  form.pic_map.ZoomHeight = zoom_height
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  if center_x_min > form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_min
  end
  if center_x_max < form.pic_map.CenterX then
    form.pic_map.CenterX = center_x_max
  end
  if center_z_min > form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_min
  end
  if center_z_max < form.pic_map.CenterY then
    form.pic_map.CenterY = center_z_max
  end
end
function on_tbar_zoom_value_changed(self)
  local form = self.ParentForm
  local ratio = self.Value / (self.Maximum - self.Minimum)
  ratio = 1 - ratio
  local zoom_width = form.pic_map.MinZoomWidth + ratio * (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
  local zoom_height = form.pic_map.MinZoomHeight + ratio * (form.pic_map.MaxZoomHeight - form.pic_map.MinZoomHeight)
  local lbl_back = form.lbl_track
  lbl_back.Left = form.tbar_zoom.Left
  lbl_back.AbsTop = form.tbar_zoom.TrackButton.AbsTop + form.tbar_zoom.TrackButton.Height
  lbl_back.Height = form.tbar_zoom.Height - form.tbar_zoom.TrackButton.Top - form.tbar_zoom.TrackButton.Height
  lbl_back.Visible = 0.0010000000000000009 < ratio
  set_map_zoom(form, zoom_width, zoom_height)
  refresh_npc_lbl_pos(form)
  refresh_team_lbl_pos(form)
end
function on_btn_zoom_in_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = true
  while self.mouse_down_zoom_in do
    local sec = nx_pause(0.1)
    local zoom_width = form.pic_map.ZoomWidth + 0.05
    local zoom_height = form.pic_map.ZoomHeight + 0.05
    if zoom_width >= form.pic_map.MaxZoomWidth or zoom_height >= form.pic_map.MaxZoomHeight then
      zoom_width = form.pic_map.MaxZoomWidth
      zoom_height = form.pic_map.MaxZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
  end
end
function on_btn_zoom_in_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_in = false
end
function on_btn_zoom_out_push(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = true
  while self.mouse_down_zoom_out do
    local sec = nx_pause(0.1)
    local zoom_width = form.pic_map.ZoomWidth - 0.05
    local zoom_height = form.pic_map.ZoomHeight - 0.05
    if zoom_width <= form.pic_map.MinZoomWidth or zoom_height <= form.pic_map.MinZoomHeight then
      zoom_width = form.pic_map.MinZoomWidth
      zoom_height = form.pic_map.MinZoomHeight
    end
    local ratio = (zoom_width - form.pic_map.MinZoomWidth) / (form.pic_map.MaxZoomWidth - form.pic_map.MinZoomWidth)
    ratio = 1 - ratio
    form.tbar_zoom.Value = form.tbar_zoom.Minimum + (form.tbar_zoom.Maximum - form.tbar_zoom.Minimum) * ratio
    set_map_zoom(form, zoom_width, zoom_height)
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
  end
end
function on_btn_zoom_out_click(self)
  local form = self.ParentForm
  self.mouse_down_zoom_out = false
end
function on_btn_up_click(self)
  self.mouse_down_move_up = false
end
function on_btn_up_push(self)
  local form = self.ParentForm
  self.mouse_down_move_up = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_up do
    local sec = nx_pause(0.1)
    local center_y = form.pic_map.CenterY - 10
    if center_z_min >= center_y then
      center_y = center_z_min
    end
    form.pic_map.CenterY = center_y
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
    if center_z_min >= center_y then
      break
    end
  end
end
function on_btn_down_click(self)
  self.mouse_down_move_down = false
end
function on_btn_down_push(self)
  local form = self.ParentForm
  self.mouse_down_move_down = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_down do
    local sec = nx_pause(0.1)
    local center_y = form.pic_map.CenterY + 10
    if center_z_max <= center_y then
      center_y = center_z_max
    end
    form.pic_map.CenterY = center_y
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
    if center_z_max <= center_y then
      break
    end
  end
end
function on_btn_left_click(self)
  self.mouse_down_move_left = false
end
function on_btn_left_push(self)
  local form = self.ParentForm
  self.mouse_down_move_left = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_left do
    local sec = nx_pause(0.1)
    local center_x = form.pic_map.CenterX - 10
    if center_x_min >= center_x then
      center_x = center_x_min
    end
    form.pic_map.CenterX = center_x
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
    if center_x_min >= center_x then
      break
    end
  end
end
function on_btn_right_click(self)
  self.mouse_down_move_right = false
end
function on_btn_right_push(self)
  local form = self.ParentForm
  self.mouse_down_move_right = true
  local center_x_min = form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_x_max = form.pic_map.ImageWidth - form.pic_map.Width / 2 / form.pic_map.ZoomWidth
  local center_z_min = form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  local center_z_max = form.pic_map.ImageHeight - form.pic_map.Height / 2 / form.pic_map.ZoomHeight
  while self.mouse_down_move_right do
    local sec = nx_pause(0.1)
    local center_x = form.pic_map.CenterX + 10
    if center_x_max <= center_x then
      center_x = center_x_max
    end
    form.pic_map.CenterX = center_x
    refresh_npc_lbl_pos(form)
    refresh_team_lbl_pos(form)
    if center_x_max <= center_x then
      break
    end
  end
end
function reset_scene()
  local form = nx_value(FORM_ESCORT)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_anshao_rec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  if optype == "update" or optype == "del" or optype == "add" then
    show_anshao_list(form)
    refresh_ansho_flag(form, escort_mass_state)
  end
  local ncount = get_anshao_count()
  form.groupbox_anshao.Top = ANSHAOLIST_SHOW_POS - nx_int(ncount) * ANSHAOLIST_HEIGHT
  form.groupbox_anshao.Visible = true
end
function ShowTipDialog(content)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, content)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    return true
  else
    return false
  end
  return false
end
function mass_timedown_started(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
    timer:Register(1000, -1, nx_current(), "on_update_timedown", form, -1, -1)
    escort_mass_timeout = get_mass_timeout()
    form.lbl_mass_timeout_tip.Visible = true
    form.lbl_mass_timeout.Visible = true
  end
end
function reset_mass_timedown(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_timedown", form)
  end
  escort_mass_timeout = 0
  form.lbl_mass_timeout_tip.Visible = false
  form.lbl_mass_timeout.Visible = false
end
function on_update_timedown(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(0) >= nx_int(escort_mass_timeout) then
    form.lbl_mass_timeout.Text = nx_widestr(get_format_time_text(0))
    renounce_mass(form)
    reset_mass_timedown(form)
    return
  end
  form.lbl_mass_timeout.Text = nx_widestr(get_format_time_text(escort_mass_timeout))
  escort_mass_timeout = escort_mass_timeout - 1
end
function on_anshao_msg(msgid)
  if nx_int(msgid) == nx_int(1) then
    local form = nx_value(FORM_ESCORT)
    if not nx_is_valid(form) then
      return
    end
    renounce_mass(form)
  end
end
function get_format_time_text(time)
  local format_time = ""
  local min = nx_int(time / 60)
  local sec = nx_int(math.mod(time, 60))
  format_time = string.format("%02d:%02d", nx_number(min), nx_number(sec))
  return nx_string(format_time)
end
