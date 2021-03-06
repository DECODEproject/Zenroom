-- This file is part of Zenroom (https://zenroom.dyne.org)
--
-- Copyright (C) 2020-2021 Dyne.org foundation designed, written and
-- maintained by Denis Roio <jaromil@dyne.org>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Affero General Public License as
-- published by the Free Software Foundation, either version 3 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
-- Affero General Public License for more details.
--
-- You should have received a copy of the GNU Affero General Public
-- License along with this program.  If not, see
-- <https://www.gnu.org/licenses/>.

-- Revokable attribute based credentials implementation in Zencode

-- ABC crypto scheme used for BLS based credentials

local ABC = require_once'crypto_abc'
local PET = require_once'crypto_petition'

local function petition_scores_f(o)
	local obj = deepmap(CONF.input.encoding.fun, o)
	return ({
		pos = {
			left = ZEN.get(obj.pos, 'left', ECP.new),
			right = ZEN.get(obj.pos, 'right', ECP.new)
		},
		neg = {
			left = ZEN.get(obj.neg, 'left', ECP.new),
			right = ZEN.get(obj.neg, 'right', ECP.new)
		}
	})
end

-- function definitions aligned with zencode_credentials
local function verifier_f(obj)
	return {
		alpha = ZEN.get(obj, 'alpha', ECP2.new),
		beta = ZEN.get(obj, 'beta', ECP2.new)
	}
end
local function credential_proof_f(obj)
	return {
		nu = ZEN.get(obj, 'nu', ECP.new),
		kappa = ZEN.get(obj, 'kappa', ECP2.new),
		pi_v = {
			c = ZEN.get(obj.pi_v, 'c', INT.new),
			rm = ZEN.get(obj.pi_v, 'rm', INT.new),
			rr = ZEN.get(obj.pi_v, 'rr', INT.new)
		},
		sigma_prime = {
			h_prime = ZEN.get(obj.sigma_prime, 'h_prime', ECP.new),
			s_prime = ZEN.get(obj.sigma_prime, 's_prime', ECP.new)
		}
	}
end
-- end of schemas from zencode_credentials

-- petition
ZEN.add_schema(
	{
		petition_scores = petition_scores_f,
		petition = function(obj)
			local res = {
				uid = ZEN.get(obj, 'uid'),
				scores = petition_scores_f(obj.scores)
			}
			if obj.owner then
				res.owner = ZEN.get(obj, 'owner', ECP.new)
			end
			if obj.vkeys then
				res.vkeys = verifier_f(obj.vkeys)
			end
			if obj.verifier then
				res.verifier = verifier_f(obj.verifier)
			end
			if obj.list then
				res.list =
					deepmap(
					function(o)
						return ZEN.get(o, '.', ECP.new)
					end,
					obj.list
				)
			end
			if obj.signature then
				res.signature = {
					r = ZEN.get(obj.signature, 'r'),
					s = ZEN.get(obj.signature, 's')
				}
			end
			return res
		end,
		petition_signature = function(obj)
			return {
				proof = credential_proof_f(obj.proof),
				uid_signature = ZEN.get(obj, 'uid_signature', ECP.new),
				uid_petition = ZEN.get(obj, 'uid_petition')
			}
		end,
		petition_tally = function(obj)
			local dec = {}
			dec.neg = ZEN.get(obj.dec, 'neg', ECP.new)
			dec.pos = ZEN.get(obj.dec, 'pos', ECP.new)
			return {
				uid = ZEN.get(obj, 'uid'),
				c = ZEN.get(obj, 'c', INT.new),
				dec = dec,
				rx = ZEN.get(obj, 'rx', INT.new)
			}
		end
	}
)

When(
	"create the petition ''",
	function(uid)
		ZEN.have'keys'
		ZEN.assert(ACK.keys.credential,"Credential key not found")
		ACK.petition = {
			uid = OCTET.from_string(uid), -- TODO: take UID from HEAP not STACK
			owner = ECP.generator() * ACK.keys.credential,
			scores = {
				pos = {
					left = ECP.infinity(),
					right = ECP.infinity()
				},
				neg = {
					left = ECP.infinity(),
					right = ECP.infinity()
				}
			}
		}
		ZEN.CODEC.petition = {
			name = 'petition',
			encoding = check_codec('petition'),
			zentype = 'schema'
		}
		-- generate an ECDH signature of the (encoded) petition using the
		-- credential keys
		-- ecdh = ECDH.new()
		-- ecdh:private(ACK.cred_kp.private)
		-- ACK.petition_ecdh_sign = { ecdh:sign(MSG.pack(OUT.petition)) }
		-- OUT.petition_ecdh_sign = map(ACK.petition_ecdh_sign, hex)
	end
)

When(
	'verify the new petition to be empty',
	function()
		ZEN.assert(
			ECP.isinf(ACK.petition.scores.pos.left),
			'Invalid new petition: positive left score is not zero'
		)
		ZEN.assert(
			ECP.isinf(ACK.petition.scores.pos.right),
			'Invalid new petition: positive right score is not zero'
		)
		ZEN.assert(
			ECP.isinf(ACK.petition.scores.neg.left),
			'Invalid new petition: negative left score is not zero'
		)
		ZEN.assert(
			ECP.isinf(ACK.petition.scores.neg.right),
			'Invalid new petition: negative right score is not zero'
		)
	end
)

When(
	"create the petition signature ''",
	function(uid)
		ZEN.have'credentials'
		ZEN.have'verifiers'
		ZEN.have'keys'
		ZEN.assert(ACK.keys.credential,'Credential key not found')
		local Theta
		local zeta
		local ack_uid = OCTET.from_string(uid)
		Theta, zeta =
			ABC.prove_cred_uid(
			ACK.verifiers,
			ACK.credentials,
			ACK.keys.credential,
			ack_uid
		)
		ACK.petition_signature = {
			proof = Theta,
			uid_signature = zeta, -- ECP
			uid_petition = ack_uid
		}
	end
)

When(
	'verify the signature proof is correct',
	function()
		ZEN.assert(
			ABC.verify_cred_uid(
				ACK.verifiers,
				ACK.petition_signature.proof,
				ACK.petition_signature.uid_signature,
				ACK.petition_signature.uid_petition
			),
			'Petition signature is invalid'
		)
	end
)

When(
	'the petition signature is not a duplicate',
	function()
		if luatype(ACK.petition.list) == 'table' then
			ZEN.assert(
				(not array_contains(
					ACK.petition.list,
					ACK.petition_signature.uid_signature
				)),
				'Duplicate petition signature detected'
			)
		else
			ACK.petition.list = {}
		end
		table.insert(ACK.petition.list, ACK.petition_signature.uid_signature)
	end
)

When(
	'the petition signature is just one more',
	function()
		-- verify that the signature is +1 (no other value supported)
		ACK.petition_signature.one =
			PET.prove_sign_petition(ACK.petition.owner, BIG.new(1))
		ZEN.assert(
			PET.verify_sign_petition(
				ACK.petition.owner,
				ACK.petition_signature.one
			),
			'ABC petition signature adds more than one signature'
		)
	end
)

When(
	'add the signature to the petition',
	function()
		-- add the signature to the petition count
		local scores = ACK.petition.scores
		local psign = ACK.petition_signature.one
		scores.pos.left = scores.pos.left + psign.scores.pos.left
		scores.pos.right = scores.pos.right + psign.scores.pos.right
		scores.neg.left = scores.neg.left + psign.scores.neg.left
		scores.neg.right = scores.neg.right + psign.scores.neg.right
		-- TODO: ZEN:push({'petition' ,'scores'}
		ACK.petition.scores = scores
	end
)

When(
	'create a petition tally',
	function()
		ZEN.assert(
			ACK.keys.credential,
			'Private key not found in credential keypair'
		)
		ZEN.assert(ACK.petition, 'Petition not found')
		ACK.petition_tally =
			PET.prove_tally_petition(
			ACK.keys.credential,
			ACK.petition.scores
		)
		ACK.petition_tally.uid = ACK.petition.uid
	end
)

When(
	'count the petition results',
	function()
		ZEN.assert(ACK.petition, 'Petition not found')
		ZEN.assert(ACK.petition_tally, 'Tally not found')
		ZEN.assert(
			ACK.petition_tally.uid == ACK.petition.uid,
			'Tally does not correspond to petition'
		)
		ACK.petition_results =
			PET.count_signatures_petition(
			ACK.petition.scores,
			ACK.petition_tally
		).pos
	end
)
