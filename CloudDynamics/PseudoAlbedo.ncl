load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
; === parameters ===
header = "/home/cldenv2016/perry92205/VVM/DATA/sc_david/"
dest = "./controlCase/"

; === basic settings ===
ntime = 361
nx = 128
ny = 128
nz = 150 
zindex = ispan (0, nz-2, 1)
Nc = 50	;[m^-3]

; === pre-process data === 

fname = "RHO.txt"
rho = asciiread ("RHO.txt", (/150/), "float")
printVarSummary (rho)
print ("read RHO done")

fqc = addfile (header+"sc_L.qc3d.nc", "r")
qc = fqc->qc
lat = fqc->yc
lon = fqc->xc
z = fqc->zc
time = fqc->Time
print ("read qc done")

dz = tofloat (z(zindex+1) - z(zindex))
var = qc * conform_dims ((/ntime, nz, ny, nx/), rho, 1)
printVarSummary (var)

varbar = (var (:, zindex, :, :) + var (:, zindex+1, :, :)) / 2
Integral = 1000 * dim_sum_n (varbar * conform_dims ((/ntime, nz-1, ny, nx/), dz, 1), 1)
printVarSummary (Integral)
delete (var)

;Pseudo Albedo : var
tmp = 0.19 * (Integral^(5./6.)) * (Nc^(1.0/3.))
var = tmp / (6.8 + tmp)
var!1 = "lat"
var!2 = "lon"
var&lat = lat
var&lon = lon
printVarSummary (var)
delete (tmp)

delete (qc)
delete (z)
; ==== plot image ====

PseudoA = new ((/3, ntime/), float)
PseudoA!1 = "time"
PseudoA&time = time

PseudoA (0, :) = dim_avg_n (var, (/1, 2/))
PseudoADev = dim_stddev_n (var, (/1, 2/))
PseudoA (1, :) = PseudoA (0, :) + PseudoADev
PseudoA (2, :) = PseudoA (0, :) - PseudoADev

wks = gsn_open_wks ("png", "PA")
res = True

res@xyDashPattern = 0
;res@xyMarkLineMode = "MarkLines"
res@xyLineColors = (/"Black", "blue", "blue"/)
res@xyLineThicknesses = (/4.5, 2.0, 2.0/)

res@tiMainString = "Pseudo Albedo"
res@gsnRightString = "g/m^2 - not sure"
res@tiYAxisString = "Pseudo Albedo"
res@tiXAxisString = "time (hr)"
res@tmXBMode = "Explicit"
res@tmXBValues = ispan (0, 2*(ntime-1), 60)
res@tmXBLabels = ispan (0, 12, 1)
res@trYMinF = min (PseudoA)
res@trYMaxF = max (PseudoA)
res@trXMinF = time (0)
res@trXMaxF = time (ntime-1)

plot = gsn_csm_xy (wks, PseudoA&time, PseudoA, res)
print ("plot Pseudo Albedo done")

; visualize
resVisual = True
resVisual@tiYAxisString = "y (m)"
resVisual@tiXAxisString = "x (m)"
resVisual@cnFillOn = True
resVisual@cnFillPalette = "MPL_gist_gray"
resVisual@lbOrientation = "vertical"
resVisual@cnLevelSelectionMode = "ManualLevels"
resVisual@cnMinLevelValF = 0.
resVisual@cnMaxLevelValF = 1.
resVisual@cnLevelSpacingF = 0.02
resVisual@cnConstFEnableFill = True
resVisual@gsnRightString = ""
resVisual@cnLinesOn = False

dest = "birdviewAlbedo/"
i = 0
do while (i .lt. ntime)
	wks = gsn_open_wks ("png", dest+"PA_timestep_"+sprinti("%0.3i", i))
	resVisual@tiMainString = "Pseudo Albedo in time step = "+sprinti ("%0.3i", i)
	plot = gsn_csm_contour (wks, var(i, :, :), resVisual)
	print ("process time step " + i)
	i = i+1
end do
