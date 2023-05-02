require("custom_sender")
require("form_stage_main\\form_guild\\form_guild_util")
local GUILD_FACULTY_STATE_NO = 0
local GUILD_FACULTY_STATE_ING = 1
local CUR_FORM_NAME = "form_stage_main\\form_guildbuilding\\form_guild_build_xiuliantime"
local FORM_GUILD_CHASE_NAME = "form_stage_main\\form_guild_war\\form_guild_chase"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 4
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  start_timer()
  update_left_time(self)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("GuildFacultyState", "int", self, nx_current(), "update_facultystate")
  end
  return 1
end
function on_main_form_close(self)
  end_timer()
  nx_destroy(self)
end
function on_btn_2_click(btn)
  custom_end_xiulian()
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function start_timer()
  local form = nx_value(CUR_FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "update_left_time", form, -1, -1)
  end
end
function end_timer()
  local form = nx_value(CUR_FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "update_left_time", form)
  end
end
function update_left_time(form)
  if not nx_is_valid(form) then
    return
  end
  form.LeftTime = form.LeftTime - 1
  local left_time = form.LeftTime
  if nx_int(left_time) <= nx_int(0) then
    end_timer()
    form:Close()
    return
  end
  form.lbl_3.Text = nx_widestr(nx_execute(nx_string(FORM_GUILD_CHASE_NAME), "get_format_time", nx_number(left_time)))
end
function update_facultystate(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local GuildFacultyState = client_player:QueryProp("GuildFacultyState")
  if nx_int(GuildFacultyState) == nx_int(GUILD_FACULTY_STATE_NO) then
    form:Close()
  else
    form.Visible = true
  end
end
