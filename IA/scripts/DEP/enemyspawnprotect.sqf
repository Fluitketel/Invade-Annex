// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file makes units invincible for a short time after to counter unit deaths on spawn.
private ["_group"];
_group = _this select 0;

{
    _x allowDamage false;
} foreach (units _group);

sleep 10;
{
    _x allowDamage true;
} foreach (units _group);