//--- nametags.sqf by BL1P snipets found on BIS site
diag_log "=========== this is the nametag script =============";
if (isServer || isDedicated || !hasInterFace) exitWith {Diag_log "I was kicked from the nametag.sqf I am not a true client";};
Waituntil{!isNull player};

while{true} do 
{
sleep 0.5;

if((isPlayer cursorTarget) && (alive cursorTarget) && (side cursorTarget == side player) && (player distance cursorTarget < 15)) then { 

_tag = name cursorTarget;

150 cutText [_tag,"PLAIN DOWN",0.1];

} else {};
};