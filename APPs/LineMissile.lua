krl.List = krl.List +1
-------触るな危険-------

LM = {}
LM.cn = 1
LM.chip = {}

LM.vel = 0.8
LM.num = 1
LM.lo_count = {}
LM.use = {}
LM.locus = {}
LM.x,LM.y,LM.z = {},{},{}
LM.tx,LM.ty,LM.tz = {},{},{}
LM.vx,LM.vy,LM.vz = {},{},{} 
LM.maxnum = 100

for i=0,_CHIPS(),1 do
	if(_TYPE(i)==10)and(_USER2(i)==1) then
		LM.chip[LM.cn] = i
		LM.cn = LM.cn +1
	end		
end
for i=1,LM.maxnum,1 do
	LM.use[i] = 0
	LM.locus[i] = {}
	for j=0,20,1 do
		LM.locus[i][j]={}
	end
	LM.lo_count[i] = 0
end


function LineMissile()
--[[
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
]]--
	for i=1,LM.cn-1,1 do
		if(_USER1(LM.chip[i])==1) then
			local count = 1
			if(LM.use[LM.num]==0) then
				LM:missile_set(LM.num,i)
				LM.num = LM.num +1
				if(LM.num==(missile_num+1)) then LM.num=1 end
			else
				LM.num = LM.num +1
				if(LM.num==(missile_num+1)) then LM.num=1 end
				count = count +1
				if(LM.use[LM.num]==0) then
					LM:missile_set(LM.num,i)
				end
				if(count==LM.maxnum) then
					break
				end
			end
		end
	end

	for i=1,LM.maxnum,1 do
		if(LM.use[i]==1) then
			local k= 0.1
			LM.tx[i],LM.ty[i],LM.tz[i] = _OX(0),_OY(0),_OZ(0)

			tgt = {}
			tgt.x = LM.tx[i]-LM.x[i]
			tgt.y = LM.ty[i]-LM.y[i]
			tgt.z = LM.tz[i]-LM.z[i]

			tgt.len = math.sqrt(tgt.x^2+tgt.y^2+tgt.z^2)
			tgt.x = tgt.x / tgt.len
			tgt.y = tgt.y / tgt.len
			tgt.z = tgt.z / tgt.len

			LM.vx[i] = (1-k)*LM.vx[i] + tgt.x*k
			LM.vy[i] = (1-k)*LM.vy[i] + tgt.y*k
			LM.vz[i] = (1-k)*LM.vz[i] + tgt.z*k

			LM.len = math.sqrt(LM.vx[i]^2+LM.vy[i]^2+LM.vz[i]^2)
			LM.vx[i] = LM.vx[i] / LM.len
			LM.vy[i] = LM.vy[i] / LM.len
			LM.vz[i] = LM.vz[i] / LM.len

			LM.x[i] = LM.x[i] +LM.vx[i] *LM.vel
			LM.y[i] = LM.y[i] +LM.vy[i] *LM.vel
			LM.z[i] = LM.z[i] +LM.vz[i] *LM.vel

			color(0,0,0)
			_MOVE3D(LM.x[i],LM.y[i],LM.z[i])
			_LINE3D(LM.x[i]-LM.vx[i]*0.2,LM.y[i]-LM.vy[i]*0.2,LM.z[i]-LM.vz[i]*0.2)
			color(150,150,150)
			_LINE3D(LM.x[i]-LM.vx[i]*0.5,LM.y[i]-LM.vy[i]*0.5,LM.z[i]-LM.vz[i]*0.5)
			color(180,0,0)
			seed = math.floor(_FPS())
			for j=1,10,1 do		
				local rx=math.random(101)*0.01-0.5
				local ry=math.random(101)*0.01-0.5
				_MOVE3D(LM.x[i]-LM.vx[i]*0.5,LM.y[i]-LM.vy[i]*0.5,LM.z[i]-LM.vz[i]*0.5)
				_LINE3D(LM.x[i]-LM.vx[i]*0.6-LM.vy[i]*0.1*rx-LM.vz[i]*0.1*ry,LM.y[i]-LM.vy[i]*0.6-LM.vz[i]*0.1*rx-LM.vx[i]*0.1*ry,LM.z[i]-LM.vz[i]*0.6-LM.vx[i]*0.1*rx-LM.vy[i]*0.1*ry)
			end

			color(200,200,200)
			for j=LM.lo_count[i],1,-1 do
				LM.locus[i][j][1] = LM.locus[i][j-1][1]
				LM.locus[i][j][2] = LM.locus[i][j-1][2]
				LM.locus[i][j][3] = LM.locus[i][j-1][3]
			end
			LM.locus[i][0][1],LM.locus[i][0][2],LM.locus[i][0][3] = LM.x[i]-LM.vx[i]*0.65,LM.y[i]-LM.vy[i]*0.65,LM.z[i]-LM.vz[i]*0.65
			_MOVE3D(LM.locus[i][0][1],LM.locus[i][0][2],LM.locus[i][0][3])
			for j=1,LM.lo_count[i],1 do
				_LINE3D(LM.locus[i][j][1],LM.locus[i][j][2],LM.locus[i][j][3])
			end
			LM.lo_count[i] = math.min(20,LM.lo_count[i]+1)

			lenge = 1
			if(tgt.len<=lenge)or(LM.y[i]<=_GETY(LM.x[i],LM.z[i])) then
				LM.use[i] = 0
				LM.lo_count[i] = 0
			end
		end
	end
end


LM.dir = 0
function LM:missile_set(n,cn)
	LM.x[n],LM.y[n],LM.z[n] = _X(LM.chip[cn]),_Y(LM.chip[cn]),_Z(LM.chip[cn])
	LM.tx[n],LM.ty[n],LM.tz[n] = _OX(0),_OY(0),_OZ(0)

	if(_DIR(LM.chip[cn])==0) then
		LM.vx[n],LM.vy[n],LM.vz[n] = _ZX(LM.chip[cn]),_ZY(LM.chip[cn]),_ZZ(LM.chip[cn])
	elseif(_DIR(LM.chip[cn])==1) then
		LM.vx[n],LM.vy[n],LM.vz[n] = _XX(LM.chip[cn]),_XY(LM.chip[cn]),_XZ(LM.chip[cn])
	elseif(_DIR(LM.chip[cn])==2) then
		LM.vx[n],LM.vy[n],LM.vz[n] = -_ZX(LM.chip[cn]),-_ZY(LM.chip[cn]),-_ZZ(LM.chip[cn])
	elseif(_DIR(LM.chip[cn])==3) then
		LM.vx[n],LM.vy[n],LM.vz[n] = -_XX(LM.chip[cn]),-_XY(LM.chip[cn]),-_XZ(LM.chip[cn])
	end

	LM.use[n] = 1	
end

function LM:MaxMin(max,min,n)
	n = math.max(min,math.min(max,n))
	return n
end

-------↓それぞれ指定してね↓-------
	
--作った関数を指定、()は不要
krl.Application[krl.List] = LineMissile
	
--ウィンドウ表示時の名前を指定
krl.Name[krl.List] = "LINE MISSILE"