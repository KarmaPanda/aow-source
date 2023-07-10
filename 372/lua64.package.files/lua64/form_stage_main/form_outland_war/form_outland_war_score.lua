require("util_gui")
require("custom_sender")
local CTS_SUB_MSG_OUTLAND_WAR_SORT_LIST = 11
local CTS_SUB_MSG_OUTLAND_WAR_ACHIEVEMENT = 12
local PARAM = 2
local FORM_NAME = "form_stage_main\\form_outland_war\\form_outland_war_score"
function main_form_init(form)
  form.Fixed = true
end
function open_form()
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width * 2 + form.lbl_11.Width) / 2
    form.Top = (gui.Height - form.Height * 2 + form.lbl_11.Height) / 2
  end
  form.Visible = true
  form:Show()
  local gui = nx_value("gui")
  custom_outland_war(11)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  close_form()
end
function open_or_hide()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    form:Show()
    form.Visible = true
    return
  end
  if form.Visible then
    form.Visible = false
  else
    form:Show()
    form.Visible = true
    custom_outland_war(11)
  end
end
function on_ani_1_animation_end()
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_int(PARAM) == nx_int(1) then
    form.ani_1.AnimationImage = "outland_2"
    form.ani_1.Loop = "true"
    form.ani_1.PlayMode = "0"
    form.ani_1.independent = "true"
  elseif nx_int(PARAM) == nx_int(-1) then
    form.ani_1.AnimationImage = "outland_4"
    form.ani_1.Loop = "true"
    form.ani_1.PlayMode = "0"
    form.ani_1.independent = "true"
  elseif nx_int(PARAM) == nx_int(0) then
    form.ani_1.AnimationImage = "outland_6"
    form.ani_1.Loop = "true"
    form.ani_1.PlayMode = "0"
    form.ani_1.independent = "true"
  elseif nx_int(PARAM) == nx_int(2) then
    form.ani_1.AnimationImage = ""
  end
end
function update_meet(...)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
  form.Visible = true
  if form.ani_1.AnimationImage ~= "" then
  elseif form.ani_1.AnimationImage == "" then
    local camp_win = nx_int(arg[2])
    PARAM = nx_int(camp_win)
    if camp_win == nx_int(1) then
      form.ani_1.AnimationImage = "outland_1"
      form.ani_1.Loop = "false"
      form.ani_1.PlayMode = "0"
      form.ani_1.independent = "true"
      nx_callback(form.ani_1, "on_animation_end", "on_ani_1_animation_end")
    elseif camp_win == nx_int(-1) then
      form.ani_1.AnimationImage = "outland_3"
      form.ani_1.Loop = "false"
      form.ani_1.PlayMode = "0"
      form.ani_1.independent = "true"
      nx_callback(form.ani_1, "on_animation_end", "on_ani_1_animation_end")
    elseif camp_win == nx_int(0) then
      form.ani_1.AnimationImage = "outland_5"
      form.ani_1.Loop = "false"
      form.ani_1.PlayMode = "0"
      form.ani_1.independent = "true"
      nx_callback(form.ani_1, "on_animation_end", "on_ani_1_animation_end")
    elseif camp_win == nx_int(2) then
      form.ani_1.AnimationImage = ""
    end
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName("sys_outlandwar_lpf008")
  gui.TextManager:Format_AddParam(nx_int(arg[3]))
  form.lbl_4.Text = nx_widestr(gui.TextManager:Format_GetText())
  gui.TextManager:Format_SetIDName("sys_outlandwar_lpf009")
  gui.TextManager:Format_AddParam(nx_int(arg[4]))
  form.lbl_22.Text = nx_widestr(gui.TextManager:Format_GetText())
  local score_info = util_split_wstring(arg[1], ";")
  if 0 >= table.getn(score_info) then
    return
  end
  form.textgrid_meet:ClearRow()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local name = client_player:QueryProp("Name")
  for i = 1, table.getn(score_info) - 1 do
    local player_info = util_split_wstring(score_info[i], ",")
    local player_school = nx_widestr(player_info[1])
    local player_name = nx_widestr(player_info[2])
    local player_kill = nx_widestr(player_info[3])
    local player_dead = nx_widestr(player_info[4])
    local player_damage = nx_widestr(player_info[5])
    local player_strive = nx_widestr(player_info[6])
    local player_goods = nx_widestr(player_info[7])
    local player_score = nx_widestr(player_info[8])
    local player_pvp_damage = nx_widestr(player_info[9])
    local be_eliminated = nx_int(player_info[10])
    local row = form.textgrid_meet:InsertRow(-1)
    if nx_widestr(player_school) == nx_widestr("") then
      form.textgrid_meet:SetGridText(row, 0, util_text("school_wulin"))
    else
      form.textgrid_meet:SetGridText(row, 0, util_text(nx_string(player_school)))
    end
    form.textgrid_meet:SetGridText(row, 1, nx_widestr(player_name))
    form.textgrid_meet:SetGridText(row, 2, nx_widestr(player_kill))
    form.textgrid_meet:SetGridText(row, 3, nx_widestr(player_dead))
    form.textgrid_meet:SetGridText(row, 4, nx_widestr(player_damage))
    form.textgrid_meet:SetGridText(row, 5, nx_widestr(player_strive))
    form.textgrid_meet:SetGridText(row, 6, nx_widestr(player_goods))
    form.textgrid_meet:SetGridText(row, 7, nx_widestr(player_score))
    form.textgrid_meet:SetGridText(row, 8, nx_widestr(player_pvp_damage))
    if nx_widestr(name) == nx_widestr(player_name) then
      for i = 0, form.textgrid_meet.ColCount - 1 do
        form.textgrid_meet:SetGridForeColor(row, i, "255,230,93,70")
      end
    end
    create_eliminate_button(form, row, 9, be_eliminated, nx_string(player_name))
  end
  form.textgrid_meet:SortRowsByInt(9, true)
end
function on_btn_quit_click(btn)
  local form = util_get_form(FORM_NAME, true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText("ui_outland_war_quit")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    custom_outland_war(7)
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function create_eliminate_button(form, row, col, be_eliminated, player_name)
  if nx_int(1) ~= be_eliminated then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local button = gui:Create("Button")
  if not nx_is_valid(button) then
    return
  end
  button.Name = "btn_eliminate_" .. nx_string(row)
  button.Text = gui.TextManager:GetText("tips_battlefield_KickOut")
  button.ForeColor = "255,255,255,255"
  button.HintText = gui.TextManager:GetText("tips_battlefield_KickOutDec")
  button.DataSource = nx_string(player_name)
  button.DrawMode = "FitWindow"
  button.NormalImage = "gui\\common\\button\\btn_normal1_out.png"
  button.FocusImage = "gui\\common\\button\\btn_normal1_on.png"
  button.PushImage = "gui\\common\\button\\btn_normal1_down.png"
  button.Visible = true
  nx_bind_script(button, nx_current())
  nx_callback(button, "on_click", "on_btn_eliminate_click")
  form.textgrid_meet:ClearGridControl(row, col)
  form.textgrid_meet:SetGridControl(row, col, button)
end
function on_btn_eliminate_click(btn)
  local name = nx_string(btn.DataSource)
  if nil == name or "" == name then
    return
  end
  custom_outland_war(14, nx_widestr(name))
end
