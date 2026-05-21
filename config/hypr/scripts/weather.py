#!/usr/bin/env python

import subprocess
from pyquery import PyQuery  # install using `pip install pyquery`
import json
import re

# ----------------- WEATHER ICONS -----------------
weather_icons = {
    "sunnyDay": "🌤",
    "clearNight": "望",
    "cloudyFoggyDay": "",
    "cloudyFoggyNight": "",
    "rainyDay": "",
    "rainyNight": "",
    "snowyIcyDay": "",
    "snowyIcyNight": "",
    "severe": "",
    "default": "",
}

# ----------------- LOCATION ID -----------------
# Replace with your location_id from weather.com
location_id = "1dfd9660dbe0df9c570b3b6d0fccf40489a6f7ad9093e9daff9e3b12ae33e1a4"

# ----------------- FETCH HTML -----------------
url = f"https://weather.com/en-IN/weather/today/l/{location_id}"
html_data = PyQuery(url=url)

# ----------------- CURRENT TEMPERATURE -----------------
temp_elem = html_data("span[data-testid='TemperatureValue']")
temp = temp_elem.eq(0).text() if temp_elem else "--"

# ----------------- CURRENT STATUS -----------------
status_elem = html_data("div[data-testid='wxPhrase']")
status = status_elem.text() if status_elem else "Unknown"
status = f"{status[:16]}.." if len(status) > 17 else status

# ----------------- STATUS CODE (SAFE) -----------------
status_code = "default"
region_header = html_data("#regionHeader")
if region_header:
    class_attr = region_header.attr("class")
    if class_attr:
        # match something like WeatherCode-sunnyDay
        match = re.search(r"WeatherCode-(\w+)", class_attr)
        if match:
            status_code = match.group(1)

# ----------------- STATUS ICON -----------------
icon = weather_icons.get(status_code, weather_icons["default"])

# ----------------- FEELS LIKE -----------------
feels_elem = html_data(
    "div[data-testid='FeelsLikeSection'] > span > span[data-testid='TemperatureValue']"
)
temp_feel = feels_elem.text() if feels_elem else "--"
temp_feel_text = f"Feels like {temp_feel}c"

# ----------------- MIN/MAX TEMPERATURE -----------------
min_elem = html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(0)
max_elem = html_data("div[data-testid='wxData'] > span[data-testid='TemperatureValue']").eq(1)
temp_min = min_elem.text() if min_elem else "--"
temp_max = max_elem.text() if max_elem else "--"
temp_min_max = f"  {temp_min}\t\t  {temp_max}"

# ----------------- WIND SPEED -----------------
wind_elem = html_data("span[data-testid='Wind']")
wind_speed = wind_elem.text().split("\n")[1] if wind_elem and "\n" in wind_elem.text() else "--"
wind_text = f"煮  {wind_speed}"

# ----------------- HUMIDITY -----------------
humidity_elem = html_data("span[data-testid='PercentageValue']")
humidity = humidity_elem.text() if humidity_elem else "--"
humidity_text = f"  {humidity}"

# ----------------- VISIBILITY -----------------
visibility_elem = html_data("span[data-testid='VisibilityValue']")
visibility = visibility_elem.text() if visibility_elem else "--"
visibility_text = f"  {visibility}"

# ----------------- AIR QUALITY INDEX -----------------
aqi_elem = html_data("text[data-testid='DonutChartValue']")
air_quality_index = aqi_elem.text() if aqi_elem else "--"

# ----------------- HOURLY RAIN PREDICTION -----------------
hourly_elem = html_data("section[aria-label='Hourly Forecast']")(
    "div[data-testid='SegmentPrecipPercentage'] > span"
)
prediction = hourly_elem.text() if hourly_elem else ""
prediction = prediction.replace("Chance of Rain", "")
prediction = f"\n\n    (hourly) {prediction}" if prediction else ""

# ----------------- TOOLTIP TEXT -----------------
tooltip_text = str.format(
    "\t\t{}\t\t\n{}\n{}\n{}\n\n{}\n{}\n{}{}",
    f'<span size="xx-large">{temp}</span>',
    f"<big>{icon}</big>",
    f"<big>{status}</big>",
    f"<small>{temp_feel_text}</small>",
    f"<big>{temp_min_max}</big>",
    f"{wind_text}\t{humidity_text}",
    f"{visibility_text}\tAQI {air_quality_index}",
    f"<i>{prediction}</i>",
)

# ----------------- OUTPUT FOR WAYBAR -----------------
temp_with_degree_symbol = temp + "C"
out_data = {
    "text": f"{icon}   {temp_with_degree_symbol}",
    "alt": status,
    "tooltip": tooltip_text,
    "class": status_code,
}

print(json.dumps(out_data))
