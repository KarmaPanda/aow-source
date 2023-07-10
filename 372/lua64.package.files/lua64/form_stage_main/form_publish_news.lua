require("util_functions")
require("util_gui")
require("util_role_prop")
local path = "form_stage_main\\form_publish_news"
local g_pop_path = "form_stage_main\\form_publish_pop_news"
function on_main_form_init(self)
  self.Fixed = true
  nx_set_value(path, self)
  return 1
end
function on_main_form_open(form)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  set_form_size(form, "")
  local manager = nx_value("PublicBord")
  if nx_is_valid(manager) then
    manager:BindForm(form)
    manager:SetTotalRuntime(nx_float(30))
  end
  form.Top = 0
  form.lbl_text_len.Font = form.mltbox_1.Font
end
function on_main_form_close(form)
end
function publish_news(style, repeatTime, info, ...)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local form = nx_value(path)
  if form == nil or not nx_is_valid(form) then
    form = util_get_form(path, true)
    nx_set_value(path, form)
  end
  if not nx_is_valid(form) then
    return
  end
  local manager = nx_value("PublicBord")
  if not nx_is_valid(manager) then
    return
  end
  local text = nx_widestr("")
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    text = nx_widestr(info)
  elseif not gui.TextManager:IsIDName(nx_string(info)) then
    text = nx_widestr(info)
  else
    text = util_format_string(info, unpack(arg))
  end
  if nx_widestr(text) == nx_widestr("") then
    return
  end
  if style == 3 then
    nx_execute(g_pop_path, "show_content", info)
    return
  end
  manager:AddPublishNews(nx_widestr(text), nx_int(style), nx_int(repeatTime))
  manager:BindForm(form)
  util_show_form(path, true)
  local form = nx_value(path)
  local bMovie = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_movie_new")
  if bMovie then
    form.Visible = false
    nx_execute("form_stage_main\\form_movie_new", "add_hide_control", form)
  end
end
function close_news(form)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = false
end
function set_form_size(form, str)
  local box = form.mltbox_1
  box.Left = form.Width
  local text = nx_widestr("")
  local temp = nx_widestr(str)
  form.lbl_text_len.Text = temp
  local lenth = form.lbl_text_len.TextWidth
  if lenth == 0 then
    return
  end
  box.Width = lenth
  local view = nx_string(0) .. "," .. nx_string(0) .. "," .. nx_string(box.Width) .. "," .. nx_string(36)
  box.ViewRect = view
  box.HtmlText = nx_widestr(temp)
  local totaltime = 10
  if lenth > form.Width then
    totaltime = 10 * (lenth / form.Width)
  end
  local manager = nx_value("PublicBord")
  if nx_is_valid(manager) then
    manager:SetTotalRuntime(nx_float(totaltime))
  end
end
function on_next_news(form)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local manager = nx_value("PublicBord")
  if not nx_is_valid(manager) then
    return
  end
  local str = manager:GetPublishNews()
  if str == nil or nx_ws_length(nx_widestr(str)) < 1 then
    close_news(form)
    return
  end
  local bord = nx_value(path)
  if not nx_is_valid(bord) then
    return
  end
  bord.Visible = true
  set_form_size(bord, str)
end
