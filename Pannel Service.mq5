//+------------------------------------------------------------------+
//|                                               Pannel Service.mq5 |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property strict
#property service
//+------------------------------------------------------------------+
#include <_Ata\PanelServer\Defines.mqh>
#include <_Ata\PanelServer\Licence.mqh>
#include <_Ata\PanelServer\WebSocketApp.mqh>

//+------------------------------------------------------------------+
//| Service program start function                                   |
//+------------------------------------------------------------------+
void OnStart()
 {
 //string s = CreateLicence(D'2025.01.29 00:00:00');
  ::Print("Service Started. " + __FUNCSIG__);
//---
  SEQ_LOG_INIT("node", DEF_SEQ_LOG_URL, DEF_SEQ_LOG_HEADER);

  CWebSocketApp App(DEF_WEBSOCKET_SERVER);
  bool safe_stop = false;
  do
   {
    if(!IsLicenced())
     {
      ::Print("Check Internet Connection...");
      ::Sleep(1000);
      continue;
     }

    if(App.CheckStopApp())
     {
      safe_stop = true;
      break;
     }
    if(App.CheckPauseApp())
     {
      ::Sleep(10000);
      continue;
     }

    App.CheckServerLoss();

    if(!App.isConnected() && !App.open(DEF_WEBSOCKET_OPEN_HEADER))
     {
      ::Sleep(100);
      continue;
     }

    App.checkMessages(false);
    ::Sleep(100);
   }
  while(!::IsStopped());

  App.close();
//---
  string message = "Service Stoped. ";
  ::Print(message + __FUNCSIG__);
  if(!safe_stop)
   {
    _SeqLogger.SetErrorCode((string)DEF_APP_ERR_SERVICE_STOP);
    _SeqLogger.SetDescription("Service Stoped");
    _SeqLogger.SetStatus(DEF_APP_STATUS_FAIL);
    _SeqLogger.SetTask("-");
    SEQ_LOG_FATAL(message);
   }
  else
    ::Print("Safe Stop...");
 }
//+------------------------------------------------------------------+
