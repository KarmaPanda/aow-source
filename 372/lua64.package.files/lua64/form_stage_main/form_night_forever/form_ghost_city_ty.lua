require("util_static_data")
require("util_functions")
require("util_gui")
local FORM_PATH = "form_stage_main\\form_night_forever\\form_ghost_city_ty"
local FP_ANI_1 = "guishi_tuiyan_open"
local FP_ANI_2 = "guishi_tuiyan_close"
local FP_ANI_3 = "guishi_tuiyan_xiaoshi"
local CLIENT_SUB_GHOST_CITY_BEGIN_TY = 1
local CLIENT_SUB_GHOST_CITY_SEND_FP_RESULT = 2
local CLIENT_SUB_GHOST_CITY_UNLOCK_FORM = 3
local CLIENT_SUB_GHOST_CITY_GET_DAY_VALUE = 4
local CLIENT_SUB_GHOST_CITY_ACCEPT_TASK = 5
local SERVER_SUB_GHOST_CITY_BEGIN_TY = 1
local SERVER_SUB_GHOST_CITY_SUCCEED = 2
local SERVER_SUB_GHOST_CITY_FAILED = 3
local SERVER_SUB_GHOST_CITY_DATA = 5
local g_item_backimage = {
  [1] = "gui\\special\\guishi\\ty_card01.png",
  [2] = "gui\\special\\guishi\\ty_card02.png",
  [3] = "gui\\special\\guishi\\ty_card03.png",
  [4] = "gui\\special\\guishi\\ty_card04.png",
  [5] = "gui\\special\\guishi\\ty_card05.png",
  [6] = "gui\\special\\guishi\\ty_card06.png",
  [7] = "gui\\special\\guishi\\ty_card07.png",
  [8] = "gui\\special\\guishi\\ty_card08.png",
  [9] = "gui\\special\\guishi\\ty_card09.png"
}
local fp_normal = "gui\\special\\guishi\\ty_card_dh08.png"
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  init_form(form)
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "refresh_surtime", form)
    timer:UnRegister(nx_current(), "defer_send_msg", form)
  end
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if is_finish(form) then
    form:Close()
  else
    local gui = nx_value("gui")
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = gui.TextManager:GetText("ui_guishi_tuiyan_btn04")
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
    dialog:ShowModal()
    dialog.Left = (gui.Width - dialog.Width) / 2
    dialog.Top = (gui.Height - dialog.Height) / 2
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      form:Close()
      return true
    end
  end
end
function init_form(form)
  form.sur_time = 0
  form.begin_index = 0
  form.end_index = 0
  form.is_pfing = 0
  form.fp_count = 0
  form.init_str = ""
  form.cur_str = ""
  form.lbl_finish.Visible = false
  form.lbl_failed.Visible = false
  local frame = form.frame
  frame:DeleteAll()
  frame.IsEditMode = true
  local str_list = util_split_string("1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9", ",")
  for i = 1, table.getn(str_list) do
    local cur_num = nx_int(str_list[i])
    local item_box = clone_control(form, "itembox", nx_string(i))
    frame:Add(item_box)
    local diff_y = nx_int((i - 1) / 6)
    local diff_x = nx_int((i - 1) % 6)
    item_box.Left = diff_x * item_box.Width + 10
    item_box.Top = diff_y * item_box.Height + 10
  end
  frame.IsEditMode = false
end
function refresh_surtime(form)
  form.sur_time = form.sur_time - 1
  form.lbl_timer.Text = nx_widestr(form.sur_time)
  if nx_int(form.sur_time) <= nx_int(0) then
    if is_finish(form) == false then
      form.lbl_failed.Visible = true
    end
    local frame = form.frame
    frame.IsEditMode = true
    local str_list = util_split_string(form.cur_str, ",")
    for i = 1, table.getn(str_list) do
      local cur_num = nx_int(str_list[i])
      local child_name = string.format("%s_%s", nx_string("itembox"), nx_string(i))
      local item_box = frame:Find(child_name)
      child_name = string.format("%s_%s", nx_string("btn_item"), nx_string(i))
      local btn_item_control = item_box:Find(child_name)
      btn_item_control.Enabled = false
    end
    frame.IsEditMode = false
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "refresh_surtime", form)
    end
  end
end
function clone_control(form, control_name, aid)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local control = nx_custom(form, nx_string(control_name))
  local new_control = gui.Designer:Clone(control)
  if not nx_is_valid(new_control) then
    return nx_null()
  end
  nx_bind_script(new_control, nx_current())
  new_control.DesignMode = false
  new_control.Name = string.format("%s_%s", nx_string(control_name), nx_string(aid))
  new_control.Visible = true
  new_control.aid = aid
  local child_list = control:GetChildControlList()
  for _, child_control in pairs(child_list) do
    if nx_is_valid(child_control) then
      local new_child = gui.Designer:Clone(child_control)
      new_child.fatherctl = new_control
      new_child.DesignMode = false
      new_child.Name = string.format("%s_%s", nx_string(child_control.Name), nx_string(aid))
      new_child.aid = aid
      new_control:Add(new_child)
    end
  end
  return new_control
end
function on_server_msg(sub_msg, ...)
  if nx_int(sub_msg) == nx_int(SERVER_SUB_GHOST_CITY_BEGIN_TY) then
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    form.sur_time = nx_int(arg[1])
    form.init_str = nx_string(arg[2])
    form.cur_str = nx_string(arg[2])
    form.lbl_timer.Visible = true
    begin_ty(form)
  elseif nx_int(sub_msg) == nx_int(SERVER_SUB_GHOST_CITY_SUCCEED) then
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    form.cur_str = nx_string(arg[1])
    refresh_form(form)
    form.begin_index = 0
    form.end_index = 0
    form.is_pfing = 0
    form.fp_count = 0
    if is_finish(form) then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(nx_current(), "refresh_surtime", form)
      end
      form.lbl_timer.Visible = false
    end
  elseif nx_int(sub_msg) == nx_int(SERVER_SUB_GHOST_CITY_FAILED) then
    local form = nx_value(FORM_PATH)
    if not nx_is_valid(form) then
      return
    end
    form.cur_str = nx_string(arg[1])
    refresh_form(form)
  elseif nx_int(sub_msg) == nx_int(SERVER_SUB_GHOST_CITY_DATA) then
    local form = nx_value("form_stage_main\\form_night_forever\\form_ghost_city")
    if not nx_is_valid(form) then
      return
    end
    form.max_value = nx_int(arg[1])
    form.reward = nx_string(arg[2])
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    form.imagegrid_reward:Clear()
    local photo = ItemQuery:GetItemPropByConfigID(form.reward, "Photo")
    form.imagegrid_reward:AddItem(0, photo, nx_widestr(form.reward), 1, 0)
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    form.pbar_1.Maximum = form.max_value
    form.pbar_1.Minimum = 0
    form.pbar_1.Value = client_player:QueryProp("GhostCityTYValue")
    form.lbl_ty_value.Text = nx_widestr(nx_string(form.pbar_1.Value) .. "/" .. nx_string(form.pbar_1.Maximum))
  end
end
function is_finish(form)
  local index = 0
  local str_list = util_split_string(form.cur_str, ",")
  for i = 1, table.getn(str_list) do
    local cur_num = nx_int(str_list[i])
    if cur_num ~= nx_int(0) then
      index = index + 1
    end
  end
  if index == 0 then
    return true
  end
  return false
end
function refresh_form(form)
  local frame = form.frame
  frame.IsEditMode = true
  local str_list = util_split_string(form.cur_str, ",")
  for i = 1, table.getn(str_list) do
    local cur_num = nx_int(str_list[i])
    local child_name = string.format("%s_%s", nx_string("itembox"), nx_string(i))
    local item_box = frame:Find(child_name)
    child_name = string.format("%s_%s", nx_string("btn_item"), nx_string(i))
    local btn_item_control = item_box:Find(child_name)
    child_name = string.format("%s_%s", nx_string("ani_item"), nx_string(i))
    local ani_item_control = item_box:Find(child_name)
    if cur_num == nx_int(0) then
      if nx_number(form.begin_index) == nx_number(i) or nx_number(form.end_index) == nx_number(i) then
        btn_item_control.Visible = false
        ani_item_control.AnimationImage = FP_ANI_3
        ani_item_control.Loop = false
        ani_item_control.PlayMode = 2
        ani_item_control.Visible = true
        ani_item_control:Play()
      end
    elseif nx_number(form.begin_index) == nx_number(i) or nx_number(form.end_index) == nx_number(i) then
      btn_item_control.Visible = false
      ani_item_control.AnimationImage = FP_ANI_2
      ani_item_control.Loop = false
      ani_item_control.PlayMode = 2
      ani_item_control.Visible = true
      ani_item_control:Play()
    end
  end
  frame.IsEditMode = false
  if is_finish(form) then
    form.lbl_finish.Visible = true
  end
end
function begin_ty(form)
  form.lbl_finish.Visible = false
  form.lbl_failed.Visible = false
  local frame = form.frame
  frame:DeleteAll()
  frame.IsEditMode = true
  local str_list = util_split_string(form.init_str, ",")
  for i = 1, table.getn(str_list) do
    local cur_num = nx_int(str_list[i])
    local item_box = clone_control(form, "itembox", nx_string(i))
    frame:Add(item_box)
    local diff_y = nx_int((i - 1) / 6)
    local diff_x = nx_int((i - 1) % 6)
    item_box.Left = diff_x * item_box.Width + 10
    item_box.Top = diff_y * item_box.Height + 10
    local child_name = string.format("%s_%s", nx_string("btn_item"), nx_string(i))
    local btn_item_control = item_box:Find(child_name)
    btn_item_control.random_num = cur_num
    btn_item_control.is_fp = 0
    btn_item_control.index = i
    nx_bind_script(btn_item_control, nx_current())
    nx_callback(btn_item_control, "on_click", "on_btn_item_click")
    local child_name = string.format("%s_%s", nx_string("ani_item"), nx_string(i))
    local ani_item_control = item_box:Find(child_name)
    ani_item_control.index = i
    nx_bind_script(ani_item_control, nx_current())
    nx_callback(ani_item_control, "on_animation_end", "on_ani_item_animation_end")
  end
  frame.IsEditMode = false
  local timer = nx_value("timer_game")
  timer:Register(1000, -1, nx_current(), "refresh_surtime", form, -1, -1)
end
function on_btn_item_click(btn)
  if btn.is_fp == 1 then
    return
  end
  local form = btn.ParentForm
  if form.is_pfing == 1 then
    return
  end
  if nx_int(form.sur_time) <= nx_int(0) then
    return
  end
  if form.fp_count >= 2 then
    return
  end
  form.is_pfing = 1
  btn.Visible = false
  local item_box = btn.Parent
  if not nx_is_valid(item_box) then
    return
  end
  local child_name = string.format("%s_%s", nx_string("ani_item"), nx_string(btn.index))
  local ani_item_control = item_box:Find(child_name)
  if not nx_is_valid(ani_item_control) then
    return
  end
  form.fp_count = form.fp_count + 1
  if form.fp_count == 1 then
    form.begin_index = btn.index
  else
    form.end_index = btn.index
  end
  ani_item_control.AnimationImage = FP_ANI_1
  ani_item_control.Loop = false
  ani_item_control.PlayMode = 2
  ani_item_control.Visible = true
  ani_item_control:Play()
end
function on_ani_item_animation_end(ani)
  ani.Visible = false
  local form = ani.ParentForm
  form.is_pfing = 0
  local item_box = ani.Parent
  if not nx_is_valid(item_box) then
    return
  end
  local child_name = string.format("%s_%s", nx_string("btn_item"), nx_string(ani.index))
  local btn_item_control = item_box:Find(child_name)
  if not nx_is_valid(btn_item_control) then
    return
  end
  if ani.AnimationImage == FP_ANI_1 then
    btn_item_control.Visible = true
    local image_name = g_item_backimage[btn_item_control.random_num]
    btn_item_control.NormalImage = nx_string(image_name)
    btn_item_control.FocueImage = nx_string(image_name)
    btn_item_control.PushImage = nx_string(image_name)
    btn_item_control.Enabled = false
    if form.fp_count == 2 then
      local timer = nx_value("timer_game")
      timer:Register(200, -1, nx_current(), "defer_send_msg", form, -1, -1)
    end
  elseif ani.AnimationImage == FP_ANI_2 then
    btn_item_control.Visible = true
    btn_item_control.NormalImage = nx_string(fp_normal)
    btn_item_control.FocueImage = nx_string(fp_normal)
    btn_item_control.PushImage = nx_string(fp_normal)
    btn_item_control.Enabled = true
    form.begin_index = 0
    form.end_index = 0
    form.is_pfing = 0
    form.fp_count = 0
  end
end
function defer_send_msg(form)
  nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_SEND_FP_RESULT, nx_int(form.begin_index - 1), nx_int(form.end_index - 1))
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "defer_send_msg", form)
  end
end
function on_btn_1_click(btn)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local text = gui.TextManager:GetText("ui_guishi_tuiyan_btn03")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_ghost_city", CLIENT_SUB_GHOST_CITY_BEGIN_TY)
    return true
  end
end
