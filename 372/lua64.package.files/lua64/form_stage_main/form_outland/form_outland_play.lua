require("util_gui")
require("util_functions")
require("custom_handler")
require("custom_sender")
local FORM_NAME = "form_stage_main\\form_outland\\form_outland_play"
local FILE_INI_ACHIEVEMENT = "ini\\form_outland\\play_achievement.ini"
local FILE_INI_PLAY = "ini\\form_outland\\play.ini"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local outland_play_achievement = get_ini(FILE_INI_ACHIEVEMENT, true)
  if not nx_is_valid(outland_play_achievement) then
    return
  end
  local outland_play = get_ini(FILE_INI_PLAY, true)
  if not nx_is_valid(outland_play) then
    return
  end
  form.play_achievement_ini = outland_play_achievement
  form.play_ini = outland_play
  form.current_page = 1
  form.btn_num = 0
  form.current_step = 1
  local week = get_week()
  if 1 <= week and week <= 3 then
    show_info(1)
  elseif 4 <= week and week <= 5 then
    show_info(2)
  elseif week == 6 or week == 0 then
    show_info(3)
  end
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
end
function open_form()
  local form = nx_execute("util_gui", "util_get_form", FORM_NAME, true, false)
  if not nx_is_valid(form) then
    return
  end
  form:Show()
end
function show_info(step)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_achievement.Visible = false
  form.mltbox_desc.Visible = true
  if not nx_find_custom(form, "current_page") then
    return
  end
  local page = form.current_page
  create_controls(step, page)
  show_highlight()
  is_show_page_btns()
  if step == 4 then
    form.mltbox_achievement.Visible = true
    form.mltbox_desc.Visible = false
    return
  end
  if not nx_find_custom(form, "play_ini") then
    return
  end
  local play_ini = form.play_ini
  if not nx_is_valid(play_ini) then
    return
  end
  local stage = ""
  local desc_index = -1
  local sec_count = play_ini:GetSectionCount()
  for i = 0, sec_count do
    stage = play_ini:GetSectionItemValue(i, "stage")
    if stage == nx_string(step) then
      desc_index = i
      break
    end
  end
  if desc_index == -1 then
    return
  end
  form.mltbox_desc.HtmlText = util_text(play_ini:ReadString(desc_index, "DescText", ""))
end
function create_controls(step, page)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.groupbox_btns:DeleteAll()
  local groupbox = gui:Create("GroupBox")
  if not nx_is_valid(groupbox) then
    return
  end
  groupbox.Left = 0
  groupbox.Top = 0
  groupbox.Width = 854
  groupbox.Height = 214
  groupbox.BackColor = "0,255,255,255"
  groupbox.LineColor = "0,0,0,0"
  local btn_list = {}
  local lbl_list = {}
  for i = 1, 5 do
    local btn = gui:Create("Button")
    if not nx_is_valid(btn) then
      return
    end
    btn.Left = 8 + 145 * (i - 1)
    btn.Top = 0
    btn.Width = 138
    btn.Height = 175
    btn.NormalImage = "gui\\special\\outland\\btn_1_out.png"
    btn.FocusImage = "gui\\special\\outland\\btn_1_on.png"
    btn.PushImage = "gui\\special\\outland\\btn_1_down.png"
    local lbl = gui:Create("Label")
    if not nx_is_valid(lbl) then
      return
    end
    lbl.Left = 38 + 145 * (i - 1)
    lbl.Top = 30
    lbl.Width = 80
    lbl.Height = 16
    lbl.Align = "Center"
    lbl.Font = "font_title"
    lbl.ForeColor = "255,255,255,255"
    lbl.TextOffsetX = 5
    lbl.TextOffsetY = 5
    groupbox:Add(btn)
    groupbox:Add(lbl)
    table.insert(btn_list, btn)
    table.insert(lbl_list, lbl)
  end
  if not nx_find_custom(form, "play_ini") then
    return
  end
  local play_ini = form.play_ini
  if not nx_is_valid(play_ini) then
    return
  end
  local count = play_ini:GetSectionCount()
  local content_list = {}
  for i = 1, count do
    local stage = play_ini:ReadInteger(i - 1, "stage", 0)
    if nx_int(stage) == nx_int(step) then
      local section_name = play_ini:GetSectionByIndex(i - 1)
      table.insert(content_list, section_name)
    end
  end
  local num = table.getn(content_list)
  if nx_find_custom(form, "btn_num") then
    form.btn_num = num
  end
  if num <= 5 then
    for i = 1, num do
      local name = content_list[i]
      local btn = btn_list[i]
      local lbl = lbl_list[i]
      local index = play_ini:FindSectionIndex(name)
      local text = play_ini:ReadString(index, "text", "")
      local target_form = play_ini:ReadString(index, "target_form", "")
      local location = play_ini:ReadInteger(index, "location", 1)
      lbl.Text = gui.TextManager:GetText(text)
      btn.target_form = target_form
      btn.location = location
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "show_stage_detail")
    end
    for index = num + 1, 5 do
      local lbl = lbl_list[index]
      local text = "ui_outland_play_desc_1_11"
      if nx_is_valid(lbl) then
        lbl.Text = gui.TextManager:GetText(text)
      end
    end
  else
    local start_index = 1
    local end_index = 1
    if num >= page + 4 then
      start_index = page
      end_index = page + 4
    else
      start_index = num - 4
      end_index = num
    end
    local btn_index = 1
    for i = start_index, end_index do
      local name = content_list[i]
      local btn = btn_list[btn_index]
      local lbl = lbl_list[btn_index]
      local index = play_ini:FindSectionIndex(name)
      local text = play_ini:ReadString(index, "text", "")
      local target_form = play_ini:ReadString(index, "target_form", "")
      local location = play_ini:ReadInteger(index, "location", 1)
      lbl.Text = gui.TextManager:GetText(text)
      btn.target_form = target_form
      btn.location = location
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "show_stage_detail")
      btn_index = btn_index + 1
    end
  end
  form.groupbox_btns:Add(groupbox)
  form.groupbox_step_end.Visible = false
  form.groupbox_btns.Visible = true
end
function show_stage_detail(btn)
  if not nx_find_custom(btn, "target_form") then
    return
  end
  if not nx_find_custom(btn, "location") then
    return
  end
  local name = btn.target_form
  local index = btn.location
  if "single" == name then
    nx_execute("form_stage_main\\form_outland\\form_outland_play_single", "open_form", index)
  elseif "multiple" == name then
    nx_execute("form_stage_main\\form_outland\\form_outland_play_multiple", "open_form", index)
  elseif "story" == name then
    nx_execute("form_stage_main\\form_outland\\form_outland_play_story", "open_form", index)
  end
end
function show_highlight()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local week = get_week()
  if 1 <= week and week <= 3 then
    form.btn_step_1.NormalImage = "gui\\special\\outland\\btn_play_1_on.png"
  elseif 4 <= week and week <= 5 then
    form.btn_step_2.NormalImage = "gui\\special\\outland\\btn_play_2_on.png"
  elseif week == 6 or week == 0 then
    form.btn_step_3.NormalImage = "gui\\special\\outland\\btn_play_3_on.png"
  end
end
function is_show_page_btns()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "btn_num") then
    return
  end
  if form.btn_num <= 5 then
    form.btn_page_up.Visible = false
    form.btn_page_down.Visible = false
  else
    form.btn_page_up.Visible = true
    form.btn_page_down.Visible = true
  end
end
function get_week()
  local mgr = nx_value("InteractManager")
  if not nx_is_valid(mgr) then
    return -1
  end
  local week = mgr:GetWeek()
  return week
end
function on_btn_step_1_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "current_step") then
    form.current_step = 1
  end
  show_info(1)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_step_2_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "current_step") then
    form.current_step = 2
  end
  show_info(2)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_step_3_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "current_step") then
    form.current_step = 3
  end
  show_info(3)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_step_end_click(btn)
  show_info(4)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_btns.Visible = false
  form.groupbox_step_end.Visible = true
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_OUTLAND), 2, 2)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_btn_achievement_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local achievement_form = util_get_form("form_stage_main\\form_outland\\form_outland_play_achievement", true)
  if not nx_is_valid(achievement_form) then
    return
  end
  local grpbox = form.groupbox_subform
  if not nx_is_valid(grpbox) then
    return
  end
  form.groupbox_main.Visible = false
  achievement_form.Visible = true
  grpbox:DeleteAll()
  grpbox:Add(achievement_form)
end
function on_server_msg(...)
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local argnum = table.getn(arg)
  if nx_number(argnum) < nx_number(1) then
    return
  end
  local select_id = arg[1]
  if select_id == nil or select_id < 0 then
    return
  end
  if not nx_find_custom(form, "play_achievement_ini") then
    return
  end
  local play_achievement_ini = form.play_achievement_ini
  if not nx_is_valid(play_achievement_ini) then
    return
  end
  local sec_index = play_achievement_ini:FindSectionIndex(nx_string(select_id))
  if nx_int(sec_index) < nx_int(0) then
    return
  end
  local name = play_achievement_ini:ReadString(sec_index, "Name", "")
  form.mltbox_achi_desc.HtmlText = util_text(name)
end
function on_btn_page_up_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "current_page") then
    return
  end
  form.current_page = form.current_page - 1
  if form.current_page <= 1 then
    form.current_page = 1
  end
  if nx_find_custom(form, "current_step") then
    show_info(form.current_step)
  end
end
function on_btn_page_down_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "current_page") then
    return
  end
  if not nx_find_custom(form, "btn_num") then
    return
  end
  form.current_page = form.current_page + 1
  if form.current_page >= form.btn_num - 4 then
    form.current_page = form.btn_num - 4
  end
  if nx_find_custom(form, "current_step") then
    show_info(form.current_step)
  end
end
