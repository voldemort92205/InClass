; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150 
; Ql and Qt
units = "g / kg"

; === pre-process data === 
fqc = addfile (header+"sc_L.qc3d.nc", "r")
qc = fqc->qc
fqg = addfile (header+"sc_L.qg3d.nc", "r")
qg = fqg->qg
fqi = addfile (header+"sc_L.qi3d.nc", "r")
qi = fqi->qi
fqr = addfile (header+"sc_L.qr3d.nc", "r")
qr = fqr->qr
fqs = addfile (header+"sc_L.qs3d.nc", "r")
qs = fqs->qs
fqv = addfile (header+"sc_L.qv3d.nc", "r")
qv = fqv->qv

time = fqc->Time
z = fqc->zc

printVarSummary (qc)
printVarSummary (qg)
printVarSummary (qi)
printVarSummary (qr)
printVarSummary (qs)
printVarSummary (qv)

print ("read all q done")

qt = qc+qg+qi+qr+qs+qv
; ql should be qc+qr
ql = qc+qr

delete (qc)
delete (qg)
delete (qi)
delete (qr)
delete (qs)
delete (qv)

; === plot images ===
res = True
res@tiYAxisString = "Height (m)"
res@tiXAxisString = "time (hr)"
res@cnFillOn = True
cmp = read_colormap_file ("rainbow+white")
;res@cnFillPalette = cmp (::-1, :)
;res@cnFillPalette = "rainbow+white"
res@cnFillPalette = "wh-bl-gr-ye-re"
res@lbOrientation = "vertical"
res@cnLevelSelectionMode = "ManualLevels"
res@cnMinLevelValF = 4.
res@cnMaxLevelValF = 9.25
res@cnLevelSpacingF = 0.125
res@cnConstFEnableFill = True
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
res@cnLinesOn = False

var = dim_avg_n (qt*1000., (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z
var = where (var .gt. 4., var, var@_FillValue)

wks = gsn_open_wks ("png", dest+"qt_perry92205")
res@gsnRightString = units
res@tiMainString = "qt - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process qt done")

var = dim_avg_n (ql*1000., (/2, 3/))
var!0 = "time"
var!1 = "z"
var&time = time
var&z = z
var = where (var .gt. 0.05, var, var@_FillValue)

delete (res@cnFillPalette)
delete (cmp)
cmp = read_colormap_file ("MPL_winter")
res@cnFillPalette = cmp (::-1, :)
res@cnMinLevelValF = 0.05
res@cnMaxLevelValF = 0.75
res@cnLevelSpacingF = 0.03

wks = gsn_open_wks ("png", dest+"ql_perry92205")
res@gsnRightString = units
res@tiMainString = "ql - Hovmoller diagram"
plot = gsn_csm_contour (wks, var (z|:, time|:), res)
delete (var)
print ("process ql done")

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
var(0, :) = dim_avg_n (dim_avg_n (ql(time1, :, :, :)*1000., (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (ql(time2, :, :, :)*1000., (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (ql(time3, :, :, :)*1000., (/2, 3/)), 0)

resEvolution1@tiXAxisString = "Ql [g/kg]"
resEvolution1@tiMainString = "Ql - profile"
wks = gsn_open_wks ("png", "ql_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of Ql with three lines")

var = new ((/3, nz/), float)
var(0, :) = dim_avg_n (dim_avg_n (qt(time1, :, :, :)*1000., (/2, 3/)), 0)
var(1, :) = dim_avg_n (dim_avg_n (qt(time2, :, :, :)*1000., (/2, 3/)), 0)
var(2, :) = dim_avg_n (dim_avg_n (qt(time3, :, :, :)*1000., (/2, 3/)), 0)

resEvolution1@tiXAxisString = "Qt [g/kg]"
resEvolution1@tiMainString = "Qt - profile"
wks = gsn_open_wks ("png", "qt_time_evolution_perry92205")
plot = gsn_csm_xy (wks, var, z, resEvolution1)
delete (var)
print ("process time evolution of Qt with three lines")

; === conditional sampling ===
; updraft : w > 0.5, downdraft : w < -0.5
; ============================
fw = addfile (header+"sc_L.w3d.nc", "r");
w = fw->w

resEvolution2 = True
resEvolution2@tiYAxisString = "Height (m)"

resEvolution2@xyDashPattern = 0
resEvolution2@xyLineColors = (/"Black", "blue", "red"/)
resEvolution2@xyLineThicknesses = (/6., 6.0, 6./)

resEvolution2@gsnDraw = False
resEvolution2@gsnFrame = False

pres = True
pres@gsnPanelRowSpec = True

; qt
updraft = where (w .gt. 0.5, qt, qt@_FillValue)
downdraft = where (w.lt. -0.5, qt, qt@_FillValue)

delete (plot)
plot = new (3, graphic)
wks = gsn_open_wks ("png", dest+"qt_conditional_sampling_perry92205")

resEvolution2@tiXAxisString = "Qt [g/kg]"
resEvolution2@trXMinF = 2.
resEvolution2@trXMaxF = 10.
i = 0
do while (i .lt. 3)
	sampling = new ((/3, nz/), double)
	if (i .eq. 0)
		timing = time1
		resEvolution2@tiMainString = "Qt - conditional sampling at 3-6 hr"
	else if (i .eq. 1)
		timing = time2
		resEvolution2@tiMainString = "Qt - conditional sampling at 6-9 hr"
	else
		timing = time3
		resEvolution2@tiMainString = "Qt - conditional sampling at 9-12 hr"
		; add legend beside to figure 3
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

	sampling (0, :) = dim_avg_n (dim_avg_n (qt (timing, :, :, :)*1000., (/2, 3/)), 0)
	sampling (1, :) = dim_avg_n (dim_avg_n (updraft (timing, :, :, :)*1000., (/2, 3/)), 0)
	sampling (2, :) = dim_avg_n (dim_avg_n (downdraft (timing, :, :, :)*1000., (/2, 3/)), 0)

	plot (i) = gsn_csm_xy (wks, sampling, z, resEvolution2)
	delete (sampling)
	i = i + 1
end do
gsn_panel (wks, plot, (/2, 1/), pres)
print ("process conditional sampling Qt done")

; ql
delete (plot)
plot = new (3, graphic)
wks = gsn_open_wks ("png", dest+"ql_conditional_sampling_perry92205")

delete (updraft)
delete (downdraft)
updraft = where (w .gt. 0.5, ql, ql@_FillValue)
downdraft = where (w.lt. -0.5, ql, ql@_FillValue)

resEvolution2@tiXAxisString = "Ql [g/kg]"
resEvolution2@pmLegendDisplayMode = "NoCreate"
resEvolution2@trXMinF = 0.
resEvolution2@trXMaxF = 0.7
i = 0
do while (i .lt. 3)
	sampling = new ((/3, nz/), double)
	if (i .eq. 0)
		timing = time1
		resEvolution2@tiMainString = "Ql - conditional sampling at 3-6 hr"
	else if (i .eq. 1)
		timing = time2
		resEvolution2@tiMainString = "Ql - conditional sampling at 6-9 hr"
	else
		timing = time3
		resEvolution2@tiMainString = "Ql - conditional sampling at 9-12 hr"
		; add legend beside to figure 3
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

	sampling (0, :) = dim_avg_n (dim_avg_n (ql (timing, :, :, :)*1000., (/2, 3/)), 0)
	sampling (1, :) = dim_avg_n (dim_avg_n (updraft (timing, :, :, :)*1000., (/2, 3/)), 0)
	sampling (2, :) = dim_avg_n (dim_avg_n (downdraft (timing, :, :, :)*1000., (/2, 3/)), 0)

	plot (i) = gsn_csm_xy (wks, sampling, z, resEvolution2)
	i = i + 1
	delete (sampling)
end do
gsn_panel (wks, plot, (/2, 1/), pres)
print ("process conditional sampling Ql done")
