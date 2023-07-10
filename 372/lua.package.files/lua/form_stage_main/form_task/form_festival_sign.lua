require("util_gui")
require("util_functions")
require("share\\view_define")
CLIENT_SUBMSG_REQUEST_INFO = 0
CLIENT_SUBMSG_REQUEST_MONEY_SIGN = 1
CLIENT_SUBMSG_REQUEST_SIGN_ACCTASK = 2
CLIENT_SUBMSG_REQUEST_GET_BIGREWARD = 3
SERVER_SUBMSG_SIGN_INFO = 0
SERVER_SUBMSG_SIGN_SUCCEED = 1
SERVER_SUBMSG_SIGN_UPDATE = 2
local sign_list = {}
col_task_id = 1
col_task_name = 2
col_reward = 3
col_count = 3
local FORM_SIGN = "form_stage_main\\form_task\\form_festival_sign"
local weilingqu = "ui_cjhd_bn001"
local yilingqu = "ui_cjhd_bn002"
local lingqu = "ui_cjhd_bn004"
local item_image1 = "gui\\special\\dbomall\\bdn_004.png"
local item_image2 = "gui\\special\\dbomall\\bdn_003.png"
local sign_date = "ui_festval_sign_date_"
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Width - self.Width) / 2
    self.Top = (gui.Height - self.Height) / 2
  end
  self.dis_bgtime = 0
  self.dis_edtime = 0
  self.card = 0
  self.big_reward = ""
  self.child_count = 0
  self.fest_pro = 0
  self.finish_flag = 0
  nx_execute("custom_sender", "custom_request_festival_sign_info", CLIENT_SUBMSG_REQUEST_INFO)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("FestivalProgress", "int", self, nx_current(), "on_update_FestivalProgress")
  end
end
function on_main_form_close(self)
  nx_execute("tips_game", "hide_tip")
  nx_destroy(self)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function clone_concrol(form, control_name, aid)
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
function receive_server_msg(sub_msg, ...)
  local form = nx_value(FORM_SIGN)
  if not nx_is_valid(form) then
    return
  end
  if nx_number(sub_msg) == SERVER_SUBMSG_SIGN_INFO then
    local dis_bgtime = nx_int(arg[1])
    local dis_edtime = nx_int(arg[2])
    local finish_flag = nx_int(arg[3])
    local card = nx_int(arg[4])
    local big_reward = nx_string(arg[5])
    local count = nx_int(arg[6])
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    table.remove(arg, 1)
    open_form(dis_bgtime, dis_edtime, finish_flag, card, big_reward, count, unpack(arg))
  elseif nx_number(sub_msg) == SERVER_SUBMSG_SIGN_UPDATE then
    frame_add_child(form)
  end
end
function open_form(dis_bgtime, dis_edtime, finish_flag, card, big_reward, count, ...)
  local form = nx_value(FORM_SIGN)
  if not nx_is_valid(form) then
    return
  end
  form.dis_bgtime = dis_bgtime
  form.dis_edtime = dis_edtime
  form.card = card
  form.big_reward = big_reward
  form.child_count = count
  form.finish_flag = finish_flag
  sign_list = {}
  for i = 1, nx_number(count) do
    sign_list[i] = {}
    sign_list[i].task_id = nx_int(arg[(i - 1) * col_count + col_task_id])
    sign_list[i].task_name = nx_string(arg[(i - 1) * col_count + col_task_name])
    sign_list[i].reward = nx_string(arg[(i - 1) * col_count + col_reward])
  end
  frame_add_child(form)
end
function frame_add_child(form)
  local count = nx_number(table.getn(sign_list))
  if count <= 0 then
    return
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local gui = nx_value("gui")
  local frame = form.frame
  local scroll_value = frame.VScrollBar.Value
  frame.AlwaysVScroll = true
  frame.IsEditMode = true
  frame:DeleteAll()
  frame.child_height = 0
  for i = 0, count - 1 do
    local new_control = clone_concrol(form, "child_box", i)
    frame:Add(new_control)
    set_child_control_info(new_control)
  end
  local fest_flag = client_player:QueryProp("FestivalFlag")
  if form.fest_pro == form.child_count and fest_flag == 0 then
    form.btn_get_big.Enabled = true
    form.btn_get_big.Text = nx_widestr(gui.TextManager:GetText(nx_string(lingqu)))
  elseif form.fest_pro == form.child_count and fest_flag == 1 then
    form.btn_get_big.Enabled = false
    form.btn_get_big.Text = nx_widestr(gui.TextManager:GetText(nx_string(yilingqu)))
  else
    form.btn_get_big.Enabled = false
    form.btn_get_big.Text = nx_widestr(gui.TextManager:GetText(nx_string(lingqu)))
  end
  local photo = get_icon(0, nx_string(form.big_reward))
  form.img_big_reward:AddItem(0, nx_string(photo), nx_widestr(form.big_reward), nx_int(1), 0)
  frame.IsEditMode = false
  frame:ResetChildrenYPos()
  frame.VScrollBar.Value = scroll_value
  if 0 > form.dis_bgtime or 0 < form.dis_edtime then
    form.btn_get_big.Enabled = false
  end
end
function set_frame_child_height(control)
  local form = control.ParentForm
  local frame = form.frame
  frame.child_height = frame.child_height + control.Height + 2
end
function set_child_control_info(control)
  local form = control.ParentForm
  local frame = form.frame
  local aid = control.aid
  control.Top = frame.child_height
  control.Left = frame.Left
  set_frame_child_height(control)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local taskmgr = nx_value("TaskManager")
  if not nx_is_valid(taskmgr) then
    return
  end
  if aid % 2 == 1 then
    control.BackImage = item_image1
  else
    control.BackImage = item_image2
  end
  local child_name = string.format("%s_%s", nx_string("reward"), nx_string(aid))
  local child_control = control:Find(child_name)
  nx_bind_script(child_control, nx_current())
  nx_callback(child_control, "on_mousein_grid", "on_mousein_reward_grid")
  nx_callback(child_control, "on_mouseout_grid", "on_mouseout_reward_grid")
  child_control:Clear()
  local reward = sign_list[aid + 1].reward
  local photo = get_icon(0, nx_string(reward))
  child_control:AddItem(0, nx_string(photo), nx_widestr(reward), nx_int(1), 0)
  child_name = string.format("%s_%s", nx_string("btn_accept_task"), nx_string(aid))
  local btn_accept = control:Find(child_name)
  nx_bind_script(btn_accept, nx_current())
  nx_callback(btn_accept, "on_click", "on_btn_accept_click")
  btn_accept.task_id = sign_list[aid + 1].task_id
  btn_accept.Enabled = true
  child_name = string.format("%s_%s", nx_string("btn_card_get"), nx_string(aid))
  local btn_card_get = control:Find(child_name)
  nx_bind_script(btn_card_get, nx_current())
  nx_callback(btn_card_get, "on_click", "on_btn_card_get_click")
  btn_card_get.task_id = sign_list[aid + 1].task_id
  btn_card_get.aid = aid
  btn_card_get.Enabled = true
  btn_accept.Text = nx_widestr(gui.TextManager:GetText(nx_string(weilingqu)))
  local progress = form.fest_pro
  if aid <= form.dis_bgtime then
    btn_card_get.Enabled = true
  end
  if is_in_accept_record(btn_accept.task_id) == 1 then
    btn_accept.Enabled = false
  end
  if aid < progress then
    btn_accept.Text = nx_widestr(gui.TextManager:GetText(nx_string(yilingqu)))
    btn_card_get.Enabled = false
    btn_accept.Enabled = false
  end
  child_name = string.format("%s_%s", nx_string("lbl_sign_flag"), nx_string(aid))
  local sign_flag = control:Find(child_name)
  if aid <= form.dis_bgtime then
    sign_flag.Visible = true
  else
    sign_flag.Visible = false
  end
  child_name = string.format("%s_%s", nx_string("lbl_task_name"), nx_string(aid))
  local lbl_task_name = control:Find(child_name)
  lbl_task_name.Text = nx_widestr(util_text(nx_string(sign_list[aid + 1].task_name)))
  child_name = string.format("%s_%s", nx_string("lbl_sign_date"), nx_string(aid))
  local lbl_sign_date = control:Find(child_name)
  lbl_sign_date.Text = nx_widestr(gui.TextManager:GetText(nx_string(sign_date) .. nx_string(aid + 1)))
  if 0 > form.dis_bgtime or 0 < form.dis_edtime then
    btn_card_get.Enabled = false
    btn_accept.Enabled = false
  end
end
function on_mousein_reward_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_mouseout_reward_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function show_prize_tips(grid, index)
  local prize_id = grid:GetItemName(nx_int(index))
  local prize_type = grid:GetItemMark(nx_int(index))
  local prize_count = grid:GetItemNumber(nx_int(index))
  if nx_string(prize_id) == "" or nx_number(prize_count) <= 0 then
    return
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  if nx_number(prize_type) == 1 then
    local tip_text = nx_widestr(util_text(nx_string(prize_id)) .. ":" .. nx_string(prize_count))
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 2 then
    local tip_text = nx_widestr(prize_id)
    nx_execute("tips_game", "show_text_tip", tip_text, x, y)
  elseif nx_number(prize_type) == 0 then
    local itemmap = nx_value("ItemQuery")
    if not nx_is_valid(itemmap) then
      return
    end
    local table_prop_name = {}
    local table_prop_value = {}
    table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(prize_id))
    if 0 >= table.getn(table_prop_name) then
      return
    end
    table_prop_value.ConfigID = nx_string(prize_id)
    for count = 1, table.getn(table_prop_name) do
      local prop_name = table_prop_name[count]
      local prop_value = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string(prop_name))
      table_prop_value[prop_name] = prop_value
    end
    local staticdatamgr = nx_value("data_query_manager")
    if nx_is_valid(staticdatamgr) then
      local index = itemmap:GetItemPropByConfigID(nx_string(prize_id), nx_string("ArtPack"))
      local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
      if nx_string(photo) ~= "" and photo ~= nil then
        table_prop_value.Photo = photo
      end
    end
    if nx_is_valid(grid.Data) then
      nx_destroy(grid.Data)
    end
    grid.Data = nx_create("ArrayList", "task_grid_data")
    grid.Data:ClearChild()
    for prop, value in pairs(table_prop_value) do
      nx_set_custom(grid.Data, prop, value)
    end
    nx_set_custom(grid.Data, "is_static", true)
    nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32)
    grid.Data:ClearChild()
  end
end
function get_icon(type, name)
  local str_icon = ""
  local select_type = 0
  if nx_number(type) == 0 then
    str_icon = nx_call("util_static_data", "item_query_ArtPack_by_id", name, "Photo")
  end
  if str_icon ~= nil and 0 < string.len(str_icon) then
    return str_icon
  end
  return ""
end
function on_btn_accept_click(btn)
  nx_execute("custom_sender", "custom_request_festival_sign_acctask", CLIENT_SUBMSG_REQUEST_SIGN_ACCTASK, btn.aid)
end
function on_btn_card_get_click(btn)
  local gui = nx_value("gui")
  local info = gui.TextManager:GetText("cjhd_bdn_006")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  dialog.mltbox_info:Clear()
  local index = dialog.mltbox_info:AddHtmlText(nx_widestr(info), -1)
  dialog.mltbox_info:SetHtmlItemSelectable(nx_int(index), false)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    if not nx_is_valid(btn) or btn.Enabled == false or not nx_find_custom(btn, "aid") then
      return
    end
    nx_execute("custom_sender", "custom_request_festival_sign_card_get", CLIENT_SUBMSG_REQUEST_MONEY_SIGN, btn.aid)
  end
end
function is_in_accept_record(task_id)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  local row = client_player:FindRecordRow("Task_Accepted", 0, nx_int(task_id))
  if 0 <= row then
    return 1
  end
  return 0
end
function on_update_FestivalProgress(form, propname, proptype, value)
  if proptype == "int" then
    form.fest_pro = value
  end
end
function on_btn_get_big_click(btn)
  nx_execute("custom_sender", "custom_request_festival_sign_get_big", CLIENT_SUBMSG_REQUEST_GET_BIGREWARD)
end
