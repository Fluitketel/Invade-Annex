////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT START (by Hellstorm77 + bl1p + fluit
////////////////////////////////////////////////////////
#define GUI_GRID_X	(0)
#define GUI_GRID_Y	(0)
#define GUI_GRID_W	(0.025)
#define GUI_GRID_H	(0.04)
#define GUI_GRID_WAbs	(1)
#define GUI_GRID_HAbs	(1)

class bl1p_dialog
{
       idd = 2000;
	   movingenable = true;
	   
class controls
	{
		class Bl1p_frame: bl1p_RscFrame
		{
			idc = 1800;
			x = 14.5 * GUI_GRID_W + GUI_GRID_X;
			y = 22 * GUI_GRID_H + GUI_GRID_Y;
			w = 14 * GUI_GRID_W;
			h = 4 * GUI_GRID_H;
		};
		class bl1p_button: bl1p_RscButton
		{
			idc = 1600;
			text = "Suicide"; //--- ToDo: Localize;
			x = 15 * GUI_GRID_W + GUI_GRID_X;
			y = 22.5 * GUI_GRID_H + GUI_GRID_Y;
			w = 13 * GUI_GRID_W;
			h = 3 * GUI_GRID_H;
			action = "nul = [false, false, false, [""action_suicide""]] ExecVM ""core\FAR_revive\FAR_handleAction.sqf"";";
		};
    }; 
};
    

////////////////////////////////////////////////////////
// GUI EDITOR OUTPUT END
////////////////////////////////////////////////////////
