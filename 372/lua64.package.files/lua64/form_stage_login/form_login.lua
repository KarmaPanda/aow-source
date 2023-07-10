require("utils")
require("util_gui")
require("util_functions")
require("const_define")
require("form_stage_main\\switch\\url_define")
require("tips_data")
require("gameinfo_collector")
local LOGIN_ANI_INI = "ini\\ui\\animation\\login_animation.ini"
local LOGIN_NEW_INI = "ini\\form\\load_new.ini"
local sdo_image = {
  "gui\\login\\bg_sdo_note_1.png",
  "gui\\login\\btn_sdo_out.png",
  "gui\\login\\btn_sdo_on.png",
  "gui\\login\\btn_sdo_donw.png"
}
local sg_image = {
  "gui\\login\\bg_sg_note_1.png",
  "gui\\login\\btn_sg_out.png",
  "gui\\login\\btn_sg_on.png",
  "gui\\login\\btn_sg_donw.png"
}
local log = function(str)
  nx_function("ext_log_testor", str .. "\n")
end
function main_form_init(form)
  form.curTop = 0
  form.curLeft = 0
  form.animationback = 0
  form.animationlable = 0
  form.star_finish = false
end
function refresh_registe(form)
  local show_registe = false
  local ini = get_ini("ini\\res_ver.ini")
  if nx_is_valid(ini) then
    local sect_index = ini:FindSectionIndex("switch")
    if 0 <= sect_index then
      local res_val = ini:ReadString(sect_index, "ShowRegiste", "0")
      if res_val == "1" then
        show_registe = true
      end
    end
  end
  form.btn_regist.Visible = show_registe
  form.lbl_21.Visible = show_registe
end
function main_form_open(form)
  form.ipt_2.Encrypt = true
  form.groupbox_web_btn.Visible = false
  form.btn_sdo_login.Visible = false
  form.visual_player = nx_null()
  change_form_size(form)
  form.btn_pwd_question.Visible = false
  form.btn_pwd_protect.Visible = false
  form.btn_keyboard.Visible = false
  form.btn_enter.Visible = false
  form.btn_return.Visible = false
  form.btn_select.Visible = false
  form.btn_login.Visible = false
  form.cbtn_save.Visible = false
  form.lbl_4.Visible = false
  form.lbl_5.Visible = false
  form.lbl_6.Visible = false
  form.lbl_7.Visible = false
  form.ipt_1.Visible = false
  form.ipt_2.Visible = false
  form.empty_1.Visible = false
  form.lbl_11.Visible = false
  form.lbl_12.Visible = false
  form.lbl_13.Visible = false
  form.lbl_14.Visible = false
  form.lbl_15.Visible = false
  form.lbl_16.Visible = false
  form.lbl_17.BackColor = "0,0,0,0"
  form.lbl_saveaccount.AbsLeft = form.cbtn_save.AbsLeft + 25
  form.lbl_saveaccount.AbsTop = form.cbtn_save.AbsTop + 5
  form.lbl_saveaccount.Visible = false
  form.ipt_1.NoFrame = true
  form.ipt_2.NoFrame = true
  refresh_registe(form)
  local game_config = nx_value("game_config")
  if game_config.save_account then
    form.cbtn_save.Checked = true
  end
  if game_config.login_account ~= "" then
    form.ipt_1.Text = nx_widestr(game_config.login_account)
  end
  form.cbtn_Video.Visible = false
  form.lbl_video_back.BackImage = ""
  form.video_1.DrawMode = "FitWindow"
  form.groupbox_qr.Visible = false
  game_config.login_qr = false
  form.qrcode_show.ZoomMultiple = 4
  game_config.show_activity = true
  if nx_find_custom(game_config, "freshman_btn_show") then
    game_config.freshman_btn_show = false
  end
  local gui = nx_value("gui")
  if nx_string(form.ipt_1.Text) == "" then
    gui.Focused = form.ipt_1
  elseif nx_string(form.ipt_2.Text) == "" then
    gui.Focused = form.ipt_2
  end
  form.Default = form.btn_enter
  form.btn_enter.Enabled = false
  form.btn_return.Enabled = false
  local timer = nx_value(GAME_TIMER)
  if not nx_find_custom(game_config, "login_type") then
    game_config.login_type = "2"
  end
  if game_config.login_type == "2" then
    form.cbtn_Video.Visible = true
    init_video_checked(form)
    play_video(form, "video\\login.wmv")
    reset_back_image(form)
    play_ani(form, "login_animation_open")
  else
    local AOWSteamClient = nx_value("AOWSteamClient")
    local is_steam = nx_is_valid(AOWSteamClient)
    if is_steam then
      form.lbl_18.Visible = false
    else
      timer:Register(100, 1, nx_current(), "start_animation", form, 1, -1)
    end
  end
  timer:Register(300000, -1, nx_current(), "exit_game", form, -1, -1)
  form.login_num = 0
  local login_info_list = get_login_info_list()
  local size = table.getn(login_info_list)
  local other_list = {}
  local is_show_sdo = false
  local last_show = 0
  for i = 0, size - 1 do
    local index = login_info_list[size - i]
    if nx_string("") ~= nx_string(index) then
      if nx_string(0) == nx_string(index) then
        last_show = 0
      elseif nx_string(1) == nx_string(index) then
        form.btn_sdo_login.Visible = true
        is_show_sdo = true
        last_show = 1
      else
        table.insert(other_list, nx_string(index))
      end
    end
  end
  local bshow_sho_mibao = false
  if is_show_sdo and 1 == last_show then
    bshow_sho_mibao = true
    on_btn_sdo_login_click(form.btn_sdo_login)
  end
  if 0 < table.getn(other_list) and not is_steam then
    form.web_view_login:AddWebCallBack("jy_login_succeed", nx_current(), "web_login_form")
    form.web_view_login:AddWebCallBack("jy_login_failed", nx_current(), "web_login_form")
    form.groupbox_web_btn.Visible = true
    create_login_btn(form, other_list)
  end
  on_show_billboard(form)
  show_mibao_btn(form, bshow_sho_mibao)
  local funcbtns = nx_value("form_main_func_btns")
  if nx_is_valid(funcbtns) then
    funcbtns:ResetLoadAddbtn()
  end
  local LogicVmChecker = nx_value("LogicVmChecker")
  if nx_is_valid(LogicVmChecker) then
    LogicVmChecker:UnRegisterUpLoad()
  end
  if is_steam then
    AOWSteamClient:LoginBySteam(form)
    try_login_game(form)
  end
end
function main_form_close(form)
  local timer = nx_value(GAME_TIMER)
  if not nx_is_valid(form) then
    return
  end
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "exit_game", form)
  end
  form.login_num = 0
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    form.web_view_login:RemoveWebCallBack("web_login_form")
    form.web_view_login:RemoveWebCallBack("web_login_form")
  end
  local form_login_note = nx_value("form_stage_login\\form_login_note")
  if nx_is_valid(form_login_note) then
    form_login_note:Close()
  end
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(sdo_login_interface) then
    sdo_login_interface:CloseWindow()
  end
  local visual_player = form.visual_player
  if nx_is_valid(visual_player) then
    local world = nx_value("world")
    world:Delete(visual_player)
  end
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager(LOGIN_NEW_INI)
  end
  nx_destroy(form)
end
function exit_game()
  local form = nx_value("form_stage_login\\form_login")
  if not nx_is_valid(form) then
    return
  end
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) then
    form.web_view_login:Disable()
    form.groupbox_web.Visible = false
  end
  local form_queue = nx_value("form_common\\form_queue")
  if nx_is_valid(form_queue) then
    return
  end
  local form_login_phone = nx_value("form_stage_login\\form_login_phone")
  if nx_is_valid(form_login_phone) then
    return
  end
  local form_out = nx_value("breakconnect_form_confirm")
  if nx_is_valid(form_out) then
    local timer = nx_value(GAME_TIMER)
    timer:UnRegister(nx_current(), "exit_game", form)
    return
  end
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(sdo_login_interface) then
    sdo_login_interface.ShowLoginDialog = false
  end
  local dialog = nx_execute("form_common\\form_confirm", "get_new_confirm_form", "breakconnect")
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.cancel_btn.Visible = false
  dialog.ok_btn.Left = dialog.cancel_btn.Left
  dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("ui_net_close_info"))
  dialog.ok_btn.Text = nx_widestr(gui.TextManager:GetText("ui_exitgame"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "breakconnect_confirm_return")
  nx_execute("main", "direct_exit_game")
end
function change_form_size(form)
  local gui = nx_value("gui")
  local desktop = gui.Desktop
  if nx_is_valid(form) then
    form.Width = desktop.Width + 5
    form.Height = desktop.Height
    form.lbl_17.Width = desktop.Width + 5
    form.lbl_17.Height = desktop.Height
    form.lbl_1.Width = desktop.Width + 5
    form.lbl_2.Width = desktop.Width
    form.lbl_saveaccount.AbsLeft = form.cbtn_save.AbsLeft + 25
    form.lbl_saveaccount.AbsTop = form.cbtn_save.AbsTop + 5
    form.video_1.Width = desktop.Width + 5
    form.video_1.Height = desktop.Height
    form.lbl_over_ani.Width = desktop.Width + 5
    form.lbl_over_ani.Height = desktop.Height
    form.lbl_video_back.Width = desktop.Width + 5
    form.lbl_video_back.Height = desktop.Height
    form.groupbox_web.Left = (gui.Width - form.groupbox_web.Width) / 2
    form.groupbox_web.Top = (gui.Height - form.groupbox_web.Height) / 2
    local game_config = nx_value("game_config")
    if form.groupbox_web.Visible and nx_is_valid(game_config) then
      form.web_view_login:Refresh()
      form.web_view_login:Enable()
    end
  end
  nx_execute("form_stage_login\\form_login_mibao", "resize")
  nx_execute("form_common\\form_queue", "resize")
  nx_execute("form_stage_login\\form_login_woniuke", "resize")
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(sdo_login_interface) then
    sdo_login_interface:ChangeFormSize()
  end
end
function on_btn_exit_game_click(btn)
  nx_execute("main", "confirm_exit_game")
end
function on_btn_enter_click(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  local account = nx_string(form.ipt_1.Text)
  local password = nx_string(form.ipt_2.Text)
  local login_validate = nx_string(game_config.login_validate)
  if account == "" then
    disp_error(util_text("ui_NotInputAccount"))
    return 0
  end
  if password == "" and "" == login_validate then
    disp_error(util_text("ui_NotInputPassword"))
    return 0
  end
  if string.len(account) < 2 then
    disp_error(util_text("ui_NotInputAccountLength"))
    return 0
  end
  if form.cbtn_save.Checked then
    game_config.save_account = true
  else
    game_config.save_account = false
  end
  game_config.login_account = nx_string(account)
  game_config.login_password = nx_string(password)
  local account = game_config.login_account
  local exe_path = nx_function("ext_get_current_exe_path")
  nx_function("ext_create_directory", exe_path .. account)
  local gui = nx_value("gui")
  local is_need_login_tips = nx_execute("form_stage_login\\form_login_tips", "is_need_login_tips")
  local form_login_tips = util_get_form("form_stage_login\\form_login_tips", true)
  if is_need_login_tips and nx_is_valid(form_login_tips) then
    form_login_tips.Top = (gui.Desktop.Height - form_login_tips.Height) / 2
    form_login_tips.Left = (gui.Desktop.Width - form_login_tips.Width) / 2
    form_login_tips.Visible = true
    form_login_tips:ShowModal()
    local res = nx_wait_event(100000000, nx_null(), "login_tips")
    if res ~= "ok" then
      return
    end
  end
  try_login_game(form)
  return 1
end
function on_btn_return_click(self)
  local form = self.Parent
  local res = nx_execute("main", "exit_game")
  if res then
    nx_gen_event(form, "login_return", "cancel")
    if nx_is_valid(form) then
      form:Close()
    end
  end
  return 1
end
function on_btn_keyboard_click(self)
  local form = self.Parent
  local subform = util_get_form("form_common\\form_minkeyboard", true)
  if nx_is_valid(subform) then
    form:Add(subform)
    subform.AbsLeft = self.AbsLeft - 250
    subform.Top = self.AbsTop + 120
    subform:Show()
    subform.Visible = true
    subform.file_name = nx_current()
  end
  return 1
end
function on_in_put_key(form, key)
  form.ipt_2:Append(nx_widestr(key))
end
function on_del_key(form)
  if form.ipt_2.IsSelectText then
    form.ipt_2:DeleteSelectText()
  elseif 0 ~= form.ipt_2.InputPos and form.ipt_2:DeleteText(form.ipt_2.InputPos - 1, 1) then
    form.ipt_2.InputPos = form.ipt_2.InputPos - 1
  end
  form.ipt_2:ClearSelect()
  form.ipt_2:ResetEditInfo()
end
function on_btn_enter_get_capture(self)
  local form = self.ParentForm
  local game_config = nx_value("game_config")
  if game_config.login_type == "1" then
    set_animation_location(form, form.lbl_5, "Login_Step3", false, false)
    set_animation_location(form, self, "Login_Start_On", true, false)
  end
end
function on_btn_enter_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local game_config = nx_value("game_config")
  if game_config.login_type == "1" then
    gui:Delete(form.animationback)
    gui:Delete(form.animationlable)
  end
end
function on_btn_return_get_capture(self)
  local form = self.ParentForm
  set_animation_location(form, form.lbl_10, "Login_Quit_Back_On", false, true)
end
function on_btn_return_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui:Delete(form.animationback)
end
function on_btn_pwd_question_click(btn)
  nx_execute("form_stage_login\\form_login_note", "show_login_note_form")
end
function on_btn_pwd_question_get_capture(self)
  local form = self.ParentForm
  set_animation_location(form, form.lbl_8, "Login_Question_Back_On", false, true)
end
function on_btn_pwd_question_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui:Delete(form.animationback)
end
function on_btn_pwd_protect_get_capture(self)
  local form = self.ParentForm
  set_animation_location(form, form.lbl_9, "Login_Password_Back_On", false, true)
end
function on_btn_pwd_protect_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui:Delete(form.animationback)
end
function on_btn_regist_get_capture(self)
end
function on_btn_regist_lost_capture(self)
end
function on_btn_select_get_capture(self)
  local form = self.ParentForm
  set_animation_location(form, self, "Login_Vbutton_Back_On", true, false)
  set_animation_location(form, self, "Login_Area_On", false, false)
end
function on_btn_select_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui:Delete(form.animationback)
  gui:Delete(form.animationlable)
end
function on_btn_login_get_capture(self)
  local form = self.ParentForm
  set_animation_location(form, self, "Login_Vbutton_Back_On", true, false)
  set_animation_location(form, self, "Login_CountersignLogin_On", false, false)
end
function on_btn_login_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui:Delete(form.animationback)
  gui:Delete(form.animationlable)
end
function on_btn_regist_click(self)
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) then
    switch_manager:OpenUrl(URL_TYPE_9YIN_ACCOUNT_REG)
  end
end
function set_animation_location(form, self, name, second, toback)
  local gui = nx_value("gui")
  if form.star_finish then
    return 0
  end
  local animation = gui:Create("Animation")
  if second == true then
    form.animationlable = animation
  else
    form.animationback = animation
  end
  animation.VAnchor = self.VAnchor
  animation.HAnchor = self.HAnchor
  animation.Top = self.Top
  animation.Left = self.Left
  animation.AnimationImage = name
  form:Add(animation)
  if toback == true then
    form:ToBack(animation)
  end
  animation.Visible = true
  animation:Play()
end
function start_animation(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return 0
  end
  local animation = create_animation(form, index)
  if not nx_is_valid(animation) then
    return 0
  end
  animation:Stop()
  animation:Play()
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return 0
  end
  local count = (table.getn(animation_info) - 3) / 2
  if count <= 0 then
    return 0
  end
  local created_table = {}
  local real_time_count = 0
  while true do
    local all_create = true
    local base_index = 3
    for i = 1, count do
      if created_table[base_index + i] == nil or not created_table[base_index + i] then
        if real_time_count * 1000 >= nx_number(animation_info[base_index + i * 2]) then
          nx_execute(nx_current(), "start_animation", form, nx_int(animation_info[base_index + i * 2 - 1]))
          created_table[base_index + i] = true
        else
          all_create = false
        end
      end
    end
    if all_create then
      break
    end
    real_time_count = real_time_count + nx_pause(0)
  end
end
function create_animation(form, index)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return
  end
  local animation = gui:Create("Animation")
  form:Add(animation)
  animation.Visible = false
  local controlitem = form:Find(nx_string(animation_info[2]))
  if nx_is_valid(controlitem) then
    animation.VAnchor = controlitem.VAnchor
    animation.HAnchor = controlitem.HAnchor
    animation.Top = controlitem.Top
    animation.Left = controlitem.Left
  else
    animation.Top = 0
    animation.Left = 0
  end
  animation.AnimationImage = animation_info[1]
  if nx_number(index) == 28 then
    animation.AnimationImage = ""
    form:ToFront(form.lbl_17)
    nx_execute(nx_current(), "back_color_change", form.lbl_17, 4000)
  end
  if animation_info[3] == "loop" then
    form:ToBack(animation)
    form:ToBack(form.lbl_4)
  end
  if animation_info[1] == "Login_Step6_1" then
    form:ToBack(animation)
    form:ToBack(form.lbl_4)
    form:ToFront(form.lbl_6)
    form:ToFront(form.groupbox_qr)
  end
  if string.find(animation_info[1], "Login_Finish_Step") ~= nil then
    form:ToFront(animation)
  end
  local flag = animation_info[3]
  if flag == "loop" then
    animation.Loop = true
  else
    animation.Loop = false
    nx_bind_script(animation, nx_current())
    nx_callback(animation, "on_animation_end", "animation_event_end")
  end
  animation.Visible = true
  animation.index = index
  return animation
end
function animation_event_end(animation, ani_name, mode)
  if not nx_is_valid(animation) then
    return 1
  end
  local form = animation.ParentForm
  local index = animation.index
  local animation_info = get_step_info(index)
  if animation_info == nil then
    return 1
  end
  local controlitem = form:Find(nx_string(animation_info[2]))
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if nx_is_valid(controlitem) and animation_info[3] == "true" and (not nx_is_valid(sdo_login_interface) or false == sdo_login_interface.ShowLoginDialog) then
    controlitem.Visible = true
  end
  if index == 5 then
    try_login_game(form)
  end
  if index == 33 then
    local login_control = nx_value("login_control")
    if nx_is_valid(login_control) then
      login_control:SetCameraDirect(894, 12.4, 495.7, 0, 3.05, 0)
    end
    local time_count = 0
    while time_count < 1 do
      time_count = time_count + nx_pause(0)
    end
    nx_gen_event(form, "login_return", "ok")
    if nx_is_valid(form) then
      form:Close()
    end
    nx_set_value("login_ready", true)
  end
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui:Delete(animation)
    else
      local world = nx_value("world")
      if nx_is_valid(world) then
        world:Delete(animation)
      end
    end
  end
end
function get_step_info(step)
  local ini = nx_execute("util_functions", "get_ini", LOGIN_ANI_INI)
  if not nx_is_valid(ini) then
    return
  end
  local ani_info_str = ini:ReadString("login_animation", nx_string(step), "")
  if ani_info_str == "" then
    return
  end
  return nx_function("ext_split_string", ani_info_str, ",")
end
function back_color_change(item, total_time)
  local escape_time = 0
  while escape_time <= nx_number(total_time) do
    if nx_is_valid(item) then
      item.BackColor = nx_string(255 * (escape_time / nx_number(total_time))) .. ",0,0,0"
    end
    escape_time = escape_time + 1 + nx_pause(0) * 1000
  end
end
function try_login_game(form)
  local game_config = nx_value("game_config")
  local ClientDataFetch = nx_value("ClientDataFetch")
  if nx_is_valid(ClientDataFetch) then
    ClientDataFetch:BeginAct(2)
  end
  local login_qr = game_config.login_qr
  if not login_qr then
    if game_config.login_account == "" then
      if nx_is_valid(form) then
        form.btn_enter.Enabled = true
        form.btn_return.Enabled = true
      end
      return 0
    end
    if game_config.login_password == "" and game_config.login_validate == "" then
      if nx_is_valid(form) then
        form.btn_enter.Enabled = true
        form.btn_return.Enabled = true
      end
      return 0
    end
  end
  form.btn_enter.Enabled = false
  form.btn_return.Enabled = false
  form.btn_sdo_login.Enabled = false
  form.btn_qr.Enabled = false
  form.star_finish = true
  GTP_set_collector_time(GTP_LUA_FUNC_LOGIN, true, false)
  if game_config.login_verify ~= nil and game_config.login_verify ~= "" then
    nx_execute("form_stage_login\\form_login_mibao", "login_game", game_config.login_account, game_config.login_password, game_config.login_verify, game_config.login_validate)
  else
    nx_execute("client", "login_game", game_config.login_addr, game_config.login_port, game_config.area_addr, game_config.area_port, game_config.login_account, game_config.login_password, game_config.login_validate, game_config.login_verify, game_config.login_niudun, game_config.login_shoujiniudun, game_config.login_qr)
  end
  game_config.login_password = ""
  game_config.login_verify = ""
  game_config.login_niudun = ""
  game_config.login_shoujiniudun = ""
  local res = nx_wait_event(100000000, nx_null(), "login_game")
  if res == "failed" or res == "timeout" then
    GTP_set_collector_time(GTP_LUA_FUNC_LOGIN, false, true)
    nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_LOGIN, game_config.login_account, "", 0, game_config.login_addr, false)
    if nx_is_valid(form) then
      form.btn_enter.Enabled = true
      form.btn_return.Enabled = true
      form.btn_sdo_login.Enabled = true
      form.btn_qr.Enabled = true
      form.star_finish = false
    end
    if nx_is_valid(ClientDataFetch) then
      ClientDataFetch:SendActInfo(2, 0)
    end
    if game_config.login_qr then
      game_config.login_qr = false
      form.groupbox_qr.Visible = false
    end
    return 0
  end
  GTP_set_collector_time(GTP_LUA_FUNC_LOGIN, false, true)
  nx_execute("gameinfo_collector", "GTP_call_func", GTP_LUA_FUNC_LOGIN, game_config.login_account, "", 0, game_config.login_addr, true)
  local timer = nx_value(GAME_TIMER)
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "exit_game", form)
  end
  if nx_is_valid(form) then
    local game_config = nx_value("game_config")
    if game_config.login_type == "1" then
      start_animation(form, 28)
    else
      play_ani(form, "login_animation_close")
      stop_video(form.video_1)
      form.cbtn_Video.Visible = false
    end
  end
  if nx_is_valid(ClientDataFetch) then
    ClientDataFetch:SendActInfo(2, 1)
  end
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    karmamgr:LoadFilterNative()
  end
end
function set_login_enabled()
  local form = nx_value("form_stage_login\\form_login")
  if nx_is_valid(form) then
    form.btn_enter.Enabled = true
    form.btn_return.Enabled = true
    form.star_finish = false
  end
end
function on_sdo_login(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local game_config = nx_value("game_config")
  local login_validate = arg[1]
  game_config.login_account = nx_string("HelloSdo")
  game_config.login_validate = nx_string(login_validate)
  game_config.login_password = ""
  local gui = nx_value("gui")
  local is_need_login_tips = nx_execute("form_stage_login\\form_login_tips", "is_need_login_tips")
  local form_login_tips = util_get_form("form_stage_login\\form_login_tips", true)
  if is_need_login_tips and nx_is_valid(form_login_tips) then
    form_login_tips.Top = (gui.Desktop.Height - form_login_tips.Height) / 2
    form_login_tips.Left = (gui.Desktop.Width - form_login_tips.Width) / 2
    form_login_tips.Visible = true
    form_login_tips:ShowModal()
    local res = nx_wait_event(100000000, nx_null(), "login_tips")
    if res ~= "ok" then
      return
    end
  end
  form.btn_enter.Enabled = false
  form.btn_return.Enabled = false
  nx_execute(nx_current(), "try_login_game", form)
end
function web_login_form(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return 1
  end
  local res = arg[1]
  if 1 == res then
    local game_config = nx_value("game_config")
    local login_account = arg[2]
    local login_validate = arg[3]
    local test = arg[4]
    game_config.login_account = nx_string(login_account)
    game_config.login_validate = nx_string(login_validate)
    nx_execute(nx_current(), "try_login_game", form)
  elseif 2 == res then
  end
  on_btn_web_close_click(form.btn_web_close)
end
function on_btn_login_click(btn)
  local form = btn.ParentForm
  set_web_info(form, btn.type_info)
end
function set_web_info(form, type_info)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\login\\web_info.ini", true)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string(type_info))
  if sec_index < 0 then
    return
  end
  local w = ini:ReadInteger(sec_index, "WebWidth", 0)
  local h = ini:ReadInteger(sec_index, "WebHeight", 0)
  local url = ini:ReadString(sec_index, "Url", "")
  local gui = nx_value("gui")
  form.groupbox_web.Width = w
  form.groupbox_web.Height = h + 10
  form.groupbox_web.Left = (gui.Width - form.groupbox_web.Width) / 2
  form.groupbox_web.Top = (gui.Height - form.groupbox_web.Height) / 2
  form.groupbox_web.Visible = true
  form.web_view_login.Top = 20
  form.web_view_login.Width = w
  form.web_view_login.Height = h
  form.web_view_login.Url = nx_widestr(url)
  form.web_view_login:Refresh()
  form.web_view_login:Enable()
end
function on_btn_web_close_click(btn)
  local form = btn.ParentForm
  form.web_view_login:Disable()
  form.groupbox_web.Visible = false
end
function create_login_btn(form, item_value_list)
  local ini = nx_execute("util_functions", "get_ini", "ini\\ui\\login\\web_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  form.lbl_24.Visible = false
  local gui = nx_value("gui")
  local size = table.getn(item_value_list)
  local width = form.groupbox_web_btn.Width / size
  for i, sect in ipairs(item_value_list) do
    local btn = gui:Create("Button")
    local sec_index = ini:FindSectionIndex(nx_string(sect))
    if nx_int(-1) == nx_int(sec_index) then
      return
    end
    local left = ini:ReadInteger(sec_index, "Left", 0)
    local top = ini:ReadInteger(sec_index, "Top", 0)
    btn.NormalImage = ini:ReadString(sec_index, "NormalImage", "")
    btn.FocusImage = ini:ReadString(sec_index, "FocusImage", "")
    btn.PushImage = ini:ReadString(sec_index, "PushImage", "")
    btn.AutoSize = true
    btn.Left = width * (i - 1)
    btn.Top = top
    btn.type_info = sect
    form.groupbox_web_btn:Add(btn)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_login_click")
  end
end
function set_sdo_login_dialog(form, sdo_login_show)
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if not nx_is_valid(sdo_login_interface) then
    return
  end
  sdo_login_interface.ShowLoginDialog = sdo_login_show
  sdo_login_interface.LoginDialogPosX = form.lbl_4.AbsLeft + 2
  sdo_login_interface.LoginDialogPosY = form.lbl_4.AbsTop + 6
  form.btn_enter.Enabled = not sdo_login_interface.ShowLoginDialog
  form.btn_return.Enabled = not sdo_login_interface.ShowLoginDialog
  show_sg_login_dialog(form, not sdo_login_show)
  form.sdo_login_show = sdo_login_show
  show_mibao_btn(form, sdo_login_show)
end
function on_btn_sdo_login_click(btn)
  local form = btn.ParentForm
  local image
  local game_config = nx_value("game_config")
  if game_config.login_type == "1" then
    image = sdo_image[2]
  else
    image = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "out", "")
  end
  if form.btn_sdo_login.NormalImage == image then
    local form_sddl = util_get_form("form_stage_login\\form_login_sddl", true)
    if nx_is_valid(form_sddl) then
      form_sddl.Visible = true
      form_sddl:ShowModal()
      local res = nx_wait_event(100000000, nx_null(), "login_sddl")
      if res ~= "ok" then
        return
      end
    end
  end
  local sdo_login_interface = nx_value("SdoLoginInterface")
  if not nx_is_valid(sdo_login_interface) then
    sdo_login_interface = nx_create("SdoLoginInterface")
    nx_set_value("SdoLoginInterface", sdo_login_interface)
  end
  if nx_is_valid(sdo_login_interface) then
    set_sdo_login_dialog(form, not sdo_login_interface.ShowLoginDialog)
  end
end
function show_sg_login_dialog(form, show)
  if not nx_is_valid(form) then
    return
  end
  form.btn_enter.Visible = show
  form.lbl_4.Visible = show
  form.lbl_5.Visible = show
  form.lbl_6.Visible = show
  form.lbl_7.Visible = show
  form.lbl_18.Visible = show
  form.ipt_1.Visible = show
  form.ipt_2.Visible = show
  form.btn_keyboard.Visible = show
  form.cbtn_save.Visible = show
  form.lbl_saveaccount.Visible = show
  form.btn_regist.Visible = show
  local game_config = nx_value("game_config")
  if game_config.login_type == "1" then
    if show then
      form.lbl_21.BackImage = sg_image[1]
      form.btn_sdo_login.NormalImage = sdo_image[2]
      form.btn_sdo_login.FocusImage = sdo_image[3]
      form.btn_sdo_login.PushImage = sdo_image[4]
    else
      form.lbl_21.BackImage = sdo_image[1]
      form.btn_sdo_login.NormalImage = sg_image[2]
      form.btn_sdo_login.FocusImage = sg_image[3]
      form.btn_sdo_login.PushImage = sg_image[4]
    end
  elseif show then
    form.lbl_21.BackImage = sg_image[1]
    form.btn_sdo_login.NormalImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "out", "")
    form.btn_sdo_login.FocusImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "on", "")
    form.btn_sdo_login.PushImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "down", "")
  else
    form.lbl_21.BackImage = sdo_image[1]
    form.btn_sdo_login.NormalImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "out_wn", "")
    form.btn_sdo_login.FocusImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "on_wn", "")
    form.btn_sdo_login.PushImage = get_ini_prop(LOGIN_NEW_INI, "btn_sdo_login", "down_wn", "")
  end
end
function on_show_billboard(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_billboard.Visible = false
  local ini = nx_execute("util_functions", "get_ini", "ini\\billboard_info.ini")
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  local index = 0
  local x = 0
  local y = 0
  local groupbox = form.groupbox_billboard
  for i = 0, count - 1 do
    if 0 < index then
      x = index * 270 + 10
    end
    local show = ini:ReadInteger(i, "show", 0)
    if show == 1 then
      local img_nor = ini:ReadString(i, "img_nor", "")
      local img_on = ini:ReadString(i, "img_on", "")
      local img_down = ini:ReadString(i, "img_down", "")
      local img_dis = ini:ReadString(i, "img_dis", "")
      local btn = gui:Create("Button")
      if nx_is_valid(btn) then
        groupbox:Add(btn)
        btn.Left = x
        btn.Top = 74
        btn.Width = 100
        btn.Height = 68
        local enable = ini:ReadInteger(i, "enable", 0)
        btn.NormalImage = img_nor
        btn.FocusImage = img_on
        btn.PushImage = img_down
        btn.DisableImage = img_dis
        btn.DrawMode = "FixWindow"
        btn.Enabled = nx_boolean(enable)
        btn.Name = ini:GetSectionByIndex(i)
        nx_bind_script(btn, nx_current())
        nx_callback(btn, "on_click", "on_btn_billboard_click")
        index = index + 1
      end
    end
  end
  if 0 < index then
    groupbox.Width = 270 * index + 30
    groupbox.AbsLeft = gui.Width - groupbox.Width
    groupbox.Visible = true
  end
end
function on_btn_billboard_click(btn)
  local name = btn.Name
  if name ~= "" then
    local ini_mgr = nx_value("IniManager")
    local ini = ini_mgr:GetIniDocument("ini\\billboard_info.ini")
    if not nx_is_valid(ini) then
      return
    end
    local index = ini:FindSectionIndex(name)
    local url = ini:ReadString(index, "url", "")
    nx_function("ext_open_url", url)
  end
end
function on_lbl_23_click(lbl)
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  switch_manager:OpenUrl(URL_TYPE_WN_MIBAO)
end
function show_mibao_btn(form, show_sdo)
  if not nx_is_valid(form) then
    return
  end
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  form.lbl_23.Visible = false
  local bshow_wn = false
  if show_sdo then
    bshow_wn = false
  else
    local url = switch_manager:GetUrl(URL_TYPE_WN_MIBAO)
    if url ~= "" then
      bshow_wn = true
    end
  end
  local gui = nx_value("gui")
  if bshow_wn == true then
    form.lbl_23.Visible = true
  end
end
function play_video(form, path)
  if form.cbtn_Video.Checked then
    form.video_1.Loop = true
    form.video_1.AutoPlay = false
    form.video_1.BackImage = "gui\\login\\login_zhdl.jpg"
    form.video_1.Video = path
    local res = form.video_1:Play()
    if not res then
      form.lbl_video_back.BackImage = "gui\\login\\login_zhdl.jpg"
    end
  else
    form.lbl_video_back.BackImage = "gui\\login\\login_zhdl.jpg"
  end
end
function stop_video(video)
  video.Loop = false
  video.AutoPlay = false
  video:Stop()
end
function play_ani(form, key)
  local ini = nx_create("IniDocument")
  ini.FileName = nx_resource_path() .. LOGIN_ANI_INI
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    return
  end
  local ani_table = ini:GetItemList(key)
  for i = 1, table.getn(ani_table) do
    local item_name = nx_string(ani_table[i])
    local ani_info_str = ini:ReadString(key, item_name, "")
    local res = nx_function("ext_split_string", ani_info_str, ",")
    if table.getn(res) == 3 then
      create_new_animation(form, item_name, res[1], res[2], res[3])
    end
  end
  nx_destroy(ini)
end
function create_new_animation(form, index, ani_path, controlitem_name, show)
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  local animation = gui:Create("Animation")
  form:Add(animation)
  animation.Visible = false
  local controlitem = form:Find(controlitem_name)
  if nx_is_valid(controlitem) then
    animation.VAnchor = controlitem.VAnchor
    animation.HAnchor = controlitem.HAnchor
    animation.Top = controlitem.Top
    animation.Left = controlitem.Left
    if index == "116" then
      controlitem.BackImage = ani_path
    end
    animation.controlitem_name = controlitem.Name
    animation.show = show
  else
    animation.Top = 0
    animation.Left = 0
  end
  animation.AnimationImage = ani_path
  animation.Loop = false
  nx_bind_script(animation, nx_current())
  nx_callback(animation, "on_animation_end", "animation_new_event_end")
  animation.Visible = true
  animation.index = index
  animation:Stop()
  animation:Play()
  return animation
end
function animation_new_event_end(animation, ani_name, mode)
  if not nx_is_valid(animation) then
    return 1
  end
  local form = animation.ParentForm
  local index = animation.index
  if nx_find_custom(animation, "controlitem_name") and nx_find_custom(animation, "show") then
    local controlitem = form:Find(animation.controlitem_name)
    local sdo_login_interface = nx_value("SdoLoginInterface")
    if nx_is_valid(controlitem) and animation.show == "true" and (not nx_is_valid(sdo_login_interface) or false == sdo_login_interface.ShowLoginDialog) then
      controlitem.Visible = true
    else
      controlitem.Visible = false
    end
    if index == "116" and nx_is_valid(controlitem) then
      animation.AnimationImage = ""
      controlitem.BackImage = "gui\\login\\mdah.png"
    end
  end
  if index == "15" then
    try_login_game(form)
  end
  if index == "116" then
    local login_control = nx_value("login_control")
    if nx_is_valid(login_control) then
      login_control:SetCameraDirect(894, 12.4, 495.7, 0, 3.05, 0)
    end
    local time_count = 0
    while time_count < 1 do
      time_count = time_count + nx_pause(0)
    end
    nx_gen_event(form, "login_return", "ok")
    if nx_is_valid(form) then
      form:Close()
    end
    nx_set_value("login_ready", true)
  end
  if nx_is_valid(animation) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      gui:Delete(animation)
    else
      local world = nx_value("world")
      if nx_is_valid(world) then
        world:Delete(animation)
      end
    end
  end
end
function set_control_ui(control)
  if not nx_is_valid(control) then
    return
  end
  local out_image = get_ini_prop(LOGIN_NEW_INI, control.Name, "out", "")
  local on_image = get_ini_prop(LOGIN_NEW_INI, control.Name, "on", "")
  local down_image = get_ini_prop(LOGIN_NEW_INI, control.Name, "down", "")
  local left = get_ini_prop(LOGIN_NEW_INI, control.Name, "left", "")
  local top = get_ini_prop(LOGIN_NEW_INI, control.Name, "top", "")
  local width = get_ini_prop(LOGIN_NEW_INI, control.Name, "width", "")
  local height = get_ini_prop(LOGIN_NEW_INI, control.Name, "height", "")
  if nx_name(control) == "Label" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "Button" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.PushImage = down_image
    end
  elseif nx_name(control) == "CheckButton" or nx_name(control) == "RadioButton" then
    if out_image ~= "" then
      control.NormalImage = out_image
    end
    if on_image ~= "" then
      control.FocusImage = on_image
    end
    if down_image ~= "" then
      control.CheckedImage = down_image
    end
  elseif nx_name(control) == "GroupBox" or nx_name(control) == "GroupScrollableBox" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  elseif nx_name(control) == "TrackRect" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
    control.TrackButton.NormalImage = get_ini_prop(LOGIN_NEW_INI, "TrackButton", "out", "")
    control.TrackButton.FocusImage = get_ini_prop(LOGIN_NEW_INI, "TrackButton", "on", "")
    control.TrackButton.PushImage = get_ini_prop(LOGIN_NEW_INI, "TrackButton", "down", "")
  elseif nx_name(control) == "Edit" then
    if out_image ~= "" then
      control.BackImage = out_image
    end
  else
    return
  end
  if left ~= "" and top ~= "" then
    control.Left = nx_number(left)
    control.Top = nx_number(top)
  end
  if width ~= "" and height ~= "" then
    control.Width = nx_number(width)
    control.Height = nx_number(height)
  end
end
function reset_back_image(form)
  if not nx_is_valid(form) then
    return
  end
  local ini = nx_execute("util_functions", "get_ini", LOGIN_NEW_INI)
  if not nx_is_valid(ini) then
    return
  end
  local gui = nx_value("gui")
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local sec_name = ini:GetSectionByIndex(i)
    local control = nx_custom(form, sec_name)
    if nx_is_valid(control) then
      set_control_ui(control)
    end
  end
end
function init_video_checked(form)
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    form.cbtn_Video.Checked = true
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  form.cbtn_Video.Checked = nx_boolean(ini:ReadString("login", "show_video", "true"))
  nx_destroy(ini)
end
function on_cbtn_Video_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.Checked then
    form.lbl_video_back.BackImage = ""
    play_video(form, "video\\login.wmv")
  else
    form.video_1:Stop()
    form.video_1.Video = ""
    form.lbl_video_back.BackImage = "gui\\login\\login_zhdl.jpg"
  end
  local game_config = nx_value("game_config")
  local account = game_config.login_account
  local ini = nx_create("IniDocument")
  if not nx_is_valid(ini) then
    return
  end
  ini.FileName = account .. "\\form_main.ini"
  ini:LoadFromFile()
  ini:WriteString("login", "show_video", nx_string(cbtn.Checked))
  ini:SaveToFile()
  nx_destroy(ini)
end
function on_btn_qr_click(btn)
  local form = btn.ParentForm
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  game_config.login_qr = true
  try_login_game(form)
end
function on_btn_qhclose_click(btn)
  local form = btn.ParentForm
  local game_config = nx_value("game_config")
  if not nx_is_valid(game_config) then
    return
  end
  game_config.login_qr = false
  form.groupbox_qr.Visible = false
  form.btn_qr.Enabled = true
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return
  end
  local receiver = sock.Receiver
  if not nx_is_valid(receiver) then
    return
  end
  nx_gen_event(receiver, "event_qr", "cancel")
  nx_gen_event(receiver, "event_login", "cancel")
end
function on_qrcode_show_right_up(qrcode_show)
  local scale = qrcode_show.ZoomMultiple
  scale = scale + 1
  if 5 <= scale then
    scale = 1
  end
  qrcode_show.ZoomMultiple = scale
end
