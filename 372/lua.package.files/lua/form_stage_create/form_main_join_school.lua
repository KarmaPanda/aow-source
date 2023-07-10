require("util_gui")
require("login_scene")
require("util_functions")
require("share\\client_custom_define")
require("tips_data")
function on_main_form_init(form)
  form.Fixed = true
  form.select_job = ""
end
function on_main_form_open(form)
  change_form_size()
  init_form()
end
function on_main_form_close(form)
  local IniManager = nx_value("IniManager")
  if nx_is_valid(IniManager) then
    IniManager:UnloadIniFromManager("ini\\form\\school_join.ini")
  end
  nx_destroy(form)
end
function on_rbtn_junzi_checked_changed(rbtn)
  local form = rbtn.ParentForm
  if rbtn.DataSource == "" then
    return
  end
  if rbtn.Checked then
    form.select_job = nx_string(rbtn.DataSource)
    form.btn_enter.Enabled = true
  end
end
function on_cbtn_gai_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if cbtn.DataSource == "" then
    return
  end
  if cbtn.Checked then
    form.select_job = nx_string(cbtn.DataSource)
    form.btn_enter.Enabled = true
  else
    form.select_job = ""
    form.btn_enter.Enabled = false
  end
end
function on_btn_enter_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("SelectSchool") then
    local school = client_player:QueryProp("SelectSchool")
    if school == "" then
      return
    elseif (school == "school_junzitang" or school == "school_gaibang") and form.select_job == "" then
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUIDE_ADD_SCHOOL), 3, nx_string(school), nx_string(form.select_job))
    form:Close()
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function change_form_size()
  local form = nx_value("form_stage_create\\form_main_join_school")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function init_form()
  local form = nx_value("form_stage_create\\form_main_join_school")
  if not nx_is_valid(form) then
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
  if client_player:FindProp("SelectSchool") then
    local school = client_player:QueryProp("SelectSchool")
    local title_icon = get_ini_prop("ini\\form\\school_join.ini", school, "Title_icon", "")
    local school_name = get_ini_prop("ini\\form\\school_join.ini", school, "school_name", "")
    local school_text = get_ini_prop("ini\\form\\school_join.ini", school, "school_text", "")
    local school_condition = get_ini_prop("ini\\form\\school_join.ini", school, "school_condition", "")
    form.mltbox_desc:Clear()
    form.mltbox_desc:AddHtmlText(util_text(school_text), -1)
    form.lbl_school_name.Text = util_text(school_name)
    form.lbl_title.BackImage = title_icon
    form.mltbox_condition.Visible = false
    form.btn_enter.Enabled = false
    if school == "school_junzitang" then
      form.groupbox_juzi.Visible = true
      form.groupbox_gaibang.Visible = false
      form.lbl_finish.Visible = false
      form.mltbox_juzi:Clear()
      form.mltbox_juzi:AddHtmlText(util_text(school_condition), -1)
    elseif school == "school_gaibang" then
      form.groupbox_juzi.Visible = false
      form.groupbox_gaibang.Visible = true
      form.lbl_finish.Visible = false
      form.mltbox_gai:Clear()
      form.mltbox_gai:AddHtmlText(util_text(school_condition), -1)
    else
      form.groupbox_juzi.Visible = false
      form.groupbox_gaibang.Visible = false
      form.lbl_finish.Visible = true
      form.mltbox_condition:Clear()
      form.mltbox_condition:AddHtmlText(util_text(school_condition), -1)
      form.mltbox_condition.Visible = true
      form.btn_enter.Enabled = true
    end
  end
end
function open_form()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("SelectSchool") and client_player:QueryProp("SelectSchool") ~= "" then
    local form = util_get_form("form_stage_create\\form_main_join_school", true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
  end
end
function on_btn_study_click(btn)
  local form = btn.ParentForm
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  if client_player:FindProp("SelectSchool") then
    local school = client_player:QueryProp("SelectSchool")
    if school == "" then
      return
    elseif (school == "school_junzitang" or school == "school_gaibang") and form.select_job == "" then
      return
    end
    local game_visual = nx_value("game_visual")
    if not nx_is_valid(game_visual) then
      return
    end
    game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUIDE_ADD_SCHOOL), 4, nx_string(school), nx_string(form.select_job))
    form:Close()
  end
end
