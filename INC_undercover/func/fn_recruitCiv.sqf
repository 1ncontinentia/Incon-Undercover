/*

Civilian Recruitment / Arming

Author: Incontinentia

*/


params [["_unit",objNull],["_armedCivPercentage",70]];

if (_unit getVariable ["isPrisonGuard",false]) exitWith {};

[_unit, [
	"<t color='#33FFEC'>Recruit</t>", {
		params ["_civ","_undercoverUnit"];

		if !((currentWeapon _undercoverUnit == "") || (currentWeapon _undercoverUnit == "Throw")) exitWith {
		    private _civComment = selectRandom ["Put your weapon away.","Get that thing out of my face","I don't like being threatened.","Put your gun away."];
		    [[_civ, _civComment] remoteExec ["globalChat",0]];
		};

		[_civ, _undercoverUnit] remoteExecCall ["INCON_fnc_recruitAttempt",_civ];

		_civ setVariable ["INC_alreadyTried",true];

	},[],6,true,true,"","((alive _target) && {(_this getVariable ['isUndercover',false])} && {!(_target getVariable ['INC_alreadyTried',false])})",4
]] remoteExec ["addAction", 0];

[_unit, [
	"<t color='#33FF42'>Steal Clothes</t>", {
		params ["_giver","_reciever"];
		private ["_gwh","_reciverUniform","_giverUniform","_droppedRecUni"];

		switch (40 > random 100) do {
			case true: {
				_gwh = createVehicle ["GroundWeaponHolder", getPosATL _reciever, [], 0, "CAN_COLLIDE"];
				_reciverUniform = uniform _reciever;
				_giverUniform = uniform _giver;
				_gwh addItemCargoGlobal [_reciverUniform, 1];
				_droppedRecUni = (((everyContainer _gwh) select 0) select 1);
				{_droppedRecUni addItemCargoGlobal [_x, 1];} forEach (uniformItems _reciever);
				{_droppedRecUni addItemCargoGlobal [_x, 1];} forEach (uniformItems _giver);
				removeUniform _reciever;
				removeUniform _giver;
				_reciever forceAddUniform _giverUniform;
				if (rating _reciever > 1000) then {_reciever addrating -1000};

				private _civComment = selectRandom ["That's a real dick move.","Fuck you.","I hope you get caught!","You're a horrible human!","What are you playing at?","You've lost my support.","I'll take one for the cause now but not again."];
				[[_giver, _civComment] remoteExec ["globalChat",0]];
			};

			case false: {
				[[_giver,"runAway"] remoteExecCall ["INCON_fnc_ucrMain",_giver]];
				if (rating _reciever > 800) then {_reciever addrating -800};
				private _civComment = selectRandom ["You can fuck off.","What am I going to wear?","Creep!","Go away!","Is this how you treat your women?","Sounds like a dirty ruse.","So now the truth comes out.","This is my favourite shirt.","You'd like that wouldn't you?"];
				[[_giver, _civComment] remoteExec ["globalChat",0]];
			};
		};

		_giver setVariable ["INC_alreadyTried",true];

		},[],6,true,true,"","((_this getVariable ['isUndercover',false]) && {!(_target getVariable ['INC_alreadyTried',false])} && {alive _target} && {uniform _target != ''} && {(currentWeapon _this != '') && {(currentWeapon _this == primaryWeapon _this) || {currentWeapon _this == handgunWeapon _this}}})",4
]] remoteExec ["addAction", 0,true];

if (30 > (random 100)) then {
	[_unit,"addBackpack"] call INCON_fnc_ucrMain;
};

if (_armedCivPercentage > (random 100)) then {

	[_unit,"addWeapon"] call INCON_fnc_ucrMain;
};

if (50 > (random 100)) then {
	[_unit,"addItems"] call INCON_fnc_ucrMain;
};
