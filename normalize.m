function [normalized_data] = normalize(source_data, kind)
% 数据的标准化（归一化）处理
% 参数filename 可用格式的源数据
% 参数kind 代表何种归一化 1是[0~1]标准化 2是[-1~1]标准化
% 返回归一化后的数据

if nargin < 2
    kind = 1; % 默认进行[0-1]标准化 叫做Min-Max标准化
end;

[m,n]  = size(source_data);
normalized_data = zeros(m, n);

%% normalize the data x to [0,1]
if kind == 1
    for i = 1:n
        ma = max( source_data(:, i) ); % Matlab中变量名不宜和函数名相同，所以不用max、min、mean等变量名
        mi = min( source_data(:, i) );
        normalized_data(:, i) = ( source_data(:, i)-mi ) / ( ma-mi );
    end
end
%% normalize the data x to [-1,1]
if kind == 2
    for i = 1:n
        mea = mean( source_data(:, i) );
        st = std( source_data(:, i) );
        normalized_data(:, i) = ( source_data(:, i)-mea ) / st;
    end
end