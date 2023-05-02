function on_main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  form.asid = ""
end
function on_main_form_close(form)
  nx_destroy(form)
  return
end
function on_btn_4_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local asid = nx_string(form.lbl_YYID.Text)
  if asid == "" then
    return
  end
  local url = "http://yy.com/#" .. asid
  nx_function("ext_open_url_ex", nx_widestr(url), "")
end
function on_btn_5_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local asid = nx_string(form.lbl_YYID.Text)
  if asid == "" then
    return
  end
  local url = "http://yy.com/#" .. asid
  nx_function("ext_open_url_ex", nx_widestr(url), "")
end
function show_form(guild_name, yy_name, asid, desc)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(158) then
    return
  end
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_auth_YY")
  if nx_is_valid(form) then
    form.lbl_guild_name.Text = yy_name
    form.lbl_YYID.Text = nx_widestr(asid)
    if desc == nx_widestr("") then
      desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
    end
    form.mltbox_desc:Clear()
    form.mltbox_desc:AddHtmlText(nx_widestr(desc), -1)
    form.Visible = true
  else
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_relation_guild\\form_guild_auth_YY", true, false)
    if not nx_is_valid(form) then
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
    local my_guild_name = client_player:QueryProp("GuildName")
    if my_guild_name == guild_name then
      local form_player = nx_value("form_stage_main\\form_main\\form_main_player")
      if nx_is_valid(form_player) then
        form.AbsLeft = form_player.btn_YY.AbsLeft + form_player.btn_YY.Width - form.Width
        form.AbsTop = form_player.btn_YY.AbsTop + 80
      end
    else
      local form_search = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_search_guild")
      if nx_is_valid(form_search) and form_search.Visible then
        form.AbsLeft = form_search.Left + form_search.Width
        form.AbsTop = form_search.Top + 16
      else
        local form_select = nx_value("form_stage_main\\form_main\\form_main_select")
        if nx_is_valid(form_select) then
          form.AbsLeft = form_select.prog_hp.AbsLeft
          form.AbsTop = form_select.btn_YY.AbsTop + 120
        end
      end
    end
    form.Visible = true
    form:Show()
    form.lbl_guild_name.Text = yy_name
    form.lbl_YYID.Text = nx_widestr(asid)
    if desc == nx_widestr("") then
      desc = gui.TextManager:GetFormatText("ui_guild_YY_desc")
    end
    form.mltbox_desc:Clear()
    form.mltbox_desc:AddHtmlText(nx_widestr(desc), -1)
  end
end
