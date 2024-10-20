//+------------------------------------------------------------------+
//|                                                      Licence.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property strict
//+------------------------------------------------------------------+
#include <_Ata\General\Crypt.mqh>
#include <_Ata\Web\Http.mqh>
#include "Defines.mqh"
//+------------------------------------------------------------------+
datetime Expiry = 0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsLicenced(void)
 {
  if(Expiry > ::TimeTradeServer() +::PeriodSeconds(PERIOD_H1) * 4)
    return true;
//---
  datetime exp_date_ir = ::StringToTime(DEF_MY_DECRYPT(httpGET(DEF_LIC_URL_IR)));
  if(exp_date_ir > ::TimeTradeServer())
   {
    Expiry = ::TimeTradeServer() + (::PeriodSeconds(PERIOD_H1) * 100);
    return true;
   }
//---
  datetime exp_date_com = ::StringToTime(DEF_MY_DECRYPT(httpGET(DEF_LIC_URL_COM)));
  if(exp_date_com > ::TimeTradeServer())
   {
    Expiry = ::TimeTradeServer() + (::PeriodSeconds(PERIOD_H1) * 100);
    return true;
   }
//---
  ::Print("Contact: " + "Ata Atalou.");
  return false;
 }
//+------------------------------------------------------------------+
string CreateLicence(datetime _time)
 {
  string hash = DEF_MY_ENCRYPT(::TimeToString(_time));
  ::Print(hash);
  return hash;
 }
//+------------------------------------------------------------------+
