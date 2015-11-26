// all credits to FSF, the original creator of this scripts
// adapted by : Warzen

// make units - leader only - randomly talk in a specific language, sound file dependent

// parameters:
// 0: Array of units
// 1: language, default "eng" - for english, planned: spa, rus, ara, fre
// 2: sound type, "radio" or "voice", default "voice"
// 2: min seconds between two "talk", default 45
// 3: max random time in seconds, added to parameter 2, default 30
// total time between two "talk" is param2 + random (param3)

// sound file format, CfgSounds
// <sound type>_<language>_<number, 2 digits>


params [ "_wz_units", ["_wz_lang", "eng"], ["_wz_soundtype", "voice"], ["_wz_mintime", 45], ["_wz_addtime", 30]];

{
	if (_x == leader group _x) then {
		[_x, _wz_lang, _wz_soundtype, _wz_mintime, _wz_addtime] spawn {
			params [ "_wz_unit", "_wz_lang", "_wz_soundtype", "_wz_mintime", "_wz_addtime"];
			private ["_sound","_sleep", "_nbsound"];

			while{alive _wz_unit} do {
				if(behaviour _wz_unit == "SAFE" || behaviour _wz_unit == "CARELESS") then {
					_nbsound = call compile format ["WZ_AI_%1_%2",_wz_soundtype,_wz_lang];
					//hint str (_nbsound);
					_sound = (floor random _nbsound)+1;
					_wz_unit say format ["%1_%2_%3",_wz_soundtype,_wz_lang,_sound];
				};
				_sleep = _wz_mintime + random _wz_addtime;
				sleep _sleep;
			};
		};
	};
} forEach _wz_units;

/* exemple: [ [u2], "eng", "radio", 10, 10] call WZ_fnc_AI_voice; */

/* version sans définition dans le cfgSound:
_root = parsingNamespace getVariable "MISSION_ROOT";
playSound3D [_root + "WZ_Scripts\Sound\radio_en_01.ogg", player , false, getposASL player, 0.5,1,0];
*/

/* note optimisation cfgSound
class CfgSounds {
	#include "_cfgSounds.hpp"
};

/*