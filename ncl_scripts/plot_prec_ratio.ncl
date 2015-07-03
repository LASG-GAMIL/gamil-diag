load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

    case_name = "test_2deg"
    path  = "~/figures"

    f = addfile(path+"/"+case_name+"_ANN_climo.nc", "r")

    precc = f->PRECC
    precl = f->PRECL
    prect = f->PRECT

    preann = prect*86400*365.

    ratioc = new(dimsizes(precc), "float")
    ratiol = new(dimsizes(precc), "float")
    ratio  = new(dimsizes(precc), "float")

    do j = 0, dimsizes(f->lat)-1
        do i = 0, dimsizes(f->lon)-1
            if (preann(0,j,i) .gt. 0.6) then
                ratioc(0,j,i) = precc(0,j,i)/prect(0,j,i)*100.
                ratiol(0,j,i) = precl(0,j,i)/prect(0,j,i)*100.
                ratio (0,j,i) = ratioc(0,j,i)+ratiol(0,j,i)*100.
            else
                ratioc(0,j,i) = 0.
                ratiol(0,j,i) = 0.
                ratio (0,j,i) = 0.
            end if
        end do
    end do
    copy_VarCoords(prect, ratioc)
    copy_VarCoords(prect, ratiol)
    copy_VarCoords(prect, ratio)

    wks = gsn_open_wks("pdf", "prec_ratio")

    gsn_define_colormap(wks, "gsltod")

    res = True
    res@pmTickMarkDisplayMode = "Always"
    res@cnLinesOn = True
    res@vpWidthF = 0.7
    res@vpHeightF = 0.4
    res@cnFillOn = True
    res@gsnSpreadColors = True
    res@lbOrientation  = "vertical"
    res@mpCenterLonF  = 180
    res@mpMinLonF = 100.
    res@mpMaxLonF = 280.
    res@mpMinLatF = -20.
    res@mpMaxLatF = 20.
    res@tmXBLabelFontHeightF = 0.018                ; resize tick labels
    res@tmYLLabelFontHeightF = 0.018
    res@gsnStringFontHeightF = 0.018
    res@lbLabelAutoStride =   True
    res@cnLineLabelsOn = True
    res@cnLineLabelFontHeightF = 0.018
    res@cnLineLabelFontThicknessF = 2
    res@cnLevelSelectionMode = "ExplicitLevels"

    plot = new(2, graphic)

    res@gsnLeftString = "(a) Convective ratio"
    res@cnLevels= fspan(60,80,11)
    plot(0) = gsn_csm_contour_map_ce(wks, ratioc(0,:,:), res)

    res@gsnLeftString = "(b) Stratiform ratio"
    res@cnLevels= fspan(20,40,11)
    plot(1) = gsn_csm_contour_map_ce(wks, ratiol(0,:,:), res)

    gsn_panel(wks, plot, (/2,1/), True)

end
