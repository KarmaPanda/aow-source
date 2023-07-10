require("util_functions")
require("define\\move_define")
require("form_stage_main\\form_task\\task_define")
require("form_stage_main\\form_talk_data")
require("custom_sender")
require("util_static_data")
local task_util = "form_stage_main\\form_task\\task_util"
local form_name = "form_stage_main\\form_talk"
local MAX_DISTANCE = 10
local MENU_HEIGHT = 74
function main_form_init(self)
  self.Fixed = false
  self.npcid = ""
  self.func_menu_ids = ""
  self.task_menu_ids = ""
  return 1
end
function main_form_open(form)
  on_size_change()
  start_check_pos(form)
  form.Visible = true
  return 1
end
function on_main_form_close(form)
  stop_check_pos()
  form.Visible = false
  nx_destroy(form)
end
function show_window(npcid, title_id, title, menu)
  local form = nx_execute("util_gui", "util_get_form", form_name, true)
  if not nx_is_valid(form) then
    return
  end
  clear_data(form)
  init_controls(form)
  form.npcid = nx_string(npcid)
  add_title(title)
  add_menu(menu)
  update_menu_control(form)
  form:Show()
  local npc_name = get_npcname_by_id(npcid)
  set_npc_name(form, npc_name)
end
function clear_data(form)
  if not nx_is_valid(form) then
    return
  end
  form.npcid = ""
  form.func_menu_ids = ""
  form.task_menu_ids = ""
end
function init_controls(form)
end
function start_check_pos(form)
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
  nx_execute(nx_current(), "form_talk_tick", form)
end
function stop_check_pos()
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
end
function form_talk_tick(form)
  if not nx_is_valid(form) then
    return
  end
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
  if not nx_is_valid(visual_npc) then
    return
  end
  while true do
    local sec = nx_pause(0.5)
    if not nx_is_valid(form) then
      break
    end
    if not nx_is_valid(visual_npc) then
      if nx_is_valid(form) then
        form:Close()
      end
      break
    end
    local dest_x = visual_player.PositionX
    local dest_z = visual_player.PositionZ
    local sx = dest_x - visual_npc.PositionX
    local sz = dest_z - visual_npc.PositionZ
    local distance = math.sqrt(sx * sx + sz * sz)
    if tonumber(distance) > tonumber(MAX_DISTANCE) then
      if nx_is_valid(form) then
        form:Close()
      end
      break
    end
  end
end
function on_size_change()
  local form_talk = nx_value(form_name)
  if not nx_is_valid(form_talk) then
    return
  end
  local gui = nx_value("gui")
  form_talk.AbsLeft = (gui.Width - form_talk.Width) / 2
  form_talk.AbsTop = (gui.Height - form_talk.Height) / 1.5
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_menu_func_select(menu_list, index)
  select_menu(menu_list, index)
end
function on_menu_task_select(menu_list, index)
  select_menu(menu_list, index)
end
function select_menu(menu, index)
  local form = menu.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local funcid = menu:GetItemKeyByIndex(index)
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return 0
  end
  local ident = form.npcid
  sock.Sender:Select(ident, nx_int(funcid))
  return
end
function add_title(text_title)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.groupscrollbox_title.IsEditMode = true
  form.talk_list:Clear()
  form.talk_list.HtmlText = nx_widestr(text_title)
  form.talk_list.Height = form.talk_list:GetContentHeight()
  form.groupscrollbox_title:ResetChildrenYPos()
  form.groupscrollbox_title.IsEditMode = false
end
function add_menu(menu)
  local form_talk = nx_value(form_name)
  if not nx_is_valid(form_talk) then
    return
  end
  local menu_table = util_split_wstring(menu, nx_widestr("|"))
  for i = 1, table.getn(menu_table) do
    local menu_sub_table = util_split_wstring(nx_widestr(menu_table[i]), nx_widestr("`"))
    if table.getn(menu_sub_table) == 2 then
      local func_id = nx_int(menu_sub_table[1])
      local desc_id = menu_sub_table[2]
      if nx_number(func_id) == nx_number(g_menu_id.leave) or nx_number(func_id) == nx_number(2) then
        task_menu_sort(desc_id, func_id)
      else
        func_menu_sort(desc_id, func_id)
      end
    end
  end
end
function end_menu(npcid)
end
function task_menu_sort(descid, funcid)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.task_menu_ids = add_menu_to_group(form.task_menu_ids, descid, funcid)
end
function func_menu_sort(descid, funcid)
  local form = nx_value(form_name)
  if not nx_is_valid(form) then
    return
  end
  form.func_menu_ids = add_menu_to_group(form.func_menu_ids, descid, funcid)
end
function add_menu_to_group(text_group, descid, funcid)
  local text_temp = nx_widestr("")
  if nx_widestr(text_group) == nx_widestr("") then
    text_temp = nx_widestr(descid) .. nx_widestr("`") .. nx_widestr(funcid)
  else
    text_temp = text_group
    text_temp = nx_widestr(text_temp) .. nx_widestr("|") .. nx_widestr(descid) .. nx_widestr("`") .. nx_widestr(funcid)
  end
  return text_temp
end
function update_menu_control(form)
  local gui = nx_value("gui")
  init_menu_control(form)
  local text_task_menu = nx_widestr(form.task_menu_ids)
  local task_menu_num = -1
  if text_task_menu ~= nx_widestr("") then
    local table_menu_task = nx_function("ext_split_wstring", text_task_menu, nx_widestr("|"))
    for i = 1, table.getn(table_menu_task) do
      local table_menu_para = nx_function("ext_split_wstring", nx_widestr(table_menu_task[i]), nx_widestr("`"))
      if table.getn(table_menu_para) == 2 then
        local desc_id = nx_widestr(table_menu_para[1])
        local func_id = nx_int(table_menu_para[2])
        local photo = get_photo_form_funcid(func_id)
        local text_menu = nx_widestr(photo) .. nx_widestr(desc_id)
        task_menu_num = form.mltbox_menu_task:AddHtmlText(nx_widestr(text_menu), func_id)
      end
    end
  end
  local text_func_menu = nx_widestr(form.func_menu_ids)
  local func_menu_num = -1
  if text_func_menu ~= nx_widestr("") then
    local table_menu_func = nx_function("ext_split_wstring", nx_widestr(text_func_menu), nx_widestr("|"))
    for i = 1, table.getn(table_menu_func) do
      local table_menu_para = nx_function("ext_split_wstring", nx_widestr(table_menu_func[i]), nx_widestr("`"))
      if table.getn(table_menu_para) == 2 then
        local desc_id = table_menu_para[1]
        local func_id = nx_int(table_menu_para[2])
        local photo = get_photo_form_funcid(func_id)
        if gui.TextManager:IsIDName(nx_string(table_menu_para[1])) then
          desc_id = gui.TextManager:GetText(nx_string(table_menu_para[1]))
        end
        local text_menu = nx_widestr(photo) .. desc_id
        func_menu_num = form.mltbox_menu_func:AddHtmlText(nx_widestr(text_menu), func_id)
      end
    end
  end
  fresh_menu_control(form)
  return true
end
function init_menu_control(form)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_menu_func:Clear()
  form.mltbox_menu_task:Clear()
  local menu_width = form.groupbox_h.Width
  local menu_height = form.groupbox_h.Height
  form.mltbox_menu_func.Left = 0
  form.mltbox_menu_func.Top = 0
  form.mltbox_menu_func.Width = menu_width / 2
  form.mltbox_menu_func.Height = menu_height
  form.mltbox_menu_task.Left = menu_width / 2
  form.mltbox_menu_task.Top = 0
  form.mltbox_menu_task.Width = menu_width / 2
  form.mltbox_menu_task.Height = menu_height
end
function fresh_menu_control(form)
  if not nx_is_valid(form) then
    return
  end
  local menu_task = form.mltbox_menu_task
  local menu_func = form.mltbox_menu_func
  menu_task.Visible = false
  menu_func.Visible = false
  local task_item_num = menu_task.ItemCount
  local func_item_num = menu_func.ItemCount
  if task_item_num <= 0 and func_item_num <= 0 then
    return
  end
  form.gsb_menu.IsEditMode = true
  local menu_max_width = form.groupbox_h.Width
  local func_menu_height = 0
  local task_menu_height = 0
  if 0 < func_item_num then
    menu_func.Visible = true
    local menu_left = 0
    local menu_width = menu_max_width / 2
    func_menu_height = menu_func:GetContentHeight()
    if task_item_num <= 0 then
      menu_width = menu_max_width
    end
    menu_func.Left = menu_left
    menu_func.Width = menu_width
    menu_func.Height = func_menu_height
    menu_func.ViewRect = "0,0," .. nx_string(menu_width) .. "," .. nx_string(func_menu_height)
  end
  if 0 < task_item_num then
    menu_task.Visible = true
    local menu_left = menu_max_width / 2
    local menu_width = menu_max_width / 2
    task_menu_height = menu_task:GetContentHeight()
    if func_item_num <= 0 then
      menu_left = 0
      menu_width = menu_max_width
    end
    menu_task.Left = menu_left
    menu_task.Width = menu_width
    menu_task.Height = task_menu_height
    menu_task.ViewRect = "0,0," .. nx_string(menu_width) .. "," .. nx_string(task_menu_height)
  end
  if func_menu_height > task_menu_height then
    form.groupbox_h.Height = func_menu_height
  else
    form.groupbox_h.Height = task_menu_height
  end
  form.gsb_menu:ResetChildrenYPos()
  form.gsb_menu.IsEditMode = false
end
function get_photo_form_funcid(funcid)
  local form_talk = nx_value(form_name)
  if not nx_is_valid(form_talk) then
    return ""
  end
  local menu_shop_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_7.png\" data=\"\" />"
  local menu_job_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_8.png\" data=\"\" />"
  local menu_school_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_9.png\" data=\"\" />"
  local menu_daytask_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_14.png\" data=\"\" />"
  local menu_qiecuo_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_5.png\" data=\"\" />"
  local menu_leave_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_11.png\" data=\"\" />"
  local menu_return_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_16.png\" data=\"\" />"
  local menu_lead_step_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_15.png\" data=\"\" />"
  local menu_task_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_11.png\" data=\"\" />"
  local menu_task_complete_photo = "<img src=\"gui\\special\\task\\leixing\\leixing14.png\" data=\"\" />"
  local menu_task_not_complete_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_11.png\" data=\"\" />"
  local menu_task_accept_photo = "<img src=\"gui\\special\\task\\leixing\\leixing15.png\" data=\"\" />"
  local menu_story_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_1.png\" data=\"\" />"
  local menu_aunser_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_1.png\" data=\"\" />"
  local menu_other_photo = "<img src=\"gui\\special\\task\\leixing\\leixing_2.png\" data=\"\" />"
  local flag = nx_int(funcid / g_menu_id.base)
  if flag >= nx_int(g_menu_id.task_accept) then
    if flag >= nx_int(g_menu_id.task_submit) and flag < nx_int(g_menu_id.task_submit + 100) then
      return menu_task_complete_photo
    elseif flag == nx_int(g_menu_id.task_uncomplete) then
      return menu_task_not_complete_photo
    elseif flag >= nx_int(g_menu_id.task_accept) and flag < nx_int(g_menu_id.task_accept + 100) then
      return menu_task_accept_photo
    end
    if flag == nx_int(g_menu_id.task_accept) then
      return menu_lead_step_photo
    end
    return menu_task_photo
  else
    if funcid == nx_int(g_menu_id.leave) then
      return menu_leave_photo
    elseif flag == nx_int(g_menu_id.func_shop) then
      return menu_shop_photo
    elseif funcid == 2 then
      return menu_return_photo
    end
    return menu_other_photo
  end
end
function get_npcname_by_id(npcid)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_scene_obj = game_client:GetSceneObj(nx_string(npcid))
  local npc_name = ""
  if nx_is_valid(client_scene_obj) then
    local string_id = client_scene_obj:QueryProp("ConfigID")
    local b_has_IDCard = false
    if client_scene_obj:FindProp("IDCard") then
      b_has_IDCard = true
    else
      b_has_IDCard = false
    end
    if b_has_IDCard then
      local info_str = client_scene_obj:QueryProp("IDCard")
      local info_lst = util_split_string(info_str, ",")
      local fname = info_lst[1]
      local sname = info_lst[2]
      if fname == "null" and sname == "null" then
        npc_name = gui.TextManager:GetText(nx_string(string_id))
      else
        local all_show_name = nx_widestr(gui.TextManager:GetText(nx_string(fname))) .. nx_string(gui.TextManager:GetText(nx_string(sname)))
        npc_name = nx_widestr(all_show_name)
      end
    else
      npc_name = gui.TextManager:GetText(nx_string(string_id))
    end
  end
  return npc_name
end
function set_npc_name(form, name)
  if not nx_is_valid(form) then
    return
  end
  form.name_label.Text = nx_widestr(name)
  return 1
end
function show_accept_form(...)
end
function show_submit_form(...)
end
