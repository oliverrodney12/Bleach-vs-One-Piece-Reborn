IsStatsCollectionOn = false
StatsCollectionVersion = 2
BaseAPI = "http://nine9dev.herokuapp.com/match.php?"

RECORD_RATING = true

adminDefault = false
auto_hero = nil

killLimit = 0
creepSpawnTime = 30 -- 30
doubleReward = 0 --double gold and exp
GAMEVOTE_DUELS_ACTIVE = 1

RUNE_SPAWN_INTERVAL = 60

ABANDON_TIMELIMIT = 300
HONOR_HISTORY_DAYS = 30

DUEL_WINNER_GOLD_MULTIPLER = 200 --[deprecated]

DUEL_NOBODY_WINS = 60+3 -- 1min = 60 [deprecated]

abandoned_players = {} --[deprecated]

_G.GameModeCombination = "0_1_1_0"

_G.CREEPS_LIMIT = 500
_G.tHeroesRadiant = {}
_G.tHeroesDire = {}
_G.rapierUnits = {}

_G.RadiantWonDuels = 0 --[deprecated]
_G.DireWonDuels = 0 --[deprecated]

_G.rapierEvent = true
_G.kyuubiSpawn = false

_G.nCOUNTDOWNTIMER = DUEL_INTERVAL --[deprecated]

_G.IsGameFinished = false --used in SetGameEnd(team) - BvOReborn.lua

_G.SHINOBU_EVENT_LEFT_LEG = false
_G.SHINOBU_EVENT_RIGHT_LEG = false
_G.SHINOBU_EVENT_LEFT_ARM = false
_G.SHINOBU_EVENT_RIGHT_ARM = false

-- COMMANDS
CMD_AUTOPICK = "-autopick " -- autopicks hero (e.g. -autopick rem, -autopick npc_dota_hero_queenofpain)

XP_PER_LEVEL_TABLE = {
    0,
    200,
    590,
    990,
    1490,
    2630,
    3330,
    4130,
    5030,
    6030,
    7130,
    11030,
    12330,
    13730,
    15230,
    16830,
    18530,
    20330,
    22230,
    31130,
    33230,
    35430,
    37730,
    40130,
    42630,
    45230,
    47930,
    50730,
    53630,
    56630,
    59730,
    62930,
    66230,
    69630,
    73130,
    76730,
    80430,
    84230,
    88130,
    92130,
    96230,
    100430,
    104730,
    109130,
    113630,
    118230,
    122930,
    127730,
    132630,
    137630,
    142730,
    147930,
    153230,
    158630,
    164130,
    169730,
    175430,
    181230,
    187130,
    193130,
    199230,
    205430,
    211730,
    218130,
    224630,
    231230,
    237930,
    244730,
    251630,
    258630,
    265730,
    272930,
    280230,
    287630,
    295130,
    302730,
    310430,
    318230,
    326130,
    334130,
    342230,
    350430,
    358730,
    367130,
    375630,
    384230,
    392930,
    401730,
    410630,
    419630,
    428730,
    437930,
    447230,
    456630,
    466130,
    475730,
    485430,
    495230,
    505130,
    515130,
}

hero_preview_animation = {
    ACT_DOTA_ATTACK,
    ACT_DOTA_ATTACK2,
    ACT_DOTA_ATTACK_EVENT,
    ACT_DOTA_RUN,
    ACT_DOTA_IDLE,
    ACT_DOTA_IDLE_RARE,
    ACT_DOTA_DIE,
    ACT_DOTA_CAST_ABILITY_1,
    ACT_DOTA_CAST_ABILITY_2,
    ACT_DOTA_CAST_ABILITY_3,
    ACT_DOTA_CAST_ABILITY_4,
    ACT_DOTA_CAST_ABILITY_5,
    ACT_DOTA_CHANNEL_ABILITY_1,
    ACT_DOTA_CHANNEL_ABILITY_2,
    ACT_DOTA_CHANNEL_ABILITY_3,
    ACT_DOTA_CHANNEL_ABILITY_4,
    ACT_DOTA_CHANNEL_ABILITY_5,
}

hero_model_done = {
    "npc_dota_hero_drow_ranger",
    "npc_dota_hero_ursa",
}

stat_collect_unit_timings = {
    "npc_dota_forgotten_one",
    "npc_dota_mimic",
    "npc_dota_kyuubi",
    "npc_dota_oz_11",
    "npc_dota_oz_22",
    "npc_dota_oz_33",
    "npc_dota_oz_44",
    "npc_dota_oz_55",
    "npc_dota_oz_66",
    "npc_dota_oz_77",
    "npc_dota_oz_88",
    "npc_dota_oz_99",
    "npc_dota_oz_100",
    "npc_boss_maximillian_bladebane",
}

secret_hero_pool = {
    "npc_dota_hero_queenofpain",
    "npc_dota_hero_windrunner",
}

cd_reduction_items = {
    "item_doom_4",
    "item_doom_5",
}

name_lookup = {}
name_lookup["npc_dota_hero_juggernaut"] =           "Ichigo"
name_lookup["npc_dota_hero_zuus"] =                 "Enel"
name_lookup["npc_dota_hero_ember_spirit"] =         "Ace"
name_lookup["npc_dota_hero_antimage"] =             "Mihawk"
name_lookup["npc_dota_hero_luna"] =                 "Orihime"
name_lookup["npc_dota_hero_sniper"] =               "Ishida"
name_lookup["npc_dota_hero_doom_bringer"] =         "Yamamoto"
name_lookup["npc_dota_hero_dragon_knight"] =        "Zaraki"
name_lookup["npc_dota_hero_riki"] =                 "Luffy"
name_lookup["npc_dota_hero_sven"] =                 "Zoro"
name_lookup["npc_dota_hero_lycan"] =                "Crocodile"
name_lookup["npc_dota_hero_phantom_assassin"] =     "Soifon"
name_lookup["npc_dota_hero_kunkka"] =               "Byakuya"
name_lookup["npc_dota_hero_skeleton_king"] =        "Toshiro"
name_lookup["npc_dota_hero_naga_siren"] =           "Rukia"
name_lookup["npc_dota_hero_slark"] =                "Hollow Ichigo"
name_lookup["npc_dota_hero_night_stalker"] =        "Lucci"
name_lookup["npc_dota_hero_bane"] =                 "Moria"
name_lookup["npc_dota_hero_elder_titan"] =          "Sanji"
name_lookup["npc_dota_hero_techies"] =              "Usopp"
name_lookup["npc_dota_hero_lina"] =                 "Nami"
name_lookup["npc_dota_hero_phantom_lancer"] =       "Aokiji"
name_lookup["npc_dota_hero_spectre"] =              "Yoruichi"
name_lookup["npc_dota_hero_queenofpain"] =          "Shinobu"
name_lookup["npc_dota_hero_keeper_of_the_light"] =  "Kuma"
name_lookup["npc_dota_hero_beastmaster"] =          "Brook"
name_lookup["npc_dota_hero_mirana"] =               "Robin"
name_lookup["npc_dota_hero_troll_warlord"] =        "Ikkaku"
name_lookup["npc_dota_hero_terrorblade"] =          "Tousen"
name_lookup["npc_dota_hero_bloodseeker"] =          "Renji"
name_lookup["npc_dota_hero_slardar"] =              "Sado"
name_lookup["npc_dota_hero_windrunner"] =           "Megumin"
name_lookup["npc_dota_hero_axe"] =                  "Squall"
name_lookup["npc_dota_hero_necrolyte"] =            "Mayuri"
name_lookup["npc_dota_hero_huskar"] =               "Law"
name_lookup["npc_dota_hero_earthshaker"] =          "Whitebeard"
name_lookup["npc_dota_hero_templar_assassin"] =     "Rory"
name_lookup["npc_dota_hero_enigma"] =               "Ulquiorra"
name_lookup["npc_dota_hero_centaur"] =              "Aizen"
name_lookup["npc_dota_hero_drow_ranger"] =          "Harribel"
name_lookup["npc_dota_hero_ursa"] =                 "Akainu"
name_lookup["npc_dota_hero_enchantress"] =          "Anzu"
name_lookup["npc_dota_hero_vengefulspirit"] =       "Rem"
name_lookup["npc_dota_hero_phoenix"] =              "Kiss-Shot Acerola-Orion Heart-Under-Blade"

model_lookup = {}
model_lookup["npc_dota_hero_brewmaster"] =                  "models/heroes/brewmaster/brewmaster.vmdl"
--Custom models
model_lookup["npc_dota_hero_juggernaut"] =                  "models/hero_ichigo/hero_ichigo_base.vmdl"
model_lookup["npc_dota_hero_zuus"] =                        "models/hero_enel2/hero_enel2_base.vmdl"
model_lookup["npc_dota_hero_ember_spirit"] =                "models/hero_ace/hero_ace_base.vmdl"
model_lookup["npc_dota_hero_antimage"] =                    "models/hero_mihawk2/hero_mihawk2_base.vmdl"
model_lookup["npc_dota_hero_luna"] =                        "models/hero_orihime/hero_orihime_base.vmdl"
model_lookup["npc_dota_hero_sniper"] =                      "models/hero_ishida/hero_ishida_base.vmdl"
model_lookup["npc_dota_hero_doom_bringer"] =                "models/hero_yamamoto/hero_yamamoto_base.vmdl"
model_lookup["npc_dota_hero_dragon_knight"] =               "models/hero_zaraki/hero_zaraki_base.vmdl"
model_lookup["npc_dota_hero_riki"] =                        "models/hero_luffy2/hero_luffy2_base.vmdl"
model_lookup["npc_dota_hero_sven"] =                        "models/hero_zoro/hero_zoro_base.vmdl"
model_lookup["npc_dota_hero_lycan"] =                       "models/hero_crocodile/hero_crocodile_base.vmdl"
model_lookup["npc_dota_hero_phantom_assassin"] =            "models/hero_soifon/hero_soifon_base.vmdl"
model_lookup["npc_dota_hero_kunkka"] =                      "models/hero_byakuya2/hero_byakuya2_base.vmdl"
model_lookup["npc_dota_hero_skeleton_king"] =               "models/hero_toshiro/hero_toshiro_base.vmdl"
model_lookup["npc_dota_hero_naga_siren"] =                  "models/hero_rukia/hero_rukia_base.vmdl"
model_lookup["npc_dota_hero_slark"] =                       "models/hero_hollow/hero_hollow_base.vmdl"
model_lookup["npc_dota_hero_night_stalker"] =               "models/hero_lucci/hero_lucci_base.vmdl"
model_lookup["npc_dota_hero_bane"] =                        "models/hero_moria/hero_moria_base.vmdl"
model_lookup["npc_dota_hero_elder_titan"] =                 "models/hero_sanji/hero_sanji_base.vmdl"
model_lookup["npc_dota_hero_techies"] =                     "models/hero_usopp/hero_usopp_base.vmdl"
model_lookup["npc_dota_hero_lina"] =                        "models/hero_nami/hero_nami_base.vmdl"
model_lookup["npc_dota_hero_phantom_lancer"] =              "models/hero_aokiji/hero_aokiji_base.vmdl"
model_lookup["npc_dota_hero_spectre"] =                     "models/hero_yoruichi/hero_yoruichi_base.vmdl"
model_lookup["npc_dota_hero_queenofpain"] =                 "models/hero_shinobu/hero_shinobu_base.vmdl"
model_lookup["npc_dota_hero_keeper_of_the_light"] =         "models/hero_kuma/hero_kuma_base.vmdl"
model_lookup["npc_dota_hero_beastmaster"] =                 "models/hero_brook/hero_brook_base.vmdl"
model_lookup["npc_dota_hero_mirana"] =                      "models/hero_robin2/hero_robin2_base.vmdl"
model_lookup["npc_dota_hero_troll_warlord"] =               "models/hero_ikkaku/hero_ikkaku_base.vmdl"
model_lookup["npc_dota_hero_terrorblade"] =                 "models/hero_tousen/hero_tousen_base.vmdl"
model_lookup["npc_dota_hero_bloodseeker"] =                 "models/hero_renji/hero_renji_base.vmdl"
model_lookup["npc_dota_hero_slardar"] =                     "models/hero_sado/hero_sado_base.vmdl"
model_lookup["npc_dota_hero_windrunner"] =                  "models/hero_megumin/hero_megumin_base.vmdl"
model_lookup["npc_dota_hero_axe"] =                         "models/hero_squall/hero_squall_base.vmdl"
model_lookup["npc_dota_hero_necrolyte"] =                   "models/hero_mayuri/hero_mayuri_base.vmdl"
model_lookup["npc_dota_hero_huskar"] =                      "models/hero_law/hero_law_base.vmdl"
model_lookup["npc_dota_hero_earthshaker"] =                 "models/hero_whitebeard/hero_whitebeard_base.vmdl"
model_lookup["npc_dota_hero_templar_assassin"] =            "models/hero_rory/hero_rory_base.vmdl"
model_lookup["npc_dota_hero_enigma"] =                      "models/hero_ulquiorra/hero_ulquiorra_base.vmdl"
model_lookup["npc_dota_hero_centaur"] =                     "models/hero_aizen/hero_aizen_base.vmdl"
model_lookup["npc_dota_hero_drow_ranger"] =                 "models/hero_harribel/hero_harribel_base.vmdl"
model_lookup["npc_dota_hero_ursa"] =                        "models/hero_akainu/hero_akainu_base.vmdl"
model_lookup["npc_dota_hero_enchantress"] =                 "models/hero_anzu/hero_anzu_base.vmdl"
model_lookup["npc_dota_hero_vengefulspirit"] =              "models/hero_rem/hero_rem_base.vmdl"
model_lookup["npc_dota_hero_phoenix"] =                     "models/hero_kissshot/hero_kissshot_base.vmdl"