/* All credits to MCC authors. This is just a quick hack of the paradrop function. */

// modified by Warzen

// parameters:
// 0 : QRF target location
// 1 : QRF start location
// 2 : QRF side (utile ??)
// 3 : array of units, cargo of the chopper
// 4 : chopper classname
// 5 : QRF type, 0 = paradrop, 1 = drop off, 2 = fast rope
// 6 : flight height - use 300 for paradrop, 50 for others
// 7 : array for fast roping

// exemple:  [ getMarkerPos "renfort", getMarkerPos "depart", EAST, ["rhs_vdv_mflora_sergeant", "rhs_vdv_mflora_rifleman", "rhs_vdv_mflora_rifleman","rhs_vdv_mflora_machinegunner"], "rhs_ka60_grey", 1, 100, []] spawn WZ_fnc_QRF_heli;

private ["_away","_p_mcc_zone_markername","_heli","_heliCrew""_helocargo","_pos","_paraSide", "_paraType", "_helitype",
         "_heli_pilot","_spawn","_heliPilot","_gunnersGroup","_type","_entry","_turrets","_path", "_timeOut",
		 "_unit", "_side", "_spawnParaGroup", "_paraGroupArray", "_paraGroup", "_paraMode", "_heliCrewCount",
		 "_p_mcc_spawnfaction", "_p_mcc_zone_behavior", "_p_mcc_awareness", "_newParaGroup", "_rampOutPos", "_flyHeight",
		 "_dropPos", "_rope", "_ropes" , "_dir", "_actualRopes"
		 ];

params [ "_pos", "_startPos", "_paraSide", "_para_units", "_helitype", "_paraMode", "_flyHeight", ["_ropes", [[1.3,1.3,-25],[-1.3,1.3,-25]] ] ];



// create the chopper and its crew
_heli 				= [_heliType, _startPos, _pos, _flyHeight, false, _paraSide] call WZ_fnc_createPlane;

_heliCrew			= group _heli;
_heliPilot			= driver _heli;
crew _heli joinSilent _heliCrew;

_heli setBehaviour "CARELESS";

_heliCrewCount = count (crew _heli);

// In case of drop-off or fast-rope return to start position
if ( _paraMode > 0 ) then
	{ _away = _startPos; }
	else {
	_spawndir = [_startPos, _pos] call BIS_fnc_dirTo;
	_away = [_pos, 2000, _spawndir] call BIS_fnc_relpos;
	};
	
_heli flyInHeight _flyHeight;
_heliPilot flyInHeight _flyHeight;


// create the cargo ie paratroopers
_unitspawned=[[100,100,5000], _paraSide, _para_units] call BIS_fnc_spawnGroup;
_cargoEmtpy = count units _unitspawned; // nbr of paratroopers

_cargoGroups =[];
_cargoGroups set [count _cargoGroups,_unitspawned];  // à quoi ça sert ???

sleep 0.1;

// put paratroopers in the heli

{
	_x assignAsCargo _heli;
	_x moveInCargo _heli;
	/*_x setSkill ["aimingspeed", MCC_AI_Aim];		// ts les setSkill sont à virer
	_x setSkill ["spotdistance", MCC_AI_Spot];
	_x setSkill ["aimingaccuracy", MCC_AI_Aim];
	_x setSkill ["aimingshake", MCC_AI_Aim];
	_x setSkill ["spottime", MCC_AI_Spot];
	_x setSkill ["commanding", MCC_AI_Command];
	_x setSkill ["general", MCC_AI_Skill];*/
	removeBackpack _x;  // à garder ??
	//_x addBackpack "B_Parachute";
} forEach (units _unitspawned);

// finding proper place to land

/* test arrivée position exacte
_dropPos = _pos findEmptyPosition [10,150,_heliType];
if ( count _dropPos == 0 ) then { _dropPos = _pos; }; 
*/
_dropPos = _pos;

//Set waypoint
_heliCrew move _pos;
(driver _heli) move _pos;

_heli setSpeedMode "FULL";
_heli setDestination [_away, "VehiclePlanned", true];

waitUntil { sleep 1;(_heli distance _dropPos) < ((getPosATL _heli select 2) + 150)};  // include heli heigth else if flying higher then 250 m this wil be 'true'

/*_heli animateDoor ["door_R", 1];
_heli animateDoor ["door_L", 1];*/
{
	_heli animateDoor [_x,1];
} foreach ["door_back_L","door_back_R","door_L","door_R","Door_6_source","Door_rear_source"];


if ( _paraMode == 2 ) then  // toss ropes for fast-rope
{
	
	_heli flyInHeight 40;
	sleep 4;		
	doStop (driver _heli);
	
	//waitUntil { sleep 1; ( (abs(speed _heli) < 0.5) && ((getPos _heli select 2) < 50) ) };
	waitUntil { sleep 1; ( (abs(speed _heli) < 0.5) && ((getPos _heli select 2) < 50) )  || !alive _heli || !alive (driver _heli)};
	if ( !alive _heli || !alive (driver _heli)) exitWith {};	
	
	_actualRopes = [];
	
	{	
		_rope = ropeCreate [_heli, _x,55,[10],[10], true];
		_actualRopes set [count _actualRopes, _rope];
		/*_rope = createVehicle ["land_rope_f", [0,0,0], [], 0, "CAN_COLLIDE"];
		sleep 0.3;
		_rope allowDamage false;
		_rope disableCollisionWith _heli;
		_actualRopes set [count _actualRopes, _rope];
		_rope setdir (getdir _heli);
		_rope attachto [_heli, _x];
		*/
		sleep 0.5;
	} forEach _ropes;
};

// ici mettre le coeur de l'éjection *****************************

_paraGroup = _unitspawned;
_dir = (direction _heli) + 180;

 switch ( _paraMode ) do
{
	case 0: // paradrop
	{
		_heli flyInHeight (getPosATL _heli select 2); // to maintain current altitude
		
		{
			if (typeOf _heli == "I_Heli_Transport_02_F") then // à quoi ça sert ???
			{
				sleep 1.6;
				
				_d = if ((speed _heli) <= 40) then {6} else {5};

				_rampOutPos = [_heli, _d, ((getDir _heli) + 180)] call BIS_fnc_relPos;
				_altitude = getPosATL _heli;

				_a = if ((speed _heli) <= 40) then {3} else {0};

				_rampOutPos set [2, ((_altitude select 2) - _a)];

				_x setPosATL _rampOutPos;
				_x setDir ((getDir _heli) + 180);
			}
			else
			{
				sleep 0.8;
			};
			
			_x allowDamage false;
			unassignVehicle _x;
			//_x action ["EJECT",vehicle _x];	
			_x action ["GetOut",vehicle _x];
			//sleep 1.0;
			sleep 0.2;
						
			// tentative de random de hauteur de déploiement du parachute - remplacer le 150 par une variable
			/*[_x, _dir ] spawn { waitUntil {(position _x select 2) <= (150 -25 + random 50)};  // ajout d'un random de -25 à +25 m pour que ce soit plus naturel
			if (vehicle _x != _x) exitWith {};*/
			
			/*_chute = createVehicle ["Steerable_Parachute_F", position _x, [], ((_dir)- 5 + (random 10)), 'FLY'];
			_chute setPos (getPos _x);
			_chute setDir ((_dir)-5+(random 10));
			_x setDir ( direction _chute );
			_chute setPos (getPos _x);
			_x moveindriver _chute;
			(vehicle _x) setDir ((_dir)-5+(random 10));
			_x allowDamage true;*/
			
			[_x, _dir, 175 ] spawn {
				_para1 = _this select 0;
				_direction1 = _this select 1;
				_h_ouvre_para = _this select 2;
				waitUntil {(position _para1 select 2) <= (_h_ouvre_para -25 + random 50)};  // ajout d'un random de -25 à +25 m pour que ce soit plus naturel
				if (vehicle _para1 != _para1) exitWith {};  // repompage, je n'ai pas regardé à quoi cela sert
				
				_chute = createVehicle ["Steerable_Parachute_F", position _para1, [], ((_direction1)- 5 + (random 10)), 'FLY'];
				_chute setPos (getPos _para1);
				_chute setDir ((_direction1)-5+(random 10));
				_para1 setDir ( direction _chute );
				_chute setPos (getPos _para1);
				_para1 moveindriver _chute;
				(vehicle _para1) setDir ((_direction1)-5+(random 10));
				_para1 allowDamage true;
			};
		} foreach (units _paraGroup);
	};
	
	case 1: // drop-off
	{
		{
			unassignVehicle _x;
		} foreach (units _paraGroup);
	};
	
	case 2: // fast-rope
	{
		_heli doMove (getPosATL _heli);
		//doStop _heli;
		doStop driver _heli;

		{					
			_rope = _actualRopes select (_forEachIndex % 2);
			
			
			[_x, _rope] spawn 
				{
					private ["_unit", "_zc", "_zdelta", "_rope"];
					_unit = _this select 0;
					_rope = _this select 1;
					_zdelta = 7 / 10;
					_zc = 22;
					
					unassignVehicle _unit;
					_unit action ["eject", vehicle _unit];
					_unit switchmove "gunner_standup01";
					
					_unit setpos [(getpos _unit select 0), (getpos _unit select 1), 0 max ((getpos _unit select 2) - 3)];
					
					while { (alive _unit) && ( (getpos _unit select 2) > 1 ) && ( _zc > -24 ) } do 
					{
						_unit attachTo [_rope, [0,0,_zc]];
						_zc = _zc - _zdelta;
						sleep 0.1;
					};
					
					_unit switchmove "";
					detach _unit;
				};
			sleep ( 1 + ((random 6)/10) );
		} foreach (units _paraGroup);
	};
};





// fin éjection *******************************************


if ( _paraMode > 0 ) then  // Drop-off or fast-rope
{
	// if chopper is still around after 40/70 seconds leave to avoid getting stuck
	if ( _paraMode > 1 ) then
	{
		_timeOut = time + 40; 
	}
	else
	{
		_timeOut = time + 70; 
	};

	{
		_x setBehaviour "AWARE";
	} foreach _cargoGroups;
	
	//wait untill all paratroopers are out 
	waitUntil { sleep 1; (count crew _heli == _heliCrewCount) || (time > _timeOut);  };

	// toss ropes for fast-rope
	if ( _paraMode == 2 ) then  
	{
		//make sure all AI cargo has left the chopper - give 4 seconds for last unit to slide down the rope
		waitUntil { sleep 1; (count crew _heli == _heliCrewCount) || (time > _timeOut + 20);  };		
		sleep 4;
		
		// drop the ropes and delete them
		{
			_attachPoint = _ropes select _forEachIndex;
			_zc = -22;
			while { _zc > -50 } do 
			{
				_x attachTo [_heli, [_attachPoint select 0 , _attachPoint select 1,_zc]];
				_zc = _zc - 2;
				sleep 0.1;
			};
			deletevehicle _x;
		} foreach _actualRopes;
		
		//wait 3 seconds before flying away
		sleep 3;
	};
	
	_away = _startpos;
	_heli flyInHeight _flyHeight;
	_heliPilot flyInHeight _flyHeight;
	
	//Set waypoint
	_heli doMove _away;
	_heliPilot doMove _away;
}
else // Paradrop
{
	_heli flyInHeight _flyHeight;
	_heliPilot flyInHeight _flyHeight;
};


_heliPilot doMove _away;
_heli setSpeedMode "FULL";
_heli setBehaviour "CARELESS";

_heli setDestination [_away, "VehiclePlanned", true];


_heli animateDoor ["door_R", 0];
_heli animateDoor ["door_L", 0];
_heli animate ["CargoRamp_Open", 0];

// Allow chopper to leave else AI will board again :-/
sleep 5; 


_timeOut = time + 80; // if chopper is still around after 1.2 minute just delete it
waituntil { sleep 1; ( ((_heli distance _away) < ((getPosATL _heli select 2) + 350)) || (time > _timeOut) ); };

{deleteVehicle _x} forEach (crew _heli);
deletegroup (group _heli);	//case we want to delete the whole shabang
deletevehicle _heli;

_paraGroup

/*
********************************************************************
Gros hack pourri du paradrop MCC.
à transformer plus tard en vraie fonction propre de paradrop, fastrope et drop off

exemple: null = [ getMarkerpos "renfort", EAST, 3, "1" , "MOVE", "AWARE", "OPF_F", getMarkerpos "depmcc"] execVM "Scripts\paratroops.sqf";

paramètre 1: marqueur d'arrivée des renforts
paramètre 2: side des renforts
paramètres 3: type d'insertion des renforts: 1 = paradrop, 0 à 2 = paradrop, 3 à 5 = drop off et 6 à 8 = fast rope
paramètres 4 & 5 : zone gaia, type de movement gaia (ie MOVE, FORTIFY..Etc)
paramètre 6: behaviour (des renforts ?)
paramètre 7: faction des renforts 
paramètre 8: marqueur de départ de l'hélico

pour l'instant, le fast rope ne marche pas, l'hélico s'arrête qq mètres trop tôt et ne déclenche pas la sortie des troupes
********************************************************************
*/
//if (isServer) then {

