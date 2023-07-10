require("util_gui")
require("util_functions")
require("util_vip")
require("form_stage_main\\form_charge_shop\\charge_shop_define")
function on_main_form_init(form)
  form.Fixed = false
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("vip_info_rec", form, "form_stage_main\\form_zhizunvip\\form_zhizunvip_info", "on_vip_info_rec_change")
  on_vip_change(form)
end
function on_vip_info_rec_change(self, recordname, optype, row, clomn)
  if clomn == VIR_STATUS or clomn == VIR_VALID_TIME then
    on_vip_change(self)
  end
end
function on_vip_change(form)
  form.mltbox_time:Clear()
  if is_vip(player, VT_JINGXIU) then
    local time = nx_number(get_vip_time(player, VT_JINGXIU))
    local str = nx_execute("form_stage_main\\form_vip_info", "format_time_form", time)
    form.mltbox_time:AddHtmlText(util_format_string("ui_sns_timelimit") .. str, nx_int(-1))
  else
    form.mltbox_time:AddHtmlText(util_format_string("ui_buyvip_5"), nx_int(-1))
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.Parent
  form:Close()
end
function on_btn_onlinebuy_click(btn)
  nx_execute("form_stage_main\\switch\\util_url_function", "open_charge_url")
end
function on_btn_buy_click(btn)
  nx_execute("form_stage_main\\form_vip_info", "pay_by_golden")
end
