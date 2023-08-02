def solve(nums: list[int], target: int) -> list[int]:
    """
    O(n) - сложность алгоритма
    O(n) - память
    """
    dictNums = {}
    n = len(nums)

    for i in range(n):
        difference = target - nums[i]
        if difference in dictNums:
            return [dictNums[difference], i]
        dictNums[nums[i]] = i

def main():
    nums_1 = [2,7,11,15]
    nums_2 = [3,2,4]
    nums_3 = [3,3]
    target_1 = 9
    target_2 = 6
    target_3 = 6
    assert solve(nums_1, target_1) == [0,1]
    assert solve(nums_2, target_2) == [1,2]
    assert solve(nums_3, target_3) == [0,1]

if __name__ == "__main__":
    main()