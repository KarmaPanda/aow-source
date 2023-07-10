require("util_functions")
require("custom_sender")
require("util_gui")
require("share\\client_custom_define")
local SUB_CUSTOMMSG_GUILD_TRANS_TO_REQHELPER = 100
local SUB_CUSTOMMSG_GUILD_REQ_HELPER_INFO = 101
function main_form_init(form)
  form.Fixed = false
  form.req_name = nx_widestr("")
  form.req_uid = ""
  form.remain_time = 0
end
function on_main_form_open(self)
  self.Fixed = false
  self.req_name = nx_widestr("")
  self.req_uid = nx_widestr("")
  self.lbl_remain_time.Text = nx_widestr("")
end
function on_main_form_close(form)
  local GuildManager = nx_value("GuildManager")
  if nx_is_valid(GuildManager) then
    GuildManager:EndTimerOfHelpItem()
  end
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GuildManager = nx_value("GuildManager")
  if nx_is_valid(GuildManager) then
    GuildManager:EndTimerOfHelpItem()
  end
  form:Close()
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return 0
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_GUILD_TRANS_TO_REQHELPER), form.req_name, form.req_uid, nx_int(1), form.trans_cost, form.trans_cd_time)
end
function on_btn_cancel_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local GuildManager = nx_value("GuildManager")
  if nx_is_valid(GuildManager) then
    GuildManager:EndTimerOfHelpItem()
  end
  form:Close()
end
function recv_help_data(...)
  local form = nx_value("form_stage_main\\form_relation\\form_relation_guild\\form_guild_sos")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.req_name = nx_widestr(arg[1])
  form.req_uid = arg[2]
  form.lbl_name.Text = nx_widestr(form.req_name)
  form.lbl_scene.Text = nx_widestr(util_text(get_scene_id_by_name(arg[3])))
  form.lbl_area.Text = nx_widestr(util_text(arg[4]))
  form.lbl_pos.Text = nx_widestr("(") .. nx_widestr(nx_int(arg[5])) .. nx_widestr(",") .. nx_widestr(nx_int(arg[6])) .. nx_widestr(")")
  form.lbl_number.Text = nx_widestr(arg[7])
  form.lbl_max_number.Text = nx_widestr(arg[8])
  local remain_time = arg[9]
  form.trans_cost = nx_widestr(arg[10])
  form.trans_cd_time = nx_widestr(arg[11])
  local text = nx_widestr(form.trans_cost) .. util_text("ui_wen")
  if nx_int(form.trans_cost) >= nx_int(1000) then
    local liang = nx_int(nx_int(form.trans_cost) / nx_int(1000))
    text = nx_widestr(liang) .. util_text("ui_liang")
    local wen = nx_int(form.trans_cost) - nx_int(liang) * nx_int(1000)
    if nx_int(wen) > nx_int(0) then
      text = text .. nx_widestr(wen) .. util_text("ui_wen")
    end
  end
  form.mltbox_1.HtmlText = nx_widestr(gui.TextManager:GetFormatText("ui_guild_qzl_01", nx_widestr(text)))
  if remain_time <= 0 then
    form.lbl_time.Text = nx_widestr("00:00:00")
  else
    local GuildManager = nx_value("GuildManager")
    if nx_is_valid(GuildManager) then
      GuildManager:RegisterTimerOfHelpItem(remain_time)
    end
  end
end
function get_scene_id_by_name(scene_id)
  local ini = nx_execute("util_functions", "get_ini", "share\\rule\\maplist.ini")
  if not nx_is_valid(ini) then
    return false
  end
  local item_count = ini:GetSectionItemCount(0)
  local index = 0
  local scene_name = ""
  for i = 1, item_count do
    index = index + 1
    local scene_name = nx_string(ini:GetSectionItemValue(0, i - 1))
    if index == scene_id then
      return scene_name
    end
  end
  return ""
end
