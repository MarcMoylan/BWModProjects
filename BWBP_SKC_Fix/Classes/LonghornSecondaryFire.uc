//=============================================================================
// Longhorn secondary fire
//
// Sprays clusters of death in a similar manner to a shotgun
//
// by Casey "The Xavious" Johnson
//=============================================================================
class LonghornSecondaryFire extends BallisticProjectileFire;

var byte ProjectileCount;

function ServerPlayFiring()
{
	super.ServerPlayFiring();
	LonghornLauncher(Weapon).LonghornFired();
}

//Do the spread on the client side
function PlayFiring()
{
	super.PlayFiring();
	LonghornLauncher(Weapon).LonghornFired();
}

// Get aim then spawn projectile
function DoFireEffect()
{
    local Vector StartTrace, X, Y, Z, Start, End, HitLocation, HitNormal;
    local Rotator Aim;
	local actor Other;
	local int i;

    Weapon.GetViewAxes(X,Y,Z);
    // the to-hit trace always starts right in front of the eye
    Start = Instigator.Location + Instigator.EyePosition();

    StartTrace = Start + X*SpawnOffset.X + Z*SpawnOffset.Z;
    if(!Weapon.WeaponCentered())
	    StartTrace = StartTrace + Weapon.Hand * Y*SpawnOffset.Y;

	for(i=0; i < (ProjectileCount-1); i++)
	{
		Aim = GetFireAim(StartTrace);
		Aim = Rotator(GetFireSpread() >> Aim);

		End = Start + (Vector(Aim)*MaxRange());
		Other = Trace (HitLocation, HitNormal, End, Start, true);

		if (Other != None)
			Aim = Rotator(HitLocation-StartTrace);

		SpawnProjectile(StartTrace, Aim);
	}

	SendFireEffect(none, vect(0,0,0), StartTrace, 0);
	Super.DoFireEffect();
}

defaultproperties
{
     bCockAfterFire=True
     ProjectileClass=Class'LonghornClusterGrenadeAlt'
     ProjectileCount=8
     BallisticFireSound=(Sound=Sound'BWBP_SKC_SoundsExp.Longhorn.Longhorn-FireAlt',Volume=1.700000)
     XInaccuracy=500
     YInaccuracy=500
     VelocityRecoil=800.000000
}
