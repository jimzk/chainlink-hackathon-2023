// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 20491192805390485299153009773594534940189261866228447918068658471970481763042;
    uint256 constant alphay  = 9383485363053290200918347156157836566562967994039712273449902621266178545958;
    uint256 constant betax1  = 4252822878758300859123897981450591353533073413197771768651442665752259397132;
    uint256 constant betax2  = 6375614351688725206403948262868962793625744043794305715222011528459656738731;
    uint256 constant betay1  = 21847035105528745403288232691147584728191162732299865338377159692350059136679;
    uint256 constant betay2  = 10505242626370262277552901082094356697409835680220590971873171140371331206856;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 21123566812647512440160169877836656797717899770123336419072992569379057132059;
    uint256 constant deltax2 = 10532969933160472488544725974676172937245268580301381319710739250793312360839;
    uint256 constant deltay1 = 8242794290348542147937827669485542761081323263202970706081698386722149313519;
    uint256 constant deltay2 = 17601228624893609784876110801518270352158340825875187409342319796970738450374;

    
    uint256 constant IC0x = 19429044056060238262115833604068376722147814955211764203740410563204610411929;
    uint256 constant IC0y = 15155697342793419355049185513910993789803151340476806714684015062824980652320;
    
    uint256 constant IC1x = 18117416875679841919629264953250348771067341346628960750061160290502919845637;
    uint256 constant IC1y = 459285168631536611944435450561705180881543582358960732223674842780534927525;
    
    uint256 constant IC2x = 1181323623466818799367738197860455149431229555500745520333170100551505460405;
    uint256 constant IC2y = 5120957144377915886956509223979070239709657163067382132897997846739627808566;
    
    uint256 constant IC3x = 3247224967177002142893192913712900274753681585315153019353320909824752182280;
    uint256 constant IC3y = 5064251136185699784254957959249120092571645492200355434286339527027385672625;
    
    uint256 constant IC4x = 16397221648587604678193415573770623547082573483474682408152270654998810357156;
    uint256 constant IC4y = 163841589586536587899038344065368244102242244844313500385507675471859564226;
    
    uint256 constant IC5x = 10891520795919358995764975131362235393537800968428554886877878062108375819796;
    uint256 constant IC5y = 16875527534433407549224199961250481762730081287984380539056529141416573103022;
    
    uint256 constant IC6x = 4479877085673209270749083552908627030635090151599795147688214148252961212537;
    uint256 constant IC6y = 14013712743473736504526116417948587119841658577441597636303290437684693661493;
    
    uint256 constant IC7x = 5689527960455444519230490161681903214351085405120394518675540943064824727241;
    uint256 constant IC7y = 19141600857059484867672737758978453636106394120401832131181918290532372600696;
    
    uint256 constant IC8x = 12392781303547014809173021136593872972765772525009964467703309758433121569390;
    uint256 constant IC8y = 4220046681270888721061630197714864736657924505868000585715465948155784807058;
    
    uint256 constant IC9x = 12343313284077446488289457901956856475301154071857608432664147579255442994248;
    uint256 constant IC9y = 18108767883597510056624730465315957647400083853009476149630727514291128347857;
    
    uint256 constant IC10x = 10688302574436784682861640766081397233579858533877849284958870394942164479323;
    uint256 constant IC10y = 15770991605493202750438802559259588651101393944672963597727140774750381895881;
    
    uint256 constant IC11x = 9792918520839049418324473480409236144487037813313025162340259106840685591740;
    uint256 constant IC11y = 13160638404284687620609648122989722287249180308718312547645188013900616152539;
    
    uint256 constant IC12x = 5701720957975557007553570450191584910584339784619005098424085821033944008381;
    uint256 constant IC12y = 8657540939295766280379739579013001617150913413779773519708863867762629955542;
    
    uint256 constant IC13x = 8373582170246519906692268388372283666440257002628588334372878804830029629375;
    uint256 constant IC13y = 283833845263480159123070381808367516893414150519514828499802418265769557931;
    
    uint256 constant IC14x = 8591609617868863605892312458620419273463873390634835910031543195304008604373;
    uint256 constant IC14y = 4014754629006190407737032605713732177757380655259460132191567860916004054114;
    
    uint256 constant IC15x = 10194021975367084665619452512802361462089366144286722823977630308292946371304;
    uint256 constant IC15y = 7401764288587658454099911921065975669917359144825743471380315433966464600431;
    
    uint256 constant IC16x = 7254427443282144190643158787985767505619638145938468989837394104458706108588;
    uint256 constant IC16y = 11017696343755391394365068140020793680429874324003025121087933935923452218214;
    
    uint256 constant IC17x = 18644706761001405371901093785176417251212950839040944197955160553315319930001;
    uint256 constant IC17y = 6496436130122149956868470253837593237073867713388996500456580503031974917537;
    
    uint256 constant IC18x = 9851878288217241855002967048126650523825102294992601265918454872263618576942;
    uint256 constant IC18y = 14919674768905224569368826651169610381413947377333594325168660432463576116872;
    
    uint256 constant IC19x = 17261259389878833795924737331145677219172911545939218550872890548257481360803;
    uint256 constant IC19y = 14078534065753855819290851135679530508227228110601749977625612135286644050224;
    
    uint256 constant IC20x = 14317736076901790281158649594883473656034831689400119305905913991501028830635;
    uint256 constant IC20y = 6653709944095410086517602370698178616867828369157770131616149129735650673326;
    
    uint256 constant IC21x = 6148641159182362257202004749360506928061308506082182748469121302761712017486;
    uint256 constant IC21y = 19853833930070323867325861795736949195186520182662882243528193211993827456678;
    
    uint256 constant IC22x = 197215308917096955813106476506311193766546705780745092029316486455380455065;
    uint256 constant IC22y = 15843621067701290551879547037244103833614527229366984126416183793547850423641;
    
    uint256 constant IC23x = 12146283611038281720778074038681373999646343435078792577537725696803883367463;
    uint256 constant IC23y = 5356193715595475321376274293344247588225018856264259871410601921100918638736;
    
    uint256 constant IC24x = 19898316554145324660025020300538585727337034576976106435555921340627286622308;
    uint256 constant IC24y = 12228311511047171428972500906630083142005736696520862279818540705339941106706;
    
    uint256 constant IC25x = 3523671093109801547221305575402285229883419368334051217818773701925401427988;
    uint256 constant IC25y = 16801927464850899127681968616643759843951712817666317709034061204850146138107;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[25] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
