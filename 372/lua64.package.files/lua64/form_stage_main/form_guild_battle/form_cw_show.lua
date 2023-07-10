require("util_gui")
require("util_functions")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_guild_battle\\form_cw_show"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.push_type = 0
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_string(FORM_NAME), "on_delay_open_1", self)
    timer:UnRegister(nx_string(FORM_NAME), "on_delay_open_2", self)
  end
  nx_destroy(self)
end
function open_form(push_type)
  local form = util_get_form(FORM_NAME, true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
  form.mltbox_1:Clear()
  form.push_type = push_type
  if nx_number(0) == nx_number(form.push_type) then
    local text = nx_widestr(util_text("ui_guild_battle_form_shp_081"))
    form.mltbox_1:AddHtmlText(nx_widestr(text), -1)
  elseif nx_number(1) == nx_number(form.push_type) then
    local text = nx_widestr(util_text("ui_guild_battle_form_shp_082"))
    form.mltbox_1:AddHtmlText(nx_widestr(text), -1)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_go_click(btn)
  local form = btn.ParentForm
  if nx_number(0) == nx_number(form.push_type) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "auto_show_hide_form_new_guild")
    local timer = nx_value(GAME_TIMER)
    timer:Register(700, 1, nx_string(FORM_NAME), "on_delay_open_1", form, -1, -1)
  elseif nx_number(1) == nx_number(form.push_type) then
    nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "auto_show_hide_form_new_guild")
    local timer = nx_value(GAME_TIMER)
    timer:Register(700, 1, nx_string(FORM_NAME), "on_delay_open_2", form, -1, -1)
  end
end
function on_delay_open_1(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "open_guild_championwar_desc")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_delay_open_2(form)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_new_guild", "open_guild_championwar_sc")
  if nx_is_valid(form) then
    form:Close()
  end
end
