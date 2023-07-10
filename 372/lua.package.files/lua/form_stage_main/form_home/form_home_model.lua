require("util_functions")
require("util_gui")
require("role_composite")
require("tips_data")
require("share\\view_define")
require("form_stage_main\\form_home\\form_home_msg")
require("util_role_prop")
local function_close_form_table = {
  "form_stage_main\\form_home\\form_home_function",
  "form_stage_main\\form_home\\form_home_myhome"
}
local enter_close_form_table = {}
function switch_home_mode(mode)
  local mode_type = mode
  local close_form_table
  if mode_type == 1 then
    close_form_table = enter_close_form_table
  elseif mode_type == 2 then
    close_form_table = function_close_form_table
  end
  if close_form_table == nil then
    return
  end
  for i, path in pairs(close_form_table) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function open_form()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
  form.model = 1
end
function on_size_change()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(form) and nx_is_valid(gui) then
    form.AbsLeft = 0
    form.AbsTop = gui.Height - form.Height
  end
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    nx_destroy(form)
  end
end
function on_main_form_open(form)
  on_size_change()
  form.rbtn_function.Checked = true
  local databinder = nx_value("data_binder")
  databinder:AddRolePropertyBind("CurHomeUID", "string", form, "form_stage_main\\form_home\\form_home_model", "on_cur_homeid_changed")
end
function on_cur_homeid_changed(form)
  if not nx_is_valid(form) then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    form:Close()
    return
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("CurHomeUID", form)
  nx_destroy(form)
end
function reset_scene()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_home_model(model_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.model = model_type
end
function on_btn_function_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.model) ~= nx_int(1) then
    switch_home_mode(1)
    nx_execute("form_stage_main\\form_home\\form_home_function", "open_form")
    set_home_model(1)
  end
end
function on_btn_edite_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_int(form.model) ~= nx_int(2) then
    switch_home_mode(2)
    nx_execute("form_stage_main\\form_home\\form_home_enter", "open_form")
    set_home_model(2)
  end
end
function on_rbtn_checked_changed(self)
  if self.Checked then
    local data_source = self.DataSource
    if nx_int(data_source) == nx_int(1) then
      switch_home_mode(1)
      nx_execute("form_stage_main\\form_home\\form_home_enter", "open_form")
      nx_execute("form_stage_main\\form_home\\form_home_function", "open_form")
      local form_enter = util_get_form("form_stage_main\\form_home\\form_home_enter", false)
      if nx_is_valid(form_enter) then
        form_enter.groupbox_op.Visible = false
        form_enter.groupbox_str_m.Visible = false
        form_enter.groupbox_str_n.Visible = true
      end
      set_home_model(1)
    elseif nx_int(data_source) == nx_int(2) then
      switch_home_mode(2)
      nx_execute("form_stage_main\\form_home\\form_home_enter", "open_form")
      set_home_model(2)
    end
  end
end
function get_current_homeid()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp("CurHomeUID") then
    return ""
  end
  return nx_string(client_player:QueryProp("CurHomeUID"))
end
