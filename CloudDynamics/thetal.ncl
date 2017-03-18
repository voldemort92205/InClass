; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150 
units = "K"
Lv = 2.5e6
Cp = 1005.
Rd = 287.05
g = 9.8

; === pre-process data === 
P = asciiread ("P.txt", (/150/), "float")
printVarSummary (P)
P0 = P(0)
print ("read P done")

fqc = addfile (header+"sc_L.qc3d.nc", "r")
qc = fqc->qc
z = fqc->zc
time = fqc->Time
fth = addfile (header+"sc_L.th3d.nc", "r")
th = fth->th
fqr = addfile (header+"sc_L.qr3d.nc", "r")
qr = fqr->qr

printVarSummary (qc)
printVarSummary (qr)
printVarSummary (th)
print ("read ql and theta done")

; theta -> T => T = theta * (p/p0) ^ (Rd/Cp)
T = th * conform_dims((/ntime, nz, ny, nx/), P/P0, 1)^(Rd/Cp)
printVarSummary (T)

; theta_L = T + (gz-Lv*ql) / Cp
thetaL = T + (g * conform_dims ((/ntime, nz, ny, nx/), z, 1) - Lv *(qc+qr)) / Cp
printVarSummary (thetaL)

; === plot images ===
res = True
res@tiYAxisString = "Height (m)"
res@tiXAxisString = "time (hr)"
res@cnFillOn = True
;res@cnFillPalette = "MPL_gist_gray"
res@lbOrientation = "vertical"
;res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 0.0004
res@cnMaxLevelValF = 0.006
res@cnLevelSpacingF = 0.5
res@cnConstFEnableFill = True
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
res@cnLinesOn = False

var = dim_avg_n (th, (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z

wks = gsn_open_wks ("png", dest+"theta_perry92205")
res@gsnRightString = units
res@tiMainString = "Theta - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process theta done")

var = dim_avg_n (T, (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z

wks = gsn_open_wks ("png", dest+"T_perry92205")
res@gsnRightString = units
res@tiMainString = "T - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process T done")

var = dim_avg_n (thetaL, (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z

wks = gsn_open_wks ("png", dest+"thetaL_perry92205")
res@gsnRightString = units
res@tiMainString = "ThetaL - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process thetaL done")

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

var = new ((/3, nz/), double)
var(0, :) = dim_avg_n (dim_avg_n (thetaL(time1, :, :, :), (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (thetaL(time2, :, :, :), (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (thetaL(time3, :, :, :), (/2, 3/)), 0)

resEvolution1@pmLegendParallelPosF = .2
resEvolution1@tiXAxisString = "theta L [K]"
resEvolution1@tiMainString = "theta L - profile"
wks = gsn_open_wks ("png", dest+"thetal_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of thetaL with three lines")

; === conditional sampling ===
resEvolution2 = True
resEvolution2@tiYAxisString = "Height (m)"
resEvolution2@tiXAxisString = "theta L (K)"

resEvolution2@xyDashPattern = 0
resEvolution2@xyLineColors = (/"Black", "blue", "red"/)
resEvolution2@xyLineThicknesses = (/6., 6.0, 6./)

resEvolution2@trXMinF = 288.
resEvolution2@trXMaxF = 306.

resEvolution2@gsnDraw = False
resEvolution2@gsnFrame = False

pres = True
pres@gsnPanelRowSpec = True

fw = addfile (header+"sc_L.w3d.nc", "r");
w = fw->w
updraft = where (w .gt. 0.5, thetaL, thetaL@_FillValue)
downdraft = where (w.lt. -0.5, thetaL, thetaL@_FillValue)

delete (plot)
plot = new (3, graphic)
wks = gsn_open_wks ("png", dest+"thetal_conditional_sampling_perry92205")

i = 0
do while (i .lt. 3)
	sampling = new ((/3, nz/), double)
	if (i .eq. 0)
		timing = time1
		resEvolution2@tiMainString = "theta L - conditional sampling at 3-6 hr"
	else if (i .eq. 1)
		timing = time2
		resEvolution2@tiMainString = "theta L - conditional sampling at 6-9 hr"
	else
		timing = time3
		resEvolution2@tiMainString = "theta L - conditional sampling at 9-12 hr"
		resEvolution2@pmLegendDisplayMode = "Always"
		resEvolution2@pmLegendSide = "Top"
		resEvolution2@pmLegendParallelPosF = 1.4
		resEvolution2@pmLegendOrthogonalPosF = -0.5
		resEvolution2@pmLegendWidthF = 0.08
		resEvolution2@pmLegendHeightF = 0.15
		resEvolution2@xyExplicitLegendLabels = (/"average", "updraft", "downdraft"/)
		resEvolution2@lgPerimOn = False
		resEvolution2@lgLabelFontHeightF = .03
		resEvolution2@lgItemOrder = (/2, 1, 0/)
	end if
	end if

	sampling (0, :) = dim_avg_n (dim_avg_n (thetaL (timing, :, :, :), (/2, 3/)), 0)
	sampling (1, :) = dim_avg_n (dim_avg_n (updraft (timing, :, :, :), (/2, 3/)), 0)
	sampling (2, :) = dim_avg_n (dim_avg_n (downdraft (timing, :, :, :), (/2, 3/)), 0)

	plot (i) = gsn_csm_xy (wks, sampling, z, resEvolution2)
	delete (sampling)
	i = i + 1
end do
gsn_panel (wks, plot, (/2, 1/), pres)
print ("process conditional sampling theta L done")
