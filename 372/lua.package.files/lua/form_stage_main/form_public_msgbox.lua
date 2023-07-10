require("custom_sender")
require("util_functions")
local MAX_BTN = 3
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  gui.Desktop:ToFront(self)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_msgbox(msgbox_typeid, uniqueid, ...)
  local instanceid = "msgbox" .. nx_string(msgbox_typeid) .. nx_string(uniqueid)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_public_msgbox", true, false, instanceid)
  if nx_is_valid(form) then
    form.objectid = uniqueid
    form.msgbox_typeid = msgbox_typeid
    for i = 3, MAX_BTN do
      local btn = form:Find("btn_" .. nx_string(i))
      if nx_is_valid(btn) then
        btn.Visible = false
      end
    end
    if table.getn(arg) > 0 then
      local btn_cnt = arg[1]
      for i = 1, btn_cnt do
        local btn = form:Find("btn_" .. nx_string(i))
        if nx_is_valid(btn) then
          btn.Visible = true
          local btn_text = util_text(arg[i + 1])
          if btn_text ~= nil and btn_text ~= "" then
            btn.Text = nx_widestr(btn_text)
          end
        end
      end
      form.mltbox_descinfo:Clear()
      local gui = nx_value("gui")
      gui.TextManager:Format_SetIDName(arg[btn_cnt + 2])
      for j = btn_cnt + 3, table.getn(arg) do
        local arg_type = nx_type(arg[j])
        if arg_type == "number" then
          gui.TextManager:Format_AddParam(nx_int(arg[j]))
        elseif arg_type == "string" then
          gui.TextManager:Format_AddParam(gui.TextManager:GetText(arg[j]))
        else
          gui.TextManager:Format_AddParam(arg[j])
        end
      end
      local descinfo = gui.TextManager:Format_GetText()
      form.mltbox_descinfo:AddHtmlText(nx_widestr("<center>" .. nx_string(descinfo) .. "</center>"), -1)
    end
    form:Show()
    form.Visible = true
  end
end
function on_btn_click(btn)
  local form = btn.Parent
  if string.len(nx_string(btn.Name)) > string.len("btn_") then
    local i, j = string.find(btn.Name, "btn_")
    local index = string.sub(btn.Name, j + 1)
    if tonumber(index) > 0 and tonumber(index) <= MAX_BTN then
      custom_send_msgbox_results_msg(form.msgbox_typeid, nx_int(index), nx_int64(form.objectid))
    end
  end
  form:Close()
  return 1
end
function close_msgbox(msgbox_typeid, uniqueid)
  local instanceid = "msgbox" .. nx_string(msgbox_typeid) .. nx_string(uniqueid)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_public_msgbox", false, false, instanceid)
  if nx_is_valid(form) then
    form:Close()
  end
end
