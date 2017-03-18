; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150 
; Ql and Qt
units = "K / day"

; === pre-process data === 
frad = addfile (header+"sc_L.rad.nc", "r")
sw = frad->dtradsw
lw = frad->dtradlw
lon = frad->xc
lat = frad->yc
z = frad->zc
time = frad->Time

printVarSummary (sw)
printVarSummary (lw)
print ("read sw and lw heating rate done")

; === plot images ===
res = True
res@tiYAxisString = "Height (m)"
res@tiXAxisString = "time (hr)"
res@cnFillOn = True
cmp = read_colormap_file ("GMT_hot")
res@cnFillPalette = cmp (::-1, :)
res@lbOrientation = "vertical"
;res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.0004
res@cnMaxLevelValF = 0.006
res@cnLevelSpacingF = 0.2
res@cnConstFEnableFill = True
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
;res@tmYBMode = "Explicit"
;res@tmYBValues = ispan (0, 10*(nz-1), 100)
;res@tmYBLabels = ispan (0, 1490, 100)
res@cnLinesOn = False

var = dim_avg_n (sw * 86400., (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z
var = where (var .gt. 0.4, var, var@_FillValue)

wks = gsn_open_wks ("png", dest+"shortwave_rate_perry92205")
res@gsnRightString = units
res@tiMainString = "shortwave heating rate - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process Hovmoller diagram shortwave hetaing rate done")

var = dim_avg_n (lw * 86400., (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z
;var = where (var .gt. 0., var, var@_FillValue)

delete (res@cnFillPalette)
delete (cmp)
cmp = read_colormap_file ("rainbow")
res@cnFillPalette = cmp (:165, :)
res@cnLevelSpacingF = 2.5
wks = gsn_open_wks ("png", dest+"longwave_rate_perry92205")
res@gsnRightString = units
res@tiMainString = "longwave heating rate - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)

wks = gsn_open_wks ("png", dest+"longwave_rate_zoomin_perry92205")
res@gsnRightString = units
res@tiMainString = "longwave heating rate - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|75:95, time|:), res)
delete (var)
print ("process Hovmoller diagram longwave hetaing rate done")

; === time evolution ===
; 3hr-6hr
time1 = ispan (90, 180, 1)
; 6hr-9hr
time2 = ispan (180, 270, 1)
; 9hr-12hr
time3 = ispan (270, 360, 1)

; resEvolution1 for three lines settings
resEvolution1 = True
resEvolution1@tiYAxisString = "Height (m)"

resEvolution1@xyDashPattern = 0
resEvolution1@xyLineColors = (/"Black", "blue", "red"/)
resEvolution1@xyLineThicknesses = (/6., 6.0, 6./)

; add legend
resEvolution1@pmLegendDisplayMode = "Always"
resEvolution1@pmLegendSide = "Top"
resEvolution1@pmLegendParallelPosF = .8
resEvolution1@pmLegendOrthogonalPosF = -0.4
resEvolution1@pmLegendWidthF = 0.08
resEvolution1@pmLegendHeightF = 0.15
resEvolution1@xyExplicitLegendLabels = (/"3-6 hr", "6-9 hr", "9-12 hr"/)
resEvolution1@lgPerimOn = False
resEvolution1@lgLabelFontHeightF = .03
resEvolution1@lgItemOrder = (/2, 1, 0/)

var = new ((/3, nz/), float)
var(0, :) = dim_avg_n (dim_avg_n (sw(time1, :, :, :)*86400., (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (sw(time2, :, :, :)*86400., (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (sw(time3, :, :, :)*86400., (/2, 3/)), 0)

resEvolution1@tiXAxisString = "shortwave heating rate [" + units + "]"
resEvolution1@tiMainString = "shortwave heating rate - profile"
wks = gsn_open_wks ("png", dest + "shortwave_heating_rate_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of shortwave heating rate with three lines")

var = new ((/3, nz/), float)
var(0, :) = dim_avg_n (dim_avg_n (lw(time1, :, :, :)*86400., (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (lw(time2, :, :, :)*86400., (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (lw(time3, :, :, :)*86400., (/2, 3/)), 0)

resEvolution1@pmLegendParallelPosF = .2
resEvolution1@tiXAxisString = "longwave heating rate [" + units + "]"
resEvolution1@tiMainString = "longwave heating rate - profile"
wks = gsn_open_wks ("png", dest + "longwave_heating_rate_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of longwave heating rate with three lines")
