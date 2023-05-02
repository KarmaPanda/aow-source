require("const_define")
require("util_functions")
local qizi_bai = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_bai.png"
local qizi_hei = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_hei.png"
local cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan1.png"
local total_errortimes = 0
local qiju_name = ""
local player_name = ""
local robot_name = ""
function main_form_init(self)
  self.Fixed = true
  self.PlayerType = 0
  self.Diff = 0
  self.QiziEffect = 0
  self.LastIndex = 0
  self.GameState = 0
  self.qipanType = 0
  self.helptext = ""
  self.b_use_vip = false
end
function on_main_form_open(self)
  refresh_form_pos(self)
  init_form(self)
  nx_execute("gui", "gui_close_allsystem_form")
end
function init_form(form)
  form.lbl_tips.Visible = false
  form.groupbox_light.Visible = false
  form.btn_yanshi.Visible = false
  form.btn_break_yanshi.Visible = false
  form.btn_start.Visible = false
  form.lbl_tips.BackImage = "gui\\common\\form_back\\di02-b.png"
  player_name = ""
  robot_name = ""
  qiju_name = ""
  total_errortimes = 0
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
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
  nx_set_value("form_stage_main\\form_small_game\\form_game_weiqi", nx_null())
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_text(text_type)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\WeiqiGame.ini")
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(form.Diff))
  if sec_index < 0 then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr("")
  if text_type == -1 then
    local textkey = ini:ReadString(nx_number(sec_index), "TextInfo", "")
    text = nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(gui.TextManager:GetText(qiju_name)) .. nx_widestr("</font><br>") .. nx_widestr(gui.TextManager:GetText(textkey))
  else
    local qiju_text = ini:ReadString(nx_number(sec_index), "TextInfo", "")
    qiju_text = gui.TextManager:GetText(qiju_text)
    local qizi_text = ini:ReadString(nx_number(sec_index), "TextInfo_" .. nx_string(text_type), "")
    qizi_text = gui.TextManager:GetText(qizi_text)
    text = nx_widestr("<font color=\"#FFCC00\">") .. nx_widestr(gui.TextManager:GetText(qiju_name)) .. nx_widestr("</font><br>") .. nx_widestr(qiju_text) .. nx_widestr("<br><s>") .. nx_widestr(qizi_text)
  end
  form.mltbox_text:Clear()
  if nx_widestr(text) ~= nx_widestr("") then
    form.mltbox_text:AddHtmlText(nx_widestr(text), nx_int(-1))
    form.mltbox_text.Height = form.mltbox_text:GetContentHeight() + 10
    form.groupbox_tips.Height = form.mltbox_text.Height + 20
  else
    form.mltbox_text.Height = 0
    form.groupbox_tips.Height = 0
  end
  form.mltbox_text.ViewRect = "1,1," .. nx_string(form.mltbox_text.Width) .. "," .. nx_string(form.mltbox_text.Height)
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
    local weiqigame = nx_value("WeiqiGame")
    weiqigame:SendError()
  end
end
function set_game_name(name)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    form.lbl_game_name.Text = nx_widestr(gui.TextManager:GetText(name))
    qiju_name = name
  end
end
function set_player_type(player_type)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form) then
    form.PlayerType = player_type
  end
end
function set_qipan_type(qipan_type)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.qipanType = qipan_type
  local grid = form.imagegrid_weiqi
  if qipan_type == 0 then
    grid.Left = 134
    grid.Top = 34
    grid.Width = 513
    grid.Height = 513
    grid.RowNum = 9
    grid.ClomnNum = 9
    grid.GridWidth = 57
    grid.GridHeight = 57
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid1.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan1.png"
  elseif qipan_type == 1 then
    grid.Left = 145
    grid.Top = 45
    grid.Width = 500
    grid.Height = 500
    grid.RowNum = 13
    grid.ClomnNum = 13
    grid.GridWidth = 37
    grid.GridHeight = 37
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid2.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan2.png"
  elseif qipan_type == 2 then
    grid.Left = 152
    grid.Top = 52
    grid.Width = 477
    grid.Height = 477
    grid.RowNum = 19
    grid.ClomnNum = 19
    grid.GridWidth = 25
    grid.GridHeight = 25
    grid.ViewRect = "0,0" .. "," .. nx_string(grid.Width) .. "," .. nx_string(grid.Height)
    form.lbl_grid_back.BackImage = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_grid.png"
    cover_image = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_quan.png"
  end
end
function set_total_errortime(times)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  if times < 0 then
    return
  end
  form.lbl_light1.Visible = false
  form.lbl_light2.Visible = false
  form.lbl_light3.Visible = false
  total_errortimes = times
  if times == 0 then
    form.lbl_light2.Visible = true
  elseif times == 1 then
    form.lbl_light1.Visible = true
    form.lbl_light2.Visible = true
    form.lbl_light1.Left = 24
    form.lbl_light2.Left = 72
  elseif 2 <= times then
    form.lbl_light1.Visible = true
    form.lbl_light2.Visible = true
    form.lbl_light3.Visible = true
  end
end
function set_errortime(times)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  if total_errortimes == 1 then
    if times == 0 then
      form.lbl_light2.BackImage = "gui\\mainform\\smallgame\\life_down.png"
    end
  elseif 2 <= total_errortimes then
    if times == 1 then
      form.lbl_light3.BackImage = "gui\\mainform\\smallgame\\life_down.png"
    elseif times == 0 then
      form.lbl_light2.BackImage = "gui\\mainform\\smallgame\\life_down.png"
    end
  end
end
function set_robot_name(qizi_type, name)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  player_name = client_player:QueryProp("Name")
  robot_name = name
  if qizi_type == 0 then
    form.lbl_name2.Text = nx_widestr(gui.TextManager:GetText(robot_name))
    form.lbl_name1.Text = nx_widestr(player_name)
  elseif qizi_type == 1 then
    form.lbl_name1.Text = nx_widestr(gui.TextManager:GetText(robot_name))
    form.lbl_name2.Text = nx_widestr(player_name)
  end
end
function set_game_diff(diff)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if nx_is_valid(form) then
    form.Diff = diff
  end
end
function set_game_type(game_type)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  if game_type == 0 then
    form.btn_yanshi.Visible = false
    form.btn_break_yanshi.Visible = false
    form.btn_start.Visible = true
  elseif game_type == 1 then
    local res_use_vip = nx_execute("form_stage_main\\form_life\\form_job_main_new", "is_culture_job_use_vip")
    form.b_use_vip = nx_boolean(res_use_vip)
    if res_use_vip then
      form.btn_yanshi.NormalImage = "gui\\language\\ChineseS\\minigame\\start-out.png"
      form.btn_yanshi.FocusImage = "gui\\language\\ChineseS\\minigame\\start-on.png"
      form.btn_yanshi.PushImage = "gui\\language\\ChineseS\\minigame\\start-down.png"
    else
      form.btn_yanshi.NormalImage = "gui\\language\\ChineseS\\yanshi-out.png"
      form.btn_yanshi.FocusImage = "gui\\language\\ChineseS\\yanshi-on.png"
      form.btn_yanshi.PushImage = "gui\\language\\ChineseS\\yanshi-down.png"
    end
    form.btn_yanshi.Visible = true
    form.btn_break_yanshi.Visible = false
    form.btn_start.Visible = false
  end
end
function set_qizi_effect(effType)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.QiziEffect = effType
end
function set_game_state(state)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.GameState = state
end
function set_help_text(text)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.helptext = "ui_smallgame_bz_qis"
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  local weiqigame = nx_value("WeiqiGame")
  if nx_is_valid(weiqigame) then
    weiqigame:StartGame()
  end
end
function on_btn_yanshi_click(btn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  form.btn_break_yanshi.Visible = true
  if nx_find_custom(form, "b_use_vip") and form.b_use_vip then
    form.btn_break_yanshi.Visible = false
  end
  local weiqigame = nx_value("WeiqiGame")
  if nx_is_valid(weiqigame) then
    weiqigame:StartYanshi()
  end
end
function on_start_yanshi()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local zi_type = gui.TextManager:GetText("ui_qishi_white")
  if form.PlayerType == 1 then
    zi_type = gui.TextManager:GetText("ui_qishi_black")
  end
  show_ani_text(util_format_string("ui_qishi_remind", zi_type))
end
function on_end_yanshi()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.btn_yanshi.Visible = false
  form.btn_break_yanshi.Visible = false
  form.btn_start.Visible = true
  show_ani_text(gui.TextManager:GetText("ui_qishi_end"))
end
function on_count_down_time(times)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_tips.Text = ""
  form.lbl_tips.Visible = true
  form.lbl_tips.Width = form.lbl_tips.Height
  form.lbl_tips.Left = form.imagegrid_weiqi.Left + (form.imagegrid_weiqi.Width - form.lbl_tips.Width) / 2
  if times == 5 then
    form.lbl_tips.BackImage = "gui\\language\\ChineseS\\minigame\\five.png"
  elseif times == 4 then
    form.lbl_tips.BackImage = "gui\\language\\ChineseS\\minigame\\four.png"
  elseif times == 3 then
    form.lbl_tips.BackImage = "gui\\language\\ChineseS\\minigame\\three.png"
  elseif times == 2 then
    form.lbl_tips.BackImage = "gui\\language\\ChineseS\\minigame\\two.png"
  elseif times == 1 then
    form.lbl_tips.BackImage = "gui\\language\\ChineseS\\minigame\\one.png"
  end
end
function on_btn_break_yanshi_click(btn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  form.btn_start.Visible = true
  local weiqigame = nx_value("WeiqiGame")
  if nx_is_valid(weiqigame) then
    weiqigame:BreakYanshi()
  end
end
function on_start_game(turn)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.groupbox_light.Visible = true
  if turn == 1 then
    show_ani_text(gui.TextManager:GetText("ui_YourTurn"))
  elseif turn == 2 then
    show_ani_text(gui.TextManager:GetText("ui_qishi_go"))
  end
end
function on_update_time(progress)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.pebar_time.Value = progress
end
function on_chizi(ori_type, num)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local zi_type = gui.TextManager:GetText("ui_qishi_white")
  local name = ""
  if ori_type == 0 then
    if form.PlayerType == 0 then
      zi_type = gui.TextManager:GetText("ui_qishi_black")
    end
    name = player_name
  elseif ori_type == 1 then
    if form.PlayerType == 1 then
      zi_type = gui.TextManager:GetText("ui_qishi_black")
    end
    name = gui.TextManager:GetText(robot_name)
  end
  local text = nx_widestr(name) .. util_format_string("ui_qishi_kill", zi_type, num)
  show_ani_text(text)
end
function on_imagegrid_weiqi_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.imagegrid_weiqi:IsEmpty(index) then
    return
  end
  local weiqigame = nx_value("WeiqiGame")
  if not nx_is_valid(weiqigame) then
    return
  end
  weiqigame:KeyDown(index)
end
function on_imagegrid_weiqi_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not grid:IsEmpty(index) then
    return
  end
end
function on_imagegrid_weiqi_mouseout_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
end
function add_qizi(turn, grid_index, qizi_index)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  if grid_index < 0 or 361 < grid_index then
    return
  end
  if not form.imagegrid_weiqi:IsEmpty(grid_index) then
    return
  end
  form.imagegrid_weiqi:SetItemMark(grid_index, -1)
  if turn == 0 then
    form.imagegrid_weiqi:AddItem(grid_index, qizi_bai, "", 1, -1)
  elseif turn == 1 then
    form.imagegrid_weiqi:AddItem(grid_index, qizi_hei, "", 1, -1)
  end
  if qizi_index ~= nil and 0 < qizi_index then
    on_qizi_effect(form, grid_index, qizi_index)
  end
end
function on_qizi_effect(form, grid_index, qizi_index)
  if form.QiziEffect > 3 or 3 < form.GameState then
    return
  end
  if form.QiziEffect == 0 then
    if form.GameState == 2 or form.GameState == 3 then
      form.imagegrid_weiqi:SetItemCoverImage(grid_index, cover_image)
      form.imagegrid_weiqi:CoverItem(grid_index, true)
      on_del_effect(form, form.LastIndex)
      form.LastIndex = grid_index
      local timer = nx_value(GAME_TIMER)
      timer:Register(2000, 1, "form_stage_main\\form_small_game\\form_game_weiqi", "on_del_effect", form, grid_index, -1)
    end
    return
  end
  if form.GameState == 2 then
    if form.QiziEffect == 2 then
      return
    end
  elseif form.GameState == 3 then
    if form.QiziEffect == 1 then
      return
    end
  else
    return
  end
  local photo = "gui\\mainform\\smallgame\\weiqi_game\\number\\" .. nx_string(qizi_index) .. ".png"
  if form.qipanType == 1 then
    photo = "gui\\mainform\\smallgame\\weiqi_game\\number37\\" .. nx_string(qizi_index) .. ".png"
  elseif form.qipanType == 2 then
    photo = "gui\\mainform\\smallgame\\weiqi_game\\number25\\" .. nx_string(qizi_index) .. ".png"
  end
  form.imagegrid_weiqi:SetItemCoverImage(grid_index, photo)
  form.imagegrid_weiqi:CoverItem(grid_index, true)
end
function on_del_effect(form, index)
  local index = nx_int(index)
  form.imagegrid_weiqi:SetItemCoverImage(index, "")
  form.imagegrid_weiqi:CoverItem(index, false)
end
function del_qizi(index)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  if index < 0 or 361 < index then
    return
  end
  if form.imagegrid_weiqi:IsEmpty(index) then
    return
  end
  form.imagegrid_weiqi:DelItem(index)
  on_del_effect(form, index)
end
function clear_qipan()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.imagegrid_weiqi:Clear()
end
function on_error_time()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  show_ani_text(gui.TextManager:GetText("ui_qishi_error"))
end
function on_end_game(res)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister("form_stage_main\\form_small_game\\form_game_weiqi", "on_update_time", form)
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
  timer:Register(2500, 1, "form_stage_main\\form_small_game\\form_game_weiqi", "auto_close_form", form, -1, -1)
end
function auto_close_form(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_help_click(self)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
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
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_back.BlendAlpha = form.groupbox_back.BlendAlpha - delta
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  refresh_form_pos(form)
end
function show_ani_text(text)
  local form = nx_value("form_stage_main\\form_small_game\\form_game_weiqi")
  if not nx_is_valid(form) then
    return
  end
  form.lbl_tips.Visible = true
  form.lbl_tips.Text = nx_widestr(text)
  form.lbl_tips.Width = form.lbl_tips.TextWidth * 2
  form.lbl_tips.Left = form.imagegrid_weiqi.Left + (form.imagegrid_weiqi.Width - form.lbl_tips.Width) / 2
  local timer = nx_value(GAME_TIMER)
  timer:Register(2000, 1, "form_stage_main\\form_small_game\\form_game_weiqi", "on_del_ani_text", form.lbl_tips, -1, -1)
end
function on_del_ani_text(lbl)
  lbl.Text = nx_widestr("")
  lbl.Visible = false
end
