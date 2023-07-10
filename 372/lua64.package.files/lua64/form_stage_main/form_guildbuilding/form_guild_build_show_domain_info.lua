require("util_gui")
function form_init(form)
  form.Fixed = false
  form.row = nil
  form.domainID = 0
  form.fieldNum = nil
end
function on_main_form_open(form)
  local gui = nx_value("gui")
end
function on_main_form_close(form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  self.ParentForm:Close()
end
function on_btn_close_click(btn)
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
end
function on_btn_click(btn)
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain")
  if not nx_is_valid(form) then
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain", true, false)
    nx_set_value("form_stage_main\\form_guildbuilding\\form_guild_build_buy_domain", form)
  end
  local formParent = btn.Parent
  form.row = formParent.row
  form.domainID = formParent.domainID
  form.fieldNum = formParent.fieldNum
  form:Show()
  form.Visible = true
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
end
function show_domain_info(form, ...)
  local gui = nx_value("gui")
  form.lbl_1.Text = nx_widestr(gui.TextManager:GetText("ui_guild_domain"))
  form.lbl_3.Text = nx_widestr(gui.TextManager:GetText("ui_domain_guildname")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_5.Text = nx_widestr(gui.TextManager:GetText("ui_domain_level")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_7.Text = nx_widestr(gui.TextManager:GetText("ui_domain_rolenum")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_9.Text = nx_widestr(gui.TextManager:GetText("ui_domain_bangzhu")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_11.Text = nx_widestr(gui.TextManager:GetText("ui_domain_scale")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_13.Text = nx_widestr(gui.TextManager:GetText("ui_domain_banner")) .. nx_widestr(gui.TextManager:GetText("ui_maohao"))
  form.lbl_2.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_" .. nx_string(arg[1])))
  form.lbl_14.Text = nx_widestr(gui.TextManager:GetText("ui_dipanmiaoshu_" .. nx_string(arg[1])))
  local map_res = "gui\\guild\\"
  local map_name = map_res .. "guildshow\\" .. nx_string(arg[1]) .. ".png"
  form.pic_1.Image = map_name
  if nx_string(arg[3]) == "" then
    form.lbl_4.Text = nx_widestr(gui.TextManager:GetText("ui_showinfo_none"))
    form.lbl_6.Text = nx_widestr(gui.TextManager:GetText("ui_showinfo_none"))
    form.lbl_8.Text = nx_widestr(gui.TextManager:GetText("ui_showinfo_none"))
    form.lbl_10.Text = nx_widestr(gui.TextManager:GetText("ui_showinfo_none"))
    form.lbl_12.Text = nx_widestr(gui.TextManager:GetText("ui_showinfo_none"))
    form.pic_2.Image = ""
    form.pic_3.Image = ""
    form.groupbox_logo.BackColor = "0,0,0,0"
    form.btn_1.Text = nx_widestr(gui.TextManager:GetText("ui_domain_qiangzhandipan"))
  else
    form.lbl_4.Text = nx_widestr(arg[3])
    form.lbl_6.Text = nx_widestr(nx_widestr(arg[6]) .. nx_widestr(gui.TextManager:GetText("ui_ji")))
    form.lbl_8.Text = nx_widestr(nx_widestr(arg[7]) .. nx_widestr(gui.TextManager:GetText("ui_ren")))
    form.lbl_10.Text = nx_widestr(arg[8])
    form.lbl_12.Text = nx_widestr(gui.TextManager:GetText("ui_dipan_scale_" .. nx_string(arg[4])))
    local logo_info = util_split_string(nx_string(arg[9]), "#")
    if table.getn(logo_info) == 3 then
      local logo_frame_pic = logo_info[1]
      local logo_logo_pic = logo_info[2]
      local logo_back_color = logo_info[3]
      map_name = map_res .. "frame\\" .. logo_frame_pic
      form.pic_2.Image = map_name
      map_name = map_res .. "logo\\" .. logo_logo_pic
      form.pic_3.Image = map_name
      form.groupbox_logo.BackColor = logo_back_color
    else
      form.pic_2.Image = ""
      form.pic_3.Image = ""
      form.groupbox_logo.BackColor = "0,0,0,0"
    end
    form.btn_1.Text = nx_widestr(gui.TextManager:GetText("ui_domain_kuodaguimo"))
  end
  if arg[10] == 1 then
    form.btn_1.Visible = false
  else
    form.btn_1.Visible = true
  end
  form.row = arg[5]
  form.domainID = arg[1]
  form.fieldNum = arg[4]
end
function on_btn_show_domain_click(btn)
  form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
  if form.domainID ~= nil then
    local file_name = "share\\Guild\\GuildDomain\\scene_map.ini"
    local ini = get_ini(file_name)
    if not nx_is_valid(ini) then
      nx_msgbox(get_msg_str("msg_418") .. file_name)
      return
    end
    local sec_index = ini:FindSectionIndex(string.sub(nx_string(form.domainID), 1, -3))
    if sec_index < 0 then
      return
    end
    local map_name = ini:ReadString(sec_index, "r", "")
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_domain", "refresh_scene_map", map_name, form.btn_1.Visible)
  end
  util_auto_show_hide_form("form_stage_main\\form_guildbuilding\\form_guild_build_show_domain_info")
end
