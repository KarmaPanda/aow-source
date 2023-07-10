require("util_functions")
require("custom_sender")
require("share\\client_custom_define")
require("share\\capital_define")
CITY_DEF_CUSTOM_SUB_BUY_ESCORT = 1
function on_main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.singelprice = 0
  form.max_count = 5
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sliver_count = nx_int(form.fipt_1.Text)
  if nx_int(sliver_count) <= nx_int(0) then
    return
  end
  custom_send_guild_city_def(CITY_DEF_CUSTOM_SUB_BUY_ESCORT, sliver_count)
  form:Close()
end
function on_fipt_changed(fipt)
  local form = fipt.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sliver_count = nx_int(fipt.Text)
  form.lbl_sliver.Text = get_yin_info(sliver_count * form.singelprice)
end
function on_btn_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_guild_city_def_msg(...)
  local submsg = nx_int(arg[1])
  if nx_int(submsg) == nx_int(1) then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guild_war\\form_guild_war_def_escort", true, false)
    if not nx_is_valid(form) then
      return false
    end
    form:Show()
    form.singelprice = nx_int(arg[2])
    form.max_count = nx_int(arg[3])
    form.lbl_count.Text = nx_widestr(nx_int(arg[4]))
    form.fipt_1.Text = nx_widestr("1")
    form.lbl_sliver.Text = get_yin_info(form.singelprice)
  end
end
function get_yin_info(n)
  local htmlTextYinZi = nx_widestr("")
  local capital_manager = nx_value("CapitalModule")
  if nx_is_valid(capital_manager) then
    local res = {}
    res = capital_manager:SplitCapital(nx_int(n), CAPITAL_TYPE_SILVER_CARD)
    local ding = res[1]
    local liang = res[2]
    local wen = res[3]
    local capital = nx_int(n)
    local gui = nx_value("gui")
    local textyZi = nx_widestr("")
    if nx_int(ding) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_ding")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(ding) .. nx_widestr(htmlText)
    end
    if nx_int(liang) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_liang")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(liang)) .. nx_widestr(htmlText)
    end
    if nx_int(wen) > nx_int(0) then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr(" ") .. nx_widestr(nx_int(wen)) .. nx_widestr(htmlText)
    end
    if capital == 0 then
      local text = gui.TextManager:GetText("ui_wen")
      local htmlText = nx_widestr(nx_widestr(text))
      htmlTextYinZi = htmlTextYinZi .. nx_widestr("0") .. nx_widestr(htmlText)
    end
  end
  return htmlTextYinZi
end
