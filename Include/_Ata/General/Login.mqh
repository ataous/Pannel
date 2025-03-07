//+------------------------------------------------------------------+
//|                                                        Login.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
//+------------------------------------------------------------------+
#include <WinAPI\winapi.mqh>
#include "Func.mqh"
//+------------------------------------------------------------------+
#define DEF_LOGIN_FILE_MENU_NO_CHART_MAX  1
#define DEF_LOGIN_FILE_MENU_NO_CHART_NOR  0
#define DEF_LOGIN_TO_TRADE_ACC_MENUE_ITEM 16

#define DEF_LOGIN_GA_ROOT                 0x00000002  // Retrieves the root window by walking the chain of parent windows
#define DEF_LOGIN_WM_COMMAND              0x00000111
#define DEF_LOGIN_WM_CLOSE                0x0010
#define DEF_LOGIN_BM_CLICK                0x000000F5
#define DEF_LOGIN_TRY_LOGIN_MAX           3
#define DEF_LOGIN_TRY_LOGIN_SLEEP_MSC     1000
#define DEF_LOGIN_TRY_TERM_CON_MAX        100
#define DEF_LOGIN_TRY_TERM_CON_SLEEP_MSC  100
#define DEF_LOGIN_TRY_POST_SLEEP_MSC      0
//+------------------------------------------------------------------+
enum ENUM_LOGIN_RESULT
 {
  LOGIN_SUCSES            = 0,
  LOGIN_FAIL              = 1,
  LOGIN_CONN_FAIL         = 2,
  LOGIN_LOAD_DEALS_FAIL   = 3,
  LOGIN_INIT_BALANCE_FAIL = 4,
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CLogin
 {
private:
  long               m_chart_id,
                     m_hl_main_chart_id,
                     m_hl_root,
                     m_hl_hmenu,
                     m_hl_sub_menu,
                     m_hl_sub_menu_item,
                     m_hl_login_popup,
                     m_hl_login_popup_btn_ok,
                     m_hl_login_popup_edt_pass,
                     m_hl_login_popup_edt_login,
                     m_hl_login_popup_cbx_server;
  bool               m_is_invalid,
                     m_close_charts;

  void               Reset(void);
  void               RestPopupHandels(void);
  bool               SafePostMessage(HANDLE wnd, uint msg, PVOID _wparam, PVOID _lparam)
   {
    if(PostMessageW(wnd, msg, _wparam, _lparam) > 0)
     {
      ::Sleep(DEF_LOGIN_TRY_POST_SLEEP_MSC);
      return true;
     }
    return false;
   }

  bool               IsTrueConnection(void);
  bool               IsValidLogin(bool &_is_valid_balance,
                                  bool &_is_valid_inti_balance,
                                  const double _init_balace);
  bool               IsCurrentLoginTrue(const long _login, const string _server);
  bool               GetMetaTraderHandels(void);
  bool               SetLoginFild(const string _login,
                                  const string _pass,
                                  const string _server);
  long               GetChartID(void);
  long               ChartWindowsHandle(long _chart_id);
  string             ReadJournal(void);

public:
  bool               OpenLoginPopup(void);

  bool               DestroyPopups(void)
   {
    if(!GetMetaTraderHandels())
      return false;
    //---
    HANDLE hl_popup = INVALID_HANDLE;
    uint ctry = 100;
    do
     {
      hl_popup = GetLastActivePopup(m_hl_root);
      if(hl_popup == m_hl_root)
        break;
      if(PostMessageW(hl_popup, DEF_LOGIN_WM_CLOSE, 0, 0) == 0)
       {
        ctry--;
        continue;
       }
     }
    while(hl_popup > 0 || ctry <= 0);
    //---
    return true;
   }

                     CLogin();
                    ~CLogin();
  bool               LoginToAccount(const string _login,
                                    const string _pass,
                                    const string _server);
  int                TryLogin(const long _login,
                              const string _pass,
                              const string _server,
                              const double _init_balace);
  bool               IsInvalid(void)                  const { return m_is_invalid;}

  void               CheckInvalidAccount(const long _login,
                                         const string _server);
  void               AddLebleToChart(const string _txt);
  void               CloseAllChart(const bool _value) { m_close_charts = _value;}
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLogin::CLogin()
 {
  m_close_charts = false;
  Reset();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CLogin::~CLogin()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLogin::Reset(void)
 {
  m_chart_id = WRONG_VALUE;
  m_hl_main_chart_id = INVALID_HANDLE;
  m_hl_root = INVALID_HANDLE;
  m_hl_hmenu = INVALID_HANDLE;
  m_hl_sub_menu = INVALID_HANDLE;
  m_hl_sub_menu_item = INVALID_HANDLE;
  RestPopupHandels();
  m_is_invalid = false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLogin::RestPopupHandels(void)
 {
  m_hl_login_popup = INVALID_HANDLE;
  m_hl_login_popup_btn_ok = INVALID_HANDLE;
  m_hl_login_popup_edt_pass = INVALID_HANDLE;
  m_hl_login_popup_edt_login = INVALID_HANDLE;
  m_hl_login_popup_cbx_server = INVALID_HANDLE;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::IsTrueConnection(void)
 {
  int connection_try = 0;
  while((!(bool)::TerminalInfoInteger(TERMINAL_CONNECTED) ||
         !::HistorySelect(0, ::TimeTradeServer() + ::PeriodSeconds(PERIOD_MN1)) ||
         ::HistoryDealsTotal() <= 0 ||
         ::SymbolsTotal(false) <= 0) &&
        connection_try < DEF_LOGIN_TRY_TERM_CON_MAX)
   {
    connection_try++;
    ::Sleep(DEF_LOGIN_TRY_TERM_CON_SLEEP_MSC);
   }
  if(connection_try >= DEF_LOGIN_TRY_TERM_CON_MAX)
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::IsValidLogin(bool &_is_valid_balance,
                          bool &_is_valid_inti_balance,
                          const double _init_balace)
 {
  for(int period = 0; period < DEF_LOGIN_TRY_TERM_CON_MAX; period++)
   {
    if(period > 0)
      ::Sleep(DEF_LOGIN_TRY_TERM_CON_SLEEP_MSC);

    _is_valid_balance = false;
    _is_valid_inti_balance = _init_balace > 0 ? false : true;
    //---
    if(::HistorySelect(0, ::TimeTradeServer() + ::PeriodSeconds(PERIOD_MN1)))
     {
      double curr_balance = ::AccountInfoDouble(ACCOUNT_BALANCE),
             balane = 0.0,
             init_balane = 0.0;
      bool find_first_deal = false;

      int total_deals = ::HistoryDealsTotal();
      for(int i = 0; i < total_deals; i++)
       {
        ulong ticket = ::HistoryDealGetTicket(i);
        if(ticket > 0)
         {
          long type  = ::HistoryDealGetInteger(ticket, DEAL_TYPE);
          if(type == DEAL_TYPE_BUY || type == DEAL_TYPE_SELL)
            find_first_deal = true;

          double value = ::HistoryDealGetDouble(ticket, DEAL_PROFIT) +
                         ::HistoryDealGetDouble(ticket, DEAL_COMMISSION) +
                         ::HistoryDealGetDouble(ticket, DEAL_SWAP) +
                         ::HistoryDealGetDouble(ticket, DEAL_FEE);
          balane += value;
          if(!find_first_deal)
            init_balane += value;
         }
       }
      //---
      _is_valid_balance = ::MathAbs(balane - curr_balance) < 1;

      if(!_is_valid_inti_balance)
        _is_valid_inti_balance = ::MathAbs(init_balane - _init_balace) < 1;
     }

    if(_is_valid_balance && _is_valid_inti_balance)
      break;
   }
  return _is_valid_balance && _is_valid_inti_balance;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::IsCurrentLoginTrue(const long _login, const string _server)
 {
  if(::AccountInfoInteger(ACCOUNT_LOGIN) != _login ||
     ::AccountInfoString(ACCOUNT_SERVER) != _server)
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//| Click on the item "Login to trading account"                     |
//+------------------------------------------------------------------+
bool CLogin::LoginToAccount(const string _login,
                            const string _pass,
                            const string _server)
 {
  if(GetMetaTraderHandels()                                            &&
     OpenLoginPopup()                                                  &&
     SetLoginFild(_login, _pass, _server)                              &&
     SafePostMessage(m_hl_login_popup_btn_ok, DEF_LOGIN_BM_CLICK, 0, 0))
    return true;
//---
  Reset();
  return false;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::OpenLoginPopup(void)
 {
//--- check is popup open
  if(m_hl_login_popup > 0)
   {
    long last_popup = GetLastActivePopup(m_hl_root);
    if(m_hl_login_popup == last_popup)
      return true;
   }
//--- Open Login To Trade Account Popup
  if(!SafePostMessage(m_hl_root, DEF_LOGIN_WM_COMMAND, m_hl_sub_menu_item, 0))
    return false;
//--- Get Login To Trade Account Popup handle
  m_hl_login_popup = GetLastActivePopup(m_hl_root);
  if(m_hl_login_popup <= 0)
    return false;
//--- Get Login To Trade Account Popup Btn Ok handle
  m_hl_login_popup_btn_ok = GetDlgItem(m_hl_login_popup, 0x00000001);
  if(m_hl_login_popup_btn_ok <= 0)
    return false;
//--- Get Login To Trade Account Popup Edit Pass handle
  m_hl_login_popup_edt_pass = FindWindowExW(m_hl_login_popup, NULL, "Edit", "");
  if(m_hl_login_popup_edt_pass <= 0)
    return false;
//--- Get Login To Trade Account Popup Edit Login handle
  m_hl_login_popup_edt_login = FindWindowExW(m_hl_login_popup, NULL, "ComboBox", "");
  if(m_hl_login_popup_edt_login <= 0)
    return false;
//--- Get Login To Trade Account Popup ComboBox Server handle
  m_hl_login_popup_cbx_server = FindWindowExW(m_hl_login_popup, m_hl_login_popup_edt_login, "ComboBox", "");
  if(m_hl_login_popup_cbx_server <= 0)
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::GetMetaTraderHandels(void)
 {
  if(m_hl_root > 0 && m_hl_sub_menu_item > 0)
    return true;
  Reset();
//---
  long mainChartID = GetChartID();
  if(mainChartID <= 0)
    return false;
//--- Get the Chart window handle (HWND)
  m_hl_main_chart_id = ChartWindowsHandle(mainChartID); ;
  if(m_hl_main_chart_id <= 0)
    return false;
//--- Get the MetaTrader handle
  m_hl_root = GetAncestor(m_hl_main_chart_id, DEF_LOGIN_GA_ROOT);
  if(m_hl_root <= 0)
    return false;
//--- Get the MetaTrader Menue handle
  m_hl_hmenu = GetMenu(m_hl_root);
  if(m_hl_hmenu <= 0)
    return false;
//--- Get the MetaTrader Sub Menue handle
  bool is_chart_maximaiz = ::ChartGetInteger(m_chart_id, CHART_IS_MAXIMIZED, 0);
  int number_menu = is_chart_maximaiz ? DEF_LOGIN_FILE_MENU_NO_CHART_MAX : DEF_LOGIN_FILE_MENU_NO_CHART_NOR;
  m_hl_sub_menu = GetSubMenu(m_hl_hmenu, number_menu);
  if(m_hl_sub_menu <= 0)
    return false;
//--- Get the MetaTrader Sub Menue Login To Trade Account Item handle
  m_hl_sub_menu_item = GetMenuItemID(m_hl_sub_menu, DEF_LOGIN_TO_TRADE_ACC_MENUE_ITEM);
  if(m_hl_sub_menu_item <= 0)
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CLogin::SetLoginFild(const string _login,
                          const string _pass,
                          const string _server)
 {
  if(SetWindowTextW(m_hl_login_popup_edt_pass, _pass) == 0)
    return false;
  if(SetWindowTextW(m_hl_login_popup_edt_login, _login) == 0)
    return false;
  if(SetWindowTextW(m_hl_login_popup_cbx_server, _server) == 0)
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
long CLogin::GetChartID(void)
 {
  m_chart_id = ::ChartFirst();
//---
  if(m_chart_id <= 0)
   {
    string name;
    if(::SymbolsTotal(false) <= 0)
      return WRONG_VALUE;

    name = ::SymbolName(0, false);

    if(!::SymbolSelect(name, true))
      return WRONG_VALUE;
    //---
    m_chart_id = ::ChartOpen(name, PERIOD_D1);
    if(m_chart_id <= 0)
      return WRONG_VALUE;
   }
  return m_chart_id;
 }
//+------------------------------------------------------------------+
//| The function gets the handle graphics                            |
//+------------------------------------------------------------------+
long CLogin::ChartWindowsHandle(long _chart_id)
 {
//--- prepare the variable to get the property value
  long result = WRONG_VALUE;
//--- reset the error value
  ::ResetLastError();
//--- receive the property value
  if(!::ChartGetInteger(_chart_id, CHART_WINDOW_HANDLE, 0, result))
   {
    //--- display the error message in Experts journal
    ::Print(__FUNCTION__ + ", Error Code = ", ::GetLastError());
   }
//--- return the value of the chart property
  return(result);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CLogin::TryLogin(const long _login,
                     const string _pass,
                     const string _server,
                     const double _init_balace)
 {
  int res = LOGIN_SUCSES;
  m_is_invalid = false;
//------
  bool is_curr_login_true = IsCurrentLoginTrue(_login, _server);
  bool is_login = false,
       is_connected = false;
  for(int login_try = 0; login_try < DEF_LOGIN_TRY_LOGIN_MAX; login_try++)
   {
    if(login_try != 0)
      ::Sleep(DEF_LOGIN_TRY_LOGIN_SLEEP_MSC);

    //--- Do Login
    if(!is_curr_login_true)
     {
      if(!LoginToAccount((string)_login, _pass, _server))
        continue;
      if(_login != ::AccountInfoInteger(ACCOUNT_LOGIN))
        continue;
     }
    is_curr_login_true = false;

    //--- Check Connection
    is_connected = IsTrueConnection();
    if(!is_connected)
      continue;
    is_login = true;
    break;
   }
//------ Validition
  bool is_valid_balance = false,
       is_valid_inti_balance = _init_balace > 0 ? false : true;
  if(is_login && is_connected)
   {
    for(int login_try = 0; login_try < DEF_LOGIN_TRY_LOGIN_MAX; login_try++)
     {
      if(!IsValidLogin(is_valid_balance, is_valid_inti_balance, _init_balace))
        continue;
      break;
     }
   }
//---
  if(!is_login || !is_connected || !is_valid_balance || !is_valid_inti_balance)
   {
    CheckInvalidAccount(_login, _server);

    if(!is_login)
      res = LOGIN_FAIL;
    else
      if(!is_connected)
        res = LOGIN_CONN_FAIL;
      else
        if(!is_valid_balance)
          res = LOGIN_LOAD_DEALS_FAIL;
        else
          if(!is_valid_inti_balance)
            res = LOGIN_INIT_BALANCE_FAIL;
   }
//---
  return res;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CLogin::CheckInvalidAccount(const long _login,
                                 const string _server)
 {
  m_is_invalid = false;
//---
  string txt = StringFormat("'%s': authorization on %s failed (Invalid account)", (string)_login, _server);

  if(!::StringToLower(txt))
    return;
//---
  MqlDateTime strut;
  ::TimeCurrent(strut);
  int year = strut.year;
  int mon  = strut.mon;
  int day  = strut.day;

  string name = (string)year + (mon < 10 ? "0" + (string)mon : (string)mon) + (day < 10 ? "0" + (string)day : (string)day) + ".log";

  string journal_file = ::TerminalInfoString(TERMINAL_DATA_PATH) + "\\logs\\" + name;
  string new_file = ::TerminalInfoString(TERMINAL_COMMONDATA_PATH) + "\\Files\\" + name;
//--- Win API
  if(!CopyFileW(journal_file, new_file, false))
    return;

//--- open the file using MQL5
  ::ResetLastError();
  int file_handle = ::FileOpen(name, FILE_READ | FILE_TXT | FILE_COMMON);
  int str_size;
  string str;

  if(file_handle != INVALID_HANDLE)
   {
    //--- read data from the file
    while(!::FileIsEnding(file_handle))
     {
      //--- find out how many symbols are used for writing the time
      str_size = ::FileReadInteger(file_handle, INT_VALUE);
      //--- read the string
      str = ::FileReadString(file_handle, str_size);
      //---
      if(::StringToLower(str) &&::StringFind(str, txt) >= 0)
       {
        m_is_invalid = true;
        break;
       }
     }
   }

  if(file_handle != INVALID_HANDLE && !::FileDelete(name, FILE_COMMON))
    ::FileClose(file_handle);
 }
//+------------------------------------------------------------------+
