require("util_gui")
require("util_functions")
local FORM_WORD = "form_stage_main\\form_guild_global_war\\form_guild_global_war_word"
local CLIENT_MSG_GGW_SET_WORD = 105
local CLIENT_MSG_GGW_GET_WORD = 106
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  init_rbtn_word(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    form.Left = (gui.Width - form.Width) / 2
    form.Top = (gui.Height - form.Height) / 2
  end
  nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_GET_WORD)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_form()
  util_show_form(FORM_WORD, true)
end
function close_form()
  local form = nx_value(FORM_WORD)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_set_word_click(btn)
  local form = btn.ParentForm
  for i = 1, 6 do
    local rbtn = form.gb_rbtn:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(rbtn) and rbtn.Checked then
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_SET_WORD, nx_widestr(rbtn.Text))
      nx_execute("custom_sender", "custom_guildglobalwar", CLIENT_MSG_GGW_GET_WORD)
      return
    end
  end
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_gsp_014"))
end
function init_rbtn_word(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local guild_name = client_player:QueryProp("GuildName")
  local tab_guild_name = util_split_wstring(guild_name, "(")
  local str = nx_string(tab_guild_name[1])
  local len = string.len(str)
  for i = 1, 6 do
    local rbtn = form.gb_rbtn:Find("rbtn_" .. nx_string(i))
    if nx_is_valid(rbtn) then
      if i <= len / 2 then
        rbtn.Visible = true
        local str_sub = string.sub(str, 2 * (i - 1) + 1, 2 * i)
        rbtn.Text = nx_widestr(str_sub)
      else
        rbtn.Visible = false
      end
    end
  end
end
function update_info(...)
  local form = util_get_form(FORM_WORD, false)
  if not nx_is_valid(form) then
    return
  end
  if #arg < 1 then
    return
  end
  local word = nx_widestr(arg[1])
  form.lbl_word.Text = word
end
