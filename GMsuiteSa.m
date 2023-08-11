% 批量计算和绘制地震动集的反应谱及均值谱
% Created on Tus Feb 10 15:51:00 2022
% @author: Vincent NT, ylpxdy@live.com
clc;clear;
tic

%% 读取待处理文件夹的地震波文件名列表
path = 'D:\Wen\Research\MAS\PEER\la01-40\Normalized';  % ### 文件夹
list = getFolderList(path);  % 获得文件夹中所有地震波的文件名列表


gmSuiteName = 'BE \it i \rm ground motion';  % ### 图例
T1 = 0.61;  % ### 结构首阶自振周期

%%% ### 地震动文件存储格式说明：下面为PEER格式
% 表头行数
headerLines = 4;
% 地震动采样信息存储格式说明
informLine = 4;  % 所在行数
informFmt = 'NPTS= %f, DT= %f, Scalar= %f';  % NPTS=点数，DT=采样间隔，Scalar=调幅系数
% 地震动数据点存储格式说明
dataCol = 5;  % 数据列数
formatString = '%f %f %f %f %f';  % 数据占位说明
units = "g";  % units intput from getAmpDtPEER()

%% 计算各反应谱及均值反应vb谱
SaPsdList = zeros(size(list,1),1000);  % 初始化地震集反应谱列表
SaAbsList = zeros(size(list,1),1000);

% 反应谱输出参数设置
kesi = 0.05;  % ### 阻尼比
abs_psd = 0; % ### Output abs (1), psd (0) or both (other values)  % 通常画 "伪反应谱"
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


for i = 1:1:size(list,1)  % 循环地震动集所有地震波
    
    % 读取地震动波形
    recordName = list{i};
%     [wave, dt, ~, ~] = getAmpDtPEER(path, recordName);
    
    % 地震动采样信息读取 = [NPTS, DT]'
    samplingInfo = readTargetText(fullfile(path,recordName), ...
            headerLines, informLine, informFmt);
    npts = samplingInfo(1);   % 采样点数
    dt = samplingInfo(2);  % 采样间隔时间 sec

    wave = getAmpGeneral(path, recordName, ...
        formatString, headerLines, dataCol, npts);
    
    % Scaling
    wave = scalingFactor*rmmissing(wave)*unitsTrans;
    
%     % Scaling
%     wave = scalingFactor*wave;

    % 计算反应谱
    [T, peak_abs, peak_psd] = responseSpectrum(...
        wave,dt,kesi,abs_psd,dT,0,'A',0);
    
    % GM suites statistics
    SaAbsList(i,:) = peak_abs';  % 加入大列表
    SaPsdList(i,:) = peak_psd';
    
    % IM calculation
    if i == 1  % for initialization
        imTable = intensityCalculate(recordName, wave, dt, units, kesi, T1, PGAratio);
    else
        imTableI = intensityCalculate(recordName, wave, dt, units, kesi, T1, PGAratio);
        imTable = [imTable; imTableI];
    end

end

%% 计算均值谱
SaPsdMean = mean(SaPsdList,1);  % 伪谱加速度
SaAbsMean = mean(SaAbsList,1);  % 谱加速度

%% 绘制反应谱
% 绘图
figure
plot(T, SaAbsList, 'LineWidth', 1, 'Color', 0.7.*[1 1 1])  % 各地震动反应谱
hold on
plot(T, SaAbsMean, '-', 'LineWidth', 2, 'Color', 0.*[1 1 1])  % 均值反应谱
% 图设置
% x轴显示范围
showPeriodStrat = 0.01;  % 显示区域的起始周期（s）
showPeriodEnd = 10;  % 显示区域的终止周期（s）
set(gca,'XLim',[showPeriodStrat showPeriodEnd])
% y轴显示范围
showSaStrat = 0;  % 显示区域的起始Sa（s）
showSaEnd = 4;  % 显示区域的终止Sa（s）
set(gca,'YLim',[showSaStrat showSaEnd])
set(gca,'xscale','linear')
set(gca,'yscale','linear')
% 轴名
xlabel('\itT\rm / s');  % x轴名
ylabel('\itSa\rm( \itT \rm{, 5%) / g}');  % y轴名
% 图例
legend([repmat({''},1,size(list,1)-1),{gmSuiteName},{'Mean Spectrum'}],...
    'Location','northeast')
% 字体大小
set(gca,'fontsize',18);
set(gca,'Fontname','Times New Roman');
grid on

disp('Finish!')
toc