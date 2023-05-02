require("util_gui")
require("form_stage_main\\form_world_war\\form_world_war_define")
local FORM_NAME = "form_stage_main\\form_world_war\\form_world_war_nyitem"
local CLOSE_TIME = 180
local REFRESH_TIME = 1000
local TVT_NY_ITEM = 63
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Top = gui.Desktop.Height / 2 - form.Height / 2
  form.Left = gui.Desktop.Width / 2 - form.Width / 2
  form.count = 0
  form.force = -1
  form.btn_get.Visible = false
  form.groupbox_6.Visible = false
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("WorldWarForce", "int", form, nx_current(), "on_WorldWarForce_changed")
  change_form_size()
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("WorldWarForce", form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_lbl_left", form)
  end
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_update_lbl_left(form)
  local force = form.force
  if form.lbl_kuang.Left > 500 then
    form.lbl_kuang.Left = 0
  else
    form.lbl_kuang.Left = form.lbl_kuang.Left + 180
  end
  form.count = form.count + 1
  if form.count >= 30 and force ~= 0 then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_lbl_left", form)
      form.count = 0
    end
    if force == 1 then
      form.lbl_kuang.Left = 0
    elseif force == 2 then
      form.lbl_kuang.Left = 180
    elseif force == 3 then
      form.lbl_kuang.Left = 360
    elseif force == 4 then
      form.lbl_kuang.Left = 540
    end
    local label = nx_custom(form, "lbl_zq_" .. nx_string(force))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\zq_1.png"
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_lxc_zq_" .. nx_string(force))
    label = nx_custom(form, "lbl_zq_name_" .. nx_string(form.force))
    if nx_is_valid(label) then
      label.Text = text
    end
  end
end
function on_btn_get_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), CLIENT_WORLDWAR_TRAITOR_ITEM, nx_int(1))
  btn.Visible = false
end
function request_open_form(force)
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
  form.force = force
  local timer = nx_value(GAME_TIMER)
  timer:Register(100, -1, nx_current(), "on_update_lbl_left", form, -1, -1)
end
function request_close_form()
  local form = nx_value(FORM_NAME)
  if nx_is_valid(form) then
    form:Close()
  end
end
function show_form(force)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if form.force ~= -1 then
    local label = nx_custom(form, "lbl_zq_" .. nx_string(form.force))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\zq_2.png"
    end
    label = nx_custom(form, "lbl_ny_" .. nx_string(form.force))
    if nx_is_valid(label) then
      label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\lx_ny_1.png"
    end
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("ui_lxc_ny_" .. nx_string(force))
    label = nx_custom(form, "lbl_ny_name_" .. nx_string(form.force))
    if nx_is_valid(label) then
      label.Text = text
    end
    label = nx_custom(form, "lbl_zq_name_" .. nx_string(form.force))
    if nx_is_valid(label) then
      label.Text = nx_widestr("")
    end
  end
  form.btn_get.Visible = true
  form.groupbox_5.Visible = true
  form.groupbox_6.Visible = false
  change_form_size()
end
function hide_form()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
end
function on_btn_hide_click(self)
  local form = self.ParentForm
  form.groupbox_5.Visible = false
  form.groupbox_6.Visible = true
end
function on_WorldWarForce_changed()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if form.force == -1 then
    return
  end
  if nx_running(nx_current(), "on_update_lbl_left") then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "on_update_lbl_left", form)
    end
  end
  local label = nx_custom(form, "lbl_zq_" .. nx_string(form.force))
  if nx_is_valid(label) then
    label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\zq_2.png"
  end
  label = nx_custom(form, "lbl_ny_" .. nx_string(form.force))
  if nx_is_valid(label) then
    label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\lx_ny_2.png"
  end
  label = nx_custom(form, "lbl_ny_name_" .. nx_string(form.force))
  if nx_is_valid(label) then
    label.Text = nx_widestr("")
  end
  label = nx_custom(form, "lbl_zq_name_" .. nx_string(form.force))
  if nx_is_valid(label) then
    label.Text = nx_widestr("")
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  local force = player:QueryProp("WorldWarForce")
  if force == 1 then
    form.lbl_kuang.Left = 0
  elseif force == 2 then
    form.lbl_kuang.Left = 180
  elseif force == 3 then
    form.lbl_kuang.Left = 360
  elseif force == 4 then
    form.lbl_kuang.Left = 540
  end
  label = nx_custom(form, "lbl_zq_" .. nx_string(force))
  if nx_is_valid(label) then
    label.BackImage = "gui\\special\\WorldWar\\ui_lx_icon\\zq_1.png"
  end
  local gui = nx_value("gui")
  local text = gui.TextManager:GetText("ui_lxc_zq_" .. nx_string(force))
  label = nx_custom(form, "lbl_zq_name_" .. nx_string(force))
  if nx_is_valid(label) then
    label.Text = text
  end
  form.force = force
  form.groupbox_5.Visible = true
  form.groupbox_6.Visible = false
  change_form_size()
end
function set_score(score_1, score_2, score_3, score_4)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if 0 <= score_1 and score_1 <= 2500 then
    form.pbar_1.Value = score_1
    form.lbl_lx_scored.Text = nx_widestr(score_1)
  end
  if 0 <= score_2 and score_2 <= 2500 then
    form.pbar_2.Value = score_2
    form.lbl_xs_scored.Text = nx_widestr(score_2)
  end
  if 0 <= score_3 and score_3 <= 2500 then
    form.pbar_3.Value = score_3
    form.lbl_bl_scored.Text = nx_widestr(score_3)
  end
  if 0 <= score_4 and score_4 <= 2500 then
    form.pbar_4.Value = score_4
    form.lbl_xd_scored.Text = nx_widestr(score_4)
  end
end
function on_btn_show_click(self)
  local form = self.ParentForm
  change_form_size()
  form.groupbox_5.Visible = true
  form.groupbox_6.Visible = false
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_WORLD_WAR), CLIENT_WORLDWAR_TRAITOR_ITEM, nx_int(2))
end
function change_form_size()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  form.Left = (desktop.Width - form.Width) / 2
  form.Top = (desktop.Height - form.Height) / 2
end
