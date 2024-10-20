//+------------------------------------------------------------------+
//|                                               DealCheckPoint.mqh |
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
class CDealCheckPoint : public CObject
 {
private:
  long               m_time_msc;
  string             m_check_point;

  void               TimeMsc(const long _value)                { m_time_msc = _value;}
public:
                     CDealCheckPoint();
                    ~CDealCheckPoint();

  void               Reset(void)                               { m_time_msc = 0;};
  ulong              TimeMsc(void)                       const { return m_time_msc;}
  void               SetChekPoint(const long _time_msc)        { m_time_msc = _time_msc;}
  void               SetChekPoint(const string _hash);
  string             GetChekPoint(void);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDealCheckPoint::CDealCheckPoint()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDealCheckPoint::~CDealCheckPoint()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDealCheckPoint::SetChekPoint(const string _hash)
 {
  Reset();
  string json_text = DEF_DB_READBLE(_hash);

  CJAVal json;

  if(json.Deserialize(json_text) &&
     json.HasKey(DEF_JSON_KEY_DLCHECK_TIMEMSC) != NULL)
   {
    m_time_msc = (long)json[DEF_JSON_KEY_DLCHECK_TIMEMSC].ToInt();
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDealCheckPoint::GetChekPoint(void)
 {
  CJAVal json;

  json[DEF_JSON_KEY_DLCHECK_TIMEMSC] = m_time_msc;


  string json_text = json.Serialize();
  m_check_point = DEF_DB_UNREADBLE(json_text);

  return m_check_point;
 }
//+------------------------------------------------------------------+
