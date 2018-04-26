function [normalized_data] = normalize(source_data, kind)
% ���ݵı�׼������һ��������
% ����filename ���ø�ʽ��Դ����
% ����kind ������ֹ�һ�� 1��[0~1]��׼�� 2��[-1~1]��׼��
% ���ع�һ���������

if nargin < 2
    kind = 1; % Ĭ�Ͻ���[0-1]��׼�� ����Min-Max��׼��
end;

[m,n]  = size(source_data);
normalized_data = zeros(m, n);

%% normalize the data x to [0,1]
if kind == 1
    for i = 1:n
        ma = max( source_data(:, i) ); % Matlab�б��������˺ͺ�������ͬ�����Բ���max��min��mean�ȱ�����
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