require("util_gui")
require("util_functions")
local NOTE_COL_DATE = 0
local NOTE_COL_TIME = 1
local NOTE_COL_SCENE = 2
local NOTE_COL_TYPE = 3
local NOTE_COL_ARG1 = 4
local NOTE_COL_ARG2 = 5
local NOTE_COL_ARG3 = 6
local RECORD_NAME = "new_note_rec"
local NOTR_PHOTO_INT = "share\\Rule\\NewNote\\note_photo.ini"
function open_form()
  util_auto_show_hide_form(nx_current())
end
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.btn_year.Visible = false
  set_scrollbar_date(form)
  show_note_date(form)
  show_year_btn(form)
  form.groupbox_main.Visible = false
  form.ani_back:Play()
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  return 1
end
function on_btn_close_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_scrollbar_note_value_changed(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_note_date(form)
end
function on_btn_year_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local year = nx_int(self.year)
  if nx_int(year) <= nx_int(0) then
    return
  end
  local rows = client_player:GetRecordRows(RECORD_NAME)
  if rows <= 0 then
    return false
  end
  for i = 0, rows - 1 do
    local data = client_player:QueryRecord(RECORD_NAME, i, NOTE_COL_DATE)
    if nx_int(data) > nx_int(year * 10000) then
      if nx_int(i) > nx_int(form.scrollbar_note.Maximum) then
        form.scrollbar_note.Value = form.scrollbar_note.Maximum
        local rbtn = form.groupbox_main:Find("rbtn_select_" .. nx_string(i - form.scrollbar_note.Maximum))
        if nx_is_valid(rbtn) then
          rbtn.Checked = true
        end
      else
        form.rbtn_select_0.Checked = true
        form.scrollbar_note.Value = i
      end
      return
    end
  end
end
function on_btn_wuxue_click(self)
  nx_execute("form_stage_main\\form_note\\form_note_wuxue_record", "open_form")
end
function on_btn_item_0_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_select_0.Checked = true
end
function on_btn_item_1_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_select_1.Checked = true
end
function on_btn_item_2_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_select_2.Checked = true
end
function on_btn_item_3_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_select_3.Checked = true
end
function on_btn_item_4_click(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_select_4.Checked = true
end
function on_ani_back_animation_end(self)
  local form = self.ParentForm
  if not nx_is_valid(form) then
    return
  end
  self.Visible = false
  form.groupbox_main.Visible = true
end
function set_scrollbar_date(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(RECORD_NAME)
  if rows < 0 then
    rows = 0
  end
  local bar_max = rows - 5
  if bar_max < 0 then
    bar_max = 0
  end
  form.scrollbar_note.Maximum = nx_int(bar_max)
  form.scrollbar_note.Value = 0
end
function show_note_date(form)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_item_0.Visible = false
  form.groupbox_item_1.Visible = false
  form.groupbox_item_2.Visible = false
  form.groupbox_item_3.Visible = false
  form.groupbox_item_4.Visible = false
  form.rbtn_select_0.Visible = false
  form.rbtn_select_1.Visible = false
  form.rbtn_select_2.Visible = false
  form.rbtn_select_3.Visible = false
  form.rbtn_select_4.Visible = false
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(RECORD_NAME)
  if rows <= 0 then
    return
  end
  local index_begin = nx_int(form.scrollbar_note.Value)
  local index_end = index_begin + 4
  if nx_int(index_end) > nx_int(rows - 1) then
    index_end = rows - 1
  end
  for i = 0, nx_number(index_end - index_begin) do
    local data = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_DATE)
    local time = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_TIME)
    local sence = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_SCENE)
    local type = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_TYPE)
    local arg1 = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_ARG1)
    local arg2 = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_ARG2)
    local arg3 = client_player:QueryRecord(RECORD_NAME, index_begin + i, NOTE_COL_ARG3)
    local gbox_item = form.groupbox_main:Find("groupbox_item_" .. nx_string(i))
    if not nx_is_valid(gbox_item) then
      return
    end
    local lbl_photo = gbox_item:Find("lbl_photo_" .. nx_string(i))
    local mltbox_text = gbox_item:Find("mltbox_text_" .. nx_string(i))
    if not nx_is_valid(lbl_photo) or not nx_is_valid(mltbox_text) then
      return
    end
    gbox_item.Visible = true
    if nx_int((index_begin + i) % 2) == nx_int(0) then
      gbox_item.Top = 220
      local gbox_hui = form.groupbox_main:Find("groupbox_hui_" .. nx_string(i))
      if nx_is_valid(gbox_item) then
        gbox_hui.Visible = true
      end
    else
      gbox_item.Top = 140
      local gbox_hui = form.groupbox_main:Find("groupbox_hui_" .. nx_string(i))
      if nx_is_valid(gbox_item) then
        gbox_hui.Visible = false
      end
    end
    local rbtn = form.groupbox_main:Find("rbtn_select_" .. nx_string(i))
    if nx_is_valid(rbtn) then
      rbtn.Visible = true
    end
    local grounb_photo, item_photo, item_text = get_note_show_info(type, arg1)
    gbox_item.BackImage = grounb_photo
    lbl_photo.BackImage = item_photo
    local year = nx_int(data / 10000)
    local month = nx_int(data % 10000 / 100)
    local day = nx_int(data % 100)
    local hour = nx_int(time / 10000)
    local min = nx_int(time % 10000 / 100)
    local szHour = "ui_new_note_time_" .. nx_string(nx_int(hour / 2))
    local data_text = nx_widestr(gui.TextManager:GetFormatText("ui_new_note_date", nx_int(year), nx_int(month), nx_int(day)))
    local time_text = nx_widestr(gui.TextManager:GetFormatText("ui_new_note_time", string.format("%02d", nx_number(hour)), string.format("%02d", nx_number(min))))
    local info_text = nx_widestr(gui.TextManager:GetFormatText(item_text, sence, nx_string(arg1), nx_string(arg2), nx_string(arg3)))
    if nx_int(type) == nx_int(3) or nx_int(type) == nx_int(9) then
      info_text = nx_widestr(gui.TextManager:GetFormatText(item_text, sence, nx_string(arg1), nx_int(arg2), nx_string(arg3)))
    end
    mltbox_text.HtmlText = data_text .. nx_widestr(util_text(szHour)) .. time_text .. info_text
    local month_text = ""
    if nx_int(index_begin + i) == nx_int(0) then
      month_text = nx_widestr(gui.TextManager:GetFormatText("ui_new_note_month", nx_int(year), nx_int(month)))
    else
      local last_date = client_player:QueryRecord(RECORD_NAME, index_begin + i - 1, NOTE_COL_DATE)
      if nx_int(data / 100) > nx_int(last_date / 100) then
        month_text = nx_widestr(gui.TextManager:GetFormatText("ui_new_note_month", nx_int(year), nx_int(month)))
      end
    end
    local lbl_month = form.groupbox_main:Find("lbl_month_" .. nx_string(i))
    if nx_is_valid(lbl_month) then
      lbl_month.Text = nx_widestr(month_text)
    end
  end
end
function create_ctrl(ctrl_name, refer_ctrl)
  local gui = nx_value("gui")
  if not nx_is_valid(refer_ctrl) then
    return nx_null()
  end
  local ctrl = gui:Create(ctrl_name)
  if not nx_is_valid(ctrl) then
    return nx_null()
  end
  local prop_tab = nx_property_list(refer_ctrl)
  for i = 1, table.getn(prop_tab) do
    nx_set_property(ctrl, prop_tab[i], nx_property(refer_ctrl, prop_tab[i]))
  end
  return ctrl
end
function get_note_show_info(type, arg1)
  local ini = nx_execute("util_functions", "get_ini", NOTR_PHOTO_INT)
  if not nx_is_valid(ini) then
    return "", ""
  end
  local sec_index = ini:FindSectionIndex(nx_string(type))
  if sec_index < 0 then
    return "", ""
  end
  local ground_photo = ini:ReadString(sec_index, "ground_photo", "")
  local item_info = ini:ReadString(sec_index, nx_string(arg1), "")
  local string_table = util_split_string(nx_string(item_info), ";")
  local item_photo = string_table[1]
  local item_text = string_table[2]
  if nx_string(item_photo) == "" or item_photo == nil then
    item_photo = ini:ReadString(sec_index, "item_photo", "")
  end
  if nx_string(item_text) == "" or item_text == nil then
    item_text = ini:ReadString(sec_index, "item_text", "")
  end
  return ground_photo, item_photo, item_text
end
function show_year_btn(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local rows = client_player:GetRecordRows(RECORD_NAME)
  if rows <= 0 then
    return
  end
  local begin_data = client_player:QueryRecord(RECORD_NAME, 0, NOTE_COL_DATE)
  local end_data = client_player:QueryRecord(RECORD_NAME, rows - 1, NOTE_COL_DATE)
  local begin_year = nx_int(begin_data / 10000)
  local end_year = nx_int(end_data / 10000)
  local index = 0
  for i = nx_number(begin_year), nx_number(end_year) do
    local btn = create_ctrl("Button", form.btn_year)
    btn.Left = btn.Left + index * 50
    btn.Text = nx_widestr(i) .. nx_widestr(util_text("ui_year"))
    btn.Visible = true
    btn.year = nx_int(i)
    nx_bind_script(btn, nx_current())
    nx_callback(btn, "on_click", "on_btn_year_click")
    form.groupbox_year:Add(btn)
    index = index + 1
  end
end
