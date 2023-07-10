require("tips_data")
require("util_gui")
require("util_functions")
local FORM_NAME = "form_stage_main\\form_power_guide"
local INI_FILE = "ini\\power_guide.ini"
local EFFECT_ELAPSE = 0.3
function open_form()
  local ST_FUNCTION_POWER_GUIDE = 858
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) then
    return
  end
  if not switch_manager:CheckSwitchEnable(ST_FUNCTION_POWER_GUIDE) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_powerguide_001"))
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
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
  if not condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(29413)) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("sys_powerguide_002"))
    return
  end
  util_auto_show_hide_form(FORM_NAME)
end
function on_main_form_init(form)
  local IniManager = nx_value("IniManager")
  if not IniManager:IsIniLoadedToManager(INI_FILE) then
    IniManager:LoadIniToManager(INI_FILE)
  end
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Left = (gui.Width - form.Width + form.groupbox_sub.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.groupbox_sub.Visible = false
  form.sub_ani_over = true
  form.sel_sub_form = ""
  init_show_btns(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function init_show_btns(form)
  if not nx_is_valid(form) then
    return
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
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
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("visible"))
  if sec_index < 0 then
    return
  end
  local item_count = ini:GetSectionItemCount(sec_index)
  for i = 0, nx_number(item_count) do
    local key = ini:GetSectionItemKey(sec_index, i)
    local var = ini:GetSectionItemValue(sec_index, i)
    if nx_find_custom(form, nx_string(key)) then
      local btn = nx_custom(form, nx_string(key))
      if nx_is_valid(btn) then
        btn.Visible = condition_manager:CanSatisfyCondition(client_player, client_player, nx_int(var))
      end
    end
  end
end
function on_btn_guide_get_capture(btn)
end
function on_btn_guide_lost_capture(btn)
end
function on_btn_guide_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not form.sub_ani_over then
    return
  end
  if form.groupbox_sub.Visible == true then
    if nx_string(form.sel_sub_form) == nx_string(btn.Name) then
      close_sub_form(form, false)
    else
      form.sel_sub_form = nx_string(btn.Name)
      close_sub_form(form, true)
    end
  else
    form.sel_sub_form = nx_string(btn.Name)
    on_refresh_sub_form(form)
  end
end
function get_text_ids(form)
  if not nx_is_valid(form) then
    return ""
  end
  if nx_string(form.sel_sub_form) == nx_string("") then
    return ""
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) then
    return ""
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  local playerschool = client_player:QueryProp("School")
  if nx_string(playerschool) == nx_string("") or nx_string(playerschool) == nx_string(0) then
    playerschool = client_player:QueryProp("NewSchool")
    if nx_string(playerschool) == nx_string("") or nx_string(playerschool) == nx_string(0) then
      playerschool = client_player:QueryProp("Force")
    end
  end
  local key = form.sel_sub_form
  if nx_string(playerschool) ~= nx_string("") and nx_string(playerschool) ~= nx_string("0") then
    key = nx_string(key) .. nx_string(",") .. nx_string(playerschool)
  end
  local ini_step_index = ini:FindSectionIndex(nx_string("step"))
  if ini_step_index < 0 then
    return ""
  end
  local ini_desc_index = ini:FindSectionIndex(nx_string("desc"))
  if ini_desc_index < 0 then
    return ""
  end
  local sec_index = ini:FindSectionIndex(nx_string("link_desc"))
  if sec_index < 0 then
    return ""
  end
  local var = ini:ReadString(sec_index, nx_string(key), "")
  if nx_string(var) == nx_string("") then
    key = form.sel_sub_form
    var = ini:ReadString(sec_index, nx_string(key), "")
    if nx_string(var) == nx_string("") then
      return ""
    end
  end
  local main_step, sub_step = get_game_step()
  if main_step == nil or main_step <= 0 then
    return ""
  end
  local var_array = util_split_string(nx_string(var), ";")
  for i = 1, table.getn(var_array) do
    local tv = var_array[i]
    local tv_array = util_split_string(nx_string(tv), ",")
    if table.getn(tv_array) >= 2 then
      local step_index = tv_array[1]
      local step_var = ini:ReadString(ini_step_index, nx_string(step_index), "")
      local step_condition = false
      local step_var_array = util_split_string(nx_string(step_var), ",")
      if table.getn(step_var_array) == 1 then
        if nx_int(main_step) >= nx_int(step_var_array[1]) then
          step_condition = true
        end
      elseif table.getn(step_var_array) == 2 and step_var_array[2] ~= nil and (nx_int(main_step) > nx_int(step_var_array[1]) or nx_int(step_var_array[1]) == nx_int(main_step) and nx_int(sub_step) >= nx_int(step_var_array[2])) then
        step_condition = true
      end
      if step_condition then
        local tips_index = tv_array[2]
        return ini:ReadString(ini_desc_index, nx_string(tips_index), "")
      end
    end
  end
  return ""
end
function refresh_sub_form_title(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(INI_FILE)
  if not nx_is_valid(ini) then
    return
  end
  local sec_index = ini:FindSectionIndex(nx_string("form_title"))
  if sec_index < 0 then
    return
  end
  local var = ini:ReadString(sec_index, nx_string(form.sel_sub_form), "")
  if nx_string(var) == nx_string("") then
    return
  end
  local text_array = util_split_string(nx_string(var), ",")
  local var_len = table.getn(text_array)
  if 1 <= var_len then
    local text = gui.TextManager:GetFormatText(text_array[1])
    form.lbl_guide_desc.Text = text
  end
  if 2 <= var_len then
    form.lbl_sub_icon.BackImage = nx_string(text_array[2])
  end
end
function on_refresh_sub_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = get_text_ids(form)
  local text_array = util_split_string(nx_string(text), ",")
  refresh_sub_form_title(form)
  form.gsbox_desc:DeleteAll()
  form.gsbox_desc.IsEditMode = true
  for i = 1, table.getn(text_array) do
    local lbl_partition = gui:Create("Label")
    lbl_partition.NoFrame = true
    lbl_partition.Top = 0
    lbl_partition.Left = 0
    lbl_partition.Width = form.gsbox_desc.Width - 35
    lbl_partition.Height = 5
    lbl_partition.DrawMode = "FitWindow"
    form.gsbox_desc:Add(lbl_partition)
    local text = gui.TextManager:GetFormatText(text_array[i])
    local mltbox = gui:Create("MultiTextBox")
    mltbox.NoFrame = true
    mltbox.Font = "font_conten_tasktrace"
    mltbox.TextColor = "255,197,184,159"
    mltbox.SelectBarColor = "0,0,0,0"
    mltbox.MouseInBarColor = "0,0,0,0"
    mltbox.DrawMode = "FitWindow"
    mltbox.Top = form.gsbox_desc.Top
    mltbox.Left = form.gsbox_desc.Left
    mltbox.Width = form.gsbox_desc.Width - 35
    mltbox.ViewRect = "5,5" .. nx_string(mltbox.Width - 10) .. "," .. nx_string(mltbox:GetContentHeight() - 10)
    mltbox:AddHtmlText(text, -1)
    mltbox.ViewRect = "5,5" .. nx_string(mltbox.Width - 10) .. "," .. nx_string(mltbox:GetContentHeight() - 10)
    mltbox.Height = mltbox:GetContentHeight()
    nx_bind_script(mltbox, nx_current())
    nx_callback(mltbox, "on_click_hyperlink", "on_click_hyperlink")
    form.gsbox_desc:Add(mltbox)
  end
  form.gsbox_desc.IsEditMode = false
  form.gsbox_desc:ResetChildrenYPos()
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("ControlMove", form.groupbox_sub) then
    return
  end
  form.groupbox_sub.Top = form.groupbox_main.Top
  form.groupbox_sub.Left = form.groupbox_main.Left + form.groupbox_main.Width - form.groupbox_sub.Width
  form.groupbox_sub.Visible = true
  local top = form.groupbox_main.Top
  local left = form.groupbox_main.Left + form.groupbox_main.Width
  form.groupbox_sub.callback_sp = FORM_NAME
  form.groupbox_sub.callback_func = "mark_effect_finish"
  form.groupbox_sub.is_visible = true
  common_execute:AddExecute("ControlMove", form.groupbox_sub, nx_float(0), nx_float(left), nx_float(top), nx_float(EFFECT_ELAPSE), "")
end
function on_btn_sub_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  close_sub_form(form, false)
end
function close_sub_form(form, reopen)
  if not nx_is_valid(form) then
    return
  end
  if not form.sub_ani_over then
    return
  end
  form.sub_ani_over = false
  local common_execute = nx_value("common_execute")
  if not nx_is_valid(common_execute) then
    return
  end
  if common_execute:FindExecute("ControlMove", form.groupbox_sub) then
    return
  end
  local top = form.groupbox_main.Top
  local left = form.groupbox_main.Left + form.groupbox_main.Width - form.groupbox_sub.Width
  local func_name = ""
  if not reopen then
    func_name = nx_string("mark_effect_finish")
    form.groupbox_sub.is_visible = false
  else
    func_name = nx_string("check_finish_and_open")
  end
  form.groupbox_sub.callback_sp = FORM_NAME
  form.groupbox_sub.callback_func = func_name
  common_execute:AddExecute("ControlMove", form.groupbox_sub, nx_float(0), nx_float(left), nx_float(top), nx_float(EFFECT_ELAPSE), "")
end
function check_finish_and_open()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  local timer = nx_value("timer_game")
  if not nx_is_valid(timer) then
    return
  end
  timer:UnRegister(FORM_NAME, "on_refresh_sub_form", form)
  timer:Register(200, 1, FORM_NAME, "on_refresh_sub_form", form, -1, -1)
end
function mark_effect_finish()
  local form = nx_value(FORM_NAME)
  if not nx_is_valid(form) then
    return
  end
  form.sub_ani_over = true
  form.groupbox_sub.Visible = form.groupbox_sub.is_visible
end
function get_game_step()
  local SwitchManager = nx_value("SwitchManager")
  if not nx_is_valid(SwitchManager) then
    return nil, nil
  end
  local MainGameStep = SwitchManager:GetMainGameStep()
  local SubGameStep = SwitchManager:GetSubGameStep()
  return MainGameStep, SubGameStep
end
function on_click_hyperlink(mltbox, index, data)
  data = nx_string(data)
  local str_lst = nx_function("ext_split_string", data, ",")
  if "open_form" == str_lst[1] then
    if nil ~= str_lst[2] and "" ~= str_lst[2] then
      util_auto_show_hide_form(str_lst[2])
    end
  elseif "search_auction" == str_lst[1] and nil ~= str_lst[2] and "" ~= str_lst[2] then
    nx_execute("form_stage_main\\form_market\\form_market", "open_form_and_search", str_lst[2])
  end
end
