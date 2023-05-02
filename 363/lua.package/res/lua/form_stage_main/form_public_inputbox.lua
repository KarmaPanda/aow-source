require("custom_sender")
require("util_functions")
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  gui.Desktop:ToFront(self)
  gui.Focused = self.name_edit
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_inputbox(inputdata_type, inputbox_typeid, uniqueid, descid, ...)
  local instanceid = "inputbox" .. nx_string(inputbox_typeid) .. nx_string(uniqueid)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_public_inputbox", true, false, instanceid)
  if nx_is_valid(form) then
    form.inputbox_typeid = inputbox_typeid
    Special_Process(form, inputbox_typeid)
    if tonumber(inputdata_type) == 0 then
      form.name_edit.OnlyDigit = true
    end
    form.mltbox_descinfo:Clear()
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName(nx_string(descid))
    for k, para in pairs(arg) do
      local arg_type = nx_type(para)
      if arg_type == "number" then
        gui.TextManager:Format_AddParam(nx_int(para))
      elseif arg_type == "string" then
        gui.TextManager:Format_AddParam(gui.TextManager:GetText(para))
      else
        gui.TextManager:Format_AddParam(para)
      end
    end
    local descinfo = gui.TextManager:Format_GetText()
    form.mltbox_descinfo:AddHtmlText(nx_widestr("<center>") .. nx_widestr(descinfo) .. nx_widestr("</center>"), -1)
    form:Show()
    form.Visible = true
  end
end
function ok_btn_click(btn)
  local form = btn.Parent
  if not nx_ws_equal(nx_widestr(form.name_edit.Text), nx_widestr("")) then
    custom_send_inputbox_results_msg(form.inputbox_typeid, form.name_edit.Text)
  end
  form:Close()
  return 1
end
function cancel_btn_click(btn)
  local form = btn.Parent
  form:Close()
  return 1
end
function Special_Process(form, inputbox_typeid)
  if 1 == tonumber(inputbox_typeid) then
    form.name_edit.MaxDigit = 99
  end
end
function close_inputbox(inputbox_typeid, uniqueid)
  local instanceid = "inputbox" .. nx_string(inputbox_typeid) .. nx_string(uniqueid)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_public_inputbox", false, false, instanceid)
  if nx_is_valid(form) then
    form:Close()
  end
end
