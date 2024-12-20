//+------------------------------------------------------------------+
//|                                                         Deal.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#include <Object.mqh>
#include <_Ata\Calendar\CalendarInfo.mqh>
#include <_Ata\General\Func.mqh>
#include "..\Defines.mqh"
#include "Deal.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPosition : public CObject
 {
private:
  CDeal              m_deal_in,
                     m_deal_out;
  bool               m_is_open_pos;
  double             m_point_value,
                     m_point;
  long               m_digits;

  bool               m_is_tick_scalp,
                     m_is_weekend,
                     m_is_news_trading;
  string             m_news;

  ulong              DurationMsc(void) { return ulong(::MathMax(m_deal_out.TimeMsc() - m_deal_in.TimeMsc(), 0));}
  bool               IsNewsRuleOne(const MqlCalendarValue & _event, uint & _index);
  bool               IsNewsRuleTwo(const MqlCalendarValue & _event, uint & _index);
  bool               SetExtraData(const bool _use_weekend,
                                  const bool _use_news,
                                  const bool _use_tick_scalp,
                                  const uint _tick_scalp_duration_msc);
  void               CheckTickScalp(const uint _tick_scalp_duration_msc);
  void               CheckWeekend(void);
  void               CheckNewsTrading(void);


public:
                     CPosition();
                    ~CPosition();
  void               SetDealIn(CDeal &Deal,
                               const bool _set_extra_data,
                               const bool _use_weekend,
                               const bool _use_news,
                               const bool _use_tick_scalp,
                               const uint _tick_scalp_duration_msc)
   {
    m_deal_in = &Deal;
    if(_set_extra_data)
      SetExtraData(_use_weekend, _use_news, _use_tick_scalp, _tick_scalp_duration_msc);
   }
  void               SetDealOut(CDeal &Deal) { m_deal_out = &Deal;}
  void               SetDeals(CDeal &DealIn,
                              CDeal &DealOut,
                              const bool _set_extra_data,
                              const bool _use_weekend,
                              const bool _use_news,
                              const bool _use_tick_scalp,
                              const uint _tick_scalp_duration_msc)
   {
    SetDealOut(DealOut);
    SetDealIn(DealIn, _set_extra_data, _use_weekend, _use_news, _use_tick_scalp, _tick_scalp_duration_msc);
   }
  //---
  void               PointValue(const double _value)           { m_point_value = _value;}
  double             PointValue(void)                    const { return m_point_value;}
  void               Point(const double _value)                { m_point = _value;}
  double             Point(void)                         const { return m_point;}
  void               Digits(const int _value)                  { m_digits = _value;}
  int                Digits(void)                        const { return (int)m_digits;}
  //---
  void               IsOpenPosition(const bool _value)         { m_is_open_pos = _value;}
  bool               IsOpenPosition(void)                const { return m_is_open_pos;}
  //---
  long               PositionId(void)                    const { return m_deal_out.PositionId();}
  string             Symbol(void)                        const { return m_deal_out.Symbol();}
  ENUM_DEAL_TYPE     PositionType(void)                  const { return m_deal_out.DealType() == DEAL_TYPE_BUY ? DEAL_TYPE_SELL : DEAL_TYPE_BUY;}
  int                MysqlEnumPositionType(void)
   {
   // 'Buy', 'Sell', 'Unknown'
    switch(PositionType())
     {
      case  DEAL_TYPE_BUY:   // Buy
        return 1;
      case  DEAL_TYPE_SELL:   //Sell
        return 2;
      default:
        break;
     }
    return 3;// 'Unknown'
   }

  double             Volume(void)                        const { return m_deal_out.Volume();}
  //---
  ulong              OpenTicket(void)                    const { return m_deal_in.Ticket();}
  datetime           OpenTime(void)                      const { return m_deal_in.Time();}
  datetime           OpenRateTime(void)                  const { return m_deal_in.RateTime();}
  ulong              OpenTimeMsc(void)                   const { return m_deal_in.TimeMsc();}
  double             OpenPrice(void)                     const { return m_deal_in.Price();}
  double             OpenSl(void)                        const { return m_deal_in.Sl();}
  double             OpenTp(void)                        const { return m_deal_in.Tp();}
  double             OpenCommission(void)                const { return m_deal_in.Commission();}
  double             OpenSwap(void)                      const { return m_deal_in.Swap();}
  double             OpenFee(void)                       const { return m_deal_in.Fee();}
  //---
  ulong              CloseTicket(void)                   const { return m_deal_out.Ticket();}
  datetime           CloseTime(void)                     const { return m_deal_out.Time();}
  datetime           CloseRateTime(void)                 const { return m_deal_out.RateTime();}
  ulong              CloseTimeMsc(void)                  const { return m_deal_out.TimeMsc();}
  double             ClosePrice(void)                    const { return m_deal_out.Price();}
  double             CloseSl(void)                       const { return m_deal_out.Sl();}
  double             CloseTp(void)                       const { return m_deal_out.Tp();}
  double             CloseProfit(void)                   const { return m_deal_out.Profit();}
  double             CloseCommission(void)               const { return m_deal_out.Commission();}
  double             CloseSwap(void)                     const { return m_deal_out.Swap();}
  double             CloseFee(void)                      const { return m_deal_out.Fee();}
  //---
  double             OpenCost(void)                      const { return(m_deal_in.Commission() + m_deal_in.Swap());}
  double             CloseCost(void)                     const { return(m_deal_out.Commission() + m_deal_out.Swap());}
  double             TotalCost(void)                     const { return(OpenCost() + CloseCost());}

  double             Profit(void)                        const { return(m_deal_out.Profit());}
  double             NetProfit(void)                     const { return(m_deal_out.Profit() + TotalCost());}
  uint               TradeDuratianMsc(void)              const { return int(m_deal_out.TimeMsc() - m_deal_in.TimeMsc());}
  double             GetProfit(const double _last_price) const;
  bool               IsTickScalp(void)                   const { return m_is_tick_scalp;}
  bool               IsWeekend(void)                     const { return m_is_weekend;}
  bool               IsNewsTrading(void)                 const { return m_is_news_trading;}
  string             News(void)                          const { return m_news;}

 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::CPosition() :
  m_is_open_pos(false),
  m_point_value(0),
  m_point(0),
  m_digits(0),
  m_is_tick_scalp(false),
  m_is_weekend(false),
  m_is_news_trading(false),
  m_news("")
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPosition::~CPosition()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CPosition::GetProfit(const double _last_price) const
 {
  double last_price = ::NormalizeDouble(_last_price, this.Digits()),
         open_price = ::NormalizeDouble(this.OpenPrice(), this.Digits()),
         dif        = last_price - open_price;

  dif = (this.PositionType() == DEAL_TYPE_BUY) ? dif : -dif;
//---
  double move_points = dif / this.Point();
  return ::NormalizeDouble(move_points * this.PointValue(), 2);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPosition::CheckTickScalp(const uint _tick_scalp_duration_msc)
 {
  if(!IsOpenPosition() && DurationMsc() < _tick_scalp_duration_msc)
    m_is_tick_scalp = true;
  else
    m_is_tick_scalp = false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPosition::CheckWeekend(void)
 {
  m_is_weekend = true;
//---
  MqlDateTime mdtstructopen, mdtstructclose;
  ::TimeToStruct(this.OpenTime(), mdtstructopen);
  ::TimeToStruct(this.CloseTime(), mdtstructclose);
//---
  if(mdtstructopen.day_of_week == SUNDAY || mdtstructopen.day_of_week == FRIDAY || mdtstructopen.day_of_week == SATURDAY)
   {
    if(mdtstructopen.day_of_week == SATURDAY) // شنبه
      return;

    string broker = ::AccountInfoString(ACCOUNT_COMPANY);
    ::StringToLower(broker);

    if(::StringFind(broker, "unfxb") >= 0)
     {
      if(mdtstructopen.day_of_week == FRIDAY && mdtstructopen.hour > 21)
        return;

      if(mdtstructopen.day_of_week == SUNDAY && mdtstructopen.hour < 21)
        return;
     }
    else
     {
      if(mdtstructopen.day_of_week == SUNDAY)
        return;
     }
   }
//---
  if(!IsOpenPosition() &&
     (mdtstructclose.day_of_week == SUNDAY || mdtstructclose.day_of_week == FRIDAY || mdtstructclose.day_of_week == SATURDAY))
   {
    if(mdtstructclose.day_of_week == SATURDAY) // شنبه
      return;

    string broker = ::AccountInfoString(ACCOUNT_COMPANY);
    ::StringToLower(broker);

    if(::StringFind(broker, "unfxb") >= 0)
     {
      if(mdtstructclose.day_of_week == FRIDAY && mdtstructclose.hour > 21)
        return;
      if(mdtstructclose.day_of_week == SUNDAY && mdtstructclose.hour < 21)
        return;
     }
    else
     {
      if(mdtstructclose.day_of_week == SUNDAY)
        return;
     }
   }
//---
  m_is_weekend = false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPosition::IsNewsRuleOne(const MqlCalendarValue & _event, uint & _index)
 {
  string symbol = this.Symbol(),
         base   = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE),
         quote  = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
  ::StringToLower(symbol);
  ::StringToLower(base);
  ::StringToLower(quote);

  for(uint i = 0; i < rule_one_event_ids.Size(); i++)
   {
    if(rule_one_event_ids[i] == _event.event_id)
     {
      if(OpenTime()  <= _event.time + 3 * PeriodSeconds(PERIOD_M1) &&
         CloseTime() >= _event.time - 2 * PeriodSeconds(PERIOD_M1))
       {
        string event_currency = rule_one_currency[i];
        ::StringToLower(event_currency);
        if(::StringFind(symbol, event_currency) >= 0 ||
           base == event_currency ||
           quote == event_currency)
         {
          _index = i;
          return true;
         }
       }
     }
   }
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPosition::IsNewsRuleTwo(const MqlCalendarValue & _event, uint & _index)
 {
  string symbol = this.Symbol(),
         base   = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_BASE),
         quote  = ::SymbolInfoString(symbol, SYMBOL_CURRENCY_PROFIT);
  ::StringToLower(symbol);
  ::StringToLower(base);
  ::StringToLower(quote);

  for(uint i = 0; i < rule_two_event_ids.Size(); i++)
   {
    if(rule_two_event_ids[i] == _event.event_id)
     {
      if(OpenTime() >= _event.time - 5 * ::PeriodSeconds(PERIOD_M1) &&
         CloseTime() <= _event.time + 2 * ::PeriodSeconds(PERIOD_M1))
       {
        string event_currency = rule_two_currency[i];
        ::StringToLower(event_currency);
        if(::StringFind(symbol, event_currency) >= 0 ||
           base == event_currency ||
           quote == event_currency)
         {
          _index = i;
          return true;
         }
       }
     }
   }
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CPosition::CheckNewsTrading(void)
 {
  m_is_news_trading = false;
  m_news = "";
  if(IsOpenPosition())
    return;
  if(CloseProfit() <= 0)
    return;
//----
  m_is_news_trading = true;

  CCalendarInfo      Calendar;
  MqlCalendarValue   event_value[];

  if(Calendar.ValueHistorySelectAll(event_value, OpenRateTime() - 5 * PeriodSeconds(PERIOD_M1), CloseTime() + 3 * PeriodSeconds(PERIOD_M1)))
   {
    for(uint i = 0; i < event_value.Size(); i++)
     {
      uint index = WRONG_VALUE;
      if(IsNewsRuleOne(event_value[i], index))
       {
        m_news = "Rule 1: " + rule_one_currency[index] + " " + rule_one_events[index];
        return;
       }

      if(IsNewsRuleTwo(event_value[i], index))
       {
        m_news = "Rule 2:" + this.Symbol() + " " + rule_two_events[index];
        return;
       }
     }
   }
//---
  m_is_news_trading = false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CPosition::SetExtraData(const bool _use_weekend,
                             const bool _use_news,
                             const bool _use_tick_scalp,
                             const uint _tick_scalp_duration_msc)
 {
  if(_use_weekend)
    CheckWeekend();
  if(_use_news)
    CheckNewsTrading();
  if(_use_tick_scalp)
    CheckTickScalp(_tick_scalp_duration_msc);
//---
  if(OpenPrice() <= 0 || ClosePrice() <= 0 || Volume() <= 0)
    return false;

  if(!CFunc::IsSymbol(this.Symbol()))
    return false;

  if(!::SymbolInfoDouble(this.Symbol(), SYMBOL_POINT, m_point))
    return false;

  if(!::SymbolInfoInteger(this.Symbol(), SYMBOL_DIGITS, m_digits))
    return false;

  if(m_point <= 0 || m_digits < 0)
    return false;

  ulong  dif_point = (ulong)::round(::MathAbs(this.ClosePrice() - this.OpenPrice()) / m_point);
  double value;
  if(dif_point > 0 && CloseProfit() / Volume() != 0)
   {
    value = MathAbs(CloseProfit() / dif_point);
    if(value > 0)
     {
      PointValue(value);
      return true;
     }
   }
//---
  ENUM_ORDER_TYPE type = (PositionType() == DEAL_TYPE_BUY) ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
  if(type == ORDER_TYPE_BUY)
   {
    double ask = ::SymbolInfoDouble(this.Symbol(), SYMBOL_ASK);
    if(ask - 5 * m_point > OpenPrice())
      type = ORDER_TYPE_BUY_LIMIT;
    if(ask + 5 * m_point < OpenPrice())
      type = ORDER_TYPE_BUY_STOP;
   }
  else
   {
    double bid = ::SymbolInfoDouble(this.Symbol(), SYMBOL_BID);
    if(bid - 5 * m_point > OpenPrice())
      type = ORDER_TYPE_SELL_STOP;
    if(bid + 5 * m_point < OpenPrice())
      type = ORDER_TYPE_SELL_LIMIT;
   }

  double price_close = type == ORDER_TYPE_BUY ? OpenPrice() + m_point : OpenPrice() - m_point;
  value = 0;
  if(OrderCalcProfit(type, this.Symbol(), Volume(), OpenPrice(), ClosePrice(), value))
    if(value > 0)
     {
      PointValue(value);
      return true;
     }
//----
  double tick_size  = SymbolInfoDouble(this.Symbol(), SYMBOL_TRADE_TICK_SIZE);
  double tick_value = SymbolInfoDouble(this.Symbol(), SYMBOL_TRADE_TICK_VALUE);
  value = 0;
  if(tick_size > 0 && tick_value > 0)
   {
    value = tick_value * m_point / tick_size;
    if(value * Volume() > 0)
     {
      PointValue(value * Volume());
      return true;
     }

   }
  PointValue(1 * Volume());
//---
  return true;
 }
//+------------------------------------------------------------------+
