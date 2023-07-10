require("util_gui")
require("share\\client_custom_define")
require("util_functions")
local FORM_GUILD_DOMAIN_MAP = "form_stage_main\\form_guild_domain\\form_guild_domain_map"
local FORM_GUILD_DOMAIN_INFO = "form_stage_main\\form_guild_domain\\form_guild_domain_info"
local FORM_GUILD_DOMAIN_RELATION = "form_stage_main\\form_guild_domain\\form_guild_domain_relation"
local FORM_GUILD_DOMAIN_DECLARE = "form_stage_main\\form_guild_domain\\form_guild_domain_declare"
local FORM_GUILD_DOMAIN_AREA = "form_stage_main\\form_guild_domain\\form_guild_domain_area"
local FORM_GUILD_SELECT_COLOUR = "form_stage_main\\form_guild_domain\\form_guild_select_colour"
local FORM_GUILD_DOMAIN_NEW_MAP = "form_stage_main\\form_guild_domain\\form_guild_domain_new_map"
local FORM_GUILD_DOMAIN_DECLARE_NEW = "form_stage_main\\form_guild_domain\\form_guild_domain_declare_new"
local DOMAIN_COUNT = 32
local GUILD_RELATION = 1
local GUILD_DECLARE = 2
local SUB_CUSTOMMSG_REQUEST_DOMAIN_INFO = 70
local CLIENT_SUBMSG_REQUEST_DECLARE_INFO = 23
local SUB_CUSTOMMSG_GET_AREA_INFO = 75
local CLIENT_SUBMSG_REQUEST_TIANWEIQIFU_INFO = 38
local SERVER_SUBMSG_SHOW_DECLARE_FORM = 0
local SUB_SERVERMSG_DOMAIN_INFO = 45
local SUB_SERVERMSG_SELECT_COLOUR = 48
local SUB_SERVERMSG_SEND_AREA_INFO = 49
local SERVER_SUBMSG_SHOW_LOOKCOMPETE_FORM = 23
local SERVER_SUBMSG_DECLARE_INFO = 25
local SERVER_SUBMSG_DECLARE_RESULT = 26
local SERVER_SUBMSG_DECLARE_FAIL = 27
local SERVER_SUBMSG_IS_NEW_GUILD_WAR = 35
local page_info_table = {
  [GUILD_RELATION] = {
    Face1 = "ui_guild_tuli_1",
    Face2 = "ui_guild_tuli_2",
    Face3 = "ui_guild_tuli_3",
    Face4 = "ui_guild_tuli_4"
  },
  [GUILD_DECLARE] = {
    gc_icon_3 = "ui_dm_stage_3",
    gc_icon_2 = "ui_dm_stage_2",
    gc_icon_1 = "ui_dm_stage_1",
    gc_icon_0 = "ui_dm_stage_0",
    gc_icon_4 = "ui_dm_stage_6"
  }
}
local ST_FUNCTION_NEW_GUILDWAR = 219
local domain_btn_prefix = "btn_domain_"
local domain_lbl_back_prefix = "lbl_back_"
local domain_name_lbl_prefix = "lbl_domain_"
local domain_widget_suffix = {
  "101",
  "103",
  "201",
  "202",
  "301",
  "302",
  "401",
  "402",
  "501",
  "503",
  "601",
  "602",
  "701",
  "703",
  "801",
  "803",
  "902",
  "903",
  "1001",
  "1003",
  "1101",
  "1102",
  "1202",
  "1203",
  "1301",
  "1304",
  "1401",
  "1404",
  "1602",
  "1603",
  "1701",
  "1703"
}
function main_form_init(form)
  form.Fixed = false
  form.FirstOpen = true
  form.page_index = 0
  form.cur_domain_id = 101
  form.cur_domain_stage = 0
  form.need_change_form = 0
  form.domain_level = 0
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  form.btn_open_info_panel.Visible = false
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if form.FirstOpen then
    local base_info = util_get_form(FORM_GUILD_DOMAIN_INFO, true, false)
    if form.groupbox_base_info:Add(base_info) then
      form.base_info = base_info
      base_info.Visible = false
      base_info.Left = 0
      base_info.Top = 0
    end
    local guild_relation = util_get_form(FORM_GUILD_DOMAIN_RELATION, true, false)
    if form.groupbox_domain_info:Add(guild_relation) then
      form.guild_relation = guild_relation
      guild_relation.Visible = false
      guild_relation.Left = 0
      guild_relation.Top = 0
    end
    local guild_declare = util_get_form(FORM_GUILD_DOMAIN_DECLARE, true, false)
    if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
      guild_declare = util_get_form(FORM_GUILD_DOMAIN_DECLARE_NEW, true, false)
    end
    if form.groupbox_domain_info:Add(guild_declare) then
      form.guild_declare = guild_declare
      guild_declare.Visible = false
      guild_declare.Left = 0
      guild_declare.Top = 0
    end
    local form_guild_look_compete = util_get_form("form_stage_main\\form_guild_domain\\form_guild_look_compete", true, false)
    if form.groupbox_result:Add(form_guild_look_compete) then
      form.form_guild_look_compete = form_guild_look_compete
      form_guild_look_compete.Visible = true
      form_guild_look_compete.Left = 0
      form_guild_look_compete.Top = 0
    end
    local form_guild_domain_area = util_get_form("form_stage_main\\form_guild_domain\\form_guild_domain_area", true, false)
    if form.groupbox_domain_info:Add(form_guild_domain_area) then
      form.form_guild_domain_area = form_guild_domain_area
      form_guild_domain_area.Visible = true
      form_guild_domain_area.Left = 0
      form_guild_domain_area.Top = 0
    end
    form.FirstOpen = false
  end
  form.btn_show_or_hide_name.Checked = false
  form.groupbox_show_options.Visible = false
  form.rbtn_guild_name.Checked = true
  form.rbtn_2.Checked = true
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    hide_all_domain(form)
    form.IsInNewGuildWar = true
    form.btn_open_info_panel.Visible = false
    form.btn_close_info_panel.Visible = true
    form.groupbox_domain_extra_info.Visible = true
    form.btn_close_info_panel.Left = form.groupbox_domain_extra_info.Left + form.groupbox_domain_extra_info.Width - 0.5 * form.btn_close_info_panel.Width
    form:ToFront(form.btn_close_info_panel)
    local msg_delay = nx_value("MessageDelay")
    if not nx_is_valid(msg_delay) then
      return
    end
    local cur_date_time = msg_delay:GetServerDateTime()
    local cur_year, cur_month, cur_day, cur_hour, cur_mins, cur_sec = nx_function("ext_decode_date", cur_date_time)
    local week = nx_function("ext_get_day_of_week", cur_year, cur_month, cur_day)
    if week == 0 then
      week = 7
    end
    local lbl_week_name = "lbl_W" .. week
    local lbl_week = form.groupbox_4:Find(lbl_week_name)
    if nx_is_valid(lbl_week) then
      lbl_week.Visible = true
    end
    local lbl_day_name = "lbl_D" .. week
    local lbl_day = form.groupbox_4:Find(lbl_day_name)
    if nx_is_valid(lbl_day) then
      lbl_day.ForeColor = "255,255,225,127"
    end
    local lbl_manner_name = "lbl_M" .. week
    local lbl_manner = form.groupbox_4:Find(lbl_manner_name)
    if nx_is_valid(lbl_manner) then
      lbl_manner.ForeColor = "255,255,225,127"
    end
  else
    form.IsInNewGuildWar = false
  end
  on_rbtn_checked_changed(form.rbtn_2)
  form.rbtn_guild_map.Checked = true
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  local guild_declare = form.guild_declare
  if nx_int(guild_declare.declare_stage) == nx_int(4) and nx_int(guild_declare.is_selecting) > nx_int(0) then
    nx_execute("form_stage_main\\form_main\\form_main", "show_declare_btn", nx_int(guild_declare.life_time))
    form.Visible = false
  else
    form:Close()
  end
end
function on_btn_open_info_panel_click(btn)
  local form = btn.ParentForm
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form.groupbox_domain_extra_info.Visible = true
    form.btn_close_info_panel.Left = form.groupbox_domain_extra_info.Left + form.groupbox_domain_extra_info.Width - 0.5 * form.btn_close_info_panel.Width
    form.btn_close_info_panel.Visible = true
    form:ToFront(form.btn_close_info_panel)
    btn.Visible = false
    return
  end
  form.groupbox_domain_info.Visible = true
  form.btn_close_info_panel.Visible = true
  btn.Visible = false
end
function on_btn_close_info_panel_click(btn)
  local form = btn.ParentForm
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form.groupbox_domain_extra_info.Visible = false
    form.btn_open_info_panel.Visible = true
    btn.Visible = false
    return
  end
  form.groupbox_domain_info.Visible = false
  form.btn_open_info_panel.Visible = true
  btn.Visible = false
end
function on_btn_domain_click(btn)
  local form = btn.ParentForm
  form.groupbox_domain_info.Visible = true
  form.btn_close_info_panel.Visible = true
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    if form.groupbox_domain_extra_info.Visible then
      form.btn_open_info_panel.Visible = false
      form.btn_close_info_panel.Visible = true
    else
      form.btn_open_info_panel.Visible = true
      form.btn_close_info_panel.Visible = false
    end
  end
  local domain_id = nx_int(string.sub(nx_string(btn.Name), 12, -1))
  nx_execute(FORM_GUILD_DOMAIN_DECLARE, "hide_all_groupbox", form.guild_declare)
  hide_all_sub_page(form)
  form.base_info.Visible = true
  form.guild_declare.Visible = true
  form.cur_domain_id = domain_id
  form.cur_domain_stage = btn.DataSource
  form.need_change_form = 1
  custom_request_domian(domain_id)
end
function on_btn_area_click(btn)
  local form = btn.ParentForm
  local scene_id = string.sub(nx_string(btn.Name), 10, -1)
  hide_all_sub_page(form)
  form.form_guild_domain_area.Visible = true
  if nx_find_custom(form, "IsInNewGuildWar") and form.IsInNewGuildWar then
    form.form_guild_domain_area.groupbox_old.Visible = false
    form.form_guild_domain_area.groupbox_new.Visible = true
    form.form_guild_domain_area.mltbox_desc:Clear()
    local text = util_text("ui_info_newguildwar_" .. nx_string(scene_id))
    form.form_guild_domain_area.mltbox_desc:AddHtmlText(nx_widestr(text), -1)
  else
    form.form_guild_domain_area.groupbox_old.Visible = true
    form.form_guild_domain_area.groupbox_new.Visible = false
    nx_execute(FORM_GUILD_DOMAIN_AREA, "clear_form_info", form.form_guild_domain_area)
    custom_request_area_info(scene_id)
  end
end
function on_rbtn_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local page_index = nx_int(rbtn.DataSource)
  form.page_index = page_index
  init_tuli(form, form.page_index)
  hide_all_sub_page(form)
  if page_index == nx_int(GUILD_RELATION) then
    form.base_info.Visible = true
    form.guild_relation.Visible = true
  elseif page_index == nx_int(GUILD_DECLARE) then
    form.base_info.Visible = true
    form.guild_declare.Visible = true
    form.need_change_form = 1
    custom_request_declare_info()
    if nx_find_custom(form, "IsInNewGuildWar") and not form.IsInNewGuildWar then
      custom_request_domian(form.cur_domain_id)
    end
  end
end
function on_btn_refresh_click(btn)
  local form = btn.ParentForm
  if nx_int(form.cur_domain_id) > nx_int(0) then
    custom_request_domian(form.cur_domain_id)
  end
  if nx_int(form.page_index) == nx_int(GUILD_RELATION) then
  elseif nx_int(form.page_index) == nx_int(GUILD_DECLARE) then
    local guild_declare = form.guild_declare
    form.need_change_form = 0
    custom_request_declare_info()
    if guild_declare.declare_stage == 0 then
      local CLIENT_SUBMSG_REQUEST_COMPETE_RESULT = 26
      nx_execute(FORM_GUILD_DOMAIN_DECLARE, "custom_request_info", nx_int(CLIENT_SUBMSG_REQUEST_COMPETE_RESULT))
    else
      local CLIENT_SUBMSG_REQUEST_COMPETE_INFO = 25
      nx_execute(FORM_GUILD_DOMAIN_DECLARE, "custom_request_info", nx_int(CLIENT_SUBMSG_REQUEST_COMPETE_INFO))
    end
  end
end
function on_btn_show_or_hide_name_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.groupbox_show_options.Visible = true
  else
    form.groupbox_show_options.Visible = false
  end
end
function on_btn_domain_get_capture(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "colour_id") or not nx_find_custom(btn, "domain_id") then
    return
  end
  local lbl_control_name = "lbl_back_" .. nx_string(btn.domain_id)
  local lbl_control = form.groupbox_domain:Find(lbl_control_name)
  if nx_is_valid(lbl_control) then
    local FocusBlendColor = nx_execute(FORM_GUILD_DOMAIN_DECLARE, "get_real_colour", nx_string(btn.colour_id), "FocusColor", "255")
    lbl_control.BlendColor = FocusBlendColor
  end
end
function on_btn_domain_lost_capture(btn)
  local form = btn.ParentForm
  if not nx_find_custom(btn, "colour_id") or not nx_find_custom(btn, "domain_id") then
    return
  end
  local lbl_control_name = "lbl_back_" .. nx_string(btn.domain_id)
  local lbl_control = form.groupbox_domain:Find(lbl_control_name)
  if nx_is_valid(lbl_control) then
    local NormalColor = nx_execute(FORM_GUILD_DOMAIN_DECLARE, "get_real_colour", nx_string(btn.colour_id), "NormalColor", "255")
    lbl_control.BlendColor = NormalColor
  end
end
function on_rbtn_scene_map_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  nx_execute("form_stage_main\\form_map\\form_map_scene", "auto_show_hide_map_scene")
  rbtn.ParentForm:Close()
end
function on_btn_history_click(btn)
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_guild_domain\\form_guild_war_history")
end
function on_rbtn_guild_name_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local child_list = form.groupbox_show_name:GetChildControlList()
  for i = 1, #child_list do
    local control = child_list[i]
    if nx_is_valid(control) and nx_custom(control, "guild_name") then
      local guild_name = control.guild_name
      if nx_ws_length(guild_name) == 0 then
        guild_name = util_text("ui_dm_stage_0")
      end
      control.Text = nx_widestr(guild_name)
    end
  end
  form.groupbox_show_name.Visible = true
end
function on_rbtn_domain_name_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local child_list = form.groupbox_show_name:GetChildControlList()
  for i = 1, #child_list do
    local control = child_list[i]
    if nx_is_valid(control) and nx_custom(control, "domain_id") then
      local domain_id = control.domain_id
      control.Text = nx_widestr(util_text("ui_dipan_" .. nx_string(domain_id)))
    end
  end
  form.groupbox_show_name.Visible = true
end
function on_rbtn_none_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  form.groupbox_show_name.Visible = false
end
function init_tuli(form, index)
  if nx_int(index) > nx_int(#page_info_table) or nx_int(index) < nx_int(1) then
    return
  end
  local control_list = form.groupbox_tuli:GetChildControlList()
  for i = 1, #control_list do
    if nx_is_valid(control_list[i]) then
      control_list[i].Visible = false
    end
  end
  local control_index = 1
  for image, text in pairs(page_info_table[nx_number(index)]) do
    local image_name = "lbl_tuli_img_" .. nx_string(control_index)
    local text_name = "lbl_tuli_text_" .. nx_string(control_index)
    local control_image = form.groupbox_tuli:Find(image_name)
    local control_text = form.groupbox_tuli:Find(text_name)
    if nx_is_valid(control_image) and nx_is_valid(control_text) then
      control_image.BackImage = "gui\\guild\\guild_jingbiao\\" .. nx_string(image) .. ".png"
      control_text.Text = nx_widestr(util_text(text))
      control_image.Visible = true
      control_text.Visible = true
      control_index = control_index + 1
    end
  end
end
function hide_all_sub_page(form)
  if nx_is_valid(form.base_info) then
    form.base_info.Visible = false
  end
  if nx_is_valid(form.guild_relation) then
    form.guild_relation.Visible = false
  end
  if nx_is_valid(form.guild_declare) then
    form.guild_declare.Visible = false
  end
  if nx_is_valid(form.form_guild_domain_area) then
    form.form_guild_domain_area.Visible = false
  end
end
function show_dialog(info_id, ...)
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.mltbox_info:Clear()
  dialog.mltbox_info.HtmlText = nx_widestr(util_format_string(nx_string(info_id), unpack(arg)))
  dialog:ShowModal()
  return dialog
end
function open_form_for_browse()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local form
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_value(FORM_GUILD_DOMAIN_NEW_MAP)
  else
    form = nx_value(FORM_GUILD_DOMAIN_MAP)
  end
  if nx_is_valid(form) then
    form:Close()
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_GUILD_DOMAIN_NEW_MAP)
  else
    form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_GUILD_DOMAIN_MAP)
  end
  if not nx_is_valid(form) then
    return
  end
  form.guild_declare.btn_declare_compete.Visible = false
  form.guild_declare.btn_declare.Visible = false
  form.guild_declare.lbl_flash.Visible = false
end
function custom_request_domian(domian_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_DOMAIN_INFO), nx_int(domian_id))
end
function custom_request_declare_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_DECLARE_INFO))
  show_loading_animation()
end
function custom_request_area_info(scene_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_AREA_INFO), nx_int(scene_id))
end
function recv_server_domain_message(...)
  if nx_int(SUB_SERVERMSG_DOMAIN_INFO) == nx_int(arg[1]) then
    nx_execute(FORM_GUILD_DOMAIN_INFO, "updata_domain_info", unpack(arg))
    nx_execute(FORM_GUILD_DOMAIN_RELATION, "updata_domain_info", unpack(arg))
    nx_execute(FORM_GUILD_DOMAIN_DECLARE, "updata_domain_info", unpack(arg))
  elseif nx_int(SUB_SERVERMSG_SEND_AREA_INFO) == nx_int(arg[1]) then
    nx_execute(FORM_GUILD_DOMAIN_AREA, "updata_domain_area_info", unpack(arg))
  elseif nx_int(SUB_SERVERMSG_SELECT_COLOUR) == nx_int(arg[1]) then
    table.remove(arg, 1)
    nx_execute(FORM_GUILD_SELECT_COLOUR, "set_select_colour_guild", unpack(arg))
  end
end
function recv_server_declare_message(sub_msg, ...)
  if nx_int(SERVER_SUBMSG_DECLARE_INFO) == nx_int(sub_msg) then
    nx_execute(FORM_GUILD_DOMAIN_DECLARE, "init_declare_info", unpack(arg))
  elseif nx_int(SERVER_SUBMSG_SHOW_LOOKCOMPETE_FORM) == nx_int(sub_msg) then
    nx_execute(FORM_GUILD_DOMAIN_DECLARE, "updata_declare_compete_result", unpack(arg))
  elseif nx_int(SERVER_SUBMSG_SHOW_DECLARE_FORM) == nx_int(sub_msg) then
    if nx_int(arg[2]) > nx_int(0) then
      nx_execute(FORM_GUILD_DOMAIN_DECLARE, "open_declare_form", arg[2])
    else
      nx_execute(FORM_GUILD_DOMAIN_DECLARE, "close_declare_form")
    end
  elseif nx_int(SERVER_SUBMSG_DECLARE_RESULT) == nx_int(sub_msg) then
    nx_execute("form_stage_main\\form_guild_domain\\form_guild_look_compete", "show_declare_result", unpack(arg))
  elseif nx_int(SERVER_SUBMSG_DECLARE_FAIL) == nx_int(sub_msg) and nx_int(#arg) > nx_int(0) then
    show_dialog(arg[1])
  end
end
function on_btn_help_click(btn)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,bangpaipian03,Newguildwar04")
  else
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,bangpaipian03,bangpaizhangaoshi04")
  end
end
function show_loading_animation()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value(FORM_GUILD_DOMAIN_NEW_MAP)
  else
    form_guild_domain_map = nx_value(FORM_GUILD_DOMAIN_MAP)
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  form_guild_domain_map.lbl_loading_back.Visible = true
  form_guild_domain_map.lbl_loading_animation.Visible = true
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "hide_loading_animation", form_guild_domain_map)
  timer:Register(1000, 1, nx_current(), "hide_loading_animation", form_guild_domain_map, -1, -1)
end
function hide_loading_animation()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if switch_manager:CheckSwitchEnable(ST_FUNCTION_NEW_GUILDWAR) then
    form_guild_domain_map = nx_value(FORM_GUILD_DOMAIN_NEW_MAP)
  else
    form_guild_domain_map = nx_value(FORM_GUILD_DOMAIN_MAP)
  end
  if not nx_is_valid(form_guild_domain_map) then
    return
  end
  form_guild_domain_map.lbl_loading_back.Visible = false
  form_guild_domain_map.lbl_loading_animation.Visible = false
end
function updata_guild_name_text(form)
  if form.rbtn_guild_name.Checked then
    on_rbtn_guild_name_checked_changed(form.rbtn_guild_name)
  end
end
function on_btn_taofa_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghuzd02,bangpaipian03,bangpaitaofa04")
end
function hide_all_domain(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, table.getn(domain_widget_suffix) do
    local domain_btn_name = domain_btn_prefix .. domain_widget_suffix[i]
    local domain_btn = form.groupbox_domain:Find(domain_btn_name)
    if nx_is_valid(domain_btn) then
      domain_btn.Visible = false
    end
    local domain_lbl_back_name = domain_lbl_back_prefix .. domain_widget_suffix[i]
    local domain_lbl_back = form.groupbox_domain:Find(domain_lbl_back_name)
    if nx_is_valid(domain_lbl_back) then
      domain_lbl_back.Visible = false
    end
    local domain_name_lbl_name = domain_name_lbl_prefix .. domain_widget_suffix[i]
    local domain_lbl_name = form.groupbox_show_name:Find(domain_name_lbl_name)
    if nx_is_valid(domain_lbl_name) then
      domain_lbl_name.Visible = false
    end
    local zhanling_lbl_name = "lbl_zhanling_" .. domain_widget_suffix[i]
    local zhanling_lbl = form.groupbox_1:Find(zhanling_lbl_name)
    if nx_is_valid(zhanling_lbl) then
      zhanling_lbl.Visible = false
    end
    local qifu_lbl_name = "lbl_qifu_" .. domain_widget_suffix[i]
    local qifu_lbl = form.groupbox_1:Find(qifu_lbl_name)
    if nx_is_valid(qifu_lbl) then
      qifu_lbl.Visible = false
    end
    local declare_lbl_name = "lbl_atk_" .. domain_widget_suffix[i]
    local declare_lbl = form.groupbox_2:Find(declare_lbl_name)
    if nx_is_valid(declare_lbl) then
      declare_lbl.Visible = false
    end
    local zhanling_time_lbl_name = "lbl_time_" .. domain_widget_suffix[i]
    local zhanling_time_lbl = form.groupbox_show_time:Find(zhanling_time_lbl_name)
    if nx_is_valid(zhanling_time_lbl) then
      zhanling_time_lbl.Visible = false
    end
  end
  local domains = {
    "1301",
    "1404",
    "1602",
    "1703"
  }
  for i = 1, table.getn(domains) do
    local weapon_lbl_name = "lbl_weapon_" .. domains[i]
    local weapon_lbl = form.groupbox_1:Find(weapon_lbl_name)
    if nx_is_valid(weapon_lbl) then
      weapon_lbl.Visible = false
    end
  end
  for i = 1, 7 do
    local lbl_week_name = "lbl_W" .. i
    local lbl_week = form.groupbox_4:Find(lbl_week_name)
    if nx_is_valid(lbl_week) then
      lbl_week.Visible = false
    end
  end
  return
end
function on_btn_tianweiqifu_click(btn)
  if not nx_is_valid(btn) then
    return
  end
  nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_guild_domain\\form_guild_tianweiqifu")
  return
end
function on_btn_guildwar_point_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  local CLIENT_SUBMSG_REQUEST_GUILDWAR_RANK = 41
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD_WAR), nx_int(CLIENT_SUBMSG_REQUEST_GUILDWAR_RANK))
end
