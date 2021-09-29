setwd(file.path(Sys.getenv('my_dir'),'2021/10/usa_military_bases_and_deployments'))

library(troopdata)

#Data Citation
#Allen, Michael A., Michael E. Flynn, and Carla Martinez Machain. 2021. "Global U.S. military deployment data: 1950-2020." Conflict Management and Peace Science. TBD.
#Kane, Tim. 2005. "Global U.S. troop deployment, 1950-2003." Technical Report. Heritage Foundation, Washington, D.C.
#Vine, David. 2015. "Base nation: How U.S. military bases abroad harm America and the World." Metropolitan Books, Washington, D.C.
#Michael A. Allen, Michael E. Flynn, and Carla Martinez Machain. 2020. "Outside the wire: US military deployments and public opinion in host states." American Political Science Review. 114(2): 326-341.

troopdata <- get_troopdata(host = NA, branch = TRUE, 1950,2020)
basedata <- get_basedata()
builddata <- get_builddata()