/*  Copyright (C) 1996-2022 id Software LLC

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

    See file, 'COPYING', for details.
*/

// Rogue Teamplay Variants Message of the Day function
// Feb'97 by ZOID <zoid@threewave.com>
// Under contract to id software for Rogue Entertainment

.float motd_time;
.float motd_count;

void() MOTD =
{
	local string tp;
	
	if (self.motd_count < 5) {
		if (teamplay > 3 && teamplay < 7)
		{
			tp = ftos(teamplay);
			stuffcmd(self, "teamplay ");
			stuffcmd(self, tp);
			stuffcmd(self, "\n");
		}
		self.motd_time = time + 1;
		self.motd_count = self.motd_count + 1;
/*
		if (teamplay == TEAM_NORMAL_NODAMAGE)
			centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nTeam play: No Friendly Fire\n");
		else if (teamplay == TEAM_NORMAL_DAMAGE)
			centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nTeam play: Friendly Fire\n");
*/
		if (teamplay == TEAM_DMATCH_TAG)
			centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nDeathmatch Tag!\n");
		else if (teamplay == TEAM_CTF)
			if (self.steam == TEAM1)
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n\nYou are ��� team!\n");
			else
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n\nYou are ���� team!\n");
		else if (teamplay == TEAM_CTF_ONEFLAG)
			if (self.steam == TEAM1)
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(One Flag Mode)\n\nYou are ��� team!\n");
			else
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(One Flag Mode)\n\nYou are ���� team!\n");
		else if (teamplay == TEAM_CTF_ALT)
			if (self.steam == TEAM1)
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are ��� team!\n");
			else if (self.steam == TEAM2)
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are ���� team!\n");
			else
				centerprint(self, "Welcome to\nThe Dissolution of Eternity!\nBy Rogue Entertainment\n\nCAPTURE THE FLAG!\n(Three Team Mode)\n\nYou are ���� team!\n");
		return;
	}
	self.motd_time = 0;
};

void() CheckMOTD =
{
//	if (self.motd_time && self.motd_time < time)
	if (self.motd_time)
	{ 
		if(self.motd_time < time)
			MOTD();
	}
};

void() SetMOTD = 
{
	self.motd_time = time + 3;
	if ( teamplay == 3 )
		self.motd_count = 2;
	else
		self.motd_count = 0;
};

