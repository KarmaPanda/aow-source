require("util_gui")
require("role_composite")
require("share\\client_custom_define")
require("form_stage_main\\form_origin\\form_origin_define")
function open_form()
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(3))
end
function auto_show_hide_origin()
  nx_execute("form_stage_main\\form_war_scuffle\\form_scuffle_main", "custom_open_limite_form", nx_int(3))
end
function reset_scene()
  local bVisible = false
  local form = nx_value(FORM_ORIGIN)
  if nx_is_valid(form) then
    bVisible = form.Visible
    form:Close()
  else
    bVisible = false
  end
  nx_execute("util_gui", "util_auto_show_hide_form", FORM_ORIGIN)
  form = nx_value(FORM_ORIGIN)
  if nx_is_valid(form) then
    form.Visible = bVisible
  end
end
function main_form_init(form)
  form.Fixed = false
  form.actor2 = nil
  form.actor2_body3 = nil
  form.actor2_body4 = nil
  form.actor2_body5 = nil
  form.actor2_body6 = nil
  form.cur_actor2 = nil
  form.main_type = ORIGIN_TYPE_JIANGHU
  form.sub_type = 1
  form.sub_type_str = ""
  form.oid = 0
  form.cbtn_index = 0
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
end
function on_main_form_open(form)
  form.btn_menpai_left.Visible = false
  form.btn_menpai_right.Visible = false
  ShowSceneBox(form, 0)
  form_rp_arm_showrole(form)
  form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_WOMAN_JUV)
  form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_MAN_JUV)
  form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_WOMAN_MAJ)
  form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_MAN_MAJ)
  load_line_form(form, form.groupbox_out)
  load_school_sub_line_form(form, form.groupbox_school_sub)
  load_force_form(form, form.groupbox_force)
  load_jianghu_chengjiu_form(form, form.groupbox_chengjiu)
  load_life_form(form, form.groupbox_life)
  load_guild_form(form, form.groupbox_guild)
  load_line_new_form(form, form.groupbox_new_school)
  form.groupbox_desc.Left = 175
  form.groupbox_desc.Top = 63
  form.groupbox_sub_info.Left = 174
  form.groupbox_sub_info.Top = 72
  form.groupbox_1.Visible = false
  show_main_radiobtn_name(form)
  show_sub_radiobtn_name(form)
  form.groupbox_complete_origin.pageno = 1
  data_bind_prop(form)
  form.cur_sex = 0
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    form.cur_sex = player:QueryProp("Sex")
  end
end
function on_main_form_close(form)
  if nx_is_valid(form.actor2) then
    local world = nx_value("world")
    world:Delete(form.actor2)
  end
  local world = nx_value("world")
  if nx_is_valid(form.actor2_body3) then
    world:Delete(form.actor2_body3)
  end
  if nx_is_valid(form.actor2_body4) then
    world:Delete(form.actor2_body4)
  end
  if nx_is_valid(form.actor2_body5) then
    world:Delete(form.actor2_body5)
  end
  if nx_is_valid(form.actor2_body6) then
    world:Delete(form.actor2_body6)
  end
  local is_help = nx_custom(form, "is_help")
  if is_help == nil or is_help == false then
    del_data_bind_prop(form)
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister("form_stage_main\\form_origin\\form_origin_desc", "play_action", form)
    end
    ui_destroy_attached_form(form)
    local form_origin_line = nx_value(FORM_ORIGIN_LINE)
    if nx_is_valid(form_origin_line) then
      nx_destroy(form_origin_line)
    end
    local form_origin_school_sub_line = nx_value(FORM_ORIGIN_SCHOOL_SUB_LINE)
    if nx_is_valid(form_origin_school_sub_line) then
      nx_destroy(form_origin_school_sub_line)
    end
    local form_origin_force = nx_value(FORM_ORIGIN_FORCE)
    if nx_is_valid(form_origin_force) then
      nx_destroy(form_origin_force)
    end
    local form_origin_chengjiu = nx_value(FORM_ORIGIN_CHENGJIU)
    if nx_is_valid(form_origin_chengjiu) then
      nx_destroy(form_origin_chengjiu)
    end
    local form_origin_life = nx_value(FORM_ORIGIN_LIFE)
    if nx_is_valid(form_origin_life) then
      nx_destroy(form_origin_life)
    end
    local form_origin_guild = nx_value(FORM_ORIGIN_GUILD)
    if nx_is_valid(form_origin_guild) then
      nx_destroy(form_origin_guild)
    end
    local form_origin_line_new = nx_value(FORM_ORIGIN_LINE_NEW)
    if nx_is_valid(form_origin_line_new) then
      nx_destroy(form_origin_line_new)
    end
    nx_destroy(form)
  end
end
function on_form_active(self)
  nx_execute("util_gui", "ui_bring_attach_form_to_front", self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
function on_rbtn_main_type_click(rbtn)
  local main_type = rbtn.TabIndex
  local b_checked = rbtn.Checked
  local form = rbtn.ParentForm
  if b_checked then
    form.main_type = main_type
    form.sub_type = 1
    local game_client = nx_value("game_client")
    local client_player = game_client:GetPlayer()
    local school = client_player:QueryProp("School")
    local force = client_player:QueryProp("Force")
    local new_school = client_player:QueryProp("NewSchool")
    if main_type == ORIGIN_TYPE_MENPAI then
      if 1 < string.len(nx_string(school)) then
        for key, value in pairs(type_table[1]) do
          local rbtn_name = "rbtn_sub_" .. nx_string(key)
          local rbtn = form.groupbox_tab_sub:Find(rbtn_name)
          if not nx_is_valid(rbtn) then
            break
          end
          if school == value then
            form.sub_type = key
            local png_name = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. string.sub(nx_string(school), 8, -1) .. ".png"
            form.lbl_sub_title.BackImage = png_name
          end
        end
      end
      form.btn_first.Checked = true
      form.lbl_12.Left = form.btn_first.Left + 43
    elseif main_type == ORIGIN_TYPE_JIANGHU then
      form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuyueli.png"
    elseif main_type == ORIGIN_TYPE_LIFE then
      form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\shenghuo.png"
    elseif main_type == ORIGIN_TYPE_GUILD then
      form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\banghui.png"
    elseif main_type == ORIGIN_TYPE_FORCE then
      local form_force = form.form_force
      if not nx_is_valid(form_force) then
        return
      end
      form_force.btn_line_1.sub_type = "school_wulin"
      if string.len(nx_string(force)) > 0 then
        for key, value in pairs(type_table[5]) do
          local rbtn_name = "rbtn_sub_" .. nx_string(key)
          local rbtn = form.groupbox_tab_sub:Find(rbtn_name)
          if not nx_is_valid(rbtn) then
            break
          end
          if force == value then
            form.sub_type = key
            form_force.btn_line_1.sub_type = value
            form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(force) .. ".png"
          end
        end
      elseif nx_int(string.len(nx_string(force))) == nx_int(0) and nx_int(string.len(nx_string(school))) == nx_int(0) and nx_int(string.len(nx_string(new_school))) == nx_int(0) then
        form.sub_type = 1
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\school_wulin.png"
      else
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\school_wulin.png"
      end
      form_force.btn_line_1.Checked = true
    elseif main_type == ORIGIN_TYPE_NEW_SCHOOL then
      local form_line_new = form.form_line_new
      if not nx_is_valid(form_line_new) then
        return
      end
      local game_client = nx_value("game_client")
      local player = game_client:GetPlayer()
      if nx_is_valid(player) then
        if player:QueryProp("Sex") == 0 then
          form_line_new.btn_line_1.sub_type = "school_gumu_1"
        else
          form_line_new.btn_line_1.sub_type = "school_gumu_0_1"
        end
      end
      if string.len(nx_string(new_school)) > 0 then
        for key, value in pairs(type_table[6]) do
          local rbtn_name = "rbtn_sub_" .. nx_string(key)
          local rbtn = form.groupbox_tab_sub:Find(rbtn_name)
          if not nx_is_valid(rbtn) then
            break
          end
          if shcool == value then
            form.sub_type = key
            form_line_new.btn_line_1.sub_type = value
            form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(new_school) .. ".png"
          end
        end
      end
      form_line_new.btn_line_1.Checked = true
    end
    show_sub_radiobtn_name(form)
    refresh_type_origin(form, form.main_type, form.sub_type)
    form.oid = 0
    form_rp_arm_showrole(form)
    form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_WOMAN_JUV)
    form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_MAN_JUV)
    form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_WOMAN_MAJ)
    form_rp_arm_showrole_body(form, ORIGIN_EM_BODY_MAN_MAJ)
  end
end
function on_rbtn_sub_type_click(rbtn)
  local sub_type = rbtn.TabIndex
  local b_checked = rbtn.Checked
  local form = rbtn.ParentForm
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  form.ScrollBar2.Value = 0
  local gui = nx_value("gui")
  if b_checked then
    form.sub_type = sub_type
    if form.main_type == ORIGIN_TYPE_MENPAI then
      local png_name = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. string.sub(type_table[1][sub_type], 8, -1) .. ".png"
      form.lbl_sub_title.BackImage = png_name
    elseif form.main_type == ORIGIN_TYPE_JIANGHU then
      local form_chengjiu = nx_custom(form, "form_chengjiu")
      for i = 1, 6 do
        local rbtn_name = "rbtn_" .. nx_string(i)
        local rbtn = nx_custom(form_chengjiu, rbtn_name)
        local lbl_name = "rbtn_" .. nx_string(i) .. "_text"
        local lbl = nx_custom(form_chengjiu, lbl_name)
        if nx_is_valid(rbtn) and nx_is_valid(lbl) then
          rbtn.Visible = false
          lbl.Visible = false
        end
      end
      if sub_type == 1 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuyueli.png"
      elseif sub_type == 2 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuchengjiu.png"
        local rbtn_count = table.getn(jianghu_chengjiu_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        else
          form_chengjiu.btn_pre.Visible = true
          form_chengjiu.btn_next.Visible = true
        end
        for i = 1, rbtn_count do
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(jianghu_chengjiu_table[i]))
            rbtn.sub_type = jianghu_chengjiu_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. jianghu_chengjiu_table[i] .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. jianghu_chengjiu_table[i] .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. jianghu_chengjiu_table[i] .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      elseif sub_type == 3 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuwuxue.png"
        local rbtn_count = table.getn(wuxue_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        end
        for i = 1, rbtn_count do
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(wuxue_table[i]))
            rbtn.sub_type = wuxue_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. wuxue_table[i] .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. wuxue_table[i] .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. wuxue_table[i] .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      elseif sub_type == 4 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghujiehun.png"
        local rbtn_count = 0
        local temp_table = marry_man_table
        if form.cur_sex == 1 then
          temp_table = marry_woman_table
        end
        rbtn_count = table.getn(temp_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        end
        for i = 1, rbtn_count do
          local pic_name_pre = string.sub(nx_string(temp_table[i]), 1, 5)
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(temp_table[i]))
            rbtn.sub_type = temp_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      elseif sub_type == 5 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghulover.png"
        local rbtn_count = 0
        local temp_table = lover_man_table
        if form.cur_sex == 1 then
          temp_table = lover_woman_table
        end
        rbtn_count = table.getn(temp_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        end
        for i = 1, rbtn_count do
          local pic_name_pre = string.sub(nx_string(temp_table[i]), 1, 5)
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(temp_table[i]))
            rbtn.sub_type = temp_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. pic_name_pre .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      elseif sub_type == 6 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuvip.png"
        local rbtn_count = table.getn(jianghu_vip_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        end
        for i = 1, rbtn_count do
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(jianghu_vip_table[i]))
            rbtn.sub_type = jianghu_vip_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. jianghu_vip_table[i] .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. jianghu_vip_table[i] .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. jianghu_vip_table[i] .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      elseif sub_type == 7 then
        form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\jianghuchengjiu.png"
        local temp_table = jianghu_body_table
        if form.cur_sex == 1 then
          temp_table = jianghu_body_woman_table
        end
        local rbtn_count = table.getn(temp_table)
        if rbtn_count < 5 then
          form_chengjiu.btn_pre.Visible = false
          form_chengjiu.btn_next.Visible = false
        else
          form_chengjiu.btn_pre.Visible = true
          form_chengjiu.btn_next.Visible = true
        end
        for i = 1, rbtn_count do
          local rbtn_name = "rbtn_" .. nx_string(i)
          local rbtn = nx_custom(form_chengjiu, rbtn_name)
          local lbl_name = nx_string(rbtn_name) .. "_text"
          local lbl = nx_custom(form_chengjiu, lbl_name)
          if nx_is_valid(rbtn) and nx_is_valid(lbl) then
            lbl.Text = nx_widestr(gui.TextManager:GetText(temp_table[i]))
            rbtn.sub_type = temp_table[i]
            rbtn.NormalImage = "gui\\special\\origin\\button\\" .. temp_table[i] .. "_out.png"
            rbtn.FocusImage = "gui\\special\\origin\\button\\" .. temp_table[i] .. "_on.png"
            rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. temp_table[i] .. "_down.png"
            rbtn.Visible = true
            lbl.Visible = true
          end
        end
        form_chengjiu.rbtn_1.Checked = true
      end
    elseif form.main_type == ORIGIN_TYPE_LIFE then
      form.form_life.btn_line_1.Checked = true
      form.form_life.lbl_2.Left = form.form_life.btn_line_1.Left + 30
    elseif form.main_type == ORIGIN_TYPE_GUILD then
      if not sub_type == 1 then
        return
      end
    elseif form.main_type == ORIGIN_TYPE_FORCE then
      local form_force = nx_custom(form, "form_force")
      if not nx_is_valid(form_force) then
        return
      end
      for i = 1, 5 do
        local rbtn_name = "btn_line_" .. nx_string(i)
        local rbtn = nx_custom(form_force, rbtn_name)
        local lbl_name = "btn_line_" .. nx_string(i) .. "_text"
        local lbl = nx_custom(form_force, lbl_name)
        if nx_is_valid(rbtn) and nx_is_valid(lbl) then
          rbtn.Visible = false
          lbl.Visible = false
        end
      end
      if sub_type > table.getn(type_table[5]) then
        return
      end
      local force = type_table[5][sub_type]
      local third_index_table = {}
      if force == "school_wulin" then
        third_index_table = wulin_table
      elseif force == "force_yihua" then
        third_index_table = yihua_man_table
        if nx_int(form.cur_sex) == nx_int(1) then
          third_index_table = yihua_woman_table
        end
      elseif force == "force_taohua" then
        third_index_table = taohua_table
      elseif force == "force_xujia" then
        third_index_table = xujia_table
      elseif force == "force_wugen" then
        third_index_table = wugen_table
      elseif force == "force_wanshou" then
        third_index_table = wanshou_table
      elseif force == "force_jinzhen" then
        third_index_table = jinzhen_table
      else
        return
      end
      form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(force) .. ".png"
      local rbtn_count = table.getn(third_index_table)
      if rbtn_count < 5 then
        form_force.btn_pre.Visible = false
        form_force.btn_next.Visible = false
      end
      for i = 1, rbtn_count do
        local rbtn_name = "btn_line_" .. nx_string(i)
        local rbtn = nx_custom(form_force, rbtn_name)
        local lbl_name = nx_string(rbtn_name) .. "_text"
        local lbl = nx_custom(form_force, lbl_name)
        if nx_is_valid(rbtn) and nx_is_valid(lbl) then
          lbl.Text = nx_widestr(gui.TextManager:GetText(third_index_table[i]))
          rbtn.sub_type = third_index_table[i]
          rbtn.NormalImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_out.png"
          rbtn.FocusImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_on.png"
          rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_down.png"
          rbtn.Visible = true
          lbl.Visible = true
        end
      end
      form_force.btn_line_1.Checked = true
    elseif form.main_type == ORIGIN_TYPE_NEW_SCHOOL then
      local form_line_new = nx_custom(form, "form_line_new")
      if not nx_is_valid(form_line_new) then
        return
      end
      form_line_new.btn_line_1.Checked = true
      show_new_school(form, form.sub_type)
    end
    refresh_type_origin(form, form.main_type, form.sub_type)
  end
end
function on_ScrollBar1_value_changed(self, value)
  local form = nx_value(FORM_ORIGIN)
  local form_line = nx_value(FORM_ORIGIN_LINE)
  local form_chengjiu = nx_value(FORM_ORIGIN_CHENGJIU)
  local sub_type_str = form.sub_type_str
  local move_form = form_line
  if form.main_type == ORIGIN_TYPE_LIFE then
    move_form = form.groupbox_life
  end
  if sub_type_str == "jianghu_jianghu" then
    move_form = form.groupbox_chengjiu
  end
  local max = move_form.Width - form.groupbox_sub_info.Width
  local min = 0
  self.Maximum = max
  self.Minimum = 0
  local totles = self.Maximum - self.Minimum
  local cur = self.Value - self.Minimum
  local cur_pos = cur / totles * (max - min)
  move_form.Left = 0 - cur_pos
end
function on_ScrollBar2_value_changed(self, value)
  local form = nx_value(FORM_ORIGIN)
  local form_line = nx_value(FORM_ORIGIN_LINE)
  local form_chengjiu = nx_value(FORM_ORIGIN_CHENGJIU)
  local sub_type_str = form.sub_type_str
  if form.main_type == ORIGIN_TYPE_LIFE then
    move_form = form.groupbox_life
  end
  if sub_type_str == "jianghu_jianghu" then
    move_form = form.groupbox_chengjiu
  end
  local max = move_form.Height - form.groupbox_out.Height
  local min = 0
  self.Maximum = max
  self.Minimum = 0
  local totles = self.Maximum - self.Minimum
  local cur = self.Value - self.Minimum
  local cur_pos = cur / totles * (max - min)
  move_form.Top = 0 - cur_pos
end
function on_ScrollBar3_value_changed(self, value)
  local form = nx_value(FORM_ORIGIN)
  local form_line_total_view = nx_value(FORM_LINE_TOTAL_VIEW)
  local move_form = form_line_total_view
  local max = move_form.Width - form.groupbox_show.Width
  local min = 0
  self.Maximum = max
  self.Minimum = 0
  local totles = self.Maximum - self.Minimum
  local cur = self.Value - self.Minimum
  local cur_pos = cur / totles * (max - min)
  move_form.Left = 0 - cur_pos
end
function on_btn_desc_close_click(btn)
  local form = nx_value(FORM_ORIGIN)
  show_sub_desc_form(form, false, true)
end
function on_btn_get_origin_click(btn)
  local form = btn.ParentForm
  local origin_id = form.oid
  if need_confirm(nx_int(origin_id)) then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    if nx_is_valid(dialog) then
      local gui = nx_value("gui")
      dialog.mltbox_info:Clear()
      dialog.mltbox_info.HtmlText = nx_widestr(gui.TextManager:GetText("choose_line_sure"))
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "cancel" then
        return
      end
    end
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN), nx_int(origin_id))
end
function on_btn_get_prize_click(btn)
  local form = btn.ParentForm
  local origin_id = form.oid
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GET_ORIGIN_PRIZE), nx_int(origin_id))
end
function on_btn_click(btn)
  nx_execute("form_stage_main\\form_helper\\form_main_helper_manager", "next_helper_form")
  nx_execute(FORM_ORIGIN_LINE, "on_btn_click", btn)
end
function on_imagegrid_item_prize_mousein_grid(grid, index)
  show_prize_tips(grid, index)
end
function on_imagegrid_item_prize_mouseout_grid(grid, index)
  nx_execute("tips_game", "hide_tip", grid.ParentForm)
end
function show_prize_tips(grid, index)
  local item_id = grid:GetItemName(nx_int(index))
  local item_count = grid:GetItemNumber(nx_int(index))
  if nx_string(item_id) == "" or nx_number(item_count) <= 0 then
    return false
  end
  local x = grid.AbsLeft + grid:GetItemLeft(index)
  local y = grid.AbsTop + grid:GetItemTop(index)
  local itemmap = nx_value("ItemQuery")
  if not nx_is_valid(itemmap) then
    return false
  end
  local table_prop_name = {}
  local table_prop_value = {}
  table_prop_name = itemmap:GetItemPropNameArrayByConfigID(nx_string(item_id))
  if 0 >= table.getn(table_prop_name) then
    return false
  end
  table_prop_value.ConfigID = nx_string(item_id)
  for count = 1, table.getn(table_prop_name) do
    local prop_name = table_prop_name[count]
    local prop_value = itemmap:GetItemPropByConfigID(nx_string(item_id), nx_string(prop_name))
    table_prop_value[prop_name] = prop_value
  end
  local staticdatamgr = nx_value("data_query_manager")
  if nx_is_valid(staticdatamgr) then
    local index = itemmap:GetItemPropByConfigID(nx_string(item_id), nx_string("ArtPack"))
    local photo = staticdatamgr:Query(nx_int(11), nx_int(index), nx_string("Photo"))
    if nx_string(photo) ~= "" and photo ~= nil then
      table_prop_value.Photo = photo
    end
  end
  if nx_is_valid(grid.Data) then
    nx_destroy(grid.Data)
  end
  grid.Data = nx_create("ArrayList", nx_current())
  grid.Data:ClearChild()
  for prop, value in pairs(table_prop_value) do
    nx_set_custom(grid.Data, prop, value)
  end
  nx_execute("tips_game", "show_goods_tip", grid.Data, x, y, 32, 32, grid.ParentForm)
end
function on_btn_first_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.groupbox_1.Visible = false
  form.school_sub_index = SCHOOL_TYPE_FIRST
  form.lbl_12.Left = btn.Left + 43
  local move_form = nx_value(FORM_ORIGIN_LINE)
  if not nx_is_valid(move_form) then
    return
  end
  move_form.Left = -27
  show_sub_desc_form(form, false)
end
function on_btn_second_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  local move_form = nx_value(FORM_ORIGIN_LINE)
  move_form.Left = -(0.3333333333333333 * move_form.Width) - 27
  form.groupbox_1.Visible = false
  form.school_sub_index = SCHOOL_TYPE_SECOND
  form.lbl_12.Left = btn.Left + 43
  show_sub_desc_form(form, false)
end
function on_btn_third_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  local move_form = nx_value(FORM_ORIGIN_LINE)
  move_form.Left = -(0.6666666666666666 * move_form.Width) - 27
  form.groupbox_1.Visible = false
  form.school_sub_index = SCHOOL_TYPE_THIRD
  form.lbl_12.Left = btn.Left + 43
  show_sub_desc_form(form, false)
end
function on_rbtn_school_sub_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  local move_form = nx_value(FORM_ORIGIN_SCHOOL_SUB_LINE)
  if not nx_is_valid(form) or not nx_is_valid(move_form) then
    return
  end
  form.groupbox_1.Visible = false
  form.school_sub_index = SCHOOL_TYPE_SUB_LINE
  form.lbl_12.Left = rbtn.Left + 43
  show_sub_desc_form(form, false)
end
function on_btn_jj_click(btn)
  if not btn.Checked then
    return
  end
  local form = btn.ParentForm
  form.groupbox_1.Top = form.groupbox_desc.Top + 5
  form.groupbox_1.Left = form.groupbox_desc.Left + 5
  form.groupbox_1.Visible = true
  form.school_sub_index = SCHOOL_TYPE_STAGE
  form.lbl_12.Left = btn.Left + 43
  show_sub_desc_form(form, false)
end
function on_btn_help_checked_changed(self)
  local form = self.ParentForm
  if not nx_find_custom(form, "attached_form") then
    return
  end
  if not nx_is_valid(form.attached_form) then
    return
  end
  form.attached_form.Visible = not form.attached_form.Visible
end
function load_line_form(form, group)
  local form_line = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_LINE, true, false)
  group:Add(form_line)
  form_line.Top = 130
  form_line.Left = 60
  form_line.Visible = false
end
function load_school_sub_line_form(form, group)
  local form_line = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_SCHOOL_SUB_LINE, true, false)
  if not nx_is_valid(form_line) then
    return
  end
  group:Add(form_line)
  group.Visible = false
  form_line.Top = 130
  form_line.Left = 60
end
function load_force_form(form, group)
  local form_force = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_FORCE, true, false)
  if not nx_is_valid(form_force) then
    return
  end
  group:Add(form_force)
  group.Visible = false
  form_force.Top = 0
  form_force.Left = 5
  nx_set_custom(form, "form_force", form_force)
end
function load_jianghu_chengjiu_form(form, group)
  group.Top = 0
  group.Left = 5
  group.Visible = false
  local form_chengjiu
  form_chengjiu = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_CHENGJIU, true, false)
  group:Add(form_chengjiu)
  nx_set_custom(form, "form_chengjiu", form_chengjiu)
end
function load_life_form(form, group)
  group.Top = -8
  group.Left = -22
  group.Visible = false
  local form_life = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_LIFE, true, false)
  form_life.Visible = false
  group:Add(form_life)
  form.form_life = form_life
  form_life.Top = 10
  form_life.Left = 30
end
function load_guild_form(form, group)
  group.Visible = false
  local form_guild = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_GUILD, true, false)
  if not nx_is_valid(form_guild) then
    return
  end
  form_guild.Visible = true
  group:Add(form_guild)
  form.form_guild = form_guild
  form_guild.Top = 10
  form_guild.Left = 30
end
function load_line_new_form(form, group)
  local form_line_new = nx_execute("util_gui", "util_get_form", FORM_ORIGIN_LINE_NEW, true, false)
  if not nx_is_valid(form_line_new) then
    return
  end
  group:Add(form_line_new)
  group.Visible = false
  form_line_new.Top = 0
  form_line_new.Left = 5
  nx_set_custom(form, "form_line_new", form_line_new)
end
function form_rp_arm_showrole(form)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if not nx_is_valid(form.role_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", form.role_box)
  end
  local client_player = game_client:GetPlayer()
  local actor2 = form.actor2
  if nx_is_valid(actor2) then
    form.role_box.Scene:Delete(actor2)
  end
  local sex = client_player:QueryProp("Sex")
  local body_type = client_player:QueryProp("BodyType")
  local role_composite = nx_value("role_composite")
  if not nx_is_valid(role_composite) then
    return
  end
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV or body_type == ORIGIN_EM_BODY_MAN_JUV or body_type == ORIGIN_EM_BODY_WOMAN_MAJ or body_type == ORIGIN_EM_BODY_MAN_MAJ then
    actor2 = create_role_composite(form.role_box.Scene, false, sex, "stand", body_type)
    local showequip_type = 0
    if client_player:FindProp("ShowEquipType") then
      showequip_type = client_player:QueryProp("ShowEquipType")
    end
    role_composite:RefreshBodyNorEquip(client_player, actor2, showequip_type)
  else
    actor2 = role_composite:CreateSceneObjectWithSubModel(form.role_box.Scene, client_player, false, false, false)
  end
  if not nx_is_valid(actor2) then
    return
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  form.actor2 = actor2
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", form.role_box, actor2)
  form.cur_actor2 = actor2
end
function data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("Origin_Active", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Completed", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Prized", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("Origin_Record", form, nx_current(), "on_update_origin_rec")
    databinder:AddTableBind("title_rec", form, nx_current(), "update_groupbox_complete_origin")
  end
end
function del_data_bind_prop(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("Origin_Active", form)
    databinder:DelTableBind("Origin_Completed", form)
    databinder:DelTableBind("Origin_Prized", form)
    databinder:DelTableBind("Origin_Record", form)
    databinder:DelTableBind("title_rec", form)
  end
  nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_new_active_origin", 0)
end
function on_update_origin_rec(form, tablename, ttype, line, col)
  if not form.Visible then
    return
  end
  if line < 0 or col < 0 then
    return
  end
  if form.groupbox_desc.Visible then
    nx_execute("form_stage_main\\form_origin\\form_origin_desc", "show_origin_info", form, form.oid)
  else
    refresh_type_origin(form, form.main_type, form.sub_type)
  end
end
function show_main_radiobtn_name(form)
  local gui = nx_value("gui")
  for i = 1, ORIGIN_TYPE_BUTTON_COUNT do
    local rbtn_name = "rbtn_main_" .. nx_string(i)
    local rbtn = nx_custom(form, rbtn_name)
    rbtn.Visible = false
  end
  for i = 1, ORIGIN_TYPE_COUNT do
    local rbtn_name = "rbtn_main_" .. nx_string(i)
    local rbtn = nx_custom(form, rbtn_name)
    rbtn.Text = gui.TextManager:GetText(rbtn_name)
    rbtn.Visible = true
  end
  local checked_rbtn_name = "rbtn_main_" .. nx_string(form.main_type)
  local checked_rbtn = nx_custom(form, checked_rbtn_name)
  checked_rbtn.Checked = true
end
function show_sub_radiobtn_name(form)
  local gui = nx_value("gui")
  for p = 1, MAX_SUB_TYPE_COUNT do
    local rbtn_name = "rbtn_sub_" .. nx_string(p)
    local rbtn = nx_custom(form, rbtn_name)
    rbtn.Text = nx_widestr("")
    rbtn.Visible = false
  end
  local sub_table = type_table[form.main_type]
  local sub_type_count = table.getn(sub_table)
  form.lbl_sub_title.Visible = false
  if 0 < sub_type_count then
    if sub_type_count > MAX_SUB_TYPE_COUNT then
      sub_type_count = MAX_SUB_TYPE_COUNT
    end
    for i = 1, sub_type_count do
      local rbtn_name = "rbtn_sub_" .. nx_string(i)
      local rbtn = nx_custom(form, rbtn_name)
      rbtn.Text = gui.TextManager:GetText(sub_table[i])
      rbtn.Visible = true
      if form.main_type == ORIGIN_TYPE_GUILD and i ~= 1 then
        rbtn.Enabled = false
      else
        rbtn.Enabled = true
      end
    end
    local checked_rbtn_name = "rbtn_sub_" .. nx_string(form.sub_type)
    local checked_rbtn = nx_custom(form, checked_rbtn_name)
    checked_rbtn.Checked = true
    form.lbl_sub_title.Visible = true
  end
end
function refresh_type_origin(form, main_type, sub_type)
  form.sub_type_str = type_table[main_type][sub_type]
  show_sub_desc_form(form, false, true)
end
function show_sub_desc_form(form, open_desc, b_refresh)
  local main_type = form.main_type
  local sub_type_str = form.sub_type_str
  if open_desc then
    form.groupbox_desc.Visible = true
    form.groupbox_complete_origin.Visible = false
    form.groupbox_sub_info.Visible = false
    form.groupbox_1.Visible = false
    form.groupbox_line_total_view.Visible = false
    form.groupbox_total_view.Visible = false
    form.groupbox_menpai_jieduan.Visible = false
    form.groupbox_guild.Visible = false
    form.groupbox_new_school.Visible = false
  else
    local gui = nx_value("gui")
    local rbtn_name = "rbtn_main_" .. nx_string(main_type)
    form.groupbox_desc.Visible = false
    form.groupbox_sub_info.Visible = true
    local form_menpai = nx_value(FORM_ORIGIN_LINE)
    local menpai_vis = false
    local menpai_sub_vis = false
    local jianghu1_vis = false
    local jianghu2_vis = false
    local shenghuo_vis = false
    local force_vis = false
    local new_menpai_vis = false
    local zonglan_vis = false
    local complete_origin_vis = true
    local scrollbar_vis = true
    local btn_menpai_zonglan_vis = false
    local guild_vis = false
    local nSchoolSubIndex = SCHOOL_TYPE_FIRST
    if main_type == ORIGIN_TYPE_MENPAI then
      menpai_vis = true
      form.ScrollBar2.Visible = false
      btn_menpai_zonglan_vis = true
      nSchoolSubIndex = form.school_sub_index
      form.rbtn_school_sub.Visible = false
      form.lbl_22.Visible = false
      if sub_type_str == "school_shaolin" then
        form.rbtn_school_sub.Visible = true
        form.lbl_22.Visible = true
      end
    elseif main_type == ORIGIN_TYPE_JIANGHU then
      form.Width = form.lbl_11.Width + 5
      form.ScrollBar2.Visible = false
      if sub_type_str == "jianghu_experience" then
        jianghu1_vis = true
        scrollbar_vis = false
      elseif sub_type_str == "jianghu_shashou" or sub_type_str == "jianghu_sidi" or sub_type_str == "jianghu_zhiji" or sub_type_str == "jianghu_card" or sub_type_str == "jianghu_jianghu" then
        scrollbar_vis = false
        jianghu2_vis = true
        form.ScrollBar2.Visible = true
      elseif sub_type_str == "jianghu_lianhuan" or sub_type_str == "jianghu_kuihua" or sub_type_str == "jianghu_xixing" or sub_type_str == "jianghu_zhaoshi" or sub_type_str == "jianghu_wuxue" then
        jianghu2_vis = true
      elseif sub_type_str == "jianghu_diwei" or sub_type_str == "jianghu_anneal" then
        jianghu2_vis = true
      elseif sub_type_str == "jianghu_marry" or sub_type_str == "marry_man_1" or sub_type_str == "marry_man_2" or sub_type_str == "marry_man_3" or sub_type_str == "marry_man_4" or sub_type_str == "marry_woman_1" or sub_type_str == "marry_woman_2" or sub_type_str == "marry_woman_3" or sub_type_str == "marry_woman_4" then
        jianghu2_vis = true
      elseif sub_type_str == "jianghu_lover" or sub_type_str == "lover_man_1" or sub_type_str == "lover_man_2" or sub_type_str == "lover_man_3" or sub_type_str == "lover_woman_1" or sub_type_str == "lover_woman_2" or sub_type_str == "lover_woman_3" then
        jianghu2_vis = true
      elseif sub_type_str == "ui_viptime" or sub_type_str == "jianghu_vip_1" or sub_type_str == "jianghu_vip_2" or sub_type_str == "jianghu_vip_3" then
        jianghu2_vis = true
      elseif sub_type_str == "jianghu_body" or sub_type_str == "jianghu_body_1" or sub_type_str == "jianghu_body_2" or sub_type_str == "jianghu_body_3" or sub_type_str == "jianghu_body_4" or sub_type_str == "jianghu_body_0_1" or sub_type_str == "jianghu_body_0_2" or sub_type_str == "jianghu_body_0_3" or sub_type_str == "jianghu_body_0_4" then
        jianghu2_vis = true
      end
    elseif main_type == ORIGIN_TYPE_LIFE then
      form.Width = form.lbl_11.Width + 5
      scrollbar_vis = false
      form.ScrollBar2.Visible = true
      shenghuo_vis = true
      show_sub_life_lines(form, sub_type_str)
    elseif main_type == ORIGIN_TYPE_GUILD then
      guild_vis = true
    elseif main_type == ORIGIN_TYPE_FORCE then
      form.Width = form.lbl_11.Width + 5
      scrollbar_vis = false
      form.ScrollBar2.Visible = true
      force_vis = true
      show_sub_force_lines(form, sub_type_str)
    elseif main_type == ORIGIN_TYPE_NEW_SCHOOL then
      form.Width = form.lbl_11.Width + 5
      scrollbar_vis = false
      form.ScrollBar2.Visible = true
      new_menpai_vis = true
      show_sub_new_school_lines(form, sub_type_str)
    elseif main_type == ORIGIN_TYPE_TOTAL then
      zonglan_vis = true
      complete_origin_vis = false
    else
      scrollbar_vis = false
    end
    form_menpai.Visible = false
    form.groupbox_1.Visible = false
    form.groupbox_school_sub.Visible = false
    form.groupbox_menpai_jieduan.Visible = false
    if menpai_vis then
      form.groupbox_menpai_jieduan.Visible = true
      if nSchoolSubIndex == SCHOOL_TYPE_FIRST or nSchoolSubIndex == SCHOOL_TYPE_SECOND or nSchoolSubIndex == SCHOOL_TYPE_THIRD then
        form_menpai.Visible = true
      elseif nSchoolSubIndex == SCHOOL_TYPE_SUB_LINE then
        form.groupbox_school_sub.Visible = true
      elseif nSchoolSubIndex == SCHOOL_TYPE_STAGE then
        form.groupbox_1.Visible = true
        form.groupbox_sub_info.Visible = false
      end
    end
    form.groupbox_jianghu1.Visible = jianghu1_vis
    form.groupbox_chengjiu.Visible = jianghu2_vis
    form.groupbox_life.Visible = shenghuo_vis
    form.groupbox_total_view.Visible = zonglan_vis
    form.groupbox_complete_origin.Visible = complete_origin_vis
    form.groupbox_guild.Visible = guild_vis
    form.groupbox_force.Visible = force_vis
    form.groupbox_new_school.Visible = new_menpai_vis
    local ScrollBar = form.ScrollBar1
    ScrollBar.Value = ScrollBar.Minimum
    ScrollBar.Visible = false
    form.ScrollBar2.Visible = false
  end
  if b_refresh then
    nx_execute(FORM_ORIGIN_LINE, "refresh_origin", main_type, sub_type_str)
  end
end
function show_sub_life_lines(form, sub_type_str)
  local gui = nx_value("gui")
  local form_life = nx_custom(form, "form_life")
  form_life.Visible = true
  form_life.btn_line_1.Visible = false
  form_life.btn_line_2.Visible = false
  form_life.btn_line_3.Visible = false
  form_life.btn_line_4.Visible = false
  form_life.btn_line_5.Visible = false
  form_life.btn_line_6.Visible = false
  if form_life.btn_line_1.Checked then
    form_life.groupbox_lines_index.Left = 0
    form_life.lbl_2.Left = form_life.btn_line_1.Left + 30
  end
  form_life.btn_pre.Enabled = false
  form_life.btn_next.Enabled = true
  if sub_type_str == "shh_caiji" then
    if form_life.page_count ~= 5 then
      form_life.page_count = 5
      form_life.btn_pre.Visible = true
      form_life.btn_next.Visible = true
    end
  elseif sub_type_str == "shh_zhizao" then
    if form_life.page_count ~= 6 then
      form_life.page_count = 6
      form_life.btn_pre.Visible = true
      form_life.btn_next.Visible = true
    end
  elseif sub_type_str == "shh_wenhua" then
    if form_life.page_count ~= 4 then
      form_life.page_count = 4
      form_life.btn_pre.Visible = false
      form_life.btn_next.Visible = false
    end
  elseif sub_type_str == "shh_shijing" and form_life.page_count ~= 2 then
    form_life.page_count = 2
    form_life.btn_pre.Visible = false
    form_life.btn_next.Visible = false
  end
  shenghuo_sort(sub_type_str, form_life.page_count)
  for i = 1, form_life.page_count do
    local control_name = "btn_line_" .. nx_string(i)
    local control = nx_custom(form_life, control_name)
    local lbl_name = "btn_line_" .. nx_string(i) .. "_text"
    local lbl = nx_custom(form_life, lbl_name)
    if nx_is_valid(control) and nx_is_valid(lbl) then
      if job_table[i] == nil then
        control.line = i
        control.NormalImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][i] .. "_out.png"
        control.FocusImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][i] .. "_on.png"
        control.CheckedImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][i] .. "_down.png"
        lbl.Text = nx_widestr(gui.TextManager:GetText(nx_string(shenghuo_table[sub_type_str][i])))
      else
        control.line = job_table[i]
        control.NormalImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][job_table[i]] .. "_out.png"
        control.FocusImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][job_table[i]] .. "_on.png"
        control.CheckedImage = "gui\\special\\origin\\button\\" .. shenghuo_table[sub_type_str][job_table[i]] .. "_down.png"
        lbl.Text = nx_widestr(gui.TextManager:GetText(nx_string(shenghuo_table[sub_type_str][job_table[i]])))
      end
      control.Visible = true
      form_life.groupbox_lines_index.Width = control.Left + control.Width
    end
  end
end
function shenghuo_sort(sub_type_str, count)
  job_table = {}
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return
  end
  if not player:FindRecord("job_rec") then
    return
  end
  local job_count = player:GetRecordRows("job_rec")
  if job_count == 0 then
    return
  end
  for i = 1, count do
    local studied = false
    for j = 0, job_count - 1 do
      local job_name = player:QueryRecord("job_rec", j, 0)
      if job_name == shenghuo_table[sub_type_str][i] then
        table.insert(job_table, 1, i)
        studied = true
        break
      end
    end
    if not studied then
      table.insert(job_table, i)
    end
  end
end
function show_sub_force_lines(form, force)
  local gui = nx_value("gui")
  local form_force = nx_custom(form, "form_force")
  if not nx_is_valid(form_force) then
    return
  end
  form_force.Visible = true
  form_force.btn_pre.Enabled = false
  form_force.btn_next.Enabled = false
  local third_index_table = {}
  if force == "school_wulin" then
    if form_force.page_count ~= table.getn(wulin_table) then
      form_force.page_count = table.getn(wulin_table)
      form_force.btn_pre.Visible = false
      form_force.btn_next.Visible = false
    end
    third_index_table = wulin_table
  else
    return
  end
  for i = 1, 5 do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_force, rbtn_name)
    local lbl_name = "btn_line_" .. nx_string(i) .. "_text"
    local lbl = nx_custom(form_force, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      rbtn.Visible = false
      lbl.Visible = false
    end
  end
  form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(force) .. ".png"
  local rbtn_count = table.getn(third_index_table)
  if rbtn_count < 5 then
    form_force.btn_pre.Visible = false
    form_force.btn_next.Visible = false
  end
  for i = 1, rbtn_count do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_force, rbtn_name)
    local lbl_name = nx_string(rbtn_name) .. "_text"
    local lbl = nx_custom(form_force, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      lbl.Text = nx_widestr(gui.TextManager:GetText(third_index_table[i]))
      rbtn.sub_type = third_index_table[i]
      rbtn.NormalImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_out.png"
      rbtn.FocusImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_on.png"
      rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_down.png"
      rbtn.Visible = true
      lbl.Visible = true
    end
  end
end
function need_confirm(origin_id)
  if nx_int(origin_id) > nx_int(0) and nx_int(origin_id) < nx_int(800) then
    local origin_manager = nx_value("OriginManager")
    local level = origin_manager:GetOriginLevel(origin_id)
    local line = origin_manager:GetOriginLine(origin_id)
    if 0 < line and level == 3 then
      return true
    end
  end
  return false
end
function on_command_update_origin(cmd_id, para)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local condition_manager = nx_value("ConditionManager")
  if not nx_is_valid(condition_manager) then
    return false
  end
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if not nx_is_valid(player) then
    return false
  end
  if cmd_id == 0 and nx_execute(FORM_ORIGIN_DESC, "can_get_origin", player, condition_manager, origin_manager, para) then
    requie_show_notify(player, origin_manager, para)
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local active_table = origin_manager:GetRefreshActiveOriginList(cmd_id)
  local count = table.getn(active_table)
  for i = 1, count do
    local origin_id = active_table[i]
    if nx_int(origin_id) > nx_int(0) and nx_int(origin_id) < nx_int(MAX_ORIGIN_COUNT) then
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      if not b_active then
        local res = nx_execute(FORM_ORIGIN_DESC, "can_active_origin", player, condition_manager, origin_manager, origin_id)
        if res then
          nx_execute("form_stage_main\\form_main\\form_main_shortcut", "set_new_active_origin", origin_id)
          local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", 28, "", -1)
          nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, origin_id)
          game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVE_ORIGIN), nx_int(origin_id))
        end
      end
    end
  end
  local complete_table = origin_manager:GetRefreshCompleteOriginList(cmd_id)
  count = table.getn(complete_table)
  for i = 1, count do
    local origin_id = complete_table[i]
    if 0 < origin_id and origin_id < MAX_ORIGIN_COUNT then
      local b_active = origin_manager:IsActiveOrigin(origin_id)
      local b_complte = origin_manager:IsCompletedOrigin(origin_id)
      if not b_complte and b_active then
        local res = nx_execute(FORM_ORIGIN_DESC, "can_get_origin", player, condition_manager, origin_manager, origin_id)
        if res then
          requie_show_notify(player, origin_manager, origin_id)
        end
      end
    end
  end
end
function get_origin_id(job_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\Life\\lifejob_origin.ini")
  if nx_is_valid(ini) and ini:FindSection("origin_id") then
    return ini:ReadString("origin_id", job_id, "")
  end
  return ""
end
function show_origin_form(job_id)
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
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local origin_id_list = util_split_string(get_origin_id(job_id), ";")
  local count = table.getn(origin_id_list)
  for i = 1, count do
    local origin_id = nx_int(origin_id_list[i])
    if nx_int(origin_id) > nx_int(0) and nx_int(origin_id) < nx_int(MAX_ORIGIN_COUNT) then
      local res = nx_execute(FORM_ORIGIN_DESC, "can_get_origin", player, condition_manager, origin_manager, origin_id)
      if res then
        local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", 28, "", -1)
        nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, origin_id)
        game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_ACTIVE_ORIGIN), nx_int(origin_id))
        return true
      end
    end
  end
  return false
end
function requie_show_notify(player, origin_manager, origin_id)
  if origin_manager:IsNotifyOrigin(origin_id) then
    return false
  end
  local index = nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_item", 28, "", -1)
  nx_execute("form_stage_main\\form_main\\form_main_request", "add_request_para", index, origin_id)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_REQUIRE_NOTIFY_ORIGIN), origin_id)
end
function open_origin_form_by_id(origin_id)
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return false
  end
  local form = util_get_form("form_stage_main\\form_origin\\form_origin", true, false)
  util_show_form("form_stage_main\\form_origin\\form_origin", true)
  local type_origin = origin_manager:GetOriginAllType(origin_id)
  local size = table.getn(type_origin)
  if size < 2 then
    return false
  end
  local main_type = type_origin[1]
  local sub_type = type_origin[2]
  local game_client = nx_value("game_client")
  local player = game_client:GetPlayer()
  if nx_is_valid(player) then
    form.cur_sex = player:QueryProp("Sex")
  end
  local refresh_self = false
  if main_type == ORIGIN_TYPE_JIANGHU then
    local found_flag = 0
    for i = 1, table.getn(jianghu_chengjiu_table) do
      if sub_type == jianghu_chengjiu_table[i] then
        sub_type = type_table[main_type][2]
        form.cbtn_index = i
        found_flag = 1
        break
      end
    end
    if nx_int(found_flag) == nx_int(0) then
      for j = 1, table.getn(wuxue_table) do
        if sub_type == wuxue_table[j] then
          form.sub_type_str = sub_type
          sub_type = type_table[main_type][3]
          form.cbtn_index = j
          found_flag = 1
          refresh_self = true
          break
        end
      end
    end
    if nx_int(found_flag) == nx_int(0) then
      local temp_table = marry_man_table
      if form.cur_sex == 1 then
        temp_table = marry_woman_table
      end
      for k = 1, table.getn(temp_table) do
        if sub_type == temp_table[k] then
          form.sub_type_str = sub_type
          sub_type = type_table[main_type][4]
          form.cbtn_index = k
          found_flag = 1
          refresh_self = true
          break
        end
      end
    end
    if nx_int(found_flag) == nx_int(0) then
      local temp_table = lover_man_table
      if form.cur_sex == 1 then
        temp_table = lover_woman_table
      end
      for k = 1, table.getn(temp_table) do
        if sub_type == temp_table[k] then
          form.sub_type_str = sub_type
          sub_type = type_table[main_type][5]
          form.cbtn_index = k
          found_flag = 1
          refresh_self = true
          break
        end
      end
    end
    if nx_int(found_flag) == nx_int(0) then
      for n = 1, table.getn(jianghu_vip_table) do
        if sub_type == jianghu_vip_table[n] then
          form.sub_type_str = sub_type
          sub_type = type_table[main_type][6]
          form.cbtn_index = n
          found_flag = 1
          refresh_self = true
          break
        end
      end
    end
    if nx_int(found_flag) == nx_int(0) then
      local temp_table = jianghu_body_table
      if form.cur_sex == 1 then
        temp_table = jianghu_body_woman_table
      end
      for n = 1, table.getn(temp_table) do
        if sub_type == temp_table[n] then
          form.sub_type_str = sub_type
          sub_type = type_table[main_type][7]
          form.cbtn_index = n
          found_flag = 1
          refresh_self = true
          break
        end
      end
    end
  elseif main_type == ORIGIN_TYPE_MENPAI then
    local origin_level = origin_manager:GetOriginLevel(origin_id)
    local origin_line = origin_manager:GetOriginLine(origin_id)
    if origin_line == 0 then
      form.cbtn_index = 4
    else
      form.cbtn_index = math.ceil(origin_level / 5)
    end
    if sub_type == "school_tianshan_0_1" or sub_type == "school_tianshan_1" or sub_type == "school_tianshan_4" then
      sub_type = "school_tianshan"
    end
  elseif main_type == ORIGIN_TYPE_LIFE then
    form.cbtn_index = origin_manager:GetOriginLine(origin_id)
  elseif main_type == ORIGIN_TYPE_GUILD then
    line = origin_manager:GetOriginLine(origin_id)
    nx_execute(FORM_ORIGIN_GUILD, "on_select_line", line)
  elseif main_type == ORIGIN_TYPE_FORCE then
    form.cbtn_index = origin_manager:GetOriginLine(origin_id)
    form.sub_type_str = nx_string(sub_type)
    sub_type = string.sub(sub_type, 1, string.len(sub_type) - 2)
  elseif main_type == ORIGIN_TYPE_NEW_SCHOOL then
    local material = origin_manager:GetOriginMaterial(origin_id)
    local origin_line = origin_manager:GetOriginLine(origin_id)
    form.sub_type_str = nx_string(sub_type)
    if origin_line == 0 then
      form.cbtn_index = 4
    elseif material == 1 or material == 2 then
      form.cbtn_index = 1
    elseif material == 3 then
      form.cbtn_index = 2
    elseif material == 4 then
      form.cbtn_index = 3
    end
    if sub_type == "school_gumu_0_1" or sub_type == "school_gumu_0_2" or sub_type == "school_gumu_0_3" then
      sub_type = "school_gumu"
    elseif sub_type == "school_nianluoba_0_1" or sub_type == "school_nianluoba_0_2" or sub_type == "school_nianluoba_0_3" then
      sub_type = "school_nianluoba"
    elseif sub_type == "school_wuxianjiao_0_1" or sub_type == "school_wuxianjiao_0_2" or sub_type == "school_wuxianjiao_0_3" then
      sub_type = "school_wuxianjiao"
    else
      sub_type = string.sub(sub_type, 1, string.len(sub_type) - 2)
    end
  end
  form.main_type = main_type
  if 0 >= form.main_type then
    return false
  end
  local name = "rbtn_main_" .. nx_string(form.main_type)
  local btn = nx_custom(form, name)
  if nx_is_valid(btn) then
    btn.Checked = true
  end
  if main_type == ORIGIN_TYPE_NEW_SCHOOL then
    local material = origin_manager:GetOriginMaterial(origin_id)
    local origin_line = origin_manager:GetOriginLine(origin_id)
    form.sub_type_str = nx_string(sub_type)
    if origin_line == 0 then
      form.cbtn_index = 4
    elseif material == 1 or material == 2 then
      form.cbtn_index = 1
    elseif material == 3 then
      form.cbtn_index = 2
    elseif material == 4 then
      form.cbtn_index = 3
    end
  end
  local sub_id_table = type_table[main_type]
  local id_table_size = table.getn(sub_id_table)
  local sub_id = 0
  for m = 1, id_table_size do
    if sub_type == sub_id_table[m] then
      sub_id = m
    end
  end
  local sub_name = "rbtn_sub_" .. nx_string(sub_id)
  local sub_btn = nx_custom(form, sub_name)
  if nx_is_valid(sub_btn) then
    sub_btn.Checked = true
  end
  form.sub_type = sub_id
  form.oid = origin_id
  if not refresh_self then
    refresh_type_origin(form, form.main_type, form.sub_type)
  else
    show_sub_desc_form(form, false, true)
  end
end
function on_btn_total_view_click(btn)
  local form = btn.ParentForm
  form.groupbox_complete_origin.Visible = false
  form.groupbox_line_total_view.Visible = true
  form.groupbox_sub_info.Visible = false
  form.groupbox_menpai_jieduan.Visible = false
  btn.isvisible = true
  form.lbl_sub_title.Visible = false
  form.lbl_12.Left = btn.Left + 43
end
function on_btn_left_click(btn)
  local form = btn.ParentForm
  local page_no = form.groupbox_complete_origin.pageno
  if 1 < page_no then
    form.groupbox_complete_origin.pageno = page_no - 1
    update_show_page(form, form.groupbox_complete_origin.pageno)
  end
end
function on_btn_right_click(btn)
  local form = btn.ParentForm
  local page_no = form.groupbox_complete_origin.pageno
  local title_count = table.getn(show_table)
  if title_count > page_no * 5 then
    form.groupbox_complete_origin.pageno = page_no + 1
    update_show_page(form, form.groupbox_complete_origin.pageno)
  end
end
function load_total_view_form(form, group)
  group.Top = 68
  group.Left = -2
  group.Visible = false
  local form_total_view = nx_execute("util_gui", "util_get_form", FORM_TOTAL_VIEW, true, false)
  group:Add(form_total_view)
  form.form_total_view = form_total_view
  form.form_total_view.Top = 0
  form.form_total_view.Left = 5
end
function load_line_total_view_form(form, group)
  group.Top = 0
  group.Left = 0
  local form_line_total_view = nx_execute("util_gui", "util_get_form", FORM_LINE_TOTAL_VIEW, true, false)
  group:Add(form_line_total_view)
  form.form_line_total_view = form_line_total_view
  form.form_line_total_view.Top = 0
  form.form_line_total_view.Left = 5
end
function update_groupbox_complete_origin(form)
  if not form.Visible then
    return
  end
  local origin_manager = nx_value("OriginManager")
  if not nx_is_valid(origin_manager) then
    return
  end
  local main_type = form.main_type
  local from, to = 0, 0
  if main_type == 1 then
    from, to = 1, 800
  elseif main_type == 2 then
    from, to = 801, 1000
  elseif main_type == 3 then
    from, to = 1001, 2000
  else
    return
  end
  title_list = {}
  sort_title()
  local title_count = table.getn(title_list)
  show_table = {}
  for i = 1, title_count do
    local title_id = title_list[i]
    local title_Line = origin_manager:GetOriginLine(title_id)
    if title_Line == 0 and main_type == 1 then
      show_table[1] = title_id
    end
  end
  for i = 1, title_count do
    local title_id = title_list[i]
    local title_Line = origin_manager:GetOriginLine(title_id)
    if nx_int(title_id) >= nx_int(from) and nx_int(title_id) <= nx_int(to) and title_Line ~= 0 then
      local size = table.getn(show_table) + 1
      show_table[size] = title_id
    end
  end
  update_show_page(form, 1)
end
function update_show_page(form, page_no)
  local from = (page_no - 1) * 5 + 1
  local to = page_no * 5
  local max_size = table.getn(show_table)
  if 5 < max_size then
    form.btn_left.Visible = true
    form.btn_right.Visible = true
    if page_no == 1 then
      form.btn_left.Enabled = false
    else
      form.btn_left.Enabled = true
    end
  else
    form.btn_left.Visible = false
    form.btn_right.Visible = false
  end
  if to >= max_size then
    to = max_size
    form.btn_right.Enabled = false
  else
    form.btn_right.Enabled = true
  end
  local show_count = 1
  for i = from, to do
    if show_table[i] > 0 then
      local btn_name = "btn_view_" .. nx_string(show_count)
      local btn_view = nx_custom(form, btn_name)
      if nx_is_valid(btn_view) then
        local title_id = show_table[i]
        btn_view.o_id = title_id
        btn_view.Visible = true
        nx_execute(FORM_ORIGIN_LINE, "set_Image", btn_view, title_id, "completed")
        show_count = show_count + 1
      end
    end
  end
end
function init_groupbox_complete_origin(form)
  form.btn_view_1.Visible = false
  form.btn_view_2.Visible = false
  form.btn_view_3.Visible = false
  form.btn_view_4.Visible = false
  form.btn_view_5.Visible = false
  form.btn_view_6.Visible = false
end
function sort_title()
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
    return
  end
  for i = 5, 1, -1 do
    for j = title_count - 1, 0, -1 do
      local title_id = player:QueryRecord("title_rec", j, 0)
      if title_id < MAX_ORIGIN_COUNT then
        local origin_manager = nx_value("OriginManager")
        if not nx_is_valid(origin_manager) then
          return false
        end
        local material = origin_manager:GetOriginMaterial(title_id)
        if material == i then
          local size = table.getn(title_list) + 1
          title_list[size] = title_id
        end
      end
    end
  end
end
function show_sub_new_school_lines(form, sub_type_str)
  local gui = nx_value("gui")
  local form_line_new = nx_custom(form, "form_line_new")
  if not nx_is_valid(form_line_new) then
    return
  end
  form_line_new.Visible = true
  form_line_new.btn_pre.Enabled = false
  form_line_new.btn_next.Enabled = false
  local third_index_table = {}
  if sub_type_str == "school_gumu" then
    third_index_table = gumu_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = gumu_woman_table
    end
    form_line_new.btn_jj.sub_type = "school_gumu_4"
  elseif sub_type_str == "school_xuedaomen" then
    third_index_table = xuedaomen_table
    form_line_new.btn_jj.sub_type = "school_xuedaomen_4"
  elseif sub_type_str == "school_nianluoba" then
    third_index_table = nianluoba_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = nianluoba_woman_table
    end
    form_line_new.btn_jj.sub_type = "school_nianluoba_4"
  elseif sub_type_str == "school_changfeng" then
    third_index_table = changfeng_table
    form_line_new.btn_jj.sub_type = "school_changfeng_4"
  elseif sub_type_str == "school_shenshui" then
    third_index_table = shenshui_table
    form_line_new.btn_jj.sub_type = "school_shenshui_4"
  elseif sub_type_str == "school_huashan" then
    third_index_table = huashan_table
    form_line_new.btn_jj.sub_type = "school_huashan_4"
  elseif sub_type_str == "school_wuxianjiao" then
    third_index_table = wuxianjiao_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = wuxianjiao_woman_table
    end
    form_line_new.btn_jj.sub_type = "school_wuxianjiao_4"
  elseif sub_type_str == "school_damo" then
    third_index_table = damo_table
    form_line_new.btn_jj.sub_type = "school_damo_4"
  elseif sub_type_str == "school_shenjiying" then
    third_index_table = shenjiying_table
    form_line_new.btn_jj.sub_type = "school_shenjiying_4"
  elseif sub_type_str == "school_xingmiao" then
    third_index_table = xingmiao_table
    form_line_new.btn_jj.sub_type = "school_xingmiao_4"
  else
    return
  end
  form_line_new.page_count = table.getn(third_index_table)
  form_line_new.btn_pre.Visible = false
  form_line_new.btn_next.Visible = false
  for i = 1, 5 do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_line_new, rbtn_name)
    local lbl_name = "btn_line_" .. nx_string(i) .. "_text"
    local lbl = nx_custom(form_line_new, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      rbtn.Visible = false
      lbl.Visible = false
    end
  end
  form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(sub_type_str) .. ".png"
  local rbtn_count = table.getn(third_index_table)
  if rbtn_count < 5 then
    form_line_new.btn_pre.Visible = false
    form_line_new.btn_next.Visible = false
  end
  for i = 1, rbtn_count do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_line_new, rbtn_name)
    local lbl_name = nx_string(rbtn_name) .. "_text"
    local lbl = nx_custom(form_line_new, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      lbl.Text = nx_widestr(gui.TextManager:GetText(third_index_table[i]))
      rbtn.sub_type = third_index_table[i]
      rbtn.NormalImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_out.png"
      rbtn.FocusImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_on.png"
      rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_down.png"
      rbtn.Visible = true
      lbl.Visible = true
    end
  end
end
function show_new_school(form, sub_type)
  local form_line_new = nx_custom(form, "form_line_new")
  if not nx_is_valid(form_line_new) then
    return
  end
  form_line_new.Visible = true
  for i = 1, 5 do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_line_new, rbtn_name)
    local lbl_name = "btn_line_" .. nx_string(i) .. "_text"
    local lbl = nx_custom(form_line_new, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      rbtn.Visible = false
      lbl.Visible = false
    end
  end
  if sub_type > table.getn(type_table[6]) then
    return
  end
  local new_school = type_table[6][sub_type]
  local third_index_table = {}
  if new_school == "school_gumu" then
    third_index_table = gumu_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = gumu_woman_table
    end
  elseif new_school == "school_xuedaomen" then
    third_index_table = xuedaomen_table
  elseif new_school == "school_changfeng" then
    third_index_table = changfeng_table
  elseif new_school == "school_nianluoba" then
    third_index_table = nianluoba_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = nianluoba_woman_table
    end
  elseif new_school == "school_shenshui" then
    third_index_table = shenshui_table
  elseif new_school == "school_huashan" then
    third_index_table = huashan_table
  elseif new_school == "school_wuxianjiao" then
    third_index_table = wuxianjiao_table
    if nx_int(form.cur_sex) == nx_int(1) then
      third_index_table = wuxianjiao_woman_table
    end
  elseif new_school == "school_damo" then
    third_index_table = damo_table
  elseif new_school == "school_shenjiying" then
    third_index_table = shenjiying_table
  elseif new_school == "school_xingmiao" then
    third_index_table = xingmiao_table
  else
    return
  end
  form.lbl_sub_title.BackImage = "gui\\language\\ChineseS\\origin\\origin\\bg\\" .. nx_string(new_school) .. ".png"
  local rbtn_count = table.getn(third_index_table)
  if rbtn_count < 5 then
    form_line_new.btn_pre.Visible = false
    form_line_new.btn_next.Visible = false
  end
  local gui = nx_value("gui")
  for i = 1, rbtn_count do
    local rbtn_name = "btn_line_" .. nx_string(i)
    local rbtn = nx_custom(form_line_new, rbtn_name)
    local lbl_name = nx_string(rbtn_name) .. "_text"
    local lbl = nx_custom(form_line_new, lbl_name)
    if nx_is_valid(rbtn) and nx_is_valid(lbl) then
      lbl.Text = nx_widestr(gui.TextManager:GetText(third_index_table[i]))
      rbtn.sub_type = third_index_table[i]
      rbtn.NormalImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_out.png"
      rbtn.FocusImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_on.png"
      rbtn.CheckedImage = "gui\\special\\origin\\button\\" .. third_index_table[i] .. "_down.png"
      rbtn.Visible = true
      lbl.Visible = true
    end
  end
  form_line_new.btn_jj.sub_type = type_table[6][sub_type] .. "_4"
  form_line_new.btn_line_1.sub_type = type_table[6][sub_type] .. "_1"
  if (sub_type == 1 or sub_type == 4 or sub_type == 6) and nx_int(form.cur_sex) == nx_int(1) then
    form_line_new.btn_line_1.sub_type = type_table[6][sub_type] .. "_0_1"
  end
  nx_execute(FORM_ORIGIN_LINE, "refresh_new_shcool", nx_string(form_line_new.btn_line_1.sub_type))
end
function form_rp_arm_showrole_body(form, body_type)
  local game_client = nx_value("game_client")
  local world = nx_value("world")
  local main_scene = world.MainScene
  if body_type ~= ORIGIN_EM_BODY_WOMAN_JUV and body_type ~= ORIGIN_EM_BODY_MAN_JUV and body_type ~= ORIGIN_EM_BODY_WOMAN_MAJ and body_type ~= ORIGIN_EM_BODY_MAN_MAJ then
    return
  end
  local control_name = "role_box_body" .. nx_string(body_type)
  local scene_box = form.groupbox_desc:Find(control_name)
  if not nx_is_valid(scene_box) then
    return
  end
  if not nx_is_valid(scene_box.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scene_box)
  end
  local client_player = game_client:GetPlayer()
  local actor2
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV then
    actor2 = form.actor2_body3
  elseif body_type == ORIGIN_EM_BODY_MAN_JUV then
    actor2 = form.actor2_body4
  elseif body_type == ORIGIN_EM_BODY_WOMAN_MAJ then
    actor2 = form.actor2_body5
  elseif body_type == ORIGIN_EM_BODY_MAN_MAJ then
    actor2 = form.actor2_body6
  else
    return
  end
  if nx_is_valid(actor2) then
    scene_box.Scene:Delete(actor2)
  end
  local sex = client_player:QueryProp("Sex")
  local actor2
  if sex == 0 then
    if body_type == ORIGIN_EM_BODY_MAN_JUV then
      actor2 = create_role_composite(scene_box.Scene, true, sex, "stand", ORIGIN_EM_BODY_MAN_JUV)
    elseif body_type == ORIGIN_EM_BODY_MAN_MAJ then
      actor2 = create_role_composite(scene_box.Scene, true, sex, "stand", ORIGIN_EM_BODY_MAN_MAJ)
    else
      return
    end
  elseif body_type == ORIGIN_EM_BODY_WOMAN_JUV then
    actor2 = create_role_composite(scene_box.Scene, true, sex, "stand", ORIGIN_EM_BODY_WOMAN_JUV)
  elseif body_type == ORIGIN_EM_BODY_WOMAN_MAJ then
    actor2 = create_role_composite(scene_box.Scene, true, sex, "stand", ORIGIN_EM_BODY_WOMAN_MAJ)
  else
    return
  end
  if not nx_is_valid(actor2) then
    return
  end
  while not actor2.LoadFinish do
    nx_pause(0.1)
  end
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV then
    form.actor2_body3 = actor2
  elseif body_type == ORIGIN_EM_BODY_MAN_JUV then
    form.actor2_body4 = actor2
  elseif body_type == ORIGIN_EM_BODY_WOMAN_MAJ then
    form.actor2_body5 = actor2
  elseif body_type == ORIGIN_EM_BODY_MAN_MAJ then
    form.actor2_body6 = actor2
  else
    return
  end
  local game_visual = nx_value("game_visual")
  game_visual:SetRoleClientIdent(actor2, client_player.Ident)
  nx_execute("util_gui", "util_add_model_to_scenebox", scene_box, actor2)
end
function ShowSceneBox(form, body_type)
  if not nx_is_valid(form) then
    return
  end
  if body_type == ORIGIN_EM_BODY_WOMAN_JUV then
    form.role_box.Visible = false
    form.role_box_body3.Visible = true
    form.role_box_body4.Visible = false
    form.role_box_body5.Visible = false
    form.role_box_body6.Visible = false
  elseif body_type == ORIGIN_EM_BODY_MAN_JUV then
    form.role_box.Visible = false
    form.role_box_body3.Visible = false
    form.role_box_body4.Visible = true
    form.role_box_body5.Visible = false
    form.role_box_body6.Visible = false
  elseif body_type == ORIGIN_EM_BODY_WOMAN_MAJ then
    form.role_box.Visible = false
    form.role_box_body3.Visible = false
    form.role_box_body4.Visible = false
    form.role_box_body5.Visible = true
    form.role_box_body6.Visible = false
  elseif body_type == ORIGIN_EM_BODY_MAN_MAJ then
    form.role_box.Visible = false
    form.role_box_body3.Visible = false
    form.role_box_body4.Visible = false
    form.role_box_body5.Visible = false
    form.role_box_body6.Visible = true
  else
    form.role_box.Visible = true
    form.role_box_body3.Visible = false
    form.role_box_body4.Visible = false
    form.role_box_body5.Visible = false
    form.role_box_body6.Visible = false
  end
end
function close_form()
  local form = nx_value("form_stage_main\\form_origin\\form_origin")
  if nx_is_valid(form) then
    form:Close()
  end
end
function open_origin_form()
  local form = nx_value(FORM_ORIGIN)
  if nx_is_valid(form) then
    if form.Visible then
      form:Close()
    else
      form.Visible = true
    end
  else
    form = nx_execute("util_gui", "util_auto_show_hide_form", FORM_ORIGIN)
    if nx_is_valid(form) then
      on_rbtn_main_type_click(form.rbtn_main_2)
      form.rbtn_main_2.Checked = true
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        gui.Desktop:ToFront(form)
      end
    end
  end
  local form = nx_value(FORM_ORIGIN)
  nx_execute("util_gui", "ui_show_attached_form", form)
end
