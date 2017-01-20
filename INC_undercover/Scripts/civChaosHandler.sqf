params [["_targetChance",100],["_rebelChance",40],["_percentageTarget",40],["_percentageRebel",50],["_timeToRebel",(random 600)]];

if (missionNamespace getVariable ["civiliansTargeted",false]) exitWith {};

[_targetChance,_rebelChance,_percentageTarget,_percentageRebel,_timeToRebel] spawn {

	params [["_targetChance",100],["_rebelChance",40],["_percentageTarget",40],["_percentageRebel",30],["_timeToRebel",(random 600)]];

	_cooldownTimer = (30 + (random 300));
	sleep _cooldownTimer;

	if (_targetChance > (random 100)) then {

		missionNameSpace setVariable ["civiliansTargeted", true, true];
		//Enemies target civs
		{
			if (((side _x) == Civilian) && {!(_x getVariable ["isUndercover", false])}) then {
				if (_percentageTarget > (random 100)) then {
					private _prevGroup = group _x;

					[_x] joinSilent grpNull;
					[_x] joinSilent (group INC_rebelCommander);

					if ((count units _prevGroup) == 0) then {
						deleteGroup _prevGroup; // clean up empty groups
					};
				};
			};
		} foreach allunits;
	};

	sleep _timeToRebel;


	//Armed civs will rebel
	if (_rebelChance > (random 100)) then {
		{
			if (
				((side _x) == Civilian) &&
				{_percentageRebel > (random 100)} &&
				{!(_x getVariable ["isUndercover", false])} &&
				{!((count weapons _x) == 0)}
			) then {
				private _prevGroup = group _x;

				[_x] joinSilent grpNull;
				[_x] joinSilent (group INC_rebelCommander);

				if ((count units _prevGroup) == 0) then {
					deleteGroup _prevGroup;
				};

				private _wpn = selectRandom (weapons _x);
				_x removeWeapon _wpn;
				private _mag = selectRandom ([_wpn,"getCompatMags"] call INCON_fnc_ucrMain);
				_x addMagazine _mag;
				_x addWeapon _wpn;

				_x setUnitAbility (0.7 + (random 0.25));
			};
		} foreach allunits;
	};

	sleep _cooldownTimer;

	missionNamespace setVariable ["civiliansTargeted", false, true];
};
