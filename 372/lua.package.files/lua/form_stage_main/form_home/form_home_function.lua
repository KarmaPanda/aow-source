require("util_functions")
require("util_gui")
require("role_composite")
require("tips_data")
require("share\\view_define")
require("form_stage_main\\form_home\\form_home_msg")
require("util_role_prop")
require("share\\client_custom_define")
require("share\\view_define")
local filter_form_table = {
  "form_stage_main\\form_home\\form_home_function",
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_main\\form_main_marry",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_home\\form_home_model",
  "form_stage_main\\form_home\\form_home_help",
  "form_stage_main\\form_main\\form_main_buff",
  "form_stage_main\\form_main\\form_main_player"
}
local hide_control = {"groupbox_4"}
local close_form_table = {
  "form_stage_main\\form_home\\form_home_myhome"
}
local fengshui_msg = {
  MSG_HEAD = CLIENT_CUSTOMMSG_HOME,
  SUB_MSG = 37,
  QUERY_IS_ADDED_FENGSHUI = 1,
  REQUEST_ADD_FENGSHUI = 2,
  QUERY_CURRENT_BUF = 3
}
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
  local scene_obj = nx_value("scene_obj")
  if nx_is_valid(scene_obj) then
    scene_obj.NumOfSameScene = scene_obj.MaxNumOfSameScene
  end
  if not HomeManager:IsMyHome() and not HomeManager:IsPartnerHome() then
    nx_execute("form_stage_main\\form_home\\form_home_enter", "open_form")
    return
  end
  form = nx_execute("util_gui", "util_get_form", nx_current(), true, false)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.btn_fengshui) then
    form.btn_fengshui.Visible = false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(fengshui_msg.MSG_HEAD), nx_int(fengshui_msg.SUB_MSG), nx_int(fengshui_msg.QUERY_IS_ADDED_FENGSHUI))
  form.Visible = true
  form:Show()
end
function main_form_init(form)
  form.Fixed = true
  form.open_type = 0
end
function on_size_change()
  local form = nx_value(nx_current())
  local gui = nx_value("gui")
  if nx_is_valid(form) and nx_is_valid(gui) then
    form.AbsLeft = 0
    form.AbsTop = gui.Height - form.Height
    form.Width = gui.Desktop.Width
  end
end
function on_main_form_open(form)
  on_size_change()
  nx_execute("gui", "gui_close_allsystem_form", 3)
  nx_execute("form_stage_main\\form_home\\form_home_model", "set_home_model", 1)
  form_init(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurHomeUID", "string", form, "form_stage_main\\form_home\\form_home_function", "on_cur_homeid_changed")
    databinder:AddViewBind(VIEWPORT_HOME_BOX, form, nx_current(), "on_view_operat_home_box")
  end
  show_filter_form()
  hide_main_form_control()
  refresh_show_new_msg_sign(form)
end
function refresh_show_new_msg_sign(form)
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
  local view = game_client:GetView(nx_string(VIEWPORT_HOME_BOX))
  if not nx_is_valid(view) then
    return
  end
  local mutual_form = nx_value("form_stage_main\\form_home\\form_home_mutual")
  local flag = view:QueryProp("HomeEventMsgFlag")
  if nx_int(flag) == nx_int(1) and not nx_is_valid(mutual_form) then
    form.lbl_new_msg.Visible = true
    return
  end
  form.lbl_new_msg.Visible = false
end
function on_view_operat_home_box(grid, optype, view_ident, index, prop_name)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if optype ~= "updateview" and optype ~= "updaterecord" then
    return
  end
  refresh_show_new_msg_sign(form)
end
function reset_mutual_icon(form)
  if not nx_is_valid(form) then
    return
  end
  if not form.lbl_new_msg.Visible then
    return
  end
  local homeid = get_current_homeid()
  if homeid == nx_string("") then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_msg", "client_to_server_msg", CLIENT_SUB_SET_EVENT_LOG, nx_string(homeid))
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
function reset_scene()
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(form)
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if HomeManager.ShowDesignLine then
    HomeManager.ShowDesignLine = false
  end
  local databinder = nx_value("data_binder")
  databinder:DelRolePropertyBind("CurHomeUID", form)
  nx_destroy(form)
  close_filter_form()
  nx_execute("gui", "gui_open_closedsystem_form")
  local form_main = util_get_form("form_stage_main\\form_main\\form_main", false)
  if nx_is_valid(form_main) and nx_is_valid(form_main.groupbox_4) and nx_is_valid(form_main.groupbox_5) then
    form_main.groupbox_4.Visible = true
    form_main.groupbox_5.Visible = true
    if nx_is_valid(form_main.groupbox_update) then
      form_main.groupbox_update.Visible = true
    end
  end
end
function show_filter_form(bool)
  for i, path in pairs(filter_form_table) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form.Visible = true
    end
  end
end
function close_filter_form(bool)
  for i, path in pairs(close_form_table) do
    local form = nx_value(path)
    if nx_is_valid(form) then
      form:Close()
    end
  end
end
function hide_main_form_control()
  local form = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form) then
    return
  end
  for i, name in pairs(hide_control) do
    local control = nx_custom(form, name)
    if nx_is_valid(control) then
      control.Visible = false
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
function on_btn_shop_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_main", "open_form", 1)
end
function on_btn_create_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_main", "open_form", 2)
end
function on_btn_employ_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_guyong", "open_form")
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_mutual_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  nx_execute("form_stage_main\\form_home\\form_home_mutual", "open_form")
  reset_mutual_icon(form)
end
function on_btn_exit_click(btn)
  nx_execute("form_stage_main\\form_bag", "auto_show_hide_bag")
end
function form_init(form)
  local HomeManager = nx_value("HomeManager")
  if not nx_is_valid(HomeManager) then
    return
  end
  if HomeManager:IsMyHome() then
    form.open_type = 1
  elseif HomeManager:IsNeighbourHome() then
    form.open_type = 2
  else
    form.open_type = 3
  end
end
function on_btn_home_click(btn)
  nx_execute("form_stage_main\\form_home\\form_home_myhome", "open_or_close_form")
end
function on_btn_fengshui_click(btn)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  game_visual:CustomSend(nx_int(fengshui_msg.MSG_HEAD), nx_int(fengshui_msg.SUB_MSG), nx_int(fengshui_msg.QUERY_CURRENT_BUF))
  return
end
function on_btn_hire_click(btn)
  nx_execute("form_stage_main\\form_home\\form_building_hire_all_info", "open_form")
end
function handle_fengshui_msg(...)
  if table.getn(arg) < 2 then
    return
  end
  local sub_msg = arg[1]
  if sub_msg == fengshui_msg.QUERY_IS_ADDED_FENGSHUI then
    if arg[2] == 0 then
      local form = nx_value(nx_current())
      if not nx_is_valid(form) then
        return
      end
      form.fengshui_bufid = arg[3]
      display_btn_fengshui()
    else
      undisplay_btn_fengshui()
    end
  elseif sub_msg == fengshui_msg.REQUEST_ADD_FENGSHUI then
    if arg[2] == 0 then
      return
    else
      return
    end
  elseif sub_msg == fengshui_msg.QUERY_CURRENT_BUF then
    local form = nx_value(nx_current())
    if not nx_is_valid(form) then
      return
    end
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    local tips_str = util_text("ui_home_fengshui_02")
    local buffs_text = nx_string("<br>")
    local n = #arg
    for i = 2, n do
      local buff_name = util_format_string("desc_" .. arg[i] .. "_0")
      buffs_text = nx_widestr(buffs_text) .. nx_widestr(i - 1) .. nx_widestr(".  ") .. nx_widestr(buff_name)
      if i < n then
        buffs_text = buffs_text .. nx_widestr("<br>")
      end
    end
    local tips_str = util_format_string("ui_home_fengshui_02", nx_widestr(buffs_text))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(tips_str))
    dialog:ShowModal()
    local gui = nx_value("gui")
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return
      end
      game_visual:CustomSend(nx_int(fengshui_msg.MSG_HEAD), nx_int(fengshui_msg.SUB_MSG), nx_int(fengshui_msg.REQUEST_ADD_FENGSHUI))
      form.btn_fengshui.Visible = false
    else
      return
    end
  end
  return
end
function display_btn_fengshui()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.btn_fengshui) then
    form.btn_fengshui.Visible = true
  end
  return
end
function undisplay_btn_fengshui()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(form.btn_fengshui) then
    form.btn_fengshui.Visible = false
  end
  return
end
