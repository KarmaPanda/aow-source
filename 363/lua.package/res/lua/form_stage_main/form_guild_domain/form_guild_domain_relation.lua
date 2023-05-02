require("util_gui")
function main_form_init(form)
  form.Fixed = true
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function updata_domain_info(...)
  if #arg < 11 then
    return
  end
  local form_guild_domain_map = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_map")
  local form = nx_value("form_stage_main\\form_guild_domain\\form_guild_domain_relation")
  if not nx_is_valid(form) or not nx_is_valid(form_guild_domain_map) then
    return
  end
  form.lbl_info_name.Text = nx_widestr(util_text("ui_dipan_" .. nx_string(form_guild_domain_map.cur_domain_id)))
end
