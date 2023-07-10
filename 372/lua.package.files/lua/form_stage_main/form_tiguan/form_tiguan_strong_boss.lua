require("form_stage_main\\form_tiguan\\form_tiguan_util")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_STRONG_BOSS, 1)
end
function on_btn_cance_click(btn)
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_STRONG_BOSS, 0)
  local form = btn.ParentForm
  form:Close()
end
function show_strong_boss(type, level, boss_id, cost)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if 0 == type then
    close_form()
  end
  if 1 == type then
    local form = util_get_form(FORM_TIGUAN_STRONG_BOSS, true)
    if not nx_is_valid(form) then
      return
    end
    form.mltbox_1:Clear()
    form.mltbox_2:Clear()
    local boss_name = gui.TextManager:GetText(boss_id)
    local text_1 = gui.TextManager:GetFormatText("danshuaboss_02", boss_name, nx_int(cost / 1000))
    form.mltbox_1:AddHtmlText(text_1, -1)
    local text_2 = gui.TextManager:GetText("danshualevelboss_0" .. nx_string(level))
    form.mltbox_2:AddHtmlText(text_2, -1)
    nx_execute("util_gui", "util_show_form", FORM_TIGUAN_STRONG_BOSS, true)
  end
end
function close_form()
  local form = util_get_form(FORM_TIGUAN_STRONG_BOSS, false)
  if nx_is_valid(form) then
    form:Close()
  end
end
