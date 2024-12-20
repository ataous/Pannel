//+------------------------------------------------------------------+
//|                                                   Continents.mqh |
//|                                           Copyright 2021, denkir |
//|                             https://www.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, denkir"
#property link      "https://www.mql5.com/ru/users/denkir"
//---
#define COUNTRIES_NUM 197
//+------------------------------------------------------------------+
//| Continents enumeration                                           |
//+------------------------------------------------------------------+
enum ENUM_CONTINENT
  {
   CONTINENT_WORLD             = 0,    // World
   CONTINENT_ASIA              = 1,    // Asia
   CONTINENT_AFRICA            = 2,    // Africa
   CONTINENT_EUROPE            = 3,    // Europe
   CONTINENT_NORTH_AMERICA     = 4,    // North America
   CONTINENT_SOUTH_AMERICA     = 5,    // South America
   CONTINENT_AUSTRALIA_OCEANIA = 6,    // Australia/Oceania
   CONTINENT_ANTARCTICA        = 7,    // Antarctica
  };
//+------------------------------------------------------------------+
//| Country by continent structure                                   |
//+------------------------------------------------------------------+
struct SCountryByContinent
  {
private:
   string            code;      // country
   string            unicode;   // country unicode
   string            country;   // country
   ENUM_CONTINENT    continent; // continent
public:
   //--- constructor
   void              SCountryByContinent(void);
   //--- copy consructor
   void              SCountryByContinent(const SCountryByContinent &_src_country);
   //--- assignment operator
   void              operator=(const SCountryByContinent &_src_country);
   //--- equality operator
   bool              operator==(const SCountryByContinent &_src_country);
   //--- initilization
   bool              Init(const string _src_country_code);
   //--- get
   string            Code(void) const           { return code;    };
   string            FlagUnicode(void) const    { return unicode; };
   string            Country(void) const        { return country; };
   ENUM_CONTINENT    Continent(void) const      { return continent;};
   string            ContinentDescription(void) const;
   static ENUM_CONTINENT ContinentByDescription(const string _src_description);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void SCountryByContinent::SCountryByContinent(void)
  {
   code = unicode = country = NULL;
   continent = WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Copy constructor                                                 |
//+------------------------------------------------------------------+
void SCountryByContinent::SCountryByContinent(const SCountryByContinent &_src_country)
  {
   code = _src_country.code;
   country = _src_country.country;
   continent = _src_country.continent;
  }
//+------------------------------------------------------------------+
//| Assignment operator                                              |
//+------------------------------------------------------------------+
void SCountryByContinent::operator=(const SCountryByContinent &_src_country)
  {
   if(!(this == _src_country))
     {
      code = _src_country.code;
      country = _src_country.country;
      continent = _src_country.continent;
     }
  }
//+------------------------------------------------------------------+
//| Equality operator                                                |
//+------------------------------------------------------------------+
bool SCountryByContinent::operator==(const SCountryByContinent &_src_country)
  {
   if(::StringCompare(code, _src_country.code))
      return false;
   if(::StringCompare(country, _src_country.country))
      return false;
   if(continent != _src_country.continent)
      return false;
   return true;
  }
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool SCountryByContinent::Init(const string _src_country_code)
  {
   const string Codes[COUNTRIES_NUM] =
     {
      "AD", // #1 - Andorra
      "AE", // #2 - United Arab Emirates
      "AF", // #3 - Afghanistan
      "AG", // #4 - Antigua and Barbuda
      "AI", // #5 - Anguilla
      "AL", // #6 - Albania
      "AM", // #7 - Armenia
      "AO", // #8 - Angola
      "AQ", // #9 - Antarctica
      "AR", // #10 - Argentina
      "AS", // #11 - American Samoa
      "AT", // #12 - Austria
      "AU", // #13 - Australia
      "AW", // #14 - Aruba
      "AX", // #15 - Åland Islands
      "AZ", // #16 - Azerbaijan
      "BA", // #17 - Bosnia and Herzegovina
      "BB", // #18 - Barbados
      "BD", // #19 - Bangladesh
      "BE", // #20 - Belgium
      "BF", // #21 - Burkina Faso
      "BG", // #22 - Bulgaria
      "BH", // #23 - Bahrain
      "BI", // #24 - Burundi
      "BJ", // #25 - Benin
      "BN", // #26 - Brunei Darussalam
      "BO", // #27 - Bolivia
      "BR", // #28 - Brazil
      "BT", // #29 - Bhutan
      "BW", // #30 - Botswana
      "BY", // #31 - Belarus
      "BZ", // #32 - Belize
      "CA", // #33 - Canada
      "CD", // #34 - Congo, Democratic Republic of the
      "CF", // #35 - Central African Republic
      "CG", // #36 - Congo
      "CH", // #37 - Switzerland
      "CI", // #38 - Côte d'Ivoire
      "CL", // #39 - Chile
      "CM", // #40 - Cameroon
      "CN", // #41 - China
      "CO", // #42 - Colombia
      "CR", // #43 - Costa Rica
      "CU", // #44 - Cuba
      "CV", // #45 - Cabo Verde
      "CY", // #46 - Cyprus
      "CZ", // #47 - Czechia
      "DE", // #48 - Germany
      "DJ", // #49 - Djibouti
      "DK", // #50 - Denmark
      "DM", // #51 - Dominica
      "DO", // #52 - Dominican Republic
      "DZ", // #53 - Algeria
      "EC", // #54 - Ecuador
      "EE", // #55 - Estonia
      "EG", // #56 - Egypt
      "EH", // #57 - Western Sahara
      "ER", // #58 - Eritrea
      "ES", // #59 - Spain
      "ET", // #60 - Ethiopia
      "EU", // #61 - European Union
      "FI", // #62 - Finland
      "FJ", // #63 - Fiji
      "FO", // #64 - Faroe Islands
      "FR", // #65 - France
      "GA", // #66 - Gabon
      "GB", // #67 - United Kingdom of Great Britain and Northern Ireland
      "GE", // #68 - Georgia
      "GH", // #69 - Ghana
      "GL", // #70 - Greenland
      "GM", // #71 - Gambia
      "GN", // #72 - Guinea
      "GQ", // #73 - Equatorial Guinea
      "GR", // #74 - Greece
      "GT", // #75 - Guatemala
      "GW", // #76 - Guinea-Bissau
      "GY", // #77 - Guyana
      "HK", // #78 - Hong Kong
      "HN", // #79 - Honduras
      "HR", // #80 - Croatia
      "HT", // #81 - Haiti
      "HU", // #82 - Hungary
      "ID", // #83 - Indonesia
      "IE", // #84 - Ireland
      "IL", // #85 - Israel
      "IN", // #86 - India
      "IQ", // #87 - Iraq
      "IR", // #88 - Iran
      "IS", // #89 - Iceland
      "IT", // #90 - Italy
      "JM", // #91 - Jamaica
      "JO", // #92 - Jordan
      "JP", // #93 - Japan
      "KE", // #94 - Kenya
      "KG", // #95 - Kyrgyzstan
      "KH", // #96 - Cambodia
      "KP", // #97 - Korea (Democratic People's Republic of)
      "KR", // #98 - Korea, Republic of
      "KW", // #99 - Kuwait
      "KZ", // #100 - Kazakhstan
      "LA", // #101 - Lao People's Democratic Republic
      "LB", // #102 - Lebanon
      "LI", // #103 - Liechtenstein
      "LK", // #104 - Sri Lanka
      "LR", // #105 - Liberia
      "LS", // #106 - Lesotho
      "LT", // #107 - Lithuania
      "LU", // #108 - Luxembourg
      "LV", // #109 - Latvia
      "LY", // #110 - Libya
      "MA", // #111 - Morocco
      "MC", // #112 - Monaco
      "MD", // #113 - Moldova
      "ME", // #114 - Montenegro
      "MG", // #115 - Madagascar
      "MK", // #116 - North Macedonia
      "ML", // #117 - Mali
      "MM", // #118 - Myanmar
      "MN", // #119 - Mongolia
      "MR", // #120 - Mauritania
      "MT", // #121 - Malta
      "MU", // #122 - Mauritius
      "MV", // #123 - Maldives
      "MW", // #124 - Malawi
      "MX", // #125 - Mexico
      "MY", // #126 - Malaysia
      "MZ", // #127 - Mozambique
      "NA", // #128 - Namibia
      "NC", // #129 - New Caledonia
      "NE", // #130 - Niger
      "NG", // #131 - Nigeria
      "NI", // #132 - Nicaragua
      "NL", // #133 - Netherlands
      "NO", // #134 - Norway
      "NP", // #135 - Nepal
      "NZ", // #136 - New Zealand
      "OM", // #137 - Oman
      "PA", // #138 - Panama
      "PE", // #139 - Peru
      "PG", // #140 - Papua New Guinea
      "PH", // #141 - Philippines
      "PK", // #142 - Pakistan
      "PL", // #143 - Poland
      "PR", // #144 - Puerto Rico
      "PS", // #145 - Palestine
      "PT", // #146 - Portugal
      "PY", // #147 - Paraguay
      "QA", // #148 - Qatar
      "RO", // #149 - Romania
      "RS", // #150 - Serbia
      "RU", // #151 - Russian Federation
      "RW", // #152 - Rwanda
      "SA", // #153 - Saudi Arabia
      "SB", // #154 - Solomon Islands
      "SC", // #155 - Seychelles
      "SD", // #156 - Sudan
      "SE", // #157 - Sweden
      "SG", // #158 - Singapore
      "SI", // #159 - Slovenia
      "SK", // #160 - Slovakia
      "SL", // #161 - Sierra Leone
      "SM", // #162 - San Marino
      "SN", // #163 - Senegal
      "SO", // #164 - Somalia
      "SR", // #165 - Suriname
      "SS", // #166 - South Sudan
      "ST", // #167 - Sao Tome and Principe
      "SV", // #168 - El Salvador
      "SY", // #169 - Syrian Arab Republic
      "SZ", // #170 - Eswatini
      "TD", // #171 - Chad
      "TG", // #172 - Togo
      "TH", // #173 - Thailand
      "TJ", // #174 - Tajikistan
      "TM", // #175 - Turkmenistan
      "TN", // #176 - Tunisia
      "TO", // #177 - Tonga
      "TR", // #178 - Turkey
      "TT", // #179 - Trinidad and Tobago
      "TW", // #180 - Taiwan
      "TZ", // #181 - Tanzania
      "UA", // #182 - Ukraine
      "UG", // #183 - Uganda
      "US", // #184 - United States of America
      "UY", // #185 - Uruguay
      "UZ", // #186 - Uzbekistan
      "VA", // #187 - Vatican
      "VC", // #188 - Saint Vincent and the Grenadines
      "VE", // #189 - Venezuela
      "VG", // #190 - Virgin Islands (British)
      "VI", // #191 - Virgin Islands (U.S.)
      "VN", // #192 - Viet Nam
      "WW", // #193 - Worldwide
      "YE", // #194 - Yemen
      "ZA", // #195 - South Africa
      "ZM", // #196 - Zambia
      "ZW"  // #197 - Zimbabwe
     };
   const string Countries[COUNTRIES_NUM] =
     {
      "Andorra",               // #1
      "United Arab Emirates",  // #2
      "Afghanistan",           // #3
      "Antigua and Barbuda",   // #4
      "Anguilla",              // #5
      "Albania",               // #6
      "Armenia",               // #7
      "Angola",                // #8
      "Antarctica",            // #9
      "Argentina",             // #10
      "American Samoa",        // #11
      "Austria",               // #12
      "Australia",             // #13
      "Aruba",                 // #14
      "Åland Islands",         // #15
      "Azerbaijan",            // #16
      "Bosnia and Herzegovina",// #17
      "Barbados",              // #18
      "Bangladesh",            // #19
      "Belgium",               // #20
      "Burkina Faso",          // #21
      "Bulgaria",              // #22
      "Bahrain",               // #23
      "Burundi",               // #24
      "Benin",                 // #25
      "Brunei Darussalam",     // #26
      "Bolivia",               // #27
      "Brazil",                // #28
      "Bhutan",                // #29
      "Botswana",              // #30
      "Belarus",               // #31
      "Belize",                // #32
      "Canada",                // #33
      "Congo, Democratic Republic of the", // #34
      "Central African Republic", // #35
      "Congo",                 // #36
      "Switzerland",           // #37
      "Côte d'Ivoire",         // #38
      "Chile",                 // #39
      "Cameroon",              // #40
      "China",                 // #41
      "Colombia",              // #42
      "Costa Rica",            // #43
      "Cuba",                  // #44
      "Cabo Verde",            // #45
      "Cyprus",                // #46
      "Czechia",               // #47
      "Germany",               // #48
      "Djibouti",              // #49
      "Denmark",               // #50
      "Dominica",              // #51
      "Dominican Republic",    // #52
      "Algeria",               // #53
      "Ecuador",               // #54
      "Estonia",               // #55
      "Egypt",                 // #56
      "Western Sahara",        // #57
      "Eritrea",               // #58
      "Spain",                 // #59
      "Ethiopia",              // #60
      "European Union",        // #61
      "Finland",               // #62
      "Fiji",                  // #63
      "Faroe Islands",         // #64
      "France",                // #65
      "Gabon",                 // #66
      "United Kingdom of Great Britain and Northern Ireland",// #67
      "Georgia",               // #68
      "Ghana",                 // #69
      "Greenland",             // #70
      "Gambia",                // #71
      "Guinea",                // #72
      "Equatorial Guinea",     // #73
      "Greece",                // #74
      "Guatemala",             // #75
      "Guinea-Bissau",         // #76
      "Guyana",                // #77
      "Hong Kong",             // #78
      "Honduras",              // #79
      "Croatia",               // #80
      "Haiti",                 // #81
      "Hungary",               // #82
      "Indonesia",             // #83
      "Ireland",               // #84
      "Israel",                // #85
      "India",                 // #86
      "Iraq",                  // #87
      "Iran",                  // #88
      "Iceland",               // #89
      "Italy",                 // #90
      "Jamaica",               // #91
      "Jordan",                // #92
      "Japan",                 // #93
      "Kenya",                 // #94
      "Kyrgyzstan",            // #95
      "Cambodia",              // #96
      "Korea (Democratic People's Republic of)",// #97
      "Korea, Republic of",    // #98
      "Kuwait",                // #99
      "Kazakhstan",            // #100
      "Lao People's Democratic Republic",// #101
      "Lebanon",               // #102
      "Liechtenstein",         // #103
      "Sri Lanka",             // #104
      "Liberia",               // #105
      "Lesotho",               // #106
      "Lithuania",             // #107
      "Luxembourg",            // #108
      "Latvia",                // #109
      "Libya",                 // #110
      "Morocco",               // #111
      "Monaco",                // #112
      "Moldova",               // #113
      "Montenegro",            // #114
      "Madagascar",            // #115
      "North Macedonia",       // #116
      "Mali",                  // #117
      "Myanmar",               // #118
      "Mongolia",              // #119
      "Mauritania",            // #120
      "Malta",                 // #121
      "Mauritius",             // #122
      "Maldives",              // #123
      "Malawi",                // #124
      "Mexico",                // #125
      "Malaysia",              // #126
      "Mozambique",            // #127
      "Namibia",               // #128
      "New Caledonia",         // #129
      "Niger",                 // #130
      "Nigeria",               // #131
      "Nicaragua",             // #132
      "Netherlands",           // #133
      "Norway",                // #134
      "Nepal",                 // #135
      "New Zealand",           // #136
      "Oman",                  // #137
      "Panama",                // #138
      "Peru",                  // #139
      "Papua New Guinea",      // #140
      "Philippines",           // #141
      "Pakistan",              // #142
      "Poland",                // #143
      "Puerto Rico",           // #144
      "Palestine",             // #145
      "Portugal",              // #146
      "Paraguay",              // #147
      "Qatar",                 // #148
      "Romania",               // #149
      "Serbia",                // #150
      "Russian Federation",    // #151
      "Rwanda",                // #152
      "Saudi Arabia",          // #153
      "Solomon Islands",       // #154
      "Seychelles",            // #155
      "Sudan",                 // #156
      "Sweden",                // #157
      "Singapore",             // #158
      "Slovenia",              // #159
      "Slovakia",              // #160
      "Sierra Leone",          // #161
      "San Marino",            // #162
      "Senegal",               // #163
      "Somalia",               // #164
      "Suriname",              // #165
      "South Sudan",           // #166
      "Sao Tome and Principe", // #167
      "El Salvador",           // #168
      "Syrian Arab Republic",  // #169
      "Eswatini",              // #170
      "Chad",                  // #171
      "Togo",                  // #172
      "Thailand",              // #173
      "Tajikistan",            // #174
      "Turkmenistan",          // #175
      "Tunisia",               // #176
      "Tonga",                 // #177
      "Turkey",                // #178
      "Trinidad and Tobago",   // #179
      "Taiwan",                // #180
      "Tanzania",              // #181
      "Ukraine",               // #182
      "Uganda",                // #183
      "United States of America",// #184
      "Uruguay",               // #185
      "Uzbekistan",            // #186
      "Vatican",               // #187
      "Saint Vincent and the Grenadines", // #188
      "Venezuela",             // #189
      "Virgin Islands (British)", // #190
      "Virgin Islands (U.S.)", // #191
      "Viet Nam",              // #192
      "Worldwide",             // #193
      "Yemen",                 // #194
      "South Africa",          // #195
      "Zambia",                // #196
      "Zimbabwe"               // #197
     };
   /*const string ABCD[] =
     {
   "\xF1E6", //      A
      "\xF1E7", //      B
      "\xF1E8", //      C
      "\xF1E9", //      D
      "\xF1EA", //      E
      "\xF1EB", //      F
      "\xF1EC", //      G
      "\xF1ED", //      H
      "\xF1EE", //      I
      "\xF1EF", //      J
      "\xF1F0", //      K
      "\xF1F1", //      L
      "\xF1F2", //      M
      "\xF1F3", //      N
      "\xF1F4", //      O
      "\xF1F5", //      P
      "\xF1F6", //      Q
      "\xF1F7", //      R
      "\xF1F8", //      S
      "\xF1F9", //      T
      "\xF1FA", //      U
      "\xF1FB", //      V
      "\xF1FC", //      W
      "\xF1FD", //      X
      "\xF1FE", //      Y
      "\xF1FF"  //      Z
     };*/
   const string Flag_codes[] =
     {
      "\xF1E6", //      A
      "\xF1E7", //      B
      "\xF1E8", //      C
      "\xF1E9", //      D
      "\xF1EA", //      E
      "\xF1EB", //      F
      "\xF1EC", //      G
      "\xF1ED", //      H
      "\xF1EE", //      I
      "\xF1EF", //      J
      "\xF1F0", //      K
      "\xF1F1", //      L
      "\xF1F2", //      M
      "\xF1F3", //      N
      "\xF1F4", //      O
      "\xF1F5", //      P
      "\xF1F6", //      Q
      "\xF1F7", //      R
      "\xF1F8", //      S
      "\xF1F9", //      T
      "\xF1FA", //      U
      "\xF1FB", //      V
      "\xF1FC", //      W
      "\xF1FD", //      X
      "\xF1FE", //      Y
      "\xF1FF"  //      Z
     };
   const ENUM_CONTINENT Continents[COUNTRIES_NUM] =
     {
      CONTINENT_EUROPE,          // #1 - Andorra
      CONTINENT_ASIA,            // #2 - United Arab Emirates
      CONTINENT_ASIA,            // #3 - Afghanistan
      CONTINENT_NORTH_AMERICA,   // #4 - Antigua and Barbuda
      CONTINENT_NORTH_AMERICA,   // #5 - Anguilla
      CONTINENT_EUROPE,          // #6 - Albania
      CONTINENT_ASIA,            // #7 - Armenia
      CONTINENT_AFRICA,          // #8 - Angola
      CONTINENT_ANTARCTICA,      // #9 - Antarctica
      CONTINENT_SOUTH_AMERICA,   // #10 - Argentina
      CONTINENT_AUSTRALIA_OCEANIA,// #11 - American Samoa
      CONTINENT_EUROPE,          // #12 - Austria
      CONTINENT_AUSTRALIA_OCEANIA,// #13 - Australia
      CONTINENT_SOUTH_AMERICA,   // #14 - Aruba
      CONTINENT_EUROPE,          // #15 - Åland Islands
      CONTINENT_ASIA,            // #16 - Azerbaijan
      CONTINENT_EUROPE,          // #17 - Bosnia and Herzegovina
      CONTINENT_NORTH_AMERICA,   // #18 - Barbados
      CONTINENT_ASIA,            // #19 - Bangladesh
      CONTINENT_EUROPE,          // #20 - Belgium
      CONTINENT_AFRICA,          // #21 - Burkina Faso
      CONTINENT_EUROPE,          // #22 - Bulgaria
      CONTINENT_ASIA,            // #23 - Bahrain
      CONTINENT_AFRICA,          // #24 - Burundi
      CONTINENT_AFRICA,          // #25 - Benin
      CONTINENT_ASIA,            // #26 - Brunei Darussalam
      CONTINENT_SOUTH_AMERICA,   // #27 - Bolivia
      CONTINENT_SOUTH_AMERICA,   // #28 - Brazil
      CONTINENT_ASIA,            // #29 - Bhutan
      CONTINENT_AFRICA,          // #30 - Botswana
      CONTINENT_EUROPE,          // #31 - Belarus
      CONTINENT_NORTH_AMERICA,   // #32 - Belize
      CONTINENT_NORTH_AMERICA,   // #33 - Canada
      CONTINENT_AFRICA,          // #34 - Congo, Democratic Republic of the
      CONTINENT_AFRICA,          // #35 - Central African Republic
      CONTINENT_AFRICA,          // #36 - Congo
      CONTINENT_EUROPE,          // #37 - Switzerland
      CONTINENT_AFRICA,          // #38 - Côte d'Ivoire
      CONTINENT_NORTH_AMERICA,   // #39 - Chile
      CONTINENT_AFRICA,          // #40 - Cameroon
      CONTINENT_ASIA,            // #41 - China
      CONTINENT_SOUTH_AMERICA,   // #42 - Colombia
      CONTINENT_NORTH_AMERICA,   // #43 - Costa Rica
      CONTINENT_NORTH_AMERICA,   // #44 - Cuba
      CONTINENT_AFRICA,          // #45 - Cabo Verde
      CONTINENT_EUROPE,          // #46 - Cyprus
      CONTINENT_EUROPE,          // #47 - Czechia
      CONTINENT_EUROPE,          // #48 - Germany
      CONTINENT_AFRICA,          // #49 - Djibouti
      CONTINENT_EUROPE,          // #50 - Denmark
      CONTINENT_NORTH_AMERICA,   // #51 - Dominica
      CONTINENT_NORTH_AMERICA,   // #52 - Dominican Republic
      CONTINENT_AFRICA,          // #53 - Algeria
      CONTINENT_SOUTH_AMERICA,   // #54 - Ecuador
      CONTINENT_EUROPE,          // #55 - Estonia
      CONTINENT_AFRICA,          // #56 - Egypt
      CONTINENT_AFRICA,          // #57 - Western Sahara
      CONTINENT_AFRICA,          // #58 - Eritrea
      CONTINENT_EUROPE,          // #59 - Spain
      CONTINENT_AFRICA,          // #60 - Ethiopia
      CONTINENT_EUROPE,          // #61 - European Union
      CONTINENT_EUROPE,          // #62 - Finland
      CONTINENT_AUSTRALIA_OCEANIA, // #63 - Fiji
      CONTINENT_EUROPE,          // #64 - Faroe Islands
      CONTINENT_EUROPE,          // #65 - France
      CONTINENT_AFRICA,          // #66 - Gabon
      CONTINENT_EUROPE,          // #67 - United Kingdom of Great Britain and Northern Ireland
      CONTINENT_ASIA,            // #68 - Georgia
      CONTINENT_AFRICA,          // #69 - Ghana
      CONTINENT_NORTH_AMERICA,   // #70 - Greenland
      CONTINENT_AFRICA,          // #71 - Gambia
      CONTINENT_AFRICA,          // #72 - Guinea
      CONTINENT_AFRICA,          // #73 - Equatorial Guinea
      CONTINENT_EUROPE,          // #74 - Greece
      CONTINENT_NORTH_AMERICA,   // #75 - Guatemala
      CONTINENT_AFRICA,          // #76 - Guinea-Bissau
      CONTINENT_SOUTH_AMERICA,   // #77 - Guyana
      CONTINENT_ASIA,            // #78 - Hong Kong
      CONTINENT_NORTH_AMERICA,   // #79 - Honduras
      CONTINENT_EUROPE,          // #80 - Croatia
      CONTINENT_NORTH_AMERICA,   // #81 - Haiti
      CONTINENT_EUROPE,          // #82 - Hungary
      CONTINENT_ASIA,            // #83 - Indonesia
      CONTINENT_EUROPE,          // #84 - Ireland
      CONTINENT_ASIA,            // #85 - Israel
      CONTINENT_ASIA,            // #86 - India
      CONTINENT_ASIA,            // #87 - Iraq
      CONTINENT_ASIA,            // #88 - Iran
      CONTINENT_EUROPE,          // #89 - Iceland
      CONTINENT_EUROPE,          // #90 - Italy
      CONTINENT_NORTH_AMERICA,   // #91 - Jamaica
      CONTINENT_ASIA,            // #92 - Jordan
      CONTINENT_ASIA,            // #93 - Japan
      CONTINENT_AFRICA,          // #94 - Kenya
      CONTINENT_ASIA,            // #95 - Kyrgyzstan
      CONTINENT_ASIA,            // #96 - Cambodia
      CONTINENT_ASIA,            // #97 - Korea (Democratic People's Republic of)
      CONTINENT_ASIA,            // #98 - Korea, Republic of
      CONTINENT_ASIA,            // #99 - Kuwait
      CONTINENT_ASIA,            // #100 - Kazakhstan
      CONTINENT_ASIA,            // #101 - Lao People's Democratic Republic
      CONTINENT_ASIA,            // #102 - Lebanon
      CONTINENT_EUROPE,          // #103 - Liechtenstein
      CONTINENT_ASIA,            // #104 - Sri Lanka
      CONTINENT_AFRICA,          // #105 - Liberia
      CONTINENT_AFRICA,          // #106 - Lesotho
      CONTINENT_EUROPE,          // #107 - Lithuania
      CONTINENT_EUROPE,          // #108 - Luxembourg
      CONTINENT_EUROPE,          // #109 - Latvia
      CONTINENT_AFRICA,          // #110 - Libya
      CONTINENT_AFRICA,          // #111 - Morocco
      CONTINENT_EUROPE,          // #112 - Monaco
      CONTINENT_EUROPE,          // #113 - Moldova
      CONTINENT_EUROPE,          // #114 - Montenegro
      CONTINENT_AFRICA,          // #115 - Madagascar
      CONTINENT_EUROPE,          // #116 - North Macedonia
      CONTINENT_AFRICA,          // #117 - Mali
      CONTINENT_ASIA,            // #118 - Myanmar
      CONTINENT_ASIA,            // #119 - Mongolia
      CONTINENT_AFRICA,          // #120 - Mauritania
      CONTINENT_EUROPE,          // #121 - Malta
      CONTINENT_AFRICA,          // #122 - Mauritius
      CONTINENT_ASIA,            // #123 - Maldives
      CONTINENT_AFRICA,          // #124 - Malawi
      CONTINENT_NORTH_AMERICA,   // #125 - Mexico
      CONTINENT_ASIA,            // #126 - Malaysia
      CONTINENT_AFRICA,          // #127 - Mozambique
      CONTINENT_AFRICA,          // #128 - Namibia
      CONTINENT_AUSTRALIA_OCEANIA,// #129 - New Caledonia
      CONTINENT_AFRICA,          // #130 - Niger
      CONTINENT_AFRICA,          // #131 - Nigeria
      CONTINENT_NORTH_AMERICA,   // #132 - Nicaragua
      CONTINENT_EUROPE,          // #133 - Netherlands
      CONTINENT_EUROPE,          // #134 - Norway
      CONTINENT_ASIA,            // #135 - Nepal
      CONTINENT_AUSTRALIA_OCEANIA,// #136 - New Zealand
      CONTINENT_ASIA,            // #137 - Oman
      CONTINENT_NORTH_AMERICA,   // #138 - Panama
      CONTINENT_SOUTH_AMERICA,   // #139 - Peru
      CONTINENT_AUSTRALIA_OCEANIA,// #140 - Papua New Guinea
      CONTINENT_ASIA,            // #141 - Philippines
      CONTINENT_ASIA,            // #142 - Pakistan
      CONTINENT_EUROPE,          // #143 - Poland
      CONTINENT_NORTH_AMERICA,   // #144 - Puerto Rico
      CONTINENT_ASIA,            // #145 - Palestine
      CONTINENT_EUROPE,          // #146 - Portugal
      CONTINENT_SOUTH_AMERICA,   // #147 - Paraguay
      CONTINENT_ASIA,            // #148 - Qatar
      CONTINENT_EUROPE,          // #149 - Romania
      CONTINENT_EUROPE,          // #150 - Serbia
      CONTINENT_EUROPE,          // #151 - Russian Federation
      CONTINENT_AFRICA,          // #152 - Rwanda
      CONTINENT_ASIA,            // #153 - Saudi Arabia
      CONTINENT_AUSTRALIA_OCEANIA,// #154 - Solomon Islands
      CONTINENT_AFRICA,          // #155 - Seychelles
      CONTINENT_AFRICA,          // #156 - Sudan
      CONTINENT_EUROPE,          // #157 - Sweden
      CONTINENT_ASIA,            // #158 - Singapore
      CONTINENT_EUROPE,          // #159 - Slovenia
      CONTINENT_EUROPE,          // #160 - Slovakia
      CONTINENT_AFRICA,          // #161 - Sierra Leone
      CONTINENT_EUROPE,          // #162 - San Marino
      CONTINENT_AFRICA,          // #163 - Senegal
      CONTINENT_AFRICA,          // #164 - Somalia
      CONTINENT_SOUTH_AMERICA,   // #165 - Suriname
      CONTINENT_AFRICA,          // #166 - South Sudan
      CONTINENT_AFRICA,          // #167 - Sao Tome and Principe
      CONTINENT_NORTH_AMERICA,   // #168 - El Salvador
      CONTINENT_ASIA,            // #169 - Syrian Arab Republic
      CONTINENT_AFRICA,          // #170 - Eswatini
      CONTINENT_AFRICA,          // #171 - Chad
      CONTINENT_AFRICA,          // #172 - Togo
      CONTINENT_ASIA,            // #173 - Thailand
      CONTINENT_ASIA,            // #174 - Tajikistan
      CONTINENT_ASIA,            // #175 - Turkmenistan
      CONTINENT_AFRICA,          // #176 - Tunisia
      CONTINENT_AUSTRALIA_OCEANIA,// #177 - Tonga
      CONTINENT_ASIA,            // #178 - Turkey
      CONTINENT_SOUTH_AMERICA,   // #179 Trinidad and Tobago
      CONTINENT_ASIA,            // #180 - Taiwan
      CONTINENT_AFRICA,          // #181 - Tanzania
      CONTINENT_EUROPE,          // #182 - Ukraine
      CONTINENT_AFRICA,          // #183 - Uganda
      CONTINENT_NORTH_AMERICA,   // #184 - United States of America
      CONTINENT_SOUTH_AMERICA,   // #185 - Uruguay
      CONTINENT_ASIA,            // #186 - Uzbekistan
      CONTINENT_EUROPE,          // #187 - Vatican
      CONTINENT_NORTH_AMERICA,   // #188 - Saint Vincent and the Grenadines
      CONTINENT_SOUTH_AMERICA,   // #189 - Venezuela
      CONTINENT_NORTH_AMERICA,   // #190 - Virgin Islands (British)
      CONTINENT_NORTH_AMERICA,   // #191 - Virgin Islands (U.S.)
      CONTINENT_ASIA,            // #192 - Viet Nam
      CONTINENT_WORLD,           // #193 - Worldwide
      CONTINENT_ASIA,            // #194 - Yemen
      CONTINENT_AFRICA,          // #195 - South Africa
      CONTINENT_AFRICA,          // #196 - Zambia
      CONTINENT_AFRICA           // #197 - Zimbabwe
     };
//---
   for(int c_idx = 0; c_idx < COUNTRIES_NUM; c_idx++)
     {
      string curr_code = Codes[c_idx];
      if(!::StringCompare(curr_code, _src_country_code))
        {
         code = curr_code;
         country = Countries[c_idx];
         continent = Continents[c_idx];
         string char_codes[2];
         char_codes[0] =::StringSubstr(curr_code, 0, 1);
         char_codes[1] =::StringSubstr(curr_code, 1, 1);
         string temp_ucode = NULL;
         if(!::StringCompare(char_codes[0], "W"))
            if(!::StringCompare(char_codes[1], "W"))
              {
               temp_ucode = "\xF310";
              }
         if(temp_ucode == NULL)
            for(int l_idx = 0; l_idx <::ArraySize(char_codes); l_idx++)
              {
               string curr_char = char_codes[l_idx];
               ushort abcd_start = 65;
               for(int l_jdx = 0; l_jdx < 26; l_jdx++)
                 {
                  string curr_abcd_str =::ShortToString(abcd_start);
                  if(!::StringCompare(curr_abcd_str, curr_char))
                    {
                     temp_ucode += Flag_codes[l_jdx];
                     break;
                    }
                  abcd_start++;
                 }
              }
         if(temp_ucode != NULL)
           {
            unicode = temp_ucode;
           }
         return true;
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Continent description                                            |
//+------------------------------------------------------------------+
string SCountryByContinent::ContinentDescription(void) const
  {
   string res_str = NULL;
//---
   switch(continent)
     {
      case CONTINENT_WORLD:
        {
         res_str = "World";
         break;
        }
      case CONTINENT_ASIA:
        {
         res_str = "Asia";
         break;
        }
      case CONTINENT_AFRICA:
        {
         res_str = "Africa";
         break;
        }
      case CONTINENT_EUROPE:
        {
         res_str = "Europe";
         break;
        }
      case CONTINENT_NORTH_AMERICA:
        {
         res_str = "North America";
         break;
        }
      case CONTINENT_SOUTH_AMERICA:
        {
         res_str = "South America";
         break;
        }
      case CONTINENT_AUSTRALIA_OCEANIA:
        {
         res_str = "Australia/Oceania";
         break;
        }
      case CONTINENT_ANTARCTICA:
        {
         res_str = "Antarctica";
         break;
        }
     }
   return res_str;
  };
//+------------------------------------------------------------------+
//| Continent by description                                         |
//+------------------------------------------------------------------+
ENUM_CONTINENT SCountryByContinent::ContinentByDescription(const string _src_description)
  {
   ENUM_CONTINENT res_continent = WRONG_VALUE;
   string descriptions[8] =
     {
      "World",
      "Asia",
      "Africa",
      "Europe",
      "North America",
      "South America",
      "Australia/Oceania",
      "Antarctica"
     };
   ENUM_CONTINENT continents[8] =
     {
      CONTINENT_WORLD,
      CONTINENT_ASIA,
      CONTINENT_AFRICA,
      CONTINENT_EUROPE,
      CONTINENT_NORTH_AMERICA,
      CONTINENT_SOUTH_AMERICA,
      CONTINENT_AUSTRALIA_OCEANIA,
      CONTINENT_ANTARCTICA
     };
   for(int ct_idx = 0; ct_idx < 8; ct_idx++)
      if(!::StringCompare(descriptions[ct_idx], _src_description))
        {
         res_continent = continents[ct_idx];
         break;
        }
   return res_continent;
  }
//+------------------------------------------------------------------+
//--- [EOF]
