load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150 
; Ql and Qt

; === pre-process data === 
fw = addfile (header+"sc_L.w3d.nc", "r");
w = fw->w
time = fw->Time
z = fw->zc
latw = fw->yc
lonw = fw->xc
print ("read w done");
printVarSummary (w)

; === plot images ===
res = True
res@tiYAxisString = "Height (m)"
res@tiXAxisString = "time (hr)"
res@cnFillOn = True
;res@cnFillPalette = "MPL_gist_gray"
res@lbOrientation = "vertical"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.025
res@cnMaxLevelValF = 0.4
;res@cnLevelSpacingF = 0.02
res@cnConstFEnableFill = True
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
;res@tmYBMode = "Explicit"
;res@tmYBValues = ispan (0, 10*(nz-1), 100)
;res@tmYBLabels = ispan (0, 1490, 100)
res@cnLinesOn = False

w2 = dim_avg_n (w^2, (/2, 3/))
w2!0 = "time"
w2!1 = "z"
w2&time = time
w2&z = z
printVarSummary (w2)
; range of w2 is 0.025 to 0.4
w2 = where (w2 .ge. 0.025, w2, w2@_FillValue)

wks = gsn_open_wks ("png", dest+"w2_vertical_profile_perry92205")
res@gsnRightString = "m^2/s^2"
res@tiMainString = "w^2 - Hovmoller diagram"
plot = gsn_csm_contour (wks, w2 (z|:, time|:), res)

w3 = dim_avg_n (w^3, (/2, 3/))
w3!0 = "time"
w3!1 = "z"
w3&time = time
w3&z = z
printVarSummary (w3)

;exclude -0.01~0.01
;w3 = where (abs(w3) .gt. 0.0025, w3, w3@_FillValue)
;delete (res@cnFillPalette)

cmp = read_colormap_file ("amwg256")
res@cnFillPalette = cmp (:165, :)
res@cnLevelSpacingF = 0.005
res@cnMinLevelValF = -0.14
res@cnMaxLevelValF = 0.04

;res@cnLevelSpacingF = 0.02
wks = gsn_open_wks ("png", dest+"w3_vertical_profile_perry92205")
res@gsnRightString = "m^3/s^3"
res@tiMainString = "w^3 - Hovmoller diagram"
plot = gsn_csm_contour (wks, w3 (z|:, time|:), res)

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

;res@xyMarkLineMode = "MarkLines"
;res@tmXBMode = "Explicit"
;res@tmXBValues = ispan (0, 2*(ntime-1), 60)
;res@tmXBLabels = ispan (0, 12, 1)
;res@trYMinF = 0.
;res@trYMaxF = 120.
res@trXMinF = 0.
res@trXMaxF = 0.2

var = new ((/3, nz/), float)
var(0, :) = dim_avg_n (w2(time1, :), 0)
var(1, :) = dim_avg_n (w2(time2, :), 0)
var(2, :) = dim_avg_n (w2(time3, :), 0)

resEvolution1@tiXAxisString = "w2 [m^2/s^2]"
resEvolution1@tiMainString = "w2 - profile"
wks = gsn_open_wks ("png", dest+"w2_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of w2 with three lines")

var = new ((/3, nz/), float)
var(0, :) = dim_avg_n (w3(time1, :), 0)
var(1, :) = dim_avg_n (w3(time2, :), 0)
var(2, :) = dim_avg_n (w3(time3, :), 0)

resEvolution1@tiXAxisString = "w3 [m^3/s^3]"
resEvolution1@tiMainString = "w3 - profile"
wks = gsn_open_wks ("png", dest+"w3_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of w3 with three lines")
