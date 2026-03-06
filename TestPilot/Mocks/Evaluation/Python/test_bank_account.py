import unittest
from bank_account import BankAccount

class BankAccountTests(unittest.TestCase):
    def test_deposit_increases_balance(self):
        account = BankAccount(100)
        account.deposit(50)
        self.assertEqual(account.balance, 150)

    def test_withdraw_reduces_balance(self):
        account = BankAccount(200)
        account.withdraw(50)
        self.assertEqual(account.balance, 150)
