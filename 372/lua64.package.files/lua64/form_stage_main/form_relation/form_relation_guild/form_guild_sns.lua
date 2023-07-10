require("util_functions")
require("custom_sender")
require("util_gui")
require("form_stage_main\\form_relation\\form_relation_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
  self.FirstOpen = true
  self.NoticeAuth = true
end
function on_main_form_open(self)
  if self.FirstOpen then
    local page_notice = util_get_form("form_stage_main\\form_relation\\form_relation_guild\\form_guild_notice", true, false)
    if self.groupbox_notice:Add(page_notice) then
      self.page_notice = page_notice
      self.page_notice.Visible = true
      self.page_notice.Fixed = true
      self.page_notice.Top = 0
      self.page_notice.Left = 0
    end
  end
end
function on_main_form_close(self)
  nx_execute("form_stage_main\\form_relation\\form_relation_guild\\form_guild_manage_disband", "close_time")
  self.Visible = false
  nx_destroy(self)
end
