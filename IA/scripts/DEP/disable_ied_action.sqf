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
if !(typeOf player in ["B_soldier_exp_F","DR_DPM_soldier_exp","DR_URBAN_soldier_exp","DR_Desert_soldier_exp","DR_Dark_soldier_exp"]) exitWith { false; };

true;