require("util_gui")
require("custom_sender")
require("util_functions")
require("menu_game")
require("define\\object_type_define")
require("share\\view_define")
require("form_stage_main\\form_task\\task_define")
SHARE_JH_EXPLORE_AWARD = "share\\Rule\\JHExplore\\jh_explore_award.ini"
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.ani_2.Visible = false
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form:Close()
end
function on_server_msg(type, ...)
  if nx_number(type) ~= SERVER_SUB_CUSTOMMSG_JH_AWARD_OPEN then
    return 0
  end
  util_auto_show_hide_form("form_stage_main\\form_task\\form_juqingjieju")
  local form = util_get_form("form_stage_main\\form_task\\form_juqingjieju", true)
  if not nx_is_valid(form) then
    return 0
  end
  if table.getn(arg) < 4 then
    return 0
  end
  local end_type = nx_number(arg[1])
  form.lbl_5.Text = nx_widestr(arg[3])
  form.lbl_8.Text = nx_widestr(arg[4])
  refresh_back_img(form, nx_number(arg[1]), nx_number(arg[2]), nx_number(arg[3]), nx_number(arg[4]))
end
function show_juqingjieju_form(self)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  local form = self
  if not nx_is_valid(form) then
    return 0
  end
  form.Visible = false
  timer:UnRegister(nx_current(), "show_juqingjieju_form", self)
end
function hide_ani_ctrl(self)
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return 0
  end
  local form = self
  if not nx_is_valid(form) then
    return 0
  end
  form.ani_2.Visible = false
  timer:UnRegister(nx_current(), "hide_ani_ctrl", self)
end
function refresh_back_img(form, end_type, pass_type, renown, favorable)
  local ini = nx_execute("util_functions", "get_ini", SHARE_JH_EXPLORE_AWARD)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if end_type == 1 then
    form.ani_2.AnimationImage = "yqd9"
  else
    form.ani_2.AnimationImage = "yqd12"
  end
  form.ani_2.Visible = true
  form.ani_2:Stop()
  form.ani_2:Play()
  local sec_index = ini:FindSectionIndex("calculate")
  local r_tab = ini:GetItemValueList(sec_index, "r")
  local r_count = table.getn(r_tab)
  for i = 1, r_count do
    local r_info = util_split_string(nx_string(r_tab[i]), ",")
    if table.getn(r_info) >= 11 and pass_type == nx_number(r_info[2]) and end_type == nx_number(r_info[3]) and renown >= nx_number(r_info[4]) and renown < nx_number(r_info[5]) and favorable >= nx_number(r_info[6]) and favorable < nx_number(r_info[7]) then
      form.lbl_3.BackImage = nx_string(r_info[9])
      form.lbl_1.BackImage = nx_string(r_info[10])
      local html_text = gui.TextManager:GetText(nx_string(r_info[11]))
      form.mltbox_3:Clear()
      form.mltbox_3:AddHtmlText(html_text, -1)
      return
    end
  end
end
function on_btn_show_jq_detail_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_JIANGHU_MEET), nx_int(CUSTOMMSG_JIANGHU_MEET_AWARD))
  form:Close()
end
function on_ani_2_animation_end(ani, name)
  ani.Visible = false
end
function on_ani_2_animation_start(ani, name)
end
function on_ani_2_animation_loop(ani, name)
  ani.Visible = false
end
