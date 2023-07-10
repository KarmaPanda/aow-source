require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
local MAX_DISTANCE = 15
function main_form_init(self)
  self.Fixed = false
  self.type = 0
  self.cg_id = 0
  self.players = ""
  self.npc = nx_null()
  self.fresh_time = os.time()
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  nx_execute(FORM_TIGUAN_GO, "show_tiguan_go", form.type, form.cg_id, form.npc)
  form:Close()
end
function on_btn_fresh_click(self)
  local form = self.ParentForm
  local fresh_time = os.time()
  local time = os.difftime(fresh_time, form.fresh_time)
  if 3 < time then
    nx_execute("custom_sender", "custom_get_tiguan_team_state")
    form.fresh_time = fresh_time
  end
end
function show_tiguan_cdt(form, cg_id)
  local gui = nx_value("gui")
  local cdt_mgr = nx_value("ConditionManager")
  if not nx_is_valid(cdt_mgr) then
    return 0
  end
  form.mltbox_cdt:Clear()
  local sharecgini = nx_execute("util_functions", "get_ini", SHARE_CHANGGUAN_INI)
  if not nx_is_valid(sharecgini) then
    return 0
  end
  local index = sharecgini:FindSectionIndex(nx_string(cg_id))
  if index < 0 then
    return 0
  end
  local condition = sharecgini:ReadString(index, "MemberConditionID", "")
  local minplayer = sharecgini:ReadString(index, "MinPlayerCount", "")
  local maxplayer = sharecgini:ReadString(index, "MaxPlayerCount", "")
  local cdt_tab = util_split_string(nx_string(condition), ";")
  for i = 1, table.getn(cdt_tab) do
    if cdt_tab[i] ~= "" then
      local cdt_desc = gui.TextManager:GetText(nx_string(cdt_mgr:GetConditionDesc(nx_int(cdt_tab[i]))))
      local len = string.len(nx_string(cdt_desc))
      local fmt = "%" .. nx_string(nx_int((48 + len) / 4)) .. "s"
      local text = ""
      text = string.format(fmt, text)
      form.mltbox_cdt:AddHtmlText(nx_widestr(text) .. cdt_desc, -1)
    end
  end
  local playercount = gui.TextManager:GetFormatText("ui_tiguan_players_const", nx_int(minplayer))
  if minplayer ~= maxplayer then
    playercount = gui.TextManager:GetFormatText("ui_tiguan_players_minmax", nx_int(minplayer), nx_int(maxplayer))
  end
  local len = string.len(nx_string(playercount))
  local fmt = "%" .. nx_string(nx_int((48 + len) / 4)) .. "s"
  local text = ""
  text = string.format(fmt, text)
  form.mltbox_cdt:AddHtmlText(nx_widestr(text) .. playercount, -1)
  form.mltbox_zhanshu:Clear()
  local zhanshu_str = gui.TextManager:GetText("ui_tiguan_zhanshu_" .. nx_string(cg_id))
  form.mltbox_zhanshu:AddHtmlText(nx_widestr(zhanshu_str), -1)
end
function show_team_info(form, ...)
  local gui = nx_value("gui")
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return 0
  end
  if table.getn(arg) % 3 ~= 0 then
    return 0
  end
  local player_count = table.getn(arg) / 3
  for i = 1, ENTER_GUAN_PLAY_COUNT do
    local gbox_player = form.gbox_player:Find("gbox_player_" .. nx_string(i))
    if not nx_is_valid(gbox_player) then
      return 0
    end
    local lbl_photo = gbox_player:Find("lbl_photo_" .. nx_string(i))
    local lbl_playname = gbox_player:Find("lbl_playname_" .. nx_string(i))
    local lbl_state = gbox_player:Find("lbl_state_" .. nx_string(i))
    if not (nx_is_valid(lbl_photo) and nx_is_valid(lbl_playname)) or not nx_is_valid(lbl_state) then
      return 0
    end
    if i <= player_count then
      local name = nx_widestr(arg[i * 3 - 2])
      local photo = nx_string(arg[i * 3 - 1])
      local can_in = nx_number(arg[i * 3])
      lbl_photo.BackImage = photo
      lbl_playname.Text = name
      lbl_state.Text = nx_widestr(gui.TextManager:GetText(ENTER_GUAN_CDT_STATE[can_in][1]))
      lbl_state.ForeColor = ENTER_GUAN_CDT_STATE[can_in][2]
      gbox_player.BlendAlpha = 255
    else
      lbl_photo.BackImage = nx_string("")
      lbl_playname.Text = nx_widestr("")
      lbl_state.Text = nx_widestr("")
      gbox_player.BlendAlpha = 50
    end
  end
end
function show_tiguan_ready(type, cg_id, npc, ...)
  local gui = nx_value("gui")
  if nx_number(type) == ENTER_GUAN_INIT then
    local form = util_get_form(FORM_TIGUAN_GO, false)
    if nx_is_valid(form) then
      return 0
    end
    form = util_get_form(FORM_TIGUAN_READY, false)
    if nx_is_valid(form) then
      show_team_info(form, unpack(arg))
      return 0
    end
    form = util_get_form(FORM_TIGUAN_READY, true)
    if not nx_is_valid(form) then
      return 0
    end
    form.npc = npc
    form.type = type
    form.cg_id = cg_id
    show_tiguan_cdt(form, cg_id)
    show_team_info(form, unpack(arg))
    nx_execute("util_gui", "util_show_form", FORM_TIGUAN_READY, true)
    if nx_running(nx_current(), "form_talk_tick") then
      nx_kill(nx_current(), "form_talk_tick")
    end
    nx_execute(nx_current(), "form_talk_tick")
  elseif ENTER_GUAN_TALK == nx_number(type) then
    nx_execute(FORM_TIGUAN_TALK, "show_tiguan_talk", npc, unpack(arg))
  else
    local form = util_get_form(FORM_TIGUAN_READY, false)
    if nx_is_valid(form) then
      form:Close()
    end
    nx_execute(FORM_TIGUAN_GO, "show_tiguan_go", type, cg_id, npc, unpack(arg))
  end
end
function form_talk_tick()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local form = nx_value(FORM_TIGUAN_READY)
  if not nx_is_valid(form) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npc))
  if not nx_is_valid(visual_npc) then
    return
  end
  while true do
    local sec = nx_pause(1)
    if not nx_is_valid(form) then
      break
    end
    if not nx_is_valid(visual_npc) then
      break
    end
    local dest_x = visual_player.PositionX
    local dest_z = visual_player.PositionZ
    local sx = dest_x - visual_npc.PositionX
    local sz = dest_z - visual_npc.PositionZ
    local distance = math.sqrt(sx * sx + sz * sz)
    if tonumber(distance) > tonumber(MAX_DISTANCE) then
      if nx_is_valid(form) then
        form:Close()
      end
      break
    end
  end
end
