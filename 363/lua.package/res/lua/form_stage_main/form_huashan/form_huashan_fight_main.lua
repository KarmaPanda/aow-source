require("utils")
require("util_gui")
require("const_define")
require("share\\view_define")
require("custom_sender")
require("form_stage_main\\form_huashan\\huashan_define")
require("form_stage_main\\form_huashan\\huashan_function")
local control_inarena_close_table = {}
local FORM_FIGHT_ROLE = "form_stage_main\\form_huashan\\form_huashan_fight_role"
local FORM_FIGHT_MAIN = "form_stage_main\\form_huashan\\form_huashan_fight_main"
local FORM_ROLE_LEFT = "form_stage_main\\form_huashan\\form_huashan_role_left"
local FORM_ROLE_RIGHT = "form_stage_main\\form_huashan\\form_huashan_role_right"
local arena_form_table = {
  FORM_FIGHT_MAIN,
  "form_stage_main\\form_main\\form_main_chat",
  "form_stage_main\\form_main\\form_notice_shortcut",
  "form_stage_main\\form_common_notice",
  "form_stage_main\\form_main\\form_main_trumpet",
  "form_stage_main\\form_main\\form_main_marry",
  "form_stage_main\\form_main\\form_main_sysinfo",
  "form_stage_main\\form_chat_system\\form_chat_light"
}
function main_form_init(self)
  self.Fixed = true
  return 1
end
function on_main_form_open(self)
  on_size_change()
  self.lbl_phase.areaid = 0
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_HUASHAN_FIGHT_ST_PLAYERA, self, nx_current(), "on_viewport_change")
    databinder:AddViewBind(VIEWPORT_HUASHAN_FIGHT_ST_PLAYERB, self, nx_current(), "on_viewport_change")
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(800, -1, nx_current(), "up_data_role_info", self, -1, -1)
  end
  show_or_hide_form(false)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "up_data_role_info", self)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
  end
  local huashan_main = nx_value(m_Main_Path)
  if nx_is_valid(huashan_main) then
    nx_execute(m_Main_Path, "on_custom_msg", "", "", HuaShanCToS_ReqLeaveLooker)
  else
    nx_execute("custom_sender", "custom_request_huashan", nx_int(HuaShanCToS_ReqLeaveLooker))
  end
  show_or_hide_form(true)
  control_inarena_close_table = {}
  reset_self_view()
  nx_destroy(self)
end
function on_main_form_shut(form)
  show_or_hide_form(true)
  control_inarena_close_table = {}
end
function on_size_change()
  local form = nx_value(FORM_FIGHT_MAIN)
  local gui = nx_value("gui")
  if nx_is_valid(form) and nx_is_valid(gui) then
    form.AbsTop = 0
    form.AbsLeft = 0
    form.Width = gui.Desktop.Width
    form.Height = gui.Desktop.Height
  end
end
function on_btn_leave_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_arena_leave_confirm"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    form:Close()
  end
end
function on_btn_huashan_main_click(btn)
  util_auto_show_hide_form(m_Main_Path)
end
function on_btn_video_click(btn)
  nx_execute("form_stage_main\\form_camera\\form_movie_save", "ShowMovieForm")
end
function on_open_form(playera, playerb)
  local player = get_player()
  if not nx_is_valid(player) then
    return
  end
  local playername = nx_widestr(player:QueryProp("Name"))
  if playername == nx_widestr(playera) or playername == nx_widestr(playerb) then
    return
  end
  gather_all_neew_hide_form()
  local form = nx_execute("util_gui", "util_show_form", FORM_FIGHT_MAIN, true)
  if not nx_is_valid(form) then
    return
  end
  local form_left = util_get_form(FORM_ROLE_LEFT, true, false)
  local form_right = util_get_form(FORM_ROLE_RIGHT, true, false)
  if not nx_is_valid(form_left) or not nx_is_valid(form_right) then
    form:Close()
    return
  end
  form.groupbox_left:Add(form_left)
  form.groupbox_right:Add(form_right)
  form.form_left = form_left
  form.form_right = form_right
  form_left.playername = nx_widestr(playera)
  form_right.playername = nx_widestr(playerb)
  on_viewport_change(form, "createview", VIEWPORT_HUASHAN_FIGHT_ST_PLAYERA)
  on_viewport_change(form, "createview", VIEWPORT_HUASHAN_FIGHT_ST_PLAYERB)
end
function up_data_role_info(form)
  nx_execute(FORM_FIGHT_ROLE, "refresh_name", form.form_left)
  nx_execute(FORM_FIGHT_ROLE, "refresh_name", form.form_right)
end
function gather_all_neew_hide_form()
  control_inarena_close_table = {}
  local gui = nx_value("gui")
  local form_list = gui.Desktop:GetChildControlList()
  for i = table.maxn(form_list), 1, -1 do
    local form = form_list[i]
    if nx_is_valid(form) and form.Visible and not is_need_show_form(form) then
      table.insert(control_inarena_close_table, form)
    end
  end
end
function show_or_hide_form(bool)
  local gui = nx_value("gui")
  for i = table.maxn(control_inarena_close_table), 1, -1 do
    local control = control_inarena_close_table[i]
    if nx_is_valid(control) then
      control.Visible = bool
    end
  end
end
function is_need_show_form(form)
  if not nx_is_valid(form) then
    return false
  end
  local script = nx_script_name(form)
  for i, para in pairs(arena_form_table) do
    if script == para then
      return true
    end
  end
  return false
end
function on_btn_self_view_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  reset_self_view()
end
function reset_self_view()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local client_player = game_visual:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local game_control = client_player.scene.game_control
  if not nx_is_valid(game_control) then
    return
  end
  game_control.Target = nx_null()
  game_control.TargetMode = 0
end
function on_viewport_change(form, optype, view_ident)
  if not nx_find_custom(form, "form_left") or not nx_find_custom(form, "form_right") then
    return
  end
  if optype ~= "updateview" and optype ~= "createview" then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return
  end
  local nameprop = ""
  if VIEWPORT_HUASHAN_FIGHT_ST_PLAYERA == view_ident then
    nameprop = "PlayerA"
  elseif VIEWPORT_HUASHAN_FIGHT_ST_PLAYERB == view_ident then
    nameprop = "PlayerB"
  else
    return
  end
  local name = view:QueryProp(nameprop)
  if form.form_left.playername == name then
    nx_execute(FORM_FIGHT_ROLE, "refresh_form", form.form_left, view)
  elseif form.form_right.playername == name then
    nx_execute(FORM_FIGHT_ROLE, "refresh_form", form.form_right, view)
  elseif "ui_vacancy" == nx_string(name) then
  else
    return
  end
  set_area_msg(form, nx_string(view:QueryProp("FightMsg")))
end
function set_area_msg(form, fightmsg)
  if "" == fightmsg then
    return
  end
  local msgs = util_split_string(fightmsg, ";")
  if table.maxn(msgs) < 3 then
    return
  end
  local areaid = nx_number(msgs[1])
  if areaid < 1 or 6 < areaid then
    return
  end
  form.lbl_area.Text = nx_widestr("@ui_area_" .. nx_string(areaid))
  form.lbl_phase.areaid = nx_number(areaid)
  local num = nx_number(msgs[3]) + 1
  form.lbl_num.Text = nx_widestr("@ui_huashanvisit_0" .. nx_string(num))
end
function ExecuteCommonNotice(strItemName, wcsDesc, strFormatTime)
  local form = nx_value(FORM_FIGHT_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form.lbl_phase, "areaid") then
    return
  end
  if not string.find(nx_string(strItemName), "huashan") then
    return
  end
  local areaid = nx_number(form.lbl_phase.areaid)
  if areaid < 1 or 6 < areaid then
    return
  end
  if not string.find(nx_string(strItemName), nx_string(areaid)) then
    return
  end
  form.lbl_phase.Text = nx_widestr(wcsDesc)
  form.lbl_time.Text = nx_widestr(strFormatTime)
end
function other_skill_changed(player, skillid)
  local form = nx_value(FORM_FIGHT_MAIN)
  if not nx_is_valid(form) then
    return
  end
  if string.len(skillid) < 3 then
    return
  end
  if not nx_is_valid(player) then
    return
  end
  nx_execute(FORM_FIGHT_ROLE, "refresh_skill_new", form.form_left, player, skillid)
  nx_execute(FORM_FIGHT_ROLE, "refresh_skill_new", form.form_right, player, skillid)
end
function on_btn_mvp_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_huashan\\form_huashan_tp_mvp")
end
