//+------------------------------------------------------------------+
//|                                                       Result.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <_Ata\General\Macros.mqh>
#include "TaskData.mqh"
#include "ResultData.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTask : public CTaskData
 {
  void               Reset(void) override
   {
    CTaskData::Reset();
    Result.Reset();
   }
public:
  CResultData        Result;

  datetime           ServerTime(void)                       const { return ::TimeTradeServer();}
  string             AppName(void)                          const { return DEF_APP_NAME;}
  string             Identification(void)                   const { return NodeId();}
  string             HashID(void)
   {
    string id_parms[] =
     {
      AppName(),
      Identification(),
      ::IntegerToString(AccountId()),
      ::IntegerToString((int)ServerTime())
     };
    string hash_id = DEF_DB_HASH_ID(id_parms);
    if(hash_id.Length() > 256)
      hash_id = ::StringSubstr(hash_id, 0, 256);
    return hash_id;
   }
  //---
                     CTask(void) { this.Reset();};
                    ~CTask(void) {};
  //---
  bool               ParsTaskJson(const string _json_text, const string _node_id);
  bool               IsValidTask(void);
  string             ResultJson(void);

  string             NewEquityChekPoint(void)
   {
    if(Result.IsSetEquityChekPoint())
      return Result.EquityChekPoint();//EquityPoint.GetChekPoint();

    if(IsResetTask())
      return NULL;
    //---
    return CheckEquity();
   }
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
{
  "nodeId": "string",
  "task": 1,
  "accountId": 1,
  "login": 1111,
  "investorPassword": "string",
  "server": "string",
  "hashPointA": "string",
  "hashPointB": "string",
  "initBalance": 10000.0,
  "targetPercent": 10.0,
  "dailyPercent": 8.0,
  "totalPercent": 12.0,
  "tickScalp": true,
  "tickScalpTerm": 30000, //milliseconds
  "gambeling": true,
  "gambelingPercent": 3.0,
  "news": false,
  "Weekend": true,
  "trailTotal": false,
  "trailTotalType": 1,
  "secure": false
}
*/
bool CTask::ParsTaskJson(const string _json_text, const string _node_id)
 {
  Reset();
  m_task_string = _json_text;
//::StringReplace(json_text, "'", "\"");
//--- Check json
  CJAVal json;
  /*
    string tex = NULL;

    if(!json.Deserialize(m_task_string))
      return false;
    if(json.HasKey(DEF_JSON_KEY_NODE_ID)             == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_TASK)                == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_ACC_ID)              == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_LOGIN)               == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_IS_SECURE)           == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_PASS)                == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_SERVER)              == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_POINT_DEAL)          == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_POINT_EQ)            == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_INIT_BALANCE)        == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_TARGET_PERCENT)      == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_DAILY_RISK_PERCENT)  == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_TOTAL_RISK_PERCENT)  == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_USE_TICK_SCALP)      == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_TICK_SCALP_TERM_MSC) == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_USE_GAMBELING)       == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_GAMBELING_PERCENT)   == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_USE_NEWS)            == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_USE_WEEKEND)         == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_USE_TRAIL_TOTAL)     == NULL)
      return false;
    if(json.HasKey(DEF_JSON_KEY_TRAIL_TOTAL_TYPE)    == NULL)
      return false;
  */
  if(!json.Deserialize(m_task_string)                      ||
     json.HasKey(DEF_JSON_KEY_NODE_ID)             == NULL ||
     json.HasKey(DEF_JSON_KEY_TASK)                == NULL ||
     json.HasKey(DEF_JSON_KEY_ACC_ID)              == NULL ||
     json.HasKey(DEF_JSON_KEY_LOGIN)               == NULL ||
     json.HasKey(DEF_JSON_KEY_IS_SECURE)           == NULL ||
     json.HasKey(DEF_JSON_KEY_PASS)                == NULL ||
     json.HasKey(DEF_JSON_KEY_SERVER)              == NULL ||
     json.HasKey(DEF_JSON_KEY_POINT_DEAL)          == NULL ||
     json.HasKey(DEF_JSON_KEY_POINT_EQ)            == NULL ||
     json.HasKey(DEF_JSON_KEY_INIT_BALANCE)        == NULL ||
     json.HasKey(DEF_JSON_KEY_TARGET_PERCENT)      == NULL ||
     json.HasKey(DEF_JSON_KEY_DAILY_RISK_PERCENT)  == NULL ||
     json.HasKey(DEF_JSON_KEY_TOTAL_RISK_PERCENT)  == NULL ||
     json.HasKey(DEF_JSON_KEY_USE_TICK_SCALP)      == NULL ||
     json.HasKey(DEF_JSON_KEY_TICK_SCALP_TERM_MSC) == NULL ||
     json.HasKey(DEF_JSON_KEY_USE_GAMBELING)       == NULL ||
     json.HasKey(DEF_JSON_KEY_GAMBELING_PERCENT)   == NULL ||
     json.HasKey(DEF_JSON_KEY_USE_NEWS)            == NULL ||
     json.HasKey(DEF_JSON_KEY_USE_WEEKEND)         == NULL ||
     json.HasKey(DEF_JSON_KEY_USE_TRAIL_TOTAL)     == NULL ||
     json.HasKey(DEF_JSON_KEY_TRAIL_TOTAL_TYPE)    == NULL)
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_JSON);
    return false;
   }
//--- Get Dataes
  IsSecure(json[DEF_JSON_KEY_IS_SECURE].ToBool());
  NodeId(json[DEF_JSON_KEY_NODE_ID].ToStr());
  Task((int)json[DEF_JSON_KEY_TASK].ToInt());
  AccountId((long)json[DEF_JSON_KEY_ACC_ID].ToInt());
  Login((long)json[DEF_JSON_KEY_LOGIN].ToInt());
  Password(json[DEF_JSON_KEY_PASS].ToStr());
  Server(json[DEF_JSON_KEY_SERVER].ToStr());
  CheckDeals(json[DEF_JSON_KEY_POINT_DEAL].ToStr());
  CheckEquity(json[DEF_JSON_KEY_POINT_EQ].ToStr());
  InitBalance(json[DEF_JSON_KEY_INIT_BALANCE].ToDbl());
  TargetPercent(json[DEF_JSON_KEY_TARGET_PERCENT].ToDbl());
  DailyRiskPercent(json[DEF_JSON_KEY_DAILY_RISK_PERCENT].ToDbl());
  TotalRiskPercent(json[DEF_JSON_KEY_TOTAL_RISK_PERCENT].ToDbl());
  UseTickScalp(json[DEF_JSON_KEY_USE_TICK_SCALP].ToBool());
  TickScalpTermMsc((uint)json[DEF_JSON_KEY_TICK_SCALP_TERM_MSC].ToInt());
  UseGambeling(json[DEF_JSON_KEY_USE_GAMBELING].ToBool());
  GambelingPercent(json[DEF_JSON_KEY_GAMBELING_PERCENT].ToDbl());
  UseNews(json[DEF_JSON_KEY_USE_NEWS].ToBool());
  UseWeekend(json[DEF_JSON_KEY_USE_WEEKEND].ToBool());
  UseTrailTotal(json[DEF_JSON_KEY_USE_TRAIL_TOTAL].ToBool());
  TrailTotal((int)json[DEF_JSON_KEY_TRAIL_TOTAL_TYPE].ToInt());
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTask::IsValidTask(void)
 {
  if(Task() < DEF_TASK_MIN_ID || Task() > DEF_TASK_MAX_ID)
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_TASK);
    return false;
   }
  if(AccountId() <= 0)
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_ACC_ID);
    return false;
   }
  if(Login() <= 0)
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_LOGIN);
    return false;
   }
  if(IS_EMPTY_STRING(Password()))
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_PASS);
    return false;
   }
  if(IS_EMPTY_STRING(Server()))
   {
    Result.ErrorCode(DEF_APP_ERR_INVALID_SERVER);
    return false;
   }
  if(InitBalance() < 0)
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_INIT_BALANCE);
    return false;
   }
  if(TargetPercent() < 0 || TargetPercent() > 100)
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_TARGET_PERCENT);
    return false;
   }
  if(DailyRiskPercent() < 0 || DailyRiskPercent() > 100)
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_DAILY_PERCENT);
    return false;
   }
  if(TotalRiskPercent() < 0 || TotalRiskPercent() > 100)
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_TOYAL_PERCENT);
    return false;
   }
  if(UseTickScalp() && TickScalpTermMsc() < 0)
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_TICKSCALP_TERM);
    return false;
   }
  if(UseGambeling() && (GambelingPercent() < 0 || GambelingPercent() > 100))
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_GAMBEL_PERCENT);
    return false;
   }
  if(UseTrailTotal() && (TrailTotal() < DEF_TASK_TRAIL_MIN_ID || TrailTotal() > DEF_TASK_TRAIL_MAX_ID))
   {
    Result.ErrorCode(DEF_APP_ERR_BAD_TOTAL_TRAIL_TYPE);
    return false;
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
{
   "nodeId"          : "String",    // 64
   "task"            : Int,         // TASK_UPDATE  = 1, TASK_RESET   = 2
   "accountId"       : UBigInt,     // DB.TblAcc
   "status"          : "String",    // success || fail
   "errorCode"       : Int,
   "description"     : "String",
}
*/
string CTask::ResultJson(void)
 {
  CJAVal json;

  json[DEF_JSON_KEY_NODE_ID]        = NodeId();
  json[DEF_JSON_KEY_TASK]           = Task();
  json[DEF_JSON_KEY_ACC_ID]         = AccountId();
  json[DEF_JSON_KEY_STATUS]         = Result.Status();
  json[DEF_JSON_KEY_ERR_CODE]       = Result.ErrorCode();
  json[DEF_JSON_KEY_ERR_DES]        = Result.ErrorDescription();

//string str = json.Serialize();
  return json.Serialize();
 }
//+------------------------------------------------------------------+
