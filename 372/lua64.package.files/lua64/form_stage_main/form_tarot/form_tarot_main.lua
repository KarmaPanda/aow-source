require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local FORM_NAME = "form_stage_main\\form_tarot\\form_tarot_main"
local image_path = "gui\\language\\ChineseS\\tarot"
local card_nums = 22
local card_pre_line = 11
local send_speed = 50
local l_base = 0
local l_margin = -45
local t_base = 10
local t_margin = 15
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.gb_send.Visible = false
  form.lbl_luopan.Visible = false
  form.mltbox_shuoming.Visible = false
  form.gb_show.Visible = false
  form.gb_card.Visible = false
  form.ani_show_card.Visible = false
  form.ani_show_card_2.Visible = false
  form.sl_index = 0
  nx_execute("custom_sender", "custom_tarot", 0)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function open_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    return
  end
  form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function update_form(...)
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  local id = nx_number(arg[1])
  local sl_index = nx_number(arg[2])
  if id == 0 then
    form.gb_send.Visible = true
    form.lbl_luopan.Visible = true
    form.mltbox_shuoming.Visible = true
    form.gb_show.Visible = false
    form.gb_card.Visible = false
  else
    if form.gb_show.Visible == false then
      send_card_once(form)
      form.gb_show.Visible = true
    end
    play_ani_show(form, id, sl_index)
  end
end
function on_query()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    return
  end
  play_ani_send(form)
end
function on_btn_close_click(btn)
  close_form()
end
function on_btn_collect_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_tarot\\form_tarot_collect")
end
function on_btn_card_share_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_TAROT) then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_006")
    return
  end
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  nx_execute("form_stage_main\\form_tarot\\form_tarot_share", "open_form", nx_widestr(player_name), form.gb_card.id)
end
function on_btn_send_click(btn)
  nx_execute("custom_sender", "custom_tarot", 4)
end
function on_play_ani_send_end(form)
  for i = 1, card_nums do
    local rbtn_card = form.gb_show:Find("rbtn_card_" .. nx_string(i))
    if nx_is_valid(rbtn_card) then
      rbtn_card.Enabled = true
    end
  end
  form.btn_ok.Enabled = true
end
function on_ani_show_card_animation_end(ani)
  local form = ani.ParentForm
  ani.Visible = false
  local id = form.gb_card.id
  form.gb_card.Visible = true
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local player_name = client_player:QueryProp("Name")
  form.lbl_card_pname.Text = nx_widestr(player_name)
  local id_path = string.format("%02d", id)
  form.lbl_card_main.BackImage = image_path .. "\\" .. id_path .. ".png"
  form.ani_show_card_2.Visible = true
  form.ani_show_card_2.PlayMode = 2
  form.ani_show_card_2:Play()
end
function on_ani_show_card_2_animation_end(ani)
  ani.Visible = false
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local sl_index = form.sl_index
  if sl_index == 0 then
    nx_execute("custom_handler", "custom_sysinfo", 1, 1, 1, 2, "sys_tarot_004")
    return
  end
  nx_execute("custom_sender", "custom_tarot", 1, form.sl_index)
end
function on_rbtn_card_checked_changed(rbtn)
  local form = rbtn.ParentForm
  local index = rbtn.sl_index
  if rbtn.Checked then
    form_sl(form, index)
  end
end
function form_sl(form, index)
  if form.sl_index > 0 then
    local rbtn_old = form.gb_show:Find("rbtn_card_" .. nx_string(form.sl_index))
    if nx_is_valid(rbtn_old) then
      rbtn_old.Top = rbtn_old.Top + 10
    end
  end
  form.sl_index = index
  if 0 < index then
    local rbtn_new = form.gb_show:Find("rbtn_card_" .. nx_string(form.sl_index))
    if nx_is_valid(rbtn_new) then
      rbtn_new.Top = rbtn_new.Top - 10
    end
  end
end
function play_ani_send(form)
  if form.btn_ok.Enabled == false then
    return
  end
  form.gb_send.Visible = false
  form.lbl_luopan.Visible = false
  form.mltbox_shuoming.Visible = false
  form.gb_show.Visible = true
  form.btn_ok.Enabled = false
  local gui = nx_value("gui")
  for i = 1, card_nums do
    local rbtn_card = form.gb_show:Find("rbtn_card_" .. nx_string(i))
    if nx_is_valid(rbtn_card) then
      form.gb_show:Remove(rbtn_card)
      gui:Delete(rbtn_card)
    end
  end
  form.sl_index = 0
  form.ani_send_index = 0
  local timer = nx_value(GAME_TIMER)
  timer:Register(send_speed, -1, nx_current(), "on_ani_send", form, -1, -1)
end
function on_ani_send(form)
  form.ani_send_index = form.ani_send_index + 1
  if form.ani_send_index > card_nums then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "on_ani_send", form)
    on_play_ani_send_end(form)
    return
  end
  local rbtn_card = create_ctrl("RadioButton", "rbtn_card_" .. nx_string(form.ani_send_index), form.rbtn_mod, form.gb_show)
  nx_bind_script(rbtn_card, nx_current())
  nx_callback(rbtn_card, "on_checked_changed", "on_rbtn_card_checked_changed")
  rbtn_card.sl_index = form.ani_send_index
  rbtn_card.Left = l_base + math.fmod(rbtn_card.sl_index - 1, card_pre_line) * (rbtn_card.Width + l_margin)
  rbtn_card.Top = t_base + math.floor((rbtn_card.sl_index - 1) / card_pre_line) * (rbtn_card.Height + t_margin)
  rbtn_card.Enabled = false
end
function play_ani_show(form, id, sl_index)
  for i = 1, card_nums do
    local rbtn_card = form.gb_show:Find("rbtn_card_" .. nx_string(i))
    if nx_is_valid(rbtn_card) then
      rbtn_card.Enabled = false
      if i == sl_index then
        rbtn_card.Visible = false
      end
    end
  end
  form.btn_ok.Enabled = false
  form.gb_card.Visible = false
  form.gb_card.id = id
  form.ani_show_card.Visible = true
  form.ani_show_card.PlayMode = 2
  form.ani_show_card:Play()
end
function send_card_once(form)
  for i = 1, card_nums do
    local rbtn_card = create_ctrl("RadioButton", "rbtn_card_" .. nx_string(i), form.rbtn_mod, form.gb_show)
    rbtn_card.sl_index = i
    rbtn_card.Left = l_base + math.fmod(rbtn_card.sl_index - 1, card_pre_line) * (rbtn_card.Width + l_margin)
    rbtn_card.Top = t_base + math.floor((rbtn_card.sl_index - 1) / card_pre_line) * (rbtn_card.Height + t_margin)
    rbtn_card.Enabled = false
  end
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(parent_ctrl.ParentForm, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function a(info)
  nx_msgbox(nx_string(info))
end
