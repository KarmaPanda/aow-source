require("const_define")
require("util_functions")
local file_name = "share\\MiniGame\\PictureGame.ini"
local formula_id = ""
function main_form_init(self)
  self.Fixed = true
  self.start = false
  self.game_time_now = 0
  self.ratio = 1
  self.helptext = ""
  self.close_btn_pos = ""
  self.help_btn_pos = ""
  self.back_photo = ""
  self.grid_row_num = 0
  self.grid_clomn_num = 0
  self.grid_photo_width = 0
  self.grid_photo_height = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.start = false
  self.game_total_time = 10000
  self.game_time_now = 0
  nx_execute("gui", "gui_close_allsystem_form")
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_picture", nx_null())
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_back.AbsLeft = 0
  form.groupbox_back.AbsTop = 0
  form.groupbox_back.Width = gui.Width
  form.groupbox_back.Height = gui.Height
  form.groupbox_main.AbsLeft = (gui.Width - form.groupbox_main.Width) / 2
  form.groupbox_main.AbsTop = (gui.Height - form.groupbox_main.Height) / 2
  local Width = form.groupbox_pic.Width
  local Height = form.groupbox_pic.Height
  if Width < Height then
    form.lbl_name.Left = (gui.Width - form.lbl_name.Width) / 2 - 370
    form.lbl_name.Top = gui.Width / 10
    form.mltbox_desc.Left = gui.Width / 2 + 250
    form.mltbox_desc.Top = gui.Height / 2 + 50
  else
    form.lbl_name.Left = (gui.Width - form.lbl_name.Width) / 2
    form.lbl_name.Top = gui.Width / 10 - 50
    form.mltbox_desc.Left = gui.Width / 2 + 300
    form.mltbox_desc.Top = gui.Height / 2 + 200
  end
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local PictureGame = nx_value("PictureGame")
  if not nx_is_valid(PictureGame) then
    return
  end
  if PictureGame:StartUseVIP() then
    btn.Visible = false
    return
  end
  PictureGame:StartGame()
  form.start = true
  btn.Visible = false
  local timer = nx_value(GAME_TIMER)
  timer:Register(200, -1, "form_stage_main\\form_small_game\\form_game_picture", "on_update_time", form, -1, -1)
end
function on_update_time(form)
  form.game_time_now = form.game_time_now + 200
  form.pebar_time.Value = 100 - (form.game_total_time - form.game_time_now) * 100 / form.game_total_time
  if form.game_total_time <= form.game_time_now then
    local PictureGame = nx_value("PictureGame")
    PictureGame:SendError()
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_update_time", form)
    return
  end
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if nx_is_valid(form) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister("form_stage_main\\form_small_game\\form_game_picture", "on_update_time", form)
    form:Close()
  end
end
function show_close_dialog(form)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = nx_widestr(util_text("ui_smallgametc"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(form) then
      return
    end
    form:Close()
    local PictureGame = nx_value("PictureGame")
    PictureGame:SendError()
  end
end
function on_imagegrid_pic_select_changed(grid, index)
  local form = grid.ParentForm
  gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if not form.start then
    return
  end
  if nx_find_custom(grid, "indirect_select") and grid.indirect_select == 1 then
    grid.indirect_select = 0
    if not gui.GameHand:IsEmpty() then
      gui.GameHand:ClearHand()
    else
      return
    end
    if grid.indirect_viewindex == index then
      grid.indirect_viewindex = -1
      return
    end
    if grid:IsEmpty(index) then
    else
      local photo1 = grid:GetItemImage(index)
      local photo2 = grid:GetItemImage(grid.indirect_viewindex)
      grid:DelItem(grid.indirect_viewindex)
      grid:DelItem(index)
      grid:AddItem(index, photo2, "", 1, -1)
      grid:AddItem(grid.indirect_viewindex, photo1, "", 1, -1)
      local PictureGame = nx_value("PictureGame")
      if not nx_is_valid(PictureGame) then
        return
      end
      PictureGame:ChangePic(grid.indirect_viewindex, index)
    end
    return
  end
  if not grid:IsEmpty(index) then
    local photo = grid:GetItemImage(index)
    gui.GameHand:SetHand("PictureGame", photo, "", "", "", "")
    grid.indirect_viewindex = index
    grid.indirect_select = 1
  end
end
function add_item(index, photo)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  if not form.imagegrid_pic:IsEmpty(index) then
    form.imagegrid_pic:DelItem(index)
  end
  form.imagegrid_pic:AddItem(index, photo, "", 1, -1)
end
function init_background(photo)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.back_photo = photo
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local width = gui.Width
  form.lbl_back.AutoSize = true
  form.lbl_back.BackImage = photo
  local ratio = 1
  if width < form.lbl_back.Width then
    ratio = width / form.lbl_back.Width
    form.lbl_back.AutoSize = false
    form.lbl_back.Width = width
  end
  form.ratio = ratio
  form.groupbox_pic.Width = form.lbl_back.Width
  form.groupbox_pic.Height = form.lbl_back.Height + form.groupbox_time.Height
  form.groupbox_main.Width = form.groupbox_pic.Width
  form.groupbox_main.Height = form.groupbox_pic.Height
  form.lbl_back.Left = 0
  form.lbl_back.Top = 0
  form.groupbox_pic.Left = 0
  form.groupbox_pic.Top = 0
  form.groupbox_time.Left = (form.groupbox_pic.Width - form.groupbox_time.Width) / 2
  form.groupbox_time.Top = form.groupbox_pic.Height - form.groupbox_time.Height
  form.btn_close.Left = form.groupbox_pic.Width - 100
  form.btn_close.Top = 70
  form.btn_help.Left = form.groupbox_pic.Width - 130
  form.btn_help.Top = 70
  refresh_form_pos(form)
end
function set_game_name(name)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  formula_id = name
  local iniformula = nx_execute("util_functions", "get_ini", "share\\Item\\life_formula.ini")
  if not nx_is_valid(iniformula) then
    return 0
  end
  local porduct_item_index = iniformula:FindSectionIndex(nx_string(formula_id))
  if porduct_item_index < 0 then
    return 0
  end
  local porduct_item = iniformula:ReadString(porduct_item_index, "ComposeResult", "")
  local item_name = gui.TextManager:GetFormatText(porduct_item)
  form.lbl_name.Text = nx_widestr(item_name)
  local item_info = gui.TextManager:GetFormatText("desc_" .. porduct_item)
  form.mltbox_desc:AddHtmlText(nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(item_name) .. nx_widestr("</font><br>") .. nx_widestr(item_info), nx_int(-1))
end
function set_btn_pos(close_btn_pos, help_btn_pos)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.close_btn_pos = close_btn_pos
  form.help_btn_pos = help_btn_pos
  local init_left = form.lbl_back.AbsLeft
  local init_top = form.lbl_back.AbsTop
  local ratio = form.ratio
  if nx_string(close_btn_pos) ~= "" then
    local table_close = util_split_string(close_btn_pos, ",")
    if table.getn(table_close) == 2 then
      form.btn_close.Left = init_left + nx_number(table_close[1]) * ratio
      form.btn_close.Top = init_top + nx_number(table_close[2]) * ratio
    end
  end
  if nx_string(help_btn_pos) ~= "" then
    local table_help = util_split_string(help_btn_pos, ",")
    if table.getn(table_help) == 2 then
      form.btn_help.Left = init_left + nx_number(table_help[1]) * ratio
      form.btn_help.Top = init_top + nx_number(table_help[2]) * ratio
    end
  end
end
function init_grid(row_num, clomn_num, photo_width, photo_height)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.grid_row_num = row_num
  form.grid_clomn_num = clomn_num
  form.grid_photo_width = photo_width
  form.grid_photo_height = photo_height
  local ratio = form.ratio
  local grid = form.imagegrid_pic
  grid.Width = clomn_num * photo_width + clomn_num - 1
  grid.Height = row_num * photo_height + row_num - 1
  grid.Width = grid.Width * ratio
  grid.Height = grid.Height * ratio
  grid.ViewRect = "0,0" .. grid.Width .. "," .. grid.Height
  grid.RowNum = row_num
  grid.ClomnNum = clomn_num
  grid.GridWidth = photo_width * ratio
  grid.GridHeight = photo_height * ratio
  local sPos = ""
  local init_left = 0
  local init_top = 0
  for i = 1, row_num do
    for j = 1, clomn_num do
      init_left = (j - 1) * (photo_width + 1) * ratio
      init_top = (i - 1) * (photo_height + 1) * ratio
      sPos = sPos .. nx_string(init_left) .. "," .. nx_string(init_top) .. ";"
    end
  end
  grid.GridsPos = sPos
  grid.Left = (form.groupbox_pic.Width - grid.Width) / 2
  grid.Top = (form.groupbox_pic.Height - form.groupbox_time.Height - grid.Height) / 2
end
function set_total_time(time)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.game_total_time = time * 1000
end
function set_help_text(text)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.helptext = nx_string(text)
end
function on_end_game(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_picture", "on_update_time", form)
  form.groupbox_main.Visible = false
  local gui = nx_value("gui")
  local Label = gui:Create("Label")
  Label.AutoSize = true
  Label.Name = "lab_res"
  local victory = "gui\\language\\ChineseS\\minigame\\victory.png"
  local lost = "gui\\language\\ChineseS\\minigame\\lost.png"
  if res == 1 then
    Label.BackImage = victory
    Label.AbsTop = (gui.Height - Label.Height) / 2 - Label.Height - 40
  else
    Label.BackImage = lost
    Label.AbsTop = (gui.Height - Label.Height) / 2
  end
  Label.AbsLeft = (form.Width - Label.Width) / 2
  form:Add(Label)
  local timer = nx_value(GAME_TIMER)
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_picture", "auto_close_form", form, -1, -1)
end
function auto_close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_help_click(self)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  groupbox = self.Parent
  local groupboxhelp = groupbox:Find("groupbox_help")
  if not nx_is_valid(groupboxhelp) then
    local gui = nx_value("gui")
    groupboxhelp = gui:Create("GroupBox")
    groupboxhelp.AutoSize = true
    groupboxhelp.Name = "groupbox_help"
    groupboxhelp.BackImage = "gui\\language\\ChineseS\\minigame\\gamehelp.png"
    groupboxhelp.AbsLeft = (groupbox.Width - groupboxhelp.Width) / 2
    groupboxhelp.AbsTop = (groupbox.Height - groupboxhelp.Height) / 2
    local button = gui:Create("Button")
    local closebutton = groupbox:Find("btn_close")
    button.AutoSize = true
    button.NormalImage = closebutton.NormalImage
    button.FocusImage = closebutton.FocusImage
    button.PushImage = closebutton.PushImage
    button.AbsLeft = groupboxhelp.Width - button.Width - 30
    button.AbsTop = 30
    nx_bind_script(button, nx_current(), "")
    nx_callback(button, "on_click", "on_close_helpbox")
    local multitextbox = gui:Create("MultiTextBox")
    multitextbox.AutoSize = true
    multitextbox.AbsLeft = 40
    multitextbox.AbsTop = button.AbsTop + button.Height + 30
    multitextbox.Width = groupboxhelp.Width - 80
    multitextbox.Height = groupboxhelp.Height - 70 - button.Height
    multitextbox.MouseInBarColor = "0,0,0,0"
    multitextbox.ViewRect = nx_string("0,0," .. nx_string(multitextbox.Width) .. "," .. nx_string(multitextbox.Height))
    multitextbox.BackColor = "0,0,0,0"
    multitextbox.LineColor = "0,0,0,0"
    multitextbox.SelectBarColor = "0,0,0,0"
    multitextbox.TextColor = "255,0,0,0"
    multitextbox.HtmlText = nx_widestr(gui.TextManager:GetText(form.helptext))
    groupboxhelp:Add(multitextbox)
    groupboxhelp:Add(button)
    groupbox:Add(groupboxhelp)
  else
    groupboxhelp.Visible = true
  end
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function on_alpha_changed(delta)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_picture")
  if not nx_is_valid(form) then
    return
  end
  init_background(form.back_photo)
  set_btn_pos(form.close_btn_pos, form.help_btn_pos)
  init_grid(form.grid_row_num, form.grid_clomn_num, form.grid_photo_width, form.grid_photo_height)
end
