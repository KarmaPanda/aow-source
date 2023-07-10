require("util_functions")
require("share\\client_custom_define")
require("util_gui")
require("util_vip")
local snatchbook_school_name = {
  "ui_duoshu_jy",
  "ui_duoshu_gb",
  "ui_duoshu_jz",
  "ui_duoshu_jl",
  "ui_duoshu_tm",
  "ui_duoshu_em",
  "ui_duoshu_wd",
  "ui_duoshu_sl",
  "ui_duoshu_mj",
  "ui_duoshu_ts"
}
local school_scene_id = {
  "school01",
  "school02",
  "school03",
  "school04",
  "school05",
  "school06",
  "school07",
  "school08",
  "school20",
  "school22"
}
local SNATCHBOOK_INI_PATH = "ini\\ui\\tvt\\tvt_snatchbook_map.ini"
local SCHOOL_MAX = 10
local CANGSHUTAI_POS_MAX = 10
function on_main_form_init(form)
  form.Fixed = false
  form.book_ini = nx_null()
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
  set_rbtn_type(form)
  form.rbtn_1.Checked = true
  form.book_ini = nx_execute("util_functions", "get_ini", SNATCHBOOK_INI_PATH)
  if not nx_is_valid(form.book_ini) then
    return
  end
  show_snatchbook_map_info(1)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  local cur_scene_id = client_scene:QueryProp("Resource")
  local school_count = table.getn(school_scene_id)
  for i = 1, school_count do
    if cur_scene_id == school_scene_id[i] then
      form.rbtn_1.Checked = true
      set_btn_check(form, i)
      show_snatchbook_map_info(i)
      break
    end
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_rbtn_checked_changed(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  show_snatchbook_map_info(btn.imagetype)
end
function set_btn_check(form, index)
  if index == 1 then
    form.rbtn_1.Checked = true
  elseif index == 2 then
    form.rbtn_2.Checked = true
  elseif index == 3 then
    form.rbtn_3.Checked = true
  elseif index == 4 then
    form.rbtn_4.Checked = true
  elseif index == 5 then
    form.rbtn_5.Checked = true
  elseif index == 6 then
    form.rbtn_6.Checked = true
  elseif index == 7 then
    form.rbtn_7.Checked = true
  elseif index == 8 then
    form.rbtn_8.Checked = true
  elseif index == 9 then
    form.rbtn_9.Checked = true
  else
    form.rbtn_10.Checked = true
  end
end
function show_snatchbook_map_info(imagetype)
  local form = nx_value("form_stage_main\\form_tvt\\form_tvt_snatchbook_map")
  if not nx_is_valid(form) then
    return
  end
  if imagetype > SCHOOL_MAX or imagetype < 1 then
    return
  end
  local ini = form.book_ini
  if not nx_is_valid(ini) then
    return
  end
  local section_count = ini:GetSectionCount()
  if section_count > SCHOOL_MAX then
    return
  end
  local index = imagetype - 1
  local schoolmap = ini:ReadString(index, "schoolmap", "")
  local sceneid = ini:ReadString(index, "sceneid", "")
  form.lbl_map.BackImage = schoolmap
  form.lbl_map.sceneid = sceneid
  for i = 1, CANGSHUTAI_POS_MAX do
    local pos = ini:ReadString(index, "pos" .. nx_string(i), "")
    local pos_list = util_split_string(nx_string(pos), ",")
    local posx = nx_number(pos_list[1])
    local posy = nx_number(pos_list[2])
    local tips = ini:ReadString(index, "tips" .. nx_string(i), "")
    local pathpos = ini:ReadString(index, "pathpos" .. nx_string(i), "")
    local pathpos_list = util_split_string(nx_string(pathpos), ",")
    local pathposx = nx_number(pathpos_list[1])
    local pathposz = nx_number(pathpos_list[2])
    local btn_book = nx_custom(form, "btn_book" .. nx_string(i))
    if nx_is_valid(btn_book) then
      btn_book.Left = posx
      btn_book.Top = posy
      btn_book.tips = tips
      btn_book.pathposx = pathposx
      btn_book.pathposz = pathposz
    end
  end
end
function set_rbtn_type(form)
  if not nx_is_valid(form) then
    return
  end
  form.rbtn_1.imagetype = 1
  form.rbtn_2.imagetype = 2
  form.rbtn_3.imagetype = 3
  form.rbtn_4.imagetype = 4
  form.rbtn_5.imagetype = 5
  form.rbtn_6.imagetype = 6
  form.rbtn_7.imagetype = 7
  form.rbtn_8.imagetype = 8
  form.rbtn_9.imagetype = 9
  form.rbtn_10.imagetype = 10
  form.lbl_map.sceneid = ""
  for i = 1, CANGSHUTAI_POS_MAX do
    local btn_book = nx_custom(form, "btn_book" .. nx_string(i))
    if nx_is_valid(btn_book) then
      btn_book.tips = ""
      btn_book.pathposx = 0
      btn_book.pathposz = 0
    end
  end
end
function on_show_label_tips(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local desc = gui.TextManager:GetText("tips_duoshu_shujia") .. nx_widestr("<br>") .. gui.TextManager:GetText(btn.tips)
  nx_execute("tips_game", "show_text_tip", nx_widestr(desc), btn.AbsLeft, btn.AbsTop, 0, form)
end
function on_hide_label_tips(btn)
  nx_execute("tips_game", "hide_tip")
end
function on_btn_book_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local role = nx_value("role")
  if nx_is_valid(role) and nx_find_custom(role, "find_path_limit") and role.find_path_limit == true then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_scene = game_client:GetScene()
  local cur_scene_id = client_scene:QueryProp("Resource")
  local pos_x = btn.pathposx
  local pos_z = btn.pathposz
  local scene_id = form.lbl_map.sceneid
  local player = game_client:GetPlayer()
  local path_finding = nx_value("path_finding")
  if not nx_is_valid(path_finding) then
    return
  end
  local trace_flag = path_finding.AutoTraceFlag
  if cur_scene_id == scene_id then
    nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", "", pos_x, -10000, pos_z, cur_scene_id)
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPath(pos_x, -10000, pos_z, 0)
    end
  else
    nx_execute("form_stage_main\\form_map\\form_map_scene", "set_trace_npc_id", "", pos_x, -10000, pos_z, scene_id)
    if trace_flag == 1 or trace_flag == 2 then
      path_finding:FindPathScene(scene_id, pos_x, -10000, pos_z, 0)
    end
  end
end
function show_school_book_info(...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tvt\\form_tvt_snatchbook_map", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local count = table.getn(arg)
  local school_count = table.getn(snatchbook_school_name)
  if count > school_count then
    return
  end
  form.mltbox_book_info:Clear()
  for i = 1, count do
    if nx_number(arg[i]) > 0 then
      local desc = gui.TextManager:GetText(snatchbook_school_name[i]) .. nx_widestr("  ") .. nx_widestr(arg[i])
      form.mltbox_book_info:AddHtmlText(desc, -1)
    end
  end
end
