require("define\\gamehand_type")
require("const_define")
require("form_stage_main\\switch\\switch_define")
function on_form_main_init(self)
  self.start_timer = false
  self.lead_num = 0
  self.lead_index = -1
end
function on_main_form_open(self)
  self.lead_num = 0
  self.lead_index = -1
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    on_main_form_close(self)
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    on_main_form_close(self)
    return
  end
  local index = form_main.clicked_index
  self.lead_index = index
  local main_btn = form_main.clicked_btn
  local btn_count = funcbtns:GetAddBtnCountByBelong(index)
  if btn_count <= 0 or not nx_is_valid(main_btn) then
    on_main_form_close(self)
    return
  end
  local gui = nx_value("gui")
  local shortcut_keys = nx_value("ShortcutKey")
  self.Width = 260
  self.Height = btn_count * 35
  self.AbsLeft = main_btn.AbsLeft + main_btn.Width - 7
  self.AbsTop = main_btn.AbsTop + main_btn.Height - self.Height
  self.groupscrollbox_1.Width = 260
  self.groupscrollbox_1.Height = btn_count * 35
  self.groupscrollbox_1.Left = 0
  self.groupscrollbox_1.Top = 0
  self.imagegrid_sel.Visible = false
  for i = 1, btn_count do
    local btn_name = funcbtns:GetAddBtnNameByBelongIndex(index, i - 1)
    local btn_pic = funcbtns:GetAddBtnPicByBelongIndex(index, i - 1)
    local is_show = is_show(btn_name)
    if not is_show then
      self.Height = self.Height - 35
      self.AbsTop = main_btn.AbsTop + main_btn.Height - self.Height
      self.groupscrollbox_1.Height = self.groupscrollbox_1.Height - 35
    end
    if is_show and btn_name ~= "" and btn_pic ~= "" then
      local btn_tip = funcbtns:GetBtnTipByName(btn_name)
      local key = funcbtns:GetBtnKeyByName(btn_name)
      local text = nx_widestr("")
      text = gui.TextManager:GetText(btn_tip)
      if 0 < key then
        local key_text = shortcut_keys:GetKeyNameByKeyID(key)
        text = text .. nx_widestr(" ( ") .. nx_widestr(key_text) .. nx_widestr(" )")
      end
      local x = 0
      local y = (i - 1) * 35
      on_create_groupbox(self.groupscrollbox_1, x, y, btn_pic, text, btn_name)
    end
  end
  self.start_timer = false
end
function check_form_show(form)
  if not nx_is_valid(form) then
    return
  end
  local left = form.AbsLeft
  local top = form.AbsTop
  local right = left + form.Width
  local bottom = top + form.Height - 5
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  if cursor_x > left - 2 and cursor_x < right - 2 and cursor_y > top - 5 and bottom > cursor_y then
    return
  else
    close_form()
  end
end
function on_groupscrollbox_1_get_capture(self)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  nx_execute("form_stage_main\\form_main\\form_main", "on_del_hide_func_timer", form_main)
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "check_form_show", self)
  end
  nx_destroy(self)
end
function on_imagegrid_sel_lost_capture(grid)
  local form = grid.ParentForm
  local left = form.AbsLeft
  local top = form.AbsTop
  local right = left + form.Width
  local bottom = top + form.Height - 5
  local gui = nx_value("gui")
  local cursor_x, cursor_y = gui:GetCursorPosition()
  if cursor_x > left - 2 and cursor_x < right - 2 and cursor_y > top - 5 and bottom > cursor_y then
    return
  else
    close_form()
  end
end
function on_imagegrid_sel_get_capture(grid)
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  nx_execute("form_stage_main\\form_main\\form_main", "on_del_hide_func_timer", form_main)
end
function on_imagegrid_sel_select_changed(grid, index)
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local btn_name = grid.sel_name
  local helper_form = nx_value("helper_form")
  if helper_form and nx_string(btn_name) ~= nx_string("btn_home") then
    on_imagegrid_sel_drag_move(grid, index)
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
    return
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local conditon_id = funcbtns:GetConditionByName(btn_name)
  if conditon_id ~= -1 then
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
    if bsucc ~= true then
      return
    end
  end
  local form_path = funcbtns:GetBtnFormByName(btn_name)
  if form_path == "" then
    return
  end
  nx_execute(form_path, "open_form")
  if funcbtns:IsNeedLeadBtn(btn_name) then
    funcbtns:SetbtnLeadEnd(btn_name)
    local form_btn_ex = grid.ParentForm
    on_hide_active_ani(form_btn_ex, btn_name)
    form_btn_ex.lead_num = form_btn_ex.lead_num - 1
    if form_btn_ex.lead_num <= 0 then
      on_hide_lead_info(form_btn_ex)
      funcbtns:ShowLeadInfoStart()
      return
    end
  end
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_imagegrid_sel_drag_move(grid, index)
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local gui = nx_value("gui")
  local btn_name = grid.sel_name
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local conditon_id = funcbtns:GetConditionByName(btn_name)
  if conditon_id ~= -1 then
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
    if bsucc ~= true then
      return
    end
  end
  local photo = funcbtns:GetBtnPhotoByName(btn_name, "image_out")
  if photo ~= "" then
    gui.GameHand:SetHand(GHT_FUNC, photo, "func", btn_name, "func_btns_ex", "btns_ex")
  end
end
function on_create_groupbox(form, x, y, image, text, name)
  if not nx_is_valid(form) then
    return
  end
  local form_btn_ex = nx_value("form_stage_main\\form_main\\form_main_func_btns_ex")
  if not nx_is_valid(form_btn_ex) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  if not nx_is_valid(groupbox) then
    return
  end
  local lbl_img = gui:Create("Label")
  local lbl_text = gui:Create("Label")
  if not nx_is_valid(lbl_img) or not nx_is_valid(lbl_text) then
    gui:Delete(groupbox)
    return
  end
  form:Add(groupbox)
  groupbox.Width = 260
  groupbox.Height = 35
  groupbox.Left = x
  groupbox.Top = y
  groupbox.Name = name
  groupbox.NoFrame = true
  groupbox.BackColor = "0,255,255,255"
  nx_bind_script(groupbox, nx_current())
  nx_callback(groupbox, "on_get_capture", "on_groupbox_get_capture")
  local use_image = image
  local text_color = "255,255,255,255"
  local conditon_id = funcbtns:GetConditionByName(name)
  if conditon_id ~= -1 then
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
    if bsucc ~= true then
      use_image = funcbtns:GetBtnPhotoByName(name, "image_enabled")
      text_color = "180,156,156,156"
    end
  end
  if use_image == "" then
    use_image = image
  end
  groupbox:Add(lbl_img)
  lbl_img.Width = 36
  lbl_img.Height = 36
  lbl_img.Left = 4
  lbl_img.Top = 0
  lbl_img.BackImage = use_image
  lbl_img.DrawMode = FitWindow
  lbl_img.BlendColor = text_color
  groupbox:Add(lbl_text)
  lbl_text.Width = 260
  lbl_text.Height = 31
  lbl_text.Left = 46
  lbl_text.Top = 2
  lbl_text.Text = text
  lbl_text.ForeColor = text_color
  lbl_text.Font = "font_main"
  nx_set_custom(form_btn_ex, name, groupbox)
  if not funcbtns:IsNeedLeadBtn(name) then
    return
  end
  local lbl_ani = gui:Create("Label")
  if not nx_is_valid(lbl_ani) then
    gui:Delete(lbl_ani)
    return
  end
  groupbox:Add(lbl_ani)
  lbl_ani.Left = -3
  lbl_ani.Top = -2
  lbl_ani.Width = 265
  lbl_ani.Height = 38
  lbl_ani.BackImage = "flash_lead_1"
  lbl_ani.DrawMode = "ExpandH"
  lbl_ani.Name = name .. "_ani"
  lbl_ani.AutoSize = false
  form_btn_ex.lead_num = form_btn_ex.lead_num + 1
end
function on_groupbox_get_capture(groupbox)
  if not nx_is_valid(groupbox) then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  nx_execute("tips_game", "hide_tip")
  local form = groupbox.ParentForm
  local helper_form = nx_value("helper_form")
  if not helper_form and form.start_timer ~= true then
    local timer = nx_value(GAME_TIMER)
    if nx_is_valid(timer) then
      timer:Register(1000, -1, nx_current(), "check_form_show", form, -1, -1)
      form.start_timer = true
    end
  end
  imggrid = form.imagegrid_sel
  imggrid:Clear()
  imggrid:SetSelectItemIndex(-1)
  imggrid.Width = groupbox.Width - 9
  imggrid.Height = groupbox.Height - 2
  imggrid.AbsLeft = groupbox.AbsLeft + 2
  imggrid.AbsTop = groupbox.AbsTop + 1
  imggrid.Visible = true
  imggrid.sel_name = groupbox.Name
  imggrid.GridPos = "0,0;"
  imggrid.GridWidth = groupbox.Width
  imggrid.GridHeight = groupbox.Height
  imggrid:AddItem(0, "", nx_widestr(""), 1, 1)
  local conditon_id = funcbtns:GetConditionByName(groupbox.Name)
  if conditon_id == -1 then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
  if bsucc ~= true then
    local gui = nx_value("gui")
    local text = gui.TextManager:GetText("desc_condition_" .. nx_string(conditon_id))
    local x = groupbox.AbsLeft + groupbox.Width / 2
    local y = groupbox.AbsTop
    nx_execute("tips_game", "show_text_tip", text, x, y)
  end
end
function close_form()
  local form = nx_value("form_stage_main\\form_main\\form_main_func_btns_ex")
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function on_hide_active_ani(form, btn_name)
  if not nx_is_valid(form) then
    return
  end
  local groupobox = form.groupscrollbox_1
  local item = groupobox:Find(btn_name)
  if not nx_is_valid(item) then
    return
  end
  local lbl_ani = item:Find(btn_name .. "_ani")
  if nx_is_valid(lbl_ani) then
    lbl_ani.Visible = false
  end
end
function on_hide_lead_info(form)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "lead_index") then
    return
  end
  if form.lead_index < 0 or form.lead_index > 2 then
    return
  end
  local form_main = nx_value("form_stage_main\\form_main\\form_main")
  if not nx_is_valid(form_main) then
    return
  end
  if form.lead_index == 0 then
    form_main.lbl_animation_0.Visible = false
    form_main.lbl_text_0.Visible = false
  elseif form.lead_index == 1 then
    form_main.lbl_animation_1.Visible = false
    form_main.lbl_text_1.Visible = false
  elseif form.lead_index == 2 then
    form_main.lbl_animation_2.Visible = false
    form_main.lbl_text_2.Visible = false
  end
end
function is_show(btn_name)
  if nx_string(btn_name) == "btn_auction_info" then
    local switchmgr = nx_value("SwitchManager")
    if nx_is_valid(switchmgr) then
      return switchmgr:CheckSwitchEnable(ST_FUNCTION_AUCTION_COMPANY)
    end
  end
  return true
end
