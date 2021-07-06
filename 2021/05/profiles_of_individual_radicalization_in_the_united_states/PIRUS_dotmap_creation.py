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