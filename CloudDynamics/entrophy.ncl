; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150
units = "s^-2"

; === pre-process data === 
fx = addfile (header+"sc_L.z3dx.nc", "r")
xi = fx->xi
time = fx->Time
z = fx->zc
print ("read xi done")
fy = addfile (header+"sc_L.z3dy.nc", "r")
eta = fy->eta
print ("read eta done")
fz = addfile (header+"sc_L.z3dz.nc", "r")
zeta = fz->zeta
print ("read zeta done")
enstrophy = (xi^2 + eta^2 + zeta^2) / 2
printVarSummary (enstrophy)
print ("process enstrophy done")

;; === plot images ===
res = True
res@tiYAxisString = "Height (m)"
res@tiXAxisString = "time (hr)"
res@cnFillOn = True
;res@cnFillPalette = "MPL_gist_gray"
res@lbOrientation = "vertical"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.0004
res@cnMaxLevelValF = 0.006
res@cnLevelSpacingF = 0.0008
res@cnConstFEnableFill = True
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
;res@tmYBMode = "Explicit"
;res@tmYBValues = ispan (0, 10*(nz-1), 100)
;res@tmYBLabels = ispan (0, 1490, 100)
res@cnLinesOn = False

var = dim_avg_n (enstrophy, (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z
printVarSummary (var)
;range of var is 0.0004 to 0.006
var = where (var .ge. 0.0004, var, var@_FillValue)

wks = gsn_open_wks ("png", dest+"enstrophy_vertical_profile_perry92205")
res@gsnRightString = units
res@tiMainString = "enstrophy - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)

wks = gsn_open_wks ("png", dest+"enstrophy_zoomin_vertical_profile_perry92205")
res@gsnRightString = units
res@cnLevelSpacingF = 0.0002
res@tiMainString = "enstrophy - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|80:95, time|:), res)
delete (var)
print ("process enstrophy done")

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
var(0, :) = dim_avg_n (dim_avg_n (enstrophy(time1, :, :, :)*1000., (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (enstrophy(time2, :, :, :)*1000., (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (enstrophy(time3, :, :, :)*1000., (/2, 3/)), 0)

resEvolution1@tiXAxisString = "enstrophy [" + units + "] * 10^-3"
resEvolution1@tiMainString = "enstrophy - profile"
wks = gsn_open_wks ("png", dest + "enstrophy_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of enstrophy with three lines")
