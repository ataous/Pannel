//+------------------------------------------------------------------+
//|                                                         Task.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "EquityCheckPoint.mqh"
#include "DealCheckPoint.mqh"
//+------------------------------------------------------------------+
//| TASK Setting                                                     |
//+------------------------------------------------------------------+
enum ENUM_TASK_TYPE
 {
  TASK_TYPE_RESET = 1,              // Algo: Normal  - From 0 time to current time  - calc all data
  TASK_TYPE_UPDATE = 2,             // Algo: Normal  - From last check point time to current time - calc all data
  TASK_TYPE_RESET_STREAM = 3,       // Algo: Normal  - From 0 time to current time  - calc all data then stream real data
  TASK_TYPE_UPDATE_SREAM = 4,       // Algo: Normal  - From last check point time to current time - calc all data then stream real data
//---
  TASK_TYPE_CHEACK = 5,             // Algo: TickByTick  - From 0 time to current time  - calc all data
//--- For 32 node in one
  TASK_TYPE_RESET_DEAL = 6,         // Algo: Normal  - From 0 time to current time - calc deals and positions
  TASK_TYPE_UPDATE_DEAL = 7,        // Algo: Normal  - From last check point time to current time - calc deals and positions

  TASK_TYPE_RESET_EQ = 8,           // Algo: Normal  - From 0 time to current time - calc Eq & obj
  TASK_TYPE_UPDATE_EQ = 9,          // Algo: Normal  - From last check point time to current time - calc Eq & obj
 };
#define DEF_TASK_MIN_ID TASK_TYPE_RESET
#define DEF_TASK_MAX_ID TASK_TYPE_UPDATE_EQ
enum ENUM_TRAIL_TYPE
 {
  TRAIL_BALANCE = 1,
  TRAIL_EQUITY  = 2
 };
#define DEF_TASK_TRAIL_MIN_ID TRAIL_BALANCE
#define DEF_TASK_TRAIL_MAX_ID TRAIL_EQUITY
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTaskData : public CObject
 {
protected:
  string             m_task_string;
  string             m_node_id;
  int                m_task;
  long               m_acc_id,
                     m_login;
  string             m_password,
                     m_raw_password,
                     m_server,
                     m_check_deals,
                     m_check_eq;
  bool               m_is_secure;
  double             m_init_balance,
                     m_target_percent,
                     m_daily_risk_percent,
                     m_total_risk_percent;
  bool               m_use_tick_scalp;
  int                m_tick_scalp_term_msc;
  bool               m_use_gambeling;
  double             m_gambeling_percent;
  bool               m_use_news;
  bool               m_use_weekend;
  bool               m_use_trail_total;
  int                m_trail_total;

  CEquityCheckPoint  EquityPoint;
  CDealCheckPoint    DealPoint;
public:
  virtual void       Reset(void)
   {
    m_task_string = NULL;
    m_node_id = NULL;
    m_task = 0;
    m_acc_id = 0;
    m_login = 0;
    m_password = NULL;
    m_raw_password = NULL;
    m_server = NULL;
    m_check_deals = NULL;
    m_check_eq = NULL;
    m_is_secure = false;
    m_init_balance = 0;
    m_target_percent = 10;
    m_daily_risk_percent = 5;
    m_total_risk_percent = 12;
    m_use_tick_scalp = true;
    m_tick_scalp_term_msc = 30000;
    m_use_gambeling = true;
    m_gambeling_percent = 3;
    m_use_news = false;
    m_use_weekend = true;
    m_use_trail_total = false;
    m_trail_total = TRAIL_BALANCE;

    EquityPoint.Reset();
    DealPoint.Reset();
   }
  //---
  void               NodeId(const string _value)            { m_node_id = _value;}
  string             NodeId(void)                     const { return m_node_id;}
  void               Task(const int _value)                 { m_task = _value;}
  int                Task(void)                       const { return m_task;}
  string             TaskSting(void)                  const { return ::EnumToString((ENUM_TASK_TYPE)m_task);}
  void               AccountId(const long _value)           { m_acc_id = _value;}
  long               AccountId(void)                  const { return m_acc_id;}
  void               Login(const long _value)               { m_login = _value;}
  long               Login(void)                      const { return m_login;}
  void               Password(const string _value)
   {
    if(m_is_secure)
      m_password = DEF_APP_DECRYPT(_value);
    else
      m_password = _value;
    m_raw_password = _value;
   }
  string             Password(void)                   const { return m_password;}
  string             RawPassword(void)                const { return m_raw_password;}
  void               Server(const string _value)            { m_server = _value;}
  string             Server(void)                     const { return m_server;}
  void               CheckDeals(const string _hash)
   {
    if(IsResetTask())
      return;
    DealPoint.SetChekPoint(_hash);
    m_check_deals = _hash;
   }
  string             CheckDeals(void)                 const { return m_check_deals;}
  void               CheckEquity(const string _hash)
   {
    if(IsResetTask())
      return;
    EquityPoint.SetChekPoint(_hash);
    m_check_eq = _hash;
   }
  string             CheckEquity(void)                const { return m_check_eq;}
  void               IsSecure(const bool _value)            { m_is_secure = _value;}
  bool               IsSecure(void)                   const { return m_is_secure;}
  void               InitBalance(const double _value)       { m_init_balance = _value;}
  double             InitBalance(void)                const { return m_init_balance;}
  void               TargetPercent(const double _value)     { m_target_percent = _value;}
  double             TargetPercent(void)              const { return m_target_percent;}
  void               DailyRiskPercent(const double _value)  { m_daily_risk_percent = _value;}
  double             DailyRiskPercent(void)           const { return m_daily_risk_percent;}
  void               TotalRiskPercent(const double _value)  { m_total_risk_percent = _value;}
  double             TotalRiskPercent(void)           const { return m_total_risk_percent;}
  void               UseTickScalp(const bool _value)        { m_use_tick_scalp = _value;}
  bool               UseTickScalp(void)               const { return m_use_tick_scalp;}
  void               TickScalpTermMsc(const int _value)     { m_tick_scalp_term_msc = _value;}
  int                TickScalpTermMsc(void)           const { return m_tick_scalp_term_msc;}
  void               UseGambeling(const bool _value)        { m_use_gambeling = _value;}
  bool               UseGambeling(void)               const { return m_use_gambeling;}
  void               GambelingPercent(const double _value)  { m_gambeling_percent = _value;}
  double             GambelingPercent(void)           const { return m_gambeling_percent;}
  void               UseNews(const bool _value)             { m_use_news = _value;}
  bool               UseNews(void)                    const { return m_use_news;}
  void               UseWeekend(const bool _value)          { m_use_weekend = _value;}
  bool               UseWeekend(void)                 const { return m_use_weekend;}
  void               UseTrailTotal(const bool _value)       { m_use_trail_total = _value;}
  bool               UseTrailTotal(void)              const { return m_use_trail_total;}
  void               TrailTotal(const int _value)           { m_trail_total = _value;}
  int                TrailTotal(void)                 const { return m_trail_total;}
  string             TrailTotalString(void)           const { return ::EnumToString((ENUM_TRAIL_TYPE)m_trail_total);}
  double             DailyLimitRatio(void)            const { return((100 - m_daily_risk_percent) / 100);}
  double             TotalLimitRatio(void)            const { return((100 - m_total_risk_percent) / 100);}
  //---
  long               EquityCheckPointTimeMsc(void)    const { return EquityPoint.TimeMsc();}
  double             EquityCheckPointBalance(void)    const { return EquityPoint.Balance();}
  double             EquityCheckPointDayLimit(void)   const { return EquityPoint.DayLimit();}
  double             EquityCheckPointTotalLimit(void) const { return EquityPoint.TotalLimit();}
  string             HashPointA(void)                       { return EquityPoint.GetChekPoint();}
  string             HashPointB(void)                       { return DealPoint.GetChekPoint();}
  //---
                     CTaskData() { Reset();}
                    ~CTaskData() {}

  bool               IsResetTask(void)
   {
    switch(m_task)
     {
      //case  TASK_TYPE_RESET:
      case  TASK_TYPE_RESET_STREAM:
      case  TASK_TYPE_CHEACK:
      case  TASK_TYPE_RESET_DEAL:
      case  TASK_TYPE_RESET_EQ:
        return true;
      case  TASK_TYPE_UPDATE:
      case  TASK_TYPE_UPDATE_SREAM:
      case  TASK_TYPE_UPDATE_DEAL:
      case  TASK_TYPE_UPDATE_EQ:
        return false;
     }
    return false;
   }
 };
//+------------------------------------------------------------------+
