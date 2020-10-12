//=============================================================================
// LS14Carbine.
//
// No, it's not really a carbine. Shut up.
//
// A semi-auto laser rifle coded to behave like the ones from call of duty.
// Secondary fire has a triple drunk rocket launcher that reloads after
// three shots. Suffers from long-gun and recoil with use.
// A good long and mid range rifle.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2007 RuneStorm. All Rights Reserved.
// Modified by Marc 'Sergeant Kelly' Moylan
// Scope code by Kaboodles
//=============================================================================
class LS14Carbine extends BallisticWeapon;


var float		HeatLevel;			// Current Heat level, duh...
var() Sound		OverHeatSound;		//Sounds for hot firing
var() Sound		GrenOpenSound;		//Sounds for rocket reloading
var() Sound		GrenLoadSound;		//
var() Sound		GrenCloseSound;		//
var() Sound		DoubleVentSound;	//Sound for double fire's vent

var   actor GLIndicator;
var() name		GrenadeLoadAnim;	//Anim for rocket reload
var() name		SingleGrenadeLoadAnim;	//Anim for rocket reload loop
var() name		HatchOpenAnim;
var() name		HatchCloseAnim;
var() Name		ShovelAnim;		//Anim to play after shovel loop ends
var() int       Rockets;		//Rockets currently in the gun.
var() int       ConfigX;		//Rockets currently in the gun.
var() int       ConfigY;		//Rockets currently in the gun.
var	bool		bHeatOnce;		//Used for playing a sound once.
var	bool		bBarrelsOnline;		//Used for alternating laser effect in attachment class.
var	bool		bIsReloadingGrenade;	//Are we loading grenades?
var	bool		bWantsToShoot;	//Are we interrupting reload?
var	bool		bOverloaded;	//You exploded it.
var float		lastModeChangeTime;
var() Material	StabBackTex;
var(Gfx) Color ChargeColor;
var(Gfx) vector RechargeOrigin;
var(Gfx) vector RechargeSize;


var actor HeatSteam;
var actor BarrelFlare;
var actor BarrelFlareSmall;
var actor VentCore;
var actor VentBarrel;
var actor CoverGlow;

struct RevInfo
{
	var() name	Shellname;
};
var() RevInfo	Shells[3];

replication
{
	// Things the server should send to the client.
	unreliable if( bNetOwner && bNetDirty && (Role==ROLE_Authority) )
		Rockets;
	reliable if (Role == ROLE_Authority)
		ClientSwitchCannonMode;
//	unreliable if (Role == Role_Authority)
//		ClientGrenadePickedUp;
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.5;
		ChaosAimSpread *= 0.5;
	}

//	Core Glow Effect
	if (CoverGlow != None)
		CoverGlow.Destroy();

    	if (Instigator.IsLocallyControlled() && level.DetailMode >= DM_SuperHigh && class'BallisticMod'.default.EffectsDetailMode >= 2)
    	{
    	CoverGlow = None;
	class'BUtil'.static.InitMuzzleFlash (CoverGlow, class'LS14GlowFX', DrawScale, self, 'BarrelGlow');
	}
}


// Only skips for alternate reload
simulated function FirePressed(float F)
{
	if ((ReloadState == RS_Shovel) || (ReloadState == RS_PostShellIn))
	{
		ServerSkipReload();
		if (Level.NetMode == NM_Client)
			SkipReload();
	}
	if (!HasAmmo())
		OutOfAmmo();
	else if (bNeedReload && ClientState == WS_ReadyToFire)
	{
		// Removed and replaced by EmptyFire()
//		ServerStartReload();
	}
	else if (reloadState == RS_None && bNeedCock && MagAmmo > 0 && !IsFiring() && level.TimeSeconds > FireMode[0].NextfireTime)
	{
		CommonCockGun();
		if (Level.NetMode == NM_Client)
			ServerCockGun();
	}
}
//simulated function Fire(float F)	{	FirePressed(F);	}
simulated function AltFire(float F)	{	FirePressed(F);	}

simulated function EmptyAltFire (byte Mode)
{
	if (Rockets <= 0 && ClientState == WS_ReadyToFire && FireCount < 1 && Instigator.IsLocallyControlled())
		ServerStartReload();
}

//Skip reloading if fire is pressed in time
simulated function SkipReload()
{
	if (ReloadState == RS_Shovel || ReloadState == RS_PostShellIn)
	{//Leave shovel loop and go to EndShovel

		if (Rockets < 3)
			SetBoneScale(2, 0.0, Shells[2].ShellName);
		PlayShovelEnd();
		ReloadState = RS_EndShovel;
	}
	else if (ReloadState == RS_PreClipOut)
	{//skip reload if clip has not yet been pulled out
		ReloadState = RS_PostClipIn;
		SetAnimFrame(ClipInFrame);
	}
}

//Show little tiny rockets
simulated function DrawWeaponInfo(Canvas C)
{
	NewDrawWeaponInfo(C, 0.705*C.ClipY);
}


simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	local int i,Count;
	local float ScaleFactor2;

	local float		ScaleFactor, XL, YL, YL2, SprintFactor;
	local string	Temp;

	Super.NewDrawWeaponInfo (C, YPos);

	ScaleFactor = C.ClipX / 1600;
	// Draw the spare ammo amount
	C.Font = GetFontSizeIndex(C, -2 + int(2 * class'HUD'.default.HudScale));
	C.DrawColor = class'hud'.default.WhiteColor;
	if (!bNoMag)
	{
		Temp = GetHUDAmmoText(0);
		C.TextSize(Temp, XL, YL);
		C.CurX = C.ClipX - 20 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 120 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(Temp, false);
	}
	if (Ammo[1] != None && Ammo[1] != Ammo[0])
	{
		Temp = GetHUDAmmoText(1);
		C.TextSize(Temp, XL, YL);
		C.CurX = C.ClipX - 160 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 120 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(Temp, false);
	}

	if (CurrentWeaponMode < WeaponModes.length && !WeaponModes[CurrentWeaponMode].bUnavailable && WeaponModes[CurrentWeaponMode].ModeName != "")
	{
		C.Font = GetFontSizeIndex(C, -3 + int(2 * class'HUD'.default.HudScale));
		C.TextSize(WeaponModes[CurrentWeaponMode].ModeName, XL, YL2);
		C.CurX = C.ClipX - 15 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 130 * ScaleFactor * class'HUD'.default.HudScale - YL2 - YL;
		C.DrawText(WeaponModes[CurrentWeaponMode].ModeName, false);
	}

	// This is pretty damn disgusting, but the weapon seems to be the only way we can draw extra info on the HUD
	// Would be nice if someone could have a HUD function called along the inventory chain
	if (SprintControl != None && SprintControl.Stamina < SprintControl.MaxStamina)
	{
		SprintFactor = SprintControl.Stamina / SprintControl.MaxStamina;
		C.CurX = C.OrgX  + 5    * ScaleFactor * class'HUD'.default.HudScale;
		C.CurY = C.ClipY - 330  * ScaleFactor * class'HUD'.default.HudScale;
		if (SprintFactor < 0.2)
			C.SetDrawColor(255, 0, 0);
		else if (SprintFactor < 0.5)
			C.SetDrawColor(64, 128, 255);
		else
			C.SetDrawColor(0, 0, 255);
		C.DrawTile(Texture'Engine.MenuWhite', 200 * ScaleFactor * class'HUD'.default.HudScale * SprintFactor, 30 * ScaleFactor * class'HUD'.default.HudScale, 0, 0, 1, 1);
	}

	DrawCrosshairs(C);

	ScaleFactor2 = 99 * C.ClipX/3200;
	C.Style = ERenderStyle.STY_Alpha;
	C.DrawColor = class'HUD'.Default.WhiteColor;
	Count = Min(8,Rockets);
    	for( i=0; i<Count; i++ )
    	{
//		C.SetPos(C.ClipX - (0.5*i+1) * ScaleFactor2, YPos);
		C.SetPos(C.ClipX - (0.5*i+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale);
		C.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14-RocketIcon', ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
	}
	if ( Rockets > 8 )
	{
		Count = Min(16,Rockets);
		for( i=8; i<Count; i++ )
		{
			C.SetPos(C.ClipX - (0.5*(i-8)+1) * ScaleFactor2, YPos - ScaleFactor2);
			C.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14-RocketIcon', ScaleFactor2, ScaleFactor2, 174, 259, 46, 45);
		}
	}
}

// Heat Junk
simulated event Tick (float DT)
{
//	if (HeatLevel >= 14 && bScopeView)
//			TemporaryScopeDown(0.5);
	if (HeatLevel > 0)
	{
			Heatlevel = FMax(HeatLevel - 2.5 * DT, 0);
	}
	super.Tick(DT);
}

simulated function AddHeat(float Amount)
{
	if (HeatLevel >= 10 && HeatLevel < 14.5)
	{
		if (CurrentWeaponMode == 0)
		{
			PlaySound(OverHeatSound,,3.7,,32);
           		BallisticInstantFire(FireMode[0]).FireRate=0.4;
		}
		class'BUtil'.static.InitMuzzleFlash (HeatSteam, class'RSNovaSteam', DrawScale, self, 'BarrelGlow');
	}
	else
	{
		if (CurrentWeaponMode == 2)            
			BallisticInstantFire(FireMode[0]).FireRate= 0.3;
		else
            BallisticInstantFire(FireMode[0]).FireRate= BallisticInstantFire(FireMode[0]).default.FireRate;
	}

	HeatLevel += Amount;
}

simulated function ClientSetHeat(float NewHeat)
{
	HeatLevel = NewHeat;
}

//Prototype Venting Code
simulated function LS14_DoubleVent()		
{	
		if (CurrentWeaponMode == 1)
		{
		AddHeat(-1);
		PlaySound(DoubleVentSound, SLOT_Misc, 0.5, ,32);	
		class'BUtil'.static.InitMuzzleFlash (HeatSteam, class'RSNovaSteam', DrawScale, self, 'BarrelGlow');
		}
}
//Prototype Overheat code
simulated function LS14Overheat()		
{	
		Heatlevel = 15;
		TemporaryScopeDown(0.5);
		bOverloaded=true;
		class'BallisticDamageType'.static.GenericHurt (Instigator, 0, Instigator, Instigator.Location, -vector(Instigator.GetViewRotation()) * 30000 + vect(0,0,10000), class'DTLS14Body');
		Firemode[0].NextFireTime += 4.0;
		class'bUtil'.static.InitMuzzleFlash(BarrelFlare, class'HVCMk9MuzzleFlash', DrawScale, self, 'BarrelGlow');
}
//Prototype Overheat code
simulated function LS14OverheatDbl()		
{	
		Heatlevel = 15;
		class'BallisticDamageType'.static.GenericHurt (Instigator, 0, Instigator, Instigator.Location, -vector(Instigator.GetViewRotation()) * 30000 + vect(0,0,10000), class'DTLS14Body');
		Firemode[0].NextFireTime += 3.0;
		class'BUtil'.static.InitMuzzleFlash(VentBarrel, class'CoachSteam', DrawScale, self, 'tip');
		class'BUtil'.static.InitMuzzleFlash(HeatSteam, class'CoachSteam', DrawScale, self, 'BarrelGlow');
}
simulated function LS14OverheatS2()		
{		
		if (BarrelFlare != None)	BarrelFlare.Destroy();	
		class'bUtil'.static.InitMuzzleFlash(BarrelFlareSmall, class'LS14BarrelOverheat', DrawScale, self, 'BarrelGlow');
}
simulated function LS14ForceCool()		
{	
		Heatlevel = 9;
		bOverloaded=false;
		class'BUtil'.static.InitMuzzleFlash(HeatSteam, class'RSNovaSteam', DrawScale, self, 'BarrelGlow');
		class'BUtil'.static.InitMuzzleFlash(VentBarrel, class'CoachSteam', DrawScale, self, 'tip');
		class'BUtil'.static.KillEmitterEffect (BarrelFlare);
		class'BUtil'.static.KillEmitterEffect (BarrelFlareSmall);
//		if (BarrelFlare != None)	BarrelFlare.Destroy();
//		if (BarrelFlareSmall != None)	BarrelFlareSmall.Destroy();
}

simulated event RenderOverlays (Canvas Canvas)
{
	local float tileScaleX;
	local float tileScaleY;
	local float HeatBar;

	local float	ScaleFactor;

	local float barOrgX;
	local float barOrgY;
	local float barSizeX;
	local float barSizeY;

//	if (!bScopeView && BarrelFlare != None)
//		DrawElectro(Canvas);

	if (!bScopeView)
	{
		Super(Weapon).RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}
	ScaleFactor = Canvas.ClipX / 1600;

    if (ScopeViewTex != None) //Now resets gun variables
    {
		if (CurrentWeaponMode == 1)
		{
	        Canvas.SetDrawColor(255,255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14ScopeDbl', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14ScopeDbl', Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14ScopeDbl', (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1);
		}
		else if (CurrentWeaponMode == 2)
		{
			// We're in double mode
			Canvas.SetPos(Canvas.OrgX+ Canvas.OrgX/4, Canvas.OrgY + Canvas.OrgY/4);
			Canvas.SetDrawColor(255,255,255,255);
			Canvas.DrawTile(Texture'BWBP_SKC_Tex.LS14.LS14ScopeDbl', 1024, 1024, 0, 0, 1024, 1024);
		}
		else
		{
	        Canvas.SetDrawColor(255,255,255,255);
		//Left Border
        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		//Scope
        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);
		//Right Border
        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		}

		Canvas.Font = GetFontSizeIndex(Canvas, -2 + int(2 * class'HUD'.default.HudScale));
//		if ((Canvas.SizeX/Canvas.SizeY) > 1.4)
//			Canvas.SetPos(configX,ConfigY);
//		else
//			Canvas.SetPos(Canvas.SizeX*0.5625, Canvas.SizeY*0.708);
//		Canvas.DrawText(MagAmmo, false);

		if ((Canvas.ClipX/Canvas.ClipY) > 1.4)
		{
			Canvas.SetPos(Canvas.SizeX*0.549,Canvas.SizeY*0.689);
			Canvas.DrawText(Rockets, false);
		}
		else
		{
			Canvas.SetPos(Canvas.SizeX*0.56, Canvas.SizeY*0.7);
			Canvas.DrawText(Rockets $ "R", false);
		}

		// Draw the Charging meter  -AsP

		HeatBar = HeatLevel/15;

		barOrgX = RechargeOrigin.X * tileScaleX;
		barOrgY = RechargeOrigin.Y * tileScaleY;

		barSizeX = RechargeSize.X * tileScaleX;
		barSizeY = RechargeSize.Y * tileScaleY;

		Canvas.DrawColor = ChargeColor;
        	Canvas.DrawColor.A = 255;

		if(HeatBar <1)
		    	Canvas.DrawColor.R = 255*HeatBar;

		if(HeatBar == 0)
		    	Canvas.DrawColor.G = 255;
		else
		    	Canvas.DrawColor.G = 0;

		Canvas.Style = ERenderStyle.STY_Alpha;
		if ((Canvas.ClipX/Canvas.ClipY) > 1.5)
			Canvas.SetPos(Canvas.SizeX*0.366,Canvas.SizeY*0.651);
		else
			Canvas.SetPos(Canvas.SizeX*0.316,Canvas.SizeY*0.645);
		//Canvas.DrawTile(Texture'Engine.WhiteTexture',barSizeX*HeatBar,barSizeY, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize*HeatBar,Texture'Engine.WhiteTexture'.VSize);
		Canvas.DrawTile(Texture'Engine.WhiteTexture',1+100*HeatBar,15, 0.0, 0.0,Texture'Engine.WhiteTexture'.USize*HeatBar,Texture'Engine.WhiteTexture'.VSize);

		if (BarrelFlare != None)	BarrelFlare.Destroy();
		if (BarrelFlareSmall != None)	BarrelFlareSmall.Destroy();
		bOverloaded=false;
	}
}

simulated event DrawElectro (Canvas C)
{
	// Draw Green Circle
	// Draw some panning lines
	C.SetPos(C.OrgX, C.OrgY);
	C.DrawTile(TexPanner'BWBP_SKC_Tex.LS14.ElectroShock', C.SizeX, C.SizeY, 0, 0, 512, 512);
}


// End Heat Junk

simulated function UpdateGLIndicator()
{
	if (!Instigator.IsLocallyControlled())
		return;
	if (LS14SecondaryFire(FireMode[1]).bLoaded)
	{
		if (GLIndicator == None)
			class'BUtil'.static.InitMuzzleFlash(GLIndicator, class'M50GLIndicator', DrawScale, self, 'tip');
	}
	else if (GLIndicator != None)
	{
		GLIndicator.Destroy();
		GLIndicator = None;
	}
}



// Notifys for greande loading sounds
simulated function LS14HatchOpen()	
{	
	PlaySound(GrenOpenSound, SLOT_Misc, 0.5, ,64);
}
simulated function LS14RocketsIn()		
{	PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);	
	LS14SecondaryFire(FireMode[1]).bLoaded = true;	
	UpdateGLIndicator();    
	Rockets = 3;
	ReloadState = RS_PostClipIn;    	
}
simulated function LS14HatchClose()	
{	
	ReloadState = RS_EndShovel;
	PlaySound(GrenCloseSound, SLOT_Misc, 0.5, ,64); 
}

simulated function LS14RocketIn()		
{	
		PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);	
		UpdateGLIndicator();    
		ReloadState = RS_PostShellIn;	
		if (Role == ROLE_Authority)
		{
			Rockets += 1;
			Ammo[1].UseAmmo (1, True);
		}
}

/*
simulated function LS14GoToLoop()
{
//		if (SightingState != SS_None)
//			TemporaryScopeDown(0.5);
		if (bWantsToShoot)
		{
      			SafePlayAnim(HatchCloseAnim, 1.0, 0.0, , "RELOAD");
				if (Rockets < 3)
					SetBoneScale(2, 0.0, Shells[2].ShellName);
		}
		else	
		{
			PlayAnim(SingleGrenadeLoadAnim,1.0, 0.0);
			ReloadState = RS_Shovel;
			SetBoneScale(2, 1.0, Shells[2].ShellName);
		}	
//      	PlayAnim('SingleGrenadeLoadAnim', 1.0, 0.1);	
}
simulated function LS14ContinueLoop()
{
	if (Rockets == 3 || Ammo[1].AmmoAmount == 0 || (Ammo[1].AmmoAmount < 3 && Rockets == Ammo[1].AmmoAmount) || bWantsToShoot)
	{
      	SafePlayAnim(HatchCloseAnim, 1.0, 0.0, , "RELOAD");	
		return;
	}
	else	
	{
		PlayAnim(SingleGrenadeLoadAnim,1.0, 0.0);
		SetBoneScale(2, 1.0, Shells[2].ShellName);
		ReloadState = RS_Shovel;
	}	
//     PlayAnim('SingleGrenadeLoadAnim', 1.0, 0.1);
	return;
}*/

/*/ A grenade has just been picked up. Loads one in if we're empty
function GrenadePickedUp ()
{
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (Instigator.Weapon == self)
			LoadGrenade();
		else
			LS14SecondaryFire(FireMode[1]).bLoaded=true;
	}
	if (!Instigator.IsLocallyControlled())
		ClientGrenadePickedUp();
}

simulated function ClientGrenadePickedUp()
{
	if (Ammo[1].AmmoAmount < Ammo[1].MaxAmmo)
	{
		if (ClientState == WS_ReadyToFire)
			LoadGrenade();
		else
			LS14SecondaryFire(FireMode[1]).bLoaded=true;
	}
}*/
simulated function bool IsGrenadeLoaded()
{
	return LS14SecondaryFire(FireMode[1]).bLoaded;
}

/*/ Tell our ammo that this is the LS14 it must notify about grenade pickups
function GiveAmmo(int m, WeaponPickup WP, bool bJustSpawned)
{
	Super.GiveAmmo(m, WP, bJustSpawned);
	if (Ammo[1] != None && Ammo_LS14Rocket(Ammo[1]) != None)
		Ammo_LS14Rocket(Ammo[1]).DaM50 = self;
}*/

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);
	if (anim == SingleGrenadeLoadAnim)
	{
		IdleTweenTime=0.0;
		PlayIdle();
	}
	else
		IdleTweenTime=default.IdleTweenTime;

	if (ReloadState == RS_PostShellIn)
	{
		if (Rockets == 3 || Ammo[1].AmmoAmount == 0)
		{
			PlayShovelEnd();
			ReloadState = RS_EndShovel;
			return;
		}
		ReloadState = RS_Shovel;
		SetBoneScale(2, 1.0, Shells[2].ShellName);
		PlayShovelLoop();
		return;
	}
	Super.AnimEnd(Channel);
}
// Load in 3 grenades
simulated function LoadGrenade()
{
	if (Ammo[1].AmmoAmount < 3 || LS14SecondaryFire(FireMode[1]).bLoaded)
		return;

	if (ReloadState == RS_None)
	{
		PlayAnim(HatchOpenAnim, 1.1, , 0);
		ReloadState = RS_PreClipOut;
	}
}

// Load in a grenade
simulated function LoadGrenadeLoop()
{
	if (Ammo[1].AmmoAmount < 1)
		return;
	if (ReloadState == RS_None)
	{
		PlayAnim(HatchOpenAnim, 1.1, , 0);
		ReloadState = RS_StartShovel;
	}
}

simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	if (i == 1)
	{
		ReloadState = RS_StartShovel;
		PlayReloadAlt();
	}
	else
	{
		ReloadState = RS_PreClipOut;
		PlayReload();
	}

	if (bScopeView && Instigator.IsLocallyControlled())
		TemporaryScopeDown(Default.SightingTime*Default.SightingTimeScale);
	for (m=0; m < NUM_FIRE_MODES; m++)
		if (BFireMode[m] != None)
			BFireMode[m].ReloadingGun(i);

	if (bCockAfterReload)
		bNeedCock=true;
	if (bCockOnEmpty && MagAmmo < 1)
		bNeedCock=true;
	bNeedReload=false;
}

simulated function PlayReloadAlt()
{
	SafePlayAnim(StartShovelAnim, StartShovelAnimRate, , 0, "RELOAD");
}



function ServerStartReload (optional byte i)
{
	local int m;

	if (bPreventReload)
		return;
	if (ReloadState != RS_None)
		return;
	if (MagAmmo >= default.MagAmmo && ( Ammo[1].AmmoAmount < 1 ||  Rockets >= 3)) //Pri Full - Alt Can't
		return;

	if (Rockets >= 3 && Ammo[0].AmmoAmount < 1) //Can't reload pri
		return;
	if (Ammo[0].AmmoAmount < 1 && Ammo[1].AmmoAmount < 1) //Can't reload any
		return;

	for (m=0; m < NUM_FIRE_MODES; m++)
		if (FireMode[m] != None && FireMode[m].bIsFiring)
			StopFire(m);

	bServerReloading = true;
	if (Rockets < 3 && Ammo[1].AmmoAmount != 0 && (MagAmmo >= default.MagAmmo/2 || Ammo[0].AmmoAmount < 1))
	{
		CommonStartReload(1);	//Server animation
		ClientStartReload(1);
	}
	else
	{
		CommonStartReload(0);	//Server animation
		ClientStartReload(0);	//Client animation
	}
}

simulated function ClientStartReload(optional byte i)
{
	if (Level.NetMode == NM_Client)
	{
		if (i == 1)
			CommonStartReload(1);
		else
			CommonStartReload(0);
	}
}


simulated function bool CheckWeaponMode (int Mode)
{
	if (Mode == 1)
		return FireCount < 1;
	return super.CheckWeaponMode(Mode);
}


simulated function bool PutDown()
{
	if (super.PutDown())
	{
		if (BarrelFlare != None)	BarrelFlare.Destroy();
		if (BarrelFlareSmall != None)	BarrelFlareSmall.Destroy();
	}
	bOverloaded=false;
	return false;
}
simulated function Destroyed()
{
	if (BarrelFlare != None)	BarrelFlare.Destroy();
	if (BarrelFlareSmall != None)	BarrelFlareSmall.Destroy();
	if (CoverGlow != None)
		CoverGlow.Destroy();
	super.Destroyed();
}

simulated function Notify_BrassOut()
{
//	BFireMode[0].EjectBrass();
}

function bool BotShouldReloadGrenade ()
{
	if ( (Level.TimeSeconds - Instigator.LastPainTime > 1.0) )
		return true;
	return false;
}

simulated event WeaponTick(float DT)
{
	local int i;
	super.WeaponTick(DT);

	if (LS14PrimaryFire(FireMode[0]).bSecondBarrel)
		bBarrelsOnline=true;
	if (AIController(Instigator.Controller) != None && !IsGrenadeLoaded()&& AmmoAmount(1) > 0 && BotShouldReloadGrenade() && !IsReloadingGrenade())
		LoadGrenade();

	if (Rockets<0)
		Rockets=0;
	for(i=2;i>(Rockets-1);i--)
	{
		if (ReloadState == RS_None)
		SetBoneScale(i, 0.0, Shells[i].ShellName);
	}
	for(i=0;i<Rockets;i++)
		SetBoneScale(i, 1.0, Shells[i].ShellName);


}

simulated function float RateSelf()
{
	if (!HasAmmo())
		CurrentRating = 0;
	else if (Ammo[0].AmmoAmount < 1 && MagAmmo < 1)
		CurrentRating = Instigator.Controller.RateWeapon(self)*0.3;
	else
		return Super.RateSelf();
	return CurrentRating;
}


// Targeted hurt radius moved here to avoid crashing

simulated function TargetedHurtRadius( float DamageAmount, float DamageRadius, class<DamageType> DamageType, float Momentum, vector HitLocation, optional Pawn ExcludedPawn )
{
	local actor Victims;
	local float damageScale, dist;
	local vector dir;

	if( bHurtEntry ) //not handled well...
		return;

	bHurtEntry = true;
	
	foreach VisibleCollidingActors( class 'Actor', Victims, DamageRadius, HitLocation )
	{
		// don't let blast damage affect fluid - VisibleCollisingActors doesn't really work for them - jag
		if( (Victims != self) && (Victims.Role == ROLE_Authority) && !Victims.IsA('FluidSurfaceInfo') && (ExcludedPawn == None || Victims != ExcludedPawn))
		{
			dir = Victims.Location - HitLocation;
			dist = FMax(1,VSize(dir));
			dir = dir/dist;
			damageScale = 1 - FMax(0,(dist - Victims.CollisionRadius)/DamageRadius);
			class'BallisticDamageType'.static.GenericHurt
			(
				Victims,
				damageScale * DamageAmount,
				Instigator,
				Victims.Location - 0.5 * (Victims.CollisionHeight + Victims.CollisionRadius) * dir,
				(damageScale * Momentum * dir),
				DamageType
			);
		}
	}
	bHurtEntry = false;
}


// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Result, Height, Dist, VDot;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;
	if (AmmoAmount(1) < 1 || !IsGrenadeLoaded())
		return 0;
	else if (MagAmmo < 1)
		return 1;

	if (CurrentWeaponMode != 2)
		CurrentWeaponMode = 2;
	Dist = VSize(B.Enemy.Location - Instigator.Location);
	Height = B.Enemy.Location.Z - Instigator.Location.Z;
	VDot = Normal(B.Enemy.Velocity) Dot Normal(Instigator.Location - B.Enemy.Location);

	Result = FRand()-0.3;
	// Too far for grenade
	if (Dist > 800)
		Result -= (Dist-800) / 2000;
	// Too close for grenade
	if (Dist < 500 &&  VDot > 0.3)
		result -= (500-Dist) / 1000;
	if (VSize(B.Enemy.Velocity) > 50)
	{
		// Straight lines
		if (Abs(VDot) > 0.8)
			Result += 0.1;
		// Enemy running away
		if (VDot < 0)
			Result -= 0.2;
		else
			Result += 0.2;
	}


	// Higher than enemy
//	if (Height < 0)
//		Result += 0.1;
	// Improve grenade acording to height, but temper using horizontal distance (bots really like grenades when right above you)
	Dist = VSize(B.Enemy.Location*vect(1,1,0) - Instigator.Location*vect(1,1,0));
	if (Height < -100)
		Result += Abs((Height/2) / Dist);

	if (Result > 0.5)
		return 1;
	return 0;
}

simulated function bool IsReloadingGrenade()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
	if (Anim == SingleGrenadeLoadAnim)
 		return true;
	return false;
}

function bool CanAttack(Actor Other)
{
	if (!IsGrenadeLoaded())
	{
		if (IsReloadingGrenade())
		{
			if ((Level.TimeSeconds - Instigator.LastPainTime > 1.0))
				return false;
		}
		else if (AmmoAmount(1) > 0 && BotShouldReloadGrenade())
		{
			LoadGrenade();
			return false;
		}
	}
	return super.CanAttack(Other);
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return AIRating;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = Super.GetAIRating();
	if (Dist < 500)
		Result -= 1-Dist/500;
	else if (Dist < 3000)
		Result += (Dist-1000) / 2000;
	else
		Result = (Result + 0.66) - (Dist-3000) / 2500;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.8;	}
// End AI Stuff =====

simulated function float ChargeBar()
{
	return HeatLevel/15;
}

function ServerSwitchWeaponMode (byte NewMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode(NewMode);
	LS14Attachment(ThirdPersonActor).bDouble = bool(CurrentWeaponMode);
	if (!Instigator.IsLocallyControlled())
		LS14PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	LS14PrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}

simulated function PlayShovelLoop()
{

	SetBoneScale(2, 1.0, Shells[2].ShellName);
	SafePlayAnim(ShovelAnim, ReloadAnimRate, 0.0, , "RELOAD");
}

defaultproperties
{
     OverHeatSound=Sound'WeaponSounds.BaseImpactAndExplosions.BShieldReflection'
     GrenOpenSound=Sound'BallisticSounds2.M50.M50GrenOpen'
     GrenLoadSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     GrenCloseSound=Sound'BallisticSounds2.M50.M50GrenClose'
     DoubleVentSound=Sound'BWBP_SKC_Sounds.CYLO.CYLO-MedHeat'
     ChargeColor=(B=100,G=255,R=255,A=255)
     RechargeOrigin=(X=600.000000,Y=330.000000)
     RechargeSize=(X=10.000000,Y=-180.000000)
     HatchOpenAnim="RLLoadPrep"
     HatchCloseAnim="RLLoadEnd"
	EndShovelAnim="RLLoadEnd"
     SingleGrenadeLoadAnim="RLLoadLoop"
     GrenadeLoadAnim="RLLoad"

	StartShovelAnim="RLLoadPrep"
	ShovelAnim="RLLoadLoop"

     Shells(0)=(ShellName="RocketThree")
     Shells(1)=(ShellName="RocketTwo")
     Shells(2)=(ShellName="RocketOne")
     Rockets=3.000000
     PlayerSpeedFactor=1.100000
     PlayerJumpFactor=1.100000
     PutDownAnimRate=1.500000
     PutDownTime=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=0)
     BigIconMaterial=Texture'BWBP_SKC_Tex.LS14.BigIcon_LS14'
     BallisticInventoryGroup=7
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Bullet=True
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Projectile=True
     bWT_Energy=True
     bNoCrosshairInScope=true;
     SpecialInfo(0)=(Info="240.0;15.0;1.1;90.0;1.0;0.0;0.3")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-Select')
     PutDownSound=(Sound=Sound'BWBP_SKC_Sounds.LS14.Gauss-Deselect')
     MagAmmo=20
     CockSound=(Sound=Sound'BallisticSounds3.USSR.USSR-Cock')
     ClipHitSound=(Sound=Sound'BallisticSounds3.USSR.USSR-ClipHit')
     ClipOutSound=(Sound=Sound'BallisticSounds3.USSR.USSR-ClipOut')
     ClipInSound=(Sound=Sound'BallisticSounds3.USSR.USSR-ClipIn')
     ClipInFrame=0.650000
     bNeedCock=True
     WeaponModes(0)=(ModeName="Single Barrel")
     WeaponModes(1)=(ModeName="Double Barrel",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(2)=(ModeName="Bot Firemode",ModeID="WM_FullAuto",bUnavailable=True)
     CurrentWeaponMode=0
     ScopeViewTex=Texture'BWBP_SKC_Tex.LS14.LS14Scope'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=40.000000
	 ZoomType=ZT_Logarithmic
     bNoMeshInScope=True
     SightPivot=(Pitch=600,Roll=-1024)
     SightOffset=(X=18.000000,Y=-8.500000,Z=22.000000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.A73InA',Pic2=Texture'BallisticUI2.Crosshairs.Misc5',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,A=192),Color2=(B=158,G=150,R=0,A=124),StartSize1=54,StartSize2=59)
     GunLength=80.000000
     CrouchAimFactor=0.600000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     SprintChaos=1.000000
     AimSpread=(X=(Min=-20.000000,Max=20.000000),Y=(Min=-20.000000,Max=20.000000))
     ViewAimFactor=0.250000
     ViewRecoilFactor=0.550000
     ChaosDeclineTime=1.500000
     ChaosAimSpread=(X=(Min=-1250.000000,Max=1400.000000),Y=(Min=-1250.000000,Max=1400.000000))
     RecoilYawFactor=0.100000
     RecoilXFactor=0.700000
     RecoilYFactor=0.700000
     RecoilDeclineTime=1.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.LS14PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.LS14SecondaryFire'
     BringUpTime=0.500000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.600000
     CurrentRating=0.600000
     bSniping=True
     bShowChargingBar=True
     Description="LS-14 Directed Energy Projection Weapon||Manufacturer: UTC Defense Tech|Primary: Focused Photon Beam|Secondary: Mini Rockets||The LS-14 Laser Carbine is UTC Defense Tech's latest energy based assault weapon. The LS-14 features a computer control system which allows the weapon to moderate both primary and secondary functions, and has an easy to read screen that can tell the user the status of its various systems. Ammunition counts, heat levels, and many other useful bits of information are simply a touch of a button away - a feature praised by many soldiers. This laser carbine features a magazine style battery, a side mounted mini rocket launcher, and a scope, making this weapon incredibly versatile. ||Unlike other directed energy weapons, the LS14 comes with a multitude of integrated safety features that prevent it from critically overloading, however these can be disabled if the user wishes. It is important to note that while the LS-14 is primarily a recoilless laser weapon, it is known to expel excess gas at higher temperatures which can make aiming difficult."
     Priority=194
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=9
     PickupClass=Class'BWBP_SKC_Fix.LS14Pickup'
     PlayerViewOffset=(X=-5.000000,Y=12.000000,Z=-15.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.LS14Attachment'
     IconMaterial=Texture'BWBP_SKC_Tex.LS14.SmallIcon_LS14'
     IconCoords=(X2=127,Y2=31)
     ItemName="LS-14 Laser Carbine"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.LS14Carbine'
     DrawScale=0.300000
}
