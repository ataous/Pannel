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
#include <_Ata\Info\DealInfo.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDeal : public CObject
 {
private:
  ulong              deal_ticket;
  long               order_ticket;
  datetime           time;
  datetime           time_rate;
  ulong              time_msc;
  ENUM_DEAL_TYPE     type;
  ENUM_DEAL_ENTRY    entry;
  long               magic;
  ENUM_DEAL_REASON   reason;
  long               position_id;
  double             volume;
  double             price;
  double             commission;
  double             swap;
  double             profit;
  double             fee;
  double             sl;
  double             tp;
  string             symbol;
  string             comment;
  string             external_id;

  double             balance;
  double             last_day_balance;
  double             daily_limit;
  double             total_limit;

public:
                     CDeal();
                     CDeal(CDealInfo *DealInfo) { Set(DealInfo);}
                    ~CDeal();
  //---
  void               Ticket(const long _value)              { deal_ticket = _value;}
  void               OrderTicket(const long _value)         { order_ticket = _value;}
  void               Time(const datetime _value)
   {
    time = _value;
    time_rate = int(time / 60) * 60;
   }
  void               RateTime(const datetime _value)        { time_rate = _value;}
  void               TimeMsc(const long _value)             { time_msc = _value;}
  void               DealType(const ENUM_DEAL_TYPE _value)  { type = _value;}
  void               Entry(const ENUM_DEAL_ENTRY _value)    { entry = _value;}
  void               Magic(const long _value)               { magic = _value;}
  void               Reason(const ENUM_DEAL_REASON _value)  { reason = _value;}
  void               PositionId(const long _value)          { position_id = _value;}
  void               Volume(const double _value)            { volume = _value;}
  void               Price(const double _value)             { price = _value;}
  void               Commission(const double _value)        { commission = _value;}
  void               Swap(const double _value)              { swap = _value;}
  void               Profit(const double _value)            { profit = _value;}
  void               Fee(const double _value)               { fee = _value;}
  void               Sl(const double _value)                { sl = _value;}
  void               Tp(const double _value)                { tp = _value;}
  void               Symbol(const string _value)            { symbol = _value;}
  void               Comment(const string _value)           { comment = _value;}
  void               ExtId(const string _value)             { external_id = _value;}
  void               Balance(const double _value)           { balance = _value;}
  void               LastDayBalance(const double _value)    { last_day_balance = _value;}
  void               DailyLimit(const double _value)        { daily_limit = _value;}
  void               TotalLimit(const double _value)        { total_limit = _value;}
  //---
  ulong              Ticket(void)         const { return deal_ticket;}
  long               OrderTicket(void)    const { return order_ticket;}
  datetime           Time(void)           const { return time;}
  datetime           RateTime(void)       const { return time_rate;}
  ulong              TimeMsc(void)        const { return time_msc;}
  ENUM_DEAL_TYPE     DealType(void)       const { return type;}
  ENUM_DEAL_ENTRY    Entry(void)          const { return entry;}
  long               Magic(void)          const { return magic;}
  ENUM_DEAL_REASON   Reason(void)         const { return reason;}
  long               PositionId(void)     const { return position_id;}
  double             Volume(void)         const { return volume;}
  double             Price(void)          const { return price;}
  double             Commission(void)     const { return commission;}
  double             Swap(void)           const { return swap;}
  double             Profit(void)         const { return profit;}
  double             Fee(void)            const { return fee;}
  double             Sl(void)             const { return sl;}
  double             Tp(void)             const { return tp;}
  string             Symbol(void)         const { return symbol;}
  string             Comment(void)        const { return comment;}
  string             ExtId(void)          const { return external_id;}
  double             Balance(void)        const { return balance;}
  double             LastDayBalance(void) const { return last_day_balance;}
  double             DailyLimit(void)     const { return daily_limit;}
  double             TotalLimit(void)     const { return total_limit;}

  //---
  bool               Set(CDealInfo &DealInfo);
  bool               Set(CDeal *Deal);
  bool               Set(const ulong _deal_ticket);
  bool               Set(const ulong            _deal_ticket,
                         const long             _order_ticket,
                         const datetime         _time,
                         const ulong            _time_msc,
                         const ENUM_DEAL_TYPE   _type,
                         const ENUM_DEAL_ENTRY  _entry,
                         const long             _magic,
                         const ENUM_DEAL_REASON _reason,
                         const long              _position_id,
                         const double            _volume,
                         const double            _price,
                         const double            _commission,
                         const double            _swap,
                         const double            _profit,
                         const double            _fee,
                         const double            _sl,
                         const double            _tp,
                         const string            _symbol,
                         const string            _comment,
                         const string            _external_id);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::CDeal() :
  deal_ticket(0),
  order_ticket(0),
  time(0),
  time_rate(0),
  time_msc(0),
  type(0),
  entry(0),
  magic(0),
  reason(0),
  position_id(0),
  volume(0.0),
  price(0.0),
  commission(0.0),
  swap(0.0),
  profit(0.0),
  fee(0.0),
  sl(0.0),
  tp(0.0),
  symbol(NULL),
  comment(NULL),
  external_id(NULL)
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDeal::~CDeal()
 {
 }
//+------------------------------------------------------------------+
bool CDeal::Set(CDealInfo &DealInfo)
 {
  deal_ticket  = DealInfo.Ticket();
  order_ticket = DealInfo.Order();
  time         = DealInfo.Time();
  time_rate    = (int)(time / 60) * 60;
  time_msc     = DealInfo.TimeMsc();
  type         = DealInfo.DealType();
  entry        = DealInfo.Entry();
  magic        = DealInfo.Magic();
  reason       = DealInfo.Reason();
  position_id  = DealInfo.PositionId();
  volume       = DealInfo.Volume();
  price        = DealInfo.Price();
  commission   = DealInfo.Commission();
  swap         = DealInfo.Swap();
  profit       = DealInfo.Profit();
  fee          = DealInfo.Fee();
  sl           = DealInfo.StopLoss();
  tp           = DealInfo.TackProfit();
  symbol       = DealInfo.Symbol();
  comment      = DealInfo.Comment();
  external_id  = DealInfo.ExternalId();
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDeal::Set(CDeal *Deal)
 {
  return Set(Deal.Ticket(),
             Deal.OrderTicket(),
             Deal.Time(),
             Deal.TimeMsc(),
             Deal.DealType(),
             Deal.Entry(),
             Deal.Magic(),
             Deal.Reason(),
             Deal.PositionId(),
             Deal.Volume(),
             Deal.Price(),
             Deal.Commission(),
             Deal.Swap(),
             Deal.Profit(),
             Deal.Fee(),
             Deal.Sl(),
             Deal.Tp(),
             Deal.Symbol(),
             Deal.Comment(),
             Deal.ExtId());
 }
//+------------------------------------------------------------------+
bool CDeal::Set(const ulong _deal_ticket)
 {
  CDealInfo DealInfo;
  DealInfo.Ticket(_deal_ticket);
  return Set(DealInfo);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDeal::Set(const ulong            _deal_ticket,
                const long             _order_ticket,
                const datetime         _time,
                const ulong            _time_msc,
                const ENUM_DEAL_TYPE   _type,
                const ENUM_DEAL_ENTRY  _entry,
                const long             _magic,
                const ENUM_DEAL_REASON _reason,
                const long             _position_id,
                const double           _volume,
                const double           _price,
                const double           _commission,
                const double           _swap,
                const double           _profit,
                const double           _fee,
                const double           _sl,
                const double           _tp,
                const string           _symbol,
                const string           _comment,
                const string           _external_id)
 {
  deal_ticket  = _deal_ticket;
  order_ticket = _order_ticket;
  time         = _time;
  time_rate    = (int)(time / 60) * 60;
  time_msc     = _time_msc;
  type         = _type;
  entry        = _entry;
  magic        = _magic;
  reason       = _reason;
  position_id  = _position_id;
  volume       = _volume;
  price        = _price;
  commission   = _commission;
  swap         = _swap;
  profit       = _profit;
  fee          = _fee;
  sl           = _sl;
  tp           = _tp;
  symbol       = _symbol;
  comment      = _comment;
  external_id  = _external_id;
  return true;
 }
//+------------------------------------------------------------------+
