require("share\\chat_define")
require("util_gui")
local FORM_TYPE_LABA = 1
local MIN_LABA_SEND_COUNT = 10
local FORM_TYPE_LABA_CROSS_SERVER = 2
local MIN_CROSS_LABA_SEND_COUNT = 10
local EQUIP_LINK_MAX_NUM = 4
local EQUIP_FACE_MAX_NUM = 1
local INFO_MAX_NUM = 300
local MAX_MORE_SEND_CNT = 99
local MIN_MORE_SEND_CNT = 10
local NO_ANIMATION = -1
local TRUMPET_COMMON_TEXT = {
  "system_cross_trumpet_item_5",
  "ui_cross_trumpet_confirm",
  "system_cross_trumpet_not_in_cross",
  "system_cross_trumpet_item_7",
  "system_xiaolaba_cross_server_donghua",
  "ui_xiaolaba_many_cross_server"
}
function main_form_init(self)
  self.Fixed = false
  self.refresh_time = 0
  self.refresh_topthree_time = 0
  self.trumpet_form_type = 0
end
function on_main_form_open(self)
  self.redit_info.ReturnFontFormat = false
  local databinder = nx_value("data_binder")
  local form_laba_logic = nx_value("form_laba_info")
  if nx_is_valid(form_laba_logic) then
    nx_destroy(form_laba_logic)
  end
  local form_laba_logic = nx_create("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  nx_set_value("form_laba_info", form_laba_logic)
  init_trumpet_ani_drop_box(form_type)
end
function on_main_form_close(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.hyperfocused = nx_null()
  cancel_post_process()
  local form_laba_logic = nx_value("form_laba_info")
  if nx_is_valid(form_laba_logic) then
    nx_destroy(form_laba_logic)
  end
  self.trumpet_form_type = 0
end
function on_main_form_visible(form)
  if not nx_is_valid(form) or not nx_find_custom(form, "trumpet_form_type") then
    return
  end
  local index = nx_number(form.trumpet_form_type)
  if index == FORM_TYPE_LABA then
    init_trumpet_form_text_info(FORM_TYPE_LABA)
    form.lbl_queue_cnt.Text = nx_widestr(0)
    form.refresh_time = 0
    on_btn_refresh_queue_click(form.btn_refresh_queue)
    form.refresh_topthree_time = os.time()
    nx_execute("custom_sender", "custom_get_speaker_rank")
    if form.cbtn_more.Checked then
      form.cbtn_more.Checked = false
    else
      on_cbtn_more_checked_changed(form.cbtn_more)
    end
    set_animation(NO_ANIMATION)
  elseif index == FORM_TYPE_LABA_CROSS_SERVER then
    init_trumpet_form_text_info(FORM_TYPE_LABA_CROSS_SERVER)
    form.lbl_queue_cnt.Text = nx_widestr(0)
    form.refresh_time = 0
    on_btn_refresh_queue_click(form.btn_refresh_queue)
    if form.cbtn_more.Checked then
      form.cbtn_more.Checked = false
    else
      on_cbtn_more_checked_changed(form.cbtn_more)
    end
    set_animation(NO_ANIMATION)
    update_cross_item_num()
  end
end
function init(form)
  change_form_size()
  form.lbl_has_money.Text = nx_widestr("0")
  form.btn_send.Enabled = false
  form.redit_info.Text = nx_widestr("")
  if form.cbtn_item.Checked then
    form.switch = 2
  else
    form.switch = -1
  end
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(1505) then
    form.groupbox_3.Visible = true
    form.groupbox_4.Top = form.groupbox_3.Top - 20
    update_bind_card()
  else
    form.groupbox_3.Visible = false
  end
  update_gold()
  update_item_num()
end
function change_form_size()
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
  form.switch = -1
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.hyperfocused = nx_null()
  cancel_post_process()
end
function on_btn_cancel_click(self)
  local form = self.ParentForm
  form.Visible = false
  form.switch = -1
  cancel_post_process()
end
function cancel_post_process()
  if nx_running(nx_current(), "focus_redit_info") then
    nx_kill(nx_current(), "focus_redit_info")
  end
  local form_laba_ani = nx_value("form_stage_main\\form_main\\form_laba_ani")
  if nx_is_valid(form_laba_ani) then
    form_laba_ani:Close()
  end
end
function on_btn_send_click(self)
  local form = self.ParentForm
  local chat_str = form.redit_info.Text
  if nx_string(chat_str) == "" then
    return
  end
  local CheckWords = nx_value("CheckWords")
  if nx_is_valid(CheckWords) and CheckWords:CheckFilterRegion(nx_widestr(chat_str)) then
    return
  end
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return
  end
  local text_send_cnt_error = nx_widestr("")
  local send_cnt = nx_int(1)
  if form.cbtn_more.Checked then
    send_cnt = nx_int(form.ipt_send_cnt.Text)
    if send_cnt < nx_int(MIN_MORE_SEND_CNT) or send_cnt > nx_int(MAX_MORE_SEND_CNT) then
      local form_laba_logic = nx_value("form_laba_info")
      if nx_is_valid(form_laba_logic) then
        local rv, name, pic, is_more_send, ani_send_cnt, desc = form_laba_logic:GetAniProperty(form.ani_idx)
        if rv and is_more_send then
          nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "xiaolaba_ani_number", ani_send_cnt)
          return
        end
      end
      text_send_cnt_error = util_format_string("xiaolaba_normal_number", nx_int(MIN_LABA_SEND_COUNT), 100)
      SystemCenterInfo:ShowSystemCenterInfo(text_send_cnt_error, 2)
      return
    end
  end
  local ani_pic = ""
  if NO_ANIMATION ~= form.ani_idx then
    local form_laba_logic = nx_value("form_laba_info")
    if nx_is_valid(form_laba_logic) then
      local rv, name, pic, is_more_send, ani_send_cnt, desc, need_top_three = form_laba_logic:GetAniProperty(form.ani_idx)
      if rv then
        if (not need_top_three or not form_laba_logic.IsTopThree) and is_more_send then
          if not form.cbtn_more.Checked then
            text_send_cnt_error = util_format_string("xiaolaba_normal_number", nx_int(MIN_LABA_SEND_COUNT), 100)
            SystemCenterInfo:ShowSystemCenterInfo(text_send_cnt_error, 2)
            return
          end
          if send_cnt < nx_int(ani_send_cnt) then
            nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "xiaolaba_ani_number", ani_send_cnt)
            return
          end
        end
        ani_pic = pic
      end
    end
  end
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  local select_index = form.combobox_color.DropListBox.SelectIndex
  local color = form_laba_logic:GetTextHtmlColor(select_index)
  local html = "<font >"
  if "" ~= color then
    html = "<font color=\"" .. color .. "\">"
  end
  local form_main_chat_logic = nx_value("form_main_chat")
  if nx_is_valid(form_main_chat_logic) then
    chat_str = form_main_chat_logic:set_chat_info_color(chat_str, nx_widestr(html))
  end
  local switch = 0
  local switch_manager = nx_value("SwitchManager")
  if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(1505) and form.cbtn_bind_card.Checked then
    switch = 1
  end
  if nx_find_custom(form, "switch") and form.switch ~= -1 then
    switch = form.switch
  end
  if nx_find_custom(form, "trumpet_form_type") and form.trumpet_form_type == FORM_TYPE_LABA_CROSS_SERVER then
    if not confirm_send_cross_server_trumpet(send_cnt) then
      return
    end
    switch = 2
  end
  nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, chat_str, send_cnt, ani_pic, switch)
end
function on_btn_buy_click(self)
  util_auto_show_hide_form("form_stage_main\\form_charge_shop\\form_online_charge")
end
function on_redit_info_changed(self)
  local form = self.ParentForm
  local info = nx_string(self.Text)
  if info == "" then
    form.btn_send.Enabled = false
  else
    form.btn_send.Enabled = true
  end
end
function update_gold()
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("CapitalModule")
  local gold = mgr:GetCapital(2)
  gold = nx_int(gold / 1000)
  if gold > nx_int(999999) then
    form.lbl_has_money.Text = nx_widestr("999999...")
  else
    form.lbl_has_money.Text = nx_widestr(gold)
  end
end
function update_bind_card()
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local mgr = nx_value("CapitalModule")
  local gold = mgr:GetCapital(4)
  gold = nx_int(gold / 1000)
  if gold > nx_int(999999) then
    form.yinpiao_num.Text = nx_widestr("999999...")
  else
    form.yinpiao_num.Text = nx_widestr(gold)
  end
end
function on_btn_face_click(self)
  local form = self.ParentForm
  local gui = nx_value("gui")
  gui.Focused = form.redit_info
  local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false, "", true)
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  if nx_is_valid(face_form) then
    if form_main_face.type == 1 then
      nx_gen_event(face_form, "selectface_return", "cancel", "")
    else
      form_main_face.type = 1
      nx_execute("form_stage_main\\form_main\\form_main_face", "show_page", form_main_face, 0)
    end
  else
    local groupbox = self.Parent
    local gui = nx_value("gui")
    form_main_face.type = 1
    nx_set_value("form_stage_main\\form_main\\form_main_face_chat", form_main_face)
    form_main_face.AbsLeft = groupbox.AbsLeft + groupbox.Width
    form_main_face.AbsTop = groupbox.AbsTop + groupbox.Height - form_main_face.Height
    form_main_face:Show()
    form_main_face.Visible = true
    while true do
      local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
      if res == "ok" then
        add_chatface_to_chatedit(html)
      else
        form_main_face:Close()
        break
      end
    end
  end
end
function add_chatface_to_chatedit(html)
  local form_main = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form_main) then
    return
  end
  local html_info = nx_string(html)
  local n_html_start, n_html_end = string.find(html_info, "<a href")
  if n_html_start ~= nil and n_html_end ~= nil then
    local cur_chat_info = nx_string(form_main.redit_info.Text)
    if false == check_equip_link_num(cur_chat_info) then
      return
    end
  end
  local n_face_start, n_face_end = string.find(html_info, "<img")
  if n_face_start ~= nil and n_face_end ~= nil then
    local cur_chat_info = nx_string(form_main.redit_info.Text)
    if false == check_face_num(cur_chat_info) then
      nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 2, "xiaolaba_ani_face")
      return
    end
  end
  form_main.redit_info:Append(html, -1)
  local gui = nx_value("gui")
  gui.Focused = nx_null()
  gui.Focused = form_main.redit_info
  on_redit_info_changed(form_main.redit_info)
end
function check_face_num(chat_info)
  local html_num = 0
  local n_start, n_end = string.find(chat_info, "<img")
  while n_start ~= nil and n_end ~= nil do
    html_num = html_num + 1
    n_start, n_end = string.find(chat_info, "<img", n_end)
  end
  if nx_number(html_num) >= EQUIP_FACE_MAX_NUM then
    return false
  end
  return true
end
function check_equip_link_num(chat_info)
  local html_num = 0
  local n_start, n_end = string.find(chat_info, "HLChatItem")
  while n_start ~= nil and n_end ~= nil do
    html_num = html_num + 1
    n_start, n_end = string.find(chat_info, "HLChatItem", n_end)
  end
  if nx_number(html_num) >= EQUIP_LINK_MAX_NUM then
    return false
  end
  return true
end
function on_btn_animation_click(btn)
  local form = btn.ParentForm
  if not nx_find_custom(form, "trumpet_form_type") then
    return
  end
  if nx_int(form.trumpet_form_type) == nx_int(FORM_TYPE_LABA_CROSS_SERVER) then
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      local text_error = util_text(TRUMPET_COMMON_TEXT[5])
      SystemCenterInfo:ShowSystemCenterInfo(text_error, 2)
    end
    return
  end
  if btn.ParentForm.ani_idx == NO_ANIMATION then
    local groupbox = btn.Parent
    local left = groupbox.AbsLeft + groupbox.Width
    local top = groupbox.AbsTop
    local now_time = os.time()
    if now_time - btn.ParentForm.refresh_topthree_time > 300 then
      btn.ParentForm.refresh_topthree_time = now_time
      nx_execute("custom_sender", "custom_get_speaker_rank")
    end
    nx_execute("form_stage_main\\form_main\\form_laba_ani", "open_select_animation", left, top, groupbox.Height)
  else
    set_animation(NO_ANIMATION)
  end
end
function set_animation(ani_idx)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  if not form.Visible then
    return
  end
  if NO_ANIMATION ~= ani_idx then
    local form_laba_logic = nx_value("form_laba_info")
    if nx_is_valid(form_laba_logic) then
      local rv, name, pic, is_more_send, ani_send_cnt, desc = form_laba_logic:GetAniProperty(nx_int(ani_idx))
      if rv then
        form.ani_idx = nx_int(ani_idx)
        form.lbl_redit_ani.BackImage = pic
        form.btn_animation.Text = util_text("ui_xiaolaba_ani_1")
        return
      end
    end
  end
  form.ani_idx = nx_int(NO_ANIMATION)
  form.lbl_redit_ani.BackImage = ""
  form.btn_animation.Text = util_text("ui_xiaolaba_ani")
end
function on_combobox_color_selected(cbbox)
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  local form = cbbox.ParentForm
  local select_index = cbbox.DropListBox.SelectIndex
  local color = form_laba_logic:GetTextColor(select_index)
  form_laba_logic.DefTextColorIdx = select_index
  cbbox.InputEdit.ForeColor = color
  cbbox.InputEdit.Text = cbbox.DropListBox.SelectString
  form.redit_info.ForeColor = color
  form.redit_info.Text = form.redit_info.Text
  nx_execute(nx_current(), "focus_redit_info", form.redit_info)
end
function on_combobox_font_selected(cbbox)
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  local form = cbbox.ParentForm
  local select_index = cbbox.DropListBox.SelectIndex
  local font = form_laba_logic:GetTextFont(select_index)
  form_laba_logic.DefTextFontIdx = select_index
  cbbox.InputEdit.Text = cbbox.DropListBox.SelectString
  form.redit_info.Font = font
  form.redit_info.Text = form.redit_info.Text
  nx_execute(nx_current(), "focus_redit_info", form.redit_info)
end
function focus_redit_info(redit_info)
  nx_pause(0.1)
  local gui = nx_is_valid(redit_info) and nx_value("gui")
end
function on_ipt_send_cnt_changed(ipt)
  local str = string.gsub(nx_string(ipt.Text), "%D", "")
  if "0" ~= str then
    str = string.gsub(str, "^0+", "")
  end
  ipt.Text = nx_widestr(str)
  ipt.InputPos = nx_ws_length(ipt.Text)
end
function on_cbtn_more_checked_changed(cbtn)
  local form = cbtn.ParentForm
  form.ipt_send_cnt.Text = nx_widestr("0")
  if cbtn.Checked then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "laba_more")
    if nx_is_valid(dialog) then
      local gui = nx_value("gui")
      local text = nx_widestr("")
      if not nx_find_custom(form, "trumpet_form_type") then
        return
      end
      if nx_int(form.trumpet_form_type) == nx_int(FORM_TYPE_LABA) then
        text = gui.TextManager:GetFormatText("ui_xiaolaba_many")
      elseif nx_int(form.trumpet_form_type) == nx_int(FORM_TYPE_LABA_CROSS_SERVER) then
        text = gui.TextManager:GetFormatText(TRUMPET_COMMON_TEXT[6])
      end
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local rv = nx_wait_event(100000000, dialog, "confirm_return")
      if "ok" ~= rv then
        form.cbtn_more.Checked = false
        return
      end
    end
    form.ipt_send_cnt.Enabled = true
  else
    if nx_find_custom(form, "ani_idx") then
      local form_laba_logic = nx_value("form_laba_info")
      if nx_is_valid(form_laba_logic) then
        local rv, name, pic, is_more_send, ani_send_cnt, desc = form_laba_logic:GetAniProperty(form.ani_idx)
        if rv and is_more_send then
          set_animation(NO_ANIMATION)
        end
      end
    end
    form.ipt_send_cnt.Enabled = false
  end
end
function close_form()
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", false, false, "laba_more")
  if nx_is_valid(dialog) then
    nx_execute("form_common\\form_confirm", "cancel_btn_click", dialog.cancel_btn)
  end
end
function on_btn_refresh_queue_click(btn)
  local new_time = os.time()
  if nx_find_custom(btn.ParentForm, "refresh_time") and new_time - btn.ParentForm.refresh_time <= 3 then
    return
  end
  btn.ParentForm.refresh_time = new_time
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) or not nx_find_custom(form, "trumpet_form_type") then
    return
  end
  if form.trumpet_form_type == FORM_TYPE_LABA then
    nx_execute("custom_sender", "custom_get_speaker_queue")
  elseif form.trumpet_form_type == FORM_TYPE_LABA_CROSS_SERVER then
    nx_execute("custom_sender", "custom_get_cross_speaker_queue")
  end
end
function refresh_queue_cnt(cnt)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  form.lbl_queue_cnt.Text = nx_widestr(cnt)
end
function on_redit_info_get_focus(self)
  local gui = nx_value("gui")
  local form = self.ParentForm
  gui.Focused = form.redit_info
  gui.hyperfocused = form.redit_info
end
function on_rbtn_history_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    form.groupbox_1.Visible = false
    form.groupbox_2.Visible = true
  end
end
function on_rbtn_speaker_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    form.groupbox_1.Visible = true
    form.groupbox_2.Visible = false
  end
end
function on_mltbox_info_click_hyperlink(self, itemindex, linkdata)
  if linkdata == nil or nx_string(linkdata) == "" then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local player_name = player:QueryProp("Name")
  if nx_string(player_name) ~= nx_string(linkdata) then
    nx_execute("custom_sender", "custom_request_chat", nx_widestr(linkdata))
  end
end
function on_mltbox_info_right_click_hyperlink(self, itemindex, linkdata)
  if linkdata == nil or nx_string(linkdata) == "" then
    return
  end
  if string.find(nx_string(linkdata), "item") ~= nil then
    return
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local player_name = player:QueryProp("Name")
  local gui = nx_value("gui")
  if nx_string(player_name) ~= nx_string(linkdata) then
    nx_execute("util_gui", "util_show_form", "form_stage_main\\form_main\\form_player_menu", true)
    local form = nx_value("form_stage_main\\form_main\\form_player_menu")
    if not nx_is_valid(form) then
      return
    end
    local x, y = gui:GetCursorPosition()
    form.AbsLeft = x
    form.AbsTop = y
    if nx_is_valid(form) then
      form.sender_name = nx_widestr(linkdata)
    end
  end
end
function on_btn_clear_click(self)
  local form = self.ParentForm
  if nx_find_custom(form, "trumpet_form_type") and nx_number(form.trumpet_form_type) == FORM_TYPE_LABA_CROSS_SERVER then
    form.mltbox_info_cross:Clear()
    return
  end
  form.mltbox_info:Clear()
end
function right_down()
  local form = nx_value("form_stage_main\\form_main\\form_player_menu")
  if nx_is_valid(form) then
    form:Close()
  end
end
function left_down()
  local form = nx_value("form_stage_main\\form_main\\form_player_menu")
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_mltbox_info_vscroll_changed(self)
  if math.abs(self.VerticalMaxValue - self.VerticalValue) < 2 then
    self.AutoScroll = true
  else
    self.AutoScroll = false
  end
end
function send_laba_immediate(prompt, content, ani_idx, confirm_id)
  confirm_id = confirm_id or ""
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_laba_prompt", false, false, nx_string(confirm_id))
  if nx_is_valid(dialog) then
    local gui = nx_value("gui")
    gui.Desktop:ToFront(dialog)
    return
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_laba_prompt", true, false, nx_string(confirm_id))
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute("form_stage_main\\form_main\\form_laba_prompt", "set_prompt", nx_widestr(prompt), nx_string(confirm_id), get_used_card_type())
  dialog:Show()
  local gui = nx_value("gui")
  gui.Desktop:ToFront(dialog)
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == res then
    if nil == ani_idx or "" == ani_idx then
      nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, nx_widestr(content), 1, "", get_used_card_type())
    else
      local form_laba_logic = nx_value("form_laba_info")
      if not nx_is_valid(form_laba_logic) then
        return
      end
      local rv, name, pic, is_more_send, ani_send_cnt, desc = form_laba_logic:GetAniProperty(nx_int(ani_idx))
      if not rv then
        pic = ""
      end
      nx_execute("custom_sender", "custom_speaker", CHATTYPE_SMALL_SPEAKER, nx_widestr(content), 1, pic, get_used_card_type())
    end
  end
end
function on_btn_change_click(self)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_consign\\form_buy_capital_bind", true)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function on_cbtn_bind_card_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    local switch_manager = nx_value("SwitchManager")
    if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(1505) then
      self.Checked = false
    end
    if form.cbtn_item.Checked then
      form.cbtn_item.Checked = false
    end
  end
end
function get_used_card_type()
  local switch_manager = nx_value("SwitchManager")
  if not nx_is_valid(switch_manager) or not switch_manager:CheckSwitchEnable(1505) then
    return 0
  end
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return 0
  end
  if form.cbtn_bind_card.Checked then
    return 1
  else
    return 0
  end
end
function open_form(config_id)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local item_configid = nx_string(config_id)
  if item_configid == nil or item_configid == "" then
    return
  end
  if item_configid == "item_xiaolaba_bangding" or item_configid == "item_xiaolaba_feibangding" then
    form.trumpet_form_type = FORM_TYPE_LABA
    open_trumpet_publish_form()
    form.cbtn_item.Checked = true
    form.switch = 2
    form.Visible = true
  elseif item_configid == "item_laba_battlefield" or item_configid == "item_laba_battlefield_bind" then
    if is_in_cross_server_fight() then
      form.trumpet_form_type = FORM_TYPE_LABA_CROSS_SERVER
      open_trumpet_publish_form()
    else
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      if nx_is_valid(SystemCenterInfo) then
        SystemCenterInfo:ShowSystemCenterInfo(TRUMPET_COMMON_TEXT[4], 2)
      end
    end
  end
end
function on_cbtn_item_checked_changed(self)
  local form = self.ParentForm
  if self.Checked then
    local switch_manager = nx_value("SwitchManager")
    if nx_is_valid(switch_manager) and switch_manager:CheckSwitchEnable(134) then
      local goods_grid = nx_value("GoodsGrid")
      if not nx_is_valid(goods_grid) then
        form.switch = -1
        self.Checked = false
        return
      end
      local count_1 = goods_grid:GetItemCount("item_xiaolaba_bangding")
      local count_2 = goods_grid:GetItemCount("item_xiaolaba_feibangding")
      local SystemCenterInfo = nx_value("SystemCenterInfo")
      local gui = nx_value("gui")
      if count_1 + count_2 == 0 then
        form.switch = -1
        self.Checked = false
        local info = gui.TextManager:GetText("system_xiaolaba_item_4")
        if nx_is_valid(SystemCenterInfo) then
          SystemCenterInfo:ShowSystemCenterInfo(info, 2)
        end
        return
      end
      if 0 < count_1 then
        local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false, "laba_item")
        if nx_is_valid(dialog) then
          local text = gui.TextManager:GetFormatText("ui_xiaolaba_item_3")
          nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
          dialog:ShowModal()
          local rv = nx_wait_event(100000000, dialog, "confirm_return")
          if "ok" ~= rv then
            form.cbtn_item.Checked = false
            return
          end
        end
      end
      form.switch = 2
      if form.cbtn_bind_card.Checked then
        form.cbtn_bind_card.Checked = false
      end
    else
      form.switch = -1
      self.Checked = false
    end
  else
    form.switch = -1
  end
end
function update_item_num()
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return
  end
  local count_1 = goods_grid:GetItemCount("item_xiaolaba_bangding")
  local count_2 = goods_grid:GetItemCount("item_xiaolaba_feibangding")
  form.lbl_item_num.Text = nx_widestr(count_1 + count_2)
end
function open_trumpet_publish_form()
  local form_laba = nx_value("form_stage_main\\form_main\\form_laba_info")
  local gui = nx_value("gui")
  if not nx_is_valid(form_laba) or not nx_is_valid(gui) then
    return
  end
  local b_in_cross = is_in_cross_server_fight()
  if not b_in_cross then
    form_laba.trumpet_form_type = 1
    form_laba.Visible = not form_laba.Visible
    if form_laba.Visible then
      init(form_laba)
      gui.Desktop:ToFront(form_laba)
    end
  else
    form_laba.trumpet_form_type = 2
    form_laba.Visible = not form_laba.Visible
    if form_laba.Visible then
      gui.Desktop:ToFront(form_laba)
    end
  end
end
function init_trumpet_form_text_info(form_type)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local index = nx_number(form_type)
  if index == FORM_TYPE_LABA then
    form.trumpet_form_type = FORM_TYPE_LABA
    form.lbl_6.Text = util_text("ui_xiaolaba")
    form.lbl_7.Text = util_text("ui_xiaolaba_text")
    form.lbl_laba_title.Text = util_text("ui_xiaolaba_title")
    form.rbtn_speaker.Text = util_text("ui_xiaolaba_title")
    form.lbl_4.Text = util_text("ui_xiaolaba_send")
    form.redit_info.Text = nx_widestr("")
    form.cbtn_item.Visible = true
    form.cbtn_item.Checked = false
    form.cbtn_item.Enabled = true
    form.lbl_28.Left = 48
    form.lbl_30.Left = 48
    form.lbl_28.Text = util_text("ui_xiaolaba_use_item_1")
    form.lbl_30.Text = util_text("ui_xiaolaba_use_item_2")
    form.groupbox_4.Visible = true
    local SwitchManager = nx_value("SwitchManager")
    if nx_is_valid(SwitchManager) and SwitchManager:CheckSwitchEnable(1505) then
      form.groupbox_3.Visible = true
      form.groupbox_4.Top = form.groupbox_3.Top - 20
      update_bind_card()
    else
      form.groupbox_3.Visible = false
    end
    form.mltbox_info.Visible = true
    form.mltbox_info_cross.Visible = false
    form.lbl_item_num.Visible = true
    form.lbl_item_num.Text = nx_widestr("0")
    form.lbl_item_num_cross.Visible = false
    form.btn_buy.Visible = true
  elseif index == FORM_TYPE_LABA_CROSS_SERVER then
    form.trumpet_form_type = FORM_TYPE_LABA_CROSS_SERVER
    form.lbl_6.Text = util_text("ui_xiaolaba_cross_server")
    form.lbl_7.Text = util_text("ui_xiaolaba_text_cross_server")
    form.lbl_laba_title.Text = util_text("ui_xiaolaba_cross_server")
    form.rbtn_speaker.Text = util_text("ui_xiaolaba_cross_server")
    form.lbl_4.Text = util_text("ui_xiaolaba_send_cross_server")
    form.redit_info.Text = nx_widestr("")
    form.cbtn_item.Visible = false
    form.cbtn_item.Checked = false
    form.cbtn_item.Enabled = false
    form.lbl_28.Left = 24
    form.lbl_30.Left = 198
    form.lbl_28.Text = util_text("ui_xiaolaba_use_item_cross_server_1")
    form.lbl_30.Text = util_text("ui_xiaolaba_use_item_cross_server_2")
    form.groupbox_4.Visible = false
    form.groupbox_3.Visible = false
    form.mltbox_info.Visible = false
    form.mltbox_info_cross.Visible = true
    form.lbl_item_num.Visible = false
    form.lbl_item_num_cross.Visible = true
    form.lbl_item_num_cross.Text = nx_widestr("0")
    form.btn_buy.Visible = false
  end
  form.lbl_redit_ani.BackImage = ""
end
function init_trumpet_ani_drop_box(form_type)
  local form = nx_value("form_stage_main\\form_main\\form_laba_info")
  if not nx_is_valid(form) then
    return
  end
  local index = nx_number(form_type)
  local form_laba_logic = nx_value("form_laba_info")
  if not nx_is_valid(form_laba_logic) then
    return
  end
  local color_cnt = form_laba_logic.TextColorCnt
  for i = 0, color_cnt - 1 do
    form.combobox_color.DropListBox:AddString(form_laba_logic:GetTextColorName(i))
    form.combobox_color.DropListBox:SetItemColor(i, form_laba_logic:GetTextColor(i))
  end
  local font_cnt = form_laba_logic.TextFontCnt
  for i = 0, font_cnt - 1 do
    form.combobox_font.DropListBox:AddString(form_laba_logic:GetTextFontName(i))
  end
  form.combobox_color.DropListBox.SelectIndex = form_laba_logic.DefTextColorIdx
  on_combobox_color_selected(form.combobox_color)
  form.combobox_font.DropListBox.SelectIndex = form_laba_logic.DefTextFontIdx
  on_combobox_font_selected(form.combobox_font)
  set_animation(NO_ANIMATION)
end
function is_in_cross_server_fight()
  local Speaker = nx_value("Speaker")
  if not nx_is_valid(Speaker) then
    return false
  end
  local res = Speaker:IsInCross()
  return res
end
function is_in_sanmeng_scene()
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return false
  end
  local client_scene = game_client:GetScene()
  if not nx_is_valid(client_scene) then
    return false
  end
  local resource = client_scene:QueryProp("ConfigID")
  if nx_string(resource) == nx_string("ini\\scene\\groupscene030") then
    return true
  end
  return false
end
function confirm_send_cross_server_trumpet(send_cnt)
  local SystemCenterInfo = nx_value("SystemCenterInfo")
  if not nx_is_valid(SystemCenterInfo) then
    return false
  end
  if not is_in_cross_server_fight() then
    SystemCenterInfo:ShowSystemCenterInfo(util_text(TRUMPET_COMMON_TEXT[3]), 2)
    return false
  end
  local goods_grid = nx_value("GoodsGrid")
  if not nx_is_valid(goods_grid) then
    return false
  end
  local count_1 = goods_grid:GetItemCount("item_laba_battlefield_bind")
  local count_2 = goods_grid:GetItemCount("item_laba_battlefield")
  if count_1 + count_2 == 0 then
    SystemCenterInfo:ShowSystemCenterInfo(util_text(TRUMPET_COMMON_TEXT[1]), 2)
    return false
  end
  if 0 < count_1 + count_2 then
    local dialog = util_get_form("form_common\\form_confirm", true, false, "laba_cross_item")
    if nx_is_valid(dialog) then
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, util_format_string(TRUMPET_COMMON_TEXT[2], nx_int(send_cnt)))
      dialog:ShowModal()
      local rv = nx_wait_event(100000000, dialog, "confirm_return")
      if "ok" == rv then
        return true
      end
    end
  end
  return false
end
function update_cross_item_num()
  local Speaker = nx_value("Speaker")
  if not nx_is_valid(Speaker) then
    return false
  end
  Speaker:UpdateCrossItemNum()
end
function sync_msg_form_show_status()
  local Speaker = nx_value("Speaker")
  if not nx_is_valid(Speaker) then
    return false
  end
  Speaker:SyncMsgFormShowStatus()
end
function set_all_trumpet_form_visible(b_visible)
  local Speaker = nx_value("Speaker")
  if not nx_is_valid(Speaker) then
    return false
  end
  Speaker:SetMsgFormShowStatus(nx_boolean(b_visible))
end
