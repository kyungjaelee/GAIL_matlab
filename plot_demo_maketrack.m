function plot_demo_maketrack(track, mycar, info, tick, sec, emsec_total, mode)

persistent fist_flag h h_cartraj h_cartrajbd h_carfill h_carsfill h_carsbd h_carsarrow h_carbd h_cararrow h_title;
if isempty(fist_flag)
    fist_flag = 1;
end

if isequal(computer, 'MACI64')
    title_fs = 18; % Font Size
else
    title_fs = 14; % Font Size
end
mycar.postemp = mycar.pos;
car_traj = zeros(5, 3);
car_trajbd = cell(5, 1);
for i = 1:5
    mycar.postemp = update_pos(mycar.postemp, mycar.vel, 0.2);
    car_traj(i, :) = mycar.postemp;
    % car_trajbd{i} = get_circle(mycar.postemp(1), mycar.postemp(2), 2000, 20);
    car_trajbd{i} = get_carshape(mycar.postemp, mycar.W, mycar.H);
end

% My car boundary
% mycar_bd = get_circle(mycar.pos(1), mycar.pos(2), 2000, 20);
mycar_bd = get_carshape(mycar.pos, mycar.W, mycar.H);

set(gcf,'Color', [0.6, 0.9, 0.8]/4 )

% Title
info_str = sprintf('[%s] [%d] %.2fsec (%.2fms) %.1fkm/h %.1fdeg/s \n %d-Seg %d-Lane/ dev: %.2fm (%.2fm) / GeoD: %.2fm / deg: %.1fdeg \n ForwardBackward Left: (%.1fm, %.1fm) Center: (%.1fm, %.1fm) Right: (%.1fm, %.1fm)' ...
    , mode.str, tick, sec, emsec_total, mycar.vel(1)/1000/1000*60*60, mycar.vel(2) ...
    , info.seg_idx, info.lane_idx, info.dev/1000, info.lane_dev/1000, info.dist/1000, info.deg ...
    , info.left_fb_dists(1)/1000, info.left_fb_dists(2)/1000, info.center_fb_dists(1)/1000, info.center_fb_dists(2)/1000, info.right_fb_dists(1)/1000, info.right_fb_dists(2)/1000 ...
    );

% Plot
real_carwh  = [mycar.W*1.8, mycar.H*1.5];

pred_hor = 5;
if fist_flag
    hold on;
    
    % Plot track
    axisinfo = plot_track(track);
    
    % Future pos of the robot
    for i = 1:pred_hor
        [h1, h2, h3] = plot_arrow(car_traj(i, 1:2), 2000, car_traj(i, 3) , 'k', 1);
        h_cartraj{i} = [h1 h2 h3];
        h_cartrajbd{i} = plot(car_trajbd{i}(:, 1), car_trajbd{i}(:, 2), 'k', 'LineWidth', 1);
    end
    
    % My Car pos
    if 1
        rszwh  = [50 100];
        [carimg, ~, cartr] = imread('carimgs/greencar.png');
        h.carrsz = imresize(carimg, rszwh);
        h.trrsz  = imresize(cartr, rszwh);
        carpos = mycar.pos;
        [xmesh_grid, ymesh_grid] = get_carmeshgrid(carpos, real_carwh, rszwh);
        h.carsurf = surf('xdata', xmesh_grid, 'ydata', ymesh_grid ...
            , 'zdata', zeros(rszwh(1), rszwh(2)) ...
            , 'cdata', h.carrsz, 'AlphaData', h.trrsz ...
            , 'FaceAlpha', 'texture' ...
            , 'FaceColor', 'texturemap' ...
            , 'EdgeColor','None', 'LineStyle', 'None');
    else
        h_carfill = fill(mycar_bd(:, 1), mycar_bd(:, 2), 'g');
        h_carbd = plot(mycar_bd(:, 1), mycar_bd(:, 2), 'k', 'LineWidth', 3);
        [h1, h2, h3] = plot_arrow(mycar.pos, 2000, mycar.pos(3), 'k', 3);
        h_cararrow = [h1 h2 h3];
    end
    
    % X, Y Axis
    xmin = axisinfo(1);
    ymin = axisinfo(3);
    plot([xmin xmin], [ymin ymin + 10000], 'w-', 'LineWidth', 3);
    plot([xmin xmin + 10000], [ymin ymin], 'w-', 'LineWidth', 3);
    text(xmin+12000, ymin-2000, 'X 10m', 'FontSize', 15, 'Color', 'w', 'HorizontalAlignment', 'Center')
    text(xmin, ymin+12000, 'Y 10m', 'FontSize', 15, 'Color', 'w', 'HorizontalAlignment', 'Center')
    
    % ETC
    switch mode.flag
        case 0
            h_title = title(sprintf('%s', info_str), 'FontSize', title_fs, 'Color', 'k');
        case 1
            h_title = title(sprintf('%s', info_str), 'FontSize', title_fs, 'Color', 'k');
    end
    axis equal; axis(axisinfo); % grid on;
    axis off;
    xlabel('X [mm]', 'FontSize', 15); ylabel('Y [mm]', 'FontSize', 15);
    fist_flag = 0;
else
    % Future pos
    for i = 1:pred_hor
        [x1, y1, x2, y2, x3, y3] = get_arrow(car_traj(i, 1:2), 2000, car_traj(i, 3) , 'k', 1);
        h_cartraj{i}(1).XData = x1; h_cartraj{i}(1).YData = y1;
        h_cartraj{i}(2).XData = x2; h_cartraj{i}(2).YData = y2;
        h_cartraj{i}(3).XData = x3; h_cartraj{i}(3).YData = y3;
        h_cartrajbd{i}.XData = car_trajbd{i}(:, 1);
        h_cartrajbd{i}.YData = car_trajbd{i}(:, 2);
    end
    
    % Car pos
    if 1
        rszwh  = [50 100];
        carpos = mycar.pos;
        [xmesh_grid, ymesh_grid] = get_carmeshgrid(carpos, real_carwh, rszwh);
        h.carsurf.XData = xmesh_grid;
        h.carsurf.YData = ymesh_grid;
    else
        h_carfill.Vertices = mycar_bd;
        h_carbd.XData = mycar_bd(:, 1); h_carbd.YData = mycar_bd(:, 2);
        [x1, y1, x2, y2, x3, y3] = get_arrow(mycar.pos, 2000, mycar.pos(3), 'k', 3);
        h_cararrow(1).XData = x1; h_cararrow(1).YData = y1;
        h_cararrow(2).XData = x2; h_cararrow(2).YData = y2;
        h_cararrow(3).XData = x3; h_cararrow(3).YData = y3;
    end
    
    % ETC
    h_title.String = info_str;
    switch mode.flag
        case 0
            h_title.Color = 'y';
        case 1
            h_title.Color = 'w';
    end
end



