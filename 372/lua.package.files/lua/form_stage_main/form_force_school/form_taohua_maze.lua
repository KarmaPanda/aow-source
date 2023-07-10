require("util_gui")
require("util_functions")
local g_tab_color_seq = {
  [1] = "gui\\special\\taohuazhen\\bg_thz_hong.png",
  [2] = "gui\\special\\taohuazhen\\bg_thz_cheng.png",
  [3] = "gui\\special\\taohuazhen\\bg_thz_huang.png",
  [4] = "gui\\special\\taohuazhen\\bg_thz_lv.png",
  [5] = "gui\\special\\taohuazhen\\bg_thz_qing.png",
  [6] = "gui\\special\\taohuazhen\\bg_thz_lan.png",
  [7] = "gui\\special\\taohuazhen\\bg_thz_zi.png"
}
local g_tab_image_seq = {
  [1] = "gui\\special\\taohuazhen\\thz_hong.png",
  [2] = "gui\\special\\taohuazhen\\thz_cheng.png",
  [3] = "gui\\special\\taohuazhen\\thz_huang.png",
  [4] = "gui\\special\\taohuazhen\\thz_lv.png",
  [5] = "gui\\special\\taohuazhen\\thz_qing.png",
  [6] = "gui\\special\\taohuazhen\\thz_lan.png",
  [7] = "gui\\special\\taohuazhen\\thz_zi.png"
}
local g_tab_tips = {
  [1] = "tips_thdthz_jing",
  [2] = "tips_thdthz_si",
  [3] = "tips_thdthz_jin",
  [4] = "tips_thdthz_du",
  [5] = "tips_thdthz_shang",
  [6] = "tips_thdthz_sheng",
  [7] = "tips_thdthz_xiu"
}
function main_form_init(self)
  self.Fixed = false
  self.Visible = true
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 3
  self.type = 0
  self.seq = 0
  self.result = ""
  return 1
end
function on_main_form_open(self)
end
function refresh_form(form)
  local type = nx_number(form.type)
  local seq = nx_number(form.seq)
  if type <= 0 then
    return
  end
  local tab_control = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4,
    form.lbl_5,
    form.lbl_6,
    form.lbl_7
  }
  local lbl = tab_control[nx_number(type)]
  if lbl == nil then
    return
  end
  local backcolor = g_tab_color_seq[nx_number(seq)]
  if backcolor == nil then
    return
  end
  lbl.BackImage = backcolor
end
function set_image(form, result)
  local tab_temp = util_split_string(result, "|")
  local tab_control = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4,
    form.lbl_5,
    form.lbl_6,
    form.lbl_7
  }
  for i = 1, table.getn(tab_control) do
    local lbl = tab_control[i]
    if lbl ~= nil then
      local image = g_tab_image_seq[nx_number(tab_temp[i])]
      if image ~= nil then
        lbl.BackImage = image
      end
    end
  end
end
function on_main_form_close(self)
  nx_destroy(self)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  form:Close()
end
function set_tips(form, pos, ...)
  local result = form.result
  local tab_result = util_split_string(result, "|")
  local tab_seq = {}
  for i = pos, table.getn(arg) do
    tab_seq[arg[i]] = i - pos + 1
  end
  local tab_temp = {}
  for i = 1, table.getn(tab_result) do
    local temp = nx_number(tab_result[i])
    tab_temp[i] = tab_seq[temp]
  end
  local tab_control = {
    form.lbl_1,
    form.lbl_2,
    form.lbl_3,
    form.lbl_4,
    form.lbl_5,
    form.lbl_6,
    form.lbl_7
  }
  for i = 1, table.getn(tab_control) do
    local lbl = tab_control[i]
    if lbl ~= nil and tab_temp[i] ~= nil then
      local image = g_tab_tips[nx_number(tab_temp[i])]
      if image ~= nil then
        lbl.HintText = util_text(image)
      end
    end
  end
end
function on_server_msg(...)
  local flag = arg[1]
  if nx_string(flag) == "begin" then
    local result = arg[2]
    local form = nx_value("form_stage_main\\form_force_school\\form_taohua_maze")
    if nx_is_valid(form) then
      form:Close()
    end
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze", true, false)
    if not nx_is_valid(form) then
      return
    end
    form:Show()
    form.result = result
    set_image(form, result)
    set_tips(form, 3, unpack(arg))
  elseif nx_string(flag) == "end" then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze", false, false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
    form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze_map", false, false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  elseif nx_string(flag) == "doing" then
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze", false, false)
    if not nx_is_valid(form) then
      return
    end
    if form.Visible == false then
      return
    end
    form.type = arg[2]
    form.seq = arg[3]
    refresh_form(form)
    set_tips(form, 4, unpack(arg))
  elseif nx_string(flag) == "useitem" then
    nx_execute("form_stage_main\\form_force_school\\form_taohua_maze_map", "refresh_form", true, unpack(arg))
  elseif nx_string(flag) == "refresh" then
    nx_execute("form_stage_main\\form_force_school\\form_taohua_maze_map", "refresh_form", false, unpack(arg))
    local form = nx_execute("util_gui", "util_get_form", "form_stage_main\\form_force_school\\form_taohua_maze", false, false)
    if not nx_is_valid(form) then
      return
    end
    if form.Visible == false then
      return
    end
    set_tips(form, 2, unpack(arg))
  end
end
