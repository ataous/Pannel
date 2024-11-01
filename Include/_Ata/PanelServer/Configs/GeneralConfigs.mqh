//+------------------------------------------------------------------+
//|                                               GeneralConfigs.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property strict
//+------------------------------------------------------------------+
//| Genelral Setting                                                 |
//+------------------------------------------------------------------+
#define DEF_APP_NAME                      "PannelService"
#define DEF_PLATFORM                      "mt5"
#define DEF_DAY_SEC                       86400
#define DEF_SLEEP_INTERVAL                100
#define DEF_LICENCE_SLEEP_INTERVAL        1000
#define DEF_PAUSE_SLEEP_INTERVAL          10000
//+------------------------------------------------------------------+
//| WebSocket Setting                                                |
//+------------------------------------------------------------------+
#define DEF_WEBSOCKET_PROTOCOL            Hybi
#define DEF_WEBSOCKET_OPEN_HEADER         NULL
#define DEF_WEBSOCKET_LOSS_SECEND         30
//+------------------------------------------------------------------+
//| MySql database Setting                                           |
//+------------------------------------------------------------------+
#define DEF_DB_SOCKET                     "0"
#define DEF_DB_CLIENT_FALG                65536
//---
#define DEF_DB_TBL_USER                   "user"
#define DEF_DB_TBL_SERVER                 "server"
#define DEF_DB_TBL_ACCOUNT                "account"
#define DEF_DB_TBL_DEAL                   "deal"
#define DEF_DB_TBL_TRANSACTION            "transaction"
#define DEF_DB_TBL_POSITION               "position"
#define DEF_DB_TBL_BALANCE                "balance"
#define DEF_DB_TBL_EQUITY                 "equity"
#define DEF_DB_TBL_DRAWDOWN               "drawdown"
#define DEF_DB_TBL_OBJECTIVE              "objective"
#define DEF_DB_TBL_STATEMENT              "statement"
#define DEF_DB_TBL_NODE_HISTORY           "node_history"
#define DEF_DB_TBL_INVALID_ACCOUNT        "invalid_account"
//---
#define DEF_DB_UNREADBLE(T)               CCrypt::DbEnCrypt(T)
#define DEF_DB_READBLE(T)                 CCrypt::DbDeCrypt(T)
#define DEF_DB_HASH_ID(T)                 CCrypt::HashID(T)
//+------------------------------------------------------------------+
//| Crypto Setting                                                   |
//+------------------------------------------------------------------+
#define DEF_DEFULT_CRYPT_KEY              "Jf}dfPeQ%k4x&Z1OO$gsTnMvr8h6B@Yi]QgP%hW^y$S8CjN^RX["     // ASE256 - Hex --> Hidarifar
//---
#define DEF_APP_ENCRYPT(T)                CCrypt::AES128_BASE64(T, DEF_APP_CRYPT_KEY)
#define DEF_APP_DECRYPT(T)                CCrypt::DeAES128_BASE64(T, DEF_APP_CRYPT_KEY)
#define DEF_MY_ENCRYPT(T)                 CCrypt::MyEnCrypt(T, DEF_DEFULT_CRYPT_KEY)
#define DEF_MY_DECRYPT(T)                 CCrypt::MyDeCrypt(T, DEF_DEFULT_CRYPT_KEY)
//+------------------------------------------------------------------+
//| Json keys                                                        |
//+------------------------------------------------------------------+
#define DEF_JSON_KEY_NODE_ID              "nodeId"
#define DEF_JSON_KEY_TASK                 "task"
#define DEF_JSON_KEY_ACC_ID               "accountId"
#define DEF_JSON_KEY_LOGIN                "login"
#define DEF_JSON_KEY_PASS                 "investorPassword"
#define DEF_JSON_KEY_SERVER               "server"
#define DEF_JSON_KEY_POINT_DEAL           "hashPointA"
#define DEF_JSON_KEY_POINT_EQ             "hashPointB"
#define DEF_JSON_KEY_INIT_BALANCE         "initBalance"
#define DEF_JSON_KEY_TARGET_PERCENT       "targetPercent"
#define DEF_JSON_KEY_DAILY_RISK_PERCENT   "dailyPercent"
#define DEF_JSON_KEY_TOTAL_RISK_PERCENT   "totalPercent"
#define DEF_JSON_KEY_USE_TICK_SCALP       "tickScalp"
#define DEF_JSON_KEY_TICK_SCALP_TERM_MSC  "tickScalpTerm"
#define DEF_JSON_KEY_USE_GAMBELING        "gambeling"
#define DEF_JSON_KEY_GAMBELING_PERCENT    "gambelingPercent"
#define DEF_JSON_KEY_USE_NEWS             "news"
#define DEF_JSON_KEY_USE_WEEKEND          "weekend"
#define DEF_JSON_KEY_USE_TRAIL_TOTAL      "trailTotal"
#define DEF_JSON_KEY_TRAIL_TOTAL_TYPE     "trailTotalType"
#define DEF_JSON_KEY_IS_SECURE            "secure"
#define DEF_JSON_KEY_STATUS               "status"
#define DEF_JSON_KEY_ERR_CODE             "errorCode"
#define DEF_JSON_KEY_ERR_DES              "description"
//+------------------------------------------------------------------+
#define DEF_JSON_KEY_EQCHECK_TIME         "time"
#define DEF_JSON_KEY_EQCHECK_BALACE       "balnce"
#define DEF_JSON_KEY_EQCHECK_DAY_LIMIT    "dayLimit"
#define DEF_JSON_KEY_EQCHECK_TOTAL_LIMIT "totalLimit"
//+------------------------------------------------------------------+
#define DEF_JSON_KEY_DLCHECK_TIMEMSC      "timeMsc"
//+------------------------------------------------------------------+
//| News Param                                                       |
//+------------------------------------------------------------------+
const string rule_one_currency[] =
 {
  "AUD",
  "CAD",
  "CHF",
  "GBP",
  "NZD",
  "USD",
  "USD",
  "USD",
  "USD",
  "USD"
 };
const string rule_one_events[] =
 {
  "CPI q/q",
  "CPI m/m",
  "CPI m/m",
  "CPI m/m",
  "CPI q/q",
  "CPI m/m",
  "Nonfarm Payrolls",
  "PPI m/m",
  "FOMC Statement",
  "FOMC Press Conference"

 };
const ulong rule_one_event_ids[] =
 {
  36010014,
  124010003,
  756020001,
  826010011,
  554010005,
  840030005,
  840030016,
  840030001,
  840050002,
  840050018
 };
//---
const string rule_two_currency[] =
 {
  "AUD", "AUD", "AUD", "CAD", "CAD", "CHF", "EUR",
  "GBP", "GBP", "GBP", "NZD", "NZD", "NZD", "USD",
  "USD", "USD", "USD", "USD", "USD"
 };
const string rule_two_events[] =
 {
  "RBA Interest Rate Decision",
  "Employment Change",
  "GDP q/q",
  "employment-change",
  "GDP m/m",
  "SNB Interest Rate Decision",
  "ECB Interest Rate Decision",
  "S&P Global/CIPS Manufacturing PMI",
  "GDP m/m",
  "BoE Interest Rate Decision",
  "Employment Change q/q",
  "GDP q/q",
  "RBNZ Interest Rate Decision",
  "CB Consumer Confidence Index",
  "Core PCE Price Index m/m",
  "GDP q/q",
  "ISM Manufacturing PMI",
  "JOLTS Job Openings",
  "Retail Sales m/m"
 };
const ulong rule_two_event_ids[] =
 {
  36030008,  36010003,  36010019,  124010011, 124010021, 756010001, 999010007,
  826500001, 826010039, 826020009, 554010016, 554010024, 554020009, 840180002,
  840010001, 840010007, 840040001, 840030021, 840020010
 };
//+------------------------------------------------------------------+
