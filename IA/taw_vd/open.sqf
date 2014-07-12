private["_dialog","_s_foot","_s_car","_s_air","_s_air_text","_s_car_text","_s_foot_text"];
createDialog "TAW_VD";
disableSerialization;

_dialog = findDisplay 2900;
_s_foot = _dialog displayCtrl 2901;
_s_car = _dialog displayCtrl 2911;
_s_air = _dialog displayCtrl 2921;
_s_foot_text = _dialog displayCtrl 2902;
_s_car_text = _dialog displayCtrl 2912;
_s_air_text = _dialog displayCtrl 2922;

//Set the values
_s_foot_text ctrlSetText format["%1", tawvd_foot];
_s_car_text ctrlSetText format["%1", tawvd_car];
_s_air_text ctrlSetText format["%1", tawvd_air];

//On foot slider
_s_foot sliderSetRange [100,1000];
_s_foot slidersetSpeed [100,100,100];
_s_foot sliderSetPosition tawvd_foot;

//In land vehicle slider
_s_car sliderSetRange [100,1000];
_s_car slidersetSpeed [100,100,100];
_s_car sliderSetPosition tawvd_car;

//In air vehicle slider
_s_air sliderSetRange [100,1000];
_s_air slidersetSpeed [100,100,100];
_s_air sliderSetPosition tawvd_air;