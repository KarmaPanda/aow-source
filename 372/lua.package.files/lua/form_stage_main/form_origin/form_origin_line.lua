require("util_functions")
require("form_stage_main\\form_origin\\form_origin_define")
local SCHOOL_POSE_INFO_PATH = "share\\War\\SchoolPose_Info.ini"
function main_form_init(form)
  form.Fixed = true
  form.Top = 0
  form.Left = 0
end
function on_main_form_open(form)
  form.Top = 20
  form.Left = 0
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_click(btn)
  if not nx_find_custom(btn, "o_id") then
    return
  end
  local form_origin_line = nx_value(FORM_ORIGIN_LINE)
  local form = nx_value(FORM_ORIGIN)
  local o_id = btn.o_id
  if o_id ~= nil and 0 < o_id then
    form.oid = o_id
    local origin_manager = nx_value("OriginManager")
    if not nx_is_valid(origin_manager) then
      return
    end
    if not nx_is_valid(form) or not nx_is_valid(form.actor2) then
      return
    end
    local actor2 = form.actor2
    nx_execute("role_composite", "link_weapon", actor2, "LWeapon", "", "")
    nx_execute("role_composite", "link_weapon", actor2, "RWeapon", "", "")
    nx_execute("role_composite", "link_weapon", actor2, "BackSheath", "", "")
    nx_execute("role_composite", "link_weapon", actor2, "BackSheathL", "", "")
    local line = origin_manager:GetOriginLine(o_id)
    form.lbl_menpai.BackImage = btn.BackImage
    nx_execute(FORM_ORIGIN, "show_sub_desc_form", form, true)
    nx_execute("form_stage_main\\form_origin\\form_origin_desc", "show_origin_info", form, o_id)
    local origin_manager = nx_value("OriginManager")
    if not nx_is_valid(origin_manager) then
      return
    end
    local body_type = origin_manager:GetBodyType(o_id)
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local body_manager = nx_value("body_manager")
    if not nx_is_valid(body_manager) then
      return
    end
    if form.main_type == ORIGIN_TYPE_MENPAI or form.main_type == ORIGIN_TYPE_GUILD or form.main_type == ORIGIN_TYPE_FORCE or form.main_type == ORIGIN_TYPE_NEW_SCHOOL or body_type == ORIGIN_EM_BODY_WOMAN_JUV or body_type == ORIGIN_EM_BODY_MAN_JUV or body_type == ORIGIN_EM_BODY_WOMAN_MAJ or body_type == ORIGIN_EM_BODY_WOMAN_MAJ or body_type == ORIGIN_EM_BODY_MAN_MAJ then
      nx_execute("form_stage_main\\form_origin\\form_origin_desc", "show_cloth", o_id, form.main_type, form.sub_type_str, line)
    end
  end
end
function refresh_menpai_main_line_all(origin_manager, main_type, sub_type)
  local form = nx_value(FORM_ORIGIN)
  local line_form = nx_value(FORM_ORIGIN_LINE)
  if not nx_is_valid(form) or not nx_is_valid(line_form) then
    return
  end
  clear_menpai(line_form, 1)
  clear_menpai(line_form, 2)
  clear_origin_name(form, "btn_s_", MAX_LEVEL_MENPAI_SAN)
  refresh_menpai_main_line(origin_manager, main_type, sub_type, 1)
  refresh_menpai_main_line(origin_manager, main_type, sub_type, 2)
  refresh_school_stage_line(origin_manager, main_type, sub_type)
  if nx_string(sub_type) == nx_string("school_shaolin") then
    refresh_school_sub_line(origin_manager)
  end
  local cur_level = refresh_origin_name(line_form, origin_manager, "btn_s_", 0, MAX_LEVEL_MENPAI_SAN)
  if not form.btn_first.Checked then
    form.btn_first.Checked = true
  end
end
function refresh_menpai_main_line(origin_manager, main_type, sub_type, line)
  local gui = nx_value("gui")
  local form = nx_value(FORM_ORIGIN_LINE)
  local sub_type_str = ""
  if nx_string(sub_type) == "school_tianshan" then
    local originform = nx_value(FORM_ORIGIN)
    if nx_int(originform.cur_sex) == nx_int(0) then
      sub_type_str = sub_type .. "_1"
    else
      sub_type_str = sub_type .. "_0_1"
    end
  end
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), line)
  if nx_string(sub_type_str) ~= "" then
    origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), line)
  end
  local lbl_name_pre = "lbl_1_"
  local lbl_line_pre = "lbl_p" .. nx_string(line) .. "_"
  local lbl_origin_pre = "lbl_n" .. nx_string(line) .. "_"
  local count = table.getn(origin_table)
  local level_end = -1
  local other_line = true
  for i = 1, count do
    local origin_id = origin_table[i]
    local level = origin_manager:GetOriginLevel(origin_id)
    local lbl
    if -1 < level and 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_completed = false
      local b_active = false
      if 2 < level then
        if main_line_isfreezed[sub_type][line] then
          b_completed = false
          b_active = false
        else
          b_completed = origin_manager:IsCompletedOrigin(origin_id)
          b_active = origin_manager:IsActiveOrigin(origin_id)
        end
      else
        b_completed = origin_manager:IsCompletedOrigin(origin_id)
        b_active = origin_manager:IsActiveOrigin(origin_id)
      end
      if level == 3 and b_completed then
        local num = 0
        if line == 1 then
          num = 2
        else
          num = 1
        end
        main_line_isfreezed[sub_type][num] = true
        form.lbl_1.BackImage = "gui\\special\\origin\\line_15.png"
        form.lbl_2.BackImage = "gui\\special\\origin\\line_13.png"
        form.lbl_3.BackImage = "gui\\special\\origin\\line_13.png"
        refresh_menpai_main_line(origin_manager, main_type, sub_type, num)
        exchange_line_position(form, num)
        other_line = false
      elseif level == 3 and not b_completed then
        local num = 0
        if line == 1 then
          num = 2
        else
          num = 1
        end
        main_line_isfreezed[sub_type][num] = false
      end
      if b_completed and level_end < level then
        level_end = level
      end
      local lbl_name = lbl_name_pre .. nx_string(level)
      lbl = nx_custom(form, lbl_name)
      if not nx_is_valid(lbl) or not main_line_isfreezed[sub_type][line] then
      end
      if level == 3 then
        for i = 2, 4 do
          local lbl_line_name = lbl_line_pre .. nx_string(i)
          lbl = nx_custom(form, lbl_line_name)
          if nx_is_valid(lbl) then
            set_school_lbl_vis(lbl, b_completed)
          end
        end
      elseif 3 < level then
        local lbl_line_name = lbl_line_pre .. nx_string(level + 1)
        lbl = nx_custom(form, lbl_line_name)
        if nx_is_valid(lbl) then
          set_school_lbl_vis(lbl, b_completed)
        end
      elseif level == 2 then
        local lbl_line_name = lbl_line_pre .. nx_string(level - 1)
        lbl = nx_custom(form, lbl_line_name)
        if nx_is_valid(lbl) then
          set_school_lbl_vis(lbl, b_completed)
        end
      end
      local lbl_origin_name = lbl_origin_pre .. nx_string(level)
      lbl = nx_custom(form, lbl_origin_name)
      if nx_is_valid(lbl) then
        refresh_lbl_name(lbl, b_completed, b_active, main_line_isfreezed[sub_type][line], gui, origin_id)
      end
    end
  end
  local lbl_name = lbl_name_pre .. nx_string(level_end)
  lbl = nx_custom(form, lbl_name)
  if not nx_is_valid(lbl) or not main_line_isfreezed[sub_type][line] then
  end
  if level_end < 2 and 0 < nx_number(count) then
    form.lbl_1.BackImage = "gui\\special\\origin\\line_11.png"
    form.lbl_2.BackImage = "gui\\special\\origin\\line_8.png"
    form.lbl_3.BackImage = "gui\\special\\origin\\line_8.png"
  end
  if other_line then
    local origin_other_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), 3 - line)
    if nx_string(sub_type_str) ~= "" then
      origin_other_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), 3 - line)
    end
    local other_count = table.getn(origin_other_table)
    if 0 >= nx_number(other_count) and sub_type ~= nil then
      main_line_isfreezed[sub_type][3 - line] = true
      form.lbl_1.BackImage = "gui\\special\\origin\\line_15.png"
      form.lbl_2.BackImage = "gui\\special\\origin\\line_13.png"
      form.lbl_3.BackImage = "gui\\special\\origin\\line_13.png"
      exchange_line_position(form, 3 - line)
    end
  end
end
function clear_menpai(form, line)
  local gui = nx_value("gui")
  local lbl_name_pre = "lbl_" .. nx_string(line) .. "_"
  local lbl_line_pre = "lbl_p" .. nx_string(line) .. "_"
  local lbl_origin_pre = "lbl_n" .. nx_string(line) .. "_"
  local lbl
  for i = 1, MAX_LEVEL_MENPAI do
    local lbl_name = lbl_name_pre .. nx_string(i)
    lbl = nx_custom(form, lbl_name)
    if nx_is_valid(lbl) then
    end
    local lbl_line_name = lbl_line_pre .. nx_string(i)
    lbl = nx_custom(form, lbl_line_name)
    if nx_is_valid(lbl) then
      set_school_lbl_vis(lbl, false)
    end
    local lbl_origin_name = lbl_origin_pre .. nx_string(i)
    lbl = nx_custom(form, lbl_origin_name)
    if nx_is_valid(lbl) then
      refresh_lbl_name(lbl, false, false, false, gui, nil)
      set_school_lbl_vis(lbl, false)
    end
  end
end
function set_school_lbl_vis(lbl, b_completed)
  local visible = false
  if b_completed then
    visible = true
  end
  lbl.Visible = visible
end
function exchange_line_position(form, select_line)
  form.groupbox_menpai.Top = form.groupbox_menpai.Top + 80
  local select_control_name = "lbl_n" .. nx_string(select_line) .. "_3"
  local other_control_name = "lbl_n" .. nx_string(3 - select_line) .. "_3"
  local select_control = form.groupbox_menpai:Find(select_control_name)
  local other_control = form.groupbox_menpai:Find(other_control_name)
  if select_control.Top < other_control.Top then
    exchange_position(form)
  end
end
function exchange_position(form)
  for i = 3, 15 do
    local up_control_name = "lbl_n1_" .. nx_string(i)
    local up_lbl_name = "lbl_n1_" .. nx_string(i) .. "_name"
    local down_control_name = "lbl_n2_" .. nx_string(i)
    local down_lbl_name = "lbl_n2_" .. nx_string(i) .. "_name"
    local up_control = form.groupbox_menpai:Find(up_control_name)
    local down_control = form.groupbox_menpai:Find(down_control_name)
    local up_lbl = form.groupbox_menpai:Find(up_lbl_name)
    local down_lbl = form.groupbox_menpai:Find(down_lbl_name)
    if nx_is_valid(up_control) and nx_is_valid(down_control) and nx_is_valid(up_lbl) and nx_is_valid(down_lbl) then
      local top = up_control.Top
      up_control.Top = down_control.Top
      down_control.Top = top
      local lbl_top = up_lbl.Top
      up_lbl.Top = down_lbl.Top
      down_lbl.Top = lbl_top
    end
  end
end
function refresh_school_stage_line(origin_manager, main_type, sub_type)
  local gui = nx_value("gui")
  local form = nx_value(FORM_ORIGIN)
  local sub_type_str = ""
  if nx_string(sub_type) == "school_tianshan" then
    sub_type_str = sub_type .. "_4"
  end
  local ini = get_ini(SCHOOL_POSE_INFO_PATH)
  if not nx_is_valid(ini) then
    return
  end
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), 0)
  if nx_string(sub_type_str) ~= "" then
    origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), 0)
  end
  local btn_name_pre = "btn_s_"
  local count = table.getn(origin_table)
  if count > MAX_LEVEL_MENPAI_SAN then
    count = MAX_LEVEL_MENPAI_SAN
  end
  for i = 1, count do
    local origin_id = origin_table[i]
    local level = origin_manager:GetOriginLevel(origin_id)
    local btn
    if -1 < level and 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_completed = origin_manager:IsCompletedOrigin(origin_id)
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      local btn_name = btn_name_pre .. nx_string(i)
      local lbl = nx_custom(form, "lbl_s_" .. nx_string(i))
      btn = nx_custom(form, btn_name)
      if nx_is_valid(btn) then
        refresh_lbl_name(btn, b_completed, b_active, false, gui, origin_id)
        local player_name, is_main_player = get_owner_name(ini, origin_id)
        if player_name ~= "" then
          local name = nx_string(btn.Name) .. "_name"
          local status_control = nx_custom(form, name)
          if nx_is_valid(status_control) then
            status_control.Text = nx_widestr(player_name)
            status_control.ForeColor = "255,255,128,0"
          end
          local name = nx_string(btn.Name) .. "_bg"
          local bg_control = nx_custom(form, name)
          if not nx_is_valid(bg_control) then
            return
          end
          if is_main_player then
            bg_control.Visible = true
          else
            bg_control.Visible = false
          end
        end
      end
    end
  end
end
function refresh_school_sub_line(origin_manager)
  local gui = nx_value("gui")
  local form = nx_value(FORM_ORIGIN_SCHOOL_SUB_LINE)
  if not nx_is_valid(origin_manager) then
    return
  end
  local btn_name_pre = "lbl_n1_"
  local origin_id = 41
  local level = origin_manager:GetOriginLevel(41)
  local btn
  local b_completed = origin_manager:IsCompletedOrigin(origin_id)
  local b_active = origin_manager:IsActiveOrigin(origin_id)
  local btn_name = btn_name_pre .. nx_string(1)
  local lbl = nx_custom(form, "lbl_1_1")
  btn = nx_custom(form, btn_name)
  if nx_is_valid(btn) then
    refresh_lbl_name(btn, b_completed, b_active, false, gui, origin_id)
  end
end
function get_owner_name(ini, origin_id)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return "", false
  end
  if not client_player:FindRecord("SchoolPoseRec") then
    return "", false
  end
  local pose_count = client_player:GetRecordRows("SchoolPoseRec")
  if pose_count == 0 then
    return "", false
  end
  local player_name = nx_widestr("")
  for i = 0, pose_count - 1 do
    local school_pose_id = client_player:QueryRecord("SchoolPoseRec", i, 0)
    local sec_index = ini:FindSectionIndex(nx_string(school_pose_id))
    local target_origin_id = ini:ReadInteger(sec_index, "GetOrigin", 0)
    if origin_id == target_origin_id then
      player_name = client_player:QueryRecord("SchoolPoseRec", i, 1)
      break
    end
  end
  if player_name == nx_widestr("") then
    return "", false
  end
  local gui = nx_value("gui")
  if gui.TextManager:IsIDName(nx_string(player_name)) then
    return "", false
  end
  return player_name, player_name == client_player:QueryProp("Name")
end
function refresh_jianghu_main()
  local form_origin = nx_value(FORM_ORIGIN)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  clear_origin_name(form_origin, "btn_jh_", MAX_LEVEL_JIANGHU)
  local cur_level = refresh_origin_name(form_origin, origin_manager, "btn_jh_", 1, MAX_LEVEL_JIANGHU)
end
function refresh_jianghu_chengjiu(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  local count = 1
  for i = 1, 2 do
    local btn_pre = "btn_" .. nx_string(count) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(count)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      count = count + 1
      clear_origin_name(form_chengjiu, btn_pre, MAX_LEVEL_JIANGHU_CHENGJIU)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_pre, i, MAX_LEVEL_JIANGHU_CHENGJIU)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_jianghu_wuxue(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_WUXUE)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_WUXUE)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_jianghu_anneal(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_ANNEAL)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_ANNEAL)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_jianghu_marry(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_MARRY)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_MARRY)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_jianghu_lover(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_LOVER)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_LOVER)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = (origin_count - 1) * 104
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_jianghu_vip(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_VIP)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_VIP)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_life(line)
  local form_origin = nx_value(FORM_ORIGIN)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_life = nx_custom(form_origin, "form_life")
  if form_life.Visible then
    clear_origin_name(form_life, "btn_", MAX_LEVEL_LIFE)
    form_life.life_line = line
    local cur_level = refresh_origin_name(form_life, origin_manager, "btn_", line, MAX_LEVEL_LIFE)
  end
end
function refresh_guild()
  local form_origin = nx_value(FORM_ORIGIN)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_guild = form_origin.form_guild
  local keyName = form_guild.select_key_name
  local line = form_guild.select_line
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  local isGuildLeader = nx_int(player:QueryProp("IsGuildCaptain"))
  if nx_int(isGuildLeader) ~= nx_int(2) then
    line = line + 1000
  end
  if form_guild.Visible then
    local preName = "btn_" .. keyName .. "_"
    clear_origin_name(form_guild, preName, MAX_GUILD_ORIGIN_COUNT)
    local cur_level = refresh_origin_name(form_guild, origin_manager, preName, line, MAX_GUILD_ORIGIN_COUNT)
  end
end
function refresh_force(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local form_force = nx_custom(form_origin, "form_force")
  if not nx_is_valid(form_force) then
    return
  end
  form_force.groupbox_1.Visible = false
  form_force.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_force, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_force, btn_origin, MAX_LEVEL_FORCE)
      local origin_count = refresh_origin_name(form_force, origin_manager, btn_origin, i, MAX_LEVEL_FORCE)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = (origin_count - 1) * 104
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_force.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
end
function refresh_origin(main_type, sub_type_str)
  local form_line = nx_value(FORM_ORIGIN_LINE)
  form_line.main_type = main_type
  form_line.sub_type = sub_type_str
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form = nx_value(FORM_ORIGIN)
  if main_type == ORIGIN_TYPE_MENPAI then
    if form.cbtn_index > 0 then
      local btn_name = btn_menpai_name[form.cbtn_index]
      local btn = nx_custom(form, btn_name)
      if nx_is_valid(btn) and btn.Visible then
        btn.Checked = true
        form.cbtn_index = 0
      end
    end
    form_line.groupbox_menpai.Top = 0
    refresh_menpai_main_line_all(origin_manager, main_type, sub_type_str)
  elseif main_type == ORIGIN_TYPE_JIANGHU then
    local form_chengjiu = nx_custom(form, "form_chengjiu")
    if sub_type_str == "jianghu_experience" then
      refresh_jianghu_main()
    elseif sub_type_str == "jianghu_jianghu" or sub_type_str == "jianghu_shashou" or sub_type_str == "jianghu_sidi" or sub_type_str == "jianghu_zhiji" or sub_type_str == "jianghu_card" then
      if form.cbtn_index > 0 then
        local btn_name = "rbtn_" .. nx_string(form.cbtn_index)
        local btn = nx_custom(form_chengjiu, btn_name)
        if nx_is_valid(btn) and btn.Visible then
          btn.Checked = true
          refresh_jianghu_chengjiu(jianghu_chengjiu_table[form.cbtn_index])
          form.cbtn_index = 0
        end
      else
        local has_checked = false
        for i = 1, 6 do
          local btn_name = "rbtn_" .. nx_string(i)
          local btn = nx_custom(form_chengjiu, btn_name)
          if nx_is_valid(btn) and btn.Visible and btn.Checked then
            refresh_jianghu_chengjiu(jianghu_chengjiu_table[i])
            has_checked = true
          end
        end
        if not has_checked then
          refresh_jianghu_chengjiu("jianghu_shashou")
        end
      end
    elseif sub_type_str == "jianghu_lianhuan" or sub_type_str == "jianghu_kuihua" or sub_type_str == "jianghu_xixing" or sub_type_str == "jianghu_wuxue" or sub_type_str == "jianghu_zhaoshi" then
      if form.cbtn_index > 0 then
        local btn_name = "rbtn_" .. nx_string(form.cbtn_index)
        local btn = nx_custom(form_chengjiu, btn_name)
        if nx_is_valid(btn) and btn.Visible then
          btn.Checked = true
          refresh_jianghu_wuxue(wuxue_table[form.cbtn_index])
          form.cbtn_index = 0
        end
      else
        local has_checked = false
        for i = 1, 6 do
          local btn_name = "rbtn_" .. nx_string(i)
          local btn = nx_custom(form_chengjiu, btn_name)
          if nx_is_valid(btn) and btn.Visible and btn.Checked then
            refresh_jianghu_wuxue(wuxue_table[i])
            has_checked = true
          end
        end
        if not has_checked then
          refresh_jianghu_wuxue("jianghu_lianhuan")
        end
      end
    elseif sub_type_str == "jianghu_marry" then
      if form.cbtn_index > 0 then
        local btn_name = "rbtn_" .. nx_string(form.cbtn_index)
        local btn = nx_custom(form_chengjiu, btn_name)
        if nx_is_valid(btn) and btn.Visible then
          btn.Checked = true
          local temp_table = marry_man_table
          if form.cur_sex == 1 then
            temp_table = marry_woman_table
          end
          refresh_jianghu_marry(temp_table[form.cbtn_index])
          form.cbtn_index = 0
        end
      elseif form.cur_sex == 0 then
        refresh_jianghu_marry("marry_man_1")
      else
        refresh_jianghu_marry("marry_woman_1")
      end
    elseif sub_type_str == "marry_man_1" or sub_type_str == "marry_man_2" or sub_type_str == "marry_man_3" or sub_type_str == "marry_man_4" or sub_type_str == "marry_woman_1" or sub_type_str == "marry_woman_2" or sub_type_str == "marry_woman_3" or sub_type_str == "marry_woman_4" then
      refresh_jianghu_marry(sub_type_str)
    elseif sub_type_str == "jianghu_lover" then
      if form.cbtn_index > 0 then
        local btn_name = "rbtn_" .. nx_string(form.cbtn_index)
        local btn = nx_custom(form_chengjiu, btn_name)
        if nx_is_valid(btn) and btn.Visible then
          btn.Checked = true
          local temp_table = lover_man_table
          if form.cur_sex == 1 then
            temp_table = lover_woman_table
          end
          refresh_jianghu_lover(temp_table[form.cbtn_index])
          form.cbtn_index = 0
        end
      elseif form.cur_sex == 0 then
        refresh_jianghu_marry("lover_man_1")
      else
        refresh_jianghu_marry("lover_woman_1")
      end
    elseif sub_type_str == "lover_man_1" or sub_type_str == "lover_man_2" or sub_type_str == "lover_man_3" or sub_type_str == "lover_woman_1" or sub_type_str == "lover_woman_2" or sub_type_str == "lover_woman_3" then
      refresh_jianghu_lover(sub_type_str)
    elseif sub_type_str == "jianghu_anneal" then
      refresh_jianghu_anneal("jianghu_diwei")
    elseif sub_type_str == "ui_viptime" then
      refresh_jianghu_vip("jianghu_vip_1")
    elseif sub_type_str == "jianghu_vip_1" or sub_type_str == "jianghu_vip_2" or sub_type_str == "jianghu_vip_3" then
      refresh_jianghu_vip(sub_type_str)
    elseif sub_type_str == "jianghu_body" then
      if form.cur_sex == 0 then
        refresh_jianghu_body("jianghu_body_1")
      else
        refresh_jianghu_body("jianghu_body_0_1")
      end
    elseif sub_type_str == "jianghu_body_1" or sub_type_str == "jianghu_body_2" or sub_type_str == "jianghu_body_3" or sub_type_str == "jianghu_body_4" or sub_type_str == "jianghu_body_0_1" or sub_type_str == "jianghu_body_0_2" or sub_type_str == "jianghu_body_0_3" or sub_type_str == "jianghu_body_0_4" then
      refresh_jianghu_body(sub_type_str)
    end
  elseif main_type == ORIGIN_TYPE_LIFE then
    form.cbtn_index = origin_manager:GetOriginLine(form.oid)
    local form_life = nx_custom(form, "form_life")
    if form.cbtn_index > 0 then
      for i = 1, 6 do
        local btn_name = "btn_line_" .. nx_string(i)
        local btn = nx_custom(form_life, btn_name)
        if nx_is_valid(btn) and btn.Visible and btn.line == form.cbtn_index then
          btn.Checked = true
          refresh_life(btn.line)
          form.cbtn_index = 0
        end
      end
    else
      local has_checked = false
      for i = 1, 6 do
        local btn_name = "btn_line_" .. nx_string(i)
        local btn = nx_custom(form_life, btn_name)
        if nx_is_valid(btn) and btn.Visible and btn.Checked then
          refresh_life(btn.line)
          has_checked = true
        end
      end
      if not has_checked then
        local btn_name = "btn_line_1"
        local btn = nx_custom(form_life, btn_name)
        if nx_is_valid(btn) then
          refresh_life(btn.line)
        end
      end
    end
  elseif main_type == ORIGIN_TYPE_GUILD then
    refresh_guild()
  elseif main_type == ORIGIN_TYPE_FORCE then
    if sub_type_str == "school_wulin" then
      refresh_force("school_wulin_1")
    elseif sub_type_str == "force_yihua" then
      if nx_int(form.cur_sex) == nx_int(0) then
        refresh_force("force_yihua_0")
      else
        refresh_force("force_yihua_1")
      end
    elseif sub_type_str == "force_taohua" then
      refresh_force("force_taohua_1")
    elseif sub_type_str == "force_xujia" then
      refresh_force("force_xujia_1")
    elseif sub_type_str == "force_wugen" then
      refresh_force("force_wugen_1")
    elseif sub_type_str == "force_wanshou" then
      refresh_force("force_wanshou_1")
    elseif sub_type_str == "force_jinzhen" then
      refresh_force("force_jinzhen_1")
    else
      refresh_force(sub_type_str)
    end
  elseif main_type == ORIGIN_TYPE_NEW_SCHOOL then
    local form_origin = nx_value(FORM_ORIGIN)
    form_origin.sub_type_str = nx_string(sub_type_str)
    local form_line_new = nx_custom(form, "form_line_new")
    local sub_line_level = "1"
    if form.cbtn_index > 0 then
      local btn_name = btn_new_menpai_name[form.cbtn_index]
      if not nx_is_valid(form_origin_line_new) then
        local btn = nx_custom(form_line_new, btn_name)
        if nx_is_valid(btn) and btn.Visible then
          btn.Checked = true
          sub_line_level = nx_string(form.cbtn_index)
        end
      end
    end
    if sub_type_str == "school_xuedaomen" or sub_type_str == "school_changfeng" or sub_type_str == "school_shenshui" or sub_type_str == "school_huashan" or sub_type_str == "school_damo" or sub_type_str == "school_shenjiying" or sub_type_str == "school_xingmiao" then
      if nx_int(sub_line_level) == nx_int(4) then
        nx_execute(FORM_ORIGIN_LINE, "refresh_new_school_stage_line", 6, nx_string(sub_type_str .. "_4"))
      else
        refresh_new_shcool(sub_type_str .. "_" .. sub_line_level)
      end
    elseif sub_type_str == "school_gumu" or sub_type_str == "school_nianluoba" or sub_type_str == "school_wuxianjiao" then
      if nx_int(sub_line_level) == nx_int(4) then
        nx_execute(FORM_ORIGIN_LINE, "refresh_new_school_stage_line", 6, nx_string(sub_type_str .. "_4"))
      elseif nx_int(form.cur_sex) == nx_int(0) then
        refresh_new_shcool(sub_type_str .. "_" .. sub_line_level)
      else
        refresh_new_shcool(sub_type_str .. "_0_" .. sub_line_level)
      end
    elseif sub_type_str == "school_gumu_4" or sub_type_str == "school_xuedaomen_4" or sub_type_str == "school_nianluoba_4" or sub_type_str == "school_changfeng_4" or sub_type_str == "school_shenshui_4" or sub_type_str == "school_huashan_4" or sub_type_str == "school_wuxianjiao_4" or sub_type_str == "school_damo_4" or sub_type_str == "school_shenjiying_4" or sub_type_str == "school_xingmiao_4" then
      nx_execute(FORM_ORIGIN_LINE, "refresh_new_school_stage_line", 6, nx_string(sub_type_str))
    else
      refresh_new_shcool(sub_type_str)
    end
  end
end
function refresh_origin_name(form, origin_manager, name_pre, line, MAX)
  local gui = nx_value("gui")
  local form_origin = nx_value(FORM_ORIGIN)
  local main_type = form_origin.main_type
  local sub_type_str = form_origin.sub_type_str
  local sub_type = ""
  if nx_string(sub_type_str) == "school_tianshan" then
    if nx_int(form_origin.cur_sex) == nx_int(0) then
      sub_type = sub_type_str .. "_1"
    else
      sub_type = sub_type_str .. "_0_1"
    end
  end
  local cur_level_max = 0
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), line)
  if nx_string(sub_type) ~= "" then
    origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), line)
  end
  local count = table.getn(origin_table)
  if count == 0 then
    return -1
  elseif MAX < count then
    count = MAX
  end
  for i = 1, count do
    local origin_id = origin_table[i]
    local level = origin_manager:GetOriginLevel(origin_id)
    local lbl
    if -1 < level and 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_completed = origin_manager:IsCompletedOrigin(origin_id)
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      local btn_name = name_pre .. nx_string(i)
      if b_completed and cur_level_max < level then
        cur_level_max = level
      end
      btn = nx_custom(form, btn_name)
      if nx_is_valid(btn) then
        refresh_lbl_name(btn, b_completed, b_active, false, gui, origin_id)
      end
    end
  end
  return count
end
function clear_origin_name(form, name_pre, count_max)
  local gui = nx_value("gui")
  local btn
  for i = 1, count_max do
    local btn_name = name_pre .. nx_string(i)
    btn = nx_custom(form, btn_name)
    if nx_is_valid(btn) then
      btn.Visible = false
      refresh_lbl_name(btn, false, false, false, gui, nil)
    end
  end
end
function refresh_lbl_name(btn, b_completed, b_active, b_freeze, gui, o_id)
  local name = nx_string(btn.Name) .. "_name"
  local parent = btn.ParentForm
  local status_control = nx_custom(parent, name)
  if not nx_is_valid(status_control) then
    return
  end
  local bg_name = nx_string(btn.Name) .. "_bg"
  local bg_control = nx_custom(parent, bg_name)
  if nx_is_valid(bg_control) then
    bg_control.Visible = false
  end
  del_flash(btn)
  local level = -1
  local origin_manager = nx_value("OriginManager")
  if o_id ~= nil then
    level = origin_manager:GetOriginLevel(o_id)
  end
  btn.Visible = true
  status_control.Visible = true
  if b_freeze and 2 < level then
    if o_id ~= nil then
      status_control.Visible = false
    end
  elseif b_completed then
    if o_id ~= nil then
      if not origin_manager:IsOriginGetPrize(o_id) then
        set_Image(btn, o_id, "completed", true)
      else
        set_Image(btn, o_id, "completed")
      end
      status_control.Text = nx_widestr(gui.TextManager:GetText("ui_origin_yhd"))
      status_control.ForeColor = "255,255,128,0"
    end
  elseif b_active then
    if o_id ~= nil then
      if can_get_origin(o_id) then
        set_Image(btn, o_id, "active", true)
        status_control.Text = nx_widestr(gui.TextManager:GetText("ui_origin_khd"))
        status_control.ForeColor = "255,0,219,0"
      else
        local is_new = nx_execute("form_stage_main\\form_main\\form_main_shortcut", "is_new_active_origin", o_id)
        if is_new then
          set_Image(btn, o_id, "active", true)
        else
          set_Image(btn, o_id, "active")
        end
        status_control.Text = nx_widestr(gui.TextManager:GetText("ui_origin_ktz"))
        status_control.ForeColor = "255,255,0,0"
      end
    end
  elseif o_id ~= nil then
    set_Image(btn, o_id, "none")
    status_control.Text = nx_widestr(gui.TextManager:GetText("ui_origin_wjh"))
    status_control.ForeColor = "255,95,67,37"
  end
  if not b_freeze or level <= 2 then
    btn.o_id = o_id
  end
  if not b_active and not b_completed then
    btn.o_id = -1
  end
  btn.Text = nx_widestr("")
  btn.Visible = status_control.Visible
end
function set_Image(lbl, name, type, flash)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local material = origin_manager:GetOriginMaterial(name)
  if nx_int(name) <= nx_int(100) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\shaolin_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\shaolin_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(138) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\wudang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\wudang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(238) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\emei_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\emei_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(338) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\tangmen_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\tangmen_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(438) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\jinyiwei_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\jinyiwei_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(538) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\gaibang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\gaibang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(638) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\junzitang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\junzitang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(738) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\jilegu_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\jilegu_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(1130) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 9, -1)
    local line = origin_manager:GetOriginLine(name)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. sub_type .. "_" .. line .. "-" .. material .. ".png"
    end
  elseif nx_int(name) >= nx_int(1151) and nx_int(name) <= nx_int(1199) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 1, 5)
    local line = origin_manager:GetOriginLine(name)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. sub_type .. "_" .. line .. "-" .. material .. ".png"
    end
  elseif nx_int(name) >= nx_int(1131) and nx_int(name) <= nx_int(1150) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 1, 5)
    local line = origin_manager:GetOriginLine(name)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. sub_type .. "_" .. line .. "-" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(1200) and nx_int(name) <= nx_int(1400) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 5, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\life\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\life\\" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(1400) and nx_int(name) <= nx_int(1450) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wmp\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wmp\\wulin" .. "_" .. material .. ".png"
    end
  elseif nx_int(name) <= nx_int(1500) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\mingjiao\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\mingjiao\\mingjiao_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\mingjiao\\mingjiao_" .. material .. "-1.png"
    end
  elseif nx_int(name) > nx_int(2100) and nx_int(name) <= nx_int(2150) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 5, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\banghui\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\banghui\\" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(2300) and nx_int(name) <= nx_int(2400) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 7, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\force\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\force\\" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(2500) and nx_int(name) < nx_int(2900) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 7, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\force\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\force\\" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) >= nx_int(2900) and nx_int(name) <= nx_int(3000) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 14, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\body\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\body\\" .. "body" .. "_" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(3000) and nx_int(name) <= nx_int(3950) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 8, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\newschool\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\newschool\\" .. sub_type .. "_" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(10000) and nx_int(name) <= nx_int(10100) then
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tianshan\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tianshan\\tianshan_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tianshan\\tianshan_" .. material .. "-1.png"
    end
  elseif nx_int(name) > nx_int(10100) and nx_int(name) <= nx_int(10200) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 8, -1)
    if type == "completed" or type == "active" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\newschool\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\newschool\\" .. sub_type .. "_" .. material .. ".png"
    end
  end
  lbl.AutoSize = true
  if flash then
    add_flash(lbl)
  end
end
function add_flash(btn)
  local gui = nx_value("gui")
  local group = btn.Parent
  local control = gui:Create("Label")
  local ctrl_name = nx_string(btn.Name) .. "_back"
  control.Name = ctrl_name
  control.Top = btn.Top - 25
  control.Left = btn.Left - 26
  control.Height = btn.Height + 50
  control.Width = btn.Width + 50
  control.BackImage = "yuan"
  group:Add(control)
  group:ToBack(control)
end
function del_flash(btn)
  local gui = nx_value("gui")
  local group = btn.Parent
  local ctrl_name = nx_string(btn.Name) .. "_back"
  local control = group:Find(ctrl_name)
  if nx_is_valid(control) then
    group:Remove(control)
    gui:Delete(control)
  end
end
function can_get_origin(o_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  return nx_execute("form_stage_main\\form_origin\\form_origin_desc", "can_get_origin", player, condition_manager, origin_manager, o_id)
end
function refresh_lbl(lbl, b_completed, ...)
  local photo = "gui\\special\\origin\\dian_1.png"
  if b_completed then
    photo = "gui\\special\\origin\\dian_2.png"
    if arg[1] ~= nil then
      photo = "gui\\special\\origin\\dian_3.png"
    end
  end
  lbl.BackImage = photo
  lbl.Visible = false
end
function clear_origin_point(form, name_pre, count_max)
  local gui = nx_value("gui")
  local btn
  for i = 1, count_max do
    local btn_name = name_pre .. nx_string(i)
    btn = nx_custom(form, btn_name)
    if nx_is_valid(btn) then
      refresh_lbl(btn, false)
    end
  end
end
function refresh_line(form, level)
  for i = 1, level do
    local lbl_p_name = "lbl_p" .. nx_string(i)
    local lbl_p = nx_custom(form, lbl_p_name)
    if nx_is_valid(lbl_p) then
      if i == level then
        refresh_lbl(lbl_p, true, level)
      else
        refresh_lbl(lbl_p, true)
      end
    end
  end
end
function refresh_new_shcool(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local form_line_new = nx_custom(form_origin, "form_line_new")
  if not nx_is_valid(form_line_new) then
    return
  end
  form_line_new.groupbox_1.Visible = false
  form_line_new.groupbox_2.Visible = false
  form_line_new.groupscrollbox_100.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_line_new, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_line_new, btn_origin, MAX_LEVEL_NEW_SHCOOL)
      local origin_count = refresh_origin_name(form_line_new, origin_manager, btn_origin, i, MAX_LEVEL_NEW_SHCOOL)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = (origin_count - 1) * 104
          end
        end
        groupbox.Width = origin_count * 100
        groupbox.Left = (form_line_new.Width - groupbox.Width) / 2
        groupbox.Visible = true
      end
    end
  end
  form_line_new.groupscrollbox_100.Visible = false
end
function refresh_new_school_stage_line(main_type, sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local sub_type_str = ""
  if nx_string(sub_type) == "school_tianshan" then
    if nx_int(form_origin.cur_sex) == nx_int(0) then
      sub_type_str = sub_type .. "_1"
    else
      sub_type_str = sub_type .. "_0_1"
    end
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local gui = nx_value("gui")
  local form = nx_value(FORM_ORIGIN_LINE_NEW)
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), 0)
  local btn_name_pre = "btn_s_"
  local count = table.getn(origin_table)
  if count > MAX_LEVEL_MENPAI_SAN then
    count = MAX_LEVEL_MENPAI_SAN
  end
  for i = 1, count do
    local origin_id = origin_table[i]
    local level = origin_manager:GetOriginLevel(origin_id)
    local btn
    if -1 < level and 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_completed = origin_manager:IsCompletedOrigin(origin_id)
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      local btn_name = btn_name_pre .. nx_string(i)
      local lbl = nx_custom(form, "lbl_s_" .. nx_string(i))
      btn = nx_custom(form, btn_name)
      if nx_is_valid(btn) then
        refresh_lbl_name(btn, b_completed, b_active, false, gui, origin_id)
      end
    end
  end
end
function refresh_jianghu_body(sub_type)
  local form_origin = nx_value(FORM_ORIGIN)
  form_origin.sub_type_str = nx_string(sub_type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form_chengjiu = nx_custom(form_origin, "form_chengjiu")
  form_chengjiu.groupbox_1.Visible = false
  form_chengjiu.groupbox_2.Visible = false
  for i = 1, 2 do
    local btn_origin = "btn_" .. nx_string(i) .. "_"
    local groupbox_name = "groupbox_" .. nx_string(i)
    local groupbox = nx_custom(form_chengjiu, groupbox_name)
    if nx_is_valid(groupbox) then
      clear_origin_name(form_chengjiu, btn_origin, MAX_LEVEL_JIANGHU_BODY)
      local origin_count = refresh_origin_name(form_chengjiu, origin_manager, btn_origin, i, MAX_LEVEL_JIANGHU_BODY)
      if 0 < origin_count then
        for j = 1, 2 do
          local lbl = groupbox:Find("lbl_" .. j)
          if nx_is_valid(lbl) then
            lbl.Width = origin_count * 80
          end
        end
        groupbox.Width = origin_count * 105
        groupbox.Left = (form_chengjiu.Width - groupbox.Width) / 2 + 10
        groupbox.Visible = true
      end
    end
  end
end
