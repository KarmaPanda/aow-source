require("util_functions")
function main_form_init(self)
  return 1
end
function is_worldwar_center_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local scene_configid = client_scene:QueryProp("ConfigID")
  if nx_string(scene_configid) == nx_string("ini\\scene\\loading01") then
    return true
  end
  return false
end
function main_form_open(self)
  local form_loading = nx_value("form_loading")
  if nx_is_valid(form_loading) then
    nx_destroy(form_loading)
  end
  form_loading = nx_create("form_loading")
  if nx_is_valid(form_loading) then
    nx_set_value("form_loading", form_loading)
  end
  local scene_music_play_manager = nx_value("scene_music_play_manager")
  if nx_is_valid(scene_music_play_manager) then
    scene_music_play_manager:StopGameMusic(1)
  end
  local stage = nx_value("stage")
  self.mltbox_loading.Visible = false
  if stage == "login" then
    self.lbl_bottom.Visible = false
    self.lbl_top.Visible = false
    self.pic_poem.Visible = false
    self.lbl_logo.Visible = false
    local pict = self.lbl_background
    pict.Visible = true
    pict.AsyncLoad = false
    pict.Image = "gui\\loading\\login.jpg"
    local pict_w = self.Width
    local pict_h = self.Width / pict.ImageWidth * pict.ImageHeight
    pict.Left = 0
    pict.Top = (self.Height - pict_h) / 2
    pict.Width = pict_w
    pict.Height = pict_h
  else
    self.BackImage = ""
    self.lbl_logo.Visible = true
    self.pic_poem.Visible = false
    self.lbl_bottom.Visible = false
    self.lbl_top.Visible = false
    self.lbl_background.Visible = true
    local image = ""
    local form_loading = nx_value("form_loading")
    if nx_is_valid(form_loading) then
      image = form_loading:GetLoadingImage()
    end
    if 0 < string.len(image) then
      self.lbl_background.Image = image
      self.pic_poem.Image = ""
    else
      self.lbl_background.Image = get_image()
      self.pic_poem.Image = get_poem()
      local scelogo, sce_pos_left, sce_pos_top, VAnchor, HAnchor = get_name_pos()
      if nx_string(scelogo) ~= "" then
        self.lab_name.AutoSize = true
        self.lab_name.BackImage = "gui\\loading\\logo\\9YZJlogo.png"
        self.lab_name.AutoSize = false
        self.lab_name.VAnchor = nx_string(VAnchor)
        self.lab_name.HAnchor = nx_string(HAnchor)
        self.lab_name.Left = nx_number(sce_pos_left)
        self.lab_name.Top = nx_number(sce_pos_top)
        self.lab_name.Visible = true
        self.lab_sce_name.AutoSize = true
        self.lab_sce_name.BackImage = nx_string(scelogo)
        self.lab_sce_name.AutoSize = false
        self.lab_sce_name.VAnchor = nx_string(VAnchor)
        self.lab_sce_name.HAnchor = nx_string(HAnchor)
        self.lab_sce_name.Left = nx_number(sce_pos_left) + 80
        self.lab_sce_name.Top = nx_number(sce_pos_top) + 90
        self.lab_sce_name.Visible = true
      end
    end
    change_form_size()
  end
  self.load_prog.Value = 0
  nx_execute(nx_current(), "show_load_percent", self)
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:HideTips("0-0")
  end
  return 1
end
function on_main_form_close(self)
  local form_loading = nx_value("form_loading")
  if nx_is_valid(form_loading) then
    nx_destroy(form_loading)
  end
  nx_destroy(self)
end
function show_loading(form)
  if not nx_is_valid(form) then
    return
  end
  local stage = nx_value("stage")
  if stage == "login" then
    return
  end
  local mltbox_loading = form.mltbox_loading
  local msg_str = "ui_loading"
  local form_loading = nx_value("form_loading")
  if nx_is_valid(form_loading) then
    msg_str = msg_str .. nx_string(form_loading:GetLoadingTextID())
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) and not gui.TextManager:IsIDName(msg_str) then
    msg_str = "ui_loading2012"
  end
  mltbox_loading:Clear()
  mltbox_loading:AddHtmlText(nx_widestr(util_text(msg_str)), -1)
  local width = mltbox_loading:GetContentWidth()
  mltbox_loading.Width = width + 200
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  mltbox_loading.AbsLeft = (desktop.Width - mltbox_loading.Width) / 2
  mltbox_loading.ViewRect = "100,0," .. nx_string(mltbox_loading.Width) .. "," .. nx_string(mltbox_loading.Height)
  mltbox_loading.Visible = true
end
function show_load_percent(form)
  nx_execute("util_gui", "clear_common_form")
  show_loading(form)
  local prog = form.load_prog
  while true do
    nx_pause(0.1)
    if not nx_is_valid(form) then
      return false
    end
    if not nx_is_valid(prog) then
      return false
    end
    local gui = nx_value("gui")
    gui.Desktop:ToFront(form)
    local world = nx_value("world")
    local scene = world.MainScene
    if not nx_is_valid(scene) then
      return false
    end
    if not nx_find_custom(scene, "terrain") then
      return false
    elseif not nx_is_valid(scene.terrain) then
      return false
    end
    local terrain = scene.terrain
    if not nx_is_valid(terrain) then
      return false
    end
    local temp = terrain:GetLoadPercent() * 100
    if temp > prog.Value then
      prog.Value = temp
    end
    if terrain:GetLoadPercent() * 100 >= 99 then
      break
    end
    local tips_manager = nx_value("tips_manager")
    if nx_is_valid(tips_manager) then
      tips_manager:HideTips("0-0")
    end
  end
  return true
end
function change_form_size()
  local form = nx_value("form_common\\form_loading")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  form.Width = desktop.Width
  form.Height = desktop.Height
  local lbl = form.lbl_background
  local image_width = 1600
  local image_height = 900
  local lbl_width = form.Width
  local lbl_height = lbl_width / image_width * image_height
  lbl.Width = lbl_width
  lbl.Height = lbl_height
  lbl.Left = 0
  lbl.Top = (form.Height - lbl_height) / 2
  local top_space = lbl.Top
  if top_space < 0 then
    top_space = 0
  end
  local edge_height = form.lbl_logo.Top + form.lbl_logo.Height / 3
  if edge_height < lbl.Top then
    edge_height = lbl.Top + 20
  end
  form.lbl_top.Top = 0
  form.lbl_top.Left = 0
  form.lbl_top.Height = edge_height
  form.lbl_top.Width = lbl_width
  form.lbl_bottom.Top = form.Height - edge_height
  form.lbl_bottom.Left = 0
  form.lbl_bottom.Height = edge_height
  form.lbl_bottom.Width = lbl_width
  form.pic_poem.Top = (form.Height - form.lbl_top.Height - form.lbl_bottom.Height - form.pic_poem.Height) / 4 + form.lbl_top.Height
end
function get_poem()
  local default_poem_image = ""
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return default_poem_image
  end
  local scene_id = scene:QueryProp("Resource")
  if nil == scene_id or "" == scene_id then
    return default_poem_image
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\loading.ini")
  if not nx_is_valid(ini) then
    return default_poem_image
  end
  local poem_image = ""
  local sec_index = ini:FindSectionIndex("poem")
  if 0 <= sec_index then
    poem_image = ini:ReadString(sec_index, nx_string(scene_id), "")
  end
  if "" == poem_image then
    return default_poem_image
  end
  return nx_string(poem_image)
end
function get_image()
  local default_image = "gui\\loading\\login.jpg"
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return default_image
  end
  local scene_id = scene:QueryProp("Resource")
  if scene_id == nil or scene_id == "" then
    return default_image
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\loading.ini")
  if not nx_is_valid(ini) then
    return default_image
  end
  local image = ""
  local sec_index = ini:FindSectionIndex("image")
  if 0 <= sec_index then
    image = ini:ReadString(sec_index, nx_string(scene_id), "")
  end
  if image == "" then
    return default_image
  end
  return nx_string(image)
end
function get_name_pos()
  local default_sce_logo = ""
  local default_pos_left = 80
  local default_pos_top = 130
  local default_VAnchor = "Top"
  local default_HAnchor = "Left"
  local client = nx_value("game_client")
  local scene = client:GetScene()
  if not nx_is_valid(scene) then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  local scene_id = scene:QueryProp("Resource")
  if scene_id == nil or scene_id == "" then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  local ini = nx_execute("util_functions", "get_ini", "ini\\loading.ini")
  if not nx_is_valid(ini) then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  local scelogo = ""
  local sec_index = ini:FindSectionIndex("scelogo")
  if 0 <= sec_index then
    scelogo = ini:ReadString(sec_index, nx_string(scene_id), "")
  end
  local scepos = ""
  sec_index = ini:FindSectionIndex("pos")
  if 0 <= sec_index then
    scepos = ini:ReadString(sec_index, nx_string(scene_id), "")
  end
  if scelogo == "" or scepos == "" then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  local list = util_split_string(scepos, ",")
  if nil ~= list[1] then
    default_VAnchor = list[1]
  end
  if nil ~= list[2] then
    default_HAnchor = list[2]
  end
  if nil ~= list[3] then
    default_pos_left = list[3]
  end
  if nil ~= list[4] then
    default_pos_top = list[4]
  end
  local gui = nx_value("gui")
  local w_ratio = gui.Width / 1024
  local h_ratio = gui.Height / 768
  default_pos_left = default_pos_left * w_ratio
  default_pos_top = default_pos_top * h_ratio
  if default_VAnchor ~= "Top" and default_VAnchor ~= "Bottom" then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  if default_HAnchor ~= "Left" and default_HAnchor ~= "Right" then
    return default_sce_logo, default_pos_left, default_pos_top, default_VAnchor, default_HAnchor
  end
  return nx_string(scelogo), nx_number(default_pos_left), nx_number(default_pos_top), nx_string(default_VAnchor), nx_string(default_HAnchor)
end
