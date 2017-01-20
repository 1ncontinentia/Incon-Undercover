/*
Must be defined in description.ext with

//----------------------INIT EVENTHANDLERS--------------------------
class Extended_Init_EventHandlers {
    class CAManBase {
        init = "_this call (compile preprocessFileLineNumbers 'unitInits.sqf')";
    };
};
---------------------------------------------------------------------------- */




params [["_unit",objNull]];


//Exit if the code is already running on the unit or the unit has "noChanges" variable
if (_unit getVariable ["initLoopRunning",false]) exitWith {};
if (_unit getVariable ["noChanges",false]) exitWith {};

_unit setVariable ["initLoopRunning", true, true];

//Recruitment script
#include "INCON\INC_undercover\unitInitsUndercover.sqf"


//Intel script
if (side _unit in [EAST,WEST,INDEPENDENT]) then {
    [_unit] call INCON_fnc_spawnIntelObjects;
};
