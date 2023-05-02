require("form_stage_main\\form_team\\team_util_functions")
function refresh_form(form)
  if nx_is_valid(form) then
    disp_team_quality_mode(form)
  end
end
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  data_bind_prop(form)
  disp_team_quality_mode(form)
end
function on_main_form_close(form)
  del_data_bind_prop(form)
  nx_destroy(form)
  nx_set_value(nx_current(), nx_null())
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("TeamPickQuality", "int", form, nx_current(), "on_TeamPickQuality_change")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelRolePropertyBind("TeamPickQuality", form)
  end
end
function on_level_click(rbtn)
  form = rbtn.ParentForm
  if not is_in_team() or not is_team_captain() then
    disp_team_quality_mode(form)
    form.Visible = false
    return
  end
  local level = nx_number(rbtn.DataSource)
  nx_execute("custom_sender", "custom_set_team_allot_quality", level)
  form.Visible = false
end
function on_TeamPickQuality_change(form)
  if not form.Visible then
    return
  end
  disp_team_quality_mode(form)
end
function disp_team_quality_mode(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindProp("TeamPickQuality") then
    return
  end
  local quality_mode = nx_number(client_player:QueryProp("TeamPickQuality"))
  local rbtn = form:Find("rbtn_" .. nx_string(quality_mode - 1))
  if nx_is_valid(rbtn) then
    rbtn.Checked = true
  end
end
