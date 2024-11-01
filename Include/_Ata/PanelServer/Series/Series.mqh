//+------------------------------------------------------------------+
//|                                                       Series.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"

#include <Object.mqh>
#include "..\Task\Task.mqh"
#include "..\History\History.mqh"
#include "SqliteSeries.mqh"
#define DEF_SERILAIZE_METHOD 3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSeries : public CObject
 {
public:
  CTask              *Task;
  CHistory           *History;
  datetime           m_time[];
  ulong              m_time_msc[];
  double             m_balance[],
                     m_day_limit[],
                     m_total_limit[],
                     m_equity_open[],
                     m_equity_high[],
                     m_equity_low[],
                     m_equity_close[];
  bool               m_balance_gambeling[],
                     m_equity_gambeling[];

  void               Reset(void);

                     CSeries();
                    ~CSeries();
  bool               Create(CHistory *_History, CTask *_Task);
  bool               CreateMethodOne(void);
  bool               CreateMethodTwo(void);
  bool               CreateMethodThree(void);

  uint               Total(void) const { return(m_time_msc.Size());}

  bool               RemoveLastRate(const double _end_balance, const double _end_equity)
   {
    uint new_size = Total() - 1;

    if(new_size >= 0)
     {
      if(::ArrayResize(m_time, new_size) != new_size)
        return false;
      if(::ArrayResize(m_time_msc, new_size) != new_size)
        return false;
      if(::ArrayResize(m_balance, new_size) != new_size)
        return false;
      if(::ArrayResize(m_day_limit, new_size) != new_size)
        return false;
      if(::ArrayResize(m_total_limit, new_size) != new_size)
        return false;
      if(::ArrayResize(m_equity_open, new_size) != new_size)
        return false;
      if(::ArrayResize(m_equity_high, new_size) != new_size)
        return false;
      if(::ArrayResize(m_equity_low, new_size) != new_size)
        return false;
      if(::ArrayResize(m_equity_close, new_size) != new_size)
        return false;
      if(::ArrayResize(m_balance_gambeling, new_size) != new_size)
        return false;
      if(::ArrayResize(m_equity_gambeling, new_size) != new_size)
        return false;
     }
    //--
    return true;
   }

  int                GetIndex(const ulong _time_msc)
   {
    if(m_time_msc.Size() > 0)
     {
      int index = ::ArrayBsearch(m_time_msc, _time_msc);
      if(m_time_msc[index] == _time_msc)
        return index;
     }
    return(WRONG_VALUE);
   }

  ulong              TimeMsc(const int _index) const
   {
    if(_index < 0 || (int)m_time_msc.Size() <= _index)
      return 0;
    else
      return m_time_msc[_index];
   }

  int                BarDurationMsc(const int _bar_shift)
   {
    if(m_time_msc.Size() == 0)
      return WRONG_VALUE;

    if(_bar_shift < 0)
      return WRONG_VALUE;

    if(_bar_shift >= (int)m_time_msc.Size())
      return WRONG_VALUE;

    if(_bar_shift == m_time_msc.Size() - 1)
      return 60000;

    return int(m_time_msc[_bar_shift + 1] - m_time_msc[_bar_shift]);
   }

  bool               IsM1Rate(const uint _bar_shift)
   {
    if(BarDurationMsc(_bar_shift) != 60000)
      return false;
    if(m_time_msc[_bar_shift] % 60000 != 0)
      return false;
    //---
    return true;
   }
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSeries::CSeries()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSeries::~CSeries()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSeries::Reset(void)
 {
  ::ArrayFree(m_time);
  ::ArrayFree(m_time_msc);
  ::ArrayFree(m_balance);
  ::ArrayFree(m_day_limit);
  ::ArrayFree(m_total_limit);
  ::ArrayFree(m_equity_open);
  ::ArrayFree(m_equity_high);
  ::ArrayFree(m_equity_low);
  ::ArrayFree(m_equity_close);
  ::ArrayFree(m_balance_gambeling);
  ::ArrayFree(m_equity_gambeling);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSeries::Create(CHistory *_History, CTask *_Task)
 {
  History = _History;
  Task = _Task;
  if(!IS_POINTER_DYNAMIC(History) || !IS_POINTER_DYNAMIC(Task))
    return false;

  if(DEF_SERILAIZE_METHOD == 1)
    return CreateMethodOne(); // defult

  if(DEF_SERILAIZE_METHOD == 2)
    return CreateMethodTwo(); // string

  if(DEF_SERILAIZE_METHOD == 3)
    return CreateMethodThree(); // push

  ulong start_cnt =::GetTickCount64();
  CreateMethodOne();
  ulong time1 = ::GetTickCount64() - start_cnt;
  ulong time_msc_1[];
  ::ArrayCopy(time_msc_1, m_time_msc);


  start_cnt =::GetTickCount64();
  CreateMethodTwo();
  ulong time2 = ::GetTickCount64() - start_cnt;
  ulong time_msc_2[];
  ::ArrayCopy(time_msc_2, m_time_msc);


  start_cnt =::GetTickCount64();
  CreateMethodThree();
  ulong time3 = ::GetTickCount64() - start_cnt;
  ulong time_msc_3[];
  ::ArrayCopy(time_msc_3, m_time_msc);


  int i1 = ::ArrayCompare(time_msc_1, time_msc_2);
  int i2 = ::ArrayCompare(time_msc_1, time_msc_3);
  int i3 = ::ArrayCompare(time_msc_2, time_msc_3);

  Print("MethodOne :: "    + (string)time1   + "\n" +
        "MethodTwo :: "    + (string)time2   + "\n" +
        "MethodThree :: "  + (string)time3   + "\n" +
        "Compare 1~2 :: "  + (string)i1      + "\n" +
        "Compare 1~3 :: "  + (string)i2      + "\n" +
        "Compare 2~3 :: "  + (string)i3
       );
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSeries::CreateMethodOne(void)
 {
  Reset();
  ulong time_msc[];
//---
  int total = History.DealsList.Total();
  for(int i = 0; i < total; i++)
   {
    int size = (int)time_msc.Size();

    CDeal *Deal = History.DealsList.At(i);
    if(!IS_POINTER_DYNAMIC(Deal))
      return false;

    ulong temp_time =  Deal.TimeMsc();

    ::ArraySort(time_msc);
    if(size == 0 || time_msc[::ArrayBsearch(time_msc, temp_time)] !=  temp_time)
     {
      if(::ArrayResize(time_msc, size + 1) == size + 1)
       {
        time_msc[size] = temp_time;
        size++;
       }
      else
        return false;
     }
   }
//---
  total =  History.PositionList.Total();
  for(int i = 0; i < total; i++)
   {
    CPosition *Position = History.PositionList.At(i);
    ulong start = ulong(::MathMax(Position.OpenRateTime() - 60, 0)) * 1000,
          end   = ulong(Position.CloseRateTime() + 60) * 1000;
    if(start > end)
      return false;

    int step = int((end - start) / 60000) + 1;
    int size = (int)time_msc.Size();

    for(int j = 0; j < step; j++)
     {
      ulong temp_time = start + j * 60000;
      if(temp_time > 0)
       {
        ::ArraySort(time_msc);
        if(size == 0 || time_msc[::ArrayBsearch(time_msc, temp_time)] !=  temp_time)
         {
          if(::ArrayResize(time_msc, size + 1) == size + 1)
           {
            time_msc[size] = temp_time;
            size++;
           }
          else
            return false;
         }
       }
     }
   }
  int size = (int)time_msc.Size();
//---
  if(::ArrayCopy(m_time_msc, time_msc) != size)
    return false;
//---

  if(::ArrayResize(m_time, size) != size ||
     ::ArrayResize(m_balance, size) != size ||
     ::ArrayResize(m_day_limit, size) != size ||
     ::ArrayResize(m_total_limit, size) != size ||
     ::ArrayResize(m_equity_open, size) != size ||
     ::ArrayResize(m_equity_high, size) != size ||
     ::ArrayResize(m_equity_low, size) != size ||
     ::ArrayResize(m_equity_close, size) != size ||
     ::ArrayResize(m_balance_gambeling, size) != size ||
     ::ArrayResize(m_equity_gambeling, size) != size)
    return false;

//---
  if(::ArrayInitialize(m_time, 0) != size ||
     ::ArrayInitialize(m_balance, 0.0) != size ||
     ::ArrayInitialize(m_day_limit, 0.0) != size ||
     ::ArrayInitialize(m_total_limit, 0.0) != size ||
     ::ArrayInitialize(m_equity_open, 0.0) != size ||
     ::ArrayInitialize(m_equity_high, 0.0) != size ||
     ::ArrayInitialize(m_equity_low, 0.0) != size ||
     ::ArrayInitialize(m_equity_close, 0.0) != size ||
     ::ArrayInitialize(m_balance_gambeling, false) != size ||
     ::ArrayInitialize(m_equity_gambeling, false) != size)
    return false;
//---
  for(int i = 0; i < size; i++)
   {
    m_time[i] = int(m_time_msc[i] / 1000);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSeries::CreateMethodTwo(void)
 {
  Reset();
  ulong time_msc[];
  ulong temp_time_msc[];
  string values;
//---
  int total = History.DealsList.Total();
  for(int i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);
    if(!IS_POINTER_DYNAMIC(Deal))
      return false;

    values += ::StringFormat("(%s),", ::StringFormat("%I64u", Deal.TimeMsc()));
   }
//---
  total =  History.PositionList.Total();
  for(int i = 0; i < total; i++)
   {
    CPosition *Position = History.PositionList.At(i);
    ulong start = ulong(::MathMax(Position.OpenRateTime() - 60, 0)) * 1000,
          end   = ulong(Position.CloseRateTime() + 60) * 1000;
    if(start > end)
      return false;
    int step = int((end - start) / 60000) + 1;

    for(int j = 0; j < step; j++)
     {
      values += ::StringFormat("(%s),", ::StringFormat("%I64u", start + j * 60000));
     }
   }
//---
  CSqliteSeries db;
  if(!db.Init())
    return false;

  if(!db.AddString(values))
    return false;

  if(!db.GetSeries(time_msc))
    return false;
  ::ArraySort(time_msc);
//---
  int size = (int)time_msc.Size();
//---
  if(::ArrayCopy(m_time_msc, time_msc) != size)
    return false;
//---

  if(::ArrayResize(m_time, size) != size ||
     ::ArrayResize(m_balance, size) != size ||
     ::ArrayResize(m_day_limit, size) != size ||
     ::ArrayResize(m_total_limit, size) != size ||
     ::ArrayResize(m_equity_open, size) != size ||
     ::ArrayResize(m_equity_high, size) != size ||
     ::ArrayResize(m_equity_low, size) != size ||
     ::ArrayResize(m_equity_close, size) != size ||
     ::ArrayResize(m_balance_gambeling, size) != size ||
     ::ArrayResize(m_equity_gambeling, size) != size)
    return false;

//---
  if(::ArrayInitialize(m_time, 0) != size ||
     ::ArrayInitialize(m_balance, 0.0) != size ||
     ::ArrayInitialize(m_day_limit, 0.0) != size ||
     ::ArrayInitialize(m_total_limit, 0.0) != size ||
     ::ArrayInitialize(m_equity_open, 0.0) != size ||
     ::ArrayInitialize(m_equity_high, 0.0) != size ||
     ::ArrayInitialize(m_equity_low, 0.0) != size ||
     ::ArrayInitialize(m_equity_close, 0.0) != size ||
     ::ArrayInitialize(m_balance_gambeling, false) != size ||
     ::ArrayInitialize(m_equity_gambeling, false) != size)
    return false;
//---
  for(int i = 0; i < size; i++)
   {
    m_time[i] = int(m_time_msc[i] / 1000);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSeries::CreateMethodThree(void)
 {
  Reset();
  ulong time_msc[];
  ulong temp_time_msc[];
  string values;
//--- Add Start Time
  if(History.StartTimeMsc() > 0)
    if(!CFunc::AddToArray(History.StartTimeMsc(), temp_time_msc))
      return false;
//--- Add Deal Time
  int total = History.DealsList.Total();
  for(int i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);
    if(!IS_POINTER_DYNAMIC(Deal))
      return false;

    if(!CFunc::AddToArray(Deal.TimeMsc(), temp_time_msc))
      return false;
   }
//--- Add Position OpenTime Until CloseTime
  total =  History.PositionList.Total();
  for(int i = 0; i < total; i++)
   {
    CPosition *Position = History.PositionList.At(i);
    ulong start = ulong(::MathMax(Position.OpenRateTime() - 60, 0)) * 1000,
          end   = ::MathMin(ulong(Position.CloseRateTime() + 60) * 1000, History.EndTimeMsc());
    if(start > end)
      return false;
    int step = int((end - start) / 60000) + 1;

    for(int j = 0; j < step; j++)
     {
      if(!CFunc::AddToArray(start + j * 60000, temp_time_msc))
        return false;
     }
   }
//--- Add End time
  if(!CFunc::AddToArray(History.EndTimeRateMsc(), temp_time_msc))
    return false;
  if(!CFunc::AddToArray(History.EndTimeMsc(), temp_time_msc))
    return false;

//---
  CSqliteSeries db;
  if(!db.Init())
    return false;

  if(!db.AddArray(temp_time_msc))
    return false;

  if(!db.GetSeries(time_msc))
    return false;
  ::ArraySort(time_msc);
//---
  int size = (int)time_msc.Size();
//---
  if(::ArrayCopy(m_time_msc, time_msc) != size)
    return false;
//---
  if(::ArrayResize(m_time, size) != size ||
     ::ArrayResize(m_balance, size) != size ||
     ::ArrayResize(m_day_limit, size) != size ||
     ::ArrayResize(m_total_limit, size) != size ||
     ::ArrayResize(m_equity_open, size) != size ||
     ::ArrayResize(m_equity_high, size) != size ||
     ::ArrayResize(m_equity_low, size) != size ||
     ::ArrayResize(m_equity_close, size) != size ||
     ::ArrayResize(m_balance_gambeling, size) != size ||
     ::ArrayResize(m_equity_gambeling, size) != size)
    return false;
//---
  double start_balance = Task.EquityCheckPointBalance(),
         day_limit     = Task.EquityCheckPointDayLimit(),
         total_limit   = Task.InitBalance() * Task.TotalLimitRatio();

  if(Task.EquityCheckPointTotalLimit() > 0)
    total_limit = Task.EquityCheckPointTotalLimit();

  if(::ArrayInitialize(m_time, 0) != size ||
     ::ArrayInitialize(m_balance, start_balance) != size ||
     ::ArrayInitialize(m_day_limit, day_limit) != size ||
     ::ArrayInitialize(m_total_limit, total_limit) != size ||
     ::ArrayInitialize(m_equity_open, start_balance) != size ||
     ::ArrayInitialize(m_equity_high, start_balance) != size ||
     ::ArrayInitialize(m_equity_low, start_balance) != size ||
     ::ArrayInitialize(m_equity_close, start_balance) != size ||
     ::ArrayInitialize(m_balance_gambeling, false) != size ||
     ::ArrayInitialize(m_equity_gambeling, false) != size)
    return false;
//---
  for(int i = 0; i < size; i++)
    m_time[i] = int(m_time_msc[i] / 1000);
//---
  return true;
 }
//+------------------------------------------------------------------+
