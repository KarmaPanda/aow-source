require("utils")
require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
local FORM_LINGXIAO = "form_stage_main\\form_lingxiao\\form_lingxiao"
local FORM_ZHIZUNPAGE = "form_stage_main\\form_lingxiao\\form_linxiao_zhizun"
local FORM_EXCHANGEPAGE = "form_stage_main\\form_lingxiao\\form_linxiao_exchange"
local FORM_HELPPAGE = "form_stage_main\\form_lingxiao\\form_linxiao_help"
local FORMTYPE_ZHIZUN = 1
local FORMTYPE_EXCHANGE = 2
function open_form(form_path)
  local form = nx_value(FORM_LINGXIAO)
  if not nx_is_valid(form) then
    form = util_auto_show_hide_form(FORM_LINGXIAO)
  end
end
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  change_form_size()
  load_zhizun_page(form)
  load_exchange_page(form)
  update_shengsifu(form)
  form.rbtn_m1.Checked = true
end
function on_main_form_close(form)
  if nx_is_valid(form.zhizun_page) then
    form.zhizun_page:Close()
  end
  if nx_is_valid(form.exchange_page) then
    form.exchange_page:Close()
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function on_rbtn_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.Checked then
    local index = rbtn.DataSource
    if nx_int(index) == nx_int(FORMTYPE_ZHIZUN) then
      form.groupbox_m1.Visible = true
      form.groupbox_m2.Visible = false
    elseif nx_int(index) == nx_int(FORMTYPE_EXCHANGE) then
      local switch_manager = nx_value("SwitchManager")
      if not nx_is_valid(switch_manager) then
        return
      end
      local exchange_enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_SHENGSIFU_EXCHANGE)
      local shengsifu_enable = switch_manager:CheckSwitchEnable(ST_FUNCTION_SHENGSIFU)
      if exchange_enable and shengsifu_enable then
        form.groupbox_m1.Visible = false
        form.groupbox_m2.Visible = true
      else
        local gui = nx_value("gui")
        if not nx_is_valid(gui) then
          return
        end
        local SystemCenterInfo = nx_value("SystemCenterInfo")
        if not nx_is_valid(SystemCenterInfo) then
          return
        end
        local text = nx_string(gui.TextManager:GetText("sys_linxiao_exchange_switch_not_open"))
        SystemCenterInfo:ShowSystemCenterInfo(nx_widestr(text), CENTERINFO_PERSONAL_NO)
      end
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    end
  end
end
function on_btn_rank_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_lx_ssb")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_lbl_shengsifu_get_capture(lbl)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local text = nx_widestr("")
  local ssfintegral = client_player:QueryProp("SsfIntegral")
  text = text .. gui.TextManager:GetFormatText("ui_lx_sm_tips_1", nx_int(ssfintegral)) .. nx_widestr("<br>")
  local rows = client_player:GetRecordRows("SsfHurtRec")
  if nx_int(rows) > nx_int(0) then
    text = text .. nx_widestr("<br>") .. gui.TextManager:GetFormatText("ui_lx_sm_tips_2") .. nx_widestr("<br>")
    for i = 0, rows - 1 do
      local name = client_player:QueryRecord("SsfHurtRec", i, 0)
      local num = client_player:QueryRecord("SsfHurtRec", i, 2)
      if nx_int(num) > nx_int(0) then
        local zhongwen = gui.TextManager:GetFormatText(nx_string(name))
        text = text .. nx_widestr(zhongwen)
        local length = string.len(nx_string(zhongwen))
        local space_num = 20 - length
        for j = 1, space_num do
          text = text .. nx_widestr("  ")
        end
        text = text .. nx_widestr(num)
        if rows > i + 1 then
          text = text .. nx_widestr("<br>")
        end
      end
    end
    text = text .. nx_widestr("<br><br>")
  end
  text = text .. nx_widestr(gui.TextManager:GetFormatText("ui_lx_sm_tips"))
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    local x, y = gui:GetCursorPosition()
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_lbl_shengsifu_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_help_checked_changed(cbtn)
  util_show_form(FORM_HELPPAGE, cbtn.Checked)
end
function load_zhizun_page(form)
  local zhizun_page = nx_execute("util_gui", "util_get_form", FORM_ZHIZUNPAGE, true, false)
  if not nx_is_valid(zhizun_page) then
    return
  end
  local is_load = form.groupbox_m1:Add(zhizun_page)
  if is_load == true then
    form.zhizun_page = zhizun_page
    form.zhizun_page.Left = 0
    form.zhizun_page.Top = 0
  end
  form.zhizun_page.Visible = true
  return zhizun_page
end
function load_exchange_page(form)
  local exchange_page = nx_execute("util_gui", "util_get_form", FORM_EXCHANGEPAGE, true, false)
  if not nx_is_valid(exchange_page) then
    return
  end
  local is_load = form.groupbox_m2:Add(exchange_page)
  if is_load == true then
    form.exchange_page = exchange_page
    form.exchange_page.Left = 0
    form.exchange_page.Top = 0
  end
  form.exchange_page.Visible = true
  return exchange_page
end
function update_shengsifu(form)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local usenum = nx_int(client_player:QueryProp("SsfUseNum"))
  local addusenum = nx_int(client_player:QueryProp("AddUseNum"))
  local beusenum = nx_int(client_player:QueryProp("SsfBeUseNum"))
  local tooladdnum = nx_int(client_player:QueryProp("ToolAddNum"))
  gui.TextManager:Format_SetIDName("ui_lx_ss_tips")
  gui.TextManager:Format_AddParam(nx_int(usenum))
  gui.TextManager:Format_AddParam(nx_int(addusenum + 275))
  gui.TextManager:Format_AddParam(nx_int(beusenum))
  gui.TextManager:Format_AddParam(nx_int(tooladdnum + 5))
  form.lbl_shengsifu.Text = nx_widestr(gui.TextManager:Format_GetText())
end
function change_form_size()
  local form = nx_value(FORM_LINGXIAO)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
