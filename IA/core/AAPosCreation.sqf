//by Fluit
if (DEBUG) then {diag_log "===============STARTING SAM CREATION SCRIPT=================";};

private ["_locations", "_loctemp"];

_locations = [];

_loctemp = [getMarkerPos "samsitesne", 6000, 70] call locations_minheight;
_locations = _locations + _loctemp;

_loctemp = [getMarkerPos "samsitesse", 5000, 70] call locations_minheight;
_locations = _locations + _loctemp;

_loctemp = [getMarkerPos "samsitessw", 6000, 150] call locations_minheight;
_locations = _locations + _loctemp;

_loctemp = [getMarkerPos "samsitesnw", 6000, 200] call locations_minheight;
_locations = _locations + _loctemp;

if (DEBUG) then {diag_log Format ["Max Sam sites = %1",PARAMS_SAMCamps];};

_numberofsamcamps = PARAMS_SAMCamps;
if (_numberofsamcamps < 0)  then {
    _numberofsamcamps = round (random 5);
};    
[_locations, _numberofsamcamps, 4000] spawn random_sam_sites;

if (DEBUG) then {diag_log "===============FINISHED SAM CREATION SCRIPT=================";};