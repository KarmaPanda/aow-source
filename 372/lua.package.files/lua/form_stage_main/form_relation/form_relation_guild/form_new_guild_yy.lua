require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\switch\\switch_define")
local FORM_YY = "form_stage_main\\form_relation\\form_relation_guild\\form_new_guild_YY"
local SUB_CUSTOMMSG_GUILD_BIND_YY_SET = 98
local SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY = 99
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.yy_query_time = 0
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_BIND_YY) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  guild_is_bind(0)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  nx_destroy(self)
  return
end
function guild_is_bind(type)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" or guild_name == nil then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_QUERY), nx_int(type), guild_name)
end
function show_bind_yy_info(...)
  if table.getn(arg) < 2 then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local type = arg[1]
  if type == 0 then
    local form = nx_value(FORM_YY)
    if not nx_is_valid(form) then
      return
    end
    if arg[2] == 1 then
      form.groupbox_4.Visible = false
      form.groupbox_3.Visible = true
      form.lbl_guild_name.Text = arg[3]
      form.lbl_ID.Text = nx_widestr(arg[4])
      local desc = nx_widestr(arg[5])
      if desc == nx_widestr("") then
        desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
      end
      form.mltbox_desc:Clear()
      form.mltbox_desc:AddHtmlText(desc, -1)
    elseif arg[2] == 0 then
      form.groupbox_4.Visible = true
      form.groupbox_3.Visible = false
    end
  elseif type == 1 then
    if arg[2] == 1 then
      nx_function("ext_guild_bind_yy", nx_int(3), arg[3], arg[4])
    else
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return
      end
      local text = nx_widestr("")
      local my_guild_name = client_player:QueryProp("GuildName")
      if my_guild_name == guild_name then
        text = gui.TextManager:GetFormatText("19889")
      else
        text = gui.TextManager:GetFormatText("19898")
      end
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
    end
  elseif type == 2 then
    nx_execute("form_stage_main\\form_main\\form_main_player", "show_yy_btn", arg[2])
  elseif type == 3 then
    local form_select = nx_value("form_stage_main\\form_main\\form_main_select")
    if nx_is_valid(form_select) then
      if arg[2] == 1 then
        form_select.btn_YY.Visible = true
      else
        form_select.btn_YY.Visible = false
      end
      local game_client = nx_value("game_client")
      if not nx_is_valid(game_client) then
        return
      end
      local client_player = game_client:GetPlayer()
      if not nx_is_valid(client_player) then
        return
      end
      local select_target_ident = client_player:QueryProp("LastObject")
      local select_target = game_client:GetSceneObj(nx_string(select_target_ident))
      if not nx_is_valid(select_target) then
        return
      end
      select_target.guild_is_bind_yy = arg[2]
    end
  end
end
function on_btn_send_post_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_BIND_YY) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local code = nx_string(form.ipt_code.Text)
  if code == "" then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19893")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
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
  if client_player:QueryProp("IsGuildCaptain") ~= 2 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19887")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" or guild_name == nil then
    return
  end
  nx_function("ext_guild_bind_yy", nx_int(1), guild_name, code)
end
function on_btn_delete_bind_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "yy_query_time") and new_time - btn.ParentForm.yy_query_time <= 3 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19892")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  btn.ParentForm.yy_query_time = new_time
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(ST_FUNCTION_GUILD_BIND_YY) then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19895")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
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
  if client_player:QueryProp("IsGuildCaptain") ~= 2 then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetFormatText("19887")
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
    return
  end
  local guild_name = form.lbl_guild_name.Text
  if guild_name == "" or guild_name == nil then
    return
  end
  local sid = form.lbl_ID.Text
  nx_function("ext_guild_bind_yy", nx_int(2), guild_name, nx_string(sid))
end
function save_yy_info(...)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  if nx_int(arg[1]) == nx_int(1) then
    local game_config = nx_value("game_config")
    if not nx_is_valid(game_config) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2], arg[3], game_config.server_name)
    local form = nx_value(FORM_YY)
    if not nx_is_valid(form) then
      return
    end
    form.groupbox_4.Visible = false
    form.groupbox_3.Visible = true
    form.lbl_guild_name.Text = arg[2]
    form.lbl_ID.Text = nx_widestr(arg[3])
    local gui = nx_value("gui")
    local desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
    form.mltbox_desc:Clear()
    form.mltbox_desc:AddHtmlText(desc, -1)
    local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
    if nx_is_valid(form_player) then
      form_player.btn_YY.Enabled = true
    end
  elseif nx_int(arg[1]) == nx_int(2) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2])
    local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
    if nx_is_valid(form_player) then
      form_player.btn_YY.Enabled = false
    end
  elseif nx_int(arg[1]) == nx_int(3) then
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_BIND_YY_SET), nx_int(arg[1]), arg[2], nx_widestr(arg[3]), nx_widestr(arg[4]))
  end
end
function send_bind_info_to_yy(...)
  nx_function("ext_guild_bind_yy", unpack(arg))
end
