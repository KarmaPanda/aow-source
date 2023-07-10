require("util_gui")
require("util_functions")
require("form_stage_main\\form_relation\\form_relation_news")
function on_main_form_init(form)
end
function on_main_form_open(form)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  form.type = 1
  databinder:AddTableBind("Gossip_Record", form.gsb_gossip, nx_current(), "add_gossip_list_form")
  change_form_size(form)
end
function change_form_size(form)
  local res = is_form_relation_news_show()
  if nx_boolean(res) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = gui.Width - form.Width - 10
  form.AbsTop = (gui.Height - form.Height) / 2
end
function add_gossip_list_form()
  local form = nx_value("form_stage_main\\form_relation\\form_gossip_info")
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  form.gsb_gossip:DeleteAll()
  if not client_player:FindRecord("Gossip_Record") then
    form.lbl_bg.Visible = false
    form.lbl_bg_num.Visible = false
    return
  end
  local rows = client_player:GetRecordRows("Gossip_Record")
  if rows <= 0 then
    form.lbl_bg.Visible = false
    form.lbl_bg_num.Visible = false
    return
  end
  form.gsb_gossip:DeleteAll()
  form.gsb_gossip.Visible = true
  local select_npcid = ""
  if nx_find_custom(form, "select_npcid") then
    select_npcid = form.select_npcid
  end
  if select_npcid ~= "" and select_npcid ~= "all_npc" then
    local row = client_player:FindRecordRow("Gossip_Record", 1, nx_string(select_npcid), 0)
    if 0 <= row then
      form.lbl_bg_num.Text = nx_widestr(1)
      form.lbl_bg.Visible = true
      form.lbl_bg_num.Visible = true
      local bg_id = client_player:QueryRecord("Gossip_Record", row, 0)
      add_gossip(form, bg_id, select_npcid, 0)
      form.gsb_gossip.IsEditMode = false
    else
      form.lbl_bg.Visible = false
      form.lbl_bg_num.Visible = false
      form.gsb_gossip.Visible = false
    end
    return
  end
  form.lbl_bg_num.Text = nx_widestr(rows)
  form.lbl_bg.Visible = true
  form.lbl_bg_num.Visible = true
  for i = 0, rows - 1 do
    local bg_id = client_player:QueryRecord("Gossip_Record", i, 0)
    local npc_id = client_player:QueryRecord("Gossip_Record", i, 1)
    add_gossip(form, bg_id, npc_id, i)
  end
  form.gsb_gossip.IsEditMode = false
  if nx_find_custom(form, "type") and nx_int(form.type) == nx_int(1) then
    form.lbl_bg_num.Visible = false
    form.lbl_bg.Visible = false
    form.gsb_gossip.Top = 24
  end
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "change_ctrls_size", "form_gossip_info")
end
function add_gossip(form, bg_id, npc_id, index)
  local gui = nx_value("gui")
  local groupbox_npc = gui:Create("GroupBox")
  groupbox_npc.Name = "GroupBox_" .. nx_string(index)
  groupbox_npc.Width = form.gsb_gossip.Width - 18
  groupbox_npc.Height = 70
  groupbox_npc.NoFrame = true
  groupbox_npc.DrawMode = "ExpandH"
  groupbox_npc.LineColor = "0,0,0,0"
  groupbox_npc.BackColor = "0,0,0,0"
  local lbl_gbox_back = gui:Create("Label")
  lbl_gbox_back.Name = "lbl_gbox_back_" .. nx_string(index)
  lbl_gbox_back.Width = groupbox_npc.Width
  lbl_gbox_back.Height = groupbox_npc.Height
  lbl_gbox_back.Top = 0
  lbl_gbox_back.Left = 0
  lbl_gbox_back.DrawMode = "Expand"
  groupbox_npc:Add(lbl_gbox_back)
  local lbl_npc = gui:Create("Label")
  lbl_npc.Name = "lbl_npc_" .. nx_string(index)
  lbl_npc.Width = 80
  lbl_npc.Height = 20
  lbl_npc.Top = 5
  lbl_npc.Left = 15
  lbl_npc.Font = "font_sns_event_mid"
  lbl_npc.ForeColor = "255,200,130,0"
  lbl_npc.Text = nx_widestr(util_text(nx_string(npc_id)))
  groupbox_npc:Add(lbl_npc)
  local lbl_npc_origin = gui:Create("Label")
  lbl_npc_origin.Name = "lbl_npc_origin_" .. nx_string(index)
  lbl_npc_origin.Width = lbl_npc.Width + 10
  lbl_npc_origin.Height = lbl_npc.Height
  lbl_npc_origin.Top = lbl_npc.Top
  lbl_npc_origin.Left = lbl_npc.Left * 2 + lbl_npc.Width
  lbl_npc_origin.Font = "font_sns_list"
  lbl_npc_origin.ForeColor = "255,78,79,83"
  local origin = npc_id .. "_1"
  if gui.TextManager:IsIDName(origin) then
    origin = util_text(nx_string(origin))
  else
    origin = util_text(nx_string("ui_karma_none"))
  end
  lbl_npc_origin.Text = nx_widestr(origin)
  groupbox_npc:Add(lbl_npc_origin)
  local btn_share = gui:Create("Button")
  btn_share.Name = "btn_share_" .. nx_string(index)
  btn_share.Top = lbl_npc.Top
  btn_share.Left = lbl_npc_origin.Left + lbl_npc_origin.Width * 1.7
  btn_share.Font = "font_sns_list"
  btn_share.ForeColor = "255,214,204,191"
  btn_share.NormalImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_out1.png"
  btn_share.FocusImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_on1.png"
  btn_share.PushImage = "gui\\language\\ChineseS\\sns_new\\btn_fx_down1.png"
  btn_share.AutoSize = true
  btn_share.DrawMode = "Tile"
  btn_share.DataSource = bg_id
  nx_bind_script(btn_share, nx_current())
  nx_callback(btn_share, "on_click", "on_btn_share_click")
  groupbox_npc:Add(btn_share)
  local btn_del = gui:Create("Button")
  btn_del.Name = "btn_del_" .. nx_string(index)
  btn_del.Top = lbl_npc.Top
  btn_del.Left = btn_share.Left + btn_share.Width * 1.1
  btn_del.Font = "font_sns_list"
  btn_del.ForeColor = "255,214,204,191"
  btn_del.Transparent = false
  btn_del.NormalImage = "gui\\language\\ChineseS\\sns_new\\btn_del_out1.png"
  btn_del.FocusImage = "gui\\language\\ChineseS\\sns_new\\btn_del_on1.png"
  btn_del.PushImage = "gui\\language\\ChineseS\\sns_new\\btn_del_down1.png"
  btn_del.AutoSize = true
  btn_del.DataSource = bg_id
  nx_bind_script(btn_del, nx_current())
  nx_callback(btn_del, "on_click", "on_btn_del_click")
  groupbox_npc:Add(btn_del)
  local multi_text_box = gui:Create("MultiTextBox")
  multi_text_box.Name = "mltbox_" .. nx_string(index)
  multi_text_box.Width = groupbox_npc.Width
  multi_text_box.Height = groupbox_npc.Height - lbl_npc.Height
  multi_text_box.Top = lbl_npc.Height
  multi_text_box.DrawMode = "Expand"
  multi_text_box.LineColor = "0,0,0,0"
  multi_text_box.LineHeight = 5
  multi_text_box.Solid = false
  multi_text_box.AutoSize = false
  multi_text_box.HasVScroll = false
  multi_text_box.Font = "font_sns_list"
  multi_text_box.TestTrans = false
  multi_text_box.TextColor = "255,62,27,19"
  multi_text_box.SelectBarColor = "0,0,0,0"
  multi_text_box.MouseInBarColor = "0,0,0,0"
  multi_text_box.BackColor = "0,255,255,255"
  multi_text_box.TransImage = true
  multi_text_box.ViewRect = "5,0,350,50"
  nx_bind_script(multi_text_box, nx_current())
  nx_callback(multi_text_box, "on_get_capture", "on_get_capture")
  nx_callback(multi_text_box, "on_lost_capture", "on_lost_capture")
  local gossip_info = gui.TextManager:GetText(bg_id)
  multi_text_box:AddHtmlText(nx_widestr(gossip_info), -1)
  groupbox_npc:Add(multi_text_box)
  groupbox_npc.Top = index * (groupbox_npc.Height + 10)
  form.gsb_gossip:Add(groupbox_npc)
  nx_execute("form_stage_main\\form_relation\\form_relation_news", "show_no_msg_lbl", false)
end
function on_btn_share_click(self)
  local bagua_id = self.DataSource
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_share_gossip_info", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  dialog.combobox_friend.Text = gui.TextManager:GetText("ui_input")
  dialog:ShowModal()
  local res, text = nx_wait_event(100000000, dialog, "input_search_return")
  if res == "ok" then
    nx_execute("custom_sender", "custom_gossip", 1, text, bagua_id)
  end
end
function on_btn_del_click(self)
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  if not nx_is_valid(dialog) then
    return
  end
  local gui = nx_value("gui")
  local text = nx_widestr(gui.TextManager:GetText(nx_string("ui_gossip_del")))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    table_selected = {}
    return
  end
  if not nx_is_valid(self) then
    return
  end
  local bagua_id = self.DataSource
  nx_execute("custom_sender", "custom_gossip", 2, "", bagua_id)
end
function on_get_capture(self)
  local str = self:GetHtmlItemText(0)
  self.HintText = nx_widestr(str)
end
function on_lost_capture(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  local mlt_box_desc = form:Find("mltbox_desc")
  if nx_is_valid(mlt_box_desc) then
    gui:Delete(mlt_box_desc)
  end
end
function close_form()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_relation\\form_gossip_info", false, false)
  if nx_is_valid(form) then
    form.Visible = false
    form:Close()
  end
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    form.Visible = false
    nx_destroy(form)
  end
end
function open_form(flag)
  if flag then
    return util_show_form("form_stage_main\\form_relation\\form_gossip_info", true, false)
  else
    close_form()
  end
end
