require("util_gui")
require("util_functions")
require("custom_sender")
local AGREE_WAR_APPLY_TYPE_ALL = 2
local FORM_NAME = "form_stage_main\\form_agree_war\\form_agree_war_main"
local scene_tab = {}
local aw_achievement_tab = {}
function main_form_init(self)
  self.Fixed = false
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_open(self)
  self.sl_1 = 0
  self.sl_2 = 0
  self.rbtn_mine_all.Checked = true
  self.rbtn_1.Checked = true
  self.btn_ok.Visible = false
  self.btn_cancel.Visible = false
  self.btn_cancel_self.Visible = false
  self.rbtn_p_a.Checked = true
  custom_agree_war(nx_int(11))
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_main_form_shut(self)
end
function close_form()
  local form = util_get_form(FORM_NAME, false, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_req_click(btn)
  nx_execute("form_stage_main\\form_agree_war\\form_agree_war_req", "open_form")
end
function on_btn_refresh_click(btn)
  custom_agree_war(nx_int(11))
end
function on_btn_close_click(btn)
  close_form()
end
function on_rbtn_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = true
    form.gb_2.Visible = false
    form.gb_3.Visible = false
    form.gb_4.Visible = false
  end
end
function on_rbtn_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = true
    form.gb_3.Visible = false
    form.gb_4.Visible = false
  end
end
function on_rbtn_3_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = false
    form.gb_3.Visible = true
    form.gb_4.Visible = false
  end
end
function on_rbtn_4_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_1.Visible = false
    form.gb_2.Visible = false
    form.gb_3.Visible = false
    form.gb_4.Visible = true
    custom_agree_war(nx_int(24))
  end
end
function on_rbtn_all_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gsb_1.IsEditMode = true
    for i = 0, form.gsb_1:GetChildControlCount() do
      local gb = form.gsb_1:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        gb.Visible = true
      end
    end
    form.gsb_1:ResetChildrenYPos()
    form.gsb_1.IsEditMode = false
  end
end
function on_rbtn_guild_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gsb_1.IsEditMode = true
    for i = 0, form.gsb_1:GetChildControlCount() do
      local gb = form.gsb_1:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        if nx_int(gb.apply_type) ~= nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          gb.Visible = true
        else
          gb.Visible = false
        end
      end
    end
    form.gsb_1:ResetChildrenYPos()
    form.gsb_1.IsEditMode = false
  end
end
function on_rbtn_team_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gsb_1.IsEditMode = true
    for i = 0, form.gsb_1:GetChildControlCount() do
      local gb = form.gsb_1:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        if nx_int(gb.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          gb.Visible = true
        else
          gb.Visible = false
        end
      end
    end
    form.gsb_1:ResetChildrenYPos()
    form.gsb_1.IsEditMode = false
  end
end
function on_rbtn_mine_checked_changed(rbtn)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gsb_1.IsEditMode = true
    for i = 0, form.gsb_1:GetChildControlCount() do
      local gb = form.gsb_1:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        local can_apply = false
        if nx_int(gb.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          local captain = client_player:QueryProp("TeamCaptain")
          if nx_widestr(captain) == nx_widestr("") or nx_widestr(captain) == nx_widestr("0") then
            captain = client_player:QueryProp("Name")
          end
          if nx_widestr(captain) == nx_widestr(gb.guild_a) or nx_widestr(captain) == nx_widestr(gb.guild_b) then
            can_apply = true
          end
        else
          local guild_name = client_player:QueryProp("GuildName")
          if nx_widestr(guild_name) == nx_widestr(gb.guild_a) or nx_widestr(guild_name) == nx_widestr(gb.guild_b) then
            can_apply = true
          end
        end
        if can_apply then
          gb.Visible = true
        else
          gb.Visible = false
        end
      end
    end
    form.gsb_1:ResetChildrenYPos()
    form.gsb_1.IsEditMode = false
  end
end
function on_rbtn_mine_all_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local client = nx_value("game_client")
    local client_role = client:GetPlayer()
    if not nx_is_valid(client_role) then
      return
    end
    local guild_name = client_role:QueryProp("GuildName")
    if nx_widestr(guild_name) == nx_widestr("0") then
      guild_name = nx_widestr("")
    end
    local player_name = client_role:QueryProp("Name")
    form.gsb_2.IsEditMode = true
    for i = 0, form.gsb_2:GetChildControlCount() do
      local gb = form.gsb_2:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        gb.Visible = false
        if nx_int(gb.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          if nx_widestr(player_name) == nx_widestr(gb.guild_a) or nx_widestr(player_name) == nx_widestr(gb.guild_b) then
            gb.Visible = true
          end
        elseif nx_widestr(guild_name) == nx_widestr(gb.guild_a) or nx_widestr(guild_name) == nx_widestr(gb.guild_b) then
          gb.Visible = true
        end
      end
    end
    form.gsb_2:ResetChildrenYPos()
    form.gsb_2.IsEditMode = false
  end
end
function on_rbtn_mine_1_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local client = nx_value("game_client")
    local client_role = client:GetPlayer()
    if not nx_is_valid(client_role) then
      return
    end
    local guild_name = client_role:QueryProp("GuildName")
    if nx_widestr(guild_name) == nx_widestr("0") then
      guild_name = nx_widestr("")
    end
    local player_name = client_role:QueryProp("Name")
    form.gsb_2.IsEditMode = true
    for i = 0, form.gsb_2:GetChildControlCount() do
      local gb = form.gsb_2:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        gb.Visible = false
        if nx_int(gb.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          if nx_widestr(player_name) == nx_widestr(gb.guild_a) then
            gb.Visible = true
          end
        elseif nx_widestr(guild_name) == nx_widestr(gb.guild_a) then
          gb.Visible = true
        end
      end
    end
    form.gsb_2:ResetChildrenYPos()
    form.gsb_2.IsEditMode = false
  end
end
function on_rbtn_mine_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local client = nx_value("game_client")
    local client_role = client:GetPlayer()
    if not nx_is_valid(client_role) then
      return
    end
    local guild_name = client_role:QueryProp("GuildName")
    if nx_widestr(guild_name) == nx_widestr("0") then
      guild_name = nx_widestr("")
    end
    local player_name = client_role:QueryProp("Name")
    form.gsb_2.IsEditMode = true
    for i = 0, form.gsb_2:GetChildControlCount() do
      local gb = form.gsb_2:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        gb.Visible = false
        if nx_int(gb.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
          if nx_widestr(player_name) == nx_widestr(gb.guild_b) then
            gb.Visible = true
          end
        elseif nx_widestr(guild_name) == nx_widestr(gb.guild_b) then
          gb.Visible = true
        end
      end
    end
    form.gsb_2:ResetChildrenYPos()
    form.gsb_2.IsEditMode = false
  end
end
function on_rbtn_all_2_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gsb_2.IsEditMode = true
    for i = 0, form.gsb_2:GetChildControlCount() do
      local gb = form.gsb_2:GetChildControlByIndex(i)
      if nx_is_valid(gb) then
        gb.Visible = true
      end
    end
    form.gsb_2:ResetChildrenYPos()
    form.gsb_2.IsEditMode = false
  end
end
function on_btn_pick_click(btn)
  local form = btn.ParentForm
  if form.gsb_pick.Visible then
    form.gsb_pick.Visible = false
  else
    form.gsb_pick.Visible = true
  end
end
function on_btn_fire_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_1:Find("gb_1_" .. nx_string(form.sl_1))
  if nx_is_valid(gb) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(util_text("ui_agree_war_cancel_war")))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" and nx_is_valid(gb) then
      custom_agree_war(nx_int(20), nx_string(gb.war_id))
    end
  end
end
function on_btn_apply_a_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_1:Find("gb_1_" .. nx_string(form.sl_1))
  if nx_is_valid(gb) then
    local guild_a = gb.guild_a
    local guild_b = gb.guild_b
    local apply_type = gb.apply_type
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local player_name = client_player:QueryProp("Name")
    if nx_int(apply_type) == nx_int(2) and nx_widestr(guild_b) == nx_widestr(player_name) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_089"))
      return
    end
    if nx_int(apply_type) == nx_int(2) and nx_widestr(guild_a) == nx_widestr(player_name) then
      custom_agree_war(nx_int(2), nx_string(gb.war_id), nx_int(2351))
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_agree_war_join_confirm", nx_widestr(guild_a))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" and nx_is_valid(gb) then
      custom_agree_war(nx_int(2), nx_string(gb.war_id), nx_int(2351))
    end
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_095"))
  end
end
function on_btn_apply_b_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_1:Find("gb_1_" .. nx_string(form.sl_1))
  if nx_is_valid(gb) then
    local guild_a = gb.guild_a
    local guild_b = gb.guild_b
    local apply_type = gb.apply_type
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local player_name = client_player:QueryProp("Name")
    if nx_int(apply_type) == nx_int(2) and nx_widestr(guild_a) == nx_widestr(player_name) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_089"))
      return
    end
    if nx_int(apply_type) == nx_int(2) and nx_widestr(guild_b) == nx_widestr(player_name) then
      custom_agree_war(nx_int(2), nx_string(gb.war_id), nx_int(2352))
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("ui_agree_war_join_confirm", nx_widestr(guild_b))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" and nx_is_valid(gb) then
      custom_agree_war(nx_int(2), nx_string(gb.war_id), nx_int(2352))
    end
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_agree_war_095"))
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_2:Find("gb_2_" .. nx_string(form.sl_2))
  if nx_is_valid(gb) then
    local cost = gb.cost
    local player_min = gb.player_min
    cost = 0
    if nx_int(cost) > nx_int(0) then
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("ui_agree_war_ans_war", nx_int(cost))
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
      dialog:ShowModal()
      local gui = nx_value("gui")
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" and nx_is_valid(gb) then
        custom_agree_war(nx_int(1), nx_string(gb.war_id), 1)
      end
    else
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      local gui = nx_value("gui")
      local text = gui.TextManager:GetFormatText("ui_agree_war_ans_war_2", nx_int(player_min))
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
      dialog:ShowModal()
      local gui = nx_value("gui")
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" and nx_is_valid(gb) then
        custom_agree_war(nx_int(1), nx_string(gb.war_id), 1)
      end
    end
  end
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_2:Find("gb_2_" .. nx_string(form.sl_2))
  if nx_is_valid(gb) then
    custom_agree_war(nx_int(1), nx_string(gb.war_id), 0)
  end
end
function on_btn_cancel_self_click(btn)
  local form = btn.ParentForm
  local gb = form.gsb_2:Find("gb_2_" .. nx_string(form.sl_2))
  if nx_is_valid(gb) then
    custom_agree_war(nx_int(20), nx_string(gb.war_id))
  end
end
function on_cbtn_sl_1_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked == true then
    if nx_int(form.sl_1) ~= nx_int(cbtn.index) then
      local gb_old = form.gsb_1:Find("gb_1_" .. nx_string(form.sl_1))
      if nx_is_valid(gb_old) then
        local cbtn_old = gb_old:Find("cbtn_sl_1_" .. nx_string(form.sl_1))
        form.sl_1 = cbtn.index
        cbtn_old.Checked = false
      else
        form.sl_1 = cbtn.index
      end
      form.textgrid_p_a:ClearRow()
      form.textgrid_p_b:ClearRow()
      local gb_new = form.gsb_1:Find("gb_1_" .. nx_string(form.sl_1))
      if nx_is_valid(gb_new) then
        form.rbtn_p_a.Text = nx_widestr(gb_new.guild_a)
        form.rbtn_p_b.Text = nx_widestr(gb_new.guild_b)
        if nx_int(gb_new.is_start) == nx_int(1) then
          custom_agree_war(nx_int(18), nx_string(gb_new.war_id))
        end
      end
    end
  elseif nx_int(form.sl_1) == nx_int(cbtn.index) then
    cbtn.Checked = true
  end
end
function on_cbtn_sl_2_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked == true then
    if nx_int(form.sl_2) ~= nx_int(cbtn.index) then
      local gb_old = form.gsb_2:Find("gb_2_" .. nx_string(form.sl_2))
      if nx_is_valid(gb_old) then
        local cbtn_old = gb_old:Find("cbtn_sl_2_" .. nx_string(form.sl_2))
        form.sl_2 = cbtn.index
        cbtn_old.Checked = false
      else
        form.sl_2 = cbtn.index
      end
      local gb_new = form.gsb_2:Find("gb_2_" .. nx_string(form.sl_2))
      local client = nx_value("game_client")
      local client_role = client:GetPlayer()
      if not nx_is_valid(client_role) then
        return
      end
      local guild_name = client_role:QueryProp("GuildName")
      if nx_widestr(guild_name) == nx_widestr("0") then
        guild_name = nx_widestr("")
      end
      local player_name = client_role:QueryProp("Name")
      form.btn_ok.Visible = false
      form.btn_cancel.Visible = false
      form.btn_cancel_self.Visible = false
      if nx_int(gb_new.apply_type) == nx_int(AGREE_WAR_APPLY_TYPE_ALL) then
        if nx_widestr(player_name) == nx_widestr(gb_new.guild_a) then
          form.btn_cancel_self.Visible = true
        elseif nx_widestr(player_name) == nx_widestr(gb_new.guild_b) then
          form.btn_ok.Visible = true
          form.btn_cancel.Visible = true
        end
      elseif nx_widestr(guild_name) == nx_widestr(gb_new.guild_a) then
        form.btn_cancel_self.Visible = true
      elseif nx_widestr(guild_name) == nx_widestr(gb_new.guild_b) then
        form.btn_ok.Visible = true
        form.btn_cancel.Visible = true
      end
    end
  elseif nx_int(form.sl_2) == nx_int(cbtn.index) then
    cbtn.Checked = true
  end
end
function on_rbtn_p_a_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_p_a.Visible = true
    form.gb_p_b.Visible = false
  end
end
function on_rbtn_p_b_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    form.gb_p_a.Visible = false
    form.gb_p_b.Visible = true
  end
end
function update_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  load_ini(self)
  local info_list = util_split_string(nx_string(arg[1]), ",")
  local index = 1
  local count = info_list[index]
  form.gsb_1.IsEditMode = true
  form.gsb_1:DeleteAll()
  form.gsb_2.IsEditMode = true
  form.gsb_2:DeleteAll()
  form.sl_1 = 0
  form.sl_2 = 0
  if nx_int(count) <= nx_int(0) then
    form.gsb_1.IsEditMode = false
    form.gsb_2.IsEditMode = false
    return
  end
  for i = 1, nx_number(count) do
    local war_id = nx_string(info_list[index + 1])
    local guild_a = nx_function("ext_utf8_to_widestr", info_list[index + 2])
    local guild_b = nx_function("ext_utf8_to_widestr", info_list[index + 3])
    local apply_type_a = nx_int(info_list[index + 4])
    local apply_type_b = nx_int(info_list[index + 5])
    local player_a = nx_widestr(info_list[index + 6])
    local player_b = nx_widestr(info_list[index + 7])
    local scale = nx_int(info_list[index + 8])
    local start_time = nx_double(info_list[index + 9])
    local start_sign = nx_int(info_list[index + 10])
    local player_nums_a = nx_int(info_list[index + 11])
    local player_nums_b = nx_int(info_list[index + 12])
    local score_a = nx_int(info_list[index + 13])
    local score_b = nx_int(info_list[index + 14])
    local no_balance = nx_int(info_list[index + 15])
    index = index + 15
    if player_b ~= nx_widestr("") then
      local gb = create_ctrl("GroupBox", "gb_1_" .. nx_string(i), form.gb_model_1, form.gsb_1)
      gb.Left = 0
      gb.war_id = war_id
      gb.guild_a = guild_a
      gb.guild_b = guild_b
      gb.is_start = nx_int(start_sign)
      gb.apply_type = apply_type_a
      gb.cost = get_cost_by_scale(scale + 1)
      gb.player_min = get_player_min_by_scale(scale + 1)
      local cbtn_sl = create_ctrl("CheckButton", "cbtn_sl_1_" .. nx_string(i), form.cbtn_sl_1, gb)
      local lbl_guild_a = create_ctrl("Label", "lbl_guild_a_1_" .. nx_string(i), form.lbl_guild_a_1, gb)
      local lbl_guild_b = create_ctrl("Label", "lbl_guild_b_1_" .. nx_string(i), form.lbl_guild_b_1, gb)
      local lbl_apply_a = create_ctrl("Label", "lbl_apply_a_1_" .. nx_string(i), form.lbl_apply_a_1, gb)
      local lbl_apply_b = create_ctrl("Label", "lbl_apply_b_1_" .. nx_string(i), form.lbl_apply_b_1, gb)
      local lbl_scale = create_ctrl("Label", "lbl_scale_1_" .. nx_string(i), form.lbl_scale_1, gb)
      local lbl_start_time = create_ctrl("Label", "lbl_start_time_1_" .. nx_string(i), form.lbl_start_time_1, gb)
      local lbl_score = create_ctrl("Label", "lbl_score_1_" .. nx_string(i), form.lbl_score_1, gb)
      local lbl_player_num = create_ctrl("Label", "lbl_player_num_1_" .. nx_string(i), form.lbl_player_num_1, gb)
      local lbl_type_guild = create_ctrl("Label", "lbl_type_guild_1_" .. nx_string(i), form.lbl_type_guild_1, gb)
      local lbl_type_all = create_ctrl("Label", "lbl_type_all_1_" .. nx_string(i), form.lbl_type_all_1, gb)
      local lbl_balance = create_ctrl("Label", "lbl_lbl_balance_1_" .. nx_string(i), form.lbl_balance_1, gb)
      cbtn_sl.index = i
      nx_bind_script(cbtn_sl, nx_current())
      nx_callback(cbtn_sl, "on_checked_changed", "on_cbtn_sl_1_checked_changed")
      if nx_int(apply_type_a) == nx_int(1) then
        lbl_apply_a.Visible = true
      else
        lbl_apply_a.Visible = false
      end
      if nx_int(apply_type_b) == nx_int(1) then
        lbl_apply_b.Visible = true
      else
        lbl_apply_b.Visible = false
      end
      if nx_int(apply_type_a) == nx_int(2) then
        lbl_type_guild.Visible = false
        lbl_type_all.Visible = true
      else
        lbl_type_guild.Visible = true
        lbl_type_all.Visible = false
      end
      if nx_int(start_sign) == nx_int(1) then
        lbl_start_time.Text = util_text("ui_yikaizhan")
      else
        lbl_start_time.Text = nx_widestr(decode_time(start_time))
      end
      if no_balance == nx_int(0) then
        lbl_balance.BackImage = "gui\\special\\agree_war\\balance_0.png"
        lbl_balance.HintText = util_text("tips_agree_war_balance_0")
      else
        lbl_balance.BackImage = "gui\\special\\agree_war\\balance_1.png"
        lbl_balance.HintText = util_text("tips_agree_war_balance_1")
      end
      lbl_guild_a.Text = guild_a
      lbl_guild_b.Text = guild_b
      lbl_scale.Text = nx_widestr((get_player_num_by_scale(scale + 1)))
      lbl_player_num.Text = nx_widestr(nx_string(player_nums_a) .. ":" .. nx_string(player_nums_b))
      lbl_score.Text = nx_widestr(nx_string(score_a) .. ":" .. nx_string(score_b))
    else
      local gb = create_ctrl("GroupBox", "gb_2_" .. nx_string(i), form.gb_model_2, form.gsb_2)
      gb.Left = 0
      gb.war_id = war_id
      gb.guild_a = guild_a
      gb.guild_b = guild_b
      gb.apply_type = apply_type_a
      gb.cost = get_cost_by_scale(scale + 1)
      gb.player_min = get_player_min_by_scale(scale + 1)
      local cbtn_sl = create_ctrl("CheckButton", "cbtn_sl_2_" .. nx_string(i), form.cbtn_sl_2, gb)
      local lbl_guild_a = create_ctrl("Label", "lbl_guild_a_2_" .. nx_string(i), form.lbl_guild_a_2, gb)
      local lbl_guild_b = create_ctrl("Label", "lbl_guild_b_2_" .. nx_string(i), form.lbl_guild_b_2, gb)
      local lbl_apply_a = create_ctrl("Label", "lbl_apply_a_2_" .. nx_string(i), form.lbl_apply_a_2, gb)
      local lbl_apply_b = create_ctrl("Label", "lbl_apply_b_2_" .. nx_string(i), form.lbl_apply_b_2, gb)
      local lbl_scale = create_ctrl("Label", "lbl_scale_2_" .. nx_string(i), form.lbl_scale_2, gb)
      local lbl_start_time = create_ctrl("Label", "lbl_start_time_2_" .. nx_string(i), form.lbl_start_time_2, gb)
      local lbl_cost = create_ctrl("Label", "lbl_cost_" .. nx_string(i), form.lbl_cost, gb)
      local lbl_type_guild = create_ctrl("Label", "lbl_type_guild_2_" .. nx_string(i), form.lbl_type_guild_2, gb)
      local lbl_type_all = create_ctrl("Label", "lbl_type_all_2_" .. nx_string(i), form.lbl_type_all_2, gb)
      local lbl_balance = create_ctrl("Label", "lbl_lbl_balance_2_" .. nx_string(i), form.lbl_balance_2, gb)
      cbtn_sl.index = i
      nx_bind_script(cbtn_sl, nx_current())
      nx_callback(cbtn_sl, "on_checked_changed", "on_cbtn_sl_2_checked_changed")
      lbl_cost.Text = nx_widestr(get_cost_by_scale(scale + 1))
      if nx_int(apply_type_a) == nx_int(1) then
        lbl_apply_a.Visible = true
      else
        lbl_apply_a.Visible = false
      end
      if nx_int(apply_type_b) == nx_int(1) then
        lbl_apply_b.Visible = true
      else
        lbl_apply_b.Visible = false
      end
      if nx_int(apply_type_a) == nx_int(2) then
        lbl_type_guild.Visible = false
        lbl_type_all.Visible = true
      else
        lbl_type_guild.Visible = true
        lbl_type_all.Visible = false
      end
      if nx_int(start_sign) == nx_int(1) then
        lbl_start_time.Text = util_text("ui_yikaizhan")
      else
        lbl_start_time.Text = nx_widestr(decode_time(start_time))
      end
      if no_balance == nx_int(0) then
        lbl_balance.BackImage = "gui\\special\\agree_war\\balance_0.png"
        lbl_balance.HintText = util_text("tips_agree_war_balance_0")
      else
        lbl_balance.BackImage = "gui\\special\\agree_war\\balance_1.png"
        lbl_balance.HintText = util_text("tips_agree_war_balance_1")
      end
      lbl_guild_a.Text = guild_a
      lbl_guild_b.Text = guild_b
      lbl_scale.Text = nx_widestr(get_player_num_by_scale(scale + 1))
    end
  end
  form.gsb_1.IsEditMode = false
  form.gsb_1:ResetChildrenYPos()
  form.gsb_2.IsEditMode = false
  form.gsb_2:ResetChildrenYPos()
  form.rbtn_all.Checked = true
  form.rbtn_mine_all.Checked = true
end
function update_player_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.textgrid_p_a:BeginUpdate()
  form.textgrid_p_b:BeginUpdate()
  form.textgrid_p_a:ClearRow()
  form.textgrid_p_b:ClearRow()
  local info_list = util_split_string(arg[1], ",")
  local index = 1
  local row_a = info_list[index]
  if nx_number(row_a) > 0 then
    for i = 1, nx_number(row_a) do
      local name = info_list[index + 1]
      local title = info_list[index + 2]
      index = index + 2
      local row = form.textgrid_p_a:InsertRow(-1)
      form.textgrid_p_a:SetGridText(row, 0, nx_widestr(name))
      form.textgrid_p_a:SetGridText(row, 1, nx_widestr(util_text("desc_" .. nx_string(title))))
    end
  end
  local row_b = info_list[index + 1]
  index = index + 1
  if nx_number(row_b) > 0 then
    for i = 1, nx_number(row_b) do
      local name = info_list[index + 1]
      local title = info_list[index + 2]
      index = index + 2
      local row = form.textgrid_p_b:InsertRow(-1)
      form.textgrid_p_b:SetGridText(row, 0, nx_widestr(name))
      form.textgrid_p_b:SetGridText(row, 1, nx_widestr(util_text("desc_" .. nx_string(title))))
    end
  end
  form.textgrid_p_a:EndUpdate()
  form.textgrid_p_b:EndUpdate()
end
function update_his_info(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  form.gsb_4.IsEditMode = true
  form.gsb_4:DeleteAll()
  local info_list = util_split_string(nx_string(arg[1]), ",")
  local index = 1
  local count = info_list[index]
  for i = 1, nx_number(count) do
    local guild_a = nx_widestr(info_list[index + 1])
    local guild_b = nx_widestr(info_list[index + 2])
    local apply_type_a = nx_int(info_list[index + 3])
    local apply_type_b = nx_int(info_list[index + 4])
    local scale = nx_int(info_list[index + 5])
    local start_time = nx_double(info_list[index + 6])
    local score_a = nx_int(info_list[index + 7])
    local score_b = nx_int(info_list[index + 8])
    local point_a = nx_int(info_list[index + 9])
    local point_b = nx_int(info_list[index + 10])
    index = index + 10
    local gb = create_ctrl("GroupBox", "gb_4_" .. nx_string(i), form.gb_model_4, form.gsb_4)
    gb.Left = 0
    local lbl_guild_a = create_ctrl("Label", "lbl_guild_a_4_" .. nx_string(i), form.lbl_guild_a_4, gb)
    local lbl_guild_b = create_ctrl("Label", "lbl_guild_b_4_" .. nx_string(i), form.lbl_guild_b_4, gb)
    local lbl_apply_a = create_ctrl("Label", "lbl_apply_a_4_" .. nx_string(i), form.lbl_apply_a_4, gb)
    local lbl_apply_b = create_ctrl("Label", "lbl_apply_b_4_" .. nx_string(i), form.lbl_apply_b_4, gb)
    local lbl_score = create_ctrl("Label", "lbl_score_4_" .. nx_string(i), form.lbl_score_4, gb)
    local lbl_point = create_ctrl("Label", "lbl_point_4_" .. nx_string(i), form.lbl_point_4, gb)
    local lbl_type_all = create_ctrl("Label", "lbl_type_all_4_" .. nx_string(i), form.lbl_type_all_4, gb)
    local lbl_type_guild = create_ctrl("Label", "lbl_type_guild_4_" .. nx_string(i), form.lbl_type_guild_4, gb)
    local lbl_scale = create_ctrl("Label", "lbl_scale_4_" .. nx_string(i), form.lbl_scale_4, gb)
    local lbl_start_time = create_ctrl("Label", "lbl_start_time_4_" .. nx_string(i), form.lbl_start_time_4, gb)
    lbl_guild_a.Text = guild_a
    lbl_guild_b.Text = guild_b
    lbl_score.Text = nx_widestr(nx_string(score_a) .. ":" .. nx_string(score_b))
    lbl_point.Text = nx_widestr(nx_string(point_a) .. ":" .. nx_string(point_b))
    lbl_start_time.Text = nx_widestr(decode_time(start_time))
    lbl_scale.Text = nx_widestr(get_player_num_by_scale(scale + 1))
    if nx_int(apply_type_a) == nx_int(1) then
      lbl_apply_a.Visible = true
    else
      lbl_apply_a.Visible = false
    end
    if nx_int(apply_type_b) == nx_int(1) then
      lbl_apply_b.Visible = true
    else
      lbl_apply_b.Visible = false
    end
    if nx_int(apply_type_a) == nx_int(2) then
      lbl_type_guild.Visible = false
      lbl_type_all.Visible = true
    else
      lbl_type_guild.Visible = true
      lbl_type_all.Visible = false
    end
  end
  form.gsb_4.IsEditMode = false
  form.gsb_4:ResetChildrenYPos()
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
function open_form_2()
  local form = util_get_form(FORM_NAME, false, false)
  if not nx_is_valid(form) then
    form = util_get_form(FORM_NAME, true)
    if nx_is_valid(form) then
      form:Show()
      form.Visible = true
    end
  else
    custom_agree_war(nx_int(11))
  end
  form.rbtn_2.Checked = true
end
function agree_war_sys(string_id, ...)
  if nx_string(string_id) == nx_string("sys_agree_war_101") or nx_string(string_id) == nx_string("sys_agree_war_102") or nx_string(string_id) == nx_string("sys_agree_war_103") or nx_string(string_id) == nx_string("sys_agree_war_104") or nx_string(string_id) == nx_string("sys_agree_war_001") or nx_string(string_id) == nx_string("sys_agree_war_002") or nx_string(string_id) == nx_string("sys_agree_war_003") or nx_string(string_id) == nx_string("sys_agree_war_004") or nx_string(string_id) == nx_string("sys_agree_war_005") or nx_string(string_id) == nx_string("sys_agree_war_006") or nx_string(string_id) == nx_string("sys_agree_war_007") or nx_string(string_id) == nx_string("sys_agree_war_105") or nx_string(string_id) == nx_string("sys_agree_war_106") or nx_string(string_id) == nx_string("sys_agree_war_101_single") or nx_string(string_id) == nx_string("sys_agree_war_102_single") or nx_string(string_id) == nx_string("sys_agree_war_103_single") or nx_string(string_id) == nx_string("sys_agree_war_104_single") or nx_string(string_id) == nx_string("sys_agree_war_001_single") or nx_string(string_id) == nx_string("sys_agree_war_002_single") or nx_string(string_id) == nx_string("sys_agree_war_003_single") or nx_string(string_id) == nx_string("sys_agree_war_004_single") or nx_string(string_id) == nx_string("sys_agree_war_005_single") or nx_string(string_id) == nx_string("sys_agree_war_006_single") or nx_string(string_id) == nx_string("sys_agree_war_007_single") or nx_string(string_id) == nx_string("sys_agree_war_105_single") or nx_string(string_id) == nx_string("sys_agree_war_106_single") then
    local form = util_get_form(FORM_NAME, false, false)
    if nx_is_valid(form) then
      custom_agree_war(nx_int(11))
    end
  end
  if nx_string(string_id) == nx_string("sys_agree_war_101") or nx_string(string_id) == nx_string("sys_agree_war_101_single") then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local player_name = client_player:QueryProp("Name")
    if nx_widestr(player_name) == nx_widestr(arg[1]) then
      local form_req = util_get_form("form_stage_main\\form_agree_war\\form_agree_war_req", false, false)
      if nx_is_valid(form_req) then
        form_req:Close()
      end
      open_form()
      local form = util_get_form(FORM_NAME, false, false)
      if nx_is_valid(form) then
        form.rbtn_2.Checked = true
      end
    end
  end
end
function load_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\agree_war\\agree_war.ini")
  if not nx_is_valid(ini) then
    return
  end
  local section = ini:FindSectionIndex("property")
  if section < 0 then
    return
  end
  scene_tab = {}
  local scene_id_str = ini:ReadString(section, "scene_id", "")
  local cost_str = ini:ReadString(section, "cost", "")
  local scene_photo_str = ini:ReadString(section, "scene_photo", "")
  local player_max_str = ini:ReadString(section, "player_max", "")
  local player_min_str = ini:ReadString(section, "player_min", "")
  local scene_id_list = util_split_string(scene_id_str, ",")
  local cost_list = util_split_string(cost_str, ",")
  local scene_photo_list = util_split_string(scene_photo_str, ",")
  local player_max_list = util_split_string(player_max_str, ",")
  local player_min_list = util_split_string(player_min_str, ",")
  for i = 1, table.getn(scene_id_list) do
    local scene_id = nx_int(scene_id_list[i])
    local tab = {}
    tab.scene_id = scene_id
    tab.cost = nx_int(cost_list[i])
    tab.scene_photo = nx_string(scene_photo_list[i])
    tab.player_max = nx_int(player_max_list[i])
    tab.player_min = nx_int(player_min_list[i])
    table.insert(scene_tab, i, tab)
  end
end
function get_player_num_by_scale(scale)
  return scene_tab[nx_number(scale)].player_max
end
function get_player_min_by_scale(scale)
  return scene_tab[nx_number(scale)].player_min
end
function get_cost_by_scale(scale)
  return scene_tab[nx_number(scale)].cost
end
function decode_time(d_time)
  local year, month, day, hour, min, sec = nx_function("ext_decode_date", d_time)
  local min_str = ""
  if nx_number(min) < 10 then
    min_str = "0" .. nx_string(min)
  else
    min_str = nx_string(min)
  end
  return nx_string(year) .. "-" .. nx_string(month) .. "-" .. nx_string(day) .. " " .. nx_string(hour) .. ":" .. min_str
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
function load_achi_ini(form)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\agree_war\\AgreeWarAchievement.ini")
  if not nx_is_valid(ini) then
    return
  end
  aw_achievement_tab = {}
  local section_count = ini:GetSectionCount()
  if section_count <= 0 then
    return
  end
  for i = nx_number(0), nx_number(section_count - 1) do
    local section = nx_number(ini:GetSectionByIndex(i))
    local tab = {}
    tab.behaviorid = ini:ReadInteger(i, "behaviorid", 0)
    tab.taskid = ini:ReadInteger(i, "taskid", 0)
    tab.name = ini:ReadString(i, "name", "")
    tab.count = ini:ReadInteger(i, "count", 0)
    tab.award = ini:ReadString(i, "award", "")
    tab.desc = ini:ReadString(i, "desc", "")
    table.insert(aw_achievement_tab, section, tab)
  end
end
function update_achievement(...)
  local form = util_get_form(FORM_NAME, false)
  if not nx_is_valid(form) then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  if not nx_is_valid(ItemsQuery) then
    return
  end
  load_achi_ini(self)
  local info_list = util_split_string(nx_string(arg[1]), ",")
  local index = 1
  local count = info_list[index]
  local VScrollBarValue = form.groupscrollbox_ach.VScrollBar.Value
  form.groupscrollbox_ach.IsEditMode = true
  form.groupscrollbox_ach:DeleteAll()
  if nx_int(count) <= nx_int(0) then
    form.groupscrollbox_ach.IsEditMode = false
    return
  end
  for i = 1, nx_number(count) do
    local achi_id = nx_number(info_list[index + 1])
    local achi_p = nx_int(info_list[index + 2])
    local achi_award = nx_int(info_list[index + 3])
    index = index + 3
    if aw_achievement_tab[achi_id] ~= nil then
      local gb = create_ctrl("GroupBox", "gb_model_achi_" .. nx_string(i), form.gb_model_achi, form.groupscrollbox_ach)
      gb.Left = 0
      gb.Top = (i - 1) * form.gb_model_achi.Height
      gb.Height = 80
      local btn_achi = create_ctrl("Button", "btn_achi_" .. nx_string(i), form.btn_achi, gb)
      local lbl_achi = create_ctrl("Label", "lbl_achi_" .. nx_string(i), form.lbl_achi, gb)
      local lbl_achi_name = create_ctrl("Label", "lbl_achi_name_" .. nx_string(i), form.lbl_achi_name, gb)
      local lbl_achi_p = create_ctrl("Label", "lbl_achi_p_" .. nx_string(i), form.lbl_achi_p, gb)
      local imagegrid_achi = create_ctrl("ImageGrid", "imagegrid_achi_" .. nx_string(i), form.imagegrid_achi, gb)
      local mltbox_desc = create_ctrl("MultiTextBox", "mltbox_desc_" .. nx_string(i), form.mltbox_desc, gb)
      lbl_achi_p.Left = 380
      mltbox_desc.Height = 80
      btn_achi.achi_id = achi_id
      btn_achi.achi_task = aw_achievement_tab[achi_id].taskid
      imagegrid_achi.award = aw_achievement_tab[achi_id].award
      local photo = ItemsQuery:GetItemPropByConfigID(nx_string(imagegrid_achi.award), "Photo")
      imagegrid_achi:AddItem(0, photo, nx_string(imagegrid_achi.award), 1, 0)
      nx_bind_script(btn_achi, nx_current())
      nx_callback(btn_achi, "on_click", "on_btn_achi_click")
      nx_bind_script(imagegrid_achi, nx_current())
      nx_callback(imagegrid_achi, "on_get_capture", "on_imagegrid_achi_get_capture")
      nx_callback(imagegrid_achi, "on_lost_capture", "on_imagegrid_achi_lost_capture")
      if achi_award == nx_int(1) then
        btn_achi.NormalImage = "gui\\special\\agree_war\\btn_out.png"
        btn_achi.FocusImage = "gui\\special\\agree_war\\btn_on.png"
        btn_achi.PushImage = "gui\\special\\agree_war\\btn_down.png"
        if achi_p == nx_int(0) then
          achi_p = aw_achievement_tab[achi_id].count
        end
      elseif achi_award == nx_int(2) then
        btn_achi.Enabled = false
        btn_achi.NormalImage = "gui\\special\\agree_war\\btn_get.png"
        btn_achi.FocusImage = "gui\\special\\agree_war\\btn_get.png"
        btn_achi.PushImage = "gui\\special\\agree_war\\btn_get.png"
        if achi_p == nx_int(0) then
          achi_p = aw_achievement_tab[achi_id].count
        end
        btn_achi.Text = ""
      else
        btn_achi.Enabled = false
        btn_achi.NormalImage = "gui\\special\\agree_war\\btn_forbid.png"
        btn_achi.FocusImage = "gui\\special\\agree_war\\btn_forbid.png"
        btn_achi.PushImage = "gui\\special\\agree_war\\btn_forbid.png"
      end
      lbl_achi_name.Text = util_text(nx_string(aw_achievement_tab[achi_id].name))
      lbl_achi_p.Text = nx_widestr(nx_string(achi_p) .. "/" .. nx_string(aw_achievement_tab[achi_id].count))
      mltbox_desc.HtmlText = util_text(nx_string(aw_achievement_tab[achi_id].desc))
    end
  end
  form.groupscrollbox_ach.IsEditMode = false
  form.groupscrollbox_ach:ResetChildrenYPos()
  form.groupscrollbox_ach.VScrollBar.Value = VScrollBarValue
end
function on_btn_achi_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_number(btn.achi_id) > 0 and 0 < nx_number(btn.achi_task) then
    custom_agree_war(nx_int(21), nx_int(btn.achi_id), nx_int(btn.achi_task))
  end
end
function on_imagegrid_achi_get_capture(imagegrid, index)
  local gui = nx_value("gui")
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_tips_by_config", imagegrid.award, x, y)
end
function on_imagegrid_achi_lost_capture(imagegrid, index)
  nx_execute("tips_game", "hide_tip")
end
