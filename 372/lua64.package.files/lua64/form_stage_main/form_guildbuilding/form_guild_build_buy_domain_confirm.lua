require("util_gui")
function form_init(form)
  form.Fixed = false
  form.file_name = nil
  form.function_name = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_form(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  local file_name = "form_stage_main\\form_guildbuilding\\" .. nx_string(form.file_name)
  local function_name = nx_string(form.function_name)
  nx_execute(file_name, function_name)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain_confirm")
end
function on_btn_cancel_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain_confirm")
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_ok_clueon"))
  form.lbl_2.Text = nx_widestr(gui.TextManager:GetText("ui_oper_validate"))
  form.btn_ok.Text = nx_widestr(gui.TextManager:GetText("ui_ok"))
  form.btn_cancel.Text = nx_widestr(gui.TextManager:GetText("ui_cancel"))
end
