require("util_gui")
require("util_functions")
require("game_object")
local FRIEND_REC = "rec_friend"
local BUDDY_REC = "rec_buddy"
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
function on_main_form_init(self)
  self.Fixed = false
  self.max_member = 0
  self.be_member = 0
  self.min_member = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  self.gsbox_eg.Visible = false
  self.cbtn_friend.Checked = true
  self.cbtn_buddy.Checked = false
  self.gsbox_friend.Visible = true
  self.gsbox_buddy.Visible = false
  self.btn_ok.Enabled = false
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local player_list = {}
  local gbox_friend = form.gsbox_friend
  local gbox_buddy = form.gsbox_buddy
  local friend_item_list = gbox_friend:GetChildControlList()
  local buddy_item_list = gbox_buddy:GetChildControlList()
  for i = 1, table.getn(friend_item_list) do
    local gb_player = friend_item_list[i]
    local cbtn_name = gb_player.cbtn_name
    local cbtn = gb_player:Find(cbtn_name)
    if nx_is_valid(cbtn) and cbtn.Checked then
      table.insert(player_list, cbtn.player_name)
    end
  end
  for i = 1, table.getn(buddy_item_list) do
    local gb_player = buddy_item_list[i]
    local cbtn_name = gb_player.cbtn_name
    local cbtn = gb_player:Find(cbtn_name)
    if nx_is_valid(cbtn) and cbtn.Checked then
      table.insert(player_list, cbtn.player_name)
    end
  end
  nx_execute("custom_sender", "custom_rob_prison", 2, unpack(player_list))
  form:Close()
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_cbtn_friend_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.cbtn_buddy.Checked = false
  cbtn.Checked = true
  form.gsbox_buddy.Visible = false
  form.gsbox_friend.Visible = true
end
function on_cbtn_buddy_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  form.cbtn_friend.Checked = false
  cbtn.Checked = true
  form.gsbox_friend.Visible = false
  form.gsbox_buddy.Visible = true
end
function init_form(form, rec_name)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local role = get_client_player()
  if not nx_is_valid(role) then
    return 0
  end
  local gbox
  if rec_name == FRIEND_REC then
    gbox = form.gsbox_friend
  elseif rec_name == BUDDY_REC then
    gbox = form.gsbox_buddy
  end
  if not role:FindRecord(rec_name) then
    return 0
  end
  local rows = role:GetRecordRows(rec_name)
  if rows == nx_int("0") then
    return 0
  end
  local index = 0
  for i = 0, rows - 1 do
    local name = nx_widestr(role:QueryRecord(rec_name, i, FRIEND_REC_NAME))
    local plevel = nx_string(role:QueryRecord(rec_name, i, FRIEND_REC_LEVEL))
    local is_online = nx_int(role:QueryRecord(rec_name, i, FRIEND_REC_ONLINE))
    if nx_number(is_online) == 0 then
      add_player(gui, gbox, name, plevel, index)
      index = index + 1
    end
  end
end
function add_player(gui, gbox, name, plevel, index)
  local gb_player = gui:Create("GroupBox")
  if not nx_is_valid(gb_player) then
    return 0
  end
  local cbtn = gui:Create("CheckButton")
  cbtn.Left = 5
  cbtn.Top = 2
  cbtn.Width = 16
  cbtn.Height = 16
  cbtn.DrawMode = "FitWindow"
  cbtn.ClickEvent = true
  cbtn.NormalImage = "gui\\common\\checkbutton\\cbtn_2_out.png"
  cbtn.FocusImage = "gui\\common\\checkbutton\\cbtn_2_on.png"
  cbtn.CheckedImage = "gui\\common\\checkbutton\\cbtn_2_down.png"
  cbtn.Name = "cbtn" .. nx_string(index)
  cbtn.Checked = false
  cbtn.player_name = name
  nx_bind_script(cbtn, nx_current())
  nx_callback(cbtn, "on_click", "on_cbtn_item_click")
  gb_player:Add(cbtn)
  local lbl_name = gui:Create("Label")
  lbl_name.Left = 32
  lbl_name.Top = 0
  lbl_name.Width = 182
  lbl_name.Height = 22
  lbl_name.Align = "Left"
  lbl_name.NoFrame = true
  lbl_name.ForeColor = "255,0,0,0"
  lbl_name.BackColor = "0,0,0,0"
  lbl_name.LineColor = "0,0,0,0"
  lbl_name.BlendColor = "0,0,0,0"
  lbl_name.ShadowColor = "0,0,0,0"
  lbl_name.Text = name
  gb_player:Add(lbl_name)
  local lbl_plevel = gui:Create("Label")
  lbl_plevel.Left = 240
  lbl_plevel.Top = 0
  lbl_plevel.Width = 100
  lbl_plevel.Height = 22
  lbl_plevel.Align = "Left"
  lbl_plevel.NoFrame = true
  lbl_plevel.ForeColor = "255,0,0,0"
  lbl_plevel.BackColor = "0,0,0,0"
  lbl_plevel.LineColor = "0,0,0,0"
  lbl_plevel.BlendColor = "0,0,0,0"
  lbl_plevel.ShadowColor = "0,0,0,0"
  local karmamgr = nx_value("Karma")
  if nx_is_valid(karmamgr) then
    local title_id = karmamgr:ParseColValue(FRIEND_REC_LEVEL, plevel)
    lbl_plevel.Text = nx_widestr(gui.TextManager:GetText("desc_" .. title_id))
  end
  gb_player:Add(lbl_plevel)
  gb_player.Left = 16
  gb_player.Top = 22 * index
  gb_player.Width = 340
  gb_player.Height = 22
  gb_player.NoFrame = true
  gb_player.BackColor = "0,0,0,0"
  gb_player.cbtn_name = "cbtn" .. nx_string(index)
  gbox:Add(gb_player)
  return 1
end
function on_cbtn_item_click(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  if btn.Checked then
    if form.be_member >= form.max_member then
      btn.Checked = false
    else
      form.be_member = form.be_member + 1
    end
  elseif 0 < form.be_member then
    form.be_member = form.be_member - 1
  end
  form.lbl_member_info.Text = gui.TextManager:GetFormatText("ui_rob_prison_member_info", nx_widestr(form.be_member), nx_widestr(form.max_member))
  if form.be_member >= form.min_member then
    form.btn_ok.Enabled = true
  else
    form.btn_ok.Enabled = false
  end
end
function show_rob_prison_select_friend(max_member, min_member)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local form = util_get_form("form_stage_main\\form_rob_prison\\form_rob_prison_select_friend", true, false)
  if not nx_is_valid(form) then
    return 0
  end
  form.max_member = nx_int(max_member)
  form.min_member = nx_int(min_member)
  form.be_member = 0
  init_form(form, FRIEND_REC)
  init_form(form, BUDDY_REC)
  form.lbl_member_info.Text = gui.TextManager:GetFormatText("ui_rob_prison_member_info", nx_widestr(form.be_member), nx_widestr(form.max_member))
  form.Visible = true
  form:Show()
end
