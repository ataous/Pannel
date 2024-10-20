//+------------------------------------------------------------------+
//|                                             EquityCheckPoint.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <_Ata\Web\JAson.mqh>
#include <_Ata\General\Crypt.mqh>
#include "..\Defines.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEquityCheckPoint : public CObject
 {
private:
  long               m_time_msc;
  double             m_balance,
                     m_day_limit,
                     m_total_limit;
  string             m_check_point;

  void               TimeMsc(const long _value)       { m_time_msc = _value;}
  void               Balance(const double _value)     { m_balance = _value;}
  void               DayLimit(const double _value)    { m_day_limit = _value;}
  void               TotalLimit(const double _value)  { m_total_limit = _value;}

public:
                     CEquityCheckPoint();
                    ~CEquityCheckPoint();

  void               Reset(void)
   {
    m_time_msc = 0;
    m_balance = 0;
   };

  long               TimeMsc(void)              const { return m_time_msc;}
  double             Balance(void)              const { return m_balance;}
  double             DayLimit(void)             const { return m_day_limit;}
  double             TotalLimit(void)           const { return m_total_limit;}

  void               SetChekPoint(const long   _time_msc,
                                  const double _balance,
                                  const double _day_limit,
                                  const double _total_limit);
  void               SetChekPoint(const string _hash);
  string             GetChekPoint(void);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEquityCheckPoint::CEquityCheckPoint()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEquityCheckPoint::~CEquityCheckPoint()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquityCheckPoint::SetChekPoint(const long   _time_msc,
                                     const double _balance,
                                     const double _day_limit,
                                     const double _total_limit)
 {
  m_time_msc = _time_msc;
  m_balance = _balance;
  m_day_limit = _day_limit;
  m_total_limit = _total_limit;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquityCheckPoint::SetChekPoint(const string _hash)
 {
  Reset();

  string json_text = DEF_DB_READBLE(_hash);

  CJAVal json;

  if(json.Deserialize(json_text) &&
     json.HasKey(DEF_JSON_KEY_EQCHECK_TIME) != NULL &&
     json.HasKey(DEF_JSON_KEY_EQCHECK_BALACE) != NULL &&
     json.HasKey(DEF_JSON_KEY_EQCHECK_DAY_LIMIT) != NULL &&
     json.HasKey(DEF_JSON_KEY_EQCHECK_TOTAL_LIMIT) != NULL)
   {
    m_time_msc = json[DEF_JSON_KEY_EQCHECK_TIME].ToInt();
    m_balance  = json[DEF_JSON_KEY_EQCHECK_BALACE].ToDbl();
    m_day_limit = json[DEF_JSON_KEY_EQCHECK_DAY_LIMIT].ToDbl();
    m_total_limit = json[DEF_JSON_KEY_EQCHECK_TOTAL_LIMIT].ToDbl();
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CEquityCheckPoint::GetChekPoint(void)
 {
  CJAVal json;

  json[DEF_JSON_KEY_EQCHECK_TIME]   = m_time_msc;
  json[DEF_JSON_KEY_EQCHECK_BALACE] = m_balance;
  json[DEF_JSON_KEY_EQCHECK_DAY_LIMIT] = m_day_limit;
  json[DEF_JSON_KEY_EQCHECK_TOTAL_LIMIT] = m_total_limit;

  string json_text = json.Serialize();

  m_check_point = DEF_DB_UNREADBLE(json_text);

  return m_check_point;
 }
//+------------------------------------------------------------------+
