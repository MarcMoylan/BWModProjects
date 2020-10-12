//=============================================================================
// MJ51Carbine.
//
// Medium range, controllable 3-round burst carbine.
// Lacks power and accuracy at range, but is easier to aim
//
// by Sarge.
// Copyright(c) 2005 RuneStorm. All Rights Reserved.
//=============================================================================
class MJ51Carbine extends BallisticWeapon;

var() bool		bFirstDraw;
var() name		GrenadeLoadAnim;	//Anim for grenade reload
var()   bool		bLoaded;


var() name		GrenBone;			
var() name		GrenBoneBase;
var() Sound		GrenSlideSound;		//Sounds for grenade reloading
var() Sound		ClipInSoundEmpty;		//			

var name			BulletBone;
var name			BulletBone2;


static function class<Pickup> RecommendAmmoPickup(int Mode)
{
	return class'AP_STANAGChaff';
}

//Chaff grenade spawn moved here
function GiveTo(Pawn Other, optional Pickup Pickup)
{
    local int m;
    local weapon w;
    local bool bPossiblySwitch, bJustSpawned;

    Instigator = Other;
    W = Weapon(Other.FindInventoryType(class));
    if ( W == None || class != W.Class)
    {
		bJustSpawned = true;
        Super(Inventory).GiveTo(Other);
        bPossiblySwitch = true;
        W = self;
		if (Pickup != None && BallisticWeaponPickup(Pickup) != None)
			MagAmmo = BallisticWeaponPickup(Pickup).MagAmmo;
    }
 	
   	else if ( !W.HasAmmo() )
	    bPossiblySwitch = true;

    if ( Pickup == None )
        bPossiblySwitch = true;

    for (m = 0; m < NUM_FIRE_MODES; m++)
    {
        if ( FireMode[m] != None )
        {
            FireMode[m].Instigator = Instigator;
            GiveAmmo(m,WeaponPickup(Pickup),bJustSpawned);
        }
    }

	if ( (Instigator.Weapon != None) && Instigator.Weapon.IsFiring() )
		bPossiblySwitch = false;

	if ( Instigator.Weapon != W )
		W.ClientWeaponSet(bPossiblySwitch);
		
	//Disable aim for weapons picked up by AI-controlled pawns
	bAimDisabled = default.bAimDisabled || !Instigator.IsHumanControlled();

    if ( !bJustSpawned )
	{
        for (m = 0; m < NUM_FIRE_MODES; m++)
			Ammo[m] = None;
		Destroy();
	}
	
	if ( Instigator.FindInventoryType(class'BCGhostWeapon') != None ) //ghosts are scary
	return;

	if(Instigator.FindInventoryType(class'BWBP_SKC_Fix.ChaffGrenadeWeapon')==None )
	{
		W = Spawn(class'BWBP_SKC_Fix.ChaffGrenadeWeapon',,,Instigator.Location);
		if( W != None)
		{
			W.GiveTo(Instigator);
			W.ConsumeAmmo(0, 9999, true);
			W.ConsumeAmmo(1, 9999, true);
		}
	}
}
simulated event AnimEnd (int Channel)
{
    local name anim;
    local float frame, rate;

    GetAnimParams(0, anim, frame, rate);

	if (Anim == 'Fire' || Anim == 'ReloadEmpty')
	{
		if (MagAmmo - BFireMode[0].ConsumedLoad < 2)
		{
			SetBoneScale(2,0.0,BulletBone);
			SetBoneScale(3,0.0,BulletBone2);
		}
	}
	super.AnimEnd(Channel);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
	if (Instigator != None && AIController(Instigator.Controller) != None)
	{
		AimSpread *= 0.30;
		ChaosAimSpread *= 0.10;
	}

	if (bFirstDraw && MagAmmo > 0)
	{
     	BringUpTime=2.0;
     	SelectAnim='PulloutFancy';
		bFirstDraw=false;
		bLoaded=False;
	}
	else
	{
     	BringUpTime=default.BringUpTime;
		SelectAnim='Pullout';
	}
	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}
	
	if (MagAmmo - BFireMode[0].ConsumedLoad < 1)
	{

		SetBoneScale(2,0.0,BulletBone);
		SetBoneScale(3,0.0,BulletBone2);
		ReloadAnim = 'ReloadEmpty';
	}
	
	else
	{
		ReloadAnim = 'Reload';
	}

	super.BringUp(PrevWeapon);

}

simulated function bool PutDown()
{

	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}

	if (super.PutDown())
	{
		return true;
	}
	return false;
}


// Load in a grenade
simulated function LoadGrenade()
{
	if (Ammo[1].AmmoAmount < 1 || bLoaded)
		return;
	if (ReloadState == RS_None)
		PlayAnim(GrenadeLoadAnim, 1.1, , 0);
}

// Animation notify for when the clip is stuck in
simulated function Notify_ClipUp()
{
	SetBoneScale(2,1.0,BulletBone);
	SetBoneScale(3,1.0,BulletBone2);
}

simulated function Notify_ClipOut()
{
	Super.Notify_ClipOut();

	if(MagAmmo < 1)
	{
		SetBoneScale(2,0.0,BulletBone);
		SetBoneScale(3,0.0,BulletBone2);
	}
}


// Notifys for greande loading sounds
simulated function Notify_GrenVisible()	{	SetBoneScale (0, 1.0, GrenBone); SetBoneScale (1, 1.0, GrenBoneBase);	ReloadState = RS_PreClipOut;}
simulated function Notify_GrenSlide()	{	PlaySound(GrenSlideSound, SLOT_Misc, 2.2, ,64);	}
simulated function Notify_GrenLoaded()	
{
    	local Inventory Inv;

	MJ51Attachment(ThirdPersonActor).bGrenadier=true;	
	MJ51Attachment(ThirdPersonActor).IAOverride(True);

	Ammo[1].UseAmmo (1, True);
	if (Ammo[1].AmmoAmount == 0)
	{
		for ( Inv=Instigator.Inventory; Inv!=None; Inv=Inv.Inventory )
			if (ChaffGrenadeWeapon(Inv) != None)
			{
				ChaffGrenadeWeapon(Inv).RemoteKill();	
				break;
			}
	}
}
simulated function Notify_GrenReady()	{	ReloadState = RS_None; bLoaded = true;	}
simulated function Notify_GrenLaunch()	
{
	SetBoneScale (0, 0.0, GrenBone); 	
	MJ51Attachment(ThirdPersonActor).IAOverride(False);
	MJ51Attachment(ThirdPersonActor).bGrenadier=false;
}
simulated function Notify_GrenInvisible()	{ SetBoneScale (1, 0.0, GrenBoneBase);	}


simulated function PlayReload()
{

    if (MagAmmo < 1)
    {
       ReloadAnim='ReloadEmpty';
       ClipHitSound.Sound=ClipInSoundEmpty;
    }
    else
    {
       ReloadAnim='Reload';
       ClipHitSound.Sound=default.ClipHitSound.Sound;
    }
	if (!bLoaded)
	{
		SetBoneScale (0, 0.0, GrenBone);
		SetBoneScale (1, 0.0, GrenBoneBase);
	}
	SafePlayAnim(ReloadAnim, ReloadAnimRate, , 0, "RELOAD");
}

simulated function IndirectLaunch()
{
//	StartFire(1);
}


// Change some properties when using sights...
simulated function SetScopeBehavior()
{
	super.SetScopeBehavior();
	bUseNetAim = default.bUseNetAim || bScopeView;
	if (bScopeView)
	{
//		SightAimFactor = 0.6;
        	FireMode[0].FireAnim='SightFire';
	}
	else
	{
//		SightAimFactor = default.ViewRecoilFactor;
        	FireMode[0].FireAnim='Fire';
	}
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
				SightingPhase += DT/0.20;
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
				SightingPhase -= DT/0.20;
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
// AI Interface =====
// choose between regular or alt-fire
function byte BestMode()
{
	local Bot B;

	B = Bot(Instigator.Controller);
	if ( (B == None) || (B.Enemy == None) )
		return 0;

	if (B.Skill > Rand(6))
	{
		if (Chaos < 0.1 || Chaos < 0.5 && VSize(B.Enemy.Location - Instigator.Location) > 500)
			return 1;
	}
	else if (FRand() > 0.75)
		return 1;
	return 0;
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
function float SuggestAttackStyle()	{	return 0.0;	}
// tells bot whether to charge or back off while defending against this weapon
function float SuggestDefenseStyle()	{	return 0.5;	}
// End AI Stuff =====



defaultproperties
{
     AIRating=0.600000
     AIReloadTime=1.000000
     AttachmentClass=Class'BWBP_SKC_Fix.MJ51Attachment'
     BallisticInventoryGroup=5
     bCockOnEmpty=False
     BCRepClass=Class'BallisticFix.BallisticReplicationInfo'
     bFirstDraw=True
     BigIconMaterial=Texture'BWBP_SKC_TexExp.M4A1.BigIcon_M4'
     bNeedCock=False
     bNoCrosshairInScope=True
     BobDamping=2.000000
     BringUpSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-PullOut',Volume=2.200000)
     BringUpTime=0.900000
     BulletBone2="Bullet2"
     BulletBone="Bullet1"
     bWT_Bullet=True
     ChaosAimSpread=(X=(Min=-2050.000000,Max=2050.000000),Y=(Min=-2050.000000,Max=2050.000000))
     ChaosDeclineTime=1.0
     ClipHitSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagIn',Volume=4.800000)
     ClipInFrame=0.650000
     ClipInSoundEmpty=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagInEmpty'
     ClipOutSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-MagOut',Volume=4.800000)
     CockSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Cock',Volume=2.200000)
     CrosshairCfg=(Pic1=Texture'BallisticUI2.Crosshairs.M50Out',pic2=Texture'BallisticUI2.Crosshairs.M50In',USize1=128,VSize1=128,USize2=128,VSize2=128,Color1=(B=0,G=0,R=255,A=158),Color2=(B=0,G=255,R=255,A=255),StartSize1=75,StartSize2=72)
     CrouchAimFactor=0.500000
     CurrentRating=0.600000
     CurrentWeaponMode=1
     CustomCrossHairTextureName="Crosshairs.HUD.Crosshair_Cross1"
     Description="MJ51 Carbine||Manufacturer: Majestic Firearms 12|Primary: 5.56mm CAP Rifle Fire|Secondary: Attach Smoke Grenade||The MJ51 is a 3-round burst carbine based off the popular M50 assault rifle. Unlike the M50 and SAR though, it fires a shorter 5.56mm CAP round and is more controllable than its larger cousin, though this comes at the expense of long range accuracy and power. While the S-AR 12 is the UTC's weapon of choice for close range engagements, the MJ51 is often seen in the hands of MP and urban security details. When paired with its native MOA-C Rifle Grenade attachment, the MJ51 makes an efficient riot control weapon. |Majestic Firearms 12 designed their MJ51 carbine alongside their MOA-C Chaff Grenade to produce a rifle with grenade launching capabilities without the need of a bulky launcher that has to be sperately maintained. Utilizing a hardened tungsten barrel and an advanced rifle grenade design, a soldier is able to seamlessly ready a grenade projectile without having to rechamber specilized rounds or operate a secondary weapon."
     DrawScale=0.300000
     FireModeClass(0)=Class'BWBP_SKC_Fix.MJ51PrimaryFire'
     FireModeClass(1)=Class'BWBP_SKC_Fix.MJ51SecondaryFire'
     GrenadeLoadAnim="LoadGrenade"
     GrenBone="Grenade"
     GrenBoneBase="GrenadeHandle"
     GrenSlideSound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-GrenLock'
     GunLength=50.000000
     IconCoords=(X2=127,Y2=31)
     IconMaterial=Texture'BWBP_SKC_TexExp.M4A1.SmallIcon_M4'
     IdleAnimRate=0.200000
     InventoryGroup=4
     ItemName="MJ51 Carbine"
     LightBrightness=150.000000
     LightEffect=LE_NonIncidence
     LightHue=30
     LightRadius=4.000000
     LightSaturation=150
     LightType=LT_Pulse
     LongGunOffset=(x=10.000000,Y=10.000000,Z=-11.000000)
     MagAmmo=30
     Mesh=SkeletalMesh'BWBP_SKC_AnimExp.M4Carbine_FP'
     PickupClass=Class'BWBP_SKC_Fix.MJ51Pickup'
     PlayerViewOffset=(X=-8.000000,Y=10.000000,Z=-14.000000)
     Priority=41
     PutDownSound=(Sound=Sound'BWBP_SKC_SoundsExp.MJ51.MJ51-Putaway',Volume=2.200000)
     PutDownTime=0.700000
     RecoilDeclineDelay=0.100000
     RecoilDeclineTime=1.5
     RecoilPitchFactor=1.500000
     RecoilXCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.300000),(InVal=0.800000,OutVal=-0.400000),(InVal=1.000000,OutVal=-0.200000)))
     RecoilXFactor=1.000000
     RecoilYawFactor=0.400000
     RecoilYCurve=(Points=(,(InVal=0.200000,OutVal=0.100000),(InVal=0.400000,OutVal=0.650000),(InVal=0.600000,OutVal=0.800000),(InVal=0.800000,OutVal=0.900000),(InVal=1.000000,OutVal=1.000000)))
     RecoilYFactor=0.200000
     SelectForce="SwitchToAssaultRifle"
     SightAimFactor = 0.700000
     SightDisplayFOV=40.000000
     SightingTime=0.200000
     SightOffset=(X=0.000000,Y=-6.450000,Z=20.500000)
     SpecialInfo(0)=(Info="240.0;20.0;0.9;75.0;0.8;0.7;0.2")
     SprintOffSet=(Pitch=-3500,Roll=3000,Yaw=-3000)
     TeamSkins(0)=(RedTex=Shader'BallisticWeapons2.Hands.RedHand-Shiny',BlueTex=Shader'BallisticWeapons2.Hands.BlueHand-Shiny')
     ViewAimFactor=0.200000
     ViewRecoilFactor=0.600000
     WeaponModes(1)=(ModeName="Burst")
     WeaponModes(2)=(bUnavailable=True)
     WeaponModes(3)=(bUnavailable=True)
}
