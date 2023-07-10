require("utils")
require("util_gui")
require("util_functions")
require("form_stage_main\\switch\\switch_define")
require("define\\sysinfo_define")
require("share\\client_custom_define")
local FORM_PATH = "form_stage_main\\form_war_scuffle\\form_balance_level"
local CLIENT_SUB_BG_REQ_LV_INFO = 1
local CLIENT_SUB_BG_REQ_PRIZE = 2
local main_ini = "share\\War\\balance_war_grow.ini"
local post_ini = "share\\Life\\PostRewardPack.ini"
function open_form()
  local form = util_get_form(FORM_PATH, true, false)
  if nx_is_valid(form) then
    form:Show()
    form.Visible = true
  end
end
function main_form_init(self)
  self.Fixed = false
  self.cur_page = 1
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    self.AbsLeft = (gui.Width - self.Width) / 2
    self.AbsTop = (gui.Height - self.Height) / 2
  end
  request_balance_lv_info(1)
end
function request_balance_lv_info(page)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_int(page) <= nx_int(0) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_GROW), nx_int(CLIENT_SUB_BG_REQ_LV_INFO), nx_int(page))
end
function rec_balance_lv_info(...)
  local form = nx_value(FORM_PATH)
  if not nx_is_valid(form) then
    return
  end
  init_ctrl(form)
  local player_lv = nx_int(arg[2])
  form.lbl_lv.Text = nx_widestr(nx_string(player_lv))
  form.pbar_exp.Maximum = nx_int(arg[3])
  form.pbar_exp.Value = nx_int(arg[4])
  form.pbar_exp.HintText = util_text(nx_string(form.pbar_exp.Value) .. nx_string("/") .. nx_string(form.pbar_exp.Maximum))
  local cur_page = nx_int(arg[5])
  local max_page = nx_int(arg[6])
  local dang = nx_int(arg[7])
  form.lbl_dang.BackImage = "gui\\special\\balance_grow\\balance_grow_" .. nx_string(dang) .. nx_string(".png")
  form.cur_page = cur_page
  form.max_page = max_page
  form.lbl_page.Text = nx_widestr(nx_string(cur_page) .. nx_string("/") .. nx_string(max_page))
  local str = nx_string(arg[1])
  local str_list = util_split_string(str, ";")
  for i = 1, #str_list do
    local temp = str_list[i]
    local lv_list = util_split_string(temp, "-")
    local lv = lv_list[1]
    local state = lv_list[2]
    local cbtn = form.groupbox_1:Find("cbtn_" .. nx_string(i))
    local lbl = form.groupbox_1:Find("lbl_" .. nx_string(i))
    if nx_is_valid(cbtn) and nx_is_valid(lbl) then
      cbtn.lv = lv
      lbl.lv = lv
      if nx_int(player_lv) < nx_int(lv) then
        cbtn.Enabled = false
        cbtn.DisableImage = "gui\\special\\balance_grow\\Bbox_lock.png"
      elseif nx_int(state) == nx_int(1) then
        cbtn.Checked = true
        cbtn.Enabled = false
        cbtn.DisableImage = "gui\\special\\balance_grow\\Bbox_open.png"
        lbl.BackImage = "gui\\special\\balance_grow\\Bicon_1.png"
      else
        cbtn.Checked = false
        cbtn.Enabled = true
        cbtn.BackImage = "gui\\special\\balance_grow\\Bbox_av_out.png"
        cbtn.FocusImage = "gui\\special\\balance_grow\\Bbox_av_on.png"
        cbtn.NormalImage = "gui\\special\\balance_grow\\Bbox_av_out.png"
        cbtn.CheckedImage = "gui\\special\\balance_grow\\Bbox_close.png"
        lbl.BackImage = "gui\\special\\balance_grow\\Bicon_2.png"
      end
    end
    local lbl_lv = form.groupbox_1:Find("lbl_lv_" .. nx_string(i))
    if nx_is_valid(lbl_lv) then
      lbl_lv.Text = nx_widestr(nx_string(lv))
    end
  end
  local index = 0
  for i = 1, 5 do
    local cbtn = form.groupbox_1:Find("cbtn_" .. nx_string(i))
    if nx_is_valid(cbtn) then
      cbtn.real_index = (nx_number(cur_page) - nx_number(1)) * nx_number(5) + nx_number(cbtn.DataSource)
      if nx_int(player_lv) >= nx_int(cbtn.lv) then
        index = index + 1
      end
    end
  end
  local pbar_lv = form.pbar_lv
  if nx_int(index) == nx_int(0) then
    pbar_lv.Value = 0
  elseif nx_int(index) == nx_int(5) then
    pbar_lv.Value = 0
  elseif nx_int(index) > nx_int(0) and nx_int(index) < nx_int(5) then
    local cbtn_min = form.groupbox_1:Find("cbtn_" .. nx_string(index))
    local cbtn_max = form.groupbox_1:Find("cbtn_" .. nx_string(index + 1))
    if nx_is_valid(cbtn_min) and nx_is_valid(cbtn_max) then
      pbar_lv.Value = nx_float(25) * (nx_float(index) - nx_float(1)) + (nx_float(player_lv) - nx_float(cbtn_min.lv)) / (nx_float(cbtn_max.lv) - nx_float(cbtn_min.lv)) * nx_float(25)
    end
  end
end
function init_ctrl(form)
  if not nx_is_valid(form) then
    return
  end
  for i = 1, 5 do
    local cbtn_prize = form.groupbox_1:Find("cbtn_" .. nx_string(i))
    local lbl_prize = form.groupbox_1:Find("lbl_" .. nx_string(i))
    local lbl_lv = form.groupbox_1:Find("lbl_lv_" .. nx_string(i))
    if nx_is_valid(cbtn_prize) and nx_is_valid(lbl_prize) and nx_is_valid(lbl_lv) then
      cbtn_prize.Enabled = false
      cbtn_prize.Checked = false
      cbtn_prize.DisableImage = "gui\\special\\balance_grow\\Bbox_nothing.png"
      lbl_prize.BackImage = "gui\\special\\balance_grow\\Bicon_3.png"
      lbl_lv.Text = nx_widestr("")
    end
  end
end
function on_main_form_close(self)
  if nx_is_valid(self) then
    nx_destroy(self)
  end
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    form:Close()
  end
end
function on_btn_last_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = nx_int(form.cur_page) - nx_int(1)
  if nx_int(page) < nx_int(1) or nx_int(page) > nx_int(form.max_page) then
    return
  end
  request_balance_lv_info(page)
end
function on_btn_next_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = nx_int(form.cur_page) + nx_int(1)
  if nx_int(page) < nx_int(1) or nx_int(page) > nx_int(form.max_page) then
    return
  end
  request_balance_lv_info(page)
end
function on_btn_page_go_click(btn)
  local form = btn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = nx_int(form.ipt_page.Text)
  if nx_int(page) < nx_int(1) or nx_int(page) > nx_int(form.max_page) then
    return
  end
  request_balance_lv_info(page)
end
function on_cbtn_prize_checked_changed(cbtn)
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  if not nx_find_custom(cbtn, "lv") then
    return
  end
  if not cbtn.Checked then
    return
  end
  local page = nx_int(form.cur_page)
  local lv = nx_int(cbtn.lv)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_int(page) <= nx_int(0) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_GROW), nx_int(CLIENT_SUB_BG_REQ_PRIZE), nx_int(lv), nx_int(page))
end
function on_cbtn_prize_click(cbtn)
  if cbtn.Checked then
    return
  end
  local form = cbtn.ParentForm
  if not nx_is_valid(form) then
    return
  end
  local page = nx_int(form.cur_page)
  local lv = nx_int(cbtn.lv)
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return
  end
  if nx_int(page) <= nx_int(0) then
    return
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_BALANCE_GROW), nx_int(CLIENT_SUB_BG_REQ_PRIZE), nx_int(lv), nx_int(page))
end
function on_cbtn_prize_get_capture(cbtn)
  if not nx_find_custom(cbtn, "real_index") then
    return
  end
  local index = cbtn.real_index
  local main_ini = nx_execute("util_functions", "get_ini", main_ini)
  if not nx_is_valid(main_ini) then
    return
  end
  local sec_count = main_ini:FindSectionIndex("war_grow_prize")
  if sec_count < 0 then
    return
  end
  local post_id = main_ini:GetSectionItemValue(sec_count, index - 1)
  local ini_post = nx_execute("util_functions", "get_ini", post_ini)
  if not nx_is_valid(ini_post) then
    return
  end
  local sec_count = ini_post:FindSectionIndex(nx_string(post_id))
  if sec_count < 0 then
    return
  end
  local str = ini_post:ReadString(sec_count, "Pack", "")
  local item_id_list = util_split_string(str, ",")
  local item_id = nx_string(item_id_list[1])
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  local x, y = gui:GetCursorClientPos()
  nx_execute("tips_game", "show_tips_by_config", item_id, x, y)
end
function on_cbtn_prize_lost_capture(cbtn)
  nx_execute("tips_game", "hide_tip")
end
function a(info)
  nx_msgbox(nx_string(info))
end
