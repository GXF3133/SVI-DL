function [x_in_range,y_in_range] = windowdata(points, start_x, end_x, C)
%windowdata
%   [x_in_range,y_in_range] = windowdata(points, start_x, end_x, C) apply a
%   time window to the data.
%          'points'       - The control points of the time window.
%          'start_x'      - The starting serial number of the geophone.
%          'end_x'        - The ending serial number of the geophone.
%          'C'            - The number of traces.
[sorted_x, sort_idx] = sort(points(:, 1));
sorted_y = points(sort_idx, 2);
sorted_points = [sorted_x, sorted_y];
min_x = min(sorted_x) - C;
max_x = max(sorted_x) + C;
all_x = [];
all_y = [];
num_points = size(sorted_points, 1);
p1_first = sorted_points(1, :);
p2_first = sorted_points(2, :);
x1_first = p1_first(1);
y1_first = p1_first(2);
x2_first = p2_first(1);
y2_first = p2_first(2);
if x2_first ~= x1_first
    slope_first = (y2_first - y1_first) / (x2_first - x1_first);
    intercept_first = y1_first - slope_first * x1_first;
else
    slope_first = Inf;
    intercept_first = x1_first;
end
left_extended_x = min_x:(x1_first - 1);
if slope_first ~= Inf
    left_extended_y = slope_first * left_extended_x + intercept_first;
else
    left_extended_y = repmat(y1_first, size(left_extended_x));
end
all_x = [all_x, left_extended_x];
all_y = [all_y, left_extended_y];
for i = 1:num_points - 1
    p1 = sorted_points(i, :);
    p2 = sorted_points(i + 1, :);
    x1 = p1(1);
    y1 = p1(2);
    x2 = p2(1);
    y2 = p2(2);
    if x2 ~= x1
        slope = (y2 - y1) / (x2 - x1);
        intercept = y1 - slope * x1;
    else
        slope = Inf;
        intercept = x1;
    end
    segment_start_x = max(x1, min_x);
    segment_end_x = min(x2, max_x);
    if segment_start_x <= segment_end_x
        segment_x = segment_start_x:segment_end_x;
        if slope ~= Inf
            segment_y = slope * segment_x + intercept;
        else
            segment_y = repmat(y1, size(segment_x));
        end
        all_x = [all_x, segment_x];
        all_y = [all_y, segment_y];
    end
end
p1_last = sorted_points(end - 1, :);
p2_last = sorted_points(end, :);
x1_last = p1_last(1);
y1_last = p1_last(2);
x2_last = p2_last(1);
y2_last = p2_last(2);
if x2_last ~= x1_last
    slope_last = (y2_last - y1_last) / (x2_last - x1_last);
    intercept_last = y1_last - slope_last * x1_last;
else
    slope_last = Inf;
    intercept_last = x1_last;
end
right_extended_x = (x2_last + 1):max_x;
if slope_last ~= Inf
    right_extended_y = slope_last * right_extended_x + intercept_last;
else
    right_extended_y = repmat(y2_last, size(right_extended_x));
end
all_x = [all_x, right_extended_x];
all_y = [all_y, right_extended_y];
[all_x, unique_indices] = unique(all_x);
all_y = all_y(unique_indices);
valid_indices = (all_x >= start_x) & (all_x <= end_x);
x_in_range = floor(all_x(valid_indices));
y_in_range = floor(all_y(valid_indices));
end

