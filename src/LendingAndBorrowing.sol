// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract LendingAndBorrowing {
    mapping(address => uint256) private userDeposits;
    mapping(address => uint256) private userBorrows;
    uint256 private totalDeposits;
    address public treasury;

    event DepositEvent(
        address indexed user,
        uint256 amount,
        uint256 oldTotalDeposits,
        uint256 newTotalDeposits,
        uint256 oldUserDeposit,
        uint256 newUserDeposit
    );

    event WithdrawalEvent(
        address indexed user,
        uint256 amount,
        uint256 oldTotalDeposits,
        uint256 newTotalDeposits,
        uint256 oldUserDeposit,
        uint256 newUserDeposit
    );

    event BorrowEvent(
        address indexed user,
        uint256 amount,
        uint256 oldBorrow,
        uint256 newBorrow,
        uint256 maxBorrowAllowed
    );

    event RepaymentEvent(
        address indexed user,
        uint256 amount,
        uint256 oldBorrow,
        uint256 newBorrow
    );

    event TreasurySet(address indexed treasuryAddress);

    modifier onlySender(address user) {
        require(msg.sender == user, "Unauthorized");
        _;
    }

    function recordDeposit(address user, uint256 amount) external onlySender(user) {
        require(amount > 0, "Amount must be > 0");

        uint256 oldUserDeposit = userDeposits[user];
        uint256 oldTotalDeposits = totalDeposits;

        uint256 newUserDeposit = oldUserDeposit + amount;
        uint256 newTotalDeposits = oldTotalDeposits + amount;

        userDeposits[user] = newUserDeposit;
        totalDeposits = newTotalDeposits;

        emit DepositEvent(
            user,
            amount,
            oldTotalDeposits,
            newTotalDeposits,
            oldUserDeposit,
            newUserDeposit
        );
    }

    function recordWithdrawal(address user, uint256 amount) external onlySender(user) {
        require(amount > 0, "Amount must be > 0");

        uint256 oldUserDeposit = userDeposits[user];
        uint256 oldTotalDeposits = totalDeposits;

        require(oldUserDeposit >= amount, "Insufficient balance");

        uint256 newUserDeposit = oldUserDeposit - amount;
        uint256 newTotalDeposits = oldTotalDeposits - amount;

        userDeposits[user] = newUserDeposit;
        totalDeposits = newTotalDeposits;

        emit WithdrawalEvent(
            user,
            amount,
            oldTotalDeposits,
            newTotalDeposits,
            oldUserDeposit,
            newUserDeposit
        );
    }

    function recordBorrow(address user, uint256 amount) external onlySender(user) {
        require(amount > 0, "Amount must be > 0");

        uint256 deposited = userDeposits[user];
        uint256 borrowed = userBorrows[user];

        uint256 maxBorrow = (deposited * 70) / 100;
        require(borrowed + amount <= maxBorrow, "Exceeds max borrow limit");

        uint256 oldBorrow = borrowed;
        uint256 newBorrow = borrowed + amount;

        userBorrows[user] = newBorrow;

        emit BorrowEvent(
            user,
            amount,
            oldBorrow,
            newBorrow,
            maxBorrow
        );
    }

    function recordRepayment(address user, uint256 amount) external onlySender(user) {
        require(amount > 0, "Amount must be > 0");

        uint256 borrowed = userBorrows[user];
        require(borrowed > 0, "Nothing to repay");

        uint256 repayAmount = amount > borrowed ? borrowed : amount;

        uint256 oldBorrow = borrowed;
        uint256 newBorrow = borrowed - repayAmount;

        userBorrows[user] = newBorrow;

        emit RepaymentEvent(
            user,
            repayAmount,
            oldBorrow,
            newBorrow
        );
    }

    function getUserBalances(address user) external view returns (uint256 deposit, uint256 borrow) {
        deposit = userDeposits[user];
        borrow = userBorrows[user];
    }

    function getTotalInSystem() external view returns (uint256) {
        return totalDeposits;
    }

    function setTreasury(address admin) external {
        require(treasury == address(0), "Treasury already set");
        treasury = admin;

        emit TreasurySet(admin);
    }
}
