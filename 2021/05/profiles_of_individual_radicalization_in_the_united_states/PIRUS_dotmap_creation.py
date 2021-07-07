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

def multiple_variables(csv_name, longitude_name, latitude_name, event_name, rgb_color_scheme, date_name, date_format, bin_name):
  raw_data = []
  with open(csv_name, encoding="utf8") as f:
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
    x,y = LonLatToPixelXY([float(row[longitude_name]), float(row[latitude_name])])
    points.append(x)
    points.append(y)
    points.append(math.sqrt(float(row[event_name]) + 1.0))
    points.append(PackColor(rgb_color_scheme))    
    points.append(FormatEpoch(row[date_name], date_format))
  array.array('f', points).tofile(open(bin_name, 'wb'))

#Far-Right=#1ECBE1
#Far-Left=#E11ECB
#Radical Islamist=#CBE11E

#Low-Income=#7224DB
#Middle-Income=#DB7224
#High-Income=#24DB72

multiple_variables("Radicalization_Far_Right.csv", "long", "lat", "Dummy_Number",[30, 203, 225], "Date_Exposure", "%Y-%m-%d", "Radicalization_Far_Right.bin")
multiple_variables("Radicalization_Far_Left.csv", "long", "lat", "Dummy_Number",[225, 30, 203], "Date_Exposure", "%Y-%m-%d", "Radicalization_Far_Left.bin")
multiple_variables("Radicalization_Islamist.csv", "long", "lat", "Dummy_Number",[203, 225, 30], "Date_Exposure", "%Y-%m-%d", "Radicalization_Islamist.bin")

multiple_variables("Low_Social_Stratum.csv", "long", "lat", "Dummy_Number",[114, 36, 219], "Date_Exposure", "%Y-%m-%d", "Low_Social_Stratum.bin")
multiple_variables("Middle_Social_Stratum.csv", "long", "lat", "Dummy_Number",[219, 114, 36], "Date_Exposure", "%Y-%m-%d", "Middle_Social_Stratum.bin")
multiple_variables("High_Social_Stratum.csv", "long", "lat", "Dummy_Number",[36, 219, 114], "Date_Exposure", "%Y-%m-%d", "High_Social_Stratum.bin")

multiple_variables("Internet_Radicals.csv", "long", "lat", "Dummy_Number",[253,254,255], "Date_Exposure", "%Y-%m-%d", "Internet_Radicals.bin")
multiple_variables("Facebook_Radicals.csv", "long", "lat", "Dummy_Number",[253,254,255], "Date_Exposure", "%Y-%m-%d", "Facebook_Radicals.bin")
