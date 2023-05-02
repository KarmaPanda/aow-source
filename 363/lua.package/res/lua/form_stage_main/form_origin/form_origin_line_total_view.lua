require("form_stage_main\\form_origin\\form_origin_define")
function refresh_origin(main_type, sub_type_str)
  local form_line = nx_value(FORM_LINE_TOTAL_VIEW)
  form_line.main_type = main_type
  form_line.sub_type = sub_type_str
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form = nx_value(FORM_ORIGIN)
  if main_type == ORIGIN_TYPE_MENPAI then
    refresh_menpai_main_line_all(origin_manager, main_type, sub_type_str)
  end
end
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
function refresh_menpai_main_line_all(origin_manager, main_type, sub_type)
  local form = nx_value(FORM_LINE_TOTAL_VIEW)
end
function refresh_menpai_main_line(origin_manager, main_type, sub_type, line)
  local gui = nx_value("gui")
  local form = nx_value(FORM_LINE_TOTAL_VIEW)
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type), line)
  local lbl_name_pre = "lbl_" .. nx_string(line) .. "_"
  local lbl_line_pre = "lbl_p" .. nx_string(line) .. "_"
  local lbl_origin_pre = "lbl_n" .. nx_string(line) .. "_"
  local count = table.getn(origin_table)
  local level_end = -1
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
        refresh_menpai_main_line(origin_manager, main_type, sub_type, num)
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
      if nx_is_valid(lbl) then
        refresh_lbl(lbl, b_completed)
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
  if nx_is_valid(lbl) and not main_line_isfreezed[sub_type][line] then
    refresh_lbl(lbl, b_completed, level_end)
  end
end
function refresh_menpai_weijie(origin_manager, main_type, sub_type)
  local gui = nx_value("gui")
  local form = nx_value(FORM_LINE_TOTAL_VIEW)
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord("title_rec") then
    return
  end
  local title_count = player:GetRecordRows("title_rec")
  if title_count == 0 then
    form.btn_jj_1.Visible = false
    return
  end
  for i = 1, title_count do
    local title_id = player:QueryRecord("title_rec", i, 0)
    local line = origin_manager:GetOriginLine(title_id)
    if line == 0 then
      form.btn_jj_1.o_id = title_id
      form.btn_jj_1.Visible = true
      refresh_lbl_name(form.btn_jj_1, true, false, false, gui, title_id)
      return
    end
  end
  form.btn_jj_1.Visible = false
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
      refresh_lbl(lbl, false)
    end
    local lbl_line_name = lbl_line_pre .. nx_string(i)
    lbl = nx_custom(form, lbl_line_name)
    if nx_is_valid(lbl) then
      set_menpai_lbl_vis(lbl, false)
    end
    local lbl_origin_name = lbl_origin_pre .. nx_string(i)
    lbl = nx_custom(form, lbl_origin_name)
    if nx_is_valid(lbl) then
      refresh_lbl_name(lbl, false, false, false, gui, nil)
    end
  end
end
function refresh_lbl(lbl, b_completed, ...)
  local photo = "gui\\special\\origin\\dian_1.png"
  if b_completed then
    photo = "gui\\special\\origin\\dian_2.png"
  end
  if arg[1] ~= nil then
    photo = "gui\\special\\origin\\dian_3.png"
  end
  lbl.BackImage = photo
end
function refresh_lbl_name(lbl, b_completed, b_active, b_freeze, gui, o_id)
  local level = -1
  local origin_manager = nx_value("OriginManager")
  if o_id ~= nil then
    level = origin_manager:GetOriginLevel(o_id)
  end
  if b_freeze and 2 < level then
    if o_id ~= nil then
      set_Image(lbl, o_id, "freeze")
    end
  elseif b_completed then
    if o_id ~= nil then
      set_Image(lbl, o_id, "completed")
    end
  elseif b_active then
    if o_id ~= nil then
      set_Image(lbl, o_id, "active")
    end
  elseif o_id ~= nil then
    set_Image(lbl, o_id, "none")
  end
  if not b_freeze or level <= 2 then
    lbl.o_id = o_id
  end
  lbl.Text = nx_widestr("")
end
function set_Image(lbl, name, type)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local material = origin_manager:GetOriginMaterial(name)
  if nx_int(name) <= nx_int(38) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\shaolin_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\shaolin\\shaolin_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(138) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\wudang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\wudang\\wudang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(238) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\emei_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\emei\\emei_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(338) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\tangmen_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\tangmen\\tangmen_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(438) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\jinyiwei_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jinyi\\jinyiwei_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(538) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\gaibang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\gaibang\\gaibang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(638) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\junzitang_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\junzitang\\junzitang_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(738) then
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\" .. name .. ".png"
    elseif type == "freeze" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\jilegu_" .. material .. "-2.png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\menpai\\jilegu\\jilegu_" .. material .. "-1.png"
    end
  elseif nx_int(name) <= nx_int(844) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 9, -1)
    local line = origin_manager:GetOriginMaterial(name)
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\jianghu\\" .. sub_type .. "_" .. line .. "-" .. material .. ".png"
    end
  elseif nx_int(name) > nx_int(1200) then
    local type_origin = origin_manager:GetOriginAllType(name)
    local sub_type = string.sub(nx_string(type_origin[2]), 5, -1)
    if type == "completed" then
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\life\\" .. name .. ".png"
    else
      lbl.NormalImage = nx_resource_path() .. "gui\\language\\ChineseS\\origin\\origin\\life\\" .. sub_type .. "_" .. material .. ".png"
    end
  end
  lbl.AutoSize = true
end
function on_btn_click(btn)
  if nx_find_custom(btn, "o_id") then
    local form_origin_line = nx_value(FORM_LINE_TOTAL_VIEW)
    local form = nx_value(FORM_ORIGIN)
    local o_id = btn.o_id
    if o_id ~= nil then
      form.oid = o_id
      local origin_manager = nx_value("OriginManager")
      if not nx_is_valid(origin_manager) then
        return false
      end
      local line = origin_manager:GetOriginLine(o_id)
      nx_execute(FORM_ORIGIN, "show_sub_desc_form", form, true)
      nx_execute("form_stage_main\\form_origin\\form_origin_desc", "show_origin_info", form, o_id)
      if form_origin_line.main_type == ORIGIN_TYPE_MENPAI then
        nx_execute("form_stage_main\\form_origin\\form_origin_desc", "show_cloth", o_id, form_origin_line.main_type, form_origin_line.sub_type, line)
      end
    end
  end
end
function clear_origin_name(form, name_pre, count_max)
  local gui = nx_value("gui")
  local btn
  for i = 1, count_max do
    local btn_name = name_pre .. nx_string(i)
    btn = nx_custom(form, btn_name)
    if nx_is_valid(btn) then
      refresh_lbl_name(btn, false, false, false, gui, nil)
    end
  end
end
function refresh_origin_name(form, origin_manager, name_pre, line, MAX)
  local gui = nx_value("gui")
  local form_origin = nx_value(FORM_ORIGIN)
  local main_type = form_origin.main_type
  local sub_type_str = form_origin.sub_type_str
  local cur_level_max = 0
  local origin_table = origin_manager:GetTypeLineOriginList(main_type, nx_string(sub_type_str), line)
  local count = table.getn(origin_table)
  if MAX < count then
    count = MAX
  end
  for i = 1, count do
    local origin_id = origin_table[i]
    local level = origin_manager:GetOriginLevel(origin_id)
    local lbl
    if -1 < level and 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_completed = origin_manager:IsCompletedOrigin(origin_id)
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      local lbl_name = name_pre .. nx_string(level)
      if b_completed and cur_level_max < level then
        cur_level_max = level
      end
      lbl = nx_custom(form, lbl_name)
      if nx_is_valid(lbl) then
        refresh_lbl_name(lbl, b_completed, b_active, false, gui, origin_id)
      end
    end
  end
  return cur_level_max
end
