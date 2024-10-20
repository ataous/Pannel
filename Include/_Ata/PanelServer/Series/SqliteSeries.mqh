//+------------------------------------------------------------------+
//|                                                 SqliteSeries.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#include <Object.mqh>
#include <Arrays\ArrayString.mqh>
#include <_Ata\Databases\SqliteDatabase.mqh>
#include <_Ata\General\Macros.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSqliteSeries : public CObject
 {
private:
  CSqlite            m_db;
  string             m_db_name,
                     m_db_path,
                     m_file_name,
                     m_table_name;
  uint               m_flags;
public:
                     CSqliteSeries();
                    ~CSqliteSeries();
  bool               Init(void);
  bool               AddArray(const ulong &_series[]);
  bool               AddString(const string _values);
  bool               Add(const ulong _time_msc);
  bool               GetSeries(ulong &_series[]);
 };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSqliteSeries::CSqliteSeries()
 {
  m_db_name = "SeriesCash.sqlite";
  m_db_path = "SeriesCash\\";
  m_file_name = m_db_path + m_db_name;
  m_flags = DATABASE_OPEN_READWRITE | DATABASE_OPEN_CREATE;
  m_table_name = "TblSeries";
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSqliteSeries::~CSqliteSeries()
 {
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSqliteSeries::Init(void)
 {
  if(!m_db.Open(m_file_name, m_flags))
    return false;

//--- create a table
  string params[] = {"series UNSIGNED BIG INT NOT NULL"};

  if(!m_db.CreateTable(m_table_name, params))
    return false;

  if(!m_db.SelectTable(m_table_name))
    return false;

  if(!m_db.EmptyTable())
    return false;

  m_db.FinalizeSqlRequest();
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSqliteSeries::AddArray(const ulong &_series[])
 {
  if(!m_db.TransactionBegin())
    return false;
//---
  CArrayString rows_str_arr;
  for(uint i = 0; i < _series.Size(); i++)
   {
    if(!rows_str_arr.Add(::StringFormat("%I64u", _series[i])))
      return false;
   }
//---
  string col_names[] = {"series"};
  if(!m_db.InsertMultipleRows(col_names, rows_str_arr))
   {
    m_db.TransactionRollback();
    return false;
   }
  m_db.FinalizeSqlRequest();
//---
  if(!m_db.TransactionCommit())
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSqliteSeries::AddString(const string _values)
 {
  if(!m_db.TransactionBegin())
    return false;
//---
  string sql_request =::StringFormat("INSERT INTO %s( series ) VALUES %s", m_table_name, _values);

  sql_request =::StringSubstr(sql_request, 0, ::StringLen(sql_request) - 1); // delete the last comma
  sql_request += ";";

  if(!m_db.Select(sql_request))
   {
    m_db.TransactionRollback();
    return false;
   }
  m_db.FinalizeSqlRequest();
//---
  if(!m_db.TransactionCommit())
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSqliteSeries::Add(const ulong _time_msc)
 {
  if(!m_db.TransactionBegin())
    return false;
//---
  string col_names[] = {"series"};
  string col_value[1];
  col_value[0] = ::StringFormat("%I64u", _time_msc);

  if(!m_db.InsertSingleRow(col_names, col_value))
    return false;
  m_db.FinalizeSqlRequest();
//---
  if(!m_db.TransactionCommit())
    return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CSqliteSeries::GetSeries(ulong &_series[])
 {
  string col_names[] = {"series"};

  if(!m_db.SelectDistinctFromOrderedBy(col_names, col_names))
    return false;

  for(int i = 0; m_db.SqlRequestRead(); i++)
    if(!CFunc::AddToArray(m_db.ColumnLong(0), _series))
      return false;
//---
  return true;
 }
//+------------------------------------------------------------------+
