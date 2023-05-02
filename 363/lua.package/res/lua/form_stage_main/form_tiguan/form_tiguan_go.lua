require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
local MAX_DISTANCE = 15
local npc_tab = {}
function main_form_init(self)
  self.Fixed = false
  self.npc = nx_null()
  self.BossNum = 0
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  local common_execute = nx_value("common_execute")
  common_execute:RemoveExecute("random_time", self)
  common_execute:RemoveExecute("random_anim", self)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(nx_current(), "close_tiguan_go", self)
  end
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
  local gp_list = nx_value("tiguan_gp_list")
  if nx_is_valid(gp_list) then
    gp_list:ClearChild()
  end
  nx_destroy(self)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_btn_step_click(self)
  local form = self.ParentForm
  if nx_number(form.type) == ENTER_GUAN_INIT then
    nx_execute("custom_sender", "custom_tiguan_random_npc", "0")
    self.Enabled = false
  elseif nx_number(form.type) == ENTER_GUAN_STAR then
    nx_execute("custom_sender", "custom_tiguan_random_npc", "1")
    self.Enabled = false
  end
end
function show_select_group(form, child)
  local names = child.names
  local names_tab = util_split_string(names, "/")
  local gbx_tiguan = form.gbox_enter:Find("gbx_tiguan_" .. nx_string(form.cg_id))
  if not nx_is_valid(gbx_tiguan) then
    return 0
  end
  for j = 1, form.BossNum do
    local gbxmessage = gbx_tiguan:Find("gbx_message_" .. nx_string(form.cg_id) .. "_" .. nx_string(j))
    if nx_is_valid(gbxmessage) then
      local cbtn = gbxmessage:Find("cbtn_bg_" .. nx_string(form.cg_id) .. "_" .. nx_string(j))
      if nx_is_valid(cbtn) then
        cbtn.Checked = false
      end
    end
  end
  local npcids_tab = util_split_string(child.npc_id, "/")
  for i = 1, table.getn(npcids_tab) do
    local npc_id = npc_tab[npcids_tab[i]]
    local gbx_message = gbx_tiguan:Find("gbx_message_" .. nx_string(form.cg_id) .. "_" .. nx_string(npc_id))
    if not nx_is_valid(gbx_message) then
      break
    end
    local cbtn_bg = gbx_message:Find("cbtn_bg_" .. nx_string(form.cg_id) .. "_" .. nx_string(npc_id))
    if nx_is_valid(cbtn_bg) then
      cbtn_bg.Checked = true
    end
  end
end
function load_group_info(form, cg_id)
  local gui = nx_value("gui")
  local itemQuery = nx_value("ItemQuery")
  if not nx_is_valid(itemQuery) then
    return 0
  end
  local gp_list = nx_call("util_gui", "get_global_arraylist", "tiguan_gp_list")
  gp_list:ClearChild()
  local ui_id = "ui_tiguan_name_" .. nx_string(cg_id)
  form.lbl_cgname.Text = gui.TextManager:GetText(ui_id)
  local changguanini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(changguanini) then
    return 0
  end
  local index = changguanini:FindSectionIndex(nx_string(cg_id))
  if index < 0 then
    return 0
  end
  local grps = changguanini:GetItemValueList(index, "Group")
  for i = 1, table.getn(grps) do
    local data_tab = util_split_string(nx_string(grps[i]), ",")
    if table.getn(data_tab) ~= 2 then
      return 0
    end
    local grp_id = nx_string(data_tab[1])
    local npc_id = nx_string(data_tab[2])
    local names = nx_widestr("")
    local npc_tab = util_split_string(npc_id, "/")
    for j = 1, table.getn(npc_tab) do
      local name = gui.TextManager:GetText("ui_tiguan_npcname_" .. npc_tab[j])
      if j == 1 then
        names = name
      else
        names = names .. nx_widestr("/") .. name
      end
    end
    local child = gp_list:CreateChild(nx_string(i))
    if nx_is_valid(child) then
      child.grp_id = grp_id
      child.npc_id = npc_id
      child.names = names
    end
  end
end
function show_all_npc(form, cg_id)
  local gui = nx_value("gui")
  for i = 1, GUAN_COUNT_MAX do
    local gbx_tiguan = form.gbox_enter:Find("gbx_tiguan_" .. nx_string(i))
    if nx_is_valid(gbx_tiguan) then
      gbx_tiguan.Visible = false
    end
  end
  local npcini = nx_execute("util_functions", "get_ini", CHANGGUAN_UI_INI)
  if not nx_is_valid(npcini) then
    return 0
  end
  local guan_index = npcini:FindSectionIndex(nx_string(cg_id))
  if guan_index < 0 then
    return 0
  end
  local npc_table = npcini:GetItemValueList(guan_index, "Npc")
  local gbx_tiguan = form.gbox_enter:Find("gbx_tiguan_" .. nx_string(cg_id))
  if not nx_is_valid(gbx_tiguan) then
    return 0
  end
  gbx_tiguan.Visible = true
  form.BossNum = table.getn(npc_table)
  for i = 1, table.getn(npc_table) do
    local data_tab = util_split_string(nx_string(npc_table[i]), ",")
    if table.getn(data_tab) ~= 3 then
      return 0
    end
    local npc_id = data_tab[1]
    local npc_index = data_tab[2]
    npc_tab[nx_string(npc_id)] = npc_index
    local npc_name = gui.TextManager:GetText("ui_tiguan_npcname_" .. npc_id)
    local npc_shenfen = gui.TextManager:GetText("ui_tiguan_npctitle_" .. nx_string(cg_id) .. "_" .. npc_index)
    local gbx_message = gbx_tiguan:Find("gbx_message_" .. nx_string(cg_id) .. "_" .. nx_string(npc_index))
    if not nx_is_valid(gbx_message) then
      break
    end
    local cbtn_bg = gbx_message:Find("cbtn_bg_" .. nx_string(cg_id) .. "_" .. nx_string(npc_index))
    local lbl_name = gbx_message:Find("lbl_name_" .. nx_string(cg_id) .. "_" .. nx_string(npc_index))
    local lbl_shenfen = gbx_message:Find("lbl_shenfen_" .. nx_string(cg_id) .. "_" .. nx_string(npc_index))
    if not nx_is_valid(cbtn_bg) then
      break
    end
    if not nx_is_valid(lbl_shenfen) then
      break
    end
    if not nx_is_valid(lbl_name) then
      break
    end
    lbl_name.Text = nx_widestr(npc_name)
    cbtn_bg.Checked = false
    lbl_shenfen.Text = nx_widestr(npc_shenfen)
  end
end
function show_tiguan_go(type, cg_id, npc, ...)
  local gui = nx_value("gui")
  if nx_number(type) == ENTER_GUAN_INIT then
    local form = util_get_form(FORM_TIGUAN_GO, true)
    if not nx_is_valid(form) then
      return 0
    end
    form.npc = npc
    form.type = type
    form.cg_id = cg_id
    form.btn_step.Enabled = true
    form.btn_step.Visible = true
    form.btn_step.Text = gui.TextManager:GetText(nx_string(BTN_TEXT[1]))
    form.lbl_step.Visible = false
    load_group_info(form, cg_id)
    show_all_npc(form, cg_id)
    nx_execute("util_gui", "util_show_form", FORM_TIGUAN_GO, true)
    if nx_running(nx_current(), "form_talk_tick") then
      nx_kill(nx_current(), "form_talk_tick")
    end
    nx_execute(nx_current(), "form_talk_tick")
  elseif nx_number(type) == ENTER_GUAN_STAR then
    local form = util_get_form(FORM_TIGUAN_GO, true)
    if not nx_is_valid(form) then
      return 0
    end
    form.npc = npc
    form.type = type
    form.cg_id = cg_id
    local is_team_caption = check_is_TeamCaption()
    if not is_team_caption then
      load_group_info(form, cg_id)
      show_all_npc(form, cg_id)
      form.btn_step.Visible = false
      form.lbl_step.Text = gui.TextManager:GetText(nx_string(LBL_TEXT[1]))
      form.lbl_step.Visible = true
    else
      form.btn_step.Enabled = true
      form.btn_step.Text = gui.TextManager:GetText(nx_string(BTN_TEXT[2]))
    end
    nx_execute("util_gui", "util_show_form", FORM_TIGUAN_GO, true)
    if nx_running(nx_current(), "form_talk_tick") then
      nx_kill(nx_current(), "form_talk_tick")
    end
    nx_execute(nx_current(), "form_talk_tick")
    form.btn_close.Enabled = false
    form.lbl_time.Text = nx_widestr(nx_string(RANDOM_NPC_TIME))
    form.lbl_time.Visible = true
    local common_execute = nx_value("common_execute")
    common_execute:AddExecute("random_time", form, nx_float(1), nx_float(RANDOM_NPC_TIME), is_team_caption)
    common_execute:AddExecute("random_anim", form, nx_float(0.2), nx_int(form.BossNum), nx_int(form.cg_id))
  elseif nx_number(type) == ENTER_GUAN_STOP then
    if 1 > table.getn(arg) then
      return 0
    end
    local form = util_get_form(FORM_TIGUAN_GO, false)
    if not nx_is_valid(form) then
      return 0
    end
    local common_execute = nx_value("common_execute")
    common_execute:RemoveExecute("random_time", form)
    common_execute:RemoveExecute("random_anim", form)
    form.lbl_time.Visible = false
    form.lbl_time.Text = nx_widestr("")
    form.type = type
    form.btn_close.Enabled = true
    form.btn_step.Visible = false
    form.lbl_step.Text = gui.TextManager:GetText(nx_string(LBL_TEXT[2]))
    form.lbl_step.Visible = true
    local gp_list = nx_value("tiguan_gp_list")
    if not nx_is_valid(gp_list) then
      return 0
    end
    local gp_table = gp_list:GetChildList()
    for i = 1, table.getn(gp_table) do
      local child = gp_table[i]
      if nx_string(child.grp_id) == nx_string(arg[1]) then
        show_select_group(form, child)
        break
      end
    end
    local timer = nx_value("timer_game")
    if nx_is_valid(timer) then
      timer:UnRegister(nx_current(), "close_tiguan_go", form)
      timer:Register(3000, 1, nx_current(), "close_tiguan_go", form, -1, -1)
    end
  elseif nx_number(type) == ENTER_GUAN_CLOSE then
    local form = util_get_form(FORM_TIGUAN_GO, false)
    if nx_is_valid(form) then
      local timer = nx_value("timer_game")
      if nx_is_valid(timer) then
        timer:UnRegister(nx_current(), "close_tiguan_go", form)
        timer:Register(2000, 1, nx_current(), "close_tiguan_go", form, -1, -1)
      end
    end
  end
end
function close_tiguan_go(form)
  if nx_is_valid(form) then
    form:Close()
  end
end
function form_talk_tick()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local form = nx_value(FORM_TIGUAN_GO)
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
function client_request_leave_tiguan()
  local text = ""
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    text = gui.TextManager:GetText("ui_tiguant_outnotice")
  end
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, nx_widestr(text))
  dialog:ShowModal()
  dialog.Left = (gui.Width - dialog.Width) / 2
  dialog.Top = (gui.Height - dialog.Height) / 2
  local result = nx_wait_event(100000000, dialog, "confirm_return")
  if "ok" == result then
    nx_execute("custom_sender", "custom_tiguan_request_leave")
  end
end
