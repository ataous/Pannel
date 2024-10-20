//+------------------------------------------------------------------+
//|                                                        Crypt.mqh |
//|                                     Copyright 2022,Akbar Atalou. |
//|                                       https://t.me/ProTraderSoft |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022,Akbar Atalou."
#property link      "https://t.me/ProTraderSoft"
#property version   "1.00"
#property strict

/*
"WARNING: hashes can not be used to restore data! CryptDecode will fail."
/---
Electronic Codebook(ECB) encryption mode and Padding equal to zero

Note 1:
in AES - 128 the key maximum size is 16 bytes, if the size is minor then 16, fill the remaining bytes with zeros;
Note 2:
in DES the key maximum size is 8, if the size is minor then 8, fill the remaining bytes with zeros and the last byte must be zero too.
Note 3:
in DES the size of the text must be multiple of 8 with the extra bytes filled by zero;

Configuration for AES - 128(C# code) :--------------------------------------
byte[] arrKey = Encoding.UTF8.GetBytes(key);
if(arrKey.Length != 16)
  Array.Resize(ref arrKey, 16);

using(Aes aesAlg = Aes.Create())
 {
  aesAlg.Mode = CipherMode.ECB;
  aesAlg.Padding = PaddingMode.Zeros;
  aesAlg.BlockSize = 128;
  aesAlg.KeySize = 128;
  aesAlg.Key = arrKey;
  aesAlg.IV = new byte[16];
 }
----------------------------------------------------------------------------
Configuration for DES(C# code) :--------------------------------------------

// Encode and check message and password
byte[] arrText = Encoding.UTF8.GetBytes(originalString);
byte[] arrKey = Encoding.UTF8.GetBytes(keyString);

if (arrKey.Length != 8) Array.Resize(ref arrKey, 8);
arrKey[7] = 0;

if (arrText.Length % 8 == 0) Array.Resize(ref arrText, arrText.Length + 8);

// Set encryption settings
DESCryptoServiceProvider provider = new DESCryptoServiceProvider();
provider.Mode = CipherMode.ECB;
provider.Padding = PaddingMode.Zeros;
provider.BlockSize = 64;
provider.KeySize = 64;
provider.Key = arrKey;
provider.IV = new byte[8];
*/
#include <ErrorDescription.mqh>
#include "Func.mqh"
#define DEF_CRYPT_CODE_PAGE     CP_MACCP
/*
CP_ACP         0     The current Windows ANSI code page.
CP_OEMCP       1     The current system OEM code page.
CP_MACCP       2     The current system Macintosh code page.   Note: This value is mostly used in earlier created program codes and is of no use now, since modern Macintosh computers use Unicode for encoding.
CP_THREAD_ACP  3     The Windows ANSI code page for the current thread.
CP_SYMBOL      42    Symbol code page
CP_UTF7        65000 UTF-7 code page.
CP_UTF8        65001 UTF-8 code page.
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCrypt
 {
private:
  enum ENUM_CRYPT_REDABLE_METHOD
   {
    REDABLE_NONE,
    REDABLE_HEX,
    REDABLE_HEX_LOW,
    REDABLE_BASE64
   };
  //------------------------------------------------------------------
  static bool        IsKeyCorrect(ENUM_CRYPT_METHOD _method, string _key)
   {
    int len = ::StringLen(_key);
    switch(_method)
     {
      case CRYPT_AES128:
        if(len != 16)
          return false;
        break;
      case CRYPT_AES256:
        if(len != 32)
          return false;
        break;
      case CRYPT_DES:
        if(len != 7)
          return false;
        break;
     }
    return true;
   }
  //------------------------------------------------------------------
  static string      CorrectKey(string _key, uint _len)
   {
    uint len = ::StringLen(_key);
    for(uint i = len; i < _len; i++)
      _key += "=";
    //--
    return ::StringSubstr(_key, 0, _len);
   }
  //------------------------------------------------------------------
  static int         EnCode(uchar            &_result[],
                            ENUM_CRYPT_METHOD _method,
                            string            _key,
                            uchar            &_data[])
   {
    if(!IsKeyCorrect(_method, _key))
      return 0;

    uchar key[];
    CFunc::TextToCharArray(_key, key);

    ::ArrayFree(_result);
    ::ResetLastError();

    int res = ::CryptEncode(_method, _data, key, _result);

    if(res <= 0)
      Print(__FUNCSIG__, " :: ", ErrorDescription(_LastError), " Code: ", (string)_LastError);

    return res;
   }
  //------------------------------------------------------------------
  static int         EnCode(uchar            &_result[],
                            ENUM_CRYPT_METHOD _method,
                            string           _key,
                            string           _text)
   {
    uchar data[];
    CFunc::TextToCharArray(_text, data);

    return EnCode(_result, _method, _key, data);
   };
  //------------------------------------------------------------------
  static string      EnCodeToString(ENUM_CRYPT_METHOD          _method,
                                    string                     _key,
                                    string                     _text,
                                    ENUM_CRYPT_REDABLE_METHOD  _readbling = REDABLE_HEX)
   {
    uchar result[];
    if(EnCode(result, _method, _key, _text))
     {
      if(_readbling == REDABLE_HEX)
        return CFunc::ArrayToHex(result);
      if(_readbling == REDABLE_HEX_LOW)
        return CFunc::ArrayToHex(result, -1, true);
      if(_readbling == REDABLE_BASE64)
       {
        uchar base64[];
        if(EnCode(base64, CRYPT_BASE64, NULL, result))
          return ::CharArrayToString(base64, 0, WHOLE_ARRAY, DEF_CRYPT_CODE_PAGE);
       }
      return ::CharArrayToString(result, 0, WHOLE_ARRAY, DEF_CRYPT_CODE_PAGE);
     }
    return NULL;
   }
  //------------------------------------------------------------------
  static int         DeCode(uchar            &_result[],
                            ENUM_CRYPT_METHOD _method,
                            string           _key,
                            uchar            &_data[])
   {
    if(!IsKeyCorrect(_method, _key))
      return 0;

    uchar key[];
    CFunc::TextToCharArray(_key, key);

    ::ArrayFree(_result);
    ::ResetLastError();

    int res = ::CryptDecode(_method, _data, key, _result);

    if(res <= 0)
      Print(__FUNCSIG__, " :: ", ErrorDescription(_LastError), " Code: ", (string)_LastError);

    return res;
   }
  //------------------------------------------------------------------
  static int         DeCode(uchar                    &_result[],
                            ENUM_CRYPT_METHOD         _method,
                            string                    _key,
                            string                    _hash,
                            ENUM_CRYPT_REDABLE_METHOD _readbling = REDABLE_HEX)
   {
    uchar data[];
    switch(_readbling)
     {
      case REDABLE_HEX :
      case REDABLE_HEX_LOW :
        CFunc::HexToArray(_hash, data);
        break;
      case REDABLE_BASE64 :
        DeCode(data, CRYPT_BASE64, NULL, _hash, REDABLE_NONE);
        break;
      default:
        CFunc::TextToCharArray(_hash, data);
        break;
     }

    ::ArrayFree(_result);
    ::ResetLastError();

    return DeCode(_result, _method, _key, data);
   };
  //------------------------------------------------------------------
  static string      DeCodeToString(ENUM_CRYPT_METHOD         _method,
                                    string                    _key,
                                    string                    _hash,
                                    ENUM_CRYPT_REDABLE_METHOD _readbling = REDABLE_HEX)
   {
    uchar result[];
    if(DeCode(result, _method, _key, _hash, _readbling))
      return ::CharArrayToString(result, 0, WHOLE_ARRAY, DEF_CRYPT_CODE_PAGE);
    return NULL;
   }

public :
                     CCrypt(void) {};
                    ~CCrypt(void) {};
  //--- EnCrypt
  static string      DES(const string _text, const string _key7)              { return EnCodeToString(CRYPT_DES, _key7, _text, REDABLE_NONE);}
  static string      AES128(const string _text, const string _key16)          { return EnCodeToString(CRYPT_AES128, _key16, _text, REDABLE_NONE);}
  static string      AES256(const string _text, const string _key32)          { return EnCodeToString(CRYPT_AES256, _key32, _text, REDABLE_NONE);}
  static string      Base64(const string _text)                               { return EnCodeToString(CRYPT_BASE64, NULL, _text, REDABLE_NONE);}
  //---
  static string      DES_Hex(const string _text, const string _key7)          { return EnCodeToString(CRYPT_DES, _key7, _text, REDABLE_HEX);}
  static string      AES128_Hex(const string _text, const string _key16)      { return EnCodeToString(CRYPT_AES128, _key16, _text, REDABLE_HEX);}
  static string      AES256_Hex(const string _text, const string _key32)      { return EnCodeToString(CRYPT_AES256, _key32, _text, REDABLE_HEX);}
  static string      Base64_Hex(const string _text)                           { return EnCodeToString(CRYPT_BASE64, NULL, _text, REDABLE_HEX);}
  //---
  static string      DES_HexLow(const string _text, const string _key7)       { return EnCodeToString(CRYPT_DES, _key7, _text, REDABLE_HEX_LOW);}
  static string      AES128_HexLow(const string _text, const string _key16)   { return EnCodeToString(CRYPT_AES128, _key16, _text, REDABLE_HEX_LOW);}
  static string      AES256_HexLow(const string _text, const string _key32)   { return EnCodeToString(CRYPT_AES256, _key32, _text, REDABLE_HEX_LOW);}
  static string      Base64_HexLow(const string _text)                        { return EnCodeToString(CRYPT_BASE64, NULL, _text, REDABLE_HEX_LOW);}
  //---
  static string      DES_BASE64(const string _text, const string _key7)       { return EnCodeToString(CRYPT_DES, _key7, _text, REDABLE_BASE64);}
  static string      AES128_BASE64(const string _text, const string _key16)   { return EnCodeToString(CRYPT_AES128, _key16, _text, REDABLE_BASE64);}
  static string      AES256_BASE64(const string _text, const string _key32)   { return EnCodeToString(CRYPT_AES256, _key32, _text, REDABLE_BASE64);}
  //--- DeCrypt
  static string      DeDES(const string _hash, const string _key7)            { return DeCodeToString(CRYPT_DES, _key7, _hash, REDABLE_NONE);}
  static string      DeAES128(const string _hash, const string _key16)        { return DeCodeToString(CRYPT_AES128, _key16, _hash, REDABLE_NONE);}
  static string      DeAES256(const string _hash, const string _key32)        { return DeCodeToString(CRYPT_AES256, _key32, _hash, REDABLE_NONE);}
  static string      DeBase64(const string _hash)                             { return DeCodeToString(CRYPT_BASE64, NULL, _hash, REDABLE_NONE);}
  //---
  static string      DeDES_Hex(const string _hash, const string _key7)        { return DeCodeToString(CRYPT_DES, _key7, _hash, REDABLE_HEX);}
  static string      DeAES128_Hex(const string _hash, const string _key16)    { return DeCodeToString(CRYPT_AES128, _key16, _hash, REDABLE_HEX);}
  static string      DeAES256_Hex(const string _hash, const string _key32)    { return DeCodeToString(CRYPT_AES256, _key32, _hash, REDABLE_HEX);}
  static string      DeBase64_Hex(const string _hash)                         { return DeCodeToString(CRYPT_BASE64, NULL, _hash, REDABLE_HEX);}
  //---
  static string      DeDES_HexLow(const string _hash, const string _key7)     { return DeCodeToString(CRYPT_DES, _key7, _hash, REDABLE_HEX_LOW);}
  static string      DeAES128_HexLow(const string _hash, const string _key16) { return DeCodeToString(CRYPT_AES128, _key16, _hash, REDABLE_HEX_LOW);}
  static string      DeAES256_HexLow(const string _hash, const string _key32) { return DeCodeToString(CRYPT_AES256, _key32, _hash, REDABLE_HEX_LOW);}
  static string      DeBase64_HexLow(const string _hash)                      { return DeCodeToString(CRYPT_BASE64, NULL, _hash, REDABLE_HEX_LOW);}
  //---
  static string      DeDES_BASE64(const string _hash, const string _key7)     { return DeCodeToString(CRYPT_DES, _key7, _hash, REDABLE_BASE64);}
  static string      DeAES128_BASE64(const string _hash, const string _key16) { return DeCodeToString(CRYPT_AES128, _key16, _hash, REDABLE_BASE64);}
  static string      DeAES256_BASE64(const string _hash, const string _key32) { return DeCodeToString(CRYPT_AES256, _key32, _hash, REDABLE_BASE64);}
  //--- Hash
  static string      MD5(const string _text)                                  { return EnCodeToString(CRYPT_HASH_MD5, NULL, _text, REDABLE_NONE);}
  static string      SHA1(const string _text)                                 { return EnCodeToString(CRYPT_HASH_SHA1, NULL, _text, REDABLE_NONE);}
  static string      SHA256(const string _text)                               { return EnCodeToString(CRYPT_HASH_SHA256, NULL, _text, REDABLE_NONE);}
  //---
  static string      MD5_Hex(const string _text)                              { return EnCodeToString(CRYPT_HASH_MD5, NULL, _text, REDABLE_HEX);}
  static string      SHA1_Hex(const string _text)                             { return EnCodeToString(CRYPT_HASH_SHA1, NULL, _text, REDABLE_HEX);}
  static string      SHA256_Hex(const string _text)                           { return EnCodeToString(CRYPT_HASH_SHA256, NULL, _text, REDABLE_HEX);}
  //---
  static string      MD5_HexLow(const string _text)                           { return EnCodeToString(CRYPT_HASH_MD5, NULL, _text, REDABLE_HEX_LOW);}
  static string      SHA1_HexLow(const string _text)                          { return EnCodeToString(CRYPT_HASH_SHA1, NULL, _text, REDABLE_HEX_LOW);}
  static string      SHA256_HexLow(const string _text)                        { return EnCodeToString(CRYPT_HASH_SHA256, NULL, _text, REDABLE_HEX_LOW);}
  //---
  static string      MD5_BASE64(const string _text)                           { return EnCodeToString(CRYPT_HASH_MD5, NULL, _text, REDABLE_BASE64);}
  static string      SHA1_BASE64(const string _text)                          { return EnCodeToString(CRYPT_HASH_SHA1, NULL, _text, REDABLE_BASE64);}
  static string      SHA256_BASE64(const string _text)                        { return EnCodeToString(CRYPT_HASH_SHA256, NULL, _text, REDABLE_BASE64);}
  //----
  static string      HashID(string &_arr[], string _seprator = "|")
   {
    string text = NULL;
    for(uint i = 0; i < _arr.Size(); i++)
     {
      if(i != 0)
        text += _seprator;
      text += _arr[i];
     }
    return DES_BASE64(text,"A6jkdW7");
   }

  static string      HashID(string _text)
   {
    string arr[1] = { _text };
    return HashID(arr);
   }

  static string      DbEnCrypt(const string _text)                            { return (_text == NULL || _text == "") ? NULL : Base64(_text);}
  static string      DbDeCrypt(const string _hash)                            { return (_hash == NULL || _hash == "") ? NULL : DeBase64(_hash);}

  static string      MyEnCrypt(const string _text, const string _key32)       { return (_text == NULL || _text == "") ? NULL : AES256_Hex(_text, CorrectKey(_key32, 32));}
  static string      MyDeCrypt(const string _hash, const string _key32)       { return (_hash == NULL || _hash == "") ? NULL : DeAES256_Hex(_hash, CorrectKey(_key32, 32));}
 };
//+------------------------------------------------------------------+
#undef DEF_CRYPT_CODE_PAGE
//+------------------------------------------------------------------+
