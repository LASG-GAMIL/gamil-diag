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
    f_obs = addfile(path_obs+"/XIEARKIN_ANN_climo.nc", "r")

    prect_mod = f_mod->PRECT
    prect_obs = f_obs->PRECT
    lat_mod   = f_mod->lat
    lon_mod   = f_mod->lon
    lat_obs   = f_obs->lat
    lon_obs   = f_obs->lon
    prect_obs_i = linint2_Wrap(lon_obs, lat_obs, prect_obs, True, lon_mod, lat_mod, 0)

    ; Convert units.
    prect_mod = (/prect_mod*86400000/)
    prect_mod@units = "mm/day"

    wgt_lat = cos(lat_mod*atan(1.0)/45.0)

    diff = prect_mod-prect_obs_i
    copy_VarCoords(prect_mod, diff)

    wks = gsn_open_wks("pdf", "prect")

    gsn_define_colormap(wks, "amwg")

    res  = True
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
    res@tmLabelAutoStride = True
    res@tmXBLabelFontHeightF = 0.02
    res@tmYLLabelFontHeightF = 0.02
    res@lbLabelFontHeightF = 0.02
    res@lbOrientation = "vertical"
    res@mpCenterLonF = 180
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels=(/0.2,0.5,1,2,3,4,5,6,7,8,9,10,12,14,17/)

    plot = new(3,graphic)

    res@gsnLeftString = "(a) "+case_title
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(prect_mod, wgt_lat, 1, 0))
    plot(0) = gsn_csm_contour_map_ce (wks, prect_mod(0,:,:),res)

    res@gsnLeftString = "(b) XIE-ARKIN"
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(prect_obs_i, wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, prect_obs_i(0,:,:),res)

    res@gsnLeftString = "(c) GAMIL-(XIE-ARKIN)"
    res@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res@cnLevels = (/-8,-6,-4,-3,-2,-1,-0.5,0,0.5,1,2,3,4,6,8/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff(0,:,:), res)

    gsn_panel(wks, plot, (/3,1/), True)
   
end
