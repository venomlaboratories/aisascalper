//+------------------------------------------------------------------+
//|                                              POISON_IVY_NF1.mq5  |
//|                          Copyright © "Jeanette Abou Khalil"      |
//|                                      MT5 CONVERSION - v6.1       |
//|                                                                   |
//| CRITICAL: This EA requires HEDGING account mode in MT5           |
//| Set in Tools -> Options -> Trade -> Account Type -> Hedging      |
//|                                                                   |
//| Original MT4 version converted to MT5 with 100% identical logic  |
//| All entry/exit conditions, grid logic, and parameters preserved  |
//+------------------------------------------------------------------+
#property strict
#property version   "6.1"
#property description "Poison Ivy v6.1 MT5 - By Jeanette Abou Khalil"
#property description "Allow web request: https://nfs.faireconomy.media and https://www.dailyfx.com"
#property description "REQUIRES HEDGING ACCOUNT MODE"

input string Name = "Poison Ivy";
input string Copyright = "Jeanette Abou Khalil";

// ===== Inputs (original names kept) =====
input int    MagicNumber   = 12023;
input double Risk_Percent  = 0.01;
double        MinProfit     = 0.0;     // hidden
input int    Distance      = 6;       // Distance in pips
input int    Step_in_pips  = 15;      // Steps in pips
input int    FROM          = 5;       // Time From hour
input int    TO            = 7;      // Time to hour
input double Multi_Size    = 1;       // multiplier

// Lines renamed + default colors
input color  FlipUpLineColor   = clrBlue;
input color  FlipDownLineColor = clrWhite;

// --- Stop/TP in account currency ---
input double StopLossDollars   = 5000.0;
input double TakeProfitDollars = 5000.0;

// --- Enable/Disable Trading by Day (gates new entries only) ---
input bool EnableMonday    = true;
input bool EnableTuesday   = true;
input bool EnableWednesday = true;
input bool EnableThursday  = true;
input bool EnableFriday    = true;
input bool EnableSaturday  = true;
input bool EnableSunday    = true;

// === Dashboard layout (fixed; not user-editable; top-left) ===
const int DashCorner   = 0;   // 0 = Top-Left (fixed)
const int DashX        = 10;
const int DashY        = 10;
const int DashWidth    = 460;
const int DashHeight   = 190; // Increased height for new line
const int DashFontSize = 10;

// Manual buttons option
input bool ShowManualBuySell = false;

// Running P/L options
input bool ShowRunningProfit   = true;
input bool RunningPL_AllMagic  = false; // if true, sum all magics for this symbol

// ===== AUTOMATIC NEWS FILTER SETTINGS (MULTI-SOURCE) =====
input string NewsSettings        = "==== News Filter Settings ====";
input bool   UseNewsFilter       = true;
input string PrimaryNewsUrl      = "https://nfs.faireconomy.media/ff_calendar_thisweek.json"; // Primary (Forex Factory)
input string BackupNewsUrl       = "https://www.dailyfx.com/calendar/data";                   // Backup (DailyFX)
input int    NewsRefreshMinutes  = 60;   // Refresh every hour
input bool   Block_On_High_Impact_Day = false; // If true, blocks all trades on days with High impact news
input bool   FilterHigh          = true;
input bool   FilterMedium        = true;
input bool   FilterLow           = false;
// Renamed for clarity as requested
input int    Do_Not_Trade_Before_High_News_in_Mins  = 30;
input int    Start_Trade_After_High_News_in_Mins   = 15;
input int    Do_Not_Trade_Before_Medium_News_in_Mins = 20;
input int    Start_Trade_After_Medium_News_in_Mins = 10;
input int    Do_Not_Trade_Before_Low_News_in_Mins    = 10;
input int    Start_Trade_After_Low_News_in_Mins      = 5;
bool   DebugNewsFilter     = false; // Hidden from user inputs

// ===== Aliases =====
#define Magic      MagicNumber
#define Risk       Risk_Percent
#define Dist       Distance
#define Step       Step_in_pips
#define TimeStart  FROM
#define TimeEnd    TO
#define UpLot      Multi_Size

// === Global Variables for News Filter ===
bool g_news_filter_verified = false;
bool g_news_filter_enabled = true;
datetime g_last_refresh = 0;
datetime g_last_request_attempt = 0;
int g_request_failures = 0;
bool g_initial_load_done = false;
int g_minutes_until_unblock = 0; // For countdown timer
bool g_is_high_impact_day_block = false; // To show correct dashboard message

// News storage
#define MAX_NEWS 256
datetime g_news_time[MAX_NEWS];
int      g_news_imp[MAX_NEWS];
string   g_news_ccy[MAX_NEWS];
string   g_news_title[MAX_NEWS];
int      g_news_count=0;
datetime g_next_news_refresh=0;
bool     g_news_loaded=false;

// -----------------------------------------------------------
// Original Variables (kept from original build)
// -----------------------------------------------------------
double Gd_00000;
int Gi_00001;
double Gd_00002;
int Gi_00003;
int Ii_00050;
int Gi_00004;
double Ind_004;
double Ind_000;
double Gd_00004;
bool returned_b;
long Gl_00004;
int returned_i;
double Gd_00001;
double Gd_00003;
long Gl_00005;
int Gi_00006;
int Gi_00007;
int Gi_00008;
int Gi_00009;
double Gd_0000A;
int Gi_0000B;
long Gl_0000C;
int Gi_0000D;
int Gi_0000E;
int Gi_0000F;
int Gi_00010;
double Gd_00011;
int Gi_00012;
int Gi_00013;
int Gi_00014;
int Gi_00015;
int Gi_00016;
int Gi_00017;
double Gd_00018;
int Gi_00019;
int Gi_0001A;
int Gi_0001B;
double Gd_0001C;
int Gi_0001D;
int Gi_0001E;
int Gi_0001F;
double Gd_00020;
int Gi_00021;
int Gi_00022;
int Gi_00023;
double Gd_00024;
int Gi_00025;
double Gd_00026;
int Gi_00027;
int Gi_00028;
int Gi_00029;
int Gi_0002A;
int Gi_0002B;
int Gi_0002C;
int Gi_0002D;
int Gi_0002E;
int Gi_0002F;
int Gi_00030;
int Gi_00031;
int Gi_00032;
int Gi_00033;
int Gi_00034;
int Gi_00035;
double Gd_00036;
double Gd_00037;
double Ind_002;
double Id_00040;
bool Gb_00037;
double Id_00060;
double Id_00058;
int Gi_00037;
bool Gb_00038;
double Gd_00038;
int Gi_00038;
double Gd_00039;
bool Gb_00039;
int Gi_00039;
double Gd_0003A;
bool Gb_0003A;
int Gi_0003A;
bool Gb_0003B;
double Gd_0003B;
int Gi_0003B;
long returned_l;
int Gi_0003C;
bool Gb_0003D;
double Gd_0003C;
int Gi_0003D;
string Is_00018;
int Ii_0004C;
double Gd_0003D;
int Gi_0003E;
bool Gb_0003F;
double Gd_0003E;
int Gi_0003F;
double Gd_0003F;
double Id_00068;
int Gi_00040;
bool Gb_00041;
double Gd_00040;
int Gi_00041;
double Gd_00041;
int Gi_00042;
bool Gb_00042;
double Gd_00042;
int Gi_00043;
bool Gb_00044;
double Gd_00043;
int Gi_00044;
double Gd_00044;
int Gi_00045;
bool Gb_00045;
double Gd_00045;
double Id_00070;
double Gd_00046;
int Gi_00047;
double Gd_00047;
double Gd_00048;
int Gi_00049;
double Gd_00049;
bool Gb_00049;
double Gd_0004A;
int Gi_0004B;
double Gd_0004B;
double Gd_0004C;
int Gi_0004D;
bool Gb_0004D;
double Gd_0004D;
double Gd_0004E;
int Gi_0004F;
double Gd_0004F;
double Gd_00050;
int Gi_00051;
double Gd_00051;
bool Gb_00051;
double Gd_00052;
int Gi_00053;
double Gd_00053;
double Gd_00054;
int Gi_00055;
bool Ib_00000;
long Gl_00055;
int Ii_0000C;
int Ii_00010;
int Ii_00004;
int Ii_00008;
int Ii_0002C;
int Ii_00024;
int Ii_00030;
int Ii_00028;
int Gi_00000;
long Gl_00000;
int Ii_00034;
int Ii_00038;
int Ii_00048;
double returned_double;
bool order_check;

// =====================================================================
// FIX PACK — MT4 helpers & UI
// =====================================================================

// MT5-specific structures
MqlTradeRequest mrequest;
MqlTradeResult mresult;

// MT5 order type constants compatibility
#define OP_BUY 0
#define OP_SELL 1

// MT5 Helper Functions
double GetAsk() { return SymbolInfoDouble(_Symbol, SYMBOL_ASK); }
double GetBid() { return SymbolInfoDouble(_Symbol, SYMBOL_BID); }

double GetOpen(int index) {
    double open[];
    ArraySetAsSeries(open, true);
    if(CopyOpen(_Symbol, PERIOD_CURRENT, index, 1, open) > 0)
        return open[0];
    return INIT_SUCCEEDED;
}

double GetClose(int index) {
    double close[];
    ArraySetAsSeries(close, true);
    if(CopyClose(_Symbol, PERIOD_CURRENT, index, 1, close) > 0)
        return close[0];
    return INIT_SUCCEEDED;
}

// Market Info wrapper
double MarketInfo(string symbol, int type) {
    switch(type) {
        case 16: return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE); // MODE_TICKVALUE
        case 17: return SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);  // MODE_TICKSIZE
        case 15: return SymbolInfoDouble(symbol, SYMBOL_TRADE_CONTRACT_SIZE); // MODE_LOTSIZE
        case 3:  return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);  // MODE_MINLOT
        case 5:  return SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);  // MODE_MAXLOT
        case 4:  return SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP); // MODE_LOTSTEP
        case 14: return (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_STOPS_LEVEL); // MODE_STOPLEVEL
        case 33: return (double)SymbolInfoInteger(symbol, SYMBOL_TRADE_FREEZE_LEVEL); // MODE_FREEZELEVEL
        case 11: return SymbolInfoDouble(symbol, SYMBOL_BID); // MODE_BID
        case 10: return SymbolInfoDouble(symbol, SYMBOL_ASK); // MODE_ASK
        case 12: return SymbolInfoDouble(symbol, SYMBOL_POINT); // MODE_POINT
        case 13: return (double)SymbolInfoInteger(symbol, SYMBOL_DIGITS); // MODE_DIGITS
        default: return INIT_SUCCEEDED;
    }
}

// Account functions
double AccountBalance() { return AccountInfoDouble(ACCOUNT_BALANCE); }
double AccountEquity() { return AccountInfoDouble(ACCOUNT_EQUITY); }
double AccountFreeMargin() { return AccountInfoDouble(ACCOUNT_MARGIN_FREE); }

// Time functions using MqlDateTime
int TimeHour(datetime time) {
    MqlDateTime tm;
    TimeToStruct(time, tm);
    return tm.hour;
}

int TimeDayOfWeek(datetime time) {
    MqlDateTime tm;
    TimeToStruct(time, tm);
    return tm.day_of_week;
}

int TimeDay(datetime time) {
    MqlDateTime tm;
    TimeToStruct(time, tm);
    return tm.day;
}

int TimeMonth(datetime time) {
    MqlDateTime tm;
    TimeToStruct(time, tm);
    return tm.mon;
}

int TimeYear(datetime time) {
    MqlDateTime tm;
    TimeToStruct(time, tm);
    return tm.year;
}

// OrdersTotal replacement - counts positions for current symbol
int OrdersTotal() {
    int count = 0;
    for(int i = PositionsTotal() - 1; i >= 0; i--) {
        if(PositionGetTicket(i) > 0) {
            if(PositionGetString(POSITION_SYMBOL) == _Symbol)
                count++;
        }
    }
    return count;
}

// OrderSelect replacement for positions
bool OrderSelect(int index, int select_mode, int pool = 0) {
    if(pool == 0) { // MODE_TRADES
        int count = 0;
        for(int i = 0; i < PositionsTotal(); i++) {
            ulong ticket = PositionGetTicket(i);
            if(ticket > 0 && PositionGetString(POSITION_SYMBOL) == _Symbol) {
                if(count == index) return true;
                count++;
            }
        }
        return false;
    } else { // MODE_HISTORY
        // For history, we need to select history first
        datetime from = 0;
        datetime to = TimeCurrent();
        if(!HistorySelect(from, to)) return false;
        
        ulong ticket = HistoryDealGetTicket(index);
        return (ticket > 0);
    }
}

// Order properties for MT5 positions
string OrderSymbol() { return PositionGetString(POSITION_SYMBOL); }
int OrderMagicNumber() { return (int)PositionGetInteger(POSITION_MAGIC); }
int OrderType() { return (int)PositionGetInteger(POSITION_TYPE); }
int OrderTicket() { return (int)PositionGetInteger(POSITION_TICKET); }
double OrderLots() { return PositionGetDouble(POSITION_VOLUME); }
double OrderOpenPrice() { return PositionGetDouble(POSITION_PRICE_OPEN); }
double OrderProfit() { return PositionGetDouble(POSITION_PROFIT); }
double OrderSwap() { return PositionGetDouble(POSITION_SWAP); }
double OrderCommission() { return PositionGetDouble(POSITION_COMMISSION); }
datetime OrderOpenTime() { return (datetime)PositionGetInteger(POSITION_TIME); }

// History functions
int HistoryTotal() {
    if(!HistorySelect(0, TimeCurrent())) return INIT_SUCCEEDED;
    return HistoryDealsTotal();
}

// OrderSend wrapper for MT5
int OrderSend(string symbol, int cmd, double volume, double price, int slippage,
              double stoploss, double takeprofit, string comment, int magic,
              datetime expiration, color arrow_color) {
    ZeroMemory(mrequest);
    ZeroMemory(mresult);
    
    mrequest.action = TRADE_ACTION_DEAL;
    mrequest.symbol = symbol;
    mrequest.volume = volume;
    mrequest.deviation = slippage;
    mrequest.magic = magic;
    mrequest.comment = comment;
    
    if(cmd == OP_BUY) {
        mrequest.type = ORDER_TYPE_BUY;
        mrequest.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        mrequest.sl = stoploss;
        mrequest.tp = takeprofit;
    } else if(cmd == OP_SELL) {
        mrequest.type = ORDER_TYPE_SELL;
        mrequest.price = SymbolInfoDouble(symbol, SYMBOL_BID);
        mrequest.sl = stoploss;
        mrequest.tp = takeprofit;
    } else {
        return -1;
    }
    
    if(!::OrderSend(mrequest, mresult)) {
        Print("OrderSend failed: ", mresult.retcode, " - ", mresult.comment);
        return -1;
    }
    
    if(mresult.retcode == TRADE_RETCODE_DONE || mresult.retcode == TRADE_RETCODE_PLACED)
        return (int)mresult.order;
    
    return -1;
}

// OrderClose wrapper for MT5
bool OrderClose(int ticket, double lots, double price, int slippage, color arrow_color) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    string symbol = PositionGetString(POSITION_SYMBOL);
    long type = PositionGetInteger(POSITION_TYPE);
    double volume = PositionGetDouble(POSITION_VOLUME);
    
    ZeroMemory(mrequest);
    ZeroMemory(mresult);
    
    mrequest.action = TRADE_ACTION_DEAL;
    mrequest.position = ticket;
    mrequest.symbol = symbol;
    mrequest.volume = volume;
    mrequest.deviation = slippage;
    
    if(type == POSITION_TYPE_BUY) {
        mrequest.price = SymbolInfoDouble(symbol, SYMBOL_BID);
        mrequest.type = ORDER_TYPE_SELL;
    } else {
        mrequest.price = SymbolInfoDouble(symbol, SYMBOL_ASK);
        mrequest.type = ORDER_TYPE_BUY;
    }
    
    return ::OrderSend(mrequest, mresult);
}

// OrderModify wrapper for MT5
bool OrderModify(int ticket, double price, double sl, double tp, datetime expiration, color arrow_color) {
    if(!PositionSelectByTicket(ticket)) return false;
    
    ZeroMemory(mrequest);
    ZeroMemory(mresult);
    
    mrequest.action = TRADE_ACTION_SLTP;
    mrequest.position = ticket;
    mrequest.sl = sl;
    mrequest.tp = tp;
    
    return ::OrderSend(mrequest, mresult);
}

// AccountFreeMarginCheck replacement
double AccountFreeMarginCheck(string symbol, int cmd, double volume) {
    double margin;
    if(!OrderCalcMargin((ENUM_ORDER_TYPE)cmd, symbol, volume,
                        SymbolInfoDouble(symbol, cmd == OP_BUY ? SYMBOL_ASK : SYMBOL_BID),
                        margin)) {
        return -1;
    }
    return AccountInfoDouble(ACCOUNT_MARGIN_FREE) - margin;
}


// Global variables (from original MT4)
double
int
double
int
int
int
double
double
double
long
double
double
long
int
int
int
int
double
int
long
int
int
int
int
double
int
int
int
int
int
int
double
int
int
int
double
int
int
int
double
int
int
int
double
int
double
int
int
int
int
int
int
int
int
int
int
int
int
int
int
int
double
double
double
double
bool
double
double
int
bool
double
int
double
bool
int
double
bool
int
bool
double
int
int
bool
double
int
string
int
double
int
bool
double
int
double
double
int
bool
double
int
double
int

// Helper Functions
bool CheckMoneyForTrade(string symb,double lots,int type){
   double fm = AccountFreeMarginCheck(symb,type,lots);
   if(fm<0){ Print("Not enough margin for ",(type==OP_BUY?"Buy":"Sell")," ",DoubleToString(lots,2)," ",symb," err=",GetLastError()); return(false); }
   return(true);
}

double AdjustLots(double lots){
   double step=MarketInfo(Symbol(),MODE_LOTSTEP);
   double minv=MarketInfo(Symbol(),MODE_MINLOT);
   double maxv=MarketInfo(Symbol(),MODE_MAXLOT);
   if(step>0) lots=MathRound(lots/step)*step;
   if(lots<minv) lots=minv;
   if(lots>maxv) lots=maxv;
   return NormalizeDouble(lots,2);
}

double FitLotsToFreeMargin(string symb,double wantedLots,int type){
   double step=MarketInfo(symb,MODE_LOTSTEP);
   double minv=MarketInfo(symb,MODE_MINLOT);
   if(step<=0) step=(minv>0?minv:0.01);
   double lots=AdjustLots(wantedLots);
   int guard=1000;
   while(lots>=minv-1e-8 && guard-->0){
      if(CheckMoneyForTrade(symb,lots,type)) return AdjustLots(lots);
      lots=NormalizeDouble(lots-step,2);
   }
   Print("Skip trade: not enough margin even at min lot ",DoubleToString(minv,2));
   return 0.0;
}

void SanitizeStops(const int orderType,const double price,double &sl,double &tp){
   int    stopLevelPts=(int)MarketInfo(Symbol(),MODE_STOPLEVEL);
   double minDist=stopLevelPts*SymbolInfoDouble(_Symbol, SYMBOL_POINT) + 2*SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(orderType==OP_BUY){
      if(sl>0 && (price-sl)<minDist) sl=0;
      if(tp>0 && (tp-price)<minDist) tp=0;
      if(sl>=price) sl=0; if(tp<=price) tp=0;
   }else{
      if(sl>0 && (sl-price)<minDist) sl=0;
      if(tp>0 && (price-tp)<minDist) tp=0;
      if(sl<=price) sl=0; if(tp>=price) tp=0;
   }
}

bool TrySetStopsLater(int ticket, double sl, double tp) {
    if(ticket <= 0) return false;
    if(!OrderSelect(ticket, SELECT_BY_TICKET)) return false;
    
    Sleep(100);
    RefreshRates();
    
    double currentBid = MarketInfo(OrderSymbol(), MODE_BID);
    double currentAsk = MarketInfo(OrderSymbol(), MODE_ASK);
    
    int stopLevel = (int)MarketInfo(OrderSymbol(), MODE_STOPLEVEL);
    double minDist = stopLevel * MarketInfo(OrderSymbol(), MODE_POINT);
    
    if(OrderType() == OP_BUY) {
        if(sl > 0 && (currentBid - sl) < minDist) sl = 0;
        if(tp > 0 && (tp - currentBid) < minDist) tp = 0;
    }
    else if(OrderType() == OP_SELL) {
        if(sl > 0 && (sl - currentAsk) < minDist) sl = 0;
        if(tp > 0 && (currentAsk - tp) < minDist) tp = 0;
    }
    
    if(sl > 0 || tp > 0) {
        return OrderModify(ticket, OrderOpenPrice(), sl, tp, 0, clrNONE);
    }
    
    return true;
}

bool IsTradingAllowedNow(){
   if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED))   { Print("Trade not allowed by account"); return(false); }
   if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT))    { Print("EA trading not allowed by account"); return(false); }
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)) { Print("Terminal auto-trading disabled"); return(false); }
   if(!MQLInfoInteger(MQL_TRADE_ALLOWED))           { Print("MQL trading disabled"); return(false); }
   return(true);
}

bool IsNewOrderAllowed(){
   int max_orders=(int)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   if(max_orders==0) return true;
   return OrdersTotal()<max_orders;
}

bool IsDayEnabled(){
   int d=DayOfWeek();
   if(d==0) return EnableSunday;
   if(d==1) return EnableMonday;
   if(d==2) return EnableTuesday;
   if(d==3) return EnableWednesday;
   if(d==4) return EnableThursday;
   if(d==5) return EnableFriday;
   if(d==6) return EnableSaturday;
   return true;
}

void IvyLabel(string name,int x,int y,string text,color col){
   if(ObjectFind(0,name)==-1) ObjectCreate(0,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_CORNER,DashCorner);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,DashFontSize);
   ObjectSetString (0,name,OBJPROP_FONT,"Arial");
   ObjectSetInteger(0,name,OBJPROP_COLOR,col);
   ObjectSetString (0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,false);
}

bool CloseAllPositions(){
   bool ok=true;
   for(int i=OrdersTotal()-1;i>=0;i--){
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) continue;
      int type=OrderType(); if(type!=OP_BUY && type!=OP_SELL) continue;
      string sym=OrderSymbol();
      int digits=(int)MarketInfo(sym,MODE_DIGITS);
      double price=(type==OP_BUY)?MarketInfo(sym,MODE_BID):MarketInfo(sym,MODE_ASK);
      if(!OrderClose(OrderTicket(),OrderLots(),NormalizeDouble(price,digits),10,clrPink)){
         Print("CloseAllPositions fail ticket ",OrderTicket()," err=",GetLastError()); ok=false;
      }
   }
   return ok;
}

// =====================================================================
// AUTOMATIC NEWS FILTER FUNCTIONS - MULTI-SOURCE FAILOVER SYSTEM
// =====================================================================

string toupper_str(string s) { 
   StringToUpper(s);
   return s; 
}

void ExtractCurrencies(string sym, string &base, string &quote){
   base = ""; 
   quote = "";
   string S = toupper_str(sym);
   string clean = "";
   for(int i = 0; i < StringLen(S); i++) {
      ushort ch = StringGetCharacter(S, i);
      if(ch >= 'A' && ch <= 'Z') {
         clean = clean + CharToString((uchar)ch);
      } else {
         break;
      }
   }
   if(StringLen(clean) >= 6) {
      base = StringSubstr(clean, 0, 3);
      quote = StringSubstr(clean, 3, 3);
   } else {
      base = clean;
      quote = "";
   }
}

// Helper to get a string value from a JSON object string
string GetJsonStringValue(string &obj, string key) {
    string key_pattern = "\"" + key + "\":\""; // Looks for "key":"
    int key_pos = StringFind(obj, key_pattern);
    if (key_pos < 0) return "";

    int value_start = key_pos + StringLen(key_pattern);
    int value_end = StringFind(obj, "\"", value_start);
    if (value_end < 0) return "";
    
    return StringSubstr(obj, value_start, value_end - value_start);
}

// PARSER 1: Forex Factory
int ParseForexFactoryJson(string &json_data) {
    g_news_count = 0;
    int current_pos = 0;
    int array_start = StringFind(json_data, "[");
    if (array_start < 0) return INIT_SUCCEEDED;
    current_pos = array_start;

    while(g_news_count < MAX_NEWS) {
        int obj_start = StringFind(json_data, "{", current_pos);
        if (obj_start < 0) break;
        int obj_end = StringFind(json_data, "}", obj_start);
        if (obj_end < 0) break;
        string event_obj = StringSubstr(json_data, obj_start, obj_end - obj_start + 1);
        current_pos = obj_end + 1;

        string title = GetJsonStringValue(event_obj, "title");
        string ccy = GetJsonStringValue(event_obj, "country");
        string impact = GetJsonStringValue(event_obj, "impact");
        string date_str_iso = GetJsonStringValue(event_obj, "date");

        if (StringLen(date_str_iso) > 15) {
            string parsable_date = date_str_iso;
            StringReplace(parsable_date, "-", ".");
            StringReplace(parsable_date, "T", " ");
            parsable_date = StringSubstr(parsable_date, 0, 16);
            datetime event_time = StringToTime(parsable_date);

            if (event_time > 0 && StringLen(ccy) > 0 && StringLen(impact) > 0) {
                int lvl = 0;
                if (impact == "High") lvl = 3;
                else if (impact == "Medium") lvl = 2;
                else if (impact == "Low") lvl = 1;
                if (lvl > 0) {
                    g_news_time[g_news_count] = event_time;
                    g_news_imp[g_news_count] = lvl;
                    g_news_ccy[g_news_count] = toupper_str(ccy);
                    g_news_title[g_news_count] = title;
                    g_news_count++;
                }
            }
        }
    }
    return g_news_count;
}

// PARSER 2: DailyFX
int ParseDailyFXJson(string &json_data) {
    g_news_count = 0;
    int current_pos = 0;
    while(g_news_count < MAX_NEWS) {
        int obj_start = StringFind(json_data, "{", current_pos);
        if (obj_start < 0) break;
        int obj_end = StringFind(json_data, "}", obj_start);
        if (obj_end < 0) break;
        string event_obj = StringSubstr(json_data, obj_start, obj_end - obj_start + 1);
        current_pos = obj_end + 1;

        string title = GetJsonStringValue(event_obj, "event");
        string ccy = GetJsonStringValue(event_obj, "country");
        string impact = GetJsonStringValue(event_obj, "importance");
        string ts_str = GetJsonStringValue(event_obj, "timestamp");
        StringReplace(ts_str, "\"", ""); // Clean up potential quotes
        long ts = (long)StringToInteger(ts_str);

        if (ts > 0 && StringLen(ccy) > 0 && StringLen(impact) > 0) {
            int lvl = 0;
            if (impact == "high") lvl = 3;
            else if (impact == "medium") lvl = 2;
            else if (impact == "low") lvl = 1;
            if(lvl > 0){
               g_news_time[g_news_count] = (datetime)ts;
               g_news_imp[g_news_count] = lvl;
               g_news_ccy[g_news_count] = toupper_str(ccy);
               g_news_title[g_news_count] = title;
               g_news_count++;
            }
        }
    }
    return g_news_count;
}


void RefreshNewsIfNeeded(){
   if(!UseNewsFilter || !g_news_filter_enabled || IsTesting()) return;
   
   datetime now = TimeCurrent();
   if(g_request_failures >= 10 && (now - g_last_request_attempt) < 1800) return; // Wait 30 mins after 10 total failures
   if(now < g_next_news_refresh && g_initial_load_done) return;
   
   g_last_request_attempt = now;
   char post[], result[];
   string hdr="";
   int res = -1;
   int parse_result = 0;
   string json = "";

   // --- Try Primary Source (Forex Factory) ---
   Print("News: Attempting primary source (Forex Factory)...");
   ResetLastError();
   res = WebRequest("GET", PrimaryNewsUrl, "", "", 5000, post, 0, result, hdr);
   if(res != -1 && ArraySize(result) > 0) {
      json = CharArrayToString(result, 0, -1, CP_UTF8);
      parse_result = ParseForexFactoryJson(json);
      if(parse_result > 0) {
         Print("News: SUCCESS - Loaded ", parse_result, " events from primary source.");
         g_news_loaded = true;
      }
   }
   
   // --- If Primary Failed, Try Backup Source (DailyFX) ---
   if(!g_news_loaded) {
      Print("News: Primary source failed. Attempting backup source (DailyFX)...");
      ArrayFree(result);
      ResetLastError();
      res = WebRequest("GET", BackupNewsUrl, "", "", 5000, post, 0, result, hdr);
      if(res != -1 && ArraySize(result) > 0) {
         json = CharArrayToString(result, 0, -1, CP_UTF8);
         parse_result = ParseDailyFXJson(json);
         if(parse_result > 0) {
            Print("News: SUCCESS - Loaded ", parse_result, " events from backup source.");
            g_news_loaded = true;
         }
      }
   }

   // --- Final Result ---
   if(g_news_loaded) {
      g_initial_load_done = true;
      g_news_filter_verified = true;
      g_request_failures = 0;
      g_last_refresh = now;
      g_next_news_refresh = now + NewsRefreshMinutes * 60;
   } else {
      Print("News: CRITICAL FAILURE - Both primary and backup news sources failed.");
      g_request_failures++;
   }
}

// *** UNIFIED AND CORRECTED NEWS LOGIC ***
bool IsNewsSafeToTrade(){
   g_minutes_until_unblock = 0; // Reset at the start of each check
   g_is_high_impact_day_block = false;

   if(!UseNewsFilter || !g_news_filter_enabled) return true;
   if(!g_news_loaded || g_news_count == 0) return true;
   
   string base = "", quote = "";
   ExtractCurrencies(Symbol(), base, quote);
   
   if(StringLen(base) != 3) return true;
   
   datetime now_gmt = TimeGMT(); // Use UTC time for all comparisons

   // --- MODE 1: Block for the entire day on High Impact News ---
   if(Block_On_High_Impact_Day) {
      for(int i = 0; i < g_news_count; i++) {
         string c = g_news_ccy[i];
         // Check only for relevant currency and High impact (level 3)
         if((c == base || c == quote) && g_news_imp[i] == 3) {
            datetime event_time_gmt = g_news_time[i];
            
            // Check if the UTC event time falls within the same calendar day as the current UTC time
            if(TimeDay(event_time_gmt) == TimeDay(now_gmt) && TimeMonth(event_time_gmt) == TimeMonth(now_gmt) && TimeYear(event_time_gmt) == TimeYear(now_gmt))
            {
               g_is_high_impact_day_block = true;
               return false; // Not safe to trade for the rest of the day
            }
         }
      }
      return true; // No high impact news found for today, so it's safe
   }

   // --- MODE 2: Minute-based buffer (if day-block is off) ---
   datetime latest_block_end = 0;
   
   for(int i = 0; i < g_news_count; i++){
      string c = g_news_ccy[i];
      if(!(c == base || c == quote)) continue;
      
      int lvl = g_news_imp[i];
      bool enabled = (lvl==3 ? FilterHigh : (lvl==2 ? FilterMedium : FilterLow));
      if(!enabled) continue;
      
      int before = (lvl==3 ? Do_Not_Trade_Before_High_News_in_Mins   : (lvl==2 ? Do_Not_Trade_Before_Medium_News_in_Mins : Do_Not_Trade_Before_Low_News_in_Mins));
      int after  = (lvl==3 ? Start_Trade_After_High_News_in_Mins    : (lvl==2 ? Start_Trade_After_Medium_News_in_Mins  : Start_Trade_After_Low_News_in_Mins));
      
      datetime event_time = g_news_time[i];
      datetime blockStart = event_time - before * 60;
      datetime blockEnd   = event_time + after * 60;
      
      if(now_gmt >= blockStart && now_gmt <= blockEnd){
         if(blockEnd > latest_block_end) {
             latest_block_end = blockEnd;
         }
      }
   }

   if(latest_block_end > 0) {
      g_minutes_until_unblock = (int)((latest_block_end - now_gmt) / 60) + 1;
      return false;
   }
   
   return true;
}

void VerifyNewsFilterLive() {
   if(!UseNewsFilter || IsTesting()) return;
   
   Print("====== MULTI-SOURCE NEWS FILTER VERIFICATION ======");
   
   g_news_filter_enabled = true;
   g_news_loaded = false;
   g_initial_load_done = false;
   g_next_news_refresh = 0;
   
   RefreshNewsIfNeeded();
   
   if(g_news_loaded) {
       Print("✓ News filter verified with ", g_news_count, " events.");
       g_news_filter_verified = true;
       bool can_trade = IsNewsSafeToTrade();
       Print("Current Status: ", can_trade ? "✓ SAFE TO TRADE" : "⚠ NEWS BLOCKING");
       if(!can_trade) Alert("News Filter: Currently blocking trades!");
   } else {
       Alert("CRITICAL: Automatic News Filter FAILED to load from ALL sources!");
       Print("EA will trade WITHOUT news protection unless fixed. Check Experts tab for details.");
       g_news_filter_verified = false;
   }
   Print("=================================================");
}

// =====================================================================
// INIT FUNCTION
// =====================================================================

// Init Function
int OnInit()
{
    // CRITICAL: Check for hedging mode
    if(AccountInfoInteger(ACCOUNT_MARGIN_MODE) != ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) {
        Alert("ERROR: This EA requires HEDGING account mode!");
        Alert("In MT5, go to Tools -> Options -> Trade");
        Alert("Set 'Account Type' to 'Hedging' (not 'Netting')");
        Print("EA cannot run without HEDGING mode. Initialization failed.");
        return INIT_FAILED;
    }
    Print("Account mode verified: HEDGING - OK");
    

    string tmp_str00000;
    string tmp_str00001;
    int Li_FFFFC;

    Ib_00000 = true;
    Ii_00004 = 16777215;
    Ii_00008 = 16748574;
    Ii_0000C = 0;
    Ii_00010 = 7;
    Is_00018 = "POISON IVY";
    Ii_00024 = 32768;
    Ii_00028 = 255;
    Ii_0002C = 16777215;
    Ii_00030 = 16711680;
    Ii_00034 = 0;
    Ii_00038 = 0;
    Id_00040 = 0;
    Ii_00048 = 0;
    Ii_0004C = 0;
    Ii_00050 = 0;
    Id_00058 = 0;
    Id_00060 = 0;
    Id_00068 = 0;
    Id_00070 = 0;

    Gd_00000 = 0;
    Gi_00001 = 0;
    Gd_00002 = 0;
    Gi_00003 = 0;
    Ii_00050 = 1;
    if ((int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 5 || (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) == 3) {
        Ii_00050 = 10;
    }
    
    Gi_00001 = FlipUpLineColor;
    Gi_00004 = Dist * Ii_00050;
    Gd_00004 = ((Gi_00004 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
    Gd_00000 = Gd_00004;
    tmp_str00000 = "FlipUp";
    if (Gd_00004 == 0) {
        Gd_00000 = SymbolInfoDouble(NULL, SYMBOL_BID);
    }
    if (ObjectCreate(0, tmp_str00000, OBJ_HLINE, 0, 0, Gd_00000) != true) {
        Print("HLineCreate", ": Failed to create a horizontal line! Error code = ", GetLastError());
    }
    else {
        ObjectSetInteger(0, tmp_str00000, 6, Gi_00001);
        ObjectSetInteger(0, tmp_str00000, 7, 0);
        ObjectSetInteger(0, tmp_str00000, 8, 1);
        ObjectSetInteger(0, tmp_str00000, 9, 0);
        ObjectSetInteger(0, tmp_str00000, 1000, 1);
        ObjectSetInteger(0, tmp_str00000, 17, 1);
        ObjectSetInteger(0, tmp_str00000, 208, 0);
        ObjectSetInteger(0, tmp_str00000, 207, 0);
    }
    
    Gi_00003 = FlipDownLineColor;
    Gi_00004 = Dist * Ii_00050;
    Gd_00004 = (Gi_00004 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
    Gd_00004 = (GetBid() - Gd_00004);
    Gd_00002 = Gd_00004;
    tmp_str00001 = "FlipDown";
    if (Gd_00004 == 0) {
        Gd_00002 = SymbolInfoDouble(NULL, SYMBOL_BID);
    }
    if (ObjectCreate(0, tmp_str00001, OBJ_HLINE, 0, 0, Gd_00002) != true) {
        Print("HLineCreate", ": Failed to create a horizontal line! Error code = ", GetLastError());
        return INIT_SUCCEEDED;
    }
    ObjectSetInteger(0, tmp_str00001, 6, Gi_00003);
    ObjectSetInteger(0, tmp_str00001, 7, 0);
    ObjectSetInteger(0, tmp_str00001, 8, 1);
    ObjectSetInteger(0, tmp_str00001, 9, 0);
    ObjectSetInteger(0, tmp_str00001, 1000, 1);
    ObjectSetInteger(0, tmp_str00001, 17, 1);
    ObjectSetInteger(0, tmp_str00001, 208, 0);
    ObjectSetInteger(0, tmp_str00001, 207, 0);
    
    if(!IsTesting() && UseNewsFilter) {
        // You must add BOTH URLs to Tools -> Options -> Expert Advisors -> Allow WebRequest
        // 1. https://nfs.faireconomy.media
        // 2. https://www.dailyfx.com
        VerifyNewsFilterLive();
    }

    Li_FFFFC = 0;
    return INIT_SUCCEEDED;
}

// =====================================================================
// MAIN TICK FUNCTION - COMPLETE AND UNTOUCHED
// =====================================================================
// OnTick Function
void OnTick()
{
    // === NEWS FILTER LOGIC ===
    RefreshNewsIfNeeded();
    
    static datetime last_status_update = 0;
    if(UseNewsFilter && TimeCurrent() - last_status_update >= 30) {
        last_status_update = TimeCurrent();
        string status = "News: ";
        if(g_news_filter_enabled && g_news_loaded) {
            if(IsNewsSafeToTrade()) {
                status += "✓ SAFE [" + IntegerToString(g_news_count) + " events]";
            } else {
                status += "⚠ BLOCKING";
            }
        } else if(!g_news_filter_enabled) {
            status += "DISABLED";
        } else {
            status += "LOADING...";
        }
        Comment(status);
    }

    // === ORIGINAL TRADING LOGIC BEGINS ===
    int Li_FFFFC;

    Gd_00036 = ((AccountBalance() / 100) * Risk);
    Gd_00037 = (MarketInfo(_Symbol, MODE_TICKVALUE) * 100);
    if(Gd_00037<=0) Gd_00037=1; // prevent zero divide
    Id_00040 = NormalizeDouble((Gd_00036 / (Gd_00037 * Ii_00050)), 2);
    if ((Id_00040 < MarketInfo(_Symbol, MODE_MINLOT))) {
        Id_00040 = MarketInfo(_Symbol, MODE_MINLOT);
    }
    
    Li_FFFFC = ObjectsTotal(0, -1, -1) - 1;
    if (Li_FFFFC >= 0) {
        do {
            Id_00060 = ObjectGetDouble(0, "FlipUp", OBJPROP_PRICE);
            Id_00058 = ObjectGetDouble(0, "FlipDown", OBJPROP_PRICE);
            Li_FFFFC = Li_FFFFC - 1;
        } while (Li_FFFFC >= 0);
    }
    
    Gi_00037 = Dist * Ii_00050;
    if ((((Gi_00037 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk()) < Id_00060)) {
        Gd_00038 = ((Gi_00037 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
        Gd_00000 = Gd_00038;
        if (Gd_00038 == 0) {
            Gd_00000 = SymbolInfoDouble(NULL, SYMBOL_BID);
        }
        if (ObjectMove(0, "FlipUp", 0, 0, Gd_00000) != true) {
            Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
        }
    }
    
    Gi_00038 = Dist * Ii_00050;
    Gd_00039 = (Gi_00038 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
    if (((GetBid() - Gd_00039) > Id_00058)) {
        Gd_00039 = (Gi_00038 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
        Gd_00039 = (GetBid() - Gd_00039);
        Gd_00001 = Gd_00039;
        if (Gd_00039 == 0) {
            Gd_00001 = SymbolInfoDouble(NULL, SYMBOL_BID);
        }
        if (ObjectMove(0, "FlipDown", 0, 0, Gd_00001) != true) {
            Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
        }
    }
    
    if ((GetAsk() < Id_00058)) {
        Gi_00039 = Dist * Ii_00050;
        if (((GetBid() - Gd_0003A) > Id_00060)) {
            Gd_0003A = ((Gi_00039 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
            Gd_00002 = Gd_0003A;
            if (Gd_0003A == 0) {
                Gd_00002 = SymbolInfoDouble(NULL, SYMBOL_BID);
            }
            if (ObjectMove(0, "FlipUp", 0, 0, Gd_00002) != true) {
                Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
            }
        }
    }
    
    if ((GetBid() > Id_00060)) {
        Gi_0003A = Dist * Ii_00050;
        if ((((Gi_0003A * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk()) < Id_00058)) {
            Gd_0003B = (Gi_0003A * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
            Gd_0003B = (GetBid() - Gd_0003B);
            Gd_00003 = Gd_0003B;
            if (Gd_0003B == 0) {
                Gd_00003 = SymbolInfoDouble(NULL, SYMBOL_BID);
            }
            if (ObjectMove(0, "FlipDown", 0, 0, Gd_00003) != true) {
                Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
            }
        }
    }
    
    if (TimeHour(TimeCurrent()) >= TimeStart && TimeHour(TimeCurrent()) < TimeEnd) {
        if ((GetOpen(0) > GetClose(0)) && (GetAsk() <= Id_00058)) {
            Gi_00004 = -1;
            Gl_00005 = 0;
            Gi_0003D = HistoryTotal() - 1;
            Gi_00006 = Gi_0003D;
            if (Gi_0003D >= 0) {
                do {
                    if (OrderSelect(Gi_00006, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_00005) {
                        Gl_00005 = OrderOpenTime();
                        Gi_00004 = OrderType();
                    }
                    Gi_00006 = Gi_00006 - 1;
                } while (Gi_00006 >= 0);
            }
            if (Gi_00004 != 1) {
                Gi_00007 = -1;
                Gi_00008 = 0;
                Gi_0003D = OrdersTotal() - 1;
                Gi_00009 = Gi_0003D;
                if (Gi_0003D >= 0) {
                    do {
                        if (OrderSelect(Gi_00009, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                            if (Gi_00007 == -1 || OrderType() == Gi_00007) {
                                Gi_00008 = Gi_00008 + 1;
                            }
                        }
                        Gi_00009 = Gi_00009 - 1;
                    } while (Gi_00009 >= 0);
                }
                if (Gi_00008 == 0) {
                    double slPrice = 0;
                    double tpPrice = 0;
                    double currentLot = Id_00040;
                    if (StopLossDollars > 0 && currentLot > 0) {
                        double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                        double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                        double slPoints = 0;
                        if(tickSize<=0) tickSize=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                        if(tickValue>0) slPoints = (StopLossDollars/currentLot) * (tickSize/tickValue);
                        slPrice = NormalizeDouble(GetBid() - slPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                    }
                    if (TakeProfitDollars > 0 && currentLot > 0) {
                        double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                        double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                        double tpPoints = 0;
                        if(tickSize<=0) tickSize=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                        if(tickValue>0) tpPoints = (TakeProfitDollars/currentLot) * (tickSize/tickValue);
                        tpPrice = NormalizeDouble(GetBid() + tpPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                    }
                    if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled() && IsNewsSafeToTrade()){
                        double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), 1);
                        SanitizeStops(OP_BUY, GetBid(), slPrice, tpPrice);
                        if(lotToSend>0) {
                            Ii_0004C = OrderSend(_Symbol, 1, lotToSend, GetBid(), 10, 0, 0, Is_00018, Magic, 0, 255);
                            if(Ii_0004C > 0) TrySetStopsLater(Ii_0004C, slPrice, tpPrice);
                        }
                    }
                    Gi_0003D = Dist * Ii_00050;
                    Gd_0003D = ((Gi_0003D * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
                    Gd_0000A = Gd_0003D;
                    if (Gd_0003D == 0) {
                        Gd_0000A = SymbolInfoDouble(NULL, SYMBOL_BID);
                    }
                    if (ObjectMove(0, "FlipUp", 0, 0, Gd_0000A) != true) {
                        Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
                    }
                }
            }
        }
        
        if ((GetOpen(0) < GetClose(0)) && (GetBid() >= Id_00060)) {
            Gi_0000B = -1;
            Gl_0000C = 0;
            Gi_0003F = HistoryTotal() - 1;
            Gi_0000D = Gi_0003F;
            if (Gi_0003F >= 0) {
                do {
                    if (OrderSelect(Gi_0000D, 0, 1) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic && OrderOpenTime() > Gl_0000C) {
                        Gl_0000C = OrderOpenTime();
                        Gi_0000B = OrderType();
                    }
                    Gi_0000D = Gi_0000D - 1;
                } while (Gi_0000D >= 0);
            }
            if (Gi_0000B != 0) {
                Gi_0000E = -1;
                Gi_0000F = 0;
                Gi_0003F = OrdersTotal() - 1;
                Gi_00010 = Gi_0003F;
                if (Gi_0003F >= 0) {
                    do {
                        if (OrderSelect(Gi_00010, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                            if (Gi_0000E == -1 || OrderType() == Gi_0000E) {
                                Gi_0000F = Gi_0000F + 1;
                            }
                        }
                        Gi_00010 = Gi_00010 - 1;
                    } while (Gi_00010 >= 0);
                }
                if (Gi_0000F == 0) {
                    double slPrice = 0;
                    double tpPrice = 0;
                    double currentLot = Id_00040;
                    if (StopLossDollars > 0 && currentLot > 0) {
                        double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                        double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                        double slPoints = 0;
                        if(tickSize<=0) slPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                        if(tickValue>0) slPoints = (StopLossDollars/currentLot) * (tickSize/tickValue);
                        slPrice = NormalizeDouble(GetAsk() + slPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                    }
                    if (TakeProfitDollars > 0 && currentLot > 0) {
                        double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                        double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                        double tpPoints = 0;
                        if(tickSize<=0) tpPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                        if(tickValue>0) tpPoints = (TakeProfitDollars/currentLot) * (tickSize/tickValue);
                        tpPrice = NormalizeDouble(GetAsk() - tpPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                    }
                    if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled() && IsNewsSafeToTrade()){
                        double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), 0);
                        SanitizeStops(OP_SELL, GetAsk(), slPrice, tpPrice);
                        if(lotToSend>0) {
                            Ii_0004C = OrderSend(_Symbol, 0, lotToSend, GetAsk(), 10, 0, 0, Is_00018, Magic, 0, 32768);
                            if(Ii_0004C > 0) TrySetStopsLater(Ii_0004C, slPrice, tpPrice);
                        }
                    }
                    Gi_0003F = Dist * Ii_00050;
                    Gd_0003F = (Gi_0003F * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
                    Gd_0003F = (GetBid() - Gd_0003F);
                    Gd_00011 = Gd_0003F;
                    if (Gd_0003F == 0) {
                        Gd_00011 = SymbolInfoDouble(NULL, SYMBOL_BID);
                    }
                    if (ObjectMove(0, "FlipDown", 0, 0, Gd_00011) != true) {
                        Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
                    }
                }
            }
        }
    }
    
    Gi_00012 = -1;
    Gi_00013 = 0;
    Gi_0003F = OrdersTotal() - 1;
    Gi_00014 = Gi_0003F;
    if (Gi_0003F >= 0) {
        do {
            if (OrderSelect(Gi_00014, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                if (Gi_00012 == -1 || OrderType() == Gi_00012) {
                    Gi_00013 = Gi_00013 + 1;
                }
            }
            Gi_00014 = Gi_00014 - 1;
        } while (Gi_00014 >= 0);
    }
    returned_double = MathPow(UpLot, Gi_00013);
    Id_00068 = (Id_00040 * returned_double);
    
    if ((GetOpen(0) > GetClose(0)) && (GetAsk() <= Id_00058)) {
        Gi_00015 = 1;
        Gi_00016 = 0;
        Gi_00041 = OrdersTotal() - 1;
        Gi_00017 = Gi_00041;
        if (Gi_00041 >= 0) {
            do {
                if (OrderSelect(Gi_00017, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                    if (Gi_00015 == -1 || OrderType() == Gi_00015) {
                        Gi_00016 = Gi_00016 + 1;
                    }
                }
                Gi_00017 = Gi_00017 - 1;
            } while (Gi_00017 >= 0);
        }
        if (Gi_00016 > 0) {
            Gi_00041 = Step * Ii_00050;
            Gd_00041 = (Gi_00041 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
            Gd_00041 = (GetBid() - Gd_00041);
            Gd_00018 = 0;
            Gi_00019 = 0;
            Gi_0001A = 0;
            Gi_00042 = OrdersTotal() - 1;
            Gi_0001B = Gi_00042;
            if (Gi_00042 >= 0) {
                do {
                    order_check = OrderSelect(Gi_0001B, 0, 0);
                    if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderType() == OP_SELL) {
                        Gi_00019 = OrderTicket();
                        if (Gi_00019 > Gi_0001A) {
                            Gd_00018 = OrderOpenPrice();
                            Gi_0001A = Gi_00019;
                        }
                    }
                    Gi_0001B = Gi_0001B - 1;
                } while (Gi_0001B >= 0);
            }
            if ((Gd_00041 > Gd_00018)) {
                double slPrice = 0;
                double tpPrice = 0;
                double currentLot = Id_00068;
                if (StopLossDollars > 0 && currentLot > 0) {
                    double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                    double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                    double slPoints = 0;
                    if(tickSize<=0) slPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                    if(tickValue>0) slPoints = (StopLossDollars/currentLot) * (tickSize/tickValue);
                    slPrice = NormalizeDouble(GetBid() - slPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                }
                if (TakeProfitDollars > 0 && currentLot > 0) {
                    double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                    double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                    double tpPoints = 0;
                    if(tickSize<=0) tpPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                    if(tickValue>0) tpPoints = (TakeProfitDollars/currentLot) * (tickSize/tickValue);
                    tpPrice = NormalizeDouble(GetBid() + tpPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                }
                if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled() && IsNewsSafeToTrade()){
                    double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), 1);
                    SanitizeStops(OP_BUY, GetBid(), slPrice, tpPrice);
                    if(lotToSend>0) {
                        Ii_0004C = OrderSend(_Symbol, 1, lotToSend, GetBid(), 10, 0, 0, Is_00018, Magic, 0, 255);
                        if(Ii_0004C > 0) TrySetStopsLater(Ii_0004C, slPrice, tpPrice);
                    }
                }
                Gi_00042 = Dist * Ii_00050;
                Gd_00042 = ((Gi_00042 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
                Gd_0001C = Gd_00042;
                if (Gd_00042 == 0) {
                    Gd_0001C = SymbolInfoDouble(NULL, SYMBOL_BID);
                }
                if (ObjectMove(0, "FlipUp", 0, 0, Gd_0001C) != true) {
                    Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
                }
            }
        }
    }
    
    if ((GetOpen(0) < GetClose(0)) && (GetBid() >= Id_00060)) {
        Gi_0001D = 0;
        Gi_0001E = 0;
        Gi_00044 = OrdersTotal() - 1;
        Gi_0001F = Gi_00044;
        if (Gi_00044 >= 0) {
            do {
                if (OrderSelect(Gi_0001F, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                    if (Gi_0001D == -1 || OrderType() == Gi_0001D) {
                        Gi_0001E = Gi_0001E + 1;
                    }
                }
                Gi_0001F = Gi_0001F - 1;
            } while (Gi_0001F >= 0);
        }
        if (Gi_0001E > 0) {
            Gi_00044 = Step * Ii_00050;
            Gd_00044 = ((Gi_00044 * SymbolInfoDouble(_Symbol, SYMBOL_POINT)) + GetAsk());
            Gd_00020 = 0;
            Gi_00021 = 0;
            Gi_00022 = 0;
            Gi_00045 = OrdersTotal() - 1;
            Gi_00023 = Gi_00045;
            if (Gi_00045 >= 0) {
                do {
                    order_check = OrderSelect(Gi_00023, 0, 0);
                    if (OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic && OrderType() == OP_BUY) {
                        Gi_00021 = OrderTicket();
                        if (Gi_00021 > Gi_00022) {
                            Gd_00020 = OrderOpenPrice();
                            Gi_00022 = Gi_00021;
                        }
                    }
                    Gi_00023 = Gi_00023 - 1;
                } while (Gi_00023 >= 0);
            }
            if ((Gd_00044 < Gd_00020)) {
                double slPrice = 0;
                double tpPrice = 0;
                double currentLot = Id_00068;
                if (StopLossDollars > 0 && currentLot > 0) {
                    double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                    double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                    double slPoints = 0;
                    if(tickSize<=0) slPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                    if(tickValue>0) slPoints = (StopLossDollars/currentLot) * (tickSize/tickValue);
                    slPrice = NormalizeDouble(GetAsk() + slPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                }
                if (TakeProfitDollars > 0 && currentLot > 0) {
                    double tickValue = MarketInfo(_Symbol, MODE_TICKVALUE);
                    double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
                    double tpPoints = 0;
                    if(tickSize<=0) tpPoints=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
                    if(tickValue>0) tpPoints = (TakeProfitDollars/currentLot) * (tickSize/tickValue);
                    tpPrice = NormalizeDouble(GetAsk() - tpPoints * SymbolInfoDouble(_Symbol, SYMBOL_POINT), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
                }
                if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled() && IsNewsSafeToTrade()){
                    double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), 0);
                    SanitizeStops(OP_SELL, GetAsk(), slPrice, tpPrice);
                    if(lotToSend>0) {
                        Ii_0004C = OrderSend(_Symbol, 0, lotToSend, GetAsk(), 10, 0, 0, Is_00018, Magic, 0, 32768);
                        if(Ii_0004C > 0) TrySetStopsLater(Ii_0004C, slPrice, tpPrice);
                    }
                }
                Gi_00045 = Dist * Ii_00050;
                Gd_00045 = (Gi_00045 * SymbolInfoDouble(_Symbol, SYMBOL_POINT));
                Gd_00045 = (GetBid() - Gd_00045);
                Gd_00024 = Gd_00045;
                if (Gd_00045 == 0) {
                    Gd_00024 = SymbolInfoDouble(NULL, SYMBOL_BID);
                }
                if (ObjectMove(0, "FlipDown", 0, 0, Gd_00024) != true) {
                    Print("HLineMove", ":Failed to move the horizontal line! Error code = ", GetLastError());
                }
            }
        }
    }
    
    Gi_00025 = -1;
    Gd_00026 = 0;
    Gi_00045 = OrdersTotal() - 1;
    Gi_00027 = Gi_00045;
    if (Gi_00045 >= 0) {
        do {
            if (OrderSelect(Gi_00027, 0, 0) && _Symbol == OrderSymbol() && OrderMagicNumber() == Magic) {
                if (OrderType() == Gi_00025 || Gi_00025 == -1) {
                    Gd_00045 = OrderProfit();
                    Gd_00045 = (Gd_00045 + OrderSwap());
                    Gd_00026 = ((Gd_00045 + OrderCommission()) + Gd_00026);
                }
            }
            Gi_00027 = Gi_00027 - 1;
        } while (Gi_00027 >= 0);
    }
    double __ab = AccountBalance();
    double __den = (__ab!=0 ? (__ab/100.0) : 1.0);
    Id_00070 = (Gd_00026 / __den);
    
    Gi_00028 = 0;
    Gi_00029 = 0;
    Gi_00045 = OrdersTotal() - 1;
    Gi_0002A = Gi_00045;
    if (Gi_00045 >= 0) {
        do {
            if (OrderSelect(Gi_0002A, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                if (Gi_00028 == -1 || OrderType() == Gi_00028) {
                    Gi_00029 = Gi_00029 + 1;
                }
            }
            Gi_0002A = Gi_0002A - 1;
        } while (Gi_0002A >= 0);
    }
    if (Gi_00029 > 0 && (GetAsk() <= Id_00058) && (Id_00070 >= MinProfit)) {
        Gi_0002B = -1;
        Gi_00045 = OrdersTotal() - 1;
        Gi_0002C = Gi_00045;
        if (Gi_00045 >= 0) {
            do {
                if (OrderSelect(Gi_0002C, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
                    Gd_00045 = OrderProfit();
                    Gd_00045 = (Gd_00045 + OrderSwap());
                    if (((Gd_00045 + OrderCommission()) < 0)) {
                        if (OrderType() == OP_BUY) {
                            if (Gi_0002B == 0 || Gi_0002B == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetBid(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                        if (OrderType() == OP_SELL) {
                            if (Gi_0002B == 1 || Gi_0002B == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetAsk(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                    }
                }
                Gi_0002C = Gi_0002C - 1;
            } while (Gi_0002C >= 0);
        }
        Gi_0002D = -1;
        Gi_00049 = OrdersTotal() - 1;
        Gi_0002E = Gi_00049;
        if (Gi_00049 >= 0) {
            do {
                if (OrderSelect(Gi_0002E, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
                    Gd_00049 = OrderProfit();
                    Gd_00049 = (Gd_00049 + OrderSwap());
                    if (((Gd_00049 + OrderCommission()) > 0)) {
                        if (OrderType() == OP_BUY) {
                            if (Gi_0002D == 0 || Gi_0002D == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetBid(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                        if (OrderType() == OP_SELL) {
                            if (Gi_0002D == 1 || Gi_0002D == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetAsk(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                    }
                }
                Gi_0002E = Gi_0002E - 1;
            } while (Gi_0002E >= 0);
        }
    }
    
    Gi_0002F = 1;
    Gi_00030 = 0;
    Gi_0004D = OrdersTotal() - 1;
    Gi_00031 = Gi_0004D;
    if (Gi_0004D >= 0) {
        do {
            if (OrderSelect(Gi_00031, 0, 0) && _Symbol == OrderSymbol() && Magic == OrderMagicNumber()) {
                if (Gi_0002F == -1 || OrderType() == Gi_0002F) {
                    Gi_00030 = Gi_00030 + 1;
                }
            }
            Gi_00031 = Gi_00031 - 1;
        } while (Gi_00031 >= 0);
    }
    if (Gi_00030 > 0 && (GetBid() >= Id_00060) && (Id_00070 >= MinProfit)) {
        Gi_00032 = -1;
        Gi_0004D = OrdersTotal() - 1;
        Gi_00033 = Gi_0004D;
        if (Gi_0004D >= 0) {
            do {
                if (OrderSelect(Gi_00033, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
                    Gd_0004D = OrderProfit();
                    Gd_0004D = (Gd_0004D + OrderSwap());
                    if (((Gd_0004D + OrderCommission()) < 0)) {
                        if (OrderType() == OP_BUY) {
                            if (Gi_00032 == 0 || Gi_00032 == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetBid(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                        if (OrderType() == OP_SELL) {
                            if (Gi_00032 == 1 || Gi_00032 == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetAsk(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                    }
                }
                Gi_00033 = Gi_00033 - 1;
            } while (Gi_00033 >= 0);
        }
        Gi_00034 = -1;
        Gi_00051 = OrdersTotal() - 1;
        Gi_00035 = Gi_00051;
        if (Gi_00051 >= 0) {
            do {
                if (OrderSelect(Gi_00035, 0, 0) && OrderSymbol() == _Symbol && OrderMagicNumber() == Magic) {
                    Gd_00051 = OrderProfit();
                    Gd_00051 = (Gd_00051 + OrderSwap());
                    if (((Gd_00051 + OrderCommission()) > 0)) {
                        if (OrderType() == OP_BUY) {
                            if (Gi_00034 == 0 || Gi_00034 == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetBid(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                        if (OrderType() == OP_SELL) {
                            if (Gi_00034 == 1 || Gi_00034 == -1) {
                                RefreshRates();
                                if(!OrderClose(OrderTicket(), OrderLots(), NormalizeDouble(GetAsk(), (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS)), 10, 16777215)) Print("Failed to close order ", OrderTicket(), " Error: ", GetLastError());
                            }
                        }
                    }
                }
                Gi_00035 = Gi_00035 - 1;
            } while (Gi_00035 >= 0);
        }
    }

    // ======== DASHBOARD DISPLAY ========
    int __tot = ObjectsTotal(0, -1, -1);
    for(int __i = __tot-1; __i >= 0; __i--){
       string __nm = ObjectName(0,__i);
       if(StringFind(__nm,"INFO_",0)==0 || __nm=="WWW.POISONIVY.COM")
          ObjectDelete(0,__nm);
    }

    int    openCount=0;
    double openProfitSum=0.0;
    for(int __k=OrdersTotal()-1; __k>=0; __k--){
       if(OrderSelect(__k,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==_Symbol){
          if(RunningPL_AllMagic || OrderMagicNumber()==Magic){
             openCount++;
             openProfitSum += (OrderProfit()+OrderSwap()+OrderCommission());
          }
       }
    }

    if(ObjectFind(0,"IVY_BOX")==-1) ObjectCreate(0,"IVY_BOX",OBJ_RECTANGLE_LABEL,0,0,0);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_CORNER,    DashCorner);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_XDISTANCE, DashX);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_YDISTANCE, DashY);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_XSIZE,     DashWidth);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_YSIZE,     DashHeight);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_BGCOLOR,   clrBlack);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_COLOR,     clrBlack);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_BACK,      true);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_SELECTABLE,false);
    ObjectSetInteger(0,"IVY_BOX",OBJPROP_HIDDEN,    false);

    int lineGap = DashFontSize + 8;
    int TitleY  = DashY + 10;
    int R1 = DashY + 32;
    int R2 = R1 + lineGap;
    int R3 = R2 + lineGap;
    int R4 = R3 + lineGap;
    int R5 = R4 + lineGap;
    int R6 = R5 + lineGap;
    int R7 = R6 + lineGap; // New row for countdown
    int L1 = DashX + 12;     int V1 = L1 + 120; // Adjusted value column
    int L2 = DashX + 230;    int V2 = L2 + 120;

    IvyLabel("IVY_TTL",    DashX+12, TitleY, "POISON IVY v1.9", clrLime);
    IvyLabel("IVY_DIST_C", L1, R1, "Distance:",              clrSilver);
    IvyLabel("IVY_DIST_V", V1, R1, IntegerToString(Dist),    clrWhite);
    IvyLabel("IVY_FROM_C", L1, R2, "FROM:",                  clrSilver);
    IvyLabel("IVY_FROM_V", V1, R2, IntegerToString(TimeStart), clrWhite);
    IvyLabel("IVY_TO_C",   L1, R3, "TO:",                    clrSilver);
    IvyLabel("IVY_TO_V",   V1, R3, IntegerToString(TimeEnd), clrWhite);
    IvyLabel("IVY_STEP_C", L1, R4, "Step in pips:",          clrSilver);
    IvyLabel("IVY_STEP_V", V1, R4, IntegerToString(Step),    clrWhite);
    IvyLabel("IVY_RISK_C",  L2, R1, "Risk Percent:",           clrSilver);
    IvyLabel("IVY_RISK_V",  V2, R1, DoubleToString(Risk,2),    clrWhite);
    IvyLabel("IVY_MULTI_C", L2, R2, "Multi Size:",             clrSilver);
    IvyLabel("IVY_MULTI_V", V2, R2, DoubleToString(UpLot,2),   clrWhite);
    IvyLabel("IVY_LOT_C",   L2, R3, "Lot:",                    clrSilver);
    IvyLabel("IVY_LOT_V",   V2, R3, DoubleToString(Id_00040,2), clrWhite);
    IvyLabel("IVY_POS_C",   L2, R4, "Positions:",              clrSilver);
    IvyLabel("IVY_POS_V",   V2, R4, IntegerToString(openCount), clrWhite);
    IvyLabel("IVY_PCT_C",   L1, R5, "Current Profit %:",        clrSilver);
    IvyLabel("IVY_PCT_V",   V1, R5, DoubleToString(Id_00070,2)+"%", (Id_00070>=0?clrLime:clrTomato));
    IvyLabel("IVY_BAL_C",   L2, R5, "Balance:",                 clrSilver);
    IvyLabel("IVY_BAL_V",   V2, R5, DoubleToString(AccountBalance(),2), clrWhite);

    if(ShowRunningProfit){
       color rcol = (openProfitSum>=0 ? clrLime : clrTomato);
       IvyLabel("IVY_RPL_C", L1, R6, "Running P/L:", clrSilver);
       IvyLabel("IVY_RPL_V", V1, R6, DoubleToString(openProfitSum,2), rcol);
    }else{
       ObjectDelete(0,"IVY_RPL_C");
       ObjectDelete(0,"IVY_RPL_V");
    }

    string ns = "OFF";
    color news_color = clrWhite;
    if(UseNewsFilter) {
       ns = "LOADING...";
       news_color = clrOrange;
       if(g_news_filter_enabled && g_news_loaded) {
          ns = "READY [" + IntegerToString(g_news_count) + "]";
          news_color = clrWhite;
       } else if(!g_news_filter_enabled) {
          ns = "DISABLED";
          news_color = clrRed;
       }
    }
    IvyLabel("IVY_NEWS_C", L2, R6, "News Feed:", clrSilver);
    IvyLabel("IVY_NEWS_V", V2, R6, ns, news_color);
    
    // --- Persistent Trade Status Display ---
    string status_text;
    color status_color;
    if(!UseNewsFilter || !g_news_filter_enabled) {
        status_text = "OFF";
        status_color = clrGray;
    } else if (IsNewsSafeToTrade()) {
        status_text = "Unblocked";
        status_color = clrLime;
    } else {
        if(g_is_high_impact_day_block) {
            status_text = "BLOCKED (High Impact Day)";
            status_color = clrYellow;
        } else {
            status_text = "BLOCKED (Unblocks in " + IntegerToString(g_minutes_until_unblock) + " mins)";
            status_color = clrOrange;
        }
    }
    IvyLabel("IVY_STATUS_C", L1, R7, "News Trade Status:", clrSilver);
    IvyLabel("IVY_STATUS_V", V1, R7, status_text, status_color);


    int btnY  = DashY + DashHeight + 8;
    int btnW  = 120, btnH = 22;
    int bX1   = DashX + 10;
    int bX2   = bX1 + btnW + 8;
    int bX3   = bX2 + btnW + 8;
    string btnBuy="TRADEs_B", btnSell="TRADEs_S", btnClose="TRADEs_C";

    if(ShowManualBuySell){
       if(ObjectFind(0, btnBuy)==-1) ObjectCreate(0, btnBuy, OBJ_BUTTON, 0, 0, 0);
       ObjectSetInteger(0, btnBuy, OBJPROP_CORNER,    DashCorner);
       ObjectSetInteger(0, btnBuy, OBJPROP_XDISTANCE, bX1);
       ObjectSetInteger(0, btnBuy, OBJPROP_YDISTANCE, btnY);
       ObjectSetInteger(0, btnBuy, OBJPROP_XSIZE,     btnW);
       ObjectSetInteger(0, btnBuy, OBJPROP_YSIZE,     btnH);
       ObjectSetInteger(0, btnBuy, OBJPROP_BGCOLOR,   clrBlue);
       ObjectSetInteger(0, btnBuy, OBJPROP_COLOR,     clrWhite);
       ObjectSetInteger(0, btnBuy, OBJPROP_SELECTABLE,false);
       ObjectSetString (0, btnBuy, OBJPROP_FONT,      "Arial");
       ObjectSetString (0, btnBuy, OBJPROP_TEXT,      "BUY   " + DoubleToString(Id_00040,2));

       if(ObjectFind(0, btnSell)==-1) ObjectCreate(0, btnSell, OBJ_BUTTON, 0, 0, 0);
       ObjectSetInteger(0, btnSell, OBJPROP_CORNER,    DashCorner);
       ObjectSetInteger(0, btnSell, OBJPROP_XDISTANCE, bX2);
       ObjectSetInteger(0, btnSell, OBJPROP_YDISTANCE, btnY);
       ObjectSetInteger(0, btnSell, OBJPROP_XSIZE,     btnW);
       ObjectSetInteger(0, btnSell, OBJPROP_YSIZE,     btnH);
       ObjectSetInteger(0, btnSell, OBJPROP_BGCOLOR,   clrYellow);
       ObjectSetInteger(0, btnSell, OBJPROP_COLOR,     clrBlack);
       ObjectSetInteger(0, btnSell, OBJPROP_SELECTABLE,false);
       ObjectSetString (0, btnSell, OBJPROP_FONT,      "Arial");
       ObjectSetString (0, btnSell, OBJPROP_TEXT,      "SELL  " + DoubleToString(Id_00040,2));
    }else{
       ObjectDelete(0, btnBuy);
       ObjectDelete(0, btnSell);
    }

    if(ObjectFind(0, btnClose)==-1) ObjectCreate(0, btnClose, OBJ_BUTTON, 0, 0, 0);
    ObjectSetInteger(0, btnClose, OBJPROP_CORNER,    DashCorner);
    ObjectSetInteger(0, btnClose, OBJPROP_XDISTANCE, bX3);
    ObjectSetInteger(0, btnClose, OBJPROP_YDISTANCE, btnY);
    ObjectSetInteger(0, btnClose, OBJPROP_XSIZE,     btnW);
    ObjectSetInteger(0, btnClose, OBJPROP_YSIZE,     btnH);
    ObjectSetInteger(0, btnClose, OBJPROP_BGCOLOR,   clrPink);
    ObjectSetInteger(0, btnClose, OBJPROP_COLOR,     clrBlack);
    ObjectSetInteger(0, btnClose, OBJPROP_SELECTABLE,false);
    ObjectSetString (0, btnClose, OBJPROP_FONT,      "Arial");
    ObjectSetString (0, btnClose, OBJPROP_TEXT,      "CLOSE ALL");
}

// =====================================================================
// DEINIT FUNCTION
// =====================================================================
void OnDeinit(const int reason)
{
    int __tot = ObjectsTotal(0, -1, -1);
    for(int __i = __tot-1; __i >= 0; __i--){
        string __nm = ObjectName(0,__i);
        if(StringFind(__nm,"IVY_",0)==0 || StringFind(__nm,"INFO_",0)==0 || __nm=="WWW.POISONIVY.COM")
            ObjectDelete(0,__nm);
    }
    ObjectDelete(0,"IVY_BOX");
    ObjectDelete(0,"TRADEs_B");
    ObjectDelete(0,"TRADEs_S");
    ObjectDelete(0,"TRADEs_C");
    ObjectsDeleteAll(0, 1);
}

// =====================================================================
// CHART EVENT HANDLER
// =====================================================================
void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   if(id==CHARTEVENT_KEYDOWN) {
      if(lparam=='R') {
         Print("Forcing news refresh...");
         VerifyNewsFilterLive();
         return;
      }
   }
   
   if(id!=CHARTEVENT_OBJECT_CLICK) return;

   if(ShowManualBuySell && sparam=="TRADEs_B")
   {
      if(!IsNewsSafeToTrade()){ Alert("News filter: manual BUY blocked."); return; }
      double slPrice = 0, tpPrice = 0, currentLot = Id_00040;
      if (StopLossDollars > 0 && currentLot > 0) {
         double tv = MarketInfo(_Symbol, MODE_TICKVALUE);
         double ts = MarketInfo(_Symbol, MODE_TICKSIZE); if(ts<=0) ts=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double p  = (tv>0) ? (StopLossDollars/currentLot) * (ts/tv) : 0;
         slPrice   = NormalizeDouble(GetAsk() - p, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      }
      if (TakeProfitDollars > 0 && currentLot > 0) {
         double tv = MarketInfo(_Symbol, MODE_TICKVALUE);
         double ts = MarketInfo(_Symbol, MODE_TICKSIZE); if(ts<=0) ts=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double p  = (tv>0) ? (TakeProfitDollars/currentLot) * (ts/tv) : 0;
         tpPrice   = NormalizeDouble(GetAsk() + p, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      }
      if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled())
      {
         double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), OP_BUY);
         SanitizeStops(OP_BUY, GetAsk(), slPrice, tpPrice);
         if(lotToSend>0) {
            int ticket = OrderSend(_Symbol, OP_BUY, lotToSend, GetAsk(), 10, 0, 0, "POISON IVY", Magic, 0, clrBlue);
            if(ticket > 0) TrySetStopsLater(ticket, slPrice, tpPrice);
         }
      }
   }
   else if(ShowManualBuySell && sparam=="TRADEs_S")
   {
      if(!IsNewsSafeToTrade()){ Alert("News filter: manual SELL blocked."); return; }
      double slPrice = 0, tpPrice = 0, currentLot = Id_00040;
      if (StopLossDollars > 0 && currentLot > 0) {
         double tv = MarketInfo(_Symbol, MODE_TICKVALUE);
         double ts = MarketInfo(_Symbol, MODE_TICKSIZE); if(ts<=0) ts=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double p  = (tv>0) ? (StopLossDollars/currentLot) * (ts/tv) : 0;
         slPrice   = NormalizeDouble(GetBid() + p, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      }
      if (TakeProfitDollars > 0 && currentLot > 0) {
         double tv = MarketInfo(_Symbol, MODE_TICKVALUE);
         double ts = MarketInfo(_Symbol, MODE_TICKSIZE); if(ts<=0) ts=SymbolInfoDouble(_Symbol, SYMBOL_POINT);
         double p  = (tv>0) ? (TakeProfitDollars/currentLot) * (ts/tv) : 0;
         tpPrice   = NormalizeDouble(GetBid() - p, (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS));
      }
      if(IsTradingAllowedNow() && IsNewOrderAllowed() && IsDayEnabled())
      {
         double lotToSend = FitLotsToFreeMargin(_Symbol, AdjustLots(currentLot), OP_SELL);
         SanitizeStops(OP_SELL, GetBid(), slPrice, tpPrice);
         if(lotToSend>0) {
            int ticket = OrderSend(_Symbol, OP_SELL, lotToSend, GetBid(), 10, 0, 0, "POISON IVY", Magic, 0, clrYellow);
            if(ticket > 0) TrySetStopsLater(ticket, slPrice, tpPrice);
         }
      }
   }
   else if(sparam=="TRADEs_C")
   {
      bool ok = CloseAllPositions();
      if(!ok) Alert("Close All: some orders failed to close. Check Journal for details.");
   }

   ChartRedraw(0);
}
// =====================================================================
// END OF FILE
// =====================================================================