require("custom_sender")
require("share\\view_define")
require("share\\itemtype_define")
require("define\\gamehand_type")
require("util_gui")
local SHILIAN_PHOTO = {
  ["00"] = "gui\\clone_new\\sj_1.png",
  ["01"] = "gui\\clone_new\\sj_2.png",
  ["02"] = "gui\\clone_new\\sj_3.png",
  ["03"] = "gui\\clone_new\\sj_4.png",
  ["10"] = "gui\\clone_new\\sj_red_2.png",
  ["20"] = "gui\\clone_new\\sj_red_3.png",
  ["30"] = "gui\\clone_new\\sj_red_4.png",
  ["12"] = "gui\\clone_new\\sj_red_5.png",
  ["13"] = "gui\\clone_new\\sj_red_6.png",
  ["23"] = "gui\\clone_new\\sj_red_7.png"
}
local max_progress = 10
function main_form_init(form)
  form.Fixed = false
  form.cur_lay_flag = 0
  form.reset_num_flag = 0
  form.tips_num_flag = 0
end
function on_main_form_open(form)
  if not nx_is_valid(form) then
    return
  end
  init_form(form)
  nx_execute("custom_sender", "custom_form_ttf_template", 4)
end
function on_main_form_close(form)
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function init_form(form)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local ttf_level = gui.TextManager:GetText("ui_ttf_level")
  local ttf_level_intr = gui.TextManager:GetText("ui_ttf_level_intr")
  local ttf_level_prog = gui.TextManager:GetText("ui_ttf_level_prog")
  local ttf_level_info = gui.TextManager:GetText("ui_ttf_level_info")
  form.lbl_current_layer.Text = ttf_level
  form.lbl_max_score.Text = nx_widestr("0")
  form.lbl_progress.Text = ttf_level_prog
  form.mltbox_current_play_info:Clear()
  form.mltbox_current_play_info:AddHtmlText(nx_widestr(ttf_level_intr), nx_int(-1))
  form.mltbox_guanka_info:Clear()
  form.mltbox_guanka_info:AddHtmlText(nx_widestr(ttf_level_info), nx_int(-1))
end
function refresh_shilian_info_form(form, weapon_num, total_score, current_layer, current_layer_playid, max_score, each_weapon_num, guanka_list, reset_num, isSuccess, max_weapon_num, max_guanka_num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.reset_num_flag = reset_num
  form.cur_lay_flag = current_layer
  form.tips_num_flag = total_score
  if current_layer == nx_int(0) then
    if max_score > nx_int(0) then
      form.lbl_max_score.Text = nx_widestr(max_score)
    else
      init_form(form)
    end
    local btn_state_id = gui.TextManager:GetText("ui_ttf_1")
    form.btn_state.Text = nx_widestr(btn_state_id)
  else
    local btn_state_id = gui.TextManager:GetText("ui_ttf_2")
    form.btn_state.Text = nx_widestr(btn_state_id)
    local gui = nx_value("gui")
    gui.TextManager:Format_SetIDName("ui_ttf_4")
    gui.TextManager:Format_AddParam(current_layer)
    form.lbl_current_layer.Text = gui.TextManager:Format_GetText()
    local current_play_info = "sys_ttf_game_" .. nx_string(current_layer_playid)
    form.mltbox_current_play_info:Clear()
    form.mltbox_current_play_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(current_play_info)), nx_int(-1))
    form.lbl_max_score.Text = nx_widestr(max_score)
    local progress = current_layer - math.floor(current_layer / max_progress) * max_progress
    if progress == 0 then
      progress = 10
    end
    gui.TextManager:Format_SetIDName("ui_ttf_8")
    gui.TextManager:Format_AddParam(nx_int(progress))
    gui.TextManager:Format_AddParam(nx_int(max_progress))
    form.lbl_progress.Text = gui.TextManager:Format_GetText()
    show_guanka_info(form, guanka_list)
  end
  gui.TextManager:Format_SetIDName("ui_ttf_8")
  gui.TextManager:Format_AddParam(nx_int(weapon_num))
  gui.TextManager:Format_AddParam(nx_int(max_weapon_num))
  form.lbl_weapon_num.Text = gui.TextManager:Format_GetText()
  form.lbl_score.Text = nx_widestr(total_score)
  create_guanka_box(form, each_weapon_num, max_guanka_num)
  gui.TextManager:Format_SetIDName("ui_ttf_5")
  gui.TextManager:Format_AddParam(nx_int(reset_num))
end
function show_guanka_info(form, guanka_list)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local play_info = ""
  local guanka_infolist = util_split_string(guanka_list, ",")
  local count = table.getn(guanka_infolist)
  form.mltbox_guanka_info:Clear()
  for i = 1, count do
    play_info = nx_string("sys_ttf_game_" .. nx_string(guanka_infolist[i]))
    form.mltbox_guanka_info:AddHtmlText(nx_widestr(gui.TextManager:GetText(play_info)), nx_int(-1))
  end
end
function create_guanka_box(form, shuang_jian_list, max_guanka_num)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local star_list, tmp_stars, stage_index, cur_star, last_star = {}, "", 1, 0, 0
  local tmp_list = util_split_string(shuang_jian_list, "|")
  local count = table.getn(tmp_list)
  if count ~= 0 then
    for _, stars in ipairs(tmp_list) do
      tmp_stars = nx_string(tmp_list[stage_index])
      if tmp_stars == "" then
        count = count - 1
        break
      end
      local stars = util_split_string(tmp_stars, ",")
      cur_star = nx_number(stars[1])
      last_star = nx_number(stars[2])
      if cur_star ~= 0 or last_star ~= 0 then
        star_list[stage_index] = get_star_pic_index(cur_star, last_star)
        stage_index = stage_index + 1
      end
    end
    for index = 1, count do
      local new_box = create_groupbox(form, index, "groupbox_guanka")
      local lbl_box = new_box:Find("lbl_info" .. nx_string(index))
      if nx_is_valid(lbl_box) then
        gui.TextManager:Format_SetIDName("ui_ttf_4")
        gui.TextManager:Format_AddParam(nx_int(index))
        lbl_box.Text = gui.TextManager:Format_GetText()
      end
      local lbl_icon_back = new_box:Find("lbl_icon" .. nx_string(index))
      if nx_is_valid(lbl_icon_back) then
        local cur_star_num = nx_string(star_list[index])
        if cur_star_num ~= "" then
          lbl_icon_back.BackImage = SHILIAN_PHOTO[cur_star_num]
        else
          return
        end
      end
      if nx_is_valid(new_box) then
        new_box.Left = (index - 1) % 5 * new_box.Width + 6
        new_box.Top = nx_int((index - 1) / 5) * (new_box.Height + 20) + 8
        form.groupscrollbox_1:Add(new_box)
        index = index + 1
      end
    end
  end
  for index = count + 1, nx_number(max_guanka_num) do
    local new_box = create_groupbox(form, index, "groupbox_guanka")
    local lbl_box = new_box:Find("lbl_info" .. nx_string(index))
    if nx_is_valid(lbl_box) then
      gui.TextManager:Format_SetIDName("ui_ttf_4")
      gui.TextManager:Format_AddParam(nx_int(index))
      lbl_box.Text = gui.TextManager:Format_GetText()
    end
    local lbl_icon_back = new_box:Find("lbl_icon" .. nx_string(index))
    lbl_icon_back.BackImage = SHILIAN_PHOTO["00"]
    if nx_is_valid(new_box) then
      new_box.Left = (index - 1) % 5 * new_box.Width + 6
      new_box.Top = nx_int((index - 1) / 5) * (new_box.Height + 20) + 8
      form.groupscrollbox_1:Add(new_box)
      index = index + 1
    end
  end
  form.groupscrollbox_1.IsEditMode = false
end
function create_groupbox(form, index, temp_name)
  local source_ent = nx_custom(form, temp_name)
  if not nx_is_valid(source_ent) then
    return nil
  end
  local gui = nx_value("gui")
  local groupbox = gui:Create("GroupBox")
  set_copy_ent_info(form, temp_name, groupbox)
  local child_ctrls = source_ent:GetChildControlList()
  for i, ctrl in ipairs(child_ctrls) do
    local ctrl_obj = gui:Create(nx_name(ctrl))
    if nx_is_valid(ctrl_obj) then
      set_copy_ent_info(form, ctrl.Name, ctrl_obj)
      ctrl_obj.Name = ctrl.Name .. nx_string(index)
      groupbox:Add(ctrl_obj)
    end
  end
  return groupbox
end
function set_copy_ent_info(form, source, target_ent)
  local source_ent = nx_custom(form, source)
  if not nx_is_valid(source_ent) then
    return
  end
  local prop_list = nx_property_list(source_ent)
  for i, prop in ipairs(prop_list) do
    if "Name" ~= prop then
      nx_set_property(target_ent, prop, nx_property(source_ent, prop))
    end
  end
end
function server_open_shilian_form(...)
  local form = util_get_form("form_stage_main\\form_skyhill\\form_ttf_template", true)
  if not nx_is_valid(form) then
    return
  end
  local weapon_num = nx_int(arg[1])
  local total_score = nx_int(arg[2])
  local current_layer = nx_int(arg[3])
  local current_layer_playid = nx_int(arg[4])
  local max_score = nx_int(arg[5])
  local each_weapon_num = nx_string(arg[6])
  local guanka_list = nx_string(arg[7])
  local reset_num = nx_int(arg[8])
  local isSuccess = nx_int(arg[9])
  local max_weapon_num = nx_int(arg[10])
  local max_guanka_num = nx_int(arg[11])
  refresh_shilian_info_form(form, weapon_num, total_score, current_layer, current_layer_playid, max_score, each_weapon_num, guanka_list, reset_num, isSuccess, max_weapon_num, max_guanka_num)
end
function server_reset_shilian_form(...)
  local form = util_get_form("form_stage_main\\form_skyhill\\form_ttf_template", true)
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  init_form(form)
  local btn_state_id = gui.TextManager:GetText("ui_ttf_1")
  form.btn_state.Text = btn_state_id
  local reset_num = nx_int(arg[1])
  form.reset_num_flag = reset_num
  local max_score = nx_int(arg[2])
  form.lbl_max_score.Text = nx_widestr(max_score)
  form.cur_lay_flag = 0
  gui.TextManager:Format_SetIDName("ui_ttf_5")
  gui.TextManager:Format_AddParam(nx_int(reset_num))
end
function close_shilian_form(...)
  local form = util_get_form("form_stage_main\\form_clone\\form_clone_main", true)
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_reset_click(btn)
  local form = btn.ParentForm
  if form.reset_num_flag == 0 then
    return
  end
  util_show_form("form_stage_main\\form_skyhill\\form_ttf_dialog", true)
  nx_execute("form_stage_main\\form_skyhill\\form_ttf_dialog", "show_cur_layer_info", form.cur_lay_flag, form.tips_num_flag)
end
function on_btn_state_click(btn)
  nx_execute("custom_sender", "custom_form_ttf_template", 8)
end
function on_lbl_score_icon_click(label)
  util_auto_show_hide_form("form_stage_main\\form_rank\\form_rank_main")
  local rang_form = nx_value("form_stage_main\\form_rank\\form_rank_main")
  if nx_is_valid(rang_form) then
    nx_execute("form_stage_main\\form_rank\\form_rank_main", "set_select_node_state", rang_form, "rank_skyhill_achievement01")
  end
end
function on_lbl_score_icon_get_capture(label)
  show_icon_tips(label, "total_tips")
end
function on_lbl_score_icon_lost_capture(label)
  nx_execute("tips_game", "hide_tip")
end
function on_lbl_weapon_icon_get_capture(label)
  show_icon_tips(label, "weapon_num")
end
function on_lbl_weapon_icon_lost_capture(label)
  nx_execute("tips_game", "hide_tip")
end
function show_icon_tips(label_icon, name_id)
  if not nx_is_valid(label_icon) then
    return
  end
  local form = label_icon.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local text = ""
  if name_id == "total_tips" then
    local total_tips = form.lbl_score.Text
    gui.TextManager:Format_SetIDName("ui_ttf_7")
    gui.TextManager:Format_AddParam(nx_int(total_tips))
    text = gui.TextManager:Format_GetText()
  elseif name_id == "weapon_num" then
    local weapon_num = form.lbl_weapon_num.Text
    gui.TextManager:Format_SetIDName("ui_ttf_6")
    gui.TextManager:Format_AddParam(nx_int(weapon_num))
    text = gui.TextManager:Format_GetText()
  else
    return
  end
  local x, y = gui:GetCursorPosition()
  local tips_manager = nx_value("tips_manager")
  if nx_is_valid(tips_manager) then
    tips_manager:ShowTextTips(nx_widestr(text), x, y, -1, "0-0")
  end
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_theme_helper", "util_open_theme", "jhqb,jianghusl02,tongtianfeng03_03,ttfgaishu04")
end
function get_star_pic_index(cur_star, last_star)
  local cur, last = cur_star, last_star
  if cur >= last then
    last = 0
  end
  local text = nx_string(cur) .. nx_string(last)
  return text
end
