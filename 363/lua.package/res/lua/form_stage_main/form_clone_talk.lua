require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
local FORM_CLONE_TALK = "form_stage_main\\form_clone_talk"
local FORM_CONFIRM = "form_common\\form_confirm"
local FUN_ID_BASE = 80000
local MAX_DISTANCE = 15
local SCENE_INI_PATH = "ini\\scenes.ini"
local CLONE_INI_PATH = "ini\\clonescenes.ini"
local cnt_tab = {}
local fun_tab = {}
function show_clone_menu(npcid, cloneconfig, cnt1, fun1, cnt2, fun2, cnt3, fun3, cnt4, fun4)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return nx_null()
  end
  local form = nx_value(FORM_CLONE_TALK)
  if not nx_is_valid(form) then
    form = nx_call("util_gui", "util_get_form", FORM_CLONE_TALK, true, false)
  end
  form.npcid = npcid
  form.cloneconfig = cloneconfig
  cnt_tab = {
    cnt1,
    cnt2,
    cnt3,
    cnt4
  }
  fun_tab = {
    fun1,
    fun2,
    fun3,
    fun4
  }
  form.Visible = true
  nx_execute(FORM_CLONE_TALK, "refresh_talk_form", form)
end
function refresh_talk_form(form)
  local gui = nx_value("gui")
  if cnt_tab[1] and cnt_tab[1] > 0 then
    form.rbtn_normal.Text = nx_widestr(util_text(nx_string(form.cloneconfig) .. "_" .. nx_string(1)))
    form.rbtn_normal.Visible = true
    form.lbl_normal.Visible = true
  else
    form.rbtn_normal.Visible = false
    form.lbl_normal.Visible = false
  end
  if cnt_tab[2] and 0 < cnt_tab[2] then
    form.rbtn_hard.Text = nx_widestr(util_text(nx_string(form.cloneconfig) .. "_" .. nx_string(2)))
    form.rbtn_hard.Visible = true
    form.lbl_hard.Visible = true
  else
    form.rbtn_hard.Visible = false
    form.lbl_hard.Visible = false
  end
  if cnt_tab[3] and 0 < cnt_tab[3] then
    form.rbtn_hell.Text = nx_widestr(util_text(nx_string(form.cloneconfig) .. "_" .. nx_string(3)))
    form.rbtn_hell.Visible = true
    form.lbl_hell.Visible = true
  else
    form.rbtn_hell.Visible = false
    form.lbl_hell.Visible = false
  end
  if cnt_tab[4] and 0 < cnt_tab[4] then
    local switch_manager = nx_value("SwitchManager")
    local is_open = switch_manager:CheckSwitchEnable(ST_FUNCTION_CLONE_LEVEL4)
    if is_open then
      form.rbtn_level4.Text = nx_widestr(util_text(nx_string(form.cloneconfig) .. "_" .. nx_string(4)))
      form.rbtn_level4.Visible = true
      form.lbl_level4.Visible = true
    else
      form.rbtn_level4.Visible = false
      form.lbl_level4.Visible = false
    end
  else
    form.rbtn_level4.Visible = false
    form.lbl_level4.Visible = false
  end
  local nameID = form.cloneconfig
  form.lbl_clonename.Text = nx_widestr(gui.TextManager:GetText(nx_string(nameID)))
  local Imgpath = read_ini_file(CLONE_INI_PATH, form.cloneconfig, "IntrImg")
  form.lbl_backimage.BackImage = nx_string(Imgpath)
  form:Show()
end
function read_ini_file(filename, section, key)
  local cloneini = nx_execute("util_functions", "get_ini", filename)
  if not nx_is_valid(cloneini) then
    nx_msgbox(filename .. get_msg_str("msg_120"))
    return ""
  end
  local sec_index = cloneini:FindSectionIndex(nx_string(section))
  if sec_index < 0 then
    return ""
  end
  return cloneini:ReadString(sec_index, key, "")
end
function main_form_init(self)
  self.Fixed = false
  self.cloneconfig = nil
  self.npcid = nil
  cnt_tab = {
    nil,
    nil,
    nil
  }
  fun_tab = {
    nil,
    nil,
    nil
  }
  return 1
end
function on_main_form_open(form)
  local gui = nx_value("gui")
  form.AbsLeft = (gui.Width - form.Width) / 2
  form.AbsTop = (gui.Height - form.Height) / 1.5
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
  nx_execute(nx_current(), "form_talk_tick")
  return 1
end
function on_main_form_close(form)
  if nx_running(nx_current(), "form_talk_tick") then
    nx_kill(nx_current(), "form_talk_tick")
  end
  if nx_find_custom(form, "needrespond") and nx_int(form.needrespond) == nx_int(1) then
  else
    local sock = nx_value("game_sock")
    if not nx_is_valid(sock) then
      return 0
    end
    sock.Sender:Select(nx_string(form.npcid), nx_int(600000))
  end
  nx_execute("tips_game", "hide_tip", form)
  nx_destroy(form)
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form:Close()
  return 1
end
function on_rbtn_normal_get_capture(self)
  show_text_tip(self, 1)
end
function on_rbtn_normal_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_rbtn_hard_get_capture(self)
  show_text_tip(self, 2)
end
function on_rbtn_hard_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function on_rbtn_hell_get_capture(self)
  show_text_tip(self, 3)
end
function on_rbtn_hell_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function show_text_tip(self, index)
  local gui = nx_value("gui")
  local form = self.ParentForm
  local text = gui.TextManager:GetFormatText("ui_fuben0012", nx_int(cnt_tab[index]))
  nx_execute("tips_game", "show_text_tip", nx_widestr(text), self.AbsLeft, self.AbsTop, 0, self.ParentForm)
end
function on_rbtn_normal_checked_changed(self)
  if self.Checked then
    select_menu(self.ParentForm, 1)
  end
end
function on_rbtn_hard_checked_changed(self)
  if self.Checked then
    select_menu(self.ParentForm, 2)
  end
end
function on_rbtn_hell_checked_changed(self)
  if self.Checked then
    select_menu(self.ParentForm, 3)
  end
end
function on_rbtn_level4_checked_changed(self)
  if self.Checked then
    select_menu(self.ParentForm, 4)
  end
end
function select_menu(form, index)
  if not nx_is_valid(form) then
    return 0
  end
  local sock = nx_value("game_sock")
  if not nx_is_valid(sock) then
    return 0
  end
  sock.Sender:Select(nx_string(form.npcid), nx_int(fun_tab[index]))
end
function form_talk_tick()
  local game_visual = nx_value("game_visual")
  local visual_player = game_visual:GetPlayer()
  if not nx_is_valid(visual_player) then
    return
  end
  local form = nx_value(FORM_CLONE_TALK)
  if not nx_is_valid(form) then
    return
  end
  local visual_npc = game_visual:GetSceneObj(nx_string(form.npcid))
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
function inphase_clone_menu(npcid, funid)
  local dialog = nx_execute(FORM_CONFIRM, "get_new_confirm_form", "inphase_clone_menu")
  if not nx_is_valid(dialog) then
    return
  end
  dialog:ShowModal()
  local text = nx_widestr(util_text("ui_fuben0009"))
  nx_execute("form_common\\form_confirm", "show_common_text", dialog, text)
  local res = nx_wait_event(100000000, dialog, "inphase_clone_menu_confirm_return")
  if res == "ok" then
    local sock = nx_value("game_sock")
    if not nx_is_valid(sock) then
      return 0
    end
    sock.Sender:Select(nx_string(npcid), nx_int(funid))
  end
end
function on_btn_help_click(btn)
  nx_execute("form_stage_main\\form_clone\\form_clone_main", "show_type_info", 102)
end
function on_close_helpbox(self)
  groupbox = self.Parent
  groupbox.Visible = false
end
function on_btn_story_record_click(btn)
  local text = ""
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    text = gui.TextManager:GetText("ui_fubendhlz")
  end
  local confirm_dialog = nx_execute("util_gui", "util_get_form", "form_common\\form_confirm", true, false)
  nx_execute("form_common\\form_confirm", "show_common_text", confirm_dialog, nx_widestr(text))
  confirm_dialog:ShowModal()
  confirm_dialog.Left = (gui.Width - confirm_dialog.Width) / 2
  confirm_dialog.Top = (gui.Height - confirm_dialog.Height) / 2
  local result = nx_wait_event(100000000, confirm_dialog, "confirm_return")
  if "ok" == result then
    local dialog = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_camera\\form_movie_save", true, false)
    dialog.groupbox_1.Visible = false
    dialog.groupbox_2.Visible = true
    dialog.groupbox_3.Visible = true
    if nx_is_valid(gui) then
      dialog.btn_video.HintText = gui.TextManager:GetText("tips_movie_save")
    end
    util_show_form("form_stage_main\\form_camera\\form_movie_save", true)
    local cloneid
    local form = btn.ParentForm
    if nx_is_valid(form) and nx_find_custom(form, "cloneconfig") then
      local cloneconfig = form.cloneconfig
      local cloneini = nx_execute("util_functions", "get_ini", SCENE_INI_PATH)
      if nx_is_valid(cloneini) then
        local count = cloneini:GetSectionCount()
        for i = 1, count do
          local index = cloneini:FindSectionIndex(nx_string(i))
          if 0 <= index then
            local config = cloneini:ReadString(index, "Config", "")
            if nx_string(cloneconfig) == nx_string(config) then
              cloneid = cloneini:GetSectionByIndex(index)
              break
            end
          end
        end
      end
    end
    if nx_find_custom(dialog, "cloneid") then
      dialog.cloneid = cloneid
    end
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      dialog.Left = (gui.Width - dialog.Width) / 2
      dialog.Top = (gui.Height - dialog.Height) / 2
    end
  end
end
