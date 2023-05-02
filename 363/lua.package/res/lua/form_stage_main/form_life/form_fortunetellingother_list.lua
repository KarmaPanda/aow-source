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
local answer
local castmoney = 0
local FortunetellingRank = 1
local CurSelectGrade = 1
local FortunetellingTipsText = {
  "tips_gua_1",
  "tips_gua_2",
  "tips_gua_3",
  "tips_gua_4",
  "tips_gua_5",
  "tips_gua_6",
  "tips_gua_7",
  "tips_gua_8",
  "tips_gua_9",
  "tips_gua_10"
}
local LblTipsText = {
  btn_1 = "tips_guatu_1",
  btn_2 = "tips_guatu_2",
  btn_3 = "tips_guatu_3"
}
local Primary_Image = "gui\\common\\button\\btn_normal2_on.png"
local Select_Image = "gui\\common\\button\\btn_normal2_down.png"
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(form)
  nx_destroy(form)
end
function openform(target, rank)
  util_auto_show_hide_form("form_stage_main\\form_life\\form_fortunetellingother_list")
  local form = nx_value("form_stage_main\\form_life\\form_fortunetellingother_list")
  if not nx_is_valid(form) then
    return
  end
  local gui = nx_value("gui")
  answer = target
  FortunetellingRank = rank
  local level = 1
  for i = 1, 3 do
    local temp = i
    local btn = form.groupbox_1:Find(nx_string(temp))
    local tip_head = form.groupbox_1:Find("btn_" .. nx_string(i))
    if i <= level then
      tip_head.Visible = true
      btn.Visible = true
      if temp <= FortunetellingRank then
        btn.Enabled = true
      else
        btn.Enabled = false
      end
    else
      tip_head.Visible = false
      btn.Visible = false
    end
  end
  form.mltbox_1:Clear()
  form.mltbox_1:AddHtmlText(nx_widestr(gui.TextManager:GetText("ui_sh_gsjm")), nx_int(-1))
  change_form_position(form, level)
  CurSelectGrade = 1
  local select_btn = form.groupbox_1:Find(nx_string(CurSelectGrade))
  select_btn.NormalImage = Select_Image
  local file_name = "share\\Life\\fortunetelling.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
end
function change_form_position(form, level)
  level = nx_int(level)
  if level >= nx_int(3) or level <= nx_int(0) then
    return
  end
  local delat = form.groupbox_1.Height - form.groupbox_1.Height * level / 3
  form.groupbox_1.Height = form.groupbox_1.Height * level / 3
  form.groupbox_2.AbsTop = form.groupbox_2.AbsTop - delat
  form.Height = form.Height - delat
  form.lbl_9.AbsTop = form.groupbox_1.Height + form.groupbox_1.AbsTop
  form.lbl_12.AbsTop = form.groupbox_1.AbsTop
  form.lbl_12.Height = 55 + form.groupbox_1.Height
end
function on_btn_click(btn)
  local form = btn.ParentForm.ParentForm
  local select_btn = form.groupbox_1:Find(nx_string(CurSelectGrade))
  select_btn.NormalImage = Primary_Image
  CurSelectGrade = nx_number(btn.Name)
  local select_btn = form.groupbox_1:Find(nx_string(CurSelectGrade))
  select_btn.NormalImage = Select_Image
end
function need_fortunetelling(form, rank, money_type)
  local game_client = nx_value("game_client")
  local target_obj = game_client:GetSceneObj(nx_string(answer))
  if not nx_is_valid(target_obj) then
    return
  end
  local type = target_obj:QueryProp("Type")
  if TYPE_PLAYER ~= tonumber(type) then
    return
  end
  local name = target_obj:QueryProp("Name")
  local file_name = "share\\Life\\fortunetelling.ini"
  local IniManager = nx_value("IniManager")
  local ini = IniManager:GetIniDocument(file_name)
  local price = nx_int(form.ipt_1.Text) * 1000000 + nx_int(form.ipt_2.Text) * 1000 + nx_int(form.ipt_3.Text)
  local money = nx_int(price) + ini:ReadInteger(rank - 1, "Money", 0)
  local gold = ini:ReadInteger(rank - 1, "Gold", 0)
  local gui = nx_value("gui")
  local dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  gui.TextManager:Format_SetIDName("ui_sh_gsgq11")
  gui.TextManager:Format_AddParam(nx_int(price))
  local Text = gui.TextManager:Format_GetText()
  dialog.mltbox_info:AddHtmlText(Text, -1)
  dialog:ShowModal()
  local res = nx_wait_event(100000000, dialog, "confirm_return")
  if res == "ok" then
    request_fortunetellingother(form, name, rank, money_type)
  end
end
function request_fortunetellingother(form, name, rank, money_type)
  local game_client = nx_value("game_client")
  local visual_player = game_client:GetPlayer()
  local price = nx_int(form.ipt_1.Text) * 1000000 + nx_int(form.ipt_2.Text) * 1000 + nx_int(form.ipt_3.Text)
  nx_execute("custom_handler", "custom_sysinfo", 0, 0, 0, 1, nx_string("12521"), nx_widestr(name))
  nx_execute("custom_sender", "custom_request", REQUESTTYPE_FORTUNETELLINGOTHER, nx_widestr(name), nx_int(rank), nx_int(price), nx_int(money_type))
end
function on_btn_ok_click(btn)
  local money_type
  local form = btn.ParentForm
  if form.rbtn_unbind_money.Checked then
    money_type = 0
  else
    money_type = 1
  end
  need_fortunetelling(btn.ParentForm, FortunetellingRank, money_type)
  btn.ParentForm:Close()
end
function on_btn_close_click(btn)
  btn.ParentForm:Close()
end
function on_btn_get_capture(btn)
  local index = nx_number(btn.Name)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(FortunetellingTipsText[index]))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, btn.ParentForm)
end
function on_btn_lost_capture(btn)
  nx_execute("tips_game", "hide_tip", btn.ParentForm)
end
function on_tip_btn_get_capture(lbl)
  local gui = nx_value("gui")
  local text = gui.TextManager:GetFormatText(nx_string(LblTipsText[nx_string(lbl.Name)]))
  local x, y = gui:GetCursorPosition()
  nx_execute("tips_game", "show_text_tip", text, x, y, 0, lbl.ParentForm)
end
function on_tip_btn_lost_capture(lbl)
  nx_execute("tips_game", "hide_tip", lbl.ParentForm)
end
function get_money_format(money)
  local text = nx_widestr("")
  if money <= 0 then
    text = nx_widestr("0") .. nx_widestr(util_text("ui_bag_wen"))
    return text
  end
  local gold = money / 1000000
  gold = math.floor(gold)
  local silver = (money - gold * 1000000) / 1000
  local silver = math.floor(silver)
  local copper = money - silver * 1000 - gold * 1000000
  if gold ~= 0 then
    text = nx_widestr(gold) .. nx_widestr(util_text("ui_bag_ding"))
  end
  if silver ~= 0 then
    text = text .. nx_widestr(silver) .. nx_widestr(util_text("ui_bag_liang"))
  end
  if copper ~= 0 then
    text = text .. nx_widestr(copper) .. nx_widestr(util_text("ui_bag_wen"))
  end
  return text
end
