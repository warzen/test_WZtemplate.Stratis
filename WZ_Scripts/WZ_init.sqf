
// Constants

// sound part - number of radio and speech file, per language
//WZ_AI_voice_eng = 3;
WZ_AI_radio_eng = 8;
WZ_AI_radio_spa = 10;
WZ_AI_voice_spa = 6;

//WZ_AI_voice_rus = 10;



// Variables

// Scripts

WZ_Sound	= "WZ_Scripts\Sound\";
WZ_Env		= "WZ_Scripts\Env\";
WZ_AI		= "WZ_Scripts\AI\";

WZ_fnc_AI_voice                     = compile preProcessFileLineNumbers(WZ_Env + "WZ_fn_AI_voice.sqf");
WZ_fnc_QRF_heli						= compile preProcessFileLineNumbers(WZ_AI + "WZ_fn_paradrop.sqf");
WZ_fnc_createPlane					= compile preProcessFileLineNumbers(WZ_AI + "WZ_fn_createPlane.sqf");
