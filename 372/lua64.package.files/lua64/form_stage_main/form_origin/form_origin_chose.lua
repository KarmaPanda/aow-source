require("util_gui")
require("share\\client_custom_define")
function main_form_init(self)
  self.Fixed = false
  local databinder = nx_value("data_binder")
  databinder:AddTableBind("title_rec", self, nx_current(), "refresh_title_list")
  databinder:AddRolePropertyBind("GuildTitle", "string", self, nx_current(), "refresh_title_list")
end
function on_main_form_open(self)
  refresh_title_list()
end
function on_main_form_close(self)
  self.groupscrollbox_list:DeleteAll()
end
function on_cbtn_checked_changed(self)
  local form = self.ParentForm
  local checked_num = 0
  for i = 1, form.groupscrollbox_list:GetChildControlCount() do
    local groupbox = form.groupscrollbox_list:GetChildControlByIndex(i - 1)
    local cbtn = groupbox:Find("cbtn" .. nx_string(i))
    if cbtn.Checked then
      checked_num = checked_num + 1
    end
  end
  if checked_num == 3 then
    for i = 1, form.groupscrollbox_list:GetChildControlCount() do
      local groupbox = form.groupscrollbox_list:GetChildControlByIndex(i - 1)
      local cbtn = groupbox:Find("cbtn" .. nx_string(i))
      if not cbtn.Checked then
        cbtn.Enabled = false
      end
    end
  end
  if checked_num < 3 then
    for i = 1, form.groupscrollbox_list:GetChildControlCount() do
      local groupbox = form.groupscrollbox_list:GetChildControlByIndex(i - 1)
      local cbtn = groupbox:Find("cbtn" .. nx_string(i))
      cbtn.Enabled = true
    end
  end
  send_to_srv()
  local file_name = "chat.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. "chat.ini"
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    ini:SaveToFile()
  end
  if self.Checked then
    ini:WriteString("title", nx_string(self.TitleID), "false")
  else
    ini:WriteString("title", nx_string(self.TitleID), "true")
  end
  ini:SaveToFile()
  nx_destroy(ini)
  ini = nx_null()
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin_chose")
end
function on_btn_ok_click(btn)
  send_to_srv()
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin_chose")
end
function on_btn_cancel_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_origin\\form_origin_chose")
end
function send_to_srv()
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local str = ""
  for i = 1, form.groupscrollbox_list:GetChildControlCount() do
    local groupbox = form.groupscrollbox_list:GetChildControlByIndex(i - 1)
    local cbtn = groupbox:Find("cbtn" .. nx_string(i))
    if cbtn.Checked then
      str = str .. nx_string(cbtn.TitleID) .. ","
    end
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_CHAT_TITLE), str)
end
function refresh_title_list()
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local chat_title_id_list = client_player:QueryProp("chattitleid")
  local title_id_list = util_split_string(chat_title_id_list, ",")
  local gui = nx_value("gui")
  local groupscrollbox_list = form.groupscrollbox_list
  groupscrollbox_list:DeleteAll()
  local list_titles = get_title_list()
  if nil == list_titles then
    return
  end
  for i = 1, table.maxn(list_titles) do
    local groupbox = gui:Create("GroupBox")
    groupscrollbox_list:Add(groupbox)
    groupbox.Left = form.groupbox_base.Left
    groupbox.Top = form.groupbox_base.Top + (i - 1) * form.groupbox_base.Height
    groupbox.Height = form.groupbox_base.Height
    groupbox.Width = form.groupbox_base.Width
    groupbox.BackColor = form.groupbox_base.BackColor
    groupbox.ShadowColor = form.groupbox_base.ShadowColor
    groupbox.NoFrame = form.groupbox_base.NoFrame
    groupbox.DrawMode = form.groupbox_base.DrawMode
    groupbox.AutoSize = form.groupbox_base.AutoSize
    groupbox.BackImage = form.groupbox_base.BackImage
    local cbtn = gui:Create("CheckButton")
    groupbox:Add(cbtn)
    cbtn.BoxSize = form.cbtn_base.BoxSize
    cbtn.NormalImage = form.cbtn_base.NormalImage
    cbtn.FocusImage = form.cbtn_base.FocusImage
    cbtn.CheckedImage = form.cbtn_base.CheckedImage
    cbtn.DisableImage = form.cbtn_base.DisableImage
    cbtn.NormalColor = form.cbtn_base.NormalColor
    cbtn.FocusColor = form.cbtn_base.FocusColor
    cbtn.PushColor = form.cbtn_base.PushColor
    cbtn.DisableColor = form.cbtn_base.DisableColor
    cbtn.Left = form.cbtn_base.Left
    cbtn.Top = form.cbtn_base.Top
    cbtn.Width = form.cbtn_base.Width
    cbtn.Height = form.cbtn_base.Height
    cbtn.BackColor = form.cbtn_base.BackColor
    cbtn.ShadowColor = form.cbtn_base.ShadowColor
    cbtn.AutoSize = form.cbtn_base.AutoSize
    cbtn.TitleID = list_titles[i]
    cbtn.Name = "cbtn" .. nx_string(i)
    nx_bind_script(cbtn, nx_current())
    nx_callback(cbtn, "on_checked_changed", "on_cbtn_checked_changed")
    local lbl = gui:Create("Label")
    groupbox:Add(lbl)
    lbl.RefCursor = form.lbl_base.RefCursor
    lbl.Left = form.lbl_base.Left
    lbl.Top = form.lbl_base.Top
    lbl.Width = form.lbl_base.Width
    lbl.Height = form.lbl_base.Height
    lbl.ForeColor = form.lbl_base.ForeColor
    lbl.ShadowColor = form.lbl_base.ShadowColor
    lbl.Font = form.lbl_base.Font
    lbl.Text = nx_widestr(util_text("role_title_" .. nx_string(list_titles[i])))
    local lbl_ani = gui:Create("Label")
    groupbox:Add(lbl_ani)
    lbl_ani.BackImage = "chat_title_" .. nx_string(list_titles[i])
    lbl_ani.Left = form.ani_base.Left
    lbl_ani.Top = form.ani_base.Top
    lbl_ani.Width = form.ani_base.Width
    lbl_ani.Height = form.ani_base.Height
  end
  groupscrollbox_list.IsEditMode = false
  groupscrollbox_list:ResetChildrenYPos()
  local checked_num = 0
  for i = 1, groupscrollbox_list:GetChildControlCount() do
    local groupbox = groupscrollbox_list:GetChildControlByIndex(i - 1)
    local cbtn = groupbox:Find("cbtn" .. nx_string(i))
    cbtn.Checked = false
    for j = 1, table.maxn(title_id_list) - 1 do
      if nx_string(cbtn.TitleID) == nx_string(title_id_list[j]) then
        cbtn.Checked = true
        checked_num = checked_num + 1
      end
    end
  end
  if 3 <= checked_num then
    return
  end
  for i = 1, groupscrollbox_list:GetChildControlCount() do
    local groupbox = groupscrollbox_list:GetChildControlByIndex(i - 1)
    local cbtn = groupbox:Find("cbtn" .. nx_string(i))
    if not cbtn.Checked and not is_saved(cbtn.TitleID) then
      cbtn.Checked = true
      checked_num = checked_num + 1
      if checked_num == 3 then
        return
      end
    end
  end
end
function get_title_list()
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local list_titles = {}
  local form_main_chat = nx_value("form_main_chat")
  if not nx_is_valid(form_main_chat) then
    return
  end
  local row_count = client_player:GetRecordRows("title_rec")
  for r = 0, row_count - 1 do
    local rec_title = client_player:QueryRecord("title_rec", r, 0)
    if form_main_chat:IsNeedTitlePic(rec_title) then
      table.insert(list_titles, rec_title)
    end
  end
  local guild_title = client_player:QueryProp("GuildTitle")
  if "ui_guild_pos_level1_name" == nx_string(guild_title) then
    table.insert(list_titles, 10001)
  elseif "ui_guild_pos_level2_name" == nx_string(guild_title) then
    table.insert(list_titles, 10002)
  end
  return list_titles
end
function is_saved(title_id)
  local file_name = "chat.ini"
  local game_config = nx_value("game_config")
  if nx_is_valid(game_config) and nx_find_property(game_config, "login_account") then
    local account = game_config.login_account
    file_name = account .. "\\" .. "chat.ini"
  end
  local ini = nx_create("IniDocument")
  ini.FileName = file_name
  if not ini:LoadFromFile() then
    nx_destroy(ini)
    ini = nx_null()
    return false
  end
  local is_need = ini:ReadString("title", nx_string(title_id), "")
  nx_destroy(ini)
  ini = nx_null()
  return is_need == "true"
end
