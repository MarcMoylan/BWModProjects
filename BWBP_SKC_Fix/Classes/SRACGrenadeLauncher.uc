//=============================================================================
// SRACGrenadeLayncher. Layncehssi
//
// Shoots bulldog ammo. Needs new model.
// By the time you have finished reading this you will know it says nothing
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class SRACGrenadeLauncher extends BallisticCamoWeapon;

var float		lastModeChangeTime;


var   bool			bLaserOn;

var   LaserActor	Laser;
var() Sound			LaserOnSound;
var() Sound			LaserOffSound;

var   Emitter		LaserDot;

var() sound      	QuickCockSound;


replication
{
	reliable if(Role == ROLE_Authority)
		bLaserOn, ClientSwitchCannonMode;

}


function ServerSwitchWeaponMode (byte NewMode)
{
	if (CurrentWeaponMode > 0 && FireMode[0].IsFiring())
		return;
	super.ServerSwitchWeaponMode(NewMode);
	if (!Instigator.IsLocallyControlled())
		SRACPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
	ClientSwitchCannonMode (CurrentWeaponMode);
}
simulated function ClientSwitchCannonMode (byte newMode)
{
	SRACPrimaryFire(FireMode[0]).SwitchCannonMode(newMode);
}
simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.99) || Index == 7)
		{
			Skins[1]=CamoMaterials[7];
     			ReloadAnimRate=1;
			WeaponModes[0].bUnavailable=false;
			WeaponModes[1].bUnavailable=false;
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=false;
			WeaponModes[4].bUnavailable=false;
     			CurrentWeaponMode=0;
			super.ServerSwitchWeaponMode(0);
			if (!Instigator.IsLocallyControlled())
				SK410PrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
     			bNoMag=True;
			Ammo[0].AmmoAmount=999;
			SRACPrimaryFire(FireMode[0]).XInaccuracy=1;
			SRACPrimaryFire(FireMode[0]).YInaccuracy=1;
			CamoIndex=7;

		}
		else if ((Index == -1 && f > 0.98) || Index == 6)
		{
			Skins[1]=CamoMaterials[6];
     			ReloadAnimRate=1;
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=true;
			WeaponModes[3].bUnavailable=true;
			WeaponModes[4].bUnavailable=false;
     			CurrentWeaponMode=4;
			super.ServerSwitchWeaponMode(4);
			if (!Instigator.IsLocallyControlled())
				SRACPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=6;
		}
		else if ((Index == -1 && f > 0.96) ||  Index == 5)
		{
			Skins[1]=CamoMaterials[5];
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=false;
			WeaponModes[4].bUnavailable=true;
     			CurrentWeaponMode=2;
			super.ServerSwitchWeaponMode(2);
			if (!Instigator.IsLocallyControlled())
				SRACPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=5;

		}
		else if ((Index == -1 && f > 0.94) || Index == 4)
		{
			Skins[1]=CamoMaterials[4];
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=false;
			WeaponModes[4].bUnavailable=true;
     			CurrentWeaponMode=2;
			super.ServerSwitchWeaponMode(2);
			if (!Instigator.IsLocallyControlled())
				SRACPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=4;

		}
		else if ((Index == -1 && f > 0.92) ||Index == 3)
		{
			Skins[1]=CamoMaterials[3];
			WeaponModes[0].bUnavailable=true;
			WeaponModes[1].bUnavailable=true;
			WeaponModes[2].bUnavailable=false;
			WeaponModes[3].bUnavailable=false;
			WeaponModes[4].bUnavailable=true;
     			CurrentWeaponMode=2;
			super.ServerSwitchWeaponMode(2);
			if (!Instigator.IsLocallyControlled())
				SRACPrimaryFire(FireMode[0]).SwitchCannonMode(CurrentWeaponMode);
			ClientSwitchCannonMode (CurrentWeaponMode);
			CamoIndex=3;

		}
		else if ((Index == -1 && f > 0.80) || Index == 2)
		{
			Skins[1]=CamoMaterials[2];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.75) || Index == 1)
		{
			Skins[1]=CamoMaterials[1];
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[0];
		}

}


simulated function BringUp(optional Weapon PrevWeapon)
{
	super.BringUp(PrevWeapon);
	GunLength = default.GunLength;


	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
		ServerSwitchLaser(FRand() > 0.5);

//	if ( ThirdPersonActor != None )
//		AH104Attachment(ThirdPersonActor).bLaserOn = bLaserOn;

	Instigator.AmbientSound = UsedAmbientSound;
	Instigator.SoundVolume = default.SoundVolume;
	Instigator.SoundPitch = default.SoundPitch;
	Instigator.SoundRadius = default.SoundRadius;
	Instigator.bFullVolume = true;

}

simulated function ClientSwitchLaser()
{
	if (bLaserOn)
	{
		SpawnLaserDot();
		PlaySound(LaserOnSound,,3.7,,32);
	}
	else
	{
		KillLaserDot();
		PlaySound(LaserOffSound,,3.7,,32);
	}
	if (!IsinState('DualAction') && !IsinState('PendingDualAction'))
		PlayIdle();
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
}


//Draw special weapon info on the hud
simulated function NewDrawWeaponInfo(Canvas C, float YPos)
{
	if (bLaserOn)	{
		CrosshairCfg.Color1.A /= 2;
		CrosshairCfg.Color2.A /= 2;
	}
	Super.NewDrawWeaponInfo (C, YPos);

	if (bLaserOn)	{
		CrosshairCfg.Color1.A = default.CrosshairCfg.Color1.A ;
		CrosshairCfg.Color2.A = default.CrosshairCfg.Color2.A ;
	}
}

simulated function KillLaserDot()
{
	if (LaserDot != None)
	{
		LaserDot.Kill();
		LaserDot = None;
	}
}
simulated function SpawnLaserDot(optional vector Loc)
{
	if (LaserDot == None)
		LaserDot = Spawn(class'BWBP_SKC_Fix.AH104LaserDot',,,Loc);
}



simulated function PlayIdle()
{
	super.PlayIdle();

	if (!bLaserOn || bPendingSightUp || SightingState != SS_None || bScopeView || !CanPlayAnim(IdleAnim, ,"IDLE"))
		return;
	FreezeAnimAt(0.0);
}

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
	if (bLaserOn != default.bLaserOn)
	{
		if (bLaserOn)
			AimAdjustTime = default.AimAdjustTime * 1.5;
		else
			AimAdjustTime = default.AimAdjustTime;
		default.bLaserOn = bLaserOn;
		ClientSwitchLaser();
	}
	Super.PostNetReceive();
}
function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
//	if (ThirdPersonActor!=None)
//		AH104Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
		AimAdjustTime = default.AimAdjustTime * 1.5;
	else
		AimAdjustTime = default.AimAdjustTime;
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
		
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
//		if (ThirdPersonActor != None)
//			AH104Attachment(ThirdPersonActor).bLaserOn = false;
		return true;
	}
	return false;
}

simulated function Destroyed ()
{
	default.bLaserOn = false;
	if (Laser != None)
		Laser.Destroy();
	if (LaserDot != None)
		LaserDot.Destroy();
	Super.Destroyed();
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

// Draw a laser beam and dot to show exact path of bullets before they're fired
simulated function DrawLaserSight ( Canvas Canvas )
{
	local Vector HitLocation, Start, End, HitNormal, Scale3D, Loc;
	local Rotator AimDir;
	local Actor Other;

	if ((ClientState == WS_Hidden) || (!bLaserOn) || Instigator == None || Instigator.Controller == None || Laser==None)
		return;

	AimDir = BallisticFire(FireMode[0]).GetFireAim(Start);
	Loc = GetBoneCoords('tip2').Origin;

	End = Start + Normal(Vector(AimDir))*5000;
	Other = FireMode[0].Trace (HitLocation, HitNormal, End, Start, true);
	if (Other == None)
		HitLocation = End;

	// Draw dot at end of beam
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && !IsInState('DualAction') && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = ConvertFOVs(End, Instigator.Controller.FovAngle, DisplayFOV, 400);
	if (ReloadState == RS_None && ClientState == WS_ReadyToFire && ((FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > -0.05) || (!FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > 0.1)))
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip2');
		Laser.SetRotation(AimDir);
	}
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 1;
	Scale3D.Z = 1;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays( Canvas Canvas )
{
	super.RenderOverlays(Canvas);
	if (!IsInState('Lowered'))
		DrawLaserSight(Canvas);
}




// Secondary fire doesn't count for this weapon
simulated function bool HasAmmo()
{
	//First Check the magazine
	if (!bNoMag && FireMode[0] != None && MagAmmo >= FireMode[0].AmmoPerFire)
		return true;
	//If it is a non-mag or the magazine is empty
	if (Ammo[0] != None && FireMode[0] != None && Ammo[0].AmmoAmount >= FireMode[0].AmmoPerFire)
			return true;
	return false;	//This weapon is empty
}
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()	{	return 0;	}

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
	Result += (Dist-1000) / 2000;

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

simulated function Notify_ManualBrassOut()
{
	BFireMode[0].EjectBrass();
}

simulated event WeaponTick(float DT)
{

	super.WeaponTick(DT);


		if (CurrentWeaponMode == 2)
		{
     			RecoilXFactor		=1.3;
     			RecoilYFactor		=1.2;
     			RecoilYawFactor		=0.8;
     			RecoilPitchFactor	=0.8;
		}
		else
		{
     			RecoilXFactor		= default.RecoilXFactor;
     			RecoilYFactor		= default.RecoilYFactor;
     			RecoilYawFactor		= default.RecoilYawFactor;
     			RecoilPitchFactor	= default.RecoilPitchFactor;
		}

}


defaultproperties
{
     LaserOnSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOn'
     LaserOffSound=Sound'BWBP_SKC_Sounds.AH104.AH104-SightOff'
     PlayerSpeedFactor=0.850000
     QuickCockSound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-CockQuick'

     CamoMaterials[7]=Shader'BWBP_SKC_Tex.SRAC.SRAC-GoldShine' // STILL FABULOUS
     CamoMaterials[6]=Shader'BWBP_SKC_Tex.SRAC.SRAC-PinkShine' // FABULOUS
     CamoMaterials[5]=Texture'BWBP_SKC_Tex.SRAC.SRAC-RedTiger' // Cod6
     CamoMaterials[4]=Shader'BWBP_SKC_Tex.SRAC.SRAC-TigerShine' // Cod4
     CamoMaterials[3]=Shader'BWBP_SKC_Tex.SRAC.SRAC-BloodShine'// The horror... the horror.... the horror....
     CamoMaterials[2]=Shader'BWBP_SKC_Tex.SRAC.SRAC-SteelShine'
     CamoMaterials[1]=Shader'BWBP_SKC_Tex.SRAC.SRAC-TacticalShine'
     CamoMaterials[0]=Shader'BWBP_SKC_Tex.SRAC.SRAC-MainShine' // Cell

     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     BigIconMaterial=Texture'BWBP_SKC_Tex.SKAS.BigIcon_SRAC'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bWT_Hazardous=True
     bWT_Splash=True
     bWT_Projectile=True
     SpecialInfo(0)=(Info="360.0;30.0;0.9;120.0;0.0;3.0;0.0")
     BringUpSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-Select')
     PutDownSound=(Sound=Sound'BallisticSounds2.M763.M763Putaway')
     PutDownTime=1.500000
     MagAmmo=18
     InventorySize=30
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Bulldog.Bulldog-CockQuick',Pitch=0.900000,Volume=1.000000)
     ReloadAnim="Reload"
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-ClipIn',Pitch=0.900000,Volume=2.000000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.SKAS.SKAS-ClipOut1',Pitch=0.900000,Volume=2.000000)
     ClipInFrame=0.650000
     IdleAnimRate=0.100000
     bCockOnEmpty=True
     bNeedCock=True
     WeaponModes(0)=(ModeName="Semi-Automatic",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(1)=(ModeName="Automatic",ModeID="WM_FullAuto")
     WeaponModes(2)=(ModeName="Manual",ModeID="WM_SemiAuto",Value=1.000000)
     WeaponModes(3)=(ModeName="Assault",ModeID="WM_FullAuto",bUnavailable=true)
     WeaponModes(4)=(ModeName="Fabulous",ModeID="WM_FullAuto",bUnavailable=true)
     CurrentWeaponMode=1
     SightPivot=(Pitch=1024,Roll=2048)
     SightOffset=(X=0.000000,Y=10.000000,Z=16.000000)
	CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.A73OutA',pic2=Texture'BallisticUI2.Crosshairs.G5InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(B=255,G=255,R=255,A=192),Color2=(B=0,G=0,R=255,A=98),StartSize1=83,StartSize2=64)
     GunLength=32.000000
     SprintOffSet=(Pitch=-1000,Yaw=-2048)
     JumpOffSet=(Pitch=1000,Yaw=-3000)
     JumpChaos=0.700000
     ViewAimFactor=0.250000
     ViewRecoilFactor=0.900000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.100000),(InVal=0.300000,OutVal=-0.200000),(InVal=1.000000,OutVal=-0.300000)))
     RecoilYCurve=(Points=(,(InVal=0.300000,OutVal=0.500000),(InVal=1.000000,OutVal=1.000000)))
     RecoilXFactor=1.000000
     RecoilYFactor=1.000000
     RecoilYawFactor=0.00000
     RecoilPitchFactor=0.000000
     RecoilMax=2048.000000
     ChaosAimSpread=(X=(Min=-1024.000000,Max=1024.000000),Y=(Min=-1024.000000,Max=1024.000000))
     AimSpread=(X=(Min=-512.000000,Max=512.000000),Y=(Min=-512.000000,Max=512.000000))
     RecoilDeclineDelay=0.200000
     RecoilDeclineTime=1.000000
     FireModeClass(0)=Class'BWBP_SKC_Fix.SRACPrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.SRACSecondaryFire'
     AIRating=0.600000
     CurrentRating=0.600000
     Description="SRAC-21/G Autocannon||Manufacturer: UTC Defense Tech|Primary: FRAG-12 Shot|Secondary: Tri-Barrel Blast||The SRAC-21/G 20mm Autocannon is the grenade launching variant of the SKAS-21 weapon system. It fires the highly potent FRAG-12 explosive round, which turns what is normally a close range suppression shotgun into a long range sniping cannon. It fires from the same electrically assisted, rotating triple-barrel system as the SKAS-21, which means that it can also be used with manual mode to further propel the generally low-impulse explosive charge. The explosive charges are designed to detonate on contact, which means the SRAC can be used in a similar fashion to a standard slug firing rifles. A laser sight is included on all SRACs due to a lack of back up iron sights. Handle with care, as this is one expensive gun."
     Priority=245
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=6
     BallisticInventoryGroup=6
     PickupClass=Class'BWBP_SKC_Fix.SRACPickup'
     PlayerViewOffset=(X=-4.000000,Y=2.000000,Z=-8.000000)
//     PlayerViewOffset=(X=-4.000000,Y=1.000000,Z=-10.000000)
     BobDamping=1.700000
     AttachmentClass=Class'BWBP_SKC_Fix.SRACAttachment'
     IconMaterial=Texture'BWBP_SKC_Tex.SKAS.SmallIcon_SRAC'
     IconCoords=(X2=127,Y2=30)
     ItemName="SRAC-21/G Autocannon"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=25
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=5.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.SKASShotgunFP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.SRAC.SRAC-MainShine'
     DrawScale=0.260000
}
