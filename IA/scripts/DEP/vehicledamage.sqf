// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file prevents ai from destroying their own vehicles.

(_this select 0) addEventHandler ["HandleDamage", {
    _crew = crew (_this select 0);
    if ((count _crew) > 0) then 
    {
        _friendlycrew = false;
        {
            if (isPlayer _x) exitWith
            {
                _friendlycrew = true; 
            };
        } forEach (_crew);
        
        if !(_friendlycrew) then 
        {
            if (!isPlayer(_this select 3)) then 
            {
                damage (_this select 0);
            };
        };
    };
}];