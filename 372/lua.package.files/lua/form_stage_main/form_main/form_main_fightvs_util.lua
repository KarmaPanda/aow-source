require("util_gui")
require("util_static_data")
require("custom_sender")
require("share\\view_define")
require("define\\object_type_define")
FORM_FIGHT_VS_ALONE = "form_stage_main\\form_main\\form_main_fightvs_alone"
FORM_FIGHT_VS_ALONE_EX = "form_stage_main\\form_main\\form_main_fightvs_alone_ex"
FORM_FIGHT_VS_BUFF = "form_stage_main\\form_main\\form_main_fightvs_buff"
FORM_FIGHT_VS_SKILL = "form_stage_main\\form_main\\form_main_fightvs_skill"
FORM_FIGHT_VS_MUSICAL = "form_stage_main\\form_main\\form_main_fightvs_musical_note"
CHUZHAO_INI_FILE = "ini\\ui\\wuxue\\wuxue_chuzhao.ini"
SHOW_IMAGE_COUNT = 10
GRID_IMAGE_WIDTH = 30
MOVE_IMAGE_TIME = 1.5
ANI_TIME_BACK = 0.2
ANI_TYPE_BACK = 0.2
TABLE_MINPIC_ZHAOSHI = {
  "gui\\language\\ChineseS\\fightvs\\wu_16.png",
  "gui\\language\\ChineseS\\fightvs\\shi_16.png",
  "gui\\language\\ChineseS\\fightvs\\xu_16.png",
  "gui\\language\\ChineseS\\fightvs\\jia_16.png",
  "gui\\language\\ChineseS\\fightvs\\shu_16.png",
  "gui\\language\\ChineseS\\fightvs\\ji_16.png",
  "gui\\language\\ChineseS\\fightvs\\she_16.png"
}
TABLE_MIDPIC_ZHAOSHI = {
  "gui\\language\\ChineseS\\fightvs\\wu_24.png",
  "gui\\language\\ChineseS\\fightvs\\shi_24.png",
  "gui\\language\\ChineseS\\fightvs\\xu_24.png",
  "gui\\language\\ChineseS\\fightvs\\jia_24.png",
  "gui\\language\\ChineseS\\fightvs\\shu_24.png",
  "gui\\language\\ChineseS\\fightvs\\ji_24.png",
  "gui\\language\\ChineseS\\fightvs\\she_24.png"
}
TABLE_MAXPIC_ZHAOSHI = {
  "gui\\language\\ChineseS\\fightvs\\wu_32.png",
  "gui\\language\\ChineseS\\fightvs\\shi_32.png",
  "gui\\language\\ChineseS\\fightvs\\xu_32.png",
  "gui\\language\\ChineseS\\fightvs\\jia_32.png",
  "gui\\language\\ChineseS\\fightvs\\shu_32.png",
  "gui\\language\\ChineseS\\fightvs\\ji_32.png",
  "gui\\language\\ChineseS\\fightvs\\she_32.png"
}
TABLE_MINPIC_RESULT = {
  "gui\\language\\ChineseS\\fightvs\\sheng_1.png",
  "gui\\language\\ChineseS\\fightvs\\shu_1.png",
  "gui\\language\\ChineseS\\fightvs\\dang_1.png",
  "gui\\language\\ChineseS\\fightvs\\shan_1.png"
}
TABLE_MAXPIC_RESULT = {
  "gui\\language\\ChineseS\\fightvs\\sheng_2.png",
  "gui\\language\\ChineseS\\fightvs\\shu_2.png",
  "gui\\language\\ChineseS\\fightvs\\dang_2.png",
  "gui\\language\\ChineseS\\fightvs\\shan_2.png"
}
FIGHT_BUFF_EFFECT = {
  jiansu = {
    1,
    "4096",
    "gui\\language\\ChineseS\\fight\\jiansu_lr.png",
    "gui\\language\\ChineseS\\fight\\jiansu_lb.png",
    "fight_buff_jiansu"
  },
  jinqinggong = {
    2,
    "65536",
    "gui\\language\\ChineseS\\fight\\jinqinggong_lr.png",
    "gui\\language\\ChineseS\\fight\\jinqinggong_lb.png",
    "fight_buff_jinqinggong"
  },
  dingshen = {
    3,
    "16384",
    "gui\\language\\ChineseS\\fight\\dingshen_lr.png",
    "gui\\language\\ChineseS\\fight\\dingshen_lb.png",
    "fight_buff_dingshen"
  },
  jiaoxie = {
    4,
    "131072",
    "gui\\language\\ChineseS\\fight\\jiaoxie_lr.png",
    "gui\\language\\ChineseS\\fight\\jiaoxie_lb.png",
    "fight_buff_jiaoxie"
  },
  fengzhao = {
    5,
    "32768",
    "gui\\language\\ChineseS\\fight\\fengzhao_lr.png",
    "gui\\language\\ChineseS\\fight\\fengzhao_lb.png",
    "fight_buff_fengzhao"
  },
  hunmi = {
    6,
    "8192",
    "gui\\language\\ChineseS\\fight\\hunmi_lr.png",
    "gui\\language\\ChineseS\\fight\\hunmi_lb.png",
    "fight_buff_hunmi"
  }
}
