//=============================================================================
// Mk781Shotgun.
//
// The Mk781 auto shottie, aka the LASERLASER
// Silencer increases accuracy. Lowres poers.
// alt fire puts in fancy shells.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class Mk781Shotgun extends BallisticCamoWeapon;


var   bool		bSilenced;				// Silencer on. Silenced
var() name		SilencerBone;			// Bone to use for hiding silencer
var() name		SilencerOnAnim;			// Think hard about this one...
var() name		SilencerOffAnim;		//
var() sound		SilencerOnSound;		// Silencer stuck on sound
var() sound		SilencerOffSound;		//
var() sound		SilencerOnTurnSound;		// Silencer screw on sound
var() sound		SilencerOffTurnSound;		//
var() float		SilencerSwitchTime;		//

var() Name		SGPrepAnim;			//Anim to use for loading special shells
var() Name		ReloadAltAnim;			//Anim to use for Reloading special shells
var() Name		ReloadAnimEmpty;		//Anim to use for Reloading from 0

var() Sound		GrenLoadSound;		//
var() float       	VisGrenades;		//Rockets currently visible in tube.
var() int       	Grenades;		//Rockets currently in the gun.
var() byte		LastWeaponMode;		//Used to store the last referenced firemode pre Alt
var() bool		bReady;			//Weapon ready for alt fire
var   byte				ShellIndex;

struct RevInfo
{
	var() name	Shellname;
};
var() RevInfo	Shells[6];

replication
{
	// Things the server should send to the client.
	reliable if(Role==ROLE_Authority)
		Grenades, bReady;
	reliable if (Role < ROLE_Authority)
		ServerSwitchSilencer;
}

simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.97) || Index == 4) //3% Tiger
		{
			if (bAllowCamoEffects)
				BallisticInstantFire(FireMode[0]).FireRate=0.3;
			Skins[1]=CamoMaterials[4];
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.90) || Index == 3) //7% AMERICA
		{
			Skins[1]=CamoMaterials[3];
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.85) || Index == 2) //10% Desert
		{
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.75) || Index == 1) //10% Digital
		{
			Skins[1]=CamoMaterials[1];
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[0];
			CamoIndex=0;
		}
}

//SPECIAL AMMO CODE -----------------------------------------------------


simulated function EmptyAltFire (byte Mode)
{
	if (Grenades <= 0 && ClientState == WS_ReadyToFire && FireCount < 1 && Instigator.IsLocallyControlled())
		ServerStartReload(Mode);
}


simulated function DrawWeaponInfo(Canvas Canvas)
{
	NewDrawWeaponInfo(Canvas, 0.705*Canvas.ClipY);
}
//Modified to subtract active grenades and add little icons
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	local int i,Count;
	local float ScaleFactor2;

	local float		ScaleFactor, XL, YL, YL2, SprintFactor;
	local string	Temp;
	local int	TempNum;

//	Super.NewDrawWeaponInfo (C, YPos);

	ScaleFactor = C.ClipX / 1600;
	// Draw the spare ammo amount
	C.Font = GetFontSizeIndex(C, -2 + int(2 * class'HUD'.default.HudScale));
	C.DrawColor = class'hud'.default.WhiteColor;
	if (!bNoMag)
	{
		Temp = GetHUDAmmoText(0);
		C.TextSize(Temp, XL, YL);
		C.CurX = C.ClipX - 20 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 140 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(Temp, false);
	}
	if (Ammo[1] != None && Ammo[1] != Ammo[0])
	{
		
		TempNum = Ammo[1].AmmoAmount;
		C.TextSize(TempNum, XL, YL);
		C.CurX = C.ClipX - 160 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 140 * ScaleFactor * class'HUD'.default.HudScale - YL;
		C.DrawText(TempNum, false);
	}

	if (CurrentWeaponMode < WeaponModes.length && !WeaponModes[CurrentWeaponMode].bUnavailable && WeaponModes[CurrentWeaponMode].ModeName != "")
	{
		C.Font = GetFontSizeIndex(C, -3 + int(2 * class'HUD'.default.HudScale));
		C.TextSize(WeaponModes[CurrentWeaponMode].ModeName, XL, YL2);
		C.CurX = C.ClipX - 15 * ScaleFactor * class'HUD'.default.HudScale - XL;
		C.CurY = C.ClipY - 150 * ScaleFactor * class'HUD'.default.HudScale - YL2 - YL;
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
	Count = Min(8,Grenades);
    	for( i=0; i<Count; i++ )
    	{
		C.SetPos(C.ClipX - (0.5*i+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale);
		C.DrawTile( Texture'BWBP_SKC_TexExp.M1014.M1014-SGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
	}
	if ( Grenades > 8 )
	{
		Count = Min(16,Grenades);
		for( i=8; i<Count; i++ )
		{
			C.SetPos(C.ClipX - (0.5*(i-8)+1) * ScaleFactor2, C.ClipY - 100 * ScaleFactor * class'HUD'.default.HudScale - YL);
		C.DrawTile( Texture'BWBP_SKC_TexExp.M1014.M1014-SGIcon',ScaleFactor2, ScaleFactor2, 0, 0, 128, 128);
		}
	}
}

//Triggered when a holder shell needs to get lost
simulated function Special_ShellRemove()
{
	VisGrenades-=1;
	UpdateBones();
}

//Function called by alt fire to play SG special load animation.
simulated function PrepAltFire()
{
		PlayAnim(SGPrepAnim,1.0, 0.0);
		ReloadState = RS_Cocking;
}

//Triggered when the SG pump animation finishes
simulated function Special_GrenadeReady()
{
		ReloadState = RS_None;	
		bReady = true;
		Grenades -=1;
		WeaponModes[0].ModeName="X-007 Loaded";
		WeaponModes[1].ModeName="X-007 Loaded";
		
}

//Triggered after Alt nade is shot.
simulated function PrepPriFire()
{
		WeaponModes[0].ModeName=default.WeaponModes[0].ModeName;
		WeaponModes[1].ModeName=default.WeaponModes[1].ModeName;
}

//For inserting a shell while reloading
simulated function Special_ShellsIn()
{
	local int GrenadesNeeded;

		PlaySound(GrenLoadSound, SLOT_Misc, 0.5, ,64);
		ReloadState = RS_PostClipIn;	
		GrenadesNeeded=6-Grenades;
		if (GrenadesNeeded > Ammo[1].AmmoAmount)
			GrenadesNeeded = Ammo[1].AmmoAmount;
		if (Role == ROLE_Authority)
		{
			Mk781SecondaryFire(FireMode[1]).bLoaded = true;
			Grenades += GrenadesNeeded;
			Ammo[1].UseAmmo (GrenadesNeeded, True);
		}
		VisGrenades=Grenades;
		
	UpdateBones();
}


simulated function bool IsGrenadeLoaded()
{
	return Mk781SecondaryFire(FireMode[1]).bLoaded;
}

function ServerStartReload (optional byte i)
{
	local int m;
	local array<byte> Loadings[2];
	
	if (bPreventReload)
		return;
	if (ReloadState != RS_None)
		return;
	if (MagAmmo < default.MagAmmo && Ammo[0].AmmoAmount > 0)
		Loadings[0] = 1;
	if (Grenades < 6 && Ammo[1].AmmoAmount > 0)
		Loadings[1] = 1;
	if (Loadings[0] == 0 && Loadings[1] == 0)
		return;

	for (m=0; m < NUM_FIRE_MODES; m++)
		if (FireMode[m] != None && FireMode[m].bIsFiring)
			StopFire(m);

	bServerReloading = true;
	
	if (i == 1)
		m = 0;
	else m = 1;
	
	if (Loadings[i] == 1)
	{
		ClientStartReload(i);
		CommonStartReload(i);
	}
	
	else if (Loadings[m] == 1)
	{
		ClientStartReload(m);
		CommonStartReload(m);
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

// Prepare to reload, set reload state, start anims. Called on client and server
simulated function CommonStartReload (optional byte i)
{
	local int m;
	if (ClientState == WS_BringUp)
		ClientState = WS_ReadyToFire;
	if (i == 1)
	{
		ReloadState = RS_PreClipOut;
		PlayReloadAlt();
	}
	else
	{
		ReloadState = RS_StartShovel;
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
	SafePlayAnim(ReloadAltAnim, 1, , 0, "RELOAD");
}

simulated event WeaponTick(float DT)
{

	super.WeaponTick(DT);

	if (AIController(Instigator.Controller) != None && !IsGrenadeLoaded()&& AmmoAmount(1) > 0 && BotShouldReloadGrenade() && !IsReloadingGrenade())
		LoadGrenadeLoop();

}

// Load in a grenade
simulated function LoadGrenadeLoop()
{
	if (Ammo[1].AmmoAmount < 1 && Grenades > 6)
		return;
	if ((ReloadState == RS_None || ReloadState == RS_StartShovel)&& Ammo[1].AmmoAmount >= 1)
	{
		PlayAnim(ReloadAltAnim, 1.0, , 0);
		ReloadState = RS_StartShovel;
	}
}


function bool BotShouldReloadGrenade ()
{
	if ( (Level.TimeSeconds - Instigator.LastPainTime > 1.0) )
		return true;
	return false;
}


simulated function bool IsReloadingGrenade()
{
    local name anim;
    local float frame, rate;
    GetAnimParams(0, anim, frame, rate);
	if (Anim == ReloadAltAnim)
 		return true;
	return false;
}



//SPECIAL AMMO CODE END ------------------------------------

simulated function UpdateBones()
{
	local int i;
	

	if (VisGrenades<0)
	VisGrenades=0;
	for(i=5;i>=VisGrenades;i--)
		SetBoneScale(i, 0.0, Shells[i].ShellName);
	if (VisGrenades>5)
		VisGrenades=6;
	for(i=0;i<VisGrenades;i++)
		SetBoneScale(i, 1.0, Shells[i].ShellName);
		
	if (bSilenced)
		SetBoneScale (6, 1.0, SilencerBone);
	else
		SetBoneScale (6, 0.0, SilencerBone);
}

function ServerSwitchSilencer(bool bNewValue)
{
	if (!Instigator.IsLocallyControlled())
	{
		Mk781PrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
		Mk781SecondaryFire(FireMode[1]).SwitchSilencerMode(bNewValue);
	}

	Mk781Attachment(ThirdPersonActor).bSilenced=bNewValue;	
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = bNewValue;
	BFireMode[0].bAISilent = bSilenced;
	if (bSilenced)
		AimSpread *= 2.00;
	else
		AimSpread = default.AimSpread;
}

//simulated function DoWeaponSpecial(optional byte i)
exec simulated function WeaponSpecial(optional byte i)
{
	if (level.TimeSeconds < SilencerSwitchTime || ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;
	TemporaryScopeDown(0.5);
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = !bSilenced;
	ServerSwitchSilencer(bSilenced);
	SwitchSilencer(bSilenced);
}
/*
exec simulated function SilencerToggle(optional byte i)
{
	if (level.TimeSeconds < SilencerSwitchTime || ReloadState != RS_None)
		return;
	if (Clientstate != WS_ReadyToFire)
		return;

	TemporaryScopeDown(0.5);
	SilencerSwitchTime = level.TimeSeconds + 1.5;
	bSilenced = !bSilenced;
	ServerSwitchSilencer(bSilenced);
	SwitchSilencer(bSilenced);
}*/

simulated function SwitchSilencer(bool bNewValue)
{
	Mk781PrimaryFire(FireMode[0]).SwitchSilencerMode(bNewValue);
	Mk781SecondaryFire(FireMode[1]).SwitchSilencerMode(bNewValue);
	Mk781Attachment(ThirdPersonActor).IAOverride(bNewValue);
	if (bNewValue)
		PlayAnim(SilencerOnAnim);
	else
		PlayAnim(SilencerOffAnim);
}
simulated function Notify_SilencerOn()	{	PlaySound(SilencerOnSound,,0.5);	}
simulated function Notify_SilencerOff()	{	PlaySound(SilencerOffSound,,0.5);	}

simulated function Notify_SilencerShow(){	UpdateBones();	}
simulated function Notify_SilencerHide(){	UpdateBones();	}


simulated function BringUp(optional Weapon PrevWeapon)
{
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.20;
		ChaosAimSpread *= 0.30;
	}
	
	if (bSilenced)
		Mk781Attachment(ThirdPersonActor).bSilenced=True;

	VisGrenades=Grenades;
	ShellIndex = FMin(Grenades-1, 5);
	Super.BringUp(PrevWeapon);

	if (AIController(Instigator.Controller) != None)
		bSilenced = (FRand() > 0.5);

	UpdateBones();
}


simulated function AnimEnded (int Channel, name anim, float frame, float rate)
{
	if (Anim == ZoomInAnim)
	{
		ScopeUpAnimEnd();
		return;
	}
	else if (Anim == ZoomOutAnim)
	{
		ScopeDownAnimEnd();
		return;
	}

	if (anim == FireMode[0].FireAnim || (FireMode[1] != None && anim == FireMode[1].FireAnim))
		bPreventReload=false;

	// Modified stuff from Engine.Weapon
	if (ClientState == WS_ReadyToFire && ReloadState == RS_None)
    {
        if (anim == FireMode[0].FireAnim && HasAnim(FireMode[0].FireEndAnim)) // rocket hack
			SafePlayAnim(FireMode[0].FireEndAnim, FireMode[0].FireEndAnimRate, 0.0);
        else if (FireMode[1]!=None && anim== FireMode[1].FireAnim && HasAnim(FireMode[1].FireEndAnim))
            SafePlayAnim(FireMode[1].FireEndAnim, FireMode[1].FireEndAnimRate, 0.0);
        else if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
        {
			bPreventReload=false;
            PlayIdle();
        }
    }
	// End stuff from Engine.Weapon

	// Start Shovel ended, move on to Shovel loop
	if (ReloadState == RS_StartShovel)
	{
		ReloadState = RS_Shovel;
		if (MagAmmo == 0)
			PlayShovelLoopEmpty();
		else
			PlayShovelLoop();
		return;
	}
	// Shovel loop ended, start it again
	if (ReloadState == RS_PostShellIn)
	{
		if (MagAmmo >= default.MagAmmo || Ammo[0].AmmoAmount < 1)
		{
			PlayShovelEnd();
			ReloadState = RS_EndShovel;
			return;
		}
		ReloadState = RS_Shovel;
		PlayShovelLoop();
		return;
	}
	// End of reloading, either cock the gun or go to idle
	if (ReloadState == RS_PostClipIn || ReloadState == RS_EndShovel)
	{
		if (bNeedCock && MagAmmo > 0)
			CommonCockGun();
		else
		{
			bNeedCock=false;
			ReloadState = RS_None;
			ReloadFinished();
			PlayIdle();
			ReAim(0.05);
		}
		return;
	}
	//Cock anim ended, goto idle
	if (ReloadState == RS_Cocking)
	{
		ReloadState = RS_None;
		ReloadFinished();
		PlayIdle();
		ReAim(0.05);
	}

}

simulated function PlayShovelLoopEmpty()
{
	SafePlayAnim(ReloadAnimEmpty, ReloadAnimRate, 0.0, , "RELOAD");
}

simulated function float RateSelf()
{
	if (PlayerController(Instigator.Controller) != None && Ammo[0].AmmoAmount <=0 && MagAmmo <= 0)
		CurrentRating = Super.RateSelf() * 0.2;
	else
		return Super.RateSelf();
	return CurrentRating;
}


// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
        	FireMode[0].FireAnim='SightFire';
	else
        	FireMode[0].FireAnim='Fire';
}

// HARDCODED SIGHTING TIME
simulated function TickSighting (float DT)
{
	if (SightingState == SS_None || SightingState == SS_Active)
		return;

	if (SightingState == SS_Raising)
	{	// Raising gun to sight position
		if (SightingPhase < 1.0)
		{
			if ((bScopeHeld || bPendingSightUp) && CanUseSights())
				SightingPhase += DT/0.25;
			else
			{
				SightingState = SS_Lowering;

				Instigator.Controller.bRun = 0;
			}
		}
		else
		{	// Got all the way up. Now go to scope/sight view
			SightingPhase = 1.0;
			SightingState = SS_Active;
			ScopeUpAnimEnd();
		}
	}
	else if (SightingState == SS_Lowering)
	{	// Lowering gun from sight pos
		if (SightingPhase > 0.0)
		{
			if (bScopeHeld && CanUseSights())
				SightingState = SS_Raising;
			else
				SightingPhase -= DT/0.25;
		}
		else
		{	// Got all the way down. Tell the system our anim has ended...
			SightingPhase = 0.0;
			SightingState = SS_None;
			ScopeDownAnimEnd();
			DisplayFOv = default.DisplayFOV;
		}
	}
}


// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;
	local float Dist;
	local Vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	Dir = Instigator.Location - B.Enemy.Location;
	Dist = VSize(Dir);

	if (Dist > 400)
		return 0;
	if (Dist < FireMode[1].MaxRange() && FRand() > 0.3)
		return 1;
	if (vector(B.Enemy.Rotation) dot Normal(Dir) < 0.0 && (VSize(B.Enemy.Velocity) < 100 || Normal(B.Enemy.Velocity) dot Normal(B.Velocity) < 0.5))
		return 1;

	return Rand(2);
}

function float GetAIRating()
{
	local Bot B;
	local float Result, Dist;
	local vector Dir;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return Super.GetAIRating();

	Dir = B.Enemy.Location - Instigator.Location;
	Dist = VSize(Dir);

	// Enemy too far away
	if (Dist > 1000)
		Result -= (Dist-1000) / 2000;
	// If the enemy has a knife too, a gun looks better
	if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result += 0.1 * B.Skill;
	// Sniper bad, very bad
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bSniping && Dist > 500)
		Result -= 0.3;
	Result += 1 - Dist / 1000;

	return Result;
}

// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()
{
	if (AIController(Instigator.Controller) == None)
		return 0.5;
	return AIController(Instigator.Controller).Skill / 7;
}

// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()
{
	local Bot B;
	local float Result, Dist;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return -0.5;

	Dist = VSize(B.Enemy.Location - Instigator.Location);

	Result = -1 * (B.Skill / 6);
	Result *= (1 - (Dist/4000));
    return FClamp(Result, -1.0, -0.3);
}
// End AI Stuff =====

simulated function Notify_BrassOut()
{
//	BFireMode[0].EjectBrass();
}


function ServerSwitchWeaponMode (byte newMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	else if (FireMode[0].NextFireTime - level.TimeSeconds < -0.1)
		super.ServerSwitchWeaponMode (newMode);
}

defaultproperties
{
	SGPrepAnim="LoadSpecial"
	ReloadAltAnim="ReloadSpecialFull"
    GrenLoadSound=Sound'BallisticSounds2.M50.M50GrenLoad'
     Grenades=6
     Shells(0)=(ShellName="HShell1")
     Shells(1)=(ShellName="HShell2")
     Shells(2)=(ShellName="HShell3")
     Shells(3)=(ShellName="HShell4")
     Shells(4)=(ShellName="HShell5")
     Shells(5)=(ShellName="HShell6")
     ReloadAnimEmpty="ReloadEmpty"
     SilencerBone="Silencer"
     SilencerOnAnim="SilencerOn"
     SilencerOffAnim="SilencerOff"
     SilencerOnSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOn'
     SilencerOffSound=Sound'BWBP3-Sounds.SRS900.SRS-SilencerOff'
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny',SkinNum=0)
     BigIconMaterial=Texture'BWBP_SKC_TexExp.M1014.BigIcon_M1014'
     BallisticInventoryGroup=3
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Shotgun=True
     bWT_Machinegun=True
     SpecialInfo(0)=(Info="300.0;30.0;0.5;60.0;0.0;1.0;0.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M763.M763Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M763.M763Putaway')

     CamoMaterials[0]=Texture'BWBP_SKC_TexExp.Stealth.Stealth-Main
     CamoMaterials[1]=Texture'BWBP_SKC_TexExp.M1014.M1014-MainCamoDigital'
     CamoMaterials[2]=Texture'BWBP_SKC_TexExp.M1014.M1014-MainCamoDesert'
     CamoMaterials[3]=Texture'BWBP_SKC_TexExp.M1014.M1014-MainCamoAmerica'
     CamoMaterials[4]=Texture'BWBP_SKC_TexExp.M1014.M1014-MainCamoTiger'

     PickupTextureIndex=2

     MagAmmo=6
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.M781.M781-Pump',Volume=2.300000)
     ReloadAnim="ReloadLoop"
//     ReloadAnimRate=1.200000
     ClipInSound=(Sound=Sound'BWBP_SKC_SoundsExp.MK781.Mk781-ShellPlus',Volume=2.300000)
     ClipInFrame=0.325000
     bCanSkipReload=True
     bShovelLoad=True
     bNoCrosshairInScope=True
     StartShovelAnim="ReloadStart"
     EndShovelAnim="ReloadEnd"
     WeaponModes(0)=(ModeName="Automatic",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Semi-Automatic",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(2)=(ModeName="X-007 Loaded",ModeID="WM_FullAuto",bUnavailable=True)
     CurrentWeaponMode=1
     SightPivot=(Pitch=-64,Yaw=10)
     SightOffset=(X=10.000000,Y=-7.645,Z=11.90000)
     SightDisplayFOV=40.000000
//     SightDisplayFOV=10
//     SightPivot=(Pitch=-64,Yaw=10)
//     SightOffset=(X=-20.000000,Y=-3.1900000,Z=4.950000)
//     SightOffset=(X=-2.000000,Y=-3.200000,Z=4.950000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M353OutA',pic2=Texture'BallisticUI2.Crosshairs.M763InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,R=255,A=192),Color2=(B=170,G=0,R=0,A=255),StartSize1=66,StartSize2=90)
     GunLength=48.000000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpOffSet=(Pitch=1000,Yaw=-3000)
     JumpChaos=0.700000
     ViewAimFactor=0.250000
     ViewRecoilFactor=0.900000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYawFactor=0.000000
     RecoilXFactor=0.600000
     RecoilYFactor=0.700000
     RecoilMax=4096.000000
     RecoilDeclineDelay=0.200000
     RecoilDeclineTime=2.000000
     SightingTime=0.250000
     PutDownTime=0.5
     FireModeClass(0)=Class'BWBP_SKC_Fix.Mk781PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.Mk781SecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="Mark 781 Mod 0 Combat Shotgun||Manufacturer: Black & Wood|Primary: 10-Gauge Flechette|Secondary: Melee||The Avenger Mk 781 is the special ops version of the M763. It boasts a modernized firing and recoil suppression system and has been praised for its field effectiveness. A good weapon in a pinch, the M781 has been known to save many soldiers' lives. ||This particular model is the MK781 Mod 0, which uses a new lightweight polymer frame and is designed specifically for tactical wetwork. Tube length and barrel length are shortened to cut weight, leaving the Mark 781 with a shell capacity of 6. As part of its wetwork upgrades, this Mark 781 has gained the ability to affix a special suppressor designed for flechette sabot ammunition and slugs. Operators are advised not to load high-powered rounds or buckshot into the suppressor due to potential suppressor damage and failure."
     Priority=245
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=7
     PickupClass=Class'BWBP_SKC_Fix.Mk781Pickup'
//     DisplayFOV=40
//     PlayerViewOffset=(X=1.000000,Y=3.000000,Z=-3.000000)
     PlayerViewOffset=(X=-6.000000,Y=10.000000,Z=-10.000000)
     DisplayFOV=60.000000
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.Mk781Attachment'
     IconMaterial=Texture'BWBP_SKC_TexExp.M1014.SmallIcon_M1014'
     IconCoords=(X2=127,Y2=35)
     ItemName="MK781 Combat Shotgun"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.M1014_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_TexExp.M1014.M1014-Shine'
     Skins(2)=Shader'BWBP_SKC_TexExp.M1014.M1014-MiscShine'
     DrawScale=0.130000
}
