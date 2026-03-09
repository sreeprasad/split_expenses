# 💸 Expense Splitter

A lightweight Bash script to track shared expenses and calculate who owes whom. It does not install any apps, or accounts, no internet required.

## Features

- Add expenses with payer, description, and amount
- Automatically calculates each person's fair share
- Persistent ledger stored as a plain text file
- Works entirely in the terminal

## Requirements

- Bash 4+ (macOS users: `brew install bash`)
- `bc` (usually pre installed on Linux/macOS)

## Usage

```bash
chmod +x split_expenses.sh
./split_expenses.sh
```

You'll see a simple menu:

```
1) Add  2) Settle  3) Clear  4) Exit
>
```

### Adding an expense

```
Who paid? Utki
What for? Groceries
Amount: 60
✓ Added
```

### Settling up

Random example
```
Total: $120.00 | Individual Share: $40.00
--------------------------------
Settlement Plan:
SP pays Utki: $40.00
Abhishek pays Utki: $40.00 
```

## How It Works

Expenses are stored in `expenses.txt` as pipe-delimited records:

```
Utki|Groceries|60
Abhishek|Taxi|30
SP|Dinner|30
```

At settlement time the script:

1. Computes each person's net balance (`amount paid − fair share`)
2. Separates people into creditors (owed money) and debtors (owe money)
3. Matches largest debtor to largest creditor first (greedy), minimizing the number of transfers in most practical cases

### Why not optimal (minimum transactions) algorithm?

For groups of 3–7 people the greedy approach produces optimal or near optimal results. The theoretical worst case requires 10+ people with a very specific balance distribution which is unlikely in real world use.

## Precision

The script uses `scale=3` in `bc` for all division, giving subcent precision. Real world rounding differences of `$0.001` are negligible.

## Limitations

- Requires Bash 4+ (associative arrays)
- Not ideal for 10+ people but not for larger groups
- No multi currency support

## License

MIT
