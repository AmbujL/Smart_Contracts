// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract VerifySign {

    function generateHash(
        address _reciever,
        string memory _msg,
        uint _nonce
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_reciever, _msg, _nonce));
    }

  
    function generateMessageSignature(bytes32 _hash)
        public
        pure
        returns (bytes32)
    {
       
        return
            keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", _hash)
            );
    }

    function verify( 
        bytes memory _signature,
        address _signer,
        address _reciever,
        string memory _msg,
        uint _nonce   
    ) public pure returns (bool) {
        bytes32 msgHash = generateHash(_reciever, _msg, _nonce);
        bytes32 msgSignature = generateMessageSignature(msgHash);

        return findSigner(msgSignature, _signature) == _signer;
    }


    function findSigner(bytes32 _msgSignature, bytes memory _signature)
        public
        pure
        returns (address)
    {

         require(_signature.length == 65, "invalid signature length");
         bytes32 r;
         bytes32 s;
         uint8  v;

        assembly {  
            r:= mload(add(_signature, 32))
            s := mload(add(_signature, 64))
            v := byte(0, mload(add(_signature, 96)))
        }

        return ecrecover(_msgSignature, v, r, s);
    }
}
