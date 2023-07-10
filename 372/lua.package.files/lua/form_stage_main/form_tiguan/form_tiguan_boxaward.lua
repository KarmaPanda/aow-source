require("form_stage_main\\form_tiguan\\form_tiguan_util")
require("custom_sender")
require("share\\view_define")
DELAY_SHOW_BOX_TIME = 5
BOXAWARD_TYPE_JIN = 0
BOXAWARD_TYPE_YIN = 1
BOXAWARD_TYPE_TONG = 2
MOUSE_ON = 0
MOUSE_OUT = 1
MOUSE_CLICK = 2
box_image_tab = {
  [BOXAWARD_TYPE_JIN] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_jin_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_jin_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_jin_click.png"
  },
  [BOXAWARD_TYPE_YIN] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_yin_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_yin_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_yin_click.png"
  },
  [BOXAWARD_TYPE_TONG] = {
    [MOUSE_ON] = "gui\\animations\\tiguan\\box_tie_on.png",
    [MOUSE_OUT] = "gui\\animations\\tiguan\\box_tie_out.png",
    [MOUSE_CLICK] = "gui\\animations\\tiguan\\box_tie_click.png"
  }
}
function main_form_init(self)
  self.Fixed = false
  self.IsOpen = false
  self.IsView = false
  self.box_type = 3
end
function on_main_form_open(self)
  local gui = nx_value("gui")
  self.Left = (gui.Width - self.Width) / 2
  self.Top = (gui.Height - self.Height) / 2
end
function on_main_form_close(self)
  local timer = nx_value("timer_game")
  timer:UnRegister(nx_current(), "show_form", self)
  local databinder = nx_value("data_binder")
  if not nx_is_valid(databinder) then
    return
  end
  databinder:DelViewBind(self)
  nx_destroy(self)
end
function on_btn_pickup_click(btn)
  local form = btn.ParentForm
  if form.IsOpen == true then
    return
  end
  form.lbl_back.BackImage = box_image_tab[form.box_type][MOUSE_CLICK]
  form.IsOpen = true
  local game_visual = nx_value("game_visual")
  if not nx_is_valid(game_visual) then
    return 0
  end
  game_visual:CustomSend(nx_int(CLIENT_CUSTOMMSG_TIGUAN_BOXAWARD_OPEN))
end
function on_btn_pickup_get_capture(btn)
  local form = btn.ParentForm
  if form.IsOpen == true then
    return
  end
  form.lbl_back.BackImage = box_image_tab[form.box_type][MOUSE_ON]
end
function on_btn_pickup_lost_capture(btn)
  local form = btn.ParentForm
  if form.IsOpen == true then
    return
  end
  form.lbl_back.BackImage = box_image_tab[form.box_type][MOUSE_OUT]
end
function show_tiguan_box_award(type, ...)
  if nx_number(type) == SHOW_BOXAWARD_OPEN then
    if table.getn(arg) < 1 then
      return 0
    end
    local form = util_get_form(FORM_TIGUAN_BOXAWARD, true)
    if not nx_is_valid(form) then
      return
    end
    local databinder = nx_value("data_binder")
    if not nx_is_valid(databinder) then
      return
    end
    databinder:AddViewBind(VIEWPORT_DROP_BOX, form, nx_current(), "on_view_operat")
    form.box_type = nx_number(arg[1])
    if form.box_type < BOXAWARD_TYPE_JIN and form.box_type > BOXAWARD_TYPE_TONG then
      form:Close()
      return
    end
    form.lbl_back.BackImage = box_image_tab[form.box_type][MOUSE_OUT]
    local timer = nx_value("timer_game")
    timer:Register(DELAY_SHOW_BOX_TIME * 1000, 1, nx_current(), "show_form", form, -1, -1)
  elseif nx_number(type) == SHOW_BOXAWARD_CLOSE then
    local form = util_get_form(FORM_TIGUAN_BOXAWARD, false)
    if not nx_is_valid(form) then
      return
    end
    form:Close()
  elseif nx_number(type) == SHOW_BOXAWARD_AGAIN then
    local form = util_get_form(FORM_TIGUAN_BOXAWARD, false)
    if not nx_is_valid(form) then
      return
    end
    form.btn_pickup.Enabled = true
  end
end
function show_form(form)
  if not nx_is_valid(form) then
    return
  end
  nx_execute("util_gui", "util_show_form", FORM_TIGUAN_BOXAWARD, true)
end
function on_view_operat(form, optype, view_ident, index)
  if not nx_is_valid(form) then
    return
  end
  if optype == "deleteview" then
    if form.IsView == true then
      form.lbl_back.BackImage = box_image_tab[form.box_type][MOUSE_OUT]
      form.IsOpen = false
      form.IsView = false
    end
  elseif optype == "createview" and form.IsOpen == true then
    form.IsView = true
  end
end
function close_form()
  local form = util_get_form(FORM_TIGUAN_BOXAWARD, false)
  if not nx_is_valid(form) then
    return
  end
  form:Close()
end
