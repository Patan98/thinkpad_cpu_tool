#!/bin/bash

#############################################################################################################################################################################
#███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████
#██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██
#█████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████
#██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██
#██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████
#############################################################################################################################################################################
HELP() # SHOW HELP MESSAGE
{
    echo "This is a script to manage CPU power"
    echo
    echo "Options:"
    echo "-h --help            Show this help message"
    echo ""
    echo "-s --switch          Change setting"
    echo ""
    echo "-m --monitor         Turn on monitor mode"
    echo ""
    echo "-b --boost           Turn on/off boost mode"
    echo ""
}

SWITCH()
{
    CPU_NOW=$(cat /sys/devices/system/cpu/intel_pstate/max_perf_pct)

    if [ $CPU_NOW = "37" ];
    then
        SWITCH_EXEC -70
        echo 70 > "/home/YOURUSERNAME/code_data/Bash/cpu_state.txt"
        NOTIFY "Processore impostato al 70%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore al 70 per 100"

    elif [ $CPU_NOW = "70" ]
    then
        SWITCH_EXEC -100
        echo 100 > "/home/YOURUSERNAME/code_data/Bash/cpu_state.txt"
        NOTIFY "Processore impostato al 100%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore al 100 per 100"

    elif [ $CPU_NOW = "100" ]
    then
        SWITCH_EXEC -37
        echo 37 > "/home/YOURUSERNAME/code_data/Bash/cpu_state.txt"
        NOTIFY "Processore impostato al 37%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore al 37 per 100"

    elif [ $CPU_NOW != "37" ] && [ $CPU_NOW != "70" ] && [ $CPU_NOW != "100" ]
    then
        SWITCH_EXEC -37
        echo 37 > "/home/YOURUSERNAME/code_data/Bash/cpu_state.txt"
        NOTIFY "Processore resettato al 37%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore resettato al 37 per 100"

    else
        echo "Qualcosa non ha funzionato (cpu.sh)"
        NOTIFY "Qualcosa non ha funzionato"
        /home/YOURUSERNAME/code/Bash/pico.sh "Qualcosa non ha funzionato"

    fi
}

SWITCH_EXEC()
{
    CPU_CLOCK_PATH="/sys/devices/system/cpu/intel_pstate/max_perf_pct"
    CPU_TURBO_PATH="/sys/devices/system/cpu/intel_pstate/no_turbo"
    GPU_CLOCK_PATH="/sys/class/drm/card0/gt_max_freq_mhz"
    GPU_TURBO_PATH="/sys/class/drm/card0/gt_boost_freq_mhz"

    if  [ $1 = "-37" ];
    then
        echo 37 > $CPU_CLOCK_PATH
        echo 1 > $CPU_TURBO_PATH
        echo 650 > $GPU_CLOCK_PATH
        echo 650 > $GPU_TURBO_PATH

    elif [ $1 = "-60" ]
    then
        echo 60 > $CPU_CLOCK_PATH
        echo 0 > $CPU_TURBO_PATH
        echo 800 > $GPU_CLOCK_PATH
        echo 800 > $GPU_TURBO_PATH

    elif [ $1 = "-70" ]
    then
        echo 70 > $CPU_CLOCK_PATH
        echo 0 > $CPU_TURBO_PATH
        echo 900 > $GPU_CLOCK_PATH
        echo 900 > $GPU_TURBO_PATH

    elif [ $1 = "-85" ]
    then
        echo 85 > $CPU_CLOCK_PATH
        echo 0 > $CPU_TURBO_PATH
        echo 1150 > $GPU_CLOCK_PATH
        echo 1150 > $GPU_TURBO_PATH

    elif [ $1 = "-100" ]
    then
        echo 100 > $CPU_CLOCK_PATH
        echo 0 > $CPU_TURBO_PATH
        echo 1150 > $GPU_CLOCK_PATH
        echo 1150 > $GPU_TURBO_PATH

    else
        break

    fi
}

MONITOR()
{
    sleep 3

    STATE_PATH="/home/YOURUSERNAME/code_data/Bash/cpu_state.txt"
    echo "$(cat "/sys/devices/system/cpu/intel_pstate/max_perf_pct")" > $STATE_PATH

    COUNTER_ALLARM=0
    COUNTER_RESET=0
    ALLARM=0

    while true
    do
        TEMPERATURE=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)
        USAGE=$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]

        # OVERHEATING
        if [ "$TEMPERATURE" -gt "79000" ];
        then
            EMERGENCY "$(cat /sys/devices/system/cpu/intel_pstate/max_perf_pct)"
            ALLARM=1
            COUNTER_ALLARM=0

        else
            # WARNING
            if [ "$TEMPERATURE" -gt "74000" ];
            then
                COUNTER_ALLARM=$((COUNTER_ALLARM+1))

            else
                COUNTER_ALLARM=0
            fi

            # ALLARM
            if [ "$COUNTER_ALLARM" -gt "15" ];
            then
                EMERGENCY "$(cat /sys/devices/system/cpu/intel_pstate/max_perf_pct)"
                ALLARM=1
                COUNTER_ALLARM=0
            fi

            # CHECK
            if [ "$TEMPERATURE" -lt "70000" ];
            then
                COUNTER_RESET=$((COUNTER_RESET+1))

            else
                COUNTER_RESET=0
            fi

            # RESET
            if [ "$COUNTER_RESET" -gt "15" ] && [ "$ALLARM" -gt "0" ] && [ "$USAGE" -lt "75" ];
            then
                RESET "$(cat $STATE_PATH)"
                NOTIFY "Protezione processore disattivata"
                /home/YOURUSERNAME/code/Bash/pico.sh "Protezione processore disattivata"
                ALLARM=0
            fi

        fi

        sleep 1
    done
}

EMERGENCY()
{
    TEMPLATES='37, 60, 70, 85, 100'
    STATE="$1"

    # EXAMPLE
    # STEP 1
    #                                                     CURRENT
    # 0---------37---------60---------70---------85---------100
    #                                           NEW
    # 0---------37---------60---------70---------85---------100

    # STEP 2
    #                                          CURRENT
    # 0---------37---------60---------70---------85---------100
    #                                NEW
    # 0---------37---------60---------70---------85---------100

    A=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '1,1p' | xargs)
    B=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '2,2p' | xargs)
    C=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '3,3p' | xargs)

    BmA="$((B - A))"
    CmB="$((C - B))"

    if (( "$BmA" < "$CmB" ));
    then
        CURRENT=$A
        NEW=$(echo $TEMPLATES | tr , '\n' | sort -n | grep -B 1 "$CURRENT" | grep -v "$CURRENT" | xargs)
        SWITCH_EXEC -"$NEW"
        NOTIFY "Processore in protezione al $NEW%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore in protezione al $NEW per cento"

    elif (( "$CmB" < "$BmA" ))
    then
        CURRENT=$C
        NEW=$(echo $TEMPLATES | tr , '\n' | sort -n | grep -B 1 "$CURRENT" | grep -v "$CURRENT" | xargs)
        SWITCH_EXEC -"$NEW"
        NOTIFY "Processore in protezione al $NEW%"
        /home/YOURUSERNAME/code/Bash/pico.sh "Processore in protezione al $NEW per cento"
    fi
}

RESET()
{
    TEMPLATES='37, 60, 70, 85, 100'
    STATE=$1

    A=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '1,1p' | xargs)
    B=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '2,2p' | xargs)
    C=$(echo $TEMPLATES, $STATE | tr , '\n' | sort -n | grep -C1 $STATE | sed -n '3,3p' | xargs)

    BmA="$((B - A))"
    CmB="$((C - B))"

    if (( "$BmA" < "$CmB" ));
    then
        SWITCH_EXEC -$A;

    elif (( "$CmB" < "$BmA" ))
    then
        SWITCH_EXEC -$C;
    fi
}

BOOST()
{
    # LISTS ALL THE PID MATCHING WITH CPU.SH IN MONITOR MODE
    PIDS="$(ps -ax | grep "[/]home/YOURUSERNAME/code/Bash/cpu.sh -m" | awk '{print $1}')"

    # IF THERE ARE SOME, STOPS CPU.SH IN MONITOR MODE
    if [ ! -z "$PIDS" ];
    then
        NOTIFY "Boost processore attivato"
        /home/YOURUSERNAME/code/Bash/pico.sh "Boost processore attivato"

        # KILLS ALL THE PIDS OF CPU.SH IN MONITOR MODE
        while IFS= read -r PID;
        do
            sudo kill "$PID"
        done <<< "$PIDS"

        COUNTER=0

        while true
        do
            TEMPERATURE=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon*/temp1_input)

            # IF OVERHEATING, RESTORE CPU.SH IN MONITOR MODE
            if [ "$TEMPERATURE" -gt "85000" ];
            then
                if [ $COUNTER -gt 5 ];
                then
                    NOTIFY "Boost processore disattivato"
                    /home/YOURUSERNAME/code/Bash/pico.sh "Boost processore disattivato"

                    sudo /home/YOURUSERNAME/code/Bash/cpu.sh -m &

                    # KILLS ALL THE PIDS OF CPU.SH IN BOOST MODE
                    PIDBOOST="$(ps -ax | grep "[/]home/YOURUSERNAME/code/Bash/cpu.sh -b" | awk '{print $1}')"
                    while IFS= read -r PID;
                    do
                        sudo kill "$PID"
                    done <<< "$PIDBOOST"
                fi

                COUNTER=$(($COUNTER + 1))

            else
                COUNTER=0
            fi

            sleep 1
        done

    else
        NOTIFY "Boost processore disattivato"
        /home/YOURUSERNAME/code/Bash/pico.sh "Boost processore disattivato"

        sudo /home/YOURUSERNAME/code/Bash/cpu.sh -m &

        # KILLS ALL THE PIDS OF CPU.SH IN BOOST MODE
        PIDBOOST="$(ps -ax | grep "[/]home/YOURUSERNAME/code/Bash/cpu.sh -b" | awk '{print $1}')"
        while IFS= read -r PID;
        do
            sudo kill "$PID"
        done <<< "$PIDBOOST"
    fi
}

function NOTIFY()
{
    # DETECTED THE NAME OF THE DISPLAY IN USE
    local display=":$(ls /tmp/.X11-unix/* | sed 's#/tmp/.X11-unix/X##' | head -n 1)"

    # DETECT THE USER USING SUCH DISPLAY
    local user=$(who | grep '('$display')' | awk '{print $1}' | head -n 1)

    # DETECT THE ID OF THE USER
    local uid=$(id -u $user)

    sudo -u $user DISPLAY=$display DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$uid/bus notify-send "$@"
}
#############################################################################################################################################################################
#███    ███  █████  ██ ███    ██
#████  ████ ██   ██ ██ ████   ██
#██ ████ ██ ███████ ██ ██ ██  ██
#██  ██  ██ ██   ██ ██ ██  ██ ██
#██      ██ ██   ██ ██ ██   ████
#############################################################################################################################################################################
if [ ! -z "$1" ] && [ -z "$2" ];
then
    case $1 in

    -h|--help)
        HELP
        ;;

    -s|--switch)
        SWITCH
        ;;

    -m|--monitor)
        MONITOR
        ;;

    -b|--boost)
        BOOST
        ;;

    *)
        echo "Use -h or --help to get the list of valid options and know what the program does"
        ;;
    esac

elif [ -z "$1" ]
then
    echo "Use -h or --help to get the list of valid options and know what the program does"
fi
#############################################################################################################################################################################
