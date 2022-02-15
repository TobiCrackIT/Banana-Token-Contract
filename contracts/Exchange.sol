// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

//Import ERC20
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Exchange is ERC20 {
    address public bananaTokenAddress;

    constructor(address _BananaToken) ERC20("BananaToken", "BAN") {
        require(_BananaToken != address(0), "Token address passed is null");
        bananaTokenAddress = _BananaToken;
    }

    //Get reserve of BananaToken
    function getReserve() public view returns (uint256) {
        return ERC20(bananaTokenAddress).balanceOf(address(this));
    }

    //Add liquidity to exchange
    function addLiquidity(uint256 _amount) public payable returns (uint256) {
        uint256 liquidity;
        uint256 ethBalance = address(this).balance;
        uint256 bananaTokenReserve = getReserve();
        ERC20 bananaToken = ERC20(bananaTokenAddress);

        if (bananaTokenReserve == 0) {
            bananaToken.transferFrom(msg.sender, address(this), _amount);
            liquidity = ethBalance;
            _mint(msg.sender, liquidity);
        } else {
            uint256 ethReserve = ethBalance - msg.value;

            uint256 bananaTokenAmount = (msg.value * bananaTokenReserve) /
                (ethReserve);
            require(
                _amount >= bananaTokenAmount,
                "Amount of tokens sent is less than the minimum tokens required"
            );

            bananaToken.transferFrom(
                msg.sender,
                address(this),
                bananaTokenAmount
            );
            liquidity = (totalSupply() * msg.value) / ethReserve;

            _mint(msg.sender, liquidity);
        }

        return liquidity;
    }

    function removeLiquidity(uint256 _amount)
        public
        returns (uint256, uint256)
    {
        require(_amount > 0, "Amount must be greater than zero");

        uint256 ethReserve = address(this).balance;
        uint256 _totalSupply = totalSupply();
        uint256 ethAmount = (ethReserve * _amount) / _totalSupply;
        uint256 bananaTokenAmount = (getReserve() * _amount) / _totalSupply;

        _burn(msg.sender, _amount);

        payable(msg.sender).transfer(ethAmount);

        ERC20(bananaTokenAddress).transfer(msg.sender, bananaTokenAmount);

        return (ethAmount, bananaTokenAmount);
    }

    function getAmountOfTokens(
        uint256 inputAmount,
        uint256 inputReserve,
        uint256 outputReserve
    ) public pure returns (uint256) {
        //We are charging a fee of 2%
        require(inputReserve > 0 && outputReserve > 0, "Invalid reserves");

        uint256 inputAmountWithFee = inputAmount * 98;

        uint256 numerator = inputAmountWithFee * outputReserve;

        uint256 denominator = (inputReserve * 100) + inputAmountWithFee;

        return numerator / denominator;
    }

    function swapEthToToken(uint256 _minTokens) public payable {
        uint256 tokenReserve = getReserve();

        uint256 tokensBought = getAmountOfTokens(
            msg.value,
            address(this).balance - msg.value,
            tokenReserve
        );

        require(
            tokensBought >= _minTokens,
            "We cant service your request now. Please try again"
        );

        ERC20(bananaTokenAddress).transfer(msg.sender, tokensBought);
    }

    function swapTokenToEth(uint256 _tokensSold, uint256 _minEth) public {
        uint256 tokenReserve = getReserve();

        uint256 ethBought = getAmountOfTokens(
            _tokensSold,
            tokenReserve,
            address(this).balance
        );

        require(
            ethBought >= _minEth,
            "We cant service your request now. Please try again"
        );

        ERC20(bananaTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _tokensSold
        );

        payable(msg.sender).transfer(ethBought);
    }
}


//Exchange Contract Address - 0x281372331db347E2346648c8b7426A188f1801A3
//Etherscan - https://rinkeby.etherscan.io/address/0x281372331db347E2346648c8b7426A188f1801A3
