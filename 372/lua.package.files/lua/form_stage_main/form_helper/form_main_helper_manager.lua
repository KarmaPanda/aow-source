require("share\\view_define")
require("util_functions")
require("util_gui")
local helper_info = "helper_info"
local item_list = {
  "open_form",
  "focus_control",
  "ani_image",
  "next",
  "text",
  "form_ani_image",
  "voice_cond_idx",
  "voice_name"
}
local multi_item = {"voice_cond", "voice_name"}
local EQUIP_TYPE = 1
local TOOL_TYPE = 2
local MATERIAL_TYPE = 3
local TASK_TYPE = 4
local CONFIG_TYPE = 1
local INDEX_TYPE = 2
local type_list = {
  imagegrid_equip = EQUIP_TYPE,
  imagegrid_tool = TOOL_TYPE,
  imagegrid_material = MATERIAL_TYPE,
  imagegrid_task = TASK_TYPE
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local function get_method_arg(ent, method_list)
  local nifo_list = nx_method(ent, method_list)
  log("method_list bagin")
  for _, info in pairs(nifo_list) do
    log("info = " .. nx_string(info))
  end
  log("method_list end")
end
local function get_method(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local method_list = nx_method_list(ent)
  log("method_list bagin")
  for _, method in ipairs(method_list) do
    log("method = " .. method)
  end
  log("method_list end")
end
local function get_custom(ent)
  if not nx_is_valid(ent) then
    log("no \163\186need entity")
    return 1
  end
  local custom_list = nx_custom_list(ent)
  log("custom_list bagin")
  for _, custom in ipairs(custom_list) do
    log("custom = " .. custom)
  end
  log("custom_list end")
end
local get_global_list = function(global_list_name)
  return get_global_arraylist(global_list_name)
end
local function get_new_global_list(global_list_name)
  local global_list = get_global_list(global_list_name)
  global_list:ClearChild()
  return global_list
end
function get_cur_helper()
  local helper_info_list = get_global_list(helper_info)
  if nx_find_custom(helper_info_list, "cur_type") then
    return nx_string(helper_info_list.cur_type)
  end
  return ""
end
function get_cur_stage()
  local helper_info_list = get_global_list(helper_info)
  if nx_find_custom(helper_info_list, "cur_stage") then
    return nx_string(helper_info_list.cur_stage)
  end
  return ""
end
function open_helper_form(helper_type, helper_index, ...)
  local helper_form = nx_value("helper_form")
  local helper_info_list = get_global_list(helper_info)
  if helper_form and nx_find_custom(helper_info_list, "cur_stage") and helper_info_list.cur_stage == helper_index then
    return false
  end
  if helper_index == nil then
    helper_index = "1"
  end
  if helper_index == "1" then
    get_new_global_list(helper_info)
  end
  load_helper_info()
  local node = helper_info_list:GetChild(helper_type)
  if not nx_is_valid(node) then
    return 2
  end
  if helper_index == nil then
    helper_index = "1"
  end
  if helper_index == "1" then
    helper_info_list:RemoveChild("server_info")
    local server_node = helper_info_list:CreateChild("server_info")
    local j = 1
    for i, para in ipairs(arg) do
      nx_set_custom(server_node, nx_string(j), nx_string(para))
      j = j + 1
    end
    local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
    if b_relationship then
      nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
    end
  end
  local node_info = node:GetChild(nx_string(helper_index))
  if not nx_is_valid(node_info) then
    close_helper_form()
    return false
  end
  if is_only_play_voice(node_info) then
    close_helper_form()
  else
    helper_info_list.cur_stage = nx_number(helper_index)
    helper_info_list.cur_type = helper_type
    nx_execute("tips_game", "hide_tip")
    nx_set_value("helper_form", true)
    open_form(node_info)
    set_click_rect(node_info)
  end
  play_voice(node_info, helper_info_list:GetChild("server_info"))
  return true
end
function on_jump_helper(gui)
  local helper_form = nx_value("helper_form")
  if not helper_form then
    return
  end
  local gui = nx_value("gui")
  local btn_jump = gui.Desktop:Find("btn_jump")
  if nx_is_valid(btn_jump) then
    btn_jump.Visible = true
    gui.Desktop:ToFront(btn_jump)
  else
    btn_jump = gui:Create("Button")
    btn_jump.Name = "btn_jump"
    btn_jump.NormalImage = "bfjump_mark"
    btn_jump.FocusImage = "bfjump02_mark"
    btn_jump.PushImage = "bfjump02_mark"
    btn_jump.InSound = "MouseOn1"
    btn_jump.ClickSound = "MouseClick1"
    btn_jump.DrawMode = "Expand"
    btn_jump.AutoSize = true
    gui.Desktop:Add(btn_jump)
    nx_bind_script(btn_jump, nx_current())
    nx_callback(btn_jump, "on_click", "on_btn_jump_click")
  end
  btn_jump.Left = gui.Width * 0.5 - btn_jump.Width * 0.5
  btn_jump.Top = gui.Height * 0.8 - btn_jump.Height * 0.5
end
function on_btn_jump_click(btn)
  close_helper_form()
end
function next_helper_form()
  local helper_form = nx_value("helper_form")
  if helper_form then
    if nx_running(nx_current(), "next_pause") then
      nx_kill(nx_current(), "next_pause")
    end
    nx_execute(nx_current(), "next_pause")
  end
end
function next_pause()
  local time_count = 0
  local helper_form = nx_value("helper_form")
  while time_count < 0.5 and helper_form do
    time_count = time_count + nx_pause(0)
  end
  local info_list = get_global_list(helper_info)
  info_list.cur_stage = info_list.cur_stage + 1
  open_helper_form(info_list.cur_type, nx_string(info_list.cur_stage))
end
function last_helper_form()
  local helper_form = nx_value("helper_form")
  if helper_form then
    local info_list = get_global_list(helper_info)
    info_list.cur_stage = info_list.cur_stage - 1
    open_helper_form(info_list.cur_type, nx_string(info_list.cur_stage))
  end
end
function close_helper_form()
  local form_top = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "top")
  local form_left = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "left")
  local form_right = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "right")
  local form_bottom = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "bottom")
  form_top:Close()
  form_left:Close()
  form_right:Close()
  form_bottom:Close()
  local gui = nx_value("gui")
  local btn = gui.Desktop:Find("btn_helper")
  local animation = gui.Desktop:Find("lbl_helper_animation")
  local lbl_animation = gui.Desktop:Find("lbl_animation")
  local multi_text = gui.Desktop:Find("text_multi_text_box")
  local btn_jump = gui.Desktop:Find("btn_jump")
  local open_animation = gui.Desktop:Find("lbl_open_form_animation")
  local next_btn = gui.Desktop:Find("next_btn")
  local lbl_arrow = gui.Desktop:Find("lbl_arrow")
  if nx_is_valid(btn) then
    btn.Visible = false
  end
  if nx_is_valid(next_btn) then
    next_btn.Visible = false
  end
  if nx_is_valid(animation) then
    animation.Visible = false
  end
  if nx_is_valid(lbl_animation) then
    lbl_animation.Visible = false
  end
  if nx_is_valid(btn_jump) then
    btn_jump.Visible = false
  end
  if nx_is_valid(multi_text) then
    multi_text.Visible = false
    multi_text:Clear()
  end
  if nx_is_valid(open_animation) then
    open_animation.Visible = false
  end
  if nx_is_valid(lbl_arrow) then
    lbl_arrow.Visible = false
  end
  local helper_info_list = get_global_list(helper_info)
  helper_info_list.cur_stage = nx_number(0)
  helper_info_list.cur_type = ""
  nx_set_value("helper_form", false)
end
function set_form_to_front()
  local form_top = nx_value("form_stage_main\\form_helper\\form_main_helpertop")
  local form_left = nx_value("form_stage_main\\form_helper\\form_main_helperleft")
  local form_right = nx_value("form_stage_main\\form_helper\\form_main_helperright")
  local form_bottom = nx_value("form_stage_main\\form_helper\\form_main_helperbottom")
  if not (nx_is_valid(form_top) and nx_is_valid(form_left) and nx_is_valid(form_right)) or not nx_is_valid(form_bottom) then
    return
  end
  local gui = nx_value("gui")
  gui.Desktop:ToFront(form_top)
  gui.Desktop:ToFront(form_left)
  gui.Desktop:ToFront(form_right)
  gui.Desktop:ToFront(form_bottom)
  local animation = gui.Desktop:Find("lbl_helper_animation")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  end
  local animation = gui.Desktop:Find("lbl_animation")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  end
  local next_btn = gui.Desktop:Find("next_btn")
  if nx_is_valid(next_btn) then
    next_btn.Visible = true
    gui.Desktop:ToFront(next_btn)
  end
  local animation = gui.Desktop:Find("lbl_arrow")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  end
  local btn_jump = gui.Desktop:Find("btn_jump")
  if nx_is_valid(btn_jump) then
    gui.Desktop:ToFront(btn_jump)
  end
end
function set_click_rect(node_info)
  local helper_form = nx_value("helper_form")
  local form_top = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "top")
  local form_left = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "left")
  local form_right = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "right")
  local form_bottom = util_get_form("form_stage_main\\form_helper\\form_main_helper", true, true, "bottom")
  form_top.Visible = true
  form_top:Show()
  form_left.Visible = true
  form_left:Show()
  form_right.Visible = true
  form_right:Show()
  form_bottom.Visible = true
  form_bottom:Show()
  local gui = nx_value("gui")
  local x, y, w, h = get_focus_pos(gui, node_info.focus_control)
  if w == 0 and h == 0 then
    x, y, w, h = get_focus_pos_btn("gui\\special\\life-out.png", "gui\\special\\life-on.png", "gui\\special\\life-down.png")
  end
  if x > gui.Width - w then
    x = gui.Width - w
  elseif x < 0 then
    x = 0
  end
  if y > gui.Height - h then
    y = gui.Height - h
  elseif y < 0 then
    y = 0
  end
  set_left_top_pos(gui, form_top, x, y, w, h)
  set_right_top_pos(gui, form_right, x, y, w, h)
  set_left_bottom_pos(gui, form_left, x, y, w, h)
  set_right_bottom_pos(gui, form_bottom, x, y, w, h)
  gui.Desktop:ToFront(form_top)
  gui.Desktop:ToFront(form_left)
  gui.Desktop:ToFront(form_right)
  gui.Desktop:ToFront(form_bottom)
  set_ani_image(gui, node_info, x, y, w, h)
  set_next_info(gui, node_info, x, y, w, h)
  set_text_info(gui, node_info, x, y, w, h)
  set_helper_image(gui, node_info, x, y, w, h)
  set_jump_helper(gui, node_info, x, y, w, h)
  set_helper_arrow(gui, node_info, x, y, w, h)
  return x, y, w, h
end
function set_helper_arrow(gui, node_info, x, y, w, h)
  local animation = gui.Desktop:Find("lbl_arrow")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
    if x / gui.Width > 0.8 then
      animation.BackImage = "jiantouzhishiright"
      animation.Left = x - animation.Width
    else
      animation.BackImage = "jiantouzhishileft"
      animation.Left = x + w
    end
  else
    animation = gui:Create("Label")
    animation.Name = "lbl_arrow"
    if x / gui.Width > 0.8 then
      animation.BackImage = "jiantouzhishiright"
      animation.Left = x - animation.Width
    else
      animation.BackImage = "jiantouzhishileft"
      animation.Left = x + w
    end
    animation.AutoSize = true
    gui.Desktop:Add(animation)
  end
  animation.Top = y + (h - animation.Height) / 2
end
function set_helper_image(gui, node_info, x, y, w, h)
  local animation = gui.Desktop:Find("lbl_animation")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  else
    animation = gui:Create("Label")
    animation.Name = "lbl_animation"
    animation.BackImage = "gui\\special\\freshman\\form.png"
    animation.DrawMode = "Expand"
    gui.Desktop:Add(animation)
  end
  animation.Left = x - 4
  animation.Top = y - 4
  animation.Height = h + 7
  animation.Width = w + 7
end
function set_text_info(gui, node_info, x, y, w, h)
  if "" == node_info.text then
    return
  end
  local multi_text = gui.Desktop:Find("text_multi_text_box")
  if nx_is_valid(multi_text) then
    multi_text.Visible = true
    gui.Desktop:ToFront(multi_text)
  else
    multi_text = gui:Create("MultiTextBox")
    multi_text.Name = "text_multi_text_box"
    multi_text.BackImage = "gui\\special\\freshman\\bg_main.png"
    multi_text.DrawMode = "Expand"
    multi_text.NoFrame = true
    multi_text.Font = "font_sns_event_mid"
    gui.Desktop:Add(multi_text)
    multi_text.ViewRect = "10,10,250,40"
    multi_text.MouseInBarColor = "0,0,0,0"
    multi_text.SelectBarColor = "0,0,0,0"
  end
  local str_lst = util_split_string(node_info.text, ",")
  local offset_x = 0
  local offset_y = 0
  local text = ""
  if nil ~= str_lst[1] then
    text = str_lst[1]
  end
  if nil ~= str_lst[2] then
    offset_x = nx_number(str_lst[2])
  end
  if nil ~= str_lst[3] then
    offset_y = nx_number(str_lst[3])
  end
  local gui_text = gui.TextManager:GetText(text)
  multi_text:Clear()
  multi_text:AddHtmlText(nx_widestr(gui_text), -1)
  autosize_tip_textbox(multi_text, x + w / 2 + offset_x, y + h / 2 + offset_y, 250)
  multi_text.Left = x + w / 2 + offset_x
  multi_text.Top = y + h / 2 + offset_y
end
function autosize_tip_textbox(tip_control, x, y, width)
  local gui = nx_value("gui")
  if width == nil or nx_string(width) == nx_string("") or nx_number(width) <= 0 then
    width = 20 + tip_control:GetContentWidth()
  else
    width = 20 + width
  end
  local height = 20 + tip_control:GetContentHeight()
  local real_width = width
  local real_height = height
  local real_x = x + 32
  local real_y = y + 32
  if real_x + real_width > gui.Width then
    real_x = x - real_width
  end
  if real_y + real_height > gui.Height then
    if y > real_height then
      real_y = y - real_height
    else
      real_y = gui.Height - real_height
    end
  end
  tip_control.AbsLeft = real_x
  tip_control.AbsTop = real_y
  tip_control.Width = width
  tip_control.Height = height
  local right = width - 10
  if right <= 10 then
    right = 11
  end
  tip_control.ViewRect = "10,10," .. nx_string(right) .. "," .. height - 10
end
function set_jump_helper(gui, node_info, x, y, w, h)
  local game_timer = nx_value("timer_game")
  game_timer:UnRegister(nx_current(), "on_jump_helper", gui)
  game_timer:Register(5000, 1, nx_current(), "on_jump_helper", gui, -1, -1)
  local btn_jump = gui.Desktop:Find("btn_jump")
  if nx_is_valid(btn_jump) then
    gui.Desktop:ToFront(btn_jump)
  end
end
function set_ani_image(gui, node_info, x, y, w, h)
  local animation = gui.Desktop:Find("lbl_helper_animation")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  else
    animation = gui:Create("Label")
    animation.Name = "lbl_helper_animation"
    gui.Desktop:Add(animation)
    animation.AutoSize = true
  end
  local str_lst = util_split_string(node_info.ani_image, ",")
  animation.BackImage = str_lst[1]
  local offset_x = 0
  local offset_y = 0
  if nil ~= str_lst[2] then
    offset_x = nx_number(str_lst[2])
  end
  if nil ~= str_lst[3] then
    offset_y = nx_number(str_lst[3])
  end
  animation.Left = nx_int(x + w) + offset_x
  animation.Top = nx_int(y + h) + offset_y
end
function set_next_info(gui, node_info, x, y, w, h)
  local next_btn = gui.Desktop:Find("next_btn")
  if node_info.next == "" then
    if nx_is_valid(next_btn) then
      next_btn.Visible = false
    end
    return 1
  end
  local str_lst = util_split_string(node_info.next, ",")
  if str_lst[1] ~= "true" then
    if nx_is_valid(next_btn) then
      next_btn.Visible = false
    end
    return 1
  end
  local offset_x = 0
  local offset_y = 0
  if table.getn(str_lst) > 2 then
    offset_x = nx_int(str_lst[2])
    offset_y = nx_int(str_lst[3])
  end
  if nx_is_valid(next_btn) then
    next_btn.Visible = true
    gui.Desktop:ToFront(next_btn)
  else
    next_btn = gui:Create("Button")
    next_btn.Name = "next_btn"
    gui.Desktop:Add(next_btn)
    next_btn.AutoSize = true
    next_btn.NormalImage = "gui\\language\\ChineseS\\button\\b-xyy-down.png"
    next_btn.FocusImage = "gui\\language\\ChineseS\\button\\b-xyy-on.png"
    next_btn.PushImage = "gui\\language\\ChineseS\\button\\b-xyy-out.png"
    next_btn.InSound = "MouseOn1"
    next_btn.ClickSound = "MouseClick1"
    gui.Desktop:ToFront(next_btn)
    nx_bind_script(next_btn, nx_current())
    nx_callback(next_btn, "on_click", "on_btn_next_click")
  end
  next_btn.Left = x + w / 2 + offset_x
  next_btn.Top = y + h / 2 + offset_y
end
function set_left_top_pos(gui, form, x, y, w, h)
  set_form_pos(form, 0, 0, x, y + h)
end
function set_left_bottom_pos(gui, form, x, y, w, h)
  set_form_pos(form, 0, y + h, x + w, gui.Height - (y + h))
end
function set_right_top_pos(gui, form, x, y, w, h)
  set_form_pos(form, x, 0, gui.Width - x, y)
end
function set_right_bottom_pos(gui, form, x, y, w, h)
  set_form_pos(form, x + w, y, gui.Width - (x + w), gui.Height - y)
end
function set_form_pos(form, x, y, w, h)
  form.Left = x
  form.Top = y
  form.Width = w
  form.Height = h
end
function on_btn_next_click(self)
  self.Visible = false
  next_helper_form()
end
function load_helper_info()
  local ini_node = nx_create("IniDocument")
  local ini_info = nx_create("IniDocument")
  local helper_info_list = get_global_list(helper_info)
  if helper_info_list:GetChildCount() > 0 then
    return false
  end
  ini_node.FileName = nx_string(nx_resource_path() .. "ini\\new_helper\\player_helper.ini")
  ini_info.FileName = nx_string(nx_resource_path() .. "ini\\new_helper\\helper_info.ini")
  if not ini_node:LoadFromFile() or not ini_info:LoadFromFile() then
    nx_destroy(ini_node)
    nx_destroy(ini_info)
    return false
  end
  local sect_list = ini_node:GetSectionList()
  for i, sect in ipairs(sect_list) do
    local parent_node = helper_info_list:CreateChild(sect)
    local node_list = ini_node:GetItemValueList(sect, "node")
    for j, node in ipairs(node_list) do
      local node_info = parent_node:CreateChild(nx_string(j))
      for k, item in ipairs(item_list) do
        nx_set_custom(node_info, item, ini_info:ReadString(node, item, ""))
      end
      for k, item in ipairs(multi_item) do
        local l = 1
        while true do
          local key = item .. "_" .. nx_string(l)
          if not ini_info:FindItem(node, key) then
            break
          end
          local value = ini_info:ReadString(node, key, "")
          nx_set_custom(node_info, key, value)
          l = l + 1
        end
        nx_set_custom(node_info, item .. nx_string("_count"), l - 1)
      end
    end
  end
  nx_destroy(ini_node)
  nx_destroy(ini_info)
  return true
end
function open_form(node_info)
  local form_str_lst = util_split_string(node_info.open_form, ";")
  local image_str_lst = util_split_string(node_info.form_ani_image, ",")
  local gui = nx_value("gui")
  for i, form_list in ipairs(form_str_lst) do
    local info_list = util_split_string(form_list, ",")
    if table.getn(info_list) > 1 then
      local gui = nx_value("gui")
      local x, y, w, h = get_focus_pos(gui, form_list)
      if "" ~= image_str_lst[i] then
        set_open_form_ani_image(gui, image_str_lst[i], x, y, w, h)
      end
    else
      local form = util_get_form(info_list[1], true, true)
      if not nx_is_valid(form) then
        break
      end
      if nx_is_valid(form) then
        form.Visible = true
        form:Show()
      end
    end
  end
end
function set_open_form_ani_image(gui, form_ani_image, x, y, w, h)
  local animation = gui.Desktop:Find("lbl_open_form_animation")
  if nx_is_valid(animation) then
    animation.Visible = true
    gui.Desktop:ToFront(animation)
  else
    animation = gui:Create("Label")
    animation.Name = "lbl_open_form_animation"
    gui.Desktop:Add(animation)
    animation.AutoSize = true
  end
  local str_lst = util_split_string(form_ani_image, ",")
  animation.BackImage = str_lst[1]
  animation.Width = w
  animation.Height = h
  local offset_x = 0
  local offset_y = 0
  if nil ~= str_lst[2] then
    offset_x = nx_number(str_lst[2])
  end
  if nil ~= str_lst[3] then
    offset_y = nx_number(str_lst[3])
  end
  animation.Left = nx_int(x)
  animation.Top = nx_int(y)
end
function close_form(node_info)
  if not nx_is_valid(node_info) then
    return
  end
  local str_lst = util_split_string(node_info.open_form, ",")
  for i, form_name in ipairs(str_lst) do
    local form = util_get_form(str_lst[1], true, true)
    if not nx_is_valid(form) then
      break
    end
    if nx_is_valid(form) then
      form.Visible = false
      form:Close()
    end
  end
end
function get_focus_pos(gui, focus_control)
  local str_lst = util_split_string(focus_control, ",")
  if table.getn(str_lst) < 2 then
    return 0, 0, 0, 0
  end
  local focus_type = str_lst[1]
  if focus_type == "form" or focus_type == "bag" or focus_type == "grid" or "text" == focus_type or focus_type == "tree" then
    local form = nx_value(str_lst[2])
    if form_not_need_refresh(get_cur_helper(), get_cur_stage()) then
      if not nx_is_valid(form) then
        return 0, 0, 0, 0
      end
      form.is_help = false
      local is_child = gui.Desktop:IsChild(form)
      if is_child and not nx_id_equal(form, gui.Desktop) then
        gui.Desktop:ToFront(form)
      else
        local parent = form.Parent
        if nx_is_valid(parent) and not nx_id_equal(form, gui.Desktop) then
          gui.Desktop:ToFront(parent)
        end
      end
      if nx_string(get_cur_helper()) == nx_string("new_world_pet_helper") and nx_string(get_cur_stage()) == nx_string("4") then
        return get_focus_pos_grid(form, str_lst[2], str_lst[3], str_lst[4], str_lst[5])
      end
      return get_focus_pos_control(form, str_lst[3])
    elseif nx_string(get_cur_helper()) == nx_string("home_helper_sy") and nx_string(get_cur_stage()) == nx_string("8") then
      return get_focus_pos_helper_sy_5(form, str_lst[3], str_lst[4])
    elseif nx_string(get_cur_helper()) == nx_string("home_helper_sy") and nx_string(get_cur_stage()) == nx_string("9") then
      return get_focus_pos_grid(form, str_lst[2], str_lst[3], str_lst[4], str_lst[5])
    elseif nx_string(get_cur_helper()) == nx_string("karma_help_04") and nx_string(get_cur_stage()) == nx_string("3") then
      local cur_scene = nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id")
      local form_prize = nx_value("form_stage_main\\form_relation\\form_world_karma_prize" .. nx_string(cur_scene))
      if not nx_is_valid(form_prize) then
        return 0, 0, 0, 0
      end
      local x = form_prize.btn_prize_1_2.AbsLeft
      local y = form_prize.btn_prize_1_2.AbsTop
      local w = form_prize.btn_prize_1_2.Width
      local h = form_prize.btn_prize_1_2.Height
      return x, y, w, h
    end
    if nx_is_valid(form) then
      local parent = form.Parent
      local is_help = nx_custom(form, "is_help")
      if nx_id_equal(parent, gui.Desktop) then
        form.is_help = true
        if not nx_id_equal(form, gui.Desktop) then
          form:Close()
        end
      end
    end
    if not nx_is_valid(form) then
      form = util_get_form(str_lst[2], true, true)
    end
    if not nx_is_valid(form) then
      return 0, 0, 0, 0
    end
    form.is_help = true
    form.Visible = true
    if nx_string(get_cur_helper()) == nx_string("karma_help_01") and nx_string(get_cur_stage()) == nx_string("2") and not init_present_to_npc_form(form) then
      return 0, 0, 0, 0
    end
    if not nx_id_equal(form, gui.Desktop) then
      form:Show()
    end
    if not nx_is_valid(form) then
      return 0, 0, 0, 0
    end
    form.is_help = false
    local is_child = gui.Desktop:IsChild(form)
    if is_child and not nx_id_equal(form, gui.Desktop) then
      gui.Desktop:ToFront(form)
    else
      local parent = form.Parent
      if nx_is_valid(parent) and not nx_id_equal(form, gui.Desktop) then
        gui.Desktop:ToFront(parent)
      end
    end
    local offset = 0
    if not nx_find_custom(form, str_lst[3]) then
      if nx_find_script(str_lst[2], str_lst[3]) then
        nx_execute(str_lst[2], str_lst[3])
        offset = 1
      else
        return 0, 0, 0, 0
      end
    end
    if focus_type == "form" then
      return get_focus_pos_control(form, str_lst[3 + offset])
    elseif focus_type == "bag" then
      return get_focus_pos_bag(form, str_lst[3 + offset], str_lst[4 + offset])
    elseif focus_type == "grid" then
      return get_focus_pos_grid(form, str_lst[2], str_lst[3 + offset], str_lst[4 + offset], str_lst[5 + offset])
    elseif focus_type == "text" then
      return get_focus_pos_text(form, str_lst[2], str_lst[3 + offset], str_lst[4 + offset])
    elseif focus_type == "tree" then
      return get_focus_pos_tree(form, str_lst[2], str_lst[3 + offset], str_lst[4 + offset])
    end
  elseif focus_type == "btn" then
    return get_focus_pos_btn(str_lst[2], str_lst[3], str_lst[4])
  elseif focus_type == "wuxue" then
    return get_focus_pos_wuxue(str_lst[2], str_lst[3], str_lst[4], str_lst[5])
  elseif focus_type == "wuxue_1" then
    return get_focus_pos_wuxue_1(str_lst[2], str_lst[3], str_lst[4])
  elseif focus_type == "func" then
    local list = {}
    for i = 4, table.getn(str_lst) do
      list[i - 3] = str_lst[i]
    end
    local x, y, w, h = nx_execute(str_lst[2], str_lst[3], unpack(list))
    local gui = nx_value("gui")
    local btn = gui.Desktop:Find("btn_helper")
    if not nx_is_valid(btn) then
      btn = gui:Create("Button")
      btn.Name = "btn_helper"
      btn.InSound = "MouseOn1"
      btn.ClickSound = "MouseClick1"
      gui.Desktop:Add(btn)
      nx_bind_script(btn, nx_current())
      nx_callback(btn, "on_click", "on_btn_next_click")
    else
      btn.Visible = true
      gui.Desktop:ToFront(btn)
    end
    btn.NormalImage = ""
    btn.FocusImage = ""
    btn.PushImage = ""
    btn.AutoSize = true
    btn.Visible = true
    btn.Left = x
    btn.Width = w
    btn.Top = y
    btn.Height = h
    return x, y, w, h
  end
  return 0, 0, 0, 0
end
function get_focus_pos_control(form, control_name)
  local control = nx_custom(form, control_name)
  if not nx_is_valid(control) then
    return 0, 0, 0, 0
  end
  control.is_helper_click = true
  return control.AbsLeft, control.AbsTop, control.Width, control.Height
end
function get_focus_pos_btn(normal_image, focus_image, push_image)
  local gui = nx_value("gui")
  local btn = gui.Desktop:Find("btn_helper")
  if not nx_is_valid(btn) then
    btn = gui:Create("Button")
    btn.Name = "btn_helper"
    btn.InSound = "MouseOn1"
    btn.ClickSound = "MouseClick1"
    gui.Desktop:Add(btn)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_next_click")
  else
    btn.Visible = true
    gui.Desktop:ToFront(btn)
  end
  btn.NormalImage = normal_image
  btn.FocusImage = focus_image
  btn.PushImage = push_image
  btn.AutoSize = false
  btn.Visible = true
  btn.DrawMode = "FitWindow"
  btn.Left = nx_execute("form_stage_main\\form_main\\form_main_request", "get_begin_left")
  btn.Top = nx_execute("form_stage_main\\form_main\\form_main_request", "get_begin_top")
  btn.Width = 60
  btn.Height = 60
  return btn.Left, btn.Top, btn.Width, btn.Height
end
function get_focus_pos_text(form, form_name, multi_text_name, find_text)
  if "" == find_text then
    return 0, 0, 0, 0
  end
  local control = nx_custom(form, multi_text_name)
  if not nx_is_valid(control) then
    return 0, 0, 0, 0
  end
  nx_execute(form_name, "find_text_item", form, control, find_text)
  local res, x, y, w, h = control:GetHyperLinkRect(find_text)
  if res then
    return x, y, w - x + 5, h - y + 5
  end
  return control.AbsLeft, control.AbsTop, control.Width, control.Height
end
function get_focus_pos_tree(form, form_name, tree_name, find_name)
  local tree = nx_custom(form, tree_name)
  if not nx_is_valid(tree) then
    return 0, 0, 0, 0
  end
  local node = nx_execute(form_name, "find_tree_item", tree, find_name)
  if not nx_is_valid(node) then
    return 0, 0, 0, 0
  end
  tree.SelectNode = tree.RootNode
  node.help_node = true
  return tree.AbsLeft, tree.AbsTop + tree:GetNodeTop(node), tree.Width, tree.ItemHeight
end
function get_focus_pos_grid(form, form_name, grid_name, is_empty, config_id)
  local grid = nx_custom(form, grid_name)
  if not nx_is_valid(grid) then
    return 0, 0, 0, 0
  end
  local offset_x = 0
  local offset_y = 0
  if nx_find_property(grid, "GridBackOffsetY") and nx_find_property(grid, "GridBackOffsetX") then
    offset_x = grid.GridBackOffsetX
    offset_y = grid.GridBackOffsetY
  end
  grid.is_helper_click = true
  if nil == is_empty or "" == is_empty or is_empty == "true" then
    local rows = grid.RowNum
    local cols = grid.ClomnNum
    local size = rows * cols - 1
    for i = 0, size do
      if grid:IsEmpty(nx_int(i)) then
        return grid.AbsLeft + grid:GetItemLeft(nx_int(i)), grid.AbsTop + grid:GetItemTop(nx_int(i)), grid.GridWidth, grid.GridHeight
      end
    end
  elseif is_empty == "false" then
    local helper_info_list = get_global_list(helper_info)
    local server_node = helper_info_list:GetChild("server_info")
    if not nx_is_valid(server_node) then
      return 0, 0, 0, 0
    end
    if nil == config_id or "" == config_id then
      config_id = nx_custom(server_node, "1")
    end
    if not nx_is_valid(grid) then
      return 0, 0, 0, 0
    end
    local index = nx_execute(form_name, "find_grid_item", grid, config_id)
    if -1 ~= index then
      local str_lst = util_split_string(grid.ViewRect, ",")
      local x = grid.AbsLeft + grid:GetItemLeft(index) + nx_int(str_lst[1])
      local y = grid.AbsTop + grid:GetItemTop(index) + nx_int(str_lst[2])
      local w = grid.GridWidth
      local h = grid.GridHeight
      return x, y, w, h
    end
  else
    local index = nx_number(is_empty)
    local str_lst = {}
    if nx_find_property(grid, "ViewRect") then
      str_lst = util_split_string(nx_string(grid.ViewRect), ",")
    end
    local x = 0
    local y = 0
    if nx_string(get_cur_helper()) == nx_string("wuji_helper") then
      x = grid:GetItemLeft(index) + grid.AbsLeft + nx_int(str_lst[1])
      y = grid:GetItemTop(index) + grid.AbsTop + nx_int(str_lst[2])
    else
      x = grid:GetItemLeft(index) + grid.AbsLeft + nx_int(str_lst[1]) - offset_x
      y = grid:GetItemTop(index) + grid.AbsTop + nx_int(str_lst[2]) - offset_y
    end
    local w = grid.GridWidth
    local h = grid.GridHeight
    return x, y, w, h
  end
  return 0, 0, 0, 0
end
function get_focus_pos_wuxue(form_type, form_index, type_index, control_name)
  local helper_info_list = get_global_list(helper_info)
  local x, y, w, h = 0, 0, 0, 0
  if control_name == nil then
    local server_node = helper_info_list:GetChild("server_info")
    if not nx_is_valid(server_node) then
      return x, y, w, h
    end
    local config_id = nx_custom(server_node, "1")
    local grid = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "find_type_in_grid", form_type, form_index, type_index, config_id)
    if not nx_is_valid(grid) then
      return x, y, w, h
    end
    return grid.AbsLeft, grid.AbsTop, grid.Width, grid.Height
  else
    nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "open_wuxue_sub_page", form_index)
    local form = nx_value(form_type)
    if nx_is_valid(form) and nx_find_custom(form, control_name) then
      local control = nx_custom(form, control_name)
      return control.AbsLeft, control.AbsTop, control.Width, control.Height
    else
      local config_id = control_name
      if nx_string("normal_anqi_attack") == nx_string(config_id) then
        local fight = nx_value("fight")
        if not nx_is_valid(fight) then
          return 0
        end
        config_id = fight:GetNormalAnqiAttackSkillID(false)
      end
      local grid = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "find_type_in_grid", form_type, form_index, type_index, config_id)
      if not nx_is_valid(grid) then
        return x, y, w, h
      end
      return grid.AbsLeft, grid.AbsTop, grid.Width, grid.Height
    end
  end
  return x, y, w, h
end
function get_focus_pos_wuxue_1(form_path, tree, skill_id)
  local x, y, w, h = 0, 0, 0, 0
  local form = nx_value(form_path)
  if nx_is_valid(form) then
    local root_node = form.tree_types.RootNode
    if not nx_is_valid(root_node) then
      return x, y, w, h
    end
    local sel_node = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "find_node", root_node, skill_id)
    if not nx_is_valid(sel_node) then
      return x, y, w, h
    else
      form.tree_types.SelectNode = sel_node
    end
    x = form.btn_wuji_1.AbsLeft
    y = form.btn_wuji_1.AbsTop
    w = form.btn_wuji_1.Width
    h = form.btn_wuji_1.Height
  else
    local btn_wuji_1 = nx_execute("form_stage_main\\form_wuxue\\form_wuxue_util", "get_wuji_helper_pos", skill_id)
    if not nx_is_valid(btn_wuji_1) then
      return 0, 0, 0, 0
    end
    x = btn_wuji_1.AbsLeft
    y = btn_wuji_1.AbsTop
    w = btn_wuji_1.Width
    h = btn_wuji_1.Height
  end
  return x, y, w, h
end
function get_focus_pos_bag(form, grid_name, config_id)
  local goods_grid = nx_value("GoodsGrid")
  local open_type = nx_number(type_list[grid_name])
  if not nx_is_valid(goods_grid) then
    return 0, 0, 0, 0
  end
  if open_type == EQUIP_TYPE then
    form.rbtn_equip.Checked = false
    form.rbtn_equip.Checked = true
  elseif open_type == TOOL_TYPE then
    form.rbtn_tool.Checked = false
    form.rbtn_tool.Checked = true
  elseif open_type == MATERIAL_TYPE then
    form.rbtn_material.Checked = false
    form.rbtn_material.Checked = true
  elseif open_type == TASK_TYPE then
    form.rbtn_task.Checked = false
    form.rbtn_task.Checked = true
  end
  local helper_info_list = get_global_list(helper_info)
  local grid = nx_custom(form, grid_name)
  if nil == config_id or "" == config_id then
    local server_node = helper_info_list:GetChild("server_info")
    if not nx_is_valid(server_node) then
      return 0, 0, 0, 0
    end
    config_id = nx_custom(server_node, "1")
  end
  if nil == config_id or "" == config_id then
    return 0, 0, 0, 0
  end
  local index = find_grid_item(nx_string(config_id), grid)
  if -1 == index then
    return 0, 0, 0, 0
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local w = grid.GridWidth
  local h = grid.GridHeight
  return x, y, w, h
end
function get_focus_pos_helper_sy_5(form, group_name, control_name)
  local group = nx_custom(form, group_name)
  if not nx_is_valid(group) then
    return 0, 0, 0, 0
  end
  local control = group:Find(control_name)
  if not nx_is_valid(control) then
    return 0, 0, 0, 0
  end
  control.is_helper_click = true
  return control.AbsLeft, control.AbsTop, control.Width, control.Height
end
function find_tool_in_view(view_id, config_id)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(view_id)
  local view_obj_table = view:GetViewObjList()
  for i = 1, table.getn(view_obj_table) do
    local view_obj = view_obj_table[i]
    local find_config = view_obj:QueryProp("ConfigID")
    if find_config == config_id then
      return view_obj.Ident
    end
  end
  return -1
end
function change_form_size()
  local helper_form = nx_value("helper_form")
  if not helper_form then
    return
  end
  local time_count = 0
  local helper_form = nx_value("helper_form")
  while time_count < 0 and helper_form do
    time_count = time_count + nx_pause(0)
  end
  local helper_info_list = get_global_list(helper_info)
  local helper_index = helper_info_list.cur_stage
  local helper_type = helper_info_list.cur_type
  local node = helper_info_list:GetChild(helper_type)
  if not nx_is_valid(node) then
    return
  end
  local node_info = node:GetChild(nx_string(helper_index))
  if not nx_is_valid(node_info) then
    return
  end
  close_form(node:GetChild(nx_string(nx_int(helper_index) - 1)))
  open_form(node_info)
  set_click_rect(node_info)
end
function find_grid_item(config_id, image_grid)
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) or not nx_is_valid(image_grid) then
    return -1
  end
  local rows = image_grid.RowNum
  local cols = image_grid.ClomnNum
  local size = rows * cols - 1
  for i = 0, size do
    local item_data = goods_grid:GetItemData(image_grid, i)
    local config = nx_execute("tips_data", "get_prop_in_item", item_data, "ConfigID")
    if nx_string(config) == nx_string(config_id) then
      return i
    end
  end
  return -1
end
function get_player()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  return client_player
end
function game_shortcut_test()
  local list = {}
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "open_helper_form", nx_string("life_qs_1"), "1", unpack(list))
end
function init_present_to_npc_form(form)
  local npc = nx_value("game_select_obj")
  if not nx_is_valid(npc) then
    return false
  end
  local configid = npc:QueryProp("ConfigID")
  form.npc_id = configid
  form.scene_id = nx_int(nx_execute("form_stage_main\\form_relation\\form_friend_list", "get_scene_id"))
  form.type = 1
  return true
end
function form_not_need_refresh(helper_id, stage)
  if nx_string(helper_id) == nx_string("karma_help_01") and nx_string(stage) == nx_string("3") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("2") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("3") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("4") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("5") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("6") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("7") then
    return true
  end
  if nx_string(helper_id) == nx_string("karma_help_05") and nx_string(stage) == nx_string("8") then
    return true
  end
  if nx_string(helper_id) == nx_string("wuji_helper") and nx_string(stage) == nx_string("4") then
    return true
  end
  if nx_string(helper_id) == nx_string("home_helper_sy") and nx_string(stage) == nx_string("6") then
    return true
  end
  if nx_string(helper_id) == nx_string("home_helper_sy") and nx_string(stage) == nx_string("7") then
    return true
  end
  if nx_string(helper_id) == nx_string("new_world_pet_helper") then
    return true
  end
  if nx_string(helper_id) == nx_string("new_tige_help") then
    return true
  end
  if nx_string(helper_id) == nx_string("lx_ssf_helper_1") and nx_string(stage) == nx_string("4") then
    return true
  end
  if nx_string(helper_id) == nx_string("lx_ssf_helper_2") and nx_string(stage) == nx_string("5") then
    return true
  end
  if nx_string(helper_id) == nx_string("outland_main_help") then
    return true
  end
  if nx_string(helper_id) == nx_string("shijia_main_help") then
    return true
  end
  if nx_string(helper_id) == nx_string("dbomall_main_help") then
    return true
  end
  if nx_string(helper_id) == nx_string("balance_war_1_helper") then
    return true
  end
  if nx_string(helper_id) == nx_string("balance_war_2_helper") then
    return true
  end
  return false
end
function play_voice(node_info, server_info)
  local voice_name = node_info.voice_name
  if 0 ~= node_info.voice_cond_count then
    local voice_cond_idx = "1"
    if "" ~= node_info.voice_cond_idx then
      voice_cond_idx = node_info.voice_cond_idx
    end
    local param = nx_custom(server_info, voice_cond_idx)
    if nil == param then
      return
    end
    local voice_name_idx = 0
    for i = 1, node_info.voice_cond_count do
      local voice_cond = nx_custom(node_info, "voice_cond_" .. nx_string(i))
      if nil == voice_cond then
        return
      end
      if param == voice_cond then
        voice_name_idx = i
        break
      end
    end
    if 0 ~= voice_name_idx then
      voice_name = nx_custom(node_info, "voice_name_" .. nx_string(voice_name_idx))
      if nil == voice_name then
        return
      end
    end
  end
  if "" == voice_name then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(1510) then
    nx_execute("form_stage_main\\form_freshman\\form_freshman_voice", "play_voice", voice_name)
  end
end
function is_only_play_voice(node_info)
  if ("" ~= node_info.voice_name or 0 ~= node_info.voice_cond_count) and "" == node_info.open_form and "" == node_info.ani_image and "" == node_info.next and "" == node_info.text and "" == node_info.form_ani_image then
    return true
  end
  return false
end
