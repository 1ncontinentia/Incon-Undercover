params ["_unit"];

#include "UCR_setup.sqf"

switch (side _unit) do {
	case _regEnySide: {
		[_unit,_regBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
	};
	case _asymEnySide: {
		[_unit,_asymBarbaric,_undercoverUnitSide] call INCON_fnc_undercoverKilledHandler;
	};
};

if (_civRecruitEnabled) then {
	if (((side _unit) == CIVILIAN) && {!(_unit getVariable ["isUndercover",false])}) then {
		[_unit,_armedCivPercentage,_civRifleArray,_civPistolArray,_civPackArray] remoteExecCall ["INCON_fnc_recruitCiv",0,true];
	};
};

_unit addEventHandler["Killed", {

	params["_unit"];

	[_unit, [
		"<t color='#FFC300'>Take uniform from dead unit</t>", {

			_this spawn {
				params ["_deadGuy","_opportunist"];
				private ["_gwh","_oldUniform","_deadUniform","_oldItems"];

				[_opportunist,"AinvPercMstpSnonWnonDnon_Putdown_AmovPercMstpSnonWnonDnon"] remoteExec ["playMove",0];

				_oldUniform = uniform _opportunist;
				_deadUniform = uniform _deadGuy;
				_oldItems = uniformItems _opportunist;
				_deadGuyItems = uniformItems _deadGuy;

				sleep 0.2;

				_gwh = createVehicle ["GroundWeaponHolder", getPosATL _opportunist, [], 0, "CAN_COLLIDE"];
				_gwh addItemCargoGlobal [_oldUniform, 1];
				{_gwh addItemCargoGlobal [_x, 1];} forEach (_deadGuyItems);

				sleep 1;

				removeUniform _deadGuy;
				_opportunist forceAddUniform _deadUniform;
				{(uniformContainer _opportunist) addItemCargoGlobal [_x, 1];} forEach (_oldItems);
			};

		},[],6,true,true,"","((_this getVariable ['isUndercover',false]) && {uniform _target != ''})",4
	]] remoteExec ["addAction", 0,true];
}];
