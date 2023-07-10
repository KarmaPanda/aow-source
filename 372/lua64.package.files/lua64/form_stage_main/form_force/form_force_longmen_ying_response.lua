require("util_gui")
require("custom_sender")
require("define\\map_lable_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) * 3 / 4
  form.Top = (gui.Height - form.Height) * 3 / 4
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "on_update_time", form)
  end
  nx_execute("custom_sender", "custom_send_bodyguardoffice_sender", 7)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_BZ)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_BZ)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_BZ)
  for i = 1, 3 do
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
  end
  for i = 1, 10 do
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_QIN_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
  end
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:DeleteArenaCircle("circle_ying")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_circle", "circle_ying")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_circle", "circle_ying")
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_ying_btn", false)
  nx_destroy(form)
end
function on_update_time(form, param1, param2)
  local last = form.lbl_time.Text
  if nx_int(last) <= nx_int(0) then
    form:Close()
    return
  end
  form.lbl_time.Text = nx_widestr(nx_int(last) - nx_int(1))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function show_form(...)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_ying_response", false)
  if not nx_is_valid(form) then
    form = util_get_form("form_stage_main\\form_force\\form_force_longmen_ying_response", true)
    form.Visible = true
    form:Show()
    local form_map = util_get_form("form_stage_main\\form_map\\form_map_scene", true)
  end
  nx_execute("form_stage_main\\form_main\\form_main", "show_changfeng_ying_btn", true)
  form.lbl_time.Text = nx_widestr(arg[1])
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:Register(1000, -1, nx_current(), "on_update_time", form, -1, -1)
  form.lbl_x.Text = nx_widestr(arg[3])
  form.lbl_z.Text = nx_widestr(arg[4])
  form.lbl_guild.Text = nx_widestr(arg[5])
  form.lbl_count.Text = nx_widestr(arg[6])
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_BZ)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_BZ)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_EFFECT)
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_BZ)
  for i = 1, 3 do
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
  end
  for i = 1, 10 do
    nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", LMBJ_QIN_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
    nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "delete_map_label", LMBJ_FBZ_1 + i - 1)
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", 6, nx_int(arg[3]), nx_int(arg[4]), MAP_CLIENT_NPC, "ui_fqfs_tips_zhongxin")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "add_label_to_map", 6, nx_int(arg[3]), nx_int(arg[4]), MAP_CLIENT_NPC, "ui_fqfs_tips_zhongxin")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "add_label_to_map", 6, nx_int(arg[3]), nx_int(arg[4]), MAP_CLIENT_NPC, "ui_fqfs_tips_zhongxin")
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:CreateArenaCircle("circle_ying", nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[2]), "gui\\special\\fqfs\\cfbj_fw.png")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "create_circle", "circle_ying", nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[2]), "gui\\special\\fqfs\\cfbj_fw.png")
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "create_circle", "circle_ying", nx_int(arg[3]), nx_int(arg[4]), nx_int(arg[2]), "gui\\special\\fqfs\\cfbj_fw.png")
  local table_info = util_split_string(nx_string(arg[7]), ";")
  local row = table.getn(table_info)
  if nx_int(row) >= nx_int(4) then
    row = 4
  end
  local fbz_count = 0
  for i = 1, row do
    if nx_string(table_info[i]) ~= nx_string("") then
      local info = util_split_string(nx_string(table_info[i]), ",")
      local player_name = nx_widestr(info[1])
      local level = nx_int(info[2])
      local x = nx_int(info[3])
      local z = nx_int(info[4])
      if nx_int(level) == nx_int(1) then
        nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", LMBJ_BZ, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_bz")
        nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "add_label_to_map", LMBJ_BZ, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_bz")
        nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "add_label_to_map", LMBJ_BZ, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_bz")
      else
        fbz_count = fbz_count + 1
        nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", LMBJ_BZ + fbz_count, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_fbz")
        nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "add_label_to_map", LMBJ_BZ + fbz_count, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_fbz")
        nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "add_label_to_map", LMBJ_BZ + fbz_count, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_fbz")
      end
    end
  end
  local qin_info = util_split_string(nx_string(arg[8]), ";")
  local row = table.getn(qin_info)
  if nx_int(row) > nx_int(10) then
    row = 10
  end
  for i = 1, row do
    if nx_string(qin_info[i]) ~= nx_string("") then
      local info = util_split_string(nx_string(qin_info[i]), ",")
      local player_name = nx_widestr(info[1])
      local x = nx_int(info[2])
      local z = nx_int(info[3])
      nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", LMBJ_QIN_1 + i - 1, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_qs")
      nx_execute("form_stage_main\\form_guild_war\\form_guild_war_map", "add_label_to_map", LMBJ_QIN_1 + i - 1, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_qs")
      nx_execute("form_stage_main\\form_guild_war\\form_guild_war_down_map", "add_label_to_map", LMBJ_QIN_1 + i - 1, x, z, MAP_CLIENT_NPC, "ui_fqfs_tips_qs")
    end
  end
end
function close_form()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_ying_response", false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
  form:Close()
end
function show_or_hide()
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_ying_response", false)
  if not nx_is_valid(form) then
    return
  end
  if form.Visible == true then
    form.Visible = false
  else
    form.Visible = true
  end
end
