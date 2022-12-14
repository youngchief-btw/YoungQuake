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

/*
===============================================================================
Bmodel rotation
===============================================================================
*/

vector ModAngles(vector a)
{
    while(a_x > 360) a_x -= 360;
    while(a_x < 0)   a_x += 360;
    while(a_y > 360) a_y -= 360;
    while(a_y < 0)   a_y += 360;
    while(a_z > 360) a_z -= 360;
    while(a_x < 0)   a_z += 360;
    return a;
}

float Clamp(float v, float min, float max)
{
    if(v < min) return min;
    if(v > max) return max;
    return v;
}

/*QUAKED info_rotate (0.4 1.0 0.6) (-8 -8 -8) (8 8 8) 
Used to indicate center of rotation.
*/
void info_rotate_axis() 
{
    remove(self);
}    

/*
===============================================================================
Continuous rotation
self.state     = state: either off, on, accel up, or deccel down.
self.avelocity = rotation degrees per second
self.speed     = current fraction of angluar velocity
self.distance  = change in self.speed per second, negative if decelerating
self.delay     = editor field for how long the acceleration should take
===============================================================================
*/

enum : int
{
    RotateStateOff,
    RotateStateAccelUp,
    RotateStateOn,
    RotateStateDecelDown
};

void rotate_object_continuously_tick(float DeltaTime)
{
    self.angles = ModAngles(self.angles + self.avelocity * DeltaTime);
}

void rotate_object_tween_tick(float DeltaTime)
{
    self.speed += self.distance * DeltaTime;
    self.speed = Clamp(self.speed, 0, 1);
    if(self.speed == 0)
    {
        self.state = RotateStateOff;
        RemoveFrameTickEntity(self);
        return;
    }
    if(self.speed == 1)
    {
        self.state = RotateStateOn;
        self.tick = rotate_object_continuously_tick;
        self.tick(DeltaTime);
        
        return;
    }
    self.angles = ModAngles(self.angles + self.avelocity * DeltaTime * self.speed);
}

void rotate_object_continuously_use()
{
    if(self.delay <= 0)
    {
        //No acceleration, just toggle on or off
        if(self.state == RotateStateOff)
        {
            self.state = RotateStateOn;
            RegisterFrameTickEntity(self);
        }
        else
        {
            self.state = RotateStateOff;
            RemoveFrameTickEntity(self);
        }
        return;
    }

    switch(self.state)
    {
    case RotateStateOff:
        self.state = RotateStateAccelUp;
        self.tick = rotate_object_tween_tick;
        self.distance = fabs(self.distance);
        RegisterFrameTickEntity(self);
        return;
        
    case RotateStateAccelUp:
        self.state = RotateStateDecelDown;
        self.tick = rotate_object_tween_tick;
        self.distance = -fabs(self.distance);
        return;
        
    case RotateStateOn:
        self.state = RotateStateDecelDown;
        self.tick = rotate_object_tween_tick;
        self.distance = -fabs(self.distance);
        return;
    
    case RotateStateDecelDown:
        self.state = RotateStateAccelUp;
        self.tick = rotate_object_tween_tick;
        self.distance = fabs(self.distance);
        return;
    }
}

/*QUAKED rotate_object_continuously (0.4 1.0 0.6) (? ? ?) (? ? ?) START_OFF 
Non-solid object that rotates continuously.
Trigger to turn on and off.
*/
void rotate_object_continuously()
{
    if(!self.avelocity)
    {
        self.avelocity = '0 30 0';
    }
    if(self.delay > 0)
    {
        self.distance = 1 / self.delay;
    }

    if(self.spawnflags & SOLID_BSP)
    {
        self.movetype = MOVETYPE_PUSH;
        self.solid = SOLID_BSP;
    }
    else
    {
        self.movetype = MOVETYPE_NONE;
        self.solid = SOLID_NOT;
    }
    self.angles = '0 0 0';
    if(self.pos2)
    {
        self.origin = self.pos2;
        setorigin(self, self.origin);
    }
    setmodel(self, self.model);
    
    self.use = rotate_object_continuously_use;
    self.tick = rotate_object_continuously_tick;

    if(self.spawnflags & START_OFF)
    {
        self.state = RotateStateOff;
    }
    else
    {
        self.state = RotateStateOn;
        self.speed = 1;
        RegisterFrameTickEntity(self);
    }
}

/*
===============================================================================
Accel/decel rotation
===============================================================================
*/


