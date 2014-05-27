//================================Control Parameters ================================================
_unit               = _this select 0;

_numMainWepMag      = 10;   //Change number of magazines in the main weapon
_numMainWepTrMag    = 10;   //Change number of tracer magazines in the main weapon
_numHeNades			= 5;	//Change number of He nades for the underslung

_numFirstAidKit     = 2;    //Change number of first aid kids in inventory
_numWhiteSmoke      = 5;    //Change number of throwable white smokes
_numGreenSmoke      = 5;   //Change number of throwable green smokes
_numRedSmoke        = 5;    //Change number of throwable red smokes

_numSideArmMag      = 5;    //Change number of side arm magazines
_numDemoCharge      = 0;    //Change number of demolitions charges
_numRGOFrag         = 5;   //Change number of throwable grenades in inventory


//===================================================================================================

if(!local _unit) exitWith{};

removeallweapons _unit;
removeHeadgear _unit;
removebackpack _unit;
removeuniform _unit;
removeVest _unit;

//_unit addWeapon "Rangefinder";

_unit addvest "V_PlateCarrierH_CTRG";
_unit adduniform "U_B_CTRG_1";

_unit addbackpack "B_Carryall_mcamo";
_unit addHeadgear "H_MilCap_mcamo";

for [{_i = 0}, {_i < _numMainWepMag}, {_i=_i + 1}]  do {_unit addmagazine "30Rnd_65x39_caseless_mag"};
for [{_i = 0}, {_i < _numMainWepTrMag}, {_i=_i + 1}]do {_unit addmagazine "30Rnd_65x39_caseless_mag_Tracer"};
for [{_i = 0}, {_i < _numHeNades}, {_i=_i + 1}]do {_unit addmagazine "3Rnd_HE_Grenade_shell"};

for [{_i = 0}, {_i < _numSideArmMag}, {_i=_i + 1}]  do {_unit addmagazine "16Rnd_9x21_Mag"};

for [{_i = 0}, {_i < _numFirstAidKit}, {_i=_i + 1}] do {_unit addItem "FirstAidKit"};

for [{_i = 0}, {_i < _numDemoCharge}, {_i=_i + 1}]  do {_unit addMagazine "DemoCharge_Remote_Mag"};

for [{_i = 0}, {_i < _numGreenSmoke}, {_i=_i + 1}]  do {_unit addMagazine "SmokeShellGreen"};
for [{_i = 0}, {_i < _numRedSmoke}, {_i=_i + 1}]    do {_unit addMagazine "SmokeShellRed"};
for [{_i = 0}, {_i < _numWhiteSmoke}, {_i=_i + 1}]  do {_unit addMagazine "SmokeShell"};


for [{_i = 0}, {_i < _numRGOFrag}, {_i=_i + 1}]     do {_unit addMagazine "HandGrenade"};



_unit addItem "NVGoggles";
_unit addItem "acc_pointer_IR";
_unit assignItem "acc_pointer_IR";

_unit addItem "itemgps";
_unit assignItem "itemgps";

_unit addPrimaryWeaponItem "optic_Aco";
_unit addWeapon "arifle_MX_GL_F";

_unit addItem "ACRE_PRC119";
_unit addItem "ACRE_PRC148";
_unit addWeapon "hgun_P07_F";
_unit addItem "muzzle_snds_L";