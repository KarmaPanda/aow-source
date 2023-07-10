require("custom_sender")
local LBL_TIAOZHAN_TEXT = {
  "ui_drtiguan_boss_1",
  "ui_drtiguan_boss_2",
  "ui_drtiguan_boss_3",
  "ui_drtiguan_boss_4",
  "ui_drtiguan_boss_5",
  "ui_drtiguan_boss_6",
  "ui_drtiguan_boss_7",
  "ui_drtiguan_boss_8",
  "ui_drtiguan_boss_9",
  "ui_drtiguan_boss_10",
  "ui_drtiguan_boss_11",
  "ui_drtiguan_boss_12",
  "ui_drtiguan_boss_13",
  "ui_drtiguan_boss_14",
  "ui_drtiguan_boss_15"
}
local TGC_C_SUBMSG_GAVEUP = 2
function init_form(self)
  self.Fixed = false
  self.ini = get_ini("share\\War\\tiguanchallenge.ini")
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  form.Visible = false
  nx_destroy(form)
end
function Init(arg1, arg2, arg3)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_battle", true)
  if nx_is_valid(form) then
    local ChallengeList = form.ini:ReadString(form.ini:FindSectionIndex(nx_string(arg1)), "ChallengeList", "")
    local Challenge, Count = ReadChallenge(ChallengeList)
    local text1 = ""
    local text2 = Challenge[arg2]
    local text3 = "ui_drtiguan_xiayizhan"
    local text4 = ""
    if arg2 < Count then
      text1 = LBL_TIAOZHAN_TEXT[arg2]
      SetTitle(form.lbl_2, text1, text2)
      text4 = Challenge[arg3]
      SetTitle(form.lbl_3, text3, text4)
    elseif arg2 == Count then
      text1 = "ui_drtiguan_zuizhongzhan"
      SetTitle(form.lbl_2, text1, text2)
      SetTitle(form.lbl_3, text3, text2)
    end
    form.Visible = true
    form:Show()
  end
end
function SetFormState(state)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_battle", false)
  if nx_is_valid(form) then
    if state == 0 then
      form.Visible = false
    elseif state == 1 then
      form.Visible = true
    elseif state == 2 then
      form:Close()
    end
  end
end
function SetTitle(lbl, text1, text2)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    lbl.Text = gui.TextManager:GetText(text1) .. nx_widestr(" ") .. gui.TextManager:GetText(text2)
  end
end
function on_btn_1_click(btn)
  custom_tiguanchallenge(TGC_C_SUBMSG_GAVEUP)
end
function ReadChallenge(str)
  local tbl = util_split_string(str, ";")
  local count = 0
  for i, v in ipairs(tbl) do
    tbl[i] = util_split_string(tbl[i], "/")[1]
    count = i
  end
  return tbl, count
end
