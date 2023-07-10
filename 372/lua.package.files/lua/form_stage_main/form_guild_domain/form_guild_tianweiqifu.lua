require("util_gui")
require("share\\client_custom_define")
local FORM_GUILD_DOMAIN_DECLARE = "form_stage_main\\form_guild_domain\\form_guild_domain_declare"
local CLIENT_SUBMSG_REQUEST_TIANWEIQIFU_INFO = 38
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 2
  nx_execute(FORM_GUILD_DOMAIN_DECLARE, "custom_request_info", CLIENT_SUBMSG_REQUEST_TIANWEIQIFU_INFO)
  return
end
function on_main_form_close(form)
  if not nx_is_valid(form) then
    return
  end
  nx_destroy(form)
  return
end
function on_btn_close_click(btn)
  if not nx_is_valid(btn) or not nx_is_valid(btn.ParentForm) then
    return
  end
  btn.ParentForm:Close()
  return
end
function update_all_tianweiqifu_info(...)
  local form = nx_value(nx_current())
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  if table.getn(arg) < 3 then
    return
  end
  local table_guild_qifu = {}
  local table_domain_tianwei = {}
  local table_domain_qifu = {}
  local domain_tianwei_num = arg[1]
  local domain_qifu_num = arg[2]
  local guild_qifu_num = arg[3]
  local dtw_start_index = 4
  local dtw_end_index = dtw_start_index + domain_tianwei_num - 1
  if 0 < domain_tianwei_num then
    local index = 1
    for i = dtw_start_index, dtw_end_index, 2 do
      table_domain_tianwei[index] = {
        domain_id = arg[i],
        tianwei = arg[i + 1]
      }
      index = index + 1
    end
  end
  local dqf_start_index = dtw_end_index + 1
  local dqf_end_index = dqf_start_index + domain_qifu_num - 1
  if 0 < domain_qifu_num then
    local index = 1
    for i = dqf_start_index, dqf_end_index, 2 do
      table_domain_qifu[index] = {
        domain_id = arg[i],
        qifu = arg[i + 1]
      }
      index = index + 1
    end
  end
  local gqf_start_index = dqf_end_index + 1
  local gqf_end_index = gqf_start_index + guild_qifu_num - 1
  if 0 < guild_qifu_num then
    local index = 1
    for i = gqf_start_index, gqf_end_index, 2 do
      table_guild_qifu[index] = {
        guild_name = arg[i],
        qifu = arg[i + 1]
      }
      index = index + 1
    end
  end
  form.mltbox_all_info:Clear()
  for i = 1, table.getn(table_domain_tianwei) do
    local text_domain = nx_widestr(util_text("ui_dipan_" .. nx_string(table_domain_tianwei[i].domain_id)))
    local text_tianwei = nx_widestr(util_text("ui_guildTianWeiName_" .. nx_string(table_domain_tianwei[i].tianwei)))
    local text_domain_tianwei_desc = gui.TextManager:GetFormatText("ui_TianQides_01", text_tianwei, text_domain)
    form.mltbox_all_info:AddHtmlText(text_domain_tianwei_desc, -1)
  end
  for i = 1, table.getn(table_domain_qifu) do
    local text_domain = nx_widestr(util_text("ui_dipan_" .. nx_string(table_domain_qifu[i].domain_id)))
    local text_qifu = nx_widestr(util_text("ui_guildQiFuName_" .. nx_string(table_domain_qifu[i].qifu)))
    local text_domain_qifu_desc = gui.TextManager:GetFormatText("ui_TianQides_02", text_qifu, text_domain)
    form.mltbox_all_info:AddHtmlText(text_domain_qifu_desc, -1)
  end
  for i = 1, table.getn(table_guild_qifu) do
    local text_guild = nx_widestr(table_guild_qifu[i].guild_name)
    local text_qifu = nx_widestr(util_text("ui_guildQiFuName_" .. nx_string(table_guild_qifu[i].qifu)))
    local text_guild_qifu_desc = gui.TextManager:GetFormatText("ui_TianQides_03", text_guild, text_qifu)
    form.mltbox_all_info:AddHtmlText(text_guild_qifu_desc, -1)
  end
  return
end
