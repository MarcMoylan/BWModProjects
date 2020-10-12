//=============================================================================
// AH208Pistol.
//
// A powerful sidearm designed for long range combat. The .44 bulelts are very
// deadly. Secondary is a pistol whip.
//
// by Nolan "Dark Carnivour" Richert.
// Copyright(c) 2006 RuneStorm. All Rights Reserved.
//=============================================================================
class AH208Pistol extends BallisticCamoWeapon;

var bool		bFirstDraw;
var   LaserActor	Laser;
var   Emitter		LaserDot;
var   bool			bLaserOn;
var   bool			bStriking;

var() Sound			LaserOnSound;
var() Sound			LaserOffSound;

var(AH208Pistol) name		RDSBone;			// Bone to use for hiding Red Dot Sight
var(AH208Pistol) name		MuzzBone;			// Bone to use for hiding Compensator
var(AH208Pistol) name		LAMBone;			// Bone to use for hiding LAM
var(AH208Pistol) name		ScopeBone;			// Bone to use for hiding scope
var(AH208Pistol) name		BulletBone;			// Bone to use for hiding bullet

var(AH208Pistol) sound		CamoSound1; //For Silver
var(AH208Pistol) sound		CamoSound2; //For Gold

replication
{
	reliable if (Role == ROLE_Authority)
		bLaserOn;
}


simulated function AdjustCamoProperties(optional int Index)
{
	local float f;

		f = FRand();

		if ((Index == -1 && f > 0.99) || Index == 6) //Golden
		{
			Skins[1]=CamoMaterials[4];
			SetBoneScale (1, 0.0, LAMBone);
     			BallisticInstantFire(FireMode[0]).RecoilPerShot=2048;
			BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=CamoSound1;
			BallisticInstantFire(FireMode[0]).Damage = 90;
			BallisticInstantFire(FireMode[0]).DamageHead = 135;
			BallisticInstantFire(FireMode[0]).DamageLimb = 35;
			CamoIndex=6;
		}
		else if ((Index == -1 && f > 0.96) || Index == 5) //Silver Scoped!
		{
			Skins[1]=CamoMaterials[3];
			SetBoneScale (1, 1.0, LAMBone);
			SetBoneScale (0, 1.0, ScopeBone);
			SightOffset = vect(70,-7.35,45.4);

			BallisticInstantFire(FireMode[0]).BallisticFireSound.Sound=CamoSound2;
     			ScopeViewTex=Texture'BWBP_SKC_Tex.Eagle.Eagle-ScopeView';
     			ZoomInSound.Sound=Sound'BallisticSounds2.R78.R78ZoomIn';
     			ZoomOutSound.Sound=Sound'BallisticSounds2.R78.R78ZoomOut';
     			FullZoomFOV=40;
			SightDisplayFOV=40;
     			bNoMeshInScope=True;
			CamoIndex=5;
		}
		else if ((Index == -1 && f > 0.93) || Index == 4) //Black RDS + Comp
		{
			Skins[1]=CamoMaterials[2];
			Skins[2]=CamoMaterials[6];
     			Skins[4]=CamoMaterials[7];
     			Skins[5]=CamoMaterials[8];
     			BallisticInstantFire(FireMode[0]).RecoilPerShot=2048;
			BallisticInstantFire(FireMode[0]).XInaccuracy=4.000000;
			BallisticInstantFire(FireMode[0]).YInaccuracy=4.000000;
			SightOffset = vect(-20,-7.4,45.3);
			CamoIndex=4;
		}
		else if ((Index == -1 && f > 0.90) || Index == 3) //Silver RDS
		{
			Skins[1]=CamoMaterials[0];
			//Skins[3]=CamoMaterials[5];
			SightOffset = vect(-20,-7.4,45.25);
			CamoIndex=3;
		}
		else if ((Index == -1 && f > 0.75) || Index == 2) //Black
		{
			Skins[1]=CamoMaterials[2];
			Skins[2]=CamoMaterials[6];
			CamoIndex=2;
		}
		else if ((Index == -1 && f > 0.60) || Index == 1) //Two Tone
		{
			Skins[1]=CamoMaterials[1];
			//Skins[3]=CamoMaterials[5];
			CamoIndex=1;
		}
		else
		{
			Skins[1]=CamoMaterials[0];
			//Skins[2]=CamoMaterials[5];
			CamoIndex=0;
		}
}

function DropFrom(vector StartLocation)
{
	local int m;
		local Pickup Pickup;

	if (!bCanThrow)
        	return;

	if (AmbientSound != None)
		AmbientSound = None;

    	ClientWeaponThrown();

    	for (m = 0; m < NUM_FIRE_MODES; m++)
    	{
        	if (FireMode[m] != None && FireMode[m].bIsFiring)
           		StopFire(m);
    	}

	if ( Instigator != None )
		DetachFromPawn(Instigator);

	Pickup = Spawn(PickupClass,self,, StartLocation);
	if ( Pickup != None )
	{
        	if (Instigator.Health > 0)
        	    WeaponPickup(Pickup).bThrown = true;
    		Pickup.InitDroppedPickupFor(self);
		Pickup.Velocity = Velocity;
		BallisticCamoPickup(Pickup).CamoIndex = CamoIndex;
		if (CamoIndex == 6) //BB
		{
			BallisticCamoPickup(Pickup).Skins[0]=Texture'ONSstructureTextures.CoreGroup.Invisible';
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[4];
		}
		else if (CamoIndex == 5) //BB
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[5];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[3];
		}
		else if (CamoIndex == 4) //BB
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[6];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[2];
		}
		else if (CamoIndex == 3) //CA
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[5];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[0];
		}
		else if (CamoIndex == 2) //DA
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[6];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[2];
		}
		else if (CamoIndex == 1) //DC
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[5];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[1];
		}
		else
		{
			BallisticCamoPickup(Pickup).Skins[0]=CamoMaterials[5];
			BallisticCamoPickup(Pickup).Skins[1]=CamoMaterials[0];
		}
    	}
    Destroy();
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (CamoIndex != 5)
		SetBoneScale (0, 0.0, ScopeBone);
	if (CamoIndex != 3 && CamoIndex != 4)
		SetBoneScale (2, 0.0, RDSBone);
	if (CamoIndex != 4)
		SetBoneScale (3, 0.0, MuzzBone);
	if (bFirstDraw && MagAmmo > 0)
	{
     		BringUpTime=1.700000;
     		SelectAnim='PulloutFancy';
		bFirstDraw=false;
		SetBoneScale(4,1.0,BulletBone);
	}
	else if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{
		IdleAnim = 'OpenIdle';
		ReloadAnim = 'OpenReload';
		SelectAnim = 'OpenPullout';
		BringUpTime=default.BringUpTime;
		SetBoneScale(4,0.0,BulletBone);
	}
	else
	{
		IdleAnim = 'Idle';
		ReloadAnim = 'Reload';
		SelectAnim = 'SuperPullout';
		BringUpTime=default.BringUpTime;
	}


	Super.BringUp(PrevWeapon);

	if (Instigator != None && Laser == None && PlayerController(Instigator.Controller) != None)
		Laser = Spawn(class'BallisticFix.LaserActor_G5Painter');
	if (Instigator != None && LaserDot == None && PlayerController(Instigator.Controller) != None)
		SpawnLaserDot();
	if (Instigator != None && AIController(Instigator.Controller) != None)
		ServerSwitchLaser(FRand() > 0.5);

	if ( ThirdPersonActor != None )
		AH208Attachment(ThirdPersonActor).bLaserOn = bLaserOn;

}

// LASER CODE


function ServerWeaponSpecial(optional byte i)
{
	if (CamoIndex !=6)
		ServerSwitchlaser(!bLaserOn);
}

simulated event PostNetReceive()
{
	if (level.NetMode != NM_Client)
		return;
	if (bLaserOn != default.bLaserOn)
	{
		if (bLaserOn)
		{
			AimSpread *= 0.8;
			AimAdjustTime = default.AimAdjustTime * 1.5;
		}
		else
		{
			AimSpread = default.AimSpread;
			AimAdjustTime = default.AimAdjustTime;
		}
		default.bLaserOn = bLaserOn;
		ClientSwitchLaser();
	}
	Super.PostNetReceive();
}

function ServerSwitchLaser(bool bNewLaserOn)
{
	bLaserOn = bNewLaserOn;
	bUseNetAim = bLaserOn;
	if (ThirdPersonActor!=None)
		AH208Attachment(ThirdPersonActor).bLaserOn = bLaserOn;
	if (bLaserOn)
	{
		AimSpread *= 0.8;
		AimAdjustTime = default.AimAdjustTime * 1.5;
	}
	else
	{
		AimSpread = default.AimSpread;
		AimAdjustTime = default.AimAdjustTime;
	}
    if (Instigator.IsLocallyControlled())
		ClientSwitchLaser();
}

simulated function ClientSwitchLaser()
{
	if (bLaserOn)
	{
		SpawnLaserDot();
		PlaySound(LaserOnSound,,0.7,,32);
	}
	else
	{
		KillLaserDot();
		PlaySound(LaserOffSound,,0.7,,32);
	}

	PlayIdle();
	bUseNetAim = bLaserOn;
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
	{
		LaserDot = Spawn(class'BallisticFix.G5LaserDot',,,Loc);
		if (LaserDot != None)
			class'BallisticEmitter'.static.ScaleEmitter(LaserDot, 1.5);
	}
}

simulated function bool PutDown()
{
	if (Super.PutDown())
	{
		KillLaserDot();
		if (ThirdPersonActor != None)
			AH208Attachment(ThirdPersonActor).bLaserOn = false;
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
	if (!bStriking && ReloadState == RS_None && ClientState == WS_ReadyToFire && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)
		SpawnLaserDot(HitLocation);
	else
		KillLaserDot();
	if (LaserDot != None)
		LaserDot.SetLocation(HitLocation);
	Canvas.DrawActor(LaserDot, false, false, Instigator.Controller.FovAngle);

	// Draw beam from bone on gun to point on wall(This is tricky cause they are drawn with different FOVs)
	Laser.SetLocation(Loc);
	HitLocation = class'BUtil'.static.ConvertFOVs(Instigator.Location + Instigator.EyePosition(), Instigator.GetViewRotation(), End, Instigator.Controller.FovAngle, DisplayFOV, 400);

	if (!bStriking && ReloadState == RS_None && ClientState == WS_ReadyToFire &&
	   ((FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > -0.05) || (!FireMode[0].IsFiring() && Level.TimeSeconds - FireMode[0].NextFireTime > 0.2)))
		Laser.SetRotation(Rotator(HitLocation - Loc));
	else
	{
		AimDir = GetBoneRotation('tip2');
		Laser.SetRotation(AimDir);
	}
	Scale3D.X = VSize(HitLocation-Loc)/128;
	Scale3D.Y = 2;
	Scale3D.Z = 2;
	Laser.SetDrawScale3D(Scale3D);
	Canvas.DrawActor(Laser, false, false, DisplayFOV);
}

simulated event RenderOverlays (Canvas Canvas)
{
	local float ImageScaleRatio;

	if (!bScopeView)
	{
		Super.RenderOverlays(Canvas);
		DrawLaserSight(Canvas);
		return;
	}
	if (bScopeView && ( (PlayerController(Instigator.Controller).DesiredFOV == PlayerController(Instigator.Controller).DefaultFOV && PlayerController(Instigator.Controller).bZooming==false)
		|| (Level.bClassicView && (PlayerController(Instigator.Controller).DesiredFOV == 90)) ))
	{
		SetScopeView(false);
		PlayAnim(ZoomOutAnim);
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
	// Draw the Scope View Tex
	Canvas.SetDrawColor(255,255,255,255);
	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
	Canvas.Style = ERenderStyle.STY_Alpha;
	ImageScaleRatio = 1.3333333;


        	Canvas.SetPos(Canvas.OrgX, Canvas.OrgY);
    		Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);

        	Canvas.SetPos((Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, Canvas.SizeY, Canvas.SizeY, 0, 0, 1024, 1024);

        	Canvas.SetPos(Canvas.SizeX - (Canvas.SizeX - Canvas.SizeY)/2, Canvas.OrgY);
        	Canvas.DrawTile(ScopeViewTex, (Canvas.SizeX - Canvas.SizeY)/2, Canvas.SizeY, 0, 0, 1, 1024);
		
}

// END LASER CODE



// Animation notify for when cocking action starts. Used to time sounds
simulated function Notify_CockSim()
{
	PlayOwnedSound(CockSound.Sound,CockSound.Slot,CockSound.Volume,CockSound.bNoOverride,CockSound.Radius,CockSound.Pitch,CockSound.bAtten);
}



simulated function Notify_HideBullet()
{
	if (MagAmmo < 2)
		SetBoneScale(4,0.0,BulletBone);
}


simulated function Notify_ShowBullet()
{
	SetBoneScale(4,1.0,BulletBone);
}



simulated event AnimEnd (int Channel)
{
    local name Anim;
    local float Frame, Rate;

    GetAnimParams(0, Anim, Frame, Rate);

	if (Anim == 'OpenFire' || Anim == 'Fire' || Anim == 'OpenFire' || Anim == 'OpenSightFire' || Anim == CockAnim || Anim == ReloadAnim)
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
		{
			IdleAnim = 'OpenIdle';
			ReloadAnim = 'OpenReload';
			PutDownAnim = 'OpenPutaway';
			SelectAnim = 'OpenPullout';
		}
		else
		{
			IdleAnim = 'Idle';
			ReloadAnim = 'Reload';
			PutDownAnim = 'Putaway';
			SelectAnim = 'Pullout';
		}
	}
	if(Anim != 'PrepPistolWhip' && Anim != 'OpenPrepPistolWhip')
		bStriking = false;
	Super.AnimEnd(Channel);
}

simulated function PlayCocking(optional byte Type)
{
	if (Type == 2)
		PlayAnim('ReloadEndCock', CockAnimRate, 0.2);
	else
		PlayAnim(CockAnim, CockAnimRate, 0.2);
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
// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();

	bUseNetAim = default.bUseNetAim || bScopeView || bLaserOn;
	if (bScopeView)
	{
		ViewRecoilFactor = 0.3;
		ChaosDeclineTime *= 1.5;
		RecoilYawFactor=0.000000;
	}
}



// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()	{	return 0;	}


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
function float SuggestAttackStyle()	{	return 0.3;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     LaserOnSound=Sound'BWAddPack-RS-Sounds.TEC.RSMP-LaserClick'
     LaserOffSound=Sound'BWAddPack-RS-Sounds.TEC.RSMP-LaserClick'
     PlayerSpeedFactor=1.000000
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     AIReloadTime=1.500000
     BigIconMaterial=Texture'BWBP_SKC_Tex.Eagle.BigIcon_Eagle'
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
		bFirstDraw=True
		bNeedCock=False
     		bNoCrosshairInScope=True

     CamoSound1=Sound'BWBP_SKC_Sounds.AH104.AH104-Blast'
     CamoSound2=Sound'BWBP_SKC_Sounds.M781.M784-Single';

     CamoMaterials[0]=Shader'BWBP_SKC_Tex.Eagle.Eagle-MainShine'
     CamoMaterials[1]=Shader'BWBP_SKC_Tex.Eagle.Eagle-TwoToneShine'
     CamoMaterials[2]=Shader'BWBP_SKC_Tex.Eagle.Eagle-BlackShine'
     CamoMaterials[3]=Shader'BWBP_SKC_Tex.Eagle.Eagle-SilverShine'
     CamoMaterials[4]=Shader'BWBP_SKC_Tex.Eagle.Eagle-GoldShine'
     CamoMaterials[5]=Texture'BWBP_SKC_Tex.Eagle.Eagle-Misc'
     CamoMaterials[6]=Texture'BWBP_SKC_Tex.Eagle.Eagle-MiscBlack'
     CamoMaterials[7]=Texture'BWBP_SKC_Tex.Eagle.Eagle-FrontBlack'
     CamoMaterials[8]=Shader'BWBP_SKC_Tex.Eagle.Eagle-SightDotGreen'

	MuzzBone="Compensator"
	RDSBone="RedDotSight"
	LAMBone="LAM"
	ScopeBone="Scope"
	BulletBone="Bullet"
     InventorySize=25
     bWT_Bullet=True
     SpecialInfo(0)=(Info="140.0;12.0;0.7;70.0;0.55;0.0;-999.0")
     BringUpSound=(Sound=Sound'BallisticSounds2.M806.M806Pullout')
     PutDownSound=(Sound=Sound'BallisticSounds2.M806.M806Putaway')
     MagAmmo=8
     CockSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-Cock',Volume=5.100000)
     ClipHitSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipHit',Volume=2.500000)
     ClipOutSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipOut',Volume=2.500000)
     ClipInSound=(Sound=Sound'BWBP_SKC_Sounds.Eagle.Eagle-ClipIn',Volume=2.500000)
     ClipInFrame=0.650000
     WeaponModes(0)=(ModeName="Semi-Automatic")
     WeaponModes(1)=(ModeName="Mode-2",bUnavailable=True,Value=7.000000)
     WeaponModes(2)=(bUnavailable=True)
     CurrentWeaponMode=0
     SightOffset=(X=-20.000000,Y=-7.350000,Z=41.700000)
     SightDisplayFOV=40.000000
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.G5OutA',Pic2=Texture'BallisticUI2.Crosshairs.M806InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(A=122),Color2=(B=122),StartSize1=64,StartSize2=76)
     CrosshairInfo=(SpreadRatios=(X1=0.750000,Y1=0.750000,X2=0.300000,Y2=0.300000))
     GunLength=4.000000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     JumpChaos=0.300000
     AimSpread=(X=(Min=-96.000000,Max=96.000000),Y=(Min=-96.000000,Max=96.000000))
     ViewAimFactor=0.150000
     ViewRecoilFactor=0.200000
     ChaosDeclineTime=0.500000
     ChaosTurnThreshold=150000.000000
     ChaosSpeedThreshold=1400.000000
     ChaosAimSpread=(X=(Min=-2900.000000,Max=2900.000000),Y=(Min=-2500.000000,Max=2500.000000))
     RecoilYawFactor=0.400000
     RecoilMax=8192.000000
     RecoilDeclineTime=0.600000
     RecoilDeclineDelay=0.200000
     FireModeClass(0)=Class'BWBP_SKC_Fix.AH208ENHANCEDFIRE'
     FireModeClass(1)=Class'BWBP_SKC_Fix.AH208MELEEFIRE'
     PutDownTime=0.800000
     BringUpTime=1.200000
     SelectForce="SwitchToAssaultRifle"
     bUseOldWeaponMesh=True
     Description="AH-208 'Eagle' Assault Pistol||Manufacturer: Enravion Combat Solutions|Primary: Magnum Rounds|Secondary: Pistol Whip|Special: Laser Dot||Built as a more affordable alternative to the AH104, the AH208 is an alternate design chambered for .44 magnum rounds instead of the usual $100 .600 HEAP ones. It is less accurate than the AH104 and D49, but its 8 round magazine and faster reload times let it put more rounds down range than both. Its significant weight and recoil means it requires both hands to shoot and is harder to control than its revolver and handcannon siblings, a fact that comes into play where range is a concern. While not as popular as its larger .600 cousin, the AH208 packs a formidable punch and is a force to be reckoned with."
     Priority=96
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     InventoryGroup=2
     GroupOffset=13
     PickupClass=Class'BWBP_SKC_Fix.AH208PICKUP'
     PlayerViewOffset=(X=0.000000,Y=19.500000,Z=-30.000000)
     BobDamping=1.200000
     AttachmentClass=Class'BWBP_SKC_Fix.AH208ATTACHMENT'
     IconMaterial=Texture'BWBP_SKC_Tex.Eagle.SmallIcon_Eagle'
     IconCoords=(X2=127,Y2=31)
     ItemName="AH208 Assault Pistol"
     LightType=LT_Pulse
     LightEffect=LE_NonIncidence
     LightHue=30
     LightSaturation=150
     LightBrightness=150.000000
     LightRadius=4.000000
     Mesh=SkeletalMesh'BWBP_SKC_Anim.DEagle_FP'
     Skins(0)=Shader'BallisticWeapons2.Hands.Hands-Shiny'
     Skins(1)=Shader'BWBP_SKC_Tex.Eagle.Eagle-MainShine'
     Skins(2)=Texture'BWBP_SKC_Tex.Eagle.Eagle-Misc'
     Skins(3)=Texture'BWBP_SKC_Tex.Eagle.Eagle-ScopeRed'
     Skins(4)=Texture'BWBP_SKC_Tex.Eagle.Eagle-Front'
     Skins(5)=Shader'BWBP_SKC_Tex.Eagle.Eagle-SightDot'
     DrawScale=0.800000
}
