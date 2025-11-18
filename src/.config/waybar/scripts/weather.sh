#!/bin/bash

STATE_FILE="/tmp/waybar_weather_unit"

# Handle toggle
if [ "$1" = "toggle" ]; then
    if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "f" ]; then
        echo "c" > "$STATE_FILE"
    else
        echo "f" > "$STATE_FILE"
    fi
    # Force waybar to update
    pkill -RTMIN+8 waybar
    exit 0
fi

# get unit, defaults to f
if [ -f "$STATE_FILE" ]; then
    unit=$(cat "$STATE_FILE")
else
    unit="f"
    echo "f" > "$STATE_FILE"
fi

# Determine unit parameter for wttr.in
if [ "$unit" = "f" ]; then
    unit_param="u"
else
    unit_param="m"
fi

# Format: icon|temp|feels_like|condition|humidity|wind|precipitation|pressure|location
weather_data=$(curl -s "wttr.in/?format=%c|%t|%f|%C|%h|%w|%p|%P|%l&$unit_param" 2>/dev/null)
IFS='|' read -r weather_code temperature feels_like condition humidity wind_speed precipitation pressure location <<< "$weather_data"
temperature=$(echo "$temperature" | sed 's/+//g')
feels_like=$(echo "$feels_like" | sed 's/+//g')
case "$weather_code" in
    "✨ "|"Clear") icon="󰖙" ;;                   # Clear/Sunny
    "⛅️ "|"Partly cloudy") icon="󰖕" ;;           # Partly cloudy
    "☁️ "|"Cloudy") icon="󰖐" ;;                  # Cloudy
    "🌫️ "|"Fog") icon="󰖑" ;;                     # Fog
    "🌧️ "|"Rain"|"Light rain") icon="󰖖" ;;       # Rain
    "⛈️ "|"Thunderstorm") icon="󰙾" ;;            # Thunderstorm
    "🌨️ "|"Snow") icon="󰖘" ;;                    # Snow
    "🌦️ "|"Light showers") icon="󰼳" ;;           # Light showers
    *) icon="󰖙" ;;                               # Default = sunny
esac
# Construct tooltip
tooltip=" $location\n\n"
tooltip+="  $temperature\n"
tooltip+="  Feels like $feels_like\n"
tooltip+="$icon  $condition\n"
tooltip+="  $humidity\n"
tooltip+="  $wind_speed\n"
tooltip+="  $precipitation\n"
tooltip+="󱤊  $pressure\n"
tooltip+="\n󰳽 to toggle °C/°F"
echo "{\"text\":\"$icon $temperature\",\"tooltip\":\"<big>Weather</big>\n$tooltip\"}"
