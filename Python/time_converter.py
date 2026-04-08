"""
Convert minutes into human-readable format
Example:
130 -> 2 hrs 10 minutes
110 -> 1 hr 50 minutes
"""

def convert_minutes(minutes):
    # Calculate hours and remaining minutes
    hours = minutes // 60
    mins = minutes % 60

    # Format output
    if hours > 0:
        if hours == 1:
            return f"{hours} hr {mins} minutes"
        else:
            return f"{hours} hrs {mins} minutes"
    else:
        return f"{mins} minutes"


# Test cases
print("Input: 130 -> Output:", convert_minutes(130))
print("Input: 110 -> Output:", convert_minutes(110))
print("Input: 45 -> Output:", convert_minutes(45))
print("Input: 60 -> Output:", convert_minutes(60))