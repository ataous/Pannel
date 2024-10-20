//+------------------------------------------------------------------+
//|                                                      CSymbol.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou"
#property link      "https://t.me/ProTraderSoft "

#define DEF_TRY_LOAD_RATE           10000
//--- include
//#include <Trade\SymbolInfo.mqh>
#include <_Ata\Info\SymbolInfo.mqh>
//+------------------------------------------------------------------+
//| Class CSymbol                                                    |
//+------------------------------------------------------------------+
class CSymbol : public CSymbolInfo
 {
  //--- === Data members === ---
private:
  ENUM_TIMEFRAMES    m_tf;
  matrix             m_ticks_mx;
  datetime           m_start_date;
  ulong              m_last_idx;
  //--- === Methods === ---
public:
  //--- constructor/destructor
  void               CSymbol(void);
  void              ~CSymbol(void) {};
  //---
  bool               Init(const string          pSymbol,
                          const ENUM_TIMEFRAMES pTimeframe,
                          const datetime        pStartDate);
  int                CheckLoadHistory(void);
  bool               LoadTicks(const datetime pStopDate,
                               const uint     pFlags);
  matrix             GetTicks(void) const { return m_ticks_mx; };
  bool               SearchTickLessOrEqual(const double pDblTime, vector &pResRow);
  bool               CopyLastTick(vector &pResRow);
 };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CSymbol::CSymbol(void)
 {
  m_ticks_mx.Init(0, 0);
  m_start_date = 0;
  m_last_idx = 0;
 };
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CSymbol::Init(const string          pSymbol,
                   const ENUM_TIMEFRAMES pTimeframe,
                   const datetime        pStartDate)
 {
  if(Name(pSymbol))
    if(Select(true))
     {
      m_tf         = pTimeframe;
      m_start_date = pStartDate;
      return true;
     }
//---
  return false;
 }
//+------------------------------------------------------------------+
//| Check and load quotes history                                    |
//+------------------------------------------------------------------+
int CSymbol::CheckLoadHistory(void)
 {
  ::ResetLastError();
//---
  datetime first_date = 0;
  datetime times[100];
  string curr_symbol = Name();
//--- check if symbol is selected in the Market Watch
  if(!Select())
   {
    Select(true);
    if(!Select())
     {
      if(::GetLastError() == ERR_MARKET_UNKNOWN_SYMBOL)
        return -1;
      Select(true);
     }
   }
//--- check if data is present
  ::SeriesInfoInteger(curr_symbol, m_tf, SERIES_FIRSTDATE, first_date);
  if(first_date > 0 && first_date <= m_start_date)
    return 1;
//--- don't ask for load of its own data if it is an indicator
  if(::MQLInfoInteger(MQL_PROGRAM_TYPE) == PROGRAM_INDICATOR &&
     ::Period() == m_tf &&::Symbol() == curr_symbol)
    return -4;
//--- second attempt
  if(::SeriesInfoInteger(curr_symbol, PERIOD_M1, SERIES_TERMINAL_FIRSTDATE, first_date))
   {
    //--- there is loaded data to build timeseries
    if(first_date > 0)
     {
      //--- force timeseries build
      ::CopyTime(curr_symbol, m_tf, first_date +::PeriodSeconds(m_tf), 1, times);
      //--- check date
      if(::SeriesInfoInteger(curr_symbol, m_tf, SERIES_FIRSTDATE, first_date))
        if(first_date > 0 && first_date <= m_start_date)
          return 2;
     }
   }
//--- max bars in chart from terminal options
  int max_bars =::TerminalInfoInteger(TERMINAL_MAXBARS);
//--- load symbol history info
  datetime first_server_date = 0;
  uint ltry = 0;
  while(!::SeriesInfoInteger(curr_symbol, PERIOD_M1, SERIES_SERVER_FIRSTDATE, first_server_date) &&
        ltry < DEF_TRY_LOAD_RATE &&
        !::IsStopped())
   {
    ltry++;
   }
  //if(::IsStopped() || ltry >= DEF_TRY_LOAD_RATE)
  //  return -1;
  ::Sleep(5);
//--- fix start date for loading
  if(first_server_date > m_start_date)
    m_start_date = first_server_date;
  if(first_date > 0 && first_date < first_server_date)
    ::Print("Warning: first server date ", first_server_date, " for ", curr_symbol,
            " does not match to first series date ", first_date);
//--- load data step by step
  int fail_cnt = 0;
  while(!::IsStopped())
   {
    //--- wait for timeseries build
    ltry = 0;
    while(!::SeriesInfoInteger(curr_symbol, m_tf, SERIES_SYNCHRONIZED) &&
          ltry < DEF_TRY_LOAD_RATE &&
          !::IsStopped())
     {
      ltry++;
     }
    if(::IsStopped() || ltry >= DEF_TRY_LOAD_RATE)
      return -3;
    ::Sleep(5);
    //--- ask for built bars
    int bars =::Bars(curr_symbol, m_tf);
    if(bars > 0)
     {
      if(bars >= max_bars)
        return(-2);
      //--- ask for first date
      if(::SeriesInfoInteger(curr_symbol, m_tf, SERIES_FIRSTDATE, first_date))
        if(first_date > 0 && first_date <= m_start_date)
          return 0;
     }
    //--- copying of next part forces data loading
    int copied =::CopyTime(curr_symbol, m_tf, bars, 100, times);
    if(copied > 0)
     {
      //--- check for data
      if(times[0] <= m_start_date)
        return 0;
      if(bars + copied >= max_bars)
        return -2;
      fail_cnt = 0;
     }
    else
     {
      //--- no more than 100 failed attempts
      fail_cnt++;
      if(fail_cnt >= 100)
        return -5;
      ::Sleep(10);
     }
   }
//--- stopped
  return -3;
 }
//+------------------------------------------------------------------+
//| Load ticks                                                       |
//+------------------------------------------------------------------+
bool CSymbol::LoadTicks(const datetime pStopDate,
                        const uint     pFlags)
 {
  string curr_symbol = Name();
  ulong from_msc     = 1000 * m_start_date,
        to_msc       = 1000 * pStopDate;
  if(m_ticks_mx.CopyTicksRange(curr_symbol, pFlags, from_msc, to_msc))
   {
    m_ticks_mx = m_ticks_mx.Transpose();
    return true;
   }
//---
  return false;
 }
//+------------------------------------------------------------------+
//| Search a tick less or equal                                      |
//+------------------------------------------------------------------+
bool CSymbol::SearchTickLessOrEqual(const double pDblTime, vector &pResRow)
 {
  ulong ticks_size = m_ticks_mx.Rows();
  if(pResRow.Resize(2))
   {
    pResRow.Fill(0.);
    double prev_dbl_time, curr_dbl_time;
    prev_dbl_time = curr_dbl_time = 0.;
    for(ulong idx = m_last_idx; idx < ticks_size && prev_dbl_time < pDblTime; idx++)
     {
      curr_dbl_time = m_ticks_mx[idx][0];
      if(idx > 0)
        prev_dbl_time = m_ticks_mx[idx - 1][0];;
      ulong idx_for_tick = WRONG_VALUE;
      if(curr_dbl_time == pDblTime)
       {
        idx_for_tick = idx;
       }
      else
        if(prev_dbl_time < pDblTime && curr_dbl_time > pDblTime)
         {
          if(prev_dbl_time > 0.)
            idx_for_tick = idx - 1;
         }
      if(idx_for_tick != WRONG_VALUE)
       {
        pResRow[0] = m_ticks_mx[idx_for_tick][1];
        pResRow[1] = m_ticks_mx[idx_for_tick][2];
        m_last_idx = idx_for_tick; // todo
        return true;
       }
     }
   }
//---
  return false;
 }
//+------------------------------------------------------------------+
//| Copy the last tick                                               |
//+------------------------------------------------------------------+
bool CSymbol::CopyLastTick(vector &pResRow)
 {
  if(pResRow.Resize(2))
   {
    pResRow.Fill(0.);
    if(RefreshRates())
     {
      pResRow[0] = Bid();
      pResRow[1] = Ask();
      return true;
     }
   }
//---
  return false;
 }
//+------------------------------------------------------------------+
