
á>
client.protonkclient"¸
LoginHallReq
uid (Ruid
uuid (	Ruuid
gameid (Rgameid
did (Rdid
	clientVer (R	clientVer
	userLevel (R	userLevel
	userMoney (R	userMoney"3
LoginHallResp
ret (Rret
tid (Rtid".
Person
name (	Rname
age (Rage"{
AllocTableReq
	roomLevel (R	roomLevel
	userLevel (R	userLevel
	userMoney (R	userMoney
tid (Rtid"4
AllocTableResp
ret (Rret
tid (Rtid"%
KickOutUser
reason (Rreason""
TraceFriendReq
uid (Ruid"k
TraceFriendResp
uid (Ruid
status (Rstatus
tid (Rtid
	roomLevel (R	roomLevel"J
BroadcastMsg
uid (Ruid
mtype (Rmtype
info (	Rinfo"8

LevelCount
level (Rlevel
count (Rcount"F
GetUserCountResp2
	levelList (2.nkclient.LevelCountR	levelList"°
LoginGameReq
uid (Ruid
tid (Rtid
did (Rdid
	clientVer (R	clientVer
mtkey (	Rmtkey
username (	Rusername
baseInfo (	RbaseInfo"í

PlayerInfo
uid (Ruid
seatId (RseatId

userStatus (R
userStatus
online (Ronline
userInfo (	RuserInfo
curCarry (RcurCarry
curAnte (RcurAnte
wintimes (Rwintimes
	losetimes	 (R	losetimes 
specialCard
 (RspecialCard
	userMoney (R	userMoney
addExp (RaddExp
addMoney (RaddMoney$
cards (2.nkclient.CardRcards
isShow (RisShow,
	bestCards (2.nkclient.CardR	bestCards
multiple (Rmultiple
roomFee (RroomFee
cardsCnt (RcardsCnt
index (Rindex+
betInfo (2.nkclient.BetInfoRbetInfo 
settleState (RsettleState*
outCards (2.nkclient.CardRoutCards.
propList (2.nkclient.PropDropRpropList"·
	TableInfo
tid (Rtid
level (Rlevel 
tableStatus (RtableStatus

bankSeatid (R
bankSeatid 
defaultAnte (RdefaultAnte
	totalAnte (R	totalAnte
	curSeatid (R	curSeatid
leftTime	 (RleftTime
	quickCall
 (R	quickCall
minCall (RminCall
maxCall (RmaxCall
	roundTime (R	roundTime

maxSeatCnt (R
maxSeatCnt
minCarry (RminCarry
maxCarry (RmaxCarry"
defaultCarry (RdefaultCarry
roomTab (RroomTab,
	boardCard (2.nkclient.CardR	boardCard
	sysBanker (R	sysBanker&
boardCardTimes (RboardCardTimes

bankUserId (R
bankUserId,
	leftCards (2.nkclient.CardR	leftCards"²
SendTableInfo
ret (Rret)
table (2.nkclient.TableInfoRtable4

playerList (2.nkclient.PlayerInfoR
playerList.
fishList (2.nkclient.FishInfoRfishList"p
UserSitDownReq
seatId (RseatId
ante (Rante
	autoBuyin (R	autoBuyin
param (Rparam"#
UserSitDownResp
ret (Rret"«
SrvBroadcastSitDown
uid (Ruid
seatId (RseatId
curCarry (RcurCarry
	userMoney (R	userMoney
userInfo (	RuserInfo
param (Rparam"T
UserAnte
seatId (RseatId
curCarry (RcurCarry
bonus (Rbonus"
Card
card (Rcard"¤
SrvSendGameStart

bankSeatid (R
bankSeatid 
defaultAnte (RdefaultAnte
	totalAnte (R	totalAnte.
anteList (2.nkclient.UserAnteRanteList$
cards (2.nkclient.CardRcards 
specialCard (RspecialCard
cardsCnt (RcardsCnt
	roundTime (R	roundTime"A
UserStandUpResp
	userMoney (R	userMoney
ret (Rret"?
SrvBroadcastStandUp
uid (Ruid
seatId (RseatId"'
UserSendTipsReq
money (Rmoney"t
UserSendTipsResp
ret (Rret
count (Rcount
curCarry (RcurCarry
	userMoney (R	userMoney"y
UserSendPropReq
money (Rmoney
type (Rtype
id (Rid
seatId (RseatId
count (Rcount"Æ
UserSendPropResp
ret (Rret
price (Rprice
curCarry (RcurCarry
	userMoney (R	userMoney
type (Rtype
id (Rid
seatId (RseatId
count (Rcount"+
AutoBuyinResp
curCarry (RcurCarry"´
SrvSendNextOperate
seatId (RseatId
leftTime (RleftTime
minCall (RminCall
maxCall (RmaxCall
	quickCall (R	quickCall
operate (Roperate"d
UserOperateReq
operate (Roperate
ante (Rante$
cards (2.nkclient.CardRcards"x
UserOperateResp
ret (Rret
operate (Roperate
curCarry (RcurCarry

opera_data (R	operaData"“
SrvBroadcastOperate
seatId (RseatId

userStatus (R
userStatus
curAnte (RcurAnte
curCarry (RcurCarry
	totalAnte (R	totalAnte
operate (Roperate$
cards (2.nkclient.CardRcards
cardType (RcardType
times	 (Rtimes"
Seat
seatId (RseatId"§
SrvBroadcastThirdCard*
seatList (2.nkclient.SeatRseatList$
cards (2.nkclient.CardRcards 
specialCard (RspecialCard
cardsCnt (RcardsCnt"i
	BonusInfo
	moneyPool (R	moneyPool(
antes (2.nkclient.UserAnteRantes
index (Rindex"Ù
SrvBroadcastGameOver4

playerList (2.nkclient.PlayerInfoR
playerList1
	bonusList (2.nkclient.BonusInfoR	bonusList$
cards (2.nkclient.CardRcards
result (Rresult
isSpring (RisSpring"@
UserLogoutResp
ret (Rret
	userMoney (R	userMoney"5
UserDropCards$
cards (2.nkclient.CardRcards"q
SrvBroadcastDropCards
seatId (RseatId
cardsCnt (RcardsCnt$
cards (2.nkclient.CardRcards"»
	ShowCards
seatId (RseatId$
cards (2.nkclient.CardRcards 
specialCard (RspecialCard
multiple (Rmultiple
isWin (RisWin
	roundTime (R	roundTime"k
SrvBroadcastUserCard1
	userCards (2.nkclient.ShowCardsR	userCards 
tableStatus (RtableStatus"3
SrvBroadcastCheckCard
showTime (RshowTime"\
UserSlotBetReq
lines (Rlines
chips (Rchips

isUseProps (R
isUseProps"m
UserSlotBetResp
ret (Rret
	userMoney (R	userMoney
lines (Rlines
chips (Rchips"6

SlotWinRet
line (Rline
count (Rcount"˜
SrvBroadcastSlotResult
seatId (RseatId
addMoney (RaddMoney
	userMoney (R	userMoney

totalBonus (R
totalBonus$
cards (2.nkclient.CardRcards(
pots (2.nkclient.SlotWinRetRpots
bonusCnt (RbonusCnt 
specialCard (RspecialCard"—
SrvBroadcastNiuniuResult

totalBonus (R
totalBonus)
cards (2.nkclient.ShowCardsRcards0
userList (2.nkclient.PlayerInfoRuserList" 
SrvBroadcastBetOn
seatId (RseatId
slot (Rslot
ante (Rante
curCarry (RcurCarry/
anteList (2.nkclient.BonusInfoRanteList"ž
SrvBroadcastBoardCards
seatId (RseatId$
cards (2.nkclient.CardRcards&
boardCardTimes (RboardCardTimes

totalTimes (R
totalTimes"_
BetInfo
ante (Rante
count (Rcount
bonus (Rbonus
times (Rtimes"4
UserCardList$
cards (2.nkclient.CardRcards"M
SrvBroadcastUserReady
seatId (RseatId
	userMoney (R	userMoney"6

BankerInfo
seatId (RseatId
uid (Ruid"ä
FishInfo
fishId (RfishId
fishType (RfishType
pathId (RpathId
life (Rlife
delay (Rdelay
	birthTime (R	birthTime.
propInfo (2.nkclient.PropDropRpropInfo
queue (Rqueue"@
PropDrop
propId (RpropId
	propCount (R	propCount"P

CreateFish.
fishList (2.nkclient.FishInfoRfishList
sort (Rsort"á
ShotFishMsg
seatId (RseatId
bulletId (RbulletId.
fishList (2.nkclient.FishInfoRfishList.
killList (2.nkclient.FishInfoRkillList
	userMoney (R	userMoney 
totalKilled (RtotalKilled"Ü
UserShooting
seatId (RseatId 
cannonLevel (RcannonLevel
param (	Rparam
ret (Rret
bulletId (RbulletId
	userMoney (R	userMoney
bindUser (RbindUser
addup (Raddupbproto3