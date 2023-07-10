require("utils")
require("util_gui")
require("const_define")
require("custom_sender")
local FORM_FIGHT_INFO_COMMON = "form_stage_main\\form_fight\\form_fight_info_common"
function main_form_init(form)
  form.Fixed = true
  form.target_scene_id = 0
  form.life_time = 3
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 3
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:Register(1000, -1, nx_current(), "close_form", form, -1, -1)
  end
end
function on_main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_form", form)
  end
  nx_destroy(form)
end
function on_main_form_shut(form)
end
function open_form_by_custom(...)
  if #arg < 1 then
    return
  end
  local form = nx_value(FORM_FIGHT_INFO_COMMON)
  if nx_is_valid(form) then
    form.life_time = 3
  else
    form = nx_execute("util_gui", "util_show_form", FORM_FIGHT_INFO_COMMON, true)
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.TextManager:Format_SetIDName(nx_string(arg[1]))
  if 1 < #arg then
    table.remove(arg, 1)
    for i, para in pairs(arg) do
      local type = nx_type(para)
      if type == "number" then
        gui.TextManager:Format_AddParam(nx_int(para))
      elseif type == "string" then
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
  end
  form.lbl_text.Text = gui.TextManager:Format_GetText()
end
function close_form(form)
  if not nx_is_valid(form) then
    return
  end
  if form.life_time > 0 then
    form.life_time = form.life_time - 1
    return
  end
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_form", form)
  end
  form:Close()
end
