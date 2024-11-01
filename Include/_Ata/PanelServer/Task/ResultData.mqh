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
#include "..\Error\Erorr.mqh"
#include "EquityCheckPoint.mqh"
#include "DealCheckPoint.mqh"
//+------------------------------------------------------------------+
#define DEF_APP_STATUS_SUCCESS            "success"
#define DEF_APP_STATUS_FAIL               "fail"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CResultData : public CObject
 {
  string             m_status;
  long               m_login_term_msc;
  long               m_db_connection_term_msc;
  long               m_update_history_term_msc;
  long               m_load_data_term_msc;
  long               m_create_series_term_msc;
  long               m_update_equity_term_msc;
  long               m_update_report_term_msc;
  long               m_update_statement_term_msc;
  long               m_store_data_term_msc;
  long               m_full_term_msc;
  int                m_error_code;

  CEquityCheckPoint  EquityPoint;
  CDealCheckPoint    DealPoint;
public:
  void               Reset(void)
   {
    m_status = DEF_APP_STATUS_SUCCESS;
    m_login_term_msc = 0;
    m_db_connection_term_msc = 0;
    m_update_history_term_msc = 0;
    m_load_data_term_msc = 0;
    m_create_series_term_msc = 0;
    m_update_equity_term_msc = 0;
    m_update_report_term_msc = 0;
    m_update_statement_term_msc = 0;
    m_store_data_term_msc = 0;
    m_full_term_msc = 0;
    m_error_code = 0;

    EquityPoint.Reset();
    DealPoint.Reset();
   }
  //---
  string             Status(void)                           const { return m_status;}
  void               Status(const string _value)                  { m_status = _value;}
  long               LoginTermMsc(void)                     const { return m_login_term_msc;}
  void               LoginTermMsc(const long _value)              { m_login_term_msc = _value;}
  long               DbConnectionTermMsc(void)              const { return m_db_connection_term_msc;}
  void               DbConnectionTermMsc(const long _value)       { m_db_connection_term_msc = _value;}
  long               UpdateHistoryTermMsc(void)             const { return m_update_history_term_msc;}
  void               UpdateHistoryTermMsc(const long _value)      { m_update_history_term_msc = _value;}
  long               LoadDataTermMsc(void)                  const { return m_load_data_term_msc;}
  void               LoadDataTermMsc(const long _value)           { m_load_data_term_msc = _value;}
  long               CreateSeriesTermMsc(void)              const { return m_create_series_term_msc;}
  void               CreateSeriesTermMsc(const long _value)       { m_create_series_term_msc = _value;}
  long               UpdateEquityTermMsc(void)              const { return m_update_equity_term_msc;}
  void               UpdateEquityTermMsc(const long _value)       { m_update_equity_term_msc = _value;}
  long               UpdateReportTermMsc(void)              const { return m_update_report_term_msc;}
  void               UpdateReportTermMsc(const long _value)       { m_update_report_term_msc = _value;}
  long               UpdateStatementTermMsc(void)           const { return m_update_statement_term_msc;}
  void               UpdateStatementTermMsc(const long _value)    { m_update_statement_term_msc = _value;}
  long               StoreDataTermMsc(void)                 const { return m_store_data_term_msc;}
  void               StoreDataTermMsc(const long _value)          { m_store_data_term_msc = _value;}
  long               FullTermMsc(void)                      const
   {
    return(m_login_term_msc +
           m_db_connection_term_msc +
           m_update_history_term_msc +
           m_load_data_term_msc +
           m_create_series_term_msc +
           m_update_equity_term_msc +
           m_update_report_term_msc +
           m_update_statement_term_msc +
           m_store_data_term_msc);
   }
  int                ErrorCode(void)                        const { return m_error_code;}
  void               ErrorCode(const int _value)
   {
    m_error_code = _value;
    m_status = m_error_code == 0 ? DEF_APP_STATUS_SUCCESS : DEF_APP_STATUS_FAIL;
   }
  string             ErrorDescription(void)                 const { return AppErrorDescription(m_error_code);}
  string             HashPointA(void)                             { return EquityPoint.GetChekPoint();}
  string             HashPointB(void)                             { return DealPoint.GetChekPoint();}

  bool               IsSetEquityChekPoint(void)             const { return EquityPoint.IsSet();}
  string             EquityChekPoint(void)                        { return EquityPoint.GetChekPoint();}
  void               EquityChekPoint(const long   _time_msc,
                                     const double _balance,
                                     const double _day_limit,
                                     const double _total_limit)
   {
    EquityPoint.SetChekPoint(_time_msc, _balance, _day_limit, _total_limit);
   }
  string             DealChekPoint(void)     { return DealPoint.GetChekPoint();}
  void               DealChekPoint(const long _time_msc)
   {
    DealPoint.SetChekPoint(_time_msc);
   }
  //---
                     CResultData() { Reset();}
                    ~CResultData() {}
 };
//+------------------------------------------------------------------+
