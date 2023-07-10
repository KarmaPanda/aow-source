require("util_gui")
require("util_functions")
require("form_stage_main\\form_battlefield_wulin\\wudao_util")
local FORM_WULIN_SEARCH = "form_stage_main\\form_battlefield_wulin\\form_wulin_search_team"
local wudao_tip_dissatisfy = "wudao_systeminfo_10101"
function main_form_init(self)
  self.Fixed = false
  self.limite = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_apply_join_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_widestr(form.mltbox_4.Text) == nx_widestr("") then
    return
  end
  custom_apply_join(nx_widestr(form.mltbox_4.Text))
end
function custom_apply_join(teamname)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WUDAO_WAR), nx_int(WuDaoWarClientMsg_APPLY_JOIN_BATTLE_TEAM), nx_widestr(teamname))
end
function rec_query_war_team_info(...)
  if not is_in_wudao_prepare_scene() then
    return
  end
  if nx_int(#arg) < nx_int(8) then
    return
  end
  local form_search = nx_value(FORM_WULIN_SEARCH)
  if nx_is_valid(form_search) and not form_search.Visible then
    form_search.Visible = true
  else
    util_show_form(FORM_WULIN_SEARCH, true)
  end
  local form = nx_value(FORM_WULIN_SEARCH)
  if not nx_is_valid(form) then
    return
  end
  local team_name = nx_widestr(arg[1])
  form.mltbox_4.Text = team_name
  local photo_index = nx_int(arg[2])
  local photo = nx_execute("form_stage_main\\form_battlefield_wulin\\form_wulin_main_team", "get_photo_by_index", photo_index)
  form.imagegrid_3:AddItem(0, photo, "", 1, -1)
  local rank = nx_int(arg[3])
  if nx_int(rank) == nx_int(-1) then
    form.lbl_36.Text = nx_widestr(util_text("ui_wudao_no_have_rank"))
  else
    form.lbl_36.Text = nx_widestr(rank)
  end
  local score = nx_int(arg[4])
  form.lbl_39.Text = nx_widestr(score)
  local win = nx_int(arg[5])
  form.lbl_46.Text = nx_widestr(win)
  local lost = nx_int(arg[6])
  form.lbl_47.Text = nx_widestr(lost)
  local limite = nx_int(arg[7])
  form.limite = limite
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.TextManager:Format_SetIDName("ui_wudao_win")
    gui.TextManager:Format_AddParam(limite)
    local text_limite = gui.TextManager:Format_GetText()
    form.lbl_2.Text = text_limite
  end
  local win_ratio = 0
  if nx_int(win + lost) ~= nx_int(0) then
    win_ratio = nx_number(win / (win + lost)) * 100
  end
  local str_ratio = string.format("%0.2f", win_ratio)
  form.lbl_45.Text = nx_widestr(str_ratio) .. nx_widestr("%")
  local team_member = nx_int(arg[8])
  gui.TextManager:Format_SetIDName("ui_wudao_common_8")
  gui.TextManager:Format_AddParam(team_member)
  local text_member = gui.TextManager:Format_GetText()
  form.lbl_3.Text = text_member
end
function close_form()
  local form = nx_value(FORM_WULIN_SEARCH)
  if nx_is_valid(form) then
    form:Close()
  end
end
