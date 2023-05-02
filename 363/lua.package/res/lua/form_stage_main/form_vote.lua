require("util_functions")
require("share\\client_custom_define")
require("const_define")
local MAX_OPTIONS = 10
function console_log(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Log(info)
  end
end
function main_form_init(form)
  form.Fixed = true
  return 1
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_option_btn_click(btn)
  local form = btn.Parent
  for i = 1, MAX_OPTIONS do
    local temp = "btn_" .. nx_string(i)
    if temp == btn.Name then
      send_select_option(i)
      form:Close()
      return
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function send_select_option(optionid)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_VOTE_OPTION_SELECT), nx_int(optionid))
  return 1
end
function show_form(vote_id)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_vote", true, false, "Vote_Form")
  local index = vote_id
  local file_name = "share\\Rule\\Vote.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local sec_index = ini:FindSectionIndex(nx_string(index))
  if tonumber(sec_index) < 0 then
    index = "default"
  end
  local vote_title = ini:ReadString(sec_index, "VoteTitle", "")
  local vote_timer = ini:ReadInteger(sec_index, "Timer", 0)
  local vote_options = ini:ReadString(sec_index, "Options", "")
  local timer = nx_value(GAME_TIMER)
  timer:Register(nx_int(vote_timer - 2000), 1, nx_current(), "on_update_vote_timer", form, -1, -1)
  form.mltbox_title:AddHtmlText(nx_widestr(vote_title), -1)
  local OptionsArray = util_split_string(nx_string(vote_options), ",")
  MAX_OPTIONS = table.getn(OptionsArray)
  form.Height = form.Height + 20 * nx_int(MAX_OPTIONS)
  for i = 1, MAX_OPTIONS do
    create_option_btn(form, i, OptionsArray[i])
  end
  form.Visible = true
  form:Show()
end
function on_update_vote_timer(form, param1, param2)
  local timer = nx_value(GAME_TIMER)
  timer:UnRegister(nx_current(), "on_update_vote_timer", form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function create_option_btn(form, option, text)
  local gui = nx_value("gui")
  btn = gui:Create("Button")
  btn.BackColor = "255,255,255,0"
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_option_btn_click")
  btn.Width = 100
  btn.Height = 20
  btn.Left = (form.Width - btn.Width) / 2
  btn.Top = form.Height / 5 + (btn.Height + 10) * nx_int(option)
  btn.Name = "btn_" .. nx_string(option)
  btn.Text = nx_widestr(text)
  form:Add(btn)
  form:ToFront(btn)
  return btn
end
