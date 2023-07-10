require("util_gui")
local DramaRec = "DramaRec"
local page_content_table = {}
local page_content_table_funcid = {}
local font_book_name = "FZHKJT30"
local font_chapter_name = "font_text_title1"
local color_chapter_name = "966144"
local font_round_name = "font_text_title2"
local color_round_name = "766144"
local font_content_name = "font_text"
local color_content_name = "956737"
local CHAPTER_COUNT_PER_PAGE = 2
function init_main_form(self)
  self.Fixed = false
  self.no_need_motion_alpha = true
  self.text_id = ""
  self.drama_name = ""
  self.chapter_id = 0
  self.round_id = 0
  self.cur_page_id = 1
  self.cur_page_type = 0
  self.player_ident = ""
  self.page_text = ""
  self.content_page_index = 1
  self.content_index = 2
  self.b_click_perv = false
end
function set_content_date(num)
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  local count_num = 0
  for count_1 = 1, table.getn(page_content_table) do
    for count_2 = 1, table.getn(page_content_table[count_1]) do
      count_num = count_num + 1
      if tonumber(count_num) == tonumber(num) then
        form_drama.content_page_index = count_1
        form_drama.content_index = count_2
      end
    end
  end
end
function set_cur_page_type(page_type)
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  if page_type == 0 then
    form_drama.cur_page_type = 0
    form_drama.gb_content.Visible = true
    form_drama.gb_text.Visible = false
    form_drama.mtb_text:Clear()
  elseif page_type == 1 then
    form_drama.cur_page_type = 1
    form_drama.gb_content.Visible = false
    form_drama.gb_text.Visible = true
  end
end
function init_form_data()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  form_drama.text_id = ""
  form_drama.drama_name = ""
  form_drama.chapter_id = 0
  form_drama.round_id = 0
  set_cur_page_type(0)
  form_drama.cur_page_id = 1
  update_pageno(form_drama)
  form_drama.player_ident = ""
  form_drama.page_text = ""
  set_content_date(2)
  form_drama.b_click_perv = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  init_drama(form)
end
function init_drama(form)
  refresh_drama_content()
  update_pageno(form)
  nx_execute("freshman_help", "form_on_open_callback", "form_stage_main\\form_drama")
end
function refresh_drama_content()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  init_form_data()
  local game_client = nx_value("game_client")
  local player_client = game_client:GetPlayer()
  form_drama.player_ident = player_client.Ident
  set_page_content_table()
  set_content_date(2)
  show_cur_page_content()
  refresh_control()
end
function refresh_control()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.cur_page_type == 0 then
    form_drama.gb_content.Visible = true
  elseif form_drama.cur_page_type == 1 then
    form_drama.gb_text.Visible = true
  end
end
function on_main_form_close(form)
  nx_execute("freshman_help", "form_on_close_callback", "form_stage_main\\form_drama")
  clear_page_content_table()
  clear_page_text_table()
  DramaRec = "DramaRec"
  if nx_is_valid(form) then
    nx_destroy(form)
  end
end
function on_btn_pervpage_click(btn)
  local form_drama = btn.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.cur_page_type == 0 then
    pervpage_content(form_drama)
  elseif form_drama.cur_page_type == 1 then
    pervpage_text(form_drama)
  end
end
function on_btn_nextpage_click(btn)
  local form_drama = btn.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.cur_page_type == 0 then
    nextpage_content(form_drama)
  elseif form_drama.cur_page_type == 1 then
    nextpage_text(form_drama)
  end
end
function on_btn_return_click(btn)
  local form_drama = btn.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  set_cur_page_type(0)
  form_drama.cur_page_id = 1
  update_pageno(form_drama)
  set_content_date(2)
  form_drama.b_click_perv = false
  show_cur_page_content()
end
function on_btn_close_click(btn)
  local form_drama = btn.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  form_drama:Close()
end
function on_mtb_text_mousemove(mtb_text, pos)
  local form_drama = mtb_text.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  if nx_int(mtb_text.ItemCount) == nx_int(0) then
    return
  end
  if form_drama.cur_page_type ~= 0 then
    return
  end
  local gui = nx_value("gui")
  local text = mtb_text:GetHtmlItemText(nx_int(0))
  text = "<font color=\"#ff0000\">" .. nx_string(text) .. "</font>"
  mtb_text:ChangeHtmlText(nx_int(0), nx_widestr(text))
end
function on_mtb_lost_capture(mtb_text)
  local form_drama = mtb_text.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  if nx_int(mtb_text.ItemCount) == nx_int(0) then
    return
  end
  if form_drama.cur_page_type ~= 0 then
    return
  end
  local gui = nx_value("gui")
  local text = mtb_text:GetHtmlItemText(nx_int(0))
  text = "<font color=\"#" .. nx_string(color_round_name) .. "\">" .. nx_string(text) .. "</font>"
  mtb_text:ChangeHtmlText(nx_int(0), nx_widestr(text))
end
function on_mtb_text_select(mtb_text, index)
  local form_drama = mtb_text.ParentForm
  if not nx_is_valid(form_drama) then
    return
  end
  if nx_int(mtb_text:GetItemKeyByIndex(index)) == nx_int(-1) then
    return
  end
  local funcid = mtb_text:GetItemKeyByIndex(index)
  local tmp1, tmp2 = math.modf(funcid / 10)
  local chapter_id = tmp1
  local round_id = funcid - chapter_id * 10
  form_drama.content_page_index = tonumber(form_drama.cur_page_id)
  local temp_table = page_content_table_funcid[form_drama.content_page_index]
  for count = 1, table.getn(temp_table) do
    if nx_int(temp_table[count]) == nx_int(funcid) then
      form_drama.content_index = tonumber(count)
    end
  end
  if round_id == 0 then
    round_id = 1
    local content_page_index = form_drama.content_page_index
    local content_index = form_drama.content_index
    if tonumber(content_page_index) == tonumber(table.getn(page_content_table)) and tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
      return
    end
    if tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
      content_page_index = tonumber(content_page_index + 1)
      content_index = tonumber(1)
    else
      content_index = tonumber(content_index + 1)
    end
    form_drama.content_page_index = tonumber(content_page_index)
    form_drama.content_index = tonumber(content_index)
  end
  local obj_ident = form_drama.player_ident
  local drama_name = form_drama.drama_name
  form_drama.chapter_id = chapter_id
  form_drama.round_id = round_id
  form_drama.text_id = ""
  set_cur_page_type(1)
  form_drama.cur_page_id = 1
  update_pageno(form_drama)
  form_drama.b_click_perv = false
  operate_page_text()
end
function on_btn_opentask_click(btn)
  local form_drama = nx_value("form_stage_main\\form_drama")
  if nx_is_valid(form_drama) then
    form_drama:Close()
  end
  nx_execute("util_gui", "util_show_form", "form_stage_main\\form_task\\form_task_main", true)
end
function pervpage_text(form_drama)
  if not nx_is_valid(form_drama) then
    return false
  end
  if table.getn(page_content_table) == 0 then
    return false
  end
  if form_drama.cur_page_id > 1 then
    form_drama.cur_page_id = form_drama.cur_page_id - 1
    show_cur_page_text(form_drama.chapter_id, form_drama.round_id)
    update_pageno(form_drama)
  elseif form_drama.chapter_id == 1 and form_drama.round_id == 1 then
    set_cur_page_type(0)
    form_drama.cur_page_id = table.getn(page_content_table)
    update_pageno(form_drama)
    set_content_date(2)
    form_drama.b_click_perv = false
    show_cur_page_content()
  else
    local content_page_index = form_drama.content_page_index
    local content_index = form_drama.content_index
    if tonumber(content_page_index) == tonumber(1) and tonumber(content_index) == tonumber(1) then
      set_content_date(2)
      return false
    end
    if tonumber(content_index) == tonumber(1) then
      content_page_index = tonumber(content_page_index - 1)
      content_index = table.getn(page_content_table[content_page_index])
    else
      content_index = tonumber(content_index - 1)
    end
    local funcid = tonumber(page_content_table_funcid[content_page_index][content_index])
    local tmp1, tmp2 = math.modf(funcid / 10)
    local chapter_id = tmp1
    local round_id = funcid - chapter_id * 10
    if round_id == 0 then
      if tonumber(content_page_index) == tonumber(1) and tonumber(content_index) == tonumber(1) then
        set_content_date(2)
        return false
      end
      if tonumber(content_index) == tonumber(1) then
        content_page_index = tonumber(content_page_index - 1)
        content_index = table.getn(page_content_table[content_page_index])
      else
        content_index = tonumber(content_index - 1)
      end
      funcid = tonumber(page_content_table_funcid[content_page_index][content_index])
      tmp1, tmp2 = math.modf(funcid / 10)
      chapter_id = tmp1
      round_id = funcid - chapter_id * 10
    end
    form_drama.content_page_index = content_page_index
    form_drama.content_index = content_index
    local obj_ident = form_drama.player_ident
    local drama_name = form_drama.drama_name
    form_drama.chapter_id = chapter_id
    form_drama.round_id = round_id
    form_drama.text_id = ""
    local drama_content_ini = nx_execute("util_functions", "get_ini", "share\\Drama\\DramaContent.ini")
    if not nx_is_valid(drama_content_ini) then
      return false
    end
    local section_name = drama_name .. "-" .. chapter_id .. "-" .. round_id
    set_cur_page_type(1)
    form_drama.b_click_perv = true
    operate_page_text()
    local page_total = 1
    local page_text_table = nx_function("ext_split_string", nx_string(form_drama.page_text), nx_string("|"))
    if table.getn(page_text_table) > 0 then
      page_total = table.getn(page_text_table)
    end
    form_drama.cur_page_id = page_total
    update_pageno(form_drama)
  end
  return true
end
function nextpage_text(form_drama)
  if not nx_is_valid(form_drama) then
    return false
  end
  if table.getn(page_content_table) == 0 then
    return false
  end
  local page_text_table = nx_function("ext_split_string", nx_string(form_drama.page_text), nx_string("|"))
  if table.getn(page_text_table) == 0 then
    return false
  end
  if form_drama.cur_page_id < table.getn(page_text_table) then
    form_drama.cur_page_id = form_drama.cur_page_id + 1
    show_cur_page_text(form_drama.chapter_id, form_drama.round_id)
    update_pageno(form_drama)
  else
    local content_page_index = form_drama.content_page_index
    local content_index = form_drama.content_index
    if tonumber(content_page_index) == tonumber(table.getn(page_content_table)) and tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
      return false
    end
    if tonumber(table.getn(page_content_table)) < tonumber(content_page_index) then
      return false
    end
    if tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
      content_page_index = tonumber(content_page_index + 1)
      content_index = tonumber(1)
    else
      content_index = tonumber(content_index + 1)
    end
    local tmptable1 = page_content_table_funcid[content_page_index]
    local funcid = tonumber(tmptable1[content_index])
    local tmp1, tmp2 = math.modf(funcid / 10)
    local chapter_id = tmp1
    local round_id = funcid - chapter_id * 10
    if round_id == 0 then
      if tonumber(content_page_index) == tonumber(table.getn(page_content_table)) and tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
        return false
      end
      if tonumber(content_index) == tonumber(table.getn(page_content_table[content_page_index])) then
        content_page_index = tonumber(content_page_index + 1)
        content_index = tonumber(1)
      else
        content_index = tonumber(content_index + 1)
      end
      funcid = tonumber(page_content_table_funcid[content_page_index][content_index])
      tmp1, tmp2 = math.modf(funcid / 10)
      chapter_id = tmp1
      round_id = funcid - chapter_id * 10
    end
    form_drama.content_page_index = content_page_index
    form_drama.content_index = content_index
    local obj_ident = form_drama.player_ident
    local drama_name = form_drama.drama_name
    form_drama.chapter_id = chapter_id
    form_drama.round_id = round_id
    form_drama.text_id = ""
    set_cur_page_type(1)
    form_drama.cur_page_id = 1
    update_pageno(form_drama)
    form_drama.b_click_perv = false
    operate_page_text()
  end
  return true
end
function pervpage_content(form_drama)
  if not nx_is_valid(form_drama) then
    return false
  end
  if table.getn(page_content_table) == 0 then
    return false
  end
  if form_drama.cur_page_id > 1 then
    form_drama.cur_page_id = form_drama.cur_page_id - 1
    update_pageno(form_drama)
    show_cur_page_content()
  end
  return true
end
function nextpage_content(form_drama)
  if not nx_is_valid(form_drama) then
    return false
  end
  if table.getn(page_content_table) == 0 then
    return false
  end
  if form_drama.cur_page_id < table.getn(page_content_table) then
    form_drama.cur_page_id = form_drama.cur_page_id + 1
    show_cur_page_content()
    update_pageno(form_drama)
  end
  return true
end
function set_page_text_table()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.text_id == "" then
    return
  end
  local split_table = nx_function("ext_split_string", nx_string(form_drama.text_id), nx_string(";"))
  if table.getn(split_table) == 0 then
    return
  end
  local gui = nx_value("gui")
  local text_table = ""
  form_drama.mtb_text:Clear()
  for count = 1, table.getn(split_table) do
    local tmp = split_table[count]
    if nx_string(split_table[count]) ~= nx_string("") then
      local font_text_table = nx_function("ext_split_string", nx_string(split_table[count]), nx_string(","))
      local font_text
      local tmp_text = ""
      if table.getn(font_text_table) == 2 then
        font_text = font_text_table[1]
        tmp_text = font_text_table[2]
      else
        tmp_text = split_table[count]
      end
      if check_text(form_drama.mtb_text, tmp_text, font_text) then
        if text_table == "" then
          text_table = split_table[count]
        else
          text_table = text_table .. ";" .. split_table[count]
        end
      else
        if text_table ~= "" then
          if form_drama.page_text == "" then
            form_drama.page_text = text_table
          else
            form_drama.page_text = form_drama.page_text .. "|" .. text_table
          end
        end
        text_table = ""
        form_drama.mtb_text:Clear()
        if text_table == "" then
          text_table = split_table[count]
        else
          text_table = text_table .. ";" .. split_table[count]
        end
        if font_text == nil then
          form_drama.mtb_text:AddHtmlText(gui.TextManager:GetText(split_table[count]), nx_int(-1))
        else
          local tmp = "<center><font face=\"" .. font_text .. "\">" .. nx_string(gui.TextManager:GetText(tmp_text)) .. "</font></center>"
          form_drama.mtb_text:AddHtmlText(nx_widestr(tmp), nx_int(-1))
        end
      end
    end
    if table.getn(split_table) == count then
      if form_drama.page_text == "" then
        form_drama.page_text = text_table
      else
        form_drama.page_text = form_drama.page_text .. "|" .. text_table
      end
    end
  end
end
function check_text(mtb_text, text_id, font)
  local gui = nx_value("gui")
  local tmp_text = ""
  if font == nil then
    tmp_text = gui.TextManager:GetText(text_id)
  else
    tmp_text = "<center><font face=\"" .. font .. "\">" .. nx_string(gui.TextManager:GetText(text_id)) .. "</font></center>"
  end
  mtb_text:AddHtmlText(nx_widestr(tmp_text), nx_int(-1))
  local tmp1 = mtb_text:GetContentHeight()
  local tmp2 = mtb_text.Height
  if tonumber(tmp1) <= tonumber(tmp2) then
    return true
  else
    return false
  end
end
function clear_page_text_table()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  form_drama.page_text = ""
end
function show_cur_page_text(chapter_id, round_id)
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.cur_page_type ~= 1 then
    return
  end
  local page_text_table = nx_function("ext_split_string", nx_string(form_drama.page_text), nx_string("|"))
  if 1 > form_drama.cur_page_id or form_drama.cur_page_id > table.getn(page_text_table) then
    return
  end
  local gui = nx_value("gui")
  form_drama.mtb_text:Clear()
  local text_table = nx_function("ext_split_string", nx_string(page_text_table[form_drama.cur_page_id]), nx_string(";"))
  for count = 1, table.getn(text_table) do
    local text_id = text_table[count]
    local tmp_table = nx_function("ext_split_string", nx_string(text_id), nx_string(","))
    if table.getn(tmp_table) == 2 then
      local begin_font = ""
      local end_font = ""
      local title_text = ""
      if count == 1 then
        begin_font = "<center><font face=\"" .. nx_string(tmp_table[1]) .. "\" color=\"#" .. nx_string(color_chapter_name) .. "\">"
        end_font = "</font></center>"
        title_text = util_text("ui_drama_chapter_" .. nx_string(chapter_id))
      elseif count == 2 then
        begin_font = "<center><font face=\"" .. nx_string(tmp_table[1]) .. "\" color=\"#" .. nx_string(color_round_name) .. "\">"
        end_font = "</font></center>"
        title_text = util_text("ui_drama_round_" .. nx_string(round_id))
      end
      local text = nx_widestr(title_text) .. nx_widestr(" ") .. nx_widestr(util_text(tmp_table[2]))
      text = nx_widestr(begin_font) .. nx_widestr(text) .. nx_widestr(end_font)
      local index = form_drama.mtb_text:AddHtmlText(nx_widestr(text), nx_int(-1))
      form_drama.mtb_text:SetHtmlItemSelectable(nx_int(index), false)
    else
      local temp_text = gui.TextManager:GetText(text_id)
      local index = form_drama.mtb_text:AddHtmlText(nx_widestr(temp_text), nx_int(-1))
      form_drama.mtb_text:SetHtmlItemSelectable(nx_int(index), false)
    end
  end
end
function set_page_content_table()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetSceneObj(form_drama.player_ident)
  if not nx_is_valid(player_obj) then
    return
  end
  if not player_obj:FindRecord(DramaRec) then
    return
  end
  if player_obj:GetRecordRows(DramaRec) < 1 then
    return
  end
  form_drama.drama_name = player_obj:QueryRecord(DramaRec, 0, 0)
  local cur_chapter_id = player_obj:QueryRecord(DramaRec, 0, 1)
  local cur_round_id = player_obj:QueryRecord(DramaRec, 0, 2)
  local text_table = {}
  local text_table_funcid = {}
  for chapter_count = 1, cur_chapter_id do
    local content = form_drama.drama_name .. "_" .. chapter_count
    local content_funcid = chapter_count * 10 + 0
    table.insert(text_table, content)
    table.insert(text_table_funcid, content_funcid)
    if chapter_count < cur_chapter_id then
      for round_id = 1, 4 do
        content = "" .. form_drama.drama_name .. "_" .. chapter_count .. "_" .. round_id
        content_funcid = chapter_count * 10 + round_id
        table.insert(text_table, content)
        table.insert(text_table_funcid, content_funcid)
      end
    else
      for round_id = 1, cur_round_id do
        content = "" .. form_drama.drama_name .. "_" .. chapter_count .. "_" .. round_id
        content_funcid = chapter_count * 10 + round_id
        table.insert(text_table, content)
        table.insert(text_table_funcid, content_funcid)
      end
    end
    if chapter_count < cur_chapter_id then
      local first, second = math.modf(chapter_count / CHAPTER_COUNT_PER_PAGE)
      if second == 0 then
        table.insert(page_content_table, text_table)
        table.insert(page_content_table_funcid, text_table_funcid)
        text_table = {}
        text_table_funcid = {}
      end
    else
      table.insert(page_content_table, text_table)
      table.insert(page_content_table_funcid, text_table_funcid)
    end
  end
end
function clear_page_content_table()
  page_content_table = {}
  page_content_table_funcid = {}
  local form = nx_value("form_stage_main\\form_drama")
  if nx_is_valid(form) then
    form.lbl_book_name.Text = ""
    form.lbl_chapter_1.Text = ""
    form.mtb_chapter_1:Clear()
    form.mtb_round_1_1:Clear()
    form.mtb_round_1_2:Clear()
    form.mtb_round_1_3:Clear()
    form.mtb_round_1_4:Clear()
    form.lbl_chapter_2.Text = ""
    form.mtb_chapter_2:Clear()
    form.mtb_round_2_1:Clear()
    form.mtb_round_2_2:Clear()
    form.mtb_round_2_3:Clear()
    form.mtb_round_2_4:Clear()
  end
end
function clear_content_control()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  for count_1 = 1, CHAPTER_COUNT_PER_PAGE do
    local str_lbl_chapter = "lbl_chapter_" .. count_1
    local str_mtb_chapter = "mtb_chapter_" .. count_1
    local control = nx_null()
    control = find_child_control(form_drama, count_1, str_lbl_chapter)
    if nx_is_valid(control) then
      control.Text = nx_widestr("")
    end
    control = find_child_control(form_drama, count_1, str_mtb_chapter)
    if nx_is_valid(control) then
      control:Clear()
    end
    for count_2 = 1, 4 do
      local str_mtb_round = "mtb_round_" .. count_1 .. "_" .. count_2
      control = find_child_control(form_drama, count_1, str_mtb_round)
      if nx_is_valid(control) then
        control:Clear()
      end
    end
  end
end
function show_cur_page_content()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  if form_drama.cur_page_type ~= 0 then
    return
  end
  if table.getn(page_content_table) == 0 then
    return
  end
  if form_drama.cur_page_id < 1 or form_drama.cur_page_id > table.getn(page_content_table) then
    return
  end
  local gui = nx_value("gui")
  clear_content_control()
  form_drama.lbl_book_name.Text = gui.TextManager:GetText(form_drama.drama_name)
  local text_table = page_content_table[form_drama.cur_page_id]
  local text_table_funcid = page_content_table_funcid[form_drama.cur_page_id]
  local table_index = 1
  for chapter_count = 1, CHAPTER_COUNT_PER_PAGE do
    if table_index > table.getn(text_table) then
      break
    end
    local textid = text_table[table_index]
    local funcid = text_table_funcid[table_index]
    local control = nx_null()
    local str_lbl_chapter = "lbl_chapter_" .. chapter_count
    control = find_child_control(form_drama, chapter_count, str_lbl_chapter)
    if nx_is_valid(control) then
      local num = chapter_count + (form_drama.cur_page_id - 1) * CHAPTER_COUNT_PER_PAGE
      local str_di = gui.TextManager:GetText("ui_Di")
      local str_zh = gui.TextManager:GetText("ui_zhang")
      control.Text = nx_widestr(nx_string(str_di) .. num .. nx_string(str_zh))
    end
    local str_mtb_chapter = "mtb_chapter_" .. chapter_count
    control = find_child_control(form_drama, chapter_count, str_mtb_chapter)
    if nx_is_valid(control) then
      control:AddHtmlText(gui.TextManager:GetText(textid), nx_int(funcid))
    end
    table_index = table_index + 1
    for round_count = 1, 4 do
      if table_index > table.getn(text_table) then
        break
      end
      textid = text_table[table_index]
      funcid = text_table_funcid[table_index]
      local str_mtb_round = "mtb_round_" .. chapter_count .. "_" .. round_count
      control = find_child_control(form_drama, chapter_count, str_mtb_round)
      if nx_is_valid(control) then
        control:AddHtmlText(gui.TextManager:GetText(textid), nx_int(funcid))
      end
      table_index = table_index + 1
    end
  end
end
function operate_page_text()
  local form_drama = nx_value("form_stage_main\\form_drama")
  if not nx_is_valid(form_drama) then
    return
  end
  local game_client = nx_value("game_client")
  local player_obj = game_client:GetSceneObj(form_drama.player_ident)
  if not nx_is_valid(player_obj) then
    return
  end
  if not player_obj:FindRecord(DramaRec) then
    return
  end
  if player_obj:GetRecordRows(DramaRec) < 1 then
    return
  end
  local chapter_id = form_drama.chapter_id
  local round_id = form_drama.round_id
  local cur_chapter_id = player_obj:QueryRecord(DramaRec, 0, 1)
  local cur_round_id = player_obj:QueryRecord(DramaRec, 0, 2)
  local cur_section_id = player_obj:QueryRecord(DramaRec, 0, 3)
  if nx_int(cur_chapter_id) < nx_int(chapter_id) then
    return
  end
  if nx_int(cur_chapter_id) == nx_int(chapter_id) and nx_int(cur_round_id) < nx_int(round_id) then
    return
  end
  local drama_content_ini = nx_execute("util_functions", "get_ini", "share\\Drama\\DramaContent.ini")
  if not nx_is_valid(drama_content_ini) then
    return
  end
  local section_name = form_drama.drama_name .. "-" .. chapter_id .. "-" .. round_id
  local section_num = 0
  if nx_int(chapter_id) < nx_int(cur_chapter_id) then
    local sec_idx = drama_content_ini:FindSectionIndex(nx_string(section_name))
    if 0 <= sec_idx then
      section_num = drama_content_ini:GetSectionItemCount(sec_idx)
    end
  elseif nx_int(chapter_id) == nx_int(cur_chapter_id) then
    if nx_int(round_id) < nx_int(cur_round_id) then
      local sec_idx = drama_content_ini:FindSectionIndex(nx_string(section_name))
      if 0 <= sec_idx then
        section_num = drama_content_ini:GetSectionItemCount(sec_idx)
      end
    elseif nx_int(round_id) == nx_int(cur_round_id) then
      section_num = cur_section_id
    end
  end
  if nx_int(round_id) == nx_int(1) then
    form_drama.text_id = font_chapter_name .. "," .. form_drama.drama_name .. "_" .. chapter_id .. ";"
    form_drama.text_id = form_drama.text_id .. font_chapter_name .. "," .. form_drama.drama_name .. "_" .. chapter_id .. "_" .. round_id .. ";"
  else
    form_drama.text_id = font_chapter_name .. "," .. form_drama.drama_name .. "_" .. chapter_id .. ";"
    form_drama.text_id = form_drama.text_id .. font_chapter_name .. "," .. form_drama.drama_name .. "_" .. chapter_id .. "_" .. round_id .. ";"
  end
  local sec_idx = drama_content_ini:FindSectionIndex(nx_string(section_name))
  if sec_idx < 0 then
    return ""
  end
  for count_1 = 1, tonumber(section_num) do
    local section_text = "desc_" .. drama_content_ini:GetSectionItemValue(sec_idx, count_1 - 1) .. ";"
    form_drama.text_id = form_drama.text_id .. section_text
  end
  clear_page_text_table()
  set_page_text_table()
  if form_drama.b_click_perv == true then
    form_drama.cur_page_id = table.getn(nx_function("ext_split_string", nx_string(form_drama.page_text), nx_string("|")))
  end
  show_cur_page_text(form_drama.chapter_id, form_drama.round_id)
end
function find_child_control(form, index, name)
  local control_table = form:GetChildControlList()
  local control = nx_null()
  local str_group = "gb_content_" .. index
  local gb_control = form.gb_content:Find(str_group)
  if not nx_is_valid(gb_control) then
    return control
  end
  control = gb_control:Find(name)
  return control
end
function update_pageno(form)
  if nx_is_valid(form) then
    form.lbl_3.Text = nx_widestr(form.cur_page_id)
  end
end
function on_rbtn_checked_changed(rbtn)
  if rbtn.Checked then
    if rbtn.TabIndex == 1 then
      DramaRec = "DramaRec"
    elseif rbtn.TabIndex == 2 then
      DramaRec = "SchoolDramaRec"
    end
    local form_drama = nx_value("form_stage_main\\form_drama")
    if not nx_is_valid(form_drama) then
      return false
    end
    clear_page_content_table()
    init_drama(form_drama)
  end
end
function show_drama(index)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_drama", true, false)
  if nx_is_valid(form) then
    form:Show()
    if nx_number(index) == nx_number(1) then
      form.rbtn_drama.Checked = true
    elseif nx_number(index) == nx_number(2) then
      form.rbtn_school.Checked = true
    end
  end
end
