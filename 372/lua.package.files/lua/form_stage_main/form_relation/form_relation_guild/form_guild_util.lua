require("share\\client_custom_define")
require("define\\sysinfo_define")
require("util_functions")
function guild_util_get_text(text_id, ...)
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetFormatText(text_id, unpack(arg)))
  return text
end
function util_split_string(str, split)
  local result = {}
  if str == nil or split == nil or str == "" then
    return result
  end
  if split == "" then
    table.insert(result, str)
    return result
  end
  local i = 0
  while true do
    local temp = i + 1
    i = string.find(str, split, i + 1)
    if i == nil then
      table.insert(result, string.sub(str, temp))
      break
    end
    local sub_string = string.sub(str, temp, i - 1)
    if sub_string == nil then
      sub_string = ""
    end
    table.insert(result, sub_string)
  end
  return result
end
function transform_date(pdate)
  local text = nx_string(pdate)
  text = string.gsub(text, " ", "")
  text = string.gsub(text, "-", "/")
  text = string.gsub(text, "#", " ")
  return text
end
local FORM_CONTRIBUTE_PERSONAL_MONEY = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm"
local FORM_CONTRIBUTE_PERSONAL_MONEY2 = "form_stage_main\\form_guildbuilding\\form_guild_build_banghuicangku_contributemoneyconfirm2"
local FORM_CONTRIBUTE_GUILD_MONEY = "form_stage_main\\form_guildbuilding\\form_guild_contribute_guild_money"
TYPE_DRAWING = 0
TYPE_BUILD = 1
local SUB_CUSTOMMSG_UPGRADE_DRAWING_BY_GUILD_CAPITAL = 26
local CLIENT_SUBMSG_UPDATE_BY_GUILD_CAPITAL = 6
function show_contribute_form(max_value, cur_value, config, contribute, buildingid, type)
  local gui = nx_value("gui")
  local form = nx_value(nx_string(FORM_CONTRIBUTE_PERSONAL_MONEY))
  if nx_string(config) == nx_string("CapitalType1") then
    form = nx_execute("util_gui", "util_get_form", nx_string(FORM_CONTRIBUTE_PERSONAL_MONEY2), true, false)
    nx_set_value(nx_string(FORM_CONTRIBUTE_PERSONAL_MONEY2), form)
  else
    form = nx_execute("util_gui", "util_get_form", nx_string(FORM_CONTRIBUTE_PERSONAL_MONEY), true, false)
    nx_set_value(nx_string(FORM_CONTRIBUTE_PERSONAL_MONEY), form)
  end
  if not nx_is_valid(form) then
    return
  end
  local MaxValue = max_value - cur_value
  nx_set_value("MaxValue", MaxValue)
  nx_set_value("configID", config)
  nx_set_value("contribute", contribute)
  if nx_string(config) == nx_string("CapitalType1") then
    form.lbl_2.Text = nx_widestr(util_text("ui_use_self_capital"))
  end
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  form:ShowModal()
  form.Visible = true
  form.Fixed = true
  local result, capital_1, capital_2 = nx_wait_event(100000000, form, "form_guild_depot_contributemoneyconfirm_return")
  if result == "ok" then
    if max_value < capital_1 + cur_value then
      local form_logic = nx_value("form_main_sysinfo")
      if nx_is_valid(form_logic) then
        form_logic:AddSystemInfo(util_text("19240"), SYSTYPE_FIGHT, 0)
      end
    elseif type == TYPE_DRAWING then
      local game_visual = nx_value("game_visual")
      if not nx_is_valid(game_visual) then
        return 0
      end
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_UPGRADE_DARWINGS), nx_string(buildingid), nx_string(config), nx_int64(capital_1), nx_int64(capital_2))
    elseif type == TYPE_BUILD then
      nx_execute("custom_sender", "custom_contribute_goods", buildingid, config, capital_1, capital_2)
    end
  end
end
function show_contribute_guild_capital_form(max_value, config, buildingid, type)
  local gui = nx_value("gui")
  local form = nx_value(nx_string(FORM_CONTRIBUTE_GUILD_MONEY))
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", nx_string(FORM_CONTRIBUTE_GUILD_MONEY), true, false)
    nx_set_value(nx_string(FORM_CONTRIBUTE_GUILD_MONEY), form)
  end
  if not nx_is_valid(form) then
    return
  end
  form.Left = (gui.Desktop.Width - form.Width) / 2
  form.Top = (gui.Desktop.Height - form.Height) / 2
  if nx_number(max_value) < nx_number(0) then
    max_value = 0
  end
  form.max_value = max_value
  form:ShowModal()
  form.Visible = true
  form.Fixed = true
  local result, use_capital = nx_wait_event(100000000, form, "contribute_return")
  if result == "ok" then
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return 0
    end
    if type == TYPE_DRAWING then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_UPGRADE_DRAWING_BY_GUILD_CAPITAL), nx_string(buildingid), nx_string(config), nx_int(use_capital))
    elseif type == TYPE_BUILD then
      game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILDBUILDING), nx_int(CLIENT_SUBMSG_UPDATE_BY_GUILD_CAPITAL), buildingid, nx_string(config), nx_int(use_capital))
    end
  end
end
