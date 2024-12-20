//+------------------------------------------------------------------+
//|                                                          App.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <_Ata\Web\ws\wsclient.mqh>
#include <_Ata\General\Tradestatistics.mqh>
#include <_Ata\General\Permissions.mqh>
#include <_Ata\General\Login.mqh>
#include <_Ata\Symbol\Base\Symbol.mqh>
#include <_Ata\Log\SeqLogger.mqh>
#include <_Ata\Web\Request.mqh>
#include "Task\Task.mqh"
#include "History\History.mqh"
#include "Series\Series.mqh"
#include "Equity\Equity.mqh"
#include "Database\Database.mqh"
#include <Files\FileTxt.mqh>
#include <_Ata\General\Func.mqh>
//+------------------------------------------------------------------+
//| Class CWebSocketApp                                              |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
class CWebSocketApp: public WebSocketClient<Hybi>
 {
private:
  CTask              *Task;
  CLogin             Login;
  CHistory           *History;
  CSeries            *Series;
  CEquity            *Equity;
  CTradeStatistics   *Statement;

  CDatabase          DB;
  CPermissions       Permissions;

  CRequest           ResultAPI;

  datetime           m_last_msg_time;
  string             m_node_id;
  bool               m_is_passe;

  bool               CheckAccount(void)
   {
    bool check = false;
    if(IS_POINTER_DYNAMIC(Task))
      if(::AccountInfoInteger(ACCOUNT_LOGIN) == Task.Login())
        return true;

    if(!check)
      Task.Result.ErrorCode(DEF_APP_ERR_LOGIN_FAIL);
    //---
    return check;
   }

  bool               TryLogin(void);
  bool               TrySendText(const string _msg);
  bool               TrySendResult(void);
  void               SendSeqTaskLog(const string message);
  bool               LoadSymbolsData(const bool _is_full = false);

  void               DoTask(void);
  bool               DoLogin(void);
  bool               DoCheckDbConnection(void);
  bool               DoUpdateHistory(void);
  bool               DoLoadData(void);
  bool               DoCreateSeries(void);
  bool               DoUpdateEquity(void);
  bool               DoUpdateStatement(void);
  bool               DoStoreDataOnDb(void);

  void               DoTaskReset(void);
  void               DoTaskUpdate(void);

  void               Reset(void)
   {
    FREE(History);
    FREE(Series);
    FREE(Equity);
    FREE(Statement);
   }
public:
                     CWebSocketApp(const string _address, const bool _useCompression = false);
                    ~CWebSocketApp();

  void               NodeId(const string _key)     { m_node_id = _key;}
  string             NodeId(void)            const { return m_node_id;}

  void               onConnected() override;
  void               onDisconnect() override;
  void               onMessage(IWebSocketMessage *msg) override;
  void               onFailed(void);
  void               CheckTask(string _task_txt);
  void               CheckServerLoss(void)
   {
    if(m_last_msg_time < ::TimeTradeServer() - DEF_WEBSOCKET_LOSS_SECEND)
     {
      close();
      m_last_msg_time = ::TimeTradeServer();
     }
   }
  bool               CheckStopApp(void);
  bool               CheckPauseApp(void);
  void               DestroyPopups(void)  { Login.DestroyPopups();}
  void               OpenLoginPopup(void) { Login.OpenLoginPopup();}
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CWebSocketApp::CWebSocketApp(const string _address, const bool _useCompression = false):
  WebSocketClient(_address, _useCompression),
  m_node_id(NULL),
  m_last_msg_time(::TimeTradeServer()),
  m_is_passe(false)
 {
  ResultAPI.Init(DEF_REULT_API_URL, DEF_REULT_API_HEADER);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CWebSocketApp::~CWebSocketApp()
 {
  Reset();
  FREE(Task);
  close();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::onConnected() override
 {
  WebSocketClient<Hybi>::onConnected();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::onDisconnect() override
 {
  WebSocketClient<Hybi>::onDisconnect();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::onMessage(IWebSocketMessage *msg) override
 {
  string response = msg.getString();
  ::StringReplace(response, "\n", "");
  FREE(msg);
//---
  CheckTask(response);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::onFailed(void)
 {
  close();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::CheckTask(string _task_txt)
 {
  Task = new CTask;
  if(Task.ParsTaskJson(_task_txt, m_node_id))
   {
    ulong start_cnt =::GetTickCount64();
    if(Task.IsValidTask())
     {
      if(DEF_IS_DEBUG)
        ::Print("Task: " + _task_txt + "." + __FUNCSIG__);

      _SeqLogger.SetAppId(Task.NodeId());
      _SeqLogger.SetTask(Task.TaskSting());
      //---
      DoTask();
     }
    //---
    ulong time_elapsed_ms =::GetTickCount64() - start_cnt;
    string message = NULL;
    if(Task.Result.ErrorCode() == 0)
      message = "Done In " + CFunc::FormatNumber(time_elapsed_ms, 0, "msc");
    else
      message = "Failed In " + CFunc::FormatNumber(time_elapsed_ms, 0, "msc") + " | " +
                "Error: " + Task.Result.ErrorDescription();

    message += " | " +
               "Id: " + (string)Task.AccountId() + " | " +
               "Task: " + (string)Task.TaskSting()  + " | " +
               "Login: " + (string)Task.Login() + " | " +
               "Pass: " + (string)Task.Password();
    //---
    DestroyPopups();
    OpenLoginPopup();
    SendSeqTaskLog(message);
    TrySendResult();
    //---
    ::Print(message + " " + __FUNCSIG__);
    m_last_msg_time = ::TimeTradeServer();
    //---
    Reset();
   }
  FREE(Task);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::DoTask(void)
 {
  switch(Task.Task())
   {
    case TASK_TYPE_RESET:                // 1- Algo: Normal  - From 0 time to current time  - calc all data
      DoTaskReset();
      break;
    case TASK_TYPE_UPDATE:               // 2- Algo: Normal  - From last check point time to current time - calc all data
      DoTaskUpdate();
      break;
    default:
      break;
   }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::TryLogin(void)
 {
  long   login      = (long)Task.Login();
  string server     = Task.Server() == "UNFXB-REAL" ? "UNFXB-Real" : Task.Server(),
         password   = Task.Password();
  double int_balace = Task.InitBalance();

  int login_result = Login.TryLogin(login, password, server, int_balace);

  if(login_result > LOGIN_SUCSES)
   {
    if(Login.IsInvalid())
     {
      ::Print("Invalid Account!!!");
      if(DB.IsConnect())
        DB.SetInvalidAccount(Task.AccountId());
      Task.Result.ErrorCode(DEF_APP_ERR_INVALID_ACC);
     }
    else
      if(login_result == LOGIN_CONN_FAIL)
        Task.Result.ErrorCode(DEF_APP_ERR_LOGIN_CONN_FAIL);
      else
        if(login_result == LOGIN_LOAD_DEALS_FAIL)
          Task.Result.ErrorCode(DEF_APP_ERR_LOGIN_DEALS_FAIL);
        else
          if(login_result == LOGIN_INIT_BALANCE_FAIL)
            Task.Result.ErrorCode(DEF_APP_ERR_LOGIN_INIT_BALANCE_FAIL);
          else
            Task.Result.ErrorCode(DEF_APP_ERR_LOGIN_FAIL);
    return false;
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::TrySendText(const string _msg)
 {
  int utry = 0;
  while(utry < DEF_APP_TRY_SEND_MAX)
   {
    if(send(_msg))
      return true;

    utry++;
    ::Sleep(DEF_APP_TRY_SEND_SLEEP_MSC);
   }
//---
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::TrySendResult(void)
 {
  bool check = false;
  string result = "{\"event\":\"result\",\"data\":" + Task.ResultJson() + "}";
  if(DEF_SEND_REULT_TO_SOCKET)
    check = TrySendText(result);
//---
  string resp = NULL;
  if(DEF_SEND_REULT_TO_API && ResultAPI.Post(resp, result))
    check = true;
//---
  return check;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::SendSeqTaskLog(const string message)
 {
  _SeqLogger.SetErrorCode((string)Task.Result.ErrorCode());
  _SeqLogger.SetDescription(Task.Result.ErrorDescription());
  _SeqLogger.SetStatus(Task.Result.Status());
  int code = Task.Result.ErrorCode();
  if(code == DEF_APP_ERR_LOGIN_FAIL)
   {
    SEQ_LOG_ERROR(message);
   }
  else
    if(code > 0)
     {
      SEQ_LOG_WARNING(message);
     }
    else
     {
      SEQ_LOG_INFO(message);
     }
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::LoadSymbolsData(const bool _is_full = false)
 {
  int total = History.SymbolList.Total();
//---
  if(total > 0)
   {
    CSymbol symbol;
    for(int i = 0; i < total; i++)
     {
      CSymbolData *symbol_data = History.SymbolList.At(i);
      string      name         = symbol_data.Name();
      datetime    start_time   = symbol_data.Time();
      //---
      int ltry = 0;
      bool is_symbol_init = false;
      do
       {
        is_symbol_init = symbol.Init(name, PERIOD_M1, start_time);
        if(is_symbol_init)
          break;
        ::Sleep(DEF_APP_TRY_LOAD_SYMBOL_SLEEP_MSC);
        ltry++;
       }
      while(!is_symbol_init && ltry <= DEF_APP_TRY_LOAD_SYMBOL);
      //---
      if(!is_symbol_init)
       {
        if(DEF_IS_DEBUG)
          ::Print("symbolInIt fail::", name);

        return false;
       }

      if(symbol.CheckLoadHistory() < 0)
       {
        if(DEF_IS_DEBUG)
          ::Print("CheckLoadHistory fail::", name);

        return false;
       }

      if(_is_full)
       {
        uint flags = COPY_TICKS_INFO | COPY_TICKS_TIME_MS | COPY_TICKS_BID |
                     COPY_TICKS_ASK;
        symbol.LoadTicks(TimeCurrent(), flags);
       }
     }
   }
//--- succeed
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoLogin(void)
 {
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- login to account
  if(!TryLogin())
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.LoginTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("Try Login faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.LoginTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("Login success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoCheckDbConnection(void)
 {
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- check DB connection
  if(!DB.IsConnect())
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_DB_CONN_FAIL);
    Task.Result.DbConnectionTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("DB connection faild:: " + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.DbConnectionTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("DB connection success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoUpdateHistory(void)
 {
  if(!CheckAccount())
    return false;
//---
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- update history
  History = new CHistory;
  if(!IS_POINTER_DYNAMIC(History) || !History.Update(Task))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_HISTORY_UPDATE_FAIL);
    Task.Result.UpdateHistoryTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("History Update faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- check has deal & pos else update not need
  if(History.DealsList.Total() < 0)
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_NO_DEAL_TOUPDATE);
    Task.Result.UpdateHistoryTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("History Update fail" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.UpdateHistoryTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("History Update success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoLoadData(void)
 {
  if(!CheckAccount())
    return false;
//---
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- load data
  if(!LoadSymbolsData(false))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_DATA_LOAD_FAIL);
    Task.Result.LoadDataTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("Load Symbols Data faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.LoadDataTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("Load Symbols Data success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoCreateSeries(void)
 {
  if(!CheckAccount())
    return false;
//---
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- create series
  Series = new CSeries;
  if(!IS_POINTER_DYNAMIC(Series) || !Series.Create(History, Task))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_SERIES_CREATE_FAIL);
    Task.Result.CreateSeriesTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("Series Create faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.CreateSeriesTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("Series Create success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoUpdateEquity(void)
 {
  if(!CheckAccount())
    return false;
//---
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- update equity
  Equity = new CEquity;
  if(!IS_POINTER_DYNAMIC(Equity) || !Equity.Update(History, Series, Task, UPDATE_TYPE_NORMAL))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_EQUITY_UPDATE_FAIL);
    Task.Result.UpdateEquityTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("Equity Update faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.UpdateEquityTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("Equity Update success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoUpdateStatement(void)
 {
  if(!CheckAccount())
    return false;
//---
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- update statement
  Statement = new CTradeStatistics;
//---
  if(!DEF_SETTING_STOR_STATEMENT)
    return true;
//---
  if(!Statement.Calculate(0, 0, History.InitialBlance()))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_SERIES_CREATE_FAIL);
    Task.Result.UpdateStatementTermMsc(time_elapsed_ms);
    if(DEF_IS_DEBUG)
      ::Print("Statement Update faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    return false;
   }
//--- succeed
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.UpdateStatementTermMsc(time_elapsed_ms);
  if(DEF_IS_DEBUG)
    ::Print("Statement Update success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
//---
  return CheckAccount();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::DoStoreDataOnDb(void)
 {
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//--- store data on db
  if(!DB.Update(Task, History, Series, Equity, Statement))
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    Task.Result.ErrorCode(DEF_APP_ERR_DB_STORE_FAIL);
    if(DEF_IS_DEBUG)
      ::Print("DB Update faild" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
    DB.StorHistory(Task);
    return false;
   }
//--- succeed
  if(DEF_IS_DEBUG)
   {
    time_elapsed_ms =::GetTickCount64() - start_cnt;
    ::Print("DB Update success" + " :: ", CFunc::FormatNumber(time_elapsed_ms, 0, "msc"));
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::CheckStopApp(void)
 {
  string str = NULL;
//---
  string filename = "PannelService\\STOPER.txt";
  CFileTxt File;
  File.SetCommon(true);

  if(File.Open(filename, FILE_READ | FILE_WRITE) != INVALID_HANDLE)
   {
    str = File.ReadString();
    File.Close();
    if(str == "")
      str = NULL;

   }
//---
  return str != NULL;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CWebSocketApp::CheckPauseApp(void)
 {
  string str = NULL;
//---
  string filename = "PannelService\\PUSSER.txt";
  CFileTxt File;
  File.SetCommon(true);

  if(File.Open(filename, FILE_READ | FILE_WRITE) != INVALID_HANDLE)
   {
    str = File.ReadString();
    File.Close();
    if(str != "" && str != NULL)
     {
      if(!m_is_passe)
        ::Print("Servise Passed...");
      m_is_passe = true;
     }
    else
     {
      if(m_is_passe)
        ::Print("Servise Restart...");
      m_is_passe = false;
     }
    return m_is_passe;
   }
//---
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::DoTaskReset(void)
 {
  Reset();
//---
  if(!DoLogin())
    return;
  if(!DoCheckDbConnection())
    return;
  if(!DoUpdateHistory())
    return;
  if(!DoLoadData())
    return;
  if(!DoCreateSeries())
    return;
  if(!DoUpdateEquity())
    return;
  if(!DoUpdateStatement())
    return;
  if(!DoStoreDataOnDb())
    return;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CWebSocketApp::DoTaskUpdate(void)
 {
//--- login to account
  if(!DoLogin())
    return;
//--- check DB connection
  if(!DoCheckDbConnection())
    return;
//--- update history by equity check point
  if(!DoUpdateHistory())
    return;
//--- load data
  if(!DoLoadData())
    return;
//--- create serise
  if(!DoCreateSeries())
    return;
//--- update equity
  if(!DoUpdateEquity())
    return;
//--- update statement
  if(!DoUpdateStatement())
    return;
//--- store data on db (all table)
  if(!DoStoreDataOnDb())
    return;
 }
//+------------------------------------------------------------------+
