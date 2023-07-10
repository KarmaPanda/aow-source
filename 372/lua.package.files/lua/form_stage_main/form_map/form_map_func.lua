require("util_functions")
function main_form_init(self)
  self.Fixed = false
end
function on_main_form_open(self)
  self.btn_spot.Expand = false
  self.btn_life.Expand = false
  self.btn_team.Expand = false
  self.btn_label.Expand = false
  self.btn_caiji.Expand = false
  self.btn_spot.GroupBoxHead = self.groupbox_spot_head
  self.btn_spot.GroupBoxList = self.groupbox_spot
  self.btn_spot.LabelArrow = self.lbl_spot
  self.btn_life.GroupBoxHead = self.groupbox_life_head
  self.btn_life.GroupBoxList = self.groupbox_life
  self.btn_life.LabelArrow = self.lbl_life
  self.btn_team.GroupBoxHead = self.groupbox_team_head
  self.btn_team.GroupBoxList = self.groupbox_team
  self.btn_team.LabelArrow = self.lbl_team
  self.btn_label.GroupBoxHead = self.groupbox_label_head
  self.btn_label.GroupBoxList = self.groupbox_label
  self.btn_label.LabelArrow = self.lbl_label
  self.btn_caiji.GroupBoxHead = self.groupbox_caiji_head
  self.btn_caiji.GroupBoxList = self.groupbox_caiji
  self.btn_caiji.LabelArrow = self.lbl_caiji
  local ini = nx_execute("util_functions", "get_ini", "gui\\map\\map_func_sel.ini")
  local sect = ini:FindSectionIndex("MainFunc")
  if 0 <= sect then
    self.cbtn_shangdian.NpcTypes = ini:ReadString(sect, "ShangDian", "")
    self.cbtn_chefu.NpcTypes = ini:ReadString(sect, "MaFu", "")
    self.cbtn_fuhuodian.NpcTypes = ini:ReadString(sect, "FuHuo", "")
    self.cbtn_chuansongmen.NpcTypes = ini:ReadString(sect, "ChuanSong", "")
  end
  local sect = ini:FindSectionIndex("Life")
  if 0 <= sect then
    self.cbtn_kuanggong.NpcTypes = ini:ReadString(sect, "KuangGong", "")
    self.cbtn_tiejiang.NpcTypes = ini:ReadString(sect, "TieJiang", "")
    self.cbtn_yufu.NpcTypes = ini:ReadString(sect, "YuFu", "")
    self.cbtn_qiaofu.NpcTypes = ini:ReadString(sect, "QiaoFu", "")
    self.cbtn_nongfu.NpcTypes = ini:ReadString(sect, "NongFu", "")
    self.cbtn_liehu.NpcTypes = ini:ReadString(sect, "LieHu", "")
    self.cbtn_caifeng.NpcTypes = ini:ReadString(sect, "CaiFeng", "")
    self.cbtn_jinjiang.NpcTypes = ini:ReadString(sect, "JinJiang", "")
    self.cbtn_yaoshi.NpcTypes = ini:ReadString(sect, "YaoShi", "")
    self.cbtn_dushi.NpcTypes = ini:ReadString(sect, "DuShi", "")
    self.cbtn_chushi.NpcTypes = ini:ReadString(sect, "ChuShi", "")
    self.cbtn_qinshi.NpcTypes = ini:ReadString(sect, "QinShi", "")
    self.cbtn_qishi.NpcTypes = ini:ReadString(sect, "QiShi", "")
    self.cbtn_shusheng.NpcTypes = ini:ReadString(sect, "ShuSheng", "")
    self.cbtn_huashi.NpcTypes = ini:ReadString(sect, "HuaShi", "")
    self.cbtn_guashi.NpcTypes = ini:ReadString(sect, "GuaShi", "")
    self.cbtn_qigai.NpcTypes = ini:ReadString(sect, "QiGai", "")
  end
  self.cbtn_label_1.NpcTypes = "1996"
  self.cbtn_label_2.NpcTypes = "1997"
  self.cbtn_label_3.NpcTypes = "1998"
  self.cbtn_label_4.NpcTypes = "1999"
  local sect = ini:FindSectionIndex("CaiJi")
  if 0 <= sect then
    self.cbtn_buyu.NpcTypes = ini:ReadString(sect, "BuYu", "")
    self.cbtn_kuangshi.NpcTypes = ini:ReadString(sect, "KuangShi", "")
    self.cbtn_famu.NpcTypes = ini:ReadString(sect, "FaMu", "")
    self.cbtn_caoyao.NpcTypes = ini:ReadString(sect, "CaoYao", "")
    self.cbtn_duyao.NpcTypes = ini:ReadString(sect, "DuYao", "")
  end
  load_check_flag(self)
  update_teammates()
  change_form_size()
end
function on_main_form_close(self)
  save_check_flag(self)
  nx_destroy(self)
end
function update_label_arrow(lbl, expand)
  lbl.AutoSize = true
  lbl.BackImage = expand and "gui\\map\\mapn\\jiantou_down_out.png" or "gui\\map\\mapn\\jiantou_right_out.png"
  lbl.AutoSize = false
end
function change_form_size()
  local form = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form) then
    return
  end
  local btn = form.btn_spot
  local head = btn.GroupBoxHead
  local list = btn.GroupBoxList
  local height = head.Top + head.Height
  list.Visible = btn.Expand
  if list.Visible then
    list.Top = height
    height = list.Top + list.Height
  end
  update_label_arrow(btn.LabelArrow, btn.Expand)
  local btn = form.btn_life
  local head = btn.GroupBoxHead
  local list = btn.GroupBoxList
  head.Top = height
  local height = head.Top + head.Height
  list.Visible = btn.Expand
  if list.Visible then
    list.Top = height
    height = list.Top + list.Height
  end
  update_label_arrow(btn.LabelArrow, btn.Expand)
  local btn = form.btn_team
  local head = btn.GroupBoxHead
  local list = btn.GroupBoxList
  head.Top = height
  local height = head.Top + head.Height
  list.Visible = btn.Expand
  if list.Visible then
    list.Top = height
    height = list.Top + list.Height
  end
  update_label_arrow(btn.LabelArrow, btn.Expand)
  local btn = form.btn_label
  local head = btn.GroupBoxHead
  local list = btn.GroupBoxList
  head.Top = height
  local height = head.Top + head.Height
  list.Visible = btn.Expand
  if list.Visible then
    list.Top = height
    height = list.Top + list.Height
  end
  update_label_arrow(btn.LabelArrow, btn.Expand)
  local btn = form.btn_caiji
  local head = btn.GroupBoxHead
  local list = btn.GroupBoxList
  head.Top = height
  local height = head.Top + head.Height
  list.Visible = btn.Expand
  if list.Visible then
    list.Top = height
    height = list.Top + list.Height
  end
  update_label_arrow(btn.LabelArrow, btn.Expand)
  form.groupbox_func.Height = height + 10
  form.Height = form.groupbox_func.Height + 10
  local gui = nx_value("gui")
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if nx_is_valid(form) and nx_is_valid(form_map) then
    form.AbsLeft = form_map.AbsLeft + form_map.Width
    form.AbsTop = form_map.AbsTop + 40
    if form.AbsLeft + form.Width > gui.Desktop.Width then
      form.AbsLeft = gui.Desktop.Width - form.Width
    end
  end
end
function on_btn_spot_click(self)
  self.Expand = not self.Expand
  change_form_size()
end
function on_btn_life_click(self)
  self.Expand = not self.Expand
  change_form_size()
end
function on_btn_team_click(self)
  self.Expand = not self.Expand
  change_form_size()
end
function on_btn_label_click(self)
  self.Expand = not self.Expand
  change_form_size()
end
function on_btn_caiji_click(self)
  self.Expand = not self.Expand
  change_form_size()
end
function show_npc_by_type(types, flag)
  local form = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form) then
    return
  end
  local lst = util_split_string(types, ",")
  for _, t in ipairs(lst) do
    if t == "-1" then
      form.groupmap_objs:ShowAllType(flag)
      return
    end
    form.groupmap_objs:ShowType(t, flag)
  end
end
function on_cbtn_smallteam_checked_changed(self)
  update_teammates()
end
function on_cbtn_bigteam_checked_changed(self)
  update_teammates()
end
function on_check_changed_spot_npc(self)
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_shangdian,
    form_func.cbtn_chefu,
    form_func.cbtn_fuhuodian,
    form_func.cbtn_chuansongmen
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_func.Checked and btn.Checked)
  end
end
function on_cbtn_select_spot_checked_changed(self)
  local form_func = self.ParentForm
  local cbtns = {
    form_func.cbtn_shangdian,
    form_func.cbtn_chefu,
    form_func.cbtn_fuhuodian,
    form_func.cbtn_chuansongmen
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = self.Checked
  end
end
function update_spot_npc()
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_shangdian,
    form_func.cbtn_chefu,
    form_func.cbtn_fuhuodian,
    form_func.cbtn_chuansongmen
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_func.Checked and btn.Checked)
  end
end
function on_check_changed_caiji_npc(self)
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  if self.Checked then
    form_map.btn_caiji.Checked = true
  end
  local cbtns = {
    form_func.cbtn_buyu,
    form_func.cbtn_kuangshi,
    form_func.cbtn_famu,
    form_func.cbtn_caoyao,
    form_func.cbtn_duyao
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_caiji.Checked and btn.Checked)
  end
end
function on_cbtn_select_caiji_checked_changed(self)
  local form_func = self.ParentForm
  local cbtns = {
    form_func.cbtn_buyu,
    form_func.cbtn_kuangshi,
    form_func.cbtn_famu,
    form_func.cbtn_caoyao,
    form_func.cbtn_duyao
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = self.Checked
  end
end
function update_caiji_npc()
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_buyu,
    form_func.cbtn_kuangshi,
    form_func.cbtn_famu,
    form_func.cbtn_caoyao,
    form_func.cbtn_duyao
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_caiji.Checked and btn.Checked)
  end
end
function on_check_changed_life_npc(self)
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  if self.Checked then
    form_map.btn_life.Checked = true
  end
  local cbtns = {
    form_func.cbtn_kuanggong,
    form_func.cbtn_tiejiang,
    form_func.cbtn_yufu,
    form_func.cbtn_qiaofu,
    form_func.cbtn_nongfu,
    form_func.cbtn_liehu,
    form_func.cbtn_caifeng,
    form_func.cbtn_jinjiang,
    form_func.cbtn_yaoshi,
    form_func.cbtn_dushi,
    form_func.cbtn_chushi,
    form_func.cbtn_qinshi,
    form_func.cbtn_qishi,
    form_func.cbtn_shusheng,
    form_func.cbtn_huashi,
    form_func.cbtn_guashi,
    form_func.cbtn_qigai
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_life.Checked and btn.Checked)
  end
end
function on_cbtn_select_life_checked_changed(self)
  local form_func = self.ParentForm
  local cbtns = {
    form_func.cbtn_kuanggong,
    form_func.cbtn_tiejiang,
    form_func.cbtn_yufu,
    form_func.cbtn_qiaofu,
    form_func.cbtn_nongfu,
    form_func.cbtn_liehu,
    form_func.cbtn_caifeng,
    form_func.cbtn_jinjiang,
    form_func.cbtn_yaoshi,
    form_func.cbtn_dushi,
    form_func.cbtn_chushi,
    form_func.cbtn_qinshi,
    form_func.cbtn_qishi,
    form_func.cbtn_shusheng,
    form_func.cbtn_huashi,
    form_func.cbtn_guashi,
    form_func.cbtn_qigai
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = self.Checked
  end
end
function update_life_npc()
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_kuanggong,
    form_func.cbtn_tiejiang,
    form_func.cbtn_yufu,
    form_func.cbtn_qiaofu,
    form_func.cbtn_nongfu,
    form_func.cbtn_liehu,
    form_func.cbtn_caifeng,
    form_func.cbtn_jinjiang,
    form_func.cbtn_yaoshi,
    form_func.cbtn_dushi,
    form_func.cbtn_chushi,
    form_func.cbtn_qinshi,
    form_func.cbtn_qishi,
    form_func.cbtn_shusheng,
    form_func.cbtn_huashi,
    form_func.cbtn_guashi,
    form_func.cbtn_qigai
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_life.Checked and btn.Checked)
  end
end
function on_cbtn_select_team_checked_changed(self)
  local form_func = self.ParentForm
  local cbtns = {
    form_func.cbtn_smallteam,
    form_func.cbtn_bigteam
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = self.Checked
  end
end
function update_teammates()
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  form_map.show_teammates = form_func.cbtn_smallteam.Checked and form_map.btn_friend.Checked
end
function on_checked_changed_label(self)
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_label_1,
    form_func.cbtn_label_2,
    form_func.cbtn_label_3,
    form_func.cbtn_label_4
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_label.Checked and btn.Checked)
  end
end
function on_cbtn_select_label_checked_changed(self)
  local form_func = self.ParentForm
  local cbtns = {
    form_func.cbtn_label_1,
    form_func.cbtn_label_2,
    form_func.cbtn_label_3,
    form_func.cbtn_label_4
  }
  for _, btn in ipairs(cbtns) do
    btn.Checked = self.Checked
  end
end
function update_label_npc()
  local form_func = nx_value("form_stage_main\\form_map\\form_map_func")
  if not nx_is_valid(form_func) then
    return
  end
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local cbtns = {
    form_func.cbtn_label_1,
    form_func.cbtn_label_2,
    form_func.cbtn_label_3,
    form_func.cbtn_label_4
  }
  for _, btn in ipairs(cbtns) do
    show_npc_by_type(btn.NpcTypes, form_map.btn_label.Checked and btn.Checked)
  end
end
function load_check_flag(self)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local ini = nx_null()
  if nx_find_custom(form_map, "map_ui_ini") and nx_is_valid(form_map.map_ui_ini) then
    ini = form_map.map_ui_ini
  end
  if nx_is_valid(ini) then
    self.cbtn_shangdian.Checked = 1 == ini:ReadInteger("MainFunc", "ShangDian", 1)
    self.cbtn_chefu.Checked = 1 == ini:ReadInteger("MainFunc", "MaFu", 1)
    self.cbtn_fuhuodian.Checked = 1 == ini:ReadInteger("MainFunc", "FuHuo", 1)
    self.cbtn_chuansongmen.Checked = 1 == ini:ReadInteger("MainFunc", "ChuanSong", 1)
    self.cbtn_kuanggong.Checked = 1 == ini:ReadInteger("Life", "KuangGong", 1)
    self.cbtn_tiejiang.Checked = 1 == ini:ReadInteger("Life", "TieJiang", 1)
    self.cbtn_yufu.Checked = 1 == ini:ReadInteger("Life", "YuFu", 1)
    self.cbtn_qiaofu.Checked = 1 == ini:ReadInteger("Life", "QiaoFu", 1)
    self.cbtn_nongfu.Checked = 1 == ini:ReadInteger("Life", "NongFu", 1)
    self.cbtn_liehu.Checked = 1 == ini:ReadInteger("Life", "LieHu", 1)
    self.cbtn_caifeng.Checked = 1 == ini:ReadInteger("Life", "CaiFeng", 1)
    self.cbtn_jinjiang.Checked = 1 == ini:ReadInteger("Life", "JinJiang", 1)
    self.cbtn_yaoshi.Checked = 1 == ini:ReadInteger("Life", "YaoShi", 1)
    self.cbtn_dushi.Checked = 1 == ini:ReadInteger("Life", "DuShi", 1)
    self.cbtn_chushi.Checked = 1 == ini:ReadInteger("Life", "ChuShi", 1)
    self.cbtn_qinshi.Checked = 1 == ini:ReadInteger("Life", "QinShi", 1)
    self.cbtn_qishi.Checked = 1 == ini:ReadInteger("Life", "QiShi", 1)
    self.cbtn_shusheng.Checked = 1 == ini:ReadInteger("Life", "ShuSheng", 1)
    self.cbtn_huashi.Checked = 1 == ini:ReadInteger("Life", "HuaShi", 1)
    self.cbtn_guashi.Checked = 1 == ini:ReadInteger("Life", "GuaShi", 1)
    self.cbtn_qigai.Checked = 1 == ini:ReadInteger("Life", "QiGai", 1)
    self.cbtn_smallteam.Checked = 1 == ini:ReadInteger("Team", "SmallTeam", 1)
    self.cbtn_bigteam.Checked = 1 == ini:ReadInteger("Team", "BigTeam", 1)
    self.cbtn_buyu.Checked = 1 == ini:ReadInteger("CaiJi", "BuYu", 1)
    self.cbtn_kuangshi.Checked = 1 == ini:ReadInteger("CaiJi", "KuangShi", 1)
    self.cbtn_famu.Checked = 1 == ini:ReadInteger("CaiJi", "FaMu", 1)
    self.cbtn_caoyao.Checked = 1 == ini:ReadInteger("CaiJi", "CaoYao", 1)
    self.cbtn_duyao.Checked = 1 == ini:ReadInteger("CaiJi", "DuYao", 1)
    self.cbtn_select_spot.Checked = 1 == ini:ReadInteger("SubFilter", "MainFunc", 1)
    self.cbtn_select_life.Checked = 1 == ini:ReadInteger("SubFilter", "Life", 1)
    self.cbtn_select_team.Checked = 1 == ini:ReadInteger("SubFilter", "Team", 1)
    self.cbtn_select_caiji.Checked = 1 == ini:ReadInteger("SubFilter", "CaiJi", 0)
    self.cbtn_select_label.Checked = 1 == ini:ReadInteger("SubFilter", "BiaoQian", 0)
    form_map.btn_func.Checked = 1 == ini:ReadInteger("MainFilter", "MainFunc", 0)
    form_map.btn_life.Checked = 1 == ini:ReadInteger("MainFilter", "Life", 0)
    form_map.btn_friend.Checked = 1 == ini:ReadInteger("MainFilter", "Team", 0)
    form_map.btn_caiji.Checked = 1 == ini:ReadInteger("MainFilter", "CaiJi", 0)
    form_map.btn_label.Checked = 1 == ini:ReadInteger("MainFilter", "BiaoQian", 0)
    form_map.btn_task.Checked = 1 == ini:ReadInteger("MainFilter", "Task", 1)
    form_map.btn_tiguan.Checked = 1 == ini:ReadInteger("MainFilter", "TiGuan", 1)
    form_map.btn_clone.Checked = 1 == ini:ReadInteger("MainFilter", "Clone", 1)
    form_map.btn_bangpai.Checked = 1 == ini:ReadInteger("MainFilter", "BangPai", 0)
  end
end
function save_check_flag(self)
  local form_map = nx_value("form_stage_main\\form_map\\form_map_scene")
  if not nx_is_valid(form_map) then
    return
  end
  local ini = nx_null()
  if nx_find_custom(form_map, "map_ui_ini") and nx_is_valid(form_map.map_ui_ini) then
    ini = form_map.map_ui_ini
  end
  if nx_is_valid(ini) then
    ini:WriteInteger("MainFunc", "ShangDian", self.cbtn_shangdian.Checked)
    ini:WriteInteger("MainFunc", "MaFu", self.cbtn_chefu.Checked)
    ini:WriteInteger("MainFunc", "FuHuo", self.cbtn_fuhuodian.Checked)
    ini:WriteInteger("MainFunc", "ChuanSong", self.cbtn_chuansongmen.Checked)
    ini:WriteInteger("Life", "KuangGong", self.cbtn_kuanggong.Checked)
    ini:WriteInteger("Life", "TieJiang", self.cbtn_tiejiang.Checked)
    ini:WriteInteger("Life", "YuFu", self.cbtn_yufu.Checked)
    ini:WriteInteger("Life", "QiaoFu", self.cbtn_qiaofu.Checked)
    ini:WriteInteger("Life", "NongFu", self.cbtn_nongfu.Checked)
    ini:WriteInteger("Life", "LieHu", self.cbtn_liehu.Checked)
    ini:WriteInteger("Life", "CaiFeng", self.cbtn_caifeng.Checked)
    ini:WriteInteger("Life", "JinJiang", self.cbtn_jinjiang.Checked)
    ini:WriteInteger("Life", "YaoShi", self.cbtn_yaoshi.Checked)
    ini:WriteInteger("Life", "DuShi", self.cbtn_dushi.Checked)
    ini:WriteInteger("Life", "ChuShi", self.cbtn_chushi.Checked)
    ini:WriteInteger("Life", "QinShi", self.cbtn_qinshi.Checked)
    ini:WriteInteger("Life", "QiShi", self.cbtn_qishi.Checked)
    ini:WriteInteger("Life", "ShuSheng", self.cbtn_shusheng.Checked)
    ini:WriteInteger("Life", "HuaShi", self.cbtn_huashi.Checked)
    ini:WriteInteger("Life", "GuaShi", self.cbtn_guashi.Checked)
    ini:WriteInteger("Life", "QiGai", self.cbtn_qigai.Checked)
    ini:WriteInteger("Team", "SmallTeam", self.cbtn_smallteam.Checked)
    ini:WriteInteger("Team", "BigTeam", self.cbtn_bigteam.Checked)
    ini:WriteInteger("CaiJi", "BuYu", self.cbtn_buyu.Checked)
    ini:WriteInteger("CaiJi", "KuangShi", self.cbtn_kuangshi.Checked)
    ini:WriteInteger("CaiJi", "FaMu", self.cbtn_famu.Checked)
    ini:WriteInteger("CaiJi", "CaoYao", self.cbtn_caoyao.Checked)
    ini:WriteInteger("CaiJi", "DuYao", self.cbtn_duyao.Checked)
    ini:WriteInteger("SubFilter", "MainFunc", self.cbtn_select_spot.Checked)
    ini:WriteInteger("SubFilter", "Life", self.cbtn_select_life.Checked)
    ini:WriteInteger("SubFilter", "Team", self.cbtn_select_team.Checked)
    ini:WriteInteger("SubFilter", "CaiJi", self.cbtn_select_caiji.Checked)
    ini:WriteInteger("SubFilter", "BiaoQian", self.cbtn_select_label.Checked)
    ini:WriteInteger("MainFilter", "MainFunc", form_map.btn_func.Checked)
    ini:WriteInteger("MainFilter", "Life", form_map.btn_life.Checked)
    ini:WriteInteger("MainFilter", "Team", form_map.btn_friend.Checked)
    ini:WriteInteger("MainFilter", "CaiJi", form_map.btn_caiji.Checked)
    ini:WriteInteger("MainFilter", "BiaoQian", form_map.btn_label.Checked)
    ini:WriteInteger("MainFilter", "Task", form_map.btn_task.Checked)
    ini:WriteInteger("MainFilter", "TiGuan", form_map.btn_tiguan.Checked)
    ini:WriteInteger("MainFilter", "Clone", form_map.btn_clone.Checked)
    ini:WriteInteger("MainFilter", "BangPai", form_map.btn_bangpai.Checked)
    ini:SaveToFile()
  end
end
function on_btn_close_click(self)
  local form = self.ParentForm
  form.Visible = false
end
