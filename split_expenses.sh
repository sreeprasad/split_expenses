#!/bin/bash

LEDGER="expenses.txt"
touch "$LEDGER"

add_expense() {
    read -p "Who paid? " person
    read -p "What for? " item
    read -p "Amount: " amount
    echo "$person|$item|$amount" >> "$LEDGER"
}

calculate_settlement() {
    if [ ! -s "$LEDGER" ]; then echo "Ledger empty!"; return; fi

    
    names=($(awk -F'|' '{print $1}' "$LEDGER" | sort -u))
    num_people=${#names[@]}
    total_spent=$(awk -F'|' '{sum+=$3} END {print sum}' "$LEDGER")
    share=$(echo "scale=2; $total_spent / $num_people" | bc)

    echo "Total: \$$total_spent | Individual Share: \$$share"
    echo "--------------------------------"

    balance_names=()
    balance_vals=()
    for name in "${names[@]}"; do
        paid=$(awk -F'|' -v n="$name" '$1==n {sum+=$3} END {print sum+0}' "$LEDGER")
        balance_names+=("$name")
        balance_vals+=($(echo "$paid - $share" | bc))
    done
 
    echo "Settlement Plan:"

    temp_creditors=$(mktemp)
    temp_debtors=$(mktemp)

    for i in "${!balance_names[@]}"; do
        name=${balance_names[$i]}
        val=${balance_vals[$i]}
        if (( $(echo "$val > 0" | bc -l) )); then
            echo "$val $name" >> "$temp_creditors"
        elif (( $(echo "$val < 0" | bc -l) )); then
            echo "${val#-} $name" >> "$temp_debtors"
        fi
    done

    sort -rn -o "$temp_creditors" "$temp_creditors"
    sort -rn -o "$temp_debtors" "$temp_debtors"

    exec 3<"$temp_creditors"
    exec 4<"$temp_debtors"

    read -u 3 c_amt c_name
    read -u 4 d_amt d_name

    while [[ -n "$c_amt" && -n "$d_amt" ]]; do
        if (( $(echo "$c_amt < $d_amt" | bc -l) )); then
            transfer=$c_amt
        else
            transfer=$d_amt
        fi

        echo "$d_name pays $c_name: \$$transfer"

  
        c_amt=$(echo "$c_amt - $transfer" | bc | sed 's/^-0$/0/')
        d_amt=$(echo "$d_amt - $transfer" | bc | sed 's/^-0$/0/')

        if (( $(echo "$c_amt == 0" | bc -l) )); then read -u 3 c_amt c_name || c_amt=""; fi
        if (( $(echo "$d_amt == 0" | bc -l) )); then read -u 4 d_amt d_name || d_amt=""; fi
    done


    exec 3<&-
    exec 4<&-

    rm "$temp_creditors" "$temp_debtors" 2>/dev/null
}


while true; do
    echo -e "\n1) Add 2) Settle 3) Clear 4) Exit"
    read -p "> " choice
    case $choice in
        1) add_expense ;;
        2) calculate_settlement ;;
        3) > "$LEDGER" ;;
        4) exit 0 ;;
    esac
done
