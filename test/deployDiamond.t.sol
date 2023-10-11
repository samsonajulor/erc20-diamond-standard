// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/ERC20Facet.sol";
import "../contracts/Diamond.sol";
// import console2 from forge
import "../lib/forge-std/src/console2.sol";

import {LibDiamond} from "../contracts/libraries//LibDiamond.sol";

import "./helpers/DiamondUtils.sol";

contract DiamondDeployer is DiamondUtils, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    ERC20Facet erc20Facet;

    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        // diamond = new Diamond(address(this), address(dCutFacet),  "Samosky", "SKY");
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        erc20Facet = new ERC20Facet(18, "Samosky", "SKY");

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](3);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

        cut[2] = (
            FacetCut({
                facetAddress: address(erc20Facet),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("ERC20Facet")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
    }

    function testName() public {
        LibDiamond.setERC20Details("Samosky", "SKY");
        assertEq(ERC20Facet(address(diamond)).getName(), 'Samosky');
        // assertEq(ERC20Facet(address(diamond)).getName(), 'Samosky');
    }

    // function testDecimals() public {
    //     assertEq(ERC20Facet(address(diamond)).decimals(), 18);
    // }

    // function testTransfer() public {
    //     vm.startPrank(address(0x1111));
    //     ERC20Facet(address(diamond)).mint(address(0x1111), 1000e18);
    //     ERC20Facet(address(diamond)).transfer(address(0x2222), 100e18);
    //     assertEq(ERC20Facet(address(diamond)).balanceOf(address(0x1111)), 900e18);
    //     assertEq(ERC20Facet(address(diamond)).balanceOf(address(0x2222)), 100e18);
    //     vm.stopPrank();
    // }

    // function testTransferFrom() public {
    //     vm.startPrank(address(0x1111));
    //     ERC20Facet(address(diamond)).mint(address(0x1111), 10000);
    //     ERC20Facet(address(diamond)).approve(address(diamond), 100);
    //     vm.startPrank(address(diamond));
    //     ERC20Facet(address(diamond)).transferFrom(address(0x1111), address(0x2222), 1);

    // }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
