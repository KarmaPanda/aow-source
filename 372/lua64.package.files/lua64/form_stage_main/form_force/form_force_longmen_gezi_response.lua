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
  nx_execute("form_stage_main\\form_map\\form_map_scene", "delete_map_label", 14)
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:DeleteArenaCircle("circle_gezi")
  nx_destroy(form)
end
function on_btn_close_click(btn)
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
  form:Close()
end
function show_form(...)
  local form = util_get_form("form_stage_main\\form_force\\form_force_longmen_gezi_response", true)
  form.Visible = true
  form:Show()
  local form_map = util_get_form("form_stage_main\\form_map\\form_map_scene", true)
  local mgr = nx_value("SceneCreator")
  if not nx_is_valid(mgr) then
    return
  end
  mgr:CreateArenaCircle("circle_gezi", nx_int(arg[2]), nx_int(arg[3]), nx_int(arg[1]), "gui\\special\\fqfs\\cfbj_fw.png")
  form.lbl_x.Text = nx_widestr(arg[2])
  form.lbl_z.Text = nx_widestr(arg[3])
  form.lbl_guild.Text = nx_widestr(arg[4])
  form.lbl_count.Text = nx_widestr(arg[5])
  nx_execute("form_stage_main\\form_map\\form_map_scene", "add_label_to_map", 14, arg[2], arg[3], MAP_CLIENT_NPC, "ui_fqfs_tips_zhongxin")
end
