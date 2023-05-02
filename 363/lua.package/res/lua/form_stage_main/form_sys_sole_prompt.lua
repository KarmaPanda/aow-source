require("util_functions")
local FORM_COUNT = 1
function main_form_init(self)
  self.Fixed = false
  self.PromptType = -1
  return 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = gui.Width - self.Width
  self.AbsTop = gui.Height - self.Height
  gui.Desktop:ToFront(self)
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function show_sole_prompt(info_id, Index)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_sys_sole_prompt", true, false, FORM_COUNT)
  if not nx_is_valid(form) then
    return
  end
  FORM_COUNT = FORM_COUNT + 1
  form.PromptType = Index
  form.Info_id = info_id
  form.mltbox_descinfo:Clear()
  local descinfo = gui.TextManager:GetText(nx_string(info_id))
  form.mltbox_descinfo:AddHtmlText(nx_widestr("<center>") .. descinfo .. nx_widestr("</center>"), -1)
  form:Show()
end
function on_btn_ok_click(btn)
  local form = btn.Parent
  if form.PromptType == 0 then
    nx_execute("form_stage_main\\form_life\\form_job_main_new", "show_or_hide_main_form", true)
  end
  form:Close()
  return 1
end
function on_btn_cance_click(btn)
  local form = btn.Parent
  form:Close()
end
function show_sole_prompt_msg(info_id, resindex)
  if info_id == nil or info_id == "" or resindex < 0 then
    return
  end
  local Index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", 30, "", -1, resindex)
  nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", Index, info_id)
  nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", Index, resindex)
end
