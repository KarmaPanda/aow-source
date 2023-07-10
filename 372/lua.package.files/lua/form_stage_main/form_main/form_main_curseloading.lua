function main_form_init(self)
  self.no_need_motion_alpha = true
  return 1
end
function on_main_form_open(self)
  change_form_size()
end
function change_form_size()
  local self = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  self.AbsTop = gui.Desktop.Height - self.Height - 150
  self.AbsLeft = (desktop.Width - self.Width) / 2
end
function set_flow_id(flowid)
  local form = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if not nx_is_valid(form) then
    return
  end
  form.flow_id = flowid
end
function get_text_by_color(text, color)
  if nx_ws_length(nx_widestr(text)) < 1 then
    return ""
  end
  local _begin = nx_widestr("<font color=\"") .. nx_widestr(color) .. nx_widestr("\">")
  local _end = nx_widestr("</font>")
  text = _begin .. nx_widestr(text) .. _end
  return text
end
function do_load_loop(ticks, cursetype, text)
  local form = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if not nx_find_custom(form, "lbl_front") then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local lbl_front = form.lbl_front
  if not nx_find_custom(form, "lbl_move") then
    return
  end
  local lbl_move = form.lbl_move
  if not nx_find_custom(form, "lbl_text") then
    return
  end
  local lbl_text = form.lbl_text
  if not nx_find_custom(form, "groupbox_1") then
    return
  end
  local groupbox = form.groupbox_1
  if not nx_find_custom(form, "groupbox_2") then
    return
  end
  local groupbox2 = form.groupbox_2
  if not nx_is_valid(lbl_front) then
    return
  end
  if not nx_is_valid(lbl_move) then
    return
  end
  if not nx_is_valid(lbl_text) then
    return
  end
  if not nx_is_valid(groupbox) then
    return
  end
  if not nx_is_valid(groupbox2) then
    return
  end
  if text ~= nil then
    local caiji_text = ""
    if cursetype == "skin_flow" then
      caiji_text = gui.TextManager:GetText("ui_caiji_tips_1")
    else
      caiji_text = gui.TextManager:GetText("ui_caiji_tips")
    end
    text = nx_widestr("<center>") .. get_text_by_color(caiji_text, "#FFFFFF") .. get_text_by_color(text, "#46FD15") .. nx_widestr("</center>")
    lbl_text.HtmlText = nx_widestr(text)
  else
    lbl_text.HtmlText = ""
  end
  local length = groupbox.Width
  local _begin = groupbox.Left
  local _end = _begin + length
  local curtick = 0
  lbl_move.Left = _begin
  local common_execute = nx_value("common_execute")
  if nx_is_valid(common_execute) then
    if not nx_find_custom(form, "total_time") then
      nx_set_custom(form, "total_time", nx_float(0))
    end
    common_execute:RemoveExecute("CurseLoading", form)
    common_execute:AddExecute("CurseLoading", form, nx_float(0), nx_float(ticks), nx_int(length), nx_int(_begin))
  end
end
function delete_self()
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_main\\form_main_curseloading")
  if nx_is_valid(form) then
    gui:Delete(form)
  end
  nx_remove_value("form_stage_main\\form_main\\form_main_curseloading")
end
