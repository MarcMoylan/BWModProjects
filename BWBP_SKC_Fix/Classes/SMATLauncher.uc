//=============================================================================
// SMATAA Recoilless.
//
// Portable artillery system. Fires a high speed shaped charge that decimates
// armor. Instant hit is almost always a kill.
// Comes with the all-new suicide alt fire!
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SMATLauncher extends BallisticWeapon;

#EXEC OBJ LOAD FILE=BWBP_SKC_Tex.utx

var() BUtil.FullSound	HatchSound;


var   bool          bRunOffsetting;
var   bool          bRunOverride;
var	bool		  bInUse;
var() rotator       RunOffset;



var()     float Heat;
var()     float CoolRate;


simulated function TickLongGun (float DT)
{
	local Actor		T;
	local Vector	HitLoc, HitNorm, Start;
	local float		Dist;

	LongGunFactor += FClamp(NewLongGunFactor - LongGunFactor, -DT/AimAdjustTime, DT/AimAdjustTime);

	Start = Instigator.Location + Instigator.EyePosition();
	T = Trace(HitLoc, HitNorm, Start + vector(Instigator.GetViewRotation()) * (GunLength+Instigator.CollisionRadius), Start, true);
	if (T == None || T.Base == Instigator || (G5MortarDamageHull(T)!=None && T.Owner == Instigator))
	{
		if (bPendingSightUp && SightingState < SS_Raising && NewLongGunFactor > 0)
			ScopeBackUp(0.5);
		NewLongGunFactor = 0;
	}
	else
	{
		Dist = VSize(HitLoc - Start)-Instigator.CollisionRadius;
		if (Dist < GunLength)
		{
			if (bScopeView)
				TemporaryScopeDown(0.5);
			NewLongGunFactor = Acos(Dist / GunLength)/1.570796;
		}
	}
}

simulated function OutOfAmmo()
{
    if ( Instigator == None || !Instigator.IsLocallyControlled() || HasAmmo() )
        return;

    DoAutoSwitch();
}




simulated function BringUp(optional Weapon PrevWeapon)
{
	Super.BringUp(PrevWeapon);

	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.5;
		ChaosAimSpread *= 0.5;
		bRunOverride=true;
	}

	if (class'BallisticReplicationInfo'.default.bNoReloading && AmmoAmount(0) > 1)
		SetBoneScale (0, 1.0, 'Rocket');

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;
}

simulated event Tick (float DT)
{
	Heat = FMax(0, Heat - CoolRate*DT);
	super.Tick(DT);
}







simulated function PlayIdle()
{
	Super.PlayIdle();
	if (bPendingSightUp || SightingState != SS_None || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}


simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		if (MagAmmo < 2)
			SetBoneScale (0, 0.0, 'Rocket');
		return true;
	}

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = false;

	return false;
}


simulated function WeaponTick(float DT)
{


	Super.WeaponTick(DT);

	if (FireMode[0].bIsFiring == true)
	{
		bInUse = true;
		SMATSecondaryFire(Firemode[1]).RailPower=0;
		Heat=0;
	}
	else
		bInUse = false;



	if (Instigator.Base != none && !bRunOverride && VSize(Instigator.velocity - Instigator.base.velocity) > 220 && !bRunOffsetting)
    {
        SetNewAimOffset(CalcNewAimOffset(), AimAdjustTime);
        bRunOffsetting=true;  
    }
    else if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) <= 220 && bRunOffsetting)
    {
        SetNewAimOffset(default.AimOffset, AimAdjustTime);
        bRunOffsetting=false;
    }

}

simulated function Rotator CalcNewAimOffset()
{
	local rotator R;

	R = default.AimOffset;

	if (!BCRepClass.default.bNoJumpOffset && SprintControl != None && SprintControl.bSprinting)
		R += SprintOffset;
    else if (Instigator.Base != none && VSize(Instigator.velocity - Instigator.base.velocity) > 220)
        R += RunOffset;
	return R;
}

simulated function vector ConvertFOVs (vector InVec, float InFOV, float OutFOV, float Distance)
{
	local vector ViewLoc, Outvec, Dir, X, Y, Z;
	local rotator ViewRot;

	ViewLoc = Instigator.Location + Instigator.EyePosition();
	ViewRot = Instigator.GetViewRotation();
	Dir = InVec - ViewLoc;
	GetAxes(ViewRot, X, Y, Z);

    OutVec.X = Distance / tan(OutFOV * PI / 360);
    OutVec.Y = (Dir dot Y) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec.Z = (Dir dot Z) * (Distance / tan(InFOV * PI / 360)) / (Dir dot X);
    OutVec = OutVec >> ViewRot;

	return OutVec + ViewLoc;
}


// AI Interface =====
function byte BestMode()
{
	return 0;	
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

	Result = Super.GetAIRating();
	if (Dist < 600)
		Result -= 0.6;
	else if (Dist > 4000)
		Result -= 0.3;
	else if (Dist > 20000)
		Result += (Dist-1000) / 2000;
	result += 0.2 - FRand()*0.4;
	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return -0.5;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return -0.9;	}
// End AI Stuff =====





exec simulated function CockGun(optional byte Type)	{ if (bNeedCock)	super.CockGun(Type);	}

simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	// Shovel loop ended, start it again
	if (ReloadState == RS_PostShellIn && anim == 'ReloadLoop')
	{
		PlayShovelEnd();
		ReloadState = RS_EndShovel;
		return;
	}

	if ((anim == ZoomOutAnim || anim == FireMode[0].FireAnim) && MagAmmo == 1 && bNeedCock )
		CommonCockGun();
	else
		Super.AnimEnd(Channel);
}

// Scope up anim just ended. Either go into scope view or move the scope back down again
simulated function ScopeUpAnimEnd()
{
 		super.ScopeUpAnimEnd();
}
// Scope down anim has just ended. Play idle anims like normal
simulated function ScopeDownAnimEnd()
{
	if (MagAmmo == 1 && bNeedCock )
		CommonCockGun();
	else
		super.ScopeDownAnimEnd();
}

simulated function Notify_CockAfterFire()
{
	bPreventReload=false;
	if (class'BallisticReplicationInfo'.default.bNoReloading)
	{
		if (AmmoAmount(0) > 0 && bNeedCock )
			CommonCockGun(1);
	}
	else if ( MagAmmo == 1 && bNeedCock )
		CommonCockGun(1);
}


simulated event RenderOverlays (Canvas Canvas)
{

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
		return;
	}
	if (!bNoMeshInScope)
	{
		Super.RenderOverlays(Canvas);
		if (SightFX != None)
			RenderSightFX(Canvas);
	}
	else
	{
		SetLocation(Instigator.Location + Instigator.CalcDrawOffset(self));
		SetRotation(Instigator.GetViewRotation());
	}

	// Draw Scope View
    if (ScopeViewTex != None)
    	{
 	        Canvas.SetDrawColor(255,255,255);

        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		
	}
}



simulated function PlayReload()
{
	bNeedCock=false;
	if (bScopeView && Instigator.Controller.IsA( 'PlayerController' ))
	{
		PlayerController(Instigator.Controller).EndZoom();
		class'BUtil'.static.PlayFullSound(self, ZoomOutSound);
	}

	SetBoneScale (0, 1.0, 'Rocket');
	if (MagAmmo < 1)
		PlayAnim('StartReloadEmpty', StartShovelAnimRate, , 0);
	else
		PlayAnim('StartReload', ReloadAnimRate, , 0);
}
simulated function PlayShovelLoop()
{
	if (MagAmmo < 1)
	{
		ClipInSound = default.ClipInSound;
		PlayAnim('ReloadLoopEmpty', ReloadAnimRate, , 0);
	}
	else
	{
		ClipInSound = default.ClipOutSound;
		PlayAnim('ReloadLoop', ReloadAnimRate, , 0);
	}
}
simulated function PlayShovelEnd()
{
	if (MagAmmo < 2)
		SetBoneScale (0, 0.0, 'Rocket');
	Super.PlayShovelEnd();
}

simulated function Notify_G5HatchOpen ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	class'BUtil'.static.PlayFullSound(self, HatchSound);
}
simulated function Notify_G5HideRocket ()
{
	if (Level.NetMode == NM_DedicatedServer)
		return;
	if (!class'BallisticReplicationInfo'.default.bNoReloading || AmmoAmount(0) < 2)
		SetBoneScale (0, 0.0, 'Rocket');
}

simulated function float ChargeBar()
{
    return FMin((Heat + SMATSecondaryFire(Firemode[1]).RailPower), 1);
}

defaultproperties
{
     HatchSound=(Sound=Sound'BallisticSounds2.M75.M75Cliphit',Volume=0.700000,Pitch=1.000000)
     RunOffset=(Pitch=-1500,Yaw=-4500)
     CoolRate=0.700000
	AimAdjustTime=0.750000
     PlayerSpeedFactor=0.700000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=4.000000
     BigIconMaterial=Texture'BWBP_SKC_Tex.SMAA.BigIcon_SMAA'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     InventorySize=71
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Projectile=True
     bWT_Super=True
     SpecialInfo(0)=(Info="500.0;60.0;1.0;80.0;2.0;0.0;1.5")
     BringUpSound=(Sound=Sound'BWBP4-Sounds.Artillery.Art-Deploy',Volume=1.100000)
     PutDownSound=(Sound=Sound'BWBP4-Sounds.Artillery.Art-Undeploy',Volume=1.100000)
     MagAmmo=1
     CockAnimRate=0.650000
     CockSound=(Sound=Sound'BallisticSounds2.G5.G5-Lever')
     ReloadAnim="ReloadLoop"
     ReloadAnimRate=0.650000
     ClipOutSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-BigOn',Volume=1.100000)
     ClipInSound=(Sound=Sound'BWBP4-Sounds.MRL.MRL-Cycle',Volume=1.100000)
     bNeedCock=True
     bShovelLoad=True
     StartShovelAnim="StartReload"
     EndShovelAnim="FinishReload"
     WeaponModes(0)=(ModeName="Single Fire")
     WeaponModes(1)=(bUnavailable=True)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     ZoomInAnim="ZoomIn"
     ZoomOutAnim="ZoomOut"
	 ZoomType=ZT_Smooth
     ScopeViewTex=Texture'BWBP_SKC_Tex.SMAA.SMATAAScopeView'
     ZoomInSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomIn',Volume=0.500000,Pitch=1.000000)
     ZoomOutSound=(Sound=Sound'BallisticSounds2.R78.R78ZoomOut',Volume=0.500000,Pitch=1.000000)
     FullZoomFOV=10.000000
     bNoMeshInScope=True
     bNoCrosshairInScope=True
     SightOffset=(X=-6.000000,Y=-7.500000,Z=5.500000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.Misc6',Pic2=Texture'BallisticUI2.Crosshairs.Cross1',USize1=256,VSize1=256,Color1=(A=192),Color2=(A=192),StartSize1=89,StartSize2=13)
     CrosshairInfo=(SpreadRatios=(X1=0.250000,Y1=0.250000,X2=1.000000,Y2=1.000000),MaxScale=3.000000)
     CrosshairChaosFactor=0.750000
     CrouchAimFactor=0.400000
     SightAimFactor=0.100000
     SprintOffSet=(Pitch=-6000,Yaw=-8000)
     JumpOffSet=(Pitch=-7000)
     AimSpread=(X=(Min=-70.000000,Max=70.000000),Y=(Min=-180.000000,Max=180.000000))
     ViewAimFactor=0.300000
     ViewRecoilFactor=1.000000
     AimDamageThreshold=300.000000
     ChaosDeclineTime=2.800000
     ChaosSpeedThreshold=380.000000
     ChaosAimSpread=(X=(Min=-2600.000000,Max=2600.000000),Y=(Min=-2600.000000,Max=2600.000000))
     RecoilYawFactor=0.000000
     RecoilMax=1024.000000
     RecoilDeclineTime=1.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SMATPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.SMATSecondaryFire'
     SelectAnimRate=0.600000
     PutDownAnimRate=0.800000
     PutDownTime=0.800000
     BringUpTime=1.000000
     SelectForce="SwitchToAssaultRifle"
     AIRating=0.750000
     CurrentRating=0.750000
     SightingTime=0.750000
     bShowChargingBar=True
     Description="Flak 16 Single Man Anti-Tank/Anti-Air Recoilless Rifle||Manufacturer: UTC Defense Tech|Primary: Launch Rocket|Secondary: Detonate Rocket||The Flak 16 SM-AT/AA Recoilless Rifle is a reloadable, single shot rocket launcher. The portable version of the Flak 54 AT/AA system, the Flak 16 SM-AT/AA is housed in a G5 casing and fires high-speed AP shaped charges for maximum penetration and damage. Engineered after UTC generals noticed the Cryons' knack for overrunning and taking over their Flak 54 sites, this new portable Recoilless Rifle has been the bane of Cryon armored divisions ever since."
     Priority=164
     CenteredOffsetY=10.000000
     CenteredRoll=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=8
     PickupClass=Class'BWBP_SKC_Fix.SMATPickup'
     PlayerViewOffset=(X=10.000000,Y=10.500000,Z=-6.000000)
     BobDamping=1.800000
     AttachmentClass=Class'BWBP_SKC_Fix.SMATAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SMAA.SmallIcon_SMAA'
     IconCoords=(X2=127,Y2=31)
     ItemName="SM-AT/AA Recoilless Rifle"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=100
     LightBrightness=192.000000
     LightRadius=12.000000
     Mesh=SkeletalMesh'BallisticAnims2.G5Bazooka'
     DrawScale=0.400000
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.SMAA.SMAA-Shine'
     Skins(2)=Texture'BWBP_SKC_Tex.SMAA.SMAAScope'
     Skins(4)=Texture'BWBP_SKC_Tex.SMAA.SMAARocket'
     Skins(5)=Texture'BWBP_SKC_Tex.SMAA.SMAALauncher'
}
