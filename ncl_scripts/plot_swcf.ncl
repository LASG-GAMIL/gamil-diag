load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

    case_name = "test_2deg"
    case_title = "GAMIL 2~S~o~N~ version"
    path_mod  = "~/figures"
    path_obs  = "~/amwg/obs_data"

    f_mod = addfile(path_mod+"/"+case_name+"_ANN_climo.nc", "r")
    f_obs = addfile(path_obs+"/CERES-EBAF_ANN_climo.nc", "r")

    swcf_mod = f_mod->SWCF
    swcf_obs = f_obs->SWCF
    lat_mod   = f_mod->lat
    lon_mod   = f_mod->lon
    lat_obs   = f_obs->lat
    lon_obs   = f_obs->lon
    swcf_obs_i = linint2_Wrap(lon_obs, lat_obs, swcf_obs, True, lon_mod, lat_mod, 0)

    wgt_lat = cos(lat_mod*atan(1.0)/45.0)

    diff = swcf_mod-swcf_obs_i
    copy_VarCoords(swcf_mod, diff)

    wks = gsn_open_wks("pdf", "swcf")

    gsn_define_colormap(wks, "amwg")

    res = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@pmTickMarkDisplayMode = "Always"
    res@cnLinesOn = False
    res@cnFillOn = True
    res@gsnSpreadColors = True
    res@mpLandFillColor = "white"
    res@lbLabelStride = 2
    res@gsnStringFontHeightF = 0.02
    res@gsnLeftStringFontHeightF = 0.02
    res@gsnRightStringFontHeightF = 0.02
    res@tmXBLabelFontHeightF  = 0.02
    res@tmLabelAutoStride = True
    res@tmYLLabelFontHeightF = 0.02
    res@lbLabelFontHeightF = 0.02
    res@lbOrientation = "vertical"
    res@mpCenterLonF = 180
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = (/-170,-150,-135,-120,-105,-90,-75,-60,-45,-30,-15,0,15,30,45/)

    plot = new(3, graphic)

    res@gsnLeftString = "(a) "+case_title
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(swcf_mod, wgt_lat, 1, 0))
    plot(0) = gsn_csm_contour_map_ce(wks, swcf_mod(0,:,:), res)

    res@gsnLeftString = "(b) CERES-EBAF"
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(swcf_obs_i, wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, swcf_obs_i(0,:,:), res)

    res@gsnLeftString = "(c) GAMIL-(CERES-EBAF)"
    res@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res@cnLevels = (/-120,-100,-80,-60,-40,-20,-10,0,10,20,40,60,80,100,120/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff(0,:,:), res)

    gsn_panel(wks, plot, (/3,1/), True)

end
