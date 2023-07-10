require("share\\view_define")
require("share\\logicstate_define")
require("player_state\\logic_const")
require("player_state\\state_input")
require("util_static_data")
require("utils")
require("util_gui")
require("define\\gamehand_type")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\request_type")
require("form_stage_main\\form_homepoint\\home_point_data")
RECORD_HOMEPOINT = 0
SENCE_HOMEPOINT = 1
local guild_domain_list = {}
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("HomePointList", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:AddTableBind("DongHaiHomePointList", form, nx_current(), "on_homepoint_rec_refresh")
  end
end
function on_main_form_close(form)
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("HomePointList", form)
    databinder:DelTableBind("DongHaiHomePointList", form)
  end
  nx_destroy(form)
end
function on_form_close_click(btn)
  local form = btn.Parent
  if not nx_is_valid(form) then
    return
  end
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:DelTableBind("HomePointList", form, nx_current(), "on_homepoint_rec_refresh")
    databinder:DelTableBind("DongHaiHomePointList", form, nx_current(), "on_homepoint_rec_refresh")
  end
  form.Visible = false
  form:Close()
end
function ok_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function close_btn_click(self)
  local form = self.ParentForm
  form:Close()
end
function rep_btn_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local sel_hp = form.sel_hp
  local sel_sence_hp = form.sel_sence_hp
  if sel_hp == "" or sel_hp == nil or sel_sence_hp == "" or sel_sence_hp == nil then
    return
  end
  if IsExistRecordHomePoint(sel_sence_hp) then
    ShowTipDialog(nx_widestr(util_text("ui_reset_limit")))
    return
  end
  if not ShowTipDialog(nx_widestr(util_text("ui_changehomepoint2"))) then
    return
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_SET_HOMEPOINT), nx_int(6), sel_hp, sel_sence_hp)
end
function on_click_homepoint_btn(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if btn.hp_type == RECORD_HOMEPOINT then
    fresh_hp_btn(form.hp_record_grp, form.record_count)
    form.sel_hp = btn.hpid
    form.sel_item = btn.index
  else
    fresh_hp_btn(form.hp_sence_grp, form.sence_count)
    form.sel_sence_hp = btn.hpid
  end
  btn.NormalImage = SelHomePoint
  btn.FocusImage = SelHomePoint
end
function ShowHomePointRepForm(Type, domain_info)
  local form = util_get_form("form_stage_main\\form_homepoint\\form_home_point_rep", true)
  if not nx_is_valid(form) then
    return
  end
  form.Type = Type
  form.sel_item = 0
  guild_domain_list = util_split_string(domain_info, ",")
  ShowExistRecordHomePoint(form, Type)
  ShowExistScenceHomePoint(form, Type)
  util_auto_show_hide_form("form_stage_main\\form_homepoint\\form_home_point_rep")
end
function create_item_homepoint(hp_grp, index, photo, hp_name, Type, hp_info)
  if not nx_is_valid(hp_grp) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local grp = gui:Create("GroupBox")
  grp.BackColor = "0,0,0,0"
  grp.LineColor = "0,0,0,0"
  grp.Width = hp_grp.Width
  grp.Height = 30
  grp.Top = 10 + index * 30
  grp.Name = nx_string("grp" .. nx_string(index))
  local hp_button = gui:Create("Button")
  hp_button.DrawMode = "Expand"
  hp_button.Height = 30
  hp_button.Width = hp_grp.Width
  hp_button.NormalImage = NormalImage
  hp_button.FocusImage = FocusImage
  hp_button.PushImage = PushImage
  hp_button.Name = nx_string("btn_hp_rep" .. nx_string(index))
  nx_bind_script(hp_button, nx_current())
  nx_callback(hp_button, "on_click", "on_click_homepoint_btn")
  if Type == RECORD_HOMEPOINT then
    nx_callback(hp_button, "on_get_capture", "on_get_capture")
    nx_callback(hp_button, "on_lost_capture", "on_lost_capture")
  end
  local size = table.getn(hp_info)
  if 0 < size then
    hp_button.hpid = hp_info[HP_ID]
    hp_button.des = hp_info[HP_DES]
    hp_button.name = hp_info[HP_NAME]
    hp_button.senceid = hp_info[HP_SENCE_NO]
    hp_button.photo = hp_info[HP_PHOTO]
    hp_button.x = hp_info[HP_POS][1]
    hp_button.y = hp_info[HP_POS][2]
    hp_button.z = hp_info[HP_POS][3]
    hp_button.hp_flag = 1
  else
    hp_button.hp_flag = 0
  end
  hp_button.hp_type = Type
  hp_button.index = index
  if hp_name == "" or hp_name == nil then
    hp_button.iskuong = true
  else
    hp_button.iskuong = false
  end
  grp:Add(hp_button)
  local label_photo = gui:Create("Label")
  label_photo.Left = 10
  label_photo.Top = 8
  label_photo.Width = 24
  label_photo.Height = 14
  label_photo.DrawMode = "FitWindow"
  label_photo.BackImage = nx_string(photo)
  label_photo.AutoSize = true
  grp:Add(label_photo)
  local label_hp_name = gui:Create("Label")
  label_hp_name.Left = 36
  label_hp_name.Top = 6
  label_hp_name.Width = 60
  label_hp_name.Height = 16
  label_hp_name.Font = "font_btn"
  label_hp_name.ForeColor = "255,255,255,255"
  if 0 < size then
    label_hp_name.Text = nx_widestr(util_text(hp_info[HP_NAME]))
  end
  grp:Add(label_hp_name)
  hp_grp:Add(grp)
end
function ShowExistRecordHomePoint(form, Type)
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local nCount = client_player:GetRecordRows(HomePointList)
  if nx_int(nCount) <= nx_int(0) then
    return
  end
  form.hp_record_grp:DeleteAll()
  form.record_count = 0
  for index = 0, nCount - 1 do
    local hp_id = client_player:QueryRecord(HomePointList, index, 0)
    local bRet, hp_info = GetHomePointFromHPid(hp_id)
    if bRet == true then
      local hp_type = get_hp_type(hp_info[HP_TYPE])
      local seltype = get_hp_type(Type)
      if nx_int(seltype) == nx_int(hp_type) then
        Create_Record_HomePoint(form.hp_record_grp, form.record_count, hp_info)
        form.record_count = form.record_count + 1
      end
    end
  end
  init_select_btn(form, SHOW_TYPE_HOMEPOINT)
end
function ShowExistScenceHomePoint(form, Type)
  local client = nx_value("game_client")
  local scene = client:GetScene()
  local scene_id = scene:QueryProp("Resource")
  local index = 0
  local nCount = GetSenceHomePointCount()
  if nCount < 0 then
    return
  end
  form.hp_sence_grp:DeleteAll()
  form.sence_count = 0
  for i = 0, nCount - 1 do
    local bRet, hp_info = GetHomePointFromIndexNo(i)
    local senceID = get_scene_name(nx_int(hp_info[HP_SENCE_NO]))
    local seltype = get_hp_type(Type)
    local hp_type = get_hp_type(hp_info[HP_TYPE])
    if nx_string(senceID) == nx_string(scene_id) and IsSchoolHomePoint(hp_info) and IsOwnGuildHomePoint(hp_info) and nx_int(seltype) == nx_int(hp_type) then
      Create_Sence_HomePoint(form.hp_sence_grp, index, hp_info)
      index = index + 1
    end
  end
  form.sence_count = index
  init_select_btn(form, SHOW_TYPE_SENCE_HOMEPOINT)
end
function Create_Sence_HomePoint(hp_grp, index, hp_info)
  local Photo = Get_Recortd_HpPhoto(hp_info[HP_TYPE])
  create_item_homepoint(hp_grp, index, Photo, hp_info[HP_NAME], SENCE_HOMEPOINT, hp_info)
end
function Create_Record_HomePoint(hp_grp, index, hp_info, script)
  local Photo = Get_Recortd_HpPhoto(hp_info[HP_TYPE])
  create_item_homepoint(hp_grp, index, Photo, hp_info[HP_NAME], RECORD_HOMEPOINT, hp_info)
end
function IsOwnGuildHomePoint(hp_info)
  if hp_info[HP_TYPE] ~= Guild_HomePoint then
    return true
  end
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return false
  end
  local guild_name = client_player:QueryProp("GuildName")
  if guild_name == "" or guild_name == nil then
    return false
  end
  local nCount = table.getn(guild_domain_list)
  if nCount == 0 then
    return false
  end
  for i = 1, nCount do
    if nx_int(guild_domain_list[i]) == nx_int(hp_info[HP_AREA]) then
      return true
    end
  end
  return false
end
function init_select_btn(form, show_type)
  local index = 0
  if show_type == SHOW_TYPE_HOMEPOINT then
    hp_grp = form.hp_record_grp
    index = form.sel_item
  else
    hp_grp = form.hp_sence_grp
  end
  local sel_btn = "btn_hp_rep" .. nx_string(index)
  local sel_grp_name = "grp" .. nx_string(index)
  local grp = hp_grp:Find(sel_grp_name)
  if not nx_is_valid(grp) then
    return
  end
  local hp_btn = grp:Find(sel_btn)
  if nx_is_valid(hp_btn) then
    hp_btn.NormalImage = SelHomePoint
    hp_btn.FocusImage = SelHomePoint
    local photo = hp_btn.photo
    local des = hp_btn.des
    local name = hp_btn.name
    if show_type == RECORD_HOMEPOINT then
      form.sel_hp = hp_btn.hpid
      form.sel_item = hp_btn.index
    else
      form.sel_sence_hp = hp_btn.hpid
      form.sel_item = hp_btn.index
    end
  end
end
function fresh_hp_btn(hp_grp, nCount)
  for i = 0, nCount do
    local grp = hp_grp:Find("grp" .. nx_string(i))
    if nx_is_valid(grp) then
      local hp_btn = grp:Find("btn_hp_rep" .. nx_string(i))
      if nx_is_valid(hp_btn) then
        hp_btn.NormalImage = NormalImage
        hp_btn.FocusImage = FocusImage
      end
    end
  end
end
function on_homepoint_rec_refresh(form, recordname, optype, row, clomn)
  if optype == "update" or optype == "del" then
    ShowExistRecordHomePoint(form, form.Type)
  end
end
function on_get_capture(btn)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local hpid = btn.hpid
  if "" == hpid or nil == hpid then
    return
  end
  local bRet, hp_info = GetHomePointFromHPid(hpid)
  if not bRet then
    return
  end
  gui.TextManager:Format_SetIDName("ui_scenehomepoint")
  gui.TextManager:Format_AddParam("ui_scene_" .. nx_string(nx_int(hp_info[HP_SENCE_NO])))
  local text = nx_widestr(gui.TextManager:Format_GetText())
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), btn.AbsLeft + 5, btn.AbsTop + 5, 0, btn.ParentForm)
end
function on_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
