
% no leap year

addpath('/home/xiyi/scripts/matlab/functions_calculate/')

ISIMIP_old_dir = '/workdir/xiyi/DATA/ISIMIP_for_ORCHIDEE/';
ISIMIP_new_dir = '/workdir/xiyi/DATA/ISIMIP_for_ORCHIDEE_reso1/';

% ISIMIP_old_dir = 'D:\forcing\ISIMIP/';
% ISIMIP_new_dir = 'D:\forcing\ISIMIP_reso1/';

scens = {'obsclim'; 'historical'; 'ssp126'; 'ssp370'; 'ssp585'};
yrs = [1901 2016; 1850 2014; 2015 2100; 2015 2100; 2015 2100];
yrs_ORCHIDEE = [1961 2016; 1901 2014; 2015 2100; 2015 2100; 2015 2100];

gcms = {{'GSWP3-W5E5'}; {'GFDL-ESM4'; 'UKESM1-0-LL'; 'MPI-ESM1-2-HR'; 'IPSL-CM6A-LR'; 'MRI-ESM2-0'}; ...
    {'GFDL-ESM4'; 'UKESM1-0-LL'; 'MPI-ESM1-2-HR'; 'IPSL-CM6A-LR'; 'MRI-ESM2-0'}; ...
    {'GFDL-ESM4'; 'UKESM1-0-LL'; 'MPI-ESM1-2-HR'; 'IPSL-CM6A-LR'; 'MRI-ESM2-0'}; ...
    {'GFDL-ESM4'; 'UKESM1-0-LL'; 'MPI-ESM1-2-HR'; 'IPSL-CM6A-LR'; 'MRI-ESM2-0'};};

vars_ORCHIDEE = {'Tmax'; 'Tmin'; 'precip'; 'Qair'; 'PSurf'; 'SWdown'; 'LWdown'; 'Wind'};
vars_units = {'K'; 'K'; 'kg m-2 s-1'; 'kg kg-1'; 'Pa'; 'W m-2'; 'W m-2'; 'm s-1'};
vars_longname = {'Maximum Daily Air Temperature'; 'Minimum Daily Air Temperature'; ...
    'Precipitation'; 'Specific Humidity'; 'Surface Pressure'; 'Downward Shortwave Radiation'; ...
    'Downward Longwave Radiation'; 'Wind Speed'};

reso_old = 0.5;
[nb_lat_old, nb_lon_old] = deal(180/reso_old, 360/reso_old);

reso = 1;
[nb_lat, nb_lon] = deal(180/reso, 360/reso);

RR = makerefmat(-180+reso/2, 90-reso/2, reso, -reso);
[nav_lon, nav_lat] = pixcenters(RR, nb_lat, nb_lon, 'makegrid');
nav_lon = nav_lon';
nav_lat = nav_lat';

% maskr = imread('G:\DATA\Tiff\World\continent_reso1.tif');
maskr = imread('/home/xiyi/DATA/Tiff/World/continent_reso1.tif');
maskr = double(maskr);
maskr(maskr==255) = nan;
maskr(~isnan(maskr)) = 1;
% figure; imagesc(maskr)

Areas = area_weighted_any([-90 90], [-180 180], reso)*1e6; % m2
Areas(isnan(maskr)) = 1.000000020040877e+20;
Areas = Areas';
% figure; imagesc(Areas)

contfrac = maskr;
contfrac(isnan(contfrac)) = 1.000000020040877e+20;
contfrac = contfrac';
% figure; imagesc(contfrac)

maskr = maskr';

% keep consistency with CRUJRA
load('/workdir/xiyi/DATA/ISIMIP_for_ORCHIDEE/CRUJRA_1deg_mask.mat', 'mask');
maskr = maskr.*mask;

for isc = 2:length(scens)
    gcms_isc = gcms{isc, 1};
    for igcm = 5%:length(gcms_isc)
        ISIMIP_old_subdir = [ISIMIP_old_dir, scens{isc}, '/', gcms_isc{igcm}, '/'];
        ISIMIP_new_subdir = [ISIMIP_new_dir, scens{isc}, '/', gcms_isc{igcm}, '/'];
        if ~exist(ISIMIP_new_subdir, 'dir')
            mkdir(ISIMIP_new_subdir)
        end 
        for iyr = yrs_ORCHIDEE(isc, 1):yrs_ORCHIDEE(isc, 2)
            disp(iyr)
            tic
            filename_new = [ISIMIP_new_subdir, gcms_isc{igcm}, '_onedeg_daily_', num2str(iyr), '.nc'];
            
            % days_iyr = datenum(iyr, 12, 31)-datenum(iyr, 1, 1)+1;
            days_iyr = datenum(1981, 12, 31)-datenum(1981, 1, 1)+1;
            tdaysecond = [0:86400:(days_iyr-1)*86400]';
            
            nb_days = length(tdaysecond);
            
            if exist(filename_new, 'file')
                delete(filename_new)
            end
            
            % 1: lat
            nccreate(filename_new, 'nav_lat', 'Dimensions', {'longitude', nb_lon, 'latitude', nb_lat}, ...
                'Format', 'netcdf4', 'Datatype', 'single');
            ncwriteatt(filename_new, 'nav_lat', 'long_name', 'Latitude');
            ncwriteatt(filename_new, 'nav_lat', 'units', 'degrees north');
            ncwrite(filename_new, 'nav_lat', nav_lat)
            
            % 2: lon
            nccreate(filename_new, 'nav_lon', 'Dimensions', {'longitude', nb_lon, 'latitude', nb_lat}, ...
                'Format', 'netcdf4', 'Datatype', 'single');
            ncwriteatt(filename_new, 'nav_lon', 'long_name', 'Longitude');
            ncwriteatt(filename_new, 'nav_lon', 'units', 'degrees east');
            ncwrite(filename_new, 'nav_lon', nav_lon);
            
            % 3: time
            nccreate(filename_new, 'time', 'Dimensions', {'time', nb_days, ...
                netcdf.getConstant('NC_UNLIMITED')}, 'Format', 'netcdf4', ...
                'Datatype', 'single', 'FillValue', 1.000000020040877e+20);
            ncwriteatt(filename_new, 'time', 'title', 'Time');
            ncwriteatt(filename_new, 'time', 'long_name', 'Time axis');
            ncwriteatt(filename_new, 'time', 'calendar', 'standard');
            ncwriteatt(filename_new, 'time', 'units', ['seconds since ', num2str(iyr), '-01-01 00:00:00']);
            ncwriteatt(filename_new, 'time', 'time_origin', [num2str(iyr), '-01-01 00:00:00']);
            ncwrite(filename_new, 'time', tdaysecond);
            
            
            % 4: contfrac
            nccreate(filename_new, 'contfrac', 'Dimensions', {'longitude', nb_lon, 'latitude', nb_lat}, ...
                'Format', 'netcdf4', 'Datatype', 'single', 'FillValue', 1.000000020040877e+20);
            ncwriteatt(filename_new, 'contfrac', 'long_name', 'Continental fraction');
            ncwriteatt(filename_new, 'contfrac', 'units', 1);
            ncwriteatt(filename_new, 'contfrac', 'coordinates', 'lon lat');
            ncwrite(filename_new, 'contfrac', contfrac);
            
            % 5: Areas
            nccreate(filename_new, 'Areas', 'Dimensions', {'longitude', nb_lon, 'latitude', nb_lat}, ...
                'Format', 'netcdf4', 'Datatype', 'single', 'FillValue', 1.000000020040877e+20);
            ncwriteatt(filename_new, 'Areas', 'long_name', 'Mesh areas');
            ncwriteatt(filename_new, 'Areas', 'units', 'm2');
            ncwriteatt(filename_new, 'Areas', 'coordinates', 'lon lat');
            ncwrite(filename_new, 'Areas', Areas);
            
            filename_old = dir([ISIMIP_old_subdir, '*_', num2str(iyr), '*.nc']);
            
            for ivar = 1:length(vars_ORCHIDEE)
                
                disp(vars_ORCHIDEE{ivar})
                
                % 6: other climate vars
                var_temp = ncread([filename_old.folder, '/', filename_old.name], ...
                    vars_ORCHIDEE{ivar});
                % figure; imagesc(var_temp(:, :, 1))
                if size(var_temp, 3)==366
                    var_temp(:, :, 366) = [];
                end
                var_temp = imresize_meanORsum3D(var_temp, reso/reso_old, 1);
                var_temp = var_temp.*maskr;
                var_temp(isnan(var_temp)) = 1.000000020040877e+20;
                
                nccreate(filename_new, vars_ORCHIDEE{ivar}, 'Dimensions', ...
                    {'longitude', nb_lon, 'latitude', nb_lat, 'time', nb_days}, ...
                    'Format', 'netcdf4', 'Datatype', 'single', 'FillValue', 1.000000020040877e+20);
                ncwriteatt(filename_new, vars_ORCHIDEE{ivar}, 'long_name', vars_longname{ivar});
                ncwriteatt(filename_new, vars_ORCHIDEE{ivar}, 'units', vars_units{ivar});
                % ncwriteatt(filename_new, vars_ORCHIDEE{ivar}, 'cell_methods', cell_methods{ivar});
                ncwrite(filename_new, vars_ORCHIDEE{ivar}, var_temp);
                % clear var_temp
                
            end
            toc
            
            % 7: Global Attributes
            ncwriteatt(filename_new, '/', 'contact', 'yixi@pku.edu.cn');
            ncwriteatt(filename_new, '/', 'create date', '2021-11-07');
            
            % ncdisp(filename_new)
            
        end
    end
end


