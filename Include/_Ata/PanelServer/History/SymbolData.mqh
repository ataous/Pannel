//+------------------------------------------------------------------+
//|                                                   SymbolData.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#property strict
#include <Object.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSymbolData : public CObject
 {
private:
  string             name;
  datetime           time;
public:
  string             Name(void)            const { return(name); }
  void               Name(const string _name)    { name = _name; }
  datetime           Time(void)            const { return(time); }
  void               Time(const datetime _time)  { time = _time; }
  void               Set(const string _name, const datetime _time)
   {
    name = _name;
    time = _time;
   }
 };
//+------------------------------------------------------------------+
