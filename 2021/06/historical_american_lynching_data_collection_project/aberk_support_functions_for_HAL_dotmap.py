import array, csv, math, os, time
#import array, csv, math, os, time, datetime
#from datetime import timedelta, date, datetime
#import datetime as dt
#from datetime import timedelta, datetime
#datetime = datetime.datetime(1601,1,1)
#utctime.isoformat()
#OverflowError: mktime argument out of range ???
#https://bytes.com/topic/python/answers/632812-overflowerror-mktime-argument-out-range
#datetime.date(1882, 1, 1)
# import datetime
# currentdate = "01/01/1882"
# day,month,year = currentdate.split('/')
# today = datetime.date(int(year),int(month),int(day))
#https://stackoverflow.com/questions/5619489/troubleshooting-descriptor-date-requires-a-datetime-datetime-object-but-rec

#The old Python hates the past / how to use strftime on the dates before 1900
#https://ozymaxx.github.io/blog/2018/05/29/python-strftime/

#Python time module won't handle year before 1900
#https://stackoverflow.com/questions/6571562/python-time-module-wont-handle-year-before-1900
#from datetime import datetime

# mDt = datetime(1900,1,1)
# dt = datetime.strptime('20-02-1899', "%d-%m-%Y")
# resultString = datetime(dt.year + (mDt - dt).days/365 + 1, dt.month, dt.day).strftime('%B %d, %Y').replace('1900', str(dt.year))

# months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
# dt = datetime.strptime('20-02-1880', "%d-%m-%Y")
# print( "{0:} {1:}, {2:}".format(months[dt.month-1], dt.day, dt.year))

# a = dt.datetime(1322, 10, 10)
# # %Y%m%d
# ''.join(map(lambda x: '{:02}'.format(getattr(a, x)), ('year', 'month', 'day')))
# # %Y-%m-%d
# '-'.join(map(lambda x: '{:02}'.format(getattr(a, x)), ('year', 'month', 'day')))
# # %Y%m%d%H%M%S
# ''.join(map(lambda x: '{:02}'.format(getattr(a, x)), ('year', 'month', 'day', 'hour', 'minute', 'second')))

# from datetime import datetime
# epoch = datetime(1970, 1, 1)
# t = datetime(1856, 3, 2)
# diff = t-epoch
# print (diff.days * 24 * 3600 + diff.seconds)

# def FormatDateStr(date_str, format_str):
#     return time.mktime(time.strptime(date_str, format_str))

# def LngLatToWebMercator(lnglat):
#     (lng, lat) = lnglat
#     x = (lng + 180.0) * 256.0 / 360.0
#     y = 128.0 - math.log(math.tan((lat + 90.0) * math.pi / 360.0)) * 128.0 / math.pi
#     return [x, y]


# def PackColor(color):
#     return color[0] + color[1] * 256.0 + color[2] * 256.0 * 256.0;

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
#   packedColor = PackColor([0.6, 0.4, 0.8])
#   epoch_0 = FormatDateStr(row['Year'], '%Y')
#   epoch_1 = epoch_0 + 60*60*24*28
#   points += [x,y,packedColor,epoch_0,epoch_1]
# array.array('f', points).tofile(open('HAL_final_black.bin', 'wb'))
# #If Python is throwing a "ValueError: could not convert string to float:" error, make sure that *all* NaNs are removed from "date", "latitude", and/or "longitude" columns
# #Error in py_run_file_impl(file, local, convert) : OverflowError: mktime argument out of range

# #Windows 10: OverflowError: mktime argument out of range
# #https://github.com/neo4j/neo4j-python-driver/issues/302

from datetime import datetime

timestamp = -1
date_time = datetime.fromtimestamp(timestamp)

print("Date time object:", date_time)

d = date_time.strftime("%m/%d/%Y, %H:%M:%S")
print("Output 2:", d) 

d = date_time.strftime("%d %b, %Y")
print("Output 3:", d)

d = date_time.strftime("%d %B, %Y")
print("Output 4:", d)

d = date_time.strftime("%I%p")
print("Output 5:", d)