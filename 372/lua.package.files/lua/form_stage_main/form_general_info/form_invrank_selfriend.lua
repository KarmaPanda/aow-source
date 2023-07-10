require("util_gui")
require("util_functions")
require("game_object")
local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
local FRIEND_REC_UID = 0
local FRIEND_REC_NAME = 1
local FRIEND_REC_ONLINE = 8
local MAX_PLAYER_COUNT = 10
function main_form_init(self)
  self.Fixed = true
  self.SelectPlayerNames = ""
  self.Visible = false
  self.sel_index = -1
  self.query_type = 0
  self.playercount = 0
  return 1
end
function refresh_form(form, query_type)
  if nx_is_valid(form) then
    init(form, query_type)
  end
end
function init(form, query_type)
  local gui = nx_value("gui")
  form.cb_type.DropListBox:ClearString()
  form.cb_type.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_haoyou")))
  form.cb_type.DropListBox:AddString(nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_zhiyou")))
  form.cb_type.OnlySelect = true
  form.query_type = query_type
  local client_role = get_client_player()
  if not nx_is_valid(client_role) then
    return
  end
  form.cb_type.InputEdit.Text = nx_widestr(gui.TextManager:GetText("ui_menu_friend_item_zhiyou"))
  show_friend_relation(form, client_role, FRIEND_REC, 0)
  show_friend_relation(form, client_role, BUDDY_REC, 1)
  form.cb_type.DropListBox.SelectIndex = 1
  on_cb_type_selected(form.cb_type)
end
function main_form_open(self)
  self.query_type = 0
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
  form.sel_index = SelectIndex
  local gsb_list = nx_null()
  if nx_number(SelectIndex) == 0 then
    gsb_list = form.gsb_playerList_friend
  elseif nx_number(SelectIndex) == 1 then
    gsb_list = form.gsb_playerList_zhiyou
  end
  if not nx_is_valid(gsb_list) then
    return
  end
  on_all_select(gsb_list, false)
  gsb_list.Visible = true
  form.playercount = 0
end
function show_friend_relation(form, player, table_name, SelectIndex)
  if not player:FindRecord(table_name) then
    return
  end
  local rows = player:GetRecordRows(table_name)
  if rows == 0 then
    return
  end
  local gsb_playerList = nx_null()
  if nx_number(SelectIndex) == 0 then
    gsb_playerList = form.gsb_playerList_friend
  elseif nx_number(SelectIndex) == 1 then
    gsb_playerList = form.gsb_playerList_zhiyou
  end
  if not nx_is_valid(gsb_playerList) then
    return
  end
  gsb_playerList:DeleteAll()
  local index = 1
  for i = 0, rows - 1 do
    local uid = nx_string(player:QueryRecord(table_name, i, FRIEND_REC_UID))
    local player_name = nx_widestr(player:QueryRecord(table_name, i, FRIEND_REC_NAME))
    local player_offline_state = nx_int(player:QueryRecord(table_name, i, FRIEND_REC_ONLINE))
    if nx_int(player_offline_state) == nx_int(0) then
      add_player(form, uid, player_name, index, gsb_playerList)
      index = index + 1
    end
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
  local lbl_cover = gui:Create("Label")
  lbl_cover.Left = 5
  lbl_cover.Top = 7
  lbl_cover.Width = 80
  lbl_cover.Height = 20
  lbl_cover.Transparent = false
  gb_player:Add(lbl_cover)
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
  local pos = index - 1
  gb_player.Left = pos % 3 * 95 + 1
  gb_player.Top = nx_int(pos / 3) * 35 + 8
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
  local form = self.ParentForm
  if not nx_is_valid(cb_item) then
    return 0
  end
  if form.playercount >= MAX_PLAYER_COUNT and cb_item.Checked == false then
    return
  end
  cb_item.Checked = not cb_item.Checked
  if cb_item.Checked == true then
    form.playercount = form.playercount + 1
  else
    form.playercount = form.playercount - 1
  end
end
function ok_btn_click(self)
  local form = self.Parent
  local form_invrank_friend = nx_value("form_invrank_friend")
  if not nx_is_valid(form_invrank_friend) then
    form.Visible = false
    return
  end
  local gsb_list = nx_null()
  local query_rec = ""
  if form.sel_index == 0 then
    gsb_list = form.gsb_playerList_friend
    query_rec = FRIEND_REC
  elseif form.sel_index == 1 then
    gsb_list = form.gsb_playerList_zhiyou
    query_rec = BUDDY_REC
  end
  if not nx_is_valid(gsb_list) then
    return
  end
  if form.playercount >= MAX_PLAYER_COUNT then
    form.playercount = MAX_PLAYER_COUNT
  end
  local count = form.playercount
  form.Visible = false
  if count <= 0 then
    return
  end
  local itemlist = gsb_list:GetChildControlList()
  local playerNameList = nx_widestr("")
  for i = 1, table.getn(itemlist) do
    if 0 < count then
      local gb_item = itemlist[i]
      local cb_item_name = gb_item.cb_item_name
      local cb_item = gb_item:Find(cb_item_name)
      if cb_item.Checked then
        if not nx_ws_equal(playerNameList, nx_widestr("")) then
          playerNameList = playerNameList .. nx_widestr(",")
        end
        playerNameList = playerNameList .. nx_widestr(cb_item.tag)
        count = count - 1
      end
    end
  end
  form_invrank_friend.PlayerNum = form.playercount + 1
  if form.query_type == 2 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_bisai", "on_refesh_firend", query_rec, playerNameList)
  elseif form.query_type == 3 then
    nx_execute("form_stage_main\\form_general_info\\form_general_info_zhanli", "on_query_friend_rank", query_rec, playerNameList)
  end
  on_main_form_close(form)
end
function cancel_btn_click(self)
  local form = self.ParentForm
  form.Visible = false
  on_main_form_close(form)
  return 1
end
function on_cbtn_all_checked_changed(cbtn)
  local form = cbtn.ParentForm
  local gsb_list = nx_null()
  if form.sel_index == 0 then
    gsb_list = form.gsb_playerList_friend
  elseif form.sel_index == 1 then
    gsb_list = form.gsb_playerList_zhiyou
  end
  if not nx_is_valid(gsb_list) then
    return
  end
  on_all_select(gsb_list, cbtn.Checked)
end
function on_all_select(select_list, checked)
  if not nx_is_valid(select_list) then
    return
  end
  local child_list = select_list:GetChildControlList()
  local count = table.getn(child_list)
  for i = 1, count do
    local child_groupbox = child_list[i]
    if nx_is_valid(child_groupbox) then
      set_palyer_check(child_groupbox, checked)
    end
  end
end
function set_palyer_check(groupbox_player, checked)
  if not nx_is_valid(groupbox_player) then
    return
  end
  if not nx_find_custom(groupbox_player, "cb_item_name") then
    return
  end
  local cb_name = groupbox_player.cb_item_name
  local cbtn = groupbox_player:Find(cb_name)
  if nx_is_valid(cbtn) then
    cbtn.Checked = checked
  end
end
