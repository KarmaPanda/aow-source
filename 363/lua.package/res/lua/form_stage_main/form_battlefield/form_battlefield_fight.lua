require("util_gui")
require("role_composite")
local FORM_BATTLE_FIGHT = "form_stage_main\\form_battlefield\\form_battlefield_fight"
local SORT_PNG = {
  [0] = "gui\\language\\ChineseS\\battlefield\\wh.png",
  [1] = "gui\\language\\ChineseS\\battlefield\\y1.png",
  [2] = "gui\\language\\ChineseS\\battlefield\\y2.png",
  [3] = "gui\\language\\ChineseS\\battlefield\\y3.png"
}
local SCHOOL_PNG = {
  school_wumenpai = "gui\\language\\ChineseS\\shengwang\\wmp.png",
  school_shaolin = "gui\\language\\ChineseS\\shengwang\\sl.png",
  school_wudang = "gui\\language\\ChineseS\\shengwang\\wd.png",
  school_emei = "gui\\language\\ChineseS\\shengwang\\em.png",
  school_gaibang = "gui\\language\\ChineseS\\shengwang\\gb.png",
  school_junzitang = "gui\\language\\ChineseS\\shengwang\\jz.png",
  school_tangmen = "gui\\language\\ChineseS\\shengwang\\tm.png",
  school_jilegu = "gui\\language\\ChineseS\\shengwang\\jl.png",
  school_jinyiwei = "gui\\language\\ChineseS\\shengwang\\jy.png"
}
local NUM_PNG = {
  [0] = "gui\\language\\ChineseS\\battlefield\\0.png",
  [1] = "gui\\language\\ChineseS\\battlefield\\1.png",
  [2] = "gui\\language\\ChineseS\\battlefield\\2.png",
  [3] = "gui\\language\\ChineseS\\battlefield\\3.png",
  [4] = "gui\\language\\ChineseS\\battlefield\\4.png",
  [5] = "gui\\language\\ChineseS\\battlefield\\5.png",
  [6] = "gui\\language\\ChineseS\\battlefield\\6.png",
  [7] = "gui\\language\\ChineseS\\battlefield\\7.png",
  [8] = "gui\\language\\ChineseS\\battlefield\\8.png",
  [9] = "gui\\language\\ChineseS\\battlefield\\9.png"
}
local TO_MAX = 3
local CLIENT_SUBMSG_SET_WRESTLE_SORT = 6
local CLIENT_SUBMSG_REQUEST_HELP = 7
local TVT_TYPE_FIGHT = 61
function main_form_init(form)
  form.to_num = 0
  form.to_sort = 1
  form.to_names = nx_widestr("")
  form.is_leader = false
  form.count_down = 60
  form.soon_down = 10
end
function on_main_form_open(form)
  change_form_size()
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "add_form", 1, TVT_TYPE_FIGHT)
end
function refresh_count_down(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form)
  end
  local count_down = nx_number(form.count_down)
  if 0 < count_down then
    local second = count_down - 1
    form.lbl_time_1.BackImage = NUM_PNG[nx_number(nx_int(second / 10))]
    form.lbl_time_2.BackImage = NUM_PNG[nx_number(nx_int(second % 10))]
    form.count_down = nx_number(second)
  end
end
function on_main_form_close(form)
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_BATTLE_FIGHT, "refresh_count_down", form)
    timer:UnRegister(FORM_BATTLE_FIGHT, "display_close", form)
  end
  nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "del_form", 1, TVT_TYPE_FIGHT)
  nx_destroy(form)
end
function on_btn_close_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    nx_execute("form_stage_main\\form_main\\form_notice_shortcut", "check_cbtn_state", 1, TVT_TYPE_FIGHT)
    form.Visible = false
  end
end
function on_btn_friend_fight_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local lbl_friend_sort, lbl_friend_name
    local datasource = nx_string(btn.DataSource)
    if "1" == datasource then
      lbl_friend_sort = form.lbl_friend_sort_1
      lbl_friend_name = form.lbl_friend_name_1
    elseif "2" == datasource then
      lbl_friend_sort = form.lbl_friend_sort_2
      lbl_friend_name = form.lbl_friend_name_2
    elseif "3" == datasource then
      lbl_friend_sort = form.lbl_friend_sort_3
      lbl_friend_name = form.lbl_friend_name_3
    end
    btn.Visible = false
    if nx_is_valid(lbl_friend_sort) then
      lbl_friend_sort.BackImage = SORT_PNG[form.to_sort]
      lbl_friend_sort.Visible = true
    end
    form.to_sort = form.to_sort + 1
    local friend_name = nx_widestr("")
    if nx_is_valid(lbl_friend_name) then
      friend_name = lbl_friend_name.Text
    end
    if nil ~= friend_name and not nx_ws_equal(nx_widestr(""), friend_name) then
      if form.to_num < form.to_sort then
        form.to_names = form.to_names .. friend_name
      else
        form.to_names = form.to_names .. friend_name .. nx_widestr(",")
      end
    end
    if form.to_num < form.to_sort then
      form.btn_random_sort.Visible = false
      if nil ~= form.to_names and not nx_ws_equal(nx_widestr(""), form.to_names) then
        nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_SET_WRESTLE_SORT, form.to_names)
      end
      form.to_sort = 1
      form.to_names = nx_widestr("")
    end
  end
end
function on_btn_random_sort_click(btn)
  local form = btn.ParentForm
  if nx_is_valid(form) then
    local randlist = {}
    while 2 >= table.getn(randlist) do
      local rand = math.random(TO_MAX)
      local state = true
      for i = 1, table.getn(randlist) do
        if rand == randlist[i] then
          state = false
          break
        end
      end
      if state then
        table.insert(randlist, rand)
      end
    end
    local to_times = 1
    for i = 1, table.getn(randlist) do
      local group_friend = form:Find("groupbox_friend")
      if nx_is_valid(group_friend) then
        local lbl_friend_name = group_friend:Find("lbl_friend_name_" .. nx_string(randlist[i]))
        local friend_name = nx_widestr("")
        if nx_is_valid(lbl_friend_name) then
          friend_name = lbl_friend_name.Text
        end
        if nil ~= friend_name and not nx_ws_equal(nx_widestr(""), friend_name) then
          local lbl_friend_sort
          lbl_friend_sort = group_friend:Find("lbl_friend_sort_" .. nx_string(randlist[i]))
          if nx_is_valid(lbl_friend_sort) then
            lbl_friend_sort.BackImage = SORT_PNG[0]
            lbl_friend_sort.Visible = true
          end
          to_times = to_times + 1
          if to_times > form.to_num then
            form.to_names = form.to_names .. friend_name
            break
          else
            form.to_names = form.to_names .. friend_name .. nx_widestr(",")
          end
        end
      end
    end
    btn.Visible = false
    form.btn_friend_fight_1.Visible = false
    form.btn_friend_fight_2.Visible = false
    form.btn_friend_fight_3.Visible = false
    if nil ~= form.to_names and not nx_ws_equal(nx_widestr(""), form.to_names) then
      nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_SET_WRESTLE_SORT, form.to_names)
    end
    form.to_sort = 1
    form.to_names = nx_widestr("")
  end
end
function init_visible(form)
  if nx_is_valid(form) then
    form.lbl_friend_leader.Visible = true
    form.lbl_friend_sort_1.Visible = false
    form.lbl_friend_sort_2.Visible = false
    form.lbl_friend_sort_3.Visible = false
    form.btn_friend_fight_1.Visible = false
    form.btn_friend_fight_2.Visible = false
    form.btn_friend_fight_3.Visible = false
    form.btn_random_sort.Visible = false
    form.lbl_enemy_leader.Visible = true
    form.lbl_enemy_sort_1.Visible = false
    form.lbl_enemy_sort_2.Visible = false
    form.lbl_enemy_sort_3.Visible = false
  end
end
function change_form_size()
  local form = nx_value(FORM_BATTLE_FIGHT)
  if nx_is_valid(form) then
    local gui = nx_value("gui")
    if nx_is_valid(gui) then
      form.AbsLeft = 0
      form.AbsTop = 0
      form.Width = gui.Desktop.Width
      form.Height = gui.Desktop.Height
      form.btn_close.Left = form.Width - form.btn_close.Width - 15
      form.groupbox_title.Left = (form.Width - form.groupbox_title.Width) / 2
      form.btn_random_sort.Left = (form.Width - form.btn_random_sort.Width) / 2
      form.btn_random_sort.Top = form.Height - form.btn_random_sort.Height - 11
      form.groupbox_friend.Top = form.Height - form.groupbox_friend.Height - 4
      form.groupbox_enemy.Left = form.Width - form.groupbox_enemy.Width - 4
      form.groupbox_enemy.Top = form.groupbox_friend.Top
    end
  end
end
function show_enter_player(scenebox, role_info, is_self, is_friend)
  local tbl_role_info = nx_function("ext_split_wstring_ex", role_info, nx_widestr(","))
  local tbl_role = {}
  tbl_role.sex = nx_number(tbl_role_info[1])
  tbl_role.hair = nx_string(tbl_role_info[8])
  tbl_role.cloth = nx_string(tbl_role_info[10])
  tbl_role.pants = nx_string(tbl_role_info[11])
  tbl_role.shoes = nx_string(tbl_role_info[12])
  if nx_find_custom(scenebox, "actor2") and nx_is_valid(scenebox.actor2) then
    local world = nx_value("world")
    world:Delete(scenebox.actor2)
  end
  if not nx_is_valid(scenebox.Scene) then
    nx_execute("util_gui", "util_addscene_to_scenebox", scenebox)
  end
  local actor2 = create_role_composite(scenebox.Scene, true, tbl_role.sex)
  while nx_call("role_composite", "is_loading", 2, actor2) do
    nx_pause(0)
  end
  local skin_info = {
    [1] = {
      link_name = "hat",
      model_name = tbl_role.hair
    },
    [2] = {
      link_name = "cloth",
      model_name = tbl_role.cloth
    },
    [3] = {
      link_name = "pants",
      model_name = tbl_role.pants
    },
    [4] = {
      link_name = "shoes",
      model_name = tbl_role.shoes
    }
  }
  for i, info in pairs(skin_info) do
    if nil ~= info.model_name then
      link_skin(actor2, info.link_name, info.model_name .. ".xmod")
    end
  end
  util_add_model_to_scenebox(scenebox, actor2)
  if is_self then
    nx_function("ext_set_model_around_color", actor2, "0,1,0", "0.015")
  end
  scenebox.actor2 = actor2
  local form = scenebox.ParentForm
  if nx_is_valid(form) and is_friend then
    form.to_num = form.to_num + 1
    if TO_MAX < form.to_num then
      form.to_num = TO_MAX
    end
  end
end
function refresh_players_info(...)
  if 4 > table.getn(arg) then
    return
  end
  local count_down_time = nx_number(arg[1])
  local white_leader_name = nx_string(arg[2])
  local black_leader_name = nx_string(arg[3])
  local players_info = arg[4]
  local tbl_players_info = nx_function("ext_split_wstring_ex", players_info, nx_widestr("#$%"))
  local tbl_players = {}
  local length = 8
  local count = table.getn(tbl_players_info) / length
  local game_client = nx_value("game_client")
  local client_player = game_client:GetPlayer()
  local self_name = ""
  if nx_is_valid(client_player) then
    self_name = nx_string(client_player:QueryProp("Name"))
  end
  local self_side = 0
  for i = 1, count do
    local index = (i - 1) * length + 1
    local side = nx_number(tbl_players_info[index])
    local name = nx_string(tbl_players_info[index + 1])
    local school = nx_string(tbl_players_info[index + 2])
    local guild = nx_string(tbl_players_info[index + 3])
    local title = nx_string(tbl_players_info[index + 4])
    local succeed_count = nx_number(tbl_players_info[index + 5])
    local wrestle_level = nx_number(tbl_players_info[index + 6])
    local info = tbl_players_info[index + 7]
    tbl_players[i] = {}
    tbl_players[i].side = side
    tbl_players[i].name = name
    if self_name == name then
      self_side = side
    end
    tbl_players[i].school = school
    local school_png = SCHOOL_PNG[school]
    if nil == school_png or "" == school_png or "0" == school_png then
      school_png = SCHOOL_PNG.school_wumenpai
    end
    tbl_players[i].school_png = school_png
    tbl_players[i].guild = guild
    if nil == guild or "" == guild or "0" == guild then
      local gui = nx_value("gui")
      if nx_is_valid(gui) then
        tbl_players[i].guild = gui.TextManager:GetText("ui_no_bangpai")
      end
    end
    tbl_players[i].title = title
    tbl_players[i].succeed_count = succeed_count
    tbl_players[i].wrestle_level = wrestle_level
    tbl_players[i].info = info
  end
  local form = util_get_form(FORM_BATTLE_FIGHT, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.count_down = count_down_time
  if 0 >= form.count_down then
    form.count_down = 60
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  init_visible(form)
  if white_leader_name == self_name or black_leader_name == self_name then
    form.is_leader = true
  end
  for i = 1, table.getn(tbl_players) do
    if self_side == tbl_players[i].side then
      local is_self = false
      if self_name == tbl_players[i].name then
        is_self = true
      end
      if white_leader_name == tbl_players[i].name or black_leader_name == tbl_players[i].name then
        if form.is_leader then
          form.btn_friend_fight_2.Visible = true
          form.btn_random_sort.Visible = true
        end
        form.lbl_friend_name_2.Text = nx_widestr(tbl_players[i].name)
        form.lbl_friend_school_2.BackImage = tbl_players[i].school_png
        form.mltbox_friend_2:Clear()
        form.mltbox_friend_2:AddHtmlText(gui.TextManager:GetText("ui_bangpaimh") .. nx_widestr(tbl_players[i].guild), -1)
        form.mltbox_friend_2:AddHtmlText(gui.TextManager:GetText("ui_shilimh") .. gui.TextManager:GetText("desc_" .. tbl_players[i].title), -1)
        form.mltbox_friend_2:AddHtmlText(gui.TextManager:GetText("ui_rank_batwintimes") .. nx_widestr(tbl_players[i].succeed_count), -1)
        form.mltbox_friend_2:AddHtmlText(gui.TextManager:GetText("ui_BatType3Score") .. nx_widestr(tbl_players[i].wrestle_level), -1)
        show_enter_player(form.scenebox_friend_2, tbl_players[i].info, is_self, true)
      else
        local friend_name_1 = nx_string(form.lbl_friend_name_1.Text)
        local friend_name_3 = nx_string(form.lbl_friend_name_3.Text)
        local btn_friend_fight, lbl_friend_name, lbl_friend_school, mltbox_friend, scenebox_friend
        if nil == friend_name_1 or "" == friend_name_1 then
          btn_friend_fight = form.btn_friend_fight_1
          lbl_friend_name = form.lbl_friend_name_1
          lbl_friend_school = form.lbl_friend_school_1
          mltbox_friend = form.mltbox_friend_1
          scenebox_friend = form.scenebox_friend_1
        elseif nil == friend_name_3 or "" == friend_name_3 then
          btn_friend_fight = form.btn_friend_fight_3
          lbl_friend_name = form.lbl_friend_name_3
          lbl_friend_school = form.lbl_friend_school_3
          mltbox_friend = form.mltbox_friend_3
          scenebox_friend = form.scenebox_friend_3
        end
        if nx_is_valid(btn_friend_fight) and form.is_leader then
          btn_friend_fight.Visible = true
        end
        if nx_is_valid(lbl_friend_name) then
          lbl_friend_name.Text = nx_widestr(tbl_players[i].name)
        end
        if nx_is_valid(lbl_friend_school) then
          lbl_friend_school.BackImage = tbl_players[i].school_png
        end
        if nx_is_valid(mltbox_friend) then
          mltbox_friend:Clear()
          mltbox_friend:AddHtmlText(gui.TextManager:GetText("ui_bangpaimh") .. nx_widestr(tbl_players[i].guild), -1)
          mltbox_friend:AddHtmlText(gui.TextManager:GetText("ui_shilimh") .. gui.TextManager:GetText("desc_" .. tbl_players[i].title), -1)
          mltbox_friend:AddHtmlText(gui.TextManager:GetText("ui_rank_batwintimes") .. nx_widestr(tbl_players[i].succeed_count), -1)
          mltbox_friend:AddHtmlText(gui.TextManager:GetText("ui_BatType3Score") .. nx_widestr(tbl_players[i].wrestle_level), -1)
        end
        if nx_is_valid(scenebox_friend) then
          show_enter_player(scenebox_friend, tbl_players[i].info, is_self, true)
        end
      end
    elseif white_leader_name == tbl_players[i].name or black_leader_name == tbl_players[i].name then
      form.lbl_enemy_name_2.Text = nx_widestr(tbl_players[i].name)
      form.lbl_enemy_school_2.BackImage = tbl_players[i].school_png
      form.mltbox_enemy_2:Clear()
      form.mltbox_enemy_2:AddHtmlText(gui.TextManager:GetText("ui_bangpaimh") .. nx_widestr(tbl_players[i].guild), -1)
      form.mltbox_enemy_2:AddHtmlText(gui.TextManager:GetText("ui_shilimh") .. gui.TextManager:GetText("desc_" .. tbl_players[i].title), -1)
      form.mltbox_enemy_2:AddHtmlText(gui.TextManager:GetText("ui_rank_batwintimes") .. nx_widestr(tbl_players[i].succeed_count), -1)
      form.mltbox_enemy_2:AddHtmlText(gui.TextManager:GetText("ui_BatType3Score") .. nx_widestr(tbl_players[i].wrestle_level), -1)
      show_enter_player(form.scenebox_enemy_2, tbl_players[i].info, false, false)
    else
      local enemy_name_1 = nx_string(form.lbl_enemy_name_1.Text)
      local enemy_name_3 = nx_string(form.lbl_enemy_name_3.Text)
      local lbl_enemy_name, lbl_enemy_school, mltbox_enemy, scenebox_enemy
      if nil == enemy_name_1 or "" == enemy_name_1 then
        lbl_enemy_name = form.lbl_enemy_name_1
        lbl_enemy_school = form.lbl_enemy_school_1
        mltbox_enemy = form.mltbox_enemy_1
        scenebox_enemy = form.scenebox_enemy_1
      elseif nil == enemy_name_3 or "" == enemy_name_3 then
        lbl_enemy_name = form.lbl_enemy_name_3
        lbl_enemy_school = form.lbl_enemy_school_3
        mltbox_enemy = form.mltbox_enemy_3
        scenebox_enemy = form.scenebox_enemy_3
      end
      if nx_is_valid(lbl_enemy_name) then
        lbl_enemy_name.Text = nx_widestr(tbl_players[i].name)
      end
      if nx_is_valid(lbl_enemy_school) then
        lbl_enemy_school.BackImage = tbl_players[i].school_png
      end
      if nx_is_valid(mltbox_enemy) then
        mltbox_enemy:Clear()
        mltbox_enemy:AddHtmlText(gui.TextManager:GetText("ui_bangpaimh") .. nx_widestr(tbl_players[i].guild), -1)
        mltbox_enemy:AddHtmlText(gui.TextManager:GetText("ui_shilimh") .. gui.TextManager:GetText("desc_" .. tbl_players[i].title), -1)
        mltbox_enemy:AddHtmlText(gui.TextManager:GetText("ui_rank_batwintimes") .. nx_widestr(tbl_players[i].succeed_count), -1)
        mltbox_enemy:AddHtmlText(gui.TextManager:GetText("ui_BatType3Score") .. nx_widestr(tbl_players[i].wrestle_level), -1)
      end
      if nx_is_valid(scenebox_enemy) then
        show_enter_player(scenebox_enemy, tbl_players[i].info, false, false)
      end
    end
  end
  form.lbl_title.Text = gui.TextManager:GetText("ui_select_team_sort")
  form.lbl_time_1.BackImage = NUM_PNG[nx_number(nx_int(form.count_down / 10))]
  form.lbl_time_2.BackImage = NUM_PNG[nx_number(nx_int(form.count_down % 10))]
  form:Show()
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_BATTLE_FIGHT, "refresh_count_down", form)
    timer:UnRegister(FORM_BATTLE_FIGHT, "display_close", form)
    timer:Register(1000, -1, FORM_BATTLE_FIGHT, "refresh_count_down", form, -1, -1)
  end
end
function display_players_sort(...)
  if 2 > table.getn(arg) then
    return
  end
  local display_time = nx_number(arg[1])
  local sort_info = arg[2]
  local tbl_sort_info = nx_function("ext_split_wstring_ex", sort_info, nx_widestr("#$%"))
  local tbl_sort = {}
  local length = 2
  local count = table.getn(tbl_sort_info) / length
  for i = 1, count do
    local index = (i - 1) * length + 1
    local name = tbl_sort_info[index]
    local sort = nx_number(tbl_sort_info[index + 1])
    tbl_sort[i] = {}
    tbl_sort[i].name = name
    tbl_sort[i].sort = sort
  end
  local form = util_get_form(FORM_BATTLE_FIGHT, true, false)
  if not nx_is_valid(form) then
    return
  end
  form.soon_down = display_time
  if form.soon_down <= 0 then
    form.soon_down = 10
  end
  local gui = nx_value("gui")
  if not nx_is_valid(gui) then
    return
  end
  for i = 1, table.getn(tbl_sort) do
    friend_name_1 = form.lbl_friend_name_1.Text
    friend_name_2 = form.lbl_friend_name_2.Text
    friend_name_3 = form.lbl_friend_name_3.Text
    if nil ~= friend_name_1 and not nx_ws_equal(nx_widestr(""), friend_name_1) and nx_ws_equal(friend_name_1, tbl_sort[i].name) then
      form.lbl_friend_sort_1.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_friend_sort_1.Visible = true
      form.btn_friend_fight_1.Visible = false
    end
    if nil ~= friend_name_2 and not nx_ws_equal(nx_widestr(""), friend_name_2) and nx_ws_equal(friend_name_2, tbl_sort[i].name) then
      form.lbl_friend_sort_2.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_friend_sort_2.Visible = true
      form.btn_friend_fight_2.Visible = false
    end
    if nil ~= friend_name_3 and not nx_ws_equal(nx_widestr(""), friend_name_3) and nx_ws_equal(friend_name_3, tbl_sort[i].name) then
      form.lbl_friend_sort_3.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_friend_sort_3.Visible = true
      form.btn_friend_fight_3.Visible = false
    end
    enemy_name_1 = form.lbl_enemy_name_1.Text
    enemy_name_2 = form.lbl_enemy_name_2.Text
    enemy_name_3 = form.lbl_enemy_name_3.Text
    if nil ~= enemy_name_1 and not nx_ws_equal(nx_widestr(""), enemy_name_1) and nx_ws_equal(enemy_name_1, tbl_sort[i].name) then
      form.lbl_enemy_sort_1.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_enemy_sort_1.Visible = true
    end
    if nil ~= enemy_name_2 and not nx_ws_equal(nx_widestr(""), enemy_name_2) and nx_ws_equal(enemy_name_2, tbl_sort[i].name) then
      form.lbl_enemy_sort_2.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_enemy_sort_2.Visible = true
    end
    if nil ~= enemy_name_3 and not nx_ws_equal(nx_widestr(""), enemy_name_3) and nx_ws_equal(enemy_name_3, tbl_sort[i].name) then
      form.lbl_enemy_sort_3.BackImage = SORT_PNG[tbl_sort[i].sort]
      form.lbl_enemy_sort_3.Visible = true
    end
  end
  form.lbl_title.Text = gui.TextManager:GetText("ui_battle_prepare")
  form.lbl_time_1.BackImage = NUM_PNG[nx_number(nx_int(form.soon_down / 10))]
  form.lbl_time_2.BackImage = NUM_PNG[nx_number(nx_int(form.soon_down % 10))]
  local timer = nx_value("timer_game")
  if nx_is_valid(timer) then
    timer:UnRegister(FORM_BATTLE_FIGHT, "refresh_count_down", form)
    timer:UnRegister(FORM_BATTLE_FIGHT, "display_close", form)
    timer:Register(1000, -1, FORM_BATTLE_FIGHT, "display_close", form, -1, -1)
  end
end
function display_close(form)
  local gui = nx_value("gui")
  if nx_is_valid(gui) then
    gui.Desktop:ToFront(form)
  end
  local soon_down = nx_number(form.soon_down)
  if 0 < soon_down then
    local second = soon_down - 1
    form.lbl_time_1.BackImage = NUM_PNG[nx_number(nx_int(second / 10))]
    form.lbl_time_2.BackImage = NUM_PNG[nx_number(nx_int(second % 10))]
    form.soon_down = nx_number(second)
  else
    form:Close()
  end
end
function player_quit(...)
  if 3 > table.getn(arg) then
    return
  end
  local white_leader_name = arg[1]
  local black_leader_name = arg[2]
  local quit_player_name = arg[3]
  local form = util_get_form(FORM_BATTLE_FIGHT, false, false)
  if nx_is_valid(form) then
    local friend_name_1 = form.lbl_friend_name_1.Text
    local friend_name_2 = form.lbl_friend_name_2.Text
    local friend_name_3 = form.lbl_friend_name_3.Text
    local enemy_name_1 = form.lbl_enemy_name_1.Text
    local enemy_name_2 = form.lbl_enemy_name_2.Text
    local enemy_name_3 = form.lbl_enemy_name_3.Text
    local lbl_name, mltbox
    if nx_ws_equal(quit_player_name, friend_name_1) then
      lbl_name = form.lbl_friend_name_1
      mltbox = form.mltbox_friend_1
    elseif nx_ws_equal(quit_player_name, friend_name_2) then
      lbl_name = form.lbl_friend_name_2
      mltbox = form.mltbox_friend_2
    elseif nx_ws_equal(quit_player_name, friend_name_3) then
      lbl_name = form.lbl_friend_name_3
      mltbox = form.mltbox_friend_3
    elseif nx_ws_equal(quit_player_name, enemy_name_1) then
      lbl_name = form.lbl_enemy_name_1
      mltbox = form.mltbox_enemy_1
    elseif nx_ws_equal(quit_player_name, enemy_name_2) then
      lbl_name = form.lbl_enemy_name_2
      mltbox = form.mltbox_enemy_2
    elseif nx_ws_equal(quit_player_name, enemy_name_3) then
      lbl_name = form.lbl_enemy_name_3
      mltbox = form.mltbox_enemy_3
    end
    if nx_is_valid(lbl_name) then
      lbl_name.Text = nx_widestr("")
    end
    if nx_is_valid(mltbox) then
      mltbox:Clear()
    end
  end
end
function request_help()
  nx_execute("custom_sender", "custom_battlefield", CLIENT_SUBMSG_REQUEST_HELP)
end
