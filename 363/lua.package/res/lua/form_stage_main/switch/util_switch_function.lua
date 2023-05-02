require("form_stage_main\\switch\\switch_define")
function on_query_switch(type, open)
  local is_open = false
  if open == 1 then
    is_open = true
  end
  local switch_func_tab = {
    [ST_NORMAL_YY_GUILD] = {
      "form_stage_main\\form_main\\form_main",
      "change_switch"
    },
    [ST_FUNCTION_WEBEXCHANGE] = {
      "form_stage_main\\form_webexchange\\form_exchange_main",
      "on_query_webexchange_switch"
    },
    [ST_SNDA_ACTIVITY_JION_MENPAI] = {
      "form_stage_main\\form_main\\form_main_map",
      "change_switch"
    },
    [ST_FUNCTION_BATTLEFIELD] = {
      "form_stage_main\\form_main\\form_main",
      "change_switch"
    },
    [ST_FUNCTION_CONSIGN] = {
      "form_stage_main\\form_bag",
      "change_switch_consign"
    },
    [ST_FUNCTION_BUY_THIRD_TASK] = {
      "form_stage_main\\form_task\\form_task_main",
      "change_switch_buy_third_task"
    },
    [ST_FUNCTION_EXCHANGE_ROLE] = {
      "form_stage_main\\form_webexchange\\form_exchange_main",
      "on_role_switch_changed"
    },
    [ST_FUNCTION_CHARGESHOP_INTEGRAL] = {
      "form_stage_main\\form_charge_shop\\form_charge_shop",
      "on_money_type_switch_changed"
    },
    [ST_FUNCTION_CHARGESHOP_WEB] = {
      "form_stage_main\\form_charge_shop\\form_charge_shop",
      "on_money_type_switch_changed"
    },
    [ST_SNDA_GEM_EGG_GAME] = {
      "form_stage_main\\form_main\\form_main",
      "change_switch"
    },
    [ST_FUNCTION_VIP_JINGXIU_1] = {
      "form_stage_main\\form_buyvip_confirm",
      "change_switch_41"
    },
    [ST_FUNCTION_VIP_JINGXIU_2] = {
      "form_stage_main\\form_buyvip_confirm",
      "change_switch_42"
    },
    [ST_FUNCTION_VIP_PRIZE] = {
      "form_stage_main\\form_vip_info",
      "on_vip_prize_switch_changed"
    },
    [ST_FUNCTION_POINT_TO_SILVERCARD] = {
      "form_stage_main\\form_consign\\form_buy_capital",
      "on_switch_changed"
    },
    [ST_FUNCTION_SILVER_TO_SILVERCARD] = {
      "form_stage_main\\form_consign\\form_buy_capital",
      "on_switch_changed"
    },
    [ST_FUNCTION_POINT_TO_BINDCARD] = {
      "form_stage_main\\form_consign\\form_buy_capital",
      "on_switch_changed"
    },
    [ST_FUNCTION_OPEN_WORD_PROTECT_TIME] = {
      "form_stage_main\\from_word_protect\\form_protect_sure",
      "on_switch_changed"
    },
    [ST_FUNCTION_EMAIL_VALIDATE] = {
      "form_stage_main\\from_word_protect\\form_protect_sure",
      "on_switch_changed"
    },
    [ST_FUNCTION_DBO_ACTIVE] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_DBO_FIRST] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_DBO_TOTAL] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_DBO_FAVOUR] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCITON_DBO_MOREACTIVE] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_LOTTERY] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_CONSUME_BACK] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_SERVER_WISH] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_GEM_EGG_GAME] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_SEEK_MINE] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCITION_FESTIVAL_SIGN] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_STRIKE_CLOCK] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_DRIVE_ANIMAL] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_KILL_PIG] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_VALENTINE_WISH] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_ACTIVITY_POINT_REBATE] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_NORMAL_ACTIVITY_DANSHENJIE_LILIAN] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_QUESTION_YUANXIAOJIE] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_SNDA_DRAGONBOATFESTIVAL] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_FUNCTION_QINGMING_REBEL] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_NORMAL_ACTIVITY_HOT_OL] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_NORMAL_ACTIVITY_PINHANSHI] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_NORMAL_ACTIVITY_JISHI_XIANHUANG] = {
      "form_stage_main\\form_dbomall\\form_dbomall",
      "on_switch_changed"
    },
    [ST_NORMAL_ACTIVITY_GUIDE] = {
      "form_stage_main\\form_main\\form_main_map",
      "on_switch_changed"
    },
    [ST_FUNCTION_HOME_OWNERSHIP] = {
      "form_stage_main\\form_home\\form_home",
      "change_home_btn"
    },
    [ST_FUNCTION_HOME_BID] = {
      "form_stage_main\\form_home\\form_home",
      "change_home_btn"
    },
    [ST_FUNCTION_HOME_BUYBACK] = {
      "form_stage_main\\form_home\\form_home",
      "change_home_btn"
    }
  }
  if switch_func_tab[type] == nil then
    return
  end
  local switch_func = switch_func_tab[type]
  nx_execute(switch_func[1], switch_func[2], type, is_open)
end
