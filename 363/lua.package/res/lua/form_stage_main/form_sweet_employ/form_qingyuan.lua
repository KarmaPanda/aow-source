require("util_gui")
require("util_functions")
require("form_stage_main\\form_sweet_employ\\sweet_employ_define")
local FORM_QINGYUAN = "form_stage_main\\form_sweet_employ\\form_qingyuan"
local FORM_CONFIRM = "form_common\\form_confirm"
local SWEET_COMMON = "form_stage_main\\form_sweet_employ\\form_employ_common"
local IMAGE_BG_SELECT = "gui\\special\\sweetemploy\\sweetemploy_subdirectories_on.png"
local IMAGE_BG_NOT_SELECT = "gui\\special\\sweetemploy\\sweetemploy_subdirectories_out.png"
local IMAGE_BTN_GOPLAYER_ON = "gui\\special\\sweetemploy\\sweetemploy_button_1_on.png"
local IMAGE_BTN_GOPLAYER_OUT = "gui\\special\\sweetemploy\\sweetemploy_button_1_out.png"
local IMAGE_BTN_GOPLAYER_DOWN = "gui\\special\\sweetemploy\\sweetemploy_button_1_down.png"
local INVALID_SELECT_INDEX = -1
local CHARACTER_ALL = 150
local RELATION_FRIEND = 0
local RELATION_BUDDY = 1
local RELATION_ALL = 2
local LOOKUP_BY_NAME = 1
local LOOKUP_BY_CONDITION = 2
local table_lbl_bg = {}
local table_lbl_name = {}
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  set_form_pos(form)
  init_cbox_strength(form)
  init_cbtn_character(form)
  init_cbtn_relation(form)
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function set_form_pos(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_btn_lookup_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local level = form.cbox_strength.DropListBox.SelectIndex
  if nx_int(level) < nx_int(0) then
    level = nx_int(0)
  end
  if nx_int(level) > nx_int(MAX_LEVEL_TITLE) then
    return
  end
  local offline_character = form.offline_character
  if (nx_int(offline_character) < nx_int(MIN_OFFLINE_CHARACTER) or nx_int(offline_character) > nx_int(MAX_OFFLINE_CHARACTER)) and nx_int(offline_character) ~= nx_int(CHARACTER_ALL) then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(4), nx_int(level), nx_int(offline_character))
end
function clear_qingyuan_list()
  local form = nx_value(FORM_QINGYUAN)
  if not nx_is_valid(form) then
    return
  end
  form.gsb_qy:DeleteAll()
end
function on_server_msg_show_qingyuan(lookup_type, ...)
  clear_qingyuan_list()
  local arg_num = table.getn(arg)
  if nx_int(arg_num) == nx_int(0) then
    return
  end
  if nx_int(arg_num % 7) ~= nx_int(0) then
    return
  end
  local form = nx_value(FORM_QINGYUAN)
  if not nx_is_valid(form) then
    return
  end
  form.btn_add_attention.Enabled = false
  form.btn_lookup_strength.Enabled = false
  nx_set_custom(form.gsb_qy, "qy_count", nx_int(0))
  nx_set_custom(form.gsb_qy, "select_index", nx_int(INVALID_SELECT_INDEX))
  table_lbl_bg = {}
  table_lbl_name = {}
  form.gsb_qy.IsEditMode = true
  for i = 1, arg_num, 7 do
    local name = nx_widestr(arg[i])
    local character = nx_int(arg[i + 1])
    local level = nx_string(arg[i + 2])
    local sex = nx_int(arg[i + 3])
    local x = nx_int(arg[i + 4])
    local z = nx_int(arg[i + 5])
    local qy_type = nx_int(arg[i + 6])
    local gb_qy = create_gb_qy(form, lookup_type, name, character, level, sex, x, z, qy_type)
    if nx_is_valid(gb_qy) then
      add_gb_qy_callback(gb_qy)
      add_gb_to_gsb(gb_qy, form.gsb_qy)
    end
  end
  form.gsb_qy.IsEditMode = false
end
function create_lbl_name(form, name)
  local gui = nx_value("gui")
  local lbl_name = gui:Create("Label")
  lbl_name.Left = form.lbl_name.Left
  lbl_name.Top = 0
  lbl_name.Width = 70
  lbl_name.Height = 30
  lbl_name.Text = nx_widestr(name)
  lbl_name.Font = "font_text_fiqure"
  lbl_name.ForeColor = "255,128,101,74"
  lbl_name.Align = "Center"
  lbl_name.Transparent = true
  lbl_name.Name = "lbl_name_" .. nx_string(form.gsb_qy.qy_count)
  return lbl_name
end
function create_lbl_character(form, character, sex)
  local gui = nx_value("gui")
  local lbl_character = gui:Create("Label")
  lbl_character.Left = form.lbl_character.Left
  lbl_character.Top = 0
  lbl_character.Width = 70
  lbl_character.Height = 30
  lbl_character.Font = "font_text_fiqure"
  lbl_character.ForeColor = "255,128,101,74"
  lbl_character.Align = "Center"
  lbl_character.Transparent = false
  lbl_character.Name = "lbl_character_" .. nx_string(form.gsb_qy.qy_count)
  local text = get_sweet_character_text(character, sex)
  local show, new_text = is_need_show_hinttext(text)
  if show then
    lbl_character.Text = new_text
    lbl_character.HintText = text
  else
    lbl_character.Text = text
  end
  return lbl_character
end
function create_lbl_level(form, level)
  local gui = nx_value("gui")
  local lbl_level = gui:Create("Label")
  lbl_level.Left = form.lbl_level.Left
  lbl_level.Top = 0
  lbl_level.Width = 70
  lbl_level.Height = 30
  lbl_level.Font = "font_text_fiqure"
  lbl_level.ForeColor = "255,128,101,74"
  lbl_level.Align = "Center"
  lbl_level.Transparent = false
  lbl_level.Name = "lbl_level_" .. nx_string(form.gsb_qy.qy_count)
  local text = nx_widestr(util_text("desc_" .. level))
  local show, new_text = is_need_show_hinttext(text)
  if show then
    lbl_level.Text = new_text
    lbl_level.HintText = text
  else
    lbl_level.Text = text
  end
  return lbl_level
end
function create_lbl_pos(form, x, z)
  local gui = nx_value("gui")
  local lbl_pos = gui:Create("Label")
  lbl_pos.Left = form.lbl_pos.Left
  lbl_pos.Top = 0
  lbl_pos.Width = 70
  lbl_pos.Height = 30
  lbl_pos.Text = nx_widestr("(") .. nx_widestr(x) .. nx_widestr(",") .. nx_widestr(z) .. nx_widestr(")")
  lbl_pos.Font = "font_text_fiqure"
  lbl_pos.ForeColor = "255,128,101,74"
  lbl_pos.Align = "Center"
  lbl_pos.Transparent = true
  lbl_pos.Name = "lbl_pos_" .. nx_string(form.gsb_qy.qy_count)
  return lbl_pos
end
function create_gb_qy(form, lookup_type, name, character, level, sex, x, z, qy_type)
  if nx_int(lookup_type) == nx_int(LOOKUP_BY_CONDITION) and not is_relation_satisfy(form, name) then
    return nx_null()
  end
  local gui = nx_value("gui")
  local gb_qy = gui:Create("GroupBox")
  gb_qy.Width = 726
  gb_qy.Height = 30
  gb_qy.NoFrame = true
  gb_qy.DrawMode = "FitWindow"
  gb_qy.BackImage = "gui\\special\\tiguan\\tiguan_rank_bar_2.png"
  gb_qy.Name = "gb_qy_" .. nx_string(form.gsb_qy.qy_count)
  local lbl_name = create_lbl_name(form, name)
  if nx_is_valid(lbl_name) then
    gb_qy:Add(lbl_name)
    table.insert(table_lbl_name, lbl_name)
  end
  local lbl_pos = create_lbl_pos(form, x, z)
  if nx_is_valid(lbl_pos) then
    gb_qy:Add(lbl_pos)
  end
  local btn_goplayer = create_btn_goplayer(form)
  if nx_is_valid(btn_goplayer) then
    add_btn_goplayer_callback(btn_goplayer)
    gb_qy:Add(btn_goplayer)
  end
  local lbl_bg = create_lbl_bg(form)
  if nx_is_valid(lbl_bg) then
    add_lbl_bg_callback(lbl_bg)
    gb_qy:Add(lbl_bg)
    table.insert(table_lbl_bg, lbl_bg)
  end
  local lbl_character = create_lbl_character(form, character, sex)
  if nx_is_valid(lbl_character) then
    gb_qy:Add(lbl_character)
  end
  local lbl_qy = create_lbl_qingyuan(form, qy_type)
  if nx_is_valid(lbl_qy) then
    gb_qy:Add(lbl_qy)
  end
  local lbl_level = create_lbl_level(form, level)
  if nx_is_valid(lbl_level) then
    gb_qy:Add(lbl_level)
  end
  return gb_qy
end
function add_gb_qy_callback(gb)
  nx_bind_script(gb, nx_current())
end
function add_gb_to_gsb(gb, gsb)
  gb.Left = 0
  gb.Top = gb.Height * gsb.qy_count + 5
  gsb:Add(gb)
  local count = gsb.qy_count + 1
  nx_set_custom(gsb, "qy_count", nx_int(count))
end
function create_lbl_bg(form)
  local gui = nx_value("gui")
  local lbl_bg = gui:Create("Label")
  lbl_bg.Left = form.gsb_qy.Left
  lbl_bg.Top = 0
  lbl_bg.Width = form.lbl_goplayer.Left - form.lbl_name.Left
  lbl_bg.Height = 38
  lbl_bg.NoFrame = true
  lbl_bg.DrawMode = "FitWindow"
  lbl_bg.BackImage = IMAGE_BG_NOT_SELECT
  lbl_bg.Transparent = false
  lbl_bg.ClickEvent = true
  lbl_bg.DataSource = nx_string(form.gsb_qy.qy_count)
  lbl_bg.Name = "lbl_bg_" .. nx_string(form.gsb_qy.qy_count)
  return lbl_bg
end
function add_lbl_bg_callback(lbl_bg)
  nx_bind_script(lbl_bg, nx_current())
  nx_callback(lbl_bg, "on_click", "on_lbl_bg_click")
end
function on_lbl_bg_click(lbl)
  local form = lbl.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local count = table.getn(table_lbl_bg)
  for i = 1, count do
    if nx_is_valid(table_lbl_bg[i]) then
      table_lbl_bg[i].BackImage = IMAGE_BG_NOT_SELECT
    end
  end
  lbl.BackImage = IMAGE_BG_SELECT
  nx_set_custom(form.gsb_qy, "select_index", nx_int(lbl.DataSource))
  form.btn_add_attention.Enabled = true
  form.btn_lookup_strength.Enabled = true
end
function get_player_name_by_index(form, i)
  local count = table.getn(table_lbl_name)
  if nx_int(count) <= nx_int(0) then
    return ""
  end
  if nx_int(i) < nx_int(0) or nx_int(i) >= nx_int(count) then
    return ""
  end
  local lbl_name = table_lbl_name[i + 1]
  if not nx_is_valid(lbl_name) then
    return ""
  end
  local name = lbl_name.Text
  return name
end
function on_btn_lookup_strength_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = get_player_name_by_index(form, form.gsb_qy.select_index)
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(12), nx_widestr(name))
end
function on_btn_search_name_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = form.edit_name.Text
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(4), nx_widestr(name))
end
function on_btn_add_attention_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local name = get_player_name_by_index(form, form.gsb_qy.select_index)
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return
  end
  nx_execute("form_stage_main\\form_relation\\form_relation", "interface_add_attention", name)
end
function init_cbox_strength(form)
  local droplistbox = form.cbox_strength.DropListBox
  droplistbox:ClearString()
  droplistbox:AddString(nx_widestr(util_text("str_quanbu")))
  for i = MIN_LEVEL_TITLE, MAX_LEVEL_TITLE do
    local level_title = "desc_title"
    if nx_int(i) < nx_int(10) then
      level_title = level_title .. nx_string("00") .. nx_string(i)
    else
      level_title = level_title .. nx_string("0") .. nx_string(i)
    end
    local desc_title = util_text(level_title)
    droplistbox:AddString(nx_widestr(desc_title))
  end
  form.cbox_strength.Text = nx_widestr(util_text("str_quanbu"))
end
function is_player_male()
  local sex = nx_execute(SWEET_COMMON, "get_player_prop", "Sex")
  if nx_int(sex) == nx_int(SEX_MALE) then
    return true
  end
  return false
end
function init_cbtn_character(form)
  for i = 0, 4 do
    local name_ctrl = "cbtn_" .. nx_string(i)
    local ctrl = form.gb_character:Find(name_ctrl)
    if not nx_is_valid(ctrl) then
      return
    end
    ctrl.Checked = false
  end
  nx_set_custom(form, "offline_character", nx_int(CHARACTER_ALL))
end
function on_cbtn_character_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  for i = 0, 4 do
    local name_ctrl = "cbtn_" .. nx_string(i)
    local ctrl = form.gb_character:Find(name_ctrl)
    if nx_is_valid(ctrl) and not nx_id_equal(ctrl, cbtn) then
      ctrl.Checked = false
    end
  end
  if cbtn.Checked then
    nx_set_custom(form, "offline_character", nx_int(cbtn.DataSource))
  else
    nx_set_custom(form, "offline_character", nx_int(CHARACTER_ALL))
  end
end
function init_cbtn_relation(form)
  form.cbtn_friend.Checked = false
  form.cbtn_buddy.Checked = false
  nx_set_custom(form, "relation", nx_int(RELATION_ALL))
end
function on_cbtn_friend_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_buddy.Checked = false
  if cbtn.Checked then
    nx_set_custom(form, "relation", nx_int(RELATION_FRIEND))
  else
    nx_set_custom(form, "relation", nx_int(RELATION_ALL))
  end
end
function on_cbtn_buddy_click(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.cbtn_friend.Checked = false
  if cbtn.Checked then
    nx_set_custom(form, "relation", nx_int(RELATION_BUDDY))
  else
    nx_set_custom(form, "relation", nx_int(RELATION_ALL))
  end
end
function is_relation_satisfy(form, name)
  local rec_name = ""
  if nx_int(form.relation) == nx_int(RELATION_FRIEND) then
    rec_name = REC_FRIEND
  elseif nx_int(form.relation) == nx_int(RELATION_BUDDY) then
    rec_name = REC_BUDDY
  elseif nx_int(form.relation) == nx_int(RELATION_ALL) then
    return true
  else
    return false
  end
  local client = nx_value("game_client")
  if not nx_is_valid(client) then
    return false
  end
  local player = client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  local row = player:FindRecordRow(rec_name, 1, name, 0)
  if nx_int(row) < nx_int(0) then
    return false
  end
  return true
end
function get_sweet_character_text(offline_character, sex)
  if nx_int(offline_character) < nx_int(MIN_OFFLINE_CHARACTER) or nx_int(offline_character) > nx_int(MAX_OFFLINE_CHARACTER) then
    if nx_int(offline_character) == nx_int(OFFLINE_CHARACTER_SET_CANCEL) then
      return nx_widestr(util_text("ui_off_accost_weizhi"))
    else
      return nx_widestr("")
    end
  end
  local index = offline_character - 100
  local text_id_pre = "ui_off_accost_title"
  if nx_int(sex) == nx_int(SEX_FEMALE) then
    text_id_pre = text_id_pre .. nx_string("_g_")
  else
    text_id_pre = text_id_pre .. nx_string("_b_")
  end
  local text_id = text_id_pre .. nx_string(index)
  return nx_widestr(util_text(text_id))
end
function create_btn_goplayer(form)
  local gui = nx_value("gui")
  local btn_goplayer = gui:Create("Button")
  btn_goplayer.Left = form.lbl_goplayer.Left
  btn_goplayer.Top = 0
  btn_goplayer.Width = 100
  btn_goplayer.Height = 26
  btn_goplayer.Text = nx_widestr(util_text("ui_qingyuan_meet"))
  btn_goplayer.NoFrame = true
  btn_goplayer.Font = "font_btn"
  btn_goplayer.ShadowColor = "0,255,0,0"
  btn_goplayer.ShadowColor = "0,255,0,0"
  btn_goplayer.DisableColor = "255,0,0,0"
  btn_goplayer.ForeColor = "255,255,255,255"
  btn_goplayer.DrawMode = "ExpandH"
  btn_goplayer.FocusImage = IMAGE_BTN_GOPLAYER_ON
  btn_goplayer.NormalImage = IMAGE_BTN_GOPLAYER_OUT
  btn_goplayer.PushImage = IMAGE_BTN_GOPLAYER_DOWN
  btn_goplayer.Transparent = false
  btn_goplayer.ClickEvent = true
  btn_goplayer.DataSource = nx_string(get_player_name_by_index(form, form.gsb_qy.qy_count))
  btn_goplayer.Name = "btn_goplayer_" .. nx_string(form.gsb_qy.qy_count)
  return btn_goplayer
end
function add_btn_goplayer_callback(btn)
  nx_bind_script(btn, nx_current())
  nx_callback(btn, "on_click", "on_btn_goplayer_click")
end
function on_btn_goplayer_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local dialog = util_get_form(FORM_CONFIRM, true, false)
  if not nx_is_valid(dialog) then
    return
  end
  nx_execute(FORM_CONFIRM, "show_common_text", dialog, util_text("ui_sns_forms_transmit_001"))
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res ~= "ok" then
    return
  end
  local name = btn.DataSource
  if nx_ws_equal(nx_widestr(name), nx_widestr("")) then
    return
  end
  nx_execute("custom_sender", "custom_offline_employ", nx_int(13), nx_widestr(name))
end
function create_lbl_qingyuan(form, qy_type)
  local gui = nx_value("gui")
  local lbl_qingyuan = gui:Create("Label")
  lbl_qingyuan.Left = form.lbl_qingyuan.Left
  lbl_qingyuan.Top = 0
  lbl_qingyuan.Width = 120
  lbl_qingyuan.Height = 30
  lbl_qingyuan.Font = "font_text_fiqure"
  lbl_qingyuan.ForeColor = "255,128,101,74"
  lbl_qingyuan.Align = "Center"
  lbl_qingyuan.Transparent = false
  lbl_qingyuan.Name = "lbl_qingyuan_" .. nx_string(form.gsb_qy.qy_count)
  local text = nx_widestr(util_text("ui_qingyuan_info0" .. nx_string(qy_type)))
  local show, new_text = is_need_show_hinttext(text)
  if show then
    lbl_qingyuan.Text = new_text
    lbl_qingyuan.HintText = text
  else
    lbl_qingyuan.Text = text
  end
  return lbl_qingyuan
end
function is_need_show_hinttext(text)
  if nx_ws_length(text) > 18 then
    local new_text = nx_function("ext_ws_substr", text, 0, 17) .. nx_widestr("...")
    return true, new_text
  end
  return false, text
end
