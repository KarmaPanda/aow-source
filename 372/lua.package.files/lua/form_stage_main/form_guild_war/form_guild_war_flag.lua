require("util_functions")
require("share\\client_custom_define")
local GUILD_WAR_FLAG_POINT_COUNT = 4
local CLIENT_SUBMSG_FLAG_CHOSE_OK = 18
local CLIENT_SUBMSG_FLAG_CHOSE_CANCEL = 19
local FLAG_INDEX = 1
local DOMAIN_ID = 0
local BUILD_MIN_LEVEL = 1
local BUILD_MAX_LEVEL = 6
local INDEX_MIN_VAL = 1
local INDEX_MAX_VAL = 4
build_type_table = {
  [1] = {m = 3, s = 0},
  [2] = {m = 4, s = 0},
  [3] = {m = 10, s = 0},
  [4] = {m = 11, s = 0}
}
function main_form_init(form)
  form.Fixed = false
  form.current_panel = nil
  form.revert = os.time() + 90
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.Default = form.ok_btn
  check_loading(form)
  return 1
end
function check_loading(form)
  local form_load = nx_value("form_common\\form_loading")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if nx_is_valid(form_load) then
    gui.Desktop:ToBack(form)
  else
    gui.Desktop:ToFront(form)
  end
end
function close_child_form(form)
  if not nx_is_valid(form) then
    return 0
  end
  if form.current_panel == nil then
    return 0
  end
  if nx_is_valid(form.current_panel) then
    form:Remove(form.current_panel)
  end
  return 0
end
function on_main_form_close(form)
  close_child_form(form)
  nx_destroy(form)
end
function on_ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
  nx_gen_event(form, "guild_flag_return", "ok")
  return 1
end
function on_cancel_btn_click(self)
  local form = self.ParentForm
  form:Close()
  nx_gen_event(form, "guild_flag_return", "cancel")
  return 1
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    FLAG_INDEX = rbtn.flag_index
    for btn_index = 1, GUILD_WAR_FLAG_POINT_COUNT do
      local trap_btn = form.groupbox:Find("btn_" .. btn_index)
      trap_btn.Visible = true
      if btn_index == FLAG_INDEX then
        trap_btn.Visible = false
      end
    end
  end
end
function on_rbtn_get_capture(rbtn)
  local form = rbtn.ParentForm
  local gui = nx_value("gui")
  form.lbl_tip.Text = nx_widestr(gui.TextManager:GetText("ui_guild_war_flag_tip"))
end
function on_rbtn_lost_capture(rbtn)
  local form = rbtn.ParentForm
  form.lbl_tip.Text = nx_widestr("")
end
function on_btn_click(trap_btn)
  local form = trap_btn.ParentForm
  local index = trap_btn.btn_index
  if index < INDEX_MIN_VAL or index > INDEX_MAX_VAL then
    return 1
  end
  local sub_table = build_type_table[index]
  local build_level = trap_btn.build_level
  if build_level < BUILD_MIN_LEVEL or build_level > BUILD_MAX_LEVEL then
    return 1
  end
  nx_execute("form_stage_main\\form_guild_war\\form_guild_war_trap", "show_trap_chose_form", form, nx_int(build_level), nx_int(DOMAIN_ID), nx_int(sub_table.m), nx_int(sub_table.s))
end
function show_guild_war_flag_chose_form(domain_id, yishi_level, jiguan_level, yanwutang_level, jinku_level)
  if domain_id <= 0 then
    return 0
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_flag", true, false)
  if not nx_is_valid(dialog) then
    return 0
  end
  for index = 1, GUILD_WAR_FLAG_POINT_COUNT do
    local btn_flag = dialog.groupbox:Find("rbtn_" .. index)
    local trap_btn = dialog.groupbox:Find("btn_" .. index)
    if nx_is_valid(btn_flag) and nx_is_valid(trap_btn) then
      btn_flag.flag_index = index
      trap_btn.btn_index = index
    end
  end
  local btn_1 = dialog.groupbox:Find("btn_1")
  if nx_is_valid(btn_1) then
    btn_1.build_level = yishi_level + 1
    btn_1.Visible = false
  end
  local btn_2 = dialog.groupbox:Find("btn_2")
  if nx_is_valid(btn_2) then
    btn_2.build_level = jiguan_level + 1
  end
  local btn_3 = dialog.groupbox:Find("btn_3")
  if nx_is_valid(btn_3) then
    btn_3.build_level = yanwutang_level + 1
  end
  local btn_4 = dialog.groupbox:Find("btn_4")
  if nx_is_valid(btn_4) then
    btn_4.build_level = jinku_level + 1
  end
  DOMAIN_ID = domain_id
  dialog:Show()
  local common_execute = nx_value("common_execute")
  common_execute:AddExecute("ShowGuildWarFlagForm", dialog, nx_float(1))
  local res = nx_wait_event(100000000, dialog, "guild_flag_return")
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if res == "ok" then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_FLAG_CHOSE_OK), nx_int(FLAG_INDEX), nx_int(DOMAIN_ID))
  end
end
function on_time_over(form)
  form:Close()
end
