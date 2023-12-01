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


    uint256 constant IC0x = 16824256397320729306061965119002505371599364970052537872044115709603930988361;
    uint256 constant IC0y = 8762920134116712864921248774767462217299386018243798513895638657038568139933;

    uint256 constant IC1x = 3776156023827019333760249060194375090175479051148940942636815653367934154654;
    uint256 constant IC1y = 16861871056453103222862222550828470327318725815630429110512028084803138124070;

    uint256 constant IC2x = 4103515580317220994512964633562854338249068020486273897629797113197244023954;
    uint256 constant IC2y = 8666538725719212713435808016488079371511409382306994691159421223062333850857;

    uint256 constant IC3x = 6091858986434499115126333392905861552658019602921412547888917691754325145925;
    uint256 constant IC3y = 16033692573663701559596119196003232997683554627199782895832135573892561388919;

    uint256 constant IC4x = 4678612079381725731100939269518349953848846385795338580802025865177794424666;
    uint256 constant IC4y = 2935819574174148602884935752976414990938416069878480442575060591536101094487;

    uint256 constant IC5x = 4079904415657632863206315357330308212291814104720367982554102396084723135890;
    uint256 constant IC5y = 12143328676221278470831099869582251450366183048142606139569615401871304691595;

    uint256 constant IC6x = 18725874572146404243507201138557285021543409582206336375377375947235309682713;
    uint256 constant IC6y = 13523122271916556711778423480462037552008302135881984188104453083277955774410;

    uint256 constant IC7x = 18414477628910402342170832829713049777127062619838144321691061141653286626330;
    uint256 constant IC7y = 20721050370390491516940073597842809458931568103054302128338544354939935177257;

    uint256 constant IC8x = 1230980211706989184964228447174448705540304042460581334320932769622141453243;
    uint256 constant IC8y = 16641004997156297020154746815258019355806881186773141676538829255183816897482;

    uint256 constant IC9x = 17830633038971082609471237662317440070254158701536681845656829586841773056036;
    uint256 constant IC9y = 18059291689320884574786567916463167369838071155632991871196191392509601156354;

    uint256 constant IC10x = 20787177941336996517963517199965869133867165208327492556316285784310380788368;
    uint256 constant IC10y = 715031547383069878649318882554542227476504394098575497084222307867538250136;

    uint256 constant IC11x = 19605262515476420882170375370102935167858615313603539541301630933239686848705;
    uint256 constant IC11y = 5719608785369601932509456226856565574130766339578912405390363187021740447039;

    uint256 constant IC12x = 6784682837562158127312237361236099908058957770274679712025263675666137192416;
    uint256 constant IC12y = 20445400130355653431186241226900900727089827411242091478420352268319524494320;

    uint256 constant IC13x = 6220941792508330833477357621008746864525623115934877000388434590205836422007;
    uint256 constant IC13y = 9460667163597040165446874833901567048857117225247262482577839733312640395146;

    uint256 constant IC14x = 20848620582154662280271567304607915410210831750247574439380449739622516571380;
    uint256 constant IC14y = 20277683213099294640484900311681158479001811619789868542117288171992230033458;

    uint256 constant IC15x = 20543672345626891633251135368647477133446990881895068373378542690218395691992;
    uint256 constant IC15y = 6464173200689648291935441401875331671077917904104128219169249582634665788783;

    uint256 constant IC16x = 7558947129627660894552879513189614063273534121017304751546245076425420910959;
    uint256 constant IC16y = 17880010172449431291489987669278463665782798351899542140753228234437399178497;

    uint256 constant IC17x = 1519674076919855595741375874663388334173901522728851899329395481089355817793;
    uint256 constant IC17y = 20408145016442772065601356057643979691250769351768530886245117490110995738000;

    uint256 constant IC18x = 16138069595555550322632399277592085469969191598516839625227968630771937083466;
    uint256 constant IC18y = 3238820981042720827280304274918340628678188096822606288010852205449108073011;

    uint256 constant IC19x = 3109960615874370959891716752691684729205482889044443605692352667246585279971;
    uint256 constant IC19y = 7977189386325117347562587437111920725222839758996529751820213045597097874267;

    uint256 constant IC20x = 3843340011267498407856067138948087649240519899315852678082616665283037534187;
    uint256 constant IC20y = 4841107759249381283188567734393895282185005193057283833995426981022795437510;

    uint256 constant IC21x = 4781802581499814451191602178263821381990537356108148597159888560979860994308;
    uint256 constant IC21y = 20374563586394224249725159473212156499338934929333763760346921264788472654370;

    uint256 constant IC22x = 10242064798333768336557341561306374788560275984873009149170059462596746360030;
    uint256 constant IC22y = 641042262914182371112644003424349352672745735576190639506440167376758572378;

    uint256 constant IC23x = 14647595737289701673061540105353286743706068844251364280113683660513235891255;
    uint256 constant IC23y = 2195328591581771189730362521837173806542340960984041679821150459706060366255;

    uint256 constant IC24x = 7344000402710370807147311948726074911740553836845347848089141949386104797461;
    uint256 constant IC24y = 4278302095716830597215152999919503918127712046532631324617572169043921164118;

    uint256 constant IC25x = 5529718357361439615042518005157942615808301186067631731773214820631999418462;
    uint256 constant IC25y = 5929995916292217760714876282959719312847247934531933897722897519448088984077;

    uint256 constant IC26x = 9782184381446979361164049532157933361250354281524687476793508200625106106886;
    uint256 constant IC26y = 8665162975177549629918814838702551750321978922051911344489943407591119479541;

    uint256 constant IC27x = 21278755229895542865227983864410871751191301400086807337238192036470575139598;
    uint256 constant IC27y = 2506439159754441567074548112825578122132440816040461406670361568492353937337;


    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[27] calldata _pubSignals) public view returns (bool) {
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

                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))

                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))


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

            checkField(calldataload(add(_pubSignals, 832)))

            checkField(calldataload(add(_pubSignals, 864)))


            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
