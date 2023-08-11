% ��������ͻ��Ƶ��𶯼��ķ�Ӧ�׼���ֵ��
% Created on Tus Feb 10 15:51:00 2022
% @author: Vincent NT, ylpxdy@live.com
clc;clear;
tic

%% ��ȡ�������ļ��еĵ����ļ����б�
path = 'D:\Wen\Research\MAS\PEER\la01-40\Normalized';  % ### �ļ���
list = getFolderList(path);  % ����ļ��������е��𲨵��ļ����б�


gmSuiteName = 'BE \it i \rm ground motion';  % ### ͼ��
T1 = 0.61;  % ### �ṹ�׽���������

%%% ### �����ļ��洢��ʽ˵��������ΪPEER��ʽ
% ��ͷ����
headerLines = 4;
% ���𶯲�����Ϣ�洢��ʽ˵��
informLine = 4;  % ��������
informFmt = 'NPTS= %f, DT= %f, Scalar= %f';  % NPTS=������DT=���������Scalar=����ϵ��
% �������ݵ�洢��ʽ˵��
dataCol = 5;  % ��������
formatString = '%f %f %f %f %f';  % ����ռλ˵��
units = "g";  % units intput from getAmpDtPEER()

%% �������Ӧ�׼���ֵ��Ӧvb��
SaPsdList = zeros(size(list,1),1000);  % ��ʼ�����𼯷�Ӧ���б�
SaAbsList = zeros(size(list,1),1000);

% ��Ӧ�������������
kesi = 0.05;  % ### �����
abs_psd = 0; % ### Output abs (1), psd (0) or both (other values)  % ͨ���� "α��Ӧ��"
dT = 0.01; % ### ? Natural period Interval
% fig = 0; % Default: plot the figure
% variable = 'A'; % Default: acceleration response spectrum
% normalize = 0; % Default: normalization ON

% IM setting
% units = 'g';  % units intput from getAmpDtPEER()
PGAratio = 0.05;  % Bracketed duration limit

% scaling factor list
scalingFactor = 1;

% Units
if units == "CM/SEC/SEC"
    unitsTrans = 0.01/9.8; % to (g)
elseif units == "g"
    unitsTrans = 1;
end


for i = 1:1:size(list,1)  % ѭ�����𶯼����е���
    
    % ��ȡ���𶯲���
    recordName = list{i};
%     [wave, dt, ~, ~] = getAmpDtPEER(path, recordName);
    
    % ���𶯲�����Ϣ��ȡ = [NPTS, DT]'
    samplingInfo = readTargetText(fullfile(path,recordName), ...
            headerLines, informLine, informFmt);
    npts = samplingInfo(1);   % ��������
    dt = samplingInfo(2);  % �������ʱ�� sec

    wave = getAmpGeneral(path, recordName, ...
        formatString, headerLines, dataCol, npts);
    
    % Scaling
    wave = scalingFactor*rmmissing(wave)*unitsTrans;
    
%     % Scaling
%     wave = scalingFactor*wave;

    % ���㷴Ӧ��
    [T, peak_abs, peak_psd] = responseSpectrum(...
        wave,dt,kesi,abs_psd,dT,0,'A',0);
    
    % GM suites statistics
    SaAbsList(i,:) = peak_abs';  % ������б�
    SaPsdList(i,:) = peak_psd';
    
    % IM calculation
    if i == 1  % for initialization
        imTable = intensityCalculate(recordName, wave, dt, units, kesi, T1, PGAratio);
    else
        imTableI = intensityCalculate(recordName, wave, dt, units, kesi, T1, PGAratio);
        imTable = [imTable; imTableI];
    end

end

%% �����ֵ��
SaPsdMean = mean(SaPsdList,1);  % α�׼��ٶ�
SaAbsMean = mean(SaAbsList,1);  % �׼��ٶ�

%% ���Ʒ�Ӧ��
% ��ͼ
figure
plot(T, SaAbsList, 'LineWidth', 1, 'Color', 0.7.*[1 1 1])  % �����𶯷�Ӧ��
hold on
plot(T, SaAbsMean, '-', 'LineWidth', 2, 'Color', 0.*[1 1 1])  % ��ֵ��Ӧ��
% ͼ����
% x����ʾ��Χ
showPeriodStrat = 0.01;  % ��ʾ�������ʼ���ڣ�s��
showPeriodEnd = 10;  % ��ʾ�������ֹ���ڣ�s��
set(gca,'XLim',[showPeriodStrat showPeriodEnd])
% y����ʾ��Χ
showSaStrat = 0;  % ��ʾ�������ʼSa��s��
showSaEnd = 4;  % ��ʾ�������ֹSa��s��
set(gca,'YLim',[showSaStrat showSaEnd])
set(gca,'xscale','linear')
set(gca,'yscale','linear')
% ����
xlabel('\itT\rm / s');  % x����
ylabel('\itSa\rm( \itT \rm{, 5%) / g}');  % y����
% ͼ��
legend([repmat({''},1,size(list,1)-1),{gmSuiteName},{'Mean Spectrum'}],...
    'Location','northeast')
% �����С
set(gca,'fontsize',18);
set(gca,'Fontname','Times New Roman');
grid on

disp('Finish!')
toc