require("util_gui")
require("share\\client_custom_define")
require("util_functions")
local SHOW_COUNT = 16
function main_form_init(form)
  form.Fixed = false
  form.ini = nil
  form.max_index = 2
  form.page_index = 2
  form.select_colour = 0
  form.change_cost = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.btn_pre.Enabled = false
  form.init_fore_color = form.lbl_name_1.ForeColor
  init_form_info(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_btn_pre_click(btn)
  local form = btn.ParentForm
  if form.page_index <= 1 then
    return
  end
  form.btn_next.Enabled = true
  change_page_index(form, form.page_index - 1)
  if form.page_index == 1 then
    btn.Enabled = false
  end
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if form.page_index >= form.max_index then
    return
  end
  form.btn_pre.Enabled = true
  change_page_index(form, form.page_index + 1)
  if form.page_index == form.max_index then
    btn.Enabled = false
  end
end
function on_rbtn_flag_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  if not nx_find_custom(rbtn, "colour_id") then
    return
  end
  local form = rbtn.ParentForm
  form.select_colour = rbtn.colour_id
end
function on_btn_ok_click(btn)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local form = btn.ParentForm
  if nx_int(form.select_colour) < nx_int(1) or nx_int(form.select_colour) > nx_int(32) then
    local form_logic = nx_value("form_main_sysinfo")
    if nx_is_valid(form_logic) then
      form_logic:AddSystemInfo(util_text("90369"), 1, 0)
    end
    return
  end
  if nx_int(form.change_cost) > nx_int(0) then
    local dialog = nx_execute("form_stage_main\\form_guild_domain\\form_guild_domain_map", "show_dialog", "ui_guildcolor_buy", nx_int(form.change_cost))
    if not nx_is_valid(dialog) then
      return
    end
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res ~= "ok" then
      return
    end
  end
  local SUB_CUSTOMMSG_SET_GUILD_COLOUR = 74
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_SET_GUILD_COLOUR), nx_int(form.select_colour))
  form:Close()
end
function init_form_info(form)
  local ini = nx_execute("util_functions", "get_ini", "share\\Guild\\GuildDomain\\guild_domain_colour.ini")
  if not nx_is_valid(ini) then
    return ""
  end
  form.ini = ini
  local total_count = ini:GetSectionCount()
  local page_count = math.ceil(total_count / SHOW_COUNT)
  form.max_index = page_count
  change_page_index(form, form.page_index)
end
function set_select_colour_guild(...)
  local form = util_show_form("form_stage_main\\form_guild_domain\\form_guild_select_colour", true)
  if not nx_is_valid(form) then
    return
  end
  if #arg < 1 then
    return
  end
  form.change_cost = arg[1]
  table.remove(arg, 1)
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = form.Name
  if common_array:FindArray(array_name) then
    common_array:RemoveArray(array_name)
  end
  common_array:AddArray(array_name, form, 60, true)
  local selected_colour_count = #arg / 2
  for i = 0, selected_colour_count - 1 do
    common_array:AddChild(array_name, nx_string(arg[i * 2 + 2]), nx_widestr(arg[i * 2 + 1]))
  end
  change_page_index(form, 1)
end
function change_page_index(form, page_index)
  local ini = form.ini
  if not nx_is_valid(ini) then
    return ""
  end
  if page_index < 1 or page_index > form.max_index then
    return
  end
  form.page_index = page_index
  form.lbl_cur_page.Text = nx_widestr(form.page_index) .. nx_widestr("/") .. nx_widestr(form.max_index)
  local control_index = 1
  local in_this_page = false
  for i = (page_index - 1) * SHOW_COUNT, page_index * SHOW_COUNT - 1 do
    local colour_id = ini:GetSectionByIndex(i)
    local colour_value = ini:ReadString(i, "NormalColor", "")
    local focus_color = ini:ReadString(i, "FocusColor", "")
    local rgb_index, _ = string.find(nx_string(colour_value), ",")
    if rgb_index then
      colour_value = "255" .. string.sub(nx_string(colour_value), rgb_index, -1)
    end
    rgb_index, _ = string.find(nx_string(focus_color), ",")
    if rgb_index then
      focus_color = "255" .. string.sub(nx_string(focus_color), rgb_index, -1)
    end
    local control_flag = form.groupbox_colour:Find("rbtn_flag_" .. nx_string(control_index))
    local control_name = form.groupbox_colour:Find("lbl_name_" .. nx_string(control_index))
    if nx_is_valid(control_flag) and nx_is_valid(control_name) then
      if colour_value ~= "" then
        control_flag.BlendColor = nx_string(colour_value)
        control_flag.FocusBlendColor = nx_string(focus_color)
        control_flag.PushBlendColor = nx_string(colour_value)
        control_flag.DisableBlendColor = nx_string(colour_value)
        control_flag.colour_id = colour_id
        check_selected_colour(control_flag)
        if nx_int(form.select_colour) == nx_int(colour_id) then
          control_flag.Checked = true
          in_this_page = true
        end
        control_flag.Visible = true
        control_name.Visible = true
      else
        control_flag.Visible = false
        control_name.Visible = false
      end
    end
    control_index = control_index + 1
  end
  if not in_this_page then
    form.rbtn_flag_0.Checked = true
  end
end
function check_selected_colour(control)
  local form = control.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local control_name = "lbl_name_" .. string.sub(nx_string(control.Name), 11, -1)
  local control_guild = form.groupbox_colour:Find(control_name)
  if not nx_is_valid(control_guild) then
    return
  end
  if not nx_find_custom(control, "colour_id") or control.colour_id == "" then
    return
  end
  local common_array = nx_value("common_array")
  if not nx_is_valid(common_array) then
    return
  end
  local array_name = form.Name
  local guild_name = common_array:FindChild(array_name, nx_string(control.colour_id))
  if not guild_name then
    control.Enabled = true
    control.HintText = ""
    control_guild.Text = nx_widestr(util_text("ui_guild_kexuanze"))
    control_guild.ForeColor = form.init_fore_color
    return
  end
  control.Enabled = false
  control.HintText = nx_widestr(util_format_string("ui_guild_color_tips", guild_name))
  control_guild.Text = nx_widestr(util_text("ui_guild_color_choosen"))
  control_guild.ForeColor = "255,255,0,0"
end
