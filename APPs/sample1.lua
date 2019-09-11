krl.List = krl.List +1
-------触るな危険-------

test = 1
testLINE = {}

function Sample()
	color(255,0,0)
	if(krl:SystemClickDown("M",0,0,_WIDTH(),_HEIGHT())==1) then
		testLINE[test] = _MX()-krl.base[krl.AppNumber]
		testLINE[-test] = _MY()-krl.base[-krl.AppNumber]	
		test =test +1	
	end
	if(test>2) then
		krl:MOVE(testLINE[1],testLINE[-1])
		for z = 1,test-1,1 do
			krl:LINE(testLINE[z],testLINE[-z])
		end
	end
	color(0,255,0)
	krl:MOVE(0,0)
	krl:LINE(500,500)
	color(0,0,255)
	krl:MOVE(175,0)
	krl:LINE(-5,180)
--	out(0,"scroll max X =",krl.scrollMax[krl.AppNumber])
--	out(1,"scroll max Y =",krl.scrollMax[-krl.AppNumber])
--	out(6,"window area X =",krl.area[krl.AppNumber])
--	out(7,"window area Y =",krl.area[-krl.AppNumber])
--	out(3,"scroll X =",krl.scroll[krl.AppNumber])
--	out(4,"scroll Y =",krl.scroll[-krl.AppNumber])
end

-------↓それぞれ指定してね↓-------
	
--作った関数を指定、()は不要
krl.Application[krl.List] = Sample
	
--ウィンドウ表示時の名前を指定
krl.Name[krl.List] = "SAMPLE"