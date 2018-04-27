#include <jutils.h>
#include <zen_ecdh.h>

#include <ecdh_ED25519.h>
#include <ecdh_NIST256.h>
#include <ecdh_GOLDILOCKS.h>
#include <ecdh_BN254CX.h>
#include <ecdh_FP256BN.h>

ecdh *ecdh_new_curve(lua_State *L, const char *curve) {
	ecdh *e = NULL;
	if(strcasecmp(curve,"ec25519")   ==0
	   || strcasecmp(curve,"ed25519")==0
	   || strcasecmp(curve,"25519")  ==0) {
		e = (ecdh*)lua_newuserdata(L, sizeof(ecdh));
		e->keysize = EGS_ED25519; // keysize seems always equal to
								  // fieldsize but since milagro uses
								  // two different defines...
		e->fieldsize = EFS_ED25519; 
		e->rng = NULL;
		e->hash = HASH_TYPE_ECC_ED25519;
		e->ECP__KEY_PAIR_GENERATE = ECP_ED25519_KEY_PAIR_GENERATE;
		e->ECP__PUBLIC_KEY_VALIDATE	= ECP_ED25519_PUBLIC_KEY_VALIDATE;
		e->ECP__SVDP_DH = ECP_ED25519_SVDP_DH;
		e->ECP__ECIES_ENCRYPT = ECP_ED25519_ECIES_ENCRYPT;
		e->ECP__ECIES_DECRYPT = ECP_ED25519_ECIES_DECRYPT;
		e->ECP__SP_DSA = ECP_ED25519_SP_DSA;
		e->ECP__VP_DSA = ECP_ED25519_VP_DSA;
		strncpy(e->curve,curve,15);
#if CURVETYPE_ED25519==MONTGOMERY
		strcpy(e->type,"montgomery");
#elif CURVETYPE_ED25519==WEIERSTRASS
		strcpy(e->type,"weierstrass");
#elif CURVETYPE_ED25519==EDWARDS
		strcpy(e->type,"edwards");
#else
		strcpy(e->type,"unknown");
#endif
	} else if(strcasecmp(curve,"nist256")==0) {
			e = (ecdh*)lua_newuserdata(L, sizeof(ecdh));
			e->keysize = EGS_NIST256;
			e->fieldsize = EFS_NIST256;
			e->rng = NULL;
			e->hash = HASH_TYPE_ECC_NIST256;
			e->ECP__KEY_PAIR_GENERATE = ECP_NIST256_KEY_PAIR_GENERATE;
			e->ECP__PUBLIC_KEY_VALIDATE	= ECP_NIST256_PUBLIC_KEY_VALIDATE;
			e->ECP__SVDP_DH = ECP_NIST256_SVDP_DH;
			e->ECP__ECIES_ENCRYPT = ECP_NIST256_ECIES_ENCRYPT;
			e->ECP__ECIES_DECRYPT = ECP_NIST256_ECIES_DECRYPT;
			e->ECP__SP_DSA = ECP_NIST256_SP_DSA;
			e->ECP__VP_DSA = ECP_NIST256_VP_DSA;

	} else if(strcasecmp(curve,"goldilocks")==0) {
		e = (ecdh*)lua_newuserdata(L, sizeof(ecdh));
		e->keysize = EGS_GOLDILOCKS;
		e->fieldsize = EFS_GOLDILOCKS;
		e->rng = NULL;
		e->hash = HASH_TYPE_ECC_GOLDILOCKS;
		e->ECP__KEY_PAIR_GENERATE = ECP_GOLDILOCKS_KEY_PAIR_GENERATE;
		e->ECP__PUBLIC_KEY_VALIDATE	= ECP_GOLDILOCKS_PUBLIC_KEY_VALIDATE;
		e->ECP__SVDP_DH = ECP_GOLDILOCKS_SVDP_DH;
		e->ECP__ECIES_ENCRYPT = ECP_GOLDILOCKS_ECIES_ENCRYPT;
		e->ECP__ECIES_DECRYPT = ECP_GOLDILOCKS_ECIES_DECRYPT;
		e->ECP__SP_DSA = ECP_GOLDILOCKS_SP_DSA;
		e->ECP__VP_DSA = ECP_GOLDILOCKS_VP_DSA;

	} else if(strcasecmp(curve,"bn254cx")==0) {
		e = (ecdh*)lua_newuserdata(L, sizeof(ecdh));
		e->keysize = EGS_BN254CX;
		e->fieldsize = EFS_BN254CX;
		e->rng = NULL;
		e->hash = HASH_TYPE_ECC_BN254CX;
		e->ECP__KEY_PAIR_GENERATE = ECP_BN254CX_KEY_PAIR_GENERATE;
		e->ECP__PUBLIC_KEY_VALIDATE	= ECP_BN254CX_PUBLIC_KEY_VALIDATE;
		e->ECP__SVDP_DH = ECP_BN254CX_SVDP_DH;
		e->ECP__ECIES_ENCRYPT = ECP_BN254CX_ECIES_ENCRYPT;
		e->ECP__ECIES_DECRYPT = ECP_BN254CX_ECIES_DECRYPT;
		e->ECP__SP_DSA = ECP_BN254CX_SP_DSA;
		e->ECP__VP_DSA = ECP_BN254CX_VP_DSA;

	} else if(strcasecmp(curve,"fp256bn")==0) {
		e = (ecdh*)lua_newuserdata(L, sizeof(ecdh));
		e->keysize = EGS_FP256BN;
		e->fieldsize = EFS_FP256BN;
		e->rng = NULL;
		e->hash = HASH_TYPE_ECC_FP256BN;
		e->ECP__KEY_PAIR_GENERATE = ECP_FP256BN_KEY_PAIR_GENERATE;
		e->ECP__PUBLIC_KEY_VALIDATE	= ECP_FP256BN_PUBLIC_KEY_VALIDATE;
		e->ECP__SVDP_DH = ECP_FP256BN_SVDP_DH;
		e->ECP__ECIES_ENCRYPT = ECP_FP256BN_ECIES_ENCRYPT;
		e->ECP__ECIES_DECRYPT = ECP_FP256BN_ECIES_DECRYPT;
		e->ECP__SP_DSA = ECP_FP256BN_SP_DSA;
		e->ECP__VP_DSA = ECP_FP256BN_VP_DSA;

	} else {
		error(L, "%s: curve not found: %s",__func__,curve);
		return NULL;
	}
	return e;
}
