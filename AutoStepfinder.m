%AutoStepfinder: A fast and automated step detection method for
%single-molecule analysis.
%Luuk Loeff*, Jacob Kerssemakers*, Chirlmin Joo & Cees Dekker.
% * Equal contribution
%---------------------------------
  
function varargout = AutoStepfinder(varargin)
% AUTOSTEPFINDER MATLAB code for AutoStepfinder.fig
% To edit the GUI see GUIDE in the command window.
% Last Modified by GUIDE v2.5 16-May-2018 14:18:11
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AutoStepfinder_OpeningFcn, ...
                   'gui_OutputFcn',  @AutoStepfinder_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes during object creation, after setting all properties.
function data_path_CreateFcn(hObject, ~, ~)
data_directory = pwd; %insert your default directory here
set(hObject,'String', num2str(data_directory));
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');

end

function AutoStepFinder(handles) 
     %% Parameters set in GUI
    initval.datapath        = get(handles.data_path, 'string');         %Data path    
    initval.codefolder      = pwd;    
    initval.GlobalErrorAccept=0.1;                                      %User value for accepting a split or merge round solution
    
    initval.SMaxTreshold    = str2double(get(handles.SMaxTreshold,...   %Threshold for second round of fitting
                              'string')); 
    initval.overshoot       = str2double(get(handles.pitch,...          %Increase of decrease the number to-be-fitted steps relative to the determined optimum.
                              'string'));       
    initval.fitrange        = str2double(get(handles.fitrange,...       %Number of steps to be fitted
                              'string'));       
    initval.stepnumber      = initval.fitrange;                         %Iteration range of the measurement
    initval.nextfile        = 1;                                
    initval.resolution      = str2double(get(handles.res_mes,...        %Resolution of measurement
                              'string'));      
    initval.meanbase        = str2double(get(handles.meanbase,...       %Mean value of the base line
                              'string'));       
    initval.userplt         = get(handles.userplton,'Value');           %Turn user plot function on/ off
    initval.scurve_eval     = get(handles.scurveeval,'Value');          %Turn S-curve evaluation on/ off
    initval.fitmean         = get(handles.fitmean,'Value');             %Use mean for fitting
    initval.fitmedian       = get(handles.fitmedian,'Value');           %Use median for fitting
    initval.treshonoff      = get(handles.basetreshon,'Value');         %Turn base line treshholding on/ off
    initval.txtoutput       = get(handles.txtoutput,'Value');           %Output .txt files
    initval.matoutput       = get(handles.matoutput,'Value');           %Output .mat files
    initval.setsteps        = str2double(get(handles.manualmodesteps,...%Resolution of measurement
                              'string'));
    initval.parametersout   = get(handles.parametersout,'Value');       %Save parameters output file.
    initval.fitsoutput      = get(handles.fitsoutput,'Value');          %Save fits output file.
    initval.propoutput      = get(handles.propoutput,'Value');          %Save properties output file.
    initval.scurvesoutput   = get(handles.scurvesoutput,'Value');       %Save S-curves output file.
    initval.manualoff       = get(handles.manualoff,'Value');           %Manual mode off
    initval.manualon        = get(handles.manualon,'Value');            %Manual mode on
    if initval.treshonoff   == 1
      initval.basetresh     = initval.meanbase;                         %Treshhold the mean of your base line
    else
      initval.basetresh     = -100000;
    end       
    initval.singlerun       = get(handles.singrun,'Value');             %Single or batch run
    if initval.singlerun    == 1
      initval.hand_load     =  1;                                       %Single Run
    else    
      initval.hand_load     =  2;                                       %Batch Run
      initval.datapath      = uigetdir(initval.datapath);               %Get directory for batch analysis
    end 
           
%% Hidden parameters (not on the GUI) for advanced use  
    initval.localstepmerge=1;                                           %if larger than 0, weird steps are removed from fit
    initval.CropInputDataFactor=1;                                      %(does it work?)
    initval.showintermediateplots=1;                                    %(does it work?)
    initval.steperrorestimate='measured';                               % 'predicted';    %'measured'
    initval.steprepulsion = 1;                                          %This term prevents very small steps (2 sample points) to be fitted

 %% Main loop 
    autostepfinder_mainloop(initval,handles);

%% Executes just before AutoStepfinder is made visible.
function AutoStepfinder_OpeningFcn(hObject, ~, handles, varargin)
cla(handles.plot_fit);
axis(handles.plot_fit);
plot(0,0);
set(handles.figure1, 'units', 'normalized', 'position', [0.01 1 0.7 0.5]);
movegui('northwest');
xlabel('Time (s)','FontSize',12);                                       %Do not rotate xlabel
ylabel('Position (A.U.)','FontSize',12, 'rot', 90);                     %Rotate ylabel
set(gca,'TickDir','out','TickLength',[0.003 0.0035],'box', 'off');      %Ticks outslide plotting area
set(handles.PostPros, 'Visible','Off'); 
set(handles.AdvancedSettings,'Visible','Off');
set(handles.fileextbox,'Visible','Off');
set(handles.customoutputbox,'Visible','Off');
set(handles.AdvancedFitting,'Visible','Off');
set(handles.Scurve_eval,'Visible','Off');
set(handles.advancedoff,'Value',1);
set(handles.Scurve_eval,'Visible','Off');
set(handles.customoutoff,'Value',1);
set(handles.fitmean,'Value',1);
set(handles.txtoutput,'Value',1);
set(handles.manualmodesteps,'enable','Off');
set(handles.manualon,'value',0);
set(handles.manualoff,'value',1);
set(handles.scruveevaloff,'Value',1);
set(handles.singrun,'Value',1);
set(handles.userpltoff,'Value',1);
set(handles.parametersout,'Value',1);
set(handles.fitsoutput,'Value',1);
set(handles.propoutput,'Value',1);
set(handles.scurvesoutput,'Value',1);
set(handles.parametersout,'enable','Off');
set(handles.fitsoutput,'enable','Off');
set(handles.propoutput,'enable','Off');
set(handles.scurvesoutput,'enable','Off');
set(handles.manualmodesteps,'string',1);
set(handles.SMaxTreshold,'string',0.15);
set(handles.basetreshon,'Value', 0);
set(handles.basetreshoff,'Value', 1);
% Choose default command line output for AutoStepfinder
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes AutoStepfinder wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = AutoStepfinder_OutputFcn(~, ~, handles) 
varargout{1} = handles.output;

function manualmodesteps_Callback(hObject, ~, ~)
manualmode=get(hObject,'String');
checkmm=isnan(str2double(manualmode));
if checkmm==1
         msgbox('The input for manual mode is NaN.','ERROR', 'error')
     return;
end
mmnumber=str2num(manualmode);
if mmnumber < 1
         msgbox('The input for manual mode is smaller than 1.','ERROR', 'error')
     return;     
end   

% --- Executes on button press in manualmodebut.
function manualmodebut_Callback(~, ~, handles)
set(handles.manualmodesteps,'enable','On')

% --- Executes on button press in customoutoff.
function customoutoff_Callback(hObject, ~, handles)
customout=get(hObject,'Value');
if customout==0
set(handles.parametersout,'enable','Off')
set(handles.fitsoutput,'enable','Off')
set(handles.propoutput,'enable','Off')
set(handles.scurvesoutput,'enable','Off')
else
set(handles.parametersout,'enable','On')
set(handles.fitsoutput,'enable','On')
set(handles.propoutput,'enable','On')
set(handles.scurvesoutput,'enable','On')
end

function manualon_Callback(~, ~, handles)
set(handles.manualmodesteps,'enable','On')
set(handles.manualoff,'value',0)

function manualoff_Callback(~, ~, handles)
set(handles.manualmodesteps,'enable','Off')
set(handles.manualon,'value',0)
set(handles.manualmodesteps,'string',1);

function data_path_Callback(hObject, ~, ~)
chckfldr=get(hObject,'String');
chckfldr= exist(chckfldr);
if chckfldr ~= 7,  msgbox('The provided directory is not valid.','ERROR', 'error')
     return; end;

function fitrange_Callback(hObject, ~, ~)
fitrange=get(hObject,'String');
checkrange=isnan(str2double(fitrange));
     if checkrange==1
         msgbox('The iteration range parameter is NaN.','ERROR', 'error')
     return;
     end    

function res_mes_Callback(hObject,~, ~)
checktimeres=get(hObject,'String');
checktimeres=isnan(str2double(checktimeres));
     if checktimeres==1
         msgbox('The time resolution parameter is NaN.','ERROR', 'error')
     return;
     end

function SMaxTreshold_Callback(hObject, ~, ~)
checksmax=get(hObject,'String');
checksmax=isnan(str2double(checksmax));
     if checksmax==1
         msgbox('The acceptance threshold is NaN.','ERROR', 'error')
     return;
     end

function pitch_Callback(hObject, ~, ~)
checkpitch=get(hObject,'String');
checkpitch=isnan(str2double(checkpitch));
     if checkpitch==1
         msgbox('The sensitivity parameter is NaN.','ERROR', 'error')
     return;
     end

% --- Executes on button press in runprogram.
function runprogram_Callback(~, ~, handles,~,~,~)
AutoStepFinder(handles)

function meanbase_Callback(hObject, ~, ~)
checkmeanbase=get(hObject,'String');
checkmeanbase=isnan(str2double(checkmeanbase));
     if checkmeanbase==1
         msgbox('The mean base line parameter is NaN.','ERROR', 'error')
     return;
     end

function uibuttongroup1_SelectionChangedFcn(~, ~, handles)
initval.PostProcessOn=get(handles.basetreshon,'Value');
if initval.PostProcessOn == 1
       set(handles.PostPros, 'Visible','On');
end
initval.PostProcessOff=get(handles.basetreshoff,'Value');
if initval.PostProcessOff == 1
       set(handles.PostPros, 'Visible','Off');   
       MeanBase = 0;
       set(handles.meanbase, 'String', MeanBase);
end

function paneladv_SelectionChangedFcn(~, ~, handles)
initval.AdvancedOn=get(handles.advancedon,'Value');
if initval.AdvancedOn == 1
       set(handles.AdvancedSettings,'Visible','On');
       set(handles.AdvancedFitting,'Visible','On');
       set(handles.Scurve_eval,'Visible','On');
       set(handles.fileextbox,'Visible','On');
       set(handles.customoutputbox,'Visible','On');
       set(handles.customoutoff,'Value',0);
       set(handles.manualoff,'value',1);
end
initval.AdvancedOff=get(handles.advancedoff,'Value');
if initval.AdvancedOff == 1
       set(handles.AdvancedSettings,'Visible','Off');
       set(handles.AdvancedFitting,'Visible','Off');
       set(handles.Scurve_eval,'Visible','Off');
       set(handles.fileextbox,'Visible','Off');
       set(handles.customoutputbox,'Visible','Off');
       set(handles.fitmean,'Value',1);
       set(handles.scruveevaloff,'Value',1);
       set(handles.customoutoff,'Value',1);
       set(handles.parametersout,'Value',1);
       set(handles.fitsoutput,'Value',1);
       set(handles.propoutput,'Value',1);
       set(handles.scurvesoutput,'Value',1);
       set(handles.parametersout,'enable','Off');
       set(handles.fitsoutput,'enable','Off');
       set(handles.propoutput,'enable','Off');
       set(handles.scurvesoutput,'enable','Off');
       set(handles.manualmodesteps,'string',1);
       set(handles.manualmodesteps,'enable','Off');
       set(handles.manualon,'value',0);
       set(handles.txtoutput,'Value',1);
       set(handles.SMaxTreshold,'string',0.15);
end

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



 function autostepfinder_mainloop(initval,handles)
 %This is the main, multi-pass loop of the autostepfinder
 while initval.nextfile>0 
    [Data,SaveName,initval]=Get_Data(initval);
    tic
    LD=length(Data);
    IndexAxis=(1:LD)';     
    stepnumber_firstrun=min([ceil(LD/4) initval.fitrange]);        
    Residu=Data;  Fit=0*Data;
    S_Curves=zeros(stepnumber_firstrun+1,2); 
    N_found_steps_per_round=zeros(2,1); 
    full_split_log=[];
    for fitround=1:2
        initval.stepnumber=stepnumber_firstrun;                         
        [FitResidu,~,S_Curve,split_indices,best_shot]=StepfinderCore(Residu,initval);       
        steproundaccept=(max(S_Curve)>initval.SMaxTreshold);
        if steproundaccept
           N_found_steps_per_round(fitround)=best_shot;         
           full_split_log=expand_split_log(full_split_log,split_indices,fitround,best_shot);           
         end   
        S_Curves(:,fitround)=S_Curve;
        Residu=Residu-FitResidu;  %new residu  
        Fit=Fit+FitResidu ;       %new fit
    end    
    
    %Final analysis: 
    if max(N_found_steps_per_round)==0, cla;
       msgbox('No steps found','Operation complete', 'help'); 
    else          
    [FinalSteps, FinalFit]=BuildFinalfit(IndexAxis,Data,full_split_log,initval);                 
     SaveAndPlot(   initval,SaveName,handles,...
                            IndexAxis, Data, FinalFit,...
                            S_Curves, FinalSteps,N_found_steps_per_round);     
     end        
     disp('done!');
     toc
 end



%% This section (490- to ~650) contains the 'Core' function of the stepfinder; 
%it can be cut and autorun independently (on a simple simulated curve) for demo purposes

function [FitX,stepsX,S_fin,splitlog,best_shot]=StepfinderCore(X,initval)
%This function splits data in a quick fashion.
%This one is a compact version of the first quick 2007 version
%output: list of stepsizes: [index time  levelbefore levelafter step dwelltimeafter steperror]
if nargin<2
    X=2*round(0.5+0.1*sin(2*pi*(1:20000)'/500))+rand(20000,1); 
    initval.stepnumber=300; initval.overshoot=1;   
end
    %% 1 split, estimate best fit, repeat
    initval.stepnumber=min([ceil(length(X)/4) initval.stepnumber]);
    [~,~,S_raw,splitlog]=Split_until_ready(X,initval); %run 1: full iteration
    
    [s_peakidx,S_fin]=Eval_Scurve(S_raw);
    best_shot=round(min([(s_peakidx-1) ceil(length(X)/4)])); 
    indexlist=sort(splitlog(1:best_shot)); 
    
    FitX=Get_FitFromStepsindices(X,indexlist,initval);   
    stepsX=Get_Steps(FitX); 

if nargin<2
    close all;
    subplot(2,1,1); plot(X,'r'),hold;plot(FitX,'k','LineWidth',2);
    title('Data and Fit');xlabel('time');ylabel('position,a.u.');
    subplot(2,1,2); semilogx(S_fin,'-o');
    title('S-curve');xlabel('Stepnumber');ylabel('S-value, a.u.');
end


function [bestshot,S_fin]=Eval_Scurve(S_raw)
    S_raw(S_raw<1)=1; S2=S_raw-1;  %remove base line
    BaseLine=linspace(0,S2(end),length(S2)); S3=S2-BaseLine';
    %S4=smooth(S3,ceil(ix/25));
    [~,i1]=max(S3);  %peak
    %sel=find(S3>0.9*pk1);i2=max(sel(sel>=i1)); bestshot=i2;
    bestshot=i1;
    S_fin=S3;
  
    
function stepsX=Get_Steps(FitX)
%list of stepsizes: [index time step levelbefore levelafter dwelltimeafter]    
    lx=length(FitX);
    T=(1:lx)';
    difX=FitX(2:lx)-FitX(1:lx-1);
    sel=find(difX~=0);    
    lsel=length(sel);
    if lsel>0
        dwellX=T(sel(2:lsel))-T(sel(1:lsel-1)); dwellX=[dwellX' T(lx)-T(sel(lsel))]';
        stepsX=[sel T(sel) FitX(sel) FitX(sel+1) difX(sel) dwellX];
    else
        stepsX=[NaN NaN NaN NaN NaN NaN];
    end
            
function [FitX,f,S,splitlog]=Split_until_ready(X,initval)
     c=1; stop=0;
     N=length(X);    
     FitX=mean(X)*ones(N,1); 
     S=ones(initval.stepnumber,1);
     splitlog=zeros(initval.stepnumber,1);
     %Create the first plateau------------------------------------------
     istart=1; istop=length(X);
     [inxt, avl, avr,rankit]=Splitfast(X(istart:istop));           
     f=[[1, 1, 1, 0, 0,0];
        [istart, istop, inxt+istart-1, avl, avr,rankit]; ...
        [N, N, N,0, 0,0,]];  
     %parameters needed for calculating S(1):-----------------
    qx=sum(X.^2);                                   %sum of squared data
    qm=N*(mean(X))^2;                               %sum of squared averages plateaus, startvalue
    aqm=(inxt-istart+1)*avl^2+(istop-inxt)*avr^2;   %sum of squared averages anti-plateaus, startvalue
    S(c)=(qx-aqm)/(qx-qm);                          %S: ratio of variances of fit and anti-fit        
    %---------------------------------       
    wm=3;  %minimum plateau length to split
     while stop==0 %Split until ready 
        c=c+1;
        fsel=find((f(:,2)-f(:,1)>wm)&f(:,6)~=0);        %among those plateaus sensibly long..
        [~,idx2]=max(f(fsel,6)); idx=(fsel(idx2));   %...find the best candidate to split. 
        splitlog(c-1)=f(idx,3);                          %keep track of index order
        FitX=Adapt_Fit(f,idx,FitX);                     %adapt fit-curve
        [f,qm,aqm]=expand_f(f,qm,aqm,idx,X);            %adapt plateau-table; adapt S
        S(c)=(qx-aqm)/(qx-qm);                             %Calculate new S-function               
        stop=(1.0*c>initval.stepnumber);
    end   %-------------------------------------------------------------------
          
function [f,qm,aqm]=expand_f(f,qm,aqm,idx,X)
%this function inserts two new plateau-property rows on the location of one old one
%....and adapts the S-function nominator and denominator

   %1) Label new levels.FLR locatess 'plateau fit  left right' etc  
    nFLR=f(idx-1,2)-f(idx-1,3);       avFLR=f(idx-1,5);      %FLR
    nFML=f(idx,3)-f(idx,1)+1;         avFML=f(idx,4);        %FML
    nFMR=f(idx,2)-f(idx,3);           avFMR=f(idx,5);        %FMR
    nFRL=f(idx+1,3)-f(idx+1,1)+1;     avFRL=f(idx+1,4);      %FRL
      
    %remove contribution from old plateau(s) from S-function terms
    qm=qm-1/(nFML+nFMR)*(nFML*avFML+nFMR*avFMR)^2;            %FM
    aqm=aqm-    1/(nFLR+nFML)*(nFLR*avFLR+nFML*avFML)^2-...   %CL
                1/(nFMR+nFRL)*(nFMR*avFMR+nFRL*avFRL)^2;      %CR
            
    %2a) construct new first plateau entry, left
	istart=f(idx,1); istop=f(idx,3);
	[inxt, avl, avr,rankit]=Splitfast(X(istart:istop));
    n1=[istart istop inxt+istart-1, avl, avr,rankit];
    
    %2b) construct new first plateau entry, right
	istart=f(idx,3)+1; istop=f(idx,2);
	[inxt, avl, avr,rankit]=Splitfast(X(istart:istop));
	n2=[istart istop inxt+istart-1, avl, avr,rankit];
	
    %3) Insert these two new plateaus in place of the old one
	[lf,~]=size(f);      
    block1=f(1:idx,:);      block1(idx,:)=n1;
	block2=f(idx:lf,:); 	block2(1,:)=n2;
	f=[block1; block2];
    
    %Label newly defined levels.FMLR locates 'plateaufit mid/left/right' etc
    nFMLL=f(idx,3)-f(idx,1)+1;          avFMLL=f(idx,4);    %FMLL
    nFMLR=f(idx,2)-f(idx,3);            avFMLR=f(idx,5);    %FMLR
    nFMRL=f(idx+1,3)-f(idx+1,1)+1;      avFMRL=f(idx+1,4);  %FMRL
    nFMRR=f(idx+1,2)-f(idx+1,3);        avFMRR=f(idx+1,5);  %FMRR
    
    %4) add contribution from new plateau(s) to S-function terms
    qm=qm...
        +1/(nFMLL+nFMLR)*(nFMLL*avFMLL+nFMLR*avFMLR)^2 ...  %FML
        +1/(nFMRL+nFMRR)*(nFMRL*avFMRL+nFMRR*avFMRR)^2;     %FMR
    aqm=aqm ...
        +1/(nFLR+nFMLL)*(nFLR*avFLR+nFMLL*avFMLL)^2 ...      %CTL
        +1/(nFMLR+nFMRL)*(nFMLR*avFMLR+nFMRL*avFMRL)^2 ...   %CTM
        +1/(nFMRR+nFRL)*(nFMRR*avFMRR+nFRL*avFRL)^2;         %CTR

function FitX=Adapt_Fit(f,idx,FitX)
	%This function creates step  and property curves adds new plateaus
	i1=f(idx,1); i2=f(idx,3);av1=f(idx,4);
    i3=f(idx,3)+1; i4=f(idx,2);av2=f(idx,5);
    FitX(i1:i2)=av1; FitX(i3:i4)=av2;
              
 function [idx, avl, avr,rankit]=Splitfast(Segment)              %
%this function also adresses a one-dim array 'Segment'
%and determines the best step-fit there
%To save time, functions like 'mean' are avoided
    w=length(Segment);     
    if w>3
		Chisq=(1:w-1)*0;                           
        AvL=Segment(1);    AvR=sum(Segment(2:w))/(w-1); AvAll=sum(Segment)/w;  
        for t=2:w-2
            AvL=(AvL*(t-1)+Segment(t))/t;     AvR=(AvR*(w-t+1)-Segment(t))/(w-t);
            DStepL=AvL-AvAll;           DStepR=AvR-AvAll;
            DeltaChisq=((DStepL.^2)*t+(DStepR.^2)*(w-t));            
            Chisq(t)=-DeltaChisq;       
        end
         [~,idx]=min(Chisq(2:w-2)); idx=idx+1;
         avl=mean(Segment(1:idx));                    avr=mean(Segment(idx+1:w));
         %rankit=(avr-avl)^2/(1/(idx-1)+1/(w-idx-1));  %quantity expresing predicted accuracy step (squared)
         rankit=(avr-avl)^2*w;
    else                                            %low-limit cases
         rankit=0;               
         switch w
             case 3 
                a=(Segment(2)+Segment(3))/2-Segment(1);            b=Segment(3)-(Segment(1)+Segment(2))/2;
                cL=[Segment(1) , (Segment(1)+Segment(2))/2];      cR=[(Segment(2)+Segment(3))/2 , Segment(3)]; 
                [~,idx]=max([a b]);    avl=cL(idx);  avr=cR(idx);
            case 2
                idx=1;  avl=Segment(1); avr=Segment(2); 
        end
    end

  function FitX=Get_FitFromStepsindices(X,indexlist,initval) 
      
      % This function builds plateau data
    %list of levels: [startindex  stopindex starttime stoptime level dwell stepbefore stepafter]
        if initval.fitmean&&~initval.fitmedian, modus='mean';end;
        if ~initval.fitmean&&initval.fitmedian, modus='median';end;
    lx=length(X);
        lsel=length(indexlist); %note: index points to last point before step

        %Build a 'FitX' based on the median levels (ot on the averages)
        idxes=[0 ; indexlist ; lx];
        FitX=0*X;
        for ii=1:lsel+1
            ixlo=idxes(ii)+1;  %first index of plateau
            ixhi=idxes(ii+1);  %last index
            switch modus
                case 'mean', FitX(ixlo:ixhi)=nanmean(X(ixlo:ixhi));
                case 'median', FitX(ixlo:ixhi)=nanmedian(X(ixlo:ixhi));
            end
        end 
        
        %% This section contains code related to the multipass steps
 
      function full_split_log=expand_split_log(full_split_log,split_indices,fitround,best_shot)
           %expand split log; remove double entries (when a residu of a
           %step is found again, we label the location by its first
           %round occurence)
           LS=length(split_indices);
           new_split_log=[split_indices 3*ones(LS,1)];
           new_split_log(1:best_shot,2)=fitround;          
               if fitround==1
                    full_split_log=[full_split_log ; new_split_log];
               else
                    already_found=find(full_split_log(:,2)<3);  %steps already spotted
                    new_found=find(~ismember(new_split_log(:,1),full_split_log(already_found,1)));                  
                    full_split_log= [full_split_log(already_found,:);...
                                     new_split_log(new_found,:)];
               end
                    
function StepsX=AddStep_Errors(X,StepsX,initval)   
%This function calculates step errors associated with the steps.
% Two options: 
%     1) the standard deviation of the adjacent plateaus
%     2) the global noise level and the length of these plateaus

if strcmp(initval.steperrorestimate,'predicted')
    shft=2;
    globalnoise=nanstd((X(shft:end)-X(1:end-shft+1)))/sqrt(2);
end

[ls,col]=size(StepsX); i1=0;
for i=1:ls
    i2=StepsX(i);
    if i<ls
        i3=StepsX(i+1);
    else 
        i3=length(X);
    end    
    Nbefore=i2-i1;    
    Nafter=i3-i2;
    
    if strcmp(initval.steperrorestimate,'measured')
        rmsbefore=std(X(i1+1:i2));
        rmsafter=std(X(i2+1:i3)) ;
        StepsX(i,col+1)=2*(rmsbefore^2/Nbefore+rmsafter^2/Nafter)^0.5; %plus minus 95%
    end
    if strcmp(initval.steperrorestimate,'predicted')
        StepsX(i,col+1)=2*(globalnoise^2/Nbefore+globalnoise^2/Nafter)^0.5; %plus minus 95%
    end
    i1=i2;
end


function [FinalSteps, FinalFit]=BuildFinalfit(T,X,splitlog,initval)
%build a step fit based on all retained indices. Perform step-by-step error
%analysis to accept second-round (residual) steps or not 
    best_shot=length(find(splitlog(:,2)<3)); %all non-duplicates
    if (initval.manualoff==1 && initval.manualon==0)
        steps_to_pick=round(initval.overshoot*best_shot);
    end
    if (initval.manualoff==0 && initval.manualon==1)
        steps_to_pick=initval.setsteps;
    end
    %select indices to use
    bestlist=(splitlog(1:steps_to_pick,:));  
    [candidate_loc,ix]=sort(bestlist(:,1));
    candidateround_no=bestlist(ix,2);

    %2)Rebuild fit from all indices.
    candidate_fit=Get_FitFromStepsindices(X,candidate_loc,initval); 
    candidate_steps=Get_StepTableFromFit(T,candidate_fit); 
    %3 get errors
    candidate_steps=AddStep_Errors(X,candidate_steps,initval); 
    candidate_relsteperror=(candidate_steps(:,8)./abs(candidate_steps(:,5))); 
 
    
    if (initval.localstepmerge && ~initval.setsteps)
        % Default: Keep round 1-steps AND 'good' round 2 steps:
        % Get a   measure for the error of steps in the first round. 
        % This can be used for reference of errors from second-round steps
        [~,~,FinalErrorTreshold]=Outlier_flag(candidate_relsteperror,2,0.8,'positive',0);
        sel_merge=find((candidate_relsteperror<2*FinalErrorTreshold)|candidateround_no==1);        
        final_idxes=candidate_steps(sel_merge,1); 
    else
        final_idxes=candidate_steps(:,1); 
    end
    %Re-build the fit from the selected indices (Effectively, rejected
    %indices are 'merged' in this step)
    FinalFit=Get_FitFromStepsindices(X,final_idxes,initval);
    FinalSteps=Get_StepTableFromFit(T,FinalFit); 
    FinalSteps=AddStep_Errors(X,FinalSteps,initval);
    LF=length(FinalSteps(:,1));
    FinalRoundNo=zeros(LF,1);
    for ii=1:LF
        idxC=FinalSteps(ii,1);
        sel=find(candidate_steps(:,1)==idxC);
        FinalRoundNo(ii)=candidateround_no(sel(1));
    end        
    FinalSteps(:,9)=FinalRoundNo;  
  
   
 
function [Data,SaveName,initval]=Get_Data(initval)
% This function loads the data, either standard or user-choice
    disp('Loading..');
    CurrentFolder=pwd;
    switch initval.hand_load     
        case 1      
        cd(initval.datapath);
        [FileName,PathName] = uigetfile('*.*','Select the signal file');
        cd(CurrentFolder);
        source=strcat(PathName,FileName);
        data=double(dlmread(source));
        SaveName=FileName(1:length(FileName)-4);
        initval.nextfile=0;      
        case 2
            fileindex=initval.nextfile;
            cd(initval.datapath);
            AllFileNames=dir('*.txt');
            cd(CurrentFolder);
            chckflder=length(AllFileNames);
            if chckflder == 0,  msgbox('The provided input folder is empty.','ERROR', 'error')
            return; end;
            AllFiles=length(AllFileNames);
            FileName=AllFileNames(fileindex).name;
            data=double(dlmread(strcat(initval.datapath,'\',FileName)));
            SaveName=FileName(1:length(FileName)-4);
            if initval.nextfile==AllFiles
                initval.nextfile=0;
            else
                initval.nextfile=fileindex+1;
            end           
    end
    [LD,cols]=size(data);
    if cols>2, msgbox('Wrong data format','ERROR', 'error'), return;end
    if cols>1, data=data(:,2); end %if array,it is assumed first column is time
    if initval.CropInputDataFactor<1
        Cropit=round(LD/initval.CropInputDataFactor);    
        Data=data(1:Cropit); 
    else
        Data=data; 
    end
%    check for NaN + Inf values
     infcheck=isinf(Data);
     nancheck=isnan(Data);

     if sum(infcheck)>0
         msgbox('Your data contains infinite values','ERROR', 'error')
         return;
     end

     if sum(nancheck)>0
         msgbox('Your data contains NaN values','ERROR', 'error')
         return;
     end         
     disp('Analyzing:'), disp(SaveName);
   
 
  
        
 function [StepsX,levelX, histX]=Get_StepTableFromFit(T,FitX)
%This function builds tables of steps or levels properties from a step fit
%Values are based on Averages of plateaus
    lx=length(FitX);
    difX=FitX(2:lx)-FitX(1:lx-1);
    sel=find(difX~=0);  %note: index points to last point before step
    lsel=length(sel);
        
    %dwell time after
    dwellT=T(sel(2:lsel))-T(sel(1:lsel-1)); 
    dwellTafter=[dwellT' T(lx)-T(sel(lsel))]';
    dwellTbefore=[T(sel(1))-T(1) dwellT']'; 
    StepsX=[sel T(sel) FitX(sel) FitX(sel+1) difX(sel) dwellTbefore dwellTafter]; 
    %list of stepsizes: [index time levelbefore levelafter step dwelltime before dwelltimeafter]
    
    Levstartidx=[1; sel+1];  %first index of level
    Levstopidx=[sel; lx];    %last index of level
    LevstartT=T(Levstartidx);
    LevstopT=T(Levstopidx);
    LevLevel=[FitX(sel); FitX(lx)];
    LevDwell=Levstopidx-Levstartidx+1;
    LevStepBefore=[0; difX(sel)];
    LevStepAfter=[difX(sel); 0];
    levelX=[Levstartidx Levstopidx LevstartT LevstopT LevLevel LevDwell LevStepBefore LevStepAfter];
    %list of levels: [startindex starttime stopindex stoptime level dwell stepbefore stepafter]   
    
    %histogram
    stepsizes=StepsX(:,4)-StepsX(:,3);
    mx=max(stepsizes); mn=min(stepsizes);
    stp=(mx-mn)/20;
    hx=(mn:stp:mx);
    if ~isempty(hx)
        histX=hist(stepsizes,hx)';
        histX=[hx' histX];
    else
        histX=[1 1];
    end
    
    
 
    
 function [flag,cleandata,treshold]=Outlier_flag(data,tolerance,sigchange,how,sho)
%this function is meant to find a representative value for a standard
%deviation in a heavily skewed distribution (typically, flat data with
% %peaks). It calculates the standard deviation and average the data;
% Based on these, outliers are determined and excluded for a new calculation
% of average and SD; this is repeated until sigma does not change anymore too much
% . This is repeated until the new sigma does not change much
% %anymore
%output: positions of outliers
%Jacob Kers 2013 and before---------------------------------------------
binz=50;

sigma=1E20;            %at start, use a total-upper-limit 
ratio=0;
ld=length(data);
flag=ones(ld,1);  %at start, all points are selected
while ratio<sigchange     %if not too much changes anymore; the higher this number the less outliers are peeled off.
    sigma_old=sigma;
    selc=find(flag==1);
    data(flag==1); 
    av=nanmedian(data(selc));       %since we expect skewed distribution, we use the median iso the mea     
    sigma=nanstd(data(selc));
    ratio=sigma/sigma_old;
    treshold=tolerance*sigma+av;
    switch how
        case 'positive',  flag=(data-av)<tolerance*sigma;     %adjust outlier flags
        case 'all',  flag=abs(data-av)<tolerance*sigma;     %adjust outlier flags  
    end
    %plot menu------------------  
    if sho==1
        cleandata=data(selc); 
        hx=(min(cleandata):(range(cleandata))/binz:max(cleandata));   %make an axis
        sthst=hist(cleandata,hx);
        figure;
        bar(hx,sthst);
        title('Histogram');
        pause(0.5);  
        close(gcf);
    end
    %---------------------------- 
end
cleandata=data(selc); 

function SaveAndPlot(initval,SaveName,handles,...
        IndexAxis,Data,FinalFit,...
        S_Curves, FinalSteps,N_found_steps_per_round)

%This function saves and plots data.
stepno_final=length(FinalSteps(:,1));
disp('Steps found:'), display(stepno_final);    
disp('Saving Files...')

     %% plot and save section
        initval.SaveFolder                =  [SaveName,'_Fitting_Result'];        %Make new folder to save results
        initval.SaveFolder                 = 'StepFit_Result';        %Make new folder to save results
        initval.SaveFolder                 =  fullfile(initval.datapath, initval.SaveFolder);
         if ~exist(initval.SaveFolder, 'dir')                                   %Check if folder already exists
         mkdir(initval.SaveFolder);                                             %If not create new folder 
         end    
    
    %Fits
      Time                      = IndexAxis*initval.resolution;                 %Time Axis 
      
    %S-Curve
      S_Curves=S_Curves(2:end,:);                                       %crop
      Stepnumber                = (1:1:length(S_Curves))';              %Stepnumbers
      SCurveRound1              = S_Curves(:,1);                        %S-Curve round 1
      SCurveRound2              = S_Curves(:,2);                        %S-Curve round 2
    
    %Step properties
      idx_steps                 =  FinalSteps(:,4)> initval.basetresh;  %Treshholding of steps
      IndexStep                 =  FinalSteps(idx_steps,1);             %Index where step occured
      TimeStep                  =  FinalSteps(idx_steps,2)...           %Time when step occured
                                   *initval.resolution; 
      LevelBefore               =  FinalSteps(idx_steps,3);             %Level before step
      LevelAfter                =  FinalSteps(idx_steps,4);             %Level after step
      StepSize                  =  LevelAfter - LevelBefore;            %Size of step
      DwellTimeStepBefore       =  FinalSteps(idx_steps,6)...           %Dwelltime step before
                                   *initval.resolution;       
      DwellTimeStepAfter        =  FinalSteps(idx_steps,7)...           %Dwelltime step after
                                   *initval.resolution;  
      StepError                 =  FinalSteps(idx_steps,8);             %Error of each step
      
      curpth=pwd;
      cd(initval.SaveFolder);
      
      if initval.txtoutput == 1
      initval.savestring='txt';
      end
      
      if initval.matoutput == 1
      initval.savestring='mat';
      end
      
      switch initval.savestring
          case 'txt' 
            % CropInputDataFactor: 1
            % GlobalErrorAccept: 0.1000
            % SMaxTreshold: 0.1500
            % basetresh: -100000
            % fitmean: 1
            % fitmedian: 0
            % fitrange: 4000
            % fitsoutput: 1
            % initval.hand_load: 1
            % localstepmerge: 1
            % manualoff: 1
            % manualon: 0
            % matoutput: 0
            % meanbase: 0
            % nextfile: 0
            % overshoot: 1
            % parametersout: 1
            % propoutput: 1
            % resolution: 1
            % savestring: 'txt'
            % scurve_eval: 0
            % scurvesoutput: 1
            % setsteps: 1
            % showintermediateplots: 1
            % singlerun: 1
            % steperrorestimate: 'predicted'
            % stepnumber: 1000
            % steprepulsion: 0.1000
            % treshonoff: 0
            % txtoutput: 1
            % userplt: 0
              config_table              = struct2table(orderfields(initval));              
              fits_table                = table(Time, Data, FinalFit);          %Save variables in table           
              properties_table          = table(IndexStep,TimeStep,...          %Save variables in table
                                          LevelBefore,LevelAfter,StepSize,...
                                          DwellTimeStepBefore,DwellTimeStepAfter,StepError);
               s_curve_table              = table(Stepnumber, SCurveRound1,...    %Save variables in table 
                                          SCurveRound2);                         
       if initval.fitsoutput == 1
               writetable(fits_table, [SaveName,'_fits.txt']);                   %Save table containing fits                       
       end
       if initval.propoutput == 1
               writetable(properties_table, [SaveName,'_properties.txt']);       %Save table containing properties                          
       end
       if initval.scurvesoutput == 1
               writetable(s_curve_table, [SaveName,'_s_curve.txt']);               %Save table containing S-curves     
       end       
       if initval.parametersout == 1
               writetable(config_table, [SaveName,'_config.txt']);               %Save table containing S-curves     
       end
     
       case 'mat'
       if initval.fitsoutput == 1       
              save([SaveName,'_fits'],'Time', 'Data', 'FinalFit'); 
       end
       if initval.propoutput == 1
              save([SaveName,'_properties'],...
                 'IndexStep','TimeStep',...   
                 'LevelBefore','LevelAfter','StepSize',...
                 'DwellTimeStepBefore','DwellTimeStepAfter',...
                 'StepError');
       end
       if initval.scurvesoutput == 1 
               save([SaveName,'_s_curve'],...
                 'Stepnumber', 'SCurveRound1','SCurveRound2');
       end
       if initval.parametersout == 1
              save([SaveName,'_config'],...
                 'initval');   
       end
       
      end
      cd(curpth);

 %% Plotting in GUI  
        close(findobj('type','figure','name','S-Curve Evaluation'));        %close S-curve plots --> for batch mode
        close(findobj('type','figure','name','User plots'));                %close user plots --> for batch mode
        cla;                                                                %clear axes 
        axis(handles.plot_fit);
        plot(Time,Data,...                                                  %Plot Data
        'LineWidth',2,....                                                  %Linewidth
        'Color',[0,0.2,1]);                                                 %Color line RBG
        hold on
        plot(Time,FinalFit,...                                              %Plot Fit
        'LineWidth',1.5,....                                                  %Linewidth
        'Color',[1,0.7,0]);                                                 %Color line RBG
        initval.MaxX=Time(end);                                             %Determine length X axis
        initval.MaxY=max(Data)*1.2;                                         %Determine length Y axis
        initval.MinY=min(Data);                                         %Determine length Y axis
        xlim([0 initval.MaxX]);                                             %Set X axis
        ylim([initval.MinY initval.MaxY]);                                             %Set Y axis
        xlabel('Time (s)','FontSize',12);                                   %Label X axis
        ylabel('Position (A.U.)','FontSize',12);                            %Label Y axis
        set(gca,'TickDir','out','TickLength',[0.003 0.0035],'box', 'off');  %Set ticks outslide plotting area, remove box plot
        initval.LegPlt=legend('Data','Fit');                                %Set labels legend
        set(initval.LegPlt,'box', 'Off','Orientation','Horizontal');        %Remove box legend, align horizontal
        if initval.treshonoff == 1                                          %If baseline tresholding is on plot line
            initval.BaseLine=repmat(initval.basetresh,1,length(Time));      %Generate array filled with baseline value
            hold on
            plot(Time,initval.BaseLine,...                                  %Plot treshold line                                              
            'LineWidth',2,...
            'Color',[1,0,0]); 
            initval.LegPlt=legend('Data','Fit','Treshold');                             %Update labels legend
            set(initval.LegPlt,'box', 'Off','Orientation','Horizontal');                %Remove box legend, align horizontal
        end

        if initval.singlerun == 0                                           %Save figure with fit, during batch mode
            cd(initval.datapath);                                               %Set current directory to datapath
            initval.FitPlt = figure('visible', 'off');                          %Plot invisible figure for saving
            set(gcf, 'units', 'normalized', 'position', [0.01 1 0.7 0.5])       %Set size figure same as GUI
            copyobj(handles.plot_fit, initval.FitPlt);                          %Copy figure from GUI
            xlabel('Time (s)','FontSize',12);                                   %Set label X axis
            ylabel('Position (A.U.)','FontSize',12);                            %Set label Y axis
            set(gca,'TickDir','out','TickLength',[0.003 0.0035],'box', 'off');  %Set ticks outslide plotting area, remove box plot
            saveas(initval.FitPlt, [initval.SaveFolder '\' SaveName '_fitfig.jpg']);                      %Save figure as jpg
            close(initval.FitPlt);                                              %Close invisible plot
        end
        cd(initval.codefolder);                                             %Set current directory to pwd

  %% Plotting user Plots
        if initval.userplt==1
            User_Plot_Result(IndexAxis,Data,FinalFit,FinalSteps,S_Curves,initval);
            if initval.singlerun == 0                                           %Save userplot jpg if batch run is on
            cd(initval.SaveFolder);                                             %Set current directory to savefolder                                                   
            saveas(findobj('type','figure','name','User plots'),...             %Save userplot figure as jpg
            [initval.SaveFolder '\' SaveName '_user_plot.jpg']);
            end
        end
        
        

 %% Plotting S-Curve Evaluation
        if initval.scurve_eval==1                                          
                LS=length(S_Curves(:,1));
    Stepnumber = (1:1:LS)'; 
    SCurveRound1   = S_Curves(:,1); %S-Curve round 1
    SCurveRound2   = S_Curves(:,2); %S-Curve round 2
    stepno_round1=N_found_steps_per_round(1);
    stepno_round2=N_found_steps_per_round(2);
    MK=1.1*max(S_Curves(:));
    
    figure('Name','S-Curve Evaluation','NumberTitle','off','units', 'normalized', 'position', [0.745 0.32 0.25 0.6]);
    %S-Curve round 1
    SCurve1Plt=subplot(1,1,1);
    cla(SCurve1Plt);

    ThreshHold=repmat(initval.SMaxTreshold,1,length(Stepnumber));
          
    plot(Stepnumber,SCurveRound1,'k-', 'LineWidth',1); hold on
    plot(Stepnumber,SCurveRound2,'b-', 'LineWidth',1); hold on
    plot(Stepnumber,ThreshHold,'r--', 'LineWidth',1);
    plot(stepno_round1,SCurveRound1(stepno_round1),'ko','MarkerFaceColor','k','MarkerSize',6);
    if stepno_round2>0
        plotidx=stepno_round2; 
    else
        plotidx=1;
    end
    plot(plotidx,SCurveRound2(plotidx),'bo','MarkerFaceColor','b','MarkerSize',6);   
    plot(stepno_final,SCurveRound1(stepno_final),'ro','MarkerSize',12);


    xlim([0 LS]); 
    ylim([0 MK]);
    set(gca,'TickDir','out','TickLength',[0.003 0.0035],'box', 'off'); %Ticks outslide plotting area

    title('Multi-pass S-curves');
    legend('Round 1','Round 2','Threshold','S_P_1^m^a^x','S_P_2^m^a^x','Final');
    
    
    xlabel('Step Number');
    ylabel('S-Score');
            if initval.singlerun == 0                                           %Save userplot jpg if batch run is on
            cd(initval.SaveFolder);                                             %Set current directory to savefolder  
            saveas(findobj('type','figure','name','S-Curve Evaluation'),...     %Save S-curve figure as jpg
            [SaveName '_s_curve.jpg'])
            end
        end
 
  function User_Plot_Result(~,~,~,FinalSteps,~,initval) 
%This function can be used to present user (and experiment-specific plots
%using the standard stepfinder output

idx_steps= FinalSteps(:,4)> initval.basetresh; % Threshholding of steps.

LevelBefore    =  FinalSteps(idx_steps,3); %Level before step
LevelAfter     =  FinalSteps(idx_steps,4); %Level after step
StepSize       =  LevelAfter - LevelBefore; %Size of step

%not in use------------------------------
% Stepnumber     = (1:1:length(S_Curves))';
% StepRange=max(Stepnumber);
% SCurveRound1   = S_Curves(:,1); %S-Curve round 1
% SCurveRound2   = S_Curves(:,2); %S-Curve round 2
% IndexStep      =  FinalSteps(idx_steps,1); %Index where step occured
% TimeStep       =  FinalSteps(idx_steps,2)*initval.resolution; %Time when step occured
% DwellTimeStep  =  FinalSteps(idx_steps,7)*initval.resolution; %Dwelltime step  
% ---------------------------------------------   

figure('Name','User plots','NumberTitle','off','units', 'normalized', 'position', [0.01 0.05 0.3 0.3]);
% %%  Transition Density Plot
%     DensityPlt = subplot(2,1,1);
%     cla(DensityPlt);
%     DensityBinsize = 0.02;
%     Xaxis=0:DensityBinsize:1;
%     Yaxis=0:DensityBinsize:1;
%     BinC={(Xaxis+(0.5*DensityBinsize)),((Yaxis+0.5*DensityBinsize))};
%     values = hist3([LevelAfter(:), LevelBefore(:)],'Ctrs',BinC);
%     contour(Xaxis,Yaxis,values);
%     colorbar;
%     title('Transition Density Plot');
%     xlabel('Level Before');
%     ylabel('Level After');

%Step-Level
    StepLPlt = subplot(2,1,1);
    cla(StepLPlt);
    StepBinsize = 0.05;
    XStep=0:StepBinsize:1;
    [histcounts, ~]= hist(LevelAfter,XStep);
    bar(XStep,histcounts)
    title('Levels');
    xlabel('Step Level');
    ylabel('Counts');
    ylimstep=max(histcounts*1.1);
    %xlimstep=max(LevelAfter*1.1);
    %ylim([0 ylimstep]);
    %xlim([0 xlimstep]);
        
%Step-size
    StepSPlt = subplot(2,1,2);
    cla(StepSPlt);
    StepBinsize = 0.05;
    XStep=-1:StepBinsize:1;
    [histcounts, ~]= hist(StepSize,XStep);
    bar(XStep,histcounts)
    title('Step-size');
    xlabel('Step Size');
    ylabel('Counts');
    %ylimstep=max(histcounts*1.1);
    %xlimstep=max(StepSize*1.1);
    %ylim([0 ylimstep]);
    %xlim([-1 xlimstep]);
    