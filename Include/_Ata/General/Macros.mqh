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
//template<typename T> 
//bool FnIsValidPointer(T *_obj) { if(::CheckPointer(_obj) == POINTER_DYNAMIC) return true; else return false;}
//+------------------------------------------------------------------+
//| Macro                                                            |
//+------------------------------------------------------------------+
#define IS_POINTER_DYNAMIC(P) (::CheckPointer(P) == POINTER_DYNAMIC)
#define FREE(P) if(::CheckPointer(P) == POINTER_DYNAMIC) delete (P);
#define STR_TIME_MSC(T) (TimeToString((T) / 1000, TIME_DATE|TIME_SECONDS) + StringFormat("'%03d", (T) % 1000))
//#define PUSH(A,V) (A[ArrayResize(A, ArrayRange(A, 0) + 1, ArrayRange(A, 0) * 2) - 1] = V)
#define EXPAND(A) (ArrayResize(A, ArrayRange(A, 0) + 1, ArrayRange(A, 0) * 2) - 1)
#define IS_EMPTY_STRING(S) (S == NULL || S == "")
//+------------------------------------------------------------------+
