require("share\\server_custom_define")
require("define\\sysinfo_define")
require("share\\chat_define")
function main_form_init(form)
  form.Fixed = false
  form.allow_empty = true
  form.no_need_motion_alpha = true
end
function main_form_open(form)
  local gui = nx_value("gui")
  gui.Focused = form.ipt_1
  return 1
end
function on_btn_1_click(self)
  local gui = nx_value("gui")
  local form = self.Parent
  local txt_id = nx_string(form.ipt_1.Text)
  local test_txt = gui.TextManager:GetFormatText(txt_id, nx_widestr("\178\206\202\253\210\187"), nx_widestr("\178\206\202\253\182\254"), nx_widestr("\178\206\202\253\200\253"), nx_widestr("\178\206\202\253\203\196"), nx_widestr("\178\206\202\253\206\229"), nx_widestr("\178\206\202\253\193\249"))
  local sysinfosort = nx_value("SysInfoSort")
  local show_channels = sysinfosort:FindSysInfoStylesByID(txt_id)
  local channel_cnt = table.getn(show_channels)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local form_main_sysinfo_logic = nx_value("form_main_sysinfo")
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_number(channel_cnt) == 0 then
    if nx_is_valid(form_main_sysinfo_logic) then
      form_main_sysinfo_logic:AddSystemInfo(test_txt, SYSTYPE_SYSTEM, 0)
    end
  else
    for index = 1, nx_number(channel_cnt) do
      local channel_type = show_channels[index]
      if nx_int(channel_type) == nx_int(1) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(test_txt, CENTERINFO_WORLD)
        end
      elseif nx_int(channel_type) == nx_int(2) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(test_txt, CENTERINFO_PERSONAL_NO)
        end
      elseif nx_int(channel_type) == nx_int(3) then
        form_main_chat_logic:AddChatInfoEx(test_txt, CHATTYPE_SYSTEM, false)
      elseif nx_int(channel_type) == nx_int(4) then
        if nx_is_valid(form_main_sysinfo_logic) then
          form_main_sysinfo_logic:AddSystemInfo(test_txt, SYSTYPE_SYSTEM, 0)
        end
      elseif nx_int(channel_type) == nx_int(5) then
        if nx_is_valid(form_main_sysinfo_logic) then
          form_main_sysinfo_logic:AddSystemInfo(test_txt, SYSTYPE_FIGHT, 0)
        end
      elseif nx_int(channel_type) == nx_int(6) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(test_txt, CENTERINFO_PERSONAL_YES)
        end
      elseif nx_int(channel_type) == nx_int(7) then
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(test_txt, CENTERINFO_SNS_FRIEND)
        end
      elseif nx_int(channel_type) == nx_int(8) and nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(test_txt, CENTERINFO_PERSONAL)
      end
    end
  end
  return 1
end
function on_btn_2_click(self)
  local form = self.Parent
  nx_gen_event(form, "test_action_return", "cancel")
  form:Close()
  nx_destroy(form)
end
