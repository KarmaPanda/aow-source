require("share\\client_custom_define")
require("util_functions")
require("util_gui")
local CLIENT_SUBMSG_REQUEST_ADD_ACT_PARTNER = 21
local CLIENT_SUBMSG_REQUEST_DEL_ACT_PARTNER = 22
local CLIENT_SUBMSG_REQUEST_SHOW_ACT_PARTNER = 23
local CLIENT_SUBMSG_REQUEST_ACCEPT_ACT_PARTNER = 24
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function show_form()
  util_show_form("form_stage_main\\form_activity\\form_activity_partner", true)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVITY_MANAGE), nx_int(CLIENT_SUBMSG_REQUEST_SHOW_ACT_PARTNER))
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function update_form_info(form)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.lbl_self_name.Text = client_player:QueryProp("Name")
  form.lbl_self_num.Text = nx_widestr(form.cur_nums)
  form.lbl_point.Text = nx_widestr(form.point)
  if nx_widestr(form.partner_name1) == nx_widestr("") then
    form.lbl_partner_name1.Text = util_text("ui_no_partner")
    form.lbl_partner_num1.Text = ""
    form.lbl_partner_num_tip1.Visible = false
    form.lbl_partner_offline1.Visible = false
  else
    form.lbl_partner_name1.Text = form.partner_name1
    if nx_int(form.is_online1) == nx_int(0) then
      form.lbl_partner_num1.Text = ""
      form.lbl_partner_num_tip1.Visible = false
      form.lbl_partner_offline1.Visible = true
    else
      form.lbl_partner_num1.Text = nx_widestr(form.partner_nums1)
      form.lbl_partner_num_tip1.Visible = true
      form.lbl_partner_offline1.Visible = false
    end
  end
  if nx_widestr(form.partner_name2) == nx_widestr("") then
    form.lbl_partner_name2.Text = util_text("ui_no_partner")
    form.lbl_partner_num2.Text = ""
    form.lbl_partner_num_tip2.Visible = false
    form.lbl_partner_offline2.Visible = false
  else
    form.lbl_partner_name2.Text = form.partner_name2
    if nx_int(form.is_online2) == nx_int(0) then
      form.lbl_partner_num2.Text = ""
      form.lbl_partner_num_tip2.Visible = false
      form.lbl_partner_offline2.Visible = true
    else
      form.lbl_partner_num2.Text = nx_widestr(form.partner_nums2)
      form.lbl_partner_num_tip2.Visible = true
      form.lbl_partner_offline2.Visible = false
    end
  end
end
function on_server_msg(...)
  local form = nx_value("form_stage_main\\form_activity\\form_activity_partner")
  if not nx_is_valid(form) then
    return
  end
  form.cur_nums = arg[1]
  form.point = arg[2]
  form.partner_name1 = arg[3]
  if nx_string(form.partner_name1) == nx_string(nil) then
    form.partner_name1 = ""
  end
  form.is_online1 = arg[4]
  form.partner_nums1 = arg[5]
  form.partner_name2 = arg[6]
  if nx_string(form.partner_name2) == nx_string(nil) then
    form.partner_name2 = ""
  end
  form.is_online2 = arg[7]
  form.partner_nums2 = arg[8]
  update_form_info(form)
end
