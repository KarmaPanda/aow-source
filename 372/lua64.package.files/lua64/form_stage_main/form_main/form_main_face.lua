require("util_gui")
require("define\\gamehand_type")
require("define\\shortcut_key_define")
local nCurPage = 1
local nPageFaceNum = 42
local PAGE_FACE = 1
local PAGE_ACTION_SELF = 2
local PAGE_INTERACTION = 3
local ACTION_SHOW_PHOTO = "gui\\special\\action_show\\"
local ACTION_SHOW_REC = "ActionShowRec"
local FACE_GENERAL = 1
local FACE_VIP = 2
local ACTION_GENERAL = 1
local ACTION_VIP = 2
function main_face_init(self)
  self.Fixed = false
  self.type = nil
  self.face_type = FACE_GENERAL
  self.vip_face_type = 1
  return 1
end
function on_form_open(self)
  local gui = nx_value("gui")
  self.imagegrid_face.ImageAsync = true
  self.CurFacePage_0 = 0
  self.MaxFaceNum_0 = 84
  self.MaxPageNum_0 = 2
  self.MaxVipFaceNum_0 = 71
  self.MaxVipPageNum_0 = 2
  self.CurActionPage_1 = 0
  self.MaxActionNum_1 = 50
  self.MaxPageNum_1 = 2
  self.CurActionPage_2 = 0
  self.MaxActionNum_2 = 50
  self.MaxPageNum_2 = 1
  self.rbtn_general.Visible = false
  self.rbtn_general.face_type = FACE_GENERAL
  self.rbtn_vip.Visible = false
  self.rbtn_vip.face_type = FACE_VIP
  local vipstatus = get_player_prop("VipStatus")
  if nx_number(vipstatus) == 1 then
    self.face_type = FACE_VIP
    self.rbtn_vip.Checked = true
  else
    self.face_type = FACE_GENERAL
    self.rbtn_general.Checked = true
  end
  show_page(self, 0)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind(ACTION_SHOW_REC, self, nx_current(), "on_action_rec_changed")
  end
  return 1
end
function on_form_close(self)
  local imagegrid = self.imagegrid_face
  imagegrid:Clear()
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind(ACTION_SHOW_REC, self)
  end
  nx_destroy(self)
  return 1
end
function on_click_imagegrid(grid, grid_index)
  local form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  local cur_page = get_cur_page(form)
  local page_num = get_item_num_max_one_page(form)
  local index = grid_index + 1 + cur_page * page_num
  local total = get_item_num_max_all(form)
  if index > total then
    nx_gen_event(form, "selectface_return", "cancel")
    nx_execute("tips_game", "hide_tip", form)
    return
  end
  if form.type == PAGE_FACE then
    set_select_face(form, index)
    return
  end
  local gui = nx_value("gui")
  grid:SetSelectItemIndex(nx_int(-1))
  local grid_index = index - 1
  if gui.GameHand:IsEmpty() and not grid:IsEmpty(grid_index) then
    local photo = grid:GetItemImage(grid_index)
    local amount = grid:GetItemNumber(grid_index)
    if form.type == PAGE_ACTION_SELF then
      local action_id = grid:GetItemName(grid_index)
      gui.GameHand:SetHand(GHT_ACTION_FACE, nx_string(photo), GHT_ACTION_FACE, nx_string(action_id), nx_string(photo), "")
    end
  end
end
function get_str_id(self)
  local type = self.type
  local out_str = "ui_face_"
  if type == PAGE_FACE then
    if self.face_type == FACE_GENERAL then
      out_str = "ui_face_"
    else
      out_str = "ui_face_vip_"
    end
  elseif type == PAGE_ACTION_SELF then
    out_str = "ui_action_"
  elseif type == PAGE_INTERACTION then
    out_str = "ui_action_inter_"
  end
  return out_str
end
function on_mousein_face(self, index)
  local form = self.ParentForm
  if self:IsEmpty(index) then
    nx_execute("tips_game", "hide_tip", self.ParentForm)
    return 0
  end
  local name = self:GetItemName(index)
  local face_index = index + 1 + nCurPage * nPageFaceNum
  local gui = nx_value("gui")
  name = nx_string(get_str_id(self.ParentForm)) .. nx_string(name)
  local text = gui.TextManager:GetFormatText(nx_string(name), nx_int(face_index))
  if form.face_type == ACTION_VIP then
    local mutual_action = nx_value("mutual_action")
    local items_info = nx_widestr("")
    if nx_is_valid(mutual_action) then
      local action_id = self:GetItemName(index)
      items_info = mutual_action:GetMutualActPackInfo(nx_string(action_id))
    end
    gui.TextManager:Format_SetIDName(nx_string(name))
    gui.TextManager:Format_AddParam(nx_widestr(items_info))
    text = gui.TextManager:Format_GetText()
  end
  local x = self:GetMouseInItemLeft()
  local y = self:GetMouseInItemTop()
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), x, y, 0, self.ParentForm)
end
function ShowPage(self, npage)
  if self.face_type == FACE_GENERAL then
    if 0 <= npage and npage < self.MaxPageNum_0 then
      nCurPage = npage
      set_cur_page(self, npage)
      local imagegrid = self.imagegrid_face
      imagegrid:Clear()
      local nbegin = npage * nPageFaceNum
      local nFaceNum = nPageFaceNum
      if nbegin + nPageFaceNum > self.MaxFaceNum_0 then
        nFaceNum = self.MaxFaceNum_0 - nbegin
      end
      local gui = nx_value("gui")
      for i = 1, nFaceNum do
        local faceindex = i + nbegin
        imagegrid:AddItem(i - 1, "Face" .. faceindex, nx_widestr(faceindex), 1, -1)
      end
      self.label_page.Text = nx_widestr(nCurPage + 1 .. "/" .. self.MaxPageNum_0)
    end
  elseif 0 <= npage and npage < self.MaxVipPageNum_0 then
    nCurPage = npage
    set_cur_page(self, npage)
    local imagegrid = self.imagegrid_face
    imagegrid:Clear()
    local nbegin = npage * nPageFaceNum
    local nFaceNum = nPageFaceNum
    if nbegin + nPageFaceNum > self.MaxVipFaceNum_0 then
      nFaceNum = self.MaxVipFaceNum_0 - nbegin
    end
    local gui = nx_value("gui")
    for i = 1, nFaceNum do
      local faceindex = i + nbegin
      imagegrid:AddItem(i - 1, "bq_vip_" .. faceindex, nx_widestr(faceindex), 1, -1)
    end
    self.label_page.Text = nx_widestr(nCurPage + 1 .. "/" .. self.MaxVipPageNum_0)
  end
end
function on_mouseout_face(self, index)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function btn_movefront_click(self)
  local form = self.ParentForm
  local cur_page = get_cur_page(form)
  local max_page_num = get_page_num(form)
  local newpage = (cur_page - 1 + max_page_num) % max_page_num
  show_page(form, newpage)
end
function btn_moveback_click(self)
  local form = self.ParentForm
  local cur_page = get_cur_page(form)
  local max_page_num = get_page_num(form)
  local newpage = (cur_page + 1) % max_page_num
  show_page(form, newpage)
end
function auto_show_facepannel(name, target)
  local face_form = nx_value(name)
  local result = ""
  if nx_is_valid(face_form) then
    nx_gen_event(face_form, "selectface_return", "cancel", "")
  else
    local gui = nx_value("gui")
    local form_main_face = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_main\\form_main_face", true, false)
    nx_set_value(name, form_main_face)
    form_main_face.AbsLeft = target.AbsLeft + target.Width
    form_main_face.AbsTop = target.AbsTop + target.Height - form_main_face.Height
    form_main_face:Show()
    local res, html = nx_wait_event(100000000, form_main_face, "selectface_return")
    if res == "ok" then
      result = html
    else
      result = ""
    end
  end
  nx_set_value(name, nil)
  return result
end
function get_max_icon_num()
  return 84
end
function show_page(self, npage)
  local type = self.type
  if type == PAGE_FACE then
    self.lbl_title.Text = nx_widestr("@ui_chat_face_text")
    self.rbtn_general.Visible = true
    self.rbtn_vip.Visible = true
    self.rbtn_general.Text = nx_widestr("@ui_putong")
    self.rbtn_vip.Text = nx_widestr("@ui_face_vip_rbt")
    ShowPage(self, npage)
  elseif type == PAGE_ACTION_SELF then
    self.lbl_title.Text = nx_widestr("@ui_chat_face_dongzuo_text")
    self.rbtn_general.Visible = true
    self.rbtn_vip.Visible = true
    self.rbtn_general.Text = nx_widestr("@ui_chat_dongzuo_single")
    self.rbtn_vip.Text = nx_widestr("@ui_chat_dongzuo_mutual")
    set_cur_page(self, npage)
    on_action_rec_refresh(self)
  elseif type == PAGE_INTERACTION then
    self.rbtn_general.Visible = false
    self.rbtn_vip.Visible = false
  end
end
function set_cur_page(self, index)
  local type = self.type
  if type == PAGE_FACE then
    self.CurFacePage_0 = index
  elseif type == PAGE_ACTION_SELF then
    self.CurActionPage_1 = index
  elseif type == PAGE_INTERACTION then
    self.CurActionPage_2 = index
  end
end
function get_cur_page(self)
  local type = self.type
  local out_num = 0
  if type == PAGE_FACE then
    out_num = self.CurFacePage_0
  elseif type == PAGE_ACTION_SELF then
    out_num = self.CurActionPage_1
  elseif type == PAGE_INTERACTION then
    out_num = self.CurActionPage_2
  end
  return out_num
end
function get_item_num_max_one_page(self)
  return nPageFaceNum
end
function set_item_num_max_all(self, num)
  local type = self.type
  local out_num = 0
  if type == PAGE_FACE then
    if self.face_type == FACE_GENERAL then
      self.MaxFaceNum_0 = num
    else
      self.MaxVipFaceNum_0 = num
    end
  elseif type == PAGE_ACTION_SELF then
    self.MaxActionNum_1 = num
  elseif type == PAGE_INTERACTION then
    self.MaxActionNum_2 = num
  end
end
function get_item_num_max_all(self)
  local type = self.type
  local out_num = 0
  if type == PAGE_FACE then
    if self.face_type == FACE_GENERAL then
      out_num = self.MaxFaceNum_0
    else
      out_num = self.MaxVipFaceNum_0
    end
  elseif type == PAGE_ACTION_SELF then
    out_num = self.MaxActionNum_1
  elseif type == PAGE_INTERACTION then
    out_num = self.MaxActionNum_2
  end
  return out_num
end
function set_page_num(self, max_num)
  local one_page_num = get_item_num_max_one_page(self)
  local value = max_num / one_page_num
  local _int, _float = math.modf(value)
  if 0 < _float then
    _int = _int + 1
  end
  local type = self.type
  if type == PAGE_FACE then
    if self.face_type == FACE_GENERAL then
      self.MaxPageNum_0 = _int
    else
      self.MaxVipPageNum_0 = _int
    end
  elseif type == PAGE_ACTION_SELF then
    self.MaxPageNum_1 = _int
  elseif type == PAGE_INTERACTION then
    self.MaxPageNum_2 = _int
  end
  return _int
end
function get_page_num(self)
  local type = self.type
  local out_num = 2
  if type == PAGE_FACE then
    if self.face_type == FACE_GENERAL then
      out_num = self.MaxPageNum_0
    else
      out_num = self.MaxVipPageNum_0
    end
  elseif type == PAGE_ACTION_SELF then
    out_num = self.MaxPageNum_1
  elseif type == PAGE_INTERACTION then
    out_num = self.MaxPageNum_2
  end
  return out_num
end
function show_action_page(self, npage)
  if npage < 0 or 2 < npage then
    return
  end
  local imagegrid = self.imagegrid_face
  imagegrid:Clear()
  nCurPage = npage
  set_cur_page(self, npage)
  local page_num = get_item_num_max_one_page(self)
  local total_num = get_item_num_max_all(self)
  local page_num_max = get_page_num(self)
  local cur_num = page_num
  local nbegin = npage * page_num
  if total_num < nbegin + page_num then
    cur_num = total_num - nbegin
  end
  local gui = nx_value("gui")
  for i = 1, cur_num do
    local faceindex = i + nbegin
    imagegrid:AddItem(i - 1, "Face" .. faceindex, gui.TextManager:GetText("ui_face_" .. faceindex), 1, -1)
  end
  self.label_page.Text = nx_widestr(npage + 1 .. "/" .. page_num_max)
end
function on_action_rec_changed(form, rec_name, opt_type, row, col)
  on_action_rec_refresh(form)
end
function on_action_rec_refresh(form, recordname, optype, row, clomn)
  if not nx_is_valid(form) then
    return 0
  end
  if form.type ~= PAGE_ACTION_SELF then
    return 0
  end
  local imagegrid = form.imagegrid_face
  imagegrid:Clear()
  nCurPage = 0
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not client_player:FindRecord("ActionShowRec") then
    return 0
  end
  if form.face_type == ACTION_GENERAL then
    local rownum = client_player:GetRecordRows("ActionShowRec")
    set_item_num_max_all(form, rownum)
    local page_num_max = set_page_num(form, rownum)
    local one_page_num = get_item_num_max_one_page(form)
    local cur_page = get_cur_page(form)
    if cur_page > page_num_max - 1 then
      return 0
    end
    local begin_index = cur_page * one_page_num
    if rownum > begin_index + one_page_num then
      end_index = (cur_page + 1) * one_page_num
    else
      end_index = rownum
    end
    if 1 > end_index then
      return 0
    end
    local gui = nx_value("gui")
    for i = begin_index + 1, end_index do
      local config_id = nx_string(client_player:QueryRecord("ActionShowRec", i - 1, 0))
      local faceindex = i
      local photo = ACTION_SHOW_PHOTO .. config_id .. ".png"
      imagegrid:AddItem(i - (begin_index + 1), photo, nx_widestr(config_id), 1, -1)
    end
    form.label_page.Text = nx_widestr(cur_page + 1 .. "/" .. page_num_max)
  elseif form.face_type == ACTION_VIP then
    local mutual_action = nx_value("mutual_action")
    if not nx_is_valid(mutual_action) then
      return 0
    end
    local rownum = client_player:GetRecordRows("MutualActionShowRec")
    set_item_num_max_all(form, rownum)
    local page_num_max = set_page_num(form, rownum)
    local one_page_num = get_item_num_max_one_page(form)
    local cur_page = get_cur_page(form)
    if cur_page > page_num_max - 1 then
      return 0
    end
    local begin_index = cur_page * one_page_num
    if rownum > begin_index + one_page_num then
      end_index = (cur_page + 1) * one_page_num
    else
      end_index = rownum
    end
    if 1 > end_index then
      return 0
    end
    local gui = nx_value("gui")
    for i = begin_index + 1, end_index do
      local config_id = nx_string(client_player:QueryRecord("MutualActionShowRec", i - 1, 0))
      local faceindex = i
      local photo = ACTION_SHOW_PHOTO .. config_id .. ".png"
      local num = mutual_action:UseMutualActNum(config_id)
      if nx_int(num) <= nx_int(0) then
        imagegrid:AddItem(i - 1, photo, nx_widestr(config_id), 1, -1)
        imagegrid:ChangeItemImageToBW(i - 1, true)
      else
        imagegrid:AddItem(i - 1, photo, nx_widestr(config_id), nx_int(num), -1)
        imagegrid:ChangeItemImageToBW(i - 1, false)
      end
    end
    form.label_page.Text = nx_widestr(cur_page + 1 .. "/" .. page_num_max)
  end
end
function on_btn_close_click(btn)
  local face_form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  nx_gen_event(face_form, "selectface_return", "cancel")
  nx_execute("tips_game", "hide_tip", face_form)
end
function on_rbtn_face_checked_changed(rbtn)
  if not rbtn.Checked then
    return
  end
  local form = rbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.face_type = rbtn.face_type
  show_page(form, 0)
end
function get_player_prop(prop_name)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return ""
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return ""
  end
  if not client_player:FindProp(nx_string(prop_name)) then
    return ""
  end
  return client_player:QueryProp(nx_string(prop_name))
end
function on_imagegrid_face_rightclick_grid(self)
  local form = nx_value("form_stage_main\\form_main\\form_main_face_chat")
  local cur_page = get_cur_page(form)
  local page_num = get_item_num_max_one_page(form)
  local index = self:GetRBClickItemIndex() + 1 + cur_page * page_num
  local total = get_item_num_max_all(form)
  if index > total then
    nx_gen_event(form, "selectface_return", "cancel")
    nx_execute("tips_game", "hide_tip", form)
    return
  end
  if form.type == PAGE_ACTION_SELF then
    local action_id = self:GetItemName(self:GetRBClickItemIndex())
    local mutual_action = nx_value("mutual_action")
    if nx_is_valid(mutual_action) then
      local type = mutual_action:GetMutualType(nx_string(action_id))
      if (type == 2 or type == 3) and not mutual_action:CheckMutualPos() then
        return false
      end
    end
    nx_execute("custom_sender", "custom_request_action", nx_string(action_id))
    nx_gen_event(form, "selectface_return", "cancel")
  else
    nx_gen_event(form, "selectface_return", "cancel")
  end
  nx_execute("tips_game", "hide_tip", form)
end
function set_select_face(form, index)
  if form.face_type == FACE_GENERAL then
    local html = nx_widestr("<img src=\"Face" .. index .. "\" only=\"line\" valign=\"bottom\"/>")
    nx_gen_event(form, "selectface_return", "ok", html)
  else
    local vipstatus = get_player_prop("VipStatus")
    if nx_number(vipstatus) == 1 then
      if nx_number(form.vip_face_type) == nx_number(2) then
        local html = nx_widestr("<img src=\"bq_vip_" .. index .. "\" only=\"line\" valign=\"bottom\"/>")
        nx_gen_event(form, "selectface_return", "ok", html)
      else
        local bvipchannel = nx_execute("form_stage_main\\form_main\\form_main_chat", "vip_face_channel")
        if bvipchannel then
          local html = nx_widestr("<img src=\"bq_vip_" .. index .. "\" only=\"line\" valign=\"bottom\"/>")
          nx_gen_event(form, "selectface_return", "ok", html)
        end
      end
    else
      local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
      if not nx_is_valid(dialog) then
        return
      end
      local gui = nx_value("gui")
      dialog.ok_btn.Text = gui.TextManager:GetText("ui_face_vip_btn")
      dialog.cancel_btn.Text = gui.TextManager:GetText("ui_cancel")
      local text = gui.TextManager:GetText("ui_face_vip_tips")
      nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
      dialog:ShowModal()
      local res = nx_wait_event(100000000, dialog, "confirm_return")
      if res == "ok" then
        util_auto_show_hide_form("form_stage_main\\form_vip_info")
      elseif res == "cancel" then
      else
        return
      end
    end
  end
end
