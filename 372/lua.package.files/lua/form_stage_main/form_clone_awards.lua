require("share\\view_define")
require("util_gui")
require("game_object")
require("util_static_data")
require("define\\tip_define")
require("share\\client_custom_define")
require("share\\capital_define")
require("define\\team_rec_define")
require("share\\chat_define")
local FORM_TEAM_ASSIGN = "form_stage_main\\form_team\\form_team_assign"
local FORM_COMPETE_BASEPRICE = "form_stage_main\\form_compete\\form_baseprice"
MAX_CLONE_AWARDS_CAPACITY = 16
MAX_TEAM_COUNT = 8
local color_lst = global_color_list
function main_form_init(self)
  self.Fixed = true
  self.nCurrentPage = 0
  self.nMaxPage = 0
  self.nDropBoxCapacity = MAX_CLONE_AWARDS_CAPACITY
  self.nItemTypeShowPerPage = 4
  self.nMaxIndexCount = 0
  self.nCurrentIndex = 0
  return 1
end
function on_main_form_open(self)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  if nx_find_custom(game_client, "ready") and game_client.ready == false then
    self:Close()
    return
  end
  local b_relationship = nx_execute("util_gui", "util_is_form_visible", "form_stage_main\\form_relationship")
  if nx_is_valid(b_relationship) then
    nx_execute("util_gui", "util_auto_show_hide_form", "form_stage_main\\form_relationship")
  end
  self.btn_pageup.Visible = false
  self.btn_pagedown.Visible = false
  self.lbl_page_show.Visible = false
  self.icg_items.Visible = false
  change_form_size(self)
  self.icg_items.typeid = VIEWPORT_CLONE_AWARDS
  self.icg_items.beginindex = 1
  self.icg_items.endindex = MAX_CLONE_AWARDS_CAPACITY
  local grid_index = 0
  for view_index = self.icg_items.beginindex, self.icg_items.endindex do
    self.icg_items:SetBindIndex(grid_index, view_index)
    grid_index = grid_index + 1
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddViewBind(VIEWPORT_CLONE_AWARDS, self, "form_stage_main\\form_clone_awards", "on_clone_awards_viewport_change")
  end
  on_clone_awards_viewport_change(self, 0, VIEWPORT_CLONE_AWARDS, 0)
end
function change_form_size(self)
  if not nx_is_valid(self) then
    return
  end
  local gui = nx_value("gui")
  self.AbsLeft = 0
  self.AbsTop = 0
  self.Width = gui.Width
  self.Height = gui.Height
end
function on_main_form_close(self)
  if self.icg_items.Capture == true then
    nx_execute("tips_game", "hide_tip", self)
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelViewBind(self)
  end
  nx_destroy(self)
  local form_itembind_pickup = nx_value("form_stage_main\\form_itembind\\form_itembind_pickup")
  if nx_is_valid(form_itembind_pickup) then
    form_itembind_pickup:Close()
  end
  local form_team_assign = nx_value(FORM_TEAM_ASSIGN)
  if nx_is_valid(form_team_assign) then
    form_team_assign:Close()
  end
end
function on_btn_close_click(self)
  local Parent_form = self.Parent
  if Parent_form.nMaxIndexCount ~= 0 then
    local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
    local text = nx_widestr(util_text("ui_cloneaward_sure"))
    nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
    dialog:ShowModal()
    local res = nx_wait_event(100000000, dialog, "confirm_return")
    if res == "ok" then
      Parent_form:Close()
    end
  else
    Parent_form:Close()
  end
end
function on_btn_min_click(self)
  local Parent_form = self.Parent
  if Parent_form.nMaxIndexCount ~= 0 then
    local form = nx_value("form_stage_main\\form_clone_awards_min")
    if not nx_is_valid(form) then
      form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_clone_awards_min", true, false)
    end
    form:Show()
    Parent_form.Visible = false
  else
    Parent_form:Close()
    local gui = nx_value("gui")
    local info = gui.TextManager:GetFormatText("5101")
    local form_main_chat_logic = nx_value("form_main_chat")
    if nx_is_valid(form_main_chat_logic) then
      form_main_chat_logic:AddChatInfoEx(info, CHATTYPE_SYSTEM, false)
    end
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(info, 2)
    end
  end
end
function on_clone_awards_viewport_change(self, optype, view_ident, index)
  if nx_running(nx_current(), "wait_for_change", self) then
    nx_kill(nx_current(), "wait_for_change", self)
  end
  nx_execute(nx_current(), "wait_for_change", self, optype, view_ident, index)
end
function wait_for_change(self, optype, view_ident, index)
  nx_pause(0.1)
  if not nx_is_valid(self) then
    return
  end
  on_clone_awards_viewport_change2(self, optype, view_ident, index)
end
function on_clone_awards_viewport_change2(self, optype, view_ident, index)
  local game_client = nx_value("game_client")
  local view = game_client:GetView(nx_string(view_ident))
  if not nx_is_valid(view) then
    return 1
  end
  local nCurrentValidItemTyps = 0
  if nx_int(self.nMaxPage) <= nx_int(0) then
    self.nCurrentPage = 1
  end
  self.nMaxIndexCount = get_viewport_valid_item_type_cout(view)
  local tmp1, tmp2 = math.modf(self.nMaxIndexCount / self.nItemTypeShowPerPage)
  if tmp2 ~= 0 then
    self.nMaxPage = nx_int(tmp1 + 1)
  else
    self.nMaxPage = nx_int(tmp1)
  end
  if 1 >= self.nMaxPage then
    self.btn_pageup.Visible = false
    self.btn_pagedown.Visible = false
    self.lbl_page_show.Visible = false
  else
    self.btn_pageup.Visible = true
    self.btn_pagedown.Visible = true
    self.lbl_page_show.Visible = true
  end
  if nx_int(self.nMaxPage) < nx_int(self.nCurrentPage) then
    self.nCurrentPage = self.nMaxPage
  end
  local startpos = (self.nCurrentPage - 1) * self.nItemTypeShowPerPage + 1
  if startpos < 1 then
    startpos = 1
  end
  nCurrentValidItemTyps = self.nMaxIndexCount
  local endpos = startpos + self.nItemTypeShowPerPage
  if nx_int(endpos) > nx_int(nCurrentValidItemTyps) then
    endpos = nx_int(nCurrentValidItemTyps)
  end
  fresh_viewport_item_to_list(self, view, startpos, endpos)
  refresh_all_btn(self)
end
function get_viewport_valid_item_type_cout(view)
  local max_index = 0
  for count = MAX_CLONE_AWARDS_CAPACITY, 1, -1 do
    local obj = view:GetViewObj(nx_string(count))
    if nx_is_valid(obj) then
      max_index = count
      break
    end
  end
  return max_index
end
function fresh_viewport_item_to_list(root, view, startpos, endpos)
  for index = 0, root.nItemTypeShowPerPage - 1 do
    local nRealPos = nx_int(index) + nx_int(startpos)
    local viewobj = view:GetViewObj(nx_string(nRealPos))
    if nx_is_valid(viewobj) then
      reset_list_item(root, index, true, viewobj)
    else
      reset_list_item(root, index, false, viewobj)
    end
  end
end
function reset_list_item(root, pos, bshow, viewobj)
  local gui = nx_value("gui")
  root.icg_items:DelItem(nx_int(pos))
  if nx_is_valid(root.icg_items.Data) then
    root.icg_items.Data:RemoveChild(nx_string(pos))
  end
  if bshow then
    local item_config = viewobj:QueryProp("ConfigID")
    local item_count = viewobj:QueryProp("Amount")
    local item_color_level = viewobj:QueryProp("ColorLevel")
    local ItemQuery = nx_value("ItemQuery")
    if not nx_is_valid(ItemQuery) then
      return
    end
    local bExist = ItemQuery:FindItemByConfigID(nx_string(item_config))
    if bExist == false then
      return
    end
    local item_name = gui.TextManager:GetText(item_config)
    local item_photo = item_query_ArtPack_by_id(nx_string(item_config), nx_string("Photo"))
    if nx_number(item_color_level) < 1 or nx_number(item_color_level) > 6 then
      item_color_level = 1
    end
    root.icg_items:AddItem(nx_int(pos), nx_string(item_photo), nx_widestr(item_name), nx_int(item_count), nx_int(0))
    local tee = nx_widestr("<font color=\"") .. nx_widestr(color_lst[nx_number(item_color_level)]) .. nx_widestr("\">") .. nx_widestr(item_name) .. nx_widestr("</font>")
    root.icg_items:SetItemInfo(nx_int(pos), nx_widestr(tee))
    local grid = root.icg_items
    if not nx_is_valid(grid.Data) then
      grid.Data = nx_create("ArrayList", "form_clone_awards_reset_list_item")
    end
    local child_data = nx_create("ArrayList", "form_clone_awards_reset_list_item_child_data")
    child_data.Name = nx_string(pos)
    grid.Data:AddChild(child_data)
    local prop_table = {}
    local proplist = viewobj:GetPropList()
    for i, prop in pairs(proplist) do
      prop_table[prop] = viewobj:QueryProp(prop)
    end
    for prop, value in pairs(prop_table) do
      nx_set_custom(child_data, prop, value)
    end
  end
end
function on_btn_pageup_click(self)
  self.Parent.nCurrentPage = self.Parent.nCurrentPage - 1
  on_clone_awards_viewport_change(self.Parent, "updateitem", VIEWPORT_CLONE_AWARDS, 0)
end
function on_btn_pagedown_click(self)
  self.Parent.nCurrentPage = self.Parent.nCurrentPage + 1
  on_clone_awards_viewport_change(self.Parent, "updateitem", VIEWPORT_CLONE_AWARDS, 0)
end
function on_btn_pick_click(btn)
  local form_awards = btn.ParentForm
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "clear_pickup_index_table")
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  local num = form_awards.nMaxIndexCount
  local b_first = true
  local gui = nx_value("gui")
  for count = num, 1, -1 do
    local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "drop_itemobj_need_bind", nx_int(count))
    if b_need_bind then
      if b_first then
        local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
        if nx_is_valid(form) then
          form.view_id = VIEWPORT_CLONE_AWARDS
          form.item_index = tonumber(count)
          form.AbsLeft = (gui.Width - form.Width) / 2
          form.AbsTop = (gui.Height - form.Height) / 4
          nx_execute("form_stage_main\\form_itembind\\form_itembind_pickup", "set_form_showinfo")
          nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
          gui.Desktop:ToFront(form)
        end
        b_first = false
      end
    else
      nx_execute("custom_sender", "custom_pickup_cloneitem", count)
    end
  end
end
function refresh_all_btn(self)
  if not nx_is_valid(self) then
    return
  end
  self.btn_pageup.Enabled = true
  self.btn_pagedown.Enabled = true
  if nx_int(self.nCurrentPage) == nx_int(1) then
    self.btn_pageup.Enabled = false
  end
  if nx_int(self.nCurrentPage) == nx_int(self.nMaxPage) then
    self.btn_pagedown.Enabled = false
  end
  local page_show = nx_string(nx_int(self.nCurrentPage)) .. "/" .. nx_string(nx_int(self.nMaxPage))
  self.lbl_page_show.Text = nx_widestr(page_show)
end
function on_icg_items_select_changed(self, index)
  local form_awards = self.ParentForm
  local root = self.Parent
  root.nCurrentIndex = index
  local nrealindex = index + (root.nCurrentPage - 1) * root.nItemTypeShowPerPage + 1
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  local game_role = game_client:GetPlayer()
  if not nx_is_valid(game_role) then
    return
  end
  nx_execute("form_stage_main\\form_bag", "clear_select_items")
  local b_need_bind = nx_execute("form_stage_main\\form_itembind\\form_itembind_manager", "drop_itemobj_need_bind", nx_int(nrealindex))
  if b_need_bind then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
    if nx_is_valid(form) then
      form.view_id = VIEWPORT_CLONE_AWARDS
      form.item_index = tonumber(nrealindex)
      form.AbsLeft = (gui.Width - form.Width) / 2
      form.AbsTop = (gui.Height - form.Height) / 4
      nx_execute("form_stage_main\\form_itembind\\form_itembind_pickup", "set_form_showinfo")
      nx_execute("util_gui", "util_show_form", "form_stage_main\\form_itembind\\form_itembind_pickup", true)
      gui.Desktop:ToFront(form)
    end
  else
    nx_execute("custom_sender", "custom_pickup_cloneitem", nrealindex)
  end
end
function on_icg_items_mousein_grid(self, index)
  local root = self.Parent
  local nrealindex = index + (root.nCurrentPage - 1) * root.nItemTypeShowPerPage + 1
  local GoodsGrid = nx_value("GoodsGrid")
  local item_data
  if nx_is_valid(GoodsGrid) then
    item_data = GoodsGrid:GetItemData(self, index)
  end
  nx_execute("tips_game", "show_goods_tip", item_data, self:GetMouseInItemLeft() + self.GridOffsetX, self:GetMouseInItemTop() + self.GridOffsetY, 32, 32, self.ParentForm)
end
function on_icg_items_mouseout_grid(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function refresh_desc(self, drop_id, score)
  local ini = nx_execute("util_functions", "get_ini", "share\\Rule\\cloneaward\\awardpack.ini")
  if not nx_is_valid(ini) then
    nx_msgbox("share\\Rule\\cloneaward\\awardpack.ini " .. get_msg_str("msg_120"))
    return 0
  end
  local sec_index = ini:FindSectionIndex(nx_string(drop_id))
  if sec_index < 0 then
    return
  end
  local gold = ini:ReadString(sec_index, "gold", "")
  local exp_1 = ini:ReadString(sec_index, "exp", "")
  local level = ini:ReadString(sec_index, "level", "")
  local liveGroove_1 = ini:ReadString(sec_index, "LiveGroove_1", "")
  local liveGroove_2 = ini:ReadString(sec_index, "LiveGroove_2", "")
  local liveGroove_3 = ini:ReadString(sec_index, "LiveGroove_3", "")
  local liveGroove_4 = ini:ReadString(sec_index, "LiveGroove_4", "")
  local liveGroove_5 = ini:ReadString(sec_index, "LiveGroove_5", "")
  local liveGroove = nx_number(liveGroove_1) / 1000 + nx_number(liveGroove_2) / 1000 + nx_number(liveGroove_3) / 1000 + nx_number(liveGroove_4) / 1000 + nx_number(liveGroove_5) / 1000
  self.ani_1.AnimationImage = "clone_award_3_" .. nx_string(level)
  self.ani_1.Loop = false
  self.ani_1.PlayMode = 2
  local capital = nx_value("CapitalModule")
  if not nx_is_valid(capital) then
    return
  end
  local list = capital:SplitCapital(nx_number(gold), nx_int(CAPITAL_TYPE_SILVER))
  form_scroll_num(self, score, list[1], list[2], list[3], liveGroove)
  refresh_all_btn(self)
end
function scroll_num(form, group_index, num)
  if not nx_is_valid(form) then
    return
  end
  local group = form:Find("groupbox_" .. group_index)
  if not nx_is_valid(group) then
    return
  end
  local lab = group:Find("box_lbl_" .. group_index)
  if not nx_is_valid(lab) then
    return
  end
  if nx_number(num) == -1 then
    return
  end
  local sec = 0
  while true do
    sec = sec + nx_pause(0.02)
    if not nx_is_valid(form) then
      return
    end
    local top = lab.Top
    lab.Top = top - 37 / math.random(1, 6)
    if nx_number(lab.Top) <= -386 then
      lab.Top = -18
    end
    if 1 <= sec then
      lab.Left = -100
      group.BackImage = "gui\\special\\clone\\" .. num .. ".png"
      break
    end
  end
end
function form_scroll_num(self, score, ding, liang, wen, liveGroove)
  if not nx_is_valid(self) then
    return
  end
  num = {}
  if 100000 <= score then
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = nx_int(math.mod(nx_number(score / 10), 10))
    num[3] = nx_int(math.mod(nx_number(score / 100), 10))
    num[4] = nx_int(math.mod(nx_number(score / 1000), 10))
    num[5] = nx_int(math.mod(nx_number(score / 10000), 10))
    num[6] = nx_int(math.mod(nx_number(score / 100000), 10))
  elseif 10000 <= score then
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = nx_int(math.mod(nx_number(score / 10), 10))
    num[3] = nx_int(math.mod(nx_number(score / 100), 10))
    num[4] = nx_int(math.mod(nx_number(score / 1000), 10))
    num[5] = nx_int(math.mod(nx_number(score / 10000), 10))
    num[6] = -1
  elseif 1000 <= score then
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = nx_int(math.mod(nx_number(score / 10), 10))
    num[3] = nx_int(math.mod(nx_number(score / 100), 10))
    num[4] = nx_int(math.mod(nx_number(score / 1000), 10))
    num[5] = -1
    num[6] = -1
  elseif 100 <= score then
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = nx_int(math.mod(nx_number(score / 10), 10))
    num[3] = nx_int(math.mod(nx_number(score / 100), 10))
    num[4] = -1
    num[5] = -1
    num[6] = -1
  elseif 10 <= score then
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = nx_int(math.mod(nx_number(score / 10), 10))
    num[3] = -1
    num[4] = -1
    num[5] = -1
    num[6] = -1
  else
    num[1] = nx_int(math.mod(nx_number(score), 10))
    num[2] = -1
    num[3] = -1
    num[4] = -1
    num[5] = -1
    num[6] = -1
  end
  num[7] = nx_int(math.mod(nx_number(wen), 10))
  num[8] = nx_int(math.mod(nx_number(wen) / 10, 10))
  num[9] = nx_int(wen / 100)
  num[10] = nx_int(math.mod(nx_number(liang), 10))
  num[11] = nx_int(math.mod(nx_number(liang) / 10, 10))
  num[12] = nx_int(nx_number(liang) / 100)
  num[13] = nx_int(math.mod(nx_number(ding), 10))
  if nx_number(ding) >= 100 then
    num[14] = nx_int(nx_number(ding) / 100)
    num[15] = nx_int(math.mod(nx_number(ding) / 10, 10))
  else
    if nx_number(ding) >= 10 then
      num[15] = nx_int(math.mod(nx_number(ding) / 10, 10))
    else
      num[15] = -1
    end
    num[14] = -1
  end
  if nx_number(liveGroove) >= 10000 then
    num[20] = nx_int(nx_number(liveGroove) / 10000)
    num[19] = nx_int(math.mod(nx_number(liveGroove) / 1000, 10))
    num[18] = nx_int(math.mod(nx_number(liveGroove) / 100, 10))
    num[17] = nx_int(math.mod(nx_number(liveGroove) / 10, 10))
    num[16] = nx_int(math.mod(nx_number(liveGroove), 10))
  else
    if nx_number(liveGroove) >= 1000 then
      num[19] = nx_int(math.mod(nx_number(liveGroove) / 1000, 10))
      num[18] = nx_int(math.mod(nx_number(liveGroove) / 100, 10))
      num[17] = nx_int(math.mod(nx_number(liveGroove) / 10, 10))
      num[16] = nx_int(math.mod(nx_number(liveGroove), 10))
    else
      if nx_number(liveGroove) >= 100 then
        num[18] = nx_int(math.mod(nx_number(liveGroove) / 100, 10))
        num[17] = nx_int(math.mod(nx_number(liveGroove) / 10, 10))
        num[16] = nx_int(math.mod(nx_number(liveGroove), 10))
      else
        if nx_number(liveGroove) >= 10 then
          num[17] = nx_int(math.mod(nx_number(liveGroove) / 10, 10))
          num[16] = nx_int(math.mod(nx_number(liveGroove), 10))
        else
          num[16] = nx_int(math.mod(nx_number(liveGroove), 10))
          num[17] = -1
        end
        num[18] = -1
      end
      num[19] = -1
    end
    num[20] = -1
  end
  self.ani_title_back:Play()
  local seconds = 0
  while true do
    seconds = seconds + nx_pause(0.02)
    if not nx_is_valid(self) then
      return
    end
    if 0.5 <= seconds then
      self.ani_title:Play()
      if 1 <= seconds then
        self.ani_time:Play()
        self.ani_gold:Play()
        self.ani_exp:Play()
        self.ani_item:Play()
      end
    end
    if 1 <= seconds then
      for i = 1, 6 do
        nx_execute(nx_current(), "scroll_num", self, i, num[i])
      end
      if 2 <= seconds then
        self.groupbox_gold.Visible = true
        for i = 7, 15 do
          nx_execute(nx_current(), "scroll_num", self, i, num[i])
        end
        if 3 <= seconds then
          for i = 16, 20 do
            nx_execute(nx_current(), "scroll_num", self, i, num[i])
          end
          if 4 <= seconds then
            if 3 >= self.nMaxIndexCount then
              self.lbl_bg_4.Visible = false
              if 2 >= self.nMaxIndexCount then
                self.lbl_bg_3.Visible = false
                if 1 >= self.nMaxIndexCount then
                  self.lbl_bg_2.Visible = false
                  if 0 >= self.nMaxIndexCount then
                    self.lbl_bg_1.Visible = false
                  end
                end
              end
            end
            self.icg_items.Visible = true
            self.ani_1:Play()
            break
          end
        end
      end
    end
  end
end
