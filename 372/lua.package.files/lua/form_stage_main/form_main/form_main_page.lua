require("util_functions")
require("share\\chat_define")
require("util_gui")
require("define\\sysinfo_define")
FORM_MAIN_CHAT = "form_stage_main\\form_main\\form_main_chat"
FORM_MAIN_PAGE = "form_stage_main\\form_main\\form_main_page"
function console_log_down(info)
  local console = nx_value("console")
  if nx_is_valid(console) then
    console:Out(info)
  end
end
function main_form_init(self)
  self.Fixed = false
  return 1
end
function on_main_form_open(self)
end
function on_main_form_close(self)
end
function on_btn_yes_click(btn)
  local page_form = nx_value(FORM_MAIN_PAGE)
  if not nx_is_valid(page_form) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  local page_name = page_form.ipt_name.Text
  if nx_string(page_name) == nx_string("") then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("11017"), CENTERINFO_PERSONAL_NO)
    end
    page_form.Visible = false
    return
  end
  if string.find(nx_string(page_name), ";") or string.find(nx_string(page_name), ":") or string.find(nx_string(page_name), ",") then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("19451"), CENTERINFO_PERSONAL_NO)
    end
    page_form.Visible = false
    return
  end
  local old_name
  if nx_find_custom(page_form.ipt_name, "OldText") then
    old_name = page_form.ipt_name.OldText
  end
  if old_name == nil and isExistEx(page_name) then
    nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, nx_string("2410"))
    page_form.Visible = false
    return
  end
  local is_show = false
  for i = 1, 20 do
    local control_name = "cbtn_" .. nx_string(i)
    local check_button = page_form.groupbox_1:Find(control_name)
    if nx_is_valid(check_button) and not is_show then
      is_show = check_button.Checked
    end
  end
  if not is_show then
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(util_text("11016"), CENTERINFO_PERSONAL_NO)
    end
    page_form.Visible = false
    return
  end
  local form_chat = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form_chat) then
    page_form.Visible = false
    return
  end
  local new_page_chat
  local rbtn_page = page_form.rbtn_page
  if nx_is_valid(rbtn_page) then
    new_page_chat = rbtn_page.page_chat
  else
    new_page_chat = nx_execute(FORM_MAIN_CHAT, "add_chat_page", form_chat, nx_widestr(page_name))
    if nx_is_valid(new_page_chat) then
      new_page_chat.need_save = true
    end
  end
  if not nx_is_valid(new_page_chat) then
    page_form.Visible = false
    return
  end
  refresh_channel_info(page_form, new_page_chat)
  new_page_chat.page_btn.Text = page_name
  if nx_find_custom(new_page_chat, "need_save") and new_page_chat.need_save then
    save_pageEx(page_name, old_name, new_page_chat.page_btn)
  end
  if nx_find_custom(page_form, "set_system_info") and page_form.set_system_info then
    new_page_chat:ShowKeyItems(nx_int(CHATTYPE_SYSTEM))
  end
  page_form.Visible = false
end
function on_btn_no_click(btn)
  local page_form = nx_value(FORM_MAIN_PAGE)
  if nx_is_valid(page_form) then
    page_form.Visible = false
  end
end
function refresh_channel_info(page_form, new_page_chat)
  if not nx_is_valid(new_page_chat) then
    return
  end
  local new_page_btn = new_page_chat.page_btn
  new_page_chat:ShowKeyItems(nx_int(-1))
  if nx_is_valid(new_page_btn) then
    for i = 1, 20 do
      local control_name = "cbtn_" .. nx_string(i)
      local check_button = page_form.groupbox_1:Find(control_name)
      if nx_is_valid(check_button) then
        local is_show = check_button.Checked
        nx_set_custom(new_page_btn, "chat_enable_" .. check_button.DataSource, is_show)
        if is_show then
          new_page_chat:ShowKeyItems(nx_int(check_button.DataSource))
        end
      end
    end
  end
  new_page_chat:GotoEnd()
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  form.Visible = true
  form.ipt_name.Text = nx_widestr(util_text("ui_xinjian"))
  form.ipt_name.MaxLength = 3
  local gui = nx_value("gui")
  local width = gui.Desktop.Width
  local height = gui.Desktop.Height
  form.Left = (width - form.Width) / 2
  form.Top = (height - form.Height) / 2
  form:Show()
end
function init_check_btns(rbtn_page)
  local gui = nx_value("gui")
  local form = nx_value(FORM_MAIN_PAGE)
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_1.Checked = false
  form.cbtn_2.Checked = false
  form.cbtn_3.Checked = false
  form.cbtn_4.Checked = false
  form.cbtn_5.Checked = false
  form.cbtn_6.Checked = false
  form.cbtn_7.Checked = false
  form.cbtn_8.Checked = false
  form.cbtn_9.Checked = false
  form.cbtn_12.Checked = false
  form.cbtn_13.Checked = false
  form.cbtn_14.Checked = false
  form.cbtn_15.Checked = false
  form.cbtn_16.Checked = false
  form.cbtn_17.Checked = false
  form.cbtn_19.Checked = false
  form.cbtn_20.Checked = false
  form.ipt_name.ReadOnly = false
  form.ipt_name.OldText = nil
  local prop_name = ""
  local control_name = ""
  local lbl_name = ""
  local check_button, lbl
  local text = ""
  local channel = 0
  for i = 1, table.getn(chat_zonghe_set) do
    channel = nx_int(chat_zonghe_set[i])
    prop_name = "chat_enable_" .. nx_string(channel)
    control_name = "cbtn_" .. nx_string(i)
    check_button = form.groupbox_1:Find(control_name)
    if nx_is_valid(check_button) then
      check_button.DataSource = nx_string(channel)
      if nx_is_valid(rbtn_page) then
        check_button.Checked = nx_custom(rbtn_page, prop_name)
      end
    end
    lbl_name = "lbl_" .. nx_string(i)
    lbl = form.groupbox_1:Find(lbl_name)
    if nx_is_valid(lbl) then
      text = "ui_chat_channel_" .. nx_string(channel)
      lbl.Text = nx_widestr(gui.TextManager:GetFormatText(text))
    end
  end
  if nx_is_valid(rbtn_page) then
    text = nx_widestr(rbtn_page.Text)
    if string.find(nx_string(text), "@") ~= nil then
      form.ipt_name.ReadOnly = true
      text = string.sub(nx_string(text), 2, -1)
      text = nx_widestr(gui.TextManager:GetFormatText(nx_string(text)))
    end
    if nx_find_custom(rbtn_page, "page_type") and nx_int(rbtn_page.page_type) == nx_int(CHATTYPE_GUILD) then
      form.ipt_name.ReadOnly = true
      form.cbtn_1.Enabled = false
      form.cbtn_2.Enabled = false
      form.cbtn_3.Enabled = false
      form.cbtn_4.Enabled = true
      form.cbtn_5.Enabled = false
      form.cbtn_6.Enabled = false
      form.cbtn_7.Enabled = false
      form.cbtn_8.Enabled = false
      form.cbtn_9.Enabled = false
      form.cbtn_10.Enabled = false
      form.cbtn_12.Enabled = false
      form.cbtn_13.Enabled = false
      form.cbtn_14.Enabled = false
      form.cbtn_15.Enabled = false
      form.cbtn_16.Enabled = false
      form.cbtn_17.Enabled = false
      form.cbtn_18.Enabled = false
      form.cbtn_19.Enabled = true
    else
      form.cbtn_1.Enabled = true
      form.cbtn_2.Enabled = true
      form.cbtn_3.Enabled = true
      form.cbtn_4.Enabled = true
      form.cbtn_5.Enabled = true
      form.cbtn_6.Enabled = true
      form.cbtn_7.Enabled = true
      form.cbtn_8.Enabled = true
      form.cbtn_9.Enabled = true
      form.cbtn_10.Enabled = true
      form.cbtn_12.Enabled = true
      form.cbtn_13.Enabled = true
      form.cbtn_14.Enabled = true
      form.cbtn_15.Enabled = true
      form.cbtn_16.Enabled = true
      form.cbtn_17.Enabled = true
      form.cbtn_18.Enabled = true
      form.cbtn_19.Enabled = true
    end
    form.ipt_name.Text = nx_widestr(text)
    form.ipt_name.OldText = nx_widestr(text)
  end
end
function load_page_infoEx()
  local form_chat = nx_value(FORM_MAIN_CHAT)
  if not nx_is_valid(form_chat) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local page_config = nx_widestr("")
  if client_player:FindProp("ChatPage") then
    page_config = client_player:QueryProp("ChatPage")
  end
  if nx_ws_equal(nx_widestr(page_config), nx_widestr("")) then
    return
  end
  local new_page_chat
  local page_table = util_split_wstring(nx_widestr(page_config), ";")
  for i = 1, table.getn(page_table) do
    sub_config = page_table[i]
    sub_table = util_split_wstring(nx_widestr(sub_config), ":")
    if not nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr("def")) then
      local section = nx_widestr(sub_table[1])
      new_page_chat = nx_execute(FORM_MAIN_CHAT, "add_chat_page", form_chat, section)
      if nx_is_valid(new_page_chat) then
        new_page_chat.need_save = true
        new_page_chat:ShowKeyItems(-1)
        local new_page_btn = new_page_chat.page_btn
        if nx_is_valid(new_page_btn) then
          local key_config = sub_table[2]
          if not nx_ws_equal(nx_widestr(key_config), nx_widestr("")) then
            for j = 1, table.getn(chat_zonghe_set) do
              nx_set_custom(new_page_btn, "chat_enable_" .. nx_string(chat_zonghe_set[j]), false)
            end
            local key_table = util_split_wstring(nx_widestr(key_config), ",")
            for j = 1, table.getn(key_table) do
              nx_set_custom(new_page_btn, "chat_enable_" .. nx_string(key_table[j]), true)
              new_page_chat:ShowKeyItems(nx_int(key_table[j]))
            end
          end
        end
      end
    end
  end
  sub_config = page_table[1]
  sub_table = util_split_wstring(nx_widestr(sub_config), ":")
  if nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr("def")) then
    local index = nx_int(sub_table[2])
    if nx_int(index) == nx_int(0) then
      form_chat.btn_channel.Checked = true
    else
      local btn = form_chat.groupbox_pagebtn:Find("new_page_button" .. nx_string(index))
      if nx_is_valid(btn) then
        btn.Checked = true
      end
    end
  else
    local index = 0
    form_chat.btn_channel.Checked = true
  end
end
function delete_pageEx(section_name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local page_config = nx_widestr("")
  if client_player:FindProp("ChatPage") then
    page_config = client_player:QueryProp("ChatPage")
  end
  if nx_ws_equal(nx_widestr(page_config), nx_widestr("")) then
    return
  end
  local page_table = util_split_wstring(nx_widestr(page_config), ";")
  local page_index = -1
  for i = 1, table.getn(page_table) do
    local sub_config = page_table[i]
    local sub_table = util_split_wstring(nx_widestr(sub_config), ":")
    if nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr(section_name)) then
      page_index = i
    end
  end
  if nx_int(page_index) ~= nx_int(-1) then
    for i = page_index, table.getn(page_table) - 1 do
      page_table[i] = page_table[i + 1]
    end
    page_table[table.getn(page_table)] = nil
  end
  local config = get_config_string(page_table)
  nx_execute("custom_sender", "custom_save_chatpage_config", config)
end
function save_pageEx(section_name, old_name, rbtn_page)
  if not nx_is_valid(rbtn_page) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local channel = 0
  local prop_name = ""
  local cur_config = nx_widestr(section_name) .. nx_widestr(":")
  for i = 1, table.getn(chat_zonghe_set) do
    channel = nx_int(chat_zonghe_set[i])
    prop_name = "chat_enable_" .. nx_string(channel)
    local is_show = nx_custom(rbtn_page, prop_name)
    if is_show then
      cur_config = cur_config .. nx_widestr(channel) .. nx_widestr(",")
    end
  end
  cur_config = nx_function("ext_ws_trim_right", cur_config, nx_widestr(","))
  local page_config = nx_widestr("")
  if client_player:FindProp("ChatPage") then
    page_config = client_player:QueryProp("ChatPage")
  end
  local page_table = {}
  if not nx_ws_equal(nx_widestr(page_config), nx_widestr("")) then
    page_table = util_split_wstring(nx_widestr(page_config), ";")
    local exist_name = ""
    if old_name ~= nil then
      exist_name = old_name
    else
      exist_name = section_name
    end
    local conf_index = 0
    for i = 1, table.getn(page_table) do
      local sub_config = page_table[i]
      local sub_table = util_split_wstring(nx_widestr(sub_config), ":")
      if nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr(exist_name)) then
        conf_index = i
        break
      end
    end
    if nx_int(conf_index) ~= nx_int(0) then
      page_table[conf_index] = nx_widestr(cur_config)
    else
      page_table[table.getn(page_table) + 1] = nx_widestr(cur_config)
    end
  else
    page_table[1] = nx_widestr(cur_config)
  end
  local config = get_config_string(page_table)
  nx_execute("custom_sender", "custom_save_chatpage_config", config)
end
function isExistEx(name)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local page_config = nx_widestr("")
  if client_player:FindProp("ChatPage") then
    page_config = client_player:QueryProp("ChatPage")
  end
  local page_table = {}
  if not nx_ws_equal(nx_widestr(page_config), nx_widestr("")) then
    page_table = util_split_wstring(nx_widestr(page_config), ";")
    for i = 1, table.getn(page_table) do
      local sub_config = page_table[i]
      local sub_table = util_split_wstring(nx_widestr(sub_config), ":")
      if nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr(name)) then
        return true
      end
    end
  end
  return false
end
function set_default_page(index)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local page_config = nx_widestr("")
  if client_player:FindProp("ChatPage") then
    page_config = client_player:QueryProp("ChatPage")
  end
  local page_table = {}
  if not nx_ws_equal(nx_widestr(page_config), nx_widestr("")) then
    page_table = util_split_wstring(nx_widestr(page_config), ";")
    sub_config = nx_widestr(page_table[1])
    sub_table = util_split_wstring(nx_widestr(sub_config), ":")
    if not nx_ws_equal(nx_widestr(sub_table[1]), nx_widestr("def")) then
      for i = table.getn(page_table), 1 do
        page_table[i + 1] = page_table[i]
      end
    end
  end
  page_table[1] = nx_widestr("def:" .. index)
  local config = get_config_string(page_table)
  nx_execute("custom_sender", "custom_save_chatpage_config", config)
end
function get_config_string(page_table)
  local config = ""
  local beginindex = 1
  local page_index = 0
  local form_main_chat = nx_value(FORM_MAIN_CHAT)
  if nx_is_valid(form_main_chat) then
    page_index = nx_int(form_main_chat.cur_info_page)
  end
  config = nx_widestr(config .. "def:" .. nx_string(page_index) .. ";")
  local def_table = util_split_wstring(nx_widestr(page_table[1]), ":")
  if not nx_ws_equal(nx_widestr(def_table[1]), nx_widestr("def")) then
    beginindex = 1
  else
    beginindex = 2
  end
  for i = beginindex, table.getn(page_table) do
    config = config .. nx_widestr(page_table[i]) .. nx_widestr(";")
  end
  config = nx_function("ext_ws_trim_right", config, nx_widestr(";"))
  return config
end
function Open(rbtn_page)
  local page_form = nx_value(FORM_MAIN_PAGE)
  if nx_is_valid(page_form) then
  else
    page_form = nx_execute("util_gui", "util_get_form", FORM_MAIN_PAGE, true, false)
  end
  page_form.rbtn_page = rbtn_page
  init_form(page_form)
  init_check_btns(rbtn_page)
end
