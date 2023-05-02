require("const_define")
require("util_functions")
require("util_gui")
local form_name = "form_stage_main\\form_small_game\\form_game_wq"
local qizi_bai = "gui\\mainform\\smallgame\\qi_game\\white_22.png"
local qizi_hei = "gui\\mainform\\smallgame\\qi_game\\black_22.png"
local cover_white_image = "gui\\mainform\\smallgame\\qi_game\\w_point.png"
local cover_black_image = "gui\\mainform\\smallgame\\qi_game\\b_point.png"
local QZSTATE_EMPTY = 46
local QZSTATE_WHITE = 79
local QZSTATE_BLACK = 88
local QZSTATE_LAST_WHITE = 80
local QZSTATE_LAST_BLACK = 89
local MOYO_WHITE = 119
local MOYO_BLACK = 98
local MIN_GUI_HEIGHT = 720
local MIN_QIPAN_HEIGHT = 770
local col_char = {
  [1] = "a",
  [2] = "b",
  [3] = "c",
  [4] = "d",
  [5] = "e",
  [6] = "f",
  [7] = "g",
  [8] = "h",
  [9] = "i",
  [10] = "j",
  [11] = "k",
  [12] = "l",
  [13] = "m",
  [14] = "n",
  [15] = "o",
  [16] = "p",
  [17] = "q",
  [18] = "r",
  [19] = "s"
}
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  nx_execute("gui", "gui_close_allsystem_form")
  refresh_form_pos(self)
  refresh_tizi(0, 0)
  nx_execute(nx_current(), "show_form_chat")
  self.Visible = true
  update_lookers("")
end
function open_form(play_type)
  local form = util_get_form(form_name, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  init_form(form, play_type)
end
function set_self_face(color)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
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
  if color == 1 then
    form.lbl_wobj_pic.BackImage = client_player:QueryProp("Photo")
    form.lbl_wname.Text = client_player:QueryProp("Name")
  elseif color == 2 then
    form.lbl_bobj_pic.BackImage = client_player:QueryProp("Photo")
    form.lbl_bname.Text = client_player:QueryProp("Name")
  end
  form.lbl_wname.Left = form.lbl_wobj_pic.Left + form.lbl_wobj_pic.Width
end
function set_obj_face(color, obj)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene_obj = game_client:GetSceneObj(nx_string(obj))
  if not nx_is_valid(client_scene_obj) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local name = ""
  local obj_type = client_scene_obj:QueryProp("Type")
  if obj_type == 2 then
    name = client_scene_obj:QueryProp("Name")
  elseif obj_type == 4 then
    local configid = client_scene_obj:QueryProp("ConfigID")
    name = gui.TextManager:GetText(configid)
  end
  if color == 1 then
    form.lbl_wobj_pic.BackImage = client_scene_obj:QueryProp("Photo")
    form.lbl_wname.Text = name
  elseif color == 2 then
    form.lbl_bobj_pic.BackImage = client_scene_obj:QueryProp("Photo")
    form.lbl_bname.Text = name
  end
end
function set_origin(color, originid)
  if nx_int(originid) < nx_int(1) then
    return
  end
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local originstr = gui.TextManager:GetText("role_title_" .. nx_string(originid))
  if color == 1 then
    form.lbl_wname_origin.Text = nx_widestr(originstr)
  elseif color == 2 then
    form.lbl_bname_origin.Text = nx_widestr(originstr)
  end
end
function show_form_chat()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form_chat = nx_value("form_stage_main\\form_main\\form_main_chat")
  if not nx_is_valid(form_chat) then
    return
  end
  form_chat.Visible = true
  form.Parent:ToFront(form_chat)
end
function init_form(form, play_type)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_last_move.Visible = false
  form.lbl_wturn_pic.Visible = false
  form.lbl_bturn_pic.Visible = false
  form.lbl_wobj_pic.BackImage = ""
  form.lbl_bobj_pic.BackImage = ""
  if play_type == 0 or play_type == 1 then
    form.btn_score.Visible = false
    form.btn_pass.Visible = false
    form.btn_estimate_moyo.Visible = false
    form.btn_pause.Visible = false
    form.btn_score.Enabled = false
    gui.Focused = form.btn_start
  elseif play_type == 2 then
    form.btn_score.Visible = false
    form.btn_pass.Visible = false
    form.btn_estimate_moyo.Visible = true
    form.btn_pause.Visible = false
    form.btn_start.Visible = false
  end
end
function set_allow_control(allow)
  local scene = nx_value("game_scene")
  if not nx_is_valid(scene) then
    return
  end
  local game_control = scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.AllowControl = allow
end
function refresh_form_pos(form)
  local gui = nx_value("gui")
  form.AbsLeft = 0
  form.AbsTop = 0
  form.Width = gui.Width
  form.Height = gui.Height
  form.groupbox_main.AbsLeft = 0
  form.groupbox_main.AbsTop = 0
  form.groupbox_main.Width = gui.Width
  form.groupbox_main.Height = gui.Height
  form.groupbox_info.Left = (form.groupbox_main.Width - form.groupbox_info.Width) / 2
  form.groupbox_info.Top = (form.groupbox_main.Height - form.groupbox_info.Height) / 50
  form.groupbox_qipan.Left = (form.groupbox_main.Width - form.groupbox_qipan.Width) / 2 + form.groupbox_qipan.Width / 16
  form.groupbox_qipan.Top = form.groupbox_info.Top + form.groupbox_info.Height
  if gui.Height < MIN_QIPAN_HEIGHT then
    form.groupbox_qipan.Top = form.groupbox_qipan.Top - (MIN_QIPAN_HEIGHT - gui.Height)
  end
  form.groupbox_tips.Left = -form.groupbox_tips.Width
  form.groupbox_tips.Top = form.groupbox_qipan.Top + form.groupbox_qipan.Height / 7
end
function on_main_form_close(self)
  nx_execute("gui", "gui_open_closedsystem_form")
  nx_destroy(self)
  local wqgame = nx_value("WqGame")
  if nx_is_valid(wqgame) then
    wqgame:ExitGameForm()
  end
end
function on_btn_close_click(btn)
  show_close_dialog(btn.ParentForm)
end
function cancel_game()
  local form = nx_value(form_name)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_start_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  btn.Visible = false
  local wqgame = nx_value("WqGame")
  if nx_is_valid(wqgame) then
    wqgame:StartGame()
  end
end
function on_btn_estimate_moyo_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  local res = wqgame:OpenClosEestimate()
  if not res then
    local grid = form.imagegrid_weiqi
    for i = 1, grid.RowNum * grid.ClomnNum do
      grid:CoverItem(i - 1, false)
    end
  end
end
function on_btn_score_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  wqgame:RequestScore()
end
function on_btn_pass_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  wqgame:DoPass()
end
function on_btn_pause_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  wqgame:Pause()
end
function show_wqgame_history_move(cur_num, color, index)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local row = nx_int(index / 19) + 1
  local col = nx_int(index % 19) + 1
  local hei_text = gui.TextManager:GetText("ui_qishi_black")
  local bai_text = gui.TextManager:GetText("ui_qishi_white")
  local text = nx_widestr(cur_num) .. nx_widestr(".")
  if color == 1 then
    text = text .. bai_text .. nx_widestr("(") .. nx_widestr(col) .. nx_widestr(",") .. nx_widestr(row) .. nx_widestr(")")
  elseif color == 2 then
    text = text .. hei_text .. nx_widestr("(") .. nx_widestr(col) .. nx_widestr(",") .. nx_widestr(row) .. nx_widestr(")")
  end
  form.mltbox_history:AddHtmlText(text, -1)
end
function show_wqgame_history_pass(cur_num, color)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local hei_text = gui.TextManager:GetText("ui_qishi_black")
  local bai_text = gui.TextManager:GetText("ui_qishi_white")
  local pas_text = gui.TextManager:GetText("ui_qishi_pass")
  local text = nx_widestr(cur_num) .. nx_widestr(".")
  if color == 1 then
    text = text .. bai_text .. nx_widestr(pas_text)
  elseif color == 2 then
    text = text .. hei_text .. nx_widestr(pas_text)
  end
  form.mltbox_history:AddHtmlText(text, -1)
end
function refresh_imagegrid(board, cur_num, cur_score)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grid = form.imagegrid_weiqi
  for i = 1, string.len(board) do
    local str = string.byte(board, i)
    if str == QZSTATE_BLACK then
      grid:AddItem(i - 1, qizi_hei, "", 1, -1)
    elseif str == QZSTATE_LAST_BLACK then
      grid:AddItem(i - 1, qizi_hei, "", 1, -1)
      form.lbl_last_move.Visible = true
      form.lbl_last_move.Left = grid.Left + grid:GetItemLeft(i - 1) - 1
      form.lbl_last_move.Top = grid.Top + grid:GetItemTop(i - 1) - 3
    elseif str == QZSTATE_WHITE then
      grid:AddItem(i - 1, qizi_bai, "", 1, -1)
    elseif str == QZSTATE_LAST_WHITE then
      grid:AddItem(i - 1, qizi_bai, "", 1, -1)
      form.lbl_last_move.Visible = true
      form.lbl_last_move.Left = grid.Left + grid:GetItemLeft(i - 1) - 1
      form.lbl_last_move.Top = grid.Top + grid:GetItemTop(i - 1) - 3
    elseif not grid:IsEmpty(i - 1) then
      grid:DelItem(i - 1)
    end
  end
  if 20 <= cur_num then
    if cur_score < 0 then
      form.lbl_score.Text = gui.TextManager:GetText("ui_qishi_fenshu") .. nx_widestr(":") .. nx_widestr(-cur_score)
    else
      form.lbl_score.Text = gui.TextManager:GetText("ui_qishi_fenshu1") .. nx_widestr(":") .. nx_widestr(cur_score)
    end
  end
end
function refresh_imagegrid_estimate(board)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local grid = form.imagegrid_weiqi
  for i = 1, string.len(board) do
    local str = string.byte(board, i)
    if str == MOYO_WHITE then
      grid:CoverItem(i - 1, true)
      grid:SetItemCoverImage(i - 1, cover_white_image)
    elseif str == MOYO_BLACK then
      grid:CoverItem(i - 1, true)
      grid:SetItemCoverImage(i - 1, cover_black_image)
    else
      grid:CoverItem(i - 1, false)
    end
  end
end
function refresh_cur_color(color)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.lbl_wturn_pic.Visible = false
  form.lbl_bturn_pic.Visible = false
  if color == 1 then
    form.lbl_wturn_pic.Visible = true
  elseif color == 2 then
    form.lbl_bturn_pic.Visible = true
  end
end
function request_score()
  nx_execute(nx_current(), "request_score_async")
end
function request_score_async()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local text = gui.TextManager:GetText("ui_qishi_jssq")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    wqgame:RequestScoreResult(1)
  else
    wqgame:RequestScoreResult(0)
  end
end
function refresh_mltbox_text(cur_num, cur_score)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
end
function refresh_time(total_time, color, color_time)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local minute = nx_int(total_time / 60)
  local second = nx_int(total_time % 60)
  local minute_text = nx_widestr(minute)
  if minute < nx_int(10) then
    minute_text = nx_widestr("0") .. nx_widestr(minute)
  end
  local second_text = nx_widestr(second)
  if second < nx_int(10) then
    second_text = nx_widestr("0") .. nx_widestr(second)
  end
  local total_text = nx_widestr("")
  if minute == nx_int(0) then
    total_text = second_text
  else
    total_text = minute_text .. nx_widestr(":") .. second_text
  end
  form.lbl_total_time.Text = total_text
  if color == 1 then
    form.lbl_wdaojishi.Text = nx_widestr(color_time)
    form.lbl_bdaojishi.Text = nx_widestr("")
  elseif color == 2 then
    form.lbl_wdaojishi.Text = nx_widestr("")
    form.lbl_bdaojishi.Text = nx_widestr(color_time)
  end
end
function refresh_success_failed(color, success, failed)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local success_text = nx_widestr(gui.TextManager:GetText("ui_life_qis_4"))
  local ci_text = nx_widestr(gui.TextManager:GetText("ui_ci"))
  local failed_text = nx_widestr(gui.TextManager:GetText("ui_life_qis_5"))
  success = nx_widestr("<font color=\"#70421A\">") .. nx_widestr(success) .. nx_widestr("</font>")
  failed = nx_widestr("<font color=\"#700C2F\">") .. nx_widestr(failed) .. nx_widestr("</font>")
  local text = success_text .. nx_widestr(":") .. success .. ci_text .. nx_widestr("  ") .. failed_text .. nx_widestr(":") .. failed .. ci_text
  if color == 1 then
    form.MltBox_wsf_times.HtmlText = text
  elseif color == 2 then
    form.MltBox_bsf_times.HtmlText = text
  end
end
function refresh_tizi(black, white)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local tizi_text = gui.TextManager:GetText("ui_life_qis_6")
  local ci_text = gui.TextManager:GetText("ui_ci")
  form.MltBox_wtizi.HtmlText = tizi_text .. nx_widestr(": ") .. nx_widestr("x") .. nx_widestr(white) .. ci_text
  form.MltBox_btizi.HtmlText = tizi_text .. nx_widestr(": ") .. nx_widestr("x") .. nx_widestr(black) .. ci_text
end
function update_lookers(...)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  form.mltbox_lookers:Clear()
  local num = 0
  for i, para in pairs(arg) do
    local client_scene_obj = game_client:GetSceneObj(nx_string(para))
    if nx_is_valid(client_scene_obj) then
      local name = client_scene_obj:QueryProp("Name")
      form.mltbox_lookers:AddHtmlText(nx_widestr(name), -1)
      num = num + 1
    end
  end
  form.lbl_lookers.Text = util_format_string("ui_qishi_pg", nx_int(num))
end
function btn_pass_enabled(enabled)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.btn_pass.Enabled = enabled
end
function btn_score_enabled(enabled)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.btn_score.Enabled = enabled
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
  end
end
function on_start_game()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.btn_score.Visible = true
  form.btn_estimate_moyo.Visible = true
  form.lbl_wobj_pic_ready.Text = nx_widestr("")
  form.lbl_bobj_pic_ready.Text = nx_widestr("")
end
function on_ready_game(color)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if color == 1 then
    form.lbl_wobj_pic_ready.Text = gui.TextManager:GetText("ui_zhunbeiok")
  elseif color == 2 then
    form.lbl_bobj_pic_ready.Text = gui.TextManager:GetText("ui_zhunbeiok")
  end
end
function on_imagegrid_weiqi_select_changed(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.imagegrid_weiqi:IsEmpty(index) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  wqgame:KeyDown(index)
end
function looker_show_score(color, score)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local hei_text = gui.TextManager:GetText("ui_qishi_black")
  local bai_text = gui.TextManager:GetText("ui_qishi_white")
  form.lbl_tips.Visible = true
  if color == 1 then
    form.lbl_tips.Text = util_format_string("ui_qishi_score", bai_text)
  elseif color == 2 then
    form.lbl_tips.Text = util_format_string("ui_qishi_score", hei_text)
  else
    form.lbl_tips.Text = gui.TextManager:GetText("ui_qishi_failed")
  end
end
function on_imagegrid_weiqi_mousein_grid(grid, index)
  local form = grid.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local wqgame = nx_value("WqGame")
  if not nx_is_valid(wqgame) then
    return
  end
  if wqgame:IsCanPlay() then
    form.imagegrid_weiqi.DrawMouseIn = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_mouse.png"
  else
    form.imagegrid_weiqi.DrawMouseIn = "gui\\mainform\\smallgame\\weiqi_game\\weiqi_mouse3.png"
  end
end
function on_imagegrid_weiqi_mouseout_grid(grid, index)
  return
end
function on_end_game(res)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
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
  timer:Register(3000, 1, form_name, "on_del_res_pic", form, -1, -1)
end
function on_del_res_pic(form)
  if not nx_is_valid(form) then
    return
  end
  local lbl = form:Find("lab_res")
  if nx_is_valid(lbl) then
    lbl.Visible = false
  end
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_help_click(self)
  nx_execute("form_stage_main\\form_help\\form_help_AllGui_New", "init_help_form", "ini\\ui\\life\\help_qis.ini")
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function change_form_size()
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  refresh_form_pos(form)
end
function set_btn_pause_text(text_type)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if text_type == 1 then
    form.btn_pause.Text = gui.TextManager:GetText("ui_redo")
  elseif text_type == 2 then
    form.btn_pause.Text = gui.TextManager:GetText("ui_zanting")
  end
end
function show_ani_text(text_type)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = nx_widestr("")
  if text_type == 1 then
    text = gui.TextManager:GetText("ui_zanting")
  elseif text_type == 2 then
    text = gui.TextManager:GetText("ui_redo")
  elseif text_type == 3 then
    text = gui.TextManager:GetText("ui_qishi_start")
  end
  form.lbl_tips.Visible = true
  form.lbl_tips.Text = text
  local timer = nx_value(GAME_TIMER)
  timer:Register(3000, 1, form_name, "on_del_ani_text", form.lbl_tips, -1, -1)
end
function on_del_ani_text(lbl)
  lbl.Text = nx_widestr("")
  lbl.Visible = false
end
