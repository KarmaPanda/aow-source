require("util_functions")
require("util_gui")
require("share\\view_define")
require("share\\client_custom_define")
local ENCHOU_TYPE = {}
function open_form()
  util_show_form("form_stage_main\\form_relation\\form_relation_enchou", true)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(nx_value("form_stage_main\\form_relation\\form_relation_enchou"))
end
function open_by_tvt()
  util_show_form("form_stage_main\\form_relation\\form_relation_enchou", true)
  open_form_by_type(4, ENCHOU_TYPE[4][2])
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  gui.Desktop:ToFront(nx_value("form_stage_main\\form_relation\\form_relation_enchou"))
end
function main_form_init(form)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Fixed = false
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  form.main_type = 1
  form.sub_type = form.main_type * 100 + 1
  form.IsInitNpcListForm = false
  return 1
end
function on_main_form_open(form)
  init_enchou_type()
  open_form_by_type(1, ENCHOU_TYPE[1][1])
end
function open_form_by_type(main_type, sub_type)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  form.main_type = main_type
  form.sub_type = sub_type
  form.groupbox_main:DeleteAll()
  for i, _ in ipairs(ENCHOU_TYPE) do
    local loc = math.floor(ENCHOU_TYPE[i][1] / 100)
    local clone = clone_radiobutton(form.rbtn_main_template)
    clone.Name = "btn_main_" .. nx_string(i)
    clone.id = i
    clone.Left = 20 + (i - 1) * clone.Width
    clone.Top = -1
    clone.Text = nx_widestr(gui.TextManager:GetText("ECTypeName_" .. nx_string(loc)))
    nx_bind_script(clone, nx_current())
    nx_callback(clone, "on_checked_changed", "on_rbtn_main_checked_changed")
    form.groupbox_main:Add(clone)
  end
  local main_rbtn = form.groupbox_main:Find("btn_main_" .. nx_string(main_type))
  if not nx_is_valid(main_rbtn) then
    return
  end
  main_rbtn.Checked = true
  local sub_rbtn = form.groupbox_sub:Find("btn_sub_" .. nx_string(sub_type))
  if not nx_is_valid(sub_rbtn) then
    return
  end
  sub_rbtn.Checked = true
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) or not form.Visible then
    return
  end
  on_main_form_close(form)
end
function on_rbtn_main_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if not nx_is_valid(form) then
    return
  end
  if form.IsInitNpcListForm then
    form.form_npc_list.Visible = false
  end
  form.cbb_scene.Visible = false
  form.cbb_relation.Visible = false
  if not nx_find_custom(btn, "id") then
    return
  end
  local loc = math.floor(ENCHOU_TYPE[btn.id][1] / 100)
  if nx_number(loc) == nx_number(5) then
    if not form.IsInitNpcListForm then
      local form_npc_list = util_get_form("form_stage_main\\form_relation\\form_enchou_npc_list", true, false)
      if form:Add(form_npc_list) then
        form.form_npc_list = form_npc_list
        form.form_npc_list.Left = 2
        form.form_npc_list.Top = form.groupbox_sub.Top - 1
        form.form_npc_list.Visible = false
        form.IsInitNpcListForm = true
      end
    end
    form.form_npc_list.Visible = true
    form:ToFront(form.form_npc_list)
    form.cbb_scene.Visible = true
    form.cbb_relation.Visible = true
    return
  end
  local gui = nx_value("gui")
  local main_id = btn.id
  form.main_type = main_id
  form.groupbox_sub:DeleteAll()
  for i, val in ipairs(ENCHOU_TYPE[main_id]) do
    local clone = clone_radiobutton(form.rbtn_sub_template)
    clone.Name = "btn_sub_" .. nx_string(val)
    clone.id = val
    clone.Left = 5
    clone.Top = 20 + (i - 1) * (clone.Height + 2)
    clone.Text = nx_widestr(gui.TextManager:GetText("ECName_" .. nx_string(val)))
    nx_bind_script(clone, nx_current())
    nx_callback(clone, "on_checked_changed", "on_rbtn_sub_checked_changed")
    form.groupbox_sub:Add(clone)
    if i == 1 then
      clone.Checked = true
    end
  end
end
function on_rbtn_sub_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  local id = btn.id
  form.sub_type = id
  form.mltbox_intro.HtmlText = gui.TextManager:GetText("ECIntroduce_" .. nx_string(id))
  form.mltbox_prog.HtmlText = gui.TextManager:GetText("ECProgram_" .. nx_string(id))
  form.lbl_pic.BackImage = "gui\\special\\karmahelp\\" .. nx_string(id) .. ".png"
  form.lbl_name.Text = gui.TextManager:GetText("ECName_" .. nx_string(id))
  form.lbl_difficulty.Text = gui.TextManager:GetText("ECDifficulty_" .. nx_string(id))
  form.lbl_limit.Text = gui.TextManager:GetText("ECLimit_" .. nx_string(id))
  form.lbl_open_time.Text = gui.TextManager:GetText("ECOpenTime_" .. nx_string(id))
  form.lbl_award.Text = gui.TextManager:GetText("ECAward_" .. nx_string(id))
  form.rbtn_rule.Checked = true
  on_rbtn_info_changed(form.rbtn_rule)
  show_or_hide_func_btn(id)
end
function on_rbtn_info_changed(btn)
  if btn.Checked then
    local form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
    if not nx_is_valid(form) then
      return
    end
    local gui = nx_value("gui")
    local name = nx_string(btn.Name)
    if name == "rbtn_rule" then
      form.mltbox_info.HtmlText = gui.TextManager:GetText("ECRule_" .. nx_string(form.sub_type))
    elseif name == "rbtn_notice" then
      form.mltbox_info.HtmlText = gui.TextManager:GetText("ECNotice_" .. nx_string(form.sub_type))
    end
  end
end
function on_btn_func_click(btn)
  local gui = nx_value("gui")
  if nx_int(btn.id) == nx_int(202) then
    util_show_form("form_stage_main\\form_origin\\form_kapai", true)
    gui.Desktop:ToFront(nx_value("form_stage_main\\form_origin\\form_kapai"))
  elseif nx_int(btn.id) == nx_int(201) then
    local form = nx_value("form_stage_main\\form_role_info\\form_role_info")
    if nx_is_valid(form) then
      if not form.Visible then
        form.Visible = true
      end
    else
      nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
    end
    gui.Desktop:ToFront(form)
    form = nx_value("form_stage_main\\form_role_info\\form_role_info")
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "on_rbtn_info_click", form.rbtn_2)
    form.rbtn_2.Checked = true
  elseif nx_int(btn.id) == nx_int(203) then
    local form = nx_value("form_stage_main\\form_role_info\\form_role_info")
    if nx_is_valid(form) then
      if not form.Visible then
        form.Visible = true
      end
    else
      nx_execute("form_stage_main\\form_role_info\\form_role_info", "auto_show_hide_role_info")
    end
    gui.Desktop:ToFront(form)
    form = nx_value("form_stage_main\\form_role_info\\form_role_info")
    nx_execute("form_stage_main\\form_role_info\\form_role_info", "on_rbtn_info_click", form.rbtn_7)
    form.rbtn_7.Checked = true
  elseif nx_int(btn.id) == nx_int(402) then
    local data = "jhqb,jianghuzd02,jhzhibao03,jhzhibaojj04"
    nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", data)
  end
end
function show_or_hide_func_btn(id)
  local gui = nx_value("gui")
  local form = nx_value("form_stage_main\\form_relation\\form_relation_enchou")
  if not nx_is_valid(form) then
    return
  end
  form.btn_func.id = id
  form.btn_func.Visible = true
  if nx_int(id) == nx_int(201) then
    form.btn_func.Text = gui.TextManager:GetText("ui_karmaexp")
  elseif nx_int(id) == nx_int(202) then
    form.btn_func.Text = gui.TextManager:GetText("ui_prestige_name")
  elseif nx_int(id) == nx_int(203) then
    form.btn_func.Text = gui.TextManager:GetText("ecname_203")
  elseif nx_int(id) == nx_int(402) then
    form.btn_func.Text = gui.TextManager:GetText("tvt_name_031")
  else
    form.btn_func.Visible = false
  end
end
function clone_radiobutton(source)
  local gui = nx_value("gui")
  local clone = gui:Create("RadioButton")
  clone.Name = source.Name
  clone.Left = source.Left
  clone.Top = source.Top
  clone.Width = source.Width
  clone.Height = source.Height
  clone.ForeColor = source.ForeColor
  clone.ShadowColor = source.ShadowColor
  clone.Font = source.Font
  clone.NormalImage = source.NormalImage
  clone.FocusImage = source.FocusImage
  clone.CheckedImage = source.CheckedImage
  clone.TabIndex = source.TabIndex
  clone.TabStop = source.TabStop
  clone.NormalColor = source.NormalColor
  clone.FocusColor = source.FocusColor
  clone.PushColor = source.PushColor
  clone.DisableColor = source.DisableColor
  clone.BackColor = source.BackColor
  clone.ShadowColor = source.ShadowColor
  clone.Text = source.Text
  clone.AutoSize = source.AutoSize
  clone.BoxSize = source.BoxSize
  clone.InSound = source.InSound
  clone.ClickSound = source.ClickSound
  clone.DrawMode = source.DrawMode
  return clone
end
function init_enchou_type()
  local ini = get_ini("share\\Karma\\karmahelp.ini")
  if not nx_is_valid(ini) then
    return
  end
  ENCHOU_TYPE = {}
  local count = ini:GetSectionCount()
  for i = 0, count - 1 do
    local type = ini:GetSectionByIndex(i)
    local item_num = ini:GetSectionItemCount(i)
    for j = 0, item_num - 1 do
      local value = ini:GetSectionItemValue(i, j)
      local tmp_table = {}
      local str_lst = util_split_string(nx_string(value), ",")
      for _, v in ipairs(str_lst) do
        table.insert(tmp_table, v)
      end
      table.insert(ENCHOU_TYPE, tmp_table)
    end
  end
end
