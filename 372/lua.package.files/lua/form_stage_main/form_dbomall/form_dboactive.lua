require("utils")
require("share\\capital_define")
require("form_stage_main\\switch\\url_define")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  local web_url = switch_manager:GetUrl(URL_TYPE_DBOMALL_ACTIVE)
  if nx_string(web_url) ~= nx_string("") then
    form.web_view_active.Url = nx_widestr(web_url)
    form.web_view_active:Refresh()
    form.web_view_active:Enable()
  end
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:AddRolePropertyBind("CapitalType0", "int", form, nx_current(), "on_gold_changed")
  end
end
function on_main_form_close(form)
  local data_binder = nx_value("data_binder")
  if nx_is_valid(data_binder) then
    data_binder:DelRolePropertyBind("CapitalType0", form)
  end
  nx_destroy(form)
end
function on_gold_changed(form)
  local manager = nx_value("CapitalModule")
  if not nx_is_valid(manager) then
    return
  end
  local point = manager:GetCapital(CAPITAL_TYPE_GOLDEN)
  local txt = manager:GetFormatCapitalHtml(CAPITAL_TYPE_GOLDEN, point)
  form.mltbox_silver.HtmlText = txt
end
