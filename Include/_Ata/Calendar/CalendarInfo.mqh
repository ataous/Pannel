//+------------------------------------------------------------------+
//|                                                 CalendarInfo.mqh |
//|                                           Copyright 2021, denkir |
//|                             https://www.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, denkir"
#property link      "https://www.mql5.com/ru/users/denkir"
//---
#include <Object.mqh>
#include <Generic\SortedSet.mqh>
#include <Arrays\ArrayString.mqh>
#include <Math\Stat\Math.mqh>
#include "Continents.mqh"
//--- defines for events filtering
//--- 1) type (3)
#define FILTER_BY_TYPE_EVENT           0x1              // 1 by type "event"
#define FILTER_BY_TYPE_INDICATOR       0x2              // 2 by type "indicator"
#define FILTER_BY_TYPE_HOLIDAY         0x4              // 3 by type "holiday"
//--- 2) sector (13)
#define FILTER_BY_SECTOR_NONE          0x8              // 4 by sector "none"
#define FILTER_BY_SECTOR_MARKET        0x10             // 5 by sector "market"
#define FILTER_BY_SECTOR_GDP           0x20             // 6 by sector "GDP"
#define FILTER_BY_SECTOR_JOBS          0x40             // 7 by sector "jobs"
#define FILTER_BY_SECTOR_PRICES        0x80             // 8 by sector "prices"
#define FILTER_BY_SECTOR_MONEY         0x100            // 9 by sector "money"
#define FILTER_BY_SECTOR_TRADE         0x200            // 10 by sector "trade"
#define FILTER_BY_SECTOR_GOVERNMENT    0x400            // 11 by sector "government"
#define FILTER_BY_SECTOR_BUSINESS      0x800            // 12 by sector "business"
#define FILTER_BY_SECTOR_CONSUMER      0x1000           // 13 by sector "consumer"
#define FILTER_BY_SECTOR_HOUSING       0x2000           // 14 by sector "housing"
#define FILTER_BY_SECTOR_TAXES         0x4000           // 15 by sector "taxes"
#define FILTER_BY_SECTOR_HOLIDAYS      0x8000           // 16 by sector "holidays"
//--- 3) frequency (6)
#define FILTER_BY_FREQUENCY_NONE       0x10000          // 17 by frequency "none"
#define FILTER_BY_FREQUENCY_WEEK       0x20000          // 18 by frequency "week"
#define FILTER_BY_FREQUENCY_MONTH      0x40000          // 19 by frequency "month"
#define FILTER_BY_FREQUENCY_QUARTER    0x80000          // 20 by frequency "quarter"
#define FILTER_BY_FREQUENCY_YEAR       0x100000         // 21 by frequency "year"
#define FILTER_BY_FREQUENCY_DAY        0x200000         // 22 by frequency "day"
//--- 4) importance (4)
#define FILTER_BY_IMPORTANCE_NONE      0x400000         // 23 by importance "none"
#define FILTER_BY_IMPORTANCE_LOW       0x800000         // 24 by importance "low"
#define FILTER_BY_IMPORTANCE_MODERATE  0x1000000        // 25 by importance "medium"
#define FILTER_BY_IMPORTANCE_HIGH      0x2000000        // 26 by importance "high"
//--- 5) unit (14)
#define FILTER_BY_UNIT_NONE            0x4000000        // 27 by unit "none"
#define FILTER_BY_UNIT_PERCENT         0x8000000        // 28 by unit "percentage"
#define FILTER_BY_UNIT_CURRENCY        0x10000000       // 29 by unit "currency"
#define FILTER_BY_UNIT_HOUR            0x20000000       // 30 by unit "hours"
#define FILTER_BY_UNIT_JOB             0x40000000       // 31 by unit "jobs"
#define FILTER_BY_UNIT_RIG             0x80000000       // 32 by unit "drilling rigs"
#define FILTER_BY_UNIT_USD             0x100000000      // 33 by unit "USD"
#define FILTER_BY_UNIT_PEOPLE          0x200000000      // 34 by unit "people"
#define FILTER_BY_UNIT_MORTGAGE        0x400000000      // 35 by unit "mortgage loans"
#define FILTER_BY_UNIT_VOTE            0x800000000      // 36 by unit "votes"
#define FILTER_BY_UNIT_BARREL          0x1000000000     // 37 by unit "barrels"
#define FILTER_BY_UNIT_CUBICFEET       0x2000000000     // 38 by unit "cubic feet"
#define FILTER_BY_UNIT_POSITION        0x4000000000     // 39 by unit "net positions"
#define FILTER_BY_UNIT_BUILDING        0x8000000000     // 40 by unit "buildings"
//--- 6) multiplier (5)
#define FILTER_BY_MULTIPLIER_NONE      0x10000000000    // 41 by multiplier "none"
#define FILTER_BY_MULTIPLIER_THOUSANDS 0x20000000000    // 42 by multiplier "thousands"
#define FILTER_BY_MULTIPLIER_MILLIONS  0x40000000000    // 43 by multiplier "millions"
#define FILTER_BY_MULTIPLIER_BILLIONS  0x80000000000    // 44 by multiplier "billions"
#define FILTER_BY_MULTIPLIER_TRILLIONS 0x100000000000   // 45 by multiplier "trillions"
//--- 7) time mode (4)
#define FILTER_BY_TIMEMODE_DATETIME    0x200000000000   // 46 by time mode "na"
#define FILTER_BY_TIMEMODE_DATE        0x400000000000   // 47 by time mode "positive"
#define FILTER_BY_TIMEMODE_NOTIME      0x800000000000   // 48 by time mode "negative"
#define FILTER_BY_TIMEMODE_TENTATIVE   0x1000000000000  // 49 by time mode "tentative"
//--- type
#define IS_TYPE_EVENT(filter) ((filter&FILTER_BY_TYPE_EVENT)!=0)
#define IS_TYPE_INDICATOR(filter) ((filter&FILTER_BY_TYPE_INDICATOR)!=0)
#define IS_TYPE_HOLIDAY(filter) ((filter&FILTER_BY_TYPE_HOLIDAY)!=0)
//--- sector
#define IS_SECTOR_NONE(filter) ((filter&FILTER_BY_SECTOR_NONE)!=0)
#define IS_SECTOR_MARKET(filter) ((filter&FILTER_BY_SECTOR_MARKET)!=0)
#define IS_SECTOR_GDP(filter) ((filter&FILTER_BY_SECTOR_GDP)!=0)
#define IS_SECTOR_JOBS(filter) ((filter&FILTER_BY_SECTOR_JOBS)!=0)
#define IS_SECTOR_PRICES(filter) ((filter&FILTER_BY_SECTOR_PRICES)!=0)
#define IS_SECTOR_MONEY(filter) ((filter&FILTER_BY_SECTOR_MONEY)!=0)
#define IS_SECTOR_TRADE(filter) ((filter&FILTER_BY_SECTOR_TRADE)!=0)
#define IS_SECTOR_CONSUMER(filter) ((filter&FILTER_BY_SECTOR_CONSUMER)!=0)
#define IS_SECTOR_HOUSING(filter) ((filter&FILTER_BY_SECTOR_HOUSING)!=0)
#define IS_SECTOR_TAXES(filter) ((filter&FILTER_BY_SECTOR_TAXES)!=0)
#define IS_SECTOR_HOLIDAYS(filter) ((filter&FILTER_BY_SECTOR_HOLIDAYS)!=0)
//--- frequency
#define IS_FREQUENCY_NONE(filter) ((filter&FILTER_BY_FREQUENCY_NONE)!=0)
#define IS_FREQUENCY_WEEK(filter) ((filter&FILTER_BY_FREQUENCY_WEEK)!=0)
#define IS_FREQUENCY_MONTH(filter) ((filter&FILTER_BY_FREQUENCY_MONTH)!=0)
#define IS_FREQUENCY_QUARTER(filter) ((filter&FILTER_BY_FREQUENCY_QUARTER)!=0)
#define IS_FREQUENCY_YEAR(filter) ((filter&FILTER_BY_FREQUENCY_YEAR)!=0)
#define IS_FREQUENCY_DAY(filter) ((filter&FILTER_BY_FREQUENCY_DAY)!=0)
//--- importance
#define IS_IMPORTANCE_NONE(filter) ((filter&FILTER_BY_IMPORTANCE_NONE)!=0)
#define IS_IMPORTANCE_LOW(filter) ((filter&FILTER_BY_IMPORTANCE_LOW)!=0)
#define IS_IMPORTANCE_MODERATE(filter) ((filter&FILTER_BY_IMPORTANCE_MODERATE)!=0)
#define IS_IMPORTANCE_HIGH(filter) ((filter&FILTER_BY_IMPORTANCE_HIGH)!=0)
//--- unit
#define IS_UNIT_NONE(filter) ((filter&FILTER_BY_UNIT_NONE)!=0)
#define IS_UNIT_PERCENT(filter) ((filter&FILTER_BY_UNIT_PERCENT)!=0)
#define IS_UNIT_CURRENCY(filter) ((filter&FILTER_BY_UNIT_CURRENCY)!=0)
#define IS_UNIT_HOUR(filter) ((filter&FILTER_BY_UNIT_HOUR)!=0)
#define IS_UNIT_JOB(filter) ((filter&FILTER_BY_UNIT_JOB)!=0)
#define IS_UNIT_RIG(filter) ((filter&FILTER_BY_UNIT_RIG)!=0)
#define IS_UNIT_USD(filter) ((filter&FILTER_BY_UNIT_USD)!=0)
#define IS_UNIT_PEOPLE(filter) ((filter&FILTER_BY_UNIT_PEOPLE)!=0)
#define IS_UNIT_MORTGAGE(filter) ((filter&FILTER_BY_UNIT_MORTGAGE)!=0)
#define IS_UNIT_VOTE(filter) ((filter&FILTER_BY_UNIT_VOTE)!=0)
#define IS_UNIT_BARREL(filter) ((filter&FILTER_BY_UNIT_BARREL)!=0)
#define IS_UNIT_CUBICFEET(filter) ((filter&FILTER_BY_UNIT_CUBICFEET)!=0)
#define IS_UNIT_POSITION(filter) ((filter&FILTER_BY_UNIT_POSITION)!=0)
#define IS_UNIT_BUILDING(filter) ((filter&FILTER_BY_UNIT_BUILDING)!=0)
//--- multiplier
#define IS_MULTIPLIER_NONE(filter) ((filter&FILTER_BY_MULTIPLIER_NONE)!=0)
#define IS_MULTIPLIER_THOUSANDS(filter) ((filter&FILTER_BY_MULTIPLIER_THOUSANDS)!=0)
#define IS_MULTIPLIER_MILLIONS(filter) ((filter&FILTER_BY_MULTIPLIER_MILLIONS)!=0)
#define IS_MULTIPLIER_BILLIONS(filter) ((filter&FILTER_BY_MULTIPLIER_BILLIONS)!=0)
#define IS_MULTIPLIER_TRILLIONS(filter) ((filter&FILTER_BY_MULTIPLIER_TRILLIONS)!=0)
//--- time mode
#define IS_TIMEMODE_DATETIME(filter) ((filter&FILTER_BY_TIMEMODE_DATETIME)!=0)
#define IS_TIMEMODE_DATE(filter) ((filter&FILTER_BY_TIMEMODE_DATE)!=0)
#define IS_TIMEMODE_NOTIME(filter) ((filter&FILTER_BY_TIMEMODE_NOTIME)!=0)
#define IS_TIMEMODE_TENTATIVE(filter) ((filter&FILTER_BY_TIMEMODE_TENTATIVE)!=0)
//+------------------------------------------------------------------+
//| Calendar value type                                              |
//+------------------------------------------------------------------+
enum ENUM_CALENDAR_VALUE_TYPE
 {
  CALENDAR_VALUE_TYPE_ACTUAL = 0,           // actual
  CALENDAR_VALUE_TYPE_PREVIOUS = 1,         // previous
  CALENDAR_VALUE_TYPE_REVISED_PREVIOUS = 2, // revised previous
  CALENDAR_VALUE_TYPE_FORECAST = 3,         // forecast
 };
//+------------------------------------------------------------------+
//| Time series observation structure                                |
//+------------------------------------------------------------------+
struct SiTsObservation
 {
  datetime           time; // timestamp
  double             val;  // value
  //--- constructor
  void               SiTsObservation(void): time(0), val(EMPTY_VALUE) {}
 };
//+------------------------------------------------------------------+
//| Time series structure                                            |
//+------------------------------------------------------------------+
struct SiTimeSeries
 {
private:
  bool               init;        // is initialized?
  uint               size;
  datetime           timevals[];  // time values
  double             datavals[];  // data values
  string             name;        // ts name
public:
  //--- constructor
  void               SiTimeSeries(void);
  //--- destructor
  void              ~SiTimeSeries(void);
  //--- copy consructor
  void               SiTimeSeries(const SiTimeSeries &src_ts);
  //--- assignment operator
  void               operator=(const SiTimeSeries &src_ts);
  //--- equality operator
  bool               operator==(const SiTimeSeries &src_ts);
  //--- indexing operator
  SiTsObservation    operator[](const uint idx) const;
  //--- initialization
  bool               Init(datetime &ts_times[], const double &ts_values[],
                          const string ts_name);
  //--- get series properties
  bool               GetSeries(datetime &dst_times[], double &dst_values[], string &dst_name);
  bool               GetSeries(SiTsObservation &dst_observations[], string &dst_name);
  //--- service
  bool               IsInit(void) const
   {
    return init;
   };
  uint               Size(void) const
   {
    return size;
   };
  void               Print(const int digs = 2, const uint step = 0);
 };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void SiTimeSeries::SiTimeSeries(void):
  name(NULL), init(false), size(WRONG_VALUE)
 {
 }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void SiTimeSeries::~SiTimeSeries(void)
 {
 }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool SiTimeSeries::Init(datetime &ts_times[], const double &ts_values[],
                        const string ts_name)
 {
  init = false;
  int values_size =::ArraySize(ts_values);
  if(values_size > 0)
    if(values_size ==::ArraySize(ts_times))
      if(::ArrayCopy(timevals, ts_times) == values_size)
        if(::ArrayCopy(datavals, ts_values) == values_size)
         {
          name = ts_name;
          size = values_size;
          init = true;
         }
  return init;
 }
//+------------------------------------------------------------------+
//| Copy consructor                                                  |
//+------------------------------------------------------------------+
void SiTimeSeries::SiTimeSeries(const SiTimeSeries &src_ts)
 {
  init = false;
  if(src_ts.IsInit())
   {
    uint src_ts_size = src_ts.Size();
    if(::ArrayCopy(timevals, src_ts.timevals) == src_ts_size)
      if(::ArrayCopy(datavals, src_ts.datavals) == src_ts_size)
       {
        name = src_ts.name;
        size = src_ts_size;
        init = true;
       }
   }
 }
//+------------------------------------------------------------------+
//| Assignment operator                                              |
//+------------------------------------------------------------------+
void SiTimeSeries::operator=(const SiTimeSeries &src_ts)
 {
  if(!(this == src_ts))
   {
    init = false;
    if(src_ts.IsInit())
     {
      uint src_ts_size = src_ts.Size();
      if(src_ts_size < size)
       {
        if(::ArrayResize(timevals, src_ts_size) != src_ts_size)
          return;
        if(::ArrayResize(datavals, src_ts_size) != src_ts_size)
          return;
       }
      if(::ArrayCopy(timevals, src_ts.timevals) == src_ts_size)
        if(::ArrayCopy(datavals, src_ts.datavals) == src_ts_size)
         {
          name = src_ts.name;
          size = src_ts_size;
          init = true;
         }
     }
   }
 }
//+------------------------------------------------------------------+
//| Equality operator                                                |
//+------------------------------------------------------------------+
bool SiTimeSeries::operator==(const SiTimeSeries &src_ts)
 {
  if(init != src_ts.init)
    return false;
  if(src_ts.init)
   {
    if(size != src_ts.size)
      return false;
    if(::StringCompare(name, src_ts.name))
      return false;
    for(uint ts_idx = 0; ts_idx < size; ts_idx++)
     {
      if(timevals[ts_idx] != src_ts.timevals[ts_idx])
        return false;
      if(datavals[ts_idx] != src_ts.datavals[ts_idx])
        return false;
     }
   }
  return true;
 }
//+------------------------------------------------------------------+
//| Indexing operator                                                |
//+------------------------------------------------------------------+
SiTsObservation SiTimeSeries::operator[](const uint idx) const
 {
  SiTsObservation res();
  if(init)
    if(idx < size)
     {
      res.time = timevals[idx];
      res.val = datavals[idx];
     }
  return res;
 }
//+------------------------------------------------------------------+
//| Get series properties                                            |
//+------------------------------------------------------------------+
bool SiTimeSeries::GetSeries(datetime &dst_times[], double &dst_values[], string &dst_name)
 {
  if(init)
    if(::ArrayResize(dst_times, size) == size)
      if(::ArrayResize(dst_values, size) == size)
       {
        for(uint ts_idx = 0; ts_idx < size; ts_idx++)
         {
          dst_times[ts_idx] = timevals[ts_idx];
          dst_values[ts_idx] = datavals[ts_idx];
         }
        dst_name = name;
        return true;
       }
  return false;
 }
//+------------------------------------------------------------------+
//| Get series properties                                            |
//+------------------------------------------------------------------+
bool SiTimeSeries::GetSeries(SiTsObservation &dst_observations[], string &dst_name)
 {
  if(init)
    if(::ArrayResize(dst_observations, size) == size)
     {
      for(uint ts_idx = 0; ts_idx < size; ts_idx++)
       {
        dst_observations[ts_idx].time = timevals[ts_idx];
        dst_observations[ts_idx].val = datavals[ts_idx];
       }
      dst_name = name;
      return true;
     }
  return false;
 }
//+------------------------------------------------------------------+
//| Print time series                                                |
//+------------------------------------------------------------------+
void SiTimeSeries::Print(const int digs = 2, const uint step = 0)
 {
  if(init)
   {
    string title_to_print = "\n---== Times series ==---";
    if(name != NULL)
      title_to_print =::StringFormat("\n---== Times series - %s==---", name);
    ::Print(title_to_print);
    for(uint ts_idx = 0; ts_idx < size; ts_idx += step + 1)
     {
      string time_str, data_str;
      time_str = ::TimeToString(timevals[ts_idx]);
      if(datavals[ts_idx] == EMPTY_VALUE)
        data_str = "EMPTY_VALUE";
      else
        data_str = ::DoubleToString(datavals[ts_idx], digs);
      ::PrintFormat("[%d]: time - %s, value - %s", ts_idx + 1, time_str, data_str);
     }
   }
  else
   {
    ::PrintFormat(__FUNCTION__": failed to print TS. It is not initialized!");
   }
 }
//+------------------------------------------------------------------+
//| Class CCalendarInfo.                                             |
//| Appointment: Class for access to calendar info.                  |
//|              Derives from class CObject.                         |
//+------------------------------------------------------------------+
class CCalendarInfo : public CObject
 {
  //--- === Data members === ---
protected:
  string             m_currency;
  ulong              m_country_id;
  MqlCalendarCountry m_country_description;
  ulong              m_event_id;
  MqlCalendarEvent   m_event_description;
  static MqlCalendarCountry m_countries[];
  bool               m_is_init;
  //--- === Methods === ---
public:
  //--- constructor/destructor
  void               CCalendarInfo(void);
  void              ~CCalendarInfo(void) {};
  //--- initialization
  bool           Init
  (
    const string currency = NULL,         // country currency code name
    const ulong country_id = WRONG_VALUE, // country ID
    const ulong event_id = WRONG_VALUE,   // event ID
    const bool to_log = false             // to log?
  );
  void               Deinit(void);
  //--- Сalendar structures descriptions
  bool               CountryDescription(MqlCalendarCountry &country, const bool to_log = false);
  bool               EventDescription(MqlCalendarEvent &event, const bool to_log = false);
  static bool        ValueDescription(ulong value_id, MqlCalendarValue &value,
                                      const bool to_log = false);
  bool               EventsByCountryDescription(MqlCalendarEvent &events[], const bool to_log = false);
  bool               EventsByCurrencyDescription(MqlCalendarEvent &events[], const bool to_log = false);
  bool               EventsBySector(const ENUM_CALENDAR_EVENT_SECTOR event_sector,
                                    MqlCalendarEvent &events[], const bool to_log = false);
  //--- Сalendar enum descriptions
  static string      EventTypeDescription(const ENUM_CALENDAR_EVENT_TYPE event_type);
  static string      EventSectorDescription(const ENUM_CALENDAR_EVENT_SECTOR event_sector, const bool is_long_form = true);
  static string      EventFrequencyDescription(const ENUM_CALENDAR_EVENT_FREQUENCY event_frequency);
  static string      EventTimeModeDescription(const ENUM_CALENDAR_EVENT_TIMEMODE event_time_mode);
  static string      EventUnitDescription(const ENUM_CALENDAR_EVENT_UNIT event_unit);
  static string      EventImportanceDescription(const ENUM_CALENDAR_EVENT_IMPORTANCE event_importance);
  static string      EventMultiplierDescription(const ENUM_CALENDAR_EVENT_MULTIPLIER event_multiplier);
  static string      ValueImpactDescription(const ENUM_CALENDAR_EVENT_IMPACT event_impact);
  //--- history
  bool           ValueHistorySelectByCountry
  (
    MqlCalendarValue &values[], // array for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  )                  const;
  bool           ValueHistorySelectByEvent
  (
    MqlCalendarValue &values[], // array for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  )                  const;
  bool           ValueHistorySelectByEvent
  (
    SiTimeSeries &dst_ts,       // timeseries for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  );
  bool           ValueHistorySelectByEvent
  (
    SiTimeSeries &dst_ts,       // timeseries for value descriptions
    const ENUM_CALENDAR_VALUE_TYPE val_type,
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  );
  bool           ValueHistorySelect
  (
    MqlCalendarValue &values[], // array for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  )                  const;
  bool           ValueHistorySelect
  (
    SiTimeSeries &dst_ts[],     // array of timeseries for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  );
  static bool    ValueHistorySelectAll
  (
    MqlCalendarValue &values[], // array for value descriptions
    datetime datetime_from,     // left border of a time range
    datetime datetime_to = 0    // right border of a time range
  );
  //--- the calendar database status
  int            ValueLastSelectByEvent
  (
    ulong&               change_id,     // Calendar change ID
    MqlCalendarValue&    values[]       // array for value descriptions
  )                  const;
  int            ValueLastSelect
  (
    ulong&               change_id,     // Calendar change ID
    MqlCalendarValue&    values[]       // array for value descriptions
  )                  const;
  static int     ValueLastSelectAll
  (
    ulong&               change_id,     // Calendar change ID
    MqlCalendarValue&    values[]       // array for value descriptions
  );
  //--- currencies
  bool               GetUniqueCurrencies(string &currencies[], const bool is_upper = true);

  //--- countries and continents
  bool               GetCountries(CArrayString &countries_arr);
  bool               GetCountries(MqlCalendarCountry &countries[]);
  bool               GetUniqueContinents(string &continents[]);
  bool               GetCountriesByContinent(const ENUM_CONTINENT src_continent,
      CArrayString &countries_arr,
      const bool is_country_flag = false);

  string             GetCountryNameById(const ulong country_id, const bool is_country_flag = false);
  string             GetCountryCodeById(const ulong country_id);
  //--- events
  bool               GetEventsByName(CArrayString &events_arr, const string name = NULL);
  bool               GetEventsByName(MqlCalendarEvent &events[], const string name = NULL);
  static bool        FilterEventsByAny(MqlCalendarEvent &filtered_events[],
                                       MqlCalendarEvent &src_events[], const ulong filter);
  static bool        FilterEventsByAll(MqlCalendarEvent &filtered_events[],
                                       MqlCalendarEvent &src_events[], const ulong filter);
  static bool        GetUniqueSectors(string &sectors[], const MqlCalendarEvent &src_events[]);
  bool               GetEventsBySector(CArrayString &events_arr,
                                       const ENUM_CALENDAR_EVENT_SECTOR event_sector);
  static ENUM_CALENDAR_EVENT_SECTOR GetSectorByName(const string sector_name);
  //--- print
  static void        PrintCountryDescription(const MqlCalendarCountry &country);
  static void        PrintEventDescription(const MqlCalendarEvent &event);
  static void        PrintValueDescription(const MqlCalendarValue &value);
  //---
private:
  bool               ValidateProperties(void);
  bool               CountryById(const ulong country_id);
  bool               EventId(void);
 };
MqlCalendarCountry CCalendarInfo::m_countries[];
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CCalendarInfo::CCalendarInfo(void)
 {
  m_currency = NULL;
  m_country_id = m_event_id = WRONG_VALUE;
  ::ZeroMemory(m_country_description);
  ::ZeroMemory(m_event_description);
  m_is_init = false;
 }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CCalendarInfo::Init(const string currency = NULL,         // country currency code name
                         const ulong country_id = WRONG_VALUE, // country ID
                         const ulong event_id = WRONG_VALUE,   // event ID
                         const bool to_log = false             // to log?
                        )
 {
//--- check reinitialization
  if(m_is_init)
   {
    ::PrintFormat(__FUNCTION__ + ": CCalendarInfo object already initialized!");
    return false;
   }
//--- check countries
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt < 1)
   {
    ::ResetLastError();
    countries_cnt = ::CalendarCountries(m_countries);
    if(countries_cnt < 1)
     {
      ::PrintFormat(__FUNCTION__ + ": CalendarCountries() returned 0! Error %d",
                    ::GetLastError());
      return false;
     }
   }
  for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
   {
    MqlCalendarCountry curr_country = m_countries[c_idx];
    //--- check currency
    if(!::StringCompare(curr_country.currency, currency))
     {
      m_currency = currency;
     }
    //--- check country
    if(country_id != WRONG_VALUE)
      if(curr_country.id == country_id)
       {
        m_country_id = country_id;
       }
   }
//--- check event
  if(event_id != WRONG_VALUE)
   {
    m_event_id = event_id;
   }
//--- validate properties
  if(!this.ValidateProperties())
    return false;
//---
  if(to_log)
   {
    ::Print("\n---== New Calendar Info object ==---");
    if(m_currency != NULL)
      ::PrintFormat("   Currency: %s", m_currency);
    if(m_country_id != WRONG_VALUE)
      ::PrintFormat("   Country id: %I64u", m_country_id);
    if(m_event_id != WRONG_VALUE)
      ::PrintFormat("   Event id: %I64u", m_event_id);
   }
  m_is_init = true;
  return true;
 }
//+------------------------------------------------------------------+
//| Deinitialization                                                 |
//+------------------------------------------------------------------+
void CCalendarInfo::Deinit(void)
 {
  m_currency = NULL;
  m_country_id = m_event_id = WRONG_VALUE;
  ::ZeroMemory(m_country_description);
  ::ZeroMemory(m_event_description);
  m_is_init = false;
 }
//+------------------------------------------------------------------+
//| Get a country description by its ID                              |
//+------------------------------------------------------------------+
bool CCalendarInfo::CountryDescription(MqlCalendarCountry &country,
                                       const bool to_log = false)
 {
  if(m_country_description.id != WRONG_VALUE)
   {
    country = m_country_description;
    if(to_log)
      this.PrintCountryDescription(country);
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get an event description by its ID                               |
//+------------------------------------------------------------------+
bool CCalendarInfo::EventDescription(MqlCalendarEvent &event, const bool to_log = false)
 {
  if(m_event_description.id != WRONG_VALUE)
   {
    event = m_event_description;
    if(to_log)
      this.PrintEventDescription(event);
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get a value description by its ID                                |
//+------------------------------------------------------------------+
static bool CCalendarInfo::ValueDescription(ulong value_id, MqlCalendarValue& value,
    const bool to_log = false)
 {
  ::ResetLastError();
  if(!::CalendarValueById(value_id, value))
   {
    ::PrintFormat(__FUNCTION__ + ": CalendarValueById() failed! Error %d",
                  ::GetLastError());
    return false;
   }
  if(to_log)
    CCalendarInfo::PrintValueDescription(value);
  return true;
 }
//+---------------------------------------------------------------------+
//| Get the array of descriptions of all events by a specified country  |
//+---------------------------------------------------------------------+
bool CCalendarInfo::EventsByCountryDescription(MqlCalendarEvent &events[],
    const bool to_log = false)
 {
  if(m_country_description.id != WRONG_VALUE)
   {
    string country_code = m_country_description.code;
    ::ResetLastError();
    if(!::CalendarEventByCountry(country_code, events))
     {
      ::PrintFormat(__FUNCTION__ + ": CalendarEventByCountry() failed! Error %d",
                    ::GetLastError());
      return false;
     }
    if(to_log)
      for(int ev_idx = 0; ev_idx < ::ArraySize(events); ev_idx++)
       {
        MqlCalendarEvent curr_event = events[ev_idx];
        this.PrintEventDescription(curr_event);
       }
    return true;
   }
  return false;
 }
//+---------------------------------------------------------------------+
//| Get the array of descriptions of all events by a specified currency |
//+---------------------------------------------------------------------+
bool CCalendarInfo::EventsByCurrencyDescription(MqlCalendarEvent &events[],
    const bool to_log = false)
 {
  if(m_currency != NULL)
   {
    //string country_code = m_country_description.code;
    ::ResetLastError();
    if(!::CalendarEventByCurrency(m_currency, events))
     {
      ::PrintFormat(__FUNCTION__ + ": CalendarEventByCurrency() failed! Error %d",
                    ::GetLastError());
      return false;
     }
    if(to_log)
      for(int ev_idx = 0; ev_idx < ::ArraySize(events); ev_idx++)
       {
        MqlCalendarEvent curr_event = events[ev_idx];
        this.PrintEventDescription(curr_event);
       }
    return true;
   }
  return false;
 }
//+-------------------------------------------------------------------+
//| Get the array of descriptions of all events by a specified sector |
//+-------------------------------------------------------------------+
bool CCalendarInfo::EventsBySector(const ENUM_CALENDAR_EVENT_SECTOR event_sector,
                                   MqlCalendarEvent &events[], const bool to_log = false)
 {
  if(m_country_description.id > 0)
   {
    string country_code = m_country_description.code;
    MqlCalendarEvent temp_events[];
    ::ResetLastError();
    if(!::CalendarEventByCountry(country_code, temp_events))
     {
      ::PrintFormat(__FUNCTION__ + ": CalendarEventByCountry() failed! Error %d",
                    ::GetLastError());
      return false;
     }
    for(int ev_idx = 0; ev_idx <::ArraySize(temp_events); ev_idx++)
     {
      ENUM_CALENDAR_EVENT_SECTOR curr_event_sector = temp_events[ev_idx].sector;
      if(curr_event_sector == event_sector)
       {
        int events_size =::ArraySize(events);
        if(::ArrayResize(events, ++events_size) != events_size)
         {
          ::Print(__FUNCTION__ + ": failed to resize events array!");
          return false;
         }
        events[--events_size] = temp_events[ev_idx];
        if(to_log)
          this.PrintEventDescription(events[events_size]);
       }
     }
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Event type description                                           |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventTypeDescription(const ENUM_CALENDAR_EVENT_TYPE event_type)
 {
  string type_description = NULL;
//---
  switch(event_type)
   {
    case CALENDAR_TYPE_EVENT:
     {
      type_description = "Event";
      break;
     }
    case CALENDAR_TYPE_INDICATOR:
     {
      type_description = "Indicator";
      break;
     }
    case CALENDAR_TYPE_HOLIDAY:
     {
      type_description = "Holiday";
      break;
     }
   }
  return type_description;
 }
//+------------------------------------------------------------------+
//| Event sector description                                         |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventSectorDescription(const ENUM_CALENDAR_EVENT_SECTOR event_sector,
    const bool is_long_form = true)
 {
  string sector_description = NULL;
//---
  switch(event_sector)
   {
    case CALENDAR_SECTOR_NONE:
     {
      sector_description = "None";
      break;
     }
    case CALENDAR_SECTOR_MARKET:
     {
      sector_description = "Market";
      break;
     }
    case CALENDAR_SECTOR_GDP:
     {
      sector_description = "Gross Domestic Product";
      if(!is_long_form)
        sector_description = "GDP";
      break;
     }
    case CALENDAR_SECTOR_JOBS:
     {
      sector_description = "Labor market";
      if(!is_long_form)
        sector_description = "Labor";
      break;
     }
    case CALENDAR_SECTOR_PRICES:
     {
      sector_description = "Prices";
      break;
     }
    case CALENDAR_SECTOR_MONEY:
     {
      sector_description = "Money";
      break;
     }
    case CALENDAR_SECTOR_TRADE:
     {
      sector_description = "Trading";
      break;
     }
    case CALENDAR_SECTOR_GOVERNMENT:
     {
      sector_description = "Government";
      if(!is_long_form)
        sector_description = "Govern.";
      break;
     }
    case CALENDAR_SECTOR_BUSINESS:
     {
      sector_description = "Business";
      break;
     }
    case CALENDAR_SECTOR_CONSUMER:
     {
      sector_description = "Consumption";
      if(!is_long_form)
        sector_description = "Consump.";
      break;
     }
    case CALENDAR_SECTOR_HOUSING:
     {
      sector_description = "Housing";
      break;
     }
    case CALENDAR_SECTOR_TAXES:
     {
      sector_description = "Taxes";
      break;
     }
    case CALENDAR_SECTOR_HOLIDAYS:
     {
      sector_description = "Holidays";
      break;
     }
   }
  return sector_description;
 }
//+------------------------------------------------------------------+
//| Event frequency description                                      |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventFrequencyDescription(const ENUM_CALENDAR_EVENT_FREQUENCY event_frequency)
 {
  string freq_description = NULL;
//---
  switch(event_frequency)
   {
    case CALENDAR_FREQUENCY_NONE:
     {
      freq_description = "None";
      break;
     }
    case CALENDAR_FREQUENCY_WEEK:
     {
      freq_description = "Weekly";
      break;
     }
    case CALENDAR_FREQUENCY_MONTH:
     {
      freq_description = "Monthly";
      break;
     }
    case CALENDAR_FREQUENCY_QUARTER:
     {
      freq_description = "Quarterly";
      break;
     }
    case CALENDAR_FREQUENCY_YEAR:
     {
      freq_description = "Yearly";
      break;
     }
    case CALENDAR_FREQUENCY_DAY:
     {
      freq_description = "Daily";
      break;
     }
   }
  return freq_description;
 }
//+------------------------------------------------------------------+
//| Event time mode description                                      |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventTimeModeDescription(const ENUM_CALENDAR_EVENT_TIMEMODE event_time_mode)
 {
  string time_mode_description = NULL;
//---
  switch(event_time_mode)
   {
    case CALENDAR_TIMEMODE_DATETIME:
     {
      time_mode_description = "Exact time";
      break;
     }
    case CALENDAR_TIMEMODE_DATE:
     {
      time_mode_description = "Takes all day";
      break;
     }
    case CALENDAR_TIMEMODE_NOTIME:
     {
      time_mode_description = "No time";
      break;
     }
    case CALENDAR_TIMEMODE_TENTATIVE:
     {
      time_mode_description = "Tentative";
      break;
     }
   }
  return time_mode_description;
 }
//+------------------------------------------------------------------+
//| Event unit description                                           |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventUnitDescription(const ENUM_CALENDAR_EVENT_UNIT event_unit)
 {
  string unit_description = NULL;
//---
  switch(event_unit)
   {
    case CALENDAR_UNIT_NONE:
     {
      unit_description = "None";
      break;
     }
    case CALENDAR_UNIT_PERCENT:
     {
      unit_description = "Percentage";
      break;
     }
    case CALENDAR_UNIT_CURRENCY:
     {
      unit_description = "National currency";
      break;
     }
    case CALENDAR_UNIT_HOUR:
     {
      unit_description = "Hours";
      break;
     }
    case CALENDAR_UNIT_JOB:
     {
      unit_description = "Jobs";
      break;
     }
    case CALENDAR_UNIT_RIG:
     {
      unit_description = "Drilling rigs";
      break;
     }
    case CALENDAR_UNIT_USD:
     {
      unit_description = "USD";
      break;
     }
    case CALENDAR_UNIT_PEOPLE:
     {
      unit_description = "People";
      break;
     }
    case CALENDAR_UNIT_MORTGAGE:
     {
      unit_description = "Mortgage loans";
      break;
     }
    case CALENDAR_UNIT_VOTE:
     {
      unit_description = "Votes";
      break;
     }
    case CALENDAR_UNIT_BARREL:
     {
      unit_description = "Barrels";
      break;
     }
    case CALENDAR_UNIT_CUBICFEET:
     {
      unit_description = "Cubic feet";
      break;
     }
    case CALENDAR_UNIT_POSITION:
     {
      unit_description = "Non-commercial net positions";
      break;
     }
    case CALENDAR_UNIT_BUILDING:
     {
      unit_description = "Buildings";
      break;
     }
   }
  return unit_description;
 }
//+------------------------------------------------------------------+
//| Event importance description                                     |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventImportanceDescription(const ENUM_CALENDAR_EVENT_IMPORTANCE event_importance)
 {
  string imp_description = NULL;
//---
  switch(event_importance)
   {
    case CALENDAR_IMPORTANCE_NONE:
     {
      imp_description = "None";
      break;
     }
    case CALENDAR_IMPORTANCE_LOW:
     {
      imp_description = "Low";
      break;
     }
    case CALENDAR_IMPORTANCE_MODERATE:
     {
      imp_description = "Moderate";
      break;
     }
    case CALENDAR_IMPORTANCE_HIGH:
     {
      imp_description = "High";
      break;
     }
   }
  return imp_description;
 }
//+------------------------------------------------------------------+
//| Event multiplier description                                     |
//+------------------------------------------------------------------+
static string CCalendarInfo::EventMultiplierDescription(const ENUM_CALENDAR_EVENT_MULTIPLIER event_multiplier)
 {
  string mult_description = NULL;
//---
  switch(event_multiplier)
   {
    case CALENDAR_MULTIPLIER_NONE:
     {
      mult_description = "None";
      break;
     }
    case CALENDAR_MULTIPLIER_THOUSANDS:
     {
      mult_description = "Thousands";
      break;
     }
    case CALENDAR_MULTIPLIER_MILLIONS:
     {
      mult_description = "Millions";
      break;
     }
    case CALENDAR_MULTIPLIER_BILLIONS:
     {
      mult_description = "Billions";
      break;
     }
    case CALENDAR_MULTIPLIER_TRILLIONS:
     {
      mult_description = "Trillions";
      break;
     }
   }
  return mult_description;
 }
//+------------------------------------------------------------------+
//| Value impact description                                         |
//+------------------------------------------------------------------+
static string CCalendarInfo::ValueImpactDescription(const ENUM_CALENDAR_EVENT_IMPACT event_impact)
 {
  string impact_description = NULL;
//---
  switch(event_impact)
   {
    case CALENDAR_IMPACT_NA:
     {
      impact_description = "None";
      break;
     }
    case CALENDAR_IMPACT_POSITIVE:
     {
      impact_description = "Positive";
      break;
     }
    case CALENDAR_IMPACT_NEGATIVE:
     {
      impact_description = "Negative";
      break;
     }
   }
  return impact_description;
 }
//+------------------------------------------------------------------+
//| Validate properties                                              |
//+------------------------------------------------------------------+
bool CCalendarInfo::ValidateProperties(void)
 {
//--- validate country id
  if(m_country_id != WRONG_VALUE)
   {
    if(!this.CountryById(m_country_id))
      return false;
    //--- if currency set before
    if(m_currency != NULL)
     {
      string curr_country_currency = m_country_description.currency;
      if(::StringCompare(curr_country_currency, m_currency))
       {
        ::PrintFormat(__FUNCTION__ + ": failed! Currencies must be the same!");
        return false;
       }
     }
   }
//--- validate event id
  if(m_event_id != WRONG_VALUE)
   {
    if(!this.EventId())
      return false;
    //--- if country id set before
    if(m_country_id != WRONG_VALUE)
     {
      ulong curr_country_id = m_event_description.country_id;
      if(curr_country_id != m_country_id)
       {
        ::PrintFormat(__FUNCTION__ + ": failed! Country ids must be the same!");
        return false;
       }
     }
    else
     {
      //--- if currency set before
      if(m_currency != NULL)
       {
        if(!this.CountryById(m_event_description.country_id))
          return false;
        string curr_country_currency = m_country_description.currency;
        ::ZeroMemory(m_country_description); // reset MqlCalendarCountry
        if(::StringCompare(curr_country_currency, m_currency))
         {
          ::PrintFormat(__FUNCTION__ + ": failed! Currencies must be the same!");
          return false;
         }
       }
     }
   }
  return true;
 }
//+------------------------------------------------------------------+
//| Get country by id                                                |
//+------------------------------------------------------------------+
bool CCalendarInfo::CountryById(const ulong country_id)
 {
  ::ResetLastError();
  if(!::CalendarCountryById(country_id, m_country_description))
   {
    ::PrintFormat(__FUNCTION__ + ": CalendarCountryById() failed! Error %d",
                  ::GetLastError());
    return false;
   }
  return true;
 }
//+------------------------------------------------------------------+
//| Get event by id                                                  |
//+------------------------------------------------------------------+
bool CCalendarInfo::EventId(void)
 {
  ::ResetLastError();
  if(!::CalendarEventById(m_event_id, m_event_description))
   {
    ::PrintFormat(__FUNCTION__ + ": CalendarEventById() failed! Error %d",
                  ::GetLastError());
    return false;
   }
  return true;
 }
//+--------------------------------------------------------------------+
//| Get values for all events in a specified time range by an event ID |                                                                |
//+--------------------------------------------------------------------+
bool CCalendarInfo::ValueHistorySelectByEvent
(
  MqlCalendarValue & values[], // array for value descriptions
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
) const
 {
  if(m_event_id == WRONG_VALUE)
   {
    ::PrintFormat(__FUNCTION__ + ": failed! No valid id for the event!");
    return false;
   }
  ::ResetLastError();
  if(::CalendarValueHistoryByEvent(m_event_id, values, datetime_from, datetime_to) < 0)
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueHistoryByEvent() failed! Error %d",
                    last_error_code);
    return false;
   }
  return true;
 }
//+-------------------------------------------------------------------+
//| Get values as timeseries for all events in a specified time range |
//| by an event ID                                                    |
//+-------------------------------------------------------------------+
bool CCalendarInfo::ValueHistorySelectByEvent
(
  SiTimeSeries & dst_ts,      // timeseries for value descriptions
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
)
 {
//--- get values for all events
  MqlCalendarValue values[];
  if(this.ValueHistorySelectByEvent(values, datetime_from, datetime_to))
   {
    int values_size =::ArraySize(values);
    if(values_size > 0)
     {
      //--- create TS
      datetime ts_times[];
      if(::ArrayResize(ts_times, values_size) == values_size)
       {
        ::ArrayInitialize(ts_times, 0);
        double ts_values[];
        if(::ArrayResize(ts_values, values_size) == values_size)
         {
          ::ArrayInitialize(ts_values, EMPTY_VALUE);
          for(int v_idx = 0; v_idx < values_size; v_idx++)
           {
            MqlCalendarValue curr_val = values[v_idx];
            ts_times[v_idx] = curr_val.time;
            if(curr_val.HasActualValue())
              ts_values[v_idx] = curr_val.GetActualValue();
           }
          string ts_name = m_event_description.name;
          string country_code = this.GetCountryCodeById(m_event_description.country_id);
          if(country_code != NULL)
            ts_name += ", " + country_code;
          SiTimeSeries temp_ts;
          if(temp_ts.Init(ts_times, ts_values, ts_name))
           {
            dst_ts = temp_ts;
            return true;
           }
         }
       }
     }
   }
  return false;
 }
//+--------------------------------------------------------------------+
//| Get values of the defined type for all events in a specified time  |
//| range by an event ID                                               |
//+--------------------------------------------------------------------+
bool CCalendarInfo::ValueHistorySelectByEvent
(
  SiTimeSeries &dst_ts,       // timeseries for value descriptions
  const ENUM_CALENDAR_VALUE_TYPE val_type,
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
)
 {
//--- get values for all events
  MqlCalendarValue values[];
  if(this.ValueHistorySelectByEvent(values, datetime_from, datetime_to))
   {
    int values_size =::ArraySize(values);
    if(values_size > 0)
     {
      //--- create TS
      datetime ts_times[];
      if(::ArrayResize(ts_times, values_size) == values_size)
       {
        ::ArrayInitialize(ts_times, 0);
        double ts_values[];
        if(::ArrayResize(ts_values, values_size) == values_size)
         {
          string val_name = NULL;
          ::ArrayInitialize(ts_values, EMPTY_VALUE);
          for(int v_idx = 0; v_idx < values_size; v_idx++)
           {
            MqlCalendarValue curr_value = values[v_idx];
            ts_times[v_idx] = curr_value.time;
            double curr_val = QNaN;
            switch(val_type)
             {
              case CALENDAR_VALUE_TYPE_ACTUAL:
               {
                if(curr_value.HasActualValue())
                  curr_val = curr_value.GetActualValue();
                val_name = "actual";
                break;
               }
              case CALENDAR_VALUE_TYPE_PREVIOUS:
               {
                if(curr_value.HasPreviousValue())
                  curr_val = curr_value.GetPreviousValue();
                val_name = "previous";
                break;
               }
              case CALENDAR_VALUE_TYPE_REVISED_PREVIOUS:
               {
                if(curr_value.HasRevisedValue())
                  curr_val = curr_value.GetRevisedValue();
                val_name = "revised";
                break;
               }
              case CALENDAR_VALUE_TYPE_FORECAST:
               {
                if(curr_value.HasForecastValue())
                  curr_val = curr_value.GetForecastValue();
                val_name = "forecast";
                break;
               }
             }
            ts_values[v_idx] = curr_val;
           }
          string ts_name = m_event_description.name;
          string country_code = this.GetCountryCodeById(m_event_description.country_id);
          if(country_code != NULL)
            ts_name += ", " + country_code;
          /*if(val_name != NULL)
             ts_name += ", " + val_name;*/
          SiTimeSeries temp_ts;
          if(temp_ts.Init(ts_times, ts_values, ts_name))
           {
            dst_ts = temp_ts;
            return true;
           }
         }
       }
     }
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get values for all events in a specified time range by country   |
//| and/or currency                                                  |
//+------------------------------------------------------------------+
bool CCalendarInfo::ValueHistorySelect
(
  MqlCalendarValue & values[], // array for value descriptions
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
) const
 {
  if(m_currency == NULL && m_country_id == WRONG_VALUE)
   {
    ::PrintFormat(__FUNCTION__ + ": failed! No valid currency and country code for the event!");
    return false;
   }
  string curr_country_code = m_country_description.code;
  ::ResetLastError();
  if(!::CalendarValueHistory(values, datetime_from, datetime_to, curr_country_code, m_currency))
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueHistory() failed! Error %d",
                    last_error_code);
    return false;
   }
  return true;
 }
//+------------------------------------------------------------------+
//| Get array of timeseries for all events in a specified time range |
//| by country and/or currency                                       |
//+------------------------------------------------------------------+
bool CCalendarInfo::ValueHistorySelect
(
  SiTimeSeries & dst_ts[],    // array of timeseries for value descriptions
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
)
 {
//--- get values for all events by country and/or currency
  MqlCalendarValue values[];
  if(this.ValueHistorySelect(values, datetime_from, datetime_to))
   {
    int values_size =::ArraySize(values);
    if(values_size > 0)
     {
      //--- collect unique event ids
      CSortedSet<ulong> event_id_set;
      for(int v_idx = 0; v_idx < values_size; v_idx++)
       {
        MqlCalendarValue curr_val = values[v_idx];
        ulong curr_event_id = values[v_idx].event_id;
        if(!event_id_set.Contains(curr_event_id))
          if(!event_id_set.Add(curr_event_id))
           {
            ::Print(__FUNCTION__ + ": failed to add an event id!");
            return false;
           }
       }
      int event_cnt = event_id_set.Count();
      ulong event_ids[];
      if(event_id_set.CopyTo(event_ids) != event_cnt)
       {
        ::Print(__FUNCTION__ + ": failed to copy event ids!");
        return false;
       }
      //--- get values as timeseries by an event ID
      if(::ArrayResize(dst_ts, event_cnt) != event_cnt)
       {
        ::Print(__FUNCTION__ + ": failed to resize dst_ts!");
        return false;
       }
      for(int ev_idx = 0; ev_idx < event_cnt; ev_idx++)
       {
        ulong curr_event_id = event_ids[ev_idx];
        //--- new CalendarInfo object with only event id specified
        CCalendarInfo curr_event_info;
        if(!curr_event_info.Init(NULL, WRONG_VALUE, curr_event_id, false))
          return false;
        SiTimeSeries temp_ts;
        if(!curr_event_info.ValueHistorySelectByEvent(temp_ts,
            datetime_from, datetime_to))
          return false;
        dst_ts[ev_idx] = temp_ts;
       }
     }
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get values for all events in a specified time range              |
//+------------------------------------------------------------------+
static bool CCalendarInfo::ValueHistorySelectAll
(
  MqlCalendarValue &values[], // array for value descriptions
  datetime datetime_from,     // left border of a time range
  datetime datetime_to = 0    // right border of a time range
)
 {
  ::ResetLastError();
  if(!::CalendarValueHistory(values, datetime_from, datetime_to))
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueHistory() failed! Error %d",
                    last_error_code);
    return false;
   }
  return true;
 }
//+------------------------------------------------------------------+
//| Get values by an event ID since the Calendar database status     |
//+------------------------------------------------------------------+
int CCalendarInfo::ValueLastSelectByEvent
(
  ulong &               change_id,    // Calendar change ID
  MqlCalendarValue &    values[]      // array for value descriptions
) const
 {
  if(m_event_id == WRONG_VALUE)
   {
    ::PrintFormat(__FUNCTION__ + ": failed! No valid id for the event!");
    return 0;
   }
  ::ResetLastError();
  int values_num =::CalendarValueLastByEvent(m_event_id, change_id, values);
  if(values_num == 0)
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueLastByEvent() failed! Error %d",
                    last_error_code);
   }
  return values_num;
 }
//+------------------------------------------------------------------+
//| Get values since the Calendar database status by country and/or  |
//| currency                                                         |
//+------------------------------------------------------------------+
int CCalendarInfo::ValueLastSelect
(
  ulong &               change_id,    // Calendar change ID
  MqlCalendarValue &    values[]      // array for value descriptions
) const
 {
  if(m_currency == NULL && m_country_id == WRONG_VALUE)
   {
    ::PrintFormat(__FUNCTION__ + ": failed! No valid currency and country code for the event!");
    return false;
   }
  string curr_country_code = m_country_description.code;
  ::ResetLastError();
  int values_num =::CalendarValueLast(change_id, values, curr_country_code, m_currency);
  if(values_num == 0)
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueLast() failed! Error %d",
                    last_error_code);
   }
  return values_num;
 }
//+------------------------------------------------------------------+
//| Get all values since the Calendar database status                |
//+------------------------------------------------------------------+
static int CCalendarInfo::ValueLastSelectAll
(
  ulong&               change_id,     // Calendar change ID
  MqlCalendarValue&    values[]       // array for value descriptions
)
 {
  ::ResetLastError();
  int values_num =::CalendarValueLast(change_id, values);
  if(values_num == 0)
   {
    int last_error_code =::GetLastError();
    if(last_error_code > 0)
      ::PrintFormat(__FUNCTION__ + ": CalendarValueLast() failed! Error %d",
                    last_error_code);
   }
  if(IS_DEBUG_MODE)
   {
    if(values_num > 0)
      ::DebugBreak();
   }
  return values_num;
 }
//+------------------------------------------------------------------+
//| Get unique currencies                                            |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetUniqueCurrencies(string &currencies[], const bool is_upper = true)
 {
//--- collect unique currencies
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt > 0)
   {
    CSortedSet<string> currency_set;
    for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
     {
      MqlCalendarCountry curr_country = m_countries[c_idx];
      string curr_country_currency = curr_country.currency;
      if(!is_upper)
       {
        if(!::StringToLower(curr_country_currency))
          return false;
       }
      if(!currency_set.Contains(curr_country_currency))
        if(!currency_set.Add(curr_country_currency))
         {
          ::Print(__FUNCTION__ + ": failed to add a currency!");
          return false;
         }
     }
    int currencies_cnt = currency_set.Count();
    if(currencies_cnt > 0)
      if(currency_set.CopyTo(currencies) == currencies_cnt)
        return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get countries list                                               |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetCountries(CArrayString & countries_arr)
 {
  if(countries_arr.Total() > 0)
    if(!countries_arr.Shutdown())
     {
      ::Print(__FUNCTION__ + ": failed to clear countries list!");
      return false;
     }
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt > 0)
   {
    for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
     {
      MqlCalendarCountry curr_country = m_countries[c_idx];
      string curr_country_name = curr_country.name;
      if(!countries_arr.Add(curr_country_name))
       {
        ::Print(__FUNCTION__ + ": failed to add a country to the list!");
        return false;
       }
     }
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get calendar countries                                           |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetCountries(MqlCalendarCountry & countries[])
 {
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt > 0)
    if(::ArrayResize(countries, countries_cnt) == countries_cnt)
     {
      for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
        countries[c_idx] = m_countries[c_idx];
      return true;
     }
  return false;
 }
//+------------------------------------------------------------------+
//| Get unique continents                                            |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetUniqueContinents(string & continents[])
 {
//--- collect unique continents
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt > 0)
   {
    CSortedSet<string> continent_set;
    for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
     {
      MqlCalendarCountry curr_country = m_countries[c_idx];
      string curr_country_code = curr_country.code;
      SCountryByContinent curr_country_continent_data;
      if(curr_country_continent_data.Init(curr_country_code))
       {
        string curr_country_continent_description =
          curr_country_continent_data.ContinentDescription();
        if(!continent_set.Contains(curr_country_continent_description))
          if(!continent_set.Add(curr_country_continent_description))
           {
            ::Print(__FUNCTION__ + ": failed to add a continent description!");
            return false;
           }
       }
     }
    int continents_cnt = continent_set.Count();
    if(continents_cnt > 0)
      if(continent_set.CopyTo(continents) == continents_cnt)
        return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get countries by continent                                       |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetCountriesByContinent(const ENUM_CONTINENT src_continent,
    CArrayString & countries_arr, const bool is_country_flag = false)
 {
  if(countries_arr.Total() > 0)
    if(!countries_arr.Shutdown())
     {
      ::Print(__FUNCTION__ + ": failed to clear countries list!");
      return false;
     }
  int countries_cnt = ::ArraySize(m_countries);
  if(countries_cnt > 0)
   {
    for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
     {
      MqlCalendarCountry curr_country = m_countries[c_idx];
      string curr_country_code = curr_country.code;
      SCountryByContinent curr_country_continent_data;
      if(curr_country_continent_data.Init(curr_country_code))
       {
        ENUM_CONTINENT curr_continent = curr_country_continent_data.Continent();
        if(curr_continent == src_continent)
         {
          string curr_country_name = ::StringFormat("%s", curr_country.name);
          if(is_country_flag)
           {
            SCountryByContinent curr_country_by_continent;
            if(curr_country_by_continent.Init(curr_country.code))
             {
              //curr_country_name += (" " + curr_country_by_continent.Code());
              curr_country_name = ::StringFormat("%s %s", curr_country.name,
                                                 curr_country_by_continent.FlagUnicode());
             }
           }
          if(!countries_arr.Add(curr_country_name))
           {
            ::Print(__FUNCTION__ + ": failed to add a country to the list!");
            return false;
           }
         }
       }
     }
    return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get country name by id                                           |
//+------------------------------------------------------------------+
string CCalendarInfo::GetCountryNameById(const ulong country_id,
    const bool is_country_flag = false)
 {
  string country_name = NULL;
//---
  int countries_cnt =::ArraySize(m_countries);
  for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
   {
    MqlCalendarCountry curr_country = m_countries[c_idx];
    ulong curr_country_id = curr_country.id;
    if(curr_country_id == country_id)
     {
      country_name = ::StringFormat("%s", curr_country.name);
      if(is_country_flag)
       {
        SCountryByContinent curr_country_by_continent;
        if(curr_country_by_continent.Init(curr_country.code))
          country_name = ::StringFormat("%s %s", curr_country.name,
                                        curr_country_by_continent.FlagUnicode());
       }
      break;
     }
   }
  return country_name;
 }
//+------------------------------------------------------------------+
//| Get country code by id                                           |
//+------------------------------------------------------------------+
string CCalendarInfo::GetCountryCodeById(const ulong country_id)
 {
  string country_code = NULL;
//---
  int countries_cnt =::ArraySize(m_countries);
  for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
   {
    MqlCalendarCountry curr_country = m_countries[c_idx];
    ulong curr_country_id = curr_country.id;
    if(curr_country_id == country_id)
     {
      country_code = curr_country.code;
      break;
     }
   }
  return country_code;
 }
//+------------------------------------------------------------------+
//| Get events by name                                               |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetEventsByName(CArrayString & events_arr, const string name = NULL)
 {
  if(events_arr.Total() > 0)
    if(!events_arr.Shutdown())
     {
      ::Print(__FUNCTION__ + ": failed to clear events list!");
      return false;
     }
  int countries_cnt = ::ArraySize(m_countries);
  for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
   {
    MqlCalendarCountry curr_country = m_countries[c_idx];
    //--- new CalendarInfo object with only country id specified
    CCalendarInfo curr_country_info;
    if(!curr_country_info.Init(NULL, curr_country.id, WRONG_VALUE, false))
      return false;
    MqlCalendarEvent country_events[];
    if(!curr_country_info.EventsByCountryDescription(country_events))
      return false;
    int country_events_size =::ArraySize(country_events);
    //---
    for(int ev_idx = 0; ev_idx <::ArraySize(country_events); ev_idx++)
     {
      MqlCalendarEvent curr_event = country_events[ev_idx];
      if(name != NULL)
       {
        int name_len =::StringLen(name);
        string curr_event_name = curr_event.name;
        string res_arr[];
        string sep = " ";
        ushort u_sep;
        string result[];
        u_sep = ::StringGetCharacter(sep, 0);
        int substrings =::StringSplit(curr_event_name, u_sep, res_arr);
        bool is_found = false;
        for(int i = 0; i < substrings; i++)
         {
          string curr_sub_str = res_arr[i];
          if(::StringFind(curr_event_name, name) > -1)
            if(name_len ==::StringLen(curr_sub_str))
             {
              is_found = true;
              break;
             }
         }
        if(!is_found)
          continue;
       }
      if(!events_arr.Add(curr_event.name))
       {
        ::Print(__FUNCTION__ + ": failed to add an event name to the list!");
        return false;
       }
     }
   }
  return events_arr.Total() > 0;
 }
//+------------------------------------------------------------------+
//| Get events by name                                               |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetEventsByName(MqlCalendarEvent & events[], const string name = NULL)
 {
  int countries_cnt = ::ArraySize(m_countries);
  for(int c_idx = 0; c_idx < countries_cnt; c_idx++)
   {
    MqlCalendarCountry curr_country = m_countries[c_idx];
    //--- new CalendarInfo object with only country id specified
    CCalendarInfo curr_country_info;
    if(!curr_country_info.Init(NULL, curr_country.id, WRONG_VALUE, false))
      return false;
    MqlCalendarEvent country_events[];
    if(!curr_country_info.EventsByCountryDescription(country_events))
      return false;
    int country_events_size =::ArraySize(country_events);
    //---
    for(int ev_idx = 0; ev_idx < country_events_size; ev_idx++)
     {
      MqlCalendarEvent curr_event = country_events[ev_idx];
      if(name != NULL)
       {
        int name_len =::StringLen(name);
        string curr_event_name = curr_event.name;
        string res_arr[];
        string sep = " ";
        ushort u_sep;
        string result[];
        u_sep = ::StringGetCharacter(sep, 0);
        int substrings =::StringSplit(curr_event_name, u_sep, res_arr);
        bool is_found = false;
        for(int i = 0; i < substrings; i++)
         {
          string curr_sub_str = res_arr[i];
          if(::StringFind(curr_sub_str, name) > -1)
            if(name_len ==::StringLen(curr_sub_str))
             {
              is_found = true;
              break;
             }
         }
        if(!is_found)
          continue;
       }
      int events_size =::ArraySize(events);
      if(::ArrayResize(events, ++events_size) != events_size)
       {
        ::Print(__FUNCTION__ + ": failed to resize events array!");
        return false;
       }
      events[--events_size] = curr_event;
     }
   }
  return ::ArraySize(events) > 0;
 }
//+------------------------------------------------------------------+
//| Filter events                                                    |
//| Valid if any criterion                                           |
//+------------------------------------------------------------------+
static bool CCalendarInfo::FilterEventsByAny(MqlCalendarEvent &filtered_events[],
    MqlCalendarEvent &src_events[], const ulong filter)
 {
  if(filter > 0)
   {
    int src_events_cnt = ::ArraySize(src_events);
    if(src_events_cnt > 0)
     {
      for(int ev_idx = 0; ev_idx < src_events_cnt; ev_idx++)
       {
        MqlCalendarEvent curr_event = src_events[ev_idx];
        //--- 1) type
        bool is_type = true;
        switch(curr_event.type)
         {
          case CALENDAR_TYPE_EVENT:
           {
            if(!IS_TYPE_EVENT(filter))
              is_type = false;
            break;
           }
          case CALENDAR_TYPE_INDICATOR:
           {
            if(!IS_TYPE_INDICATOR(filter))
              is_type = false;
            break;
           }
          case CALENDAR_TYPE_HOLIDAY:
           {
            if(!IS_TYPE_HOLIDAY(filter))
              is_type = false;
            break;
           }
         }
        if(!is_type)
          continue;
        //--- 2) sector
        bool is_sector = true;
        switch(curr_event.sector)
         {
          case CALENDAR_SECTOR_NONE:
           {
            if(!IS_SECTOR_NONE(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_MARKET:
           {
            if(!IS_SECTOR_MARKET(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_GDP:
           {
            if(!IS_SECTOR_GDP(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_JOBS:
           {
            if(!IS_SECTOR_JOBS(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_PRICES:
           {
            if(!IS_SECTOR_PRICES(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_MONEY:
           {
            if(!IS_SECTOR_MONEY(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_TRADE:
           {
            if(!IS_SECTOR_TRADE(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_CONSUMER:
           {
            if(!IS_SECTOR_CONSUMER(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_HOUSING:
           {
            if(!IS_SECTOR_HOUSING(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_TAXES:
           {
            if(!IS_SECTOR_TAXES(filter))
              is_sector = false;
            break;
           }
          case CALENDAR_SECTOR_HOLIDAYS:
           {
            if(!IS_SECTOR_HOLIDAYS(filter))
              is_sector = false;
            break;
           }
         }
        if(!is_sector)
          continue;
        //--- 3) frequency
        bool is_frequency = true;
        switch(curr_event.frequency)
         {
          case CALENDAR_FREQUENCY_NONE:
           {
            if(!IS_FREQUENCY_NONE(filter))
              is_frequency = false;
            break;
           }
          case CALENDAR_FREQUENCY_WEEK:
           {
            if(!IS_FREQUENCY_WEEK(filter))
              is_frequency = false;
            break;
           }
          case CALENDAR_FREQUENCY_MONTH:
           {
            if(!IS_FREQUENCY_MONTH(filter))
              is_frequency = false;
            break;
           }
          case CALENDAR_FREQUENCY_QUARTER:
           {
            if(!IS_FREQUENCY_QUARTER(filter))
              is_frequency = false;
            break;
           }
          case CALENDAR_FREQUENCY_YEAR:
           {
            if(!IS_FREQUENCY_YEAR(filter))
              is_frequency = false;
            break;
           }
          case CALENDAR_FREQUENCY_DAY:
           {
            if(!IS_FREQUENCY_DAY(filter))
              is_frequency = false;
            break;
           }
         }
        if(!is_frequency)
          continue;
        //--- 4) importance
        bool is_importance = true;
        switch(curr_event.importance)
         {
          case CALENDAR_IMPORTANCE_NONE:
           {
            if(!IS_IMPORTANCE_NONE(filter))
              is_importance = false;
            break;
           }
          case CALENDAR_IMPORTANCE_LOW:
           {
            if(!IS_IMPORTANCE_LOW(filter))
              is_importance = false;
            break;
           }
          case CALENDAR_IMPORTANCE_MODERATE:
           {
            if(!IS_IMPORTANCE_MODERATE(filter))
              is_importance = false;
            break;
           }
          case CALENDAR_IMPORTANCE_HIGH:
           {
            if(!IS_IMPORTANCE_HIGH(filter))
              is_importance = false;
            break;
           }
         }
        if(!is_importance)
          continue;
        //--- 5) unit
        bool is_unit = true;
        switch(curr_event.unit)
         {
          case CALENDAR_UNIT_NONE:
           {
            if(!IS_UNIT_NONE(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_PERCENT:
           {
            if(!IS_UNIT_PERCENT(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_CURRENCY:
           {
            if(!IS_UNIT_CURRENCY(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_HOUR:
           {
            if(!IS_UNIT_HOUR(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_JOB:
           {
            if(!IS_UNIT_JOB(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_RIG:
           {
            if(!IS_UNIT_RIG(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_USD:
           {
            if(!IS_UNIT_USD(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_PEOPLE:
           {
            if(!IS_UNIT_PEOPLE(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_MORTGAGE:
           {
            if(!IS_UNIT_MORTGAGE(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_VOTE:
           {
            if(!IS_UNIT_VOTE(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_BARREL:
           {
            if(!IS_UNIT_BARREL(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_CUBICFEET:
           {
            if(!IS_UNIT_CUBICFEET(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_POSITION:
           {
            if(!IS_UNIT_POSITION(filter))
              is_unit = false;
            break;
           }
          case CALENDAR_UNIT_BUILDING:
           {
            if(!IS_UNIT_BUILDING(filter))
              is_unit = false;
            break;
           }
         }
        if(!is_unit)
          continue;
        //--- 6) multiplier
        bool is_multiplier = true;
        switch(curr_event.multiplier)
         {
          case CALENDAR_MULTIPLIER_NONE:
           {
            if(!IS_MULTIPLIER_NONE(filter))
              is_multiplier = false;
            break;
           }
          case CALENDAR_MULTIPLIER_THOUSANDS:
           {
            if(!IS_MULTIPLIER_THOUSANDS(filter))
              is_multiplier = false;
            break;
           }
          case CALENDAR_MULTIPLIER_MILLIONS:
           {
            if(!IS_MULTIPLIER_MILLIONS(filter))
              is_multiplier = false;
            break;
           }
          case CALENDAR_MULTIPLIER_BILLIONS:
           {
            if(!IS_MULTIPLIER_BILLIONS(filter))
              is_multiplier = false;
            break;
           }
          case CALENDAR_MULTIPLIER_TRILLIONS:
           {
            if(!IS_MULTIPLIER_TRILLIONS(filter))
              is_multiplier = false;
            break;
           }
         }
        if(!is_multiplier)
          continue;
        //--- 7) time mode
        bool is_time_mode = true;
        switch(curr_event.time_mode)
         {
          case CALENDAR_TIMEMODE_DATETIME:
           {
            if(!IS_TIMEMODE_DATETIME(filter))
              is_time_mode = false;
            break;
           }
          case CALENDAR_TIMEMODE_DATE:
           {
            if(!IS_TIMEMODE_DATE(filter))
              is_time_mode = false;
            break;
           }
          case CALENDAR_TIMEMODE_NOTIME:
           {
            if(!IS_TIMEMODE_NOTIME(filter))
              is_time_mode = false;
            break;
           }
          case CALENDAR_TIMEMODE_TENTATIVE:
           {
            if(!IS_TIMEMODE_TENTATIVE(filter))
              is_time_mode = false;
            break;
           }
         }
        if(!is_time_mode)
          continue;
        //--- add an event to the array
        int events_size =::ArraySize(filtered_events);
        if(::ArrayResize(filtered_events, ++events_size) != events_size)
         {
          ::Print(__FUNCTION__ + ": failed to resize events array!");
          return false;
         }
        filtered_events[--events_size] = curr_event;
       }
      return true;
     }
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Filter events                                                    |
//| Valid if all criteria                                            |
//+------------------------------------------------------------------+
static bool CCalendarInfo::FilterEventsByAll(MqlCalendarEvent &filtered_events[],
    MqlCalendarEvent &src_events[], const ulong filter)
 {
  if(filter > 0)
   {
    int src_events_cnt = ::ArraySize(src_events);
    if(src_events_cnt > 0)
     {
      for(int ev_idx = 0; ev_idx < src_events_cnt; ev_idx++)
       {
        MqlCalendarEvent curr_event = src_events[ev_idx];
        //--- 1) type
        if(IS_TYPE_EVENT(filter))
          if(curr_event.type != CALENDAR_TYPE_EVENT)
            continue;
        if(IS_TYPE_INDICATOR(filter))
          if(curr_event.type != CALENDAR_TYPE_INDICATOR)
            continue;
        if(IS_TYPE_HOLIDAY(filter))
          if(curr_event.type != CALENDAR_TYPE_HOLIDAY)
            continue;
        //--- 2) sector
        if(IS_SECTOR_NONE(filter))
          if(curr_event.sector != CALENDAR_SECTOR_NONE)
            continue;
        if(IS_SECTOR_MARKET(filter))
          if(curr_event.sector != CALENDAR_SECTOR_MARKET)
            continue;
        if(IS_SECTOR_GDP(filter))
          if(curr_event.sector != CALENDAR_SECTOR_GDP)
            continue;
        if(IS_SECTOR_JOBS(filter))
          if(curr_event.sector != CALENDAR_SECTOR_JOBS)
            continue;
        if(IS_SECTOR_PRICES(filter))
          if(curr_event.sector != CALENDAR_SECTOR_PRICES)
            continue;
        if(IS_SECTOR_MONEY(filter))
          if(curr_event.sector != CALENDAR_SECTOR_MONEY)
            continue;
        if(IS_SECTOR_TRADE(filter))
          if(curr_event.sector != CALENDAR_SECTOR_TRADE)
            continue;
        if(IS_SECTOR_CONSUMER(filter))
          if(curr_event.sector != CALENDAR_SECTOR_CONSUMER)
            continue;
        if(IS_SECTOR_HOUSING(filter))
          if(curr_event.sector != CALENDAR_SECTOR_HOUSING)
            continue;
        if(IS_SECTOR_TAXES(filter))
          if(curr_event.sector != CALENDAR_SECTOR_TAXES)
            continue;
        if(IS_SECTOR_HOLIDAYS(filter))
          if(curr_event.sector != CALENDAR_SECTOR_HOLIDAYS)
            continue;
        //--- 3) frequency
        if(IS_FREQUENCY_NONE(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_NONE)
            continue;
        if(IS_FREQUENCY_WEEK(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_WEEK)
            continue;
        if(IS_FREQUENCY_MONTH(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_MONTH)
            continue;
        if(IS_FREQUENCY_QUARTER(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_QUARTER)
            continue;
        if(IS_FREQUENCY_YEAR(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_YEAR)
            continue;
        if(IS_FREQUENCY_DAY(filter))
          if(curr_event.frequency != CALENDAR_FREQUENCY_DAY)
            continue;
        //--- 4) importance
        if(IS_IMPORTANCE_NONE(filter))
          if(curr_event.importance != CALENDAR_IMPORTANCE_NONE)
            continue;
        if(IS_IMPORTANCE_LOW(filter))
          if(curr_event.importance != CALENDAR_IMPORTANCE_LOW)
            continue;
        if(IS_IMPORTANCE_MODERATE(filter))
          if(curr_event.importance != CALENDAR_IMPORTANCE_MODERATE)
            continue;
        if(IS_IMPORTANCE_HIGH(filter))
          if(curr_event.importance != CALENDAR_IMPORTANCE_HIGH)
            continue;
        //--- 5) unit
        if(IS_UNIT_NONE(filter))
          if(curr_event.unit != CALENDAR_UNIT_NONE)
            continue;
        if(IS_UNIT_PERCENT(filter))
          if(curr_event.unit != CALENDAR_UNIT_PERCENT)
            continue;
        if(IS_UNIT_CURRENCY(filter))
          if(curr_event.unit != CALENDAR_UNIT_CURRENCY)
            continue;
        if(IS_UNIT_HOUR(filter))
          if(curr_event.unit != CALENDAR_UNIT_HOUR)
            continue;
        if(IS_UNIT_JOB(filter))
          if(curr_event.unit != CALENDAR_UNIT_JOB)
            continue;
        if(IS_UNIT_RIG(filter))
          if(curr_event.unit != CALENDAR_UNIT_RIG)
            continue;
        if(IS_UNIT_USD(filter))
          if(curr_event.unit != CALENDAR_UNIT_USD)
            continue;
        if(IS_UNIT_PEOPLE(filter))
          if(curr_event.unit != CALENDAR_UNIT_PEOPLE)
            continue;
        if(IS_UNIT_MORTGAGE(filter))
          if(curr_event.unit != CALENDAR_UNIT_MORTGAGE)
            continue;
        if(IS_UNIT_VOTE(filter))
          if(curr_event.unit != CALENDAR_UNIT_VOTE)
            continue;
        if(IS_UNIT_BARREL(filter))
          if(curr_event.unit != CALENDAR_UNIT_BARREL)
            continue;
        if(IS_UNIT_CUBICFEET(filter))
          if(curr_event.unit != CALENDAR_UNIT_CUBICFEET)
            continue;
        if(IS_UNIT_POSITION(filter))
          if(curr_event.unit != CALENDAR_UNIT_POSITION)
            continue;
        if(IS_UNIT_BUILDING(filter))
          if(curr_event.unit != CALENDAR_UNIT_BUILDING)
            continue;
        //--- 6) multiplier
        if(IS_MULTIPLIER_NONE(filter))
          if(curr_event.multiplier != CALENDAR_MULTIPLIER_NONE)
            continue;
        if(IS_MULTIPLIER_THOUSANDS(filter))
          if(curr_event.multiplier != CALENDAR_MULTIPLIER_THOUSANDS)
            continue;
        if(IS_MULTIPLIER_MILLIONS(filter))
          if(curr_event.multiplier != CALENDAR_MULTIPLIER_MILLIONS)
            continue;
        if(IS_MULTIPLIER_BILLIONS(filter))
          if(curr_event.multiplier != CALENDAR_MULTIPLIER_BILLIONS)
            continue;
        if(IS_MULTIPLIER_TRILLIONS(filter))
          if(curr_event.multiplier != CALENDAR_MULTIPLIER_TRILLIONS)
            continue;
        //--- 7) time mode
        if(IS_TIMEMODE_DATETIME(filter))
          if(curr_event.time_mode != CALENDAR_TIMEMODE_DATETIME)
            continue;
        if(IS_TIMEMODE_DATE(filter))
          if(curr_event.time_mode != CALENDAR_TIMEMODE_DATE)
            continue;
        if(IS_TIMEMODE_NOTIME(filter))
          if(curr_event.time_mode != CALENDAR_TIMEMODE_NOTIME)
            continue;
        if(IS_TIMEMODE_TENTATIVE(filter))
          if(curr_event.time_mode != CALENDAR_TIMEMODE_TENTATIVE)
            continue;
        //--- add an event to the array
        int events_size =::ArraySize(filtered_events);
        if(::ArrayResize(filtered_events, ++events_size) != events_size)
         {
          ::Print(__FUNCTION__ + ": failed to resize events array!");
          return false;
         }
        filtered_events[--events_size] = curr_event;
       }
      return true;
     }
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get unique sectors                                               |
//+------------------------------------------------------------------+
static bool CCalendarInfo::GetUniqueSectors(string &sectors[],
    const MqlCalendarEvent &src_events[])
 {
//--- collect unique sectors
  int events_cnt = ::ArraySize(src_events);
  if(events_cnt > 0)
   {
    CSortedSet<string> sector_set;
    for(int ev_idx = 0; ev_idx < events_cnt; ev_idx++)
     {
      ENUM_CALENDAR_EVENT_SECTOR curr_sector = src_events[ev_idx].sector;
      string curr_sector_description = CCalendarInfo::EventSectorDescription(curr_sector);
      if(!sector_set.Contains(curr_sector_description))
        if(!sector_set.Add(curr_sector_description))
         {
          ::Print(__FUNCTION__ + ": failed to add a sector description!");
          return false;
         }
     }
    int sectors_cnt = sector_set.Count();
    if(sectors_cnt > 0)
      if(sector_set.CopyTo(sectors) == sectors_cnt)
        return true;
   }
  return false;
 }
//+------------------------------------------------------------------+
//| Get events by sector                                             |
//+------------------------------------------------------------------+
bool CCalendarInfo::GetEventsBySector(CArrayString &events_arr,
                                      const ENUM_CALENDAR_EVENT_SECTOR event_sector)
 {
  return true;
 }
//+------------------------------------------------------------------+
//| Get sector by name                                               |
//+------------------------------------------------------------------+
static ENUM_CALENDAR_EVENT_SECTOR CCalendarInfo::GetSectorByName(const string sector_name)
 {
  ENUM_CALENDAR_EVENT_SECTOR sector = WRONG_VALUE;
  string would_be_names[] =
   {
    "None",
    "Market",
    "Gross Domestic Product",
    "Labor market",
    "Prices", "Money",
    "Trading",
    "Government",
    "Business",
    "Consumption",
    "Housing",
    "Taxes",
    "Holidays"
   };
  ENUM_CALENDAR_EVENT_SECTOR would_be_sectors[] =
   {
    CALENDAR_SECTOR_NONE,
    CALENDAR_SECTOR_MARKET,
    CALENDAR_SECTOR_GDP,
    CALENDAR_SECTOR_JOBS,
    CALENDAR_SECTOR_PRICES,
    CALENDAR_SECTOR_MONEY,
    CALENDAR_SECTOR_TRADE,
    CALENDAR_SECTOR_GOVERNMENT,
    CALENDAR_SECTOR_BUSINESS,
    CALENDAR_SECTOR_CONSUMER,
    CALENDAR_SECTOR_HOUSING,
    CALENDAR_SECTOR_TAXES,
    CALENDAR_SECTOR_HOLIDAYS
   };
//---
  for(int s_idx = 0; s_idx <::ArraySize(would_be_names); s_idx++)
   {
    string curr_would_be_name = would_be_names[s_idx];
    if(!::StringCompare(sector_name, curr_would_be_name))
     {
      sector = would_be_sectors[s_idx];
      break;
     }
   }
  return sector;
 };
//+------------------------------------------------------------------+
//| Print country description                                        |
//+------------------------------------------------------------------+
static void CCalendarInfo::PrintCountryDescription(const MqlCalendarCountry & country)
 {
  ::Print("\n---== Country description ==---");
  ::PrintFormat("   Id: %I64u", country.id);
  ::PrintFormat("   Name: %s", country.name);
  ::PrintFormat("   Code: %s", country.code);
  ::PrintFormat("   Currency: %s", country.currency);
  ::PrintFormat("   Currency symbol: %s", country.currency_symbol);
  ::PrintFormat("   URL name: %s", country.url_name);
 }
//+------------------------------------------------------------------+
//| Print event description                                          |
//+------------------------------------------------------------------+
static void CCalendarInfo::PrintEventDescription(const MqlCalendarEvent & event)
 {
  ::Print("\n---== Event description ==---");
  ::PrintFormat("   Id: %I64u", event.id);
  ::PrintFormat("   Type: %s", CCalendarInfo::EventTypeDescription(event.type));
  ::PrintFormat("   Sector: %s", CCalendarInfo::EventSectorDescription(event.sector));
  ::PrintFormat("   Frequency: %s", CCalendarInfo::EventFrequencyDescription(event.frequency));
  ::PrintFormat("   Time mode: %s", CCalendarInfo::EventTimeModeDescription(event.time_mode));
  ::PrintFormat("   Country id: %I64u", event.country_id);
  ::PrintFormat("   Unit: %s", CCalendarInfo::EventUnitDescription(event.unit));
  ::PrintFormat("   Importance: %s", CCalendarInfo::EventImportanceDescription(event.importance));
  ::PrintFormat("   Multiplier: %s", CCalendarInfo::EventMultiplierDescription(event.multiplier));
  ::PrintFormat("   Digits: %I32u", event.digits);
  ::PrintFormat("   Source URL: %s", event.source_url);
  ::PrintFormat("   Event code: %s", event.event_code);
  ::PrintFormat("   Name: %s", event.name);
 }
//+------------------------------------------------------------------+
//| Print value description                                          |
//+------------------------------------------------------------------+
static void CCalendarInfo::PrintValueDescription(const MqlCalendarValue & value)
 {
  ::Print("\n---== Value description ==---");
  ::PrintFormat("   Id: %I64u", value.id);
  ::PrintFormat("   Event id: %I64u", value.event_id);
  ::PrintFormat("   Time: %s", ::TimeToString(value.time));
  ::PrintFormat("   Period: %s", ::TimeToString(value.period));
  ::PrintFormat("   Revision: %I32d", value.revision);
  if(value.HasActualValue())
   {
    double actual_val = value.GetActualValue();
    ::PrintFormat("   Actual value: %0.2f", actual_val);
   }
  if(value.HasPreviousValue())
   {
    double prev_val = value.GetPreviousValue();
    ::PrintFormat("   Previous value: %0.2f", prev_val);
   }
  if(value.HasRevisedValue())
   {
    double revised_val = value.GetRevisedValue();
    ::PrintFormat("   Revised previous value: %0.2f", revised_val);
   }
  if(value.HasForecastValue())
   {
    double forecast_val = value.GetForecastValue();
    ::PrintFormat("   Forecast value: %0.2f", forecast_val);
   }
  ::PrintFormat("   Impact type: %s", CCalendarInfo::ValueImpactDescription(value.impact_type));
 }
//+------------------------------------------------------------------+
//--- [EOF]
//+------------------------------------------------------------------+
