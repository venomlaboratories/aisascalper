# POISON IVY v6.1 - MT4 & MT5 Expert Advisor

This repository contains the Poison Ivy trading EA in both MT4 and MT5 versions with **100% identical trading behavior**.

## Files

- **POISON_IVY_NF1.mq4** - Original MetaTrader 4 version
- **POISON_IVY_NF1.mq5** - MetaTrader 5 version (converted with identical logic)
- **MT5_CONVERSION_NOTES.md** - Detailed documentation of all MT5 changes

## Critical Requirements

### MT5 Version REQUIRES Hedging Mode
The MT5 version **only works with HEDGING accounts**, not NETTING accounts.

**To set up hedging mode:**
1. In MT5, go to **Tools → Options → Trade**
2. Set **Account Type** to **"Hedging"**
3. Restart MT5 if needed

The EA will automatically check this on startup and alert you if the wrong mode is detected.

## Features

### Trading Strategy
- **FlipUp/FlipDown Lines**: Horizontal lines that define entry zones
- **Smart Entry**: 
  - SELL when bearish candle touches FlipDown line
  - BUY when bullish candle touches FlipUp line
- **Grid/Martingale**: Adds positions with lot multiplier based on grid step
- **Smart Exit**: Closes all positions when price touches opposite line with profit

### Risk Management
- **Risk-based lot sizing**: Calculates lot size based on account balance percentage
- **Stop Loss in Dollars**: Set SL based on account currency (not pips)
- **Take Profit in Dollars**: Set TP based on account currency (not pips)
- **Free margin check**: Ensures sufficient margin before opening positions

### News Filter (Multi-Source)
- **Primary Source**: Forex Factory JSON API
- **Backup Source**: DailyFX JSON API
- **Auto-Failover**: Switches to backup if primary fails
- **Configurable Blocking**: 
  - Block trades before/after high impact news
  - Block entire day on high impact news (optional)
  - Separate settings for High/Medium/Low impact

### Day-of-Week Filtering
- Enable/disable trading for each day of the week
- Useful for avoiding weekends or specific market conditions

### Dashboard
- Real-time display of:
  - Account info (balance, equity, margin)
  - Open positions count
  - Running profit/loss
  - News filter status
  - Next scheduled news events
- Optional manual Buy/Sell/Close All buttons

## Installation

### MT4
1. Copy `POISON_IVY_NF1.mq4` to `MetaTrader4/MQL4/Experts/`
2. Restart MT4 or refresh Navigator
3. Add web requests in Tools → Options → Expert Advisors → Allow WebRequest:
   - `https://nfs.faireconomy.media`
   - `https://www.dailyfx.com`
4. Drag EA onto chart

### MT5
1. **FIRST**: Set account to Hedging mode (see above)
2. Copy `POISON_IVY_NF1.mq5` to `MetaTrader5/MQL5/Experts/`
3. Restart MT5 or recompile in MetaEditor
4. Add web requests in Tools → Options → Expert Advisors → Allow WebRequest:
   - `https://nfs.faireconomy.media`
   - `https://www.dailyfx.com`
5. Drag EA onto chart

## Input Parameters

### Core Settings
- `MagicNumber` - Unique identifier for this EA's orders
- `Risk_Percent` - Risk per trade as percentage of balance (e.g., 0.01 = 1%)
- `Distance` - Distance in pips for FlipUp/FlipDown lines from price
- `Step_in_pips` - Distance between grid orders
- `FROM` / `TO` - Trading hours (e.g., 5 to 7 = 05:00 to 07:00)
- `Multi_Size` - Lot multiplier for grid positions

### Visual Settings
- `FlipUpLineColor` - Color of FlipUp line (default: Blue)
- `FlipDownLineColor` - Color of FlipDown line (default: White)

### Risk Management
- `StopLossDollars` - Stop loss in account currency
- `TakeProfitDollars` - Take profit in account currency

### Day Filters
- `EnableMonday` through `EnableSunday` - Enable/disable trading by day

### News Filter
- `UseNewsFilter` - Master switch for news filtering
- `NewsRefreshMinutes` - How often to refresh news data
- `Block_On_High_Impact_Day` - Block all trading on days with high impact news
- `FilterHigh/Medium/Low` - Which impact levels to filter
- `Do_Not_Trade_Before_*_News_in_Mins` - Buffer before news events
- `Start_Trade_After_*_News_in_Mins` - Buffer after news events

### Dashboard
- `ShowManualBuySell` - Show manual trading buttons
- `ShowRunningProfit` - Display running P/L
- `RunningPL_AllMagic` - Include all magic numbers in P/L (or just this EA)

## Default Settings

```
MagicNumber = 12023
Risk_Percent = 0.01 (1%)
Distance = 6 pips
Step_in_pips = 15 pips
FROM = 5 (05:00)
TO = 7 (07:00)
Multi_Size = 1.0
StopLossDollars = 5000.0
TakeProfitDollars = 5000.0
UseNewsFilter = true
```

## Important Notes

1. **Test First**: Always test on demo account before live trading
2. **Hedging Mode (MT5)**: Required - EA will not run without it
3. **Web Requests**: Must be enabled for news filter to work
4. **Account Currency**: SL/TP are in your account currency (USD, EUR, etc.)
5. **Grid Risk**: Martingale/grid systems can use significant margin
6. **News Events**: EA blocks trading around high-impact news by default

## Trading Logic Flow

1. **On Tick**:
   - Refresh news data if needed
   - Calculate lot size based on risk
   - Check FlipUp/FlipDown line positions
   - Move lines if needed

2. **Entry Check**:
   - Is trading hour in range (FROM to TO)?
   - Is current day enabled?
   - Is news filter safe?
   - Is candle direction correct?
   - Is price touching the line?
   - History check: last closed order type

3. **Entry Execution**:
   - Calculate SL/TP in dollars
   - Check free margin
   - Open position
   - Set SL/TP (if allowed by broker stops level)

4. **Grid Logic**:
   - Count existing positions in same direction
   - If price moves Step_in_pips away
   - Open new position with multiplied lot size

5. **Exit Logic**:
   - If price touches opposite line
   - Check total profit >= MinProfit
   - Close all positions for this symbol and magic

## Support & Disclaimer

**Author**: Jeanette Abou Khalil
**Version**: 6.1
**Type**: Grid/Martingale EA with News Filter

**DISCLAIMER**: Trading involves substantial risk. Past performance does not guarantee future results. Always test thoroughly on demo account before using real money. The authors are not responsible for any losses incurred while using this EA.

## License

Copyright © Jeanette Abou Khalil

---

For detailed technical information about the MT5 conversion, see [MT5_CONVERSION_NOTES.md](MT5_CONVERSION_NOTES.md)
