require("custom_sender")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
local MAX_VALUE = 6
local MAX_DRAWING_LEVEL = 75
function main_form_init(self)
  self.Fixed = true
end
function on_main_form_open(self)
  self.redit_1.ReadOnly = true
  self.IsEdit = true
  return 1
end
function on_btn_edit_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local gui = nx_value("gui")
  if true == form.IsEdit then
    form.redit_1.ReadOnly = false
    form.IsEdit = false
    local publish_text = nx_widestr(gui.TextManager:GetText("ui_guild_publish_purpose"))
    btn.Text = publish_text
  elseif false == form.IsEdit then
    local content = form.redit_1.Text
    local check_words = nx_value("CheckWords")
    if nx_is_valid(check_words) and nx_widestr(content) ~= nx_widestr(check_words:CleanWords(nx_widestr(content))) then
      local gui = nx_value("gui")
      local text = nx_widestr(gui.TextManager:GetText("ui_EnterValidIntro"))
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      return 0
    end
    custom_request_set_guild_purpose(content)
    form.redit_1.ReadOnly = true
    form.IsEdit = true
    local edit_text = nx_widestr(gui.TextManager:GetText("ui_guild_edit_purpose"))
    btn.Text = edit_text
  end
end
function on_recv_guild_info(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_intro")
  if not nx_is_valid(form) or table.getn(arg) ~= 14 then
    return
  end
  local form_guild = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild")
  if not nx_is_valid(form_guild) then
    return
  end
  local capital = nx_int64(arg[10])
  local ding = nx_int(capital / 1000000)
  local liang = nx_int((capital - 1000000 * ding) / 1000)
  local wen = nx_int(capital - 1000000 * ding - 1000 * liang)
  form.lbl_guild_capital.HtmlText = nx_widestr(guild_util_get_text("ui_guild_capital1", nx_int(ding), nx_int(liang), nx_int(wen))) .. nx_widestr("<img src=\"gui\\common\\money\\liang.png\" valign=\"center\" only=\"line\" data=\"\" />")
  form.lbl_guild_name.Text = nx_widestr(arg[1])
  form.lbl_guild_level.Text = nx_widestr(arg[2])
  form.lbl_guild_captain.Text = nx_widestr(arg[3])
  form.lbl_guild_founder.Text = nx_widestr(arg[4])
  form.lbl_found_date.Text = nx_widestr(transform_date(arg[5]))
  if nx_int(arg[12]) <= nx_int(0) then
    form.lbl_guild_location.Text = nx_widestr(guild_util_get_text("ui_guild_domain_none"))
  else
    form.lbl_guild_location.Text = nx_widestr(guild_util_get_text("ui_dipanmiaoshu_" .. nx_string(arg[12])))
  end
  if 0 >= nx_ws_length(nx_widestr(arg[7])) then
    form.redit_1.Text = nx_widestr(guild_util_get_text("ui_None"))
    form_guild.mltbox_zongzhi.HtmlText = nx_widestr(guild_util_get_text("ui_None"))
  else
    form.redit_1.Text = nx_widestr(arg[7])
    form_guild.mltbox_zongzhi.HtmlText = nx_widestr(arg[7])
  end
end
function on_main_form_close(self)
end
function on_recv_logo(logo)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_intro")
  if not nx_is_valid(form) then
    return
  end
  local logo_info = util_split_string(logo, "#")
  if table.getn(logo_info) == 3 then
    if logo_info[1] == "" and logo_info[2] == "" and logo_info[3] == "0,255,255,255" then
      form.pic_logo.Image = "gui\\guild\\formback\\bg_logo.png"
    else
      form.pic_frame.Image = "gui\\guild\\frame\\" .. logo_info[1]
      form.pic_logo.Image = "gui\\guild\\logo\\" .. logo_info[2]
      form.groupbox_logo.BackColor = logo_info[3]
    end
  end
end
function on_recv_guild_intro_info(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_intro")
  if not nx_is_valid(form) then
    return
  end
  for i = 1, MAX_VALUE do
    local show_lbl = form.groupbox_1:Find("lbl_info_" .. i)
    if nx_is_valid(show_lbl) then
      if i < 7 then
        if i == 6 then
          local gui = nx_value("gui")
          show_lbl.Text = nx_widestr(arg[i]) .. nx_widestr(gui.TextManager:GetText("ui_guild_piece"))
        else
          show_lbl.Text = nx_widestr(arg[i])
        end
      else
        show_lbl.Text = nx_widestr(nx_int(arg[i] / MAX_DRAWING_LEVEL * 100))
      end
    end
  end
end
