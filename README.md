# HappyAutoReply

## 实现功能

- 1.防脚本验证 自动答题
- 2.小队聊天频道的跟随命令

# 残Task

- 1.1 自动关闭提示窗体
- 2.1 跟随任意成员

StaticPopup_Hide
StaticPopup_Hide("PARTY_INVITE")

GOSSIP_CONFIRM

/rl
---

## 自动接收邀请
```
local frame = CreateFrame("FRAME")
frame:RegisterEvent("PARTY_INVITE_REQUEST")
frame:SetScript("OnEvent", function(self, event, sender)
	if sender:sub(1,1) == "A" then
	AcceptGroup()
	end
end
```

## FollowUnit

```
FollowUnit(unit)
```

## UnitId

```
"arenaN"
    Opposing arena member with index N (1,2,3,4 or 5).

"bossN"
    The active bosses of the current encounter if available N (1,2,3...,8).

"focus"
    The current player's focus target as selected by the /focus command.

"mouseover"
    The unit which the mouse is currently (or was most recently) hovering over.

"none"
    A valid unit token that always refers to no unit. UnitName will return "Unknown, nil" for this UnitID. Use to force a macro to not auto self-cast (/cast [target=none] Healing Wave).

"partyN"
    The Nth party member excluding the player (1,2,3 or 4).

"partypetN"
    The pet of the Nth party member (N is 1,2,3, or 4).

"pet"
    The current player's pet.

"player"
    The current player.

"raidN"
    The raid member with raidIndex N (1,2,3,...,40).

"raidpetN"
    The pet of the raid member with raidIndex N (1,2,3,...,40)

"target"
    The currently targeted unit. May be overridden in macros by unit specified as a value of respective Secure Button attribute.

"vehicle"
    The current player's vehicle.

"nameplateN""
    The Nth nameplate (1,2,3,...,40). Cannot be targeted by spells or commands such as /target nameplate1 or /cast [target=nameplate1] Healing Wave.

"spectated<T><N>"
    The Nth spectated unit (1,2,3,...,15) for either Team "a" or "b", such as "spectatedb2" for the second unit on team B. Only present in commentator mode.

"spectatedpet<T><N>"
    The pet of the Nth spectated unit (1,2,3,...,15) for either Team "a" or "b", such as "spectatedpetb2" for the second units' pet on team B. Only present in commentator mode.
```

## UnitIsGroupLeader

```
isLeader = UnitIsGroupLeader(unit [, partyCategory])
```
