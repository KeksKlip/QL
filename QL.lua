--Version='0.5.1.0'
-- �� ���� �������� ����� ������ ��� - forum.qlua.org
package.cpath=".\\?.dll;.\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\loadall.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\loadall.dll;C:\\Program Files\\Lua\\5.1\\?.dll;C:\\Program Files\\Lua\\5.1\\?51.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files\\Lua\\5.1\\loadall.dll;C:\\Program Files\\Lua\\5.1\\clibs\\loadall.dll"..package.cpath
package.path=package.path..";.\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.luac;C:\\Program Files\\Lua\\5.1\\lua\\?.lua;C:\\Program Files\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\?.lua;C:\\Program Files\\Lua\\5.1\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\lua\\?.luac;"
require"bit"
require"socket"
FUT_OPT_CLASSES="FUTUX,OPTUX,SPBOPT,SPBFUT"
NOTRANDOMIZED=true
--[[
Trading Module
]]--
function sendLimit(class,security,direction,price,volume,account,client_code,comment,execution_condition,expire_date,market_maker)
	if string.find(FUT_OPT_CLASSES,class)~=nil then
		return sendLimitFO(class,security,direction,price,volume,account,comment,execution_condition,expire_date,market_maker)
	else
		return sendLimitSpot(class,security,direction,price,volume,account,client_code,comment,market_maker)
	end
end
function sendLimitFO(class,security,direction,price,volume,account,comment,execution_condition,expire_date,market_maker)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ���� (��� ����-������)
	-- execution_condition ����� ��������� 2 �������� - FILL_OR_KILL(���������� ��� ���������),KILL_BALANCE(����� �������). ���� �������� �� ������ �� �� ��������� ��������� � �������. ��������! �������� ������ �� ������� �����!
	-- expire_date - ����������� ��� �������� ������ �� ������� �����
	-- market_maker - ������� ������ ������-�������. true\false
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil) then
		return nil,"QL.sendLimitFO(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="���� ������",
		["CLASSCODE"]=class,
		["���"]="��������������",
		["������� ����������"]="��������� � �������",
		["�����"]=class,
		["����������"]=security,
		["����������"]=string.format("%d",tostring(volume)),
		["����"]=toPrice(security,price),
		["�������� ����"]=tostring(account)
	}
	if direction=='B' then transaction['�/�']='�������' else transaction['�/�']='�������' end
	if comment~=nil then
		transaction['�����������']=string.sub(tostring(comment),0,20)
	else
		transaction['�����������']='QL'
	end
	if expire_date~=nil then
		transaction['���������� ������']='��'
		transaction['���� ����������']=tostring(expire_date)
	end
	if execution_condition~=nil then 
		if string.upper(execution_condition)=='FILL_OR_KILL' then
			transaction["������� ����������"]='���������� ��� ���������'
		elseif string.upper(execution_condition)=='KILL_BALANCE' then
			transaction["������� ����������"]='����� �������'
		end
	end
	if market_maker~=nil and market_maker then
		transaction['MARKET_MAKER_ORDER']='YES'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendLimitFO():"..res
	else
		return trans_id, "QL.sendLimitFO(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendLimitSpot(class,security,direction,price,volume,account,client_code,comment,market_maker)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ����
	-- market_maker - ������� ������ ������-�������. true\false
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil) then
		return nil,"QL.sendLimitSpot(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string.format("%d",tostring(volume)),
		["PRICE"]=toPrice(security,price),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if comment~=nil then
		transaction.client_code=string.sub(transaction.client_code..'//'..tostring(comment),0,20)
	else
		transaction.client_code=string.sub(transaction.client_code..'//QL',0,20)
	end
	if market_maker~=nil and market_maker then
		transaction['MARKET_MAKER_ORDER']='YES'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendLimitSpot():"..res
	else
		return trans_id, "QL.sendLimitSpot(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendMarket(class,security,direction,volume,account,client_code,comment)
	-- �������� �������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil  or volume==nil or account==nil) then
		return nil,"QL.sendMarket(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["TYPE"]="M",
		["QUANTITY"]=string.format("%d",tostring(volume)),
		["ACCOUNT"]=account
	}
	if client_code==nil then
		transaction.client_code=account
	else
		transaction.client_code=client_code
	end
	if string.find(FUT_OPT_CLASSES,class)~=nil then
		if direction=="B" then
			transaction.price=toPrice(security,getParamEx(class,security,"PRICEMAX").param_value)
		else
			transaction.price=toPrice(security,getParamEx(class,security,"PRICEMIN").param_value)
		end
	else
		transaction.price="0"
	end
	if comment~=nil then
		transaction.comment=tostring(comment)
		if string.find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string.sub('QL'..comment,0,20) else transaction.client_code=string.sub(transaction.client_code..'/QL'..comment,0,20) end
	else
		transaction.comment=tostring(comment)
		if string.find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string.sub('QL',0,20) else transaction.client_code=string.sub(transaction.client_code..'/QL',0,20) end
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendMarket():"..res
	else
		return trans_id, "QL.sendMarket(): Market order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendStop(class,security,direction,stopprice,dealprice,volume,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or stopprice==nil or volume==nil or account==nil or dealprice==nil) then
		return nil,"QL.sendStop(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string.format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,stopprice),
		["PRICE"]=toPrice(security,dealprice),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=exp_date
	end
	if comment~=nil then
		transaction.comment=string.sub(tostring(comment),0,20)
	else
		transaction.comment='QL'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendStop():"..res
	else
		return trans_id, "QL.sendStop(): Stop-order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." StopPrice="..stopprice.." DealPrice="..dealprice.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendTPSL(class,security,direction,price,volume,tpoffset,sloffset,maxoffset,defspread,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or stopprice==nil or volume==nil or account==nil or dealprice==nil) then
		return nil,"QL.sendStop(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=string.format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,stopprice),
		["PRICE"]=toPrice(security,dealprice),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=exp_date
	end
	if comment~=nil then
		transaction.comment=tostring(comment)
		if string.find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string.sub('//QL'..comment,0,20) else transaction.client_code=string.sub(transaction.client_code..'//QL'..comment,0,20) end
	else
		transaction.comment=tostring(comment)
		if string.find(FUT_OPT_CLASSES,class)~=nil then	transaction.client_code=string.sub('//QL',0,20) else transaction.client_code=string.sub(transaction.client_code..'//QL',0,20) end
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendStop():"..res
	else
		return trans_id, "QL.sendStop(): Stop-order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." StopPrice="..stopprice.." DealPrice="..dealprice.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function sendTake(class,security,direction,price,volume,offset,offsetunits,deffspread,deffspreadunits,account,exp_date,client_code,comment)
	-- �������� ������� ����-������
	-- ��� ��������� ����� ���� �������,���������� � ������� ����� ������ ���� �� ���
	-- ���� ��� ������� ��� - ������������ ����
	-- ���� ����� ����� �� ������� - �� ������ "�� ������"
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil or offset==nil or offsetunits==nil or deffspread==nil or deffspreadunits==nil) then
		return nil,"QL.sendTake(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_STOP_ORDER",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["STOP_ORDER_KIND"]='TAKE_PROFIT_STOP',
		["OPERATION"]=direction,
		["QUANTITY"]=string.format("%d",tostring(volume)),
		["STOPPRICE"]=toPrice(security,price),
		["OFFSET_UNITS"]=offsetunits,
		["SPREAD_UNITS"]=deffspreadunits,
		["OFFSET"]=tonumber(offset),
		["SPREAD"]=tonumber(deffspread),
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
	end
	if exp_date==nil then
		transaction["EXPIRY_DATE"]="GTC"
	else
		transaction['EXPIRY_DATE']=exp_date
	end
	if comment~=nil then
		transaction.comment=string.sub(tostring(comment),0,20)
	else
		transaction.comment='QL'
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendTake():"..res
	else
		return trans_id, "QL.sendTake(): Take-profit sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Offset="..offset..' OffsetUnits='..offsetunits..' Spread='..deffspread..' SpreadUnits='..deffspreadunits.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
	end
end
function moveOrder(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������
	-- ����������� ����� ���������� mode,fo_number,fo_p
	-- � ����������� �� ������ ������ ������ ����� ������� ������� ����������� ���� ��� ���� ���� �������� �����
	if (fo_number==nil or fo_p==nil or mode==nil) then
		return nil,"QL.moveOrder(): Can`t move order. Nil parameters."
	end
	local forder=getRowFromTable("orders","ordernum",fo_number)
	if forder==nil then
		return nil,"QL.moveOrder(): Can`t find ordernumber="..fo_number.." in orders table!"
	end
	if string.find(FUT_OPT_CLASSES,forder.class_code)~=nil then
		return moveOrderFO(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	else
		return moveOrderSpot(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	end
end
function moveOrderSpot(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������ ��� ����� ����
	-- ����������� ����� ���������� mode,fo_number,fo_p
	-- ���������� 2 ���������� ������+���������� ��� ������ �� ��������� ������
	-- ���������� 2 ��������� :
	-- 1. Nil - ���� ������� ��� ����� ���������� (2-� ���� 2 ������)
	-- 2. �������������� ���������
	if (fo_number==nil or fo_p==nil) then
		return nil,"QL.moveOrderSpot(): Can`t move order. Nil parameters."
	end
	local forder=getRowFromTable("orders","ordernum",fo_number)
	if forder==nil then
		return nil,"QL.moveOrderSpot(): Can`t find ordernumber="..fo_number.." in orders table!"
	end
	if (orderflags2table(forder.flags).cancelled or (orderflags2table(forder.flags).done and forder.balance==0)) then
		return nil,"QL.moveOrderSpot(): Can`t move cancelled or done order!"
	end
	if mode==0 then
		--���� MODE=0, �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������. 
		--� �������� ������� ������������ ��� ����� ������, ��� ���� ���������� ������ ���� ������, ���������� �������� �������;
		if so_number~=nil and so_p~=nil then
			_,ms=killOrder(fo_number,forder.seccode,forder.class_code)
			--toLog("ko.txt",ms)
			trid,ms1=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,fo_p,tostring(forder.balance),forder.account,forder.client_code,forder.comment)
			local sorder=getRowFromTable("orders","ordernum",so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find ordernumber="..so_number.." in orders table!"
			end
			_,ms=killOrder(so_number,sorder.seccode,sorder.class_code)
			--toLog("ko.txt",ms)
			trid2,ms2=sendLimit(sorder.class_code,sorder.seccode,orderflags2table(sorder.flags).operation,so_p,tostring(sorder.balance),sorder.account,sorder.client_code,sorder.comment)
			if trid~=nil and trid2~=nil then
				return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
			else
				return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
			end
		else
			_,ms=killOrder(fo_number,forder.seccode,forder.class_code)
			--toLog("ko.txt",ms)
			local trid,ms=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,fo_p,tostring(forder.balance),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	elseif mode==1 then
		--���� MODE=1, �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������. 
		--� �������� ������� ������������ ��� ����� ������, ��� ���� ��������� ��� ���� ������, ��� � ����������;
		if so_number~=nil and so_p~=nil and so_q~=nil then
			_,_=killOrder(fo_number,forder.seccode,forder.class_code)
			local trid,ms1=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,toPrice(forder.seccode,fo_p),tostring(fo_q),forder.account,forder.client_code,forder.comment)
			local sorder=getRowFromTable("orders","ordernum",so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find ordernumber="..so_number.." in orders table!"
			end
			_,_=killOrder(so_number,sorder.seccode,sorder.class_code)
			local trid2,ms2=sendLimit(sorder.class_code,sorder.seccode,orderflags2table(sorder.flags).operation,toPrice(sorder.seccode,so_p),tostring(so_q),sorder.account,sorder.client_code,sorder.comment)
			if trid~=nil and trid2~=nil then
				return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
			else
				return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
			end
		else
			_,_=killOrder(fo_number,forder.seccode,forder.class_code)
			local trid,ms=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,toPrice(forder.seccode,fo_p),tostring(fo_q),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	elseif mode==2 then
		--���� MODE=2,  �� ������ � ��������, ���������� ����� ������ FIRST_ORDER_NUMBER � SECOND_ORDER_NUMBER, ���������. 
		--���� ���������� ����� � ������ �� ������ ������ ��������� �� ����������, ���������� ����� FIRST_ORDER_NEW_QUANTITY � SECOND_ORDER_NEW_QUANTITY, �� � �������� ������� ������������ ��� ����� ������ � ���������������� �����������.
		if so_number~=nil and so_p~=nil and so_q~=nil then
			local sorder=getRowFromTable("orders","ordernum",so_number)
			if sorder==nil then
				return nil,"QL.moveOrderSpot(): Can`t find ordernumber="..so_number.." in orders table!"
			end
			_,_=killOrder(fo_number,forder.seccode,forder.class_code)
			_,_=killOrder(so_number,sorder.seccode,sorder.class_code)
			if forder.balance==fo_q and sorder.balance==so_q then
				local trid,ms1=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,toPrice(forder.seccode,fo_p),tostring(fo_q),forder.account,forder.client_code,forder.comment)
				local trid2,ms2=sendLimit(sorder.class_code,sorder.seccode,orderflags2table(sorder.flags).operation,toPrice(sorder.seccode,so_p),tostring(so_q),sorder.account,sorder.client_code,sorder.comment)
				if trid~=nil and trid2~=nil then
					return trid2,"QL.moveOrderSpot(): Orders moved. Trans_id1="..trid.." Trans_id2="..trid2
				else
					return nil,"QL.moveOrderSpot(): One or more orders not moved! Msg1="..ms1.." Msg2="..ms2
				end
			else
				return nil,"QL.moveOrderSpot(): Mode=2. Orders balance~=new_quantity"
			end
		else
			_,_=killOrder(fo_number,forder.seccode,forder.class_code)
			local trid,ms=sendLimit(forder.class_code,forder.seccode,orderflags2table(forder.flags).operation,toPrice(forder.seccode,fo_p),tostring(fo_q),forder.account,forder.client_code,forder.comment)
			if trid~=nil then
				return trid,"QL.moveOrderSpot(): Order moved. Trans_Id="..trid
			else
				return nil,"QL.moveOrderSpot(): Order not moved! Msg="..ms
			end
		end
	else
		return nil,"QL.moveOrder(): Mode out of range! Mode can be from {0,1,2}"
	end
end
function moveOrderFO(mode,fo_number,fo_p,fo_q,so_number,so_p,so_q)
	-- ����������� ������ ��� �������� �����
	-- �������� "����������" ���������� �����
	if (fo_number==nil or fo_p==nil or mode==nil) then
		return nil,"QL.moveOrderFO(): Can`t move order. Nil parameters."
	end
	local transaction={}
	if mode==0 then
		if so_number~=nil and so_p~=nil then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]="0"
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]="0"
		transaction["MODE"]=tostring(mode)
	elseif mode==1 then
		if fo_q==nil or fo_q==0 then
			return nil,"QL.moveOrder(): Mode=1. First Order Quantity can`t be nil or zero!"
		end
		if so_number~=nil and so_p~=nil and so_q>0 then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]=tostring(so_q)
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]=tostring(fo_q)
		transaction["MODE"]=tostring(mode)
	elseif mode==2 then
		if fo_q==nil or fo_q==0 then
			return nil,"QL.moveOrder(): Mode=2. First Order Quantity can`t be nil or zero!"
		end
		if so_number~=nil and so_p~=nil and so_q>0 then
			transaction["SECOND_ORDER_NUMBER"]=tostring(so_number)
			transaction["SECOND_ORDER_NEW_PRICE"]=so_p
			transaction["SECOND_ORDER_NEW_QUANTITY"]=tostring(so_q)
		end
		transaction["FIRST_ORDER_NUMBER"]=tostring(fo_number)
		transaction["FIRST_ORDER_NEW_PRICE"]=fo_p
		transaction["FIRST_ORDER_NEW_QUANTITY"]=tostring(fo_q)
		transaction["MODE"]=tostring(mode)
	else
		return nil,"QL.moveOrder(): Mode out of range! mode can be from {0,1,2}"
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local order=getRowFromTable("orders","ordernum",fo_number)
	if order==nil then
		return nil,"QL.moveOrderFO(): Can`t find ordernumber="..fo_number.." in orders table!"
	end
	transaction["TRANS_ID"]=tostring(trans_id)
	transaction["CLASSCODE"]=order.class_code
	transaction["SECCODE"]=order.seccode
	transaction["ACTION"]="MOVE_ORDERS"

	--toLog("move.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.moveOrderFO():"..res
	else
		return trans_id, "QL.moveOrderFO(): Move order sended sucesfully. Mode="..mode.." FONumber="..fo_number.." FOPrice="..fo_p
	end
end
function sendRPS(class,security,direction,price,volume,account,client_code,partner)
    -- ������� �������� ������ �� ����������� ������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil or partner==nil) then
		return nil,"QL.sendRPS(): Can`t send order. Nil parameters."
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_NEG_DEAL",
		["CLASSCODE"]=class,
		["SECCODE"]=security,
		["OPERATION"]=direction,
		["QUANTITY"]=volume,
		["PRICE"]=price,
		["ACCOUNT"]=account,
		["PARTNER"]=partner,
		["SETTLE_CODE"]="B0"
	}
	if client_code==nil then
		transaction.client_code=account
	else
		transaction.client_code=client_code
	end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendRPS():"..res
	else
		return trans_id, "QL.sendRPS(): RPS order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Partner="..partner.." Trans_id="..trans_id
	end
end
function sendReportOnRPS(class,operation,key)
    -- �������� ������ �� ������ ��� ����������
	if(class==nil or operation==nil or key==nil) then
		return nil,"QL.sendRPS(): Can`t send order. Nil parameters."
	end
	--local trans_id=tostring(math.ceil(os.clock()))..tostring(math.random(os.clock()))
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="NEW_REPORT",
		["CLASSCODE"]=class,
		["NEG_TRADE_OPERATION"]=operation,
		["NEG_TRADE_NUMBER"]=key
	}
	local res=sendTransaction(transaction)
	if res~="" then
		return nil, "QL.sendReportOnRPS():"..res
	else
		return trans_id, "QL.sendReportOnRPS(): ReportOnRPS order sended sucesfully. Class="..class.." Oper="..operation.." Key="..key.." Trans_id="..trans_id
	end
end
function killOrder(orderkey,security,class)
	-- ������� ������ �������������� ������ �� ������
	-- ��������� ������� 1 �������
	-- �����! ������ ������� �� ����������� ������ ������
	-- ���������� ��������� ������� � ������ ������ ���������� �������� ���� ���� ������ � ����������� � ����������
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"QL.killOrder(): Can`t kill order. OrderKey nil or zero"
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="KILL_ORDER",
		["ORDER_KEY"]=tostring(orderkey)
	}
	if (security==nil and class==nil) or (class~=nil and security==nil) then
		local order=getRowFromTable("orders","ordernum",orderkey)
		if order==nil then return nil,"QL.killOrder(): Can`t kill order. No such order in Orders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order.seccode
	elseif	security~=nil then
		transaction.seccode=security
		transaction.classcode=getSecurityInfo("",security).class_code
	else
		transaction.seccode=security
		transaction.classcode=class 
	end
	--toLog("ko.txt",transaction)
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"QL.killOrder(): "..res
	else
		return trans_id,"QL.killOrder(): Limit order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..trans_id
	end
end
function killStopOrder(orderkey,security,class)
	-- ������� ������ ����-������ �� ������
	-- ��������� ������� 1 �������
	-- �����! ������ ������� �� ����������� ������ ������
	-- ���������� ��������� ������� � ������ ������ ���������� �������� ���� ���� ������ � ����������� � ����������
	if orderkey==nil or tonumber(orderkey)==0 then
		return nil,"QL.killStopOrder(): Can`t kill order. OrderKey nil or zero"
	end
	if NOTRANDOMIZED then
		math.randomseed(socket.gettime())
		NOTRANDOMIZED=false
	end
	local trans_id=math.random(2000000000)
	local transaction={
		["TRANS_ID"]=tostring(trans_id),
		["ACTION"]="KILL_STOP_ORDER",
		["STOP_ORDER_KEY"]=tostring(orderkey)
	}
	if (security==nil and class==nil) or (class~=nil and security==nil) then
		local order=getRowFromTable("stop_orders","ordernum",orderkey)
		if order==nil then return nil,"QL.killStopOrder(): Can`t kill order. No such order in StopOrders table." end
		transaction.classcode=order.class_code
		transaction.seccode=order.seccode
	elseif	security~=nil then
		transaction.seccode=security
		transaction.classcode=getSecurityInfo("",security).class_code
	else
		transaction.seccode=security
		transaction.classcode=class 
	end
	--toLog("ko.txt",transaction)
	if string.find(FUT_OPT_CLASSES,transaction.classcode)~=nil then transaction['BASE_CONTRACT']=getParamEx(transaction.classcode,transaction.seccode,'optionbase').param_image end
	local res=sendTransaction(transaction)
	if res~="" then
		return nil,"QL.killStopOrder(): "..res
	else
		return trans_id,"QL.killStopOrder(): Stop-order kill sended. Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..trans_id
	end
end
function killAllOrders(table_mask)
	-- ������ ������� �������� ���������� �� ������ �������� ������ ��������������� ������� ���������� ��� �������� �������� table_mask
	-- ������ ���� ��������� ����������  : ACCOUNT,CLASSCODE,SECCODE,OPERATION,CLIENT_CODE,COMMENT
	-- ���� ������� ������� � ���������� nil - �������� ��� �������� ������
	local i,key,val,result_num=0,0,0,0
	local tokill=true
	local row={}
	local result_str=""
	for i=0,getNumberOf("orders"),1 do
		row=getItem("orders",i)
		tokill=false
		--toLog(log,"Row "..i.." onum="..row.ordernum)
		if orderflags2table(row.flags).active then
			tokill=true
			--toLog(log,"acitve")
			if table_mask~=nil then
				for key,val in pairs(table_mask) do
					--toLog(log,"check key="..key.." val="..val)
					--toLog(log,"strlowe="..string.lower(key).." row="..row[string.lower(key)].." tbl="..val)
					if row[string.lower(key)]~=val then
						tokill=false
						--toLog(log,"false cond. t="..table_mask.key.." row="..row[string.lower(key)])
						break
					end
				end
			end
		end
		if tokill then
			--toLog(log,"kill onum"..row.ordernum)
			res,ms=killOrder(tostring(row.ordernum),row.seccode,row.class_code)
			result_num=result_num+1
			--toLog(log,ms)
			if res then
				result_str=result_str..row.ordernum..","
			else
				result_str=result_str.."!"..row.ordernum..","
			end
		end
	end
	return true,"QL.killAllOrders(): Sended "..result_num.." transactions. Ordernums:"..result_str
end
function killAllStopOrders(table_mask)
	-- ������ ������� �������� ���������� �� ������ �������� ����-������ ��������������� ������� ���������� ��� �������� �������� table_mask
	-- ������ ���� ��������� ����������  : ACCOUNT,CLASSCODE,SECCODE,OPERATION,CLIENT_CODE,COMMENT
	-- ���� ������� ������� � ���������� nil - �������� ��� �������� ������
	local i,key,val,result_num=0,0,0,0
	local tokill=true
	local row={}
	local result_str=""
	for i=0,getNumberOf("stop_orders"),1 do
		row=getItem("stop_orders",i)
		tokill=false
		--toLog(log,"Row "..i.." onum="..row.ordernum)
		if stoporderflags2table(row.flags).active then
			tokill=true
			--toLog(log,"acitve")
			if table_mask~=nil then
				for key,val in pairs(table_mask) do
					--toLog(log,"check key="..key.." val="..val)
					--toLog(log,"strlowe="..string.lower(key).." row="..row[string.lower(key)].." tbl="..val)
					if row[string.lower(key)]~=val then
						tokill=false
						--toLog(log,"false cond. t="..table_mask.key.." row="..row[string.lower(key)])
						break
					end
				end
			end
		end
		if tokill then
			--toLog(log,"kill onum"..row.ordernum)
			res,ms=killStopOrder(tostring(row.ordernum),row.seccode,row.class_code)
			result_num=result_num+1
			--toLog(log,ms)
			if res then
				result_str=result_str..row.ordernum..","
			else
				result_str=result_str.."!"..row.ordernum..","
			end
		end
	end
	return true,"QL.killAllStopOrders(): Sended "..result_num.." transactions. Ordernums:"..result_str
end
function getPosition(security,account)
    --���������� ������ ������� �� �����������
	local class_code=getSecurityInfo("",security).class_code
    if string.find(FUT_OPT_CLASSES,class_code)~=nil then
	--futures
		for i=0,getNumberOf("futures_client_holding") do
			local row=getItem("futures_client_holding",i)
			if row~=nil and row.seccode==security and row.trdaccid==account then
				if row.totalnet==nil then
					return 0
				else
					return row.totalnet
				end
			end
		end
	else
	-- spot
		toLog(log,'posnum='..getNumberOf("depo_limits"))
		for i=0,getNumberOf("depo_limits") do
			local row=getItem("depo_limits",i)
			toLog(log,row)
			if row~=nil and row.seccode==security and row.trdaccid==account then
				if row.currentbal==nil then
					return 0
				else
					return row.currentpos
				end
			end
		end
	end
    return 0
end
--[[
Quik Table class QTable
]]
QTable ={}
QTable.__index = QTable
function QTable:new()
     -- ������� � ���������������� ��������� ������� QTable
	 local t_id = AllocTable()
     if t_id ~= nil then
         q_table = {}
         setmetatable(q_table, QTable)
         q_table.t_id=t_id
         q_table.caption = ""
         q_table.created = false
		 q_table.curr_col=0
		 q_table.curr_line=0
         --������� � ��������� ���������� ��������
         q_table.columns={}
         return q_table
     else
         return nil
     end
end                
function QTable:Show()
     -- ���������� � ��������� ���� � ��������� ��������
     CreateWindow(self.t_id)
     if self.caption ~="" then
         -- ������ ��������� ��� ����
         SetWindowCaption(self.t_id, self.caption)
     end
     self.created = true
end
function QTable:IsClosed()
     --���� ���� � �������� �������, ���������� �true�
	 return IsWindowClosed(self.t_id)
end
function QTable:delete()
     -- ������� �������
     return DestroyTable(self.t_id)
end
function QTable:GetCaption()
    -- ���������� ������, ���������� ��������� �������
	 if IsWindowClosed(self.t_id) then
         return self.caption
     else
         return GetWindowCaption(self.t_id)
     end
end
function QTable:SetCaption(s)
     -- ������ ��������� �������
	 self.caption = s
	 if not IsWindowClosed(self.t_id) then
         res = SetWindowCaption(self.t_id, tostring(s))
     end
end
function QTable:AddColumn(name, c_type, width, ff )
    -- �������� �������� ������� name ���� C_type � �������
	-- ff � ������� �������������� ������ ��� �����������
	local col_desc={}
	self.curr_col=self.curr_col+1
    col_desc.c_type = c_type
	col_desc.format_function = ff
    col_desc.id = self.curr_col
	self.columns[name] = col_desc
    -- name ������������ � �������� ��������� �������
    return AddColumn(self.t_id, self.curr_col, name, true, c_type, width)
end 
function QTable:Clear()
     -- �������� �������
     return Clear(self.t_id)
end 
function QTable:SetValue(row, col_name, data)
     -- ���������� �������� � ������
	 local col_ind = self.columns[col_name].id or nil
     if col_ind == nil then
		return false
     end
     -- ���� ��� ������� ������ ������� ��������������, �� ��� ������������
     local ff = self.columns[col_name].format_function
     if type(ff) == "function" then
         -- � �������� ���������� ������������� ������������
         -- ��������� ���������� ������� ��������������
         if self.columns[col_name].c_type==QTABLE_STRING_TYPE or self.columns[col_name].c_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, ff(data))
		else
			return SetCell(self.t_id, row, col_ind, ff(data),data)
		end
     else
		if self.columns[col_name].c_type==QTABLE_STRING_TYPE or self.columns[col_name].c_type==QTABLE_CACHED_STRING_TYPE then
			return SetCell(self.t_id, row, col_ind, tostring(data))
		else
			return SetCell(self.t_id, row, col_ind, tostring(data),data)
		end
     end
end 
function QTable:AddLine()
    -- ��������� � ����� ������� ������ ������� � ���������� �� �����
	self.curr_line=self.curr_line+1
    return InsertRow(self.t_id, -1)
end
function QTable:DeleteLine(key)
	self.curr_line=self.curr_line-1
	if key==nil then return false end
	return DeleteRow(self.t_id,key)
end
function QTable:GetSize()
     -- ���������� ������ �������, ���������� ����� � ��������
     return GetTableSize(self.t_id)
end
function QTable:GetValue(row, name)
-- �������� ������ �� ������ �� ������ ������ � ����� �������
	 local t={}
	 local col_ind = self.columns[name].id
     if col_ind == nil then
		return nil
     end
	 t = GetCell(self.t_id, row, col_ind)
     return t
end
function QTable:SetPosition(x, y, dx, dy)
     -- ������ ���������� ����
	 -- x,y - ���������� ������ �������� ����; dx,dy - ������ � ������
	 return SetWindowPos(self.t_id, x, y, dx, dy)
end
function QTable:GetPosition()
     -- ������� ���������� ���������� ����
	 top, left, bottom, right = GetWindowRect(self.t_id)
     return top, left, right-left, bottom-top
end
--[[
Graphics functions
]]
function isChartExist(chart_name)
	-- ���������� true, ���� ������ � ��������������� chart_name ��������� ����� false
	if chart_name==nil or chart_name=='' then return false end
	local n=getNumCandles(chart_name)
	if n==nil or n<1 then toLog(log,'isChartExist n='..n) return false end
	return true
end
function getCandle(chart_name,bar,line)
	-- ���������� ����� �� ������� bar �� ��������� ������������ ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- �������� bar �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	if not isChartExist(chart_name) then return nil,'Chart doesn`t exist' end
	local n=getNumCandles(chart_name)
	local lline=0
	local lbar=n-1
	if line~=nil then lline=tonumber(line) end
	if bar~=nil then lbar=tonumber(bar) end
	if lbar>n then return nil,'Spacified bar='..bar..' doesn`t exist' end
	local t,n,p=getCandlesByIndex(chart_name,lline,lbar,1)
	if t~=nil then return t[0] else return nil,'Error gettind Candles from '..chart_name end
end
function getPrevCandle(chart_name,line)
	-- ���������� ����-��������� ����� ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	if not isChartExist(chart_name) then return nil,'Chart doesn`t exist' end
	local n=getNumCandles(chart_name)
	return getCandle(chart_name,n-2,line)
end
function getLastCandle(chart_name,line)
	-- ���������� ��������� ����� ��� ������� � ��������������� chart_name
	-- �������� line �� ������������ (�� ��������� 0)
	-- ���������� ������� ��� � ������������� ������ ��� nil � ��������� � ������������
	return getCandle(chart_name,nil,line)
end
--[[
Commmon Trading Signals
]]
function crossOver(bar,chart_name1,val2,parameter,line1,line2)
	-- ���������� true ���� ������ � ��������������� chart_name1 ������� ����� ����� ������ (��� ��������) val2 � ���� bar.
	-- ��������� parameter,line1,line2 �������������. �� ��������� ����� close,0,0 ��������������
	if bar==nil or chart_name1==nil or val2==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name1,bar,line1),getCandle(chart_name1,bar-1,line1)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name1 end
	local par=parameter or 'close'
	toLog(log,'par='..par)
	if type(val2)=='string' then
		local candle2l,candle2p=getCandle(val2,bar,line2),getCandle(val2,bar-1,line2)		
		if candle2l==nil or candle2p==nil then return false,'Eror on getting candles for '..val2 end
		toLog(log,candle1l)
		toLog(log,candle1p)
		if candle1l[par]>candle2l[par] and candle1p[par]<=candle2p[par] then return true else return false end
	elseif type(val2)=='number' then
		if candle1l[par]>val2 and candle1p[par]<=val2 then return true else return false end
	else
		return false,'Unsupported type for 3rd parameter'
	end
end
function crossUnder(bar,chart_name1,val2,parameter,line1,line2)
	-- ���������� true ���� ������ � ��������������� chart_name1 ������� ������ ����  ������ (��� ��������) val2 � ���� bar.
	-- ��������� parameter,line1,line2 �������������. �� ��������� ����� close,0,0 ��������������
	if bar==nil or chart_name1==nil or val2==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name1,bar,line1),getCandle(chart_name1,bar-1,line1)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name1 end
	local par=parameter or 'close'
	if type(val2)=='string' then
		local candle2l,candle2p=getCandle(val2,bar,line2),getCandle(val2,bar-1,line2)		
		if candle2l==nil or candle2p==nil then return false,'Eror on getting candles for '..val2 end
		if candle1l[par]<candle2l[par] and candle1p[par]>=candle2p[par] then return true else return false end
	elseif type(val2)=='number' then
		if candle1l[par]<val2 and candle1p[par]>=val2 then return true else return false end
	else
		return false,'Unsupported type for 3rd parameter'
	end
end
function turnDown(bar,chart_name,parameter,line)
	-- ���������� true ���� ������ � ��������������� chart_name "����������� ����". �.�. �������� ������� � ���� bar ������ �������� � ���� bar-1.
	-- ��������� parameter,line �������������. �� ��������� ����� close,0 ��������������
	if bar==nil or chart_name==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name,bar,line),getCandle(chart_name,bar-1,line)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name end
	local par=parameter or close
	if candle1l[par]<candle1p[par] then return true else return false end
end
function turnUp(bar,chart_name,parameter,line)
	-- ���������� true ���� ������ � ��������������� chart_name "����������� �����". �.�. �������� ������� � ���� bar ������ �������� � ���� bar-1.
	-- ��������� parameter,line �������������. �� ��������� ����� close,0 ��������������
	if bar==nil or chart_name==nil then return false,'Bad parameters' end
	local candle1l,candle1p=getCandle(chart_name,bar,line),getCandle(chart_name,bar-1,line)
	if candle1l==nil or candle1p==nil then return false,'Eror on getting candles for '..chart_name end
	local par=parameter or close
	if candle1l[par]>candle1p[par] then return true else return false end
end
--[[
Support Functions
]]--
function getParam(security,param_name)
	--�������� ����������� ������� getParamEx. ������������� ������� ��� ������. ���������� �������� � ���������� �������. � ������ ������ ���������� ����������� ������ ����������
	if security==nil or security=='' or param_name==nil or param_name=='' then return nil,'Bad arguments' end
	local t=getParamEx(getSecurityInfo('',security).class_code,security,param_name)
	if t.result~='1' then return nil,param_name..' for '..security..' nor found' end
	if t.param_type=='3' then
		return t.param_image
	else
		return tonumber(t.param_value)
	end
end
function toLog(file_path,value)
	-- ������ � ��� ��������� value
	-- value ����� ���� ������, ������� ��� �������� 
	-- file_path  -  ���� � �����
	-- ���� ����������� �� �������� � ����������� ����� ������ ������
	if file_path~=nil and value~=nil then
		lf=io.open(file_path,"a+")
		if lf~=nil then
			if type(value)=="string" or type(value)=="number" then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..value.."\n")
			elseif type(value)=='boolean' then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..tostring(value).."\n")
			elseif type(value)=="table" then
				if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
				lf:write(getHRDateTime().." "..table2string(value).."\n")
			end
			if io.type(lf)~="file" then	lf=io.open(file_path,"a+") end
			lf:flush()
			if io.type(lf)=="file" then	lf:close() end
		end
	end
end
function table2string(table)
	local k,v,str=0,0,""
	for k,v in pairs(table) do
		if type(v)=="string" or type(v)=="number" then
			str=str..k.."="..v..';'
		elseif type(v)=="table"then
			str=str..k.."={"..table2string(v).."};"
		elseif type(v)=="function" or type(v)=='boolean' then
			str=str..k..'='..tostring(v)..';'
		end
	end
	return str
end
function getHRTime()
	-- ���������� ����� � ������������� � ���� ������
	local now=socket.gettime()
	return string.format("%s,%3d",os.date("%X",now),select(2,math.modf(now))*1000)
end
function getHRDateTime()
	-- ���������� ������ � ������� ����� � ����� � �������������
	local now=socket.gettime()
	return string.format("%s,%3d",os.date("%c",now),select(2,math.modf(now))*1000)
end
function toPrice(security,value)
	-- �������������� �������� value � ���� ����������� ����������� ������� (�������� ������ ����� ����� �����������)
	-- ���������� ������
	if (security==nil or value==nil) then return nil end
	local scale=getParamEx(getSecurityInfo("",security).class_code,security,"SEC_SCALE").param_value
	return string.format("%."..string.format("%d",scale).."f",tonumber(value))
end
function getPosFromTable(table,value)
	-- ���������� ���� �������� value �� ������� table, ����� -1
	if (table==nil or value==nil) then
		return -1
	else
		local k,v
		for k,v in pairs(table) do
			if v==value then
				return k
			end
		end
		return -1
	end
end
function orderflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ������ �� ������
	--[[ �������� : 
	active, cancelled, done,operation("B" for Buy, "S" for Sell),limit(true - limit order, false - market order),
	mte(�������� ���������� ������ ����������� ��������),fill_or_kill(��������� ������ ���������� ��� �����),
	mmorder(������ ������-�������. ��� �������� ������ ������� ���������� �����������),received(��� �������� ������ ������� �������� �� �����������),
	cancell_rest(����� �������),iceberg
	]]
	local t={}
	local band=bit.band
	local tobit=bit.tobit
	if band(tobit(flags),0x1)~=0 then t.active=true	else t.active = false end
	if band(tobit(flags),0x2)~=0 then t.cancelled=true 
	else	
		if not t.active then t.done=true else t.done=false end
		t.cancelled=false
	end
	if band(tobit(flags), 0x4)~=0 then t.operation="S" else t.operation = "B" end
	if band(tobit(flags), 0x8)~=0 then t.limit=true else t.limit = false end
	if band(tobit(flags),0x10)~=0 then t.mte=true	else t.mte=false end
	if band(tobit(flags),0x20)~=0 then t.fill_or_kill=true else t.fill_or_kill=false end
	if band(tobit(flags),0x40)~=0 then t.mmorder=true else t.mmorder=false end
	if band(tobit(flags),0x80)~=0 then t.received=true else t.received=false end
	if band(tobit(flags),0x100)~=0 then t.cancell_rest=true else t.cancell_rest=false end
	if band(tobit(flags),0x200)~=0 then t.iceberg=true else t.iceberg=false end
	if t.cancelled and t.done then message("Erorr in orderflags2table order cancelled and done!",2)	end
	return t
end
function tradeflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ������ �� ������
	--[[ �������� :operation("B" for Buy, "S" for Sell, "" for not defined(index for example))
	]]
	local t={}
	local band=bit.band
	local tobit=bit.tobit
	if band(tobit(flags), 0x1)~=0 then t.operation="S" return t end
	if band(tobit(flags), 0x2)~=0 then t.operation="B" return t end
	t.operation=""
	return t
end
function stoporderflags2table(flags)
	-- ������� ���������� ������� � ������ ��������� ����-������ �� ������
	--[[ �������� : 
	active, cancelled, done,operation("B" for Buy, "S" for Sell),limit(true - limit order, false - market order),
	mte(�������� ���������� ������ ����������� ��������),wait_activation(����-������ ������� ���������),
	another_server(����-������ � ������� �������),tplopf(��������������� � ������ ����-������ ���� ����-������� �� ������, � ������ ����� �������� ������ �������� ��������� � �� ������������ ����-������ ������ �� ����������� ����� ������ ����������� ������� ���������),
	manually_activated(����-������ ������������ �������),rejected(����-������ ���������, �� ���� ���������� �������� ��������),
	rejected_limits(����-������ ���������, �� �� ������ �������� �������),cdtloc(����-������ �����, ��� ��� ����� ��������� ������),
	cdtloe(����-������ �����, ��� ��� ��������� ������ ���������),minmaxcalc(���� ������ ��������-���������)
	]]
	local t={}
	local band=bit.band
	local tobit=bit.tobit
	if band(tobit(flags), 0x1) then t.active=true	else t.active = false end
	if band(tobit(flags),0x2) then t.cancelled=true 
	else	
		if not t.active then t.done=true else t.done=false end
		t.cancelled=false
	end
	if band(tobit(flags), 0x4) then t.operation="S" else t.operation = "B" end
	if band(tobit(flags), 0x8) then t.limit=true else t.limit = false end
	if band(tobit(flags),0x20) then t.wait_activation=true else t.wait_activation=false end
	if band(tobit(flags),0x40) then t.another_server=true else t.another_server=false end
	if band(tobit(flags),0x100) then t.tplopf=true else t.tplopf=false end
	if band(tobit(flags),0x200) then t.manually_activated=true else t.manually_activated=false end
	if band(tobit(flags),0x400) then t.rejected=true else t.rejected=false end
	if band(tobit(flags),0x800) then t.rejected_limits=true else t.rejected_limits=false end
	if band(tobit(flags),0x1000) then t.cdtloc=true else t.cdtlo=false end
	if band(tobit(flags),0x2000) then t.cdtloe=true else t.cdtloe=false end
	if band(tobit(flags),0x8000) then t.minmaxcalc=true else t.minmaxcalc=false end
	return t
end
function stoporderextflags2table(flags)
	-- ������� ���������� ������� � �������������� ��������� ����-������ �� ������
	--[[ �������� : 
	userest(������������ ������� �������� ������), cpf(��� ��������� ���������� ������ ����� ����-������), asolopf(������������ ����-������ ��� ��������� ���������� ��������� ������),
	percent(������ ����� � ���������, ����� � � ������� ����),defpercent(�������� ����� ����� � ���������, ����� � � ������� ����),
	this_day(���� �������� ����-������ ��������� ����������� ����),interval(���������� �������� ������� �������� ����-������),
	markettp(���������� ����-������� �� �������� ����),marketstop(���������� ����-������ �� �������� ����),
	]]
	local t={}
	local band=bit.band
	local tobit=bit.tobit
	if band(tobit(flags), 0x1) then t.userest=true else t.userest = false end
	if band(tobit(flags),0x2) then t.cpf=true t.cpf=false	end
	if band(tobit(flags), 0x4) then t.asolopf=true else t.asolopf =false end
	if band(tobit(flags), 0x8) then t.percent=true else t.percent = false end
	if band(tobit(flags),0x10) then t.defpercent=true else t.defpercent=false end
	if band(tobit(flags),0x20) then t.this_day=true else t.this_day=false end
	if band(tobit(flags),0x40) then t.interval=true else t.interval=false end
	if band(tobit(flags),0x80) then t.markettp=true else t.markettp=false end
	if band(tobit(flags),0x100) then t.marketstop=true else t.marketstop=false end
	return t
end
function bit_set( flags, index )
	--������� ���������� true, ���� ��� [index] ���������� � 1
	local n=1
    n=bit.lshift(1, index)
    if bit.band(flags, n) ~=0 then
       return true
    else
       return false
    end
end
function getRowFromTable(table_name,key,value)
	-- ���������� ������ (������� ���) �� ������� table_name � �������� key ������ value.
	-- table_name[key].value
	local i
	for i=getNumberOf(table_name),0,-1 do
		if getItem(table_name,i)[key]==value then
			return getItem(table_name,i)
		end
	end
	return nil
end
function HiResTimer()
-- ��������� ������ http://lua-users.org/wiki/HiResTimer
-- ������������� �������� ������ ������
	local alien=require"alien"

	--
	-- get the kernel dll
	--
	local kernel32=alien.load("kernel32.dll")

	--
	-- get dll functions
	--
	local QueryPerformanceCounter=kernel32.QueryPerformanceCounter
	QueryPerformanceCounter:types{ret="int",abi="stdcall","pointer"}
	local QueryPerformanceFrequency=kernel32.QueryPerformanceFrequency
	QueryPerformanceFrequency:types{ret="int",abi="stdcall","pointer"}
	--------------------------------------------
	--- utility : convert a long to an unsigned long value
	-- (because alien does not support longlong nor ulong)
	--------------------------------------------
	local function lu(long)
		return long<0 and long+0x80000000+0x80000000 or long
	end

	--------------------------------------------
	--- Query the performance frequency.
	-- @return (number)
	--------------------------------------------
	local function qpf()
		local frequency=alien.array('long',2)
		QueryPerformanceFrequency(frequency.buffer)
		return  math.ldexp(lu(frequency[1]),0)
				+math.ldexp(lu(frequency[2]),32)
	end

	--------------------------------------------
	--- Query the performance counter.
	-- @return (number)
	--------------------------------------------
	local function qpc()
		local counter=alien.array('long',2)
		QueryPerformanceCounter(counter.buffer)
		return	 math.ldexp(lu(counter[1]),0)
				+math.ldexp(lu(counter[2]),32)
	end

	--------------------------------------------
	-- get the startup values
	--------------------------------------------
	local f0=qpf()
	local c0=qpc()
	local c1=qpc()
	return (c1-c0)/f0
end
function getSTime()
	--���������� ������� ����� ������� � ���� ����� ������� HHMMSS
	local t = ""
	local a = tostring(getInfoParam("SERVERTIME"))
	for s in a:gmatch('%d+') do
		t=t..s
	end
	return tonumber(t)
end
function getLTime()
	-- ���������� ������� ����� ���������� � ���� ����� ������� HHMMSS
	local t=os.date('*t')
	local a=""
	if string.len(tostring(t.hour))<2 then a='0'..t.hour else a=t.hour end
	if string.len(tostring(t.min))<2 then a=a..'0'..t.min else a=a..t.min end
	if string.len(tostring(t.sec))<2 then a=a..'0'..t.sec else a=a..t.sec end
	return tonumber(a)
end
function getTradeDate()
	-- ���������� ������� �������� ���� � ���� ����� ������� YYYYMMDD
	local t = ""
	local a = tostring(getInfoParam("TRADEDATE"))
	for s in a:gmatch('%d+') do
		t=s..t
	end
	return tonumber(t)
end
function isTradeTime(exchange, shift)
	--���������� true ���� ������� ��������� ����� �������� �������� ��� ����� exchange � false ���� ��� (�������, ��� ������)
	-- ��������� ������� ���� - UX,MICEX,FORTS
	-- � ��������� shift ������� ������� ����� ������� ������� ������� ������������ ������� ���� MICEX,FORTS (������� ��������� � ������� ��������)
	if exchange==nil then return false end
	local time=getSTime()
	local sp=0
	if shift~=nil then sp=tonumber(shift) end
	if (exchange=='UX' or exchange=='MICEX') and time+sp>103000 and time+sp<173000 then return true else return false end
	if exchange=='FORTS' and ((time+sp>100000 and time+sp<140000) or (time+sp>140300 and time+sp<184500) or (time+sp>190000 and time+sp<235000)) then return true else return false end
	return false
end
function datetime2string(dt)
	-- ����������� ������ datetime � ������ ������� YYYYMMDDHHMMSS
	local s='' 
	if string.len(tostring(dt.year))<4 then s=s..'20'..dt.year else s=s..dt.year end
	if string.len(tostring(dt.month))<2 then s=s..'0'..dt.month else s=s..dt.month end
	if string.len(tostring(dt.day))<2 then s=s..'0'..dt.day else s=s..dt.day end
	if string.len(tostring(dt.hour))<2 then s=s..'0'..dt.hour else s=s..dt.hour end
	if string.len(tostring(dt.min))<2 then s=s..'0'..dt.min else s=s..dt.min end
	if string.len(tostring(dt.sec))<2 then s=s..'0'..dt.sec else s=s..dt.sec end
	return s
end
function isEqual(tbl1,tbl2)
    -- ���������� true ���� ������� tbl1 � tbl2 ��������� ���������
	if isSubTable(tbl1,tbl2) and isSubTable(tbl2,tbl1) then return true else return false end
end
function isSubTable(sub,main)
	-- ���������� true ���� ������� sub ��������� � � �������� ���������� � ������� main
	for k, v in pairs(sub ) do
        if ( type(v) == "table" and type(main[k]) == "table" ) then
            if ( not isSubTable( v, main[k] ) ) then return false end
        else
            if ( v ~= main[k] ) then return false end
        end
    end
	return true
end