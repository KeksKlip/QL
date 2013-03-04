-- Version 0.3.1
--[[
	�������� moveOrder,moveOrderSpot,moveOrderFO. ������� ������ ������� ������� - FUT_OPT_CLASSES. �������� ������� �������� ���������� killOrder � ����������� �� ����������� ����������.
	�������� ���������� ������� ���������� � toPrice. �������� ������� getRowFromTable. �������� ��������� ���������� sendLimit, sendMarket, sendRPS, sendReportOnRPS
]]--
package.cpath=".\\?.dll;.\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files (x86)\\Lua\\5.1\\loadall.dll;C:\\Program Files (x86)\\Lua\\5.1\\clibs\\loadall.dll;C:\\Program Files\\Lua\\5.1\\?.dll;C:\\Program Files\\Lua\\5.1\\?51.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?.dll;C:\\Program Files\\Lua\\5.1\\clibs\\?51.dll;C:\\Program Files\\Lua\\5.1\\loadall.dll;C:\\Program Files\\Lua\\5.1\\clibs\\loadall.dll"..package.cpath
package.path=package.path..";.\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\?.lua;C:\\Program Files (x86)\\Lua\\5.1\\?\\init.lua;C:\\Program Files (x86)\\Lua\\5.1\\lua\\?.luac;C:\\Program Files\\Lua\\5.1\\lua\\?.lua;C:\\Program Files\\Lua\\5.1\\lua\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\?.lua;C:\\Program Files\\Lua\\5.1\\?\\init.lua;C:\\Program Files\\Lua\\5.1\\lua\\?.luac;"
require"bit"
require"socket"
FUT_OPT_CLASSES="FUTUX,OPTUX,SPBOPT,SPBFUT"
NOTRANDOMIZED=true
--require"iuplua"
--require"iupluacontrols"
--[[
Trading Module
]]--
function sendLimit(class,security,direction,price,volume,account,client_code,comment)
	-- �������� �������������� ������
	-- ��� ��������� ����� ���� ������� � ���������� ������ ���� �� ���
	-- �����! ���� ������ ���� �������� � ����������� ������ ����� ����� ��� ������ ������
	-- ���� ��� ������� ��� - ������������ ����
	-- ������ ������� ���������� 2 ��������� 
	--     1. ID ����������� ���������� ���� nil ���� ���������� ���������� �� ������ ������� ����
	--     2. �������� ��������� ������� ���� ���� ������ � ����������� ����������
	if (class==nil or security==nil or direction==nil or price==nil or volume==nil or account==nil) then
		return nil,"QL.sendLimit(): Can`t send order. Nil parameters."
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
		["PRICE"]=price,
		["ACCOUNT"]=tostring(account)
	}
	if client_code==nil then
		transaction.client_code=tostring(account)
	else
		transaction.client_code=tostring(client_code)
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
		return nil, "QL.sendLimit():"..res
	else
		return trans_id, "QL.sendLimit(): Limit order sended sucesfully. Class="..class.." Sec="..security.." Dir="..direction.." Price="..price.." Vol="..volume.." Acc="..account.." Trans_id="..trans_id
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
			transaction.price=string.gsub(getParamEx(class,security,"PRICEMAX").param_image,"%s","")
		else
			transaction.price=string.gsub(getParamEx(class,security,"PRICEMIN").param_image,"%s","")
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
	if (orderflags2table(forder.flags).cancelled==1 or (orderflags2table(forder.flags).done==1 and forder.balance==0)) then
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
		return trans_id,"QL.killOrder(): Limit order kill sended. MAY NOT KILL!!! Class="..transaction.classcode.." Sec="..transaction.seccode.." Key="..orderkey.." Trans_id="..trans_id
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
		if orderflags2table(row.flags).active==1 then
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
function getPosition(security)
    --���������� ������ ������� �� �����������
	local class_code=getSecurityInfo("",security).class_code
    if string.find(FUT_OPT_CLASSES,class_code)~=nil then
	--futures
		local row=getRowFromTable("futures_client_holding","seccode",security)
		if row~=nil then
			if row.totalnet==nil then
				return 0
			else
				return row.totalnet
			end
		end
	else
	-- spot
		local row=getRowFromTable("account_positions","seccode",security)
		if row~=nil then
			if row.currentpos==nil then
				return 0
			else
				return row.currentpos
			end
		end
	end
    return 0
end
--[[
Support Functions
]]--
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
			str=str..k.."="..v
		elseif type(v)=="table"then
			str=str..k.."={"..table2string(v).."}"
		elseif type(v)=="function" then
			str=str..tostring(v)
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
	local scale=getParamEx(getSecurityInfo("",security).class_code,security,"SEC_SCALE").param_value
	return string.format("%."..string.format("%d",scale).."f",value)
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
	-- �������� : active, cancelled, done,operation("B" for Buy, "S" for Sell),limit(1 - limit order, 0 - market order)
	local t={}
	if bit_set(flags, 0) then
		t.active=1
	else
		t.active = 0
	end
	if bit_set(flags,1) then
		t.cancelled=1
	else
		if t.active==0 then t.done=1 else t.done=0 end
		t.cancelled=0
	end
	if bit_set(flags, 2) then
		t.operation="S"
	else
		t.operation = "B"
	end
	if bit_set(flags, 3) then
		t.limit=1
	else
		t.limit = 0
	end
	if t.cancelled==1 and t.done==1 then
		message("Erorr in orderflags2table order cancelled and done!",2)
	end
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