# import array, csv, math, os, time
# import array, csv, math, os, time, datetime
# from datetime import timedelta, date, datetime
# import calendar

# # Windows 10: OverflowError: mktime argument out of range
# # https://github.com/neo4j/neo4j-python-driver/issues/302

# # Year 2000 (Y2K) issues: Python depends on the platform’s C library, which generally doesn’t have year 2000 issues, since all dates and times are represented internally as seconds since the epoch. Functions accepting a struct_time (see below) generally require a 4-digit year. For backward compatibility, 2-digit years are supported if the module variable accept2dyear is a non-zero integer; this variable is initialized to 1 unless the environment variable PYTHONY2K is set to a non-empty string, in which case it is initialized to 0. Thus, you can set PYTHONY2K to a non-empty string in the environment to require 4-digit years for all year input. When 2-digit years are accepted, they are converted according to the POSIX or X/Open standard: values 69-99 are mapped to 1969-1999, and values 0–68 are mapped to 2000–2068. Values 100–1899 are always illegal.
# # https://docs.python.org/2/library/time.html#time-y2kissues

# # Python: Reliably convert a 8601 string to timestamp
# # https://stackoverflow.com/questions/12378102/python-reliably-convert-a-8601-string-to-timestamp
# # Luckily, Python provides an alternative to mktime() that is what the C library should have provided: calendar.timegm(). With this function, I can rewrite your function like this:

# # parsed = parse_date(timestamp)
# # timetuple = parsed.timetuple()
# # return calendar.timegm(timetuple)

# def FormatDateStr(date_str, format_str):
# #    return time.mktime(time.strptime(date_str, format_str))
#     return calendar.timegm(time.strptime(date_str, format_str))

# def LngLatToWebMercator(lnglat):
#     (lng, lat) = lnglat
#     x = (lng + 180.0) * 256.0 / 360.0
#     y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
#     return [x, y]


# def PackColor(color):
#     return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

# #Black Lynchings
# raw_data = []
# with open("HAL_final_black.csv") as f:
#   reader = csv.DictReader(f, delimiter=",")
#   for row in reader:
#     raw_data.append(row)

# len(raw_data)

# raw_data[0]


# #format x,y,packed_color,epoch_0,epoch_1
# points = []
# for row in raw_data:
#   x,y = LngLatToWebMercator([float(row['Longitude']), float(row['Latitude'])])
#   packedColor = PackColor([255, 255, 0])
#   epoch_0 = FormatDateStr(row['Date'], '%Y-%m')
#   epoch_1 = epoch_0 + 60*60*24*28
#   points += [x,y,packedColor,epoch_0,epoch_1]
# array.array('f', points).tofile(open('HAL_final_black.bin', 'wb'))
# # If Python is throwing a "ValueError: could not convert string to float:" error, make sure that *all* NaNs are removed from "date", "latitude", and/or "longitude" columns
# # Error in py_run_file_impl(file, local, convert) : OverflowError: mktime argument out of range

# #White Lynchings
# raw_data = []
# with open("HAL_final_white.csv") as f:
#   reader = csv.DictReader(f, delimiter=",")
#   for row in reader:
#     raw_data.append(row)

# len(raw_data)

# raw_data[0]

# #format x,y,packed_color,epoch_0,epoch_1
# points = []
# for row in raw_data:
#   x,y = LngLatToWebMercator([float(row['Longitude']), float(row['Latitude'])])
#   packedColor = PackColor([0, 0, 255])
#   epoch_0 = FormatDateStr(row['Date'], '%Y-%m')
#   epoch_1 = epoch_0 + 60*60*24*28
#   points += [x,y,packedColor,epoch_0,epoch_1]
# array.array('f', points).tofile(open('HAL_final_white.bin', 'wb'))

# #Other/Unknown Race Lynchings

# raw_data = []
# with open("HAL_final_other.csv") as f:
#   reader = csv.DictReader(f, delimiter=",")
#   for row in reader:
#     raw_data.append(row)

# len(raw_data)

# raw_data[0]


# #format x,y,packed_color,epoch_0,epoch_1
# points = []
# for row in raw_data:
#   x,y = LngLatToWebMercator([float(row['Longitude']), float(row['Latitude'])])
#   packedColor = PackColor([0, 255, 0])
#   epoch_0 = FormatDateStr(row['Date'], '%Y-%m')
#   epoch_1 = epoch_0 + 60*60*24*28
#   points += [x,y,packedColor,epoch_0,epoch_1]
# array.array('f', points).tofile(open('HAL_final_other.bin', 'wb'))

import array, calendar, csv, math, time

def LonLatToPixelXY(lonlat):
  (lon, lat) = lonlat
  x = (lon + 180.0) * 256.0 / 360.0
  y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
  return [x, y]

def FormatEpoch(datestr, formatstr):
  return calendar.timegm(time.strptime(datestr, formatstr))

def PackColor(color):    
  return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

def hex2rgb(h):
  return tuple(int(h.strip("#")[i:i+2], 16) for i in (0, 2 ,4))

raw_data = []
with open("HAL_final_black.csv", encoding="utf8") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)

len(raw_data)

raw_data[0]

# rev 1
# x,y,size_value,epoch
# show all points in same color. Initial date at full size. after n days begin to fade dot until a year as elapsed...
# don't distinguish between events with 0 or > 0 number of events
#This is for **ALL** events
points = []
for row in raw_data:
  x,y = LonLatToPixelXY([float(row['Longitude']), float(row['Latitude'])])
  points.append(x)
  points.append(y)
  #points.append(math.sqrt(float(row['Scale']) + 1.0))
  points.append(PackColor([255,0,0]))    
  points.append(FormatEpoch(row["Date"], '%Y-%m'))
array.array('f', points).tofile(open('HAL_final_black.bin', 'wb'))

#Male
raw_data = []
with open("HAL_final_male.csv", encoding="utf8") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)

len(raw_data)

raw_data[0]

# rev 1
# x,y,size_value,epoch
# show all points in same color. Initial date at full size. after n days begin to fade dot until a year as elapsed...
# don't distinguish between events with 0 or > 0 number of events
#This is for **ALL** events
points = []
for row in raw_data:
  x,y = LonLatToPixelXY([float(row['Longitude']), float(row['Latitude'])])
  points.append(x)
  points.append(y)
  #points.append(math.sqrt(float(row['Scale']) + 1.0))
  points.append(PackColor([255,153,51]))    
  points.append(FormatEpoch(row["Date"], '%Y-%m'))
array.array('f', points).tofile(open('HAL_final_male.bin', 'wb'))

#Female
raw_data = []
with open("HAL_final_female.csv", encoding="utf8") as f:
  reader = csv.DictReader(f, delimiter=",")
  for row in reader:
    raw_data.append(row)

len(raw_data)

raw_data[0]

# rev 1
# x,y,size_value,epoch
# show all points in same color. Initial date at full size. after n days begin to fade dot until a year as elapsed...
# don't distinguish between events with 0 or > 0 number of events
#This is for **ALL** events
points = []
for row in raw_data:
  x,y = LonLatToPixelXY([float(row['Longitude']), float(row['Latitude'])])
  points.append(x)
  points.append(y)
  #points.append(math.sqrt(float(row['Scale']) + 1.0))
  points.append(PackColor([0, 255, 0]))    
  points.append(FormatEpoch(row["Date"], '%Y-%m'))
array.array('f', points).tofile(open('HAL_final_female.bin', 'wb'))