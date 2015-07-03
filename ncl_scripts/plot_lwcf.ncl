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

    lwcf_mod = f_mod->LWCF
    lwcf_obs = f_obs->LWCF
    lat_mod   = f_mod->lat
    lon_mod   = f_mod->lon
    lat_obs   = f_obs->lat
    lon_obs   = f_obs->lon
    lwcf_obs_i = linint2_Wrap(lon_obs, lat_obs, lwcf_obs, True, lon_mod, lat_mod, 0)

    wgt_lat = cos(lat_mod*atan(1.0)/45.0)

    diff = lwcf_mod-lwcf_obs_i
    copy_VarCoords(lwcf_mod, diff)

    wks = gsn_open_wks("pdf", "lwcf")

    gsn_define_colormap(wks, "amwg")

    res  = True
    res@gsnDraw = False
    res@gsnFrame = False
    res@pmTickMarkDisplayMode = "Always"
    res@cnLinesOn   = False
    res@cnFillOn = True
    res@gsnSpreadColors = True
    res@mpLandFillColor = "white"
    res@lbLabelStride = 2
    res@gsnStringFontHeightF = 0.02
    res@gsnLeftStringFontHeightF = 0.02
    res@gsnRightStringFontHeightF = 0.02
    res@tmXBLabelFontHeightF  = 0.02
    res@tmLabelAutoStride = True
    res@tmYLLabelFontHeightF  = 0.02
    res@lbLabelFontHeightF = 0.02
    res@lbOrientation = "vertical"
    res@mpCenterLonF = 180
    res@cnLevelSelectionMode = "ExplicitLevels"
    res@cnLevels = (/-45,-30,-20,-10,-0,10,20,30,40,50,60,70,85,100,115/)

    plot = new(3, graphic)
    res@gsnLeftString = "(a) "+case_title
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(lwcf_mod, wgt_lat, 1, 0))
    plot(0) = gsn_csm_contour_map_ce(wks, lwcf_mod(0,:,:), res)

    res@gsnLeftString = "(b) CERES-EBAF"
    res@gsnRightString = "MEAN = "+sprintf("%4.2f", wgt_areaave(lwcf_obs_i, wgt_lat, 1, 0))
    plot(1) = gsn_csm_contour_map_ce(wks, lwcf_obs(0,:,:), res)

    res@gsnLeftString = "(c) GAMIL1-(CERES-EBAF)"
    res@gsnRightString = "RMSE = "+sprintf("%4.2f", sqrt(wgt_areaave(diff^2, wgt_lat, 1, 0)))
    res@cnLevels = (/-80,-60,-40,-30,-20,-10,-5,0,5,10,20,30,40,60,80/)
    plot(2) = gsn_csm_contour_map_ce(wks, diff(0,:,:), res)

    gsn_panel(wks, plot, (/3,1/), True)

end
