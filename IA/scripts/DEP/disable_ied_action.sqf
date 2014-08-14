// ***** Dynamic Enemy Population *****
//              By Fluit
// 
// This file handles the action for disabling an IED.

_target = cursorTarget;

if (vehicle player != player)               exitWith { false; };
if (_target distance player > 3)            exitWith { false; };
if !("ToolKit" in backpackItems player)     exitWith { false; };
if !(_target getVariable "IED")             exitWith { false; };
if (_target getVariable "workingon")        exitWith { false; };

true;