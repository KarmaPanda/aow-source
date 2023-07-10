require("util_gui")
require("util_functions")
require("share\\view_define")
require("share\\capital_define")
local g_form_name = "form_stage_main\\form_depot_upgrade"
function refresh_upgrade_info_ctl(form)
  if not nx_is_valid(form) then
    return
  end
  local bShow = form.rbtn_mid.Checked == true or form.rbtn_adv.Checked == true
  form.lbl_2.Visible = bShow
  form.lbl_3.Visible = bShow
  form.lbl_4.Visible = bShow
  form.mltbox_silver.Visible = bShow
  form.mltbox_card.Visible = bShow
end
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.uplevel = 0
  form.needsilver = 0
  form.needcard = 0
  form.level = 0
  init_upgrade_info(form)
  refresh_upgrade_info_ctl(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_close_click(btn)
  util_show_form(g_form_name, false)
end
function on_ok_click(btn)
  local form = btn.ParentForm
  if form.rbtn_mid.Checked == false and form.rbtn_adv.Checked == false then
    local dialog = util_get_form("form_common\\form_confirm", true, false)
    if not nx_is_valid(dialog) then
      return
    end
    dialog.mltbox_info.HtmlText = util_format_string("ui_upgrade_tips_3")
    dialog.relogin_btn.Visible = false
    dialog:ShowModal()
    return
  end
  local lvl = form.uplevel - form.level
  local capital = nx_value("CapitalModule")
  if show_confirm(capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(form.needsilver)), capital:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(form.needcard))) then
    nx_execute("custom_sender", "send_depot_msg", 1, lvl)
  end
  util_show_form(g_form_name, false)
end
function on_uplevel_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local maxsilver = nx_custom(rbtn, "maxsilver")
    local maxcard = nx_custom(rbtn, "maxcard")
    form.uplevel = nx_custom(rbtn, "level")
    form.needsilver = nx_custom(rbtn, "needsilver")
    form.needcard = nx_custom(rbtn, "needcard")
    local capital = nx_value("CapitalModule")
    if nx_is_valid(capital) then
      form.mltbox_silver.HtmlText = capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(maxsilver))
      form.mltbox_card.HtmlText = capital:FormatCapital(CAPITAL_TYPE_SILVER_CARD, nx_int64(maxcard))
    end
    refresh_upgrade_info_ctl(form)
  end
end
function init_upgrade_info(form)
  local game_client = nx_value("game_client")
  local box = game_client:GetView(nx_string(VIEWPORT_DEPOT))
  if not nx_is_valid(box) then
    return
  end
  local g_items = {
    form.rbtn_mid,
    form.rbtn_adv
  }
  for i, item in pairs(g_items) do
    item.Enabled = false
    nx_set_custom(item, "level", i + 1)
  end
  local level = nx_number(box:QueryProp("DepotLevel"))
  form.level = level
  local temp = ""
  local depot_info = {}
  local ini = get_ini("share\\Rule\\depotbox.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex("LevelInfo")
    local info = ini:GetItemValueList(index, "info")
    local count = table.getn(info)
    for i = 1, count do
      local str = util_split_string(info[i], ",")
      if table.getn(str) == 5 then
        local lvl = nx_number(str[1])
        depot_info[lvl] = {}
        depot_info[lvl].maxsilver = nx_int64(str[2])
        depot_info[lvl].maxcard = nx_int64(str[3])
        depot_info[lvl].needsilver = nx_int64(str[4])
        depot_info[lvl].needcard = nx_int64(str[5])
      end
    end
  end
  for i, item in pairs(g_items) do
    local lvl = nx_custom(item, "level")
    local cfg = depot_info[lvl - 1]
    if cfg ~= nil and level < lvl then
      item.Enabled = true
      nx_set_custom(item, "needsilver", cfg.needsilver)
      nx_set_custom(item, "needcard", cfg.needcard)
    end
  end
  for i, item in pairs(g_items) do
    local lvl = nx_custom(item, "level")
    local cfg = depot_info[lvl]
    if cfg ~= nil and level < lvl then
      item.Enabled = true
      nx_set_custom(item, "maxsilver", cfg.maxsilver)
      nx_set_custom(item, "maxcard", cfg.maxcard)
    end
  end
  if level == nx_number(1) then
    form.rbtn_adv.Enabled = false
  end
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  for lvl_update = 1, 3 do
    local cfg = depot_info[lvl_update]
    if cfg ~= nil then
      if lvl_update == 1 then
        form.mltbox_1.HtmlText = util_format_string("ui_upgrade_info_1") .. nx_widestr("<br>") .. nx_widestr("       ") .. util_format_string("ui_upgrade_info_need", capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(cfg.needsilver)))
      end
      if lvl_update == 2 then
        form.mltbox_2.HtmlText = util_format_string("ui_upgrade_info_2") .. nx_widestr("<br>") .. nx_widestr("       ") .. util_format_string("ui_upgrade_info_need", capital:FormatCapital(CAPITAL_TYPE_SILVER, nx_int64(cfg.needcard)))
      end
    end
  end
end
function show_confirm(silver, card)
  local dialog = util_get_form("form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  if nx_int64(silver) ~= nx_int64(0) and nx_int64(card) ~= nx_int64(0) then
    dialog.mltbox_info.HtmlText = util_format_string("ui_upgrade_tips_1") .. util_format_string(": {@0:str}, {@1:str}", silver, card) .. util_format_string("ui_upgrade_tips_0")
  elseif nx_int64(silver) ~= nx_int64(0) and nx_int64(card) == nx_int64(0) then
    dialog.mltbox_info.HtmlText = util_format_string("ui_upgrade_tips_1") .. util_format_string(": {@0:str}", silver) .. util_format_string("ui_upgrade_tips_0")
  elseif nx_int64(silver) == nx_int64(0) and nx_int64(card) ~= nx_int64(0) then
    dialog.mltbox_info.HtmlText = util_format_string("ui_upgrade_tips_2") .. util_format_string(": {@0:str}", card) .. util_format_string("ui_upgrade_tips_0")
  elseif nx_int64(silver) == nx_int64(0) and nx_int64(card) == nx_int64(0) then
    dialog.mltbox_info.HtmlText = util_format_string("ui_upgrade_tips_1") .. util_format_string(": {@0:str}, {@1:str}", silver, card) .. util_format_string("ui_upgrade_tips_0")
  end
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  return res == "ok"
end
