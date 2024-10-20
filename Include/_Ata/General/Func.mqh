//+------------------------------------------------------------------+
//|                                                       Mocros.mqh |
//|                                    Copyright 2024, Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property strict
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CFunc
 {
public:
  //template<typename T>
  //static bool        AddToArray(const T _element, T &_array[])
  // {
  //  uint size = _array.Size();
  //  if(::ArrayResize(_array, size + 1) != size + 1)
  //    return false;
  //  _array[size] = _element;
  //  return true;
  // }
  static bool        AddToArray(const ulong _element, ulong &_array[])
   {
    uint size = _array.Size();
    if(::ArrayResize(_array, size + 1) != size + 1)
      return false;
    _array[size] = _element;
    return true;
   }
  //+------------------------------------------------------------------+
  //| Check Is Tex Symbol                                              |
  //+------------------------------------------------------------------+
  static bool        IsSymbol(const string _symbol)
   {
    bool is_custom = true;
    if(!::SymbolExist(_symbol, is_custom))
      return false;
    if(is_custom)
      return false;
    //--- succeed
    return true;
   }
  //+------------------------------------------------------------------+
  //| Safe Expert Remove                                               |
  //+------------------------------------------------------------------+
  static void        SafeExpertRemove(const string _message = NULL)
   {
    if(_message != NULL && _message != "")
      ::Alert(_message);
    ::ExpertRemove();
   }
  //+------------------------------------------------------------------+
  //| Safe Divide                                                      |
  //+------------------------------------------------------------------+
  static double      SafeDivide(const double _value, const double _divider)
   {
    if(::MathAbs(_value) <= FLT_EPSILON)
      return 0.0;
    if(_divider == 0)
      return 0.0;
    return _value / _divider;
   }
  //+------------------------------------------------------------------+
  //| Safe Percent                                                     |
  //+------------------------------------------------------------------+
  static double      SafePercent(const double _value, const double _divider)
   {
    return SafeDivide(_value, _divider) * 100;
   }
  //+------------------------------------------------------------------+
  //| 34256454.23 => 34,256,454.23                                     |
  //+------------------------------------------------------------------+
  static string      FormatNumber(double _numb, int _degit = 2, string _unit = "", string _delim = ",", string _dec = ".")
   {
    string numb = ::DoubleToString(_numb, _degit),
           nnumb,
           enumb;

    int pos = StringFind(numb, _dec);
    if(pos == -1)
     {
      nnumb = numb;
      enumb = "";
     }
    else
     {
      nnumb = StringSubstr(numb, 0, pos);
      enumb = StringSubstr(numb, pos);
     }

    int cnt = StringLen(nnumb);
    if(cnt < 4)
      if(_unit != NULL && _unit != "")
        return(numb + " " + _unit);
      else
        return(numb);

    int x = (int)MathFloor(cnt / 3);
    int y = cnt - x * 3;

    string forma = "";
    if(y != 0)
      forma = ::StringSubstr(nnumb, 0, y) + _delim;

    for(int i = 0; i < x; i++)
     {
      if(i != x - 1)
        forma += ::StringSubstr(nnumb, y + i * 3, 3) + _delim;
      else
        forma += ::StringSubstr(nnumb, y + i * 3, 3);
     }
    if(_unit != NULL && _unit != "")
      forma += enumb + " " + _unit;
    else
      forma += enumb;

    return(forma);
   }
  //+------------------------------------------------------------------+
  //| Array To Hex                                                     |
  //+------------------------------------------------------------------+
  static string      ArrayToHex(uchar &_arr[], int _count = -1, bool _is_low = false)
   {
    string res = "";
    //--- check
    if(_count < 0 || _count > ArraySize(_arr))
      _count = ArraySize(_arr);
    //--- transform to HEX string
    string format = _is_low ? "%.2x" : "%.2X";
    for(int i = 0; i < _count; i++)
      res += StringFormat(format, _arr[i]);
    //---
    return(res);
   }
  //+------------------------------------------------------------------+
  //| Hex To Array                                                     |
  //+------------------------------------------------------------------+
  static void        HexToArray(string _hex, uchar &_arr[])
   {
    for(uint i = 0; i < _hex.Length(); i += 2)
     {
      ArrayResize(_arr, _arr.Size() + 1);
      _arr[_arr.Size() - 1] = (uchar)HexToInteger(StringSubstr(_hex, i, 2));
     }
   }
  //+------------------------------------------------------------------+
  //| Hex To Integer                                                   |
  //+------------------------------------------------------------------+
  static int         HexToInteger(string _str)
   {
    int result = 0;
    int power = 0;
    for(int pos = StringLen(_str) - 1; pos >= 0; pos--)
     {

      int c = StringGetCharacter(_str, pos);
      int value = 0;
      if(c >= '0' && c <= '9')
        value = c - '0';
      else
        if(c >= 'a' && c <= 'f')
          value = c - 'a' + 10;
        else
          if(c >= 'A' && c <= 'F')
            value = c - 'A' + 10;

      result += int(value * MathPow(16.0, power));
      power++;
     }
    return(result);
   }
  //+------------------------------------------------------------------+
  //| convert integer to string contained input's hexadecimal notation |
  //+------------------------------------------------------------------+
  static string      IntegerToHex(int integer_number)
   {
    string hex_string = "00000000";
    int    value, shift = 28;
    //---
    for(int i = 0; i < 8; i++)
     {
      value = (integer_number >> shift) & 0x0F;
      if(value < 10)
        bool check = StringSetCharacter(hex_string, i, ushort(value + '0'));
      else
        bool check = StringSetCharacter(hex_string, i, ushort((value - 10) + 'A'));
      shift -= 4;
     }
    //---
    return(hex_string);
   }
  //+------------------------------------------------------------------+
  //| Text To CharArray                                                |
  //+------------------------------------------------------------------+
  static void        TextToCharArray(const string _text, uchar &_array[], uint _code_page = CP_MACCP)
   {
    ::ArrayFree(_array);
    ::StringToCharArray(_text, _array, 0, ::StringLen(_text), _code_page);
   }
  //+------------------------------------------------------------------+
  //| convert red, green and blue values to color                      |
  //+------------------------------------------------------------------+
  static int         RGB(int red_value, int green_value, int blue_value)
   {
    //--- check parameters
    if(red_value < 0)
      red_value = 0;
    if(red_value > 255)
      red_value = 255;
    if(green_value < 0)
      green_value = 0;
    if(green_value > 255)
      green_value = 255;
    if(blue_value < 0)
      blue_value = 0;
    if(blue_value > 255)
      blue_value = 255;
    //---
    green_value <<= 8;
    blue_value <<= 16;
    return(red_value + green_value + blue_value);
   }
  //+------------------------------------------------------------------+
  //| right comparison of 2 doubles                                    |
  //+------------------------------------------------------------------+
  static bool        CompareDoubles(double number1, double number2)
   {
    if(NormalizeDouble(number1 - number2, 8) == 0)
      return(true);
    else
      return(false);
   }
  //+------------------------------------------------------------------+
  //| up to 16 digits after decimal point                              |
  //+------------------------------------------------------------------+
  static string      DoubleToStrMorePrecision(double number, int precision)
   {
    static double DecimalArray[17] =
     {
      1.0,
      10.0,
      100.0,
      1000.0,
      10000.0,
      100000.0,
      1000000.0,
      10000000.0,
      100000000.0,
      1000000000.0,
      10000000000.0,
      100000000000.0,
      1000000000000.0,
      10000000000000.0,
      100000000000000.0,
      1000000000000000.0,
      10000000000000000.0
     };

    double rem, integer, integer2;
    string intstring, remstring, retstring;
    bool   isnegative = false;
    int    rem2;
    //---
    if(precision < 0)
      precision = 0;
    if(precision > 16)
      precision = 16;
    //---
    double p = DecimalArray[precision];
    if(number < 0.0)
     {
      isnegative = true;
      number = -number;
     }
    integer = MathFloor(number);
    rem = MathRound((number - integer) * p);
    remstring = "";
    for(int i = 0; i < precision; i++)
     {
      integer2 = MathFloor(rem / 10);
      rem2 = (int)NormalizeDouble(rem - integer2 * 10, 0);
      remstring = IntegerToString(rem2) + remstring;
      rem = integer2;
     }
    //---
    intstring = DoubleToString(integer, 0);
    if(isnegative)
      retstring = "-" + intstring;
    else
      retstring = intstring;

    if(precision > 0)
      retstring = retstring + "." + remstring;
    //---
    return(retstring);
   }
 };
//+------------------------------------------------------------------+
