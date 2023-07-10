require("util_functions")
require("util_gui")
require("define\\gamehand_type")
require("define\\shortcut_key_define")
require("const_define")
require("util_role_prop")
require("form_stage_main\\switch\\switch_define")
local MAX_ROM_NUM = 3
local FORM_MIAN_FUNCBTNS = "form_stage_main\\form_main\\form_main_func_btns"
local ani_loop = 2
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
local get_player = function()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return nx_null()
  end
  local client_player = game_client:GetPlayer()
  return client_player
end
function load_ini(form)
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form, "func_btn_ini") and nx_is_valid(form.func_btn_ini) then
    nx_destroy(form.func_btn_ini)
    form.func_btn_ini = nx_null()
  end
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local file = account .. "\\func_" .. nx_string(game_config.server_name) .. ".ini"
  ini.FileName = file
  ini:LoadFromFile()
  local show_row = ini:ReadInteger("main", "showrow", 1)
  local only_read = ini:ReadInteger("main", "onlyread", 0)
  local lock = ini:ReadInteger("main", "lock", 0)
  if lock == 1 then
    on_btn_unlock_click(form.btn_unlock)
  end
  form.func_btn_ini = ini
  form.show_row = show_row
  form.only_read = only_read
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  if not nx_find_custom(game_config, "freshman_btn_show") then
    return
  end
  if conditon_manager:CanSatisfyCondition(client_player, client_player, 103011) then
    game_config.freshman_btn_show = false
  else
    game_config.freshman_btn_show = true
  end
end
function main_form_init(self)
  self.Fixed = true
  return 1
end
function auto_show_hide_form_func_btns()
  util_auto_show_hide_form(nx_current())
end
function on_main_form_open(self)
  self.show_row = 1
  self.only_read = 0
  self.lock = 0
  load_ini(self)
  change_form_size()
  if self.only_read == 0 then
    set_image_grid_info(self.image_control_grid)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddRolePropertyBind("CurJHSceneConfigID", "string", self, nx_current(), "update_newjh_main_func_btns_ui")
  end
  change_btn_pos(self, self.image_control_grid)
  save_btn_info()
  if self.show_row > 1 then
    self.lbl_bg_bar_2.Visible = true
    self.lbl_bg_bar_3.Visible = true
    self.image_control_grid.RowNum = MAX_ROM_NUM
  else
    self.lbl_bg_bar_2.Visible = false
    self.lbl_bg_bar_3.Visible = false
    self.image_control_grid.RowNum = 1
  end
  self.btn_light2.Visible = false
  self.lbl_chatnum2.Visible = false
  self.btn_openchat2.Visible = false
  self.lbl_chatoutline2.Visible = false
  self.btn_opengroup2.Visible = false
  self.lbl_groupoutline2.Visible = false
  self.ani_newjh_explore.Visible = false
  self.ani_newjh_explore:Stop()
end
function set_image_grid_info(image_grid)
  if not nx_is_valid(image_grid) then
    return
  end
  local index = 0
  image_grid:Clear()
  local gui = nx_value("gui")
  local shortcut_keys = nx_value("ShortcutKey")
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(shortcut_keys) or not nx_is_valid(gui) then
    return
  end
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  if not nx_is_valid(funcbtns) then
    return
  end
  local count = funcbtns:GetBtnCount()
  funcbtns:ClearCoustomBtn()
  for i = 0, count - 1 do
    local btn_name = ""
    local keyid = -1
    local btn_pos = -1
    if nx_find_custom(game_config, "freshman_btn_show") and game_config.freshman_btn_show == true then
      local bBtnShow = funcbtns:IsFreshManBtnByIndex(i)
      if bBtnShow == true then
        btn_name = funcbtns:GetBtnNameByIndex(i)
        keyid = funcbtns:GetBtnKeyByIndex(i)
        btn_pos = funcbtns:GetBtnPosByIndex(i)
      end
    else
      btn_name = funcbtns:GetBtnNameByIndex(i)
      keyid = funcbtns:GetBtnKeyByIndex(i)
      btn_pos = funcbtns:GetBtnPosByIndex(i)
    end
    if btn_name ~= "" and 0 <= btn_pos then
      funcbtns:SetCustomBtnPos(btn_name, btn_pos)
    end
  end
end
function on_main_form_close(self)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "check_all_btns", self)
  end
  save_btn_info()
  if nx_find_custom(self, "func_btn_ini") and nx_is_valid(self.func_btn_ini) then
    nx_destroy(self.func_btn_ini)
    self.func_btn_ini = nx_null()
  end
  nx_destroy(self)
end
function change_form_size()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
end
function on_take_func(form, index_name)
  local gui = nx_value("gui")
  local game_hand = gui.GameHand
  local func_manager = nx_value("func_manager")
  local para2 = gui.GameHand.Para2
  if para2 == index_name then
    return 1
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local photo = funcbtns:GetBtnPhotoByName(index_name, "image_out")
  if photo ~= "" then
    gui.GameHand:SetHand(GHT_FUNC, photo, "func", index_name, "func_btns", "")
  end
  return 1
end
function on_open_form(name)
  if nil == name or "" == name then
    return 1
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local conditon_manager = nx_value("ConditionManager")
  if not nx_is_valid(conditon_manager) then
    return
  end
  local conditon_id = funcbtns:GetConditionByName(name)
  if conditon_id ~= -1 then
    local bsucc = conditon_manager:CanSatisfyCondition(client_player, client_player, conditon_id)
    if bsucc ~= true then
      local text = util_text("desc_condition_" .. nx_string(conditon_id))
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(text, 2)
      end
      return
    end
  end
  local form_path = funcbtns:GetBtnFormByName(name)
  if form_path == "" then
    return
  end
  if nx_string(name) == "btn_school_info" then
    local new_school = get_new_school()
    if "" ~= new_school and "0" ~= new_school then
      form_path = "form_stage_main\\form_school_war\\form_newschool_school_msg_info"
    end
    local n_force = get_force()
    if n_force ~= "" and n_force ~= "0" then
      form_path = "form_stage_main\\form_school_war\\form_new_school_msg_info"
    end
  end
  nx_execute(form_path, "open_form")
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
end
function on_btn_close_click(btn)
  local form = nx_value(nx_current())
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function change_btn_pos(form, image_grid)
  if not nx_is_valid(form) or not nx_is_valid(image_grid) then
    return
  end
  local client_player = get_player()
  local shortcut_keys = nx_value("ShortcutKey")
  local gui = nx_value("gui")
  local funcbtns = nx_value("form_main_func_btns")
  local game_config = nx_value("game_config")
  if not (nx_is_valid(client_player) and nx_is_valid(shortcut_keys)) or not nx_is_valid(gui) then
    return
  end
  if not nx_is_valid(game_config) then
    return
  end
  if not nx_is_valid(funcbtns) then
    return
  end
  local count = funcbtns:GetCustomBtnCount()
  image_grid:Clear()
  for i = 0, count - 1 do
    local btn_name = funcbtns:GetCustomBtnName(i)
    if funcbtns:FindBtnName(btn_name) then
      local keyid = funcbtns:GetBtnKeyByName(btn_name)
      local btn_realpos = funcbtns:GetCustomBtnPosByIndex(i)
      if not is_show(btn_name) and 0 <= btn_realpos then
        delete_custom_btn(btn_name)
        btn_name = ""
      end
      if btn_name ~= "" and 0 <= btn_realpos then
        local index_s = image_grid:FindItem(nx_widestr(btn_name))
        if -1 ~= index_s then
          image_grid:DelItem(nx_int(index_s))
        end
        if not image_grid:IsEmpty(nx_int(btn_realpos)) then
          local index = get_empty_grid(image_grid)
          if index ~= -1 then
            local src_name = image_grid:GetItemName(nx_int(btn_realpos))
            local src_photo = funcbtns:GetBtnPhotoByName(nx_string(src_name), "image_out")
            image_grid:AddItem(nx_int(index), src_photo, nx_widestr(src_name), nx_int(1), nx_int(1))
            local keyid_s = funcbtns:GetBtnKeyByName(nx_string(src_name))
            local text_s = shortcut_keys:GetKeyNameByKeyID(nx_int(keyid_s))
            image_grid:SetItemAddInfo(nx_int(index), nx_int(0), nx_widestr(text_s))
            image_grid:ShowItemAddInfo(nx_int(index), nx_int(0), true)
            funcbtns:SetCustomBtnPos(nx_string(src_name), index)
          end
        end
        local btn_photo = funcbtns:GetBtnPhotoByName(btn_name, "image_out")
        image_grid:DelItem(nx_int(btn_realpos))
        image_grid:AddItem(nx_int(btn_realpos), btn_photo, nx_widestr(btn_name), nx_int(1), nx_int(1))
        local text = shortcut_keys:GetKeyNameByKeyID(nx_int(keyid))
        image_grid:SetItemAddInfo(nx_int(btn_realpos), nx_int(0), nx_widestr(text))
        image_grid:ShowItemAddInfo(nx_int(btn_realpos), nx_int(0), true)
      end
    end
  end
  form.only_read = 1
end
function check_all_btns(form)
  if not nx_is_valid(form) then
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
  local image_grid = form.image_control_grid
  local def_count = funcbtns:GetBtnCount()
  for j = 0, def_count - 1 do
    local btn_name = funcbtns:GetBtnNameByIndex(j)
    local src_pos = image_grid:FindItem(nx_widestr(btn_name))
    if src_pos == -1 then
      local des_pos = get_empty_grid(image_grid)
      if des_pos ~= -1 then
        local btn_photo = funcbtns:GetBtnPhotoByName(btn_name, "image_out")
        local keyid = funcbtns:GetBtnKeyByName(btn_name)
        image_grid:AddItem(nx_int(des_pos), btn_photo, nx_widestr(btn_name), nx_int(1), nx_int(1))
        local text = shortcut_keys:GetKeyNameByKeyID(nx_int(keyid))
        image_grid:SetItemAddInfo(nx_int(des_pos), nx_int(0), nx_widestr(text))
        image_grid:ShowItemAddInfo(nx_int(des_pos), nx_int(0), true)
      end
    end
  end
end
function get_empty_grid(grid)
  if not nx_is_valid(grid) then
    return -1
  end
  local count = grid.ClomnNum * MAX_ROM_NUM
  for i = 0, count - 1 do
    if grid:IsEmpty(i) then
      return i
    end
  end
  return -1
end
function save_btn_info()
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local form = nx_value(FORM_MIAN_FUNCBTNS)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "func_btn_ini") then
    return
  end
  if not nx_is_valid(form.func_btn_ini) then
    return
  end
  local save_string = ""
  local split_key = ";"
  local btn_key = ","
  local count = funcbtns:GetCustomBtnCount()
  for i = 0, count - 1 do
    local btn_name = funcbtns:GetCustomBtnName(i)
    if funcbtns:FindBtnName(btn_name) then
      local btn_pos = funcbtns:GetCustomBtnPosByIndex(i)
      local default_pos = funcbtns:GetBtnPosByName(btn_name)
      save_string = save_string .. btn_name .. btn_key .. nx_string(btn_pos) .. split_key
    end
  end
  if nx_find_custom(form, "func_btn_ini") and nx_is_valid(form.func_btn_ini) then
    local ini = form.func_btn_ini
    ini:WriteString("main", "CustomFuncForm", nx_string(save_string))
    ini:WriteInteger("main", "showrow", form.show_row)
    ini:WriteInteger("main", "onlyread", form.only_read)
    ini:WriteInteger("main", "lock", form.lock)
    ini:SaveToFile()
  end
end
function on_image_control_grid_drag_move(self, index, drag_x, drag_y)
  local form = self.ParentForm
  local name = self:GetItemName(index)
  on_take_func(form, nx_string(name))
end
function on_image_control_grid_mousein_grid(grid, index)
  shortcut_item_change_image(grid, index, "image_on")
end
function on_image_control_grid_mouseout_grid(grid, index)
  shortcut_item_change_image(grid, index, "image_out")
end
function on_image_control_grid_drag_enter(grid, index)
  shortcut_item_change_image(grid, index, "image_down")
end
function on_image_control_grid_select_changed(self, index)
  local name = nx_string(self:GetItemName(index))
  shortcut_item_change_image(self, index, "image_up")
  local gui = nx_value("gui")
  local para2 = gui.GameHand.Para2
  local para4 = gui.GameHand.Para4
  local shortcut_keys = nx_value("ShortcutKey")
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(shortcut_keys) or not nx_is_valid(gui) then
    return 1
  end
  if not nx_is_valid(funcbtns) then
    return 1
  end
  if para2 ~= nil then
    local result = funcbtns:FindBtnName(para2)
    if result then
      local form = self.ParentForm
      local index_s = -1
      if para4 == "btns_ex" then
        if form.lock == 1 and name ~= "" then
          return 1
        end
        local pos = self:FindItem(nx_widestr(para2))
        if pos ~= -1 then
          index_s = pos
        else
          local empty_pos = get_empty_grid(self)
          if empty_pos == -1 then
            return 1
          end
          index_s = empty_pos
        end
      else
        index_s = self:FindItem(nx_widestr(para2))
      end
      local index_t = index
      if -1 == index_s or -1 == index_t then
        return 1
      end
      if index_s == index_t and name ~= "" then
        return 1
      end
      funcbtns:SetCustomBtnPos(para2, index_t)
      gui.GameHand:ClearHand()
      if "" ~= name then
        funcbtns:SetCustomBtnPos(name, index_s)
        local btn_photo = funcbtns:GetBtnPhotoByName(name, "image_on")
        self:DelItem(nx_int(index_s))
        self:AddItem(nx_int(index_s), btn_photo, nx_widestr(name), nx_int(1), nx_int(1))
        local keyid = funcbtns:GetBtnKeyByName(name)
        local text = shortcut_keys:GetKeyNameByKeyID(keyid)
        self:SetItemAddInfo(nx_int(index_s), nx_int(0), nx_widestr(text))
        self:ShowItemAddInfo(nx_int(index_s), nx_int(0), true)
      else
        self:DelItem(nx_int(index_s))
      end
      local btn_photo = funcbtns:GetBtnPhotoByName(para2, "image_on")
      self:DelItem(nx_int(index_t))
      self:AddItem(nx_int(index_t), btn_photo, nx_widestr(para2), nx_int(1), nx_int(1))
      local keyid = funcbtns:GetBtnKeyByName(para2)
      local text = shortcut_keys:GetKeyNameByKeyID(keyid)
      self:SetItemAddInfo(nx_int(index_t), nx_int(0), nx_widestr(text))
      self:ShowItemAddInfo(nx_int(index_t), nx_int(0), true)
      save_btn_info()
      local helper_form = nx_value("helper_form")
      if helper_form then
        nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "close_helper_form")
      end
      return 1
    end
  end
  on_open_form(name)
end
function shortcut_item_change_image(grid, index, change_type)
  local name = nx_string(grid:GetItemName(index))
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return 1
  end
  if "" == name then
    return 1
  end
  local form = grid.ParentForm
  local name = nx_string(grid:GetItemName(index))
  if "image_on" == change_type then
    local gui = nx_value("gui")
    local cursor_x, cursor_y = gui:GetCursorPosition()
    local btn_tip = funcbtns:GetBtnTipByName(name)
    local widestr_info = gui.TextManager:GetText(btn_tip)
    nx_execute("tips_game", "show_text_tip", widestr_info, cursor_x, cursor_y, 0, form)
  elseif "image_out" == change_type then
    nx_execute("tips_game", "hide_tip", form)
  end
  local btn_photo = funcbtns:GetBtnPhotoByName(name, change_type)
  grid:SetItemImage(index, btn_photo)
end
function on_btn_more_click(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  form.lbl_bg_bar_2.Visible = not form.lbl_bg_bar_2.Visible
  form.lbl_bg_bar_3.Visible = not form.lbl_bg_bar_3.Visible
  if form.lbl_bg_bar_2.Visible then
    form.image_control_grid.RowNum = MAX_ROM_NUM
    form.show_row = MAX_ROM_NUM
  else
    form.image_control_grid.RowNum = 1
    form.show_row = 1
  end
  gui.Desktop:ToFront(self)
  save_btn_info()
end
function update_shortcut_key()
  local form = nx_value(nx_current())
  local shortcut_keys = nx_value("ShortcutKey")
  local funcbtns = nx_value("form_main_func_btns")
  local index = 0
  if not nx_is_valid(shortcut_keys) or not nx_is_valid(form) then
    return 1
  end
  if not nx_is_valid(funcbtns) then
    return
  end
  local count = funcbtns:GetBtnCount()
  for i = 0, count - 1 do
    local btn_name = funcbtns:GetBtnNameByIndex(i)
    local keyid = funcbtns:GetBtnKeyByName(btn_name)
    if btn_name ~= "" and 0 <= keyid then
      local index = form.image_control_grid:FindItem(nx_widestr(btn_name))
      local text = shortcut_keys:GetKeyNameByKeyID(nx_int(keyid))
      form.image_control_grid:SetItemAddInfo(nx_int(index), nx_int(0), nx_widestr(text))
    end
  end
end
function find_grid_item(grid, config_id)
  local size = grid.RowNum * grid.ClomnNum
  for i = 1, size do
    local item_name = grid:GetItemName(i - 1)
    if nx_string(item_name) == config_id then
      return i - 1
    end
  end
end
function delete_custom_btn(btn_name)
  local form = nx_value(FORM_MIAN_FUNCBTNS)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "lock") then
    return
  end
  if form.lock == 1 then
    return
  end
  local funcbtns = nx_value("form_main_func_btns")
  if not nx_is_valid(funcbtns) then
    return
  end
  local form_main_btns = nx_value(FORM_MIAN_FUNCBTNS)
  if not nx_is_valid(form_main_btns) then
    return
  end
  local bDel = funcbtns:IsDelBtnByName(btn_name)
  if bDel ~= true then
    return
  end
  local imggrid = form_main_btns.image_control_grid
  local btn_pos = funcbtns:GetCustomBtnPosByName(btn_name)
  imggrid:DelItem(nx_int(btn_pos))
  funcbtns:DeleteCustomBtn(btn_name)
  save_btn_info()
end
function on_btn_lock_click(btn)
  change_btn(btn, 1)
end
function on_btn_unlock_click(btn)
  change_btn(btn, 0)
end
function change_btn(btn, index)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if index == 0 then
    form.lock = 1
    btn.Visible = false
    form.btn_lock.Visible = true
  elseif index == 1 then
    form.lock = 0
    btn.Visible = false
    form.btn_unlock.Visible = true
  end
  save_btn_info()
end
function get_force()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "0"
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "0"
  end
  local playerschool = client_player:QueryProp("Force")
  return nx_string(playerschool)
end
function get_new_school()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return "0"
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "0"
  end
  local new_school = client_player:QueryProp("NewSchool")
  return nx_string(new_school)
end
function update_newjh_main_func_btns_ui(form)
  if not nx_is_valid(form) then
    return
  end
  local bIsNewJHModule = is_newjhmodule()
  if bIsNewJHModule then
    form.lbl_bg.Visible = false
    form.lbl_bg_bar_1.Visible = false
    form.lbl_bg_bar_2.Visible = false
    form.btn_close.Visible = false
    form.lbl_bg_bar_3.Visible = false
    form.lbl_bg_bar_4.Visible = false
    form.groupbox_1.Visible = false
    form.btn_help.Visible = false
    form.image_control_grid.Visible = false
    form.btn_unlock.Visible = false
    form.btn_more.Visible = false
    form.btn_lock.Visible = false
    form.groupbox_newjh.Visible = true
  else
    form.lbl_bg.Visible = true
    form.lbl_bg_bar_1.Visible = true
    form.lbl_bg_bar_2.Visible = true
    form.btn_close.Visible = true
    form.lbl_bg_bar_3.Visible = true
    form.lbl_bg_bar_4.Visible = true
    form.groupbox_1.Visible = true
    form.btn_help.Visible = true
    form.image_control_grid.Visible = true
    form.btn_unlock.Visible = true
    form.btn_more.Visible = true
    form.btn_lock.Visible = true
    form.groupbox_newjh.Visible = false
    if form.show_row > 1 then
      form.lbl_bg_bar_2.Visible = true
      form.lbl_bg_bar_3.Visible = true
      form.image_control_grid.RowNum = MAX_ROM_NUM
    else
      form.lbl_bg_bar_2.Visible = false
      form.lbl_bg_bar_3.Visible = false
      form.image_control_grid.RowNum = 1
    end
  end
  return
end
function on_btn_newjh_bag_click(btn)
  nx_execute("form_stage_main\\form_bag_new", "auto_show_hide_bag")
end
function on_btn_newjh_yinz_click(btn)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  nx_execute("custom_sender", "custom_send_newjh_back_home")
end
function on_btn_newjh_explore_click(btn)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  local form = nx_value(FORM_MIAN_FUNCBTNS)
  if not nx_is_valid(form) then
    return
  end
  form.ani_newjh_explore.Visible = false
  form.ani_newjh_explore:Stop()
  util_auto_show_hide_form("form_stage_main\\form_task\\form_jianghu_explore")
end
function on_btn_life_skill_click(btn)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  local skill_id = nx_string("sh_gh")
end
function on_jianghu_info_change(sub_type)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  if nx_int(3) == nx_int(sub_type) then
    form.ani_newjh_explore.AnimationImage = nx_string("jhtsyl")
  elseif nx_int(4) == nx_int(sub_type) then
    form.ani_newjh_explore.AnimationImage = nx_string("jhtsmw")
  elseif nx_int(5) == nx_int(sub_type) then
    form.ani_newjh_explore.AnimationImage = nx_string("jhtshg")
  end
  form.ani_newjh_explore.Visible = true
  form.ani_newjh_explore:Stop()
  form.ani_newjh_explore:Play()
  ani_loop = 2
end
function on_ani_newjh_explore_animation_loop(ani, name)
  ani_loop = ani_loop - 1
  if 0 == ani_loop then
    ani.Visible = false
    ani:Stop()
  end
end
function on_btn_formula_click(btn)
  local bIsNewJHModule = is_newjhmodule()
  if not bIsNewJHModule then
    return
  end
  local form = util_get_form("form_stage_main\\form_life\\form_item_formula", true)
  if not nx_is_valid(form) then
    return
  end
  util_auto_show_hide_form("form_stage_main\\form_life\\form_item_formula")
  local helper_form = nx_value("helper_form")
  if helper_form then
    local helper_info_list = get_global_arraylist("helper_info")
    if not nx_is_valid(helper_info_list) then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
      return
    end
    local server_node = helper_info_list:GetChild("server_info")
    if not nx_is_valid(server_node) then
      nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
      return
    end
    config_id = nx_custom(server_node, "1")
    nx_execute("form_stage_main\\form_life\\form_item_formula", "select_node", nx_string(config_id))
    nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  end
end
function update_btns_shortcut_key()
  local form = nx_value(FORM_MIAN_FUNCBTNS)
  if not nx_is_valid(form) then
    return
  end
  local shortcut_keys = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_keys) then
    return
  end
  form.lbl_1.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_Form_Formula))
  form.lbl_2.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_Form_Bonfire))
  form.lbl_3.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_Form_Bag))
  form.lbl_4.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_Form_Explore))
  form.lbl_5.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_Form_Friend_List))
  form.lbl_6.Text = nx_widestr(shortcut_keys:GetKeyNameByKeyID(Key_FuncKey_Tent))
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
