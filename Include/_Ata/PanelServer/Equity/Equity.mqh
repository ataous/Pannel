//+------------------------------------------------------------------+
//|                                                       Equity.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <Object.mqh>
#include "..\History\History.mqh"
#include "..\Series\Series.mqh"
#include <Arrays\ArrayObj.mqh>
//#include "..\Report\Values\RuleSeries.mqh"
//+------------------------------------------------------------------+
enum ENUM_BE_UPDATE_TYPE
 {
  UPDATE_TYPE_FAST,
  UPDATE_TYPE_NORMAL,
  UPDATE_TYPE_FULL
 };
enum ENUM_DD_SOURCE
 {
  DD_SOURCE_BALANCE = 1,
  DD_SOURCE_EQUITY  = 2,
  DD_SOURCE_UNKNOWN = 3
 };
enum ENUM_DD_TYPE
 {
  DD_TYPE_DAILY = 1,
  DD_TYPE_TOTAL = 2,
  DD_TYPE_UNKNOWN = 3
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDrawDown : public CObject
 {
public:
  ENUM_DD_SOURCE     source;
  ENUM_DD_TYPE       type;
  datetime           time;
  ulong              time_msc;
  double             limit;
  double             value;
                     CDrawDown() : source(DD_SOURCE_UNKNOWN), type(DD_TYPE_UNKNOWN), time(0), time_msc(0), limit(0), value(0) {}
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEquity : public CObject
 {
private:
  CTask              *Task;
  CHistory           *History;
  CSeries            *Series;
  MqlRates           m_prev_profit_rate;

  bool               UpdateBalance(void);
  bool               UpdateEquity(const ENUM_BE_UPDATE_TYPE _type);
  bool               CheckTotalLimiTrail(void);
  bool               FindCheckPoint(void);

  void               FillOneBar(const CPosition *_Position, const uint _bar_shift);
  void               FillOpenBar(const CPosition *_Position, const uint _bar_shift);
  void               FillOnWayBar(const CPosition *_Position, const uint _bar_shift, const ENUM_BE_UPDATE_TYPE _type);
  void               FillCloseBar(const CPosition *_Position, const uint _bar_shift);

  void               CreateOneBarRate(const CPosition *_Position,
                                      const uint      _bar_shift,
                                      MqlRates        &_res_rate);
  void               CreateOpenRate(const CPosition *_Position,
                                    const uint      _bar_shift,
                                    MqlRates        &_virtual_rate);
  bool               CreateOnWayRate(const CPosition *_Position,
                                     const uint      _bar_shift,
                                     MqlRates        &_res_rate);
  void               CreateCloseRate(const CPosition *_Position,
                                     const uint      _bar_shift,
                                     MqlRates        &_res_rate);

  bool               CreateProfitRate(const CPosition *_Position,
                                      const MqlRates  &_virtual_rate,
                                      MqlRates        &_profit_rate,
                                      const bool      _is_open    = false,
                                      const bool      _is_close   = false);

  bool               AddProfits(MqlRates &_profit_rate,
                                const uint     _bar_shift);
  double             GetTickPriceByType(MqlTick &_tick, ENUM_DEAL_TYPE _type);
  void               RestTradePrevProfit(void);
  void               SetTradePrevProfit(const MqlRates &_profit_rate);
  void               CheckEquityHighLow(void);

  bool               UpdateData(void);

  void               Reset(void)
   {
    //FREE(BalanceData);
    //FREE(EquityData);

    DrawDownList.Clear();
   }



public:
  //CRuleSeries        *BalanceData;
  //CRuleSeries        *EquityData;

  CArrayObj          DrawDownList;

                     CEquity();
                    ~CEquity();
  bool               Update(CHistory                  * _History,
                            CSeries                   * _Series,
                            CTask                     * _Task,
                            const ENUM_BE_UPDATE_TYPE _type = UPDATE_TYPE_FULL);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEquity::CEquity()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEquity::~CEquity()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::Update(CHistory                  *_History,
                     CSeries                   *_Series,
                     CTask                     *_Task,
                     const ENUM_BE_UPDATE_TYPE _type = UPDATE_TYPE_FULL)
 {
  ulong start_cnt =::GetTickCount64();
  Reset();
//---
  History = _History;
  Series = _Series;
  Task = _Task;
  if(!IS_POINTER_DYNAMIC(History) || !IS_POINTER_DYNAMIC(Series) || !IS_POINTER_DYNAMIC(Task))
    return false;
//---
  if(!UpdateBalance())
    return false;
//---
  if(!UpdateEquity(_type))
    return false;
//---
  if(!CheckTotalLimiTrail())
    return false;
//---
  if(!UpdateData())
    return false;
//---
  if(!FindCheckPoint())
    return false;
//--- succeed
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::UpdateBalance(void)
 {
//----
  uint total = History.DealsList.Total();

  for(uint i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);

    if(!IS_POINTER_DYNAMIC(Deal) && Deal.Ticket() <= 0)
      return false;

    int index = Series.GetIndex(Deal.TimeMsc());
    if(index == WRONG_VALUE)
      return false;

    double balance = Deal.Balance();
    double day_limit = Deal.DailyLimit();
    int count = (int)Series.m_balance.Size() - index;

    ::ArrayFill(Series.m_balance, index, count, balance);
    ::ArrayFill(Series.m_day_limit, index, count, day_limit);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::UpdateEquity(const ENUM_BE_UPDATE_TYPE _type)
 {
  int size = (int)Series.m_balance.Size();
  if(::ArrayCopy(Series.m_equity_open, Series.m_balance) != size ||
     ::ArrayCopy(Series.m_equity_high, Series.m_balance) != size ||
     ::ArrayCopy(Series.m_equity_low, Series.m_balance) != size ||
     ::ArrayCopy(Series.m_equity_close, Series.m_balance) != size)
    return false;
//----
  uint total = History.PositionList.Total();

  for(uint i = 0; i < total; i++)
   {
    CPosition *Position = History.PositionList.At(i);

    if(!IS_POINTER_DYNAMIC(Position))
      return false;

    int start_ser = Series.GetIndex(Position.OpenTimeMsc()),
        end_ser   = Series.GetIndex(Position.CloseTimeMsc());

    if(start_ser == WRONG_VALUE || end_ser == WRONG_VALUE)
      return false;

    for(int bar = start_ser; bar <= end_ser; bar++)
     {
      if(bar == start_ser && bar == end_ser)
       {
        FillOneBar(Position, bar);
        continue;
       }
      if(bar == start_ser)
       {
        FillOpenBar(Position, bar);
        continue;
       }
      if(bar == end_ser)
       {
        FillCloseBar(Position, bar);
        continue;
       }
      FillOnWayBar(Position, bar, _type);
     }
   }
  CheckEquityHighLow();
//--- Remove last Rate
  if(!Series.RemoveLastRate(History.EndBalance(), History.EndEquity()))
    return false;
//---

//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::CheckTotalLimiTrail(void)
 {
  if(!Task.UseTrailTotal())
    return true;
//----
  uint total = Series.Total();
  double max_value = Task.EquityCheckPointTotalLimit(),
         ratio = Task.TotalLimitRatio();

  if(Task.TrailTotal() == TRAIL_EQUITY)
   {
    for(uint i = 0; i < total; i++)
     {
      max_value = ::MathMax(max_value, Series.m_equity_high[i]);
      Series.m_total_limit[i] = max_value * ratio;
     }
   }
  else
   {
    for(uint i = 0; i < total; i++)
     {
      max_value = ::MathMax(max_value, Series.m_balance[i]);
      Series.m_total_limit[i] = max_value * ratio;
     }
   }
//----
  total = History.DealsList.Total();
  for(uint i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);
    int index = Series.GetIndex(Deal.TimeMsc());
    if(index >= 0)
      Deal.TotalLimit(Series.m_total_limit[index]);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::FindCheckPoint(void)
 {
//--- اگر تعداد پوزیشن ها حداقل یک مورد است چک پوینت معنی دارد
  if(History.PositionList.Total() <= 0)
    return true;
//--- چک پوینت محاسباتی ایکویتی
  uint total = Series.Total();
  for(uint i = total - 1; i >= 0; i--)
   {
    if(Series.m_balance[i] == Series.m_equity_open[i] &&
       Series.m_balance[i] == Series.m_equity_high[i] &&
       Series.m_balance[i] == Series.m_equity_low[i] &&
       Series.m_balance[i] == Series.m_equity_close[i])
     {
      //--- بررسی شود در آن نقطه هیچ پوزیشن بازی وجود نداشته باشد.
      if(History.IsPositionOpenAtTimeMsc(Series.m_time_msc[i]))
        continue;
      Task.Result.EquityChekPoint(Series.m_time_msc[i], Series.m_balance[i],
                                  Series.m_day_limit[i], Series.m_total_limit[i]);
      break;
     }
   }
//--- چک پوینت محاسباتی دیلز
  int index = History.DealsList.Total() - 1;
  if(index >= 0)
   {
    CDeal *Deal = History.DealsList.At(index);

    if(IS_POINTER_DYNAMIC(Deal) && Deal.TimeMsc() > 0)
      Task.Result.DealChekPoint(Deal.TimeMsc());
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::FillOneBar(const CPosition *_Position, const uint _bar_shift)
 {
  RestTradePrevProfit();
//--- create virtual rate
  MqlRates virtual_rate;
  CreateOneBarRate(_Position, _bar_shift, virtual_rate);
//--- calc profit rate
  MqlRates profit_rate;
  CreateProfitRate(_Position, virtual_rate, profit_rate, true, true);
//--- add to indData
  AddProfits(profit_rate, _bar_shift);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::FillOpenBar(const CPosition *_Position, const uint _bar_shift)
 {
  RestTradePrevProfit();
//--- create virtual rate
  MqlRates virtual_rate;
  CreateOpenRate(_Position, _bar_shift, virtual_rate);
//--- calc profit rate
  MqlRates profit_rate;
  CreateProfitRate(_Position, virtual_rate, profit_rate, true, false);
//--- add to indData
  AddProfits(profit_rate, _bar_shift);
//---
  SetTradePrevProfit(profit_rate);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::FillOnWayBar(const CPosition *_Position, const uint _bar_shift, const ENUM_BE_UPDATE_TYPE _type)
 {
  ENUM_DEAL_TYPE type  = _Position.PositionType();
  MqlRates profit_rate;
  if(!Series.IsM1Rate(_bar_shift) ||
     (_type == UPDATE_TYPE_FULL && type == DEAL_TYPE_SELL))
   {
    MqlRates virtual_rate;
    if(CreateOnWayRate(_Position, _bar_shift, virtual_rate))
      CreateProfitRate(_Position, virtual_rate, profit_rate, false, false);
    else
     {
      profit_rate.open = m_prev_profit_rate.close;
      profit_rate.high = m_prev_profit_rate.close;
      profit_rate.low = m_prev_profit_rate.close;
      profit_rate.close = m_prev_profit_rate.close;
     }
   }
  else
   {
    //--- create virtual rate
    string  symbol = _Position.Symbol();
    datetime from  = Series.m_time[_bar_shift];
    MqlRates symbol_rates[1];
    int count_rates = ::CopyRates(symbol, PERIOD_M1, from, 1, symbol_rates);
    //--- calc profit rate
    if(count_rates > 0)
     {
      double point = (double)::SymbolInfoDouble(symbol, SYMBOL_POINT);

      if(type == DEAL_TYPE_SELL && point > 0)
       {
        symbol_rates[0].open  = symbol_rates[0].open  + (double)symbol_rates[0].spread * point;
        symbol_rates[0].high  = symbol_rates[0].high  + (double)symbol_rates[0].spread * point;
        symbol_rates[0].low   = symbol_rates[0].low   + (double)symbol_rates[0].spread * point;
        symbol_rates[0].close = symbol_rates[0].close + (double)symbol_rates[0].spread * point;
       }

      CreateProfitRate(_Position, symbol_rates[0], profit_rate, false, false);
     }
    else
     {
      profit_rate.open = m_prev_profit_rate.close;
      profit_rate.high = m_prev_profit_rate.close;
      profit_rate.low = m_prev_profit_rate.close;
      profit_rate.close = m_prev_profit_rate.close;
     }
   }
//--- add to Series
  AddProfits(profit_rate, _bar_shift);
//---
  SetTradePrevProfit(profit_rate);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::FillCloseBar(const CPosition *_Position, const uint _bar_shift)
 {
////--- create virtual rate
//  MqlRates virtual_rate;
//  CreateCloseRate(_Position, _bar_shift, virtual_rate);
////--- calc profit rate
//  MqlRates profit_rate;
//  CreateProfitRate(_Position, virtual_rate, profit_rate, false, true);
////--- add to Series
//  AddProfits(profit_rate, _bar_shift);
//---
  RestTradePrevProfit();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::CreateOneBarRate(const CPosition *_Position,
                               const uint      _bar_shift,
                               MqlRates        &_res_rate)
 {
  _res_rate.open   = _Position.OpenPrice();
  _res_rate.close  = _Position.ClosePrice();
  _res_rate.high   = ::MathMax(_res_rate.open, _res_rate.close);
  _res_rate.low    = ::MathMin(_res_rate.open, _res_rate.close);
  _res_rate.spread = 0;
//---
  string  symbol = _Position.Symbol();
  ENUM_DEAL_TYPE type  = _Position.PositionType();

  long from_msc = long(Series.TimeMsc(_bar_shift)),
       to_msc   = from_msc + 60000;

  if(Series.Total() > _bar_shift + 2)
    to_msc = long(Series.TimeMsc(_bar_shift + 1) - 1);

  matrix ticks;
  uint flags = type == DEAL_TYPE_BUY ? COPY_TICKS_BID : COPY_TICKS_ASK;

  if(ticks.CopyTicksRange(symbol, flags, from_msc, to_msc))
   {
    if(ticks.Cols() < 1 || ticks.Rows() < 1)
      return;
    _res_rate.high   = ticks.Max();
    _res_rate.low    = ticks.Min();
    _res_rate.close  = ticks[0][ticks.Cols() - 1];
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::CreateOpenRate(const CPosition *_Position,
                             const uint      _bar_shift,
                             MqlRates        &_res_rate)
 {
  _res_rate.open   = _Position.OpenPrice();
  _res_rate.close  = _res_rate.open;
  _res_rate.high   = _res_rate.open;
  _res_rate.low    = _res_rate.open;
  _res_rate.spread = 0;
//---
  string  symbol = _Position.Symbol();
  ENUM_DEAL_TYPE type  = _Position.PositionType();
  long from_msc = long(_Position.OpenTimeMsc()),
       to_msc   = from_msc + 60000;

  if(Series.Total() > _bar_shift + 2)
    to_msc = long(Series.TimeMsc(_bar_shift + 1) - 1);

  matrix ticks;
  uint flags = type == DEAL_TYPE_BUY ? COPY_TICKS_BID : COPY_TICKS_ASK;

  if(ticks.CopyTicksRange(symbol, flags, from_msc, to_msc))
   {
    if(ticks.Cols() < 1 || ticks.Rows() < 1)
      return;
    _res_rate.open   = ticks[0][0];
    _res_rate.high   = ticks.Max();
    _res_rate.low    = ticks.Min();
    _res_rate.close  = ticks[0][ticks.Cols() - 1];
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::CreateOnWayRate(const CPosition *_Position,
                              const uint      _bar_shift,
                              MqlRates        &_res_rate)
 {
//---
  string  symbol = _Position.Symbol();
  ENUM_DEAL_TYPE type  = _Position.PositionType();
  long from_msc = long(Series.TimeMsc(_bar_shift)),
       to_msc   = from_msc + 60000;

  if(Series.Total() > _bar_shift + 2)
    to_msc = long(Series.TimeMsc(_bar_shift + 1) - 1);

  matrix ticks;
  uint flags = type == DEAL_TYPE_BUY ? COPY_TICKS_BID : COPY_TICKS_ASK;

  if(ticks.CopyTicksRange(symbol, flags, from_msc, to_msc))
   {
    if(ticks.Cols() < 1 || ticks.Rows() < 1)
      return false;
    _res_rate.open   = ticks[0][0];
    _res_rate.high   = ticks.Max();
    _res_rate.low    = ticks.Min();
    _res_rate.close  = ticks[0][ticks.Cols() - 1];
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::CreateCloseRate(const CPosition *_Position,
                              const uint      _bar_shift,
                              MqlRates        &_res_rate)
 {
  _res_rate.open   = _Position.ClosePrice();
  _res_rate.close  = _res_rate.open;
  _res_rate.high   = _res_rate.open;
  _res_rate.low    = _res_rate.open;
  _res_rate.spread = 0;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::CreateProfitRate(const CPosition *_Position,
                               const MqlRates  &_virtual_rate,
                               MqlRates        &_profit_rate,
                               const bool      _is_open    = false,
                               const bool      _is_close   = false)
 {
  _profit_rate.open  = _Position.GetProfit(_virtual_rate.open);
  _profit_rate.high  = _Position.GetProfit(_virtual_rate.high);
  _profit_rate.low   = _Position.GetProfit(_virtual_rate.low);
  _profit_rate.close = (!_is_close ? _Position.GetProfit(_virtual_rate.close) : _Position.Profit());
//--- succeed
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::AddProfits(MqlRates &_profit_rate,
                         const uint     _bar_shift)
 {
  uint total = Series.Total();
  if(_bar_shift >= total)
    return false;

  double value1 = _profit_rate.high,
         value2 = _profit_rate.low,
         value3 = _profit_rate.open,
         value4 = _profit_rate.close;

  Series.m_equity_open[_bar_shift]  += _profit_rate.open;
  Series.m_equity_high[_bar_shift]  += _profit_rate.high;
  Series.m_equity_low[_bar_shift]   += _profit_rate.low;
  Series.m_equity_close[_bar_shift] += _profit_rate.close;
//--- succeed
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CEquity::GetTickPriceByType(MqlTick &_tick, ENUM_DEAL_TYPE _type)
 {
  if(_type == DEAL_TYPE_SELL)
    return _tick.ask;
  return _tick.bid;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::RestTradePrevProfit(void)
 {
  MqlRates clean;
  m_prev_profit_rate = clean;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::SetTradePrevProfit(const MqlRates &_profit_rate)
 {
  m_prev_profit_rate = _profit_rate;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEquity::CheckEquityHighLow(void)
 {
  uint total = Series.Total();
  for(uint i = 0; i < total; i++)
   {
    double value1 = Series.m_equity_open[i],
           value2 = Series.m_equity_high[i],
           value3 = Series.m_equity_low[i],
           value4 = Series.m_equity_close[i];

    Series.m_equity_high[i] = ::MathMax(::MathMax(value1, value2), ::MathMax(value3, value4));
    Series.m_equity_low[i]  = ::MathMin(::MathMin(value1, value2), ::MathMin(value3, value4));
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CEquity::UpdateData(void)
 {
  bool   use__gambling = Task.UseGambeling(),
         is_balance_gambling = false,
         is_equity_gambling = false;
  double gambl_perc = Task.GambelingPercent(),
         percent = WRONG_VALUE;

  bool is_balance_daily_touch = false,
       is_balance_total_touch = false,
       is_equity_daily_touch = false,
       is_equity_total_touch = false;
  DrawDownList.Clear();
//--- Loop Series For Gamblings & Draw down
  int total = (int)Series.Total();
  for(int i = 0; i < total; i++)
   {
    if(use__gambling)
     {
      //--- balance gambling
      if(!is_balance_gambling)
       {
        percent = ((Series.m_balance[::MathMax(i - 1, 0)] - Series.m_balance[i]) / Series.m_balance[::MathMax(i - 1, 0)]) * 100;
        if(percent > gambl_perc)
         {
          is_balance_gambling = true;
          Series.m_balance_gambeling[i] = true;
         }
       }
      //--- equity gambling
      if(!is_equity_gambling)
       {
        percent = ((Series.m_balance[i] - Series.m_equity_low[i]) / Series.m_balance[i]) * 100;
        if(percent > gambl_perc)
         {
          is_equity_gambling = true;
          Series.m_equity_gambeling[i] = true;
         }
       }
      //--- rest gambling
      if(Series.m_balance[i] == Series.m_equity_low[i])
       {
        is_balance_gambling = false;
        is_equity_gambling = false;
       }
     }

    //--- balance daily touch list
    if(!is_balance_daily_touch && Series.m_balance[i] <= Series.m_day_limit[i])
     {
      CDrawDown *DD = new CDrawDown;
      DD.source = DD_SOURCE_BALANCE;
      DD.type = DD_TYPE_DAILY;
      DD.time = Series.m_time[i];
      DD.time_msc = Series.m_time_msc[i];
      DD.limit = Series.m_day_limit[i];
      DD.value = Series.m_balance[i];

      if(!DrawDownList.Add(DD))
       {
        FREE(DD);
       }
      else
        is_balance_daily_touch = true;
     }
    else
      if(is_balance_daily_touch && Series.m_balance[i] > Series.m_day_limit[i])
        is_balance_daily_touch = false;

    //--- balance total touch list
    if(!is_balance_total_touch && Series.m_balance[i] <= Series.m_total_limit[i])
     {
      CDrawDown *DD = new CDrawDown;
      DD.source = DD_SOURCE_BALANCE;
      DD.type = DD_TYPE_TOTAL;
      DD.time = Series.m_time[i];
      DD.time_msc = Series.m_time_msc[i];
      DD.limit = Series.m_total_limit[i];
      DD.value = Series.m_balance[i];

      if(!DrawDownList.Add(DD))
       {
        FREE(DD);
       }
      else
        is_balance_total_touch = true;
     }
    else
      if(is_balance_total_touch && Series.m_balance[i] > Series.m_total_limit[i])
        is_balance_total_touch = false;

    //--- equity daily touch list
    if(!is_equity_daily_touch && Series.m_equity_low[i] <= Series.m_day_limit[i])
     {
      CDrawDown *DD = new CDrawDown;
      DD.source = DD_SOURCE_EQUITY;
      DD.type = DD_TYPE_DAILY;
      DD.time = Series.m_time[i];
      DD.time_msc = Series.m_time_msc[i];
      DD.limit = Series.m_day_limit[i];
      DD.value = Series.m_equity_low[i];

      if(!DrawDownList.Add(DD))
       {
        FREE(DD);
       }
      else
        is_equity_daily_touch = true;
     }
    else
      if(is_equity_daily_touch && Series.m_equity_low[i] > Series.m_day_limit[i])
        is_equity_daily_touch = false;

    //--- equity total touch list
    if(!is_equity_total_touch && Series.m_equity_low[i] <= Series.m_total_limit[i])
     {
      CDrawDown *DD = new CDrawDown;
      DD.source = DD_SOURCE_EQUITY;
      DD.type = DD_TYPE_TOTAL;
      DD.time = Series.m_time[i];
      DD.time_msc = Series.m_time_msc[i];
      DD.limit = Series.m_total_limit[i];
      DD.value = Series.m_equity_low[i];

      if(!DrawDownList.Add(DD))
       {
        FREE(DD);
       }
      else
        is_equity_total_touch = true;
     }
    else
      if(is_equity_total_touch && Series.m_equity_low[i] > Series.m_total_limit[i])
        is_equity_total_touch = false;
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
