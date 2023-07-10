require("util_functions")
require("form_stage_main\\form_task\\task_define")
local TASK_LIST_HEIGHT = 160
local GROUPSCROLLBOX_HEIGHT = 165
function main_form_init(self)
  self.Fixed = false
  self.Visible = false
  return 1
end
function main_form_open(self)
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function show_fuben_task(npc_configid, npc_photo, task_id, title_id, context_id, target_id)
  local form = nx_value("form_stage_main\\form_task\\form_fuben_task_tips")
  if nx_is_valid(form) then
    form:Close()
  end
  form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_task\\form_fuben_task_tips", true)
  show_npc_image(form, npc_configid, npc_photo)
  show_fuben_task_info(form, task_id, title_id, context_id, target_id)
  local gui = nx_value("gui")
  local photo = "<img src=\"gui\\special\\task\\leixing\\leixing_11.png\" data=\"\" />"
  local menu_info = nx_widestr(photo) .. nx_widestr(gui.TextManager:GetText("ui_task_iknow"))
  form.mltbox_menu_func:AddHtmlText(nx_widestr(menu_info), 0)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_menu_func_select(menu_list, index)
  local form = menu_list.ParentForm
  form:Close()
end
function show_fuben_task_info(form, task_id, title_id, context_id, target_id)
  local gui = nx_value("gui")
  local task_info_text = nx_widestr("<font color=\"#ff80ff\">") .. nx_widestr(gui.TextManager:GetText("ui_task_teamshow")) .. nx_widestr("</font>")
  local title_text = gui.TextManager:GetText(title_id)
  title_text = nx_widestr("<font color=\"#ffff00\">") .. nx_widestr(title_text) .. nx_widestr("</font>")
  if title_text ~= nil and title_text ~= nx_widestr("") then
    task_info_text = nx_widestr(task_info_text) .. nx_widestr("<br><br>") .. nx_widestr(title_text)
  end
  local target_text = gui.TextManager:GetText(target_id)
  if target_text ~= nil and nx_widestr(target_text) ~= nx_widestr("") then
    task_info_text = nx_widestr(task_info_text) .. nx_widestr("<br>") .. nx_widestr(target_text)
  end
  task_info_text = nx_widestr(task_info_text) .. nx_widestr("<br><font color=\"#ffff00\">") .. nx_widestr(gui.TextManager:GetText("ui_task_describe")) .. nx_widestr("</font>")
  local context_text = gui.TextManager:GetText(context_id)
  local ex_para_flag = string.find(nx_string(context_text), "@0:")
  if ex_para_flag ~= nil then
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local name = client_player:QueryProp("Name")
    gui.TextManager:Format_SetIDName(nx_string(context_id))
    gui.TextManager:Format_AddParam(name)
    context_text = gui.TextManager:Format_GetText()
  end
  if context_text ~= nil and context_text ~= nx_widestr("") then
    task_info_text = nx_widestr(task_info_text) .. nx_widestr("<br>") .. nx_widestr(context_text)
  end
  local index = form.talk_list:AddHtmlText(nx_widestr(task_info_text), nx_int(0))
  form.talk_list:SetHtmlItemSelectable(nx_int(index), false)
  local content_height = form.talk_list:GetContentHeight()
  if content_height < TASK_LIST_HEIGHT then
    content_height = TASK_LIST_HEIGHT
  end
  form.groupscrollbox_1.IsEditMode = true
  form.talk_list.Height = content_height
  form.groupscrollbox_1.Height = GROUPSCROLLBOX_HEIGHT
  form.groupscrollbox_1.IsEditMode = false
end
function show_npc_image(form, npc_configid, npc_photo)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local npc_name = gui.TextManager:GetText(nx_string(npc_configid))
  form.name_label.Text = npc_name
  local photo_head = nx_string(npc_photo)
  if photo_head ~= "" then
    local str_const = "_large."
    local str_lst = nx_function("ext_split_string", nx_string(photo_head), ".")
    if table.getn(str_lst) >= 2 then
      local str_temp = str_lst[1]
      form.lhbodynpc.BackImage = str_lst[1] .. str_const .. str_lst[2]
    end
  end
  if not form.Visible then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_task\\form_fuben_task_tips", true)
  end
end
