// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This add the addActions for disabling an IED.
_object = _this select 0;
_object addAction ["<t color='#FF0000'>Cut red wire</t>", "call dep_fnc_disable_ied",[0], 6, false, true, "", "call dep_fnc_disable_ied_action"];
_object addAction ["<t color='#00990A'>Cut green wire</t>", "call dep_fnc_disable_ied",[1], 6, false, true, "", "call dep_fnc_disable_ied_action"];
_object addAction ["<t color='#0006AD'>Cut blue wire</t>", "call dep_fnc_disable_ied",[2], 6, false, true, "", "call dep_fnc_disable_ied_action"];