//+------------------------------------------------------------------+
//|                                                      History.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayString.mqh>
#include <_Ata\Info\PositionInfo.mqh>
#include <_Ata\General\Func.mqh>
#include "..\Task\Task.mqh"
#include "Deal.mqh"
#include "Position.mqh"
#include "SymbolData.mqh"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CHistory
 {
private:
  CTask              *Task;
  //CArrayObj          SwapDealList;
  CArrayString       SymbolArr;
  CArrayString       TradeDays;
  datetime           m_frist_deal_time,
                     m_first_trade_time;
  long               m_start_time_msc;
  datetime           m_start_time,
                     m_end_time,
                     m_end_time_rate;
  ulong              m_end_time_msc;
  double             //m_start_balnce,
  m_init_balance,
  m_end_equity,
  m_end_balance;
  uint               m_total_open_position,
                     m_total_open_order;

  void               Reset(void)
   {
    DealsList.Clear();
    PositionList.Clear();
    SymbolList.Clear();
    SymbolArr.Clear();
    TradeDays.Clear();

    m_frist_deal_time = 0;
    m_first_trade_time = 0;

    m_start_time_msc = 0;
    m_start_time = 0;
    m_end_time = 0;
    m_end_time_rate = 0;
    m_end_time_msc = 0;

    //m_start_balnce = 0;
    m_init_balance = 0;
    m_end_equity = 0;
    m_end_balance = 0;

    m_total_open_position = 0;
    m_total_open_order = 0;
   }

  bool               AddToDealsList(CDeal *Deal);
  bool               AddToPositionList(CDeal *Deal);
  bool               DealsListCompletion(void);
  bool               PositionListCompletion(void);
  bool               AddLiveToPositionList(CPositionInfo &PositionInfo);
  void               AddToSymbolList(const string _symbol, const datetime _time);
  void               AddToDaysList(const datetime _time);
  void               CheckFirstTimes(CDeal *Deal);

  bool               UpdateData(void);
public:
  CArrayObj          DealsList,
                     PositionList,
                     SymbolList;

                     CHistory();
                    ~CHistory();

  bool               Update(CTask *_Task);
  long               StartTimeMsc(void)            const { return m_start_time_msc;}
  datetime           EndTime(void)                 const { return m_end_time;}
  ulong              EndTimeMsc(void)              const { return m_end_time_msc;}
  ulong              EndTimeRateMsc(void)          const { return m_end_time_rate * 1000;}
  double             EndEquity(void)               const { return m_end_equity;}
  double             EndBalance(void)              const { return m_end_balance;}
  datetime           FirstDealTime(void)           const { return m_frist_deal_time;}
  datetime           FirstTradeTime(void)          const { return m_first_trade_time;}
  double             InitialBlance(void)           const { return m_init_balance;}
  //double             StartBlance(void)             const { return m_start_balnce;}

  int                TotalOpenPositons(void)       const { return (int)m_total_open_position;}
  int                TotalOpenOrders(void)         const { return (int)m_total_open_order;}

  bool               IsPositionOpenAtTimeMsc(const ulong _time_msc)
   {
    int total = PositionList.Total();
    for(int i = 0; i < total; i++)
     {
      CPosition *Position = PositionList.At(i);
      ulong open_time_msc = Position.OpenTimeMsc();
      ulong close_time_msc = Position.CloseTimeMsc();

      if(_time_msc >= open_time_msc && _time_msc <= close_time_msc)
        return true;
     }
    return false;
   }
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistory::CHistory()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CHistory::~CHistory()
 {
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::Update(CTask *_Task)
 {
  Reset();
  Task = _Task;
  if(!IS_POINTER_DYNAMIC(Task))
    return false;

  m_init_balance = Task.InitBalance();
  m_start_time_msc = Task.EquityCheckPointTimeMsc();
  m_start_time = datetime(m_start_time_msc / 1000);
  m_end_time = ::TimeTradeServer();
  m_end_equity = ::AccountInfoDouble(ACCOUNT_EQUITY);
  m_end_balance = ::AccountInfoDouble(ACCOUNT_BALANCE);
  m_end_time_rate = (int)(m_end_time / 60) * 60;
  m_end_time_msc = (ulong)(m_end_time * 1000);
//--- History
  if(!::HistorySelect(m_start_time, ::TimeTradeServer() + ::PeriodSeconds(PERIOD_MN1)))
    return false;

  uint total = ::HistoryDealsTotal();

  for(uint i = 0; i < total; i++)
   {
    CDealInfo DealInfo;
    if(!DealInfo.SelectByIndex(i))
      return false;

    CDeal *Deal = new CDeal;
    Deal.Set(DealInfo);
    //---
    if(!AddToDealsList(Deal))
     {
      FREE(Deal);
      return false;
     }

    if(!AddToPositionList(Deal))
      return false;
    CheckFirstTimes(Deal);
   }
  DealsListCompletion();
  PositionListCompletion();
//---- Live
  m_total_open_order = OrdersTotal();
  m_total_open_position  = PositionsTotal();
  for(uint i = 0; i < m_total_open_position; i++)
   {
    CPositionInfo PositionInfo;
    if(!PositionInfo.SelectByIndex(i))
      continue;
    AddLiveToPositionList(PositionInfo);
   }
//---
  //if(!UpdateData())
  //  return false;
//--- succeed
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::AddToDealsList(CDeal *Deal)
 {
  return DealsList.Add(Deal);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::AddToPositionList(CDeal *Deal)
 {
  if(!CFunc::IsSymbol(Deal.Symbol()))
    return true;

  ENUM_DEAL_TYPE type = Deal.DealType();

  if(Deal.Entry() != DEAL_ENTRY_OUT)
   {
    if(Deal.Entry() == DEAL_ENTRY_IN || Deal.Entry() == DEAL_ENTRY_INOUT)
      if(type == DEAL_TYPE_BUY && type == DEAL_TYPE_SELL)
        AddToDaysList(Deal.Time());

    return true;
   }

  if(type != DEAL_TYPE_BUY && type != DEAL_TYPE_SELL)
    return true;

  if(Deal.Volume() <= 0)
    return true;

  if(Deal.Price() <= 0)
    return true;

  CPosition *Position = new CPosition;
  Position.SetDealOut(Deal);

  return PositionList.Add(Position);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::DealsListCompletion(void)
 {
//----
  uint total = DealsList.Total();
  if(total > 0)
   {
    if(DEF_IS_SWAOP_IN_MID_NIGHT)
     {
      CArrayObj SwapDealList;
      for(uint i = 0; i < total; i++)
       {
        CDeal *Deal = DealsList.At(i);
        //--- Add SwapDeals
        if(Deal.Swap() != 0 && Deal.Comment() != "Swap Deal")
         {
          if(::HistorySelectByPosition(Deal.PositionId()))
           {
            uint deal_total = ::HistoryDealsTotal();
            for(uint j = 0; j < deal_total; j++)
             {
              CDealInfo DealInfo;
              if(!DealInfo.SelectByIndex(j))
                return false;

              if(DealInfo.Entry() != DEAL_ENTRY_IN)
                continue;

              if(DealInfo.DealType() != DEAL_TYPE_BUY && DealInfo.DealType() != DEAL_TYPE_SELL)
                continue;

              if(DealInfo.Volume() <= 0)
                continue;

              if(DealInfo.Price() <= 0)
                continue;

              if(DealInfo.Symbol() != Deal.Symbol())
                continue;

              if(DealInfo.DealType() == Deal.DealType())
                continue;

              datetime open_day = int(DealInfo.Time() / (DEF_DAY_SEC)) * DEF_DAY_SEC;
              datetime close_day = int(Deal.Time() / (DEF_DAY_SEC)) * DEF_DAY_SEC;

              uint step = (uint)::MathCeil((close_day - open_day) / DEF_DAY_SEC);
              if(step <= 0)
               {
                Deal.Comment("Swap Deal");
                break;
               }

              double swap_per_day = Deal.Swap() / step;

              for(uint i = 1; i <= step; i++)
               {
                datetime time = open_day + i * DEF_DAY_SEC;
                ulong ticket = (ulong)::StringToInteger((string)Deal.Ticket() + (string)i);

                if(i == step)
                  swap_per_day = Deal.Swap() - (step - 1) * swap_per_day;

                CDeal * SwapDeal = new CDeal;
                SwapDeal.Set(Deal);
                SwapDeal.Ticket(ticket);
                SwapDeal.Time(time);
                SwapDeal.TimeMsc(time * 1000);
                SwapDeal.Commission(0);
                SwapDeal.Swap(swap_per_day);
                SwapDeal.Profit(0);
                SwapDeal.Fee(0);
                SwapDeal.Comment("Swap Deal");
                SwapDeal.ExtId((string)Deal.Ticket());

                if(!SwapDealList.Add(SwapDeal))
                 {
                  FREE(SwapDeal);
                  return false;
                 }
               }
              break;
             }
           }
         }
       }
      uint swap_total = SwapDealList.Total();
      for(uint i = 0; i < swap_total; i++)
       {
        CDeal *SwapDeal = SwapDealList.At(i);
        total = DealsList.Total();
        for(uint pos = 0; pos < total; pos++)
         {
          CDeal *Deal = DealsList.At(pos);
          if(Deal.TimeMsc() > SwapDeal.TimeMsc())
           {
            DealsList.Insert(SwapDeal, pos);
            break;
           }
         }
       }
      if(swap_total > 0)
        SwapDealList.FreeMode(false);
     }

    //--- calc each deal balance prams
    double balance = Task.EquityCheckPointBalance();
    double last_day_balance = m_init_balance;
    MqlDateTime prev_deal_time_str;
    ::TimeToStruct(0, prev_deal_time_str);
    //---
    for(uint i = 0; i < total; i++)
     {
      CDeal *Deal = DealsList.At(i);

      MqlDateTime deal_time_str;
      ::TimeToStruct(Deal.Time(), deal_time_str);

      if(Deal.Time() >= m_first_trade_time && m_first_trade_time != 0)
       {
        if(prev_deal_time_str.day_of_year != deal_time_str.day_of_year)
          last_day_balance = balance;
       }

      prev_deal_time_str = deal_time_str;
      double swap = !DEF_IS_SWAOP_IN_MID_NIGHT ? Deal.Swap() :
                    (Deal.Comment() == "Swap Deal" ? Deal.Swap() : 0);
      balance += Deal.Profit() + Deal.Commission() + swap;

      Deal.Balance(balance);
      Deal.LastDayBalance(last_day_balance);
      Deal.DailyLimit(last_day_balance * Task.DailyLimitRatio());
      Deal.TotalLimit(m_init_balance * Task.TotalLimitRatio());
     }
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::PositionListCompletion(void)
 {
  uint total = PositionList.Total();
  for(uint i = 0; i < total; i++)
   {
    CPosition *Position = PositionList.At(i);
    if(!::HistorySelectByPosition(Position.PositionId()))
      return false;

    uint deal_total = ::HistoryDealsTotal();
    for(uint j = 0; j < deal_total; j++)
     {
      CDealInfo DealInfo;
      if(!DealInfo.SelectByIndex(j))
        return false;

      if(DealInfo.Entry() != DEAL_ENTRY_IN)
        continue;

      if(DealInfo.DealType() != DEAL_TYPE_BUY && DealInfo.DealType() != DEAL_TYPE_SELL)
        continue;

      if(DealInfo.Volume() <= 0)
        continue;

      if(DealInfo.Price() <= 0)
        continue;

      if(DealInfo.Symbol() != Position.Symbol())
        continue;

      if(DealInfo.DealType() != Position.PositionType())
        continue;

      CDeal Deal;
      Deal.Set(DealInfo);
      Position.SetDealIn(Deal, true, Task.UseWeekend(), Task.UseNews(), Task.UseTickScalp(), Task.TickScalpTermMsc());

      AddToSymbolList(Position.Symbol(), Position.OpenRateTime());
      break;
     }
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::AddLiveToPositionList(CPositionInfo & PositionInfo)
 {
  long pos_id = PositionInfo.Identifier();

  if(!::HistorySelectByPosition(pos_id))
    return false;

  CDeal *DealIn  = new CDeal;
  bool is_deal_in_set = false;
  uint deal_total = ::HistoryDealsTotal();
  for(uint j = 0; j < deal_total; j++)
   {
    CDealInfo DealInfo;
    if(!DealInfo.SelectByIndex(j))
     {
      FREE(DealIn);
      return false;
     }

    if(DealInfo.Entry() != DEAL_ENTRY_IN)
      continue;

    if(DealInfo.DealType() != DEAL_TYPE_BUY && DealInfo.DealType() != DEAL_TYPE_SELL)
      continue;

    if(DealInfo.Volume() <= 0)
      continue;

    if(DealInfo.Price() <= 0)
      continue;

    if(DealInfo.Symbol() != PositionInfo.Symbol())
      continue;

    ENUM_DEAL_TYPE pos_deal_type = PositionInfo.PositionType() == POSITION_TYPE_BUY ? DEAL_TYPE_BUY : DEAL_TYPE_SELL;

    if(DealInfo.DealType() != pos_deal_type)
      continue;

    is_deal_in_set = DealIn.Set(DealInfo);
    break;
   }

  if(!is_deal_in_set)
   {
    FREE(DealIn);
    return false;
   }

  CDeal *Dealout = new CDeal;
  bool is_deal_out_set = Dealout.Set(0,
                                     0,
                                     m_end_time,
                                     m_end_time_msc,
                                     DealIn.DealType() == DEAL_TYPE_BUY ? DEAL_TYPE_SELL : DEAL_TYPE_BUY,
                                     DEAL_ENTRY_OUT,
                                     0,
                                     DEAL_REASON_CLIENT,
                                     DealIn.PositionId(),
                                     PositionInfo.Volume(),
                                     DealIn.DealType() == DEAL_TYPE_BUY ? ::SymbolInfoDouble(PositionInfo.Symbol(), SYMBOL_BID) : ::SymbolInfoDouble(PositionInfo.Symbol(), SYMBOL_ASK),
                                     0,
                                     0,
                                     PositionInfo.Profit(),
                                     0.0,
                                     PositionInfo.StopLoss(),
                                     PositionInfo.TakeProfit(),
                                     PositionInfo.Symbol(),
                                     "",
                                     DealIn.ExtId());

  if(!is_deal_out_set)
   {
    FREE(DealIn);
    FREE(Dealout);
    return false;
   }

  CPosition *Position = new CPosition;
  Position.IsOpenPosition(true);
  Position.SetDeals(DealIn, Dealout, true, Task.UseWeekend(), Task.UseNews(), Task.UseTickScalp(), Task.TickScalpTermMsc());

  AddToSymbolList(Position.Symbol(), Position.OpenRateTime());

  if(PositionList.Add(Position))
    return true;
  FREE(Position);
//---
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHistory::AddToSymbolList(const string _symbol, const datetime _time)
 {
  SymbolArr.Sort();
  if(SymbolArr.Search(_symbol) < 0)
   {
    if(SymbolArr.Add(_symbol))
     {
      CSymbolData *data = new CSymbolData;
      data.Name(_symbol);
      data.Time(datetime(int((_time / 60) * 60)));
      if(!SymbolList.Add(data))
        delete data;
     }
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHistory::AddToDaysList(const datetime _time)
 {
  TradeDays.Sort();
  datetime day = (_time / DEF_DAY_SEC) * DEF_DAY_SEC;
  string date = ::TimeToString(day, TIME_DATE | TIME_SECONDS);
  if(TradeDays.Search(date) < 0)
    TradeDays.Add(date);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CHistory::CheckFirstTimes(CDeal * Deal)
 {
  if(m_frist_deal_time != 0 && m_first_trade_time != 0)
    return;
//---
  if(m_frist_deal_time == 0 && Deal.Time() > 0)
    m_frist_deal_time = Deal.Time();
//---
  if(m_first_trade_time == 0 && Deal.Time() > 0)
   {
    ENUM_DEAL_TYPE type = Deal.DealType();
    if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
      m_first_trade_time = Deal.Time();
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CHistory::UpdateData(void)
 {
//---
  return true;
 }
//+------------------------------------------------------------------+
