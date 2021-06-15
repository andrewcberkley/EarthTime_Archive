#import array, csv, math, os, time
import array, csv, math, os, time, datetime
from datetime import timedelta, date, datetime
import calendar

#Windows 10: OverflowError: mktime argument out of range
#https://github.com/neo4j/neo4j-python-driver/issues/302

#Python: Reliably convert a 8601 string to timestamp
#https://stackoverflow.com/questions/12378102/python-reliably-convert-a-8601-string-to-timestamp
#Luckily, Python provides an alternative to mktime() that is what the C library should have provided: calendar.timegm(). With this function, I can rewrite your function like this:

# parsed = parse_date(timestamp)
# timetuple = parsed.timetuple()
# return calendar.timegm(timetuple)

def FormatDateStr(date_str, format_str):
#    return time.mktime(time.strptime(date_str, format_str))
    return calendar.timegm(time.strptime(date_str, format_str))

def LngLatToWebMercator(lnglat):
    (lng, lat) = lnglat
    x = (lng + 180.0) * 256.0 / 360.0
    y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
    return [x, y]


def PackColor(color):
    return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

raw_data = []
with open("HAL_final_black.csv") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)

len(raw_data)

raw_data[0]


#format x,y,packed_color,epoch_0,epoch_1
points = []
for row in raw_data:
  x,y = LngLatToWebMercator([float(row['Longitude']), float(row['Latitude'])])
  packedColor = PackColor([0.6, 0.4, 0.8])
  epoch_0 = FormatDateStr(row['Year'], '%Y')
  epoch_1 = epoch_0 + 60*60*24*28
  points += [x,y,packedColor,epoch_0,epoch_1]
array.array('f', points).tofile(open('HAL_final_black.bin', 'wb'))
#If Python is throwing a "ValueError: could not convert string to float:" error, make sure that *all* NaNs are removed from "date", "latitude", and/or "longitude" columns
#Error in py_run_file_impl(file, local, convert) : OverflowError: mktime argument out of range