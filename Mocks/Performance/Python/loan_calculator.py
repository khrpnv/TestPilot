import math

class LoanCalculator:
    def calculate_monthly_installment(self, amount: float, annual_interest: float, months: int) -> float:
        rate = annual_interest / 100.0 / 12.0
        return (amount * rate) / (1 - math.pow(1 + rate, -months))

    def generate_amortization_schedule(self, amount: float, annual_interest: float, months: int) -> list[float]:
        monthly = self.calculate_monthly_installment(amount, annual_interest, months)
        return [monthly for _ in range(months)]
