function y = mp3player_plotwavR(~)
    mState = -1;
    screenRect = get(0,'Screensize');
    screenWidth = screenRect(3);
    screenHeight = screenRect(4);
    figWidth = 600;
    figHeight = 400;
    figX = (screenWidth - figWidth)/2;
    figY = (screenHeight-figHeight)/2;
    hFigure = figure(1);
    set(hFigure, 'position',[figX figY figWidth figHeight], 'color','white','toolbar','none', 'menubar','none', 'numbertitle','off', 'name','soundbytes');
    hAxes_BKG = axes('parent',hFigure);
    
    set(hAxes_BKG, 'units','pixels', 'position',[1 1 figWidth figHeight], 'xtick',[], 'ytick',[], 'xcolor','w', 'ycolor','w', 'Tag','hAxes_BKG');
    imgMatrix_BKG = ones(400,600,3);
    imshow(imgMatrix_BKG,'parent',hAxes_BKG);
    hAxes_Wave = axes('parent',hFigure);
    set(hAxes_Wave, 'units','pixels', 'position',[50 150 441 200], 'Tag','hAxes_Wave', 'xtick',[], 'ytick',[], 'box','on', 'Tag','hAxes_Wave');
    axis([1 441 1 200]);
    axis off;
    hPushbutton_Stop_Play = uicontrol('Style','Pushbutton', 'String','>||', 'Position',[221 51 100 30], 'Tag','hPushbutton_mState');
    mp3FileName = 'Under the bridge.mp3';
    [mp3Y, mp3Fs] = audioread(mp3FileName);
    mp3p = audioplayer(mp3Y,mp3Fs);
    set(mp3p, 'TimerPeriod',0.1, 'TimerFcn',{@PlayerTimerFcn,hFigure});
    totalSample = get(mp3p,'TotalSample');
    totalSeconds = floor(totalSample/mp3Fs);
    songMM = floor(totalSeconds/60);
    songSS = rem(totalSeconds,60);
    hSlider = uicontrol('Style','Slider','Min',0,'Max',totalSeconds,'Value',0,'SliderStep',[1/totalSeconds 0.05],'Position',[50 120 441 10], 'Tag','hSlider');
    set(hPushbutton_Stop_Play, 'Callback',{@hPushbutton_Stop_play_Fcn,hFigure});
    set(hSlider,'Callback',{@hSlider_Callback,hFigure});
    function hPushbutton_Stop_play_Fcn(hObject, eventData, hFig)
        if mState == 1
            pause(mp3p);
            mState = 0;
        elseif mState == 0
            resume(mp3p);
            mState = 1;
        else
            play(mp3p);
            mState = 1;
        end
    end
    function PlayerTimerFcn(hObject, eventData, hFig)
        hAxes_w = findobj(hFig, 'Tag','hAxes_Wave');
        set(hFig,'CurrentAxes',hAxes_w);
        hSlider_w = findobj(hFig, 'Tag','hSlider');
        sliderValue = get(hSlider_w,'value');
        sliderV = sliderValue * 44100;
        mTotalSamples = length(mp3Y);
        mTotalSeconds = round(mTotalSamples/44100);
        mCurrentSample = get(hObject,'CurrentSample');
        mCurrentSecond = round(mCurrentSample/mTotalSamples * mTotalSeconds);
        if mCurrentSecond < mTotalSeconds - 1
            if mCurrentSample > sliderV && mCurrentSample < sliderV+44100
                set(hSlider_w, 'Value',mCurrentSecond);
            end
 
            mSampleRate = get(hObject,'SampleRate');
 
            tmpX = mSampleRate/100;
            axes_X = 1:tmpX;
            a = length(axes_X);
 
            mp3Y1y = mp3Y(mCurrentSample:100:mCurrentSample+44099,1);
            plot(axes_X, mp3Y1y, '-r');
 
            axis([1 441 -1 1]);
            axis off;
        else
            stop(mp3p);
 
        end
    end
    function hSlider_Callback(hObject, eventData, hFig)
        mTotalSamples = get(mp3p,'TotalSample');
        mTotalSeconds = round(mTotalSamples/44100);
        sliderCurrentSecondCell = get(hObject,'value');
 
        if iscell(sliderCurrentSecondCell)
            sliderCurrentSecond = sliderCurrentSecondCell{1};
        else
            sliderCurrentSecond = sliderCurrentSecondCell;
        end
        mCurrentSample = round(sliderCurrentSecond * 44100);
        pause(mp3p);
        play(mp3p,mCurrentSample);
    end
    y = hFigure;
    
 
end