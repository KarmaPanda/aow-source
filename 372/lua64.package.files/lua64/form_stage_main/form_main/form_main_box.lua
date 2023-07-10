require("util_functions")
require("define\\gamehand_type")
require("util_role_prop")
require("form_stage_main\\switch\\switch_define")
local FUNC_TYPE_FIGHT = 0
local FUNC_TYPE_LIFE = 1
local FUNC_TYPE_JIANGHU = 2
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    return
  end
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.Left = (gui.Desktop.Width - self.Width) / 2
    self.Top = (gui.Desktop.Height - self.Height) / 2
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "update_newjh_form_main_box")
  end
  self.rbtn_fight.Checked = true
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_rbtn_life_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_grid(FUNC_TYPE_LIFE)
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_rbtn_fight_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_grid(FUNC_TYPE_FIGHT)
end
function on_rbtn_jianghu_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  refresh_grid(FUNC_TYPE_JIANGHU)
end
function on_ImageControlGrid1_select_changed(grid, index)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local func_name = nx_string(grid:GetItemName(index))
  local conditon_id = funcbtns:GetConditionByName(func_name)
  if conditon_id ~= -1 then
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
    if not bsucc then
      local text = util_text("desc_condition_" .. nx_string(conditon_id))
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
      return
    end
  end
  local form_path = funcbtns:GetBtnFormByName(func_name)
  if form_path == "" then
    return
  end
  nx_execute(form_path, "open_form")
  local helper_form = nx_value("helper_form")
  if helper_form then
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function on_ImageControlGrid1_drag_move(grid, index, drag_x, drag_y)
  if grid:IsEmpty(index) then
    return
  end
  if math.abs(drag_x) < 4 and math.abs(drag_y) < 4 then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local func_name = nx_string(grid:GetItemName(index))
  local photo = funcbtns:GetBtnPhotoByName(func_name, "image_out")
  if photo ~= "" then
    gui.GameHand:SetHand(GHT_FUNC, photo, "func", func_name, "func_btns_ex", "btns_ex")
  end
end
function on_ImageControlGrid1_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  local func_name = nx_string(grid:GetItemName(index))
  local func_tips = funcbtns:GetBtnTipByName(func_name)
  local text = util_text(func_tips)
  local key = funcbtns:GetBtnKeyByName(func_name)
  if 0 < key then
    local key_text = shortcut_keys:GetKeyNameByKeyID(key)
    text = text .. nx_widestr(" ( ") .. nx_widestr(key_text) .. nx_widestr(" )")
  end
  nx_execute("tips_game", "show_text_tip", text, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop())
end
function on_ImageControlGrid1_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function refresh_grid(func_type)
  func_type = func_type or FUNC_TYPE_FIGHT
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local imagegrid = form.ImageControlGrid1
  imagegrid:Clear()
  imagegrid:SetSelectItemIndex(nx_int(-1))
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    form:Close()
    return
  end
  local func_count = funcbtns:GetAddBtnCountByBelong(func_type)
  for i = 0, func_count - 1 do
    local func_name = funcbtns:GetAddBtnNameByBelongIndex(func_type, i)
    local func_photo = funcbtns:GetAddBtnBigPicByBelongIndex(func_type, i)
    local func_tips = funcbtns:GetBtnTipByName(func_name)
    if is_show(func_name) and "" ~= func_photo then
      log(nx_string(func_photo))
      imagegrid:AddItem(i, func_photo, nx_widestr(func_name), 1, -1)
      imagegrid:SetItemAddInfo(i, 0, util_text(func_tips))
      imagegrid:ShowItemAddInfo(i, 0, true)
    end
  end
end
function find_grid_item(grid, control_name)
  if not nx_is_valid(grid) then
    return -1
  end
  return grid:FindItem(nx_widestr(control_name))
end
function update_newjh_form_main_box(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.Visible = false
  else
    form.Visible = true
  end
  return
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
