import array, csv, math, os, time
from datetime import timedelta, date, datetime

def FormatDateStr(date_str, format_str):
    return time.mktime(time.strptime(date_str, format_str))

def LngLatToWebMercator(lnglat):
    (lng, lat) = lnglat
    x = (lng + 180.0) * 256.0 / 360.0
    y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
    return [x, y]


def PackColor(color):
    return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

def multiple_variables(csv_name, longitude_name, latitude_name, rgb_color_scheme, date_name, date_format, bin_name):
  raw_data = []
  with open(csv_name) as f:
    reader = csv.DictReader(f, delimiter=",")
    for row in reader:
      raw_data.append(row)

  len(raw_data)

  raw_data[0]


  #format x,y,packed_color,epoch_0,epoch_1
  points = []
  for row in raw_data:
    x,y = LngLatToWebMercator([float(row[longitude_name]), float(row[latitude_name])])
    packedColor = PackColor(rgb_color_scheme)
    epoch_0 = FormatDateStr(row[date_name], date_format)
    epoch_1 = epoch_0 + 60*60*24*28
    points += [x,y,packedColor,epoch_0,epoch_1]
  array.array('f', points).tofile(open(bin_name, 'wb'))

#Far-Right=#1ECBE1
#Far-Left=#E11ECB
#Radical Islamist=#CBE11E

#Low-Income=#7224DB
#Middle-Income=#DB7224
#High-Income=#24DB72

multiple_variables("far_right.csv", "long", "lat", [30,203,225], "Date_Exposure", "%Y-%m-%d", "far_right.bin")