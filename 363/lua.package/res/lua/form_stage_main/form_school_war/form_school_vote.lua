require("util_functions")
require("util_gui")
require("util_vip")
VoteZhangmen = 13
ChangeVoteDesc = 14
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_votezhangmen_click(btn)
  local form = btn.ParentForm
  if not CheckRight() then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_schoolcontest_prompt_1")
  gui.TextManager:Format_AddParam(form.lbl_zhangmenname.Text)
  local Text = nx_widestr(gui.TextManager:Format_GetText())
  dialog.mltbox_info.HtmlText = Text
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_request_school_pose_fight", VoteZhangmen, 0)
  end
end
function on_btn_editzhanglaodesc_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local Text = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_schoolcontest_prompt_4")))
  dialog.mltbox_info.HtmlText = Text
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_request_school_pose_fight", ChangeVoteDesc, form.redit_zhanglao.Text)
  end
end
function on_btn_votezhanglao_click(btn)
  local form = btn.ParentForm
  if not CheckRight() then
    return
  end
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_schoolcontest_prompt_1")
  gui.TextManager:Format_AddParam(form.lbl_zhanglaoname.Text)
  local Text = nx_widestr(gui.TextManager:Format_GetText())
  dialog.mltbox_info.HtmlText = Text
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_request_school_pose_fight", VoteZhangmen, 1)
  end
end
function on_btn_editzhangmendesc_click(btn)
  local form = btn.ParentForm
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  local Text = nx_widestr(gui.TextManager:GetFormatText(nx_string("ui_schoolcontest_prompt_4")))
  dialog.mltbox_info.HtmlText = Text
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_request_school_pose_fight", ChangeVoteDesc, form.redit_zhangmen.Text)
  end
end
function CheckRight()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  if is_vip(client_player, VT_NORMAL) and client_player:QueryProp("PowerLevel") >= 26 then
    return true
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "chat_vip")
  if not nx_is_valid(dialog) then
    return false
  end
  local gui = nx_value("gui")
  dialog.ok_btn.Text = gui.TextManager:GetText("ui_chat_vip_btn")
  local text = gui.TextManager:GetFormatText("ui_chat_vote_tips")
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == res and not util_is_form_visible("form_stage_main\\form_vip_info") then
    util_auto_show_hide_form("form_stage_main\\form_vip_info")
  end
  return false
end
function show_voteform(zhangmenname, zhangmenvote, zhangmentitle, zhangmendesc, zhanglaoname, zhanglaovote, zhanglaotitle, zhanglaodesc)
  local gui = nx_value("gui")
  local form = util_get_form("form_stage_main\\form_school_war\\form_school_vote", true)
  if not nx_is_valid(form) then
    return
  end
  form.mltbox_votedesc:Clear()
  if gui.TextManager:IsIDName(nx_string(zhangmenname)) then
    zhangmenname = gui.TextManager:GetFormatText(nx_string(zhangmenname))
  end
  if gui.TextManager:IsIDName(nx_string(zhanglaoname)) then
    zhanglaoname = gui.TextManager:GetFormatText(nx_string(zhanglaoname))
  end
  gui.TextManager:Format_SetIDName("ui_schoolcontest_announce")
  gui.TextManager:Format_AddParam(zhangmenname)
  gui.TextManager:Format_AddParam(zhanglaoname)
  form.mltbox_votedesc:AddHtmlText(nx_widestr(gui.TextManager:Format_GetText()), -1)
  form.lbl_zhangmenname.Text = nx_widestr(zhangmenname)
  form.lbl_zhanglaoname.Text = nx_widestr(zhanglaoname)
  local ini = nx_execute("util_functions", "get_ini", "share\\War\\SchoolPose_Info.ini")
  if nx_is_valid(ini) then
    local index = ini:FindSectionIndex(nx_string(zhangmentitle))
    if 0 <= index then
      local postitle = "role_title_" .. ini:ReadString(index, "GetOrigin", "")
      form.lbl_zhangmenoriginname.Text = nx_widestr(gui.TextManager:GetFormatText(postitle))
    end
    index = ini:FindSectionIndex(nx_string(zhanglaotitle))
    if 0 <= index then
      postitle = "role_title_" .. ini:ReadString(index, "GetOrigin", "")
      form.lbl_zhanglaooriginname.Text = nx_widestr(gui.TextManager:GetFormatText(postitle))
    end
  end
  form.lbl_piaonum1.Text = nx_widestr(zhangmenvote)
  form.lbl_piaonum2.Text = nx_widestr(zhanglaovote)
  form.redit_zhangmen.ReadOnly = true
  form.redit_zhanglao.ReadOnly = true
  form.btn_editzhanglaodesc.Visible = false
  form.btn_editzhangmendesc.Visible = false
  local CheckWords = nx_value("CheckWords")
  if not nx_is_valid(CheckWords) then
    return
  end
  local votedesc = CheckWords:CleanWords(nx_widestr(zhangmendesc))
  if nx_widestr(votedesc) == nx_widestr("") then
    votedesc = gui.TextManager:GetFormatText("ui_schoolcontest_manifesto_first")
  end
  form.redit_zhangmen.Text = nx_widestr(votedesc)
  votedesc = CheckWords:CleanWords(nx_widestr(zhanglaodesc))
  if nx_widestr(votedesc) == nx_widestr("") then
    votedesc = gui.TextManager:GetFormatText("ui_schoolcontest_manifesto_first")
  end
  form.redit_zhanglao.Text = nx_widestr(votedesc)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local playname = client_player:QueryProp("Name")
  if playname == zhangmenname then
    form.redit_zhangmen.ReadOnly = false
    form.btn_editzhangmendesc.Visible = true
  end
  if playname == zhanglaoname then
    form.redit_zhanglao.ReadOnly = false
    form.btn_editzhanglaodesc.Visible = true
  end
  util_show_form("form_stage_main\\form_school_war\\form_school_vote", true)
end
