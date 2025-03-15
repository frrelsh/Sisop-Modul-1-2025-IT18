#!/bin/bash

file=$1

case $2 in
    --info)
        awk -F',' 'NR > 1 {
            if ($2+0 > maxUsage) { maxUsage = $2+0; maxPokeUsage = $1 }
            if ($3+0 > maxRaw) { maxRaw = $3+0; maxPokeRaw = $1 }
        }
        END {
            printf "Highest Adjusted Usage: %s with %.4f%%\n", maxPokeUsage, maxUsage;
            printf "Highest Raw Usage: %s with %d uses\n", maxPokeRaw, maxRaw
        }' "$file"
        ;;

    --sort)
        if [[ -z $3 ]]; then
            echo "Error: No sorting column provided"
            echo "Use -h or --help for more information"
            exit 1
        fi
        case $3 in
            usage) column=2 ;;
            rawusage) column=3 ;;
            name) column=1 ;;
            hp) column=6 ;;
            atk) column=7 ;;
            def) column=8 ;;
            spatk) column=9 ;;
            spdef) column=10 ;;
            speed) column=11 ;;
            *) echo "Error: Invalid sorting column"; exit 1 ;;
        esac
        (head -n 1 "$file" && tail -n +2 "$file" | sort -t',' -k$column,${column}nr)
        ;;

    --grep)
        if [[ -z $3 ]]; then
            echo "Error: No name provided"
            echo "Use -h or --help for more information"
            exit 1
        fi
        search_name=$3
        (head -n 1 "$file" && tail -n +2 "$file" | grep -i "^$search_name,")
        ;;

    --filter)
        if [[ -z $3 ]]; then
            echo "Error: No filter type provided"
            echo "Use -h or --help for more information"
            exit 1
        fi
        type_filter=$3
        (head -n 1 "$file" && tail -n +2 "$file" | awk -F',' -v type="$type_filter" '$4 == type || $5 == type' | sort -t',' -k2,2nr)
        ;;

    -h|--help)
        cat << EOF


                                                      ░░
                                                    ▒██▒░
                                                  ░██▒░▓▓░
                                      ░▒▒░▓░    ░▓█▓░░▓█▓▒░     ░░░░░░░
            ░░░▒████████▓░░    ░░░▒▓█████████░░░█████▓░░░░▒███████▓▓▓█▒   ░░▒░░░░░
         ░░▓██▓▒░░░░░░░░▒██▒   ▒██▓░░░░██▓░░▒██▒██▓▒▒▒▒▓█▓███░░░▒█░ ░██░  ░▓██▓▓███▓▒▒▒░░
       ░▓██▒░           ░░▒█▒  ░████░ ░▓▓░  ░░██░░░▒▒░░░░███░   ░▒░ ░▓█░  ░▓███░░░░███▒▓███▓░
       ░▒███▒      ░▒█▓▓░ ░▓▓░░░▒▓██░ ░░   ░▓██░ ▒█░▓▒░▒████░   ░░░ ░░█▓▓█████▓░  ░▒██░  ░█▒
        ░▒███▓█▒   ░░█▒█▓ ░███▒░░░▒█▒    ░▒█▒▓█  ░█▓░▒█▓▒██▓         ▒█▒░▓░░░░▓█░  ░█▒░ ░██░
          ░█████░   ░▓██░░██░░█▒ ░░░▓▓░ ░░░░▓██▒░   ░░   ░▓█▒ ░░░ ░░▒█░░▓█▒░▓░░█▒░░░▒░ ░▒█░
          ░░░▒███░  ░░░░▓██░░░████▓░░█░░▓░░ ░░░██▒░░ ░░▓███░ ░▒█▒░█░▓▒ ░░▒▓▓░ ░█░░░ ░░ ░█▒
              ▓███░  ░▒████   ░░░  ░▓█ ░████▒░░░░▒▓████▓██▓░░░▓████░▒█░      ░█▒░▒░   ░▓▓░
              ░▓██▓░ ░░████▒      ░▓█░ ░█▓▓████▓▒░░▒█  ▒███████████▓░▒█▓▒░▒▒██▒░░▓░   ░█▒
               ░███▒  ░▒█████▓▒▒▓████░▒▒█▓  ░▒▓██████    ░░░░░░▓▓███▓▓▒▓██▓███░ ░█░  ░█▓░
                ░███░  ░█▒░▓████▓░▒███▓▓▒░      ░▒██▓           ░▒▓▓█████░░▓██████░ ░▓█░
                 ▒███▒▓███░                                            ░░     ░▓████▓█▒░░
                 ░▓████▒░                                                       ░▒▓██▓░
                  ░░

      Usage:
        ./pokemon_analysis.sh <file.csv> <command> [options]

      Options:
        --info          : Show highest usage% and raw usage
        --sort <method> : Sort Pokemon by column
                name      Sort by Pokemon name
                usage     Sort by Adjusted Usage
                raw       Sort by Raw Usage
                hp        Sort by HP
                atk       Sort by Attack
                def       Sort by Defense
                spatk     Sort by Special Attack
                spdef     Sort by Special Defense
                speed     Sort by Speed
        --grep <name>   : Search a specific Pokemon
        --filter <type> : Filter Pokemon by type
        -h, --help      : Show this help message
EOF
        exit 0
        ;;
    *)
        echo "Error: Invalid command"
        echo "Use -h or --help for more information."
        exit 1
        ;;
esac

#error handling
if [[ $# -lt 2 ]]; then
    echo "Error: Invalid number of arguments."
    echo "Use -h or --help for more information."
    exit 1
fi
