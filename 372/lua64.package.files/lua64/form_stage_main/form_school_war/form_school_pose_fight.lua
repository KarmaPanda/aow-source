require("util_functions")
require("util_gui")
require("define\\gamehand_type")
PhaseNone = 0
PhaseSignUpFreePK = 1
PhaseGetReadyFreePK = 2
PhaseFreePK = 3
PhaseGetReadyZhiShiPK = 4
PhaseZhiShiPK = 5
PhaseGetReadyZhangLaoPK = 6
PhaseZhangLaoPK = 7
PhaseGetReadyZhangMenRightPK = 8
PhaseZhangMenRightPK = 9
PhaseZhangVote = 10
FreePKSignUp = 0
GiveUpFreePK = 1
JoinFreePK = 2
GiveUpZhiShiPK = 3
JoinZhiShiPK = 4
GiveUpZhangLaoPK = 5
JoinZhangLaoPK = 6
GiveUpZhanMenRightPK = 7
JoinZhanMenRightPK = 8
GiveUpZhangMenPK = 9
JoinZhangMenPK = 10
GiveUpRisingPK = 11
JoinRisingPK = 12
VoteZhangmen = 13
function on_school_pose_fight_msg(submsg_type, ...)
  local gui = nx_value("gui")
  if submsg_type == PhaseFreePK then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    dialog.mltbox_info:Clear()
    local Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_freepk"))
    dialog.mltbox_info:AddHtmlText(Text, -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_school_pose_fight(JoinFreePK, 1)
    else
      custom_request_school_pose_fight(JoinFreePK, 0)
    end
  elseif submsg_type == PhaseZhiShiPK then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    dialog.mltbox_info:Clear()
    local Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_zhishipk"))
    dialog.mltbox_info:AddHtmlText(Text, -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_school_pose_fight(JoinZhiShiPK, 1)
    else
      custom_request_school_pose_fight(JoinZhiShiPK, 0)
    end
  elseif submsg_type == PhaseZhangLaoPK then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    dialog.mltbox_info:Clear()
    local Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_zhanglaopk"))
    dialog.mltbox_info:AddHtmlText(Text, -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_school_pose_fight(JoinZhangLaoPK, 1)
    else
      custom_request_school_pose_fight(JoinZhangLaoPK, 0)
    end
  elseif submsg_type == PhaseZhangMenRightPK then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    dialog.mltbox_info:Clear()
    local Text = nx_widestr(gui.TextManager:GetFormatText("ui_schoolpose_zhangmenrightpk"))
    dialog.mltbox_info:AddHtmlText(Text, -1)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_school_pose_fight(JoinZhanMenRightPK, 1)
    else
      custom_request_school_pose_fight(JoinZhanMenRightPK, 0)
    end
  elseif submsg_type == PhaseZhangVote then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    dialog.mltbox_info:Clear()
    local Text = nx_widestr("\196\227\209\161\203\173\215\247\213\198\195\197" .. nx_string(arg[1]) .. "\187\185\202\199" .. nx_string(arg[2]))
    dialog.mltbox_info:AddHtmlText(Text, -1)
    dialog.ok_btn.Text = nx_widestr(arg[1])
    dialog.cancel_btn.Text = nx_widestr(arg[2])
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      custom_request_school_pose_fight(VoteZhangmen, 1)
    else
      custom_request_school_pose_fight(VoteZhangmen, 0)
    end
  end
end
function custom_request_school_pose_fight(submsg_type, ...)
  nx_execute("custom_sender", "custom_request_school_pose_fight", submsg_type, unpack(arg))
end
