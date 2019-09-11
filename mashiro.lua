
--Spirytusをロード
	loadlib("Spirytus.DLL", "rc_OpenSpirytus")();


--各種ライブラリをロード
	LUA_PATH="C:/lib/OrzDeveloppment/?"

	require("cel/RC/Spell.lua")		--cel氏製フォント表示ライブラリ
	require("cel/font/PathData.lua")	--cel氏製フォントライブラリ
	require("OstLib/G2VTFtSb-Cel.lua")	--Ostwald氏製フォントライブラリ

--Spell.luaを改変
	Spell.DrawChar2 = function(x,y,st,size,s,c,scale,font)
		font = font or PathData
		if font[st]==nil then return end
		scale = scale or 1
		s,c = s or 0,c or 1
		local mode = 0
		local tx,ty
		for i=1,table.getn(font[st]) do
			if font[st][i] == "M" then
				mode = 0
			elseif font[st][i] == "L" then
				mode = 1
			else
				tx,ty = font[st][i][2]*scale,font[st][i][1]
				if mode == 0 then
					msr:MOVE(x+size*(tx*c+ty*s),y-size*(ty*c-tx*s))
					mode = 1
				else
					msr:LINE(x+size*(tx*c+ty*s),y-size*(ty*c-tx*s))
				end
			end
		end
	end

	Spell.DrawSentence2 = function(self,x,y,size,font)
		font = font or PathData
		local l = 0
		local px = 2/_HEIGHT() * self.distance
		local tmp
		for i=1,table.getn(self.chars) do
			if(font[self.chars[i]]~=nil) then	
				tmp = (1-font[self.chars[i]][0])/2 * size
				l = l - tmp
				Spell.DrawChar2(x+l*self.c , y+l*self.s , self.chars[i] , size , self.s,self.c,1,font)
				l = l + tmp + font[self.chars[i]][0]*size + px
			end
		end
	end

	Spell.DrawChar = function(x,y,st,size,s,c,scale,font)
		font = font or PathData
		if font[st]==nil then return end
		scale = scale or 1
		s,c = s or 0,c or 1
		local mode = 0
		local tx,ty
		for i=1,table.getn(font[st]) do
			if font[st][i] == "M" then
				mode = 0
			elseif font[st][i] == "L" then
				mode = 1
			else
				tx,ty = font[st][i][2]*scale,font[st][i][1]
				if mode == 0 then
					_MOVE2D(x+size*(tx*c+ty*s),y-size*(ty*c-tx*s))
					mode = 1
				else
					_LINE2D(x+size*(tx*c+ty*s),y-size*(ty*c-tx*s))
					msr.lines = msr.lines +1
				end
			end
		end
	end

--Window表示用の変数準備
	Window = {}
	Window.line = 2/_HEIGHT()
	Window.height = _HEIGHT()
	Window.width = _WIDTH()
	

--ヘアライン用変数準備
	block = {}
	block.number = _HEIGHT()/5
	for i=0,block.number,1 do
		block[i]={}
		block[i].start = math.floor(math.random(3))
		block[i].finish = block[i].start +1
		block[i].color = 170-math.floor(math.random(25))
	end

--簡単色指定
	function color(r,g,b)
		local co = r*256^2+g*256+b
		_SETCOLOR(co)
	end

--EXKEYDOWN関連
	EXKEY = {}
	for i=0,10,1 do
		EXKEY[i] = {}
		EXKEY[i].down = 0
	
	end
	function EXKEYDOWN(n)
		if(_EXKEY(n)==0)and(EXKEY[n].down==-1) then
			EXKEY[n].down = 0
		elseif(_EXKEY(n)==1)and(EXKEY[n].down==1) then
			EXKEY[n].down = -1
		elseif(_EXKEY(n)==1)and(EXKEY[n].down==0) then
			EXKEY[n].down = 1
		end
		if(_EXKEY(n)==0)and(EXKEY[n].down==1) then
			EXKEY[n].down = 0
		end
		local ret_key = math.max(0,EXKEY[n].down)

		return ret_key
	end


--スムーズにメニューをしまう
	function MoveSmooth(val,vr,com,min)
		val=val+(vr-val)/com
		if(math.abs(vr-val)<min) then	
			val = vr
		end
		return val
	end

--------------------------------コントロールセンター　ましろ--------------------------------
--変数準備
	msr = {}
	msr.version = "0.7"
	msr.width = 0
	msr.power = -1
	msr.display = -1
	msr.left = -_WIDTH()/_HEIGHT()
	msr.lines = 0

--初期の高さを指定（ピクセル）
	msr.krile = 20
	msr.miyuri = 20
	msr.model = 20
	msr.info = 20


--ましろ用MOVE2D,LINE2D
	function msr:MOVE(x,y)
		if(msr.display>0) then
			_MOVE2D(x,y)
		end
	end
	function msr:LINE(x,y)
		if(msr.display>0) then
			_LINE2D(x,y)
			msr.lines = msr.lines +1
		end
	end

--ましろ用mouse関連
	msr.mousedownR = 0
	msr.mousedownL = 0
	msr.mousedownM = 0
	msr.mouseupR = 0
	msr.mouseupL = 0
	msr.mouseupM = 0  

--KEY関連のマウスバージョン
	function msr:click(type,bx,by,ax,ay)
		if(msr.power<0) then
			return 0
		elseif(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
			if(type=="R") then
				return _MR()
			elseif(type=="L") then
				return _ML()
			else
				return _MM()
			end
		else
			return 0
		end
	end

--KEYDOWNのマウスバージョン
	function msr:clickdown(type,bx,by,ax,ay)
		if(msr.power<0) then
			return 0
		elseif(type=="R") then
			if(msr.mousedownR==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="L") then
			if(msr.mousedownL==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="M") then
			if(msr.mousedownM==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		end
	end

--KEYUPのマウスバージョン
	function msr:clickup(type,bx,by,ax,ay)
		if(msr.power<0) then
			return 0
		elseif(type=="R") then
			if(msr.mouseupR==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="L") then
			if(msr.mouseupL==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="M") then
			if(msr.mouseupM==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		end
	end

--KEYUPやKEYDOWNの更新
	function msr:updown_control()

			if(_MR()==0)and(msr.mousedownR==-1) then
				msr.mousedownR = 0
			elseif(_MR()==1)and(msr.mousedownR==1) then
				msr.mousedownR = -1
			elseif(_MR()==1)and(msr.mousedownR==0) then
				msr.mousedownR = 1
			end
			if(_MR()==0)and(msr.mousedownR==1) then
				msr.mousedownR = 0
			end

			if(_ML()==0)and(msr.mousedownL==-1) then
				msr.mousedownL = 0
			elseif(_ML()==1)and(msr.mousedownL==1) then
				msr.mousedownL = -1
			elseif(_ML()==1)and(msr.mousedownL==0) then
				msr.mousedownL = 1
			end
			if(_ML()==0)and(msr.mousedownL==1) then
				msr.mousedownL = 0
			end

			if(_MM()==0)and(msr.mousedownM==-1) then
				msr.mousedownM = 0
			elseif(_MM()==1)and(msr.mousedownM==1) then
				msr.mousedownM = -1
			elseif(_MM()==1)and(msr.mousedownM==0) then
				msr.mousedownM = 1
			end
			if(_MM()==0)and(msr.mousedownM==1) then
				msr.mousedownM = 0
			end

			if(_MR()==0)and(msr.mouseupR==1) then
				msr.mouseupR = 0
			end
			if(_MR()==1)and(msr.mouseupR==0) then
				msr.mouseupR = -1
			elseif(_MR()==0)and(msr.mouseupR==-1) then
					msr.mouseupR = 1
			end
		
			if(_ML()==0)and(msr.mouseupL==1) then
				msr.mouseupL = 0
			end
			if(_ML()==1)and(msr.mouseupL==0) then
				msr.mouseupL = -1
			elseif(_ML()==0)and(msr.mouseupL==-1) then
				msr.mouseupL = 1
			end
		
			if(_MM()==0)and(msr.mouseupM==1) then
				msr.mouseupM = 0
			end
			if(_MM()==1)and(msr.mouseupM==0) then
				msr.mouseupM = -1
			elseif(_MM()==0)and(msr.mouseupM==-1) then
				msr.mouseupM = 1
			end
	end


----------------ましろメイン部分----------------
	function Mashiro()

--SETVIEW関連のバグで、最初に実行
		tx,ty,tz = target_axis(myr.target_number)
		if(myr.target_id~=_PLAYERMYID()) then
			_SETVIEW(tx,ty+10,tz-20,tx,ty,tz)
		elseif(myr.cam_reset==1) then
			_SETVIEWTYPE(0)
			myr.cam_reset = -1
		end

--マウスの情報取得の更新
		msr:updown_control()

--RC窓の初期化かつ、windowサイズが変わった時に対応する
		if(Window.width~=_WIDTH()) then
			Window.width = _WIDTH()
			msr.left = -_WIDTH()/_HEIGHT()
		end
		if(Window.height~=_HEIGHT()) then
			Window.height = _HEIGHT()
			Window.line = 2/_HEIGHT()
			msr.left = -_WIDTH()/_HEIGHT()
			block.number = _HEIGHT()/5
			for i=0,block.number,1 do
				if(block[i]==NULL) then
					block[i] = {}
				end
				block[i].start = math.floor(math.random(3))
				block[i].finish = block[i].start +1
				block[i].color = 170-math.floor(math.random(25))
			end
		end
		
--Spaceキーでましろ起動
		if(EXKEYDOWN(3)==1) then
			msr.power = -msr.power

		end
--ましろのスムーズな出し入れ
		if(msr.power>0) then
			msr.width = MoveSmooth(msr.width,200*Window.line,2.5,0.001)
		else
			msr.width = MoveSmooth(msr.width,0,2.5,0.001)
		end

--ましろ自体の表示/非表示
		if(msr.width>0) then
			msr.display = 1 
		else
			msr.display = 0
		end

--KRILE GUIのコントロール
		for p=krl.List,1,-1 do
			for q=1,krl.List,1 do
				if(krl.layer[q]==p) then
					if(krl.call[q]>0) then
						krl.AppNumber = q
						krl:Frame(q)
					end
					local NAME = Spell.new(krl.Name[p])
					krl.TotalWidth = math.max(krl.TotalWidth,(NAME:Width(0.04)+0.04))
				end
			end
		end

		krl:MouseMain()

--ヘアラインの表示
		if(msr.display>0) then		
			for i=0,block.number,1 do
				for j=0,4,1 do
					if(j>=block[i].start)and(j<=block[i].finish) then
						color(block[i].color,block[i].color,block[i].color)
					else
						color(160,160,160)
					end	
					msr:MOVE(msr.left,1-i*Window.line*5-j*Window.line)
					msr:LINE(msr.left+msr.width,1-i*Window.line*5-j*Window.line)
				end
			end
			color(0,0,0)
			msr:MOVE(msr.left+msr.width,1)
			msr:LINE(msr.left+msr.width,-1)	
		end

--各アプリケーション
		msr:Krile()		--GUIシステム
		msr:Miyuri()		--ネットワーク管理システム
		msr:clock()		--アナログ時計の表示




--line本数のリセット
		msr.lines = 0
	end

----------------------------コントロールセンター　ましろ　ここまで----------------------------

----------------------------アナログ時計　ここから----------------------------
	msr.clockmode = 1
	function msr:clock()

--ボタンとか色々
		color(50,50,50)
		msr:MOVE(msr.left,-1+120*Window.line)	msr:LINE(msr.left+msr.width,-1+120*Window.line)
		msr:MOVE(msr.left,-1+100*Window.line)	msr:LINE(msr.left+msr.width,-1+100*Window.line)

		local click = msr:click("L",0,_HEIGHT()-121,200,_HEIGHT()-100)

		color(130,130,130)
		msr:MOVE(msr.left,-1+(121-20*click)*Window.line)
		msr:LINE(msr.left+msr.width,-1+(121-20*click)*Window.line)
		msr:MOVE(msr.left,-1+(119-20*click)*Window.line)
		msr:LINE(msr.left+msr.width,-1+(119-20*click)*Window.line)
		

		color(40,40,40)
		for i=1,5,1 do
			color(50+20*i,50+20*i,50+20*i)
			msr:MOVE(msr.left,-1+(100-i+20*click)*Window.line)
			msr:LINE(msr.left+msr.width,-1+(100-i+20*click)*Window.line)
		end

		color(30,30,30)
		mozi = Spell.new("CLOCK")
		mozi:DrawSentence2(msr.left+msr.width-(100-click)*Window.line-mozi:Width(Window.line*10)/2,-1+(115-click)*Window.line,Window.line*10)

		if(msr:clickup("L",0,_HEIGHT()-121,200,_HEIGHT()-100)==1) then
			msr.clockmode = -msr.clockmode
		end



--日付と曜日の、線の数やmashiroとkrileのバージョン表示
		data = {}
		data[0],data[1],data[2],data[3],data[4],data[5],data[6] = "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"
		year,month,day,dat,hour,min,sec,msec = GetLocalTime()

		if(msr.clockmode>0) then
			year = string.format("%d",year)
			month = string.format("%d",month)
			day = string.format("%d",day)
			days = year.."/"..month.."/"..day
			color(50,50,50)
			mozi = Spell.new(days)
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(mozi:WidthAdjust(80))/2,-1+85*Window.line,mozi:WidthAdjust(80))
			mozi = Spell.new(data[dat])
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(Window.line*10)/2,-1+65*Window.line,Window.line*10)
			mozi = Spell.new("FPS")
			mozi:DrawSentence2(msr.left+msr.width-190*Window.line,-1+35*Window.line,Window.line*7)
			mozi = Spell.new(":")
			mozi:DrawSentence2(msr.left+msr.width-155*Window.line,-1+35*Window.line,Window.line*7)			
			fps = string.format("%0.2f",_FPS())
			mozi = Spell.new(fps)
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line,-1+35*Window.line,Window.line*7)
			mozi = Spell.new("LINE")
			mozi:DrawSentence2(msr.left+msr.width-190*Window.line,-1+20*Window.line,Window.line*7)
			mozi = Spell.new(":")
			mozi:DrawSentence2(msr.left+msr.width-155*Window.line,-1+20*Window.line,Window.line*7)	
			lines = string.format("%d",msr.lines)
			mozi = Spell.new(lines)
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line,-1+20*Window.line,Window.line*7)			
		else
			ver = "VER  "..msr.version
			mozi = Spell.new("MASHIRO")
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(Window.line*8)/2,-1+80*Window.line,Window.line*8)
			mozi = Spell.new(ver)
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(Window.line*6)/2,-1+65*Window.line,Window.line*6)
			ver = "VER  "..krl.version
			mozi = Spell.new("KRILE")
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(Window.line*8)/2,-1+40*Window.line,Window.line*8)
			mozi = Spell.new(ver)
			mozi:DrawSentence2(msr.left+msr.width-150*Window.line-mozi:Width(Window.line*6)/2,-1+25*Window.line,Window.line*6)
		end

--アナログ時計表示部分
		local radius = 35
		local angle = math.pi/6

		local cent_x,cent_y = msr.left+msr.width-50*Window.line,-1+50*Window.line

		for i=0,11,1 do
			if(math.mod(i,3)==0) then
				color(213,62,98)
				msr:MOVE(cent_x+(radius-3)*Window.line*math.sin(angle*i),cent_y+(radius-3)*Window.line*math.cos(angle*i))
				msr:LINE(cent_x+(radius+5)*Window.line*math.sin(angle*i),cent_y+(radius+5)*Window.line*math.cos(angle*i))
			else
				color(255,255,255)
				msr:MOVE(cent_x+radius*Window.line*math.sin(angle*i),cent_y+radius*Window.line*math.cos(angle*i))
				msr:LINE(cent_x+(radius+5)*Window.line*math.sin(angle*i),cent_y+(radius+5)*Window.line*math.cos(angle*i))
			end

			color(0,0,0)
			msr:MOVE(cent_x+3*Window.line*math.sin(angle*i),cent_y+3*Window.line*math.cos(angle*i))
			msr:LINE(cent_x+3*Window.line*math.sin(angle*(i+1)),cent_y+3*Window.line*math.cos(angle*(i+1)))
		end

		if(hour>12) then
			hour = hour -12 
		end
		hour = hour*5 +math.floor(min/60*5)
		angle = math.pi/30
		color(60,60,60)
		msr:MOVE(cent_x+30*Window.line*math.sin(hour*angle),cent_y+30*Window.line*math.cos(hour*angle))
		msr:LINE(cent_x+3*Window.line*math.sin((hour+15)*angle),cent_y+3*Window.line*math.cos((hour+15)*angle))
		msr:LINE(cent_x+3*Window.line*math.sin((hour-15)*angle),cent_y+3*Window.line*math.cos((hour-15)*angle))
		msr:LINE(cent_x+30*Window.line*math.sin(hour*angle),cent_y+30*Window.line*math.cos(hour*angle))

		msr:MOVE(cent_x+37*Window.line*math.sin(min*angle),cent_y+37*Window.line*math.cos(min*angle))
		msr:LINE(cent_x+3*Window.line*math.sin((min+15)*angle),cent_y+3*Window.line*math.cos((min+15)*angle))
		msr:LINE(cent_x+3*Window.line*math.sin((min-15)*angle),cent_y+3*Window.line*math.cos((min-15)*angle))
		msr:LINE(cent_x+37*Window.line*math.sin(min*angle),cent_y+37*Window.line*math.cos(min*angle))

		msr:MOVE(cent_x,-1+50*Window.line)
		msr:LINE(cent_x+37*Window.line*math.sin(sec*angle),cent_y+37*Window.line*math.cos(sec*angle))


	end
	
	Spell.WidthAdjust = function(self,size,scale)
		scale = scale or 1
		local tn = table.getn(self.chars)
		local len = 0
		for i=1,tn do
			len = len + PathData[self.chars[i]][0]
		end
		return (size*Window.line - self.distance*(tn-1)*2/_HEIGHT())/len
	end
----------------------------アナログ時計ここまで---------------------------	

----------------------------GUIシステム "KRILE"　ここから---------------------------
--変数準備　座標は全て左上を０に、ピクセル数で扱う
	krl = {}
	krl.version = "1.0"
	krl.List = 0
	krl.Application = {}
	krl.base = {}	--windowの基準点（左上の座標）
	krl.area = {}	--windowの大きさ
	krl.scroll = {}	--window内での現在のスクロール量
	krl.scrollMax = {}	--windowの最大のスクロール数
	krl.scrollbar = {}	--スクロールバーの大きさ
	krl.layer = {}	--windowごとのレイヤー高さ　いわゆるZオーダー
	krl.Name = {}	--windownの名前
	krl.call = {}	--windowが起動しているかどうか
	krl.hidden = {}	--windowの表示/非表示
	krl.AppNumber = 0
	krl.menu = 20		--menuバーの高さ
	krl.under = 5		--フッター的なやつの高さ
	krl.TotalWidth = 0
	krl.setting = 0

--マウス関連の変数
	krl.Mousex = 0
	krl.Mousey = 0
	krl.MouseR = 0
	krl.MouseL = 0
	krl.MouseDownL = 0
	krl.MouseDownR = 0
	krl.Mousemove = 0
	krl.Mousescale = 0
	krl.MousedeffX = 0
	krl.MousedeffY = 0
	krl.MousebaseMax = 0
	krl.Mousescroll = 0
	krl.MouseSclX1 = 0
	krl.MouseSclY1 = 0
	krl.MouseSclX2 = 0
	krl.MouseSclY2 = 0

--その他変数
	krl.LineContinue = -1	--線の連続性を確認（_MOVE実行の節約のため）
	krl.LineNum = {}	--krl.LineNum[i]　アプリごとの今描画中の線の番号記録用

	krl.Mcoordinates = {}	--krl.Mcoordinates[i][j] i番目のアプリのMOVEに使うj番目の線の座標（＋でX座標、ーでY表）
	krl.Lcoordinates = {}	--krl.Lcoordinates[i][j] i番目のアプリのLINEに使うj番目の線の座標（同上）

	krl.spell = {}
	krl.button = {}

--windowのフレーム描画
	function krl:Frame(i)
		bx,by = krl.base[i],krl.base[-i]

		local count = krl.area[-i]+krl.menu+krl.under
		local menu_c = krl.menu
		local under_c = krl.area[-i]+krl.menu

		if(krl.hidden[i]>0) then
			for j=0,count,1 do
				if(j<=menu_c)or(j>under_c) then
					if(krl.layer[i]~=1) then
						color(180,180,180)
					else
						color(135,135,135)
					end
				else
					color(255,255,255)
				end
				krl:MOVE2D(bx,by-krl.menu+j)
				krl:LINE2D(bx+krl.area[i],by+j-krl.menu)
			end
		end
	--アプリケーションの内容を実行&描画
		krl.Application[i]()

	--線番号をリセット
		krl.LineNum[i] = 1

	--windowが表示する設定の時に実行する
		if(krl.hidden[i]>0) then
			color(0,0,0)
			krl:MOVE2D(bx,by-krl.menu)
			krl:LINE2D(bx+krl.area[i],by-krl.menu)			krl:LINE2D(bx+krl.area[i],by+krl.area[-i]+krl.under)
			krl:LINE2D(bx,by+krl.area[-i]+krl.under)		krl:LINE2D(bx,by-krl.menu)
			krl:MOVE2D(bx,by)					krl:LINE2D(bx+krl.area[i],by)
			krl:MOVE2D(bx,by+krl.area[-i])				krl:LINE2D(bx+krl.area[i],by+krl.area[-i])
			krl:MOVE2D(bx+krl.area[i]-krl.menu,by)			krl:LINE2D(bx+krl.area[i]-krl.menu,by-krl.menu)
			krl:MOVE2D(bx+krl.area[i]-krl.menu*2,by)		krl:LINE2D(bx+krl.area[i]-krl.menu*2,by-krl.menu)
			krl:MOVE2D(bx+10,by+krl.area[-i])			krl:LINE2D(bx+10,by+krl.area[-i]+krl.under)
			krl:MOVE2D(bx+krl.area[i]-10,by+krl.area[-i])		krl:LINE2D(bx+krl.area[i]-10,by+krl.area[-i]+krl.under)
			color(230,230,230)
			krl:MOVE2D(bx+krl.area[i]-5,by-5)			krl:LINE2D(bx+krl.area[i]-15,by-15)
			krl:MOVE2D(bx+krl.area[i]-5,by-15)			krl:LINE2D(bx+krl.area[i]-15,by-5)
			krl:MOVE2D(bx+krl.area[i]-krl.menu-5,by-5)		krl:LINE2D(bx+krl.area[i]-krl.menu-15,by-5)

			if(krl.layer[i]==1) then
				local py,qy = by-krl.menu,by
				if(krl:SystemClickUp("L",bx+krl.area[i]-krl.menu*2,by-krl.menu,bx+krl.area[i]-krl.menu,by)==1) then
					krl.hidden[i] = -krl.hidden[i]
				elseif(krl:SystemClickUp("L",bx+krl.area[i]-krl.menu,by-krl.menu,bx+krl.area[i],by)==1) then
					krl.call[i] = -krl.call[i]
				end
			end
			krl:Title(i)
		end

	end	

--タイトル表示部分
	function krl:Title(i)
		local bx = krl.base[i]
		local by = krl.base[-i] -krl.menu 
		local l = 0
		local name_swi = 0
		local haba_max = krl.area[i]-krl.menu*2
		while(name_swi==0) do
			local mozi = string.sub(krl.Name[i],1,-1-l)
			local NAME = Spell.new(mozi)
			local haba = NAME:Width(Window.line*10)/Window.line +7
			if(haba<=haba_max) then
				local x = (2/_HEIGHT())*(bx+5)-_WIDTH()/_HEIGHT()
				local y = (-2/_HEIGHT())*(by+5)+1
				local size = Window.line*10
				NAME:DrawSentence(x,y,size)
				name_swi = 1
			else
				l = l+1
			end
		end
	end

--マウスコントロール部分
	function krl:MouseMain()

	--windowの移動の実行
		krl:Moving()

	--windowの拡大縮小の実行
		krl:Scaling()

	--スクロールの実行
		krl:Scroll()

		for i=1,krl.List,1 do
			krl.scrollMax[i] = 0
			krl.scrollMax[-i] = 0
		end

	--Zオーダーの入れ替え制御
		if(krl:SystemClickUp("L",0,0,_WIDTH(),_HEIGHT())==1) then
			krl:Interchange()
		end
	end
	

--Zオーダーの計算
	function krl:Zorder()
		local z = krl.List +1
		for i=krl.List,1,-1 do
			for j=1,krl.List,1 do
				if(krl.layer[j]==i) then
					if(krl.call[j]>0) then
						if(krl.hidden[j]>0) then
							local bx,by = krl.base[j],krl.base[-j]-krl.menu
							local rx,ry = bx+krl.area[j],krl.base[-j]+krl.area[-j]+krl.under
							if(bx<_MX())and(_MX()<rx)and(by<_MY())and(_MY()<ry) then
								z = i
							end
						end
					end
				end
			end
		end
		return z
	end

--Zオーダーの入れ替え制御
	function krl:Interchange()
		local Zorder = krl:Zorder()
		if(1<Zorder)and(Zorder<=krl.List) then
			local target = 0
			for i=1,krl.List,1 do
				if(krl.layer[i]==Zorder) then
					target = i
				end
			end
			while(krl.layer[target]~=1) do
				for i=1,krl.List,1 do
					local under_layer = krl.layer[target] -1
					if(krl.layer[i]==under_layer) then
						krl.layer[i],krl.layer[target] = krl.layer[target],krl.layer[i]
					end
				end
			end
		end
	end

--windowの移動制御
	function krl:Moving()
		if(krl.Mousemove==0)and(krl.Mousescale==0)and(krl.Mousescroll==0) then
			if(krl:SystemClickDown("L",0,0,_WIDTH(),_HEIGHT())==1) then
				krl:Interchange()
				for i=krl.List,1,-1 do
					if(krl.layer[i]==1)and(krl.call[i]==1)and(krl.hidden[i]==1) then
						local bx1,by1 = krl.base[i],krl.base[-i]-krl.menu
						local rx1,ry1 = bx1 +krl.area[i] -krl.menu*2,krl.base[-i]
						local bx2,by2 = krl.base[i]+10,krl.base[-i]+krl.area[-i]
						local rx2,ry2 = krl.base[i]+krl.area[i]-10 ,by2+krl.under
						if((bx1<_MX())and(_MX()<rx1)and(by1<_MY())and(_MY()<ry1))or((bx2<_MX())and(_MX()<rx2)and(by2<_MY())and(_MY()<ry2)) then
							krl.MousedeffX = krl.base[i] -_MX()
							krl.MousedeffY = krl.base[-i] -_MY()
							krl.Mousemove = i
						end
						break
					end
				end
			end
		else
			krl.base[krl.Mousemove]  = _MX() +krl.MousedeffX
			krl.base[-krl.Mousemove] = _MY() +krl.MousedeffY
			if(_ML()==0) then
				krl.Mousemove = 0
			end
		end
	end

--windowの拡大縮小
	function krl:Scaling()
		if(krl.Mousescale==0)and(krl.Mousemove==0)and(krl.Mousescroll==0) then
			if(krl:SystemClickDown("L",0,0,_WIDTH(),_HEIGHT())==1) then
				krl:Interchange()
				for i=krl.List,1,-1 do
					if(krl.layer[i]==1)and(krl.call[i]==1)and(krl.hidden[i]==1) then
						local bx1,by1 = krl.base[i],krl.base[-i]+krl.area[-i]
						local rx1,ry1 = bx1+10 ,by1+krl.menu
						local bx2,by2 = krl.base[i]+krl.area[i]-10,krl.base[-i]+krl.area[-i]
						local rx2,ry2 = bx2+10 ,by2+krl.under
						if(bx1<_MX())and(_MX()<rx1)and(by1<_MY()) then
							krl.MousedeffX = _MX() -krl.base[i]
							krl.MousedeffY = _MY() -(krl.base[-i]+krl.area[-i]+krl.under)
							krl.Mousescale = -i
							krl.MousebaseMax = krl.base[i] +krl.area[i] -krl.menu*2 -30
						elseif(bx2<_MX())and(_MX()<rx2)and(by2<_MY())and(_MY()<ry2) then
							krl.MousedeffX = _MX() -(krl.base[i] +krl.area[i])
							krl.MousedeffY = _MY() -(krl.base[-i]+krl.area[-i])
							krl.Mousescale = i
						end
						break
					end
				end
			end
		elseif(krl.Mousescale>0) then
			krl:Scrollbar()
			krl.area[krl.Mousescale]  = math.max(70,(_MX() -krl.base[krl.Mousescale] -krl.MousedeffX))
			krl.area[-krl.Mousescale] = math.max(70,(_MY() -krl.base[-krl.Mousescale] -krl.MousedeffY))
			local driftX = krl.scroll[krl.Mousescale]-krl.scrollMax[krl.Mousescale]
			local driftY = krl.scroll[-krl.Mousescale]-krl.scrollMax[-krl.Mousescale]
			if(driftX>=0) then
				krl.scroll[krl.Mousescale] = krl.scroll[krl.Mousescale]-driftX
			end
			if(driftY>=0) then
				krl.scroll[-krl.Mousescale] = krl.scroll[-krl.Mousescale]-driftY
			end
			if(_ML()==0) then
				krl.Mousescale = 0
			end
		elseif(krl.Mousescale<0) then
			krl:Scrollbar()
			local mx = krl.base[-krl.Mousescale]
			local my = krl.base[krl.Mousescale]
			krl.base[-krl.Mousescale] = math.min(krl.MousebaseMax,_MX()-krl.MousedeffX)
			krl.area[-krl.Mousescale] = math.max(70,krl.area[-krl.Mousescale] -krl.base[-krl.Mousescale] +mx)
			krl.area[krl.Mousescale]  = math.max(70,_MY() -krl.base[krl.Mousescale] -krl.under -krl.MousedeffY)
			local driftY = krl.scroll[krl.Mousescale]-krl.scrollMax[krl.Mousescale]
			if(krl.scroll[-krl.Mousescale]>0) then
				krl.scroll[-krl.Mousescale] = math.max(0,krl.scroll[-krl.Mousescale]-(-krl.base[-krl.Mousescale] +mx))
			end
			if(driftY>=0) then
				krl.scroll[krl.Mousescale] = krl.scroll[krl.Mousescale]-driftY
			end
			if(_ML()==0) then
				krl.Mousescale = 0
			end
		end
	end

--windowのスクロール制御
	function krl:Scroll()
		if(krl.Mousemove==0)and(krl.Mousescale==0)and(krl.Mousescroll==0) then
			if(krl:SystemClickDown("R",0,0,_WIDTH(),_HEIGHT())==1) then
				krl:Interchange()
				for i=krl.List,1,-1 do
					if(krl.layer[i]==1)and(krl.call[i]==1)and(krl.hidden[i]==1) then
						local bx,by = krl.base[i],krl.base[-i]
						local rx,ry = bx+krl.area[i],krl.base[-i]+krl.area[-i]
						if(bx<_MX())and(_MX()<rx)and(by<_MY())and(_MY()<ry) then
							krl.MouseSclX1 = _MX()
							krl.MouseSclY1 = _MY()
							krl.MouseSclX2 = krl.scroll[i]
							krl.MouseSclY2 = krl.scroll[-i]
							krl.Mousescroll = -i
						end	
						break
					end
				end
			end
		elseif(krl.Mousescroll<0) then
			local mx = math.max(0,math.min(krl.scrollMax[krl.Mousescroll],krl.MouseSclX2-(_MX()-krl.MouseSclX1)))
			local my = math.max(0,math.min(krl.scrollMax[-krl.Mousescroll],krl.MouseSclY2-(_MY()-krl.MouseSclY1)))
			if(mx~=krl.scroll[-krl.Mousescroll])or(my~=krl.scroll[krl.Mousescroll]) then
				krl.Mousescroll = -krl.Mousescroll
			end
			if(_MR()==0) then
				krl.Mousescroll = 0
			end
		elseif(krl.Mousescroll~=0) then
			krl:Scrollbar()
			krl.scroll[krl.Mousescroll] = math.max(0,math.min(krl.scrollMax[krl.Mousescroll],krl.MouseSclX2-(_MX()-krl.MouseSclX1)))
			krl.scroll[-krl.Mousescroll] = math.max(0,math.min(krl.scrollMax[-krl.Mousescroll],krl.MouseSclY2-(_MY()-krl.MouseSclY1)))
			if(_MR()==0) then
				krl.Mousescroll = 0
			end
		end
	end

--スクロールバーの表示
	function krl:Scrollbar()
		local bar_length_X = math.max(0.1,krl.area[krl.AppNumber]/(krl.area[krl.AppNumber]+krl.scrollMax[krl.AppNumber]))
		local bar_length_Y = math.max(0.1,krl.area[-krl.AppNumber]/(krl.area[-krl.AppNumber]+krl.scrollMax[-krl.AppNumber]))

		local bar_slide_X = (1-bar_length_X)/2*((krl.scroll[krl.AppNumber]-krl.scrollMax[krl.AppNumber]/2)/(krl.scrollMax[krl.AppNumber]/2+0.0001))*krl.area[krl.AppNumber]
		local baseX = krl.base[krl.AppNumber]+krl.area[krl.AppNumber]/2+bar_slide_X
		local baseY = krl.base[-krl.AppNumber]+krl.area[-krl.AppNumber]-3
		color(200,200,200)
		krl:MOVE2D(baseX-bar_length_X*krl.area[krl.AppNumber]/2,baseY)
		krl:LINE2D(baseX+bar_length_X*krl.area[krl.AppNumber]/2,baseY)
		color(80,80,80)
		krl:MOVE2D(baseX-bar_length_X*krl.area[krl.AppNumber]/2,baseY+1)
		krl:LINE2D(baseX+bar_length_X*krl.area[krl.AppNumber]/2,baseY+1)

		local bar_slide_Y = (1-bar_length_Y)/2*((krl.scroll[-krl.AppNumber]-krl.scrollMax[-krl.AppNumber]/2)/(krl.scrollMax[-krl.AppNumber]/2+0.0001))*krl.area[-krl.AppNumber]
		baseX = krl.base[krl.AppNumber]+krl.area[krl.AppNumber]-3
		baseY = krl.base[-krl.AppNumber]+krl.area[-krl.AppNumber]/2+bar_slide_Y
		color(200,200,200)
		krl:MOVE2D(baseX,baseY-bar_length_Y*krl.area[-krl.AppNumber]/2)
		krl:LINE2D(baseX,baseY+bar_length_Y*krl.area[-krl.AppNumber]/2)
		color(80,80,80)
		krl:MOVE2D(baseX+1,baseY-bar_length_Y*krl.area[-krl.AppNumber]/2)
		krl:LINE2D(baseX+1,baseY+bar_length_Y*krl.area[-krl.AppNumber]/2)

		color(0,0,0)
		krl:MOVE2D(krl.base[krl.AppNumber],krl.base[-krl.AppNumber])
		krl:LINE2D(krl.base[krl.AppNumber]+krl.area[krl.AppNumber],krl.base[-krl.AppNumber])
		krl:LINE2D(krl.base[krl.AppNumber]+krl.area[krl.AppNumber],krl.base[-krl.AppNumber]+krl.area[-krl.AppNumber])
		krl:LINE2D(krl.base[krl.AppNumber],krl.base[-krl.AppNumber]+krl.area[-krl.AppNumber])
		krl:LINE2D(krl.base[krl.AppNumber],krl.base[-krl.AppNumber])
	end

--システムで使うMOVE2DとLINE2D
	function krl:MOVE2D(x,y)
		x = (2/_HEIGHT())*x-_WIDTH()/_HEIGHT()
		y = (-2/_HEIGHT())*y+1
		_MOVE2D(x,y)
	end
	function krl:LINE2D(x,y)
		x = (2/_HEIGHT())*x-_WIDTH()/_HEIGHT()
		y = (-2/_HEIGHT())*y+1
		msr.lines = msr.lines +1
		_LINE2D(x,y)
	end

--アプリ上で使うMOVE2DとLINE2D
	function krl:MOVE(x,y)
		if(krl.hidden[krl.AppNumber]>0) then
			krl.Mcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]] = x
			krl.Mcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]] = y
			krl.LineContinue = -1

			x = (2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(x-krl.scroll[krl.AppNumber])*Window.line
			y = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(y-krl.scroll[-krl.AppNumber])*Window.line
			_MOVE2D(x,y)

			local diffX = x-krl.area[krl.AppNumber]
			local diffY = y-krl.area[-krl.AppNumber]
			if(diffX>krl.scrollMax[krl.AppNumber]) then
				krl.scrollMax[krl.AppNumber] = diffX
			end
			if(diffY>krl.scrollMax[-krl.AppNumber]) then
				krl.scrollMax[-krl.AppNumber] = diffY
			end
		end
	end

	function krl:LINE(x,y)
		if(krl.hidden[krl.AppNumber]>0) then
			local diffX = x-krl.area[krl.AppNumber]
			local diffY = y-krl.area[-krl.AppNumber]
			if(diffX>krl.scrollMax[krl.AppNumber]) then
				krl.scrollMax[krl.AppNumber] = diffX
			end
			if(diffY>krl.scrollMax[-krl.AppNumber]) then
				krl.scrollMax[-krl.AppNumber] = diffY
			end

			krl.Lcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]] = x
			krl.Lcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]] = y
			if(krl.LineContinue>0) then
				krl.Mcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]] = krl.Lcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]-1]
				krl.Mcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]] = krl.Lcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]+1]
			end

	--ベース座標、範囲座標、線のスタート/エンド座標の変数化
			local bx,by = krl.scroll[krl.AppNumber],krl.scroll[-krl.AppNumber]		
			local ax,ay = bx+krl.area[krl.AppNumber],by+krl.area[-krl.AppNumber]
			local spx,spy = krl.Mcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]],krl.Mcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]]
 			local epx,epy = krl.Lcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]],krl.Lcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]]
			--StartPointX,EndPointXの略
		
			local spc,epc = 0,0
			--StartPointCase,EndPointCase
			spc = krl:CaseStatement(bx,by,ax,ay,spx,spy)
			epc = krl:CaseStatement(bx,by,ax,ay,epx,epy)
			--場合わけに連続性を持たせる
			if(spc==11) then
				if(epc==18) then
					epc = 10
				elseif(epc==17) then
					epc = 9
				end
			elseif((spc==18)and(epc==11))or((spc==17)and(epc==11)) then
				epc = 19
			end

			local slope 				-- 線分の傾きを計算
			if((epx-spx)==0) then
				slope = (epy-spy)/0.0001	--傾きが0の時、エラー回避のため極小の数字を代入
			else
				slope = (epy-spy)/(epx-spx)
			end
			local intercept = spy-slope*spx		--傾きを代入

			local case_multi = spc*epc
			if(case_multi==0) then
				local APx,APy = 0,0
				if(spc==0)and(epc==0) then
					--線が両方ともwindow内にある時
					APx =(2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(krl.Lcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]]-krl.scroll[krl.AppNumber])*Window.line
					APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(krl.Lcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]]-krl.scroll[-krl.AppNumber])*Window.line
					_LINE2D(APx,APy)
					krl.LineContinue = 1
					krl.LineNum[krl.AppNumber] = krl.LineNum[krl.AppNumber] +1
					msr.lines = msr.lines +1
				else
					--線の片方がwindwo外にあるとき
					local OutPointCase = 0
					if(spc==0) then
						OutPointCase = epc
					else
						OutPointCase = spc
						spx,epx = epx,spx
						spy,epy = epy,spy
					end

					local PointCP = {}
					PointCP.LU,PointCP.RU,PointCP.RD,PointCP.LD = krl:CrossProduct(spx,spy,epx,epy)

					local case = {}
					case[11] = function()
						if(PointCP.LU>0) then
							case[18]()
						elseif(PointCP.LU<0) then
							case[12]()
						else
							APx,APy = bx,by
						end
					end
					case[12] = function()
						APy = by
						APx = (APy-intercept)/slope
					end
					case[13] = function()
						if(PointCP.RU>0) then
							case[12]()
						elseif(PointCP.RU<0) then
							case[14]()
						else
							APx,APy = ax,by
						end
					end
					case[14] = function()
						APx = ax
						APy = slope*APx+intercept
					end
					case[15] = function()
						if(PointCP.RD>0) then
							case[14]()
						elseif(PointCP.RD<0) then
							case[16]()
						else
							APx,APy = ax,ay
						end
					end
					case[16] = function()
						APy = ay
						APx = (APy-intercept)/slope
					end
					case[17] = function()
						if(PointCP.LD>0) then
							case[16]()
						elseif(PointCP.LD<0) then
							case[18]()
						else
							APx,APy = bx,by
						end
					end
					case[18] = function()
						APx = bx
						APy = slope*APx+intercept
					end

					case[OutPointCase]()

					if(OutPointCase==spc) then
						APx = (2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(APx-krl.scroll[krl.AppNumber])*Window.line
						APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(APy-krl.scroll[-krl.AppNumber])*Window.line
						_MOVE2D(APx,APy)
						APx =(2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(krl.Lcoordinates[krl.AppNumber][krl.LineNum[krl.AppNumber]]-krl.scroll[krl.AppNumber])*Window.line
						APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(krl.Lcoordinates[krl.AppNumber][-krl.LineNum[krl.AppNumber]]-krl.scroll[-krl.AppNumber])*Window.line
						_LINE2D(APx,APy)
						msr.lines = msr.lines +1	
					else
						APx =(2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(APx-krl.scroll[krl.AppNumber])*Window.line
						APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(APy-krl.scroll[-krl.AppNumber])*Window.line
						_LINE2D(APx,APy)
						msr.lines = msr.lines +1
					end
					krl.LineContinue = 1
					krl.LineNum[krl.AppNumber] = krl.LineNum[krl.AppNumber] +1	
				end		
			else
				--線が同じ象限にいるとき
				if(spc==epc) then
					--何も記述しない

				elseif((math.mod(spc,2)==0)and((epc~=spc+1)and(epc~=spc-1)))or(((math.mod(spc,2)==1)and((spc-2>=epc)or(epc>=spc+2)))) then
					--線の始点と終点の両方がwindow外にあるとき
					--始点を中心としたL字型の象限にいる時に実行
					local PointCP = {}
					PointCP[1],PointCP[2],PointCP[3],PointCP[4] = krl:CrossProduct(spx,spy,epx,epy)
					PointCP[5] = PointCP[1]

					local PointCoordinates = {}
					local PointMove = 1

					local case = {}
					case[1] = function()
						PointCoordinates[-PointMove] = by
						PointCoordinates[PointMove] = (by-intercept)/slope
					end			
					case[2] = function()
						PointCoordinates[PointMove]  = ax
						PointCoordinates[-PointMove]  = slope*ax+intercept
					end			
					case[3] = function()
						PointCoordinates[-PointMove] = ay
						PointCoordinates[PointMove] = (ay-intercept)/slope
					end			
					case[4] = function()
						PointCoordinates[PointMove]  = bx
						PointCoordinates[-PointMove]  = slope*bx+intercept
					end
					case[5] = function()
						PointCoordinates[PointMove]  = bx
						PointCoordinates[-PointMove]  = by
					end
					case[6] = function()
						PointCoordinates[PointMove]  = ax
						PointCoordinates[-PointMove]  = by
					end
					case[7] = function()
						PointCoordinates[PointMove]  = ax
						PointCoordinates[-PointMove]  = ay
					end
					case[8] = function()
						PointCoordinates[PointMove]  = bx
						PointCoordinates[-PointMove]  = ay
					end		

					for i=1,4,1 do
						local PointSymbol = 0
						PointSymbol = PointCP[i]*PointCP[i+1]
						if(PointSymbol<0) then
							case[i]()
							PointMove = PointMove +1
						elseif(PointSymbol==0) then
							if(PointCP[i]==0) then
								case[i+4]()
								PointMove = PointMove +1
							end
						end
					end
				
					if(PointMove~=1) then
						if(PointCoordinates[1]~=NULL)and(PointCoordinates[-1]~=NULL)and(PointCoordinates[2]~=NULL)and(PointCoordinates[-2]~=NULL) then
							local APx,APy = 0,0
							APx =(2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(PointCoordinates[1]-krl.scroll[krl.AppNumber])*Window.line
							APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(PointCoordinates[-1]-krl.scroll[-krl.AppNumber])*Window.line
							_MOVE2D(APx,APy)
							APx =(2/_HEIGHT())*krl.base[krl.AppNumber]-_WIDTH()/_HEIGHT()+(PointCoordinates[2]-krl.scroll[krl.AppNumber])*Window.line
							APy = (-2/_HEIGHT())*krl.base[-krl.AppNumber]+1-(PointCoordinates[-2]-krl.scroll[-krl.AppNumber])*Window.line
							_LINE2D(APx,APy)
							msr.lines = msr.lines +1
						end
					end
				end

				krl.LineContinue = 1
				krl.LineNum[krl.AppNumber] = krl.LineNum[krl.AppNumber] +1
			end
		end
	end

--線分の位置によるケースわけ
	function krl:CaseStatement(bx,by,ax,ay,x,y)
		local case = 0
		if(x<=bx) then
			if(y<=by) then
				case = 11
			elseif(y<=ay) then
				case = 18
			elseif(ay<=y) then
				case = 17
			end
		elseif(x<=ax) then
			if(y<=by) then
				case = 12
			elseif(y<=ay) then
				case = 0
			elseif(ay<=y) then
				case = 16
			end
		elseif(ax<=x) then
			if(y<=by) then
				case = 13
			elseif(y<=ay) then
				case = 14
			elseif(ay<=y) then
				case = 15
			end
		end
		return case
	end

--内積を使って線分PQがwindow枠の左右どちらにいるのかを判定
	function krl:CrossProduct(Px,Py,Qx,Qy)
		local dicision = {}
		local AreaPoint = {}
		AreaPoint[1],AreaPoint[-1] = krl.scroll[krl.AppNumber],krl.scroll[-krl.AppNumber]
		AreaPoint[2],AreaPoint[-2] = krl.scroll[krl.AppNumber]+krl.area[krl.AppNumber],krl.scroll[-krl.AppNumber]
		AreaPoint[3],AreaPoint[-3] = krl.scroll[krl.AppNumber]+krl.area[krl.AppNumber],krl.scroll[-krl.AppNumber]+krl.area[-krl.AppNumber]
		AreaPoint[4],AreaPoint[-4] = krl.scroll[krl.AppNumber],krl.scroll[-krl.AppNumber]+krl.area[-krl.AppNumber]
		local PQx,PQy = Qx-Px,Qy-Py
		for i=1,4,1 do
			local PAx,PAy = AreaPoint[i]-Px,AreaPoint[-i]-Py

			dicision[i] = PQx*PAy-PQy*PAx
		end

		return dicision[1],dicision[2],dicision[3],dicision[4]
	end

--KRILE用にDrawCharを改変
	Spell.krlDrawChar = function(x,y,st,size,s,c,scale,font)
		font = font or PathData
		if font[st]==nil then return end
		scale = scale or 1
		s,c = s or 0,c or 1
		local mode = 0
		local tx,ty
		for i=1,table.getn(font[st]) do
			if font[st][i] == "M" then
				mode = 0
			elseif font[st][i] == "L" then
				mode = 1
			else
				tx,ty = font[st][i][2]*scale,font[st][i][1]
				if mode == 0 then
					krl:MOVE(x+size*(tx*c+ty*s),y+size*(ty*c-tx*s))
					mode = 1
				else
					krl:LINE(x+size*(tx*c+ty*s),y+size*(ty*c-tx*s))
					
				end
			end
		end
	end

	Spell.krlDrawSentence = function(self,x,y,size,font)

		font = font or PathData
		local l = 0
		local px = self.distance
		local tmp
		for i=1,table.getn(self.chars) do
			tmp = (1-font[self.chars[i]][0])/2 * size
			l = l - tmp
			Spell.krlDrawChar(x+l*self.c , y+l*self.s , self.chars[i] , size , self.s,self.c,1,font)
			l = l + tmp + font[self.chars[i]][0]*size + px
		end
	end

--KRILEのシステム用に使うクリック判定(click)
)
	function krl:SystemClick(type,bx,by,ax,ay)
		if(msr.power>0)and(_MX()<=200) then
			return 0
		elseif(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
			if(type=="R") then
				return _MR()
			elseif(type=="L") then
				return _ML()
			else
				return _MM()
			end
		else
			return 0
		end
	end

--KRILEのシステム用に使うクリック判定（DOWN）
	function krl:SystemClickDown(type,bx,by,ax,ay)
		if(msr.power>0)and(_MX()<=200) then
			return 0
		elseif(type=="R") then
			if(msr.mousedownR==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="L") then
			if(msr.mousedownL==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="M") then
			if(msr.mousedownM==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		end
	end

--KRILEシステム用に使うクリック判定（up)
	function krl:SystemClickUp(type,bx,by,ax,ay)
		if(msr.power>0)and(_MX()<=200) then
			return 0
		elseif(type=="R") then
			if(msr.mouseupR==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="L") then
			if(msr.mouseupL==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		elseif(type=="M") then
			if(msr.mouseupM==1)and(_MX()<ax)and(_MX()>bx)and(_MY()<ay)and(_MY()>by) then
				return 1
			else
				return 0
			end
		end
	end


--KRILEのアプリで使うclick
	function krl:Click(type,bx,by,ax,ay)
		if(krl.layer[krl.AppNumber]==1) then
			local mx = _MX()-krl.base[krl.AppNumber]+krl.scroll[krl.AppNumber]
			local my = _MY()-krl.base[-krl.AppNumber]+krl.scroll[-krl.AppNumber]
		
			ax = bx + ax
			ay = by + ay

			local bx2 = krl.scroll[krl.AppNumber]
			local ax2 = krl.scroll[krl.AppNumber]+krl.area[krl.AppNumber]
			local by2 = krl.scroll[-krl.AppNumber]
			local ay2 = krl.scroll[-krl.AppNumber]+krl.area[-krl.AppNumber]

			if(msr.power>0)and(_MX()<=200) then
				return 0
			elseif(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
				if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
					if(type=="R") then
						return _MR()
					elseif(type=="L") then
						return _ML()
					else
						return _MM()
					end
				else
					return 0
				end
			else
				return 0
			end
		end
	end


--KRILEのアプリで使うクリック判定(DOWN)
	function krl:ClickDown(type,bx,by,ax,ay)
		if(krl.layer[krl.AppNumber]==1) then
			local mx = _MX()-krl.base[krl.AppNumber]+krl.scroll[krl.AppNumber]
			local my = _MY()-krl.base[-krl.AppNumber]+krl.scroll[-krl.AppNumber]
		
			ax = bx + ax
			ay = by + ay

			local bx2 = krl.scroll[krl.AppNumber]
			local ax2 = krl.scroll[krl.AppNumber]+krl.area[krl.AppNumber]
			local by2 = krl.scroll[-krl.AppNumber]
			local ay2 = krl.scroll[-krl.AppNumber]+krl.area[-krl.AppNumber]

			if(msr.power>0)and(_MX()<=200) then
				return 0
			elseif(type=="R") then
				if(msr.mousedownR==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			elseif(type=="L") then
				if(msr.mousedownL==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			elseif(type=="M") then
				if(msr.mousedownM==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			end
		end
	end


--KRILEのアプリで使うクリック判定(UP)
	function krl:ClickUp(type,bx,by,ax,ay)
		if(krl.layer[krl.AppNumber]==1) then
			local mx = _MX()-krl.base[krl.AppNumber]+krl.scroll[krl.AppNumber]
			local my = _MY()-krl.base[-krl.AppNumber]+krl.scroll[-krl.AppNumber]
		
			ax = bx + ax
			ay = by + ay

			local bx2 = krl.scroll[krl.AppNumber]
			local ax2 = krl.scroll[krl.AppNumber]+krl.area[krl.AppNumber]
			local by2 = krl.scroll[-krl.AppNumber]
			local ay2 = krl.scroll[-krl.AppNumber]+krl.area[-krl.AppNumber]
			if(msr.power>0)and(_MX()<=200) then
				return 0
			elseif(type=="R") then
				if(msr.mouseupR==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			elseif(type=="L") then
				if(msr.mouseupL==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			elseif(type=="M") then
				if(msr.mouseupM==1)and(mx<ax)and(mx>bx)and(my<ay)and(my>by) then
					if(mx<ax2)and(mx>bx2)and(my<ay2)and(my>by2) then
						return 1
					else
						return 0
					end
				else
					return 0
				end
			end
		end
	end

--ボタンの生成
	function krl.button:new(bx,by,ax,ay)
		local self = {}
		self.bx = bx
		self.by = by
		self.ax = ax
		self.ay = ay
		setmetatable(self,{__index = krl.button})
		return self
	end
--ボタンの描画
	function krl.button:draw(type)
		if(type==NULL) then type = "L" end

		local mx = _MX()-krl.base[krl.AppNumber]+krl.scroll[krl.AppNumber]
		local my = _MY()-krl.base[-krl.AppNumber]+krl.scroll[-krl.AppNumber]

		if(krl:Click(type,self.bx,self.by,self.ax,self.ay)==1) then
			color(130,130,130)
			krl:MOVE(self.bx+self.ax-1,self.by+1)
			krl:LINE(self.bx+1,self.by+1)
			krl:LINE(self.bx+1,self.ay+self.by-1)
			color(200,200,200)
			krl:MOVE(self.bx+self.ax-2,self.by+2)
			krl:LINE(self.bx+2,self.by+2)
			krl:LINE(self.bx+2,self.ay+self.by-2)
		else
			color(130,130,130)
			krl:MOVE(self.bx+self.ax-1,self.by+1)
			krl:LINE(self.bx+self.ax-1,self.by+self.ay-1)
			krl:LINE(self.bx+1,self.ay+self.by-1)
			color(200,200,200)
			krl:MOVE(self.bx+self.ax-2,self.by+2)
			krl:LINE(self.bx+self.ax-2,self.by+self.ay-2)
			krl:LINE(self.bx+2,self.ay+self.by-2)
		end
		color(0,0,0)
		krl:MOVE(self.bx,self.by)
		krl:LINE(self.bx+self.ax,self.by)
		krl:LINE(self.bx+self.ax,self.by+self.ay)
		krl:LINE(self.bx,self.by+self.ay)
		krl:LINE(self.bx,self.by)
	end

--ボタンが押されたかの判定制御
	function krl.button:click(type)
		local judge = 0
		if(krl.Mousescroll<=0)and(krl.Mousescale==0) then
			judge = krl:Click(type,self.bx,self.by,self.ax,self.ay)
		end
		return judge
	end
	function krl.button:clickdown(type)
		local judge = 0
		if(krl.Mousescroll<=0)and(krl.Mousescale==0) then
			judge = krl:ClickDown(type,self.bx,self.by,self.ax,self.ay)
		end
		return judge
	end
	function krl.button:clickup(type)
		local judge = 0
		if(krl.Mousescroll<=0)and(krl.Mousescale==0) then
			local judge = krl:ClickUp(type,self.bx,self.by,self.ax,self.ay)
		end
		return judge
	end

--ボタンの描画
	function krl.button:MOVE(buttonX,buttonY,type)
		if(type==NULL) then type = "L" end
		buttonX = buttonX + self.bx
		buttonY = buttonY + self.by
		if(krl:Click(type,self.bx,self.by,self.ax,self.ay)==1) then
			buttonX = buttonX +1
			buttonY = buttonY +1
		end
		krl:MOVE(buttonX,buttonY)
	end

	function krl.button:LINE(buttonX,buttonY,type)
		if(type==NULL) then type = "L" end
		buttonX = buttonX + self.bx
		buttonY = buttonY + self.by
		if(krl:Click(type,self.bx,self.by,self.ax,self.ay)==1) then
			buttonX = buttonX +1
			buttonY = buttonY +1
		end
		krl:LINE(buttonX,buttonY)
	end

--KRILEメイン部分
	function msr:Krile()
		if(krl.setting==0) then
			for i=1,krl.List,1 do
				krl.call[i] = -1
				krl.hidden[i] = 1
				if(krl.base[i]==NULL) then	krl.base[i] = _WIDTH()/2+(i-1)*30  -150		end	--�s�N�Z���w��
				if(krl.base[-i]==NULL) then	krl.base[-i] = _HEIGHT()/2+(i-1)*30 -150	end
				if(krl.scroll[i]==NULL) then	krl.scroll[i] = 0		end
				if(krl.scroll[-i]==NULL) then	krl.scroll[-i] = 0		end
				if(krl.area[i]==NULL) then	krl.area[i] = 175		end
				if(krl.area[-i]==NULL) then	krl.area[-i] = 175		end
				krl.scrollMax[i] = 0
				krl.scrollMax[-i] = 0	
				krl.layer[i] = i
				krl.LineNum[i] = 1
				krl.Mcoordinates[i] = {}
				krl.Lcoordinates[i] = {}
				msr.krile = msr.krile +20
			end
			krl.setting = 1
		end

		color(50,50,50)
		msr:MOVE(msr.left,1-20*Window.line)	msr:LINE(msr.left+msr.width,1-20*Window.line)

		local click = msr:click("L",15,0,200,20)
		if(click==1) then
			for i=1,5,1 do
				color(50+20*i,50+20*i,50+20*i)
				msr:MOVE(msr.left,1-i*Window.line)
				msr:LINE(msr.left+msr.width,1-i*Window.line)
			end
		else
			color(130,130,130)
			msr:MOVE(msr.left,1-19*Window.line)
			msr:LINE(msr.left+msr.width,1-19*Window.line)
			msr:MOVE(msr.left,1-21*Window.line)
			msr:LINE(msr.left+msr.width,1-21*Window.line)
		end
		
		--KRILEの名前描画
		color(61,1,255)
		mozi = Spell.new("KRILE")
		--mozi:DrawSentence2(msr.left+msr.width-(100-click)*Window.line-mozi:Width(Window.line*10)/2,1-(5+1*click)*Window.line,Window.line*10)
		mozi:DrawSentence2(msr.left+msr.width-(190-click)*Window.line,1-(5+1*click)*Window.line,Window.line*10)
		--アプリのリストを表示
		for i=1,krl.List,1 do
			color(50,50,50)
			msr:MOVE(msr.left+msr.width-185*Window.line,1-(20*(i+1)*Window.line))	msr:LINE(msr.left+msr.width,1-(20*(i+1)*Window.line))
			msr:MOVE(msr.left+msr.width-185*Window.line,1-(20*i*Window.line))	msr:LINE(msr.left+msr.width-185*Window.line,1-(20*(i+1)*Window.line))

			click = msr:click("L",0,i*20,170,(i+1)*20)
			if(click==1) then
				for j=1,5,1 do
					color(50+20*j,50+20*j,50+20*j)
					msr:MOVE(msr.left+msr.width-(185-j)*Window.line,1-(20*i+j)*Window.line)
					msr:LINE(msr.left+msr.width-30*Window.line,1-(20*i+j)*Window.line)
					msr:MOVE(msr.left+msr.width-(185-j)*Window.line,1-((20*i+(j-1))*Window.line))
					msr:LINE(msr.left+msr.width-(185-j)*Window.line,1-(20*(i+1)*Window.line))
				end
			else
				color(130,130,130)
				msr:MOVE(msr.left+msr.width-185*Window.line,1-(20+20*i-1)*Window.line)
				msr:LINE(msr.left+msr.width-30*Window.line,1-(20+20*i-1)*Window.line)
				msr:MOVE(msr.left+msr.width-185*Window.line,1-(20+20*i+1)*Window.line)
				msr:LINE(msr.left+msr.width-30*Window.line,1-(20+20*i+1)*Window.line)
			end
			color(50,50,50)
			msr:MOVE(msr.left+msr.width-185*Window.line,1-(20*i*Window.line))	msr:LINE(msr.left+msr.width-185*Window.line,1-(20*(i+1)*Window.line))

			local NAME = Spell.new(krl.Name[i])
			NAME:DrawSentence2(msr.left+msr.width-(180-click)*Window.line,1-(20*i+6+click)*Window.line,Window.line*8)

			if(krl.layer[i]==1) then
				msr:MOVE(msr.left+msr.width-197*Window.line,1-(20+20*i-4)*Window.line)
				msr:LINE(msr.left+msr.width-197*Window.line,1-(20+20*i-16)*Window.line)
				msr:LINE(msr.left+msr.width-188*Window.line,1-(20+20*i-10)*Window.line)
				msr:LINE(msr.left+msr.width-197*Window.line,1-(20+20*i-4)*Window.line)
			end

	--アプリ名がクリックされた時に、そのアプリを起動
			if(msr:clickup("L",15,20*i,170,20*i+20)==1) then
				if(krl.call[i]>0) then
					if(krl.layer[i]~=1) then
						for p=1,krl.layer[i]-1,1 do
							for  q=1,krl.List,1 do
								if(krl.layer[q]==(krl.layer[i]-1)) then
									krl.layer[q],krl.layer[i] = krl.layer[i],krl.layer[q]
								end
							end
						end
						if(krl.hidden[i]<0) then 
							krl.hidden[i]=1
						end
					else	
						krl.hidden[i] = -krl.hidden[i]
					end
				end
			end

	--クリックされた時に凹んだように見せる
			click = msr:click("L",170,i*20,200,(i+1)*20)
			if(click==1) then
				for j=1,5,1 do
					color(50+20*j,50+20*j,50+20*j)
					msr:MOVE(msr.left+msr.width-(31-j)*Window.line,1-(20*i+j)*Window.line)
					msr:LINE(msr.left+msr.width,1-(20*i+j)*Window.line)
					msr:MOVE(msr.left+msr.width-(31-j)*Window.line,1-((20*i+(j-1))*Window.line))
					msr:LINE(msr.left+msr.width-(31-j)*Window.line,1-(20*(i+1)*Window.line))
				end
			else
				color(130,130,130)
				msr:MOVE(msr.left+msr.width-30*Window.line,1-(20+20*i-1)*Window.line)
				msr:LINE(msr.left+msr.width,1-(20+20*i-1)*Window.line)
				msr:MOVE(msr.left+msr.width-30*Window.line,1-(20+20*i+1)*Window.line)
				msr:LINE(msr.left+msr.width,1-(20+20*i+1)*Window.line)
			end

			color(50,50,50)
			msr:MOVE(msr.left+msr.width-30*Window.line,1-(20*i*Window.line))
			msr:LINE(msr.left+msr.width-30*Window.line,1-(20*(i+1))*Window.line)
			if(krl.call[i]==1)  then
				color(255,224,145)
			else
				color(200,200,200)	
			end
			msr:MOVE(msr.left+msr.width-(15-click)*Window.line,1-(20+20*i-17+click)*Window.line)
			msr:LINE(msr.left+msr.width-(15-click)*Window.line,1-(20+20*i-9+click)*Window.line)
			local deg = math.rad(300/10)
			local rad = 6
			msr:MOVE(msr.left+msr.width-(15-math.sin(deg*2)*rad-click)*Window.line,1-(20+20*i-10-math.cos(deg*2)*rad+click)*Window.line)
			for p=3,10,1 do
				msr:LINE(msr.left+msr.width-(15-math.sin(deg*p)*rad-click)*Window.line,1-(20+20*i-10-math.cos(deg*p)*rad+click)*Window.line)
			end
			if(msr:clickup("L",170,20*i,200,20*i+20)==1) then
				krl.call[i] = -krl.call[i]
				if(krl.call[i]>0) then
					if(krl.layer[i]~=1) then
						for p=1,krl.layer[i]-1,1 do
							for  q=1,krl.List,1 do
								if(krl.layer[q]==(krl.layer[i]-1)) then
									krl.layer[q],krl.layer[i] = krl.layer[i],krl.layer[q]
								end
							end
						end
						if(krl.hidden[i]<0) then 
							krl.hidden[i]=1
						end
					end
				end
			end
		end

	end
----------------------------GUIシステム　KRILE ここまで---------------------------

----------------------------ネットワークシステム　MIYURI　ここから---------------------------
--MIYURI用変数準備
	myr = {}
	myr.version = "1.0"
	myr.cam_reset = 0
	myr.id = {}
	myr.player_number = 0
	myr.target_number = 0
	myr.target_id = 0

--最初は自分をターゲットにしておく
	if(_PLAYERS()~=0) then
		myr.target_id=_PLAYERMYID()
	end

--ネットワーク変数の更新
	function myr:id_Update()
		if(myr.player_number~=_PLAYERS()) then
			myr.player_number = _PLAYERS()
			for i=0,myr.player_number,1 do
				myr.id[i] = _PLAYERID(i)
			end
		end
	end

--ターゲットidが異なる（＝誰か抜けたりした）時の制御
	function myr:target_checker()	
		if(myr.target_id~=myr.id[myr.target_number]) then
			local counter = 0
			for i=0,myr.player_number,1 do
				if(myr.target_id==myr.id[i]) then
					myr.target_number = i
				else
					counter = counter +1
				end
			end
			if(counter==myr.player_number+1) then
				myr.target_number = 0
				myr.target_id = _PLAYERID(0)
			end
		end
	end

--MASHIRO上の描画
	function myr:drawing()
		local baseY = msr.krile

		color(0,0,0)
		msr:MOVE(msr.left,1-(baseY)*Window.line)
		msr:LINE(msr.left+msr.width,1-(baseY)*Window.line)
		msr:MOVE(msr.left,1-(baseY+20)*Window.line)
		msr:LINE(msr.left+msr.width,1-(baseY+20)*Window.line)

		local click = msr:click("L",0,baseY,200,baseY+20)

		if(click==1) then
			for j=1,5,1 do
				color(50+20*j,50+20*j,50+20*j)
				msr:MOVE(msr.left,1-(baseY+j)*Window.line)
				msr:LINE(msr.left+msr.width,1-(baseY+j)*Window.line)
			end
		else
			color(130,130,130)
			msr:MOVE(msr.left,1-(baseY-1)*Window.line)
			msr:LINE(msr.left+msr.width-185*Window.line,1-(baseY-1)*Window.line)
			msr:MOVE(msr.left,1-(baseY+1)*Window.line)
			msr:LINE(msr.left+msr.width,1-(baseY+1)*Window.line)
			msr:MOVE(msr.left,1-(baseY+20-1)*Window.line)
			msr:LINE(msr.left+msr.width,1-(baseY+20-1)*Window.line)
			msr:MOVE(msr.left,1-(baseY+20+1)*Window.line)
			msr:LINE(msr.left+msr.width,1-(baseY+20+1)*Window.line)
		end

		color(61,1,255)
		mozi = Spell.new("NETWORK")
		mozi:DrawSentence2(msr.left+msr.width-(190-click)*Window.line,1-(baseY+5+1*click)*Window.line,Window.line*10)

		color(30,30,30)
		mozi = Spell.new("STATUS")
		mozi:DrawSentence2(msr.left+msr.width-(180)*Window.line,1-(baseY+26)*Window.line,Window.line*8)
		if(_PLAYERS()==0) then
			color(237,26,61)
			mozi = Spell.new("OFFLINE")
		else
			color(152,255,31)
			mozi = Spell.new("ONLINE")
		end
		mozi:DrawSentence2(msr.left+msr.width-(80)*Window.line,1-(baseY+26)*Window.line,Window.line*8)

		if(_PLAYERS()~=0) then
			color(30,30,30)
			mozi = Spell.new("PLAYERS")
			mozi:DrawSentence2(msr.left+msr.width-(180)*Window.line,1-(baseY+46)*Window.line,Window.line*8)
			local players = string.format("%d",_PLAYERS())
			color(61,1,255)
			mozi = Spell.new(players)
			mozi:DrawSentence2(msr.left+msr.width-(50)*Window.line,1-(baseY+46)*Window.line,Window.line*8)
			
			for i=0,_PLAYERS()-1,1 do
	--ARM有無の表示
				if(_PLAYERARMS(i)==0) then
					color(200,200,200)
				else
					color(180,0,0)
				end
				msr:MOVE(msr.left+msr.width-(160)*Window.line,1-(baseY+60+20*i+5)*Window.line)
				msr:LINE(msr.left+msr.width-(160)*Window.line,1-(baseY+60+20*i+15)*Window.line)
				msr:LINE(msr.left+msr.width-(150)*Window.line,1-(baseY+60+20*i+15)*Window.line)
				msr:LINE(msr.left+msr.width-(150)*Window.line,1-(baseY+60+20*i+5)*Window.line)
				msr:LINE(msr.left+msr.width-(153)*Window.line,1-(baseY+60+20*i+9)*Window.line)
				msr:LINE(msr.left+msr.width-(157)*Window.line,1-(baseY+60+20*i+9)*Window.line)
				msr:LINE(msr.left+msr.width-(160)*Window.line,1-(baseY+60+20*i+5)*Window.line)
				msr:MOVE(msr.left+msr.width-(153)*Window.line,1-(baseY+60+20*i+11)*Window.line)
				msr:LINE(msr.left+msr.width-(157)*Window.line,1-(baseY+60+20*i+11)*Window.line)

	--プレイヤーの名前の表示　プレイヤーの色を取得してその色にする
				_SETCOLOR(_PLAYERCOLOR(i))
				mozi = Spell.new(_PLAYERNAME(i))
				if(_PLAYERID(i)==_PLAYERMYID()) then
					mozi:DrawSentence2(msr.left+msr.width-(140)*Window.line,1-(baseY+66+20*i)*Window.line,Window.line*8)
				else
					mozi:DrawSentence2(msr.left+msr.width-(130)*Window.line,1-(baseY+66+20*i)*Window.line,Window.line*8)
				end

	--名前をクリックした時、押されたように描画する
				click = msr:click("L",155,baseY+60+20*i+2,191,baseY+60+20*i+18)

				if(click==1) then
					for j=1,3,1 do
						color(50+30*j,50+30*j,50+30*j)
						msr:MOVE(msr.left+msr.width-(45-j)*Window.line,1-(baseY+60+20*i+2+j)*Window.line)
						msr:LINE(msr.left+msr.width-(45-j)*Window.line,1-(baseY+60+20*i+18)*Window.line)
						msr:MOVE(msr.left+msr.width-(45-j)*Window.line,1-(baseY+60+20*i+2+j)*Window.line)
						msr:LINE(msr.left+msr.width-(9)*Window.line,1-(baseY+60+20*i+2+j)*Window.line)
					end
				else
					color(130,130,130)
					msr:MOVE(msr.left+msr.width-(46)*Window.line,1-(baseY+60+20*i+1)*Window.line)
					msr:LINE(msr.left+msr.width-(46)*Window.line,1-(baseY+60+20*i+19)*Window.line)
					msr:LINE(msr.left+msr.width-(8)*Window.line,1-(baseY+60+20*i+19)*Window.line)
					msr:LINE(msr.left+msr.width-(8)*Window.line,1-(baseY+60+20*i+1)*Window.line)
					msr:LINE(msr.left+msr.width-(46)*Window.line,1-(baseY+60+20*i+1)*Window.line)
				end
				
				if(i==myr.target_number) then
					color(255,224,125)
				else
					color(200,200,200)
				end
				msr:MOVE(msr.left+msr.width-(40-click)*Window.line,1-(baseY+60+20*i+5+click)*Window.line)
				msr:LINE(msr.left+msr.width-(40-click)*Window.line,1-(baseY+60+20*i+15+click)*Window.line)
				msr:LINE(msr.left+msr.width-(25-click)*Window.line,1-(baseY+60+20*i+15+click)*Window.line)
				msr:LINE(msr.left+msr.width-(25-click)*Window.line,1-(baseY+60+20*i+5+click)*Window.line)
				msr:LINE(msr.left+msr.width-(40-click)*Window.line,1-(baseY+60+20*i+5+click)*Window.line)
				msr:MOVE(msr.left+msr.width-(38-click)*Window.line,1-(baseY+60+20*i+7+click)*Window.line)
				msr:LINE(msr.left+msr.width-(38-click)*Window.line,1-(baseY+60+20*i+13+click)*Window.line)
				msr:LINE(msr.left+msr.width-(35-click)*Window.line,1-(baseY+60+20*i+13+click)*Window.line)
				msr:LINE(msr.left+msr.width-(35-click)*Window.line,1-(baseY+60+20*i+7+click)*Window.line)
				msr:LINE(msr.left+msr.width-(38-click)*Window.line,1-(baseY+60+20*i+7+click)*Window.line)
				msr:MOVE(msr.left+msr.width-(22-click)*Window.line,1-(baseY+60+20*i+8+click)*Window.line)
				msr:LINE(msr.left+msr.width-(22-click)*Window.line,1-(baseY+60+20*i+12+click)*Window.line)
				msr:LINE(msr.left+msr.width-(19-click)*Window.line,1-(baseY+60+20*i+12+click)*Window.line)
				msr:LINE(msr.left+msr.width-(16-click)*Window.line,1-(baseY+60+20*i+15+click)*Window.line)
				msr:LINE(msr.left+msr.width-(14-click)*Window.line,1-(baseY+60+20*i+15+click)*Window.line)
				msr:LINE(msr.left+msr.width-(14-click)*Window.line,1-(baseY+60+20*i+5+click)*Window.line)
				msr:LINE(msr.left+msr.width-(16-click)*Window.line,1-(baseY+60+20*i+5+click)*Window.line)
				msr:LINE(msr.left+msr.width-(19-click)*Window.line,1-(baseY+60+20*i+8+click)*Window.line)
				msr:LINE(msr.left+msr.width-(22-click)*Window.line,1-(baseY+60+20*i+8+click)*Window.line)

				color(30,30,30)
				msr:MOVE(msr.left+msr.width-(45)*Window.line,1-(baseY+60+20*i+2)*Window.line)
				msr:LINE(msr.left+msr.width-(45)*Window.line,1-(baseY+60+20*i+18)*Window.line)
				msr:LINE(msr.left+msr.width-(9)*Window.line,1-(baseY+60+20*i+18)*Window.line)
				msr:LINE(msr.left+msr.width-(9)*Window.line,1-(baseY+60+20*i+2)*Window.line)
				msr:LINE(msr.left+msr.width-(45)*Window.line,1-(baseY+60+20*i+2)*Window.line)
				
				if(msr:clickup("L",155,baseY+60+20*i+2,191,baseY+60+20*i+18)==1) then
						myr.target_number = i
						myr.target_id = _PLAYERID(i)
						if(myr.target_id==_PLAYERMYID()) then
							myr.cam_reset = 1
						end
				end
			end

		end
	end
--MIYURIメイン
	function msr:Miyuri()
		myr:drawing()

	--オフラインの時は全ての変数をリセット
		if(_PLAYERS()==0) then
				myr.cam_reset = 0
				myr.player_number = 0
				myr.target_number = 0
				myr.target_id = 0
				for i=1,30,1 do
					myr.id[i] = 0
				end
		else
			myr:id_Update()	
			myr:target_checker()
			--チェックしてもtarget_idが0になる時は自分をターゲットにしてエラー回避
			if(myr.target_id==0) then
				myr.target_id=_PLAYERMYID()
				myr.cam_reset = 1
			end
		end
	end

--ノイズキャンセラー
--悪用厳禁！
	function target_axis(num)
		if _PLAYERID(num)==_PLAYERMYID() then return _X(),_Y(),_Z() end
		
		local rx,ry,rz
		if type(_NTICKS)=="function" then	
		
			local sf=(_PLAYERCHIPS(num)^(1/3))*0.5
			local nt=_NTICKS()
			math.randomseed(7644)
			rx=_PLAYERX(num)
			
		
			local sn = math.sin(nt/350) * sf
		
			rx=rx+sn - math.sin(nt/150) * sf
		
			math.randomseed(7644)
			ry=_PLAYERY(num)
		
			local sn = math.sin(nt/360) * sf
		
			ry=ry+sn- math.sin(nt/160) * sf
		
			math.randomseed(7644)
			rz=_PLAYERZ(num)
		
			local sn = math.sin(nt/340) * sf
		
			rz=rz+sn- math.sin(nt/140) * sf
		else
		
			math.randomseed(1519)
			rx=_PLAYERX(num)
			
			math.randomseed(1519)
			ry=_PLAYERY(num)
			
			math.randomseed(1519)
			rz=_PLAYERZ(num)
		end
		
		return rx,ry,rz	
	end


----------------------------ネットワークシステム　MIYURI ここまで----------------------------
