/// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

contract LoanLending {
    address public owner;
    uint256 public minimumLoanAmount;
    uint256 public maximumLoanAmount;
    uint256 public interestRate; // Annual interest rate in percentage (e.g., 10 for 10%)
    uint256 public loanDuration; // Duration in seconds

    struct Loan {
        uint256 amount;
        uint256 startTime;
        uint256 endTime;
        uint256 interest;
        bool isActive;
        bool isPaid;
    }

    mapping(address => Loan) public loans;

    event LoanRequested(address borrower, uint256 amount, uint256 interest);
    event LoanRepaid(address borrower, uint256 amount, uint256 interest);

    constructor(
        uint256 _minimumLoanAmount,
        uint256 _maximumLoanAmount,
        uint256 _interestRate,
        uint256 _loanDuration
    ) {
        owner = msg.sender;
        minimumLoanAmount = _minimumLoanAmount;
        maximumLoanAmount = _maximumLoanAmount;
        interestRate = _interestRate;
        loanDuration = _loanDuration;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // Function to allow contract to receive ETH
    receive() external payable {}

    // Function to request a loan
    function requestLoan(uint256 _amount) external {
        require(!loans[msg.sender].isActive, "You already have an active loan");
        require(
            _amount >= minimumLoanAmount && _amount <= maximumLoanAmount,
            "Loan amount out of range"
        );
        require(
            address(this).balance >= _amount,
            "Insufficient contract balance"
        );

        uint256 interest = calculateInterest(_amount);
        uint256 endTime = block.timestamp + loanDuration;

        loans[msg.sender] = Loan({
            amount: _amount,
            startTime: block.timestamp,
            endTime: endTime,
            interest: interest,
            isActive: true,
            isPaid: false
        });

        payable(msg.sender).transfer(_amount);

        emit LoanRequested(msg.sender, _amount, interest);
    }

    // Function to repay loan
    function repayLoan() external payable {
        Loan storage loan = loans[msg.sender];
        require(loan.isActive, "No active loan found");
        require(!loan.isPaid, "Loan already paid");

        uint256 totalAmount = loan.amount + loan.interest;
        require(msg.value >= totalAmount, "Insufficient repayment amount");

        loan.isActive = false;
        loan.isPaid = true;

        // Return excess payment if any
        if (msg.value > totalAmount) {
            payable(msg.sender).transfer(msg.value - totalAmount);
        }

        emit LoanRepaid(msg.sender, loan.amount, loan.interest);
    }

    // Function to calculate interest
    function calculateInterest(uint256 _amount) public view returns (uint256) {
        return (_amount * interestRate * loanDuration) / (365 days * 100);
    }

    // Function to withdraw contract balance (only owner)
    function withdrawFunds() external onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to withdraw");
        payable(owner).transfer(balance);
    }

    // Function to get loan details
    function getLoanDetails(
        address _borrower
    )
        external
        view
        returns (
            uint256 amount,
            uint256 startTime,
            uint256 endTime,
            uint256 interest,
            bool isActive,
            bool isPaid
        )
    {
        Loan memory loan = loans[_borrower];
        return (
            loan.amount,
            loan.startTime,
            loan.endTime,
            loan.interest,
            loan.isActive,
            loan.isPaid
        );
    }

    // Function to update contract parameters (only owner)
    function updateParameters(
        uint256 _minimumLoanAmount,
        uint256 _maximumLoanAmount,
        uint256 _interestRate,
        uint256 _loanDuration
    ) external onlyOwner {
        minimumLoanAmount = _minimumLoanAmount;
        maximumLoanAmount = _maximumLoanAmount;
        interestRate = _interestRate;
        loanDuration = _loanDuration;
    }
}
