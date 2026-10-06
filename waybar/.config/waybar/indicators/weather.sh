#!/bin/bash

icon=$(omarchy-weather-icon 2>/dev/null)
temperature=$(curl -fsS --max-time 4 "https://wttr.in?m&format=%t" 2>/dev/null | tr -d '\n')
temperature=${temperature#+}

if [[ -n $icon && -n $temperature ]]; then
  jq -cn --arg text "$icon $temperature" '{text: $text}'
else
  printf '{"text":"","class":"unavailable"}\n'
fi
