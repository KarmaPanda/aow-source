require("util_gui")
require("util_functions")
require("util_vip")
require("share\\client_custom_define")
local max_dig_count = 50
function main_form_init(form)
  form.Fixed = true
  form.remain_time = 0
  return 1
end
function show_index_btn(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local nTime = client_player:QueryProp("DigTreasureTime")
  nTime = nx_number(nTime) % nx_number(100) + 1
  form.mainbox.IsEditMode = true
  for i = 1, max_dig_count do
    local control = clone_control(form, "btnbox", i)
    form.mainbox:Add(control)
    set_btnbox(control, nTime)
    control.Visible = true
  end
  form.mainbox.IsEditMode = false
  return 1
end
function on_main_form_open(form)
  form.groupbox_help.Visible = false
  form.mainbox.child_height = 0
  form.mainbox.child_left = 0
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_remain_time.Text = ""
  local nTime = client_player:QueryProp("DigTreasureCD")
  form.remain_time = nx_int(nTime)
  local nCount = client_player:QueryProp("DigTreasureTime")
  local nMax = nx_int(nCount) / nx_int(100)
  local nCur = nx_number(nCount) % nx_number(100)
  local nRemain = nx_int(nMax) - nx_int(nCur)
  form.lbl_remain_count.Text = nx_widestr(nRemain)
  local SeekMineManager = nx_value("SeekMineManager")
  if nx_is_valid(SeekMineManager) then
    SeekMineManager:RegisterRemainTimer(form.remain_time)
  end
  show_index_btn(form)
  return 1
end
function on_main_form_close(form)
  local SeekMineManager = nx_value("SeekMineManager")
  if nx_is_valid(SeekMineManager) then
    SeekMineManager:EndTimer()
  end
  nx_destroy(form)
  return 1
end
function on_btn_click(btn)
  btn.Enabled = false
  nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(0))
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
end
function on_btn_6_click(btn)
  local vip_module = nx_value("VipModule")
  if not nx_is_valid(vip_module) then
    return
  end
  btn.Enabled = false
  nx_execute("custom_sender", "custom_seek_mine_msg", nx_int(0))
  if not vip_module:IsVip(VT_NORMAL) and not util_is_form_visible("form_stage_main\\form_vip_info") then
    util_auto_show_hide_form("form_stage_main\\form_vip_info")
  end
end
function on_btn_info_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form.groupbox_help.Visible = not form.groupbox_help.Visible
  end
end
function on_server_msg(...)
  local type = arg[1]
  if nx_int(type) == 1 then
    local form = nx_value("form_stage_main\\form_task\\form_seek_mine")
    if not nx_is_valid(form) then
      return
    end
    if nx_int(arg[2]) == nx_int(1) then
      local parent_ctrl = form.Parent
      if nx_is_valid(parent_ctrl) then
        local parent_form = parent_ctrl.ParentForm
        if nx_is_valid(parent_form) and nx_script_name(parent_form) == "form_stage_main\\form_dbomall\\form_dbomall" then
          parent_form:Close()
        else
          form:Close()
        end
      else
        form:Close()
      end
      return
    end
    show_index_btn(form)
    local game_client = nx_value("game_client")
    if not nx_is_valid(game_client) then
      return
    end
    local client_player = game_client:GetPlayer()
    if not nx_is_valid(client_player) then
      return
    end
    local nCount = client_player:QueryProp("DigTreasureTime")
    local nMax = nx_int(nCount) / nx_int(100)
    local nCur = nx_number(nCount) % nx_number(100)
    local nRemain = nx_int(nMax) - nx_int(nCur)
    form.lbl_remain_count.Text = nx_widestr(nRemain)
    local nTime = client_player:QueryProp("DigTreasureCD")
    form.remain_time = nx_int(nTime)
    local SeekMineManager = nx_value("SeekMineManager")
    if nx_is_valid(SeekMineManager) then
      SeekMineManager:RegisterRemainTimer(form.remain_time)
    end
  elseif nx_int(type) == nx_int(3) then
    local item_config = nx_string(arg[2])
    local card = arg[3]
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "is_moveto")
    if not nx_is_valid(dialog) then
      return true
    end
    dialog.mltbox_info:Clear()
    local gui = nx_value("gui")
    dialog.mltbox_info:AddHtmlText(nx_widestr(gui.TextManager:GetFormatText("ui_beijisha_enemy_confirm", nx_widestr(card))), nx_int(-1))
    dialog.event_type = "is_moveto"
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "is_moveto_confirm_return")
    if res == "ok" then
      nx_execute("custom_sender", "custom_seek_mine_moveto_msg", nx_int(5), nx_string(item_config), nx_int(1))
    elseif res == "cancel" then
      nx_execute("custom_sender", "custom_seek_mine_moveto_msg", nx_int(5), nx_string(item_config), nx_int(0))
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  form:Close()
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
function set_btnbox(control, nTime)
  local form = control.ParentForm
  local mainbox = form.mainbox
  local aid = control.aid
  control.Top = mainbox.child_height
  control.Left = 10 + mainbox.child_left
  set_child_box_pos(control)
  local child_name = string.format("%s_%s", nx_string("btn"), nx_string(aid))
  local btn_control = control:Find(child_name)
  nx_bind_script(btn_control, nx_current())
  nx_callback(btn_control, "on_click", "on_btn_click")
  child_name = string.format("%s_%s", nx_string("lbl_mid"), nx_string(aid))
  local lbl_control = control:Find(child_name)
  btn_control.Visible = false
  if nx_int(aid) < nx_int(nTime) then
    lbl_control.Visible = false
  end
  if nx_int(aid) == nx_int(nTime) then
    btn_control.Visible = true
    btn_control.Enabled = true
  end
end
function set_child_box_pos(control)
  local form = control.ParentForm
  local mainbox = form.mainbox
  local aid = control.aid
  mainbox.child_height = nx_int(aid / 5) * 20 + nx_int(aid / 5) * control.Height
  mainbox.child_left = aid % 5 * (control.Width + 20)
end
