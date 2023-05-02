require("share\\view_define")
require("share\\logicstate_define")
require("util_static_data")
require("utils")
require("util_gui")
require("game_object")
require("util_functions")
require("define\\object_type_define")
require("define\\shortcut_key_define")
function main_form_init(form)
  form.Fixed = false
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
  local databinder = nx_value("data_binder")
  if nx_is_valid(databinder) then
    databinder:AddTableBind("shortcut_rec", self, nx_current(), "update_shortcut_record")
  end
end
function on_main_form_close(form)
  nx_destroy(form)
end
function show_form(form, isautostop)
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(form, "groupbox_1") then
    close_form()
    return
  end
  form.groupbox_1.Visible = false
  if not nx_find_custom(form, "animation") then
    close_form()
    return
  end
  reset_control(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:UnRegister(nx_current(), "close_form", form)
  local gui = nx_value("gui")
  local w_ratio = gui.Width / 1024
  local h_ratio = gui.Height / 768
  if nx_int(4) == nx_int(isautostop) then
    local form_wuguan = util_get_form("form_stage_main\\form_life\\form_job_wuguan_01", true)
    if nx_is_valid(form_wuguan) then
      form_wuguan.Left = gui.Width - form_wuguan.Width
      form_wuguan.Top = 0
      form_wuguan.Visible = true
      form_wuguan:Show()
    end
    return
  elseif nx_int(5) == nx_int(isautostop) then
    local form_wuguan = util_get_form("form_stage_main\\form_life\\form_job_wuguan_02", true)
    if nx_is_valid(form_wuguan) then
      form_wuguan.Visible = true
      form_wuguan:Show()
    end
    return
  end
  timer:Register(50000, 1, nx_current(), "close_form", form, -1, -1)
  local animation = form.animation
  local arr_ani = util_split_string(nx_string(animation), ";")
  if 0 >= table.getn(arr_ani) then
    close_form()
    return
  end
  form.ani_1.AnimationImage = nx_string(arr_ani[1])
  form.ani_1.PlayMode = 0
  form.ani_1.Loop = false
  if nx_int(1) == nx_int(isautostop) then
    form.Left = 0
    form.Top = 0
    form.btn_ok.Visible = false
    form.lbl_4.Visible = false
    form.lbl_2.Visible = false
    form.lbl_kuang.Height = 155
    form.ani_1.AnimationImage = ""
    form.ani_1.PlayMode = 0
    form.ani_1.Loop = false
    change_lab(form)
    form.groupbox_1.Top = 0
    form.groupbox_1.Left = gui.Width - form.groupbox_1.Width
    form.groupbox_1.Visible = true
  elseif nx_int(2) == nx_int(isautostop) then
    form.ani_1.Top = 200 * h_ratio
    form.ani_1.Left = 600 * w_ratio
    timer:Register(3000, 1, nx_current(), "on_update_time", form, -1, -1)
  elseif nx_int(3) == nx_int(isautostop) then
    form.ani_1.Top = 200 * h_ratio
    form.ani_1.Left = 600 * w_ratio
    timer:Register(1000, 1, nx_current(), "on_update_time", form, -1, -1)
  elseif nx_int(6) == nx_int(isautostop) then
    form.ani_1.Top = gui.Height / 3
    form.ani_1.Left = (gui.Width - 50) / 2
    timer:Register(10000, 1, nx_current(), "on_update_time", form, -1, -1)
  else
    form.ani_1.Top = 7
    form.ani_1.Left = 9
    timer:Register(5000, 1, nx_current(), "on_update_time", form, -1, -1)
  end
  if 1 < table.getn(arr_ani) then
    if nx_int(1) == nx_int(isautostop) then
      on_show_last_ani_time(form)
      form.ani_2.Loop = true
      form.ani_2.AbsTop = 90 * h_ratio
      form.ani_2.AbsLeft = 129
    else
      timer:Register(1000, 1, nx_current(), "on_show_last_ani_time", form, -1, -1)
    end
  end
end
function close_form()
  local form_animation = nx_value("form_stage_main\\form_life\\form_job_animation")
  if nx_is_valid(form_animation) then
    form_animation.ani_1.Top = 7
    form_animation.ani_1.Left = 9
    form_animation:Close()
  end
  local form_wuguan = nx_value("form_stage_main\\form_life\\form_job_wuguan_01")
  if nx_is_valid(form_wuguan) then
    form_wuguan:Close()
  end
end
function on_update_time(form)
  end_timer(form)
end
function on_show_last_ani_time(form)
  local animation = form.animation
  local arr_ani = util_split_string(nx_string(animation), ";")
  if table.getn(arr_ani) > 1 then
    form.ani_2.AnimationImage = nx_string(arr_ani[2])
    form.ani_2.PlayMode = 0
    form.ani_2.Loop = false
  end
end
function end_timer(form)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "on_update_time", form)
  timer:UnRegister(nx_current(), "on_show_last_ani_time", form)
  timer:UnRegister(nx_current(), "close_form", form)
  reset_control(form)
  form.animation = nil
  form:Close()
end
function reset_control(form)
  for i = 1, 2 do
    local ani = form:Find("ani_" .. nx_string(i))
    ani.AnimationImage = ""
    ani.PlayMode = 0
    ani.Loop = false
  end
end
function on_btn_ok_click(self)
  local form = self.ParentForm
  form:Close()
end
function open_job_form(form, num, ...)
  local gui = nx_value("gui")
  form.AbsTop = 0
  form.AbsLeft = 0
  form.groupbox_1.Top = 0
  form.groupbox_1.Left = gui.Width - form.groupbox_1.Width
  form.groupbox_1.Visible = true
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "close_form", form)
  timer:Register(50000, 1, nx_current(), "close_form", form, -1, -1)
  if "1" == nx_string(num) then
    form.btn_ok.Visible = false
    form.lbl_4.Visible = false
    form.lbl_2.Visible = false
    form.lbl_kuang.Height = 155
    change_lab(form)
  elseif "2" == nx_string(num) then
    form.groupbox_1.Top = (gui.Height - form.groupbox_1.Height) / 2
    form.groupbox_1.Left = (gui.Width - form.groupbox_1.Width) / 2
    form.btn_ok.Visible = true
    form.lbl_4.Visible = true
    form.lbl_2.Visible = true
    form.lbl_kuang.Height = 124
    form.lbl_1.Visible = true
    form.lbl_pic.Visible = true
    form.lbl_pic.Left = 212
    form.lbl_pic.Top = 81
    form.lbl_pic.Width = 32
    form.lbl_pic.Height = 32
    if 0 < table.getn(arg) then
      local skill_id = arg[1]
      form.lbl_pic.BackImage = "icon\\skill\\" .. nx_string(skill_id) .. ".png"
      form.mlitbox_text.HtmlText = nx_widestr(util_format_string("desc_freshman_help_5", nx_string(skill_id)))
    else
      form.lbl_pic.BackImage = "icon\\skill\\zhaoshi057.png"
      form.mlitbox_text.HtmlText = nx_widestr(gui.TextManager:GetText("desc_freshman_help_1"))
    end
  end
end
function change_lab(form)
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  local shortcut_cut = nx_value("ShortcutKey")
  if not nx_is_valid(shortcut_cut) then
    return
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  form.Width = gui.Width
  form.Height = gui.Height
  form.lbl_1.Visible = false
  local key_name = shortcut_cut:GetKeyNameByKeyID(Key_Role_Parry)
  if "Right Button" == key_name then
    form.lbl_pic.Visible = true
    form.lbl_pic.BackImage = "gui\\animations\\renwuyindao\\right_click_1.png"
    form.lbl_pic.Left = 206
    form.lbl_pic.Top = 60
    form.lbl_pic.Width = 48
    form.lbl_pic.Height = 64
    form.mlitbox_text.HtmlText = nx_widestr(gui.TextManager:GetText("desc_freshman_help_2"))
  else
    form.lbl_pic.Visible = false
    form.mlitbox_text.HtmlText = nx_widestr(gui.TextManager:GetText("desc_freshman_help_3"))
  end
end
function show_res_form(form, num)
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "close_form", form)
  timer:Register(50000, 1, nx_current(), "close_form", form, -1, -1)
  if "4" == nx_string(num) then
    form.groupbox_1.Visible = false
    form.lbl_pic_1.DataSourse = "book_CS_jh_cqgf04"
    form.lbl_pic_1.BackImage = "icon\\prop\\prop436.png"
    form.lbl_name_1.Text = nx_widestr(gui.TextManager:GetText("book_CS_jh_cqgf04"))
  elseif "3" == nx_string(num) then
    form.lbl_pic_1.BackImage = "icon\\prop\\prop436.png"
    form.lbl_pic_2.BackImage = "icon\\prop\\prop436.png"
    form.lbl_pic_1.DataSourse = "book_CS_jh_cqgf01"
    form.lbl_pic_2.DataSourse = "Book_CS_jh_cqgf06"
    form.lbl_name_1.Text = nx_widestr(gui.TextManager:GetText("book_CS_jh_cqgf01"))
    form.lbl_name_2.Text = nx_widestr(gui.TextManager:GetText("book_CS_jh_cqgf06"))
  end
end
function on_btn_res_ok_click(self)
  local form = self.ParentForm
  form:Close()
end
function on_lbl_pic_get_capture(self)
  local id = self.DataSourse
  nx_execute("tips_game", "show_tips_by_config", nx_string(id), self.AbsLeft + self.Width / 2, self.AbsTop - self.Height / 2)
end
function on_lbl_pic_lost_capture(self)
  nx_execute("tips_game", "hide_tip", self.ParentForm)
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_life\\form_job_animation")
  local gui = nx_value("gui")
  if not nx_is_valid(form) then
    return
  end
  if nx_find_custom(form.ani_1, "id") then
    show_animation(form, form.ani_1.id)
  end
  if form.groupbox_1.Visible then
    if form.btn_ok.Visible then
      form.groupbox_1.Top = (gui.Height - form.groupbox_1.Height) / 2
      form.groupbox_1.Left = (gui.Width - form.groupbox_1.Width) / 2
    else
      form.groupbox_1.Top = 0
      form.groupbox_1.Left = gui.Width - form.groupbox_1.Width
    end
  end
  local form_wuguan = nx_value("form_stage_main\\form_life\\form_job_wuguan_01")
  if nx_is_valid(form_wuguan) then
    form_wuguan.Top = 0
    form_wuguan.Left = gui.Width - form_wuguan.Width
  end
end
function show_animation(form, id)
  if not nx_is_valid(form) then
    return
  end
  form.groupbox_1.Visible = false
  local form_shortcut = nx_value("form_stage_main\\form_main\\form_main_shortcut")
  if not nx_is_valid(form_shortcut) then
    return
  end
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return
  end
  form.ani_1.AnimationImage = ""
  form.ani_1.id = ""
  local rows = client_player:GetRecordRows("shortcut_rec")
  for i = 0, rows do
    local row = client_player:QueryRecord("shortcut_rec", i, 0)
    local name = client_player:QueryRecord("shortcut_rec", i, 2)
    if name == id then
      if 90 <= row then
        local left = form_shortcut.grid_shortcut_2.AbsLeft
        local top = form_shortcut.grid_shortcut_2.AbsTop
        local index = row - 90
        form.ani_1.AnimationImage = "skillbar_movie"
        form.ani_1.PlayMode = 0
        form.ani_1.Loop = true
        form.ani_1.AbsLeft = left + 44 * index - 27
        form.ani_1.AbsTop = top - 26
        form.ani_1.id = id
        return
      end
      local index = get_skill_index(form_shortcut.grid_shortcut_main, nx_number(row))
      if -1 ~= index then
        local left = form_shortcut.grid_shortcut_main.AbsLeft
        local top = form_shortcut.grid_shortcut_main.AbsTop
        form.ani_1.AnimationImage = "skillbar_movie"
        form.ani_1.PlayMode = 0
        form.ani_1.Loop = true
        form.ani_1.AbsLeft = left + 43.6 * index - 25
        form.ani_1.AbsTop = top - 26
        form.ani_1.id = id
        return
      end
    end
  end
  reset_control(form)
  if nx_string(id) ~= "" then
    local gui = nx_value("gui")
    local name = gui.TextManager:GetText(id)
    local text = gui.TextManager:GetFormatText("9742", name)
    local SystemCenterInfo = nx_value("SystemCenterInfo")
    if nx_is_valid(SystemCenterInfo) then
      SystemCenterInfo:ShowSystemCenterInfo(text, 2)
    end
  end
end
function get_skill_index(grid, row)
  if row < 0 then
    return -1
  end
  local beginindex = grid.beginindex + grid.page * (grid.RowNum * grid.ClomnNum)
  local endindex = beginindex + grid.RowNum * grid.ClomnNum
  local game_client = nx_value("game_client")
  if not nx_is_valid(game_client) then
    return -1
  end
  local client_player = game_client:GetPlayer()
  if not nx_is_valid(client_player) then
    return -1
  end
  if row >= beginindex and row < endindex then
    return row - beginindex
  else
    return -1
  end
end
function update_shortcut_record(form, record_name, opttype, row, col)
  if nx_find_custom(form.ani_1, "id") then
    show_animation(form, form.ani_1.id)
  end
end
