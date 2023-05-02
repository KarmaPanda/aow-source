require("custom_sender")
require("share\\view_define")
require("form_stage_main\\form_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  for i = 1, 9 do
    local name = "lbl_" .. nx_string(i)
    local lblobj = self:Find(name)
    if nx_is_valid(lblobj) then
      lblobj.Visible = false
    end
  end
  local databinder = nx_value("data_binder")
  databinder:AddViewBind(VIEWPORT_JUANZHOU, self, nx_current(), "on_self_view_operat")
  return 1
end
function get_NPC_id(...)
  if table.getn(arg) < 1 then
    return
  end
  local form = nx_value("form_stage_main\\form_guildbuilding\\form_guild_build_booklist")
  form.npc_id = arg[1]
  local game_client = nx_value("game_client")
  local build_npc = game_client:GetSceneObj(nx_string(form.npc_id))
  if not nx_is_valid(build_npc) then
    return
  end
  local sub_type = build_npc:QueryProp("SubType")
  init_form(form, sub_type)
  on_self_view_operat(form)
end
function init_form(self, sub_type)
  local file_name = "share\\Guild\\GuildFuncNpc\\GuildFuncNpc_BuyBook.ini"
  local ini = nx_execute("util_functions", "get_ini", file_name)
  if not nx_is_valid(ini) then
    return
  end
  local sec_count = ini:GetSectionCount()
  local first, last, count = 1, 9, 1
  if nx_number(sub_type) ~= 5 then
    first = 10
    last = sec_count
  else
    first = 1
    last = 9
  end
  for i = first, last do
    local section = ini:GetSectionByIndex(i - 1)
    local image = nx_resource_path() .. "gui\\guild\\book\\" .. nx_string(section) .. ".png"
    local name = guild_util_get_text("ui_" .. nx_string(section))
    self.BookGrid:AddItem(count - 1, image, nx_widestr(name), nx_int(0), nx_int(0))
    self.BookGrid:SetItemName(count - 1, nx_widestr(section))
    self.BookGrid:ShowItemAddInfo(count - 1, 0, true)
    count = count + 1
  end
end
function on_BookGrid_select_changed(grid, index)
  local config_id = grid:GetItemName(index)
  local form = grid.ParentForm
  if nx_string(config_id) == "" then
    return
  else
    nx_execute("form_stage_main\\form_guildbuilding\\form_guild_build_buybook", "show_book_info", config_id, form.npc_id)
  end
end
function on_self_view_operat(form)
  if not nx_is_valid(form) then
    return
  end
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(VIEWPORT_JUANZHOU))
  if not nx_is_valid(view) then
    return 1
  end
  local scroll_count = view:GetRecordRows("JuanZhouRec")
  for i = 0, scroll_count - 1 do
    local scroll_id = view:QueryRecord("JuanZhouRec", i, 0)
    local index = form.BookGrid:FindItem(nx_widestr(scroll_id))
    if index ~= -1 then
      local name = "lbl_" .. nx_string(index + 1)
      local lblobj = form:Find(name)
      if nx_is_valid(lblobj) then
        lblobj.Visible = true
      end
    end
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_main_form_close(self)
  local databinder = nx_value("data_binder")
  databinder:DelViewBind(self)
  custom_guild_del_viewport(VIEWPORT_JUANZHOU)
  nx_destroy(self)
end
