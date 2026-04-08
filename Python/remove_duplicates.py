"""
Remove duplicate characters from a string using loop
"""

def remove_duplicates(input_string):
    result = ""

    for char in input_string:
        if char not in result:
            result += char

    return result


# Test cases
print("Input: programming -> Output:", remove_duplicates("programming"))
print("Input: hello -> Output:", remove_duplicates("hello"))
print("Input: aabbcc -> Output:", remove_duplicates("aabbcc"))