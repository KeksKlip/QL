require"QL"
require"iuplua"

log="moving_signals.log"
--�������������� ��������
chart1="short_mov"
chart2="long_mov"

is_run = true

function OnStop()
  is_run = false
  toLog(log,'OnStop. Script finished manually')
  message ("������ ���������� �������", 2)
  -- ���������� ������� ����
  t:delete()
end

function main()
	log=getScriptPath()..'\\'..log
	toLog(log,"Start main")
	--������� ������� ����
	t=QTable:new()
	-- ��������� 2 �������
	t:AddColumn("TREND DETECTOR",QTABLE_STRING_TYPE,45)
	t:AddColumn("SIGNAL",QTABLE_STRING_TYPE,30)
	-- ��������� �������� ��� �������
	t:SetCaption('Moving Signals')
	-- ���������� �������
	t:Show()
	-- ��������� ������ ������
	line=t:AddLine()

	while is_run do
		--�������� �������� �����������

		--���������� � ��������� �������
		n_chart1 = getNumCandles (chart1)
		if n_chart1==0 or n_chart1==nil then
			toLog(log,'Can`t get data from chart '..chart1)
			message('�� ����� �������� ������ � ������� '..chart1,1)
			is_run=false
			break
		end
		--���������� � �������� �������
		n_chart2 = getNumCandles(chart2)
		if n_chart2==0 or n_chart2==nil then
			toLog(log,'Can`t get data from chart '..chart2)
			message('�� ����� �������� ������ � ������� '..chart2,1)
			is_run=false
			break
		end
		--�������� ���������� �������� ��������� �������
		short_mov1 = getCandlesByIndex(chart1,0,n_chart1-2,1)[0].close

		--�������� �������������� �������� ��������� �������
		short_mov2 = getCandlesByIndex(chart1,0,n_chart2-3,1)[0].close
	  
		--�������� ���������� �������� �������� �������
		long_mov1 = getCandlesByIndex(chart2,0,n_chart2-2,1)[0].close

		--�������� �������������� �������� ��������   �������
		long_mov2 = getCandlesByIndex(chart2,0,n_chart2-3,1)[0].close

		--�������� ������
		if short_mov1>short_mov2 and long_mov1>long_mov2 then
			TREND_DETECTOR="��� ������� ������. ����� �����" --������� ���������� TREND_DETECTOR � ������� �����.
		elseif short_mov1<short_mov2 and long_mov1<long_mov2 then
			TREND_DETECTOR="��� ������� ������. ����� ��������" --������� ���������� TREND_DETECTOR � ������� �����.
		else
			TREND_DETECTOR="��� ����������� ������"
		end
	
		--��������� ��������.

		--������� �����
		if short_mov1>long_mov1 and short_mov2<long_mov2 then
			iup.Message('����� ������!','������� �����')	
			toLog (log, "Golden Cross detected")
			SIGNAL="GOLDEN CROSS" --������� � ������� �����.
		--̸����� �����
		elseif short_mov1<long_mov1 and short_mov2>long_mov2 then
			iup.Message('����� ������!','̨����� �����')	
			toLog (log, "Dead Cross detected")
			SIGNAL="DEAD CROSS" --������� � ������� �����.
		else
			SIGNAL="NO SIGNAL" --������� � ������� �����.
		end
		-- ��������� �������� ��� ����� �������
		t:SetValue(line,"TREND DETECTOR",TREND_DETECTOR)
		t:SetValue(line,"SIGNAL",SIGNAL)

		sleep(1000)
	end
	toLog(log,"Main ended")
	iup.Close()
end