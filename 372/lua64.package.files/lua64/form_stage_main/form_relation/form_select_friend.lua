require("util_gui")
require("util_functions")
require("game_object")
local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
local BROTHER_REC = "rec_brother"
local ATTENTION_REC = "rec_attention"
local FRIEND_REC_UID = 0
local FRIEND_REC_NAME = 1
local FRIEND_REC_PHOTO = 2
local FRIEND_REC_CHENGHAO = 3
local FRIEND_REC_LEVEL = 4
local FRIEND_REC_MENPAI = 5
local FRIEND_REC_BANGPAI = 6
local FRIEND_REC_XINQING = 7
local FRIEND_REC_ONLINE = 8
local FRIEND_REC_SCENE = 9
local FRIEND_REC_MODEL = 10
function main_form_init(self)
  self.Fixed = true
  self.SelectPlayerNames = ""
  self.Visible = false
  self.IsExistGuanZhu = false
  return 1
end
function init(form)
  local gui = nx_value("gui")
  form.cb_type.DropListBox:ClearString()
  form.cb_type.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_haoyou")))
  form.cb_type.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_zhiyou")))
  if form.IsExistGuanZhu then
    form.cb_type.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_guanzhu")))
  end
  form.cb_type.OnlySelect = true
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  form.cb_type.InputEdit.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_haoyou"))
  show_friend_relation(form, client_role, FRIEND_REC, 0)
  show_friend_relation(form, client_role, BUDDY_REC, 1)
  show_friend_relation(form, client_role, ATTENTION_REC, 2)
  form.gsb_playerList_friend.Visible = true
  form.gsb_playerList_zhiyou.Visible = false
  form.gsb_playerList_guanzhu.Visible = false
end
function main_form_open(self)
  local gui = nx_value("gui")
  init(self)
  return 1
end
function on_main_form_close(self)
  self.Visible = false
  nx_destroy(self)
end
function is_check(SelectPlayerNames, playerName)
  local table_player_names = util_split_wstring(nx_widestr(SelectPlayerNames), nx_widestr(","))
  for i = 1, table.getn(table_player_names) do
    if nx_ws_equal(nx_widestr(table_player_names[i]), nx_widestr(playerName)) then
      return true
    end
  end
  return false
end
function on_cb_type_selected(btn)
  local SelectIndex = btn.DropListBox.SelectIndex
  if nx_number(SelectIndex) == -1 then
    return
  end
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  local form = btn.ParentForm
  form.gsb_playerList_friend.Visible = false
  form.gsb_playerList_zhiyou.Visible = false
  form.gsb_playerList_guanzhu.Visible = false
  if nx_number(SelectIndex) == 0 then
    form.gsb_playerList_friend.Visible = true
  elseif nx_number(SelectIndex) == 1 then
    form.gsb_playerList_zhiyou.Visible = true
  elseif nx_number(SelectIndex) == 2 then
    form.gsb_playerList_guanzhu.Visible = true
  end
end
function show_friend_relation(form, player, table_name, SelectIndex)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  if nx_number(SelectIndex) == 0 then
    gsb_playerList = form.gsb_playerList_friend
  elseif nx_number(SelectIndex) == 1 then
    gsb_playerList = form.gsb_playerList_zhiyou
  elseif nx_number(SelectIndex) == 2 then
    gsb_playerList = form.gsb_playerList_guanzhu
  end
  for i = 0, rows - 1 do
    local index = i
    local uid = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, index, FRIEND_REC_NAME))
    local player_icon = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_PHOTO))
    local player_menpai = nx_string(player:QueryRecord(table_name, index, FRIEND_REC_MENPAI))
    local player_offline_state = nx_int(player:QueryRecord(table_name, index, FRIEND_REC_ONLINE))
    add_player(form, uid, player_name, index, gsb_playerList)
  end
  gsb_playerList.IsEditMode = false
end
function add_player(form, uid, playerName, index, gsb_playerList)
  local gui = nx_value("gui")
  local gb_player = gui:Create("GroupBox")
  local cb_item = gui:Create("CheckButton")
  cb_item.Left = 5
  cb_item.Top = 7
  cb_item.Width = 14
  cb_item.Height = 15
  cb_item.uid = nx_string(uid)
  cb_item.tag = nx_widestr(playerName)
  cb_item.DrawMode = "FitWindow"
  cb_item.NormalImage = "gui\\common\\checkbutton\\cbtn_1_off.png"
  cb_item.FocusImage = "gui\\common\\checkbutton\\cbtn_1_on.png"
  cb_item.CheckedImage = "gui\\common\\checkbutton\\cbtn_1_down.png"
  cb_item.Name = "cb_" .. nx_string(index)
  gb_player:Add(cb_item)
  if is_check(form.SelectPlayerNames, playerName) then
    cb_item.Checked = true
  end
  local lb_name = gui:Create("Button")
  lb_name.Width = 80
  lb_name.Height = 20
  lb_name.Left = 17
  lb_name.Top = 5
  lb_name.Text = nx_widestr(playerName)
  lb_name.Font = "font_text"
  lb_name.Align = "Left"
  lb_name.ForeColor = "255,255,255,255"
  lb_name.BackColor = "0,0,0,0"
  lb_name.NormalColor = "0,0,0,0"
  lb_name.FocusColor = "255,255,255,255"
  lb_name.PushColor = "255,255,255,255"
  lb_name.DisableColor = "0,0,0,0"
  lb_name.ShadowColor = "0,0,0,0"
  lb_name.BackColor = "0,0,0,0"
  lb_name.LineColor = "0,0,0,0"
  lb_name.target = cb_item
  nx_bind_script(lb_name, nx_current())
  nx_callback(lb_name, "on_click", "on_lb_name_click")
  gb_player:Add(lb_name)
  gb_player.Left = index % 3 * 95 + 1
  gb_player.Top = nx_int(index / 3) * 35 + 8
  gb_player.Width = 105
  gb_player.Height = 30
  gb_player.NoFrame = true
  gb_player.BackColor = "0,255,255,255"
  gb_player.cb_item_name = "cb_" .. nx_string(index)
  gsb_playerList:Add(gb_player)
  return 1
end
function on_lb_name_click(self)
  local cb_item = self.target
  if not nx_is_valid(cb_item) then
    return 0
  end
  cb_item.Checked = not cb_item.Checked
end
function check_players(form, selectPlayerName)
  local itemlist = form.gsb_playerList_friend:GetChildControlList()
  local playerNameList = ""
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if nx_ws_equal(nx_widestr(cb_item.tag), nx_widestr(selectPlayerName)) then
      cb_item.Checked = true
      return
    end
  end
  itemlist = form.gsb_playerList_zhiyou:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if nx_ws_equal(nx_widestr(cb_item.tag), nx_widestr(selectPlayerName)) then
      cb_item.Checked = true
      return
    end
  end
  itemlist = form.gsb_playerList_guanzhu:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if nx_ws_equal(nx_widestr(cb_item.tag), nx_widestr(selectPlayerName)) then
      cb_item.Checked = true
      return
    end
  end
end
function ok_btn_click(self)
  local form = self.Parent
  local itemlist = form.gsb_playerList_friend:GetChildControlList()
  local playerNameList = nx_widestr("")
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      if not nx_ws_equal(playerNameList, nx_widestr("")) then
        playerNameList = playerNameList .. nx_widestr(",")
      end
      playerNameList = playerNameList .. nx_widestr(cb_item.tag)
    end
  end
  itemlist = form.gsb_playerList_zhiyou:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      if not nx_ws_equal(playerNameList, nx_widestr("")) then
        playerNameList = playerNameList .. nx_widestr(",")
      end
      playerNameList = playerNameList .. nx_widestr(cb_item.tag)
    end
  end
  itemlist = form.gsb_playerList_guanzhu:GetChildControlList()
  for i = 1, table.getn(itemlist) do
    local gb_item = itemlist[i]
    local cb_item_name = gb_item.cb_item_name
    local cb_item = gb_item:Find(cb_item_name)
    if cb_item.Checked then
      if not nx_ws_equal(playerNameList, nx_widestr("")) then
        playerNameList = playerNameList .. nx_widestr(",")
      end
      playerNameList = playerNameList .. nx_widestr(cb_item.tag)
    end
  end
  nx_gen_event(form, "input_name_return", "ok", playerNameList)
  form.Visible = false
  return 1
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form.Visible = false
  return 1
end
