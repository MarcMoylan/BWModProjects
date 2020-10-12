//=============================================================================
// CX61 'Spectre' Assault Rifle
//
// Flamethrower / G28 gas sprayer.
//
// by Azarael
//=============================================================================
class CX61AssaultRifle extends BallisticWeapon;

#exec OBJ LOAD FILE=BWBP_SKC_TexExp.utx
#exec OBJ LOAD FILE=BWBP_SKC_AnimExp.ukx

var   RX22ASpray		Flame;
var   CX61GasSpray 	GasSpray;
var 	float				StoredGas;

replication
{
	reliable if (Role == ROLE_Authority)
		ClientSwitchCX61Mode, StoredGas;
}

exec simulated function SwitchWeaponMode (byte newMode)
{
	if (FireMode[1].bIsFiring || Flame != None || GasSpray != None)
		return;
	ServerSwitchWeaponMode(newMode);	
}

function ServerSwitchWeaponMode (byte newMode)
{
    if (Firemode[1].bIsFiring || Flame != None || GasSpray != None)
        return;
	super.ServerSwitchWeaponMode (newMode);
	if (!Instigator.IsLocallyControlled())
		CX61SecondaryFire(FireMode[1]).SwitchCX61Mode(CurrentWeaponMode);
	ClientSwitchCX61Mode(CurrentWeaponMode);
}

simulated function ClientSwitchCX61Mode (byte newMode)
{
	CX61SecondaryFire(FireMode[1]).SwitchCX61Mode(newMode);
}

simulated event PostNetBeginPlay()
{
	super.PostNetBeginPlay();
	CX61SecondaryFire(FireMode[1]).SwitchCX61Mode(CurrentWeaponMode);
}

// See if firing modes will let us fire another round or not
simulated function bool CheckWeaponModeAlt ()
{
	if (FireCount >= 2)
		return false;
	return true;
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

simulated event RenderOverlays(Canvas C)
{
	super.RenderOverlays(C);
	if (Flame != None)
	{
		Flame.SetLocation(ConvertFOVs(GetBoneCoords('tip2').Origin, DisplayFOV, Instigator.Controller.FovAngle, 32));
		Flame.SetRotation(rotator(Vector(GetAimPivot() + GetRecoilPivot()) >> GetPlayerAim()));
		C.DrawActor(Flame, false, false, Instigator.Controller.FovAngle);
	}
	
	else if (GasSpray != None)
	{
		GasSpray.SetLocation(ConvertFOVs(GetBoneCoords('tip2').Origin, DisplayFOV, Instigator.Controller.FovAngle, 32));
		GasSpray.SetRotation(rotator(Vector(GetAimPivot() + GetRecoilPivot()) >> GetPlayerAim()));
		C.DrawActor(GasSpray, false, false, Instigator.Controller.FovAngle);
	}
}

simulated function WeaponTick (float DT)
{
	super.WeaponTick(DT);

	if (ThirdPersonActor != None && !Instigator.IsFirstPerson() && AIController(Instigator.Controller) == None)
	{
		if (Flame != None)
		{
			Flame.SetLocation(CX61Attachment(ThirdPersonActor).GetAltTipLocation());
			Flame.SetRotation(rotator(Vector(GetAimPivot() + GetRecoilPivot()) >> GetPlayerAim()));
		}
		if (GasSpray != None)
		{
			GasSpray.SetLocation(CX61Attachment(ThirdPersonActor).GetAltTipLocation());
			GasSpray.SetRotation(rotator(Vector(GetAimPivot() + GetRecoilPivot()) >> GetPlayerAim()));
		}
	}
}

simulated event Tick (float DT)
{
	super.Tick(DT);
	if (StoredGas < default.StoredGas && ( FireMode[1]==None || !FireMode[1].IsFiring() ))
		StoredGas = FMin(default.StoredGas, StoredGas + (DT / 10) * (1 + StoredGas/default.StoredGas) );
}

simulated event Destroyed()
{
	if (Flame != None)
		Flame.bHidden=false;
	if (GasSpray != None)
		GasSpray.bHidden=false;
	super.Destroyed();
}

simulated function float ChargeBar()
{
	return StoredGas;
}

static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_SARClip';
}

simulated function PlayReload()
{
	if (MagAmmo < 1)
		SetBoneScale (1, 0.0, 'Bullet');

	super.PlayReload();
}

simulated function Notify_ClipOutOfSight()
{
	SetBoneScale (1, 1.0, 'Bullet');
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
	if (Dist > 700)
		Result += 0.3;
	else if (B.Enemy.Weapon != None && B.Enemy.Weapon.bMeleeWeapon)
		Result -= 0.05 * B.Skill;
	if (Dist > 2000)
		Result -= (Dist-2000) / 4000;

	return Result;
}
// tells bot whether to charge or back off while using this weapon
function float SuggestAttackStyle()	{	return 0.1;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====

defaultproperties
{
     AimAdjustTime=0.400000
     AimSpread=(X=(Min=-32.000000,Max=32.000000),Y=(Min=-32.000000,Max=32.000000))
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.CX61Attachment'
     BallisticInventoryGroup=5
     bCockOnEmpty=True
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     BigIconMaterial=Texture'BWBP_SKC_TexExp.Icons.BigIcon_CX61'
     bNeedCock=True
     bNoCrosshairInScope=True
     BobDamping=1.700000
     BringUpSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Pullout')
     BringUpTime=0.4
	 SelectAnimRate=1.4
     bShowChargingBar=True
     bWT_Bullet=True
     bWT_Machinegun=True
     ChaosDeclineTime=1.000000
     ChaosSpeedThreshold=1200.000000
     ChaosTurnThreshold=170000.000000
     ClipInFrame=0.650000
     ClipInSound=(Sound=Sound'BallisticSounds3.SAR.SAR-ClipIn')
     ClipOutSound=(Sound=Sound'BallisticSounds3.SAR.SAR-ClipOut')
     CockAnimPostReload="ReloadEndCock"
     CockSound=(Sound=Sound'BallisticSounds3.SAR.SAR-Cock')
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.A73OutA',Pic2=Texture'BallisticUI2.Crosshairs.M50InA',USize1=256,VSize1=256,USize2=256,VSize2=256,Color1=(A=128),StartSize1=70,StartSize2=82)
     CrosshairInfo=(SpreadRatios=(Y1=0.800000,Y2=1.000000),MaxScale=6.000000)
     CrouchAimFactor=0.900000
     CurrentWeaponMode=0
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="CX-61 'Spectre' Flechette Rifle||Manufacturer: Frontier Tech|Primary: 10mm DU Flechettes|Secondary: Healing Gas/Flamethrower || The CX-61 is a powerful anti-Cryon flechette rifle designed primarily around reverse-engineered technology. Unlike most of Frontier Tech's weaponry, the CX-61 uses ballistic ammunition, specifically a special 10mm Depleted Uranium penetrator round with a Cryon designed propellant. These rounds rip through Cryon battlearmor with relative ease, allowing UTC soldiers to burn away the fleshy material that binds their mechanical components together. For this purpose, the gun additionally comes with an ignitable, dual-purpose gas dispenser that can release either ignited or unignitied G28 fumes to heal allies or set opponents alight. This gas supply is constantly replenished by a Cryon nano-forge housed in the receiver. It is strongly recommended to check the ignition status before attempting to assist allied soldiers."
     DisplayFOV=55.000000
     DrawScale=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.CX61PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.CX61SecondaryFire'
     GroupOffset=2
     GunLength=16.000000
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.Icons.Icon_CX61'
     InventoryGroup=4
     ItemName="CX61 Flechette Rifle"
     JumpChaos=0.300000
     JumpOffSet=(Pitch=1000,Yaw=-500)
     LightBrightness=130.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=3.000000
     LightSaturation=150
     LightType=LT_Pulse
     LongGunOffset=(X=-20.000000,Y=0.000000,Z=-15.000000)
     LongGunPivot=(Pitch=2000,Yaw=-1024)
     MagAmmo=16
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.Spectre_FP'
     PickupClass=Class'CX61Pickup'
     PlayerViewOffset=(X=2.000000,Y=7.000000,Z=-14.000000)
     Priority=32
     PutDownSound=(Sound=Sound'BallisticSounds2.XK2.XK2-Putaway')
     PutDownTime=0.4
	 PutDownAnimRate=1.5
     RecoilDeclineDelay=0.15
     RecoilDeclineTime=1.5
     RecoilMax=4096
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=-0.060000),(InVal=0.400000,OutVal=0.110000),(InVal=0.500000,OutVal=-0.120000),(InVal=0.600000,OutVal=0.130000),(InVal=0.800000,OutVal=0.160000),(InVal=1.000000)))
     RecoilXFactor=0.350000
     RecoilYawFactor=1
     RecoilYCurve=(Points=(,(InVal=0.100000,OutVal=0.1000),(InVal=0.200000,OutVal=0.19000),(InVal=0.400000,OutVal=0.360000),(InVal=0.600000,OutVal=0.650000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.350000
     SelectForce="SwitchToAssaultRifle"
     SightDisplayFOV=40.000000
     SightOffset=(Y=-0.350000,Z=22.800000)
     SightPivot=(Pitch=600)
     SpecialInfo(0)=(Info="240.0;25.0;0.8;90.0;0.0;1.0;0.0")
     SprintOffSet=(Pitch=-3000,Yaw=-4000)
     StoredGas=1
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     ViewRecoilFactor=0.200000
     WeaponModes(0)=(ModeName="Flamethrower",ModeID="WM_FullAuto")
     WeaponModes(1)=(ModeName="Healing Gas",ModeID="WM_FullAuto")
     WeaponModes(2)=(bUnavailable=True)
//     HudColor=(B=255,G=50,R=0)
}
