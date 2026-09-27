import evdev

try:
    d = evdev.InputDevice('/dev/input/event2')
    print('Device:', d.name)
    caps = d.capabilities(verbose=True)
    for k, v in caps.items():
        print(k, v)
except Exception as e:
    print('Error:', e)
