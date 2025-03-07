//+------------------------------------------------------------------+
//|                                                    SeqLogger.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property strict


// Message levels
#define SEQ_LEV_DEBUG             "DBG" // debugging (for service use)
#define SEQ_LEV_INFO              "INF" // information (to track the functionality)
#define SEQ_LEV_WARNING           "WRN" // warning (attention)
#define SEQ_LEV_ERROR             "ERR" // non-critical error (check the log, work can be continued)
#define SEQ_LEV_FATAL             "FTL" // fatal error (work cannot be continued)
// Message output macros
#define SEQ_LOG_INIT(appName,urlSeq,httpHeader)       _SeqLogger.InIt(appName,urlSeq,httpHeader);
#define SEQ_LOG_SENDER                                _SeqLogger.SetSender(__FILE__, __FUNCTION__);
// type one
#define SEQ_LOG_INFO(message)                         SEQ_LOG_SENDER; _SeqLogger.Info(message);
#define SEQ_LOG_DEBUG(message)                        SEQ_LOG_SENDER; _SeqLogger.Debug(message);
#define SEQ_LOG_WARNING(message)                      SEQ_LOG_SENDER; _SeqLogger.Warning(message);
#define SEQ_LOG_ERROR(message)                        SEQ_LOG_SENDER; _SeqLogger.Error(message);
#define SEQ_LOG_FATAL(message)                        SEQ_LOG_SENDER; _SeqLogger.Fatal(message);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSeqLogger
 {
private:
  string             m_module; // module (file) name
  string             m_sender; // function name
  string             m_level; // message level
  string             m_message; // message text
  string             m_urlSeq; // url of the Seq service
  string             m_appName; // application name for Seq
  string             m_httpHeader;
  string             m_symbol;
  string             m_period;
  string             m_appId;
  string             m_login;
  bool               m_use_curr_login;
  string             m_task;
  string             m_status;
  string             m_errorCode;
  string             m_errorDescript;

  // private methods
  void               Log(string level, string message, string symbol = NULL, int period = WRONG_VALUE);
  string             TimeToStr(datetime value);
  string             PeriodToStr(ENUM_TIMEFRAMES value);
  string             Quote(string value);
  string             Level(void);
  void               SendToSeq(void);
  string             CreateJsonMsg(void);
public:
                     CSeqLogger(void);

  void               SetSender(string module, string sender);
  void               SetUrl(const string urlSeq)               { m_urlSeq = urlSeq;}
  void               SetAppName(const string appName)          { m_appName = appName;}
  void               SetHttpHeader(const string httpHeader)    { m_httpHeader = httpHeader;}
  void               SetAppId(const string appId)              { m_appId = appId;}
  void               SetLogin(const string login)              { m_login = login;}
  void               SetUseCurrLogin(const bool value)         { m_use_curr_login = value;}
  void               SetTask(const string task)                { m_task = task;}
  void               SetStatus(const string status)            { m_status = status;}
  void               SetErrorCode(const string errorCode)      { m_errorCode = errorCode;}
  void               SetDescription(const string descript)     { m_errorDescript = descript;}
  void               InIt(const string appName,
                          const string urlSeq,
                          const string httpHeader);
  void               Debug(string message, string symbol = NULL, int period = WRONG_VALUE)    { Log(SEQ_LEV_DEBUG, message, symbol, period);};
  void               Info(string message, string symbol = NULL, int period = WRONG_VALUE)     { Log(SEQ_LEV_INFO, message, symbol, period);};
  void               Warning(string message, string symbol = NULL, int period = WRONG_VALUE)  { Log(SEQ_LEV_WARNING, message, symbol, period);};
  void               Error(string message, string symbol = NULL, int period = WRONG_VALUE)    { Log(SEQ_LEV_ERROR, message, symbol, period);};
  void               Fatal(string message, string symbol = NULL, int period = WRONG_VALUE)    { Log(SEQ_LEV_FATAL, message, symbol, period);};
 };
static CSeqLogger _SeqLogger;
//+------------------------------------------------------------------+
// Constructor
//+------------------------------------------------------------------+
CSeqLogger::CSeqLogger(void)
 {
  m_appName = "MT5";
  m_urlSeq = "";
  m_httpHeader = "Content-Type: application/vnd.serilog.clef\r\n";
  m_appId = "-";
  m_use_curr_login = true;
  m_login = (string)::AccountInfoInteger(ACCOUNT_LOGIN);
  m_task = "-";
  m_status = "-";
  m_errorCode = "-";
  m_errorDescript = "-";
 }
//+------------------------------------------------------------------+
// Set the message sender
//+------------------------------------------------------------------+
void CSeqLogger::SetSender(string module, string sender)
 {
  m_module = module; // module (file) name
  m_sender = sender; // function name
  StringReplace(m_module, ".mq5", ".cpp5");
  StringReplace(m_module, ".mqh", ".cpp");
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CSeqLogger::InIt(const string appName, const string urlSeq, const string httpHeader)
 {
  SetAppName(appName);
  SetUrl(urlSeq);
  SetHttpHeader(httpHeader);
 }
//+------------------------------------------------------------------+
// Enclose the string in double quotes
//+------------------------------------------------------------------+
string CSeqLogger::Quote(string value)
 {
  return "\"" + value + "\"";
 }
//+------------------------------------------------------------------+
// Convert the message level to a format for Seq
//+------------------------------------------------------------------+
string CSeqLogger::Level()
 {
  if(m_level == SEQ_LEV_DEBUG)
    return "Debug";
  if(m_level == SEQ_LEV_WARNING)
    return "Warning";
  if(m_level == SEQ_LEV_ERROR)
    return "Error";
  if(m_level == SEQ_LEV_FATAL)
    return "Fatal";
  return "Information";
 }
//+------------------------------------------------------------------+
// Convert time to the ISO8601 format for Seq
//+------------------------------------------------------------------+
string CSeqLogger::TimeToStr(datetime value)
 {
  MqlDateTime mdt;
  TimeToStruct(value, mdt);
  ulong msec = GetTickCount64() % 1000; // for comparison
  return StringFormat("%4i-%02i-%02iT%02i:%02i:%02i.%03iZ",
                      mdt.year, mdt.mon, mdt.day, mdt.hour, mdt.min, mdt.sec, msec);
 }
//+------------------------------------------------------------------+
// Convert period to string
//+------------------------------------------------------------------+
string CSeqLogger::PeriodToStr(ENUM_TIMEFRAMES value)
 {
  return StringSubstr(EnumToString(value), 7);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CSeqLogger::CreateJsonMsg(void)
 {
// replace illegal characters
  StringReplace(m_message, "\n", " ");
  StringReplace(m_message, "\t", " ");
// prepare string in clef (Compact Logging Event Format)
  if(m_use_curr_login)
    m_login = (string)::AccountInfoInteger(ACCOUNT_LOGIN);

  string ext_message = ::StringFormat("%s(%s), %s(%s) / %s / %s / %s",
                                      m_appName, m_appId, m_task, m_status, m_module, m_sender, m_message);
  return "{" +
         "\"@t\":"               + Quote(TimeToStr(TimeCurrent())) + // message time
         ",\"@mt\":"             + Quote(ext_message) +              // message with additional info
         ",\"@l\":"              + Quote(Level()) +                  // level details (Information)
         ",\"Application\":"     + Quote(m_appName) +                // application name
         ",\"Id\":"              + Quote(m_appId) +                  // application id
         ",\"Login\":"           + Quote(m_login) +                  // login
         ",\"Task\":"            + Quote(m_task) +                   // task
         ",\"Symbol\":"          + Quote(m_symbol) +                 // symbol (EURUSD)
         ",\"Period\":"          + Quote(m_period) +                 // period (H4)
         ",\"Module\":"          + Quote(m_module) +                 // module name (__FILE__)
         ",\"Sender\":"          + Quote(m_sender) +                 // sender name (__FUNCTION__)
         ",\"Level\":"           + Quote(m_level) +                  // level abbreviation (INF)
         ",\"Status\":"          + Quote(m_status) +                 // status
         ",\"ErrorCode\":"       + Quote(m_errorCode) +              // error code
         ",\"ErrorDescrip\":"    + Quote(m_errorDescript) +          // error description
         ",\"Message\":"         + Quote(m_message) +                // message without additional info
         "}";
 }
//+------------------------------------------------------------------+
// Send message to Seq via http
//+------------------------------------------------------------------+
void CSeqLogger::SendToSeq(void)
 {
  string clef = CreateJsonMsg();

// prepare data fro POST request
  char data[]; // HTTP message body data array
  char result[]; // web service response data array
  string answer; // web service response headers
  string headers = m_httpHeader;
  ::ArrayResize(data, ::StringToCharArray(clef, data, 0, WHOLE_ARRAY, CP_UTF8) - 1);

// send message to Seq via http
  ::ResetLastError();
  int rcode = ::WebRequest("POST", m_urlSeq, headers, 3000, data, result, answer);
  if(rcode > 201)
   {
    ::PrintFormat("%s / rcode=%i / url=%s / answer=%s / %s", __FUNCTION__,
                  rcode, m_urlSeq, answer, ::CharArrayToString(result));
   }
 }
//+------------------------------------------------------------------+
// Write a message to log
//+------------------------------------------------------------------+
void CSeqLogger::Log(string level, string message, string symbol = NULL, int period = WRONG_VALUE)
 {
  m_level = level;
  m_message = message;
  m_symbol = symbol == NULL ? "-" : _Symbol;
  m_period = period == WRONG_VALUE ? "-" : PeriodToStr(_Period);

// print message to the experts journal (Toolbox/Experts)
//PrintFormat("%s: %s %s", m_level, m_sender, m_message);

// if URL is defined, send message to Seq via http
  if(m_urlSeq != "")
    SendToSeq();
 }
//+------------------------------------------------------------------+
#undef SEQ_LEV_DEBUG
#undef SEQ_LEV_INFO
#undef SEQ_LEV_WARNING
#undef SEQ_LEV_ERROR
#undef SEQ_LEV_FATAL
//+------------------------------------------------------------------+
