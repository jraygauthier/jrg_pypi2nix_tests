
import itertools
from time import sleep

def say_hello() -> None:
    print("Hello world!")
    for s in itertools.repeat("!", 5):
        sleep(0.2)
        print(s)
