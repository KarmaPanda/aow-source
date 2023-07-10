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
local TGC_C_SUBMSG_FIGHT = 0
local TGC_C_SUBMSG_LEAVE = 1
function init_form(self)
  self.Fixed = false
  self.ini = get_ini("share\\War\\tiguanchallenge.ini")
  self.select = 1
  self.count = 0
  self.highest = 1
end
function on_main_form_open(form)
end
function on_main_form_close(form)
  Restart(form)
  form.Visible = false
  nx_destroy(form)
end
function Restart(form)
  local groupbox = nx_null()
  for i = 1, form.count do
    groupbox = form.groupbox_cbtn:Find("groupbox_" .. nx_string(i))
    if nx_is_valid(groupbox) then
      groupbox:DeleteAll()
    end
  end
  form.select = 0
  form.count = 0
  form.highest = 0
  form.ScrollBar1.Maximum = 1
  form.ScrollBar1.Value = 0
end
function CreateCbtn(parent, id, name, enabled)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local cbtn = gui:Create("CheckButton")
    if nx_is_valid(cbtn) then
      cbtn.Name = "cbtn_" .. name
      cbtn.Left = 0
      cbtn.Top = 0
      cbtn.Width = 185
      cbtn.Height = 29
      cbtn.DrawMode = "Center"
      cbtn.NormalImage = "gui\\special\\tiguan\\cbtn_out.png"
      cbtn.FocusImage = "gui\\special\\tiguan\\cbtn_on.png"
      cbtn.PushImage = "gui\\special\\tiguan\\cbtn_down.png"
      cbtn.AutoSize = true
      if enabled == 0 then
        cbtn.Enabled = false
      elseif enabled == 1 then
        cbtn.Enabled = true
      end
      nx_bind_script(cbtn, nx_current())
      nx_callback(cbtn, "on_checked_changed", "on_cbtn_checked_changed")
      parent:Add(cbtn)
    end
  end
end
function CreateLbl(parent, id, text1, color1, text2, color2)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local lbl_tiaozhan = gui:Create("Label")
    if nx_is_valid(lbl_tiaozhan) then
      lbl_tiaozhan.Name = "lbl_" .. nx_string(2 * (id - 1) + 1)
      lbl_tiaozhan.Left = 33
      lbl_tiaozhan.Top = 1
      lbl_tiaozhan.Width = 52
      lbl_tiaozhan.Height = 28
      lbl_tiaozhan.Align = "Center"
      lbl_tiaozhan.Font = "font_name_tittle"
      lbl_tiaozhan.ForeColor = color1
      lbl_tiaozhan.Text = gui.TextManager:GetText(text1)
      parent:Add(lbl_tiaozhan)
    end
    local lbl_yingzhan = gui:Create("Label")
    if nx_is_valid(lbl_yingzhan) then
      lbl_yingzhan.Name = "lbl_" .. nx_string(2 * (id - 1) + 2)
      lbl_yingzhan.Left = 88
      lbl_yingzhan.Top = 1
      lbl_yingzhan.Width = 66
      lbl_yingzhan.Height = 28
      lbl_yingzhan.Align = "Center"
      lbl_yingzhan.Font = "font_name_tittle"
      lbl_yingzhan.ForeColor = color2
      lbl_yingzhan.Text = gui.TextManager:GetText(text2)
      parent:Add(lbl_yingzhan)
    end
  end
end
function CreateGroupBox(parent, id, name, enabled, text1, color1, text2, color2)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    local groupbox = gui:Create("GroupBox")
    if nx_is_valid(groupbox) then
      groupbox.Name = "groupbox_" .. nx_string(id)
      groupbox.Left = 12
      groupbox.Top = 12 + (id - 1) * 30
      groupbox.Width = 185
      groupbox.Height = 29
      groupbox.BackColor = "0,255,255,255"
      groupbox.NoFrame = true
      CreateCbtn(groupbox, id, name, enabled)
      CreateLbl(groupbox, id, text1, color1, text2, color2)
      if id <= 5 then
        groupbox.Visible = true
      else
        groupbox.Visible = false
      end
      parent:Add(groupbox)
    end
  end
end
function Init(arg1, arg2, ...)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_nobattle", true)
  if nx_is_valid(form) then
    local ChallengeList = form.ini:ReadString(form.ini:FindSectionIndex(nx_string(arg1)), "ChallengeList", "")
    local Challenge, Count = ReadChallenge(ChallengeList)
    form.count = Count
    form.highest = arg2
    local temp = Count - arg2 + 1
    local text1 = ""
    local text2 = ""
    local color1 = ""
    local color2 = ""
    local enabled = 0
    for i = 1, Count do
      if i == 1 then
        text1 = "ui_drtiguan_zuizhongzhan"
      else
        text1 = LBL_TIAOZHAN_TEXT[Count - i + 1]
      end
      text2 = Challenge[i]
      if i < temp then
        color1 = "255,111,108,101"
        color2 = "255,111,108,101"
      elseif i == temp then
        color1 = "255,255,255,255"
        color2 = "255,255,153,0"
        enabled = 1
      elseif i > temp then
        color1 = "255,255,255,255"
        color2 = "255,168,255,0"
        enabled = 1
      end
      CreateGroupBox(form.groupbox_cbtn, i, nx_string(Count - i + 1), enabled, text1, color1, text2, color2)
      SetTitle(form.lbl_title, text1, text2)
      if form.ScrollBar1.Maximum < i - 1 then
        form.ScrollBar1.Maximum = i - 1
      end
      form.Visible = true
      form:Show()
    end
  end
end
function SetFormState(state, highest)
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_nobattle", false)
  if nx_is_valid(form) then
    if state == 0 then
      form.Visible = false
    elseif state == 1 then
      SetCbtnLbl(form, highest)
      form.Visible = true
      form:Show()
    elseif state == 2 then
      form:Close()
    end
  end
end
function SetCbtnLbl(form, highest)
  SetCbtnEnabled(form, form.select, 0)
  if form.select < form.count then
    if highest > form.highest then
      if highest <= form.count then
        SetLblColor(form, highest, "255,255,255,255", "255,255,153,0")
      end
      form.highest = highest
    end
    if highest ~= 0 then
      SetLblColor(form, form.select, "255,255,255,255", "255,168,255,0")
      local temp = GetNext()
      SetCbtnEnabled(form, temp, 1)
      SetTitle2(form, temp)
      form.select = temp
    end
  elseif form.select == form.count and highest ~= 0 then
    SetLblColor(form, form.select, "255,255,255,255", "255,168,255,0")
  end
end
function SetCbtnEnabled(form, index, enabled)
  local groupbox_cbtn = form.groupbox_cbtn
  local id = form.count - index + 1
  local groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(id))
  if nx_is_valid(groupbox) then
    local cbtn = groupbox:Find("cbtn_" .. nx_string(index))
    if nx_is_valid(cbtn) then
      if enabled == 0 then
        cbtn.Enabled = false
      elseif enabled == 1 then
        cbtn.Enabled = true
      end
    end
  end
end
function SetLblColor(form, index, color1, color2)
  local groupbox_cbtn = form.groupbox_cbtn
  local id = form.count - index + 1
  local groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(id))
  if nx_is_valid(groupbox) then
    local lbl_tiaozhan = groupbox:Find("lbl_" .. nx_string(2 * (id - 1) + 1))
    if nx_is_valid(lbl_tiaozhan) then
      lbl_tiaozhan.ForeColor = color1
    end
    local lbl_yingzhan = groupbox:Find("lbl_" .. nx_string(2 * (id - 1) + 2))
    if nx_is_valid(lbl_yingzhan) then
      lbl_yingzhan.ForeColor = color2
    end
  end
end
function SetTitle2(form, index)
  local groupbox_cbtn = form.groupbox_cbtn
  local id = form.count - index + 1
  local groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(id))
  if nx_is_valid(groupbox) then
    local lbl_tiaozhan = groupbox:Find("lbl_" .. nx_string(2 * (id - 1) + 1))
    local lbl_yingzhan = groupbox:Find("lbl_" .. nx_string(2 * (id - 1) + 2))
    if nx_is_valid(lbl_tiaozhan) and nx_is_valid(lbl_yingzhan) then
      form.lbl_title.Text = lbl_tiaozhan.Text .. nx_widestr(" ") .. lbl_yingzhan.Text
    end
  end
end
function SetTitle(lbl, text1, text2)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    lbl.Text = gui.TextManager:GetText(text1) .. nx_widestr(" ") .. gui.TextManager:GetText(text2)
  end
end
function GetNext()
  local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_tiguanchallenge\\form_tiguanchallenge_nobattle", false)
  if nx_is_valid(form) then
    local dest = 0
    if form.highest < form.count then
      dest = form.highest
    elseif form.highest >= form.count then
      dest = form.count
    end
    if form.select + 1 < form.count then
      if dest >= form.select + 1 then
        local groupbox_cbtn = form.groupbox_cbtn
        local groupbox = nx_null()
        local cbtn = nx_null()
        for i = form.select + 1, dest do
          groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(form.count - i + 1))
          if nx_is_valid(groupbox) then
            cbtn = groupbox:Find("cbtn_" .. nx_string(i))
            if nx_is_valid(cbtn) then
              if cbtn.Enabled == true then
                return i
              elseif i == dest then
                return i
              end
            end
          end
        end
      elseif dest < form.select + 1 then
        return form.select + 1
      end
    elseif form.select + 1 >= form.count then
      return form.count
    end
  end
end
function on_ScrollBar1_value_changed(srl, value)
  local groupbox_cbtn = srl.ParentForm.groupbox_cbtn
  local groupbox = nx_null()
  for i = 1, srl.ParentForm.count do
    groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(i))
    if nx_is_valid(groupbox) then
      groupbox.Top = groupbox.Top + (value - srl.Value) * 30
      if groupbox.Top >= 12 and groupbox.Top <= 132 then
        groupbox.Visible = true
      else
        groupbox.Visible = false
      end
    end
  end
end
function on_cbtn_checked_changed(self)
  if self.Checked then
    self.ParentForm.select = nx_number(util_split_string(self.Name, "_")[2])
    local groupbox_cbtn = self.ParentForm.groupbox_cbtn
    local groupbox = nx_null()
    local lbl_tiaozhan = nx_null()
    local lbl_yingzhan = nx_null()
    local cbtn = nx_null()
    for i = 1, self.ParentForm.count do
      groupbox = groupbox_cbtn:Find("groupbox_" .. nx_string(i))
      if nx_is_valid(groupbox) then
        if i == self.ParentForm.count - self.ParentForm.select + 1 then
          lbl_tiaozhan = groupbox:Find("lbl_" .. nx_string(2 * (i - 1) + 1))
          lbl_yingzhan = groupbox:Find("lbl_" .. nx_string(2 * (i - 1) + 2))
          if nx_is_valid(lbl_tiaozhan) and nx_is_valid(lbl_yingzhan) then
            self.ParentForm.lbl_title.Text = lbl_tiaozhan.Text .. nx_widestr(" ") .. lbl_yingzhan.Text
          end
        else
          cbtn = groupbox:Find("cbtn_" .. nx_string(self.ParentForm.count - i + 1))
          if nx_is_valid(cbtn) then
            cbtn.Checked = false
          end
        end
      end
    end
  end
end
function on_btn_start_click(btn)
  custom_tiguanchallenge(TGC_C_SUBMSG_FIGHT, btn.ParentForm.select)
end
function on_btn_end_click(btn)
  custom_tiguanchallenge(TGC_C_SUBMSG_LEAVE)
end
function ReadChallenge(str)
  local tbl = util_split_string(str, ";")
  local count = 0
  for i, v in ipairs(tbl) do
    tbl[i] = util_split_string(tbl[i], "/")[1]
    count = i
  end
  SwapChallenge(tbl, count)
  return tbl, count
end
function SwapChallenge(tbl, count)
  local str = ""
  for i = 1, count / 2 do
    str = tbl[i]
    tbl[i] = tbl[count - i + 1]
    tbl[count - i + 1] = str
  end
end
