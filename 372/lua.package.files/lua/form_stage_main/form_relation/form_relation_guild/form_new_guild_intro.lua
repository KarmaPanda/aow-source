require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_relation\\form_relation_guild\\sub_command_define")
local MAIN_FORM_PATH = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild"
local PARENT_FORM_PATH = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_intro_total"
local FORM_WAR_INFO = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_war_info"
local liang_chars = "<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />"
local INI_FILE = "ini\\Guild\\guild_active.ini"
local DEBUG_MODE = true
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.redit_notice.ReadOnly = true
  form.redit_tenet.ReadOnly = true
  form.btn_notice.Visible = false
  form.btn_tenet.Visible = false
  form.lbl_guild_name.Text = nx_widestr("")
  form.lbl_guild_level.BackImage = ""
  form.lbl_guild_founder.Text = nx_widestr("")
  form.lbl_found_date.Text = nx_widestr("")
  form.lbl_hotness.Text = nx_widestr("")
  form.lbl_member_count.Text = nx_widestr("")
  form.lbl_online_count.Text = nx_widestr("")
  form.lbl_guild_location.Text = nx_widestr("")
  form.mltbox_guild_capital.HtmlText = nx_widestr("")
  form.mltbox_money.HtmlText = nx_widestr("")
  form.lbl_guild_bulid.Text = nx_widestr("")
  custom_request_basic_guild_info()
  custom_guild_get_logo()
  form.btn_goto_pros_form.Visible = false
  local ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS = 789
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_LEVEL_POS_MEMBER_MAX_PLUS) then
    form.btn_goto_pros_form.Visible = true
  end
  return true
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
  return true
end
function on_btn_upgrade_click(btn)
  local form_guild = nx_value(MAIN_FORM_PATH)
  if not nx_is_valid(form_guild) then
    return false
  end
  if nx_is_valid(form_guild.form_levelup) then
    form_guild.rbtn_construct.Checked = true
    form_guild.form_levelup.rbtn_guild_levelup.Checked = true
  end
  return true
end
function on_btn_donate_click(btn)
  util_show_form("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_donate_money", true)
end
function on_btn_notice_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local redit_notice = form.redit_notice
  if redit_notice.ReadOnly then
    local btn_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_publish"))
    btn.Text = btn_text
    redit_notice.ReadOnly = false
    gui.Focused = redit_notice
  else
    local edit_text = redit_notice.Text
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(edit_text)) then
      local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidNote"))
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      return false
    end
    custom_request_set_notice(edit_text)
    local btn_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_edit"))
    btn.Text = btn_text
    gui.Focused = nx_null()
    redit_notice.ReadOnly = true
  end
end
function on_btn_tenet_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return false
  end
  local redit_tenet = form.redit_tenet
  if redit_tenet.ReadOnly then
    local btn_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_publish"))
    btn.Text = btn_text
    redit_tenet.ReadOnly = false
    gui.Focused = redit_tenet
  else
    local edit_text = redit_tenet.Text
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) and not check_words:CheckBadWords(nx_widestr(edit_text)) then
      local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidNote"))
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      return false
    end
    custom_request_set_tenet(edit_text)
    local btn_text = nx_widestr(gui.TextManager:GetText("ui_guild_notice_edit"))
    btn.Text = btn_text
    gui.Focused = nx_null()
    redit_tenet.ReadOnly = true
  end
end
function update_guild_level_image(guild_level)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return false
  end
  local image_path = "gui\\guild\\guild_new_2\\"
  local file_name = nx_string(guild_level) .. "b.png"
  local full_path = image_path .. file_name
  form.lbl_guild_level.BackImage = full_path
  return true
end
function get_guild_total_number(guild_level)
  local total_number = 0
  if nx_int(0) == nx_int(guild_level) then
    return total_number
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return total_number
  end
  ini.FileName = nx_resource_path() .. "share\\Guild\\guild_level_position.ini"
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return total_number
  end
  local item_list = ini:GetItemValueList(nx_string(guild_level), "r")
  local item_count = ini:GetItemCount(nx_string(guild_level))
  for i = 1, item_count do
    local value = nx_string(item_list[i])
    local str_list = util_split_string(value, ",")
    total_number = total_number + nx_int(str_list[3])
  end
  nx_destroy(ini)
  return total_number
end
function on_active_btn_click(btn)
  local form_guild = nx_value(MAIN_FORM_PATH)
  if not nx_is_valid(form_guild) then
    return false
  end
  if not nx_find_custom(btn, "main_form_btn") or not nx_find_custom(btn, "sub_form_btn") then
    return false
  end
  local main_rbtn = form_guild.groupbox_1:Find(btn.main_form_btn)
  main_rbtn.Checked = true
  local main_form = form_guild.groupbox_all:Find(main_rbtn.DataSource)
  local sub_rbtn = main_form.groupbox_2:Find(btn.sub_form_btn)
  sub_rbtn.Checked = true
  return true
end
function on_link_btn_click(btn)
  if not nx_find_custom(btn, "link_form") then
    return
  end
  if not nx_find_custom(btn, "act_no") then
    return
  end
  local form_guild = nx_value(MAIN_FORM_PATH)
  if not nx_is_valid(form_guild) then
    return false
  end
  if nx_number(btn.act_no) == 10 then
    local main_rbtn = form_guild.rbtn_diplomacy
    main_rbtn.Checked = true
    local main_form = form_guild.groupbox_all:Find(main_rbtn.DataSource)
    local sub_rbtn = main_form.groupbox_2:Find("rbtn_champion_war")
    sub_rbtn.Checked = true
    local form_war_info = nx_value(FORM_WAR_INFO)
    if nx_is_valid(form_war_info) then
      form_war_info.rbtn_cw_1.Checked = true
    end
    return
  end
  local form_info = util_split_string(btn.link_form, ",")
  if table.getn(form_info) <= 0 then
    return
  end
  util_auto_show_hide_form(form_info[1])
  return true
end
function load_guild_active(info_list)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return false
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local IniManager = nx_value("IniManager")
  if not DEBUG_MODE then
    if not IniManager:IsIniLoadedToManager(INI_FILE) then
      IniManager:LoadIniToManager(INI_FILE)
    end
  else
    IniManager:UnloadIniFromManager(INI_FILE)
    IniManager:LoadIniToManager(INI_FILE)
  end
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) or ini == nil then
    return false
  end
  form.groupbox_template.Visible = false
  form.main_group_scroll_box.IsEditMode = true
  form.main_group_scroll_box:DeleteAll()
  for i = 1, ini:GetSectionCount() do
    local act_no = ini:GetSectionByIndex(i - 1)
    local act_info = find_act_with_msg(act_no, info_list)
    fill_act_info(form, act_info, gui, ini, i - 1)
  end
  form.main_group_scroll_box.IsEditMode = false
  form.main_group_scroll_box:ResetChildrenYPos()
  return true
end
function create_ctrl(ctrl_name, name, refer_ctrl, parent_ctrl)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  nx_set_custom(form, name, ctrl)
  if nx_is_valid(parent_ctrl) then
    parent_ctrl:Add(ctrl)
  end
  ctrl.Name = name
  return ctrl
end
function guild_util_get_text(text_id, ...)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return ""
  end
  local text = nx_widestr(gui.TextManager:GetFormatText(text_id, unpack(arg)))
  return text
end
function custom_request_basic_guild_info()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_BASIC_GUILD_INFO))
  return true
end
function custom_request_set_notice(text)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_GUILD_SET_NOTICE), text)
  return true
end
function custom_request_set_tenet(text)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_SET_PURPOSE), nx_widestr(text))
  return true
end
function custom_guild_get_logo()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GET_LOGO))
  return true
end
function on_recv_basic_info(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) or table.getn(arg) < 13 then
    return false
  end
  form.lbl_guild_name.Text = nx_widestr(arg[1])
  update_guild_level_image(arg[2])
  form.lbl_guild_founder.Text = nx_widestr(arg[3])
  form.lbl_found_date.Text = nx_widestr(arg[4])
  form.lbl_hotness.Text = nx_widestr(arg[8])
  form.lbl_member_count.Text = nx_widestr(nx_string(arg[11]) .. "/" .. nx_string(arg[12]))
  form.lbl_online_count.Text = nx_widestr(arg[10])
  form.lbl_guild_location.Text = nx_widestr(arg[9])
  local capital = nx_int64(arg[7])
  local ding = nx_int(capital / 1000000)
  local liang = nx_int((capital - 1000000 * ding) / 1000)
  local wen = nx_int(capital - 1000000 * ding - 1000 * liang)
  local text = guild_util_get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))
  form.mltbox_guild_capital.HtmlText = nx_widestr(text)
  capital = nx_int64(arg[13])
  ding = nx_int(capital / 1000000)
  liang = nx_int((capital - 1000000 * ding) / 1000)
  wen = nx_int(capital - 1000000 * ding - 1000 * liang)
  text = guild_util_get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))
  form.mltbox_money.HtmlText = nx_widestr(text)
  if nx_ws_length(nx_widestr(arg[6])) <= 0 then
    form.redit_notice.Text = nx_widestr(guild_util_get_text("ui_None"))
  else
    form.redit_notice.Text = nx_widestr(arg[6])
  end
  if 0 >= nx_ws_length(nx_widestr(arg[5])) then
    form.redit_tenet.Text = nx_widestr(guild_util_get_text("ui_None"))
  else
    form.redit_tenet.Text = nx_widestr(arg[5])
  end
  load_guild_active(arg[14])
  return true
end
function on_recv_logo(logo)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return false
  end
  local logo_info = util_split_string(logo, "#")
  if table.getn(logo_info) == 3 then
    if logo_info[1] == "" and logo_info[2] == "" and logo_info[3] == "0,255,255,255" then
      form.pic_logo.Image = "gui\\guild\\formback\\bg_logo.png"
    else
      form.pic_frame.Image = "gui\\guild\\frame\\" .. logo_info[1]
      form.pic_logo.Image = "gui\\guild\\logo\\" .. logo_info[2]
      form.groupbox_logo.BackColor = logo_info[3]
    end
  end
  return true
end
function on_item_grid_mousein(grid, index)
  local data = grid.DataSource
  local vars = util_split_string(data, ",")
  if index >= table.getn(vars) then
    return
  end
  local config_id = vars[index + 1]
  if config_id == nil or nx_string(config_id) == nx_string("") then
    return
  end
  local item_query = nx_value("ItemQuery")
  if not nx_is_valid(item_query) then
    return
  end
  if not item_query:FindItemByConfigID(config_id) then
    return
  end
  nx_execute("tips_game", "show_tips_by_config", config_id, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_item_grid_mouseout(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function create_build_war_step_time(form, act_no, count)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "guild_war_step_time") or not nx_find_custom(form, "guild_war_text_id") then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(nx_current(), "update_guild_war_time", form)
  timer:Register(1000, count, nx_current(), "update_guild_war_time", form, nx_int(act_no), -1)
end
function update_guild_war_time(form, act_no)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ctrl_name = "act_desc" .. nx_string(act_no)
  local ctrl = nx_custom(form, ctrl_name)
  if ctrl == nil or not nx_is_valid(ctrl) then
    return
  end
  if not nx_find_custom(form, "guild_war_step_time") or not nx_find_custom(form, "guild_war_text_id") then
    return
  end
  gui.TextManager:Format_SetIDName(form.guild_war_text_id)
  local min = nx_int(math.mod(form.guild_war_step_time, 3600) / 60)
  local sec = nx_int(math.mod(form.guild_war_step_time, 60))
  form.guild_war_step_time = nx_int(form.guild_war_step_time) - nx_int(1)
  local str_time = nx_string(min) .. ":" .. nx_string(sec)
  gui.TextManager:Format_AddParam(nx_string(str_time))
  ctrl.HtmlText = gui.TextManager:Format_GetText()
end
function find_act_with_msg(act_no, msg)
  local open_acts = util_split_string(msg, ";")
  for i = 1, table.getn(open_acts) do
    local act_info = util_split_string(open_acts[i], ",")
    local act_n = act_info[1]
    if nx_int(act_n) == nx_int(act_no) then
      return open_acts[i]
    end
  end
  return ""
end
function fill_act_info(form, act_info, gui, ini, sect_index)
  if not nx_is_valid(form) then
    return
  end
  if not nx_is_valid(ini) then
    return
  end
  if nx_int(sect_index) < nx_int(0) then
    return
  end
  if nx_string(act_info) == nx_string("") then
    return
  end
  local act_args = util_split_string(act_info, ",")
  local act_no = act_args[1]
  local act_decs_arg = act_args[2]
  if act_no ~= nil then
    local main_form_btn = ini:ReadString(sect_index, "main_form_btn", "")
    local sub_form_btn = ini:ReadString(sect_index, "sub_form_btn", "")
    local text = ini:ReadString(sect_index, "text", "")
    local link_form = ini:ReadString(sect_index, "link_form", "")
    local open_text = ini:ReadString(sect_index, "open_text", "")
    local btn_desc_text = ini:ReadString(sect_index, "btn_desc_text", "")
    local btn_link_text = ini:ReadString(sect_index, "btn_link_text", "")
    local desc_text = ini:ReadString(sect_index, "desc_text", "")
    local award = ini:ReadString(sect_index, "award", "")
    local sub_groupbox = create_ctrl("GroupBox", "sub_groupbox_" .. nx_string(act_no), form.groupbox_template, form.main_group_scroll_box)
    sub_groupbox.Visible = true
    sub_groupbox.Left = 0
    sub_groupbox.Top = sub_groupbox.Height * act_no
    local sub_btn = create_ctrl("Button", "sub_btn_" .. nx_string(act_no), form.btn_template, sub_groupbox)
    nx_bind_script(sub_btn, nx_current())
    nx_callback(sub_btn, "on_click", "on_active_btn_click")
    sub_btn.Text = gui.TextManager:GetFormatText(btn_desc_text)
    sub_btn.Enabled = true
    sub_btn.main_form_btn = main_form_btn
    sub_btn.sub_form_btn = sub_form_btn
    if nx_string(main_form_btn) == nx_string("") or nx_string(sub_form_btn) == nx_string("") then
      sub_btn.Enabled = false
    end
    local link_btn = create_ctrl("Button", "link_btn_" .. nx_string(act_no), form.btn_link_template, sub_groupbox)
    nx_bind_script(link_btn, nx_current())
    nx_callback(link_btn, "on_click", "on_link_btn_click")
    link_btn.Text = gui.TextManager:GetFormatText(btn_link_text)
    link_btn.Enabled = true
    link_btn.link_form = link_form
    link_btn.act_no = act_no
    if nx_string(link_form) == nx_string("") then
      link_btn.Enabled = false
    end
    local open_time = create_ctrl("Label", "open_desc" .. nx_string(act_no), form.lbl_15, sub_groupbox)
    open_time.Text = gui.TextManager:GetFormatText(nx_string(open_text))
    local act_desc = create_ctrl("MultiTextBox", "act_desc" .. nx_string(act_no), form.mltbox_1, sub_groupbox)
    if nx_int(act_no) == nx_int(1) and 1 < table.getn(act_args) then
      desc_text = desc_text .. nx_string("_") .. nx_string(act_args[2])
    end
    gui.TextManager:Format_SetIDName(desc_text)
    if act_decs_arg ~= nil and nx_string(act_decs_arg) ~= nx_string("") then
      if nx_int(act_no) == nx_int(6) and table.getn(act_args) > 4 then
        act_args[3] = nx_number(act_args[3]) / nx_number(10000)
        act_args[5] = nx_int(act_args[5]) / nx_int(10000)
      end
      if nx_int(act_no) == nx_int(1) then
        if 2 < table.getn(act_args) and nx_int(act_args[3]) > nx_int(0) then
          form.guild_war_step_time = nx_int(act_args[3])
          form.guild_war_text_id = nx_string(desc_text)
          update_guild_war_time(form, act_no)
          create_build_war_step_time(form, act_no, nx_int(form.guild_war_step_time))
        end
      else
        for j = 2, table.getn(act_args) do
          local temp_argn = nx_int(act_args[j])
          if j == 3 and nx_int(act_no) == nx_int(6) and nx_number(act_args[3]) < nx_number(1) and nx_number(act_args[3]) ~= nx_number(0) then
            temp_argn = nx_number(act_args[3])
          end
          gui.TextManager:Format_AddParam(temp_argn)
        end
      end
    end
    act_desc.HtmlText = gui.TextManager:Format_GetText()
    local grid = create_ctrl("ImageGrid", "grid_" .. nx_string(act_no), form.imagegrid_1, sub_groupbox)
    local vars = util_split_string(award, ";")
    local ds = ""
    for i = 1, table.getn(vars) do
      local item_info = util_split_string(vars[i], ",")
      if 2 <= table.getn(item_info) then
        local photo = nx_execute("util_static_data", "item_query_ArtPack_by_id", nx_string(item_info[1]), "Photo")
        grid:AddItem(i - 1, photo, item_info[2], nx_int(item_info[2]), -1)
        ds = ds .. item_info[1] .. ","
      end
    end
    grid.DataSource = ds
    nx_bind_script(grid, nx_current())
    nx_callback(grid, "on_mousein_grid", "on_item_grid_mousein")
    nx_callback(grid, "on_mouseout_grid", "on_item_grid_mouseout")
    local sub_lbl = create_ctrl("Label", "sub_lbl_" .. nx_string(act_no), form.lbl_template, sub_groupbox)
    sub_lbl.Text = gui.TextManager:GetText(nx_string(text))
  end
end
function modify_act_state(act_no, desc_text, btn1_enabled, btn2_enabled)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gb = form.main_group_scroll_box:Find("sub_groupbox_" .. nx_string(act_no))
  if not nx_is_valid(gb) then
    return
  end
  local multitext_desc = gb:Find("act_desc" .. nx_string(act_no))
  local sub_btn = gb:Find("sub_btn_" .. nx_string(act_no))
  local link_btn = gb:Find("link_btn_" .. nx_string(act_no))
  if not (nx_is_valid(multitext_desc) and nx_is_valid(sub_btn)) or not nx_is_valid(link_btn) then
    return
  end
  multitext_desc.HtmlText = desc_text
  sub_btn.Enabled = btn1_enabled
  link_btn.Enabled = btn2_enabled
end
function on_btn_goto_pros_form_click(btn)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_levelup", false, false)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_guild_prosperity.Checked = true
  local form_main = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", false, false)
  if not nx_is_valid(form_main) then
    return
  end
  form_main.rbtn_construct.Checked = true
end
