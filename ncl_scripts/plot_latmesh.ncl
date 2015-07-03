load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

    f = addfile("run.rhminl/test_2deg.gamil.h0.1979-01.nc", "r")

    lat_full = f->lat

    lat_half = new(dimsizes(lat_full)-1, typeof(lat_full))
    dlat = new(dimsizes(lat_full)-1, typeof(lat_full))
    do j = 0, dimsizes(lat_full)-2
        lat_half(j) = (lat_full(j+1)+lat_full(j))*0.5
        dlat(j) = lat_full(j+1)-lat_full(j)
    end do


    wks = gsn_open_wks("pdf", "latmesh")

    res = True

    plot = gsn_csm_xy(wks, lat_half, dlat, res)

end
