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
#define  DEF_IS_TEST_MODE false
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
    //---
    if(DEF_IS_TEST_MODE)
     {
      //string task = (string)(int)TASK_TYPE_RESET;
      string task = (string)(int)TASK_TYPE_UPDATE;
      string hash_a = "";
      string hash_b = "";
      if(true)
       {
        //--- my test account
        hash_a = "eyJ0aW1lTXNjIjoxNzMwMjgzMTg5NzY0fQ==";
        hash_b = "eyJ0aW1lIjoxNzMwMzEzOTYwMDAwLCJiYWxuY2UiOjE5OTkyNi4wMDAwMDAwMCwiZGF5TGltaXQiOjE5MDAwMC4wMDAwMDAwMCwidG90YWxMaW1pdCI6MTc2MDAwLjAwMDAwMDAwfQ==";

        string acc_id = "1223";
        string login = "899422";
        string pass = "0PeBg@1*";
        string init_bal = "200000";

        //--- Other Account
        //        hash_a = "";
        //        hash_b = "";
        //
        //        string acc_id = "1163";
        //        string login = "893992";
        //        string pass = "ZsE!p2@6";
        //        string init_bal = "5000";

        string response = "{"                                                +
                          "\"nodeId\": \"ata-test-node\","                   +
                          "\"task\": " + task + ","                          +
                          "\"accountId\": \"" + acc_id + "\","               +
                          "\"login\": " + login + ","                        +
                          "\"investorPassword\": \"" + pass + "\","          +
                          "\"server\": \"UNFXB-Real\","                      +
                          "\"hashPointA\": \"" + hash_a + "\","              +
                          "\"hashPointB\": \"" + hash_b + "\","              +
                          "\"userId\": 0,"                                   +
                          "\"initBalance\": " + init_bal + ","               +
                          "\"targetPercent\": 10,"                           +
                          "\"dailyPercent\": 5,"                             +
                          "\"totalPercent\": 12,"                            +
                          "\"tickScalp\":true,"                              +
                          "\"tickScalpTerm\": 30000,"                        +
                          "\"gambeling\":true, "                             +
                          "\"gambelingPercent\": 3,"                         +
                          "\"news\":true,"                                   +
                          "\"weekend\":true,"                                +
                          "\"trailTotal\":false,"                            +
                          "\"trailTotalType\": 0,"                           +
                          "\"secure\":false"                                 +
                          "}";

        App.CheckTask(response);
       }
      else     // accounts loop
       {
        int acc_ids[]      = {1163, 1172, 1173, 1181, 1182, 1185, 1188, 1194, 1197, 1199, 1200, 1201, 1203, 1204, 1209, 1216, 1218, 1219, 1221, 1222, 1223, 1227, 1230, 1231, 1237, 1251, 1252, 1253, 1255, 1256, 1257, 1258, 1259, 1260, 1261, 1262, 1263, 1264, 1265, 1266, 1267};
        int logins[]       = {893992, 893003, 808318, 894749, 322483, 810111, 819174, 893749, 126535, 889782, 895653, 893758, 813774, 895702, 897101, 895223, 898998, 812569, 889750, 808570, 899422, 122297, 896566, 897417, 812076, 813459, 815275, 889661, 892163, 896108, 898068, 903344, 902837, 815281, 901839, 789602, 899210, 902981, 899067, 901129, 903724};
        string passwords[] = {"ZsE!p2@6", "Y!P29j@y", ")bY4LXo2", "i8b@8!FJ", "OMDTin4)", "u23A)0ZL", "sGh#8]zA", "d41g!N!L", "S^riT0_e", "^1RfU4Jk", "U*!gI4h4", "iz1P9N!!", "]+q40USa", "89z*!KCp", "B7k*J@w4", "Ve*@R01v", "ZwV@92x!", "r#LVlt95", "7Xf9qW*x", "UyF5bOx%", "*Du0S!a5", "ux(Wb4gq", "5L@wg6P*", "!@pI9t9V", "z5O)jO*z", "w1E)5wQT", "Df0zk&!K", "tJ1&UM7)", "sYTk!22*", "39!*ncOF", "Jr*5@1Fa", "@el*6KN4", "Bb0@Rc6!", "r1enO!VO", "!*1Gy6fP", "rPlt5x4)", "34Eu*q@W", "P@w5@Qh8", "ok!*6HO8", "*J54B@es", "F@u@8Fi2"};
        int init_bals[]    = {5000, 10000, 100000, 200000, 25000, 5000, 200000, 10000, 25000, 5000, 10000, 5000, 5000, 25000, 50000, 50000, 10000, 5000, 10000, 5000, 200000, 25000, 5000, 10000, 5000, 5000, 5000, 5000, 5000, 5000, 5000, 50000, 10000, 5000, 5000, 10000, 25000, 5000, 200000, 10000, 5000};

        for(uint i = 0; i < acc_ids.Size(); i++)
         {
          string response = "{"                                                +
                            "\"nodeId\": \"ata-test-node\","                   +
                            "\"task\": " + task + ","                          +
                            "\"accountId\": \"" + (string)acc_ids[i] + "\","   +
                            "\"login\": " + (string)logins[i] + ","            +
                            "\"investorPassword\": \"" + passwords[i] + "\","  +
                            "\"server\": \"UNFXB-Real\","                      +
                            "\"hashPointA\": \"" + hash_a + "\","              +
                            "\"hashPointB\": \"" + hash_b + "\","              +
                            "\"userId\": 0,"                                   +
                            "\"initBalance\": " + (string)init_bals[i] + ","   +
                            "\"targetPercent\": 10,"                           +
                            "\"dailyPercent\": 5,"                             +
                            "\"totalPercent\": 12,"                            +
                            "\"tickScalp\":true,"                              +
                            "\"tickScalpTerm\": 30000,"                        +
                            "\"gambeling\":true, "                             +
                            "\"gambelingPercent\": 3,"                         +
                            "\"news\":true,"                                   +
                            "\"weekend\":true,"                                +
                            "\"trailTotal\":false,"                            +
                            "\"trailTotalType\": 0,"                           +
                            "\"secure\":false"                                 +
                            "}";

          App.CheckTask(response);
         }
       }
      continue;
     }
    //---
    if(!IsLicenced())
     {
      ::Print("Check Internet Connection...");
      ::Sleep(DEF_LICENCE_SLEEP_INTERVAL);
      continue;
     }
    //---
    if(App.CheckStopApp())
     {
      safe_stop = true;
      break;
     }
    if(App.CheckPauseApp())
     {
      ::Sleep(DEF_PAUSE_SLEEP_INTERVAL);
      continue;
     }
    //---
    App.CheckServerLoss();

    if(!App.isConnected() && !App.open(DEF_WEBSOCKET_OPEN_HEADER))
     {
      ::Sleep(DEF_SLEEP_INTERVAL);
      continue;
     }

    App.checkMessages(false);
    ::Sleep(DEF_SLEEP_INTERVAL);
   }
  while(!::IsStopped());

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
