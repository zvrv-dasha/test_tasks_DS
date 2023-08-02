def isBrokenVersion(version: int, bad: int) -> bool:
    if version >= bad:
        return True
    return False

def solve(n: int, bad: int) -> int:
    """
    O(log(n)) - сложность алгоритма
    O(1) - память
    """
    low = 1
    high = n
    while low < high:
        mid = (low + high) // 2
        if isBrokenVersion(mid, bad) == True:
            high = mid
        else:
            low = mid + 1
    return low

def main():
    n_1 = 5
    bad_1 = 4
    n_2 = 1
    bad_2 = 1
    assert solve(n_1, bad_1) == bad_1
    assert solve(n_2, bad_2) == bad_2
    print(solve(n_1, bad_1))
    print(solve(n_2, bad_2))

if __name__ == "__main__":
    main()