require("custom_sender")
require("share\\view_define")
require("util_gui")
require("util_functions")
require("form_stage_main\\form_guild\\form_guild_util")
function main_form_init(self)
  self.Fixed = false
  self.book_id = ""
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  return 1
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_ok_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    if form.book_id ~= "" then
      custom_guild_buybook(form.book_id)
    end
    form:Close()
  end
end
function show_book_info(config_id, npcid)
  local form = util_get_form("form_stage_main\\form_guildbuilding\\form_guild_build_buybook", true)
  if nx_is_valid(form) then
    form.book_id = nx_string(config_id)
    local file_name = "share\\Guild\\GuildFuncNpc\\GuildFuncNpc_BuyBook.ini"
    local ini = nx_execute("util_functions", "get_ini", file_name)
    if not nx_is_valid(ini) then
      return
    end
    local item_table = ini:GetItemValueList(nx_string(config_id), nx_string("r"))
    if table.getn(item_table) < 1 then
      return
    end
    local cost_info = util_split_string(item_table[1], ",")
    if table.getn(cost_info) < 3 then
      return
    end
    if nx_int(cost_info[1]) == nx_int(0) then
      form.mltbox_3:AddHtmlText(nx_widestr(guild_util_get_text("ui_buybook_player_capital", nx_int(cost_info[2]), nx_int(cost_info[3]))), nx_int(-1))
    else
      form.mltbox_3:AddHtmlText(nx_widestr(guild_util_get_text("ui_buybook_guild_capital", nx_int(cost_info[2]), nx_int(cost_info[3]))), nx_int(-1))
    end
    form.pic_book.Image = nx_resource_path() .. "gui\\guild\\book\\" .. nx_string(config_id) .. ".png"
    form.lbl_book_name.Text = guild_util_get_text("ui_" .. nx_string(config_id))
    form.mltbox_1:AddHtmlText(nx_widestr(guild_util_get_text("ui_bookintr_" .. nx_string(config_id))), nx_int(-1))
    form.mltbox_2:AddHtmlText(nx_widestr(guild_util_get_text("ui_bookinfo_" .. nx_string(config_id))), nx_int(-1))
    form.lbl_buy.Visible = false
    form.btn_ok.Visible = true
    form.Visible = true
    form:Show()
    local game_client = nx_value("game_client")
    local view = game_client:GetView(nx_string(VIEWPORT_JUANZHOU))
    if not nx_is_valid(view) then
      return 1
    end
    if not view:FindRecord("JuanZhouRec") then
      return
    end
    local scroll_count = view:GetRecordRows("JuanZhouRec")
    for i = 0, scroll_count - 1 do
      local scroll_id = view:QueryRecord("JuanZhouRec", i, 0)
      if nx_string(scroll_id) == nx_string(config_id) then
        form.lbl_buy.Visible = true
        form.btn_ok.Visible = false
      end
    end
  end
end
