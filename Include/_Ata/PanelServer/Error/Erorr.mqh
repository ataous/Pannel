//+------------------------------------------------------------------+
//|                                                        Erorr.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
//+------------------------------------------------------------------+
//| App Erros                                                        |
//+------------------------------------------------------------------+
#define DEF_APP_ERR_NO_ERROR              0
#define DEF_APP_ERR_INVALID_JSON          5001
#define DEF_APP_ERR_INVALID_NODE_ID       5002
#define DEF_APP_ERR_INVALID_TASK          5003
#define DEF_APP_ERR_INVALID_USER_ID       5004
#define DEF_APP_ERR_INVALID_ACC_ID        5005
#define DEF_APP_ERR_INVALID_LOGIN         5006
#define DEF_APP_ERR_INVALID_PASS          5007
#define DEF_APP_ERR_INVALID_SERVER        5008
#define DEF_APP_ERR_LOGIN_FAIL            5009
#define DEF_APP_ERR_HISTORY_UPDATE_FAIL   5010
#define DEF_APP_ERR_DATA_LOAD_FAIL        5011
#define DEF_APP_ERR_SERIES_CREATE_FAIL    5012
#define DEF_APP_ERR_DB_CONN_FAIL          5013
#define DEF_APP_ERR_DB_STORE_FAIL         5014
#define DEF_APP_ERR_STATEMENT_FAIL        5015
#define DEF_APP_ERR_EQUITY_UPDATE_FAIL    5016
#define DEF_APP_ERR_REPORT_UPDATE_FAIL    5017
#define DEF_APP_ERR_INVALID_ACC           5018
#define DEF_APP_ERR_SERVICE_STOP          5019
#define DEF_APP_ERR_BAD_INIT_BALANCE      5020
#define DEF_APP_ERR_BAD_TARGET_PERCENT    5021
#define DEF_APP_ERR_BAD_DAILY_PERCENT     5022
#define DEF_APP_ERR_BAD_TOYAL_PERCENT     5023
#define DEF_APP_ERR_BAD_TICKSCALP_TERM    5024
#define DEF_APP_ERR_BAD_GAMBEL_PERCENT    5025
#define DEF_APP_ERR_BAD_TOTAL_TRAIL_TYPE  5026
#define DEF_APP_ERR_NO_DEAL_TOUPDATE      5027
#define DEF_APP_ERR_HISTORY_INITIAL_FAIL  5028
#define DEF_APP_ERR_INT_CONN_FAIL         5029
#define DEF_APP_ERR_LOGIN_CONN_FAIL       5030
#define DEF_APP_ERR_LOGIN_DEALS_FAIL      5031
#define DEF_APP_ERR_LOGIN_INIT_BALANCE_FAIL 5032


//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
string AppErrorDescription(const int _code)
 {
  switch(_code)
   {
    case DEF_APP_ERR_NO_ERROR:
      return "no error";
    case DEF_APP_ERR_INVALID_JSON:
      return "invalid json format";
    case DEF_APP_ERR_INVALID_NODE_ID:
      return "invalid node id";
    case DEF_APP_ERR_INVALID_TASK:
      return "invalid task";
    case DEF_APP_ERR_INVALID_USER_ID:
      return "invalid user id";
    case DEF_APP_ERR_INVALID_ACC_ID:
      return "invalid account id";
    case DEF_APP_ERR_INVALID_LOGIN:
      return "invalid login no.";
    case DEF_APP_ERR_INVALID_PASS:
      return "invalid password";
    case DEF_APP_ERR_INVALID_SERVER:
      return "invalid server";
    case DEF_APP_ERR_LOGIN_FAIL:
      return "login fali";
    case DEF_APP_ERR_HISTORY_UPDATE_FAIL:
      return "history update fail";
    case DEF_APP_ERR_DATA_LOAD_FAIL:
      return "load data fail";
    case DEF_APP_ERR_SERIES_CREATE_FAIL:
      return "create serises fail";
    case DEF_APP_ERR_DB_CONN_FAIL:
      return "db connection fail";
    case DEF_APP_ERR_DB_STORE_FAIL:
      return "db storing fail";
    case DEF_APP_ERR_STATEMENT_FAIL:
      return "statement update fail";
    case DEF_APP_ERR_EQUITY_UPDATE_FAIL:
      return "equity update fail";
    case DEF_APP_ERR_REPORT_UPDATE_FAIL:
      return "report update fail";
    case DEF_APP_ERR_INVALID_ACC:
      return "invalid account";
    case DEF_APP_ERR_SERVICE_STOP:
      return "service stoped";
    case DEF_APP_ERR_BAD_INIT_BALANCE:
      return "invalid initial balance";
    case DEF_APP_ERR_BAD_TARGET_PERCENT:
      return "invalid target percent";
    case DEF_APP_ERR_BAD_DAILY_PERCENT:
      return "invalid daily percent";
    case DEF_APP_ERR_BAD_TOYAL_PERCENT:
      return "invalid total percent";
    case DEF_APP_ERR_BAD_TICKSCALP_TERM:
      return "invalid tick scalp term";
    case DEF_APP_ERR_BAD_GAMBEL_PERCENT:
      return "invalid gambelling percent";
    case DEF_APP_ERR_BAD_TOTAL_TRAIL_TYPE:
      return "invalid total trail type";
    case DEF_APP_ERR_NO_DEAL_TOUPDATE:
      return "no update required(no deal or position)";
    case DEF_APP_ERR_HISTORY_INITIAL_FAIL:
      return "initial calculation balance fail";
    case DEF_APP_ERR_INT_CONN_FAIL:
      return "internet connection fail";
    case DEF_APP_ERR_LOGIN_CONN_FAIL:
      return "login connection fail";
    case DEF_APP_ERR_LOGIN_DEALS_FAIL:
      return "login broker deals fail";
    case DEF_APP_ERR_LOGIN_INIT_BALANCE_FAIL:
      return "login initial balance fail";
    default:
      break;
   }
  return "unkown error";
 }
//+------------------------------------------------------------------+
