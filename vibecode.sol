// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title DeflationaryToken
 * @dev A simple ERC20-like token with a 1% burn-on-transfer mechanism.
 *
 * IMPORTANT: This contract is for educational purposes only. It has not been
 * professionally audited and is not guaranteed to be secure for production use.
 * Do not deploy this contract on a mainnet with real funds.
 */
contract DeflationaryToken {
    // --- State Variables ---

    string public constant name = "Deflationary Test Token";
    string public constant symbol = "DTT";
    uint8 public constant decimals = 18;

    // The burn rate is 1%. The divisor is 100, so (amount / 100) is 1% of the amount.
    uint256 public constant BURN_RATE_DIVISOR = 100;

    uint256 private _totalSupply;
    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    // --- Events ---

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // --- Constructor ---

    /**
     * @dev Sets the initial total supply and mints it to the contract deployer's address.
     * This constructor takes no arguments, as requested.
     */
    constructor() {
        // Set an initial supply of 1,000,000 tokens.
        // The total supply is multiplied by 10**decimals to account for the decimal places.
        uint256 initialSupply = 1000000 * (10**uint256(decimals));
        _totalSupply = initialSupply;

        // Assign the entire initial supply to the address that deployed the contract.
        _balances[msg.sender] = initialSupply;

        // Emit a transfer event to signify the minting of the initial tokens.
        emit Transfer(address(0), msg.sender, initialSupply);
    }

    // --- Public View Functions ---

    /**
     * @dev Returns the total supply of tokens, which decreases over time.
     */
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev Returns the token balance of a specific address.
     */
    function balanceOf(address account) public view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev Returns the remaining number of tokens that `spender` is allowed
     * to spend on behalf of `owner`.
     */
    function allowance(address owner, address spender) public view returns (uint256) {
        return _allowances[owner][spender];
    }

    // --- Public Write Functions ---

    /**
     * @dev Moves `amount` of tokens from the caller's account to `recipient`.
     * This function includes the deflationary burn mechanism.
     * Returns a boolean indicating success.
     */
    function transfer(address recipient, uint256 amount) public virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     * Returns a boolean indicating success.
     */
    function approve(address spender, uint256 amount) public virtual returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is deducted from the caller's allowance.
     * This transfer is also subject to the burn fee.
     * Returns a boolean indicating success.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[sender][msg.sender];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, currentAllowance - amount);
        
        return true;
    }
    
    // --- Internal Functions ---

    /**
     * @dev The core logic for transferring tokens, including the burn mechanism.
     * This function is internal and reused by both `transfer` and `transferFrom`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        // --- Deflationary Mechanism ---
        // 1. Calculate the burn amount (1% of the transaction amount).
        uint256 burnAmount = amount / BURN_RATE_DIVISOR;
        
        // 2. Calculate the actual amount the recipient will receive.
        uint256 transferAmount = amount - burnAmount;

        // 3. Update balances. The sender's balance is reduced by the full amount.
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += transferAmount;

        // 4. Burn the tokens by reducing the total supply.
        _totalSupply -= burnAmount;

        // Emit events for both the main transfer and the burn.
        emit Transfer(sender, recipient, transferAmount);
        // The burn is represented as a transfer to the zero address (address(0)).
        emit Transfer(sender, address(0), burnAmount);
    }
    
    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`'s tokens.
     * This is an internal function to be reused.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
