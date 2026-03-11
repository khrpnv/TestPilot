class BankAccountError(Exception):
    pass

class InsufficientFundsError(BankAccountError):
    pass

class AccountNotFoundError(BankAccountError):
    pass

class BankAccount:
    def __init__(self, account_id, owner, balance=0.0):
        self.id = account_id
        self.owner = owner
        self.balance = balance

class BankAccountManager:
    def __init__(self):
        self._accounts = {}

    def create_account(self, account):
        self._accounts[account.id] = account

    def deposit(self, account_id, amount):
        account = self._get_account(account_id)
        account.balance += amount

    def withdraw(self, account_id, amount):
        account = self._get_account(account_id)
        if account.balance < amount:
            raise InsufficientFundsError("Insufficient funds.")
        account.balance -= amount

    def get_balance(self, account_id):
        account = self._get_account(account_id)
        return account.balance

    def _get_account(self, account_id):
        if account_id not in self._accounts:
            raise AccountNotFoundError(f"Account {account_id} not found.")
        return self._accounts[account_id]
