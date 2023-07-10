require("util_functions")
require("util_gui")
local MAXSIGNINNUM = 7
local SIGNINREC = "SignInRec"
local ImagePath = "gui\\language\\ChineseS\\qiandaohuodong\\"
function on_main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  local SignInActivity = nx_value("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_destroy(SignInActivity)
  end
  local SignInActivity = nx_create("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_set_value("SignInActivity", SignInActivity)
  end
  local gui = nx_value("gui")
  self.AbsLeft = (gui.Width - self.Width) / 2
  self.AbsTop = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(SIGNINREC, self, nx_current(), "on_signin_rec_change")
    databinder:AddRolePropertyBind("IsGetVipPrize", "int", self, nx_current(), "on_get_vip_prize_change")
  end
  show_today_prize()
  self.cbtn_1.Checked = 1 == load_tips_checked()
  return 1
end
function on_main_form_close(form)
  local SignInActivity = nx_value("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_destroy(SignInActivity)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(SIGNINREC, form)
    databinder:DelRolePropertyBind("IsGetVipPrize", form)
  end
  nx_destroy(form)
end
function on_btn_3_click(btn)
  btn.ParentForm:Close()
end
function on_btn_1_click(btn)
  nx_execute("custom_sender", "custom_request_signin")
end
function on_btn_2_click(btn)
  nx_execute("custom_sender", "custom_request_signin_vip")
end
function on_cbtn_1_checked_changed(cbtn)
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_signin.ini"
  ini:LoadFromFile()
  ini:WriteInteger(nx_string("Checked"), nx_string("val"), nx_int(cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_lbl_get_capture(lbl)
  local SignInActivity = nx_value("SignInActivity")
  if not nx_is_valid(SignInActivity) then
    return
  end
  local index = lbl.DataSource
  local prize_table = SignInActivity:GetPrize(nx_int(index))
  local size = table.getn(prize_table)
  if size % 2 ~= 0 then
    return
  end
  local tips_text = nx_widestr("")
  for i = 1, size, 2 do
    local ConfigID = prize_table[i]
    local num = prize_table[i + 1]
    tips_text = tips_text .. util_format_string("tips_qiandao_1", ConfigID, num)
  end
  nx_execute("tips_game", "show_text_tip", tips_text, lbl.AbsLeft, lbl.AbsTop)
end
function on_lbl_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function on_imagegrid_mousein_grid(grid, index)
  if grid:IsEmpty(index) then
    return
  end
  local SignInActivity = nx_value("SignInActivity")
  if not nx_is_valid(SignInActivity) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = 0
  if client_player:FindRecord(SIGNINREC) then
    rows = client_player:GetRecordRows(SIGNINREC)
  end
  if rows < 0 or rows >= MAXSIGNINNUM then
    return
  end
  local prize_table = SignInActivity:GetPrize(rows + 1)
  local size = table.getn(prize_table)
  if size % 2 ~= 0 then
    return
  end
  if size < 2 * (index + 1) then
    return
  end
  local ConfigID = prize_table[2 * index + 1]
  nx_execute("tips_game", "show_tips_by_config", ConfigID, grid:GetMouseInItemLeft(), grid:GetMouseInItemTop(), grid.ParentForm)
end
function on_imagegrid_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip")
end
function on_signin_rec_change(bind_id, recordname, optype, row, clomn)
  if not nx_is_valid(bind_id) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord(recordname) then
    return
  end
  local rows = client_player:GetRecordRows(recordname)
  if rows <= 0 then
    return
  end
  for i = 0, rows - 1 do
    local lbl_name = "lbl_" .. nx_string(i + 1)
    local lbl = nx_custom(bind_id, lbl_name)
    if nx_is_valid(lbl) then
      lbl.BackImage = ImagePath .. nx_string(i + 1) .. "2" .. ".png"
    end
  end
  for i = rows, MAXSIGNINNUM - 1 do
    local lbl_name = "lbl_" .. nx_string(i + 1)
    local lbl = nx_custom(bind_id, lbl_name)
    if nx_is_valid(lbl) then
      lbl.BackImage = ImagePath .. nx_string(i + 1) .. "1" .. ".png"
    end
  end
  local is_get_vip_prize = client_player:FindProp("IsGetVipPrize") and 0 < client_player:QueryProp("IsGetVipPrize")
  if is_get_vip_prize then
    local lbl_name = "lbl_" .. "8"
    local lbl = nx_custom(bind_id, lbl_name)
    if nx_is_valid(lbl) then
      lbl.BackImage = ImagePath .. "82.png"
    end
  end
  show_today_prize()
end
function on_get_vip_prize_change(bind_id, prop_name, prop_type, value)
  if not nx_is_valid(bind_id) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not client_player:FindProp(prop_name) then
    return
  end
  local is_get_vip_prize = client_player:QueryProp("IsGetVipPrize") > 0
  local lbl_name = "lbl_" .. "8"
  local lbl = nx_custom(bind_id, lbl_name)
  if not nx_is_valid(lbl) then
    return
  end
  if is_get_vip_prize then
    lbl.BackImage = ImagePath .. "82.png"
  else
    lbl.BackImage = ImagePath .. "81.png"
  end
end
function show_today_prize()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local SignInActivity = nx_value("SignInActivity")
  if not nx_is_valid(SignInActivity) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = 0
  if client_player:FindRecord(SIGNINREC) then
    rows = client_player:GetRecordRows(SIGNINREC)
  end
  if rows < 0 or rows >= MAXSIGNINNUM then
    local imagegrid = form.imagegrid_1
    imagegrid:Clear()
    return
  end
  local prize_table = SignInActivity:GetPrize(rows + 1)
  local size = table.getn(prize_table)
  if size % 2 ~= 0 then
    return
  end
  local ItemsQuery = nx_value("ItemQuery")
  local imagegrid = form.imagegrid_1
  imagegrid:Clear()
  local index = 0
  for i = 1, size, 2 do
    local ConfigID = prize_table[i]
    local num = prize_table[i + 1]
    local photo = ItemsQuery:GetItemPropByConfigID(ConfigID, "Photo")
    imagegrid:AddItem(index, photo, util_text(ConfigID), num, -1)
    index = index + 1
  end
end
function is_need_tips()
  local signin_isopen = true
  local is_can_signin = true
  local ST_FUNCTION_SIGNIN = 18
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    signin_isopen = switch_manager:CheckSwitchEnable(ST_FUNCTION_SIGNIN)
  end
  local SignInActivity = nx_value("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_destroy(SignInActivity)
  end
  local SignInActivity = nx_create("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_set_value("SignInActivity", SignInActivity)
  end
  is_can_signin = SignInActivity:CanSignIn()
  if signin_isopen and is_can_signin and 1 == load_tips_checked() then
    nx_execute("form_stage_main\\form_activity\\form_activity_signin", "open_form")
  else
    local SignInActivity = nx_value("SignInActivity")
    if nx_is_valid(SignInActivity) then
      nx_destroy(SignInActivity)
    end
  end
end
function load_tips_checked()
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return 0
  end
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  local rst = 1
  if nx_is_valid(ini) then
    ini.FileName = account .. "\\form_signin.ini"
    if ini:LoadFromFile() then
      rst = ini:ReadInteger(nx_string("Checked"), nx_string("val"), 1)
    end
  end
  nx_destroy(ini)
  return rst
end
function open_form()
  local SignInActivity = nx_value("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_destroy(SignInActivity)
  end
  local SignInActivity = nx_create("SignInActivity")
  if nx_is_valid(SignInActivity) then
    nx_set_value("SignInActivity", SignInActivity)
  end
  is_can_signin = SignInActivity:CanSignIn()
  if is_can_signin then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_activity\\form_activity_signin", true, false)
    if not nx_is_valid(form) then
      return
    end
    nx_execute("form_stage_main\\form_dbomall\\form_dbomall", "add_sub_form", form)
  else
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("huigui_qiandao_new_forbidden"))
    local SignInActivity = nx_value("SignInActivity")
    if nx_is_valid(SignInActivity) then
      nx_destroy(SignInActivity)
    end
  end
end
