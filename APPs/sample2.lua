krl.List = krl.List +1
-------�G��Ȋ댯-------

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

-------�����ꂼ��w�肵�Ăˁ�-------
	
--������֐����w��A()�͕s�v
krl.Application[krl.List] = Sample2
	
--�E�B���h�E�\�����̖��O���w��
krl.Name[krl.List] = "SAMPLE2"