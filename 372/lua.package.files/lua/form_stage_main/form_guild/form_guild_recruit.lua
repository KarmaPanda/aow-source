require("util_gui")
require("share\\client_custom_define")
require("form_stage_main\\form_hire_shop\\form_hire_shop_price")
require("form_stage_main\\form_hire_shop\\form_hire_shop_additem")
local strRecruitForm = "form_stage_main\\form_guild\\form_guild_recruit"
local SUB_CUSTOMMSG_REQUEST_RECRUIT_NPC = 72
local OPT_EMPLOY_RECRUIT = 0
local OPT_MODIFY_RECRUIT = 1
local OPT_APPLY_RECRUIT = 2
local FORM_EMPLOY = 0
local FORM_SETTING = 1
local FORM_APPLY_CONFIRM = 2
local FORM_CLOSE = 3
local table_ps = {
  "ui_guild_zhaomu_text01",
  "ui_guild_zhaomu_text02",
  "ui_guild_zhaomu_text03"
}
function on_recv_recruit_msg(...)
  local form_type = nx_int(arg[1])
  local npc = arg[2]
  if form_type == nx_int(FORM_EMPLOY) or form_type == nx_int(FORM_SETTING) then
    local form = nx_value(nx_string(strRecruitForm))
    if nx_is_valid(form) then
      nx_destroy(form)
      nx_set_value(nx_string(strRecruitForm), nx_null())
    end
    form = nx_execute("util_gui", "util_get_form", nx_string(strRecruitForm), true, false)
    if not nx_is_valid(form) then
      return 0
    end
    nx_set_value(nx_string(strRecruitForm), form)
    form.func_opt = nx_int(form_type)
    form.npc_id = npc
    form:Show()
  elseif form_type == nx_int(FORM_APPLY_CONFIRM) then
    nx_execute(strRecruitForm, "ApplyConfirm", npc)
  elseif form_type == nx_int(FORM_CLOSE) then
    local form = nx_value(nx_string(strRecruitForm))
    if nx_is_valid(form) then
      form:Close()
    end
  else
    return 0
  end
end
function main_form_init(form)
  form.Fixed = false
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.Left = (gui.Width - form.Width) / 2
  form.Top = (gui.Height - form.Height) / 2
  local game_client = nx_value("game_client")
  local ident = nx_string(form.npc_id)
  local npc = game_client:GetSceneObj(ident)
  if not nx_is_valid(npc) then
    return false
  end
  form.combobox_item.DropListBox:ClearString()
  form.combobox_item.OnlySelect = true
  form.combobox_item.Text = gui.TextManager:GetText("guild_recruit_tool_01")
  form.combobox_item.DropListBox:AddString(gui.TextManager:GetText("guild_recruit_tool_01"))
  form.combobox_item.DropListBox:AddString(gui.TextManager:GetText("guild_recruit_tool_02"))
  form.combobox_item.DropListBox.SelectIndex = 0
  init_ps_drop_list(form)
  form.ps_id = 1
  local cryout = npc:QueryProp("CryOut")
  form.ps_id = nx_number(cryout)
  if 0 >= form.ps_id or form.ps_id > table.getn(table_ps) then
    form.ps_id = 1
  end
  local ps = util_text(table_ps[form.ps_id])
  form.ipt_cryout.Text = nx_widestr(ps)
  form.btn_moidfy.Text = gui.TextManager:GetText("ui_guild_recruit_3")
  form.btn_start_stop.Text = gui.TextManager:GetText("ui_guild_recruit_5")
  if form.func_opt == FORM_EMPLOY then
    form.btn_moidfy.Enabled = false
  else
    if form.func_opt == FORM_SETTING then
      form.combobox_item.Enabled = false
      form.btn_start_stop.Enabled = false
    else
    end
  end
  return 1
end
function on_main_form_close(form)
  nx_destroy(form)
  nx_set_value(nx_string(strRecruitForm), nx_null())
end
function on_btn_moidfy_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local cry_text = nx_widestr(form.ps_id)
  cry_text = DeleteFontColor(nx_string(cry_text))
  local CheckWords = nx_value("CheckWords")
  local filter_crytext = CheckWords:CleanWords(nx_widestr(cry_text))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_RECRUIT_NPC), form.npc_id, OPT_MODIFY_RECRUIT, nx_widestr(filter_crytext))
  return 1
end
function on_btn_start_stop_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  local cry_text = nx_widestr(form.ps_id)
  local item_opt = form.combobox_item.DropListBox.SelectIndex
  cry_text = DeleteFontColor(nx_string(cry_text))
  local CheckWords = nx_value("CheckWords")
  local filter_crytext = CheckWords:CleanWords(nx_widestr(cry_text))
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_RECRUIT_NPC), form.npc_id, OPT_EMPLOY_RECRUIT, nx_widestr(filter_crytext), item_opt)
  return 1
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form:Close()
  return 1
end
function ApplyConfirm(npc_id)
  local game_client = nx_value("game_client")
  local ident = nx_string(npc_id)
  local npcObj = game_client:GetSceneObj(ident)
  if not nx_is_valid(npcObj) then
    return false
  end
  local npcGuild = npcObj:QueryProp("Guild")
  if not show_confirm_info("ui_guild_recruit_10", nx_widestr(npcGuild)) then
    return false
  end
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return false
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_GUILD), nx_int(SUB_CUSTOMMSG_REQUEST_RECRUIT_NPC), npc_id, OPT_APPLY_RECRUIT)
  return true
end
function init_ps_drop_list(form)
  local cb = form.ipt_cryout
  if not nx_is_valid(cb) then
    return
  end
  cb.OnlySelect = true
  cb.DropListBox:ClearString()
  local count = table.getn(table_ps)
  for i = 1, count do
    local text = util_text(table_ps[i])
    cb.DropListBox:AddString(nx_widestr(text))
  end
  cb.Text = nx_widestr("")
end
function on_ipt_cryout_selected(cb)
  local form = cb.ParentForm
  if not nx_is_valid(form) then
    return
  end
  form.ps = cb.Text
  form.ps_id = cb.DropListBox.SelectIndex + 1
end
