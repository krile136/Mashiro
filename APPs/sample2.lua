krl.List = krl.List +1
-------触るな危険-------

function Sample2()

	local testspell = Spell.new("TEST")
	
	testspell:krlDrawSentence(10,10,10)

	local testbutton = krl.button:new(100,60,30,30)
	testbutton:draw()
	local testjudge = testbutton:click("R")

	out(5,testjudge)

	testbutton:MOVE(10,10)
	testbutton:LINE(20,20)
	testbutton:MOVE(20,10)
	testbutton:LINE(10,20)


	color(0,0,255)
	krl:MOVE(0,0)
	krl:LINE(300,300)
end

-------↓それぞれ指定してね↓-------
	
--作った関数を指定、()は不要
krl.Application[krl.List] = Sample2
	
--ウィンドウ表示時の名前を指定
krl.Name[krl.List] = "SAMPLE2"