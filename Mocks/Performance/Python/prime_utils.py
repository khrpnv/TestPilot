import math

class PrimeUtils:
    def is_prime(self, number: int) -> bool:
        if number < 2:
            return False
        if number == 2:
            return True
        if number % 2 == 0:
            return False
        max_divisor = int(math.sqrt(number))
        for divisor in range(3, max_divisor + 1, 2):
            if number % divisor == 0:
                return False
        return True

    def generate_primes(self, limit: int) -> list[int]:
        primes = []
        for i in range(2, limit + 1):
            if self.is_prime(i):
                primes.append(i)
        return primes
