require("util_gui")
require("role_composite")
require("form_stage_main\\form_general_info\\form_general_info_define")
function open_form()
  util_auto_show_hide_form(nx_current())
end
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if nx_is_valid(form_general_info_bisai) then
    nx_destroy(form_general_info_bisai)
  end
  local form_general_info_bisai = nx_create("form_general_info_bisai")
  nx_set_value("form_general_info_bisai", form_general_info_bisai)
  nx_execute("custom_sender", "custom_query_match_data", 5)
  show_self(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("SkillIntegral", "int", form, nx_current(), "on_skillintegral_changed")
  end
  form.rbtn_bishi.Checked = true
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("SkillIntegral", form)
  end
  for i = 1, table.getn(sub_form) do
    local form = nx_value("form_stage_main\\form_general_info\\form_general_info_" .. sub_form[i])
    if nx_is_valid(form) then
      form:Close()
    end
  end
  local form_general_info_bisai = nx_value("form_general_info_bisai")
  if nx_is_valid(form_general_info_bisai) then
    nx_destroy(form_general_info_bisai)
  end
  local form_invrank_friend = nx_value("form_invrank_friend")
  if nx_is_valid(form_invrank_friend) then
    nx_destroy(form_invrank_friend)
  end
  nx_destroy(form)
end
function on_skillintegral_changed(form, prop_name, prop_type, prop_value)
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
  form.lbl_3.Text = nx_widestr(client_player:QueryProp("SkillIntegral"))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_zhanli_checked_changed(btn)
  if btn.Checked then
    close_sub_form()
    local form = btn.ParentForm
    form.groupbox_role_info.Visible = true
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "show_form", form)
  end
end
function on_rbtn_bishi_checked_changed(btn)
  if btn.Checked then
    close_sub_form()
    local form = btn.ParentForm
    form.groupbox_role_info.Visible = false
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bishi", "show_form", form)
  end
end
function on_rbtn_duihuan_checked_changed(btn)
  if btn.Checked then
    close_sub_form()
    local form = btn.ParentForm
    form.groupbox_role_info.Visible = true
  end
end
function on_rbtn_chengjiu_checked_changed(btn)
  if btn.Checked then
    close_sub_form()
    local form = btn.ParentForm
    form.groupbox_role_info.Visible = true
    nx_execute("form_stage_main\\form_general_info\\form_general_info_chengjiu", "show_form", form)
  end
end
function on_rbtn_bisai_checked_changed(btn)
  if btn.Checked then
    close_sub_form()
    local form = btn.ParentForm
    form.groupbox_role_info.Visible = true
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bisai", "show_form", form)
  else
    local form_bisai = nx_value("form_stage_main\\form_general_info\\form_general_info_bisai")
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bisai", "clear_ls_effect", form_bisai)
  end
end
function on_rbtn_paihang_checked_changed(btn)
end
function close_sub_form()
  for i = 1, table.getn(sub_form) do
    local form = nx_value("form_stage_main\\form_general_info\\form_general_info_" .. sub_form[i])
    if nx_is_valid(form) then
      form.Visible = false
    end
  end
  local form_query_friend = nx_value("form_stage_main\\form_general_info\\form_invrank_selfriend")
  if nx_is_valid(form_query_friend) then
    nx_destroy(form_query_friend)
  end
end
function show_self(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if not nx_is_valid(form.scenebox_self.Scene) then
    util_addscene_to_scenebox(form.scenebox_self)
  end
  local actor2 = create_scene_obj_composite(form.scenebox_self.Scene, client_player, false)
  util_add_model_to_scenebox(form.scenebox_self, actor2)
  local game_effect = nx_create("GameEffect")
  if nx_is_valid(game_effect) then
    nx_bind_script(game_effect, "game_effect", "game_effect_init", form.scenebox_self.Scene)
    form.scenebox_self.Scene.game_effect = game_effect
  end
  local terrain = form.scenebox_self.Scene:Create("Terrain")
  form.scenebox_self.Scene.terrain = terrain
  form.actor2 = actor2
  form.lbl_name.Text = client_player:QueryProp("Name")
  local text_id = ""
  if client_player:QueryProp("School") ~= 0 and client_player:QueryProp("School") ~= "" then
    text_id = client_player:QueryProp("School")
  elseif client_player:QueryProp("Force") ~= 0 and client_player:QueryProp("Force") ~= "" then
    text_id = client_player:QueryProp("Force")
  else
    text_id = "ui_task_school_null"
  end
  form.lbl_school.Text = util_text(text_id)
  local title_id = client_player:QueryProp("TitleID")
  local form_bisai = nx_value("form_general_info_bisai")
  if nx_is_valid(form_bisai) and 0 < title_id then
    form_bisai:ShowTitleLbl(form.lbl_title, nx_int(title_id))
  end
end
