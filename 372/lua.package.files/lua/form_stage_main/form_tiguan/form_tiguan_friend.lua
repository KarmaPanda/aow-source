require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("share\\view_define")
require("util_static_data")
require("define\\sysinfo_define")
require("form_stage_main\\form_chat_system\\chat_util_define")
local TreeNodeList = {
  {
    mark = "1",
    ui_tag = "ui_fuqi_01",
    name = "partner"
  },
  {
    mark = "2",
    ui_tag = "ui_haoyou_01",
    name = "friend"
  },
  {
    mark = "3",
    ui_tag = "ui_zhiyou_01",
    name = "buddy"
  },
  {
    mark = "4",
    ui_tag = "ui_pupil_01",
    name = "teacherpupil"
  }
}
local color_online = "255,255,255,255"
local color_offline = "255,128,128,128"
function on_main_form_init(form)
  form.Fixed = true
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
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local form_tiguan = util_get_form(FORM_TIGUAN_ONE, false)
  if nx_is_valid(form_tiguan) then
    form.Left = form_tiguan.Left + form_tiguan.btn_invite_friend.Left + form_tiguan.groupbox_2.Left - form.Height / 3
    form.Top = form_tiguan.Top + form_tiguan.btn_invite_friend.Top + form_tiguan.groupbox_2.Top - form.Height
  end
  refresh_friend_tree(form)
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_tiguan\\form_new_tiguan_main", "hide_gb_friend")
  end
end
function refresh_friend_tree(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return 0
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return 0
  end
  form.tree_friend:BeginUpdate()
  local exchange_root = form.tree_friend:CreateRootNode(nx_widestr("root"))
  exchange_root.category = -1
  for i = 1, table.getn(TreeNodeList) do
    local value = TreeNodeList[i]
    local node_name = gui.TextManager:GetText(nx_string(value.ui_tag))
    local node = exchange_root:CreateNode(node_name)
    node.Mark = nx_int(value.mark)
    node.category = 0
    set_node_prop(node, 1)
  end
  for i = 1, table.getn(TreeNodeList) do
    local value = TreeNodeList[i]
    local first_node = exchange_root:FindNodeByMark(nx_int(value.mark))
    local member_table = do_sort_byonline(get_member_list(value.name))
    local member_count = table.getn(member_table)
    local online_count = 0
    for i = 1, table.getn(member_table) do
      local record = member_table[i]
      local node_name = nx_widestr(record.player_name)
      local is_online = nx_int(record.online) == nx_int(0)
      local second_node = first_node:CreateNode(node_name)
      set_node_prop(second_node, 2)
      second_node.category = 1
      second_node.ForeColor = is_online and color_online or color_offline
      if is_online then
        online_count = online_count + 1
      end
    end
    if nx_number(value.mark) == 4 then
      local first_name = first_node.Text .. nx_widestr("  [") .. nx_widestr(online_count) .. nx_widestr("/") .. nx_widestr(member_count) .. nx_widestr("]")
      first_node.Text = first_name
    else
      local first_name = first_node.Text .. nx_widestr("     [") .. nx_widestr(online_count) .. nx_widestr("/") .. nx_widestr(member_count) .. nx_widestr("]")
      first_node.Text = first_name
    end
  end
  exchange_root.Expand = true
  form.tree_friend.IsNoDrawRoot = true
  form.tree_friend:EndUpdate()
end
function on_tree_friend_select_changed(self, cur_node, pre_node)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if cur_node.category == 0 then
    return 0
  end
  nx_execute("custom_sender", "custom_send_danshua_tiguan_msg", CLIENT_MSG_DS_ALTER_ALLY, cur_node.Text)
  nx_execute("form_stage_main\\form_tiguan\\form_new_tiguan_main", "hide_gb_friend")
end
function get_member_list(typename)
  if nx_string(typename) == "partner" then
    return get_partner_table()
  elseif nx_string(typename) == "friend" then
    return get_friend_table()
  elseif nx_string(typename) == "buddy" then
    return get_buddy_table()
  elseif nx_string(typename) == "teacherpupil" then
    return get_pupil_table()
  elseif nx_string(typename) == "attention" then
    return get_attention_table()
  elseif nx_string(typename) == "acquaint" then
    return get_acquaint_table()
  elseif nx_string(typename) == "enemy" then
    return get_enemy_table()
  elseif nx_string(typename) == "blood" then
    return get_blood_table()
  elseif nx_string(typename) == "filter" then
    return get_filter_table()
  else
    return {}
  end
end
function do_sort_byonline(record_table)
  local online_table = {}
  local offline_table = {}
  local count = table.getn(record_table)
  for i = 1, count do
    local record = record_table[i]
    if nx_int(record.online) == nx_int(0) then
      table.insert(online_table, record)
    else
      table.insert(offline_table, record)
    end
  end
  local new_table = {}
  count = table.getn(online_table)
  for i = 1, count do
    table.insert(new_table, online_table[i])
  end
  count = table.getn(offline_table)
  for i = 1, count do
    table.insert(new_table, offline_table[i])
  end
  return new_table
end
