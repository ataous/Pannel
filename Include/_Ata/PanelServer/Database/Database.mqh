//+------------------------------------------------------------------+
//|                                                     Database.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
#include <_Ata\Databases\MySQL\MySQLClass.mqh>
#include <_Ata\General\Tradestatistics.mqh>
#include "..\History\History.mqh"
#include "..\Series\Series.mqh"
#include "..\Equity\Equity.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDatabase
 {
private:
  CMySQL             DB;
  CHistory           *History;
  CSeries            *Series;
  CEquity            *Equity;
  CTask              *Task;
  CTradeStatistics   *Statement;

  string             m_hash_id;

  bool               Connect(void);
  void               Disconnect(void);
  bool               Execute(const string _query);
  bool               TransactionBegin(void);
  bool               TransactionExecute(const string _query);
  bool               TransactionCommit(void);
  bool               TransactionRollback(void);

  string             StringFild(const string _text);
  string             IntegerFild(const long _value);
  string             DoubleFild(const double _value, const int _digits = 8);
  string             DateTimeFild(const datetime _time);

  bool               CreateDatabase(void);
  bool               DropTables(void);
  bool               CreateTables(void);
  bool               CreateTableUser(void);
  bool               CreateTableServer(void);
  bool               CreateTableAccount(void);
  bool               CreateTableDeal(void);
  bool               CreateTableTransaction(void);
  bool               CreateTablePosition(void);
  bool               CreateTableBalance(void);
  bool               CreateTableEquity(void);
  bool               CreateTableObjective(void);
  bool               CreateTableStatement(void);
  bool               FillTempData(void);

  bool               StoreAccountData(void);
  bool               StoreDeals(void);
  bool               StorePositions(void);
  bool               StoreBalance(void);
  bool               StoreEquity(void);
  bool               StoreStatement(void);
  bool               StoreDrawdown(void);
  bool               StoreObjective(void);
  bool               StoreCheckPoints(void);
  bool               StoreNodeLastUpdate(const string _hash_id, const bool _is_trans = false);
public:
                     CDatabase();
                    ~CDatabase();
  bool               IsConnect(void);
  bool               Update(CTask              *_Task,
                            CHistory           *_History,
                            CSeries            *_Series,
                            CEquity            *_Equity,
                            CTradeStatistics   *_Statement);
  void               SetInvalidAccount(const ulong _account_id);
  bool               StorHistory(CTask *_Task, const bool _is_trans = false);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabase::CDatabase()
 {
  IsConnect();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CDatabase::~CDatabase()
 {
  Disconnect();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::Connect(void)
 {
  DB.SetTrace(DEF_DB_TRACE);
  return DB.Connect(DEF_DB_SERVER, DEF_DB_User, DEF_DB_Password, DEF_DB_DB_Name, DEF_DB_PORT, DEF_DB_SOCKET, DEF_DB_CLIENT_FALG);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDatabase::Disconnect(void)
 {
  DB.Disconnect();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::IsConnect(void)
 {
  if(DB.IsConnect())
    return true;

  return Connect();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::Execute(const string _query)
 {
  if(!DB.Execute(_query))
   {
    Disconnect();
    if(!Connect())
      return false;

    return DB.Execute(_query);
   }
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::TransactionBegin(void)
 {
  Disconnect();
  if(!Connect())
    return false;
  return DB.TransactionBegin();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::TransactionExecute(const string _query)
 {
  if(!DB.Execute(_query))
   {
    TransactionRollback();
    return false;
   }
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::TransactionCommit(void)
 {
  return DB.TransactionCommit();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::TransactionRollback(void)
 {
  return DB.TransactionRollback();
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabase::StringFild(const string _text)
 {
  return "'" + _text + "'";
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabase::IntegerFild(const long _value)
 {
  if(!::MathIsValidNumber(_value))
    return "null";
  return ::IntegerToString(_value);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabase::DoubleFild(const double _value, const int _digits = 8)
 {
  if(!::MathIsValidNumber(_value))
    return "null";
  double value = ::NormalizeDouble(_value, _digits);
  return ::DoubleToString(value, _digits);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CDatabase::DateTimeFild(const datetime _time)
 {
//-- fix mysql bug 1292 error
  datetime time = _time > (2 * 60 * 60) ? _time : (2 * 60 * 60);

  return StringFild(::TimeToString(time, TIME_DATE | TIME_MINUTES | TIME_SECONDS));
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::Update(CTask              *_Task,
                       CHistory           *_History,
                       CSeries            *_Series,
                       CEquity            *_Equity,
                       CTradeStatistics   *_Statement)
 {
  ulong start_cnt =::GetTickCount64(),
        time_elapsed_ms;
//---
  Task = _Task;
  History = _History;
  Series = _Series;
  Equity = _Equity;
  Statement = _Statement;

  if(!IS_POINTER_DYNAMIC(Task) || !IS_POINTER_DYNAMIC(History) || !IS_POINTER_DYNAMIC(Series) || !IS_POINTER_DYNAMIC(Equity) || !IS_POINTER_DYNAMIC(Statement))
    return false;

  bool is_store = false;
  for(int i = 0; i < 3; i++)
   {
    if(!TransactionBegin())
      continue;
    if(!StoreAccountData())
      continue;
    if(!StoreDeals())
      continue;
    if(!StorePositions())
      continue;
    if(!StoreBalance())
      continue;
    if(!StoreEquity())
      continue;
    if(!StoreStatement())
      continue;
    if(!StoreObjective())
      continue;
    if(!StoreCheckPoints())
      continue;
    if(!StorHistory(Task, true))
      continue;
    if(!TransactionCommit())
      continue;

    is_store = true;
    break;
   }
//---
  time_elapsed_ms =::GetTickCount64() - start_cnt;
  Task.Result.StoreDataTermMsc(time_elapsed_ms);
//---
  return is_store;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDatabase::SetInvalidAccount(const ulong _account_id)
 {
  string query = NULL;
  query  = "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_INVALID_ACCOUNT + "` (";
  query += "`account_id`";      //INT UNSIGNED      NOT NULL,";
  query += ") VALUES (";
  query += IntegerFild(_account_id);
  query += ");";
//---
//string query = "UPDATE `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_ACCOUNT +
//               "` SET `account_status`=" + (string)DEF_DB_INVALID_ACC_CODE +
//               " WHERE `id` = " + (string)_account_id + ";";
//---
  DB.Execute(query);
 }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateDatabase(void)
 {
  if(!DropTables())
    return false;
  if(!CreateTables())
    return false;
  if(!FillTempData())
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::DropTables(void)
 {
  string query = "DROP TABLE IF EXISTS `sgb`.`statement`;";
  query += "DROP TABLE IF EXISTS `sgb`.`objective`;";
  query += "DROP TABLE IF EXISTS `sgb`.`equity`;";
  query += "DROP TABLE IF EXISTS `sgb`.`balance`;";
  query += "DROP TABLE IF EXISTS `sgb`.`balance_equity`;";
  query += "DROP TABLE IF EXISTS `sgb`.`position`;";
  query += "DROP TABLE IF EXISTS `sgb`.`transaction`;";
  query += "DROP TABLE IF EXISTS `sgb`.`deal`;";
  query += "DROP TABLE IF EXISTS `sgb`.`account`;";
  query += "DROP TABLE IF EXISTS `sgb`.`server`;";
  query += "DROP TABLE IF EXISTS `sgb`.`user`; ";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTables(void)
 {
  if(!CreateTableUser())
    return false;
  if(!CreateTableServer())
    return false;
  if(!CreateTableAccount())
    return false;
  if(!CreateTableDeal())
    return false;
  if(!CreateTableTransaction())
    return false;
  if(!CreateTablePosition())
    return false;
  if(!CreateTableBalance())
    return false;
  if(!CreateTableEquity())
    return false;
  if(!CreateTableObjective())
    return false;
  if(!CreateTableStatement())
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableUser(void)
 {
  string table_name = DEF_DB_TBL_USER;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`           INT UNSIGNED      NOT NULL AUTO_INCREMENT,";
  query += "`first_name`   VARCHAR ( 255 )   NULL,";
  query += "`last_name`    VARCHAR ( 255 )   NULL,";
  query += "`email`        VARCHAR ( 255 )   NOT NULL,";
  query += "`password`     VARCHAR ( 255 )   NOT NULL,";

  query += "`created_at`   TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`   TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`   TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "UNIQUE INDEX `user_idx_email` ( `email` ) USING BTREE,";
  query += "CONSTRAINT `user_ck_email_lower_case` CHECK (`email` = LOWER( `email` ))";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableServer(void)
 {
  string table_name = DEF_DB_TBL_SERVER;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`           INT UNSIGNED      NOT NULL AUTO_INCREMENT,";
  query += "`broker_name`  VARCHAR ( 255 )   NOT NULL,";
  query += "`server`       VARCHAR ( 255 )   NOT NULL,";
  query += "`domain`       VARCHAR ( 255 )   NOT NULL,";
  query += "`platform`     VARCHAR ( 32 )    NOT NULL DEFAULT 'mt5',";
  query += "`type`         VARCHAR ( 32 )    NOT NULL DEFAULT 'demo',";

  query += "`created_at`   TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`   TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`   TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "UNIQUE INDEX `broker_idx_server` ( `server` ) USING BTREE,";
  query += "UNIQUE INDEX `broker_idx_domain` ( `domain` ) USING BTREE,";
  query += "CONSTRAINT `user_ck_domain_lower_case` CHECK (`domain` = LOWER( `domain` ))";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableAccount(void)
 {
  string table_name = DEF_DB_TBL_ACCOUNT;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                 INT UNSIGNED      NOT NULL AUTO_INCREMENT,";
  query += "`user_id`            INT UNSIGNED      NOT NULL,";
  query += "`server_id`          INT UNSIGNED      NOT NULL,";
  query += "`login`              INT UNSIGNED      NOT NULL,";
  query += "`pasword`            VARCHAR ( 255 )   NOT NULL,";
  query += "`investor_password`  VARCHAR ( 255 )   NOT NULL,";
  query += "`hash_point_a`       VARCHAR ( 255 )   NULL,";
  query += "`hash_point_b`       VARCHAR ( 255 )   NULL,";

  query += "`created_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`         TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `account_idx_fk_user_id` ( `user_id` ) USING BTREE,";
  query += "INDEX `account_idx_fk_server_id` ( `server_id` ) USING BTREE,";
  query += "CONSTRAINT `account_user_id_fkey` FOREIGN KEY ( `user_id` ) REFERENCES `sgb`.`user` ( `id` ) ON DELETE RESTRICT ON UPDATE CASCADE,";
  query += "CONSTRAINT `account_server_id_fkey` FOREIGN KEY ( `server_id` ) REFERENCES `sgb`.`server` ( `id` ) ON DELETE RESTRICT ON UPDATE CASCADE ";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableDeal(void)
 {
  string table_name = DEF_DB_TBL_DEAL;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`              VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`      INT UNSIGNED      NOT NULL,";
  query += "`deal_ticket`     BIGINT UNSIGNED   NOT NULL,";
  query += "`order_ticket`    BIGINT UNSIGNED   NOT NULL,";
  query += "`time`            TIMESTAMP         NOT NULL,";
  query += "`time_rate`       TIMESTAMP         NOT NULL,";
  query += "`time_msc`        BIGINT UNSIGNED   NOT NULL,";
  query += "`type`            TINYINT UNSIGNED  NOT NULL,";
  query += "`entry`           TINYINT UNSIGNED  NOT NULL,";
  query += "`magic`           BIGINT            ZEROFILL NOT NULL,";
  query += "`reason`          TINYINT UNSIGNED  NOT NULL,";
  query += "`position_ticket` BIGINT UNSIGNED   NOT NULL,";
  query += "`volume`          DOUBLE            NOT NULL,";
  query += "`price`           DOUBLE            NOT NULL,";
  query += "`commission`      DOUBLE            NOT NULL,";
  query += "`swap`            DOUBLE            NOT NULL,";
  query += "`profit`          DOUBLE            NOT NULL,";
  query += "`fee`             DOUBLE            NOT NULL,";
  query += "`stop_loss`       DOUBLE            NOT NULL,";
  query += "`take_profit`     DOUBLE            NOT NULL,";
  query += "`symbol`          VARCHAR ( 255 )   NOT NULL,";
  query += "`comment`         VARCHAR ( 255 )   NULL,";
  query += "`external_id`     VARCHAR ( 255 )   NULL,";

  query += "`created_at`      TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`      TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`      TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `deal_idx_fk_account_id` ( `account_id` ) USING BTREE,";
  query += "INDEX `deal_idx_fk_deal_ticket` ( `deal_ticket` ) USING BTREE,";
  query += "CONSTRAINT `deal_account_id_fkey` FOREIGN KEY ( `account_id` ) REFERENCES `sgb`.`account` ( `id` ) ON DELETE RESTRICT ON UPDATE CASCADE ";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableTransaction(void)
 {
  string table_name = DEF_DB_TBL_TRANSACTION;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                 VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`         INT UNSIGNED      NOT NULL,";

  query += "`created_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`         TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `transaction_idx_fk_account_id` ( `account_id` ) USING BTREE,";
  query += "CONSTRAINT `transaction_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `sgb`.`account` ( `id` ) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTablePosition(void)
 {
  string table_name = DEF_DB_TBL_POSITION;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                 VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`         INT UNSIGNED      NOT NULL,";
  query += "`open_deal_ticket`   BIGINT UNSIGNED   NOT NULL,";
  query += "`open_time`          TIMESTAMP         NOT NULL,";
  query += "`open_time_rate`     TIMESTAMP         NOT NULL,";
  query += "`open_time_msc`      BIGINT            NOT NULL,";
  query += "`open_price`         DOUBLE            NOT NULL,";
  query += "`open_commission`    DOUBLE            NOT NULL,";
  query += "`open_swap`          DOUBLE            NOT NULL,";
  query += "`open_fee`           DOUBLE            NOT NULL,";
  query += "`close_deal_ticket`  BIGINT UNSIGNED   NOT NULL,";
  query += "`close_time`         TIMESTAMP         NOT NULL,";
  query += "`close_time_rate`    TIMESTAMP         NOT NULL,";
  query += "`close_time_msc`     BIGINT            NOT NULL,";
  query += "`close_price`        DOUBLE            NOT NULL,";
  query += "`close_commission`   DOUBLE            NOT NULL,";
  query += "`close_swap`         DOUBLE            NOT NULL,";
  query += "`close_fee`          DOUBLE            NOT NULL,";
  query += "`cost`               DOUBLE            NOT NULL,";
  query += "`profit`             DOUBLE            NOT NULL,";
  query += "`net_profit`         DOUBLE            NOT NULL,";
  query += "`duratian_msc`       BIGINT UNSIGNED   NOT NULL,";
  query += "`is_weekend`         TINYINT           NOT NULL,";
  query += "`type`               TINYINT           NOT NULL,";
  query += "`volume`             DOUBLE            NOT NULL,";
  query += "`symbol`             VARCHAR ( 255 )   NOT NULL,";
  query += "`position_ticket`    BIGINT UNSIGNED   NOT NULL,";
  query += "`is_tick_scalp`      TINYINT ( 1 )     NOT NULL DEFAULT 0,";
  query += "`is_weekend`         TINYINT ( 1 )     NOT NULL DEFAULT 0,";
  query += "`is_news_trading`    TINYINT ( 1 )     NOT NULL DEFAULT 0,";
  query += "`news`               VARCHAR ( 255 )   NULL,";
  query += "`status`             TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "`created_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`         TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`         TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `position_idx_fk_account_id` ( `account_id` ) USING BTREE,";
  query += "INDEX `position_idx_fk_position_ticket` ( `position_ticket` ) USING BTREE,";
  query += "CONSTRAINT `position_account_id_fkey` FOREIGN KEY ( `account_id` ) REFERENCES `sgb`.`account` ( `id` ) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableBalance(void)
 {
  string table_name = DEF_DB_TBL_BALANCE;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                 VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`         INT UNSIGNED      NOT NULL,";
  query += "`time_msc`           BIGINT            NOT NULL,";
  query += "`balance`            DOUBLE            NULL,";
  query += "`last_day_balance`   DOUBLE            NULL,";
  query += "`daily_limit`        DOUBLE            NULL,";
  query += "`total_limit`        DOUBLE            NULL,";

  query += "`created_at`      TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`      TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`      TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY (`id`),";
  query += "INDEX `balance_equity_idx_fk_account_id`(`account_id`) USING BTREE,";
  query += "CONSTRAINT `balance_equity_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `sgb`.`account` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableEquity(void)
 {
  string table_name = DEF_DB_TBL_EQUITY;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                    VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`            INT UNSIGNED      NOT NULL,";

  query += "`time`                  TIMESTAMP         NOT NULL,";
  query += "`time_msc`              BIGINT            NOT NULL,";
  query += "`balance`               DOUBLE NULL,";
  query += "`open_equity`           DOUBLE            NULL,";
  query += "`high_equity`           DOUBLE            NULL,";
  query += "`low_equity`            DOUBLE            NULL,";
  query += "`close_equity`          DOUBLE            NULL,";
  query += "`daily_limit`           DOUBLE            NULL,";
  query += "`total_limit`           DOUBLE            NULL,";
  query += "`is_balance_gambeling`  TINYINT ( 1 )     NOT NULL DEFAULT 0,";
  query += "`is_equity_gambeling`   TINYINT ( 1 )     NOT NULL DEFAULT 0,";
  query += "`created_at`            TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`            TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`            TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY (`id`),";
  query += "INDEX `balance_equity_idx_fk_account_id`(`account_id`) USING BTREE,";
  query += "CONSTRAINT `balance_equity_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `sgb`.`account` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableObjective(void)
 {
  string table_name = DEF_DB_TBL_OBJECTIVE;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";

  query += "`id`                             VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`                     INT UNSIGNED      NOT NULL,";

  query += "`init_balance`                   DOUBLE            NULL,";
  query += "`balance_min_value`              DOUBLE            NULL,";
  query += "`balance_min_time`               TIMESTAMP         NULL,";
  query += "`balance_min_time_msc`           BIGINT            NULL,";
  query += "`balance_max_value`              DOUBLE            NULL,";
  query += "`balance_max_time`               TIMESTAMP         NULL,";
  query += "`balance_max_time_msc`           BIGINT            NULL,";
  query += "`balance_is_daily_touch`         TINYINT ( 1 )     NULL,";
  query += "`balance_daily_touch_value`      DOUBLE            NULL,";
  query += "`balance_daily_touch_Time`       TIMESTAMP         NULL,";
  query += "`balance_daily_touch_Time_Msc`   BIGINT            NULL,";
  query += "`balance_daily_touch_Limit`      DOUBLE            NULL,";
  query += "`balance_is_total_touch`         TINYINT ( 1 )     NULL,";
  query += "`balance_total_touch_value`      DOUBLE            NULL,";
  query += "`balance_total_touch_time`       TIMESTAMP         NULL,";
  query += "`balance_total_touch_time_Msc`   BIGINT            NULL,";
  query += "`balance_total_touch_limit`      DOUBLE            NULL,";
  query += "`equity_min_value`               DOUBLE            NULL,";
  query += "`equity_min_time`                TIMESTAMP         NULL,";
  query += "`equity_min_time_msc`            BIGINT            NULL,";
  query += "`equity_max_value`               DOUBLE            NULL,";
  query += "`equity_max_time`                TIMESTAMP         NULL,";
  query += "`equity_max_time_msc`            BIGINT            NULL,";
  query += "`equity_is_daily_touch`          TINYINT ( 1 )     NULL,";
  query += "`equity_daily_touch_value`       DOUBLE            NULL,";
  query += "`equity_daily_touch_Time`        TIMESTAMP         NULL,";
  query += "`equity_daily_touch_Time_Msc`    BIGINT            NULL,";
  query += "`equity_daily_touch_Limit`       DOUBLE            NULL,";
  query += "`equity_is_total_touch`          TINYINT ( 1 )     NULL,";
  query += "`equity_total_touch_value`       DOUBLE            NULL,";
  query += "`equity_total_touch_time`        TIMESTAMP         NULL,";
  query += "`equity_total_touch_time_Msc`    BIGINT            NULL,";
  query += "`equity_total_touch_limit`       DOUBLE            NULL,";

  query += "`created_at`                     TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`                     TIMESTAMP         NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`                     TINYINT ( 1 )     NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `objective_idx_fk_account_id`(`account_id`) USING BTREE,";
  query += "CONSTRAINT `objective_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `sgb`.`account` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::CreateTableStatement(void)
 {
  string table_name = DEF_DB_TBL_STATEMENT;
  string query = "CREATE TABLE IF NOT EXISTS `" + DEF_DB_DB_Name + "`.`" + table_name + "` (";


  query += "`id`                             VARCHAR ( 255 )   NOT NULL,";
  query += "`account_id`                     INT UNSIGNED      NOT NULL,";

  query += "`total_net_profit`               DOUBLE         NULL,";
  query += "`gross_profit`                   DOUBLE         NULL,";
  query += "`gross_loss`                     DOUBLE         NULL,";
  query += "`profit_factor`                  DOUBLE         NULL,";
  query += "`recovery_factor`                DOUBLE         NULL,";
  query += "`expected_payoff`                DOUBLE         NULL,";
  query += "`sharpe_ratio`                   DOUBLE         NULL,";
  query += "`ahpr`                           DOUBLE         NULL,";
  query += "`ahpr_percent`                   DOUBLE         NULL,";
  query += "`ghpr`                           DOUBLE         NULL,";
  query += "`ghpr_percent`                   DOUBLE         NULL,";
  query += "`z_score`                        DOUBLE         NULL,";
  query += "`z_score_percent`                DOUBLE         NULL,";
  query += "`lr_correlation`                 DOUBLE         NULL,";
  query += "`lr_standard_error`              DOUBLE         NULL,";
  query += "`total_deals`                    INT            NULL,";
  query += "`total_trades`                   INT            NULL,";
  query += "`total_profit_trades`            INT            NULL,";
  query += "`total_loss_trades`              INT            NULL,";
  query += "`total_win_rate`                 DOUBLE         NULL,";
  query += "`total_loss_rate`                DOUBLE         NULL,";
  query += "`total_average_profit_trade`     DOUBLE         NULL,";
  query += "`total_average_loss_trade`       DOUBLE         NULL,";
  query += "`long_trades`                    INT            NULL,";
  query += "`long_profit_trades`             INT            NULL,";
  query += "`long_loss_trades`               INT            NULL,";
  query += "`long_win_rate`                  DOUBLE         NULL,";
  query += "`long_loss_rate`                 DOUBLE         NULL,";
  query += "`short_trades`                   INT            NULL,";
  query += "`short_profit_trades`            INT            NULL,";
  query += "`short_loss_trades`              INT            NULL,";
  query += "`short_win_rate`                 DOUBLE         NULL,";
  query += "`short_loss_rate`                DOUBLE         NULL,";
  query += "`largest_profit_trade`           DOUBLE         NULL,";
  query += "`largest_loss_trade`             DOUBLE         NULL,";
  query += "`ave_profit_trade`               DOUBLE         NULL,";
  query += "`ave_loss_trade`                 DOUBLE         NULL,";
  query += "`max_consecutive_wins`           DOUBLE         NULL,";
  query += "`max_consecutive_losses`         DOUBLE         NULL,";
  query += "`ave_consecutive_wins_trades`    INT            NULL,";
  query += "`ave_consecutive_losses_trades`  INT            NULL,";

  query += "`created_at`                     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,";
  query += "`updated_at`                     TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,";
  query += "`is_deleted`                     TINYINT ( 1 )  NOT NULL DEFAULT 0,";

  query += "PRIMARY KEY ( `id` ),";
  query += "INDEX `statement_idx_fk_account_id`(`account_id`) USING BTREE,";
  query += "CONSTRAINT `statement_account_id_fkey` FOREIGN KEY (`account_id`) REFERENCES `sgb`.`account` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE";

  query += ") ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;";
//---
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::FillTempData(void)
 {

  string query = "";
//--- fill user
  query += "INSERT INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_USER + "` ( `first_name`, `last_name`, `email`, `password` ) VALUES ";
  query += "( 'test_1',    'tester_1',    'Ghasemgolalizade1369@yahoo.com',   'temp_pass1' ),";
  query += "( 'test_2',    'tester_2',    'hasankarimiyan47@gmail.com',       'temp_pass2' ),";
  query += "( 'test_3',    'tester_3',    'erfanijavad0@gmail.com',           'temp_pass3' ),";
  query += "( 'test_4',    'tester_4',    'dararahmati1366@gmail.com',        'temp_pass4' ),";
  query += "( 'test_5',    'tester_5',    'sahar1ndco@gmail.com',             'temp_pass5' ),";
  query += "( 'test_6',    'tester_6',    'samaxanmirzayi@gmail.com',         'temp_pass6' ),";
  query += "( 'test_7',    'tester_7',    'teolhhiadm@gmail.com',             'temp_pass7' ),";
  query += "( 'test_8',    'tester_8',    'arashghobadi795@gmail.com',        'temp_pass8' ),";
  query += "( 'test_9',    'tester_9',    'Alimazuniii@gmail.com',            'temp_pass9' ),";
  query += "( 'test_10',   'tester_10',   'sadeghi650@gmail.com',             'temp_pass10' ),";
  query += "( 'test_11',   'tester_11',   'shahramavd@yahoo.com',             'temp_pass11' ),";
  query += "( 'test_12',   'tester_12',   'shahmaribehzad9@gmail.com',        'temp_pass12' ),";
  query += "( 'test_13',   'tester_13',   'Amirhosseinrohani77@gmail.com',    'temp_pass13' ),";
  query += "( 'test_14',   'tester_14',   'aramrehmeti@gmail.com',            'temp_pass14' ),";
  query += "( 'test_15',   'tester_15',   'mirshamsi1344@gmail.com',          'temp_pass15' ),";
  query += "( 'test_16',   'tester_16',   'naderramezani13@gmail.com',        'temp_pass16' ),";
  query += "( 'test_17',   'tester_17',   'hamed.zahra9713@gmail.com',        'temp_pass17' ),";
  query += "( 'test_18',   'tester_18',   'farshad.kamrava@gmail.com',        'temp_pass18' ),";
  query += "( 'test_19',   'tester_19',   'anush.sharifi95@gmail.com',        'temp_pass19' );";
//--- fill server
  query += "INSERT INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_SERVER + "` ( `broker_name`, `server`, `domain`, `platform`, `type` ) VALUES ";
  query += "( 'UNFXB', 'UNFXB-REAL', '-', 'mt5', 'demo' );";
//--- fill account
  query += "INSERT INTO `sgb`.`account` ( `user_id`,`server_id`,`login`, `pasword`, `investor_password`) VALUES ";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'Ghasemgolalizade1369@yahoo.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1),";
  query += "288263, '-', '!dp0rGcd' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'hasankarimiyan47@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1),";
  query += "288265, '-', '9Y&amMwi' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'erfanijavad0@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1),";
  query += "288266, '-', '!nlnAn7J' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'dararahmati1366@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1),";
  query += "288267, '-', 'lY&*e284' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'sahar1ndco@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288268, '-', 'p2#qNDLq' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'samaxanmirzayi@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288269, '-', 'ALN1_@6g' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'teolhhiadm@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288270, '-', ']N0yK)$0' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'arashghobadi795@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288272, '-', '8c^pk8Se' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'Alimazuniii@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288273, '-', '%&bR(%9F' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'sadeghi650@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288274, '-', ')d@eCAK7' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'shahramavd@yahoo.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288275, '-', 'V%)JFO4m' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'shahmaribehzad9@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288276, '-', '*322WLi[' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'Amirhosseinrohani77@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288278, '-', 'a(bfX3u*' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'aramrehmeti@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288282, '-', '7KiPbHq)' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'mirshamsi1344@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288283, '-', 'k@V7ru9E' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'naderramezani13@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288284, '-', 'CeUcX)g7' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'hamed.zahra9713@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288286, '-', 'X6qf90(U' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'farshad.kamrava@gmail.com' LIMIT 1), ";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288287, '-', 'M3wX*a[d' ),";
  query += "( (SELECT id From `sgb`.`user` WHERE `user`.email = 'anush.sharifi95@gmail.com' LIMIT 1),";
  query += "(SELECT id From `sgb`.`server` WHERE `server`.`server` = 'UNFXB-REAL' LIMIT 1), ";
  query += "288289, '-', '2n^2#F]r' );";

  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreAccountData(void)
 {
//---
  string query = NULL;
  m_hash_id = Task.HashID();

  query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_ACCOUNT + "` (";

  query += "`id`,";                       // int unsigned NOT NULL,
  query += "`server`,";                   // varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  query += "`login`,";                    // int unsigned NOT NULL,
  query += "`investor_password`,";        // varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  if(Task.Result.ErrorCode() == 0)
   {
    query += "`hash_point_a`,";             // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
    query += "`hash_point_b`,";             // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
    query += "`last_update`,";            // timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    query += "`history_id`,";             // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
   }
  query += "`task`,";                     // int NOT NULL,
  query += "`algorithm`,";                // int NOT NULL,
  query += "`initial_balance`,";          // decimal(15, 2) NOT NULL,
  query += "`daily_drawdown_percent`,";   // decimal(5, 2) NOT NULL,
  query += "`total_drawdown_percent`,";   // decimal(5, 2) NOT NULL,
  query += "`tick_scalp_enable`,";        // tinyint(1) NOT NULL,
  query += "`tick_scalp_term`,";          // int NOT NULL,
  query += "`gambeling_enable`,";         // tinyint(1) NOT NULL,
  query += "`gambeling_percent`,";        // decimal(5, 2) NOT NULL,
  query += "`news_enable`,";              // tinyint(1) NOT NULL,
  query += "`weekend_enable`,";           // tinyint(1) NOT NULL,
  query += "`trail_total`,";              // tinyint(1) NOT NULL,
  query += "`trail_total_type`,";         // int NOT NULL,
  query += "`is_secure`";                 // tinyint(1) NOT NULL,

  query += ") VALUES";

  query += " (";

  query += IntegerFild(Task.AccountId())              + ",";    //"`id`,";                      // int unsigned NOT NULL,
  query += StringFild(Task.Server())                  + ",";    //"`server`,";                  // varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  query += IntegerFild(Task.Login())                  + ",";    //"`login`,";                   // int unsigned NOT NULL,
  query += StringFild(Task.Password())                + ",";    //"`investor_password`,";       // varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  if(Task.Result.ErrorCode() == 0)
   {
    query += StringFild(Task.Result.DealChekPoint())  + ",";    //"`hash_point_a`,";            // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
    query += StringFild(Task.Result.EquityChekPoint()) + ",";   //"`hash_point_b`,";            // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
    query += DateTimeFild(History.EndTime())          + ",";    //"`last_update`,";             // timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    query += StringFild(m_hash_id)                    + ",";    //"`history_id`,";              // varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci DEFAULT NULL,
   }
  query += IntegerFild(Task.Task())                   + ",";    //"`task`,";                    // int NOT NULL,
  query += IntegerFild(1)                             + ",";    //"`algorithm`,";               // int NOT NULL,
  query += DoubleFild(Task.InitBalance(), 2)          + ",";    //"`initial_balance`,";         // decimal(15, 2) NOT NULL,
  query += DoubleFild(Task.DailyRiskPercent(), 2)     + ",";    //"`daily_drawdown_percent`,";  // decimal(5, 2) NOT NULL,
  query += DoubleFild(Task.TotalRiskPercent(), 2)     + ",";    //"`total_drawdown_percent`,";  // decimal(5, 2) NOT NULL,
  query += IntegerFild(Task.UseTickScalp())           + ",";    //"`tick_scalp_enable`,";       // tinyint(1) NOT NULL,
  query += IntegerFild(Task.TickScalpTermMsc())       + ",";    //"`tick_scalp_term`,";         // int NOT NULL,
  query += IntegerFild(Task.UseGambeling())           + ",";    //"`gambeling_enable`,";        // tinyint(1) NOT NULL,
  query += DoubleFild(Task.GambelingPercent(), 2)     + ",";    //"`gambeling_percent`,";       // decimal(5, 2) NOT NULL,
  query += IntegerFild(Task.UseNews())                + ",";    //"`news_enable`,";             // tinyint(1) NOT NULL,
  query += IntegerFild(Task.UseWeekend())             + ",";    //"`weekend_enable`,";          // tinyint(1) NOT NULL,
  query += IntegerFild(Task.UseTrailTotal())          + ",";    //"`trail_total`,";             // tinyint(1) NOT NULL,
  query += IntegerFild(Task.TrailTotal())             + ",";    //"`trail_total_type`,";        // int NOT NULL,
  query += IntegerFild(Task.IsSecure())               + "";     //"`is_secure`";                // tinyint(1) NOT NULL,

  query += ");";

  return TransactionExecute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreDeals(void)
 {
  if(!DEF_SETTING_STOR_DEAL)
    return true;
//---
  string query = NULL;
  bool is_start = true;

  if(Task.IsResetTask())
    query = "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_DEAL + "` WHERE account_id=" + IntegerFild(Task.AccountId()) + ";";

  uint total = History.DealsList.Total();
  for(uint i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);

    if(IS_POINTER_DYNAMIC(Deal) && Deal.Ticket() > 0)
     {
      int digits = (int)::SymbolInfoInteger(Deal.Symbol(), SYMBOL_DIGITS);

      if(is_start || query == NULL)
       {
        query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_DEAL + "` (";

        query += "`account_id`,";      //INT UNSIGNED      NOT NULL,";
        query += "`deal_ticket`,";     //BIGINT UNSIGNED   NOT NULL,";
        query += "`order_ticket`,";    //BIGINT UNSIGNED   NOT NULL,";
        query += "`time`,";            //TIMESTAMP         NOT NULL,";
        query += "`time_rate`,";       //TIMESTAMP         NOT NULL,";
        query += "`time_msc`,";        //BIGINT UNSIGNED   NOT NULL,";
        query += "`type`,";            //TINYINT UNSIGNED  NOT NULL,";
        query += "`entry`,";           //TINYINT UNSIGNED  NOT NULL,";
        query += "`magic`,";           //BIGINT            ZEROFILL NOT NULL,";
        query += "`reason`,";          //TINYINT UNSIGNED  NOT NULL,";
        query += "`position_ticket`,"; //BIGINT UNSIGNED   NOT NULL,";
        query += "`volume`,";          //DOUBLE            NOT NULL,";
        query += "`price`,";           //DOUBLE            NOT NULL,";
        query += "`commission`,";      //DOUBLE            NOT NULL,";
        query += "`swap`,";            //DOUBLE            NOT NULL,";
        query += "`profit`,";          //DOUBLE            NOT NULL,";
        query += "`fee`,";             //DOUBLE            NOT NULL,";
        query += "`stop_loss`,";       //DOUBLE            NOT NULL,";
        query += "`take_profit`,";     //DOUBLE            NOT NULL,";
        query += "`symbol`,";          //VARCHAR ( 255 )   NOT NULL,";
        query += "`comment`,";         //VARCHAR ( 255 )   NULL,";
        query += "`balance`,";         //DOUBLE            NULL,";
        query += "`external_id`";      //VARCHAR ( 255 )   NULL,";

        query += ") VALUES";

        is_start = false;
       }
      else
        query += ",";

      query += " (";

      query += IntegerFild(Task.AccountId())          + ",";   //"`account_id`,";      //INT UNSIGNED      NOT NULL,";
      query += IntegerFild(Deal.Ticket())             + ",";   //"`deal_ticket`,";     //BIGINT UNSIGNED   NOT NULL,";
      query += IntegerFild(Deal.OrderTicket())        + ",";   //"`order_ticket`,";    //BIGINT UNSIGNED   NOT NULL,";
      query += DateTimeFild(Deal.Time())              + ",";   //"`time`,";            //TIMESTAMP         NOT NULL,";
      query += DateTimeFild(Deal.RateTime())          + ",";   //"`time_rate`,";       //TIMESTAMP         NOT NULL,";
      query += IntegerFild(Deal.TimeMsc())            + ",";   //"`time_msc`,";        //BIGINT UNSIGNED   NOT NULL,";
      query += IntegerFild((int)Deal.DealType())      + ",";   //"`type`,";            //TINYINT UNSIGNED  NOT NULL,";
      query += IntegerFild((int)Deal.Entry())         + ",";   //"`entry`,";           //TINYINT UNSIGNED  NOT NULL,";
      query += IntegerFild(Deal.Magic())              + ",";   //"`magic`,";           //BIGINT            ZEROFILL NOT NULL,";
      query += IntegerFild((int)Deal.Reason())        + ",";   //"`reason`,";          //TINYINT UNSIGNED  NOT NULL,";
      query += IntegerFild(Deal.PositionId())         + ",";   //"`position_ticket`,"; //BIGINT UNSIGNED   NOT NULL,";
      query += DoubleFild(Deal.Volume(), 2)           + ",";   //"`volume`,";          //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Price(), digits)       + ",";   //"`price`,";           //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Commission(), digits)  + ",";   //"`commission`,";      //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Swap(), 2)             + ",";   //"`swap`,";            //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Profit(), 2)           + ",";   //"`profit`,";          //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Fee(), 2)              + ",";   //"`fee`,";             //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Sl(), digits)          + ",";   //"`stop_loss`,";       //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.Tp(), digits)          + ",";   //"`take_profit`,";     //DOUBLE            NOT NULL,";
      query += StringFild(Deal.Symbol())              + ",";   //"`symbol`,";          //VARCHAR ( 255 )   NOT NULL,";
      query += StringFild(Deal.Comment())             + ",";   //"`comment`,";         //VARCHAR ( 255 )   NULL,";
      query += DoubleFild(Deal.Balance(), 2)          + ",";   //"`balance`,";         //DOUBLE            NULL,";
      query += StringFild(Deal.ExtId())               + "";    //"`external_id`,";     //VARCHAR ( 255 )   NULL,";

      query += ") ";
     }
    if(i != 0 && i % 200 == 0)
     {
      if(query != NULL)
       {
        query += ";";
        if(!TransactionExecute(query))
          return false;
       }
      query = NULL;
     }
   }
//---
  if(query != NULL)
   {
    query += ";";
    return TransactionExecute(query);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StorePositions(void)
 {
  if(!DEF_SETTING_STOR_POSITION)
    return true;
//---
  string query = NULL;
  bool is_start = true;

  if(Task.IsResetTask())
    query = "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_POSITION + "` WHERE `account_id`=" + IntegerFild(Task.AccountId()) + ";";

  uint total = History.PositionList.Total();
  for(uint i = 0; i < total; i++)
   {
    CPosition *Position = History.PositionList.At(i);

    if(IS_POINTER_DYNAMIC(Position) && Position.PositionId() > 0 && Position.OpenTicket() > 0 && (Position.CloseTicket() > 0 || Position.IsOpenPosition()))
     {
      int digits = Position.Digits();

      if(is_start || query == NULL)
       {
        if(i == 0)
          query += "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_POSITION + "` WHERE `status`=1 AND `account_id`=" + IntegerFild(Task.AccountId()) + ";";

        query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_POSITION + "` (";

        query += "`account_id`,";         //INT UNSIGNED      NOT NULL,";
        query += "`open_deal_ticket`,";   //BIGINT UNSIGNED   NOT NULL,";
        query += "`open_time`,";          //TIMESTAMP         NOT NULL,";
        query += "`open_time_rate`,";     //TIMESTAMP         NOT NULL,";
        query += "`open_time_msc`,";      //BIGINT            NOT NULL,";
        query += "`open_price`,";         //DOUBLE            NOT NULL,";
        query += "`open_stop_loss`,";     //DOUBLE            NULL,";
        query += "`open_take_profit`,";   //DOUBLE            NULL,";
        query += "`open_commission`,";    //DOUBLE            NOT NULL,";
        query += "`open_swap`,";          //DOUBLE            NOT NULL,";
        query += "`open_fee`,";           //DOUBLE            NOT NULL,";
        query += "`close_deal_ticket`,";  //BIGINT UNSIGNED   NOT NULL,";
        query += "`close_time`,";         //TIMESTAMP         NOT NULL,";
        query += "`close_time_rate`,";    //TIMESTAMP         NOT NULL,";
        query += "`close_time_msc`,";     //BIGINT            NOT NULL,";
        query += "`close_price`,";        //DOUBLE            NOT NULL,";
        query += "`close_stop_loss`,";    //DOUBLE            NULL,";
        query += "`close_take_profit`,";  //DOUBLE            NULL,";
        query += "`close_commission`,";   //DOUBLE            NOT NULL,";
        query += "`close_swap`,";         //DOUBLE            NOT NULL,";
        query += "`close_fee`,";          //DOUBLE            NOT NULL,";
        query += "`cost`,";               //DOUBLE            NOT NULL,";
        query += "`profit`,";             //DOUBLE            NOT NULL,";
        query += "`net_profit`,";         //DOUBLE            NOT NULL,";
        query += "`duratian_msc`,";       //BIGINT UNSIGNED   NOT NULL,";
        query += "`type`,";               //TINYINT           NOT NULL,";
        query += "`volume`,";             //DOUBLE            NOT NULL,";
        query += "`symbol`,";             //VARCHAR ( 255 )   NOT NULL,";
        query += "`position_ticket`,";    //BIGINT UNSIGNED   NOT NULL,";
        query += "`is_tick_scalp`,";      // TINYINT(1)       NOT NULL DEFAULT 0,
        query += "`is_weekend`,";         // TINYINT(1)       NOT NULL DEFAULT 0,
        query += "`is_news_trading`,";    // TINYINT(1)       NOT NULL DEFAULT 0,
        query += "`news`,";               // VARCHAR(255)     NULL,
        query += "`status`";              //TINYINT ( 1 )     NOT NULL DEFAULT 0,";

        query += ") VALUES";
        is_start = false;
       }
      else
        query += ",";

      query += " (";

      query += IntegerFild(Task.AccountId()) + ",";             //"`account_id`,";         //INT UNSIGNED      NOT NULL,";
      query += IntegerFild(Position.OpenTicket()) + ",";        //"`open_deal_ticket`,";   //BIGINT UNSIGNED   NOT NULL,";
      query += DateTimeFild(Position.OpenTime()) + ",";         //"`open_time`,";          //TIMESTAMP         NOT NULL,";
      query += DateTimeFild(Position.OpenRateTime()) + ",";     //"`open_time_rate`,";     //TIMESTAMP         NOT NULL,";
      query += IntegerFild(Position.OpenTimeMsc()) + ",";       //"`open_time_msc`,";      //BIGINT            NOT NULL,";
      query += DoubleFild(Position.OpenPrice(), digits) + ",";  //"`open_price`,";         //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.OpenSl(), digits) + ",";     //query += "`open_stop_loss`,";     //DOUBLE            NULL,";
      query += DoubleFild(Position.OpenTp(), digits) + ",";     //query += "`open_take_profit`,";   //DOUBLE            NULL,";
      query += DoubleFild(Position.OpenCommission(), 2) + ",";  //"`open_commission`,";    //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.OpenSwap(), 2) + ",";        //"`open_swap`,";          //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.OpenFee(), 2) + ",";         //"`open_fee`,";           //DOUBLE            NOT NULL,";
      query += IntegerFild(Position.CloseTicket()) + ",";       //"`close_deal_ticket`,";  //BIGINT UNSIGNED   NOT NULL,";
      query += DateTimeFild(Position.CloseTime()) + ",";        //"`close_time`,";         //TIMESTAMP         NOT NULL,";
      query += DateTimeFild(Position.CloseRateTime()) + ",";    //"`close_time_rate`,";    //TIMESTAMP         NOT NULL,";
      query += IntegerFild(Position.CloseTimeMsc()) + ",";      //"`close_time_msc`,";     //BIGINT            NOT NULL,";
      query += DoubleFild(Position.ClosePrice(), digits) + ","; //"`close_price`,";        //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.CloseSl(), digits) + ",";    //query += "`open_stop_loss`,";     //DOUBLE            NULL,";
      query += DoubleFild(Position.CloseTp(), digits) + ",";    //query += "`open_take_profit`,";   //DOUBLE            NULL,";
      query += DoubleFild(Position.CloseCommission(), 2) + ","; //"`close_commission`,";   //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.CloseSwap(), 2) + ",";       //"`close_swap`,";         //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.CloseFee(), 2) + ",";        //"`close_fee`,";          //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.TotalCost(), 2) + ",";       //"`cost`,";               //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.Profit(), 2) + ",";          //"`profit`,";             //DOUBLE            NOT NULL,";
      query += DoubleFild(Position.NetProfit(), 2) + ",";       //"`net_profit`,";         //DOUBLE            NOT NULL,";
      query += IntegerFild(Position.TradeDuratianMsc()) + ",";  //"`duratian_msc`,";       //BIGINT UNSIGNED   NOT NULL,";
      query += IntegerFild(Position.PositionType()) + ",";      //"`type`,";               //TINYINT           NOT NULL,";
      query += DoubleFild(Position.Volume(), 2) + ",";          //"`volume`,";             //DOUBLE            NOT NULL,";
      query += StringFild(Position.Symbol()) + ",";             //"`symbol`,";             //VARCHAR ( 255 )   NOT NULL,";
      query += IntegerFild(Position.PositionId()) + ",";        //"`position_ticket`,";    //BIGINT UNSIGNED   NOT NULL,";
      query += IntegerFild(Position.IsTickScalp()) + ",";       //"`is_tick_scalp`,";      // TINYINT(1)        NOT NULL DEFAULT 0,
      query += IntegerFild(Position.IsWeekend()) + ",";         //`is_weekend`,";          // TINYINT(1)        NOT NULL DEFAULT 0,
      query += IntegerFild(Position.IsNewsTrading()) + ",";     //"`is_news_trading`,";    // TINYINT(1)        NOT NULL DEFAULT 0,
      query += StringFild(Position.News()) + ",";               //"`news`,";               // VARCHAR(255)      NULL,
      query += IntegerFild(Position.IsOpenPosition()) + "";     //"`status`";              //TINYINT ( 1 )     NOT NULL DEFAULT 0,";

      query += ")";
     }
    if(i != 0 && i % 200 == 0)
     {
      if(query != NULL)
       {
        query += ";";
        if(!TransactionExecute(query))
          return false;
       }
      query = NULL;
     }
   }
//---
  if(query != NULL)
   {
    query += ";";
    return TransactionExecute(query);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreBalance(void)
 {
  if(!DEF_SETTING_STOR_BALANCE)
    return true;
//---
  string query = NULL;
  bool is_start = true;

  if(Task.IsResetTask())
    query = "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_BALANCE + "` WHERE account_id=" + IntegerFild(Task.AccountId()) + ";";

  uint total = History.DealsList.Total();
  for(uint i = 0; i < total; i++)
   {
    CDeal *Deal = History.DealsList.At(i);

    if(IS_POINTER_DYNAMIC(Deal) && Deal.Ticket() > 0)
     {
      if(is_start || query == NULL)
       {
        query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_BALANCE + "` (";

        query += "`deal_ticket`,";       //BIGINT UNSIGNED   NOT NULL,";
        query += "`account_id`,";        //INT UNSIGNED      NOT NULL,";
        query += "`time_msc`,";          //BIGINT UNSIGNED   NOT NULL,";
        query += "`balance`,";           //DOUBLE            NOT NULL,";
        query += "`last_day_balance`,";  //DOUBLE            NOT NULL,";
        query += "`daily_limit`,";       //DOUBLE            NOT NULL,";
        query += "`total_limit`";        //DOUBLE            NOT NULL,";

        query += ") VALUES";
        is_start = false;
       }
      else
        query += ",";

      query += " (";

      query += IntegerFild(Deal.Ticket())             + ",";   //"`deal_ticket`,";     //BIGINT UNSIGNED   NOT NULL,";
      query += IntegerFild(Task.AccountId())          + ",";   //"`account_id`,";        //INT UNSIGNED      NOT NULL,";
      query += IntegerFild(Deal.TimeMsc())            + ",";   //BIGINT UNSIGNED   NOT NULL,";
      query += DoubleFild(Deal.Balance(), 2)          + ",";   //"`balance`";            //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.LastDayBalance(), 2)   + ",";   //"`last_day_balance`,";  //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.DailyLimit(), 2)       + ",";   //"`daily_limit`,";       //DOUBLE            NOT NULL,";
      query += DoubleFild(Deal.TotalLimit(), 2)       + "";    //"`total_limit`,";       //DOUBLE            NOT NULL,";

      query += ")";
     }
    if(i != 0 && i % 500 == 0)
     {
      if(query != NULL)
       {
        query += ";";
        if(!TransactionExecute(query))
          return false;
       }
      query = NULL;
     }
   }
//---
  if(query != NULL)
   {
    query += ";";
    return TransactionExecute(query);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreEquity(void)
 {
  string query = NULL;
  bool is_start = true;

  if(Task.IsResetTask())
    query = "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_EQUITY + "` WHERE account_id=" + IntegerFild(Task.AccountId()) + ";";

  uint total = Series.Total();
  for(uint i = 0; i < total; i++)
   {
    if(is_start || query == NULL)
     {
      query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_EQUITY + "` (";

      query += "`account_id`,";    //INT UNSIGNED      NOT NULL,";
      query += "`time_msc`,";      //BIGINT            NOT NULL,
      query += "`time`,";          //TIMESTAMP         NOT NULL,";
      query += "`balance`,";       // DOUBLE           NULL,
      query += "`high_equity`,";   //DOUBLE            NULL,";
      query += "`low_equity`,";    //DOUBLE            NULL,";
      if(DEF_SETTING_STOR_EQUITY == STOR_EQUITY_FULL)
       {
        query += "`open_equity`,";   //DOUBLE            NULL,";
        query += "`close_equity`,";  //DOUBLE            NULL,";
       }
      query += "`daily_limit`,";   //DOUBLE            NULL,";
      query += "`total_limit`,";   //DOUBLE            NULL,";
      query += "`is_balance_gambeling`,";    // TINYINT ( 1 ) NOT NULL DEFAULT 0,
      query += "`is_equity_gambeling`";      // TINYINT ( 1 ) NOT NULL DEFAULT 0,

      query += ") VALUES";
      is_start = false;
     }
    else
      query += ",";

    query += " (";

    query += IntegerFild(Task.AccountId())               + ",";   //"`account_id`,";    //INT UNSIGNED      NOT NULL,";
    query += IntegerFild(Series.m_time_msc[i])           + ",";   //"`time_msc`,";      //BIGINT            NOT NULL,
    query += DateTimeFild(Series.m_time[i])              + ",";   //"`time`,";          //TIMESTAMP         NOT NULL,";
    query += DoubleFild(Series.m_balance[i], 2)          + ",";   //"`balance`,";       //DOUBLE            NULL,";
    query += DoubleFild(Series.m_equity_high[i], 2)      + ",";   //"`high_equity`,";   //DOUBLE            NULL,";
    query += DoubleFild(Series.m_equity_low[i], 2)       + ",";   //"`low_equity`,";    //DOUBLE            NULL,";
    if(DEF_SETTING_STOR_EQUITY == STOR_EQUITY_FULL)
     {
      query += DoubleFild(Series.m_equity_open[i], 2)      + ",";   //"`open_equity`,";   //DOUBLE            NULL,";
      query += DoubleFild(Series.m_equity_close[i], 2)     + ",";   //"`close_equity`";   //DOUBLE            NULL,";
     }
    query += DoubleFild(Series.m_day_limit[i], 2)        + ",";   //"`daily_limit`,";   //DOUBLE            NULL,";
    query += DoubleFild(Series.m_total_limit[i], 2)      + ",";   //"`total_limit`";    //DOUBLE            NULL,";
    query += IntegerFild(Series.m_balance_gambeling[i])  + ",";   //"`is_balance_gambeling`,";    // TINYINT ( 1 ) NOT NULL DEFAULT 0,
    query += IntegerFild(Series.m_equity_gambeling[i])   + "";    //"`is_equity_gambeling`";      // TINYINT ( 1 ) NOT NULL DEFAULT 0,

    query += ")";


    if(i != 0 && i % 300 == 0)
     {
      if(query != NULL)
       {
        query += ";";
        if(!TransactionExecute(query))
          return false;
       }
      query = NULL;
     }
   }
//---
  if(query != NULL)
   {
    query += ";";
    return TransactionExecute(query);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreStatement(void)
 {
  if(!DEF_SETTING_STOR_STATEMENT)
    return true;
//---
  string query = NULL;

  query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_STATEMENT + "` (";

  query += "`id`,";                             //VARCHAR ( 255 )   NOT NULL,
  query += "`total_net_profit`,";               //DOUBLE         NULL,";
  query += "`gross_profit`,";                   //DOUBLE         NULL,";
  query += "`gross_loss`,";                     //DOUBLE         NULL,";
  query += "`profit_factor`,";                  //DOUBLE         NULL,";
  query += "`recovery_factor`,";                //DOUBLE         NULL,";
  query += "`expected_payoff`,";                //DOUBLE         NULL,";
  query += "`sharpe_ratio`,";                   //DOUBLE         NULL,";
  query += "`ahpr`,";                           //DOUBLE         NULL,";
  query += "`ahpr_percent`,";                   //DOUBLE         NULL,";
  query += "`ghpr`,";                           //DOUBLE         NULL,";
  query += "`ghpr_percent`,";                   //DOUBLE         NULL,";
  query += "`z_score`,";                        //DOUBLE         NULL,";
  query += "`z_score_percent`,";                //DOUBLE         NULL,";
  query += "`lr_correlation`,";                 //DOUBLE         NULL,";
  query += "`lr_standard_error`,";              //DOUBLE         NULL,";
  query += "`total_deals`,";                    //INT            NULL,";
  query += "`total_trades`,";                   //INT            NULL,";
  query += "`total_profit_trades`,";            //INT            NULL,";
  query += "`total_loss_trades`,";              //INT            NULL,";
  query += "`total_win_rate`,";                 //DOUBLE         NULL,";
  query += "`total_loss_rate`,";                //DOUBLE         NULL,";
  query += "`total_average_profit_trade`,";     //DOUBLE         NULL,";
  query += "`total_average_loss_trade`,";       //DOUBLE         NULL,";
  query += "`long_trades`,";                    //INT            NULL,";
  query += "`long_profit_trades`,";             //INT            NULL,";
  query += "`long_loss_trades`,";               //INT            NULL,";
  query += "`long_win_rate`,";                  //DOUBLE         NULL,";
  query += "`long_loss_rate`,";                 //DOUBLE         NULL,";
  query += "`short_trades`,";                   //INT            NULL,";
  query += "`short_profit_trades`,";            //INT            NULL,";
  query += "`short_loss_trades`,";              //INT            NULL,";
  query += "`short_win_rate`,";                 //DOUBLE         NULL,";
  query += "`short_loss_rate`,";                //DOUBLE         NULL,";
  query += "`largest_profit_trade`,";           //DOUBLE         NULL,";
  query += "`largest_loss_trade`,";             //DOUBLE         NULL,";
  query += "`ave_profit_trade`,";               //DOUBLE         NULL,";
  query += "`ave_loss_trade`,";                 //DOUBLE         NULL,";
  query += "`max_consecutive_wins`,";           //DOUBLE         NULL,";
  query += "`max_consecutive_losses`,";         //DOUBLE         NULL,";
  query += "`ave_consecutive_wins_trades`,";    //INT            NULL,";
  query += "`ave_consecutive_losses_trades`";   //INT            NULL,";

  query += ") VALUES (";

  query += IntegerFild(Task.AccountId()) + ",";   //"`account_id`,";        //INT UNSIGNED      NOT NULL,";
  query += DoubleFild(Statement.Profit()) + ",";
  query += DoubleFild(Statement.GrossProfit()) + ",";
  query += DoubleFild(Statement.GrossLoss()) + ",";
  query += DoubleFild(Statement.ProfitFactor()) + ",";
  query += DoubleFild(Statement.RecoveryFactor()) + ",";
  query += DoubleFild(Statement.ExpectedPayoff()) + ",";
  query += DoubleFild(Statement.SharpeRatio()) + ",";
  query += DoubleFild(Statement.AHPR()) + ",";
  query += DoubleFild(Statement.AHPRPercent()) + ",";
  query += DoubleFild(Statement.GHPR()) + ",";
  query += DoubleFild(Statement.GHPRPercent()) + ",";
  query += DoubleFild(Statement.ZScore()) + ",";
  query += DoubleFild(Statement.ZScorePercent()) + ",";
  query += DoubleFild(Statement.LRCorrelation()) + ",";
  query += DoubleFild(Statement.LRStandardError()) + ",";
  query += IntegerFild(Statement.Deals()) + ",";
  query += IntegerFild(Statement.Trades()) + ",";
  query += IntegerFild(Statement.ProfitTrades()) + ",";
  query += IntegerFild(Statement.LossTrades()) + ",";
  query += DoubleFild(Statement.Percent(Statement.ProfitTrades(), Statement.Trades())) + ",";
  query += DoubleFild(Statement.Percent(Statement.LossTrades(), Statement.Trades())) + ",";
  query += DoubleFild(Statement.Divide(Statement.GrossProfit(), Statement.ProfitTrades())) + ",";
  query += DoubleFild(Statement.Divide(Statement.GrossLoss(), Statement.LossTrades())) + ",";
  query += IntegerFild(Statement.LongTrades()) + ",";
  query += IntegerFild(Statement.ProfitLongTrades()) + ",";
  query += IntegerFild(Statement.LongTrades() - Statement.ProfitLongTrades()) + ",";
  query += DoubleFild(Statement.Percent(Statement.ProfitLongTrades(), Statement.LongTrades())) + ",";
  query += DoubleFild(Statement.Percent(Statement.LongTrades() - Statement.ProfitLongTrades(), Statement.LongTrades())) + ",";
  query += IntegerFild(Statement.ShortTrades()) + ",";
  query += IntegerFild(Statement.ProfitShortTrades()) + ",";
  query += IntegerFild(Statement.ShortTrades() - Statement.ProfitShortTrades()) + ",";
  query += DoubleFild(Statement.Percent(Statement.ProfitShortTrades(), Statement.ShortTrades())) + ",";
  query += DoubleFild(Statement.Percent(Statement.ShortTrades() - Statement.ProfitShortTrades(), Statement.ShortTrades())) + ",";
  query += DoubleFild(Statement.LargestProfitTrade()) + ",";
  query += DoubleFild(Statement.LargestLossTrade()) + ",";
  query += DoubleFild(Statement.Divide(Statement.GrossProfit(), Statement.ProfitTrades())) + ",";
  query += DoubleFild(Statement.Divide(Statement.GrossLoss(), Statement.LossTrades())) + ",";
  query += DoubleFild(Statement.MaxConWins()) + ",";
  query += DoubleFild(Statement.MaxConLosses()) + ",";
  query += IntegerFild(Statement.ProfitTradesAvgCon()) + ",";
  query += IntegerFild(Statement.LossTradesAvgCon()) + "";

  query += "); ";
//---
  return  TransactionExecute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CDatabase::StoreDrawdown(void)
 {
  string query = NULL;
  bool is_start = true;

  if(Task.IsResetTask())
    query = "DELETE FROM `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_DRAWDOWN + "` WHERE account_id=" + IntegerFild(Task.AccountId()) + ";";

  uint total = Equity.DrawDownList.Total();
  for(uint i = 0; i < total; i++)
   {
    CDrawDown *DD = Equity.DrawDownList.At(i);

    if(!IS_POINTER_DYNAMIC(DD))
      continue;

    if(is_start || query == NULL)
     {
      query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_DRAWDOWN + "` (";

      query += "`account_id`,";    //INT UNSIGNED      NOT NULL,";
      query += "`source,";
      query += "`type,";
      query += "`time,";
      query += "`time_msc,";
      query += "`limit,";
      query += "`value";

      query += ") VALUES";
      is_start = false;
     }
    else
      query += ",";

    query += " (";

    query += IntegerFild(Task.AccountId())               + ",";   //"`account_id`,";    //INT UNSIGNED      NOT NULL,";
    query += StringFild(DD.source)                       + ",";
    query += StringFild(DD.type)                         + ",";
    query += DateTimeFild(DD.time)                       + ",";
    query += IntegerFild(DD.time_msc)                    + ",";
    query += DoubleFild(DD.limit)                        + ",";
    query += DoubleFild(DD.value)                        + "";

    query += ")";


    if(i != 0 && i % 300 == 0)
     {
      if(query != NULL)
       {
        query += ";";
        if(!TransactionExecute(query))
          return false;
       }
      query = NULL;
     }
   }
//---
  if(query != NULL)
   {
    query += ";";
    return TransactionExecute(query);
   }
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CDatabase::StoreObjective(void)
 {
  if(!DEF_SETTING_STOR_OBJECTIVE)
    return true;
//---
  string query = "CALL UpdateObjective(" + IntegerFild(Task.AccountId()) + ");";
//---
  return  TransactionExecute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool  CDatabase::StoreCheckPoints(void)
 {
  string query = NULL;
  query += "UPDATE `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_ACCOUNT + "` SET ";
  query += "`hash_point_a` = " + StringFild(Task.Result.DealChekPoint()) + ", ";
  query += "`hash_point_b` = " + StringFild(Task.Result.EquityChekPoint()) + " ";
  query += "WHERE `id` = " + IntegerFild(Task.AccountId()) + ";";
//---
  return  TransactionExecute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StoreNodeLastUpdate(const string _hash_id, const bool _is_trans = false)
 {
  string query = NULL;
  query += "UPDATE `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_ACCOUNT + "` SET ";
  query += "`node_last_update`= " + DateTimeFild(History.EndTime()) + ", ";
  query += "`node_history_id`=" + StringFild(_hash_id) + " ";
  query += "WHERE `id` = " + (string)Task.AccountId() + ";";
//---
  if(_is_trans)
    return TransactionExecute(query);
  return Execute(query);
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDatabase::StorHistory(CTask *_Task, const bool _is_trans = false)
 {
  if(!IS_POINTER_DYNAMIC(_Task))
    return false;
//---
  string query = NULL;
  if(!_is_trans)
     m_hash_id = _Task.HashID();


  query += "REPLACE INTO `" + DEF_DB_DB_Name + "`.`" + DEF_DB_TBL_NODE_HISTORY + "` (";

  query += "`id`,";                             //varchar 255
  query += "`server_time`,";                    //timestamp
  query += "`app_name`,";                       //varchar 255
  query += "`identification`,";                 //varchar 255
  query += "`task`,";                           //varchar 50
  query += "`accountId`,";                      //int
  query += "`login`,";                          //int
  query += "`investor_password`,";              //varchar 255
  query += "`server`,";                         //varchar 255
  query += "`hash_point_a`,";                   //varchar 255
  query += "`hash_point_b`,";                   //varchar 255
  query += "`initial_balance`,";                //double
  query += "`target_percent`,";                 //double
  query += "`daily_risk_percent`,";             //double
  query += "`total_risk_percent`,";             //double
  query += "`is_check_tick_scalp`,";            //tinyint 1
  query += "`tick_scalp_term_msc`,";            //bigint
  query += "`is_check_gambeling`,";             //tinyint 1
  query += "`gambeling_percent`,";              //double
  query += "`is_check_news`,";                  //tinyint 1
  query += "`is_check_Weekend`,";               //tinyint 1
  query += "`is_trail_total`,";                 //tinyint 1
  query += "`trail_total_type`,";               //tinyint 1
  query += "`is_secure`,";                      //tinyint 1
  query += "`result_status`,";                  //varchar 255
  query += "`login_term_msc`,";                 //bigint
  query += "`db_connection_term_msc`,";         //bigint
  query += "`update_history_term_msc`,";        //bigint
  query += "`load_data_term_msc`,";             //bigint
  query += "`create_series_term_msc`,";         //bigint
  query += "`update_equity_term_msc`,";         //bigint
  query += "`update_report_term_msc`,";         //bigint
  query += "`update_statement_term_msc`,";      //bigint
  query += "`store_data_term_msc`,";            //bigint
  query += "`full_term_msc`,";                  //bigint
  query += "`error_code`,";                     //int
  query += "`error_description`,";              //varchar 255
  query += "`new_hash_point_a`,";               //varchar 255
  query += "`new_hash_point_b`";                //varchar 255


  query += ") VALUES (";

  query += StringFild(m_hash_id) + ",";                                //varchar 255
  query += DateTimeFild(_Task.ServerTime()) + ",";                    //timestamp
  query += StringFild(_Task.AppName()) + ",";                         //varchar 255
  query += StringFild(_Task.Identification()) + ",";                  //varchar 255
  query += StringFild(_Task.TaskSting()) + ",";                       //varchar 50
  query += IntegerFild(_Task.AccountId()) + ",";                      //int
  query += IntegerFild(_Task.Login()) + ",";                          //int
  query += StringFild(_Task.RawPassword()) + ",";                     //varchar 255
  query += StringFild(_Task.Server()) + ",";                          //varchar 255
  query += StringFild(_Task.HashPointA()) + ",";                      //varchar 255
  query += StringFild(_Task.HashPointB()) + ",";                      //varchar 255
  query += DoubleFild(_Task.InitBalance(), 2) + ",";                  //double
  query += DoubleFild(_Task.TargetPercent()) + ",";                   //double
  query += DoubleFild(_Task.DailyRiskPercent()) + ",";                //double
  query += DoubleFild(_Task.TotalRiskPercent()) + ",";                //double
  query += IntegerFild((int)_Task.UseTickScalp()) + ",";              //tinyint 1
  query += IntegerFild(_Task.TickScalpTermMsc()) + ",";               //bigint
  query += IntegerFild((int)_Task.UseGambeling()) + ",";              //tinyint 1
  query += DoubleFild(_Task.GambelingPercent()) + ",";                //double
  query += IntegerFild((int)_Task.UseNews()) + ",";                   //tinyint 1
  query += IntegerFild((int)_Task.UseWeekend()) + ",";                //tinyint 1
  query += IntegerFild((int)_Task.UseTrailTotal()) + ",";             //tinyint 1
  query += IntegerFild(_Task.TrailTotal()) + ",";                     //tinyint 1
  query += IntegerFild((int)_Task.IsSecure()) + ",";                  //tinyint 1
  query += StringFild(_Task.Result.Status()) + ",";                   //varchar 255
  query += IntegerFild(_Task.Result.LoadDataTermMsc()) + ",";         //bigint
  query += IntegerFild(_Task.Result.DbConnectionTermMsc()) + ",";     //bigint
  query += IntegerFild(_Task.Result.UpdateHistoryTermMsc()) + ",";    //bigint
  query += IntegerFild(_Task.Result.LoadDataTermMsc()) + ",";         //bigint
  query += IntegerFild(_Task.Result.CreateSeriesTermMsc()) + ",";     //bigint
  query += IntegerFild(_Task.Result.UpdateEquityTermMsc()) + ",";     //bigint
  query += IntegerFild(_Task.Result.UpdateReportTermMsc()) + ",";     //bigint
  query += IntegerFild(_Task.Result.UpdateStatementTermMsc()) + ",";  //bigint
  query += IntegerFild(_Task.Result.StoreDataTermMsc()) + ",";        //bigint
  query += IntegerFild(_Task.Result.FullTermMsc()) + ",";             //bigint
  query += IntegerFild(_Task.Result.ErrorCode()) + ",";               //int
  query += StringFild(_Task.Result.ErrorDescription()) + ",";         //varchar 255
  query += StringFild(_Task.Result.HashPointA()) + ",";               //varchar 255
  query += StringFild(_Task.Result.HashPointB()) + "";                //varchar 255

  query += ");";

  if(_is_trans)
   {
    if(!TransactionExecute(query))
      return false;
   }
  else
    if(!Execute(query))
      return false;

  //if(_Task.Result.ErrorCode() == 0)
  //  return StoreNodeLastUpdate(hash_id, _is_trans);
//---
  return true;
 }
//+------------------------------------------------------------------+
