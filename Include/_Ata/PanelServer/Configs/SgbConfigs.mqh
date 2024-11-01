//+------------------------------------------------------------------+
//|                                                          SGB.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property strict
//+------------------------------------------------------------------+
//| General Setting                                                  |
//+------------------------------------------------------------------+
#define DEF_IS_DEBUG                      true
#define DEF_IS_SWAOP_IN_MID_NIGHT         false
#define DEF_APP_TRY_SEND_MAX              3
#define DEF_APP_TRY_SEND_SLEEP_MSC        100
#define DEF_APP_TRY_LOGIN_MAX             3
#define DEF_APP_TRY_LOGIN_SLEEP_MSC       1000
#define DEF_APP_TRY_TERM_CON_MAX          100
#define DEF_APP_TRY_TERM_CON_SLEEP_MSC    100
#define DEF_APP_TRY_LOAD_SYMBOL           100
#define DEF_APP_TRY_LOAD_SYMBOL_SLEEP_MSC 100
//+------------------------------------------------------------------+
//| App Report Setting                                               |
//+------------------------------------------------------------------+
enum ENUM_STOR_EQUITY_TIPE
 {
  STOR_EQUITY_FULL = 1,
  STOR_EQUITY_LIMIT = 2
 };
#define DEF_SETTING_STOR_DEAL             true
#define DEF_SETTING_STOR_POSITION         true
#define DEF_SETTING_STOR_BALANCE          true
#define DEF_SETTING_STOR_EQUITY           STOR_EQUITY_FULL
#define DEF_SETTING_STOR_OBJECTIVE        true
#define DEF_SETTING_STOR_STATEMENT        true
#define DEF_SETTING_STOR_TRANSACTION      true
//+------------------------------------------------------------------+
//| WebSocket Setting                                                |
//+------------------------------------------------------------------+
#define DEF_WEBSOCKET_SERVER              "wss://node.sgbdev.com:443"
//#define DEF_WEBSOCKET_SERVER              "wss://free.blr2.piesocket.com/v3/1?api_key=slpnzeEp97tmelOkd0vpGQndM9RhpuULsuNjtJfl&notify_self=1"

#define DEF_SEND_REULT_TO_SOCKET          true
#define DEF_SEND_REULT_TO_API             true
#define DEF_REULT_API_URL                 "https://node.sgbdev.com/api/v1/Accounts/Result"
#define DEF_REULT_API_HEADER              "Content-Type: application/json\r\n"
//+------------------------------------------------------------------+
//| MySql database Setting                                           |
//+------------------------------------------------------------------+
#define DEF_DB_TRACE                      false
#define DEF_DB_INVALID_ACC_CODE           15
//---new
#define DEF_DB_SERVER                    "63.250.32.216"
#define DEF_DB_PORT                       3306
#define DEF_DB_User                       "node"
#define DEF_DB_Password                   "JrtIlo=4d-1=xrvB{,]3&&Q8"
#define DEF_DB_DB_Name                    "sgb_node"
//#define DEF_DB_DB_Name                    "ATA_TEST"
//+------------------------------------------------------------------+
//| SeqLog Server                                                    |
//+------------------------------------------------------------------+
//#define DEF_SEQ_LOG_URL                   "https://log.sgbdev.com/ingest/clef"
#define DEF_SEQ_LOG_URL                   "http://185.110.191.118:5341/ingest/clef"
#define DEF_SEQ_LOG_HEADER                "Content-Type: application/json\r\n"
//+------------------------------------------------------------------+
//| Crypto Setting                                                   |
//+------------------------------------------------------------------+
#define DEF_APP_CRYPT_KEY                 "})zrWY%IopJ&df9h" // ASE256 - Base64
//+------------------------------------------------------------------+
//| Licecce Setting                                                  |
//+------------------------------------------------------------------+
#define DEF_LIC_URL_IR                    "https://sgbconf.s3.ir-thr-at1.arvanstorage.ir/sgb.cnf"
#define DEF_LIC_URL_COM                   "https://sgbconf.s3.ir-thr-at1.arvanstorage.com/sgb.cnf"
//+------------------------------------------------------------------+
